action=$1;

# --------------------Colors--------------------
# Usage: echo "${yel}Yellow Text${end}"
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

source dev-env/common.sh

case "$action" in
	start)
		setupEnv
		docker-compose up -d
		echo "${grn}Wordpress running on${end} ${cyn}dev-machine${end}:${yel}8080${end}"
		echo "${grn}PHPMyAdmin running on${end} ${cyn}dev-machine${end}:${yel}22222${end}"
		echo "${grn}Angular App running on${end} ${cyn}dev-machine${end}:${yel}4200${end}"

		read  -n 1 -p "Once Wordpress is loaded, press any key to fix-permissions..." mainmenuinput
		npm run wordpress:fix-permissions
		startSass
		;;
	stop)
		setupEnv
		stopSass
		#stopSync
		docker-compose down
		echo "${red}All App containers have been stopped and removed.${end}"
		;;
	*)
		echo "${red}Action not found${end}"
		exit 
esac

