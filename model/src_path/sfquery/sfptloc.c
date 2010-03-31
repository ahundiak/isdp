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

#include "PWapi/lpptloc.h"
#include "PWapi/ptlocmac.h"

#include "PWapi/sflp.h"
#include "PWapi/lpprops.h"
#include "PWapi/sfgeom.h"




extern PWresult pwPtNesting( struct PWid *, PWpoint2d, double, int *,
                             PWobjid * );

/*
 *
 *   Application function :  pwSfPtLocate().
 *
 *  Description
 *  -----------
 *  This API for point locate works at the Surface Level, and classifies
 *  a point as one of the following Possible enumerated types are
 *  ONEDGE, ONVERTEX, INHOLE, INAREA, and OUTSIDE.
 *
 *  Input
 *  -----
 *  Struct Pgeomid   *p_sfgeomid;
 *
 *  Ppoint       xyzpt;       * XYZ point if available *
 *
 *  Ppoint2d     uvpt;        * UV point if XYZ point not available *
 *
 *  double       xyztol;      * XYZ tolerance with which ptloc is to be
 *                                tested *
 *
 *  Output
 *  ------
 *  struct PWid            *p_bdryid;     *  Bdry id if on egde/vertex 
 *                                         *  else PW_NULL_OBJID 
 *
 *   enum  PWptloctype       *p_ptloc;
 */
 
PWresult   pwSfPtLocate
(
           struct PWgeomid   *p_sfgeomid,
           PWpoint           xyzpt,
           PWpoint2d         uvpt,
           double            xyztol,
           enum PWptloctype  *p_ptloc,
           PWobjid           *p_bdryid,
           struct PWcvpt     *p_edpt
)
{
   PWresult                 retval=PW_K_Success;
   long                     rc=BSSUCC;
   int                      i=0, lpcount=0,  numoutfcs=0, numloops=0;
   double                   tmp_dist=0;
   struct PWsfdata          loc_sfdata;
   PWobjid                  *p_outfcs=NULL, *p_lpids=NULL;
   PWboolean                is_ploop;
   PWpoint                  loc_xyzpt, tmp_xyzpt;
   PWpoint2d                loc_uvpt;
   struct IGRbsp_surface    *p_sfgeom=NULL;
   struct PWid              lpobj;


   /*
    * Initialize the output
    */

   *p_bdryid = PW_K_NullObjid;
   lpobj.osnum = p_sfgeomid->id.osnum;
   *p_ptloc = PWptloc_unknown;
   memset (p_edpt, 0, sizeof (struct PWcvpt));

   if( !xyzpt && !uvpt )
   {
      retval = SetError( PW_K_PtLocation, PW_K_InvalidArg );
      goto wrapup;
   }

   if( xyzpt )
      memcpy( loc_xyzpt, xyzpt, 3*sizeof(double));
   if( uvpt )
      memcpy( loc_uvpt, uvpt, 2*sizeof(double));

   /* Get the surface geometry from the surface id. 
    */
   retval = PW_GetSfBspsfStack(p_sfgeomid->id.objid, p_sfgeomid->id.osnum, 
                       p_sfgeomid->mattyp, p_sfgeomid->mat, p_sfgeom );
   OnErrorCode( retval, wrapup );

   loc_sfdata.datatype = PWsfdata_bspsf;
   loc_sfdata.data.p_bspsf = p_sfgeom;

   if( !xyzpt )
   {
      /* Get the xyz point from the input uvpoint and p_sfgeom
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
                   tmp_xyzpt, &tmp_dist );
      OnErrorState( rc != BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup);
      if( tmp_dist > xyztol ) /* (check) */
      {
         *p_ptloc = PWptloc_unknown;
         goto wrapup;
      }
   }/* if !uvpt */

   /* Get only the first level P-loops 
    */
   numoutfcs = pwNumOuterFacesOfSf( p_sfgeomid->id.objid, 
                                    p_sfgeomid->id.osnum );

   /* Allocate space for outermost faces "p_outfcs"
    */
   p_outfcs = ( PWobjid *)alloca( numoutfcs*sizeof(PWobjid));
   OnErrorState( !p_outfcs, retval, SetError( 0, PW_K_DynamicMemory),
                 wrapup);

   pwOuterFacesOfSf( p_sfgeomid->id.objid, p_sfgeomid->id.osnum, p_outfcs );

   /* Get the total number of loops on the surface. This includes all P and
    * C loops.
    */
   numloops = pwNumLpsOfSf( p_sfgeomid->id.objid, p_sfgeomid->id.osnum );

   /* Allocate space for numloops number of p_lpids
    */
   p_lpids = (PWobjid *)alloca( numloops*sizeof(PWobjid));
   OnErrorState( !p_lpids, retval, SetError( 0, PW_K_DynamicMemory),
                 wrapup);

   /* Loop over numoutfcs of surface
    */
   lpcount = 0;
   for( i=0; i<numoutfcs; i++ )
   {
      lpobj.objid = p_outfcs[i];

      /* Collect all the loops under which the input point falls.
       * This is done by range check.
       */
      retval = pwPtNesting( &lpobj, loc_uvpt, xyztol, &lpcount, p_lpids );
      OnErrorCode( retval, wrapup );
    }
    if( !lpcount )
       *p_ptloc = PWptloc_outside;

    /* After collecting all the loops which are likely candidates. We do a
     * point locate in a LIFO manner
     */
    for( i= lpcount; i>0; i-- )
    {
       lpobj.objid = p_lpids[i-1];
       retval = pwLpPtLocate( &lpobj, loc_xyzpt, NULL, &loc_sfdata,
                              xyztol, p_ptloc, p_bdryid, p_edpt );
       OnErrorCode( retval, wrapup );

       /* Get loop type of this loop
        */
       is_ploop = pwIsLpFace ( lpobj.objid, lpobj.osnum );
       if( (*p_ptloc == PWptloc_inhole && !is_ploop ) ||
           (*p_ptloc == PWptloc_inarea && is_ploop ) )
       {
          *p_bdryid = lpobj.objid;
          break;
       }
       else if( *p_ptloc == PWptloc_onedge || *p_ptloc == PWptloc_onstartvtx ||
                *p_ptloc == PWptloc_onstopvtx )
          break;
    }
    if( !i )
       if( *p_ptloc == PWptloc_inhole )
       {
          *p_ptloc = PWptloc_outside;
          *p_bdryid = PW_K_NullObjid;
       }
 
    wrapup:

    p_edpt->cvid = *p_bdryid;
    PW_Wrapup( retval, "Function: pwSfPtLocate(). ");
    return retval;

}/* end of function pwSfPtLocate() */


/*-------------------------- STATIC FUNCTIONS ------------------------------*/

/*
  DESCRIPTION

  The following is an internal function only. It is not made static as it 
  can be called internally from other files.
*/

PWresult SfGeomPtLocate
(
  struct IGRbsp_surface *sf,
  PWosnum os,
  PWpoint xyzpt,
  PWpoint2d uvpt,
  double xyztol,
  int numoutfcs,
  PWobjid *p_outfcs,
  int numloops,
  enum PWptloctype *p_ptloc,
  PWobjid *p_bdryid,
  struct PWcvpt *p_edpt
)
{
  PWresult retval=PW_K_Success;
  PWboolean is_ploop;
  PWobjid *p_lpids;
  int i, lpcount=0;
  struct PWid lpobj;
  struct PWsfdata loc_sfdata;

  lpobj.osnum = os;

  /* 
   * Allocate space for total number of loops on this surface
   */

  p_lpids = (PWobjid *) alloca (numloops * sizeof(PWobjid));

  /* 
   * Loop over numoutfcs of surface
   */

  for (i=0; i<numoutfcs; i++)
  {
    lpobj.objid = p_outfcs[i];

    /*
     * Collect all the loops under which the input point falls.
     * This is done by range check.
     */

    retval = pwPtNesting (&lpobj, uvpt, xyztol, &lpcount, p_lpids);
    OnErrorCode( retval, wrapup );
  }
  if (!lpcount)
    *p_ptloc = PWptloc_outside;

  /*
   * After collecting all the loops which are likely candidates. We do a
   * point locate in a LIFO manner
   */

  loc_sfdata.datatype = PWsfdata_bspsf;
  loc_sfdata.data.p_bspsf = sf;
  for (i= lpcount; i>0; i--)
  {
    lpobj.objid = p_lpids[i-1];
    retval = pwLpPtLocate (&lpobj, xyzpt, uvpt, &loc_sfdata,
              xyztol, p_ptloc, p_bdryid, p_edpt);
    OnErrorCode( retval, wrapup );

    /* 
     * Get loop type of this loop
     */

    is_ploop = pwIsLpFace (lpobj.objid, lpobj.osnum);
    if ( (*p_ptloc == PWptloc_inhole && !is_ploop ) ||
         (*p_ptloc == PWptloc_inarea && is_ploop ) )
    {
      *p_bdryid = lpobj.objid;
      break;
    }
    else if ( *p_ptloc == PWptloc_onedge || *p_ptloc == PWptloc_onstartvtx ||
              *p_ptloc == PWptloc_onstopvtx )
      break;
  }

  if ( !i )
    if (*p_ptloc == PWptloc_inhole)
    {
      *p_ptloc = PWptloc_outside;
      *p_bdryid = PW_K_NullObjid;
    }
 
wrapup:
  p_edpt->cvid = *p_bdryid;
  PW_Wrapup (retval, "SfGeomPtLocate");
  return retval;
}
