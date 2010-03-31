/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
/*
Abstract

History
    dhm   5/20/88   creation date.
*/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "OMDB.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "dpstruct.h"
#include "emsdef.h"
#include "emserr.h"

from GRvg import GRgeomprops;

extern OMuword  OPP_GR3dpoint_class_id;

IGRint EMnester_action_hndlr (args, new_entry, locate_args, action)

struct GRlc_info      *new_entry;
struct LC_action_args *locate_args;
enum   GRlocate_action *action;
IGRchar               *args;

{
  struct ret_obj_info
  {
    IGRint           array_size;
    IGRlong          *num_entries;
    struct GRlc_info    **lc_info;
  };

  IGRlong          msg_loc, status;
  IGRchar          errmsg[EMMAXERRMSG_LEN];
  struct GRprops   props;
  struct ret_obj_info    *entries;
  OMuword          new_entry_classid;

  /*
   * Initialize
   */

  status = OM_S_SUCCESS;
  strcpy(errmsg, "EMnester_action_hndlr error\n");
  entries = (struct ret_obj_info *) args;

  switch (*action)
  {
    /*
     * These 2 cases are sent when a reference space is
     * entered during an rtree scan.
     */

    case end_transition:
    case start_transition:
    {
      status = OM_S_SUCCESS;
      goto ret_end;
    }

    /*
     * This case is called when an object is to be posted as
     * already located.
     */

    case post_object:
    {
      lc$check_id(rc = &msg_loc, objid = new_entry->located_obj.objid,
                  osnum = new_entry->located_obj.osnum);
      status = OM_S_SUCCESS;
      goto ret_end;
    }

    /*
     * This case allows objects to check to see if it has already
     * been located -- helpful in solids and owners.
     */

    case check_object:
    {
      lc$check_id(rc = &msg_loc, objid = new_entry->located_obj.objid,
                  osnum = new_entry->located_obj.osnum, mode = LC_CHECK);
      if (msg_loc == LC_ID_FOUND)
         status = OM_S_SUCCESS;
      else
         status = LC_ID_NOT_FOUND;
      goto ret_end;
    }

    /*
     * This case is called if the located object overlaps curve boundary.
     */

    case add_overlap:
    {
      status = OM_S_SUCCESS;
      goto ret_end;
    }

    /*
     * This case is called if the located object is outside curve boundary.
     */

    case add_outside:
    {
      status = OM_S_SUCCESS;
      goto ret_end;
    }

  } /* end switch (action) */


 /*
  * Get the geom. properties of the located object.
  */

  status = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                         &new_entry->module_info.md_env.matrix_type,
                         new_entry->module_info.md_env.matrix, &props),
                   senderid = NULL_OBJID,
                   targetid = new_entry->located_obj.objid,
                   targetos = new_entry->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);

  if ( (props.phy_closed) || (props.closed) )
  {
    status = om$get_classid(osnum = new_entry->located_obj.osnum,
                            objid = new_entry->located_obj.objid,
                            p_classid = &new_entry_classid);
    EMomerr_hndlr(status, ret_end, errmsg);

    if (new_entry_classid == OPP_GR3dpoint_class_id)
      goto ret_end;

    if (entries->array_size == 0)
    {
      *(entries->lc_info) = (struct GRlc_info *) om$malloc(size = 10 *
                                         sizeof(struct GRlc_info) );
      EMerr_hndlr(!(*entries->lc_info), status, OM_E_ABORT, ret_end);

      entries->array_size = 10;
    }
    else if ( (*entries->num_entries) >= entries->array_size )
    {
      entries->array_size = entries->array_size + 1;
      *(entries->lc_info) = (struct GRlc_info *)
        om$realloc(ptr = (IGRchar *)*(entries->lc_info), 
			size = entries->array_size * sizeof(struct GRlc_info) );
      EMerr_hndlr(!(*entries->lc_info), status, OM_E_ABORT, ret_end);
    }

    (*(entries->lc_info))[*entries->num_entries] = *new_entry;
    (*entries->num_entries)++;

  }  /* end if object is closed */


 ret_end:
  return(status);

}

end implementation Root;
