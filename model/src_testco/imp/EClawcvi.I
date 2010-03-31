/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This file contains the command object that creates and manipulates
    the law-curves generally used in the system. It also contains the
    function that the rest of the system can use to obtain a given law
    curve definition by it's name. This function is called EMget_lawcurve
    and has three arguments - retmsg, lawcv_name, lawcv (* IGRlong, * IGRchar,
    ** struct IGRbsp_curve).

  HISTORY

    scw :  08/14/94  :  Clarified sleep method
    SY  :  10/06/93  :  Not to output message EMS_S_VarCurNotUniq.
    SY  :  06/30/93  :  Modified to make it associative.
Rustagi :  05/25/92  :  Modified for Message Sub-system Compliance  
    SS  :  08/15/89  :  Creation
*/

class implementation EClawcv;

#include "EMS.h"
#include <stdio.h>
#include <string.h>
#include "exdef.h"
#include "exmacros.h"
#include "maerr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSlc.h"
#include "EC_P.h"
#include "EC_M.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "REcurve.h"
#include "grmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

/*
 * The law curve should be able to generate atleast this many number
 * unique points w.r.t. the lenght tolerance. That is, it should have
 * a lenght of atleast this number times the length tolerance in the
 * X-direction.
 */

#define MINNUMPTS_ON_LAWCV	100


#define MAXSIZE_PRODPATHNAME	200
#define MAXNUM_PRODPATHS	20
#define INVALID_INX 		-1
#define COMM_FILE		"/tmp/_lawcv_temp"
#define NULL_MGR		-1

#define WINEXT_XMIN		5
#define WINEXT_YMIN		130
#define WINEXT_XMAX		505
#define WINEXT_YMAX		575

#define INITIAL_STATE	0

#define CREATE_LAWCV	0
#define SHOW_LAWCV   	1
#define MODIFY_LAWCV 	2
#define OUTPUT_LAWCV	3

#define LOCATE_CREATE_STATE  	0
#define XPT1_CREATE_STATE	1
#define XPT2_CREATE_STATE	2
#define NAME_CREATE_STATE	3

#define NAME_SHOW_STATE		0

#define NAME_MODIFY_STATE	0
#define OPTION_MODIFY_STATE	1

#define NAME_OUTPUT_STATE	0
#define XPT1_OUTPUT_STATE	1
#define XPT2_OUTPUT_STATE	2

#define TEST_EXISTS  0
#define TEST_EXECUTE 1
#define TEST_SUCCESS 0

#define X 0
#define Y 1
#define Z 2
#define W 3

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

%safe
static long int _lawmgr = -1;
static void put_lawcurve(), show_lawcurve(), delete_lawcurve();
%endsafe

extern GRclassid OPP_EMSlawmgr_class_id, OPP_GRcurve_class_id;
extern GRclassid OPP_GRbspline_class_id, OPP_GAbcsubbc_class_id;
extern GRclassid OPP_EMSsubbs_class_id;

from GRcurve import GRendpts;
from EMSlawmgr import EMinit, EMputcv, EMgetcv;
from EMSassoc import EMget_parent_info;
from GRgraphics import GRconstruct;

method wakeup(IGRint pos)
{
  IGRlong sts = OM_S_SUCCESS;
  IGRboolean assoc_state;

  gr$get_associative_flag(buffer = &assoc_state);
  if (assoc_state)
  {
    GRdisplay_associative_button(TRUE);
    me->associative = TRUE;
  }

  sts = om$send(msg = message ECelements.wakeup(pos),
                mode = OM_e_wrt_message,
                targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  return sts;
}

method super_cmd.sleep(IGRint pos)
{
  IGRlong sts = OM_S_SUCCESS;

  sts = om$send(msg = message ECelements.sleep(pos),
                mode = OM_e_wrt_message,
                targetid = my_id);
  if (!(1 & sts))
    return OM_E_ABORT;

  if (me->associative)
    GRdisplay_associative_button(FALSE);

  return sts;
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func, badcv, assoc_placement;
  IGRchar cvname[MAX_CHAR+1], stat_prompt[MAX_CHAR+1], buff1[MAX_CHAR+1];
  IGRshort *mattyp, xform_mattyp_temp, xform_mattyp, four=4;
  IGRint i, j, cvinx, subtype, substate, two=2;
  IGRlong msg_loc, stat_OM, eventmask, acceptmask;
  IGRdouble *mat, *plnnor, *xpts, scales[4], tempd, lentol;
  IGRpoint blinept1, blinept2, dumpt, minrng, maxrng, xform_xpts[2];
  IGRvector xaxis;
  IGRmatrix idmat, xform_mat_temp, xform_mat, xrot_mat;
  struct IGRline bline;
  struct IGRplane cvplane;
  struct GRevent event, lc_event;
  struct IGRbsp_curve *cvgeom;
  struct GRmd_env *md_env;
  struct GRid cvid;
  enum EMSdatatype dattyp;
  enum EMSuser_responses useract;

  struct GRvg_construct construct_list;	/* standard construction list */
  struct EMSobject_info parent;		/* parent of the law curve    */
  IGRint info_size = 0;			/* size of recompute info     */
  struct EMSlaw_curve *lawcv_info = NULL;/* recompute info            */
  OM_S_OBJID constructed_lawcv;
  OM_S_CLASSLIST rtree_class, elig_class;
  OMuword rtree_classid, elig_classid;
  struct GRlc_locate lc_attr;
  
  extern void flip_lawcurve(), output_lawcurve();
  extern void EMtoplnxform();
  extern IGRboolean MAxrotmx(), MAptsxform(), MAmulmx(), MAtypemx();
  extern IGRboolean MAidmx(), MArptsxform(), MAbcrevparm();
  extern IGRboolean BSnorvec(), BSbx2(), EFboreline(), EFaxisline();
  extern IGRlong EMgetvggeom();

  stat_OM = OM_S_SUCCESS;

  cvgeom = NULL;
  bline.point1 = blinept1;
  bline.point2 = blinept2;
  cvplane.point = ME.EClawcv->xpts[FIRST];
  cvplane.normal = ME.EClawcv->plnnor;

  ex$message(msgnumb = EM_M_ManupVarCur);

  /*
   * The command has just been entered. Ask the user
   * to pick a sub-command.
   */

  do
    {
    if (ME.super_cmd->state == INITIAL_STATE)
      {
      ex$message(msgnumb = EMS_P_CretVarCur);
      /* TO add ' / (M)anipulate / (O)utput variation curve') */
      eventmask = GRm_RJT_MOVEON | GRm_TEXT_VALUE;
      stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                   response = response, response_data = response_data,
                   event = &event);
      EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
      ex$message(msgnumb = EMS_P_ClearPromptField);
      if (msg_loc == GRw_no_value)
        event.response = EX_RJT_MOVEON;
 
      switch (event.response)
        {
        case EX_RJT_MOVEON:
          subtype = CREATE_LAWCV;
          break;

        case EX_STRING:
          if (toupper (event.event.keyin[0]) == 'C')
            subtype = CREATE_LAWCV;
          else if (toupper (event.event.keyin[0]) == 'S')
            subtype = SHOW_LAWCV;
          else if (toupper (event.event.keyin[0]) == 'M')
            subtype = MODIFY_LAWCV;
          else if (toupper (event.event.keyin[0]) == 'O')
            subtype = OUTPUT_LAWCV;
          else
            goto ret_end;
          break;

        default:
          goto ret_end;
        }
      ME.super_cmd->state = !INITIAL_STATE;
      ME.EClawcv->subtype = subtype;
      ME.EClawcv->substate = INITIAL_STATE;
      }

    /*
     * The sub-command has been chosen. Based on this, perform
     * the necessary actions.
     */

    switch (ME.EClawcv->subtype)
      {
      case CREATE_LAWCV:
        substate = ME.EClawcv->substate;
        switch (substate)
          {
          case LOCATE_CREATE_STATE:
            stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                       &useract, response, response_data, "curve",
                       NULL,
                       " near start point", 
                       " with first point for X-vector in view",
                       NULL,
                       NULL),
                       targetid = my_id);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);

            if (useract == EMSuser_data)
              {

              OM_BLOCK_MOVE (&ME.ECelements->accev.event.button.x,
               ME.EClawcv->xpts[FIRST], sizeof (IGRpoint));

              plnnor = ME.EClawcv->plnnor;
              stat_func = EFboreline (&msg_loc, my_id, &ME.ECelements->accev,
                           &bline);
              EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM,
               OM_E_ABORT, ret_end);
              for (i=X; i<=Z; i++)
                plnnor[i] = blinept2[i] - blinept1[i];
              stat_func = BSnorvec (&msg_loc, plnnor);
              EMerr_hndlr (!stat_func || msg_loc != BSSUCC, stat_OM,
               OM_E_ABORT, ret_end);
             
              cvid = ME.ECelements->elems[0].located_obj;
              md_env = &ME.ECelements->elems[0].module_info;
              mattyp = &md_env->md_env.matrix_type;
              mat = md_env->md_env.matrix;
              ME.EClawcv->reversed = ME.ECelements->elemprops[FIRST] &
		                     EC_ELEM_ISREVERSED;
              stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                         mattyp, mat,
			 ME.EClawcv->reversed ? dumpt : ME.EClawcv->orig,
                         ME.EClawcv->reversed ? ME.EClawcv->orig : dumpt),
                         targetid = cvid.objid, targetos = cvid.osnum);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM,
               OM_E_ABORT, ret_end);

              substate = XPT2_CREATE_STATE;
              }
            else if (useract == EMSuser_backup)
              ME.super_cmd->state = INITIAL_STATE;
            else
              goto ret_end;
            break;
  
          case XPT1_CREATE_STATE:
            ex$message(msgnumb = EMS_P_InpFirpVw);
            eventmask = GRm_DATA | GRm_BACK_UP;
            stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                         response = response, response_data = response_data,
                         event = &event);
            EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
            ex$message(msgnumb = EMS_P_ClearPromptField);

            switch (event.response)
              {
              case EX_DATA:
                OM_BLOCK_MOVE (&event.event.button.x,
                 ME.EClawcv->xpts[FIRST], sizeof (IGRpoint));

                plnnor = ME.EClawcv->plnnor;
                stat_func = EFboreline (&msg_loc, my_id, &event, &bline);
                EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM,
                 OM_E_ABORT, ret_end);
                for (i=X; i<=Z; i++)
                  plnnor[i] = blinept2[i] - blinept1[i];
                stat_func = BSnorvec (&msg_loc, plnnor);
                EMerr_hndlr (!stat_func || msg_loc != BSSUCC, stat_OM,
                 OM_E_ABORT, ret_end);
             
                cvid = ME.ECelements->elems[0].located_obj;
                md_env = &ME.ECelements->elems[0].module_info;
                mattyp = &md_env->md_env.matrix_type;
                mat = md_env->md_env.matrix;
                ME.EClawcv->reversed = ME.ECelements->elemprops[FIRST] &
                                       EC_ELEM_ISREVERSED;
                stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                           mattyp, mat,
                           ME.EClawcv->reversed ? dumpt : ME.EClawcv->orig,
                           ME.EClawcv->reversed ? ME.EClawcv->orig : dumpt),
                           targetid = cvid.objid, targetos = cvid.osnum);
                EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM,
                 OM_E_ABORT, ret_end);

                substate = XPT2_CREATE_STATE;
                break;

              case EX_BACK_UP:
                ME.ECelements->num_elems = 0;
                ME.ECelements->num_events = 0;
                substate = LOCATE_CREATE_STATE;
                break;
 
              default:
                goto ret_end;
              }
            break;
  
          case XPT2_CREATE_STATE:
            ex$message(msgnumb = EMS_P_InpSecpVw);
            EFrblineseg (ME.EClawcv->xpts[FIRST],
             &ME.ECelements->active_display);
            eventmask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
            stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                         response = response, response_data = response_data,
                         event = &event);
            EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
            ex$message(msgnumb = EMS_P_ClearPromptField);

            switch (event.response)
              {
              case EX_DATA:
                OM_BLOCK_MOVE (&event.event.button.x,
                 ME.EClawcv->xpts[SECOND], sizeof (IGRpoint));
                substate = NAME_CREATE_STATE;
                break;

              case EX_RJT_MOVEON:
                stat_func = EFaxisline (&msg_loc, &ME.ECelements->accev,
                             TRUE, &bline);
                EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM,
                 OM_E_ABORT, ret_end);

                OM_BLOCK_MOVE (blinept2, ME.EClawcv->xpts[SECOND],
                 sizeof (IGRpoint));
                substate = NAME_CREATE_STATE;
                break;

              case EX_BACK_UP:
                ME.ECelements->num_elems = 0;
                ME.ECelements->num_events = 0;
                substate = XPT1_CREATE_STATE;
                break;
 
              default:
                goto ret_end;
              }
            break;
  
          case NAME_CREATE_STATE:
            if (ME.ECelements->elems_hilit)
              {
              stat_OM = dp$erase_hilite (msg = &msg_loc);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
               ret_end);
              ME.ECelements->elems_hilit = FALSE;
              }
            
            mattyp = &ME.ECelements->elems[0].module_info.md_env.matrix_type;
            mat = ME.ECelements->elems[0].module_info.md_env.matrix;

            EMtoplnxform (&msg_loc, ME.EClawcv->orig, ME.EClawcv->plnnor,
             mattyp, mat, &xform_mattyp_temp, xform_mat_temp,
             NULL, NULL, NULL);
            EMerr_hndlr (EMSerror (msg_loc & stat_OM), stat_OM, OM_E_ABORT,
             ret_end);

            xpts = (IGRdouble *)ME.EClawcv->xpts;

	    /*-------------------------------------------------------------
	     * Fix a bug in the following call. It was to transform xpts to
	     * xpts which uses the same storage for transformed points.
	     * This makes command object inconsistent when backups. Correct
	     * the problem by introducing xform_xpts to store transformed
	     * points.
	     * SY : 06/30/93
	     *-------------------------------------------------------------
	     */

            stat_func = MAptsxform (&msg_loc, &two, xform_mat_temp,
                         xpts, xform_xpts);
            EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
            for (i=X; i<=Z; i++)
              xaxis[i] = i == Z ? 0.0 : xform_xpts[1][i] - xform_xpts[0][i];
            BSnorvec (&msg_loc, xaxis);
            EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);

            stat_func = MAxrotmx (&msg_loc, xaxis, xrot_mat);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            stat_func = MAmulmx (&msg_loc, &four, &four, &four, xrot_mat,
                         xform_mat_temp, xform_mat);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            stat_func = MAtypemx (&msg_loc, xform_mat, &xform_mattyp);
            EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM, OM_E_ABORT,
             ret_end);

            cvid = ME.ECelements->elems[0].located_obj;
            stat_OM = EMgetvggeom (&msg_loc, &xform_mattyp, xform_mat, &cvid,
                       &cvgeom, &dattyp);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
            ME.EClawcv->reversed = ME.ECelements->elemprops[FIRST] &
                                   EC_ELEM_ISREVERSED;
            if (ME.EClawcv->reversed)
              {
              stat_func = MAbcrevparm (&msg_loc, cvgeom, cvgeom);
              EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM,
               OM_E_ABORT, ret_end);
              }
            cvgeom->poles[FIRST+X] = 0.0;
            cvgeom->poles[FIRST+Y] = 0.0;
            for (i=0, j=Z; i<cvgeom->num_poles; i++, j+=3)
              cvgeom->poles[j] = 0.0;
            
            BSbx2 (&msg_loc, &cvgeom->num_poles, cvgeom->poles,
             cvgeom->weights, minrng, maxrng);
            BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);

            tempd = maxrng[X] - minrng[X];
            badcv = TRUE;
            if (tempd < MINNUMPTS_ON_LAWCV * lentol)
              ex$message(msgnumb = EMS_S_CvrShrtXais)
            else if (minrng[X] < 0.0)
              ex$message(msgnumb = EMS_S_SCurNegXcomp)
            else
              badcv = FALSE;

            if (badcv)
              {
              ems_sleep (2);
              substate = LOCATE_CREATE_STATE;
              ME.ECelements->num_elems = 0;
              ME.ECelements->num_events = 0;

              om$dealloc (ptr = cvgeom);
              cvgeom = NULL;
              break;
              }

            scales[X] = scales[Y] = 100.0 / tempd;
            scales[Z] = scales[W] = 1.0;

            MAidmx (&msg_loc, idmat);
            stat_func = MAgscamx (&msg_loc, idmat, cvgeom->poles, scales,
                         xform_mat);
            EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM, OM_E_ABORT,
             ret_end);

            stat_func = MArptsxform (&msg_loc, &cvgeom->num_poles,
                         &cvgeom->rational, cvgeom->weights, xform_mat,
                         cvgeom->poles, cvgeom->poles);
            EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM, OM_E_ABORT,
             ret_end);

            ex$message(msgnumb = EMS_P_EntNmFrVarCu);
            eventmask = GRm_STRING | GRm_BACK_UP;
            stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                         response = response, response_data = response_data,
                         event = &event);
            EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
            ex$message(msgnumb = EMS_P_ClearPromptField);
 
            switch (event.response)
              {
              case EX_STRING:
                put_lawcurve (&msg_loc, event.event.keyin, &cvinx, cvgeom);
                om$dealloc (ptr = cvgeom);
                cvgeom = NULL;
                if (EMSerror (msg_loc))
                  {
                  ex$message(msgnumb = EMS_S_ErrorEncount);
                  substate = LOCATE_CREATE_STATE;
                  ME.ECelements->num_elems = 0;
                  ME.ECelements->num_events = 0;
                  }
                else if (msg_loc == EMS_I_NotUnique)
                  {
		  /*
                  ex$message(msgnumb = EMS_S_VarCurNotUniq);
		  */
                  }
                else
                  {
                  ex$message(msgnumb = EMS_P_VarCurNum, buff = buff1);
                  sprintf(stat_prompt, "%s%d", buff1,cvinx);
                  ex$message(field = PROMPT_FIELD, justification=RIGHT_JUS,
                               in_buff=stat_prompt);
                  }

		/*
		 * Store parent info and recompute info
		 */
		msg_loc = OM_S_SUCCESS;
		
		parent.grid = ME.ECelements->elems[0].located_obj;
		parent.env = ME.ECelements->elems[0].module_info;

		info_size = sizeof(struct EMSlaw_curve) + 
		            strlen(event.event.keyin) + 1;

		lawcv_info = (struct EMSlaw_curve *) alloca(info_size);

		memcpy(lawcv_info->normal, ME.EClawcv->plnnor,
		       sizeof(IGRvector));

		/*
		 * Save the axis info for recomputation
		 */
		for (i = X; i <= Z; i++)
		  lawcv_info->axis[i] = ME.EClawcv->xpts[1][i] - 
		                        ME.EClawcv->xpts[0][i];

		lawcv_info->reversed = ME.EClawcv->reversed;
		strcpy(lawcv_info->name, event.event.keyin);

	        /*
		 * initialize construction list
		 */
	        construct_list.msg = &msg_loc;
	        construct_list.env_info = &ME.ECelements->elems[0].module_info;
	        construct_list.newflag = FALSE;
	        construct_list.level = 0;
	        construct_list.properties = NULL;
	        construct_list.geometry = NULL;
	        construct_list.display = &me->active_display;
	        construct_list.class_attr = NULL;
	        construct_list.name = event.event.keyin;

		/*
		 * get associative flag
		 */
		gr$get_associative_flag(buffer = &assoc_placement);

		/*
		 * Call the macro to create associative law curve
		 */
		stat_func = ems$associative_element_by_function
		  (msg = &msg_loc,
		   associative = assoc_placement ? TRUE : FALSE,
		   num_parents = 1,
		   parents = &parent,
		   info_size = info_size,
		   info = (IGRchar *) lawcv_info,
		   function_name = "EMCrLawCv",
		   construct_list = &construct_list,
		   class_name = "GAbcsubbc",
		   created_id = &constructed_lawcv);
		EMerr_hndlr(EMSerror(msg_loc & stat_func), stat_OM, OM_E_ABORT,
			    ret_end);

                ex$message(msgnumb = EMS_P_ClearPromptField, buff = cvname);
		/*
                show_lawcurve (&msg_loc, cvname, &cvinx, NULL);
		*/
                if (EMSerror (msg_loc))
                  {
                  ex$message(msgnumb = EMS_S_ErrorEncount);
                  substate = LOCATE_CREATE_STATE;
                  ME.ECelements->num_elems = 0;
                  ME.ECelements->num_events = 0;

                  ex$message(msgnumb = EMS_P_ClearPromptField, buff = cvname);
                  delete_lawcurve (&msg_loc, cvname, &cvinx);
                  break;
                  }

                ME.ECelements->num_elems = 0;
                ME.ECelements->num_events = 0;
                substate = LOCATE_CREATE_STATE;
                break;
 
              case EX_BACK_UP:
                om$dealloc (ptr = cvgeom);
                cvgeom = NULL;
                substate = XPT2_CREATE_STATE;
                break;
              
              default:
                goto ret_end;
              }
            break;
  
          default:
            stat_OM = OM_E_ABORT;
            goto ret_end;
          }
        ME.EClawcv->substate = substate;
        break;
  
 
     case SHOW_LAWCV:
        substate = ME.EClawcv->substate;
        switch (substate)
          {
          case NAME_SHOW_STATE:
            ex$message(msgnumb = EMS_P_EntNumbVarcv);
            eventmask = GRm_TEXT_VALUE | GRm_BACK_UP;
	    acceptmask = GRm_TEXT_VALUE;

	    /*
            stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                         value_type = GRIO_SCALAR, response = response,
                         response_data = response_data, event = &event);
			 */

	    /*
	     * Locate the named law curve.
	     */

	    lc_attr.properties = IGN_LC_BIT | IGN_RW_BIT | IGN_DP_BIT | IGN_MOD_BIT;
	    lc_attr.owner_action = LC_NON_GEOM_MOD;

	    rtree_class.w_count = 1;
	    rtree_class.w_flags = OM_CLST_subclass;
	    rtree_class.p_classes = &rtree_classid;
	    rtree_classid = OPP_GAbcsubbc_class_id;
	    
	    elig_class.w_count = 1;
	    elig_class.w_flags = OM_CLST_subclass;
	    elig_class.p_classes = &elig_classid;
	    elig_classid = OPP_GAbcsubbc_class_id;
	    
	    stat_func = lc$locate (rc = &msg_loc,
				   event1 = &lc_event,
				   event2 = &event,
				   mask1 = eventmask,
				   mask2 = acceptmask,
				   response = response,
				   response_data = response_data,
				   display_flag = LC_ACC_ONE_ELEMENT,
				   locate_key = EMS_P_EntNumbVarcv,
				   acc_key = EMS_P_EntNumbVarcv,
				   relocate_key = EMS_I_CvNotLocated,
				   attributes = &lc_attr,
				   stack = &me->locate_stack,
				   rtree_classes = &rtree_class,
				   eligible_classes = &elig_class,
				   regex = TRUE);
            EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
            ex$message(msgnumb = EMS_P_ClearPromptField);

	    if (!(1 & msg_loc))
	    {
	      if (lc_event.response == EX_BACK_UP)
                ME.super_cmd->state = INITIAL_STATE;
	      else
		return OM_S_SUCCESS;
	    }
	    else
	    {
            switch (event.response)
              {
              case EX_STRING:
                cvinx = INVALID_INX;
		cvid = event.located_object[0].located_obj;
		md_env = &event.located_object[0].module_info;
		mattyp = &md_env->md_env.matrix_type;
		mat = md_env->md_env.matrix;

		stat_OM = EMgetvggeom (&msg_loc, mattyp, mat, &cvid,
				       &cvgeom, NULL);
		EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
			     ret_end);

		show_lawcurve (&msg_loc, event.event.keyin, NULL, cvgeom);
		/*
                show_lawcurve (&msg_loc, event.event.keyin, &cvinx, NULL);
		*/
                if (msg_loc == EMS_I_NotFound)
                  ex$message(msgnumb = EMS_S_NoVarCur) 
                else if (EMSerror (msg_loc))
                  ex$message(msgnumb = EMS_S_VarCuNotDisp)
                else
                  {
                  ex$message(msgnumb = EMS_P_VarCurNum, buff = buff1);
                  sprintf(stat_prompt, "%s%d", buff1,cvinx);
                  ex$message(field = PROMPT_FIELD, justification=RIGHT_JUS,
                               in_buff=stat_prompt);
                  }
                break;
 
              case EX_VALUE:
                ex$message(msgnumb = EMS_P_ClearPromptField, buff = cvname);
                cvinx = event.event.value;
                show_lawcurve (&msg_loc, cvname, &cvinx, NULL);
                if (msg_loc == EMS_I_NotFound)
                  ex$message(msgnumb = EMS_S_NoVarCur)
                else if (EMSerror (msg_loc))
                  ex$message(msgnumb = EMS_S_VarCuNotDisp)
                break;
 
              case EX_BACK_UP:
                ME.super_cmd->state = INITIAL_STATE;
                break;

              default:
                goto ret_end;
              }
	    }
            break;
 
          default:
            goto ret_end;
          }
        ME.EClawcv->substate = substate;
        break;
   

      case MODIFY_LAWCV:
        ex$message(msgnumb = EMS_S_NotSuport);
        ems_sleep (2);
        ME.super_cmd->state = INITIAL_STATE;
        break;
 

      case OUTPUT_LAWCV:
        ex$message(msgnumb = EMS_S_NotSuport);
        ems_sleep (2);
        ME.super_cmd->state = INITIAL_STATE;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  if (cvgeom)
    om$dealloc (ptr = cvgeom);

  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}





method get_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                            OM_S_CLASSLIST *rtree_classes, *elig_classes,
                            *nelig_classes; IGRushort *geomprops;
                            IGRshort *operation; IGRushort *options;
                            IGRint *minnum_to_locate, *maxnum_to_locate)
{
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  rtree_classes->w_count = 1;
  rtree_classes->w_flags = OM_CLST_subclass;
  rtree_classes->p_classes[0] = OPP_GRbspline_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_GRcurve_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = EC_LOC_DISPELEMDIR;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}


/*-----------------------------------------------------------------------
 * The following function is added for 2.4 to make law curve associative.
 *
 * 06/30/93 : JSY : Creation.
 *-----------------------------------------------------------------------
 */

#argsused

IGRint EMCrLawCv(EMmsg, options, old_objid, new_objid,
		 num_parents, parent_info, recomp_info,
		 construct_list, mod_new_id)
IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
{
  IGRdouble *mat, scales[4], disrng;
  IGRpoint dumpt, origin, xpts[2], minrng, maxrng;
  IGRmatrix mat1, xrot_mat, xform_mat, idmat;
  IGRvector xaxis;
  IGRint i, j;
  IGRlong num_pts = 2;
  IGRuint num_roots, root_type;
  IGRshort *mattyp, mattyp1, xform_mattyp, four = 4;
  union EMSparent_info root;
  struct EMSlaw_curve *info = NULL;
  struct IGRbsp_curve *cvgeom;
  IGRchar ref_path[1024], namepath[1024];
  IGRlong loc_msg, sts = OM_S_SUCCESS;

  extern void EMtoplnxform();
  extern IGRboolean MAxrotmx(), MAptsxform(), MAmulmx(), MAtypemx();
  extern IGRboolean MAidmx(), MArptsxform(), MAbcrevparm();
  extern IGRboolean BSnorvec(), BSbx2();
  extern IGRlong EMgetvggeom();

  num_roots = num_parents;
  if (num_roots != 1)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto quit;
  }

  /*
   * Get the real parent.
   */
  root_type = EMSlcinfo;
  sts = om$send(msg = message EMSassoc.EMget_parent_info(&loc_msg,
							 NULL,
							 num_roots,
							 parent_info,
							 &root_type,
							 &root),
		senderid = new_objid,
		targetid = new_objid);
  EMerr_hndlr(EMSerror(sts & loc_msg), *EMmsg, EMS_E_Fail, quit);

  /*
   * Collect recompute info.
   */
  info = (struct EMSlaw_curve *) recomp_info;

  /*
   * Use dir path to create the full path name, per Jimmy.
   */
  di$give_pathname(osnum = root.lc_info.located_obj.osnum,
		   pathname = ref_path);

  /*
   * Set up absolute path for the law curve name
   */
  sprintf(namepath, "%s:usr:%s", ref_path, info->name);
  
  mattyp = &root.lc_info.module_info.md_env.matrix_type;
  mat = root.lc_info.module_info.md_env.matrix;

  sts = om$send(msg = message GRcurve.GRendpts(&loc_msg,
					       mattyp,
					       mat,
					       info->reversed ? dumpt : origin,
					       info->reversed ? origin : dumpt),
		senderid = new_objid,
		targetid = root.lc_info.located_obj.objid,
		targetos = root.lc_info.located_obj.osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), *EMmsg, EMS_E_Fail, quit);

  EMtoplnxform(&loc_msg, origin, info->normal,
		mattyp, mat, &mattyp1, mat1,
		NULL, NULL, NULL);
  EMerr_hndlr(EMSerror(loc_msg), *EMmsg, EMS_E_Fail, quit);

  memcpy(xpts[0], origin, sizeof(IGRpoint));
  for (i = X; i <= Z; i++)
    xpts[1][i] = origin[i] + info->axis[i];

  sts = MAptsxform(&loc_msg, &num_pts, mat1, xpts, xpts);
  EMerr_hndlr(!sts || EMSerror(loc_msg), *EMmsg, EMS_E_BSerror, quit);

  for ( i = X; i <= Z; i++)
    xaxis[i] = i == Z ? 0.0 : xpts[1][i] - xpts[0][i];
  BSnorvec(&loc_msg, xaxis);
  
  sts = MAxrotmx(&loc_msg, xaxis, xrot_mat);
  EMerr_hndlr(EMSerror(loc_msg), *EMmsg, EMS_E_BSerror, quit);
  
  sts = MAmulmx(&loc_msg, &four, &four, &four, xrot_mat, mat1, xform_mat);
  EMerr_hndlr(EMSerror(loc_msg), *EMmsg, EMS_E_BSerror, quit);

  sts = MAtypemx(&loc_msg, xform_mat, &xform_mattyp);
  EMerr_hndlr(!sts || EMSerror(loc_msg), *EMmsg, EMS_E_BSerror, quit);

  sts = EMgetvggeom(&loc_msg, &xform_mattyp, xform_mat,
		    &root.lc_info.located_obj, &cvgeom, NULL);
  EMerr_hndlr(EMSerror(sts & loc_msg), *EMmsg, EMS_E_BSerror, quit);

  if (info->reversed)
  {
    sts = MAbcrevparm(&loc_msg, cvgeom, cvgeom);
    EMerr_hndlr(!sts || EMSerror(loc_msg), *EMmsg, EMS_E_BSerror, quit);
  }

  cvgeom->poles[FIRST + X] = 0.0;
  cvgeom->poles[FIRST + Y] = 0.0;
  for ( i = 0, j = Z; i < cvgeom->num_poles; i++, j += 3)
    cvgeom->poles[j] = 0.0;

  BSbx2(&loc_msg, &cvgeom->num_poles, cvgeom->poles,
	cvgeom->weights, minrng, maxrng);
  disrng = maxrng[X] - minrng[X];

  scales[X] = scales[Y] = 100.0 / disrng;
  scales[Z] = scales[W] = 1.0;

  MAidmx(&loc_msg, idmat);
  sts = MAgscamx(&loc_msg, idmat, cvgeom->poles, scales, xform_mat);
  EMerr_hndlr(!sts || EMSerror(loc_msg), *EMmsg, EMS_E_BSerror, quit);

  sts = MArptsxform(&loc_msg, &cvgeom->num_poles,
		    &cvgeom->rational, cvgeom->weights, xform_mat,
		    cvgeom->poles, cvgeom->poles);
  EMerr_hndlr(!sts || EMSerror(loc_msg), *EMmsg, EMS_E_BSerror, quit);

  /*
   * Construct the law curve
   */
  construct_list->level = 0;
  construct_list->properties = NULL;
  construct_list->geometry = (IGRchar *) cvgeom;

  if (old_objid == NULL_OBJID)
    construct_list->name = namepath;

  sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
		senderid = NULL_OBJID,
		targetid = new_objid);
  *mod_new_id = new_objid;

  /*
   * Show the modified law curve
   */
  show_lawcurve(&loc_msg, info->name, NULL, cvgeom);
  *EMmsg = MSSUCC;

 quit:
  return sts;
}

		   
/*
 * Functions used to access the law-curve subsystem. Much of these are
 * to be used locally - ensured by the "static" declaration.
 */

static void put_lawcurve (msg, name, cvinx, cv)
IGRlong *msg;
IGRchar *name;
struct IGRbsp_curve *cv;
IGRint *cvinx;
{
  IGRlong msg_loc, stat_OM = OM_S_SUCCESS;

  *msg = EMS_S_Success;

  if (_lawmgr == NULL_MGR)
    {
    stat_OM = om$construct (classid = OPP_EMSlawmgr_class_id,
               osnum = OM_Gw_TransOSnum_0, 
               msg = message EMSlawmgr.EMinit (&msg_loc), p_objid = (OM_p_OBJID)&_lawmgr);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  stat_OM = om$send (msg = message EMSlawmgr.EMputcv (msg, name, cvinx, cv),
             targetid = _lawmgr, targetos = OM_Gw_TransOSnum_0,
             senderid = NULL_OBJID);

ret_end:
  if (EMSerror (stat_OM) && !EMSerror (*msg))
    *msg = EMS_E_Fail;
  return;
}


void EMget_lawcurve (msg, name, index, lawcv)
IGRlong *msg;
IGRchar *name;
IGRint *index;
struct IGRbsp_curve **lawcv;
{
  IGRlong stat_OM = OM_S_SUCCESS;

  *msg = EMS_S_Success;
  
  if (_lawmgr == NULL_MGR)
    *msg = EMS_I_NotFound;
  else
    stat_OM = om$send (msg = message EMSlawmgr.EMgetcv (msg, name,
               index, lawcv), targetid = _lawmgr,
              targetos = OM_Gw_TransOSnum_0, senderid = NULL_OBJID);
  if (EMSerror (stat_OM))
    *msg = EMS_E_Fail;
  return;
}


static void show_lawcurve (msg, name, cvinx, cv)
IGRlong *msg;
IGRchar *name;
IGRint *cvinx;
struct IGRbsp_curve *cv;
{
  IGRboolean path_found, stat_func;
  IGRchar fullprocname[MAXSIZE_PRODPATHNAME+1], procname[20];
  IGRchar commfile[20], *argptr[4];
  IGRint i, numpts;
  IGRlong msg_loc, stat_OM = OM_S_SUCCESS;
  IGRdouble cvpars[MINNUMPTS_ON_LAWCV+1], startpar;
  IGRpoint cvpts[MINNUMPTS_ON_LAWCV+1];
  FILE *ptfile;
  extern IGRboolean BSequalspcs();
  extern int access();

  *msg = EMS_S_Success;
  
  if (!cv)
  {
    EMerr_hndlr (_lawmgr == NULL_MGR, *msg, EMS_I_NotFound, ret_end);

    stat_OM = om$send (msg = message EMSlawmgr.EMgetcv (&msg_loc, name,
	      cvinx, &cv), targetid = _lawmgr, targetos = OM_Gw_TransOSnum_0,
              senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_I_NotFound, ret_end);
  }
  
  startpar = 0.0;
  numpts = MINNUMPTS_ON_LAWCV;
  stat_func = BSequalspcs (&msg_loc, cv, &startpar, &numpts, cvpars, cvpts);
  EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

  strcpy (commfile, COMM_FILE);
  ptfile = fopen (commfile, "w");
  EMerr_hndlr (!ptfile, *msg, EMS_E_Fail, ret_end);
  fprintf (ptfile, "%d\n", numpts);
  for (i=0; i<numpts; i++)
    fprintf (ptfile, "%lf %lf\n", cvpts[i][X], cvpts[i][Y]);
  fprintf (ptfile, "%d\n", -1);
  fprintf (ptfile, "Variation curve = %s\n", name);
  fprintf (ptfile, "Percentage length\n");
  fprintf (ptfile, "Value\n");
  fprintf (ptfile, "%d %d %d %d\n", WINEXT_XMIN, WINEXT_YMIN,
   WINEXT_XMAX, WINEXT_YMAX);
  fclose (ptfile);

  strcpy (procname, "/bin/graph");
  path_found = FALSE;
  for (i=0; i<MAXNUM_PRODPATHS && !path_found; i++)
    {
    path_found = ex$get_path(index = i, path = fullprocname,
                  len = MAXSIZE_PRODPATHNAME - strlen (procname),
                  type = EX_PRODUCT_PATH);
    if (path_found)
      {
      strcat (fullprocname, procname);
      if (access (fullprocname, TEST_EXISTS) == TEST_SUCCESS)
        break;
      else
        path_found = FALSE;
      }
    }
  if (!path_found)
    {
    ex$message(msgnumb = EMS_S_ExecImNtFnd);
    ems_sleep (2);
    goto ret_end;
    }

  argptr[0] = fullprocname;
  argptr[1] = EMS_LAWCV_PLOT;
  argptr[2] = commfile;
  argptr[3] = NULL;
  ex$fork (num_entry = 3, argu = argptr);
  
ret_end:
  if (cv)
    om$dealloc (ptr = cv);

  if (EMSerror (stat_OM) && !EMSerror (*msg))
    *msg = EMS_E_Fail;
  return;
}

#argsused

static void delete_lawcurve (msg, name, cvinx)
IGRlong *msg;
IGRchar *name;
IGRint *cvinx;
{
  *msg = EMS_S_Success;

  return;
}

end implementation EClawcv;
