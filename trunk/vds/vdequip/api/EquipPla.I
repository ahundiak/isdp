/* $Id: EquipPla.I,v 1.2 2001/06/18 20:53:42 ad Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/EquipPla.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EquipPla.I,v $
 *	Revision 1.2  2001/06/18 20:53:42  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/07/08  13:10:12  pinnacle
# Replaced: vdequip/api/EquipPla.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/10/29  17:24:12  pinnacle
# Place Equipment API
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/19/96	i-paris		created
 *	07/01/96	yzhu	        use  VDsetAttDrSymb	
 *
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include	"AS_status.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include	"macro.h"
#include	"acrepdef.h"
#include	"acrepmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"nd.h"
#include	"nddef.h"
#include	"ndmacros.h"
#include	"msmacros.h"
#include	"parametric.h"
#include	"acdef.h"
#include	"acmacros.h"
#include	"dp.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"PDUerror.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"VDScheckdef.h"
#include	"VDSpathdef.h"
#include	"VDSutil.h"
#include	"vdattmacros.h"

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"
#include	"v_dbgmacros.h"
#include 	"vddgndef.h"
#include 	"v_drw.h"


from	ACdb_info	import	ACset_db_info;
from	ACrg_collect	import	ACadd_list_attribute;
from	GRvg		import	GRputsymb;
from	NDnode		import	NDchg_state;
from	VDequipment	import	ACmplace_from_def;

extern	GRclassid	OPP_ACrg_collect_class_id,
			OPP_VDequipment_class_id;

/* ************************************************************************** */
IGRlong	VDconstructDynamicBox (	IGRlong		*msg,
				IGRint		DynNum,
			struct	VDcollector	DynCol[],
			struct	GRmd_env	*Env,
			struct	GRid		*dBox	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;
	IGRdouble	att_exp ;
	IGRchar		att_txt[ATTR_NAME];
struct	ACrg_coll	attr;

	/* Initialize */
	dBox->objid = NULL_OBJID;
	dBox->osnum = Env->md_id.osnum;

	/* Construct dynamic box */
	sts = om$construct ( classid = OPP_ACrg_collect_class_id,
                             osnum   = dBox->osnum,
                             p_objid = &dBox->objid );
        as$status ( sts    = sts,
                    msg    = "om$construct(DYNAMIC BOX)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* State state for dynamic box */
        sts = om$send ( msg = message NDnode.NDchg_state
                        ( ND_DEL_NO_CH|ND_WAIT_DEL, ND_DEL_NO_CH|ND_WAIT_DEL ),
                        senderid = NULL_OBJID,
                        targetid = dBox->objid,
                        targetos = dBox->osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDchg_state(DYNAMIC BOX)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Fill dynamic box */
        for ( i=0; i<DynNum; i++ ) {

		/* Init return values */
		att_exp = 0.0 ;
		att_txt[0] = '\0';

		/* Create a row */
		attr.desc.value.att_txt[0] = '\0';
		sts = vd$collectorGetRow ( msg = msg,
					   idx = i,
					   Col = DynCol,
					   Nam = attr.name,
					   Txt = att_txt,
					   Val = &att_exp);
                as$status ( sts    = sts,
                            msg    = "vd$collectorGetRow(Nam,Txt,Val i)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
		if (att_txt[0] == '\0'){
			attr.desc.type = AC_ATTRIB_DOUBLE;
			attr.desc.value.att_exp = att_exp ;
		}
		else{
			attr.desc.type = AC_ATTRIB_TEXT;
			strcpy( attr.desc.value.att_txt, att_txt );
		}

                sts = om$send ( msg = message ACrg_collect.ACadd_list_attribute
                                        ( msg, 1, &attr ),
                                senderid = NULL_OBJID,
                                targetid = dBox->objid,
                                targetos = dBox->osnum );
                as$status ( sts    = sts,
                            msg    = "ACrg_collect.ACadd_list_attribute(DYN)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDplaceEquip (		IGRlong		*msg,
				IGRint		TplNum,
			struct	VDcollector	TplCol[],
				IGRint		DynNum,
			struct	VDcollector	*DynCol,
			struct	VDdescriptor	*Desc,
				IGRint		rep,
				IGRchar		*DirPath,
				IGRchar		*RootName,
				IGRint		prop,
			struct	GRobj_env	*OccId	)
{
	IGRlong		sts=OM_S_SUCCESS;
	struct	GRid		*TplObj, dummy;
	struct	GRsymbology	symbology;
	IGRint		i, suc=1;
	IGRchar		typ[20], Name[DI_PATH_MAX];
        struct GRid             collId; /* for symbology collector */
        VD_drwOutputData        *output = NULL;

        SetProc ( VDplaceEquip ); Begin

	/* Initialize */
	TplObj = NULL;

	/* Attach macro library */
        sts = ac$construct_path ( mode = AC_ADD_PATH, name = Desc->MacLib );
        as$status ( sts    = sts,
                    msg    = "ac$construct_path()",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get equipment generic macro definition */
        sts = ac$find_macro_defn ( action          = ACfind_load,
                                   macro_name      = "VDequidef",
                                   p_macro_defn_id = &dummy );
        as$status ( sts    = sts,
                    msg    = "ac$find_macro_defn()",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Set static box object */
	sts = VDsetCollRow ( msg, &TplCol[0], NULL, &(Desc->StaBox), NULL,
			     NULL, NULL, NULL, FALSE );
	as$status ( sts    = sts,
                    msg    = "VDsetCollRow()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create dynamic box object */
	sts = VDconstructDynamicBox ( msg, DynNum, DynCol, &OccId->mod_env,
				      &dummy );
	as$status ( sts    = sts,
                    msg    = "VDconstructDynamicBox()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Set dynamic box object */
	sts = VDsetCollRow ( msg, &TplCol[1], NULL, &dummy, NULL,
			     NULL, NULL, NULL, FALSE );
	as$status ( sts    = sts,
                    msg    = "VDsetCollRow()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Convert template VDcollector to ID */
	sts = VDexpCollector ( msg, TplNum, TplCol );
	as$status ( sts    = sts,
                    msg    = "VDexpCollector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Make source on ID */
	sts = VDmakCollector ( msg, TplNum, TplCol );
	as$status ( sts    = sts,
                    msg    = "VDmakCollector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Check templates types */
	sts = VDchkCollector ( msg, TplNum, TplCol );
	as$status ( sts    = sts,
                    msg    = "VDchkCollector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory for templates */
	TplObj = om$calloc ( num = TplNum, structure = struct GRid );

	/* Get templates */
	for ( i=0; i<TplNum; i++ ) {
		sts = VDgetCollRow ( msg, &TplCol[i], NULL, &TplObj[i], NULL,
			     	     NULL, NULL, NULL, FALSE );
		as$status ( sts    = sts,
	                    msg    = "VDgetCollRow()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Construct equipment */
	sts = om$construct ( classid = OPP_VDequipment_class_id,
                             osnum   = OccId->obj_id.osnum,
                             p_objid = &OccId->obj_id.objid );
        as$status ( sts    = sts,
                    msg    = "om$construct(EQUIPMENT)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set default representation (if needed) */
        if ( (rep != AC_2D_REP) && (rep != AC_3D_REP) && (rep != AC_ENV_REP) ) {
                sts = ac$get_def_rep ( prep = &rep, esymb = &symbology );
                as$status ( sts    = sts,
                            msg    = "ac$get_def_rep()",
                            test   = (!(sts & 0x00000001)),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }

	/* Place equipment */
        dummy.objid = NULL_OBJID;
        dummy.osnum = OccId->mod_env.md_id.osnum;
	Desc->prop |= prop;
        if (Desc->HdrTyp == VD_OCC_CONS)	strcpy ( typ, "VDequicon" );
        else					strcpy ( typ, "VDequidef" );
        sts = om$send ( msg = message VDequipment.ACmplace_from_def (
                                        &suc,
                                        Desc->prop,
                                        rep,
                                        typ,
                                        TplNum,
                                        TplObj,
                                        &dummy,
                                        &OccId->mod_env ),
                        senderid = NULL_OBJID,
                        targetid = OccId->obj_id.objid,
                        targetos = OccId->obj_id.osnum );
        *msg = suc;
        as$status ( sts    = sts,
                    msg    = "ACconst.ACmplace_from_def",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get symbology */
       	ASget_active_symb ( &symbology.level, &symbology.display_attr );

        /* Change display */
        if (Desc->HdrSym)
		COmchg_var_symb ( Desc->HdrSym, &OccId->obj_id,
                                  symbology.level, &symbology.display_attr,
                                  &OccId->mod_env );

        /* yzhu attr.symb or user defined file for symbology driven */
        collId.objid = NULL_OBJID ;
        sts =
        VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
        if( (sts&*msg&1) ) {
           sts = VDsetAttDrSymb(msg, OccId->obj_id,OccId->mod_env,output);
           VD_drwFreeOutputData( &output ) ;
        }
        else {

           /* Take symbology from ASCII file */
           sts = vd$get_attr_symbology ( msg       = msg,
                                      path      = "config/attribute",
                                      file_name = "equip.att",
                                      obj       = &OccId->obj_id,
                                      obj_env   = &OccId->mod_env,
                                      symbology = &symbology );
           if (sts & 0x00000001 & (*msg)) {
                sts = om$send ( msg = message GRvg.GRputsymb
                                        ( msg, &symbology ),
                                senderid = NULL_OBJID,
                                targetid = OccId->obj_id.objid,
                                targetos = OccId->obj_id.osnum );
		as$status ( sts    = sts,
                            msg    = "GRvg.GRputsymb",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
           }
        }
        /* Name occurence if needed */
        if (RootName == NULL)	strcpy ( Name, Desc->MacNam );
        else			strcpy ( Name, RootName );
        if(Desc->HdrTyp != HDR_GRAPHIC) {
                sts = VDincrementalName ( msg, &OccId->obj_id, DirPath, Name );
                as$status ( sts    = sts,
                            msg    = "VDincrementalName",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }

        /* Set DB info */
	Desc->DbInfo.quantity = EQUIPMENT_OBJ;
        sts = om$send ( msg = message ACdb_info.ACset_db_info
					( msg, &Desc->DbInfo ),
                        senderid = NULL_OBJID,
                        targetid = OccId->obj_id.objid,
                        targetos = OccId->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "ACdb_info.ACset_db_info",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        /* Display equipment occurence */
        sts = gr$display_object ( object_id = &OccId->obj_id,
                                  md_env    = &OccId->mod_env );
        as$status ( sts    = sts,
                    msg    = "gr$display_object",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:

	/* Delete macro occurence if something fails */
        if (!(sts & 0x00000001 & (*msg)))
                gr$delete_object ( msg       = msg,
                                   md_env    = &OccId->mod_env,
                                   object_id = &OccId->obj_id );

	/* Free memory */
	if (TplObj) {	om$dealloc (ptr = TplObj);	TplObj = NULL;	}

	return (sts);
}
/* ************************************************************************** */

end implementation Root;
