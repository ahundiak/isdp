class implementation EMScompsurf;

/*

HISTORY
	09 May 93	ashok		Creation.
        17 Jun 93       NP              Changed "EMmkintlist" calls to the 
                                        new name "EMmakeintlist" due to addition
                                        of two new curve type parameters.
                                        NOTE: TRY AND SET CURVE TYPES 
                                              MEANINGFULLY IN THE CALL 
                                              (CURRENTLY SET TO NULL).
        08 jul 93        Sudha           Modified for BSprototypes ansification
	08 Jul 93	ashok		Modified EFcvt_edge_to_cv() to
					increase the bspline order of the
					output curve conditionally. Updated
					'DESCRIPTION' below.
	01 Sep 93	ashok		Added "ls_bdrys" argument to
					EFext_and_prj_cv()
	07 Sep 93	ashok		Modified EFcvt_edge_to_cv() to always
					check for planarity of surface.
        08 Sep 93       Sudhakar        Moved the function 
                                        'EFcreate_outward_offset_by_half_
                                         thickness' into this file.
	15 Oct 93	ashok		Added new function EFmkint_from_edge().
					Also added two arguments to
					EFget_edge_info().
        28 Oct 93       sudhakar        Modified tangency check to use
					EMS_ZERODEG_ANGLE(EFget_sf_extensions). 
                                        Using 'dominant' edge to determine the
					'angle measure' for consistency
                                        (EFget_edge_info). 
                                        Using the new math function 'EMpjcvnsrf'
                                        for mapping of curve onto the surface
                                        if the existing 'EFmap_the_curve' 
                                        returns more than one mapped curve
                                        (EFext_and_prj_cv).
        05 Nov 93       sudhakar        Added code to pass the offset distances
                                        of the adjacent surfaces to the
                                        "EFget_sf_extensions" function (two
                                        new args). This enables handling
                                        large differences in the multiple
                                        offset distances of adjacent surfaces.
	25 Nov 93	ashok		Enhanced EFget_sf_extensions() to
				 	detect tangential iso edges and restrict
					extension along corresponding natural
					directions to a minimum (5 times CHT)
        29 Nov 93       sudhakar        Added a new function 
                                        'EFmkint_from_isocurve()'.
        13 Dec 93       sudhakar        Fixed a bug in function "EFget_sf_ext.."
                                        in handling of adjacent surface offset
                                        distances [TR# 119313969].
        17 Dec 93       sudhakar        Modified the function 
                                        "EFget_sf_extensions" to :
                                         a) use a better method to obtain the
                                            loopset range; and
                                         b) not process "natural" and "iso"
                                            edges which are also "seams".
                                            [Fix for TR# 119312081]
	29 Dec 93	ashok		Modified EFext_and_prj_cv() to support
					two new arguments (options and num_out)
        04 Jan 93       sudhakar        Modified "EFget_sf_extensions" function
                                        such that seams are handled properly.
                                        Modified "EFproj_vert_to_intobj" func.
                                        to project the vertex always when the
                                        number of incident intobjs is "0" and
                                        the two edges are not free edges.
                                        Added a new arg. "option" to the
                                        function "EFcvt_edge_to_cv". If this
                                        option is set to "DONOT_FIT_BSPLINE_
                                        CURVE", then fitting is not done. 
        11 Jan 94       ashok           Calling math function BSrmdblpts()
                                        to remove duplicate points before
                                        calling BSdirfitcv() in
                                        EFcvt_edge_to_cv().
        11 Jan 94       sudhakar        Added three new functions :
                                         EFchk_special_tangent() - which checks
                                           whether an edge is a special tangent.
                                         EFconvert_anglemeasure_to_angle().
                                         EFwill_edges_stitch_after_projection()-
                                           which checks whether projected edges 
                                           stitch on the offset composite.
                                        Modified EFget_sf_extensions() to 
                                        give maximum extensions when special
                                        tangent edges exist (TR# 119312801). 
        24 Jan 94       sudhakar        Modified the logic of the function
                                        "EFchk_special_tangent()" to identify
                                        only those tangent edges which are 
                                        a) [globally neutral OR have curvature
                                           continuity]     AND
                                        b) have the number of edges at 
                                           atleast one of the vertices as > 3
                                             AND
                                        c) atleast one of the vertex edges
                                           is either convex or concave.
                                        This fixed lot of regression problems
                                        caused due to unwanted surface 
                                        extensions.
        03 Feb 94      sudhakar         Fix for TR# 119416612. Ensuring that
                                        max-extension distance is non-zero even
                                        if all adjacent surfaces are open.
        02 Sep 94      sanjay           Added additional checks to not to call
                                        BSdirfitcv routine in case if the surf
                                        is planar and curve type is orthogonal
                                        polygon, polygon and infinite line. 
                                        This fixes one of the problem faced by
                                        FOLD.
        07 Sep 95      Jagan            Added an option is_full for the function
                                        EFmkint_from_isocurve which make intobj
                                        out of  iso_curve from U=0 to U=1 if 
                                        is_full= 0 else with in the limits 
                                        specified.  
        24 Oct 95      Jagan            BSpolyxdst() fails when curve is to be 
                                        extended by the dist more than a 
                                        critical distance.So in such cases
                                        the curve is extended in steps. 
        12 Nov 97      Kiran            EFget_edge_info is giving the neutrality
                                        bit from the angle greater than 177.1 de
                                        g. So the limiting tolerance has been
                                        changed to what is available in EFcheck_
                                        is_neutral() function which is used for
                                        rounding.
                                
					
DESCRIPTION

This file contains the supporting functions needed by the general
'composite-surface offset' functionality.

EFintobj_matches_edge() - Given an edge and a bunch of intobjs this function
			  determines the intobj corresponding to the edge.

EFcvt_edge_to_cv() - Given an edge this function returns its b-spline
		     geometry.

EFext_and_prj_cv() - Given a curve geometry this function extends the curve
		     at either ends by given distances and then projects it
		     on to the input surface. The fuction returns the
		     projected curve(s) as an EMSintobj linked list. It also
		     appends the intobj(s) to the input EMSinters list.
		     Optionally it can trim the curve w.r.t the loopset of
		     the surface and return the loopset trim info in "ls_bdrys".

EFconvert_seam_to_intobjs() - Generates the intobjs correspon-
                              ding to natural seams of the
                              input surface.

EFare_intobjs_reverse_connected() - Checks whether the current
                                    intobj pair are reverse
                                    connected by comparing the
                                    the 'pos-orient' bits of
                                    corresponding surfaces.

EFproj_vert_to_intobj() -  Given a vertex defined by two consecutive edges
			   this function determines the total number of edges
			   incident at this vertex. If this number is 2 OR if
			   either of the two edges input is free, then it
			   determines if the 2 edges are tangential. If so it 
			   projects the vertex onto the input intobj and outputs
			   the result in an EMSpypoint structure.

EFget_sf_extensions() - Given the original surface, its offset, the offset
			distance, direction of offset etc, this function
			computes the amount of extension that need to be
			applied to the offset in each of its 4 natural
			directions in order to produce intersections with
			the adjacent surfaces.

EFcreate_partial_sf() - Given that the incoming surface's natural definition
			is physically closed in U or V this function 
			determines whether any outer loop of the surface
			is closed or not. If not, an equivalent "open" surface
			is created using the 'EMreduce_range' method.


EFget_component_offsets() - Given a set of surfaces and offset distances
			    this function constructs the offset surfaces
			    and outputs an array of a structure containing
			    offset surface id and properties like closure,
			    planarity etc. It also outputs the adjacent
			    surfaces for each surface.

EFget_edge_info() - Given an edge this function returns information about it
		    such as properties, whether convex or cocave, its
		    common-edge and its common surface.

EFget_offsetdistance_for_surface - Function for Determining the offset distance
				   for a surface given the 'specific surface 
				   offset information'.

EFcreate_outward_offset_by_half_thickness - Function for Determining the 
					    outward offset surface with the
					    common and specific offset distances
					    halved. This is used in case
					    of 'symmetric' thinwall.

EFmkint_from_edge() - Given a surface and an edge on it, this function
                      creates an intersection object out of it and inserts it
                      into the incoming intersection list.

EFmkint_from_isocurve - This function extracts the iso curve on a surface based
                        on a u/v parameter and direction, reversing it if
                        needed; creates an intersection object and inserts
                        it into the incoming intersection list. 

EFchk_special_tangent() - Checks whether an edge is a special tangent edge. 
                          A special tangent edge is an edge along which
                          the two surfaces meeting at the edge have second order
                          continuity.

EFwill_edges_stitch_after_projection() - Given the two surfaces and (tangent)
                                         edges of the surfaces, this function
                                         determines whether the given two edges
                                         can be stitched after offsetting the
                                         respective surfaces.
EFconvert_anglemeasure_to_angle() - Given the angle measure i.e. the value
                                    which is output by EMSedge.EMchkconvex
                                    method, this returns the angle in degrees.
*/

#include "OMmacros.h"
#include "EMS.h"
#include "EMSasdef.h"
#include "EMSssprops.h"
#include "bsvalues.h"
# include "EMSopt.h"    /* EMS_OPT_ALL EMS_opt_offsetS_copy_topology */
# include "EMSprop.h"   /* EMED_XYZ_CLOSED EMED_DEGENERATE */
/* # include "ems_m_inc.h" Includes the world */
# include "gocmacros.h" /* Include generate abstract macro */
# include "EMS_E.h"     /* EMS_E_InsufficientDynamicMemory */
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsarclen.h"
#include "msdef.h"
#include "msmacros.h"
#include "emsmapdef.h"
#include "EMSsplitdef.h"
#include "emsedgedef.h"
#include "emsimpdef.h"
#include "bspartofcv.h"
#include <float.h>

%safe
#include <math.h>
#include "bststcvfln.h"
#include "bsptlngen.h"
#include "bspolyxtdst.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsnorkts.h"
#include "bsmdistptsf.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsdirfitcv.h"
#include "bscnvtomkt.h"
#include "bsalloccv.h"
#include "bsrev_cv.h"
#include "bsrmdblpts.h"

%endsafe

#define FIRST	0
#define SECOND	1
#define UNKNOWN -1
#define NEUTRAL 0
#define CONVEX  1
#define CONCAVE 2
#define U0 0
#define V1 1
#define U1 2
#define V0 3
#define OPEN        0
#define UV_CLOSURE  1
#define XYZ_CLOSURE 2

#define U_CLOSED     0x1
#define V_CLOSED     0x2
#define PLANAR       0x4
#define SEAM_DELETED 0x8

#define U_LEFT   0
#define U_RIGHT  1
#define V_LEFT   2
#define V_RIGHT  3

#define M_PI            3.14159265358979323846
#define CONST_U  0
#define CONST_V  1

struct EMSoff_sf_info
{
   GRobjid	     objid;       /* objid of the offset sf component */
   IGRdouble	     distance;    /* offset distance for the sf component */
   IGRushort	     props;       /* sf attributes such as phy_closed, planar etc */
   IGRint	     num_adj_sfs; /* No of common edge sfs for this sf */
   IGRint	     *adj_sfs;    /* indices to common sfs w.r.t surfs[] array */
};

from EMSsubbs import EMget_props, EMpartolbasis, EMgetbsdef;
from EMSsubbs import EMget_natedge_info, EMss4poles, EMreduce_range;
from EMSedge import EMpt_location, EMchkconvex, EMinternalpt, EMendpts;
from EMSedge import EMget_props, EMget_bcxyz_geom, EMget_props_type;
from EMSedge  import EMgetvtxedges, EMxyz_endpt, EMtangent, EMextractyourself,
		     EMgetpygeom;
from EMSloop  import EMget_edges;
from EMSloopset import EMget_loops, EMbounded_uv_range, EMgetrange;
from EMSboundary import EMgetsurface_info, EMget_objid;
from EMSsubbs    import EMpratmpt, EMsfradcrv;

/*****************************************************************************/
IGRboolean EFintobj_matches_edge(msg, p_intobj, edge, p_surf1, p_partolb, 
	   dist, chk_tol, p_mattyp, matrix, pp_match, p_mdist,
	   p_closure_info)
/*****************************************************************************/
IGRlong			*msg;
struct EMSintobj	*p_intobj, **pp_match;
GRobjid			edge;
struct GRid		*p_surf1;
struct EMSpartolbasis	*p_partolb;
IGRdouble		dist, chk_tol, *p_mdist;
IGRshort		*p_mattyp;
IGRmatrix		matrix;
IGRint			*p_closure_info;
/*

Description:
This function tests if the input intobj(s) produced by intersecting the offsets
of 2 adjacent surfaces of a composite) corresponds to the common edge ("edge")
between the two. It also returns the type of "edge" ie concave or convex.

Algorithm:
	o Get an internal point on the input edge.
	o FOR each input intobj:
	  o If the incoming edge is closed but the intobj is not closed
	    then this intobj cannot be a match. Skip to next intobj, if any.
	  o Project edge internal point on to the intobj. Also get minimum 
	    distance.
	  o If the minimum distance is > a factor then this is probably
	    not a matching intobj.
	  o Now project this point on the intobj on to the input surface (to
	    which "edge" belongs.
	  o If the projected point on the surface lies on the "edge" then
	     the "edge" and "intobj" probably match. 

            Else if check if the distance between the projected point
	       on the surface from the intobj is greater than "dist" (typically
	       the offset distance) OR if this intobj had earlier been 
	       identified as "potentially not matching". If so, the "edge" 
               and this "intobj" DO NOT match. Process next intobj.
	    Else
	       the "edge" and "intobj" probably  match.

	  o At this point we know that the intobj is a potential candidate.
	    If this intobj's "minimum-distance" from the edge is less than 
	    the "minimum- distance" of all other intobjs so far then this 
            intobj is the matching intobj of all the intobjs processed so far.

	  o Process next intobj if any.

*/
{
IGRlong 		i, msg_loc, stat_OM;
IGRboolean		matched, possible_mismatch;
IGRushort		ed_props;
IGRpoint		pnt, pnt2;
struct GRparms		proj_parms;
IGRdouble		min_dist, mdist_sofar, fb_mdist_sofar, uv[2], lentol;
struct EMSpypoint	py_pt;
struct EMSintobj	*match_int=NULL, *fb_match_int=NULL;
struct EMSptloc_info	info;

IGRboolean		EMintobj_closed();
IGRlong			EMprojectpt();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  matched = FALSE;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);

/* Get edge properties */
  stat_OM = om$send(msg = message EMSedge.EMget_props(&msg_loc, &ed_props),
            	    senderid = NULL_OBJID,
		    targetos = p_surf1->osnum,
		    targetid = edge);
  EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  mdist_sofar = MAXDOUBLE;
  fb_mdist_sofar = MAXDOUBLE; /* fb stands for "fall-back" */
  for(i=0; p_intobj; p_intobj=p_intobj->next, i++)
  {
    if(!(ed_props & EMED_OPEN) && 
       !EMintobj_closed(&msg_loc, p_intobj, FALSE, p_partolb->tol)) continue;

    if((ed_props & EMED_XYZ_CLOSED) && 
       !EMintobj_closed(&msg_loc, p_intobj, TRUE, lentol)) continue;

    if(i==0 && !(p_intobj->next)) /* only one intobj in incoming list */
    {
        match_int = p_intobj;
	matched = TRUE;
        break;
    }
    else if(i==0)
    {
    /* get an internal point on "edge" in uv[] */
	stat_OM = om$send(msg = message EMSedge.EMinternalpt(&msg_loc, 1,
				          NULL, uv, NULL, p_partolb),
		    senderid = NULL_OBJID,
		    targetos = p_surf1->osnum,
		    targetid = edge);
	EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, 
		     ret_end);

    /* get the XYZ coordinates corresponding to uv[2] in pnt[3] */
	stat_OM = om$send(msg = message GRvg.EMptatpr (&msg_loc, p_mattyp, 
						       matrix, uv, 2, pnt),
                    senderid = NULL_OBJID,
                    targetos = p_surf1->osnum,
                    targetid = p_surf1->objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
                     ret_end);

    }

   /* Project the edge's internal point on to the intobj */
    stat_OM = EMprojectpt(&msg_loc, p_mattyp, matrix, 
			  &p_intobj->this_xyzintobj, 1, 
			  pnt, lentol, &py_pt, &min_dist);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

   /* Examine min_dist to aid in taking a decision later.
      TBD: Currently using 3 times dist to be the limiting distance. Need to
        verify its correctness.
   */
    if((min_dist - 3 * dist) > chk_tol) possible_mismatch = TRUE;
    else possible_mismatch = FALSE;

   /* Project on to the surface containing "edge" */
    stat_OM = om$send(msg = message GRgraphics.GRptproject(&msg_loc, p_mattyp,
				  matrix, py_pt.point, pnt2, &proj_parms),
		      senderid = NULL_OBJID,
		      targetos = p_surf1->osnum,
		      targetid = p_surf1->objid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  /* Classify the location of the point w.r.t "edge" */
    uv[0] = proj_parms.u;
    uv[1] = proj_parms.v;

    stat_OM = om$send(msg = message EMSedge.EMpt_location(&msg_loc, uv,
			  &info, NULL, p_partolb),
		      senderid = NULL_OBJID,
		      targetos = p_surf1->osnum,
		      targetid = edge);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

    if(info.location != EMS_L_ONEDGE && info.location != EMS_L_ONVRTX)
    {
     if(possible_mismatch ||
        fabs(BSdistptpt(&msg_loc, py_pt.point, pnt2) - dist) > chk_tol)
	{
	  /* set-up the alternate criterion for a "fall-back" matching intobj
	     in case the first criterion fails to produce a match
	  */
	  if(min_dist < fb_mdist_sofar)
	  {
	     fb_mdist_sofar = min_dist;
	     fb_match_int = p_intobj;
	  }
          continue;
	}
    }
    matched = TRUE;
    if(min_dist < mdist_sofar)
    {
      mdist_sofar = min_dist;
      match_int = p_intobj;
    }
  } /* for (mdist_sofar= .... ) */

  if(!matched)  /* Check if we have a "fall-back" intobj that most closely
		   matches the input edge */
  {
     if(fb_match_int)
     {
	match_int = fb_match_int;
	mdist_sofar = fb_mdist_sofar;
        matched = TRUE;
     }
  }
  if(matched)
  {
    if(pp_match) *pp_match = match_int;
    if(p_mdist) *p_mdist = mdist_sofar;

    if(p_closure_info)
      if(!(ed_props & EMED_OPEN)) *p_closure_info = UV_CLOSURE;
      else if(ed_props & EMED_XYZ_CLOSED) *p_closure_info = XYZ_CLOSURE;
      else
	*p_closure_info = OPEN;
  } /* if(matched) */

ret_end:
  return(matched);
}

/****************************************************************************/
void EFcvt_edge_to_cv(msg, option, ed_grid, sf_grid, curve, mdenv_info)
IGRlong			*msg;
IGRushort               option;
struct GRid		ed_grid, *sf_grid;
struct IGRbsp_curve	**curve;
struct GRmdenv_info	*mdenv_info;
/****************************************************************************/
{
  IGRlong		stat_OM, msg_loc;
  BSrc			rc;
  IGRuchar		cv_type;
  struct GRid		loc_sf_grid;
  struct GRprops	sf_props;
  struct IGRbsp_curve	*cv=NULL, *bs_cv=NULL;

    *msg = EMS_S_Success;

    if(!sf_grid)
    {
	   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info(
			           &msg_loc, &loc_sf_grid.objid, NULL),
			 senderid = NULL_OBJID,
			 targetid = ed_grid.objid,
			 targetos = ed_grid.osnum);
	   EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, 
		       ret_end);
	   loc_sf_grid.osnum = ed_grid.osnum;

    }
    else loc_sf_grid = *sf_grid;

/* get the geometric properties  of the surface on which the curve is to be
   projected
*/
    stat_OM = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                                                    &(mdenv_info->matrix_type),
                                                    mdenv_info->matrix,
                                                    &sf_props),
                      targetid = loc_sf_grid.objid,
		      targetos = loc_sf_grid.osnum,
		      senderid = NULL_OBJID);
    EMerr_hndlr(EMSerror(msg_loc&stat_OM), *msg, EMS_E_SurfaceError, ret_end);

    cv = (struct IGRbsp_curve *) om$malloc(size = 
 			                    sizeof(struct  IGRbsp_curve));
    EMerr_hndlr(!cv, *msg, EMS_E_DynamicMemoryAllocated, ret_end);
    cv->poles = cv->knots = cv->weights = NULL;

  /* Extract the XYZ bspline geometry of the edge */

    stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc, 
				    mdenv_info, &loc_sf_grid, 
				    NULL, 0, OM_K_MAXINT, FALSE, NULL, cv),
		      senderid = NULL_OBJID,
		      targetid = ed_grid.objid,
		      targetos = ed_grid.osnum);
    EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

    *curve = cv;

    stat_OM = om$send(msg = message EMSedge.EMget_props_type(&msg_loc, 
					    NULL, &cv_type),
		      senderid = NULL_OBJID,
		      targetid = ed_grid.objid,
		      targetos = ed_grid.osnum);
    EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  /* If the xyz geometry is order 2 then fit a b-spline curve iff:
      - the surface is planar and the curve-type is not a "line-string"
				OR
      - the surface is non-planar (irrespective of the curve-type)
  */
    if(!(option & EMSEdgCrv_DONOT_FIT_BSP_CURVE) &&
       cv->order == 2 && cv->num_poles > 2 && 
       ((sf_props.planar && (cv_type != EMlinestring && 
		             cv_type != EMorthogonal_linestring &&
        	             cv_type != EMplanar_linestring &&
                             cv_type != EMorthogonal_polygon &&
                             cv_type != EMpolygon &&
                             cv_type != EMinfinite_line))       ||
	 !sf_props.planar))

    {
      IGRlong			i, count;
      IGRint			type;
      IGRshort			order, new_num;
      IGRpoint			start_point, end_point;
      IGRvector			vec1, vec2;
      IGRboolean		is_line, stat_func;
      IGRdouble			*new_pts;

    /* Check if the curve van be converted to a simple line-segment. If so
       convert it.
    */
      BStstcvfln(cv, &is_line, start_point, end_point, &rc);
      EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
/*
 * If it is a degenerate line then math does not return end points.
 */
      if(is_line == 2)	/* line-seg degenerate */
      {
	for(i=0; i<3; i++) start_point[i] = cv->poles[i];
        if (cv->rational)
        {
           IGRdouble	weight;
           weight = cv->weights[0];
	   for(i=0; i<3; i++) start_point[i] /= weight;
        }
	for(i=0; i<3; i++) end_point[i] = start_point[i];
      }

      if(is_line)
      {
	stat_func = BSptlngen(&rc, start_point, end_point, cv, &type);
        EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
	goto ret_end;
      }

      new_pts = NULL;
      new_pts = (IGRdouble *) om$malloc(size = cv->num_poles * 3 * 
					    sizeof(IGRdouble));
      EMerr_hndlr(!new_pts, *msg, EMS_E_DynamicMemoryAllocated, ret_end);
      BSrmdblpts(&rc, (IGRshort)cv->num_poles, (IGRpoint *)cv->poles, 
		 &new_num, (IGRpoint *)new_pts);
      order = (new_num > 3 ? 4 : 3);
      bs_cv = (struct IGRbsp_curve *) om$malloc(size = 
				      sizeof(struct  IGRbsp_curve));
      EMerr_hndlr(!bs_cv, *msg, EMS_E_DynamicMemoryAllocated, ret_end);
      count = new_num + order - 1;
      bs_cv->poles = NULL;
      bs_cv->poles = (IGRdouble *) om$malloc(size = count * 3 * 
					    sizeof(IGRdouble));
      EMerr_hndlr(!bs_cv->poles, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

      bs_cv->knots = NULL;
      count += order;
      bs_cv->knots = (IGRdouble *) om$malloc(size = count * sizeof(IGRdouble));
      EMerr_hndlr(!bs_cv->knots, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

      BSdirfitcv((IGRlong)new_num, (IGRpoint *)new_pts, order, 0, 0, FALSE,
		 vec1, vec2, bs_cv, &rc);
      EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
      om$dealloc(ptr = cv->poles);
      om$dealloc(ptr = cv->knots);
      if(cv->rational) om$dealloc(ptr = cv->weights);
      om$dealloc(ptr = cv);
      if(new_pts) om$dealloc(ptr = new_pts);
      *curve = bs_cv;
    }

ret_end:
    if(!(1 & *msg))
    {
	if(cv)
	{
	   if(cv->poles) om$dealloc(ptr = cv->poles);
	   if(cv->knots) om$dealloc(ptr = cv->knots);
	   if(cv->weights) om$dealloc(ptr = cv->weights);
	   om$dealloc(ptr = cv);
	}
	if(bs_cv)
	{
	   if(bs_cv->poles) om$dealloc(ptr = bs_cv->poles);
	   if(bs_cv->knots) om$dealloc(ptr = bs_cv->knots);
	   om$dealloc(ptr = bs_cv);
	}
    }
     return;
}

/****************************************************************************/
struct EMSintobj *EFext_and_prj_cv(msg, fr_sf_grid, to_sf_grid, opt,
	         p_partolb, cv, want_ext, dist1, dist2, mdenv_info, p_inters,
	         positioned, ls_bdrys, num_out)
/****************************************************************************/
IGRlong			*msg;
struct GRid		fr_sf_grid, to_sf_grid;
IGRushort		opt;
struct EMSpartolbasis	*p_partolb;
struct IGRbsp_curve	*cv;
IGRboolean              want_ext;
IGRdouble		dist1, dist2;
struct GRmdenv_info	*mdenv_info;
struct EMSinters	**p_inters;
IGRboolean		positioned;
struct EMSsfintedpar	***ls_bdrys;
IGRint			*num_out;
{
  IGRlong		stat_OM, msg_loc, j, k, num_bytes;
  BSrc			rc;
  IGRint		num_out_cvs;
  IGRushort		options;
  IGRboolean		world, stat_func,status;
  IGRshort		is_planar;
  IGRdouble		cht_tol,start,endp,dir,arc_len,total_dist= 0.0;
  IGRpoint		end_pt;
  struct IGRbsp_curve	*ext_cv1, *ext_cv2;
  struct IGRbsp_surface *sf_geom;
  struct GRid		dummy_grid, ls_grid;
  struct EMSdataselect  *uv_data, *xyz_data, ext_cv_data;
  struct EMSintobj	*tmp_intobj=NULL, *p_intobj=NULL;
  struct EMSpartolbasis	loc_partol;

  extern IGRboolean EFmap_the_curve() ;
  extern struct EMSintobj *EMmakeintlist();
  extern void EMpjcvnsrf();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  ext_cv1 = NULL;
  ext_cv2 = NULL;
  sf_geom = NULL;
  dummy_grid.objid = NULL_OBJID;
  dummy_grid.osnum = fr_sf_grid.osnum;
  ls_grid.objid = NULL_OBJID;
  ls_grid.osnum = to_sf_grid.osnum;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  if(!p_partolb)
  {
    world = TRUE;
    stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                             &mdenv_info->matrix_type, mdenv_info->matrix, 
			     &world, FALSE, &loc_partol.tol),
		       senderid = NULL_OBJID,
                       targetos = to_sf_grid.osnum,
                       targetid = to_sf_grid.objid);
    
    EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_SurfaceError,ret_end);
    loc_partol.in_world = TRUE;
    loc_partol.is_valid = TRUE;
    loc_partol.mattyp = &mdenv_info->matrix_type;
    loc_partol.mat = mdenv_info->matrix;
    p_partolb = &loc_partol;
  }

/* If trim info is to be output, this means that the input geometry is to
   be trimmed w.r.t the loopset of to_sf_grid. So get the id of the loopset.
*/
  if(ls_bdrys)
  {
    OM_S_CHANSELECT chan_to_loopset;
    OMuint num_lps;
    OM_S_OBJECT_LINKAGE comm_list[1];

    EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
    om$get_channel_objects(objid = to_sf_grid.objid,
			   osnum = to_sf_grid.osnum,
     			   p_chanselect = &chan_to_loopset, count = &num_lps,
			   size = 1, list = comm_list);
    EMerr_hndlr (num_lps != 1, *msg, EMS_E_Fail, ret_end);
    
    ls_grid.objid = comm_list[FIRST].S_objid;

  }

/* Get the b-spline geometry of the surface on which the curve is to be
   projected
*/
  stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                                 &(mdenv_info->matrix_type),
                                                 mdenv_info->matrix,
                                                 &num_bytes),
                    targetid = to_sf_grid.objid,
		    targetos = to_sf_grid.osnum,
		    senderid = NULL_OBJID);
  EMerr_hndlr(EMSerror(msg_loc & stat_OM), *msg, EMS_E_SurfaceError, ret_end);

  sf_geom = (struct IGRbsp_surface *) om$malloc(size = num_bytes);
  EMerr_hndlr(!sf_geom, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

  stat_OM = om$send (msg = message GRvg.GRgetgeom(&msg_loc,
                                                  &(mdenv_info->matrix_type),
                                                  mdenv_info->matrix,
                                                  (IGRchar *) sf_geom),
                    targetid = to_sf_grid.objid,
		    targetos = to_sf_grid.osnum,
		    senderid = NULL_OBJID);
  EMerr_hndlr(EMSerror(msg_loc & stat_OM), *msg, EMS_E_SurfaceError, ret_end);
  
  if(sf_geom->planar) is_planar = EMS_O_Planar;
  else is_planar = EMS_O_Unknown;

  if(want_ext)
  {
  /* Extend the curve by "dist1" and "dist2" respectively at either ends */
    BSalloccv(cv->order, (cv->num_poles)+(cv->order)-1, cv->rational,
	      (IGRshort)0, &ext_cv1, &rc);
    EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);

    for(j=0; j<3; j++)
	end_pt[j] = (cv->rational ? cv->poles[j]/cv->weights[0] : cv->poles[j]);
    if(dist1 != 0) 
     {
     BSpolyxtdst(cv, end_pt, dist1, ext_cv1, &rc);

     /* When the ext_dist is > a critical dist, BSpolyxtdst() fails 
        returning 'rc = BSOUTOFDESN' . In such cases extend the curve
        in steps.
     */
     if(rc == BSOUTOFDESN  )
     {
      do
       {
        start = cv->knots[cv->order - 1];
        endp  = cv->knots[cv->num_poles];
        dir   = (start + endp )/2.0;
        BSarclen(&rc,&status,cv,&start,&endp,&dir,&arc_len);
        total_dist += arc_len;
        if( total_dist < dist1) BSpolyxtdst(cv, end_pt, arc_len, ext_cv1, &rc);
        if((rc == BSWARN) || BSERROR(rc)) break;
        cv = ext_cv1 ;
       } while( total_dist < dist1);
      }
    if(rc == BSWARN)
    {
#ifdef DEBUG
       printf("Curve Closed on First Extension\n");
#endif
    }
    EMerr_hndlr(BSERROR(rc) && (rc != BSWARN), *msg, EMS_E_BSerror, ret_end);
    }
    else
    ext_cv1 = cv;

    if(ext_cv1->periodic)
    {
       stat_func = BScnvtomkt(&rc, ext_cv1);
       EMerr_hndlr (!stat_func, *msg, EMS_E_BSerror, ret_end);
    }
    stat_func = BSnorkts(&rc, &ext_cv1->order, &ext_cv1->num_poles,
                         ext_cv1->knots);
    EMerr_hndlr (!stat_func, *msg, EMS_E_BSerror, ret_end);

    BSalloccv(ext_cv1->order, (ext_cv1->num_poles)+(ext_cv1->order)-1, 
	      ext_cv1->rational, (IGRshort)0, &ext_cv2, &rc);
    EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);

    k = 3 * (ext_cv1->num_poles - 1);
    for(j=0; j<3; j++)
	end_pt[j] = (ext_cv1->rational ? 
		ext_cv1->poles[k+j]/ext_cv1->weights[(ext_cv1->num_poles)-1] :
			ext_cv1->poles[k+j]);
    if(dist2 != 0)
    {
      BSpolyxtdst(ext_cv1, end_pt, dist2, ext_cv2, &rc);

     /* When the ext_dist is > a critical dist, BSpolyxtdst() fails 
        returning 'rc = BSOUTOFDESN' . In such cases extend the curve
        in steps.
     */
      if(rc == BSOUTOFDESN  )
      {
        total_dist = 0.0;
        do
        {
          start = ext_cv1->knots[cv->order - 1];
          endp  = ext_cv1->knots[cv->num_poles];
          dir   = (start + endp )/2.0;
          BSarclen(&rc,&status,ext_cv1,&start,&endp,&dir,&arc_len);
          total_dist += arc_len;
          if( total_dist < dist2) 
               BSpolyxtdst(ext_cv1, end_pt, arc_len, ext_cv2, &rc);
          if((rc == BSWARN) || BSERROR(rc)) break; 
          ext_cv1 = ext_cv2 ;
         } while( total_dist < dist2);
       }
       if(rc == BSWARN)
    {
#ifdef DEBUG
       printf("Curve Closed on Second Extension\n");
#endif
    }
    EMerr_hndlr(BSERROR(rc) && (rc != BSWARN)&&(rc != 12), *msg,
                                         EMS_E_BSerror, ret_end);
    }
    else 
      ext_cv2 = ext_cv1;

    if(ext_cv2->periodic)
    {
       stat_func = BScnvtomkt(&rc, ext_cv2);
       EMerr_hndlr (!stat_func, *msg, EMS_E_BSerror, ret_end);
    }
    stat_func = BSnorkts(&rc, &ext_cv2->order, &ext_cv2->num_poles,
                         ext_cv2->knots);
    EMerr_hndlr (!stat_func, *msg, EMS_E_BSerror, ret_end); 
  }  /* end of if(want_ext) */

  /* Now map (project) the extended curve on to 'to_sf_grid' */

    options = EMMapBnd_StrokeIfNeeded  | EMMapBnd_NoCurveType | 
	      EMMapBnd_WantBadCurves | EMMapBnd_NoValidate; 
    if(opt & EMSExtPrj_NoClip) options |= EMMapBnd_NoClip;
    num_out_cvs = 0;
    uv_data = xyz_data = NULL;
    EFmap_the_curve(dummy_grid, 
                    (want_ext ? ext_cv2 : cv), 
                    sf_geom, ls_grid, &cht_tol, 
		    p_partolb, options, &is_planar, &num_out_cvs, &uv_data, 
		    &xyz_data, NULL, ls_bdrys, FALSE, &msg_loc);
#ifdef DEBUG
 if(num_out_cvs != 1)
     printf("The number of curves from EFmap_the_curve = %d\n", num_out_cvs);
#endif
    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,  ret_end);

    /* If the number of mapped curves is NOT EQUAL to 1 and the option
       EMSExtPrj_WantSingleOut is set we need to error out. If clipping w.r.t
       loopset has not been requested we attempt mapping again using the
       new Math function
    */
    EMerr_hndlr((num_out_cvs != 1 && (opt & EMSExtPrj_WantSingleOut) &&
	        !(opt & EMSExtPrj_NoClip)), *msg, EMS_E_Fail,  ret_end);
    if(num_out_cvs != 1 && (opt & EMSExtPrj_NoClip))
    {
      double *p_refpt=NULL;
      IGRpoint refpt;
      extern void EMdataselect_data_free();

     /* Call the function which uses the new math function for mapping
        of the curve. This allows for a single component of the
        mapped curves to be returned, using the 'nearest to an input point'
        criterion. */
      ext_cv_data.datatype = EMSdata_curve3d;
      ext_cv_data.data.curve = (want_ext ? ext_cv2 : cv);

      if(uv_data) EMdataselect_data_free(&msg_loc, uv_data, num_out_cvs);
      if(xyz_data) EMdataselect_data_free(&msg_loc, xyz_data, num_out_cvs);

      uv_data = xyz_data = NULL;

     /* Call the new math based function. If the request is to get back a
        single curve, then use an internal point on the unextended curve
        to single out the one piece in case of ambiguity. */
      if (opt & EMSExtPrj_WantSingleOut && cv)
      {
        struct EMSdataselect cvgeom;

        cvgeom.datatype = EMSdata_curve3d;
        cvgeom.data.curve = cv;
        EMinternalpt (&msg_loc, NULL, NULL, &cvgeom, 
         EMScvint_middle, 1, refpt);
        if (!EMSerror (msg_loc))
        {
          p_refpt = refpt;
          uv_data = (struct EMSdataselect *) 
                     malloc (sizeof (struct EMSdataselect));
          xyz_data = (struct EMSdataselect *) 
                      malloc (sizeof (struct EMSdataselect));
        }
      }

      EMpjcvnsrf(&msg_loc, NULL, sf_geom, &ext_cv_data, cht_tol,
                           p_refpt, &num_out_cvs, &uv_data, &xyz_data);
      EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,  ret_end);

      if (num_out_cvs != 1 && (opt & EMSExtPrj_WantSingleOut))
      {
#ifdef DEBUG
           printf("Number of curves mapped by EMpjcvnsrv = %d\n", num_out_cvs);
           printf("Give File name to output bad extended curve\n");
           prtbspc(ext_cv_data.data.curve);
#endif
           if(uv_data) EMdataselect_data_free(&msg_loc,
                                         uv_data, num_out_cvs);
           if(xyz_data) EMdataselect_data_free(&msg_loc,
                                         xyz_data, num_out_cvs);
	   EMerr_hndlr(TRUE, *msg, EMS_E_Fail,  ret_end);
      }
    }

    for(j = 0; j < num_out_cvs; j++)
    {
      tmp_intobj =  EMmakeintlist(&msg_loc, p_inters, NULL, &to_sf_grid, NULL,
 	            NULL, NULL, NULL, NULL, &xyz_data[j], &uv_data[j],
		    NULL, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    TRUE, positioned);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      if(j == 0) p_intobj = tmp_intobj;
    }

ret_end:
  if(num_out) *num_out = num_out_cvs;
  if(sf_geom) om$dealloc(ptr=sf_geom);
  if(ext_cv1) BSfreecv(&rc, ext_cv1);
  if(ext_cv2) BSfreecv(&rc, ext_cv2);
  return(p_intobj);

}

/****************************************************************************/
IGRboolean EFconvert_seam_to_intobjs(msg, surf_grid, mdenv_info,
                                     p_inters, p_intobjs)
/****************************************************************************/
IGRlong                 *msg;
struct GRid             surf_grid;
struct GRmdenv_info     *mdenv_info;
struct EMSinters        **p_inters;
struct EMSintobj        *p_intobjs[2];
/* 
   This function converts the natural seam-edges of a surface into 'intobjs'
   and returns them in the 'p_inters' structure. The two seam-intobjs are
   connected to each other through the 'other_intobj_node' pointer. The
   'EMSintobj_seam' property is set for both the intobjs. 
   If the surface is closed in 'u' parameter 
     then the first intobj corresponds to u=0 and
          the second corresponds to u=1;
   If the surface is closed in 'v' parameter 
     then the first intobj corresponds to v=1 and
          the second corresponds to v=0;
 */
{

  IGRlong               stat_OM, msg_loc, i;
  IGRdouble             poles[4][3], uv[8], xyz[6];
  IGRushort             ed_props[4];
  struct IGRpolyline    poly;
  struct EMSdataselect  in_data, seam_data_uv, seam_data_xyz;

  extern struct EMSintobj *EMmakeintlist();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  poly.num_points = 2;
  stat_OM = om$send(msg = message EMSsubbs.EMget_natedge_info(&msg_loc,
                                           mdenv_info, NULL, ed_props),
                    senderid = NULL_OBJID,
                    targetid = surf_grid.objid,
                    targetos = surf_grid.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  if((ed_props[U0] & EMED_SEAM && ed_props[U1] & EMED_SEAM) ||
     (ed_props[V0] & EMED_SEAM && ed_props[V1] & EMED_SEAM) )
  {
    stat_OM = om$send(msg = message EMSsubbs.EMss4poles(&msg_loc, poles,
                                                        mdenv_info),

                      senderid = NULL_OBJID,
                      targetid = surf_grid.objid,
                      targetos = surf_grid.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
                 ret_end);
    if(ed_props[U0] & EMED_SEAM) /* surface closed in u */
    {
      uv[0] = 0.0; uv[1] = 0.0; uv[2] = 0.0; uv[3] = 1.0;
      uv[4] = 1.0; uv[5] = 0.0; uv[6] = 1.0; uv[7] = 1.0;
        for(i=0; i<3; i++)
      {
        xyz[i] = poles[0][i];
        xyz[3+i] = poles[2][i];
      }
    }
    else /* surface closed in v */
    {
      uv[0] = 0.0; uv[1] = 1.0; uv[2] = 1.0; uv[3] = 1.0;
      uv[4] = 0.0; uv[5] = 0.0; uv[6] = 1.0; uv[7] = 0.0;
      for(i=0; i<3; i++)
      {
        xyz[i] = poles[2][i];
        xyz[3+i] = poles[3][i];
      }
    }

    in_data.data.poly = &poly;
    for(i=FIRST; i<=SECOND; i++)
    {
      in_data.datatype = EMSdata_poly2d;
      poly.points = (i==0 ? uv : &uv[4]);
      stat_OM = EMmkintdata(&msg_loc, &in_data, NULL, NULL, FALSE, NULL, NULL,
                            FALSE, NULL, NULL, &seam_data_uv);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      in_data.datatype = EMSdata_poly3d;
      poly.points = xyz;
      stat_OM = EMmkintdata(&msg_loc, &in_data, NULL, NULL, TRUE, NULL, NULL,
                            FALSE, NULL, NULL, &seam_data_xyz);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      p_intobjs[i] = EMmakeintlist(&msg_loc, p_inters, NULL, &surf_grid, NULL,
                     NULL, NULL, NULL, NULL, &seam_data_xyz, &seam_data_uv,
                     NULL, i==0 ? FALSE : TRUE, NULL, NULL, NULL, NULL, NULL,
                     NULL, NULL, TRUE, i==0 ? FALSE : TRUE);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    } /* for(i=FIRST; i<=SECOND; i++) */
  p_intobjs[0]->other_intobj_node = p_intobjs[1];
  p_intobjs[1]->other_intobj_node = p_intobjs[0];
  p_intobjs[0]->props |= EMSintobj_seam;
  p_intobjs[1]->props |= EMSintobj_seam;
  p_intobjs[0]->props |= EMSintobj_isocurve;
  p_intobjs[1]->props |= EMSintobj_isocurve;
  return(TRUE);
  } /* if(ed_props[U0] ......) */
ret_end:
  return(FALSE);
}

/**************************************************************************/
IGRboolean EFare_intobjs_reverse_connected(msg, p_intobj)
IGRlong                 *msg;
struct EMSintobj        *p_intobj;
/**************************************************************************/
{
  IGRlong               msg_loc, stat_OM;
  IGRuchar              sf_props;
  IGRushort             pos_ornt_1, pos_ornt_2;
  IGRboolean            rev_connect=FALSE;
  struct GRid           surf_1, surf_2;
  struct EMSintobj      *p_otherintobj;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  p_otherintobj = p_intobj->other_intobj_node;
  surf_1 = p_intobj->this_obj_node->this_obj;
  surf_2 = p_otherintobj->this_obj_node->this_obj;
  stat_OM = om$send(msg = message EMSsubbs.EMget_props(&msg_loc, &sf_props),
                    senderid = NULL_OBJID,
                    targetid = surf_1.objid,
                    targetos = surf_1.osnum);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  pos_ornt_1 = (sf_props & EMSIS_NRML_REVERSED ? 0x1 : 0x0);

  stat_OM = om$send(msg = message EMSsubbs.EMget_props(&msg_loc, &sf_props),
                    senderid = NULL_OBJID,
                    targetid = surf_2.objid,
                    targetos = surf_2.osnum);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  pos_ornt_2 = (sf_props & EMSIS_NRML_REVERSED ? 0x1 : 0x0);

  if(pos_ornt_1 ^ pos_ornt_2) rev_connect = FALSE;
  else rev_connect = TRUE;

ret_end:
  return(rev_connect);

}

/*****************************************************************************/
IGRboolean EFproj_vert_to_intobj(msg, this_edge, next_edge, this_free, 
		                 sf_id, intobj, uvtol, lentol, env, py_pt)
/*****************************************************************************/
IGRlong			*msg;
struct GRid		*this_edge, *next_edge, *sf_id;
IGRboolean		this_free;
struct EMSintobj	*intobj;
IGRdouble		uvtol, lentol;
struct GRmd_env		*env;
struct EMSpypoint	**py_pt;
{

IGRlong			stat_OM, msg_loc, rc;
OMuint			count;
IGRint			num_edges;
IGRboolean		projected, next_free, *end_lis;
GRobjid			*edges;
IGRushort		options;
OM_S_CHANSELECT		chan_to_cm_ed;
struct IGRbsp_surface	*sf_geom=NULL;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  projected = FALSE;

  /* Check if common edge exists for next_edge  */
  EMmake_chanselect(EMSedge_to_common_edge, &chan_to_cm_ed);
  count = 0;
  stat_OM = om$get_channel_count(objid = next_edge->objid,
		        osnum = next_edge->osnum,
                        p_chanselect = &chan_to_cm_ed, count = &count);
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

  if(count)
     next_free = FALSE;
     else next_free = TRUE;

/* Get the number of edges at the right vertex of the input edge. Exclude
   common, seam and degenerate edges.
*/

  num_edges = 0;
  edges = NULL;
  end_lis = NULL;
  options = EMSvtxedges_onlydominant | EMSvtxedges_noseamedge | 
	    EMSvtxedges_nodegenerate;
  stat_OM = om$send(msg = message EMSedge.EMgetvtxedges(&msg_loc, options,
			  TRUE, 0, &num_edges, &edges, &end_lis),
		    targetid = this_edge->objid,
		    targetos = this_edge->osnum,
		    senderid = NULL_OBJID);
  EMerr_hndlr (!(msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  /* If either this_edge or next_edge is free  OR  
     If the number of vertex edges equals 2 then,
	We need to project the vertex on to the intobj if the two edges
	are tangential to each other at this vertex.
  */
  if((this_free || next_free) || num_edges == 2)
  {
     IGRdouble	dottol, dotp;
     IGRpoint	end_pt;
     IGRvector	vec1, vec2;

     stat_OM = om$send(msg = message EMSedge.EMxyz_endpt(&msg_loc, sf_id,
			             &env->md_env, NULL, NULL, NULL, end_pt,
				     &sf_geom),
		       targetid = this_edge->objid,
		       targetos = this_edge->osnum,
		       senderid = NULL_OBJID);
     EMerr_hndlr (!(msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
     stat_OM = om$send(msg = message EMSedge.EMtangent(&msg_loc, env, 
				     &sf_id->objid, end_pt, 1.0, NULL, vec1),
		       targetid = this_edge->objid,
		       targetos = this_edge->osnum,
		       senderid = NULL_OBJID);
     EMerr_hndlr (!(msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
     stat_OM = om$send(msg = message EMSedge.EMtangent(&msg_loc, env,
				     &sf_id->objid, end_pt, 1.0, NULL, vec2),
		       targetid = next_edge->objid,
		       targetos = next_edge->osnum,
		       senderid = NULL_OBJID);
     EMerr_hndlr (!(msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

     BSnorvec(&rc, vec1);
     BSnorvec(&rc, vec2);
     EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, ret_end);
     dottol = cos((90.0 - EMS_ZEROANGLE_DEG) * (M_PI/180.0));
     dotp = fabs(BSdotp(&rc, vec1, vec2));
#ifdef DEBUG
 printf(" 1.0 - dotp = %lg ; dottol = %lg\n", 1.0-dotp, dottol);
#endif

    /* Use the tangency test only if either this or the next edge
       is free. 
       If both edges are not free, check whether they have a 
       common "other" surface. If so, then project the vertex. 
       The reasoning is that, both these intobjs have been generated
       by intersection between the same pair of surfaces. Hence, the
       split point cannot be obtained by intersection. 
    */
     if( ((this_free || next_free) && (fabs(1.0 - dotp) < dottol)) ||
         (!this_free && !next_free && (num_edges == 2) ))
     {
	struct EMSpypoint	loc_pypt;
	IGRdouble		min_dist;
/*	IGRdouble		uv[2], base_point[3]; */
	struct EMSpypoint	*EMpypoint_malloc();
	IGRlong			EMprojectpt();

#ifdef DEBUG
printf("projected vertex to intobj\n");
#endif
	uvtol = uvtol; /* supress compiler warning */

	loc_pypt.next = NULL;
	stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			      env->md_env.matrix, &intobj->this_xyzintobj,
			      1, end_pt, lentol, &loc_pypt, &min_dist);
        EMerr_hndlr (!(msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

	*py_pt = EMpypoint_malloc(&msg_loc, 1);
	stat_OM = EMfind_uv_xyz_point (&msg_loc, &env->md_env,
		         &intobj->this_obj_node->this_obj, NULL,
			 &intobj->this_uvintobj, &intobj->this_xyzintobj,
			 FALSE, NULL, *py_pt, &loc_pypt);
/*
	if(! BSmdistptsf(&rc, sf_geom, loc_pypt.point, &uv[0], &uv[1],
	                 base_point, &min_dist))
           EMerr_hndlr (TRUE, *msg, EMS_E_BSerror, ret_end);


	stat_OM = EMprojectpt(&msg_loc, &env->md_env.matrix_type,
			      env->md_env.matrix, &intobj->this_uvintobj,
			      1, uv, uvtol, *py_pt, &min_dist);
        EMerr_hndlr (!(msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
*/
	projected = TRUE;
     }
  }
ret_end:

  if(edges) om$dealloc(ptr = edges);
  if(end_lis) om$dealloc(ptr = end_lis);
  if(sf_geom) om$dealloc(ptr = sf_geom);

  return(projected);
}

/* ************************************************************************* */
void EFget_sf_extensions(msg, orig_sf, off_sf, env, off_dist, off_inward, 
			 mult_off_dist, num_adjsfs, adjsfs_offdists, ext_dist)

IGRlong		*msg;
struct GRid	orig_sf, off_sf;
struct GRmd_env	*env;
IGRdouble	off_dist, ext_dist[4], *adjsfs_offdists;
IGRboolean	off_inward, mult_off_dist;
IGRint          num_adjsfs;
/* ************************************************************************* */
{
IGRlong			msg_loc, sts;
IGRint			num_loops, num_edges, buff_size, i, j, depth;
IGRboolean		has_convex, has_concave, has_cv_cx, has_neutral,
			has_free, convex, neutral, spec_tangent, free, 
                        no_ext_reqd[4], min_ext_reqd[4], max_ext_reqd[4],
			u_range_closed, v_range_closed;
IGRushort		*props, ed_props;
IGRdouble		ang_meas, range[4];
struct GRid		*edges, comm_surf, comm_ed;
OM_S_OBJID		*loop_ids;
OM_S_CHANSELECT		chan_to_loopset;
IGRdouble               cht;
IGRdouble               area;
IGRshort                across_seam;
IGRint                  split_ind;
IGRdouble               mid_uv[2];

IGRlong			EFget_edge_info();
extern    IGRdouble     fabs();

	*msg = EMS_S_Success;
	sts  = OM_S_SUCCESS;
        BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);

	loop_ids = NULL;
	props = NULL;
	edges = NULL;
	for(i=0; i<4; i++) ext_dist[i] = 0.0;

	/* Get all the loops in Current_Surface */
        props = NULL;
        depth = 1;     /* We are interested in outer loops only */
        buff_size = 0;
        num_loops = 0;
	no_ext_reqd[U_LEFT]=no_ext_reqd[U_RIGHT] = FALSE;
        no_ext_reqd[V_LEFT]=no_ext_reqd[V_RIGHT] = FALSE;
	min_ext_reqd[U_LEFT]=min_ext_reqd[U_RIGHT] = FALSE;
        min_ext_reqd[V_LEFT]=min_ext_reqd[V_RIGHT] = FALSE;
	max_ext_reqd[U_LEFT]=max_ext_reqd[U_RIGHT] = FALSE;
        max_ext_reqd[V_LEFT]=max_ext_reqd[V_RIGHT] = FALSE;

        EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
        sts = om$send(msg = message EMSloopset.EMget_loops
                        (&msg_loc, 0, &depth, &loop_ids, &props, &buff_size,
                         &num_loops),
                        senderid = orig_sf.objid,
                        p_chanselect = &chan_to_loopset);
        EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopsetError,ret_end);

        /* Get the u-v ranges of the surface. This method is more exact
           especially when seams exist on the surface. */
        sts = om$send(msg = message EMSloopset.EMbounded_uv_range
                                     (&msg_loc, range, &area, &across_seam,
                                      &split_ind, mid_uv, NULL, NULL, NULL),
                      senderid = orig_sf.objid,
                      targetos = orig_sf.osnum,
                      p_chanselect = &chan_to_loopset);
        EMerr_hndlr(EMSerror (sts & msg_loc), *msg, 
                                              EMS_E_LoopsetError, ret_end);
        
        u_range_closed = ((fabs(range[2]-range[0]) == 1.0) ? TRUE : FALSE);
        v_range_closed = ((fabs(range[3]-range[1]) == 1.0) ? TRUE : FALSE);
 
#ifdef DEBUG
 if(across_seam)
  printf("The loopset range is UMIN,VMIN - (%lg, %lg)  UMAX,VMAX -  %lg, %lg\n",
                      range[0], range[1], range[2], range[3]); 
#endif

	has_convex = has_concave = has_cv_cx = has_neutral = has_free = FALSE;
	for(i=0; i<num_loops; i++)
	{
           /* Get all the edges in this loop */
           buff_size = num_edges = 0;
           edges = NULL;
           sts = om$send(msg = message EMSloop.EMget_edges(&msg_loc, 1,
                               EMS_OPT_ALL, &edges, &buff_size, 
			       &num_edges),
                         senderid = NULL_OBJID,
                         targetos = orig_sf.osnum,
                         targetid = loop_ids[i]);
           EMerr_hndlr(EMSerror(sts & msg_loc), *msg, EMS_E_LoopError, ret_end);

	   for(j=0; j< num_edges; j++)
	   {
	   /* Check if edge is convex, concave, tangent or a free edge */
              convex = neutral = free = spec_tangent = FALSE;
              sts = EFget_edge_info(&msg_loc, &env->md_env.matrix_type,
				    env->md_env.matrix, edges[j], &comm_ed,
                                    &comm_surf, &ed_props, &free, &convex,
                                    &neutral, &spec_tangent, NULL, &ang_meas,
                                    NULL);
              EMerr_hndlr(! (1 & sts & msg_loc), *msg,EMS_E_EdgeError,ret_end);

	      if(!(ed_props & EMED_DEGENERATE))
	        if(free) has_free = TRUE; /* has no common edge */
	        else if(neutral) has_neutral = TRUE;  /* edge is tangent */
	        else if(convex) has_convex = TRUE;
	        else has_concave = TRUE;

             /* Since surface extensions can potentially cause closure
                and overlap of surfaces, the extension distances along
                the four natural directions need to be limited whereever
                possible. This following code checks for various 
                conditions and sets two kinds of flags for each of the
                four natural directions (viz: U_LEFT, U_RIGHT, V_LEFT, V_RIGHT)
                 "no_ext_req" flag:
                    This is set when the edge is:
                      a) degenerate natural edge or
                      b) free natural edge which is full range   or
                      c) tangent non-seam natural edge which is full range or 
                      d) tangent seam natural edge which is full range 
                          provided the surface is closed in the other parameter.
                          (eg. natural seam full range from u=0 to u=1 (v=0)
                               and surface is closed along v parameter
                                  => no_ext_req along V_LEFT).
                 "min_ext_reqd" flag:
                    This is set when the edge is:
                      a) free part-natural and at the end of the loopset range 
                                 or
                      b) iso and at the end of the surface loopset range.
                 "max_ext_reqd" flag:
                    This is set when a "special-tangent" iso edge is encountered
                    to ensure that the special tangent edge has the freedom to
                    move if necessary.
             */
                  
              if((neutral &&  
                         (fabs(ang_meas-2.0)<= EMS_ZEROANGLE_DEG))
                    || free || ed_props & EMED_DEGENERATE)
                       /*   ||   ed_props & EMED_SEAM) */
	      {
		if((ed_props & EMED_NATURAL) || (ed_props & EMED_ISO)) 
		{
		  IGRdouble start_loc[2], stop_loc[2];
		  IGRboolean u_dir=TRUE, full_nat=FALSE;

                  sts = om$send(msg = message EMSedge.EMendpts(&msg_loc,
                      		       start_loc, stop_loc, NULL, NULL, NULL),
			      	 senderid = NULL_OBJID,
                              	 targetos = edges[j].osnum,
				 targetid = edges[j].objid);
		  EMerr_hndlr(EMSerror(sts & msg_loc), *msg, EMS_E_EdgeError, 
			       ret_end);

		  if(start_loc[1] != stop_loc[1]) u_dir = FALSE;

                  if(spec_tangent)
                  {
                    if(u_dir)
                    {
                        if(start_loc[1] == range[1])
                           max_ext_reqd[V_LEFT] = TRUE;
                        else if(start_loc[1] == range[3])
                           max_ext_reqd[V_RIGHT] = TRUE;
                    }
                    else  /* v direction */
                    {
                        if(start_loc[0] == range[0])
                           max_ext_reqd[U_LEFT] = TRUE;
                        else if(start_loc[0] == range[2])
                           max_ext_reqd[U_RIGHT] = TRUE;
                    }
                  }

		  if((ed_props & EMED_NATURAL) && !spec_tangent)
		  {
		    if(u_dir) 
                    {
                      if(!(ed_props & EMED_SEAM) ||
                         ((ed_props & EMED_SEAM) && v_range_closed) )
		      {
		        if(start_loc[0] < stop_loc[0])
		        {
		  	  if(start_loc[0]==0.0 && stop_loc[0]==1.0)
		     	     full_nat = no_ext_reqd[V_RIGHT] = TRUE;
		        }
		        else
		        {
		  	  if(start_loc[0]==1.0 && stop_loc[0]==0.0)
			     full_nat = no_ext_reqd[V_LEFT] = TRUE;
		        }
                      }
		    }
		    else  /* v direction */
		    {
                      if(!(ed_props & EMED_SEAM) ||
                         ((ed_props & EMED_SEAM) && u_range_closed) )
                      {
		        if(stop_loc[1] < start_loc[1])
		        {
			  if(stop_loc[1]==0.0 && start_loc[1]==1.0)
			     full_nat = no_ext_reqd[U_RIGHT] = TRUE;
		        }
		        else
		        {
			  if(stop_loc[1]==1.0 && start_loc[1]==0.0)
			     full_nat = no_ext_reqd[U_LEFT] = TRUE;
		        }
                      } /* end of if(!(ed_props .. */
		    }
		  } /* ed_props & EMED_NATURAL */

		  if(((ed_props & EMED_NATURAL && !full_nat) ||
		     ed_props & EMED_ISO) && !spec_tangent) 
		  {
		    if(u_dir)
		    {
			if(start_loc[1] == range[1])
			   min_ext_reqd[V_LEFT] = TRUE;
			else if(start_loc[1] == range[3])
			   min_ext_reqd[V_RIGHT] = TRUE;
		    }
		    else  /* v direction */
		    {
			if(start_loc[0] == range[0])
			   min_ext_reqd[U_LEFT] = TRUE;
			else if(start_loc[0] == range[2])
			   min_ext_reqd[U_RIGHT] = TRUE;
		    }
		  } /* ed_props & EMED_NATURAL && !full_nat) || .... */
		} /* ed_props & (EMED_NATURAL | EMED_ISO) */
	      } /* neutral || free || degenerate */
	   } /* for(j=0; j< num_edges; j++) */
	   if(edges) om$dealloc(ptr = edges);
	   edges = NULL;
	} /* for(i=0; i<num_loops; i++) */
	if(loop_ids) om$dealloc(ptr = loop_ids);
	loop_ids = NULL;
	if(props) om$dealloc(ptr = props);
	props = NULL;

        if(has_convex && has_concave) has_cv_cx = TRUE;

	if(!has_cv_cx)
	{
	/* Surface has only convex edges OR only concave edges OR neither */
	   if((!has_convex) && (!has_concave))
	   {
	   /* Surface has only free and/or tangent edges. Give minimum extension
	      along all four natural directions and return.
	   */
	      for(i=0; i<4; i++) 
		 ext_dist[i] = (no_ext_reqd[i] ? 0.0 : 
                                (max_ext_reqd[i] ? 5.0 * off_dist : 9.0 * cht));
	      goto ret_end;
	   }
	   else if(((has_convex && off_inward) || (has_concave && !off_inward))
		&& !mult_off_dist)
	   {
	   /* Surface has only convex or only concave edges with offset
	      direction being such that no extension is required if there
              are no multiple offsets. If multiple offset distances are
              specified then we extend the surface by 5 times it's
              offset distance.
	   */
	      for(i=0; i<4; i++)
		  ext_dist[i] = (no_ext_reqd[i] ? 0.0 : 
                                (max_ext_reqd[i] ? 5.0 * off_dist : 9.0 * cht));
	      goto ret_end;

	   }
	}

	/* Give a default extension of 5 times offset distance along all 
	   four parametric directions unless the earlier natural/iso edge 
	   processing indicates that zero or  minimum extension is required
	*/
        if(!mult_off_dist)
	  for(i=0; i<4; i++)
	    ext_dist[i] = (no_ext_reqd[i] ? 0.0 :
					    (min_ext_reqd[i] ? 9.0 * cht :
						               5.0 * off_dist));
        else
        {
        /* Find the maximum of the offset distances of the adjacent surfaces
           and use 5 times that as the default extension distance. The minumum
           value of this maximum distance is taken as the offset distance of
           this surface.
	*/

          IGRdouble  max_adj_dist;

          if((num_adjsfs > 0) && adjsfs_offdists)
          {
            max_adj_dist = -1 * MAXDOUBLE;
            for(i=0; i<num_adjsfs; i++)
               if(adjsfs_offdists[i] > max_adj_dist)
                    max_adj_dist = adjsfs_offdists[i];

           /* Ensure that this maximum is not less than "off_dist".
              Neccessary, for example, where all adjacent surfaces are open */
            if(max_adj_dist < off_dist) max_adj_dist = off_dist;
          }
          else
            max_adj_dist = off_dist; /* case of no adjacent surfaces */

#ifdef DEBUG
         printf(" max adjacent offset distance = %lg\n", max_adj_dist);
#endif
   	  for(i=0; i<4; i++)
	       ext_dist[i] = (no_ext_reqd[i] ? 0.0 :
					       (min_ext_reqd[i] ?
						    9.0 * cht :
						    5.0 * max_adj_dist));

        }

	off_sf.objid = NULL_OBJID; /* off_sf is an unused parameter currently.
				      Suppress compiler warning.
				   */
ret_end:
	if(edges) om$dealloc(ptr = edges);
	if(loop_ids) om$dealloc(ptr = loop_ids);
	if(props) om$dealloc(ptr = props);
	return;
}

/************************************************************************/
IGRboolean EFcreate_partial_sf(msg, sfmdenv, construct_list, surf_in, 
			       u_closed, surf_out, seam_deleted)

  IGRlong    *msg;
  struct GRmd_env         *sfmdenv;
  struct GRvg_construct   *construct_list;
  struct GRid		  surf_in, *surf_out;
  IGRboolean		  u_closed, *seam_deleted;
/************************************************************************/
{
  IGRdouble      range[4];
  IGRdouble      area, water_mark;
  IGRshort       across_seam;
  IGRint         split_ind;
  IGRdouble      mid_uv[2];
  IGRlong        sts, msg_loc;
  IGRboolean	 make_partial;
  OM_S_CHANSELECT  chan_to_loopset;

  *msg = EMS_S_Success;
  sts  = OM_S_SUCCESS;
  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  make_partial = FALSE;
  *seam_deleted = FALSE;

  /* Get the u-v ranges of the surface */
  sts = om$send(msg = message EMSloopset.EMbounded_uv_range
                               (&msg_loc, range, &area, &across_seam,
                                &split_ind, mid_uv, NULL, NULL, NULL),
                senderid = surf_in.objid,
		targetos = surf_in.osnum,
                p_chanselect = &chan_to_loopset);
  EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopsetError, ret_end);

  /* Create a partial surface if the bounded range of the loopset indicated
     that the seam is not taking part in the final topology
  */
  if((u_closed && !((range[0] == 0) && (range[2] == 1.0))) ||
     (!u_closed && !((range[1] == 0) && (range[3] == 1.0))))
  {

#ifdef DEBUG
printf("Creating partial surface for surface id = %d\n", surf_in.objid);
#endif

        /* Make a copy of the surface */
	/* TBD : What if the surfs are in different OS ? */
	  surf_out->osnum = surf_in.osnum;
          sts = om$send (msg = message GRgraphics.GRcopy
                                                (&msg_loc, sfmdenv,
                                                 sfmdenv, &surf_out->objid),
                                  senderid = NULL_OBJID,
				  targetos = surf_in.osnum,
                                  targetid = surf_in.objid);
          EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, ret_end);

        /* Use EMSsubbs.EMreduce_range()-create the partial surface */

          water_mark = area + 0.1;
          sts = om$send(msg = message EMSsubbs.EMreduce_range
                               (&msg_loc, construct_list->env_info,
                                &surf_out->objid, water_mark),
                        senderid = NULL_OBJID,
                        targetid = surf_out->objid);
          EMerr_hndlr(!(1 & sts & msg_loc), *msg,
                                      EMS_E_SurfaceError, ret_end);
	  make_partial = TRUE;
	  if(!(across_seam == NOT_ACROSS_SEAM))
	       *seam_deleted = TRUE;
  }
ret_end:
  return(make_partial);

}

/* ************************************************************************* */
void EFget_component_offsets(msg, numsf, surfs, surfs_os, default_thk, 
			     num_spec_thk, val_spec_thk, spec_thk_sf_sets, 
			     num_nooffset_sfs, nooffset_sfs, off_surfs, env,
			     offset_inward, construct_list, comm_sf_indices,
			     errkey_list, option, status_str)
/* ************************************************************************* */
IGRlong			*msg;
IGRint			numsf, num_spec_thk, num_nooffset_sfs, *comm_sf_indices;
GRobjid 		*surfs, *nooffset_sfs;
GRspacenum		surfs_os;
IGRdouble		default_thk, *val_spec_thk;
struct GRobjid_set      *spec_thk_sf_sets;
struct EMSoff_sf_info	*off_surfs;
struct GRmd_env		*env;
IGRboolean		offset_inward;
struct GRvg_construct	*construct_list;
struct EMSerror_help	*errkey_list;
IGRushort		option;
IGRchar			*status_str;
{
  IGRlong		msg_loc, sts;
  IGRint		i=0, j, k, num_edges, buff_size, *curr_index_ptr;
  IGRboolean		found, seam_deleted, is_natural_normal,
			create_partial=FALSE;
  struct IGRbsp_surface	srfdef;
  struct GRid		sf_to_offset, partial_sfid, *edges=NULL;
  GRobjid		comm_sf_id;
  OM_S_CHANSELECT	to_comm_ed;

  IGRboolean		EFcreate_partial_sf();

  *msg = EMS_S_Success;
  /* Create a buffer to hold 8 edges */
  buff_size = 8;
  edges = (struct GRid *) om$malloc(size = buff_size * sizeof(struct GRid));
  EMerr_hndlr(!(edges), *msg, EMS_E_NoDynamicMemory, ret_end);
  curr_index_ptr = comm_sf_indices;
  EMmake_chanselect(EMSedge_to_common_edge, &to_comm_ed);

  for(i=0; i<numsf; i++)
  {
     create_partial = FALSE;
     off_surfs[i].distance = default_thk;
     off_surfs[i].objid = NULL_OBJID;

     /* Check whether current surface is to have zero offset distance */
     found = FALSE;
     for(j=0; j<num_nooffset_sfs && !found; j++)
     {
       if(surfs[i] == nooffset_sfs[j])
       { 
          off_surfs[i].distance = 0.0;
	  found = TRUE;
       }
     }

     /* Check whether current surface is a special thickness surface */
     for(j=0; j<num_spec_thk && !found; j++)
     {
        for(k=0; k<spec_thk_sf_sets[j].num_ids; k++)
        {
           if(surfs[i] == spec_thk_sf_sets[j].objids[k])
           {
              off_surfs[i].distance = val_spec_thk[j];
              found = TRUE;
           }
        }
     }

     /* Get the bs-definition of surfs[i] */
     sts = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &srfdef),
                    senderid = NULL_OBJID,
                    targetid = surfs[i],
		    targetos = surfs_os);
     EMerr_hndlr (!(msg_loc & sts), *msg, EMS_E_Fail, ret_end);

     off_surfs[i].props = (srfdef.u_phy_closed ? U_CLOSED : 0x0);
     off_surfs[i].props |= (srfdef.v_phy_closed ? V_CLOSED : 0x0);
     off_surfs[i].props |= (srfdef.planar ? PLANAR : 0x0);

     sf_to_offset.objid = surfs[i];
     sf_to_offset.osnum = surfs_os;

     /* Determine if a partial surface needs to be created from surfs[i].
	This will be done if surfs[i]'s surface definition is closed in U
	or V but its topology is not (ie seam not participating in outer loop)
     */
     if(srfdef.u_phy_closed || srfdef.v_phy_closed)
     {
	create_partial = EFcreate_partial_sf(&msg_loc, env, construct_list,
		         sf_to_offset, srfdef.u_phy_closed ? TRUE : FALSE, 
		         &partial_sfid, &seam_deleted);
        EMerr_hndlr (!(msg_loc), *msg, EMS_E_Fail, ret_end);

	if(create_partial) sf_to_offset = partial_sfid;
	if(seam_deleted) off_surfs[i].props |= SEAM_DELETED;	  
     }

     /* Now offset the component surface surfs[i] */
     is_natural_normal = (srfdef.pos_orient ? FALSE: TRUE) ^ offset_inward;
     option &= (~EMS_opt_offsetS_copy_topology);
     option |= EMS_opt_offsetS_by_range;
     sts = om$send(msg = message EMSsurface.EMoffset(&msg_loc, option,
		         &env->md_env.matrix_type, env->md_env.matrix, 
			 construct_list, is_natural_normal,
			 off_surfs[i].distance, 0, NULL, NULL, NULL, NULL,
			 status_str, &off_surfs[i].objid, errkey_list),
 		   senderid = NULL_OBJID,
		   targetid = sf_to_offset.objid,
		   targetos = sf_to_offset.osnum );
     EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

     if(create_partial)
     {
     /* delete the temporary partial surface that was used to create the
        offset surface
     */
        sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
		      senderid = NULL_OBJID,
                      targetid = sf_to_offset.objid,
                      targetos = sf_to_offset.osnum);
        EMerr_hndlr(!(1&sts), *msg, EMS_E_Fail, ret_end);
     }

/* Now to fill in the indices of the adjacent surfaces */
     num_edges = 0;
     sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
			    EMS_OPT_STITCHED, &edges, &buff_size, &num_edges,
			    NULL, NULL, NULL, NULL),
		      senderid = NULL_OBJID,
		      targetid = surfs[i],
		      targetos = surfs_os);
     EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

     off_surfs[i].num_adj_sfs = num_edges;
     off_surfs[i].adj_sfs = curr_index_ptr;
     for(j=0; j<num_edges; j++)
     {
	   comm_sf_id = NULL_OBJID;
	   sts = om$send(msg = message EMSboundary.EMgetsurface_info(&msg_loc,
			       &comm_sf_id, NULL),
			 senderid = edges[j].objid,
			 p_chanselect = &to_comm_ed,
			 targetos = surfs_os);
           EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_Fail, ret_end);

	   for(k=0; k<numsf; k++)
	      if(comm_sf_id == surfs[k])
	      {
		*curr_index_ptr = k;
		curr_index_ptr++;
		break;
	      }
     } /* for(j=0; j<num_edges; j++) */
  } /* for(i=0; i<numsf; i++) */

ret_end:
  if (!(1&*msg))
  {
    IGRint num_created=0;
 
    /*
     * Failed to create all the offset surfaces for all the components of the
     * composite surface. So, delete all the intermediate offset surfaces cr-
     * ated.
     */
    num_created = i;

    for (i=0; i<num_created && off_surfs[i].objid != NULL_OBJID; i++)
    {
       sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc, env),
                      senderid = NULL_OBJID,
                      targetid = off_surfs[i].objid,
                      targetos = surfs_os);
    }
  }

  if(edges) om$dealloc(ptr = edges);

  return;
}

/* ************************************************************************* */
IGRlong EFget_edge_info(msg, mattyp, mat, in_edge, comm_ed, comm_surf, 
			ed_props, free, convex, neutral, special_tangent,
                        iso_direc, ang_meas, cm_ed_props)
/* ************************************************************************* */
IGRlong			*msg;
IGRshort		*mattyp;
IGRmatrix		mat;
struct GRid		in_edge, *comm_ed, *comm_surf;
IGRushort		*ed_props, *cm_ed_props;
IGRboolean		*free, *convex, *neutral, *special_tangent, *iso_direc;
IGRdouble		*ang_meas;
{
  IGRlong		sts, msg_loc;
  IGRushort             loc_ed_props=0, loc_cm_props=0, new_loc_cm_props = 0;
  IGRuchar              edge_type;
  OMuint		count;
  struct GRid		loc_cm_ed;
  OM_S_CHANSELECT	chan_to_cm_ed;
  IGRboolean            cm_ed_dominant = FALSE, loc_iso_direc;
  IGRlong               EFchk_special_tangent();
  IGRdouble             MIN_ANGLE_TOL;
	*msg = EMS_S_Success;
	sts  = OM_S_SUCCESS;
        MIN_ANGLE_TOL = EMS_ZEROANGLE_DEG_MAX;

	sts = om$send(msg = message EMSedge.EMget_props(&msg_loc,
				    &loc_ed_props),
		      senderid = NULL_OBJID,
		      targetos = in_edge.osnum,
		      targetid = in_edge.objid);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg,EMS_E_EdgeError,ret_end);

	if(ed_props) *ed_props = loc_ed_props;

       /* Get the common edge and common-edge-surface if it exists */
	EMmake_chanselect (EMSedge_to_common_edge, &chan_to_cm_ed);
	count = 0;
	sts = om$get_channel_count(objid = in_edge.objid, osnum = in_edge.osnum,
              p_chanselect = &chan_to_cm_ed, count = &count);
	EMerr_hndlr (!(1&sts), *msg, EMS_E_OMerror, ret_end);
	if(count) /* common edge exists */
	{
	   if(free) *free = FALSE;
	   loc_cm_ed.osnum = in_edge.osnum;
	   sts = om$send(msg = message EMSboundary.EMget_objid(&msg_loc,
                                       &loc_cm_ed.objid),
		         senderid = in_edge.objid,
		         targetos = in_edge.osnum,
                         p_chanselect = &chan_to_cm_ed);
	   EMerr_hndlr(EMSerror(sts & msg_loc), *msg, EMS_E_EdgeError, ret_end);

           if(loc_ed_props & EMED_SUBORDINATE) 
           {
               cm_ed_dominant = TRUE;
           }
           sts = om$send(msg = message EMSedge.EMget_props(&msg_loc,
                                                         &loc_cm_props),
                      senderid = NULL_OBJID,
                      targetos = loc_cm_ed.osnum,
                      targetid = loc_cm_ed.objid);
           EMerr_hndlr(! (1 & sts & msg_loc), *msg,EMS_E_EdgeError,ret_end);


           if(cm_ed_props) *cm_ed_props = loc_cm_props;

	   if(comm_ed)
	   {
	      comm_ed->osnum = loc_cm_ed.osnum;
	      comm_ed->objid = loc_cm_ed.objid;
	   }
	   if(comm_surf)
	   {
	     comm_surf->osnum = in_edge.osnum;
	     sts = om$send(msg = message EMSboundary.EMgetsurface_info(
	  		         &msg_loc, &comm_surf->objid, NULL),
			   senderid = NULL_OBJID,
			   targetid = loc_cm_ed.objid,
			   targetos = loc_cm_ed.osnum);
	     EMerr_hndlr(EMSerror(sts & msg_loc), *msg, EMS_E_EdgeError,
			 ret_end);
            sts = om$send(msg = message EMSedge.EMget_props_type(&msg_loc,
                                                         &new_loc_cm_props,
                                                         &edge_type),
                      senderid = NULL_OBJID,
                      targetos = comm_ed->osnum,
                      targetid = comm_ed->objid);
           EMerr_hndlr(!(1 & sts & msg_loc), *msg,EMS_E_EdgeError,ret_end);
           if(edge_type ==  EMlinesegment) MIN_ANGLE_TOL =  EMS_ZEROANGLE_DEG;
	   }

	   if(loc_ed_props & EMED_DEGENERATE) goto ret_end;

	   /* Check if the edge is tangent (neutral), convex OR concave */

	   if(neutral || convex)
	   {
	     IGRboolean is_neutral=FALSE, is_convex=FALSE;
	     IGRdouble loc_ang_meas;

             if((loc_ed_props & EMED_TANGENT) || (loc_cm_props & EMED_TANGENT))
	     {
	       is_neutral = TRUE;
	       loc_ang_meas = 2.0;
	     }
	     else
	     {
              /* Send this message to the 'Dominant' edge. */
	      sts = om$send(msg = message EMSedge.EMchkconvex(&msg_loc,
					          NULL, mattyp, mat,
					          EMS_ZEROANGLE_DEG,
						  &is_convex, &is_neutral,
						  &loc_ang_meas),
			    senderid = NULL_OBJID,
			    targetos = in_edge.osnum,
                            targetid = (cm_ed_dominant ?
                                            loc_cm_ed.objid :
                                            in_edge.objid));
	      EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_EdgeError, ret_end);
/*
 It is sometimes possible for having both convexity and concavity bits on so it is desirable to check accoring to the minimum tolerance value used in the function EFcheck_is_neutral.                                  
*/
	      if(is_neutral || (fabs(2.0 - loc_ang_meas) < MIN_ANGLE_TOL))
		 is_neutral = TRUE;
	     }

             if(is_neutral && special_tangent)
             {
               *special_tangent = FALSE;
               sts = EFchk_special_tangent(&msg_loc, mattyp, mat, in_edge, 
                                           (comm_surf ? comm_surf : NULL), 
                                           loc_ed_props, &is_neutral, 
                                           &loc_ang_meas, &loc_iso_direc,
                                           special_tangent);
	       EMerr_hndlr(!(1 & sts & msg_loc), *msg, 
                                                EMS_E_EdgeError, ret_end);
               if(iso_direc) *iso_direc = loc_iso_direc;
             }
#ifdef DEBUG
printf("angle_measure = %lg\n", loc_ang_meas);
if(special_tangent && *special_tangent) 
       printf("Special Tangent Edge Id = %d\n", in_edge.objid);
#endif
	     if(neutral) *neutral = is_neutral;
	     if(convex) *convex = is_convex;
	     if(ang_meas) *ang_meas = loc_ang_meas;
	   } /* if(neutral || convex) */

	} /* if(count) i.e common edge exists */
	else                   /* Connectable Edge */
	{
	   if(free) *free = TRUE;
	   if(neutral) *neutral = FALSE;
	   if(convex) *convex = FALSE;
           if(special_tangent) *special_tangent = FALSE;
	}
ret_end:
	return(sts);
}

/*****************************************************************
NAME:
   EFget_offsetdistance_for_surface
   
ABSTRACT:
   Function for Determining the offset distance for a surface
   given the 'specific surface offset information'.


ARGUMENTS:

     Input:

       current_surf     -  the id of the surface for which the offset distance
                           is to be determined

       distance         -  common offset distance

       num_spec_off     - number of special offset distance values 

       val_spec_off     - array of special offset distance values
       
       spec_off_sf_sets - objids of the special offset distance surfaces

       num_nooffsetsfs  - number of open surfaces

       nooffsetsfs      - array of open surface ids.

    Output:

       offset_distance  - the actual value of the offset distance for 
                          the current surface.

RETURN VALUES:     

ALGORITHM:

NOTES:
   See if you can merge this function with any of the existing ones
   in 'src_funk/misc/EFcsoffsupp.I'.

KEYWORDS:

HISTORY:
   Sudhakar : 03/18/93  : genesis.

*/

void EFget_offsetdistance_for_surface(current_surf, distance,
                                       num_spec_off, val_spec_off,
                                       spec_off_sf_sets,
                                       num_nooffsetsfs, nooffsetsfs,
                                       offset_distance)
  OM_S_OBJID              current_surf;
  IGRdouble               distance;
  IGRint                  num_spec_off;
  IGRdouble               *val_spec_off;
  struct GRobjid_set      *spec_off_sf_sets;
  IGRint                  num_nooffsetsfs;
  GRobjid                 *nooffsetsfs;
  IGRdouble               *offset_distance;
/************************************************************************/
{
  IGRint i, j;

#ifdef DEBUG
printf("Entered EFgetoffdist\n");
#endif

  *offset_distance = distance;

  /* Check whether current surface is an open surface */

  for(i=0; i<num_nooffsetsfs; i++)
  {
    if(current_surf == nooffsetsfs[i])
    {
      *offset_distance = 0.0;
#ifdef DEBUG
  printf("Surface is Open\n");
#endif
      goto ret_end;
    }
  }

  /* Check whether current surface is a special thickness surface */

  for(i=0; i<num_spec_off; i++)
  {
    for(j=0; j<spec_off_sf_sets[i].num_ids; j++)
    {
       if(current_surf == spec_off_sf_sets[i].objids[j])
       {
         *offset_distance = val_spec_off[i];
#ifdef DEBUG
  printf("Special Thickness found\n");
#endif
         goto ret_end;
       }
    }
  }

ret_end:

#ifdef DEBUG
printf("Current Surf-id = %d\n", current_surf);
printf("  Offset distance = %lf\n", *offset_distance);
#endif

  return;

}

/***********************************************************************

NAME:
   EFcreate_outward_offset_by_half_thickness

ABSTRACT:
   Function for Determining the outward offset surface with the
   common and specific offset distances halved. This is used in case
   of 'symmetric' thinwall.


ARGUMENTS:

     Input:

       msg, const_list      - the usual stuff

       common_thickness     - common offset distance

       num_mult_thicknesses - number of special thicknesses

       vals_mult_thickness  - array of values of special thicknesses

       spec_tk_sf_sets      - ids of the special thickness surfaces
                              arranged in a structure.
    
     Input/Output: 

       compsurf             - id of the input composite surface.
                              Modified to the offset surface id at
                              the end of successful creation.
     Output:

       errkey_list          - List of error codes and associated object
                              ids. Unused.
       
RETURN VALUES:

ALGORITHM:

NOTES:

KEYWORDS:

HISTORY:
   Sudhakar : 05/18/93  : genesis.

***********************************************************************/

  void EFcreate_outward_offset_by_half_thickness(msg, const_list,
                                       common_thickness, num_mult_thicknesses,
                                       vals_mult_thickness, spec_tk_sf_sets,
                                       compsurf, errkey_list)
  IGRlong    *msg;
  struct GRvg_construct *const_list;
  IGRdouble   common_thickness;
  IGRint      num_mult_thicknesses;
  IGRdouble   *vals_mult_thickness;
  struct  GRobjid_set  *spec_tk_sf_sets;
  GRobjid     *compsurf;
  struct   EMSerror_help  *errkey_list;
{
  IGRint j;
  IGRlong  msg_loc, stat_OM;
  IGRushort   offopts = 0;
  IGRboolean  offin_flag;
  IGRdouble  half_thick, *vals_half_tk = NULL;
  GRobjid  off_surf;

  *msg = OM_S_SUCCESS;
  stat_OM = EMS_S_Success;
  half_thick = common_thickness/2.0;

  if(num_mult_thicknesses)
  {
     vals_half_tk = (IGRdouble *) om$malloc (size = num_mult_thicknesses *
                                       sizeof(IGRdouble));
     EMerr_hndlr (!vals_half_tk, *msg, EMS_E_NoStackMemory, ret_end);

     for(j=0; j<num_mult_thicknesses; j++)
          vals_half_tk[j] = vals_mult_thickness[j]/2.0;
  }

  offin_flag = FALSE;
  stat_OM = om$send (msg = message EMSsurface.EMoffset (&msg_loc, offopts,
               &const_list->env_info->md_env.matrix_type,
               const_list->env_info->md_env.matrix,
               const_list,
               offin_flag, half_thick,
               num_mult_thicknesses, vals_half_tk, spec_tk_sf_sets,
               0, NULL, NULL, &off_surf, errkey_list),
               senderid = NULL_OBJID,
               targetid = *compsurf);

  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

#ifdef DEBUG
printf("Successful outward offset of original compsurf = %d to\n", *compsurf);
printf("                                 new  compsurf = %d\n", off_surf);
#endif
  *compsurf = off_surf;

ret_end:

  if(vals_half_tk)  om$dealloc(ptr = vals_half_tk);

  return;
}

/****************************************************************************

NAME : EFmkint_from_edge();

ABSTRACT:
Given a surface and an edge on it, this function creates an intersection 
object out of it and inserts it into the incoming intersection list.

ARGUMENTS:

NOTES:
The option to reverse the direction of the generated intobj is available
only if the UV intersection is to be output as geometry (and not EMSedge).

HISTORY:
	 ashok	3-Oct-93	Genesis
         sanjay 26-Dec-94       is_valid field of par_tol was not initialized
                                because of which EMgetpygeom method crashes.
                                Now this field is initialized to FALSE.

****************************************************************************/
struct EMSintobj *EFmkint_from_edge(msg, surf_grid, edge, uv_obj, copy, rev,
				    mdenv_info, p_inters)


IGRlong			*msg;
struct GRid		surf_grid, edge;
IGRboolean		uv_obj, copy, rev;
struct GRmdenv_info	*mdenv_info;
struct EMSinters	**p_inters;

{
IGRlong			stat_OM, msg_loc;
BSrc			rc;
IGRboolean		stat_func;
GRobjid			*edg_ptr=NULL;
struct GRid		loc_edge;
struct EMSpartolbasis	par_tol;
struct EMSdataselect	data, uv_data, xyz_data;
struct IGRbsp_curve	*xyz_cv=NULL;
struct EMSintobj	*p_intobj=NULL;

struct EMSintobj	*EMmakeintlist(); 

	*msg = OM_S_SUCCESS;
	stat_OM = EMS_S_Success;
	par_tol.mattyp = &mdenv_info->matrix_type;
	par_tol.mat = mdenv_info->matrix;
	par_tol.in_world = TRUE;
        par_tol.is_valid = FALSE;
	loc_edge.osnum = edge.osnum;

	if(uv_obj)
	{
	  if(copy)
	  {
            edg_ptr = &loc_edge.objid;
            stat_OM = om$send(msg = message EMSedge.EMextractyourself(
                                        &msg_loc, NULL, NULL, 1,
                                        &edg_ptr,
                                        NULL, NULL, FALSE,
                                        (IGRushort)EMImpBnd_NoInputDelete,
                                        NULL, &par_tol),
			      senderid = NULL_OBJID,
                              targetid = edge.objid,
                              targetos = edge.osnum);
            EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	  }
	  else
	    loc_edge.objid = edge.objid;

	  data.datatype = EMSdata_object;
	  data.data.object = &loc_edge;
	  EMmkintdata(&msg_loc, &data, NULL, NULL, FALSE, NULL,
		    NULL, TRUE, NULL, NULL, &uv_data);
          EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
	}
	else  /* UV boundary is required as a EMSdata_poly2d */
	{
	    struct IGRpolyline	poly;

	    poly.points = NULL;
            stat_OM = om$send(msg = message EMSedge.EMgetpygeom(&msg_loc, 0,
					OM_K_MAXINT, rev, NULL, &poly,
					&par_tol, 0),
			      senderid = NULL_OBJID,
                              targetid = edge.objid,
                              targetos = edge.osnum);
            EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

	    data.datatype = EMSdata_poly2d;
	    data.data.poly = &poly;
	    EMmkintdata(&msg_loc, &data, NULL, NULL, FALSE, NULL,
		    NULL, FALSE, NULL, NULL, &uv_data);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	    if(poly.points) om$dealloc(ptr = poly.points);
	}

  /* Extract the XYZ bspline geometry of the edge */
	xyz_cv = (struct IGRbsp_curve *) om$malloc(size = 
 			                    sizeof(struct  IGRbsp_curve));
    	EMerr_hndlr(!xyz_cv, *msg, EMS_E_DynamicMemoryAllocated, ret_end);
    	xyz_cv->poles = xyz_cv->knots = xyz_cv->weights = NULL;

	stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc, 
	 		        mdenv_info, &surf_grid, NULL, 0, OM_K_MAXINT, 
				FALSE, NULL, xyz_cv),
		          senderid = NULL_OBJID,
		          targetid = edge.objid,
		      	  targetos = edge.osnum);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

	if(!uv_obj && rev)             /* reverse curve if necessary */
	{
	  stat_func = BSrev_cv (&rc, xyz_cv);
	  EMerr_hndlr(!stat_func || rc!=BSSUCC, *msg, EMS_E_BSerror, ret_end);
	}
	data.datatype = EMSdata_curve3d;
	data.data.curve = xyz_cv;
	EMmkintdata(&msg_loc, &data, NULL, NULL, TRUE, NULL,
		    NULL, FALSE, NULL, NULL, &xyz_data);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

	p_intobj = EMmakeintlist(&msg_loc, p_inters, NULL, &surf_grid, NULL,
				 NULL, NULL, NULL, NULL, &xyz_data, &uv_data,
				 NULL, FALSE, FALSE, NULL, NULL, 0, 0, NULL,
				 NULL, TRUE, FALSE);
	EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,  ret_end);

ret_end:
	if(xyz_cv)
	{
	   if(xyz_cv->poles) om$dealloc(ptr = xyz_cv->poles);
	   if(xyz_cv->knots) om$dealloc(ptr = xyz_cv->knots);
	   if(xyz_cv->rational) om$dealloc(ptr = xyz_cv->weights);
	   om$dealloc(ptr = xyz_cv);
	}
	return(p_intobj);
}

/****************************************************************************
NAME:
   EFmkint_from_isocurve

DESCRIPTION: 
    This function extracts the iso curve on a surface (surf_grid) based
    on the u/v parameter (uv) and the v/u direction (iso_uorv) and 
    reverses it based on the flag (rev). It outputs the iso curve in
    the form of an intersection object.
 
    Note:
     Input:
        rev          =FALSE   intobj should flow from u/v = 0.0 to 1.0
                     =TRUE    intobj should flow from u/v = 1.0 to 0.0
    The inherent assumption here is that the curve generated by the
    'BSconstprcv' function is always flowing from the 0.0 to 1.0.
    Hence this needs to be reversed if 'rev' flag is set.

****************************************************************************/
struct EMSintobj *EFmkint_from_isocurve(msg, surf_grid, uv, iso_uorv,
                                    rev,is_full,mdenv_info, p_inters)
IGRlong                 *msg;
struct GRid             surf_grid;
IGRdouble               uv[6];
IGRshort                iso_uorv;
IGRboolean              rev;
IGRboolean              is_full;
struct GRmdenv_info     *mdenv_info;
struct EMSinters        **p_inters;
{
IGRlong                 stat_OM, msg_loc, num_bytes;
BSrc                    rc;
IGRboolean              stat_func, tst_plan;
struct EMSdataselect    data, uv_data, xyz_data;
struct IGRbsp_curve     *xyz_cv=NULL;
struct EMSintobj        *p_intobj=NULL;
struct IGRpolyline      poly;
IGRdouble               points[4];
IGRshort                option;
struct IGRbsp_surface   *surf_geom = NULL;

struct EMSintobj        *EMmakeintlist();


    *msg = OM_S_SUCCESS;
    stat_OM = EMS_S_Success;

 /* Extract the curve along the iso-direction on the surface */

    poly.num_points = 2;
   if(is_full) 
    {
      if(iso_uorv == CONST_U)
      {
        points[0] = points[2] = uv[0];
        points[1] = (rev ? 1.0 : 0.0);
        points[3] = (rev ? 0.0 : 1.0);
      }
      else
      {
        points[1] = points[3] = uv[1];
        points[0] = (rev ? 1.0 : 0.0);
        points[2] = (rev ? 0.0 : 1.0);
      }
    }
    else
     {
	if(iso_uorv == CONST_U)
      	{
           points[0] = points[2] = uv[0];
           points[1] = uv[3];
           points[3] = uv[5];
        }
        else
       {
           points[1] = points[3] = uv[1];
           points[0] = uv[2];
           points[2] = uv[4];
       }
    }
    poly.points = points;

#ifdef DEBUG
  printf("Intobj  start: %lg, %lg,  end: %lg, %lg \n", points[0], points[1],
                               points[2], points[3]);    
#endif
    data.datatype = EMSdata_poly2d;
    data.data.poly = &poly;
    EMmkintdata(&msg_loc, &data, NULL, NULL, FALSE, NULL,
                NULL, FALSE, NULL, NULL, &uv_data);
    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);


    /* Get the b-spline geometry of the surface from which the curve is to be
        extracted */
    stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                                 &(mdenv_info->matrix_type),
                                                 mdenv_info->matrix,
                                                 &num_bytes),
                    targetid = surf_grid.objid,
                    targetos = surf_grid.osnum,
                    senderid = NULL_OBJID);
    EMerr_hndlr(EMSerror(msg_loc & stat_OM), *msg, EMS_E_SurfaceError, ret_end);

    surf_geom = (struct IGRbsp_surface *) om$malloc(size = num_bytes);
    EMerr_hndlr(!surf_geom, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

    stat_OM = om$send (msg = message GRvg.GRgetgeom(&msg_loc,
                                                  &(mdenv_info->matrix_type),
                                                  mdenv_info->matrix,
                                                  (IGRchar *) surf_geom),
                       targetid = surf_grid.objid,
                       targetos = surf_grid.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr(EMSerror(msg_loc & stat_OM), *msg, EMS_E_SurfaceError, ret_end);

    /* Extract the XYZ bspline geometry of the isocurve */
    BSalloccv((iso_uorv == CONST_U) ? surf_geom->v_order : surf_geom->u_order,
              (iso_uorv == CONST_U) ? surf_geom->v_num_poles : surf_geom->u_num_poles,
              surf_geom->rational, (IGRshort)0, &xyz_cv, &rc);
    EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, ret_end);

    option = (iso_uorv == CONST_U ? 1 : 2);
    tst_plan = FALSE;
    stat_func = BSconstprcv(&rc, surf_geom, &option, 
                            (iso_uorv == CONST_U ? &uv[0] : &uv[1]), 
                            &tst_plan, xyz_cv); 
    EMerr_hndlr(rc!=BSSUCC || !stat_func, *msg, EMS_E_BSerror, ret_end);

    if(rev) 
    {
        stat_func = BSrev_cv (&rc, xyz_cv);
        EMerr_hndlr(!stat_func || rc!=BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }
    data.datatype = EMSdata_curve3d;
    data.data.curve = xyz_cv;
    EMmkintdata(&msg_loc, &data, NULL, NULL, TRUE, NULL,
                NULL, FALSE, NULL, NULL, &xyz_data);
    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

    p_intobj = EMmakeintlist(&msg_loc, p_inters, NULL, &surf_grid, NULL,
                             NULL, NULL, NULL, NULL, &xyz_data, &uv_data,
                             NULL, FALSE, FALSE, NULL, NULL, 0, 0, NULL,
                             NULL, TRUE, FALSE);
    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,  ret_end);

ret_end:
    if(surf_geom) om$dealloc(ptr = surf_geom);
    if(xyz_cv) BSfreecv(&rc, xyz_cv);

    return(p_intobj);
}


/* ____________________________________________________________________________

Name : EFconvert_anglemeasure_to_angle()

Abstract : Given the angle measure i.e. the value which will be returned from
           EMSedge.EMchk_convex method, this returns the angle in degrees.

Arguments : 
           IGRdouble    ang_meas       I       angle measure
           IGRdouble    *angle         O       angle in degrees

Return Values : 
           EMS_S_Success      if success
           EMS_E_InvalidArg   if angle measure passed is incorrect / fails.

History : 
           Sanjay  27th Dec' 93.   Creation

____________________________________________________________________________ */


IGRlong   EFconvert_anglemeasure_to_angle( ang_meas, angle )
IGRdouble ang_meas, *angle;
{
   IGRlong   sts;

   sts = EMS_S_Success;
   if( !angle ) { sts = EMS_E_InvalidArg; goto wrapup; }
 
   if( ang_meas >=0 && ang_meas <=1.0 )
   {
       *angle = 90.0 - acos( ang_meas ) * 180.0 / M_PI;
   }
   else if( ang_meas >= 1.0 && ang_meas <= 2.0 )
   {
       *angle = 90.0 + acos( 2.0 - ang_meas ) * 180.0 / M_PI;
   }
   else if( ang_meas >= 2.0 && ang_meas <= 3.0 )
   {
       *angle = 270 - acos( ang_meas - 2.0 ) * 180 / M_PI;
   }
   else if( ang_meas >= 3.0 && ang_meas <= 4.0 )
   {
       *angle = 270.0 + acos( 4.0 - ang_meas ) * 180 / M_PI;
   }
   else
   {
       sts = EMS_E_InvalidArg; *angle = 0.0;
   }

wrapup : 
   return sts;
}


/* ____________________________________________________________________________

Name :     EFwill_edges_stitch_after_projection()

Abstract : Given the two surfaces and edges of the surfaces, this function 
           determines whether the given two edges can be stitched after 
           offsetting the respective surfaces.

Arguments : 
           IGRlong               *msg        O   Success / failure
           struct IGRbsp_curve   *edge1      I   xyz geometry of the edge #1
           struct IGRbsp_surface *surf1      I   geometry of the surface #1
           IGRboolean            nat_normal1 I   whether to offset the surface1
                                                 along its natural normal / 
                                                 reverse to it.
           struct IGRbsp_curve   *edge2      I   xyz geometry of the edge #2
           struct IGRbsp_surface *surf2      I   geometry of the surface #2
           IGRboolean            nat_normal2 I   whether to offset the surface2
                                                 along its natural normal / 
                                                 reverse to it.
           IGRdouble             offdist     I   offset distance

Return values : 
           TRUE  if the edges are stitchable after offset.
           FALSE if the edges are non-stitchable after offset.

History : 

           Sanjay    27th Dec' 93.      Creation

____________________________________________________________________________ */
            

IGRboolean  EFwill_edges_stitch_after_projection1( msg, edge1, surf1, 
	    nat_normal1, edge2, surf2, nat_normal2, offdist )
IGRlong	              *msg;
struct IGRbsp_curve   *edge1, *edge2; 
struct IGRbsp_surface *surf1, *surf2;
IGRboolean            nat_normal1, nat_normal2;
IGRdouble             offdist;       
{
   BSrc                  rc;
   IGRint                indx;
   IGRlong               sts;
   IGRpoint              endpt1[2], endpt2[2];
   IGRdouble             par, chttol, stitol, dist;
   IGRboolean            will_stitch ;
   struct IGRbsp_curve   *offcv1, *offcv2; 

   /*
    * Initilaization of local variables
    */

   sts = OM_S_SUCCESS;
   *msg = EMS_S_Success;
   will_stitch = FALSE;
   offcv1 = offcv2 = NULL;

   /*
    * Find the offset edges for the two surfaces
    */

   BSoffcvfrsf( edge1, surf1, nat_normal1, FALSE, offdist, NULL, TRUE, 
                  NULL, NULL, NULL, &offcv1, &rc );  
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup ); 

   BSoffcvfrsf( edge2, surf2, nat_normal2, FALSE, offdist, NULL, TRUE, 
                  NULL, NULL, NULL, &offcv2, &rc );  
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup ); 

   /*
    * Get the end points of the two curves
    */

   par = offcv1->knots[ offcv1->order - 1 ]; 
   BScveval( offcv1, par, 0, endpt1[0], &rc);
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );

   par = offcv1->knots[ offcv1->num_poles ]; 
   BScveval( offcv1, par, 0, endpt1[1], &rc);
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );
  
   par = offcv2->knots[ offcv2->order - 1 ]; 
   BScveval( offcv2, par, 0, endpt2[0], &rc);
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );
   
   par = offcv2->knots[ offcv2->num_poles ]; 
   BScveval( offcv2, par, 0, endpt2[1], &rc);
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );

   /*
    * Now check the distance between the end points of the curves againast
    * the worst stitch tolerance. If this check passes through,  then  set  
    * will_stitch flag TRUE otherwise FALSE.
    */

   BSEXTRACTPAR( &rc, BSTOLCHRDHT, chttol);  
   stitol = 2.0 * chttol;

   dist = BSdistptpt( &rc, endpt1[0], endpt2[0] );
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );
   if( dist < stitol ) indx = 1;
   else 
   {
      dist = BSdistptpt( &rc, endpt1[0], endpt2[1] );
      EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );
      if( dist < stitol ) indx = 0; 
      else goto wrapup;
   }
    
   dist = BSdistptpt( &rc, endpt1[1], endpt2[indx] ); 
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );
   if( dist < stitol ) will_stitch = TRUE;

wrapup : 
   if( offcv1 ) sts = BSfreecv( &rc, offcv1 );
   if( offcv2 ) sts = BSfreecv( &rc, offcv2 );
   return will_stitch;
}

IGRboolean  EFwill_edges_stitch_after_projection( msg, edge, surf1, 
	    surf2, md_env, direction, offdist )
IGRlong	             *msg;
struct GRid          *edge, *surf1, *surf2;
struct GRmdenv_info  *md_env; 
IGRint               direction;
IGRdouble            offdist;
{
   BSrc                  rc;
   IGRint                indx, ii, fact;
   IGRlong               sts, size;
   IGRpoint              pt[2], dummypt, normal1, normal2,
                         offpt1, offpt2; 
   IGRdouble             chttol, sttol, uvpt1[2], uvpt2[2], dist; 
   IGRboolean            will_stitch;
   struct IGRbsp_surface *sfgeom1, *sfgeom2;
   
   sts = OM_S_SUCCESS;
   *msg = EMS_S_Success;
   indx = 0;
   will_stitch = FALSE;
   sfgeom1 = sfgeom2 = NULL;

   BSEXTRACTPAR( &rc, BSTOLCHRDHT, chttol);  
   sttol = 2.0 * chttol;

   sts = om$send( msg = message EMSedge.EMxyz_endpt(  msg, 
                                surf1, md_env, NULL, NULL, 
                                pt[0], pt[1], NULL),
                  senderid = NULL_OBJID,
                  targetid = edge->objid,
                  targetos = edge->osnum );
   EMerr_hndlr( !(1&sts&*msg), *msg, EMS_E_EdgeError, wrapup);

   sts = om$send( msg = message GRvg.GRgetsize( msg, 
                                &md_env->matrix_type,
                                md_env->matrix,
                                &size ),
                  senderid = NULL_OBJID,
                  targetid = surf1->objid,
                  targetos = surf1->osnum );
   EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_SurfaceError, wrapup);

   sfgeom1 = (struct IGRbsp_surface *) om$malloc( size = size );
   EMerr_hndlr(!sfgeom1, *msg, EMS_E_DynamicMemoryAllocated, wrapup);
			         
   sts = om$send( msg = message GRvg.GRgetgeom( msg, 
                                &md_env->matrix_type,
                                md_env->matrix,
                                (IGRchar *) sfgeom1 ), 
                  senderid = NULL_OBJID,
                  targetid = surf1->objid,
                  targetos = surf1->osnum );
   EMerr_hndlr( !(1&sts&*msg), *msg, EMS_E_SurfaceError, wrapup);
                  
   sts = om$send( msg = message GRvg.GRgetsize( msg, 
                                &md_env->matrix_type,
                                md_env->matrix,
                                &size ),
                  senderid = NULL_OBJID,
                  targetid = surf2->objid,
                  targetos = surf2->osnum );
   EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_SurfaceError, wrapup);

   sfgeom2 = (struct IGRbsp_surface *) om$malloc( size = size );
   EMerr_hndlr(!sfgeom2, *msg, EMS_E_DynamicMemoryAllocated, wrapup);
			         
   sts = om$send( msg = message GRvg.GRgetgeom( msg, 
                                &md_env->matrix_type,
                                md_env->matrix,
                               (IGRchar *) sfgeom2 ), 
                  senderid = NULL_OBJID,
                  targetid = surf2->objid,
                  targetos = surf2->osnum );
   EMerr_hndlr( !(1&sts&*msg), *msg, EMS_E_SurfaceError, wrapup);

   for(indx = 0; indx < 2; indx++)
   {
       sts = om$send( msg = message EMSsubbs.EMpratmpt( msg,
                                    &md_env->matrix_type, md_env->matrix,
                                    1, pt[indx], uvpt1, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = surf1->objid,
                      targetos = surf1->osnum );
       EMerr_hndlr( !(1&sts&*msg), *msg, EMS_E_SurfaceError, wrapup);
               
       sts = om$send( msg = message EMSsubbs.EMpratmpt( msg,
                                    &md_env->matrix_type, md_env->matrix,
                                    1, pt[indx], uvpt2, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = surf2->objid,
                      targetos = surf2->osnum );
       EMerr_hndlr( !(1&sts&*msg), *msg, EMS_E_SurfaceError, wrapup);

       BSsfarrevn( &rc, sfgeom1, 1, &uvpt1[0], 1, &uvpt1[1], dummypt, normal1);
       EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

       BSsfarrevn( &rc, sfgeom2, 1, &uvpt2[0], 1, &uvpt2[1], dummypt, normal2);
       EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup);
 
       BSnorvec( &rc, normal1); 
       EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup);
    
       BSnorvec( &rc, normal2); 
       EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

       if( !sfgeom1->pos_orient )
       {   
          for(ii=0; ii<3; ii++) 
              normal1[ii] = -normal1[ii];
       } 
       if( !sfgeom2->pos_orient )
       {   
          for(ii=0; ii<3; ii++) 
              normal2[ii] = -normal2[ii];
       }
       if( direction ) fact = 1; else fact = -1; 
       
       for(ii=0; ii<3; ii++) 
           offpt1[ii] = pt[indx][ii] + fact * normal1[ii] * offdist;
       for(ii=0; ii<3; ii++) 
           offpt2[ii] = pt[indx][ii] + fact * normal2[ii] * offdist;

       dist = BSdistptpt( &rc, offpt1, offpt2);
       if( dist < sttol ) will_stitch = TRUE; 
       else { will_stitch = FALSE; break; }
   }

wrapup : 
   if( sfgeom1 ) free( sfgeom1 );
   if( sfgeom2 ) free( sfgeom2 );
   return will_stitch;
}


/* ----------------------------------------------------------------------------
   
Name : EFchk_special_tangent() 
Abstract : 
       Checks whether an edge is a special tangent edge or not.
       Special tangent should have the following properties.
       It should be :
        1. tangent and ISO and not belong to a EMSgenbs        AND
        2. have surfaces with similar types on either side     AND
        3. [globally neutral OR have curvature continuity]     AND
        4. have the number of edges at atleast one of the
           vertices as > 3                                     AND
        5. atleast one of the vertex edges is either convex
           or concave. 
	
Arguments : 
       IGRlong         *msg             I   Return message 	
					    EMS_S_Success if success
       IGRshort        *mattyp;         I
       IGRmatrix       mat;             I
       struct GRid     edge             I   Edge id
       struct GRid     *comm_surf_id    I   surface id of the common edge 
                                            (optional) or NULL
       IGRboolean      *neutral         I   flag indicating whether the
                                            edge is "neutral"
       IGRboolean      *ang_meas        I   value of angle measure at the
                                            edge between the two surfaces.
       IGRboolean      *iso_direc       O   Iso direction of the edge/NULL
       IGRboolean      *is_sp_tan       O   is the edge is special tangent ?

History :

       G. Sanjay       23rd Dec' 94.    Creation

---------------------------------------------------------------------------- */
IGRlong EFchk_special_tangent( msg, mattyp, mat, edge,
                               comm_surf_id, edge_props,
                               neutral, ang_meas,
                               iso_direc, is_sp_tan )
IGRlong             *msg;
IGRshort            *mattyp;
IGRmatrix           mat;
struct GRid         edge, *comm_surf_id;
IGRushort           edge_props;
IGRboolean          *neutral;
IGRdouble           *ang_meas;
IGRboolean          *iso_direc, *is_sp_tan;
{
   BSrc                  rc;
   IGRchar               classname[ OM_K_MAXCLASS_LEN ];
   IGRlong               ret_sts, ret_msg, size, ii, jj;
   IGRushort             options;
   OMuint                count;
   OM_S_CHANSELECT       chan_to_cm_ed;
   IGRdouble             tol, uvpt[10], mean_crv, cm_mean_crv, iso_points[4],
                         loc_ang_meas;  
   IGRpoint              surf_uvpt, cm_surf_uvpt, xyz_pts[5];
   IGRboolean            loc_convex, loc_neutral, is_iso;
   GRclassid             surf_classid, comm_surf_classid;
   struct GRid           loc_surf_id, loc_comm_surf_id, loc_comm_edge_id;
   struct IGRpolyline    pygeom;
   struct EMSpartolbasis tolbasis;
   struct IGRbsp_surface *surf_geom = NULL, *comm_surf_geom = NULL;
   GRobjid               *edges[2];
 
   *msg = EMS_S_Success;
   ret_sts = OM_S_SUCCESS; 
   tolbasis.mat = mat; 
   tolbasis.mattyp = mattyp; 
   tolbasis.is_valid = FALSE;
   tolbasis.in_world = TRUE;
   pygeom.num_points = 0;
   pygeom.points = NULL;
   edges[0] = edges[1] = NULL;

   if( is_sp_tan ) *is_sp_tan = FALSE;
   else goto wrapup;

   if(comm_surf_id) 
   {
     loc_comm_surf_id.objid =  comm_surf_id->objid;
     loc_comm_surf_id.osnum =  comm_surf_id->osnum;
   }
   else
   {
       /* Get the common edge and common-edge-surface if it exists */
        EMmake_chanselect (EMSedge_to_common_edge, &chan_to_cm_ed);
        count = 0;
        ret_sts = om$get_channel_count(objid = edge.objid, osnum = edge.osnum,
              p_chanselect = &chan_to_cm_ed, count = &count);
        EMerr_hndlr (!(1&ret_sts), *msg, EMS_E_OMerror, wrapup);
        if(count) /* common edge exists */
        {
           loc_comm_edge_id.osnum = edge.osnum;
           ret_sts = om$send(msg = message EMSboundary.EMget_objid(&ret_msg,
                                       &loc_comm_edge_id.objid),
                         senderid = edge.objid,
                         targetos = edge.osnum,
                         p_chanselect = &chan_to_cm_ed);
           EMerr_hndlr(EMSerror(ret_sts & ret_msg), *msg,
                                                   EMS_E_EdgeError, wrapup);
           loc_comm_surf_id.osnum = edge.osnum;
           ret_sts = om$send(msg = message EMSboundary.EMgetsurface_info(
                                 &ret_msg, &loc_comm_surf_id.objid, NULL),
                           senderid = NULL_OBJID,
                           targetid = loc_comm_edge_id.objid,
                           targetos = loc_comm_edge_id.osnum);
           EMerr_hndlr(EMSerror(ret_sts & ret_msg), *msg, EMS_E_EdgeError,
                         wrapup);
        }
        else
        {
           *msg = EMS_E_Fail;
           goto wrapup;
        }
    } 

   /*
    * Get the surface id of the edge
    */

   ret_sts = om$send ( msg = message EMSboundary.EMgetsurface_info (
                                 &ret_msg,
                                 &loc_surf_id.objid,
                                 NULL ),
                       senderid = NULL_OBJID,
                       targetid = edge.objid,
                       targetos = edge.osnum );
   EMerr_hndlr ( !( 1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup );
   loc_surf_id.osnum = edge.osnum;


  /* 
   * Seam edges for which have the common-edge also as a seam edge of the
   * same surface are not classified as "special tangent".
   */

   if(edge_props & EMED_SEAM && (loc_surf_id.objid == loc_comm_surf_id.objid))
   {
     *is_sp_tan = FALSE;
     goto wrapup;
   }

   /* 
    * Get the poly line geometry of the edge. 
    */
   ret_sts = om$send ( msg = message EMSedge.EMgetpygeom ( &ret_msg, 0, MAXINT, 
                                      FALSE, NULL, &pygeom,
                                      NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = edge.objid,
                       targetos = edge.osnum );
   EMerr_hndlr ( !(1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup);
 
   BSEXTRACTPAR( &rc, BSTOLLENVEC, tol);
   EMerr_hndlr( BSERROR(rc), *msg, EMS_E_BSerror, wrapup );

   is_iso = EMis_iso_edge( pygeom.num_points, pygeom.points, tol, iso_points );

   /*
    * If the edge is not a tangent edge or an iso edge it cannot be a 
    * special tangent (T2) edge.
    */
 
   if( (edge_props & EMED_DEGENERATE) || !(*neutral) || 
       !(fabs(*ang_meas-2.0) <= EMS_ZEROANGLE_DEG) || 
       !(is_iso) ) goto wrapup;

   /* 
    * Get the class name of the surface 
    */

   ret_sts = om$get_classname( objid = loc_surf_id.objid,
                               osnum = loc_surf_id.osnum,
                               classname = classname );
   EMerr_hndlr( !(1 & ret_sts), *msg, EMS_E_OMerror, wrapup );

   /*
    * If the surface is a general B-Spine surface then it doesn't have a 
    * special tangent edge (Assumption) .
    */
 
   if( (strcmp( classname, "EMSgenbs") == 0 ) ||  
       (strcmp( classname, "EMAgenbs") == 0 ) ) 
   {
       *is_sp_tan = FALSE;
       goto wrapup;
   } 

   /* 
    * Get the class name of the common surface 
    */

   ret_sts = om$get_classname( objid = loc_comm_surf_id.objid,
                               osnum = loc_comm_surf_id.osnum,
                               classname = classname );
   EMerr_hndlr( !(1 & ret_sts), *msg, EMS_E_OMerror, wrapup );
  
   /*
    * If the surface is a general B-Spine surface then it doesn't have a 
    * special tangent edge (Assumption) .
    */
 
   if( (strcmp( classname, "EMSgenbs") == 0 ) || 
       (strcmp( classname, "EMAgenbs") == 0 ) ) 
   {
       *is_sp_tan = FALSE;
       goto wrapup;
   } 

   /* 
    * Check for the class ids of the two surfaces. If they donot
    * match, then edge cannot be a special tangent edge.
    */

   ret_sts = om$get_classid( objid = loc_surf_id.objid,
                               osnum = loc_surf_id.osnum,
                               p_classid = &surf_classid );
   EMerr_hndlr( !(1 & ret_sts), *msg, EMS_E_OMerror, wrapup );
   ret_sts = om$get_classid( objid = loc_comm_surf_id.objid,
                               osnum = loc_comm_surf_id.osnum,
                               p_classid = &comm_surf_classid );
   EMerr_hndlr( !(1 & ret_sts), *msg, EMS_E_OMerror, wrapup );
#ifdef DEBUG
  printf("surf classid = %d ; comm surf classid = %d\n", 
                         surf_classid, comm_surf_classid);
#endif

   if(!((om$is_ancestry_valid (subclassid = surf_classid,
        superclassid = comm_surf_classid) == OM_S_SUCCESS) ||
        (om$is_ancestry_valid (subclassid = comm_surf_classid,
         superclassid = surf_classid) == OM_S_SUCCESS)))
   {
      *is_sp_tan = FALSE;
      goto wrapup;
   }

   /*
    * Now check for the global tangency
    */

   options = EMSchkconvex_global;
   loc_convex = loc_neutral = FALSE;
   ret_sts = om$send( msg = message EMSedge.EMchkconvex( &ret_msg, options,
                                   mattyp, mat, EMS_ZEROANGLE_DEG,
                                   &loc_convex, &loc_neutral, &loc_ang_meas ),
                      senderid = NULL_OBJID,
                      targetid = edge.objid,
                      targetos = edge.osnum );
   EMerr_hndlr ( !(1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup);

   if( loc_neutral && (fabs( loc_ang_meas - 2.0 ) <= EMS_ZEROANGLE_DEG) )
   {
#ifdef DEBUG
 printf("Special Tangency due to Global Tangency \n");
#endif
       *is_sp_tan = TRUE;
    /* goto wrapup; */
   }

   /*
    * The edge is a iso-tangent edge and the adjacent surfaces are not the
    * general B-Spline surfaces. It may be a special tangent. For an edge
    * to be a special tangent, it should be iso, tangent and surrounded by
    * two non genbs surfaces and with curvature continuity perpendicular 
    * to the direction of edge.
    */

   /*
    * Find the iso direction
    */
  
   if( iso_direc ) 
   {
       int         ii;
       IGRboolean  u_iso, v_iso; 
     
       u_iso = v_iso = TRUE; 
       for(ii=1; ii<pygeom.num_points; ii++)
           if( fabs(pygeom.points[ii*2] - pygeom.points[0]) > tol )   
           { u_iso = FALSE; break; }

       for(ii=1; ii<pygeom.num_points; ii++)
           if( fabs(pygeom.points[ii*2+1] - pygeom.points[1]) > tol )   
           { v_iso = FALSE; break; }

       if( u_iso && v_iso ) { *is_sp_tan = FALSE;  goto wrapup; }
       if( u_iso ) *iso_direc = CONST_U;
       else *iso_direc = CONST_V; 
    }

    if(!(*is_sp_tan))
    {
      /*
       * Get the 5 internal uv points of the edge
       */
      ret_sts = om$send ( msg = message EMSedge.EMinternalpt ( &ret_msg,
                                      5, NULL, uvpt, NULL, NULL ), 
                          senderid = NULL_OBJID,
                          targetid = edge.objid,
                          targetos = edge.osnum );
      EMerr_hndlr( !(1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup );

      /*
       * Get the general bspline geometry of the surface and common surface. 
       */

      ret_sts = om$send( msg = message GRvg.GRgetsize( &ret_msg, 
                                       mattyp, mat,
    	                             &size ),
                         senderid = NULL_OBJID,
                         targetid = loc_surf_id.objid,
                         targetos = loc_surf_id.osnum );
      EMerr_hndlr( !( 1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup);
 
      surf_geom = (struct IGRbsp_surface *) om$malloc( size = size );
      EMerr_hndlr(!surf_geom, *msg, EMS_E_DynamicMemoryAllocated, wrapup);

      ret_sts = om$send( msg = message GRvg.GRgetgeom( &ret_msg, 
                                       mattyp, mat,
                                       (IGRchar *) surf_geom ),
                         senderid = NULL_OBJID,
                         targetid = loc_surf_id.objid,
                         targetos = loc_surf_id.osnum );
      EMerr_hndlr( !( 1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup);
         
      ret_sts = om$send( msg = message GRvg.GRgetsize( &ret_msg, 
                                       mattyp, mat,
    	                             &size ),
                         senderid = NULL_OBJID,
                         targetid = loc_comm_surf_id.objid,
                         targetos = loc_comm_surf_id.osnum );
      EMerr_hndlr( !( 1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup);
 
      comm_surf_geom = (struct IGRbsp_surface *) om$malloc( size = size );
      EMerr_hndlr(!comm_surf_geom, *msg, EMS_E_DynamicMemoryAllocated, wrapup);

      ret_sts = om$send( msg = message GRvg.GRgetgeom( &ret_msg, 
                                       mattyp, mat,
                                       (IGRchar *) comm_surf_geom ),
                         senderid = NULL_OBJID,
                         targetid = loc_comm_surf_id.objid,
                         targetos = loc_comm_surf_id.osnum );
      EMerr_hndlr( !( 1 & ret_sts & ret_msg), *msg, EMS_E_EdgeError, wrapup);
         
      /*
       * Get the xyz points on the surface corresponding to uvpts
       */

      for(ii=0; ii<5; ii++)
      {
          BSsfeval(surf_geom, uvpt[ii*2], uvpt[ii*2+1], 0, &xyz_pts[ii], &rc);
          EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup );
      }

      ii = 0;
      do
      {
        /*
         * Get the uvpt on the surface corresponding to xyzpt
         */ 
        surf_uvpt[0] = uvpt[ii*2];
        surf_uvpt[1] = uvpt[ii*2+1];
                                          
        /*
         * Get the uvpt on the common surface corresponding to xyzpt 
         */ 
        ret_sts = om$send ( msg = message EMSsubbs.EMpratmpt( &ret_msg,
                                      mattyp, mat, 1,
                                   /* &md_env->matrix_type, md_env->matrix, 1,*/
                                      &xyz_pts[ii][0],cm_surf_uvpt, NULL, NULL),
                            senderid = NULL_OBJID,
                            targetid = loc_comm_surf_id.objid,
                            targetos = loc_comm_surf_id.osnum );
        EMerr_hndlr( !(1& ret_sts& ret_msg), *msg, EMS_E_SurfaceError, wrapup);
       
        /*
         * Get surface's mean curvature
         */ 
        if(surf_geom->planar)
                mean_crv = 0.0;
        else
        {
             ret_sts = om$send ( msg = message EMSsubbs.EMsfradcrv ( &ret_msg,
                                       mattyp, mat,
                                       NULL, 2, 1, &surf_uvpt[0], 1,
                                       &surf_uvpt[1], DBL_MAX, &mean_crv,
                                       NULL, NULL),
                            senderid = NULL_OBJID,
                            targetid = loc_surf_id.objid,
                            targetos = loc_surf_id.osnum );      
             EMerr_hndlr( !(1& ret_sts& ret_msg), *msg, 
                                              EMS_E_SurfaceError,wrapup);
        }

        /*
         * Get common surface's mean curvature
         */ 
        if(comm_surf_geom->planar)
                cm_mean_crv = 0.0;
        else
        {
              ret_sts = om$send ( msg = message EMSsubbs.EMsfradcrv ( &ret_msg,
                                       mattyp, mat,
                                       NULL, 2, 1, &cm_surf_uvpt[0], 1, 
                                       &cm_surf_uvpt[1], DBL_MAX, &cm_mean_crv,
                                       NULL, NULL ),
                            senderid = NULL_OBJID,
                            targetid = loc_comm_surf_id.objid,
                            targetos = loc_comm_surf_id.osnum );      
              EMerr_hndlr( !(1& ret_sts& ret_msg), *msg, 
                                               EMS_E_SurfaceError,wrapup);
        }

        if( fabs( cm_mean_crv - mean_crv ) > tol )
        {
            *is_sp_tan = FALSE;
            goto wrapup;
         } 
  
      } while ( ++ii < 5 );  /* do ...*/
        /* Continue the loop for 5 iterations i.e. sample points */ 
  
      /*
       * If for all the 5 iterations it is success, set is_sp_tan flag to TRUE
       */
#ifdef DEBUG
 printf("Special Tangent Due to Curvature continuity %lg, %lg\n",
                 mean_crv, cm_mean_crv);
#endif
      *is_sp_tan = TRUE;
    } /* end of if(!(*is_sp_tan)) */

    /* 
     * Special tangencies need to be considered only when there is a need
     * to shift these intersection to another point, due to the movement
     * of either of its vertices. This happens only when either of the
     * two edges has more than three edges meeting at them. 
     */

    if(*is_sp_tan)
    {
       IGRushort      options;
       IGRboolean     right_vtx, *is_rightend[2];
       IGRint         num_buff, num_edges[2];

       /* Initialise */
       edges[0] = edges[1] = NULL;
       is_rightend[0] = is_rightend[1] = NULL;
       options = EMSvtxedges_onlydominant | EMSvtxedges_noseamedge |
                 EMSvtxedges_nodegenerate;
 
       for (ii = 0; ii < 2 ; ii++)
       {
          num_buff = num_edges[ii] = 0;
          right_vtx = TRUE;
          if(ii > 0) right_vtx = FALSE;
          ret_sts = om$send (msg = message EMSedge.EMgetvtxedges(&ret_msg,
                                  options, right_vtx, num_buff,
                                  &num_edges[ii], &edges[ii], &is_rightend[ii]),
                            senderid = NULL_OBJID,
                            targetid = edge.objid,
                            targetos = edge.osnum);
          if(is_rightend[ii]) om$dealloc(ptr = is_rightend[ii]);
          is_rightend[ii] = NULL;
          EMerr_hndlr(EMSerror(ret_sts & ret_msg), *msg,
                                                     EMS_E_EdgeError, wrapup);
#ifdef DEBUG
printf("For edge id = %d of Surface id = %d :\n", edge.objid, loc_surf_id.objid);
  if(ii == 0)
     printf("Number of edges at right vertex = %d\n", num_edges[ii]);
  else
     printf("Number of edges at left vertex = %d\n", num_edges[ii]);
#endif
       }

       if((num_edges[0] <= 3) && (num_edges[1] <= 3))
       {
#ifdef DEBUG
  printf("Not considered a special tangent edge\n");
#endif
          *is_sp_tan = FALSE;
          goto wrapup;
       }

      /*
       * Check whether all the edges are tangent. If all the edges are 
       * tangent then this edge need not be classified as a special
       * tangent edge.
       */

       for(ii=0; ii<2; ii++)
       {
            if(num_edges[ii] <= 3) continue;
            for(jj=0; jj<num_edges[ii]; jj++)
            {
               struct GRid              vtxedg, vtxedg_surf, comm_ed, comm_surf;
               IGRboolean               vtxedg_free;
               IGRushort                vtxedg_props, vtxcm_ed_props;
               IGRdouble                vtxedg_ang_meas;
               struct EMSpartolbasis    partolbasis;

               vtxedg.objid = edges[ii][jj];
               vtxedg.osnum = vtxedg_surf.osnum = edge.osnum;
               comm_ed.osnum = comm_surf.osnum = edge.osnum;

               /* get surface id of this edge */
               partolbasis.is_valid = FALSE;
               partolbasis.in_world = TRUE;
               partolbasis.mattyp = mattyp;
               partolbasis.mat = mat;

               ret_sts = om$send(msg = message EMSboundary.EMgetsurface_info
                                       (&ret_msg, &vtxedg_surf.objid,
                                                  &partolbasis),
                                 senderid = NULL_OBJID,
                                 targetid = vtxedg.objid,
                                 targetos = vtxedg.osnum);
               EMerr_hndlr(! (1 & ret_sts & ret_msg),
                                             *msg,EMS_E_EdgeError,wrapup);

               ret_sts = EFget_edge_info(&ret_msg,
                                     mattyp, mat, vtxedg,
                                     &comm_ed, &comm_surf, &vtxedg_props,
                                     &vtxedg_free, &loc_convex, &loc_neutral,
                                     (IGRboolean *)NULL, (IGRboolean *)NULL,
                                     &vtxedg_ang_meas, &vtxcm_ed_props);
               EMerr_hndlr(! (1 & ret_sts & ret_msg),
                                             *msg,EMS_E_EdgeError,wrapup);

               if(!loc_neutral && !vtxedg_free)
               {
                 *is_sp_tan = TRUE;
                 goto wrapup;
               }
            } /* end of for(jj..)  */
       } /* end of for(ii...) */
       if(*is_sp_tan) *is_sp_tan = FALSE;

    }

wrapup :
    if( pygeom.points ) om$dealloc( ptr = pygeom.points );    
    if( surf_geom ) om$dealloc( ptr = surf_geom );
    if( comm_surf_geom ) om$dealloc( ptr = comm_surf_geom );
    for(ii=0; ii<2; ii++)
      if(edges[ii])  om$dealloc( ptr = edges[ii]);
    return ( ret_sts );
}

end implementation EMScompsurf;


