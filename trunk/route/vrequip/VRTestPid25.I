/* $Id: VRTestPid25.I,v 1.3 2001/02/20 01:13:47 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip / VRTestPid25.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRTestPid25.I,v $
 *	Revision 1.3  2001/02/20 01:13:47  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:54:44  anand
 *	SP merge
 *	
# Revision 1.1  2000/12/18  17:01:48  pinnacle
# Created: route/vrequip/VRTestPid25.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/20  15:35:34  pinnacle
# Created: vrequip/VRTestPid25.I by kddinov for route
#
# Revision 1.1  1997/09/12  23:31:18  pinnacle
# Created: vrequip/VRTestPid25.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	KDD		Sept/97		creation. 
 *
 *************************************************************************/

class implementation Root;
 
/* 
#define vdsDEBUG 1
*/
 
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "igr.h"
#include "msdef.h"
#include "msmacros.h"
#include <stdio.h>
#include "OMprimitives.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
 
#include "macro.h"
#include "nddef.h"
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "VRmsg.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VREquipForm.h"
#include "VREquipment.h"
#include "VRchannel.h"
#include "grownmacros.h"
#include "dp.h"
#include "ndmacros.h"
#include "grmacros.h"
#include "VRDbParamDef.h"

extern 	int	VRGetAttribute();
extern	int	VRdbGetEqOccur();

from 	VREquipment	import	GRputattr;
from 	VRGeneric	import	VRGetParams;

/*-----------------------------------------------------------------------------
*  This utility converts Route PID Equipment from pre Route.2.5 Attribute
*  format to Route 2.5 System Attribute format.
*
*  We Update the System Collection according to:
*  old "eqp_partno"     gets VDS Part.PartNb value from call to VRdbGetEqOccur,
*                       before it used to get "eqp_number" from PID DB table,
*
*  new attribute
*  VR_N_PID_EQP_NUMBER gets the value of "eqp_number" column from PID DB table.
-----------------------------------------------------------------------------*/

int VRTestPidEquip25(	struct GRid	OldEquip)

{
struct GRid                   	SysParId, UsrParId, MisParId;
struct ACrg_coll              	Collection[8];
struct VRdbEquipPart    	Part;
struct VREquipment_common     	equipment;



IGRlong				sts, status, retcode;
char				EquipNumber[80], TableName[80];

/*-----------------------
#.   Get attribute collections.
-------------------------*/
    sts    = om$send( msg   = message VRGeneric.VRGetParams (&retcode,
                                      &SysParId, &UsrParId, &MisParId),
                   senderid = NULL_OBJID,
                   targetid = OldEquip.objid,
                   targetos = OldEquip.osnum);
    as$status(sts = sts );


/*-----------------------
#.   Search for VR_N_PID_EQP_NUMBER system attribute. 
-------------------------*/
    Collection[0].desc.type = AC_ATTRIB_TEXT;
    strcpy( Collection[0].name, "eqp_partno" );

    strcpy(Collection[1].desc.value.att_txt, "");
    Collection[1].desc.type = AC_ATTRIB_TEXT;
    strcpy( Collection[1].name, VR_N_PID_EQP_NUMBER );

    Collection[2].desc.type = AC_ATTRIB_TEXT;
    strcpy( Collection[2].name, VR_N_TABLE_NAME_DB );

    sts   = VRGetAttribute( Collection, 3, &SysParId, NULL, 0);

    if ( strlen(Collection[1].desc.value.att_txt) > 0 ) goto wrapup; 

/*-----------------------
#    If VR_N_PID_EQP_NUMBER not found, this PID was created prior to Route 2.5. 
*    "eqp_partno" 	-----> VR_N_PID_EQP_NUMBER.
*    VDS Part.PartNb	----->	"eqp_partno".    
-------------------------*/
    strcpy( EquipNumber , Collection[0].desc.value.att_txt );
    strcpy( TableName   , Collection[2].desc.value.att_txt );

    Part.PartNb[0]  = 0;
    status = VRdbGetEqOccur( &retcode, TableName, EquipNumber, NULL,&Part,NULL);

    Collection[0].desc.type = AC_ATTRIB_TEXT;
    strcpy( Collection[0].name, "eqp_partno" );
    strcpy( Collection[0].desc.value.att_txt, Part.PartNb);
 
    Collection[1].desc.type = AC_ATTRIB_TEXT;
    strcpy( Collection[1].name, VR_N_PID_EQP_NUMBER );
    strcpy( Collection[1].desc.value.att_txt, EquipNumber); 

    VR$ModifyCollection(    p_msg                 = &retcode,
                            Operation             = VR_MERGE_COLL,
                            p_ParamsListToModify  = Collection,
                            NbParamsToModify      = 2,
                            p_OutputCollectionId  = &SysParId );


/*-----------------------
#.   Make sure the instance data EquipNo, is identical to VR_N_PID_EQP_NUMBER.
-------------------------*/
    strcpy( equipment.EquipNo , EquipNumber);
    equipment.Iwant   = VREquipment_EquipNo;
 
    sts    = om$send( msg   = message VREquipment.GRputattr
                                                (&retcode, (char *) &equipment),
                   senderid = NULL_OBJID,
                   targetid = OldEquip.objid,
                   targetos = OldEquip.osnum);
    as$status(sts = sts) ;


/*-----------------------
#. 	Wrapup
-------------------------*/
wrapup:

return ((int) sts);
}

end implementation Root;
