class specification clsk (1:0) of Root;

instance clsk
{
 channel {}k_chan1;
 channel {}k_chan2;
 channel {(initial=10)}k_chan3;
};

message printk(  );

end specification clsk;
