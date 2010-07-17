/*
	I/STRUCT
*/
class specification VSpmplatCmd (1:0) of VSplplatCmd ;

instance VSpmplatCmd {
	double 	expValue ;
	char   	**oldprtList ;
	int    	oldprtIndex,
		oldprtCount ;
	double	*oldparVal ;
	
} ;


override wakeup ;

override delete ;

override init_cmd ;

override get_modifiable_gadgets ;

override QueryRDB ;

override construct_plate ;

message fillThkCutOffFld( long *msg ) ;

override enable_form ;

override form_notification ;

override updCutOff ;

message SaveList( long *msg ) ;

end specification VSpmplatCmd ;

