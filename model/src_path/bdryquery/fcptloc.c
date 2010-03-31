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

#include "PWapi/lpprops.h"
#include "PWapi/sflp.h"

#include "PWapi/partol.h"
#include "PWapi/lpptloc.h"
#include "PWapi/ptlocmac.h"




/*
 *   Application function: pwFcPtLocate().
 *   --------------------------------------
 *
 *   Description
 *   -----------
 *   This funtion operates at a face level, and classifies an input point
 *   as ONVERTEX, ONEDGE, INAREA, INHOLE, or OUTSIDE.
 *
 *   Input
 *   -----
 *   PWobjid            fcobjid;       * Face loop objid  *
 *
 *   PWosnum            fcosnum;       * Face loop osnum  *
 *
 *   Ppoint             xyzpt;         * XYZ point if available *
 *
 *   Ppoint2d           uvpt;          * UV point if XYZ point not available *
 *
 *   struct Psfdata     *p_sfdata;     * Input surface geometry of the loop *
 *
 *   double             xyztol;        * XYZ tolerance with which ptloc is to be
 *                                       tested *
 *
 *   Output
 *   ------
 *   PWobjid           *p_bdryid;      * Boundary id if on egde/vertex else
 *                                       PW_K_NullObjid *
 *   enum PWptloctype  *p_ptloc;       * Contains the inhole, inarea, on 
 *                                       vertex etc information
 */



PWresult   pwFcPtLocate
(
           struct PWid      *p_lpid,
           PWpoint          xyzpt,
           PWpoint2d        uvpt,
           struct PWsfdata  *p_sfdata, 
           double           xyztol, 
           enum PWptloctype *p_ptloc, 
           PWobjid          *p_bdryid, 
           struct PWcvpt    *p_edpt
)
{
   PWresult                retval=PW_K_Success;
   BSrc                    rc=BSSUCC;
   PWboolean               is_ploop=FALSE, inside=FALSE;
   PWrange2d               fclprange;
   PWpoint                 loc_xyzpt, tmp_xyzpt;
   PWpoint2d               loc_uvpt;
   PWobjid                 *p_holeids=NULL, *p_rangechk=NULL, loc_edid;
   int                     i=0, count=0, numholes=0;
   double                  tmp_dist=0, uvtol=0;
   struct IGRbsp_surface   *p_sfgeom=NULL;
   struct PWid             holeobj;


   retval = PW_K_Success;
   *p_bdryid = PW_K_NullObjid;
   *p_ptloc = PWptloc_unknown;
   holeobj.osnum = p_lpid->osnum;
   memset (p_edpt, 0, sizeof (struct PWcvpt));

   /* Get the input loop type */
   is_ploop = pwIsLpFace( p_lpid->objid, p_lpid->osnum );

   if( (!xyzpt && !uvpt) || !is_ploop )
   {
      retval = SetError( PW_K_PtLocation, PW_K_InvalidArg );
      goto wrapup;
   } 
   if( xyzpt )
      memcpy( loc_xyzpt, xyzpt, 3*sizeof(double));
   if( uvpt )
      memcpy( loc_uvpt, uvpt, 2*sizeof(double));

   /* Get the surface geometry from the surface id if not input 
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
                   tmp_xyzpt, &tmp_dist );
      OnErrorState( rc != BSSUCC, retval,
                 SetError( PW_K_BspMath, PW_K_Internal), wrapup);
      if( tmp_dist > xyztol ) /* (check) */
      {
         *p_ptloc = PWptloc_unknown;
         goto wrapup;
      }
   }/* if !uvpt */

   /*
    * Get the input Face loop range. This will help in classifying the point
    * trivially, if it is outside the Face loop range box.
    */
   pwGetLpRange (p_lpid->objid, p_lpid->osnum, fclprange ); 

   /* Get the uvtol given the xyztol
    */
   uvtol = pwGetParTolSf( p_sfgeom, xyztol );

   /* Bump up the loop range by half the uvtol */
   PW_2dbxinc(fclprange, uvtol/2)  /* Macro call  */

   /* Check for the uv point to be in the range box */
   inside = PW_2dptinbx (fclprange, loc_uvpt); /* Macro call */

   if( !inside )
   {
      /* Fill the return structure : ptloc */
      *p_ptloc = PWptloc_outside; 
      goto wrapup;
   }

   /* Call a function to get the First level C-loops given a P-loop (Face),
    */
   numholes = pwNumHolesOfFace( p_lpid->objid, p_lpid->osnum );

   /* Allocate memory for the holes 'p_holeids'
    */
   p_holeids = (PWobjid *)alloca( numholes*sizeof( PWobjid ) ); 
   OnErrorState( !p_holeids, retval, SetError( 0, PW_K_DynamicMemory),
                 wrapup);

   /* Allocate space for holeids which will succeed the range check
    */
   p_rangechk = (PWobjid *)alloca( numholes*sizeof( PWobjid ) );
   OnErrorState( !p_rangechk, retval, SetError( 0, PW_K_DynamicMemory),
                 wrapup);

   /* Get the hole ids for the given P-loop id 
    */
   pwHolesOfFace( p_lpid->objid, p_lpid->osnum, p_holeids );

   for( i=0; i<numholes; i++)
   {
      /*
       * Get the input C- loop range. This will help in classifying the point
       * trivially, if it is outside the C- loop range box.
       */
      pwGetLpRange ( p_holeids[i], p_lpid->osnum, fclprange );

      /* Bump up the loop range by half the uvtol */
      PW_2dbxinc (fclprange, uvtol/2)  /* Macro call */

      /* Check for the uv point to be in the range box */
      inside = PW_2dptinbx (fclprange, loc_uvpt); /* Macro call */

      if( inside )
      {
         p_rangechk[count] = p_holeids[i];
         count++;
      }
   }
  
   for( i=count; i>0; i-- )
   {
      holeobj.objid = p_rangechk[i-1];
      retval = pwLpPtLocate( &holeobj, loc_xyzpt, NULL,
                             p_sfdata, xyztol, p_ptloc, &loc_edid, p_edpt);
      OnErrorCode( retval, wrapup );

      if( *p_ptloc == PWptloc_inhole )
      {
         *p_bdryid = p_rangechk[i];
         break;
      }
      else if( *p_ptloc == PWptloc_onstartvtx || *p_ptloc == PWptloc_onstopvtx 
               || *p_ptloc == PWptloc_onedge )
      {
         *p_bdryid = loc_edid;
         break;
      }
   }  

   if( !count || *p_ptloc == PWptloc_inarea )
   {
      /* Indicates either there is no hole inside the face or the input
       * point is ouside all the holes collected in the previous step.
       * At this stage we are not certain whether the input point is actually
       * inside the outside P-Loop or not. This is because we did'nt do a
       * point locate on the outside loop. We only did a range check. 
       */
       
      retval = pwLpPtLocate( p_lpid, loc_xyzpt, NULL,
                             p_sfdata, xyztol, p_ptloc, &loc_edid, p_edpt);
      OnErrorCode( retval, wrapup );

      if( *p_ptloc == PWptloc_onstartvtx || *p_ptloc == PWptloc_onstopvtx  || 
          *p_ptloc == PWptloc_onedge )
         *p_bdryid = loc_edid;
      else if( *p_ptloc == PWptloc_inarea )
         *p_bdryid = p_lpid->objid;
      else if( *p_ptloc == PWptloc_inhole )
      {
         *p_ptloc = PWptloc_outside;
      }
         
   }

   wrapup:

   p_edpt->cvid = *p_bdryid;
   PW_Wrapup( retval, "Function: pwFcPtLocate(). ");
   return retval;
}/* end of function pwFcPtLocate() */
   
   
    

