class Sip < Formula
  include Language::Python::Virtualenv

  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://python-sip.readthedocs.io/en/latest/"
  url "https://files.pythonhosted.org/packages/3e/f5/85bfb3c716b8eda9e2b0c0c5f36acb701746045c828a4497a44e581db3a6/sip-6.8.5.tar.gz"
  sha256 "5dddd5966e9875d89ecde9d3e6ac63225f9972e4d25c09e20fa22f1819409c70"
  license "BSD-2-Clause"
  head "https://github.com/Python-SIP/sip.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "5166559a1a609ede21b1462a91430ded1bc13c4da31eebf2495582c79cd57a05"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "5166559a1a609ede21b1462a91430ded1bc13c4da31eebf2495582c79cd57a05"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5166559a1a609ede21b1462a91430ded1bc13c4da31eebf2495582c79cd57a05"
    sha256 cellar: :any_skip_relocation, sonoma:         "10f91e96f31d796efa5100b0843acfd9a5fa38321564f478bc530b1778762c00"
    sha256 cellar: :any_skip_relocation, ventura:        "10f91e96f31d796efa5100b0843acfd9a5fa38321564f478bc530b1778762c00"
    sha256 cellar: :any_skip_relocation, monterey:       "10f91e96f31d796efa5100b0843acfd9a5fa38321564f478bc530b1778762c00"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "026973a84e2f213a792080539d290c599ed716571ec4424acc87fd28b75d9891"
  end

  depends_on "python@3.12"

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/51/65/50db4dda066951078f0a96cf12f4b9ada6e4b811516bf0262c0f4f7064d4/packaging-24.1.tar.gz"
    sha256 "026ed72c8ed3fcce5bf8950572258698927fd1dbda10a5e981cdf0ac37f4f002"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/1c/1c/8a56622f2fc9ebb0df743373ef1a96c8e20410350d12f44ef03c588318c3/setuptools-70.1.0.tar.gz"
    sha256 "01a1e793faa5bd89abc851fa15d0a0db26f160890c7102cd8dce643e886b47f5"
  end

  def install
    python3 = "python3.12"
    venv = virtualenv_install_with_resources

    # Modify the path sip-install writes in scripts as we install into a
    # virtualenv but expect dependents to run with path to Python formula
    inreplace venv.site_packages/"sipbuild/builder.py", /\bsys\.executable\b/, "\"#{which(python3)}\""
  end

  test do
    (testpath/"pyproject.toml").write <<~EOS
      # Specify sip v6 as the build system for the package.
      [build-system]
      requires = ["sip >=6, <7"]
      build-backend = "sipbuild.api"

      # Specify the PEP 566 metadata for the project.
      [tool.sip.metadata]
      name = "fib"
    EOS

    (testpath/"fib.sip").write <<~EOS
      // Define the SIP wrapper to the (theoretical) fib library.

      %Module(name=fib, language="C")

      int fib_n(int n);
      %MethodCode
          if (a0 <= 0)
          {
              sipRes = 0;
          }
          else
          {
              int a = 0, b = 1, c, i;

              for (i = 2; i <= a0; i++)
              {
                  c = a + b;
                  a = b;
                  b = c;
              }

              sipRes = b;
          }
      %End
    EOS

    system "#{bin}/sip-install", "--target-dir", "."
  end
end
