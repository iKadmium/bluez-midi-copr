PROJECT="$1"
PACKAGE="${2}"
TARGET_FEDORA="$3"
ARCHITECTURES="${4:-x86_64 aarch64}"

if [ -z "$PROJECT" ] || [ -z "$TARGET_FEDORA" ]; then
    echo "Usage: $0 <project> <package> <target-fedora> [architectures]"
    echo "Example: $0 kadmium/bluez-midi bluez fedora-42 'x86_64 aarch64'"
    exit 1
fi

# Build chroot arguments for copr build
CHROOT_ARGS=""
for arch in $ARCHITECTURES; do
    CHROOT_ARGS="$CHROOT_ARGS --chroot $TARGET_FEDORA-$arch"
done

echo "Building for project: $PROJECT"
echo "Target Fedora: $TARGET_FEDORA"
echo "Package: $PACKAGE"
echo "Architectures: $ARCHITECTURES"
echo "Chroot arguments: $CHROOT_ARGS"

copr-cli build --nowait "$PROJECT" "spec/$TARGET_FEDORA/$PACKAGE.spec" $CHROOT_ARGS