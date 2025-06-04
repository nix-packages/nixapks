{ pkgs, ... }:

let
  buildToolsVersion = "34.0.0";
  platformVersion = "35";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion ];
    platformToolsVersion = "35.0.2";
    platformVersions = [ platformVersion ];
    emulatorVersion = "35.2.5";
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis"];
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

  # in postPatch we patch the gradle.properties file to use more ram

  postPatch = ''
    substituteInPlace gradle.properties \
      --replace-fail "org.gradle.jvmargs=-Xmx3072M" "org.gradle.jvmargs=-Xmx4096M"
  '';
  nativeBuildInputs = [
    androidComposition.androidsdk
    gradle
    (with pkgs; [
      temurin-bin
      keepBuildTree
      git
      # jdk21
    ])
  ];

  mitmCache = gradle.fetchDeps {
    # pname = "ankidroid";
    pkg = finalAttrs;
    data = ./deps.json;
  };
  ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
  gradleFlags = "  -PsigningConfigs.skip=true -Duniversal-apk=true -Dorg.gradle.project.android.aapt2FromMavenOverride=${finalAttrs.ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";

  gradleBuildTask = "assembleDebug";
  doCheck = true;

  gradleUpdateTask = "assembleDebug";

  installPhase = ''
    cp app/build/outputs/apk/release/app-release.apk $out
  '';
})

