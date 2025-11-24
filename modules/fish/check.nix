{
  pkgs,
  self,
}:

let
  fishWrapped =
    (self.wrapperModules.fish.apply {
      inherit pkgs;

      "config.fish".content = ''
        # Test configuration
        set -gx TEST_VAR "test_value"
        set fish_greeting "Test Fish Shell"

        # Add an alias for testing
        alias test-alias='echo "Alias works!"'
      '';

      functions = {
        greet = ''
          echo "Hello, $argv"
        '';

        testfunc = ''
          echo "Test function works!"
        '';
      };

      "conf.d" = {
        "01-test" = ''
          # This runs before config.fish
          set -gx CONF_D_TEST "loaded"
        '';
      };

    }).wrapper;

in
pkgs.runCommand "fish-test" { } ''
  "${fishWrapped}/bin/fish" --version | grep -q "fish"

  "${fishWrapped}/bin/fish" -c "greet World" | grep -q "Hello, World"

  "${fishWrapped}/bin/fish" -c "testfunc" | grep -q "Test function works!"

  "${fishWrapped}/bin/fish" -c 'echo $TEST_VAR' | grep -q "test_value"

  "${fishWrapped}/bin/fish" -c 'echo $CONF_D_TEST' | grep -q "loaded"

  "${fishWrapped}/bin/fish" -c "test-alias" | grep -q "Alias works!"

  touch $out
''
