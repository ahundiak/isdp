class implementation VLmrkLine;

//+*****************************************************************************
//
//	Implementation of object defining the mark of a Struct 
//		   stiffener or plate on a plate. The result is usually a
//		   curve defining the side of the marking object which touches
//		   the corresponding plate along with an offset (malconta) which
//		   indicates the width of the marking object.  The main curve
//		   may be trimmed across boundaries and the offset is usually a
//		   short curve of a 100 units, a third of the way along the
//		   length of the marking object.
//		   
//===========================================================================***

#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "madef.h"
#include "ma.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "nddef.h"
#include "asmacros.h"
#include "vsglobalmsg.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsstfnrdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbeam.h"
#include "vlstructure.h"
#include "vds.h"
#include "vlmsg.h"

/********************************** DEBUG flags	***********************

#ifndef MARKERDEBUG

#define MARKERDEBUG	1 
#define vsDEBUG		1
#define vserrDEBUG	1

#endif

*********************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vlmark.h"

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

#define EPS 1e-5
#define MALCONTA 8

//   *********c	External Functions

#include "bscvarrev0.h"
#include "bsplplintop.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsptnorsf.h"
#include "matypemx.h"
#include "mascalmx.h"
#include "maarcptan.h"
#include "mabcinpl.h"
#include "malpfrln.h"		// line perp to another
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bssfeval.h"
#include "bsptnorsf.h"
#include "bssur_sur.h"
#include "bsplplintop.h"	// BSplplintop

//extern IGRboolean MAlpfrln (IGRlong *messg, struct MAline *ln, IGRpoint pt,
//IGRvector n, struct MAline *line );

extern 			ASmake_source_from_env( struct GRid *,
						struct GRmd_env *,
						struct GRid *,
						int	),

			VLseekFields ( struct ACrg_coll*, int, char* );
 
 // see VLtoolFunk.I
extern			IntTwoSrf( IGRboolean, IGRboolean,
				   struct GRlc_info *, struct GRlc_info *,
				   struct GRvg_construct *, IGRint *,
				   struct GRid *, IGRlong * ),

get_extsurf_geom(
        struct GRid             *surf_ptr  ,                    /* I */
        struct GRmd_env         *surf_mod_env_ptr ,             /* I */
        IGRdouble               extent ,                        /* I */
        struct IGRbsp_surface   **ext_surf_geom_ptrptr ) ;      /* O */


extern	long EMintersect_two_element ( 

	struct          GRlc_info *object_1,
	struct          GRlc_info *object_2,
	IGRushort       trimming_options,
	struct          GRvg_construct *construct_list,
	IGRlong         *num_inters,
	struct GRid     **inters,
	IGRlong         *msg  ) ;

extern  double	fabs( double );

//********************c  External Methods

from	ACrg_collect	import	AClist_attribute,
				ACmod_list_attribute,
				ACadd_list_attribute;

from  GRcurve	import	GRendpts,
			GRmidpoint ;

from  VSstfBeam	import	VSgetPlateSide;

from  VSfeature	import	VSgetResultType,
			VSforwardToSource  ; 

from  EMSsubbs	import	EMproject_curve_onto_surface,
			EMproject_curve_along_surface_normals,
			EMisoparcvs;

// from	GRgraphics	import GRgetname;

// External variables

extern	GRclassid
			OPP_GR3dlinestr_class_id,
			OPP_GR3dlineseg_class_id,
			OPP_VSplate_class_id ,
			OPP_VSfeature_class_id ,
			OPP_VSimgFeature_class_id,
			OPP_VSbeam_class_id ,
			OPP_ACpretend_class_id ;


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

method VLplace_mark(
               IGRlong	*	ret;		// standard return code
               int		TypeSide;	// which side of plate to mark
               int		IntsTypeSide;	// which side of stiffnto take
               IGRint		count;		// number of object in list
               struct GRobj_env list[];		// list of templates
               struct GRmd_env  *md_env		// module of current file
              )
{
  struct GRid	temp[VLMrkMaxNumTemplates];	// templates for this object

  struct	ACrg_coll ACrg[ VLMrkParams];   // collections for param templ

  IGRlong	l_msg	= MSFAIL;		// long return from methods

  IGRint	sts	= OM_E_INVARG,		// status from messages
		i_msg   = MSFAIL,		// int  return from methods
		paramIndex,			// index of param in collectn
		j;				// counter

  if ( !ret || !md_env || !list || !count ) {
	__DBGpr_int( " Problem with arguments? ret ", ret );
	__DBGpr_int( " Problem with arguments? md_env ", md_env );
	__DBGpr_int( " Problem with arguments? list", list );
	__DBGpr_int( " Problem with arguments? count", count );
	goto wrapup;
  }

  *ret = MSFAIL;

  paramIndex = 0;
  strcpy( ACrg[paramIndex].name,  VLTypeSide );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = TypeSide;
  paramIndex++;

  strcpy(ACrg[paramIndex].name,  VLIntsTypeSide );
  ACrg[paramIndex].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[paramIndex].desc.value.att_exp = IntsTypeSide;
  paramIndex++;

  temp[ VLMrkCollIndex].osnum = md_env->md_id.osnum;
  sts = om$construct(classid	= OPP_ACrg_collect_class_id,
                        osnum   = temp[ VLMrkCollIndex].osnum,
                        p_objid = &temp[ VLMrkCollIndex].objid);

  __CheckRC( sts, 1, "Mark: OMconstruct ACrg_collect ", wrapup ) ;

  sts = om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
           targetid = temp[ VLMrkCollIndex].objid,
           targetos = temp[ VLMrkCollIndex].osnum );

  __CheckRC( sts, 1, "Mark: NDchg_state for ACrg_collect ", wrapup ) ;

  sts = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   				     (&l_msg, paramIndex, ACrg),
              targetid = temp[ VLMrkCollIndex].objid,
              targetos = temp[ VLMrkCollIndex].osnum);

  __CheckRC( sts, l_msg, "Mark: ACrg_collect.ACadd_list ", wrapup ) ;

  for (j=0,paramIndex= VLMrkPlateIndex; j<count; j++,paramIndex++ )
  {
   as$make_source( go_grid	= list[j].obj_id,
                    mod_env	= &list[j].mod_env,
                    as_os	= md_env.md_id.osnum,
                    as_grid	= &temp[paramIndex]);
  }

  sts = om$send(  msg  = message VLmrkLine.ACmplace(
                                          &i_msg,
                                          AChdr_noprotect | AChdr_nodisplay, 
					  0,
                                           VLMacroMark	,
                                           //VLMrkNumTemplates,
					  count+1,
                                          temp,
                                          md_env ),
                 targetid = my_id );

  __CheckRC( sts, i_msg, "Mark: ACncpx.ACmplace ", wrapup ) ;

  *ret = OM_S_SUCCESS;

wrapup:			// ******  WRAPUP HERE		**************

  return sts;

}		// end place mark

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++**

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjMarkingLine;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLmrkLine;

