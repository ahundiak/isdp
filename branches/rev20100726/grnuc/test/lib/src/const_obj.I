class implementation GRvg;

#include <stdio.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"

construct_object(msg, geom, classname, md_env, obj_id)
  IGRlong  *msg;                     /* output */
  IGRchar  *geom;                    /* input */
  IGRchar  *classname;               /* input */
  struct GRmd_env  *md_env;          /* output */
  GRobjid   *obj_id;                 /* output */
{
  IGRlong     status;
  struct GRvg_construct const_list;
  struct IGRdisplay  display_attr;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;

  gr$get_module_env(buffer = md_env);

  display_attr.color = 1;
  display_attr.weight = 0;
  display_attr.style = 0;

  const_list.level = 1;
  const_list.properties = GRIS_NEW;
  const_list.name = 0;
  const_list.display = &display_attr;
  const_list.class_attr = 0;
  const_list.newflag = FALSE;
  const_list.msg = msg;
  const_list.env_info = md_env;
  const_list.geometry = geom;

  status = om$construct(osnum = md_env->md_id.osnum,
                        classname = classname,
                        p_objid = obj_id,
                        msg = message GRgraphics.GRconstruct(&const_list),
                        neighbor = OM_GS_NULL_NEIGHBOR);
  if (!(1&status))
  {
    printf("\n om$construct failed \n");
  }

  return(status);

}

end implementation GRvg;
