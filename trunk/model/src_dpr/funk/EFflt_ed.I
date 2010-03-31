/* ###################   APOGEE COMPILED   ################## */
class implementation  EMSedge;

#include "EMS.h"
/* igr.h replacement */


# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */

#include  "emsmacros.h"
#include  "EMSmsgdef.h"
# include "EMSlogic.h"      /* EMSmsgReport         */
# include "EMStypedef.h"    /* EMSmsgReport         */
# include "EMSommacros.h"   /* ems$get_memory       */

/*
 Notes
      This function filters out the un-necessary edges
      for lift operation.

 History
        RC     11/07/87      Creation date
*/

void EFfilter_edges_for_lift (
	EMmsg,
	num_edges,
	ed_ids)

IGRlong		*EMmsg;
IGRint		*num_edges;
struct	GRid	*ed_ids;

{
   IGRlong 		OM_stat;
   IGRint  		i, j;
   OMuint		count;
   OM_S_CHANSELECT	cm_ed_chan;

   *EMmsg = EMS_S_Success;

   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   i = 0;
   do
   {
	OM_stat = om$get_channel_count (osnum = ed_ids[i].osnum,
		objid = ed_ids[i].objid, p_chanselect = &cm_ed_chan,
		count = &count);
	EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

	if (count == 0)
	{
	  for (j = i+1 ; j < *num_edges; j++)
	     ed_ids[j-1] = ed_ids[j];
	  (*num_edges)--;	   
	}
        else i++;

    } while ( i < *num_edges);

wrapup:

   EMWRAPUP (*EMmsg, OM_stat, "In EFfilter_edges_for_lift");

   return;

} /* end  EFfilter_edges_for_lift  */

end implementation EMSedge;
