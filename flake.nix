{
  description = "Development shell configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      # Helper function to create system-specific pkgs
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      
      # Import pkgs for each system
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    in {

      devShells = forAllSystems (system: 
        let
          pkgs = pkgsForSystem system;
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              zsh
            ];
            shellHook = ''
              # Check if zsh is installed and set it as the default shell
              if command -v zsh >/dev/null 2>&1; then
                export SHELL=$(command -v zsh)
                exec zsh
              else
                echo "zsh is not installed. Falling back to default shell."
              fi
            '';
          };
          # You can add more named devShells here

          node = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_22
              yarn
              
            ];
          };
          # You can add more named devShells here

          
        }
      );
    };
}