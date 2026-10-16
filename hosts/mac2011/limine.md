Antes de rebuildar:
	•	Como o Limine vai se instalar no caminho removível, o NixOS grava em /boot/EFI/BOOT/. Confira que seu ESP está montado em /boot (o hardware-configuration.nix do host deve ter isso; não verifiquei).
	•	Mantenha o pendrive/instalador NixOS ou o Option-key com o disco original à mão. Se o menu não subir, você recupera pelo instalador.
	•	Testar com ```nh os boot``` (não switch): o novo bootloader só entra no próximo reinício, e se falhar você volta pela geração anterior no menu antigo.
