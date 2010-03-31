/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
  DESCRIPTION

    This function takes in various pieces defining a construction environment
    and returns an environment with all defaults "fleshed" out in the form of
    the GRvg_construct structure. This is understood by most GR-objects. The
    function that does this is EMgetvgcnstr.

    Since some of the fields in the GRvg_construct structure are pointers
    which cannot take on a NULL value, these need to point to valid memory
    locations. These memory locations (most probably automatic variables
    declared in the calling function) are used to initialize these pointers
    by calling the function EMinitvgcnstr.

  HISTORY

    SS  :  03/10/91  :  Creation
*/

#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSasopts.h"

void EMinitvgcnstr (msg, mdenv, disp, obj_name, vgcnstr)
IGRlong *msg;
struct GRmd_env *mdenv;
struct IGRdisplay *disp;
IGRchar *obj_name;
struct GRvg_construct *vgcnstr;
{
  vgcnstr->msg = msg;
  vgcnstr->env_info = mdenv;
  vgcnstr->newflag = FALSE;
  vgcnstr->level = DEFAULT_GR_LEVEL;
  vgcnstr->properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  vgcnstr->geometry = NULL;
  vgcnstr->display = disp;
  vgcnstr->class_attr = NULL;
  vgcnstr->name = obj_name;

  return;
}


IGRboolean EMgetvgcnstr (opts, objtype, mdenv, level, disp, dispattr, objname,
                          vgcnstr)
IGRushort opts;
IGRchar objtype;
struct GRmd_env *mdenv;
IGRshort level;
struct IGRdisplay *disp;
IGRchar *dispattr, *objname;
struct GRvg_construct *vgcnstr;
{
  IGRboolean stat_func;
  IGRshort active_level;
  IGRint bytes_in, bytes_out;
  IGRlong msg_loc;
  struct GRmd_env active_md_env;
  struct IGRdisplay active_display;

  stat_func = TRUE;

  /*
   * Initialize the module info
   */

  if (!mdenv)
    {
    bytes_in = sizeof (struct GRmd_env);
    gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
     buffer = vgcnstr->env_info, nret = &bytes_out);
    EMerr_hndlr (EMSerror (msg_loc), stat_func, FALSE, ret_end);
    }
  else
    OM_BLOCK_MOVE (mdenv, vgcnstr->env_info, sizeof (struct GRmd_env));

  /*
   * Initialize the level field
   */

  if (level > HIGHEST_GR_LEVEL)
    {
    bytes_in = sizeof (IGRshort);
    gr$get_active_level (msg = &msg_loc, sizbuf = &bytes_in,
     buffer = &vgcnstr->level, nret = &bytes_out);
    EMerr_hndlr (EMSerror (msg_loc), stat_func, FALSE, ret_end);
    }
  else
    vgcnstr->level = level;

  /*
   * Initialize the display field
   */

  if (!disp)
    {
    bytes_in = sizeof (struct IGRdisplay);
    gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
     buffer = vgcnstr->display, nret = &bytes_out);
    EMerr_hndlr (EMSerror (msg_loc), stat_func, FALSE, ret_end);
    }
  else
    OM_BLOCK_MOVE (disp, vgcnstr->display, sizeof (struct IGRdisplay));

  /*
   * Initialize the display attributes
   */

  vgcnstr->class_attr = dispattr;

  /*
   * Initialize the name field
   */

  if (!objname && opts & EMSasconst_generatename)
    {
    stat_func = EMdefnewname (vgcnstr->name, vgcnstr->env_info->md_id.osnum,
                 objtype);
    EMerr_hndlr (!stat_func, stat_func, FALSE, ret_end);
    }
  else if (!objname)
    vgcnstr->name = NULL;
  else
    strcpy (vgcnstr->name, objname);

ret_end:
  return (stat_func);
}
