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

# --------------------Functions--------------------
function setupEnv {
	startMachineIfOff
	docker-machine env dev-machine
	eval $(docker-machine env dev-machine)
}
export -f setupEnv

function dockerCleanup {
	echo "Remove any stopped containers and dangling volumes."
	docker rm $(docker ps -a -q)
	docker volume rm `docker volume ls -q -f dangling=true`
}
export -f dockerCleanup

function runInBackground {
	#Check that we receive a second argument for process name
	if [ -z "$2" ]; then
		echo "${yel}runInBackground${end}: ${red}Give the process (${1}) a name as the second argument and try again${end}"
		exit
	else
		PROCESS_NAME=$2
	fi
	#-----------------------------------------------------

	#Check if process exists

	if [ -e "logs/${PROCESS_NAME}_pid.txt" ]; then
		processID=`cat logs/${PROCESS_NAME}_pid.txt`
		if ps -p $processID > /dev/null; then
			# Do something knowing the pid exists, i.e. the process with $PID is running
			echo "${yel}runInBackground${end}: ${red}Process \"${PROCESS_NAME}\" already running in background${end}"
			exit
		fi
	fi
	#-----------------------------------------------------

	echo "Starting and running ${mag}${PROCESS_NAME}${end} in background..."
	nohup $1 > logs/${PROCESS_NAME}.log 2>&1 &
	echo $! > logs/${PROCESS_NAME}_pid.txt
	echo "Logs available at ${cyn}logs/${PROCESS_NAME}.log${end}"
}
export -f runInBackground

function stopBackgroundProcess {
	echo "Stoping and removing ${mag}${1}${end}"
	kill -9 `cat logs/${1}_pid.txt`
	rm logs/${1}_pid.txt
}
export -f stopBackgroundProcess

function startSync {
	echo "Syncing files..."
	ttab -t 'Sync: docker-osx-dev' -G 'eval $(docker-machine env dev-machine); docker-osx-dev;'
	echo "${yel}Opening docker-osx-dev in new tab...${end}"
	read  -n 1 -p "Press any key once it's loaded to continue.." mainmenuinput
}
export -f startSync

function startUtilities {
	echo "Starting Utility Containers"
	docker-compose -f dev-env/utilities/docker-compose.yml up -d

	# KIMAI
	KIMAI_PORT="$(docker ps|grep utilities_kimai|sed \
	  's/.*0.0.0.0://g'|sed 's/->.*//g')"
	# Restore DB
	cat dev-env/utilities/data/kimai-backup.sql | docker exec -i utilities_db /usr/bin/mysql -u devenv --password=devenv kimai
	# cat data/kimai-backup.sql  | docker exec -i utilities_db /usr/bin/mysql -u root --password=root kimai

	echo "${grn}Kimai Time-Tracking running on ${end} ${cyn}dev-machine${end}:${yel}${KIMAI_PORT}${end}"

	# PORTAINER
	PORTAINER_PORT="$(docker ps|grep utilities_portainer|sed \
	  's/.*0.0.0.0://g'|sed 's/->.*//g')"
	echo "${grn}Portainer Docker UI running on ${end} ${cyn}dev-machine${end}:${yel}${PORTAINER_PORT}${end}"
}
export -f startUtilities

function stopUtilities {
	echo "Stop added utilities."
	# Backup
	docker exec utilities_db /usr/bin/mysqldump -u devenv --password=devenv kimai > dev-env/utilities/data/kimai-backup.sql
	docker-compose -f dev-env/utilities/docker-compose.yml down
}
export -f stopUtilities

function startDev {
	# Start machine only if it's not running
	MACHINE_STATUS=$(docker-machine status dev-machine)
	if [ "$MACHINE_STATUS" = "Stopped" ]; then
		echo "Starting machine..."
		docker-machine start dev-machine
	fi
	
	startSync
	setupEnv
	startUtilities

	echo "Starting App..."
	#startSync
	# . scripts/app.sh start
	# startSass
}
export -f startDev

function startMachineIfOff {
	# Start machine only if it's not running
	MACHINE_STATUS=$(docker-machine status dev-machine)
	if [ ! "$MACHINE_STATUS" = "Running" ]; then
		echo "Starting machine..."
		docker-machine start dev-machine
	fi
}
export -f startMachineIfOff





