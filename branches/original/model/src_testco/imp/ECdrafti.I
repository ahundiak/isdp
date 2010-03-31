/* ###################   APOGEE COMPILED   ################## */
class implementation ECdraft;

/*
HISTORY

04 Dec 1989 RC  Modified to allow non_orthogonal draft vector in case
                surface draft.
09 Oct 1989 rlw Modified to support draft of non-planar curves.
                Also modified to use accept point to indicate offset side
                and swapped prompts around.

22 May 1989 jBk Replaced GRm_STRING masks with GRm_TEXT_VALUE.

19 May 1989 jBk Changed references of GRgetevent to co$getevent,
                including modification to use new value_type
                argument.

12 May 1989 jBk removed method wakeup; simplified init and sleep;

                replaced usages of mod_info instance variable
                with usages of previously existing md_env
                instance variable.

4/28/91     jhw Modified to call EMplace_drafted_surface.
8/08/91     scw Changed to use Grnuc associative flag
02/15/91    amd Initialized the angle field. replaced stackalloc with alloca.
07/22/92    NP	Updated for message subsystem compliance.
10-Feb-93  Jack Removed unnecessary import EMSgenbs.EMdrafted_surface.
03/30/93    NP  IMPORTANT NOTE:
                If passing in a string to ex$message through a buffer, the
                following fields HAVE to be specified: justification and field.
                There were two places that were putting a prompt in a buffer
                using one ex$message call (using a message key) and immediately
                displaying the prompt using another ex$message call. The
                justification was screwed up due to reason mentioned above.
                Modified to make each a single call with the message key.
07/05/93  Sudha Modified for BSprototypes ansification

*/

#include "EMS.h"
#include "OMerrordef.h"
#include <values.h>
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

#include "griomacros.h" /* co$getevent */

#include "bserr.h"
#include "bsicmpcvoff.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "exmacros.h"		/* ex$putqueue() */
#include "go.h"

#include "EMSdpb.h"     
#include "EMSopt.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"

#include "msmacros.h"		/* ex$message */
#include "ECcmd.h"
#include "ECmsg.h"
#include "EMSascmacros.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bscrossp.h"

 
#define X 0
#define Y 1
#define Z 2

#define ID_CURVE            0
#define FROM_POINT          1
#define TO_POINT            2
#define NON_ORTH_TO_POINT   3
#define DIR_POINT           4
#define UNIFORM             5
#define OFF_CODE            6
#define DRAFT_ANGLE         7
#define FILLET              8 
#define PROCESS             9

#define DFSUR           0
#define DFSOL           1

extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_EMSgencompsf_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSsfsolid_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GRcurve_class_id;

from GRgraphics import GRlnproject, GRdisplay;
from GRvg import GRgetattr, GRdetplane, GRgeomprops;
from GRcurve import GRgenabsg;
from EMSgencompsf import EMproject_with_draft;
from EMSsfsolid import EMcap_thyself;

method init (IGRint type; IGRchar *string)
{
  ME.super_cmd->state = ID_CURVE;
/*
  ME.ECelement->locate_stack.num_entries = 0;
  ME.ECelement->elem_hilit = FALSE;
  ME.super_cmd->mytype = type;

    taken care of by allocation (calloc) and by parent's init -- jBk
*/
  ex$message(msgnumb = EMS_P_No,  /* "[n]" */
             buff    = ME.ECdraft->fillet_def); 
  ex$message(msgnumb = EMS_P_Yes, /* "[y]" */
             buff    = ME.ECdraft->uniform_def); 
  ex$message(msgnumb = EMS_P_DraftOption,   /* "[d]" */
             buff    = ME.ECdraft->code_def); 
/*
  me->next_comp = 0;  

    taken care of by allocation (calloc) -- jBk
*/

  return om$send (
    mode = OM_e_wrt_parent,
    msg = message ECdraft.init (type, string),
    targetid = my_id
  );
}


method sleep(int pos)
{
 IGRint sts;

 sts = om$send (
    mode = OM_e_wrt_parent,
    msg = message ECdraft.sleep (pos),
    targetid = my_id
 );

 ME.ECelement->elem_hilit = FALSE;

 return sts;
}

method wakeup (int pos)
{
 IGRint sts;
 IGRboolean            state;

 sts = om$send ( mode = OM_e_wrt_parent,
                 msg = message ECdraft.wakeup (pos),
                 targetid = my_id );

 gr$get_associative_flag( buffer = &state );
 GRdisplay_associative_button(state);
 return(sts);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean assoc_placement;
  IGRboolean stat_func;
  IGRchar errmsg[EMMAXERRMSG_LEN], prompt[MAX_PROMPT_SIZE];
  IGRchar loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRint event_size, display_flag;
  IGRlong stat_OM, msg_loc;
  IGRlong event_mask1, event_mask2;
  IGRlong i;
  struct GRevent accev, event;
  struct GRlc_locate lc_attr;
  enum GRdpmode dpmode;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass;
  struct IGRplane       plane;
  IGRpoint              plane_point;
  IGRvector             plane_normal, sidevec, crossp;
  struct IGRline        boreline;
  IGRpoint              pnt1, pnt2, line_pt, cveval[2];
  IGRdouble             t, dotp, lensq;
  struct GRparms        proj_parms;
  GRobjid               closest_crv_id, new_surf, new_solid;
  struct IGRbsp_curve   *closest_crv_geom = NULL;
  IGRchar               *generic_pointer = NULL;
  OM_S_CHANSELECT       to_comps;
  OMuword               class_id;
  OM_S_OBJECT_LINKAGE   *oblist = NULL;
  IGRint                num_elements;
  IGRvector             temp_vector;
  struct                GRprops geom_props;
  BSrc                  rc;
  struct GRvg_construct *construction_list=NULL;

  extern   void        EMinitvgcnstr();
  extern   void        EMgetvgcnstr();  

 
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECdraft.execute");

  if (ME.super_cmd->mytype == DFSUR)  
  {
      ex$message(msgnumb = EM_M_PlaceDraftedSurf);
  }
  else if (ME.super_cmd->mytype == DFSOL)  
  {
      ex$message(msgnumb = EM_M_PlaceDraftedSolid);
  }

  do 
    {
    switch (ME.super_cmd->state)
      {
      case ID_CURVE:
        if (ME.ECelement->elem_hilit)
        {
        stat_OM = dp$erase_hilite(msg = &msg_loc,
                                  osnum = me->md_env.md_id.osnum,
                                  objid = me->md_env.md_id.objid);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;
        }
        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;
    display_flag = 6;

    ex$message(msgnumb = EMS_P_AccWithPtOnSideToDraftToReject,
               buff    = acc_prompt); 
    ex$message(msgnumb = EMS_I_CvNotLocated,
               buff    = reloc_prompt); 
    lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW | IGN_MOD_BIT;
    if (ME.super_cmd->mytype == DFSOL)
     {
      lc_attr.properties |= LC_PLANAR_ONLY;
      ex$message(msgnumb = EMS_P_00034, /* "Identify closed planar curve" */
                 buff    = loc_prompt); 
     }
    else
    {
     ex$message(msgnumb = EMS_P_IdCv, /* Identify curve */
                buff    = loc_prompt); 
    }
    lc_attr.owner_action = LC_RIGID_COMP | LC_RIGID_OWNER |
                           LC_FLEX_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER;
    strcpy(lc_attr.classes, "GRcurve");

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_GRbspline_class_id;
    eliclass = OPP_GRcurve_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;

    stat_func = lc$locate(rc = &msg_loc,
              event1 = &ME.ECelement->locev, 
              event2 = &accev,
              mask1 = event_mask1, 
              mask2 = event_mask2,
              eventsize= &event_size, 
              unhilight_mode = (enum GRdpmode) GRhd,
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &lc_attr, 
              stack = &ME.ECelement->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

        ex$message(msgnumb = EMS_P_ClearPromptField);
        ex$message(msgnumb = EMS_I_ClearStatusField);

        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else
            goto ret_end;
          }

        switch (accev.response)
          {
          case EX_DATA:
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem = accev.located_object[0];
        
            stat_OM = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                                 &me->elem.module_info.md_env.matrix_type,
                                 me->elem.module_info.md_env.matrix,
                                 &geom_props),
                       senderid = my_id,
                       targetid = ME.ECelement->elem.located_obj.objid,
                       targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            
            me->phy_closed = geom_props.phy_closed ? TRUE : FALSE;
            if (ME.super_cmd->mytype == DFSOL)
            {
                if (! me->phy_closed)
                {
                   ex$message(msgnumb = EMS_I_CvNotClosed);
                   break;
                }
            }
            stat_OM = om$get_classid(
                        objid = ME.ECelement->elem.located_obj.objid,
                        osnum = ME.ECelement->elem.located_obj.osnum,
                        p_classid = &class_id);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
 
            stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                          superclassid = OPP_EMScomposite_class_id);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            if (stat_OM != OM_S_SUCCESS)
            {
                stat_OM = OM_S_SUCCESS;
                me->num_comps = 0;
                me->is_composite = FALSE;
                me->is_uniform = TRUE;
            }
            else
            {
                me->is_composite = TRUE;
                stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

                stat_OM = om$get_channel_count(
                        objid = ME.ECelement->elem.located_obj.objid,
                        osnum = ME.ECelement->elem.located_obj.osnum,
                                p_chanselect = &to_comps,
                                count = (OMuint *)&me->num_comps);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
  
                oblist  = (OM_S_OBJECT_LINKAGE *) om$malloc(
                        size = (me->num_comps)*sizeof(OM_S_OBJECT_LINKAGE));
                EMerr_hndlr(!oblist, *response, TERMINATE, ret_end);

                stat_OM = om$get_channel_objects(
                        objid = ME.ECelement->elem.located_obj.objid,
                        osnum = ME.ECelement->elem.located_obj.osnum,
                                p_chanselect = &to_comps,
                                list = oblist,
                                size = (OMuint)me->num_comps,
                                count = (OMuint *)&me->num_comps);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

                num_elements = om$dimension_of(varray = me->comp_ids); 
                if (me->num_comps > num_elements)
                {
                  stat_OM = om$vla_set_dimension(varray = me->comp_ids,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);

                  stat_OM = om$vla_set_dimension(varray = me->ang_dis,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);

                  stat_OM = om$vla_set_dimension(varray = me->off_code,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);
                }      
                for (i=0; i<me->num_comps; i++) 
                  {
                    me->comp_ids[i] = oblist[i].S_objid;
                    me->ang_dis[i] = 0.0; /* AMD : 02/15/92 : Initialize */
                  }
                if (oblist) 
                   {
                   om$dealloc(ptr = oblist);
                   oblist = NULL;
                   }
            }
            plane.point = (IGRdouble *) &plane_point[0];
            plane.normal = (IGRdouble *) &plane_normal[0];
            stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRvg.GRdetplane(&msg_loc,
                         &me->elem.module_info.md_env.matrix_type,
                         me->elem.module_info.md_env.matrix,
                         &plane),
                       senderid = my_id,
                       targetid = ME.ECelement->elem.located_obj.objid,
                       targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            if (msg_loc != MSSUCC) me->is_linecase = TRUE;
            else
            {
                    me->is_linecase = FALSE;
                    me->vector[X] = plane.normal[X];
                    me->vector[Y] = plane.normal[Y];
                    me->vector[Z] = plane.normal[Z];
            }
/*
 * Push the accept event on the queue, unless the element
 * was located via an event generator.  rlw 10/09/89
 */
            if (me->locev.subtype == GRst_REGULAR)
             {
              ex$putque(
               msg = &msg_loc,
               response = &accev.response,
               byte = (long *)&event_size,
               buffer = (char *)&accev.event);
             } /* if (me->locev.subtype == GRst_REGULAR) */
            ME.super_cmd->state = DIR_POINT;
            break;
          default:
            goto ret_end;
          }
        break;


      case DIR_POINT:

        dpmode = GRhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me->elem.module_info.md_env.matrix_type,
                         me->elem.module_info.md_env.matrix,
                           &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                          targetid = ME.ECelement->elem.located_obj.objid,
                          targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit =TRUE;

/*
        ex$message(msgnumb = EMS_P_InputPtOnSideToDraftTo);
        event_mask = GRm_DATA | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
            msgnum = EMS_P_InputPtOnSideToDraftTo,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);

        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_DATA:
            ME.ECdraft->off_dirpt[X] = event.event.button.x;
            ME.ECdraft->off_dirpt[Y] = event.event.button.y;
            ME.ECdraft->off_dirpt[Z] = event.event.button.z;

            boreline.point1 = pnt1;  /* allocates storage for */
            boreline.point2 = pnt2;  /* the boreline          */

            EFboreline(&msg_loc, my_id, &event, &boreline);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            if (me->is_linecase)
            {
                    me->vector[0] = pnt2[0] - pnt1[0];
                    me->vector[1] = pnt2[1] - pnt1[1];
                    me->vector[2] = pnt2[2] - pnt1[2];
                    BSnorvec(&rc, me->vector);
                    EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);
            }
           stat_OM = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                         &me->elem.module_info.md_env.matrix_type,
                         me->elem.module_info.md_env.matrix,
                         &boreline,
                         line_pt, me->pt_on_crv, &t, &proj_parms),
                      senderid = my_id,
                      targetid = ME.ECelement->elem.located_obj.objid,
                      targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            if (me->is_composite) closest_crv_id = proj_parms.leaf_id.objid;
            else closest_crv_id = ME.ECelement->elem.located_obj.objid;

            /* now determine if right_side = TRUE or FALSE */
           
            stat_OM = om$send(msg = message GRcurve.GRgenabsg(&msg_loc,
                         &me->elem.module_info.md_env.matrix_type,
                         me->elem.module_info.md_env.matrix,
                       &generic_pointer),
                      senderid = my_id,
                      targetid = closest_crv_id,
                      targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            closest_crv_geom = (struct IGRbsp_curve *) generic_pointer;

            BScveval(closest_crv_geom, proj_parms.u, 1, cveval, &rc);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            sidevec[X] = line_pt[X] - cveval[0][X];
            sidevec[Y] = line_pt[Y] - cveval[0][Y];
            sidevec[Z] = line_pt[Z] - cveval[0][Z];

            BScrossp(&rc, cveval[1], me->vector, crossp);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            dotp = BSdotp(&rc, crossp, sidevec);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);
            me->right_side = (dotp > 0 ? TRUE : FALSE);
            ME.super_cmd->state = FROM_POINT;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = ID_CURVE;
            break;
          default:
            goto ret_end;
          }
        break;

       case FROM_POINT:
        ex$message(msgnumb = EMS_P_00049, /* Input from point */
                   buff    = prompt); 
/*
        ex$message(in_buff = prompt);
        event_mask = GRm_DATA | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event,
                     response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
            prompt = prompt,
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
            me->from_pt[X] = me->to_pt[X] = event.event.button.x;
            me->from_pt[Y] = me->to_pt[Y] = event.event.button.y;
            me->from_pt[Z] = me->to_pt[Z] = event.event.button.z;
            ME.super_cmd->state = TO_POINT;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = DIR_POINT;
            break;
          default:
            goto ret_end;
          }
        break;


      case TO_POINT:
        if (ME.super_cmd->mytype == DFSOL)  
        {
          ex$message(msgnumb = EMS_P_00050); /* Input to point */
        }
        else
        {
          ex$message(msgnumb = EMS_P_InputToPtBkupForNonOrtho);
        }


        EFdyvector(me->vector, me->from_pt, me->to_pt,
                   &ME.ECelement->active_display);
/*
        event_mask = GRm_DATA | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event,
                     response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
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
            me->to_pt[X] = event.event.button.x;
            me->to_pt[Y] = event.event.button.y;
            me->to_pt[Z] = event.event.button.z;

            temp_vector[X] = me->to_pt[X] - me->from_pt[X];
            temp_vector[Y] = me->to_pt[Y] - me->from_pt[Y];
            temp_vector[Z] = me->to_pt[Z] - me->from_pt[Z];

            dotp = BSdotp(&rc, temp_vector, me->vector);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            lensq = me->vector[X]*me->vector[X] + 
                    me->vector[Y]*me->vector[Y] + 
                    me->vector[Z]*me->vector[Z];

            t = dotp/lensq;

            me->to_pt[X] = me->from_pt[X] + t * me->vector[X];
            me->to_pt[Y] = me->from_pt[Y] + t * me->vector[Y];
            me->to_pt[Z] = me->from_pt[Z] + t * me->vector[Z];

            if (dotp < 0)
            {
                me->vector[X] = - me->vector[X];
                me->vector[Y] = - me->vector[Y];
                me->vector[Z] = - me->vector[Z];
                me->right_side = ! me->right_side;
            }
            me->length = BSdistptpt(&rc, me->from_pt, me->to_pt);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            for ( i = 0; i < 3; i++)
              me->draft_vec[i] = me->vector[i] * me->length;

            if (me->is_composite) ME.super_cmd->state = UNIFORM;
            else {me->next_comp = 0; ME.super_cmd->state = DRAFT_ANGLE;}
            me->non_orth = FALSE;
            break;
          case EX_BACK_UP:
             if (ME.super_cmd->mytype == DFSOL)  
              ME.super_cmd->state = FROM_POINT;
             else
              ME.super_cmd->state = NON_ORTH_TO_POINT;
            break;
          default:
            goto ret_end;
          }
        break;

      case NON_ORTH_TO_POINT:
        ex$message(msgnumb = EMS_P_00050); /* Input to point */
                                      
        EFrblineseg(me->from_pt, &ME.ECelement->active_display);
/*
        event_mask = GRm_DATA | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event,
                     response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_BACK_UP,
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
            me->to_pt[X] = event.event.button.x;
            me->to_pt[Y] = event.event.button.y;
            me->to_pt[Z] = event.event.button.z;

            me->draft_vec[X] = me->to_pt[X] - me->from_pt[X];
            me->draft_vec[Y] = me->to_pt[Y] - me->from_pt[Y];
            me->draft_vec[Z] = me->to_pt[Z] - me->from_pt[Z];

            dotp = BSdotp(&rc, me->draft_vec, me->vector);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            if (dotp < 0)
             me->right_side = ! me->right_side;

            if (me->is_composite) ME.super_cmd->state = UNIFORM;
            else {me->next_comp = 0; ME.super_cmd->state = DRAFT_ANGLE;}
            me->non_orth = TRUE;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = FROM_POINT;
            break;
          default:
            goto ret_end;
          }
        break;

      case UNIFORM:

        ex$message(msgnumb = EMS_P_UniformDraft,
                   buff    = prompt); 
        strcat (prompt, ME.ECdraft->uniform_def);
/*
        ex$message(in_buff = prompt);
        event_mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event,
                     response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            prompt = prompt,
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

        if (msg_loc == GRw_no_value) event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case STRING:
            if (toupper (event.event.keyin[0]) == 'Y')
              {
              ME.ECdraft->is_uniform = TRUE;
              ex$message(msgnumb = EMS_P_Yes,
                         buff    = ME.ECdraft->uniform_def); 
              }
            else if (toupper (event.event.keyin[0]) == 'N')
              {
              ME.ECdraft->is_uniform = FALSE;
              ex$message(msgnumb = EMS_P_No,
                         buff    = ME.ECdraft->uniform_def); 
              }
            else 
              {
              if (ME.ECdraft->uniform_def[1] == 'n')
                ME.ECdraft->is_uniform = FALSE;
              else
                ME.ECdraft->is_uniform = TRUE;
              }
            me->next_comp = 0;
            ME.super_cmd->state = DRAFT_ANGLE;
            break;
          case EX_RJT_MOVEON:
            if (ME.ECdraft->uniform_def[1] == 'n')
                ME.ECdraft->is_uniform = FALSE;
            else ME.ECdraft->is_uniform = TRUE;
            me->next_comp = 0;
            ME.super_cmd->state = DRAFT_ANGLE;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = me->non_orth ? NON_ORTH_TO_POINT : 
                                  TO_POINT;
            break;
          default:
            goto ret_end;
          }
        break;

  
      case OFF_CODE:

        stat_OM = dp$erase_hilite(msg = &msg_loc,
                                  osnum = me->md_env.md_id.osnum,
                                  objid = me->md_env.md_id.objid);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;

        dpmode = GRhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me->elem.module_info.md_env.matrix_type,
                         me->elem.module_info.md_env.matrix,
                           &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                       targetid = me->comp_ids[me->next_comp],
                       targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        ex$message(msgnumb = EMS_P_DrftOrPrsrvOrLinVar,
                   buff    = prompt); 
        strcat (prompt, ME.ECdraft->code_def);
/*
        ex$message(in_buff = prompt);
        event_mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event,
                     response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            prompt = prompt,
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

        if (msg_loc == GRw_no_value) event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case STRING:
            if (toupper (event.event.keyin[0]) == 'D')
              {
              me->off_code[me->next_comp] = BSCONSTOFF;
              ex$message(msgnumb = EMS_P_DraftOption,  /* [d] */
                         buff    = ME.ECdraft->code_def); 
              }
            else if (toupper (event.event.keyin[0]) == 'P')
              {
              me->off_code[me->next_comp] = BSPRESERVCVSHP;
              ex$message(msgnumb = EMS_P_PreserveOption,  
                         buff    = ME.ECdraft->code_def); 
              }
            else if (toupper (event.event.keyin[0]) == 'L')
              {
              me->off_code[me->next_comp] = BSLINVAROFF;
              ex$message(msgnumb = EMS_P_LinearVarOption,
                         buff    = ME.ECdraft->code_def); 
              }
            else 
              {
              if (ME.ECdraft->code_def[1] == 'd')
                      me->off_code[me->next_comp] = BSCONSTOFF;
              else if (ME.ECdraft->code_def[1] == 'p')
                      me->off_code[me->next_comp] = BSPRESERVCVSHP;
              else if (ME.ECdraft->code_def[1] == 'l')
                      me->off_code[me->next_comp] = BSLINVAROFF;
              }
              if (me->off_code[me->next_comp] == BSCONSTOFF)
                        ME.super_cmd->state = DRAFT_ANGLE;
              else if (me->next_comp && 
                        me->off_code[me->next_comp-1] != BSCONSTOFF)
              {
                        ex$message(msgnumb = EMS_I_IllegalDraftMode);
              }
              else if (!me->phy_closed && 
                       (!me->next_comp || me->next_comp + 1 == me->num_comps))
              {
                        ex$message(msgnumb = EMS_I_IllegalDraftMode);
              }
              else if (me->next_comp + 1 == me->num_comps)
                        ME.super_cmd->state = FILLET;
              else {me->next_comp++; ME.super_cmd->state = DRAFT_ANGLE;}
              break;
          case EX_RJT_MOVEON:
              if (ME.ECdraft->code_def[1] == 'd')
                      me->off_code[me->next_comp] = BSCONSTOFF;
              else if (ME.ECdraft->code_def[1] == 'p')
                      me->off_code[me->next_comp] = BSPRESERVCVSHP;
              else if (ME.ECdraft->code_def[1] == 'l')
                      me->off_code[me->next_comp] = BSLINVAROFF;
              if (me->off_code[me->next_comp] == BSCONSTOFF)
                        ME.super_cmd->state = DRAFT_ANGLE;
              else if (me->next_comp && 
                        me->off_code[me->next_comp-1] != BSCONSTOFF)
              {
                        ex$message(msgnumb = EMS_I_IllegalDraftMode);
              }
              else if (!me->phy_closed && 
                       (!me->next_comp || me->next_comp + 1 == me->num_comps))
              {
                        ex$message(msgnumb = EMS_I_IllegalDraftMode);
              }
              else if (me->next_comp + 1 == me->num_comps)
                        ME.super_cmd->state = FILLET;
              else {me->next_comp++; ME.super_cmd->state = DRAFT_ANGLE;}
              break;
          case EX_BACK_UP:
              if (me->next_comp == 0) ME.super_cmd->state = UNIFORM;
              else {me->next_comp--; ME.super_cmd->state = DRAFT_ANGLE;}
            break;
          default:
            goto ret_end;
          }
        stat_OM = dp$erase_hilite(msg = &msg_loc,
                                  osnum = me->md_env.md_id.osnum,
                                  objid = me->md_env.md_id.objid);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;
        break;

      case DRAFT_ANGLE:

        ex$message(msgnumb = EMS_P_EnterDraftAngle,
                   buff    = prompt); 
        if (me->is_uniform) me->next_comp = 0;
        else
        {
          IGRchar temp_buff[100];  /* defined for ex$message  */

          ex$message(msgnumb = EMS_P_BackToChaDraftMode,
                     buff    = temp_buff); 
          strcat(prompt,temp_buff);
  
          stat_OM = dp$erase_hilite(msg = &msg_loc,
                                    osnum = me->md_env.md_id.osnum,
                                    objid = me->md_env.md_id.objid);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                     ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
        }
        dpmode = GRhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me->elem.module_info.md_env.matrix_type,
                         me->elem.module_info.md_env.matrix,
                           &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                          targetid = (me->is_uniform ? 
                                ME.ECelement->elem.located_obj.objid :
                                me->comp_ids[me->next_comp]),
                       targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
/*
        ex$message(in_buff = prompt);
        event_mask = GRm_ANGLE | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_VALUE | GRm_BACK_UP,
            value_type = GRIO_ANGLE,
            prompt = prompt,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);

        if (stat_func == FALSE)
          {
          ex$message(msgnumb = EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
          }
        if (msg_loc == GRw_no_value)
          {
           ex$message(msgnumb = EMS_I_00006); /* No default is supplied */
           break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_VALUE:
            if (event.event.value < 0.0)
              {             
                ex$message(msgnumb = EMS_I_AngleMustBePositive);
                break;
              }
            me->ang_dis[me->next_comp] = event.event.value;
            me->off_code[me->next_comp] = BSCONSTOFF;
            if (me->is_uniform || me->next_comp + 1 == me->num_comps)
                         ME.super_cmd->state = FILLET;
            else 
            {
                me->next_comp++;
            }
            break;
          case EX_BACK_UP:
            if (me->is_uniform)
            {
                if (me->is_composite)  ME.super_cmd->state = UNIFORM;
                else ME.super_cmd->state = me->non_orth ? 
                                           NON_ORTH_TO_POINT : TO_POINT;
            }
            else ME.super_cmd->state = OFF_CODE;
            break;
          default:
            goto ret_end;
          }
        if (! me->is_uniform)
        {
        stat_OM = dp$erase_hilite(msg = &msg_loc,
                                  osnum = me->md_env.md_id.osnum,
                                  objid = me->md_env.md_id.objid);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;
        }
        break;


      case FILLET:

        if (! ME.ECelement->elem_hilit)
        {
        dpmode = GRhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me->elem.module_info.md_env.matrix_type,
                         me->elem.module_info.md_env.matrix,
                           &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                          targetid = ME.ECelement->elem.located_obj.objid,
                          targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit =TRUE;
        }
        ex$message(msgnumb = EMS_P_DraftWithFillet,
                   buff    = prompt); 
        strcat (prompt, ME.ECdraft->fillet_def);
/*
        ex$message(in_buff = prompt);
        event_mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event,
                     response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            prompt = prompt,
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

        if (msg_loc == GRw_no_value) event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case STRING:
            if (toupper (event.event.keyin[0]) == 'Y')
              {
              ME.ECdraft->fillet = TRUE;
              ex$message(msgnumb = EMS_P_Yes,
                         buff    = ME.ECdraft->fillet_def); 
              }
            else if (toupper (event.event.keyin[0]) == 'N')
              {
              ME.ECdraft->fillet = FALSE;
              ex$message(msgnumb = EMS_P_No,
                         buff    = ME.ECdraft->fillet_def); 
              }
            else 
              {
              if (ME.ECdraft->fillet_def[1] == 'n')
                ME.ECdraft->fillet = FALSE;
              else
                ME.ECdraft->fillet = TRUE;
              }
            ME.super_cmd->state = PROCESS;
            break;
          case EX_RJT_MOVEON:
            if (ME.ECdraft->fillet_def[1] == 'n')
                ME.ECdraft->fillet = FALSE;
            else ME.ECdraft->fillet = TRUE;
            ME.super_cmd->state = PROCESS;
            break;
          case EX_BACK_UP:
            if (me->is_uniform) ME.super_cmd->state = DRAFT_ANGLE;
            else 
            {
                me->next_comp = me->num_comps - 1;
                ME.super_cmd->state = DRAFT_ANGLE;
            }
            break;
          default:
            goto ret_end;
          }
        break;


      case PROCESS:
        {
            struct EMSobject_info   loc_curve;
            struct EMSpoint_info    loc_vector[2];
            struct EMSvalue_info  * loc_angles;
            IGRint                  num_sides, is_solid;
            
            is_solid = (ME.super_cmd->mytype != DFSUR);

            gr$get_associative_flag( buffer = &assoc_placement );

            loc_vector[0].type = EMSdatainfo_numeric;
            memcpy(loc_vector[0].pt, me->from_pt, sizeof(IGRpoint));

            loc_vector[1].type = EMSdatainfo_numeric;
            memcpy(loc_vector[1].pt, me->to_pt, sizeof(IGRpoint));

            loc_curve.grid = ME.ECelement->elem.located_obj;
            loc_curve.env  = ME.ECelement->elem.module_info;

            num_sides = (ME.ECdraft->is_uniform) ? 1 : me->num_comps;

            loc_angles = (struct EMSvalue_info *) alloca(num_sides * 
                                          sizeof(struct EMSvalue_info));
            
            for (i=0; i<num_sides; ++i)
            {
                loc_angles[i].type = EMSdatainfo_numeric;
                loc_angles[i].val  = me->ang_dis[i] * 180/M_PI;  /*degrees*/
            }
            
            ex$message(msgnumb = EMS_S_Processing); /* "Processing..." */

            stat_OM = dp$erase_hilite(msg = &msg_loc,
                                      osnum = me->md_env.md_id.osnum,
                                      objid = me->md_env.md_id.objid);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                 ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            ME.ECelement->elem_hilit = FALSE;
/******************************************************************************
            stat_OM = EMplace_drafted_surface
                            ( &me->msg,
                              assoc_placement ? NULL : EMSasconst_notassociative,
                              &me->md_env, 
                              ME.ECelement->active_level,
                              &ME.ECelement->active_display,
                              NULL,
                              NULL,
                              &loc_curve,
                              loc_vector,
                              loc_angles,
                              ME.ECdraft->off_code,
                              num_sides,
                              ME.ECdraft->is_uniform,
                              ME.ECdraft->fillet,
                              ME.ECdraft->right_side,
                              is_solid,
                              is_solid ? &new_solid : &new_surf );
******************************************************************************/
            construction_list = (struct GRvg_construct *) om$malloc(size =
                                              sizeof(struct GRvg_construct));
            EMinitvgcnstr(&me->msg, &me->md_env,
                           &ME.ECelement->active_display,
                           NULL, construction_list);
            EMgetvgcnstr(NULL, NULL, &me->md_env, ME.ECelement->active_level,
                         &ME.ECelement->active_display, NULL, NULL, 
                         construction_list);
            stat_OM = ems$pl_drafted_surface(msg = &me->msg,
                 options = assoc_placement ? NULL : EMSasconst_notassociative,
                 curve = &loc_curve,
                 vector = loc_vector,
                 angles = loc_angles,
                 codes = ME.ECdraft->off_code,
                 num_sides = num_sides,
                 is_uniform = ME.ECdraft->is_uniform,
                 is_fillet = ME.ECdraft->fillet,
                 is_right_side = ME.ECdraft->right_side,
                 is_solid = is_solid,
                 construction_list = construction_list, 
                 draft_object = is_solid ? &new_solid : &new_surf );    
            if(construction_list)
              {
              om$dealloc(ptr = construction_list);
              construction_list = NULL;
              }
              
            if (msg_loc == EMS_I_InvalidArg || msg_loc == EMS_I_BSerror)
            {
                ex$message(msgnumb = EMS_I_DraftedSurfCantCreate);
                ME.super_cmd->state = ID_CURVE;
                break;
            }
            EMerr_hndlr (!(1&stat_OM&msg_loc), *response,TERMINATE, ret_end);

            dpmode = GRbd;
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay (&msg_loc,
                             &me->md_env.md_env.matrix_type,
                             me->md_env.md_env.matrix,
                               &dpmode, &me->md_env.md_id),
                              senderid = my_id,
                       targetid = (ME.super_cmd->mytype == DFSUR ?
                                            new_surf : new_solid),
                       targetos = me->md_env.md_id.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
               ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            if (ME.super_cmd->mytype == DFSUR) 
            {
                   ex$message(msgnumb = EMS_I_DraftedSurfCreated);
            }
            else if (ME.super_cmd->mytype == DFSOL) 
            {
                   ex$message(msgnumb = EMS_I_DraftedSolidCreated);
            }
            ME.super_cmd->state = ID_CURVE;
        }
        break;

      default:
        ex$message(msgnumb = EMS_F_CommandIllegalState);
        printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
        *response = TERMINATE;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
   if (oblist) 
     {
     om$dealloc(ptr = oblist);
     oblist = NULL;
     }
   if(construction_list)
     {
     om$dealloc(ptr = construction_list);
     construction_list = NULL;
     }
  return (stat_OM);
}

end implementation ECdraft;

