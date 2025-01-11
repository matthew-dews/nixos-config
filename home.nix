{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./browsers.nix
    ./fish.nix
    ./vscode.nix
  ];

  home.username = "corinne";
  home.homeDirectory = "/home/corinne";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  # Packages can be found via 'nix search nixpkgs search_term'
  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip
    zstd

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor

    # misc
    cowsay
    signal-desktop
    tree
    which

    # productivity
    inputs.llmify.packages.${pkgs.system}.default
    obsidian

    # development related
    bun
    code-cursor
    gh
    nixfmt-rfc-style
    nodejs_20
    poetry
    inputs.pyinit.packages.${pkgs.system}.default

    # system tools
    ethtool
    lm_sensors # for `sensors` command
    lsof # list open files
    # it provides the command `nom` works just like `nix`
    # with more detailed log output
    nix-output-monitor
    pciutils # lspci
    sysstat
    usbutils # lsusb
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Corinne";
    userEmail = "corinnecorinfinite@gmail.com";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    #bashrcExtra = ''
    #  export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    #'';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      #k = "kubectl";
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
