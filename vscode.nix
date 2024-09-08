{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      jkillian.custom-local-formatters
      ms-python.python
    ];
    userSettings = builtins.fromJSON ''
      {
          "[nix]": {
              "editor.defaultFormatter": "jkillian.custom-local-formatters"
          },
          "customLocalFormatters.formatters": [
              {
                  "command": "nixfmt",
                  "languages": [
                      "nix"
                  ]
              }
          ],
          "git.autofetch": true,
          "git.suggestSmartCommit": false
      }
    '';
  };
}
