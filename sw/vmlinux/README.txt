File in this directory:
initrd                      A disk image needed if you want to build the 
                            Amber Linux kernel from sources
patch-2.4.27-amber2.bz2     Amber Linux patch file
patch-2.4.27-vrs1.bz2       ARM Linux patch file
README.txt                  This file
vmlinux.dis                 Kernel disassembly file
vmlinux.mem                 Kernel .mem file for Verilog simulations
                            If you build the kernal from source these 2 files
                            get replaced.


# +++++++++++++++++++++++++++++++++++++++++++
# How to build Amber Linux kernel from source
# +++++++++++++++++++++++++++++++++++++++++++
# If you also want to create your own initrd disk image, 
# then follow that procedure (below) first.

# Set the location on your system where the Amber project is located
export AMBER_BASE=/proj/opencores-svn/trunk

# Pick a directory on your system where you want to build Linux
export LINUX_WORK_DIR=/proj/amber2-linux

export AMBER_CROSSTOOL=arm-none-linux-gnueabi


# Create the Linux build directory
test -e ${LINUX_WORK_DIR} || mkdir ${LINUX_WORK_DIR}
cd ${LINUX_WORK_DIR}

# Download the kernel source
wget http://www.kernel.org/pub/linux/kernel/v2.4/linux-2.4.27.tar.gz
tar zxf linux-2.4.27.tar.gz
ln -s linux-2.4.27 linux
cd linux

#Apply 2 patch files
cp ${AMBER_BASE}/sw/vmlinux/patch-2.4.27-vrs1.bz2 .
cp ${AMBER_BASE}/sw/vmlinux/patch-2.4.27-amber2.bz2 .
bzip2 -d patch-2.4.27-vrs1.bz2
bzip2 -d patch-2.4.27-amber2.bz2
patch -p1 < patch-2.4.27-vrs1
patch -p1 < patch-2.4.27-amber2

# Build the kernel and create a .mem file for simulations
make dep
make vmlinux

cp vmlinux vmlinux_unstripped
${AMBER_CROSSTOOL}-objcopy -R .comment -R .note vmlinux
${AMBER_CROSSTOOL}-objcopy --change-addresses -0x02000000 vmlinux
$AMBER_BASE/sw/tools/amber-elfsplitter vmlinux > vmlinux.mem
# Add the ram disk image to the .mem file
$AMBER_BASE/sw/tools/amber-bin2mem ${AMBER_BASE}/sw/vmlinux/initrd 800000 >> vmlinux.mem
${AMBER_CROSSTOOL}-objdump -C -S -EL vmlinux_unstripped > vmlinux.dis 
cp vmlinux.mem $AMBER_BASE/sw/vmlinux/vmlinux.mem
cp vmlinux.dis $AMBER_BASE/sw/vmlinux/vmlinux.dis

# Run the Linux simulation to verify that you have a good kernel image
cd $AMBER_BASE/hw/sim
run vmlinux


# +++++++++++++++++++++++++++++++++++++++++++
# How to create your own initrd file
# +++++++++++++++++++++++++++++++++++++++++++
This file is the disk image that Linux mounts as
part of the boot process. It contains a bare bones Linux directory
structure and an init file (which is just hello-world renamed).

# Set the location on your system where the Amber project is located
export AMBER_BASE=/proj/opencores-svn/trunk

# Pick a directory on your system where you want to build Linux
export LINUX_WORK_DIR=/proj/amber2-linux


cd ${LINUX_WORK_DIR}
# Need root permissions to mount disks
su root
dd if=/dev/zero of=initrd bs=200k count=1
mke2fs -F -m0 -b 1024 initrd

mkdir mnt
mount -t ext2 -o loop initrd ${LINUX_WORK_DIR}/mnt

# Add files 
mkdir ${LINUX_WORK_DIR}/mnt/sbin
mkdir ${LINUX_WORK_DIR}/mnt/dev
mkdir ${LINUX_WORK_DIR}/mnt/bin
mkdir ${LINUX_WORK_DIR}/mnt/etc
mkdir ${LINUX_WORK_DIR}/mnt/proc
mkdir ${LINUX_WORK_DIR}/mnt/lib

mknod ${LINUX_WORK_DIR}/mnt/dev/console c 5 1
mknod ${LINUX_WORK_DIR}/mnt/dev/tty2 c 4 2
mknod ${LINUX_WORK_DIR}/mnt/dev/null c 1 3
mknod ${LINUX_WORK_DIR}/mnt/dev/loop0 b 7 0
chmod 600 ${LINUX_WORK_DIR}/mnt/dev/*

cp $AMBER_BASE/sw/hello-world/hello-world.elf ${LINUX_WORK_DIR}/mnt/sbin/init
chmod +x ${LINUX_WORK_DIR}/mnt/sbin/init

# Check
df ${LINUX_WORK_DIR}/mnt

# Unmount
umount ${LINUX_WORK_DIR}/mnt
exit

cp initrd $AMBER_BASE/sw/vmlinux
