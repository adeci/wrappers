{
  config,
  wlib,
  lib,
  ...
}:
{
  _class = "wrapper";

  options = {

    configFile = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = ''
        Waybar configuration settings file.
        See <https://github.com/Alexays/Waybar/wiki/Configuration>
      '';
      example = ''
        {
          "height": 30,
          "layer": "top",
          "modules-center": [],
          "modules-left": [
            "sway/workspaces",
            "niri/workspaces"
          ]
        }
      '';
    };

    "style.css" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = "CSS style for Waybar.";
    };

  };

  config.flags = {
    "--config" = config.configFile.path;
    "--style" = config."style.css".path;
  };

  config.package = lib.mkDefault config.pkgs.waybar;

  config.meta.maintainers = [
    {
      name = "turbio";
      github = "turbio";
      githubId = 1428207;
    }
  ];

  config.meta.platforms = lib.platforms.linux;

}
