
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
#include "PWapi/profquery.h"

extern PWclassid OPP_SKmgr_class_id, OPP_SKequal_class_id;
extern PWclassid OPP_SKline_class_id, OPP_SKarc_class_id;
extern PWclassid OPP_SKcircle_class_id, OPP_SKbspline_class_id;
extern PWclassid OPP_SKcompcurve_class_id,OPP_SKpoint_class_id;
extern PWclassid OPP_GRcompcurve_class_id;

from SKvariable   import SKgetvar;
from SKconstraint import SKgetmgr;
from SKexplicit import SKgetval;


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API operates on profile objects and returns the top level
        geometries(comp_curves, single curves etc. which stanalone) . 
	The same API can also be used on an SKcompcurve/GRcompcurve .It 
	returns the end-point connected components of the composite curve
	in this case.
	
  DESCRIPTION
	The API can be used to get a list of components of compcurves.
        In case of SKcompcurve, the outputs comprises of SKline, SKarc etc.
	Whereas for GRcompcurve the output comprises of G3dlineseg, GR3dcirarc
	etc.

  ARGUMENTS
	PWobjid 	I	profile_id
	PWosnum 	I	os
	PWobjid		O	*components
	
  HISTORY

     Satya   02/26/96   Creation 

*/

PWresult  pwGetProfileComponents 
( 
  PWobjid profile_id,
  PWosnum os,
  PWobjid *components
)
{
  	long			OMsts,PWsts;
        OM_S_CHANSELECT         chan_to_comps,chan_to_defpts,chan_to_geoms;
        OM_S_OBJECT_LINKAGE     *comp_list,*ptvar_list;
	int			cnt,cnti;
        OMuint			count,cnttmp,icount;
        PWclassid               cmp_classid;

        OMsts = OM_S_SUCCESS;
        PWsts = PW_K_Success;
 
        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
        EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);

        count = 0;

	OMsts = om$get_channel_count ( objid = profile_id, 
				       osnum = os,
				       p_chanselect = &chan_to_comps,
				       count = &count);
 	if (count)
  	{
    		comp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * 
				sizeof ( OM_S_OBJECT_LINKAGE ) );
                OMsts = om$get_channel_objects (list = comp_list, 
						size = count,
                                       		count = &count,
                                                objid = profile_id,
						osnum = os,
                                                p_chanselect = &chan_to_comps);
	}
	for(cnti=0,cnt=0;cnt<count;cnt++)
        {
           OMsts = om$get_classid (objid = comp_list[cnt].S_objid, 
				   osnum = os,
                                   p_classid = &cmp_classid);
           /** SKpoints which are created as parts of SKarc and SKbspline
	       creation are not the top owners and hence should not be
	       shown **/
           if (cmp_classid == OPP_SKpoint_class_id)               
           {
    	       ptvar_list = (OM_S_OBJECT_LINKAGE *)alloca (sizeof ( 
                                             OM_S_OBJECT_LINKAGE ) );
               OMsts = om$get_channel_objects (list = ptvar_list, 
					       size = 1,
                                       	       count = &icount,
                                               objid = comp_list[cnt].S_objid,
					       osnum = os,
                                               p_chanselect = &chan_to_defpts);
               cnttmp = 0;
	       OMsts = om$get_channel_count ( objid = ptvar_list[0].S_objid, 
				              osnum = os,
				              p_chanselect = &chan_to_geoms,
				              count = &cnttmp);
               if(cnttmp > 1)
	         continue;
	   }
	   components[cnti++] = comp_list[cnt].S_objid;
        }
	return(PWsts);
}


/*
  ABSTRACT
	This returns the number of top level geometries for a given profile

  DESCRIPTION

  NOTES

  ARGUMENTS
	PWobjid       I		profile_id
	PWosnum       I		os

  RETURN VALUES
        int		        Number of profile components 
       
  HISTORY

     Satya   02/26/96   Creation 

*/

int pwNumProfileComponents 
( 
  PWobjid profile_id,
  PWosnum os
)
{
        long                    OMsts,PWsts;
        OM_S_CHANSELECT         chan_to_comps,chan_to_defpts,chan_to_geoms;
        OM_S_OBJECT_LINKAGE     *comp_list,*ptvar_list;
        int                     cnt,num_comps;
        OMuint                  count,cnttmp,icount;
        PWclassid               cmp_classid;

        OMsts = OM_S_SUCCESS;
        PWsts = PW_K_Success;
 
        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts);
        EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);

        count = 0;

	OMsts = om$get_channel_count ( objid = profile_id, 
				       osnum = os,
				       p_chanselect = &chan_to_comps,
				       count = &count);
 	if (count)
  	{
    		comp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * 
				sizeof ( OM_S_OBJECT_LINKAGE ) );
                OMsts = om$get_channel_objects (list = comp_list, 
						size = count,
                                       		count = &count,
                                                objid = profile_id,
						osnum = os,
                                                p_chanselect = &chan_to_comps);
	}
        num_comps = count;
	for(cnt=0;cnt<count;cnt++)
        {
           OMsts = om$get_classid (objid = comp_list[cnt].S_objid, 
				   osnum = os,
                                   p_classid = &cmp_classid);
           /** SKpoints which are created as parts of SKarc and SKbspline
	       creation are not the top owners and hence should not be
	       shown **/
           if (cmp_classid == OPP_SKpoint_class_id)
           {
    	       ptvar_list = (OM_S_OBJECT_LINKAGE *)alloca (sizeof 
					( OM_S_OBJECT_LINKAGE ) );
               OMsts = om$get_channel_objects (list = ptvar_list, 
						size = 1,
                                       		count = &icount,
                                                objid = comp_list[cnt].S_objid,
						osnum = os,
                                                p_chanselect = &chan_to_defpts);
               cnttmp = 0;
	       OMsts = om$get_channel_count ( objid = ptvar_list[0].S_objid, 
				              osnum = os,
				              p_chanselect = &chan_to_geoms,
				              count = &cnttmp);
               if(cnttmp > 1)
	         num_comps--;
	   }
        }
	return(num_comps);
}

/*
  ABSTRACT
        This API gives the components of the comp curve.

  DESCRIPTION

  NOTES

  ARGUMENTS
        PWobjid       I         comp_curve
        PWosnum       I         os
        PWobjid*      O         components

  HISTORY

     Satya   02/26/96   Creation

*/

PWresult  pwGetCvComponents  
(
  PWobjid comp_curve,
  PWosnum os,
  PWobjid *components
)
{
  	long			OMsts,PWsts;
        OM_S_CHANSELECT         chan_to_comps;
        OM_S_OBJECT_LINKAGE     *comp_list;
	int			cnt;
	GRclassid		sk_classid;
        OMuint			count;

        OMsts = OM_S_SUCCESS;
        PWsts = PW_K_Success;
 
        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        count = 0;

        OMsts = om$get_classid (objid = comp_curve, osnum = os,
                                p_classid = &sk_classid);
        if (!(1&OMsts))
        {
           PWsts = SetError (PW_K_Pathway, PW_K_Internal);
           goto wrapup;
        }

        /*
         * Error out if the first element is not an Composite Curve 
         */
        if ((sk_classid != OPP_SKcompcurve_class_id) && 
		(sk_classid != OPP_GRcompcurve_class_id)) 
        {
           PWsts = SetError(PW_K_Pathway,PW_K_InvalidArg) ;
           goto wrapup;
        }
   
	OMsts = om$get_channel_count ( objid = comp_curve, 
				       osnum = os,
				       p_chanselect = &chan_to_comps,
				       count = &count);
 	if (count)
  	{
    	   comp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * 
				sizeof ( OM_S_OBJECT_LINKAGE ) );
           OMsts = om$get_channel_objects (list = comp_list, 
				           size = count,
                                       	   count = &count,
                                           objid = comp_curve,
					   osnum = os,
                                           p_chanselect = &chan_to_comps);
	   if (!(1&OMsts))
	   {
	      PWsts = SetError (PW_K_Pathway, PW_K_Internal);
	      goto wrapup;
	   }
	}
	for(cnt=0;cnt<count;cnt++)
	  components[cnt] = comp_list[cnt].S_objid;
wrapup:
   PW_Wrapup (PWsts, "pwGetCvComponents");
   return (PWsts);
}

/*
  ABSTRACT
        This returns the number of curve componets of the given Composite
        Curve or a GR compcurve.

  ARGUMENTS
        PWobjid       I         comp_curve
        PWosnum       I         os

  RETURN VALUES
        int                     Number of profile components

  HISTORY

     Satya   02/26/96   Creation

*/

int pwNumCvComponents 
( 
  PWobjid comp_curve,
  PWosnum os
)
{
  	long			OMsts;
        OM_S_CHANSELECT         chan_to_comps;
        OMuint			count;

        OMsts = OM_S_SUCCESS;

        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        count = 0;

	OMsts = om$get_channel_count ( objid = comp_curve, 
				       osnum = os,
				       p_chanselect = &chan_to_comps,
				       count = &count);
	return((int)count);
}

/*
  ABSTRACT
	Extracts the active reference plane on which the given profile is
	placed

  DESCRIPTION
	The API takes a profile objid as the input and from that extracts
	the objid of the current reference plane to which the profile
	is attached and it is returned.

  ARGUMENTS
	PWobjid 		profile_id
	PWosnum 		os

  RETURN CODE

     PWobjid	      - On Success
     PW_K_NullObjid   - On Failure

  KEYWORDS


  CAVEATS
 
  HISTORY

     Satya   02/26/96   Creation 

*/

PWobjid pwGetRefPlane 
( 
  PWobjid profile_id,
  PWosnum os
)
{
  	long			OMsts;
        OM_S_CHANSELECT         chan_to_parents;
        OM_S_OBJECT_LINKAGE     ptlinkage[2];
        OMuint			count;

        OMsts = OM_S_SUCCESS;

  	EMmake_chanselect ( NDfather_father, &chan_to_parents);
	OMsts = om$get_channel_objects (list = ptlinkage, size = 1, 
					objid = profile_id, 
					osnum = os,
					p_chanselect = &chan_to_parents,
					count = &count);
	if (!(1&OMsts) || !count)
	   return(PW_K_NullObjid);
	else
	   return(ptlinkage[0].S_objid);
}
 
PWresult pwProfileXformMat
(
  PWobjid profile_id,
  PWosnum os,
  short inp_mattyp,
  PWmatrix   inp_mat, 
  short  *xyz_xy_mattyp,
  PWmatrix xyz_xy_mat,
  short  *xy_xyz_mattyp,
  PWmatrix xy_xyz_mat
)
{
         long OMsts,PWsts,OMmsg;

         OMmsg = EMS_S_Success;
	 PWsts = PW_K_Success;
         OMsts = OM_S_SUCCESS;

         if((xyz_xy_mat != NULL) && (xyz_xy_mattyp != NULL))
         {
           OMsts = om$send (msg = message SKmgr.SKget_xymat (&OMmsg,
                            SK_OPT_GET_XYZ_TO_XY, &inp_mattyp, inp_mat, 
                            xyz_xy_mattyp, xyz_xy_mat),
                            targetid = profile_id,
                            targetos = os,
                            senderid=NULL_OBJID);
           if (!(1&OMsts&OMmsg))
           {
             PWsts = SetError (PW_K_Pathway, PW_K_Internal);
             goto wrapup;
           }
         }
         if((xy_xyz_mat != NULL) && (xy_xyz_mattyp != NULL))
         {
           OMsts = om$send (msg = message SKmgr.SKget_xymat (&OMmsg,
                      SK_OPT_GET_XY_TO_XYZ, &inp_mattyp, inp_mat, 
                      xy_xyz_mattyp, xy_xyz_mat),
                      targetid = profile_id,
                      targetos = os,
                      senderid=NULL_OBJID);
           if (!(1&OMsts&OMmsg))
           {
             PWsts = SetError (PW_K_Pathway, PW_K_Internal);
             goto wrapup;
           }
         }

wrapup:
   PW_Wrapup (PWsts, "pwProfileXformMat");
   return(PWsts);
}

end implementation SKmgr;
