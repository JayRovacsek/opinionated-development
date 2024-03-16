{ writers, ... }:
writers.writeTOML "config.toml" {
  files.extend-exclude = [ ];

  default.extend-words = { };
}
