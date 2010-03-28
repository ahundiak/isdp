/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   DYtranslate_element_init

Description
   This function is used to display an element in dynamics that
   tracks the cursor.


Arguments
   origin      IGRpoint       The origin of the object
   obj_id      struct GRid    The object to be put into dynamics

Return Values
   OM_S_SUCCESS

History
   Gray Winn   03/04/88    Creation Date
   SCW         07/08/02    ANSI conversion
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "msdef.h"
#include "madef.h"
#include "growner.h"
#include "grgs.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "OMerrordef.h"

extern IGRboolean DPdlist_in_fold_dynamics;

struct dyn_args
{
   IGRpoint             origin;
   struct GRid          obj_id;
   struct GRmdenv_info  env;
};

IGRint DYtranslate_element_init (origin, obj_id)
IGRpoint          origin;
struct GRid       *obj_id;
{
IGRlong           ret_msg;
IGRint            i;          
IGRboolean        dyn_on;       /* is dynamics on?             */
IGRboolean        inquire = 1;  /* inquire from DPdynflags     */
struct dyn_args   data;         /* arguments passed to DYmove  */

IGRint   DYtranslate_element();

   /*
    *  if dynamics is off then exit
    */

   DPdynflags (&ret_msg, &inquire, &dyn_on, NULL);
   if (!dyn_on)
   {
      return (OM_S_SUCCESS);
   }

   data.obj_id = *obj_id;
   MAidmx(&ret_msg, data.env.matrix);
   for (i=0; i < 3; ++i) data.origin[i] = origin[i];

   DPdlist_in_fold_dynamics = TRUE;
   dp$dynamics (dyn_fun = DYtranslate_element, information = &data);
   DPdlist_in_fold_dynamics = FALSE;

   return (OM_S_SUCCESS);
}


#argsused
IGRint DYtranslate_element (dptr, point, mtx, objects, num_objects, 
            buffers, num_buffers, in_dummy1, in_dummy2, in_dummy3, 
            out_dummy1, out_dummy2, out_dummy3)
struct dyn_args       *dptr;
struct EX_button      *point;
IGRdouble             *mtx;
struct GRid          **objects;
IGRint                *num_objects;
struct DPele_header  **buffers;
IGRint                *num_buffers;
IGRchar               *in_dummy1;
IGRchar               *in_dummy2;
IGRchar               *in_dummy3;
IGRchar              **out_dummy1;
struct GRmdenv_info  **out_dummy2;
IGRchar              **out_dummy3;
{
IGRlong              msg;
   dptr->env.matrix[3] = point->x - dptr->origin[0];
   dptr->env.matrix[7] = point->y - dptr->origin[1];
   dptr->env.matrix[11] = point->z - dptr->origin[2];
   MAtypemx (&msg, dptr->env.matrix, &dptr->env.matrix_type);

   /*
    *  set up the buffer pointer
    */

   *objects = &dptr->obj_id;
   *num_objects = 1;
   *out_dummy2 = &dptr->env;
   return (msg);
}
end implementation Root;
