class OpsAgent < Formula
  desc "Kubernetes operations agent terminal"
  homepage "https://github.com/Chengyunlai/ops-agent"
  version "0.1.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.1/ops-agent_0.1.1_darwin-arm64.tar.gz"
      sha256 "45487abe13b901ac33bff573320539a455ac40bac7bb949a3167e3015e20c0de"
    else
      url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.1/ops-agent_0.1.1_darwin-amd64.tar.gz"
      sha256 "843f220b53d9cb92d9c669160daa8d360eb48790833e9647133ef94221ad738e"
    end
  end

  on_linux do
    url "https://github.com/Chengyunlai/ops-agent/releases/download/v0.1.1/ops-agent_0.1.1_linux-amd64.tar.gz"
    sha256 "92cc67632177eb19978bd1fea34481f1bbf2c19de4e18d35d6e96d58a4bcd389"
    depends_on arch: :x86_64
  end

  def install
    bin.install "ops-agent", "ops_agent"
    pkgshare.install "config.example.toml"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ops-agent --version")
  end
end
