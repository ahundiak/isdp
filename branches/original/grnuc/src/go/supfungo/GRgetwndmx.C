/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRget_window_matrix

Description
   This function will return a window's rotation matrix.

   *msg           IGRlong        return code
   window_osnum   GRspacenum     window's osnum
   window_objid   GRobjid        winodw's objid
   matrix         IGRmatrix      window's rotation matrix.
   *ortho_view    IGRint         flag set if it is an ortho view.

Notes
   The window matrix may be NULL.
   The ortho flag may be NULL.
 
Return Values
   MSSUCC   -  success
   MSFAIL   -  failure

History
   Gray Winn   03/11/88    Creation date
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "var.h"

IGRint GRget_window_matrix (msg, window_osnum, window_objid, matrix,
                            ortho_view)
IGRlong     *msg;
GRspacenum  window_osnum;
GRobjid     window_objid;
IGRmatrix   matrix;
IGRint      *ortho_view;
{
IGRlong           om_msg;
IGRint            ortho;
IGRint            i;
IGRlong           which_error;
IGRmatrix         tmatrix;
struct var_list   var_list[3];

   *msg = MSSUCC;

   var_list[0].var            = VIEW_ROTATION;
   var_list[0].var_ptr        = (char *)tmatrix;
   var_list[0].num_bytes      = sizeof(IGRdouble)*16;
   var_list[0].bytes_returned = &which_error;

   var_list[1].var            = GRAGAD_FLAGS;
   var_list[1].var_ptr        = (char *)&ortho;
   var_list[1].num_bytes      = sizeof (IGRint);
   var_list[1].bytes_returned = &which_error;

   var_list[2].var            = END_PARAM;
   var_list[2].var_ptr        = NULL;
   var_list[2].num_bytes      = 0;
   var_list[2].bytes_returned = NULL;

   om_msg = dp$inq_set_gragad(msg = msg, osnum = window_osnum,
            gragad_objid = window_objid, which_error = &which_error,
            var_list = var_list);

   if (om_msg & *msg & 1)
   {
      if (ortho_view)
      {
         *ortho_view = ortho & AXIS_WLD_ALIGN;
      }

      if (matrix)
      {
         for (i=0; i < 16; ++i)
         {
            matrix[i] = tmatrix[i];
         }
      }
   }
   return(om_msg);
}
