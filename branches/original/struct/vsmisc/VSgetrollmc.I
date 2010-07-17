
/* $Id $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        vsmisc/VSgetrollmc.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/31/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "exmacros.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"
#include "VDobj.h"
#include "vsdbgmacros.h"

#define vsDEBUG		1
#define vserrDEBUG	1

from	VSfeature	import		VSforwardToSource, VSforwardToOriginal;
from 	VSbeam		import		VSgetSupportAxis;
from 	ACcpx_defn	import		ACgive_name;

extern  GRclassid	OPP_nci_macro_class_id, OPP_VSbeamAxis_class_id;

extern   OM_S_CHANSELECT AS_to_owner;

/* --------------------- FCT VSgetRollMacOnStiff () ------------------- */
IGRlong VSgetRollMacOnStiff(  struct GRobj_env  *stiff,
                              IGRchar           *mac_name,
                              struct GRobj_env  *roll_mac       )
{
IGRlong                 sts, msg, notUsed;
IGRchar                 *axis_name=NULL;
struct GRid             axis_mac, macro_def;
struct GRobj_env        axis;

    SetProc( VSgetRollMacOnStiff ); Begin

    roll_mac->_objid = NULL_OBJID;
    __DBGpr_obj("Input Stiffener ", stiff->obj_id);
    sts = om$send(  msg = message VSfeature.VSforwardToOriginal(
                    &notUsed,
                    OM_e_wrt_object,
                    message VSbeam.VSgetSupportAxis(
                            &msg,
                            &stiff->mod_env,
                            &axis               )) ,
            senderid = NULL_OBJID,
            targetid = stiff->_objid,
            targetos = stiff->_osnum  );
    __CheckRC( sts, msg, "VSbeam.VSgetSupportAxis", wrapup ) ;
    __DBGpr_obj("Stiffener Axis(graphics)  ", axis.obj_id );

    sts = om$get_objid_at_index( osnum        = axis._osnum,
                                 objid        = axis._objid,
                                 p_chanselect = &AS_to_owner,
                                 index        = 0,
                                 objidaddr    = &axis_mac.objid,
                                 osnumaddr    = &axis_mac.osnum   );
    __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
    __DBGpr_obj("Stiffener Axis(macro) ", axis_mac );

    if( vs$is_ancestry_valid( object  = &axis_mac,
			      classid = OPP_VSbeamAxis_class_id ) )
    {
	struct GRobj_env	parentOE;

	__DBGpr_com("This is a VSbeamAxis object" );
        vdobj$GetTemplate( objID      = &axis_mac,
                           nth        = 1,
                           templateOE = &parentOE );
	__DBGpr_obj("Stiffener Axis Parent", parentOE.obj_id );

        sts = om$get_objid_at_index( osnum        = parentOE._osnum,
                                     objid        = parentOE._objid,
                                     p_chanselect = &AS_to_owner,
                                     index        = 0,
                                     objidaddr    = &axis_mac.objid,
                                     osnumaddr    = &axis_mac.osnum   );
        __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
        __DBGpr_obj("Stiffener Axis(macro) ", axis_mac );
    }

    if( ! vs$is_ancestry_valid( object  = &axis_mac,
                                classid = OPP_nci_macro_class_id ) )
    {
        __DBGpr_com("Stiffener Axis is NOT an nci_macro, going to wrapup");
        sts = OM_E_NOTIMPL;
        goto wrapup;
    }

    sts = om$send(  msg = message ACcpx.find_macro( &macro_def ),
                    senderid = NULL_OBJID,
                    targetid = axis_mac.objid,
                    targetos = axis_mac.osnum   );
    __CheckRC( sts, 1, "ACcpx.find_macro", wrapup ) ;

    sts = om$send( msg = message ACcpx_defn.ACgive_name( &axis_name ),
                   senderid = NULL_OBJID,
                   targetid = macro_def.objid,
                   targetos = macro_def.osnum   );
    __CheckRC( sts, 1, "ACcpx_defn.ACgive_name", wrapup ) ;
    __DBGpr_str("Axis Macro Name ", axis_name );


    if( !mac_name ) 
    { 
	roll_mac->obj_id  = axis_mac;
	roll_mac->mod_env = axis.mod_env;
	goto wrapup;
    }
    __DBGpr_str("Input Macro ", mac_name );

    if( !strlen( mac_name ) )
    {
        roll_mac->obj_id  = axis_mac;
        roll_mac->mod_env = axis.mod_env;
        goto wrapup;
    }

    if( strcmp(mac_name, axis_name) )
    {
        sts = OM_E_NOTIMPL;
        goto wrapup;
    }
    roll_mac->obj_id  = axis_mac;
    roll_mac->mod_env = axis.mod_env;
    sts = MSSUCC;

wrapup:
    __DBGpr_obj("Axis output is set to ", roll_mac->obj_id );
    End
    return sts;
}

/* --------------------- FCT VSgetSrfMacOnPlate () ------------------- */
IGRlong VSgetSrfMacOnPlate(  struct GRobj_env  *plate,
                              IGRchar           *mac_name,
                              struct GRobj_env  *srf_mac       )
{
IGRlong                 sts, msg, notUsed;
IGRint			ACrc;
IGRchar                 *srf_name=NULL;
struct GRid             supp_srf, macro_def;
struct GRobj_env        srf;

    SetProc( VSgetSrfMacOnPlate ); Begin

    srf_mac->_objid = NULL_OBJID;

    __DBGpr_obj("Input Plate ", plate->obj_id);
    sts = om$send(  msg = message VSfeature.VSforwardToSource(
                    &notUsed,
                    OM_e_wrt_object,
		    message ACcpx.ACfind_temp_obj(
					&ACrc,
					VS_K_plSuppSurf,
					&supp_srf ) ),
            senderid = NULL_OBJID,
            targetid = plate->_objid,
            targetos = plate->_osnum  );
    __CheckRC( sts, msg, "ACcpx.ACfind_temp_obj: Support Surface",  wrapup ) ;

    sts = om$send( msg = message NDmacro.ACreturn_foot( &msg, "",
					&srf.obj_id, &srf._matrix_type,
					srf._matrix ),
		senderid = NULL_OBJID,
		targetid = supp_srf.objid,
		targetos = supp_srf.osnum );
    __CheckRC( sts, msg, "NDmacro.ACreturn_foot",  wrapup ) ;
    srf._md_os = srf._osnum;
    sts = ex$get_modid( mod_osnum = srf._md_os,
		        mod_id    = &srf._md_id );
    __DBGpr_obj("Source Plate Support Surface ", srf.obj_id );

    if( ! vs$is_ancestry_valid( object  = &srf.obj_id,
                                classid = OPP_nci_macro_class_id ) )
    {
        __DBGpr_com("Plate Surface is NOT an nci_macro, going to wrapup");
        sts = OM_E_NOTIMPL;
        goto wrapup;
    }

    sts = om$send(  msg = message ACcpx.find_macro( &macro_def ),
                    senderid = NULL_OBJID,
                    targetid = srf._objid,
                    targetos = srf._osnum   );
    __CheckRC( sts, 1, "ACcpx.find_macro", wrapup ) ;

    sts = om$send( msg = message ACcpx_defn.ACgive_name( &srf_name ),
                   senderid = NULL_OBJID,
                   targetid = macro_def.objid,
                   targetos = macro_def.osnum   );
    __CheckRC( sts, 1, "ACcpx_defn.ACgive_name", wrapup ) ;
    __DBGpr_str("Surface Macro Name ", srf_name );

    if( !mac_name )
    {
	*srf_mac = srf;
	goto wrapup;
    }
    __DBGpr_str("Input Macro ", mac_name );

    if( !strlen(mac_name) )
    {
        *srf_mac = srf;
        goto wrapup;
    }

    if( strcmp(mac_name, srf_name) )
    {
        sts = OM_E_NOTIMPL;
        goto wrapup;
    }

    *srf_mac = srf;
    sts = MSSUCC;

wrapup:
    __DBGpr_obj("Surface output is set to ", srf_mac->obj_id );
    End
    return sts;
}

end implementation VDSroot;
