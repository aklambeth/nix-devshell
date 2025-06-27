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
              ansible
              claude-code
              git
              gh
              opentofu
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
              nodejs_24
	      typescript
              claude-code
              yarn
              git
              gh
            ];
          };
          # You can add more named devShells here

          mcp = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_22
              ansible
              claude-code
              yarn
              python313
              python312Packages.pip
              uv
              git
              gh 
            ];
          };
          # You can add more named devShells here

          docker = pkgs.mkShell {
            packages = with pkgs; [
              docker
              docker-compose
              lazydocker
            ];
          };

          ollama = pkgs.mkShell {
            packages = with pkgs; [
              ollama
            ];
          };

          # You can add more named devShells here


        }
      );
    };
}
