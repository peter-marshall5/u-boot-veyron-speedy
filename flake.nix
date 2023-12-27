{
  description = "Build u-boot for veyron-speedy";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = (import nixpkgs) {
        system = "x86_64-linux";
      };
    in
    {
      bin.speedy = pkgs.callPackage ./u-boot-builder.nix {};
    };
}
