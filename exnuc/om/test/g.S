class specification g (1:0) of Root;

instance g
{
     int  grins;
     channel { (one_to_one) }  one;
     channel { (many_to_many, initial=5, increment=10) } many;
};

message send_chan ();

message answer ();

override unknown;

end specification g;
