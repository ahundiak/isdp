/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   DYauxview_init

Description
   This function will display an auxiliary view in dynamics about a
   normal to the folding line.

Arguments
   *mod_env          struct GRmd_env   module environment
   matrix            IGRmatrix         matrix defining rotation
   origin            IGRpoint          origin for drawing view
   *normal           struct IGRline    normal to folding line
   *fold_line        struct IGRline    folding line
   *caller_id        struct GRid       Commands osnum and objid   
   chansel           OM_p_CHANSELECT   Commands chansel

History 
   Gray Winn      03/04/88    Creation Date
   SCW            07/08/92    ANSI conversion
\*/

class implementation Root;

#include "coimport.h"
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
#include "msdef.h"
#include "madef.h"
#include "growner.h"
#include "grgs.h"
#include "dpmacros.h"
#include "detaildef.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "igrdef.h"

extern IGRboolean DPdlist_in_fold_dynamics;

struct dyn_args
{
   IGRmatrix            matrix;
   IGRpoint             origin;
   IGRpoint             pts[2];
   struct IGRline       normal;
   struct GRid          obj_id;
   struct IGRdisplay    display;
   struct GRmdenv_info  env;
   struct DPele_header  ele;
   struct IGRpolyline   polyline;
};

IGRint DYauxview_init (mod_env, matrix, origin, normal, fold_line, 
                       caller_id, chansel)
struct GRmd_env   *mod_env;
IGRmatrix         matrix;
IGRpoint          origin;
struct IGRline    *normal;
struct IGRline    *fold_line;
struct GRid       *caller_id;
OM_p_CHANSELECT   chansel;
{
IGRlong           om_msg;
IGRlong           msg;
IGRint            i;          
IGRboolean        dyn_on;       /* is dynamics on?             */
IGRboolean        inquire = 1;  /* inquire from DPdynflags     */
IGRdouble         t1, t2;
IGRpoint          diag1;
IGRpoint          diag2;
struct GRobj_env  obj_info;     /* object being cloned         */
struct dyn_args   data;         /* arguments                   */
struct IGRline    line1;

IGRint   DYauxview();

   /*
    *  if dynamics is off then exit
    */

   DPdynflags (&msg, &inquire, &dyn_on, NULL);
   if (!dyn_on)
   {
      return (MSSUCC);
   }

   /*
    *  if the channel contains a graphics set then exit, otherwise
    *  use the object information returned for the clone
    */

   om_msg = GRgsget_simple_object (&msg, caller_id, chansel, &obj_info);

   if (!(om_msg & msg & 1))
   {
      return (MSSUCC);
   }

   for (i=0; i < 3; ++i) data.origin[i] = origin[i];
   for (i=0; i < 16; ++i) data.matrix[i] = matrix[i];
   data.normal.point1 = normal->point1;
   data.normal.point2 = normal->point2;
   data.obj_id.osnum = mod_env->md_id.osnum;
   data.obj_id.objid = obj_info.obj_id.objid;
   data.display.color = 2;
   data.display.weight = 0;
   data.display.style = 1;

   /*
    *  Build folding line element.
    */

   data.polyline.num_points = 2;
   data.polyline.points = (IGRdouble *)data.pts;
   line1.point1 = data.pts[0];
   line1.point2 = data.pts[1];
   diag1[0] = diag1[1] = diag1[2] = GRDGNLIMITS_MIN_D;
   diag2[0] = diag2[1] = diag2[2] = GRDGNLIMITS_MAX_D;
   MAtlncbclip (&msg, fold_line, diag1, diag2, &t1, &t2, &line1);

   dp$build_dis_buffer( buffer = &data.ele, type = IGRPY,
      display_att = &data.display, geometry = &data.polyline);

   DPdlist_in_fold_dynamics = TRUE;
   dp$dynamics (dyn_fun = DYauxview, information = &data);
   DPdlist_in_fold_dynamics = FALSE;

   return (MSSUCC);
}


#argsused
IGRint DYauxview (dptr, point, mtx, objects, num_objects, buffers,
                  num_buffers, in_dummy1, in_dummy2, in_dummy3, out_dummy1,
                  out_dummy2, out_dummy3)
struct dyn_args       *dptr;
struct EX_button      *point;
IGRdouble             *mtx;
struct GRid          **objects;
IGRint                *num_objects;
struct DPele_header  **buffers;
IGRint                *num_buffers;
IGRchar               *in_dummy1;
IGRchar               *in_dummy2;
IGRchar               *in_dummy3;
IGRchar              **out_dummy1;
struct GRmdenv_info  **out_dummy2;
IGRchar              **out_dummy3;
{
IGRshort             four = 4;
IGRlong              msg;
IGRpoint             tpoint;
IGRmatrix            tmatrix;

   tpoint[0] = point->x;
   tpoint[1] = point->y;
   tpoint[2] = point->z;

   GRauxview_build_rot_matrix (&msg, dptr->origin, &dptr->normal,
      tpoint, tmatrix);

   MAmulmx (&msg, &four, &four, &four, tmatrix, dptr->matrix,
      dptr->env.matrix);

   MAtypemx (&msg, dptr->env.matrix, &dptr->env.matrix_type);

   /*
    *  set up the buffer pointer
    */

   *num_buffers = 1;
   *buffers = &dptr->ele;
   *objects = &dptr->obj_id;
   *num_objects = 1;
   *out_dummy2 = &dptr->env;
   return (msg);
}

IGRint GRauxview_build_rot_matrix (msg, origin, normal, point, 
                                   result_matrix)
IGRlong           *msg;
IGRpoint          origin;
struct IGRline    *normal;
IGRpoint          point;
IGRmatrix         result_matrix;
{
IGRdouble      t;
IGRpoint       prj_point1;

   /*
    *  Project point onto perp.
    */

   MAptlnproj (msg, point, normal, prj_point1, &t);

   /*
    *  Generate translation.
    */

   MAidmx(msg, result_matrix);
   result_matrix[3] = prj_point1[0] - origin[0];
   result_matrix[7] = prj_point1[1] - origin[1];
   result_matrix[11] = prj_point1[2] - origin[2];
   return(1);
}

end implementation Root;
