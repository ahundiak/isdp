class implementation EMSsubbs;

#include <math.h>
#include <alloca.h>
#include <memory.h>
#include "OMmacros.h"
#include "igrdp.h"
#include "gocmacros.h"

#include "bserr.h"
#include "madef.h"
#include "prototypes/bsconstprcv.h"
#include "prototypes/bspartofcv.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "sfdpdata.h"
#include "PWapi/sfdp.h"
#include "PWapi/sfgeom.h"
#include "channel.h"
#include "PWapi/clsid.h"
#include "PWapi/mx.h"

from EMSgradata import EMgetRLT;

%safe
static void invert_clip_pars
(
  int num_clip_pairs,
  double *clip_pars,
  double cktol,
  int *num_keep_pairs,
  double *keep_pairs
);
%endsafe

/*
  DESCRIPTION

  The following function obtains the color, weight and line-style of the
  surface. 


  BUGS

  The structure PWsfattrdata must be done away with. The information must
  be returned instead in the existing IGRdisplay structure.

 
  HISTORY

  SAM  :  02/15/95  :  Creation
*/

PWresult pwGetSfAttrData
(
  PWobjid                 sfobj, 
  PWosnum                 os,
  struct PWsfattrdata     *p_sfattrdata
)
{
  /* status stuff */

  long                    OMsts = OM_S_SUCCESS, OMmsg = EMS_S_Success;
  unsigned                int retval = PW_K_Success;

  struct GRsymbology      symb;
  short                   gprops;
  struct IGResbs          attr;
                            
  /* intialize the sfattrdata structures to default values */

  p_sfattrdata->id = sfobj;
  p_sfattrdata->os = os;

  OMsts = om$send(msg = message GRvg.GRgetsymb(&OMmsg, &symb),
		  targetid = sfobj,
		  targetos = os,
		  senderid = sfobj);
  OnErrorState(!(1&OMsts&OMmsg), retval, SetError(0, PW_K_Internal), wrapup);
		
  OMsts = om$send(msg = message GRvg.GRgetattr(&OMmsg, (char *) &attr),
		  targetid = sfobj,
		  targetos = os,
		  senderid = sfobj);
  OnErrorState(!(1&OMsts&OMmsg), retval, SetError(0, PW_K_Internal), wrapup);

 OMsts = om$send(msg = message GRvg.GRgetprops(&OMmsg, &gprops),
		  targetid = sfobj,
		  targetos = os,
		  senderid = sfobj);
  OnErrorState(!(1&OMsts&OMmsg), retval, SetError(0, PW_K_Internal), wrapup);

  OM_BLOCK_MOVE(&symb.display_attr,&p_sfattrdata->attr,sizeof(struct IGRdisplay));

  p_sfattrdata->polygon_display = attr.is_polydis;
  p_sfattrdata->surface_display = gprops & GRIS_DISPLAYABLE;

wrapup:

  return retval;
}



/*
  DESCRIPTION

  The following function returns the number of 'internal' rule lines or iso-
  lines (not counting the iso-lines occuring at the natural boundary), along 
  with the boundaries on each of them. Each boundary on a given rule-line
  defines the pair of parameters on the iso-curve, which will yield the portion
  of the iso-curve lying within area of the surface.

  The number of internal iso-lines in U and V -- 'num_u_rules' and 
  'num_v_rules' are returned. A U-iso-line is one which holds U constant.
  The values of the U and V parameters at which these lines are defined are
  returned in the arrays -- 'u_rule_pars' and 'v_rule_pars'. The number of 
  boundaries on each of these rule lines is returned in the arrays --
  'num_u_rule_bdrys' and 'num_v_rule_bdrys'. And finally the boundaries
  on each of the rule-lines are returned in the 3-dimensional arrays --
  'u_rule_bdrys' and 'v_rule_bdrys'. All the output arguments, except the
  last set -- u_rule_bdrys and v_rule_bdrys are single arrays. All memory
  for arrays is allocated by the function. The caller must free the memory
  by a call to the corresponding free function supplied -- 
  pwFreeSfRuleLineTable (see below).

  The last pair of output arguments needs some explanation. The caller declares
  the arguments as:
    double (**u_rule_bdrys)[2], (**v_rule_bdrys)[2];
  and calls the function giving the address of these variables (eg: 
  &u_rule_bdrys). The way the data is accessed after the call is:
    start_par = u_rule_bdrys[i][j][START];
    stop_par = u_rule_bdrys[i][j][STOP];
  where, i is the i-th rule-line in the array (0 <= i < num_u_rules),
  and j is the j-th boundary on that rule-line (0 <= j < num_u_rule_bdrys[i]),
  and START is the constant 0 and STOP is the constant 1.
  

  ASSUMPTIONS

  The function assumes that the iso-curves on the surface, when extracted,
  will have their parameterization range from 0 to 1. Also, this function
  assumes that the clip points stored inside the EMSgradata are in a ascending,
  sorted order.


  BUGS

  In the current implementation, the same rule-line (iso-line) can occur
  multiple times but with a different set of boundaries on them. So, by
  looking at 'num_u_rules' or 'num_v_rules', one cannot trivially say, how
  many iso-lines will be drawn. We should change this behaviour later to
  coalesce these rule-lines correctly. But this, re-occurence of iso-lines
  should not hamper the extraction of the XYZ curves corresponding to the
  boundaries. It only makes that process less efficient.

  In the current implementation, the boundary parameters pairs may not occur
  sorted for a given rule-line. This will be changed later. But this possible
  unsorted nature does not hamper the extraction of the part of the iso-curve
  that is visible in the rule-line.


  HISTORY

  SS  :  03/07/96  :  Creation
*/

#define LOCAL_RLT_BUFFER_SIZE 1000

PWresult pwGetSfRuleLineTable
(
  PWobjid sfobj,
  PWosnum os,
  int *num_u_rules,
  int *num_v_rules,
  double **u_rule_pars,
  double **v_rule_pars,
  int **num_u_rule_bdrys,
  int **num_v_rule_bdrys,
  double (***u_rule_bdrys)[2],
  double (***v_rule_bdrys)[2]
)
{
  char **rltbuffers;
  int i, j, k, uinx, vinx;
  int num_helpers=0, num_gradata=0, dum_num;
  int num_clip_pairs, num_keep_pairs;
  long msg;
  double *keep_pars, keep_pars_mem[2], cktol=1e-10;
  PWmatrix mx;
  PWresult result=PW_K_Success;
  PWobjid *helpers, *gradata;
  struct IGResqbs **rlt=NULL;
  struct IGResbs esbs;
  struct IGRbsp_surface *sf;
  OM_S_CHANSELECT chan_to_helpers;

  /*
   * Initialize the output
   */

  *num_u_rules = 0;
  *num_v_rules = 0;
  *u_rule_pars = NULL;
  *v_rule_pars = NULL;
  *num_u_rule_bdrys = NULL;
  *num_v_rule_bdrys = NULL;
  *u_rule_bdrys = NULL;
  *v_rule_bdrys = NULL;

  /*
   * Obtain any EMSgradata objects of this surface that store the
   * rule-line tables. Note that we need to pick up only the EMSgradata
   * objects on the helper channel. So weed out the rest. The surface may not
   * have any EMSgradata objects on it, and the rule-line table will then
   * have to be filled up by looking up the surface's attributes.
   */

  EMmake_chanselect (EMSrequester_to_helpers, &chan_to_helpers);
  num_helpers = omNumObjsOnChannel (sfobj, os, &chan_to_helpers);
  if (num_helpers)
  {
    helpers = (PWobjid *) alloca (num_helpers * sizeof (PWobjid));
    dum_num = omGetObjsOnChannel (sfobj, os, &chan_to_helpers, helpers);
    OnErrorState (dum_num != num_helpers, result, 
     SetError (PW_K_EMS, PW_K_Internal), wrapup);
    gradata = (PWobjid *) alloca (num_helpers * sizeof (PWobjid));
    for (i=0; i<num_helpers; i++)
      if (omClassidFromObjid (helpers[i], os) == OPP_EMSgradata_class_id)
      {
        gradata[i] = helpers[i];
        num_gradata++;
      }
  }

  /*
   * Obtain all the rule-line information for this surface, either from
   * EMSgradata, when present or from the surface-attributes when not.
   */

  if (num_gradata)
  {
    /*
     * For every EMSgradata object, obtain the rule-line table.
     */

    rlt = (struct IGResqbs **) alloca (num_gradata * sizeof (char *));
    memset (rlt, NULL, num_gradata * sizeof (char *));
    rltbuffers = (char **) alloca (num_gradata * sizeof (char *));
    memset (rltbuffers, NULL, num_gradata * sizeof (char *));

    for (i=0; i<num_gradata; i++)
    {
      rltbuffers[i] = (char *) alloca (LOCAL_RLT_BUFFER_SIZE);
      memset (rltbuffers[i], NULL, LOCAL_RLT_BUFFER_SIZE);
  
      result = om$send (msg = message EMSgradata.EMgetRLT (&msg, rltbuffers[i],
                LOCAL_RLT_BUFFER_SIZE, &rlt[i]), targetid = gradata[i], 
                targetos = os, senderid = PW_K_NullObjid);
      OnErrorState (IsError (result & msg), result, SetError (PW_K_Pathway,
       PW_K_Error), wrapup);
    }
  }
  
  else
  {
    /*
     * If there are no EMSgradata objects stored for this  surface, then
     * artificially generate an rlt, based on the attribute information
     * stored within the surface. Artificially, set num_gradata to 1 so the
     * rest of the code doesn't know the difference.
     */

    result = om$send (msg = message GRvg.GRgetattr (&msg, (char *) &esbs),
              targetid = sfobj, targetos = os, senderid = PW_K_NullObjid);
    OnErrorState (IsError (result & msg), result, SetError (PW_K_Pathway,
     PW_K_Error), wrapup);

    result = PW_GetSfBspsfStack (sfobj, os, MAIDMX, pwIdMx (mx), sf);  
    OnErrorCode (result, wrapup);

    rlt = (struct IGResqbs **) alloca (sizeof (char *));
    memset (rlt, NULL, sizeof (char *));
    rltbuffers = (char **) alloca (sizeof (char *));
    memset (rltbuffers, NULL, sizeof (char *));

    rltbuffers[0] = (char *) alloca (LOCAL_RLT_BUFFER_SIZE);
    memset (rltbuffers[0], NULL, LOCAL_RLT_BUFFER_SIZE);
  
    result = om$send (msg = message EMSsubbs.EMgetRuleLineTable (&msg,
              FALSE, (int *) &esbs.u_rules, (int *) &esbs.v_rules, 
              sf, NULL, NULL, 
              rltbuffers[0], LOCAL_RLT_BUFFER_SIZE, &rlt[0]),
              targetid = sfobj, targetos = os, senderid = PW_K_NullObjid);
    OnErrorState (IsError (result & msg), result, SetError (PW_K_Pathway,
     PW_K_Error), wrapup);

    num_gradata = 1;
  }


  /*
   * Scan the rule-line tables, gathering information and allocating the
   * appropriate amount of memory.
   */

  for (i=0; i<num_gradata; i++)
  {
    (*num_u_rules) += rlt[i]->u_rules;
    (*num_v_rules) += rlt[i]->v_rules;
  }

  if (*num_u_rules)
  {
    *u_rule_pars = (double *) malloc (*num_u_rules * sizeof (double));
    *num_u_rule_bdrys = (int *) malloc (*num_u_rules * sizeof (int));
    *u_rule_bdrys = (double (**)[]) malloc (*num_u_rules * sizeof (char *));

    OnErrorState (!*u_rule_pars || !*num_u_rule_bdrys || !*u_rule_bdrys,
     result, SetError (PW_K_EMS, PW_K_DynamicMemory), wrapup);
  }
  if (*num_v_rules)
  {
    *v_rule_pars = (double *) malloc (*num_v_rules * sizeof (double));
    *num_v_rule_bdrys = (int *) malloc (*num_v_rules * sizeof (int));
    *v_rule_bdrys = (double (**)[]) malloc (*num_v_rules * sizeof (char *));

    OnErrorState (!*v_rule_pars || !*num_v_rule_bdrys || !*v_rule_bdrys,
     result, SetError (PW_K_EMS, PW_K_DynamicMemory), wrapup);
  }

  /*
   * Obtain the boundaries. The pairs that are stored in the RLT represent
   * the gaps on the curve. So we need to obtain the complement of the
   * pairs. See the notes above the static function used to do this task.
   */

  uinx = 0;
  vinx = 0;
  for (i=0; i<num_gradata; i++)
  {
    /*
     * Process the U-rule lines for this (i-th) EMSgradata
     */

    for (j=0; j<rlt[i]->u_rules; j++)
    {
      (*u_rule_pars)[uinx] = rlt[i]->u_rule_values[j];

      num_clip_pairs = rlt[i]->u_num_bound[j];
      if (num_clip_pairs)
      {
        keep_pars = (double *) alloca ((num_clip_pairs+1)*2*sizeof (double));
        invert_clip_pars (num_clip_pairs, rlt[i]->u_bdrys[j], cktol,
         &num_keep_pairs, keep_pars);
      }
      else
      {
        num_keep_pairs = 1;
        keep_pars = keep_pars_mem;
        keep_pars[0] = 0.0;
        keep_pars[1] = 1.0;
      }
      (*num_u_rule_bdrys)[uinx] = num_keep_pairs;

      (*u_rule_bdrys)[uinx] = (double (*)[]) malloc (num_keep_pairs * 
                               2 * sizeof(double));
      OnErrorState (!(*u_rule_bdrys)[uinx], result, SetError (PW_K_EMS,
       PW_K_DynamicMemory), wrapup);
      for (k=0; k<num_keep_pairs; k++)
      {
        (*u_rule_bdrys)[uinx][k][START] = keep_pars[k*2];
        (*u_rule_bdrys)[uinx][k][STOP] = keep_pars[k*2+1];
      }
      uinx++;
    }

    /*
     * Process the V-rule lines for this (i-th) EMSgradata
     */

    for (j=0; j<rlt[i]->v_rules; j++)
    {
      (*v_rule_pars)[vinx] = rlt[i]->v_rule_values[j];

      num_clip_pairs = rlt[i]->v_num_bound[j];
      if (num_clip_pairs)
      {
        keep_pars = (double *) alloca ((num_clip_pairs+1)*2*sizeof (double));
        invert_clip_pars (num_clip_pairs, rlt[i]->v_bdrys[j], cktol,
         &num_keep_pairs, keep_pars);
      }
      else
      {
        num_keep_pairs = 1;
        keep_pars = keep_pars_mem;
        keep_pars[0] = 0.0;
        keep_pars[1] = 1.0;
      }
      (*num_v_rule_bdrys)[vinx] = num_keep_pairs;

      (*v_rule_bdrys)[vinx] = (double (*)[]) malloc (num_keep_pairs * 
                               2 * sizeof(double));
      OnErrorState (!(*v_rule_bdrys)[vinx], result, SetError (PW_K_EMS,
       PW_K_DynamicMemory), wrapup);
      for (k=0; k<num_keep_pairs; k++)
      {
        (*v_rule_bdrys)[vinx][k][START] = keep_pars[k*2];
        (*v_rule_bdrys)[vinx][k][STOP] = keep_pars[k*2+1];
      }
      vinx++;
    }
  }

wrapup:
  if (rlt)
   for (i=0; i<num_gradata; i++)
     if (rlt[i] && (char *)rlt[i] != rltbuffers[i])
       free (rlt[i]);

  PW_Wrapup (result, "pwGetSfRuleLines");
  return (result);
}

/*
 * Static helper function for above.
 * 
 * Out of the n_pairs, check if any of the boundary clip values lie at 
 * 0 or 1. Say, there are 'n_ends' such values (can only be 0, 1 or 2). Then 
 * the number of contiguous segments that the curve gets broken up into
 * is n_segs = ((n_pairs * 2) - n_ends)+1. Now, if there is any pair of clip
 * points that are at the ends (ie, n_ends is non-zero) then, we need to
 * discard that segment and start counting segments-to-keep in an alternating
 * fashion with the remaining. So if the number of significant segments 
 * after discarding is N_segs (= (n_segs - (n_ends ? 1 : 0))), then the
 * number of segments to keep becomes = (N_segs / 2) + (N_segs % 2). This
 * latter is nothing but picking up alternate segments starting from the
 * first of the new set.
 */

static void invert_clip_pars
(
  int num_clip_pairs,
  double *clip_pars,
  double cktol,
  int *num_keep_pairs,
  double *keep_pars
)
{
  int start_seg_clipped=0, stop_seg_clipped=0;
  int num_internal_pars, n_segs, N_segs, num_segs_keep;

  if (fabs (clip_pars[0]) < cktol)
    start_seg_clipped = 1;
  if (fabs (clip_pars[num_clip_pairs*2-1] - 1.0) < cktol)
    stop_seg_clipped = 1;

  num_internal_pars = (num_clip_pairs*2 - 
                       start_seg_clipped - stop_seg_clipped);
  n_segs = num_internal_pars + 1;
  N_segs = n_segs - ((start_seg_clipped || stop_seg_clipped) ? 1 : 0);
  num_segs_keep = (N_segs / 2) + (N_segs % 2);

  *num_keep_pairs = num_segs_keep;
  if (start_seg_clipped)
    memcpy (keep_pars, &clip_pars[1], num_internal_pars*sizeof (double));
  else
  {
    keep_pars[0] = 0.0;
    memcpy (&keep_pars[1], &clip_pars[0], num_internal_pars*sizeof (double));
  }

  if (!stop_seg_clipped)
    keep_pars[(*num_keep_pairs)*2 - 1] = 1.0;

  return;
}


void pwFreeSfRuleLineTable
(
  int num_u_rules,
  int num_v_rules,
  double *u_rule_pars,
  double *v_rule_pars,
  int *num_u_rule_bdrys,
  int *num_v_rule_bdrys,
  double (**u_rule_bdrys)[2],
  double (**v_rule_bdrys)[2]
)
{
  int i;

  if (u_rule_pars)
    free (u_rule_pars);

  if (v_rule_pars)
    free (v_rule_pars);

  if (num_u_rule_bdrys)
    free (num_u_rule_bdrys);

  if (num_v_rule_bdrys)
    free (num_v_rule_bdrys);

  if (u_rule_bdrys)
  {
    for (i=0; i<num_u_rules; i++)
      if (u_rule_bdrys[i])
        free (u_rule_bdrys[i]);
    free (u_rule_bdrys);
  }

  if (v_rule_bdrys)
  {
    for (i=0; i<num_v_rules; i++)
      if (v_rule_bdrys[i])
        free (v_rule_bdrys[i]);
    free (v_rule_bdrys);
  }

  return;
}



/*
  DESCRIPTION

  The following function, returns an array of IGRbsp_curves that correspond
  to internal rule-lines displayed on the input 'sfobj'. There is one
  curve output for every piece of the rule-line that is visible. 

  Memory for the output -- 'rule_line_cvs' -- is malloced by this function and
  should be freed by the caller. This is an array of pointers, each pointer
  pointing to an IGRbsp_curve. Each of the curves is malloced as a single
  block of memory (with it's poles, knots and weights pointing to areas within
  this block. Hence each curve pointer must be freed with a single "free"
  call. The caller allocates something like:
    struct IGRbsp_curve **rule_cvs=NULL;
  and calls the function with '&rule_cvs'. To access the output curves:
    rule_cvs[i]
  where, rule_cvs[i] is a pointer to the i-th curve of the output.
  Memory is then freed as:
    for (i=0; i<num_rule_cvs; i++)
      free (rule_cvs[i]);
    free (rule_cvs);


  BUGS

  The output curves are not checked for planarity. Their "planar" field
  is unconditionally set to FALSE. This is being done for performance
  reasons.


  HISTORY

  SS  :  03/07/96  :  Creation
*/

PWresult pwGetSfRuleLineCvs
(
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  int *num_rule_cvs,
  struct IGRbsp_curve ***rule_cvs
)
{
  PWboolean ckplan=FALSE;
  short isodir;
  BSrc rc;
  PWresult result=PW_K_Success;
  int i, j, cvinx, total_num_u_rules, total_num_v_rules;
  int u_size, v_size;
  int u_iso_order, v_iso_order, u_iso_numpoles, v_iso_numpoles;
  int num_u_rules, num_v_rules;
  double *u_rule_pars=NULL, *v_rule_pars=NULL;
  double start_par, mid_par, stop_par;
  int *num_u_rule_bdrys=NULL, *num_v_rule_bdrys=NULL;
  double (**u_rule_bdrys)[2]=NULL, (**v_rule_bdrys)[2]=NULL;
  struct IGRbsp_curve *cv;
  struct IGRbsp_surface *sf;

  *num_rule_cvs = 0;

  result = pwGetSfRuleLineTable (sfobj, os, &num_u_rules, &num_v_rules,
            &u_rule_pars, &v_rule_pars, &num_u_rule_bdrys, &num_v_rule_bdrys,
            &u_rule_bdrys, &v_rule_bdrys);
  OnErrorCode (result, wrapup);

  /*
   * Count the total number of curves that need to be output. One for
   * each boundary on each rule-line. Also, allocate the space to hold
   * pointers for each of the output curves.
   */

  total_num_u_rules = 0;
  for (i=0; i<num_u_rules; i++)
    for (j=0; j<num_u_rule_bdrys[i]; j++)
      total_num_u_rules++;

  total_num_v_rules = 0;
  for (i=0; i<num_v_rules; i++)
    for (j=0; j<num_v_rule_bdrys[i]; j++)
      total_num_v_rules++;

  (*num_rule_cvs) = total_num_u_rules + total_num_v_rules;

  *rule_cvs = (struct IGRbsp_curve **) malloc ((*num_rule_cvs) * 
               sizeof (char *));
  OnErrorState (!*rule_cvs, result, SetError (PW_K_EMS, PW_K_DynamicMemory),
   wrapup);
  
  /*
   * Allocate the memory for all of the output curves. We know that each
   * iso curve requires the same number of poles, weights and knots as in
   * corresponding direction of the surface (V or U). Then, the max number
   * of poles for a curve extracted from such an iso curve = number of poles +
   * (2 X order) - 1.
   */

  result = PW_GetSfBspsfStack (sfobj, os, mattyp, mat, sf);  
  OnErrorCode (result, wrapup);

  u_iso_order = sf->v_order;
  v_iso_order = sf->u_order;
  u_iso_numpoles = sf->v_num_poles + (2 * sf->v_order) - 1;
  v_iso_numpoles = sf->u_num_poles + (2 * sf->u_order) - 1;

  GRbc_size (u_iso_order, u_iso_numpoles, sf->rational, 0, u_size);
  GRbc_size (v_iso_order, v_iso_numpoles, sf->rational, 0, v_size);

  cvinx = 0;
  for (i=0; i<total_num_u_rules; i++)
  {
    cv = (struct IGRbsp_curve *) malloc (u_size);
    OnErrorState (!cv, result, SetError (PW_K_EMS, PW_K_DynamicMemory), 
     wrapup);
   
    GRbc_partition (cv, u_iso_order, u_iso_numpoles, sf->rational, 0);
    (*rule_cvs)[cvinx] = cv;

    cvinx++;
  }
  for (i=0; i<total_num_v_rules; i++)
  {
    cv = (struct IGRbsp_curve *) malloc (v_size);
    OnErrorState (!cv, result, SetError (PW_K_EMS, PW_K_DynamicMemory), 
     wrapup);
   
    GRbc_partition (cv, v_iso_order, v_iso_numpoles, sf->rational, 0);
    (*rule_cvs)[cvinx] = cv;

    cvinx++;
  }

  /*
   * Begin the extraction of all the output curves
   */

  cvinx = 0;

  /*
   * First extract all the U output curves.
   */

  GRbc_size (sf->v_order, sf->v_num_poles, sf->rational, 0, u_size);
  cv = (struct IGRbsp_curve *) alloca (u_size);
  GRbc_partition (cv, sf->v_order, sf->v_num_poles, sf->rational, 0);

  isodir = 1;
  for (i=0; i<num_u_rules; i++)
  {
    BSconstprcv (&rc, sf, &isodir, &u_rule_pars[i], &ckplan, cv);
    OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
     wrapup);

    for (j=0; j<num_u_rule_bdrys[i]; j++)
    {
      start_par = u_rule_bdrys[i][j][START];
      stop_par = u_rule_bdrys[i][j][STOP];
      mid_par = (start_par + stop_par) / 2.0;

      BSpartofcv (&rc, cv, start_par, mid_par, stop_par, (*rule_cvs)[cvinx++]);
      OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
       wrapup);
    }
  }

  /*
   * Now extract all the V output curves.
   */

  GRbc_size (sf->u_order, sf->u_num_poles, sf->rational, 0, v_size);
  cv = (struct IGRbsp_curve *) alloca (v_size);
  GRbc_partition (cv, sf->u_order, sf->u_num_poles, sf->rational, 0);

  isodir = 2;
  for (i=0; i<num_v_rules; i++)
  {
    BSconstprcv (&rc, sf, &isodir, &v_rule_pars[i], &ckplan, cv);
    OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
     wrapup);

    for (j=0; j<num_v_rule_bdrys[i]; j++)
    {
      start_par = v_rule_bdrys[i][j][START];
      stop_par = v_rule_bdrys[i][j][STOP];
      mid_par = (start_par + stop_par) / 2.0;

      BSpartofcv (&rc, cv, start_par, mid_par, stop_par, (*rule_cvs)[cvinx++]);
      OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
       wrapup);
    }
  }

wrapup:
  pwFreeSfRuleLineTable (num_u_rules, num_v_rules, u_rule_pars, v_rule_pars,
   num_u_rule_bdrys, num_v_rule_bdrys, u_rule_bdrys, v_rule_bdrys);

  PW_Wrapup (result, "pwGetSfRuleLineCvs");
  return (result);
}

end implementation EMSsubbs;
