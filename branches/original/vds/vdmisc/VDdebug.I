/* $Id: VDdebug.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDdebug.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdebug.I,v $
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
# Revision 1.1  1995/09/18  20:28:42  pinnacle
# Created: ./vdmisc/VDdebug.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/08/95	adz		Add genabgs calls.
 *
 ***************************************************************************/

class implementation Root ;

#include <stdio.h>		/* For NULL		*/
#include <stdlib.h>		/* For malloc and free	*/
#include <tools.h>
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "exdef.h"		/* Constants for exec (IGE)	*/
#include "ex.h"			/* Structs EX*			*/
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "igrdp.h"		/* Structs IGR* for display	*/
#include "gr.h"			/* Structs GR* for graphic info	*/
#include "godef.h"
#include "growner.h"
#include "emssfdef.h"
#include "v_def.h"
#include "v_.h"
#include "msdef.h"
#include "madef.h"
#include "bserr.h"
#include "bstypes.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"

from	GRvg	import	GRgenabsg;

extern	OMuword	OPP_EMSsurface_class_id ;
extern	OMuword	OPP_GRbspline_class_id ;

/*----------------------------------------------------------------------------*/

void VD_dumpCurve( cv ) struct IGRbsp_curve *cv ; {

	if( cv ) {
		int i ;
		printf( "Order       %d\n", cv->order ) ;
		printf( "Perriodic   %d\n", cv->periodic ) ;
		printf( "Non-uniform %d\n", cv->non_uniform ) ;
		printf( "Planar      %d\n", cv->planar ) ;
		printf( "Num. poles  %d\n", cv->num_poles ) ;
		printf( "Phy. closed %d\n", cv->phy_closed ) ;
		if( cv->num_poles && cv->poles ) {
			double *p ;
			for( i = 0 ; i < cv->num_poles ; i++ ) {
				p = cv->poles + i * 3 ;
				printf( "\tP%2d: %f, %g, %f\n", i, p[0], p[1], p[2] ) ;
			}
		}
		printf( "Num. knots  %d\n", cv->num_knots ) ;
		if( cv->num_knots && cv->knots ) {
			for( i = 0 ; i < cv->num_knots ; i++ ) {
				printf( "\tK%2d: %g\n", i, cv->knots[i] ) ;
			}
		}
		printf( "Rational    %d\n", cv->rational ) ;
		if( cv->rational && cv->weights ) {
			for( i = 0 ; i < cv->num_poles ; i++ ) {
				printf( "\tW%2d: %g\n", i, cv->weights[i] ) ;
			}
		}
	} else {
		printf( "curve is NULL\n" ) ;
	}
		
} /* VD_dumpCurve */
/*----------------------------------------------------------------------------*/
void VD_dumpSurface( sf ) struct IGRbsp_surface *sf ; {

	int i ; double *p ;

	if( !sf ) {
		printf( "surface is NULL\n" ) ;
		return ;
	}
	printf( "U order         %d\n", sf->u_order ) ;
	printf( "V order         %d\n", sf->v_order ) ;
	printf( "U periodic      %d\n", sf->u_periodic ) ;
	printf( "V periodic      %d\n", sf->u_periodic ) ;
	printf( "U non-uniform   %d\n", sf->u_non_uniform ) ;
	printf( "V non-uniform   %d\n", sf->v_non_uniform ) ;
	printf( "U num poles     %d\n", sf->u_num_poles ) ;
	printf( "V num poles     %d\n", sf->v_num_poles ) ;
	for( i = 0 ; i < sf->u_num_poles * sf->v_num_poles ; i++ ) {
		p = sf->poles + i * 3 ;
		printf( "P %2d: %f %f %f\n", i, p[0], p[1], p[2] ) ;
	}
	printf( "Rational       %d\n", sf->rational ) ;
	printf( "Planar         %d\n", sf->planar ) ;
	printf( "U phy. closed  %d\n", sf->u_phy_closed ) ;
	printf( "V phy. closed  %d\n", sf->v_phy_closed ) ;
	
} /* VD_dumpSurface */
/*----------------------------------------------------------------------------*/
void VD_dumpClass( o ) struct GRid *o ; {
		char C[OM_K_MAXCLASS_LEN] ; int rc ;

	C[0] = '?' ; C[1] = '\0' ;
	rc = om$get_classname(	objid = o->objid,
				osnum = o->osnum,
				classname = C ) ;
	if( rc & 1 ) {
		printf( "[%s]\n", C ) ;
	} else {
		printf( "[?]\n" ) ;
	}

} /* VD_dumpClass */
/*----------------------------------------------------------------------------*/
void VD_dumpSfType( type ) short type ; {

	switch( type ) {

#define PRTYPE( t ) case t : printf( "\t%d -> %s\n", t, #t ) ; break ;

		PRTYPE( EMfreeform_surface	)
		PRTYPE( EMcylinder		)
		PRTYPE( EMcone			)
		PRTYPE( EMelliptical_cylinder	)
		PRTYPE( EMelliptical_cone	)
		PRTYPE( EMsphere		)
		PRTYPE( EMellipsoid		)
		PRTYPE( EMtorus			)
		PRTYPE( EMpcylinder		)
		PRTYPE( EMpcone			)
		PRTYPE( EMproject		)
		PRTYPE( EMrevol			)

#undef PRTYPE

		default : printf( "\tUnknown surface type\n" ) ; break ;
	}

} /* VD_dumpSfType */
/*----------------------------------------------------------------------------*/
void VD_dumpProps( props ) int props ; {

	if( props & GRIS_DISPLAYABLE	) printf( "\tDISPLAYABLE\n" ) ;
	if( props & GRIS_LOCATABLE	) printf( "\tLOCATABLE\n" ) ;
	if( props & GR_RIGID_RELATIONSHIP) printf( "\tRIGID_RELATIONSHIP\n" ) ;
	if( props & GRNOT_IN_RTREE	) printf( "\tNOT_IN_RTREE\n" ) ;
	if( props & GRIS_PLANAR		) printf( "\tPLANAR\n" ) ;
	if( props & GRIS_NEW		) printf( "\tNEW\n" ) ;
	if( props & GRIS_MODIFIED	) printf( "\tMODIFIED\n" ) ;

} /* VD_dumpProps */
/*----------------------------------------------------------------------------*/

void VD_ShowObj( o ) struct GRid *o ; {
	char C[OM_K_MAXCLASS_LEN] ; int rc ;

	C[0] = '?' ; C[1] = '\0' ;
	rc = om$is_objid_valid(	objid = o->objid,
				osnum = o->osnum ) ;

	if( rc & 1 ) {
		rc = om$get_classname(	objid = o->objid,
					osnum = o->osnum,
					classname = C ) ;
	}
	if( rc & 1 ) {
		printf( "\tObject: %d %d [%s]\n", o->osnum, o->objid, C ) ;
	} else {
		printf( "\tObject: %d %d Class ? :\n\t", o->osnum, o->objid ) ;
		om$report_error( sts = rc ) ;
	}
	fflush( stdout ) ;
} /* VD_ShowObj */

/*----------------------------------------------------------------------------*/
void VD_dumpObject( objId, objEnv )

struct GRid		*objId ;
struct GRmd_env		*objEnv ; {

	long		msg, sts ;		/* OM return code	*/

	printf(" === dumpObject === \n");

	if( objId && objEnv ) {

          char C[OM_K_MAXCLASS_LEN] ; int rc ;

          C[0] = '?' ; C[1] = '\0' ;
          rc = om$is_objid_valid( objid = objId->objid,
                                  osnum = objId->osnum ) ;

          if( rc & 1 ) {
                rc = om$get_classname(  objid = objId->objid,
                                        osnum = objId->osnum,
                                        classname = C ) ;
          }
          if( rc & 1 ) {
                printf( "\tObject: %d %d [%s]\n",
					objId->osnum, objId->objid, C ) ;
          } else {
                printf( "\tObject: %d %d Class ? :\n\t",
					 objId->osnum, objId->objid ) ;
                om$report_error( sts = rc ) ;
          }
          fflush( stdout ) ;

	  pr_mat(" Mtx ", 4, 4, objEnv->_MATRIX );
	  printf(" MtxType : %d \n", objEnv->_MATRIX_TYPE );
	  __DBGpr_obj( " MtxId ", objEnv->md_id );

	  if( vd_$is_ancestry_valid(	object	= objId,
					classid = OPP_EMSsurface_class_id )){

		struct IGRbsp_surface	*objGeom ;

		sts =
		_VD_SEND_OBJN(	*objId,
				GRvg.GRgenabsg( &msg,
						&objEnv->_MATRIX_TYPE,
						objEnv->_MATRIX,
						(char **) &objGeom ));
		__CheckRC( sts, msg, "GRvg.GRgenabsg", wrapup ) ;
		VD_dumpSurface( objGeom );
	  }
	  else if( vd_$is_ancestry_valid(object  = objId,
					classid = OPP_GRbspline_class_id )){

		struct IGRbsp_curve	*objGeom ;

		sts =
		_VD_SEND_OBJN(	*objId,
				GRvg.GRgenabsg( &msg,
						&objEnv->_MATRIX_TYPE,
						objEnv->_MATRIX,
						(char **) &objGeom ));
		__CheckRC( sts, msg, "GRvg.GRgenabsg", wrapup ) ;
		VD_dumpCurve( objGeom );
	  }
	}

	wrapup :
		printf(" --- dumpObject --- \n");

} /* VD_dumpObject */

/*----------------------------------------------------------------------------*/

end implementation Root ;
