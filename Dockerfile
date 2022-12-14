FROM registry.gitlab.com/islandoftex/images/texlive:latest

LABEL \
  org.opencontainers.image.title="Full TeX Live with additions" \
  org.opencontainers.image.authors="Sanjib Kumar Sen <sksenweb@gmail.com>" \
  org.opencontainers.image.source="https://github.com/dante-ev/docker-texlive" \
  org.opencontainers.image.licenses="MIT"

ENV LANG=C.UTF-8
    # LC_ALL=C.UTF-8 \
    # TERM=dumb

# ARG BUILD_DATE
# ARG GITLATEXDIFF_VERSION=1.6.0

WORKDIR /home

# Fix for update-alternatives: error: error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
# RUN mkdir -p /usr/share/man/man1

# # pandoc in the repositories is older - we just overwrite it with a more recent version
# RUN wget https://github.com/jgm/pandoc/releases/download/2.12/pandoc-2.12-1-amd64.deb -q --output-document=/home/pandoc.deb && dpkg -i pandoc.deb && rm pandoc.deb

# # get PlantUML in place
# RUN wget https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar -q --output-document=/home/plantuml.jar
# ENV PLANTUML_JAR=/home/plantuml.jar

# # install pkgcheck
# RUN wget https://gitlab.com/Lotz/pkgcheck/raw/master/bin/pkgcheck -q --output-document=/usr/local/bin/pkgcheck && chmod a+x /usr/local/bin/pkgcheck

# # Install IBM Plex fonts
# RUN mkdir -p /tmp/fonts && \
#     cd /tmp/fonts && \
#     wget "https://github.com/IBM/plex/releases/download/v5.1.3/OpenType.zip" -q && \
#     unzip -q OpenType.zip && \
#     cp -r OpenType/* /usr/local/share/fonts && \
#     fc-cache -f -v && \
#     cd .. && \
#     rm -rf fonts

RUN apt-get update -q && \
    # Install git (Required for git-latexdiff)
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends git latexmk && \
    # Install Ruby's bundler
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 ruby poppler-utils && gem install bundler && \
    # openjdk-8-jre-headless is currently not available in testing
    # solution by https://stackoverflow.com/a/61902164/873282
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 software-properties-common && \
    # apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && \
    # apt-get update && \
    # plantuml requires java8
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends openjdk-8-jre-headless && \
    # proposal by https://github.com/sumandoc/TeXLive-2017
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 curl fontconfig && \
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 curl libgetopt-long-descriptive-perl libdigest-perl-md5-perl fontconfig && \
    # libfile-copy-recursive-perl is required by ctanify
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends libfile-which-perl libfile-copy-recursive-perl openssh-client && \
    # latexindent modules
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 libyaml-tiny-perl libfile-homedir-perl libunicode-linebreak-perl liblog-log4perl-perl libtest-log-dispatch-perl && \
    # for plantuml, we need graphviz and inkscape. For inkscape, there is no non-X11 version, so 200 MB more
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends graphviz inkscape && \
    # some more packages
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends fonts-texgyre latexml && \
    # fig2dev - tool for xfig to translate the figure to other formats
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 fig2dev && \
    # add Google's Inconsolata font (https://fonts.google.com/specimen/Inconsolata)
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 fonts-inconsolata && \
    # required by tlmgr init-usertree
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 xzdec && \
    # install bibtool
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 bibtool && \
    # install Python's pip3
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 python3-pip && \
    # install gnuplot
    # apt-get install -qqy -o=Dpkg::Use-Pty=0 gnuplot && \
    # Removing documentation packages *after* installing them is kind of hacky,
    # but it only adds some overhead while building the image.
    # Source: https://github.com/aergus/dockerfiles/blob/master/latex/Dockerfile
    apt-get --purge remove -qy .\*-doc$ && \
    # save some space
    rm -rf /var/lib/apt/lists/* && apt-get clean && \
    # remove doc files and man pages already installed
    echo "Removing documentation and man pages already installed." &&\
    rm -rf /usr/share/groff/* /usr/share/info/* &&\
    rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* &&\
    rm -rf /usr/share/man &&\
    mkdir -p /usr/share/man &&\
    find /usr/share/doc -depth -type f ! -name copyright -delete &&\
    find /usr/share/doc -type f -name "*.pdf" -delete &&\
    find /usr/share/doc -type f -name "*.gz" -delete &&\
    find /usr/share/doc -type f -name "*.tex" -delete &&\
    (find /usr/share/doc -type d -empty -delete || true) &&\
    mkdir -p /usr/share/doc &&\
    mkdir -p /usr/share/info &&\
    echo "tlmgr install completed, moving fonts" &&\
    (rm -rf /root/texmf/tlpkg || true) &&\
    (rm -rf /root/texmf/web2c || true) &&\
    # cp -n -r /root/texmf/* /usr/share/texlive/texmf-dist/ &&\
    (rm -rf /root/texmf || true) &&\
    (rm -rf /root/texmf-var || true) &&\
    echo "installed packages merged and /root/texmf deleted" &&\
    echo "now deleting useless packages" &&\
    # cd /usr/share/texlive/texmf-dist/tex/latex/ &&\
    # rm -rf a0poster a4wide achemso acro* actuarial* bewerbung biochemistr* \
    #        bithesis bizcard bondgraph* bookshelf bubblesort carbohydrates \
    #        catechis cclicenses changelog cheatsheet circui* commedit comment \
    #        contracard course* csv* currvita* cv* dateiliste* denisbdoc \
    #        diabetes* dinbrief directory dirtytalk duck* duotenzor \
    #        dynkin-diagrams easy* elegant* elzcards emoji enigma es* \
    #        etaremune europasscv europecv exam* exceltex exercis* exesheet \
    #        ffslides fibeamer fink fithesis fixme* fjodor fla* flip* form* \
    #        fonttable forest g-brief gauss gcard gender genealogy* git* \
    #        gloss* gmdoc* HA-prosper hackthefootline halloweenmath hand* \
    #        harnon-cv harpoon harveyballs he-she hobby hpsdiss ifmslide \
    #        image-gallery invoice* interactiveworkbook isorot isotope \
    #        istgame iwhdp jknapltx jlabels jslectureplanner jumplines \
    #        kalendarium kantlipsum keystroke kix knitting* knowledge \
    #        komacv* labels* ladder lectures lettr* lewis logbox magaz \
    #        mail* makebarcode mandi mathexam mceinleger mcexam \
    #        medstarbeamer menu* mi-solns minorrevision minutes mla-paper \
    #        mnotes moderncv modernposter moderntimeline modiagram moodle \
    #        multiaudience mwe my* neuralnetwork newspaper nomen* papermas \
    #        pas-* pb-diagram permutepetiteannonce phf* philex \
    #        phonenumbers photo piff* pinlabel pixelart plantslabels \
    #        pmboxdraw pmgraph polynom* powerdot ppr-prv practicalreports \
    #        pressrelease probsoln productbox progress* proofread protocol \
    #        psbao psfrag* pst-* python qcircuit qcm qrcode qs* quantikz \
    #        quicktype quiz2socrative quotchap qyxf-book ran* rcs* \
    #        readablecv readarray realboxes recipe* rectopma \
    #        reflectgraphics register reotex repeatindex rterface \
    #        rulercompass runcode sa-tikz sauerj schedule schemabloc \
    #        schooldocs scratch* scsnowman sdrt semant* seminar sem* \
    #        sesstime setdeck sf298 sffms shadethm shdoc shipunov \
    #        signchart simple* skb skdoc skeldoc skills skrapport \
    #        smartdiagram spectralsequences sslides studenthandouts svn* \
    #        swfigure swimgraf syntaxdi syntrace synttree table-fct \
    #        tableaux tabu talk tasks tdclock technics ted texmate \
    #        texpower texshade threadcol ticket ticollege todo* \
    #        topiclongtable tqft tucv tufte-latex twoup uebungsblatt uml \
    #        unravel upmethodology uwmslide vdmlisting venndiagram \
    #        verbasef verifiche versonotes vhistory vocaltract was \
    #        webquiz williams willowtreebook worksheet xbmks xcookybooky \
    #        xcpdftips xdoc xebaposter xtuthesis xwatermark xytree ya* \
    #        ycbook ydoc yplan zebra-goodies zed-csp zhlipsum ziffer zw* &&\
    # cd /tmp/ &&\
    # echo "Updating LaTeX and font system files, iteration 1." &&\
    # fc-cache -fv &&\
# delete texlive sources and other potentially useless stuff
    # echo "Removing potentially useless stuff from LaTeX installation." &&\
    # (rm -rf /usr/share/texmf/source || true) &&\
    # (rm -rf /usr/share/texlive/texmf-dist/source || true) &&\
    # (rm -rf /usr/share/texlive/texmf-dist/doc/ || true) &&\
    # find /usr/share/texlive -type f -name "readme*.*" -delete &&\
    # find /usr/share/texlive -type f -name "README*.*" -delete &&\
    # (rm -rf /usr/share/texlive/release-texlive.txt || true) &&\
    # (rm -rf /usr/share/texlive/doc.html || true) &&\
    # (rm -rf /usr/share/texlive/index.html || true) &&\
    # rm -rf /usr/share/texlive/texmf-dist/fonts/source &&\
    # rm -rf /usr/share/texlive/texmf-dist/tex/latex/pst-poker &&\
    # rm -rf /usr/share/texlive/README &&\
    # rm -rf /usr/share/texlive/texmf-dist/texdoctk &&\
    # rm -rf /usr/share/texlive/texmf-dist/texdoc &&\
    # echo "Removing doc and other useless things." &&\
    # rm -rf /usr/share/doc &&\
    # mkdir -p /usr/share/doc &&\
# clean up all temporary files
    echo "Cleaning up temporary files." &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -f /etc/ssh/ssh_host_* &&\
# delete man pages and documentation
    echo "Deleting man pages and documentation." &&\
    rm -rf /usr/share/man &&\
    mkdir -p /usr/share/man &&\
    find /usr/share/doc -depth -type f ! -name copyright -delete &&\
    find /usr/share/doc -type f -name "*.pdf" -delete &&\
    find /usr/share/doc -type f -name "*.gz" -delete &&\
    find /usr/share/doc -type f -name "*.tex" -delete &&\
    (find /usr/share/doc -type d -empty -delete || true) &&\
    mkdir -p /usr/share/doc &&\
    rm -rf /usr/share/texlive/texmf-dist/doc &&\
    rm -rf /var/cache/apt/archives &&\
    mkdir -p /var/cache/apt/archives &&\
    rm -rf /tmp/* /var/tmp/* &&\
    (find /usr/share/ -type f -empty -delete || true) &&\
    (find /usr/share/ -type d -empty -delete || true) &&\
    mkdir -p /usr/share/texmf/source &&\
    mkdir -p /usr/share/texlive/texmf-dist/source\
# Install git-latexdiff v1.6.0 https://gitlab.com/git-latexdiff/git-latexdiff
# RUN git config --global advice.detachedHead false && \
#     git clone --branch "$GITLATEXDIFF_VERSION" --depth=1 https://gitlab.com/git-latexdiff/git-latexdiff.git /tmp/git-latexdiff && \
#     make -C /tmp/git-latexdiff install-bin && \
#     rm -rf /tmp/git-latexdiff
# install-getnonfreefronts uses that directory
# ENV PATH="/usr/local/texlive/2021/bin/x86_64-linux:${PATH}"
# # install luximono
# RUN cd /tmp && wget https://www.tug.org/fonts/getnonfreefonts/install-getnonfreefonts && texlua install-getnonfreefonts && getnonfreefonts --sys luximono
# # update font index
# RUN luaotfload-tool --update
# WORKDIR /workdir