class specification clsa (1:0) of Root;

instance clsa
{
 int anum;
 channel {(many_to_many,rel_ordered,initial=1,increment=20)clsb,clsc;}acb;
 channel {}any_chan;
};

message printa( int num );

end specification clsa;
