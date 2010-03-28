/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRgetgeom

     Abstract: This routine gets the internal B-spline geometry of
	       an object and places it into the provided storage.

-----
%SC%    
 
     GRgetgeom(msg,mat_type,matrix,geometry)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type     IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failed due to 
				 storage allocation problems.

     *geometry     IGRchar	 geometry pointer (preallocated space)

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:
	      GRgenabsg

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
	    The input geometry pointer must point to memory which
	   has already been allocated.

	    The pointer for the poles, weights, etc. will be assigned
	   by this routine. Hence, the size of the memory allocated
	   to hold the geometry should be the size of an IGRbsp_curve
	   structure  plus  the size of the poles, weights, etc. in bytes.

-----
%CH%

     CHANGE HISTORY:
	
	RDH     03/26/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine sends a message to GRgenabsg to get the abstract 
geometry and then assigns the pointers to the poles, weights, etc.
in the structure. Finally, it copies the geometry into the storage 
indicated by the input pointer.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

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
	      
      MAbccopy(msg,bc,geometry);
    }
  else
    {
      OMmsg = OM_E_ABORT;
    }

	

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRbspline;
