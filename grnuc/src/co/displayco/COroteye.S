class specification COroteye (1:0) of DPvw;




instance COroteye
{
    IGRdouble angle_x,angle_y;
    OM_S_OBJID  win_id;
    OMuword     win_os;
    IGRdouble   pt_x, pt_y, pt_z;
};


message validate_point ( long * sts );

message save_win_data ( long * sts );

message get_win ( long * sts );

message rubber_band_pyramid ( long * sts );

message store_angle1 ( long * sts );

message keyin_roteye ( long * sts );

message my_wakeup ();

message my_sleep ();

message my_init ();

end specification COroteye;
