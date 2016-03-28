url=${1:-"https://raw.githubusercontent.com/wav/resources/master/bash"}

source2shUrl="$url/source2.sh"
source2confUrl="$url/source2.conf.template"

profileDir=~/.profile

[[ ! -d "$profileDir" ]] && mkdir -p "$profileDir"

if [ ! -f "$source2shUrl" ]; then
	echo "Downloading '$source2shUrl'"
	curl -s "$source2shUrl" > "$profileDir/source2.sh" || exit 1
else
	cp "$source2shUrl" "$profileDir/source2.sh"
fi

cat ~/.bash_profile | grep -oE '^.*## SOURCE2 ##$' > /dev/null || \
  echo "[[ -s \"$profileDir/source2.sh\" ]] && . \"$profileDir/source2.sh\"; ## SOURCE2 ##" >> ~/.bash_profile

if [ ! -s "$profileDir/source2.conf" ]; then
	if [ ! -f "$source2confUrl" ]; then
		echo "Downloading '$source2confUrl'"
		curl -s "$source2confUrl" > "$profileDir/source2.conf" || exit 1
	else
		cp "$source2confUrl" "$profileDir/source2.conf"
	fi
	. "$profileDir/source2.sh"
	source2::pull -a
fi

echo "Done. Run \`source $profileDir/source2.sh\` or open a new session, then run \`source2::help\`"