class specification COfillobj (1:0) of COtools, CEO_GSLOCATE;




instance COfillobj
{
	IGRshort what_mode;
};


message getdpb_props ( long * sts );

message setfill_type ( long * sts );

message obj_fill ( long * sts );

end specification COfillobj;
