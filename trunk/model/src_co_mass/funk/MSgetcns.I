/* ###################   APOGEE COMPILED   ################## */
class implementation super_cmd;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#define IGE_WORKS 1

#include "ems_m_inc.h"

MSfill_construct_list(msg, event, construct_list)
IGRlong *msg;
struct GRevent *event;
struct GRvg_construct *construct_list;
{
 IGRint		bytes_in, bytes_out;
 IGRlong        EMmsg;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Set up the construct list pointers
 */
 construct_list->newflag = FALSE;
 construct_list->geometry = NULL;
 construct_list->class_attr = NULL;
 construct_list->name = NULL;

 bytes_in = sizeof (struct IGRdisplay);
 gr$get_active_display (msg = &EMmsg, 
                         sizbuf = &bytes_in,
                         buffer = construct_list->display, 
                         nret = &bytes_out);
 if (!(1&EMmsg)) goto wrapup;

 bytes_in = sizeof(construct_list->level);
 gr$get_active_level(
   msg = &EMmsg,
   sizbuf = &bytes_in,
   buffer = &construct_list->level,
   nret = &bytes_out);
 if (!(1&EMmsg)) goto wrapup;

/*
 * Load the active properties.  We should load these
 * because someone may wish to drive command through the
 * CI and therefore may wish to place non-displayable
 * objects.
 */

#if IGE_WORKS
 bytes_in = sizeof(construct_list->properties);
 gr$get_active_prop(
   msg = &EMmsg,
   sizbuf = &bytes_in,
   buffer = &construct_list->properties,
   nret = &bytes_out);
 if (!(1&EMmsg)) goto wrapup;
#else
 construct_list->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
#endif

/*
 * Load the construction enviroment
 */

 bytes_in = sizeof(struct GRmd_env);

   if (event && (event->response == EX_DATA))
    {
     gr$get_construct_env(
       msg = &EMmsg,
       point = &event->event.button,
       sizbuf = &bytes_in,
       buffer = construct_list->env_info,
       nret = &bytes_out);
     if (!(1&EMmsg)) goto wrapup;
    }
  else
  {
   gr$get_module_env(
     msg = &EMmsg,
     sizbuf = &bytes_in,
     buffer = construct_list->env_info,
     nret = &bytes_out);
   if (!(1&EMmsg)) goto wrapup;
  }
/*
 * eof
 */
wrapup:
  if (!(1&EMmsg)) return (OM_E_ABORT);
 else
  return(OM_S_SUCCESS);
}
end implementation super_cmd;
