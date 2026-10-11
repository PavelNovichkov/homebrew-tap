class Finiteflow < Formula
  desc "Multivariate functional reconstruction using finite fields and dataflow graphs"
  homepage "https://github.com/peraro/finiteflow"
  url "https://github.com/peraro/finiteflow/archive/b951bf7361643292ae3846383281e5f4626dad78.tar.gz"
  version "20260808"
  sha256 "d37cb0837d7f455f72f27c41c8b9bfa78e684a10746d60815fedee73fd75c54f"
  license "MIT"

  # This formula tracks specific commits rather than upstream releases.
  livecheck do
    skip "Tracks specific commits"
  end

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

  test do
    (testpath/"test.c").write <<~C
      #include <fflow/capi.h>
      #include <stdio.h>

      int main(void)
      {
        FFCStr vars[] = {"x", "y"};
        FFCStr functions[] = {"(1+x)/(1+y)"};
        FFNode input;
        FFGraph graph = ffNewGraphWithInput(2, &input);
        FFRatFunList * parsed = ffParseRatFun(vars, 2, functions, 1);
        ffSetOutputNode(graph, ffAlgRatFunEval(graph, input, parsed));

        FFRatFunList * reconstructed;
        if (ffReconstructFunction(graph, (FFRecOptions){0}, &reconstructed) != FF_SUCCESS)
          return 1;
        puts(ffRatFunToStr(reconstructed, 0, vars));
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lfflow", "-o", "test"
    assert_equal "( 1*x+1 )/( 1*y+1 )", shell_output("./test").chomp
  end
end
