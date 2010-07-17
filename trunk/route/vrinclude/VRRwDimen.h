/* $Id: VRRwDimen.h,v 1.3 2002/04/24 19:12:26 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrinclude/VRRwDimen.h
 *
 * Description:
 * This file contains gadget definitions for dimension fields for raceway forms
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRRwDimen.h,v $
 *     Revision 1.3  2002/04/24 19:12:26  louis
 *     Modified 'struct VRRwCptetails' to include cpt shape for cr3902&cr3942 as a short variable.
 *
 *     Revision 1.2  2002/04/24 18:37:01  louis
 *     Modified 'struct VRRwCptetails' to include cpt shape for cr3902&cr3942
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:54  cvs
 *     Initial import to CVS
 *
 * Revision 1.5  2000/02/04  18:25:24  pinnacle
 * (No comment)
 *
 * Revision 1.4  1999/05/17  12:04:38  pinnacle
 * Replaced: vrinclude/VRRwDimen.h for:  by sbilla for route
 *
 * Revision 1.3  1999/05/17  11:49:12  pinnacle
 * Replaced: vrinclude/VRRwDimen.h for:  by sbilla for route
 *
 * Revision 1.2  1999/04/19  18:54:08  pinnacle
 * Replaced: vrinclude/VRRwDimen.h for: CR 179900491 by aharihar for route
 *
 * Revision 1.1  1999/04/18  07:52:08  pinnacle
 * Created for Raceway Multi Tier Enhancement.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      03/20/99   law          Created for Raceway Multi Tier enahancement
 *     Apr 20, 99  Anand        Added prototypes for VR_Build_Tier_Str
 *     05.17.99    Reddy        Added prototypes for VRFetchTierdata
 *     02.04.2000  Alwin        Added prototypes for 4 functions used for
 *								fetching the Material & Insulation info from DB
 *     04.24.2002  law          Included cpt section shape for cr3902&cr3942
 *************************************************************************/


#ifndef	vr_VRRwDimen_include

#define vr_VRRwDimen_include

#include <stdio.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"              /* struct IGRdisplay */
#include "gr.h"
#include "ex.h"
#include "FI.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dpstruct.h"           /* struct DPele_header */
#include "parametric.h"
#include "ACrg_collect.h"

/* Gadget labels defined only for Raceway Tier's */
#define ACTIVE_CPT_INDEX_TEXT		710
#define DECREASE_ACTIVE_CPT_INDEX	711	
#define ACTIVE_CPT_INDEX		712
#define INCREASE_ACTIVE_CPT_INDEX	713

#define FRM_TIER_SP_1			714
#define FRM_TIER_SP_2			715

#define FRM_NO_TIER_1			716
#define FRM_NO_TIER_2			717

#define FRM_DEPTH_1			718
#define FRM_DEPTH_2			719

#define FRM_WIDTH_1			720
#define FRM_WIDTH_2			721

struct VRRwCptDetails
{
  IGRdouble depth;
  IGRdouble width;
  IGRint    nb_tier;
  IGRshort  shape;
  IGRdouble tier_sp[10];
};

/* Place all the newly added functions prototypes */
extern IGRint VRRw_dimen_fields __(( 	Form form_ptr,
					IGRint gadget_id,
					struct GRid *CompId,
					struct GRmd_env *md_env,
					IGRint NbCpts,
					IGRint *active_cpt,
					IGRint proc_mode,
					IGRint shape_code,
					struct VRRwCptDetails *RwCptData,
					struct GRid *CollectorId ));

extern IGRint VRDelOldTierAttrs __((	struct GRid CompId, 
					struct GRmd_env *md_env ));

extern IGRlong VRGetComp_NbCpt 	__((	IGRlong     *msg,
     					IGRshort    application,  
     					IGRint      shape_code,
     					IGRchar     *spec_name,
     					IGRchar     *comp_code,
     					IGRint      *NbCpt ));

extern int VR_Build_Tier_Str __((	IGRint	ncpt,
					IGRint	ntier,
					IGRchar	*tierspstr,
					IGRchar	*notierstr ));

extern int VRFetchTierdata __((		struct GRmd_env *md_env,
					IGRint 		cpt_ndx,
					struct 	GRid    cmpobj,
					IGRint 		obj_is_param,
					IGRint 		*no_tiers,
					IGRchar 	*tier_sp )) ;

/* following four function headers added by Alwin for CR179900696. These
are implemented in vrpdu/VRfunc.I file  */
extern IGRint VRHGet_Material_Insulation_ClassInfo __((
											  IGRlong     *msg,
											  IGRchar     *spec_name,
											  IGRint      *nbMaterialClass,
											  IGRchar     **material_class,
											  IGRint      *nbInsulationClass,
											  IGRchar     **insulation_class
											  ));

extern IGRint VRHGet_Material_Insulation_Thickness __((
											  IGRlong     *msg,               
											  IGRchar     *material_class,   
											  IGRdouble   *dMaterialThickness,
											  IGRchar     *insulation_class, 
											  IGRdouble   *dInsulThickness  
											  ));


extern IGRint VRUpdMaterial_InsulationList	__((
											  IGRchar     *form_ptr,
											  IGRboolean  bIsMaterial,
											  IGRchar     *szText, 
											  IGRint      gadget_to_update 
											  ));

extern IGRint VRUpdMaterial_InsulationThickness __((
											  IGRchar     *form_ptr,
											  IGRboolean  bIsMaterial,
											  IGRchar     *szText,
											  IGRint      gadget_to_update 
											  ));

#endif
