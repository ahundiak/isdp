/*
** ci_listeneri.I
**
** Management of the automatic execution of a command file on notification by
** a graphic object.
**
** History
**	GARDELLA D.	03/15/88 :  creation.
*/

class implementation ci_listener;
   
#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "godef.h"
#include "ciexecmacros.h"

#include "ci.h"
#include "citypedef.h"
from ci		import set_value;
from GRnotify	import GRntfyconn;


method CLplace(	struct GRid	graphic;	/* object to be monitored */
		IGRchar		*fname;		/* CI file name */
		IGRint		*rc )		/* Return Code */
{
	IGRlong		sts, status;
	OM_S_CHANSELECT	chansel;
 	struct GRid	listener;
	IGRboolean	tag_connect ;
	IGRint		listener_index ;

/* Connect to the graphic object */
	listener.objid = my_id;
	listener.osnum = OM_Gw_current_OS;
	chansel.type = OM_e_name;
	chansel.u_sel.name = "ci_listener.to_graphic";
/* AF: 20 Oct 88, Modified for 1.2 */
	tag_connect = FALSE ;
	sts = om$send(msg = message GRnotify.GRntfyconn(&status,
							&listener,
							&chansel,
							&listener_index,
							&tag_connect,
							NULL ),
		targetid = graphic.objid,
		targetos = graphic.osnum );
	if ( !(sts & 1) )
	{
	    fprintf(stderr, "ci_listener.CLplace -> GRnotify.GRntfyconn\n");
	    om$report_error(sts = sts);
	    *rc = 0;
	    return OM_S_SUCCESS;
	}

/* Load the 'automatic' CI file */
	ME.ci_listener->ci_file.osnum = 1 ;
	if ( !ci$load(	file_name =	fname,
			file_id = 	&(ME.ci_listener->ci_file.objid) ) )
	{
	    fprintf(stderr, "ci_listener.CLplace: ci$load failed with %s\n", fname );
	    ME.ci_listener->ci_file.objid = NULL_OBJID;
	    *rc = 0;
	    return OM_S_SUCCESS;
	}

/* Set the value of the reserved variable GR_EXECUTOR */
	sts = om$send(msg = message
		       ci.set_value( NULL, "GR_EXECUTOR", (char *)&graphic, 0),
/*		targetos = ME.ci_listener->ci_file.osnum,	*/
		targetid = ME.ci_listener->ci_file.objid);
	if ( !(sts & 1) )
	{
	    fprintf(stderr,
	"ci_listener.CLplace -> ci.set_value failed with variable \"GR_EXECUTOR\"\n" );
	    *rc = 0;
	    return OM_S_SUCCESS;
	}

	*rc = 1;
	return OM_S_SUCCESS;
}


method GRnotifylis(IGRlong *msg, *OMmsg, *mask; OM_S_MESSAGE *graphics_msg)
{
	IGRlong		sts;
	char		notify_entry[32];
	char		del = 0;

/*
 * Depending on the notified action, determine the entry point in the CI file
 * or exit.
 * NOTE: For the moment the list of supported actions is limited to
 *		GR_GEOM_XFORMED,  GR_GEOM_MODIFIED, GR_DELETED
 * This list can obviously be extented on user request.
 */
	switch( *mask )
	{
	  case GR_GEOM_XFORMED :
	    strcpy(notify_entry, "gr_geom_xformed");
	    break;
	  case GR_GEOM_MODIFIED :
	    strcpy(notify_entry, "gr_geom_modified");
	    break;
	  case GR_DELETED :
	    strcpy(notify_entry, "gr_deleted");
	    del = 1;  
	    break;
	  default :
	    return OM_S_SUCCESS;
	}

/* Run the CI file previously loaded with the relevant entry point */
	ci$run(	file_id = &(ME.ci_listener->ci_file.objid),
		entry =	notify_entry );

/* For GR_DELETED, it is valuable to remove the link */
	if ( del )
	{
	    sts = om$send(msg = message Root.delete(0),
			   targetid = my_id );
	    if ( (sts & 1) != 1 )
	    {
	        fprintf(stderr, "ci_listener.delete -> Root.delete to itself\n");
	        om$report_error(sts = sts);
	        return(OM_W_ABORT);
	    }
	}
	return OM_S_SUCCESS;
}


method delete(int n)
{
	IGRlong		sts;

/* delete the CI object */
	if( !IF_EQ_OBJID(ME.ci_listener->ci_file.objid, NULL_OBJID) )
	{
		sts = om$send(msg = message Root.delete(0),
/*			   targetos = ME.ci_listener->ci_file.osnum, */
			   targetid = ME.ci_listener->ci_file.objid );
		if ( (sts & 1) != 1 )
		{
		    fprintf(stderr, "ci_listener.delete -> Root.delete to CI object\n");
		    om$report_error(sts = sts);
		}
	}

/* Hara Kiri */
	sts = om$send(mode = OM_e_wrt_message,
			msg = message Root.delete(n),
			targetid = my_id );
	if ( (sts & 1) != 1 )
	{
	    fprintf(stderr, "ci_listener.delete -> Root.delete to itself\n");
	    om$report_error(sts = sts);
	    return(OM_W_ABORT);
	}
	return 1;
}


end implementation ci_listener;
