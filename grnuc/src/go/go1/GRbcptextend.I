/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRptextend

     Abstract: This routine extends one endpoint of a B-spline curve
	      to another point.

-----
%SC%    

	GRptextend(msg,env,endpoint,ext_pt,newend);


-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     env	  GRmd_env	 environment information
     endpoint	  IGRpoint	 endpoint to extend
     ext_pt	  IGRpoint	 point to extend to

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - severe error
					MSINARG - object is not open
				 or is not linear

     newend	  IGRpoint	 new end point
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     GR2pt2dis
	     GRptlnproj
     Methods:
	     GRgenabsg
	     GRpostabsg
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	   The new endpoint is found as the projection of ext_pt onto
	  the line segment formed by the first or last two poles.

	   This routine works on curves of order 2 only (i.e. linear 
	  curves).
-----
%CH%

     CHANGE HISTORY:
	
	RDH     05/02/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This method gets the abstract geometry of the object and checks to
see if the curve is open and of order two. If both of these parameters
are correct, the distances from endpoint to the first and last poles
is computed and the pole which is closest to endpoint identifies 
which end of the curve to extend. The correct segment of the curve
is then used as a line for ext_pt to be projected onto. The project
point becomes the new endpoint and the objects new abstract geometry
is then posted.

----*/
/*EH*/

class implementation GRbspline;


#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"


extern    IGRboolean    MAptlnproj();
extern    IGRboolean    MA2pt2dis();

method GRptextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint,
		  ext_pt,newend)
{
  struct IGRbsp_curve *bc;			/* abstract geometry pointer */
  struct IGRline ln;				/* temporary line	     */
  struct GRpost_info info;
 
  IGRchar *ptr;					/* abstract geometry pointer */

  GRobjid newid;				/* new object id	     */

  IGRdouble dis1,dis2;				/* distances		     */
  IGRdouble dis;				/* distance		     */
  IGRdouble t;					/* t parameter of proj_pt    */

  IGRlong i,j;					/* indexes		     */
  IGRlong mess;					/* return code		     */
  IGRlong OMmsg;				/* OM return code	     */


  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;
						/* get abstract geometry     */
  GRgetabsg(msg,&env->md_env.matrix_type,env->md_env.matrix,&ptr,i);

  if( *msg & 1 )
    {
      bc = (struct IGRbsp_curve *)ptr;

      if( !bc->phy_closed  &&  bc->order == 2 ) /* valid curve to extend?    */
	{
	  MA2pt2dis(&mess,&bc->poles[0],endpoint,&dis1);
	  MA2pt2dis(&mess,&bc->poles[(bc->num_poles -1) * 3],endpoint,&dis2);

	  if( dis1 <= dis2 )			/* see which end to extend   */
	    {
	      for(i = 1; i < bc->num_poles; ++i)
		 {
		   MA2pt2dis(&mess,&bc->poles[0],&bc->poles[i * 3],&dis);

		   if( dis > 0.0 )
		     {
 	      	       ln.point1 = &bc->poles[0];
		       ln.point2 = &bc->poles[i * 3];
		       break;
		     }
		 }

	      j = 0;
	    }
	  else
	    {
	      for(i = bc->num_poles - 2; i >= 0; --i)
		 {
		   MA2pt2dis(&mess,&bc->poles[(bc->num_poles - 1) * 3],
			     &bc->poles[i * 3],&dis);

		   if( dis > 0.0 )
		     {
 	      	       ln.point1 = &bc->poles[(bc->num_poles - 1) * 3];
		       ln.point2 = &bc->poles[i * 3];
		       break;
		     }
		 }

	      j = bc->num_poles - 1;
	    }
						/* project ext_pt to get new */
						/* start or end point	     */
	  if( (dis > 0.0) && MAptlnproj(msg,ext_pt,&ln,newend,&t) )
	    {
	      bc->poles[j * 3]     = newend[0];
	      bc->poles[j * 3 + 1] = newend[1];
	      bc->poles[j * 3 + 2] = newend[2];

						/* post the object	     */
	      info.construct_flag = FALSE;
	
	      OMmsg = om$send(mode = OM_e_wrt_object,
                              msg = message GRvg.GRpostabsg(     msg,env,&info,ptr,&newid),
                              senderid = my_id,
                              targetid = my_id);
	    }
	  else
	    {
	      if( dis == 0.0 )
		{
		  *msg = MASDGENRAT;
		}
	    }
	}
      else
	{
	  *msg = MSINARG;			/* invalid input	     */
	  OMmsg = OM_E_ABORT;
	}
    }
  else
    {
      OMmsg = OM_E_ABORT;			/* failed to get input	     */
    }

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRbspline;
