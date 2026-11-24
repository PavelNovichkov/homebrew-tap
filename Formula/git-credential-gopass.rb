class GitCredentialGopass < Formula
  desc "Git credential helper that stores credentials in gopass"
  homepage "https://github.com/gopasspw/git-credential-gopass"
  url "https://github.com/gopasspw/git-credential-gopass/archive/refs/tags/v1.17.5.tar.gz"
  sha256 "3f6f71d1b8220b2cc9bc4eeb154127b91979ac0fac43e99f9c0ef89a210bdbf3"
  license "MIT"
  head "https://github.com/gopasspw/git-credential-gopass.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/pavelnovichkov/tap"
    manifest_sha256 "cf2984908c5e2552ad58a7e9769a2a42aa102c36623a5bfc6847002c3ea30914"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2798ae0a83d0577b13a460b2b4e5638c037842ce1e7ebb4342864b1edb5c356f"
    sha256 cellar: :any,                 x86_64_linux: "5f6371516b614ccebce615e53d461dd358275f611c3c3b42947ef02dfd692466"
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
