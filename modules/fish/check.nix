{
  pkgs,
  self,
}:

let
  fishWrapped =
    (self.wrapperModules.fish.apply {
      inherit pkgs;

      "config.fish".content = ''
        # Test configuration that loads after system defaults
        set -gx TEST_VAR "test_value"
        set -g fish_greeting "Test Fish Shell"

        # Test alias
        alias test-alias='echo "Alias works!"'

        # Test inline function
        function greet
          echo "Hello, $argv"
        end

        function testfunc
          echo "Test function works!"
        end
      '';

    }).wrapper;

in
pkgs.runCommand "fish-test" { } ''
  # Test 1: Fish version works
  "${fishWrapped}/bin/fish" --version | grep -q "fish"

  # Test 2: Inline functions work
  "${fishWrapped}/bin/fish" -c "greet World" | grep -q "Hello, World"
  "${fishWrapped}/bin/fish" -c "testfunc" | grep -q "Test function works!"

  # Test 3: Config variables are set
  "${fishWrapped}/bin/fish" -c 'echo $TEST_VAR' | grep -q "test_value"

  # Test 4: Aliases work
  "${fishWrapped}/bin/fish" -c "test-alias" | grep -q "Alias works!"

  # Test 5: System integration - basic fish functions should be available
  "${fishWrapped}/bin/fish" -c "type -q fish_add_path" && echo "System functions loaded"

  # Test 6: Completions are available (check for basic cd completion function)
  "${fishWrapped}/bin/fish" -c "functions -q __fish_complete_cd" && echo "System completions loaded"

  # Test 7: Our config loads AFTER system (test that we can override)
  "${fishWrapped}/bin/fish" -c 'echo $fish_greeting' | grep -q "Test Fish Shell"

  touch $out
''
