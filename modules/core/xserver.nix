{ variables, ... }: {
  services.xserver = {
    enable = false;
    xkb = {
      layout = "${variables.keyboardLayout}";
      variant = "";
    };
  };
}
