/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "gocmacros.h"
#include "msdef.h"
#define BUFF_SIZE 40

method GRstretch(IGRlong *EMmsg; struct GRmd_env *md_env;
	IGRshort *prism_type; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid)
{
 IGRlong status,msg1;
 IGRchar *absgptr;
 IGRshort mx_type;
 IGRint i;
 IGRint b_indices[BUFF_SIZE],*m_indices = NULL,*b_ptr = NULL;
 IGRint num_poles;
 struct IGRbsp_surface *surf;
 IGRpoint from_point, to_point;
 
 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 GRgetabsg(&msg1,&md_env->md_env.matrix_type,
    	md_env->md_env.matrix,&absgptr,i);
 EMerr_hndlr(!(1&msg1), *EMmsg, MSFAIL, wrapup);

 surf = (struct IGRbsp_surface *)absgptr;

 EFreturn_poles_within_fence( EMmsg,
                               surf,
                               NULL,NULL,
                               NULL,
                               NULL,
                               *prism_type, prism,
                               &num_poles,BUFF_SIZE,
                               b_indices,
                               NULL,&m_indices,NULL);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, MSFAIL, wrapup);

 if (num_poles != 0)
 {

  if (num_poles > BUFF_SIZE)
   b_ptr = m_indices;
  else
   b_ptr = b_indices;

  from_point[0] = from_point[1] = from_point[2] = 0.0;

  for (i=0;i<3;i++)
   to_point[i] = xform_matrix[4*i+3];

  status = om$send (msg = message EMSsubbs.EMmove_poles(EMmsg,md_env,
                          NULL,num_poles,b_ptr,from_point,to_point,NULL,
                          objid),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL,wrapup);

  GR_NOTIFY_LISTENERS(EMmsg,&status,GR_GEOM_MODIFIED);
 }
 else
 {
    MAtypemx(EMmsg,xform_matrix,&mx_type);

    status = om$send (msg = message GRgraphics.GRxform(EMmsg,md_env,&mx_type,
                            xform_matrix,objid),
             targetid = my_id);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL,wrapup);
 }
 

wrapup:

 if (m_indices) om$dealloc(ptr = m_indices);
 return (status);
}
end implementation EMSsubbs;

