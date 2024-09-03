{
  pkgs,
  inputs,
  lib,
  ...
}:

let
  # I have not been able to successfully pull in the version of buildFirefoxXpiAddon that is
  # defined in nur. In lots of other people's configs it is somehow either "just there" or is
  # pulled in with something like 
  # `buildFirefoxXpiAddon = config.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon;` and is
  # does not appear to be available via
  # `buildFirefoxXpiAddon = inputs.firefox-addons.buildFirefoxXpiAddon;`
  #
  # This was inspired by https://github.com/jwiegley/nix-config/blob/9cc2120b1ab5d092131b5027c82249d863494623/config/home.nix#L253
  #
  # Source code for buildFirefoxXpiAddon: https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/default.nix#L5
  buildFirefoxXpiAddon = lib.makeOverridable (
    {
      stdenv ? pkgs.stdenv,
      fetchurl ? pkgs.fetchurl,
      pname,
      version,
      addonId,
      url,
      sha256,
      meta,
      ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      passthru = {
        inherit addonId;
      };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );
in
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
    # This setting is adapted from the browser.uiCustomization.state setting in about:config
    policies.Preferences."browser.uiCustomization.state" = builtins.toJSON {
      placements = {
        widget-overflow-fixed-list = [ ];
        unified-extensions-area = [ "enhancerforyoutube_maximerf_addons_mozilla_org-browser-action" ];
        nav-bar = [
          "back-button"
          "forward-button"
          "stop-reload-button"
          "urlbar-container"
          "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
          "ublock0_raymondhill_net-browser-action"
          "downloads-button"
          "_testpilot-containers-browser-action"
          "reset-pbm-toolbar-button"
          "unified-extensions-button"
        ];
        toolbar-menubar = [ "menubar-items" ];
        TabsToolbar = [
          "tabbrowser-tabs"
          "new-tab-button"
          "alltabs-button"
        ];
        PersonalToolbar = [ "personal-bookmarks" ];
      };
      seen = [
        "save-to-pocket-button"
        "developer-button"
        "ublock0_raymondhill_net-browser-action"
        "_testpilot-containers-browser-action"
        "enhancerforyoutube_maximerf_addons_mozilla_org-browser-action"
        "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
      ];
      dirtyAreaCache = [
        "nav-bar"
        "PersonalToolbar"
        "toolbar-menubar"
        "TabsToolbar"
        "widget-overflow-fixed-list"
        "unified-extensions-area"
      ];
      currentVersion = 20;
      newElementCount = 8;
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
      # Search for extensions available in firefox-addons with 
      # `nix flake show gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons`
      # or browse online at https://nur.nix-community.org/repos/rycee
      #
      # Note: If desired you can have the build failed when new permissions are added:
      # https://gitlab.com/rycee/nur-expressions/?dir=pkgs%2Ffirefox-addons#permission-allow-lists
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin

        # I have not been able to get unfree extensions working. Looking through many examples
        # onlines I suspect there may be something about Home Manager as a NixOS module that is
        # different from other people's setups, but I am not (yet) skilled enough in nix to
        # figure out what the problem is. In theory `home-manager.useGlobalPkgs = true;` in my 
        # flakes.nix and 
        # 
        # 
        # Source of fields
        # - For addons that are part of firefox-addons (but which are unfree and thus can't be
        #   added by their name) the details can be copied from
        #   https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/generated-firefox-addons.nix
        # First visit the addon page on https://addons.mozilla.org/
        # - pname: Use the addon name for pname, replacing spaces with hyphens. TODO: is that true? could it be anything?
        # - version: Find the version number on the addon page.
        # - url: 
        # - addonId: 
        #   - Install the addon temporarily in Firefox
        #   - Go to about:debugging#/runtime/this-firefox
        #   - Find the addon and copy its Extension ID
        # - sha256:
        #   - Easy mode: set it to some value, rebuild and copy the value from the error after "sha256-"*c;
        #       error: hash mismatch in fixed-output derivation '/nix/store/r79p3gx4r46pbhnyr93qy86fyqy66fz6-enhancer_for_youtube-2.0.126.xpi.drv':
        #        specified: sha256-HIdlLBSW9kWFg9/dob05CAhUK472lgdGMukxiLD+FNM=
        #           got:    sha256-VrSX1G8HWrzXTS7eWauXKOb6FIJqhdWtnaqitlPdMTg=
        #   - Hard mode: 
        #     - Download the XPI file using the URL from step 4
        #     - Run nix-prefetch-url file://path/to/downloaded.xpi
        #     - Copy the resulting SHA256 hash
        # - meta: can be left empty but must be present
        (buildFirefoxXpiAddon {
          pname = "enhancer-for-youtube";
          version = "2.0.126";
          addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
          url = "https://addons.mozilla.org/firefox/downloads/file/4325319/enhancer_for_youtube-2.0.126.xpi";
          sha256 = "56b497d46f075abcd74d2ede59ab9728e6fa14826a85d5ad9daaa2b653dd3138";
          meta = with lib; {
            homepage = "https://www.mrfdev.com/enhancer-for-youtube";
            description = "Take control of YouTube and boost your user experience!";
            license = {
              shortName = "enhancer-for-youtube";
              fullName = "Custom License for Enhancer for YouTube™";
              url = "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/license/";
              free = false;
            };
            mozPermissions = [
              "cookies"
              "storage"
              "*://www.youtube.com/*"
              "*://www.youtube.com/embed/*"
              "*://www.youtube.com/live_chat*"
              "*://www.youtube.com/pop-up-player/*"
              "*://www.youtube.com/shorts/*"
            ];
            platforms = platforms.all;
          };

        })
        (buildFirefoxXpiAddon {
          pname = "onepassword-password-manager";
          version = "2.27.1";
          addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4333130/1password_x_password_manager-2.27.1.xpi";
          sha256 = "675502aa7938d495066e1e56e3c579c1216687175da87161e1ae89d610467736";
          meta = with lib; {
            homepage = "https://1password.com";
            description = "The best way to experience 1Password in your browser. Easily sign in to sites, generate passwords, and store secure information, including logins, credit cards, notes, and more.";
            license = {
              shortName = "1pwd";
              fullName = "Service Agreement for 1Password users and customers";
              url = "https://1password.com/legal/terms-of-service/";
              free = false;
            };
            mozPermissions = [
              "<all_urls>"
              "alarms"
              "clipboardWrite"
              "contextMenus"
              "downloads"
              "idle"
              "management"
              "nativeMessaging"
              "notifications"
              "privacy"
              "scripting"
              "tabs"
              "webNavigation"
              "webRequest"
              "webRequestBlocking"
              "https://*.1password.ca/*"
              "https://*.1password.com/*"
              "https://*.1password.eu/*"
              "https://*.b5dev.ca/*"
              "https://*.b5dev.com/*"
              "https://*.b5dev.eu/*"
              "https://*.b5local.com/*"
              "https://*.b5staging.com/*"
              "https://*.b5test.ca/*"
              "https://*.b5test.com/*"
              "https://*.b5test.eu/*"
              "https://*.b5rev.com/*"
            ];
            platforms = platforms.all;
          };
        })
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
