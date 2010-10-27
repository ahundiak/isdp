/* $Id: VDdrwrmfmlst.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwrmfmlst.I
 *
 * Description:
 *		Drawing Support functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwrmfmlst.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  21:24:46  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1995/11/21  00:56:54  pinnacle
# Replaced: ./vddraw/drw/VDdrwrmfmlst.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/08/23  20:05:56  pinnacle
# Replaced: vddraw/drw/VDdrwrmfmlst.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/06/27  18:31:28  pinnacle
# Replaced: vddraw/drw/VDdrwrmfmlst.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/06/01  23:17:04  pinnacle
# Replace: vddraw/drw/VDdrwrmfmlst.I by azuurhou for OPE
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/32/95	adz		creation date
 *	05/25/95	adz		Check against orthognal reference
 *					objects.
 *	10/30/97	ah		warning message
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "igr.h"
#include "vd_ve.h"
#include "v_drw.h"
#include "v_vedef.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_fndslsinmc.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"
#include "v_visedproto.h"

from	EMSsurface	import	EMcrvsrfint;

extern	OMuword		OPP_EMSproject_class_id ;

#ifdef	NOT_NEEDED

/*----------------------------------------------------------------------------*/
long VD_drwRmObjFromList(msg,	viewVector,
				inCnt, inList,
				ftId, ftEnv,
				outCnt, outList )

long			*msg ;
double			*viewVector ;
int			inCnt ;
struct	GRobj_env	*inList ;
struct	GRid		*ftId ;
struct	GRmd_env	*ftEnv;
int			*outCnt ;
struct	GRobj_env	*outList ;
{
	/*
	 * given a list of objects. This function will delete the 
	 * active feet from the list.
	 */
	int			sts = OM_S_SUCCESS ;
	int			i,j,	/* Loop index.			      */
				relShip;/* Relation ship between two ranges.  */
	GRrange 		memRng, /* Range of object.		      */
				virRng ;/* Range of virtual element.	      */
	short			world ; /* Compute range in world coordinate. */

	/*
	 * The construction to be drawn is also on the list of located
	 * elements. So, swap the last solid / surface with the foot
	 * to project.
	 */
	SetProc( VD_drwRmObjFromList ); Begin

	*msg	= MSSUCC ;
	*outCnt	= inCnt ;

	__DBGpr_int("VD_drwRmObjFromList" , inCnt );

	/*
	 * Get range of object to extract.
	 */
	world = TRUE ;
	sts = om$send( msg	= message GRgraphics.GRgetrang(
						       msg,
						       &ftEnv->_MATRIX_TYPE,
						       ftEnv->_MATRIX,
						       &world,
						       memRng ),
		       senderid = ftId->objid,
		       targetid = ftId->objid,
		       targetos = ftId->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Range of object min", memRng    ) ;
	__DBGpr_vec( "Range of object max", memRng +3 ) ;

	/*
	 * For each located elements, if range of virtual parent of located
	 * element is in front or intersect range of object, keep located
	 * element. Otherwise reject it.
	 */
	*outCnt = 0 ;
	for( i=0, j=0 ; i<inCnt ; i++ ){

	    if( ! IF_EQ_GRID( inList[i]._grid, *ftId ) ) {

		sts = om$send( msg	= message GRgraphics.GRgetrang(
						  msg,
						  &inList[i]._matrix_type,
						  inList[i]._matrix,
						  &world,
						  virRng ),
			       senderid = inList[i]._objid,
			       targetid = inList[i]._objid,
			       targetos = inList[i]._osnum ) ;

		if( !( sts & 1 & *msg ) ) continue ;

		sts = VD_veRangeRangeRelationShip( msg,
						  virRng,
						  memRng,
						  viewVector,
						  &relShip ) ;

		if( !( sts & 1 & *msg ) 		||
		    relShip == VD_K_0_IN_FRONT_OF_1	||
		    relShip == VD_K_0_AT_THE_BACK_OF_1	) continue ;

		/*
		 * lucky object.
		 */
		outList[j++] = inList[i] ;
	    }
	    else{
		outList[j++] = inList[i] ;
	    }
	}

	*outCnt = j ;
	sts = OM_S_SUCCESS ;

	wrapup:
		__DBGpr_int(" VD_drwRmObjFromList" , *outCnt );
		End 
		return OM_S_SUCCESS ;
}

#endif


/*----------------------------------------------------------------------------*/
long VD_drwGetIndexFromElemList( msg,	viewVector, elmList,
					inCnt, inList, outCnt )

long			*msg ;
double			*viewVector ;
struct	VDve_elem_buf	*elmList ;
int			inCnt ;
struct	GRobj_env	*inList ;
int			*outCnt ;	/* start index and current index */
{
	/*
	 * given a list of refenence objects for one object. This routine
	 * will find the next object which is in front of the found edges 
	 * of the input object. When no object is found, this means that the
	 * object is not hidden by other surfaces or solids.
	 */
	int			sts = OM_S_SUCCESS ;
	int			i,e,j,	/* Loop index.			      */
				relShip;/* Relation ship between two ranges.  */
	GRrange 		memRng, /* Range of object.		      */
				virRng ;/* Range of virtual element.	      */
	short			world ; /* Compute range in world coordinate. */
	IGRvector		normal ;	/* get normal of object	      */

// Get rid of warning message
#ifdef	vdsDEBUG
	enum	GRdpmode	dpmode ;
#endif

	struct	IGRbsp_surface	*sfGeom ;

	/*
	 * The construction to be drawn is also on the list of located
	 * elements. So, swap the last solid / surface with the foot
	 * to project.
	 */

	SetProc( VD_drwGetIndexFromElemList ); Begin

	*msg	= MSSUCC ;
	sfGeom	= NULL ;

	/*
	 * For each located elements, if range of virtual parent of located
	 * element is in front or intersect range of object, return located
	 * element. 
	 */

	j       = *outCnt ;
	*outCnt = inCnt ;	/* set default to end of list. */

	world = TRUE ;
	for( i=j ; i<inCnt ; i++ ){

	    __DBGpr_int( "Check Object" , i );
	    __DBGpr_obj( "Check Object" , inList[i]._grid );

	    if( vd_$is_ancestry_valid(	object	= &inList[i]._grid,
					classid	= OPP_EMSproject_class_id )){
	      _FREE( sfGeom );
	      sts =
	      vd_$get_geometry(	msg	= msg,
				grobjId	= & inList[i]._grid,
				grobjEnv= & inList[i].mod_env,
				geometry= & sfGeom );
	      if( sts & *msg & 1){

	        __DBGpr_int( " Surface Planer ", sfGeom->planar );

	        sts = 
	        vd_$get_normal(	msg	= msg,
				sfId	= & inList[i]._grid,
				sfEnv	= & inList[i].mod_env,
				normal	= normal );
	        if( sts & *msg & 1){
	          if( sfGeom->planar &&
		    VD_orthoVectors( viewVector, normal )){

			__DBGpr_vec( "\tnormal", normal );
			__DBGpr_obj( "Surface Orthogonal ", inList[i]._grid );
			continue ;
	  	  }
	        }
	      }
	    } /* is_ancestry_valid */

	    sts = om$send( msg	= message GRgraphics.GRgetrang(
						  msg,
						  &inList[i]._matrix_type,
						  inList[i]._matrix,
						  &world,
						  virRng ),
			   senderid = inList[i]._objid,
			   targetid = inList[i]._objid,
			   targetos = inList[i]._osnum ) ;

	    if( !( sts & 1 & *msg ) ){
		__DBGpr_obj("ERROR: GetRange ", inList[i]._grid );
		continue ;
	    }

	    /*
	     * get the range of each of the found edges and compare.
	     */
	    for( e=0 ; e<elmList->count ; e++ ){

		sts =
		om$send(msg	= message GRgraphics.GRgetrang(
					  msg,
					  &elmList->obj_info_p[e]._matrix_type,
					  elmList->obj_info_p[e]._matrix,
					  &world,
					  memRng ),
		       senderid = elmList->obj_info_p[e]._objid,
		       targetid = elmList->obj_info_p[e]._objid,
		       targetos = elmList->obj_info_p[e]._osnum ) ;

		if( !( sts & 1 & *msg ) ){
		    __DBGpr_obj("ERROR: GetRange ", 
					elmList->obj_info_p[e]._grid );
		    continue ;
		}

		sts = VD_veRangeRangeRelationShip(	msg,
							virRng,
							memRng,
							viewVector,
							&relShip ) ;

		if( !( sts & 1 & *msg ) 		||
			relShip == VD_K_0_IN_FRONT_OF_1	||
			relShip == VD_K_0_AT_THE_BACK_OF_1 ) continue ;

		/*
		 * lucky object.
		 */

#ifdef	vdsDEBUG
		__DBGpr_int(" edges number ", e );
		dpmode = GRhd ;
                vd_$bulk_display(       dpmode  = dpmode,
                                        count   = 1,
                                        objenvs = elmList->obj_info_p +e );

		__DBGpr_vec( "Range of object min", virRng    ) ;
		__DBGpr_vec( "Range of object max", virRng +3 ) ;
		__DBGpr_vec( "Range of edge   min", memRng    ) ;
		__DBGpr_vec( "Range of edge   max", memRng +3 ) ;
#endif
		*outCnt = i ;
		goto wrapup ;
	    } /* for each edge. */
	}

	*msg = MSSUCC ;
	sts = OM_S_SUCCESS ;

	wrapup:
		__DBGpr_int(" VD_drwGetIndexFromEdgList" , *outCnt );
		_FREE( sfGeom );
		End ;
		return sts ;
}
/*----------------------------------------------------------------------------*/
end implementation VDSroot ;
