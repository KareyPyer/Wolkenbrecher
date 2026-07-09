# =============================================================================
# Dockerfile fusionné : Gemini (prioritaire) + Tycho
# Base : jupyter/datascience-notebook (déjà équipé de Python, R, JupyterLab,
#        conda, et de nombreux packages data-science)
# =============================================================================
FROM jupyter/datascience-notebook:latest [cite: 1]

USER root [cite: 1]
ENV DEBIAN_FRONTEND=noninteractive [cite: 1]

# =============================================================================
# 1. LOCALES
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 [cite: 1]

ENV LANG=en_US.UTF-8 [cite: 1]
ENV LANGUAGE=en_US:en [cite: 1]
ENV LC_ALL=en_US.UTF-8 [cite: 1]

# =============================================================================
# 2. DÉPENDANCES SYSTÈME (Tycho + Gemini)
#    Sont exclus les paquets déjà présents dans l'image de base :
#      python3, python3-pip, python3-venv, r-base, r-base-dev, curl, git, …
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \ [cite: 1, 2]
    build-essential \
    wget \
    unzip \
    gnupg \
    software-properties-common \
    ca-certificates \
    python3-dev \
    libopenblas-dev \
    liblapack-dev \
    # --- Outils DB / réseau --- \
    sqlite3 \
    postgresql-client \
    redis-tools \
    # --- Java (requis par Clojure) --- \
    default-jdk \
    # --- Graphviz (binaire + headers pour pygraphviz) --- \
    graphviz \
    libgraphviz-dev \
    pkg-config \ [cite: 2, 3]
    # --- Éditeur / divers --- \
    emacs-nox \
    rlwrap \
    # --- SSH --- \
    openssh-server \
    sudo \
    # --- Lisp --- \
    sbcl \ [cite: 3]
    && apt-get clean && rm -rf /var/lib/apt/lists/* [cite: 3]

# =============================================================================
# 3. LANGAGES SUPPLÉMENTAIRES (Tycho)
# =============================================================================

# --- Julia 1.9.3 -----------------------------------------------------------
#RUN wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.3-linux-x86_64.tar.gz && \
    #tar -xzf julia-*.tar.gz -C /opt && \ [cite: 3, 4]
    #ln -s /opt/julia-*/bin/julia /usr/local/bin/julia && \
    #rm -f julia-*.tar.gz [cite: 4]
#RUN curl -fsSL https://install.julialang.org | sh [cite: 4, 5]

# --- Clozure Common Lisp ----------------------------------------------------
RUN curl -sL -o ccl.tar.gz \
        https://github.com/Clozure/ccl/releases/download/v1.12/ccl-1.12-linuxx86.tar.gz && \ [cite: 5]
    tar -xzf ccl.tar.gz -C /opt && rm -f ccl.tar.gz && \ [cite: 5]
    ln -s /opt/ccl/lx86cl64 /usr/local/bin/ccl [cite: 5]

# --- Clojure ----------------------------------------------------------------
RUN curl -sLO https://download.clojure.org/install/linux-install-1.11.1.1413.sh && \ [cite: 5]
    chmod +x linux-install-1.11.1.1413.sh && \ [cite: 5]
    ./linux-install-1.11.1.1413.sh && \ [cite: 5]
    rm -f linux-install-1.11.1.1413.sh [cite: 5]

# =============================================================================
# 4. CONFIGURATION SSH (Tycho)
# =============================================================================
RUN mkdir -p /var/run/sshd && \ [cite: 5, 6]
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \ [cite: 6]
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \ [cite: 6]
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config [cite: 6]

# =============================================================================
# 5. UTILISATEUR "dev" (Tycho – accès SSH / sudo)
# =============================================================================
RUN useradd -ms /bin/bash dev && \ [cite: 6, 7]
    echo "dev:dev" | chpasswd && \ [cite: 7]
    adduser dev sudo [cite: 7]

# =============================================================================
# 6. EMACS – plugins data-science (Tycho)
#    ⚠️  Requiert install-emacs-packages.sh et init.el dans le contexte de build
# =============================================================================
COPY install-emacs-packages.sh /tmp/ [cite: 7]
RUN chmod +x /tmp/install-emacs-packages.sh && /tmp/install-emacs-packages.sh [cite: 7]

COPY init.el /home/dev/.emacs.d/init.el [cite: 7]
RUN chown -R dev:dev /home/dev/.emacs.d [cite: 7]

# =============================================================================
# 7. RETOUR UTILISATEUR NOTEBOOK (priorité Gemini → ${NB_UID})
# =============================================================================
USER ${NB_UID} [cite: 7]

# =============================================================================
# 8. PACKAGES PYTHON SUPPLÉMENTAIRES
#
#    Déjà fournis par jupyter/datascience-notebook (on ne les réinstalle PAS) :
#      numpy, scipy, pandas, matplotlib, seaborn, scikit-learn,
#      jupyterlab, plotly, sympy, statsmodels, bokeh, altair 
#
#    Installés ici (absents de l'image de base) : 
# =============================================================================

# Correction du conflit : force une version de NumPy compatible avec l'image de base avant le reste
RUN pip install --no-cache-dir "numpy<2.0"

RUN pip install --no-cache-dir \ 
    # ── Deep Learning ── \
    torch \ [cite: 8]
    torchvision \ [cite: 8]
    torchaudio \ [cite: 8]
    tensorflow \ [cite: 8]
    keras \ [cite: 8]
    # ── Data / Viz complémentaires ── \
    networkx \ [cite: 8]
    graphviz \ [cite: 8]
    pygraphviz \ [cite: 8]
    holoviews \ [cite: 8]
    dask \ [cite: 8]
    pyarrow \ [cite: 8]
    # ── API / serveur ── \
    fastapi \ [cite: 8, 9]
    uvicorn \ [cite: 9]
    # ── Stack Gemini (scraping / cloud / OSINT) ── \
    google-cloud-storage \ [cite: 9]
    shodan \ [cite: 9]
    beautifulsoup4 \ [cite: 9]
    playwright \ [cite: 9]
    tweepy [cite: 9]

# =============================================================================
# 9. PLAYWRIGHT – navigateur headless Chromium (Gemini)
# =============================================================================
RUN playwright install chromium [cite: 9]

# =============================================================================
# 10. PORTS EXPOSÉS
#     8888 = JupyterLab (image de base) [cite: 10]
#     8000 = FastAPI / Uvicorn (Tycho) [cite: 10]
#       22 = SSH (Tycho) [cite: 10]
# =============================================================================
EXPOSE 22 8000 8888 [cite: 10]

# =============================================================================
# 11. DÉMARRAGE
#     Par défaut : JupyterLab (hérité de l'image de base). [cite: 10]
#     Pour lancer SSH + JupyterLab simultanément, utiliser un script d'entrée
#     ou décommenter la ligne ci-dessous (SSH seul). [cite: 10, 11]
# =============================================================================
# CMD ["/usr/sbin/sshd", "-D"] [cite: 11]
