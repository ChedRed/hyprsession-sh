helpl="
				hyprsession.sh version 1.0
				==========================
    Usage
    -----
	hyprsession [action] <path>
	hyprsession option [option] <value>

    Parameters
    ----------
	[action]
	 >> reboot		Save a session and reboot the system
	 >> save		Save a session
	 >> load		Load a session

	<path>			Defines an optional path that
				 hyprsession will use as a session
	
	[option]
	 >> autosave		Save a session automatically (3600; seconds)
	 >> path		Define the default path for hyprsession
				 to use (~/.config/hypr/hypr.session; string)
	
	<value>			Defines the value that an option is set to
"


IFS=$'\n'
autosave=3600
path=~/.config/hypr/hypr.session
if [ -f ~/.config/hypr/hyprsession.conf ]; then
	config=$(<~/.config/hypr/hyprsession.conf)
	parameter=""
	for line in $config; do
		IFS=$':'
		
		for parameters in $line; do
			temparam=$(echo $parameters | xargs)
			if [[ "autosavepath" == *$temparam* ]]; then
				parameter=$temparam
			else
				if [[ $parameter == "autosave" ]]; then
					autosave=$temparam
				elif [[ $parameter == "path" ]]; then
					path=$temparam
				fi
			fi
		done
	done
	IFS=$'\n'
else
	echo "autosave: 3600
path: ~/.config/hypr/hypr.session">~/.config/hypr/hyprsession.conf
fi


if	[[ $1 == "save" || $1 == "reboot" ]];	then
	monitor=""
	workspace=""
	move=""
	size=""
	pin=""
	float=""
	fullscreen=""
	clientfullscreen=""
	run=""
	>$(eval echo $path)
	for line in $(hyprctl clients); do
		if [[ $line =~ ^Window ]] && [[ $run != "" ]]; then
			echo "[$monitor;$workspace;$move;$size;$pin;$float;$fullscreen;$clientfullscreen] $run">>$(eval echo $path)
			monitor=""
			workspace=""
			move=""
			size=""
			pin=""
			float=""
			fullscreen=""
			clientfullscreen=""
			run=""
		else
			value=$(echo $line | xargs)
			if	[[ $value =~ ^monitor: ]];		then
				monitor="monitor${value:8}"
			elif	[[ $value =~ ^workspace: ]];		then
				preworkspace=${value:10}
				workspace="workspace${preworkspace%%(*}silent"
			elif	[[ $value =~ ^at: ]];			then
				move="move${value:3}"
			elif	[[ $value =~ ^size: ]];			then
				size="size${value:5}"
			elif	[[ $value == "pinned: 1" ]];		then
				pin="pin"
			elif	[[ $value == "floating: 1" ]];		then
				float="float"
			elif	[[ $value == "fullscreen: 1" ]];	then
				fullscreen="fullscreen"
			elif	[[ $value == "fullscreenClient: 1" ]];	then
				clientfullscreen="fakefullscreen"
			elif	[[ $value =~ ^pid: ]];			then
				
				run=$(ps --no-headers -o cmd -p ${value:5})
			fi
		fi
	done
	echo "[$monitor;$workspace;$move;$size;$pin;$float;$fullscreen;$clientfullscreen] $run">>$(eval echo $path)
	if [[ $1 == "reboot" ]]; then
		reboot
	fi

elif	[[ $1 == "load" ]];	then
	for line in $(cat $(eval echo $path)); do
		IFS=' '
		hyprctl dispatch -- exec $line
	done

elif	[[ $1 == "option" ]];	then
	
	exit 0

else
	printf "%s\n" "$helpl"
	exit 0
fi
