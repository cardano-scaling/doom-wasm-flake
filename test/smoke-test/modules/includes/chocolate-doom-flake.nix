{ inputs, ... }: {
  imports = [ (inputs.get-flake ../../../../.).flakeModule ];
}
