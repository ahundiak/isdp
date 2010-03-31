class specification NMnonmanist (1:0) of NMnonmanigm;

#include "nm.h"

instance NMnonmanist
{
 IGRdouble lentol, cht;
};



/* Reject the EMSassoc instance data.
*/
override EMSassoc;

/**************** Get ignore - implementation from NMnonmani.
reject
	EMput_info, 
	EMget_info;
***************************/
	
reject
	NMperform_boolean;
	
override
	GRgetobjinfo, 
	NMreexecute, 
	debug;

message NMperform_stitch(IGRlong *EMmsg;
                    	 IGRint num_comps;
                    	 struct GRid *comps;
                    	 struct GRmd_env *mod_info;
		    	 struct EMSstitch_info *in_pairs;
		    	 IGRint in_num_pairs;
		    	 struct EMSstitch_geominfo *geom;
		         struct NMgmSSI *in_ssi;
		    	 IGRushort makecs_options, nm_options;
			 struct GRvg_construct *construct; 
                         IGRchar *status_str);


end specification NMnonmanist;
