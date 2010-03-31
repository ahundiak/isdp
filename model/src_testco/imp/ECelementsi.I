class implementation ECelements;

#include "EMS.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"

#include "madef.h"
#include "maidmx.h"
#include "actparam.h"

static IGRboolean aflag;

/* 
History 
    Tapadia 6/9/92 - Modified for message sub system compliance
    JSY     02/17/93 Add support for skip accept/reject cycle in
                     do_locate method.
    Aditya  10/09/95 Fix for TR119524989. Used strncpy() in do_locate().
*/

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

extern GRclassid OPP_GRgraphics_class_id;
extern GRclassid OPP_GRcurve_class_id, OPP_GRflxown_class_id;
extern GRclassid OPP_EMSsubbs_class_id;
extern GRclassid OPP_SKdumpt_class_id;

from GRgraphics import GRdisplay;
from SKdumpt      import SKget_origin_id;

method init (IGRint type; IGRchar *string)
{
  IGRushort geom_props, topo_props, options;
  IGRshort oper;
  IGRint min_to_locate, max_to_locate;
  IGRlong msg_loc, stat_OM;
  IGRlong display_flag, locate_mask, accept_mask;
  OM_S_CLASSLIST *r_classes, *e_classes, *ne_classes;

  stat_OM = OM_S_SUCCESS;

  ME.super_cmd->state = 0;
  ME.super_cmd->mytype = type;
  ME.ECelements->locate_stack.num_entries = 0;
  ME.ECelements->num_elems = 0;
  ME.ECelements->num_events = 0;
  
  r_classes = &ME.ECelements->rtree_classes;
  r_classes->p_classes = ME.ECelements->r_classmem;
  e_classes = &ME.ECelements->elig_classes;
  e_classes->p_classes = ME.ECelements->e_classmem;
  ne_classes = &ME.ECelements->nelig_classes;
  ne_classes->p_classes = ME.ECelements->ne_classmem;

  stat_OM = om$send (msg = message ECelements.get_locate_criteria
             (&msg_loc, MAXNUM_RESTRICTIVE_CLASSES-1, r_classes, e_classes,
             ne_classes, &geom_props, &oper, &options, &min_to_locate,
             &max_to_locate), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

  if (oper == EC_GEOM_READ || oper == EC_ATTR_READ)
  {
    geom_props |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_RW;
    topo_props = LC_RIGID_COMP | LC_RIGID_OWNER | 
                 LC_FLEX_COMP | LC_FLEX_OWNER | 
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else if (oper == EC_ATTR_WRITE)
  {
    geom_props |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_WRITE_ONLY;
    topo_props = LC_RIGID_COMP | LC_RIGID_OWNER |
                 LC_FLEX_COMP | LC_FLEX_OWNER | 
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else if (oper == EC_GEOM_CHGSHAPE || oper == EC_GEOM_NOCHGSHAPE)
  {
    aflag = pwIsActivationOn();
    if (aflag)
    {
      /** Commented out the MOD_BIT and WRITE_ONLY to catch profiles in 
       ** Reference files
       **/
      geom_props |= LC_LC_ONLY | LC_DP_ONLY; /*| IGN_MOD_BIT | LC_WRITE_ONLY;*/
    }
    else
    {
      geom_props |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_WRITE_ONLY;
    }
    topo_props = LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | 
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else
  {
    stat_OM = OM_E_ABORT;
    goto ret_end;
  }

  if (options & EC_LOC_RIGIDCOMPOK)
    topo_props |= LC_RIGID_COMP;
   
  if (options & EC_LOC_ASSOCOK)
    topo_props |= LC_ASSOCIATIVE;

  if (options & EC_LOC_EXTCONSTOK)
    topo_props |= LC_EXTERN_CONSTRAINED;

  if (options & EC_LOC_NOFLEXGROUPS)
    topo_props &= ~LC_FLEX_OWNER;
  else if (max_to_locate > 1 && topo_props & LC_FLEX_OWNER)
    e_classes->p_classes[e_classes->w_count++] = OPP_GRflxown_class_id;

  if (options & EC_LOC_READONLYOK)
    geom_props |= LC_READ_ONLY;


  locate_mask = GRm_DATA | GRm_TEXT_VALUE | GRm_BACK_UP;
  if (max_to_locate > 1 && !(options & EC_LOC_NOSPECOBJS))
    locate_mask |= GRm_SPECIFIED_OBJ;
  if (min_to_locate == 0)
    locate_mask |= GRm_RJT_MOVEON;

  accept_mask = GRm_DATA;
  if (max_to_locate > 1)
    {
    accept_mask |= GRm_TEXT_VALUE;
    if (!(options & EC_LOC_NOSPECOBJS))
      accept_mask |= GRm_SPECIFIED_OBJ;
    }

  ME.ECelements->locate_mask = locate_mask;
  ME.ECelements->accept_mask = accept_mask;
  ME.ECelements->owner_action = topo_props;
  ME.ECelements->properties = geom_props;
  ME.ECelements->min_to_locate = min_to_locate;
  ME.ECelements->max_to_locate = max_to_locate;
  ME.ECelements->options = options;

  display_flag = (options & EC_LOC_DISPONEWINDOW ? ONE_WINDOW : ALL_WINDOWS ) |
                 ELEM_HILIGHT |
                 (options & EC_LOC_PROJACCPT ?
                  PROJ_ACCEPT_POINT : NO_PROJ_ACCEPT_POINT) |
		 (options & EC_LOC_NO_ACC_RJT ?
                  NO_ACC_REJ_CYCLE | DO_NOT_RELOCATE :
                  ACC_REJ_CYCLE | 
		  (options & EC_LOC_NO_RELOCATE ?
		   DO_NOT_RELOCATE : RELOCATE )) | LC_REGULAR_HIGHLIGHT |
                 LC_ERASE_LOC_ELEMENT;
  if (options & EC_LOC_DISPELEMDIR || options & EC_LOC_PROJLOCPT)
    display_flag |= LC_INPUT_LOC_POINT;
  if (max_to_locate > 1)
    display_flag |= LC_ACCEPT_CURSOR;
  ME.ECelements->display_flag = display_flag;

  ME.ECelements->locobj_hndlr = NULL;

ret_end:
  return (stat_OM);
}

method wakeup (IGRint pos)
{
  IGRboolean stat_func;
  IGRushort *elemprops;
  IGRint i, num_elems;
  IGRint bytes_in, bytes_out;
  IGRlong msg_loc, stat_OM;
  struct GRmd_env *actmd_env;
  struct GRmdenv_info *mdenv_info;
  struct GRlc_info *elems;
  struct IGRdisplay *actdisp;
  enum GRdpmode dpmode;
  extern IGRboolean EFdisplay_curve_normal_or_tangent();

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  ex$message(msgnumb = EMS_P_ClearPromptField);

 /****
  aflag = pwIsActivationOn();
  if (aflag)
  {
     int sts;
     sts = pwGetActiveModuleEnv(&ME.ECelements->active_md_env);
     MAidmx(&msg_loc, ME.ECelements->active_md_env.md_env.matrix);
     ME.ECelements->active_md_env.md_env.matrix_type = MAIDMX;
  }
  else
 ***/
  {
     bytes_in = sizeof (struct GRmd_env);
     gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
      buffer = &ME.ECelements->active_md_env, nret = &bytes_out);
     EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }

  bytes_in = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
   buffer = &ME.ECelements->active_display, nret = &bytes_out);
  EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

  bytes_in = sizeof (IGRshort);
  gr$get_active_level (msg = &msg_loc, sizbuf = &bytes_in,
   buffer = &ME.ECelements->active_level, nret = &bytes_out);
  EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

  if (ME.ECelements->elems_hilit)
    {
    num_elems = ME.ECelements->num_elems;
    elems = ME.ECelements->elems;
    elemprops = ME.ECelements->elemprops;

    actmd_env = &ME.ECelements->active_md_env;
    actdisp = &ME.ECelements->active_display;
    for (i=0; i<num_elems; i++)
      {
      dpmode = GRhhd;

      mdenv_info = &elems[i].module_info.md_env;

      aflag = pwIsActivationOn();
      if (aflag)
      {
         stat_OM = om$send(msg = message GRgraphics.GRdisplay
                    (&msg_loc, &ME.ECelements->active_md_env.md_env.matrix_type,
                     ME.ECelements->active_md_env.md_env.matrix, 
                     &dpmode, &ME.ECelements->active_md_env.md_id),
                    targetid = elems[i].located_obj.objid,
                    targetos = elems[i].located_obj.osnum);
         EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
      }
      else
      {
         stat_OM = om$send(msg = message GRgraphics.GRdisplay
                    (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix, 
                    &dpmode, &actmd_env->md_id),
                    targetid = elems[i].located_obj.objid,
                    targetos = elems[i].located_obj.osnum);
         EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
      }

      if (elemprops[i] & EC_ELEM_ISCURVE &&
          ME.ECelements->options & EC_LOC_DISPELEMDIR)
        {
        stat_func = EFdisplay_curve_normal_or_tangent (&elems[i], NULL, FALSE,
                     elemprops[i] & EC_ELEM_ISREVERSED, my_id, GRhhd,
                     actmd_env, actdisp, &msg_loc);
        EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);
        }
      }
    }

ret_end:
  return (stat_OM);
}

method sleep (IGRint pos)
{
  IGRlong msg_loc, stat_OM;
  extern void COclear_vsd();

  stat_OM = OM_S_SUCCESS;

  ex$message(msgnumb = EMS_P_ClearPromptField);
  ex$message(msgnumb = EMS_S_ClearStatusField);
  ex$message(msgnumb = EM_M_ClearMessageField);

  if (ME.ECelements->elems_hilit)
    {
    stat_OM = dp$erase_hilite (msg = &msg_loc);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
    }

  COclear_vsd();

ret_end:
  return (stat_OM);
}


method do_locate (IGRlong *msg; enum EMSuser_responses *useract;
                  IGRint *response; IGRchar *response_data;
                  IGRchar *elemtype, *postmsg_gen,
                  *postmsg_1, *postmsg_2, *postmsg_3;
                  IGRushort options)
{
  IGRboolean stat_func, loop_done, locate_accept_point, found, reversed;
  IGRboolean is_bore;
  IGRchar localstr[MAX_CHAR], key_locate_str[MAX_CHAR];
  IGRchar locate_str[MAX_CHAR], accept_str[MAX_CHAR], relocate_str[MAX_CHAR];
  IGRchar *p_actargs, *p_selargs;
  IGRushort *elemprops, lopts;
  IGRint  num_elems, max_to_locate, min_to_locate, vla_size;
  IGRlong putquesize;
  IGRint i, j, inx, blksize, num_loccomps, num_events, num_atevent;
  IGRlong msg_loc, stat_OM, lcmsg, save_stat, no_bytes;
  IGRlong locate_mask, accept_mask, display_flag, display_flag1;
  GRclassid elemclass;
  struct GRlc_locate lc_attr;
  struct GRlc_info *elem, *curr_elems, *loccomps;
  struct GRmd_env *elem_env, mod;
  struct GRevent *locev, *accev, objev, *ptr_locev;
  struct GRid elemid;
  struct locate_acthndlr_args actargs;
  enum GRdpmode dpmode;
  IGRboolean (*p_selhndlr)();
  IGRlong (*p_acthndlr)();
  IGRboolean EFdetermine_direction(), EFdisplay_curve_normal_or_tangent();
  IGRlong EMlocate_eligchk_hndlr();
  IGRchar tmp_buff[52];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  loccomps = NULL;

  num_elems = ME.ECelements->num_elems;
  num_events = ME.ECelements->num_events;
  locate_mask = ME.ECelements->locate_mask;
  accept_mask = ME.ECelements->accept_mask;
  display_flag = ME.ECelements->display_flag;
  min_to_locate = ME.ECelements->min_to_locate;
  max_to_locate = ME.ECelements->max_to_locate;
  lc_attr.owner_action = ME.ECelements->owner_action;
  lc_attr.properties = ME.ECelements->properties;
  locev = &ME.ECelements->locev;
  accev = &ME.ECelements->accev;
  lopts = ME.ECelements->options;
  putquesize = sizeof (struct GRevent);

  ex$message(msgnumb = EMS_S_IdenElemtype, type = "%s",
	var = `elemtype`, buff = key_locate_str); 

  if (max_to_locate - ME.ECelements->num_elems > 1)
    ex$message(msgnumb = EMS_P_AccWithNext, buff = accept_str)
  else
    ex$message(msgnumb = EMS_P_Accept, buff = accept_str)
  if (postmsg_gen)
    strcat (accept_str, postmsg_gen);
  if (postmsg_2)
    strcat (accept_str, postmsg_2);

  ex$message(msgnumb = EMS_P_Reject, buff = tmp_buff);
  strcat(accept_str, tmp_buff);

  ex$message(msgnumb = EMS_P_EleNotFound, type = "%s",
	var = `elemtype`, buff = relocate_str);

  loop_done = FALSE;
  do
    {
    strncpy (locate_str, key_locate_str, (MAX_CHAR-1));
    if (num_elems)
      {
      sprintf (localstr, " (%d)", num_elems+1);
      strcat (locate_str, localstr);
      if (postmsg_gen)
        strcat (locate_str, postmsg_gen);
      if (postmsg_3)
        strcat (locate_str, postmsg_3);
      if (num_elems >= ME.ECelements->min_to_locate)
        {
        locate_mask |= GRm_RJT_MOVEON;
	ex$message(msgnumb = EMS_P_MoveOn, buff = tmp_buff);
	strcat(locate_str, tmp_buff);
        }
      }
    else
      {
      if (postmsg_gen)
        strcat (locate_str, postmsg_gen);
      if (postmsg_1)
        strcat (locate_str, postmsg_1);
      }
      
    stat_OM = gr$gsput_locate_criteria (msg = &msg_loc,
               attributes = &lc_attr,
               rtree_classes = &ME.ECelements->rtree_classes,
               eligible_classes = &ME.ECelements->elig_classes);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

    if (ME.ECelements->acthndlr)
      {
      p_actargs = ME.ECelements->acthndlr_args;
      p_acthndlr = (IGRlong (*)()) ME.ECelements->acthndlr;
      }
    else if (lopts & EC_LOC_PLANEDEF || !(lopts & EC_LOC_NOCHKDUPLICATES))
      {
      actargs.options = lopts;
      actargs.loc_prompt = locate_str;
      actargs.acc_prompt = accept_str;
      actargs.reloc_prompt = relocate_str;
      actargs.numelems = ME.ECelements->num_elems;
      actargs.elems = ME.ECelements->elems;
      actargs.nelig_classes = ME.ECelements->nelig_classes;
      p_actargs = (IGRchar *) &actargs;
      p_acthndlr = EMlocate_eligchk_hndlr;
      }
    else
      {
      p_actargs = NULL;
      p_acthndlr = NULL;
      }

    if (ME.ECelements->selhndlr)
      {
      p_selargs = ME.ECelements->selhndlr_args;
      p_selhndlr = ME.ECelements->selhndlr;
      }
    else
      {
      p_selargs = NULL;
      p_selhndlr = NULL;
      }

    stat_func = lc$locate (
                 rc = &lcmsg, 
                 event1 = locev, 
                 event2 = accev,
                 event3 = &objev,
                 mask1 = locate_mask,
                 mask2 = accept_mask,
                 value_type1 = NULL,
                 value_type2 = NULL,
                 display_flag = display_flag,
                 hilight_mode = GRhd,
                 unhilight_mode = lopts & EC_LOC_NOHALFHILITE ? GRhe : GRhhd,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = locate_str,
                 acc_prompt = accept_str,
                 relocate_prompt = relocate_str, 
                 attributes = &lc_attr, 
                 stack = &ME.ECelements->locate_stack,
                 act_handler = p_acthndlr,
                 act_args = p_actargs,
                 select = p_selhndlr,
                 select_args = p_selargs,
                 rtree_classes = &ME.ECelements->rtree_classes, 
                 eligible_classes = &ME.ECelements->elig_classes);
    EMerr_hndlr (EMSerror (stat_func), stat_OM, OM_E_ABORT, ret_end); 
    loop_done = TRUE;

    if (lcmsg == LC_OBJ_LOCATED)
      {
      /*
       * An object has been located and it can be found in the
       * third event, viz, objev. Pass it through the customized processor
       * first. If the return code is EMS_I_NoMore, then this is the last
       * element to be located.
       */

      stat_OM = om$send (msg = message ECelements.proc_locobj (&msg_loc,
                 locev, accev, &objev), targetid = my_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

      if (msg_loc == EMS_I_Found || msg_loc == EMS_I_NoMore)
        {
        /*
         * The object located could be a graphic object or a fence object
         * or any kind of set. Call this function to break up the set into
         * processable entities also applying the eligible class list and
         * the non-eligible class list criteria on these objects. Ignore
         * this check if no flexible owners are locatable.
         */

        save_stat = msg_loc;
        if (! (lopts & EC_LOC_NOFLEXGROUPS))
          {
          stat_OM = EMselective_fence (&ME.ECelements->elig_classes, 
                     &ME.ECelements->nelig_classes, &objev.located_object[0],
                     FALSE, FALSE, my_id, &num_loccomps, &loccomps, &msg_loc);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           ret_end);
          }
        else
          {
          loccomps = (struct GRlc_info *) om$malloc
                      (size = sizeof (struct GRlc_info));
          EMerr_hndlr (!loccomps, stat_OM, OM_E_ABORT, ret_end);
          OM_BLOCK_MOVE (&objev.located_object[0], loccomps,
           sizeof (struct GRlc_info));
          num_loccomps = 1;
          }

        blksize = num_elems + num_loccomps;
        if (blksize > max_to_locate)
          {
          ex$message(msgnumb = EMS_S_TooManyEleLoc);
          if (loccomps)
            {
            om$dealloc (ptr = loccomps);
            loccomps=NULL;
            }
          continue;
          }

        /*
         * Unless the option to not check for duplicates is on, check if
         * any of the elements located have been previously located. If
         * so remove all duplicates from the list of these recently
         * located elements.
         */

        num_elems = ME.ECelements->num_elems;
        if (!(lopts & EC_LOC_NOCHKDUPLICATES))
          {
          inx = 0;
          curr_elems = ME.ECelements->elems;
          while (inx < num_loccomps)
            {
            elemid = loccomps[inx].located_obj;
            found = FALSE;
            for (j=0; j<num_elems; j++)
              if (elemid.objid == curr_elems[j].located_obj.objid &&
                  elemid.osnum == curr_elems[j].located_obj.osnum)
                {
                blksize = (num_loccomps - inx - 1) * sizeof (struct GRlc_info);
                if (blksize)
                  OM_BLOCK_MOVE (&loccomps[inx+1], &loccomps[inx], blksize);
                num_loccomps--;
                found = TRUE;
                break;
                }
            if (!found)
              inx++;
            }
          }

	/*
	 * Project the locate point if it is requested. JSY -- 12/29/92
	 */
        if (lopts & EC_LOC_PROJLOCPT)
  	{
	  num_events = ME.ECelements->num_events;
	  vla_size = om$dimension_of (varray = ME.ECelements->locevents);
	  blksize = num_events + 1;
	  if (blksize > vla_size)
          {
	    blksize += ELEMS_ARRAY_INCR;
	    stat_OM = om$vla_set_dimension (varray = ME.ECelements->locevents,
					    size = blksize);
	    EMomerr_exit (stat_OM, ret_end);
          }

	  ptr_locev = &ME.ECelements->locevents[num_events];
	  memcpy(ptr_locev, locev, sizeof(struct GRevent));

	  display_flag1 = PROJ_ACCEPT_POINT | ELEM_HILIGHT;
	  no_bytes = sizeof(IGRboolean);
	  gr$get_bore_locate(msg = &msg_loc,
			     sizbuf = &no_bytes,
			     buffer = &is_bore,
			     nret = &no_bytes);
	  no_bytes = sizeof(struct GRmd_env);
	  gr$get_module_env(msg = &msg_loc,
			    sizbuf = &no_bytes,
			    buffer = &mod,
			    nret = &no_bytes);

	  /* copy the GRid from event3 to event1 before projecting */
	  memcpy(&ptr_locev->located_object[0].located_obj,
		 &objev.located_object[0].located_obj,
		 sizeof(struct GRid));
	  
	  LCobj_project(ptr_locev, display_flag1, is_bore, TRUE, &mod);
	}

        vla_size = om$dimension_of (varray = ME.ECelements->elems);
        if (blksize > vla_size)
          {
          blksize = (blksize / ELEMS_ARRAY_INCR) * ELEMS_ARRAY_INCR +
                    (blksize % ELEMS_ARRAY_INCR ? ELEMS_ARRAY_INCR : 0);
          stat_OM = om$vla_set_dimension (varray = ME.ECelements->elems,
                     size = blksize);
          EMomerr_exit (stat_OM, ret_end);

          stat_OM = om$vla_set_dimension (varray = ME.ECelements->elemprops,
                     size = blksize);
          EMomerr_exit (stat_OM, ret_end);
          }

        num_events = ME.ECelements->num_events;
        vla_size = om$dimension_of (varray = ME.ECelements->num_atevent);
        blksize = num_events + 1;
        if (blksize > vla_size)
          {
          blksize += ELEMS_ARRAY_INCR;
          stat_OM = om$vla_set_dimension (varray = ME.ECelements->num_atevent,
                     size = blksize);
          EMomerr_exit (stat_OM, ret_end);
          }

        elem = &ME.ECelements->elems[num_elems];
        elemprops = &ME.ECelements->elemprops[num_elems];
        for (i=0; i<num_loccomps; i++)
          {
          elem[i] = loccomps[i];
          elemprops[i] = NULL;

          elemid = elem[i].located_obj;
          stat_OM = om$get_classid (objid = elemid.objid,
                     osnum = elemid.osnum, p_classid = &elemclass);
          EMomerr_exit (stat_OM, ret_end);
  
          stat_OM = om$is_ancestry_valid (subclassid = elemclass,
                     superclassid = OPP_GRcurve_class_id);
          EMomerr_exit (stat_OM, ret_end);
 
          if (stat_OM == OM_S_SUCCESS)
            elemprops[i] |= EC_ELEM_ISCURVE;

          reversed = FALSE;
          if (lopts & EC_LOC_DISPELEMDIR &&
              elemprops[i] & EC_ELEM_ISCURVE)
            {
            locev->located_object[0] = elem[i];
            stat_func = EFdetermine_direction (locev, my_id, &msg_loc);
            EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
            reversed = locev->located_object[0].geom_parms.polygon_inx;

            stat_func = EFdisplay_curve_normal_or_tangent (&elem[i], NULL,
                         FALSE, reversed, my_id, GRhhd,
                         &ME.ECelements->active_md_env, 
                         &ME.ECelements->active_display, &msg_loc);
            EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
            }
          elemprops[i] |= reversed ? EC_ELEM_ISREVERSED : NULL;
          }
        num_elems = ME.ECelements->num_elems += num_loccomps;
        ME.ECelements->num_atevent[num_events] = num_loccomps;
        num_events = ++ME.ECelements->num_events;
        if (save_stat == EMS_I_NoMore)
          max_to_locate = num_elems;

        if (num_elems < max_to_locate)
          {
          locate_accept_point = TRUE;
          if (locev->response == EX_OBJID ||
              (locev->subtype != GRst_REGULAR &&
               accev->located_object[0].located_obj.objid ==
                objev.located_object[0].located_obj.objid))
            locate_accept_point = FALSE;

          if (locate_accept_point)
            {
            stat_OM = ex$putque (msg = &msg_loc, response = &accev->response,
                       byte = &putquesize, buffer = (IGRchar *) &accev->event);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, 
             ret_end);
            }
          }
        else
          {
            UI_prompt ("");
          }

        *useract = EMSuser_data;
        ME.ECelements->elems_hilit = TRUE;
        }
      loop_done = FALSE;
      }

    else if (ME.ECelements->locate_stack.num_entries)
      {
      /*
       * The locate cycle was interrupted in the accept/reject phase.
       * Some processing might be necessary.
       */

      /*
       * If the interruption is caused by requesting no accept/reject cycle,
       * then take the object on the stack as the one located. SY -- 02/17/93
       */
      if (lopts & EC_LOC_NO_ACC_RJT)
      {
        ME.ECelements->num_elems = 1;
	inx = ME.ECelements->locate_stack.num_entries - 1;
	memcpy(ME.ECelements->elems, &ME.ECelements->locate_stack.entry[inx],
	       sizeof(struct GRlc_info));
	ME.ECelements->locate_stack.num_entries = 0;
        *useract = EMSuser_data;
      }
      else if (*response == EX_BACK_UP)
        {
        ME.ECelements->locate_stack.num_entries = 0;
        if (loccomps)
          {
          om$dealloc (ptr = loccomps);
          loccomps=NULL;
          }
        continue;
        }
      else if (*response ==  EX_RESTART)
        {
        ME.ECelements->locate_stack.num_entries = 0;
        locev->response = *response;
        *useract = EMSuser_unknown;
        }
      else
        *useract = EMSuser_unknown;
      }

    else if (lcmsg == LC_NO_OBJ_LOCATED)
      {
      /*
       * Neither has an object been located nor has it been stacked
       * in the middle of an accept/reject.
       */
      if (lopts & EC_LOC_NO_ACC_RJT)
      {
        ME.ECelements->num_elems = 0;
	ME.ECelements->locate_stack.num_entries = 0;
        *useract = EMSuser_data;
      }
      else if (locev->response == GR_UNKNOWN_TYPE &&
        (*response == EX_DATA ||
         *response == EX_RJT_MOVEON ||
         *response == EX_BACK_UP || 
         *response == EX_OBJID ||
         *response == EX_RESTART))
        {
        ex$message(msgnumb = EMS_I_00005);
	loop_done = FALSE;
        continue;
        }

      else if (locev->response == EX_DATA)
        {
        if (lopts & EC_LOC_NO_RELOCATE)
	  *useract = EMSuser_unknown;
        continue;
        }
      
      else if (locev->response == EX_RJT_MOVEON)
        *useract = EMSuser_moveon;

      else if (locev->response == EX_BACK_UP)
        {
        num_events = ME.ECelements->num_events;
        if (num_events)
          {
          num_atevent = ME.ECelements->num_atevent[num_events-1];
          num_elems = ME.ECelements->num_elems;
          elem = &ME.ECelements->elems[num_elems-num_atevent];
          elemprops = &ME.ECelements->elemprops[num_elems-num_atevent];

          for (i=0; i<num_atevent; i++)
            {
            if (elemprops[i] & EC_ELEM_ISCURVE &&
                lopts & EC_LOC_DISPELEMDIR)
              {
              stat_func = EFdisplay_curve_normal_or_tangent (&elem[i], NULL,
                           FALSE, elemprops[i] & EC_ELEM_ISREVERSED, my_id,
                           GRhe, &ME.ECelements->active_md_env, 
                           &ME.ECelements->active_display, &msg_loc);
              EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_OM, OM_E_ABORT,
               ret_end);
              }

            elem_env = &elem[i].module_info;
            dpmode = GRhe;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                       &elem_env->md_env.matrix_type, elem_env->md_env.matrix,
                       &dpmode, &ME.ECelements->active_md_env.md_id), 
                       targetid = elem[i].located_obj.objid,
                       targetos = elem[i].located_obj.osnum);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
             ret_end);
            }

          num_elems = ME.ECelements->num_elems -= num_atevent;
          num_events = --ME.ECelements->num_events;
          if (!num_elems)
            ME.ECelements->elems_hilit = FALSE;
          loop_done = FALSE;
          }
        else
          *useract = EMSuser_backup;
        }

      else
        *useract = EMSuser_unknown;
      }
/* fix for mlk */
    if (loccomps)
      {
      om$dealloc (ptr = loccomps);
      loccomps=NULL;
      }
    }
  while (!loop_done && num_elems < max_to_locate);

ret_end:
  if (EMSerror (stat_OM))
    *response = TERMINATE;
  
  if (loccomps)
    om$dealloc (ptr = loccomps);

  return (stat_OM);
}

/*
History
    SY 	:	12/11/92

    If there is a user specified handler then use it. This eliminates
    the need to override this method for classes subclassing from it.
    Subclasses need to call method set_locobj_hndlr_func to reset
    ME.ECelements->locobj_hndlr to different handler functions.
*/

method proc_locobj (IGRlong *msg; struct GRevent *loc_event, *acc_event,   
                    *obj_event)
{
  IGRlong sts;
  
  sts = OM_S_SUCCESS;

  if (ME.ECelements->locobj_hndlr)
    sts = (*ME.ECelements->locobj_hndlr)(msg, loc_event, acc_event, obj_event);
  else
    *msg = EMS_I_Found;

  return sts;
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
  rtree_classes->p_classes[0] = OPP_GRgraphics_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_GRgraphics_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = NULL;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}


method set_hndlr_funcs (IGRlong *msg;
                        IGRboolean (*acthndlr)(); IGRchar *acthndlr_args;
                        IGRboolean (*selhndlr)(); IGRchar *selhndlr_args)
{
  *msg = EMS_S_Success;

  ME.ECelements->acthndlr = acthndlr;
  ME.ECelements->acthndlr_args = acthndlr_args;
  ME.ECelements->selhndlr = selhndlr;
  ME.ECelements->selhndlr_args = selhndlr_args;

  return (OM_S_SUCCESS);
}


method set_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                            OM_S_CLASSLIST *rtree_classes, *elig_classes,
                            *nelig_classes; IGRushort geomprops;
                            IGRshort operation; IGRushort options;
                            IGRint minnum_to_locate, maxnum_to_locate)
{
  IGRushort topo_props;
  IGRlong display_flag, locate_mask, accept_mask;
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ME.ECelements->locate_stack.num_entries = 0;
  ME.ECelements->num_elems = 0;
  ME.ECelements->num_events = 0;

  if (rtree_classes->w_count > maxnum_classes ||
      elig_classes->w_count > maxnum_classes ||
      nelig_classes->w_count > maxnum_classes)
  {
    UI_status("Cannot locate too many classes");
    stat_OM = OM_E_ABORT;
    goto quit;
  }
  
  ME.ECelements->rtree_classes.w_count = rtree_classes->w_count;
  ME.ECelements->rtree_classes.w_flags = rtree_classes->w_flags;
  ME.ECelements->rtree_classes.p_classes = ME.ECelements->r_classmem;
  memcpy(ME.ECelements->r_classmem, rtree_classes->p_classes,
	 rtree_classes->w_count * sizeof(GRclassid));
  
  ME.ECelements->elig_classes.w_count = elig_classes->w_count;
  ME.ECelements->elig_classes.w_flags = elig_classes->w_flags;
  ME.ECelements->elig_classes.p_classes = ME.ECelements->e_classmem;
  memcpy(ME.ECelements->e_classmem, elig_classes->p_classes,
	 elig_classes->w_count * sizeof(GRclassid));

  ME.ECelements->nelig_classes.w_count = nelig_classes->w_count;
  ME.ECelements->nelig_classes.w_flags = nelig_classes->w_flags;
  ME.ECelements->nelig_classes.p_classes = ME.ECelements->ne_classmem;
  memcpy(ME.ECelements->ne_classmem, nelig_classes->p_classes,
	 nelig_classes->w_count * sizeof(GRclassid));
  
  if (operation == EC_GEOM_READ || operation == EC_ATTR_READ)
  {
    geomprops |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_RW;
    topo_props = LC_RIGID_COMP | LC_RIGID_OWNER | 
                 LC_FLEX_COMP | LC_FLEX_OWNER | 
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else if (operation == EC_ATTR_WRITE)
  {
    geomprops |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_WRITE_ONLY;
    topo_props = LC_RIGID_COMP | LC_RIGID_OWNER |
                 LC_FLEX_COMP | LC_FLEX_OWNER | 
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else if (operation == EC_GEOM_CHGSHAPE || operation == EC_GEOM_NOCHGSHAPE)
  {
    geomprops |= LC_LC_ONLY | LC_DP_ONLY | IGN_MOD_BIT | LC_WRITE_ONLY;
    topo_props = LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | 
                 LC_REF_OBJECTS | LC_NO_REF_HEADER;
  }
  else
  {
    stat_OM = OM_E_ABORT;
    goto quit;
  }

  if (options & EC_LOC_RIGIDCOMPOK)
    topo_props |= LC_RIGID_COMP;
   
  if (options & EC_LOC_ASSOCOK)
    topo_props |= LC_ASSOCIATIVE;

  if (options & EC_LOC_EXTCONSTOK)
    topo_props |= LC_EXTERN_CONSTRAINED;

  if (options & EC_LOC_NOFLEXGROUPS)
    topo_props &= ~LC_FLEX_OWNER;
  else if (maxnum_to_locate > 1 && topo_props & LC_FLEX_OWNER)
    ME.ECelements->e_classmem[ME.ECelements->elig_classes.w_count++] = OPP_GRflxown_class_id;

  if (options & EC_LOC_READONLYOK)
    geomprops |= LC_READ_ONLY;


  locate_mask = GRm_DATA | GRm_TEXT_VALUE | GRm_BACK_UP;
  if (maxnum_to_locate > 1 && !(options & EC_LOC_NOSPECOBJS))
    locate_mask |= GRm_SPECIFIED_OBJ;
  if (minnum_to_locate == 0)
    locate_mask |= GRm_RJT_MOVEON;

  accept_mask = GRm_DATA;
  if (maxnum_to_locate > 1)
  {
    accept_mask |= GRm_TEXT_VALUE;
    if (!(options & EC_LOC_NOSPECOBJS))
      accept_mask |= GRm_SPECIFIED_OBJ;
  }

  ME.ECelements->locate_mask = locate_mask;
  ME.ECelements->accept_mask = accept_mask;
  ME.ECelements->owner_action = topo_props;
  ME.ECelements->properties = geomprops;
  ME.ECelements->min_to_locate = minnum_to_locate;
  ME.ECelements->max_to_locate = maxnum_to_locate;
  ME.ECelements->options = options;

  display_flag = (options & EC_LOC_DISPONEWINDOW ? ONE_WINDOW : ALL_WINDOWS ) |
                 ELEM_HILIGHT |
                 (options & EC_LOC_PROJACCPT ?
                  PROJ_ACCEPT_POINT : NO_PROJ_ACCEPT_POINT) |
		 (options & EC_LOC_NO_ACC_RJT ?
                  NO_ACC_REJ_CYCLE | DO_NOT_RELOCATE :
                  ACC_REJ_CYCLE |
		  (options & EC_LOC_NO_RELOCATE ?
		   DO_NOT_RELOCATE : RELOCATE )) | LC_REGULAR_HIGHLIGHT |
                 LC_ERASE_LOC_ELEMENT;
  if (options & EC_LOC_DISPELEMDIR || options & EC_LOC_PROJLOCPT)
    display_flag |= LC_INPUT_LOC_POINT;
  if (maxnum_to_locate > 1)
    display_flag |= LC_ACCEPT_CURSOR;
  ME.ECelements->display_flag = display_flag;

quit:
  return (stat_OM);
}


method set_locobj_hndlr_func (IGRlong *msg; IGRint (*locobj_hndlr)())
{
  *msg = MSSUCC;

  ME.ECelements->locobj_hndlr = locobj_hndlr;

  return OM_S_SUCCESS;
}


/*
 * This is the action-handler used in order to not go through the accept-reject
 * cycle if the object being located is already in the list of located
 * objects. This is a subset of EFlocate_action_handler().
 */

IGRlong EMlocate_eligchk_hndlr (curr_info, new_locinfo, priv_args, action)
struct locate_acthndlr_args *curr_info;
struct GRlc_info *new_locinfo;
struct LC_action_args *priv_args;
enum GRlocate_action *action;
{
  IGRboolean eligible, planar_ele;
  IGRshort idmattyp;
  IGRint i, numclasses;
  IGRlong msg_loc, stat_func;
  IGRmatrix idmat;
  GRclassid newclassid, *classids, classid;
  struct GRid *newid, *locid, *locid1, origin_id;
  struct IGRbsp_curve *crv;
  struct IGRbsp_surface *srf;
  enum GRlocate_action locact;
  extern void EMidmatrix();
  extern IGRlong LCptlocact(), EMgetabsg();
  IGRboolean aflag = 0;
  long  sts = OM_S_SUCCESS; 

 locid1 = &new_locinfo->located_obj;

 om$get_classid (objid = locid1->objid, osnum = locid1->osnum,
      p_classid = &classid);

if(aflag = pwIsActivationOn())
 {
 GRspacenum osn;
 osn = pwGetActiveOs();

 if(om$is_ancestry_valid(subclassid = classid, 
        superclassid = OPP_SKdumpt_class_id) == OM_S_SUCCESS)
 {
  stat_func = om$send (msg = message SKdumpt.SKget_origin_id(&msg_loc,&origin_id),
      senderid = NULL_OBJID, targetid = locid1->objid, targetos = locid1->osnum);
   EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
  if(origin_id.osnum != osn)
     return (sts);
 }
 else
 {
   if(new_locinfo->located_obj.osnum != osn)
     return (sts);
 }
 }


  stat_func = TRUE;
  eligible = TRUE;
  
  /*
   * If the action is to add, then first check to see if the input list
   * already has the object. If so then we don't want to go through the
   * accept/reject handler. 
   */

  locact = *action;
  if (locact == add_all || locact == add_inside || locact == add_outside ||
      locact == add_overlap || locact == add_nopost)
    {
    newid = &new_locinfo->located_obj;
    for (i=0; i<curr_info->numelems; i++)
      {
      locid = &curr_info->elems[i].located_obj;
      if (locid->objid == newid->objid && locid->osnum == newid->osnum)
        {
        eligible = FALSE;
        break;
        }
      }

    /*
     * Check if the newly located object is of an ineligible class.
     * If so, the object is rendered ineligible.
     */

    numclasses = curr_info->nelig_classes.w_count;
    if (eligible && numclasses)
      {
      stat_func = om$get_classid (objid = newid->objid, osnum = newid->osnum,
                   p_classid = &newclassid);
      EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);

      classids = curr_info->nelig_classes.p_classes;
      for (i=0; i<numclasses; i++)
        {
        stat_func = om$is_ancestry_valid (subclassid = newclassid, 
                     superclassid = classids[i]);
        EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
          
        if (stat_func == OM_S_SUCCESS)
          {
          eligible = FALSE;
          break;
          }
        stat_func = TRUE;
        }
      }

    /*
     * If the option to locate only objects that have a potential unambiguos
     * plane definition is set, check for this.
     */

    if (eligible && curr_info->options & EC_LOC_PLANEDEF)
      {
      planar_ele = FALSE;
      EMidmatrix (&msg_loc, &idmattyp, idmat);

      stat_func = om$get_classid (objid = newid->objid, osnum = newid->osnum,
                   p_classid = &newclassid);
      EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);

      stat_func = om$is_ancestry_valid (subclassid = newclassid, 
                   superclassid = OPP_EMSsubbs_class_id);
      EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
          
      if (stat_func != OM_S_SUCCESS)
        {
        stat_func = om$is_ancestry_valid (subclassid = newclassid, 
                     superclassid = OPP_GRcurve_class_id);
        EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);

        if (stat_func != OM_S_SUCCESS)
          eligible = FALSE;
        else
          {
          stat_func = EMgetabsg (&msg_loc, &idmattyp, idmat,
                       newid->osnum, newid->objid, &crv);
          EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
          if (crv->planar)
            planar_ele = TRUE;
          else
            planar_ele = FALSE;
          }
        }
      else
        {
        stat_func = EMgetabsg (&msg_loc, &idmattyp, idmat,
                     newid->osnum, newid->objid, &srf);
        EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
        if (srf->planar)
          planar_ele = TRUE;
        else
          planar_ele = FALSE;
        }
      stat_func = TRUE;

      if (planar_ele)
	ex$message(msgnumb = EMS_P_AccWiFirPtOnXaxis, 
		buff = curr_info->acc_prompt) 
      else
	ex$message(msgnumb = EMS_P_AccAtPtForViewNor,
		buff = curr_info->acc_prompt) 
      }
    }

  if (eligible)
    stat_func = LCptlocact (NULL, new_locinfo, priv_args, action);

ret_end:
  return (stat_func);
}

end implementation ECelements;
