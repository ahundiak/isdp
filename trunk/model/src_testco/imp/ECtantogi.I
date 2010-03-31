/* ###################   APOGEE COMPILED   ################## */
class implementation ECtantog;

/*

   Command:       Toggle Tangent Edge Display 
   Specification: 10017b
   
   Notes: 
   This command object will toggle on/off the display of tangent edges
   on a per drawing view basis.  By default, tangent edge display will
   be supressed, so this command will primarily be used to toggle the
   display on.

   History:
   June 12 1992  Jack  Creation
   08/14/94      scw   clarified sleep method

*/

#include "EMS.h"
#include "EMSopt.h"
#include <string.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "codef.h"
#include "codpdef.h"
#include "EMSdpb.h"
# include "EMSlogic.h"      /* EMSokay */
#include "igrdef.h"
#include "dpmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "grmsg.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "detaildef.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "OMprimitives.h"

# ifndef DEBUG
# define DEBUG 0
# endif

/* states */
#define BEGIN_STATE        0
#define IDENTIFY_WINDOW    1
#define DISPLAY_COORD_SYSTEMS 2
#define LOC_DRAWING_VIEW   3


from GRdrawview import GRget_drawing_attachment_id;
from GRdvattach import GRget_put_orientation;
from GRgraphics import GRdisplay;
from OMObjSpace import pass;
from GRdrawview import GRdv_coord_sys_display;

extern GRcomponent_pass_fun();

method init (IGRint type; IGRchar *string)
{

 IGRint  size_buf,
         bytes_ret;
 IGRlong EMmsg=0,
         status=0;

  ME.super_cmd->mytype = type;

  me->window.osnum = 0;
  me->window.objid = NULL_OBJID;  

  size_buf = sizeof(struct GRmd_env);
  gr$get_module_env(msg    = &EMmsg,
                    sizbuf = &size_buf,
                    buffer = &me->md_env,
                    nret   = &bytes_ret);

   status = om$osnum_to_oso_objid(osnum = me->md_env.md_id.osnum,
                                  p_objid = &me->os_objid);


  return (OM_S_SUCCESS);
}

method wakeup (IGRint pos)
{

  ex$message(msgnumb = EM_M_TgTnEdDs )
  
  return (OM_S_SUCCESS);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{


  IGRlong EMmsg=0,
          status=0,
          locate_mask=0, 
          accept_mask=0, 
          display_flag,
          window_mask=0;
  struct GRlc_locate attributes;
  IGRint  get_flag,
          orient;
  struct GRid attach_id; 
  OMuword         r_classes[5], e_classes[5];
  struct GRevent  accept_event,
                  window_event;
  OM_S_CLASSLIST  rtree_classes, eligible_classes;  
  IGRlong         object_was_located;  
  IGRuchar  style,
            weight;
  IGRint    flag=0;          
  OM_S_CLASSLIST classlist;
  OMuword classid;


 do
  {
   switch(ME.super_cmd->state)
    {

   case BEGIN_STATE:
     /*
      * if a window has not been defined yet, prompt for one
      */
     if((me->window.objid == NULL_OBJID) && (me->window.osnum == 0))
       ME.super_cmd->state = IDENTIFY_WINDOW;
     else
       ME.super_cmd->state = DISPLAY_COORD_SYSTEMS;

     break;

   case IDENTIFY_WINDOW:
     /*
      * if we got to this case because of a backup, we assume
      * the user located the wrong window and we need to clear
      * the coordinate system display of that window before 
      * picking a new one.
      */
     if((me->window.objid != NULL_OBJID) && (me->window.osnum != 0))
      {
       /*
        * build the class list
        */
       classlist.w_count = 1; 
       classlist.w_flags = 0;
       classid =  OPP_GRdrawview_class_id;
       classlist.p_classes = &classid;

       style = 0;
       weight = 0;
       flag |= GR_DV_CS_RESTORE;


       /*
        * restore the original display of the coordinate system for 
        * every drawing view in the master object space.
        */
       status = om$send(msg = message OMObjSpace.pass
                               (&classlist, 
                                 OM_e_wrt_object,
                                 message GRdrawview.GRdv_coord_sys_display(
                                                      &EMmsg,
                                                       style,
                                                       weight,
                                                      &me->md_env,
                                                      &me->window,
                                                       flag) ),
                    senderid = my_id,
                    targetos = me->md_env.md_id.osnum,
                    targetid = me->os_objid);
       if(! (1 & status & EMmsg)) goto wrapup;
      }
     else
      { 
       /* locate a window */

       window_mask |= GRm_DATA;
       status = co$getevent (msg = &EMmsg,
                             event_mask = window_mask,
                             msgnum = GR_P_SelWin,
                             response = response,
                             response_data = response_data,
                             event = &window_event);
       if(! (1 & status & EMmsg)) 
         break; /* try to get the window again */
        if (window_event.response IS EX_DATA)
         {
           me->window.objid = window_event.event.button.objid;
           me->window.osnum = window_event.event.button.osnum; 
         }
      }

     ME.super_cmd->state = DISPLAY_COORD_SYSTEMS;

     break;

   case DISPLAY_COORD_SYSTEMS:

       /*
        * build the class list
        */
       classlist.w_count = 1; 
       classlist.w_flags = 0;
       classid =  OPP_GRdrawview_class_id;
       classlist.p_classes = &classid;


       style = 1;
       weight = 3;
       flag = 0;


       /*
        * display the coordinate systems with an alternate symbology
        * depending on that drawing views tangent edge display mode.
        */
       status = om$send(msg = message OMObjSpace.pass
                               (&classlist, 
                                 OM_e_wrt_object,
                                 message GRdrawview.GRdv_coord_sys_display(
                                                      &EMmsg,
                                                       style,
                                                       weight,
                                                      &me->md_env,
                                                      &me->window,
                                                       flag) ),
                    senderid = my_id,
                    targetos = me->md_env.md_id.osnum,
                    targetid = me->os_objid);
       if(! (1 & status & EMmsg)) goto wrapup;

     ME.super_cmd->state = LOC_DRAWING_VIEW;

     break;


   case LOC_DRAWING_VIEW:

  
      locate_mask = GRm_DATA |  GRm_STRING | GRm_TEXT_VALUE | GRm_RJT_MOVEON
                  | GRm_RESTART | GRm_BACK_UP;
      accept_mask = GRm_DATA | GRm_RESTART;

       display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL;                   /* Erase the hilite plane */
       attributes.properties = 
        LC_LC_NONLC             |       /* Locate locatable and nonloc objects */
        LC_DP_INVIS             |       /* Locate displayable and invis objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* Locate read and write objects */
       attributes.owner_action = 
        LC_FLEX_OWNER  |                /* GRdrawview is a flex owner */
        LC_FLEX_COMP   |                
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */


       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_GRdrawview_class_id;
       e_classes[0] = OPP_GRdrawview_class_id;       

       ex$message(msgnumb = EMS_S_CSdisplayOff )

       status =  lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         event3 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRbdhe,
         locate_key =           EMS_P_EdDrVwMoveOn,
         acc_key =              GR_P_AccDrwVw,
         relocate_key =         EMS_S_DrVwNotFound,
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);

      if (!object_was_located)
       {
        if (accept_event.response IS EX_BACK_UP)
         {
          ME.super_cmd->state = IDENTIFY_WINDOW;
          break;
         }
         dp$erase_hilite(msg = &EMmsg);
         if (accept_event.response IS EX_RJT_MOVEON)
             goto wrapup;
         else 
            return(OM_S_SUCCESS);
       }
      else if (accept_event.response IS GR_UNKNOWN_TYPE)
             {
              dp$erase_hilite(msg = &EMmsg);
              return(OM_S_SUCCESS);
             }
           else 
           {
            /* toggle the display mode of the drawing view */

            /* get the GRid of the drawing view attachment connected
               to this drawing view */
            status = om$send(msg = message GRdrawview.GRget_drawing_attachment_id
                                         (&EMmsg, 
                                          &attach_id),
                          senderid = my_id,
                          targetos = accept_event.located_object[0].located_obj.osnum,
                          targetid = accept_event.located_object[0].located_obj.objid);
            if(! (1 & status & EMmsg)) goto wrapup;


            /* the tangent edge display flag (bit) is in the orientation
               int for the drawing view attachment.
             */  
            get_flag = 1;
            status = om$send(msg = message GRdvattach.GRget_put_orientation
                                         (&EMmsg, 
                                           get_flag,
                                          &orient),
                          senderid = my_id,
                          targetos = attach_id.osnum,
                          targetid = attach_id.objid );
            if(! (1 & status & EMmsg)) goto wrapup;
            

            /* toggle the tangent edge display flag, the flag set
               means that tangent edge display will be supressed 
               when process detail display is run
             */
            if(orient & GR_DV_TAN_ED_DIS_OFF_AFTER_PDD) /* if display is off */
               orient &= ~(GR_DV_TAN_ED_DIS_OFF_AFTER_PDD);  /* turn it on */
            else
               orient |= GR_DV_TAN_ED_DIS_OFF_AFTER_PDD; /* else turn it off */


            /* update the tangent edge display flag */
            get_flag = 0;
            status = om$send(msg = message GRdvattach.GRget_put_orientation
                                         (&EMmsg, 
                                           get_flag,
                                          &orient),
                          senderid = my_id,
                          targetos = attach_id.osnum,
                          targetid = attach_id.objid );
            if(! (1 & status & EMmsg)) goto wrapup;


            /* send a display to the drawing view */

            /*
             * update the display of the drawing view's coordinate system
             * to reflect the what the tangent edge display mode will be
             * when process detail display is run.
             */
            if(orient & GR_DV_TAN_ED_DIS_OFF_AFTER_PDD)
             {
               style = 1;
               weight = 3;
             }
            else
             {
               style = 0;
               weight = 0;
             }
            flag=0;

            status = om$send(msg = message GRdrawview.GRdv_coord_sys_display(
                                                       &EMmsg,
                                                        style,
                                                        weight,
                                                       &me->md_env,
                                                       &me->window, 
                                                        flag),
                    senderid = my_id,     
                    targetid = accept_event.located_object[0].located_obj.objid,
                    targetos = accept_event.located_object[0].located_obj.osnum);
            if(! (1 & EMmsg)) goto wrapup;


          }
        break;   


/*
 * Something has messed up our state table
 */
     default:
#ifdef DEBUG
     printf("default state: problem.");
#endif
      break;
    }
  }
 while(TRUE);

wrapup:
  *response = TERMINATE;

 return (OM_S_SUCCESS);
}

method super_cmd.sleep (IGRint pos)
{

  IGRint flag = 0;
  struct GRmd_env md_env;
  IGRlong EMmsg,
          status;
  OM_S_CLASSLIST classlist;
  OMuword classid;
  IGRuchar style,
           weight;  
  OM_S_OBJID os_objid;

  UI_prompt ("");
  UI_message ("");
  
  
  /* For each drawing view, restore the coordinate
     system display if it was modified
   */  
  if((me->window.objid != NULL_OBJID) && (me->window.osnum != 0))
   {
   /*
    * build the class list
    */
   classlist.w_count = 1; 
   classlist.w_flags = 0;
   classid =  OPP_GRdrawview_class_id;
   classlist.p_classes = &classid;

   style = 0;
   weight = 0;
   flag |= GR_DV_CS_RESTORE;

   status = om$osnum_to_oso_objid(osnum = md_env.md_id.osnum,
                                  p_objid = &os_objid);


   /*
    * restore the original display of the coordinate system for 
    * every drawing view in the master object space.
    */
   status = om$send(msg = message OMObjSpace.pass
                               (&classlist, 
                                 OM_e_wrt_object,
                                 message GRdrawview.GRdv_coord_sys_display(
                                                      &EMmsg,
                                                       style,
                                                       weight,
                                                      &me->md_env,
                                                      &me->window,
                                                       flag) ),
                    senderid = my_id,
                    targetos = me->md_env.md_id.osnum,
                    targetid = me->os_objid);
   if(! (1 & status & EMmsg)) goto wrapup;
   }


wrapup:
  return (OM_S_SUCCESS);
}

end implementation ECtantog;

