#!/bin/sh
set -e

PLAYLISTS="
  https://www.init7.net/assets/downloads/playlist/srg-fhd-mc.m3u
  https://api.init7.net/tvchannels.m3u
"
OUTPUT_FILE="/usr/share/nginx/html/playlist.m3u"

echo "$(date): fetching playlists..."
TMPFILE=$(mktemp)
echo "#EXTM3U" >"$TMPFILE"
for url in $PLAYLISTS; do
  [ -z "$url" ] && continue
  echo "  <- $url"
  wget -q -O - "$url" | grep -v "^#EXTM3U" >>"$TMPFILE" || echo "  warning: failed to fetch $url" >&2
done
mv "$TMPFILE" "$OUTPUT_FILE"
chmod 644 "$OUTPUT_FILE"
echo "$(date): merged $(grep -c '^#EXTINF' "$OUTPUT_FILE" 2>/dev/null || echo 0) channels"
