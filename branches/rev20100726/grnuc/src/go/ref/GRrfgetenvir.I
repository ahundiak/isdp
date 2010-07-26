/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetenvironment - get the environment information
		for objects in this reference file.
Synopsis
	GRgetenvironment(msg,env_path,new_env)

	IGRlong *msg	return message
	struct GRmd_env *env_path 
			the environment path to this attachment 
	struct GRmd_env *new_env
			the environment information for objects 
			    in the reference file

Description
	This method returns the environment information 
	for objects in this attachment of a reference file.  

 	This routine computes the transformation necessary to go
 	transform objects in the reference file space to the 
 	master file space. The structure returned also contains the
 	module information necessary to communicate with objects in
 	the reference file space.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error occured of file not yet attached
Notes
	None.
History
	MAS  	08/20/86 	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "refpriv.h"
#include "madef.h"
#include "OMmacros.h"

method GRgetenvironment(IGRlong *msg; struct GRmd_env *env_path;
		struct GRmd_env *new_env)
{
    IGRshort four;
    IGRlong  msg1;
    IGRlong OMmsg;		
    IGRint  i,
	    dimension,
	    dimension2;


    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    dimension = om$dimension_of(varray = me->filename);

    dimension2 = om$dimension_of(varray = me->osname);

    if ((dimension) && (dimension2))
    {
        if (env_path->md_env.matrix_type != MAIDMX)
        {			/* additional transformation necessary	*/
	    four = 4;
	    MAmulmx(msg,&four,&four,&four,env_path->md_env.matrix,
		me->ref_to_master_matrix,new_env->md_env.matrix);
    	}
    	else			/* no nesting present			*/
    	{
	    for (i=0; i<16; ++i)
	    {
	    	new_env->md_env.matrix[i] = me->ref_to_master_matrix[i];
	    }
    	}
        if (1 & *msg)		/* if successful			*/
        {			/* get type of matrix			*/
            MAtypemx(&msg1,new_env->md_env.matrix,
		   &new_env->md_env.matrix_type);
				/* get module information of ref. file	*/
	    Get_module_info(msg,me->osname,&new_env->md_id.osnum,
			&new_env->md_id.objid);
	    if (! (1 & *msg))
	    {
	        OMmsg = OM_E_ABORT;
	    }
        }
        else
        {
	    OMmsg = OM_E_ABORT;
        }
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }

    return( OMmsg );
}
end implementation GRreffile;
