{
  description = "Build android applications with nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
    gradle2nix.url = "github:tadfisher/gradle2nix/v2";
    gradle-dot-nix.url = "github:CrazyChaoz/gradle-dot-nix";
  };
  outputs =
    inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          # i dont understand why this is needed, but it is
          allowUnfreePredicate =
            pkg:
            builtins.elem (pkgs.lib.getName pkg) [
              "android-sdk-cmdline-tools"
              "android-sdk-platform-tools"
              "android-sdk-tools"
              "android-sdk-emulator"
              "android-sdk-build-tools"
              "android-sdk-platforms"
              "android-sdk-system-image-35-google_apis-arm64-v8a-system-image-35-google_apis-x86_64"
            ];
        };
      };

      myLib = pkgs.callPackage ./lib { inherit inputs; };
    in
    {
      packages.x86_64-linux = myLib.byNameOverlay ./apks;
      lib = myLib;
    };
}
