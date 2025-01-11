# Applying changes
Run `sudo nixos-rebuild switch` to apply modifications.

Because this setup uses Home Manager as a NixOS module this will also rebuild the Home Manager setup.

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

# Updating nix
`nix flake update`
or
`sudo nixos-rebuild switch --upgrade`

TODO: what is the difference?

TODO: what about when I want to update the NixOS version? e.g. from 24.05 to 24.11?

# Applying changes
```
# Optional, can be used to check for errors without applying changes
nix flake check

sudo nixos-rebuild switch
```

# Available Settings

Home Manager (generaly user specific) settings: https://nix-community.github.io/home-manager/options.xhtml

# Notes
- nix will ignore files not tracked by git. Ensure any new `*.nix` files are added.

# Resources
This repo was mostly put together thanks to https://nixos-and-flakes.thiscute.world/