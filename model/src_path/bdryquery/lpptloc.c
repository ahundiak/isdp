#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "OMminimum.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bssfeval.h"
#include "bsmdistptsf.h"
#include "bsgeom_cvsf.h"
#include "bsmdptcvbx.h"
#include "PWapi/partol.h"
#include "PWapi/edptproj.h"
#include "PWapi/ptlocmac.h"
#include "PWapi/edbcxyzgeom.h"
#include "PWapi/mdstptgm.h"

#include "PWapi/lpprops.h"
#include "PWapi/lped.h"
#include "PWapi/edgeom.h"

#include "ptclass.h"

static PWboolean   IsPtOnEdge
(
   struct PWid             *p_edid,
   struct PWsfdata         *p_sfdata,
   PWpoint                 xyzpt,
   PWpoint2d               uvpt,
   double                  xyztol,
   struct PWcvpt           *p_onvertex
);


/*
 *   Aplication Function:  pwLpPtLocate().
 *   --------------------------------------
 *   Description
 *   -----------
 *
 *   This function is the lowest level driver for point locate,
 *   it works at single loop level. The output is a location
 *   information of a point and an enum.
 *
 *   Input
 *   -----
 *   PWobjid     lpobjid;        Loop objid for the query 
 *    
 *   PWosnum     lposnum;        Loop osnum for the query
 *
 *   PWpoint       xyzpt;        XYZ point if available 
 *
 *   PWpoint2d     uvpt;         UV point if XYZ point not available 
 *
 *   struct PWsfdata *p_sfdata;  Input surface geometry of the loop 
 *
 *   double       xyztol;       XYZ tolerance with which ptloc is to be
 *                                tested 
 *   Output
 *   ------
 *   PWobjid   *p_edid;    Edge id if on egde/vertex else PW_NULL_OBJID 
 *
 *   enum PW_PTLOC  *p_ptloc;
 *   
 *   struct PWcvpt  *p_edpt;    if the input point is on an edge or vertex
 *                              this sturcture returns information about the
 *                              point.
 *
 *   Possible values of enum according to loop geometry are:
 *
 *      ONVERTEX
 *      ONEDGE
 *      INHOLE
 *      INAREA
 *      OUTSIDE
 *      UNKNOWN
 */

PWresult  pwLpPtLocate
(        
          struct PWid      *p_lpid,
          PWpoint          xyzpt,
          PWpoint2d        uvpt, 
          struct PWsfdata  *p_sfdata, 
          double           xyztol, 
          enum PWptloctype *p_ptloc,
          PWobjid          *p_edid,
          struct PWcvpt    *p_edpt
)
{
   int                     i=0, numedges=0;
   BSrc                    rc=BSSUCC;
   double                  tmp_dist, uvtol;
   PWobjid                 *p_lpedges=NULL;
   PWpoint                 loc_xyzpt, tmp_ptxyz;
   PWresult                retval=PW_K_Success;
   PWrange2d               lprange;
   PWboolean               inside=FALSE, is_ploop=FALSE, onedge=FALSE;
   PWpoint2d               loc_uvpt;
   struct PWid             edobj;
   enum  PWtopopostype     position=PWtopopos_unknown;
   struct IGRbsp_surface   *p_sfgeom=NULL;

   *p_ptloc = PWptloc_unknown;
   *p_edid = PW_K_NullObjid;
   edobj.osnum = p_lpid->osnum;
   memset (p_edpt, 0, sizeof (struct PWcvpt));

   if( !xyzpt && !uvpt )
   {
      retval = SetError( PW_K_PtLocation, PW_K_InvalidArg );
      goto wrapup;
   }
   if(xyzpt)
      memcpy( loc_xyzpt, xyzpt, 3*sizeof(double));
   if(uvpt)
      memcpy( loc_uvpt, uvpt, 2*sizeof(double));

   /* Get the surface geometry  
    */
   if( (p_sfdata->datatype == PWsfdata_null) ||
       (p_sfdata->datatype == PWsfdata_plane)  )
   {
      retval = SetError( PW_K_PtLocation, PW_K_InvalidArg );
      goto wrapup;
   }
   else if( p_sfdata->datatype == PWsfdata_bspsf )
   {
      p_sfgeom = p_sfdata->data.p_bspsf;
   }
   else if( p_sfdata->datatype == PWsfdata_gmbspsf )
   {
      p_sfgeom = p_sfdata->data.p_gmbspsf->bspsf;
   }

   if( !xyzpt )
   {
      /* Get xyz point from the input uv point and p_sfgeom 
       */
      BSsfeval( p_sfgeom, uvpt[U], uvpt[V], 0, &loc_xyzpt, &rc );
      OnErrorState( rc != BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup);
   } 
   if( !uvpt )
   {
      /* Get the uvpoint from the input xyz point and p_sfgeom
       */
      BSmdistptsf( &rc, p_sfgeom, xyzpt, &loc_uvpt[U], &loc_uvpt[V],
                   tmp_ptxyz, &tmp_dist );
      OnErrorState( rc != BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup);
      if( tmp_dist > xyztol ) /* (check) */
      {
         *p_ptloc = PWptloc_unknown;
         goto wrapup;
      }
   }/* if !uvpt */

   /*
    * Get the input loop range. This will help in classifying the point
    * trivially, if it is outside the loop range box.
    */
   pwGetLpRange( p_lpid->objid, p_lpid->osnum, lprange );

   /* Get the uvtol given the xyztol
    */
   uvtol = pwGetParTolSf( p_sfgeom, xyztol );

   /* Bump up the loop range by half the uvtol */
   PW_2dbxinc( lprange, uvtol/2 )  /* Macro call  */

   /* Check for the uv point to be in the range box */
   inside = PW_2dptinbx ( lprange, loc_uvpt );  /* Macro call */

   if( !inside )
   {
      /* Fill the return  structure : p_ptloc */

      is_ploop = pwIsLpFace( p_lpid->objid, p_lpid->osnum );
      if( is_ploop )
         *p_ptloc = PWptloc_inhole;
      else
         *p_ptloc = PWptloc_inarea;
      goto wrapup;
   }
   
   /* Processing for point location on Vertex/Edge */

   /* Get the edges of the loop 
    */
   numedges = pwNumEdsOfLp( p_lpid->objid, p_lpid->osnum );

   /* Allocate memory for the number of edges into p_lpedges 
    */
   p_lpedges = ( PWobjid *)alloca ( numedges*(sizeof(PWobjid)));
   OnErrorState( !p_lpedges, retval, SetError( 0, PW_K_DynamicMemory),
                 wrapup);

   /* Get the loop edge ids 
    */
   pwEdsOfLp( p_lpid->objid, p_lpid->osnum, p_lpedges );

   for( i=0; i<numedges; i++)
   {
      edobj.objid = p_lpedges[i];
      onedge = IsPtOnEdge( &edobj, p_sfdata, loc_xyzpt, loc_uvpt, xyztol, 
                             p_edpt );
      if( onedge )
      {
         *p_edid = p_lpedges[i];
         position = pwGetTopoposCvpt( p_edpt );
         if( position == PWtopopos_start ) 
            *p_ptloc = PWptloc_onstartvtx ;
         else if( position == PWtopopos_stop )
            *p_ptloc = PWptloc_onstopvtx ;
         else
             *p_ptloc = PWptloc_onedge;
         goto wrapup;
      }
   }

   /*
    * At this stage the input point is not on any vertex or edge of
    * the loop. So we need to determine whether the point is inside or
    * outside the loop.
    * Ray shooting is done to determine inside or outside classification.
    * Call the API which does this classification
    */

    retval = LpPtClassify (p_lpid, loc_uvpt, xyztol, p_sfdata,
                             p_ptloc, p_edid, p_edpt);
    OnErrorCode( retval, wrapup );
    
    /* The input point should not lie on an edge or vertex at this 
     * point because check for this condition is already made. So if
     * this happens then mark it as unknown.
     */
    if( *p_ptloc == PWptloc_onedge || *p_ptloc == PWptloc_onstartvtx ||
        *p_ptloc == PWptloc_onstopvtx )
    {
       *p_ptloc = PWptloc_unknown;
       *p_edid = PW_K_NullObjid;
    }

    wrapup:

    p_edpt->cvid = *p_edid;
    PW_Wrapup( retval, "Function: pwLpPointLocate ");
    return (retval);
}/* end of function pwLpPtLocate */



/*
 *   Application Function: IsPtOnEdge().
 *   -------------------------------------
 *   Description
 *   -----------
 *
 *   Input
 *   -----
 *   Output
 *   ------
 */

static PWboolean   IsPtOnEdge
( 
   struct PWid             *p_edid,
   struct PWsfdata         *p_sfdata,
   PWpoint                 xyzpt,
   PWpoint2d               uvpt,
   double                  xyztol,
   struct PWcvpt           *p_onvertex
)
{
   unsigned long           retval;
   long                    rc;
   PWpoint2d               startpt, stoppt;
   PWpoint                 startptxyz , stopptxyz;
   struct PWcvparam        startpar, stoppar;
   PWpoint                 bx[2], intpt;
   struct IGRbsp_curve     *p_bspcv=NULL;
   struct IGRbsp_surface   *p_sfgeom=NULL;
   double                  edpar, dist, uvtol;
   PWboolean               on_edge=FALSE, intersection;
   struct PWcvpt           cvpt;
   struct PWcvdata         cvdata;
   struct PWcvparam        minpar;
   PWpoint                 minpt;
   double                  sqdist =0.0;

   
   /*
    * Initialize
    */
   cvpt.p_attrib = NULL;
   cvdata.datatype = PWcvdata_bspcv;
   memset (p_onvertex, 0, sizeof (struct PWcvpt));

   if( p_sfdata->datatype == PWsfdata_plane )
      OnErrorState( TRUE, retval, SetError(PW_K_Pathway, PW_K_InvalidArg),
                    wrapup);

   p_sfgeom = p_sfdata->datatype == PWsfdata_bspsf ? p_sfdata->data.p_bspsf :
                                            p_sfdata->data.p_gmbspsf->bspsf;
   /*
    * Get the uvtol for this surface
    */
   uvtol = pwGetParTolSf (p_sfgeom, xyztol);
   /*
    *  Get the end points of the edge
    */
   pwGetEdEndPts( p_edid->objid, p_edid->osnum, startpt, stoppt );

   /*
    *  Get the xyz endpoints
    */
   BSsfeval( p_sfgeom, startpt[U], startpt[V], 0, &startptxyz, &rc);
   OnErrorState( rc != BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup);

   BSsfeval( p_sfgeom, stoppt[U], stoppt[V], 0, &stopptxyz, &rc);
   OnErrorState( rc != BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup);
   /*
    *  Get the distance between the input xyzpt and the start, stop points.
    *  If either of the distance is within xyz tolerance, return ptloc as
    *  'PWptloc_onstartvtx / PWptloc_onstopvtx'.
    */
   dist = pwDistPtPt( xyzpt, startptxyz );
   if( fabs(dist) < xyztol )
   {
       pwGetEdEndPars( p_edid->objid, p_edid->osnum, &startpar, &stoppar );
       p_onvertex->cvparam = startpar;
       memcpy( p_onvertex->pt, startpt, 2*sizeof(double));
       pwSetTopoposCvpt( p_onvertex, PWtopopos_start );
       on_edge = TRUE;
   }
   else if( (dist = pwDistPtPt( xyzpt, stopptxyz ) ) < xyztol )
   {
      pwGetEdEndPars( p_edid->objid, p_edid->osnum, &startpar, &stoppar );
      p_onvertex->cvparam = stoppar;
      memcpy( p_onvertex->pt, stoppt, 2*sizeof(double));
      pwSetTopoposCvpt( p_onvertex, PWtopopos_stop );
      on_edge = TRUE;
   }
   else
   {
      /*
       *  Construct a boreline arround the xyz point with the xyz tol
       */
      bx[0][0] = xyzpt[0];
      bx[0][1] = xyzpt[1];
      bx[0][2] = xyzpt[2] -xyztol;

      bx[1][0] = xyzpt[0];
      bx[1][1] = xyzpt[1];
      bx[1][2] = xyzpt[2] +xyztol;
     
      /*
       *  Get the xyz geometry of the input edge
       */
      retval = pwGetEdbcXyzGeom( p_edid->objid, p_edid->osnum, p_sfdata, &p_bspcv );
      OnErrorCode( retval, wrapup);
     
      cvdata.data.p_bspcv = p_bspcv;
      /*
       *  Check if this edge intersects the bounding box of the boreline.
       */
      BSmdptcvbx( p_bspcv, bx[0], bx[1], xyztol, &edpar, intpt, &intersection,
                  &rc );
      OnErrorState( rc !=BSSUCC, retval,
                    SetError( PW_K_BspMath, PW_K_Internal), wrapup );
      if (intersection)
      {
        sqdist = pwMinDistSqPtCvdata (xyzpt, &cvdata, minpt, &minpar);
        if (fabs (sqrt(sqdist))> xyztol)
           intersection =0;
      }
      if( intersection )
      {
         retval =pwEdPtProject (p_edid, 1, (PWpoint2d *)&uvpt[0], uvtol, &cvpt);

         OnErrorCode (retval, wrapup);
         if (cvpt.p_attrib)
         {
           pwFreeAttribList (cvpt.p_attrib);
           cvpt.p_attrib = NULL;
         }
         p_onvertex->cvparam.spaninx = cvpt.cvparam.spaninx;
         p_onvertex->cvparam.spanpar = cvpt.cvparam.spanpar;
         memcpy( p_onvertex->pt, cvpt.pt, 2*sizeof(double));
         pwSetTopoposCvpt( p_onvertex, PWtopopos_middle );
         on_edge = TRUE; 
      }
   }

   if( on_edge )
     p_onvertex->cvid = p_edid->objid;

   wrapup:
   if( p_bspcv ) free( p_bspcv );
   return( on_edge );
}/* end of function IsPtOnEdge */
