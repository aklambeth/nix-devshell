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

          python = pkgs.mkShell {
            name = "python-dev";

            buildInputs = with pkgs; [
                # Python 3.13 with properly integrated packages
                (python313.withPackages (ps: with ps; [
                  pip
                  virtualenv
                ]))

                # GitHub CLI
                git
                gh

                # Modern Python package management tools
                pipx
                uv
              ];

            shellHook = ''
              echo "🐍 Python Development Shell"
              echo "Python version: $(python --version)"
              echo "GitHub CLI version: $(gh --version | head -n1)"
              echo "UV version: $(uv --version)"
              echo "Pipx version: $(pipx --version)"
              echo "MkDocs Material available"
              echo ""
              echo "Available commands:"
              echo "  python    - Python 3.13 interpreter"
              echo "  uv        - Ultra-fast Python package installer"
              echo "  pipx      - Install and run Python applications in isolated environments"
              echo "  pip       - Traditional package installer"
              echo "  gh        - GitHub CLI"
              echo ""
              echo "Quick start:"
              echo "  uv venv .venv          # Create virtual environment with uv"
              echo "  source .venv/bin/activate  # Activate virtual environment"
              echo "  pipx install <package> # Install Python app globally"
              echo ""
            '';

            # Environment variables
            PYTHONPATH = "${pkgs.python313Packages.mkdocs-material}/${pkgs.python313.sitePackages}";
          };

          # You can add more named devShells here
          #
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
