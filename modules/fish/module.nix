{
  config,
  lib,
  wlib,
  ...
}:
{
  _class = "wrapper";

  options = {
    "config.fish" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = ''
        Your fish configuration file content.
      '';
      example = ''
        set -gx EDITOR nvim
        set -gx PATH $PATH /usr/local/bin

        alias ll='ls -la'
        abbr gc 'git commit'

        set fish_greeting ""

        # Define functions inline
        function mkcd
            mkdir -p $argv[1]
            and cd $argv[1]
        end
      '';
    };
  };

  config.args = lib.optionals (config."config.fish".content != "") [
    # Use system fish config and all integrations
    "--init-command"
    "source ${config."config.fish".path}"
  ];

  config.package = config.pkgs.fish;

  config.meta.maintainers = [
    {
      name = "adeci";
      github = "adeci";
      githubId = 80290157;
    }
  ];
  config.meta.platforms = lib.platforms.all;
}
