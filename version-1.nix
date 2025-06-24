{ config, pkgs, ... }:
{
  networking.hostName = "compose";

  programs = {
    firefox = {
      enable = true;
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DontCheckDefaultBrowser = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        DisableFormHistory = true;
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        FirefoxHome = {
          SponsoredTopSites = false;
          Pocket = false;
          SponsoredPocket = false;
        };
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
        };
      };
    };
    niri.enable = true;
  };
  environment = {
    etc = {
      "niri/config.kdl".text = ''
input {
    keyboard {
        xkb {
        }
        numlock
    }
    touchpad {
        natural-scroll
    }
}

layout {
    gaps 16
    center-focused-column "never"
    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 1.0
    }
    default-column-width { proportion 1.0; }
    focus-ring {
        width 4
        active-color "#7fc8ff"
        inactive-color "#505050"
    }
    border {
        off
    }
}

spawn-at-startup "swaybg" "-m" "center" "-i" "${./extra/compositv.png}"
spawn-at-startup "mako"
spawn-at-startup "wvkbd-mobintl" "--hidden"
spawn-at-startup "pw-play" "${./extra/startup.opus}"

screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

window-rule {
    match app-id=r#"firefox$"# title="^Picture-in-Picture$"
    open-floating true
}

binds {
    Mod+Shift+Slash { show-hotkey-overlay; }
    Mod+K hotkey-overlay-title="Toggle On-Screen Keyboard" { spawn "killall" "-s" "34" "wvkbd-mobintl"; }

    //Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
    Mod+D hotkey-overlay-title="Run an Application" { spawn "sh" "-c" "pw-play ${./extra/launcher.opus} & fuzzel"; }

    XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
    XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
    XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

    XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

    Mod+O repeat=false { toggle-overview; }
    Mod+Q repeat=false { close-window; }

    Mod+Left  { focus-column-left; }
    Mod+Down  { focus-window-down; }
    Mod+Up    { focus-window-up; }
    Mod+Right { focus-column-right; }

    Mod+Ctrl+Left  { move-column-left; }
    Mod+Ctrl+Down  { move-window-down; }
    Mod+Ctrl+Up    { move-window-up; }
    Mod+Ctrl+Right { move-column-right; }

    Mod+Shift+Left  { focus-monitor-left; }
    Mod+Shift+Down  { focus-monitor-down; }
    Mod+Shift+Up    { focus-monitor-up; }
    Mod+Shift+Right { focus-monitor-right; }

    Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
    Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
    Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
    Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }

    Mod+Page_Down      { focus-workspace-down; }
    Mod+Page_Up        { focus-workspace-up; }
    Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
    Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }

    Mod+Shift+Page_Down { move-workspace-down; }
    Mod+Shift+Page_Up   { move-workspace-up; }

    Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
    Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
    Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
    Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

    Mod+WheelScrollRight      { focus-column-right; }
    Mod+WheelScrollLeft       { focus-column-left; }
    Mod+Ctrl+WheelScrollRight { move-column-right; }
    Mod+Ctrl+WheelScrollLeft  { move-column-left; }

    Mod+BracketLeft  { consume-or-expel-window-left; }
    Mod+BracketRight { consume-or-expel-window-right; }

    Mod+Comma  { consume-window-into-column; }
    Mod+Period { expel-window-from-column; }

    Mod+R { switch-preset-column-width; }
    Mod+Shift+R { switch-preset-window-height; }
    Mod+Ctrl+R { reset-window-height; }
    Mod+F { maximize-column; }
    Mod+Shift+F { fullscreen-window; }
    Mod+Ctrl+F { expand-column-to-available-width; }

    Mod+C { center-column; }
    Mod+Ctrl+C { center-visible-columns; }

    Mod+Minus { set-column-width "-10%"; }
    Mod+Equal { set-column-width "+10%"; }
    Mod+Shift+Minus { set-window-height "-10%"; }
    Mod+Shift+Equal { set-window-height "+10%"; }

    Mod+V       { toggle-window-floating; }
    Mod+Shift+V { switch-focus-between-floating-and-tiling; }

    Mod+W { toggle-column-tabbed-display; }

    Print { screenshot; }
    Ctrl+Print { screenshot-screen; }
    Alt+Print { screenshot-window; }

    Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

    Mod+Shift+E { quit; }
    Ctrl+Alt+Delete { quit; }

    Mod+Shift+P { power-off-monitors; }
}

hotkey-overlay {
    skip-at-startup
}
      '';
    };
    systemPackages = with pkgs; [
      fuzzel
      mako
      psmisc
      swaybg
      vlc
      wvkbd
    ];
  };
  security.rtkit.enable = true;
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "you";
          command  = "${pkgs.niri}/bin/niri-session";
        };
        initial_session = {
          user = "you";
          command  = "${pkgs.niri}/bin/niri-session";
        };
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    pulseaudio.enable = false;
  };
  users.users.you = {
    isSystemUser = true;
    home = "/home/you";
    shell = pkgs.bash;
    description = "You";
    group = "you";
    extraGroups = [
      "input"
      "networkmanager"
      "seat"
      "video"
      "wheel"
    ];
  };
  users.groups.you = {};
}
