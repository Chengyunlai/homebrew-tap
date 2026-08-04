class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.11"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.11/ops-agent_0.1.11_darwin-arm64.tar.gz"
      sha256 "4360f7b5b8ba787dec953ca917e824f74d419c60569db3bb5dcaa974a190b2ac"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.11/ops-agent_0.1.11_darwin-amd64.tar.gz"
      sha256 "85b40584c55eb8e5bf3a3a80db8df4206c374d4ba83f0c766ef320a720217afd"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.11/ops-agent_0.1.11_linux-amd64.tar.gz"
    sha256 "d9dd124cce7c17eb627247ab43326df38f0cc0d6a196219ab8a76c9fd91c1516"
    depends_on arch: :x86_64
  end

  def install
    libexec.install "ops-agent"
    system "tar", "-czf", libexec/"_internal.tar.gz", "_internal"
    bin.install_symlink libexec/"ops-agent"
    bin.install_symlink libexec/"ops-agent" => "ops_agent"
    pkgshare.install "config.example.toml"
  end

  def post_install
    return if (libexec/"_internal").directory?

    system "tar", "-xzf", libexec/"_internal.tar.gz", "-C", libexec
    rm libexec/"_internal.tar.gz"
    system libexec/"ops-agent", "--version"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ops-agent --version")
  end
end
