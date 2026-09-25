class Qgraf < Formula
  desc "Feynman diagram generator"
  homepage "https://qgraf.ist.utl.pt/~paulo/qgraf.html"
  # The manual's "Automatic downloads" section asks packages to use `links/`.
  url "http://qgraf.tecnico.ulisboa.pt/links/qgraf-4.0.5.tgz", user: "anonymous:anonymous"
  sha256 "2dabf4305aa192ef78621763bb9e275fdcbd900d435f8dcb7d1aed916bab0a99"
  # Free for academic research and teaching only; redistribution, including
  # bottles, is not permitted.
  license :cannot_represent

  livecheck do
    url "http://anonymous:anonymous@qgraf.tecnico.ulisboa.pt/links/"
    regex(/href=.*?qgraf[._-]v?(\d+(?:\.\d+){2})\.t/i)
  end

  depends_on "gcc" # for gfortran

  def install
    system "make", "qgraf"
    bin.install "qgraf"
    pkgshare.install "models", "styles"
    doc.install "qgraf-#{version}.pdf"
  end

  def caveats
    <<~EOS
      Example models and styles are installed to:
        #{opt_pkgshare}/models
        #{opt_pkgshare}/styles

      QGRAF rejects paths containing dots, such as `/home/linuxbrew/.linuxbrew`,
      so copy the files you need into your working directory rather than
      pointing `model_dir` or `style_dir` at them.
    EOS
  end

  test do
    # qgraf rejects paths containing dots, such as `/home/linuxbrew/.linuxbrew`.
    cp [pkgshare/"models/qed", pkgshare/"styles/sum.sty"], testpath
    (testpath/"qgraf.dat").write <<~EOS
      output_dir = './' ;
      style = 'sum.sty' ;
      output = 'qed.out' ;
      model = 'qed' ;
      in = e_minus[p1] ;
      out = e_minus[q1], photon[q2] ;
      loops = 1 ;
      loop_momentum = k ;
      options = onepi ;
    EOS
    # qgraf exits successfully even on errors, so check the diagram count.
    assert_match(/total = +1 connected diagram$/, shell_output("#{bin}/qgraf qgraf.dat"))
  end
end
