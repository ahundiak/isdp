/* $Id: VDdrwfdrefsf.I,v 1.2 2001/09/04 14:24:05 ramarao Exp $  */

/* I/VDS
 *
 * File:	 vddraw/drw/VDdrwfdrefsf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Reference:
 *	$Log: VDdrwfdrefsf.I,v $
 *	Revision 1.2  2001/09/04 14:24:05  ramarao
 *	Fixed TR# 5534.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/18  19:06:08  pinnacle
# Replaced: vddraw/drw/VDdrwfdrefsf.I for:  by azuurhou for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1995/09/28  12:50:36  pinnacle
# Replaced: ./vddraw/drw/VDdrwfdrefsf.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/08/16  14:53:22  pinnacle
# Replaced: vddraw/drw/VDdrwfdrefsf.I for:  by azuurhou for vds.240
#
# Revision 1.7  1995/06/27  18:29:02  pinnacle
# Replaced: vddraw/drw/VDdrwfdrefsf.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/05/01  16:19:42  pinnacle
# Replace: vddraw/drw/VDdrwfdrefsf.I by azuurhou for OPE
#
# Revision 1.2  1995/04/03  16:30:44  pinnacle
# Replaced: vddraw/drw/VDdrwfdrefsf.I by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/03/95	adz		creation date.
 *	04/25/95	adz		Memeory Free problem in fnc.
 *	06/02/95	adz		Option Changed in vd$select_obj_comp.
 *	08/15/95	adz		code correction.
 *	09/27/95	adz		checking ref count.
 */

class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "vd_ve.h"
#include "vddrwattr.h"
#include "v_drw.h"
#include "v_drwenv.h"
#include "v_vedef.h"
#include "v_edgedef.h"
#include "v_edgemacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_drwdef.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"

/*----------------------------------------------------------------------------*/

long VD_drwFindRefSurfacesOfObject(	msg, envInfo, inp, xData,
					ssList, ssCount )

long			*msg ;
VD_drwEnvInfo		*envInfo ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData;
struct GRobj_env	**ssList ;
int			*ssCount ; {

	/*
	 * Given a object ( inp->elmId, inp->elmEnv ) to extract, the view
	 * vector ( inp->drwInfo.viewVector ) of extraction and the set name
	 * of the list oflocated elements, this function returns the
	 * solids / surfaces ( ssList, ssCount ) near to the member which
	 * to be used for extracting object.
	 * The envInfo contains the names of feets which are used to support
	 * an specific representation. 
	 * The envelope flags inside this structure determine to put
	 * the main object to the list of reference objects.
	 *
	 * Note :
	 * ------
	 *	'*ssList' is allocated and hence must be freed by the caller
	 *	with 'free( *ssList )'.
	 */

	long			sts ;	/* OM completion code.		      */
	int			i,	/* Loop index.			      */
				count,	/* Size of the above list.	      */
				relShip;/* Relation ship between two ranges.  */
	GRrange 		memRng; /* Range of object.		      */
	short			world ; /* Compute range in world coordinate. */
	int			setCount ;
	struct	GRobj_env	*setList ;
	GRrange			*setRange ;	/* reference list of range    */
	struct	VDve_elem_buf	buf ;

	SetProc( VD_drwFindRefSurfacesOfObject ); Begin

	/*
	 * initialization output list.
	 */
	*msg     = MSSUCC ;
	*ssList  = NULL ;
	*ssCount = 0 ;

	count    = 0 ;

	setCount = 0 ;
	setList  = NULL ;
	setRange = NULL ;

	buf.count	= 0 ;
	buf.buf_siz	= 0 ;
	buf.obj_info_p	= NULL ;

	VD_drwGetTransMode( msg, inp, &xData->selectMask );

	if( xData->selectMask != VD_K_drwTrans ){
		__DBGpr_com(" process selection mask ");
		sts =
		VD_drwGetSelectSetObjects( msg, inp, xData,
					   &setCount, &setList, &setRange);
		__CheckRC( sts, *msg, "VD_drwGetSelectSetObjects", wrapup );
	}
	else{
/*
		sts =
		VD_drwGiveSetInfo( msg, inp->drwInfo.drwEnv, inp->refSetName,
			 		&setCount, &setList, &setRange);
		__CheckRC( sts, *msg, "VD_drwGiveSetInfo", wrapup );
*/
	}

	/*
	 * Get range of object to extract.
	 */
	world = TRUE ;
	sts = om$send( msg	= message GRgraphics.GRgetrang(
						msg,
						&inp->elmEnv->_MATRIX_TYPE,
						inp->elmEnv->_MATRIX,
						&world,
						memRng ),
		       senderid = inp->elmId->objid,
		       targetid = inp->elmId->objid,
		       targetos = inp->elmId->osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Range of object min", memRng	) ;
	__DBGpr_vec( "Range of object max", memRng +3	) ;

	/*
	 * For each located elements, if range of virtual parent of located
	 * element is in front or intersect range of object, keep located
	 * element. Otherwise reject it.
	 */
	count = 0;
	for( i=0; i<setCount; i++ ) {

		/*
		 * check the object to treat.
		 */
	        if( IF_EQ_GRID( setList[i]._grid, *inp->elmId )){

		    /*
		     * When the envelope of the object is in process,
		     * the main object need to be added as reference object.
		     */
		    if( envInfo->env1_obj0 ){
			__DBGpr_com(" Added myId to List ");
			setList[count++] = setList[i] ;
		    }
		    continue ;
		}

		sts =
		VD_veRangeRangeRelationShip(	msg,
						setRange +i,
						memRng,
						inp->drwInfo.viewVector,
						&relShip ) ;
		if( !(sts&1&*msg) 			||
		    relShip == VD_K_0_IN_FRONT_OF_1	||
		    relShip == VD_K_0_AT_THE_BACK_OF_1	) continue ;

		/*
		 * OBJECT ACCEPTED IN LIST.
		 */
		setList[count++] = setList[i] ;

		__DBGpr_obj(" RefList Object ", setList[i]._grid );
	}

#ifdef	vdsDEBUG
	__DBGpr_int(" Ref Object Count ", count );
	for( i=0 ; i<count ; i++ ){
		__DBGpr_obj(" Ref Object ", setList[i].obj_id );
	}
	vd_$bulk_display(	dpmode	= GRhd,
				count	= count,
				objenvs	= setList );
#endif

	if( count ){
	  
	    /*
	     * Set the input buffer.
	     */
	    if( envInfo->yes_no ){

		__DBGpr_com(" PROCESS the Envelope " );

		/*
		 * Inside the function "VD_drwGiveFeetsBasedOnRep", the
		 * field "env1_obj0" is used to keep either the envelope (1)
		 * or the main object (0) feets.
		 * We need to find the reference objects, reference envelopes
		 * are not needed.
		 * The resulting feet objects are stored in the buf, which
		 * is used as both input and output buffer. The input buffer
		 * if freeed when any result is found.
		 */
		envInfo->env1_obj0 = FALSE ;

		buf.count	= count ;
		buf.buf_siz	= setCount ;
		buf.obj_info_p	= setList ;
		setList		= NULL  ;

		sts =
		VD_drwGiveFeetsBasedOnRep( msg, &buf, envInfo );

		count	= buf.count ;
		setList = buf.obj_info_p ;

		buf.count	= 0 ;
		buf.buf_siz	= 0 ;
		buf.obj_info_p	= NULL ;
	    }

	    /*
	     * get all the surface/solid objects and NOT wireframe objects.
	     * The resulting list is used as list of reference surfaces to
	     * compare the main object against the reference surfaces in 
	     * front or intersection with the object.
	     */
            sts =
            vd_$select_obj_comps(msg    = msg,
                                option  = VD_K_gm_SURFACE,
                                count   = count,
                                objEnvs = setList,
                                elmList = &buf );
	    __CheckRC( sts, *msg, "vd_$select_obj_comps", wrapup );

#ifdef	vdsDEBUG
            __DBGpr_int(" Ref Surface Count", buf.count );
	    for( i=0 ; i<buf.count ; i++ ){
		__DBGpr_obj(" Ref Surface ", buf.obj_info_p[i].obj_id );
	    }
	    vd_$bulk_display(	dpmode	= GRhd,
				count	= buf.count,
				objenvs	= buf.obj_info_p );
#endif

	    *ssList  = buf.obj_info_p ;
	    *ssCount = buf.count ;

	    buf.obj_info_p = NULL ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

		if( !(sts&*msg&1)){
			_FREE( buf.obj_info_p );
		}

		_FREE( setRange );
		_FREE( setList );

		End
		return sts ;

} /* VD_drwFindRefSurfacesOfObject */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
