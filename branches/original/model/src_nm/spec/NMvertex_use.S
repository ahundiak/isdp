/*
This instantiable class represents a 'key point' in the parametrix
space. It could be a the meeting point of various edges or a user specified
feature point.

The NMvertex object will group various NMvertex_use objects from various
parametric spaces.

History
	SM	16-Apr-91	Genesis.
*/

class specification NMvertex_use (1:0) of NMcreated, NMassoc;

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

channel vtx_channel
{
 (many_to_one, initial = 1, increment = 1)
 NMvertex.to_vtx_uses;
};

instance NMvertex_use
{
 channel vtx_channel		to_vtx;
 IGRdouble point[2];
 variable enum EMScvinttype edloc[];
 IGRuchar			props;
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
/*******************
override GRgraphics;
reject
	GRgetprops, GRchgprops, GRgethprops;
*******************/

from NDnode inherit NDdelete, NDparent_deleted;
from NMcreated inherit GRmksource;

override debug, 
	EMinit_associative, 	/* Always set option EMS_no_const_assoc
				   and EMSinit_dont_store_recomp_info.
				*/
	NDdisconnect, 		/* Adjust instance data */
	NDupdate, 		/* Ignore */
	NDmove_to_root;		/* Put in delete batch */

from NDnodein inherit NDconnect;

message NMinit(IGRlong *EMmsg; IGRuint nminit_opt;
		IGRuchar nmprops; IGRint numedges; GRobjid *edges;
		enum EMScvinttype *loc_on_edge; IGRdouble *uvpt; 
		struct NMgmSSI *ssi; struct GRid *sfid);

message NMconnect_edges(IGRlong *EMmsg; IGRint numedges;
		       GRobjid *edges; 
		       enum EMScvinttype *loc_on_edge;
		       IGRdouble *uvpt; IGRuint connect_opt;
		       struct NMgmSSI *ssi);

message NMget_incedence_info(IGRlong *EMmsg; GRobjid refedge; IGRint *numedges;
			     GRobjid **edges;
			     enum EMScvinttype **loc_on_edge;
			     struct GRid *xyzvtx;
			     IGRdouble *uvpt, *xyzpt;
			     IGRuint nmquery_opt);

message NMprop(IGRlong *EMmsg; IGRuchar options, *props);

message NMreplace_edge(IGRlong *EMmsg; GRobjid exist_edgeid; 
		       IGRint num_replacements; GRobjid *replacements;
		       enum EMScvinttype *loc_on_replacements;
		       IGRuint connect_opt; struct NMgmSSI *ssi);

message NMgetsurface_info(IGRlong *EMmsg; GRobjid *sfid; 
			  struct EMSpartolbasis *ptol);
			
message NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options);

message NMcheck(IGRlong *EMmsg);

message NMreset(IGRlong *EMmsg; IGRdouble *newuv; struct GRmd_env *env);

message NMpoint(IGRlong *EMmsg; IGRdouble *point; IGRboolean get);

message NMedge_reversed(IGRlong *EMmsg; struct GRid *edgeid);

end specification NMvertex_use;
