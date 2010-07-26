/* #######################    APOGEE COMPILED   ######################## */
class implementation GRreffile;

#include "grimport.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "refpriv.h"
#include "referr.h"
#include "msdef.h"
#include "dperr.h"
#include "dpdef.h"

from GRcontext import GRdeletectx;


GRopenfile(msg,md_env,objid,named_view,logical,mod_osnum,mod_objid,osname,
	view_id,context)

IGRlong		*msg;			/* return code		
					GRVIEWNOTFOUND
					GRFILENOTFOUND
					OM_E_NO_OS_AVAIL
					MSSUCC				*/
struct GRmd_env	*md_env;		/* module environment		*/
GRobjid		*objid;			/* reference file objid		*/
IGRchar		*named_view;		/* named view			*/
IGRchar		*logical;		/* name for directory mount	*/
GRspacenum 	*mod_osnum;		/* reference file module space	*/
GRobjid		*mod_objid;		/* reference module id		*/
IGRchar		*osname;		/* object space name		*/
struct GRid	*view_id;
struct GRid	*context;
{
    IGRlong	OMmsg,			/* OM return code		*/
		msg1,
		flag;

    IGRint	count,			/* number of views found	*/
		i;

    IGRboolean  constr_flag;		/* flag indicating construct	*/
    struct  GRid mod_id;
    IGRchar views[100];

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    constr_flag = TRUE;		 	/* set flag			*/
					/* init the file		*/
    OMmsg = om$send
	(msg = message GRreffile.GRrfinit
		(msg,&constr_flag,logical,mod_osnum,mod_objid,context),
	senderid = *objid,
	targetid = *objid);
					
    if (1 & OMmsg & *msg)
    {	
	om$os_number_to_name(
		osnum = *mod_osnum,
		osname = osname);

    	/* verify that the saved view exists.
	 */

	view_id->objid = NULL_OBJID;

	if ( named_view )
	{
            count = 0;

	    mod_id.objid = *mod_objid;
	    mod_id.osnum = *mod_osnum;

	    strcpy(views,GRDP_SAVEDVIEWS);
	    strcat(views," ");
	    strcat(views,GRDP_REGVIEWS);

	    dp$get_gragad_id(
		    msg = &msg1,
		    mod_GRid = &mod_id,
		    name = named_view,
		    array_size = 1,
		    total_num = &i,
		    numberofids = &count,
		    found_GRids = view_id,
		    search_priority = views);

# ifdef DEBUG
	    printf("Saved view id check\n");
	    printf("OMmsg = %X\n",OMmsg);
	    printf("msg = %X\n",msg1);
	    printf("count= %d\n",count);
# endif
	    if (! count)
	    {
		/* close the object space, send flag= 3 to indicate
		 * the construct operation failed
		 */

	        flag = 3;

	    	om$send
		    	(msg = message GRreffile.GRrfclose
			    (msg,&flag),
		    	senderid = *objid,
		    	targetid = *objid);

		*msg = GRVIEWNOTFOUND;
		OMmsg = OM_E_ABORT;
	    }
   	}
	if ( ! (1 & OMmsg))
	{
	    om$send(msg = message GRcontext.GRdeletectx
		(&msg1,md_env),
		senderid = *objid,
		targetid = context->objid,
		targetos = context->osnum);

	}
    }

    return(OMmsg);
}
end implementation GRreffile;
