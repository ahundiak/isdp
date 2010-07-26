/* #######################    APOGEE COMPILED   ######################## */
class implementation GRgraphics;

#include "grimport.h"
#include "godef.h"
#include "dpdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "grerr.h"
#include "msdef.h"
#include "madef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from GRcontext import GRloadctx;

%safe
static  struct  GRid	GRcurrent_context = {0};
static  struct  GRid	GRcontext_Super = {0};
static  IGRint	GRexpand_reffiles = 1;

static  struct  GRid	saved_GRcurrent_context = {0};
static  struct  GRid	saved_GRcontext_Super = {0};
static  IGRint	saved_GRexpand_reffiles = 1;

static  IGRmatrix env_matrix;
static  IGRshort  env_type;

%endsafe

GRsetupcontext(msg,Super_objid,Super_osnum,PDM_wakeup)

IGRlong		*msg;
GRobjid		*Super_objid;
GRspacenum	*Super_osnum;
OMuword		*PDM_wakeup;
{
    IGRshort	flag;

    IGRlong	OMmsg;

    IGRint	sizebuf,nret,count;

    OM_S_CHANSELECT chan,to_chan;

    extern OMuword EX_active_OS_num;
    extern OMuword EX_ACTINV_OS_num;


    struct GRmd_env md_env;

    /* check to see if caller is the context Super.  If
     * not, do nothing.
     */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    /* This is a special fix for PDM.  They need the ability to bring
     * up a file as an invisible space and not have the reference files
     * nested in the space be awakened.
     */

    *PDM_wakeup = ((EX_active_OS_num == EX_ACTINV_OS_num) ? 0 : 1);
    if (*PDM_wakeup)
    {
	saved_GRcurrent_context = GRcurrent_context;
	saved_GRcontext_Super = GRcontext_Super;
	saved_GRexpand_reffiles = GRexpand_reffiles;
    }
    if (EX_ACTINV_OS_num == *Super_osnum)
    {
	/* see if context object already exists.
	 */

	GRcontext_Super.objid = *Super_objid;
	GRcontext_Super.osnum = *Super_osnum;
	MAidmx(msg,env_matrix);
	env_type = MAIDMX;

        chan.type = OM_e_name;
	chan.u_sel.name = "Super_rfmgr.to_context";
	
	om$get_channel_count(p_chanselect = &chan,
		osnum = *Super_osnum,
		objid = *Super_objid,
		count = (OMuint *)&count);

	if (count)	/* object already exists		*/
	{
	    om$get_objid_at_index(
		    osnum = *Super_osnum,
		    objid = *Super_objid,
		    p_chanselect = &chan,
		    index = 0,
		    objidaddr = &GRcurrent_context.objid,
		    osnumaddr = &GRcurrent_context.osnum);
	}
	else
	{		
     	    sizebuf = sizeof (struct GRmd_env);

    	    gr$get_locate_env(
		    msg = msg,
		    sizbuf = &sizebuf,
		    buffer = &md_env,
		    nret = &nret);

	     /* construct master file context object
     	      */
	
	     flag = GRMASTER_CONTEXT;

    	     OMmsg = om$construct(
		    classname = "GRcontext",
		    p_objid = &GRcurrent_context.objid,
		    osnum = *Super_osnum,
	  	    msg = message GRcontext.GRloadctx
		      (msg,&md_env.md_env.matrix_type,
			md_env.md_env.matrix,Super_osnum,&flag));

	     if ( 1 & OMmsg)
	     {
		GRcurrent_context.osnum = GRcontext_Super.osnum;

    		/* connect super and context object
     		 */

    		to_chan.type = OM_e_name;
    		to_chan.u_sel.name = "GRcontext.to_super";

    		OMmsg = om$send(mode = OM_e_wrt_object,
  			msg = message Root.connect(chan,NULL,
			  GRcurrent_context.objid,
			  GRcurrent_context.osnum,to_chan,NULL),
        		senderid = GRcurrent_context.objid,
			targetid = GRcontext_Super.objid,
			targetos = GRcontext_Super.osnum);
	    }
	}
    }

    return(OMmsg);
}

GRputcontextid(msg,context_id,saved_contextid)

IGRlong		*msg;
GRobjid		*context_id;
GRobjid		*saved_contextid;
{
    *msg = MSSUCC;	

    *saved_contextid = GRcurrent_context.objid;
    GRcurrent_context.objid = *context_id;

    return (OM_S_SUCCESS);

}

GRgetcurrentctx(msg,context_id)

IGRlong		*msg;
struct GRid	*context_id;
{
    *msg = MSSUCC;
    *context_id = GRcurrent_context;

    return(OM_S_SUCCESS);
}

/*\
Name
     GRgetctxsuper -  This file gets the object id and object space
		Reference File manager of the master file.

		If the Super does not exist, it is an error.

Synopsis
	IGRlong GRgetctxsuper(msg,Super_id)

	IGRlong		*msg;		 completion code		
	struct GRid 	*Super_id;	 objid, osnum for your super	

Description

	This function returns the object id and object 
	space number of the Reference file Super of the
	master file.  This would be the super for the context
	objects for a particular design session.

Diagnostics
	The return codes:

	MSSUCC - successful completion
	MSFAIL - error

Notes
	None.

History
	MAS	06/01/87	Design Date.
\*/

IGRlong GRgetctxsuper(msg,Super_id)

IGRlong		*msg;		/* completion code		*/
struct GRid 	*Super_id;	/* objid, osnum for your super	*/
{
    IGRlong	OMmsg;


    
    OMmsg = OM_S_SUCCESS;	/* initialize return values	*/
    *msg = MSSUCC;

    *Super_id = GRcontext_Super;

    return( OMmsg );
}
/* 
 * The following functions access a statics internal variable to determine
 * if  a reference file object is in expansion mode or no expansion
 * mode.
 * 
 * The object becomes no expansion mode when nesting occurs.  This implies
 * that an R-tree pass is done, but if any Reference file objects receive
 * the message, they should ignore it and not pass it on to the object 
 * spaces they represent.
 * /
		/* 0 - no expansion mode*/
		/* 1 - expansion mode	*/

GRset_expansion_mode(expand_flag)

IGRint	*expand_flag;
{
     GRexpand_reffiles = *expand_flag;   
     return(1);
}

/* 
 *	This function returns TRUE if it is okay to pass the message
 *	on to the other object space; FALSE if it should not be
 *	passed on.
 */
	
IGRboolean GRexpansion_valid()		
{
	return(GRexpand_reffiles);
}

GRrestore_context_stack(PDM_sleep)
    IGRint	*PDM_sleep;
{
    extern OMuword EX_ACTINV_OS_num;

    *PDM_sleep = ((EX_active_OS_num == EX_ACTINV_OS_num) ? 0 : 1);
    if (*PDM_sleep)
    {
	GRcurrent_context = saved_GRcurrent_context;
	GRcontext_Super = saved_GRcontext_Super;
	GRexpand_reffiles = saved_GRexpand_reffiles;
    }
    return(1);

}

GRget_env(matrix_type,matrix)
   IGRshort  *matrix_type;
   IGRdouble *matrix;
{
   IGRint	i;
   
   for (i=0; i<16; ++i)
   {
	matrix[i] = env_matrix[i];
   }
   *matrix_type = env_type;

   return(1);

}

GRpush_env(new_matrix_type,new_matrix)
    IGRshort  *new_matrix_type;
    IGRdouble *new_matrix;
{
   IGRint	i;

   if (*new_matrix_type != -1)
   {
   	for (i=0; i<16; ++i)
   	{
   	    env_matrix[i] = new_matrix[i];
   	}
   }
   env_type = *new_matrix_type;	 

   return(1);
}

end implementation GRgraphics;
