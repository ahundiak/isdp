/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsolid;

#include "EMS.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSsfparms.h"
#include "emssfdef.h" /* For EMcylinder... */
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include <stdio.h>
#include "bssfarrevn.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpl.h"


extern OMuword OPP_EMSprjcompsf_class_id;
extern OMuword OPP_EMSproject_class_id;

%safe
static int pp_get_logical_normal();
static int pp_get_axis_points();
%endsafe

method EMorient_yourself (IGRlong *EMmsg;
                          IGRushort options;
                          struct GRmd_env *env)

/* ***********************************************************************

Description
   This method overrides the message defined at EMSsolid to implement
   orientation of solids of projection specially.

   Input
     env - module environment of the solid
     options - Currently, should be set to NULL

   Output
     EMmsg: Completions status

Notes
   Upon exit the completion code will be one of the following:
    EMS_S_Success : if successful
    EMS_E_Fail : if there is failure
    EMS_E_InvalidCase : if the solid normals could not be oriented 


History
  05/28/90    : pp :       Creation
  07/01/93    : Sudha      Modified for BSprototypes ansification

*************************************************************************** */

{
 IGRlong status;
 OM_S_CHANSELECT to_components;
 OMuword dominant_classid;
 IGRboolean surface_of_projection = FALSE;

 IGRint i;
 OMuint count;
 OM_S_OBJECT_LINKAGE linkage[3];
 struct GRid GRid;
 
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = EMmake_chanselect (GRcmpowner_to_components, &to_components);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$get_channel_objects(objid = my_id,
                                 p_chanselect = &to_components,
                                 list = linkage,
                                 size = 3,
                                 count = &count);
 if (status == OM_S_SUCCESS)
 {
  status = om$get_classid(objid = linkage[0].S_objid,
                          p_classid = &dominant_classid);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$is_ancestry_valid(subclassid = dominant_classid,
                               superclassid = OPP_EMSproject_class_id);
  if (status == OM_S_SUCCESS)
   surface_of_projection = TRUE;
  else if (status == OM_I_INVANCESTRY)
  {
    status = om$is_ancestry_valid(subclassid = dominant_classid,
                                  superclassid = OPP_EMSprjcompsf_class_id);
    if (status == OM_S_SUCCESS)
      surface_of_projection = TRUE;
    else surface_of_projection = FALSE;
  }
  else
  {
   *EMmsg = EMS_E_OMerror; 
   goto wrapup;
  }
 }
 else
  status = OM_S_SUCCESS;

 if (surface_of_projection)
 {
  IGRdouble params[2],pl_pt[3];
  IGRvector pl_nrml,axis;
  IGRdouble dist,disttol,dot_p;
  BSrc     rc;
  IGRpoint point1, point2;
 
  params[0] = 0.48;
  params[1] = 0.54;
 
  BSEXTRACTPAR(&rc,BSTOLLENVEC,disttol);

  GRid.objid = linkage[0].S_objid;
  GRid.osnum = linkage[0].osnum;

  pp_get_axis_points(EMmsg, &GRid, env,point1, point2); 
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = BSmkvec(&rc, axis, point1, point2);
  status = BSnorvec(&rc,axis);

  GRid.objid = linkage[1].S_objid;
  GRid.osnum = linkage[1].osnum;

  pp_get_logical_normal(EMmsg,&GRid, env, params, pl_nrml, pl_pt);
  EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  BSdistptpl(&rc,point1,pl_pt,pl_nrml,&dist);
  EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

  if (dist > disttol)
  {

  /*
   * See if point 2 is lying on that plane.
   */
   BSdistptpl(&rc,point2,pl_pt,pl_nrml,&dist);
   if (dist > disttol)
   {
     *EMmsg = EMS_E_InvalidCase;
     goto wrapup;
   }
   else
    for (i=0;i<3;i++)
     axis[i] = -axis[i];
  }

  dot_p = BSdotp(&rc,axis,pl_nrml);

  if (dot_p < 0)
  {
   status = om$send (msg = message EMSsurface.EMrevorient (EMmsg),
                     targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
 }
 else
 {
  status = om$send (msg = message EMSsolid.EMorient_yourself(EMmsg, options,
                          env),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);
 }


wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsfsolid:EMorient_yourself error");
 return (status);

}

static int pp_get_axis_points(EMmsg,proj_GRid,env,point1, point2)
IGRlong *EMmsg;
struct GRid *proj_GRid;
struct GRmd_env *env;
IGRpoint point1;
IGRpoint point2;
{
 OMuword proj_classid;
 struct EMsurface_params   parms;
 unsigned short   type;
 OM_S_CHANSELECT to_comps;
 IGRlong status;
 IGRdouble axis[6];
 struct IGRbsp_curve *cptr;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 cptr = &parms.params.project.curve;
 cptr->poles = NULL; /* Do not want projected curve */
 cptr->knots = NULL;
 cptr->weights = NULL;

 status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$get_classid(objid = proj_GRid->objid,
                          osnum = proj_GRid->osnum,
                          p_classid = &proj_classid);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$is_ancestry_valid ( subclassid = proj_classid,
                                  superclassid = OPP_EMSprjcompsf_class_id );

  if (status == OM_S_SUCCESS)
  {
   status = om$send(msg = message EMSsurface.EMget_params(EMmsg, NULL,
                         env, &type, &parms),
                   senderid = proj_GRid->objid,
                   p_chanselect = &to_comps,
                   from = 0, to = 0);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  else
  {
   status = om$send(msg = message EMSsurface.EMget_params(EMmsg, NULL,
                         env, &type, &parms),
                   senderid = NULL_OBJID,
                   targetid = proj_GRid->objid,
                   targetos = proj_GRid->osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }

   get_projection_axis(EMmsg,type,&parms,axis);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, *EMmsg, wrapup);

   OM_BLOCK_MOVE(&axis[0], point1,sizeof(IGRpoint));
   OM_BLOCK_MOVE(&axis[3], point2,sizeof(IGRpoint));

wrapup:
 if (type == EMproject)
 { 
  if (cptr->poles) om$dealloc(ptr = cptr->poles);
  if (cptr->knots) om$dealloc(ptr = cptr->knots);
  if (cptr->weights) om$dealloc(ptr = cptr->weights);
 }
 return(1);
}
static int pp_get_logical_normal(EMmsg,surf_GRid, env, params, sf_nrml, sf_pt)
IGRlong *EMmsg;
struct GRid *surf_GRid;
struct GRmd_env *env;
IGRdouble *params;
IGRdouble *sf_nrml;
IGRdouble *sf_pt;
{
 BSrc   rc;
 IGRlong status;
 struct IGRbsp_surface *surface;
 IGRint i;

 surface= NULL;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = om$send(
   msg = message GRvg.GRgenabsg(
    EMmsg,
    &env->md_env.matrix_type,
    env->md_env.matrix,
    (IGRchar **) &surface),
   senderid = NULL_OBJID,
   targetid = surf_GRid->objid,
   targetos = surf_GRid->osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 BSsfarrevn(&rc,surface,1,&params[0], 1, &params[1],sf_pt,sf_nrml);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

 status = BSnorvec(
   &rc,
   sf_nrml);                  

 if (!surface->pos_orient)
 {
  for (i=0;i<3;i++)
   sf_nrml[i] = -sf_nrml[i];
 }

wrapup:
 return(1);
}
end implementation EMSsfsolid;
