class GitCredentialGopass < Formula
  desc "Git credential helper that stores credentials in gopass"
  homepage "https://github.com/gopasspw/git-credential-gopass"
  url "https://github.com/gopasspw/git-credential-gopass/archive/refs/tags/v1.17.2.tar.gz"
  sha256 "d73a0d7f9a062a2297b31f7aa2ba48447614fe194716d1034532ab9a6acacc06"
  license "MIT"
  head "https://github.com/gopasspw/git-credential-gopass.git", branch: "master"

  depends_on "go" => :build
  depends_on "gopass"

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end
end
