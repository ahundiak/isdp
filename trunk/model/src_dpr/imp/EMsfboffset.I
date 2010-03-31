class implementation EMSsfboolean;

/* 
History:

  ???	:???		: Creation
  ashok :19-Jan-93 	: Forced to do composite surface offset.

*/

#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h"

#define FIRST  0
#define SECOND 1

method EMoffset (IGRlong *msg; IGRushort options;
                 IGRshort *mattyp; IGRmatrix mat;
                 struct GRvg_construct *const_args;
                 IGRboolean offset_inward;
                 IGRdouble thickness;
                 IGRint num_spec_thick;
                 IGRdouble *val_spec_thick;
                 struct GRobjid_set *spec_thick_sf_sets;
                 IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
                 IGRchar status_str[];
                 GRobjid *offsetobj;
                 struct EMSerror_help *errkey_list)
{
  IGRushort loc_opts, boolopts;
  OMuint i, offset_count, count;
  IGRlong bsrc, msg_loc, stat_OM;
  IGRdouble curr_cht;
  GRobjid *comp_offsetobjs;
  GRclassid myclass;
  OM_S_CHANSELECT chan_to_comps;
  OM_S_OBJECT_LINKAGE *compobj_list;
  enum EMSbooltype booltype;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  *offsetobj = NULL_OBJID;

#ifdef USE_SMART_OFFSET

  /*
   * Obtain the offset objects of each of the operands. Some offsets
   * may be degenerate; skip these. If all operands get skipped thusly,
   * return a code indicating degeneracy. In the case of a difference op,
   * if the positive solid is degenerate then the whole result is also
   * degenerate.
   */ 

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
   count = &count);
  EMerr_hndlr (count < 2, *msg, EMS_E_InvalidCase, ret_end);

  compobj_list = (OM_p_OBJECT_LINKAGE) alloca (count *
                  sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!compobj_list, *msg, EMS_E_NoStackMemory, ret_end);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
   count = &count, size = count, list = compobj_list);
  EMerr_hndlr (count < 2, *msg, EMS_E_InvalidCase, ret_end);

  comp_offsetobjs = (GRobjid *) alloca (count * sizeof (GRobjid));
  EMerr_hndlr (!comp_offsetobjs, *msg, EMS_E_NoStackMemory, ret_end);

  booltype = (enum EMSbooltype) ME.EMSsfboolean->operation;
  offset_count = 0;
  for (i=0; i<count; i++)
    {
    loc_opts = options | 
               (booltype == EMSbool_difference && i > FIRST ? 
                EMS_opt_offsetS_negative : NULL);
    stat_OM = om$send (msg = message EMSsurface.EMoffset (&msg_loc, loc_opts,
               mattyp, mat, const_args, offset_inward, thickness,
               num_spec_thick, val_spec_thick, spec_thick_sf_sets,
               num_nooffsetsfs, nooffsetsfs, status_str,
               &comp_offsetobjs[offset_count], errkey_list),
               targetid = compobj_list[i].S_objid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    if (msg_loc != EMS_I_Degenerate)
      offset_count++;
    else if (booltype == EMSbool_difference && i == FIRST)
      break;
    }
  EMerr_hndlr (!offset_count, *msg, EMS_I_Degenerate, ret_end);
  /*
   * Create a new Boolean object if the number of successful offset objects
   * created is greater than one. The new Boolean is defined over the
   * offset pieces.
   */

  if (offset_count > 1)
    {
    BSEXTRACTPAR (&bsrc, BSTOLCHRDHT, curr_cht);
    BSchangepar (&bsrc, BSTOLCHRDHT, ME.EMSsfboolean->cht);
    boolopts = ((options & EMS_opt_offsetS_display) ? 
                EMSsfbool_opt_display : NULL) |
               ((options & EMS_opt_offsetS_handlestop) ? 
                EMSsfbool_opt_HandleStop : NULL);
    om$get_classid (object = me, p_classid = &myclass);
    stat_OM = om$construct (classid = myclass,
               msg = message EMSsfboolean.EMboolean (&msg_loc, mattyp, mat,
               comp_offsetobjs[FIRST],
               offset_count-1, &comp_offsetobjs[SECOND],
               const_args, booltype, boolopts, NULL,
               NULL, NULL, NULL, NULL), p_objid = offsetobj);
    BSchangepar (&bsrc, BSTOLCHRDHT, curr_cht);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    *offsetobj = comp_offsetobjs[FIRST];

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSsfboolean.EMoffset");
  return (stat_OM);

#endif

  return (om$send (msg = message EMScompsurf.EMoffset (msg, options,
           mattyp, mat, const_args, offset_inward, thickness,
	   num_spec_thick, val_spec_thick, spec_thick_sf_sets,
           num_nooffsetsfs, nooffsetsfs, status_str, offsetobj,
	   errkey_list),
           mode = OM_e_wrt_message, targetid = my_id));

}

end implementation EMSsfboolean;
