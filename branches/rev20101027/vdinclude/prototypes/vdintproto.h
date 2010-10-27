/* $Id: vdintproto.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude/prototypes/vdintproto.h
 *
 * Description: intersection prototypes
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdintproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/10/29  17:49:32  pinnacle
 * initial revision
 *
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/29/96	ah		Creation
 *
 * -------------------------------------------------------------------*/

#ifndef vdintproto_include
#define vdintproto_include

// Main Intersection Routine
extern IGRlong VDint2elemInternal __((
  struct GRobj_env      *obj_env1,
  struct GRobj_env      *obj_env2,
  struct GRid      	*id1,
  struct GRid      	*id2,
  IGRint	        Trim1Req,
  IGRint                Trim2Req,
  IGRboolean 		AppRequired,
  struct GRmd_env	*MOD_ENV,
  IGRint                *num_inter,
  struct GRid 	        *GRid_tab));

extern int VDintSrfPlInf __((
  IGRboolean		trim_option,	/* I */ 
  IGRboolean		app_option,	/* I */
  struct GRlc_info 	*plane_lc_ptr,	/* infine  plane   */ 	    /* I */
  struct GRlc_info	*srf_lc_ptr,	/* general surface */       /* I */	
  struct GRvg_construct *cst_ptr,	 			    /* I */
  IGRint		*nb_int_ptr,	/* number of intersection*/ /* O */
  struct GRid		*int_sol));	/* list of intersection  */ /* O */

extern int VDintCrvPlInf __(( 
  struct GRlc_info 	*plane_lc_ptr,	/* infine  plane   */ 	    /* I */
  struct GRlc_info	*crv_lc_ptr,	/* general curve   */       /* I */	
  struct GRvg_construct	*cst_ptr,	 			    /* I */
  IGRint		*nb_int_ptr,	/* number of intersection*/ /* O */
  struct GRid		*int_sol));	/* list of intersection  */ /* O */

extern int VDintSrfLnInf __(( 
  IGRboolean		trim_option,   
  struct GRlc_info 	*line_lc_ptr,  	/* infine  line */ 	    /* I */
  struct GRlc_info	*srf_lc_ptr,   	/* general surface/curve */ /* I */	
  struct GRvg_construct	*cst_ptr,       			    /* I */
  IGRint		*nb_int_ptr,   	/* number of intersection*/ /* O */
  struct GRid		*int_sol));     /* list of intersections */ /* O */

extern int VDintPlLnInf __((
  struct GRlc_info 	*plane_lc_ptr,	/* infine  plane   */ 	    /* I */
  struct GRlc_info	*line_lc_ptr,	/* infinite line   */       /* I */	
  struct GRvg_construct	*cst_ptr,	 			    /* I */
  IGRint		*nb_int_ptr,	/* number of intersection*/ /* O */
  struct GRid		*int_sol));	/* list of intersection  */ /* O */

extern int VDintPlPlInf __((
  struct GRlc_info 	*plane1_lc_ptr, /* infinite plane  */ 	    /* I */
  struct GRlc_info	*plane2_lc_ptr, /* infinite plane  */ 	    /* I */	
  struct GRvg_construct	*cst_ptr,	 			    /* I */
  IGRint		*nb_int_ptr,	/* number of intersection*/ /* O */
  struct GRid		*int_sol));	/* list of intersection  */ /* O */

extern int VDintLnLnInf __((
  struct GRlc_info 	*line1_lc_ptr,	/* infinite line   */ 	    /* I */
  struct GRlc_info	*line2_lc_ptr,  /* infinite line   */       /* I */	
  struct GRvg_construct	*cst_ptr,	 			    /* I */
  IGRint		*nb_int_ptr,	/* number of intersection*/ /* O */
  struct GRid		*int_sol));	/* list of intersection  */ /* O */

extern int VDintGetNoTrimSrf __((
  struct GRlc_info	*lc_obj_ptr,	  /* I : imposed-boundary surface */
  struct GRmd_env	*mod_env_ptr,	  /* I : mod. env. for copy       */
  struct GRlc_info	*new_lc_obj_ptr));/* O : surf with no boundary    */

extern int VDintGetExtCurve __((
  struct GRvg_construct *cst_ptr,   	/* I   */
  struct GRlc_info	*lc_obj_ptr));	/* I/O */

extern int VDintSetLcObjFromObjEnv __((
  struct GRobj_env  *obj_env,
  struct GRlc_info  *lc_obj,
  OMuword           *temp_cl));

extern int VDintSetLcObjFromId __((
  struct GRid       *id,
  struct GRlc_info  *lc_obj,
  OMuword           *temp_cl));

extern int VDintCheckAncestry __((
  GRclassid ancestor1, 
  GRclassid ancestor2, 
  OMuword   class1, 
  OMuword   class2));

#endif

