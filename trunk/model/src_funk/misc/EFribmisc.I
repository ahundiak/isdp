class implementation EMSsffeature;

/*
INPUT

  vector   For translation, it is the vector in direction of translation.
           For offset, it is the normal to the profile plane (this is used in
                       conjunction with the parameter "offset_right).
NOTES

1.Whenever an object needs to be offset, translated or otherwise transformed in
  this file, the new object is ALWAYS created using the input construct list for
  consistency. 
2.Variable allocated on stack using alloca are not freed.

3. It is the "offset_ext_profile" that is intersected with the base solid to
   find the OUT segments that we need (in conjunction with the "offset_profile")
   which is finally converted to a specific bitmask on matching intobjs. 

   As a special case, if the "profile" argument is NULL, then we take this to 
   mean that the OUT segments are solely determined by point location with the
   solid and are NOT dependent on relationship between the "offset_ext_profile"
   and the "offset_profile". 

4. Vector can be NULL, if offset/translate distance is zero. If it is NULL even
   when distance is not zero, then zero offset is forced.

5. If "distance" is NULL, then zero offset distance is assumed.

HISTORY:

  NP  07/02/93  Creation
  NP  09/27/93  Added an argument to "EFtrace_and_modify_groups" function, so 
                that traced data can be returned to caller.
  NP  10/06/93  Marking of intobjs had to be modified to suit the fact that we
                now merge extention segments with the profiles, if the ends 
                happen to be linear. 
  NP  10/26/93  Coinicdent plane intersections were not being correctly handled.
  NP  11/29/93  Added function "EFdelete_bad_trace_groups" to remove closed 
                groups that would tend to form external C-loops later.
  NP  12/08/93  Removed call to "EFdelete_bad_trace_groups" since it was 
                removing invalid loops within a very narrow scope. Now the 
                burden has been shifted to the selective boolean function 
                "EFspbool_modify_trace_groups" by passing in a new option to 
                the EMsplityourself method (EMImpBnd_DelInvalidLoops).
Sanjay 3/30/95  Unset the fwd/bwd connect properties of all the intobjs in 
                "EFtrace_and_modify_groups" function. These properties are 
                being set during the intial tracing which was performed on
                this intersection list. TR#119524776.
Sanjay 05/10/95 Unset the fwd/bwd connect properties of all the intobjs in 
                "EFtrace_and_modify_groups" function if the surface is a 
                single surface. Let them remain if the surface is a composite,
                as trace is to be done across surfaces. TR# 119526161.
Aditya 07/04/95 The deletion of intobjs in EFcheck_intobj_overlap() has been
                made conditional depending on whether the intobj lies along
                an offset profile or is along end segments generated in the
                'no_extend' option. An argument 'profile_type' has been added
                to functions "EFmark_trace_intobjs()" and 
                "EFcheck_intobj_overlap()" to mark this fact. This was done
                to fix failures when duplicate intobjs were created by
                coincident plane conditions. Undeleted intobjs will have
                similarly oriented duplicates on the same surface and will
                be cleaned up in EMfixsfintout(). TR# 119524932. This 
                hopefullly is a temporary fix.
Aditya 07/20/95 The fixes (of unsetting fwd/bwd) for TRs 119524776 & 119526161
                have been deleted as a fix has been put in the function
                EFcreate_inters() for properly setting the pointers.
Aditya 09/07/95 Removing the argument profile_type as the problem has been
                fixed at the intersection creation level.
*/

/*******
#define MORE_RIGOROUS_CHECK_FOR_OVERLAP
#define DEBUG  
#define WANT_TO_DISPLAY_MATCHING_INTOBJS 
*******/


%safe
#include <stdio.h>
%endsafe

#include "OMerrordef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "EMSconstruct.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "dp.h"  /* take this out later. used in disp. points */
#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsicmpcvoff.h"
#include "bsparameters.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emserr.h" /* EMerr_hndlr macro*/
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "EMSutlmacros.h"
#include "emslpinitdef.h"

/*math prototypes*/
#include "ma.h"
#include "maunitvc.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "bsdistptpts.h"
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bscumdist.h"
#include "bsprptoncv.h"
#include "bsmergesort.h"

#define ABS_FLOAT(x)  ((x) < 0.0? -(x) : (x))

from GRcurve     import EMcvoffset, GRendpts;
from EMSsolid    import EMpoint_locate;
from EMSboundary import EMtpcopy;
from EMSloop     import EMlpinit, EMgivenestinfo, EMtreemod, EMget_props;
from EMSloop     import EMget_edges;
from EMSloopset  import EMnesting, EMtreemod, EMget_loops;
from EMSsubbs    import EMpartolbasis;

extern OMuword OPP_EMScomposite_class_id;

extern void EMsfinttrace(), EMsfinttrace_free(), EMdelintobj();
extern void EMsfintloops_free(), EMsfintloops_data_free();
extern void EMinters_data_free(), EMinters_free(), EMsfintedpar_free();
extern IGRint EMsfintloops();
extern void EMswapmem();
extern IGRlong EMprojectpt();
extern void EMmergeinters();
extern void EFtransfer_inters();
extern IGRlong EFspbool_modify_trace_groups();
extern void EFset_ptr_from_trace_info();
extern void EMcmpinters();
extern void EMdelintobj_selective();

%safe
static void EMmovetrace(), EMinittrace(), EMfreetrace();
static void EFmodify_cv_pars();
%endsafe

/* If "offset_profile" and "offset_ext_profile" are NOT NULL, these are 
 * passed back from this function, else they are deleted.
 *
 * Does not make sense to have a bunch of env's passed in. Change the function
 * to have only ONE env. passed in, which is common to profiles & base solid.
 */

IGRlong EFmark_trace_intobjs (EFmsg,
                     construct_list,
                     inters,
                     inters_env,
                     check_present_bits,
                     check_absent_bits,
                     mark_bits,
                     unmark_bits,
                     profile,
                     profile_env,
                     offset_profile,
                     offset_profile_endpts,
                     ext_profile,
                     ext_profile_env,
                     offset_ext_profile,
                     offset_ext_profile_endpts,
                     vector,
                     distance,
                     translate,
                     offset_right,
                     base_solid,
                     base_solid_env)
IGRlong *EFmsg;
struct GRvg_construct *construct_list;
struct EMSinters *inters;
struct GRmd_env  *inters_env, *profile_env, *ext_profile_env, *base_solid_env;
IGRlong check_present_bits, check_absent_bits, mark_bits, unmark_bits;
struct GRid *profile, *ext_profile, *base_solid;
struct GRid *offset_profile, *offset_ext_profile;
IGRpoint *offset_profile_endpts, *offset_ext_profile_endpts;
IGRdouble  *distance;
IGRvector vector;
IGRboolean *translate, *offset_right;
{
  BSrc rc;
  GRspacenum const_os;
  GRobjid  objid;
  OMuint  num_orig_comps, num_ext_comps;
  OMuword  prof_class_id;
  OM_S_CHANSELECT to_components;
  GRobjid *orig_comps, *ext_comps;
  IGRlong  sts, msg_loc, num_inter, num_matches;
  IGRlong  num_cv_pars;
  IGRlong  num_alloc_slots;
  IGRulong *int_props;
  IGRint   i,j, *off_code, num_curves, num_pars;
  IGRshort mat_type, xform_mattype;
  IGRdouble *cv_ints_xyz, *cv_pars;
  IGRdouble *mat, basis_tol, basis_tol_sq, knot_tol, cht_tol, cht_tol_sq;
  struct IGRbsp_curve *curve_geom;
  struct GRparms *sol_ints_uv, *cv_ints_uv;
  struct GRmd_env *const_md_env;
  struct GRid prof, ext_prof, current_comp;
  struct GRid offset_prof, offset_ext_prof;
  struct GRid *curr_prof, *moved_prof;
  IGRvector loc_vector, unit_vector, xform_vec;
  IGRmatrix xform_mat;
  IGRboolean success, zero_offset, first_component, last_component;
  IGRboolean fully_overlap,startpt_match,endpt_match;
  IGRpoint  startpt, endpt;
  IGRpoint orig_startpts[2], orig_endpts[2];
  GRobjid cvid;
  GRspacenum cvos;

  /*function calls*/
  IGRlong EFcheck_intobj_overlap();
 

  sts    = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  const_md_env = construct_list->env_info;
  mat          = const_md_env->md_env.matrix; 
  mat_type     = const_md_env->md_env.matrix_type;
  const_os     = const_md_env->md_id.osnum;

  /* initialize output stuff */

  if (offset_profile)
  {
      offset_profile->objid = NULL_OBJID;
      offset_profile->osnum = const_os;
  }
  if (offset_ext_profile)
  {
      offset_ext_profile->objid = NULL_OBJID;
      offset_ext_profile->osnum = const_os;
  }


  /* INITIALIZATIONS. IMPT. CHECKED AT WRAPUP */

   orig_comps  = NULL;
   ext_comps   = NULL;
   zero_offset = FALSE;
   cv_ints_uv  = NULL;
   sol_ints_uv = NULL;
   cv_ints_xyz = NULL;
   int_props   = NULL;
   curve_geom  = NULL;
   cv_pars     = NULL;
   prof.objid = NULL_OBJID;
   prof.osnum = const_os;
   ext_prof.objid  = NULL_OBJID;
   ext_prof.osnum  = const_os;
   offset_prof.objid = NULL_OBJID;
   offset_prof.osnum = const_os;
   offset_ext_prof.objid  = NULL_OBJID;
   offset_ext_prof.osnum  = const_os;

  /* make sure that EITHER mark OR unmark bits are passed in */
  EMerr_hndlr (!mark_bits && !unmark_bits, *EFmsg, EMS_E_Fail, wrapup);


  BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);
  BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht_tol);
  basis_tol_sq = basis_tol * basis_tol;
  cht_tol_sq   = cht_tol * cht_tol;

  sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);

  zero_offset = (distance? ((*distance) == 0.0) : TRUE);


  if (vector)
  {
    /* make a copy of input vector so that we may normalize it */
    OM_BLOCK_MOVE (vector, loc_vector, sizeof (IGRvector));
 
    success = MAunitvc( &msg_loc, loc_vector, unit_vector);
    EMerr_hndlr ((msg_loc!= MSSUCC) || !success, *EFmsg, EMS_E_Fail, wrapup);
  }
  else
  {
     zero_offset = TRUE;

  }
  
  /* if we dont know whether to translate or offset the curve/profile, i.e. the
   * parameter "translate" is passed as NULL, we probably wanted a zero offset.
   */

  if (!translate)
  {
     zero_offset = TRUE;
  }

  /* make a copy of both the incoming profiles/composite curves, in the
   * module environment of the construct list.
   */
  
  prof.osnum   = const_os;
  prof.objid   = NULL_OBJID;

  if (profile)
  {  sts = om$send (msg= message GRgraphics.GRcopy(
                                           &msg_loc,
                                           profile_env,
                                           const_md_env,
                                           &(prof.objid)),
                        senderid=NULL_OBJID,
                        targetid=profile->objid,
                        targetos=profile->osnum);
     EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
  }

  ext_prof.osnum   = const_os;
  ext_prof.objid   = NULL_OBJID;
  sts = om$send (msg= message GRgraphics.GRcopy(
                                           &msg_loc,
                                           ext_profile_env,
                                           const_md_env,
                                           &(ext_prof.objid)),
                        senderid=NULL_OBJID,
                        targetid=ext_profile->objid,
                        targetos=ext_profile->osnum);
  EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);


  /* translate/offset the profiles in the direction given and by the required 
   * distance. 
   */ 
 
  if (zero_offset) /* ==> NO offset/translate  */
  {
      /* the new curve is simply the original curve */
      if (prof.objid != NULL_OBJID)
      {
        OM_BLOCK_MOVE (&prof, &offset_prof, sizeof (struct GRid));
      }
      OM_BLOCK_MOVE (&ext_prof,  &offset_ext_prof,  sizeof (struct GRid));

      /* Since copies themselves are the moved profiles, set ids to NULL_OBJID,
       * else it will try deleting twice at wrapup.
       */
      prof.objid = NULL_OBJID;
      ext_prof.objid  = NULL_OBJID;
      
  }
  else if (translate && *translate)
  {
    /* create a transformation matrix to translate in the direction of the
     * "unit_vector" by the amount specified by "distance".
     */
    for (i=0; i<3; i++)
       xform_vec[i] = unit_vector[i] * (*distance);
    
    success = MAtrlmx(&msg_loc, xform_vec,(IGRdouble *)xform_mat);
    EMerr_hndlr (!success || (msg_loc != MSSUCC), *EFmsg, EMS_E_BSerror,wrapup);
    
    /* find out the type of the matrix */
    success = MAtypemx(&msg_loc, (IGRdouble *)xform_mat, &xform_mattype);
    EMerr_hndlr (!success || (msg_loc!= MSSUCC), *EFmsg, EMS_E_BSerror, wrapup);
    
    /* GRxform TRANSFORMS THE ORIGINAL CURVES THEMSELVES AND NO NEW OBJECTS 
     * ARE CREATED. 
     * Translate both the original profile and the modified profile. The 
     * output parameter "objid" will be same as the targetid in both cases.
     */
    if (prof.objid != NULL_OBJID)
    {
      sts = om$send (msg = message GRgraphics.GRxform(
               &msg_loc, const_md_env, &xform_mattype, xform_mat, &objid),
                      senderid = NULL_OBJID,
                      targetid = prof.objid,
                      targetos = prof.osnum);
      EMerr_hndlr (!(1&sts&msg_loc) || (objid != prof.objid), 
                     *EFmsg, EMS_E_Fail, wrapup);

      offset_prof.objid = objid;
      offset_prof.osnum = prof.osnum;
      prof.objid = NULL_OBJID; /* checked at wrapup*/
    }
 

    sts = om$send (msg = message GRgraphics.GRxform(
               &msg_loc, const_md_env, &xform_mattype, xform_mat, &objid),
                      senderid = NULL_OBJID,
                      targetid = ext_prof.objid,
                      targetos = ext_prof.osnum);
    EMerr_hndlr (!(1&sts&msg_loc) || (objid != ext_prof.objid), 
                     *EFmsg, EMS_E_Fail, wrapup);

    offset_ext_prof.objid  = objid;
    offset_ext_prof.osnum  = ext_prof.osnum;
    ext_prof.objid = NULL_OBJID; /* checked at wrapup*/

  }
  else /* offset (instead of translate) both the profiles */
  {
    
    /* offset both profiles. (i==1) is original profile and (i==0) is the
     * extended profile. Note the uppper index of "i" depends on whether 
     * "profile" is input as NULL or not.
     */
    for (i=0; i< (prof.objid==NULL_OBJID?1:2) ; i++)
    {
      curr_prof  = (i==0? &ext_prof : &prof);
      moved_prof = (i==0? &offset_ext_prof : &offset_prof );
 
      sts = om$get_classid (osnum = curr_prof->osnum, objid=curr_prof->objid,
                      p_classid = &prof_class_id);
      EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);
 
      sts = om$is_ancestry_valid (subclassid   = prof_class_id,
                            superclassid = OPP_EMScomposite_class_id);
      EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);
 
      if (sts == OM_S_SUCCESS) /* if profile is a composite */
      { sts = om$get_channel_count(p_chanselect = &to_components,
                   objid = curr_prof->objid, osnum = curr_prof->osnum,
                   count = (OMuint *) (&num_curves));
        EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);
      }
      else 
        num_curves = 1;
 
      /* declare an array of "off_codes" for the offset. Each curve will have 
       * the same value (BSCONSTOFF) of offset_type.
       * (allocing variable "off_code" twice (i=0&1), hope this is OK)
       */
      off_code = (IGRint *) alloca (sizeof (IGRint) * num_curves);
      for (j=0; j<num_curves; j++)
        off_code[j] = BSCONSTOFF;
 
      sts = om$send (msg= message GRcurve.EMcvoffset(&msg_loc,
                            &mat_type, mat, construct_list,
                            distance,
                            vector,
                            *offset_right,
                            TRUE, off_code,
                            FALSE, TRUE,
                            moved_prof,
                            NULL,NULL,NULL/* Not used as far as I can see*/),
                 senderid = NULL_OBJID,
                 targetid = curr_prof->objid,
                 targetos = curr_prof->osnum);
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
 
       /* since we will be working with the moved profiles from now on,
        * delete the copied profiles (i.e. copies of incoming profiles).
        */
       sts = om$send (msg = message GRgraphics.GRdelete(&msg_loc, const_md_env),
                  senderid = NULL_OBJID,
                  targetid = curr_prof->objid,
                  targetos = curr_prof->osnum); 
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
      
       /* Now that original copy has been deleted, set the id to NULL, else
        * it will try deleting again at wrapup.
        */ 
        curr_prof->objid = NULL_OBJID;

     }/*for i*/

   }/*else*/

  
  if ((offset_prof.objid != NULL_OBJID) && offset_profile_endpts)
  {
    
     sts = om$send (msg = message GRcurve.GRendpts(&msg_loc, 
                                 &mat_type, mat, 
                                offset_profile_endpts[0], 
                                offset_profile_endpts[1]), 
                 senderid = NULL_OBJID,
                 targetid = offset_prof.objid,
                 targetos = offset_prof.osnum);
     EMerr_hndlr (!(1&sts) || (msg_loc != MSSUCC), *EFmsg, EMS_E_Fail, wrapup);

  }
  if ((offset_ext_prof.objid!= NULL_OBJID) && offset_ext_profile_endpts)
  {

     sts = om$send (msg = message GRcurve.GRendpts(&msg_loc, 
                                 &mat_type, mat, 
                                offset_ext_profile_endpts[0], 
                                offset_ext_profile_endpts[1]), 
                 senderid = NULL_OBJID,
                 targetid = offset_ext_prof.objid,
                 targetos = offset_ext_prof.osnum);
     EMerr_hndlr (!(1&sts) || (msg_loc != MSSUCC), *EFmsg, EMS_E_Fail, wrapup);

  }


  /* intersect the offset of the (input) extended profile with the base solid */

  num_alloc_slots=0; /*number of allocated memory slots for function use*/
  num_inter=0; /* Initialize. IMPORTANT*/

  sts = om$send(msg = message EMSsurface.EMcrvsrfint(
            &msg_loc,
            NULL, /* no need to construct objects out of intersections */
            &(base_solid_env->md_env), 
            NULL, /* not passing in the geometry */
            &offset_ext_prof, /* curve's GRid*/
            &(const_md_env->md_env), /* curve's GRmdenv_info */
            FALSE,/* dont need intersections in hole areas of surface */
            &num_alloc_slots, /* I, the caller, am NOT allocating any memory */
            &num_inter, /* number of intersections */
            NULL, /* intersection points are NOT to be converted into objects */
            NULL, /** DO NOT need UV intersection data on the solid */
            &cv_ints_uv,     /* UV  intersection data on the curve */
            NULL, /* DO NOT need XYZ intersection data on the curve */
            NULL), /* DO NOT need int. props of int. pt wrt surface edges */
                   senderid = NULL_OBJID,
                   targetid = base_solid->objid,
                   targetos = base_solid->osnum);
  EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, msg_loc, wrapup);



  /* store the endpts of the first and last component of the orig. profile */

  if (offset_prof.objid != NULL_OBJID)
  {
    num_orig_comps = 0;
    orig_comps = NULL;
    EFget_lowest_components(&msg_loc,&offset_prof, &num_orig_comps, &orig_comps,
                             NULL, NULL, NULL);
    EMerr_hndlr (!(1&msg_loc), *EFmsg, msg_loc, wrapup);

    for (i=0; i<2; i++)
    {
        cvid= (i==0? orig_comps[0]  : orig_comps[num_orig_comps-1]);
        cvos= offset_prof.osnum;

        sts = om$send (msg = message GRcurve.GRendpts(&msg_loc,
                                   &mat_type, mat, 
                                   (i==0? orig_startpts[0] : orig_endpts[0]), 
                                   (i==0? orig_startpts[1] : orig_endpts[1])),
                   senderid = NULL_OBJID,
                   targetid = cvid,
                   targetos = cvos);
       EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
    }
 }

  /* Get the components of the offset extended profile */

  num_ext_comps = 0;
  ext_comps = NULL;
  EFget_lowest_components(&msg_loc,&offset_ext_prof, &num_ext_comps, &ext_comps,
                             NULL, NULL, NULL);
  EMerr_hndlr (!(1&msg_loc), *EFmsg, msg_loc, wrapup);


  for (i=0; i<num_ext_comps; i++)
  { 
    num_pars = 0; /* no intersection parameters on this component, assume */
    current_comp.objid = ext_comps[i];
    current_comp.osnum = offset_ext_prof.osnum;
    cv_pars = NULL;
    curve_geom  = NULL;

    first_component    = (i==0);
    last_component     = (i==(num_ext_comps-1));
 
    curve_geom = NULL;
    sts = EMgetvggeom(&msg_loc, &mat_type, mat, &current_comp, 
                      (IGRchar **)&curve_geom, NULL);
    EMerr_hndlr(!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
 
    /* get the knot tolerance for the curve */
    (void)BScvkttol2(curve_geom->order,curve_geom->knots, curve_geom->num_poles,
             curve_geom->poles, curve_geom->rational?(curve_geom->weights):NULL,
             &knot_tol, &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

    /* get the endpts of this component*/
    sts = om$send (msg = message GRcurve.GRendpts(&msg_loc, 
                                 &mat_type, mat, startpt, endpt),
                 senderid = NULL_OBJID,
                 targetid = current_comp.objid,
                 targetos = current_comp.osnum);
    EMerr_hndlr (!(1&sts) || (msg_loc != MSSUCC), *EFmsg, EMS_E_Fail, wrapup);
  
    /* check if they match with any pair of endpts of the orig offset profile */

    if ((offset_prof.objid!=NULL_OBJID) && (first_component || last_component))
    {
      fully_overlap            = FALSE;
      startpt_match            = FALSE;
      endpt_match              = FALSE;

      if (first_component)
      {
        if (BSdistptpts(&rc, startpt, orig_startpts[0]) < cht_tol_sq)
            startpt_match = TRUE;

        if (BSdistptpts(&rc, endpt,   orig_startpts[1]) < cht_tol_sq)
            endpt_match   = TRUE;

        if (startpt_match && endpt_match)
            fully_overlap = TRUE;
      }
      else if (last_component)
      {
        if (BSdistptpts(&rc, startpt, orig_endpts[0]) < cht_tol_sq)
             startpt_match = TRUE;
        if (BSdistptpts(&rc, endpt,   orig_endpts[1]) < cht_tol_sq)
             endpt_match   = TRUE;

        if (startpt_match && endpt_match)
            fully_overlap = TRUE;
 
      }
  
      /* No need to check for error. BSdistptpts ALWAYS returns success*/
      EMerr_hndlr (rc!=BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

    }
    else
    {
       /* we need to check for overlap with EVERY single OUT segment of this 
        * component. This "else" case is used to force a a match with intobjs
        * that overlaps the OUT segments of this component. If "offset_prof" had
        * been input, this would be same as saying that this component exactly 
        * overlaps a component of "offset_prof".
        */

       fully_overlap = TRUE;
    }

    /* Collect all the upars for this particular component.*/
    num_cv_pars = 0;
    for (j=0; j<num_inter; j++)
       if (cv_ints_uv[j].leaf_id.objid == current_comp.objid)
          num_cv_pars++;

    /* allocate two extra spaces in the array, since we might have to include 
     * the endpts of the segment too.
     */
    cv_pars = (IGRdouble *) om$malloc (size = sizeof(IGRdouble) * 
                                                      (num_cv_pars+2));
    EMerr_hndlr (!cv_pars, *EFmsg, EMS_E_NoDynamicMemory, wrapup);
 
    if (num_cv_pars)
    { 
      num_cv_pars = 0;
      for (j=0; j<num_inter; j++)
         if (cv_ints_uv[j].leaf_id.objid == current_comp.objid)
            cv_pars[num_cv_pars++] = cv_ints_uv[j].u;

      /* sort the pars in ASCENDING order*/
      (void) BSmergesort(cv_pars,num_cv_pars,&rc); /* Always returns success */

      /* if there is NO intersection at either endpt, then introduce the endpt
       * parameter (0 or 1) so that we may check every segment of this curve
       * for overlap with intobjs.
       */
      if (ABS_FLOAT(cv_pars[0]) > knot_tol)
      {
         OM_BLOCK_MOVE (&cv_pars[0], &cv_pars[1], sizeof (IGRdouble) * 
                                                    num_cv_pars);
         num_cv_pars++;
         cv_pars [0]                    = 0.0;
      }
      if (ABS_FLOAT(cv_pars [num_cv_pars-1] - 1.0) > knot_tol)
      {
         num_cv_pars++;
         cv_pars [num_cv_pars-1]        = 1.0;
      }
    }
    else 
    {  num_cv_pars = 2; /* check WHOLE segment for overlap with intobjs*/
       cv_pars [0]                    = 0.0;
       cv_pars [1]                    = 1.0;
    }


    if (fully_overlap)
    {   /* everything is fine. Nothing to be done here.*/
    }
    else if (startpt_match)
    {  
       /* project the ENDPT of the original curve onto this segment and keep
        * all parameters upto and including the first one AFTER the projected
        * endpt, assuming the parameters are pre-sorted in ascending order. 
        * This is same as saying that the profiles are extended upto the
        * FIRST intersection with the solid at its endpt.
        */
       (void) EFmodify_cv_pars (&msg_loc, curve_geom, cv_pars, &num_cv_pars, 
                                  knot_tol, NULL, orig_endpts[1]);
       EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

    }
    else if (endpt_match)
    {  
       /* project the STARTPT of the original curve onto this segment and keep
        * all parameters starting from the first one BEFORE the projected endpt,
        * assuming the parameters are pre-sorted in ascending order.
        * This is same as saying that the profiles are extended upto the
        * FIRST intersection with the solid at its startpt.
        */
       (void) EFmodify_cv_pars (&msg_loc, curve_geom, cv_pars, &num_cv_pars, 
                                  knot_tol, orig_startpts[0], NULL);
       EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

    }
    else
    { 

       /* This is a special case. In all other extension cases, there will
        * be a match between at least ONE endpt of the extended profile and the 
        * orig. profile. If none exists, then this is like an extension segment
        * for a single linear segment. In this case, project both endpts of the
        * orig profile onto the extension segment. Keep all parameters between
        * the FIRST one BEFORE the projected startpt point and the FIRST one 
        * AFTER the projected endpt.
        */
       (void) EFmodify_cv_pars (&msg_loc, curve_geom, cv_pars, &num_cv_pars, 
                               knot_tol, orig_startpts[0], orig_endpts[1]);
       EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
    }

    /* pass the array of cv_pars and to the check intobj overlap function along
     * with the XYZ geometry of this component. The matching intobjs get 
     * marked/unmarked as needed at this point.
     */

    if (num_cv_pars)
    {
       /* REMOVE construct_list argument after debugging is done*/
       sts = EFcheck_intobj_overlap (&msg_loc, curve_geom, cv_pars, num_cv_pars,
                check_present_bits, check_absent_bits, mark_bits, unmark_bits, 
                inters, base_solid, inters_env, &num_matches, NULL, 
                construct_list);
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);
    }
    /* free array of curve parameter and the curve geom */

    if (curve_geom)
    { om$dealloc (ptr = curve_geom);
      curve_geom = NULL;/* need this, else will try freeing again at wrapup*/
    }
    
    if (cv_pars)
    { om$dealloc(ptr = cv_pars);
      cv_pars = NULL; /* need this, else will try freeing again at wrapup*/
    }

  }/*for "num_ext_comps"*/

  
  /* check if the modified profiles are needed by the calling function*/
  if (offset_profile)
  {
     *offset_profile = offset_prof;
     offset_prof.objid = NULL_OBJID;/* so that it doesnt get deleted below*/
  }
  if (offset_ext_profile)
  {
     *offset_ext_profile = offset_ext_prof;
     offset_ext_prof.objid = NULL_OBJID;/* so that it doesnt get deleted below*/
  }
            
  wrapup:
  
  /* free the intersection data */
  if (cv_ints_uv)
   om$dealloc (ptr=cv_ints_uv);
  if (sol_ints_uv)
   om$dealloc (ptr=sol_ints_uv);
  if (cv_ints_xyz)
   om$dealloc (ptr=cv_ints_xyz);
  if (int_props)
   om$dealloc (ptr=int_props);

  if (curve_geom)
    om$dealloc (ptr = curve_geom);

  if (cv_pars)
    om$dealloc(ptr = cv_pars);

  /* delete the copies of the input profiles */
  if (prof.objid != NULL_OBJID)
  {  sts = om$send (msg = message GRgraphics.GRdelete (&msg_loc, const_md_env),
                  senderid = NULL_OBJID,
                  targetid = prof.objid,
                  targetos = prof.osnum);
  }
  if (ext_prof.objid != NULL_OBJID)
  {  sts = om$send (msg = message GRgraphics.GRdelete (&msg_loc, const_md_env),
                  senderid = NULL_OBJID,
                  targetid = ext_prof.objid,
                  targetos = ext_prof.osnum);
  }
  if (offset_prof.objid != NULL_OBJID)
  {  sts = om$send (msg = message GRgraphics.GRdelete (&msg_loc, const_md_env),
                  senderid = NULL_OBJID,
                  targetid = offset_prof.objid,
                  targetos = offset_prof.osnum);
  }
  if (offset_ext_prof.objid != NULL_OBJID)
  {  sts = om$send (msg = message GRgraphics.GRdelete (&msg_loc, const_md_env),
                  senderid = NULL_OBJID,
                  targetid = offset_ext_prof.objid,
                  targetos = offset_ext_prof.osnum);
  }

  if (orig_comps)
     om$dealloc(ptr = orig_comps);

  if (ext_comps)
     om$dealloc(ptr = ext_comps);

  EMWRAPUP( *EFmsg, sts, "In EFmark_trace_intobjs");   
  return (sts);
  
}

/******************************************************************************/
/* This function takes in an array of cv_pars, which are the intersections of
 * the extended profile with the base solid. The overlap with the original 
 * profile is passed in as two endpts. The job of this function is to re-arrange
 * the parameters such that it retains all intersections between startpt and
 * endpt, and the first one to the left of startpt and the first one to the
 * right of endpt. It is assume dthat the array is sorted in ascending order. 
 * The final output will also be in ascending order.
 *
 * Special cases:
 *
 *  If the startpt is NULL, then it takes all the paramters upto the projection
 *          of endpt and ONE more after that.
 *  If the endpt is NULL, it takes the first parameter to the left of the 
 *      projected startpt and all the rest that follow after that.
 *  If both are NULL, it simply returns the input back.
 */

static void EFmodify_cv_pars (EFmsg, cv_geom, cv_pars, num_cv_pars, knot_tol, 
                                startpt, endpt)
IGRlong *EFmsg;
IGRdouble *cv_pars;
IGRpoint startpt, endpt;
IGRlong *num_cv_pars;
struct IGRbsp_curve *cv_geom;
IGRdouble knot_tol;
{
  IGRlong sts, i, loc_num_cv_pars;
  IGRdouble startpar, endpar;
  IGRboolean success, on_cv, found_location;
  BSrc rc;

  sts    = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;



  /* NOTE:We are operating on an array that has been sorted in ASCENDING order*/
  if (startpt)
  {
    success =  BSprptoncv(&rc, cv_geom, startpt, &startpar, &on_cv);
    EMerr_hndlr (!success || !on_cv || rc!=BSSUCC, *EFmsg, EMS_E_BSerror, 
                 wrapup);


    /* if the startpt happens to coincide with the FIRST parameter, then we 
     * need to keep ALL the parameters.
     */

    if (ABS_FLOAT (startpar - cv_pars[0]) > knot_tol)
    { 
      loc_num_cv_pars = *num_cv_pars;
      found_location = FALSE;
      for (i=0; i<(loc_num_cv_pars-1); i++)
      {
         /* if the startpar matches next par OR if the startpar lies between 
          * current and next par then keep all parameters from current par 
          * onwards.
          */
         if ((((startpar-cv_pars[i])>knot_tol) && 
                                     ((cv_pars[i+1]-startpar)>knot_tol)) 
                                    ||
              (ABS_FLOAT (startpar - cv_pars[i+1]) < knot_tol)  )
         {
           OM_BLOCK_MOVE (&cv_pars[i], &cv_pars[0], sizeof(IGRdouble) *
                                                     ((*num_cv_pars)-i)   );
           *num_cv_pars -= i;
           found_location = TRUE;
           break;
         }
      } 
      EMerr_hndlr (!found_location, *EFmsg, EMS_E_Fail, wrapup);
    }
  }/*if*/
   
  if (endpt)
  {
    success =  BSprptoncv(&rc, cv_geom, endpt, &endpar, &on_cv);
    EMerr_hndlr (!success || !on_cv || rc!=BSSUCC, *EFmsg, EMS_E_BSerror, 
                 wrapup);

    /* if the endpt happens to coincide with the LAST parameter, then we 
     * need to keep ALL the parameters.
     */

    if (ABS_FLOAT (endpar - cv_pars[(*num_cv_pars)-1]) > knot_tol)
    {
 
      loc_num_cv_pars = *num_cv_pars;
      found_location = FALSE;
      for (i=0; i<(loc_num_cv_pars-1); i++)
      {
         /* if the endpar matches current par OR if the endpar lies between 
          * current and next par then keep all parameters upto next par.
          */
         if ( (ABS_FLOAT (endpar - cv_pars[i]) < knot_tol) 
                                || 
              (((endpar-cv_pars[i])>knot_tol) && 
                                       ((cv_pars[i+1]-endpar)>knot_tol)) )
         {
           *num_cv_pars = i+2;
           found_location = TRUE;
           break;
         }
      } 
      EMerr_hndlr (!found_location, *EFmsg, EMS_E_Fail, wrapup);
    }
  }

wrapup:
  
  EMWRAPUP( *EFmsg, sts, "In EFmodify_cv_pars");   

}

/*
 * "construct list" is used ONLY in DEBUG for display purposes, and can be 
 * otherwise passed in as NULL. Even IN debug, if construct list is NULL, then
 * display of overlapping intobjs is simply skipped.
 */
#ifdef __STDC__
#argsused
#else
/*ARGSUSED*/
#endif

IGRlong EFcheck_intobj_overlap (EFmsg, curve, cv_pars, num_cv_pars, 
           check_present_bits, check_absent_bits, mark_bits, unmark_bits, 
           inters, base_solid, modenv, num_matches, lentol, construct_list)
IGRlong *EFmsg; 
struct IGRbsp_curve *curve;
IGRdouble *cv_pars;
IGRlong check_present_bits, check_absent_bits, mark_bits, unmark_bits;
IGRlong  num_cv_pars, *num_matches;
struct EMSinters *inters;
struct GRid *base_solid;
struct GRmd_env *modenv;
IGRdouble *lentol;
struct GRvg_construct *construct_list;
{

  BSrc rc;
  IGRlong num_pts;
  IGRlong i,j, num_points_on_solid, num_segments_on_solid;
  IGRulong pt_loc;
  IGRlong sts, msg_loc;
  struct EMSinters *inters_loc;
  struct EMSintobj *intobj_loc;
  struct EMSpypoint *projected_pts;
  IGRpoint xyz_pt, samplepts[3], check_point;
  IGRdouble mindist[3], tol, *mat, cum_dist;
  IGRshort mat_type;
  IGRboolean success, possible_duplicate, done, check_this_segment, cv_on_solid;
  IGRboolean coplanar_segment;

  
  sts    = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;
 
  *num_matches = 0; /*initialize at beginning */

  mat = modenv->md_env.matrix;
  mat_type = modenv->md_env.matrix_type;

  /* default tolerance is chord-height???*/
  if (lentol)
    tol = *lentol;
  else
  { BSEXTRACTPAR (&rc, BSTOLCHRDHT, tol);
  }


  /* allocate memory for and create projected pts linked list */
  /* CHANGE THIS TO "NUM_SAMPLEPTS" AT SOME POINT OF TIME?*/

  projected_pts = (struct EMSpypoint *) alloca ( 3 * sizeof(struct EMSpypoint));
  EMerr_hndlr(!projected_pts, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  projected_pts[0].next = &(projected_pts[1]);
  projected_pts[1].next = &(projected_pts[2]);
  projected_pts[2].next = NULL;

  /* assume the whole curve does NOT lie ON the solid */
  cv_on_solid = FALSE;

  num_segments_on_solid = 0; /*assume*/

  for (i=0; i<(num_cv_pars-1); i++)  /* num_segments = num_pars -1  */
  {
    /* The XYZ values of the two endpts are known.  Extract the XYZ value of 
     * the midpt of this segment. A three-point match is considered good 
     * enough for checking overlap. We want ALL the following to be true:
     *   1. The first end of the segment MUST map to AN endpt of the intobj
     *   2. The other end of the segment MUST map to the OTHER endpt of the 
     *      intobj
     *   3. The midpt of the segment MUST map to the MIDDLE of the intobj
     * These conditions will give us the correctly overlapping intobj and will
     * not catch spurious degenerate intobjs etc. (although there should NOT be
     * any degenerate intobjs at this stage).
     */
    BScveval(curve, cv_pars[i], NULL, &xyz_pt,&rc);
    EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
    OM_BLOCK_MOVE (xyz_pt, samplepts[0], sizeof (IGRpoint));
    
    BScveval(curve, (cv_pars[i] + cv_pars[i+1])/2.0 , NULL, &xyz_pt,&rc);
    EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
    OM_BLOCK_MOVE (xyz_pt, samplepts[1], sizeof (IGRpoint));

    BScveval(curve, cv_pars[i+1], NULL, &xyz_pt,&rc);
    EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
    OM_BLOCK_MOVE (xyz_pt, samplepts[2], sizeof (IGRpoint));

    /* check if this segment is degenerate, i.e. all three points are within 
     * chord height of each other. If so, skip checking this segment against tho     * intobjs.
     *  CHORD HT DEGENERACY OK???
     */
    num_pts = 3; 
    success = BScumdist(&rc,&num_pts,(IGRdouble *)samplepts,NULL,&cum_dist);
    EMerr_hndlr((rc != BSSUCC) || !success, *EFmsg, EMS_E_BSerror, wrapup);

    if (cum_dist < tol)
    { /* Degenerate segment. Ignore this*/
      /* IGNORING THIS OK?? */
#ifdef DEBUG
      printf ("Ignoring degenerate segment for intobj overlap check \n");
#endif
      continue;
    }

    done = FALSE;
    num_points_on_solid=0;
    check_this_segment = FALSE;
    coplanar_segment = FALSE;

    for (j=0; j<3 && !done; j++)
    {
      /* use midpt of segment for pt location check by default. If that fails,
       * then use the endpts.
       */
      OM_BLOCK_MOVE (samplepts[(j==0?1:(j==1?0:2))], check_point, 
                      sizeof(IGRpoint));
      pt_loc = NULL;
      sts = om$send (msg = message EMSsolid.EMpoint_locate (&msg_loc,
                      modenv, NULL/*unused*/, check_point, NULL, &pt_loc),
                  senderid = NULL_OBJID,
                  targetid = base_solid->objid,
                  targetos = base_solid->osnum);
      EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
  
      if (pt_loc == EMS_S_INSOLID)
      { done = TRUE; 
        check_this_segment = FALSE; /* we dont want this segment */
      }
      else if (pt_loc == EMS_S_ONSOLID)
      {
         num_points_on_solid++; 
         continue; /* On cases are ignored. Move on to next sample point */
      }
      else if (pt_loc == EMS_S_UNKNOWN)
      {  
         continue; /* Ambiguous. Check with another point on segment.*/
      }
      else 
      {
        done=TRUE;
        check_this_segment = TRUE;
      }

    }/*for*/

    if (!done)
    { /* all three points could not be classified as IN or OUT of the solid and
       * we know that this segment is NOT degenerate. If all 3 points lie ON the
       * solid, that means this entire segment lies ON the solid (assuming 3 
       * pts is good enough for this check).  The way the rib intersection 
       * algorithm is written, it is as if any rib surface that is coplanar 
       * with a base solid surface is deemed to be PUSHED into the volume of the
       * latter, which means that we generate NO intersections on the rib 
       * surface with the co-planar surface of the base solid, but instead
       * generate intersections with the "common-surfaces" of the base-solid-
       * planar-surface" to simulate the "pushing-into-volume". We need to 
       * realize that since the rib surfaces are intersected one by one, an 
       * intersection on the co-planr base-solid surface above may be generated
       * by another surface of the rib. Since the curves/profiles that come into
       * this function can be looked at simply as bounding curves of the top 
       * surface of the final rib, generating an intersection on a plane of the 
       * base solid that is coplanar with the rib top surface will simulate an
       * intersection that should not be there.
       * Therefore we identify such coplanar intersections by means of this 
       * current coplanar segment and delete those intobjs.  (NP 10/26/93)
       */
      if (num_points_on_solid == 3)
      {

         /*  DO NOT exit the function at this stage, as there might be other 
          *  segments we have not checked for overlap with intobjs. If the WHOLE
          *  incoming segment is ON the solid, THEN return the InvalidArg 
          *  info code back.
          *  EMerr_hndlr(TRUE, *EFmsg, EMS_I_InvalidArg, wrapup);
          */
         coplanar_segment = TRUE;
         check_this_segment = TRUE;
         num_segments_on_solid++;
         if (num_segments_on_solid == (num_cv_pars-1)) /*ALL segments ON solid*/
         {
            cv_on_solid=TRUE;
           
            /** EMerr_hndlr(TRUE, *EFmsg, EMS_I_InvalidArg, wrapup);  **/
          
         }
      }
      else
      {
         EMerr_hndlr(TRUE, *EFmsg, EMS_E_Fail, wrapup);
      }
    }

    if (check_this_segment)
    {
      inters_loc = inters;
      while (inters_loc)
      {
        intobj_loc = inters_loc->cvs;
        while (intobj_loc)
        { /* check only those intobjs that have the "check_present_bits" set and
           * "check_absent_bits" NOT set. This will improve the efficiency. 
           * Also, to increase efficiency check if the "mark_bits" are already
           * set and the "unmark_bits" not set. This will reduce unnecessary 
           * checking of intobjs that have already been marked by virtue of 
           * being the "other_intobj_node" of an overlapping intobj.
           */


          if(
            ((check_present_bits? (intobj_loc->props&check_present_bits):TRUE)&&
             (check_absent_bits ?!(intobj_loc->props&check_absent_bits) :TRUE)&&
             (mark_bits         ?!(intobj_loc->props&mark_bits)         :TRUE)&&
             (unmark_bits       ? (intobj_loc->props&unmark_bits)       :TRUE)))
          {

            /* maybe optimize by projecting one point at a time? */
            sts = EMprojectpt (&msg_loc, mat_type, mat,
                       &intobj_loc->this_xyzintobj, 3, (IGRdouble *)samplepts, 
                       tol, projected_pts, mindist);
            EMerr_hndlr (!(1&msg_loc&sts), *EFmsg, EMS_E_Fail, wrapup);
   
            possible_duplicate = TRUE;
            for (j=0; j<3; j++)
            {
               if (mindist[j] > tol) /* use "tol" or "2*tol" ????*/
               {
                  possible_duplicate = FALSE;
                  break;
               }
            }
   
            if (possible_duplicate)
            {


#ifdef MORE_RIGOROUS_CHECK_FOR_OVERLAP
             /*
              *  To HAVE or NOT TO HAVE this..... THAT is the Question......
              *  Make doubly sure by checking the props of the projected points
              */

               if ( !(( (projected_pts[0].props&EMS_PYPT_ATSTART && 
                         projected_pts[2].props&EMS_PYPT_ATSTOP)     || 
                        (projected_pts[0].props&EMS_PYPT_ATSTOP  &&
                         projected_pts[2].props&EMS_PYPT_ATSTART) )  &&
                         projected_pts[1].props&EMS_PYPT_ATMIDDLE))
                       
                       goto loc_end;   /*NEXT intobj */
#endif





#ifdef WANT_TO_DISPLAY_MATCHING_INTOBJS
                 if (construct_list)
                 {
                   for (j=0; j<3; j++)
                   {  
                     construct_list->display->color++;
                     construct_list->display->weight +=2;
                     ECdisplayPointSetByBuffer(&msg_loc,
                              *(construct_list->display), 
                              *(construct_list->env_info), NULL_OBJID, 1, 
                              &(projected_pts[j].point), TRUE);
                     construct_list->display->color--;
                     construct_list->display->weight -=2;
                     EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
                   }
                 }
#endif
     
                 /* Finally found the sucker. Mark it as required. If this was
                  * a coplanar segment, then by virtue of the above argument,
                  * all matching intobjs should be deleted.
                  */
                 (*num_matches)++;

                 if (coplanar_segment)
                 {
                    intobj_loc->props |= EMSintobj_deletable;
                    if (intobj_loc->other_intobj_node)
                       intobj_loc->other_intobj_node->props |= 
                                                          EMSintobj_deletable;
                 }
                 else
                 { intobj_loc->props |= mark_bits ; 
                   intobj_loc->props &= ~unmark_bits; 
                   /* mark the other intobj node too, if it exists*/
                   if (intobj_loc->other_intobj_node)
                   { intobj_loc->other_intobj_node->props |= mark_bits;
                     intobj_loc->other_intobj_node->props &= ~unmark_bits;
                   }
                 }

            }/*if "possible_duplicate"*/

          }/*if intobj meets all criteria for checking overlap*/
  
#ifdef MORE_RIGOROUS_CHECK_FOR_OVERLAP
          loc_end:
#endif
          intobj_loc = intobj_loc->next;

        }/*while "intobj_loc"*/
    
        inters_loc = inters_loc->next;    

      }/*while "inters_loc"*/

    }/*if "check_this_segment"*/

  }/*for*/

  /* before exiting, delete all intobjs marked as "deletable" due to the 
   * coplanar logic.
   */


 (void) EMdelintobj_selective(&msg_loc, NULL, inters, EMSintobj_deletable,NULL);
  EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

 
  wrapup:

  EMWRAPUP (*EFmsg, sts, "In EFcheck_intobj_overlap");
  return (sts);
}
/*****************************************************************************/

/* ASSUMPTIONS:
   num_sfs <= 4  is this still valid???????????
   On error, it deletes the output tracedata, so that the calling function 
   does not have to free it.

IMPORTANT:
 - If "out_tracedata" does not exist, "*out_tracedata" MUST be set to NULL
   on input. if "out_tracedata" is sent in as NULL, then trace data is simply 
   not passed back from this function. If "out_tracedata" exists then the trace
   info in this function is appended to it.

*/

IGRlong EFtrace_and_modify_groups(EFmsg, num_sfs, sf_ids, inters, inters_env, 
                                  construct_list, check_present_bits, 
                                  check_absent_bits, altxyztol, altuvtol,
                                  out_tracedata)
IGRlong *EFmsg;
IGRint num_sfs;
struct GRid *sf_ids;
struct EMSinters **inters;
struct GRmd_env  *inters_env;
IGRdouble *altuvtol, *altxyztol;
IGRulong check_present_bits, check_absent_bits;
struct GRvg_construct *construct_list;
struct EMSsftracedata **out_tracedata;
{
  IGRlong sts, msg_loc;
  IGRint i,j, k, m;
  IGRshort mat_type;
  IGRdouble *mat;
  struct EMSinters **new_inters, *inters_loc;
  IGRboolean deleted, out_tracedata_alloced, sfinttrace_alloced;
  OMuword  sf_class;
  OMuint  count, num_components;
  OM_S_CHANSELECT to_components;
  OM_S_OBJECT_LINKAGE *surfaces;
  struct GRid *sf;
  struct EMSsftracedata tracedata, tmp_tracedata;
  struct EMSintobj *intobj_loc, *intobj_next;
  void EFdelete_bad_trace_groups();
 
  *EFmsg = EMS_S_Success;
  sts   = OM_S_SUCCESS;

  mat          = inters_env->md_env.matrix;
  mat_type     = inters_env->md_env.matrix_type;

  sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_Fail, wrapup);

  /* INITIALIZATIONS */
  sfinttrace_alloced    = FALSE;
  out_tracedata_alloced = FALSE;

  /* 
   *  1. Separate the inters out in the beginning.
   *  2. Later merge the inters back.
   */

  /*allocate memory for the split inters list*/
  new_inters=(struct EMSinters **)alloca(num_sfs * sizeof(struct EMSinters *));

  for (i=0; i< num_sfs; i++)
  {
    
    new_inters[i] = NULL; /* NO inters ptr corresp. to this (comp.) surface */

    /* check if this surface is a composite */
    sts = om$get_classid (objid = sf_ids[i].objid,
                          osnum = sf_ids[i].osnum,
                          p_classid = &sf_class);
    EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

    sts = om$is_ancestry_valid (subclassid = sf_class,
               superclassid = OPP_EMScompsurf_class_id);  
    if (sts == OM_S_SUCCESS)
    {   /* get ids of each individual surface on this composite */
        sts = om$get_channel_count (objid = sf_ids[i].objid, 
                                    osnum = sf_ids[i].osnum,
                                    p_chanselect = &to_components,
                                    count = &count);
        EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

        surfaces = (OM_S_OBJECT_LINKAGE *) alloca (count *
                                       sizeof(OM_S_OBJECT_LINKAGE));

        sts = om$get_channel_objects (osnum=sf_ids[i].osnum, 
                                      objid=sf_ids[i].objid,
                                      p_chanselect = &to_components,
                                      list=surfaces, 
                                      size=count,
                                      count = &num_components);
        sf = (struct GRid *) alloca (num_components * sizeof(struct GRid));

        for (j=0; j<num_components; j++)
        {
           sf[j].objid = surfaces[j].S_objid;
           sf[j].osnum = surfaces[j].osnum;
        }
    }/*if*/
    else
    {
        num_components = 1;
        sf = (struct GRid *) alloca (1 * sizeof(struct GRid));
        sf[0].objid = sf_ids[i].objid;
        sf[0].osnum = sf_ids[i].osnum;
    }

    /* separate out those inters nodes corresp. to these components */
    for (j=0; j<num_components; j++)
    {
        /* "inters" can (HAS to be) null ONLY after the last surf is processed*/
        EMerr_hndlr(!(*inters), *EFmsg, EMS_E_Fail, wrapup);


       (void)EFtransfer_inters(&msg_loc, &sf[j], inters, &new_inters[i]);
        EMerr_hndlr(!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
    }

  }/* for every (composite) surface */


  /* Make SURE original "inters" is NULL after the last surf is processed*/
  EMerr_hndlr((*inters), *EFmsg, EMS_E_Fail, wrapup);


  out_tracedata_alloced = FALSE;

  for(i=0; i< num_sfs; i++)
  {
 
    /* trace the "new_inters[i]" list. These (possibly composite) surfaces have
     * to be separately traced because otherwise, trace will connect across 
     * these surfaces. Then we cannot get the correct closed topological groups.
     * NOTE: Also of help to the trace fn. are the "EMSintobj_marked" bits, 
     * ----  that will start the trace. The "check_present_bits" HAS TO contain
     *       the "EMSintobj_marked" bits.
     */


    /* Compress this inters list, since some nodes may now be empty due to 
     * deletion of intobjs on other nodes/surfaces (possibly because some/all 
     * intobjs on this surface had been the "other_intobj_node" of deleted 
     * intobjs on another surface).
     *   If all nodes are empty, move on to next inters list.
     */

    EMcmpinters (&msg_loc, &new_inters[i]); 
    if (!new_inters[i])
      continue;

    EMinittrace (&tracedata);
    sfinttrace_alloced           = FALSE;

   EMsfinttrace (&msg_loc, &mat_type, mat, new_inters[i], altuvtol, altxyztol,
                 &tracedata.num_grps, &tracedata.num_subgrps_grp, 
                 &tracedata.num_elems_subgrp, &tracedata.elems,
                 &tracedata.subgrp_rev, &tracedata.elem_rev, 
                 &tracedata.grp_closed, &tracedata.subgrp_closed);

   sfinttrace_alloced           = TRUE;

   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);

   /* set the "fwd" and "bwd" pointers on the intobjs using trace info above, 
    * so that ALL subsequent tracing done on this inters list will be trivial
    * (i.e. geometric end-pt checks between intobjs will be overidden by the
    * "fwd" and "bwd" pointers).
    */

   /* since we do NOT want open groups, we delete intobjs belonging to open
    * groups, which will also lighten the load on the next function that does
    * a loopset split internally. This needs to be done in three steps. First
    * we mark all deletable intobjs as "EMSintobj_deletable", then free the
    * trace data and THEN delete the intobjs. If the intobjs are deleted BEFORE
    * freeing trace data, "EMsfinttrace_free" sometimes crashes, understandably.
    */

   for (j=0; j<tracedata.num_grps; j++)
   {
      if (!tracedata.grp_closed[j])
      { for (k=0; k<(tracedata.num_subgrps_grp[j]); k++)
        {
           intobj_loc = tracedata.elems[j][k];
           for (m=0; m<(tracedata.num_elems_subgrp[j][k]); m++)
           {
             intobj_loc->props |= EMSintobj_deletable;
             intobj_loc  = intobj_loc->next;
           }
        }
      }
   }
   
   /* since the above trace data is now invalid due to deletion of intobjs,
    * we re-create the trace data, after deleting the above tracedata.
    */

   /* Delete the old trace data.*/
   EMfreetrace(&tracedata);
   sfinttrace_alloced = FALSE;
   EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);
   

   /* Now physically delete the deletable intobjs */

   inters_loc = new_inters[i];
   while (inters_loc)
   {
     intobj_loc = inters_loc->cvs;
     while (intobj_loc)
     {
        intobj_next = intobj_loc->next;
        if (intobj_loc->props & EMSintobj_deletable)
        {
          EMdelintobj (&msg_loc, intobj_loc);
          EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);
        }
        intobj_loc  = intobj_next;
     }
     inters_loc=inters_loc->next;
   }

   /* compress the inters here, since some nodes just MIGHT be empty due to the
    * deletion of intobjs above. If there are no non-empty nodes left, move on 
    * to next surface.
    */

   EMcmpinters (&msg_loc, &new_inters[i]); 
   if (!new_inters[i])
      continue;


   /* at this point we have to make one more check. On each surface that has
    * only closed groups, we need to check if there are any closed groups that 
    * are deletable. These will be closed groups that are so oriented that they
    * will try to form an external C-loop on its surface, which is an error. The
    * way to identify such loops is through the expensive process of nesting.
    */

/***** REMOVED. SEE NOTES ABOVE FUNCTION. (NP 12/08/93).
    deleted = FALSE;
    EFdelete_bad_trace_groups(&msg_loc, new_inters[i], inters_env, altuvtol, 
                                  altxyztol, construct_list, &deleted);
    EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);

    if (deleted)
    {
       EMcmpinters (&msg_loc, &new_inters[i]); 
       if (!new_inters[i])
         continue;
    }
***/

   EMinittrace (&tracedata);
   sfinttrace_alloced           = FALSE;

   EMsfinttrace (&msg_loc, &mat_type, mat, new_inters[i], altuvtol, altxyztol,
                 &tracedata.num_grps, &tracedata.num_subgrps_grp, 
                 &tracedata.num_elems_subgrp, &tracedata.elems,
                 &tracedata.subgrp_rev, &tracedata.elem_rev, 
                 &tracedata.grp_closed, &tracedata.subgrp_closed);

   sfinttrace_alloced           = TRUE;

   EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);


   /*** set the fwd/bwd pointers based on the trace info
   EFset_ptr_from_trace_info(&msg_loc, &tracedata);
   EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);
   *****/

   /* now make the call to the selective boolean function to keep only CERTAIN
    * closed topological groups (the ones that contain at least one intobj 
    * that has a certain bitmask), and all groups contained within them.
    */

   if (check_present_bits || check_absent_bits)
   {
      sts = EFspbool_modify_trace_groups(&msg_loc,
                                      construct_list,
                                      inters_env,
                                      &new_inters[i], NULL,
                                      &tracedata, NULL,
                                      NULL, NULL, NULL, NULL, NULL,
                                      check_present_bits, 
                                      check_absent_bits);
  
      if (msg_loc==EMS_E_AllIntersectionsDeleted)
            sfinttrace_alloced=FALSE; /* else it will crash in wrapup, since
                                       * no intobj==>no trace data to free.
                                       */
      EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

/*******
      EFset_ptr_from_trace_info(&msg_loc, &tracedata);
      EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);
*******/

   }

   if (out_tracedata)
   {

      if (*out_tracedata) 
      {
         EMmergetrace (&msg_loc, &tracedata, *out_tracedata, &tmp_tracedata);
         EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);

         /* Now delete the old trace data for "out_tracedata" */
         EMfreetrace (*out_tracedata);
         EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);

         /* move updated trace data to "out_tracedata" */
         (void) EMmovetrace (&tmp_tracedata, *out_tracedata);
          out_tracedata_alloced = TRUE;

         EMinittrace (&tmp_tracedata);
      }
      else
      {
         *out_tracedata = (struct EMSsftracedata *) om$malloc(size=
                                          sizeof(struct EMSsftracedata));
         /* move trace data to "out_tracedata" */
         (void) EMmovetrace (&tracedata, *out_tracedata);
          out_tracedata_alloced = TRUE;

         EMinittrace (&tracedata);
          /* since  "tracedata" is now moved over to "out_tracedata"*/
         sfinttrace_alloced = FALSE;
      }

   }


   if (sfinttrace_alloced)
   {
      /* Now delete the temporary trace data before we move on to next inters */
     EMfreetrace(&tracedata);
     EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);
   
     sfinttrace_alloced = FALSE;
   } 


  }/* for every (composite) surface */


  /* now re-merge the partitioned "new_inters[i]" lists so that we get the 
   * original list back.
   */

  for (i=0; i<num_sfs; i++)
  {
    (void) EMmergeinters (&msg_loc, inters, new_inters[i]);
    EMerr_hndlr(!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
  }


  /* in the process of deleting open groups, if ALL the inters nodes are empty,
   * we need to flag that as an error, since we expect SOMETHING to survive.
   */

  if (!(*inters))
  {
     *EFmsg = EMS_E_AllIntersectionsDeleted;
     goto wrapup;
  }

  wrapup:

  /* on error, free the output trace data right here so that the calling 
   * function does not have to do it.
   */

  if (!(1&sts&*EFmsg))
  {

   if (out_tracedata_alloced)
   {  EMfreetrace (*out_tracedata);
   }
  }

  /* free temporary trace data if not already done so above */
  if (sfinttrace_alloced)
  {
    EMfreetrace (&tracedata);
  }
  
  EMWRAPUP( *EFmsg, sts, "In EFtrace_and_modify_groups");
  return (sts);
}

/**************************************************************************/

void EFset_ptr_from_trace_info(EFmsg, tracedata)
IGRlong *EFmsg;
struct EMSsftracedata *tracedata;
{

 IGRlong sts, msg_loc;
 IGRint  i,j, k, num_subgrps;
 IGRboolean grp_closed, subgrp_closed, last_element;
 IGRboolean subgrp_reversed;
 struct EMSintobj *intobj, *logical_start_intobj, *logical_stop_intobj;
 struct EMSintobj *xyz_start_intobj, *xyz_stop_intobj;
 struct EMSintobj *prev_xyz_stop_intobj;
 struct EMSintobj *fwd_intobj, *first_intobj;


 msg_loc = EMS_S_Success;
 sts     = OM_S_SUCCESS;

/** Q: 1. what if a ingle intobj points to itself thro "fwd" and "bwd" ptr for
          XYZ trace?
**/


 for (i=0; i<tracedata->num_grps; i++)
 {
    grp_closed = tracedata->grp_closed[i];
    num_subgrps= tracedata->num_subgrps_grp[i];

    /* Get the XYZ stop intobj for the LAST subgrp, which will automatically
     * be the "previous" intobj for the XYZ start intobj of the FIRST subgrp.
     */

    if (grp_closed)
    { 
        logical_start_intobj = tracedata->elems[i][num_subgrps-1];
        logical_stop_intobj  = logical_start_intobj;
        for (k=0; k<(tracedata->num_elems_subgrp[i][num_subgrps-1]-1); k++)
            logical_stop_intobj = logical_stop_intobj->next;
        prev_xyz_stop_intobj  = tracedata->subgrp_rev[i][num_subgrps-1]? 
                                    logical_start_intobj : logical_stop_intobj;
    }
    else
    {
      prev_xyz_stop_intobj  = NULL;
    }

    for (j=0; j<tracedata->num_subgrps_grp[i]; j++)
    {
       subgrp_closed   = tracedata->subgrp_closed[i][j];
       subgrp_reversed = tracedata->subgrp_rev[i][j];

       /* For XYZ continuity in trace, we have to connectt up the ends of the 
        * subgrps with "fwd" and "bwd" pointers, without setting any connect
        * or noconnect pointers.
        */
        logical_start_intobj = tracedata->elems[i][j];
        logical_stop_intobj  = logical_start_intobj;
        for (k=0; k<(tracedata->num_elems_subgrp[i][j]-1); k++)
            logical_stop_intobj = logical_stop_intobj->next;

        xyz_start_intobj = subgrp_reversed? logical_stop_intobj :
                                            logical_start_intobj;
        xyz_stop_intobj  = subgrp_reversed? logical_start_intobj :
                                            logical_stop_intobj;

        /* make the "fwd" and "bwd" XYZ trace connections and REMOVE the 
         * corresponding props (since props are for UV connect)
         */

        if (prev_xyz_stop_intobj)
        {  xyz_start_intobj->bwd           =   prev_xyz_stop_intobj; 
           xyz_start_intobj->props        &= ~(EMSintobj_bwd_connectuv|
                                               EMSintobj_bwd_noconnectuv);
           /* SET THE FWD_NOCONNECT BIT???*/
           prev_xyz_stop_intobj->fwd       =   xyz_start_intobj; 
           prev_xyz_stop_intobj->props    &= ~(EMSintobj_fwd_connectuv|
                                               EMSintobj_bwd_noconnectuv);
           /* SET THE BWD_NOCONNECT BIT???*/
        }

        /* reset the "prev_xyz_stop_intobj" to XYZ stop of current subgrp, for
         * the next iteration of the for loop.
         */

        prev_xyz_stop_intobj = xyz_start_intobj;

       /*elements in subgrp are expected to be connected in the LOGICAL 
        * direction of flow on the surface. Therefore, we do not even look at
        * the "intobj->reversed" field. The elements are in the form of a linked
        * list and are NOT indexed by array (except for the first element).
        */

       intobj        = tracedata->elems[i][j];
       first_intobj  = intobj; /*first element in subgroup.*/ 

       for (k=0; k<tracedata->num_elems_subgrp[i][j]; k++)
       {
         last_element  = (k==(tracedata->num_elems_subgrp[i][j]-1)?TRUE:FALSE);
         fwd_intobj    = !last_element? (intobj->next) :
                                        (subgrp_closed?first_intobj:NULL);
         if (fwd_intobj)
         {
           /* make "fwd" and "bwd" connections */
           /* CAN INTOBJ AND FWD_INTOBJ BE SAME????? */
           intobj->fwd        =  fwd_intobj;
           intobj->props     |=  EMSintobj_fwd_connectuv;
           intobj->props     &= ~EMSintobj_fwd_noconnectuv;
           fwd_intobj->bwd    =  intobj;
           fwd_intobj->props |=  EMSintobj_bwd_connectuv;
           fwd_intobj->props &= ~EMSintobj_bwd_noconnectuv;
         }

         intobj = intobj->next; /* go to next intobj in subgrp */

       }/*for, k*/

    }/*for, j*/

 }/*for, i*/

 
  EMWRAPUP( *EFmsg, sts, "In EFset_ptr_from_trace_info");
}

/******************************************************************************/

/* UNUSED FUNCTION:
 * This function was used to clean up an inters list that had bad intobjs which
 * would have caused invalid loops upon imposition. However, this function is 
 * kind of limited in that it took only closed trace groups on the individual
 * surfaces to check for this condition. If a closed trace group spanned many
 * surfaces, it would not handle it. Then, we would have to split the loopset
 * on the surface with the closed groups  AND open subgroups on the surface, 
 * and during splitting and nesting of the loops created from the subgroups, we
 * come across the invalid loops, and hence corresponding invalid subgroups and
 * hence invalid intobjs. BUT, most of this work is already being done in the
 * selective boolean function "EFspbool_modify_trace_groups" (i.e. splitting
 * of loopsets etc), which we are calling anyway. Therefore instead of using
 * this limited function, an option "EMImpBnd_DelInvalidLoops" has been added to
 * the selective boolean function to take care of ALL types of invalid loops.
 * (NP 12/08/93).
 */
void EFdelete_bad_trace_groups(EFmsg, inters, inters_env, altuvtol, altxyztol, 
                                const_list, deleted)
IGRlong *EFmsg;
struct EMSinters *inters;
struct GRmd_env *inters_env;
IGRdouble *altuvtol, *altxyztol;
struct GRvg_construct *const_list;
IGRboolean *deleted;
{

   IGRlong msg_loc, sts, i, j, k;
   IGRdouble *mat;
   IGRshort mat_type;
   IGRushort props, *lpprops;
   IGRboolean world=TRUE, skip_this_surface;
   IGRboolean deletable_intobjs, sfinttrace_alloced, sfintloops_alloced;
   struct EMSsftracedata tracedata;
   IGRdouble **sfpartols, uvtol;
   GRobjid  **loop_sf, **end_edges, *loops;
   struct GRid  this_sf, cp_loopset, *edges;
   struct EMSsfintedpar  ***intedpars;
   OMuint count;
   OM_S_CHANSELECT       chan_to_loopset, to_edges, to_loops, to_inner;
   OM_S_OBJECT_LINKAGE   *looplist, list[1];
   struct EMSpartolbasis partolbasis;
   struct EMSnest_info   nest_info;
   IGRint depth, buf_size, array_size, num_edges, num_loops;
   struct EMSinters *inters_loc, *inters_next, *cp_inters;
   struct EMSintobj *intobj_loc, *intobj_loc2, **orig_intobjs, **cp_intobjs;


   *EFmsg = EMS_S_Success;
   sts    = OM_S_SUCCESS;

   mat        = inters_env->md_env.matrix;
   mat_type   = inters_env->md_env.matrix_type;


   sfinttrace_alloced   = FALSE;
   sfintloops_alloced   = FALSE;
   skip_this_surface    = FALSE;
   *deleted             = FALSE;
   loops                = NULL;
   lpprops              = NULL;
   edges                = NULL;
   cp_inters            = NULL;
   cp_loopset.objid     = NULL_OBJID;
   
 
   sts = EMmake_chanselect(EMSloopset_to_loops, &to_loops);
   EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_Fail, wrapup);
   sts = EMmake_chanselect(EMSloop_to_inner, &to_inner);
   EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_Fail, wrapup);
   sts = EMmake_chanselect(EMSsubbs_to_loopset, &chan_to_loopset);
   EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_Fail, wrapup);
   sts = EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);
   EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_Fail, wrapup);

   EMinittrace (&tracedata);
 

   inters_loc = inters;
   while (inters_loc)
   {

     this_sf = inters->this_obj;
     inters_next = inters_loc->next; 
     inters_loc->next = NULL;
     skip_this_surface = FALSE;
     deletable_intobjs = FALSE;
     loops             = NULL;
     lpprops           = NULL;
     edges             = NULL;
     cp_inters         = NULL;
     cp_loopset.objid  = NULL_OBJID;

     if(!altuvtol)
     {
        sts = om$send(msg = message EMSsubbs.EMpartolbasis (&msg_loc, &mat_type,
                              mat, &world, TRUE, &uvtol),
               senderid = NULL_OBJID,
               targetos = this_sf.osnum,
               targetid = this_sf.objid);
     }
     else
      uvtol = *altuvtol;
     /* trace the intobjs on this surface */
    
     /* first make a copy of the inters node. The node is null-terminated */

     sts =  EMdupinters(&msg_loc, &inters_loc, &cp_inters, TRUE, FALSE, 
                         &this_sf, NULL, FALSE, inters_env, const_list, 
                         NULL, NULL, 0, NULL, NULL, 0);
     EMerr_hndlr (!(sts&msg_loc&1), *EFmsg, EMS_E_Fail, wrapup);

     /* now we need to maintain a correspondence between the intobjs in the
      * original and the copied lists.
      */

    orig_intobjs = (struct EMSintobj **) alloca ((inters_loc->num_cvs) *
                                                 sizeof (struct EMSintobj *)) ;
    EMerr_hndlr (!orig_intobjs, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

    cp_intobjs   = (struct EMSintobj **) alloca ((inters->num_cvs) *
                                                 sizeof (struct EMSintobj *)) ;
    EMerr_hndlr (!cp_intobjs, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

    intobj_loc  = inters_loc->cvs;
    intobj_loc2 = cp_inters->cvs;
    for (i=0; i<inters_loc->num_cvs; i++)
    {  orig_intobjs[i] = intobj_loc;
       cp_intobjs[i]   = intobj_loc2;
       intobj_loc  = intobj_loc->next;
       intobj_loc2 = intobj_loc2->next;
    }

     EMinittrace (&tracedata);

     EMsfinttrace (&msg_loc, &mat_type, mat, cp_inters, altuvtol, altxyztol,
                 &tracedata.num_grps, &tracedata.num_subgrps_grp,
                 &tracedata.num_elems_subgrp, &tracedata.elems,
                 &tracedata.subgrp_rev, &tracedata.elem_rev,
                 &tracedata.grp_closed, &tracedata.subgrp_closed);
     sfinttrace_alloced   = TRUE;

     /* check if there are any open groups. If there ARE any open groups, we 
      * cannot make a clean determination as to which closed trace groups might
      * form external C-loops later and mess things up. Therefore we work on
      * this surface ONLY if it has closed trace groups. Of course, this means 
      * we will not be able to handle some rib cases, but this is done here to
      * that we may handle at least a large majority of them.
      */

     for (i=0; i<tracedata.num_grps; i++)
     {
        if (! (tracedata.grp_closed[i]))
          { skip_this_surface = TRUE; break;}
        if (tracedata.num_subgrps_grp[i] > 1)
          { skip_this_surface = TRUE; break;}
           
     }

     if (!skip_this_surface)
     {

        EMsfintloops (&msg_loc, &mat_type, mat, this_sf.osnum, altuvtol,
               tracedata.num_grps, tracedata.num_subgrps_grp, 
               tracedata.num_elems_subgrp, tracedata.elems, 
               tracedata.subgrp_rev, tracedata.elem_rev,
               tracedata.grp_closed, tracedata.subgrp_closed,
               TRUE, FALSE, &loop_sf, &end_edges, &intedpars, &sfpartols);
        sfintloops_alloced = TRUE;
        EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

        /* get the loopset of this surface */
        
        count = 0;
        sts = om$get_channel_objects (objid = this_sf.objid,
                                osnum = this_sf.osnum,
                                p_chanselect = &chan_to_loopset, 
                                count = &count, size = 1, list = list);
      EMerr_hndlr (!(1&sts) || (count != 1), *EFmsg, EMS_E_Fail, wrapup);

      /* make a copy of the loopset and work on the copy */

      sts = om$send (msg=message EMSboundary.EMtpcopy (&msg_loc, NULL,
                             this_sf.osnum, this_sf.osnum, NULL, 
                             &(cp_loopset.objid)),
                   senderid = NULL_OBJID,
                   targetid = list[0].S_objid,
                   targetos = list[0].osnum);
      EMerr_hndlr (!(sts&msg_loc&1), *EFmsg, EMS_E_LoopsetError, wrapup);
      cp_loopset.osnum = this_sf.osnum;


      /* nest each of the new loops into this loopset */
      for (i=0; i<tracedata.num_grps; i++)
      {
        /* we are assuming here that there will be ONLY ONE subgrp per closed
         * group. That is why we index off of only the group and not the 
         * subgrp (ideally, sfintloops creates a loop for each subgrp).
         */
          partolbasis.is_valid = TRUE;
          partolbasis.tol = uvtol;
          nest_info.loopid = loop_sf[i][0];
          nest_info.lp_props = EMLP_ACTIVE; /*IMPORTANT (ELSE CAUSES PROBLEMS)*/

        /* Initialize the loop by sending the EMlpinit message (P_Loop/C_Loop 
         * property will be set by this message). Setting 'options' to 
         * EMLpInit_NoClosureTest since we know loop is closed.
         */
        sts = om$send (msg = message EMSloop.EMlpinit(&msg_loc, 
				     nest_info.lp_props, &partolbasis,
				     EMLpInit_NoClosureTest),
		senderid = NULL_OBJID,
		targetos = this_sf.osnum,
		targetid = nest_info.loopid );
        EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

        /* Now determine if the Loop is to be nested directly under the loopset.
         * If not get the actual parent (an existing loop in the loopset) under 
         * which it should be nested. Then, accordingly, the loop (child) is 
         * added to the parent using EMtreemod message.
         */
        sts = om$send (msg = message EMSloop.EMgivenestinfo (&msg_loc,
              &nest_info), 
		senderid = NULL_OBJID,
		targetos = this_sf.osnum,
		targetid = nest_info.loopid );
        EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

        sts = om$send (msg = message EMSloopset.EMnesting (&msg_loc,
               &nest_info, &partolbasis),
	       senderid = NULL_OBJID,
	       targetos = cp_loopset.osnum,
               targetid = cp_loopset.objid);
        EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

        /* Since this is a natural loopset, NONE of the new loops should 
         * have the loopset as a nesting parent. The natural loop should
         * be the parent. Therefore the "EMSloop" implementation of the 
         * EMtreemod message is used.
         */
        EMerr_hndlr ((nest_info.parent == cp_loopset.objid),
                     *EFmsg, EMS_E_Fail, wrapup);
        sts = om$send (msg = message EMSloop.EMtreemod (&msg_loc,
                               &nest_info, ADD_CHILD, &partolbasis),
	                 senderid = NULL_OBJID,
	                 targetos = this_sf.osnum,
                         targetid = nest_info.parent);
        EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_LoopError, wrapup);

      }/*for*/

      /* now that all of the loops are nested into the loopset, we need to 
       * delete those loops that will cause trouble later. These are loops that
       * would tend to form external C-loops later on. Any C-loop that is a 
       * child of the natural loop is a candidate for being deleted. Mark all 
       * intobjs that formed this bad loop as deletable.  Then delete all these 
       * intobjs from the inters list. Also delete all the loops created here, 
       * after first disconnecting their edges.
       */

      count = 0;
      sts = om$get_channel_count (objid = cp_loopset.objid,
                                osnum = cp_loopset.osnum,
                                p_chanselect = &to_loops,
                                count = &count);
      /* The loopset should have only a single natural loop */
      EMerr_hndlr (!(1&sts) || (!count) || (count !=1), 
                                         *EFmsg, EMS_E_Fail, wrapup);

      sts = om$get_channel_objects (objid = cp_loopset.objid,
                                osnum = cp_loopset.osnum,
                                p_chanselect = &to_loops,
                                count = &count, size = 1, list = list);
      EMerr_hndlr (!(1&sts) || (!count), *EFmsg, EMS_E_Fail, wrapup);

      /* now get the children of this natural loop. Its one of THESE children 
       * that could potentially cause trouble later.
       */

      sts = om$get_channel_count (objid = list[0].S_objid,
                                osnum = list[0].osnum,
                                p_chanselect = &to_inner,
                                count = &count); 
      EMerr_hndlr (!(1&sts) || (!count), *EFmsg, EMS_E_Fail, wrapup);

      looplist = (OM_S_OBJECT_LINKAGE *) alloca (count * 
                                      sizeof (OM_S_OBJECT_LINKAGE));
      sts = om$get_channel_objects (objid = list[0].S_objid,
                                osnum = list[0].osnum,
                                p_chanselect = &to_inner,
                                count = &count, size = count, list = looplist);
      EMerr_hndlr (!(1&sts) || (!count), *EFmsg, EMS_E_Fail, wrapup);

      for (i=0; i<count; i++)
      {
       sts = om$send (msg = message EMSloop.EMget_props(&msg_loc, &props),
                  senderid = NULL_OBJID,
                  targetid = looplist[i].S_objid,
                  targetos = looplist[i].osnum);
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

       if (!(props&EMLP_PLOOP))
       {
         /* get the edges of this loop as well as ALL loops nested uunder this
          * loop. Find the corresponding intobjs to which the edges belong and
          * mark those intobjs for deletion.
          */
         array_size=0;
         num_edges=0;
         edges = NULL;
         sts = om$send (msg = message EMSloop.EMget_edges (&msg_loc,
                                     MAXINT, EMS_OPT_ALL, &edges, 
                                     &array_size, &num_edges),
                    senderid =  NULL_OBJID,
                    targetid = looplist[i].S_objid,
                    targetos = looplist[i].osnum);
         EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
         for (j=0; j<num_edges; j++)
         {
            intobj_loc = cp_inters->cvs;
            while (intobj_loc)
            { if (intobj_loc->this_uvintobj.data.object->objid==edges[j].objid)
               {
                  for (k=0; k<inters_loc->num_cvs; k++)
                  {
                     if (intobj_loc == cp_intobjs[k])
                     { 
                        orig_intobjs[k]->props |= EMSintobj_deletable;
                        break;
                     }
                  }
                  break;
               }
               intobj_loc = intobj_loc->next;
            }
         }

         deletable_intobjs = TRUE;
       }
      }/*for, i*/

      /* now that our job is done, disconnect all the loops from their edges,
       * (except the natural loop). The reason is that the edges are part of the
       * cp_inters list as well as the loopset. We are deleting the cp_inters 
       * list anyway later. Free the trace data before deleting the intobjs. 
       */

       buf_size=0;
       num_loops=0;
       loops = NULL;
       lpprops = NULL;
       depth = MAXINT;
       sts = om$send (msg = message EMSloopset.EMget_loops (&msg_loc,
                                   EMS_OPT_ALL, &depth, &loops, 
                                   &lpprops, &buf_size, &num_loops),
                  senderid =  NULL_OBJID,
                  targetid = cp_loopset.objid,
                  targetos = cp_loopset.osnum);
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

       for (i=0; i<num_loops; i++)
       {
         if (!(lpprops[i]&EMLP_NATURAL))
         {
           sts = om$send(msg = message Root.wild_disconnect(to_edges),
                                targetid = loops[i],
                                targetos = this_sf.osnum,
                                senderid = NULL_OBJID);
           EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_OMerror, wrapup);
         }
       }

       /* now simply send a delete message to the loopset. It will get rid of
        * all the newly created loops, but leave alone the disconnected edges
        * which will be freed by the EMinters_data_free function.
        */

       sts = om$send(msg = message Root.delete(1),
                                targetid = cp_loopset.objid,
                                targetos = cp_loopset.osnum,
                                senderid = NULL_OBJID);
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);
       cp_loopset.objid = NULL_OBJID; /* IMPT. checked at wrapup */

       /* free the trace data */
       if (sfinttrace_alloced)
       {
         EMfreetrace(&tracedata);
         sfinttrace_alloced = FALSE;
       }

       /* delete all deletable intobjs. Since we have null-terminated this 
        * this inters node, the deletion is done ONLY on this node.
        */
     
       if (deletable_intobjs)
       {
         (void) EMdelintobj_selective(&msg_loc, NULL, inters_loc, 
                            EMSintobj_deletable, NULL);
         EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

         *deleted = TRUE;
       }


       if (edges)
         {om$dealloc (ptr = edges); edges=NULL;}
       if (lpprops)
         {om$dealloc (ptr = lpprops); lpprops = NULL;}
       if (loops)
         {om$dealloc (ptr = loops); loops = NULL;}
        
      if (sfintloops_alloced)
      {
        EMsfintloops_free (loop_sf, end_edges, intedpars, sfpartols);
        sfintloops_alloced = FALSE;
      }  

     }/*if !skip_this_surface */


     /* free the trace data if necessary (if the "if" loop above was skipped) */
     if (sfinttrace_alloced)
     {
         EMfreetrace(&tracedata);
         sfinttrace_alloced = FALSE;
     }


     if (orig_intobjs)
       {stackfree (orig_intobjs); orig_intobjs=NULL;}
     if (cp_intobjs)
       {stackfree (cp_intobjs); cp_intobjs =NULL;}
     if (looplist)
        {stackfree (looplist); looplist = NULL;}

     if (cp_inters)
     {
       EMinters_data_free(&msg_loc, cp_inters, MAXINT, NULL, EMsfintedpar_free);
       EMinters_free (cp_inters, MAXINT);
       cp_inters = NULL;
     }

     inters_loc->next = inters_next;
     inters_loc = inters_loc->next;


   } /*while*/


wrapup:

  if (edges)
    om$dealloc (ptr = edges);
  if (lpprops)
    om$dealloc (ptr = lpprops);
  if (loops)
    om$dealloc (ptr = loops);

  if (cp_loopset.objid != NULL_OBJID)
  {
    buf_size=0;
    num_loops=0;
    loops = NULL;
    lpprops = NULL;
    depth = MAXINT;
    sts = om$send (msg = message EMSloopset.EMget_loops (&msg_loc,
                                EMS_OPT_ALL, &depth, &loops,
                                &lpprops, &buf_size, &num_loops),
               senderid =  NULL_OBJID,
               targetid = cp_loopset.objid,
               targetos = cp_loopset.osnum);
    if(!(1&sts&msg_loc))
      {*EFmsg = EMS_E_Fail;}
 
    for (i=0; i<num_loops; i++)
    {
      if (!(lpprops[i]&EMLP_NATURAL))
      {
        sts = om$send(msg = message Root.wild_disconnect(to_edges),
                             targetid = loops[i],
                             targetos = this_sf.osnum,
                             senderid = NULL_OBJID);
        if(!(1&sts))
          {*EFmsg = EMS_E_OMerror;}
      }
    }

     sts = om$send(msg = message Root.delete(1),
                                targetid = cp_loopset.objid,
                                targetos = cp_loopset.osnum,
                                senderid = NULL_OBJID);
     if(!(1&sts))
       {*EFmsg = EMS_E_Fail;}
  
    if (lpprops)
      om$dealloc (ptr = lpprops);
    if (loops)
      om$dealloc (ptr = loops);
  }/*if*/


  
  if (sfinttrace_alloced)
  {
    EMfreetrace(&tracedata);
  }
  
  if (sfintloops_alloced)
  {
     EMsfintloops_free (loop_sf, end_edges, intedpars, sfpartols);
  }  

  if (cp_inters)
  {
    EMinters_data_free(&msg_loc, cp_inters, MAXINT, NULL, EMsfintedpar_free);
    EMinters_free (cp_inters, MAXINT);
  }


  EMWRAPUP( *EFmsg, sts, "In EFdelete_bad_trace_groups");

}
/*----------------------------------------------------------------------------*/

static void EMmovetrace (in_tracedata, out_tracedata)
struct EMSsftracedata *in_tracedata, *out_tracedata;
{

    out_tracedata->num_grps           = in_tracedata->num_grps;
    out_tracedata->num_subgrps_grp    = in_tracedata->num_subgrps_grp;
    out_tracedata->num_elems_subgrp   = in_tracedata->num_elems_subgrp;
    out_tracedata->elems              = in_tracedata->elems;
    out_tracedata->subgrp_rev         = in_tracedata->subgrp_rev;
    out_tracedata->elem_rev           = in_tracedata->elem_rev;
    out_tracedata->grp_closed         = in_tracedata->grp_closed;
    out_tracedata->subgrp_closed      = in_tracedata->subgrp_closed;

}

static void EMinittrace(tracedata)
struct EMSsftracedata *tracedata;
{
    tracedata->num_grps           = 0;
    tracedata->num_subgrps_grp    = NULL;
    tracedata->num_elems_subgrp   = NULL;
    tracedata->elems              = NULL;
    tracedata->subgrp_rev         = NULL;
    tracedata->elem_rev           = NULL;
    tracedata->grp_closed         = NULL;
    tracedata->subgrp_closed      = NULL;
}


static void EMfreetrace(tracedata)
struct EMSsftracedata *tracedata;

{

  IGRlong msg_loc;

  EMsfinttrace_free (&msg_loc,
                 tracedata->num_grps,
                 tracedata->num_subgrps_grp,
                 tracedata->num_elems_subgrp,
                 tracedata->elems,
                 tracedata->subgrp_rev,
                 tracedata->elem_rev,
                 tracedata->grp_closed,
                 tracedata->subgrp_closed);
}

/*----------------------------------------------------------------------------*/

end implementation EMSsffeature;
