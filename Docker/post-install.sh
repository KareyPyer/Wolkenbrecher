#!/bin/bash
set -e

# ==============================================================================
# Vérification des privilèges root
# ==============================================================================
if [ "$EUID" -ne 0 ]; then
  echo "Ce script nécessite les droits root. Veuillez l'exécuter avec sudo."
  exit 1
fi

echo "=== Mise à jour des dépôts ==="
apt-get update

echo "=== Outils de développement ==="
apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    clang \
    gdb \
    valgrind \
    ripgrep \
    fd-find \
    silversearcher-ag \
    shellcheck \
    universal-ctags \
    sqlite3 \
    redis-tools \
    postgresql-client \
    openssh-client \
    openssh-server \
    rsync \
    parallel \
    graphviz \
    nodejs \
    npm

echo "=== Java ==="
apt-get install -y openjdk-21-jdk

echo "=== Lisp ==="
apt-get install -y sbcl clisp

echo "=== Clojure ==="
curl -L https://download.clojure.org/install/linux-install.sh -o install-clojure.sh
chmod +x install-clojure.sh
./install-clojure.sh
rm install-clojure.sh

echo "=== Emacs ==="
apt-get install -y emacs-nox exuberant-ctags

echo "=== Python (Outils) ==="
# Conformément aux recommandations Debian/Ubuntu (PEP 668), nous utilisons un environnement 
# virtuel pour installer les paquets tiers sans interférer avec le python système.
VENV_PATH="/opt/python-dev-tools"

echo "Création de l'environnement virtuel dans $VENV_PATH..."
python3 -m venv "$VENV_PATH"

echo "Installation des outils Python dans le venv..."
"$VENV_PATH/bin/pip" install --no-cache-dir \
    poetry \
    hatch \
    ruff \
    black \
    isort \
    mypy \
    pyright \
    pytest \
    pytest-cov \
    ipdb

echo "Création des liens symboliques pour rendre les outils accessibles globalement..."
for bin_file in "$VENV_PATH/bin"/*; do
    bin_name=$(basename "$bin_file")
    
    # On exclut les binaires internes du venv (python, pip, activate, etc.) 
    # pour ne pas écraser ceux du système.
    case "$bin_name" in
        python*|pip*|activate*|Activate*|wheel)
            continue
            ;;
        *)
            ln -sf "$bin_file" "/usr/local/bin/$bin_name"
            ;;
    esac
done

echo "=== GitHub CLI ==="
# Installation de wget si absent
if ! type -p wget >/dev/null; then
    apt-get install -y wget
fi

mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli.gpg >/dev/null
chmod go+r /etc/apt/keyrings/githubcli.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list >/dev/null

# Mise à jour nécessaire pour récupérer les paquets du nouveau dépôt ajouté
apt-get update
apt-get install -y gh

# ==============================================================================
# Nettoyage (Optionnel)
# ==============================================================================
# Utile dans Docker pour alléger l'image, mais généralement inutile sur une machine physique.
# Décommentez les lignes ci-dessous si vous générez une image système minimale.
# apt-get clean
# rm -rf /var/lib/apt/lists/*

echo "=== Installation terminée avec succès ==="
