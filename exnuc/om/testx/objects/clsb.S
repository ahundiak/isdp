class specification clsb (1:0) of clsa;

instance clsb
{
	char clsb_char;
	channel {(many_to_many)}btoany;
};

message printb( );
message b1();
message b2();
message b3();

end specification clsb;
