class specification NMnonmanibnd (1:0) of NMnonmanigm;

instance NMnonmanibnd
{
 IGRdouble cht;
 IGRint num_sfs;
 variable IGRint num_cvs[];
 variable struct GRid sfid[], cvid[];
};


/* Reject the EMSassoc instance data.
*/
override EMSassoc;

reject
	NMperform_boolean;
	
override
	GRgetobjinfo, 
	NMreexecute, 
	debug, 
	NDconnect;	/* Don't flexibly own curve parents */

message NMcreate_boundaries(IGRlong *EMmsg; IGRint num_sfs;
			    struct GRid *surfid; IGRint *num_cvs_persf;
			    struct EMSdataselect *curves;
			    struct GRmd_env *my_env;
			    struct GRvg_construct *construct;
			    IGRushort map_options,
			    nm_options; IGRchar *status_str);

end specification NMnonmanibnd;
