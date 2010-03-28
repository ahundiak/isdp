/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRvg
     METHOD NAME:   GRaltchgclass

     Abstract: 
		This method sets up the necessary information for 
		the constructing of an object.  This will be
		particularily useful when an object changes class
		during posting the abstract geometry to the 
		instance data.

-----
%SC%    

     GRaltchgclass(msg,env,my_id,classname,properties,
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

long GRaltchgclass(msg, env, my_id, classname,  properties,
	geometry, chan_flag, del_flag, new_objid)


    long 	*msg; 			/* return message		*/
    struct GRmd_env *env; 		/* environment information	*/
    GRobjid	*my_id;			/* objects id			*/
    char 	*classname; 		/* classname to construct	*/
    short       *properties;	 	/* object properties		*/
    char 	*geometry; 		/* the new geometry		*/
    short	*chan_flag; 		/* indicator of whether channel
					   linkages should be maintained*/
    short	*del_flag;		/* indicator of whether the old
					   object (*my_id) should be
				 	   deleted			*/
    GRobjid 	*new_objid;		/* the new object-id		*/

{
	int save_props;

      	IGRboolean 	set_clear;
	IGRboolean	world;

	long		msg2;		/* local message		*/
	long		OMmsg;		/* OM return code		*/

	GRclassid	classid;	/* classid needed by OM		*/

        GRrange		range;
	OMuword		osnum;
	OM_S_CHANSELECT chan_sel;

	struct GRsymbology symb;	/* symbology			*/
	struct GRvg_construct arglist;	/* construct argument list	*/
	struct GRmd_env	  temp_env;

	*msg = MSSUCC;			/* initialize to success	*/
	OMmsg = OM_S_SUCCESS;

					/* get classid from OM		*/
        OMmsg = om$get_classid(classname = classname,
                               p_classid = &classid);

	if (! (1 & OMmsg))		/* get classid failed		*/
	{
	    *msg = MSINARG;
	    goto wrapup;
	}
	/* This function might have been executed  by a command object,
	   for ex: Change arc to circle command - 
	   so the below patch up code is necessary... */

	if (OM_Gw_current_OS == OM_Gw_TransOSnum_0)
		osnum=env->md_id.osnum;
	else
		osnum=OM_Gw_current_OS;

					/* get symbology for construct	*/

 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetsymb(&msg2,&symb),
                         senderid = *my_id,
                         targetid = *my_id,
                         targetos = osnum);


	if (! (1 & OMmsg & msg2))	/* get symbology failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
					/*set up arguments for construct*/
	arglist.level = symb.level;
	arglist.properties = *properties;
	if (! (*chan_flag))		/* clear component flag		*/
	{
	    arglist.properties = arglist.properties & 
		~GR_RIGID_RELATIONSHIP;
	}
 
        om$send(msg = message GRvg.GRgethprops(&msg2,(IGRuint *)&save_props),
		senderid = *my_id,
		targetid = *my_id);

					/*set up arguments for construct*/
	arglist.name = 0;		/* new object will not be named	*/
	arglist.display = &(symb.display_attr);

	arglist.class_attr = 0;		/*** at some point this will 
					     change		    *****/
	arglist.newflag = FALSE;
	arglist.msg = &msg2;
	arglist.geometry = geometry;
					/* set up new environment info	*/
	arglist.env_info = &temp_env;
	temp_env.md_id.objid = NULL_OBJID; 
	temp_env.md_id.osnum = env->md_id.osnum; 
	temp_env.md_env = env->md_env;

	OMmsg = om$construct(osnum = env->md_id.osnum,
                             classid = classid,
			     msg=message GRgraphics.GRaltconstruct
				(&arglist),
                             p_objid = new_objid,
                             neighbor = OM_GS_NULL_NEIGHBOR);

	if ( !(1 & OMmsg))		/* the construct failed		*/
	{
            *msg = MSFAIL;
	    goto wrapup;
        }

	set_clear = -1;			/* replace hidden line props	*/
	om$send(msg = message GRvg.GRchghprops(&msg2,&set_clear,
		&save_props),
		senderid = *my_id,
		targetos = env->md_id.osnum,
	        targetid = *new_objid);

	if (*chan_flag)			/* channel linkages maintained	*/
	{	    
	    chan_sel.type = OM_e_name;
	    chan_sel.u_sel.name = "GRconnector.to_owners";

	    om$send (mode = OM_e_wrt_object,
		     msg = message Root.move_chan(
				chan_sel,*my_id,env->md_id.osnum,
				chan_sel),
		     senderid = *my_id,
		     targetos = env->md_id.osnum,
		     targetid = *new_objid);

	    chan_sel.u_sel.name = "GRnotify.notification";

	    om$send (mode = OM_e_wrt_object,
		     msg = message Root.move_chan(
				chan_sel,*my_id,env->md_id.osnum,
				chan_sel),
		     senderid = *my_id,
		     targetos = env->md_id.osnum,
		     targetid = *new_objid);
	}
	
	if (*del_flag)			/* delete old object		*/
	{
	    OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRdelete(&msg2,env),
                            senderid = *my_id,
		            targetos = env->md_id.osnum,
                            targetid = *my_id);

	    if (! (1 & OMmsg & msg2))
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	    }

	}
	if (OMmsg & 1)
	{
	    world = FALSE;
	    OMmsg = om$send(msg = message GRvg.GRgetrang(&msg2,
			    &env->md_env.matrix_type,env->md_env.matrix,
			    &world,range),
			    senderid = *new_objid,
			    targetos = env->md_id.osnum,
			    targetid = *new_objid);
	    if (1 & OMmsg)
	    {
		OMmsg = GRowneradd(msg,env,new_objid,&env->md_id.osnum,
			range);
	    }
	}

 wrapup:
	return (OMmsg);

}
end implementation GRvg;
