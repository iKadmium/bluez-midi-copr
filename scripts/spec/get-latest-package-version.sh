fedora_version="$1"
package="${2:-bluez}"
release_ver="${fedora_version#fedora-}"

# Use dnf to query the package version, sort by version and get the latest
current_ver=$(dnf --releasever="$release_ver" --quiet repoquery "$package" --queryformat='%{version}-%{release}\n' 2>/dev/null | sort -V | tail -1 | sed 's/\.fc[0-9]*$//')
if [ -n "$current_ver" ]; then
    echo "$current_ver"
    exit 0
else
    echo "Failed to query $package version for Fedora $release_ver" >&2
    exit 1
fi