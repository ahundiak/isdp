class specification NMfeaturelp (1:0) of EMSgraloop;

#include "nmdef.h"
#include "nmchandef.h"
#include "nm.h"

instance NMfeaturelp
{
 GRobjid		nesting_parent;
 IGRuchar		nmprops;
};

from EMSloop inherit EMget_edges;

override debug, 
	 EMintcopy, 
	 EMnesting, 	  /* Return EMS_I_Ambiguous */
	 delete, 	  /* Delete only if directed by the creator */
	 EMupdate_feature, /* Ignore. I am forced to do this because inspite
			      of using EMGL_HOLD_UPDATE property, the NMflp 
			      seems to get updated along with rest of the
			      feature loops.
			   */
	 EMdisplay, 	/* Display with increased weight. */
	 EMgetsurface_info,  /* If no direct path, try thru nesting parent*/
	 EMpt_location; /* try onedge, onvtx, or set to unknown */
	
message NMflpinit(IGRlong *EMmsg; struct EMSpartolbasis *partol;
		  struct GRmd_env *env;
		 IGRushort lp_props; IGRuchar helper_props; 
		 GRobjid surf_id, parent_plp_id; IGRushort options;
		 struct NMgmSSI *ssi);

message NMget_nesting_parent(IGRlong *EMmsg; GRobjid *parent; 
			     IGRboolean get_it);

message NMprop(IGRlong *EMmsg; IGRuchar options, *props);

end specification NMfeaturelp;
