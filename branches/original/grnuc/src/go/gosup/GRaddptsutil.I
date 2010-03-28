/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRaddptsutil

     Abstract: This is a utility function for adding points to
	a linear object.

-----
%SC%    

     VALUE = GRaddptsutil(msg,env,osnum,objid,num,points,vector,new_objid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *env	  GRmd_env	 structure defining the transformation
				 and other info about the object
     *osnum	  GRspacenum	 space number of graphics object
     *objid	  GRobjid	 object id of graphics object
     *num	  IGRshort	 number of points to add
     *points	  IGRdouble	 array of 3-D points to add
     vector	  IGRvector	 vector defining projection 
				 direction (may be degenerate)

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 return code:
				  - MSSUCC if successful
				  - GRSNOINVTRAN (severe) if input 
				    matrix is not invertible
				  - GRSDGNEXCEED (severe) if range
				    exceeds design limits
				  - MSFAIL (severe) if other error
				  - MSINARG invalid class, orthogonal
					    polygon
     *new_objid	 GRobjid	 used if object changes classes,
				 otherwise is same as original id

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     	GRpladdpts
		GRorthaddpts

     Methods:
		GRaddpts	     
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
		This function assumes that the object being operated
	on is of the GRlinear class and is an instance of GRlinestr,
	GRpllinestr, GRpolygon or GRorthlnst.

		This function can not be used on orthogonal polygons.
	Insert vertex is suggested if a point needs to be added to
	an orthogonal polygon.
	   
-----
%CH%

     CHANGE HISTORY:
	
	RDH     03/16/88 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
Using om$is_ancestry_valid, determine the type of linear object
being modified and call the appropriate function or method to 
perform the point insertions.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"

extern    IGRlong    GRpladdpts();

IGRlong GRaddptsutil(msg,env,osnum,objid,num,points,vector,new_objid)

IGRlong    *msg;			/* output - completion code	*/
struct     GRmd_env *env;		/* input - environment		*/
GRspacenum *osnum;			/* input - space number 	*/	
GRobjid    *objid;			/* input - object id		*/
IGRshort   *num;			/* input - number of pts to add	*/	
IGRdouble  *points;			/* input - points to add	*/
IGRvector  vector;			/* input - projection direction	*/
GRobjid	   *new_objid;			/* output - object id of new	*/
					/* 	    object		*/

{
  GRclassid classid;			/* class id of input object	*/

  IGRshort option;

  IGRboolean planar,polygon,orthogonal;

  IGRchar *ancestor;			/* parent class names		*/

  IGRlong OMmsg;


  *msg = MSSUCC;

  planar = FALSE;
  polygon = FALSE;

  option = 1;					/* signal no closure	*/

  OMmsg = om$get_classid(osnum = *osnum, objid = *objid, p_classid = &classid);

  if( 1 & OMmsg )
  {
    ancestor = "GRplanar";

    OMmsg = om$is_ancestry_valid(subclassid = classid,
				 superclassname = ancestor);

    if( OMmsg == OM_S_SUCCESS )
    {
      planar = TRUE;

      ancestor = "GRorthogonal";

      OMmsg = om$is_ancestry_valid(subclassid = classid,
				   superclassname = ancestor);

      if( OMmsg == OM_S_SUCCESS )
      {
	orthogonal = TRUE;

        ancestor = "GRorthpoly";

        OMmsg = om$is_ancestry_valid(subclassid = classid,
				     superclassname = ancestor);

        if( OMmsg == OM_S_SUCCESS )
 	{
	  polygon = TRUE;
	}
      }
      else
      {
        orthogonal = FALSE;

        ancestor = "GRpolygon";

        OMmsg = om$is_ancestry_valid(subclassid = classid,
				     superclassname = ancestor);

        if( OMmsg == OM_S_SUCCESS )
 	{
	  polygon = TRUE;
	}
      }
    }

    if( !planar )				/* linestring		*/
    {
      OMmsg = om$send(msg = message GRlinear.GRaddpts(msg,env,num,points,
    						      &option,new_objid),
		      senderid = *objid,
		      targetid = *objid,
		      targetos = *osnum);
    }
    else
    {
      if( polygon )
      {
        option = 0;
      }

      if( !orthogonal )
      {
	OMmsg = GRpladdpts(msg,env,osnum,objid,num,points,&option,vector,
			   new_objid);
      }
      else
      {
        if( !polygon )
	{
          OMmsg = GRorthaddpts(msg,env,osnum,objid,num,points,&option,vector,
			       new_objid);
	}
	else
	{
	  *msg = MSINARG;
	}
      }
    }
  }

   return( OMmsg );

}/* This has been an R.D.H. production!!! */	

end implementation GRlinear;
