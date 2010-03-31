/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

   This method returns the size of the buffer, in bytes, required to
   store a composite curves.
  
   RETURN VALUES
   
   size			The size of the buffer, in bytes, required to
			store the composite curve
   msg		 	completion code
  			- MSSUCC if successful
			- MANOMEMORY no dynamic memory available
  			- MSFAIL (severe) if failure
  
 NOTES
  
   This method should not be present.
   
 HISTORY
  
   05/08/87 : rlw : Copied curve method by rdh and changed class name
 */

class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "gocmacros.h"

method GRgetsize(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRlong *size)

{
  struct IGRbsp_curve *bc;		/* pointer for geometry	      */

  IGRchar *ptr;
  IGRlong OMmsg;			/* OM return code	      */

  IGRint i;				/* index		      */


  *msg = MSSUCC;

  OMmsg = OM_S_SUCCESS;

  GRgetabsg(msg,mat_type,matrix,&ptr,i);
 
  if( *msg & 1 )
    {
      bc = (struct IGRbsp_curve *) ptr;

      GRbc_size(bc->order,bc->num_poles,bc->rational,bc->num_boundaries,
            *size);
    }
  else
    {
      OMmsg = OM_E_ABORT;
    }

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRcompcurve;
