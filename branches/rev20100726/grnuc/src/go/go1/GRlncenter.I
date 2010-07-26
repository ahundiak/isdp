/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlinear
     METHOD NAME: GRcenter

     Abstract: This routine calculates the centroid of a linear 
	      element.

-----
%SC%    

     GRcenter(msg,mat_type,matrix,center)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     center	  IGRpoint	 centroid of linear element
     
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	     GRgenabsg

     Methods:
	     MAptscentroid

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	RDH     04/08/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the abstract geometry and the geometric properties
of the element and sends the poles and number of poles or the number
of poles - 1 to MAptscentroid which calculates the centroid as the 
mean value of the poles. The physically closed flag of the properties
is used to decide the number of points to use in the centroid calcu-
lation (For more information see MAptscentroid.)

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRcenter(IGRlong *msg; IGRshort *mat_type; 
	 	IGRmatrix matrix; IGRpoint center)

{
  struct IGRbsp_curve *bc;		/* pointer to abstract geom   */
  struct GRprops props;			/* geometric properties	      */

  IGRchar *ptr;				/* pointer to abstract geom   */

  IGRlong numpts;			/* number of points	      */
  IGRlong OMmsg;			/* OM return code	      */

  extern IGRboolean MAptscentroid();	/* function declarations      */


  *msg = MSSUCC;

  OMmsg = OM_S_SUCCESS;


  GRgetabsg(msg,mat_type,matrix,&ptr,i); /* get abstract geometry      */

  if( *msg & 1 )
  {
    OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRgeomprops(msg,mat_type,matrix,&props),
                    senderid = my_id,
                    targetid = my_id);

    if( 1 & OMmsg & *msg )
    {
      bc = (struct IGRbsp_curve *)ptr;

      if( props.closed  ||  bc->phy_closed )
      {
	numpts = bc->num_poles - 1;
      }
      else
      {
	numpts = bc->num_poles;
      }

      MAptscentroid(msg,bc->poles,&numpts,center);
    }
  }
  else
  {
    OMmsg = OM_E_ABORT;
  }

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRlinear;
