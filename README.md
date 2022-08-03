container_control:
-----------------

This is a program to create a test ansible environment with one control node and one or more client nodes as docker cotnainers.
Here both the control node and clients are docker containers.
You can find the the Dockerfiles for the control and client images in the dockerfiles directory.
Please generate an RSA key as below before you build the images. Run these commands inside the container_coltrol directory on in which ever directory the Dockerfile(s) are present.

mkdir keys; ssh-keygen -f ./keys/remote_key -N ""

host_control:
-------------

This is a program to create docker container clients. Here only the clients are docker containers.
The control node is the host itself and must have ansible installed on it.
Run start.sh to deploy the containers and stop.sh to stop them.
