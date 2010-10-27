/* $Id: VDgtcmpobj.I,v 1.2 2001/08/31 22:20:08 ahundiak Exp $  */

/* I/VDS
 *
 * File:	vdmisc/VDgtcmpobj.I
 *
 * Description:
 *	This file contains support function for the macro vd_$select_obj_comps.
 *	The function returns, based on the input setting the solids, surfaces,
 *	wireframe and/or textual information.
 *
 * Dependencies:
 *
 * Reference
 *	$Log: VDgtcmpobj.I,v $
 *	Revision 1.2  2001/08/31 22:20:08  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/06/02  12:50:28  pinnacle
# Replace: vdmisc/VDgtcmpobj.I by azuurhou for OPE
#
# Revision 1.1  1995/04/03  15:47:24  pinnacle
# Created: ./vdmisc/VDgtcmpobj.I by azuurhou r#
# rno
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/03/95	adz		creation date.
 *	05/02/95	adz		Correction for image objects.
 *	06/02/95	adz		Solids are returned when option 
 *					is active.
 */

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <alloca.h>

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"

#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "EMSmsgdef.h"

#include "dpstruct.h"

#include "godef.h"
#include "gr.h"
#include "go.h"

#include "bs.h"
#include "bsvalues.h"

#include "vd_ve.h"
#include "v_edgedef.h"
#include "v_datamacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from	GRowner		import	GRget_matrix;
from	ACheader	import	ACfind_model;
from	VDlink		import	ACget_model_list;
	

/*
 *  External - global variables
 */

/*
 * Class-id's Needed For Element Classification
 */
extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRtext_class_id;
extern OMuword OPP_GRpoint_class_id;
extern OMuword OPP_GRflxown_class_id;
extern OMuword OPP_GRclhdr_class_id;
extern OMuword OPP_GRsmhdr_class_id;
extern OMuword OPP_GRsmdfhdr_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_ACcpx_class_id;
extern OMuword OPP_ACrg_collect_class_id;
extern OMuword OPP_AScontents_class_id;
extern OMuword OPP_ASnode_class_id;
extern OMuword OPP_EMSmassprop_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_SKmgr_class_id;
extern OMuword OPP_EMSasectvw_class_id;
extern OMuword OPP_VDrelat_hdr_class_id;

/*
 * The function allows you to specify the need for a certain subgroup of 
 * graphics.
 * Existing groups:	
 */

#define	IS_A_SUBCLASS( sclass, pclass )  \
	(om$is_ancestry_valid( subclassid = sclass,  \
	superclassid = pclass ) == OM_S_SUCCESS)

#define _REALLOC( ptr, nelem, type ) \
	(type *) realloc( (ptr), (unsigned) ( (nelem) * sizeof( type ) ) )

/*---- VD_drwBuildCompRcd ------------------------------------------------*/

long VD_drwBuildCompRcd(	IGRlong			*msg,
				struct GRid		*elmId,
				struct GRmd_env		*elmEnv,
                                IGRmatrix		mtx,
                                IGRshort		mtxType,
                                struct VDve_elem_buf	*elmList )
/*
NAME
   VD_drwBuildCompRcd

DESCRIPTION
   This function allocates and initializes a sort record for a new element.
   It also adds the sort record to the array of buckets used for sorting.

PARAMETERS
	elmId	(IN) - the element whose sort record is to be built
	elmEnv	(IN) - the environment of the element, can be NULL
	mtx	(IN) - the matrix of the element's environment
	mtxType	(IN) - the type of 'matrix'
	elmList	(IN) - module environment of the element

HISTORY
	Ad
*/
{
	IGRlong			sts = OM_S_SUCCESS ;
	IGRint			i ;

	SetProc( VD_drwBuildCompRcd ); Begin

	*msg = MSSUCC ;

	/*
	 * allocate new memory.
	 */
	if( elmList->obj_info_p == NULL ){

		__DBGpr_com("Allocate memory ");

		elmList->buf_siz    = 10 ;
		elmList->count      = 0 ;
		if( ! ( elmList->obj_info_p = _MALLOC(	elmList->buf_siz,
							struct GRobj_env )))
			vd_$mem_fail();
	}

	/*
	 * Check if reallocation is needed.
	 */
	if( elmList->count +1 >= elmList->buf_siz ){

		/*
		 * allocate, reallocate memory.
		 */
		elmList->buf_siz   += 10 ;
		elmList->obj_info_p = _REALLOC(	elmList->obj_info_p,
						elmList->buf_siz,
						struct GRobj_env );
	}

	/*
	 * Fill the result in the output list.
	 */
	__DBGpr_int( "List index ", elmList->count );
	__DBGpr_obj( "List Object", *elmId );

	elmList->obj_info_p[elmList->count]._grid		= *elmId ;
	elmList->obj_info_p[elmList->count]._matrix_type	= mtxType ;
	elmList->obj_info_p[elmList->count]._md_os		= elmId->osnum ;
	for( i=0 ; i<16 ; i++ )
	  elmList->obj_info_p[elmList->count]._matrix[i]	= mtx[i] ; 

	sts =
	ex$get_modid(
		mod_osnum = elmList->obj_info_p[elmList->count]._md_os,
		mod_id	  = &elmList->obj_info_p[elmList->count]._md_id );

	elmList->count   += 1 ;

	wrapup:

		End
		return sts ;

}/* VD_drwBuildCompRcd */

/*---- VDdrwSelectCompsObj -------------------------------------------*/

#if defined(__STDC__)
long VDdrwSelectCompsObj(	IGRlong			*msg,
				IGRint			option,
				struct GRid		*elmId,
				struct GRmd_env		*elmEnv,
				IGRmatrix		mtx,
				IGRshort		mtxType,
				struct VDve_elem_buf	*elmList )
#else
long VDdrwSelectCompsObj( msg, option, elmId, elmEnv, mtx, mtxType, elmList )

	IGRlong			*msg ;
	IGRint			option ;
	struct	GRid		*elmId ;
	struct	GRmd_env	*elmEnv ;
	IGRmatrix		mtx ;
	IGRshort		mtxType ;
	struct VDve_elem_buf	*elmList ;
#endif

/*
NAME
	VDdrwSelectCompsObj

DESCRIPTION
	This function classifies a located object and performs the functions
	necessary to process the object.

	Following is a list of classes and the functions performed:

	   Composite Surface/Curve or Solid:  Get each component and
	                                      create sort records for them

	   Surface, Curve, or Point:          Create a sort record for it

	   Graphic Group or Cell:             Get each component and call
	                                      VDdrwSelectCompsObj
	                                      recursively on them

	   Symbol Header:                     Build a new environment matrix
	                                      for the symbol, get each
	                                      component and call
	                                      VDdrwSelectCompsObj
	                                      recursively

	   Relative Header:		      Get the relative parent object
					      and use there surface with the
					      same environment matrix.

PARAMETERS
	msg	(OUT)- return status.
	option	(IN) - graphical type needed.
	elmId	(IN) - the element whose sort record is to be built
	elmEnv	(IN) - the environment of the element, can be NULL
	mtx	(IN) - the matrix of the element's environment
	mtxType (IN) - the type of 'matrix'
	elmList (IN) - module environment of the element

HISTORY
	Ad.
*/

{
	OMuword            elem_classid, comp_classid;
	IGRshort           cpMtxType;
	IGRlong            sts;
	IGRint             cpCount;
	IGRint             i;
	IGRmatrix          cpMtx;
	struct GRid        *Comps = NULL ;

	SetProc( VDdrwSelectCompsObj ); Begin 

#ifdef	vdsDEBUG
	{
	IGRchar classname[50];

	sts = om$get_classname( osnum = elmId->osnum,
	                        objid = elmId->objid,
	                        classname = classname );

        if ( 1 & sts )
	  __DBGpr_str(" Classname ", classname );
	  __DBGpr_obj(" OBJECT    ", *elmId );
	}
#endif

	/* get the classid of this object */
	sts = om$get_classid( osnum     = elmId->osnum,
	                      objid     = elmId->objid,
	                      p_classid = &elem_classid );
        if ( !(1 & sts) ) return OM_S_SUCCESS;

	if (( IS_A_SUBCLASS( elem_classid, OPP_EMSasectvw_class_id ))){

	   /*
	    * The located object is a cross section view.
	    * It is an owner of solids that need to be processed.
	    */

	   sts =
	   vd_$get_components(	msg		= msg,
				grobjId		= elmId,
				grobjEnv	= elmEnv,
				number		= &cpCount,
				components	= &Comps );
	   __CheckRC( sts, *msg, "get_components", wrapup );

	   __DBGpr_int("Cross Section View header", cpCount );

	   for( i=0; i<cpCount; i++ )
	   {
	      /*
	       * only process solids owned by the cross section view
	       */
	      sts = om$get_classid( osnum     = Comps[i].osnum,
	                            objid     = Comps[i].objid,
	                            p_classid = &comp_classid );

              if ( !(1 & sts) ) continue;

	      if( IS_A_SUBCLASS( comp_classid, OPP_EMScompsurf_class_id )){
		VDdrwSelectCompsObj(	msg, option, Comps +i, elmEnv,
					mtx, mtxType, elmList );
	      }
	   }  /* end: for ( i < cpCount ) */
	}

	else if ( ( IS_A_SUBCLASS( elem_classid, OPP_GRflxown_class_id ) ) ||
	          ( elem_classid == OPP_GRclhdr_class_id ) ||
	          ( elem_classid == OPP_GRsmdfhdr_class_id )){

	   /*
	    * The located object is a flexible grouping (graphic group),
	    * cell header, or a symbol definition header
	    *	 => 	get each component and classify them individually
	    * 		because they can be nested.
	    */
	   sts =
	   vd_$get_components(	msg		= msg,
				grobjId		= elmId,
				grobjEnv	= elmEnv,
				number		= &cpCount,
				components	= &Comps );
	   __CheckRC( sts, *msg, "get_components", wrapup );

	   __DBGpr_int("Cell/Symbol definition header", cpCount );

	   for( i=0; i<cpCount; i++ )
	     VDdrwSelectCompsObj(	msg, option, Comps +i, elmEnv,
					mtx, mtxType, elmList );
	}

	else if( IS_A_SUBCLASS( elem_classid, OPP_ACrg_collect_class_id )){

		/*
		 * Filter the collector directly before any other
		 * complex object.
		 */
	   __DBGpr_com("ACrg_collect object");
	   return OM_S_SUCCESS ;
	}
		
	else if( IS_A_SUBCLASS( elem_classid, OPP_VDrelat_hdr_class_id )){

	   /*
	    * The located object is a relative header/image object.
	    *	=>	build a new environment matrix for the objects
	    *		in the symbol, get each component and classify them
	    *		individually because they can be nested
	    */

	   IGRint		j, len = 5 ;	/* Max link list	*/
	   struct GRid		relObj,
				relList[5] ;

	   sts =
	   _VD_SEND_OBJN(	*elmId,
				GRowner.GRget_matrix( msg,
	                                              &mtxType,
	                                              mtx,
	                                              &cpMtxType,
	                                              cpMtx ));
	   __CheckRC( sts, *msg, "GRowner.GRget_matrix", wrapup );

	   sts =
	   _VD_SEND_OBJN(	*elmId,
				ACheader.ACfind_model( msg, &relObj ));
	   __CheckRC( sts, *msg, "ACheader.ACfind_model", wrapup );

	   sts =
	   _VD_SEND_OBJN(	relObj,
				VDlink.ACget_model_list(msg,
							len,
							relList,
							&len ));
	   __CheckRC( sts, *msg, "VDlink.ACget_model_list", wrapup );

	   __DBGpr_int("VDrelat_hdr ", len );

	   for( i=0; i<len; i++ )
	     VDdrwSelectCompsObj(	msg, option, relList +i, elmEnv,
/**
					cpMtx, cpMtxType, elmList );
 **/
					mtx, mtxType, elmList );
	}

	else if( IS_A_SUBCLASS( elem_classid, OPP_GRsmhdr_class_id )){

	   /*
	    * The located object is a symbol header
	    *	=>	build a new environment matrix for the objects
	    *		in the symbol, get each component and classify them
	    *		individually because they can be nested
	    */

	   /* SOs can't be applied to symbols so they must be */
	   /* be ignored if we are outputting SOs             */

	   sts =
	   _VD_SEND_OBJN(	*elmId,
				GRowner.GRget_matrix( msg,
	                                              &mtxType,
	                                              mtx,
	                                              &cpMtxType,
	                                              cpMtx ));
	   __CheckRC( sts, *msg, "GRowner.GRget_matrix", wrapup );

	   sts =
	   vd_$get_components(	msg		= msg,
				grobjId		= elmId,
				grobjEnv	= elmEnv,
				number		= &cpCount,
				components	= &Comps );
	   __CheckRC( sts, *msg, "get_components", wrapup );

	   __DBGpr_int("Symbol header", cpCount );

	   for( i=0; i<cpCount; i++ )
	     VDdrwSelectCompsObj(	msg, option, Comps +i, elmEnv,
					cpMtx, cpMtxType, elmList );
	}

	else if( (IS_A_SUBCLASS( elem_classid, OPP_ACcpx_class_id ) ) ||
	         (IS_A_SUBCLASS( elem_classid, OPP_AScontents_class_id ) ) ||
	         (IS_A_SUBCLASS( elem_classid, OPP_ASnode_class_id ))){

	   /*
	    * element is an associative object that could own geometry
	    *	=>	getits components and  classify them individually
	    */
	   sts =
	   vd_$get_components(	msg		= msg,
				grobjId		= elmId,
				grobjEnv	= elmEnv,
				number		= &cpCount,
				components	= &Comps );
	   __CheckRC( sts, *msg, "get_components", wrapup );

	   __DBGpr_int("Associative Complex", cpCount );

	   for( i=0; i<cpCount; i++ )
	      VDdrwSelectCompsObj(	msg, option, Comps +i, elmEnv,
					mtx, mtxType, elmList );
	}

	else if( IS_A_SUBCLASS(elem_classid, OPP_SKmgr_class_id )){

	   /*
	    * SKmgr is an ancestor
	    *	=>	the object is a profile get its components a
	    *		classify them
	    */
	   sts =
	   vd_$get_components(	msg		= msg,
				grobjId		= elmId,
				grobjEnv	= elmEnv,
				number		= &cpCount,
				components	= &Comps );
	   __CheckRC( sts, *msg, "get_components", wrapup );

	   __DBGpr_int("Profile (SKmgr)", cpCount );

	   for( i=0; i<cpCount; i++ )
	      VDdrwSelectCompsObj(	msg, option, Comps +i, elmEnv,
					mtx, mtxType, elmList );

	}

	else if( IS_A_SUBCLASS(elem_classid, OPP_EMSsolid_class_id )){

	   /*
	    * Do some special checking on Solids.
	    */
	   __DBGpr_com(" EMSsolids " );

	   if( option & VD_K_gm_SOLIDS ){

		VD_drwBuildCompRcd(	msg, elmId, elmEnv,
					mtx, mtxType, elmList );
           }
           else{
	     sts =
	     vd_$get_components(msg		= msg,
				grobjId		= elmId,
				grobjEnv	= elmEnv,
				number		= &cpCount,
				components	= &Comps );
	     __CheckRC( sts, *msg, "get_components", wrapup );

	     for( i=0; i<cpCount; i++ )
	       VDdrwSelectCompsObj(	msg, option, Comps +i, elmEnv,
					mtx, mtxType, elmList );
	  }
	}

	else if( IS_A_SUBCLASS(elem_classid, OPP_EMScomposite_class_id )){

	   /*
	    * EMScomposite is an ancestor
	    */

	   /*
	    * object is a mass properties object
	    *	=>	ignore it
	    */
	   if ( IS_A_SUBCLASS( elem_classid, OPP_EMSmassprop_class_id ) )
	      return OM_S_SUCCESS;

	   /*
	    * Get ride of non graphical composite objects.
	    *
	    * if(! (IS_A_SUBCLASS( elem_classid, OPP_GRcompcurve_class_id )) ||
	    *	(IS_A_SUBCLASS( elem_classid, OPP_EMScompsurf_class_id )))
	    *    return OM_S_SUCCESS;
	    */
		
	   sts =
	   vd_$get_components(	msg		= msg,
				grobjId		= elmId,
				grobjEnv	= elmEnv,
				number		= &cpCount,
				components	= &Comps );
	   __CheckRC( sts, *msg, "get_components", wrapup );

	   for( i=0; i<cpCount; i++ )
	     VDdrwSelectCompsObj(	msg, option, Comps +i, elmEnv,
					mtx, mtxType, elmList );
	}

	else if( IS_A_SUBCLASS( elem_classid, OPP_EMSsurface_class_id )){

	     __DBGpr_obj("Surface   ", *elmId );

	    if( option & VD_K_gm_SURFACE )
	    	VD_drwBuildCompRcd(	msg, elmId, elmEnv,
					mtx, mtxType, elmList );
	      
	}
	else if( IS_A_SUBCLASS( elem_classid, OPP_GRbspline_class_id )){

	   if( IS_A_SUBCLASS( elem_classid, OPP_GRpoint_class_id )){

	      __DBGpr_obj("Point    ", *elmId );

	      if( option & VD_K_gm_POINT )
	          VD_drwBuildCompRcd(	msg, elmId, elmEnv,
					mtx, mtxType, elmList );
	   } 
	   else{

	      __DBGpr_obj("Curve    ", *elmId );

	      if( option & VD_K_gm_WIREFRAME )
	          VD_drwBuildCompRcd(	msg, elmId, elmEnv,
					mtx, mtxType, elmList );
	   }
	} 

	else if( IS_A_SUBCLASS( elem_classid, OPP_GRtext_class_id )){

	   /*
	    * GRtext is an ancestor
	    *	=>	do nothing (because output is always planar)
	    */
	
	      __DBGpr_obj("Text    ", *elmId );

	     if( option & VD_K_gm_TEXT )
	         VD_drwBuildCompRcd(	msg, elmId, elmEnv,
					mtx, mtxType, elmList );
	} 

	else{
	   __DBGpr_com("Unclassifiable object" );
	}

	wrapup :

		_FREE( Comps );

	/*
	 * The fact that the function is recursive, return TRUE on all
	 * the cases and let it proceed processing.
	 */
		sts = MSSUCC ;
		*msg = MSSUCC ;
		End
		return sts ;

}  /* VDdrwSelectCompsObjs */

/*---- VD_SelectCompsObj -------------------------------------------*/

#if defined(__STDC__)
long VD_SelectCompsObj(	IGRlong			*msg,
			IGRint			option,
			IGRint			count,
			struct GRid		*grIds,
			struct GRobj_env	*objEnvs,
			struct GRmd_env		*theEnv,
			struct VDve_elem_buf	*elmList )
#else
long VD_SelectCompsObj( msg, option, count, grIds, objEnvs, theEnv, elmList )

	IGRlong			*msg ;
	IGRint			option ;
	IGRint			count ;
	struct	GRid		*grIds ;
	struct	GRobj_env	*objEnvs ;
	struct	GRmd_env	*theEnv ;
	struct	VDve_elem_buf	*elmList ;
#endif

/*
NAME
	VD_SelectCompsObj

DESCRIPTION
	This function classifies a located object and performs the functions
	necessary to process the object. This function allows you to process
	more then one element at the time.

	Following criterias are allowed:

PARAMETERS
	msg	(OUT)- return status.
	option	(IN) - graphics object type.
	count	(IN) - number of input objects.
	grIds	(IN) - the element whose sort record is to be built
	objEnvs (IN) - elmId + elmEnv.
	theEnv	(IN) - the environment of the element, can be NULL
	elmList (IN/OUT) - resulted list with found elements

HISTORY
	Ad.
*/

{
	IGRlong            sts = OM_S_SUCCESS ;
	IGRint             i;

	SetProc( VD_SelectCompsObj ); Begin 

	*msg = MSSUCC ;

	if( ! elmList )	goto wrapup ;

	/*
	 * Test the output buffer.
	 */
	if( elmList->obj_info_p == NULL ){
		elmList->count   = 0 ;
		elmList->buf_siz = 0 ;
	}


	if( objEnvs ){
	  for( i=0 ; i<count ; i++ ){

		sts =
		VDdrwSelectCompsObj(	msg,
					option,
					&( objEnvs[i].obj_id ),
					&( objEnvs[i].mod_env ),
					objEnvs[i].mod_env.md_env.matrix,
					objEnvs[i].mod_env.md_env.matrix_type,
					elmList );
	  }
	}
	else{
	  for( i=0 ; i<count ; i++ ){
		
		sts =
		VDdrwSelectCompsObj(	msg,
					option,
					grIds +i,
					theEnv,
					theEnv->md_env.matrix,
					theEnv->md_env.matrix_type,
					elmList );
	  }
	}

	__DBGpr_int(" Found", elmList->count );
	if( elmList->count ){
		sts = MSSUCC ;
		*msg = MSSUCC ;
	}

	wrapup:

		End
		return sts;
}

end implementation Root;
