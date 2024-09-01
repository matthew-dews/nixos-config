# Applying changes to /etc/nixos/configuration.nix
Run `sudo nixos-rebuild switch` to apply modifications.

# Initial setup

Adapted from https://nixos-and-flakes.thiscute.world/nixos-with-flakes/other-useful-tips#managing-the-configuration-with-git


From scratch this is setup with the following
```
sudo mv /etc/nixos /etc/nixos.bak # Create a backup
sudo ln -s ~/nixos-config/ /etc/nixos

# Copy existing files over, they will inherit user permissions
cp /etc/nixos.bak/* ~/nixos-config
sudo nixos-rebuild switch

cd ~/nixos-config
git init
git add *
git commit -m "Initial commit"
```

Adjust these steps when starting from this repo instead.

