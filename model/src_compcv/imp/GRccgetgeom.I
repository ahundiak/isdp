/*
 DESCRIPTION

   This method returns the geometry of a composite curve.
  
   RETURN VALUES
   
   geometry		The resulting merged bspline curve
   msg		 	completion code
  			- MSSUCC if successful
			- MANOMEMORY no dynamic memory available
  			- MSFAIL (severe) if failure
  
 NOTES
  
   This method should not be present.
   
 HISTORY
  
   05/08/87 : rlw : Copied curve method by rdh and changed class name
   Sudha   06/21/93        modified for BSprototype ansification
 */

class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "gocmacros.h"
#include "mabccopy.h"

method GRgetgeom(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRchar *geometry)
{
  IGRchar *ptr;				/* pointer for cache address  */

  struct IGRbsp_curve *bc;		/* pointer for cache bc       */
  struct IGRbsp_curve *curve;		/* temporary geometry pointer */

  IGRlong OMmsg;			/* OM return code	      */


  *msg = MSSUCC;			/* get the abstract geometry  */
  OMmsg = OM_S_SUCCESS;
  
  GRgetabsg(msg,mat_type,matrix,&ptr,i);

  if( *msg & 1 )			/* copy into given storage    */
    {
      bc = (struct IGRbsp_curve *) ptr;
      curve = (struct IGRbsp_curve *)geometry;

      GRbc_partition(curve,bc->order,bc->num_poles,bc->rational,
		     bc->num_boundaries);
	      
      MAbccopy(msg,bc,(struct IGRbsp_curve *)geometry);
    }
  else
    {
      OMmsg = OM_E_ABORT;
    }

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRcompcurve;
