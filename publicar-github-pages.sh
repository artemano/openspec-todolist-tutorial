#!/usr/bin/env bash
# ============================================================================
# publicar-github-pages.sh
# Publica el tutorial (HTML + videos) como sitio en GitHub Pages,
# ejecutándolo desde la carpeta que contiene tutorial-openspec-todolist.html.
#
# Uso:
#   bash publicar-github-pages.sh                     # con GitHub CLI (gh)
#   bash publicar-github-pages.sh <url-repo-github>   # sin gh, repo ya creado
#
# Requiere: git. Recomendado: GitHub CLI (gh) autenticado (gh auth login).
# Windows:  ejecutar en Git Bash o WSL.
# ============================================================================
set -euo pipefail

TUTORIAL="tutorial-openspec-todolist.html"
REPO_NOMBRE="${REPO_NOMBRE:-openspec-todolist-tutorial}"
RAMA="main"
REMOTO_ARG="${1:-}"

# ---------- Verificaciones ----------
command -v git >/dev/null 2>&1 || { echo "ERROR: git no está instalado"; exit 1; }
[ -f "$TUTORIAL" ] || { echo "ERROR: no encuentro $TUTORIAL en este directorio. Ejecuta el script desde la carpeta del tutorial."; exit 1; }

# ---------- Preparar el sitio ----------
echo "==> Preparando archivos del sitio"

# GitHub Pages sirve index.html en la raíz: creamos una copia.
cp -f "$TUTORIAL" index.html

# Evita que GitHub procese el sitio con Jekyll (más rápido y sin sorpresas).
touch .nojekyll

# Carpeta de videos (aunque aún no estén grabados, deja la estructura lista).
mkdir -p assets
[ -f assets/.gitkeep ] || touch assets/.gitkeep

# Advertencia: todo lo que esté aquí será público.
if [ -f guion-videos.md ]; then
  echo ""
  echo "  AVISO: 'guion-videos.md' (documento de producción) está en la carpeta"
  echo "  y quedará público en el repo. Si no lo quieres publicar, muévelo fuera"
  echo "  y vuelve a ejecutar el script."
  echo ""
fi

# ---------- Git ----------
if [ ! -d .git ]; then
  echo "==> Inicializando repositorio git"
  git init -q -b "$RAMA"
fi

git add -A
if git diff --cached --quiet; then
  echo "==> Sin cambios nuevos que commitear"
else
  git commit -q -m "Tutorial OpenSpec TodoList: publicación en GitHub Pages"
  echo "==> Commit creado"
fi

# ---------- Publicación ----------
publicado=""

if [ -n "$REMOTO_ARG" ]; then
  # Modo manual: URL de repo ya creado en GitHub.
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "$REMOTO_ARG"
  echo "==> Haciendo push a $REMOTO_ARG"
  git push -u origin "$RAMA"
  publicado="manual"

elif command -v gh >/dev/null 2>&1; then
  # Modo automático con GitHub CLI.
  gh auth status >/dev/null 2>&1 || { echo "ERROR: GitHub CLI no está autenticado. Ejecuta: gh auth login"; exit 1; }

  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "==> Creando repo '$REPO_NOMBRE' en GitHub y haciendo push"
    gh repo create "$REPO_NOMBRE" --public --source . --remote origin --push
  else
    echo "==> Haciendo push al remoto existente"
    git push -u origin "$RAMA"
  fi

  OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

  echo "==> Activando GitHub Pages (rama $RAMA, raíz /)"
  # POST crea la configuración; si ya existe (409), PUT la actualiza.
  gh api -X POST "repos/$OWNER_REPO/pages" \
    -f "source[branch]=$RAMA" -f "source[path]=/" >/dev/null 2>&1 \
  || gh api -X PUT "repos/$OWNER_REPO/pages" \
    -f "source[branch]=$RAMA" -f "source[path]=/" >/dev/null 2>&1 \
  || true

  URL=$(gh api "repos/$OWNER_REPO/pages" -q .html_url 2>/dev/null || echo "")
  publicado="gh"

else
  echo ""
  echo "  GitHub CLI (gh) no está instalado y no pasaste una URL de repo."
  echo "  Opciones:"
  echo "   a) Instala gh (https://cli.github.com), ejecuta 'gh auth login'"
  echo "      y vuelve a correr este script."
  echo "   b) Crea un repo vacío en github.com y ejecuta:"
  echo "      bash publicar-github-pages.sh https://github.com/<usuario>/<repo>.git"
  exit 1
fi

# ---------- Resumen ----------
echo ""
echo "============================================================"
if [ "$publicado" = "gh" ]; then
  echo "  Publicado. El sitio estará disponible en 1-2 minutos en:"
  echo ""
  echo "     ${URL:-https://<tu-usuario>.github.io/$REPO_NOMBRE/}"
else
  echo "  Push completado. Falta un paso manual (solo la primera vez):"
  echo ""
  echo "   1. En GitHub: Settings → Pages"
  echo "   2. Source: 'Deploy from a branch', Branch: $RAMA, carpeta: / (root)"
  echo "   3. Guardar. El sitio queda en https://<usuario>.github.io/<repo>/"
fi
echo ""
echo "  Para actualizar (nuevos videos en assets/, cambios al HTML):"
echo "  vuelve a ejecutar este script — commit + push + listo."
echo "============================================================"