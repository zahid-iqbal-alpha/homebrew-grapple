require "open-uri"
require "json"
require "digest"

class GrappleCli < Formula
  desc "Command-line interface for Grapple"
  homepage "https://github.com/grapple-solutions/grapple-cli"

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    unless @github_token
      raise CurlDownloadStrategyError, "Environmental variable HOMEBREW_GITHUB_API_TOKEN is required."
    end
    validate_github_repository_access!
  end

  def validate_github_repository_access!
    # Test access to the repository
    GitHub.repository(@owner, @repo)
    rescue GitHub::API::HTTPNotFoundError
    # We switched to GitHub::API::HTTPNotFoundError,
    # because we can now handle bad credentials messages
    message = <<~EOS
      HOMEBREW_GITHUB_API_TOKEN can not access the repository: #{@owner}/#{@repo}
      This token may not have permission to access the repository or the url of formula may be incorrect.
    EOS
    raise CurlDownloadStrategyError, message
  end
  
  def self.latest_release_version(repo_owner, repo_name)
    set_github_token
    url = "https://api.github.com/repos/#{repo_owner}/#{repo_name}/releases/latest"
    response = URI.parse(url).open
    latest_release = JSON.parse(response.read)
    latest_release["tag_name"]
  end

  version latest_release_version("grapple-solutions", "grapple-cli")

  url "https://github.com/grapple-solutions/grapple-cli/archive/refs/tags/#{version}.tar.gz"

  def install
    libexec.install Dir["*"]
    bin.write_exec_script (libexec/"grpl")
  end
  test do
    system "#{bin}/grpl", "--version"
  end
end
