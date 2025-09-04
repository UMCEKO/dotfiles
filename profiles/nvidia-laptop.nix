{ variables, ... }: {
  # Enable GPU Drivers
  drivers.amdgpu.enable = false;
  drivers.nvidia.enable = true;
  drivers.nvidia-prime = {
    enable = true;
    intelBusID = "${variables.intelID}";
    nvidiaBusID = "${variables.nvidiaID}";
  };
  drivers.intel.enable = false;
  vm.guest-services.enable = false;
}
