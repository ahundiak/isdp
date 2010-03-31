/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfspltwsf;

#include "EMS.h"

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSslspltwsf");
  return(OM_S_SUCCESS);
}

method GRxform(IGRlong *EMmsg; struct GRmd_env *obj_mdenv;
               IGRshort *matrix_type; IGRmatrix matrix;
               GRobjid *newobjid)
{
 IGRlong		sts;
 
 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message EMSdpr.EMchangeClass(EMmsg, NULL, NULL), 
				targetid = my_id);
 if(!(1&sts)) goto wrapup;

 sts = om$send(mode = OM_e_wrt_message, msg = message EMSsfboolean.GRxform
		(EMmsg, obj_mdenv, matrix_type, matrix, newobjid), 
		targetid = my_id);

wrapup:
return(sts);
}


extern OMuword OPP_EMSsolid_class_id, OPP_EMSsfboolean_class_id, 
	       OPP_EMSslboolean_class_id;
	
method EMchangeClass(IGRlong *EMmsg;
		      OMuword *newclassid, 
			      *changedToClassid)
{
 IGRlong		sts;
 OMuword		myclassid;
 IGRboolean		issolid = FALSE;
 char			newclassname[OM_K_MAXCLASS_LEN];
 OM_S_CHANSELECT	to_image;
 OM_S_OBJECT_LINKAGE	image;
 OMuint			count = 0;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 EMmake_chanselect(EMSsfspltwsf_to_mirror_image, &to_image);
 sts = om$get_channel_objects(object = me, p_chanselect = &to_image, 
			list = &image, size = 1, count = &count);
 if(!(1&sts)) goto wrapup;
 if(count)
  {
   sts = om$send(msg = message Root.wild_disconnect(to_image), targetid=my_id);
   if(!(1&sts)) goto wrapup;
   sts = om$send(msg = OPPmargs, targetid = image.S_objid);
   if(!(1&sts)) goto wrapup;
  }

 if(newclassid)
  {
   sts = om$get_classname(classid = *newclassid, classname = newclassname);
   if(!(1&sts)) goto wrapup;
   if(changedToClassid) *changedToClassid = *newclassid;
  }
 else
  {
   sts = om$get_classid(objid = my_id, p_classid = &myclassid);
   if(!(1&sts)) goto wrapup;

   if( (myclassid == OPP_EMSsolid_class_id) ||
     ((sts = om$is_ancestry_valid(superclassid = OPP_EMSsolid_class_id, 
				 subclassid = myclassid)) == OM_S_SUCCESS))
     {
      strcpy(newclassname, "EMSslboolean");
      if(changedToClassid) *changedToClassid = OPP_EMSslboolean_class_id;     
     }
    else 
     {
      strcpy(newclassname, "EMSsfboolean");
      if(changedToClassid) *changedToClassid = OPP_EMSsfboolean_class_id;     
     }
  }

 sts = om$change_class(objid = my_id, 
                       classname = newclassname,
                       sd_override = OM_K_change_class_sd_override);

wrapup:
return(sts);
}



method GRdelete(IGRlong *EMmsg; struct GRmd_env *env)
{
 IGRlong 		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_image;
 OMuint			count = 0;
 OM_S_OBJECT_LINKAGE	image;

 *EMmsg = EMS_S_Success;

 EMmake_chanselect(EMSsfspltwsf_to_mirror_image, &to_image);
 sts = om$get_channel_objects(object = me, p_chanselect = &to_image, 
			list = &image, size = 1, count = &count);
 if(count)
  {
   sts = om$send(msg = message Root.wild_disconnect(to_image), 
			targetid = my_id);
   if(!(1&sts)) goto wrapup;

   sts = om$send(msg = message EMSdpr.EMchangeClass(EMmsg, NULL, NULL), 
			targetid = image.S_objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 om$send(mode = OM_e_wrt_message, msg = message EMSsfboolean.GRdelete
			(EMmsg, env), targetid = my_id);
			
wrapup:
return(sts);
}

end implementation EMSsfspltwsf;
