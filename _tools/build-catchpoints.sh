#!/bin/sh
# Regenerates c/<slug>/index.html redirect pages from _catchpoints.txt.
# Usage (from anywhere):  sh _tools/build-catchpoints.sh
# The whole c/ directory is rebuilt, so removing a line removes its page.
set -euf   # -f: no globbing when splitting lines

root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/_catchpoints.txt"
out="$root/c"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() { echo "catchpoints: line $n: $*" >&2; exit 1; }

# Escape for an HTML attribute / text node.
esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/"/\&quot;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

n=0
count=0
while IFS= read -r line || [ -n "$line" ]; do
  n=$((n + 1))
  # Strip comments: '#' at line start or after whitespace (keeps URL #fragments).
  line=$(printf '%s\n' "$line" | sed -e 's/^[[:space:]]*#.*//' -e 's/[[:space:]]#.*//')
  set -- $line                          # split on whitespace
  [ $# -eq 0 ] && continue
  [ $# -eq 2 ] || fail "expected '<slug> <destination>', got: $line"
  slug=$1 dest=$2

  case $slug in *[!a-z0-9-]*|-*|'') fail "bad slug '$slug' (use a-z, 0-9, -)";; esac
  case $dest in
    https://*|http://*) ;;
    /*) case $dest in //*) fail "destination '$dest' must be a URL or a /path";; esac ;;
    *) fail "destination '$dest' must start with https:// or /";;
  esac
  case $dest in *[\"\'\<\>\\]*) fail "destination contains quotes, <, > or \\";; esac
  [ -e "$tmp/$slug" ] && fail "duplicate slug '$slug'"

  d=$(esc "$dest")
  mkdir -p "$tmp/$slug"
  cat > "$tmp/$slug/index.html" <<EOF
<!DOCTYPE html>
<!-- Generated from _catchpoints.txt by _tools/build-catchpoints.sh. Do not edit. -->
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<meta http-equiv="refresh" content="0; url=$d">
<link rel="canonical" href="$d">
<title>Redirecting…</title>
<style>
  body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: #f7f6f2; color: #1b1d22; font: 16px/1.6 system-ui, -apple-system, Segoe UI, Roboto, sans-serif; }
  a { color: #5865f2; }
  @media (prefers-color-scheme: dark) { body { background: #121317; color: #ecedf0; } a { color: #7c86ff; } }
</style>
</head>
<body>
<p>Redirecting to <a id="dest" href="$d">$d</a>…</p>
<script>location.replace(document.getElementById("dest").href);</script>
</body>
</html>
EOF
  count=$((count + 1))
done < "$src"

rm -rf "$out"
mv "$tmp" "$out"
trap - EXIT
echo "catchpoints: wrote $count page(s) to c/"
