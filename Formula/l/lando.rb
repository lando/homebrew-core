class Lando < Formula
  desc "Push button development environments"
  homepage "https://docs.lando.dev"
  url "https://github.com/lando/core/archive/refs/tags/v3.23.2.tar.gz"
  sha256 "a3edf4c1d82ce6af725d9760122f74e8ed74d453140d12407bf5764f19b145d5"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "node@20" => :build

  resource("pkg") do
    url "https://registry.npmjs.org/@yao-pkg/pkg/-/pkg-5.15.0.tgz"
    sha256 "1311535b871bb09af0468df7bf09cca8627ce3bac64197add30a6d87c41a7bc6"
  end

  def install
    resource("pkg").stage do
      system "npm", "install", *std_npm_args
      bin.install_symlink Dir["#{libexec}/bin/*"]
    end

    system "npm", "install", "--production", *std_npm_args(prefix: false)
    system "pkg", "--config", "package.json", "--targets", "node20",
     "--out-path" "dist", "--options", "dns-result-order=ipv4first", "bin/lando"
    bin.install "dist/@lando/core" => "lando"
  end

  def caveats
    <<~EOS
      To complete the installation:
        lando setup
    EOS
  end

  test do
    assert_match "127.0.0.1", shell_output("#{bin}/lando config --path proxyIp")
  end
end
