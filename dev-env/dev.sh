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
		startMachineIfOff
		startSync
		setupEnv
		startUtilities

		echo "Starting App..."
		#startSync
		#docker run  --rm --name buy_obd -v "$(pwd)"/src:/var/www/html dynaum/php-apache-composer
		docker-compose up
		startSass
		;;
	sync-start)
		startSync
		;;
	setup-env)
		setupEnv
		;;
	stop)
		setupEnv
		stopSass
		#stopSync

		echo "Gracefully stop apps container and backup databases."
		#. scripts/app.sh stop
		docker-compose down

		stopUtilities

		dockerCleanup

		echo "Stop machine."
		docker-machine stop dev-machine;
		echo "${red}The Dev-Machine and all its apps have been stopped and removed.${end}"
		;;
	sass-start)
		startSass
		;;
	sass-stop)
		stopSass
		;;
	setup-env)
		setupEnv
		;;
	*)
		echo "${red}Action not found${end}"
		exit 
esac

