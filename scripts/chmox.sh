find . -type f -name "*.sh" \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./result/*" \
  -exec chmod +x {}

find . -type f -name "*.sh" \
  -not -path "./.git/*" \
  -not -path "./result/*" \
  -printf "%M  %p\n"
