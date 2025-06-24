{ config, pkgs, lib, modulesPath, ... }: {

  imports = [
    "${modulesPath}/image/repart.nix"
  ];

  image.repart =
    let
      efiArch = pkgs.stdenv.hostPlatform.efiArch;
    in
    {
      name = config.boot.uki.name;
      split = true;

      partitions = {
        "esp" = {
          contents = {
            "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
              "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

            "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
              "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";

            # systemd-boot configuration
            "/loader/loader.conf".source = (pkgs.writeText "$out" ''
              timeout 3
            '');
          };
          repartConfig = {
            Type = "esp";
            UUID = "c12a7328-f81f-11d2-ba4b-00a0c93ec93b"; # Well known
            Format = "vfat";
            SizeMinBytes = "260M";
            SizeMaxBytes = "260M";
            SplitName = "-";
          };
        };
        "store" = {
          storePaths = [ config.system.build.toplevel ];
          stripNixStorePrefix = true;
          repartConfig = {
            Type = "linux-generic";
            Label = "store_${config.system.image.version}";
            Format = "squashfs";
            Minimize = "off";
            ReadOnly = "yes";
            SizeMinBytes = "4G";
            SizeMaxBytes = "4G";
            SplitName = "store";
          };
        };
/*
        # Placeholder for the second installed Nix store.
        "store-empty" = {
          repartConfig = {
            Type = "linux-generic";
            Label = "_empty";
            Minimize = "off";
            SizeMinBytes = "4G";
            SizeMaxBytes = "4G";
            SplitName = "-";
          };
        };

        # Persistent storage
        "var" = {
          repartConfig = {
            Type = "var";
            UUID = "4d21b016-b534-45c2-a9fb-5c16e091fd2d"; # Well known
            Format = "btrfs";
            Label = "nixos-persistent";
            Minimize = "off";

            # Has to be large enough to hold update files.
            SizeMinBytes = "8G";
            SizeMaxBytes = "8G";
            SplitName = "-";

            # Wiping this gives us a clean state.
            FactoryReset = "yes";
          };
        };*/
      };
    };
}
