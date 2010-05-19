/* $Id: SMCmpInterFn.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCmpInterFn.I
 *
 * Description:
 *
 *      Implements the function SMCompIntersect.
 *
 * Dependencies:
 *
 *      Root
 *
 * Revision History:
 *	$Log: SMCmpInterFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 * 22 Jun 1993	Raju	creation
 * 02 Dec 1993	Ad Z	V2.3 correction
 *			EMS_SFINT_PROCDUPLICATE -> EMS_SFINT_SKIPFIXING
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;


#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "ex.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "bserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
extern OMuword OPP_EMSsolid_class_id;

from EMSsurface import GRgetrang;


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCompIntersect

  Abstract


   	This function finds out if there is an intersection between the given
	solid of compartment and a plane.


  Returns
         OM_S_SUCCESS if success
         OM_E_ABORT   if fails
 -------------------------------------------------------------------------
*/
int  SMCompIntersect (
struct GRvg_construct *construct_list,  /* [I] for intersect_surfaces   */
struct IGRplane *plane,			/* [I] input plane		*/
struct GRlc_info *located_object,	/* [I] info of Solid		*/
struct GRid *SolidId,			/* [I] input solid		*/
int *numinters,				/* [O] = 0, no intersection,
						 1, intersection exits  */
int *EMmsg				/* [O] return message		*/
)
/*
-fi */
{
 IGRlong                 sts, rc;
 GRrange                 Solid_range;
 IGRboolean              world;
 struct IGRbsp_surface   plane_to_intersect;
 IGRboolean              inrange;
 extern  void 		 BSplptnorrg();
 IGRpoint                plane_poles[4];
 IGRdouble               u_knots[4],v_knots[4];
 struct GRmd_env	 *SolidEnv;
 IGRshort                outworld_opt, trim_opt, outparam_opt, inters_opt;
 struct EMSdataselect    other_data;
 extern IGRlong		 EMintersect_surfaces();
 OMuword		 SolidClass;
 struct EMSinters	 *sf_inters[2];

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 *numinters = 0;

 world = TRUE;
 SolidEnv = &located_object->module_info;


/* Get range of the solid
*/
 sts = om$send(msg=message EMSsurface.GRgetrang
         (&rc, &SolidEnv->md_env.matrix_type, SolidEnv->md_env.matrix, 
 	  &world,Solid_range), targetid = SolidId->objid,
			    targetos = SolidId->osnum,
			    senderid = NULL_OBJID);
 if(!(1&rc&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
 else *EMmsg = EMS_S_Success;

/* Get the plane definition which encompases the surface range.
*/
 plane_to_intersect.poles = (IGRdouble *) plane_poles;
 plane_to_intersect.u_knots = u_knots;
 plane_to_intersect.v_knots = v_knots;

 BSplptnorrg(Solid_range,&Solid_range[3],plane->point,plane->normal,1.1,
                &inrange,&plane_to_intersect,&rc);
 if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
 else *EMmsg = EMS_S_Success;



/*  Intersect the plane with the surface.
*/

 other_data.datatype = EMSdata_surface;
 other_data.data.surface = &plane_to_intersect;


 outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT;

 outworld_opt = EMSINT_OUTPUT_WORLD ;


 trim_opt = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA | EMSINT_TRIM_COPLANAR
	    | EMSINT_TRIM_PROCOVERLAP;

 inters_opt = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_SKIPFIXING;

 sts = om$get_classid(objid = SolidId->objid, p_classid = &SolidClass);
 if( (sts = om$is_ancestry_valid(subclassid = SolidClass, 
				 superclassid = OPP_EMSsolid_class_id))
    == OM_S_SUCCESS)
  inters_opt |= EMS_SFINT_MUSTCLOSE | EMS_SFINT_AUTODOUBLECHECK;
 else sts = OM_S_SUCCESS;


 sf_inters[0] = sf_inters[1] = NULL;

 sts = EMintersect_surfaces(EMmsg, SolidId, &SolidEnv->md_env, 1, &other_data,
				&construct_list->env_info->md_env, inters_opt, outworld_opt, 
				outparam_opt, trim_opt, construct_list,
				numinters, &(sf_inters[0]),&(sf_inters[1]),
				NULL, NULL, NULL, NULL, NULL);
 if(!*numinters || (*EMmsg == EMS_I_NotFound))
  {
   *numinters = 0;
   *EMmsg = EMS_I_NoIntersection;
   sts = OM_S_SUCCESS;	/* 09-Jan-91 -- SM */
   goto wrapup;
  }
 else *numinters = 1;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

wrapup:

 EMWRAPUP(*EMmsg,sts,"In SMCompIntersect\n");
 return(sts);

}

end implementation Root;

