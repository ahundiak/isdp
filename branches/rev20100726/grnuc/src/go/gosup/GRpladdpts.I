/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	GRpladdpts
 
     Abstract:

		This function adds a set of points to the end of 
	a planar, linear graphics object.  For a closed geometry
	(e.g., a polygon), the repeated last point is removed,
	the new points are added, and a new repeated last point
	is generated.

-----
%SC%

     VALUE = GRpladdpts(msg,env,osnum,objid,num,points,option,
			vector,new_objid)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *env	  GRmd_env	 structure defining the transformation
				 and other info about the object
     *osnum	  GRspacenum	 space number of graphics object
     *objid	  GRobjid	 object id of graphics object
     *num	  IGRshort	 number of points to add
     *points	  IGRdouble	 array of 3-D points to add
     *option	  IGRshort	 option to be used for closed linear
				 objects
				   - if = 0, then replace current
				     repeated last point with new
				     list of points and close again
				     (primarily used for polygons)
				   - if = 1, then add current list
				     of points without deleting 
				     the current last point
				     (primarily used for linestrings)
     vector	  IGRvector	 vector defining projection 
				 direction (may be degenerate)

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				  - MSSUCC if successful
				  - GRSNOINVTRAN (severe) if input 
				    matrix is not invertible
				  - GRSDGNEXCEED (severe) if range
				    exceeds design limits
				  - MSFAIL (severe) if other error
     *new_objid	 GRobjid	 used if object changes classes,
				 otherwise is same as original id

     VALUE (IGRboolean) = TRUE	  - if successful
			= FALSE   - if an error occurred

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

		MAlnplproj
		MAaddvc

     Methods:

		GRaddpts
		GRdetplane
-----
%NB%

     NOTES:	None.
-----
%CH%
     CHANGE HISTORY:
	
	REJ  05/14/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

	Looping thru the given points, as soon as the object defines
	a unique plane then project the remaining points onto that
	plane along the given vector and add these points.  Until a
	plane is found, merely add points.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"

extern    IGRboolean    MAlnplproj();
extern    IGRboolean    MAaddvc();

IGRboolean GRpladdpts(msg,env,osnum,objid,num,points,option,
		      vector,new_objid)

IGRlong    *msg;			/* output - completion code	*/
struct     GRmd_env *env;		/* input - environment		*/
GRspacenum *osnum;			/* input - space number 	*/	
GRobjid    *objid;			/* input - object id		*/
IGRshort   *num;			/* input - number of pts to add	*/	
IGRdouble  *points;			/* input - points to add	*/
IGRshort   *option;			/* input - add option		*/
					/*	   0 for polygons	*/
					/* 	   1 for linestrings	*/
IGRvector  vector;			/* input - projection direction	*/
GRobjid	   *new_objid;			/* output - object id of new	*/
					/* 	    object		*/

{
	IGRboolean  status;		/* function return status	*/
	IGRlong	    OMreturn;		/* working return value		*/
	IGRlong	    msg1;		/* working completion code	*/
	IGRint	    i,j;		/* loop counters		*/
	GRobjid	    id;			/* working object id		*/
	IGRvector   normal;		/* normal to plane		*/
	struct IGRplane plane;		/* plane of object		*/
	IGRpoint    point1,point2;	/* two points defining line	*/
	struct IGRline line;		/* line for projection		*/
	IGRpoint    point;   		/* projected point		*/
	IGRpoint    temp;		/* temporary point		*/
	IGRdouble   t;			/* t-parameter			*/
	IGRshort    n;			/* number of points to add	*/


	*msg = MSSUCC;			/* initialize to success	*/
	status = TRUE;

	plane.normal = normal;
	plane.point = point;
	line.point1 = point1;
	line.point2 = point2;

	*new_objid = *objid;
	id = *objid;

	for (i = 0; i < *num; i++)
	{
	
	  OMreturn = om$send(mode = OM_e_wrt_object,
                             msg = message GRvg.GRdetplane(
				&msg1,&env->md_env.matrix_type,     
				&env->md_env.matrix[0],&plane),
                             senderid = *objid,
                             targetid = *objid,
                             targetos = *osnum);

	  if (! (1 & OMreturn))
	  {
	    status = FALSE;
	    *msg = MSFAIL;
	    break;
	  }

	  if (1 & msg1)				/* unique plane		*/
	  {
	    for (j = i; j < *num; j++)
	    {
	      point1[0] = points[3*j];
	      point1[1] = points[3*j+1];
	      point1[2] = points[3*j+2];
	      MAaddvc(&msg1,point1,vector,point2);
	      status = MAlnplproj(&msg1,&line,&plane,temp,point,&t);
	      if (! status) 
	      {
		status = FALSE;
	  	*msg = MSFAIL;
	        goto wrapup;
	      }	        	   
	      points[3*j] = point[0];
	      points[3*j+1] = point[1];
	      points[3*j+2] = point[2];
	    }

	    n = *num - i;			/* number to add	*/

	    OMreturn = om$send(mode = OM_e_wrt_object,
                               msg = message       GRlinear.GRaddpts(msg,env,&n,&points[3*i],       option,new_objid),
                               senderid = id,
                               targetid = id,
                               targetos = *osnum);

	    if (! (1 & OMreturn))
	    {
	      status = FALSE;
	    }

	    break;

	  }
	  else					/* non-unique plane	*/
	  {

	    n = 1;				/* number to add	*/

	    OMreturn = om$send(mode = OM_e_wrt_object,
                               msg = message       GRlinear.GRaddpts(msg,env,&n,&points[3*i],       option,new_objid),
                               senderid = id,
                               targetid = id,
                               targetos = *osnum);

	    if (! (1 & OMreturn))
	    {
	      status = FALSE;
	      break;
	    }

	  }

	  id = *new_objid;
	}

wrapup:

	return (OMreturn);

}

end implementation GRlinear;
