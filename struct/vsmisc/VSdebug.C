/*
	I/STRUCT
*/
#include <stdio.h>		/* For NULL		*/
#include <stdlib.h>		/* For malloc and free	*/
/* #include <tools.h>					*/
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
#include "vsdef.h"
#include "vsdpbdef.h"
#include "vs.h"
#include "vsdpb.h"
#include "vspart.h"
#include "vsoptdef.h"
#include "vsattr.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsbeam.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#ifdef USED
/*----------------------------------------------------------------------------*/
void VSdumpMassProps( mp ) register VSintegral *mp ; {

	printf( "Area		%g\n", mp->area				) ;
	printf( "Volume		%g\n", mp->volume			) ;
	printf( "Ixx		%g\n", mp->MofI.element.Ixx		) ;
	printf( "Iyy		%g\n", mp->MofI.element.Iyy		) ;
	printf( "Izz		%g\n", mp->MofI.element.Izz		) ;
	printf( "Ixy		%g\n", mp->MofI.element.Ixy		) ;
	printf( "Iyz		%g\n", mp->MofI.element.Iyz		) ;
	printf( "Izx		%g\n", mp->MofI.element.Izx		) ;
	printf( "Dimensions	%g, %g, %g\n",
			mp->dims[0], mp->dims[1], mp->dims[2] ) ;
	printf( "Centroid	%g, %g, %g\n",
			mp->centroid[0], mp->centroid[1], mp->centroid[2] ) ;

} /* VSdumpMassProps */
/*----------------------------------------------------------------------------*/
void VSdumpCurve( cv ) struct IGRbsp_curve *cv ; {

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
		
} /* VSdumpCurve */
/*----------------------------------------------------------------------------*/
void VSdumpSurface( sf ) struct IGRbsp_surface *sf ; {

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
	
} /* VSdumpSurface */
/*----------------------------------------------------------------------------*/
VSdumpClass( o ) struct GRid *o ; {
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

} /* VSdumpClass */
/*----------------------------------------------------------------------------*/
static void VS__dumpComponents( top, owner ) struct GRid *top, *owner ; {

	long		msg ;
	int		i,		/* Loop-on-component index	*/
			j,
			count,		/* Count of components		*/
			size,		/* Of index path		*/
			ipath[10] ;
	struct GRid	*cmpList ;
	extern OM_S_CHANSELECT AS_to_comp ;

	if( !VS_GetChanObjWithMalloc( owner, &AS_to_comp, &count, &cmpList ) ) {
		/*
		 * Not an owner.
		 */
		goto wrapup ;
	}

	for( i = 0 ; i < count ; i++ ) {
		printf( "%2d - Component [%d,%4d] PATH:", i,
			cmpList[i].osnum, cmpList[i].objid ) ;
		VSgetCmpIndexPath( &msg, top, cmpList + i, &size, ipath ) ;
		for( j = 0 ; j < size ; j++ ) {
			printf( " %2d", ipath[j] ) ;
		}
		printf( " " ) ; VSdumpClass( cmpList + i ) ; 
		VS__dumpComponents( top, cmpList + i ) ;
	}
	wrapup :
		if( count ) _FREE( cmpList ) ;
		
} /* VS__dumpComponents */
/*----------------------------------------------------------------------------*/
void VSdumpComponents( owner ) struct GRid *owner ; {

	printf( "\n*-* Dump ownership tree\n" ) ;
	printf( "Top owner [%d,%4d] ", owner->osnum, owner->objid ) ;
	VSdumpClass( owner ) ;

	VS__dumpComponents( owner, owner ) ;
	printf( "\n*-* End\n" ) ;

} /* VSdumpComponents */
/*----------------------------------------------------------------------------*/
void VSdumpSfType( type ) short type ; {

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

} /* VSdumpSfType */
/*----------------------------------------------------------------------------*/
void VSdumpEvent( event ) int event ; {

#define PRTEV( EV ) if( event & EV ) printf( "%s-", #EV ) ;

	printf( "Event 0x%x : ", event ) ;
	PRTEV(  KEYBOARD_EVENT		) ;
	PRTEV(  BUTTON_EVENT		) ;
	PRTEV(  REFRESH_EVENT		) ;
	PRTEV(  DELETE_EVENT		) ;
	PRTEV(  COVER_EVENT		) ;
	PRTEV(  KEYIN_EVENT		) ;
	PRTEV(  MENUBAR_EVENT		) ;
	PRTEV(  PTTY_EVENT		) ;
	PRTEV(  AUX_EVENT		) ;
	PRTEV(  COLLAPSE_EVENT		) ;
	PRTEV(  PROCESS_EVENT		) ;
	PRTEV(  TIMER_EVENT		) ;
	PRTEV(  WINDOW_ICON_EVENT	) ;
	PRTEV(  WINDOW_USER_ICON_EVENT	) ;
	PRTEV(  USER_EVENT		) ;
	PRTEV(  SYSTEM_EVENT		) ;
	PRTEV(  MOTION_EVENT		) ;
	PRTEV(  DIGMOTION_EVENT		) ;
	PRTEV(  SWAPVS_EVENT		) ;
	PRTEV(  EXTRA_EVENT		) ;
	printf( "\n" ) ;

} /* VSdumpEvent */
/*----------------------------------------------------------------------------*/
void VSdumpProps( props ) int props ; {

	if( props & GRIS_DISPLAYABLE	) printf( "\tDISPLAYABLE\n" ) ;
	if( props & GRIS_LOCATABLE	) printf( "\tLOCATABLE\n" ) ;
	if( props & GR_RIGID_RELATIONSHIP) printf( "\tRIGID_RELATIONSHIP\n" ) ;
	if( props & GRNOT_IN_RTREE	) printf( "\tNOT_IN_RTREE\n" ) ;
	if( props & GRIS_PLANAR		) printf( "\tPLANAR\n" ) ;
	if( props & GRIS_NEW		) printf( "\tNEW\n" ) ;
	if( props & GRIS_MODIFIED	) printf( "\tMODIFIED\n" ) ;

} /* VSdumpProps */
/*----------------------------------------------------------------------------*/
#endif /* USED */

void ShowObj( o ) struct GRid *o ; {
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
} /* ShowObj */
/*----------------------------------------------------------------------------*/

