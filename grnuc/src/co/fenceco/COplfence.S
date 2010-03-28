class specification COplfence (1:0) of COnpt;




instance COplfence
{
   struct GRid         window_id;
   IGRushort   properties;
};


override construct_object;

message clear_fill_mode ();

message restore_fill_mode ();

end specification COplfence;
