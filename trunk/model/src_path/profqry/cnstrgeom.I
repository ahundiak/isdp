class implementation	SKmgr;

#include <stdio.h>
#include <alloca.h>
#include <math.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igetypedef.h"

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "EMSmsgdef.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

#include "EMSopt.h"
#include "SKdef.h"
#include "bserr.h"
#include "bsparameters.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWmodel.h"
#include "PWapi/cnstrgeom.h"

extern PWclassid OPP_SKmgr_class_id, OPP_SKequal_class_id;
extern PWclassid OPP_SKline_class_id, OPP_SKarc_class_id;
extern PWclassid OPP_SKhvptpt_class_id, OPP_SKifcol_class_id;
extern PWclassid OPP_SKifequal_class_id, OPP_SKcollinear_class_id;
extern PWclassid OPP_SKcompcurve_class_id,OPP_SKpoint_class_id;
extern PWclassid OPP_GRcompcurve_class_id,OPP_SKexplicit_class_id;
extern PWclassid OPP_SKhorizvert_class_id,OPP_SKrelang_class_id;
extern PWclassid OPP_SKfixang_class_id,OPP_SKcoincident_class_id;
extern PWclassid OPP_SKasptgrnd_class_id,OPP_SKnormal_class_id;
extern PWclassid OPP_SKparallel_class_id,OPP_SKptonelmt_class_id;
extern PWclassid OPP_SKradial_class_id,OPP_SKifptpt_class_id;
extern PWclassid OPP_SKimplicit_class_id,OPP_SKtangency_class_id;
extern PWclassid OPP_SKcircle_class_id,OPP_SKbspline_class_id;
extern PWclassid OPP_SKaxisptpt_class_id;

from SKvariable   import SKgetvar;
from SKconstraint import SKgetmgr,SKgetprops;
%safe
static PWresult GetPtvarCoords ( PWobjid vgpts, PWosnum os, PWpoint point);
static PWresult GetPtvarsCommonGeomid ( PWobjid vgpt1, PWobjid vgpt2, 
                                        PWosnum os, PWobjid *geom_id);
static PWresult GetPtvarKeypoint( PWobjid vgpts, PWosnum os, PWobjid geom_id, 
                                  enum PWtopopostype  *keypoint);
static PWresult GetPtvarGeomid( PWobjid vgpts, PWosnum os, int *num_cvids, 
                                  PWobjid *cvid);
%endsafe
/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetGroundGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts;
	  OMuint		num_members;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKasptgrnd_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
 
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                              sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                         osnum = os,
                                         p_chanselect = &to_ptvars,
                                         list = members,
                                         size = num_members,
	            		           count = &num_members);
	  vgpts = members[0].S_objid;
          GetPtvarCoords( vgpts, os, point);
          GetPtvarGeomid( vgpts, os, &num_cvids,cvid);
          if(num_cvids == 1)
             geom_id = cvid[0];
          else
             geom_id = cvid[1];
          GetPtvarKeypoint( vgpts, os, geom_id, &keypoint);
          cvpt[0].p_attrib = NULL;
          cvpt[0].props = NULL;
          pwInitCvpt (&cvpt[0], keypoint,point, 3, 0, 0.0, geom_id);
wrapup:

   PW_Wrapup (PWsts, "pwGetGroundConstraintGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetHorizVertGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          OMuint		num_members;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success;


          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKhorizvert_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  for(cnt=0;cnt<num_members;cnt++)
	         vgpts[cnt] = members[cnt].S_objid;
             
          for(cnt = 0; cnt < num_members; cnt++)
          {
             GetPtvarsCommonGeomid ( vgpts[0], vgpts[1],os, &geom_id);
	     if(geom_id == PW_K_NullObjid)
             {
               GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
               if(num_cvids == 1)
                 geom_id = cvid[0];
               else
                 geom_id = cvid[1];
             }
             GetPtvarCoords( vgpts[cnt], os, point);
             GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
             cvpt[cnt].p_attrib = NULL;
             cvpt[cnt].props = NULL;
             pwInitCvpt (&cvpt[cnt],keypoint, point, 3, 0, 0.0, geom_id);
          }
wrapup:
   PW_Wrapup (PWsts, "pwGetHorizVertConstraintGeom");
   return (PWsts);
}



/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetCoincidentGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[2];
	  OMuint		num_members;
	  int			cnti;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr,tmp_cnstr_id;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKcoincident_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &chan_to_members,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &chan_to_members,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
          tmp_cnstr_id = members[0].S_objid;

          /* Get vgpts corresponding to the constraint */
          num_members = 0;
          members = (OM_p_OBJECT_LINKAGE) alloca(sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = tmp_cnstr_id,
                                         osnum = os,
                                         p_chanselect = &to_ptvars,
                                         list = members,
                                         size = 2,
	        		         count = &num_members);
	  vgpts[0] = members[0].S_objid;
	  vgpts[1] = members[1].S_objid;
          for(cnti=0;cnti<2;cnti++)
          {
            cvpt[cnti].p_attrib = NULL;
            cvpt[cnti].props = NULL;
            GetPtvarGeomid( vgpts[cnti], os, &num_cvids,cvid);
            if(num_cvids == 1)
               geom_id = cvid[0];
            else
               geom_id = cvid[1];
            GetPtvarCoords( vgpts[cnti], os, point);
            GetPtvarKeypoint( vgpts[cnti], os, geom_id, &keypoint);
            pwInitCvpt (&cvpt[cnti], keypoint,point, 3, 0, 0.0, geom_id);
          }
wrapup:

   PW_Wrapup (PWsts, "pwGetCoincidentGeom");
   return (PWsts);
}

/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetTangencyGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts;
	  OMuint		num_members;
	  int			cnti;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKtangency_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  vgpts = members[0].S_objid;
          GetPtvarGeomid( vgpts, os, &num_cvids,cvid);
          GetPtvarCoords( vgpts, os, point);
          for(cnti=0;cnti<2;cnti++)
          {
            cvpt[cnti].p_attrib = NULL;
            cvpt[cnti].props = NULL;
            if(cnti == 0)
               geom_id = cvid[0];
            else
               geom_id = cvid[1];
            GetPtvarKeypoint( vgpts, os, geom_id, &keypoint);
            pwInitCvpt (&cvpt[cnti], keypoint,point, 3, 0, 0.0, geom_id);
          }
wrapup:

   PW_Wrapup (PWsts, "pwGetTangencyConstraintGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
        PWobjid       O         *geom_id_out,
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetPointOnElementGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts;
	  OMuint		num_members;
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		sk_classid,cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          int                   num_cvids;
          PWobjid               cvid[2];
	  OM_S_OBJECT_LINKAGE   *constrs,*ptvars;
	  OMuint		num_constrs,num_ptvars;
	  OM_S_OBJECT_LINKAGE   *skpts;
	  OMuint		num_skpts;


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success;
 
          geom_id = PW_K_NullObjid;
          *geom_id_out = PW_K_NullObjid;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKptonelmt_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  vgpts = members[0].S_objid;

          cvpt[0].p_attrib = NULL;
          cvpt[0].props = NULL;
          GetPtvarGeomid( vgpts, os, &num_cvids,cvid);
          if(num_cvids == 1)
             geom_id = cvid[0];
          else
             geom_id = cvid[1];
          GetPtvarCoords( vgpts, os, point);
          GetPtvarKeypoint( vgpts, os, geom_id, &keypoint);
          pwInitCvpt (&cvpt[0], keypoint,point, 3, 0, 0.0, geom_id);

          /* Get  the other geometry */
          num_constrs = 0;
          geom_id = PW_K_NullObjid;
          constrs = (OM_p_OBJECT_LINKAGE) alloca(sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                         osnum = os,
                                         p_chanselect = &chan_to_members,
                                         list = constrs,
                                         size = 1,
	        		         count = &num_constrs);
	  OMsts = om$get_classid (objid = constrs[0].S_objid, osnum = os,
					  p_classid = &sk_classid);
	  if (!(1&OMsts))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
          if((om$is_ancestry_valid (subclassid = sk_classid,
                   superclassid = OPP_SKcollinear_class_id) == OM_S_SUCCESS))
          {
	    num_ptvars = 0;
	    OMsts = om$get_channel_count(objid = constrs[0].S_objid,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       count = &num_ptvars);
            OnErrorState (!(1&OMsts) || (num_ptvars != 3),     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
	    ptvars = (OM_p_OBJECT_LINKAGE) alloca (num_ptvars *
					sizeof(OM_S_OBJECT_LINKAGE));
	    OMsts = om$get_channel_objects(objid = constrs[0].S_objid,
						   osnum = os,
						   p_chanselect = &to_ptvars,
						   list = ptvars,
						   size = num_ptvars,
						   count = &num_ptvars);
            GetPtvarsCommonGeomid ( ptvars[1].S_objid, ptvars[2].S_objid,os,
                                    &geom_id);
            OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          }
          if((om$is_ancestry_valid (subclassid = sk_classid,
                   superclassid = OPP_SKequal_class_id) == OM_S_SUCCESS))
          {
	    num_skpts = 0;
	    OMsts = om$get_channel_count(objid = constrs[0].S_objid,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       count = &num_skpts);
            OnErrorState (!(1&OMsts) || (num_skpts != 2),     
                       PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),wrapup);
	    skpts = (OM_p_OBJECT_LINKAGE) alloca (num_skpts *
					sizeof(OM_S_OBJECT_LINKAGE));
	    OMsts = om$get_channel_objects(objid = constrs[0].S_objid,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       list = skpts,
					       size = num_skpts,
					       count = &num_skpts);
            for(cnt = 0; cnt < 2 ; cnt ++)
            {
	      OMsts = om$get_channel_count(objid = skpts[cnt].S_objid,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       count = &num_ptvars);
              OnErrorState (!(1&OMsts) || !num_ptvars,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
	      ptvars = (OM_p_OBJECT_LINKAGE) alloca (num_ptvars *
					sizeof(OM_S_OBJECT_LINKAGE));
	      OMsts = om$get_channel_objects(objid = skpts[cnt].S_objid,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       list = ptvars,
					       size = num_ptvars,
					       count = &num_ptvars);
              if((vgpts == ptvars[0].S_objid) || 
                                  (vgpts == ptvars[1].S_objid))
                continue;
              else
              {
                GetPtvarsCommonGeomid ( ptvars[0].S_objid,ptvars[1].S_objid, 
                                       os, &geom_id);
                OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
                break;
              }
                 
            }
          }
          *geom_id_out = geom_id;

wrapup:

   PW_Wrapup (PWsts, "pwGetPointOnElementGeom");
   return (PWsts);
}

/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
        PWobjid       O         *geom_id1,
        PWobjid       O         *geom_id2

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetParallelGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id1,
  PWobjid *geom_id2
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWobjid		mgr;
          OMuint		num_members;
          PWobjid               geom_id;


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          *geom_id1 = PW_K_NullObjid;
          *geom_id2 = PW_K_NullObjid;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKparallel_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || (num_members != 4),     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  for(cnt=0;cnt<num_members;cnt++)
            vgpts[cnt] = members[cnt].S_objid;

          GetPtvarsCommonGeomid ( vgpts[0], vgpts[1], os, &geom_id);
          OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          *geom_id1 = geom_id;
          GetPtvarsCommonGeomid ( vgpts[2], vgpts[3], os, &geom_id);
          OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          *geom_id2 = geom_id;
wrapup:
   PW_Wrapup (PWsts, "pwGetParallelGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetCollinearGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          OMuint		num_members;
          int                   num_cvids;
          PWobjid               cvid[2];



          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKcollinear_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || (num_members != 3),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
          for(cnt=0;cnt<num_members;cnt++)
	      vgpts[cnt] = members[cnt].S_objid;

	  for(cnt=0;cnt<num_members;cnt++)
          {
             GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
             if(num_cvids == 1)
               geom_id = cvid[0];
             else
               geom_id = cvid[1];
             GetPtvarCoords( vgpts[cnt], os, point);
             GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
             cvpt[cnt].p_attrib = NULL;
             cvpt[cnt].props = NULL;
             pwInitCvpt (&cvpt[cnt],keypoint, point, 3, 0, 0.0, geom_id);
          }
wrapup:
   PW_Wrapup (PWsts, "pwGetCollinearGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
        PWobjid       O         *geom_id1,
        PWobjid       O         *geom_id2

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetEqualityGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id1,
  PWobjid *geom_id2
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[2][2];
	  OMuint		num_members,num_sub_members;
	  int			cnt,cnti;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members,*sub_members;
	  PWclassid		cnstrclassid;
	  PWobjid		mgr;
	  PWobjid		geom_id;

          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          *geom_id1 = PW_K_NullObjid;
          *geom_id2 = PW_K_NullObjid;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKequal_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
          num_members = 0;
	  OMsts = om$get_channel_count(objid = cnstr_id,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       count = &num_members);
          OnErrorState (!(1&OMsts) || (num_members != 2),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

          members = (OM_p_OBJECT_LINKAGE) alloca(num_members *
                                     sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                         osnum = os,
                                         p_chanselect = &to_ptvars,
                                         list = members,
                                         size = num_members,
	        		         count = &num_members);
          for(cnt = 0; cnt < num_members ; cnt++)
          {
	    OMsts = om$get_channel_count(objid = members[cnt].S_objid,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       count = &num_sub_members);
            OnErrorState (!(1&OMsts) || !num_sub_members,     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
	    sub_members = (OM_p_OBJECT_LINKAGE) alloca (
					sizeof(OM_S_OBJECT_LINKAGE));
	    OMsts = om$get_channel_objects(objid = members[cnt].S_objid,
					       osnum = os,
					       p_chanselect = &to_ptvars,
					       list = sub_members,
					       size = num_sub_members,
					       count = &num_sub_members);
	    for(cnti = 0; cnti < 2; cnti++)
	    {
	       vgpts[cnt][cnti] = sub_members[cnti].S_objid;
	    }
          }
          GetPtvarsCommonGeomid ( vgpts[0][0], vgpts[0][1], os, &geom_id);
          OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          *geom_id1 = geom_id;
          GetPtvarsCommonGeomid ( vgpts[1][0], vgpts[1][1], os, &geom_id);
          OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          *geom_id2 = geom_id;
wrapup:

   PW_Wrapup (PWsts, "pwGetEqualityGeom");
   return (PWsts);
}

/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
        int           O         *num_cvpts,
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetNormalGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
          int			cnt;
	  OMuint		num_members;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr,geom_id1;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          geom_id = PW_K_NullObjid;
          geom_id1 = PW_K_NullObjid;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKnormal_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
          for(cnt=0; cnt<num_members; cnt++)
          {
	      vgpts[cnt] = members[cnt].S_objid;
          }
          *num_cvpts = num_members;
          if(num_members == 3)
          {
            for(cnt=0; cnt<3; cnt++)
            {
             if(cnt < 2)
               GetPtvarsCommonGeomid ( vgpts[0], vgpts[1],os, &geom_id);
             else
               GetPtvarsCommonGeomid ( vgpts[0], vgpts[2],os, &geom_id);
	     if(geom_id == PW_K_NullObjid)
             {
                GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
                if(num_cvids == 1)
                  geom_id = cvid[0];
                else
                  geom_id = cvid[1];
              }
              GetPtvarCoords( vgpts[cnt], os, point);
              GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
              cvpt[cnt].p_attrib = NULL;
              cvpt[cnt].props = NULL;
              pwInitCvpt (&cvpt[cnt], keypoint,point, 3, 0, 0.0, geom_id);
            }
          }
          else
          { 
            /* Get the common Geomids corresponding to the set of vgpts */
            GetPtvarsCommonGeomid ( vgpts[0], vgpts[1], os, &geom_id);
            OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
            GetPtvarsCommonGeomid ( vgpts[2], vgpts[3], os, &geom_id1);
            OnErrorState ((geom_id1 ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
             
            for(cnt=0; cnt< num_members; cnt++)
            {
              GetPtvarCoords( vgpts[cnt], os, point);
              if(cnt < 2)
                GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
              else
                GetPtvarKeypoint( vgpts[cnt], os, geom_id1, &keypoint);
              cvpt[cnt].p_attrib = NULL;
              cvpt[cnt].props = NULL;
              if(cnt < 2)
                pwInitCvpt (&cvpt[cnt], keypoint,point, 3, 0, 0.0, geom_id);
              else
                pwInitCvpt (&cvpt[cnt], keypoint,point, 3, 0, 0.0, geom_id1);
            
            }
          }
wrapup:
   PW_Wrapup (PWsts, "pwGetNormalGeom");
   return (PWsts);
}



/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
        PWobjid       O         *geom_id_out

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetSinglparlGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWobjid		geom_id,mgr;
          OMuint		num_members;
	  OM_S_OBJECT_LINKAGE   *ptvars;
          OMuint		num_ptvars;


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

	  *geom_id_out = PW_K_NullObjid;
	  geom_id = PW_K_NullObjid;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKifptpt_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &chan_to_members,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || (num_members != 1),     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &chan_to_members,
                                           list = members,
                                           size = 1,
	               		           count = &num_members);
          
          num_ptvars = 0;
          OMsts = om$get_channel_count(objid = members[0].S_objid,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_ptvars);
          OnErrorState (!(1&OMsts) || (num_ptvars != 2),     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                            wrapup);
          ptvars = (OM_p_OBJECT_LINKAGE) alloca (num_ptvars *
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = members[0].S_objid,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = ptvars,
                                           size = num_ptvars,
                                           count = &num_ptvars);
          for(cnt = 0; cnt < num_ptvars; cnt++)
          {
             vgpts[cnt] = ptvars[cnt].S_objid;
          }
          GetPtvarsCommonGeomid ( vgpts[0], vgpts[1], os, &geom_id);
          OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          *geom_id_out = geom_id;
wrapup:
   PW_Wrapup (PWsts, "pwGetSinglparlGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
        PWobjid       O         *geom_id_out

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetRadialGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  PWobjid *geom_id_out
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWobjid		geom_id,mgr;
          OMuint		num_members;
	  OM_S_OBJECT_LINKAGE   *ptvars;
          OMuint		num_ptvars;


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          geom_id =  PW_K_NullObjid ;    
          *geom_id_out =  PW_K_NullObjid ;    

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKradial_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &chan_to_members,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || (num_members != 1),     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &chan_to_members,
                                           list = members,
                                           size = 1,
	               		           count = &num_members);
          
          num_ptvars = 0;
          OMsts = om$get_channel_count(objid = members[0].S_objid,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_ptvars);
          OnErrorState (!(1&OMsts) || (num_ptvars != 2),     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                            wrapup);
          ptvars = (OM_p_OBJECT_LINKAGE) alloca (num_ptvars *
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = members[0].S_objid,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = ptvars,
                                           size = num_ptvars,
                                           count = &num_ptvars);
          for(cnt = 0; cnt < num_ptvars; cnt++)
          {
             vgpts[cnt] = ptvars[cnt].S_objid;
          }
          GetPtvarsCommonGeomid ( vgpts[0], vgpts[1], os, &geom_id);
          OnErrorState ((geom_id ==  PW_K_NullObjid),     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          *geom_id_out = geom_id;
wrapup:
   PW_Wrapup (PWsts, "pwGetRadialGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetStackedGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          OMuint		        num_members;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKhvptpt_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  for(cnt=0;cnt<num_members;cnt++)
	         vgpts[cnt] = members[cnt].S_objid;
             
          for(cnt = 0; cnt < num_members; cnt++)
          {
             GetPtvarsCommonGeomid ( vgpts[0], vgpts[1],os, &geom_id);
	     if(geom_id == PW_K_NullObjid)
             {
               GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
               if(num_cvids == 1)
                 geom_id = cvid[0];
               else
                 geom_id = cvid[1];
             }
             GetPtvarCoords( vgpts[cnt], os, point);
             GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
             cvpt[cnt].p_attrib = NULL;
             cvpt[cnt].props = NULL;
             pwInitCvpt (&cvpt[cnt],keypoint, point, 3, 0, 0.0, geom_id);
          }
wrapup:
   PW_Wrapup (PWsts, "pwGetStackedGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetAxisStackedGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
          enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          OMuint		num_members;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKaxisptpt_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  for(cnt=0;cnt<num_members;cnt++)
	         vgpts[cnt] = members[cnt].S_objid;
             
          for(cnt = 0; cnt < num_members; cnt++)
          {
             if(cnt < 2)
               GetPtvarsCommonGeomid ( vgpts[0], vgpts[1],os, &geom_id);
             else
               GetPtvarsCommonGeomid ( vgpts[2], vgpts[3],os, &geom_id);
	     if(geom_id == PW_K_NullObjid)
             {
               GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
               if(num_cvids == 1)
                 geom_id = cvid[0];
               else
                 geom_id = cvid[1];
             }
             GetPtvarCoords( vgpts[cnt], os, point);
             GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
             cvpt[cnt].p_attrib = NULL;
             cvpt[cnt].props = NULL;
             pwInitCvpt (&cvpt[cnt],keypoint, point, 3, 0, 0.0, geom_id);
          }
wrapup:
   PW_Wrapup (PWsts, "pwGetAxisStackedGeom");
   return (PWsts);
}


/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetAbsangleGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          OMuint		num_members;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKfixang_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || !num_members,     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  for(cnt=0;cnt<num_members;cnt++)
	         vgpts[cnt] = members[cnt].S_objid;
             
          for(cnt = 0; cnt < num_members; cnt++)
          {
             GetPtvarsCommonGeomid ( vgpts[0], vgpts[1],os, &geom_id);
	     if(geom_id == PW_K_NullObjid)
             {
               GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
               if(num_cvids == 1)
                 geom_id = cvid[0];
               else
                 geom_id = cvid[1];
             }
             GetPtvarCoords( vgpts[cnt], os, point);
             GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
             cvpt[cnt].p_attrib = NULL;
             cvpt[cnt].props = NULL;
             pwInitCvpt (&cvpt[cnt],keypoint, point, 3, 0, 0.0, geom_id);
          }
wrapup:
   PW_Wrapup (PWsts, "pwGetAbsangleGeom");
   return (PWsts);
}




/*
  ABSTRACT

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
        int           O         *num_cvpts,
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetRelangleGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  int *num_cvpts,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  int			cnt;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members;
	  PWclassid		cnstrclassid;
	  PWpoint		point;
	  enum PWtopopostype    keypoint;
	  PWobjid		geom_id,mgr;
          OMuint		        num_members;
          int                   num_cvids;
          PWobjid               cvid[2];


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success; 

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
	    
          if(cnstr_id == NULL_OBJID)
          {
            PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
 	    goto wrapup; 
          }
	  OMsts = om$get_classid (objid = cnstr_id, osnum = os,
					  p_classid = &cnstrclassid);
	  if (!(1&OMsts) || (cnstrclassid != OPP_SKrelang_class_id))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
  	  OMsts = om$send (msg = message SKconstraint.SKgetmgr (&OMmsg, &mgr),
             					targetid = cnstr_id,
             					targetos = os,
             					senderid = NULL_OBJID);
          if (!(1&OMsts&OMmsg) || (mgr == NULL_OBJID))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }

          num_members = 0;
          OMsts = om$get_channel_count(objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &to_ptvars,
                                       count = &num_members);
          OnErrorState (!(1&OMsts) || (num_members > 4 || num_members < 3),     
                            PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                            wrapup);
          members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                               sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
	  for(cnt=0;cnt<num_members;cnt++)
	         vgpts[cnt] = members[cnt].S_objid;
	  for(cnt=0;cnt<num_members;cnt++)
              printf("vgpts = %d\n",vgpts[cnt]);
          *num_cvpts = num_members;   
	  if(num_members == 3)
          {
            for(cnt = 0; cnt < 3; cnt++)
            {
             if(cnt < 2)
               GetPtvarsCommonGeomid ( vgpts[0], vgpts[1],os, &geom_id);
             else
               GetPtvarsCommonGeomid ( vgpts[0], vgpts[2],os, &geom_id);
	     if(geom_id == PW_K_NullObjid)
             {
               GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
               if(num_cvids == 1)
                 geom_id = cvid[0];
               else
                 geom_id = cvid[1];
             }
             GetPtvarCoords( vgpts[cnt], os, point);
             GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
             cvpt[cnt].p_attrib = NULL;
             cvpt[cnt].props = NULL;
             pwInitCvpt (&cvpt[cnt],keypoint, point, 3, 0, 0.0, geom_id);
            }
          }
	  else
          {
            for(cnt = 0; cnt < 4; cnt++)
            {
             if(cnt < 2)
               GetPtvarsCommonGeomid ( vgpts[0], vgpts[1],os, &geom_id);
             else
               GetPtvarsCommonGeomid ( vgpts[2], vgpts[3],os, &geom_id);
	     if(geom_id == PW_K_NullObjid)
             {
               GetPtvarGeomid( vgpts[cnt], os, &num_cvids,cvid);
               if(num_cvids == 1)
                 geom_id = cvid[0];
               else
                 geom_id = cvid[1];
             }
             GetPtvarCoords( vgpts[cnt], os, point);
             GetPtvarKeypoint( vgpts[cnt], os, geom_id, &keypoint);
             cvpt[cnt].p_attrib = NULL;
             cvpt[cnt].props = NULL;
             pwInitCvpt (&cvpt[cnt],keypoint, point, 3, 0, 0.0, geom_id);
            }
          }
wrapup:
   PW_Wrapup (PWsts, "pwGetRelangleGeom");
   return (PWsts);
}

PWresult pwGetDimConstraintProps
(
  PWobjid cnstr_id,
  PWosnum os,
  PWboolean *is_clockwise,
  PWboolean *is_negative_axis,
  PWboolean *is_supplement
)
{
    long      OMmsg = EMS_S_Success;
    PWresult  PWsts = PW_K_Success;
    long      OMsts = OM_S_SUCCESS;
    unsigned short     vprops = NULL;
   
 
    *is_clockwise = FALSE;
    *is_negative_axis = FALSE;
    *is_supplement = FALSE;

    OMsts = om$send (msg = message SKconstraint.SKgetprops (&OMmsg, &vprops),
                              targetid = cnstr_id,
                              targetos = os,
                              senderid = NULL_OBJID);
    if (!(1&OMsts&OMmsg))
    {
       PWsts = SetError (PW_K_Pathway, PW_K_Internal);
       goto wrapup;
    }
    if (vprops &  SK_CLOCKWISE_ANGLE)
       *is_clockwise = TRUE;
    else
       *is_clockwise = FALSE;

    if (vprops &   SK_NEGATIVE_AXIS)
       *is_negative_axis = TRUE;
    else
       *is_negative_axis = FALSE;

    if (vprops &   SK_SUPPLEMENT)
       *is_supplement = TRUE;
    else
       *is_supplement = FALSE;

wrapup:
  PW_Wrapup (PWsts, "pwGetDimConstraintProps");
   return (PWsts);
 
}

static PWresult GetPtvarCoords
(
  PWobjid vgpts,
  PWosnum os,
  PWpoint point
)
{
          long                  OMsts,OMmsg,PWsts;
          OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
          OM_S_CHANSELECT       chan_to_geoms;
          PWpoint               newpoint;


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);

	  /** Determine the coordinates corresponding to the ptvar ***/
          OMsts = om$send (msg = message SKvariable.SKgetvar (&OMmsg,
                           NULL, NULL, NULL, newpoint),
                           targetid = vgpts,
	                   targetos = os,
			   senderid = NULL_OBJID);
	  if (!(1&OMsts&OMmsg))
	  {
	      PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	      goto wrapup;
	  }
	  memcpy(point,newpoint,sizeof(PWpoint));

wrapup:

   PW_Wrapup (PWsts, "GetPtvarCoords");
   return (PWsts);

}


static PWresult GetPtvarKeypoint(
  PWobjid vgpts,
  PWosnum os,
  PWobjid geom_id,
  enum PWtopopostype  *keypoint
)
{
          long                  OMsts,OMmsg,PWsts;
          OMuint                num_sub_members;
          OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
          OM_S_CHANSELECT       chan_to_geoms;
          OM_S_OBJECT_LINKAGE   *sub_members;
          PWclassid             sk_classid;


          OMmsg = EMS_S_Success;
          OMsts = OM_S_SUCCESS;
          PWsts = PW_K_Success;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);

          OMsts = om$get_channel_count(objid = geom_id,
                                       osnum = os,
                                       p_chanselect = &chan_to_defpts,
                                       count = &num_sub_members);
          OnErrorState (!(1&OMsts) || !num_sub_members,     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
          sub_members=(OM_p_OBJECT_LINKAGE)alloca(num_sub_members*
                                           sizeof(OM_S_OBJECT_LINKAGE));
          OMsts = om$get_channel_objects(objid = geom_id,
                                         osnum = os,
                                         p_chanselect = &chan_to_defpts,
                                         list = sub_members,
               			         size = num_sub_members,
                                         count = &num_sub_members);
          OMsts = om$get_classid (objid = geom_id,
                                  osnum = os,
                                  p_classid = &sk_classid);
          if (!(1&OMsts))
          {
              PWsts = SetError (PW_K_Pathway, PW_K_Internal);
              goto wrapup;
          }
          if(om$is_ancestry_valid (subclassid = sk_classid,
                      superclassid = OPP_SKpoint_class_id) == OM_S_SUCCESS)
          {
              *keypoint = PWtopopos_start;
          }
          if(om$is_ancestry_valid (subclassid = sk_classid,
                superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
          {
              if(vgpts== sub_members[0].S_objid)
                   *keypoint = PWtopopos_start;
              else
                   *keypoint = PWtopopos_stop;
          }
          if(om$is_ancestry_valid (subclassid = sk_classid,
                superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS)
          { 
              if(vgpts == sub_members[0].S_objid)
                   *keypoint = PWtopopos_start;
              else
              {
                 if(vgpts == sub_members[1].S_objid)
                      *keypoint = PWtopopos_middle;
                 else
                      *keypoint = PWtopopos_stop;
              }
          }
          if(om$is_ancestry_valid (subclassid = sk_classid,
                superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS)
          { 
                      *keypoint = PWtopopos_middle;
          }
          if(om$is_ancestry_valid (subclassid = sk_classid,
                superclassid = OPP_SKbspline_class_id) == OM_S_SUCCESS)
          { 
              if(vgpts== sub_members[0].S_objid)
                   *keypoint = PWtopopos_start;
              else
                   *keypoint = PWtopopos_stop;
          }
wrapup:

   PW_Wrapup (PWsts, "GetPtvarKeypoint");
   return (PWsts);

}

static PWresult GetPtvarGeomid(
  PWobjid vgpts,
  PWosnum os,
  int *num_cvids,
  PWobjid *cvid
)
{
          long                  OMsts,PWsts;
          OMuint                num_members;
          int                   cnti;
          OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
          OM_S_CHANSELECT       chan_to_geoms;
          OM_S_OBJECT_LINKAGE   *members;


          OMsts = OM_S_SUCCESS;
	  PWsts = PW_K_Success;

          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
	  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
	  EMmake_chanselect (SKinterface_to_member_constrs, 
                             &chan_to_members);
	  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);


            /** Get all the geometries to which the SKptvar is connected ***/
            num_members = 0;
            OMsts = om$get_channel_count(objid = vgpts,
                                         osnum = os,
                                         p_chanselect = &chan_to_geoms,
                                         count = &num_members);
            OnErrorState (!(1&OMsts) || !num_members,     
                     PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
            members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                               sizeof(OM_S_OBJECT_LINKAGE));
	    OMsts = om$get_channel_objects(objid = vgpts,
			                 osnum = os,
					 p_chanselect = &chan_to_geoms,
					 list = members,
					 size = num_members,
					 count = &num_members);
            for(cnti = 0; cnti < num_members; cnti++)
            {
               cvid[cnti] = members[cnti].S_objid;
            }
            *num_cvids = num_members;
wrapup:

   PW_Wrapup (PWsts, "GetPtvarGeomid");
   return (PWsts);

}

static PWresult GetPtvarsCommonGeomid
(
  PWobjid vgpt1,
  PWobjid vgpt2,
  PWosnum os,
  PWobjid *geom_id
)
{
          int cnt,cnti,k,num_cvids,loc_num_cvids[2];
          PWobjid cvid[2];
          PWobjid loc_cvids[2][2];
          PWobjid vgpts[2];
	  long PWsts;
	 
          PWsts = PW_K_Success; 

          *geom_id =  PW_K_NullObjid;
          vgpts[0] = vgpt1;
          vgpts[1] = vgpt2;
          for(cnt = 0; cnt < 2; cnt++)
          {
            GetPtvarGeomid(vgpts[cnt], os, &num_cvids, cvid);
            loc_num_cvids[cnt] = num_cvids;
            for(cnti = 0; cnti < num_cvids; cnti++)
            {
              loc_cvids[cnt][cnti] = cvid[cnti];
            }
          }
	  if((loc_num_cvids[0] == 1) && (loc_num_cvids[1] == 1))
          {
             if(loc_cvids[0][0] == loc_cvids[1][0])
               *geom_id = loc_cvids[0][0];
             else
               OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, 
			PW_K_InvalidArg), wrapup);
          }
          else if((loc_num_cvids[0] == 1) && (loc_num_cvids[1] == 2))
          {
             if(loc_cvids[0][0] == loc_cvids[1][0])
                     *geom_id = loc_cvids[0][0];
             else if(loc_cvids[0][0] == loc_cvids[1][1])
                     *geom_id = loc_cvids[0][0];
             else
               OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, 
			PW_K_InvalidArg), wrapup);
          }
          else if((loc_num_cvids[1] == 1) && (loc_num_cvids[0] == 2))
          {
             if(loc_cvids[1][0] == loc_cvids[0][0])
                     *geom_id = loc_cvids[1][0];
             else if(loc_cvids[1][0] == loc_cvids[0][1])
                     *geom_id = loc_cvids[1][0];
             else
               OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, 
			PW_K_InvalidArg), wrapup);
          }
          else if((loc_num_cvids[0] == 2) && (loc_num_cvids[1] == 2))
          {
            for( k = 0; k < 2; k++)
            {
              if(loc_cvids[0][k] == loc_cvids[1][0])
              {
                  *geom_id = loc_cvids[1][0];
                  goto wrapup;
              }
              else if(loc_cvids[0][k] == loc_cvids[1][1])
              {
                  *geom_id= loc_cvids[1][1];
                  goto wrapup;
              }
            }
       
            OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                          wrapup);
          }
wrapup:
   PW_Wrapup (PWsts, "GetPtvarsCommonGeomid");
   return (PWsts);
}
end implementation SKmgr;

