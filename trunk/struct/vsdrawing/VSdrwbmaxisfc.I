/* $Id: VSdrwbmaxisfc.I,v 1.2 2001/02/20 01:18:44 build Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwbmaxisfc.I
 *
 * Description: Function to trim an axis.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwbmaxisfc.I,v $
 *      Revision 1.2  2001/02/20 01:18:44  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1  2001/02/15 23:33:30  ramarao
 *      Implemented CR# 4038.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/15/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VScpx;

#include <math.h>
#include "bserr.h"
#include "bscveval.h"
#include "bsdistptpts.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "VDobj.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vsbeamdef.h"
#include "vsbeammacros.h"
#include "vssectiondef.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsjntmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

from EMSedge	import	EMget_bcxyz_geom;
from VSbeam	import  VSgetSupportAxis;

extern int VSvertexCmp();

#define EQPARMS( t1, t2 ) VSzeroDist( fabs( (t1) - (t2) ) )

IGRlong	VSdrwGetTrimmedAxis( IGRlong		*msg,
		             struct GRobj_env  	*beamOE,
			     IGRchar		*side,
			     struct GRid	*axis,
			     struct GRmd_env	*axisEnv )
{
IGRlong			sts, *descrs=NULL;
IGRint			i, j, k, l, sfCount=0, numFaces=0, checkEdgeCount=0,
			ip[2], collectFaceCount=0, edCount=0, vxCount=0;
IGRdouble		maxDistSq, distSq, *t0, *t1, *p0, *p1, *vxList=NULL, 
			*vxParms= NULL, *previous;
IGRboolean		found=FALSE, haveFarthestPnt;
IGRchar			**faceNames=NULL, sfToCheck[100];
IGRpoint        	prjPnt;
struct GRparms  	prjParm;
struct GRid		solidId, footId, sfIdToCheck, pdelCv, loopSet,
			*sfList=NULL, *edList=NULL, *collectFaces=NULL,
			*checkEdges=NULL;
struct GRobj_env	oneSf;
OM_S_CHANSELECT		chan_select;
struct IGRbsp_surface	*sfGeom=NULL;
struct IGRbsp_curve	edGeom;
struct GRvg_construct   cst;

   SetProc( VSdrwGetBeamSurfaces ); Begin

   __DBGpr_obj( "Input Beam", beamOE->obj_id );

   sfIdToCheck.objid = NULL_OBJID;

   sprintf( sfToCheck, "%s:%s:%s", VS_K_bmGrCmpName, VS_K_bmBody, side );
   __DBGpr_str( "Surface Name to Check", sfToCheck );

   sts = vs$listBeamFaces(  msg    = msg,
                            beam   = &beamOE->obj_id,
                            count  = &numFaces,
                            names  = &faceNames,
                            descrs = &descrs );
   __CheckRC( sts, *msg, "vs$listBeamFaces", wrapup );
   __DBGpr_int("Named Faces Count", numFaces );

   sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                    msg, sfToCheck,
                                    &sfIdToCheck, NULL, NULL ),
                        senderid= beamOE->_objid,
                        targetid= beamOE->_objid,
                        targetos= beamOE->_osnum ) ;
   if( !(sts&1&(*msg) ) || sfIdToCheck.objid == NULL_OBJID ) 
   {
      __DBGpr_str("Failed to get the Surface", sfToCheck );
      sts = *msg = MSFAIL;
      goto wrapup;
   }
   __DBGpr_obj( "Surface To Check", sfIdToCheck );

   sts = vs$get_surface_edges( msg      = msg,
                               sfId     = &sfIdToCheck,
                               sfEnv    = &beamOE->mod_env,
                               edgeType = VS_K_CONTOUR_EDGES,
                               edCount  = &checkEdgeCount,
                               edList   = &checkEdges 	      );
   __CheckRC( sts, *msg, "vs$get_surface_edges", wrapup ) ;
   __DBGpr_int("Contour Edge Count to Check", checkEdgeCount );
   

   sts = VSdrwGetFacesOfPart( msg, &beamOE->obj_id, &beamOE->mod_env,
			      &sfCount, &sfList ) ;
   __CheckRC( sts, *msg, "VSdrwGetFacesOfPart", wrapup ) ;
   __DBGpr_int("Actual Surface Count", sfCount );

   if( !( collectFaces = _MALLOC( (sfCount-numFaces+1), struct GRid ) ) ) 
	vd_$mem_fail();

   collectFaces[collectFaceCount++] = sfIdToCheck;

   om$make_chanselect( channame     = "EMSedge.to_common_edge",
		       p_chanselect = &chan_select );

   for( i=numFaces; i<sfCount; i++ )
   {
       __DBGpr_obj("Surface", sfList[i] );
       edCount = 0;
       _FREE( edList );
       sts = vs$get_surface_edges( msg      = msg,
                                   sfId     = &sfList[i],
                                   sfEnv    = &beamOE->mod_env,
                                   edgeType = VS_K_CONTOUR_EDGES,
                                   edCount  = &edCount,
                                   edList   = &edList );
       if( !(sts&1&(*msg) )  )  continue;

       found = FALSE;
       for( j=0; j<edCount; ++j )
       {
	  for( k=0; k<checkEdgeCount; ++k )
	  {
             sts = om$is_objid_on_channel( osnum_c    = edList[j].osnum,
					   objid_c    = edList[j].objid,
					   objid      = checkEdges[k].objid,
					   osnum2     = checkEdges[k].osnum,
					   p_chanselect = &chan_select );
	     if( sts&1 ) { found = TRUE; break; }
	  }
	  if( found ) break;
       }
       __DBGpr_int( "Adjacent Surfaces?", found );
       if( found ) collectFaces[collectFaceCount++] = sfList[i];
   }
   __DBGpr_objlist( "Surfaces Collected", collectFaceCount, collectFaces );

   for( k=i=0; i<collectFaceCount ; i++ ) 
   {
        oneSf._grid     = collectFaces[i] ;
        oneSf.mod_env   = beamOE->mod_env ;

        sts = vs$getLoopset( msg     = msg,
                             surface = &oneSf,
                             loopset = &loopSet ) ;
        __CheckRC( sts, *msg, "vs$getLoopset", wrapup ) ;

	edCount = 0;
        edList  = NULL;

        sts = VSgetEdgesByProps( msg, &loopSet, EMED_NATURAL,
                                 &edCount, &edList ) ;
        __CheckRC( sts, *msg, "VSgetEdgesByProps", wrapup ) ;

        /*
         * Get geometry of surface : it will speed up
         */
	_FREE( sfGeom ) ;
        sts = vs$get_geometry( msg      = msg,
                               grobjId  = collectFaces + i,
                               grobjEnv = &beamOE->mod_env,
                               geometry = &sfGeom ) ;
        __CheckRC( sts, *msg, "vs$get_geometry 1", wrapup ) ;

        /*
         * Two end points per edge.
         */
        if( !vxList ) 
	{
             vxCount = 2*edCount ;
             vxList  = _MALLOC( vxCount * 3, double ) ;
             if( !vxList ) vd_$mem_fail() ;
        } 
	else 
	{
             double  *newptr ;
             vxCount += 2 * edCount ;

	     newptr = _REALLOC( vxList, vxCount*3, IGRdouble );
             if( newptr ) 
	     {
                  vxList = newptr ;
             } 
	     else 
	     {
                  _FREE( vxList ) ; vxList = NULL ; vxCount = 0 ;
                  vd_$mem_fail() ;
             }
        }

        for( j = 0 ; j < edCount ; j++ ) 
	{
             VSzeroOutEdgeGeom( &edGeom ) ;
             sts = om$send( msg = message EMSedge.EMget_bcxyz_geom(
                         msg, &beamOE->mod_env.md_env, collectFaces + i, sfGeom,
			 0, OM_K_MAXINT, FALSE, NULL, &edGeom ),
                    senderid= edList[j].objid,
                    targetid= edList[j].objid,
                    targetos= edList[j].osnum ) ;
             __CheckRC( sts, *msg, "EMSedge.EMget_bcxyz_geom", wrapup ) ;

             BScveval( &edGeom, 0., 0, (IGRpoint *) (vxList + k), msg ) ;
             k += 3 ;
             BScveval( &edGeom, 1., 0, (IGRpoint *) (vxList + k), msg ) ;
             k += 3 ;
             VSfreeEdgeGeom( &edGeom ) ;
        } 
   }

   /*
    * Remove duplicate entries.
    */
   qsort( (char *) vxList, vxCount, sizeof( IGRpoint ), VSvertexCmp ) ;
   previous = vxList ; l = 1 ; k = 3 ;

   for( i = 1 ; i < vxCount ; i++ ) 
   {
       j = i * 3 ;
       if( !VSeqPoints( previous, vxList + j ) ) 
       {
           VSvccpy( vxList + k, vxList + j ) ;
           previous = vxList + k ;
           k += 3 ; l++ ;
       }
   }
   vxCount = l ;
   __DBGpr_int( "Vertext Count", vxCount );

   if( !( vxParms = _MALLOC( vxCount, double ) ) ) vd_$mem_fail() ;

   /*
    * Project vertices onto original axis, overwriting the coordinates of
    * the vertices with those of their projections.
    */
   for( i = 0 ; i < vxCount ; i++ ) {
         sts = om$send(  msg     = message GRgraphics.GRptproject(
                                        msg, &axisEnv->_MATRIX_TYPE,
					axisEnv->_MATRIX, vxList + 3 * i,
					prjPnt, &prjParm ),
	 		senderid = NULL_OBJID,
                        targetid = axis->objid,
                        targetos = axis->osnum ) ;
         __CheckRC( sts, *msg, "GRgraphics.GRptproject", wrapup ) ;
	 __DBGpr_vec("Projection Point", prjPnt ) ;
         VSvccpy( vxList + 3 * i, prjPnt ) ;
         vxParms[i] = prjParm.u ;
   }

   /*
    * Takes the two farthest apart projected points.
    */
   maxDistSq = 0 ;
   haveFarthestPnt = FALSE ;
   for( i = 0 ; i < vxCount - 1 ; i++ ) 
   {
       for( j = 1 ; j < vxCount ; j++ ) 
       {
           distSq = BSdistptpts(   msg, vxList + 3 * i, vxList + 3 * j ) ;
           if( distSq > maxDistSq ) 
	   {
               haveFarthestPnt = TRUE ;
               maxDistSq       = distSq ;
               ip[0]           = 3 * i ;
               ip[1]           = 3 * j ;
           }
        }
    }

    if( !haveFarthestPnt ) 
    {
         sts = *msg = MSFAIL ; goto wrapup ;
    }

    t0 = vxParms + ip[0] / 3 ; p0 = vxList + ip[0] ;
    t1 = vxParms + ip[1] / 3 ; p1 = vxList + ip[1] ;

    /*
     * Order points according to their parameters on the original axis.
     */
    if( *t0 > *t1 ) 
    {
        double *tmp ;

        tmp =  t0 ; t0  =  t1 ;  t1 = tmp ;
        tmp =  p0 ; p0  =  p1 ;  p1 = tmp ;
    }
    if( EQPARMS( *t0, 0. ) && EQPARMS( *t1, 1. ) ) 
    {
        /*
         * Nothing to do.
         */
        *msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
    }

    /*
     * Resize copy: keep portion from p0 to p1.
     */

    __DBGpr_vec( "Farthest Point 0", p0 );
    __DBGpr_vec( "Farthest Point 1", p1 );

    sts = ASextract_cv( *axis, p0, p1, axisEnv, &pdelCv ) ;
    if( sts&1 )	*axis = pdelCv;
    __DBGpr_obj( "Trimmed Curve", *axis ) ;

wrapup:
   if( faceNames ) { VSfreeList( numFaces, faceNames ); faceNames = NULL; }
   _FREE( collectFaces );
   _FREE( descrs );
   _FREE( checkEdges );
   _FREE( edList );
   _FREE( sfList );
   _FREE( sfGeom ) ;
   _FREE( vxParms );
   _FREE( vxList  );
   End
   return sts;
}

end implementation VScpx;
