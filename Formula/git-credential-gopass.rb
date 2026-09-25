class GitCredentialGopass < Formula
  desc "Git credential helper that stores credentials in gopass"
  homepage "https://github.com/gopasspw/git-credential-gopass"
  url "https://github.com/gopasspw/git-credential-gopass/archive/refs/tags/v1.17.3.tar.gz"
  sha256 "5b5d017234eb59c153ec29b6ea3dcec78e12934a344c519e4bb90cadafbe75a8"
  license "MIT"
  head "https://github.com/gopasspw/git-credential-gopass.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/pavelnovichkov/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "6be130d1707fee1e72be3e4a14bb9964d908f19ab42220d02b48c0478bccdd24"
    sha256 cellar: :any,                 x86_64_linux: "6ee889fac193fa3c4d08e344ffb65fcd19958216bfcd14e1a69ffc9183c675b2"
  end

  depends_on "go" => :build
  depends_on "gopass"

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end
end
