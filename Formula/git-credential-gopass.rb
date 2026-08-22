class GitCredentialGopass < Formula
  desc "Git credential helper that stores credentials in gopass"
  homepage "https://github.com/gopasspw/git-credential-gopass"
  url "https://github.com/gopasspw/git-credential-gopass/archive/refs/tags/v1.16.1.tar.gz"
  sha256 "8382b98e56b4547232cc5ea8967eb2a7497a9821a50499d215dafc2f530ba32e"
  license "MIT"
  head "https://github.com/gopasspw/git-credential-gopass.git", branch: "master"

  depends_on "go" => :build
  depends_on "gopass"

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end
end
