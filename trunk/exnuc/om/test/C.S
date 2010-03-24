class specification C (1:0) of Root;

instance C
{
	int num;
	channel {B;}   scb;
	channel {A,ResA;}   sca;
	channel {A,B;} sbca;
};

message assign_c ( int num );

message show();

message make_connect();

end specification C;
