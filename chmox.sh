find . -type f -name "*.sh" \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./result/*" \
  -exec chmod +x {} \;