{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
      appimageTools = pkgs.appimageTools;
      fetchurl = pkgs.fetchurl;
    in
    {
      packages = {
        ${system} = {
          miru = let
            version = "5.5.6"; # Update this to the correct version of Miru
            pname = "miru";
            name = "${pname}-${version}";

            src = fetchurl {
              url = "https://github.com/ThaUnknown/miru/releases/download/v${version}/linux-Miru-${version}.AppImage";
              hash = "sha256:04fmg7phjxp8axdzvyrliaqnrrzk5lb36x30hn116hgz24dazxn9"; # Replace with the correct sha256 hash
            };

            appimageContents = appimageTools.extractType1 { inherit name src; };
          in
          appimageTools.wrapType1 {
            inherit name src;

            extraInstallCommands = ''
              mv $out/bin/${name} $out/bin/${pname}
              install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
              substituteInPlace $out/share/applications/${pname}.desktop \
                --replace-fail 'Exec=AppRun' 'Exec=${pname}'
              cp -r ${appimageContents}/usr/share/icons $out/share
            '';
          };
        };
      };

      defaultPackage.${system} = self.packages.${system}.miru;
    };
}