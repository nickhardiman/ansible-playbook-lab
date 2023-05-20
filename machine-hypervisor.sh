# run
# log into hypervisor
# download and run this script
#   curl -o - https://raw.githubusercontent.com/nickhardiman/homelab/main/machine-hypervisor-configure.sh | bash -x

# SSH security
# if SSH service on this box is accessible to the Internet
# use key pairs only, disable password login
# for more information, see
#   man sshd_config
#echo "AuthenticationMethods publickey" >> /etc/ssh/sshd_config
 
# install Ansible
sudo dnf install --assumeyes ansible-core
# install Ansible libvirt collection
sudo ansible-galaxy collection install community.libvirt --collections-path /usr/share/ansible/collections

# !!! move this to machine-hypervisor-configure.yml
# install git
sudo dnf install --assumeyes git
git config --global user.name         "Nick Hardiman"
git config --global user.email        nick@email-domain.com
git config --global github.user       nick
git config --global push.default      simple
# default timeout is 900 seconds (https://git-scm.com/docs/git-credential-cache)
git config --global credential.helper 'cache --timeout=1200'
git config --global pull.rebase false

# Add an Ansible user account.
# create a new keypair 
ssh-keygen -f ./ansible-key -q -N ""
mv ansible-key  ansible-key.priv
# Create the ansible_user account (not using --system). 
useradd ansible_user
# Copy the keys to ansible_user's SSH config directory. 
mkdir /home/ansible_user/.ssh
chmod 0700 /home/ansible_user/.ssh
cp ansible-key.priv  /home/ansible_user/.ssh/id_rsa
chmod 0600 /home/ansible_user/.ssh/id_rsa
cp ansible-key.pub  /home/ansible_user/.ssh/id_rsa.pub
# enable SSH to localhost with key-based login
cat ansible-key.pub >> /home/ansible_user/.ssh/authorized_keys
chmod 0600 /home/ansible_user/.ssh/authorized_keys
chown -R ansible_user:ansible_user /home/ansible_user/.ssh
# Allow passwordless sudo.
echo 'ansible_user      ALL=(ALL)       NOPASSWD: ALL' > /etc/sudoers.d/ansible_user 
# Copy the keys to your SSH config directory. 
cp ansible-key.priv  /home/nick/.ssh/
cp ansible-key.pub  /home/nick/.ssh/
# Add the location to ansible.cfg. 
private_key_file = /home/nick/.ssh/ansible-key.priv
# Check your work. 
ssh -i /home/nick/.ssh/ansible-key.priv ansible_user@localhost  id


# enable nested virtualization? 
# /etc/modprobe.d/kvm.conf 
# options kvm_amd nested=1

# install my libvirt host role
# I'm not using ansible-galaxy because I am actively developing this role.
# Check out the directive in ansible.cfg in some playbooks.
mkdir -p ~/ansible/collections
cd ~/ansible/collections
# If the repo has already been cloned, git exits with this error message. 
#   fatal: destination path 'libvirt-host' already exists and is not an empty directory.
# !!! not uploaded
git clone https://github.com/nickhardiman/ansible-collection-platform.git
# turn the host into a hypervisor
cd ansible-collection-platform
ansible-playbook --ask-become-pass machine-hypervisor.yml

