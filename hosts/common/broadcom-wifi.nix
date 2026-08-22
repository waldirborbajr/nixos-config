# hosts/common/broadcom-wifi.nix
#
# hardware.enableRedistributableFirmware — necessário nos dois hosts com
# chipset Wi-Fi Broadcom físico (dell1564: BCM4312, mac2011: BCM4331,
# ambos via driver open-source b43). Deliberadamente NÃO faz parte de
# hosts/common/mac-workstation.nix: macutm/macvmf são VMs sem hardware
# Wi-Fi físico e não devem herdar isso — por isso este módulo é
# importado individualmente por dell1564 e mac2011, não pela cadeia
# mac-workstation/mac-vm-workstation.
{...}: {
  hardware.enableRedistributableFirmware = true;
}
