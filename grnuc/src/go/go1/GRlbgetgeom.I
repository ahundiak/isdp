/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlbsys
     METHOD NAME: GRgetgeom

     Abstract: This routine gets the internal geometry of
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

     *geometry     IGRchar	 geometry pointer (preallocated space
				 for an IGRlbsys.
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
geometry and then copies it into the provided storage.

----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetgeom(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRchar *geometry)
{
  IGRchar *ptr;				/* pointer for cache address  */

  struct IGRlbsys *lb;			/* pointer for cache lbsys    */
  struct IGRlbsys *sys;			/* temporary geometry pointer */


  IGRlong OMmsg;			/* OM return code	      */


  *msg = MSSUCC;			/* get the abstract geometry  */
  OMmsg = OM_S_SUCCESS;
  
  GRgetabsg(msg,mat_type,matrix,&ptr,i);

  if( *msg & 1 )			/* copy into given storage    */
    {
      lb   = (struct IGRlbsys *) ptr;
      sys = (struct IGRlbsys *) geometry;

      *sys = *lb;
    }
  else
    {
      OMmsg = OM_E_ABORT;
    }

	

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRlbsys;
