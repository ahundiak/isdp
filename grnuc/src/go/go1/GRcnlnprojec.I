/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRconic
     METHOD NAME:  GRlnproject

     Abstract: 
		This method projects the input line
		onto the given object.
-----
%SC%    

    GRlnproject(msg,mat_type,matrix,line,line_pt,
		curve_pt,t,curve_parms)


-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *line         IGRline	  line to project onto object
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     line_pt	  IGRpoint	 projected point on the line
     curve_pt	  IGRpoint	 point on element where projection
				 occurred
     *t  	  IGRdouble	 parameter describing projected 
				 point on the line
     *curve_parms GRparms 	 parameters describing projected
				 point on the curve

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAlnarproj
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

 This routine projects the line onto the IGR geometry of the conic
object and then extracts the u parameter of the projected point from
the B-spline geometry.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"
#include "bserr.h"

extern    IGRboolean    MAlnarproj();
extern    IGRboolean    MAartobc();
extern    void		BSangarctou();

method GRlnproject(IGRlong *msg; IGRshort *mat_type; IGRmatrix 
		   matrix; struct IGRline *line; IGRpoint line_pt,
		   curve_pt; IGRdouble *t; struct GRparms *curve_parms)

{
    struct IGRarc      arc;		/* IGR geometry			*/

    IGRdouble line_pts[6];		/* line project points		*/
    IGRdouble curve_pts[6];		/* conic project points		*/
    IGRdouble ts[2];			/* line t parameters		*/
    IGRdouble theta;

    IGRshort num_points;

    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/


    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
    curve_parms->leaf_id.objid = my_id;
    curve_parms->leaf_id.osnum = OM_Gw_current_OS;
    curve_parms->v = 0.0;
    curve_parms->polygon_inx = 0;

					/* get IGR geometry		*/
    OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message
		       GRconic.GRgetarc(msg,mat_type,matrix,&arc),
                    senderid = my_id,
                    targetid = my_id);

    if( 1 & OMmsg & *msg)
    {					/* project point onto curve	*/
        if( MAlnarproj(&msg2,line,&arc,line_pts,curve_pts,ts,&num_points) )
	{
	    if( num_points >= 1 )
	    {
		line_pt[0] = line_pts[0];
		line_pt[1] = line_pts[1];
		line_pt[2] = line_pts[2];

		curve_pt[0] = curve_pts[0];
		curve_pt[1] = curve_pts[1];
		curve_pt[2] = curve_pts[2];

		*t = ts[0];

		curve_parms->u = 0.0;
		MAptwcangel(msg,curve_pt,&arc,&theta);

		theta -= arc.start_angle;

		if( MAabsolute(theta) < MAETA )
		{
		    theta = 0.0;
		}

	        BSangarctou(arc.sweep_angle,theta,&curve_parms->u,&msg2);
		if (msg2 != BSSUCC)
                {
 	            *msg = MSSUCC;
		    goto wrapup;
		}

		if (curve_parms->u > 1.0)
		{
		    curve_parms->u = 1.0;
		}
		else if (curve_parms->u < 0.0)
		{
		    curve_parms->u = 0.0;
	        }
	    }
	    else
	    {
		*msg = MSFAIL;
		OMmsg = OM_W_ABORT;
	    }
	}
	else
	{
	    *msg = MSFAIL;
	    OMmsg = OM_W_ABORT;
	}
     }

   
wrapup:
    
   return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRconic;

