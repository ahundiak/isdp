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
#include "PWapi/cnstrqry.h"

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
extern PWclassid OPP_SKaxisptpt_class_id;

from SKvariable   import SKgetvar;
from SKconstraint import SKgetmgr,SKgetprops;
from SKexplicit   import SKgetval;


/*
  ABSTRACT
        The API gets all the  constraints on the profile. The objects ids
	of the constraints are given out.


  NOTES
	Proper memory allocation should be done by the user. Another API 
	PWNumProfileConstraints can be used to get the required memory.

  ARGUMENTS
	PWobjid       I		profile_id
	PWosnum       I		os
        PWobjid	      O		*constraints

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult  pwGetProfileConstraints
(
  PWobjid profile_id,
  PWosnum os,
  PWobjid *constraints
)
{
  	long			OMsts,PWsts;
        OM_S_CHANSELECT         chan_to_cnstrs,chan_to_comps,chan_to_memcnstr;
        OM_S_OBJECT_LINKAGE     *comp_list,*cnstr_list;
	int			cnt,cnti,j;
	GRclassid		sk_classid,cnstr_classid;
        OMuint			count,icount;

        OMsts = OM_S_SUCCESS;
        PWsts = PW_K_Success; 
	EMmake_chanselect (SKmgr_to_constrs, &chan_to_cnstrs);
	EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
	EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_memcnstr);
        count = 0;
        icount = 0;

        OMsts = om$get_classid (objid = profile_id, osnum = os,
                                p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

        /*
         * Error out if the input is not a profile
         */
        if (sk_classid != OPP_SKmgr_class_id) 
        {
           PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
           goto wrapup;
        }
   
	OMsts = om$get_channel_count ( objid = profile_id, 
				       osnum = os,
				       p_chanselect = &chan_to_cnstrs,
				       count = &count);
        if (!(1&OMsts) || !(count))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
    	comp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * 
				sizeof ( OM_S_OBJECT_LINKAGE ) );
        OMsts = om$get_channel_objects (list = comp_list, 
				           size = count,
                                       	   count = &count,
                                           objid = profile_id,
					   osnum = os,
                                           p_chanselect = &chan_to_cnstrs);
	if (!(1&OMsts))
	{
	      PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	      goto wrapup;
	}
	for(cnti=0,cnt=0;cnt<count;cnt++)
        {
          OMsts = om$get_classid (objid = comp_list[cnt].S_objid, 
                                  osnum = os,
                                  p_classid = &cnstr_classid);
          if(cnstr_classid == OPP_SKequal_class_id)
          {
	     OMsts = om$get_channel_count ( objid = comp_list[cnt].S_objid, 
				            osnum = os,
				            p_chanselect = &chan_to_comps,
				            count = &icount);
             if(!icount)
               continue;
          }
          /** If the constraint type is SKifcol, then we need to give out the
	      actual SKcollinear constraints as output and also if the
              class id is SKifequal we need to give out the actual
              SKequal constraints as output **/

          if((cnstr_classid == OPP_SKifcol_class_id)|| 
			(cnstr_classid == OPP_SKifequal_class_id))
          {
	     OMsts = om$get_channel_count ( objid = comp_list[cnt].S_objid, 
				            osnum = os,
				            p_chanselect = &chan_to_memcnstr,
				            count = &icount);
    	     cnstr_list = (OM_S_OBJECT_LINKAGE *)alloca ( icount * 
				sizeof ( OM_S_OBJECT_LINKAGE ) );
             OMsts = om$get_channel_objects (list = cnstr_list, 
				           size = icount,
                                       	   count = &icount,
                                           objid = comp_list[cnt].S_objid,
					   osnum = os,
                                           p_chanselect = &chan_to_memcnstr);
             for(j=0;j<icount;j++)
             {
                constraints[cnti++] = cnstr_list[j].S_objid;
             }
             continue;
          }
	  constraints[cnti++] = comp_list[cnt].S_objid;
        }
wrapup:
   PW_Wrapup (PWsts, "pwGetProfileConstraints");
   return (PWsts);
}

/*
  ABSTRACT
	The API extracts the geometry of the profile which is constrained
	by the given constraint.

  DESCRIPTION
	It takes the constraint as the input, and extracts the geometric
	details of the profile on which the constraint is placed. The
	coordinates of the points , the geometric element and the keypoints
	on the geometric element are computed and returned.

  NOTES

  ARGUMENTS
	PWobjid       I		cnstr_id
	PWosnum       I		os
	PWcvpt	      O		*cvpt

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwGetConstraintGeom 
(
  PWobjid cnstr_id, 
  PWosnum os,
  int  *num_cvpts,
  struct PWcvpt *cvpt
)
{
  	  long			OMsts,OMmsg,PWsts;
          PWobjid	        vgpts[4];
	  OMuint		num_members,num_sub_members;
	  int			cnt,cnt1,cnti,num_pts,num_vgpts;
	  OM_S_CHANSELECT       chan_to_defpts,chan_to_members,to_ptvars;
	  OM_S_CHANSELECT       chan_to_geoms;
	  OM_S_OBJECT_LINKAGE   *members,*sub_members;
	  PWclassid		sk_classid,cnstrclassid;
	  PWpoint		point[4],newpoint;
          PWobjid		cvids[4][2];
	  enum PWtopopostype    keypoint[4];
	  PWobjid		geom_id[2],mgr,tmpvgpt;
          int                   num_geoms[4];


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
	  if (!(1&OMsts))
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
	  if(num_members)
          {
            members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
            OMsts = om$get_channel_objects(objid = cnstr_id,
                                           osnum = os,
                                           p_chanselect = &to_ptvars,
                                           list = members,
                                           size = num_members,
	               		           count = &num_members);
            if(!(om$is_ancestry_valid (subclassid = cnstrclassid,
                 superclassid = OPP_SKequal_class_id) == OM_S_SUCCESS))
            {
	      for(cnt=0;cnt<num_members;cnt++)
	         vgpts[cnt] = members[cnt].S_objid;
	      num_vgpts = num_members;

              /** Collinear Constraint  comes under 3 point case .
	          All other 3 point cases have the common vgpt as the first 
		  vgpt hence swap the vgpts to have common vgpt as the first
	          one for collinear also **/
              if((om$is_ancestry_valid (subclassid = cnstrclassid,
                 superclassid = OPP_SKcollinear_class_id) == OM_S_SUCCESS))
              {
                  tmpvgpt = vgpts[0];
                  vgpts[0] = vgpts[1];
                  vgpts[1] = tmpvgpt;
              }
	    }
            else
	    {
	       /** Processing of Equality Constraint **/
               num_pts = 0;
               for(cnt=0;cnt<num_members;cnt++)
               {
                 num_sub_members = 0;
                 OMsts = om$get_channel_count(objid = members[cnt].S_objid,
                                              osnum = os,
                                              p_chanselect = &to_ptvars,
                                              count = &num_sub_members);
		 if (!num_sub_members)
		 {
		    PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		    goto wrapup;
		 }
                 sub_members = (OM_p_OBJECT_LINKAGE) alloca (num_sub_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
                 OMsts = om$get_channel_objects(objid = members[cnt].S_objid,
                                                osnum = os,
                                                p_chanselect = &to_ptvars,
                                                list = sub_members,
                                                size = num_sub_members,
	               	         	        count = &num_sub_members);
		 for(cnt1=0;cnt1<num_sub_members;cnt1++)
		   vgpts[num_pts+cnt1] = sub_members[cnt1].S_objid;
		 num_pts += num_sub_members;
	       }
	       num_vgpts = num_pts;
	    }
          }
	  else
          {
	    /*** Process other constraints which are super constraints ***/
            num_members = 0;
            OMsts = om$get_channel_count(objid = cnstr_id,
                                         osnum = os,
                                         p_chanselect = &chan_to_members,
                                         count = &num_members);
	    if (!num_members)
	    {
	      PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	      goto wrapup;
	    }
            members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
	    OMsts = om$get_channel_objects(objid = cnstr_id,
					   osnum = os,
					   p_chanselect = &chan_to_members,
					   list = members,
					   size = num_members,
					   count = &num_members);
            if(!(om$is_ancestry_valid (subclassid = cnstrclassid,
                 superclassid = OPP_SKifcol_class_id) == OM_S_SUCCESS))
            {
              num_pts = 0;
              for(cnt=0;cnt<num_members;cnt++)
              {
                 num_sub_members = 0;
                 OMsts = om$get_channel_count(objid = members[cnt].S_objid,
                                              osnum = os,
                                              p_chanselect = &to_ptvars,
                                              count = &num_sub_members);
	         if (!num_sub_members)
	         {
	           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	           goto wrapup;
	         }
                 sub_members = (OM_p_OBJECT_LINKAGE) alloca (num_sub_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
                 OMsts = om$get_channel_objects(objid = members[cnt].S_objid,
                                                osnum = os,
                                                p_chanselect = &to_ptvars,
                                                list = sub_members,
                                                size = num_sub_members,
                                                count = &num_sub_members);
                 for(cnt1=0;cnt1<num_sub_members;cnt1++)
                   vgpts[num_pts+cnt1] = sub_members[cnt1].S_objid;
                 num_pts += num_sub_members;
              }
              num_vgpts = num_pts;
            }
            else
            {
              num_pts = 0;
              for(cnt=0;cnt<num_members;cnt++)
              {
                 num_sub_members = 0;
                 OMsts = om$get_channel_count(objid = members[cnt].S_objid,
                                              osnum = os,
                                              p_chanselect = &to_ptvars,
                                              count = &num_sub_members);
	         if (!num_sub_members)
	         {
	           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	           goto wrapup;
	         }
                 sub_members = (OM_p_OBJECT_LINKAGE) alloca (num_sub_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
                 OMsts = om$get_channel_objects(objid = members[cnt].S_objid,
                                                osnum = os,
                                                p_chanselect = &to_ptvars,
                                                list = sub_members,
                                                size = num_sub_members,
                                                count = &num_sub_members);
	         if(cnt==0)
                 {
                   for(cnt1=0;cnt1<num_sub_members;cnt1++)
                     vgpts[cnt1] = sub_members[cnt1].S_objid;
                 }
                 else
                 {
                    vgpts[3] = sub_members[2].S_objid;
                    num_pts = num_sub_members + 1;
                 }
              }
              num_vgpts = num_pts;
	    }
          }
          /** All the SKptvars comprising the constraint are ready now 
	      get the corresponding values of the points ***/
	  for(cnt=0;cnt<num_vgpts;cnt++)
          {
	     /** Determine the coordinates corresponding to the ptvar ***/
             OMsts = om$send (msg = message SKvariable.SKgetvar (&OMmsg,
                              NULL, NULL, NULL, newpoint),
                              targetid = vgpts[cnt],
			      targetos = os,
			      senderid = NULL_OBJID);
	     if (!(1&OMsts&OMmsg))
	     {
	         PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	         goto wrapup;
	     }
	     memcpy(point[cnt],newpoint,sizeof(PWpoint));
          }

          /** Get all the geometries to which the SKptvars are connected ***/
	  for(cnt=0;cnt<num_vgpts;cnt++)
          {
             /** Determine the geometry on which the ptvars lie ***/
             num_members = 0;
             OMsts = om$get_channel_count(objid = vgpts[cnt],
                                          osnum = os,
                                          p_chanselect = &chan_to_geoms,
                                          count = &num_members);
	     if (!num_members)
	     {
	        PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	        goto wrapup;
	     }
             members = (OM_p_OBJECT_LINKAGE) alloca (num_members *
                                sizeof(OM_S_OBJECT_LINKAGE));
	     OMsts = om$get_channel_objects(objid = vgpts[cnt],
					    osnum = os,
					    p_chanselect = &chan_to_geoms,
					    list = members,
					    size = num_members,
					    count = &num_members);
             num_geoms[cnt] = num_members;
             for(cnti = 0; cnti < num_members; cnti++)
             {
               cvids[cnt][cnti] = members[cnti].S_objid;
             }
         }         
         for(cnt=0;cnt<num_vgpts;cnt++)
         {
           cvpt[cnt].p_attrib = NULL;
           cvpt[cnt].props = NULL;
         }
	 switch (num_vgpts)
	 {
                /*** Ground Constraint,Point On Element & Tangency ***/
 
		case 1:
		    if(num_geoms[0] == 1)
		      geom_id[0] = cvids[0][0];
		    else
		      geom_id[0] = cvids[0][1];
                    OMsts = om$get_channel_count(objid = geom_id[0],
                                          osnum = os,
                                          p_chanselect = &chan_to_defpts,
                                          count = &num_sub_members);
		    if (!num_sub_members)
		    {
		       PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		       goto wrapup;
		    }
                    sub_members = (OM_p_OBJECT_LINKAGE)alloca(num_sub_members *
                                               sizeof(OM_S_OBJECT_LINKAGE));
                    OMsts = om$get_channel_objects(objid = geom_id[0],
                                            osnum = os,
                                            p_chanselect = &chan_to_defpts,
                                            list = sub_members,
                                            size = num_sub_members,
                                            count = &num_sub_members);
                    OMsts = om$get_classid (objid = geom_id[0], osnum = os,
                                          p_classid = &sk_classid);
                    if (!(1&OMsts))
                    {
                      PWsts = SetError (PW_K_Pathway, PW_K_Internal);
                      goto wrapup;
                    }
                    if((om$is_ancestry_valid (subclassid = sk_classid,
                           superclassid = OPP_SKline_class_id) == OM_S_SUCCESS))
                    {
                       printf("Entered line case\n");
                       if(vgpts[0] == sub_members[0].S_objid)
                          keypoint[0] = PWtopopos_start;
                       else
                          keypoint[0] = PWtopopos_stop;
                    }
                    if((om$is_ancestry_valid (subclassid = sk_classid,
                           superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS))
                    {
                       printf("Entered arc case\n");
                      if(vgpts[0] == sub_members[0].S_objid)
                        keypoint[0] = PWtopopos_start;
                      else 
                      {
                        if(vgpts[0] == sub_members[1].S_objid)
                           keypoint[0] = PWtopopos_middle;
                      	else
                           keypoint[0] = PWtopopos_stop;
                      }
                    }
                    printf("Entered else case\n");
                    printf("keypnt = %d\n", keypoint[0]);
                    pwInitCvpt (&cvpt[0], keypoint[0], 
				point[0], 3, 0, 0.0, geom_id[0]);
		    break;
		case 2:
		    if(!(om$is_ancestry_valid (subclassid = cnstrclassid,
                         superclassid = OPP_SKhvptpt_class_id) == OM_S_SUCCESS))
 	            {
		      if(num_geoms[0] == 1)
		        geom_id[0] = cvids[0][0];
		      else if(num_geoms[1] == 1)
		        geom_id[0] = cvids[1][0];
		      else
		      {
		        for (cnt=0; cnt<num_vgpts; cnt++)
                          for (cnti=0; cnti<num_geoms[cnt]; cnti++)
                            if (cvids[0][cnt] == cvids[1][cnti])
                              geom_id[0] = cvids[0][cnt];
      		      }
      		      OMsts = om$get_channel_count(objid = geom_id[0],
                                                 osnum = os,
                                                 p_chanselect = &chan_to_defpts,
                                                 count = &num_sub_members);
		      if (!num_sub_members)
		      {
		         PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		         goto wrapup;
		      }
                      sub_members =(OM_p_OBJECT_LINKAGE)alloca(num_sub_members *
                                               sizeof(OM_S_OBJECT_LINKAGE));
                      OMsts = om$get_channel_objects(objid = geom_id[0],
                                               osnum = os,
                                               p_chanselect = &chan_to_defpts,
                                               list = sub_members,
                                               size = num_sub_members,
                                               count = &num_sub_members);
                      OMsts = om$get_classid (objid = geom_id[0], osnum = os,
                                              p_classid = &sk_classid);
                      if (!(1&OMsts))
                      {
                        PWsts = SetError (PW_K_Pathway, PW_K_Internal);
                        goto wrapup;
                      }
                      if((om$is_ancestry_valid (subclassid = sk_classid,
                           superclassid = OPP_SKline_class_id) == OM_S_SUCCESS))
                      {
                         if(vgpts[0] == sub_members[0].S_objid)
                         {
                            keypoint[0] = PWtopopos_start;
                            keypoint[1] = PWtopopos_stop;
                         }
                         else
                         {
                            keypoint[0] = PWtopopos_stop;
                            keypoint[1] = PWtopopos_start;
                         }
                      }
                      if((om$is_ancestry_valid (subclassid = sk_classid,
                           superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS))
                      {
                        if(vgpts[0] == sub_members[0].S_objid)
                        {
                          keypoint[0] = PWtopopos_start;
                          keypoint[1] = PWtopopos_middle;
                        }
                        else
                        {
                          keypoint[0] = PWtopopos_middle;
                          keypoint[1] = PWtopopos_start;
                        }
                      }
                      pwInitCvpt (&cvpt[0], keypoint[0], 
				point[0], 3, 0, 0.0, geom_id[0]);
                      pwInitCvpt (&cvpt[1],keypoint[1], 
				point[1], 3, 0, 0.0, geom_id[0]);
                    }
                    else
                    {
                      for(cnt = 0; cnt < num_vgpts; cnt++)
                      {
                      	if(num_geoms[cnt] == 1)
		          geom_id[cnt] = cvids[cnt][0];
		        else
		          geom_id[cnt] = cvids[cnt][1];
                        OMsts = om$get_channel_count(objid = geom_id[cnt],
                                                 osnum = os,
                                                 p_chanselect = &chan_to_defpts,
                                                 count = &num_sub_members);
		        if (!num_sub_members)
		        {
		           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		           goto wrapup;
		        }
                        sub_members=(OM_p_OBJECT_LINKAGE)alloca(num_sub_members*
                                               sizeof(OM_S_OBJECT_LINKAGE));
                        OMsts = om$get_channel_objects(objid = geom_id[cnt],
                                                 osnum = os,
                                            	 p_chanselect = &chan_to_defpts,
                                            	 list = sub_members,
                                            	 size = num_sub_members,
                                                 count = &num_sub_members);
                        OMsts = om$get_classid (objid = geom_id[cnt], 
					        osnum = os,
                                                p_classid = &sk_classid);
                        if (!(1&OMsts))
                        {
                          PWsts = SetError (PW_K_Pathway, PW_K_Internal);
                          goto wrapup;
                        }
                        if((om$is_ancestry_valid (subclassid = sk_classid,
                           superclassid = OPP_SKline_class_id) == OM_S_SUCCESS))
                        {
                           if(vgpts[cnt] == sub_members[0].S_objid)
                             keypoint[cnt] = PWtopopos_start;
                           else
                             keypoint[cnt] = PWtopopos_stop;
                        }
                        if((om$is_ancestry_valid (subclassid = sk_classid,
                            superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS))
                        {
                          if(vgpts[cnt] == sub_members[0].S_objid)
                            keypoint[cnt] = PWtopopos_start;
                          else 
                          {
                            if(vgpts[cnt] == sub_members[1].S_objid)
                              keypoint[cnt] = PWtopopos_middle;
                      	    else
                              keypoint[cnt] = PWtopopos_stop;
                          }
                        }
                      }
                      pwInitCvpt (&cvpt[0],keypoint[0], 
				point[0], 3, 0, 0.0, geom_id[0]);
                      pwInitCvpt (&cvpt[1],keypoint[1], 
				point[1], 3, 0, 0.0, geom_id[1]);
                    }
	            break;
                /** Collinear Constraint*/
		case 3:
                    geom_id[0] = cvids[0][0];
/*
                    geom_id[1] = cvids[0][1];
*/
                    geom_id[1] = cvids[2][0];
                    for(cnt=0;cnt < 2; cnt++)
                    {
                      OMsts = om$get_channel_count(objid = geom_id[cnt],
                                               osnum = os,
                                               p_chanselect = &chan_to_defpts,
                                               count = &num_sub_members);
		      if (!num_sub_members)
		      {
		         PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		         goto wrapup;
		      }
                      sub_members =(OM_p_OBJECT_LINKAGE)alloca(num_sub_members *
                                               sizeof(OM_S_OBJECT_LINKAGE));
                      OMsts = om$get_channel_objects(objid = geom_id[cnt],
                                               osnum = os,
                                               p_chanselect = &chan_to_defpts,
                                               list = sub_members,
                                               size = num_sub_members,
                                               count = &num_sub_members);
                      OMsts = om$get_classid (objid = geom_id[cnt], osnum = os,
                                          p_classid = &sk_classid);
                      if (!(1&OMsts))
                      {
                        PWsts = SetError (PW_K_Pathway, PW_K_Internal);
                        goto wrapup;
                      }
                      if((om$is_ancestry_valid (subclassid = sk_classid,
                           superclassid = OPP_SKline_class_id) == OM_S_SUCCESS))
                      {
                        if(cnt==0)
                        {
                            if(vgpts[0] == sub_members[0].S_objid)
                            {
                              keypoint[0] = PWtopopos_start;
                              keypoint[1] = PWtopopos_stop;
                            }
                            else
                            {
                              keypoint[0] = PWtopopos_stop;
                              keypoint[1] = PWtopopos_start;
                            }
                        }
                        else
                        {
                            if(vgpts[2] == sub_members[0].S_objid)
                              keypoint[2] = PWtopopos_start;
                            else
                              keypoint[2] = PWtopopos_stop;
                        }
  	              }
                    }
                    pwInitCvpt (&cvpt[0], keypoint[0], 
				point[0], 3, 0, 0.0, geom_id[0]);
                    pwInitCvpt (&cvpt[1],keypoint[1], 
				point[1], 3, 0, 0.0, geom_id[0]);
                    pwInitCvpt (&cvpt[2], keypoint[2], 
				point[2], 3, 0, 0.0, geom_id[1]);
		    break;
		case 4:
		    if(num_geoms[0] == 1)
		      geom_id[0] = cvids[0][0];
		    else 
                    {
                      if (num_geoms[1] == 1)
		        geom_id[0] = cvids[1][0];
		      else
		      {
                        for (cnt=0; cnt<2; cnt++)
                          for (cnti=0; cnti<2; cnti++)
                            if (cvids[0][cnt] == cvids[1][cnti])
                              geom_id[0] = cvids[0][cnt];
                      }
                    }
		    if(num_geoms[2] == 1)
		      geom_id[1] = cvids[2][0];
		    else 
                    {
                      if (num_geoms[3] == 1)
		        geom_id[1] = cvids[3][0];
	              else
	              {
                        for (cnt=0; cnt<2; cnt++)
                          for (cnti=0; cnti<2; cnti++)
                            if (cvids[2][cnt] == cvids[3][cnti])
                              geom_id[1] = cvids[2][cnt];
                      }
                    }
                    for(cnt=0;cnt<2;cnt++)
                    {
                      OMsts = om$get_channel_count(objid = geom_id[cnt],
                                                 osnum = os,
                                                 p_chanselect = &chan_to_defpts,
                                                 count = &num_sub_members);
		      if (!num_sub_members)
		      {
		         PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		         goto wrapup;
		      }
                      sub_members =(OM_p_OBJECT_LINKAGE)alloca(num_sub_members *
                                               sizeof(OM_S_OBJECT_LINKAGE));
                      OMsts = om$get_channel_objects(objid = geom_id[cnt],
                                               osnum = os,
                                      	       p_chanselect = &chan_to_defpts,
                                               list = sub_members,
                                               size = num_sub_members,
                                               count = &num_sub_members);
                      OMsts = om$get_classid (objid = geom_id[cnt], osnum = os,
                                         p_classid = &sk_classid);
                      if (!(1&OMsts))
                      {
                        PWsts = SetError (PW_K_Pathway, PW_K_Internal);
                        goto wrapup;
                      }
                      if((om$is_ancestry_valid (subclassid = sk_classid,
            		   superclassid = OPP_SKline_class_id) == OM_S_SUCCESS))
                      {
                        if(cnt==0)
                        {
                          if(vgpts[0] == sub_members[0].S_objid)
                          {
                            keypoint[0] = PWtopopos_start;
                            keypoint[1] = PWtopopos_stop;
                          }
                          else
                          {
                            keypoint[0] = PWtopopos_stop;
                            keypoint[1] = PWtopopos_start;
                          }
                        }
                        else
                        {
                          if(vgpts[2] == sub_members[0].S_objid)
                          {
                            keypoint[2] = PWtopopos_start;
                            keypoint[3] = PWtopopos_stop;
                          }
                          else
                          {
                            keypoint[2] = PWtopopos_stop;
                            keypoint[3] = PWtopopos_start;
                          }
                        }
                      }
                    }       
                    pwInitCvpt (&cvpt[0], keypoint[0], 
				point[0], 3, 0, 0.0, geom_id[0]);
                    pwInitCvpt (&cvpt[1], keypoint[1], 
				point[1], 3, 0, 0.0, geom_id[0]);
                    pwInitCvpt (&cvpt[2], keypoint[2], 
				point[2], 3, 0, 0.0, geom_id[1]);
                    pwInitCvpt (&cvpt[3], keypoint[3], 
				point[3], 3, 0, 0.0, geom_id[1]);
	            break;
		default: 
		    break;
	 }
         *num_cvpts = num_vgpts;
wrapup:

   PW_Wrapup (PWsts, "pwGetConstraintGeom");
   return (PWsts);
}

/*
  ABSTRACT 
	This API gives the number of constraints on the profile.
	This can be used for allocating the memory for constraints
	before calling the pwGetConstraintsGeom API.

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid      I		profile_id
	PWosnum      I		os

  RETURN CODE
     int	      - Number of components 

  KEYWORDS


  CAVEATS
 
  HISTORY

     Satya   02/26/96   Creation 

*/

int pwNumProfileConstraints 
( 
  PWobjid profile_id,
  PWosnum os
)
{

  	long			OMsts,PWsts;
        OM_S_CHANSELECT         chan_to_cnstrs,chan_to_comps,chan_to_memcnstr;
        OM_S_OBJECT_LINKAGE     *comp_list;
	int			cnt,num_cnstrs;
	GRclassid		sk_classid,cnstr_classid;
        OMuint			count,icount;

        OMsts = OM_S_SUCCESS;
        PWsts = PW_K_Success;
 
	EMmake_chanselect (SKmgr_to_constrs, &chan_to_cnstrs);
	EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
	EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_memcnstr);

        count = 0;
        icount = 0;
        num_cnstrs = 0;

        OMsts = om$get_classid (objid = profile_id, osnum = os,
                                p_classid = &sk_classid);

        /*
         * Error out if the input is not a profile
         */
        if (sk_classid != OPP_SKmgr_class_id) 
        {
           PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
           goto wrapup;
        }
   
	OMsts = om$get_channel_count ( objid = profile_id, 
				       osnum = os,
				       p_chanselect = &chan_to_cnstrs,
				       count = &count);
        if (!(1&OMsts) || !(count))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
        num_cnstrs = count;
    	comp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * 
				sizeof ( OM_S_OBJECT_LINKAGE ) );
        OMsts = om$get_channel_objects (list = comp_list, 
				           size = count,
                                       	   count = &count,
                                           objid = profile_id,
					   osnum = os,
                                           p_chanselect = &chan_to_cnstrs);
	if (!(1&OMsts))
	{
	      PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	      goto wrapup;
	}
	for(cnt=0;cnt<count;cnt++)
        {
          OMsts = om$get_classid (objid = comp_list[cnt].S_objid, 
                                  osnum = os,
                                  p_classid = &cnstr_classid);
          if(cnstr_classid == OPP_SKequal_class_id)
          {
	     OMsts = om$get_channel_count ( objid = comp_list[cnt].S_objid, 
				            osnum = os,
				            p_chanselect = &chan_to_comps,
				            count = &icount);
             if(!icount)
               num_cnstrs--;
          }
          if((cnstr_classid == OPP_SKifequal_class_id)|| 
			(cnstr_classid == OPP_SKifcol_class_id))
          {
             num_cnstrs--;
	     OMsts = om$get_channel_count ( objid = comp_list[cnt].S_objid, 
				            osnum = os,
				            p_chanselect = &chan_to_memcnstr,
				            count = &icount);
             num_cnstrs += icount;
          }
        }
wrapup:
	return(num_cnstrs);
}

/*
  ABSTRACT
	Given a Constraint objid, the API outputs the type of constraint.

  DESCRIPTION
	Given a constraint's objid, the API gives out its type by checking
	the class of the constraint.

  NOTES

  ARGUMENTS
	PWobjid 		cnstr_id
	PWosnum 		os

  RETURN CODE
        enum PWprfcnstrtype  
        
  HISTORY

     Satya   02/26/96   Creation 

*/

enum PWprfcnstrtype  pwConstraintType  
(
  PWobjid cnstr_id,
  PWosnum os
)
{
	  PWclassid		sk_classid = 0;
          long 			OMmsg;
          IGRushort 		vprops = NULL;

          sk_classid = omClassidFromObjid (cnstr_id, os);

          if (omIsAncestryValid (sk_classid, OPP_SKhorizvert_class_id))
          {
            om$send (msg = message SKconstraint.SKgetprops (&OMmsg, &vprops),
                     targetid = cnstr_id,
                     targetos = os,
                     senderid = NULL_OBJID);
            if (vprops &  SK_HORIZONTAL)
                return(PWprfcnstr_horizontal);
            else
                return(PWprfcnstr_vertical);

          }
          if (omIsAncestryValid (sk_classid, OPP_SKrelang_class_id))
                return(PWprfcnstr_relangular);
          if (omIsAncestryValid (sk_classid, OPP_SKfixang_class_id))
          {
            om$send (msg = message SKconstraint.SKgetprops (&OMmsg, &vprops),
                     targetid = cnstr_id,
                     targetos = os,
                     senderid = NULL_OBJID);
            if (vprops &  SK_HORIZONTAL)
                return(PWprfcnstr_horzabsangular);
            else
                return(PWprfcnstr_vertabsangular);
          } 
          if (omIsAncestryValid (sk_classid, OPP_SKcoincident_class_id))
                return(PWprfcnstr_coincident);
          if (omIsAncestryValid (sk_classid, OPP_SKcollinear_class_id))
                return(PWprfcnstr_collinear);
          if (omIsAncestryValid (sk_classid, OPP_SKequal_class_id))
                return(PWprfcnstr_equality);
          if (omIsAncestryValid (sk_classid, OPP_SKasptgrnd_class_id))
                return(PWprfcnstr_ground);
          if (omIsAncestryValid (sk_classid, OPP_SKhvptpt_class_id))
          {
            om$send (msg = message SKconstraint.SKgetprops (&OMmsg, &vprops),
                     targetid = cnstr_id,
                     targetos = os,
                     senderid = NULL_OBJID);
            if (vprops &  SK_HORIZONTAL)
                return(PWprfcnstr_horizontal_dim);
            else
                return(PWprfcnstr_vertical_dim);
          }
          if (omIsAncestryValid (sk_classid, OPP_SKnormal_class_id))
                return(PWprfcnstr_normal);
          if (omIsAncestryValid (sk_classid, OPP_SKparallel_class_id))
                return(PWprfcnstr_parallel);
          if (omIsAncestryValid (sk_classid, OPP_SKptonelmt_class_id))
                return(PWprfcnstr_ptonelmt);
          if (omIsAncestryValid (sk_classid, OPP_SKradial_class_id))
                return(PWprfcnstr_radial);
          if (omIsAncestryValid (sk_classid, OPP_SKifptpt_class_id))
                return(PWprfcnstr_singleparl_dim);
          if (omIsAncestryValid (sk_classid, OPP_SKtangency_class_id))
                return(PWprfcnstr_tangency);
          if (omIsAncestryValid (sk_classid, OPP_SKaxisptpt_class_id))
          { 
            om$send (msg = message SKconstraint.SKgetprops (&OMmsg, &vprops),
                     targetid = cnstr_id,
                     targetos = os,
                     senderid = NULL_OBJID);
            if (vprops &  SK_HORIZONTAL)
                return(PWprfcnstr_axis_horizontal_dim);
            else
                return(PWprfcnstr_axis_vertical_dim);
          }
          return(PWprfcnstr_invalid);
}

/*
  ABSTRACT
	Given a Dimensional Constraint the value of the dimension is output.

  NOTES
  Both angular and linear Dimension values are output as doubles. Angular 
  dimension value is ouput in degress.

  ARGUMENTS
	PWobjid 		dimcnstr_id
	PWosnum 		os

  RETURN CODE
	double                  on success
	MAXDOUBLE		on failure

  CAVEATS
	Need to handle expressions . 

  HISTORY

     Satya   02/26/96   Creation 

*/

double pwDimConstraintVal 
(
  PWobjid dimcnstr_id, 
  PWosnum os
)
{
  	long		OMsts,OMmsg;
	double		loc_ang;

        OMmsg = EMS_S_Success;
        OMsts = OM_S_SUCCESS;

  	OMsts   = om$send (msg = message SKexplicit.SKgetval(&OMmsg,&loc_ang),
              			 targetid = dimcnstr_id,
				 targetos = os,
				 senderid = NULL_OBJID);
        if (!(1&OMsts&OMmsg))
	   return(MAXDOUBLE);
	else
	   return(loc_ang);
}

/*
  ABSTRACT
	Given a constraint the API outputs whether the given constraint
	is a Dimensional Constraint or not.

  ARGUMENTS
	PWobjid 		csntr_id
	PWosnum 		os

  RETURN CODE
	TRUE			If constraint is dimensional
        FALSE			If constraint is not dimensional

  HISTORY

     Satya   02/26/96   Creation 

*/

PWboolean pwIsDimConstraint  
(
  PWobjid cnstr_id,
  PWosnum os
)
{
  	  long			OMsts;
	  PWclassid		sk_classid;

          OMsts = OM_S_SUCCESS;

          OMsts = om$get_classid (objid = cnstr_id, osnum = os,
                                p_classid = &sk_classid);
 	  if (om$is_ancestry_valid (subclassid = sk_classid,
                     superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS)
	    return(TRUE);
	  else
	    return(FALSE);
}

int pwGetDimObject
(
  PWobjid cnstr_id,
  PWosnum os,
  PWobjid *dim_id
)
{

        OM_S_CHANSELECT         chan_to_comps;
        OM_S_OBJECT_LINKAGE     *dim_list;
        OMuint			count;
        long			OMsts;
        PWresult                PWsts = PW_K_Success;
       
        OMsts = OM_S_SUCCESS;
        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        count = 0;

        OMsts = om$get_channel_count ( objid = cnstr_id,
                                       osnum = os,
                                       p_chanselect = &chan_to_comps,
                                       count = &count);
    	dim_list = (OM_S_OBJECT_LINKAGE *)alloca ( 
                                      sizeof ( OM_S_OBJECT_LINKAGE ) );
        if (count == 1)
        {
          OMsts = om$get_channel_objects (list = dim_list,
                                        size = count,
                                        count = &count,
                                        objid = cnstr_id,
                                        osnum = os,
                                        p_chanselect = &chan_to_comps);
          *dim_id = dim_list[0].S_objid;
        }
	else 
	{
	      PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	      goto wrapup;
	}
wrapup:
   PW_Wrapup (PWsts, "pwGetDimObject");
   return (PWsts);
}

PWresult pwGetConstraintProps
(
  PWobjid cnstr_id,
  PWosnum os,
  unsigned short *vprops
)
{
    long      OMmsg = EMS_S_Success;
    PWresult  PWsts = PW_K_Success;
    long      OMsts = OM_S_SUCCESS;
    

    OMsts = om$send (msg = message SKconstraint.SKgetprops (&OMmsg, vprops),
                              targetid = cnstr_id,
                              targetos = os,
                              senderid = NULL_OBJID);
    if (!(1&OMsts&OMmsg))
    {
       PWsts = SetError (PW_K_Pathway, PW_K_Internal);
       goto wrapup;
    }
wrapup:
  PW_Wrapup (PWsts, "pwGetConstraintProps");
  return(PWsts);
}

end implementation SKmgr;
