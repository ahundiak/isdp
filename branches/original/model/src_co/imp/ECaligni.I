/* ###################   APOGEE COMPILED   ################## */
class implementation ECalign;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
/*
 Description

 This method performs the element modification stuff
 for the align commands.

 History

 01/05/88 : rlw : Creation date
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 */

#include "ems_m_inc.h"			/* Includes everything */
#include "EC_I.h"			/* Informational messages */
#include "EMSdpb.h"			/* DPB include file */
#include "EMSutlmacros.h"

from GRgraphics import GRdisplay;
from GRsubbc import EMalign_curve;
#ifndef IDRAW
from EMSgenbs import EMalign_surface;
#endif

method perform_duty()
{
 enum		GRdpmode DisplayMode;
 IGRboolean	clear_status_field, is_a_curve;
 IGRlong	sts, *my_msg, mode;
 struct		GRmd_env *md_env;
 struct		GRmdenv_info *mdenv_info;
 struct		GRlc_info *loc_info;
 struct		GRid *id;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 is_a_curve = (me->mytype == 87);
 clear_status_field = FALSE;
 me->have_a_constructed_object = FALSE;
 mode = me->events[0].event.value;
/*
 * We must send the message to the object
 * which is changing (or at least freeform).
 */
 if (mode == 1)
  {
   struct	GRevent t1, t2;

   mode = 0;
   t1 = me->events[1];
   t2 = me->events[2];
   me->events[1] = me->events[3];
   me->events[2] = me->events[4];
   me->events[3] = t1;
   me->events[4] = t2;
  }
/*
 * Erase the objects
 */
 DisplayMode = GRbe;
 if (mode != 1)
  {
   loc_info = &me->events[1].located_object[0];
   id = &loc_info->located_obj;
   md_env = &loc_info->module_info;
   mdenv_info = &md_env->md_env;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts))
     {
      *my_msg = MSFAIL;
      goto wrapup;
     }
/***************************************************************
   sts = EMpromote_class(
     is_a_curve,
     md_env,
     id,
     my_msg);
***************************************************************/
    sts = ems$promote_class(
                is_a_curve = is_a_curve,
                    mdenv = md_env,
                    object = id,
                       msg = my_msg);
    if (! (1 & sts)) goto wrapup;
  }
 if (mode != 0)
  {
   loc_info = &me->events[3].located_object[0];
   id = &loc_info->located_obj;
   md_env = &loc_info->module_info;
   mdenv_info = &md_env->md_env;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts))
     {
      *my_msg = MSFAIL;
      goto wrapup;
     }
/***************************************************************
   sts = EMpromote_class(
     is_a_curve,
     md_env,
     id,
     my_msg);
***************************************************************/
   sts = ems$promote_class(
                is_a_curve = is_a_curve,
                    mdenv = md_env,
                    object = id,
                       msg = my_msg);
    if (! (1 & sts)) goto wrapup;
  }
/*
 * Modify the object
 */
 loc_info = &me->events[1].located_object[0];
 id = &loc_info->located_obj;
 if (is_a_curve)
  {
   sts = om$send(
     msg = message GRsubbc.EMalign_curve(
      loc_info,
      &me->events[2].event.button.x,
      &me->events[3].located_object[0],
      &me->events[4].event.button.x,
      mode,
      my_msg),
     targetid = id->objid,
     targetos = id->osnum);
  }
 else
  {
#ifndef IDRAW
   sts = om$send(
     msg = message EMSgenbs.EMalign_surface(
      loc_info,
      me->events[2].located_object[0].geom_parms.polygon_inx,
      &me->events[3].located_object[0],
      me->events[4].located_object[0].geom_parms.polygon_inx,
      mode,
      my_msg),
     targetid = id->objid,
     targetos = id->osnum);
#endif
  }
/*
 * If an error occured then inform the user
 * that the modification failed
 */
  ON_ERROR
   ex$message(msgnumb = EMS_I_00029)	/* Modification failed */
/*
 * Display the modified object
 */
  else
   {
    ex$message(				/* Processing . */
     msgnumb = EMS_I_00004,
     type = "%s",
     var = " . ")
    clear_status_field = TRUE;
   }
/*
 * Draw the objects
 */
 DisplayMode = GRbd;
 if (mode != 1)
  {
   loc_info = &me->events[1].located_object[0];
   id = &loc_info->located_obj;
   mdenv_info = &loc_info->module_info.md_env;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts))
     {
      *my_msg = MSFAIL;
      goto wrapup;
     }
  }
 if (mode != 0)
  {
   loc_info = &me->events[3].located_object[0];
   id = &loc_info->located_obj;
   mdenv_info = &loc_info->module_info.md_env;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts))
     {
      *my_msg = MSFAIL;
      goto wrapup;
     }
  }
/*
 * Clear the status field
 */
if (clear_status_field)
 ex$message(msgnumb = EMS_I_00000)	/* Clear field */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation ECalign;
