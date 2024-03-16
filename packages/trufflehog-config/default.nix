{ writers, ... }:
writers.writeYAML "config.yaml" {
  detectors = [{
    name = "Basic sensitive regex search";
    keywords = [ "TOKEN" "AUTHTOKEN" "PASSWORD" "KEY" ];
    regex.adjective = "(?i).*_(TOKEN|PASSWORD|KEY|AUTHTOKEN)";
  }];
}
