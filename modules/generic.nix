{ pkgs, config, ... }:
{

  hardware.enableAllHardware = true;
  hardware.enableAllFirmware = true;

  boot.uki.name = "arccos";
  boot.kernelParams = [ ];

  # TODO Is there a way to override these?
  #system.nixos.release = "2024-08";
  #system.nixos.codeName = "Babylon";

  system.nixos.distroId = "arccos";
  system.nixos.distroName = "arccos";

  # Make the current system version visible in the prompt.
  programs.bash.promptInit = ''
    export PS1='$? > '
  '';

  # Not compatible with system.etc.overlay.enable yet.
  # users.mutableUsers = false;

  services.getty.autologinUser = "root";

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.repart.enable = true;
  boot.initrd.systemd.repart.device =
    {
      x86_64-linux = "/dev/sda";
      aarch64-linux = "/dev/vda";
      riscv64-linux = "/dev/vda";
    }
    ."${pkgs.stdenv.system}";

  boot.initrd.systemd.services.systemd-repart.before = [ "sysroot.mount" ];

  systemd.repart.partitions = {
    "10-esp" = {
      Type = "esp";
      SplitName = "-";
    };
    "20-store" = {
      Type = "linux-generic";
      Label = "store_${config.system.image.version}";
      SplitName = "store";
      SizeMinBytes = "4G";
      SizeMaxBytes = "4G";
    };
    "30-store-empty" = {
      Type = "linux-generic";
      Label = "_empty";
      SplitName = "-";
      Minimize = "off";
      SizeMinBytes = "4G";
      SizeMaxBytes = "4G";
    };
    "40-var" = {
      Type = "var";
      UUID = "4d21b016-b534-45c2-a9fb-5c16e091fd2d"; # Well known
      Format = "btrfs";
      Label = "nixos-persistent";
      Minimize = "off";

      # Has to be large enough to hold update files.
      SizeMinBytes = "8G";
      SplitName = "-";

      # Wiping this gives us a clean state.
      FactoryReset = "yes";
    };
  };

  # Don't accumulate crap.
  boot.tmp.cleanOnBoot = true;
  services.journald.extraConfig = ''
    SystemMaxUse=10M
  '';

  # Debugging
  environment.systemPackages = with pkgs; [
    (runCommand "systemd-sysupdate" { } ''
      mkdir -p $out/bin
      ln -s ${config.systemd.package}/lib/systemd/systemd-sysupdate $out/bin
    '')
  ];

  system.stateVersion = "25.05";
}
