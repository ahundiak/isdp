class specification clsr (1:0) of clsq;

instance clsr
{
 channel {(many_to_many,rel_ordered,initial=1,increment=20)}chan_rchan;
 channel {}any_rchan;
};

message printr(  );

end specification clsr;
