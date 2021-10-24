_deploy (){
	INVENTORY="../hosts"
	LIST="nodes: [node0001"
	
	echo "[all]" > $INVENTORY
	for ((NUM=2; NUM<=$CLIENTS; NUM++))
	do
		if [ $NUM -lt 10 ]
		then
			NODE=node000${NUM}
		else
			NODE=node00${NUM}
		fi
		LIST="${LIST},${NODE}"
		echo $NODE >> $INVENTORY
	done
	LIST="${LIST}]"
	echo "---" > nodelist
	echo $LIST >> nodelist
	echo "..." >> nodelist
	ansible-playbook deploy_container.yml --tags deploy
	
	echo "[all:vars]" >> $INVENTORY
	echo "ansible_connection=docker" >> $INVENTORY
}

_input () {
	while true
	do
		echo -ne "Number of containers to deploy: "; read CLIENTS
		TOTAL_WORDS=$(echo $CLIENTS | wc -w)
		if [[ $TOTAL_WORDS -eq 1 && $CLIENTS =~ [0-9] ]]
		then
			_deploy
			exit 0
		fi
	done
}

_input

