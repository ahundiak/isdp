/*
	 VDS 2.0 - PPM macro library - 92/07/09 (alc)
		Warning - temporary file (see Ludo) -
 */

class implementation GRvg;	/* NOT a method */

#include "EMS.h"
/*
Notes
  This function intersects two graphics elements and returns the intersections
  in the form of objects constructed in the OS specified in the construct
  list.
  The valid combinations are -

  object_1				object_2
  --------                              --------
  curve/comp curve			  --	(Self intersection)
  curve/comp curve			curve/comp curve
  curve/comp curve			surf/comp surf
  surf/comp surf			surf/comp surf

Arguments

  object_1	input		info for object 1.

  object_2	input		info for object 2 (This arguments should
				be NULL or same as object_1 for self 
				intersection in case of curves)
				
  construct_list input		For intersection objects to be constructed.

  num_inters output Number of intersection objects being returned.

  inters	 output		GRids of intersection objects. No memory
				should be allocated upon input. Memory
				is allocated in the function
				UNCONDITIOANLLY.
History

  SM	04-Jan-88	Genesis.
  SM    04-Apr-88	Changed to do trace and then to call the function
			EMfix_sfint_uvtrace to cause refinement of surface
			surface intersection results.
  rlw   30-May-88       Added addition argument in order to be able to turn
                        trimming off.  I changed the routine name such that
                        callers would be aware that the function has changed.
  rlw   02-Mar-89       Modified to add conditional compilation statements
                        for the I/DRAW product.
  SS    18-Sep-89	Changed the "trimming_required" argument to
			"trim_opt".
  SM	26-Jan-90	fixed to handle solid/curve combo.
  LLC   22-june-92	In surf_surf case set inters_opt with EMS_SFINT_NOREFINE;
			Modification valid until EMS20.
*/

#define DEBUG 0

#if DEBUG
#include <stdio.h>
#endif

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */


/* lc.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMlimits_include
# include "OMlimits.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

# ifndef lcdef_include
# include "lcdef.h"
# endif

# ifndef lc_include
# include "lc.h"
# endif

# ifndef lcmacros_include
# include "lcmacros.h"
# endif

/* end of lc.h replacement */

#include "emsdattyp.h"                  /* enum EMSdata_ etc. */
#include "emsinter.h"                   /* struct defintions for int. */
#include "EMSmsgdef.h"                  /* EMS return codes */
#include "OMprimitives.h"
#include "OMmacros.h"                   /* OM_BLOCK_MOVE */
#include "emserr.h"                     /* EMerr_hndlr */
#include "emssfintdef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsinterdef.h"

#define	CURVE	1
#define SURF	2
#define SOL	3
#define UNKNOWN 4

#ifndef IDRAW
extern OMuword OPP_EMSsurface_class_id, OPP_EMSsolid_class_id;
#endif
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRbcsubbc_class_id, OPP_GRlinear_class_id;

from GRcurve import EMcrvcrvint, EMcrvslfint;
#ifndef IDRAW
from EMSsurface import EMsfsfint, EMcrvsrfint;
from EMSedge import EMget_props_type;
#endif

#ifndef IDRAW  
extern IGRboolean _use_infinite_plane;
#endif

IGRlong LLCintersect_two_element(
 object_1,
 object_2,
 trimming_options,
 construct_list,
 num_inters,
 inters,
 msg)

struct		GRlc_info *object_1;
struct		GRlc_info *object_2;
unsigned 	IGRshort trimming_options;
struct		GRvg_construct *construct_list;
IGRlong		*num_inters;
struct GRid	**inters;
IGRlong		*msg;
{
  IGRlong		sts, rc;
  struct GRid		obj1, obj2;
  OMuword		class1, class2;
  IGRint		type1 = UNKNOWN, 
			type2 = UNKNOWN;
  static IGRlong 	EMget_element_type();
  struct GRmd_env	*env1, *env2;
  IGRlong		pnt_slots, crv_slots, num_pts, num_crv;
  struct GRid		*pnt_ids, *crv_ids;
  IGRshort              outworld_opt, outparam_opt, inters_opt;
  struct EMSdataselect  other_data;
  IGRint		i, j, m;
  IGRshort              *mat_type;
  IGRdouble             *matrix;
  OMuword		crv_classid;
  extern IGRlong	EMintersect_surfaces();


  /*
     Initialize.
  */
  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  pnt_slots = num_pts = crv_slots = num_crv = 0;
  pnt_ids = crv_ids = NULL;
  *num_inters = 0;
  if(inters) *inters = NULL;

  OM_BLOCK_MOVE(&object_1->located_obj, &obj1, sizeof(struct GRid));
  sts = EMget_element_type(obj1, &type1);
  EMerr_hndlr(type1 == UNKNOWN, *msg, EMS_E_InvalidArg, wrapup);
  env1 = &object_1->module_info;


  if(object_2)
   {
    OM_BLOCK_MOVE(&object_2->located_obj, &obj2, sizeof(struct GRid));
    sts = EMget_element_type(obj2, &type2);
    EMerr_hndlr(type2 == UNKNOWN, *msg, EMS_E_InvalidArg, wrapup);
    env2 = &object_2->module_info;
   }
  else obj2.objid = NULL_OBJID;


  /* If the second object is NULL_OBJID or same as the first one, 
     we have possibility of a self intersection (only for curves).
  */
  if(IF_NULL_OBJID(obj2.objid) ||
     (IF_EQ_OBJID(obj1.objid, obj2.objid) && (obj1.osnum == obj2.osnum)))
   {
     /* If curves, do self intersection. Else invalid argument.
     */
     if( (type1 == CURVE) && (type2 == CURVE) )
      {
	sts = om$send(msg = message GRcurve.EMcrvslfint(msg, construct_list, 
				&env1->md_env, &pnt_slots, &num_pts, 
				&pnt_ids, NULL, NULL, &crv_slots, &num_crv, 
				&crv_ids, NULL),
				senderid = obj1.objid, 
				targetid = obj1.objid, targetos = obj1.osnum);
	EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);
	EMerr_hndlr(!num_pts && !num_crv, *msg, EMS_I_NoIntersection, wrapup);
	
	if(!(*inters))
	   *inters = (struct GRid *) om$malloc(size = 
				(num_crv + num_pts) * sizeof(struct GRid));
	EMerr_hndlr(!(*inters), *msg, EMS_E_NoDynamicMemory, wrapup);
	if(pnt_ids)
	 OM_BLOCK_MOVE(pnt_ids, *inters, num_pts * sizeof(struct GRid));
	if(crv_ids)
	 OM_BLOCK_MOVE(crv_ids, &(*inters)[num_pts], 
				num_crv * sizeof(struct GRid));
	*num_inters = num_crv + num_pts;
	if(pnt_ids) om$dealloc(ptr = pnt_ids); pnt_ids = NULL;
	if(crv_ids) om$dealloc(ptr = crv_ids); crv_ids = NULL;
      }
     else
      {
	*msg = EMS_E_InvalidArg;
	goto wrapup;
      }
   } /* if self intersection */

  else
   {
     if( ((type1 == SURF) || (type1 == SOL)) && 
	 ((type2 == SURF) || (type2 == SOL)))
      {
	/* Surface-Surface intersection
	*/
#ifndef IDRAW	
        other_data.datatype = EMSdata_object;
        other_data.data.object = &obj2;

        if (trimming_options & EMSINT_TRIM_OUTPUT && !_use_infinite_plane)
         {
          if(inters)
           {
            outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT;
            outworld_opt = EMSINT_OUTPUT_WORLD;
	   }
	  else
	   {
            outparam_opt = NULL;
            outworld_opt = NULL;
	   }
	
          inters_opt = EMS_SFINT_PROCDUPLICATE;
          if( (type1 == SOL) && (type2 == SOL))
	    inters_opt |= EMS_SFINT_MUSTCLOSE | EMS_SFINT_AUTODOUBLECHECK;
         }
        else 
         {
         outparam_opt = NULL;
         outworld_opt = inters ? EMSINT_OUTPUT_WORLD : NULL;
         inters_opt = EMS_SFINT_NOREFINE;
         }

	/*| KLUDGE FOR CI_MACRO int_2_element */
	inters_opt	= EMS_SFINT_NOREFINE;

       if(inters)
        {
	 *inters = om$malloc(size = sizeof(struct GRid));
	 EMerr_hndlr(!*inters, *msg, EMS_E_NoDynamicMemory, wrapup);
	 (*inters)->osnum = construct_list->env_info->md_id.osnum;
	 (*inters)->objid = NULL_OBJID;
        }

	sts = EMintersect_surfaces
			(msg, &obj1, &env1->md_env, 1, &other_data, 
			 &env2->md_env, inters_opt, 
			 outworld_opt, outparam_opt, trimming_options,
			 construct_list, 
			 num_inters,
			 NULL, NULL, NULL, NULL, 
			 inters ? &(*inters)->objid : NULL, NULL, NULL);

        if (*msg == EMS_I_Interrupt)
         {
          *num_inters = 0;
          goto wrapup;
         }
	else if(!*num_inters || (*msg == EMS_I_NotFound))
	 {
	  *num_inters = 0;
	  *msg = EMS_I_NoIntersection;
	  goto wrapup;
         }
        else if(inters && !IF_NULL_OBJID((*inters)->objid)) *num_inters = 1;

	*msg = EMS_S_Success;	/* return whatever possible */
	sts = OM_S_SUCCESS;
#endif			
     } /* if( (type1 == SURF) && (type2 == SURF) ) */

     else if( (type1 == CURVE) && (type2 == CURVE))
      {
	sts = om$send(msg = message GRcurve.EMcrvcrvint(msg, construct_list, 
			&env1->md_env, NULL, &obj2, &env2->md_env, 
			NULL, &pnt_slots, &num_pts, &pnt_ids, NULL, NULL, 
			NULL, &crv_slots, &num_crv, &crv_ids, NULL, NULL), 
			senderid = obj1.objid, 
			targetid = obj1.objid, targetos = obj1.osnum);
	EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);
	EMerr_hndlr(!num_pts && !num_crv, *msg, EMS_I_NoIntersection, wrapup);
	
	if(!(*inters))
	   *inters = (struct GRid *) om$malloc(size = 
				(num_crv + num_pts) * sizeof(struct GRid));
	EMerr_hndlr(!(*inters), *msg, EMS_E_NoDynamicMemory, wrapup);
	if(pnt_ids)
	 OM_BLOCK_MOVE(pnt_ids, *inters, num_pts * sizeof(struct GRid));
	if(crv_ids)
	 OM_BLOCK_MOVE(crv_ids, &(*inters)[num_pts], 
				num_crv * sizeof(struct GRid));
	*num_inters = num_crv + num_pts;
	if(pnt_ids) om$dealloc(ptr = pnt_ids); pnt_ids = NULL;
	if(crv_ids) om$dealloc(ptr = crv_ids); crv_ids = NULL;
	
      } /* if( (type1 == CURVE) && (type2 == CURVE)) */

     else if( ((type1 == CURVE) && ((type2 == SURF) || (type2 == SOL))) ||
	      (((type1 == SURF) || (type1 == SOL)) &&  (type2 == CURVE))
	    )
      {
#ifndef IDRAW	
	struct GRmdenv_info *my_info, *other_info;
	struct GRid	    my_GRid, other_GRid;

	if( (type1 == SURF) || (type1 == SOL))
	 {
	   my_GRid = obj1;
	   my_info = &env1->md_env;
	   other_GRid = obj2;
	   other_info = &env2->md_env;
	 }
	else
	 {
	   my_GRid = obj2;
	   my_info = &env2->md_env;
	   other_GRid = obj1;
	   other_info = &env1->md_env;
	 }

	sts = om$send(msg = message EMSsurface.EMcrvsrfint(msg, construct_list,
			my_info, NULL, &other_GRid, other_info, FALSE, 
			&pnt_slots, num_inters, 
			inters, NULL, NULL, NULL, NULL), 
			senderid = my_GRid.objid, 
			targetid = my_GRid.objid, 
			targetos = my_GRid.osnum);
	EMerr_hndlr(!(1&*msg&sts), *msg, EMS_E_Fail, wrapup);
	EMerr_hndlr(!(*num_inters), *msg, 
				EMS_I_NoIntersection, wrapup);
#endif	
      } /* if CURVE - SURF */

     else
      {
	*msg = EMS_E_InvalidArg;
	goto wrapup;
      }

   }  /* if not self intersection */


wrapup:
if(pnt_ids) om$dealloc(ptr = pnt_ids);
if(crv_ids) om$dealloc(ptr = crv_ids);
EMWRAPUP(*msg, sts, "In EMinetrsect_two_elements");
return(sts);
}

static IGRlong EMget_element_type(obj, type)
  struct GRid	obj;
  IGRint	*type;
{
  IGRlong	sts = OM_S_SUCCESS;
  OMuword	class1;

  *type = UNKNOWN;  
  sts = om$get_classid(objid = obj.objid, osnum = obj.osnum, 
		       p_classid = &class1);
  if(!(1&sts)) goto wrapup;

#ifndef IDRAW
  if( (sts = om$is_ancestry_valid(subclassid = class1, 
	superclassid = OPP_EMSsolid_class_id)) == OM_S_SUCCESS)
    *type = SOL;
  else if( (sts = om$is_ancestry_valid(subclassid = class1, 
		superclassid = OPP_EMSsurface_class_id)) == OM_S_SUCCESS)
    *type = SURF;
  else
#endif
   {
     sts = om$is_ancestry_valid(subclassid = class1, 
				 superclassid = OPP_GRcurve_class_id);
     if(sts == OM_S_SUCCESS)
       *type = CURVE;
   }

wrapup:
	return(sts);
}
end implementation GRvg;
