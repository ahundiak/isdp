class specification clsm (1:0) of Root;

instance clsm
{
 int anum;
 channel {(many_to_many,rel_ordered,initial=1,increment=20)}chan_m1;
 channel {}chan_m2;
};

override delete;

end specification clsm;
