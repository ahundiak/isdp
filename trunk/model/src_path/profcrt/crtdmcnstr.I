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
#include "ECmsg.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/dmcnstr.h"
#include "actparam.h"

extern PWclassid OPP_SKline_class_id, OPP_SKfixang_class_id; 
extern PWclassid OPP_SKhvptpt_class_id, OPP_SKradial_class_id; 
extern PWclassid OPP_SKcompcurve_class_id,OPP_SKpoint_class_id; 
extern PWclassid OPP_SKarc_class_id, OPP_SKcircle_class_id; 
extern PWclassid OPP_SKline_class_id, OPP_SKifptpt_class_id; 
extern PWclassid OPP_SKrelang_class_id;

from	SKgeometry import SKgetmgr;
from    SKconstraint import SKcreate_geom, SKinit,SKvalidate;

static PWresult CreateDimConstraint
(
  PWclassid cnstrclass,
  PWosnum os,
  unsigned short opts,
  int     num_vgpts,
  PWobjid *vgpts,
  unsigned short cnstrprops,
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
	The API creates an Absolute Angle Constraint.

  ARGUMENTS
        PWobjid                 *element_id
        PWosnum                 os
        PWobjid                 **conflict_cnstr,
        int                     *num_conflict_cnstr,
        PWobjid                 *fixang

*/

PWresult pwFixangConstraint 
(
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *fixang
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
	int		        num_vgpts,sts;
        PWboolean		flag;
        extern OMuword          EX_active_OS_num;
        unsigned short          opts;

        

        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
        cnstrprops = NULL;
        cnstrclass = OPP_SKfixang_class_id;
        /* An optional SK_OPT_CHECK_UNITS too may be needed ???? */
        opts = SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY 
			| SK_OPT_CHECK_UNITS ;
        vgpts = (PWobjid *)alloca(2*sizeof(PWobjid));

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

        OMsts = om$get_classid (objid = element_id, osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
	{
	   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
	}
   
        if(sk_classid != OPP_SKline_class_id) 
        {
	  PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
	  goto wrapup;
        }
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
	vgpts[0] = ptlinkage[0].S_objid;
	vgpts[1] = ptlinkage[1].S_objid;
        num_vgpts = 2;
		
        CreateDimConstraint(cnstrclass,os,opts,num_vgpts,vgpts,
                            cnstrprops,&mod_env,
                            num_conflict_cnstr,conflict_cnstr, fixang);
wrapup:
   PW_Wrapup (PWsts, "pwFixangConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
      The API places an orthogonal Dimensional Constraint. If the is_horiz
      bit is set, it places the constraint along the horizontal axis and if 
      it is FALSE it places the dimension along the vertical axis.

  ARGUMENTS
      PWobjid        	      *element_id
      enum PWtopopostype      *keypnt
      PWosnum 		      os
      PWboolean               is_horiz
      PWobjid 		      **conflict_cnstr
      int 		      *num_conflict_cnstr
      PWobjid                 *horizdim

  HISTORY
     Satya   02/26/96   Creation 

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwHorizDimConstraint 
(  
  PWobjid *element_id,
  enum PWtopopostype *keypnt,
  PWosnum os,
  PWboolean is_horiz,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *horizdim
)
{
  	long			OMsts,OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          cnstrprops ;
        PWobjid			loc_vgpts[4],*vgpts;
        OM_S_CHANSELECT         chan_to_defpts;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
	int		        icnt,num_vgpts;
        struct GRid		parmele,ele;
	int			scnt,num_elems,sts;
        PWboolean               flag;
        extern OMuword          EX_active_OS_num;
        unsigned short          opts;

	

        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
        opts = SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY;
        vgpts = (PWobjid *)alloca(4*sizeof(PWobjid));

	if(is_horiz)
           cnstrprops = SK_HORIZONTAL;
	else
	   cnstrprops = NULL;
        cnstrclass = OPP_SKhvptpt_class_id;
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

	if(element_id[1] == NULL_OBJID)
	   num_elems = 1;
	else
	   num_elems = 2;
	for(scnt = 0; scnt < num_elems; scnt++)
	{
          OMsts = om$get_classid (objid = element_id[scnt], osnum = os,
                                  p_classid = &sk_classid);
          if (!(1&OMsts))
	  {
	     PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	     goto wrapup;
	  }
   
          if(sk_classid == OPP_SKcompcurve_class_id) 
          {
	    PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
	    goto wrapup;
          }
          if(num_elems == 1)
          {
             if(sk_classid != OPP_SKline_class_id) 
             {
	        PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
	        goto wrapup;
             }
          }
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
          if(num_elems > 1)
          {
            switch(keypnt[scnt])
            {
               case PWtopopos_start:
                      vgpts[scnt] = ptlinkage[0].S_objid;
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
                           vgpts[scnt] = ptlinkage[1].S_objid;
                      }
                      if (sk_classid == OPP_SKarc_class_id)
                      {
                            vgpts[scnt] = ptlinkage[2].S_objid;
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
                           vgpts[scnt] = ptlinkage[1].S_objid;
                      }
                      break;
                case PWtopopos_unknown:
                         PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
                         goto wrapup;
             }
          }
          else
          {
             vgpts[0] = ptlinkage[0].S_objid;
             vgpts[1] = ptlinkage[1].S_objid;
          }
        }
        if(num_elems > 1)
        {
          parmele.objid = element_id[0];
          parmele.osnum = os;
          ele.objid = element_id[1];
          ele.osnum = os;

          OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                           &mod_env, &parmele, NULL, NULL,
                                           1, &ele, &icnt, &loc_vgpts);
        }

        num_vgpts = 2;
        CreateDimConstraint(cnstrclass,os,opts,num_vgpts,vgpts,
                            cnstrprops,&mod_env,
                            num_conflict_cnstr,conflict_cnstr, horizdim);

wrapup:
   PW_Wrapup (PWsts, "pwhorizdimConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	Places a Radial Dimensional Constraint on a given given arc or
	a circle.

  ARGUMENTS
	PWobjid 		element_id
	PWosnum 		os
        PWobjid                 **conflict_cnstr,
        int                     *num_conflict_cnstr,
        PWobjid		        *radial

  HISTORY

     Satya   02/26/96   Creation 

*/



/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwRadialConstraint 
( 
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *radial
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
        int			num_vgpts,sts;
	PWboolean		flag;
        extern OMuword          EX_active_OS_num;
        unsigned short          opts;


        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
        cnstrprops = NULL;
        cnstrclass = OPP_SKradial_class_id;
        opts = SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY |
		SK_OPT_CHECK_UNITS ;
        vgpts = (PWobjid *)alloca(4*sizeof(PWobjid));

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
        OMsts = om$get_classid (objid = element_id, osnum = os,
                                  p_classid = &sk_classid);
        if (!(1&OMsts))
	{
	   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
	}
   
        if((sk_classid != OPP_SKarc_class_id) && 
		(sk_classid != OPP_SKcircle_class_id ))
        {
	  PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ; 
	  goto wrapup;
        }
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
	vgpts[0] = ptlinkage[0].S_objid;
	vgpts[1] = ptlinkage[1].S_objid;
        num_vgpts = 2;
        CreateDimConstraint(cnstrclass,os,opts,num_vgpts,vgpts,
                            cnstrprops,&mod_env,
                            num_conflict_cnstr,conflict_cnstr, radial);
wrapup:
   PW_Wrapup (PWsts, "pwRadialConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	Places a Single Parallel Dimensional Constraint on a given 
	line segment.

  ARGUMENTS
	PWobjid 		element_id
	PWosnum 		os
        PWobjid                 **conflict_cnstr,
        int                     *num_conflict_cnstr,
        PWobjid		        *singleparl

  HISTORY

     Satya   02/26/96   Creation 

*/


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwSingleParlConstraint 
( 
  PWobjid element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *singleparl
)
{
  	long			OMsts,OMmsg,PWsts;
  	struct GRmd_env		mod_env;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          cnstrprops ;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts,chan_to_parent,chan_to_comps;
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
        struct GRid		mgr_id,planid,cnstr_grid;
	PWpoint			centpt;
	short			planmattyp;
	IGRmatrix		planmat;
	int			num_vgpts,sts;
	PWboolean		flag;
        extern OMuword          EX_active_OS_num;
        unsigned short          opts;

        

        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
        cnstrprops = NULL;
        cnstrclass = OPP_SKifptpt_class_id;
        EMmake_chanselect (NDfather_father, &chan_to_parent);
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
  	EMmake_chanselect ( GRconnector_to_owners, &chan_to_comps);
    
        opts = NULL;
	vgpts = (PWobjid *)alloca(2*sizeof(PWobjid));
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
       OMsts = om$send (msg = message SKgeometry.SKgetmgr (&OMmsg,
                                         &mgr_id.objid),
                           targetos = os,
                           senderid = NULL_OBJID,
                           targetid = element_id);
       mgr_id.osnum = os;

	vgpts[0] = ptlinkage[0].S_objid;
	vgpts[1] = ptlinkage[1].S_objid;

        num_vgpts = 2;
        OMsts = om$send (msg = message NDnode.ASreturn_go (&planid, 
		           &planmattyp,planmat), 
                           targetos = mgr_id.osnum,
                           senderid = mgr_id.objid, 
                           p_chanselect = &chan_to_parent,
                           from = FIRST, to = FIRST);
        OMsts = SKfind_centroid (&OMmsg, &mod_env, mgr_id, centpt);
        CreateDimConstraint(cnstrclass,os,opts,num_vgpts,vgpts,
                            cnstrprops,&mod_env,
                            num_conflict_cnstr,conflict_cnstr, singleparl);
        if(*singleparl == NULL_OBJID)
	{
	   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
        }
        cnstr_grid.objid = *singleparl;
	cnstr_grid.osnum = os;
        OMsts = SKcreate_sngl_parallel (&OMmsg, &mod_env, cnstr_grid, 
					vgpts, planid, centpt); 
wrapup:
   PW_Wrapup (PWsts, "pwSingleParallelConstraint");
   return (PWsts);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API places a relative angular constraint between two elements

  NOTES
        Currently there is no control on the quadrant in which the dimension
        constraint is placed. The dimension's are always placed in CCW 
        orientation.

  ARGUMENTS
	PWobjid 		element_id[2]
	enum elmt_key_pnt       keypnt[2]
	PWosnum 		os
        PWobjid		        *angular

  HISTORY

     Satya   02/26/96   Creation 

*/


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwRelangConstraint 
(
  PWobjid *element_id,
  PWosnum os,
  PWobjid **conflict_cnstr,
  int *num_conflict_cnstr,
  PWobjid *relang
)

{
  	long			OMsts,OMmsg;
  	PWclassid               sk_classid,cnstrclass = OM_K_NOTUSING_CLASSID;
        unsigned short          opts ;
        PWobjid			*vgpts;
        OM_S_CHANSELECT         chan_to_defpts, chan_to_parent,chan_to_comps;
        OM_S_CHANSELECT         to_geom; 
        OM_S_OBJECT_LINKAGE     ptlinkage[4];
        OMuint			count;
        int			scnt,icnt,num_vgpts,sts;
	PWresult		PWsts ;
  	struct GRmd_env		mod_env;
	PWobjid			loc_vgpts[4];
        struct GRid             mgr_id,planid,cnstr_grid,parmele,ele;
        short                   planmattyp;
        IGRmatrix               planmat;
        extern OMuword          EX_active_OS_num;
	PWboolean		flag;
        unsigned short          cnstrprops ;
       
	
 
	OMmsg = EMS_S_Success;
	PWsts = PW_K_Success;
	OMsts = OM_S_SUCCESS;

        cnstrclass = OPP_SKrelang_class_id;
        cnstrprops = NULL;
        opts = NULL;
  	EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
	EMmake_chanselect ( SKvariable_to_geometries, &to_geom);
        EMmake_chanselect (NDfather_father, &chan_to_parent);
        EMmake_chanselect ( GRconnector_to_owners, &chan_to_comps);
  
  
        vgpts = (PWobjid *)alloca(4*sizeof(PWobjid));
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
		* Error out if the element is not an SKline
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
						objid = element_id[scnt], 
						osnum = os,
						p_chanselect = &chan_to_defpts,
						count = &count);
		if (!(1&OMsts) || !count)
		{
		   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
		   goto wrapup;
		}

		if(scnt == 0)
                {
		  vgpts[0] = ptlinkage[0].S_objid;
		  vgpts[1] = ptlinkage[1].S_objid;
                }
		if(scnt == 1)
                {
		  vgpts[2] = ptlinkage[0].S_objid;
		  vgpts[3] = ptlinkage[1].S_objid;
                }
        }
        parmele.objid = element_id[0];
        parmele.osnum = os;
        ele.objid = element_id[1];
        ele.osnum = os;

        OMsts = SKprocess_sketch_graphics (&OMmsg, SK_PROCSKGR_MERGESK,
                                           &mod_env, &parmele, NULL, NULL, 
					   1, &ele, &icnt, &loc_vgpts);
       OMsts = om$send (msg = message SKgeometry.SKgetmgr (&OMmsg,
                                         &mgr_id.objid),
                           targetos = os,
                           senderid = NULL_OBJID,
                           targetid = element_id[0]);
       mgr_id.osnum = os;

       OMsts = om$send (msg = message NDnode.ASreturn_go (&planid,
                           &planmattyp,planmat),
                           targetos = mgr_id.osnum,
                           senderid = mgr_id.objid,
                           p_chanselect = &chan_to_parent,
                           from = FIRST, to = FIRST);
 
        num_vgpts = 4;
        CreateDimConstraint(cnstrclass,os,opts,num_vgpts,vgpts,
                            cnstrprops,&mod_env,
                            num_conflict_cnstr,conflict_cnstr, relang);
        if(*relang != NULL_OBJID)
	{
           cnstr_grid.objid = *relang;
           cnstr_grid.osnum = os;
	   OMsts = SKcreate_relang (&OMmsg, &mod_env,cnstr_grid,vgpts,planid);
	}
wrapup:
   PW_Wrapup (PWsts, "pwRelAngularConstraint");
   return (PWsts);
}


/*
 *  A helper function which helps in recomputing the constraint after
 *   placement of the constraint. This is used by both Geometric constraint
 *   as well as  Dimensional Constraint
*/


PWresult CreateDimConstraint
( 
  PWclassid cnstrclass,
  PWosnum os,
  unsigned short opts,
  int     num_vgpts,
  PWobjid *vgpts,
  unsigned short cnstrprops,
  struct GRmd_env  *mod_env,
  int *num_conflict_cnstr,
  PWobjid  **conflict_cnstr,
  PWobjid *constraint
)
{
	long                    OMsts,OMmsg,PWsts;
        IGRboolean		val_cnstr;
        long			val_msg_loc;
        struct GRid             cnstr_grid;
        unsigned short	        loc_opts;
       
        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;
        loc_opts = SK_OPT_MARK_AS_USERADD;

        OMsts = om$construct (classid = cnstrclass, osnum = os,
                              msg = message SKconstraint.SKinit(&OMmsg,loc_opts,
                              mod_env, num_vgpts, vgpts, cnstrprops, 
			      NULL, NULL),
                              p_objid = &cnstr_grid.objid);

        if (!(1&OMsts&OMmsg))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	   goto wrapup;
	}
        cnstr_grid.osnum = os;
  
        OMsts = om$send (msg = message SKconstraint.SKvalidate (&val_msg_loc,
                    NULL, mod_env, &val_cnstr,
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
          if (opts & SK_OPT_CREATE_GEOMETRY)
          {
             OMsts = om$send ( msg = message SKconstraint.SKcreate_geom
                                (&OMmsg, NULL, mod_env, NULL),
                                targetid = cnstr_grid.objid, 
                                targetos = os,
                                senderid = NULL_OBJID);
             if (!(1&OMsts&OMmsg))
             {
               PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	       goto wrapup;
	     }

             /*
              * Since the geometric handle was created, see if we have to 
              * check if the units convert flag for explicit dimensions 
              * needs to be set.
              */ 
              if (opts & SK_OPT_CHECK_UNITS)
              {
                 OMsts = SKset_units_convert_flag(&OMmsg, &cnstr_grid);
                 if (!(1&OMsts&OMmsg))
                 {
                   PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	           goto wrapup;
	         }
              }
          }
        }
        else
        {
	  *constraint = NULL_OBJID;
          om$send (msg = message GRgraphics.GRdelete (&OMmsg, mod_env),
                              targetid = cnstr_grid.objid, 
			      targetos = os,
                              senderid = NULL_OBJID);
          ECvg_report_conflict(&OMmsg, val_msg_loc, mod_env, cnstr_grid, 
                               *num_conflict_cnstr, *conflict_cnstr);
        }
wrapup:
   PW_Wrapup (PWsts, "CreateDimConstraint");
   return (PWsts);
}

end implementation SKmgr;
