/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlbsys
     METHOD NAME: GRkeypoint

     Abstract:	This method returns as the keypoint the origin
		of the local bounded system.
-----
%SC%    

     GRkeypoint(msg,mat_type,matrix,line,keypoint,key_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix
     *line	  IGRline	 boreline
     
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred

     keypoint	  IGRpoint	 nearest keypoint to input line
     *key_parms   struct GRparms parameter information cooresponding
				    to the keypoint
     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	none.

     Methods: 	none.
-----
%RL%

     RELATIONS REFERENCED:  none.
			  
-----
%NB%

     NOTES:  none.
	   
-----
%CH%

     CHANGE HISTORY:
	
	KMO     05/01/86 : Design date.
	KMO	05/01/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This routine retrieves the origin of the local bounded
	system from the transformation matrix in the instance
	data and returns it as the nearest keypoint to the input
	boreline.
----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "grerr.h"
#include "godef.h"

method GRkeypoint(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		  struct IGRline *line; IGRpoint keypoint;
		  struct GRparms *key_parms)
{
  IGRlong 		OMmsg;		    /* OM return code	      */
  IGRchar		*buffer;
  struct IGRlbsys	*lbsys;
  IGRlong		internal_msg;
  
  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  /*
   *  get the geometry
   */

  GRgetabsg(&internal_msg,mat_type,matrix,&buffer,i);

  if (! (1 & internal_msg))
  {
      *msg = MSFAIL;
      OMmsg = OM_E_ABORT;
      goto wrapup;
  }
      
  lbsys = (struct IGRlbsys *)buffer;

  /*
   *  store the origin of the lbsys as the keypoint of the lbsys
   */

  keypoint[0] = lbsys->matrix[3];
  keypoint[1] = lbsys->matrix[7];
  keypoint[2] = lbsys->matrix[11];

  *msg = GR_PARM_NOT_VALID;

  /* set up parameter information. the parms are not valid for a local
   * bounded system
   */

  key_parms->u = 0;
  key_parms->v = 0;
  key_parms->leaf_id.objid = my_id;
  key_parms->leaf_id.osnum = OM_Gw_current_OS;
  key_parms->polygon_inx = 2;

	

wrapup:
  return( OMmsg );

}
end implementation GRlbsys;
