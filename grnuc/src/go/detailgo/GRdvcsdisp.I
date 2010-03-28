/* #######################    APOGEE COMPILED   ######################## */
/*
Name
   GRdv_coord_sys_display


Description
   This method will find out if the tangent edge display for
   this drawing view is intended to be on or off after process
   detail display is run.  If it will be off, the display
   for it's coordinate system will be changed.  Increase the
   weight and change the style.  The restore parm is used to
   specify the call is to restore the c.s. display.

   1. Modify the coordinate system display
      - send display with GRbeheo(will clear all of them)
      - send GRchgweight and GRchgstyle with passed in values
      - send display with GRbdheo
   2. Restore the coordinate system display
      - send display with GRbeheo(will clear all of them)
      - send GRchgweight and GRchgstyle with passed in values
      - send display with GRbd(will only display those with el. dis. on.)

Arguments
   *msg           IGRlong          completion code 
    style         IGRint           new style for the coordinate system   
    weight        IGRint           new weight for the coordinate system
   *md_env        struct GRmd_env  module environment to display in
   *window        struct GRid      window the dv was located in
    flag          IGRint           what to do; defined in detaildef.h


History
   Jack  07/02/92  Creation

*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "detaildef.h"
#include "dpdef.h"
#include "igrdef.h"
#include "dpmacros.h"

from GRdvattach import GRget_put_orientation;

extern IGRint GRcomponent_pass_fun();

method GRdv_coord_sys_display(IGRlong *msg;
                              IGRuchar  style;
                              IGRuchar  weight;
                              struct GRmd_env *md_env;
                              struct GRid *window;
                              IGRint  flag)
{
   IGRlong status, 
           msg2;
   struct GRid attach_id;
   IGRint get_flag,
          orient;
   enum GRdpmode DisplayMode;     
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
   if(!(flag & GR_DV_CS_RESTORE))
    {
     /* the tangent edge display flag (bit) is in the orientation
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
      
    }
            

   /*
    * if we want to change the cs display but tan edge display is on,
    * we don't need to modify the cs display.  just exit.
    */
   if(!(flag & GR_DV_CS_RESTORE)) 
     if(!(orient & GR_DV_TAN_ED_DIS_OFF_AFTER_PDD))
       { /* set to default style and weight just in case the element
          * display for the coordinate system was turned off.
          */
         style = 0;
         weight = 0;
       }
       
   /*
    * first, clear the display 
    * send this pass message to the drawing view which will pass the
    * display message to the coordinate system
    */
   DisplayMode = GRbeheo;
   status = GRcomponent_pass_fun (  msg,
                                    message GRgraphics.GRdisplay (
                                             &msg2,
                                             &md_env->md_env.matrix_type,
                                              md_env->md_env.matrix,
                                             &DisplayMode,
                                             &md_env->md_id),
                                    GR_DV_CS,
                                    my_id,
                                    OM_Gw_current_OS);
   if(! (1 & status & *msg & msg2)) goto wrapup;


   status = GRcomponent_pass_fun ( 
                           msg,
                           message GRvg.GRchgstyle(&msg2,&style),
                           GR_DV_CS,
                           my_id,
                           OM_Gw_current_OS );
   if(! (1 & status & *msg & msg2)) goto wrapup;

   status = GRcomponent_pass_fun ( 
                           msg,
                           message GRvg.GRchgweight(&msg2,&weight),
                           GR_DV_CS,
                           my_id,
                           OM_Gw_current_OS );
   if(! (1 & status & *msg & msg2)) goto wrapup;


   if(flag & GR_DV_CS_RESTORE)
     DisplayMode = GRbd; /* won't get undisplayed elements */
   else
     DisplayMode = GRbdheo; /* will get all of the cs's */

   status = GRcomponent_pass_fun (  msg,
                                    message GRgraphics.GRdisplay (
                                             &msg2,
                                             &md_env->md_env.matrix_type,
                                              md_env->md_env.matrix,
                                             &DisplayMode,
                                             &md_env->md_id),
                                    GR_DV_CS,
                                    my_id,
                                    OM_Gw_current_OS);
   if(! (1 & status & *msg & msg2)) goto wrapup;

wrapup:
    return(status);
}
end implementation GRdrawview;

