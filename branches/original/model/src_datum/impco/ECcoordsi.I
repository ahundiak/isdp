class implementation ECcoords;

#include <stdio.h>                      /* Needed for print statements */
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
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
#include "EMSasopts.h"

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

#define IDENTIFY_CS 1
#define LOCATE_WINDOW 2
#define PROCESS 3

#define MAX_NUM_WIN 32
from GRgraphics   import GRdisplay;
from EMSdatplnmgr import EMactivate, EMget_info;
from EMSdatpln import EMget_pln_info;
extern OMuword OPP_EMSdatpln_class_id,
               OPP_GRcoords_class_id,
               OPP_GRbspline_class_id;

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
 OMuword constr_os;
 OM_S_OBJID res_id[3],old_datum;
 IGRdouble xdir[3], zdir[3], origin[3];
 struct GRvg_construct const_list;
 struct GRlc_info datum_lc_info;
 struct GRid mgr_GRid;

 sts = OM_S_SUCCESS;
 msg = MSSUCC;

 locate_mask = GRm_DATA | GRm_BACK_UP;
 accept_mask = GRm_DATA;

 ex$message ( msgnumb = EM_M_RefPlnFrmCoord);

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
    ME.super_cmd->state = IDENTIFY_CS;
   break;

   case IDENTIFY_CS:
   {
       attributes.properties |= LC_RW;

       /* fix for TR#119420249 - to locate VDS coordinate system, fix
	  suggested by VDS group */
       attributes.owner_action = LC_FLEX_COMP | 
                           LC_RIGID_OWNER | LC_RIGID_COMP |
                          (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);
       rtree_classes.w_count = 1;
       eligible_classes.w_count = 1;
       r_classes[0] = OPP_GRcoords_class_id;
       e_classes[0] = OPP_GRcoords_class_id;

       sts = lc$locate(
         rc =			&msg,
         event1 =		&me->locate_event,
         event2 =		&accept_event,
         mask1 =		locate_mask,
         mask2 =		accept_mask,
         display_flag =		display_flag,
         locate_key    =        EMS_P_IdCs,
         acc_key    =           EMS_P_AcceptReject,
         attributes = 		&attributes,
         relocate_key    =      EMS_E_NoCs,
         stack = 		&me->locate_stack,
         rtree_classes = 	&rtree_classes,
         eligible_classes =     &eligible_classes);
       if (!(1&sts)) return (OM_S_SUCCESS);
       
       if (!(1&msg))
       {
        if (ME.ECcoords->locate_event.response == EX_BACK_UP)
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

        ME.ECcoords->cs_info = accept_event.located_object[0];
        lcobj = ME.ECcoords->cs_info.located_obj;

        sts = dp$erase_hilite(msg = &msg);
        if (!(1&sts&msg)) return (OM_E_ABORT);

         ME.super_cmd->state = LOCATE_WINDOW; 
        
       }
       break;
   }

    case LOCATE_WINDOW:
    {
      struct GRevent event;

      ex$message ( msgnumb = EMS_P_IdWnROrMvOnNoReOr);

      eventmask = GRm_RJT_MOVEON | GRm_DATA | GRm_STRING | GRm_BACK_UP;

      sts = co$getevent (msg = &msg, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
      UI_prompt ("");

      wingrid[0].objid = NULL_OBJID;

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
         ME.super_cmd->state = PROCESS;
        break;

        case EX_BACK_UP:
         ME.super_cmd->state = IDENTIFY_CS;
        break;
        
        default:
         return (OM_S_SUCCESS);
       }
     break;
   }

    case PROCESS:
    {
     IGRint i;
     const_list.msg = &msg;
     const_list.env_info = &me->md_env;
     const_list.newflag = FALSE;
     const_list.level = ME.ECelement->active_level;
     const_list.properties = GRIS_DISPLAYABLE | GRIS_NEW | GRIS_LOCATABLE;
     const_list.geometry = NULL;
     const_list.display = &ME.ECelement->active_display;
     const_list.class_attr = NULL;
     const_list.name = NULL;
     sts = dp$erase_hilite(msg = &msg);
     if (!(1&sts&msg)) return (OM_E_ABORT);
     
     constr_os = const_list.env_info->md_id.osnum;
    
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
          /*
           * Erase the active datum plane since the now constructed entity 
           * is going to be active.
           */
          display_mode = GRbe;
          sts = om$send (msg = message GRgraphics.GRdisplay(
                         &msg,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           &display_mode,
                           &me->md_env.md_id),
                       targetid = old_datum,
                       targetos = mgr_GRid.osnum);
          if (!(1&sts&msg))  return (OM_E_ABORT);
     }
  
     EFcreate_ref_plane_from_cs(&msg,
                                  (me->is_associative ?
                                   NULL : EMSasconst_notassociative),
                                  &ME.ECcoords->cs_info,
                                  &const_list,
                                  res_id);
     if (!(1&msg)) return (OM_E_ABORT);
  
     if (wingrid[0].objid != NULL_OBJID)
     {
          sts = om$send (msg = message EMSdatpln.EMget_pln_info(
                                  &msg,
                                   NULL,const_list.env_info,
                                   xdir,
                                   NULL, 
                                   zdir,
                                   origin,
                                   NULL),
                         targetid = res_id[0],
                         targetos = constr_os);
          if (!(1&sts&msg)) 
            return (OM_E_ABORT);
  
          datum_lc_info.module_info = *(const_list.env_info);
          datum_lc_info.located_obj.objid = res_id[0];
          datum_lc_info.located_obj.osnum = constr_os;
  
          sts = EMsetwinornt ( &msg, 
                                numwin, 
                                wingrid,
                                origin,
                                xdir, 
                                zdir,
                               &datum_lc_info);
          if (!(1&sts&msg)) 
          return (OM_E_ABORT);
        }
  
        if (old_datum != NULL_OBJID)
        {
          /*
           * Redisplay the old datum plane since the now constructed entity 
           * is going to be active.
           */
  
          display_mode = GRbd;
          sts = om$send (msg = message GRgraphics.GRdisplay(
                                 &msg,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &display_mode,
                                 &me->md_env.md_id),
                         targetid = old_datum,
                         targetos = mgr_GRid.osnum);
          if (!(1&sts&msg))  
            return (OM_E_ABORT);
        }
  
        for (i=0;i<3;i++)
        {
         display_mode = GRbd;
  
         sts = om$send (msg = message GRgraphics.GRdisplay(
                               &msg,
                               &me->md_env.md_env.matrix_type,
                               me->md_env.md_env.matrix,
                               &display_mode,
                               &me->md_env.md_id),
                       targetid = res_id[i],
                       targetos = constr_os);
         if (!(1&sts&msg))  
         return (OM_E_ABORT);
        }

        /* restart the command */
        ME.super_cmd->state = IDENTIFY_CS;
       break;

      }
    }
 }
 while (TRUE);
}

method super_cmd.sleep(int pos)
{
  IGRlong sts = OM_S_SUCCESS;
  IGRlong msg = MSSUCC;

  if (me->is_associative)
    GRdisplay_associative_button(FALSE);
 
  sts = dp$erase_hilite(msg = &msg);
  if (!(1&sts&msg)) 
    return (OM_E_ABORT);

  sts = om$send (msg = message ECcoords.sleep(pos),
                 mode = OM_e_wrt_parent,
                 targetid = my_id);

 return(sts);
}

method wakeup (int pos)
{
 IGRlong sts = OM_S_SUCCESS;
 IGRlong msg = MSSUCC,i;
 enum GRdpmode display_mode; 
 
 sts = om$send (msg = message ECcoords.wakeup(pos),
                mode = OM_e_wrt_parent,
                targetid = my_id);

 {

   gr$get_associative_flag( buffer = &me->is_associative ); 
   if (me->is_associative)
    GRdisplay_associative_button(TRUE);
 }
 return(sts);
}
end implementation ECcoords;

