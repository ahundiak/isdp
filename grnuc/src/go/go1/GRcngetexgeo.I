/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAME: GRgetexgeom

     Abstract: This routine gets the internal extended B-spline 
	      geometry of a conic object and places it into the 
	      provided storage.

-----
%SC%    

	GRgetexgeom(*msg,mat_type,matrix,*geometry)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     mat_type     IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failed due to 
				 storage allocation problems.

     geometry     IGRchar	 geometry pointer (preallocated space)

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	      MAbctoel
	      MAeltobc
	      
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
 This routine gets the abstract geometry and then converts it to an
IGRellipse. Then it assigns the pointers to the output geometry for
the poles, weights, etc. in the structure. Finally, it converts the
IGRellipse to a B-spline curve.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAeltobc();

method GRgetexgeom(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		   IGRchar *geometry)
{
  struct IGRarc ar;				/* extended non-abstract geom*/
  struct IGRbsp_curve *curve;			/* temporary geometry pointer*/

  IGRlong OMmsg;				/* OM return code	     */


  *msg = MSSUCC;

  OMmsg = OM_S_SUCCESS;
  
  OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRconic.GRgetarc(msg, mat_type,matrix,&ar),
                  senderid = my_id,
                  targetid = my_id);

  if( 1 & OMmsg & *msg )
    {
      curve = (struct IGRbsp_curve *)geometry;

      GRbc_partition(curve,3,MAELPOLE_SIZE,1,0);
	      
      MAeltobc(msg,&ar,geometry);		/* convert the ellipse to bc */
    }

  if( !( 1 & *msg ) )
    {
      OMmsg = OM_E_ABORT;
    }

	

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRconic;
