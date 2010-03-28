/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRcirarc
     METHOD NAME: GRaxmodify

     Abstract: This routine modifies a circular arc object by allowing
	      an input point which is projected onto the circular arc
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
					MASDGENRAT - arc was
				 degenerate.
					MSINARG - axis_pt did not
				 project uniquely onto circular arc

     newid	  GRobjid	 returned object id

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     MAptarproj
	     MAsubvc
	     MAptsxform
	     MAcrossvc
	     MAaddvc
	     MA3protmx
	     MAang2vc
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
        scw     06/23/92 : Added static ANSI C prototypes
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the 	IGR geometry of the arc object and 
then the axis point is projected onto the arc to determine the end 
point of the new primary axis and a new rotation matrix is found. 
Finally, the endpoint is projected onto the new axis to determine 
the length of the primary axis and a new start angle is computed. 
Then the object is posted.

----*/
/*EH*/

class implementation GRcirarc;


#include "grimport.h"
#include "msdef.h"
#include "maerr.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAsincos();
extern    IGRboolean    MAptsxform();
extern    IGRboolean    MAptarproj();
extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAcrossvc();
extern    IGRboolean    MAaddvc();
extern    IGRboolean    MA3protmx();
extern    IGRboolean    MAtrnmx();
extern    IGRboolean    MAptlnproj();
extern    IGRboolean    MA2ptdis();
extern    IGRboolean    MAartobc();

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static IGRboolean GRdetangle __((IGRlong *msg, struct IGRarc *arc, 
                                 IGRpoint st_pt));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe




method GRaxmodify(IGRlong *msg; struct GRmd_env *env; IGRpoint axis_pt,
		  end_pt; GRobjid *newid)
{
  struct IGRarc arc;				/* arc geometry		     */
  struct IGRline prim;				/* axis of object	     */
  struct GRpost_info info;

  IGRpoint proj_pt1;				/* project point	     */
  IGRpoint st_pt;				/* arc start point           */

  IGRvector n;					/* normal to circle	     */
  IGRvector v0,v1;				/* vectors along axes	     */

  IGRdouble proj_pt[6];				/* project points	     */
  IGRdouble t;					/* t parameter of proj_pt    */
  IGRdouble sin_val,cos_val;			/* sine and cosine of st ang */

  IGRlong m;					/* number of points          */
  IGRlong mess;					/* return code		     */
  IGRlong OMmsg;				/* OM return code	     */
  
  IGRshort num;					/* number of project points  */


  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;
  *newid = my_id;
  

						/* get IGR geometry          */
  OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRconic.GRgetarc(msg,&env->md_env.matrix_type,
                  env->md_env.matrix,&arc),
                  senderid = my_id,
                  targetid = my_id);

  if( 1 & OMmsg & *msg )
    {
      if( arc.prim_axis != 0.0 )
	{
	  if( MAptelproj(&mess,axis_pt,&arc,&num,proj_pt) )
	    {
	      MAsincos(&mess,&arc.start_angle,&sin_val,&cos_val);
	      st_pt[0] = arc.prim_axis * cos_val;
	      st_pt[1] = arc.sec_axis  * sin_val;
	      st_pt[2] = 0.0;

	      m = 1;
	      MAptsxform(&mess,&m,arc.rot_matrix,st_pt,st_pt);

	      n[0] = arc.rot_matrix[2];
	      n[1] = arc.rot_matrix[6];
	      n[2] = arc.rot_matrix[10];

	      MAsubvc(&mess,proj_pt,arc.origin,v0);
	      MAcrossvc(&mess,n,v0,v1);
	      MAaddvc(&mess,arc.origin,v1,v1);

	      if( MA3protmx(&mess,arc.origin,proj_pt,v1,arc.rot_matrix) )
	        {
	  	  MAptsxform(&mess,&m,arc.rot_matrix,st_pt,st_pt);

		  num = 4;
		  MAtrnmx(&mess,&num,arc.rot_matrix,arc.rot_matrix);

		  prim.point1 = arc.origin;
		  prim.point2 = proj_pt;
 
		  MAptlnproj(&mess,end_pt,&prim,proj_pt1,&t);

		  MA2ptdis(&mess,arc.origin,proj_pt1,&arc.prim_axis);


		  if( GRdetangle(msg,&arc,st_pt) )
	            {
                      info.construct_flag = FALSE;

                      OMmsg = om$send(mode = OM_e_wrt_object,
                                       msg = message GRconic.GRputarc(
                                             msg, 
                                             env,
                                            &info,
                                            &arc,
                                             newid),
                                  senderid = my_id,
                                  targetid = my_id);
                    }

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
          OMmsg = OM_E_ABORT;			/* failed to get input	     */
        }
    }
    my_id = *newid;
  
	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

  return( OMmsg );

}/* This has been an R.D.H. production!!! */



/* This routine determines the new start angle of the modified arc with
  respect to the new orientation and axis lengths.
*/


static IGRboolean GRdetangle(msg,arc,st_pt)

		  IGRlong       *msg;		/* return code		     */
		  struct IGRarc *arc;		/* arc		  	     */
	   	  IGRpoint	 st_pt;		/* start point of arc	     */

{
  IGRvector x;					/* x-axis		     */

  IGRdouble alpha[3];				/* angle between axis and    */
						/* start point of arc        */
  IGRdouble sin_val,cos_val;	                /* adjusted sine and cosine  */

  IGRdouble z;

extern    IGRdouble    MAatan();

  IGRlong mess;					/* return code		     */
  
  *msg = MSSUCC;

  
  x[0] = 1.0;
  x[1] = 0.0;
  x[2] = 0.0;

  MAang2vc(&mess,x,st_pt,alpha);

  sin_val = alpha[1] * arc->prim_axis;
  cos_val = alpha[2] * arc->sec_axis;

/*
 *
 *  Check for special cases.
 *
 */

  if ((cos_val != 0.0) && (sin_val != 0.0))
  {
    if (cos_val == 0.0) 	/* either 90 or 270 degrees	*/
    {
      if (sin_val > 0.0)
      {
        arc->start_angle = PI/2.0;	
      }  
      else 
      {
        arc->start_angle = 3.0*PI/2.0;
      }
    }
    else
    {
      if (sin_val == 0.0)	/* either 0 or 180 degrees	*/
      {
        if (cos_val > 0.0)
        {
          arc->start_angle = 0.0;
        } 
        else 
        {
          arc->start_angle = PI;
        }
      }
      else
      {

/* 
 *
 *  Not a special case, determine the principal value of the arctangent
 *  of sin/cos.
 *
 */

        z = (sin_val)/(cos_val);	/* z is the tangent		*/

        arc->start_angle = MAatan(msg,&z);

/*
 *
 *  Now, put arc_tan into its proper quadrant.
 *
 */

        if (arc->start_angle > 0.0) 	/* either quadrant I or III	*/
        {
          if (sin_val < 0.0)
          {   
            arc->start_angle += PI;	/* quadrant III			*/
          }
        } 
        else 
        {		
          if (arc->start_angle < 0.0)	/* either quadrant II or IV	*/
          {
            if (sin_val > 0.0)
            {
              arc->start_angle += PI;	/* quadrant II			*/
            } 
            else 
            {
              arc->start_angle += 2.0*PI;/* quadrant IV			*/
	    }
          }
        }
      }
    }
  }
  else
  {
    *msg = MSFAIL;
  }


  return( *msg == MSSUCC );

}
  
end implementation GRcirarc;
