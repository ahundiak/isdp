class implementation GAbcsubbc;

#include "GAbcsubbc.h"
#include "OMmacros.h"
#include "bsparameters.h"
#include "bserr.h"

extern OMuword OPP_GAbcsubbc_class_id, OPP_GRbcsubbc_class_id;
from EMSparamvc import EMconstruct;

/*
 * HISTORY:	
 * Prasad	?       
 * Carlos	6/92    First release (for Associative fitted curve).
 * Carlos	7/16/92	Reworked associative part to put paramvc's 
 * 			even if not given beg_tan and end_tan.
 * 
 * DESCRIPTION:
 * This function constructs a fitted curve and its parameter
 * vectors (if associative).
 */
IGRint GAbcsubbc_AScurve_by_data_reduction_func(EMmsg,
                                                options,
                                                cvorder,
                                                beg_tan,
                                                end_tan,
                                                ls_info,
                                                construct_list,
                                                res_id,
                                                average_error,
                                                max_error,
                                                max_indicator,
                                                error_line)
IGRlong *EMmsg; 
unsigned int options; 
IGRint cvorder;
IGRvector beg_tan;
IGRvector end_tan;
struct GRlc_info *ls_info;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
IGRdouble *average_error, *max_error;
IGRlong *max_indicator;
IGRpoint error_line[2];
{
 IGRlong status;
 IGRint msg_loc, rc;
 OMuword constros;
 struct GAbcsubbc_AScurve_by_data_reduction_info recomp_info;
 struct EMfit_error_info *more_info = NULL;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 *res_id = NULL_OBJID;
 constros = construct_list->env_info->md_id.osnum;

 if (options & EMSasconst_notassociative)
 {
   IGRdouble avg_error_buff;
   IGRdouble max_error_buff;
   IGRlong max_ind_buff;
   IGRpoint error_line_buff[2];

   status = om$construct(classid = OPP_GRbcsubbc_class_id,
                         msg = message GRsubbc.EMleast_squares_fit_curvee(
                               cvorder,
                               0,
                               NULL,
                               NULL,
                               ls_info,
                               (IGRvector *)beg_tan,
                               (IGRvector *)end_tan,
                               NULL,
                               NULL, /* No reference curve */
                               &avg_error_buff,
                               &max_error_buff,
                               &max_ind_buff,
                               error_line_buff,
                               construct_list),
                         p_objid = res_id,
                         osnum = constros);
  EMerr_hndlr(!(1&status&*(construct_list->msg)), *EMmsg, EMS_E_Fail, wrapup);

  if (average_error)
   *average_error = avg_error_buff;

  if (max_error)
   *max_error = max_error_buff;

  if (error_line)
   OM_BLOCK_MOVE(error_line_buff, error_line, sizeof (IGRpoint) * 2);

  if (max_indicator)
   *max_indicator = max_ind_buff;
 }
 else
 {
  IGRchar *save_geom_ptr;
  IGRint num_parents;
  short mattyp;
  IGRdouble *mat;
  struct EMSvector_info direction;
  struct EMSobject_info list[3];
  direction.type = EMSdatainfo_numeric;

  mattyp = construct_list->env_info->md_env.matrix_type;
  mat = construct_list->env_info->md_env.matrix;

  list[0].grid = ls_info->located_obj;
  list[0].env = ls_info->module_info;
  num_parents = 1;

  BSEXTRACTPAR(&rc, BSTOLCHRDHT, recomp_info.cht);

  if (!beg_tan) {
    /* give it some value, to be changed later */
    IGRvector tan1;
    int i;
    recomp_info.props = 0;
    for (i=0; i<3; i++) 
      tan1[i] = 1;
    OM_BLOCK_MOVE(tan1,direction.vec,sizeof(IGRvector));
    }
    else {
      recomp_info.props = GR_beginning_tangent;
      OM_BLOCK_MOVE(beg_tan,direction.vec,sizeof(IGRvector));
      }

  status = EMgetparvec_object(&msg_loc, mattyp, mat, constros,
                              &direction, &list[num_parents]);
  EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  ++(num_parents);

  if (!end_tan) {
    /* give it some value, to be changed later */
    IGRvector tan2;
    int i;
    for (i=0; i<3; i++) 
      tan2[i] = 1;
    OM_BLOCK_MOVE(tan2,direction.vec,sizeof(IGRvector));
    }
    else {
      int i;
      for (i=0;i<3;i++)
        end_tan[i] = -end_tan[i];
      recomp_info.props |= GR_end_tangent;
      OM_BLOCK_MOVE(end_tan,direction.vec,sizeof(IGRvector));
      };
  status = EMgetparvec_object(&msg_loc, mattyp, mat, constros,
                                &direction, &list[num_parents]);
  EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  ++(num_parents);

  recomp_info.order = cvorder;

  status = om$construct(classid = OPP_GAbcsubbc_class_id,
                        p_objid = res_id,
                        osnum = constros);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
/*
 * Use the geometry pointer in construct_list to return information
 * about the error stuff. 
 */

  save_geom_ptr = construct_list->geometry; 
  status = om$send(msg = message EMSassoc.EMinit_associative(EMmsg,
                          NULL, num_parents, list,        
                          GAbcsubbc_AScurve_by_data_reduction,
                          sizeof(recomp_info),
                          (IGRchar *)&recomp_info,
                          construct_list),
                    senderid = NULL_OBJID,
                    targetid = *res_id,
                    targetos = constros);
  more_info = (struct EMfit_error_info *) construct_list->geometry;
  construct_list->geometry = save_geom_ptr;
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if (average_error)
   *average_error = more_info->average_error;

  if (max_error)
   *max_error = more_info->max_error;

  if (max_indicator)
   *max_indicator = more_info->max_indicator;

  if (error_line)
   OM_BLOCK_MOVE(more_info->error_line, error_line, sizeof (IGRpoint) * 2);
  
  if (!(beg_tan && end_tan)) {
   /* get abstract geometry and find what the first and last segments
    * for the control polygon are. These will then be the 'natural'
    * tangency parameter vectors (if any of them had not been given 
    * by the user) */
    IGRchar *p_geom = NULL;
    struct IGRbsp_curve  curve;
    struct IGRbsp_curve *pcurve;
    IGRdouble *poles = NULL;
    IGRlong msg = EMS_S_Success;
    IGRushort opts; 
    struct EMSgeomdata vecgeom;
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc;

    pcurve = &curve;
    stat_OM = om$send (msg = message GRvg.GRgenabsg (&msg_loc,
            &mattyp, 
            mat,
            &p_geom), 
            senderid = NULL_OBJID,            
            targetid = *res_id,
            targetos = constros);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), msg, EMS_E_Fail, wrapup);
    pcurve = (struct IGRbsp_curve *)p_geom;
    poles = pcurve->poles; 

    if (!beg_tan) {
      /* change parameter vector to direction of segment between first 
         and second poles of the bspline */
      int i;
      for (i=0; i<3; i++)
        vecgeom.vector[i] = poles[i + 3] - poles[i]; 
      status = om$send(msg = message EMSparamvc.EMconstruct(EMmsg,
      					opts, 
      					&mattyp, 
      					mat,
      					&vecgeom),
      			senderid = NULL_OBJID,
      			targetid = list[1].grid.objid,
      			targetos = constros);
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
      recomp_info.props |= GR_beginning_tangent;
      /* modify recomp info so that it knows there is beginning tangent */
      status = om$send(msg = message EMSassoc.EMput_info(EMmsg,
      					NULL, 
      					GAbcsubbc_AScurve_by_data_reduction,
      					sizeof(recomp_info),
      					(IGRchar *)&recomp_info),
      			senderid = NULL_OBJID,
      			targetid = *res_id,
      			targetos = constros);
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
      }

    if (!end_tan) {
      /* change parameter vector to direction of segment between last 
         and next to last poles of the bspline */
      int i, j=0;
      for (i = (pcurve->num_poles - 1)*3; i < (pcurve->num_poles)*3; i++)
        vecgeom.vector[j++] = poles[i - 3] - poles[i]; 
      status = om$send(msg = message EMSparamvc.EMconstruct(EMmsg,
      					opts, 
      					&mattyp, 
      					mat,
      					&vecgeom),
      			senderid = NULL_OBJID,
      			targetid = list[2].grid.objid,
      			targetos = constros);
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
      recomp_info.props |= GR_end_tangent;
      /* modify recomp info so that it knows there is end tangent */
      status = om$send(msg = message EMSassoc.EMput_info(EMmsg,
      					NULL, 
      					GAbcsubbc_AScurve_by_data_reduction,
      					sizeof(recomp_info),
      					(IGRchar *)&recomp_info),
      			senderid = NULL_OBJID,
      			targetid = *res_id,
      			targetos = constros);
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
      }
 }

wrapup:
 if (!(1&status&*EMmsg))
 {
  if (*res_id != NULL_OBJID)
  {
   IGRlong cln_msg;

   om$send (msg = message GRgraphics.GRdelete(&cln_msg, 
                  construct_list->env_info),
           senderid = NULL_OBJID,
           targetid = *res_id,
           targetos = constros);
  }
 }
 if (more_info) om$dealloc(ptr = more_info);

 EMWRAPUP (*EMmsg, status, "In GAbcsubbc_curve_by_data_reduction error");
 }
 return (status);
}
end implementation GAbcsubbc;

