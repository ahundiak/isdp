class implementation ECcvoffset;

/*
History

08/14/94    scw     clarified sleep method
12/29/93    HGB     Don't pass NULL for the parms of GRmidpoint
07/05/93    Sudha   Modified for BSprototypes ansification
9 June 1992 Tapadia Modified for message sub system compliance

09 Oct 1989 rlw Modified to support offset of non-planar curves.
                Also modified to use accept point to indicate offset side.

22 May 1989 jBk Replaced GRm_STRING masks with GRm_TEXT_VALUE.

19 May 1989 jBk Changed references of GRgetevent to co$getevent,
                including modification to use new value_type
                argument.

11 May 1989 jBk Moved prompt clearance and command name
                presenting from wakeup to execute;

                eliminated wakeup;

                Modified sleep to send to parent and not do any
                erasing or field presenting;

                removed references to me^^ECcvoffset.mod_info in
                favor of pre-existing and unutilized
                me^^EClement.md_env;

                removed gr$get calls and some initializations
                which occur in ECelement's init from this init
                while adding a send to parent of init.

dhm  01/20/89   Initialized const_list->msg.

RV   ??/??/88   creation date.

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
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_I.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bscrossp.h"

#define X 0
#define Y 1
#define Z 2

#define ID_CURVE        0
#define DIR_POINT       1
#define UNIFORM         2
#define OFF_CODE        3
#define OFF_DIST        4
#define FILLET          5
#define PROCESS         6

extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRcurve_class_id;

from GRgraphics import GRlnproject, GRdisplay;
from GRvg import GRgetattr, GRdetplane, GRgeomprops;
from GRcurve import EMcvoffset, GRgenabsg, GRmidpoint;

method init (IGRint type; IGRchar *string)
{
  IGRchar errmsg[EMMAXERRMSG_LEN];

  strcpy (errmsg, "ECcvoffset.init");

  ME.super_cmd->state = ID_CURVE;
  strcpy (ME.ECcvoffset->fillet_def, "[n]");
  strcpy (ME.ECcvoffset->uniform_def, "[y]");
  strcpy (ME.ECcvoffset->code_def, "[o]");
  me->remove_loops = TRUE;
  me->next_comp = 0;  
  
  return om$send (
        mode = OM_e_wrt_parent,
        msg = message ECcvoffset.init (type, string),
        targetid = my_id
    );
}

method super_cmd.sleep(int pos)
{
    IGRint sts;

    sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECcvoffset.sleep (pos),
        targetid = my_id
    );

    ME.ECelement->elem_hilit = FALSE;

    return(sts);
}



method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRchar errmsg[EMMAXERRMSG_LEN], prompt[MAX_PROMPT_SIZE];
  IGRchar temp_prompt[MAX_PROMPT_SIZE];
  IGRchar loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRlong event_size;
  IGRint  display_flag;
  IGRlong stat_OM, msg_loc;
  IGRlong event_mask1, event_mask2;
  IGRlong i;
  struct GRevent accev, event;
  struct GRlc_locate lc_attr;
  struct GRvg_construct const_list;
  struct IGResbc esbc;
  enum GRdpmode dpmode;
  struct GRid cvoffset_id;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OMuword               rclass, eliclass;
  struct IGRplane       plane;
  IGRpoint              plane_point;
  IGRvector             plane_normal, sidevec, crossp;
  struct IGRline        boreline;
  IGRpoint              pnt1, pnt2, line_pt, cveval[2];
  IGRdouble             t, dotp;
  struct GRparms        proj_parms;
  GRobjid               closest_crv_id;
  struct IGRbsp_curve   *closest_crv_geom = NULL;
  IGRchar               *generic_pointer = NULL;
  OM_S_CHANSELECT       to_comps;
  OMuword               class_id;
  OM_S_OBJECT_LINKAGE   *oblist = NULL;
  IGRint                num_elements;
  struct                GRprops geom_props;
  BSrc                  rc;


  ex$message(msgnumb = EMS_P_ClearPromptField);
  ex$message(msgnumb = EM_M_POfCr);
 
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECcvoffset.execute");

  do 
    {
    switch (ME.super_cmd->state)
      {
      case ID_CURVE:

        if (ME.ECelement->elem_hilit)
        {
        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;
        }
        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;
	ex$message(msgnumb = EMS_P_00030, buff = loc_prompt)
    display_flag = 6;

    ex$message(msgnumb = EMS_P_AccWiPtOnSiToOffsetRej, buff = acc_prompt);
    ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW | IGN_MOD_BIT;
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
              eventsize= (int *)&event_size, 
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

	ex$message(msgnumb = EMS_I_ClearStatusField);
	ex$message(msgnumb = EMS_P_ClearPromptField);
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
            ME.ECelement->elem.located_obj.objid = accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = accev.located_object[0].
                                         located_obj.osnum;

            stat_OM = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &geom_props),
                       senderid = my_id,
                       targetid = ME.ECelement->elem.located_obj.objid,
                       targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            
            me->phy_closed = geom_props.phy_closed ? TRUE : FALSE;

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

                  stat_OM = om$vla_set_dimension(varray = me->comp_dis,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);

                  stat_OM = om$vla_set_dimension(varray = me->off_code,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);
                }      
                for (i=0; i<me->num_comps; i++) 
                                me->comp_ids[i] = oblist[i].S_objid;
                if (oblist) om$dealloc(ptr = oblist);
            }
            plane.point = (IGRdouble *) &plane_point[0];
            plane.normal = (IGRdouble *) &plane_normal[0];
            stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRvg.GRdetplane(&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &plane),
                       senderid = my_id,
                       targetid = ME.ECelement->elem.located_obj.objid,
                       targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            if (msg_loc != MSSUCC) me->is_linecase = TRUE;


/* plane normal is taken as the vector for offset , instead of the view
   vector, until the math function is ready to do view-offset.
*/
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
               response = (int *)&accev.response,
               byte = &event_size,
               buffer = (char *)&accev.event);
             } /* if (me->locev.subtype == GRst_REGULAR) */
            ME.super_cmd->state = DIR_POINT;
            break;
          default:
            goto ret_end;
          }
        break;


      case DIR_POINT:
/*
        event_mask = GRm_DATA | GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
	ex$message(msgnumb = EMS_P_InPtOnSideOffset, buff = prompt); 
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
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_DATA:
            ME.ECcvoffset->off_dirpt[X] = event.event.button.x;
            ME.ECcvoffset->off_dirpt[Y] = event.event.button.y;
            ME.ECcvoffset->off_dirpt[Z] = event.event.button.z;

            boreline.point1 = pnt1;  /* allocates storage for */
            boreline.point2 = pnt2;  /* the boreline          */

            EFboreline(&msg_loc, my_id, &event, &boreline);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

/* this is how the vector for offset must be defined, for all curves, once 
   view-offset can be done.
*/
            if (me->is_linecase)
            {
                    me->vector[0] = pnt2[0] - pnt1[0];
                    me->vector[1] = pnt2[1] - pnt1[1];
                    me->vector[2] = pnt2[2] - pnt1[2];
                    BSnorvec(&rc, me->vector);
                    EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);
            }
            stat_OM = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
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
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
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

            if (me->is_composite) ME.super_cmd->state = UNIFORM;
            else {me->next_comp = 0; ME.super_cmd->state = OFF_DIST;}
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = ID_CURVE;
            break;
          default:
            goto ret_end;
          }
        break;


      case UNIFORM:
	ex$message(msgnumb = EMS_P_UniformOffset , buff = prompt);
        strcat (prompt, ME.ECcvoffset->uniform_def);
/*
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
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
          }
        if (msg_loc == GRw_no_value) event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC) goto ret_end;             
        switch (event.response)
          {
          case STRING:
            if (toupper (event.event.keyin[0]) == 'Y')
              {
              ME.ECcvoffset->is_uniform = TRUE;
              strcpy (ME.ECcvoffset->uniform_def, "[y]");
              }
            else if (toupper (event.event.keyin[0]) == 'N')
              {
              ME.ECcvoffset->is_uniform = FALSE;
              strcpy (ME.ECcvoffset->uniform_def, "[n]");
              }
            else 
              {
              if (ME.ECcvoffset->uniform_def[1] == 'n')
                ME.ECcvoffset->is_uniform = FALSE;
              else
                ME.ECcvoffset->is_uniform = TRUE;
              }
            me->next_comp = 0;
            ME.super_cmd->state = OFF_DIST;
            break;
          case EX_RJT_MOVEON:
            if (ME.ECcvoffset->uniform_def[1] == 'n')
                ME.ECcvoffset->is_uniform = FALSE;
            else ME.ECcvoffset->is_uniform = TRUE;
            me->next_comp = 0;
            ME.super_cmd->state = OFF_DIST;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = DIR_POINT;
            break;
          default:
            goto ret_end;
          }
        break;


      case OFF_CODE:

        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;

        dpmode = GRhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                           &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                       targetid = me->comp_ids[me->next_comp],
                       targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

	ex$message(msgnumb = EMS_P_OffsetPreLinVar, buff = prompt); 
        strcat (prompt, ME.ECcvoffset->code_def);
/*
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
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
          }
        if (msg_loc == GRw_no_value) event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC) goto ret_end;             
        switch (event.response)
          {
          case STRING:
            if (toupper (event.event.keyin[0]) == 'O')
              {
              me->off_code[me->next_comp] = BSCONSTOFF;
              strcpy (ME.ECcvoffset->code_def, "[o]");
              }
            else if (toupper (event.event.keyin[0]) == 'P')
              {
              me->off_code[me->next_comp] = BSPRESERVCVSHP;
              strcpy (ME.ECcvoffset->code_def, "[p]");
              }
            else if (toupper (event.event.keyin[0]) == 'L')
              {
              me->off_code[me->next_comp] = BSLINVAROFF;
              strcpy (ME.ECcvoffset->code_def, "[l]");
              }
            else 
              {
              if (ME.ECcvoffset->code_def[1] == 'o')
                      me->off_code[me->next_comp] = BSCONSTOFF;
              else if (ME.ECcvoffset->code_def[1] == 'p')
                      me->off_code[me->next_comp] = BSPRESERVCVSHP;
              else if (ME.ECcvoffset->code_def[1] == 'l')
                      me->off_code[me->next_comp] = BSLINVAROFF;
              }
              if (me->off_code[me->next_comp] == BSCONSTOFF)
                        ME.super_cmd->state = OFF_DIST;
              else if (me->next_comp && 
                        me->off_code[me->next_comp-1] != BSCONSTOFF)
			ex$message(msgnumb = EMS_S_IllegalOffMode)   
              else if (!me->phy_closed && 
                       (!me->next_comp || me->next_comp + 1 == me->num_comps))
			ex$message(msgnumb = EMS_S_IllegalOffMode)   
              else if (me->next_comp + 1 == me->num_comps)
                        ME.super_cmd->state = FILLET;
              else {me->next_comp++; ME.super_cmd->state = OFF_DIST;}
              break;
          case EX_RJT_MOVEON:
              if (ME.ECcvoffset->code_def[1] == 'o')
                      me->off_code[me->next_comp] = BSCONSTOFF;
              else if (ME.ECcvoffset->code_def[1] == 'p')
                      me->off_code[me->next_comp] = BSPRESERVCVSHP;
              else if (ME.ECcvoffset->code_def[1] == 'l')
                      me->off_code[me->next_comp] = BSLINVAROFF;
              if (me->off_code[me->next_comp] == BSCONSTOFF)
                        ME.super_cmd->state = OFF_DIST;
              else if (me->next_comp && 
                        me->off_code[me->next_comp-1] != BSCONSTOFF)
			ex$message(msgnumb = EMS_S_IllegalOffMode)   
              else if (!me->phy_closed && 
                       (!me->next_comp || me->next_comp + 1 == me->num_comps))
			ex$message(msgnumb = EMS_S_IllegalOffMode)   
              else if (me->next_comp + 1 == me->num_comps)
                        ME.super_cmd->state = FILLET;
              else {me->next_comp++; ME.super_cmd->state = OFF_DIST;}
              break;
          case EX_BACK_UP:
              if (me->next_comp == 0) ME.super_cmd->state = UNIFORM;
              else {me->next_comp--; ME.super_cmd->state = OFF_DIST;}
            break;
          default:
            goto ret_end;
          }
        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;
        break;

  
      case OFF_DIST:
	ex$message(msgnumb = EMS_P_EnterOffDist, buff = prompt); 
        if (me->is_uniform) me->next_comp = 0;
        else
        {
		ex$message(msgnumb = EMS_P_BackToChaOffMode,buff = temp_prompt); 
		strcat(prompt, temp_prompt);

        	stat_OM = dp$erase_hilite(msg = &msg_loc);
        	EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
       	 	EMerr_hndlr(EMis_error(msg_loc),*response, TERMINATE, ret_end);
        	ME.ECelement->elem_hilit = FALSE;
        }
        dpmode = GRhd;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                           &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                          targetid = (me->is_uniform ? 
                                ME.ECelement->elem.located_obj.objid :
                                me->comp_ids[me->next_comp]),
                       targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        {
          struct GRparms curve_parms;
        
	  /* Purify : initialize curve u parameter */ 
	  curve_parms.u = 0.5; 
          stat_OM = om$send(msg = message GRcurve.GRmidpoint (&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &curve_parms, me->pt_on_crv),
                          senderid = my_id,
                       targetid = (me->is_composite ?
                                        me->comp_ids[me->next_comp] : 
                                        ME.ECelement->elem.located_obj.objid),
                       targetos = ME.ECelement->elem.located_obj.osnum);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
            ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        }

	ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
		in_buff = prompt);
        EFrblineseg (ME.ECcvoffset->pt_on_crv,
                                 &ME.ECelement->active_display);
/*
        event_mask = GRm_DATA | GRm_DIST | GRm_BACK_UP;

        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP,
            value_type = GRIO_DISTANCE,
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
		ex$message(msgnumb = EMS_I_00006);
          	break;
          }
        if (msg_loc != MSSUCC)
          goto ret_end;
        switch (event.response)
          {
          case EX_DATA:
            me->comp_dis[me->next_comp]  = BSdistptpt (&msg_loc, 
                                       ME.ECcvoffset->pt_on_crv, 
                                       &event.event.button.x);
            EMerr_hndlr (msg_loc != BSSUCC, *response, TERMINATE, ret_end);

            me->off_code[me->next_comp] = BSCONSTOFF;
            if (me->is_uniform || me->next_comp + 1 == me->num_comps)
                         ME.super_cmd->state = FILLET;
            else me->next_comp++;
            break;
          case EX_VALUE:
            if (event.event.value < 0.0)
              {             
		ex$message(msgnumb = EMS_I_DistMustBepositive);
              	break;
              }
            me->comp_dis[me->next_comp] = event.event.value;
            me->off_code[me->next_comp] = BSCONSTOFF;
            if (me->is_uniform || me->next_comp + 1 == me->num_comps)
                         ME.super_cmd->state = FILLET;
            else me->next_comp++;
            break;
          case EX_BACK_UP:
            if (me->is_uniform)
            {
                if (me->is_composite)  ME.super_cmd->state = UNIFORM;
                else ME.super_cmd->state = DIR_POINT;
            }
            else  ME.super_cmd->state = OFF_CODE;
            break;
          default:
            goto ret_end;
          }
        if (! me->is_uniform)
        {
          stat_OM = dp$erase_hilite(msg = &msg_loc);
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
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                           &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                          targetid = ME.ECelement->elem.located_obj.objid,
                          targetos = ME.ECelement->elem.located_obj.osnum);
        	EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           		ret_end, errmsg);
        	EMerr_hndlr(EMis_error(msg_loc), *response, TERMINATE, ret_end);
        	ME.ECelement->elem_hilit =TRUE;
        }
	ex$message(msgnumb = EMS_P_OffWithFillet, buff = prompt);
        strcat (prompt, ME.ECcvoffset->fillet_def);
	ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
		in_buff = prompt);
/*
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
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
          }
        if (msg_loc == GRw_no_value) event.response = EX_RJT_MOVEON;
        else if (msg_loc != MSSUCC) goto ret_end;             
        switch (event.response)
          {
          case STRING:
            if (toupper (event.event.keyin[0]) == 'Y')
              {
              ME.ECcvoffset->fillet = TRUE;
              strcpy (ME.ECcvoffset->fillet_def, "[y]");
              }
            else if (toupper (event.event.keyin[0]) == 'N')
              {
              ME.ECcvoffset->fillet = FALSE;
              strcpy (ME.ECcvoffset->fillet_def, "[n]");
              }
            else 
              {
              if (ME.ECcvoffset->fillet_def[1] == 'n')
                ME.ECcvoffset->fillet = FALSE;
              else
                ME.ECcvoffset->fillet = TRUE;
              }
            ME.super_cmd->state = PROCESS;
            break;
          case EX_RJT_MOVEON:
            if (ME.ECcvoffset->fillet_def[1] == 'n')
                ME.ECcvoffset->fillet = FALSE;
            else ME.ECcvoffset->fillet = TRUE;
            ME.super_cmd->state = PROCESS;
            break;
          case EX_BACK_UP:
            if (me->is_uniform) ME.super_cmd->state = OFF_DIST;
            else 
            {
                me->next_comp = me->num_comps - 1;
                ME.super_cmd->state = OFF_DIST;
            }
            break;
          default:
            goto ret_end;
          }
        break;


      case PROCESS:

	ex$message(msgnumb = EMS_S_Processing);

        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;

        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRvg.GRgetattr
                   (&msg_loc, (char *)&esbc),
                          senderid = my_id,
                          targetid = ME.ECelement->elem.located_obj.objid,
                          targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
         ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
         ret_end);

        const_list.msg = &msg_loc;
        const_list.env_info = &me->md_env;
        const_list.newflag = FALSE;
        const_list.level = ME.ECelement->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_NEW | GRIS_LOCATABLE;
        const_list.geometry = NULL;
        const_list.display = &ME.ECelement->active_display;
        const_list.class_attr = (char *)&esbc;
        const_list.name = NULL;

        stat_OM = om$send(msg = message GRcurve.EMcvoffset(&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                   &const_list,
                   ME.ECcvoffset->comp_dis, ME.ECcvoffset->vector, 
                   ME.ECcvoffset->right_side,
                   ME.ECcvoffset->is_uniform, 
                   ME.ECcvoffset->off_code,
                   ME.ECcvoffset->fillet, 
                   ME.ECcvoffset->remove_loops, &cvoffset_id,
                   NULL, NULL, NULL),
                          senderid = my_id,
                          targetid = ME.ECelement->elem.located_obj.objid,
                          targetos = ME.ECelement->elem.located_obj.osnum);
/* 01/27/89 : rlw : Modified not to kill on error */
        if (msg_loc == EMS_I_InvalidArg)
              	{
			ex$message(msgnumb = EMS_S_InvalidOfstCode);
                 	ME.super_cmd->state = ID_CURVE; break;
		}
        else if ((msg_loc == EMS_I_BSerror) ||
                 (! (1 & msg_loc)) ||
                 (! (1 & stat_OM)))
               	{
			ex$message(msgnumb = EMS_S_OfstCrvCantBeCrtd);
                 	ME.super_cmd->state = ID_CURVE; break;
		}
        else 	ex$message(msgnumb = EMS_S_OfstCrvCrtd)
        dpmode = GRbd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                   &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                       targetid = cvoffset_id.objid,
                       targetos = cvoffset_id.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
         ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
         ret_end);

        ME.super_cmd->state = ID_CURVE;
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
  return (stat_OM);
}

end implementation ECcvoffset;

