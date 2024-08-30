#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
print_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Change timezone to India
print_message "Changing timezone to India (Asia/Kolkata)"
timedatectl set-timezone Asia/Kolkata

# Install EPEL repository and Nginx
print_message "Installing Nginx"
dnf install -y nginx

# Start and enable Nginx
print_message "Starting and enabling Nginx"
systemctl start nginx
systemctl enable nginx

# Configure SSH
print_message "Configuring SSH"
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH service
print_message "Restarting SSH service"
systemctl restart sshd

# Enable color prompt in .bashrc
print_message "Enabling color prompt in .bashrc"
cat << 'EOF' >> /root/.bashrc

# Enable color prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Enable color support for ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
EOF

# Ensure .ssh directory exists
print_message "Creating .ssh directory"
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add SSH public keys to authorized_keys
print_message "Adding SSH public keys to authorized_keys"
cat << 'EOF' >> /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOHDV/GXK5SNvVj954rQmYx4f5oicCXWdo0aw1ElkYsR rchoudhury63@gmail.com
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpDBlyev/RfBkOe/AuuX9rW6xW+cgFQq6F/Bp4UaCYl debatashaktiranjan@gmail.com
EOF

# Ensure correct permissions on authorized_keys
chmod 600 /root/.ssh/authorized_keys

print_message "Setup completed successfully"
