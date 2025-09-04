{ variables, ... }: {
  services = {
    rpcbind.enable = variables.enableNFS;
    nfs.server.enable = variables.enableNFS;
  };
}
