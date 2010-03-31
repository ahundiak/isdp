/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSassoc;

/*
 * This function transforms an entity such that the same can behave
 * associatively and support the protocol defined at EMSassoc.
 * 
 * History
 *   Creation : PP : 10/21/91
 */

from EMSsurface import EMtransform_to_associative;

extern OMuword OPP_EMSsurface_class_id, OPP_GRcurve_class_id;

extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_GR3dellarc_class_id;
extern OMuword OPP_GR3dellipse_class_id;
extern OMuword OPP_GR3dinfline_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dorthlnst_class_id;
extern OMuword OPP_GR3dorthpoly_class_id;
extern OMuword OPP_GR3dpllnstr_class_id;
extern OMuword OPP_GR3dpoint_class_id;
extern OMuword OPP_GR3dpolygon_class_id;
extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_GRlinear_class_id;
extern OMuword OPP_EMSdatpln_class_id;

extern OMuword OPP_GA3dcirarc_class_id;
extern OMuword OPP_GA3dcircle_class_id;
extern OMuword OPP_GA3dellarc_class_id;
extern OMuword OPP_GA3dellipse_class_id;
extern OMuword OPP_GA3dinfline_class_id;
extern OMuword OPP_GA3dlineseg_class_id;
extern OMuword OPP_GA3dlinestr_class_id;
extern OMuword OPP_GA3dorthlnst_class_id;
extern OMuword OPP_GA3dorthpoly_class_id;
extern OMuword OPP_GA3dpllnstr_class_id;
extern OMuword OPP_GA3dpoint_class_id;
extern OMuword OPP_GA3dpolygon_class_id;
extern OMuword OPP_GAbcsubbc_class_id;
extern OMuword OPP_GAcompcurve_class_id;
extern OMuword OPP_GAlinear_class_id;
extern OMuword OPP_EMAdatpln_class_id;

/* Associative parametric classes */

extern OMuword OPP_ASby2ptsg_class_id;
extern OMuword OPP_ASlinedbt_class_id;
extern OMuword OPP_ASlineorth_class_id;
extern OMuword OPP_ASlinepara_class_id;
extern OMuword OPP_ASlineangl_class_id;
extern OMuword OPP_AScircnt_class_id;
extern OMuword OPP_ASarccntrd_class_id;
extern OMuword OPP_AScompcurve_class_id;

/* Variational geometry classes */

extern OMuword OPP_SKarc_class_id;
extern OMuword OPP_SKline_class_id;
extern OMuword OPP_SKcircle_class_id;
extern OMuword OPP_SKpoint_class_id;

extern OMuword OPP_EMSgroup_class_id;
extern OMuword OPP_GRgrgrp_class_id;

IGRint EFtransform_to_associative(EMmsg, options, non_assoc_GRid)
IGRlong *EMmsg; /* Completion message */
unsigned int options; /* Currently unused */
struct GRid *non_assoc_GRid; /* GRid to be transformed */
{
 IGRlong status;
 IGRlong msg_loc, change_class = FALSE;
 OM_S_OBJID loc_new_objid;
 char assoc_classname[20];

 assoc_classname[0] = '\0';
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (EFisAncestryValid(&msg_loc, non_assoc_GRid->objid, non_assoc_GRid->osnum, 
                        OPP_EMSsurface_class_id, FALSE))
 {
   status = om$send (msg = message EMSsurface.EMtransform_to_associative(
                           &msg_loc,
                           &loc_new_objid),
                     senderid = NULL_OBJID,
                     targetid = non_assoc_GRid->objid,
                     targetos = non_assoc_GRid->osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   non_assoc_GRid->objid = loc_new_objid;
 }
 else if (EFisAncestryValid(&msg_loc, non_assoc_GRid->objid,
                            non_assoc_GRid->osnum, 
                            OPP_GRcurve_class_id, FALSE))
 {
   OMuword curve_classid;
   status = om$get_classid (osnum = non_assoc_GRid->osnum,
                            objid = non_assoc_GRid->objid,
                            p_classid = &curve_classid);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

   status = EFget_assoc_classid(&msg_loc, curve_classid, assoc_classname);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_InvalidArg, wrapup);
   change_class = TRUE;

 }
 else if (EFisAncestryValid(&msg_loc, non_assoc_GRid->objid,
                            non_assoc_GRid->osnum, 
                            OPP_EMSdatpln_class_id, FALSE))
 {
  strcpy(assoc_classname, "EMAdatpln");
  change_class = TRUE;
 }
 else if (EFisAncestryValid(&msg_loc, non_assoc_GRid->objid,
                            non_assoc_GRid->osnum, 
                            OPP_GRgrgrp_class_id, FALSE))
 {
  strcpy(assoc_classname, "EMSagrp");
  change_class = TRUE;
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 if (change_class)
 {
  status = om$change_class(objid = non_assoc_GRid->objid,
                           osnum = non_assoc_GRid->osnum,
                           sd_override = OM_K_change_class_sd_override,
                           classname = assoc_classname);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EFtransform_to_associative error");
 return (status);
}

IGRint EFget_assoc_classid(msg, classid, classname)
IGRlong *msg;
OMuword classid;
char *classname;
{
 IGRint sts;
 
 sts = OM_S_SUCCESS;

 if ((classid == OPP_GR3dcirarc_class_id) ||
     (classid == OPP_SKarc_class_id) ||
     (classid == OPP_GA3dcirarc_class_id))
  strcpy(classname,"GA3dcirarc");
 else if ((classid == OPP_GR3dcircle_class_id)  || 
          (classid == OPP_SKcircle_class_id) ||
          (classid == OPP_GA3dcircle_class_id))
  strcpy(classname,"GA3dcircle");
 else if ((classid == OPP_GR3dellarc_class_id) ||
         (classid == OPP_GA3dellarc_class_id))
  strcpy(classname,"GA3dellarc");
 else if ((classid == OPP_GR3dellipse_class_id) ||
         (classid == OPP_GA3dellipse_class_id))
  strcpy(classname,"GA3dellipse");
 else if ((classid == OPP_GR3dinfline_class_id) ||
          (classid == OPP_GA3dinfline_class_id))
  strcpy(classname,"GA3dinfline");
 else if ((classid == OPP_GR3dlineseg_class_id) ||
          (classid == OPP_SKline_class_id) ||
          (classid == OPP_GA3dlineseg_class_id))
  strcpy(classname,"GA3dlineseg");
 else if ((classid == OPP_GR3dlinestr_class_id) ||
          (classid == OPP_GA3dlinestr_class_id))
  strcpy(classname,"GA3dlinestr");
 else if ((classid == OPP_GR3dorthlnst_class_id) ||
          (classid == OPP_GA3dorthlnst_class_id))
  strcpy(classname,"GA3dorthlnst");
 else if ((classid == OPP_GR3dorthpoly_class_id) ||
          (classid == OPP_GA3dorthpoly_class_id))
  strcpy(classname,"GA3dorthpoly");
 else if ((classid == OPP_GR3dpllnstr_class_id) ||
          (classid == OPP_GA3dpllnstr_class_id))
  strcpy(classname,"GA3dpllnstr");
 else if ((classid == OPP_GR3dpoint_class_id) ||
          (classid == OPP_SKpoint_class_id) ||
          (classid == OPP_GA3dpoint_class_id))
  strcpy(classname,"GA3dpoint");
 else if ((classid == OPP_GR3dpolygon_class_id) ||
          (classid == OPP_GA3dpolygon_class_id))
  strcpy(classname,"GA3dpolygon");
 else if ((classid == OPP_GRbcsubbc_class_id) ||
          (classid == OPP_GAbcsubbc_class_id))
  strcpy(classname,"GAbcsubbc");
 else if ((classid == OPP_GRcompcurve_class_id) ||
          (classid == OPP_GAcompcurve_class_id))
  strcpy(classname,"GAcompcurve");
 else    
         if(    ( classid == OPP_ASlinedbt_class_id  ) ||
 	        ( classid == OPP_ASlineorth_class_id ) ||
 	        ( classid == OPP_ASlinepara_class_id ) ||
 	        ( classid == OPP_ASlineangl_class_id ) ||
 	        ( classid == OPP_ASby2ptsg_class_id  )) 
                  strcpy(classname,"GA3dlineseg");
	 else if( classid ==  OPP_AScircnt_class_id )
                  strcpy(classname,"GA3dcircle");
         else if( classid ==  OPP_ASarccntrd_class_id )
                  strcpy(classname,"GA3dcirarc");
	 else if( classid ==  OPP_AScompcurve_class_id )
                  strcpy(classname,"GAcompcurve");
         else 
		sts = OM_E_NOSUCHCLASS;
/*
 * eof
 */
 return(sts);
}
end implementation EMSassoc;
