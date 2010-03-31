/* ###################   APOGEE COMPILED   ################## */
/*
 * HISTORY
 * 
 * Rajiv Agrawal : 07/02/92 : Message system compliance
 * scw           : 08/15/94 : clarified sleep method
 */

class implementation ECdatum;

#include <stdio.h>                      /* Needed for print statements */
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
#include "dpdef.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h" /* For ems$get_datum_plane_mgr..*/
#include "msmacros.h"
#include "ECcmd.h"
#include "ECmsg.h"

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

#define IDENTIFY_DATUM 1
#define LOCATE_WINDOW 2
#define PROCESS 3

#define MAX_NUM_WIN 32
from GRgraphics   import GRdisplay;
from EMSdatplnmgr import EMactivate, EMget_info;
from EMSdatpln import EMget_pln_info;
extern OMuword OPP_EMSdatpln_class_id,
               OPP_GRbspline_class_id;

method super_cmd.sleep(int pos)
{
 IGRlong sts = OM_S_SUCCESS;

 UI_prompt("");
 UI_status("");
 UI_message("");

 return(sts);
}

method execute(int *response; char *response_data; int pos)
{
 IGRlong sts,msg;
 IGRint options,locate_mask, accept_mask,display_flag;
 enum GRdpmode display_mode;
 struct GRlc_locate attributes;
 OMuword r_classes[5], e_classes[5];
 OM_S_CLASSLIST	rtree_classes, eligible_classes;
 struct GRevent accept_event;
 struct GRid wingrid[MAX_NUM_WIN];
 IGRint total_numwin, numwin,eventmask;

 sts = OM_S_SUCCESS;
 msg = MSSUCC;

 locate_mask = GRm_DATA | GRm_BACK_UP;
 accept_mask = GRm_DATA;

 ex$message ( msgnumb = EM_M_SelectActiveRefPlane);

 display_flag = 
      ELEM_HILIGHT		| 	/* Hilite the whole element */
      NO_PROJ_ACCEPT_POINT	| 	/* Don't project the accept point */
      ACC_REJ_CYCLE		|	/* Run through accept reject cycle */
      RELOCATE			| 	/* Relocate if none found */
      LC_REGULAR_HIGHLIGHT	|	/* Use regular hilite not 1/2 */
      LC_ERASE_ALL;			/* Erase the hilite plane */

 attributes.properties = 
        LC_LC_ONLY		|	/* Locate locatable objects */
        LC_DP_ONLY		|	/* Locate displayable objects */
        IGN_MOD_BIT             |	/* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    ;	/* Planarity doesn't matter */

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
    ME.super_cmd->state = IDENTIFY_DATUM;
   break;

   case IDENTIFY_DATUM:
   {
       attributes.properties |= LC_RW;

       attributes.owner_action = LC_FLEX_COMP | 
                           LC_RIGID_OWNER |
                           LC_HANDLES | 
                          (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);
       rtree_classes.w_count = 1;
       eligible_classes.w_count = 1;
       r_classes[0] = OPP_GRbspline_class_id;
       e_classes[0] = OPP_EMSdatpln_class_id;

       sts = lc$locate(
         rc =			&msg,
         event1 =		&me->locate_event,
         event2 =		&accept_event,
         mask1 =		locate_mask,
         mask2 =		accept_mask,
         display_flag =		display_flag,
         locate_key    =        EMS_P_IdRefPln,
         acc_key    =           EMS_P_AcceptReject,
         attributes = 		&attributes,
         relocate_key    =      EMS_E_RfPlNoLc,
         stack = 		&me->locate_stack,
         rtree_classes = 	&rtree_classes,
         eligible_classes =     &eligible_classes);
       if (!(1&sts)) return (OM_S_SUCCESS);
       
       if (!(1&msg))
       {
        if (ME.ECdatum->locate_event.response == EX_BACK_UP)
        {
        }
        else
         return(OM_S_SUCCESS);
       }
       else
       {
        struct GRid lcobj;
        struct GRid mgr_GRid;
        OM_S_OBJID old_datum;

        ME.ECdatum->datum_info = accept_event.located_object[0];
        lcobj = ME.ECdatum->datum_info.located_obj;

        sts = dp$erase_hilite(msg = &msg);
        if (!(1&sts&msg)) return (OM_E_ABORT);
/*
 * Put the accept event onto the queue
 */

/*
        IGRint putque_size;
        if (accept_event.response == EX_DATA)
        {
         putque_size = sizeof(accept_event.event) + sizeof (IGRint) ;
         sts = ex$putque(msg = &msg, response = response,
                        byte = &putque_size, buffer = &accept_event.event);
         if (!(1&sts)) return (OM_E_ABORT);
        }
*/

        sts = ems$get_datum_plane_mgr(msg = &msg,
                                  mgrid = &mgr_GRid.objid,
                                  mgros = &mgr_GRid.osnum);
        if (!(1&msg&sts)) return (OM_E_ABORT);
 
        sts = om$send (msg = message EMSdatplnmgr.EMget_info(&msg,
                             NULL,NULL,NULL,&old_datum,NULL),
                       targetid = mgr_GRid.objid,
                       targetos = mgr_GRid.osnum);
        if (!(1&sts&msg)) return (OM_E_ABORT);

        if (old_datum != NULL_OBJID)
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
/*
 * If the old datum is the same as located object then deactivate the
 * same.
 */
   
        if (old_datum == lcobj.objid)
          options = EMS_OPT_DEACTIVATE;
        else
          options = NULL;
       
        sts = om$send (msg = message EMSdatplnmgr.EMactivate(&msg,
                             options,&lcobj.objid, &old_datum),
                       targetid = mgr_GRid.objid,
                       targetos = mgr_GRid.osnum);
        if (!(1&sts&msg)) return (OM_E_ABORT);

        display_mode = GRbe;

        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->datum_info.module_info.md_env.matrix_type,
                         me->datum_info.module_info.md_env.matrix,
                         &display_mode,
                         &me->datum_info.module_info.md_id),
                   targetid = me->datum_info.located_obj.objid,
                   targetos = me->datum_info.located_obj.osnum);
        if (!(1&sts&msg))  return (OM_E_ABORT);


        display_mode = GRbd;

        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->datum_info.module_info.md_env.matrix_type,
                         me->datum_info.module_info.md_env.matrix,
                         &display_mode,
                         &me->datum_info.module_info.md_id),
                   targetid = me->datum_info.located_obj.objid,
                   targetos = me->datum_info.located_obj.osnum);
        if (!(1&sts&msg))  return (OM_E_ABORT);

        if (old_datum != NULL_OBJID)
        {
         display_mode = GRbd;

         sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->datum_info.module_info.md_env.matrix_type,
                         me->datum_info.module_info.md_env.matrix,
                         &display_mode,
                         &me->datum_info.module_info.md_id),
                   targetid = old_datum,
                   targetos = me->datum_info.located_obj.osnum);
         if (!(1&sts&msg))  return (OM_E_ABORT);
        }

        if (old_datum != lcobj.objid)
         ME.super_cmd->state = LOCATE_WINDOW; 
        
       }
       break;
   }

    case LOCATE_WINDOW:
    {
      struct GRevent event;

      ex$message ( msgnumb = EMS_P_IdWnReOrMvOn);

      eventmask = GRm_RJT_MOVEON | GRm_DATA | GRm_STRING | GRm_BACK_UP;

      sts = co$getevent (msg = &msg, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
      UI_prompt ("");

      switch (event.response)
      {
        case EX_DATA:
         wingrid[0].objid = event.event.button.objid;
         wingrid[0].osnum = event.event.button.osnum;
         numwin = 1;
         if (IF_NULL_OBJID (wingrid[0].objid))
         {
            ex$message ( msgnumb = EMS_S_NotWindowSpecification);
            break;
         }
         ME.super_cmd->state = PROCESS;
         break;

        case EX_STRING:
         sts = dp$get_gragad_id (msg = &msg, name = event.event.keyin,
                       total_num = &total_numwin, numberofids = &numwin,
                       found_GRids = wingrid,
                       type_gragad = ALL_GG_CLASSES | ACTIVE_GG);
         if (!(1&sts)) return (OM_E_ABORT);
         if (!numwin)        
         {
            ex$message ( msgnumb = EMS_S_NotWindowSpecification);
            break;
         }
         ME.super_cmd->state = PROCESS;
         break;

        case EX_RJT_MOVEON:
        case EX_BACK_UP:
         ME.super_cmd->state = IDENTIFY_DATUM;
        break;
        
        default:
         return (OM_S_SUCCESS);
       }
     break;
   }
 
    case PROCESS:
    {
     IGRdouble xdir[3],ydir[3],zdir[3],origin[3];
     struct GRmd_env *env;

     env = &ME.ECdatum->datum_info.module_info;

     sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg,
                          NULL,env,
                          xdir,ydir,zdir,origin,NULL),
                    targetid = ME.ECdatum->datum_info.located_obj.objid,
                    targetos = ME.ECdatum->datum_info.located_obj.osnum);
     if (!(1&sts&msg)) return (OM_E_ABORT);
                    
     sts = EMsetwinornt (&msg, numwin, wingrid,
                   origin,
                   xdir, zdir,
                   &ME.ECdatum->datum_info);
     if (!(1&sts&msg)) return (OM_E_ABORT);
     ME.super_cmd->state = IDENTIFY_DATUM;
  }
 }
}
 while (TRUE);
}
end implementation ECdatum;

