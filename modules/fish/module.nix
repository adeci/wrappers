{
  config,
  lib,
  wlib,
  ...
}:
let
  # Generate function files from the functions attrset
  functionFiles = lib.mapAttrsToList (name: content: {
    name = "fish/functions/${name}.fish";
    path = config.pkgs.writeText "${name}.fish" ''
      function ${name}
          ${content}
      end
    '';
  }) config.functions;

  # Generate conf.d snippet files if provided
  confFiles = lib.mapAttrsToList (name: content: {
    name = "fish/conf.d/${name}.fish";
    path = config.pkgs.writeText "${name}.fish" content;
  }) config."conf.d";
in
{
  _class = "wrapper";

  options = {
    "config.fish" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = ''
        Your fish configuration file content.
        Write as you would for ~/.config/fish/config.fish

        Example:
        ```fish
        set -gx EDITOR nvim
        set -gx PATH $PATH /usr/local/bin

        alias ll='ls -la'
        abbr gc 'git commit'

        set fish_greeting ""
        ```
      '';
    };

    functions = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      description = ''
        Fish functions. Each attribute becomes a function file in functions/.
        The key is the function name, the value is the function body.

        Example:
        ```nix
        functions = {
          greet = '''
            echo "Hello, $argv"
          ''';
          mkcd = '''
            mkdir -p $argv[1]
            cd $argv[1]
          ''';
        };
        ```
      '';
    };

    "conf.d" = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      description = ''
        Configuration snippets that run before config.fish.
        Useful for modular configuration or overridable defaults.
        Files are executed in sorted order by filename.

        Example:
        ```nix
        "conf.d" = {
          "01-path" = '''
            set -gx PATH /opt/homebrew/bin $PATH
          ''';
          "02-colors" = '''
            set -gx CLICOLOR 1
          ''';
        };
        ```
      '';
    };
  };

  config.args =
    let
      # Create a directory with our functions
      functionsDir =
        if functionFiles != [ ] then config.pkgs.linkFarm "fish-functions" functionFiles else null;

      # Create a directory with our conf.d files
      confDir = if confFiles != [ ] then config.pkgs.linkFarm "fish-conf.d" confFiles else null;

      # Create the init script that sets up our environment
      initScript = config.pkgs.writeText "fish-init.fish" ''
        ${lib.optionalString (functionsDir != null) ''
          # Add our functions to the function path
          set -p fish_function_path "${functionsDir}/fish/functions"
        ''}

        ${lib.optionalString (confDir != null) ''
          # Source conf.d files in order
          for conf in ${confDir}/fish/conf.d/*.fish
            source $conf
          end
        ''}

        # Source our main config
        ${lib.optionalString (config."config.fish".content != "") ''
          source "${config."config.fish".path}"
        ''}
      '';
    in
    [
      # Totally isolated from system and default fish configs
      # This means we must set EVERYTHING ourselves
      # Normal fish integrations will not work unless explicitly set
      "--no-config"
      "--init-command"
      "source ${initScript}"
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
