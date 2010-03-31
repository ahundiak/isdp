/* ###################   APOGEE COMPILED   ################## */
class implementation ECaddraft;

/*
HISTORY
   creation      Nirmal   -    02/1993.
   Sudha         07/05/93      Modified for BSprototypes ansification
   scw           08/14/94      clarified sleep method
*/

#include "bsvalues.h"
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
#include  <math.h>
#include  "bsparameters.h"
#include  "bsicmpcvoff.h"
#include  "EMSasfeatdef.h"
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "bssfarrevn.h"
#include "bsnorvec.h"
#include "bsmdistptsf.h"
#include "bsdotp.h"
#include "bscveval.h"
#include "bscrossp.h"
#include "gr.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

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
#define SURFACE_AND_LOOPS                   2

/*** STATES  *****/
#define LOCATE_SURF_OR_PLANE_OR_LOOP        0
#define GET_ANGLE                   1
#define STUFF_ANGLE                 2
#define DISPLAY_AND_GET_DIRECTION   3
#define ADD_DRAFT                   4
#define UNDO                        5
#define REINIT                      6

/*** ACTIONS ****/
#define GET_PLANE_OR_DATUM 0
#define GET_SURF_TO_DRAFT  1
#define GET_FACE_LOOP  2
#define GET_SURF_WITH_EDGE 3

/***** FORM LABLES *****/
#define SURFACE_SURFACE 15 
#define SURFACE_LOOP 18 
#define EDGE_SURFACE 20 
#define EXIT		1
#define CON_TO_WINDOW	5


extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSloop_class_id;
extern OMuword  OPP_EMSdatpln_class_id;
extern OMuword OPP_EMSsolid_class_id;

extern OMuword OPP_EMSgenbs_class_id;

from GRvg import GRchgweight, GRgetsize, GRgetgeom, GRgetrang, GRdetplane;
from GRgraphics import GRdelete, GRdisplay;
from EMSsubbs import EMgetowner, EMgetedges, EMmk_nat_bdry;
from EMSedge import EMget_bcxyz_geom;
from GRvg import GRchgprops;
from EMSsurface import EMdisplay_edges , EMgetactiveid;
from EMSloop import EMnext_edge, EMget_edges;
from EMSboundary import EMgetsurface_info;
from EMSdpr import EMundo;

/*
 * This structure is used as an argument to the action-handler
 * called within the 'do_locate' method.
*/
struct locate_acthndlr_args
{
   IGRushort options;
   IGRchar *loc_prompt, *acc_prompt, *reloc_prompt;
   IGRint numelems;
   struct GRlc_info *elems;
   OM_S_CLASSLIST nelig_classes;
};

/*
 * This structure is used as an argument to the action-handler
 * called within this command's execute method.
*/

struct surf_to_drft_hndlr_args
{
   struct GRid *surface;
   struct GRid my_inst;
   struct GRmd_env *env;
   struct locate_acthndlr_args actargs;
};

static IGRboolean aflag;

method init(int pos; char *str_ptr)
{
    IGRlong        sts;

    sts = om$send (mode = OM_e_wrt_parent,
                   msg = message ECaddraft.init (pos, str_ptr),
                   targetid = my_id);

    me->draft_angle = 5.0;
    me->num_drafts = 0;
    me->num_surfs = 0;
    me->num_loops = 0;
    me->num_drafts_inc=0;
    me->uniform_draft=FALSE;
    me->action = 0;
    ME.super_cmd->state=0;
    me->active_grid .objid=NULL_OBJID ;
    me->active_grid .osnum=0 ;
    me->surf[1].objid = NULL_OBJID;
    me->add_draft_type = 0;
    me->int_grid.objid = NULL_OBJID;
    me->ext_surf_id = NULL_OBJID;
    me->cmd_typ = GET_SURF_TO_DRAFT;
    me->cons_id.objid = NULL_OBJID;
    me->form_displayed = 2;
    me->form1 = NULL;
    if (!(1 & sts)) return(OM_E_ABORT);
    return(OM_S_SUCCESS);
}


method super_cmd.sleep(int pos)
{
    IGRlong        msg, sts, *response;
    IGRlong        junk;

    response = (IGRlong *) &junk;
    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "dp$erase_hilite error");

    if (me->associative_flag)
        GRdisplay_associative_button(FALSE);
 if(me->form_displayed == TRUE)
       FIf_erase (ME.ECaddraft->form1);

    return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
    IGRlong        i, jjj, msg, sts;
    enum           GRdpmode dpmode;
    IGRint buff_size, num_edges=0;
    struct GRid *edges=NULL;
    IGRboolean aflag = 0;

    sts = om$send (mode = OM_e_wrt_parent,
                   msg = message ECaddraft.wakeup (pos),
                   targetid = my_id);
        if (!(1 & sts)) goto ret_end;

   aflag = pwIsActivationOn();
   if(aflag)
      pwGetActiveModuleEnv(&ME.ECelements->active_md_env);
   
    dpmode = GRhd;
    for(i=0; i< me->num_surfs; i++)
    {
      if(i==0 &&  me->action != GET_SURF_WITH_EDGE) 
        {
        dpmode = GRhhd;
        sts = om$send(msg = message GRgraphics.GRdisplay
                           (&msg,
                            &me^^ECelements.active_md_env.md_env.matrix_type,
                            me^^ECelements.active_md_env.md_env.matrix,
                            &dpmode, &me^^ECelements.active_md_env.md_id),
                      targetid = me->loc_info[i].located_obj.objid,
                      targetos = me->loc_info[i].located_obj.osnum);
        if (!(1 & sts)) goto ret_end;
        }
        dpmode = GRhd;
        sts = om$send(msg = message GRgraphics.GRdisplay
                           (&msg,
                            &me^^ECelements.active_md_env.md_env.matrix_type,
                            me^^ECelements.active_md_env.md_env.matrix,
                            &dpmode, &me^^ECelements.active_md_env.md_id),
                      targetid = me->loc_info[i].located_obj.objid,
                      targetos = me->loc_info[i].located_obj.osnum);
       if (!(1 & sts)) goto ret_end;
    }
    if( me->action == GET_FACE_LOOP)
      {
      for(jjj=0; jjj<me->num_loops; jjj++)
       {
       edges=NULL;
       buff_size= num_edges = 0;
       sts = om$send(msg = message EMSloop.EMget_edges(
                    &msg, 1, EMS_OPT_NONDEG, &edges, &buff_size,
                                 &num_edges),
                    targetid = me->the_loop[jjj].objid,
                    targetos = me->the_loop[jjj].osnum);
       if (!(1 & sts)) goto ret_end;
                      
       for(i=0; i<num_edges; i++)
          {
          dpmode = GRhd;
          EFhilite_edge_with_weight (&msg,
              me^^ECelements.active_md_env, edges[i].objid, dpmode);
          }
        if(edges) {om$dealloc(ptr = edges); edges=NULL;}
        }
       }


    /* Get the dpb variables */

  /*   sts = EMdpb_getinfo (&msg, &me->dpb_info); */
    gr$get_associative_flag( buffer = &me->associative_flag );

    GRstatus_display_button(TRUE);
    if (me->associative_flag)
        GRdisplay_associative_button(TRUE);
   if(me->form_displayed == TRUE)
       FIf_display (ME.ECaddraft->form1);

   ret_end:
    if(edges) {om$dealloc(ptr = edges); edges=NULL;}
    return(OM_S_SUCCESS);
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func, hili;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRchar loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRint iii, event_size, qsize, display_flag;
  IGRint buff_size;
  IGRlong stat_OM, msgloc,msg_loc;
  IGRlong event_mask1, event_mask2;
  struct GRevent event;
  struct GRlc_locate lc_attr;
  struct GRvg_construct const_list;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT       to_loopset;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass[2];
  struct GRid           *edges = NULL;
  GRobjid  hinge_edge_id = NULL_OBJID;

   struct GRmd_env *env,disp_env;
   IGRint (*p_acthndlr)();
   IGRchar *p_actargs;
   struct surf_to_drft_hndlr_args my_actargs;
   IGRlong EMloc_open_surf_hndlr();
   IGRlong EMloc_surf_to_drft_hndlr ();

  struct IGRbsp_curve hinge_edge_geom;
  struct IGRbsp_surface *datum_geom=NULL, *draft_surf_geom=NULL;
  struct IGRbsp_surface *surf_geom=NULL;
  struct IGRbsp_curve *hinge_geom=NULL;
  struct GRid GRID;

  GRobjid solid_id;
  IGRint                count, num_edges = 0, buf_size = 0;
  IGRint             ii, ij;
  IGRdouble             draft_angle;
  IGRboolean red_neck=TRUE, 
               cont=FALSE, draft_angle_rev=FALSE, loop_locatable=FALSE;
  struct IGRbsp_curve curve;
  IGRpoint p0, p1;
  IGRint type;
  struct DPele_header line_buff, curve_buff;
  struct IGResbc ele_attr;
  struct IGRdisplay display_attr;

  extern IGRboolean EFloop_curves_locatable();
  extern EFdraw_vector_on_screen() ;
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECaddraft.execute"); /* no message key needed here */

  msg_loc = msgloc = EMS_S_Success;
 
  gr$get_module_env(buffer = &disp_env); 
  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

  if(me->num_drafts == 0)
     stat_OM = om$vla_set_dimension(varray = me->loc_info, size = 2);
  ERROR(stat_OM, msg_loc, "execute(8).vla_set_dimension");

  do 
    {
    switch (ME.super_cmd->state)
      {
    case LOCATE_SURF_OR_PLANE_OR_LOOP:

        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;
         lc_attr.properties = NULL;
         lc_attr.owner_action =  NULL;
         aflag = pwIsActivationOn();
         if (aflag)
         {
         lc_attr.owner_action = LC_LOCALMOD |  LC_RIGID_COMP | 
                                LC_NO_REF_HEADER | LC_REF_OBJECTS;
         /* added REF_OBJECTS for RFA*/
         }
         else
         {
         lc_attr.owner_action = LC_LOCALMOD |  LC_RIGID_COMP | 
                                LC_NO_REF_HEADER; 
         }

         if(me->action == GET_PLANE_OR_DATUM)
           {
           event_mask1 | = GRm_STRING;
           event_mask2 | = GRm_STRING;
           ex$message(msgnumb = EMS_P_IdentifyPlaneToDraftFrom,
                   buff    = loc_prompt);
           if(me->cmd_typ == GET_FACE_LOOP)
             {
              ex$message(msgnumb = EMS_P_AcceptWithFace,
                 buff    = me->accept_prompt);
              ex$message(msgnumb = EMS_S_LoopOptSel);
              }
           else
              {
               ex$message(msgnumb = EMS_S_SurfOptSel);
               ex$message(msgnumb = EMS_P_AcceptWithSurfToDraft,
               buff    = me->accept_prompt);
              }
           rclass = OPP_EMSsubbs_class_id;
           elig_classes.w_count = 2;
           eliclass[0] = OPP_EMSsubbs_class_id;
           eliclass[1] = OPP_EMSdatpln_class_id;
           lc_attr.properties = 0x11 | LC_RW | LC_PLANAR_ONLY;
           lc_attr.owner_action |=  LC_FLEX_COMP |
                LC_ASSOCIATIVE   |
                LC_HANDLES       |
                LC_EXTERN_CONSTRAINED;    /* Locate associative objects */
           }
         else if(me->action == GET_SURF_TO_DRAFT)
           {
           event_mask1 |= GRm_RJT_MOVEON;
           event_mask2 |= GRm_RJT_MOVEON;
           if(me->num_drafts == 0)
             {
             ex$message(msgnumb = EMS_P_IdentifySurfaceToDraft,
                   buff    = loc_prompt);
             }
           else
             {
             ex$message(msgnumb = EMS_P_IdentifyNextSurfToDraftMvOn,
                   buff    = loc_prompt);
             }
           ex$message(msgnumb = EMS_P_AcceptWithNextSurfToDraft,
               buff    = acc_prompt);
           rclass = OPP_EMSsubbs_class_id;
           eliclass[0] = OPP_EMSsubbs_class_id;
           lc_attr.properties = 0x11 | LC_RW;
           lc_attr.owner_action |=  LC_FLEX_COMP ;
           elig_classes.w_count = 1;
           }
         else if(me->action == GET_SURF_WITH_EDGE)
           {
           event_mask1 |= GRm_RJT_MOVEON;
           event_mask2 |= GRm_RJT_MOVEON;
           rclass = OPP_EMSsubbs_class_id;
           if(me->num_drafts == 0)
             {
             ex$message(msgnumb = EMS_P_IdentifySurfaceToDraft,
                   buff    = loc_prompt);
             }
           else
             {
             ex$message(msgnumb = EMS_P_IdentifyNextSurfToDraftMvOn,
                   buff    = loc_prompt);
             }
           ex$message(msgnumb = EMS_P_AccWithEdgeReject,
               buff    = acc_prompt);
           eliclass[0] = OPP_EMSsubbs_class_id;
           lc_attr.properties = 0x11 | LC_RW | LC_PLANAR_NON_PLANAR;
           lc_attr.owner_action |=  LC_FLEX_COMP ;
           elig_classes.w_count = 1;
           }
         else if(me->action == GET_FACE_LOOP)
           {
           event_mask1 |= GRm_RJT_MOVEON;
           event_mask2 |= GRm_RJT_MOVEON;
           ex$message(msgnumb = EMS_P_AcceptWithNextFace,
               buff    = acc_prompt);
           if(me->num_drafts == 0)
             {
             ex$message(msgnumb = EMS_P_IdentifyFace,
                   buff    = loc_prompt);
             }
           else
             {
             ex$message(msgnumb = EMS_P_IdentifyNextFaceMvOn,
                   buff    = loc_prompt);
             }
           rclass = OPP_EMSsurface_class_id;
           eliclass[0] = OPP_EMSloop_class_id;
           lc_attr.properties =  LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_ONLY;
           lc_attr.owner_action |=  LC_OBJ_W_OWNER;

           loop_locatable = EFloop_curves_locatable();
           if(!loop_locatable)
               EFset_locate_eligibility(&msg_loc,1,"EMSloop");
           elig_classes.w_count = 1;
           }
       display_flag =ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ERASE_LOC_ELEMENT;

         ex$message(msgnumb = EMS_I_00011,
               buff    = reloc_prompt);
         strcpy(lc_attr.classes, "EMSsubbs");
         rtree_classes.w_count = 1;
         rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
     
         rtree_classes.p_classes = &rclass;
         elig_classes.p_classes = &eliclass[0];

      env = &ME.ECelements->active_md_env;

      p_actargs = (IGRchar *) &my_actargs;
/*
      Locate handler to locate all types of solids/surfaces
*/
      p_acthndlr = (IGRint (*)())EMloc_surf_to_drft_hndlr;


      GRID.objid = me->accev.located_object[0].located_obj.objid;
      GRID.osnum = me->accev.located_object[0].located_obj.osnum;
      if(me->action == GET_PLANE_OR_DATUM)
        {
         GRID.objid = NULL_OBJID;
        }
      my_actargs.surface = &GRID;
      my_actargs.my_inst.objid =  my_id;
      my_actargs.my_inst.osnum = OM_Gw_current_OS;
      my_actargs.actargs.options = ME.ECelements->options;
      my_actargs.actargs.loc_prompt = NULL;
      my_actargs.actargs.acc_prompt = NULL;
      my_actargs.actargs.reloc_prompt = NULL;
      my_actargs.actargs.numelems = me->num_surfs;
      my_actargs.actargs.elems = &me->loc_info[0];
      my_actargs.actargs.nelig_classes = ME.ECelements->nelig_classes;
      my_actargs.env = env;

      ex$message(msgnumb = EM_M_AddDraft);
      stat_func = lc$locate(rc = &msg_loc,
              event1 = &ME.ECelements->locev, 
              event2 = &me->accev,
              mask1 = event_mask1, 
              mask2 = event_mask2,
              eventsize= &event_size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt =
              (ME.super_cmd->state ==0 && me->action==0 ) ?
                                    me->accept_prompt: acc_prompt,
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
            switch(me->action)
              {
              case GET_PLANE_OR_DATUM:
                {
                if (ME.ECelements->locev.response == EX_BACK_UP)
                   {
                   ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
                   break;
                   }
                else if (ME.ECelements->locev.response == GR_UNKNOWN_TYPE)
                  {
                   ME.ECelements->locev.event.keyin[0] =
                           toupper(ME.ECelements->locev.event.keyin[0]); 
             
                   if(ME.ECelements->locev.event.keyin[0] == 'E')
                      {
                      me->action = GET_SURF_WITH_EDGE;
                      me->add_draft_type = SURFACES_AND_EDGES_OR_CRVS_OR_SURFS;
                      ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
                      me->cmd_typ =  GET_SURF_WITH_EDGE;
                      break;
                      }
                   else if(ME.ECelements->locev.event.keyin[0] == 'L')
                      {
                      me->add_draft_type = SURFACE_AND_SURFACES;
                      me->cmd_typ = GET_FACE_LOOP;
                      me->action = GET_PLANE_OR_DATUM ;
                      ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
		      ME.ECelements->locev.event.keyin[0] ='\0';
                      }
                   else if(ME.ECelements->locev.event.keyin[0] == 'S')
                      {
                      me->add_draft_type = SURFACE_AND_SURFACES;
                      me->action = GET_PLANE_OR_DATUM ;
                      me->cmd_typ = GET_SURF_TO_DRAFT;
                      ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
		      ME.ECelements->locev.event.keyin[0] ='\0';
                      }
                    else
                      {
                      goto ret_end;
                      }
                   }
                 else
                    goto ret_end;
                 }
                 break;

              case GET_SURF_TO_DRAFT:
              case GET_SURF_WITH_EDGE:
              case GET_FACE_LOOP:
                 if(ME.ECelements->locev.response == EX_RJT_MOVEON)
                      {
                       if(me->num_drafts > 0)
                          ME.super_cmd->state = GET_ANGLE;
                       else
                          ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
                      }
                 else if(ME.ECelements->locev.response == GR_UNKNOWN_TYPE)
                      {
                         ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
                         goto ret_end;
                      }
                 else if(ME.ECelements->locev.response == EX_BACK_UP)
                      {
                       IGRint loc_num_drafts =0;
                        loc_num_drafts = me->num_surfs;
                        me->num_drafts -= me->num_drafts_inc; 
                        me->num_surfs -= me->num_drafts_inc; 
                        if(me->num_surfs <0)
                           {
                            me->num_surfs=0;
                            loc_num_drafts = 1;
                           }

                     for(ii=me->num_surfs; ii< loc_num_drafts; ii++)
                       {
                        dpmode = GRhe;
                        stat_OM = om$send(mode = OM_e_wrt_object,
                                 msg = message GRgraphics.GRdisplay (&msg_loc,
                               &me^^ECelements.active_md_env.md_env.matrix_type,
                               me^^ECelements.active_md_env.md_env.matrix,
                               &dpmode, &me^^ECelements.active_md_env.md_id),
                                senderid = my_id,
                                targetid = me->loc_info[ii].located_obj.objid,
                                targetos = me->loc_info[ii].located_obj.osnum);
                        EMomerr_hndlr_action (stat_OM, *response = TERMINATE;
                                                        goto ret_end, errmsg);
                        EMerr_hndlr (EMis_error (msg_loc), *response,TERMINATE,
                                                         ret_end);
                        }

                     if( me->action == GET_FACE_LOOP && me->num_loops >0)
                     {
                     edges=NULL;
                     buff_size= num_edges = 0;
                     stat_OM = om$send(msg = message EMSloop.EMget_edges(
                            &msg_loc, 1, EMS_OPT_NONDEG, &edges, &buff_size,
                                        &num_edges),
                        targetid = me->the_loop[me->num_loops-1].objid,
                        targetos = me->the_loop[me->num_loops-1].osnum);
                      EMomerr_hndlr_action(stat_OM, *response = TERMINATE; 
                             goto ret_end, errmsg);
                      EMerr_hndlr (EMis_error (msg_loc), *response, 
                             TERMINATE, ret_end);
                      
                      for(iii=0; iii<num_edges; iii++)
                         {
                         dpmode = GRhe;
                         EFhilite_edge_with_weight (&msg_loc,
                             me^^ECelements.active_md_env, edges[iii].objid,
                                dpmode);
                          }
                       if(edges) {om$dealloc(ptr = edges); edges=NULL;}
                       me->num_loops--;
                       }

                       if(me->num_drafts < 0) 
                            {
                            me->num_drafts=0;
                            me->action = GET_PLANE_OR_DATUM; 
                            }
                        ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
                      }
                 else
                      {
                       goto ret_end;
                      }
                 break;
              }
           break;
          }
      

      switch (me->accev.response )
      {
       case EX_DATA:
         switch (me->action)
         {
           case  GET_PLANE_OR_DATUM:

            me->add_draft_type = SURFACE_AND_SURFACES;
            me->surf[0].objid = me->accev.located_object[0].located_obj.objid;
            me->surf[0].osnum = me->accev.located_object[0].located_obj.osnum;

            OM_BLOCK_MOVE( &me->accev.located_object[0],
                         &me->loc_info[0],
                         sizeof(struct GRlc_info ));
           ME.super_cmd->state = LOCATE_SURF_OR_PLANE_OR_LOOP;
           me->action = me->cmd_typ;

           dp$erase_hilite (msg = &msg_loc);
           dpmode = GRhhd;
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

            qsize = sizeof(me->accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = (long *)&qsize,
                          buffer = (char *)&me->accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);

           me->num_drafts_inc = 1;
           me->num_surfs = 1;
           break;

          case  GET_SURF_TO_DRAFT :
            {
             
            me->surf[1].objid = me->accev.located_object[0].located_obj.objid;
            me->surf[1].osnum = me->accev.located_object[0].located_obj.osnum;

            if(me->num_drafts > 0)
             {
              stat_OM = om$vla_set_dimension(varray=me->loc_info,
                       size=me->num_drafts +2 ); 
              ERROR(stat_OM, msg_loc, "execute(8).vla_set_dimension");
 
             }
            OM_BLOCK_MOVE( &me->accev.located_object[0],
                         &me->loc_info[1+me->num_drafts],
                         sizeof(struct GRlc_info ));

            ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
            me->action = GET_SURF_TO_DRAFT;
            me->num_drafts_inc = 1;
            me->num_drafts += me->num_drafts_inc;
            me->num_surfs = 1+me->num_drafts;

            qsize = sizeof(me->accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = (long *)&qsize,
                          buffer = (char *)&me->accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);

            break;
           }

          case  GET_SURF_WITH_EDGE :
            me->surf[1].objid = me->accev.located_object[0].located_obj.objid;
            me->surf[1].osnum = me->accev.located_object[0].located_obj.osnum;
            if(me->num_drafts>1)
             {
              stat_OM = om$vla_set_dimension(varray = me->loc_info, size =
                            (2+me->num_drafts*2));
              ERROR(stat_OM, msg_loc, "execute(8).vla_set_dimension");

             }
            OM_BLOCK_MOVE( &me->accev.located_object[0],
                         &me->loc_info[me->num_drafts*2],
                         sizeof(struct GRlc_info ));
            me->num_surfs = me->num_drafts;

            stat_OM = om$send(msg=message EMSsubbs.EMgetowner(
                              &msg_loc,
                              &solid_id,
                              FALSE),
                      targetos = me->surf[1].osnum,
                      targetid = me->surf[1].objid);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);

            stat_OM = om$get_channel_count(objid = me->surf[1].objid,
                                 osnum = me->surf[1].osnum,
                                 p_chanselect=&to_loopset,
                                 count  = (OMuint *)&count);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

            if(!count)
            {
               stat_OM = om$send(msg=message EMSsubbs.EMmk_nat_bdry (&msg_loc, 
                          &me^^ECelements.active_md_env.md_env, NULL), 
                      targetos = me->surf[1].osnum,
                      targetid = me->surf[1].objid);
               EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
               EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
                        ret_end);
            }
       
            qsize = sizeof(me->accev.event) + sizeof (IGRint);
            stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = (long *)&qsize,
                          buffer = (char *)&me->accev.event);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);

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

        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
            msgnum = EMS_P_IdentifyEdge,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;             
        switch (event.response)
          {
          case EX_DATA:
            num_edges = 0;
            stat_OM = om$send(msg = message EMSsubbs.EMgetedges(&msg_loc,
                                        EMS_OPT_NONDEG_NONSEAM,
                                        &edges, &buf_size, &num_edges,
                                        NULL, NULL, NULL, NULL),
                        targetid = me->surf[1].objid,
                        targetos = me->surf[1].osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        
            if (! num_edges)
            { ex$message(msgnumb = EMS_I_SurfNoStitchEdges);
                ME.super_cmd->state = 2;
                break;
            }

            stat_OM = dp$erase_hilite(msg = &msg_loc);
            ex$message(msgnumb = EMS_P_AccRejEdge,
                       buff    = acc_prompt);
            stat_OM = EMtpselect(&msg_loc, edges, me->surf[1], num_edges,
                                 EMS_GET_MOD_EDGE, NULL, event,
                        &me^^ECelements.active_md_env, acc_prompt, &event_mask1,
                                 &event_size, response, response_data,
                                 &me->accev, &hili);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            if (me->accev.response == EX_BACK_UP ||
                me->accev.response == GR_UNKNOWN_TYPE)  break;

            hinge_edge_id = me->accev.located_object[0].located_obj.objid;

            OM_BLOCK_MOVE( &me->accev.located_object[0],
                          &me->loc_info[2*me->num_drafts+1],
                         sizeof(struct GRlc_info ));

            ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
            me->action = GET_SURF_WITH_EDGE;
 
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = 2;
            break;
          default:
            goto ret_end;
          }
        me->num_drafts++;
        me->num_drafts_inc = 2;
        stat_OM = dp$erase_hilite(msg = &msg_loc);
        break;
       
        case GET_FACE_LOOP:
         {
         GRobjid  adj_surf=NULL_OBJID;
         BSrc rc=BSSUCC;
         OM_S_CHANSELECT to_common;

         stat_OM = om$vla_set_dimension(varray = me->the_loop, size =
                            (me->num_loops+1));
         ERROR(stat_OM, msg_loc, "execute(8).vla_set_dimension");
         me->the_loop[me->num_loops].objid =
                 me->accev.located_object[0].located_obj.objid;
         me->the_loop[me->num_loops].osnum =
                 me->accev.located_object[0].located_obj.osnum;

          edges=NULL;
          buff_size= num_edges = 0;
          stat_OM = om$send(msg = message EMSloop.EMget_edges(&msg_loc,
                                        1,
                                        EMS_OPT_NONDEG,
                                        &edges,
                                        &buff_size,
                                        &num_edges),
                        targetid = me->the_loop[me->num_loops].objid,
                        targetos = me->the_loop[me->num_loops].osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            dpmode = GRhd;

          stat_OM = om$vla_set_dimension(varray = me->loc_info, size =
                            (me->num_drafts + num_edges+1));
          ERROR(stat_OM, msg_loc, "execute(8).vla_set_dimension");

          stat_OM = EMmake_chanselect(EMSedge_to_common_edge, &to_common);

          me->num_drafts_inc=0;
          for(iii=0; iii<num_edges; iii++)
            {
            adj_surf=NULL_OBJID;
            stat_OM = om$send(msg = message EMSloop.EMgetsurface_info(&msg_loc,
                                    &adj_surf,
                                    NULL),
                        senderid = edges[iii].objid,
                        targetos = edges[iii].osnum,
                        p_chanselect = &to_common);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
           EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);


         /***** display thicker ********/
            dpmode = GRhd;
            EFhilite_edge_with_weight (&msg_loc, me^^ECelements.active_md_env,
                                       edges[iii].objid, dpmode);
              me->surf[1].objid = adj_surf;
              me->surf[1].osnum = me->accev.located_object[0].located_obj.osnum;

              dpmode = GRhd;
              stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                               &me^^ECelements.active_md_env.md_env.matrix_type,
                                me^^ECelements.active_md_env.md_env.matrix,
                           &dpmode, &me^^ECelements.active_md_env.md_id),
                          senderid = my_id,
                        targetid = adj_surf,
                        targetos = me->the_loop[me->num_loops].osnum);
              EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
              EMerr_hndlr(EMis_error (msg_loc),*response,TERMINATE, ret_end);

              cont=FALSE;
              for(ii=0; ii<me->num_drafts+iii; ii++)
                   if(me->loc_info[ii].located_obj.objid == adj_surf)
                       {
                        cont = TRUE;
                        break;
                       }
              if(cont) continue;


              me->num_drafts_inc++;
              me->accev.located_object[0].located_obj.objid = adj_surf;
              OM_BLOCK_MOVE( &me->accev.located_object[0],
                   &me->loc_info[me->num_drafts+me->num_drafts_inc],
                         sizeof(struct GRlc_info ));
           }
         if(edges) {om$dealloc(ptr = edges); edges=NULL;}

          me->num_loops++;
          me->num_drafts = me->num_drafts + me->num_drafts_inc;
          me->num_surfs = 1 + me->num_drafts;
          ME.super_cmd->state = LOCATE_SURF_OR_PLANE_OR_LOOP;
          me->action = GET_FACE_LOOP;

          
          qsize = sizeof(me->accev.event) + sizeof (IGRint);
          stat_OM = ex$putque(msg = &msg_loc, 
                          response = response, 
                          byte = (long *)&qsize,
                          buffer = (char *)&me->accev.event);
           EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);

          break;
         }
      }
  }
  break;

    case GET_ANGLE:
       me->event[0].event.value = me->draft_angle;
       ex$message(msgnumb = EMS_P_KeyinDraftAngle,
         var=me->draft_angle, type = "%f");
      stat_OM = ems$getevent (
        msg = &msg_loc,
        event_mask = GRm_VALUE | GRm_DATA | GRm_RJT_MOVEON  | GRm_BACK_UP,
        value_type = GRIO_ANGLE,
        response = (long *)response,
        response_data = response_data,
        event = &me->event[0]);

       ex$message(msgnumb = EMS_P_ClearPromptField); 
      if (stat_OM == FALSE)
       {
        ex$message(msgnumb = EMS_E_FailInputProcExit);
        *response = TERMINATE;
        goto ret_end ;
       }
      if (msg_loc == GRw_no_value)
       {
        me->event[0].event.value = 5.0 ;
         ME.super_cmd->state = DISPLAY_AND_GET_DIRECTION ;
         break;
       }
      if (msg_loc != MSSUCC)
       {
        me->event[0].event.value = 5.0 ;
         ME.super_cmd->state = DISPLAY_AND_GET_DIRECTION ;
         break;
       }

      switch(me->event[0].response)
       {
        case EX_DATA:
          me->event[0].event.value = me->draft_angle *  M_PI/180.0;
        case EX_VALUE:
          me->event[0].event.value *= 180.0/M_PI;
         ME.super_cmd->state = ADD_DRAFT;
         ME.super_cmd->state = DISPLAY_AND_GET_DIRECTION ;
         if(me->event[0].event.value <  0.0 || me->event[0].event.value > 90.0)
           {
           ex$message(msgnumb = EMS_E_BadAssAngle)
           ME.super_cmd->state = GET_ANGLE;
           }
         else
           {
           me->draft_angle = me->event[0].event.value;
           }
         break;
        case EX_RJT_MOVEON:
         me->event[0].event.value = me->draft_angle;
         ME.super_cmd->state = DISPLAY_AND_GET_DIRECTION ;
         break;
        case EX_BACK_UP:
         ME.super_cmd->state = LOCATE_SURF_OR_PLANE_OR_LOOP;
         break;
        default:
          goto ret_end;
      } /* if state = GET_ANGLE */
      break;

     case DISPLAY_AND_GET_DIRECTION :
       {
       IGRpoint dir_pt, pnts[1][1];
       IGRvector nrml[1][1],tangent, draft_vec;
       IGRlong buf_size;
       IGRdouble dist, u_p, v_p;
       IGRdouble range[6];
       BSrc rc=BSSUCC;
       IGRboolean world = TRUE;
       IGRdouble pointo[3],point[6];
       struct IGRplane plane_def;
       IGRpoint  pln_pt;
       IGRvector  pln_nrml;
       struct GRid win_grid;
       IGRdouble win_tol, length, temp_length, fraction;

        plane_def.point =  pln_pt;
        plane_def.normal  = pln_nrml;

       const_list.msg = &msg_loc;
       const_list.env_info = &ME.ECelements->active_md_env;
       const_list.newflag = FALSE;
       const_list.level = ME.ECelements->active_level;
       const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
       const_list.display = &ME.ECelements->active_display;
       const_list.class_attr = NULL;
       const_list.name = NULL;

      me->surf[1].objid = me->loc_info[1].located_obj.objid;
      if(me->action == GET_SURF_TO_DRAFT || me->action == GET_FACE_LOOP)
      {
         surf_geom=NULL;
          me->ext_surf_id = NULL_OBJID;
          me->int_grid.objid = NULL_OBJID;

         EFget_intersection(&msg_loc, &me^^ECelements.active_md_env,
          &me->surf[0].objid, &me->surf[1],
           &me->ext_surf_id, &surf_geom,
            &const_list, TRUE, &me->int_grid, &red_neck);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                               &me^^ECelements.active_md_env.md_env.matrix_type,
                                me^^ECelements.active_md_env.md_env.matrix,
                                    &buf_size),
                        senderid = NULL_OBJID,
                        targetid = me->int_grid.objid,
                        targetos = me->surf[1].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        hinge_geom = (struct IGRbsp_curve *) om$malloc( size=buf_size);
        EMerr_hndlr (!hinge_geom, *response, TERMINATE, ret_end);

        stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                               &me^^ECelements.active_md_env.md_env.matrix_type,
                                me^^ECelements.active_md_env.md_env.matrix,
                           (IGRchar *) hinge_geom),
                        senderid = NULL_OBJID,
                        targetid = me->int_grid.objid,
                        targetos = me->surf[1].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
       }
       else
       {
        stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                               &me^^ECelements.active_md_env.md_env.matrix_type,
                                me^^ECelements.active_md_env.md_env.matrix,
                                    &buf_size),
                        senderid = NULL_OBJID,
                        targetid = me->surf[1].objid,
                        targetos = me->surf[1].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        surf_geom = (struct IGRbsp_surface *) om$malloc(size=buf_size);
        EMerr_hndlr (!surf_geom, *response, TERMINATE, ret_end);

        stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                               &me^^ECelements.active_md_env.md_env.matrix_type,
                                me^^ECelements.active_md_env.md_env.matrix,
                           (IGRchar *) surf_geom),
                        senderid = NULL_OBJID,
                        targetid = me->surf[1].objid,
                        targetos = me->surf[1].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);

        hinge_edge_geom.poles = NULL;
        hinge_edge_geom.knots = NULL;
        hinge_edge_geom.weights = NULL;
        stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
                               &me^^ECelements.active_md_env.md_env,
                                        &me->surf[1],
                                        surf_geom,
                                        0, MAXINT, FALSE, NULL,
                                        &hinge_edge_geom),
                        senderid = NULL_OBJID,
                        targetid = hinge_edge_id,
                        targetos = me->surf[1].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        hinge_geom =  &hinge_edge_geom;


       }

        display_attr.weight = 2;
        display_attr.style = (IGRchar)0;
        display_attr.color = (IGRchar)7;
        ele_attr.is_polydis = FALSE;
        ele_attr.is_curvedis = TRUE;
        dp$build_dis_buffer(buffer = &curve_buff,
                      type = IGRBC,
                      display_att = &display_attr,
                      ele_spec_att = &ele_attr,
                      geometry = hinge_geom);

        dpmode = GRhd;
        dp$display( msg = &msg_loc, mode = dpmode, buffer = &curve_buff);


        stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                               &me^^ECelements.active_md_env.md_env.matrix_type,
                                me^^ECelements.active_md_env.md_env.matrix,
                                    &world,
                                    range),
                        senderid = NULL_OBJID,
                        targetid = me->surf[1].objid,
                        targetos = me->surf[1].osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        win_grid.objid = me->accev.event.button.objid;
        win_grid.osnum = me->accev.event.button.osnum;

        length = range[3] - range[0];
        temp_length = range[4] - range[1];
        if (temp_length > length)
            length = temp_length;
        temp_length = range[5] - range[2];
        if (temp_length > length)
           length = temp_length;
        EFget_window_dittol (&win_grid, &win_tol);
        fraction = 100.0 * win_tol / length;

        for(ii=0;ii<6;ii++)
             range[ii] *= fabs(fraction);

        curve.poles = (IGRdouble *)om$malloc(size=6*sizeof(IGRdouble ));
        curve.knots = (IGRdouble *)om$malloc(size=12*sizeof(IGRdouble ));
        curve.weights=NULL;

        BScveval(hinge_geom, .5, 0, (IGRpoint *)point, &rc);

        for(ii=0;ii<3;ii++)
           {
           dir_pt[ii] = (range[3+ii] + range[ii])/2.0;
           draft_vec[ii] = dir_pt[ii] - point[ii];
           }

        BSmdistptsf(&rc, surf_geom, &point[0], &u_p, &v_p, &point[3], &dist);
        BSsfarrevn(&rc, surf_geom,1, &u_p, 1, &v_p,
                             (IGRdouble *)pnts, (IGRdouble *)nrml);

        if(surf_geom->pos_orient)
            for(ii=0; ii<3; ii++)
                nrml[0][0][ii] *= -1.0;
        BSnorvec(&rc, nrml[0][0]);

        BScveval(hinge_geom, .5, 1, (IGRpoint *)point, &rc);
        BScrossp(&rc, &point[3] , nrml[0][0], tangent);
        BSnorvec(&rc, tangent);

        if( BSdotp(&rc, draft_vec, tangent) < 0.0)
            for(ii=0; ii<3; ii++)
                tangent[ii] *= -1.0;
        else
            for(ii=0; ii<3; ii++)
                nrml[0][0][ii] *= -1.0;

        for(ii=0;ii<3;ii++)
        {
           p0[ii] = pnts[0][0][ii] - tangent[ii] * 100.0;
           p1[ii] = pnts[0][0][ii] + tangent[ii] * 100.0;
        }
        
        BSptlngen(&rc, p0, p1, &curve, &type );

        display_attr.weight = 1;
        display_attr.style = (IGRchar)1;
        display_attr.color = (IGRchar)7;
        ele_attr.is_polydis = FALSE;
        ele_attr.is_curvedis = TRUE;
        dp$build_dis_buffer(buffer = &line_buff,
                      type = IGRBC,
                      display_att = &display_attr,
                      ele_spec_att = &ele_attr,
                      geometry = &curve);

        dpmode = GRhd;
        dp$display( msg = &msg_loc, mode = dpmode, buffer = &line_buff);

        for(ii=0;ii<3;ii++)
           draft_vec[ii] =  (nrml[0][0][ii] + tangent[ii])/2.0;
        BSnorvec(&rc, draft_vec);

        if(BSdotp(&rc, draft_vec, nrml[0][0]) < 0.0)
         for(ii=0;ii<3;ii++)
           draft_vec[ii] *= -1.0;

       if(aflag = pwIsActivationOn())
       {
        EFdraw_vector_on_screen(NULL_OBJID, &me->active_display,
              &disp_env, GRbd, FALSE,
                 pnts[0][0], draft_vec, range,
                 &msg_loc); 
       }
       else
       {
        EFdraw_vector_on_screen(NULL_OBJID, &me->active_display,
              &me^^ECelements.active_md_env, GRbd, FALSE,
                 pnts[0][0], draft_vec, range,
                 &msg_loc); 
       }
       ex$message(msgnumb = EMS_P_AcceptDraftDirRejToFlip);
        stat_OM = ems$getevent (
        msg = &msg_loc,
        event_mask = GRm_VALUE | GRm_DATA | GRm_RJT_MOVEON  | GRm_BACK_UP,
        value_type = GRIO_ANGLE,
        response = (long *)response,
        response_data = response_data,
        event = &me->event[1]);

       ex$message(msgnumb = EMS_P_ClearPromptField);

        dpmode = GRhe;
        dp$display( msg = &msg_loc, mode = dpmode, buffer = &line_buff);
        display_attr.weight = 2;
        display_attr.style = (IGRchar)0;
        display_attr.color = (IGRchar)7;
        ele_attr.is_polydis = FALSE;
        ele_attr.is_curvedis = TRUE;
        dp$build_dis_buffer(buffer = &curve_buff,
                      type = IGRBC,
                      display_att = &display_attr,
                      ele_spec_att = &ele_attr,
                      geometry = hinge_geom);
        dp$display( msg = &msg_loc, mode = dpmode, buffer = &curve_buff);
      if(aflag = pwIsActivationOn())
      {
       EFdraw_vector_on_screen(NULL_OBJID, &me->active_display,
              &disp_env,
               GRbe, FALSE, pnts[0][0], draft_vec, range,
                 &msgloc); 
      }
      else
      { 
       EFdraw_vector_on_screen(NULL_OBJID, &me->active_display,
              &me^^ECelements.active_md_env,
               GRbe, FALSE, pnts[0][0], draft_vec, range,
                 &msgloc); 
      }

      if (stat_OM == FALSE)
       {
        ex$message(msgnumb = EMS_E_FailInputProcExit);
        *response = TERMINATE;
        goto ret_end ;
       }
      if (msg_loc == GRw_no_value)
       {
        me->event[1].event.value = 0.0;
        goto DRAW_VECTOR;
       }
      if (msg_loc != MSSUCC)
       {
        me->event[1].event.value = 0.0;
        goto DRAW_VECTOR;
       }

        switch(me->event[1].response)
        {
        case EX_BACK_UP:
         dpmode = GRhe;
         dp$display( msg = &msg_loc, mode = dpmode, buffer = &line_buff);
         dp$display( msg = &msg_loc, mode = dpmode, buffer = &curve_buff);
         if(aflag = pwIsActivationOn())
         {
         EFdraw_vector_on_screen(NULL_OBJID, &me->active_display,
              &disp_env, GRbe, FALSE, pnts[0][0],
                draft_vec, range,
                 &msg_loc);
         }
         else
         {
         EFdraw_vector_on_screen(NULL_OBJID, &me->active_display,
              &me^^ECelements.active_md_env, GRbe, FALSE, pnts[0][0],
                draft_vec, range,
                 &msg_loc);
         }
         ME.super_cmd->state = GET_ANGLE;
         goto ret_end;
        case EX_DATA:
        case EX_VALUE:
          me->event[1].event.value = 0.0;
          break;
        case EX_RJT_MOVEON:
          dpmode = GRhe;
          dp$display( msg = &msg_loc, mode = dpmode, buffer = &curve_buff);
          draft_angle_rev = TRUE;
          me->event[1].event.value = 1.0;
          break;
         default:
           ME.super_cmd->state = DISPLAY_AND_GET_DIRECTION ;
           goto ret_end ;
          }


DRAW_VECTOR :

        if(hinge_geom) om$dealloc(ptr=hinge_geom);
           hinge_geom=NULL;
        if(surf_geom) om$dealloc(ptr=surf_geom);
           surf_geom=NULL;

       if(me->int_grid.objid != NULL_OBJID)
         {
          dpmode = GRhe;
          dp$display( msg = &msg_loc, mode = dpmode, buffer = &curve_buff);

          stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete (&msg_loc,
                                    &me^^ECelements.active_md_env),
                        senderid = NULL_OBJID,
                        targetid = me->int_grid.objid,
                        targetos = me->surf[1].osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

          if(me->ext_surf_id != NULL_OBJID)
          {
          stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete (&msg_loc,
                                    &me^^ECelements.active_md_env),
                        senderid = NULL_OBJID,
                        targetid = me->ext_surf_id,
                        targetos = me->surf[1].osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                        ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          }
          me->ext_surf_id = NULL_OBJID;
          }
     ME.super_cmd->state = ADD_DRAFT;
     break;
     }
      case ADD_DRAFT:
       {
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

        EFadd_draft(&msg_loc,
                    me->num_drafts,
                    draft_angle_rev,
                    &me->event[0],
                    &me->event[1],
                    me->add_draft_type,
                    me->loc_info,
                    initopts,
                    &const_list,
                    &me->cons_id,
                    me->associative_flag ? NULL : EMSasconst_notassociative);
        if (EMis_error (msg_loc))
           ME.super_cmd->state =  REINIT; /** reinitialize ***/
        else
           ME.super_cmd->state = UNDO;
        break;
       }

   case UNDO:
        {
        IGRint  display_count, involk_count;
        IGRushort  option;
        GRobjid *display_ids=NULL;

        ex$message(msgnumb = EMS_I_ProcessCompBackUpToUndo);
        ex$message(msgnumb = EMS_P_DataPtToAcceptSolid);
        stat_OM = ems$getevent (
        msg = &msg_loc,
        event_mask = GRm_DATA | GRm_RJT_MOVEON  | GRm_BACK_UP,
        value_type = GRIO_ANGLE,
        response = (long *)response,
        response_data = response_data,
        event = &me->event[1]);

        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (stat_OM == FALSE)
         {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end ;
         }
         if (msg_loc != MSSUCC)
            ME.super_cmd->state =  REINIT; /** reinitialize ***/
         else if(me->event[1].response == EX_BACK_UP)
            {
             display_count = involk_count = 0;
             option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
             stat_OM = om$send(msg = message EMSdpr.EMundo(&msg_loc,
                            &option,
                            &me^^ECelements.active_md_env,
                            NULL, NULL, NULL, &display_ids,
                            &display_count, &involk_count),
             targetid = me->cons_id.objid,
             targetos = me->cons_id.osnum);
             ERROR(stat_OM, msg_loc, "execute(0).EMundo error");
             me->cons_id.objid = NULL_OBJID;
             ME.super_cmd->state =  DISPLAY_AND_GET_DIRECTION;
             }
          else
             ME.super_cmd->state =  REINIT; /** reinitialize ***/

           break;
         }

   case REINIT:
        {
/** reinitialize ***/
           me->num_drafts = 0;
           me->num_surfs = 0;
           me->num_loops = 0;
           me->num_drafts_inc=0;
           me->uniform_draft=FALSE;
           me->action = 0;
           ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
           me->active_grid .objid=NULL_OBJID ;
           me->active_grid .osnum=0 ;
           me->surf[1].objid = NULL_OBJID;
           me->add_draft_type = 0;
           me->int_grid.objid = NULL_OBJID;
           me->ext_surf_id = NULL_OBJID;
           me->cmd_typ = GET_SURF_TO_DRAFT;
           me->cons_id.objid = NULL_OBJID;
/*
 * *
            me->form_displayed = 2;
           me->form1 = NULL;
 */
           goto ret_end;
        }

      default:
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        *response = TERMINATE;
        goto ret_end;
      }
   }
  while (TRUE);

ret_end:

  if (edges) om$dealloc(ptr = edges);
  if(surf_geom) om$dealloc(ptr=surf_geom);
  if(datum_geom) om$dealloc(ptr=datum_geom);
  if(draft_surf_geom) om$dealloc(ptr=draft_surf_geom);
  if(hinge_geom) om$dealloc(ptr=hinge_geom);

  if(me->int_grid.objid != NULL_OBJID)
      {
      stat_OM = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRdelete (&msg_loc,
                                    &me^^ECelements.active_md_env),
                        senderid = NULL_OBJID,
                        targetid = me->int_grid.objid,
                        targetos = me->surf[1].osnum);
       me->int_grid.objid = NULL_OBJID;
      }
  if(me->ext_surf_id != NULL_OBJID)
      {
       stat_OM = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRdelete (&msg_loc,
                                    &me^^ECelements.active_md_env),
                        senderid = NULL_OBJID,
                        targetid = me->ext_surf_id,
                        targetos = me->surf[1].osnum);
       me->ext_surf_id = NULL_OBJID;
       }
  dp$erase_hilite (msg = &msg_loc);
  return (stat_OM);
}




IGRint EFget_window_dittol (win_grid, dittol)
     struct GRid  *win_grid;
     IGRdouble  *dittol;
{
  IGRint ret_stat,status;
  IGRlong msg;
  struct var_list list_var[2];
  IGRdouble vwscale;

  gr$get_dit_tolerance(msg = &msg,
                       buffer = dittol,
                       nret = &ret_stat);

  list_var[0].var = VVOL_VIEWPORT_SCALE;
  list_var[0].var_ptr = (char *)&vwscale;
  list_var[0].num_bytes = sizeof (IGRdouble);
  list_var[0].bytes_returned = (IGRlong *)&ret_stat;

  list_var[1].var = END_PARAM;
  list_var[1].var_ptr = NULL;
  list_var[1].num_bytes = 0;
  list_var[1].bytes_returned = NULL;

  status =
  dp$inq_set_gragad (msg = &msg,
                     osnum = win_grid->osnum,
                     gragad_objid = win_grid->objid,
                     which_error = &ret_stat,
                     var_list = list_var);
/*   fe$status(action= RET_STATUS); */
  (*dittol) /= vwscale;
  return(TRUE);
}


/*
Action-handler to locate any surface of a solid as the surface to draft.
*/

IGRlong EMloc_surf_to_drft_hndlr (curr_info, new_locinfo, priv_args, action)
struct surf_to_drft_hndlr_args *curr_info;
struct GRlc_info *new_locinfo;
struct LC_action_args *priv_args;
enum GRlocate_action *action;
{
   IGRlong       stat_func;
   struct locate_acthndlr_args *act_args;
   IGRlong       msg_loc;
   IGRlong       msg;
   struct GRid   start_grid;
   struct GRid   *search_id;
   IGRboolean eligible=TRUE;
   IGRboolean aflag = 0;

   IGRlong EMlocate_eligchk_hndlr();
   stat_func = TRUE;

      if(aflag = pwIsActivationOn())
      {
        GRspacenum osn;
        osn = pwGetActiveOs();
        if(new_locinfo->located_obj.osnum != osn)
          return(OM_S_SUCCESS); 
      }

   search_id = &new_locinfo->located_obj;

   start_grid.objid =  NULL_OBJID;
   start_grid.objid =  curr_info->surface->objid;
   start_grid.osnum =  curr_info->surface->osnum;

   if(start_grid.objid == NULL_OBJID)
       {
          eligible=TRUE;
       }
   else if( EFisAncestryValid(&msg_loc, search_id->objid, search_id->osnum,
            OPP_EMSsurface_class_id, FALSE))
       {
       stat_func = om$send(msg = message EMSsurface.EMgetactiveid (&msg_loc,
        &start_grid, NULL),
         senderid = NULL_OBJID,
         targetid = search_id->objid,
         targetos = search_id->osnum);
       if(!(1 & stat_func & msg_loc)) start_grid.objid = NULL_OBJID;
       if(start_grid.objid == search_id->objid) start_grid.objid = NULL_OBJID;
       if(start_grid.objid != NULL_OBJID)
        {
          eligible=FALSE;
          if(EFisAncestryValid(&msg_loc, start_grid.objid, start_grid.osnum,
              OPP_EMSsolid_class_id, FALSE))
               eligible=TRUE;
         }
       }
     else if(!EFisAncestryValid(&msg_loc, search_id->objid, search_id->osnum,
            OPP_EMSdatpln_class_id, FALSE))
       {
       eligible=TRUE;
       }

      if(eligible)
        {
          act_args =  &curr_info->actargs;
          stat_func = EMlocate_eligchk_hndlr (act_args, new_locinfo, priv_args,
              action);
        }

ret_end:
   return(stat_func);
}



end implementation ECaddraft;

