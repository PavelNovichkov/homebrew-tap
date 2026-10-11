class GitCredentialGopass < Formula
  desc "Git credential helper that stores credentials in gopass"
  homepage "https://github.com/gopasspw/git-credential-gopass"
  url "https://github.com/gopasspw/git-credential-gopass/archive/refs/tags/v1.17.4.tar.gz"
  sha256 "115d1a10dc5356f094b6159cc346d81e2f4abae55c1ad03b697f2427e68b748f"
  license "MIT"
  head "https://github.com/gopasspw/git-credential-gopass.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/pavelnovichkov/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "591e54dd63d0457901d5a5ab3f050efe349c7f2d4872e4b40b2bde0695b7690c"
    sha256 cellar: :any,                 x86_64_linux: "cdd2a1105a760eea9a4451a713bc68bcb493061391f76296f228f2c20d373560"
  end

  depends_on "go" => :build
  depends_on "gopass"

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  test do
    (testpath/"batch.gpg").write <<~GPG
      Key-Type: RSA
      Name-Real: Testing
      Name-Email: testing@foo.bar
      %no-protection
      %transient-key
      %commit
    GPG

    begin
      system formula_opt_bin("gnupg")/"gpg", "--batch", "--gen-key", "batch.gpg"
      system formula_opt_bin("gopass")/"gopass", "init", "--path", testpath/"store", "testing@foo.bar"

      pipe_output("#{bin}/git-credential-gopass store", <<~EOS, 0)
        protocol=https
        host=example.com
        username=user
        password=secret
      EOS
      credential = pipe_output("#{bin}/git-credential-gopass get", <<~EOS, 0)
        protocol=https
        host=example.com
      EOS
    ensure
      system formula_opt_bin("gnupg")/"gpgconf", "--kill", "gpg-agent"
    end

    assert_match "password=secret", credential
  end
end
