class implementation EMSrevcompsf;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "gocmacros.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "MDreveledef.h"
#include "emssfdef.h"
#include "EMSopt.h"    /* for EMS_OPT_CONNECTABLE */
#include "EMSsfparms.h"
#include "EMSommacros.h"   /* ems$get_memory   */
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EC_I.h"
#include "nddef.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "OMmacros.h"

#define BUFFER_SIZE  400

from EMSrevol     import EMgetRevolvedFormat;

method EMget_params(
 IGRlong *EMmsg;    /* Completion message */
 struct IGRbsp_surface *geom;    /* Surface geometry */
 struct GRmd_env *env;    /* module environment of the  surface */
 IGRushort *type;    /* surface type */
 struct EMsurface_params *params)
{
  IGRlong status;
  IGRboolean    is_360, world = TRUE, got_it = FALSE;
  OM_S_CHANSELECT    to_comps;
  IGRdouble  static_doubles_buffer[BUFFER_SIZE], *doubles_buffer = NULL;
  IGRint num_components = 0, rvinx, i;
  struct EMrevolve_params *ptr = NULL;
  struct IGRbsp_surface *revcmp_gm = NULL;
  struct BSgeom_bsp_surf revsrf;

  extern void BSsftgeomsf();
  extern void BSaxsfrev();

  *EMmsg = MSSUCC;
  status = OM_S_SUCCESS;

  if(type)
  *type = EMrevol;

  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

  status = om$send(msg = message GRowner.GRget_number_components
                    (EMmsg, &num_components),
                     targetid = my_id);
  EMomerr_hndlr ( status, wrapup, "GRget_number_components");

  if(params)
   {
  ptr = &params->params.revolve;
  status = om$send(msg = message GRgraphics.GRgetrang
                         (EMmsg,
                          &env->md_env.matrix_type,
                          env->md_env.matrix,
                          &world,
                          params->range),
                    targetid = my_id);

   if (!(status & *EMmsg & 1))
     goto wrapup;

  /* Instead of relying on a surface of revolution being at index 0, loop
      around untill the revolved format is found.
   */
   {
    for(i=0; i<num_components; i++)
     {
      status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(EMmsg,
                         TRUE, &env->md_env.matrix_type,
                         env->md_env.matrix, &ptr->curve, NULL, NULL,
                         NULL, NULL, NULL),
                    p_chanselect = &to_comps,
                    from = i, to = i);
       if (!(status & *EMmsg & 1)) continue;
       else {got_it = TRUE; rvinx = i; break;}
     }
      status = OM_S_SUCCESS;
      *EMmsg = MSSUCC;
   }

  if(got_it) { 
  ems$get_memory(rc = EMmsg, element_size = sizeof(IGRdouble),
                 num_elements = ptr->curve.num_poles *
                               (ptr->curve.rational ? 4:3) +
                                ptr->curve.num_knots,
                 buffer = (IGRchar *)static_doubles_buffer,
                 buffer_size = BUFFER_SIZE,
                 ptr = (IGRchar **) &doubles_buffer);

  ptr->curve.poles = doubles_buffer;
  ptr->curve.weights = ptr->curve.rational ?
                       doubles_buffer + ptr->curve.num_poles * 3 : NULL;
  ptr->curve.knots = doubles_buffer +
                     ptr->curve.num_poles * (ptr->curve.rational ? 4 : 3);

  status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(EMmsg,
                   FALSE, &env->md_env.matrix_type,
                   env->md_env.matrix, &ptr->curve,
                  (IGRdouble *)ptr->axis, &is_360,
                   &ptr->start_angle, &ptr->sweep_angle, FALSE),
                   p_chanselect = &to_comps,
                   from = rvinx, to = rvinx);
  if (!(status & *EMmsg & 1) )
      goto wrapup;

    } /* if (got_it) */
 else {
  OMuword cmpnt_classid;
  struct GRid cmpnt_GRid;
  IGRboolean revsf_found = FALSE;
  IGRshort gencv_flag;
  IGRlong cmpnt_size;

  for(i = 0; i < num_components; i++) {
      status = om$get_objid_at_index (object = me,
                 p_chanselect = &to_comps,
                 index = i, objidaddr = &cmpnt_GRid.objid,
                 osnumaddr = &cmpnt_GRid.osnum);
  
               if(!(1 & status)) {
                 *EMmsg = EMS_E_OMerror;
                 goto wrapup;
                 } 
       status = om$get_classid (osnum = cmpnt_GRid.osnum,
                                objid = cmpnt_GRid.objid,
                                p_classid = &cmpnt_classid);

               if(!(1 & status)) {
                 *EMmsg = EMS_E_OMerror;
                 goto wrapup;
                 }
       status = om$is_ancestry_valid (subclassid = cmpnt_classid,
                        superclassid = OPP_EMSrevcompsf_class_id);
               if(!(1 & status)) {
                 *EMmsg = EMS_E_OMerror;
                 goto wrapup;
                 }
       if (status == OM_S_SUCCESS) {
           revsf_found = TRUE;
           break;
               }
           }  

       if(!geom) {
          status = om$send (msg = message GRvg.GRgetsize (EMmsg,
                            &env->md_env.matrix_type,
                            env->md_env.matrix,
                            &cmpnt_size),
                      targetid = cmpnt_GRid.objid,
                      targetos = cmpnt_GRid.osnum);
          if(!(1 & status & *EMmsg)) {
             *EMmsg = EMS_E_Fail;
              goto wrapup;
             }
          status = om$send (msg = message GRvg.GRgetgeom (EMmsg,
                            &env->md_env.matrix_type,
                            env->md_env.matrix,
                            (IGRchar *)revcmp_gm),
                      targetid = cmpnt_GRid.objid,
                      targetos = cmpnt_GRid.osnum);
          if(!(1 & status & *EMmsg)) {
             *EMmsg = EMS_E_Fail;
              goto wrapup;
             }
         }
       else revcmp_gm = geom;

       revsrf.geom_prop = FALSE;
       revsrf.type = BSSF_OF_REV;
       revsrf.bounded = TRUE;
       revsrf.bspsf = revcmp_gm;

       ptr->start_angle = 0;
       BSsftgeomsf (&revsrf, FALSE, BSSF_OF_REV, EMmsg);
       if(*EMmsg != BSSUCC) {
           *EMmsg = EMS_E_Fail;
           goto wrapup;
           }
          *EMmsg = EMS_S_Success;
       ptr->sweep_angle = revsrf.len1;
       OM_BLOCK_MOVE(revsrf.sfgen_cv, &ptr->curve,
                     sizeof(struct IGRbsp_curve));
       BSaxsfrev(revcmp_gm, revsrf.pt1, ptr->axis, &gencv_flag, EMmsg);
       if(*EMmsg != BSSUCC) {
           *EMmsg = EMS_E_Fail;
           goto wrapup;
           }
          *EMmsg = EMS_S_Success;
     }

 } /* if (params) */

 wrapup:

  if(doubles_buffer && doubles_buffer ISNT static_doubles_buffer)
    om$dealloc(ptr = doubles_buffer);

  if(revcmp_gm) om$dealloc (ptr = revcmp_gm);
  EMWRAPUP(*EMmsg, status, "EMSrevcompsf.EMget_params")
  return(status);
}

end implementation EMSrevcompsf;
