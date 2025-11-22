{
  pkgs,
  self,
}:
let
  waybarWrapped =
    (self.wrapperModules.waybar.apply {
      inherit pkgs;

      configFile.content = ''
        position = "top";
        modules-left = [ ];
        modules-right = [ ];
        modules-center = [ ];
      '';

      "style.css".content = "";

    }).wrapper;

in
pkgs.runCommand "waybar-test" { } ''
  "${waybarWrapped}/bin/waybar" --version | grep -q "${waybarWrapped.version}"
  touch $out
''
