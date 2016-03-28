source2 wav/bash/check.sh

nix() {
	nonEmpty NIXPKGS || return 1
	nix-env -f "$NIXPKGS" $@
}

nix?() {
	nix -qa \* -P | fgrep -i "$1";
}