{ pkgs, lib, ... }:
{
  programs.firefox = {
    # Inspiration taken from
    # https://github.com/quatquatt/nixos/blob/main/base/software/home/firefox.nix
    # https://github.com/Misterio77/nix-config/blob/main/home/gabriel/features/desktop/common/firefox.nix
    enable = true;
    policies = {
      # Available policies: https://mozilla.github.io/policy-templates/
      DontCheckDefaultBrowser = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;

      DisplayBookmarksToolbar = "never";

      OverrideFirstRunPage = "";
      PictureInPicture.Enabled = false;
      PromptForDownloadLocation = false;

      HardwareAcceleration = true;
      TranslateEnabled = true;

      Homepage.StartPage = "previous-session";

      UserMessaging = {
        UrlbarInterventions = false;
        SkipOnboarding = true;
      };

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };

      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      FirefoxHome = # Make new tab only show search
        {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
        };
    };
    policies.Preferences = {
      "browser.urlbar.suggest.searches" = true; # Need this for basic search suggestions
      "browser.urlbar.shortcuts.bookmarks" = false;
      "browser.urlbar.shortcuts.history" = false;
      "browser.urlbar.shortcuts.tabs" = false;

      "browser.tabs.tabMinWidth" = 75; # Make tabs able to be smaller to prevent scrolling

      "browser.aboutConfig.showWarning" = false; # No warning when going to config
      "browser.warnOnQuitShortcut" = false;

      "browser.tabs.loadInBackground" = true; # Load tabs automaticlaly

      "browser.in-content.dark-mode" = true; # Use dark mode
      "ui.systemUsesDarkTheme" = true;

      "extensions.autoDisableScopes" = 0; # Automatically enable extensions
      "extensions.update.enabled" = false; # Don't update extensions since they're sourced from rycee
    };
    profiles.default = {
      search = {
        force = true;
        default = "Google";
        privateDefault = "DuckDuckGo";
        order = [
          "Google"
          "DuckDuckGo"
        ];
        engines = {
          "Bing".metaData.hidden = true;
        };
      };
      bookmarks = { };
      # extensions = with inputs.firefox-addons; [
      #     ublock-origin
      # ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
