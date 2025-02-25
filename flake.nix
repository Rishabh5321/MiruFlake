{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        miru = pkgs.appimageTools.wrapType2 rec {
          name = "miru";
          pname = "miru";
          version = "5.5.10";

          src = pkgs.fetchurl {
            url = "https://github.com/ThaUnknown/miru/releases/download/v${version}/linux-Miru-${version}.AppImage";
            hash = "sha256-nLPqEI6u5NNQ/kPbXRWPG0pIwutKNK2J8JeTPN6wHlg=";
          };

          extraInstallCommands =
            let
              contents = pkgs.appimageTools.extract { inherit pname version src; };
            in
            ''
              install -m 444 -D ${contents}/miru.desktop -t $out/share/applications
              substituteInPlace $out/share/applications/miru.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
              cp -r ${contents}/usr/share/icons $out/share
            '';

          meta = with pkgs.lib; {
            description = "Bittorrent streaming software for cats.";
            homepage = "https://github.com/ThaUnknown/miru";
            license = licenses.gpl3;
            maintainers = with maintainers; [ karitham ];
            platforms = [ "x86_64-linux" ];
            mainProgram = "miru";
          };
        };
      };

      defaultPackage.${system} = self.packages.${system}.miru;
    };
}