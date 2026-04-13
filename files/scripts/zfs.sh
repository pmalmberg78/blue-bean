# Remove legacy zfs-fuse if present
if rpm -q --quiet zfs-fuse; then
  rpm -e --nodeps zfs-fuse || true
fi

# Install zfs-release RPM (expand distro macro at runtime)
ZFS\_RELEASE\_URL="https://zfsonlinux.org/fedora/zfs-release-3-0\$(rpm --eval '%{dist}').noarch.rpm"
curl -fsSL -o /tmp/zfs-release.rpm "\$ZFS\_RELEASE\_URL"
rpm -Uvh /tmp/zfs-release.rpm

# Enable repo metadata refresh and install zfs packages.
# Note: use exact kmod name if you have a kmod built for the OSTree kernel ABI.
dnf -y --setopt=install\_weak\_deps=False install zfs zfs-dracut || {
  echo "dnf install failed; ensure kmod-zfs matching kernel ABI is available in repos"; exit 1
}

# If kmod RPMs for the OSTree kernel are available they will install .ko files into /lib/modules.
# Attempt to rebuild DKMS modules if dkms and kernel-devel are available (best-effort).
if command -v dkms >/dev/null 2>&1; then
  if dnf -y list installed kernel-devel >/dev/null 2>&1; then
    dkms autoinstall || true
  fi
fi

# Regenerate initramfs so ZFS is included in the image (if dracut is available in build env)
if command -v dracut >/dev/null 2>&1; then
  dracut --force
fi

# Try to load module in build environment (non-fatal)
if command -v modprobe >/dev/null 2>&1; then
  modprobe zfs || true
fi
