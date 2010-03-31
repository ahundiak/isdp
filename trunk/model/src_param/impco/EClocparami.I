class implementation EClocparam;

/*
   HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification
*/

#include "codpdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "execmsg.h"
#include "exdef.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "ECcmd.h"
#include "ECmsg.h"

#include "EMSasmacros.h"
#include "ma2lnpro.h"

#define POINTPARAM_CMD	0
#define VECTORPARAM_CMD 1
#define PLANEPARAM_CMD  2

#define NUM_STATIC_GEOMPARMS	10

/*
 * This structure is used as an argument to the select-handler called
 * within the 'do_locate' method for this class
 */

struct locate_selhndlr_args
  {
  unsigned short param_types;
  };

extern GRclassid OPP_GRvg_class_id, OPP_EMSassoc_class_id;

from EMSassoc import EMdisplay_geomparam, EMlocate_geomparam;
from EMSparameter import EMgetdimgeom;
from EMSparamgm import EMdisplay, EMgetgeom;
from GRvg import GRgetsymb;

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
  rtree_classes->p_classes[0] = OPP_GRvg_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_EMSassoc_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = EC_LOC_NOFLEXGROUPS;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}

method locate_param (IGRlong *msg; IGRushort op_type;
                     IGRushort param_types;
                     enum EMSuser_responses *useract;
                     IGRint *response; IGRchar *response_data;
                     struct GRid *paramobj; struct GRevent *paramevent)
{
  IGRboolean stat_func;
  IGRshort mattyp;
  IGRint num_geom_params;
  IGRlong msg_loc, stat_OM;
  IGRdouble *mat, dumpar, lnpar, *dptr;
  IGRpoint blinept1, blinept2, dumpt1, dumpt2;
  struct locate_selhndlr_args selargs;
  struct IGRline bline;
  struct GRlc_info *elem, *p_lcinfo;
  struct EMSgeomdata pargeom_data;
  struct GRmd_env *p_mdenv, *elem_md_env;
  GRobjid *geom_params, buff[NUM_STATIC_GEOMPARMS], win_oid;
  IGRboolean EMpselect(), EFboreline();
  OMuword win_os;

  char element_type[1024], message_string[1024], tmp_buff[1024];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  geom_params = NULL;

  selargs.param_types = param_types & ~(EMSparam_grid | EMSparam_value);
  stat_OM = om$send (msg = message ECelements.set_hndlr_funcs (&msg_loc,
             NULL, NULL, EMpselect, (IGRchar *) &selargs), targetid = my_id);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  /*
   * Locate the parametric element and obtain an accept point near
   * the parameter object to be located.
   */

  ME.ECelements->owner_action |= LC_BOTTOM_UP | LC_ASSOCIATIVE |
                                 LC_HANDLES |
                                  LC_STOP_ON_ASSOC | LC_INTERMIDIATE |
                                  LC_EXTERN_CONSTRAINED;

  /* get messages from ums */

  ex$message(msgnumb = EMS_P_ParamEle, buff = element_type);
  ex$message(msgnumb = EMS_P_PtNrParam, buff = tmp_buff);
  strcpy(message_string," ");
  strcat(message_string,tmp_buff);

  stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc, useract,
             response, response_data, element_type, NULL, NULL,
             message_string, NULL, NULL),
             targetid = my_id);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  if (*useract != EMSuser_data)
    {
    paramobj->objid = NULL_OBJID;
    goto ret_end;
    }
  
  bline.point1 = blinept1;
  bline.point2 = blinept2;

  elem = ME.ECelements->elems;
  elem_md_env = &elem->module_info;
  mattyp = elem_md_env->md_env.matrix_type;
  mat = elem_md_env->md_env.matrix;

  /*
   * Construct the bore-line using the info in the data-point
   * event.
   */

  stat_func = EFboreline (&msg_loc, my_id, &ME.ECelements->accev, &bline);
  EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail,
   ret_end);
  
  /*
   * Using this boreline obtain the parameters sorted by minimum distance.
   * from boreline to the parameter.
   */

  stat_OM = om$send (msg = message EMSassoc.EMlocate_geomparam (&msg_loc, NULL,
             &mattyp, mat, param_types, &bline, NUM_STATIC_GEOMPARMS, buff,
             &num_geom_params, &geom_params),
             targetid = elem->located_obj.objid,
             targetos = elem->located_obj.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (!num_geom_params, *msg, EMS_E_InvalidCase, ret_end);

  /*
   * Pick the first one out of the list. This will be the one closest
   * to the boreline. Format it into the output.
   */
  ex$get_cur_mod (id = &win_oid, osnum = &win_os);
  dp$erase_hilite (msg = &msg_loc, objid = win_oid, osnum = win_os);

  paramobj->objid = *geom_params;
  paramobj->osnum = elem->located_obj.osnum;

  *paramevent = ME.ECelements->accev;
  p_lcinfo = paramevent->located_object;
  p_lcinfo->located_obj = *paramobj;
  p_lcinfo->geom_parms.leaf_id.objid = NULL_OBJID;
  p_mdenv = &p_lcinfo->module_info;
  p_mdenv->md_id = elem_md_env->md_id;
  p_mdenv->md_env.matrix_type = elem_md_env->md_env.matrix_type;
  OM_BLOCK_MOVE (elem_md_env->md_env.matrix, p_mdenv->md_env.matrix,
   sizeof (IGRmatrix));
  paramevent->num_id = 1;

  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             &mattyp, mat, &pargeom_data), targetid = paramobj->objid,
             targetos = paramobj->osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (pargeom_data.geomtype == GEOMDATA_POINT)
    {
    OM_BLOCK_MOVE (pargeom_data.point, &paramevent->event.button.x,
     sizeof (IGRpoint));
    paramevent->subtype = GRst_KEYPOINT;
    }
  else if (pargeom_data.geomtype == GEOMDATA_VECTOR)
    {
    stat_OM = om$send (msg = message EMSparamgm.EMgetdimgeom (&msg_loc, NULL,
               &mattyp, mat, NULL, NULL, &pargeom_data, NULL),
               targetid = paramobj->objid, targetos = paramobj->osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    
    MA2lnproj (&msg_loc, &bline, &pargeom_data.line.igr_line, dumpt1, dumpt2,
     &dumpar, &lnpar); 
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (lnpar > 0.5)
      dptr = pargeom_data.line.line_pt1;
    else
      dptr = pargeom_data.line.line_pt2;
    OM_BLOCK_MOVE (dptr, &paramevent->event.button.x, sizeof (IGRpoint));
    paramevent->subtype = GRst_KEYPOINT;
    }
  paramevent->response = EX_DATA;

ret_end:
  if (geom_params && geom_params != buff)
    om$dealloc (ptr = geom_params);

  EMWRAPUP (*msg, stat_OM, "EMlocparam.locate_param");
  return (stat_OM);
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRushort param_type;
  IGRlong putquesize;
  IGRint mytype;
  IGRlong msg_loc, stat_OM;
  struct GRid paramobj;
  struct GRevent param_event;
  enum EMSuser_responses useract;

  stat_OM = OM_S_SUCCESS;

  mytype = ME.super_cmd->mytype;
  if (mytype == POINTPARAM_CMD)
    {
    param_type = EMSparam_point;
    ex$message (msgnumb = EM_M_PointParameter);
    }
  else if (mytype == VECTORPARAM_CMD)
    {
    param_type = EMSparam_vector;
    ex$message (msgnumb = EM_M_AxisParameter);
    }
  else
    {
    param_type = EMSparam_plane;
    ex$message (msgnumb = EM_M_PlaneParameter);
    ex$message (msgnumb = EMS_S_NotYetSupported);
    *response = TERMINATE;
    sleep (2);
    goto ret_end;
    }

  stat_OM = om$send (msg = message EClocparam.locate_param (&msg_loc, NULL,
             param_type, &useract, response, response_data,
             &paramobj, &param_event), targetid = my_id);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), stat_OM, OM_E_ABORT, ret_end);

  if (useract == EMSuser_data)
    {
    putquesize = sizeof (struct GRevent);
    stat_OM = ex$putque (msg = &msg_loc, response = &param_event.response,
               byte = &putquesize, buffer = (IGRchar *)&param_event.event);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

    *response = TERMINATE;
    }

ret_end:
  if (EMSerror (stat_OM))
  {
    ex$message (msgnumb = EMS_S_ErrorInCommand);
    sleep (2);
    *response = TERMINATE;
  }
  return (stat_OM);
}



/*
  DESCRIPTION

    This is the select-handler used while locating geometric parameters
    of a given parametric entity. It goes through the accept/reject cycle,
    displaying the entities specially.

  RETURN VALUE

    0 - error or no objects accepted
    1 - objects accepted or in stack

    return code (msg)
     see lcdef.h for values
     LC_NO_OBJ_LOCATED
     LC_OBJ_LOCATED
     LC_OBJS_IN_STACK
     LC_RELOCATE
     LC_UNKNOWN_TYPE
     LC_BACKUP             

  HISTORY
  
    SS  :  03/26/91  :  Creation. Basis is LCselect/LCdisplay
*/

IGRboolean EMpselect (msg, selargs, userargs)
IGRlong *msg;
struct LC_select_args *selargs;
struct locate_selhndlr_args *userargs;
{
  IGRboolean process, stat_func, reject_object, stat_located;
  IGRchar info[GR_MAX_CHAR];
  IGRshort mattyp;
  IGRint i, num_win;
  IGRlong msg_loc, stat_OM, mask, display_flag;
  IGRdouble *mat;
  GRobjid loc_obj;
  GRspacenum loc_osnum;
  struct GRid *locate_win_id, *file_mod_id, win_ids[MAX_WINDOW];
  struct GRevent *accept_event, *accept_event1;
  struct GRlc_stack *stack; 
  struct GRlc_info *entry;
  struct GRmdenv_info *entry_md;
  OMuword win_os;
  OM_S_OBJID win_oid;

  *msg = LC_NO_OBJ_LOCATED;
  stat_located = FALSE;

  stack = selargs->stack;
  locate_win_id = &stack->window;
  file_mod_id = &stack->module;

  /*
   * For each of the entries in the stack, perform the following process.
   * There is usually just one entry.
   */

  process = TRUE;
  while (process && stack->num_entries)
    {
    entry = &stack->entry[stack->num_entries-1];
    loc_obj = entry->located_obj.objid;
    loc_osnum = entry->located_obj.osnum;

    /*
     * Display the object information in the status field using the
     * message system.
     */

     LCget_info (loc_obj, loc_osnum, info);
     ex$message (msgnumb = LC_NO_MSG, in_buff = info, field = ERROR_FIELD);
     ex$message (msgnumb = selargs->acc_key, in_buff = selargs->acc_prompt,
      field = PROMPT_FIELD, justification = RIGHT_JUS);

    /*
     * The highlight of the element is always done specially, through the 
     * message EMSassoc.EMdisplay_geomparam. If all the windows in the
     * module are to be displayed, then take care to see that the
     * display is first done in the window where the locate was performed.
     * If no parameters were displayable, then this object is not eligible.
     * In this case, behave as if this was a reject.
     */

    dp$get_gragad_id (msg = &msg_loc, mod_GRid = file_mod_id,
     type_gragad = ALL_GG_CLASSES | ACTIVE_GG | NO_DELAY_GG,
     name = "*", array_size = MAX_WINDOW, 
     numberofids = &num_win, found_GRids = win_ids);

    for (i=0; i<num_win; i++)
      {
      if (win_ids[i].objid == locate_win_id->objid &&
          win_ids[i].osnum == locate_win_id->osnum)
        {
        win_ids[i] = win_ids[0];
        win_ids[0] = *locate_win_id;
        break;
        }
      }

    entry_md = &entry->module_info.md_env;
    mattyp = entry_md->matrix_type;
    mat = entry_md->matrix;

    reject_object = FALSE;
    for (i=0; i<num_win; i++)
      {
      stat_OM = om$send (msg = message EMSassoc.EMdisplay_geomparam
                 (&msg_loc, NULL, &mattyp, mat, userargs->param_types,
                 &win_ids[i]), targetid = loc_obj, targetos = loc_osnum,
                 senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, LC_NO_OBJ_LOCATED,
       ret_end);
      if (msg_loc == EMS_I_NotFound)
        {
        reject_object = TRUE;
        break;
        }
      }
    if (reject_object)
      {
      /*
       * The current element is rejected; continue to process
       * the remaining elements in the stack.  If there are no
       * elements left in the stack, return control to the
       * main locate filter to either continue the search through
       * the Rtree or return control to the caller of the filter.
       */

      if (!--stack->num_entries)
        {
        *msg = LC_RELOCATE;
        stat_located = TRUE;
        }
      continue;
      }

    /*
     * Add reset and backup to the valid responses in the mask to
     * ems$getevent.  These two responses will not accept the element
     * because they are directly interpreted by this function.
     */

    mask = selargs->eventmask | GRm_RESET | GRm_BACK_UP;

    /*
     * Modify the cursor if the command requests it.  This is usually
     * for commands that do a chain locate.
     */

    display_flag = selargs->display_flag;
    if (display_flag & LC_ACCEPT_CURSOR) 
      LCdef_cursor ();

    /*
     * Wait for the user's response
     */

    LCmark_locate (LC_Other_Point);

    accept_event = selargs->accept_event;
    ems$getevent (msg = &msg_loc, event_mask = mask, 
     value_type = selargs->value_type, scale_flag = selargs->scale_flag,
     response = (IGRlong *)selargs->response, response_data = selargs->response_data,
     event = accept_event);

    /*
     * Restore the cursor if necessary.
     */

    if (display_flag & LC_ACCEPT_CURSOR) 
      LCrestore_cursor();    

    /*
     * Process the user's response
     */

    switch (accept_event->response) 
      {
      case EX_BACK_UP:
        /*
         * Leave the accept/reject cycle, set up the return codes
         * to exit the Rtree search, and return to the main filter.
         * The filter may then reenter the locate cycle or return
         * to the caller, depending on the original locate request.
         */

        stack->num_entries = 0;
        *msg = LC_BACKUP;
        process = FALSE;
        break;

      case EX_RJT_MOVEON:
        /*
         * The current element is rejected; continue to process
         * the remaining elements in the stack.  If there are no
         * elements left in the stack, return control to the
         * main locate filter to either continue the search through
         * the Rtree or return control to the caller of the filter.
         */

        if (!--stack->num_entries) 
          {
          ex$get_cur_mod (id = &win_oid, osnum = &win_os);
          dp$erase_hilite (msg = msg, objid = win_oid, osnum = win_os);
          *msg = LC_RELOCATE;
          stat_located = TRUE;
          }
        break;
         
      case GR_UNKNOWN_TYPE:
        /*
         * Unknown input type; return control to the caller
         */

        ex$get_cur_mod (id = &win_oid, osnum = &win_os);
        dp$erase_hilite (msg = msg, objid = win_oid, osnum = win_os);
        *msg = LC_UNKNOWN_TYPE;
        process = FALSE;
        break;

      default:
        /*
         * Accept the object with any recognized input type
         */

        if (accept_event->response == DATA) 
          {
          /*
           * Check to see if projection of accept point is
           * requested.  If the third bit is not set in the
           * display flag project the accept point onto the
           * element using a point or boreline project
           * depending on the type of locate that is occuring
           */

          if (! (display_flag & NO_PROJ_ACCEPT_POINT)) 
            {
            stat_func = LCget_parms (accept_event->event.button.x,
                         accept_event->event.button.y,
                         accept_event->event.button.z, 
                         *selargs->is_bore ? LC_LNPROJECT : LC_PTPROJECT,
                         loc_obj, loc_osnum,
                         accept_event->event.button.objid,
                         accept_event->event.button.osnum,
                         entry->proj_pnt, &entry->geom_parms,
                         mattyp, mat);
            EMerr_hndlr (!stat_func, *msg, LC_NO_OBJ_LOCATED, ret_end);
            }
          }

        /*
         * Set up the return codes to indicate that the object
         * was accepted.  Note that acc_event1 is being filled in
         * rather than acc_event.
         */

        *msg = LC_OBJ_LOCATED;
        stat_located = TRUE;
        process = FALSE;
        accept_event1 = selargs->acc_event1;
        accept_event1->located_object[0] = *entry;
        accept_event1->num_id = 1;
        stack->num_entries = 0;
        break;
      }
    }

ret_end:
  return (stat_located);
}

end implementation EClocparam;
