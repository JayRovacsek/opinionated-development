{ writers, ... }:
writers.writeTOML "config.toml" {
  files.extend-exclude = [ ];

  default.extend-words = {
    # False positive caught in commit hashes
    ba = "ba";
  };
}
