class GitCredentialGopass < Formula
  desc "Git credential helper that stores credentials in gopass"
  homepage "https://github.com/gopasspw/git-credential-gopass"
  url "https://github.com/gopasspw/git-credential-gopass/archive/refs/tags/v1.17.3.tar.gz"
  sha256 "5b5d017234eb59c153ec29b6ea3dcec78e12934a344c519e4bb90cadafbe75a8"
  license "MIT"
  head "https://github.com/gopasspw/git-credential-gopass.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/pavelnovichkov/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "0b22c2a4b0d13eeee0ba5ddaf41e9caaf8f16c4bcae829dad7bc7e150b51427d"
    sha256 cellar: :any,                 x86_64_linux: "27a17ec2c015f95a268892c858643246c3a82087fde8a6ce5a5d9f8c4ba53957"
  end

  depends_on "go" => :build
  depends_on "gopass"

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end
end
