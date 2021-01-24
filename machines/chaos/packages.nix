{ ... }: {

  home-manager.users.rien = { pkgs, ... }: {
    home.packages = with pkgs; [
      ranger
      acpi
      ripgrep
      spotify-tui
      fd
      strace
      nix-index
      pciutils
    ];
  };
}
