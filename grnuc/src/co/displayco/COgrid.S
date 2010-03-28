class specification COgrid (1:0) of COwindow;





instance COgrid
{
   
    IGRdouble          refer_cross[2];
    IGRint             grids[2];

    IGRint             fit_flag;

    struct GRunit_lock unit_lock;
    IGRlong            size;
};


message wakeup_act ( long * sts );

message setref (IGRint  flag);

message setgrd (IGRint  flag);

message getgragad ( long * sts );

message grd_lk ( long * sts );

message grd_onoff ( long * sts );

message get_sel_gragad ( IGRint flag ; IGRint num_wnds ; IGRint err_flg; IGRint type_gragad);

message get_sel_all_gragad ( IGRint type_gragad );

message fit ( long * sts );

message set_unitlk ( long * sts );

message unitlk_onoff ( long * sts );

message unitlk1 ( long * sts );

message unitlk2 ( long * sts );

end specification COgrid;
