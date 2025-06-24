{
  description = "Alternative Remote Control ComposiTV Operating System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      inherit (nixpkgs) lib;

      # The platform we want to build on. This should ideally be configurable.
      buildPlatform = "x86_64-linux";

      # We use this to build derivations for the build platform.
      buildPkgs = nixpkgs.legacyPackages."${buildPlatform}";
    in
    (flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ] (system:
      let
        # We use this later to add some extra outputs for the build system.
        isBuildPlatform = system == buildPlatform;

        # We treat everything as cross-compilation without a special
        # case for isBuildSystem. Nixpkgs will do the right thing.
        crossPkgs = import nixpkgs { localSystem = buildPlatform; crossSystem = system; config = { allowUnfree = true; }; };

        # A convenience wrapper around lib.nixosSystem that configures
        # cross-compilation.
        crossNixos = module: lib.nixosSystem {
          modules = [
            module

            {
              # We could also use these to trigger cross-compilation,
              # but we already have the ready-to-go crossPkgs.
              #
              # nixpkgs.buildPlatform = buildSystem;
              # nixpkgs.hostPlatform = system;
              nixpkgs.pkgs = crossPkgs;
            }
          ];
        };
      in
      # Some outputs only make sense for the build system, e.g. the development shell.
      (lib.optionalAttrs isBuildPlatform (import ./buildHost.nix { pkgs = buildPkgs; }))
      //
      {
        packages =
          let
            ctv_1 = crossNixos {
              imports = [
                ./base.nix
                ./version-1.nix
              ];

              system.image.version = "2025062405"; # YYYYMMDDnn
            };
          in
          {
            default = self.packages."${system}".ctv_image;

            ctv_image = self.lib.mkInstallImage ctv_1;
            ctv_update = self.lib.mkUpdate ctv_1;
          };
      })) // {
      lib = {
        # Prepare an update package for the system.
        mkUpdate = nixos:
          let
            config = nixos.config;
          in
          buildPkgs.runCommand "update-${config.system.image.version}"
            {
              nativeBuildInputs = with buildPkgs; [ xz ];
            } ''
            mkdir -p $out
            xz -1 -cz ${config.system.build.uki}/${config.system.boot.loader.ukiFile} \
              > $out/${config.system.boot.loader.ukiFile}.xz
            xz -1 -cz ${config.system.build.image}/${config.boot.uki.name}_${config.system.image.version}.store.raw \
              > $out/store_${config.system.image.version}.img.xz
          '';

        # Prepare a ready-to-boot disk image.
        mkInstallImage = nixos:
          let
            config = nixos.config;
          in
          buildPkgs.runCommand "image-${config.system.image.version}"
            {
              nativeBuildInputs = with buildPkgs; [ qemu ];
            } ''
            mkdir -p $out
            qemu-img convert -f raw -O qcow2 \
              -C ${config.system.build.image}/${config.boot.uki.name}_${config.system.image.version}.raw \
              $out/disk.qcow2
          '';
      };
    };
}
