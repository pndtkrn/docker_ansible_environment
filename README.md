This is a program to create a test ansible environment with one control node and one or more client nodes.
You can find the the Dockerfiles for the control and client images in the dockerfiles directory.
Please generate an RSA key as below before you build the images.

ssh-keygen -f ./keys/remote_key -N ""
