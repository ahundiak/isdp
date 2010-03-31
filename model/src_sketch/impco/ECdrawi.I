/*

Name
  Place Profile command object overrides.

Abstract
  Command object for Place LineArc and Profile methods.
  
Synopsis

Description

Return Value

Notes

Index

Keywords

History
  06/05/92 : Vadiraj : Modified for message subsystem compliance.
  06/25/92 : Rajiv Agrawal : Modified the backup usage.  Added a status form
                       for Place profile command to place arc.  
                       Cleaned up a lot of code and removed some duplication.
  07/10/92 : Rajiv Agrawal : Took out the code for the execute method and created
                       a new file called ECdrawexec.I.
  01/23/93 : Kumar N : Reaction to shamrock - WINDOWS NT  
  06/12/93 : Rajiv Agrawal : Modify profile functionality.
  09/09/93 : Rajiv Agrawal : Additions to support ONEPROFILE command mode.  
  09/18/93 : Rajiv Agrawal : Moved the shortcut functionality into a callable function.
  01/17/94 : Sudha         : disable Close option for edit profile command
			     - fix tr#119415540  
  02/11/94 : Sudha         : Moved the GRdisplay_associative_button after the mode change in
                             sleep method (fix TR#119313951 & TR#119416936).
  08/13/94 : scw           : Added X11 for Intel Solaris port
  08/15/94 : scw           : Clarified sleep emthod
  07/11/95 : Satya         : Disabled Close option for edit profile command
                             for some cases which were not dealt with
                             properly before
 
 */

class implementation ECdraw;

#include <values.h>
#include <string.h>
#include <math.h>

#include "igrdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "EMSasmacros.h"
#include "EMSdraw.h"
#include "ECcmd.h"
#include "ECmsg.h"
#include "SSmacros.h"
#ifdef X11
#include "limits.h"
#include "X11/keysym.h"
#endif

#include "madef.h"
#include "maidmx.h"
 
#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#endif
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRbspline_class_id;
from GRgraphics import GRdisplay, GRchgprops;

#define FORM_XLOC	0
#define FORM_YLOC	105

#define MAX_WORD_LEN  20

#define MODIFY_SEGMENT 1
#define MODIFY_VERTEX  2

method init (IGRint type; IGRchar *string)
{
  IGRint 	  i, j;
  IGRlong 	  stat_OM; 
  IGRpoint 	  *pts;
  struct IGRline  *lines;

  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, 
                     msg = message ECelements.init(type, string), 
                     targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  ME.ECdraw->form_ptr = NULL;
  ME.ECdraw->line_state = TRUE;
  ME.ECdraw->angle_constr = FALSE;
  ME.ECdraw->symm_state = FALSE;
  ME.ECdraw->horver_state = FALSE;
  me->have_to_decide = TRUE; 

  ME.ECdraw->firstobj = NULL_OBJID;
  ME.ECdraw->compobj = NULL_OBJID;
  ME.ECdraw->wingrid.objid = NULL_OBJID;
  ME.ECdraw->cur_comp_inx = 0;

  ME.ECdraw->symm_line.point1 = ME.ECdraw->symmpt_store[0];  
  ME.ECdraw->symm_line.point2 = ME.ECdraw->symmpt_store[1];

  ME.ECdraw->num_pts = 0;

  pts = ME.ECdraw->tolpt_store;
  lines = ME.ECdraw->tol_constr_lines;
  for (i=0, j=0; i<4; i++, j+=2)
  {
    lines[i].point1 = pts[j];
    lines[i].point2 = pts[j+1];
    ME.ECdraw->active_tol_constr[i] = FALSE;
  }

  ME.ECdraw->angle_constr_line.point1 = ME.ECdraw->anglept_store[0];
  ME.ECdraw->angle_constr_line.point2 = ME.ECdraw->anglept_store[1];

  pts = ME.ECdraw->inttolpt_store;
  lines = ME.ECdraw->inttol_constr_lines;
  for (i=0, j=0; i<12; i++, j+=2)
  {
    lines[i].point1 = pts[j];
    lines[i].point2 = pts[j+1];
  }
  ME.ECdraw->num_inttol_constr = 0;

  ME.ECdraw->modify_state = 0;
  
  ME.super_cmd->state = FIRSTPT_STATE;
  me->have_to_decide = FALSE;    

  if (ME.super_cmd->mytype == MODIFYPROFILE)
    ME.super_cmd->state = MODIFY_PROFILE_STATE;
  else if (me->mytype == VARPROFILE || me->mytype == LINEARC)
    me->have_to_decide = TRUE;
    
ret_end:
  return (stat_OM);
}

method status_disp()
{
  IGRint stat_func;
  IGRlong stat_OM, msg_loc;
  IGRchar form_name[20];
  IGRint ECdraw_formfunc();

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == LINEARC)
    strcpy (form_name, "GRCompOption");
  else
    strcpy (form_name, "GRPlProfile");
    
  if (ME.ECdraw->form_ptr == NULL)
  {
    stat_func = FIf_new (0, form_name, ECdraw_formfunc, &ME.ECdraw->form_ptr);
    EMerr_hndlr (stat_func != FI_SUCCESS, stat_OM, OM_E_ABORT, ret_end);
  
    stat_func = FIf_set_location (ME.ECdraw->form_ptr, FORM_XLOC, FORM_YLOC);
    EMerr_hndlr (stat_func != FI_SUCCESS, stat_OM, OM_E_ABORT, ret_end);

    stat_func = FIf_set_cmd_oid_os (ME.ECdraw->form_ptr, my_id, OM_Gw_current_OS);
    EMerr_hndlr (stat_func != FI_SUCCESS, stat_OM, OM_E_ABORT, ret_end);
  }
  
  om$send (msg = message ECdraw.do_form_disp (&msg_loc), targetid = my_id);

ret_end:
  return (stat_OM);
}

method wakeup (IGRint pos)
{
  IGRboolean flag, aflag;
  IGRint dum;
  IGRlong msg_loc, stat_OM;
  IGRdouble dittol, vwscale;
  struct var_list list_var[2];

  if (me->have_to_decide)
    /*
     * Intentional block. If the associative flag is on and the reference plane
     * lock is on, then construct a variational profile, else place a
     * good old composite curve. pp 09/02/91 
     *
     * NOTE: this block was moved from init to wake-up method due to TR92N1065.
     * We want to decide only the first time we enter the command, and after 
     * any previous command sleep method. Carlos, 02/17/92. 
     */
  {
     IGRboolean  state;

     gr$get_associative_flag( buffer = &state );

     if (state)
       me->mytype = VARPROFILE;
     else
       me->mytype = LINEARC;

     me->have_to_decide = FALSE;
  }

  om$send (mode = OM_e_wrt_message, msg = message ECelements.wakeup (pos),
           targetid = my_id);

  aflag = pwIsActivationOn();
  if (aflag)
  {
    pwGetActiveModuleEnv(&ME.ECelements->active_md_env);
   /*****
    MAidmx( &msg_loc, ME.ECelements->active_md_env.md_env.matrix);
    ME.ECelements->active_md_env.md_env.matrix_type = MAIDMX;
   ****/
  }

  gr$get_dynamics_on (msg = &msg_loc, buffer = &ME.ECdraw->dyn_on);
  flag = TRUE;
  gr$put_dynamics_on (msg = &msg_loc, buffer = &flag);

  if (!IF_NULL_OBJID (ME.ECdraw->wingrid.objid))
  {
    gr$get_dit_tolerance (buffer = &dittol);
    dittol += dittol;

    list_var[0].var = VVOL_VIEWPORT_SCALE;
    list_var[0].var_ptr = (IGRchar *) &vwscale;
    list_var[0].num_bytes = sizeof (IGRdouble);
    list_var[0].bytes_returned = (IGRlong *)&dum;

    list_var[1].var = END_PARAM;
    list_var[1].var_ptr = NULL;
    list_var[1].num_bytes = 0;
    list_var[1].bytes_returned = NULL;

    stat_OM = dp$inq_set_gragad (msg = &msg_loc,
               osnum = ME.ECdraw->wingrid.osnum, 
               gragad_objid = ME.ECdraw->wingrid.objid, which_error = &dum,
              var_list = list_var);
    if (!EMSerror (stat_OM & msg_loc))
      ME.ECdraw->wintol = dittol / vwscale;
  }

  if (me->mytype != LINEARC)
  {
    IGRboolean assoc_flag;

    gr$get_associative_flag( buffer = &assoc_flag );
 
    if (!assoc_flag)
    {
      assoc_flag = TRUE;
      gr$put_associative_flag( buffer = &assoc_flag );
      me->change_global_assoc_flag = TRUE;
    }
    else
      me->change_global_assoc_flag = FALSE;

    EFrefplane_lock_mgr(&msg_loc,NULL,TRUE,&me->prev_ref_lock_state);

    GRdisplay_associative_button(TRUE);
  }

  if (ME.ECdraw->form_ptr)
    om$send (msg = message ECdraw.do_form_disp (&msg_loc), targetid = my_id);

  /*
   * Invoke the Smart Sketch technology.
   */
  ss$enter();
  ss$activate();
  
  GRstatus_display_button (TRUE);
  return (OM_S_SUCCESS);
}


method super_cmd.sleep (IGRint pos)
{
  IGRlong msg_loc;
  extern void COclear_vsd();

  COclear_vsd();

  gr$put_dynamics_on (msg = &msg_loc, buffer = &ME.ECdraw->dyn_on);

  if (ME.ECdraw->form_ptr)
    FIf_erase (ME.ECdraw->form_ptr);
   
  if (me->mytype != LINEARC)
  {
    IGRint msg_loc;

    if (me->change_global_assoc_flag)
    {
      IGRboolean assoc_flag;
      assoc_flag = FALSE;
      gr$put_associative_flag( buffer = &assoc_flag );
    }
    GRdisplay_associative_button(0);

    if (!(me->prev_ref_lock_state))
      EFrefplane_lock_mgr(&msg_loc,NULL,FALSE,NULL);
  }

  ss$exit();
  GRstatus_display_button (FALSE);
  
  return (om$send (mode = OM_e_wrt_message, msg = message ECelements.sleep
          (pos), targetid = my_id));
}


method delete (IGRint flag)
{
  IGRlong stat_OM, msg_loc;
  extern IGRint FIf_delete();

  stat_OM = OM_S_SUCCESS;

  if (ME.ECdraw->form_ptr)
  {
    FIf_erase (ME.ECdraw->form_ptr);
#ifdef NT
   IGRlong num_byte;
   IGRint  resp;
   struct GRevent dumevent;

   resp = EX_FORM_FINISHED;
   num_byte = sizeof (struct GRevent);

   status = ex$putque (msg = &EMmsg, response = &resp, byte = &num_byte,
                       buffer = dumevent.event.keyin);
   if (!(1&status&EMmsg)) return (OM_E_ABORT);
#endif
    FIf_delete (ME.ECdraw->form_ptr);
  }
  /*
   * If we were in Edit Profile mode, then turn the display and locate of the
   * modifified segments in case they were turned off.
   */
  if (ME.ECdraw->modify_state > 0)
  {
    IGRshort 		action, props;
    int 		i, end_inx;
    enum GRdpmode 	dpmode;
    struct GRmd_env 	*env;

    action = 1;
    props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    dpmode = GRbd;
    env = &ME.ECelements->active_md_env;
    end_inx = (ME.ECdraw->modify_state == MODIFY_SEGMENT ? 1 : 2);
    for (i=0; i < end_inx; i++) 
    {
      om$send  ( msg = message GRgraphics.GRchgprops 
                       (&msg_loc, &action, &props), 
                 targetid = ME.ECdraw->modseg[i].objid, 
                 targetos = ME.ECdraw->modseg[i].osnum);
      om$send (msg = message GRgraphics.GRdisplay 
                   (&msg_loc, &env->md_env.matrix_type,
                    env->md_env.matrix, &dpmode, &env->md_id),
               targetid = ME.ECdraw->modseg[i].objid, 
               targetos = ME.ECdraw->modseg[i].osnum);
    }
  }

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message ECelements.delete
             (flag), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
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
  elig_classes->p_classes[0] = OPP_GRbspline_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = EC_LOC_PROJACCPT;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}


/*
 * The following function gets invoked by the forms-system which in turn
 * calls the method on this command object.
 */
#argsused
IGRint ECdraw_formfunc (form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form form_ptr;
{
  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  EMerr_hndlr (stat_func != FI_SUCCESS, stat_OM, OM_E_ABORT, ret_end);

  stat_OM = om$send (msg = message ECdraw.do_form (&msg_loc, gadget_label),
                     senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
 
ret_end:
  return (stat_OM);
}

method do_form (IGRlong *msg; IGRint gadget_label)
{
  IGRchar str[MAX_WORD_LEN];
  IGRint count;
  IGRlong stat_OM, msg_loc;
  struct GRevent event;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  switch (gadget_label)
  {
    case LINE_STATE:
    	strcpy (str, "L");
    	break;

    case ARC_STATE:
    	strcpy (str, "A");
    	break;
    
    case ARCBYRADIUS_STATE:
    	strcpy (str, "R");
    	break;

    case AUTOCLOSE_STATE:
        strcpy (str, "C");
        break;

    case BEGINSYMM1_STATE:
     	strcpy (str, "S");
      	break;

    case PARCONSTR_STATE:
      	strcpy (str, "P");
      	break;

    case NORCONSTR_STATE:
     	strcpy (str, "N");
      	break;

    case HORCONSTR_STATE:
      	strcpy (str, "H");
      	break;

    case VERCONSTR_STATE:
      	strcpy (str, "V");
      	break;

    case COLLCONSTR_STATE:
      	strcpy (str, "I");
      	break;

    case ORTHOCONSTR_STATE:
      	strcpy (str, "O");
      	break;

    case REVCONSTR_STATE:
      	strcpy (str, "W");
      	break;

    case DELALLCONSTR_STATE:
      	strcpy (str, "E");
      	break;

    case KILLFORM_STATE:
      FIf_erase (ME.ECdraw->form_ptr);
      FIf_delete (ME.ECdraw->form_ptr);
      ME.ECdraw->form_ptr = NULL;
      goto ret_end;

    default:
      stat_OM = OM_E_ABORT;
      *msg = EMS_E_Fail;
      goto ret_end;
  }

  count = sizeof (struct GRevent);
  event.response = EX_STRING;
  strcpy (event.event.keyin, str);
  stat_OM = ex$putque (msg = &msg_loc, response = &event.response,
                       byte = (IGRlong *)&count, buffer = (IGRchar *)&event.event);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

ret_end:
 return (stat_OM);
}



IGRboolean EFdo_form_abling (Form form_ptr, short super_state, short horver_state, 
                             short symm_state, short cmdtype)
{
  IGRboolean stat_func;

  stat_func = TRUE;

  if (cmdtype != LINEARC)
  {
    switch (super_state)
    {
      case FIRSTPT_STATE:
         FIg_disable (form_ptr, ARC_STATE);
         FIg_disable (form_ptr, ARCBYRADIUS_STATE);
         FIg_disable (form_ptr, LINE_STATE);
         FIg_disable (form_ptr, AUTOCLOSE_STATE);
         FIg_disable (form_ptr, DELCONSTR_STATE);
         break;

      case NEXTPT_STATE:
         FIg_enable (form_ptr, ARC_STATE);
         FIg_enable (form_ptr, ARCBYRADIUS_STATE);
         FIg_enable (form_ptr, LINE_STATE);
         if (cmdtype != MODIFYPROFILE)
           FIg_enable (form_ptr, AUTOCLOSE_STATE);
         else
           FIg_disable (form_ptr, AUTOCLOSE_STATE);
         FIg_enable (form_ptr, DELCONSTR_STATE);
         break;

      case MODIFY_PROFILE_STATE:
         FIg_disable (form_ptr, AUTOCLOSE_STATE);
         break;

      default:
         break;      
    }
  }
  else
  {
    switch (super_state)
    {
      case FIRSTPT_STATE:
        FIg_enable (form_ptr, DELALLCONSTR_STATE);
        FIg_enable (form_ptr, REVCONSTR_STATE);
        FIg_disable (form_ptr, ARC_STATE);
        FIg_disable (form_ptr, ARCBYRADIUS_STATE);
        FIg_disable (form_ptr, HORCONSTR_STATE);
        FIg_disable (form_ptr, LINE_STATE);
        FIg_disable (form_ptr, AUTOCLOSE_STATE);
        FIg_disable (form_ptr, VERCONSTR_STATE);
        FIg_disable (form_ptr, PARCONSTR_STATE);
        FIg_disable (form_ptr, NORCONSTR_STATE);
        FIg_disable (form_ptr, COLLCONSTR_STATE);
        FIg_disable (form_ptr, ORTHOCONSTR_STATE);
        FIg_disable (form_ptr, BEGINSYMM1_STATE);
        FIg_disable (form_ptr, DELCONSTR_STATE);
        break;
  
      case NEXTPT_STATE:
        FIg_enable (form_ptr, ARC_STATE);
        FIg_enable (form_ptr, ARCBYRADIUS_STATE);
        FIg_enable (form_ptr, LINE_STATE);
        if (cmdtype != MODIFYPROFILE)
          FIg_enable (form_ptr, AUTOCLOSE_STATE);
        FIg_enable (form_ptr, DELCONSTR_STATE);
        FIg_enable (form_ptr, DELALLCONSTR_STATE);
        FIg_enable (form_ptr, REVCONSTR_STATE);
        if (!symm_state)
          FIg_enable (form_ptr, BEGINSYMM1_STATE);
        else
          FIg_disable (form_ptr, BEGINSYMM1_STATE);
        if (horver_state)
        {
          FIg_disable (form_ptr, HORCONSTR_STATE);
          FIg_disable (form_ptr, VERCONSTR_STATE);
          FIg_disable (form_ptr, PARCONSTR_STATE);
          FIg_disable (form_ptr, NORCONSTR_STATE);
          FIg_disable (form_ptr, COLLCONSTR_STATE);
          FIg_disable (form_ptr, ORTHOCONSTR_STATE);
          FIg_disable (form_ptr, BEGINSYMM1_STATE);
        }
        else
        {
          FIg_enable (form_ptr, HORCONSTR_STATE);
          FIg_enable (form_ptr, VERCONSTR_STATE);
          FIg_enable (form_ptr, PARCONSTR_STATE);
          FIg_enable (form_ptr, NORCONSTR_STATE);
          FIg_enable (form_ptr, COLLCONSTR_STATE);
          FIg_enable (form_ptr, ORTHOCONSTR_STATE);
        }
        break;

      case COLLCONSTR_STATE:
      case ORTHOCONSTR_STATE:
      case COLORTHCONSTR_STATE:
      case PARCONSTR_STATE:
      case NORCONSTR_STATE:
        FIg_disable (form_ptr, HORCONSTR_STATE);
        FIg_disable (form_ptr, VERCONSTR_STATE);
        FIg_disable (form_ptr, PARCONSTR_STATE);
        FIg_disable (form_ptr, NORCONSTR_STATE);
        FIg_disable (form_ptr, COLLCONSTR_STATE);
        FIg_disable (form_ptr, ORTHOCONSTR_STATE);
        FIg_disable (form_ptr, BEGINSYMM1_STATE);
        FIg_disable (form_ptr, DELCONSTR_STATE);
        FIg_disable (form_ptr, DELALLCONSTR_STATE);
        FIg_disable (form_ptr, REVCONSTR_STATE);
        break;

      default:
        stat_func = FALSE;
    }
  }
  
  return (stat_func);
}

method do_form_disp (IGRlong *msg)
{
  IGRboolean stat_func;
  IGRlong stat_OM;

  stat_OM = OM_S_SUCCESS;
  stat_func = EFdo_form_abling (ME.ECdraw->form_ptr, ME.super_cmd->state,
                                ME.ECdraw->horver_state, ME.ECdraw->symm_state,
                                ME.super_cmd->mytype);
  EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

  FIf_display (ME.ECdraw->form_ptr);

ret_end:
  return (stat_OM);
}

end implementation ECdraw;
