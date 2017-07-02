# --------------------Colors--------------------
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# --------------------Helper Functions--------------------
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
		echo "${yel}runInBackground${end}: ${red}Process \"${PROCESS_NAME}\" already running in background${end}"
		exit
	fi
	#-----------------------------------------------------

	echo "Starting and running ${mag}${PROCESS_NAME}${end} in background..."
	nohup $1 > logs/${PROCESS_NAME}.log 2>&1 &
	echo $! > logs/${PROCESS_NAME}_pid.txt
	echo "Logs available at ${cyn}logs/${PROCESS_NAME}.log${end}"
}

function stopBackgroundProcess {
	echo "Stoping and removing ${mag}${1}${end}"
	kill -9 `cat logs/${1}_pid.txt`
	rm logs/${1}_pid.txt
}

function setupEnv {
	eval $(docker-machine env dev-machine)
}


operation=$1;
setupEnv


if [ $operation = "backup" ]; then
	setupEnv
	echo "Backing up wordpress database...";
	docker exec fe_guys_server /bin/bash -c "sudo -u www-data wp db export /data/wordpress-db.sql --allow-root "
	docker cp fe_guys_server:/data/wordpress-db.sql ./data/wordpress
	
	echo 'Copying Relevant Files'
	# rm -R ./wordpress/wp-content/uploads
	docker cp fe_guys_server:/app/wp-content/uploads/ ./wordpress/wp-content
fi

if [ $operation = "restore" ]; then
	docker exec fe_guys_server /bin/bash -c  "wp db import /data/wordpress/wordpress-db.sql --allow-root"
fi

if [ $operation = "fix-permissions" ]; then
	echo "Fixing File and Directory Permissions..."
	docker exec fe_guys_server /bin/sh -c "sh /scripts/fix-permissions.sh"
fi


if [ $operation = "sass-start" ]; then
	echo "Starting and running Wordpress Sass Watcher in background..."
	runInBackground 'sass --watch wordpress/wp-content/themes/fe-guys/sass:wordpress/wp-content/themes/fe-guys' 'wordpress-sass'
fi

if [ $operation = "sass-stop" ]; then
	echo "Stoping and removing Wordpress Sass Watcher"
	stopBackgroundProcess 'wordpress-sass'
fi

if [ $operation = "sass-compile" ]; then
	sass wordpress/wp-content/themes/fe-guys/sass/style.scss wordpress/wp-content/themes/fe-guys/style.css
fi