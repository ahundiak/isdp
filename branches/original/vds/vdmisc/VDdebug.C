/*
	I/VDS	Copy
*/
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
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

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
				printf( "\tP%2d: %g, %g, %g\n", i, p[0], p[1], p[2] ) ;
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
		printf( "P %2d: %g %g %g\n", i, p[0], p[1], p[2] ) ;
	}
	printf( "Rational       %d\n", sf->rational ) ;
	printf( "Planar         %d\n", sf->planar ) ;
	printf( "U phy. closed  %d\n", sf->u_phy_closed ) ;
	printf( "V phy. closed  %d\n", sf->v_phy_closed ) ;
	
} /* VD_dumpSurface */
/*----------------------------------------------------------------------------*/
VD_dumpClass( o ) struct GRid *o ; {
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

