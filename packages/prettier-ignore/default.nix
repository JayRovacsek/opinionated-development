{ writeTextFile, ... }:
writeTextFile {
  name = ".prettierignore";
  text = ''
    .conform.yaml
    .pre-commit-config.yaml
    *.nix
    CHANGELOG.md
    checks.yaml
    result
  '';
}
