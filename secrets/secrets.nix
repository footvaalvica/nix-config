let
  omi_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUuny6M64dFx5ITS6jN7Irb880Kg151/w5kiajF56vC mateusp@omi";
  sonic_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5s9KddIfPBuAJ+BOujG6Ug/gqPULDeSlfQnq7l2M2u mateusp@sonic";
  system_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWnKAAQTgE/T2IZzMcH+v16pErSf07MVWV5NRB2qhzk root@nixos";
  keys = [omi_key sonic_key system_key];
in {
  "upsmon.pass.age".publicKeys = keys;
  "freshrss.age".publicKeys = keys;
}
