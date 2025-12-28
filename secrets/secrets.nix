let
  omi_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUuny6M64dFx5ITS6jN7Irb880Kg151/w5kiajF56vC mateusp@omi";
  sonic_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5s9KddIfPBuAJ+BOujG6Ug/gqPULDeSlfQnq7l2M2u mateusp@sonic";
  keys = [omi_key sonic_key];
in {
  "upsmon.pass.age".publicKeys = keys;
}
