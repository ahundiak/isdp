/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION
    
    This command locates a sequence of writable, orphan, curves (GRbspline)
    for manipulation of it's parameterization. The user manpulates 
    equi-parameter points on this sequence of curves in order to obtain
    a grid with desirable characteristics. The parameterization of the curves
    is adjusted to follow this grid pattern. Even a single curve can be
    manipulated this way.

  NOTES

    The curves located are modified, but not by shape. If the a non-free-form
    curve is to be re-paramterized, it changes class to a free-form.

  BUGS
  
    Curves located in an object space other than the active one are not
    handled correctly. The EMSdataconstrain structure does not currently
    allow for curve-objects in different modules.

  HISTORY
  
    Rustagi :  05/21/92  :  Modified for Message Sub-system Compliance
    jBk     :  06/06/89  :  Changed GRm_STRING to GRm_TEXT_VALUE
    SS      :  04/20/89  :  Creation
    Sudha   :  07/05/93  :  Modified for BSprototypes ansification

*/

class implementation ECcvreparam;

#include "EMS.h"
#include <string.h>
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"
#include "EC_P.h"
#include "EC_M.h"
#include "ma.h"
#include "mabcrevpa.h"
#include "bscvarrev0.h"
#include "bsarclnparc.h"

#define LOCATE_STATE	0
#define PARBYLEN_STATE	1
#define NUMPTS_STATE	2
#define PTMODIFY_STATE	3
#define CVMODIFY_STATE	4

extern GRclassid OPP_GRbspline_class_id, OPP_GRcurve_class_id;

from GRgraphics import GRdisplay;
from GRvg import GRgenabsg;

method init (IGRint type; IGRchar *string)
{
  IGRlong stat_OM;

  ME.ECcvreparam->parbylen = FALSE;
  ME.ECcvreparam->numpts_per_cv = DEFAULT_NUMPTS_PER_CV;

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message
             ECelements.init (type, string), targetid = my_id);
  ME.ECelements->owner_action &= ~LC_FLEX_OWNER;

  return (stat_OM);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRchar str[MAX_CHAR], buff1[MAX_CHAR], buff2[MAX_CHAR];
  IGRint default_numpts;
  IGRlong msg_loc, stat_OM, eventmask;
  struct GRevent event, lastevent;
  enum EMSuser_responses useract;
  extern IGRboolean EMinit_wininfo();

  stat_OM = OM_S_SUCCESS;

  ex$message(msgnumb = EM_M_AdParonCur);

  do 
    {
    switch (ME.super_cmd->state)
      {
      case LOCATE_STATE:
        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                   &useract, response, response_data, "curve", 
                   " near start point", " / Backup for option", NULL, NULL,
                   NULL),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (useract == EMSuser_backup)
          ME.super_cmd->state = PARBYLEN_STATE;
        else if (useract == EMSuser_moveon)
          ME.super_cmd->state = NUMPTS_STATE;
        else
          goto ret_end;
        break;

      case PARBYLEN_STATE:
        ex$message(msgnumb = EMS_P_ParbyArcLen, buff = str);
        if (ME.ECcvreparam->parbylen) 
        	ex$message(msgnumb = EMS_P_Yes, buff = buff1)
        else 
        	ex$message(msgnumb = EMS_P_No, buff = buff1)
        strcat (str, buff1);
        ex$message(field=PROMPT_FIELD, justification=RIGHT_JUS, in_buff=str);
        eventmask = GRm_TEXT_VALUE | GRm_RJT_MOVEON;
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
            break;

          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'N')
              ME.ECcvreparam->parbylen = FALSE;
            else if (toupper (event.event.keyin[0]) == 'Y')
              ME.ECcvreparam->parbylen = TRUE;
            else
              goto ret_end;
            break;

          default:
            goto ret_end;
          }
        ME.super_cmd->state = LOCATE_STATE;
        break;

      case NUMPTS_STATE:
        default_numpts = ME.ECcvreparam->numpts_per_cv;
        ex$message(msgnumb = EMS_P_InpNumCtlPts, buff=buff2);
        sprintf (str, "%s[%d]",buff2, default_numpts);
	ex$message(field = PROMPT_FIELD, justification=RIGHT_JUS, in_buff=str);
        eventmask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     value_type = GRIO_SCALAR, response = response,
                     response_data = response_data, event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        ex$message(msgnumb = EMS_P_ClearPromptField);

        if (event.response == EX_VALUE ||
            event.response == EX_RJT_MOVEON)
          {
          if (event.response == EX_VALUE && msg_loc != GRw_no_value)
            {
            if (event.event.value)
              ME.ECcvreparam->numpts_per_cv = event.event.value;
            else
              break;
            }

          stat_OM = om$send (msg = message ECcvreparam.data_init (&msg_loc),
                     targetid = my_id);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           ret_end);

          ME.super_cmd->state = PTMODIFY_STATE;
          }
        else if (event.response == EX_BACK_UP)
          ME.super_cmd->state = LOCATE_STATE;
        else
          goto ret_end;
        break;

      case PTMODIFY_STATE:
        if (ME.ECelements->elems_hilit)
          {
          stat_OM = dp$erase_hilite (msg = &msg_loc);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           ret_end);
          ME.ECelements->elems_hilit = FALSE;
          }

        stat_func = EMinit_wininfo();
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        stat_OM = om$send (msg = message ECcvreparam.ptdata_modify (&msg_loc,
                   &useract, &lastevent, response, response_data),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (useract == EMSuser_backup)
          ME.super_cmd->state = NUMPTS_STATE;
        else if (useract == EMSuser_moveon)
          ME.super_cmd->state = CVMODIFY_STATE;
        else
          goto ret_end;
        break;

      case CVMODIFY_STATE:
        ex$message(msgnumb = EMS_I_Processing);
        stat_OM = om$send (msg = message ECcvreparam.cvdata_modify (&msg_loc),
                   targetid = my_id);
        ex$message(msgnumb = EMS_S_ClearStatusField);
        if (msg_loc != EMS_E_InvalidArg)
          {
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           ret_end);
          }
        else
          {
          ex$message(msgnumb = EMS_P_InvalPar);
          sleep (2);
          }

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_STATE;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  if (EMSerror (stat_OM))
    {
    *response = TERMINATE;
    ex$message(msgnumb = EMS_S_ExitDuError);
    sleep (2);
    }
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
  *operation = EC_GEOM_NOCHGSHAPE;
  *options = EC_LOC_DISPELEMDIR | EC_LOC_NOFLEXGROUPS | EC_LOC_NOSPECOBJS;

  *minnum_to_locate = 1;
  *maxnum_to_locate = MAXINT;

ret_end:
  return (stat_OM);
}

method data_init (IGRlong *msg)
{
  IGRboolean *ptaltered;
  IGRint i, vlasize, numpts;
  IGRlong stat_OM;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  numpts = ME.ECelements->num_elems * ME.ECcvreparam->numpts_per_cv;

  ME.ECcvreparam->incomplete_inxprocess = FALSE;

  vlasize = om$dimension_of (varray = ME.ECcvreparam->pts);
  if (vlasize < numpts)
    {
    stat_OM = om$vla_set_dimension (varray = ME.ECcvreparam->pts,
               size = numpts);
    EMomerr_exit (stat_OM, ret_end);
    }
  ME.ECcvreparam->ptdata_valid = FALSE;

  vlasize = om$dimension_of (varray = ME.ECcvreparam->ptaltered);
  if (vlasize < numpts)
    {
    stat_OM = om$vla_set_dimension (varray = ME.ECcvreparam->ptaltered,
               size = numpts);
    EMomerr_exit (stat_OM, ret_end);
    }
  ptaltered = ME.ECcvreparam->ptaltered;
  for (i=0; i<numpts; i++)
    ptaltered[i] = FALSE;

ret_end:
  return (stat_OM);
}



#define NUM_CVS_STATIC 5
#define NUM_PTS_STATIC 10

method ptdata_modify (IGRlong *msg; enum EMSuser_responses *useract;
                      struct GRevent *lastevent; 
                      IGRint *response; IGRchar *response_data)
{
  IGRboolean reentry, done;
  IGRboolean *ptaltered;
  IGRushort *cvprops;
  IGRshort *actmattyp, *mattyp;
  IGRint i, j, numcvs, numpts_per_cv;
  IGRint proc_cvinx, proc_ptinx;
  IGRlong msg_loc, stat_OM;
  IGRdouble pars_mem[NUM_PTS_STATIC], *pars;
  IGRdouble delta, *actmat, *mat;
  IGRpoint *pts;
  GRspacenum osnum;
  GRobjid objid;
  struct GRmd_env *actmd_env;
  struct IGRbsp_curve *cv;
  struct IGRdisplay display;
  struct EMSdataconstrain cvcons_mem[NUM_CVS_STATIC], *cvcons;
  struct GRlc_info *cvinfo;
  enum GRdpmode dpmode;
  extern void EMptnetwrk_display(), EMptnetwrk();
extern IGRboolean GRabsg_del_all() ;
  extern IGRlong EMgetabsg();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  cvcons = NULL;
  pars = NULL;

  actmd_env = &ME.ECelements->active_md_env;
  actmattyp = &actmd_env->md_env.matrix_type;
  actmat = actmd_env->md_env.matrix;
  numcvs = ME.ECelements->num_elems;
  cvinfo = ME.ECelements->elems;
  cvprops = ME.ECelements->elemprops;
  numpts_per_cv = ME.ECcvreparam->numpts_per_cv;

  /*
   * Obtain the constraints structures for each curve (row).
   */

  if (numcvs > NUM_CVS_STATIC)
    cvcons = (struct EMSdataconstrain *) om$malloc (size = numcvs *
              sizeof (struct EMSdataconstrain));
  else
    cvcons = cvcons_mem;
  EMerr_hndlr (!cvcons, *msg, EMS_E_NoDynamicMemory, ret_end);

  for (i=0; i<numcvs; i++)
    {
    cvcons[i].type = EMSconstrain_tocrv;
    cvcons[i].data.datatype = EMSdata_object;
    cvcons[i].data.data.object = &cvinfo[i].located_obj;
    }

  /*
   * Obtain the point-matrix that has equi-parameterized points along
   * each curve as it's rows (if it has not already been obtained). The
   * parameters-array is generated. The points (and parameters) are generated
   * only as internal points to the curve (excluding the end-points), since
   * the end-points cannot be reparametrized to anything but 0.0 and 1.0,
   * respectively. If the curves are to be parametrized by arc-length,
   * the geometry of these curves is picked up thusly.
   */

  if (numpts_per_cv > NUM_PTS_STATIC)
    pars = (IGRdouble *) om$malloc (size = numpts_per_cv * sizeof (IGRdouble));
  else
    pars = pars_mem;

  delta = 1.0 / ((numpts_per_cv+2) - 1);
  pars[0] = delta;
  for (i=1; i<numpts_per_cv; i++)
    pars[i] = pars[i-1] + delta;

  pts = ME.ECcvreparam->pts;
  if (!ME.ECcvreparam->ptdata_valid)
    {
    for (i=0, j=0; i<numcvs; i++, j+=numpts_per_cv)
      {
      osnum = cvinfo[i].located_obj.osnum;
      objid = cvinfo[i].located_obj.objid;
      mattyp = &cvinfo[i].module_info.md_env.matrix_type;
      mat = cvinfo[i].module_info.md_env.matrix;

      stat_OM = EMgetabsg (&msg_loc, mattyp, mat, osnum, objid, &cv);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
      
      if (cvprops[i] & EC_ELEM_ISREVERSED)
        {
        MAbcrevparm (&msg_loc, cv, cv);
        GRabsg_del_all();
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
        }

      if (ME.ECcvreparam->parbylen)
        {
        BSarclnparc (&msg_loc, cv);
        GRabsg_del_all();
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
        }

      BScvarrev0 (&msg_loc, cv, pars, numpts_per_cv, pts[j]);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      }
    ME.ECcvreparam->ptdata_valid = TRUE;
    }

  /*
   * Call the point network modification function over and over. This
   * loop terminates under the following conditions:
   * a) The point to be modified had been selected but processing is
   *    interrupted before modification. 
   *    (Return code is EMS_I_Incomplete, useract: EMSuser_stack).
   * b) User indicates a termination of the modification processing.
   *    (Return code: EMS_S_Success, useract: EMSuser_moveon).
   * c) User indicated a back-up before choosing a point to modify.
   *    (Return code: EMS_S_Success, useract: EMSuser_backup).
   * d) The processing was suspended by an uninterpretable user-input,
   *    but at a stage where the point was not selected.
   *    (Return code: EMS_S_Success, useract: EMSuser_stack).
   * e) An error condition occurred. 
   *    (Return code: EMS_E_xxx).
   *
   * Under the following return conditions the loop continues.
   * a) A point was selected and modified. The index of the changed point
   *    is noted.
   *    (Return code: EMS_S_Success, useract: EMSuser_data)
   */

  display = ME.ECelements->active_display;
  display.weight = 0;
  display.style = 2;

  dpmode = GRbd;
  EMptnetwrk_display (&msg_loc, pts, numcvs, numpts_per_cv, &display,
   actmd_env, dpmode, 
   (numcvs == 1 ? EMS_PTNET_DISPROWS : EMS_PTNET_DISPCOLS) | EMS_PTNET_DISPPT);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (reentry = ME.ECcvreparam->incomplete_inxprocess)
    {
    proc_cvinx = ME.ECcvreparam->proc_cvinx;
    proc_ptinx = ME.ECcvreparam->proc_ptinx;
    }
  ptaltered = ME.ECcvreparam->ptaltered;
  done = FALSE;
  do
    {
    EMptnetwrk (&msg_loc, pts, numcvs, numpts_per_cv, cvcons,
     &display, actmd_env, reentry, &proc_cvinx, &proc_ptinx,
     (numcvs == 1 ? EMS_PTNET_DISPROWS : EMS_PTNET_DISPCOLS) |
      EMS_PTNET_DISPPT,
     useract, lastevent, response, response_data);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    reentry = FALSE;

    if (*useract == EMSuser_data)
      ptaltered[proc_cvinx * numpts_per_cv + proc_ptinx] = TRUE;
    else if (msg_loc == EMS_I_Interrupt)
      {
      ME.ECcvreparam->incomplete_inxprocess = TRUE;
      ME.ECcvreparam->proc_cvinx = proc_cvinx;
      ME.ECcvreparam->proc_ptinx = proc_ptinx;
      done = TRUE;
      }
    else
      done = TRUE;
    }
  while (!done);

  dpmode = GRbe;
  EMptnetwrk_display (&msg_loc, pts, numcvs, numpts_per_cv, &display,
   actmd_env, dpmode,
   (numcvs == 1 ? EMS_PTNET_DISPROWS : EMS_PTNET_DISPCOLS) | EMS_PTNET_DISPPT);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  if (cvcons && cvcons != cvcons_mem)
    om$dealloc (ptr = cvcons);
  if (pars && pars != pars_mem)
    om$dealloc (ptr = pars);

  EMWRAPUP (stat_OM, *msg, NULL);
  return (stat_OM);
}



method cvdata_modify (IGRlong *msg)
{
  IGRboolean *ptaltered;
  IGRushort *cvprops;
  IGRint i, j, k, l, inxlim, altptctr, numcvs, numpts_per_cv;
  IGRlong msg_loc, mod_msg, stat_OM;
  IGRdouble pars_mem[2*NUM_PTS_STATIC], *pars, *oldpars;
  IGRdouble delta;
  IGRpoint pts_mem[NUM_PTS_STATIC], *newpts, *pts;
  struct GRid *cvobj;
  struct GRlc_info *cvinfo;
  struct GRmd_env *cvenv, *actenv;
  enum GRdpmode dpmode;
  extern IGRlong EMcvreparam();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  pars = NULL;
  newpts = NULL;

  numcvs = ME.ECelements->num_elems;
  cvinfo = ME.ECelements->elems;
  cvprops = ME.ECelements->elemprops;
  numpts_per_cv = ME.ECcvreparam->numpts_per_cv;
  actenv = &ME.ECelements->active_md_env;

  /*
   * If a particular curve needs to be reparameterized (indicated by the
   * Boolean flag array - ptaltered), the new geometry is posted directly
   * into the curve if it is a free-form curve to begin with. If it is
   * not then the curve changes class into a free-form and gets the
   * new geometry.
   */

  if (numpts_per_cv > NUM_PTS_STATIC)
    {
    pars = (IGRdouble *) om$malloc (size = 2 * numpts_per_cv * 
            sizeof (IGRdouble));
    newpts = (IGRpoint *) om$malloc (size = numpts_per_cv * sizeof (IGRpoint));
    }
  else 
    {
    pars = pars_mem;
    newpts = pts_mem;
    }
  EMerr_hndlr (!pars || !newpts, *msg, EMS_E_NoDynamicMemory, ret_end);
  oldpars = &pars[numpts_per_cv];

  delta = 1.0 / ((numpts_per_cv+2) - 1);
  pars[0] = delta;
  for (i=1; i<numpts_per_cv; i++)
    pars[i] = pars[i-1] + delta;

  pts = ME.ECcvreparam->pts;
  ptaltered = ME.ECcvreparam->ptaltered;
  for (i=0, j=0; i<numcvs; i++, j+=numpts_per_cv)
    {
    altptctr = 0;
    inxlim = j+numpts_per_cv;
    for (k=j, l=0; k<inxlim; k++, l++)
      {
      if ((k<inxlim-1 && ptaltered[k+1]) ||
          ptaltered[k] ||
          (k>j && ptaltered[k-1]))
        {
        oldpars[altptctr] = pars[l];
        OM_BLOCK_MOVE (pts[k], newpts[altptctr], sizeof (IGRpoint));
        altptctr++;
        }
      }
    
    if (altptctr || ME.ECcvreparam->parbylen ||
        cvprops[i] & EC_ELEM_ISREVERSED)
      {
      cvenv = &cvinfo[i].module_info;
      cvobj = &cvinfo[i].located_obj;

      dpmode = GRbe;
      stat_OM = om$send(msg = message GRgraphics.GRdisplay
                 (&msg_loc, &cvenv->md_env.matrix_type, cvenv->md_env.matrix, 
                 &dpmode, &actenv->md_id), targetid = cvobj->objid,
                 targetos = cvobj->osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

      stat_OM = EMcvreparam (&mod_msg, &cvinfo[i].located_obj,
                 &cvinfo[i].module_info, ME.ECcvreparam->parbylen,
                 cvprops[i] & EC_ELEM_ISREVERSED,
                 altptctr, oldpars, NULL, NULL, newpts);

      dpmode = GRbd;
      stat_OM = om$send(msg = message GRgraphics.GRdisplay
                 (&msg_loc, &cvenv->md_env.matrix_type, cvenv->md_env.matrix, 
                 &dpmode, &actenv->md_id), targetid = cvobj->objid,
                 targetos = cvobj->osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

      if (EMSerror (mod_msg))
        {
        *msg = mod_msg;
        goto ret_end;
        }
      }
    }

ret_end:
  if (pars && pars != pars_mem)
    om$dealloc (ptr = pars);
  if (newpts && newpts != pts_mem)
    om$dealloc (ptr = newpts);

  if (*msg != EMS_E_InvalidArg)
    EMWRAPUP (stat_OM, *msg, NULL);
  return (stat_OM);
}

end implementation ECcvreparam;
