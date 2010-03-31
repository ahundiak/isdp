/* ###################   APOGEE COMPILED   ################## */
/*
    History

       dhm     01/31/92   added GRm_TEXT_VALUE to the locate_mask so that
                          reference planes can be located by name.
       scw     08/15/94   clarified sleep method
*/

class implementation EConoff;

#include <stdio.h>                      /* Needed for print statements */
#include <math.h>
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "lcmacros.h"

#include "exmacros.h"                   /* Has ex$putque */
#include "maerr.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "emsdef.h"

#include "ECcmd.h"
#include "ECmsg.h"

#include "actparam.h"


# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

#define DISPLAY_ON 0
#define DISPLAY_OFF 1
#define ACTIVE_REF 2

#define IDENTIFY_DATUM 1
#define LOCATE_WINDOW 2
#define PROCESS 3
#define MAX_NUM_WIN 32

from GRgraphics   import GRdisplay,GRchgprops;
from EMSdatpln import EMtoggle_on_off, EMget_pln_info;
from EMSdatplnmgr import EMget_datums, EMactivate, EMget_info;

extern OMuword OPP_EMSdatpln_class_id,
               OPP_SKmgr_class_id,
               OPP_GRbspline_class_id;

static IGRboolean aflag;
static GRspacenum osn;


method execute(int *response; char *response_data; int pos)
{
 IGRboolean turn_on;
 IGRlong sts,msg;
 IGRint i,locate_mask, accept_mask,display_flag;
 enum GRdpmode display_mode;
 struct GRlc_locate attributes;
 OMuword r_classes[5], e_classes[5];
 OM_S_CLASSLIST        rtree_classes, eligible_classes;
 struct GRevent accept_event;
 struct GRid wingrid[MAX_NUM_WIN];
 IGRint total_numwin, numwin,eventmask;

 IGRlong RFlocate_ref_plane_handler();

 sts = OM_S_SUCCESS;
 msg = MSSUCC;
 aflag = pwIsActivationOn();

 if (me->mytype == DISPLAY_ON)
 {
    ex$message (field=MESSAGE_FIELD, 
                /* Turn reference plane display on */
                msgnumb = EM_M_TrnRfPlDsOn,
                justification=CENTER_JUS );
  turn_on = TRUE;
 }
 else if (me->mytype == DISPLAY_OFF)
 {
    ex$message (field=MESSAGE_FIELD, 
                /* Turn reference plane display off */
                msgnumb = EM_M_TrnRfPlDsOff,
                justification=CENTER_JUS );
  turn_on = FALSE;
 }
 else
 {
    ex$message (field=MESSAGE_FIELD, 
                /* Select current reference plane */
                msgnumb = EM_M_SlAcRfPl,
                justification=CENTER_JUS );

  turn_on = TRUE;
 }


 display_flag = 
      ELEM_HILIGHT                |     /* Hilite the whole element        */
      NO_PROJ_ACCEPT_POINT        |     /* Don't project the accept point  */
      ACC_REJ_CYCLE               |     /* Run through accept reject cycle */
      /* 
       * 11/09/92:  SRH - DO NOT RELOCATE when none found; this is required 
       *                  for rehighlighting hidden RP's  (TR #11925218)
       */
      DO_NOT_RELOCATE             |     /* see comment (SRH- 11/09/92)     */
      LC_REGULAR_HIGHLIGHT        |     /* Use regular hilite not 1/2      */
      LC_ERASE_ALL;                     /* Erase the hilite plane          */

 attributes.properties = 
        LC_LC_ONLY                |     /* Locate locatable objects */
        LC_DP_ONLY                |     /* Locate displayable objects */
        IGN_MOD_BIT               |     /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR;           /* Planarity doesn't matter */

 if(aflag)
   attributes.properties |= LC_REF_OBJECTS;     /* Added by satish to catch 
                                           reference planes in a diff. os */

  rtree_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes = &r_classes[0];
  eligible_classes.w_flags = OM_CLST_subclass;
  eligible_classes.p_classes = &e_classes[0];

/*
 * Enter infinite loop.
 */
 do
 {
  switch (ME.super_cmd->state)
  {
   case 0:
   {
    IGRint vla_size = 0;

    aflag = pwIsActivationOn();
    if (aflag)
    {
       osn = pwGetActiveOs();
       sts = ems$get_datum_plane_mgr(msg = &msg,
                                     osnum = &osn,
                                     mgrid = &me->mgr_GRid.objid,
                                     mgros = &me->mgr_GRid.osnum);
       if (!(1&msg&sts)) return (OM_E_ABORT);
    }
    else
    {
       sts = ems$get_datum_plane_mgr(msg = &msg,
                                     mgrid = &me->mgr_GRid.objid,
                                     mgros = &me->mgr_GRid.osnum);
       if (!(1&msg&sts)) return (OM_E_ABORT);
    }


    sts = om$send (msg = message EMSdatplnmgr.EMget_datums(&msg,
                          (turn_on ? EMS_OPT_OFF_DATUMS : EMS_OPT_ON_DATUMS), 
                          &me->datum_count, NULL),
                   targetid = me->mgr_GRid.objid,
                   targetos = me->mgr_GRid.osnum);
    if (!(1&sts&msg)) return (OM_E_ABORT);

    if ((me->datum_count == 0) && !(me->mytype == ACTIVE_REF))
    {
     if (me->mytype == DISPLAY_ON)
     {
      ex$message( field = ERROR_FIELD, 
                  /* All existing reference planes display is on */
                  msgnumb =  EMS_E_AllExRfPlDsOn,
                  seconds = 2 );
     }
     else if (me->mytype == DISPLAY_OFF)
     {
      ex$message( field = ERROR_FIELD, 
                  /* All existing reference planes display is off */
                  msgnumb =  EMS_E_AllExRfPlDsOff,
                  seconds = 2 );
     }
     *response = TERMINATE;
     return (OM_S_SUCCESS);
    }
    else
    {
     vla_size = OM_DIMENSION_OF(me->datum_GRids);
     if (me->datum_count > vla_size)
       OM_SET_DIMENSION(me->datum_GRids,me->datum_count);

     sts = om$send (msg = message EMSdatplnmgr.EMget_datums(&msg,
                           (turn_on ? EMS_OPT_OFF_DATUMS : EMS_OPT_ON_DATUMS), 
                          &me->datum_count, me->datum_GRids),
                   targetid = me->mgr_GRid.objid,
                   targetos = me->mgr_GRid.osnum);
     if (!(1&sts&msg)) return (OM_E_ABORT);
    }
    ME.super_cmd->state = IDENTIFY_DATUM;
   }
   break;

   case IDENTIFY_DATUM:
   {
     int  locate_key;

       if (me->mytype == ACTIVE_REF)
         locate_mask = GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;
       else
         locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | 
                       GRm_TEXT_VALUE;

       accept_mask = GRm_DATA;
       attributes.properties |= LC_RW;

       if ((me->mytype == DISPLAY_ON) ||
           (me->mytype == ACTIVE_REF))
       {
        sts = om$send (msg = message EConoff.make_datums_locatable(TRUE),
                             targetid = my_id);
        if (!(1&sts)) return (OM_E_ABORT);
       }
       attributes.owner_action = LC_FLEX_COMP | 
                           LC_RIGID_OWNER |
                           LC_HANDLES | 
                          (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

       if(aflag)
         attributes.owner_action |= LC_REF_OBJECTS;

       rtree_classes.w_count = 1;
       eligible_classes.w_count = 2;
       r_classes[0] = OPP_GRbspline_class_id;
       e_classes[0] = OPP_EMSdatpln_class_id;
       e_classes[1] = OPP_SKmgr_class_id;
 
      
       if (me->mytype == ACTIVE_REF)
        locate_key = EMS_P_IdRefPlnProf ;     
                                          /* Identify reference plane/profile */
       else 
        locate_key = EMS_P_IdRfPlPrfMvOnAll; 
                        /* Identify reference plane or profile/moveon for all*/

       aflag = pwIsActivationOn();
       if (aflag)
       {
         GRspacenum osn;
         osn = pwGetActiveOs();

       sts = lc$locate(
         rc               =  &msg,
         event1           =  &me->locate_event,
         event2           =  &accept_event,
         mask1            =   locate_mask,
         mask2            =   accept_mask,
         display_flag     =   display_flag,
         locate_key       =   locate_key,
         acc_key          =   EMS_P_00038, /* Accept/reject */
         attributes       =  &attributes,
         relocate_key     =   EMS_E_RfPlNoLc, /* Reference plane not located */
         stack            =  &me->locate_stack,
         rtree_classes    =  &rtree_classes,
         eligible_classes =  &eligible_classes,
         act_handler      = RFlocate_ref_plane_handler,
         act_args         = &osn);
       }
       else
       {
       sts = lc$locate(
         rc               =  &msg,
         event1           =  &me->locate_event,
         event2           =  &accept_event,
         mask1            =   locate_mask,
         mask2            =   accept_mask,
         display_flag     =   display_flag,
         locate_key       =   locate_key,
         acc_key          =   EMS_P_00038, /* Accept/reject */
         attributes       =  &attributes,
         relocate_key     =   EMS_E_RfPlNoLc, /* Reference plane not located */
         stack            =  &me->locate_stack,
         rtree_classes    =  &rtree_classes,
         eligible_classes =  &eligible_classes);
        }

       if (!(1&sts)) return (OM_S_SUCCESS);
       
       if (!(1&msg))
       {
        if (ME.EConoff->locate_event.response == EX_BACK_UP)
        {
        }
        else if (ME.EConoff->locate_event.response == EX_RJT_MOVEON)
        {
         if (me->mytype != ACTIVE_REF)
         {
           struct GRid active_datpln;

           ems$get_active_datum_plane(msg = &msg,
                                     datpln = &active_datpln);
           if (!(1&msg)) return (OM_E_ABORT);

          for (i=0;i<me->datum_count;i++)
          {
            if (me->datum_GRids[i].objid != NULL_OBJID)
            {
             if (me->mytype == DISPLAY_ON)
             {
               sts = om$send (msg = message EConoff.display_datum(
                                    me->datum_GRids[i],
                                    GRhe),
                              targetid = my_id);
               if (!(1&sts)) return (OM_E_ABORT);
             }

             display_mode = (me->mytype == DISPLAY_ON) ? GRbd : GRbehe;
             sts = om$send (msg = message EConoff.display_datum(
                                  me->datum_GRids[i],
                                  display_mode),
                            targetid = my_id);
             if (!(1&sts)) return (OM_E_ABORT);
/*
 * If the reference plane that I am about to turn off is active then
 * make sure that the same is displayed.
 */

/*
  Commented this section out since the user does not have any way of 
  turning the display of a current reference plane other than this.

             if ((me->mytype != DISPLAY_ON) &&
                 (me->datum_GRids[i].objid == active_datpln.objid))
             {
               me->datum_GRids[i].objid = NULL_OBJID;
               continue;
             }
*/

             sts = om$send (msg = message EMSdatpln.EMtoggle_on_off(&msg,
                                  ((me->mytype == DISPLAY_ON) ? EMS_OPT_ON :
                                    EMS_OPT_OFF)),
                            targetid = me->datum_GRids[i].objid,
                            targetos = me->datum_GRids[i].osnum);
             if (!(1&sts&msg)) return (OM_E_ABORT);

             me->datum_GRids[i].objid = NULL_OBJID;
            }
          }
         *response = TERMINATE;
         return (OM_S_SUCCESS);
         }
         else
          return (OM_S_SUCCESS);
        }
        else
         return(OM_S_SUCCESS);
       }
       else
       {
        struct GRid lcobj;

        ME.EConoff->datum_info = accept_event.located_object[0];
        lcobj = ME.EConoff->datum_info.located_obj;

        if (EFisAncestryValid(&msg, lcobj.objid, lcobj.osnum,
                          OPP_SKmgr_class_id, FALSE))
        { 
          OM_S_CHANSELECT to_father;
          struct GRid temp;

          EMmake_chanselect(NDfather_father, &to_father); 

          temp.objid = NULL_OBJID;
          om$get_objid_at_index(objid = lcobj.objid,
                                osnum = lcobj.osnum,
                                objidaddr = &temp.objid,
                                osnumaddr = &temp.osnum,
                                index = 0,
                                p_chanselect = &to_father);


          if (temp.objid == NULL_OBJID)
          {
            ex$message( field = ERROR_FIELD, 
                       /* Invalid input */
                       msgnumb = EMS_S_InvInp);
          
          }
          else
          {
           ME.EConoff->datum_info = accept_event.located_object[0];
           lcobj.objid = temp.objid;
           lcobj.osnum = temp.osnum;
           ME.EConoff->datum_info.located_obj = lcobj;
          }
        }

        if (me->mytype != ACTIVE_REF)
        {
         if (turn_on)
         {
          sts = om$send (msg = message EConoff.display_datum(
                               lcobj,
                               GRhe),
                         targetid = my_id);
          if (!(1&sts)) return (OM_E_ABORT);
         }

         display_mode = (turn_on) ? GRbd : GRbehe;
         sts = om$send (msg = message EConoff.display_datum(
                                  lcobj,
                                  display_mode),
                           targetid = my_id);
         if (!(1&sts)) return (OM_E_ABORT);

        sts = om$send (msg = message EMSdatpln.EMtoggle_on_off(&msg,
                                ((turn_on) ? EMS_OPT_ON :
                                 EMS_OPT_OFF)),
                          targetid = lcobj.objid,
                          targetos = lcobj.osnum);
        if (!(1&sts&msg)) return (OM_E_ABORT);
       }
       else
       {
        OM_S_OBJID old_datum;


        sts = om$send (msg = message EMSdatplnmgr.EMget_info(&msg,
                             NULL,NULL,NULL,&old_datum,NULL),
                       targetid = me->mgr_GRid.objid,
                       targetos = me->mgr_GRid.osnum);
        if (!(1&sts&msg)) return (OM_E_ABORT);


        sts = dp$erase_hilite(msg = &msg);

        if (old_datum != NULL_OBJID)
        {
         aflag = pwIsActivationOn();
         if (aflag)
         {
         display_mode = GRbe;

         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->display_env.md_env.matrix_type,
                         me->display_env.md_env.matrix,
                         &display_mode,
                         &me->display_env.md_id),
                   targetid = old_datum,
                   targetos = me->datum_info.located_obj.osnum);
         if (!(1&sts&msg))  return (OM_E_ABORT);
         }
         else
         {
         display_mode = GRbe;

         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->datum_info.module_info.md_env.matrix_type,
                         me->datum_info.module_info.md_env.matrix,
                         &display_mode,
                         &me->datum_info.module_info.md_id),
                   targetid = old_datum,
                   targetos = me->datum_info.located_obj.osnum);
         if (!(1&sts&msg))  return (OM_E_ABORT);
         }
        }

        display_mode = GRbe;

         aflag = pwIsActivationOn();
         if (aflag)
         {
        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->display_env.md_env.matrix_type,
                         me->display_env.md_env.matrix,
                         &display_mode,
                         &me->display_env.md_id),
                   targetid = me->datum_info.located_obj.objid,
                   targetos = me->datum_info.located_obj.osnum);
         }
         else
         {

        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->datum_info.module_info.md_env.matrix_type,
                         me->datum_info.module_info.md_env.matrix,
                         &display_mode,
                         &me->datum_info.module_info.md_id),
                   targetid = me->datum_info.located_obj.objid,
                   targetos = me->datum_info.located_obj.osnum);
         }
        if (!(1&sts&msg))  return (OM_E_ABORT);

        sts = om$send (msg = message EMSdatplnmgr.EMactivate(&msg,
                             NULL,&lcobj.objid, &old_datum),
                       targetid = me->mgr_GRid.objid,
                       targetos = me->mgr_GRid.osnum);
        if (!(1&sts&msg)) return (OM_E_ABORT);

        display_mode = GRbd;

         aflag = pwIsActivationOn();
         if (aflag)
         {
        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->display_env.md_env.matrix_type,
                         me->display_env.md_env.matrix,
                         &display_mode,
                         &me->display_env.md_id),
                   targetid = me->datum_info.located_obj.objid,
                   targetos = me->datum_info.located_obj.osnum);
         }
         else
         {

        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->datum_info.module_info.md_env.matrix_type,
                         me->datum_info.module_info.md_env.matrix,
                         &display_mode,
                         &me->datum_info.module_info.md_id),
                   targetid = me->datum_info.located_obj.objid,
                   targetos = me->datum_info.located_obj.osnum);
         }
        if (!(1&sts&msg))  return (OM_E_ABORT);

        if (old_datum != NULL_OBJID)
        {
         display_mode = GRbd;

         aflag = pwIsActivationOn();
         if (aflag)
         {
         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->display_env.md_env.matrix_type,
                         me->display_env.md_env.matrix,
                         &display_mode,
                         &me->display_env.md_id),
                   targetid = old_datum,
                   targetos = me->datum_info.located_obj.osnum);
         }
         else
         {
         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->datum_info.module_info.md_env.matrix_type,
                         me->datum_info.module_info.md_env.matrix,
                         &display_mode,
                         &me->datum_info.module_info.md_id),
                   targetid = old_datum,
                   targetos = me->datum_info.located_obj.osnum);
         }
         if (!(1&sts&msg))  return (OM_E_ABORT);
        }
       }

        for (i=0;i<me->datum_count;i++)
        {
         if (lcobj.objid == me->datum_GRids[i].objid)
         {
          me->datum_GRids[i].objid = NULL_OBJID;
          break;
         }
        }
        if (me->mytype != ACTIVE_REF)
         ME.super_cmd->state = IDENTIFY_DATUM; 
        else
         ME.super_cmd->state = LOCATE_WINDOW;
       }
       break;
   }

    case LOCATE_WINDOW:
    {
     struct GRevent event;

     eventmask = GRm_RJT_MOVEON | GRm_DATA | GRm_STRING | GRm_BACK_UP;
     event.event.keyin[0] = '\0';

     sts = co$getevent( msg = &msg,   
                        event_mask = eventmask,
                        /* Identify window to re-orient/move on */
                        msgnum = EMS_P_IdWnReOrMvOn, 
                        response = response, 
                        response_data = response_data,
                        event = &event);

     switch (event.response)
     {
        case EX_DATA:
         wingrid[0].objid = event.event.button.objid;
         wingrid[0].osnum = event.event.button.osnum;
         numwin = 1;
         if (IF_NULL_OBJID (wingrid[0].objid))
         {
            ex$message( field = ERROR_FIELD, 
                       /* Not a window specification */
                       msgnumb = EMS_E_NoWnSp );
            break;
         }
         ME.super_cmd->state = PROCESS;
         break;

        case EX_STRING:
         if (event.event.keyin[0] == '\0')
         {
          ME.super_cmd->state = IDENTIFY_DATUM;
          break;
         }
         sts = dp$get_gragad_id (msg = &msg, name = event.event.keyin,
                       total_num = &total_numwin, numberofids = &numwin,
                       found_GRids = wingrid,
                       type_gragad = ALL_GG_CLASSES | ACTIVE_GG);
         if (!(1&sts)) return (OM_E_ABORT);
         if (!numwin)        
         {
            ex$message( field = ERROR_FIELD, 
                        /* Not a window specification */
                        msgnumb = EMS_E_NoWnSp );
            break;
         }
         ME.super_cmd->state = PROCESS;
         break;

        case EX_RJT_MOVEON:
        case EX_BACK_UP:
         ME.super_cmd->state = IDENTIFY_DATUM;
         if ((me->mytype == ACTIVE_REF) &&
             (event.response == EX_RJT_MOVEON))
         {
           *response = TERMINATE;
           return (OM_S_SUCCESS);
         }
        break;
        
        default:
         return (OM_S_SUCCESS);
       }
     break;
   }

    case PROCESS:
    {
     IGRdouble xdir[3],ydir[3],zdir[3],origin[3];
     struct GRmd_env *env, rfenv;

     env = &me->datum_info.module_info;

     aflag = pwIsActivationOn();
     if(aflag)
     {
       sts = pwGetActiveModuleEnv( &rfenv);
     }

     sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg,
                          NULL, aflag ? &rfenv : NULL,
                          xdir,ydir,zdir,origin,NULL),
                    targetid = me->datum_info.located_obj.objid,
                    targetos = me->datum_info.located_obj.osnum);
     if (!(1&sts&msg)) return (OM_E_ABORT);
  
     sts = EMsetwinornt (&msg, numwin, wingrid,
                   origin,
                   xdir, zdir,
                   &ME.EConoff->datum_info);
     if (!(1&sts&msg)) return (OM_E_ABORT);
     ME.super_cmd->state = IDENTIFY_DATUM;

     if (me->mytype == ACTIVE_REF)
     {
      *response = TERMINATE;
      return (OM_S_SUCCESS);
     }
   }
  }
 }
 while (TRUE);
}

method super_cmd.sleep(int pos)
{
 IGRlong sts = OM_S_SUCCESS;

    /* clear all fields */
    ex$message( field=PROMPT_FIELD, 
                msgnumb = EMS_P_00000 );
    ex$message( field = ERROR_FIELD, 
                msgnumb = EMS_I_00000 );
    ex$message (field=MESSAGE_FIELD, 
                msgnumb = EMS_I_00000 );

 if ((me->datum_count) && (me->mytype != DISPLAY_OFF))
 {
   sts = om$send (msg = message EConoff.make_datums_locatable(0),
                 targetid = my_id);
 }
 return(sts);
}

method wakeup(int pos)
{
 IGRlong sts = OM_S_SUCCESS;
 IGRlong msg, bytes_in, bytes_out;

 sts = om$send (mode = OM_e_wrt_parent,
                msg = message EConoff.wakeup(pos),
                targetid = my_id);

 bytes_in = sizeof(me->display_env);

 gr$get_display_env(
   msg = &msg, 
   sizbuf = &bytes_in,
   buffer = &me->display_env,
   nret = &bytes_out);
 if (!(1&msg)) return (OM_E_ABORT);

 if ((me->datum_count) && (me->mytype != DISPLAY_OFF))
 {
   sts = om$send (msg = message EConoff.make_datums_locatable(1),
                 targetid = my_id);
 }
 
 return (sts);
}

method make_datums_locatable(IGRint on)
{
 IGRlong i,sts,msg;
 IGRshort props, action;
 enum GRdpmode display_mode;

 sts = OM_S_SUCCESS;
 msg = MSSUCC;

 for (i=0;i<me->datum_count;i++)
 {
  if (me->datum_GRids[i].objid != NULL_OBJID)
  {
   if (on)
    action = 1;
   else
    action = 0;

   props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

   sts = om$send (msg = message GRgraphics.GRchgprops(&msg, &action, &props),
                 targetid = me->datum_GRids[i].objid,
                 targetos = me->datum_GRids[i].osnum);
   if (!(1&sts&msg))  return (OM_E_ABORT);

   if (on) 
   {
    display_mode = GRhhd;
    sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                       &me->display_env.md_env.matrix_type,
                       me->display_env.md_env.matrix,
                       &display_mode,
                       &me->display_env.md_id),
                 targetid = me->datum_GRids[i].objid,
                 targetos = me->datum_GRids[i].osnum);
    if (!(1&sts&msg))  return (OM_E_ABORT);
   }
  }
 }
 if (!on)
  sts = dp$erase_hilite(msg = &msg);

 return (sts);
}

method display_datum(struct GRid datum_GRid;
                     enum GRdpmode display_mode)
{
 IGRlong sts,msg;

 sts = OM_S_SUCCESS;
 msg = MSSUCC;

 if (datum_GRid.objid != NULL_OBJID)
  {
   sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                       &me->display_env.md_env.matrix_type,
                       me->display_env.md_env.matrix,
                       &display_mode,
                       &me->display_env.md_id),
                 targetid = datum_GRid.objid,
                 targetos = datum_GRid.osnum);
   if (!(1&sts&msg))  return (OM_E_ABORT);
  }
 return (sts);
}

IGRlong RFlocate_ref_plane_handler(osn, new_entry, locate_args, action)
GRspacenum *osn;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;
{
  IGRboolean  call_action_handler = FALSE;
  IGRlong sts = OM_S_SUCCESS;

  switch(*action)
  {
      case add_all:
      case add_inside:
      case add_outside:
      case add_overlap:
      case add_nopost:
      {
         if (new_entry->located_obj.osnum != *osn)
         {
            call_action_handler = FALSE;
         }
         else
         {
            call_action_handler = TRUE;
         }
      }
      break;

      default:
 
      break;
  } 

  /* Call the default action handler */

  if(call_action_handler)
      sts = LCptlocact(NULL, new_entry, locate_args, action);
  else
      sts = OM_S_SUCCESS;

  return(sts);
}
end implementation EConoff;

