trap _exit_clean EXIT

DEPLOYED=0

_banner () {
	echo -e "==========================================================="
	echo -e "Ansible Environment Deployment Program"
	echo -e "==========================================================="
}

_exit_clean () {
	if [ $DEPLOYED -eq 1 ]
	then
		echo -e "\nRemoving components\n"
		docker container rm -f $ANSIBLE_CONTAINER
		for ((NUM=1; NUM<=$CLIENTS; NUM++))
		do
			if [ $NUM -lt 10 ]
			then
				NODE=node000${NUM}
			else
				NODE=node00${NUM}
			fi
			docker container rm -f $NODE
		done
		docker network rm $NETWORK
		rm -rf $HOSTS
	fi
}

_quit_check () {
	INPUT=$1
	
	if [[ $INPUT =~ q|Q ]]
	then
		echo -e "Exiting..."
		exit 0
	fi
}

_client_input () {
	DEFAULT_CLIENTS=1
	while true
	do
		echo -ne "Number of client nodes [q]:($DEFAULT_CLIENTS) "; read CLIENTS
		TOTAL_WORDS=$(echo $CLIENTS | wc -w)
		if [ $TOTAL_WORDS -eq 1 ]
		then
			_quit_check $CLIENTS
			if [[ $CLIENTS =~ [0-9] ]]
			then
				break
			else
				echo -e "Invalid input. Please try again."
			fi
		elif [ $TOTAL_WORDS -eq 0 ]
		then
			CLIENTS=$DEFAULT_CLIENTS
			break
		else
			echo -e "Invalid input. Please try again."
		fi
	done
}

_deploy () {
	ANSIBLE_CONTAINER=ansible_control
	ANSIBLE_IMAGE=ansible_control
	CLIENT_IMAGE=ansible_client
	NETWORK=ansible_net
	
	ANSIBLE_CONFIG=ansible.cfg
	HOSTS=hosts
	
	echo -e ""
	echo -e "Creating ansible network."
	_create_network $NETWORK
	echo -e "Deploying control node."
	_create_container $ANSIBLE_CONTAINER $ANSIBLE_IMAGE $NETWORK
	
	echo "[all]" > $HOSTS
	for ((NUM=1; NUM<=$CLIENTS; NUM++))
	do
		if [ $NUM -lt 10 ]
		then
			NODE=node000${NUM}
		else
			NODE=node00${NUM}
		fi
		
		echo -e "Deploying client $NODE."
		_create_container $NODE $CLIENT_IMAGE $NETWORK
		echo "$NODE" >> $HOSTS
	done
	
	DEPLOYED=1
	
	docker cp $HOSTS $ANSIBLE_CONTAINER:/etc/ansible/  &>/dev/null
	
	echo -e "\nEntering shell...\n"
	docker container exec -it $ANSIBLE_CONTAINER bash
}

_create_network () {
	NETWORK=$1
	
	docker network ls | grep $NETWORK
	if [ $? -ne 0 ]
	then
		docker network create $NETWORK &>/dev/null
	fi
}

_create_container () {
	NAME=$1
	IMAGE=$2
	NETWORK=$3
	
	docker container run -d --privileged -it --network $NETWORK --name $NAME $IMAGE &>/dev/null
	sleep 1
	docker container exec $NAME rm -rf /var/run/nologin &>/dev/null
	docker container exec $NAME hostnamectl set-hostname $NAME &>/dev/null
}

_main_menu () {
	_banner
	while true
	do
		_client_input
		_deploy
		exit
	done
}

_main_menu

