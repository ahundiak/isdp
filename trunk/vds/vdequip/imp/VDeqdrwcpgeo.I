/* $Id: VDeqdrwcpgeo.I,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/imp/VDeqdrwcpgeo.I
 *
 * Description:
 *
 * Dependencies:
 *	VDS Associative Visualization Process.
 *
 * Revision History:
 *	$Log: VDeqdrwcpgeo.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
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
# Revision 1.3  1995/06/14  22:29:52  pinnacle
# Replaced: vdequip/imp/VDeqdrwcpgeo.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *	06/13		adz		The a.v.p process is not using the
 *		method NDdrawing_copy_geom. The argumnents are no more 
 *		corresponding to the information request.
 *
 *
 *	OBSOLETE	OBSOLETE	OBSOLETE	OBSOLETE
 *
 ***************************************************************************/

class implementation VDequipment ;

#include "AS_status.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "v_drw.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "v_drwmacros.h"

/*
 * Definition of the structure for drawing extraction.
 */

#define _MALLOC( nelem, type )  \
        (type *) malloc( (unsigned) ( (nelem) * sizeof( type ) ) )

/*----------------------------------------------------------------------------*/
double *VDmxorigin( mx, origin ) const double *mx ; double *origin ; {

        origin[0] = mx[3] ;
        origin[1] = mx[7] ;
        origin[2] = mx[11] ;

        return origin ;

} /* VDmxorigin */

/*----------------------------------------------------------------------------*/
method NDdrawing_copy_geom(	struct GRid	*selected_elements ;
				int		nb_elements ;
				struct GRid	**outList ;
				int		*outCount ;
				double		*vector,
						*point ;
				int		*levelMask ;
				struct IGRlbsys *lbsys ;
				struct GRmd_env *from_env,
						*to_env ) {

	long			sts,
				msg ;
	IGRchar			*fileName = NULL ;
	struct GRsymbology	mySymb ;
	VDpartAttr		Attr ;

	*outCount	= 0 ;
	*outList	= NULL ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( &msg, &mySymb ),
			targetid= my_id ) ;
	as$status( sts = sts, action = goto wrapup );
	as$status( sts = msg, action = goto wrapup );

	if( DPlevel_check( mySymb.level, levelMask ) ) {

		struct IGRplane		drawingPlane,
					viewPlane ;
		IGRvector		viewVector ;
		IGRpoint		viewPoint ;
		struct GRid		moi ;
		VD_drwOutputData	*output = NULL ;

		drawingPlane.point	= point ;
		drawingPlane.normal	= vector ;
		
		viewPlane.point		= VDmxorigin(lbsys->matrix, 
		 				      viewPoint ) ;
		viewPlane.normal	= vector ;
		VD_vccpy( viewVector, vector ) ;

		moi.objid = my_id ;
		moi.osnum = OM_Gw_current_OS ;

		/*
		 * Invoke Drawing Extraction Language Interpreter.
		 */
		sts = vd_$drwExecConfig(msg		= &msg,
					elmId		= &moi,
					elmEnv		= from_env,
					drwPlane	= &drawingPlane,
					viewPlane	= &viewPlane,
					viewVector	= viewVector,
					drwEnv		= to_env,
					drwLbsys	= lbsys,
					selCount	= nb_elements,
					selList		= selected_elements,
			filename = ( fileName ) ? fileName : NULL ,
					output		= &output ) ;

		if( sts & 1 & msg ) {
			int			n	= 0 ;
			VD_drwOutputData	*p	= output ;
			while( p ) { n += p->set.count ; p = p->next ; }

			if( n ) {
				*outList = _MALLOC( n, struct GRid ) ;
				if( *outList ) {
					n = 0 ;
					p = output ;
					while( p ) {
						int i ;
						int max = p->set.count ;
						struct GRid *l = p->set.list ;
						for( i = 0 ; i < max ; i++ ) {
							(*outList)[n++] = l[i] ;
						}
						p = p->next ;
					}
					*outCount = n ;
				}
			}
			VD_drwFreeOutputData( &output ) ;
		}

	} else sts = OM_S_SUCCESS ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method NDdrawing_copy_geom */
/*----------------------------------------------------------------------------*/

end implementation VDequipment ;

