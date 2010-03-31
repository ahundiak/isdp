/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains basic methods required by construction
 commands.

 History

 07/24/88 : rlw : Creation date
 08/14/94 : scw : clarified sleep method

 */

class implementation ECbase;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"			/* Includes everything */
#include "EMSdpb.h"			/* To get construction parameters */

method load_construction_information(struct GRevent *event)
{
 IGRint		bytes_in, bytes_out;
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Set up the construct list pointers
 */
 me->construct_list.msg = &me->msg;
 me->construct_list.env_info = &me->construct_env;
 me->construct_list.newflag = FALSE;
 me->construct_list.geometry = NULL;
 me->construct_list.display = &me->display;
 me->construct_list.name = NULL;
/*
 * Set up the element specific data
 */
 {
  IGRuchar      buffer;
  extern	IGRlong EMdpb_get();
  IGRlong	sts, loc_msg;
  struct	IGResbs *surface_specific;

  surface_specific = &me->surface_element_specific;
  me->construct_list.class_attr = (IGRchar *) surface_specific;
  surface_specific->is_surfdis = TRUE;		/* Required */
  surface_specific->is_slowdis = FALSE;		/* Doesn't matter */
  surface_specific->type = NULL;		/* Doesn't matter */
  sts = EMdpb_get(
    &loc_msg,
    EMSdpb_props,
    &buffer);
   if (! (1 & sts))
    {
     me->msg = MSFAIL;
     return(OM_E_ABORT);
    }
  surface_specific->is_polydis = buffer & EMDPB_POLYGON_DISPLAY_ON;
  sts = EMdpb_get(
    &loc_msg,
    EMSdpb_u_rules,
    &buffer);
   if (! (1 & sts))
    {
     me->msg = MSFAIL;
     return(OM_E_ABORT);
    }
  surface_specific->u_rules = buffer;
  sts = EMdpb_get(
    &loc_msg,
    EMSdpb_v_rules,
    &buffer);
   if (! (1 & sts))
    {
     me->msg = MSFAIL;
     return(OM_E_ABORT);
    }
  surface_specific->v_rules = buffer;
 }
 me->construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
/*
 * Load the construction enviroment
 */
 bytes_in = sizeof(me->construct_env);
 if (event &&
     (event->response == EX_DATA))
  {
   gr$get_construct_env(
     msg = &me->msg,
     point = &event->event.button,
     sizbuf = &bytes_in,
     buffer = &me->construct_env,
     nret = &bytes_out);
    ERROR_ABORT
  }
 else
  {
   gr$get_module_env(
     msg = &me->msg,
     sizbuf = &bytes_in,
     buffer = &me->construct_env,
     nret = &bytes_out);
    ERROR_ABORT
  }
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
 IGRlong	sts;
/*
 * Clear out the vsd
 */
 clear_vsd;
/*
 * Death
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message Root.delete(f_defer_flag),
   targetid = my_id);
  return(sts);
}

method wakeup(int pos)
{
 IGRint		bytes_in, bytes_out;
/*
 * Get the active color, weight, style
 */
 bytes_in = sizeof(me->display);
 gr$get_active_display(
   msg = &me->msg, 
   sizbuf = &bytes_in,
   buffer = &me->display,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * Get the active level
 */
 bytes_in = sizeof(me->construct_list.level);
 gr$get_active_level(
   msg = &me->msg,
   sizbuf = &bytes_in,
   buffer = &me->construct_list.level,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * Get the enviroment in which displays
 * are to take place
 */
 bytes_in = sizeof(me->display_env);
 gr$get_display_env(
   msg = &me->msg,
   sizbuf = &bytes_in,
   buffer = &me->display_env,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
 IGRlong	sts;
 extern		IGRlong DPerase_hilite();
/*
 * Erase the hilite plane
 */
 sts = dp$erase_hilite(
  msg = &me->msg,
  osnum = me->display_env.md_id.osnum,
  objid = me->display_env.md_id.objid);
/*
 * eof
 */
 return(sts);
}

end implementation ECbase;
