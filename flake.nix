{
  description = "Elixir Phoenix Development Environment with SQLite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      # Define packages needed for both devShell and build
      commonPackages = with pkgs; [
        elixir
        erlang
        elixir_ls
        sqlite
        glibcLocales
        nodejs_20

        # tools
        just
      ];

      nixTools = with pkgs; [
        alejandra
        nixpkgs-fmt
      ];
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = commonPackages ++ nixTools;

        shellHook = ''
          export LANG=en_US.UTF-8
          export ERL_AFLAGS="-kernel shell_history enabled"
          export MIX_HOME="$PWD/.nix-mix"
          export HEX_HOME="$PWD/.nix-hex"
          export PATH="$MIX_HOME/bin:$HEX_HOME/bin:$PATH"

          # Setup the Phoenix project on first run
          if [ ! -d "lib" ]; then
            echo "Setting up new Phoenix project with SQLite..."
            mix local.hex --force
            mix local.rebar --force
            mix archive.install hex phx_new --force
            mix phx.new . --app bundestag_annotate --database sqlite3

            # Accept all defaults
            echo "Y" | true
          fi

          echo "Elixir Phoenix development environment loaded!"
          echo "To start your Phoenix server:"
          echo "  * Run 'mix phx.server' or inside IEx with 'iex -S mix phx.server'"
        '';
      };
    });
}
