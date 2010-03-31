class implementation EMScompsurf;
/*
DESCRIPTION

This function constructs an offset of a composite surface using a general
offset algorithm which essentially consists of following steps:

  - offset component surfaces.
  - extend the offset component surfaces sufficiently such that adjacent
    intersect.
  - map edges on original surfaces to the corresponding intersection curves
    on the offsets.
  - trim every intersection curve on each offset surface with its adjacent
    curves.
  - create and nest the loops on the offset surfaces.
  - stitch the offset surfaces

It optionally returns the boundaries of the output offset composite surface as 
an inters list.

It optionally returns the components of the incoming composite-surface.

RETURN VALUE

Returns OM_S_SUCCESS if operation is successful.

RETURNED PARAMETERS
constructed_object  The offset composite-surface.
inters_out	    The EMSinters linked list corresponding to the boundaries
		    of constructed_object.
num_comps	    The number of primitive surfaces in the incoming composite.
sf_comps	    The objids of primitive surfaces in the incoming composite.
msg 		    EMS_S_Success - successful
                    EMS_E_Fail    - if failure
edge_map_list       The edge ids list  of the original composite surface 
                    in the order similar to that of the offset surface
                    

NOTE

If an error occurs, no object will be returned.

HISTORY
        30 July 95   V.Srinivas         Loops when get merged due to the 
                                        presence of seam edge was leading to
                                        topology mismatch, so to solve this 
                                        problem for this special case 
                                        EFoffset_compsf_tw is created
                                        instead of EFoffset_compsf.
                                        This function returns edge_map_list
                                        variable with edge ids list of
                                        original surface in the same order 
                                        as that of offset surface. For the
                                        case other than this special case
                                        it returns NULL values. 
        20 Nov 95       Jagan           When the Loops are merged across the
                                        Seam_edge and it still sends the vertex
                                        formed by the seam and the previous
                                        edge to form the vertex on the resultant
                                        offset_surface it gives bad results.
                                        So The intobj's more_info is sent as
                                        NULL in such cases, to avoid this
                                        problem.
        24 Oct 95       Jagan          Added a new function EFget_intobj_extdist
                                        which finds out the extention dist
                                        required for the edges before there
                                        are mapped on to the offset surf. 
        07 sep 95       Jagan           Added an option is_full to the routine
                                        EFmkint_from_iso_edge which takes the
                                        ISO edge from U=0 to U=1 if is_full is 
                                        set to TRUE else it is with in the start
                                        and ens limits.modified the routine 
                                        EFprj_midpoint_onto_off_surf to project
                                        the end points also.Fixed tr#119525198  
        02 Sep 94       Sanjay          Fixed a problem related to the ISO
                                        direction to be returned by the routine
                                        EFprj_midpoint_onto_off_surf.
	16 Jun 94	ashok	 	Copied "mlk" fixes from EMS 4 version.
        11 Jan 94       sudhakar        Modified the args. of EFget_edge_info()
                                        to determine whether an edge is a
                                        special tangent edge. Also added code
                                        to not process a special tangent edge as
                                        a natural edge. Marking of special
                                        tangent edge intobjs is done. Also
                                        modified such that stop-start properties
                                        are not set for special tangent
                                        intobjs (fix for TR# 119312801).
        04 Jan 94       sudhakar        Added a new "NULL" option arg. to all 
                                        occurances of "EFcvt_edge_to_cv()" 
                                        function call.
        17 Dec 93       ashok/sudhakar  Modified the criteria used by the
                                        function "EFgenerate_an_iso_intobj"
                                        so that the check for "BSP" surfaces
                                        is not done.
        13 Dec 93       sudhakar        Fixed a bug in handling of adjacent
                                        surface offset distance information
                                        for single surfaces [TR# 119313969].
        02 Dec 93       sudhakar        Fix for TR# 119313755. Mark any
                                        degenerate free edge intobj
                                        as 'EMSintobj_xyzdegenerate'.
        29 Nov 93       sudhakar        Added two new functions to 
                                        enable preserving 'iso' edges in
                                        the original solid/surface as
                                        'iso' edges in the offset, wherever
                                        possible.
                                        New Functions:
                                            EFmkint_from_iso_edge()
                                            EFgenerate_an_iso_intobj()
                                        Functions Modified:
                                            EFmkint_from_nat_edge().
        25 Nov 93       ashok           Modified to pass new additional
                                        parameter to EMextend_by_distance
                                        message.
        05 Nov 93       sudhakar        Added code to pass the offset distances
                                        of the adjacent surfaces to the 
                                        "EFget_sf_extensions" function (two
                                        new args). This enables handling 
                                        large differences in the multiple
                                        offset distances of adjacent surfaces.
        03 Nov 93       sudhakar        Modified such that 'stopstart'
                                        properties of the 'other_intobj'
                                        for a 'full natural' edge are 
                                        set only if the 'other_intobj' is 
                                        not also originating from a 
                                        'full natural' edge. Also adedd
                                        a new static function to delete
                                        the 'tmpmarked' from all the 
                                        'intobjs' at the end of stage 2.
        28 Oct 93       sudhakar        Modified tangency check to use
                                        EMS_ZERODEG_ANGLE. Resetting the
                                        commond-edge-surface to 'NULL_OBJID'
                                        on encountering a 'free' edge. 
                                        Combining all left-over extended
                                        surfaces into a graphic group in
                                        DEBUG mode.
	15 Oct 93	ashok		Enhanced handling of tangent and free
					edge cases. If such an edge is also
					a full natural edge then we snap on
					to the corresponding natural edge on
					the offset surface instead of projecting
					and extending it.
	01 Oct 93	sampath		Added code to create loopset for
					for component surface if not present.
	27 Sep 93	sampath		Added new flag
					EMS_opt_offsetS_remove_opensfs
					to remove open surfaces.
	01 Sep 93	ashok		Modified for argument change to
					EFext_and_prj_cv().
	15 Aug 93	ashok		Added arguments num_comps
					and sf_comps. If these are non-NULL
					the components of the composite-
					surface (in_grid) are returned to 
					caller. Updated DESCRIPTION.
        27 Jun 93       sudhakar        Added code to set the extension
                                        distances for 'open' surfaces to
                                        5 times the common offset distance.
        19 May 93       sudhakar        Modified to implement Code Review
                                        Recommendations.
	23 Apr 93	ashok		Creation. Moved code from method.
	15 May 93	ashok		Code review changes to make the
					code readable and modular.


ALGORITHM

	Essentially there are 4 stages:

	STAGE 1 - Offset each component surface (ignoring boundaries) of the 
		  composite and then extend it in all the parametric directions.
                  If the surface has seams and is not closed in either u or v,
                  then create an equivalent 'partial' surface and generate
                  the extended offset of the 'partial' surface.

	STAGE 2 - This is the guts of this method. Generate the inters list
		  for the offset composite surface. Consists of foll steps:

		- For every surface S (S -> original sf, S' -> corres. offset)

		  - For every loop L of S

		    - For every edge E of L

			- Check if E is a free edge.
			  If so compute the corresponding intobj on S' by
			  extending the geometry of E and then projecting it
			  on to S'. Then connect the intobj to the inters node
			  of S' "in-place" (using appropriate static function)

			  Else 
                          If the current edge is connected at-a-seam to an
                          already processed edge, then no intobj need be 
                          generated. So post the current edge-id into the
                          'more-info' of the already generated intobj and
                          continue to next edge.
                          Otherwise
                          scan the avail_intobjs_list of S' to see if
			  the intobj has already been created while processing
			  common edge of E.
			  If so,
			     Extract the intobj from the avail_intobjs_list
			     and connect it to the inters node "in-place"
			     (using appropriate static function).
			  Else if current edge is a seam-edge
                               If S is closed in u or v
                                   Generate the two seam intobjs. Place the
                                   correct intobj in the inters list and
                                   the other intobj in the avail_intobjs_list.
                               Else
                                   Merge the loops across the seam edge and
                                   continue to next edge.
                          Else 
			     Check if E is a tangent edge.
			     If so,
				Compute the intobjs on S' and on S''(the offset
				of the surface across the common edge of E) by
				extending the geometry of E and then projecting
				on to S' and S''. Then connect the intobj on S'
				to its inters node "in-place" as usual. Append
				intobj on S'' to the avail_intobj_list of S''.
			     Else
				Compute the intobjs on S' and S'' by performing
				surface-surface intersection. If more than one
				intersection curves result do edge matching
				and just retain the one that matches with E.
				Connect the intobjs as mentioned above.

	STAGE 3 - Now the inters list for the composite surface is ready.
		  At this point:
		  On any inters node all the intobjs that are to finally
		  form a loop are placed "in sequence" (effected by connecting
		  them by the "fwd" pointer mechanism apart from "next" poiner).
		  To get to the starting intobj of the next loop go across
		  the "next" pointer of "last" intobj (whose fwd pointer points
		  to NULL) of the previous loop.
		  Now visit each inters node and generate the boundaries. This
		  involves the following steps for each loop of the surface:

		    - splitting every intobj with the adjacent intobjs and
		      discard the end pieces resulting from the split.
		    - Creating edge objects from the split intobj geometry.
		    - Creating loop object from the edges and nesting it
		      into the loopset of the surface.

	STAGE 4 - At this point boundaries on all the offset surfaces have
		  been created. Now stitch all the surfaces together.

	Note: Static functions are used in this file to build the inters list. 
	      These static funtions work on the following static variables
	      defined in this file.

		Sf_Inters 	- Pointer to the inters list being built.
		Current_Inters  - Pointer to the inters node of the current
				  surface being processed.

		Current_Surface - Objid of the surface being processed.
		Current_Loop    - Objid of the loop being processed.
		Loop_Start_Edge - Objid of the starting edge of Current_Loop.
		Current_Edge    - Objid of edge being processed.
		Common_Edge	- Objid of common edge of Current_Edge.

		Loop_Start_Intobj    - Pointer to intobj corresponding to
				       Loop_Start_Edge.
		Fwd_Connect_Intobj   - Pointer to the intobj corresponding to
				       Current_Edge.
		Prev_Loop_Last_Intobj- Pointer to the last intobj of the loop
				       processed prior to the Current_Loop.
		Avail_Intobjs_Ptr    - Pointer to the list of intobjs on
				       Current_Surface that were generated 
				       earlier while processing other surfaces.

	      The following static functions are used to build the inters list:

		EFinit_start_intobj()  - Initializes  Loop_Start_Intobj and 
					 Fwd_Connect_Intobj to input intobj.

		EFfwd_connect_intobj() - Connects input intobj to 
					 Fwd_Connect_Intobj->fwd. Then resets
					 Fwd_Connect_Intobj to input intobj.

		EFscan_intobj_list()   - Checks if an intobj corresponding to
					 Current_Edge is alredy present in
					 Avail_Intobjs_Ptr list. If so returns
					 it.

	        EFextract_intobj_from_list() - Extracts the input intobj from
					       the list pointed by Avail_Intobjs
						_Ptr and then appends it to
						current intobj loop chain by
						calling EFfwd_connect_intobj().

		EFarrange_loop_intobjs()- Connects all the "fwd" connected
					  intobjs with "next" pointer also.
					  Then connects Loop_Start_Intobj to
					  Current_Inters->cvs if first loop 
					  else to Prev_Loop_Last_Intobj.
					  Resets Prev_Loop_Last_Intobj.

	        EFget_inters_node() - Given a surface object gets the pointer
				      to its inters node.

	        EFappend_intobj_to_list() - Appends input intobj to the input
					    inters node. The accumulated 
					    intobjs would later represent
					    the Avail_Intobjs list when this
					    inters node becomes Current_Inters.

		EFappend_intobj_to_Avail_list() - Appends input intobj to the
                                                  current Avail_Intobjs list.
		
	        EFmerge_with_inters_list() - Picks the intobjs from the input
					     inters list and appends them to
					     corresponding inters nodes of
					     Sf_Inters.

		EFset_stopstart_property() - Sets the 'EMSintobj_exact_atstop/
                                             atstart' property bit, appropria-
                                             tely for intobjs touching seam-
                                             intobjs.

		EFset_other_stopstart_property() - Sets the above property
                                                   for the other_intobj.

		EFmerge_loop_across_seam() -  Merges the edges of the loop
                                              across the seam edge of the
                                              current loop.

		EFpost_edge_to_intobj_moreinfo() - Adds the common-edge-objid
                                                   of the current edge
                                                   to the 'more-info' of the
                                                   'other-intobj' if the
                                                   other surface has not already
                                                   been processed.

		EFadd_edge_to_intobj_moreinfo() - Used by the above function.


		EFis_this_edge_redundant() - Checks whether an 'intobj'
                                             needs to be generated for the
                                             current edge or not.

		EFcheck_same_common_sfs() - Checks for connected-at-seam by
                                            comparing the common-surfaces and
                                            presence of seams.

                EFalready_processed_other_surface() - Checks whether the other-
                                                      intobj surface has already
                                                      been processed. This info
                                                      is used to decide whether
                                                      to add the edge-id into
                                                      more-info of the other-
                                                      intobj.

                EFfree_edgelist_more_info() - Frees the more_info pointer of
                                              the current-intobj from pointing
                                              to the 'edge-list' linked-list.

                EFgenerate_an_iso_intobj() - This function is used to check 
                                             whether an 'Iso' edge in the
                                             original surface should be marked 
                                             as 'Iso' in the 'offset' surface. 

                EFmkint_from_iso_edge() -  This function is used for generating
                                           the intersection objects from an
                                           iso edge and its common edge if there
                                           is one. The assumption is that
                                           the edge is 
                                              either a stitchable (free) edge
                                                  or a tangent edge.
                                           If tangent,
                                              either or both could be iso.
*/

#include "OMmacros.h"
#include "EMS.h"
#include "EMSasdef.h"
#include "EMSssprops.h"
#include <values.h>
# include "EMSopt.h"    /* EMS_OPT_ALL EMS_opt_offsetS_copy_topology */
# include "EMSprop.h"   /* EMED_XYZ_CLOSED EMED_DEGENERATE */
/* # include "ems_m_inc.h" Includes the world */
# include "gocmacros.h" /* Include generate abstract macro */
# include "EMS_E.h"     /* EMS_E_InsufficientDynamicMemory */
# include "emsdef.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "msmacros.h"
#include "emsmapdef.h"
#include "EMSsplitdef.h"
#include "EMSifmacros.h"
#include "bsvalues.h" /* defines MAXINT */
#include "bsgeom_cvsf.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsprptonsf.h"
#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWapi/eded.h"
#include "PWapi/sfgeom.h"
#include "PWapi/partol.h"

static void EFget_intobj_extdist
(
  GRobjid    edobj,
  OMuword    os,
  IGRushort  lpprops,
  double     offdist,
  double     partol,
  double     chttol,
  double     ext_dist[2]
);

extern PWboolean pwIsEdFree
(
  PWobjid   edobj,
  PWosnum   os
);
%safe
#include <math.h>
static OM_S_OBJID Current_Surface, Current_Loop, Loop_Start_Edge,
		  Current_Edge, Common_Edge;
static struct EMSinters  *Sf_Inters, *Current_Inters;
static struct EMSintobj  *Loop_Start_Intobj, *Fwd_Connect_Intobj,
			 *Prev_Loop_Last_Intobj, *Avail_Intobjs_Ptr;
static void EFinit_start_intobj(), EFfwd_connect_intobj(), EFscan_intobj_list(),
	    EFextract_intobj_from_list(), EFarrange_loop_intobjs(),
	    EFget_inters_node(), EFappend_intobj_to_list(),
	    EFmerge_with_inters_list(), EFappend_intobj_to_Avail_list(),
            EFset_stopstart_property(), EFset_other_stopstart_property(),
            EFmerge_loop_across_seam(),
            EFpost_edge_to_intobj_moreinfo(), 
            EFadd_edge_to_intobj_moreinfo(),
            EFfree_edgelist_more_info(),
	    EFchk_if_natural(), EFreset_tmpmark_on_surface_intobjs();
static IGRboolean EFis_this_edge_redundant(),
                  EFcheck_same_common_sfs(),
                  EFalready_processed_other_surface(),
                  EFgenerate_an_iso_intobj();
static struct EMSintobj  *EFmkint_from_nat_edge(), 
                         *EFmkint_from_iso_edge();
static IGRlong EFprj_midpoint_onto_off_surf();
static IGRboolean EFis_along_seam();
static void EFchk_if_iso();
%endsafe

struct EMSoff_sf_info
{
   GRobjid	     objid;       /* objid of the offset sf component */
   IGRdouble	     distance;    /* offset distance for the sf component */
   IGRushort	     props;       /* sf attributes such as phy_closed, planar etc */
   IGRint	     num_adj_sfs; /* No of common edge sfs for this sf */
   IGRint	     *adj_sfs;    /* indices to common sfs w.r.t surfs[] array */
};

struct edge_list 
{
   GRobjid           edgeid;
   struct edge_list  *next;
};

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

#define CONST_U  0
#define CONST_V  1

extern OMuword OPP_EMSgencompsf_class_id;

from EMSsubbs import EMget_props,EMextend_by_dist_from_orig_surf; 
from EMSsubbs import EMpartolbasis;
from EMSsubbs import EMextend_by_dist;
from EMSedge import EMchkconvex, EMget_props, EMget_location, EMendpts, 
                    EMxyz_endpt,EMinternalpt, EMgetvtxedges, EMgetpygeom;
from EMSloop  import EMget_edges;
from EMSloopset import EMget_loops, EMbounded_uv_range;
from EMSboundary import EMget_objid, EMgetsurface_info;
from EMSsubbs import EMreduce_range;
from EMSsubbs import EMgetbsdef;

IGRlong EFoffset_compsf(msg, in_grid, option, mattyp, mat, construct_list,
			offset_inward, distance, num_spec_thick,
			val_spec_thick, spec_thick_sf_sets, num_nooffsetsfs,
			nooffsetsfs, status_str, constructed_object,
			inters_out, num_comps, sf_comps, errkey_list)
    IGRlong *msg;
    struct GRid in_grid;
    IGRushort option;
    IGRshort *mattyp;
    IGRmatrix mat;
    struct GRvg_construct *construct_list;
    IGRboolean offset_inward;
    IGRdouble distance;
    IGRint num_spec_thick;
    IGRdouble *val_spec_thick;
    struct GRobjid_set *spec_thick_sf_sets;
    IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
    IGRchar *status_str;
    OM_S_OBJID *constructed_object;
    struct EMSinters **inters_out;
    IGRint *num_comps;
    GRobjid **sf_comps;
    struct EMSerror_help *errkey_list;

{
IGRlong			sts, msg_loc, num_inters, jj;
IGRint                  num_edges, *comm_sf_indices=NULL;
IGRshort		loc, ed_loc, cm_ed_loc;
IGRdouble		tol, lentol, ext_dist[4], ang_meas, 
                        *adjsfs_offdists=NULL;
GRobjid			*surfs=NULL;
struct GRid		*edges, comm_ed, orig_surf, off_surf,comm_surf, cs_grid;
struct EMSoff_sf_info	*off_surfs_info=NULL;
struct EMSdataselect	sf2_data;
IGRushort		inters_options, world_options, param_options, *props,
			ed_props, cm_ed_props, opt;
IGRint		i, j, k, l, clos_info, buff_size, list_size, numsf,no_edges[2], 
			depth, num_loops, max_adjsfs, num_adjsfs, comm_sf_ind=0; 
                                       /* initialize to
					  prevent stupid compiler warning */
IGRboolean		world, convex, neutral, matches, is_free,
			ed_nat, cm_ed_nat, ed_iso, cm_ed_iso, ls_created=FALSE,
                        is_spec_tangent=FALSE;
struct GRmd_env		sfmdenv;
struct EMSpartolbasis	partolb;
struct EMSinters	*p_inters, *tmp_inters, *other_inters;
struct EMSintobj	*p_intobj, *p_intobj_fwd, *p_match, *p_intobjs[2],
			*current_intobj;
OM_S_OBJID		*loop_ids;
OM_S_CHANSELECT		chan_to_loopset;
struct IGRbsp_curve     *cv_geom = NULL;
struct EMSpypoint	*p_pypt = NULL;

/* Variables added by Sudhakar to support seams */
OM_S_OBJID     	prev_common_surface;
IGRboolean     	stat_func, seam_affected;
IGRint          this_seam_index, other_seam_index;

extern void		EMdelintobj(), EFcvt_edge_to_cv(),
			EFget_sf_extensions(), EFget_component_offsets();
extern IGRboolean	EFintobj_matches_edge(), EFconvert_seam_to_intobjs(),
			EFproj_vert_to_intobj();
extern IGRlong 		EFget_edge_info();
extern struct EMSintobj *EFext_and_prj_cv();
extern struct EMSinters	*EMinters_malloc();
extern IGRdouble 	fabs();
/*
 * Initialize
 */
	*msg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	*constructed_object = NULL_OBJID;
	Sf_Inters = NULL;
	edges = NULL;
	loop_ids = NULL;
	props = NULL;
	opt = EMSExtPrj_NoClip | EMSExtPrj_WantSingleOut;

        EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
        sfmdenv.md_env.matrix_type = *mattyp;
        OM_BLOCK_MOVE(mat, sfmdenv.md_env.matrix, sizeof(IGRmatrix));
        sfmdenv.md_id.objid = construct_list->env_info->md_id.objid;
        sfmdenv.md_id.osnum = construct_list->env_info->md_id.osnum;

/*
 * get  list of the surfaces of this composite surface
*/

	sts = om$send( msg = message GRowner.GRget_number_components(
				&msg_loc, &numsf ),
			senderid = NULL_OBJID,
			targetid = in_grid.objid,
			targetos = in_grid.osnum );
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	surfs = (GRobjid *) om$malloc(size = numsf * sizeof(GRobjid));

	off_surfs_info = (struct EMSoff_sf_info *) om$malloc(size = numsf * 
					      sizeof(struct EMSoff_sf_info) );
	list_size = numsf;
	buff_size = num_edges = numsf = 0;
	EMerr_hndlr((!surfs || !off_surfs_info), *msg, EMS_E_NoDynamicMemory, 
	             ret_end);

	sts = om$send(msg = message EMScompsurf.EMgetedges(&msg_loc,
			    EMS_OPT_STITCHED, NULL, &buff_size, &num_edges,
			    &surfs, NULL, &list_size, &numsf),
		      senderid = NULL_OBJID,
		      targetos = in_grid.osnum,
		      targetid = in_grid.objid);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	/* Allocate the memory that will be used to store the indices of
	   the adjacent surfaces
	*/
        if(num_edges)
        {
	   comm_sf_indices = (IGRint *) om$malloc(size = num_edges *
					       sizeof(IGRint));
	   EMerr_hndlr((!comm_sf_indices), *msg,
                                      EMS_E_NoDynamicMemory, ret_end);
        }
        else
        {
          /* No stitched edges . Hence number of components got to be 1 */

           numsf = 1;
           sts = om$send( msg = message GRowner.GRget_components(
                                &msg_loc, &sfmdenv, &orig_surf, numsf,
                                &numsf, 0, 0),
                        senderid = NULL_OBJID,
                        targetid = in_grid.objid,
                        targetos = in_grid.osnum );
           EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

           surfs[0] = orig_surf.objid;

	   /* Make sure the surface has a 'loopset' before proceeding. */

	   sts = om$send (msg = message EMSsubbs.EMputLsIfNotThere(&msg_loc,
                   &(sfmdenv.md_env), NULL, NULL, 0, &ls_created),
                   targetid = surfs[0],
                   targetos = in_grid.osnum,
                   senderid = NULL_OBJID);
           EMerr_hndlr(! (1 & sts & msg_loc), *msg,EMS_E_LoopsetError, ret_end);

        }

/* 1ST STAGE PROCESSING. OFFSETTING AND EXTENDING COMPONENT SURFACES .... */
   ex$message(msgnumb = EMS_S_ProcessingOne);

/* Offset and fill in information for all the component surfaces such as 
   U/V-closure, seam deleted or not, offset-distance and adjacent surface
   indices in the 'off_surfs_info' list.
*/
	EFget_component_offsets(&msg_loc, numsf, surfs, OM_Gw_current_OS,
				distance, num_spec_thick, val_spec_thick, 
				spec_thick_sf_sets, num_nooffsetsfs, 
				nooffsetsfs, off_surfs_info, &sfmdenv, 
				offset_inward, construct_list, comm_sf_indices,
				errkey_list, option, status_str);
   	EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);

        if(!num_edges)
        {
           list_size = 0;
           buff_size = num_edges;

           sts = om$send(msg = message EMScompsurf.EMgetedges(&msg_loc,
                            EMS_OPT_CONNECTABLE, NULL, &buff_size, &num_edges,
                            NULL, NULL, &list_size, NULL),
                      senderid = NULL_OBJID,
                      targetos = in_grid.osnum,
                      targetid = in_grid.objid);
           EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

           if(!num_edges)
           {
            /* Case of single closed component surface 
                    eg. torus/ellipsoid etc.*/
              *constructed_object = off_surfs_info[0].objid;
              goto ret_end;
           }
        }

	orig_surf.osnum = OM_Gw_current_OS;   /* os of the incoming composite */
	off_surf.osnum = sfmdenv.md_id.osnum; /* os of the output composite */

        max_adjsfs = -1 * OM_K_MAXINT;
	for ( i=0; i<numsf; i++ )
            if(off_surfs_info[i].num_adj_sfs > max_adjsfs)	
                max_adjsfs = off_surfs_info[i].num_adj_sfs;

        if(max_adjsfs > 0)
        {
           adjsfs_offdists = (IGRdouble *) om$malloc(size =
                                         max_adjsfs * sizeof(IGRdouble));
           EMerr_hndlr((!adjsfs_offdists), *msg,
                                      EMS_E_NoDynamicMemory, ret_end);
        }
        else
           adjsfs_offdists = NULL;

	for ( i=0; i<numsf; i++ )
	{
	    orig_surf.objid = surfs[i];
	    off_surf.objid = off_surfs_info[i].objid;

           /* Get the offset distances of the adjacent surfaces */
            num_adjsfs = off_surfs_info[i].num_adj_sfs;
            for(j=0; j<num_adjsfs; j++)
                 adjsfs_offdists[j] = 
                       off_surfs_info[off_surfs_info[i].adj_sfs[j]].distance;

	  /* Determine the extent of extension needed for Current_Surface */
	    EFget_sf_extensions(&msg_loc, orig_surf, off_surf,
				&sfmdenv, (off_surfs_info[i].distance > 0.0 ?
				off_surfs_info[i].distance : distance),
                                offset_inward,
                              (((num_spec_thick == 0) && (num_nooffsetsfs == 0))
                                 ? FALSE : TRUE),
                                num_adjsfs,
                                adjsfs_offdists,
                                ext_dist);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
 printf("The extension distances for surface id = %d are : %lg,%lg,%lg,%lg\n",
           orig_surf.objid, ext_dist[0], ext_dist[1], ext_dist[2], ext_dist[3]);
#endif


	  /* Extend Current_Surface along its parametric directions */
	    sts = om$send( msg = message EMSsubbs.EMextend_by_dist(&msg_loc, 
					&sfmdenv, ext_dist, ext_dist, 
					(EMS_opt_extendS_deextend_if_needed |
                                        EMS_opt_extendS_reparametrize_surface),
                                        &off_surfs_info[i].objid),
			senderid = NULL_OBJID,
			targetid = off_surf.objid,
			targetos = off_surf.osnum );
	    if(! (1 & sts & msg_loc))
              {
      sts = om$send( msg = message EMSsubbs.EMextend_by_dist_from_orig_surf(
                                  &msg_loc,
                                  &sfmdenv, ext_dist, ext_dist,
                                  (EMS_opt_extendS_deextend_if_needed |
                                   EMS_opt_extendS_reparametrize_surface),
                                   orig_surf.objid,
                                   &off_surfs_info[i].objid),
                        senderid = NULL_OBJID,
                        targetid = off_surf.objid,
                        targetos = off_surf.osnum );
               EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);
             }

	}

        if(adjsfs_offdists) om$dealloc (ptr = adjsfs_offdists);
        adjsfs_offdists = NULL;

/* 2ND STAGE PROCESSING. COMPUTING SURFACE-SURFACE INTERSECTIONS .... */
ex$message(msgnumb = EMS_S_ProcessingTwo);

/* Now intersect pairs of surfaces in 'off_sf_info[]'. Intersect only pairs
   that share an edge in the original pair ("surfs"). Thus  produce an 
   'EMSinters' list with uv and xyz representation of the intersection curves.
*/
	BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, tol);
	BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
	inters_options = EMS_SFINT_NOREFINE | EMS_SFINT_HANDLESTOP;
	world_options = EMSINT_OUTPUT_WORLD;
	param_options = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT |
			EMSINT_ORIENT_RIGHT;
	sfmdenv.md_env.matrix_type = *mattyp;
	OM_BLOCK_MOVE(mat, sfmdenv.md_env.matrix, sizeof(IGRmatrix));

/*      EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset); */


	/* Allocate the 'inters' list for the offset composite surface */
	Sf_Inters = EMinters_malloc (&msg_loc, numsf);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
        for(i=0, p_inters=Sf_Inters; i<numsf; i++, p_inters=p_inters->next)
        {
	    p_inters->this_obj.objid = off_surfs_info[i].objid;
	    p_inters->this_obj.osnum = off_surf.osnum;
	}

	/* Start constructing the inters list processing node at a time */
	for(i=0, p_inters=Sf_Inters; i<numsf; i++, p_inters=p_inters->next)
	{
	/* Initialize the per-surface static variables */
	  Current_Inters = p_inters;
	  Current_Surface = Current_Inters->this_obj.objid;
	  Avail_Intobjs_Ptr = Current_Inters->cvs;
	  Current_Inters->num_cvs = 0;
	  Prev_Loop_Last_Intobj = NULL;

#ifdef DEBUG
printf("Current_Surface = %d\n", Current_Surface);
printf("Original Surface = %d\n", surfs[i]);
#endif

	/* Get the parametric-tolerance of the current original surf */
	  orig_surf.objid = surfs[i];
	  off_surf.objid = off_surfs_info[i].objid;
  	  world = TRUE;
  	  sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                 mattyp, mat, &world, FALSE, &partolb.tol),
			 senderid = NULL_OBJID,
                         targetos = orig_surf.osnum,
                         targetid = orig_surf.objid);
	  EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_SurfaceError,ret_end);
	  partolb.in_world = TRUE;
	  partolb.is_valid = TRUE;
	  partolb.mattyp = mattyp;
	  partolb.mat = mat;

	/* Check if the current surface or any of its common edge surfaces has
	   seam deleted. If so set the flag "seam_affected" to TRUE.
	*/
	  seam_affected = (off_surfs_info[i].props & SEAM_DELETED ? 
						     TRUE : FALSE);
	  for(l=0; l<off_surfs_info[i].num_adj_sfs && !seam_affected; l++)
	  {
	     comm_sf_ind = off_surfs_info[i].adj_sfs[l];
	     if(off_surfs_info[comm_sf_ind].props & SEAM_DELETED) 
		seam_affected = TRUE;
	  }

	/* Get all the loops in Current_Surface */
          loop_ids = NULL;
          props = NULL;
          depth = OM_K_MAXINT;
          buff_size = 0;
          sts = om$send(msg = message EMSloopset.EMget_loops
                        (&msg_loc, 0, &depth, &loop_ids, &props, &buff_size,
                         &num_loops),
                        senderid = orig_surf.objid,
                        p_chanselect = &chan_to_loopset);
          EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopsetError,
                       ret_end);

	  /* For each loop in the original surface, generate intobjs
	     corresponding to its edges on the offset surface
	  */
          for(j=0; j<num_loops; j++)
	  {
#ifdef DEBUG
printf("  Current Loop no. = %d\n", j);
#endif
	    /* Get all the edges in this loop */
	    buff_size = num_edges = 0;
	    edges = NULL;
            sts = om$send(msg = message EMSloop.EMget_edges(&msg_loc, 1, 
				EMS_OPT_ALL, &edges, &buff_size, &num_edges),
			  senderid = NULL_OBJID,
			  targetos = orig_surf.osnum,
                          targetid = loop_ids[j]);
            EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopError,
                        ret_end);

	    /* Initilalize the per-loop static variables */
	    Current_Loop = loop_ids[j];
	    Loop_Start_Edge = edges[0].objid;
	    Loop_Start_Intobj = NULL;
            prev_common_surface = NULL_OBJID;

	    /* For every edge in Current_Loop generate the corresponding
	       intobj. This intobj will be then positioned 'in-place' in
	       Current_Inters.
	    */
	    for(k=0; k<num_edges; k++)
	    {
	       /* Initialize the per-edge static variables */
	       Current_Edge = edges[k].objid;
	       Common_Edge = NULL_OBJID;
#ifdef DEBUG
printf("    Current_Edge no. = %d\n", k);
#endif
               current_intobj = NULL;

	/* Call function to return all the edge info (props, common edge,
	   comm_edge surface, convex/concave/tangent/special-tangent/free etc
	*/
	       sts = EFget_edge_info(&msg_loc, mattyp, mat, edges[k], &comm_ed,
				     &comm_surf, &ed_props, &is_free, &convex,
				     &neutral, &is_spec_tangent, NULL, 
                                     &ang_meas, &cm_ed_props);
	       EMerr_hndlr(! (1 & sts & msg_loc), *msg,EMS_E_EdgeError,ret_end);

	       if(ed_props & EMED_DEGENERATE)
	       {
	       /* check if edge is a full natural edge. If not move on to
		  next edge. Else continue processing the degenarate natural
		  edge as usual.
	       */
	         EFchk_if_natural(&msg_loc, edges[k], ed_props, FALSE, &ed_nat,
				  &ed_loc);
		 if(!ed_nat) 
                      continue;
	       }

	       Common_Edge = comm_ed.objid;

	       if(is_free)     /* Current_Edge is a free edge */
	       {
	         EFchk_if_natural(&msg_loc, edges[k], ed_props, FALSE, &ed_nat,
				  &ed_loc);
		 if(!ed_nat)
		    EFchk_if_iso(&msg_loc, edges[k], ed_props, &ed_iso);
		 else
                    ed_iso = FALSE;
		 tmp_inters = NULL;
		 if(ed_nat)
		 {
		   current_intobj = EFmkint_from_nat_edge(&msg_loc,
				    ed_nat, FALSE, FALSE, ang_meas, 
                                    ed_props, NULL, ed_loc, NULL, 
                                    &edges[k], NULL, &orig_surf, NULL,
                                    &off_surf, NULL,
				    &sfmdenv.md_env, &tmp_inters);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

		   current_intobj->props |= EMSintobj_tmpmarked;
		 }
                /* Case where 'iso-ness' should be preserved */
                 else if(EFgenerate_an_iso_intobj(&msg_loc, is_free, 
                                           FALSE, ang_meas,
                                           ed_iso, FALSE,
                                           &edges[k], NULL, &orig_surf, 
                                           NULL, &sfmdenv.md_env,no_edges))
                 {
                  IGRboolean is_full;
                  /* 
                     If the num_edges at the right and left end are equal to
                     two then this intobj takes the iso edge which is  exactly
                     of the length of it's corresponding edge in the original
                     surface instead of taking the total iso_curve(u=0 to u=1)
                   */
                  if((no_edges[0] == 2)&&(no_edges[1] == 2))
                  is_full = FALSE;
                  else is_full = TRUE;
#ifdef DEBUG
printf("   Edge is FREE and ISO. Extracting Iso edge\n");
#endif
	        current_intobj = EFmkint_from_iso_edge(&msg_loc,is_full,ed_iso,
				    FALSE, FALSE, &edges[k], NULL, &orig_surf,
                                    &off_surf, NULL, NULL,
				    &sfmdenv.md_env, &tmp_inters);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
		   current_intobj->props |= EMSintobj_isocurve;
                 }
		 else 
		 {
		   EFcvt_edge_to_cv(&msg_loc, NULL, edges[k], &orig_surf, 
                                    &cv_geom, &sfmdenv.md_env);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

/* CRC - Write function to determine the extension required at either end using 
	 info of adjacent edges and surfaces (offset distances)
*/
/* CRC BLOCK START */
		   /* ext_dist[0] = (props[j] & EMLP_EXTERNAL ? 5 * distance :
							   5 * tol);*/
           EFget_intobj_extdist(edges[k].objid,orig_surf.osnum ,props[j],
                                distance,partolb.tol,tol,ext_dist);

/* CRC BLOCK END */
		   current_intobj = EFext_and_prj_cv(&msg_loc, orig_surf, 
						     off_surf, opt, NULL,
						     cv_geom,
						    ed_props & EMED_XYZ_CLOSED ?
						     FALSE : TRUE,
                                                     ext_dist[0],
                                                     ext_dist[1],
						     &sfmdenv.md_env, 
						     &tmp_inters, FALSE, NULL,
						     NULL);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
      		   om$dealloc(ptr = cv_geom->poles);
		   om$dealloc(ptr = cv_geom->knots);
		   if(cv_geom->rational) om$dealloc(ptr = cv_geom->weights);
		   om$dealloc(ptr = cv_geom);
		   cv_geom = NULL;
	  	 } /* else of if(ed_nat) */

                 if(ed_props & EMED_XYZ_CLOSED)
                    current_intobj->props |= EMSintobj_xyz_closed;
                 if(ed_props & EMED_DEGENERATE)
                    current_intobj->props |= EMSintobj_xyzdegenerate;
		 EFmerge_with_inters_list(Current_Inters, tmp_inters);
		 EMinters_free(tmp_inters, OM_K_MAXINT);
                 comm_surf.objid = NULL_OBJID;  /* Reset for Free edges */
	       }
	       else   /* Common edge exists */
	       {
                /* This functions checks for already processed surface pairs
                   to help deal with edges split due to seams  */

	          if(seam_affected && Current_Edge != Loop_Start_Edge)
		  {   
		      IGRboolean  add_to_start;
                      if(EFis_this_edge_redundant(&msg_loc,
                                                  prev_common_surface,
                                                  comm_surf.objid, i,
                                                  off_surfs_info,
                                                  k, edges, num_edges,
                                                  &add_to_start))
                      {
                          EFpost_edge_to_intobj_moreinfo(add_to_start, 
                                             		 comm_ed.objid, i,
                                                         off_surfs_info);
#ifdef DEBUG
printf("        Edge connected to prev edge at seam =%d\n", edges[k].objid);
#endif

		/* Current_Edge will not form part of final loop. Continue.
		   If the Current_Edge were tangential to the previously
		   processed edge the previous intobj (Fwd_Connect_Intobj)
		   would have its more_info pointing to the intersection point.
		   This is spurious. Hence deallocate it.
		*/
		          if(Fwd_Connect_Intobj->more_info)
		          {
		             p_pypt = (struct EMSpypoint *) 
				       Fwd_Connect_Intobj->more_info;
		             om$dealloc(ptr = p_pypt);
		             Fwd_Connect_Intobj->more_info = NULL;
		           }
                           continue;
                      }
		  }

		  /* Check if the intobj corresponding to the current edge is
		     available in the avail-list
		  */
		  EFscan_intobj_list(&p_intobj);
		  if(p_intobj)  /* intobj available in Avail_intobjs list */
		  {
#ifdef DEBUG
printf("   Matching intobj found during Scanning\n");
#endif
		    EFextract_intobj_from_list(p_intobj);
		    current_intobj = p_intobj;
		    if(!Loop_Start_Intobj)
           		EFinit_start_intobj(p_intobj);
		    else
	   		EFfwd_connect_intobj(p_intobj);
		  }
                  else if(ed_props & EMED_SEAM) /* current edge is a seam */
                  {
                  /* Check whether seam is deleted */
                    if(!(off_surfs_info[i].props & SEAM_DELETED))
                    {
		    /* Generate the two intobjs on the offset corresponding to
		       the seams
		    */
#ifdef DEBUG
printf("   Surface closed in u/v\n");
#endif
                        tmp_inters = NULL;
                        stat_func =  EFconvert_seam_to_intobjs
                                                 (&msg_loc, off_surf,
                                                 &sfmdenv.md_env,
                                                 &tmp_inters, p_intobjs);
                        EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, 
				     ret_end);

		        /* Determine which of the two seams (U/V = 0 or 1)
			   the Current_Edge corresponds to.
			*/
		        sts = om$send(msg = message EMSedge.EMget_location(
					    &msg_loc, &loc),
				      targetid = edges[k].objid,
				      targetos = edges[k].osnum,
				      senderid = NULL_OBJID);
                        EMerr_hndlr(EMSerror (sts & msg_loc), *msg, 
				    EMS_E_EdgeError, ret_end);

			if(loc == 0 || loc == 2) /* seam is U=0 OR U=1 */
			   this_seam_index = (loc==0 ? 0 : 1);
			else   /* seam is V=0 OR V=1 */
			   this_seam_index = (loc==1 ? 0 : 1);
			other_seam_index = (this_seam_index==0 ? 1 : 0);

                  /* Put the seam intobjs into appropriate lists.
                     Add one int-obj to the inters list and the other to
                     the Avail_Intobjs list.
		  */
                        if(this_seam_index == 1)
                        {
                            tmp_inters->cvs = p_intobjs[1];
                        }
                        p_intobjs[0]->next = NULL;
                        tmp_inters->num_cvs--;

                        EFmerge_with_inters_list(Current_Inters, tmp_inters);
                        EMinters_free(tmp_inters, OM_K_MAXINT);

		        current_intobj = p_intobjs[this_seam_index];
                        EFappend_intobj_to_Avail_list(
						p_intobjs[other_seam_index]);

                    } /* if seam was NOT deleted */
                    else
                    {
/* CRC
	 If the function is successful then the current loop has been merged
	 with the next. So the next loop need not be processed later. Increment
	 j. Also the number of edges in the current loop would have increased.
	 The function should return this. Set num_edges to this value and
	 continue.

	 ASSUMPTION - This has to be the j+1 st loop in loop_ids[] ??
	 Check this out....

	 Document the function.
*/
/* CRC BLOCK START */
                   /* Merge edges from common-seam-edge loop into the
                      current edge list in the proper order. Since we have 
		      merged the current loop with the next loop we need not
	 	      process the next loop later. Hence increment j 
		      (loop index).
		   */
		      GRobjid merged_loop;

                      EFmerge_loop_across_seam(&msg_loc, prev_common_surface, 
                                               i, off_surfs_info,
                                               k, &edges, &num_edges,
                                               &merged_loop);
		      EMerr_hndlr((merged_loop != loop_ids[j+1]), *msg,
				   EMS_E_Fail, ret_end); /* Here the assumption
                                                            is that the other
                                                            seam edge is in the
                                                            next loop. So, Error
                                                            Out if it is not.
                                                            TBD.*/
		      j++;
          /*
           * When the Seam_edge is responsible for the loops to be merged
           * cross it, the vertex connecting this Seam and the previos edge
           * (Fwd_Connect_Intobj) may not form the vertex on the resultent
           * offset_surface,So better we leave it for the intobjs to find
           * it's vertex in the EMregen_tpgy rather than sending the proj
           * vertex point here. -Jagan
           */

                      if (Fwd_Connect_Intobj && Fwd_Connect_Intobj->more_info)
                      {
                        om$dealloc (ptr = Fwd_Connect_Intobj->more_info);
                        Fwd_Connect_Intobj->more_info = NULL;
                      }
                      continue; /* to next edge in modified edges list */
/* CRC BLOCK END */
                    } /* end of else of if(NOT seam_deleted) */
                  }
		  else    /* Not a seam. intobj needs to be generated */
		  {
		  /* get the inters node corresponding to comm_surf's offset */
		     for(l=0; l<off_surfs_info[i].num_adj_sfs; l++)
		     {
		       comm_sf_ind = off_surfs_info[i].adj_sfs[l];
		       if(IF_EQ_OBJID(comm_surf.objid, surfs[comm_sf_ind]))
		       {
			 EFget_inters_node(comm_sf_ind, &other_inters);
			 break;
		       }
		     }
		     EMerr_hndlr(!(other_inters), *msg, EMS_E_Fail, ret_end);

	             if(neutral)	/* edge is tangent */
		     {
		        tmp_inters = NULL;

		        /* Check if either edge is a full natural edge */
			EFchk_if_natural(&msg_loc, edges[k], ed_props,
				       is_spec_tangent, &ed_nat, &ed_loc);
	                EFchk_if_natural(&msg_loc, comm_ed, cm_ed_props,
				       is_spec_tangent, &cm_ed_nat, &cm_ed_loc);

                        ed_iso = cm_ed_iso = FALSE;
			if(!ed_nat && !cm_ed_nat)
			{
			  EFchk_if_iso(&msg_loc, edges[k], ed_props, &ed_iso);
			  EFchk_if_iso(&msg_loc, comm_ed, cm_ed_props,
				       &cm_ed_iso);
			}
                        if((fabs(ang_meas - 2.0) <= EMS_ZEROANGLE_DEG)
                                  && (ed_nat || cm_ed_nat))
		 	{
			/* Edges are exactly tangential and atleast one of them
			   is a full natural edge. Hence extract corresponding
			   natural edge onthe offset surface.
			*/
		   	    p_intobjs[0] = EFmkint_from_nat_edge(&msg_loc,
					  ed_nat, cm_ed_nat,
                                          neutral, ang_meas,
                                          ed_props, cm_ed_props,
				  	  ed_loc, cm_ed_loc, 
					  &edges[k], &comm_ed,
                                          &orig_surf, &comm_surf,
                                          &off_surf,
				  	  &other_inters->this_obj,
					  &sfmdenv.md_env, &tmp_inters);
            	   	    EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail,
					ret_end);
		   	    p_intobjs[1] = p_intobjs[0]->other_intobj_node;
			    if(ed_nat)
			      p_intobjs[0]->props |= EMSintobj_tmpmarked;
			    if(cm_ed_nat)
			      p_intobjs[1]->props |= EMSintobj_tmpmarked;
		 	}
                        else if(EFgenerate_an_iso_intobj(&msg_loc, FALSE, 
                                           neutral, ang_meas,
                                           ed_iso, cm_ed_iso,
                                           &edges[k], &comm_ed, &orig_surf, 
                                          &comm_surf, &sfmdenv.md_env,no_edges))
                        {
			/* Edges are exactly tangential and atleast one of them
			   is an Iso  edge whose iso-ness can be preserved
                           in the offset. Hence extract corresponding
			   iso edge on the offset surface.
			*/
#ifdef DEBUG
printf("   Edge is TANGENT and ISO. Extracting Iso edge\n");
#endif
		   	    p_intobjs[0] = EFmkint_from_iso_edge(&msg_loc,
					  TRUE,ed_iso, cm_ed_iso,
					  (ed_props & EMED_REVERSE_CONNECT ?
						     TRUE : FALSE),
				  	  &edges[k], &comm_ed, &orig_surf, 
                                          &off_surf, &comm_surf, 
				  	  &other_inters->this_obj,
					  &sfmdenv.md_env, &tmp_inters);
            	   	    EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail,
					ret_end);
		   	    p_intobjs[1] = p_intobjs[0]->other_intobj_node;
			    if(ed_iso)
			      p_intobjs[0]->props |= EMSintobj_isocurve;
			    if(cm_ed_iso)
			      p_intobjs[1]->props |= EMSintobj_isocurve;
                            if(is_spec_tangent)
                            {
			      p_intobjs[0]->props |= EMSintobj_special_tangent;
			      p_intobjs[1]->props |= EMSintobj_special_tangent;
                            }
                        }
			else
			{
#ifdef DEBUG
printf("   Edge is TANGENT, Extending and projecting edge\n");
#endif
		           EFcvt_edge_to_cv(&msg_loc, NULL, edges[k], 
                                            &orig_surf, &cv_geom,
					    &sfmdenv.md_env);
      	                   EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,
				       ret_end);

/* CRC - Call function to determine extensions at either end */
/* CRC - BLOCK START */
		           p_intobjs[0] = EFext_and_prj_cv(&msg_loc, orig_surf, 
			     off_surf, opt, NULL, cv_geom,
			     ed_props & EMED_XYZ_CLOSED ? FALSE :TRUE,
			     5 * distance, 5 * distance, &sfmdenv.md_env,
			     &tmp_inters, FALSE, NULL, NULL);
      	                   EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,
				       ret_end);
	                   p_intobjs[1] = EFext_and_prj_cv(&msg_loc, comm_surf, 
			     other_inters->this_obj, opt, NULL, cv_geom,
			     ed_props & EMED_XYZ_CLOSED ? FALSE :TRUE,
			     5 * distance, 5 * distance, &sfmdenv.md_env, 
			     &tmp_inters, FALSE, NULL, NULL);
      	                   EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,
				       ret_end);
/* CRC - BLOCK END */
		           if(ed_props & EMED_REVERSE_CONNECT)
			      p_intobjs[1]->reversed = (p_intobjs[1]->reversed ?
						        FALSE : TRUE);
		           p_intobjs[0]->other_intobj_node = p_intobjs[1];
		           p_intobjs[1]->other_intobj_node = p_intobjs[0];
		           p_intobjs[0]->props |= (EMSintobj_unmatched_dat |
					           EMSintobj_tangent);
		           p_intobjs[1]->props |= (EMSintobj_unmatched_dat |
					           EMSintobj_tangent);
      		           om$dealloc(ptr = cv_geom->poles);
		           om$dealloc(ptr = cv_geom->knots);
		           if(cv_geom->rational)
				 om$dealloc(ptr = cv_geom->weights);
		           om$dealloc(ptr = cv_geom);
		           cv_geom = NULL;
			} /* else of if(ang_meas==2.0 && ed_nat || cm_ed_nat) */
		     } /* end if(neutral) */

		     else   /* need to intersect Current_Inters->this_obj and */
		     {      /* other_inters->this_obj to get required intobj  */
		       tmp_inters = NULL;
		       num_inters = 0;
	    	       sf2_data.datatype = EMSdata_object;
	    	       sf2_data.data.object = &other_inters->this_obj;
#ifdef DEBUG
printf("   Computing intobj through EMsfsfint: %ld %ld \n", off_surf.objid,
	   other_inters->this_obj.objid);
#endif
		       sts = om$send(msg = message EMSsurface.EMsfsfint(&msg_loc,
                            mattyp, mat, construct_list, &sf2_data, 
			    &sfmdenv.md_env, world_options, param_options, NULL,
                 	    &num_inters, &tmp_inters, &tmp_inters),
			    senderid = NULL_OBJID,
                     	    targetid = off_surf.objid, 
			    targetos = off_surf.osnum);
		       EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_Fail, 
				  ret_end);
#ifdef DEBUG
if(!num_inters) printf("csoffset:Error - No intersections returned by sfsfint\n");
#endif
		       EMerr_hndlr(!num_inters, *msg, EMS_E_Fail, ret_end);
		     } /* end else    need to intersect ......    */

   	             p_intobj = (struct EMSintobj *)tmp_inters->cvs;
		     matches = EFintobj_matches_edge(&msg_loc, p_intobj, 
		        Current_Edge, &orig_surf, &partolb, 
			(off_surfs_info[i].distance +
			 off_surfs_info[comm_sf_ind].distance)/2.0, tol, 
		        mattyp, mat, &p_match, NULL, &clos_info);
                     if(matches && (1 & msg_loc))
		     {
		       if(!convex && !neutral)   /* edge is concave */
		       {
		       	   p_match->reversed = 
				    (p_match->reversed ? FALSE : TRUE);
		       	   p_match->other_intobj_node->reversed =
		                    (p_match->other_intobj_node->reversed ? 
				     FALSE : TRUE);
		       }
		       if(clos_info != OPEN)
		       {
			 p_match->props |= EMSintobj_xyz_closed;
			 p_match->other_intobj_node->props |= 
			                  EMSintobj_xyz_closed;
		       }

		      /* Delete all intobjs except the "matching" intobj */
		       p_intobj = (struct EMSintobj *)tmp_inters->cvs;
		       while(p_intobj)
		       {
			  p_intobj_fwd = p_intobj->next;
			  if(p_intobj != p_match) 
			     EMdelintobj(&msg_loc, p_intobj);
			  p_intobj = p_intobj_fwd;
		       }
		       current_intobj = p_match;
		       EFmerge_with_inters_list(Current_Inters, tmp_inters);
		       EFmerge_with_inters_list(other_inters, tmp_inters->next);
		       EMinters_data_free(&msg_loc, tmp_inters, OM_K_MAXINT, 
					  NULL, NULL);
		       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,ret_end);
		       EMinters_free(tmp_inters, OM_K_MAXINT);
		     }
		     else  /* Edge match failed */
		     {
#ifdef DEBUG
  printf("csoffset:Error - Edge Match Failure\n");
#endif
		       EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);
		     } /* end else Edge match failed */
		  } /* end else     intobj needs to be generated */
	       } /* end else       Common edge exists */
               
/* Free the 'more-info' pointer, pointing to the edge-list linked list */
               EFfree_edgelist_more_info(current_intobj);

/* Check if the right-end vertex of Current_Edge to see if the Current_Edge
   and the next edge are tangential at this vertex. If so, then a check is made
   if there is any other edge incident at this vertex. If not, then this vertex
   is projected on to the intobj just generated on Current_Surface and its
   more_info is made to point to the projected point. This point will be used
   in splitting the intobj while regenerating topology on the surface. Ofcourse
   this check is not needed if the edge is closed in xyz or if it is a seam.
*/
               if(!(ed_props & EMED_XYZ_CLOSED) && !(ed_props & EMED_SEAM))
               {
	         if(EFproj_vert_to_intobj(&msg_loc, &edges[k], (k<num_edges-1 ?
					&edges[k+1] : &edges[0]), is_free,
					&orig_surf, current_intobj,partolb.tol, 
					lentol, &sfmdenv, &p_pypt))
		      current_intobj->more_info = (IGRchar *) p_pypt;
               }
               prev_common_surface = comm_surf.objid;

	    } /* for(k=0; k<num_edges; k++) */

/* All intobjs corresponding to edges of Current_Loop are now
   ready to be integrated with the Current_Inters Node
*/
	    EFarrange_loop_intobjs();
	    if(edges) om$dealloc(ptr = edges);
	    edges = NULL;
	  } /* for(j=0; j<num_loops; j++) */
	  if(loop_ids) om$dealloc(ptr = loop_ids);
	  if(props) om$dealloc(ptr = props);
	  loop_ids = NULL;
	  props = NULL;
	} /* for(i=0, p_inters=Sf_Inters; i<numsf; .... */

       /* Reset the "tmpmarked" bit for all the intobjs of all the surfaces */
	p_inters = Sf_Inters;
	for(i=0; p_inters; i++, p_inters=p_inters->next)
	{
          EFreset_tmpmark_on_surface_intobjs(p_inters);
        }

/* 3RD STAGE PROCESSING. COPYING TOPOLOGY .... */
ex$message(msgnumb = EMS_S_Processing);

	p_inters = Sf_Inters;
	for(i=0; p_inters; i++, p_inters=p_inters->next)
	{
	  orig_surf.objid = surfs[i];
#ifdef DEBUG
printf("Regenerating topology for Surface = %d\n", off_surfs_info[i].objid);
printf("No. of intobjs in this surface = %d\n", p_inters->num_cvs);
#endif
	  EMregen_tpgy(&msg_loc, &p_inters, orig_surf, construct_list, NULL);
      	  EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
	}
/* TBD: Deallocate the more-info field on each intobj node if it is NON-NULL
26/Mar/93 - Ashok
*/

/* 4TH STAGE PROCESSING. STITCHING SURFACES .... */
ex$message(msgnumb = EMS_S_ProcessingFour);

/* Now each node in the sf_inters list has topology mapped on to its
   corresponding surface ('this_obj' field). We are now ready to create
   a composite surface out of these surfaces.
*/
        cs_grid.osnum = construct_list->env_info->md_id.osnum;
	sts = om$construct(classid = OPP_EMSgencompsf_class_id,
			   p_objid = &cs_grid.objid,
			   osnum = construct_list->env_info->md_id.osnum);
	EMerr_hndlr(! (1 & sts ), *msg, EMS_E_Fail, ret_end);

	jj = OM_K_MAXINT;
        for(i=0; i<numsf; i++)
	   if(off_surfs_info[i].distance == 0.0 &&
	      option & EMS_opt_offsetS_remove_opensfs)
	   {
		sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
				    construct_list->env_info),
			     senderid = NULL_OBJID,
			     targetid = off_surfs_info[i].objid,
			     targetos = off_surf.osnum);
		EMerr_hndlr(!(1 & sts & msg_loc ), *msg, EMS_E_Fail, ret_end);
	   }
	   else
	   {
		sts = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
						   &cs_grid, &jj),
			 senderid = NULL_OBJID,
			 targetid = off_surfs_info[i].objid,
			 targetos = off_surf.osnum);
		EMerr_hndlr(!(1 & sts & msg_loc ), *msg, EMS_E_Fail, ret_end);
	   }

	*constructed_object = cs_grid.objid;
/*
 * End of routine
 */
ret_end:
#ifndef KEEP_SURFS_ON_ERR
        if(EMSerror(*msg))
          for(i=0; i<numsf; i++)
             sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
					 	    construct_list->env_info),
			   senderid = NULL_OBJID,
                           targetid = off_surfs_info[i].objid,
                           targetos = off_surf.osnum);
#else
      if(EMSerror(*msg))
      {
        GRobjid    bad_surface_set, *objects = NULL;
        enum GRdpmode dpmode;

        objects = (GRobjid *) om$malloc(size = numsf * sizeof(GRobjid));
        for(i=0; i<numsf; i++)  objects[i] = off_surfs_info[i].objid;

       /* Make a graphic group of all the offset surfaces and display them */
        sts = ems$build_graphic_group(
                         number_of_objects = numsf,
                                   objects = objects,
                                    construction_args = construct_list,
                                    constructed_object = &bad_surface_set,
                                                msg = &msg_loc);
        dpmode = GRbd;
        sts = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                            &construct_list->env_info->md_env.matrix_type,
                            construct_list->env_info->md_env.matrix,
                            &dpmode,
                            &construct_list->env_info->md_id),
                 senderid = NULL_OBJID,
                 targetid = bad_surface_set,
                 targetos = off_surf.osnum);

        if(objects) om$dealloc(ptr = objects);
      }

#endif
	if(cv_geom)
	{
	   if(cv_geom->poles) om$dealloc(ptr = cv_geom->poles);
	   if(cv_geom->knots) om$dealloc(ptr = cv_geom->knots);
	   if(cv_geom->rational) om$dealloc(ptr = cv_geom->weights);
	   om$dealloc(ptr = cv_geom);
	}
        if(adjsfs_offdists) om$dealloc (ptr = adjsfs_offdists);
	if(off_surfs_info) om$dealloc(ptr = off_surfs_info);
	if(comm_sf_indices) om$dealloc(ptr = comm_sf_indices);
	if(edges) om$dealloc(ptr = edges);
	if(loop_ids) om$dealloc(ptr = loop_ids);
	if(props) om$dealloc(ptr = props);
	if(inters_out)
	   *inters_out = Sf_Inters;
	else
	{
	   EMinters_data_free(&msg_loc, Sf_Inters, OM_K_MAXINT, NULL, NULL);
	   EMinters_free(Sf_Inters, OM_K_MAXINT);
	}
	if(num_comps) *num_comps = numsf;
	if(sf_comps)
	   *sf_comps = surfs;
	else
	   if(surfs) om$dealloc(ptr = surfs);
	return(sts);
}


/************************************************************************/
  static void EFinit_start_intobj(p_intobj)
  struct EMSintobj *p_intobj;
/************************************************************************/
{

  Loop_Start_Intobj = p_intobj;
  Fwd_Connect_Intobj = p_intobj;
  return;
}

/************************************************************************/
  static void EFfwd_connect_intobj(p_intobj)
  struct EMSintobj *p_intobj;
/************************************************************************/
{
  Fwd_Connect_Intobj->fwd = p_intobj;
  Fwd_Connect_Intobj = p_intobj;
  return;
}

/************************************************************************/
  static void EFscan_intobj_list(p_intobj)
  struct EMSintobj **p_intobj;
/************************************************************************/
{
  struct EMSintobj	*tmp_intobj;
/*  GRobjid		*obj_ptr; */
  struct edge_list      *obj_ptr;

  *p_intobj = NULL;
  tmp_intobj = Avail_Intobjs_Ptr;
  while(tmp_intobj)
  {
    obj_ptr = (struct edge_list *) tmp_intobj->more_info;
    while(obj_ptr)
    {
      if(Current_Edge == obj_ptr->edgeid) 
      {
       	*p_intobj = tmp_intobj;
	break;
      }
      obj_ptr = obj_ptr->next;
    }
    tmp_intobj = tmp_intobj->next;
  }
  return;
}

/************************************************************************/
  static void EFextract_intobj_from_list(p_intobj)
  struct EMSintobj *p_intobj;
/************************************************************************/
{
  struct EMSintobj	*tmp_intobj, *prev_intobj;

  tmp_intobj = Avail_Intobjs_Ptr;
  prev_intobj = NULL;
  while(tmp_intobj)
  {
    if(tmp_intobj == p_intobj)
    {
      if(!prev_intobj)
	Avail_Intobjs_Ptr = tmp_intobj->next;
      else
	prev_intobj->next = tmp_intobj->next;
    /*
      if(p_intobj->more_info) om$dealloc(ptr = p_intobj->more_info);
      p_intobj->more_info = NULL;
    */
      break;
    }
    prev_intobj = tmp_intobj;
    tmp_intobj = tmp_intobj->next;
  }
  return;
}

/************************************************************************/
  static void EFarrange_loop_intobjs()
/************************************************************************/
{
  struct EMSintobj	*tmp_intobj;

/*  Superfluous.... Hence commenting... can save memory this way
  while(Loop_Start_Edge != * ((GRobjid *)Loop_Start_Intobj->more_info))
  {
    tmp_intobj = Loop_Start_Intobj->fwd;
    Fwd_Connect_Intobj->fwd = Loop_Start_Intobj;
    Fwd_Connect_Intobj = Loop_Start_Intobj;
    Fwd_Connect_Intobj->fwd = NULL;
    Loop_Start_Intobj = tmp_intobj;
  }
*/
  if(Loop_Start_Intobj == NULL) return;
  tmp_intobj = Loop_Start_Intobj;
  (Current_Inters->num_cvs)++;
  while(tmp_intobj->fwd)
  {
    tmp_intobj->next = tmp_intobj->fwd;
    tmp_intobj->fwd->bwd = tmp_intobj;
    tmp_intobj = tmp_intobj->fwd;
    (Current_Inters->num_cvs)++;
  }
  tmp_intobj->next = NULL;
  tmp_intobj->fwd = (tmp_intobj == Loop_Start_Intobj ? NULL : 
						       Loop_Start_Intobj);
  Loop_Start_Intobj->bwd = (tmp_intobj == Loop_Start_Intobj ? NULL :
							      tmp_intobj);
  if(Prev_Loop_Last_Intobj)
     Prev_Loop_Last_Intobj->next = Loop_Start_Intobj;
  else
     Current_Inters->cvs = Loop_Start_Intobj;
  Prev_Loop_Last_Intobj = tmp_intobj;
  EFset_stopstart_property(tmp_intobj);
  return;
}

/************************************************************************/
  static void EFfree_edgelist_more_info(tmp_intobj)
  struct EMSintobj *tmp_intobj;
/************************************************************************/
{
 /* Free the more_info pointer of the current intobj */

  struct edge_list *e_list, *p_list;

  if(tmp_intobj->more_info)
   {
     e_list = (struct edge_list *) tmp_intobj->more_info;
     while(e_list)
     {
       p_list = e_list->next;
       om$dealloc(ptr = e_list);
       e_list = p_list;
     }
   }
  tmp_intobj->more_info = NULL;

  return;
}

/************************************************************************/
  static void EFreset_tmpmark_on_surface_intobjs(p_inters)
  struct EMSinters *p_inters;
/************************************************************************/
{
  struct EMSintobj *p_intobj;

 /* Reset the ""tmpmarked" bit for all the connected intobjs */
  p_intobj = p_inters->cvs;
  while(p_intobj)
  {
    if(p_intobj->props & EMSintobj_tmpmarked)
        /* Reset the "tmpmarked" bit */
        p_intobj->props &= (~EMSintobj_tmpmarked);
    p_intobj = p_intobj->next;
  }
}
 

/************************************************************************/
  static void EFset_stopstart_property(tmp_intobj)
  struct EMSintobj *tmp_intobj;
/************************************************************************/
{

 /* Code for setting 'exact_atstart/stop' property */ 

  if(tmp_intobj->fwd)
  {
    do
    {
      tmp_intobj = tmp_intobj->fwd;

     /* Set stop-start property if seam-intobj */
      if(tmp_intobj->props & EMSintobj_seam) 
      {
       if(!EFis_along_seam(&tmp_intobj->this_uvintobj,
		           &tmp_intobj->bwd->this_uvintobj))
       {
         if(!(tmp_intobj->bwd->props & EMSintobj_special_tangent))
                 tmp_intobj->bwd->props |= EMSintobj_exact_atstop;
         EFset_other_stopstart_property(tmp_intobj->bwd, 
                                          EMSintobj_special_tangent,
                                               EMSintobj_exact_atstop); 
       }
       if(!EFis_along_seam(&tmp_intobj->this_uvintobj,
		           &tmp_intobj->fwd->this_uvintobj))
       {
         if(!(tmp_intobj->fwd->props & EMSintobj_special_tangent))
                    tmp_intobj->fwd->props |= EMSintobj_exact_atstart;
         EFset_other_stopstart_property(tmp_intobj->fwd,
                                          EMSintobj_special_tangent,
                                               EMSintobj_exact_atstart);
       }
      }

     /* Set stop-start property for vertices where two full natural, tangent
	(or free) edges meet.
     */
      if(tmp_intobj->props & EMSintobj_tmpmarked)  /* means full natural bdry
						      that is free or tangent */
      {
	if(tmp_intobj->props & EMSintobj_xyzdegenerate)
	{
	/* Trivial case where we set "exact" stop and start properties */
	   tmp_intobj->props |=
			     (EMSintobj_exact_atstart | EMSintobj_exact_atstop);
	}

	if(tmp_intobj->bwd->props & EMSintobj_tmpmarked)
	{
           if(!(tmp_intobj->props & EMSintobj_special_tangent))
	           tmp_intobj->props |= EMSintobj_exact_atstart;
       	   EFset_other_stopstart_property(tmp_intobj,
                                      EMSintobj_special_tangent |
                                      EMSintobj_tmpmarked | EMSintobj_isocurve,
				      EMSintobj_exact_atstart); 
           if(!(tmp_intobj->bwd->props & EMSintobj_special_tangent))
	           tmp_intobj->bwd->props |= EMSintobj_exact_atstop;
       	   EFset_other_stopstart_property(tmp_intobj->bwd,
                                      EMSintobj_special_tangent |
                                      EMSintobj_tmpmarked | EMSintobj_isocurve,
			              EMSintobj_exact_atstop); 
	}
	if(tmp_intobj->fwd->props & EMSintobj_tmpmarked)
	{
           if(!(tmp_intobj->props & EMSintobj_special_tangent))
	          tmp_intobj->props |= EMSintobj_exact_atstop;
       	   EFset_other_stopstart_property(tmp_intobj,
                                      EMSintobj_special_tangent |
                                      EMSintobj_tmpmarked | EMSintobj_isocurve,
				      EMSintobj_exact_atstop); 
           if(!(tmp_intobj->fwd->props & EMSintobj_special_tangent))
	          tmp_intobj->fwd->props |= EMSintobj_exact_atstart;
       	   EFset_other_stopstart_property(tmp_intobj->fwd,
                                      EMSintobj_special_tangent |
                                      EMSintobj_tmpmarked | EMSintobj_isocurve,
			              EMSintobj_exact_atstart); 
	}
        /* The "tmpmarked" bit is retained to enable handling of the 
           case where two full natural edges are being extracted 
           seperately. Because of unequal extension of the corresponding
           surfaces, the two extracted natural edges may not be of equal
           length and hence the properties of 'exact_atstop' and 'atstart'
           should not be set on the 'other_intobj' if it also is 
           "tmpmarked'.  This check is done in 'EFset_other_stopstart_prop.."
           function. */
        /********************
	** Reset the "tmpmarked" bit **
	tmp_intobj->props &= (~EMSintobj_tmpmarked);
        *********************/
      }
    } while(tmp_intobj->next);
  }
  else
  {
   /* Set stop-start property for single-intobj */
    tmp_intobj->props |= EMSintobj_exact_atstop;
    tmp_intobj->props |= EMSintobj_exact_atstart;
    if(tmp_intobj->other_intobj_node)
    {
      tmp_intobj->other_intobj_node->props |= EMSintobj_exact_atstop;
      tmp_intobj->other_intobj_node->props |= EMSintobj_exact_atstart;
    }
  }
   
  return;
}

/************************************************************************/
  static void EFset_other_stopstart_property(tmp_intobj, filter_out_props,
                                                             set_prop)
  struct EMSintobj *tmp_intobj;
  IGRulong filter_out_props, set_prop;
/************************************************************************/
/*
  Set the appropriate stop/start property for the other_intobj based 
  on whetherthe corresponding edges are 'reverse connected' 
*/
{
  struct EMSintobj *p_intobj; 
  
  IGRlong  msg_loc, sts;
 
  IGRboolean EFare_intobjs_reverse_connected();

  sts = OM_S_SUCCESS;

  p_intobj = tmp_intobj->other_intobj_node;

  /* Set properties for intobjs other than those obtained by independently 
     extracting from corresponding 'full-natural' edges */
  if(p_intobj && !(p_intobj->props & filter_out_props))
  {
    if(EFare_intobjs_reverse_connected(&msg_loc, tmp_intobj))
    {
      if(set_prop & EMSintobj_exact_atstart)
          p_intobj->props |= EMSintobj_exact_atstop;
      else
          p_intobj->props |= EMSintobj_exact_atstart;
    }
    else
    {
      p_intobj->props |= set_prop;
    }
  }

  return;

}

/************************************************************************/
  static void EFappend_intobj_to_list(p_intobj, p_inters)
  struct EMSintobj *p_intobj;
  struct EMSinters *p_inters;
/************************************************************************/
{
/*  GRobjid *obj_ptr=NULL; */
  struct edge_list  *obj_ptr=NULL;

  p_intobj->next = p_inters->cvs;
  p_intobj->this_obj_node = p_inters;
  p_inters->cvs  = p_intobj;

/*  obj_ptr = (GRobjid *)om$malloc(size = sizeof(GRobjid)); 
  *obj_ptr = Common_Edge; */

  obj_ptr = (struct edge_list *)om$malloc(size = sizeof(struct edge_list)); 
  obj_ptr->edgeid = Common_Edge; 
  obj_ptr->next   = NULL;
  
  p_intobj->more_info = (IGRchar *)obj_ptr;
  (p_inters->num_cvs)++;
  return;
}

/************************************************************************/
  static void EFappend_intobj_to_Avail_list(p_intobj)
  struct EMSintobj *p_intobj;
/************************************************************************/
{
/*  GRobjid *obj_ptr=NULL; */
  struct edge_list  *obj_ptr=NULL;

  p_intobj->next = Avail_Intobjs_Ptr;
  Avail_Intobjs_Ptr = p_intobj;
  p_intobj->this_obj_node = Current_Inters;

/*  obj_ptr = (GRobjid *)om$malloc(size = sizeof(GRobjid));
  *obj_ptr = Common_Edge; */

  obj_ptr = (struct edge_list *)om$malloc(size = sizeof(struct edge_list)); 
  obj_ptr->edgeid = Common_Edge; 
  obj_ptr->next   = NULL;

  p_intobj->more_info = (IGRchar *)obj_ptr;
  return;
}

/************************************************************************/
  static void EFmerge_with_inters_list(dest_inters, p_inters)
  struct EMSinters *dest_inters, *p_inters;
/************************************************************************/
{
  struct EMSintobj	*tmp_intobj;

    tmp_intobj = p_inters->cvs;

    if(dest_inters == Current_Inters)
    {
    	tmp_intobj->this_obj_node = Current_Inters;
	if(!Loop_Start_Intobj)
           EFinit_start_intobj(tmp_intobj);
	else
	   EFfwd_connect_intobj(tmp_intobj);
    }
    else
    {
    	tmp_intobj->this_obj_node = dest_inters;
	EFappend_intobj_to_list(tmp_intobj, dest_inters);
    }
    p_inters->num_cvs = 0;
    p_inters->cvs = NULL;

/* TBD
   Deallocate p_inters OR should this be done by Caller
*/
  return;
}

/************************************************************************/
  static void EFget_inters_node(index, inters)
  IGRint  index;
  struct EMSinters **inters;
/************************************************************************/
{
  struct EMSinters	*tmp_inters;
  IGRint		loc_index=0;
  *inters = NULL;
  tmp_inters = Sf_Inters;
  while(tmp_inters)
  {
    if(loc_index == index)
    {
	*inters = tmp_inters;
	break;
    }
    tmp_inters = tmp_inters->next;
    loc_index++;
  }
  return;
}


/************************************************************************/
  static void EFmerge_loop_across_seam(msg, prev_comm_sf,
                                          surf_index, off_surfs_info, 
                                          edge_index, loop_edges, num_edges,
                                          merged_loop_id)
  IGRlong                *msg;
  OM_S_OBJID             prev_comm_sf;
  IGRint                 surf_index;
  struct EMSoff_sf_info  *off_surfs_info;
  IGRint                 edge_index;
  struct GRid            **loop_edges;
  IGRlong                *num_edges;
  OM_S_OBJID             *merged_loop_id;
/************************************************************************/
/*
  This function merges the 'edges' in the other-loop-across-the-seam into
  the current 'loop_edges' list after the current edge.  
  o It is assumed that the current edge in the current 'loop_edges' list
    is the seam-edge.
  o The seam-edge and subsequent edges in the other-loop-across-seam which
    have the same common-surface with the previous edge in the current
    'loop_edges' list are not added to the list of edges.
  o The merged edges are inserted after the current edge in the 
    'loop_edges' list.
  o At return time:
        i) 'num_edges' is incremented by the number of edges
           added in this routine.
       ii) 'loop_edges' contains the edges list with the inserted
           edges (memory reallocation done if necessary).
      iii) 'merged_loop_id' contains the objid of the loop which has
           been merged with the current loop.
 */
{
  IGRlong msg_loc, sts;
  struct GRid comm_ed, *c_edges, comm_sf, c_comm_ed, *edges;
  IGRint i, m;
  IGRboolean same_comm_sf;
  IGRint seam_index, start, list_index;
  IGRint buff_size, num_c_edges; 
  IGRlong     num_total_edges, num_deleted;
  OM_S_CHANSELECT	chan_to_cm_ed, chan_to_loop;
  OMuint  count;
 
  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  c_edges = NULL;
  edges = *loop_edges;
  *merged_loop_id = NULL_OBJID;
  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_cm_ed);
  EMmake_chanselect (EMSedge_to_owner, &chan_to_loop);

#ifdef DEBUG
printf("     --Merging Loops across seam\n");  
#endif

  /* Find the common-seam-edge */
  sts = om$send(msg = message EMSboundary.EMget_objid(&msg_loc,
                                                         &comm_ed.objid),
                senderid = edges[edge_index].objid,
                targetos = edges[edge_index].osnum,
                p_chanselect = &chan_to_cm_ed);
  EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError,
                             ret_end);

  /* Get the loop objid of the common-edge loop. This loop is
     to be merged with the current loop. This is used in the
     main function.
  */
  sts = om$send(msg = message EMSboundary.EMget_objid(&msg_loc,
                                                         merged_loop_id),
                senderid = comm_ed.objid,
                targetos = edges[edge_index].osnum,
                p_chanselect = &chan_to_loop);
  EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError,
                             ret_end);

  /* Get the edges in the to-be-merged-loop.
     'num_c_edges' - stores the number of edges in this loop.
     'c_edges'     - contains the array of edge objids in this loop. 
  */ 
  buff_size = num_c_edges = 0;
  c_edges = NULL;
  sts = om$send(msg = message EMSloop.EMget_edges(&msg_loc, 1,
                         EMS_OPT_ALL, &c_edges, &buff_size, &num_c_edges),
                senderid = NULL_OBJID, 
                targetid = *merged_loop_id);
  EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopError, ret_end);

#ifdef DEBUG 
printf("     --There are %d edges in the other loop\n", num_c_edges);
#endif

  /* Locate the common-seam-edge in the list of edges */
 
  seam_index = 0; 		/* intialize to obviate compiler warning */
  for(i=0; i<num_c_edges; i++)
  {
     if(c_edges[i].objid == comm_ed.objid)
     {
          seam_index = i;
          break;
     }
  } /* end of for(i=0;...) */

  same_comm_sf = TRUE;
  start = seam_index;
  num_deleted = 0;
  while(same_comm_sf)
  {
    start++;
    if(start >= num_c_edges)
       start -= num_c_edges;

   /* Get the common edge and common-edge-surface if it exists */
    count = 0;
    sts = om$get_channel_count(objid = c_edges[start].objid,
                        osnum = c_edges[start].osnum,
                        p_chanselect = &chan_to_cm_ed, count = &count);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_OMerror, ret_end);
    if(count) /* common edge exists */
    {
       c_comm_ed.osnum = c_edges[start].osnum;
       sts = om$send(msg = message EMSboundary.EMget_objid(&msg_loc,
                                                          &c_comm_ed.objid),
                                senderid = c_edges[start].objid,
                                targetos = c_edges[start].osnum,
                                p_chanselect = &chan_to_cm_ed);
       EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError, ret_end);
 
       sts = om$send(msg = message EMSboundary.EMgetsurface_info(&msg_loc,
                                            &comm_sf.objid, NULL),
                                senderid = NULL_OBJID,
                                targetid = c_comm_ed.objid,
                                targetos = c_edges[start].osnum);
       EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError, ret_end);
 
       if(comm_sf.objid == prev_comm_sf)
       {
          EFpost_edge_to_intobj_moreinfo(FALSE, c_comm_ed.objid,
                                         surf_index, off_surfs_info); 
          num_deleted++;
       }
       else
          same_comm_sf = FALSE;
    } /*  if(count)... */
    else   /* it is a free edge */
       same_comm_sf = FALSE;
      
  } /* end of while(same_comm_sf)  */
 
 
 /* Reallocate space for the edges list if the new loop contributes
    any new edges  */

  if((num_c_edges - (num_deleted + 1)) > 0 )
  {
    num_total_edges = *num_edges + num_c_edges - (num_deleted + 1);
 
    edges = (struct GRid *) om$realloc (ptr = (char *)edges,
                           size = num_total_edges * sizeof(struct GRid));  
    EMerr_hndlr(!(edges),*msg, EMS_E_DynamicMemoryAllocated, ret_end);
 
  /* Position already-existing-edges at end-of-list */
 
    for(i=(*num_edges)-1, m=num_total_edges-1; i>edge_index; i--,m-- )
    {
      edges[m].objid = edges[i].objid;
      edges[m].osnum = edges[i].osnum;
    }
   
    start = seam_index + num_deleted + 1; /* This is the index into the
                                             edges of the loop-to-be-merged
                                             from which the edge ids are to be
                                             copied into the reallocated edge
                                             objid array. */
 
  /* Copy the edge ids into the edges list */
    list_index = edge_index;
    if(start < num_c_edges)
    {
      for(i=start; i<num_c_edges; i++)
      {
        list_index++;
        edges[list_index].objid = c_edges[i].objid;
        edges[list_index].osnum = edges[edge_index].osnum;
      }
      for(i=0; i<seam_index; i++)
      {
        list_index++;
        edges[list_index].objid = c_edges[i].objid;
        edges[list_index].osnum = edges[edge_index].osnum;
      }
    }
    else
    {
      if(start >= num_c_edges)
          start = start - num_c_edges;  
 
      for(i=start; i<seam_index; i++)
      {
        list_index++;
        edges[list_index].objid = c_edges[i].objid;
        edges[list_index].osnum = edges[edge_index].osnum;
      }
    }
 
  /* Assign the new number of edges in loop to num_edges */
    *num_edges = num_total_edges;
    *loop_edges = edges;
  } /* end of if((num_c_edges.....)   */
 
ret_end:

#ifdef DEBUG
printf("      --No. of new edges added = %d\n", list_index-edge_index);
printf("      --Modified num_total_edges = %d\n", num_total_edges);
printf("      ---Merged loop id = %d\n", *merged_loop_id);
#endif
    
    if(c_edges) om$dealloc(ptr = c_edges);
 
  return;
 
}

/************************************************************************/
/*
  NAME:
     static IGRboolean EFis_this_edge_redundant().

  ABSTRACT:

     This function tests whether the current edge is connected to  
  either the previous-edge or the first-edge at-a-seam in the original
  solid/surface topology. If so, the edge is considered redundant as far
  as generating topology on the offset solid/surface and the function 
  returns TRUE in either case. It returns FALSE otherwise.

  DESCRIPTION/ALGORITHM:

     In the Composite Offset algorithm, for any surface whose natural
  definition is a closed one (eg. a cylinder or cone), if the uv-range
  of the loopset does not span the range (0.0-1.0) in the direction
  of closure, an equivalent partial surface which 'fits' the loopset
  range is created and used in the Offset process. Since partial surfaces
  do not have seams, as against the original closed surfaces which have,
  edges which touch at seams in the original closed surfaces will give
  rise to a single edge (intobj) in the partial definition. Hence the 
  first of these edges which is encountered is used to generate the 
  'intobj' and the others donot generate an 'intobj'.

     This function tests whether an 'intobj' has already been generated
  for this edge, because it is connected at a seam to an edge for which
  the 'intobj' has already been generated. The other edge to which it
  is connected may be either the previous-edge or the first-edge in the
  loop. If so, it returns TRUE, other FALSE.


     The current edge is said to be connected to another edge at-a-seam
  if
     a)both the current edge and the other edge have the same 
       common-edge surface, and
     b)either the current surface or the common-edge-surface has
       its SEAM_DELETED property set.

     The SEAM_DELETED property of the Offset surface indicates whether
  a closed surface in the original has been replaced by a partial one
  in the offset solid/surface. 

  RETURN VALUES:

     The function returns TRUE if an 'intobj' need not be generated for
   the current edge. Otherwise it returns FALSE.

     The value returned  by the 'add_to_start_intobj' arg indicates 
   whether it is the previous-edge (add_to_start_intobj = FALSE)
   or the first-edge (add_to_start_intobj = TRUE). This flag is used
   to post the informaton about the current edge into the 'more_info'
   field of the appropriate (previous or first) edge 'intobj' later in
   the code in the main.

 */
/************************************************************************/
  static IGRboolean EFis_this_edge_redundant(msg,
                                         prev_comm_surf, curr_comm_surf,
                                         surf_index, off_surfs_info,
                                         edge_index, edges, num_edges,
                                         add_to_start_intobj)
  IGRlong                 *msg;
  GRobjid                 prev_comm_surf;
  GRobjid                 curr_comm_surf;
  IGRint                  surf_index;
  struct  EMSoff_sf_info  *off_surfs_info;
  IGRint                  edge_index;
  struct  GRid            *edges;
  IGRlong                 num_edges;
  IGRboolean              *add_to_start_intobj;
{

  IGRint search_index, j, num_iters;
  IGRboolean conn_at_seam, same_intobj; 
  IGRlong  sts, msg_loc;
  IGRushort     edn_props;
  struct  GRid      next_comm_ed, next_comm_sf;
  OM_S_CHANSELECT	chan_to_cm_ed;

  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_cm_ed);

  /* The 'connected' flag indicates whether the current edge is connected
     at the end of a seam, to an already processed edge. Initialized to
     FALSE  
  */
  conn_at_seam = FALSE;

  /* 'add_to_start_intobj' indicates whether the connection-at-the-seam 
     is with the previous edge (FALSE) or with the first edge (TRUE) 
  */
  *add_to_start_intobj = FALSE;

  if(edge_index > 0)     /* Just to ensure that the current edge is not
                            the first edge. */
  {

  /* Check for same common-surface with previous edge */

     conn_at_seam = EFcheck_same_common_sfs(prev_comm_surf, curr_comm_surf,
                                             surf_index, off_surfs_info);

#ifdef DEBUG
if(conn_at_seam)
  printf("    Connected-at-seam to previous edge\n");
#endif


  /* If not connected with previous edge then check for 
      same-common-surface with all edges till the end of the edge-list
      and edge[0] (If edge[0] is a seam-edge then check with edge[1]).
      If all have the same common surface as the current edge 
         then the current-edge is redundant due to edge[0].
  */
     if(!conn_at_seam)
     {
       search_index = edge_index; 
       same_intobj = TRUE;
       num_iters = num_edges - edge_index; /* since it includes the first edge
                                              also */
       for(j=0; j<num_iters; j++)
       {
          search_index++;
          if(search_index > num_edges-1)
              search_index -= num_edges;

       /* Get the properties of the edge and check if its is a seam */
          sts = om$send(msg = message EMSedge.EMget_props
                                       (&msg_loc, &edn_props),
                        senderid = NULL_OBJID,
                        targetos = edges[search_index].osnum,
                        targetid = edges[search_index].objid);
          EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_EdgeError,ret_end);

       /* If the current edge is a 'seam-edge', goto next edge */
          if(edn_props & EMED_SEAM)
          {
            search_index++;
            if(search_index > num_edges-1)
                search_index -= num_edges;
          }

       /* Get the common edge and surface of the next-edge */
          next_comm_ed.osnum = edges[search_index].osnum;
          sts = om$send(msg = message EMSboundary.EMget_objid(&msg_loc,
                                                         &next_comm_ed.objid),
                               senderid = edges[search_index].objid,
                               targetos = edges[search_index].osnum,
                               p_chanselect = &chan_to_cm_ed);
          EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError, ret_end);

          sts = om$send(msg = message EMSboundary.EMgetsurface_info(&msg_loc,
                                                  &next_comm_sf.objid, NULL),
                               senderid = NULL_OBJID,
                               targetid = next_comm_ed.objid,
                               targetos = next_comm_ed.osnum);
          EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_EdgeError, ret_end);

       /* Check whether the next edge has the same common surface */
          same_intobj &= EFcheck_same_common_sfs(next_comm_sf.objid, 
                                                 curr_comm_surf,
                                                 surf_index, 
                                                 off_surfs_info);
          if(!same_intobj)
              break;
        } /* end of for(j=0.....) */
        
        *add_to_start_intobj = TRUE;

       /* 'same_intobj' indicates whether the current-edge will generate
          the same 'intobj' as the first-edge 
       */
        conn_at_seam = same_intobj;

#ifdef DEBUG
if(conn_at_seam)
  printf("       Connected-at-seam to first edge\n");
#endif

     } /* end of if(!conn_at_seam).. */
  } /* end of if(edge_index>0).. */

ret_end:
  return(conn_at_seam);
}

/************************************************************************/
  static IGRboolean EFcheck_same_common_sfs(prev_comm_surf, curr_comm_surf,
                                            surf_index, off_surfs_info)
  GRobjid   prev_comm_surf;
  GRobjid   curr_comm_surf;
  IGRint       surf_index;
  struct  EMSoff_sf_info  *off_surfs_info;
/************************************************************************/
{
 /* Check for same common-surface
      then check for either surface being a seam-deleted one
           If so then 'connected = TRUE.  */

  IGRint l, adj_sf_index;
  IGRboolean connected = FALSE;

  if(prev_comm_surf == curr_comm_surf)
  {
       for(l=0; l<off_surfs_info[surf_index].num_adj_sfs; l++)
       {
             adj_sf_index = off_surfs_info[surf_index].adj_sfs[l];
             if((off_surfs_info[surf_index].props & SEAM_DELETED) ||
                (off_surfs_info[adj_sf_index].props & SEAM_DELETED))
             {
                   connected = TRUE;
                   break;
             } /* end of if((off_surfs.....) */
       } /* end of for(l=0....) */
   } /* end of if(prev_.....) */

   return(connected);
}
/************************************************************************/
  static void EFpost_edge_to_intobj_moreinfo(post_to_start, common_edgeid,
                                             surf_index, off_surfs_info)
  IGRboolean    post_to_start;
  GRobjid       common_edgeid;
  IGRint        surf_index;
  struct EMSoff_sf_info  *off_surfs_info;
/************************************************************************/
{
 /* 
   This function posts the information about the common_edgeid into 
   the 'more_info' of the 'other_intobj_node' of the appropriate
   'intobj' if the 'surface' associated with the 'other_intobj_node'
   is not already processed.

    post_to_start = FALSE implies add to previous intobj created.
    post_to_start = TRUE  implies add to first intobj created.
    Add edge-info only if the other surface has not already been 
     processed.
 */

  if(post_to_start)
  {
    if(Loop_Start_Intobj->other_intobj_node)
    if(!EFalready_processed_other_surface(
           Loop_Start_Intobj->other_intobj_node->this_obj_node->this_obj.objid,
                                                          surf_index,
                                                          off_surfs_info))
        EFadd_edge_to_intobj_moreinfo(Loop_Start_Intobj->other_intobj_node,
                                                          common_edgeid);
  }
  else
  {
    if(Fwd_Connect_Intobj->other_intobj_node)
    if(!EFalready_processed_other_surface(
          Fwd_Connect_Intobj->other_intobj_node->this_obj_node->this_obj.objid,
                                                           surf_index,
                                                           off_surfs_info))
        EFadd_edge_to_intobj_moreinfo(Fwd_Connect_Intobj->other_intobj_node,
                                                          common_edgeid);
  }
  
  return;
}

/************************************************************************/
  static IGRboolean EFalready_processed_other_surface(other_surf_id,
                                                      surf_index,
                                                      off_surfs_info)
  GRobjid                other_surf_id;
  IGRint                 surf_index;
  struct EMSoff_sf_info  *off_surfs_info;
/************************************************************************/
{
  /* Check whether the surface id corresponding to the 'other_surf_id'
     occurs in the 'Sf_Inters' list above the 'Current_Inters'.
     This is done by comparing the indices of the two surfaces.
     If the other surface index  is less than the current surface 
     index (surf_index) then 'processed' flag is set to TRUE
  */

  IGRint     ii;
  IGRboolean processed = FALSE;

  for(ii=0; ii<off_surfs_info[surf_index].num_adj_sfs; ii++)
  {
   if(off_surfs_info[off_surfs_info[surf_index].adj_sfs[ii]].objid ==
       other_surf_id)
     if(off_surfs_info[surf_index].adj_sfs[ii] <= surf_index)
     {
            processed = TRUE;
            break;
     }
  } /* end of for(ii=....) */

  return(processed);

}
    
/************************************************************************/
  static void EFadd_edge_to_intobj_moreinfo(p_intobj, edgeobjid)
  struct EMSintobj  *p_intobj;
  GRobjid           edgeobjid;
/************************************************************************/
{
  struct edge_list *obj_ptr, *ptr;

  ptr = (struct edge_list *) p_intobj->more_info;

  obj_ptr = (struct edge_list *)om$malloc(size = sizeof(struct edge_list));
  obj_ptr->edgeid = edgeobjid;
  obj_ptr->next   = ptr;
  
  p_intobj->more_info = (IGRchar *) obj_ptr;
 
  return;
}

/************************************************************************
NAME:
 EFmkint_from_iso_edge

DESCRIPTION:
 This function is used for generating the intersection objects from an
 iso edge and its common edge if there is one. The assumption is that
 the edge is either a stitchable (free) edge or a tangent edge. If tangent,
 either or both could be iso.
*************************************************************************/
static struct EMSintobj *EFmkint_from_iso_edge(msg,is_full,ed_is_iso, 
                                        cm_ed_is_iso,rev_conn, edge, cm_edge,
                                        surf,off_surf, cm_surf, cm_off_surf,
					mdenv_info, p_inters)

IGRlong			*msg;
IGRboolean		ed_is_iso, cm_ed_is_iso, /* indicate "naturalness"   */
			rev_conn,  		 /* indicates edge and its 
						    common edge are
				      		    reverse connected        */
                        is_full;                 /*indicates weather full
                                                   (u=0 to u=1) edge 
                                                   required or the the edge with
                                                    same length is required  */
struct GRid		*edge, *cm_edge, *surf, *cm_surf,
                        *off_surf, *cm_off_surf;
struct GRmdenv_info	*mdenv_info;
struct EMSinters	**p_inters;  /* Output inters list */
{

  IGRlong		msg_loc, stat_OM;
  IGRboolean		swap, rev;
  IGRshort		loc_uorv;
  struct GRid           loc_edge, loc_surf,
                        loc_off_surf;
  struct EMSintobj      *p_intobjs[2], *p_intobj=NULL;
  IGRdouble             uv[6];
  IGRushort		opt;

  struct EMSintobj      *EFext_and_prj_cv(), *EFmkint_from_isocurve();
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if(!ed_is_iso && !cm_ed_is_iso) EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);

  if(!ed_is_iso) swap = TRUE;
  else swap = FALSE;

  loc_surf = (swap ? *cm_surf : *surf);
  loc_off_surf = (swap ? *cm_off_surf : *off_surf);
  loc_edge = (swap ? *cm_edge : *edge);

  stat_OM = EFprj_midpoint_onto_off_surf(&msg_loc,loc_edge, loc_surf, 
                             loc_off_surf, mdenv_info, uv, &loc_uorv, &rev);
  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

 /* Extract the iso curve on the offset surface along 'loc_uorv' direction
    extending the full length of the surface. */

  p_intobjs[0] = EFmkint_from_isocurve(&msg_loc, loc_off_surf, uv, loc_uorv,
                                       rev,is_full, mdenv_info, p_inters);
  EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
  p_intobjs[0]->props |= EMSintobj_isocurve;

  if(cm_surf)
  {
    if(!swap && cm_ed_is_iso)
    {
       stat_OM = EFprj_midpoint_onto_off_surf(&msg_loc, *cm_edge, 
                                  *cm_surf,*cm_off_surf, mdenv_info, uv, 
                                  &loc_uorv, &rev);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

      /* Extract the iso curve on the offset surface along 'loc_uorv' direction
         extending the full length of the surface. */

       p_intobjs[1] = EFmkint_from_isocurve(&msg_loc, *cm_off_surf,
                                            uv, loc_uorv, 
                                            (rev ^ rev_conn ? TRUE : FALSE), 
                                            is_full,mdenv_info, p_inters);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
 if(rev_conn) printf("Reversing the Iso other intobj: rev_conn = %d\n", rev_conn);
#endif
       if(rev_conn) p_intobjs[1]->reversed = TRUE;
       p_intobjs[1]->props |= EMSintobj_isocurve;
    }
    else
    {
       opt = EMSExtPrj_NoClip | EMSExtPrj_WantSingleOut;
       p_intobjs[1] = EFext_and_prj_cv(&msg_loc, 
                                       (swap ? *off_surf : *cm_off_surf),
                                       (swap ? *off_surf : *cm_off_surf), opt,
				       NULL,
                                       p_intobjs[0]->this_xyzintobj.data.curve,
                                       FALSE, 0.0, 0.0, mdenv_info, p_inters,
                                       FALSE, NULL, NULL);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

#ifdef DEBUG
 if(rev_conn) printf("Reversing the projected other intobj\n");
#endif
      if(rev_conn)
            p_intobjs[1]->reversed = (p_intobjs[1]->reversed ? FALSE : TRUE);

    }
    p_intobjs[0]->other_intobj_node = p_intobjs[1];
    p_intobjs[1]->other_intobj_node = p_intobjs[0];
    p_intobjs[0]->props |= (EMSintobj_unmatched_dat | EMSintobj_tangent);
    p_intobjs[1]->props |= (EMSintobj_unmatched_dat | EMSintobj_tangent);

    if(swap) /* The first inters node corresponds up cm_surf and the next
               corresponds to surf. Hence swap their positions/
            */
    {
        struct EMSinters        *tmp_inters;
        tmp_inters = (*p_inters)->next;
        tmp_inters->next = *p_inters;
        (*p_inters)->next = NULL;
        *p_inters = tmp_inters;
        p_intobj = p_intobjs[1];

    }
    else
        p_intobj = p_intobjs[0];
  } /*  if(cm_surf) */
  else
        p_intobj = p_intobjs[0];

ret_end:
  return(p_intobj);

}

static IGRlong EFprj_midpoint_onto_off_surf(msg, edge, surf, off_surf, 
                                            mdenv_info, uv, uorv, reverse)
IGRlong      *msg;
struct GRid  edge, surf, off_surf;
struct GRmdenv_info *mdenv_info;
IGRdouble    uv[6];
IGRshort     *uorv;
IGRboolean   *reverse;
{
  IGRboolean            world;
  IGRlong               msg_loc, stat_OM;
  IGRpoint              pnt, pnt2,prj_pnt,prj_pnt2;
  struct GRparms          proj_parms,end_parms;
  struct EMSpartolbasis partolb;
  IGRdouble start_loc[2], stop_loc[2], umin, vmin, sfpartol=0, chttol=0;
  IGRboolean u_dir=TRUE, on_seam=FALSE;
  struct IGRbsp_surface	*sf_geom=NULL;
  IGRdouble   begin_pt_uv[2], end_pt_uv[2],begin_pt_xyz[3],end_pt_xyz[3];

  extern IGRdouble fabs();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  world = TRUE;
  stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                             &mdenv_info->matrix_type, mdenv_info->matrix,
                             &world, FALSE, &partolb.tol),
                       senderid = NULL_OBJID,
                       targetos = surf.osnum,
                       targetid = surf.objid);

  EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_SurfaceError,ret_end);
  partolb.in_world = TRUE;
  partolb.is_valid = TRUE;
  partolb.mattyp = &mdenv_info->matrix_type;
  partolb.mat = mdenv_info->matrix;

  /* Determine if the surface is closed. This is needed to check if the
     edge being projected is running along the seam
  */
  stat_OM = PW_GetSfBspsfStack (surf.objid, surf.osnum, mdenv_info->matrix_type,
                                mdenv_info->matrix, sf_geom);
  EMerr_hndlr(!(1 & stat_OM), *msg, EMS_E_SurfaceError,ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  sfpartol = pwGetParTolSf (sf_geom, chttol);

  /* 
   * Determine the End-pts of the edge and find the direction of flow of the
   * edge. Also find whether it flows along constant U or constant V.
   * Trivially return the projected point if on seam; Else do a point project
   */
  stat_OM = om$send(msg = message EMSedge.EMendpts(&msg_loc,
                                     start_loc, stop_loc, NULL, NULL, NULL),
                    senderid = NULL_OBJID,
                    targetos = edge.osnum,
                    targetid = edge.objid);
  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
  begin_pt_uv[0] = start_loc[0];
  begin_pt_uv[1] = start_loc[1];
  end_pt_uv[0]   = stop_loc[0] ;
  end_pt_uv[1]   = stop_loc[1] ;
  /* get the end points in XYZ space */

  stat_OM = om$send(msg = message EMSedge.EMxyz_endpt(&msg_loc,
                   NULL,mdenv_info,
                   begin_pt_uv, end_pt_uv,
                   begin_pt_xyz,end_pt_xyz,
                   NULL),
                   senderid = NULL_OBJID,
                   targetos = edge.osnum,
                   targetid = edge.objid);
  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  /* Project the begin_pt on to the offset surface */
  prj_pnt[0] = begin_pt_xyz[0];
  prj_pnt[1] = begin_pt_xyz[1];
  prj_pnt[2] = begin_pt_xyz[2];
  stat_OM = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                                  &mdenv_info->matrix_type,
                                  mdenv_info->matrix,prj_pnt,
                                  prj_pnt2, &end_parms),
                    senderid = NULL_OBJID,
                    targetos = surf.osnum,
                    targetid = off_surf.objid);
  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
  uv[2]=end_parms.u ; 
  uv[3]= end_parms.v;
                 
  /* Project on to the end_pt on the offset surface */
  prj_pnt[0] = end_pt_xyz[0];
  prj_pnt[1] = end_pt_xyz[1];
  prj_pnt[2] = end_pt_xyz[2];
  stat_OM = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                                  &mdenv_info->matrix_type,
                                  mdenv_info->matrix,prj_pnt,
                                  prj_pnt2, &end_parms),
                    senderid = NULL_OBJID,
                    targetos = surf.osnum,
                    targetid = off_surf.objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  uv[4]= end_parms.u; 
  uv[5]= end_parms.v; 

  umin = fabs(start_loc[0] - stop_loc[0]);
  vmin = fabs(start_loc[1] - stop_loc[1]);
  if( umin < vmin )
      u_dir = FALSE;

  if(u_dir)
  {
     *uorv = CONST_V;
     if(sf_geom->v_phy_closed)
	if(start_loc[1] < partolb.tol || fabs(start_loc[1] - 1.0) < partolb.tol)
	   on_seam = TRUE;
     if(on_seam)
     {
        uv[1] = (start_loc[1] < partolb.tol ? 0.0 : 1.0);
        uv[0] = 0.5;
     }
        
  }
  else
  {
     *uorv = CONST_U;
     if(sf_geom->u_phy_closed)
	if(start_loc[0] < partolb.tol || fabs(start_loc[0] - 1.0) < partolb.tol)
	   on_seam = TRUE;
     if(on_seam)
     {
        uv[0] = (start_loc[0] < partolb.tol ? 0.0 : 1.0);
	uv[1] = 0.5;
     }
  }

  *reverse = FALSE;
  if(u_dir)    /* Edge flows along constant V */
     if(start_loc[0] > stop_loc[0]) 
                   *reverse = TRUE;
  if(!u_dir)
     if(start_loc[1] > stop_loc[1]) 
                   *reverse = TRUE;

  if(on_seam) goto ret_end;

  /* Get an internal point on the edge and project onto the offset
     surface. */

  /* get an internal point on "edge" in uv[] */
  stat_OM = om$send(msg = message EMSedge.EMinternalpt(&msg_loc, 1,
                                          NULL, uv, NULL, &partolb),
                    senderid = NULL_OBJID,
                    targetos = surf.osnum,
                    targetid = edge.objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
                     ret_end);

  /* get the XYZ coordinates corresponding to uv[2] in pnt[3] */
  stat_OM = om$send(msg = message GRvg.EMptatpr (&msg_loc,
                                               &mdenv_info->matrix_type,
                                               mdenv_info->matrix, uv, 2, pnt),
                    senderid = NULL_OBJID,
                    targetos = surf.osnum,
                    targetid = surf.objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
                     ret_end);
  /* Project on to the offset surface */
  stat_OM = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                                  &mdenv_info->matrix_type,
                                  mdenv_info->matrix, pnt,
                                  pnt2, &proj_parms),
                    senderid = NULL_OBJID,
                    targetos = surf.osnum,
                    targetid = off_surf.objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  uv[0] = proj_parms.u;
  uv[1] = proj_parms.v;
  
  /*
   * uv[2],uv[3] : u,v parameters of the starting point of intobj
   * uv[4],uv[5] : u,v parameters of the ending point of intobj
   * The intobjs are extended at the ends by ten times the chord height partol,
   * so that it intersects safely with it's adjacent intobjs.
   */

  if(*uorv == CONST_U) 
     if(uv[3]>uv[5]) 
      {
        uv[3] += 10.0 * sfpartol;
        uv[5] -= 10.0 * sfpartol;
        if(uv[3] > 1.0) uv[3] = 1.0;
        if(uv[5] < 0.0) uv[5] = 0.0;
      }
    else
      {
       uv[5] += 10.0 * sfpartol;
       uv[3] -= 10.0 * sfpartol;
        if(uv[5] > 1.0) uv[5] = 1.0;
        if(uv[3] < 0.0) uv[3] = 0.0;
      }
  else
     if(uv[2]>uv[4])
      {
        uv[2] += 10.0 * sfpartol;
        uv[4] -= 10.0 * sfpartol;
        if(uv[2] > 1.0) uv[2] = 1.0;
        if(uv[4] < 0.0) uv[4] = 0.0;
      }
    else
      {
       uv[4] += 10.0 * sfpartol;
       uv[2] -= 10.0 * sfpartol;
       if(uv[4] > 1.0) uv[4] = 1.0;
       if(uv[2] < 0.0) uv[2] = 0.0;
      }
  

ret_end:
  return(stat_OM);
}

/************************************************************************
This function is used for generating the intersection objects from a
natural edge and its common edge if there is one. The assumption is that
the edge is either a stitchable (free) edge or a tangent edge. If tangent,
either or both could be natural.
*************************************************************************/
static struct EMSintobj *EFmkint_from_nat_edge(msg, ed_is_nat, cm_ed_is_nat,
                                               neutral, ang_meas,
					       ed_props, cm_ed_props, 
                                               ed_loc, cm_ed_loc, 
                                               edge, cm_edge, 
                                               orig_surf, orig_cm_surf,
                                               surf, cm_surf,
					       mdenv_info, p_inters)

IGRlong			*msg;
IGRboolean		ed_is_nat, cm_ed_is_nat; /* indicate "naturalness"   */
IGRboolean              neutral;
IGRdouble               ang_meas;
IGRushort               ed_props, cm_ed_props;   /* edge properties          */
IGRshort		ed_loc, cm_ed_loc;	 /* indicates the location 
					            U0, V1 , U1 or V0 	     */
struct GRid		*edge, *cm_edge, 
                        *orig_surf, *orig_cm_surf,
                        *surf, *cm_surf;
struct GRmdenv_info	*mdenv_info;
struct EMSinters	**p_inters;  /* Output inters list */
{

  IGRlong		msg_loc, stat_OM;
  IGRboolean		swap, rev_conn;
  IGRshort		loc_loc;
  struct GRid		loc_surf, nat_ed;
  GRobjid		nat_edges[4];
  struct EMSintobj	*p_intobjs[2], *p_intobj=NULL;
  IGRdouble             uv[6];
  IGRshort              loc_uorv;
  IGRboolean            rev, ed_iso, cm_ed_iso;
  IGRushort		opt;
  IGRint                no_edges[2];
  struct EMSintobj	*EFmkint_from_edge(), *EFext_and_prj_cv(),
                        *EFmkint_from_isocurve();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  rev_conn = (ed_props & EMED_REVERSE_CONNECT ? TRUE : FALSE);
  if(!ed_is_nat && !cm_ed_is_nat) EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);
  
  ed_iso = cm_ed_iso = FALSE;
  if(!ed_is_nat)
  {
    swap = TRUE;
    EFchk_if_iso(&msg_loc, *edge, ed_props, &ed_iso);
  }
  else
  {
    swap = FALSE;
    if(!cm_ed_is_nat)
       if(cm_edge) EFchk_if_iso(&msg_loc, *cm_edge, cm_ed_props, &cm_ed_iso);
  }

  loc_surf = (swap ? *cm_surf : *surf);
  loc_loc = (swap ? cm_ed_loc : ed_loc);

  stat_OM = om$send(msg = message EMSsurface.EMmk_nat_bdry(
				  &msg_loc, mdenv_info, nat_edges),
		    senderid = NULL_OBJID,
                    targetid = loc_surf.objid,
                    targetos = loc_surf.osnum);
  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  nat_ed.objid = nat_edges[loc_loc];
  nat_ed.osnum = loc_surf.osnum;
  p_intobjs[0] = EFmkint_from_edge(&msg_loc, loc_surf, nat_ed, FALSE, NULL, 
				   FALSE, mdenv_info, p_inters);
  EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
  p_intobjs[0]->props |= EMSintobj_isocurve;

  if(cm_surf)
  {
    if(!swap && cm_ed_is_nat)
    {

      stat_OM = om$send(msg = message EMSsurface.EMmk_nat_bdry(
				      &msg_loc, mdenv_info, nat_edges),
		        senderid = NULL_OBJID,
                        targetid = cm_surf->objid,
                        targetos = cm_surf->osnum);
      EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      /* Create the "other" intobj's geometry is running in the same direction
         as that of p_intobjs[0] and then set its "reversed" field if the edges
	 are to be "reverse-connected"
      */
      nat_ed.objid = nat_edges[cm_ed_loc];
      nat_ed.osnum = cm_surf->osnum;
      p_intobjs[1] = EFmkint_from_edge(&msg_loc, *cm_surf, nat_ed, FALSE,
 				       NULL, (rev_conn ? TRUE : FALSE),
				       mdenv_info, p_inters);
      EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
      if(rev_conn) p_intobjs[1]->reversed = TRUE;
      p_intobjs[1]->props |= EMSintobj_isocurve;

    }
    else if(!swap &&
                     EFgenerate_an_iso_intobj(&msg_loc, FALSE, 
                                           neutral, ang_meas,
                                           FALSE, cm_ed_iso,
                                           edge, cm_edge, orig_surf, 
                                           orig_cm_surf, mdenv_info,no_edges)
           ) 
    {
#ifdef DEBUG
 printf("This NAT_EDGE (%d - %d). Other ISO Edge\n", 
                           edge->objid, orig_surf->objid);
#endif
     stat_OM = EFprj_midpoint_onto_off_surf(&msg_loc, *cm_edge, *orig_cm_surf,
                                *cm_surf, mdenv_info, uv, &loc_uorv, &rev);
      EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

      /* Extract the iso curve on the offset surface along 'loc_uorv' direction
         extending the full length of the surface. */

      p_intobjs[1] = EFmkint_from_isocurve(&msg_loc, *cm_surf,
                                            uv, loc_uorv,
                                            (rev ^ rev_conn ? TRUE : FALSE),
                                            TRUE,mdenv_info, p_inters);
      EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
 if(rev_conn) printf("Reversing the Iso other intobj: rev_conn = %d\n", rev_conn
);
#endif
      if(rev_conn) p_intobjs[1]->reversed = TRUE;
      p_intobjs[1]->props |= EMSintobj_isocurve;

    }
    else if(swap && 
                     EFgenerate_an_iso_intobj(&msg_loc, FALSE, 
                                           neutral, ang_meas,
                                           ed_iso, FALSE,
                                           edge, cm_edge, orig_surf, 
                                           orig_cm_surf, mdenv_info,no_edges)
           ) 
    {
#ifdef DEBUG
 printf("This ISO Edge (%d - %d). Other NAT_EDGE\n", 
                           edge->objid, orig_surf->objid);
#endif
       stat_OM = EFprj_midpoint_onto_off_surf(&msg_loc, *edge, *orig_surf,
                                *surf, mdenv_info, uv, &loc_uorv, &rev);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

      /* Extract the iso curve on the offset surface along 'loc_uorv' direction
         extending the full length of the surface. */

       p_intobjs[1] = EFmkint_from_isocurve(&msg_loc, *surf,
                                            uv, loc_uorv,
                                            (rev ^ rev_conn ? TRUE : FALSE),
                                            TRUE,mdenv_info, p_inters);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
 if(rev_conn) printf("Reversing the Iso other intobj: rev_conn = %d\n", rev_conn
);
#endif
       if(rev_conn) p_intobjs[1]->reversed = TRUE;
       p_intobjs[1]->props |= EMSintobj_isocurve;
    }
    else
    {
       opt = EMSExtPrj_NoClip | EMSExtPrj_WantSingleOut;
       p_intobjs[1] = EFext_and_prj_cv(&msg_loc, (swap ? *surf : *cm_surf),
				       (swap ? *surf : *cm_surf), opt, NULL,
				       p_intobjs[0]->this_xyzintobj.data.curve,
				       FALSE, 0.0, 0.0, mdenv_info, p_inters,
				       FALSE, NULL, NULL);
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

      if(rev_conn)
	    p_intobjs[1]->reversed = (p_intobjs[1]->reversed ? FALSE : TRUE);
/*
	 if(swap)
	    p_intobjs[0]->reversed = (p_intobjs[0]->reversed ? FALSE : TRUE);
	 else
	    p_intobjs[1]->reversed = (p_intobjs[1]->reversed ? FALSE : TRUE);
*/
    }
    p_intobjs[0]->other_intobj_node = p_intobjs[1];
    p_intobjs[1]->other_intobj_node = p_intobjs[0];
    p_intobjs[0]->props |= (EMSintobj_unmatched_dat | EMSintobj_tangent);
    p_intobjs[1]->props |= (EMSintobj_unmatched_dat | EMSintobj_tangent);

    if(swap) /* The first inters node corresponds up cm_surf and the next
	       corresponds to surf. Hence swap their positions/
	    */
    {
        struct EMSinters	*tmp_inters;
	tmp_inters = (*p_inters)->next;
	tmp_inters->next = *p_inters;
	(*p_inters)->next = NULL;
	*p_inters = tmp_inters;
	p_intobj = p_intobjs[1];
	
    }
    else
	p_intobj = p_intobjs[0];
  } /*  if(cm_surf) */
  else
	p_intobj = p_intobjs[0];

ret_end:
  return(p_intobj);
}

/**************************************************************************
This function checks if a given edge runs along a surface parametric boundary.
If so it also finds its location i.e whether along U0, V1, U1 or V0.
****************************************************************************/
static void EFchk_if_natural(msg, edge, ed_props, is_sp_tan, is_nat, loc)
IGRlong		*msg;
struct GRid	edge;
IGRushort	ed_props;
IGRboolean      is_sp_tan;
IGRboolean	*is_nat;
IGRshort	*loc;
{
  IGRlong		stat_OM, msg_loc;

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;
  *is_nat = FALSE;

  if((ed_props & EMED_NATURAL) && !is_sp_tan)
  {
     IGRdouble start_loc[2], stop_loc[2];
     IGRboolean u_dir=TRUE;

     *loc = -99;
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg_loc,
                      		     start_loc, stop_loc, NULL, NULL, NULL),
  	               senderid = NULL_OBJID,
                       targetos = edge.osnum,
  		       targetid = edge.objid);
     EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

     if(start_loc[1] != stop_loc[1]) u_dir = FALSE;
     if(u_dir)
     {
       if(start_loc[0] < stop_loc[0])
       {
  	if(start_loc[0]==0.0 && stop_loc[0]==1.0)
  	   *loc = V1;
       }
       else
       {
  	if(start_loc[0]==1.0 && stop_loc[0]==0.0)
  	   *loc = V0;
       }
     }
     else  /* v direction */
     {
       if(stop_loc[1] < start_loc[1])
       {
  	if(stop_loc[1]==0.0 && start_loc[1]==1.0)
  	   *loc = U1;
       }
       else
       {
  	if(stop_loc[1]==1.0 && start_loc[1]==0.0)
  	   *loc = U0;
       }
     }
     if(*loc != -99) *is_nat = TRUE;

  } /* ed_props & EMED_NATURAL */

ret_end:
  return;
}
/**************************************************************************
This function checks if a given edge runs along a surface's iso-parametric
direction.
****************************************************************************/
static void EFchk_if_iso(msg, edge, ed_props, is_iso)
IGRlong		*msg;
struct GRid	edge;
IGRushort	ed_props;
IGRboolean	*is_iso;
{
  IGRlong		stat_OM, msg_loc;

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;
  *is_iso = FALSE;

  if(ed_props & EMED_ISO)
     *is_iso = TRUE;
  else
  {
     IGRdouble iso_points[4];
     struct IGRpolyline poly;
     extern IGRboolean EMis_iso_edge();

     poly.points = NULL;
     stat_OM = om$send(msg = message EMSedge.EMgetpygeom(&msg_loc, 0,
				     OM_K_MAXINT, FALSE, NULL, &poly, NULL,
				     NULL),
  	               senderid = NULL_OBJID,
                       targetos = edge.osnum,
  		       targetid = edge.objid);
     EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

     *is_iso = EMis_iso_edge(poly.num_points, poly.points, EMS_HIGH_UVLENTOL,
			     iso_points);
  } /* else of ed_props & EMED_ISO */

ret_end:
  return;
}

/************************************************************************
NAME:
    EFgenerate_an_iso_intobj

DESCRIPTION:
 This function is used to check whether an 'Iso' edge in the original
 surface should be marked as 'Iso' in the 'offset' surface. The reasoning
 for this is as follows:
     'intobjs' marked as 'Iso' are not refined in 'EMregen_tpgy' so
     that 'natural' edge intobjs (which are also marked as Iso) do not get
     refined. This however, causes problems in multi-edge vertex situations
     which have Iso edges, resulting in 'z val' showing 'gap between edges'.

ALGORITHM:

 Edges which are 'Iso' should generate an 'Iso' 'intobj' only if the
 following conditions are met:

     The edge is a FREE edge or a neutral edge within EMS_ZEROANGLE_DEG &&
                             AND
       Either the edge or its common edge is an 'Iso' edge
                             AND
         [(Both Vertices of this edge have <= 3 edges meeting at them)
                             OR
          (Neither this surface nor the common surface is an EMSgenbs
                             AND
             None of the other surface meeting at the two vertices are
                                                        of type 'EMSgenbs'
                             AND
               All 'tangent' edges meeting at either of the vertices
                                     are neutral within EMS_ZEROANGLE_DEG)] 

RETURN VALUES:
The function returns 
            'TRUE'     if the above conditions are met 
            'FALSE'    otherwise

HISTORY:

??-Dec-93
Creation - Sudhakar

14-Dec-93
Modified the function to remove "surface-type" from the criteria for 
retaining iso-ness - Ashok

27-Dec-93
Modified argument list. Removed ed_props and cm_ed_props. Added ed_iso and
cm_ed_iso. - Ashok

29-Sep-95
If more than two edges meet at the ends of a free edge than gen_iso is
set to FALSE,to avoid invalid offset surface with gaps at the vertex.
And this fixes the TRs 119423086 and 119527604.  -Jagan


*************************************************************************/
static IGRboolean EFgenerate_an_iso_intobj(msg, is_free, neutral, ang_meas,
                                           ed_iso, cm_ed_iso, edge, cm_edge,
					   surf, cm_surf, mdenv_info,no_edges)

IGRlong			*msg;
IGRboolean              is_free, neutral, ed_iso, cm_ed_iso;
IGRdouble               ang_meas;
struct GRid		*edge, *cm_edge, 
                        *surf, *cm_surf;
struct GRmdenv_info	*mdenv_info;
IGRint                  no_edges[2];

{

  IGRlong		msg_loc, stat_OM, ii, jj;
  IGRboolean            gen_iso;
  GRobjid        	*edges[2];
/*  extern void           getsftype(); */
  extern IGRlong        EFget_edge_info();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  gen_iso = FALSE;
  cm_edge = cm_edge; /* To avoid compiler warning */
  cm_surf = cm_surf; /* avoid compiler warnings */
  edges[0] = edges[1] = NULL;
/*  ed_iso = ed_props & EMED_ISO;
    cm_ed_iso = cm_ed_props & EMED_ISO;
*/

#ifdef DEBUG
 printf("Entered EFgenerate_an_iso_intobj() function \n");
#endif

  if( is_free || 
        (neutral && (fabs(ang_meas - 2.0) <= EMS_ZEROANGLE_DEG)))

/*   if((ed_props & EMED_ISO) || (cm_ed_props && (cm_ed_props & EMED_ISO))) */
     if(ed_iso || cm_ed_iso)
     {
       IGRushort      options;
       IGRboolean     right_vtx, *is_rightend[2];
       IGRint         num_buff, num_edges[2];
/*       IGRshort       this_sftype, cm_sftype;		*/

       /* Initialise */
       is_rightend[0] = is_rightend[1] = NULL;

       /* Obtain the information about the edges meeting at the two
          vertices of this edge. */

       options =  EMSvtxedges_onlydominant;

       for (ii = 0; ii < 2 ; ii++)
       {
          num_buff = num_edges[ii] = 0;
          right_vtx = TRUE;
          if(ii > 0) right_vtx = FALSE;
          stat_OM = om$send (msg = message EMSedge.EMgetvtxedges(&msg_loc,
                                  options, right_vtx, num_buff, 
                                  &num_edges[ii], &edges[ii], &is_rightend[ii]),
                            senderid = NULL_OBJID,
                            targetid = edge->objid,
                            targetos = edge->osnum);
	  if(is_rightend[ii]) om$dealloc(ptr = is_rightend[ii]);
          EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, 
                                                     EMS_E_EdgeError, ret_end);
#ifdef DEBUG
  printf("For edge id = %d of Surface id = %d :\n", edge->objid, surf->objid);
  if(ii == 0)
     printf("Number of edges at right vertex = %d\n", num_edges[ii]);
  else
     printf("Number of edges at left vertex = %d\n", num_edges[ii]);
#endif
       }
       no_edges[0] = num_edges[0];
       no_edges[1] = num_edges[1]; 
       /* If free edge has more than three edges meeting at it's ends 
          than it is better not to take gen_iso = TRUE because it
          is some times resulting  in invalid offset-surface with 
          gap between the edges at the vertex.
       */

       if(is_free)
       { 
        if((num_edges[0] <= 2) && (num_edges[1] <= 2))
         {
          gen_iso = TRUE;
          goto ret_end;
         }
          else 
          {
           gen_iso = FALSE;
           goto ret_end;
          }
        }
       if((num_edges[0] <= 3) && (num_edges[1] <= 3))
       {
          gen_iso = TRUE;
          goto ret_end;
       }
         for(ii=0; ii<2; ii++)
         {
            if(num_edges[ii] <= 2) continue;
            for(jj=0; jj<num_edges[ii]; jj++)
            {
               struct GRid     		vtxedg, vtxedg_surf, comm_ed, comm_surf;
               IGRboolean      		vtxedg_free, convex, neutral;
               IGRushort      		vtxedg_props, vtxcm_ed_props;
               IGRdouble       		vtxedg_ang_meas;
/*               IGRshort        		vtxsftype, vtxcmsftype;  */
               struct EMSpartolbasis    partolbasis;
              
               vtxedg.objid = edges[ii][jj];
               vtxedg.osnum = vtxedg_surf.osnum = surf->osnum;
               comm_ed.osnum = comm_surf.osnum = surf->osnum;

               /* get surface id of this edge */
               partolbasis.is_valid = FALSE; 
               partolbasis.in_world = TRUE;
               partolbasis.mattyp = &mdenv_info->matrix_type;
               partolbasis.mat = mdenv_info->matrix;

               stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                                       (&msg_loc, &vtxedg_surf.objid,
                                                  &partolbasis),
                                 senderid = NULL_OBJID,
                                 targetid = vtxedg.objid,
                                 targetos = vtxedg.osnum);
               EMerr_hndlr(! (1 & stat_OM & msg_loc), 
                                             *msg,EMS_E_EdgeError,ret_end);

               stat_OM = EFget_edge_info(&msg_loc, 
                                     &mdenv_info->matrix_type, 
                                     mdenv_info->matrix, vtxedg, 
                                     &comm_ed, &comm_surf, &vtxedg_props,
                                     &vtxedg_free, &convex, &neutral,
                                     NULL, NULL,
                                     &vtxedg_ang_meas, &vtxcm_ed_props);
               EMerr_hndlr(! (1 & stat_OM & msg_loc), 
                                             *msg,EMS_E_EdgeError,ret_end);

               if(neutral)
               {
/*
                  getsftype(vtxedg_surf.objid, vtxedg_surf.osnum, &vtxsftype); 
                  getsftype(comm_surf.objid, comm_surf.osnum, &vtxcmsftype); 

                  if((vtxsftype == BSGEN_BSP_SF) || 
                     (vtxcmsftype == BSGEN_BSP_SF) ||
*/
                  if(fabs(vtxedg_ang_meas - 2.0) > EMS_ZEROANGLE_DEG)
                  {
#ifdef DEBUG
                    printf("Iso-ness Discarded due to :\n");
                    printf("  For Surfid = %d, edge id = %d :\n", 
                                           vtxedg_surf.objid, vtxedg.objid);
                    printf(" ang_meas = %lg\n", vtxedg_ang_meas);
#endif
                    gen_iso = FALSE;
                    goto ret_end;
                  }
               } /* end of if(neutral) */
            } /* end of for(jj..)  */
         } /* end of for(ii...) */
         gen_iso = TRUE;
     } /* end of if((ed_iso || cm_ed_iso .. and if(is_free || ..) */
 
ret_end:
  for(ii=0; ii<2; ii++)
      if(edges[ii]) om$dealloc(ptr = edges[ii]);

#ifdef DEBUG
  if(gen_iso)
     printf("This intobj will be ****ISO*****\n");
#endif
  return(gen_iso);
} 

/****************************************************************************
NAME: EFis_along_seam

DESCRIPTION: 
	     This function checks if the two incoming 2D line segments
	     (EMSdataselects) are parallel to each other. This static
	     function is highly specialized in that :
		o the first dataselect is assumed to represent a seam.
		o the dataselects represent UV space geometry

RETURN VALUES:
	     TRUE if the candidate dataselect is parallel to the seam,
	     FALSE otherwise.

CAVEATS:
	The two dataselects are assumed to be of type EMSdata_poly2d

HISTORY:
	23-Dec-1993	ashok		Creation
*/

static IGRboolean EFis_along_seam(seam, cand)
/****************************************************************************/
struct EMSdataselect	*seam, *cand;
{
  IGRlong		rc, i;
  IGRboolean		stat_func;
  IGRdouble		*seam_start_pt, *seam_stop_pt, *start_pt, *stop_pt,
			vec1[3], vec2[3], dottol, dotp;
  stat_func = FALSE;
  if(cand->datatype != EMSdata_poly2d) goto ret_end;

  seam_start_pt = &seam->data.poly->points[0];
  seam_stop_pt  = &seam->data.poly->points[2*(seam->data.poly->num_points-1)];
  start_pt = &cand->data.poly->points[0];
  stop_pt  = &cand->data.poly->points[2*(cand->data.poly->num_points-1)];
  for(i=0; i<2; i++)
  {
      vec1[i] = seam_start_pt[i] - seam_stop_pt[i];
      vec2[i] = start_pt[i] - stop_pt[i];
  }
  vec1[2] = vec2[2] = 0.0;
  BSnorvec(&rc, vec1);
  if(BSERROR(rc)) goto ret_end;
  BSnorvec(&rc, vec2);
  if(BSERROR(rc)) goto ret_end;
  dottol = cos((90.0 - EMS_ZEROANGLE_DEG) * (M_PI/180.0));
  dotp = fabs(BSdotp(&rc, vec1, vec2));
  if(fabs(1.0 - dotp) < dottol)    /* vectors along same direction ! */
     stat_func = TRUE;
ret_end:
  return(stat_func);
}


/****************************************************************
   EFget_intobj_extdist():
       It finds the extention distance required for the
       edge which is to be projected on to the offset 
       surface.
****************************************************************/

static void EFget_intobj_extdist
(
  GRobjid    edobj,
  OMuword    os,
  IGRushort  lpprops,
  double     offdist,
  double     partol,
  double     chttol,
  double     ext_dist[2]
)
{
  GRobjid prev_ed=NULL_OBJID, next_ed=NULL_OBJID;

  prev_ed = pwGetPrevEdNoDegen (edobj, os, partol);
  next_ed = pwGetNextEdNoDegen (edobj, os, partol);
  if (prev_ed != NULL_OBJID && prev_ed != edobj && pwIsEdFree (prev_ed, os))
  {
    ext_dist[0] = chttol;
  }
  else
  {
    ext_dist[0] = (lpprops & EMLP_EXTERNAL ? 5 * offdist :
                                             5 * chttol);
  }

  if (next_ed != NULL_OBJID && next_ed != edobj && pwIsEdFree (next_ed, os))
  {
    ext_dist[1] = chttol;
  }
  else
  {
    ext_dist[1] = (lpprops & EMLP_EXTERNAL ? 5 * offdist :
                                             5 * chttol);
  }
}

/********************************************************

  PWboolean pwIsEdFree:
      It finds weather the given edge if free edge are not.
**********************************************************/


PWboolean pwIsEdFree
(
  PWobjid edobj,
  PWosnum os
)
{
  OM_S_CHANSELECT to_commed;
  IGRlong sts=OM_S_SUCCESS;
  unsigned int count=0;

  EMmake_chanselect (EMSedge_to_common_edge, &to_commed);
  count = 0;
  sts = om$get_channel_count(objid = edobj, osnum = os,
                             p_chanselect = &to_commed, count = &count);
  if ((1&sts) && count)
    return FALSE;
  else
    return TRUE;
}

/*******
           this function does the offset composite surface for a
           case of non symmetric offset---V.Srinivas
 *******/

IGRlong EFoffset_compsf_tw(msg, in_grid, option, mattyp, mat, construct_list,
			offset_inward, distance, num_spec_thick,
			val_spec_thick, spec_thick_sf_sets, num_nooffsetsfs,
			nooffsetsfs, status_str, constructed_object,
			inters_out, num_comps, sf_comps, errkey_list,edge_map_list)
    IGRlong *msg;
    struct GRid in_grid;
    IGRushort option;
    IGRshort *mattyp;
    IGRmatrix mat;
    struct GRvg_construct *construct_list;
    IGRboolean offset_inward;
    IGRdouble distance;
    IGRint num_spec_thick;
    IGRdouble *val_spec_thick;
    struct GRobjid_set *spec_thick_sf_sets;
    IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
    IGRchar *status_str;
    OM_S_OBJID *constructed_object;
    struct EMSinters **inters_out;
    IGRint *num_comps;
    GRobjid **sf_comps;
    struct EMSerror_help *errkey_list;
    GRobjid  ***edge_map_list;

{
IGRlong			sts, msg_loc, num_inters, jj;
IGRint                  num_edges,tmp_num_edges, *comm_sf_indices=NULL;
IGRshort		loc, ed_loc, cm_ed_loc;
IGRdouble		tol, lentol, ext_dist[4], ang_meas, 
                        *adjsfs_offdists=NULL;
GRobjid			*surfs=NULL,seam_objid;
struct GRid		*edges, comm_ed, orig_surf, off_surf,comm_surf, cs_grid;
struct EMSoff_sf_info	*off_surfs_info=NULL;
struct EMSdataselect	sf2_data;
IGRushort		inters_options, world_options, param_options, *props,
			ed_props, cm_ed_props, opt;
IGRint  		i, j, k, l, clos_info, buff_size, list_size, numsf,no_edges[2], 
			depth, num_loops, max_adjsfs, num_adjsfs, comm_sf_ind=0; 
IGRint                  lpinx;
                                       /* initialize to
					  prevent stupid compiler warning */
IGRboolean		world, convex, neutral, matches, is_free,
			ed_nat, cm_ed_nat, ed_iso, cm_ed_iso, ls_created=FALSE,
                        is_spec_tangent=FALSE;
struct GRmd_env		sfmdenv;
struct EMSpartolbasis	partolb;
struct EMSinters	*p_inters, *tmp_inters, *other_inters;
struct EMSintobj	*p_intobj, *p_intobj_fwd, *p_match, *p_intobjs[2],
			*current_intobj;
OM_S_OBJID		*loop_ids;
OM_S_CHANSELECT		chan_to_loopset;
struct IGRbsp_curve     *cv_geom = NULL;
struct EMSpypoint	*p_pypt = NULL;

/* Variables added by Sudhakar to support seams */
OM_S_OBJID     	prev_common_surface;
IGRboolean     	stat_func, seam_affected;
IGRint          this_seam_index, other_seam_index;

extern void		EMdelintobj(), EFcvt_edge_to_cv(),
			EFget_sf_extensions(), EFget_component_offsets();
extern IGRboolean	EFintobj_matches_edge(), EFconvert_seam_to_intobjs(),
			EFproj_vert_to_intobj();
extern IGRlong 		EFget_edge_info();
extern struct EMSintobj *EFext_and_prj_cv();
extern struct EMSinters	*EMinters_malloc();
extern IGRdouble 	fabs();
/*
 * Initialize
 */
	*msg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	*constructed_object = NULL_OBJID;
	Sf_Inters = NULL;
	edges = NULL;
	loop_ids = NULL;
	props = NULL;
        seam_objid=NULL_OBJID;
	opt = EMSExtPrj_NoClip | EMSExtPrj_WantSingleOut;

        EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
        sfmdenv.md_env.matrix_type = *mattyp;
        OM_BLOCK_MOVE(mat, sfmdenv.md_env.matrix, sizeof(IGRmatrix));
        sfmdenv.md_id.objid = construct_list->env_info->md_id.objid;
        sfmdenv.md_id.osnum = construct_list->env_info->md_id.osnum;

/*
 * get  list of the surfaces of this composite surface
*/

	sts = om$send( msg = message GRowner.GRget_number_components(
				&msg_loc, &numsf ),
			senderid = NULL_OBJID,
			targetid = in_grid.objid,
			targetos = in_grid.osnum );
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	surfs = (GRobjid *) om$malloc(size = numsf * sizeof(GRobjid));

	off_surfs_info = (struct EMSoff_sf_info *) om$malloc(size = numsf * 
					      sizeof(struct EMSoff_sf_info) );
	list_size = numsf;
	buff_size = num_edges = numsf = 0;
	EMerr_hndlr((!surfs || !off_surfs_info), *msg, EMS_E_NoDynamicMemory, 
	             ret_end);

	sts = om$send(msg = message EMScompsurf.EMgetedges(&msg_loc,
			    EMS_OPT_STITCHED, NULL, &buff_size, &num_edges,
			    &surfs, NULL, &list_size, &numsf),
		      senderid = NULL_OBJID,
		      targetos = in_grid.osnum,
		      targetid = in_grid.objid);
	EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	/* Allocate the memory that will be used to store the indices of
	   the adjacent surfaces
	*/
        if(num_edges)
        {
	   comm_sf_indices = (IGRint *) om$malloc(size = num_edges *
					       sizeof(IGRint));
	   EMerr_hndlr((!comm_sf_indices), *msg,
                                      EMS_E_NoDynamicMemory, ret_end);
        }
        else
        {
          /* No stitched edges . Hence number of components got to be 1 */

           numsf = 1;
           sts = om$send( msg = message GRowner.GRget_components(
                                &msg_loc, &sfmdenv, &orig_surf, numsf,
                                &numsf, 0, 0),
                        senderid = NULL_OBJID,
                        targetid = in_grid.objid,
                        targetos = in_grid.osnum );
           EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

           surfs[0] = orig_surf.objid;

	   /* Make sure the surface has a 'loopset' before proceeding. */

	   sts = om$send (msg = message EMSsubbs.EMputLsIfNotThere(&msg_loc,
                   &(sfmdenv.md_env), NULL, NULL, 0, &ls_created),
                   targetid = surfs[0],
                   targetos = in_grid.osnum,
                   senderid = NULL_OBJID);
           EMerr_hndlr(! (1 & sts & msg_loc), *msg,EMS_E_LoopsetError, ret_end);

        }

/* 1ST STAGE PROCESSING. OFFSETTING AND EXTENDING COMPONENT SURFACES .... */
   ex$message(msgnumb = EMS_S_ProcessingOne);

/* Offset and fill in information for all the component surfaces such as 
   U/V-closure, seam deleted or not, offset-distance and adjacent surface
   indices in the 'off_surfs_info' list.
*/
	EFget_component_offsets(&msg_loc, numsf, surfs, OM_Gw_current_OS,
				distance, num_spec_thick, val_spec_thick, 
				spec_thick_sf_sets, num_nooffsetsfs, 
				nooffsetsfs, off_surfs_info, &sfmdenv, 
				offset_inward, construct_list, comm_sf_indices,
				errkey_list, option, status_str);
   	EMerr_hndlr(! (1 & msg_loc), *msg, EMS_E_Fail, ret_end);

        if(!num_edges)
        {
           list_size = 0;
           buff_size = num_edges;

           sts = om$send(msg = message EMScompsurf.EMgetedges(&msg_loc,
                            EMS_OPT_CONNECTABLE, NULL, &buff_size, &num_edges,
                            NULL, NULL, &list_size, NULL),
                      senderid = NULL_OBJID,
                      targetos = in_grid.osnum,
                      targetid = in_grid.objid);
           EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

           if(!num_edges)
           {
            /* Case of single closed component surface 
                    eg. torus/ellipsoid etc.*/
              *constructed_object = off_surfs_info[0].objid;
              goto ret_end;
           }
        }

	orig_surf.osnum = OM_Gw_current_OS;   /* os of the incoming composite */
	off_surf.osnum = sfmdenv.md_id.osnum; /* os of the output composite */

        max_adjsfs = -1 * OM_K_MAXINT;
	for ( i=0; i<numsf; i++ )
            if(off_surfs_info[i].num_adj_sfs > max_adjsfs)	
                max_adjsfs = off_surfs_info[i].num_adj_sfs;

        if(max_adjsfs > 0)
        {
           adjsfs_offdists = (IGRdouble *) om$malloc(size =
                                         max_adjsfs * sizeof(IGRdouble));
           EMerr_hndlr((!adjsfs_offdists), *msg,
                                      EMS_E_NoDynamicMemory, ret_end);
        }
        else
           adjsfs_offdists = NULL;

	for ( i=0; i<numsf; i++ )
	{
	    orig_surf.objid = surfs[i];
	    off_surf.objid = off_surfs_info[i].objid;

           /* Get the offset distances of the adjacent surfaces */
            num_adjsfs = off_surfs_info[i].num_adj_sfs;
            for(j=0; j<num_adjsfs; j++)
                 adjsfs_offdists[j] = 
                       off_surfs_info[off_surfs_info[i].adj_sfs[j]].distance;

	  /* Determine the extent of extension needed for Current_Surface */
	    EFget_sf_extensions(&msg_loc, orig_surf, off_surf,
				&sfmdenv, (off_surfs_info[i].distance > 0.0 ?
				off_surfs_info[i].distance : distance),
                                offset_inward,
                              (((num_spec_thick == 0) && (num_nooffsetsfs == 0))
                                 ? FALSE : TRUE),
                                num_adjsfs,
                                adjsfs_offdists,
                                ext_dist);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
 printf("The extension distances for surface id = %d are : %lg,%lg,%lg,%lg\n",
           orig_surf.objid, ext_dist[0], ext_dist[1], ext_dist[2], ext_dist[3]);
#endif


	  /* Extend Current_Surface along its parametric directions */
	    sts = om$send( msg = message EMSsubbs.EMextend_by_dist(&msg_loc, 
					&sfmdenv, ext_dist, ext_dist, 
					(EMS_opt_extendS_deextend_if_needed |
                                        EMS_opt_extendS_reparametrize_surface),
                                        &off_surfs_info[i].objid),
			senderid = NULL_OBJID,
			targetid = off_surf.objid,
			targetos = off_surf.osnum );
	    EMerr_hndlr(! (1 & sts & msg_loc), *msg, EMS_E_Fail, ret_end);

	}

        if(adjsfs_offdists) om$dealloc (ptr = adjsfs_offdists);
        adjsfs_offdists = NULL;

/* 2ND STAGE PROCESSING. COMPUTING SURFACE-SURFACE INTERSECTIONS .... */
ex$message(msgnumb = EMS_S_ProcessingTwo);

/* Now intersect pairs of surfaces in 'off_sf_info[]'. Intersect only pairs
   that share an edge in the original pair ("surfs"). Thus  produce an 
   'EMSinters' list with uv and xyz representation of the intersection curves.
*/
	BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, tol);
	BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
	inters_options = EMS_SFINT_NOREFINE | EMS_SFINT_HANDLESTOP;
	world_options = EMSINT_OUTPUT_WORLD;
	param_options = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT |
			EMSINT_ORIENT_RIGHT;
	sfmdenv.md_env.matrix_type = *mattyp;
	OM_BLOCK_MOVE(mat, sfmdenv.md_env.matrix, sizeof(IGRmatrix));

/*      EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset); */


	/* Allocate the 'inters' list for the offset composite surface */
	Sf_Inters = EMinters_malloc (&msg_loc, numsf);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
        for(i=0, p_inters=Sf_Inters; i<numsf; i++, p_inters=p_inters->next)
        {
	    p_inters->this_obj.objid = off_surfs_info[i].objid;
	    p_inters->this_obj.osnum = off_surf.osnum;
	}

	/* Start constructing the inters list processing node at a time */
	for(i=0, p_inters=Sf_Inters; i<numsf; i++, p_inters=p_inters->next)
	{
	/* Initialize the per-surface static variables */
	  Current_Inters = p_inters;
	  Current_Surface = Current_Inters->this_obj.objid;
	  Avail_Intobjs_Ptr = Current_Inters->cvs;
	  Current_Inters->num_cvs = 0;
	  Prev_Loop_Last_Intobj = NULL;

#ifdef DEBUG
printf("Current_Surface = %d\n", Current_Surface);
printf("Original Surface = %d\n", surfs[i]);
#endif

	/* Get the parametric-tolerance of the current original surf */
	  orig_surf.objid = surfs[i];
	  off_surf.objid = off_surfs_info[i].objid;
  	  world = TRUE;
  	  sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                 mattyp, mat, &world, FALSE, &partolb.tol),
			 senderid = NULL_OBJID,
                         targetos = orig_surf.osnum,
                         targetid = orig_surf.objid);
	  EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_SurfaceError,ret_end);
	  partolb.in_world = TRUE;
	  partolb.is_valid = TRUE;
	  partolb.mattyp = mattyp;
	  partolb.mat = mat;

	/* Check if the current surface or any of its common edge surfaces has
	   seam deleted. If so set the flag "seam_affected" to TRUE.
	*/
	  seam_affected = (off_surfs_info[i].props & SEAM_DELETED ? 
					     TRUE : FALSE);
	  for(l=0; l<off_surfs_info[i].num_adj_sfs && !seam_affected; l++)
	  {
	     comm_sf_ind = off_surfs_info[i].adj_sfs[l];
	     if(off_surfs_info[comm_sf_ind].props & SEAM_DELETED)
             { 
		seam_affected = TRUE;
             }
	  }

	/* Get all the loops in Current_Surface */
          loop_ids = NULL;
          props = NULL;
          depth = OM_K_MAXINT;
          buff_size = 0;
          sts = om$send(msg = message EMSloopset.EMget_loops
                        (&msg_loc, 0, &depth, &loop_ids, &props, &buff_size,
                         &num_loops),
                        senderid = orig_surf.objid,
                        p_chanselect = &chan_to_loopset);
          EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopsetError,
                       ret_end);

	  /* For each loop in the original surface, generate intobjs
	     corresponding to its edges on the offset surface
	  */
          if(edge_map_list)
          edge_map_list[i]=(GRobjid**)malloc(num_loops*sizeof(GRobjid));

          for(j=0,lpinx=0; j<num_loops; j++,lpinx++)
	  {
#ifdef DEBUG
printf("  Current Loop no. = %d\n", j);
#endif
	    /* Get all the edges in this loop */
            if(edge_map_list)
               edge_map_list[i][lpinx]=NULL;
	    buff_size = num_edges = 0;
	    edges = NULL;
            sts = om$send(msg = message EMSloop.EMget_edges(&msg_loc, 1, 
				EMS_OPT_ALL, &edges, &buff_size, &num_edges),
			  senderid = NULL_OBJID,
			  targetos = orig_surf.osnum,
                          targetid = loop_ids[j]);
            EMerr_hndlr(EMSerror (sts & msg_loc), *msg, EMS_E_LoopError,
                        ret_end);

	    /* Initilalize the per-loop static variables */
	    Current_Loop = loop_ids[j];
	    Loop_Start_Edge = edges[0].objid;
	    Loop_Start_Intobj = NULL;
            prev_common_surface = NULL_OBJID;

	    /* For every edge in Current_Loop generate the corresponding
	       intobj. This intobj will be then positioned 'in-place' in
	       Current_Inters.
	    */
	    for(k=0; k<num_edges; k++)
	    {
	       /* Initialize the per-edge static variables */
	       Current_Edge = edges[k].objid;
	       Common_Edge = NULL_OBJID;
#ifdef DEBUG
printf("    Current_Edge no. = %d\n", k);
#endif
               current_intobj = NULL;


	/* Call function to return all the edge info (props, common edge,
	   comm_edge surface, convex/concave/tangent/special-tangent/free etc
	*/
	       sts = EFget_edge_info(&msg_loc, mattyp, mat, edges[k], &comm_ed,
				     &comm_surf, &ed_props, &is_free, &convex,
				     &neutral, &is_spec_tangent, NULL, 
                                     &ang_meas, &cm_ed_props);
	       EMerr_hndlr(! (1 & sts & msg_loc), *msg,EMS_E_EdgeError,ret_end);

	       if(ed_props & EMED_DEGENERATE)
	       {
	       /* check if edge is a full natural edge. If not move on to
		  next edge. Else continue processing the degenarate natural
		  edge as usual.
	       */
	         EFchk_if_natural(&msg_loc, edges[k], ed_props, FALSE, &ed_nat,
				  &ed_loc);
		 if(!ed_nat) 
                      continue;
	       }

	       Common_Edge = comm_ed.objid;

	       if(is_free)     /* Current_Edge is a free edge */
	       {
	         EFchk_if_natural(&msg_loc, edges[k], ed_props, FALSE, &ed_nat,
				  &ed_loc);
		 if(!ed_nat)
		    EFchk_if_iso(&msg_loc, edges[k], ed_props, &ed_iso);
		 else
                    ed_iso = FALSE;
		 tmp_inters = NULL;
		 if(ed_nat)
		 {
		   current_intobj = EFmkint_from_nat_edge(&msg_loc,
				    ed_nat, FALSE, FALSE, ang_meas, 
                                    ed_props, NULL, ed_loc, NULL, 
                                    &edges[k], NULL, &orig_surf, NULL,
                                    &off_surf, NULL,
				    &sfmdenv.md_env, &tmp_inters);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

		   current_intobj->props |= EMSintobj_tmpmarked;
		 }
                /* Case where 'iso-ness' should be preserved */
                 else if(EFgenerate_an_iso_intobj(&msg_loc, is_free, 
                                           FALSE, ang_meas,
                                           ed_iso, FALSE,
                                           &edges[k], NULL, &orig_surf, 
                                           NULL, &sfmdenv.md_env,no_edges))
                 {
                  IGRboolean is_full;
                  /* 
                     If the num_edges at the right and left end are equal to
                     two then this intobj takes the iso edge which is  exactly
                     of the length of it's corresponding edge in the original
                     surface instead of taking the total iso_curve(u=0 to u=1)
                   */
                  if((no_edges[0] == 2)&&(no_edges[1] == 2))
                  is_full = FALSE;
                  else is_full = TRUE;
#ifdef DEBUG
printf("   Edge is FREE and ISO. Extracting Iso edge\n");
#endif
	        current_intobj = EFmkint_from_iso_edge(&msg_loc,is_full,ed_iso,
				    FALSE, FALSE, &edges[k], NULL, &orig_surf,
                                    &off_surf, NULL, NULL,
				    &sfmdenv.md_env, &tmp_inters);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
		   current_intobj->props |= EMSintobj_isocurve;
                 }
		 else 
		 {
		   EFcvt_edge_to_cv(&msg_loc, NULL, edges[k], &orig_surf, 
                                    &cv_geom, &sfmdenv.md_env);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

/* CRC - Write function to determine the extension required at either end using 
	 info of adjacent edges and surfaces (offset distances)
*/
/* CRC BLOCK START */
		   /* ext_dist[0] = (props[j] & EMLP_EXTERNAL ? 5 * distance :
							   5 * tol);*/
           EFget_intobj_extdist(edges[k].objid,orig_surf.osnum ,props[j],
                                distance,partolb.tol,tol,ext_dist);

/* CRC BLOCK END */
		   current_intobj = EFext_and_prj_cv(&msg_loc, orig_surf, 
						     off_surf, opt, NULL,
						     cv_geom,
						    ed_props & EMED_XYZ_CLOSED ?
						     FALSE : TRUE,
                                                     ext_dist[0],
                                                     ext_dist[1],
						     &sfmdenv.md_env, 
						     &tmp_inters, FALSE, NULL,
						     NULL);
            	   EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
      		   om$dealloc(ptr = cv_geom->poles);
		   om$dealloc(ptr = cv_geom->knots);
		   if(cv_geom->rational) om$dealloc(ptr = cv_geom->weights);
		   om$dealloc(ptr = cv_geom);
		   cv_geom = NULL;
	  	 } /* else of if(ed_nat) */

                 if(ed_props & EMED_XYZ_CLOSED)
                    current_intobj->props |= EMSintobj_xyz_closed;
                 if(ed_props & EMED_DEGENERATE)
                    current_intobj->props |= EMSintobj_xyzdegenerate;
		 EFmerge_with_inters_list(Current_Inters, tmp_inters);
		 EMinters_free(tmp_inters, OM_K_MAXINT);
                 comm_surf.objid = NULL_OBJID;  /* Reset for Free edges */
	       }
	       else   /* Common edge exists */
	       {
                /* This functions checks for already processed surface pairs
                   to help deal with edges split due to seams  */

	          if(seam_affected && Current_Edge != Loop_Start_Edge)
		  {   
		      IGRboolean  add_to_start;
                      if(EFis_this_edge_redundant(&msg_loc,
                                                  prev_common_surface,
                                                  comm_surf.objid, i,
                                                  off_surfs_info,
                                                  k, edges, num_edges,
                                                  &add_to_start))
                      {
                          EFpost_edge_to_intobj_moreinfo(add_to_start, 
                                             		 comm_ed.objid, i,
                                                         off_surfs_info);
#ifdef DEBUG
printf("        Edge connected to prev edge at seam =%d\n", edges[k].objid);
#endif

		/* Current_Edge will not form part of final loop. Continue.
		   If the Current_Edge were tangential to the previously
		   processed edge the previous intobj (Fwd_Connect_Intobj)
		   would have its more_info pointing to the intersection point.
		   This is spurious. Hence deallocate it.
		*/
		          if(Fwd_Connect_Intobj->more_info)
		          {
		             p_pypt = (struct EMSpypoint *) 
				       Fwd_Connect_Intobj->more_info;
		             om$dealloc(ptr = p_pypt);
		             Fwd_Connect_Intobj->more_info = NULL;
		           }
                           continue;
                      }
		  }

		  /* Check if the intobj corresponding to the current edge is
		     available in the avail-list
		  */
		  EFscan_intobj_list(&p_intobj);
		  if(p_intobj)  /* intobj available in Avail_intobjs list */
		  {
#ifdef DEBUG
printf("   Matching intobj found during Scanning\n");
#endif
		    EFextract_intobj_from_list(p_intobj);
		    current_intobj = p_intobj;
		    if(!Loop_Start_Intobj)
           		EFinit_start_intobj(p_intobj);
		    else
	   		EFfwd_connect_intobj(p_intobj);
		  }
                  else if(ed_props & EMED_SEAM) /* current edge is a seam */
                  {
                  /* Check whether seam is deleted */
                    if(!(off_surfs_info[i].props & SEAM_DELETED))
                    {
		    /* Generate the two intobjs on the offset corresponding to
		       the seams
		    */
#ifdef DEBUG
printf("   Surface closed in u/v\n");
#endif
                        tmp_inters = NULL;
                        stat_func =  EFconvert_seam_to_intobjs
                                                 (&msg_loc, off_surf,
                                                 &sfmdenv.md_env,
                                                 &tmp_inters, p_intobjs);
                        EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, 
				     ret_end);

		        /* Determine which of the two seams (U/V = 0 or 1)
			   the Current_Edge corresponds to.
			*/
		        sts = om$send(msg = message EMSedge.EMget_location(
					    &msg_loc, &loc),
				      targetid = edges[k].objid,
				      targetos = edges[k].osnum,
				      senderid = NULL_OBJID);
                        EMerr_hndlr(EMSerror (sts & msg_loc), *msg, 
				    EMS_E_EdgeError, ret_end);

			if(loc == 0 || loc == 2) /* seam is U=0 OR U=1 */
			   this_seam_index = (loc==0 ? 0 : 1);
			else   /* seam is V=0 OR V=1 */
			   this_seam_index = (loc==1 ? 0 : 1);
			other_seam_index = (this_seam_index==0 ? 1 : 0);

                  /* Put the seam intobjs into appropriate lists.
                     Add one int-obj to the inters list and the other to
                     the Avail_Intobjs list.
		  */
                        if(this_seam_index == 1)
                        {
                            tmp_inters->cvs = p_intobjs[1];
                        }
                        p_intobjs[0]->next = NULL;
                        tmp_inters->num_cvs--;

                        EFmerge_with_inters_list(Current_Inters, tmp_inters);
                        EMinters_free(tmp_inters, OM_K_MAXINT);

		        current_intobj = p_intobjs[this_seam_index];
                        EFappend_intobj_to_Avail_list(
						p_intobjs[other_seam_index]);

                    } /* if seam was NOT deleted */
                    else
                    {
/* CRC
	 If the function is successful then the current loop has been merged
	 with the next. So the next loop need not be processed later. Increment
	 j. Also the number of edges in the current loop would have increased.
	 The function should return this. Set num_edges to this value and
	 continue.

	 ASSUMPTION - This has to be the j+1 st loop in loop_ids[] ??
	 Check this out....

	 Document the function.
*/
/* CRC BLOCK START */
                   /* Merge edges from common-seam-edge loop into the
                      current edge list in the proper order. Since we have 
		      merged the current loop with the next loop we need not
	 	      process the next loop later. Hence increment j 
		      (loop index).
		   */
		      GRobjid merged_loop;
                       
                        seam_objid=edges[k].objid;

                      EFmerge_loop_across_seam(&msg_loc, prev_common_surface, 
                                               i, off_surfs_info,
                                               k, &edges, &num_edges,
                                               &merged_loop);
		      EMerr_hndlr((merged_loop != loop_ids[j+1]), *msg,
				   EMS_E_Fail, ret_end); /* Here the assumption
                                                            is that the other
                                                            seam edge is in the
                                                            next loop. So, Error
                                                            Out if it is not.
                                                            TBD.*/
		      j++;
          /*
           * When the Seam_edge is responsible for the loops to be merged
           * cross it, the vertex connecting this Seam and the previos edge
           * (Fwd_Connect_Intobj) may not form the vertex on the resultent
           * offset_surface,So better we leave it for the intobjs to find
           * it's vertex in the EMregen_tpgy rather than sending the proj
           * vertex point here. -Jagan
           */

                      if (Fwd_Connect_Intobj && Fwd_Connect_Intobj->more_info)
                      {
                        om$dealloc (ptr = Fwd_Connect_Intobj->more_info);
                        Fwd_Connect_Intobj->more_info = NULL;
                      }
                      continue; /* to next edge in modified edges list */
/* CRC BLOCK END */
                    } /* end of else of if(NOT seam_deleted) */
                  }
		  else    /* Not a seam. intobj needs to be generated */
		  {
		  /* get the inters node corresponding to comm_surf's offset */
		     for(l=0; l<off_surfs_info[i].num_adj_sfs; l++)
		     {
		       comm_sf_ind = off_surfs_info[i].adj_sfs[l];
		       if(IF_EQ_OBJID(comm_surf.objid, surfs[comm_sf_ind]))
		       {
			 EFget_inters_node(comm_sf_ind, &other_inters);
			 break;
		       }
		     }
		     EMerr_hndlr(!(other_inters), *msg, EMS_E_Fail, ret_end);

	             if(neutral)	/* edge is tangent */
		     {
		        tmp_inters = NULL;

		        /* Check if either edge is a full natural edge */
			EFchk_if_natural(&msg_loc, edges[k], ed_props,
				       is_spec_tangent, &ed_nat, &ed_loc);
	                EFchk_if_natural(&msg_loc, comm_ed, cm_ed_props,
				       is_spec_tangent, &cm_ed_nat, &cm_ed_loc);

                        ed_iso = cm_ed_iso = FALSE;
			if(!ed_nat && !cm_ed_nat)
			{
			  EFchk_if_iso(&msg_loc, edges[k], ed_props, &ed_iso);
			  EFchk_if_iso(&msg_loc, comm_ed, cm_ed_props,
				       &cm_ed_iso);
			}
                        if((fabs(ang_meas - 2.0) <= EMS_ZEROANGLE_DEG)
                                  && (ed_nat || cm_ed_nat))
		 	{
			/* Edges are exactly tangential and atleast one of them
			   is a full natural edge. Hence extract corresponding
			   natural edge onthe offset surface.
			*/
		   	    p_intobjs[0] = EFmkint_from_nat_edge(&msg_loc,
					  ed_nat, cm_ed_nat,
                                          neutral, ang_meas,
                                          ed_props, cm_ed_props,
				  	  ed_loc, cm_ed_loc, 
					  &edges[k], &comm_ed,
                                          &orig_surf, &comm_surf,
                                          &off_surf,
				  	  &other_inters->this_obj,
					  &sfmdenv.md_env, &tmp_inters);
            	   	    EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail,
					ret_end);
		   	    p_intobjs[1] = p_intobjs[0]->other_intobj_node;
			    if(ed_nat)
			      p_intobjs[0]->props |= EMSintobj_tmpmarked;
			    if(cm_ed_nat)
			      p_intobjs[1]->props |= EMSintobj_tmpmarked;
		 	}
                        else if(EFgenerate_an_iso_intobj(&msg_loc, FALSE, 
                                           neutral, ang_meas,
                                           ed_iso, cm_ed_iso,
                                           &edges[k], &comm_ed, &orig_surf, 
                                          &comm_surf, &sfmdenv.md_env,no_edges))
                        {
			/* Edges are exactly tangential and atleast one of them
			   is an Iso  edge whose iso-ness can be preserved
                           in the offset. Hence extract corresponding
			   iso edge on the offset surface.
			*/
#ifdef DEBUG
printf("   Edge is TANGENT and ISO. Extracting Iso edge\n");
#endif
		   	    p_intobjs[0] = EFmkint_from_iso_edge(&msg_loc,
					  TRUE,ed_iso, cm_ed_iso,
					  (ed_props & EMED_REVERSE_CONNECT ?
						     TRUE : FALSE),
				  	  &edges[k], &comm_ed, &orig_surf, 
                                          &off_surf, &comm_surf, 
				  	  &other_inters->this_obj,
					  &sfmdenv.md_env, &tmp_inters);
            	   	    EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail,
					ret_end);
		   	    p_intobjs[1] = p_intobjs[0]->other_intobj_node;
			    if(ed_iso)
			      p_intobjs[0]->props |= EMSintobj_isocurve;
			    if(cm_ed_iso)
			      p_intobjs[1]->props |= EMSintobj_isocurve;
                            if(is_spec_tangent)
                            {
			      p_intobjs[0]->props |= EMSintobj_special_tangent;
			      p_intobjs[1]->props |= EMSintobj_special_tangent;
                            }
                        }
			else
			{
#ifdef DEBUG
printf("   Edge is TANGENT, Extending and projecting edge\n");
#endif
		           EFcvt_edge_to_cv(&msg_loc, NULL, edges[k], 
                                            &orig_surf, &cv_geom,
					    &sfmdenv.md_env);
      	                   EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,
				       ret_end);

/* CRC - Call function to determine extensions at either end */
/* CRC - BLOCK START */
		           p_intobjs[0] = EFext_and_prj_cv(&msg_loc, orig_surf, 
			     off_surf, opt, NULL, cv_geom,
			     ed_props & EMED_XYZ_CLOSED ? FALSE :TRUE,
			     5 * distance, 5 * distance, &sfmdenv.md_env,
			     &tmp_inters, FALSE, NULL, NULL);
      	                   EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,
				       ret_end);
	                   p_intobjs[1] = EFext_and_prj_cv(&msg_loc, comm_surf, 
			     other_inters->this_obj, opt, NULL, cv_geom,
			     ed_props & EMED_XYZ_CLOSED ? FALSE :TRUE,
			     5 * distance, 5 * distance, &sfmdenv.md_env, 
			     &tmp_inters, FALSE, NULL, NULL);
      	                   EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,
				       ret_end);
/* CRC - BLOCK END */
		           if(ed_props & EMED_REVERSE_CONNECT)
			      p_intobjs[1]->reversed = (p_intobjs[1]->reversed ?
						        FALSE : TRUE);
		           p_intobjs[0]->other_intobj_node = p_intobjs[1];
		           p_intobjs[1]->other_intobj_node = p_intobjs[0];
		           p_intobjs[0]->props |= (EMSintobj_unmatched_dat |
					           EMSintobj_tangent);
		           p_intobjs[1]->props |= (EMSintobj_unmatched_dat |
					           EMSintobj_tangent);
      		           om$dealloc(ptr = cv_geom->poles);
		           om$dealloc(ptr = cv_geom->knots);
		           if(cv_geom->rational)
				 om$dealloc(ptr = cv_geom->weights);
		           om$dealloc(ptr = cv_geom);
		           cv_geom = NULL;
			} /* else of if(ang_meas==2.0 && ed_nat || cm_ed_nat) */
		     } /* end if(neutral) */

		     else   /* need to intersect Current_Inters->this_obj and */
		     {      /* other_inters->this_obj to get required intobj  */
		       tmp_inters = NULL;
		       num_inters = 0;
	    	       sf2_data.datatype = EMSdata_object;
	    	       sf2_data.data.object = &other_inters->this_obj;
#ifdef DEBUG
printf("   Computing intobj through EMsfsfint: %ld %ld \n", off_surf.objid,
	   other_inters->this_obj.objid);
#endif
		       sts = om$send(msg = message EMSsurface.EMsfsfint(&msg_loc,
                            mattyp, mat, construct_list, &sf2_data, 
			    &sfmdenv.md_env, world_options, param_options, NULL,
                 	    &num_inters, &tmp_inters, &tmp_inters),
			    senderid = NULL_OBJID,
                     	    targetid = off_surf.objid, 
			    targetos = off_surf.osnum);
		       EMerr_hndlr(!(1 & sts & msg_loc), *msg, EMS_E_Fail, 
				  ret_end);
#ifdef DEBUG
if(!num_inters) printf("csoffset:Error - No intersections returned by sfsfint\n");
#endif
		       EMerr_hndlr(!num_inters, *msg, EMS_E_Fail, ret_end);
		     } /* end else    need to intersect ......    */

   	             p_intobj = (struct EMSintobj *)tmp_inters->cvs;
		     matches = EFintobj_matches_edge(&msg_loc, p_intobj, 
		        Current_Edge, &orig_surf, &partolb, 
			(off_surfs_info[i].distance +
			 off_surfs_info[comm_sf_ind].distance)/2.0, tol, 
		        mattyp, mat, &p_match, NULL, &clos_info);
                     if(matches && (1 & msg_loc))
		     {
		       if(!convex && !neutral)   /* edge is concave */
		       {
		       	   p_match->reversed = 
				    (p_match->reversed ? FALSE : TRUE);
		       	   p_match->other_intobj_node->reversed =
		                    (p_match->other_intobj_node->reversed ? 
				     FALSE : TRUE);
		       }
		       if(clos_info != OPEN)
		       {
			 p_match->props |= EMSintobj_xyz_closed;
			 p_match->other_intobj_node->props |= 
			                  EMSintobj_xyz_closed;
		       }

		      /* Delete all intobjs except the "matching" intobj */
		       p_intobj = (struct EMSintobj *)tmp_inters->cvs;
		       while(p_intobj)
		       {
			  p_intobj_fwd = p_intobj->next;
			  if(p_intobj != p_match) 
			     EMdelintobj(&msg_loc, p_intobj);
			  p_intobj = p_intobj_fwd;
		       }
		       current_intobj = p_match;
		       EFmerge_with_inters_list(Current_Inters, tmp_inters);
		       EFmerge_with_inters_list(other_inters, tmp_inters->next);
		       EMinters_data_free(&msg_loc, tmp_inters, OM_K_MAXINT, 
					  NULL, NULL);
		       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail,ret_end);
		       EMinters_free(tmp_inters, OM_K_MAXINT);
		     }
		     else  /* Edge match failed */
		     {
#ifdef DEBUG
  printf("csoffset:Error - Edge Match Failure\n");
#endif
		       EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);
		     } /* end else Edge match failed */
		  } /* end else     intobj needs to be generated */
	       } /* end else       Common edge exists */
               
/* Free the 'more-info' pointer, pointing to the edge-list linked list */
               EFfree_edgelist_more_info(current_intobj);

/* Check if the right-end vertex of Current_Edge to see if the Current_Edge
   and the next edge are tangential at this vertex. If so, then a check is made
   if there is any other edge incident at this vertex. If not, then this vertex
   is projected on to the intobj just generated on Current_Surface and its
   more_info is made to point to the projected point. This point will be used
   in splitting the intobj while regenerating topology on the surface. Ofcourse
   this check is not needed if the edge is closed in xyz or if it is a seam.
*/
               if(!(ed_props & EMED_XYZ_CLOSED) && !(ed_props & EMED_SEAM))
               {
	         if(EFproj_vert_to_intobj(&msg_loc, &edges[k], (k<num_edges-1 ?
					&edges[k+1] : &edges[0]), is_free,
					&orig_surf, current_intobj,partolb.tol, 
					lentol, &sfmdenv, &p_pypt))
		      current_intobj->more_info = (IGRchar *) p_pypt;
               }
               prev_common_surface = comm_surf.objid;

	    } /* for(k=0; k<num_edges; k++) */

/* All intobjs corresponding to edges of Current_Loop are now
   ready to be integrated with the Current_Inters Node
*/
	    EFarrange_loop_intobjs();
 /***********
      Filling edge_map_list in the same order as that of the
       offset surface edges. This list does not contain the seam edge
       as this edge do not participate in mapping the edges.
       This ensures the correct edge mapping
       of the original and offset surface and thus gives topological
       match ---- V.Srinivas
  **********/


         tmp_num_edges=num_edges;
         if(edge_map_list)
         {
          int index=0;
          edge_map_list[i][lpinx]=(GRobjid *)malloc(num_edges*sizeof(GRobjid));
          for(k=0;k<tmp_num_edges;k++)
          {
            if(edges[k].objid!=seam_objid)
            {
             if(pwIsEdFree(edges[k].objid,edges[k].osnum))
              edge_map_list[i][lpinx][index++]=edges[k].objid;
            }
          }
         }
	    if(edges) om$dealloc(ptr = edges);
	    edges = NULL;
	  } /* for(j=0; j<num_loops; j++) */
	  if(loop_ids) om$dealloc(ptr = loop_ids);
	  if(props) om$dealloc(ptr = props);
	  loop_ids = NULL;
	  props = NULL;
	} /* for(i=0, p_inters=Sf_Inters; i<numsf; .... */

       /* Reset the "tmpmarked" bit for all the intobjs of all the surfaces */
	p_inters = Sf_Inters;
	for(i=0; p_inters; i++, p_inters=p_inters->next)
	{
          EFreset_tmpmark_on_surface_intobjs(p_inters);
        }

/* 3RD STAGE PROCESSING. COPYING TOPOLOGY .... */
ex$message(msgnumb = EMS_S_Processing);

	p_inters = Sf_Inters;
	for(i=0; p_inters; i++, p_inters=p_inters->next)
	{
	  orig_surf.objid = surfs[i];
#ifdef DEBUG
printf("Regenerating topology for Surface = %d\n", off_surfs_info[i].objid);
printf("No. of intobjs in this surface = %d\n", p_inters->num_cvs);
#endif
	  EMregen_tpgy(&msg_loc, &p_inters, orig_surf, construct_list, NULL);
      	  EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
	}
/* TBD: Deallocate the more-info field on each intobj node if it is NON-NULL
26/Mar/93 - Ashok
*/

/* 4TH STAGE PROCESSING. STITCHING SURFACES .... */
ex$message(msgnumb = EMS_S_ProcessingFour);

/* Now each node in the sf_inters list has topology mapped on to its
   corresponding surface ('this_obj' field). We are now ready to create
   a composite surface out of these surfaces.
*/
        cs_grid.osnum = construct_list->env_info->md_id.osnum;
	sts = om$construct(classid = OPP_EMSgencompsf_class_id,
			   p_objid = &cs_grid.objid,
			   osnum = construct_list->env_info->md_id.osnum);
	EMerr_hndlr(! (1 & sts ), *msg, EMS_E_Fail, ret_end);

	jj = OM_K_MAXINT;
        for(i=0; i<numsf; i++)
	   if(off_surfs_info[i].distance == 0.0 &&
	      option & EMS_opt_offsetS_remove_opensfs)
	   {
		sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
				    construct_list->env_info),
			     senderid = NULL_OBJID,
			     targetid = off_surfs_info[i].objid,
			     targetos = off_surf.osnum);
		EMerr_hndlr(!(1 & sts & msg_loc ), *msg, EMS_E_Fail, ret_end);
	   }
	   else
	   {
		sts = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
						   &cs_grid, &jj),
			 senderid = NULL_OBJID,
			 targetid = off_surfs_info[i].objid,
			 targetos = off_surf.osnum);
		EMerr_hndlr(!(1 & sts & msg_loc ), *msg, EMS_E_Fail, ret_end);
	   }

	*constructed_object = cs_grid.objid;
/*
 * End of routine
 */
ret_end:
#ifndef KEEP_SURFS_ON_ERR
        if(EMSerror(*msg))
          for(i=0; i<numsf; i++)
             sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
					 	    construct_list->env_info),
			   senderid = NULL_OBJID,
                           targetid = off_surfs_info[i].objid,
                           targetos = off_surf.osnum);
#else
      if(EMSerror(*msg))
      {
        GRobjid    bad_surface_set, *objects = NULL;
        enum GRdpmode dpmode;

        objects = (GRobjid *) om$malloc(size = numsf * sizeof(GRobjid));
        for(i=0; i<numsf; i++)  objects[i] = off_surfs_info[i].objid;

       /* Make a graphic group of all the offset surfaces and display them */
        sts = ems$build_graphic_group(
                         number_of_objects = numsf,
                                   objects = objects,
                                    construction_args = construct_list,
                                    constructed_object = &bad_surface_set,
                                                msg = &msg_loc);
        dpmode = GRbd;
        sts = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                            &construct_list->env_info->md_env.matrix_type,
                            construct_list->env_info->md_env.matrix,
                            &dpmode,
                            &construct_list->env_info->md_id),
                 senderid = NULL_OBJID,
                 targetid = bad_surface_set,
                 targetos = off_surf.osnum);

        if(objects) om$dealloc(ptr = objects);
      }

#endif
	if(cv_geom)
	{
	   if(cv_geom->poles) om$dealloc(ptr = cv_geom->poles);
	   if(cv_geom->knots) om$dealloc(ptr = cv_geom->knots);
	   if(cv_geom->rational) om$dealloc(ptr = cv_geom->weights);
	   om$dealloc(ptr = cv_geom);
	}
        if(adjsfs_offdists) om$dealloc (ptr = adjsfs_offdists);
	if(off_surfs_info) om$dealloc(ptr = off_surfs_info);
	if(comm_sf_indices) om$dealloc(ptr = comm_sf_indices);
	if(edges) om$dealloc(ptr = edges);
	if(loop_ids) om$dealloc(ptr = loop_ids);
	if(props) om$dealloc(ptr = props);
	if(inters_out)
	   *inters_out = Sf_Inters;
	else
	{
	   EMinters_data_free(&msg_loc, Sf_Inters, OM_K_MAXINT, NULL, NULL);
	   EMinters_free(Sf_Inters, OM_K_MAXINT);
	}
	if(num_comps) *num_comps = numsf;
	if(sf_comps)
	   *sf_comps = surfs;
	else
	   if(surfs) om$dealloc(ptr = surfs);
	return(sts);
}

end implementation EMScompsurf;
