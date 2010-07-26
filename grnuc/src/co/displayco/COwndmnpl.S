class specification COwndmnpl (1:0) of COwindow;




instance COwndmnpl
{
    IGRlong mask;
    IGRdouble act_z[3];
    IGRshort send_flags;
    struct GRevent event0; 
	IGRshort	defaults[6];
	IGRshort	def_depths[2];
};


message wakeup_act ( long * sts );

message get_act_dep ( long * sts );

message get_wnd ( long * sts );

message idnt_wnd1 ( long * sts );

message crt_window ( long * sts );

message get_wndctr ( long * sts );

message dspl ( long * sts );

message init_depths ( long * sts );

message pntdepths (IGRint  flag);

message init_vwvols ( long * sts );

message vwvols (IGRint  flag);

message storepnts (IGRint  index);

message idnt_wnd ( long * sts );

message wnd_off ( long * sts );

message wnd_on ( long * sts );

message get_wnd_name ( long * sts );

message rnm_wnd ( long * sts );

message get_pt11 ( long * sts );

message get_pt22 ( long * sts );

message idntfywnd ( long * sts );

message get_all_graphic_gadgets ( long * sts );

message check_wnd_name ( long * sts );

message verify_window_name (IGRint *sts; IGRboolean use_default);

end specification COwndmnpl;
