class specification COmiscl (1:0) of COwindow;




instance COmiscl
{
    OM_S_OBJID dplvldir_id;
    GRspacenum mod_osnum;
    IGRint level_mask_buffer[32];
};


message wakeup_act ( long * sts );

message delay_onoff ( long * sts );

message decode_levels ( long * sts );

message err_msg ( long * sts );

message get_string ( long * sts );

message display_levels ( long * sts );

end specification COmiscl;
