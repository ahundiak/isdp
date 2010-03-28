/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRconic
     METHOD NAME:  GRptproject

     Abstract: 
		This method projects the input point
		onto the given object.
-----
%SC%    

    GRptproject(msg,mat_type,matrix,pt,prjpt,curve_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type    IGRshort	  type of input transformation matrix
     matrix	  IGRmatrix	  transformation matrix
     pt		  IGRpoint	  point to project

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     prjpt	  IGRpoint	 point on element where projection
				 occurred
     *curve_parms GRparms 	 parameters describing projected
				 point on the curve
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAptarproj
	MAartobc
     Methods:
	GRgetarc
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	RDH     09/03/86 : Design date.
	MEF	11/06/89 : Altered to call BSangarctou instead of MAangtou.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

 This routine projects the point onto the IGR geometry of the conic
object and then extracts the u parameter of the projected point from
the B-spline geometry.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bserr.h"

extern    IGRboolean    MAptarproj();
extern    IGRboolean    MAartobc();
extern    void		BSangarctou();

method GRptproject(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		   IGRpoint pt,prjpt; struct GRparms *curve_parms)

{
    struct IGRarc      arc;		/* IGR geometry			*/
    IGRdouble curve_pts[6];		/* conic project points		*/

    IGRshort num_points;


    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/

    IGRdouble theta;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
					/* get IGR geometry		*/
    OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRconic.GRgetarc(msg,mat_type,matrix,&arc),
                    senderid = my_id,
                    targetid = my_id);

    if( 1 & OMmsg & *msg)
      {					/* project point onto curve	*/
        MAptarproj(&msg2,pt,&arc,&num_points,curve_pts);

	if( num_points == 1 || num_points == 2 || num_points == -1 )
	  {
	    prjpt[0] = curve_pts[0];
	    prjpt[1] = curve_pts[1];
	    prjpt[2] = curve_pts[2];

	    curve_parms->u = 0.0;
	    MAptwcangel(msg,prjpt,&arc,&theta);
 	    theta -= arc.start_angle;

   	    BSangarctou(arc.sweep_angle,theta,&curve_parms->u,&msg2);
            if ( msg2 != BSSUCC)
              {
		OMmsg = OM_E_ABORT;
		*msg = MSSUCC;
		goto wrapup;
	      }

	    curve_parms->v = 0;
	    curve_parms->polygon_inx = 0;
	    curve_parms->leaf_id.objid = my_id;
	    curve_parms->leaf_id.osnum = OM_Gw_current_OS;

	  }
	else
	  {
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	  }
     }

wrapup:	
    
   return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRconic;

