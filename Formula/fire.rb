class Fire < Formula
  desc "Feynman Integral REduction by integration-by-parts identities"
  homepage "https://gitlab.srcc.msu.ru/feynmanintegrals/fire"
  url "https://gitlab.srcc.msu.ru/feynmanintegrals/fire/-/archive/7.1/fire-7.1.tar.gz"
  sha256 "7c16e78254212bcf9d97db42e690291b4344b796e9132dd08204bca43efaad1f"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://gitlab.srcc.msu.ru/feynmanintegrals/fire.git"
    strategy :git
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  pour_bottle? do
    reason "The bundled Fermat binary and FUEL library grant no right to redistribute them."
    satisfy { false }
  end

  depends_on "flint"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "zstd"

  on_macos do
    # The build hardcodes -fopenmp, which Apple clang does not accept, and
    # upstream explicitly recommends the brewed LLVM toolchain on macOS.
    depends_on "libomp"
    depends_on "llvm"
  end

  # FUEL, the simplifier interface layer, is a git submodule of FIRE. Homebrew
  # builds must not hit the network, so it is vendored here, pinned to the
  # commit that the FIRE release tag records for FIRE7/extra/fuel; update it
  # together with `url`.
  resource "fuel" do
    url "https://gitlab.com/feynmanintegrals/fuel/-/archive/8627acefec5be237080e94c1ea903a52c680aa32/fuel-8627acefec5be237080e94c1ea903a52c680aa32.tar.gz"
    version "8627acefec5be237080e94c1ea903a52c680aa32"
    sha256 "5a193a739b193ec6e9a6261ef8bcc51f0f3b0e28eb6f1156a83f863780c7f763"
  end

  def install
    (buildpath/"FIRE7/extra/fuel").install resource("fuel")

    # Prefer the brewed LLVM on macOS, as upstream documents, but keep going
    # through Homebrew's compiler shim so that dependency include/library
    # paths are injected into the hand-written Makefiles.
    ENV.llvm_clang if OS.mac?

    cd "FIRE7" do
      inreplace "Makefile.in" do |s|
        # `make dep` otherwise creates a throwaway git repository and clones the
        # submodules; both are already staged, and neither is allowed here.
        s.gsub! "dep: prepare_git depend", "dep: depend"
        s.gsub! "\tcd .. && $(GIT) submodule update --init --recursive FIRE7/extra/fuel\n", ""
        s.gsub! "\tcd .. && $(GIT) submodule update --init --recursive FIRE7/extra/zstd\n", ""

        # Link against the brewed zstd instead of building the vendored copy.
        s.gsub! "\texport CXX=$(CCPLUS) && export CC=$(CC) && $(MAKE) -C ./extra/zstd\n", ""
        s.gsub! "\t$(MAKE) -C ./extra/zstd PREFIX=`pwd`/usr/ uninstall\n", ""
        s.gsub! "\t$(MAKE) -C ./extra/zstd PREFIX=`pwd`/usr/ install\n", ""

        # Link the vendored kyotocabinet statically on macOS too, as upstream
        # does on Linux, instead of against a dylib in the build directory.
        s.gsub! "--disable-zlib", "--disable-zlib --disable-shared"
      end

      # FLINT >= 3.3 no longer pulls in fmpq.h transitively.
      inreplace "extra/fuel/library/mpoly_factor_flint.cpp",
                "#include \"mpoly_factor_flint.h\"",
                "#include \"mpoly_factor_flint.h\"\n#include <flint/fmpq.h>"

      # Not a GNU configure script: it only rewrites the Makefiles.
      # FLINT is the default simplifier backend of FIRE 7 and is taken from
      # Homebrew rather than built from the (network-fetched) submodule.
      args = %W[
        --enable-zstd
        --no-install-flint
        --cpp=#{ENV.cxx}
        --cc=#{ENV.cc}
      ]
      system "./configure", *args
      system "make", "dep"
      system "make"

      # The layout below mirrors upstream's own package.sh: the executables
      # find each other and the simplifier settings through
      # paths relative to argv[0], so the tree has to stay intact.
      libexec.install "bin", "FIRE7.m", "mm", "examples"

      %w[poly prime multiprime].each do |dir|
        (libexec/dir).install Dir["#{dir}/{FIRE7,FLAME7,Ftool7,eqgen_external_solver}"]
      end
      (libexec/"tools").install Dir["tools/{add,combine,compose,diff,lcm,reconstruct," \
                                    "substitute,tables2rules}"]

      (libexec/"extra/fuel").install "extra/fuel/libraryBinarySettings"
      # Fermat is a freeware x86_64 binary shipped with FUEL; on other
      # architectures it cannot run, and FLINT is used instead anyway.
      if Hardware::CPU.intel?
        fermat = OS.mac? ? "ferm64" : "ferl64"
        (libexec/"extra/fuel/extra").install "extra/fuel/extra/#{fermat}"
      end

      # LiteRed 1.8.3 by R.N. Lee, shipped with FIRE and used by FIRE7.m.
      (libexec/"extra").install "extra/LiteRed"

      # bin/ ships symlinks for the MPI and GPU executables too, which are not built
      Dir[libexec/"bin/*"].each { |link| rm link if File.symlink?(link) && !File.exist?(link) }

      %w[FIRE7 FIRE7p FIRE7mp FLAME7 FLAME7p FLAME7mp FTool7 FTool7p FTool7mp].each do |exe|
        bin.write_exec_script libexec/"bin/#{exe}"
      end

      pkgshare.install_symlink libexec/"FIRE7.m", libexec/"mm", libexec/"examples",
                               libexec/"extra/LiteRed"
    end

    doc.install "README.md", "CHANGELOG.md"
  end

  def caveats
    <<~EOS
      FIRE is built with the FLINT simplifier backend (--calc flint, the default);
      the ginac, pari and symbolica backends are not compiled in. The Fermat
      binary shipped by upstream is installed as well (--calc fermat); it is
      freeware, so check its terms before use:
        https://home.bway.net/lewis/

      Mathematica interface, examples and the bundled LiteRed 1.8.3:
        #{opt_pkgshare}/FIRE7.m
        #{opt_pkgshare}/examples
        #{opt_pkgshare}/LiteRed
      Using LiteRed requires citing https://arxiv.org/abs/1310.1145 as well.

      The auxiliary tools (add, combine, compose, diff, lcm, reconstruct,
      substitute, tables2rules) are not linked into #{HOMEBREW_PREFIX}/bin
      because of their generic names; they live in:
        #{opt_libexec}/bin

      The MPI executables are not built.
    EOS
  end

  test do
    cp_r [pkgshare/"examples/box.start", pkgshare/"examples/box.m"], testpath

    (testpath/"box.config").write <<~EOS
      #compressor        none
      #threads           1
      #fthreads          2
      #variables         d
      #start
      #folder            ./
      #problem           1 box.start
      #integrals         box.m
      #output            box.tables
    EOS

    output = shell_output("#{bin}/FIRE7 --calc flint -c #{testpath}/box")
    assert_match "Master integrals: 3", output
    assert_match "d^2", (testpath/"box.tables").read
  end
end
