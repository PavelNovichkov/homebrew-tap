class Finiteflow < Formula
  desc "Multivariate functional reconstruction using finite fields and dataflow graphs"
  homepage "https://github.com/peraro/finiteflow"
  url "https://github.com/peraro/finiteflow/archive/8761419b506114656f8eacf5194b9820afae0d48.tar.gz"
  version "20260709"
  sha256 "17eb3533a60dd09e8f48edcaa3d8ab8da940caef9a96eab543fb0dddebbc2538"
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
