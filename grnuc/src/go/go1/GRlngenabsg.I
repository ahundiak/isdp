/*
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRlinear	
     METHOD NAME:   GRgenabsg

     Abstract: 
		This method generates the abstract data representation 
		for a linear object and places the data in the standard 
		buffer (abstract data cache).  

-----
%SC%    

     GRgenabsg(msg,matrix_type,matrix,absgptr)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type IGRshort	 type of the transformation matrix
     matrix	  IGRmatrix	 local-to-world transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
				      due to allocation problems
     **absgptr    IGRchar	 pointer to abstract geometry 

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:


     Methods:			None.

-----
%RL%

     RELATIONS REFERENCED:	None.
-----
%NB%

     NOTES:			None.
-----
%CH%

     CHANGE HISTORY:
	
	REJ	01/28/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method converts the linear object into a B-spline 
	representation and places it in the cache.

*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bsparameters.h"       /* Included by Mohan TR:90N1545 */
#include "bserr.h"              /*   ---   do    ---            */
 
extern    char    *GRabsg_alloc();
extern    IGRboolean    MApytobc();
extern    IGRboolean  MA2ptdis();

method GRgenabsg ( long *msg; short *matrix_type; IGRmatrix matrix; char **absgptr)
{
  long       OMmsg, msg1, msg2, ret_code;
  int        action, i;
  double     tol, dist;
  IGRboolean status;

  struct IGRpolyline  polyline;
  struct GRabsg_hdr   absg_hdr;
  struct IGRbsp_curve *curve;

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  action = 2;
  polyline.num_points = 101;

  GRbc_size ( 2, polyline.num_points, 0, 0, absg_hdr.geometry_size );
  absg_hdr.id.objid = my_id;
  absg_hdr.id.osnum = OM_Gw_current_OS;
  absg_hdr.matrix_type = *matrix_type;

  for (i = 0; i < 16; i++)
    absg_hdr.matrix [i] = matrix [i];

  curve = (struct IGRbsp_curve *) GRabsg_alloc ( &msg1, &absg_hdr );

  GRbc_partition ( curve, 2, polyline.num_points, 0, 0 );
  polyline.points = curve->poles;

  OMmsg = om$send ( msg = message GRlinear.GRgetpolyline (
      msg, matrix_type, matrix, &action, &polyline ),
      targetid = my_id );

  if (!(1 & OMmsg))
  {
    GRbc_size ( 2, polyline.num_points, 0, 0, absg_hdr.geometry_size );
    curve = (struct IGRbsp_curve *)GRabsg_alloc ( &msg1, &absg_hdr );
    GRbc_partition ( curve, 2, polyline.num_points, 0, 0 );
    polyline.points = curve->poles;
    if (1 & msg1)
      OMmsg = om$send ( msg = message GRlinear.GRgetpolyline (
          msg, matrix_type, matrix, &action, &polyline ),
          targetid = my_id);
    else
      OMmsg = OM_E_ABORT;
  }

  if (1 & OMmsg)
  {
    if (!MApytobc ( msg, &polyline, curve ))
      OMmsg = OM_E_ABORT;
    else
    {
      if (curve->phy_closed != TRUE)
      {
        status = BSEXTRACTPAR ( &ret_code, BSTOLCLOSETOZERO, tol );
        MA2ptdis ( &msg2, curve->poles,curve->poles + (curve->num_poles - 1) * 3, &dist );
        if (dist <= tol)
          curve->phy_closed = TRUE;
      }

      *absgptr = (char *) curve;
    }
  }


  if (!(1 & OMmsg & *msg))
  {
    GRabsg_del_all ();

    OMmsg = OM_E_ABORT;
    *msg = MSFAIL;
  }

  return OMmsg;
}

end implementation GRlinear;
