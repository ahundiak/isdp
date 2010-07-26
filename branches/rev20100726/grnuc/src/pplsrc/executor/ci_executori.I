/*
** ci_executori.I
**
** Management of the automatic execution of a command file on notification by
** a graphic object.
**
** History
**	GARDELLA D.	03/15/88 :  creation.
**	E BEEKER	03/25/88: modification to deal with the event queue
*/

class implementation ci_executor;

#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "godef.h"
#include "codef.h"
#include "exdef.h"
#include "exmacros.h"

from GRnotify	import GRntfyconn;

method CI_ex_load(struct GRid	GR_exec,	/* IN. Object to be monitored */
				user_data;
		IGRchar		*ci_fname;	/* CI file name */
		IGRint		*rc )		/* Return Code */
/*
 * loads the file name into the instance data of the object
 * connects the ci_executor to the specified object
 */
{
	IGRlong		sts, status;
	OM_S_CHANSELECT	chansel;
 	struct GRid	myself;
	IGRboolean	tag_connect ;
	IGRint		listener_index ;
#ifdef DEBUG
printf("entering method CI_ex_load\n");
printf("ci_fname:%s\n", ci_fname);
printf("GR_exec:%d %d\n", (int)GR_exec.objid, GR_exec.osnum );
#endif
	/* Connect to the graphic object */
	myself.objid = my_id;
	myself.osnum = OM_Gw_current_OS;
	chansel.type = OM_e_name;
	chansel.u_sel.name = "ci_executor.to_graphic";
/* AF: 20 Oct 88, Modified for 1.2 */
	tag_connect = FALSE ;
	sts = om$send(msg = message GRnotify.GRntfyconn
					(	&status,
						&myself,
						&chansel,
						&listener_index,
						&tag_connect,
						NULL ),
		targetid = GR_exec.objid,
		targetos = GR_exec.osnum );
	if ( !(sts & 1) )
	{
	    fprintf(stderr, "ci_executor.CI_ex_load -> GRnotify.GRntfyconn\n");
	    om$report_error(sts = sts);
	    *rc = 0;
	    return OM_S_SUCCESS;
	}

	/* Load the name of the file */
	strcpy( ME.ci_executor->ci_file_name, ci_fname );

	/* Load the GRid of the user_data object */
	ME.ci_executor->user_data = user_data;
#ifdef DEBUG
printf("exiting method CI_ex_load\n");
#endif
	*rc = 1;
	return OM_S_SUCCESS;
}


method GRnotifylis(IGRlong *msg, *OMmsg, *mask; OM_S_MESSAGE *graphics_msg)
{
	OM_S_CHANSELECT		chansel;	/* channel selector */
	OM_S_OBJECT_LINKAGE	list[1];	/* list of connected objects */
	unsigned int		nb;		/* # of connected objects */
	int			rc;		/* return code */
	char			stmp[MAX_LENGTH_FOR_CI_NAME];
	char			fentry[32];

	/*
	 * Depending on the notified action, determine the entry point in the CI file
	 * or exit.
	 * NOTE: For the moment the list of supported actions is limited to
	 *		GR_GEOM_XFORMED,  GR_GEOM_MODIFIED, GR_DELETED
	 * This list can obviously be extented on user request.
	 */
	switch( *mask ){
	  case GR_GEOM_XFORMED :
		strcpy(fentry, "gr_geom_xformed");
		break;
	  case GR_GEOM_MODIFIED :
		strcpy(fentry, "gr_geom_modified");
		break;
	  case GR_DELETED :
		strcpy(fentry, "gr_deleted");
		break;
	  default :
		/* no action */
		return 1;
	}

	/* get the id of the attached object */
	chansel.type       = OM_e_name;
	chansel.u_sel.name = "ci_executor.to_graphic";

	rc = om$get_channel_objects(
		objid = 	my_id,
		p_chanselect =	&chansel,
		list =		list,
		size = 		1,
		count =		&nb );

	if ( COERROR(rc) ){
		fprintf(stderr,"ci_executor.notify: pbs in om$get_channel_objects");
		om$report_error(sts = rc );
		return OM_W_ABORT;
	}
	if( nb != 1 ){
		/* pbs */
	}

	/* puts the command "ci" on the event queue */
	ci_executor_put_q("ci", CMD_STRING ) ;

	/* puts the name of the cifile on the event queue */
	ci_executor_put_q(ME.ci_executor->ci_file_name, STRING ) ;

	/* puts the name of the entry function  on the event queue */
	ci_executor_put_q(fentry, STRING ) ;

	/* puts the id and osnum  of the connected object on the event queue */
	/* puts the id and osnum of an object user_data
	   for further use on the e. q. */
	/* everything is put each 8 bytes */
	sprintf(stmp,"%d        ", (int)list[0].S_objid );
	sprintf(&stmp[8],"%d        ", (int)list[0].osnum );
	sprintf(&stmp[16],"%d        ", (int)ME.ci_executor->user_data.objid);
	sprintf(&stmp[24],"%d", (int)ME.ci_executor->user_data.osnum );
	ci_executor_put_q(stmp , STRING ) ;

#ifdef DEBUG
printf("---------- ci_executor.GRnotify --------------\n");
print_queue();
#endif
	return OM_S_SUCCESS;
}

ci_executor_put_q(s, resp)
char *s;
long resp;
/*
 * puts an event STRING or CMD_STRING on the event queue
 */
{
	int status;
	IGRlong size, msg;

	size = strlen(s) + 1;	
#ifdef DEBUG
printf("ci_executor_put_q: %s (%d) size:%d\n",s,resp,size );
fflush(stdout);
#endif
	status = ex$putque (
		msg =		&msg,
		pos =		BACK,
		response =	(int *)&resp,
		byte =		&size,
		buffer =	s );

	if (!status || COERROR(msg)){
		erreur("ci_executor_put_q()->ex$putque error");
		return 0;
	}
	return 1;
}

end implementation ci_executor;
