{ ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      util-linux = prev.util-linux.override {
        nlsSupport = false;
        translateManpages = false;
      };
    })
  ];
}
