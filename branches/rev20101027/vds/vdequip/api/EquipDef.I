/* $Id: EquipDef.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/EquipDef.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EquipDef.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
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
#include	"macro.h"
#include	"acdef.h"
#include	"acmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"msmacros.h"
#include	"nddef.h"
#include	"PDUerror.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"VDSpathdef.h"
#include	"VDSutil.h"
#include	"vdbmacros.h"

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"

from	ACrg_collect	import	ACadd_list_attribute,
				ACchg_prop_mgr,
				AClist_attribute;
from	NDnode		import	NDchg_state;

extern	GRclassid	OPP_ACrg_collect_class_id;

/* ************************************************************************** */
IGRlong	VDisConnected (	IGRlong		*msg	)
{
	IGRint		sts=OM_S_SUCCESS;

	/* Initialize */
	*msg = MSFAIL;
	UI_prompt ( "" );

	/* Check PDU connection */
	if (VDSverify_login() != PDM_S_SUCCESS) {
		UI_status ( "User is not logged in to Database" );
		goto wrapup;
	}
	if (VDSverify_project() != OM_S_SUCCESS) {
                UI_status( "User not Selected Project" );
                goto wrapup;
        }

	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDconstructStaticBox (		IGRlong		*msg,
				struct	VDdescriptor	*Desc,
					IGRint		num,
				struct	ACrg_coll	att[],
				struct	ACrg_coll	mac	)
{
	IGRint		i, sts=OM_S_SUCCESS;

	/* Construct static box */
        sts = om$construct ( classid = OPP_ACrg_collect_class_id,
                             osnum   = Desc->StaBox.osnum,
                             p_objid = &Desc->StaBox.objid );
        as$status ( sts    = sts,
                    msg    = "om$construct(STATIC BOX)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* State state for static box */
        sts = om$send ( msg = message NDnode.NDchg_state
                        ( ND_DEL_NO_CH|ND_WAIT_DEL, ND_DEL_NO_CH|ND_WAIT_DEL ),
                        senderid = NULL_OBJID,
                        targetid = Desc->StaBox.objid,
                        targetos = Desc->StaBox.osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDchg_state(STATIC BOX)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Fill static box */
        for ( i=0; i<num; i++ ) {
                sts = om$send ( msg = message ACrg_collect.ACadd_list_attribute
                                        	( msg, 1, &att[i] ),
                                senderid = NULL_OBJID,
                                targetid = Desc->StaBox.objid,
                                targetos = Desc->StaBox.osnum );
                as$status ( sts    = sts,
                            msg    = "ACrg_collect.ACadd_list_attribute(STA)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }

	/* Add active macro in static box */
        sts = om$send ( msg = message ACrg_collect.ACadd_list_attribute
                                        ( msg, 1, &mac ),
                        senderid = NULL_OBJID,
                        targetid = Desc->StaBox.objid,
                        targetos = Desc->StaBox.osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACadd_list_attribute(MAC)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Lock static box */
        sts = om$send ( msg = message ACrg_collect.ACchg_prop_mgr
                ( AC_BOX_LOCKED|AC_BOX_CACHE, AC_BOX_LOCKED|AC_BOX_CACHE ),
                        senderid = NULL_OBJID,
                        targetid = Desc->StaBox.objid,
                        targetos = Desc->StaBox.osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACchg_prop_mgr(STA)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	  
wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetEquipDescription (		IGRlong		*msg,
					IGRchar		*CatName,
					IGRchar		*PartNum,
					IGRchar		*RevName,
					GRspacenum	ActiveOS,
				enum	ACm_poss_hdr	HdrTyp,
				struct	VDdescriptor	*Desc	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i, sNum=0, cnt=0;
struct	ACrg_coll	*sAtt;
struct	ACrg_coll	attr;
	IGRchar		search[DI_PATH_MAX], **buffer;

	/* Initialize */
	*msg = MSFAIL;
	Desc->HdrTyp = HdrTyp;
	sAtt = NULL;
	strcpy ( attr.name, "mac_name" );
        attr.desc.type = AC_ATTRIB_TEXT;
        strncpy ( attr.desc.value.att_txt, CatName, macro_MAX_CHAR );
	buffer = NULL;

	/* Initialize static collection object */
	Desc->StaBox.objid = NULL_OBJID;
	Desc->StaBox.osnum = ActiveOS;

	/* Check input */
	if (  (CatName  == NULL) || (CatName[0]  == '\0')
	   || (PartNum  == NULL) || (PartNum[0] == '\0')
	   || (RevName  == NULL) || (RevName[0]  == '\0') )	goto wrapup;

	/* Check connection with database */
	sts = VDisConnected ( msg );
	as$status ( sts    = sts,
                    msg    = "VDisConnected()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get static attributes */
	sts = VDSGetPartAtt ( CatName, PartNum, RevName, "EQUIP",
			      &sNum, &sAtt, NULL, NULL );
	UI_status ( "" );
	as$status ( sts    = sts,
                    msg    = "VDSget_attr(STATIC ATTRIBUTES)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get active macro */
        for ( i=0; i<sNum; i++ ) {
                if (!(strcmp( sAtt[i].name, "p_macro" ) ) ) {
                        strcpy ( attr.desc.value.att_txt,
                                 sAtt[i].desc.value.att_txt );
                        break;
                }
        }
        strcpy ( Desc->MacNam, attr.desc.value.att_txt );

	/* Set db_info */
        strcpy ( Desc->DbInfo.catalog,  CatName );
        strcpy ( Desc->DbInfo.part_num, PartNum );
        strcpy ( Desc->DbInfo.revision, RevName );

	/* Construct static box */
	sts = VDconstructStaticBox ( msg, Desc, sNum, sAtt, attr );
	as$status ( sts    = sts,
                    msg    = "VDconstructStaticBox()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Find library name */
        sprintf ( search,
                  "(%s = '%s') and (%s = '%s') and (%s = '%s') and (%s = '%s')",
                  "n_catalogname", CatName,
                  "p_macrocat",    "pdmlibraries",
                  "p_macrorev",    "vds",
                  "p_macroname",   attr.desc.value.att_txt );
        sts = vdb$RisSelect ( select     = "p_macropartno",
                              table_name = "pdmparamloc",
                              where      = search,
                              numselect  = 1,
                              p_numrows  = &cnt,
                              p_buffer   = &buffer );
        as$status ( sts    = sts,
                    msg    = "vdb$RisSelect(LIBRARY)",
                    test   = ( (sts !=1) || (cnt == 0) ),
                    action = GOTO_VALUE,
                    value  = wrapup );
        sts = vdb$RisExtractValue ( nbrows      = cnt,
                                    nbcolumns   = 1,
                                    buffer      = buffer,
                                    row         = 0,
                                    column      = 0,
                                    value       = Desc->MacLib );
        as$status ( sts    = sts,
                    msg    = "vdb$RisExtractValue(LIBRARY)",
                    test   = (sts !=1),
                    action = GOTO_VALUE,
                    value  = wrapup );
	  
wrapup:
	if (buffer)     vdb$RisFreeBuffer ( buffer = buffer,
                                            size   = cnt );
	if (sAtt) {	om$dealloc (ptr = sAtt);	sAtt = NULL;	}
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetCollectorFromEquipDef (	IGRlong		*msg,
					IGRchar		*CatName,
					IGRchar		*PartNum,
					IGRchar		*RevName,
					IGRint		*TplNum,
				struct	VDcollector	**TplCol,
					IGRint		*DynNum,
				struct	VDcollector	**DynCol	)
{
	IGRlong		sts=OM_S_SUCCESS, siz=sizeof(struct GRmd_env), ret;
	IGRint		i, dNum=0;
struct	GRmd_env	Env;
struct	ACrg_coll	*dAtt;

	/* Initialize */
	*msg = MSFAIL;
	*TplNum = 0;
	*TplCol = NULL;
	*DynNum = 0;
	*DynCol = NULL;
	dAtt = NULL;

	/* Get current environment */
        sts = gr$get_module_env ( msg    = msg,
                                  sizbuf = &siz,
                                  buffer = &Env,
                                  nret   = &ret );

	/* Check input */
	if (  (CatName  == NULL) || (CatName[0]  == '\0')
	   || (PartNum  == NULL) || (PartNum[0] == '\0')
	   || (RevName  == NULL) || (RevName[0]  == '\0') )	goto wrapup;

	/* Check connection with database */
	sts = VDisConnected ( msg );
	as$status ( sts    = sts,
                    msg    = "VDisConnected()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get dynamic attributes */
	sts = VDSGetPartAtt ( CatName, PartNum, RevName, "EQUIP",
			      NULL, NULL, &dNum, &dAtt );
	UI_status ( "" );
	as$status ( sts    = sts,
                    msg    = "VDSget_attr(DYNAMIC ATTRIBUTES)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Construct template collector */
	sts = vd$getMacDefCollector ( msg	= msg,
				      MacDef	= "VDequidef",
				      TplNum	= TplNum,
				      TplCol	= TplCol );
	as$status ( sts    = sts,
                    msg    = "vd$getMacDefCollector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Set private to attribute 0 and 1 (attributes boxes) */
	if (*TplNum >= 2) {
		(*TplCol)[0].prop &= ~VD_COL_FREE;
		(*TplCol)[1].prop &= ~VD_COL_FREE;
	}

	/* Construct dynamic collector */
	if (dNum <= 0)	goto wrapup;
	*DynNum = dNum;
	sts = vd$collectorConstruct ( msg = msg,
				      Num = *DynNum,
				      Col = DynCol );
	as$status ( sts    = sts,
                    msg    = "vd$collectorConstruct()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Fill dynamic collector */
	for ( i=0; i<(*DynNum); i++ ) {
		sts = vd$collectorSetRow ( msg = msg,
					   idx = i,
					   Col = *DynCol,
					   Nam = dAtt[i].name );
		as$status ( sts    = sts,
	                    msg    = "vd$collectorSetRow(Nam i)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		switch (dAtt[i].desc.type) {

			case AC_ATTRIB_TEXT:
				sts = vd$collectorSetRow (
					msg = msg,
					idx = i,
					Col = *DynCol,
					Txt = dAtt[i].desc.value.att_txt );
				as$status ( sts    = sts,
msg    = "vd$collectorSetRow(Txt i)",
test   = (!(sts & 0x00000001 & (*msg))),
			                    action = GOTO_VALUE,
			                    value  = wrapup );
				break;

			case AC_ATTRIB_DOUBLE:
				sts = vd$collectorSetRow (
					msg = msg,
					idx = i,
					Col = *DynCol,
					Val = &dAtt[i].desc.value.att_exp );
				as$status ( sts    = sts,
msg    = "vd$collectorSetRow(Val i)",
test   = (!(sts & 0x00000001 & (*msg))),
			                    action = GOTO_VALUE,
			                    value  = wrapup );
				break;
		}
	}

wrapup:
	if (dAtt) {	om$dealloc (ptr = dAtt);	dAtt = NULL;	}
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetCollectorFromEquipOcc (		IGRlong		*msg,
					struct	VDcollector	*OccCol,
						IGRint		*TplNum,
					struct	VDcollector	**TplCol,
						IGRint		*DynNum,
					struct	VDcollector	**DynCol )
{
	IGRlong		sts=OM_S_SUCCESS;
struct	GRid		DynId;
struct	ACrg_coll	*attr;
	IGRint		i;

	/* Initialize */
	*DynNum = 0;
	*DynCol = NULL;
	attr	= NULL;

	/* Get templates' collector */
	if ( (TplNum != NULL) && (TplCol != NULL) ) {

		*TplNum = 0;
		*TplCol = NULL;
		sts = vd$getMacOccCollector ( msg    = msg,
					      OccCol = OccCol,
					      TplNum = TplNum,
					      TplCol = TplCol );
		as$status ( sts    = sts,
	                    msg    = "vd$getMacOccCollector()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		if (*TplNum <= 2) {
			*TplNum = 0;
			om$dealloc (ptr = *TplCol);
			*TplCol = NULL;
		}
		else {	/* Set private prop to static & dynamic boxes */
			(*TplCol)[0].prop &= ~VD_COL_FREE;
			(*TplCol)[1].prop &= ~VD_COL_FREE;
		}
	}

	/* Get dynamic attributes collection */
	sts = VDgetCollRow ( msg, &(*TplCol)[1],
			     NULL, &DynId, NULL, NULL, NULL, NULL, FALSE );
	as$status ( sts    = sts,
                    msg    = "VDgetCollRow()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Evaluate size of collection */
	sts = om$send ( msg = message ACrg_collect.AClist_attribute
					( msg, 0, NULL, DynNum ),
			senderid = NULL_OBJID,
			targetid = DynId.objid,
			targetos = DynId.osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory for collection */
	attr = om$calloc ( num = *DynNum, structure = struct ACrg_coll );

	/* Get collection */
	sts = om$send ( msg = message ACrg_collect.AClist_attribute
					( msg, *DynNum, attr, NULL ),
			senderid = NULL_OBJID,
			targetid = DynId.objid,
			targetos = DynId.osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Construct dynamic collector */
	sts = vd$collectorConstruct ( msg = msg,
				      Num = *DynNum,
				      Col = DynCol );
	as$status ( sts    = sts,
                    msg    = "vd$collectorConstruct()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Fill dynamic collector */
	for ( i=0; i<*DynNum; i++ ) {

		if	(attr[i].desc.type == AC_ATTRIB_DOUBLE) {
			sts = VDsetCollRow ( msg, &(*DynCol)[i],
					     attr[i].name, NULL, NULL,
					     &attr[i].desc.value.att_exp, NULL,
					     NULL, TRUE );
			as$status ( sts    = sts,
		                    msg    = "VDsetCollRow()",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
		else if (attr[i].desc.type == AC_ATTRIB_TEXT) {
			sts = VDsetCollRow ( msg, &(*DynCol)[i],
					     attr[i].name, NULL, NULL,
					     NULL, attr[i].desc.value.att_txt,
					     NULL, TRUE );
			as$status ( sts    = sts,
		                    msg    = "VDsetCollRow()",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
	}

wrapup:
	if (attr) {	om$dealloc (ptr = attr);	attr = NULL;	}
	return (sts);
}
/* ************************************************************************** */

end implementation Root;
