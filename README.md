# Proxmox Unattended Installation

This project provides an automated installation assistant for Proxmox, allowing users to create a customized ISO image for unattended installations. By using a configuration file (`answer.toml`), users can specify installation parameters and scripts to run at first boot. It also includes a webhook receiver to receive post installation notifications, making it easier to manage and deploy Proxmox on multiple machines.

> [!CAUTION]
> You need to have Docker installed. Please ensure Docker is set up before proceeding.

First, you need to clone this repository.
```
git clone https://github.com/abelgarcia2/proxmox-auto-install-assistant.git
```
Then, you should customize your `answer.toml` file. First, copy the provided template.
```
cp answer.toml.example answer.toml
```
Now, edit it with your favorite text editor (nano, vim, vscode...)

When you are ready, simply execute the `insert-answer-file.sh` script. You can add `-f` parameter to point to an existing ISO image (if not,  the script downloads the latest ISO image itself)
```
./insert-answer-file.sh -f proxmox-iso
```

If you want to add a script to run at the first boot, you can use the `-s` parameter.
```
./insert-answer-file.sh -s first-run.sh
```

After that, new ISO image will be created. Now you can burn it to a USB drive to install Proxmox on any computer using, for example, the following command.
```
# dd bs=1M conv=fdatasync if=./proxmox-ve_*.iso of=/dev/XYZ

```

## Webhook Receiver
If you set the `post-installation-webhook` option in the `answer.toml` file you can use `webhook-receiver.py` script to receive it.
This script runs a simple web server whose only job is to print the data it receives via the POST method. The usage is very similar to [python http.server module](https://docs.python.org/3/library/http.server.html#command-line-interface)
```
python3 webhook-receiver.py
```
