{ pkgs, ... }:

let
  buildToolsVersion = "34.0.0";
  platformVersion = "35";
  systemImageType = "google_apis";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion ];
    platformToolsVersion = "35.0.2";
    platformVersions = [ platformVersion ];
    emulatorVersion = "35.2.5";
    includeEmulator = true;
    abiVersions = [ "armeabi-v7a" "arm64-v8a" "x86_64" ];
    extraLicenses = [
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };
  gradle = pkgs.gradle_8;
in

pkgs.stdenv.mkDerivation (finalAttrs: rec {
  name = "ankidroid-${version}.apk";
  version = "2.20.1";

  src = pkgs.fetchFromGitHub {
    owner = "ankidroid";
    repo = "Anki-Android";
    tag = "v${version}";
    hash = "sha256-CPCczLovuQTjUTWgjVjgZ8PL4idlcTzWZ2wKwqsF+cg=";
  };

  nativeBuildInputs = [
    androidComposition.androidsdk
    gradle
    (with pkgs; [
      temurin-bin
      keepBuildTree
      git
    ])
  ];

  mitmCache = gradle.fetchDeps {
    # pname = "ankidroid";
    pkg = finalAttrs;
    data = ./deps.json;
  };
  ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";

  gradleBuildTask = "assembleRelease";
  doCheck = true;


  installPhase = ''
    cp app/build/outputs/apk/release/app-release.apk $out
  '';
})

