/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRdisextend

     Abstract: This routine extends one endpoint of a B-spline curve
	      along its natural extenion by a specified distance.

-----
%SC%    

	GRdisextend(*msg,*env,endpoint,dist,newend)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     env	  GRmd_env	 environment information
     endpoint	  IGRpoint	 endpoint to extend
     dist	  IGRdouble	 distance to extend geometry

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
					MASDGENRAT - curve is a
				 point

     newend	  IGRpoint	 new end point
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     MA2pt2dis
	     MAsubvc
	     MAunitvc
	     MAscalvc
	     MAaddvc

     Methods:
	     GRgenabsg
	     GRpostabsg
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:

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
is then used as a vector to scale by the distance to find the new 
end point of the curve. Then the new curve is posted.

----*/
/*EH*/

class implementation GRbspline;


#include "grimport.h"
#include "msdef.h"
#include "maerr.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MA2pt2dis();
extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAunitvc();
extern    IGRboolean    MAscalvc();
extern    IGRboolean    MAaddvc();

method GRdisextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint;
		   IGRdouble *dist; IGRpoint newend)
{
  struct IGRbsp_curve *bc;			/* abstract geometry pointer */
  struct GRpost_info info;

  IGRvector vc;					/* direction vector	     */

  IGRchar *ptr;					/* abstract geometry pointer */

  GRobjid newid;				/* new object id	     */

  IGRdouble dis1,dis2;				/* distances		     */

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
	           MAsubvc(&mess,&bc->poles[0],&bc->poles[i*3],vc);
		   if( MAunitvc(&mess,vc,vc) )
		     {
		       break;
		     }
		 }
	      j = 0;				/* set j to modify first pole*/
	    }
	  else
	    {
	      for(i = bc->num_poles - 2; i >= 0; --i)
		 {
	           MAsubvc(&mess,&bc->poles[(bc->num_poles - 1) * 3],
			   &bc->poles[i * 3],vc);
		   if( MAunitvc(&mess,vc,vc) )
		     {
		       break;
		     }
		 }
	      j = bc->num_poles - 1;		/* set j to modifu last pole */
	    }

	  if( 1 & mess )
	    {
	      MAscalvc(&mess,dist,vc,vc);	/* scale by dist	     */
						/* add offset to pole	     */
	      MAaddvc(&mess,&bc->poles[j * 3],vc,&bc->poles[j * 3]);

	      newend[0] = bc->poles[j * 3];
	      newend[1] = bc->poles[j * 3 + 1];
	      newend[2] = bc->poles[j * 3 + 2];
						/* post the object	     */
	      info.construct_flag = FALSE;

	      OMmsg = om$send(mode = OM_e_wrt_object,
                              msg = message GRvg.GRpostabsg(msg,env,
					&info,ptr,&newid),
                              senderid = my_id,
                              targetid = my_id);
	    }
	  else
	    {
	      *msg = MASDGENRAT;
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
