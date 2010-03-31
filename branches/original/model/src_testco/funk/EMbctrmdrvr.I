class implementation GRcurve;

#include "EMS.h"
/* 
   function for ECtrmdrvr in /usrx/ingr/ems/src_testco/slic/ECtrmdrvr.sl

   this file in /usrx/ingr/ems/src_testco/funk/EMbctrmcrvs.I

   Abstract
	***to be filled in***

   Algorithm
	***to be filled in***

   History
	sjv			date of creation
	sjv	02/12/88	initialize pointers used in memory allocation
    dhm 2/16/89     modified to preserve the original curve's symbology.
        rlw     06/09/89        Modified not to send display parameter of
                                construct list to place part of curve such
                                that existing symbology is used.
	Sudha   07/02/93        Modified for BSprototypes ansification
*/

#include "EMSlogic.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "emserr.h"
#include "msdef.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "bstagsort.h"

extern OMuword OPP_GRcompcurve_class_id;

IGRlong	EMtrmdrvr(
msg,
drvr_crv_id,
crv_info,
const_list,
num_crvs)

IGRlong 		*msg;
GRobjid			drvr_crv_id;
struct EMScrv_info_sd *crv_info;
struct GRvg_construct *const_list;
IGRint 			num_crvs;

/*
   Abstract
	***to be filled in***
   Notes
	***to be filled in***
   History
	sjv	01/30/88 Creation
*/

#define DUMMY_IX	-1 /* dummy index value for end points */
/* EMtrmdrvr warning return status codes */
#define MSTRM_NONINT_CRV	201	/* curve non-intersecting with other curves */
#define MSTRM_DISJNT_CRV	203	/* curve unconnected (disjoint) with other curves */

/* macro to allocate or reallocate memory & check for Memory Over */
#define MEM_ALLOC( data_ptr, data_type, num, error_exit )\
if (!data_ptr)	\
 data_ptr = (data_type *) om$malloc( size = (num * sizeof(data_type)));	\
else	\
 data_ptr = (data_type *) om$realloc( ptr = (char *)data_ptr, size = (num * sizeof(data_type)));	\
/* check for error in (re)allocation, if any */	\
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

	struct crv_seg_info_sd {
		IGRint		crvint_num, 	/* total number of intersection points for the curve */
		startix,
		endix;		/* start & end intersection point indices */
	};

	struct crv_int_info_sd {
		IGRint		int_objix;	/* channel index for curve having intersection point */
		struct GRparms int_parms;
	};

	struct EMScrv_info_sd *p_crv_info;

	/* intersection pts. info. for the different curves */
	struct crv_int_info_sd **crv_int_info,
	*p_crv_int_info;

	struct crv_seg_info_sd *crv_seg_info,
	*p_crv_seg_info;

	IGRdouble	 * int_par_info, 	/* intersection parameter value
						used only for sorting */
	loc_pt_par;	/* located point parameter value */

	IGRint		 * *int_infoix, /* index to intersection info. sorted in
					ascending order of parametric value */
	*p_int_infoix;

	IGRlong	pnt_slots = 0, 	/* no preallocation for point info. */
	crv_slots = 0, 	/* no preallocation for curve overlap info. */
	num_ovr; 	/* number of overlaps */

	struct GRparms *my_pnt_inters,
	*other_pnt_inters, /* parametric info. for the intersection points */
	start_parms,
	end_parms;	/* for EMpartofcv method */

	struct GRid crv_id,
	leaf_id;
	GRobjid  pcrv_id; /* for returning part of curve id */

	IGRlong		crvcrvint_num; 	/* number of intersections */
	IGRint		rem_crvs, /* remaining curves to be processed */
			crv_num,
	    int_num,
	    intix, /* index to intersection point info */
		seg_startix,
		seg_endix,
	i;	/* for loop index variables */

	IGRboolean	is_closed, /* curve physically closed ? */
	is_crv_nonint, /* all non-intersecting curves ? */
	is_crv_disjnt, /* non-intersecting curve ? */
	is_compcurve,
	    bs_status;

	IGRlong	bs_rc,
	    status = OM_S_SUCCESS;

	struct GRmdenv_info mdenv_info;
	GRspacenum	md_osnum; /* module object space number */

	OMuint			index, /* for object index */
	chan_count; /* for om$get_channel_count */
	OMuword                 class_id;
	OM_S_CHANSELECT         to_comps;
        struct GRvg_construct *p_const_list, construct_list;

	/*******************************************************************/
	/*			end of declarations			   */
	/*******************************************************************/

	/* initialise */
	*msg = MSSUCC;
	is_crv_nonint = FALSE;
	is_crv_disjnt = FALSE;
        p_const_list = &construct_list;
        construct_list = *const_list;
        construct_list.display = NULL;
	/* initialize pointers used for allocating memory */
	crv_int_info = NULL;
	crv_seg_info = NULL;
	int_par_info = NULL;
	int_infoix = NULL;
	my_pnt_inters = NULL;
	other_pnt_inters = NULL;

	status = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
	EMomerr_hndlr( status, wrapup, "EMtrmdrvr : EMmake_chanselect" );

	mdenv_info = p_const_list -> env_info -> md_env;
	md_osnum = p_const_list -> env_info -> md_id.osnum;

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
		EMomerr_hndlr( status, wrapup, "EMtrmdrvr : om$get_classid" );

		if (class_id IS OPP_GRcompcurve_class_id) {
			status = om$get_channel_count(objid = p_crv_info ->crv_id,
			    osnum = md_osnum,
			    p_chanselect = &to_comps,
			    count = &chan_count);
			EMomerr_hndlr( status, wrapup, "EMtrmdrvr : om$get_channel_count" );

			p_crv_info ->chan_count = chan_count;
			leaf_id = p_crv_info ->loc_pt_prj_parms.leaf_id;
			/* get index for curve having locate point */
			status = om$get_index( osnum_c = md_osnum,
			    objid_c = p_crv_info ->crv_id,
			    p_chanselect = &to_comps,
			    objid = leaf_id.objid,
			    osnum2 = leaf_id.osnum,
			    indexaddr = &index);
			EMomerr_hndlr( status, wrapup, "EMtrmdrvr : om$get_index" );
			p_crv_info ->loc_objix = index;

		} else {
			/* not a composite curve */
			p_crv_info ->chan_count = 0;
			p_crv_info ->loc_objix = 0;
		};
		p_crv_seg_info ->crvint_num = 0;
		p_crv_seg_info ->startix = 0;
		p_crv_seg_info ->endix = 0;
	};

	/* find the points of intersection */
	for ( crv_num = 0; (crv_num < num_crvs ); ++crv_num )
    {
		crv_id.objid = crv_info[ crv_num ].crv_id;
		crv_id.osnum = md_osnum;
		is_compcurve = (crv_info[ crv_num ].chan_count > 0);

		crvcrvint_num = 0; /* initialize grand_num_pnt for EMcrvcrvint */
		status = om$send( mode = OM_e_wrt_object,
		    msg = message GRcurve.EMcrvcrvint(
		    msg, 	/* *msg */
		NULL, 		/* *cnst_list */
		&mdenv_info, 	/* *my_objenv */
		NULL, 		/* *other_curve */
		&crv_id, 	/* *other_obj */
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
		    targetid = drvr_crv_id,
		    targetos = md_osnum);
		if (EMSmsgReport(status, "EMtrmdrvr : EMcrvcrvint", FALSE) )
			goto wrapup;

        if (NOT(crvcrvint_num))
            continue; /* skip the loop if no intersection found */

		MEM_ALLOC( crv_int_info[ crv_num ], struct crv_int_info_sd, crvcrvint_num, wrapup );

		/* save intersection parametric information */
		for (i = 0; (i < crvcrvint_num); ++i) {

			/* save curve info */
			p_crv_int_info = crv_int_info[ crv_num ] + i;
			p_crv_int_info ->int_parms = other_pnt_inters[ i ];
			if ( is_compcurve ) {
				leaf_id = other_pnt_inters[ i ].leaf_id;
				/* get index for curve having intersection point */
				status = om$get_index( osnum_c = md_osnum,
				    objid_c = crv_id.objid,
				    p_chanselect = &to_comps,
				    objid = leaf_id.objid,
				    osnum2 = leaf_id.osnum,
				    indexaddr = &index);
				EMomerr_hndlr( status, wrapup, "EMtrmdrvr : om$get_index" );
				p_crv_int_info ->int_objix = index;
			} else
				p_crv_int_info ->int_objix = 0;

		};

		crv_seg_info[ crv_num ].crvint_num = crvcrvint_num;

	};  /* end for loop to get intersection points */


	rem_crvs = num_crvs;
	/* test for non-intersecting curves, if any */
	for ( crv_num = 0; (crv_num < num_crvs); ++crv_num ) {
		if ( crv_seg_info[ crv_num ].crvint_num IS 0 ) {
			is_crv_disjnt = TRUE;
			crv_info[ crv_num ].crv_stat = CRV_DISJNT;
			--rem_crvs;
		} else
			crv_info[ crv_num ].crv_stat = CRV_OK;
	};

	if (rem_crvs IS 0) {
		is_crv_nonint = TRUE;
		goto wrapup;
	};

	/* sort the points in ascending order of the parametric value */
	for ( crv_num = 0; (crv_num < num_crvs); ++crv_num ) {
		p_crv_info = &crv_info[ crv_num ];
		if (p_crv_info -> crv_stat IS CRV_DISJNT)
			/* skip non-intersecting curves */
			continue;
		p_crv_seg_info = &crv_seg_info[ crv_num ];
		crvcrvint_num = p_crv_seg_info ->crvint_num;
		p_crv_int_info = crv_int_info[ crv_num ];

		/* allocate memory for the index array */
		MEM_ALLOC( int_infoix[ crv_num ], IGRint, crvcrvint_num, wrapup );
		/* allocate memory for int_par_info  */
		MEM_ALLOC( int_par_info, IGRdouble, crvcrvint_num, wrapup);

		if (crvcrvint_num IS 1) {
			/* only one point of intersection, no sorting necessary */
			*int_infoix[ crv_num ] = 0;
			int_par_info[ 0 ] = p_crv_int_info ->int_objix + 
			    p_crv_int_info ->int_parms.u;
		} else {
			for ( i = 0; ( i < crvcrvint_num ); ++i ) {
				int_par_info[ i ] = p_crv_int_info ->int_objix + 
				    p_crv_int_info ->int_parms.u;
				++p_crv_int_info;
			};

			/* sort intersection points parametric info */
			bs_status = BStagsort( &bs_rc, 		/* *rc */
			(IGRint *)&crvcrvint_num, 	/* *num_values */
			int_par_info, 	/* *values */
			int_infoix[ crv_num ]);	/* *subs */

			if (( NOT bs_status ) OR ( bs_rc ISNT BSSUCC )) {
				*msg = MSFAIL;
				status = OM_E_ABORT;
				goto wrapup;
			};
		};

		/* Now, get the segment identified by the user */
		is_closed = p_crv_info ->phy_closed;
		loc_pt_par = p_crv_info ->loc_pt_prj_parms.u + 
		    p_crv_info ->loc_objix;

		/* segment start point ix */
		int_num = 0;
		p_int_infoix = int_infoix[ crv_num ];
		intix = *p_int_infoix;
		while ( loc_pt_par > int_par_info[ intix ] ) {
			++int_num; /* next intersection point */
			if (int_num < crvcrvint_num)
				intix = *(++p_int_infoix);
			else
				break;
		};

		if ( int_num IS 0 ) {
			if (is_closed)
				/* closed curve, wraparound to last point */
				p_crv_seg_info ->startix = crvcrvint_num - 1;
			else
				/* start point of the curve is start point of the segment */
				p_crv_seg_info ->startix = DUMMY_IX;
		} else
			/* save previous point index as start point ix */
			p_crv_seg_info ->startix = int_num - 1;

		/* segment end point ix */
		p_int_infoix = int_infoix[ crv_num ] + crvcrvint_num - 1;
		intix = *p_int_infoix;
		int_num = crvcrvint_num;
		while ( loc_pt_par < int_par_info[ intix ] ) {
			--int_num; /* previous intersection point */
			if (int_num > 0)
				intix = *(--p_int_infoix);
			else
				break;
		};

		if ( int_num IS crvcrvint_num ) {
			if (is_closed)
				/* closed curve, wraparound to first point */
				p_crv_seg_info ->endix = 0;
			else
				/* end point of the curve is end point of the segment */
				p_crv_seg_info ->endix = DUMMY_IX;
		} else
			p_crv_seg_info ->endix = int_num;
	};

	/* extract the segments from the curves using method EMpartofcv */

	for ( crv_num = 0; (crv_num < num_crvs); ++crv_num ) {
		/* set start_parms, end_parms for EMpartofcv */
		p_crv_info = &crv_info[ crv_num ];
		if (p_crv_info -> crv_stat IS CRV_DISJNT)
			/* skip non-intersecting curves */
			continue;
		p_crv_seg_info = &crv_seg_info[ crv_num ];
		p_crv_int_info = crv_int_info[ crv_num ];
		p_int_infoix = int_infoix[ crv_num ];
		is_compcurve = ( p_crv_info ->chan_count > 0 );

		seg_startix = p_crv_seg_info ->startix;
		if ( seg_startix IS DUMMY_IX ) {
			/* start point of curve is start point of segment */
			start_parms.u = 0;
			if (is_compcurve) {
				/* composite curve, get objid of start curve */
				index = 0;
				status = om$get_objid_at_index( osnum = md_osnum,
				    objid = p_crv_info ->crv_id,
				    p_chanselect = &to_comps,
				    index = index,
				    objidaddr = &start_parms.leaf_id.objid,
				    osnumaddr = &start_parms.leaf_id.osnum );
				EMomerr_hndlr( status, wrapup, "EMtrmdrvr : om$get_objid_at_index");
			} else {
				/* simple curve, initialise leaf_id */
				start_parms.leaf_id.objid = md_osnum;
				start_parms.leaf_id.osnum = p_crv_info ->crv_id;
			};
		} else
			start_parms = (p_crv_int_info + 
			    *(p_int_infoix + seg_startix)) ->int_parms;

		seg_endix = p_crv_seg_info ->endix;
		if ( seg_endix IS DUMMY_IX ) {
			/* end point of curve is end point of segment */
			end_parms.u = 1;
			if (is_compcurve) {
				/* composite curve, get objid of start curve */
				index = p_crv_info ->chan_count - 1;
				status = om$get_objid_at_index( osnum = md_osnum,
				    objid = p_crv_info ->crv_id,
				    p_chanselect = &to_comps,
				    index = index,
				    objidaddr = &end_parms.leaf_id.objid,
				    osnumaddr = &end_parms.leaf_id.osnum );
				EMomerr_hndlr( status, wrapup, "EMtrmdrvr : om$get_objid_at_index");
			} else {
				/* simple curve, initialise leaf_id */
				end_parms.leaf_id.objid = md_osnum;
				end_parms.leaf_id.osnum = p_crv_info ->crv_id;
			};

		} else
			end_parms = (p_crv_int_info + 
			    *(p_int_infoix + seg_endix)) ->int_parms;

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

		EMomerr_hndlr( status, wrapup, "EMtrmdrvr : GRcurve.EMpartofcv" );

		crv_info[ crv_num ].pcrv_id = pcrv_id;
	};

wrapup :

	/* deallocate memory allocated in EMcrvcrvint method */
	MEM_DEALLOC( my_pnt_inters );
	MEM_DEALLOC( other_pnt_inters );

	MEM_DEALLOC( int_par_info );
	MEM_DEALLOC( crv_seg_info );
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
		else if (is_crv_disjnt)
			*msg = MSTRM_DISJNT_CRV; /* warning */

		return(status);
	};
} /* EMtrmdrvr */

end implementation GRcurve;
