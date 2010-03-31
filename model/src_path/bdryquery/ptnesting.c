#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "OMminimum.h"

#include "PWapi/lpprops.h"
#include "PWapi/ptlocmac.h"

#include "PWapi/sflp.h"

/*
 *   Application function : pwPtNesting
 *   ----------------------------------
 *   Description
 *   -----------
 *   Given a loopid and an uv-point this function gives all the loop ids
 *   inside the input loop, which passes the range box test. ie the uv-point
 *   lies inside the range box of the output loops.
 *
 *   Input
 *   ------
 *   struct  PWid        *p_lpid                 *   Input loop objid and 
 *                                               *   osnum which is to be 
 *                                               *   tested for point nesting
 *
 *   PWpoint2d           uvpt                    *   Input uv-point
 *
 *   double              xyztol                  *   Xyz tolerance for rangebox
 *                                               *   test.      
 *   Output
 *   ------
 *
 *   int                 *p_lpcount              *   total number of output
 *                                               *   loops passing the test. 
 *
 *   PWobjid             *p_outlpids             *   Objids of output loops
 *                                               *   which passes the range
 *                                               *   box test.
 */


PWresult   pwPtNesting
(
   struct PWid  *p_lpid,
   PWpoint2d    uvpt,
   double       xyztol,
   int          *p_lpcount,
   PWobjid      *p_outlpids
)
{
   unsigned long     retval;
   int               i, numinners;
   PWobjid           *p_inners;
   PWboolean         inside, is_ploop;
   PWrange2d         lprange;
   struct PWid       innerlpobj;
   
   retval = PW_K_Success;
   innerlpobj.osnum = p_lpid->osnum;
  
   /* Get the input loop range 
    */
   pwGetLpRange( p_lpid->objid, p_lpid->osnum, lprange );

   /* Bump up the loop range  by half xyztol
    * (check) xyz or uv
    */
   PW_2dbxinc( lprange, xyztol/2 )

   /* Check for the uvpoint to be in the range box
    */
   inside = PW_2dptinbx( lprange, uvpt );

   if( inside )
   {
      p_outlpids[*p_lpcount] = p_lpid->objid;
      *p_lpcount += 1;
      
      /* Get the loop type of this loop
       */
      is_ploop = pwIsLpFace( p_lpid->objid, p_lpid->osnum );

      if( is_ploop)
      {
         /* Get all the outermost loops (Holes)
          */
         numinners = pwNumHolesOfFace( p_lpid->objid, p_lpid->osnum );

         /* Allocate memory for holes 'p_inners'
          */
         p_inners = (PWobjid *)alloca( numinners*sizeof(PWobjid));
         OnErrorState( !p_inners, retval, SetError( 0, PW_K_DynamicMemory),
                       wrapup);
      
         pwHolesOfFace( p_lpid->objid, p_lpid->osnum, p_inners );
      }
      else
      {
         /* Get all the outermost loops (Faces).
          */
         numinners = pwNumInnerFacesOfHole( p_lpid->objid, p_lpid->osnum );

         /* Allocate static space for faecs. 'p_inners'
          */
         p_inners = (PWobjid *)alloca( numinners*sizeof(PWobjid));
         OnErrorState( !p_inners, retval, SetError( 0, PW_K_DynamicMemory),
                       wrapup);

         pwInnerFacesOfHole( p_lpid->objid, p_lpid->osnum, p_inners );
      }
      for( i=0; i<numinners; i++)
      {
         innerlpobj.objid = p_inners[i];
         retval = pwPtNesting( &innerlpobj, uvpt, xyztol, p_lpcount,
                               p_outlpids );
         OnErrorCode( retval, wrapup );
      }
   }/* if inside */
   wrapup:
   PW_Wrapup( retval, "Function: pwPtNesting() ");
   return retval;
}/* end of function pwPtNesting */


