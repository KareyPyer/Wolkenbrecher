# =============================================================================
# Dockerfile fusionné : Gemini (prioritaire) + Tycho
# Base : jupyter/datascience-notebook (déjà équipé de Python, R, JupyterLab,
#        conda, et de nombreux packages data-science)
# =============================================================================
FROM jupyter/datascience-notebook:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

# =============================================================================
# 1. LOCALES
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# =============================================================================
# 2. DÉPENDANCES SYSTÈME (Tycho + Gemini)
#    Sont exclus les paquets déjà présents dans l'image de base :
#      python3, python3-pip, python3-venv, r-base, r-base-dev, curl, git, …
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    unzip \
    gnupg \
    software-properties-common \
    ca-certificates \
    python3-dev \
    libopenblas-dev \
    liblapack-dev \
    # --- Outils DB / réseau ---
    sqlite3 \
    postgresql-client \
    redis-tools \
    # --- Java (requis par Clojure) ---
    default-jdk \
    # --- Graphviz (binaire + headers pour pygraphviz) ---
    graphviz \
    libgraphviz-dev \
    pkg-config \
    # --- Éditeur / divers ---
    emacs-nox \
    rlwrap \
    # --- SSH ---
    openssh-server \
    sudo \
    # --- Lisp ---
    sbcl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# =============================================================================
# 3. LANGAGES SUPPLÉMENTAIRES (Tycho)
# =============================================================================

# --- Julia 1.9.3 -----------------------------------------------------------
RUN wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.3-linux-x86_64.tar.gz && \
    tar -xzf julia-*.tar.gz -C /opt && \
    ln -s /opt/julia-*/bin/julia /usr/local/bin/julia && \
    rm -f julia-*.tar.gz

# --- Clozure Common Lisp ----------------------------------------------------
RUN curl -sL -o ccl.tar.gz \
        https://github.com/Clozure/ccl/releases/download/v1.12/ccl-1.12-linuxx86.tar.gz && \
    tar -xzf ccl.tar.gz -C /opt && rm -f ccl.tar.gz && \
    ln -s /opt/ccl/lx86cl64 /usr/local/bin/ccl

# --- Clojure ----------------------------------------------------------------
RUN curl -sLO https://download.clojure.org/install/linux-install-1.11.1.1413.sh && \
    chmod +x linux-install-1.11.1.1413.sh && \
    ./linux-install-1.11.1.1413.sh && \
    rm -f linux-install-1.11.1.1413.sh

# =============================================================================
# 4. CONFIGURATION SSH (Tycho)
# =============================================================================
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# =============================================================================
# 5. UTILISATEUR "dev" (Tycho – accès SSH / sudo)
# =============================================================================
RUN useradd -ms /bin/bash dev && \
    echo "dev:dev" | chpasswd && \
    adduser dev sudo

# =============================================================================
# 6. EMACS – plugins data-science (Tycho)
#    ⚠️  Requiert install-emacs-packages.sh et init.el dans le contexte de build
# =============================================================================
COPY install-emacs-packages.sh /tmp/
RUN chmod +x /tmp/install-emacs-packages.sh && /tmp/install-emacs-packages.sh

COPY init.el /home/dev/.emacs.d/init.el
RUN chown -R dev:dev /home/dev/.emacs.d

# =============================================================================
# 7. RETOUR UTILISATEUR NOTEBOOK (priorité Gemini → ${NB_UID})
# =============================================================================
USER ${NB_UID}

# =============================================================================
# 8. PACKAGES PYTHON SUPPLÉMENTAIRES
#
#    Déjà fournis par jupyter/datascience-notebook (on ne les réinstalle PAS) :
#      numpy, scipy, pandas, matplotlib, seaborn, scikit-learn,
#      jupyterlab, plotly, sympy, statsmodels, bokeh, altair
#
#    Installés ici (absents de l'image de base) :
# =============================================================================
RUN pip install --no-cache-dir \
    # ── Deep Learning ──
    torch \
    torchvision \
    torchaudio \
    tensorflow \
    keras \
    # ── Data / Viz complémentaires ──
    networkx \
    graphviz \
    pygraphviz \
    holoviews \
    dask \
    pyarrow \
    # ── API / serveur ──
    fastapi \
    uvicorn \
    # ── Stack Gemini (scraping / cloud / OSINT) ──
    google-cloud-storage \
    shodan \
    beautifulsoup4 \
    playwright \
    tweepy

# =============================================================================
# 9. PLAYWRIGHT – navigateur headless Chromium (Gemini)
# =============================================================================
RUN playwright install chromium

# =============================================================================
# 10. PORTS EXPOSÉS
#     8888 = JupyterLab (image de base)
#     8000 = FastAPI / Uvicorn (Tycho)
#       22 = SSH (Tycho)
# =============================================================================
EXPOSE 22 8000 8888

# =============================================================================
# 11. DÉMARRAGE
#     Par défaut : JupyterLab (hérité de l'image de base).
#     Pour lancer SSH + JupyterLab simultanément, utiliser un script d'entrée
#     ou décommenter la ligne ci-dessous (SSH seul).
# =============================================================================
# CMD ["/usr/sbin/sshd", "-D"]
