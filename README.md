
NOTE: The distributed implementation of this program depends on the init.getif() system call. If the first IP 			address returned is not the address of the machine on the local network, no node can be named correctly. 		Hence nodes can’t connect.
Group Members:

1) Ashvini Patel, UFID: 47949297
2) Dhruv Mahajan, UFID: 42111994

How to run the project:

The Client simulator and server are two different processes. These can be on the same or different machines on the same local network but they must get the correct IP address from the init.getif() system call.

Step 1) 
To run Server
./project4 server

Step 2
To run client simumator
./project4 <numclients> <minimumActivities> <IP Address of the Server>


example ./proejct4 