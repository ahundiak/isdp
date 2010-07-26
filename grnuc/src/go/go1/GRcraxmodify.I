/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRcircle
     METHOD NAME: GRaxmodify

     Abstract: This routine modifies a circle object by allowing
	      an input point which is projected onto the circle
	      to define a new orientation of the object. Also, 
	      a second input point is projected onto the new axis
	      created by the first point to determine the length
	      of the primary axis.

-----
%SC%    

	GRaxmodify(msg,env,axis_pt,end_pt,newid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     env	  GRmd_env	 environment information
     axis_pt	  IGRpoint	 point indicating axis to modify
				 ( it also creates the axis to modify)
     end_pt	  IGRpoint	 point to extend end of axis to

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - severe error
					MASDGENRAT - circle was
				 degenerate.
					MSINARG - axis_pt did not
				 project uniquely onto circle

     newid	  GRobjid	 returned object id

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     MAptelproj
	     MAsubvc
	     MAcrossvc
	     MAaddvc
	     MA3protmx
	     MAptlnproj
	     MA2ptdis
	     MAartobc
     Methods:
	     GRgetarc
	     GRpostabsg
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	RDH     05/02/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the IGR geometry of the circle object and then
the  axis point is projected onto the arc to determine the end point
of the new primary axis and a new rotation matrix is found. Finally,
the endpoint is projected onto the new axis to determine the length 
of the primary axis and the object is posted.

----*/
/*EH*/

class implementation GRcircle;


#include "grimport.h"
#include "msdef.h"
#include "maerr.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAptarproj();
extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAcrossvc();
extern    IGRboolean    MAaddvc();
extern    IGRboolean    MA3protmx();
extern    IGRboolean    MAtrnmx();
extern    IGRboolean    MAptlnproj();
extern    IGRboolean    MA2ptdis();
extern    IGRboolean    MAartobc();

method GRaxmodify(IGRlong *msg; struct GRmd_env *env; IGRpoint axis_pt,
		  end_pt; GRobjid *newid)
{
  struct IGRarc arc;				/* arc geometry		     */
  struct IGRline prim;				/* axis of object	     */
  struct GRpost_info info;	

  IGRpoint proj_pt1;				/* project point	     */

  IGRvector n;					/* normal to circle	     */
  IGRvector v0,v1;				/* vectors along axes	     */

  IGRdouble proj_pt[6];				/* project points	     */
  IGRdouble t;					/* t parameter of proj_pt    */

  IGRlong mess;					/* return code		     */
  IGRlong OMmsg;				/* OM return code	     */

  IGRshort num;					/* number of project points  */



  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;
  *newid = my_id; 
						/* get IGR geometry          */
  OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRconic.GRgetarc(msg, &env->md_env.matrix_type,env->md_env.matrix,&arc),
                  senderid = my_id,
                  targetid = my_id);

  if( 1 & OMmsg & *msg )
    {
      if( arc.prim_axis != 0.0 )
        {
          if( MAptelproj(&mess,axis_pt,&arc,&num,proj_pt) )
            {
    	      n[0] = arc.rot_matrix[2];
	      n[1] = arc.rot_matrix[6];
	      n[2] = arc.rot_matrix[10];

	      MAsubvc(&mess,proj_pt,arc.origin,v0);
	      MAcrossvc(&mess,n,v0,v1);
	      MAaddvc(&mess,arc.origin,v1,v1);

	      if( MA3protmx(&mess,arc.origin,proj_pt,v1,arc.rot_matrix) )
	        {
	          num = 4;
	          MAtrnmx(&mess,&num,arc.rot_matrix,arc.rot_matrix);

	          prim.point1 = arc.origin;
	          prim.point2 = proj_pt;

	          MAptlnproj(&mess,end_pt,&prim,proj_pt1,&t);

	          MA2ptdis(&mess,arc.origin,proj_pt1,&arc.prim_axis);

                  info.construct_flag = FALSE;

	      	  OMmsg = om$send(mode = OM_e_wrt_object,
                                  msg = message GRconic.GRputarc
                                        (msg,
                                         env,
                                        &info,
                                        &arc,
                                         newid),
                                  senderid = my_id,
                                  targetid = my_id);
		}
	      else
	        {
	          *msg = MSFAIL;
	        }
	    }
	  else
	    {
	      *msg = MSINARG;
	    }
	}
      else
        {
          *msg = MASDGENRAT;
        }
    }
  else
    {
      if( !( 1 & *msg ) )
	{
          OMmsg = OM_E_ABORT;
	}
    }

    my_id = *newid;

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRcircle;
