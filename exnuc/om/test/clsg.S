class specification clsg (1:0) of clsf;

instance clsg
{
 int gnum;
 channel {(many_to_many,rel_ordered,initial=1,increment=20)}chan_gchan;
 channel {}any_gchan;
};

message printg(  );

end specification clsg;
