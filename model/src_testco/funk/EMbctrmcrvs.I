class implementation GRcurve;

#include "EMS.h"
/* 
   function for ECtrmcrvele in /usrx/ingr/ems/src_testco/imp/ECtrmcrvele.I

   this file in /usrx/ingr/ems/src_testco/funk/EMbctrmcrvs.I

   Abstract
      Trying to intersect the curves passed in inside the array crv_info and
      then trim them to the intersection points using EMpartofcv.

   Algorithm
	***to be filled in***

   History
	sjv	11/18/87	date of creation
	sjv	02/12/88	initialize pointers used in memory allocation;
				fix bug in discarding points for curves with
				multiple segments
	sjv	02/17/88	modified to process non-intersecting curves;
				also check if all curve segments are connected
        rlw     06/09/89        Modified not to send display parameter of
                                construct list to place part of curve such
                                that existing symbology is used.
        Sudha   07/02/93        Modified for BSprototypes ansification
        dhm     10/21/93        TR 119310591 and added lots of comments.
*/

#include "EMSlogic.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "grerr.h"
#include "msdef.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "EC_S.h"
#include "EMSmsgdef.h"
#include "ECdlb.h"
#include "EMSlcdef.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "msmacros.h"
#include "bstagsort.h"
#include "bsparameters.h"

extern OMuword OPP_GRcompcurve_class_id;
extern IGRdouble fabs();

/* message imports */
from GRcompcurve import EMmakecomp;

IGRlong	EMtrmcrvele(
msg,
crv_info,
const_list,
num_crvs,
num_dup_crvs,
p_compcrv_id)

IGRlong 		*msg;
struct EMScrv_info_sd	*crv_info;
struct GRvg_construct	*const_list;
IGRint 			num_crvs;
IGRint			num_dup_crvs;
GRobjid			*p_compcrv_id;

/*
   Abstract
      Trying to intersect the curves passed in inside the array crv_info and
      then trim them to the intersection points using EMpartofcv.

   Notes
      This function has four major arrays that contain all the information
      needed to do the trim operation.  They are:
          crv_info[]       the input array that has the curves to trim
          crv_seg_info[]   the main thing needed in this array is startix and
                           endix.  These are the indexes to 
                           int_infoix[crv_num][startix/endix].
          int_infoix[][]   this is the ordered array of intersection indexes
                           for each curve. For example, int_infoix[crv][0]
                           contains an index (ind) that is used in 
                           crv_int_info[crv_num][ind].
          crv_int_info[][] this array contains all the intersection point 
                           information needed to trim the curves.  The 
                           important members of this array structure are 
                           other_crvix and other_ptix. other_crvix is the curve
                           that this curve intersects with. other_ptix is the
                           index within the other curve.  For example,
                           crv_int_info[other_crvix][other_ptix] would be the 
                           intersection information for the curve that the 
                           current intersects with.

      You got all that???  It was confusing to me, so I wrote these notes to
      help me(dhm) understand what was going on.  Basically, 
      crv_seg_info[crv_num].startix/endix points to int_infoix[crv_num][?]
      which points to crv_int_info[crv_num][?]. Simple huh?

   History
	sjv	01/20/88 changed to accept composite curves
	sjv	12/30/87 Method converted into function
	sjv	12/07/87 Creation
        dhm     10/21/93 TR 119210591 fixed and added a lot of comments.
        aditya  10/12/95 TR 119420430 Fix for abort.
*/

#define DUMMY_IX	-1 /* dummy index value for end points */

/* EMtrmcrvele warning return status codes */

#define MSTRM_NONINT_CRV	201	/* curve non-intersecting with other curves */
#define MSTRM_DISJNT_CRV	203	/* curve unconnected (disjoint) with other curves */
#define MSTRM_AMBIG_CRV		205	/* curve segment ambiguous */
#define MSTRM_INVMULT_CRV	207	/* error in input, curve disjoint */

/* macro to allocate or reallocate memory & check for Memory Over */

#define MEM_ALLOC( data_ptr, data_type, num, error_exit )\
if (!data_ptr)	\
 data_ptr = (data_type *) om$malloc( size = (num * sizeof(data_type)));	\
else	\
 data_ptr = (data_type *) om$realloc( ptr = (char *)data_ptr, size = (num * sizeof(data_type)));	\
/* check for error in (re)allocation, if any */ \
if (!data_ptr)	\
{	\
 *msg = MSNOMEM;	\
 status = OM_E_ABORT;	\
 goto error_exit;	\
}
/* MEM_ALLOC */

/* macro to deallocate memory */

#define MEM_DEALLOC(data_ptr) \
if (data_ptr) om$dealloc( ptr = (char *)data_ptr )


{
	enum seg_stat_ed	 {
		HAVE_NONE, HAVE_START, HAVE_END, HAVE_BOTH 								};
	struct crv_seg_info_sd {
		enum seg_stat_ed	seg_stat;	/* segment status */
		IGRint		crvint_num, 	/* total number of intersection points for the curve */
		remint_num, 	/* remaining number of intersections */
		startix,
                endix;		/* start & end intersection point indices */
	};

	struct crv_int_info_sd {
		IGRint	other_crvix, /* array index for other curve */
		other_ptix, 	/* array index for point on other curve */
		int_objix;	/* channel index for curve having intersection point */
		struct GRparms int_parms;
	};

	struct EMScrv_info_sd	*p_crv_info;

	/* intersection pts. info. for the different curves */
	struct crv_int_info_sd **crv_int_info,
	*p_crv_int_info1,
	*p_crv_int_info2;

	struct crv_seg_info_sd *crv_seg_info,
	*p_crv_seg_info;

	IGRdouble	 * int_par_info, 	/* intersection parameter value
						used only for sorting */
	next_int_par, /* for checking points with same parameter value in case
			of multiple input */
	loc_pt_par,	/* located point parameter value */
	other_int_par,
	int_par,	/* used in discarding multiple points */
	seg_start_par1,
	seg_start_par2,
	seg_end_par1,
	seg_end_par2,	/* for comparing segment parameter values */
	par_tol;	/* tolerance value for comparing parameter values */

	IGRint		 * *int_infoix, /* index to intersection info. sorted in
					ascending order of parametric value */
	*p_int_infoix1,
	*p_int_infoix2;

	IGRlong	pnt_slots = 0, 	/* no preallocation for point info. */
	crv_slots = 0, 	/* no preallocation for curve overlap info. */
	num_ovr, 	/* number of overlaps */
	err_crv_num;	/* for EMmakecomp error curve number */

	struct GRparms *my_pnt_inters,
	*other_pnt_inters, /* parametric info. for the intersection points */
	start_parms,
	end_parms;	/* for EMpartofcv method */


	struct GRid crv_id1, crv_id2,
	leaf_id;
	GRobjid  pcrv_id; /* for returning part of curve id */

	IGRlong		crvcrvint_num; 	/* number of intersections */
	IGRint		rem_crvs, /* remaining curves to be processed */
			rem_dup_crvs, /* remaining duplicate curves to be processed */
	conn_crvs, /* number of connected curves */
	num_segs, /* effective number of segments */
	alloc_totnum, 	/* total number of data structures
					   to be allocated */
	remint_num, 	/* number of intersections remaining after discarding */
	crv_num1,
	    crv_num2, /* curve number */
	dup_crv_num, 	/* duplicate curve number */
	start_crv_num = 0, /* for making composite curve */
	crvix1,
	    crvix2,
	    int_num1,
	    int_num2, /* intersection number */
	other_crv_num,
	other_int_num, /* for discarding points */
	iter_cnt,
	    iter_cnt_max, 	/* maximum no. of passes to determine curve
				   segments for trimming */
	intix, /* index to intersection point info */
	seg_startix1,
	    seg_endix1,
	    seg_startix2,
	    seg_endix2,
	next_segix, /* used in discarding multiple points */
	    next_crv_segix = 0,
		start_crv_segix = 0, /* for making composite curve */
	    i;	/* for loop index variables */

	enum seg_stat_ed	seg_stat;	/* segment status */

	IGRboolean	is_start,
	    is_end,
	    is_closed, /* curve physically closed ? */
	is_crv_nonint, /* non-intersecting curve ? */
	is_crv_invmult, /* invalid multiple input for curve ? */
	is_crv_disjnt, /* disjoint (unconnected) resultant curve ? */
	is_crv_ambig, /* curve segment ambiguous ? */
	is_crv_discard, /* curve discarded ? */
	is_compcurve1,
	    is_compcurve2, 	/* for curve1 and curve2 */
	bs_status;

	IGRlong	bs_rc,
	    status = OM_S_SUCCESS;

	struct GRmd_env *p_md_env;
	struct GRmdenv_info mdenv_info;

	struct GRlc_info *p_lc_info; /* for EMmakecomp */
	GRspacenum	md_osnum; /* module object space number */

	OMuint			index, /* for object index */
	chan_count; /* for om$get_channel_count */
	OMuword                 class_id;
	OM_S_CHANSELECT         to_comps;
        struct GRvg_construct	*p_const_list, construct_list;
        IGRint                  start_int_objix1, start_int_objix2,
                                end_int_objix1, end_int_objix2;

	/*******************************************************************/
	/*			end of declarations			   */
	/*******************************************************************/

	/* initialise */
	*msg = MSSUCC;
	(void)BSEXTRACTPAR(msg, BSTOLPARAM, par_tol);
	is_crv_disjnt = FALSE;
	is_crv_nonint = FALSE;
	is_crv_ambig = FALSE;
	is_crv_invmult = FALSE;
        p_const_list = &construct_list;
        construct_list = *const_list;
        construct_list.display = NULL;
	/* initialize pointers used for allocating memory */
	int_par_info = NULL;
	int_infoix = NULL;
	my_pnt_inters = NULL;
	other_pnt_inters = NULL;
	crv_seg_info = NULL;
	crv_int_info = NULL;
	p_lc_info = NULL;

	iter_cnt_max = num_crvs * num_crvs;

	status = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
	EMomerr_hndlr( status, wrapup, "EMtrmcrvele : EMmake_chanselect" );


	p_md_env = p_const_list ->env_info;
	mdenv_info = p_md_env ->md_env;

	md_osnum = p_md_env ->md_id.osnum;

	/* allocate crv_seg_info */
	MEM_ALLOC( crv_seg_info, struct crv_seg_info_sd, num_crvs, wrapup );

	/* allocate memory for crv_int_info array pointers */
	MEM_ALLOC( crv_int_info, struct crv_int_info_sd * ,
	    num_crvs, wrapup);

	/* allocate memory for array of pointers : int_infoix */
	MEM_ALLOC( int_infoix, IGRint * , num_crvs, wrapup );

	/* initialise array values */
	for ( i = 0; (i < num_crvs); ++i ) {
		crv_int_info[ i ] = NULL;

		int_infoix[ i ] = NULL;

		p_crv_info = &crv_info[ i ];
		p_crv_seg_info = &crv_seg_info[ i ];
		/* initialise curve segment info */
		status = om$get_classid(objid = p_crv_info ->crv_id,
		    osnum = md_osnum,
		    p_classid = &class_id);
		EMomerr_hndlr( status, wrapup, "EMtrmcrvele : om$get_classid" );

		if (class_id IS OPP_GRcompcurve_class_id) {
			status = om$get_channel_count(objid = p_crv_info ->crv_id,
			    osnum = md_osnum,
			    p_chanselect = &to_comps,
			    count = &chan_count);
			EMomerr_hndlr( status, wrapup, "EMtrmcrvele : om$get_channel_count" );

			p_crv_info ->chan_count = chan_count;
			leaf_id = p_crv_info ->loc_pt_prj_parms.leaf_id;
			/* get index for curve having locate point */
			status = om$get_index( osnum_c = md_osnum,
			    objid_c = p_crv_info ->crv_id,
			    p_chanselect = &to_comps,
			    objid = leaf_id.objid,
			    osnum2 = leaf_id.osnum,
			    indexaddr = &index);
			EMomerr_hndlr( status, wrapup, "EMtrmcrvele : om$get_index" );
			p_crv_info ->loc_objix = index;

		} else {
			/* not a composite curve */
			p_crv_info ->chan_count = 0;
			p_crv_info ->loc_objix = 0;
		};
		p_crv_seg_info ->crvint_num = 0;
		p_crv_seg_info ->seg_stat = HAVE_NONE;
		p_crv_seg_info ->startix = 0;
		p_crv_seg_info ->endix = 0;
	};

	/* find the points of intersection.
         * Intersect each curve with all the other curves. For example,
         * intersect 1st curve with all the other curves passed in; then
         * intersect 2nd curve will 3rd one and on down, etc.
         */

	for ( crv_num1 = 0; (crv_num1 < (num_crvs - 1)); ++crv_num1 ) {
		crv_id1.objid = crv_info[ crv_num1 ].crv_id;
		crv_id1.osnum = md_osnum;
		is_compcurve1 = (crv_info[ crv_num1 ].chan_count > 0);

		dup_crv_num = crv_info[ crv_num1 ].dup_crvix;
		for ( crv_num2 = crv_num1 + 1; (crv_num2 < num_crvs); ++crv_num2 ) {
			if (crv_info[ crv_num2 ].dup_crvix IS dup_crv_num)
				continue; /* same curve */
			crv_id2.objid = crv_info[ crv_num2 ].crv_id;
			crv_id2.osnum = md_osnum;
			is_compcurve2 = (crv_info[ crv_num2 ].chan_count > 0);

			crvcrvint_num = 0; /* initialize grand_num_pnt for EMcrvcrvint */
			status = om$send( mode = OM_e_wrt_object,
			    msg = message GRcurve.EMcrvcrvint(
			    msg, 	/* *msg */
			NULL, 		/* *cnst_list */
			&mdenv_info, 	/* *my_objenv */
			NULL, 		/* *other_curve */
			&crv_id2, 	/* *other_obj */
			&mdenv_info, 	/* *other_objenv */
			NULL, 		/* inter_options */
			&pnt_slots, 	/* *pnt_slots */
			&crvcrvint_num, 	/* *grand_num_pnt */
			NULL, 		/* **pnt_ids */
			&my_pnt_inters, 	/* **my_pnt_inters */
			&other_pnt_inters, /* **other_pnt_inters */
			NULL, 		/* **inter_pnts_xyz */
			&crv_slots, 	/* *crv_slots */
			&num_ovr, 	/* *grand_num_crv */
			NULL, 		/* **crv_ids */
			NULL, 		/* **my_crv_inters */
			NULL		/* **other_crv_inters */
			),
			    senderid = NULL_OBJID,
			    targetid = crv_id1.objid,
			    targetos = crv_id1.osnum);
			if (EMSmsgReport( status, "EMtrmcrvele : GRcurve.EMcrvcrvint", FALSE) )
				goto wrapup;

			if (NOT(crvcrvint_num))
				continue; /* skip the loop if no intersection found */

			/* allocate memory for saving the info */
			alloc_totnum = crv_seg_info[ crv_num1 ].crvint_num + crvcrvint_num;

			MEM_ALLOC( crv_int_info[ crv_num1 ], struct crv_int_info_sd, alloc_totnum, wrapup );

			alloc_totnum = crv_seg_info[ crv_num2 ].crvint_num + crvcrvint_num;

			MEM_ALLOC( crv_int_info[ crv_num2 ], struct crv_int_info_sd, alloc_totnum, wrapup );

			/* save intersection parametric information */
			for (i = 0,
			    crvix1 = crv_seg_info[ crv_num1 ].crvint_num,
			    crvix2 = crv_seg_info[ crv_num2 ].crvint_num; 

			    (i < crvcrvint_num); 

			    ++i,
			    ++crvix1,
			    ++crvix2 ) {

				/* save curve1 info
                                 * Intersection info. for each curve
                                 */

                                p_crv_int_info1 = crv_int_info[ crv_num1 ] + crvix1;
				p_crv_int_info1 ->int_parms = my_pnt_inters[ i ];
                                /* Curve index intersected with and
                                 * index to the crv_int_info on curve 
                                 * intersected with. 
                                 * crv_int_info[other_crvix][other_ptix]
                                 */
				p_crv_int_info1 ->other_crvix = crv_num2;
				p_crv_int_info1 ->other_ptix = crvix2;
				if ( is_compcurve1 ) {
					leaf_id = my_pnt_inters[ i ].leaf_id;
					/* get index for curve having intersection point */
					status = om$get_index( osnum_c = md_osnum,
					    objid_c = crv_id1.objid,
					    p_chanselect = &to_comps,
					    objid = leaf_id.objid,
					    osnum2 = leaf_id.osnum,
					    indexaddr = &index);
					EMomerr_hndlr( status, wrapup, "EMtrmcrvele : om$get_index" );
					p_crv_int_info1 ->int_objix = index;
				} else
					p_crv_int_info1 ->int_objix = 0;

				/* save curve2 info */
				p_crv_int_info1 = crv_int_info[ crv_num2 ] + crvix2;
				p_crv_int_info1 ->int_parms = other_pnt_inters[ i ];
				p_crv_int_info1 ->other_crvix = crv_num1;
				p_crv_int_info1 ->other_ptix = crvix1;
				if ( is_compcurve2 ) {
					leaf_id = other_pnt_inters[ i ].leaf_id;
					/* get index for curve having intersection point */
					status = om$get_index( osnum_c = md_osnum,
					    objid_c = crv_id2.objid,
					    p_chanselect = &to_comps,
					    objid = leaf_id.objid,
					    osnum2 = leaf_id.osnum,
					    indexaddr = &index);
					EMomerr_hndlr( status, wrapup, "EMtrmcrvele : om$get_index" );
					p_crv_int_info1 ->int_objix = index;
				} else
					p_crv_int_info1 ->int_objix = 0;
			};

			crv_seg_info[ crv_num1 ].crvint_num += crvcrvint_num;
			crv_seg_info[ crv_num2 ].crvint_num += crvcrvint_num;
		}; /* crv_num2 for */
	}; /* crv_num1 for */

       /*** Finished intersection all the curves.  ***/


	rem_crvs = num_crvs;

	/* test for non-intersecting curves, if any */

	for ( crv_num1 = 0; (crv_num1 < num_crvs); ++crv_num1 ) {
		crvcrvint_num = crv_seg_info[ crv_num1 ].crvint_num;
		crv_seg_info[ crv_num1 ].remint_num = crvcrvint_num;
		if ( crvcrvint_num IS 0 ) {
			is_crv_disjnt = TRUE;
			crv_info[ crv_num1 ].crv_stat = CRV_DISJNT;
			--rem_crvs;
		} else
			crv_info[ crv_num1 ].crv_stat = CRV_OK;
	};

	if (rem_crvs IS 0) {
		is_crv_nonint = TRUE;
		goto wrapup;
	};

	/* sort the points in ascending order of the parametric value */

	for ( crv_num1 = 0; (crv_num1 < num_crvs); ++crv_num1 ) {
		p_crv_info = &crv_info[ crv_num1 ];
		if (p_crv_info -> crv_stat IS CRV_DISJNT)
			/* skip non-intersecting curves */
			continue;
		p_crv_seg_info = &crv_seg_info[ crv_num1 ];
		crvcrvint_num = p_crv_seg_info ->crvint_num;
		p_crv_int_info1 = crv_int_info[ crv_num1 ];

		/* allocate memory for the index array */
		MEM_ALLOC( int_infoix[ crv_num1 ], IGRint, crvcrvint_num, wrapup );
		/* allocate memory for int_par_info  */
		MEM_ALLOC( int_par_info, IGRdouble, crvcrvint_num, wrapup);

		if (crvcrvint_num IS 1) {
			/* only one point of intersection, no sorting necessary */
			*int_infoix[ crv_num1 ] = 0;
			int_par_info[ 0 ] = p_crv_int_info1 ->int_objix + 
			    p_crv_int_info1 ->int_parms.u;
		} else {
			for ( i = 0; ( i < crvcrvint_num ); ++i ) {
				int_par_info[ i ] = p_crv_int_info1 ->int_objix + 
				    p_crv_int_info1 ->int_parms.u;
				++p_crv_int_info1;
			};

			/* sort intersection points parametric info.
                         * Gives you the sorted index array to the 
                         * curve's intersection information array.
                         */

			bs_status = BStagsort( &bs_rc, 		/* *rc */
			(IGRint *)&crvcrvint_num, 	/* *num_values */
			int_par_info, 	/* *values */
			int_infoix[ crv_num1 ]);	/* *subs */

			if (( NOT bs_status ) OR ( bs_rc ISNT BSSUCC )) {
				*msg = MSFAIL;
				status = OM_E_ABORT;
				goto wrapup;
			};
		};

		/* Now, get the segment identified by the user */

                /*
                 * There is an array of intersection parameter information
                 * on each curve. Next, there is an array of ordered indexes 
                 * to these parameters. So the startix is the index to the
                 * index array that tells the start parameter (low value)
                 * of the section of the curve the user wants. Next, endix
                 * is the index to the index array that tells the ending
                 * parameter (high value) of the section the user wants.
                 * So the portion the user wants is between startix and endix.
                 * startix = start index to int_infoix[crv][?]
                 * endix = end index to int_infoix[crv][?]
                 * int_infoix = ordered index array to crv_int_info[crv][?]
                 * crv_int_info[][] = array of intersection parameter info.
                 */

		is_closed = p_crv_info ->phy_closed;
		loc_pt_par = p_crv_info ->loc_pt_prj_parms.u + 
		    p_crv_info ->loc_objix;

		/* segment start point ix */
		int_num1 = 0;
		p_int_infoix1 = int_infoix[ crv_num1 ];
		intix = *p_int_infoix1;
		while ( loc_pt_par > int_par_info[ intix ] ) {
			++int_num1; /* next intersection point */
			if (int_num1 < crvcrvint_num)
				intix = *(++p_int_infoix1);
			else
				break;
		};

		if ( int_num1 IS 0 ) {
			if (is_closed)
				/* closed curve, wraparound to last point */
				p_crv_seg_info ->startix = crvcrvint_num - 1;
			else {
				/* start point of the curve is start point of
                                 * the segment.
                                 * This means you are taking the portion of the
                                 * curve from par=0 to the 1st intersection
                                 * point.  DUMMY_IX is also used to mean that
                                 * the index you are using isn't in the index 
                                 * array. It's a 0 for the start par. and a 1
                                 * for the end par. Later, it is used to mean
                                 * that this isn't the intersection index you
                                 * want - as is the case with duplicate curves.
                                 */

				p_crv_seg_info ->startix = DUMMY_IX;
				p_crv_seg_info ->seg_stat = HAVE_START;
			};
		} else
			/* save previous point index as start point ix */
			p_crv_seg_info ->startix = int_num1 - 1;

		/* segment end point ix */
		p_int_infoix1 = int_infoix[ crv_num1 ] + crvcrvint_num - 1;
		intix = *p_int_infoix1;
		int_num1 = crvcrvint_num;
		while ( loc_pt_par < int_par_info[ intix ] ) {
			--int_num1; /* previous intersection point */
			if (int_num1 > 0)
				intix = *(--p_int_infoix1);
			else
				break;
		};

		if ( int_num1 IS crvcrvint_num ) {
			if (is_closed)
				/* closed curve, wraparound to first point */
				p_crv_seg_info ->endix = 0;
			else {
				/* end point of the curve is end point of the
                                 * segment.
                                 * This means you are taking the portion from
                                 * the last intersection par to par = 1.
                                 */

				p_crv_seg_info ->endix = DUMMY_IX;
				p_crv_seg_info ->seg_stat = HAVE_END;
			};
		} else
			p_crv_seg_info ->endix = int_num1;
	};

	/* now identify the segment for trimming the curve element */
	num_segs = rem_crvs;

	if (num_dup_crvs) {
		rem_dup_crvs = num_dup_crvs;
		/* check for connected segments; also check for duplicate segments */
		for ( crv_num1 = 0; (crv_num1 < (num_crvs - 1)); ++crv_num1 ) {
			if (crv_info[ crv_num1 ].crv_stat IS CRV_DISJNT)
				/* skip non-intersecting curves */
				continue;

			seg_startix1 = crv_seg_info[ crv_num1 ].startix;
			seg_endix1 = crv_seg_info[ crv_num1 ].endix;
			p_crv_int_info1 = crv_int_info[ crv_num1 ];
			p_int_infoix1 = int_infoix[ crv_num1 ];

                        /*
                         * 119310591 - added start_int_objix1, end_int_objix1,
                         * start_int_objix2, end_int_objix2 to the code to
                         * check to see if the parameters are on the same
                         * component of a composite curve.  dhm 10/21/93.
                         */
			if (seg_startix1 IS DUMMY_IX)
                        {
                                start_int_objix1 = DUMMY_IX;
				seg_start_par1 = 0;
                        }
			else
                        {
                                start_int_objix1 = (p_crv_int_info1 +
                                   *(p_int_infoix1 + seg_startix1))->int_objix;

				seg_start_par1 = (p_crv_int_info1 +
                                *(p_int_infoix1 + seg_startix1))->int_parms.u;
                        }

			if (seg_endix1 IS DUMMY_IX)
                        {
                                end_int_objix1 = DUMMY_IX;
				seg_end_par1 = 1;
                        }
			else
                        {
                                end_int_objix1 = (p_crv_int_info1 +
                                   *(p_int_infoix1 + seg_endix1))->int_objix;

				seg_end_par1 = (p_crv_int_info1 +
				*(p_int_infoix1 + seg_endix1))->int_parms.u;
                        }

                        /*
                         * Looking for duplicate curves that need to be 
                         * discarded. Discard if the duplicate curve
                         * intersects at the same point as crv_num1; if the
                         * start intersection point of crv_num1 is the same as
                         * the end intersection point of crv_num2; or if the
                         * end intersection point of crv_num1 is the same as 
                         * the start intersection point of crv_num2.
                         */

			dup_crv_num = crv_info[ crv_num1 ].dup_crvix;
			for ( crv_num2 = (crv_num1 + 1); (crv_num2 < num_crvs); ++crv_num2 ) {
				if ((crv_info[ crv_num2 ].crv_stat IS CRV_DISCARD) OR
				    (crv_info[ crv_num2 ].crv_stat IS CRV_DISJNT) OR
				    (crv_info[ crv_num2 ].dup_crvix ISNT dup_crv_num))
					/* skip discarded & non-intersecting curves,
					   look for copy of curve */
					continue;

				/* duplicate curve */

				is_crv_discard = FALSE;
				seg_startix2 = crv_seg_info[ crv_num2 ].startix;
				seg_endix2 = crv_seg_info[ crv_num2 ].endix;
				p_crv_int_info2 = crv_int_info[ crv_num2 ];
				p_int_infoix2 = int_infoix[ crv_num2 ];

				if (seg_startix2 IS DUMMY_IX)
                                {
                                        start_int_objix2 = DUMMY_IX;
					seg_start_par2 = 0;
                                }
				else
                                {
                                        start_int_objix2 = (p_crv_int_info2 +
                                        *(p_int_infoix2 + seg_startix2))->int_objix;

					seg_start_par2 = (p_crv_int_info2 +
                                        *(p_int_infoix2 + seg_startix2)) -> int_parms.u;
                                }

				if (seg_endix2 IS DUMMY_IX)
                                {
                                        end_int_objix2 = DUMMY_IX;
					seg_end_par2 = 1;
                                }
				else
                                {
                                        end_int_objix2 = (p_crv_int_info2 +
                                        *(p_int_infoix2 + seg_endix2))->int_objix;

					seg_end_par2 = (p_crv_int_info2 +
					*(p_int_infoix2 + seg_endix2)) -> int_parms.u;
                                }

				/* check if same segment */
				if ((fabs(seg_start_par1 - seg_start_par2) < par_tol) AND
				    (fabs(seg_end_par1 - seg_end_par2) < par_tol) AND
                                    (start_int_objix1 IS start_int_objix2) AND
                                    (end_int_objix1 IS end_int_objix2))
					/* ignore curve */
					is_crv_discard = TRUE;
				else {
					/* check for contiguous segments */
					is_closed = crv_info[ crv_num2 ].phy_closed;
					crvcrvint_num = crv_seg_info[ crv_num2 ].crvint_num;
					remint_num = crv_seg_info[ crv_num2 ].remint_num;
					if (fabs(seg_start_par1 - seg_end_par2) < par_tol) {
						is_crv_discard = TRUE;
						/* discard segment end &
						   other intersection points, if any */
						int_par = seg_end_par1;
						do {
							other_crv_num = (p_crv_int_info2 + *(p_int_infoix2 + seg_endix2)) ->other_crvix;
							other_int_num = (p_crv_int_info2 + *(p_int_infoix2 + seg_endix2)) ->other_ptix;
							if (other_int_num ISNT DUMMY_IX) {
								--remint_num;
								(crv_int_info[other_crv_num] + other_int_num) ->other_ptix = DUMMY_IX;
							};
							++seg_endix2;
							if (seg_endix2 IS crvcrvint_num)
								if (is_closed)
									/* wrap around */
									seg_endix2 = 0;
								else {
									seg_endix2 = DUMMY_IX;
									break;
								};
							seg_end_par2 = (p_crv_int_info2 +
								*(p_int_infoix2 + seg_endix2)) -> int_parms.u;

						} while (NOT(fabs(int_par - seg_end_par2) < par_tol));
						crv_seg_info[ crv_num2 ].endix = seg_endix2;
						if (seg_endix2 IS DUMMY_IX)
							crv_seg_info[ crv_num2 ].seg_stat = HAVE_END;
					} else if (fabs(seg_end_par1 - seg_start_par2) < par_tol) {
						is_crv_discard = TRUE;
						/* discard segment start &
						   other intersection points, if any */
						int_par = seg_start_par1;
						do {
							other_crv_num = (p_crv_int_info2 + *(p_int_infoix2 + seg_startix2)) ->other_crvix;
							other_int_num = (p_crv_int_info2 + *(p_int_infoix2 + seg_startix2)) ->other_ptix;
							if (other_int_num ISNT DUMMY_IX) {
								--remint_num;
								(crv_int_info[other_crv_num] + other_int_num) ->other_ptix = DUMMY_IX;
							};
							--seg_startix2;
							if (seg_startix2 < 0)
								if (is_closed)
									/* wrap around */
									seg_startix2 = crvcrvint_num - 1;
								else {
									seg_startix2 = DUMMY_IX;
									break;
								};
							seg_start_par2 = (p_crv_int_info2 +
								*(p_int_infoix2 + seg_startix2)) -> int_parms.u;

						} while (NOT(fabs(int_par - seg_start_par2) < par_tol));
						crv_seg_info[ crv_num2 ].startix = seg_startix2;
						if (seg_startix2 IS DUMMY_IX)
							crv_seg_info[ crv_num2 ].seg_stat = HAVE_START;
					};
					crv_seg_info[ crv_num2 ].remint_num = remint_num;
					if (remint_num IS 0) {
						/* disjoint curve */
						--num_segs;
						--rem_crvs;
						crv_info[ crv_num2 ].crv_stat = CRV_DISJNT;
						is_crv_invmult = TRUE;
					};
				};
				if (is_crv_discard) {
					crv_info[ crv_num1 ].crv_stat = CRV_DISCARD;
					crv_seg_info[ crv_num1 ].remint_num = 0;
					--num_segs;
					--rem_crvs;
					/* discard intersection points on curve */
					crvcrvint_num = crv_seg_info[ crv_num1 ].crvint_num;
					for ( i = 0; (i < crvcrvint_num); ++i ) {
						other_crv_num = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_crvix;
						other_int_num = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_ptix;
						if (other_int_num IS DUMMY_IX)
							continue;
						(crv_int_info[other_crv_num] + other_int_num) ->other_ptix = DUMMY_IX;
					};
					--rem_dup_crvs;
					break; /* break from crv_num2 for loop */
				};
			}; /* for crv_num2 */
		if (rem_dup_crvs IS 0)
			break; /* all duplicate curves processed */
		}; /* for crv_num1 */
	}; /* num_dup_crvs */

	if (is_crv_invmult)
		goto wrapup;

        /*
         * This section of code is trying to figure out which segment each
         * intersection point really lies on. This can get tricky with all the
         * duplicate curves that are passed in every time a different segment
         * on a curve is identified. crv_seg_info[][].seg_stat, startix, and
         * endix gets set for the final time here.  The main for loop may get
         * executed more than once.  It continues to go thru the curves until
         * it finds each one's true start and end index or else it is an 
         * error - ambiguous condition.
         */

	iter_cnt = 0;
	while ( ( rem_crvs > 0) AND (iter_cnt < iter_cnt_max) ) {
		for ( crv_num1 = 0; (crv_num1 < num_crvs); ++crv_num1 ) {
			p_crv_seg_info = &crv_seg_info[ crv_num1 ];
			seg_stat = p_crv_seg_info ->seg_stat;

			if (( seg_stat IS HAVE_BOTH ) OR
			    (crv_info[ crv_num1 ].crv_stat IS CRV_DISJNT) OR
			    (crv_info[ crv_num1 ].crv_stat IS CRV_DISCARD))
				continue; /* next curve */

			++iter_cnt;
			is_closed = crv_info[ crv_num1 ].phy_closed;
			crvcrvint_num = p_crv_seg_info ->crvint_num;
			remint_num = p_crv_seg_info ->remint_num;
			p_crv_int_info1 = crv_int_info[ crv_num1 ];
			p_int_infoix1 = int_infoix[ crv_num1 ];
			seg_startix1 = p_crv_seg_info ->startix;
			seg_endix1 = p_crv_seg_info ->endix;

			if ( seg_stat ISNT HAVE_START ) { /* identify segment start point */
                                /* intersection index on 1st curve */
				int_num1 = *(p_int_infoix1 + seg_startix1);

                                /* intersection indexes for the 2nd curve */
				int_num2 = (p_crv_int_info1 + int_num1) ->other_ptix;
				crv_num2 = (p_crv_int_info1 + int_num1) ->other_crvix;
				while ((int_num2 IS DUMMY_IX) AND
				      (remint_num > 0) ) {
					/* ignore discarded points */
					--remint_num;
					if (seg_startix1 IS 0) {
						if (is_closed)
							/* closed curve, wraparound to last point */
							seg_startix1 = crvcrvint_num - 1;
						else
							/* open curve, end of loop */
							break;
					} else
						--seg_startix1;
					int_num1 = *(p_int_infoix1 + seg_startix1);
					crv_num2 = (p_crv_int_info1 + int_num1) ->other_crvix;
					int_num2 = (p_crv_int_info1 + int_num1) ->other_ptix;
				};
				if ((remint_num IS 0) OR
				    (is_closed AND (remint_num IS 1))) {
					/* disjoint curve */
					is_crv_disjnt = TRUE;
					crv_info[ crv_num1 ].crv_stat = CRV_DISJNT;
					p_crv_seg_info ->remint_num = 0;
					--rem_crvs;
					--num_segs;
					continue; /* end of for loop */
				};
				if ( (seg_startix1 IS 0) AND (int_num2 IS DUMMY_IX) ) {
					/* start point of the curve is start point of the segment */
					seg_startix1 = DUMMY_IX;
					if (seg_stat IS HAVE_NONE)
						seg_stat = HAVE_START;
					else
						seg_stat = HAVE_BOTH;
				} else {

					/* check if corresponding point on other curve is selected */

					seg_startix2 = crv_seg_info[ crv_num2 ].startix;
					seg_endix2 = crv_seg_info[ crv_num2 ].endix;
					p_crv_int_info2 = crv_int_info[ crv_num2 ];
					p_int_infoix2 = int_infoix[ crv_num2 ];

                                        /* 119310591 - added int_objix */
					other_int_par = (p_crv_int_info2 + int_num2) -> int_parms.u + (p_crv_int_info2 + int_num2)->int_objix;

					if ( seg_startix2 IS DUMMY_IX)
						is_start = FALSE;
					else {
                                                /* 119310591 - added int_objix */
						seg_start_par2 = (p_crv_int_info2 +
							*(p_int_infoix2 + seg_startix2)) -> int_parms.u + (p_crv_int_info2 + *(p_int_infoix2 + seg_startix2))->int_objix;

						/*is_start = ( int_num2 IS * (int_infoix[crv_num2] + seg_startix2) );*/
						is_start = (fabs(other_int_par - seg_start_par2) < par_tol);
					};
					if ( seg_endix2 IS DUMMY_IX )
						is_end = FALSE;
					else {
                                                /* 119310591 - added int_objix */
						seg_end_par2 = (p_crv_int_info2 +
							*(p_int_infoix2 + seg_endix2)) -> int_parms.u + (p_crv_int_info2 + *(p_int_infoix2 + seg_endix2))->int_objix;

						/*is_end = ( int_num2 IS * (int_infoix[crv_num2] + seg_endix2) );*/
						is_end = (fabs(other_int_par - seg_end_par2) < par_tol);
					};

					if ( is_start OR is_end ) { /* segment start point on curve1 identified */
						if (seg_stat IS HAVE_NONE)
							seg_stat = HAVE_START;
						else
							seg_stat = HAVE_BOTH;
						if (NOT(is_closed))
							/* segment start point identified,
							   discard points of intersection before start point */
							for ( i = (seg_startix1 - 1); (i >= 0); --i ) {
								/* discard point */
								crv_num2 = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_crvix;
								int_num2 = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_ptix;
								if (int_num2 IS DUMMY_IX)
									continue;
								--remint_num;
								(crv_int_info[crv_num2] + int_num2) ->other_ptix = DUMMY_IX;
							};
					} else {
						/* check for points with same par. value */
						if (seg_startix1 > 0) {
							next_segix = seg_startix1;
							do {
								/* skip discarded points, if any */
								--next_segix;
								other_int_num = (p_crv_int_info1 +
									*(p_int_infoix1 + next_segix)) -> other_ptix;
							} while ((other_int_num IS DUMMY_IX) AND
								(next_segix > 0));
							if (NOT((next_segix IS 0) AND
								(other_int_num IS DUMMY_IX))) {
								/* check if same par. value */
								int_par = (p_crv_int_info1 + int_num1) -> int_parms.u;
								next_int_par = (p_crv_int_info1 +
									*(p_int_infoix1 + next_segix)) -> int_parms.u;
								if (fabs(next_int_par - int_par) < par_tol) {
									/* discard point */
									(crv_int_info[ crv_num2 ] + int_num2) -> other_ptix = DUMMY_IX;
									/* new start point */
									seg_startix1 = next_segix;
								};
							};
						};
					};
				};
				p_crv_seg_info ->startix = seg_startix1;
			};
			/* identify segment end point */
			if ( (seg_stat ISNT HAVE_END) AND (seg_stat ISNT HAVE_BOTH) ) {
				/* have start or have none, find end point */
				int_num1 = *(p_int_infoix1 + seg_endix1);
				int_num2 = (p_crv_int_info1 + int_num1) ->other_ptix;
				crv_num2 = (p_crv_int_info1 + int_num1) ->other_crvix;
				while ((int_num2 IS DUMMY_IX) AND (remint_num > 0)) {
					/* ignore discarded points */
					--remint_num;
					if (seg_endix1 IS (crvcrvint_num - 1)) {
						if (is_closed)
							/* closed curve, wraparound to first point */
							seg_endix1 = 0;
						else
							/* open curve, end of loop */
							break;
					} else
						++seg_endix1;
					int_num1 = *(p_int_infoix1 + seg_endix1);
					crv_num2 = (p_crv_int_info1 + int_num1) ->other_crvix;
					int_num2 = (p_crv_int_info1 + int_num1) ->other_ptix;
				};
				if ((remint_num IS 0) OR
				    (is_closed AND (remint_num IS 1))){
					/* disjoint curve */
					is_crv_disjnt = TRUE;
					crv_info[ crv_num1 ].crv_stat = CRV_DISJNT;
					p_crv_seg_info ->remint_num = 0;
					--rem_crvs;
					--num_segs;
					continue; /* end of for loop */
				};
				if ( (seg_endix1 IS (crvcrvint_num - 1)) AND (int_num2 IS DUMMY_IX)) {
					/* end point of the curve is end point of the segment */
					seg_endix1 = DUMMY_IX;
					if (seg_stat IS HAVE_NONE)
						seg_stat = HAVE_END;
					else
						seg_stat = HAVE_BOTH;
				} else {

					/* check if corresponding point on other curve is selected */
					seg_startix2 = crv_seg_info[ crv_num2 ].startix;
					seg_endix2 = crv_seg_info[ crv_num2 ].endix;
					p_crv_int_info2 = crv_int_info[ crv_num2 ];
					p_int_infoix2 = int_infoix[ crv_num2 ];

                                        /* 119310591 - added int_objix */
					other_int_par = (p_crv_int_info2 + int_num2) -> int_parms.u + (p_crv_int_info2 + int_num2)->int_objix;

					if (seg_startix2 IS DUMMY_IX)
						is_start = FALSE;
					else {
                                                /* 119310591 - added int_objix */
						seg_start_par2 = (p_crv_int_info2 +
							*(p_int_infoix2 + seg_startix2)) -> int_parms.u + (p_crv_int_info2 + *(p_int_infoix2 + seg_startix2))->int_objix;

						/*is_start = ( int_num2 IS * (int_infoix[ crv_num2 ] + seg_startix2) );*/
						is_start = (fabs(other_int_par - seg_start_par2) < par_tol);
					};
					if ( seg_endix2 IS DUMMY_IX )
						is_end = FALSE;
					else {
                                                /* 119310591 - added int_objix */
						seg_end_par2 = (p_crv_int_info2 +
							*(p_int_infoix2 + seg_endix2)) -> int_parms.u + (p_crv_int_info2 + *(p_int_infoix2 + seg_endix2))->int_objix;

						/*is_end = ( int_num2 IS * (int_infoix[crv_num2] + seg_endix2) );*/
						is_end = (fabs(other_int_par - seg_end_par2) < par_tol);
					};
					if ( is_start OR is_end ) { /* segment end point on curve1 identified */
						if ( seg_stat IS HAVE_NONE )
							seg_stat = HAVE_END;
						else
							seg_stat = HAVE_BOTH;
						if (NOT(is_closed))
							/* segment end point identified,
							   discard points of intersection after end point */
							for ( i = (seg_endix1 + 1); (i < crvcrvint_num ); ++i ) {
								/* discard point */
								crv_num2 = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_crvix;
								int_num2 = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_ptix;
								if (int_num2 IS DUMMY_IX)
									continue;
								--remint_num;
								(crv_int_info[crv_num2] + int_num2) ->other_ptix = DUMMY_IX;
							};
					} else {
						/* check for points with same par. value */
						if (seg_endix1 < (crvcrvint_num -1 )) {
							next_segix = seg_endix1;
							do {
								/* skip discarded points, if any */
								++next_segix;
								other_int_num = (p_crv_int_info1 +
									*(p_int_infoix1 + next_segix)) -> other_ptix;
							} while ((other_int_num IS DUMMY_IX) AND
								(next_segix < (crvcrvint_num -1)));
							if (NOT((next_segix IS (crvcrvint_num -1)) AND
								(other_int_num IS DUMMY_IX))) {
								/* check if same par. value */
								int_par = (p_crv_int_info1 + int_num1) -> int_parms.u;
								next_int_par = (p_crv_int_info1 +
									*(p_int_infoix1 + next_segix)) -> int_parms.u;
								if (fabs(next_int_par - int_par) < par_tol) {
									/* discard point */
									(crv_int_info[ crv_num2 ] + int_num2) -> other_ptix = DUMMY_IX;
									/* new end point */
									seg_endix1 = next_segix;
								};
							};
						};
					};

				};
				p_crv_seg_info ->endix = seg_endix1;
			};
			p_crv_seg_info ->remint_num = remint_num;
			p_crv_seg_info ->seg_stat = seg_stat;

                        /*
                         * Setting other_ptix to -1 on all curves that crv1 
                         * intersects with except for the curves that inter-
                         * sect on the segment the user identified. This
                         * wipes crv1 out on all the other curves. This happens
                         * when you have duplicate curves passed in. Here
                         * DUMMY_IX means that this curve(crv1) isn't the true 
                         * intersecting curve on the other curve(crv2).
                         */

			if (seg_stat IS HAVE_BOTH) {
				--rem_crvs;
				if (is_closed)
					/* discard all intersection points other
						than segment end points */
					for ( i = 0; (i < crvcrvint_num); ++i) {
						/* discard point */
						crv_num2 = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_crvix;
						int_num2 = (p_crv_int_info1 + *(p_int_infoix1 + i)) ->other_ptix;
						if ((int_num2 IS DUMMY_IX) OR
							(i IS seg_startix1) OR
							(i IS seg_endix1))
							continue;
						(crv_int_info[crv_num2] + int_num2) ->other_ptix = DUMMY_IX;
					};
			}; /* (seg_stat IS HAVE_BOTH) */
	
		}; /* for loop */
	}; /* while loop */

	if (rem_crvs > 0) {
		/* ambiguous situation; iter_cnt IS iter_cnt_max */
		is_crv_ambig = TRUE;
		/* mark ambiguous curves */
		for ( i = 0; (i < num_crvs); ++i ) {
			if ((crv_info[ i ].crv_stat IS CRV_DISCARD) OR
			    (crv_info[ i ].crv_stat IS CRV_DISJNT))
				continue;
			if (crv_seg_info[ i ].seg_stat ISNT HAVE_BOTH)
				crv_info[ i ].crv_stat = CRV_AMBIG;
		};
	};

	if (NOT(is_crv_ambig OR is_crv_disjnt)) {
		/* get start curve # */
		for ( i = 0; (i < num_crvs); ++i ) {
			if (crv_info[ i ].crv_stat IS CRV_DISCARD)
				continue; /* skip discarded curves */
			if ( (crv_seg_info[ i ].startix IS DUMMY_IX) OR
			    (crv_seg_info[ i ].endix IS DUMMY_IX) )
				break;
		};
		/* test if resultant curve open or closed */
		if ( i IS num_crvs ) {
			/* resultant curve closed, start with 1st undiscarded curve */
			crv_num1 = 0;
			while (crv_info[ crv_num1 ].crv_stat IS CRV_DISCARD)
				++crv_num1;
			next_crv_segix = crv_seg_info[ crv_num1 ].endix;
		} else {
			/* resultant curve open, start curve with its end point
			   as end point of resultant curve */
			crv_num1 = i;
			if (crv_seg_info[ crv_num1 ].startix IS DUMMY_IX)
				next_crv_segix = crv_seg_info[ crv_num1 ].endix;
			else
				next_crv_segix = crv_seg_info[ crv_num1 ].startix;
		};

		/* save info. for making composite curve */
		start_crv_num = crv_num1;
		start_crv_segix = next_crv_segix;

		/* check if all segments are connected */
		conn_crvs = 1;
		do {
                        /*
                         * Fix for TR#119420430.
                         */
                        if(next_crv_segix == DUMMY_IX) break;

			p_crv_int_info1 = crv_int_info[ crv_num1 ] +
				*( int_infoix[ crv_num1 ] + next_crv_segix);
			crv_num2 = p_crv_int_info1 -> other_crvix;
			if (crv_num2 IS start_crv_num)
				/* end of connected curves,
				   resultant curve closed */
				break;
			++conn_crvs;
			seg_startix2 = crv_seg_info[ crv_num2 ].startix;
			seg_endix2 = crv_seg_info[ crv_num2 ].endix;
			if ((seg_startix2 IS DUMMY_IX) OR
			    (seg_endix2 IS DUMMY_IX))
				/* end of connected curves,
				   resultant curve open */
				break;
			int_num2 = p_crv_int_info1 -> other_ptix;
			crv_num1 = crv_num2; /* next curve # */

                        /*
                         * other_ptix whould be the same as the
                         * int_infoix[crv][startix/endix].
                         */

			if (int_num2 IS *(int_infoix[ crv_num2 ] + seg_startix2))
				next_crv_segix = seg_endix2;
			else
				next_crv_segix = seg_startix2;
		} while (conn_crvs <= num_segs);  /* added this to fix infinite
                                                   * loop problem */

		is_crv_disjnt = (conn_crvs < num_segs);
	};

	if (is_crv_ambig OR is_crv_disjnt) {
		crv_num1 = 0;
		/* get 1st curve with segment identified */
		while ((crv_info[ crv_num1 ].crv_stat IS CRV_DISCARD) OR
			(crv_info[ crv_num1 ].crv_stat IS CRV_DISJNT))
			++crv_num1;
	} else {
		/* restore values for making composite curve */
		crv_num1 = start_crv_num;
		next_crv_segix = start_crv_segix;
	};

	/* allocate memory for the partofcv lc_info */
	MEM_ALLOC( p_lc_info, struct GRlc_info, num_segs, wrapup );

	/* extract the segments from the curves using method EMpartofcv */
	for ( i = 0; (i < num_segs); ++i ) {
		/* set start_parms, end_parms for EMpartofcv */
		p_crv_info = &crv_info[ crv_num1 ];
		p_crv_seg_info = &crv_seg_info[ crv_num1 ];
		p_crv_int_info1 = crv_int_info[ crv_num1 ];
		p_int_infoix1 = int_infoix[ crv_num1 ];
		is_compcurve1 = ( p_crv_info ->chan_count > 0 );

		seg_startix1 = p_crv_seg_info ->startix;
		if ( seg_startix1 IS DUMMY_IX ) {
			/* start point of curve is start point of segment */
			start_parms.u = 0;
			if (is_compcurve1) {
				/* composite curve, get objid of start curve */
				index = 0;
				status = om$get_objid_at_index( osnum = md_osnum,
				    objid = p_crv_info ->crv_id,
				    p_chanselect = &to_comps,
				    index = index,
				    objidaddr = &start_parms.leaf_id.objid,
				    osnumaddr = &start_parms.leaf_id.osnum );
				EMomerr_hndlr( status, wrapup, "EMtrmcrvele : om$get_objid_at_index");
			} else {
				/* simple curve, initialise leaf_id */
				start_parms.leaf_id.objid = md_osnum;
				start_parms.leaf_id.osnum = p_crv_info ->crv_id;
			};
		} else
			start_parms = (p_crv_int_info1 + 
			    *(p_int_infoix1 + seg_startix1)) ->int_parms;

		seg_endix1 = p_crv_seg_info ->endix;
		if ( seg_endix1 IS DUMMY_IX ) {
			/* end point of curve is end point of segment */
			end_parms.u = 1;
			if (is_compcurve1) {
				/* composite curve, get objid of start curve */
				index = p_crv_info ->chan_count - 1;
				status = om$get_objid_at_index( osnum = md_osnum,
				    objid = p_crv_info ->crv_id,
				    p_chanselect = &to_comps,
				    index = index,
				    objidaddr = &end_parms.leaf_id.objid,
				    osnumaddr = &end_parms.leaf_id.osnum );
				EMomerr_hndlr( status, wrapup, "EMtrmcrvele : om$get_objid_at_index");
			} else {
				/* simple curve, initialise leaf_id */
				end_parms.leaf_id.objid = md_osnum;
				end_parms.leaf_id.osnum = p_crv_info ->crv_id;
			};

		} else
			end_parms = (p_crv_int_info1 + 
			    *(p_int_infoix1 + seg_endix1)) ->int_parms;

		status = om$send( mode = OM_e_wrt_object,
		    msg = message GRcurve.EMpartofcv(
		    msg, 			/* *msg */
		&mdenv_info.matrix_type, 	/* *mattyp */
		mdenv_info.matrix, 		/* mat */
		p_const_list, 		/* *const_args */
		&start_parms, 		/* *startpar */
		&p_crv_info ->loc_pt_prj_parms, /* *midpar */
		&end_parms, 			/* *endpar */
		&pcrv_id	/* *partcrvid*/ ),
		    senderid = NULL_OBJID,
		    targetid = p_crv_info ->crv_id,
		    targetos = md_osnum );

		EMomerr_hndlr( status, wrapup, "EMtrmcrvele : GRcurve.EMpartofcv" );

		if (is_crv_ambig OR is_crv_disjnt) {
			crv_info[ crv_num1 ].pcrv_id = pcrv_id;
			++crv_num1;
			while (((crv_info[ crv_num1 ].crv_stat IS CRV_DISCARD) OR
				(crv_info[ crv_num1 ].crv_stat IS CRV_DISJNT)) AND
			    (crv_num1 < num_crvs))
				++crv_num1;
		} else {
			crv_info[ crv_num1 ].pcrv_id = NULL_OBJID;
			/* place info for EMmakecomp */
			p_lc_info[ i ].located_obj.objid = pcrv_id;
			p_lc_info[ i ].located_obj.osnum = md_osnum;
			p_lc_info[ i ].module_info = *p_md_env;

			if ( i IS (num_segs - 1) )
				break; /* end of loop, skip code for last curve */
			/* get next curve info */
			p_crv_int_info1 = crv_int_info[ crv_num1 ] + 
			    *(p_int_infoix1 + next_crv_segix);

			crv_num2 = p_crv_int_info1 ->other_crvix;
			int_num2 = p_crv_int_info1 ->other_ptix;
			next_crv_segix = crv_seg_info[ crv_num2 ].startix;
			if (int_num2 IS * (int_infoix[ crv_num2 ] + next_crv_segix))
				next_crv_segix = crv_seg_info[ crv_num2 ].endix;

			crv_num1 = crv_num2;
		};
	};

	if (is_crv_ambig OR is_crv_disjnt) 
		goto wrapup;

	/* make composite curve out of these segments (parts of curve) */

	/* create composite curve shell */
	status = om$construct( classname = "GRcompcurve",
	    obj_osnum = NULL,
	    osnum = md_osnum,
	    p_objid = p_compcrv_id,
	    msg = message GRgraphics.GRconstruct( p_const_list)
	    );
	EMomerr_hndlr( status, wrapup, "EMtrmcrvele : GRgraphics.GRconstruct" );

	status = om$send( mode = OM_e_wrt_object,
	    msg = message GRcompcurve.EMmakecomp(
	    msg, 		/* *msg */
	p_md_env, 		/* *myModuleInfo */
	num_segs, 		/* num_ent */
	p_lc_info, 	/* *entries */
	&err_crv_num), 	/* *rotten_one */
	senderid = NULL_OBJID,
	    targetid = *p_compcrv_id,
	    targetos = md_osnum);
	EMomerr_hndlr( status, wrapup, "EMtrmcrvele : GRcompcurve.EMmakecomp" );

        ex$message(msgnumb=EMS_S_ClearStatusField);

wrapup:

	/* deallocate memory allocated in EMcrvcrvint method */
	MEM_DEALLOC( my_pnt_inters );
	MEM_DEALLOC( other_pnt_inters );

	MEM_DEALLOC( int_par_info );
	MEM_DEALLOC( crv_seg_info );
	MEM_DEALLOC( p_lc_info );
	for (i = 0; i < num_crvs; ++i) {
		MEM_DEALLOC( int_infoix[ i ] );
		MEM_DEALLOC( crv_int_info[ i ] );
	};
	MEM_DEALLOC( crv_int_info );
	MEM_DEALLOC( int_infoix );

	if (NOT(1 & *msg) )
		return(status);
	else {
		if (is_crv_nonint)
			*msg = MSTRM_NONINT_CRV; /* warning */
		else if (is_crv_invmult)
			*msg = MSTRM_INVMULT_CRV; /* warning */
			else if (is_crv_ambig)
				*msg = MSTRM_AMBIG_CRV; /* warning */
				else if (is_crv_disjnt)
					*msg = MSTRM_DISJNT_CRV; /* warning */

		return(status);
	};

} /* EMtrmcrvele */

end implementation GRcurve;
