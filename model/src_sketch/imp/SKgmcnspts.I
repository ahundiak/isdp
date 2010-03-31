class implementation SKgeometry;

from SKvariable import SKputvar;
from SKmgr import SKconnect_to_ptvar;

extern GRclassid OPP_SKptvar_class_id;

method SKcreate_constraint_points(IGRlong *EMmsg; IGRushort options;
                                  IGRshort *matrix_type;
                                  IGRdouble *matrix;
                                  OM_S_OBJID skmgr, *first, *last;
                                  IGRint *element_no;
                                  IGRint total_count)
                               
{
 IGRlong status;
 IGRdouble param, point[3];
 struct GRprops properties;
 OM_S_OBJID skpt;
 OM_S_CHANSELECT to_owner;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 if (skmgr == NULL_OBJID)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 param = 0;

 status = EMmake_chanselect(GRconnector_to_owners, &to_owner);
 
 if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
  {
   status = om$send (msg = message GRvg.GRgeomprops(EMmsg, matrix_type, 
                      matrix, &properties),
                   p_chanselect = &to_owner);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
 else
  {
   status = om$send (msg = message GRvg.GRgeomprops(EMmsg, matrix_type, 
                      matrix, &properties),
                     targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }

 if (*element_no == 0)
 {
  param = 0;

  status = om$send (msg = message GRvg.EMptatpr(EMmsg, 
                         matrix_type,
                         matrix,&param,1,point),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = om$construct (classid = OPP_SKptvar_class_id,
                        p_objid = &skpt);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$send (msg = message SKgeometry.SKconnect_to_pt
            (EMmsg, NULL, skpt, 0, 0),targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = om$send (msg = message SKmgr.SKconnect_to_ptvar(EMmsg,skpt,NULL,
                          0,MAXINT),
                    targetid = skmgr); 
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
                         
  status = om$send (msg = message SKvariable.SKputvar(EMmsg,NULL,
             matrix_type,matrix,point), targetid = skpt);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  *first = skpt;
 }
 else
 {
   status = om$send (msg = message SKgeometry.SKconnect_to_pt
             (EMmsg, NULL, *last, MAXINT, 0), targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

/*
 * If I am not last element of (If i am the last element but my owner is not
 * closed then create an end point constraint.
 */

 if  ((*element_no < (total_count - 1)) || ((*element_no == (total_count - 1))
      &&  !properties.phy_closed))
 {
  param = 1;

  status = om$send (msg = message GRvg.EMptatpr(EMmsg, 
                         matrix_type,
                         matrix,&param,1,point),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = om$construct (classid = OPP_SKptvar_class_id,
                        p_objid = &skpt);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$send (msg = message SKgeometry.SKconnect_to_pt
            (EMmsg, NULL, skpt, 0, 1), targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = om$send (msg = message SKmgr.SKconnect_to_ptvar(EMmsg,skpt,NULL,
                          0,MAXINT),
                    targetid = skmgr); 
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = om$send (msg = message SKvariable.SKputvar(EMmsg,NULL,
                          matrix_type,matrix,point),
                    targetid = skpt);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  *last = skpt;
 }
 
 if ((*element_no == (total_count - 1)) && (properties.phy_closed))
 {
  if (total_count > 1)
  {
   status = om$send (msg = message SKgeometry.SKconnect_to_pt
             (EMmsg, NULL, *last, 0, 0), targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   status = om$send (msg = message SKgeometry.SKconnect_to_pt
             (EMmsg, NULL, *first, 0, 1), targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  *last = *first;
 }

 ++(*element_no);

wrapup:
 EMWRAPUP(*EMmsg, status, "In SKgeometry:SKcreate_constraint_points error");
 return (status);
}

end implementation SKgeometry;

