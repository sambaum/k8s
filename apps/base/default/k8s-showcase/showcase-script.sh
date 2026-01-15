echo
echo "=== ENV ==="
env | egrep -v "(KUBERNETES|HOSTNAME|SHLVL|HOME|TERM|PATH|LANG|PWD|LC_ALL)" || true
echo
echo "=== CONFIG FILES ==="
for dir in /etc/showcase/*; do
	[ -d "$dir" ] || continue
	echo "# $dir"
	for file in "$dir"/*; do
		[ -f "$file" ] || continue
		echo "--- $file ---"
		cat "$file"
		echo
	done
done

sleep 3600
