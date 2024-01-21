{ lib
, stdenv
, fetchurl
, directoryListingUpdater
, SDL2
, SDL2_image
, SDL2_mixer
, SDL2_ttf
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lbreakouthd";
  version = "1.1.6";

  src = fetchurl {
    url = "mirror://sourceforge/lgames/lbreakouthd-${finalAttrs.version}.tar.gz";
    hash = "sha256-Gor2LnM8vi6skJbzfR5023J13GxvqcpIrua9S+nT/S0=";
  };

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
  ];

  hardeningDisable = [ "format" ];

  passthru.updateScript = directoryListingUpdater {
    inherit (finalAttrs) pname version;
    url = "https://lgames.sourceforge.io/LBreakoutHD/";
    extraRegex = "(?!.*-win(32|64)).*";
  };

  meta = {
    homepage = "https://lgames.sourceforge.io/LBreakoutHD/";
    description = "A widescreen Breakout clone";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ AndersonTorres ];
    inherit (SDL2.meta) platforms;
    broken = stdenv.isDarwin;
  };
})
