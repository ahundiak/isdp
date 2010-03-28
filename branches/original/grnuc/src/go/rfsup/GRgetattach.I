/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetattachment - determines if a  reference file
		attachment is to become the active 
		construct file.

Synopsis

	IGRint GRgetattachment(msg,objid,info)

	IGRlong *msg;		return message	
	GRobjid	*objid;		object id of object	
	IGRchar	*info;		information sent to function 

Description

	This is a function invoked by the GRfunction method
	to determine if a given line intersects a reference 
	file attachment object.  If so, the attachment becomes
	the active file.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/14/87	Design date.

\*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"

from GRreffile import GRlninattachment,GRgetenvironment;

IGRint GRgetattachment(msg,objid,info)

IGRlong 	*msg;			/* return message		*/
struct GRid	*objid;			/* object id of object		*/
IGRchar		*info;			/* information sent to function */

{
    IGRlong	OMmsg;			/* return codes			*/

    IGRint	indicator;		/* relationship of point to 
					   attachment.			*/

    struct GRfunction_info *my_info;	/* information passed in	*/
					
    struct  get_att_arguments		/* special information passed in*/
    {
	struct GRmd_env env;
	struct IGRline line;
	IGRdouble tol;
    } *get_att_args;

    OM_S_MESSAGE *lnin_msg;		/* message to pass to attachment*/


    OMmsg = OM_S_SUCCESS;		/* initialize variables		*/
    *msg =  MSSUCC;

    my_info = (struct GRfunction_info *)info;

    get_att_args = (struct get_att_arguments *)my_info->info;

    lnin_msg = message GRreffile.GRlninattachment(
		msg,&my_info->md_env->md_env.matrix_type,
		my_info->md_env->md_env.matrix,
		get_att_args->line.point1,
		get_att_args->line.point2,
		&get_att_args->tol,&indicator);

    OMmsg = om$send(
	msg = lnin_msg,
	senderid = objid->objid,
	targetid = objid->objid,
	targetos = objid->osnum);

#ifdef DEBUG
 	printf("GRgetattach - send completed\n");
	printf("OMmsg = %X\n",OMmsg);
	printf("indicator = %d\n",indicator);
#endif

    if (1 & OMmsg & *msg)
    {
	if (indicator)		/* point is in or on attachment		*/
	{			/* get the environment information	*/
	    OMmsg = om$send(
		msg = message GRreffile.GRgetenvironment(
			msg,my_info->md_env,&get_att_args->env),
		senderid = objid->objid,
		targetid = objid->objid,
		targetos = objid->osnum);
				/* if successful; stop sending		*/
	    if (1 & OMmsg & *msg)
	    {
	    	OMmsg = OM_I_STOP_SENDING;
	    }
	}
    }

    return(OMmsg);
}

end implementation GRgraphics;
