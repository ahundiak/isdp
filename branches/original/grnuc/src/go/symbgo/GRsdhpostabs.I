/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRpostabsg

Description
   This routine posts the geometry into the instance data for the 3-D 
   floating point symbol definition header.

   *msg         IGRlong             completion message 
   *env_info    struct GRmd_env     data set environment
   *post_info   struct GRpost_info  post information
   *absptr      IGRchar             pointer to abstract geometry
   *newobjid    GRobjid             object id of any new object


Return Values
   MSSUCC    - if successful
   MSFAIL    - if failure

History
   DEM  06/10/86 : Design date.
   DEM  06/10/86 : Creation date.
   HGW  08/14/86 : Changed terminology
   HGW  09/29/86 : Convert to 4.0
   HGW  11/02/87 : Changes for version 1.1
   SCW  07/23/92 : Ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "vardef.h"
#include "grsymdef.h"

method GRpostabsg(IGRlong *msg; struct GRmd_env *ds_info;
                  struct GRpost_info *post_info; IGRchar *absptr; 
                  GRobjid *newobjid)
{
IGRlong              om_msg;
IGRlong              time_stamp;
IGRlong               temp;
IGRint               i;
struct IGRsymboldef  *sdh;        /* pointer to abstract geom */
struct GRvar_list    list[2];

   *msg = MSSUCC;                   /* initialize success       */
   sdh = (struct IGRsymboldef *)absptr;/* type cast to symbol def hdr*/

   for (i = 0; i < 3; ++i)
   {
      me->diag_pt1[i] = sdh->diag_pt1[i];
      me->diag_pt2[i] = sdh->diag_pt2[i];
   }

   /*
    * time stamp the symbol definition header 
    */

   time_stamp = GRtime(0);

   list[0].var = GR_TIME_STAMP;
   list[0].var_ptr = (IGRchar *)&time_stamp;
   list[0].num_bytes = sizeof (IGRlong);
   list[0].bytes_returned = &temp;

   list[1].var = END_PARAM;
   list[1].var_ptr = NULL;
   list[1].num_bytes = NULL;
   list[1].bytes_returned = NULL;

   om_msg = om$send (
            msg = message GRsymbol.GRset_inq_symbol (msg, 1, list),
            targetid = my_id);

   return(OM_S_SUCCESS);
}

end implementation GRsmdfhdr;
