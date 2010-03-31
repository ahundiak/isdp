/* ###################   APOGEE COMPILED   ################## */
class implementation ECreplace;

/*
HISTORY
   creation      Nirmal   -    02/1993.
   scw   08/14/94  clarified sleep method

   Hari  07/07/95  Case REINIT introduced and the error state
                   handled. Initially even when the operation
                   fails, operation success message was displayed
                   giving a false impression. Now if the operation
                   fails the replace surface displays 'operation
                   fail' message and reinitializes the data properly.  
*/

#include "EMS.h"
#include "OMerrordef.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */
/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"

# include "griomacros.h" /* co$getevent */
# include "EMSasmacros.h" /* ems$getevent */

#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "emsgeteddef.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
# include "EMSmsgdef.h"
#include "exmacros.h"
#include "msmacros.h" /* for ex$message */
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include  <values.h>
#include  <math.h>
#include  "bsparameters.h"
#include  "bsicmpcvoff.h"
#include  "EMSasfeatdef.h"
#include  "EMSasopts.h"
#include "EMSdpb.h"

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *response = TERMINATE;\
    ex$message(msgnumb = EMS_F_0002)\
    return(OM_E_ABORT);\
   }\
 }

#define SURFACES_AND_EDGES_OR_CRVS_OR_SURFS 0
#define SURFACE_AND_SURFACES                1


/*** STATES  *****/
#define LOCATE_SURFS                0
#define REPLACE_SURF               2
#define UNDO                       3

/* Added status to account for failure .Hari */

#define REINIT                     4


/*** ACTIONS *****/
#define GET_SURF_TO_REPLACE             0
#define GET_REPLACEMENT_SURF            1


extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSdatpln_class_id;

extern OMuword OPP_EMSgenbs_class_id;

from EMSgenbs  import EMdrafted_surface;

from GRvg import GRgetsize, GRgetgeom, GRgetrang;
from GRgraphics import GRdelete, GRdisplay;
from EMSsubbs import EMgetowner, EMgetedges, EMmk_nat_bdry;
from EMSedge import EMget_bcxyz_geom;
from GRvg import GRchgprops;
from EMSsurface import EMdisplay_edges;
from EMSdpr import EMundo;

struct locate_acthndlr_args
{
   IGRushort options;
   IGRchar *loc_prompt, *acc_prompt, *reloc_prompt;
   IGRint numelems;
   struct GRlc_info *elems;
   OM_S_CLASSLIST nelig_classes;
};


struct surf_to_drft_hndlr_args
{
   struct GRid *surface;
   struct GRid my_inst;
   struct GRmd_env *env;
   struct locate_acthndlr_args actargs;
};


method init(int pos; char *str_ptr)
{
    IGRlong        msg, sts;

    sts = om$send (mode = OM_e_wrt_parent,
                   msg = message ECreplace.init (pos, str_ptr),
                   targetid = my_id);
  me->action = GET_SURF_TO_REPLACE;
  ME.super_cmd->state = LOCATE_SURFS;
    me->num_surfs = 0;
    me->action = 0;
    me->num_located =0;
          me->cons_id.objid = NULL_OBJID;
    if (!(1 & sts)) return(OM_E_ABORT);
    return(sts);
   
}

method super_cmd.sleep(IGRint pos)
{
    IGRlong        msg, sts, *response;
    IGRlong        junk;

    response = (IGRlong *) &junk;
    sts = dp$erase_hilite(msg = &msg);

    if (me->associative_flag)
         GRdisplay_associative_button(FALSE); 

    return(OM_S_SUCCESS);
}

method wakeup(IGRint pos)
{
    IGRlong        sts;
    enum           GRdpmode DisplayMode;

    sts = om$send (mode = OM_e_wrt_parent,
                   msg = message ECreplace.wakeup (pos),
                   targetid = my_id);
    if (!(1 & sts)) return(OM_E_ABORT);

    DisplayMode = GRhd;
    gr$get_associative_flag( buffer = &me->associative_flag );

    if (me->associative_flag)
        GRdisplay_associative_button(TRUE);

    return(OM_S_SUCCESS);
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRchar loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRint event_size, qsize, display_flag;
  IGRlong stat_OM, msg_loc;
  IGRlong event_mask1, event_mask2;
  struct GRlc_locate lc_attr;
  struct GRvg_construct const_list;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT       to_loopset;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass[2];
  IGRdouble             draft_angle;
  struct GRevent accev, event;
 struct GRmd_env *env;

  struct GRid GRID;
  IGRlong (*p_acthndlr)();
  IGRchar *p_actargs;
   struct surf_to_drft_hndlr_args my_actargs;
   extern IGRlong EMloc_open_surf_hndlr();
   extern IGRlong EMloc_surf_to_drft_hndlr ();

  extern BSnorvec(), BSsfarrevn(), EFdraw_vector_on_screen();
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECaddraft.execute"); /* no message key needed here */
  
  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

  /**** initialize ***/
/*
  me->num_surfs = 0;
  me->action = GET_SURF_TO_REPLACE;
  ME.super_cmd->state = LOCATE_SURFS;
*/
  if(me->num_surfs == 0)
    {
     stat_OM = om$vla_set_dimension(varray = me->loc_info, size = 2);
     EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
    }

  do 
    {
    switch (ME.super_cmd->state)
      {
    case LOCATE_SURFS:
        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA | GRm_BACK_UP;

         
       if(me->action == GET_SURF_TO_REPLACE)
          {
           event_mask1 |= GRm_RJT_MOVEON;
           event_mask2 |= GRm_RJT_MOVEON;
           elig_classes.w_count = 1;
           eliclass[0] = OPP_EMSsubbs_class_id;
       if(me->cons_id.objid != NULL_OBJID)
            ex$message(msgnumb = EMS_I_ProcessCompBackUpToUndo);
       if(me->num_surfs <= 0)
        {
         ex$message(msgnumb = EMS_P_IdentifySurfToReplace, buff = loc_prompt)
        }
       else
        {
        ex$message(msgnumb = EMS_P_IdentifySurfToReplaceMvOn, buff = loc_prompt)
        }
           lc_attr.properties = 0x11 | LC_RW | LC_PLANAR_NON_PLANAR;
         lc_attr.owner_action = LC_LOCALMOD |  LC_RIGID_COMP | LC_NO_REF_HEADER;
         ex$message(msgnumb = EMS_P_AcceptWithReplacementSurf, buff=acc_prompt);
          }
       else if( me->action == GET_REPLACEMENT_SURF)
          {
         ex$message(msgnumb = EMS_P_IdentifyReplacementSurf, buff = loc_prompt)
         ex$message(msgnumb = EMS_P_AccRjectSf, buff = acc_prompt)
           elig_classes.w_count = 2;
           eliclass[0] = OPP_EMSsubbs_class_id;
           eliclass[1] = OPP_EMSdatpln_class_id;
           lc_attr.properties = 0x11 | LC_RW;
           lc_attr.owner_action = LC_RIGID_COMP | LC_LOCALMOD | 
                LC_FLEX_COMP |
                LC_ASSOCIATIVE   |
                LC_HANDLES       |
                LC_REF_OBJECTS | LC_NO_REF_HEADER |
                LC_EXTERN_CONSTRAINED;    /* Locate associative objects */
          }

         display_flag = 6;

         ex$message(msgnumb = EMS_I_00011, buff    = reloc_prompt);
         strcpy(lc_attr.classes, "EMSsubbs");
         rtree_classes.w_count = 1;
         rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
         rclass = OPP_EMSsubbs_class_id;
     
         rtree_classes.p_classes = &rclass;
         elig_classes.p_classes = &eliclass[0];

/* Locate handler to locate all types of solids/surfaces */
         p_actargs = (IGRchar *) &my_actargs;

      p_acthndlr = (IGRlong (*)())EMloc_surf_to_drft_hndlr;

      GRID.objid = me->accev.located_object[0].located_obj.objid;
      GRID.osnum = me->accev.located_object[0].located_obj.osnum;
      if(me->action == GET_REPLACEMENT_SURF)
        {
         GRID.objid = NULL_OBJID;
        }
      my_actargs.surface = &GRID;
      my_actargs.my_inst.objid = my_id;
      my_actargs.my_inst.osnum = OM_Gw_current_OS;
      my_actargs.actargs.options = ME.ECelements->options;
      my_actargs.actargs.loc_prompt = NULL;
      my_actargs.actargs.acc_prompt = NULL;
      my_actargs.actargs.reloc_prompt = NULL;
      my_actargs.actargs.numelems = me->num_surfs;
      my_actargs.actargs.elems = &me->loc_info[0];
      my_actargs.actargs.nelig_classes = ME.ECelements->nelig_classes;
      my_actargs.env = env;

         ex$message(msgnumb = EM_M_ReplaceSurf);
         stat_func = lc$locate(rc = &msg_loc,
              event1 = &ME.ECelements->locev, 
              event2 = &accev,
              mask1 = event_mask1, 
              mask2 = event_mask2,
              eventsize= &event_size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &lc_attr, 
              stack = &ME.ECelements->locate_stack, 
              act_handler = p_acthndlr,
              act_args = p_actargs,
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

         ex$message(msgnumb = EMS_S_ClearStatusField);
         ex$message(msgnumb = EMS_P_ClearPromptField);
         if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }

        if (msg_loc == FALSE)
          {
           if(ME.ECelements->locev.response == EX_RJT_MOVEON)
             {
             ME.super_cmd->state =  LOCATE_SURFS;
/*
             if((me->action == GET_SURF_TO_REPLACE ) && ( me->num_surfs > 0) )
                  ME.super_cmd->state =  REPLACE_SURF;
*/
             }
          else if(ME.ECelements->locev.response == GR_UNKNOWN_TYPE)
             {
              ME.super_cmd->state =  LOCATE_SURFS;
              goto ret_end;
             }
          else if(ME.ECelements->locev.response == EX_BACK_UP)
             {
              if(me->cons_id.objid != NULL_OBJID)
                {
                IGRint  display_count, involk_count;
                IGRushort  option;
                GRobjid *display_ids=NULL;

                display_count = involk_count = 0;
                option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
                stat_OM = om$send(msg = message EMSdpr.EMundo(&msg_loc,
                            &option,
                            &ME.ECelements->active_md_env,
                            NULL, NULL, NULL, &display_ids,
                            &display_count, &involk_count),
                targetid = me->cons_id.objid,
                targetos = me->cons_id.osnum);
                ERROR(stat_OM, msg_loc, "execute(0).EMundo error");
                ME.super_cmd->state = LOCATE_SURFS;
                me->cons_id.objid = NULL_OBJID;
                me->action = GET_REPLACEMENT_SURF;
                me->num_surfs=1; 
                goto ret_end;
              }
              me->num_surfs--; 
              if(me->num_surfs <= 0) 
                {
                me->num_surfs=0;
                me->action = GET_SURF_TO_REPLACE; 
                }
              ME.super_cmd->state =  LOCATE_SURFS;
              }
           else
              goto ret_end;
           }
      

      switch (accev.response )
      {
       case EX_DATA:
/*
         if(me->num_surfs > 0)
          {
          stat_OM = om$vla_set_dimension(varray=me->loc_info,
                       size= (1+ me->num_surfs) *2 );
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

          }
*/
         if( me->action == GET_SURF_TO_REPLACE)
          {
           me->surf[0].objid = accev.located_object[0].located_obj.objid;
           me->surf[0].osnum = accev.located_object[0].located_obj.osnum;
            OM_BLOCK_MOVE( &accev.located_object[0],
                         &me->loc_info[me->num_surfs*2],
                         sizeof(struct GRlc_info ));
           me->num_located++;
            qsize = sizeof(accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = (long *)&qsize,
                          buffer = (char *)&accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
          }
         else if(me->action == GET_REPLACEMENT_SURF)
           {
           me->surf[1].objid = accev.located_object[0].located_obj.objid;
           me->surf[1].osnum = accev.located_object[0].located_obj.osnum;
           OM_BLOCK_MOVE( &accev.located_object[0],
                         &me->loc_info[2*me->num_surfs+1],
                         sizeof(struct GRlc_info ));
           me->num_surfs = 1;
           me->num_located++;
           }
          
/*
              qsize = sizeof(accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = (long *)&qsize,
                          buffer = (char *)&accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
*/


          if( me->action == GET_SURF_TO_REPLACE)
           {
            dpmode = GRhd;
            stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me^^ECelements.active_md_env.md_env.matrix_type,
                         me^^ECelements.active_md_env.md_env.matrix,
                           &dpmode, &me^^ECelements.active_md_env.md_id),
                          senderid = my_id,
                       targetid = me->surf[0].objid,
                       targetos = me->surf[0].osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            }
          else
            {
              dpmode = GRhd;
              stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me^^ECelements.active_md_env.md_env.matrix_type,
                         me^^ECelements.active_md_env.md_env.matrix,
                           &dpmode, &me^^ECelements.active_md_env.md_id),
                          senderid = my_id,
                       targetid = me->surf[1].objid,
                       targetos = me->surf[1].osnum);
              EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
              EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
           }

        if( me->action == GET_SURF_TO_REPLACE)
          {
          me->action = GET_REPLACEMENT_SURF;
          ME.super_cmd->state = LOCATE_SURFS;
          }
        else
          {
          me->action = GET_SURF_TO_REPLACE;
          ME.super_cmd->state = REPLACE_SURF;
          }


        stat_OM = dp$erase_hilite(msg = &msg_loc);
        break;
    }
    break;

      case REPLACE_SURF:
        {
       struct IGRbsp_curve hinge_curve_geom;
       IGRushort initopts, genopts;


  /* * Construct drafted surfaces and attach it to me */

        const_list.msg = &msg_loc;
        const_list.env_info = &ME.ECelements->active_md_env;
        const_list.newflag = FALSE;
        const_list.level = ME.ECelements->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
        const_list.display = &ME.ECelements->active_display;
        const_list.class_attr = NULL;
        const_list.name = NULL;
        genopts = initopts = NULL;
        EFreplace_sfs(&msg_loc,
                    me->num_surfs,
                    me->loc_info,
                    initopts,
                    &const_list,
                    &me->cons_id,
                    me->associative_flag ? NULL : EMSasconst_notassociative);

        /* Code modified here to handle failure cases. Hari */

        if (EMis_error (msg_loc))
        {
         /*   ME.super_cmd->state =  LOCATE_SURFS; */
           ex$message(msgnumb = EMS_E_OperationFailed); 
           ME.super_cmd->state = REINIT;
        }  
        else
        {   
            /* ME.super_cmd->state = UNDO; */
           ME.super_cmd->state = LOCATE_SURFS;
           me->num_surfs=0;
        }

        break;
        }

     /* Added case to account for failure cases. Hari */ 
        
      case REINIT:
        
         {
           /* Reinitializing the datas */

           me->action = GET_SURF_TO_REPLACE;
           ME.super_cmd->state = LOCATE_SURFS;
           me->num_surfs = 0;
           me->action = 0;
           me->num_located =0;
           me->cons_id.objid = NULL_OBJID;

           goto ret_end;
          }

      default:
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto ret_end;
      }
   }
  while (TRUE);

ret_end:
  {

   /*
    IGRlong dpehrc;
    dp$erase_hilite (msg = &dpehrc);
    */

   /* Properly setting the msg field .Hari */

   dp$erase_hilite (msg = &msg_loc);
  }

  return (stat_OM);
}

end implementation ECreplace;


