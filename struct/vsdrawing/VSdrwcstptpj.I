/* $Id: VSdrwcstptpj.I,v 1.1.1.1 2001/01/04 21:10:33 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        vsdrawing/VSdrwcstptpj.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwcstptpj.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:33  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/02/24  21:49:32  pinnacle
# Replaced: vsdrawing/VSdrwcstptpj.I for:  by mdong for struct
#
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 02/22/99	Ming		TR179900301
 *
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <stdlib.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "EMSmsgdef.h"
#include "fontdef.h"
#include "font.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Include of function prototypes.
 */
#include "vsdrwproto.h"
#Include "vsvecmxproto.h"

extern OMuword		OPP_GRpoint_class_id ;

extern long		EFproject_any_curve_on_planen() ;

/*----------------------------------------------------------------------------*/
long VSdrwCstPartProj( msg, inp, xData, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
VSdrwGraphicGroup	*outp ; {

	/*
	 * This function extracts the projection of a part.
	 */

	long			sts ;		/* OM completion code.	      */
	int			i,		/* Loop on part faces.	      */
				j ;		/* Loop on wireframes.	      */
	int			fcCount ;	/* Count of part faces.       */
	struct GRid		*fcList ;	/* List of part faces.	      */
	int			fcDrwCount ;	/* Count of faces to extract  */
						/* drawing.		      */
	struct GRid		*fcDrwList ;	/* List of faces to extract   */
						/* drawing.		      */
	struct GRvg_construct	cst ;		/* Construction list for      */
						/* wireframes.		      */
	struct IGRdisplay	dspVis, 	/* Display for visible	      */
						/* wireframes.		      */
				dspHid ;	/* Display for hidden	      */
						/* wireframes.		      */
	struct GRid		*wfList ;	/* Wireframes of face.	      */
	int			wfCount ;	/* Count of wireframes.       */
	int			wfHidden ;	/* Wireframe hidden ?	      */
	struct GRid		*pjList ;	/* Projected wireframes.      */
	int			pjCount ;	/* Count of projected	      */
						/* wireframes.		      */
	OMuword 		pjClassid ;	/* Class of the projected     */
						/* wireframe.		      */

	SetProc( VSdrwCstPartProj ); Begin

	/*
	 * Initialize data.
	 */
	outp->list  = NULL ;
	outp->count = 0 ;

	fcList	= fcDrwList	= pjList	= wfList	= NULL ;
	fcCount = fcDrwCount	= pjCount	= wfCount	= 0 ;

	__DBGpr_obj( "Part to draw", *(inp->elmId) ) ;
	__DBGpr_vec( "Drawing plane P",	inp->drwInfo.drwPlane->point ) ;
	__DBGpr_vec( "Drawing plane N", inp->drwInfo.drwPlane->normal ) ;
	__DBGpr_vec( "View vector", inp->drwInfo.viewVector ) ;

	if( VSorthoVectors( inp->drwInfo.drwPlane->normal,
	                    inp->drwInfo.viewVector ) ) {
           if( xData->verbose ) {
	     double *vw = inp->drwInfo.viewVector ;
	     double *dn = inp->drwInfo.drwPlane->normal ;
	     VSdrwPrintf( "!!! View vector (%g,%g,%g) is parallel to ...\n",
	                  vw[0], vw[1], vw[2] ) ;
	     VSdrwPrintf( "!!! ... drawing plane (normal=%g,%g,%g): cannot project\n",
	                  dn[0], dn[1], dn[2] ) ;
	   }
	   vs$inv_arg() ;	                
	}

	dspVis = dspHid = xData->overrides.elmDisplay ;
	dspHid.style = xData->overrides.dpAttr.hiddenStyle ;

	/*
	 * Construct construction list for wireframes.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &dspVis,
			   Cnst_list	= cst ) ;

	/*
	 * Get faces of part.
	 */
	sts = VSdrwGetFacesOfPart( msg,
				   inp->elmId,
				   inp->elmEnv,
				   &fcCount,
				   &fcList ) ;
	__CheckRC( sts, *msg, "VSdrwGetFacesOfPart", wrapup ) ;

	/*
	 * Keep only faces which have their normals not orthogonal to
	 * view vector.
	 */
	sts = VSdrwFindPartFacesNotOrthoToViewVect( msg,
						    inp->drwInfo.viewVector,
						    fcCount,
						    fcList,
						    inp->elmEnv,
						    &fcDrwCount,
						    &fcDrwList ) ;
	__CheckRC( sts, *msg, "VSdrwFindPartFacesNotOrthoToViewVect", wrapup ) ;

	/*
	 * For each face which has its normal not orthogonal to view vector,
	 * create the wireframe model of face. For each wireframe, if it is
	 * hidden  by other faces, project the wireframe to drawing plane using
	 * a 'hidden' symbology, otherwise project the wireframe using a
	 * 'visible' symbology.
	 */
	for( i=0; i<fcDrwCount; i++ ) {

		__DBGpr_obj( "Face to draw", fcDrwList[i] ) ;
/*
		sts = VSdrwSfToWireFrame( msg,
					  fcDrwList+i,
					  inp->elmEnv,
					  &cst,
					  &wfCount,
					  &wfList ) ;
		__CheckRC( sts, *msg, "VSdrwSfToWireFrame", wrapup ) ;
*/
		sts = VSdrwObjectToWireFrame( 	msg, 
						fcDrwList+i,
						inp->elmEnv,
						&cst,
						&wfCount,  
						&wfList ) ;
		__CheckRC( sts, *msg, "VSdrwObjectToWireFrame", wrapup ) ;
		/*
		 * Reallocate memory for projected wireframe.
		 */
		/* commented by Ming for TR179900301
		if( pjCount ) {
			if( !( pjList = _REALLOC( pjList, pjCount + wfCount,
						  struct GRid ) ) )
				vs$mem_fail() ;
		} else {
			if( !( pjList = _MALLOC( wfCount, struct GRid ) ) )
				vs$mem_fail() ;
		}
		*/

		/*
		** TR179900301 by Ming
		*/
		if( pjCount )
		{
		  if( wfCount )
		  {
		    if( !(pjList = _REALLOC(pjList, pjCount+wfCount,
					    struct GRid)) )
			vs$mem_fail() ;
		  }
		  else
		    continue;
		}
		else
		{
                  if( wfCount )
                  {
		    if( !( pjList = _MALLOC( wfCount, struct GRid ) ) )
			vs$mem_fail() ;
                  }
                  else
                    continue;
		}

		/*
		 * For each wireframe, project wireframe to drawing plane
		 * using a 'hidden' symbology if the wireframe is hidden,
		 * otherwise project wireframe using a 'visible' symbology.
		 */

		for( j=0; j<wfCount; j++ ) {

			__DBGpr_obj( "Wireframe", wfList[j] ) ;

			/*
			 * See if wireframe is hidden.
			 */
			sts = VSdrwIsEdgeHiddenByFaces(	msg,
							wfList + j,
							cst.env_info,
							i,
							inp->drwInfo.viewVector,
							inp->elmEnv,
							fcDrwCount,
							fcDrwList,
							&wfHidden ) ;
			__CheckRC( sts, *msg, "VSdrwIsEdgeHiddenByFaces",
				   wrapup ) ;

			if( wfHidden ) {
				__DBGpr_com( "\tis HIDDEN" ) ;
				cst.display = &dspHid ;
			} else {
				__DBGpr_com( "\tis VISIBLE" ) ;
				cst.display = &dspVis ;
			}

			/*
			 * Project wireframe onto drawing plane.
			 */
			sts = EFproject_any_curve_on_planen(
							msg,
							&cst,
							wfList + j,
							cst.env_info,
							inp->drwInfo.drwPlane,
							inp->drwInfo.viewVector,
							pjList + pjCount,
							&pjClassid ) ;
			__CheckRC( sts, *msg, "EFproject_any_curve_on_planen",
				   wrapup ) ;

			__DBGpr_obj( "Projected wireframe", pjList[pjCount] );
			__DBGpr_com( "Is a point ?" ) ;

			/*
			 * Do not take points.
			 */
			if( om$is_ancestry_valid(
					   subclassid	= pjClassid,
					   superclassid = OPP_GRpoint_class_id )
					   == OM_S_SUCCESS ) {

				__DBGpr_com( "\t-> Yes" ) ;

				vs$bulk_delete( grids  = pjList + pjCount,
						theEnv = cst.env_info ) ;

			} else {
				__DBGpr_com( "\t-> No" ) ;
				pjCount++ ;
			}
		}

		/*
		 * Delete constructed wireframes.
		 */
		vs$bulk_delete( grids  = wfList,
				count  = wfCount,
				theEnv = cst.env_info ) ;

		_FREE( wfList ) ;
		wfList	= NULL ;
		wfCount = 0 ;
	}

	/*
	 * Remove projected curves which are covered by other projected curves.
	 */
	sts = VSdrwRmCoveredCurves( msg,
				    dspHid.style,
				    dspVis.style,
				    pjCount,
				    pjList,
				    cst.env_info,
				    &outp->count,
				    &outp->list ) ;
	__CheckRC( sts, *msg, "VSdrwRmCoveredCurves", wrapup ) ;

	__DBGpr_objlist( "Drawing of part", outp->count, outp->list ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( wfCount && wfList )
				vs$bulk_delete( grids  = wfList,
						count  = wfCount,
						theEnv = cst.env_info ) ;

			if( pjCount && pjList )
				vs$bulk_delete( grids  = pjList,
						count  = pjCount,
						theEnv = cst.env_info ) ;

			_FREE( outp->list ) ;
			outp->list  = NULL ;
			outp->count = 0 ;
		}

		_FREE( fcList	 ) ;
		_FREE( fcDrwList ) ;
		_FREE( wfList	 ) ;
		_FREE( pjList	 ) ;

		End
		return sts ;

} /* VSdrwCstPartProj */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
