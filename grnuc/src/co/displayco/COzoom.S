class specification COzoom (1:0) of DPvw;




instance COzoom
{
    IGRdouble factor;
};


message my_prompt ( long * sts );

message switch_factor ();

message get_win ( long * sts );

message keyin_zoom ();

message centering ();

message my_wakeup ();

message my_sleep ();

message my_init ();

end specification COzoom;
