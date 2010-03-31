class specification NMedge (1:0) of NMcreated, NMassoc;

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

instance NMedge
{
 IGRuchar props;
 struct GRid refuse, refsf;
 variable IGRboolean reverse[];
};

/* Reject the EMSassoc instance data and the relevant messages.
*/
override EMSassoc;
override
	EMput_info, EMget_info;


/* Reject the GRvg instance data and relevant messages.
*/
override GRvg;
reject
	GRputattr, GRgetattr, GRchghprops, GRchgcolor, GRchgdp, GRchglevel, 
	GRchgstyle, GRchgweight, GRgetsymb, GRputsymb;


/* Reject the GRconnector instance data and the relevant messages.
*/
override GRconnector;
reject
	GRrigidconn, GRflexconn, GRdisconn;


/* Cannot reject GRgraphics because ME.GRgraphics->properties are directly
   accessed in EMSassoc code, in a lot of places. Decided against numerous
   overrides.
   SM Sept 5, 1991.
*/
/**********
override GRgraphics;
reject
	GRgetprops, GRchgprops, GRgethprops;
**********/

from NDnode inherit NDdelete, NDparent_deleted;
from NMcreated inherit GRmksource;

override
	NDdisconnect, 		/* Adjust instance data */
	EMinit_associative, 	/* Always set option EMS_no_const_assoc
				   and EMSinit_dont_store_recomp_info.
				*/
	debug, 
	NDupdate, 		/* Ignore */
	NDmove_to_root;		/* Put in delete batch */

from NDnodein inherit NDconnect, NDdisconnect;

message NMinit(IGRlong *EMmsg; IGRuint nminit_opt;
		IGRuchar nmprops; IGRint num_edges;
		struct GRid *edges, *surfs; IGRboolean *reverse;
		struct GRmd_env *env; struct NMgmSSI *ssi);

message NMconnect_edges(IGRlong *EMmsg; IGRint num_edges;
		        struct GRid *edges, *surfs; IGRboolean *reverse;
			struct GRmd_env *env; struct NMgmSSI *ssi;
			IGRuint connect_opt);

message NMdisconnect_edges(IGRlong *EMmsg; IGRint num_edges;
		        struct GRid *edges, *surfs; struct GRmd_env *env;
		        IGRuint connect_opt; struct NMgmSSI *ssi);
		
message NMreset_refuse(IGRlong *EMmsg; struct GRid *refuse, *refsf;
		      struct GRmd_env *env);

message NMget_edge_info(IGRlong *EMmsg; IGRint *num_edges; struct GRid **edges,
		       *refedge, *refsf; IGRboolean **reverse;
		       IGRuint nmquery_opt);

message NMcheck(IGRlong *EMmsg; struct GRid *refuse, *refsf);

message NMprop(IGRlong *EMmsg; IGRuchar options, *props);

message NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options);

message NMedge_reversed(IGRlong *EMmsg; struct GRid *edgeid);

end specification NMedge;
