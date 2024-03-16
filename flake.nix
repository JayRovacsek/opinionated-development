{
  description = "Opinionated Development";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    gitignore = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hercules-ci/gitignore.nix";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-github-actions = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-github-actions";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { flake-utils, nixpkgs, pre-commit-hooks, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = self;
            hooks = {
              actionlint.enable = true;
              conform.enable = true;
              deadnix.enable = true;
              nixfmt.enable = true;
              prettier.enable = true;
              statix.enable = true;
              typos.enable = true;

              # Custom hooks
              conform-config = {
                enable = true;
                name = "Conform Config";
                entry = ''
                  ${pkgs.coreutils}/bin/cp ${
                    self.packages.${system}.conform-config
                  } .conform.yaml
                '';
                language = "system";
                pass_filenames = false;
              };

              github-checks-workflow = {
                enable = true;
                name = "Github Checks Workflow";
                entry = ''
                  ${pkgs.coreutils}/bin/cp ${
                    self.packages.${system}.git-workflow-checks
                  } .github/workflows/checks.yaml
                '';
                language = "system";
                pass_filenames = false;
              };

              git-cliff = {
                enable = true;
                name = "Git Cliff";
                entry = "${pkgs.git-cliff}/bin/git-cliff --config ${
                    self.packages.${system}.cliff-config
                  } --output CHANGELOG.md";
                language = "system";
                pass_filenames = false;
              };

              statix-write = {
                enable = true;
                name = "Statix Write";
                entry = "${pkgs.statix}/bin/statix fix";
                language = "system";
                pass_filenames = false;
              };

              trufflehog-verified = {
                enable = true;
                name = "Trufflehog Search";
                entry =
                  "${pkgs.trufflehog}/bin/trufflehog git file://. --since-commit HEAD --only-verified --fail --no-update";
                language = "system";
                pass_filenames = false;
              };

              trufflehog-regex = {
                enable = true;
                name = "Trufflehog Regex Search";
                entry =
                  "${pkgs.trufflehog}/bin/trufflehog git file://. --since-commit HEAD --config ${
                    self.packages.${system}.trufflehog-config
                  } --fail --no-verification -x ${
                    self.packages.${system}.trufflehog-ignore
                  }  --no-update";
                language = "system";
                pass_filenames = false;
              };
            };

            settings = {
              deadnix.edit = true;
              nixfmt.width = 80;
              prettier = {
                ignore-path = [ self.packages.${system}.prettier-ignore ];
                write = true;
              };
              typos = {
                configPath = "${self.packages.${system}.typos-config}";
                locale = "en-au";
              };
            };
          };
        };

        devShells.default = pkgs.mkShell {
          name = "opinionated-development-dev-shell";
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        githubActions = self.inputs.nix-github-actions.lib.mkGithubMatrix {
          checks =
            (pkgs.lib.getAttrs [ "x86_64-linux" "x86_64-darwin" ] self.checks)
            // (pkgs.lib.getAttrs [ "x86_64-linux" "x86_64-darwin" ]
              self.packages);
        };

        packages = {
          cliff-config = pkgs.callPackage ./packages/cliff-config { };
          conform-config = pkgs.callPackage ./packages/conform-config { };
          git-workflow-checks =
            pkgs.callPackage ./packages/git-workflow-checks { };
          prettier-ignore = pkgs.callPackage ./packages/prettier-ignore { };
          trufflehog-config = pkgs.callPackage ./packages/trufflehog-config { };
          trufflehog-ignore = pkgs.callPackage ./packages/trufflehog-ignore { };
          typos-config = pkgs.callPackage ./packages/typos-config { };
        };
      });
}
