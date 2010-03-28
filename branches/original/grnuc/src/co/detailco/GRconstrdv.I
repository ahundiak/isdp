/*
Name
   GRconstruct_dv

Description
   This function is used to construct a drawing view object.  The drawing
   view object will consists of an optional coordinate system which is xy 
   aligned with the view and an optional reference file which is the model
   attachment.

Arguments
   *msg           long              completion code
   *mod_env       struct GRmd_env   module environment
   properties     unsigned short    properties of the drawing view
   *display       struct IGRdisplay    display info
   level          short             level
   name[]         char              name of the drawing view
   desc[]         char              description of the drawing view
   *orientation   int               the orientation of the drawing view
   *ref_info      struct GRrf_info     Information about the reference file
   classname[]    char              classname of the drawing view
   rot_matrix     IGRmatrix            window rotation
   origin         IGRpoint             origin of the drawing view
   *scale         char              scale string
   *dv_id         struct GRid          the drawing view object id
   *cs_id         struct GRid          the cordinate system object id

Notes 
   If the orientation argument is NULL, a reference file will be
   constructed and added to the drawing view.  If the orientation argument
   is not NULL, a reference file will not be constructed and the
   orientation of the drawing view will be defined as one of the 6
   principal sides of a cube.

   The ref_info variable may be NULL if an orientaion is defined.

   If the cs_id is NULL then a coordinate system will not be constructed.

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   	03/03/88    Creation date
   Henry Bequet	12/09/91    Hidden edges symbology support
*/

class implementation Root;

#include "coimport.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "grcoordsys.h"
#include "csdef.h"
#include "ref.h"
#include "refdef.h"
#include "detail.h"
#include "OMerrordef.h"
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

from GRgraphics import  GRconstruct;

extern OMuword EX_dup_os_occured;

int GRconstruct_dv ( msg, mod_env, properties, display, level, name, desc, orientation, 
                     ref_info, classname, rot_matrix, origin, scale, dv_id, cs_id )
long              *msg;
struct GRmd_env   *mod_env;
unsigned short    properties;
struct IGRdisplay *display;
short             level;
char              name[];
char              desc[];
int               *orientation;
struct GRrf_info  *ref_info;
char              classname[];
IGRmatrix         rot_matrix;
IGRpoint          origin;
char              *scale;
struct GRid       *dv_id;
struct GRid       *cs_id;
{
  long                         om_msg;
  int                          i;
  struct GRvg_construct        const_list;
  struct IGRlbsys              lb;
  struct GRdrawview_class_attr class_attr;
  struct GRhesym               hesym;
  struct IGRdisplay            display_tmp;

  *msg = MSSUCC;
  om_msg = OM_S_SUCCESS;

  /* KLUDGE: Set a global flag indicating that a dup os attachment
             has not occurred. This will be check after the construct.
             In the future construct should return OM_I_DUPLICATE_OS. */
  EX_dup_os_occured = 0;

  /* Build construct arguments. */
  const_list.msg = msg;
  const_list.newflag = FALSE;
  const_list.env_info = mod_env;
  const_list.properties = properties;
  const_list.geometry = (char *)&lb;
  const_list.level = level;
  const_list.class_attr = (char *)ref_info;
  const_list.name = NULL;

  /* the display depends on the visible edge symbology */
  gr$get_visible_edge_sym ( buffer = &hesym );
  if ((hesym.flags & DPB_USE_ORIG_COLOR) &&
      (hesym.flags & DPB_USE_ORIG_WEIGHT) &&
      (hesym.flags & DPB_USE_ORIG_STYLE))
    const_list.display = display;
  else
  {
    if (ref_info)
      *(ref_info->ref_properties) |= GROVERRIDE_SYMBOLOGY;
    display_tmp = *display;
    const_list.display = &display_tmp;
/* fix for TR119314109 */
    if (!(hesym.flags & DPB_USE_ORIG_COLOR))
      display_tmp.color = hesym.color;
#if COMMENT_OUT
    else
      display_tmp.color = (unsigned short) ~0;/* use original color*/
#endif

    if (!(hesym.flags & DPB_USE_ORIG_STYLE))
      display_tmp.style = hesym.style;
#if COMMENT_OUT
    else
      display_tmp.style = (IGRuchar) ~0;
#endif

    if (!(hesym.flags & DPB_USE_ORIG_WEIGHT))
      display_tmp.weight = hesym.weight;
#if COMMENT_OUT
    else
      display_tmp.weight = (IGRuchar) ~0;
#endif
  }

  /* Build matrix of the local bounded system. */
  lb.matrix[0]  =  rot_matrix[0];
  lb.matrix[1]  =  rot_matrix[4];
  lb.matrix[2]  =  rot_matrix[8];
  lb.matrix[3]  =  origin[0];
  lb.matrix[4]  =  rot_matrix[1];
  lb.matrix[5]  =  rot_matrix[5];
  lb.matrix[6]  =  rot_matrix[9];
  lb.matrix[7]  =  origin[1];
  lb.matrix[8]  =  rot_matrix[2];
  lb.matrix[9]  =  rot_matrix[6];
  lb.matrix[10] =  rot_matrix[10];
  lb.matrix[11] =  origin[2];
  lb.matrix[12] =  rot_matrix[12];
  lb.matrix[13] =  rot_matrix[13];
  lb.matrix[14] =  rot_matrix[14];
  lb.matrix[15] =  rot_matrix[15];

  /* The diagonal points have no meaning when a clip polygon is defined or a saved 
     view was defined or a clip polygon was specified. */
  lb.diag_pt1[0] = lb.diag_pt1[1] = lb.diag_pt1[2] = (double)GRDGNLIMITS_MIN_D + 1.0;
  lb.diag_pt2[0] = lb.diag_pt2[1] = lb.diag_pt2[2] = (double)GRDGNLIMITS_MAX_D - 1.0;

  if (!orientation)
  {
    /* If a clipping polygon is not defined, a save view is not given and a scale 
       was not specified then the polygon should be clipped to the design file limits. */
    if ((ref_info->named_view[0] == '\0') &&
        (ref_info->scale[0] == '\0') &&
        (!ref_info->clip_poly))
      /* Form a local bounded system that is the size of the design cube. */
      GRformlbsys ( msg, rot_matrix, origin, &lb );

    /* Construct the reference file object. */
    if (!(*ref_info->ref_properties & GRRF_IS_READ_ONLY))
      GRmake_writable (msg, ref_info->filename,NULL);

    class_attr.da_class_attr.ref_file.osnum = mod_env->md_id.osnum;
    om_msg = om$construct ( osnum = mod_env->md_id.osnum,
        classname = "GRreffile",
        msg = message GRgraphics.GRconstruct ( &const_list ),
        p_objid = &class_attr.da_class_attr.ref_file.objid );
  } 
  else
  {
    class_attr.da_class_attr.orientation = *orientation;
    class_attr.da_class_attr.ref_file.objid = NULL_OBJID;
  }

  for (i = 0; i < 3; i++)
  {
    lb.diag_pt1[i] = 0;
    lb.diag_pt2[i] = 0;
  }

  if (cs_id)
  {
    /* Construct the view aligned coordinate system. */
    om_msg = GRconstruct_cs (msg, mod_env, level, display, properties, 
        NULL, "GRdvcs", &lb, cs_id);
    class_attr.da_class_attr.coord_sys = *cs_id;
  } 
  else
    class_attr.da_class_attr.coord_sys.objid = NULL_OBJID;

  class_attr.da_class_attr.scale = scale;
  class_attr.da_class_attr.desc = desc;
  if (om_msg & *msg & 1)
  {
    /*
       *  Construct the drawing view.
       */

    class_attr.da_id.objid = NULL_OBJID;
    const_list.display = NULL;
    const_list.level = NULL;
    const_list.name = name;
    const_list.class_attr = (char *) &class_attr;
    dv_id->osnum = mod_env->md_id.osnum;
    om_msg = om$construct (osnum = mod_env->md_id.osnum,
        classname = classname, p_objid = &dv_id->objid,
        msg = message GRgraphics.GRconstruct(&const_list));
  }

  if ((om_msg & *msg & 1) && EX_dup_os_occured)
    *msg = OM_I_DUPLICATE_OS;

  return om_msg;
}

end implementation Root;
