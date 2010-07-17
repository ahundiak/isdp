/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/pin_jig/VLklStrLines.I
 *
 * Description: Key Lines Implementation.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/12/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "EMSmsgdef.h"
#include "VDobj.h"
#include "VDmem.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "vsbmaxisdef.h"
#include "vlquerydef.h"
#include "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

extern VLgetMacrosAtStep();

IGRlong	VLklGetStructuralLines(	IGRlong			*msg,
				struct GRobj_env	*plate,
				IGRint			*count,
				struct GRid		**lines )
{
IGRlong			sts;
IGRint			i, stf_count=0;
GRname			frm_name;
struct GRid		par_bmaxis, frm_pln, cp_obj;
struct GRvg_construct	cst;
struct GRobj_env	axis_gr, *stf_list=NULL;

   SetProc( VLklGetStructuralLines );

   if( !plate || !count || !lines ) return OM_E_INVARG;

   VLinitCnst( &cst );

   VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
                      VLgetMacrosAtStep, &stf_count, &stf_list );
   VLfilterDef( stf_count, stf_list, &stf_count, "VSstfBeam" );
   __DBGpr_int("Number of Stiffeners on the plate ", stf_count );

   if( !(*lines) || !(*count) )
   {
       if( !( *lines = _MALLOC( stf_count, struct GRid )) ) vd_$mem_fail();
   }
   else
   {
       if( !( *lines = _REALLOC( *lines, (*count)+stf_count,
			struct GRid )) ) vd_$mem_fail() ; 
   }

   for( i=0; i<stf_count; ++i )
   {
       __DBGpr_int("Checking ", i );
       __DBGpr_obj("Stiffener Object ", stf_list[i].obj_id );

       vdobj$GetParent(	objID      = &stf_list[i].obj_id,
			idx        = 1,
			parentID   = &par_bmaxis );	
       __DBGpr_obj("Beam Axis for this Stiffener ", par_bmaxis );

       vdobj$GetParent( objID      = &par_bmaxis,
			idx        = 1, 
                        parentID   = &frm_pln );
       __DBGpr_obj("Infinite Frame for this Axis ", frm_pln );

       vdobj$Get( objID = &frm_pln, objName = frm_name );
       __DBGpr_str("Frame Name ", frm_name );

       vdobj$GetFoot( objID    = &par_bmaxis,
		      footName = VS_K_baBmAxis,
		      footOE   = &axis_gr ); 

       vd_$grCopy( msg		= msg,
		   frEnv	= &axis_gr.mod_env,
		   frObj	= &axis_gr.obj_id,
		   toEnv	= cst.env_info,
		   toObj	= &cp_obj	);

       VLcreateKLJunction( msg, &cp_obj, cst.env_info, 
			   frm_name, &(*lines)[(*count)++] );
   }
   __DBGpr_objlist("Stiffener Trace ", stf_count, 
			&(*lines)[(*count)-stf_count] );

wrapup:
   _FREE( stf_list );
   End
   return sts;
}

end implementation VDSroot;
