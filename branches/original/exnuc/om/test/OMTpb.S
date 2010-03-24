class specification OMTpb (2:0) of Root;

instance OMTpb
	{

	char *p_key;
	long rec;

	};


message OMTpb_constr( char *p_key; long *rec );

message display( int value; int *ret );

message time_display( );

end specification OMTpb;
 
