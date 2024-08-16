require "open-uri"
require "json"
require "digest"
require "utils/github"

class GrappleCli < Formula
  desc "Command-line interface for Grapple"
  homepage "https://github.com/grapple-solutions/grapple-cli"

  def self.set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    unless @github_token
      raise CurlDownloadStrategyError, "Environmental variable HOMEBREW_GITHUB_API_TOKEN is required."
    end
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
