/* $Id: vlunwext.h,v 1.1.1.1 2001/01/04 21:11:11 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        include/vlunwext.h
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vlunwext.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:11  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/10/27  04:18:18  pinnacle
 * Replaced: include/vlunwext.h for:  by smpathak for loft
 *
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.1  1997/10/28  20:26:56  pinnacle
 * Created: include/vlunwext.h by rchennup for loft
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *      10/26/98   Sandeep      Modification for TR #179801541
 *************************************************************************/

#ifndef	vlunwext_include
#define	vlunwext_include

#define  UNWEXT_NB_PROCOPT	    4
#define  UNWEXT_OPT_PARENT          0
#define  UNWEXT_OPT_ADDFEAT         1
#define  UNWEXT_OPT_AUTOMRK         2
#define  UNWEXT_OPT_ADDSTOK         3
#define  UNWEXT_ATT_IDX_PARENT	    7
#define  UNWEXT_ATT_IDX_ADDFEAT     8
#define  UNWEXT_ATT_IDX_AUTOMRK     9
#define  UNWEXT_ATT_IDX_ADDSTOK    10

#define  UNWEXT_NB_OPT             11

#define  G_PRCOPT      		   22

struct	edge_match_list {

	IGRint		   Count ;
	struct EdgeMatch   *EdgeList;

} ;

/*** Structure can be used to store list or lists of objid ****/

struct	proj_line_list {

	IGRint		cnt ;		/* Count of objid   */
	OM_S_OBJID   	*list;		/* List of objid    */

} ;

/*+M

Macro 
	vl$place_unwrap_extract

Abstract
	This macro will place the Unwrap Extraction in the design file.

Arguments
	OUT	IGRlong			*msg		Completion code
        IN      struct  GRobj_env       *plate          Input Plate
        IN      struct  GRmd_env        *md_env		Current Module Info
	IN	struct  GRid		cs_obj		Coordinate System
	IN      IGRdouble               *options	Option List
							See vlunfold.h for more
	IN	IGRint			proc_opts	Processing Options
	IN      IGRchar                 *setup_file	Setup File Name
	OUT     struct GRid             *unw_obj	Unwrap Extraction Object
	OUT     IGRint                  *feat_count	Feature Count
	OUT     struct  GRid            *feat_list[]    Feature List

Note
	*msg will be
		MSSUCC	if successfull
		MSFAIL	if severe error
-M*/

extern long
VLunw_CreateUnwrapObj
		  __((  long                    *msg,
                        struct  GRobj_env       *plate,
                        struct  GRmd_env        *md_env,
                        struct  GRid            cs_obj,
                        IGRdouble               *options,
                        IGRchar                 *setup_file,
                        struct GRid             *unw_obj,
                        IGRint                  *feat_count,
                        struct  GRid            **feat_list ));

#omdef vl$place_unwrap_extract( msg,
				plate,
				md_env,
				cs_obj,
				options,
				setup_file = "unwrap_setup",
				unw_obj    = NULL,
				feat_count = NULL,
				feat_list  = NULL              )

	VLunw_CreateUnwrapObj( (msg), (plate), (md_env), (cs_obj), (options),
	                  (setup_file), (unw_obj), (feat_count), (feat_list) )

#endomdef

/*+M

Macro 
	vl$get_unwrap_edges

Abstract
	This macro will return the edge matching list, i.e. 2-D graphics
	of the edge along with 3-D edge edge attribute object.

Arguments
	OUT	IGRlong			*msg		Completion code
        IN      struct  GRid		unw_obj         Input Unwrap Object
	OUT     IGRint                  *edge_count	Edge Count
	OUT     struct  EdgeMatch       *match_list[]   Edge matching List

Note
	*msg will be
		MSSUCC	if successfull
		MSFAIL	if severe error
-M*/

extern long
VLunwGetUnwrapEdges
	       __((     IGRlong           *msg,
                        struct GRid       unw_obj,
                        IGRint            *edge_count,
                        struct EdgeMatch  **match_list ));

#omdef vl$get_unwrap_edges( msg,
			    unwrap_obj,
			    edge_count,
			    match_list  = NULL  )

   VLunwGetUnwrapEdges( (msg), (unwrap_obj), (edge_count), (match_list) )

#endomdef

/*+M

Macro 
	vl$get_feature_lines

Abstract
	This macro will return the matching list of 2-D feature graphics
	along with actual feature object in the model.
Arguments
	OUT	IGRlong			*msg		Completion code
        IN      struct  GRid       	unw_obj		Input Plate
	IN      IGRint               	*optlines	Option List
							See vlunfold.h for more
	OUT     IGRint                  *feature_count	Feature Count
	OUT     struct  EdgeMatch       *feat_list[]    Feature List

Note
	*msg will be
		MSSUCC	if successfull
		MSFAIL	if severe error
-M*/

extern long
VLunwGetFeatureLines
	       __((     IGRlong           *msg,
                        struct GRid       unw_obj,
			IGRint		  *optlines,
                        IGRint            *feature_count,
                        struct EdgeMatch  **match_list ));

#omdef vl$get_feature_lines( msg,
			     unwrap_obj,
			     optlines,
			     feature_count,
			     match_list  = NULL  )

   VLunwGetFeatureLines( (msg), (unwrap_obj), (optlines),
		 	 (feature_count), (match_list) )

#endomdef

#endif
