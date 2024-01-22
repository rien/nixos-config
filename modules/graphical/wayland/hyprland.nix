{
  # State configured by nwg-displays
  source = "~/.config/hypr/monitors.conf";

  env = "XCURSOR_SIZE,24";

  input = {
    kb_layout = "us";
    kb_variant = "alt-intl";
    kb_options = "caps:none";
    numlock_by_default = "true";
    repeat_rate = "75";
    repeat_delay = "175";

    follow_mouse = "1";

    touchpad = {
        middle_button_emulation = "true";
        natural_scroll = "false";
    };
  };

  general = {
    gaps_in = "2";
    gaps_out = "10";
    border_size = "2";
    "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    "col.inactive_border" = "rgba(595959aa)";

    layout = "dwindle";
  };

  misc.force_default_wallpaper = 0;

  dwindle = {
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = true; # you probably want this
  };

  decoration = {
      rounding = "5";

      drop_shadow = "true";
      shadow_range = "4";
      shadow_render_power = "3";
      "col.shadow" = "rgba(1a1a1aee)";
  };

  animations = {
      enabled = true;

      # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
  };

  gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
  };

  windowrulev2 = [
    "noinitialfocus,class:^(jetbrains-.*),title:^(win.*)"
  ];

  "$mod" = "SUPER";
  bind = [
    "$mod, Return, exec, kitty"
    "$mod, F, exec, firefox"
    "$mod, L, exec, swaylock -fF -c a6e3a1"
    "$mod, C, killactive,"
    "$mod, Q, exit,"
    "$mod, E, exec, dolphin"
    "$mod, V, togglefloating,"
    "$mod, R, exec, kickoff"
    "$mod, P, pseudo, # dwindle"
    "$mod, J, togglesplit, # dwindle"

    # Move focus with mainMod + arrow keys
    "$mod, left, movefocus, l"
    "$mod, right, movefocus, r"
    "$mod, up, movefocus, u"
    "$mod, down, movefocus, d"

    # Switch workspaces with mainMod + [0-9]
    "$mod, 1, moveworkspacetomonitor, 1 current"
    "$mod, 1, workspace, 1"
    "$mod, 2, moveworkspacetomonitor, 2 current"
    "$mod, 2, workspace, 2"
    "$mod, 3, moveworkspacetomonitor, 3 current"
    "$mod, 3, workspace, 3"
    "$mod, 4, moveworkspacetomonitor, 4 current"
    "$mod, 4, workspace, 4"
    "$mod, 5, moveworkspacetomonitor, 5 current"
    "$mod, 5, workspace, 5"
    "$mod, 6, moveworkspacetomonitor, 6 current"
    "$mod, 6, workspace, 6"
    "$mod, 7, moveworkspacetomonitor, 7 current"
    "$mod, 7, workspace, 7"
    "$mod, 8, moveworkspacetomonitor, 8 current"
    "$mod, 8, workspace, 8"
    "$mod, 9, moveworkspacetomonitor, 9 current"
    "$mod, 9, workspace, 9"
    "$mod, 0, moveworkspacetomonitor, 10 current"
    "$mod, 0, workspace, 10"



    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    "$mod SHIFT, 1, movetoworkspace, 1"
    "$mod SHIFT, 2, movetoworkspace, 2"
    "$mod SHIFT, 3, movetoworkspace, 3"
    "$mod SHIFT, 4, movetoworkspace, 4"
    "$mod SHIFT, 5, movetoworkspace, 5"
    "$mod SHIFT, 6, movetoworkspace, 6"
    "$mod SHIFT, 7, movetoworkspace, 7"
    "$mod SHIFT, 8, movetoworkspace, 8"
    "$mod SHIFT, 9, movetoworkspace, 9"
    "$mod SHIFT, 0, movetoworkspace, 10"

    # Example special workspace (scratchpad)
    "$mod, S, togglespecialworkspace, magic"
    "$mod SHIFT, S, movetoworkspace, special:magic"

    # Scroll through existing workspaces with mainMod + scroll
    "$mod, mouse_down, workspace, e+1"
    "$mod, mouse_up, workspace, e-1"


    # Media controls
    ", XF86AudioRaiseVolume, exec, pamixer -i 5"
    ", XF86AudioLowerVolume, exec, pamixer -d 5"
    ", XF86AudioMicMute, exec, pamixer --default-source -m"
    ", XF86AudioMute, exec, pamixer -m"
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioPause, exec, playerctl play-pause"
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPrev, exec, playerctl previous"
  ];

  bindm = [
    # Move/resize windows with mainMod + LMB/RMB and dragging
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];
}
