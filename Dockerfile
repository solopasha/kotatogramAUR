FROM archlinux:base-devel

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm reflector && \
    reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -S --noconfirm git sudo && \
    sed \
        -e '/MAKEFLAGS=/s/^#//g' \
        -e '/MAKEFLAGS/s/-j2/-j$(($(nproc)+1))/g' \
        -e '/^OPTIONS/s/!lto/lto/g' \
        -i /etc/makepkg.conf && \
    useradd -m builduser && \
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build && \
    cd /home/builduser && \
    su -c 'git clone https://aur.archlinux.org/yay-bin.git' builduser && \
    cd yay-bin && \
    su -c 'makepkg -sri --noconfirm' builduser && \
    cd .. && rm -rf yay

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
