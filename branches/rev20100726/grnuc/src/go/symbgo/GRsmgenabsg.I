/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgenabsg

Description
   This routine generates the abstract data representation for a 3-D
   double precision symbol header object and places the data in the 
   abstract geometry cache.

    *msg         IGRlong        completion message 
    *matrix_type IGRshort       type of transformation matrix
    matrix       IGRmatrix      transformation matrix
    **absgptr    IGRchar        pointer to abstract geometry buffer

Note
   The matrix should be an Identity matrix.  If the matrx is not 
   identity then MSFAIL will be returned.

History
   DEM/HGW  07/02/86 : Design date and  07/03/86 : Creation date.
   HGW      08/07/86 : Changed terminolgy.
   HGW      09/29/86 : Convert to 4.0
   HGW      11/07/87 : Change for version 1.1
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "madef.h"
#include "gocmacros.h"

method GRgenabsg (IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
                  IGRchar **absgptr)
{
IGRlong           om_msg;
IGRboolean        world;
GRrange           range;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   world = FALSE;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Get the extents of symbol definition header  Note: must do this
    *  before filling in abstract geometry buffer since this will write
    *  in the buffer
    */

   om_msg = om$send(
            msg = message GRgraphics.GRgetrang (msg, NULL, NULL,
            &world, range),
            p_chanselect = &chansel, from = NULL, to = NULL);

   if (om_msg & *msg & 1)
   {
      om_msg = GR3dlbvigenabsg (msg, matrix_type, matrix,
               (me->properties & GRIS_VIEW_INDEP) ? 1 : 0, 
               me->matrix, me->origin, range, &range[3], my_id, 
               OM_Gw_current_OS, absgptr);
   }
   return(om_msg);
}
end implementation GRsmhdr;
