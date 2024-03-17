_:
let
  mkCheck = { system }: {
    ${system} = {

    };
  };

  mkChecks = { config-overrides ? { }, package-overrides ? { }, systems ? [ ] }:
    builtins.foldl' (acc: system:
      acc // (mkCheck { inherit config-overrides package-overrides system; }))
    { } systems;

in { inherit mkCheck mkChecks; }
