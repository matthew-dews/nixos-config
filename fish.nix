# https://github.com/dj95/nix-dotfiles/blob/b6082882db1be942737216eadcc6b9c363845fc7/home-manager/modules/fish.nix
{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true; # Not strictly necessary since it is enabled at the system level
    # Add any Fish-specific configurations here
    shellAliases = {
    };
    shellInit = ''
      # Add any Fish shell initialization commands here
    '';
    loginShellInit = ''
      # Add any login shell initialization commands here
    '';
    interactiveShellInit = ''
      # Add any interactive shell initialization commands here
    '';
    plugins = [
      # Add any Fish plugins here
      # Example: { name = "z"; src = pkgs.fishPlugins.z.src; }
    ];
  };
}