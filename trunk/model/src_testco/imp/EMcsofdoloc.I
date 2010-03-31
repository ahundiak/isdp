/*
NAME:
     do_locate

ABSTRACT:

 This is the override of the 'do_locate' method for offset surfaces. 

ARGUMENTS:

RETURN VALUES:

DESCRIPTION:

NOTES:

KEYWORDS:

HISTORY:

    Sudhakar : 20Jul'93  :  Creation
    Sudhakar : 02Feb'94  :  Modified to enable the place offset and
                            thinwall forms to be edited when in do_locate.
                            [TR# 119416611].
*/

class implementation ECcsoffset;

#include <stdio.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h" /* for co$getevent */
#include "lcdef.h"
#include "lc.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "EMSaction.h"  /* for EMSaction_handler */

#include "EMSasmacros.h"
#include "emssfintdef.h"
/* #include "emssfint.h" */
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMS.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSfeadef.h"
#include "EMSopt.h"
#include "plotmacros.h"

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


from GRgraphics import GRdisplay;


method do_locate (IGRlong *msg; enum EMSuser_responses *useract;
                  IGRint *response; IGRchar *response_data;
                  IGRchar *elemtype, *postmsg_gen,
                  *postmsg_1, *postmsg_2, *postmsg_3;
                  IGRushort options)
{
  IGRboolean stat_func, loop_done, locate_accept_point, found, reversed;
  IGRboolean is_bore;
  IGRchar key_locate_str[MAX_CHAR];
  IGRchar locate_str[MAX_CHAR], accept_str[MAX_CHAR], relocate_str[MAX_CHAR];
  IGRchar add_str[MAX_CHAR];
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

  strcpy(add_str, "");
  if (postmsg_gen)
    strcpy (add_str, postmsg_gen);
  if (postmsg_2)
    strcat (add_str, postmsg_2);
  if (max_to_locate - ME.ECelements->num_elems > 1)
    ex$message(msgnumb = EMS_P_AccIdNext, type = "%s",
        var = `add_str`, buff = accept_str)
  else
    ex$message(msgnumb = EMS_P_Accept, type = "%s",
        var = `add_str`, buff = accept_str)

  ex$message(msgnumb = EMS_P_Reject, buff = tmp_buff);
  strcat(accept_str, tmp_buff);

  ex$message(msgnumb = EMS_P_EleNotFound, type = "%s",
	var = `elemtype`, buff = relocate_str);

  loop_done = FALSE;
  do
    {
    if(num_elems)
       {
       ex$message(msgnumb = EMS_S_IdenNextElemtype, type = "%s",
                var = `elemtype`, buff = key_locate_str);
       }
    else
       {
       ex$message(msgnumb = EMS_S_IdenElemtype, type = "%s",
                var = `elemtype`, buff = key_locate_str);
       }
    strcpy (locate_str, key_locate_str);

    if (num_elems)
      {
      if (postmsg_gen)
        strcat (locate_str, postmsg_gen);
      if (postmsg_3)
        strcat (locate_str, postmsg_3);
      if (num_elems >= ME.ECelements->min_to_locate)
        {
        locate_mask |= GRm_RJT_MOVEON;
	ex$message(msgnumb = EMS_P_MvOnWhenDone, buff = tmp_buff);
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
#ifdef DEBUG
 if(stat_func & 1)
    printf("Successful in lc-locate of do_locate\n");
 else
    printf("Error in lc-locate of do_locate\n");
 printf(" ME.ECelements->attributes.owner_action = %d\n", lc_attr.owner_action);
 printf(" ME.ECelements->attributes.properties = %d\n", lc_attr.properties);
 printf(" ME.ECelements->display_flag = %d\n", display_flag);
 printf(" ME.ECelements->locate_mask = %d\n", locate_mask);
 printf(" ME.ECelements->accept_mask = %d\n", accept_mask);
 printf(" ME.ECelements->min_to_locate = %d\n", min_to_locate);
 printf(" ME.ECelements->max_to_locate = %d\n", max_to_locate);
#endif

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

end implementation ECcsoffset;

