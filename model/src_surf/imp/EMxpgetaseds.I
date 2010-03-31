/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSxsection.h"

/*
 DESCRIPTION
   This method returns the edges of the cross section plane that 
   are associated to the model's surfaces.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method EMget_associated_edges (
        IGRlong            *EMmsg;
        GRobjid            **act_eds, **inact_eds;
        IGRint             *num_act_eds, *num_inact_eds,
                           *act_eds_arrsz, *inact_eds_arrsz;
        IGRushort  options;
        IGRint             tree_depth)
{
  struct GRid  *ed_GRids = NULL;
  IGRlong      OM_stat, mthd_stat, rc;
  IGRint       num_eds = 0, array_size = 0, i, j;
  IGRboolean   ed_exists;
  extern void  EFmemory_allocation();

  /* **************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * o Get my edges.
   * o Add the active edges to the act_eds list.
   */

  if (options & EMSXS_ACT_EDGES)
  {
   OM_stat = om$send (msg = message EMSsubbs.EMget_edges (&mthd_stat,
                      OM_K_MAXINT, EMS_OPT_ALL, NULL, &ed_GRids, 
                      &array_size, &num_eds),
                     targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
   
   if ( (*num_act_eds + num_eds) > *act_eds_arrsz)
   {
     EFmemory_allocation (&rc, (IGRchar **) act_eds, 
                          (*num_act_eds + num_eds), act_eds_arrsz, 
                          sizeof(GRobjid), 10, 5);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   } /* if ( (*num_act_eds + num_eds) > *act_eds_arrsz) */

   for (i = 0; i < num_eds; i++)
   {
     ed_exists = FALSE;
     for (j = 0; j < *num_act_eds; j++)
     {
       if (ed_GRids[i].objid == (*act_eds)[j])
       {
         ed_exists = TRUE;      break;
       }
     } /* for (j = 0; j < *num_act_eds; j++) */

     if (!ed_exists)
      (*act_eds)[(*num_act_eds)++] = ed_GRids[i].objid;

   } /* for (i = 0; i < num_eds; i++) */

  } /* if (options & EMSXS_ACT_EDGES) */

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsplane.EMget_associated_edges");
   if (ed_GRids) om$dealloc (ptr = ed_GRids);
   return (OM_stat);
  
}

end implementation EMSxsplane;
