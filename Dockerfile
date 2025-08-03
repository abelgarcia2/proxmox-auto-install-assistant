FROM debian:bookworm

RUN apt-get update && apt-get install -y wget

# Add Proxmox repositories
RUN echo deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription > /etc/apt/sources.list.d/pve-no-subscription.list
RUN wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg

RUN apt-get update && apt-get install -y proxmox-auto-install-assistant xorriso

RUN mkdir /root/proxmox-auto-install
WORKDIR /root/proxmox-auto-install
VOLUME /root/proxmox-auto-install

ENTRYPOINT ["proxmox-auto-install-assistant"]
