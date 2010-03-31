class implementation    SKmgr;

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
#include "ECmsg.h"
#include "nddef.h"
#include "ndmacros.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/gmcnstr.h"
#include "actparam.h"

extern PWclassid OPP_SKline_class_id, OPP_SKarc_class_id;
extern PWclassid OPP_SKpoint_class_id, OPP_SKcircle_class_id;
extern PWclassid OPP_SKcompcurve_class_id;
extern PWclassid OPP_SKconstraint_class_id, OPP_SKcoincident_class_id;
extern PWclassid OPP_SKifcol_class_id, OPP_SKcollinear_class_id;  
extern PWclassid OPP_SKequal_class_id,  OPP_SKifequal_class_id;  
extern PWclassid OPP_SKnormal_class_id, OPP_SKparallel_class_id;
extern PWclassid OPP_SKptonelmt_class_id, OPP_SKtangency_class_id;
extern PWclassid OPP_SKasptgrnd_class_id,OPP_SKhorizvert_class_id;
from SKconstraint import SKinit,SKvalidate,SKgetmgr;

static PWresult CreateGeomConstraint 
( 
  PWclassid cnstrclass,
  PWosnum os,
  int     num_vgpts,
  PWobjid *vgpts,
  unsigned short cnstrprops,
  char *cnstrinfo,
  PWboolean chkcycle,
  struct GRmd_env  *mod_env,
  int *num_conflict_cnstr,
  PWobjid  **conflict_cnstr,
  PWobjid *constraint
);


/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places a coincident constraint between two elements
  DESCRIPTION
	Given two elements of a profile and the keypoints of the element the
	API places the coincident constraint. The elements currently supported
	are line, circle and point. The allowed keypoints are start points for 
	all types of elements and end points for lines and arcs, and center
	point for circles and arcs.

  ARGUMENTS
 	PWobjid 		*element_id,
        enum PWtopopostype      *keypnt,
        PWosnum 		os,
        PWobjid 		**conflict_cnstr,
        int 			*num_conflict_cnstr,
        PWobjid 		*coincident

  HISTORY

     Satya   02/26/96   Creation 

*/

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwCoincidentConstraint 
( 
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *coincident
)

{
  	long			OMsts,OMmsg;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts, to_geom;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
        double		        lentol;
        int			cnt,scnt,icnt;
        PWobjid			ptvars[4];
	PWresult		PWsts ;
  	struct GRmd_env		mod_env;
	PWobjid			loc_vgpts[4];
	struct	GRid		parmele,ele;
        int			num_vgpts,sts;
	unsigned short		cnstrprops;
	PWboolean		chkcycle,flag;
        extern OMuword          EX_active_OS_num;

	OMmsg = EMS_S_Success;
	PWsts = PW_K_Success;
	OMsts = OM_S_SUCCESS;

        cnstrclass = OPP_SKcoincident_class_id;
        cnstrprops = NULL;
	chkcycle = FALSE;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
	EMmake_chanselect ( SKvariable_to_geometries, &to_geom);
  
        BSEXTRACTPAR (&OMmsg, BSTOLLENVEC, lentol);
    
        if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }

        num_vgpts = 2;
        vgpts = (PWobjid *)alloca(num_vgpts*sizeof(PWobjid));
        for(scnt = 0; scnt < 2 ; scnt++)
        {
          	OMsts = om$get_classid (objid = element_id[scnt], osnum = os,
                                  p_classid = &sk_classid);
		if (!(1&OMsts))
		{
		   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		   goto wrapup;
		}
    
	       /*
		* Error out if the element is a composite curve.
		*/
	       if (sk_classid == OPP_SKcompcurve_class_id)
	       {
		 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
		 goto wrapup;
	       }
	       /*
		* Build the list of ptvars connected to each component
		*/
		OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
						objid = element_id[scnt], 
						osnum = os,
						p_chanselect = &chan_to_defpts,
						count = &count);
		if (!(1&OMsts) || !count)
		{
		   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		   goto wrapup;
		}

		for (cnt = 0; cnt < count; cnt++)
		  ptvars[cnt] = ptlinkage[cnt].S_objid;

		switch(keypnt[scnt])
		{
		    case PWtopopos_start:
			  vgpts[scnt] = ptvars[0];
			  break;
		    case PWtopopos_stop:
			    if ((sk_classid == OPP_SKpoint_class_id)
				 || (sk_classid == OPP_SKcircle_class_id))
			    {
			      PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			      goto wrapup;
			    }
			    if (sk_classid == OPP_SKline_class_id)
			    {
				  vgpts[scnt] = ptvars[1];
			    }
			    if (sk_classid == OPP_SKarc_class_id)
			    {
				  vgpts[scnt] = ptvars[2];
			    }
			    break;
		    case PWtopopos_middle:
			    if ((sk_classid == OPP_SKpoint_class_id)
				 || (sk_classid == OPP_SKline_class_id))
			    {
			       PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			       goto wrapup;
			    }
			    if ((sk_classid == OPP_SKarc_class_id)
				 || (sk_classid == OPP_SKcircle_class_id))
			    {
				  vgpts[scnt] = ptvars[1];
			    }
			    break;
		    case PWtopopos_unknown:
			 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			 goto wrapup;
		}
        }
        parmele.objid = vgpts[0];
        parmele.osnum = os;
        ele.objid = vgpts[1];
        ele.osnum = os;

        OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                           &mod_env, &parmele, NULL, NULL, 
					   1, &ele, &icnt, &loc_vgpts);
        if (OMmsg == EMS_I_BadPlane)
        {
           PWsts = SetError(PW_K_Pathway,PW_K_NonPlanar) ;
           goto wrapup;
        }
        else if (OMmsg == EMS_I_Cycle)
        {
            PWsts = SetError(PW_K_Pathway,PW_K_Cycle) ;
            goto wrapup;
        }
	if(vgpts[0] == vgpts[1])
	{
            PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
            goto wrapup;
        }
        if (OMmsg == EMS_I_Assoc)
          chkcycle = TRUE;

        CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                         cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
                         conflict_cnstr, coincident);
wrapup:
   PW_Wrapup (PWsts, "pwCoincidentConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places a collinear  constraint.

  DESCRIPTION
	Given a set of line segments the API creates a collinear
	constraint between these elements. 

  NOTES

  ARGUMENTS
	int			num_elems;
	PWobjid 		*element_ids
	PWosnum 		os
        PWobjid		        *collinear
        PWobjid 	        **conflict_cnstr,
        int 		        *num_conflict_cnstr,

  CAVEATS
	1.  Need to handle common point cases
	2.  Need to handle cases where conflicting cases arise
 
  HISTORY

     Satya   02/26/96   Creation 

*/


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwCollinearConstraint 
( 
  int num_elems,
  PWobjid *element_ids,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *collinear
)
{
  	long			OMsts, OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          cnstrprops ;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
	int		        cnt,cntr, num_vgpts,sts;
        struct GRid		parmele,ele;
        PWboolean               chkcycle,flag;
        extern OMuword          EX_active_OS_num;

        cnstrprops = NULL;
        chkcycle = TRUE;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
  
    
       if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }

        OMsts = om$get_classid (objid = element_ids[0], osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
 
       /*
        * Error out if the element is not an SKline
        */
       if (sk_classid != OPP_SKline_class_id) 
       {
           PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
           goto wrapup;
       }
       /*
        * Build the list of ptvars connected to each component of
	* first element
        */
        OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
                                          objid = element_ids[0], 
				          osnum = os,
                                          p_chanselect = &chan_to_defpts,
                                          count = &count);
      
        if (!(1&OMsts) || !count)
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

        vgpts = (PWobjid *) alloca (4 * sizeof (PWobjid));
        vgpts[0] = ptlinkage[FIRST].S_objid;
        vgpts[1] = ptlinkage[SECOND].S_objid;
        num_vgpts = 2;
        parmele.objid = element_ids[FIRST];
	parmele.osnum = os;

	for(cntr = 1; cntr < num_elems; cntr++)
	{
	  ele.objid = element_ids[cntr];
	  ele.osnum = os;

          OMsts = om$get_classid (objid = element_ids[cntr], osnum = os,
                                  p_classid = &sk_classid);
          if (!(1&OMsts))
          {
            PWsts = SetError (PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
 
          /*
           * Error out if the element is not an SKline
           */
          if (sk_classid != OPP_SKline_class_id) 
          {
            PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
            goto wrapup;
          }
          OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                             &mod_env, &parmele, NULL, 
			                     NULL, 1, &ele, &cnt, 
					     &vgpts[num_vgpts]);
          num_vgpts += cnt;
       
	  if (OMmsg == EMS_I_BadPlane)
          {
             PWsts = SetError(PW_K_Pathway,PW_K_NonPlanar) ;
             goto wrapup;
          }
          else if (OMmsg == EMS_I_Cycle)
          {
             PWsts = SetError(PW_K_Pathway,PW_K_Cycle) ;
             goto wrapup;
          }
          if(OMmsg == EMS_I_Assoc)
            chkcycle = TRUE;
        }

/****** Will need for validation of the input points
            for (j=FIRST; j<loc_num_vgpts; j++)
            {
              is_duplicate = FALSE;
              for (k=FIRST; k<num_vgpts; k++)
              {
                 if (loc_vgpts[j] == vgpts[k])
                 {
                   is_duplicate = TRUE;
                   break;
                 }
              }
              if (!is_duplicate)
                vgpts[num_vgpts++] = loc_vgpts[j];
            }
******Will need for validation of the input points ***/


         if (num_vgpts > 3)
            cnstrclass = OPP_SKifcol_class_id;
          else
            cnstrclass = OPP_SKcollinear_class_id;

          CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                           cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
                           conflict_cnstr, collinear);

wrapup:
   PW_Wrapup (PWsts, "pwCollinearConstraint");
   return (PWsts);

}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places an equality  constraint.

  DESCRIPTION
	Given a set of line segments or arcs the API creates an equality
	constraint between these elements. Radii are made equal in case
	of arcs.

  ARGUMENTS
	int			num_elems;
	PWobjid 		*element_ids
	PWosnum 		os
        PWobjid 		**conflict_cnstr,
        int 		        *num_conflict_cnstr,
        PWobjid		        *equal

  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult pwEqualityConstraint
(
  int num_elems,
  PWobjid *element_ids,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *equal
)

{
  	long			OMsts, OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
  	PWclassid               sk_classid1;
        unsigned short          cnstrprops ;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
	int		        cnt,cntr, num_vgpts,sts;
        struct GRid		parmele,ele;
        PWboolean               chkcycle,flag;
        extern OMuword          EX_active_OS_num;

        

        cnstrprops = NULL;
        chkcycle = FALSE;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
  
        if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }

        OMsts = om$get_classid (objid = element_ids[0], osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
 
       /*
        * Error out if the element is an SKpoint or an SKcompcurve
        */
       if ((sk_classid == OPP_SKcompcurve_class_id) ||  
		(sk_classid == OPP_SKpoint_class_id))  
       {
           PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
           goto wrapup;
       }
       /*
        * Build the list of ptvars connected to each component of
	* first element
        */
        OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
                                          objid = element_ids[0], 
				          osnum = os,
                                          p_chanselect = &chan_to_defpts,
                                          count = &count);
      
        if (!(1&OMsts) || !count)
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

        vgpts = (PWobjid *) alloca (num_elems * 2 * sizeof (PWobjid));
        vgpts[0] = ptlinkage[FIRST].S_objid;
        vgpts[1] = ptlinkage[SECOND].S_objid;
        num_vgpts = 2;
        parmele.objid = element_ids[FIRST];
	parmele.osnum = os;

	for(cntr = 1; cntr < num_elems; cntr++)
	{
	  ele.objid = element_ids[cntr];
	  ele.osnum = os;

          OMsts = om$get_classid (objid = element_ids[cntr], osnum = os,
                                  p_classid = &sk_classid1);
          if (!(1&OMsts))
          {
            PWsts = SetError (PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
 
          /*
           * Error out if the element does not belong to the same class
	   * as that of the first element
           */
          if (sk_classid != sk_classid1)
          {
             PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
             goto wrapup;
          }
          OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                             &mod_env, &parmele, NULL, 
			                     NULL, 1, &ele, &cnt, 
					     &vgpts[num_vgpts]);

          num_vgpts += cnt;
       
	  if (OMmsg == EMS_I_BadPlane)
          {
             PWsts = SetError(PW_K_Pathway,PW_K_NonPlanar) ;
             goto wrapup;
          }
          else if (OMmsg == EMS_I_Cycle)
          {
             PWsts = SetError(PW_K_Pathway,PW_K_Cycle) ;
             goto wrapup;
          }
          if (OMmsg == EMS_I_Assoc)
            chkcycle = TRUE;
        }

         if (num_vgpts > 4)
            cnstrclass = OPP_SKifequal_class_id;
          else
            cnstrclass = OPP_SKequal_class_id;

         CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                          cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
                          conflict_cnstr, equal);
wrapup:
   PW_Wrapup (PWsts, "pwEqualityConstraint");
   return (PWsts);

}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places a ground constraint on a given element at its keypoint.
  DESCRIPTION
	Given an element of a profile and the keypoint of the element the
	API places the ground constraint. The elements currently supported
	are line, circle and point. The allowed keypoints are start points for 
	all types of elements and end points for lines and arcs, and center
	point for circles and arcs.

  NOTES

  ARGUMENTS
	PWobjid 		element_id
	enum PWtopopostype      keypnt
	PWosnum 		os
        PWobjid 		**conflict_cnstr
        int 		        *num_conflict_cnstr 
        PWobjid		        *ground

  HISTORY

     Satya   02/26/96   Creation 

*/




PWresult pwGroundConstraint 
( 
  PWobjid element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr, 
  PWobjid *ground
)
{
  	long			OMsts,OMmsg;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts, to_geom;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
        int			cnt;
        PWobjid			ptvars[4];
	PWresult		PWsts ;
  	struct GRmd_env		mod_env;
        PWboolean		chkcycle;
        unsigned short          cnstrprops = NULL;
        int			num_vgpts;
	int			sts;
        PWboolean		flag;
	extern OMuword	        EX_active_OS_num;

	OMmsg = EMS_S_Success;
	PWsts = PW_K_Success;
	OMsts = OM_S_SUCCESS;

        cnstrclass = OPP_SKasptgrnd_class_id;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
	EMmake_chanselect ( SKvariable_to_geometries, &to_geom);
  
	if(os == EX_active_OS_num)
	{
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
	  if(PWsts == PW_K_Error)
	  {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
	    if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }
        
        /*
         * Find the underlying composite curve or SKgeometry element.
         */
  
        OMsts = om$get_classid (objid = element_id, osnum = os,
                                  p_classid = &sk_classid);
	if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
        }
    
       /*
        * Error out if the element is a composite curve.
        */
       if (sk_classid == OPP_SKcompcurve_class_id)
       {
	 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
         goto wrapup;
       }
       /*
        * Build the list of ptvars connected to each component
        */
        OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
                                          objid = element_id, 
				          osnum = os,
                                          p_chanselect = &chan_to_defpts,
                                          count = &count);
        if (!(1&OMsts) || !count)
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
	}

        for (cnt = 0; cnt < count; cnt++)
          ptvars[cnt] = ptlinkage[cnt].S_objid;
        vgpts = (PWobjid *)malloc(sizeof(PWobjid));
        
        switch(keypnt)
	{
	    case PWtopopos_start:
                  vgpts[0] = ptvars[0];
		  break;
	    case PWtopopos_stop:
                    if ((sk_classid == OPP_SKpoint_class_id)
                         || (sk_classid == OPP_SKcircle_class_id))
                    {
			 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			 goto wrapup;
                    }
                    if (sk_classid == OPP_SKline_class_id)
                    {
			  vgpts[0] = ptvars[1];
                    }
                    if (sk_classid == OPP_SKarc_class_id)
                    {
			  vgpts[0] = ptvars[2];
                    }
		    break;
	    case PWtopopos_middle:
                    if ((sk_classid == OPP_SKpoint_class_id)
                         || (sk_classid == OPP_SKline_class_id))
                    {
			 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			 goto wrapup;
                    }
                    if ((sk_classid == OPP_SKarc_class_id)
		         || (sk_classid == OPP_SKcircle_class_id))
                    {
                          vgpts[0] = ptvars[1];
                    }
		    break;
	    case PWtopopos_unknown:
			 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			 goto wrapup;
	}

        num_vgpts = 1;
        chkcycle = FALSE;
        CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                         cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
			 conflict_cnstr, ground);
wrapup:
   PW_Wrapup (PWsts, "pwGroundConstraint");
   return (PWsts);
}


/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places a horizontal/vertical constraint on the given
	line segment of the profile.

  DESCRIPTION

	Given an element of the profile, the API places a horizontal
	constraint if the is_horiz flag is TRUE and vertical constraint
	otherwise. Only line segments are valid elements for this constraint.
	

  NOTES

  ARGUMENTS
	PWobjid 		*element_id
        enum PWtopopostype      *keypnt
	PWosnum 		os
	PWboolean               is_horiz
        PWobjid 		**conflict_cnstr
        int 			*num_conflict_cnstr
        PWobjid		        *horizvert

  HISTORY

     Satya   02/26/96   Creation 

*/

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwHorizVertConstraint 
( 
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWboolean is_horiz,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *horizvert
)
{
	long                    OMsts,OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          cnstrprops = NULL;
        PWobjid			*vgpts; 
        int	                cnt,scnt,icnt;
        PWobjid                 ptvars[4],loc_vgpts[4];
        OM_S_CHANSELECT         chan_to_defpts;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
        int			num_vgpts,sts;
        PWboolean		chkcycle,flag;
        struct GRid             parmele,ele; 
        extern OMuword          EX_active_OS_num;

       
        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
      
        cnstrclass = OPP_SKhorizvert_class_id;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
        chkcycle = FALSE;
  
        if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }

	vgpts = (PWobjid *)malloc(2*sizeof(PWobjid)); 
        if(element_id[1] == NULL_OBJID)
        {
          OMsts = om$get_classid (objid = element_id[0], osnum = os,
                                  p_classid = &sk_classid);
          if (!(1&OMsts&OMmsg))
          {
            PWsts = SetError (PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }

         /*
          * Error out if the element is not an SKline curve.
          */
         if (sk_classid != OPP_SKline_class_id) 
         {
           PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
           goto wrapup;
         }
         /*
          * Build the list of ptvars connected to each component
          */
          OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
                                          objid = element_id[0], 
				          osnum = os,
                                          p_chanselect = &chan_to_defpts,
                                          count = &count);
          if (!(1&OMsts))
          {
             PWsts = SetError (PW_K_Pathway, PW_K_Internal);
             goto wrapup;
          }
      
          for (cnt = 0; cnt < count; cnt++)
            ptvars[cnt] = ptlinkage[cnt].S_objid;
        
          vgpts[0] = ptvars[0];
          vgpts[1] = ptvars[1];
        }
        else
        {
          if(element_id[0] == NULL_OBJID)  
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
          for(scnt = 0; scnt < 2 ; scnt++)
          {
          	OMsts = om$get_classid (objid = element_id[scnt], osnum = os,
                                  p_classid = &sk_classid);
		if (!(1&OMsts))
		{
		   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		   goto wrapup;
		}
    
	       /*
		* Error out if the element is a composite curve.
		*/
	       if (sk_classid == OPP_SKcompcurve_class_id) 
               {
		 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
		 goto wrapup;
	       }
	       /*
		* Build the list of ptvars connected to each component
		*/
		OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
						objid = element_id[scnt], 
						osnum = os,
						p_chanselect = &chan_to_defpts,
						count = &count);
		if (!(1&OMsts) || !count)
		{
		   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		   goto wrapup;
		}

		for (cnt = 0; cnt < count; cnt++)
		  ptvars[cnt] = ptlinkage[cnt].S_objid;
		
		switch(keypnt[scnt])
		{
		    case PWtopopos_start:
			  vgpts[scnt] = ptvars[0];
			  break;
		    case PWtopopos_stop:
			    if ((sk_classid == OPP_SKpoint_class_id)
				 || (sk_classid == OPP_SKcircle_class_id))
			    {
			      PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			      goto wrapup;
			    }
			    if (sk_classid == OPP_SKline_class_id)
			    {
				  vgpts[scnt] = ptvars[1];
			    }
			    if (sk_classid == OPP_SKarc_class_id)
			    {
				  vgpts[scnt] = ptvars[2];
			    }
			    break;
		    case PWtopopos_middle:
			    if ((sk_classid == OPP_SKpoint_class_id)
				 || (sk_classid == OPP_SKline_class_id))
			    {
			       PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			       goto wrapup;
			    }
			    if ((sk_classid == OPP_SKarc_class_id)
				 || (sk_classid == OPP_SKcircle_class_id))
			    {
				  vgpts[scnt] = ptvars[1];
			    }
			    break;
		    case PWtopopos_unknown:
			 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
			 goto wrapup;
		}
          }
          parmele.objid = vgpts[0];
          parmele.osnum = os;
          ele.objid = vgpts[1];
          ele.osnum = os;

          OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                           &mod_env, &parmele, NULL, NULL, 
					   1, &ele, &icnt, &loc_vgpts);
          if (OMmsg == EMS_I_BadPlane)
          {
	      PWsts = SetError(PW_K_Pathway,PW_K_NonPlanar) ; 
	      goto wrapup;
          }
          else if (OMmsg == EMS_I_Cycle)
          {
	      PWsts = SetError(PW_K_Pathway,PW_K_Cycle) ; 
	      goto wrapup;
          }

          if (OMmsg == EMS_I_Assoc)
            chkcycle = TRUE;
        }

        if(is_horiz)
	  cnstrprops = SK_HORIZONTAL;
  
        num_vgpts = 2;
        CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                         cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
                         conflict_cnstr, horizvert);
wrapup:
   PW_Wrapup (PWsts, "pwHorizVertConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	Places a Normal Constraint between two given elements.

  DESCRIPTION
	Given two elements belonging to the same profile or a different
	profile a Normal constraint is placed between the two given
	elements. If the two elements belong to different profiles
	then on placement of this profile, the profiles merge with
	each other and the profile of the second element gets merged
	with the profile of the first element.

  NOTES

  ARGUMENTS
	PWobjid 		*element_id
	PWosnum 		os
        PWobjid 		**conflict_cnstr,
        int 			*num_conflict_cnstr,
        PWobjid		        *normal

  HISTORY

     Satya   02/26/96   Creation 

*/


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwNormalConstraint 
(  
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *normal
)
{
  	long			OMsts,OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          cnstrprops ;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
	int		        cnt, num_vgpts,sts;
        struct GRid		parmele,ele,cnstr_grid;
	PWboolean	        chkcycle,flag;
        extern OMuword          EX_active_OS_num;

        

        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
        cnstrprops = NULL;
	cnstrclass = OPP_SKnormal_class_id;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
    
        if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }

        OMsts = om$get_classid (objid = element_id[0], osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
    
       /*
        * Error out if the element is not an SKline curve.
        */
       if (sk_classid != OPP_SKline_class_id)
       {
         PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
         goto wrapup;
       }
       OMsts = om$get_classid (objid = element_id[1], osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

        vgpts = (PWobjid *) alloca (4 * sizeof (PWobjid));

       if (sk_classid != OPP_SKline_class_id)
       {
         PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
         goto wrapup;
       }
       /*
        * Build the list of ptvars connected to each component
        */
        OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
                                          objid = element_id[0], 
				          osnum = os,
                                          p_chanselect = &chan_to_defpts,
                                          count = &count);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
      
	*normal = cnstr_grid.objid;
        vgpts[0] = ptlinkage[0].S_objid;
        vgpts[1] = ptlinkage[1].S_objid;
        num_vgpts = 2;
	parmele.objid = element_id[0];
	parmele.osnum = os;
	ele.objid = element_id[1];
	ele.osnum = os;

        OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                           &mod_env, &parmele, NULL, 
		             		   NULL, 1, &ele,
                                           &cnt, &vgpts[num_vgpts]);
        if (!(1&OMsts&OMmsg))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

        num_vgpts += cnt;

        if (OMmsg == EMS_I_BadPlane)
        {
           PWsts = SetError(PW_K_Pathway,PW_K_NonPlanar) ;
           goto wrapup;
        }
        else if (OMmsg == EMS_I_Cycle)
        {
           PWsts = SetError(PW_K_Pathway,PW_K_Cycle) ;
           goto wrapup;
        }
        if (OMmsg == EMS_I_Assoc)
          chkcycle = TRUE;

        CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                         cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
                         conflict_cnstr, normal);

wrapup:
   PW_Wrapup (PWsts, "pwNormalConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	Places a Parallel Constraint between two given elements.

  DESCRIPTION
	Given two elements belonging to the same profile or a different
	profile a parallel constraint is placed between the two given
	elements. If the two elements belong to different profiles
	then on placement of this profile, the profiles merge with
	each other and the profile of the second element gets merged
	with the profile of the first element.

  NOTES

  ARGUMENTS
	PWobjid 		*element_id
	PWosnum 		os
  	PWobjid 		**conflict_cnstr
        int 			*num_conflict_cnstr
        PWobjid		        *parallel

  HISTORY

     Satya   02/26/96   Creation 

*/


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwParallelConstraint 
(  
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *parallel
)
{
  	long			OMsts,OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          cnstrprops ;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
	int		        cnt, num_vgpts,sts;
        struct GRid		parmele,ele;
        PWboolean		flag,chkcycle = FALSE;
        extern OMuword          EX_active_OS_num;

        

        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
        cnstrprops = NULL;
        cnstrclass = OPP_SKparallel_class_id;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
    
        if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }
        OMsts = om$get_classid (objid = element_id[0], osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
    
       /*
        * Error out if the element is not an SKline 
        */
       if (sk_classid != OPP_SKline_class_id)
       {
         PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
         goto wrapup;
       }
       OMsts = om$get_classid (objid = element_id[1], osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

       if (sk_classid != OPP_SKline_class_id)
       {
         PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
         goto wrapup;
       }
       /*
        * Build the list of ptvars connected to each component
        */
        OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
                                          objid = element_id[0], 
				          osnum = os,
                                          p_chanselect = &chan_to_defpts,
                                          count = &count);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
        vgpts = (PWobjid *)alloca(4*sizeof(PWobjid));
        vgpts[0] = ptlinkage[0].S_objid;
        vgpts[1] = ptlinkage[1].S_objid;
        num_vgpts = 2;
	parmele.objid = element_id[0];
	parmele.osnum = os;
	ele.objid = element_id[1];
	ele.osnum = os;

        OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                           &mod_env, &parmele, NULL, 
		             		   NULL, 1, &ele,
                                           &cnt, &vgpts[num_vgpts]);
        if (!(1&OMsts&OMmsg))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
        if (OMmsg == EMS_I_BadPlane)
        {
           PWsts = SetError(PW_K_Pathway,PW_K_NonPlanar) ;
           goto wrapup;
        }
        else if (OMmsg == EMS_I_Cycle)
        {
           PWsts = SetError(PW_K_Pathway,PW_K_Cycle) ;
           goto wrapup;
        }
        if(OMmsg == EMS_I_Assoc)
          chkcycle = TRUE;

        num_vgpts += cnt;
        CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                         cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
                         conflict_cnstr, parallel);
wrapup:
   PW_Wrapup (PWsts, "pwParallelConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places a Point on Element constraint between two elements
  DESCRIPTION
	Given a geometries objid and a point on another geometry, specified
        with the help of its objid and keypoint,  the API places the point on 
        element constraint. The elements currently supported
	are line, circle for the geometry. 

  ARGUMENTS
	PWobjid 		*element_id
        enum PWtopopostype      keypnt
	PWosnum 		os
        PWobjid 		**conflict_cnstr
  	int 			*num_conflict_cnstr
        PWobjid		        *ptonelmt

  HISTORY

     Satya   02/26/96   Creation 

*/


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwPtonelmtConstraint 
( 
  PWobjid *element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *ptonelmt
)
{
  	long			OMsts,OMmsg;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts, to_geom;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
        double		        lentol;
        int			cnt,icnt;
        PWobjid			ptvars[4];
	PWresult		PWsts ;
  	struct GRmd_env		mod_env;
	struct	GRid		parmele,ele;
        struct SKptonelmt_info  ptonelmt_info;
	int			num_vgpts,sts;
        char 			*cnstrinfo;
        PWboolean		chkcycle,flag;
        extern OMuword          EX_active_OS_num;

       
	OMmsg = EMS_S_Success;
	PWsts = PW_K_Success;
	OMsts = OM_S_SUCCESS;
	cnstrclass = OPP_SKptonelmt_class_id;
        chkcycle = FALSE;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
	EMmake_chanselect ( SKvariable_to_geometries, &to_geom);
  
        BSEXTRACTPAR (&OMmsg, BSTOLLENVEC, lentol);
    
        if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }

        OMsts = om$get_classid (objid = element_id[0], osnum = os,
                                  p_classid = &sk_classid);
	if (!(1&OMsts))
	{
	   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
	}
    
	/*
	 *  Error out if the element is a composite curve.
	 */
	if (sk_classid == OPP_SKcompcurve_class_id)
	{
	  PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
	  goto wrapup;
	} 
	/*
	 * Build the list of ptvars connected to each component
	 */
	OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
					objid = element_id[0], 
					osnum = os,
					p_chanselect = &chan_to_defpts,
					count = &count);
	if (!(1&OMsts) || !count)
	{
	   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
	}

	for (cnt = 0; cnt < count; cnt++)
	  ptvars[cnt] = ptlinkage[cnt].S_objid;

        vgpts = (PWobjid *)alloca(4*sizeof(PWobjid));
	switch(keypnt)
	{
	    case PWtopopos_start:
		  vgpts[0] = ptvars[0];
		  break;
	    case PWtopopos_stop:
		    if ((sk_classid == OPP_SKpoint_class_id)
			 || (sk_classid == OPP_SKcircle_class_id))
		    {
		      PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
		      goto wrapup;
		    }
		    if (sk_classid == OPP_SKline_class_id)
		    {
			  vgpts[0] = ptvars[1];
		    }
		    if (sk_classid == OPP_SKarc_class_id)
		    {
			  vgpts[0] = ptvars[2];
		    }
		    break;
	    case PWtopopos_middle:
		    if ((sk_classid == OPP_SKpoint_class_id)
			 || (sk_classid == OPP_SKline_class_id))
		    {
		       PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
		       goto wrapup;
		    }
		    if ((sk_classid == OPP_SKarc_class_id)
			 || (sk_classid == OPP_SKcircle_class_id))
		    {
			  vgpts[0] = ptvars[1];
		    }
		    break;
	    case PWtopopos_unknown:
		 PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
		 goto wrapup;
	}
        parmele.objid = vgpts[0];
        parmele.osnum = os;
        num_vgpts = 1;
        ele.objid = element_id[1];
        ele.osnum = os;

        ptonelmt_info.elemobj = ele.objid;
        cnstrinfo = (char *) &ptonelmt_info;
 

        OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                           &mod_env, &parmele, NULL, NULL, 
					   1, &ele, &icnt, &vgpts[num_vgpts]);
       if (!(1&OMsts&OMmsg))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
        if (OMmsg == EMS_I_BadPlane)
        {
           PWsts = SetError(PW_K_Pathway,PW_K_NonPlanar) ;
           goto wrapup;
        }
        else if (OMmsg == EMS_I_Cycle)
        {
           PWsts = SetError(PW_K_Pathway,PW_K_Cycle) ;
           goto wrapup;
        }
        if(OMmsg == EMS_I_Assoc)
          chkcycle = TRUE;

        num_vgpts += icnt;
        CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,NULL,
                         cnstrinfo,chkcycle,&mod_env,num_conflict_cnstr,
                         conflict_cnstr, ptonelmt);

wrapup:
   PW_Wrapup (PWsts, "pwPtonelmtConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places a tangency constraint on the given arc segment 
	of the profile.

  DESCRIPTION

	Given an element of the profile, the API places a tangency
	constraint . Only arc segments are valid elements for this constraint.
	

  NOTES

  ARGUMENTS
  	PWobjid 		element_id,
  	enum PWtopopostype 	keypnt,
  	PWosnum 		os,
  	PWobjid 		**conflict_cnstr,
  	int 			*num_conflict_cnstr,
  	PWobjid 		*tangent

  HISTORY

     Satya   02/26/96   Creation 

*/

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwTangencyConstraint 
( 
  PWobjid element_id,
  enum PWtopopostype keypnt,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *tangent
)
{
	long                    OMsts,OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          cnstrprops ;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts,chan_to_geoms;
        OM_S_OBJECT_LINKAGE     ptlinkage[4],gmlist[3];
        OMuint			count;
	int			cnti,cntj;
	unsigned short		gmtype[2];
	int		        num_vgpts,sts;
        PWboolean		chkcycle,flag;
        extern OMuword          EX_active_OS_num;


        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
      
        cnstrprops = NULL;
        chkcycle = FALSE;
        cnstrclass = OPP_SKtangency_class_id;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
        EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
 
        if(os == EX_active_OS_num)
        {
          gr$get_module_env(msg = &OMmsg, buffer = &mod_env);
        }
        else
        {
          PWsts = pwActivateOS(os);
          if(PWsts == PW_K_Error)
          {
            PWsts = SetError(PW_K_Pathway, PW_K_Internal);
            goto wrapup;
          }
          flag = pwIsActivationOn();
          if(flag)
          {
            sts = pwGetActiveModuleEnv(&mod_env);
            if(!sts)
            {
              PWsts = SetError(PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
          }
        }
        OMsts = om$get_classid (objid = element_id, osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts&OMmsg))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

        /*
         * Error out if the first element is not an SKarc or an SKline
         */
        if ((sk_classid != OPP_SKline_class_id) && 
		(sk_classid != OPP_SKarc_class_id))
        {
           PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
           goto wrapup;
        }
        /*
        * Build the list of ptvars connected to component
        */
        OMsts = om$get_channel_objects (list = ptlinkage, size = 4, 
                                        objid = element_id, 
				        osnum = os,
                                        p_chanselect = &chan_to_defpts,
                                        count = &count);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
        vgpts = (PWobjid *) alloca (3 * sizeof (PWobjid));

        switch(keypnt)
        {
            case PWtopopos_start:
                  vgpts[0] = ptlinkage[0].S_objid;
                  break;
            case PWtopopos_stop:
                    if (sk_classid == OPP_SKline_class_id)
                    {
                          vgpts[0] = ptlinkage[1].S_objid;
                    }
                    if (sk_classid == OPP_SKarc_class_id)
                    {
                          vgpts[0] =  ptlinkage[2].S_objid;
                    }
                    break;
            case PWtopopos_middle:
                    {
                         PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
                         goto wrapup;
                    }
            case PWtopopos_unknown:
                         PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
                         goto wrapup;
        }

        OMsts = om$get_channel_objects (objid = vgpts[0],
                                        osnum = os, 
				        p_chanselect = &chan_to_geoms,
                                        count = &count, size = 3, 
					list = gmlist);
        if (!(1&OMsts) || (count != 2))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }
  
        for (cnti=FIRST; cnti<=SECOND; cnti++)
           SKgetgeomtype (gmlist[cnti].S_objid, os, &gmtype[cnti]);

        if ((gmtype[FIRST] & SK_LINE && gmtype[SECOND] & SK_LINE) ||
              (gmtype[FIRST] & SK_POINT || gmtype[SECOND] & SK_POINT))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
           goto wrapup;
	}
 
	for(cnti=0,cntj=1;cnti<=1;cnti++,cntj++)
        {
           OMsts = om$get_channel_objects (objid = gmlist[cnti].S_objid,
                                             osnum = os,
                                             p_chanselect = &chan_to_defpts,
                                             count = &count, size = 4, 
					     list = ptlinkage);
 
            if (!(1&OMsts))
            {
              PWsts = SetError (PW_K_Pathway, PW_K_Internal);
              goto wrapup;
            }
            if (gmtype[cnti] & SK_LINE)
             vgpts [cntj] = ptlinkage [ptlinkage [0].S_objid == 
				       vgpts [0] ? 1 : 0].S_objid;
            else if (gmtype[cnti] & SK_ARC)
              vgpts [cntj] = ptlinkage [1].S_objid;    /* center pt-id */
            else if (gmtype[cnti] & SK_BSPLINE)
              vgpts [cntj] = ptlinkage [ptlinkage [0].S_objid == 
				vgpts [0] ? 1 : 2].S_objid;
         }
         num_vgpts = 3;
         CreateGeomConstraint(cnstrclass,os,num_vgpts,vgpts,
                          cnstrprops,NULL,chkcycle,&mod_env,num_conflict_cnstr,
                          conflict_cnstr, tangent);

wrapup:
   PW_Wrapup (PWsts, "pwTangencyConstraint");
   return (PWsts);
}

/*
 *  A helper function which helps in recomputing the constraint after
 *   placement of the constraint. This is used by both Geometric constraint
 *   as well as  Dimensional Constraint
*/


PWresult CreateGeomConstraint
( PWclassid cnstrclass,
  PWosnum os,
  int     num_vgpts,
  PWobjid *vgpts,
  unsigned short cnstrprops,
  char *cnstrinfo,
  PWboolean chkcycle,
  struct GRmd_env  *mod_env,
  int *num_conflict_cnstr,
  PWobjid  **conflict_cnstr,
  PWobjid *constraint
)
{
	long                    OMsts,OMmsg,PWsts;
        IGRboolean		val_cnstr;
        long			val_msg_loc;
        struct GRid             mgrid,cnstr_grid;
	int		        comp_type,batch_mode;
        unsigned short          opts;
       
        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;

        opts = SK_OPT_CREATE_GEOMETRY | SK_OPT_MARK_AS_NEWADD |
                    SK_OPT_MARK_AS_USERADD | SK_OPT_DISPLAY_GEOMETRY ;
 
        OMsts = om$construct (classid = cnstrclass, osnum = os,
                              msg = message SKconstraint.SKinit (&OMmsg, opts,
                              mod_env, num_vgpts, vgpts, cnstrprops, 
			      NULL, cnstrinfo),
                              p_objid = &cnstr_grid.objid);

        if (!(1&OMsts&OMmsg))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
	}
        cnstr_grid.osnum = os;
  
        OMsts = om$send (msg = message SKconstraint.SKvalidate (&val_msg_loc,
            chkcycle ? SK_UPDATE_CHKCYCLE : NULL, mod_env, &val_cnstr,
            num_conflict_cnstr, conflict_cnstr),
            senderid = NULL_OBJID,
            targetid = cnstr_grid.objid, 
            targetos = cnstr_grid.osnum);
        if (!(1&OMsts&OMmsg))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           val_cnstr = 0;
        }
  
        if (val_cnstr)
        {
	  *constraint = cnstr_grid.objid;
          OMsts = om$send (msg = message SKconstraint.SKgetmgr
                                   (&OMmsg, &mgrid.objid), 
            		     senderid = NULL_OBJID,
                             targetid = cnstr_grid.objid,
                             targetos = cnstr_grid.osnum);
          if (!(1&OMsts&OMmsg))
          {
            PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	    goto wrapup;
	  }
          mgrid.osnum = cnstr_grid.osnum;
          comp_type = ND_COMP;
          nd$wait_batch (type = GR_GEOM_POSTED,
            l_object = &mgrid, l_obj_info = &comp_type, nb_obj = 1);

          nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
          if (batch_mode == ND_IMMEDIATE)
            nd$exec_batch();
        }
        else
        {
          ECvg_report_conflict(&OMmsg, val_msg_loc, mod_env, cnstr_grid, 
                               *num_conflict_cnstr, *conflict_cnstr);
        }
  
wrapup:
   PW_Wrapup (PWsts, "CreateGeomConstraint");
   return (PWsts);
}

end implementation SKmgr;
