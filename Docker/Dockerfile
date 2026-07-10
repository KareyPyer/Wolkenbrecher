FROM quay.io/jupyter/datascience-notebook:latest

LABEL maintainer="Doktor Nand"

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        unzip \
        jq \
        tree \
        vim \
        nano \
        tmux \
        htop \
        graphviz \
        libgraphviz-dev \
        pkg-config \
        libxml2-dev \
        libxslt1-dev \
        libffi-dev \
        libssl-dev \
        libjpeg-dev \
        zlib1g-dev \
        chromium \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Installation Conda
USER ${NB_UID}

RUN mamba install -y -c conda-forge \
    altair \
    bokeh \
    holoviews \
    hvplot \
    panel \
    plotly \
    pyarrow \
    polars \
    dask \
    distributed \
    networkx \
    python-igraph \
    graphviz \
    pygraphviz \
    geopandas \
    folium \
    osmnx \
    beautifulsoup4 \
    lxml \
    scrapy \
    nltk \
    spacy \
    gensim \
    textblob \
    transformers \
    datasets \
    sentence-transformers \
    huggingface_hub \
    faiss-cpu \
    duckdb \
    statsmodels \
    xgboost \
    lightgbm \
    shap \
    umap-learn \
    hdbscan \
    && \
    mamba clean --all -f -y

## pip
RUN pip install --no-cache-dir \
    playwright \
    shodan \
    python-whois \
    dnspython \
    tweepy \
    trafilatura \
    newspaper4k \
    yake \
    keybert \
    yake-github

## spaCy
RUN python -m spacy download en_core_web_sm && \
    python -m spacy download fr_core_news_sm

## Playwright
RUN playwright install chromium

## Extensions Jupyter
RUN pip install --no-cache-dir \
    jupyterlab-git \
    jupyterlab-lsp \
    python-lsp-server

# 100726
