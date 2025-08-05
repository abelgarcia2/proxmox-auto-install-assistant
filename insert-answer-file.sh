#!/bin/bash

docker_image_name="proxmox-auto-install-assistant"
iso_filename=""
answer_filename="answer.toml"
first_boot_script_filename=""

help() {
    echo "Usage: $0 [options]"
    echo
    echo "Description:"
    echo "  This script adds an answer.toml response file to a Proxmox VE ISO,"
    echo "  which can be specified as an option. If no ISO file is specified,"
    echo "  it will be downloaded from the Proxmox website"
    echo
    echo "Options:"
    echo "  -f    Proxmox VE ISO file"
    echo "  -h    Shows that message and exit"
    echo "  -s    First boot script"
}

get_current_proxmox_version() {
    curl -s https://proxmox.com/en/downloads \
        |grep -oE "Proxmox VE ([0-9]+\.[0-9]+) .* Installer" \
        | grep -oE "[0-9]+.[0-9]+"
}

download_iso() {
    if ! command -v curl &> /dev/null; then
        echo -e "\033[1;31m[!] curl is not installed. Please install curl to download the ISO\033[0m"
        exit 1
    fi

    proxmox_version=$(get_current_proxmox_version)
    iso_filename="proxmox-ve_$proxmox_version-1.iso"

    curl -sO "https://enterprise.proxmox.com/iso/SHA256SUMS"
    curl -O "https://enterprise.proxmox.com/iso/$iso_filename"
}

verify_iso() {
    if ! command -v sha256sum &> /dev/null; then
        echo -e "\033[1;33m[!] sha256sum is not installed. Skipping ISO verification...\033[0m"
        return
    fi

    sha256sum -c SHA256SUMS --ignore-missing --quiet

    if [ $? -eq 1 ]; then
        rm SHA256SUMS
        exit 1
    fi

    rm SHA256SUMS
}


while getopts "hf:s:" opt; do
    case $opt in
        h) help; exit ;;
        f) iso_filename=${OPTARG} ;;
        s) first_boot_script_filename=${OPTARG} ;;
        *) help; exit ;;
    esac
done

# if [[ "$1" == "--help" || "$1" == "-h" ]]; then
#     help
#     exit
# fi

if ! command -v docker &> /dev/null; then
    echo -e "\033[1;31m[!] docker is not installed. Please install docker\033[0m"
    exit 1
fi

if [ ! -e $answer_filename ]; then
    echo -e "\033[1;31m[!] $answer_filename file not found. You forget run cp answer.toml.example answer.toml?\033[0m"
    exit 1
fi

if [ ! -e "$iso_filename" ]; then
    echo -e "\033[32m[!] Looks like you still don’t have the ISO image, let’s downloading it...\033[0m"
    download_iso
    verify_iso
fi

if ! docker image inspect  "$docker_image_name" &> /dev/null; then
    echo -e "\033[32m[!] Looks like you still don’t have the Docker image, let’s build it...\033[0m"
    docker build . -t "$docker_image_name"
    echo
fi

echo -e "\033[32m[!] Now we're going to include the answer file in the iso image...\033[0m"
if [ -n "$first_boot_script_filename" ]; then
    docker run --rm -it -v .:/root/proxmox-auto-install "$docker_image_name" \
        prepare-iso "$iso_filename" --fetch-from iso \
        --answer-file "$answer_filename" --on-first-boot "$first_boot_script_filename"
else
    docker run --rm -it -v .:/root/proxmox-auto-install "$docker_image_name" \
        prepare-iso "$iso_filename" --fetch-from iso \
        --answer-file "$answer_filename"
fi
