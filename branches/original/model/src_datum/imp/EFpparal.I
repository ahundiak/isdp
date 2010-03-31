class implementation EMAdatpln;

#include "EMSasnuc.h"
#include "exdef.h"
/* ***************************************************************

Description
 This function creates a referenec plane parallel to a planar face or
 another reference plane.

Arguments
 options :I : Currently the following options are supported
              EMSasconst_notassociative: In this case a non-associative
                parallel reference plane will be created.
 planar_element : I : Information about the planar face or a reference plane
                      to which the reference plane that is being created in
                      this command needs to be parallel to
 edge_info : I : This is used to determine the X,Y direction of the
                 reference plane.

                 It could be in one of the following forms:
                 if X and Y are specified
                   then edge[0] contains information about the X edge.
                        edge[1] contains information about the Y edge.

                 if only X is specified
                   then edge[0] will contain information about the X edge
                   and edge[1].located_obj.objid should be set to 
                   NULL_OBJID.

                 if only Y is specified
                   then edge[1] will contain information about the X edge
                   and edge[0].located_obj.objid should be set to 
                   NULL_OBJID.

                  if none of them are specified, then the function will
                  try to construct a reference plane with orientations
                  based on some internal rules. In this case edge_info
                  can be set to NULL.

offset_event : I : This could be in one of the following forms:
                   If the reference plane that needs to be constructed
                   has to pass thru a point then:
                   offset_event->response should be EX_DATA and the
                   structure should have information appropriately.
                   
                   if the same is not set to EX_DATA then it is 
                   assumed that the reference plane needs to be created
                   by a offset based on a value/expression.
              
                   If no value is being input, it is the responsibility of
                   the caller to set offset_event->subtype to be GRst_DEFAULT
                   in which case a coincident reference plane will be
                   created.

props : I :   Other salient information is passed through this field.
              if (props & EMS_X_EDGE_PRIMARY)
               then x edge is assumed to be primary 
              else the y edge is assumed to e primary. This is true
               when both edges are input.

               if (props & EMS_PLANE_REV)
                then it is assumed that the offset needs to be done in
                the opposite direction to the oriented normal of a
                reference plane/face.
              
               if (props & EMS_EDGE_REV)
                then it is assumed that the direction is opposite to the
                curve direction of the edge. This is only valid when either
                X or Y edges are being passed.

construct_list : I : Construction information
cons_obj : O : Constructed object

Notes
 Upon exit the completion code can be interpreted as follows:
  (if (1&*EMmsg) is TRUE then it is success else we have failure.

History
 07/30/92 : PP : Creation

********************************************************************** */
                   

 


IGRint EFcreate_ref_parallel_to_plane1(EMmsg, 
       options,
       planar_element,
       edge_info,
       offset_event,
       props,
       construct_list,
       cons_obj)
IGRlong *EMmsg;
unsigned int options; 
struct GRlc_info *planar_element; /* Element to which the reference plane being
                                     created is parallel to */
struct GRlc_info *edge_info;      /* Information about X, Y edges. */
struct GRevent *offset_event;     /* Information containing the offset 
                                     distance or a point through which the
                                     reference plane needs to pass */
IGRint props;                     /* Used to communicate about the nature
                                     of the plane being constructed */
struct GRvg_construct *construct_list; /* Construction information */
OM_S_OBJID *cons_obj;             /* Objid that is constructed */

{
 IGRlong status;
 IGRshort mattype;
 IGRushort const_options=NULL;
 IGRint  type, num_parents;
 IGRdouble *mat;
 OMuword constros;
 struct EMSobject_info list[5], *next_ptr;
 struct EMSpoint_info thru_pt;
 struct EMSvalue_info val;
 struct EMSrefpln_planar_element_info info;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *cons_obj = NULL_OBJID;
 constros = construct_list->env_info->md_id.osnum;

 info.props = 0;
 info.props = props;

 list[0].grid = planar_element->located_obj; 
 list[0].env =  planar_element->module_info;

 type = EMS_ASparallel_to_planar_element_new;
 mattype = construct_list->env_info->md_env.matrix_type;
 mat = construct_list->env_info->md_env.matrix;

/*
 * edge_info[0] is the X edge.
 */
 next_ptr = &list[1];
 num_parents = 1;


 if (edge_info && edge_info[0].located_obj.objid != NULL_OBJID)
 {
  next_ptr->grid = edge_info[0].located_obj;
  next_ptr->env  = edge_info[0].module_info;
  ++next_ptr;
  ++num_parents;
  info.props |= EMS_X_EDGE;
 }

/*
 * edge_info[1] is the Y edge.
 */

 if (edge_info && edge_info[1].located_obj.objid != NULL_OBJID)
 {
  next_ptr->grid = edge_info[1].located_obj;
  next_ptr->env = edge_info[1].module_info;
  ++(next_ptr);
  ++num_parents;
  info.props |= EMS_Y_EDGE;
 }

 if ((offset_event->response != EX_DATA) &&
     (offset_event->subtype != GRst_DEFAULT))
 {
  val.type = EMSdatainfo_event;
  val.valevent = offset_event;
  status = EMgetparval_object (EMmsg, constros, NULL, &val,
                   next_ptr);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  info.props |= EMS_OFFSET_VALUE;
  ++num_parents;
 }
 else if (offset_event->response == EX_DATA)
 {
  thru_pt.type = EMSdatainfo_event;
  thru_pt.ptevent = offset_event;

  status = EMgetparpt_object(EMmsg, mattype, mat, constros, 
           &thru_pt, next_ptr);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  info.props |= EMS_THRU_POINT;
  ++num_parents;
  const_options = EMSasconst_no_autodimension;
 }
 else if (offset_event->subtype == GRst_DEFAULT)
 {
  const_options = EMSasconst_no_autodimension;
 }

 status = om$construct(classid = OPP_EMAdatpln_class_id,
                       p_objid = cons_obj,
                       osnum = constros);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSassoc.EMinit_associative(EMmsg,
                            ((options & EMSasconst_notassociative) ?
                              EMSasconst_noautodimension : const_options), 
                              num_parents, list, type,
                             sizeof (struct EMSrefpln_planar_element_info),
                             (char *)&info,
                             construct_list),
                       senderid = NULL_OBJID,
                       targetid = *cons_obj,
                       targetos = constros);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (options & EMSasconst_notassociative)
 {
  struct GRid src_GRid;

  src_GRid.objid = NULL_OBJID;
  status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                               &src_GRid,construct_list->env_info),
                    senderid = *cons_obj,
                    targetid = *cons_obj,
                    targetos = constros);
  if (1&status&*EMmsg)
   *cons_obj = src_GRid.objid;
  else
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 }
 

wrapup:
 if (!(1&status&*EMmsg))
 {
  IGRlong cln_sts, cln_msg;

  if (*cons_obj != NULL_OBJID)
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete(&cln_msg,
                            construct_list->env_info),
                      senderid = NULL_OBJID,
                      targetid = *cons_obj,
                      targetos = constros);
   *cons_obj = NULL_OBJID;
  }
 }
 return (status);
}
end implementation EMAdatpln;

