class GitCredentialGopass < Formula
  desc "Git credential helper that stores credentials in gopass"
  homepage "https://github.com/gopasspw/git-credential-gopass"
  url "https://github.com/gopasspw/git-credential-gopass/archive/refs/tags/v1.17.0.tar.gz"
  sha256 "2efe7cc34ad18f4e12368d24528c5b589c9d0796a606ede8154ad6a412b05ad0"
  license "MIT"
  head "https://github.com/gopasspw/git-credential-gopass.git", branch: "master"

  depends_on "go" => :build
  depends_on "gopass"

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end
end
