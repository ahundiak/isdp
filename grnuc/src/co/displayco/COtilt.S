class specification COtilt (1:0) of DPvw;




instance COtilt
{
    OM_S_OBJID win_id;
    OMuword    win_os;
    IGRdouble  pt_x, pt_y, pt_z;
};


message store_win_data ( long * sts );

message validate_point ( long * sts );

message get_win ( long * sts );

message rubber_band_pyramid ( long * sts );

message keyin_tilt ( long * sts );

message my_wakeup ();

message my_sleep ();

message my_init ();

end specification COtilt;
