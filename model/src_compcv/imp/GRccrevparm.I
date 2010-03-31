/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include <stdio.h>
#include "msdef.h"
#include "igrdef.h"
#include "madef.h"
#include "emserr.h"
#include "godef.h"
#include "gocmacros.h"
#include "emsdef.h"

method GRrevparm(IGRlong *msg;
		 struct GRmd_env *env)

/*Abstract
	This method sends a reverse parameterization message to all of its
	member components via its channel. Then 
	i.  ordering of the channels is reversed.
	ii. continuity conditions are swapped.

Return values for error code

	MSSUCC	if successful
	MSNOMEM	if memory allocation failed
	MSFAIL	otherwise

History
	gk	11/18/86	creation date
	rlw	05/08/87	fixed channel name, removed continuity stuff
    DLB 10/28/87    modified channel for version 1.1.0
    dhm 04/06/88    added GR_NOTIFY_LISTENERS
*/

{
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  IGRuint		numb_of_chan, count;
  IGRlong 		i, status = OM_S_SUCCESS;
  OM_S_CHANSELECT 	to_components, to_composite;
  OM_S_OBJECT_LINKAGE	*component_obj = NULL;

  *msg = MSSUCC;
  strcpy(errmsg, "GRcompcurve.GRrevparm");

/* Make channel selectors */

  to_components.type       = OM_e_addr;
  to_components.u_sel.addr = &ME.GRcmpowner->to_components;

  status = EMmake_chanselect(GRconnector_to_owners, &to_composite);
  EMomerr_hndlr(status, wrapup, errmsg);


/* Reverse individual components */

  status = om$send(msg = OPPmargs,
                   p_chanselect = &to_components,
                   from = 0,
                   to = GRDGNLIMITS_MAX_I);
  EMomerr_hndlr(status, wrapup, errmsg);
  if( *msg != MSSUCC ) goto wrapup;


/* NEED TO CHANGE THE ORDERING OF THE CHANNELS */

  status = om$get_channel_count(p_chanselect = &to_components,
			        objid = my_id,
				count = &numb_of_chan);
  EMomerr_hndlr(status, wrapup, errmsg);


/* Allocate adequate space */

  component_obj = (OM_S_OBJECT_LINKAGE *) om$malloc
   (size = numb_of_chan * sizeof(OM_S_OBJECT_LINKAGE) );
  if( !component_obj )
   {
     fprintf(stderr, "GRcompcurve.GRccrevparm memory allocation failure\n");
     *msg = MSNOMEM;
     return(OM_E_ABORT);
   }

/* Get object ids */

  status = om$get_channel_objects(p_chanselect = &to_components,
				  objid = my_id,
                                  list =  component_obj,
                                  size = numb_of_chan,
                                  count = &count);
  EMomerr_hndlr(status, wrapup, errmsg);


/* Disconnect all except the first object */

 { /*Start block for my_GRid*/
  IGRlong stupid_index;
  struct GRid my_GRid;


  stupid_index = 0;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;  

  for( i = 1; i < numb_of_chan; i++ )
   {
     status = om$send(msg = message GRconnector.GRdisconn(msg, &my_GRid),
                      targetid = component_obj[i].S_objid);
     EMomerr_hndlr(status, wrapup, errmsg);
   }

   /* Connect, in order, all the objects [1-numb_of_chan] to index=0 */

  for( i = 1; i < numb_of_chan; i++ )
   {
     status = om$send(msg = message GRconnector.GRrigidconn(msg, &my_GRid,
                            &stupid_index),
                      targetid = component_obj[i].S_objid);
     EMomerr_hndlr(status, wrapup, errmsg);
   }
 }  /*END block for my_GRid*/

wrapup:
  if( component_obj ) om$dealloc( ptr=component_obj );

  GR_NOTIFY_LISTENERS(msg, &status, GR_GEOM_MODIFIED);

  return(status);
}

end implementation GRcompcurve;
