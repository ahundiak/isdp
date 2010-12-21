class specification VDCmdgrset (1:0) of VDS_LOCATE;




instance VDCmdgrset
{
	char	                	name[32];     /* set name  */
        variable struct GRobj_env       locObjs[0]; /* selected objects  */ 
        int                             numobjs;
};


message check_set_name ( long * sts );

message save_set_name ( long * sts );

message make_set_of_objects ( long * sts );

message process_locate ( long * sts );

end specification VDCmdgrset;
