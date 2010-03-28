/* #######################    APOGEE COMPILED   ######################## */
/*
Name
   GRdv_sync_tan_ed_disp


Description
   IGRint orient is in the instance for GRdvattach.  Two of its bits
   are : GR_DV_TAN_ED_DIS_OFF_CURRENT and GR_DV_TAN_ED_DIS_OFF_AFTER_PDD.
   This method will assign the value of the second to the first.


Arguments
   *msg           IGRlong          completion code 


History
   Jack  07/10/92  Creation

*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "detaildef.h"
#include "dpdef.h"
#include "igrdef.h"
#include "dpmacros.h"

from GRdvattach import GRget_put_orientation;


method GRdv_sync_tan_ed_disp( IGRlong *msg;
                              struct GRid *window )

{
   IGRlong  status;
   struct GRid attach_id;
   IGRint   get_flag,
            orient;
   IGRlong  level_mask[32];
   IGRlong  bytes_returned = 0, 
            which_error;
  struct var_list var_list[2];
   
   /*
    * Get the level(layer) on/off mask.
    */

   var_list[0].var = LEVELS;
   var_list[0].var_ptr = (IGRchar *)level_mask;
   var_list[0].num_bytes = sizeof(IGRlong) * 32;
   var_list[0].bytes_returned = &bytes_returned;
   var_list[1].var = END_PARAM;

   status = dp$inq_set_gragad(msg = msg,
                              osnum = window->osnum,
                              gragad_objid = window->objid,
                              which_error = &which_error,
                              var_list = var_list);

   if(!(DPlevel_check(me->level,level_mask)))
     { /* if the level for this drawing view is off then leave */
       goto wrapup;
     }


/* get the GRid of the drawing view attachment connected
 * to this drawing view 
 */
   status = om$send(msg = message GRdrawview.GRget_drawing_attachment_id
                                  ( msg, 
                                   &attach_id),
                    senderid = my_id,
                    targetos = OM_Gw_current_OS,
                    targetid = my_id);
   if(! (1 & status & *msg)) goto wrapup;

   orient = 0;  
   /* the tangent edge display flags  is in the orientation
      int for the drawing view attachment.
    */  
     get_flag = 1;
     status = om$send(msg = message GRdvattach.GRget_put_orientation
                                         ( msg, 
                                           get_flag,
                                          &orient),
                      senderid = my_id,
                      targetos = attach_id.osnum,
                      targetid = attach_id.objid );
     if(! (1 & status & *msg)) goto wrapup;
      
     /*
      * sync up the two tangent edge display bits
      */     
     if(orient & GR_DV_TAN_ED_DIS_OFF_AFTER_PDD)
         orient |= GR_DV_TAN_ED_DIS_OFF_CURRENT; /* turn it on */
     else
         orient &= ~(GR_DV_TAN_ED_DIS_OFF_CURRENT); /* turn it off */

     /*
      * put the new bit values into the instance data of the drawing
      * view attachment.
      */
     get_flag = 0;
     status = om$send(msg = message GRdvattach.GRget_put_orientation
                                         ( msg, 
                                           get_flag,
                                          &orient),
                      senderid = my_id,
                      targetos = attach_id.osnum,
                      targetid = attach_id.objid );
     if(! (1 & status & *msg)) goto wrapup;


wrapup:
    return(status);
}
end implementation GRdrawview;

