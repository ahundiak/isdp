/*
  ALGORITHM

    Obtain the Boolean operation type. Obtain the current operands to
    this operation. If this node is a save-side, one of the operands is
    a plane that was generated by this node. In this case, copy the plane
    and make it "natural". Substitute this plane as the operand for
    subsequent processing. Now undo-delete this node. Send this same message
    to any of the operands that happen to be Booleans and substitute the
    new-ids returned for the operands. Perform the Boolean operation again
    creating a new node. This new node is returned as the "new-id" from
    this method.

    The "depth" counter is used as an alternate means to stop the descent
    of this method down the tree. If the depth is zero, no more action
    takes place.

    Optionally, this method can perform in a test-incremental Boolean mode. In
    this mode, the method undoes one level, then re-does the operation and
    immediately undoes the operation. In the final result the entire
    tree has been broken up into it's primitives. Each Booelan stage 
    having been tested from top-down.

  HISTORY

    SS  :  11/02/92  :  Creation
*/

class implementation EMSsfboolean;

#include <stdio.h>
#include "OMmacros.h"
#include "exdef.h"
#include "ex.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdp.h"
#include "dpmacros.h"
#include "EMS_I.h"
#include "msdef.h"
#include "emssfintdef.h"
#include "emsdebug.h"
#include "proto/EMkeybdio.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/grdisp.h"
#include "PWapi/sfchksliver.h"

#define FIRST  0
#define SECOND 1

#define CHT  0
#define BAS  1

#define NUM_CHKPTS 5

extern GRclassid OPP_EMSsolid_class_id, OPP_EMSslboolean_class_id;
extern GRclassid OPP_EMSslmacro_class_id;

extern short _Pathway, _pathway_trim, _pathway_orient;

static IGRboolean is_boolean_node (obj, op, type)
GRobjid obj;
IGRuchar op;
enum EMSbooltype *type;
{
  IGRboolean stat_func = FALSE;
  IGRlong msg_loc;
  GRclassid classid;
  enum EMSbooltype general_type, exact_type;

  om$get_classid (objid = obj, p_classid = &classid);
  if (classid == OPP_EMSsfboolean_class_id ||
      classid == OPP_EMSslboolean_class_id)
    {
    general_type = exact_type = EMSbool_nullNullU;
    om$send (msg = message EMSsfboolean.EMget_operation_type
     (&msg_loc, NULL, &exact_type, &general_type, NULL, NULL,
     NULL, NULL, NULL, NULL, NULL, NULL), targetid = obj, 
     senderid = NULL_OBJID);

    if (!(op & DISJ_DUE_TO_RETRY))
      general_type = exact_type;
    else if (exact_type == EMSbool_saveside)
      general_type = EMSbool_saveside;

    if (general_type == EMSbool_union ||
        general_type == EMSbool_difference ||
        general_type == EMSbool_intersect ||
        general_type == EMSbool_saveside)
      {
      if (type)
        *type = general_type;
      stat_func = TRUE;
      }
    }
  return (stat_func);
}

static IGRboolean getnewtol (cht, bastol)
IGRdouble *cht, *bastol;
{
  IGRboolean stat_func=FALSE;
  IGRchar str[GR_MAX_CHAR], tolstr[10];
  IGRint i;
  IGRdouble tol[2], newtol;

  UI_status ("Change tolerances");
  tol[CHT] = *cht;
  tol[BAS] = *bastol;
  for (i=CHT; i<=BAS; i++)
    {
    if (i == CHT)
      strcpy (tolstr, "Cht-tol");
    else
      strcpy (tolstr, "Bas-tol");
    sprintf (str, "Temp chg %s (Current=%7.12lf) / Move-on", tolstr, tol[i]);

    newtol = EMgetdouble (str, NULL, TRUE, tol[i]);
    if (newtol == tol[i])
      continue;
    else
      {
      tol[i] = newtol;
      stat_func = TRUE;
      }
    }
  *cht = tol[CHT];
  *bastol = tol[BAS];
  return (stat_func);
}

static IGRboolean f_override_pathway_chk (dpr)
GRobjid dpr;
{
  IGRboolean stat_func=FALSE;
  IGRchar resp;
  IGRushort dpr_props=NULL;
  IGRlong msg_loc;

  om$send (msg = message EMSdpr.EMget_dpr_props (&msg_loc, &dpr_props),
   targetid = dpr, senderid = NULL_OBJID);
  if (! (dpr_props & EMS_POST310_OBJECT))
  {
    resp = EMgetchar ("Use Pathway to redo Boolean y/[n]", 
            "Existing Boolean not using Pathway", TRUE, 'n');
    if (toupper (resp) == 'Y')
      stat_func = TRUE;
  }

  return (stat_func);
}

static void movelevel (type, num_comps, comps)
enum EMSbooltype type;
int num_comps;
GRobjid *comps;
{
  IGRchar op[20], str[128];
  IGRshort newlevel;
  IGRint i;
  IGRlong msg_loc;

  if (type == EMSbool_union)
    strcpy (op, "Union");
  else if (type == EMSbool_difference)
    strcpy (op, "Difference");
  else if (type == EMSbool_intersect)
    strcpy (op, "Intersection");
  else if (type == EMSbool_saveside)
    strcpy (op, "Save-side");
  else
    strcpy (op, "Unknown op");
  sprintf (str, "%s: Move operands to new level", op);

  for (i=0; i<num_comps; i++)
  {
    pwDisplayObj (comps[i], OS, FALSE, TRUE);
    newlevel = EMgetint ("Input new level for operand to change to [1023]",
                str, TRUE, 1023);
    dp$erase_hilite (msg = &msg_loc);

    om$send (msg = message GRvg.GRchglevel (&msg_loc, &newlevel),
     targetid = comps[i], senderid = NULL_OBJID);
  }

  return;
}

static GRobjid newbool (msg, dpr, mattyp, mat, num_comps, comp_objs,
                        type, cht, bastol, override_pathway_chk, str)
IGRlong *msg;
GRobjid dpr;
IGRshort *mattyp;
IGRmatrix mat;
IGRint num_comps;
GRobjid *comp_objs;
enum EMSbooltype type;
IGRdouble cht, bastol;
IGRboolean override_pathway_chk;
IGRchar *str;
{
  IGRboolean special_saveside, save_pw, save_pw_trim, save_pw_orient;
  IGRboolean action;
  IGRushort loc_options, dpr_props=NULL;
  IGRlong msg_loc, bs_msg, bool_msg, stat_func;
  IGRdouble save_cht, save_bastol;
  GRobjid newdpr;
  GRclassid classid;
  struct GRmd_env loc_md_env;
  struct IGRdisplay loc_disp;
  struct GRvg_construct const_args;

  *msg = EMS_S_Success;

  EMgetmdenv (&loc_md_env, mattyp, mat, OM_Gw_current_OS);
  EMinitvgcnstr (&msg_loc, &loc_md_env, &loc_disp, NULL, &const_args);
  EMgetvgcnstr (NULL, NULL, &loc_md_env, DEFAULT_GR_LEVEL, NULL, NULL,
   NULL, &const_args);

  om$get_classid (objid = dpr, p_classid = &classid);
  newdpr = NULL_OBJID;
  om$construct (classid = classid, p_objid = &newdpr);
  EMerr_hndlr (IF_NULL_OBJID (newdpr), *msg, EMS_E_OMerror, ret_end);

  save_pw = _Pathway;  
  save_pw_trim = _pathway_trim;  
  save_pw_orient = _pathway_orient;  

  om$send (msg = message EMSdpr.EMget_dpr_props (&msg_loc, &dpr_props),
   targetid = dpr, senderid = NULL_OBJID);
  if (dpr_props & EMS_POST310_OBJECT || override_pathway_chk)
  {
    _Pathway = TRUE;
    _pathway_trim = TRUE;
    _pathway_orient = TRUE;
  }
  else
  {
    _Pathway = FALSE;
    _pathway_trim = FALSE;
    _pathway_orient = FALSE;
  }

  if (type == EMSbool_saveside &&
      om$is_ancestry_valid (subclassid = classid,
       superclassid = OPP_EMSsolid_class_id) != OM_S_SUCCESS)
    special_saveside = TRUE;
  else
    special_saveside = FALSE;
  loc_options = EMSsfbool_opt_display | EMSsfbool_opt_retryDisjoint |
                 EMSsfbool_opt_HandleStop | 
                 (special_saveside ? (EMSsfbool_opt_OpenIntPossible |
                                      EMSsfbool_opt_SingleTopology) : NULL);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, save_cht);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, save_bastol);
  BSchangepar (&bs_msg, BSTOLCHRDHT, cht);
  BSchangepar (&bs_msg, BSTOLLENVEC, bastol);
  om$send (msg = message EMSsfboolean.EMboolean (&bool_msg,
   mattyp, mat, comp_objs[FIRST], num_comps-1, &comp_objs[SECOND],
   &const_args, type, loc_options, str, NULL, NULL,
   NULL, NULL), targetid = newdpr, senderid = NULL_OBJID);
  BSchangepar (&bs_msg, BSTOLCHRDHT, save_cht);
  BSchangepar (&bs_msg, BSTOLLENVEC, save_bastol);

  if (_Pathway)
  {
    action = TRUE;
    dpr_props = EMS_POST310_OBJECT;
    om$send (msg = message EMSdpr.EMsetprops (&msg_loc, &action, &dpr_props),
     targetid = newdpr, senderid = NULL_OBJID);
  }

  _Pathway = save_pw;  
  _pathway_trim = save_pw_trim;  
  _pathway_orient = save_pw_orient;  

  EMerr_hndlr (EMSerror (bool_msg), *msg, EMS_E_Fail, ret_end);

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "newbool");
  return (newdpr);  
}


static void printer (olddpr, newdpr, num_comps, comp_obj_links, comp_objs,
                     type, level, file)
GRobjid olddpr, newdpr, *comp_objs;
IGRint num_comps;
OM_p_OBJECT_LINKAGE comp_obj_links;
enum EMSbooltype type;
FILE *file;
{
  IGRchar classname[OM_K_MAXCLASS_LEN+1];
  IGRint i;
  GRclassid classid;

  if (file)
    printer (olddpr, newdpr, num_comps, comp_obj_links, comp_objs, type, 
     level, (FILE *) NULL);
  else
    file = stderr;

  fprintf (file, "Level %d:  ", level);
  fprintf (file, "(%d) ", olddpr);
  fprintf (file, "%s ", 
   (type == EMSbool_union ? "Union" :
    (type == EMSbool_difference ? "Difference" :
     (type == EMSbool_intersect ? "Intersection" : 
      (type == EMSbool_saveside ? "Save-side" : "Weird")))));
  if (!IF_NULL_OBJID (newdpr))
    fprintf (file, "%d = ", newdpr);
  else
    fprintf (file, "= ");

  for (i=0; i<num_comps; i++)
    {
    fprintf (file, "(%d)", comp_obj_links[i].S_objid);

    if (!is_boolean_node (comp_objs[i], NULL, (enum EMSbooltype *) NULL))
      {
      om$get_classid (objid = comp_objs[i], p_classid = &classid);
      om$get_classname (classid = classid, classname = classname);
      fprintf (file, " %s", classname);
      }
    else if (!IF_NULL_OBJID (newdpr) && 
             comp_objs[i] != comp_obj_links[i].S_objid)
      fprintf (file, " %d", comp_objs[i]);

    if (i <= num_comps-2)
      fprintf (file, ", ");
    }
  fprintf (file, "\n");

  return;
}


IGRint EMremove_slmacro (treeid, os)
GRobjid *treeid;
GRspacenum os;
{
  GRobjid local_treeid;
  GRclassid classid;
  IGRuint count, num_comps, comp_inx;
  IGRint i, num_removed;
  IGRlong msg_loc, inx;
  struct GRid tmpid;
  OM_S_OBJECT_LINKAGE ownerobj, *compobjs=NULL;
  OM_S_CHANSELECT chan_to_comps, chan_to_owner;

  local_treeid = *treeid;
  num_removed = 0;

  om$get_classid (objid = local_treeid, osnum = os, p_classid = &classid);
  if (om$is_ancestry_valid (subclassid = classid, 
       superclassid = OPP_EMSdpr_class_id) == OM_S_SUCCESS)
    {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    om$get_channel_count (objid = *treeid, osnum = os, 
     p_chanselect = &chan_to_comps, count = &num_comps);
    if (num_comps)
      {
      compobjs = (OM_p_OBJECT_LINKAGE) alloca (num_comps * 
                  sizeof (OM_S_OBJECT_LINKAGE));
      om$get_channel_objects (objid = *treeid, osnum = os,
       p_chanselect = &chan_to_comps, list = compobjs, size = num_comps,
       count = &num_comps);
      }

    if (om$is_ancestry_valid (subclassid = classid, 
         superclassid = OPP_EMSslmacro_class_id) == OM_S_SUCCESS)
      {
      EMmake_chanselect (GRconnector_to_owners, &chan_to_owner);
      ownerobj.S_objid = NULL_OBJID;
      om$get_channel_objects (objid = *treeid, osnum = os, 
       p_chanselect = &chan_to_owner, list = &ownerobj, size = 1, 
       count = &count);

      tmpid.objid = *treeid;
      tmpid.osnum = os;
      for (i=0; i<num_comps; i++)
        om$send (msg = message GRconnector.GRdisconn (&msg_loc, &tmpid),
        targetid = compobjs[i].S_objid, targetos = os, senderid = NULL_OBJID);

      if (ownerobj.S_objid != NULL_OBJID)
        {
        om$get_index (osnum_c = os, objid_c = ownerobj.S_objid,
         p_chanselect = &chan_to_comps, objid = *treeid, osnum2 = os,
         indexaddr = &comp_inx);

        tmpid.objid = ownerobj.S_objid;
        tmpid.osnum = os;
        om$send (msg = message GRconnector.GRdisconn (&msg_loc, &tmpid),
         targetid = *treeid, targetos = os, senderid = NULL_OBJID);     
        }

      om$send (msg = message Root.delete (TRUE), 
       targetid = *treeid, targetos = os, senderid = NULL_OBJID);
      num_removed++;

      if (ownerobj.S_objid != NULL_OBJID)
        {
        tmpid.objid = ownerobj.S_objid;
        tmpid.osnum = os;
        for (i=FIRST; i<num_comps; i++)
          {
          inx = comp_inx + i;
          om$send (msg = message GRconnector.GRrigidconn (&msg_loc, &tmpid,
           &inx), targetid = compobjs[i].S_objid, targetos = os, 
           senderid = NULL_OBJID);
          }
        local_treeid = ownerobj.S_objid;
        }
      else
        local_treeid = compobjs[FIRST].S_objid;
        
      }

    for (i=0; i<num_comps; i++)
      num_removed += EMremove_slmacro (&compobjs[i].S_objid, os);
    }

  *treeid = local_treeid;
  return (num_removed);
}


method EMredobooltree (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                       IGRushort options; IGRint depth; GRobjid *my_new_id;
                       FILE *outfile)

{
  IGRboolean debug, noop, incremental, debug_display, undo, prompt;
  IGRboolean asknewtol_onerror, override_pathway_chk, newtol_specified;
  IGRchar status_str[GR_MAX_CHAR];
  IGRushort loc_options;
  IGRuint num_comps;
  IGRint i, level, num, display_count, invoke_count, buff_size, response;
  IGRlong msg_loc, stat_OM;
  IGRdouble response_data[128];
  IGRdouble cht, loc_cht, bastol, loc_bastol;
  GRobjid *display_ids, *comp_objs;
  struct GRid *old_id;
  struct GRmd_env loc_md_env;
  struct GRsymbology tree_symb, symb;
  struct GRevent event;
  struct IGRdisplay loc_disp;
  enum EMSbooltype general_type;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT chan_to_comps, chan_to_loopset;
  OM_p_OBJECT_LINKAGE comp_obj_links;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  debug = options & EMS_O_Debug;
  noop = options & EMS_O_Noop;
  incremental = options & EMS_O_Incremental;
  debug_display = options & EMS_O_Display;
  undo = options & EMS_O_Undo;
  asknewtol_onerror = options & EMS_O_Retry;
  num_comps = 0;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);

  /*
   * Determine if the depth counter suggests that we can go further down
   * the Boolean tree. If not, return.
   */
 
  if (!depth)
    {
    *msg = EMS_I_Useless;
    *my_new_id = my_id;
    goto ret_end;
    }
  else
    depth--;
  
  /*
   * Determine the operation type. If this is not a "valid" Boolean node,
   * exit.
   */

  if (!is_boolean_node (my_id, ME.EMSsfboolean->operation, &general_type))
    {
    *msg = EMS_I_Useless;
    *my_new_id = my_id;
    goto ret_end;
    }

  /*
   * Obtain the current operands involved in the operation. If this
   * is an intersect plane save-side, make a copy of the plane and retain
   * it (since this is going to be deleted by the undo). Number of components
   * in this static case must atleast be 1 or more.
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
   count = &num_comps);
  EMerr_hndlr (!noop && !num_comps, *msg, EMS_E_InvalidCase, ret_end);

  comp_obj_links = (OM_p_OBJECT_LINKAGE) alloca (num_comps *
                    sizeof (OM_S_OBJECT_LINKAGE));
  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
   size = num_comps, count = &num_comps, list = comp_obj_links);
  comp_objs = (GRobjid *) alloca (num_comps * sizeof (GRobjid));
  for (i=0; i<num_comps; i++)
    comp_objs[i] = comp_obj_links[i].S_objid;

  if (!noop)
    {
    EMgetmdenv (&loc_md_env, mattyp, mat, OM_Gw_current_OS);
    if (general_type == EMSbool_saveside)
      {
      om$send (msg = message GRgraphics.GRcopy (&msg_loc, &loc_md_env,
       &loc_md_env, &comp_objs[SECOND]), targetid = comp_objs[SECOND]);
      om$send (msg = message EMSsurface.EMrevorient (&msg_loc),
       targetid = comp_objs[SECOND]);

      EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
      om$send (msg = message Root.delete (FALSE),
       p_chanselect = &chan_to_loopset, senderid = comp_objs[SECOND]);
      om$send (msg = message EMSsurface.EMmk_nat_bdry (&msg_loc,
       &loc_md_env.md_env, NULL), targetid = comp_objs[SECOND]);

      comp_obj_links[SECOND].S_objid = comp_objs[SECOND];
      }
    }

  /*
   * Undo this node. Before that obtain the depth of this tree for
   * statistics purposes. Also, obtain the symbology of the tree.
   */

  level = -1;
  om$send (msg = message EMSsfboolean.EMgettreedepth (&msg_loc, 0, &level),
   targetid = my_id);
  om$send (msg = message GRvg.GRgetsymb (&msg_loc, &tree_symb),
   targetid = my_id);
   
  if (!noop)
    {
    loc_options = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
    old_id = NULL;
    num = 0;
    buff_size = 0;
    display_ids = NULL;
    display_count = 0;
    invoke_count = 0;
    stat_OM = om$send (msg = message EMSdpr.EMundo (&msg_loc,
               &loc_options, &loc_md_env, &old_id,
               &num, &buff_size, &display_ids, &display_count, &invoke_count),
               targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * If the test-incremental redo is set then, perform the Boolean operation
   * immediately. Soon after that undo the Boolean that was just performed.
   */

  if (!noop && (incremental || undo))
    {
    if (debug)
      printer (my_id, NULL_OBJID, num_comps, comp_obj_links, comp_objs, 
       general_type, level, outfile);

    if (debug_display)
      {
      dpmode = GRbd;
      for (i=0; i<num_comps; i++)
        {
        om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
         targetid = comp_objs[i]);
        if (i)
          symb.display_attr.color += 2;
        else
          symb.display_attr.color += 1;
        om$send (msg = message GRvg.GRputsymb (&msg_loc, &symb),
         targetid = comp_objs[i]);
        om$send (msg = message GRgraphics.GRdisplay (&msg_loc, mattyp,
         mat, &dpmode, &loc_md_env.md_id), targetid = comp_objs[i]);
        }
    
      prompt = TRUE;
      while (prompt)
        {
        UI_prompt ("(Q)uit breaking / [C]ontinue");
        co$getevent (msg = &msg_loc, event_mask = 
         GRm_TEXT_VALUE | GRm_RJT_MOVEON, response = &response,
         response_data = response_data, event = &event);
        UI_prompt ("");
        if (msg_loc == GRw_no_value || event.response == EX_RJT_MOVEON ||
            (event.response == EX_STRING && 
             toupper (event.event.keyin[0]) == 'C'))
          prompt = FALSE;
        else if (event.response == EX_STRING && 
                 toupper (event.event.keyin[0]) == 'Q')
          {
          options &= ~EMS_O_Display;
          prompt = FALSE;
          }
        }
      }

    if (incremental)
      {
      loc_bastol = bastol;
      loc_cht = cht;
      newtol_specified = FALSE;
      override_pathway_chk = FALSE;
      do 
        {
        ex$message (msgnumb = EMS_I_Processing, buff = status_str);
        strcat (status_str, " - Incremental");
        msg_loc = EMS_S_Success;
        *my_new_id = newbool (&msg_loc, my_id, mattyp, mat, num_comps, 
                      comp_objs, general_type, loc_cht, loc_bastol, 
                      override_pathway_chk,
                      status_str);

        newtol_specified = FALSE;
        override_pathway_chk = FALSE;
        if (EMSerror (msg_loc))
          {
          if (asknewtol_onerror)
            newtol_specified = getnewtol (&loc_cht, &loc_bastol);
          override_pathway_chk = f_override_pathway_chk (my_id);
          }
        }
      while (newtol_specified || override_pathway_chk);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      if (debug)
        {
        if (pwGetSliverSfs (*my_new_id, OS, *mattyp, mat, cht, NUM_CHKPTS, 
             NULL))
          {
          UI_status ("Sliver topology produced");
          fprintf (stderr, "Sliver topology produced\n");
          if (outfile)
            fprintf (outfile, "Sliver topology produced\n");
          }
        }
      }

    if (debug_display)
      {
      om$send (msg = message GRvg.GRputsymb (&msg_loc, &tree_symb),
       targetid = *my_new_id);
      dpmode = GRbd;
      om$send (msg = message GRgraphics.GRdisplay (&msg_loc, mattyp,
       mat, &dpmode, &loc_md_env.md_id), targetid = *my_new_id);
      }

    if (incremental)
      {
      loc_options = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
      old_id = NULL;
      num = 0;
      buff_size = 0;
      display_ids = NULL;
      display_count = 0;
      invoke_count = 0;
      stat_OM = om$send (msg = message EMSdpr.EMundo (&msg_loc,
                 &loc_options, &loc_md_env, &old_id,
                 &num, &buff_size, &display_ids, &display_count, 
                 &invoke_count), targetid = *my_new_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      *my_new_id = NULL_OBJID;
      }
    }

  /*
   * Send the operands this same redo-boolean-tree message (if they happen to
   * be Boolean nodes) thus obtaining their new-ids. If the operands are not
   * Boolean nodes then retain the current objects themselves. If this
   * is a call to simply output the tree, do so before recursing down. This
   * will cause the tree to print top-down. 
   */

  if (debug && noop)
    printer (my_id, NULL_OBJID, num_comps, comp_obj_links, comp_objs, 
     general_type, level, outfile);

  for (i=0; i<num_comps; i++)
    {
    if (om$is_objid_valid (objid = comp_obj_links[i].S_objid) == OM_S_SUCCESS)
      {
      if (is_boolean_node (comp_obj_links[i].S_objid, 
           NULL, (enum EMSbooltype *) NULL))
        {
        stat_OM = om$send (msg = message EMSsfboolean.EMredobooltree (&msg_loc,
                   mattyp, mat, options, depth, &comp_objs[i], outfile),
                   targetid = comp_obj_links[i].S_objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    }

  /*
   * Create a new Boolean DPR-node and perform the Boolean op. This node
   * becomes the output id. 
   */

  if (!noop && !incremental && !undo)
    {
    if (debug_display)
      {
      gr$get_active_display (buffer = &loc_disp);
      dpmode = GRbd;
      for (i=0; i<num_comps; i++)
        {
        om$send (msg = message GRvg.GRchgdp (&msg_loc, &loc_disp),
         targetid = comp_objs[i]);
        om$send (msg = message GRgraphics.GRdisplay (&msg_loc, mattyp,
         mat, &dpmode, &loc_md_env.md_id), targetid = comp_objs[i]);
        }
      }

    loc_bastol = bastol;
    loc_cht = cht;
    newtol_specified = FALSE;
    override_pathway_chk = FALSE;
    do 
      {
      ex$message (msgnumb = EMS_I_Processing, buff = status_str);
      msg_loc = EMS_S_Success;
      *my_new_id = newbool (&msg_loc, my_id, mattyp, mat, num_comps, 
                    comp_objs, general_type, loc_cht, loc_bastol, 
                    override_pathway_chk,
                    status_str);

      newtol_specified = FALSE;
      override_pathway_chk = FALSE;
      if (EMSerror (msg_loc))
        {
        if (asknewtol_onerror)
          newtol_specified = getnewtol (&loc_cht, &loc_bastol);
        override_pathway_chk = f_override_pathway_chk (my_id);
        }
      }
    while (newtol_specified || override_pathway_chk);

    if (EMSerror (msg_loc))
      movelevel (general_type, num_comps, comp_objs);

    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (debug)
      {
      printer (my_id, *my_new_id,
       num_comps, comp_obj_links, comp_objs, general_type, level, outfile);

      if (pwGetSliverSfs (*my_new_id, OS, *mattyp, mat, cht, NUM_CHKPTS, 
           NULL))
        {
        fprintf (stderr, "Sliver topology produced\n");
        if (outfile)
          fprintf (outfile, "Sliver topology produced\n");
        }
      }
    }

ret_end:
  if (EMSerror (*msg & stat_OM))
    fprintf (stderr, "EMredobool error - %d. Depth %d\n", my_id, depth);
  EMWRAPUP (*msg, stat_OM, "EMSsfboolean.EMredobooltree");
  return (stat_OM);
}



method EMgettreedepth (IGRlong *msg; IGRint relnum; IGRint *depth)
{
  IGRint i, loc_depth;
  IGRuint num_comps;
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_comps;
  OM_p_OBJECT_LINKAGE comp_obj_links;
  enum EMSbooltype exact_type, general_type;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message EMSsfboolean.EMget_operation_type
             (&msg_loc, NULL, &exact_type, &general_type, NULL, NULL,
             NULL, NULL, NULL, NULL, NULL, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (!(ME.EMSsfboolean->operation & DISJ_DUE_TO_RETRY))
    general_type = exact_type;
  else if (exact_type == EMSbool_saveside)
    general_type = EMSbool_saveside;

  if (general_type != EMSbool_union &&
      general_type != EMSbool_difference &&
      general_type != EMSbool_intersect &&
      general_type != EMSbool_saveside)
    {
    *depth = relnum;
    goto ret_end;
    }
  
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
   count = &num_comps);
  EMerr_hndlr (!num_comps, *msg, EMS_E_InvalidCase, ret_end);

  comp_obj_links = (OM_p_OBJECT_LINKAGE) alloca (num_comps *
                    sizeof (OM_S_OBJECT_LINKAGE));
  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
   size = num_comps, count = &num_comps, list = comp_obj_links);

  *depth = relnum + 1;
  relnum++;
  for (i=0; i<num_comps; i++)
    {
    if (is_boolean_node (comp_obj_links[i].S_objid, 
         NULL, (enum EMSbooltype *) NULL))
      {
      stat_OM = om$send (msg = message EMSsfboolean.EMgettreedepth (&msg_loc,
                 relnum, &loc_depth), targetid = comp_obj_links[i].S_objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      if (loc_depth > *depth)
        *depth = loc_depth;
      }
    }

ret_end:
  if (EMSerror (*msg & stat_OM))
    fprintf (stderr, "EMgettreedepth error - %d. Depth %d\n", my_id, *depth);
  EMWRAPUP (*msg, stat_OM, "EMSsfboolean.EMgettreedepth");
  return (stat_OM);
}

end implementation EMSsfboolean;
