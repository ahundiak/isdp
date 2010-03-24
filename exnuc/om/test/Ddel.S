class specification Ddel  (1:0) of Root;

/*
/* delete an instance. objects will send a message requesting to be
/* deleted. they will include their classname so that we can use
/* their method for deletion. 
*/
message MAINDEL();

message Telld(char classname; int defer; int times);


end specification Ddel;
   
