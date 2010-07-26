/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRarcnradpts
 
     Abstract: This is the routine called by command objects for
	      constructing an arc given four events which define 
	      the center, the radius, the start point, and the 
	      endpoint of the arc. The start and endpoint may be
	      start and sweep angles. No special events are
	      allowed.

-----
%SC%

     value = GRarcnradpts(msg,events,num_events,ccw,ar)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events       GRevents	 array of pointers to events
     num_events	  IGRshort	 number of events
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred
					MSINARG - invalid event type

     ccw	  IGRshort	 flag for counter-clockwise orientation
     ar		  IGRbsp_curve	 output arc
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - arc found
                        FALSE- no arc found

-----
%MD%

     MODULES INVOKED:
			GRprerout
			MAarr3ptconstr
			MAdotvc
			MAbccopy
			MAsubvc
			MAunitvc
			MAscalvc
			MAaddvc
			MAarcptangconstr
			MAtrnmx
			MAptsxform
			MAatan2
			MAartobc
-----
%NB%

     NOTES:
	    The storage for the arc must already be allocated.
	   Allow for 7 poles, 7 weights, 10 knots.

	    The order of events must be:

		1). center of the arc.
		2). radius of the arc.
		3). start point or angle of the arc.
		4). stop point or sweep angle of the arc.            

	     The flag ccw is used as follows:
		ccw == 1 => return arc counter-clockwise wrt view
		ccw == 0 => return arc clockwise wrt view

	    The view is taken as the view of the center point.

	    The radius must be greater than zero.

	    In the event that the sweep is specified by an angle,
	   the ccw flag will be ignored.
-----

%CH%
     CHANGE HISTORY:

	R.D.H.   05/04/86 : Creation date.

%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 The routine first calls GRprerout to preprocess the input. Then it
gets the view rotation matrix from the view id of the center point.
Then it processes the input as follows:

	1). The start and end is given by 2 points:
		The routine calls MAarr3ptconstr to find the two
	    arcs defined by the data. Then it returns the arc 
	    which is oriented correctly in the view as determined
	    by the ccw flag.

	2). The point on the start axis is given and the sweep angle
		The routine finds the end of the start axis by 
	    scaling the vector from the start axis point to the center
	    by the radius. It then calls MAarcptangconstr to get the
	    correct arc.

	3). The start and sweep are given as angles:
		The routine creates an IGRarc whose center and radius
	    are the input center and radius and whose rotation is the
	    transpose of the view rotation which is a world-to-view
	    transformation. Then the start angle is given as the input
	    start angle and the sweep angle is the input sweep angle if
	    ccw is 1, otherwise it is given as the negative of the
 	    input sweep angle. Finally, the IGRarc is converted to a
	    B-spline curve.

	4). The start angle is given along with a point defining the
	   sweep angle.
		The routine creates an IGRarc whose center and radius 
	   are the input center and radius and whose rotation is the
	   transpose of the view rotation. Then the point determining
	   the sweep angle is used to produce the endpoint of the arc.
	   This point is taken to the arcs coordinate system to find 
	   the angle which produced the point. This angle along with
	   the start angle and ccw flag are then used to get the
	   arcs sweep angle. Finally, the IGRarc is converterd to a
	   B-spline arc.

----*/
/*EH*/


#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "dpdef.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "msdef.h"
#include "dp.h"
#include "dpmacros.h"

#include "grrouterpriv.h"

extern    IGRdouble    MAatan2();

extern    IGRboolean    GRprerout();
extern    IGRboolean    MAarr3ptconstr();
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MAbccopy();
extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAunitvc();
extern    IGRboolean    MAscalvc();
extern    IGRboolean    MAaddvc();
extern    IGRboolean    MAarcptangconstr();
extern    IGRboolean    MAtrnmx();
extern    IGRboolean    MAptsxform();
extern    IGRboolean    MAartobc();

IGRboolean GRarcnradpts(msg,events,num_events,ccw,ar)

	   IGRlong             *msg;		/* return code		     */
	   struct GRevent      *events[];	/* events		     */
	   IGRshort            *num_events;	/* number of events	     */
	   IGRshort	       *ccw;		/* flag for orientation of ar*/
	   struct IGRbsp_curve *ar;		/* arc			     */

{
  struct GRrtevent rtevents[GRMAX_AR_EVENTS+1];	/* router data structure     */
  struct IGRbsp_curve arcs[2];			/* array of two arcs	     */
  struct IGRarc arc;				/* temporary arc	     */
  IGRmatrix view_rot;				/* view rotation	     */

  IGRpoint point;				/* point on arc 	     */
  
  IGRvector view_vc;				/* view vector		     */
  IGRvector n1,n2;				/* arc normal vectors        */

  IGRdouble poles1[21],knots1[10],wts1[7];	/* storage for arcs	     */
  IGRdouble poles2[21],knots2[10],wts2[7];	/* storage for arcs	     */
  IGRdouble points[9];				/* input points		     */
  IGRdouble dot_pro;				/* dot product		     */
  IGRdouble theta;				/* angle		     */

  IGRshort max_id,max_val;			/* max number of objects and */
						/* values per ellipse  event */
  IGRshort dim;					/* dimension of matrix	     */
  IGRshort set0_inq1;				/* view inquiry information  */
  IGRshort i;					/* index		     */

  IGRlong which_error,bytes_ret;		/* view inquiry information  */
  IGRlong num;					/* number of points	     */
  IGRlong mess;					/* return code		     */



  *msg = MSSUCC;

  max_id =  1;					/* max number of ids for ar  */
  max_val = 1;					/* max number of vals for ar */

  if( *num_events == GRMAX_AR_EVENTS+1 )	/* valid number of events?   */
    {
      if( GRprerout(msg,events,num_events,&max_id,&max_val,rtevents) )
	{
	  IGRlong status;
	  struct var_list list[2];

           list[0].var = VIEW_ROTATION;
           list[0].var_ptr = (char *)view_rot;
           list[0].num_bytes = sizeof(IGRdouble)*16;
           list[0].bytes_returned= &bytes_ret;
           list[1].var = END_PARAM;
           list[1].var_ptr = NULL;
           list[1].num_bytes = 0;
           list[1].bytes_returned = NULL;

/*          if( GRwnparam(msg,&set0_inq1,&rtevents[0].viewid,&which_error,
			VIEW_ROTATION,view_rot,sizeof(IGRdouble)*16,
			&bytes_ret,END_PARAM) )
*/

           status = dp$inq_set_gragad( msg = msg,
                              osnum = rtevents[0].viewid.osnum,
                              gragad_objid = rtevents[0].viewid.objid,
                              which_error = &which_error,
                              var_list = list );

            if( status & 1)
	    {
	      
	      if( rtevents[2].type == GRD_POINT )
	        {
		  arcs[0].poles = poles1;	/* init arcs		     */
		  arcs[0].knots = knots1;
		  arcs[0].weights = wts1;

		  arcs[1].poles = poles2;
		  arcs[1].knots = knots2;
		  arcs[1].weights = wts2;

		  if( *ccw )			/* determine view vector     */
		    {
		      view_vc[0] = view_rot[8];
		      view_vc[1] = view_rot[9];
		      view_vc[2] = view_rot[10];
		    }
		  else
		    {
		      view_vc[0] = -view_rot[8];
		      view_vc[1] = -view_rot[9];
		      view_vc[2] = -view_rot[10];
		    }

		  if( rtevents[3].type == GRD_POINT )
	      	    {
		      for(i=0;i<3;++i)		/* load points	      	     */
			 {
			   points[i]   = rtevents[2].pt[i];
			   points[i+3] = rtevents[0].pt[i];
			   points[i+6] = rtevents[3].pt[i];
			 }
						/* construct two arcs	     */
	              if( MAarr3ptconstr(&mess,&rtevents[1].val[0],points,
					 view_vc,arcs,n1,n2) )
			{
			  MAdotvc(&mess,view_vc,n1,&dot_pro);

			  if( dot_pro >= 0.0 ) /* return counter-clockwise   */
			    {
			      MAbccopy(&mess,&arcs[0],ar);
			    }
			  else
			    {
			      MAbccopy(&mess,&arcs[1],ar);
			    }
			}
		      else
			{
			  *msg = MSFAIL;
			}
		    }
		  else
		    {				/* produce start point of ar */
		      MAsubvc(&mess,rtevents[2].pt,rtevents[0].pt,point);
		      MAunitvc(&mess,point,point);
		      MAscalvc(&mess,&rtevents[1].val[0],point,point);
		      MAaddvc(&mess,rtevents[0].pt,point,point);
						/* construct ar		     */
		      MAarcptangconstr(msg,rtevents[0].pt,point,
				       &rtevents[3].val[0],view_vc,ar);
		    }
	        }
	      else
		{				/* set up IGRarc arc	     */
		  arc.origin[0] = rtevents[0].pt[0];
		  arc.origin[1] = rtevents[0].pt[1];
		  arc.origin[2] = rtevents[0].pt[2];

		  arc.prim_axis = arc.sec_axis = rtevents[1].val[0];

		  arc.start_angle = rtevents[2].val[0];

		  dim = 4;
		  MAtrnmx(&mess,&dim,view_rot,arc.rot_matrix);

		  if( rtevents[3].type == GRD_VALUE )
		    {				/* determine sweep angle     */
		      arc.sweep_angle = rtevents[3].val[0];
		    }
		  else
		    {				/* produce point on arc      */
		      if( rtevents[1].val[0] > 0.0)/* find sine and cosine   */
			{
		          MAsubvc(&mess,rtevents[3].pt,rtevents[0].pt,point);

		          num = 1;		/* take to local system      */
		          MAptsxform(&mess,&num,view_rot,point,point);

						/* get principle angle	     */
		          theta = MAatan2(&mess,&point[1],&point[0]);
						/* calculate sweep angle     */
		          if( rtevents[2].val[0] <= theta )
			    {
			      arc.sweep_angle = theta - rtevents[2].val[0];
			    }
		          else
			    {
			      arc.sweep_angle = 2.0 * PI - rtevents[2].val[0]
						+ theta;
			    }
			}
		      else
			{
			  *msg = MASDGENRAT;
			}
		    }

		  if( *msg & 1 )
		    {
		      MAartobc(msg,&arc,ar);	/* convert IGRarc to B-spline*/
		    }
		}
	    } 
        }
    }
  else
    {
      *msg = MSINARG;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */     
