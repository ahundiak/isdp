/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRvg
     METHOD NAME:   GRtaltchgclass

     Abstract: 
		This method sets up the necessary information for 
		the constructing of an object.  This will be
		particularily useful when an object changes class
		during posting the abstract geometry to the 
		instance data.

-----
%SC%    

     GRtaltchgclass(msg,env,my_id,classname,properties,
		geometry,chan_flag, del_flag, new_objid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *env	  GRmd_env	 environment information
     *my_id	  GRobjid	 Object id of calling object
     *classname   char	 array for classname
     *properties  short 	 common property bits
     *geometry	  char	 pointer to the geometry in 
				    internal format
     *chan_flag	  short	 flag to indicate whether or not 
				    channel linkages are to be
				    preserved:
				    0 = do not preserve
				    1 = preserve linkages    
     *del_flag	  short	 flag to indicate whether or not 
				    delete the input object:
				    0 = do not delete
				    1 = delete the old object

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  long	 completion code
				    - MSSUCC if successful
				    - MSINARG classname incorrect
				    - MSFAIL if error occured
     *new_objid	  GRobjid	 new object id

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:		

     Methods:		

	GRgetsymb
	GRdelete
				
-----
%RL%

     RELATIONS REFERENCED:	
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:
	
	MAS	05/16/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This routine gathers the necessary information to construct 
an object.  This is especially useful in methods where an
object changes class.

If requested, any channel linkages will be maintained.

If requested, the old object will be deleted.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"


from GRlinear import GRputpolyline;
from GRconic import GRputarc;

long GRtaltchgclass(msg, env, my_id, type, classname,  properties,
	geometry, old_range, range)

    long 	*msg; 			/* return message		*/
    struct GRmd_env *env; 		/* environment information	*/
    GRobjid	*my_id;			/* objects id			*/
    int	type;			/* 0 = arc, 1 = polyline	*/
    char 	*classname; 		/* classname to construct	*/
    short       *properties;	/* object properties		*/
    char 	*geometry; 		/* the new geometry		*/
    double	*old_range;
    double   *range;

{
	long		OMmsg;		/* OM return code		*/

	struct GRmd_env	  temp_env;
	struct GRpost_info post_info;

	GRobjid		newobjid;

	*msg = MSSUCC;			/* initialize to success	*/
	OMmsg = OM_S_SUCCESS;

	OMmsg = GRownerrem(msg,env,my_id,&env->md_id.osnum,old_range);

        if ( 1 & OMmsg & *msg)
	{
      					/* set up new environment info	*/
	    temp_env.md_id.objid = NULL_OBJID; 
	    temp_env.md_id.osnum = env->md_id.osnum; 
	    temp_env.md_env = env->md_env;

	    OMmsg = om$change_class(osnum=OM_Gw_current_OS,
			objid = *my_id,
			classname = classname);

	    printf("OMmsg = %X\n",OMmsg);

	    if ( 1 & OMmsg)
	    {
		post_info.construct_flag = 1;
	    	if (type == 1)
	    	{
	    	    OMmsg = om$send(msg = message GRlinear.GRputpolyline
			    (msg,&temp_env,&post_info,(struct IGRpolyline *)geometry,&newobjid),
			senderid = *my_id,
			targetid = *my_id);
		}
		else if (type == 0)
		{
	    	    OMmsg = om$send(msg = message GRconic.GRputarc
			(msg,&temp_env,&post_info,(struct IGRarc *)geometry,&newobjid),
			senderid = *my_id,
			targetid = *my_id);
		}		

		printf("newobjid = %d\n",newobjid);

		if (1 & OMmsg & *msg)
		{
	    	    OMmsg = GRowneradd(msg,env,&newobjid,&env->md_id.osnum,
			range);
		}
	    }
	}

	return (OMmsg);

}
end implementation GRvg;
