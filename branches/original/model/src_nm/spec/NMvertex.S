/*
The NMvertex object will group various NMvertex_use objects from various
parametric spaces.

History
	SM	16-Apr-91	Genesis.
*/

class specification NMvertex (1:0) of NMcreated, GA3dpoint;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "exfi.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsbool.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "nmdef.h"
#include "nmchandef.h"
#include "nm.h"

channel vtx_use_channel
{
 (rel_ordered, one_to_many, initial = 1, increment = 1)
 NMvertex_use.to_vtx;
};


instance NMvertex
{
 channel vtx_use_channel	to_vtx_uses;
 IGRuchar			props;
};


from NMcreated inherit GRmksource;

override 
	debug, 
	GRchgprops, 		/* Disable turning locatable on */
	GRdisyourself;		/* Display with increased weight */


message NMinit(IGRlong *EMmsg; IGRuint nminit_opt;
		IGRuchar nmprops; IGRint num;
		struct GRid *vtxuses; IGRpoint xyzpoint; struct NMgmSSI *ssi);
	
message NMconnect_vertex_uses(IGRlong *EMmsg; IGRint num; struct GRid *vtxuses;
			     IGRpoint xyzpoint; struct NMgmSSI *ssi;
			     IGRuint connect_opt);
	
message NMpoint(IGRlong *EMmsg; IGRdouble *point; IGRboolean get);

message NMprop(IGRlong *EMmsg; IGRuchar options, *props);

message NMcheck(IGRlong *EMmsg; struct NMgmSSI *ssi; 
		IGRuint connect_opt);

message NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options);

message NMget_info(IGRlong *EMmsg; IGRint *num_vtxuse; GRobjid **vtxuse;
		   IGRuchar *props; IGRushort options);
		
message NMreplace_vtxuse(IGRlong *EMmsg; GRobjid exist_vtxuse;
		         IGRint num_replacements; GRobjid *replacements;
		         IGRuint connect_opt; struct NMgmSSI *ssi);
		
end specification NMvertex;
