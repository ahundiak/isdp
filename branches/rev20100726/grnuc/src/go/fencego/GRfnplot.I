/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRplotyourself

Description
   This method sets up the plot method for the fence object.

Argruments
   *msg           IGRlong           completion code:
   *mod_env       struct GRmd_env   structure containing context info
   *dgn_buf       IGRchar           buffer for output to IGDS design file
   *bs_buf        IGRchar           buffer to contain abstract geometry
   *ele_buf       IGRchar           buffer to contain IGDS formatted ele
   *ele_size      IGRint            # bytes in IGDS element
   *file_des      IGRint            pointer to IGDS design file created
   *max_overflow  IGRdouble         max. abs. value of integer overflow
   *id_info       struct GRid       array of GRid structures
                                    id_info[0] - pointer to window to plot
                                    id_info[1] - pointer to temp object
                                                 used in the clip method
                                                 used for reference file 
                                                 objects
   *scale_factor  IGRdouble         scale factor

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    01/21/88      Creation date.
   Gray Winn    10/07/88    Updated for message interception
\*/

class implementation GRgsmgr;

#include "grimport.h"
#include "msdef.h"

method GRplotyourself(IGRlong *msg; struct GRmd_env *mod_env;
                      IGRchar *dgn_buf; IGRchar *bs_buf; IGRchar *ele_buf; 
                      IGRint *ele_size; IGRint *file_des; 
                      IGRdouble *max_overflow; struct GRid *id_info; 
                      IGRdouble *scale_factor)
{
   *msg = MSSUCC;
   return (OM_S_SUCCESS);
}
end implementation GRgsmgr;
