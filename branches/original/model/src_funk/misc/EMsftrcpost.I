/* ###################   APOGEE COMPILED   ################## */
/*
Notes
  This file contains the functions related to refinement/fixing of the traced
  intersection data. The main function which interfaces with the caller is
  EMfix_refine_intdata. This function looks at the intersection on two surfaces
  (either/both of which can be complex) and their corresponding trace
  information. It calls the lower level function EMfix_sfint_uvtrace() in
  succession for each solid (modifying the trace information along the way
  if it has to.)
  The function EMfix_sfint_uvtrace() looks at the ends between subgroups
  and between open groups and modifies them to become exact. Actually it
  passes each of endpoints to the function EMsfint_exact() which does the
  actual work. EMfix_sfint_uvtrace() also extends two subgroups on the same
  surface to exactly match at the appropriate end points.
  Only EMfix_refine_intdata() and EMfix_sfint_uvtrace are relevant to the
  caller. Other functions in this file are specific to this processing are
  are therefore made static.
  During refinement of intersection data, topology is also made use of 
  for linking up intersection pieces.

  HISTORY

    SM  :  01-Apr-88  :  Creation
    SM	:  04-Oct-88  :  If split points are on the same edge and at the
			 same point, do not consider it as mismatched
			topology.
    SM  :  25-Oct-88  : Perform extension even between subgroups resulting
			out of coincedent plane intersection. Also even if
			extension fails connect the forward and backward
			pointers in the respective intersection nodes.
    SM	:  16-Feb-89  : Out of my utter stupidity, I was returning invalid
			argument code from EMfix_sfint_uvtrace(), if the data 
			had parametric curves 
			(instead of edge objects or 2d polylines) even though
			I am able to handle them. Fixed it.
    SM  :  12-Sep-89  : Ignore subgroups which have an intobj marked as 
			'noconnectuv' at the relevant end, when trying
			to extend data.
    SM  :  08-Nov-90  : Ignore data terminating on degenerate edges for
			extension.
    NP	:  10-Apr-92  : The "xyzendpts" needed by the "EMsfint_exact"  function
			are now obtained (using the "EMgetendpts_xyz" function)
			using env_info from the CONSTRUCT LIST rather than the
			"mattyp" and "mat" passed into the "EMfix_sfint_uvtrace"
			function. Creates problems with ref. files, otherwise.
    NP  :  15-Sep-92  : Updated EMsfint_exact function calls, to which I have
			now added an argument. Added a whole bunch of 
			"EMgetendpts_uv" statements to evaluate the additional
			parameter for the call.("approx_uv3_next" is the
			newly added parameter.). 
                        Also corrected a bunch compiler warnings.
    NP  :  14-Oct-93  : The subgrp_rev flag was being used to access matching
                        endpt info of two successive intobjs WITHIN a subgrp.
                        
			 
*/

class implementation Root;

#ifndef DEBUG
#define DEBUG 0
#endif


#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif

# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "OMminimum.h"
# include "OMerrordef.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "igr.h"
# include "go.h"


%safe
#include <math.h>
%endsafe

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "EMStpmacros.h"
#include "emsmacros.h"
#include "EMSutlmacros.h"

#define U 0
#define V 1
#define FIRST 0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (msg_loc)) goto label;

/*
 * If the difference between the parametric values in a given dimension is
 * less than this (for a normalized surface paramteric space), the two
 * points definitely do not represent points that lie at opposite boundaries
 * of the natural parametric space.
 */

#define MAX_UV_TOLERANCE 0.5

/*
 * This is the size in bytes of a buffer which will get allocated on the
 * stack and used locally by this function. If this size is found to
 * be small a larger buffer is malloced and used instead.
 */

#if DEBUG
#define LOCAL_BUFF_SIZE 1
#else
#define LOCAL_BUFF_SIZE 100
#endif

/*
 * A factor to multiply the given parametric basis tolerance by, in order
 * to more accurately compute the intersection point. This helps resolve
 * problems associated with borderline cases that do not link up in
 * uv-space and yet would give an end-point intersection condition.
 */


#define EMrefix(msg, mattyp, mat, other_mattyp, other_mat, const_list, inters, altuvtol, altxyztol, num_grps, num_subgrps_grp, num_elems_subgrp, elems, subgrp_rev, elem_rev, grp_closed, subgrp_closed, inters_opt, outworld_opt, outparam_opt, trim_opt, opinx) \
	{ \
         EMsfinttrace_free ((msg), *(num_grps), *(num_subgrps_grp), \
     	 *(num_elems_subgrp), *(elems), *(subgrp_rev), *(elem_rev), \
	 *(grp_closed), *(subgrp_closed)); \
         EMerr_hndlr (!(1&*msg), *msg, EMS_E_Fail, ret_end); \
         EMsfinttrace_ptrs_null ((num_grps), (num_subgrps_grp), \
	  (num_elems_subgrp), \
	  (elems), (subgrp_rev), (elem_rev), (grp_closed), (subgrp_closed)); \
         EMsfinttrace ((msg), (mattyp), (mat), (inters), (altuvtol), \
	  (altxyztol), (num_grps), (num_subgrps_grp), (num_elems_subgrp), \
	  (elems), (subgrp_rev), (elem_rev), (grp_closed), (subgrp_closed)); \
         EMerr_hndlr (!(1&*msg), *msg, EMS_E_Fail, ret_end); \
	 sts = EMfix_sfint_after_uvtrace( (msg), (mattyp), (mat), \
	 (other_mattyp), (other_mat), (const_list), \
	 (inters), (altuvtol), (altxyztol), (num_grps), (num_subgrps_grp), \
	 (num_elems_subgrp), (elems), (subgrp_rev), (elem_rev), \
	 (grp_closed), (subgrp_closed), (inters_opt), (outworld_opt), \
	 (outparam_opt), (trim_opt), (opinx)); \
	 if(*msg == EMS_I_Modified) other_data_changed = TRUE; \
	 goto ret_end; \
	}
	
from EMSsubbs import EMpartolbasis, EMpratmpt;
from EMSedge import EMptproject, EMget_props, EMgetsurface_info;
from EMSloop import EMget_objid, EMget_props;

%safe
static IGRint EMretrim();
static void EMsm_remove_intobj();
static void EMsm_purge_intobj();
static IGRint EMgetint_topology();
static void EMsort_the_intobjs();
static IGRint EMare_intobjs_exact();
static void EMsfinttrace_ptrs_null();
static IGRint EMupdate_splitinfo();
static IGRint EMorient_deg();
%endsafe


/* Following global switch (defined in src_testco/imp/ECdbgsendi.I) is
   used to suppress refinement for debugging purposes only. The switch
   can be toggled on/off via the debug command 'z toggle refinement'
   defined in zsk.cmd.
*/
extern short _sm_skip_int_refinement;
extern IGRboolean WANT_POST220_BEHAVIOR;
extern void EMbreak_connection();
	
IGRint EMfix_and_refine_intdata (msg, mattyp, mat, other_mattyp, other_mat, 
			    const_list, inters1, inters2, 
                            altuvtol1, altxyztol, altuvtol2, 
                            num_grps, num_subgrps_grp, num_elems_subgrp,
                            elems, subgrp_rev, elem_rev,
                            grp_closed, subgrp_closed, inters_opt, 
                            outworld_opt, outparam_opt, trim_opt)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
IGRshort *other_mattyp;
IGRmatrix other_mat;
struct GRvg_construct *const_list;
struct EMSinters *inters1, *inters2;
IGRdouble *altuvtol1, *altxyztol, *altuvtol2;
IGRint *num_grps, **num_subgrps_grp, ***num_elems_subgrp;
struct EMSintobj ****elems;
IGRboolean ***subgrp_rev, ****elem_rev, **grp_closed, 
	   ***subgrp_closed;
IGRushort inters_opt, outworld_opt, outparam_opt, trim_opt;	
{
 IGRlong	sts = OM_S_SUCCESS;
 IGRboolean	dangling_data = FALSE;
 extern void	EMsfinttrace(), EMsfinttrace_free();

 *msg = EMS_S_Success;

 if( _sm_skip_int_refinement) 
  {
   fprintf(stderr, "\nSKIPPING REFINEMENT\n");
   goto wrapup;
  }

 /* For the intersections on the first surface/solid, do the fixing.
 */
#if DEBUG
 fprintf(stderr, "\nFix_sfint_uvtrace 1\n");
#endif
 sts = EMfix_sfint_after_uvtrace(msg, mattyp, mat, other_mattyp, other_mat, 
		const_list, inters1, 
		altuvtol1, altxyztol, &num_grps[0], &num_subgrps_grp[0], 
		&num_elems_subgrp[0], &elems[0], &subgrp_rev[0], 
		&elem_rev[0], &grp_closed[0], &subgrp_closed[0], inters_opt, 
		outworld_opt, outparam_opt, trim_opt, FIRST);
 EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, wrapup);
 if(*msg == EMS_I_Open) dangling_data = TRUE;

 /* If some piece in the 'other_intersections' was deleted, then the return
    code will be EMS_I_Modified. In such a case retrace the other intersections
    again. The piece is not actually deleted but marked for deletion at this
    point. So delete that piece out of the intersection list.
 */
 if( (*msg == EMS_I_Modified) && inters2)
  {
   EMsm_purge_intobj(msg, other_mattyp, other_mat, &num_grps[1], 
    &num_subgrps_grp[1], &num_elems_subgrp[1], &elems[1], &subgrp_rev[1], 
    &elem_rev[1], &grp_closed[1], &subgrp_closed[1], inters2, altuvtol2, 
    altxyztol);
   if(!(1&*msg)) goto wrapup;
  }

 if( (*msg == EMS_S_Success) && inters2)
  {
   EMsfinttrace_free (msg, num_grps[1], num_subgrps_grp[1], 
     num_elems_subgrp[1], elems[1], subgrp_rev[1], elem_rev[1], 
     grp_closed[1], subgrp_closed[1]);
   EMerr_hndlr(!(1&*msg), *msg, EMS_E_Fail, wrapup);

   EMsfinttrace_ptrs_null (&num_grps[1], &num_subgrps_grp[1], 
     &num_elems_subgrp[1], &elems[1], 
     &subgrp_rev[1], &elem_rev[1], &grp_closed[1], &subgrp_closed[1]);

   EMsfinttrace (msg, other_mattyp, other_mat, inters2, altuvtol2, altxyztol, 
     &num_grps[1], &num_subgrps_grp[1], &num_elems_subgrp[1], &elems[1], 
     &subgrp_rev[1], &elem_rev[1], &grp_closed[1], &subgrp_closed[1]);
   EMerr_hndlr(!(1&*msg), *msg, EMS_E_Fail, wrapup);
  }
 else if(!inters2) goto wrapup;

 /* For the intersections on the second surface/solid, do the fixing.
 */
#if DEBUG
 fprintf(stderr, "\nFix_sfint_uvtrace 2\n");
#endif
 sts = EMfix_sfint_after_uvtrace(msg, other_mattyp, other_mat, mattyp, mat, 
		const_list, inters2, 
		altuvtol2, altxyztol, &num_grps[1], &num_subgrps_grp[1], 
		&num_elems_subgrp[1], &elems[1], &subgrp_rev[1], 
		&elem_rev[1], &grp_closed[1], &subgrp_closed[1], inters_opt, 
		outworld_opt, outparam_opt, trim_opt, SECOND);
 EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, wrapup);
 if(*msg == EMS_I_Open) dangling_data = TRUE;

 /* If some piece in the 'other_intersections' was deleted, then the return
    code will be EMS_I_Modified. In such a case retrace the other intersections
    again. To complete the loop do the fixing on the first inters list
    again. Hopefully this second fixing should not cause any refinement
    but just 'extension' between subgroups.
 */
 if(*msg == EMS_I_Modified)
  {
   EMsm_purge_intobj(msg, mattyp, mat, &num_grps[0], &num_subgrps_grp[0], 
    &num_elems_subgrp[0], &elems[0], &subgrp_rev[0], &elem_rev[0], 
    &grp_closed[0], &subgrp_closed[0], inters1, altuvtol1, altxyztol);
   if(!(1&*msg)) goto wrapup;
  }

 if(*msg == EMS_S_Success)
  {
   EMsfinttrace_free (msg, num_grps[0], num_subgrps_grp[0], 
     num_elems_subgrp[0], elems[0], subgrp_rev[0], elem_rev[0], 
     grp_closed[0], subgrp_closed[0]);
   EMerr_hndlr(!(1&*msg), *msg, EMS_E_Fail, wrapup);

   EMsfinttrace_ptrs_null (&num_grps[0],
     &num_subgrps_grp[0], &num_elems_subgrp[0], &elems[0], &subgrp_rev[0], 
     &elem_rev[0], &grp_closed[0], &subgrp_closed[0]);

   EMsfinttrace (msg, mattyp, mat, inters1, altuvtol1, altxyztol, &num_grps[0],
     &num_subgrps_grp[0], &num_elems_subgrp[0], &elems[0], &subgrp_rev[0], 
     &elem_rev[0], &grp_closed[0], &subgrp_closed[0]);
   EMerr_hndlr(!(1&*msg), *msg, EMS_E_Fail, wrapup);

#if DEBUG
   fprintf(stderr, "\nFix_sfint_uvtrace 3\n");
#endif
   sts = EMfix_sfint_after_uvtrace(msg, mattyp, mat, other_mattyp, other_mat, 
		const_list, inters1, 
		altuvtol1, altxyztol, &num_grps[0], &num_subgrps_grp[0], 
		&num_elems_subgrp[0], &elems[0], &subgrp_rev[0], 
		&elem_rev[0], &grp_closed[0], &subgrp_closed[0], inters_opt, 
		outworld_opt, outparam_opt, trim_opt, FIRST);
   EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, wrapup);
  }

wrapup:

if(dangling_data) *msg = EMS_I_Open;

EMWRAPUP(*msg, sts, "In EMfix_refine_intdata");
return(sts);
}

IGRint EMfix_sfint_after_uvtrace (msg, mattyp, mat, other_mattyp, other_mat, 
			    const_list, inters, altuvtol, altxyztol,
                            num_grps, num_subgrps_grp, num_elems_subgrp,
                            elems, subgrp_rev, elem_rev,
                            grp_closed, subgrp_closed, inters_opt, 
                            outworld_opt, outparam_opt, trim_opt, opinx)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
IGRshort *other_mattyp;
IGRmatrix *other_mat;
struct GRvg_construct *const_list;
struct EMSinters *inters;
IGRdouble *altuvtol, *altxyztol;
IGRint *num_grps, **num_subgrps_grp, ***num_elems_subgrp;
struct EMSintobj ****elems;
IGRboolean ***subgrp_rev, ****elem_rev, **grp_closed, ***subgrp_closed;
IGRushort inters_opt, outworld_opt, outparam_opt, trim_opt;
IGRint opinx;
{
  IGRboolean 		**elemrevs, at_stop1, at_stop2, 
			in_world = TRUE, at_stop1_other, at_stop2_other, 
			at_stop_con = FALSE, begin1, begin2, skip1 = FALSE, 
			dangling_data = FALSE, retrim[2], skip2 = FALSE, 
			other_data_changed = FALSE, exact1, exact2, 
			mismatched_topology = FALSE, refined = FALSE, 
			extnded = FALSE, coinc1 = FALSE, coinc2 = FALSE, 
			changed_for_maxsplit = FALSE;
  IGRint 		localmem[LOCAL_BUFF_SIZE], totnum_subgrps, blksize, 
			inxlim, i, j, k, l, circinxj, circinxk, altinx1, 
			altinx2, altinx1_other, altinx2_other;
  extern IGRint		EMextend_intdata(), EMgetendpts_uv(), 
			EMgetendpts_xyz(), EMsfint_exact();
  IGRlong 		msg_loc, sts, rc;
  IGRdouble 		dumpt[3], endpt1[2], endpt2[2], bastol, xyzendpt[3], 
			dumpt_other[3], endpt1_other[2], endpt2_other[2], 
			junkpt[3], *approx_uv3_1, *approx_uv3_2, xyzlentol = 0,
			dist, endpt_con[2], cht;
  extern IGRdouble BSdistptpt();
  GRobjid 		**sfids, sfid1, sfid2;
  GRspacenum 		sfos;
  struct EMSintobj 	***intobjs, *intobj_loc, ***ptrptr, **ptr, *intobj1, 
			*intobj2, *intobj1_other, *intobj2_other, 
			*con_intobj = NULL;
  extern void		EMsfinttrace(), EMsfinttrace_free();
  OM_S_CHANSELECT	to_common_edge;
  struct EMSpartolbasis partolbasis;
  struct EMSdataselect  surf_data;
  struct GRid		surf_GRid;
  void		EMsfinttrace_ptrs_null();
  struct IGRbsp_surface *surf_geom = NULL;
  IGRdouble 		u_low = 0.0, v_low = 0.0, u_hig = 1.0, v_hig = 1.0;
  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  sfos = OM_Gw_current_OS;
  BSEXTRACTPAR(&rc, BSTOLLENVEC, xyzlentol);
  BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
  retrim[0] = retrim[1] = FALSE;
  surf_data.datatype = EMSdata_null;

  ptrptr = NULL;

  {
   enum EMSdatatype	junk;

   junk = (*elems)[0][0]->this_uvintobj.datatype;
   EMerr_hndlr (junk != EMSdata_object && junk != EMSdata_poly2d &&
		junk != EMSdata_curve3d, *msg, EMS_E_InvalidArg, ret_end);
   junk = (*elems)[0][0]->this_xyzintobj.datatype; 
   EMerr_hndlr (junk != EMSdata_object && junk != EMSdata_poly3d &&
		junk != EMSdata_curve3d, *msg, EMS_E_InvalidArg, ret_end);
  }

  /*
   * Malloc (if needed) and partition memory for 
   * local use.
   */

  totnum_subgrps = 0;
  for (i=0; i<*num_grps; i++)
    totnum_subgrps += (*num_subgrps_grp)[i];

  blksize = /* For the intersection elements double-array */
              (*num_grps * sizeof (struct EMSintobj **)) +
               (totnum_subgrps * 2 * sizeof (struct EMSintobj *)) +
            /* For the reversal flag double-array */
              (*num_grps * sizeof (IGRboolean *)) +
               (totnum_subgrps * 2 * sizeof (IGRboolean)) +
            /* For the surface ids double-array */
              (*num_grps * sizeof (GRobjid *)) +
               (totnum_subgrps * sizeof (GRobjid));
  if (blksize <= LOCAL_BUFF_SIZE * sizeof (IGRint))
    ptrptr = (struct EMSintobj ***) localmem;
  else
    { 
    ptrptr = (struct EMSintobj ***) om$malloc (size = blksize);
    EMerr_hndlr (!ptrptr, *msg, EMS_E_NoDynamicMemory, ret_end);  
    }

  intobjs = (struct EMSintobj ***) ptrptr;
  elemrevs = (IGRboolean **) &intobjs[*num_grps];
  sfids = (GRobjid **) &elemrevs[*num_grps];
  ptr = (struct EMSintobj **) &sfids[*num_grps];
  for (i=0; i<*num_grps; i++)
    {
    intobjs[i] = (struct EMSintobj **) ptr;
    elemrevs[i] = (IGRboolean *) &(intobjs[i])[(*num_subgrps_grp)[i]*2];
    sfids[i] = (GRobjid *) &(elemrevs[i])[(*num_subgrps_grp)[i]*2];
    ptr = (struct EMSintobj **) &(sfids[i])[(*num_subgrps_grp)[i]];
    }

  /*
   * Obtain information into the local buffers about the
   * surfaces on which each subgroup is defined and about
   * the surface-edges on which their endpoints are incident.
   */

  for (i=0; i<*num_grps; i++)
    {
    for (j=0, k=0; j<(*num_subgrps_grp)[i]; j++, k+=2)
      {
      intobjs[i][k] = intobj_loc = (*elems)[i][j];
      for (l=0; l<(*num_elems_subgrp)[i][j]-1; l++)
        intobj_loc = intobj_loc->next;
      intobjs[i][k+1] = intobj_loc;

      elemrevs[i][k] = (*elem_rev)[i][j][0];
      elemrevs[i][k+1] = (*elem_rev)[i][j][(*num_elems_subgrp)[i][j]-1];

      if ((*elems)[i][j]->this_obj_node)
        sfids[i][j] = (*elems)[i][j]->this_obj_node->this_obj.objid;
      else
        sfids[i][j] = NULL_OBJID;
      }
    }
  if ((*elems)[0][0]->this_obj_node)
    sfos = (*elems)[0][0]->this_obj_node->this_obj.osnum;


  sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
				
  for (i=0; i<*num_grps; i++)
    {
    if ((*subgrp_closed)[i][0])
       continue;

    if( (*num_subgrps_grp)[i] == 1) inxlim = 1;
    else
      inxlim = (*num_subgrps_grp)[i] - ((*grp_closed)[i] ? 0 : 1);
    for (j=0, k=0; j<inxlim; j++, k+=2)
      {
      sfid1 = sfids[i][j];
      circinxj = (j + 1) % (*num_subgrps_grp)[i];
      sfid2 = sfids[i][circinxj];

      altinx1 = (*subgrp_rev)[i][j] ? 0 : 1;
      altinx1_other = (*subgrp_rev)[i][j] ? 1 : 0;

      intobj1 = intobjs[i][k+altinx1];
      intobj1_other = intobjs[i][k+altinx1_other];

      /* at_stop flag refers to the relevant end point of the intobj in
         question. It is based on the trace information. The trace info
	 has already considered the intobj->reversed flag.
      */
      at_stop1 = 
        (elemrevs[i][k+altinx1] && (*subgrp_rev)[i][j]) ||
         (!elemrevs[i][k+altinx1] && !(*subgrp_rev)[i][j]) ? 
        TRUE : FALSE;

      at_stop1_other = 
        (elemrevs[i][k+altinx1_other] && (*subgrp_rev)[i][j]) ||
         (!elemrevs[i][k+altinx1_other] && !(*subgrp_rev)[i][j]) ? 
        FALSE : TRUE;

      altinx2 = (*subgrp_rev)[i][circinxj] ? 1 : 0;
      altinx2_other = (*subgrp_rev)[i][circinxj] ? 0 : 1;

      circinxk = (k + 2) % ((*num_subgrps_grp)[i] * 2);
      intobj2 = intobjs[i][circinxk+altinx2]; 
      intobj2_other = intobjs[i][circinxk+altinx2_other]; 

      at_stop2 = 
        (elemrevs[i][circinxk+altinx2] && (*subgrp_rev)[i][circinxj]) ||
         (!elemrevs[i][circinxk+altinx2] && !(*subgrp_rev)[i][circinxj]) ? 
        FALSE : TRUE;

      at_stop2_other = 
        (elemrevs[i][circinxk+altinx2_other] && (*subgrp_rev)[i][circinxj]) ||
         (!elemrevs[i][circinxk+altinx2_other] && !(*subgrp_rev)[i][circinxj]) 
	 ? TRUE : FALSE;
  
      begin1 = FALSE;
      begin2 = TRUE;
      exact1 = exact2 = skip1 = skip2 = FALSE;
      coinc1 = coinc2 = FALSE;

      skip1 = intobj1 ? (intobj1->props & EMSintobj_delrefine) ||
		 	!(intobj1->other_intobj_node) : TRUE;
      coinc1 = intobj1 ? (intobj1->props & EMSintobj_coincident) : TRUE;
      if(intobj1)
        exact1 = at_stop1 ? intobj1->props & EMSintobj_exact_atstop :
			    intobj1->props & EMSintobj_exact_atstart;
								
      skip2 = intobj2 ? (intobj2->props & EMSintobj_delrefine) : TRUE;
      coinc2 = intobj2 ? (intobj2->props & EMSintobj_coincident) : TRUE;

      if(intobj2)	
        exact2 = at_stop2 ? intobj2->props & EMSintobj_exact_atstop :
			    intobj2->props & EMSintobj_exact_atstart;
								

      /* Even if the intobjs are exact geometrically, topologically they
       * may be 'inexact' in the sense that they do not end on common
       * edges. Such intobjs are treated as inexact and they are
       * modified in the function EMsfint_exact(), such that they now end
       * on common edges.
      */
      if(!skip1 && !skip2)
       mismatched_topology = !(EMare_intobjs_exact(&msg_loc, intobj1, intobj2, 
			    !at_stop1, !at_stop2, &exact1, &exact2, 
			    &to_common_edge));
			
      if (!skip1 && !skip2 && !(exact1 &&exact2)
	 )
        {
	 if(intobj1->other_intobj_node)
	  {
           sts = EMgetendpts_uv (&msg_loc, 
		 &intobj1->other_intobj_node->this_uvintobj,
                 intobj1->reversed, 1, at_stop1 ? dumpt : endpt1, 
                 at_stop1 ? endpt1 : dumpt);
           EMomerr_exit (sts, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	  }
	 if(intobj2->other_intobj_node)
	  {
           sts = EMgetendpts_uv (&msg_loc, 
		 &intobj2->other_intobj_node->this_uvintobj,
                 intobj2->reversed, 1, at_stop2 ? dumpt : endpt2, 
                 at_stop2 ? endpt2 : dumpt);
           EMomerr_exit (sts, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	  }
         sts = EMgetendpts_xyz (&msg_loc, 
			    const_list && const_list->env_info ? 
                               &(const_list->env_info->md_env.matrix_type) :
			       mattyp,
			    const_list && const_list->env_info ?
                               const_list->env_info->md_env.matrix :
			       mat, 
				    &intobj1->this_xyzintobj,
                 	            intobj1->reversed, 1, 
                                    at_stop1 ? dumpt : xyzendpt, 
                 	            at_stop1 ? xyzendpt : dumpt);
         EMomerr_exit (sts, ret_end);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

         sts = EMgetendpts_xyz (&msg_loc, 
			    const_list && const_list->env_info ? 
                               &(const_list->env_info->md_env.matrix_type) :
			       mattyp,
			    const_list && const_list->env_info ?
                               const_list->env_info->md_env.matrix :
			       mat, 
				    &intobj2->this_xyzintobj,
                 	            intobj2->reversed, 1, 
                                    at_stop2 ? junkpt : dumpt, 
                 	            at_stop2 ? dumpt : junkpt);
         EMomerr_exit (sts, ret_end);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	
 	 /* If the relevant points from the two intobjs are within model
	    space tolerance then no need for refinement. 
	 */
	
         if( !mismatched_topology && 
	     (dist = BSdistptpt(&rc, xyzendpt, dumpt)) < xyzlentol)
          {
           extern IGRboolean	EMrecord_pointers();
	
	   intobj1->props |= at_stop1 ? EMSintobj_exact_atstop :
					EMSintobj_exact_atstart;
	   intobj2->props |= at_stop2 ? EMSintobj_exact_atstop :
					EMSintobj_exact_atstart;

	   EMrecord_pointers(&msg_loc, !at_stop1, !at_stop2, intobj1, intobj2);
	   refined = TRUE;	
	  }
	 else if( (IF_EQ_OBJID(sfid1, sfid2) && (*grp_closed)[i]) ||
		  !IF_EQ_OBJID(sfid1, sfid2))
	  {
	   approx_uv3_1 = intobj1->other_intobj_node ? endpt1 : NULL;
	   approx_uv3_2 = intobj2->other_intobj_node ? endpt2 : NULL;
	   begin1 = !at_stop1;
	   begin2 = !at_stop2;
	   sts = EMsfint_exact(&msg_loc, mattyp, mat, other_mattyp, 
			   other_mat, const_list, num_grps, num_subgrps_grp, 
			   num_elems_subgrp, elems, intobj1, intobj2,
			   begin1, begin2, approx_uv3_1, approx_uv3_2, xyzendpt,
                           retrim);
	   if(msg_loc == EMS_S_Success) refined = TRUE;
	   if(msg_loc == EMS_I_Open) dangling_data = TRUE;
           if(retrim[0])
            {
	     sts = EMretrim(&msg_loc, num_grps, num_subgrps_grp,
			      num_elems_subgrp, elems, subgrp_rev, elem_rev, 
			      intobj1, &other_data_changed);
	     EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
             EMrefix(msg, mattyp, mat, other_mattyp, other_mat, const_list, 
		     inters, altuvtol, altxyztol,
         	     num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		     subgrp_rev, elem_rev, grp_closed, subgrp_closed, 
		     inters_opt, outworld_opt, outparam_opt, trim_opt, opinx);

	    } /* if(retrim[0]) */
           if(retrim[1])
            {
	     sts = EMretrim(&msg_loc, num_grps, num_subgrps_grp,
			      num_elems_subgrp, elems, subgrp_rev, elem_rev, 
			      intobj2, &other_data_changed);
	     EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
             EMrefix(msg, mattyp, mat, other_mattyp, other_mat, const_list, 
		     inters, altuvtol, altxyztol,
         	     num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		     subgrp_rev, elem_rev, grp_closed, subgrp_closed, 
		     inters_opt,  outworld_opt,  outparam_opt, 
		     trim_opt, opinx);
	    } /* if(retrim[1]) */
	
	  } /* If xyz points not within tolerance */
	
        } /* If intobjs eligible for refinement */

       if(!(*grp_closed)[i])
	{
	 /* process begin point of first subgroup. If we have more than one
	    group of intersection data, then the intobj which should have
	    been linked with the intobj in question can be possibly obtained
	    using topology (common edge). If such an continuing piece exists
	    on the common edge, then the reason it did not get grouped with 
	    this intobj was because of improper tolerances (among other
	    reasons). This situation can be corrected by refinement. If the
	    common edges were indeed produced from intersection of their
	    respective surfaces, then this situation will be corrected by
	    three surface iteration or curve surface iteration. If this is
	    not the case however, then artificial refinement will be done
	    assuming the endpoint of one of the intobjs to be fixed and
	    'pulling' the other towards it. All this will take place in the
	    function EMsfint_exact.
	 */
	 skip1 = skip2 = exact1 = exact2 = FALSE;
	 coinc1 = coinc2 = FALSE;
	
	 skip1 = intobj1_other ? (intobj1_other->props & EMSintobj_delrefine)
				|| !(intobj1_other->other_intobj_node) 
			       : TRUE;
	 coinc1 = intobj1_other ? (intobj1_other->props & EMSintobj_coincident)
			       : TRUE;
         if(intobj1_other)
          exact1 = at_stop1_other ? 
			    intobj1_other->props & EMSintobj_exact_atstop :
			    intobj1_other->props & EMSintobj_exact_atstart;
	 con_intobj = NULL;
	 at_stop_con = FALSE;
	
	 if( (j == 0) && !skip1)
	  {
	   sts = EMgetint_topology(&msg_loc, mattyp, mat, num_grps, 
				num_subgrps_grp, num_elems_subgrp, elems, 
				subgrp_rev, elem_rev, intobj1_other, 
				&con_intobj, at_stop1_other, &at_stop_con, 
				&to_common_edge);
	   if(!(1&msg_loc&sts))
	    { con_intobj = NULL; at_stop_con = FALSE;}
	  }
	
         skip2 = con_intobj ? (con_intobj->props & EMSintobj_delrefine) 
			     : FALSE;
         coinc2 = con_intobj ? (con_intobj->props & EMSintobj_coincident)
			     : FALSE;
         if(con_intobj)	
         exact2 = at_stop_con ? con_intobj->props & EMSintobj_exact_atstop :
			    con_intobj->props & EMSintobj_exact_atstart;
	
	 if( (j == 0) && !skip1 && !skip2 && !(exact1 && exact2) )
	  {
	   if(intobj1_other->other_intobj_node)
	    {
             sts = EMgetendpts_uv (&msg_loc,
		&intobj1_other->other_intobj_node->this_uvintobj,
                intobj1_other->reversed, 1, at_stop1_other ? 
		dumpt : endpt1_other, at_stop1_other ? endpt1_other : dumpt);
   	     EMomerr_exit (sts, ret_end);
      	     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	    }
	   if( con_intobj && con_intobj->other_intobj_node)
	    {
             sts = EMgetendpts_uv (&msg_loc,
		&con_intobj->other_intobj_node->this_uvintobj,
                con_intobj->reversed, 1, at_stop_con ? 
		dumpt : endpt_con, at_stop_con ? endpt_con : dumpt);
   	     EMomerr_exit (sts, ret_end);
      	     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	    }
      	   sts = EMgetendpts_xyz (&msg_loc, 
				const_list && const_list->env_info ?
                                  &(const_list->env_info->md_env.matrix_type) :
				  mattyp,
				const_list && const_list->env_info ?
                                  const_list->env_info->md_env.matrix :
				  mat, 
				    &intobj1_other->this_xyzintobj,
                 	            intobj1_other->reversed, 1, 
			            at_stop1_other ? dumpt_other : xyzendpt, 
                 	            at_stop1_other ? xyzendpt : dumpt_other);
      	   EMomerr_exit (sts, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	   approx_uv3_1= intobj1_other->other_intobj_node ? endpt1_other : NULL;
	   approx_uv3_2= con_intobj ? 
                            (con_intobj->other_intobj_node ? endpt_con : NULL)
                                    : NULL;
	   begin1 = !at_stop1_other;
	   begin2 = !at_stop_con;
	   sts = EMsfint_exact(&msg_loc, mattyp, mat, other_mattyp, 
			   other_mat, const_list, num_grps, num_subgrps_grp, 
			   num_elems_subgrp, elems, intobj1_other, con_intobj,
			   begin1, begin2, approx_uv3_1, approx_uv3_2, xyzendpt,
                           retrim);
	   if(msg_loc == EMS_S_Success) refined = TRUE;
	   if(msg_loc == EMS_I_Open) dangling_data = TRUE;
	   if(retrim[0])
            {
	     sts = EMretrim(&msg_loc, num_grps, 
			num_subgrps_grp, num_elems_subgrp, elems, subgrp_rev, 
			elem_rev, intobj1_other, &other_data_changed);
	     EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
	     EMrefix(msg, mattyp, mat, other_mattyp, other_mat, const_list, 
		     inters, altuvtol, altxyztol,
         	     num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		     subgrp_rev, elem_rev, grp_closed, subgrp_closed, 
		     inters_opt,  outworld_opt,  outparam_opt, 
		     trim_opt, opinx);
	    } /* if(retrim[0]) */
           if(retrim[1] && con_intobj)
            {
	     sts = EMretrim(&msg_loc, num_grps, num_subgrps_grp,
			      num_elems_subgrp, elems, subgrp_rev, elem_rev, 
			      con_intobj, &other_data_changed);
	     EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
             EMrefix(msg, mattyp, mat, other_mattyp, other_mat, const_list, 
		     inters, altuvtol, altxyztol,
         	     num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		     subgrp_rev, elem_rev, grp_closed, subgrp_closed, 
		     inters_opt,  outworld_opt,  outparam_opt, 
		     trim_opt,  opinx);
	    } /* if(retrim[1]) */
	
	  } /* if(j == 0) */
	
	 /* Process end point of last subgroup */
	
	 skip1 = skip2 = exact1 = exact2 = FALSE;
	 coinc1 = coinc2 = FALSE;
	
	 skip2 = intobj2_other ? (intobj2_other->props & EMSintobj_delrefine)
				|| !(intobj2_other->other_intobj_node)
			       : TRUE;
	 coinc2 = intobj2_other ? (intobj2_other->props & EMSintobj_coincident)
			       : TRUE;
         if(intobj2_other)
          exact2 = at_stop2_other ? 
			    intobj2_other->props & EMSintobj_exact_atstop :
			    intobj2_other->props & EMSintobj_exact_atstart;
			
	 con_intobj = NULL;
	 at_stop_con = FALSE;

	 if( (j == (inxlim-1)) && !skip2)	
	  {
	   sts = EMgetint_topology(&msg_loc, mattyp, mat, num_grps, 
				num_subgrps_grp, num_elems_subgrp, elems, 
				subgrp_rev, elem_rev, intobj2_other, 
				&con_intobj, at_stop2_other, &at_stop_con, 
				&to_common_edge);
	   if(!(1&msg_loc&sts))
	    { con_intobj = NULL; at_stop_con = FALSE;}
	  }
	
         skip1 = con_intobj ? (con_intobj->props & EMSintobj_delrefine) 
				: FALSE;
         coinc1 = con_intobj ? (con_intobj->props & EMSintobj_coincident)
				: FALSE;
         if(con_intobj)	
          exact1 = at_stop_con ? con_intobj->props & EMSintobj_exact_atstop :
			    con_intobj->props & EMSintobj_exact_atstart;
	
	 if( (j == (inxlim-1)) && !skip2 && !skip1 && !(exact2 && exact1) )
	  {
	   if(intobj2_other->other_intobj_node)
	    {
             sts = EMgetendpts_uv (&msg_loc,
			&intobj2_other->other_intobj_node->this_uvintobj,
                 	intobj2_other->reversed, 1, 
			at_stop2_other ? dumpt : endpt2_other, 
			at_stop2_other ? endpt2_other : dumpt);
     	     EMomerr_exit (sts, ret_end);
      	     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	    }
	   if(con_intobj && con_intobj->other_intobj_node)
	    {
             sts = EMgetendpts_uv (&msg_loc,
			&con_intobj->other_intobj_node->this_uvintobj,
                 	con_intobj->reversed, 1, 
			at_stop_con ? dumpt : endpt_con, 
			at_stop_con ? endpt_con : dumpt);
     	     EMomerr_exit (sts, ret_end);
      	     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	    }
      	   sts = EMgetendpts_xyz (&msg_loc, 
				const_list && const_list->env_info ?
                                  &(const_list->env_info->md_env.matrix_type) :
				  mattyp,
				const_list && const_list->env_info ?
                                  const_list->env_info->md_env.matrix :
				  mat, 
				    &intobj2_other->this_xyzintobj,
                 	            intobj2_other->reversed, 1, 
			            at_stop2_other ? dumpt_other : xyzendpt, 
                 	            at_stop2_other ? xyzendpt : dumpt_other);
      	   EMomerr_exit (sts, ret_end);
           EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
	   approx_uv3_1= intobj2_other->other_intobj_node ? endpt2_other : NULL;
	   approx_uv3_2= con_intobj ? 
                            (con_intobj->other_intobj_node ? endpt_con : NULL)
                                    : NULL;
	   begin1 = !at_stop2_other;
	   begin2 = !at_stop_con;
 	   sts = EMsfint_exact(&msg_loc, mattyp, mat, other_mattyp, 
			   other_mat, const_list, num_grps, num_subgrps_grp, 
			   num_elems_subgrp, elems, intobj2_other, con_intobj,
			   begin1, begin2, approx_uv3_1, approx_uv3_2, xyzendpt,
                           retrim);
	   if(msg_loc == EMS_S_Success) refined = TRUE;
	   if(msg_loc == EMS_I_Open) dangling_data = TRUE;
           if(retrim[0])
            {
	     sts = EMretrim(&msg_loc, num_grps, 
			num_subgrps_grp, num_elems_subgrp, elems, subgrp_rev, 
			elem_rev, intobj2_other, &other_data_changed);
	     EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
	     EMrefix(msg, mattyp, mat, other_mattyp, other_mat, const_list, 
		     inters, altuvtol, altxyztol,
         	     num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		     subgrp_rev, elem_rev, grp_closed, subgrp_closed, 
		     inters_opt,  outworld_opt,  outparam_opt, 
		     trim_opt,  opinx);
	    } /* if(retrim[0]) */
           if(retrim[1] && con_intobj)
            {
	     sts = EMretrim(&msg_loc, num_grps, num_subgrps_grp,
			      num_elems_subgrp, elems, subgrp_rev, elem_rev, 
			      con_intobj, &other_data_changed);
	     EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
             EMrefix(msg, mattyp, mat, other_mattyp, other_mat, const_list, 
		     inters, altuvtol, altxyztol,
         	     num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		     subgrp_rev, elem_rev, grp_closed, subgrp_closed, 
		     inters_opt,  outworld_opt,  outparam_opt, 
		     trim_opt,  opinx);
	    } /* if(retrim[1]) */
	  } /* if(j == (inxlim-1)) */
	
	} /* if(!(*grp_closed)[i]) */
	
      }/* for (j=0, k=0; j<=inxlim; j++, k+=2) */

    }  /* for (i=0; i<*num_grps; i++) */


 /* If refinement has taken place then do retracing so that extension
    will use uptodate trace information. Also if retraced, then obtain the
    information in the local buffers again since the trace information has
    changed. The number of groups, number of subgroups etc. should always
    decrease as a result of refinement. Nevertheless check if the localmemory
    is enough just to be sure so that memory is not overwritten if something
    has gone wrong in refinement.
 */


  if (refined)
   {
     EMsfinttrace_free (&msg_loc, *num_grps, *num_subgrps_grp, 
        *num_elems_subgrp, *elems, *subgrp_rev, *elem_rev, *grp_closed,
        *subgrp_closed);
     EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

     EMsfinttrace_ptrs_null (num_grps, 
		   num_subgrps_grp, num_elems_subgrp, elems, 
		   subgrp_rev, elem_rev, grp_closed, subgrp_closed);
		
     EMsfinttrace (&msg_loc, mattyp, mat, inters, altuvtol, altxyztol, 
		   num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		   subgrp_rev, elem_rev, grp_closed, subgrp_closed);
     EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
     if(ptrptr && (ptrptr != (struct EMSintobj ***)localmem)) 
          om$dealloc(ptr = ptrptr);
     ptrptr = NULL;

     /*
      * Malloc (if needed) and partition memory for 
      * local use.
     */

     totnum_subgrps = 0;
     for (i=0; i<*num_grps; i++)
      totnum_subgrps += (*num_subgrps_grp)[i];

     blksize = /* For the intersection elements double-array */
              (*num_grps * sizeof (struct EMSintobj **)) +
               (totnum_subgrps * 2 * sizeof (struct EMSintobj *)) +
            /* For the reversal flag double-array */
              (*num_grps * sizeof (IGRboolean *)) +
               (totnum_subgrps * 2 * sizeof (IGRboolean)) +
            /* For the surface ids double-array */
              (*num_grps * sizeof (GRobjid *)) +
               (totnum_subgrps * sizeof (GRobjid));
     if (blksize <= LOCAL_BUFF_SIZE * sizeof (IGRint))
       ptrptr = (struct EMSintobj ***) localmem;
     else
      { 
       ptrptr = (struct EMSintobj ***) om$malloc (size = blksize);
       EMerr_hndlr (!ptrptr, *msg, EMS_E_NoDynamicMemory, ret_end);  
      }

     intobjs = (struct EMSintobj ***) ptrptr;
     elemrevs = (IGRboolean **) &intobjs[*num_grps];
     sfids = (GRobjid **) &elemrevs[*num_grps];
     ptr = (struct EMSintobj **) &sfids[*num_grps];
     for (i=0; i<*num_grps; i++)
     {
      intobjs[i] = (struct EMSintobj **) ptr;
      elemrevs[i] = (IGRboolean *) &(intobjs[i])[(*num_subgrps_grp)[i]*2];
      sfids[i] = (GRobjid *) &(elemrevs[i])[(*num_subgrps_grp)[i]*2];
      ptr = (struct EMSintobj **) &(sfids[i])[(*num_subgrps_grp)[i]];
     }

     /*
      * Obtain information into the local buffers about the
      * surfaces on which each subgroup is defined and about their endpoints.
      */

    for (i=0; i<*num_grps; i++)
     {
      for (j=0, k=0; j<(*num_subgrps_grp)[i]; j++, k+=2)
       {
        intobjs[i][k] = intobj_loc = (*elems)[i][j];
        for (l=0; l<(*num_elems_subgrp)[i][j]-1; l++)
         intobj_loc = intobj_loc->next;
        intobjs[i][k+1] = intobj_loc;

        elemrevs[i][k] = (*elem_rev)[i][j][0];
        elemrevs[i][k+1] = (*elem_rev)[i][j][(*num_elems_subgrp)[i][j]-1];

        if ((*elems)[i][j]->this_obj_node)
         sfids[i][j] = (*elems)[i][j]->this_obj_node->this_obj.objid;
        else
         sfids[i][j] = NULL_OBJID;
       }
     }

   } /* if(refined) */

  if ((*elems)[0][0]->this_obj_node)
   sfos = (*elems)[0][0]->this_obj_node->this_obj.osnum;

  /* The following post processing is done to break the elements which
     are incedent on some existing edges. By linking such elements into
     a single subgroup, such incedence information is lost. In order to
     cause maximum splits and create virtual vertices later, such elements
     need to be forced into different subgroups. If the existing edge,
     on which there is incedence, has a common edge, then a degenerate 
     intersection is introduced on the common surface, to force a topological
     continuity.

     Thus, if intersections A and B are incedent on an existing edge E1, which
     has a common edge E2, then the resultant intersection graph, after this
     processing will be -

     A (on S1) --> C (on S2) --> B (on S1)

     where intersection C is the degenerate intersection, incedent on E2.

     For the sake of not causing topology mismatches on old models (pre 2.4)
     by causing more number of edges, the following is done only if the
     global switch WANT_POST220_BEHAVIOR is TRUE.

     SM 06/09/93.
  */

  /* Following comment has effectively disabled the 'maximum-split' 
     functionality. This action is being taken because not enough time
     is left to fully debug it for EMS 3. A revisit to it needs to be
     done for EMS 4
  */
/* if(!WANT_POST220_BEHAVIOR)*/
   goto Extension;

  for(i=0; i<*num_grps; i++)
   {
    struct EMSintobj 		*this_elem, *new_elem, *next_elem;
    struct EMSsfintedpar 	*inc1, *inc2, *newinc1, *newinc2;
    struct EMSdataselect 	new_xyzintobj, new_uvintobj, junk_intobj;
    IGRuint 			comcount = 0;
    OM_S_OBJECT_LINKAGE 	comed;
    GRobjid 			comsf, thissf;
    IGRdouble 			xyzpt[2][3], uvpt[2][2], dumpt[2][3];
    struct EMSproj_info 	projinfo;
    struct EMSpartolbasis 	compartol, thispartol;
    struct IGRpolyline 		poly3d, poly2d;
    struct GRid 		junkGRid;
    IGRboolean 			at_stop1, at_stop2;


    /* When 2 intobjs are incedent at the same point, it is important to
       know their orientation wrt each other, i.e whether they are going
       to enclose area within themselves or not. If they are going to enclose
       area within themselves (they are oriented 'right' wrt each other), then
       no processing need be done for the common surface, since the
       final topology is not going to have any part of the current
       incedent edge. If the intobjs are not going to enclose area
       within themselves then parts of the existing incedent edge are going
       to be retained in the final topology. In such a case, the common edge
       of this incedent edge also needs to be split. This will be
       achieved by forcing a point intersection on the common surface.

       Currently, point location is relied upon to determine the orientation
       of the 2 intobjs. There is some room for improvement here. Knowing that
       the data is oriented (for union/difference/intersection) such
       that the other volume is to the left or right, is there a way the
       orientation of these 2 intobjs be deduced from that? When this is
       figured out, the intobjs can be marked appropriately before
       calling the function EMorient_deg, so that point location can be
       avoided.
    */
    for(j=0; j<(*num_subgrps_grp)[i]; j++)
     {
      thissf = NULL_OBJID;

      this_elem = (*elems)[i][j];
      if (this_elem->this_obj_node)
       {
        sfos = this_elem->this_obj_node->this_obj.osnum;
        thissf = this_elem->this_obj_node->this_obj.objid;
       }

      /* Examine the logical stop of each element for incedence on existing
         edge. For open subgroups, the last element does not have to be checked
         as there is no continuing piece. For closed subgroups however,
         the last element needs to be checked for incedence to prevent
         it from getting linked with the first element.
      */
      inxlim = (*num_elems_subgrp)[i][j] - ((*subgrp_closed)[i][j] ? 0 :1);
      if((*num_elems_subgrp)[i][j] == 1)
       inxlim = 0;

      thispartol.mattyp = const_list && const_list->env_info ?
                           &(const_list->env_info->md_env.matrix_type): mattyp,
      thispartol.mat = const_list && const_list->env_info ?
                        const_list->env_info->md_env.matrix : mat;


      if(!IF_NULL_OBJID(thissf))
       {
	sts = om$send(msg = message EMSsubbs.EMpartolbasis(&msg_loc, 
	      thispartol.mattyp, thispartol.mat, &in_world, TRUE, 
	      &thispartol.tol), targetid = thissf, targetos = sfos, 
	      senderid = NULL_OBJID);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
       }
      else thispartol.tol = 0.00000001;

      thispartol.is_valid = TRUE;

      for(l=0; l<inxlim; l++)
       {
	inc1 = (struct EMSsfintedpar *) this_elem->more_info;
	
	if(!inc1 || (this_elem->props & EMSintobj_nontriminfo))
	 goto NextElem;

        circinxj = (l + 1) % (*num_elems_subgrp)[i][j];
        if(!circinxj)
         next_elem = (*elems)[i][j];
        else
         next_elem = this_elem->next;

        at_stop1 = ((*elem_rev)[i][j][l])? FALSE : TRUE;
        at_stop2 = ((*elem_rev)[i][j][circinxj])? TRUE : FALSE;

	if( (at_stop1 && !this_elem->reversed) ||
	    (!at_stop1 && this_elem->reversed))
	 inc1 = inc1->next;	
	
	if(!inc1 || IF_NULL_OBJID(inc1->edgeid))
         goto NextElem;

        if(next_elem && next_elem->more_info && 
           (!(next_elem->props & EMSintobj_nontriminfo)))
         {
          inc2 = (struct EMSsfintedpar *) next_elem->more_info;


  	  if( (at_stop2 && !next_elem->reversed) ||
	      (!at_stop2 && next_elem->reversed))
	   inc2 = inc2->next;	
	 }
        else inc2 = NULL;

        if(inc2 && !IF_EQ_OBJID(inc1->edgeid, inc2->edgeid))
         {
	  /* The edge ids could very well be different if the incedence
	     is at the end of an edge. However, we can safely disconnect
	     the 2 intobjs as long as BOTH are incedent at the ends.
	  */
	  if((inc1->edgeid == NULL_OBJID) || (inc2->edgeid == NULL_OBJID)
	     || (inc1->intloc == EMScvint_middle) 
	     || (inc2->intloc == EMScvint_middle))
           goto NextElem;
         }

        /* If the 2 intobjs incedent at the common point are oriented
           such that they contain area between themselves, then the common
           incedence point is of no interest, since it is not going to
           represent a vertex after these intersections have been used to
           modify topology. Hence such intobjs are skipped.
        */
        if(this_elem && next_elem)
         {
          sts = EMorient_deg(&msg_loc, this_elem, next_elem, inc1, sfos, 
                &thispartol, NULL, &comed);
          if(!(1&msg_loc) || (this_elem->props & EMSintobj_degen_ornt_right))
           {
	    msg_loc = EMS_S_Success;
            goto NextElem;
           }
         }

        /* We now have an intersection piece which is logically ending
           on an existing edge.
        */
        EMbreak_connection(this_elem);
        this_elem->props |= (at_stop1 ? EMSintobj_fwd_noconnectuv
                                      : EMSintobj_bwd_noconnectuv);
        if(next_elem)
         {
          EMbreak_connection(next_elem);
          next_elem->props |= (at_stop2 ? EMSintobj_fwd_noconnectuv
                                              : EMSintobj_bwd_noconnectuv);
         }

        changed_for_maxsplit = TRUE;

        /* If the uv connection that was just broken was not incedent in
           the middle of the existing edge, then breaking the connection
           is not going to cause a split on the existing edge. In this case 
           there is no further action required to maintain topological 
           integrity if this data is used to modify the existing boundaries.
        */
        if(inc2 && (inc2->intloc != EMScvint_middle) &&
                   (inc1->intloc != EMScvint_middle))
         goto NextElem;
       
        /* Introduce a degenerate intersection on the common surface if there
           exists a common edge connection.
        */
        sts = om$get_channel_objects(objid = inc1->edgeid, osnum = sfos, 
              p_chanselect = &to_common_edge, count = &comcount, 
              list = &comed, size = 1);
        if(!(1&sts)) goto ret_end;

        if(!comcount) goto NextElem;

        comsf = NULL_OBJID;
        sts = om$send(msg = message EMSedge.EMgetsurface_info(&msg_loc, 
              &comsf, NULL), targetid = comed.S_objid, targetos = sfos, 
              senderid = NULL_OBJID);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

        if(IF_NULL_OBJID(comsf)) 
         goto NextElem;

        if(IF_EQ_OBJID(thissf, comsf))
         goto NextElem;
     
        /* Get the xyz end point of this intersection piece and use that
           as the degenerate intersection on the common surface.
        */
   	sts = EMgetendpts_xyz (&msg_loc, 
	      const_list && const_list->env_info ?
              &(const_list->env_info->md_env.matrix_type) : mattyp,
	      const_list && const_list->env_info ?
              const_list->env_info->md_env.matrix : mat, 
	      &this_elem->this_xyzintobj, this_elem->reversed, 1, 
	      at_stop1 ? dumpt[0] : xyzpt[0], at_stop1 ? xyzpt[0] : dumpt[0]);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

	/* The point in the common surface's uv space.
	*/
	sts = om$send(msg = message EMSsubbs.EMpratmpt(&msg_loc, 
	      const_list && const_list->env_info ?
              &(const_list->env_info->md_env.matrix_type) : mattyp,
	      const_list && const_list->env_info ?
              const_list->env_info->md_env.matrix : mat, 1, xyzpt[0], uvpt[0], 
              NULL, NULL), targetid = comsf, targetos = sfos, 
              senderid = NULL_OBJID);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
	
	/* The other uv point projected onto the common edge.
	*/
	compartol.mattyp = const_list && const_list->env_info ?
                           &(const_list->env_info->md_env.matrix_type): mattyp,
        compartol.mat = const_list && const_list->env_info ?
                        const_list->env_info->md_env.matrix : mat;
	compartol.is_valid = FALSE;
	sts = om$send(msg = message EMSedge.EMptproject(&msg_loc, uvpt[0], 1, 
	      &projinfo, NULL, &compartol), targetid = comed.S_objid, 
	      targetos = sfos, senderid = NULL_OBJID);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);
	
	/* Setup the incedence on the common edge.
	*/
	newinc1 = (struct EMSsfintedpar *) EMsfintedpar_malloc(&msg_loc, 2);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);	
	newinc2 = newinc1->next;
	
        OM_BLOCK_MOVE(projinfo.proj_pt, newinc1->point, 2*sizeof(IGRdouble));
        OM_BLOCK_MOVE(projinfo.proj_pt, newinc2->point, 2*sizeof(IGRdouble));
        OM_BLOCK_MOVE(&projinfo.param, &newinc1->edgepar, 
                      sizeof(struct EMSedgebound));
        OM_BLOCK_MOVE(&projinfo.param, &newinc2->edgepar, 
                      sizeof(struct EMSedgebound));
        newinc1->intloc = newinc2->intloc = projinfo.location;
        newinc1->edgeid = newinc2->edgeid = comed.S_objid;
        
        /* Construct the uv and xyz intersection nodes.
        */
        poly3d.num_points = poly2d.num_points = 2;
        OM_BLOCK_MOVE(xyzpt, xyzpt[1], 3*sizeof(IGRdouble));
        OM_BLOCK_MOVE(uvpt, uvpt[1], 2*sizeof(IGRdouble));
        poly3d.points = (IGRdouble *) xyzpt;
        poly2d.points = (IGRdouble *) uvpt;
        junk_intobj.datatype = EMSdata_poly3d;
        junk_intobj.data.poly = &poly3d;
        sts = EMmkintdata(&msg_loc, &junk_intobj, EMpoint, FALSE, TRUE, NULL, 
              const_list, 
              (this_elem->this_xyzintobj.datatype == EMSdata_object) ?
               TRUE : FALSE, &cht, NULL, &new_xyzintobj);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);	
        junk_intobj.datatype = EMSdata_poly2d;
        junk_intobj.data.poly = &poly2d;
        sts = EMmkintdata(&msg_loc, &junk_intobj, EMpoint, FALSE, FALSE, NULL, 
              const_list, 
              (this_elem->this_uvintobj.datatype == EMSdata_object) ?
               TRUE : FALSE, &compartol.tol, NULL, &new_uvintobj);
	EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);	
	junkGRid.objid = comsf;
	junkGRid.osnum = sfos;
	
	new_elem = (struct EMSintobj *) ems$makeintlist(msg = &msg_loc, 
                  inters_a = &inters, object_a = &junkGRid,
                  xyzintobject = &new_xyzintobj, uvintobject_a = &new_uvintobj,
                  moreinfo_a = newinc1, 
                  props_a = EMSintobj_uvdegenerate|EMSintobj_xyzdegenerate);

        /* Setup the xyzspace connectivity for trace. This connectivity
           being -

           this_elem ---> new elem ---> next_elem.
        */
        new_elem->reversed = FALSE;
        new_elem->props |= 
                     (EMSintobj_fwd_noconnectuv | EMSintobj_bwd_noconnectuv);
        if(at_stop1)
         this_elem->fwd = new_elem;
        else
         this_elem->bwd = new_elem;

        new_elem->bwd = this_elem;

        if(next_elem)
         {
          new_elem->fwd = next_elem;
          if(at_stop2)
           next_elem->fwd = new_elem;
          else
           next_elem->bwd = new_elem;

          /* Orient the degenerate intersection using the 2 non-degenerate
             pieces.
          */
          sts = EMorient_deg(&msg_loc, this_elem, next_elem, inc1, sfos, 
                &thispartol, new_elem, &comed);
	  EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);	
         }
	EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);	
	
NextElem:	
	this_elem = this_elem->next;
	
       } /* for(l=0; l<inxlim; l++) */

     } /* for(j=0; j<(*num_subgrps_grp)[i]; j++) */

   } /* for(i=0; i<*num_grps; i++) */

Extension:
  if (changed_for_maxsplit)
   {
     EMsfinttrace_free (&msg_loc, *num_grps, *num_subgrps_grp, 
        *num_elems_subgrp, *elems, *subgrp_rev, *elem_rev, *grp_closed,
        *subgrp_closed);
     EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

     EMsfinttrace_ptrs_null (num_grps, 
		   num_subgrps_grp, num_elems_subgrp, elems, 
		   subgrp_rev, elem_rev, grp_closed, subgrp_closed);
		
     EMsfinttrace (&msg_loc, mattyp, mat, inters, altuvtol, altxyztol, 
		   num_grps, num_subgrps_grp, num_elems_subgrp, elems, 
		   subgrp_rev, elem_rev, grp_closed, subgrp_closed);
     EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
     if(ptrptr && (ptrptr != (struct EMSintobj ***)localmem)) 
          om$dealloc(ptr = ptrptr);
     ptrptr = NULL;

     /*
      * Malloc (if needed) and partition memory for 
      * local use.
     */

     totnum_subgrps = 0;
     for (i=0; i<*num_grps; i++)
      totnum_subgrps += (*num_subgrps_grp)[i];

     blksize = /* For the intersection elements double-array */
              (*num_grps * sizeof (struct EMSintobj **)) +
               (totnum_subgrps * 2 * sizeof (struct EMSintobj *)) +
            /* For the reversal flag double-array */
              (*num_grps * sizeof (IGRboolean *)) +
               (totnum_subgrps * 2 * sizeof (IGRboolean)) +
            /* For the surface ids double-array */
              (*num_grps * sizeof (GRobjid *)) +
               (totnum_subgrps * sizeof (GRobjid));
     if (blksize <= LOCAL_BUFF_SIZE * sizeof (IGRint))
       ptrptr = (struct EMSintobj ***) localmem;
     else
      { 
       ptrptr = (struct EMSintobj ***) om$malloc (size = blksize);
       EMerr_hndlr (!ptrptr, *msg, EMS_E_NoDynamicMemory, ret_end);  
      }

     intobjs = (struct EMSintobj ***) ptrptr;
     elemrevs = (IGRboolean **) &intobjs[*num_grps];
     sfids = (GRobjid **) &elemrevs[*num_grps];
     ptr = (struct EMSintobj **) &sfids[*num_grps];
     for (i=0; i<*num_grps; i++)
     {
      intobjs[i] = (struct EMSintobj **) ptr;
      elemrevs[i] = (IGRboolean *) &(intobjs[i])[(*num_subgrps_grp)[i]*2];
      sfids[i] = (GRobjid *) &(elemrevs[i])[(*num_subgrps_grp)[i]*2];
      ptr = (struct EMSintobj **) &(sfids[i])[(*num_subgrps_grp)[i]];
     }

     /*
      * Obtain information into the local buffers about the
      * surfaces on which each subgroup is defined and about their endpoints.
      */

    for (i=0; i<*num_grps; i++)
     {
      for (j=0, k=0; j<(*num_subgrps_grp)[i]; j++, k+=2)
       {
        intobjs[i][k] = intobj_loc = (*elems)[i][j];
        for (l=0; l<(*num_elems_subgrp)[i][j]-1; l++)
         intobj_loc = intobj_loc->next;
        intobjs[i][k+1] = intobj_loc;

        elemrevs[i][k] = (*elem_rev)[i][j][0];
        elemrevs[i][k+1] = (*elem_rev)[i][j][(*num_elems_subgrp)[i][j]-1];

        if ((*elems)[i][j]->this_obj_node)
         sfids[i][j] = (*elems)[i][j]->this_obj_node->this_obj.objid;
        else
         sfids[i][j] = NULL_OBJID;
       }
     }

   } /* if(refined) */

  if ((*elems)[0][0]->this_obj_node)
   sfos = (*elems)[0][0]->this_obj_node->this_obj.osnum;

  /*
   * Loop through the intersection data. Whenever parametric-data needs
   * to be extended, call the extend-data function on it.
   */
  for (i=0; i<*num_grps; i++)
    {
	IGRboolean	update1 = FALSE, update2 = FALSE, 
			noconnect1 = FALSE, noconnect2 = FALSE, 
			degen_checked = FALSE, is_degenerate[2][2];
	struct EMSsfintedpar *edpar1 = NULL, *edpar2 = NULL;
	extern IGRboolean	EMset_connection();

	IGRboolean ok = FALSE;
	
     if ((*num_subgrps_grp)[i] == 1 && (*subgrp_closed)[i][0])
      {
      /*
       * The group consists of a single loop which is closed (closed
       * in uv-space). Therefore, this group cannot have any possible
       * extensions/merges to be peformed on it. Skip the group.
       */
        
       continue;
      }

    inxlim = (*num_subgrps_grp)[i] - ((*grp_closed)[i] ? 0 : 1);
    for (j=0, k=0; j<inxlim; j++, k+=2)
      {
       if(surf_geom && (surf_data.datatype == EMSdata_object))
         om$dealloc(ptr = surf_geom);

      degen_checked = FALSE;
      surf_data.datatype = EMSdata_null;
      surf_geom = NULL;

      sfid1 = sfids[i][j];
      circinxj = (j + 1) % (*num_subgrps_grp)[i];
      sfid2 = sfids[i][circinxj];

      altinx1 = (*subgrp_rev)[i][j] ? 0 : 1;

      intobj1 = intobjs[i][k+altinx1];

      at_stop1 = 
        (elemrevs[i][k+altinx1] && (*subgrp_rev)[i][j]) ||
         (!elemrevs[i][k+altinx1] && !(*subgrp_rev)[i][j]) ? 
        TRUE : FALSE;

      altinx2 = (*subgrp_rev)[i][circinxj] ? 1 : 0;

      circinxk = (k + 2) % ((*num_subgrps_grp)[i] * 2);
      intobj2 = intobjs[i][circinxk+altinx2]; 

      at_stop2 = 
        (elemrevs[i][circinxk+altinx2] && (*subgrp_rev)[i][circinxj]) ||
         (!elemrevs[i][circinxk+altinx2] && !(*subgrp_rev)[i][circinxj]) ? 
        FALSE : TRUE;

      skip1 = intobj1 ? intobj1->props & EMSintobj_delrefine : TRUE;
      skip2 = intobj2 ? intobj2->props & EMSintobj_delrefine : TRUE;
      noconnect1 = at_stop1 ? intobj1->props & EMSintobj_fwd_noconnectuv 
			    : intobj1->props & EMSintobj_bwd_noconnectuv;
      noconnect2 = at_stop2 ? intobj2->props & EMSintobj_fwd_noconnectuv 
			    : intobj2->props & EMSintobj_bwd_noconnectuv;
			
      if (!IF_EQ_OBJID (sfid1, sfid2) || skip1 || skip2 || (noconnect1 &&
	  noconnect2))
	continue;

      /*
       * Obtain the relevant endpoints for the
       * intersection data.
       */

      sts = EMgetendpts_uv (&msg_loc, &intobj1->this_uvintobj,
                 intobj1->reversed, 1, at_stop1 ? dumpt : endpt1, 
                 at_stop1 ? endpt1 : dumpt);
      EMomerr_exit (sts, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

      sts = EMgetendpts_uv (&msg_loc, &intobj2->this_uvintobj,
                 intobj2->reversed, 1, at_stop2 ? dumpt : endpt2,
                 at_stop2 ? endpt2 : dumpt);
      EMomerr_exit (sts, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);


      /*
       * Check if these endpoints lie close to opposite sides of parameteric
       * space bounds. If so, no extending needs to be done. Else, extend to
       * the second node. 
       */

      if (fabs (endpt1[U] - endpt2[U]) > MAX_UV_TOLERANCE ||
          fabs (endpt1[V] - endpt2[V]) > MAX_UV_TOLERANCE)
        {
        /*
         * The endpoints lie close to seam-edges and must therefore, not
         * be altered. The situation is correct to begin with.
         */

        continue;
        }

      /* If the endpoints in question are both incedent on some existing
	 edges, then extension is not necessary. 
	
	 SM- 03-Feb-89 - The above was put in as an optimisation, but
	 some cases have been pointed out where extension should occur
	 inspite of split information being present. After extension for
	 such cases, update the split information by projecting the new
	 end point onto the incedent edge for data integrity after this
	 point.
      */

       edpar1 = (struct EMSsfintedpar *) 
                    (intobj1->props & EMSintobj_nontriminfo ? NULL : 
							  intobj1->more_info);
       edpar2 = (struct EMSsfintedpar *)
		    (intobj2->props & EMSintobj_nontriminfo ? NULL :
							  intobj2->more_info);

       if(edpar1 && !at_stop1 && intobj1->reversed) edpar1 = edpar1->next;
       else if(edpar1 && at_stop1 && !intobj1->reversed) edpar1 = edpar1->next;

       if(edpar2 && !at_stop2 && intobj2->reversed) edpar2 = edpar2->next;
       else if(edpar2 && at_stop2 && !intobj2->reversed) edpar2 = edpar2->next;

       if(edpar1 && !IF_NULL_OBJID(edpar1->edgeid))
        {
	 IGRushort edprops = NULL;

	 sts = om$send(msg = message EMSedge.EMget_props
			(&msg_loc, &edprops), targetid = edpar1->edgeid, 
			targetos = sfos, senderid = NULL_OBJID);
	 if(edprops & EMED_DEGENERATE) continue;
	
	 update1 = TRUE;
	}
       else update1 = FALSE;
       if(edpar2 && !IF_NULL_OBJID(edpar2->edgeid))
	{
	 IGRushort edprops = NULL;

	 sts = om$send(msg = message EMSedge.EMget_props
			(&msg_loc, &edprops), targetid = edpar2->edgeid, 
			targetos = sfos, senderid = NULL_OBJID);
	 if(edprops & EMED_DEGENERATE) continue;
	
	 update2 = TRUE;
	}
       else update2 = FALSE;
	
      /*
       * One of the intersection nodes needs to be extended to the second.
       * So invoke the function passing the relevant information to it.
       * The modification needs to be done to parametric space data
       * only. The model space end points of the two subgroups have
       * already been linked by trace into the same group.
       * In case of any kind of error during extension, try the next pair.
       */

      if(intobj1->this_obj_node && intobj1->this_obj_node->more_info)
       {
        surf_data.datatype = EMSdata_surface;
        surf_data.data.surface = (struct IGRbsp_surface *)
                                         (intobj1->this_obj_node->more_info);
       }
      else if(intobj2->this_obj_node && intobj2->this_obj_node->more_info)
       {
        surf_data.datatype = EMSdata_surface;
        surf_data.data.surface = (struct IGRbsp_surface *)
                                         (intobj2->this_obj_node->more_info);
       }
      else if (!IF_NULL_OBJID (sfid1))
       {
        surf_GRid.objid = sfid1;
        surf_GRid.osnum = sfos;
        surf_data.datatype = EMSdata_object;
        surf_data.data.object = &surf_GRid;
       }

      if (altuvtol)
        bastol = *altuvtol;
      else if(intobj1->this_obj_node && intobj1->this_obj_node->more_info)
       {
	sts = EFsspbtol_by_geom(&msg_loc,
				    intobj1->this_obj_node->more_info,
				    &bastol);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
       }
      else if (!IF_NULL_OBJID (sfid1))
        {
        sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                   mattyp, mat, &in_world, FALSE, &bastol),
                   targetid = sfid1, targetos = sfos, senderid = NULL_OBJID);
        EMomerr_exit (sts, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
        }
      else
        bastol = 0.0;

      partolbasis.tol = bastol;
      partolbasis.mattyp = mattyp;
      partolbasis.mat = mat;
      partolbasis.in_world = TRUE;
      partolbasis.is_valid = TRUE;

      /* The ends which are incedent on a degenerate edge of the surface
         need to be left untouched. If the incedent edge information is
         supplied, this check has already been made. If the edge information
         is not supplied, do a geometrical check.
      */

      if( (!update1 || !update2) && !surf_geom)
       {
	if(surf_data.datatype == EMSdata_surface)
	   surf_geom = surf_data.data.surface;
	else if(surf_data.datatype == EMSdata_object)
	 EMgetvggeom(&msg_loc, mattyp, mat, surf_data.data.object, 
	             &surf_geom, NULL);
	if(surf_geom)
	 {
          u_low = surf_geom->u_knots[surf_geom->u_order - 1];
          u_hig = surf_geom->u_knots[surf_geom->u_num_poles];
          v_low = surf_geom->v_knots[surf_geom->v_order - 1];
          v_hig = surf_geom->v_knots[surf_geom->v_num_poles];
	 }
       }
      /*
       * The natural edges are classified as follows:
       *
       * THIS DEFINITION DEPENDS ON THE FUNCTION EFclassify_degenerate_edges().
       *
       * is_degenerate[0][0] implies v = 0
       * is_degenerate[0][1] implies v = 1
       * is_degenerate[1][0] implies u = 0
       * is_degenerate[1][1] implies u = 1
      */

      if(!update1 && surf_geom)
       {
	if(!degen_checked)
	 {
          EFclassify_degenerate_edges(surf_geom, is_degenerate, &msg_loc);
          degen_checked = TRUE;
         }
        if ( (((endpt1[U] - u_low) < bastol) && is_degenerate[1][0]) ||
             (((u_hig - endpt1[U]) < bastol) && is_degenerate[1][1]) ||
             (((endpt1[V] - v_low) < bastol) && is_degenerate[0][0]) ||
             (((v_hig - endpt1[V]) < bastol) && is_degenerate[0][1]) )
         continue;
       }

      if(!update2 && surf_geom)
       {
	if(!degen_checked)
	 {
          EFclassify_degenerate_edges(surf_geom, is_degenerate, &msg_loc);
          degen_checked = TRUE;
         }
        if ( (((endpt2[U] - u_low) < bastol) && is_degenerate[1][0]) ||
             (((u_hig - endpt2[U]) < bastol) && is_degenerate[1][1]) ||
             (((endpt2[V] - v_low) < bastol) && is_degenerate[0][0]) ||
             (((v_hig - endpt2[V]) < bastol) && is_degenerate[0][1]) )
         continue;
       }

      sts = EMextend_intdata (&msg_loc, &intobj1->this_uvintobj,
				 &intobj2->this_uvintobj,
				 intobj1->reversed ? !at_stop1 : at_stop1,
				 intobj2->reversed ? !at_stop2 : at_stop2,
				 &partolbasis, NULL, &surf_data, mat, mattyp);

      /* If extention between these two subgroups failed then continue
	 on with the next pair. 
      */

      if(!(1&msg_loc&sts))
       {
	msg_loc = EMS_S_Success;
	sts = OM_S_SUCCESS;
       }
      else
       {
        if(update1) sts = EMupdate_splitinfo(&msg_loc, 
				&intobj1->this_uvintobj, edpar1,
				intobj1->reversed ? !at_stop1 : at_stop1, 
				&partolbasis, sfos);
        if(update2) sts = EMupdate_splitinfo(&msg_loc, 
				&intobj2->this_uvintobj, edpar2,
				intobj2->reversed ? !at_stop2 : at_stop2, 
				&partolbasis, sfos);
	/* Errors do not warrant exiting. 
	*/
	msg_loc = EMS_S_Success;
	sts = OM_S_SUCCESS;
       }

#if DEBUG
      if( (msg_loc == EMS_I_NoSolution) || (msg_loc == EMS_I_Useless))
       fprintf(stderr, "\nGap after extention\n");
#endif


      /* The information about these two subgroups being linked in parametric
	 space is now stored in the fwd/bwd pointers of the respective intobj
	 along with the property indicating logical forward or backward 
	 continuity. 
      */
      extnded = TRUE;
      ok = EMset_connection(&msg_loc, !at_stop1, !at_stop2, intobj1, intobj2, 
			    TRUE);
      if(!ok) 
       {
        EMbreak_connection(intobj1);
        EMbreak_connection(intobj2);
       }

      } /* for (j=0, k=0; j<inxlim; j++, k+=2) */

    } /* for (i=0; i<*num_grps; i++) */

  /*
   * If any of the edges have been extended, the surface-intersection trace
   * function is called again on this data. The control information passed
   * in is freed and the new information generated by this function is
   * returned in place. 
   */

  if (extnded)
    {
    EMsfinttrace_free (&msg_loc, *num_grps, *num_subgrps_grp, 
     *num_elems_subgrp, *elems, *subgrp_rev, *elem_rev, *grp_closed,
     *subgrp_closed);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

    EMsfinttrace_ptrs_null (num_grps,
     num_subgrps_grp, num_elems_subgrp, elems, subgrp_rev, elem_rev, 
     grp_closed, subgrp_closed);

    EMsfinttrace (&msg_loc, mattyp, mat, inters, altuvtol, altxyztol, num_grps,
     num_subgrps_grp, num_elems_subgrp, elems, subgrp_rev, elem_rev, 
     grp_closed, subgrp_closed);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }

ret_end:
  if(surf_geom && (surf_data.datatype == EMSdata_object))
   om$dealloc(ptr = surf_geom);

  if(other_data_changed) *msg =  EMS_I_Modified;
  else if(refined || extnded) *msg = EMS_S_Success;
  else if(dangling_data) *msg = EMS_I_Open;
  else *msg = EMS_I_NoSolution;
  if(ptrptr && (ptrptr != (struct EMSintobj ***)localmem)) 
        om$dealloc(ptr = ptrptr);
  return (sts);
}

#argsused
static IGRint EMretrim(EMmsg, num_grps, num_subgrps_grp, 
		    num_elems_subgrp, elems, subgrp_rev, elem_rev,
		    intobj, other_data_changed)
IGRlong *EMmsg;
IGRint *num_grps, **num_subgrps_grp, ***num_elems_subgrp;
struct EMSintobj ****elems;
IGRboolean ***subgrp_rev, ****elem_rev;
struct EMSintobj *intobj;
IGRboolean *other_data_changed;
{
 IGRlong		sts;
 IGRint			elem_num_con, i, j, m;
 IGRboolean		bingo;
 struct EMSintobj	*intobj_con, *this_intobj;
 IGRint 		grp_num = 0, subgrp_num = 0, elem_num = 0;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

/* Determine the group number, subgroup number and the element number
   for the input intersection node
*/
 bingo = FALSE;
 for(i=0; (i<(*num_grps)) && !bingo; i++)
 for(j=0; (j<(*num_subgrps_grp)[i]) && !bingo; j++)
  {
   this_intobj = (*elems)[i][j];
   for(m=0; (m<(*num_elems_subgrp)[i][j]) && !bingo; m++)
    {
     if(this_intobj == intobj) 
      {
       grp_num = i;
       subgrp_num = j;
       elem_num = m;
       bingo = TRUE;
      }
     this_intobj = this_intobj->next;
    }
   }

/* If the subgroup in question has only one element, just remove it.
*/
 if((*num_elems_subgrp)[grp_num][subgrp_num] == 1)
  {
   EMsm_remove_intobj(EMmsg, intobj, NULL, other_data_changed);
   goto wrapup;
  }

 elem_num_con = elem_num ? elem_num - 1 : elem_num + 1;
 intobj_con = (*elems)[grp_num][subgrp_num];
 for(i=0; i<elem_num_con; i++) intobj_con = intobj_con->next;

 
/* Since the intersection data is in a hole, this intobj needs to be removed
   from the intersection list. Also the corresponding incedent point
   on the intobj removed needs to be transferred to the next or previous 
   intobj as the case may be.
   When an intobj is removed (by intobj what is meant is the intersection
   piece) the corresponding intobj on the other surface also needs to be
   removed to avoid mismatch in topology.
*/
 EMsm_remove_intobj(EMmsg, intobj, intobj_con, other_data_changed);

wrapup:
return(sts);
}

static void EMsm_remove_intobj(EMmsg, intobj1, intobj2, other_data_changed)
IGRlong *EMmsg;
struct EMSintobj *intobj1, *intobj2;
IGRboolean *other_data_changed;
{
 struct EMSsfintedpar *edpar1, *edpar2;
 IGRchar *save_ptr;
 extern void EMdelintobj();

 *EMmsg = EMS_S_Success;

#if DEBUG
 fprintf(stderr, "Deleting Intobj\n");
#endif

 edpar1 = (struct EMSsfintedpar *) (intobj1 ? 
           (intobj1->props & EMSintobj_nontriminfo ? NULL : intobj1->more_info) 
                     : NULL);
 edpar2 = (struct EMSsfintedpar *) (intobj2 ? 
           (intobj2->props & EMSintobj_nontriminfo ? NULL : intobj2->more_info)
                     : NULL);

 if(edpar1 && edpar2)
  {
  if(IF_NULL_OBJID(edpar1->edgeid)) edpar1 = edpar1->next;
  if(!IF_NULL_OBJID(edpar2->edgeid)) edpar2 = edpar2->next;
  if(edpar1 && edpar2 && !IF_NULL_OBJID(edpar1->edgeid) 
     && IF_NULL_OBJID(edpar2->edgeid))
   {
    save_ptr = (IGRchar *) (edpar2->next);
    *edpar2 = *edpar1;
    edpar2->next = (struct EMSsfintedpar *) save_ptr;
   }
  }

/* When an intobj node is removed, its corresponding piece on the other surface
   will also have to be removed. Instead of actually removing it mark it
   as being expendable.
*/
 if(intobj1) 
  {
   if(intobj1->other_intobj_node)
    {
     intobj1->other_intobj_node->props |= EMSintobj_delrefine;
     intobj1->other_intobj_node->other_intobj_node = NULL;

     /* Since there is common xyz data, set the datatype for this intobj
	to EMSdata_null. That way the xyz data is not freed and the other
	intobj still has access to it untill it is physically removed from
	the inters list.
     */
     intobj1->this_xyzintobj.datatype = EMSdata_null;
     intobj1->other_intobj_node = NULL;
     *other_data_changed = TRUE;
    }
   EMdelintobj(EMmsg, intobj1); 
  }
}





#define MAX_INTOBJ	5

static void EMsm_purge_intobj(EMmsg, mattyp, mat, num_grps, num_subgrps_grp, 
	    num_elems_subgrp, elems, subgrp_rev, elem_rev, grp_closed, 
	    subgrp_closed, inters, altuvtol, altxyztol)
IGRlong *EMmsg;
IGRshort *mattyp;
IGRmatrix mat;
IGRint *num_grps, **num_subgrps_grp, ***num_elems_subgrp;
struct EMSintobj ****elems;
IGRboolean ***subgrp_rev, ****elem_rev, **grp_closed, ***subgrp_closed;
struct EMSinters *inters;
IGRdouble *altuvtol, *altxyztol;
{
 IGRlong sts, num_intobj, i;
 struct EMSintobj *deletable_intobj[MAX_INTOBJ], **intobj_ptr, *this_intobj;
 IGRboolean other_data_changed;
 struct EMSinters	*this_inters;
 extern void		EMsfinttrace(), EMsfinttrace_free();

 *EMmsg = EMS_S_Success;
 intobj_ptr = NULL;

 this_inters = inters;
 num_intobj = 0;
 while(this_inters)
  {
   this_intobj = this_inters->cvs;
   while(this_intobj)
   {
    if(this_intobj->props & EMSintobj_delrefine) num_intobj++;
    this_intobj = this_intobj->next;
   }
   this_inters = this_inters->next;
  }

 if(!num_intobj) goto wrapup;

 if(num_intobj > MAX_INTOBJ)
  intobj_ptr = (struct EMSintobj **) 
		malloc(num_intobj * sizeof(struct EMSintobj *));
 else intobj_ptr = deletable_intobj;
 if(!intobj_ptr) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

 for(i=0; i<num_intobj; i++) intobj_ptr[i] = NULL;

 num_intobj = 0;
 this_inters = inters;
 while(this_inters)
  {
   this_intobj = this_inters->cvs;
   while(this_intobj)
    {
     if(this_intobj->props & EMSintobj_delrefine)
      intobj_ptr[num_intobj++] = this_intobj;
     this_intobj = this_intobj->next;
    }
   this_inters = this_inters->next;
  }

 for(i=0; i<num_intobj; i++)
  {
   if(!intobj_ptr[i]) continue;
   intobj_ptr[i]->other_intobj_node = NULL;
   sts = EMretrim(EMmsg, num_grps, num_subgrps_grp, 
		  num_elems_subgrp, elems, subgrp_rev, elem_rev, 
		  intobj_ptr[i], &other_data_changed);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* since an intersection has been removed, we need to retrace.
   */
   EMsfinttrace_free (EMmsg, num_grps[0], num_subgrps_grp[0], 
     num_elems_subgrp[0], elems[0], subgrp_rev[0], elem_rev[0], 
     grp_closed[0], subgrp_closed[0]);
   if(!(1&*EMmsg)) goto wrapup;

   EMsfinttrace_ptrs_null (&num_grps[0],
     &num_subgrps_grp[0], &num_elems_subgrp[0], &elems[0], &subgrp_rev[0], 
     &elem_rev[0], &grp_closed[0], &subgrp_closed[0]);

   EMsfinttrace (EMmsg, mattyp, mat, inters, altuvtol, altxyztol, &num_grps[0],
     &num_subgrps_grp[0], &num_elems_subgrp[0], &elems[0], &subgrp_rev[0], 
     &elem_rev[0], &grp_closed[0], &subgrp_closed[0]);
   if(!(1&*EMmsg)) goto wrapup;
  }

wrapup:
if(intobj_ptr && (intobj_ptr != deletable_intobj))
  free(intobj_ptr);
if(1&*EMmsg) *EMmsg = EMS_I_Modified;
}


/* Given a intobj, this function returns the intobj which terminates or
   begins on the edge which is 'common' (topologically) to the edge on which
   the input intobj terminates/begins. It also returns the boolean flag 
   'at_stop_con' to indicate whether the point in question was begin or end
   of that intobj.
*/
#define INTOBJ_BUF 5

struct EMSsort_intobj
 {
  IGRdouble dist;
  IGRdouble point[3];
  IGRchar *more_info;
  IGRboolean at_stop;
 };

#argsused
static IGRint EMgetint_topology(EMmsg, mattyp, mat, num_grps, num_subgrps_grp, 
		    num_elems_subgrp, elems, subgrp_rev, elem_rev,
		    intobj, con_intobj, at_stop, at_stop_con, to_common_edge)
IGRlong *EMmsg;
IGRshort *mattyp;
IGRmatrix mat;
IGRint *num_grps, **num_subgrps_grp, ***num_elems_subgrp;
struct EMSintobj ****elems;
IGRboolean ***subgrp_rev, ****elem_rev;
struct EMSintobj *intobj, **con_intobj;
IGRboolean at_stop, *at_stop_con;
OM_S_CHANSELECT *to_common_edge;
{
 IGRlong		sts, rc;
 IGRint			i, j, m;
 IGRboolean		bingo = FALSE;
 struct EMSintobj	*this_intobj;
 struct EMSsfintedpar	*edpar;
 IGRint			count = 0, num_discarded = 0;
 OM_S_OBJECT_LINKAGE	comm;
 GRobjid		comm_id, edgeid;
 GRspacenum		sfos;
 struct EMSintobj	*my_side_buf[INTOBJ_BUF], *comm_side_buf[INTOBJ_BUF], 
			**my_side_ptr = NULL, **comm_side_ptr = NULL, 
			*intobj2 = NULL;
 IGRint			num_my_side = 0, num_comm_side = 0;
 IGRdouble		dist1, dist2, dumpt[3], 
			xyzendpt1[3], xyzendpt2[3], xyzendpt3[3];
 extern IGRdouble BSdistptpt(); 
 struct EMSsort_intobj	sort_intobj_buf[INTOBJ_BUF], *sort_intobj_ptr = NULL;


 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 *con_intobj = NULL;
 edpar = (struct EMSsfintedpar *) (intobj->props & EMSintobj_nontriminfo ? 
                                        NULL : intobj->more_info);
 sfos = intobj->this_obj_node->this_obj.osnum;
 my_side_ptr = my_side_buf;
 comm_side_ptr = comm_side_buf;
 sort_intobj_ptr = (struct EMSsort_intobj *) sort_intobj_buf;

 EMerr_hndlr(!edpar, *EMmsg, EMS_I_NoSolution, wrapup);
 if(!at_stop && intobj->reversed)
    edpar = edpar->next;
 else if(at_stop && !intobj->reversed)
    edpar =  edpar->next;
 EMerr_hndlr(!edpar, *EMmsg, EMS_I_NoSolution, wrapup);
 edgeid = edpar->edgeid;
 EMerr_hndlr(IF_NULL_OBJID(edgeid), *EMmsg, EMS_I_NoSolution, wrapup);
 sts = om$get_channel_objects(objid = edgeid, osnum = sfos, 
			      p_chanselect = to_common_edge, 
                              count = (OMuint *) &count, 
			      list = &comm, size = 1);
 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
 EMerr_hndlr(!count, *EMmsg, EMS_I_NoSolution, wrapup);

 comm_id = comm.S_objid;

 /* How many intobjs incedent on edgeid  and commom edge of edgeid ?
 */
 for(i=0; (i<(*num_grps)); i++)
 for(j=0; (j<(*num_subgrps_grp)[i]); j++)
  {
   this_intobj = (*elems)[i][j];
   for(m=0; (m<(*num_elems_subgrp)[i][j]); m++)
    {
     struct EMSsfintedpar	*junk = NULL;

     junk = (struct EMSsfintedpar *) this_intobj->more_info;
     if( (junk && IF_EQ_OBJID(junk->edgeid, edgeid)) ||
	 (junk && junk->next && IF_EQ_OBJID(junk->next->edgeid, edgeid)))
	num_my_side++;
     if( (junk && IF_EQ_OBJID(junk->edgeid, comm_id)) ||
	 (junk && junk->next && IF_EQ_OBJID(junk->next->edgeid, comm_id)))
	num_comm_side++;
     this_intobj = this_intobj->next;
    }
  }

  EMerr_hndlr(!num_comm_side, *EMmsg, EMS_I_NoSolution, wrapup);

  /* num_my_side has to be atleast 1 (for the intput intobj). Else error.
  */
  EMerr_hndlr(!num_my_side, *EMmsg, EMS_E_Fail, wrapup);

  /* Collect all the relevant intobjs on my side and on common edge side
  */
 if(num_my_side > INTOBJ_BUF)
  my_side_ptr = (struct EMSintobj **) om$malloc(size = num_my_side *
						sizeof(struct EMSintobj *));
 if(num_comm_side > INTOBJ_BUF)
  comm_side_ptr = (struct EMSintobj **) om$malloc(size = num_comm_side *
						sizeof(struct EMSintobj *));
 EMerr_hndlr(!my_side_ptr || !comm_side_ptr, *EMmsg, EMS_E_NoDynamicMemory, 
		wrapup);
		
 num_my_side = num_comm_side = 0;
 for(i=0; (i<(*num_grps)); i++)
 for(j=0; (j<(*num_subgrps_grp)[i]); j++)
  {
   this_intobj = (*elems)[i][j];
   for(m=0; (m<(*num_elems_subgrp)[i][j]); m++)
    {
     struct EMSsfintedpar	*junk = NULL;

     junk = (struct EMSsfintedpar *) this_intobj->more_info;
     if( (junk && IF_EQ_OBJID(junk->edgeid, edgeid)) ||
	 (junk && junk->next && IF_EQ_OBJID(junk->next->edgeid, edgeid)))
	my_side_ptr[num_my_side++] = (struct EMSintobj *) this_intobj;
	       
     if( (junk && IF_EQ_OBJID(junk->edgeid, comm_id)) ||
	 (junk && junk->next && IF_EQ_OBJID(junk->next->edgeid, comm_id)))
	comm_side_ptr[num_comm_side++] = (struct EMSintobj *) this_intobj;
     this_intobj = this_intobj->next;
    }
  }
		
 /* If there are more than one intobj on either sides then do the following-
    .. Get the closest distances between the endpoints of intobj in question
       and all the intobjs on the other side. Sort these distances and keep
       a pointer to the parent intobj (of the other side) with each
       distance.
    .. Take the minimum distance in the list. If any intobj on 'this' side
	other than the intobj in question has minimum distance less than
	the minimum distance from the sorted list, discard that entry
	from the sorted list. Take the next entry and try the same
	thing. Continue untill a hit is made or the list is exhausted.
 */
 if(num_comm_side > INTOBJ_BUF)
  sort_intobj_ptr = (struct EMSsort_intobj *) om$malloc(size = num_comm_side
					* sizeof(struct EMSsort_intobj));
 EMerr_hndlr(!sort_intobj_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 sts = EMgetendpts_xyz (EMmsg, mattyp, mat, 
		&intobj->this_xyzintobj, intobj->reversed, 1, 
		at_stop? dumpt : xyzendpt1, 
                at_stop? xyzendpt1 : dumpt);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
 for(i=0; i<num_comm_side; i++)
  {
   struct EMSintobj *junk;

   junk = comm_side_ptr[i];
   sts = EMgetendpts_xyz (EMmsg, mattyp, mat, 
		&junk->this_xyzintobj, junk->reversed, 1, 
		xyzendpt2, xyzendpt3);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
   dist1 = BSdistptpt(&rc, xyzendpt1, xyzendpt2);
   dist2 = BSdistptpt(&rc, xyzendpt1, xyzendpt3);
   sort_intobj_ptr[i].dist = dist1 < dist2 ? dist1 : dist2;
   OM_BLOCK_MOVE(dist1 < dist2 ? xyzendpt2 : xyzendpt3, 
		   sort_intobj_ptr[i].point, 3 * sizeof(IGRdouble));
   sort_intobj_ptr[i].more_info = (IGRchar *) junk;
   sort_intobj_ptr[i].at_stop = dist1 < dist2 ? FALSE : TRUE;
  }
 EMsort_the_intobjs(sort_intobj_ptr, num_comm_side);
 intobj2 = NULL;
 while( (num_discarded < num_comm_side) && !bingo)
  {
   struct EMSsort_intobj	*this_entry;

   this_entry = (struct EMSsort_intobj *) &sort_intobj_ptr[num_discarded];
   bingo = TRUE; 
   intobj2 = (struct EMSintobj *) this_entry->more_info;
   *at_stop_con = this_entry->at_stop;	 
   for(i=0; i<num_my_side; i++)     
    {
     if(my_side_ptr[i] == intobj) continue;
     sts = EMgetendpts_xyz (EMmsg, mattyp, mat, 
		&my_side_ptr[i]->this_xyzintobj, my_side_ptr[i]->reversed, 1, 
		xyzendpt1, xyzendpt2);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     /* If either of the end points are closer discard this entry. 
     */
     dist1 = BSdistptpt(&rc, xyzendpt1, this_entry->point);
     dist2 = BSdistptpt(&rc, xyzendpt2, this_entry->point);
     if( (dist1 < this_entry->dist) || (dist2 < this_entry->dist))
      {
       num_discarded++; 
       bingo = FALSE; 
       intobj2 = NULL; 
       break;
      }
    }
  }

wrapup:
*con_intobj = intobj2;
if(my_side_ptr && (my_side_ptr != my_side_buf)) om$dealloc(ptr = my_side_ptr);
if(comm_side_ptr && (comm_side_ptr != comm_side_buf)) 
  om$dealloc(ptr = comm_side_ptr);
if(sort_intobj_ptr && (sort_intobj_ptr != sort_intobj_buf))
  om$dealloc(ptr = sort_intobj_ptr);
return(sts);
}


static void EMsort_the_intobjs(intobj, size)
struct EMSsort_intobj	*intobj;
IGRint			size;
{
 int       		i, j;
 struct EMSsort_intobj	temp;

 for(i = 0; i + 1 < size; i ++)
   for(j = i + 1; j < size; j ++)
    {
     if(intobj[i].dist > intobj[j].dist)
      {
        temp = intobj[i];
        intobj[i] = intobj[j];
        intobj[j] = temp;
      }
    }
}


/* The following function looks at the two intobjs and checks whether their
   relevant end points are incedent on common edges. If they are then 
   exact1 and exact2 are both set to TRUE else they are both set to
   FALSE. The function is a special purpose function and is written to 
   minimise code since similar check needs to be done in different
   places.
*/

static IGRint EMare_intobjs_exact(EMmsg, intobj1, intobj2, begin1, begin2, 
				exact1, exact2, to_common_edge)
 IGRlong		*EMmsg;
 struct EMSintobj	*intobj1, *intobj2;
 IGRboolean		begin1, begin2, *exact1, *exact2;
 OM_S_CHANSELECT	*to_common_edge;
{
 struct EMSsfintedpar		*edpar1, *edpar2;
 IGRlong			sts = OM_S_SUCCESS;
 GRspacenum			sfos;
 IGRboolean			are_exact = FALSE;

 *EMmsg = EMS_S_Success;

 if(!intobj1 || !intobj2) goto wrapup;

 edpar1 = (struct EMSsfintedpar *) (intobj1->props & EMSintobj_nontriminfo ? 
                                            NULL : intobj1->more_info);
 edpar2 = (struct EMSsfintedpar *) (intobj2->props & EMSintobj_nontriminfo ? 
                                            NULL : intobj2->more_info);
 sfos = intobj1->this_obj_node->this_obj.osnum;

 if(!edpar1 || !edpar2) goto wrapup;

  if(begin1 && intobj1->reversed)
    edpar1 = edpar1->next;
  else if(!begin1 && !intobj1->reversed)
    edpar1 =  edpar1->next;

  if(edpar2 && begin2 && intobj2->reversed)
    edpar2 = edpar2->next;
  else if(edpar2 && !begin2 && !intobj2->reversed)
    edpar2 = edpar2->next;

 if(!edpar1 || !edpar2) goto wrapup;

 if(IF_EQ_OBJID(edpar1->edgeid, edpar2->edgeid))
  are_exact = TRUE;
 else
  {
   sts = om$is_objid_on_channel(objid_c = edpar1->edgeid,
				osnum_c = sfos,  
				p_chanselect = to_common_edge, 
				objid = edpar2->edgeid, osnum2 = sfos);
   if(sts == OM_S_SUCCESS)
    {
     if( (edpar1->intloc == EMScvint_middle) && 
       (edpar2->intloc == EMScvint_middle)) are_exact = TRUE;
     else if( (edpar1->intloc != EMScvint_middle) &&
	    (edpar2->intloc != EMScvint_middle)) are_exact = TRUE;
    }
   else if( (edpar1->intloc != EMScvint_middle) &&
	    (edpar2->intloc != EMScvint_middle)) are_exact = TRUE;
  }
 
wrapup:
 if(!are_exact)
  {
   if(exact1) *exact1 = FALSE;
   if(exact2) *exact2 = FALSE;
  }
 return(are_exact);

}


static void EMsfinttrace_ptrs_null (num_grps, num_subgrps_grp, 
				   num_elems_subgrp, elems, subgrp_rev, 
				   elem_rev, grp_closed, subgrp_closed)
IGRint *num_grps, **num_subgrps_grp, ***num_elems_subgrp;
struct EMSintobj ****elems;
IGRboolean ***subgrp_rev, ****elem_rev, **grp_closed, ***subgrp_closed;
{
 *num_grps = NULL;
 *num_subgrps_grp = NULL;
 *num_elems_subgrp = NULL;
 *elems = NULL;
 *subgrp_rev = NULL;
 *elem_rev = NULL;
 *grp_closed = NULL;
 *subgrp_closed = NULL;
}



static IGRint EMupdate_splitinfo(EMmsg, intdata, edpar, at_stop, partolbasis, 
				 sfos)
IGRlong			*EMmsg;
struct EMSdataselect	*intdata;
struct EMSsfintedpar	*edpar;
IGRboolean		at_stop;
struct EMSpartolbasis	*partolbasis;
GRspacenum		sfos;
{
 IGRlong		sts;
 IGRdouble		point[2], dumpt[2];
 struct EMSproj_info	proj_info;

 *EMmsg = EMS_S_Success;

 if(!intdata || !edpar) {*EMmsg = EMS_I_InvalidArg; goto wrapup;}
	
 sts = om$is_objid_valid(objid = edpar->edgeid, osnum = sfos);
 if(sts != OM_S_SUCCESS)
  {
   *EMmsg = EMS_I_Useless;
   sts = OM_S_SUCCESS;
   goto wrapup;
  }

 sts = EMgetendpts_uv(EMmsg, intdata, FALSE, 1, at_stop ? dumpt : point, 
			at_stop ? point : dumpt);
 if(!(1&sts&*EMmsg)) goto wrapup;

 sts = om$send(msg = message EMSedge.EMptproject
	    (EMmsg, point, 1, &proj_info, NULL, partolbasis), 
		senderid = NULL_OBJID, targetid = edpar->edgeid, 
		targetos = sfos);
 if(!(1&*EMmsg&sts)) goto wrapup;

#if DEBUG
 fprintf(stderr, "Updating splitinfo after extension\n");
#endif

 OM_BLOCK_MOVE(&proj_info.param, &edpar->edgepar, 
					sizeof(struct EMSedgebound));
 OM_BLOCK_MOVE(proj_info.proj_pt, edpar->point, 2*sizeof(IGRdouble));
 edpar->intloc = proj_info.location;

wrapup:
return(sts);
}


static IGRint EMorient_deg(EMmsg, intobj1, intobj2, inc, sfos, partol, 
                           newintobj, comed)
IGRlong *EMmsg;
struct EMSintobj *intobj1, *intobj2, *newintobj;
struct EMSpartolbasis *partol;
struct EMSsfintedpar *inc;
OM_S_OBJECT_LINKAGE *comed;
GRspacenum sfos;
{
 IGRlong 		sts = OM_S_SUCCESS, rc;
 struct GRid		*ed1, *ed2;
 IGRshort		location = EMS_L_UNKNWN;
 GRobjid		comlp = NULL_OBJID, thislp = NULL_OBJID;
 IGRushort		comlp_props = NULL, thislp_props = NULL;
 IGRboolean		rev_ornt = FALSE, EMorient_coinc();

 *EMmsg = EMS_S_Success;

 if(!intobj1 || !intobj2)
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 if( (intobj1->this_uvintobj.datatype != EMSdata_object) || 
     (intobj2->this_uvintobj.datatype != EMSdata_object))
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 ed1 = intobj1->this_uvintobj.data.object;
 ed2 = intobj2->this_uvintobj.data.object;

 if(intobj2->props & EMSintobj_degen_ornt_right)
  location = intobj2->reversed ? EMS_L_LEFT : EMS_L_RIGHT;
 else if(intobj2->props & EMSintobj_degen_ornt_left)
  location = intobj2->reversed ? EMS_L_RIGHT : EMS_L_LEFT;
 else
   (void) EMorient_coinc(EMmsg, NULL_OBJID, NULL, ed1->objid, ed2->objid, 
          NULL, NULL, partol, &location, NULL, ed1->osnum);


 /* If the orientation is still not known, try doing it with the
    incedent edge and then deducing for the 2 intobjs.
 */
 if(location == EMS_L_UNKNWN)
  {
   (void) EMorient_coinc(EMmsg, NULL_OBJID, NULL, inc->edgeid, ed1->objid, 
          NULL, NULL, partol, &location, NULL, ed1->osnum);
   if(location == EMS_L_RIGHT)
    location = EMS_L_LEFT;
   else if(location == EMS_L_LEFT)
    location = EMS_L_RIGHT;
   else
    {
     (void) EMorient_coinc(EMmsg, NULL_OBJID, NULL, inc->edgeid, ed2->objid, 
          NULL, NULL, partol, &location, NULL, ed2->osnum);
     if(location == EMS_L_RIGHT)
      location = EMS_L_LEFT;
     else if(location == EMS_L_LEFT)
      location = EMS_L_RIGHT;
    }
  }

 if(location == EMS_L_UNKNWN)
  goto wrapup;

 if(!(1&*EMmsg))
  {
   location = EMS_L_UNKNWN;
   goto wrapup;
  }

 if(intobj2->reversed)
  {
   if(location == EMS_L_RIGHT)
    location = EMS_L_LEFT;
   else if(location == EMS_L_LEFT)
    location = EMS_L_RIGHT;
  }

 if(newintobj)
  {

   /* If the common edge is owned by a C loop, the newelem should be oriented
      in reverse direction.
   */
   sts = ems$send_loops(msg = &rc, message = message EMSloop.EMget_objid
         (EMmsg, &comlp), sender_edge = comed->S_objid, all_mask =EMLP_ACTIVE);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &comlp_props), 
         targetid = comlp, targetos = comed->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = ems$send_loops(msg = &rc, message = message EMSloop.EMget_objid
         (EMmsg, &thislp), sender_edge = inc->edgeid, all_mask = EMLP_ACTIVE);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &thislp_props), 
         targetid = thislp, targetos = sfos, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   rev_ornt = (comlp_props & EMLP_PLOOP) ^ (thislp_props & EMLP_PLOOP) ? TRUE
                                                                      : FALSE;
   if( ((location == EMS_L_RIGHT) && !rev_ornt) ||
       ((location == EMS_L_LEFT) && rev_ornt))
    newintobj->props |= EMSintobj_degen_ornt_right;
   else if( ((location == EMS_L_LEFT) && !rev_ornt) ||
     ((location == EMS_L_RIGHT) && rev_ornt))
    newintobj->props |= EMSintobj_degen_ornt_left;
  }

 if(location == EMS_L_RIGHT)
  {
   intobj1->props |= EMSintobj_degen_ornt_right;
   intobj2->props |= EMSintobj_degen_ornt_right;
  }
 else if(location == EMS_L_LEFT)
  {
   intobj1->props |= EMSintobj_degen_ornt_left;
   intobj2->props |= EMSintobj_degen_ornt_left;
  }

wrapup:
if(location == EMS_L_UNKNWN)
 *EMmsg = EMS_E_Fail;
return(sts);
}
end implementation Root;

