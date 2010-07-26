class specification k (1:0) of Root;

instance k
{
     int  grins;
     channel { (many_to_one) }  one;
     channel { (many_to_many, initial=50, increment=50) k, z; } many;
     channel { (many_to_many, rel_ordered,
		initial=50, increment=50) k, z, y; } rel;
     channel { (many_to_many, abs_ordered,
		initial=50, increment=50) z, k; } abs;
};

message send_chan ( OM_S_CHANNUM chn; int *ans);

message answer ( int *ans );

end specification k;
