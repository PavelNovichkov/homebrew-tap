class Finiteflow < Formula
  desc "Multivariate functional reconstruction using finite fields and dataflow graphs"
  homepage "https://github.com/peraro/finiteflow"
  url "https://github.com/peraro/finiteflow/archive/b951bf7361643292ae3846383281e5f4626dad78.tar.gz"
  version "20260808"
  sha256 "d37cb0837d7f455f72f27c41c8b9bfa78e684a10746d60815fedee73fd75c54f"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "cffi"
  depends_on "gmp"

  # Expose the user's environment in order to build the Mathematica interface,
  # see https://docs.brew.sh/Building-Against-Non-Homebrew-Dependencies for
  # details.
  env :std

  def install
    python_site_packages = prefix/Language::Python.site_packages("python3")

    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DMATHLIBINSTALL=#{pkgshare}/Mathematica",
           # See https://github.com/peraro/finiteflow/issues/6.
           "-DFFLOW_USE_FLINT=OFF",
           "-DFFLOW_PYTHON=ON",
           "-DFFLOW_PYTHON_INSTALL=#{python_site_packages}"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (pkgshare/"Mathematica").install "mathlink/FiniteFlow.m"
  end
end
