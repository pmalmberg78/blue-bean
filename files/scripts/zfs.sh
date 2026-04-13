# Remove legacy zfs-fuse if present
if rpm -q --quiet zfs-fuse; then
  rpm -e --nodeps zfs-fuse || true
fi

# Install zfs-release RPM (expand distro macro at runtime)
dnf install -y https://zfsonlinux.org/fedora/zfs-release-3-0$(rpm --eval "%{dist}").noarch.rpm

dnf install -y zfs

# Try to load module in build environment (non-fatal)
if command -v modprobe >/dev/null 2>&1; then
  modprobe zfs || true
fi
