class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "grerr.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "bsdistptpt.h"

method EMmakecomp( IGRlong		*msg;
		   struct GRmd_env	*myModuleInfo;
		   IGRlong		 num_ent;
		   struct GRlc_info	*entries;
		   IGRlong		*rotten_one)
/*
Abstract
	This method makes composite out of objects being sent or connects
	them to an existing composite.

Notes
	This method composites all the elements sent in. There are
	two possibilities:  1. ME could be just be a composite curve
	shell. In that case only the incoming objects form the components
	of ME composite curve object.
			    2. ME could be a composite curve with some
	components. In this case, the incoming objects are appended to
	MY last component or MY first component.

   	Components can be added to either front or the end
	of the composite curve.

	It is assumed that only curve elements are being sent in.
	If either of the end points of an element is not close enough to
	the previous component, then the index of that element is sent
	back in	*rotten_one. Otherwise *rotten_one is set to -1.

	The parametrization of an element is reversed if its
	stop point is close to the the stop point of the previous element.
  	(normal case is start point of the incoming element is close
	to the stop point of the previous element).

History
	gk	01/16/87	creation date
	rlw	05/08/87	changed channel name
    DLB 10/28/87    mod channel for version 1.1.0
    dhm 01/22/88    modified to handle the case where the first entry
                    is a composite curve.
    dhm 07/22/88    modified to close curve off if needed and to keep the
                    first one first.
    dhm 08/22/88    fixed addressing problem when calling EMclose_composite
                    and EMmaintain_first_component.
    Sudha   06/21/93        modified for BSprototype ansification
*/

#define IS	==
#define OR	||

{
  IGRchar 		errmsg[EMMAXERRMSG_LEN];
  IGRuint		count;
  IGRlong 		comp_so_far, loc_msg, istart, j, status=OM_S_SUCCESS;
  IGRlong       	stupid_index;
  IGRpoint		comp_start[3], comp_stop[3];
  IGRdouble		dist_tol;
  OM_S_CHANSELECT	to_components;
  OMuword           	entries_class_id;
  struct GRid       	my_GRid, first_obj;

  *msg = MSSUCC;
  strcpy (errmsg, "GRcompcurve.EMmakecomp");
  *rotten_one = -1;
  stupid_index = 0;  
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

/* Set up the channel select */

  status = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMomerr_hndlr(status, wrapup, errmsg);

/* How many components do I have so far? */

  status = om$get_channel_count(p_chanselect = &to_components,
			        objid = my_id,
				count = &count);
  EMomerr_hndlr(status, wrapup, errmsg);
  comp_so_far = count;

  status = BSEXTRACTPAR( &loc_msg, BSTOLLENVEC, dist_tol );


/* 
    If I have no components
  	check to see if the first object is an open one
	if so  make first entry the first component
    Else
	get my end points
*/

  if( comp_so_far IS 0 )
  {
     status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
		   	    &entries[0].module_info.md_env.matrix_type,
		    	    entries[0].module_info.md_env.matrix,
			    comp_start[0], comp_stop[0]),
		      targetid = entries[0].located_obj.objid, 
		      targetos = entries[0].located_obj.osnum);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

     if( BSdistptpt(&loc_msg, comp_start[0], comp_stop[0]) < dist_tol )
     {
        *msg = GRILLDEFINITION;
        *rotten_one = 0;
        return(status);
     }

     /*
      * If the first entry is a composite curve, then
      * need to move its channel to the composite shell.
      * and delete the entry composite curve. dhm 1/22/88
      * Also, get the first object in order to maintain the
      * first object.   dhm 7/22/88
      */

     status = om$get_classid(osnum = entries[0].located_obj.osnum,
                             objid = entries[0].located_obj.objid,
                             p_classid = &entries_class_id);
     EMomerr_hndlr(status, wrapup, errmsg);

     if (entries_class_id == OPP_GRcompcurve_class_id)
     {
        status = om$send(msg = message Root.move_chan(to_components,
                               entries[0].located_obj.objid,
                               entries[0].located_obj.osnum,
                               to_components),
                         targetid = my_id);
        EMomerr_hndlr(status, wrapup, errmsg);

        status = om$send(msg = message Root.delete(1),
                         targetid = entries[0].located_obj.objid,
                         targetos = entries[0].located_obj.osnum);
        EMomerr_hndlr(status, wrapup, errmsg);

        status = om$get_objid_at_index(objid = my_id,
                                       p_chanselect = &to_components,
                                       index = 0,
                                       objidaddr = &first_obj.objid,
                                       osnumaddr = &first_obj.osnum);
        EMomerr_hndlr(status, wrapup, "om$get_objid_at_index\n");

     }  /* end if entries_class_id = GRcompcurve_class_id */
     else
     {
        first_obj.objid = entries[0].located_obj.objid;
        first_obj.osnum = entries[0].located_obj.osnum;

        status = om$send(msg = message GRconnector.GRrigidconn(&loc_msg,
                               &my_GRid, &stupid_index),
                         targetid = entries[0].located_obj.objid,
                         targetos = entries[0].located_obj.osnum);
        EMomerr_hndlr(status, wrapup, errmsg);
        EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);
     }

     istart = 1;
  }
  else
  {
     status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
				    &myModuleInfo->md_env.matrix_type,
		    		     myModuleInfo->md_env.matrix,
				     comp_start[0], comp_stop[0]),
		      targetid = my_id);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

     if( BSdistptpt(&loc_msg, comp_start[0], comp_stop[0]) < dist_tol )
     {
        *msg = GRILLDEFINITION;
        return(status);
     }
     istart = 0;
  }


/*
   Status: we have a composite
	   we have its start and stop points
	   istart is the index of the incoming object to start at
*/

  for(j = istart; j < num_ent; j++)
  {
     struct GRid	add_obj;
     IGRboolean		inter_allowed;

     add_obj.objid = entries[j].located_obj.objid;
     add_obj.osnum = entries[j].located_obj.osnum;
     inter_allowed = FALSE;

     status = om$send(msg = message GRcompcurve.EMaddtocomp(&loc_msg, 
			    add_obj, &entries[j].module_info, 
			    myModuleInfo, inter_allowed, dist_tol, dist_tol,
			    TRUE, comp_start[0], comp_stop[0], &comp_so_far), 
		      targetid = my_id);
     EMomerr_hndlr(status, wrapup, errmsg);

     if (loc_msg != MSSUCC)
     {
        *rotten_one = j;
        *msg = loc_msg;
        return(status);
     }

  }	/* for */

  /*
   * If we have more than one entry, then we need to see if it
   * needs to be closed off.  Then we need to check the first object
   * to be sure it is still the first one.  If it isn't, then we need to
   * make it the first one.    dhm 7/22/88
   */

   if (num_ent > 1)
   {
     status = EMclose_composite(&loc_msg, myModuleInfo, my_GRid, dist_tol,
                                dist_tol);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

     status = EMmaintain_first_component(&loc_msg, myModuleInfo, my_GRid,
                                         first_obj);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);
   }


wrapup:
  return(status);
}
end implementation GRcompcurve;
