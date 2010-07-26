class specification COvwangle (1:0) of DPvw;




instance COvwangle
{
    OM_S_OBJID win_id;
    OMuword    win_os;
    IGRdouble pt_x, pt_y, pt_z;
};


message default_angle ( long * sts );

message validate_point ( long * sts );

message save_win_data ( long * sts );

message get_win ( long * sts );

message rubber_band_pyramid ( long * sts );

message keyin_angle ( long * sts );

message my_wakeup ();

message my_sleep ();

message my_init ();

end specification COvwangle;
