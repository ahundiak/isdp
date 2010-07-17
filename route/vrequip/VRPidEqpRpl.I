/* $Id: VRPidEqpRpl.I,v 1.2 2001/02/20 01:13:41 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	 vrequip/VRPidEqpRpl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRPidEqpRpl.I,v $
 *      Revision 1.2  2001/02/20 01:13:41  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/03/22  16:23:36  pinnacle
# Modified to fix TR17990119
#
# Revision 1.2  1999/12/29  12:03:54  pinnacle
# Replaced by Anand for CR 179900908
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/12  21:43:28  pinnacle
# Replaced: vrequip/VRPidEqpRpl.I for:  by kddinov for route
#
# Revision 1.4  1997/12/29  22:28:10  pinnacle
# Replaced: vrequip/VRPidEqpRpl.I for:  by kddinov for route
#
# Revision 1.3  1997/10/20  15:32:34  pinnacle
# Replaced: vrequip/VRPidEqpRpl.I for:  by kddinov for route
#
# Revision 1.2  1997/12/04  22:40:28  pinnacle
# Replaced: vcequip/VCPidEqpRpl.I for:  by kddinov for route
#
# Revision 1.1  1997/10/28  16:30:06  pinnacle
# Created: vcequip/VCPidEqpRpl.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 * 		   KDD		creation.
 *	4-98	   KDD		TR #179800067. Translate embedded terminals 
 *				to their new positions.
 *
 *      Dec 1999   Anand        TR 179802479 - Cables are losing connections 
 *                              to terminals if a PID Equipment is replaced 
 *                              with another PID Equipment.
 *      Dec 1999   Anand        CR 179900908 - Implemented option to maintain
 *                 		existing nozzle parameters on PID eqp when the
 *                 		replace PID equipment button is utilized.
 *      Mar 2000   Alwin        TR 179901199 -goto TR2479 prevents from setting 
 *								the instance data back to New Terminal, hence 
 *								placed at wrong offsets. Commented the 
 *								line goto TR2479.
 *								There's special case also handled when user 
 *								modifies the TagNumber of embedded terminal. 
 *								This would get rid of "recompute failure error".
 *
*-------------------------------------------------------------------------
*  HIERARCHY:
*
*  VREquipment 
*       |        child                      
*       +------------------> ACpretend
*                                |         child
*                                +-----------------> VRNozzle (or VCTerm)
*
*-------------------------------------------------------------------------
*  ALGORITHM:
*
* - Create new VREquipment object. Delete at the end.
* - NDnode.NDchange_connect all old ACpretend children from OldEquip to NewEquip
* - Evaluate OldEquip with the new macro name. 
* - For matching (OldEquip and NewEquip) VRHozzleHold macro template names:
*	- NDnode.NDchange_connect the corresponding NewVRNozzle 
*	  from NewAcpretend to OldAcpretend.
*	  (NDchange_connect OldVRNozzle from OldAcpretend to NewAcpretend).
*	- NDnode.NDchange_connect OldAcpretend from NewEquip to OldEquip.
*	  (NDchange_connect NewAcpretend from OldEquip to NewEquip). 
*	- notify (GRgraphics.GRidchanged) all owners and listeners of 
*	  OldVRNozzle
*       - GRgraphics.GRidchanged for NewO
 *************************************************************************/
 
class implementation VREquipment;
 
/*
#define vdsDEBUG 1
*/
 
#include <string.h>
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
#include "vdprdmacros.h"
#include "vdreporterr.h"

#include "vc_define.h" 
#include "vc_structs.h"
#include "VCstructs.h"
#include "vdparmacros.h"
 
 
extern int 	VRPidEqp_GetNozzles  ( );
extern int      VCPidEqp_GetTerminals  ( );
extern IGRint 	VREvaluateEquip ();
extern int 	GRnotifylisteners(); 

extern GRclassid        OPP_VREquipment_class_id;

extern char EX_runname [ ] ;


from    VCRoot          import  VCGetInstance;
from    VCRoot          import  VCSetInstance;
from    VCRoot          import  VCgetSysAttributes;
from    VCRoot          import  VCmodSysAttributes;
from    VCMac           import  VCMmacname;
from    VCP             import  VCP_num;
from    VCP             import  VCP_init;
from    VCP             import  VCP_get;
from    VCP             import  VCP_add;
from 	VCTerm		import	VCTembed;
 
#ifdef vdsDEBUG
from    VCRoot          import  VCGetCode;
#endif

from    VCMac           import  VCMchgdn;
from    ACpretend       import  ACgive_downscan, ACpconnect;

/*******************************************************************************
* KDD Aug 1997
*	Replaces Macro Template for Pid Equipment. 
*
* 1.	Gets old macro (+ feet description + VRNozzle children) from
*	ACmodel component and ACpretend children. 
*       One to one correspondence between VRNozHold components & VRNozz children
*       consult with VREquipOver.I: VRPlaceNozzleFeet
*
* 2.	Swap Old ACmodel (component channel) and ACpretend (child channel)
*
* 3.	Evaluate Equipment here is needed EquipNumber. 
*	The System Collection MUST be Updates on input. 
*
* 4. 	For Matching Old and New feet names reconnect dependents of Old 
*	ACpretend to orrecponding New ACpretend. 
*	This will preserve the network connections for VRNozzles.
*-------------------------------------------------------------------------------
*
* I:  EquipId		struct GRid 	- Pid Equipment Id. 
*
* I:  EquipNumber	*(char) 	- New Equipment Number. 
*					  Will Update the system Collection. 
*
* I:  md_env		*(struct GRmd_env) - Module Envirronment 
*-------------------------------------------------------------------------------
*
* RETURN status:
*
* 1     - OK
* even  - problems
*******************************************************************************/
method VRReplace (      IGRlong                 *msg;
                        struct GRid             NewEquip;
                        struct GRmd_env         *md_env )
{
  struct GRid			SysParId, UsrParId, MisParId,
				OldSysId, OldUsrId, 
				NewSysId, NewUsrId,
				NewSysParId, NewUsrParId, NewMisParId,
				OldGraphics, NewGraphics, TempId;

  struct GRid			OldEquip, OldAttr, NewAttr;

  struct VREquipment_common 	equipment;

  struct myfeet                 *OldFeet    = NULL,   *NewFeet    = NULL;

  struct ACrg_coll		Collection[8], *AttrList= NULL,
				*OldAttrList = NULL, *NewAttrList = NULL,
				*OldUsrAttr  = NULL, *NewUsrAttr  = NULL;

  struct GRid			*OldPretend = NULL,   *NewPretend = NULL,
			        *NewNozzle  = NULL,   *OldNozzle  = NULL,
				*OldChild   = NULL,   *NewChild   = NULL,
				*Parent     = NULL,
				*Child      = NULL;

  struct GRid                   *OldTerm    = NULL, *OldPlacedTerm = NULL,
                                *NewTerm    = NULL, *NewPlacedTerm = NULL,
				*OldCompTerm= NULL, *OldChldTerm   = NULL,
				*NewCompTerm= NULL, *NewChldTerm   = NULL; 

  struct VRGenInfo 		VRNewInstance, VROldInstance;

  struct VCGenInfo 		NewInstance, OldInstance;


  int				NumOldFeet    = 0, NumNewFeet    = 0, 
				NumOldPretend = 0, NumNewPretend = 0,	
			        NumNewNozzle  = 0, NumOldNozzle  = 0,
				NumOldCompTerm= 0, NumOldChldTerm= 0,
				NumNewCompTerm= 0, NumNewChldTerm= 0,
				NumOldChild   = 0, NumNewChild   = 0,
				NumParent     = 0,
				NumChild      = 0,
				NumAttrList   = 0,
				NumOldAttrList= 0, NumNewAttrList   = 0,
				NumOldUsrAttr = 0, NumNewUsrAttr    = 0;

  int                           NumOldTerm    = 0, NumOldPlacedTerm = 0,
                                NumNewTerm    = 0, NumNewPlacedTerm = 0;
 
  IGRshort			matrix_type;
  IGRlong			retcode = 1, sts=1; 
  IGRint			i, j, k, n;

  struct GRmd_env 		new_env;    
  GRobjid         		new_objid;
  IGRmatrix       		matrix; 

  IGRlong     			index = 0; 

  char				EquipNumber[41]={""}, text[41]={""},
				NewMacroName[80]={""}, OldMacroName[80]={""};

  IGRboolean            	Embedded = FALSE;
  IGRboolean            	bRetainParams;

  int				TermUsedFlag[100];



    SetProc(VCEquipment.VRReplace); Begin

    SysParId.objid = NULL_OBJID; 	UsrParId.objid = NULL_OBJID;
    MisParId.objid = NULL_OBJID;        NewSysParId.objid = NULL_OBJID;
    NewUsrParId.objid = NULL_OBJID;     NewMisParId.objid = NULL_OBJID;
    OldGraphics.objid = NULL_OBJID;     NewGraphics.objid = NULL_OBJID;
    TempId.objid = NULL_OBJID;    

    OldFeet    = NULL;		NewFeet = NULL;		OldPretend = NULL;
    NewPretend = NULL;		Child      = NULL;

    bRetainParams = *msg;
    /* This is admittedly bad coding. The msg was intended for return code
     * purposes only. Here, I have used it as a "Trojan horse" to bring in the
     * value of a gadget in a form that belongs to the command object. This was
     * done for service pack purposes. Other developers to kindly refrain from
     * this kind of coding. Anand for CR 179900908 */
    *msg = OM_S_SUCCESS;
    __DBGpr_int(" Do we retain nozzle params?", bRetainParams);

    OldEquip.objid = my_id;
    OldEquip.osnum = OM_Gw_current_OS;

__DBGpr_obj("OldEquipment ID          ", OldEquip);
__DBGpr_obj("NewEquipment ID          ", NewEquip);


/*-----------------------
#  Inititalize 
-------------------------*/
     sts   = om$send( msg   = message VRGeneric.VRGetMatrix(&retcode,0,NULL,
                                  (IGRdouble *) matrix, md_env),
                   senderid = NULL_OBJID,
                   targetid = OldEquip.objid,
                   targetos = OldEquip.osnum);
    as$status(sts = sts );

/*-----------------------
#1.   Get Old/New Feet names (VRNozHold) and VRNozzle (ACpretend children)
*    One to one correspondence between VRNozHold components & VRNozz children.
-------------------------*/
    sts = VRPidEqp_GetNozzles  (OldEquip, &NumOldFeet,    &OldFeet,
                                          &NumOldPretend, &OldPretend, md_env);

    if ( !(NumOldPretend == NumOldFeet) ) {
        as$status(  sts = sts, msg = "NumOldPretend != NumOldFeet",
		    action = GOTO_VALUE, value = wrapup);
    }
__DBGpr_objlist("VRNozzle children of OldEquip", NumOldPretend, OldPretend); 


    sts = VRPidEqp_GetNozzles  (NewEquip, &NumNewFeet,    &NewFeet,
                                          &NumNewPretend, &NewPretend, md_env);
    if ( !(NumNewPretend == NumNewFeet) ) {
        as$status( sts = sts, msg = "NumNewPretend != NumNewFeet",
		action = GOTO_VALUE, value = wrapup);
    }
__DBGpr_objlist("VRNozzle children of NewEquip", NumNewPretend, NewPretend); 



/*-----------------------
#2.   Get Old/New Feet IDs (VCTerm) and VCTerm (ACpretend children)
*
* Note:
*    VCPidEqp_GetTerminals returns VCTerm component IDs, and ACpretend child ID.
*    VCTerm "child" is a child of ACpretend, and grand child of VREquipment. 
-------------------------*/

//    if ( !vd$prd_get_product_info( run_name = "Cable")) goto cont2;

    sts = VCPidEqp_GetTerminals(OldEquip, &NumOldCompTerm, &OldCompTerm,
                                          &NumOldChldTerm, &OldChldTerm,md_env);

__DBGpr_objlist("VCTerm   componts of OldEquip", NumOldCompTerm, OldCompTerm); 
__DBGpr_objlist("VCTerm   children of OldEquip", NumOldChldTerm, OldChldTerm); 

 
    sts = VCPidEqp_GetTerminals(NewEquip, &NumNewCompTerm, &NewCompTerm,
                                          &NumNewChldTerm, &NewChldTerm,md_env);
 
__DBGpr_objlist("VCTerm   componts of NewEquip", NumNewCompTerm, NewCompTerm); 
__DBGpr_objlist("VCTerm   children of NewEquip", NumNewChldTerm, NewChldTerm); 

cont2:

/*-----------------------
#3.   Modify attribute collections.
-------------------------*/
    sts    = om$send( msg   = message VRGeneric.VRGetParams (&retcode,
                                      &SysParId, &UsrParId, &MisParId),
		   senderid = NULL_OBJID,
                   targetid = OldEquip.objid,
                   targetos = OldEquip.osnum);
    as$status(sts = sts );
 
    sts    = om$send( msg   = message VRGeneric.VRGetParams (&retcode,
                                      &NewSysParId, &NewUsrParId, &NewMisParId),
		   senderid = NULL_OBJID,
                   targetid = NewEquip.objid,
                   targetos = NewEquip.osnum);
    as$status(sts = sts );
 
    VR$ModifyCollection(  p_msg                 = &retcode,
                          Operation             = VR_MERGE_COLL,
                          p_InputCollectionId   = &NewSysParId,
                          p_OutputCollectionId  = &SysParId);
 
    VR$ModifyCollection(  p_msg                 = &retcode,
                          Operation             = VR_UNION_COLL,
                          p_InputCollectionId   = &NewMisParId,
                          p_OutputCollectionId  = &MisParId);
 
    VR$ModifyCollection(  p_msg                 = &retcode,
                          Operation             = VR_UNION_COLL,
                          p_InputCollectionId   = &NewUsrParId,
                          p_OutputCollectionId  = &UsrParId);


/*-----------------------
#4.   Set instance data me->EquipNo. 
*    First try VR_N_PID_EQP_NUMBER, else "eqp_partno".
-------------------------*/
    strcpy(Collection[0].desc.value.att_txt, ""); 
    Collection[0].desc.type = AC_ATTRIB_TEXT;
    strcpy( Collection[0].name, VR_N_PID_EQP_NUMBER );
    sts   = VRGetAttribute( Collection, 1, &SysParId, NULL, 0);

    if ( strlen(Collection[0].desc.value.att_txt) == 0 ) {
       Collection[0].desc.type = AC_ATTRIB_TEXT;
       strcpy( Collection[0].name, "eqp_partno" );
       sts   = VRGetAttribute( Collection, 1, &SysParId, NULL, 0);
    }

    strcpy( equipment.EquipNo , Collection[0].desc.value.att_txt) ;
    equipment.Iwant   = VREquipment_EquipNo;
    __DBGpr_str(" Equipment part no",equipment.EquipNo);
 
    sts    = om$send( msg   = message VREquipment.GRputattr
                                                (&retcode, (char *) &equipment),
                   senderid = NULL_OBJID,
                   targetid = OldEquip.objid,
                   targetos = OldEquip.osnum);
    as$status(sts = sts) ;
 

/*-----------------------
#5.   Swap the graphics template components (ACheader).
-------------------------*/
    sts = om$send( msg    = message NDnode.ASreturn_go( &OldGraphics,NULL,NULL),
		 senderid = NULL_OBJID,
                 targetid = OldEquip.objid,
                 targetos = OldEquip.osnum);
    as$status(sts = sts);
    __DBGpr_obj(" Graphics obj of Old equipment",OldGraphics);
 
    sts = om$send( msg    = message NDnode.ASreturn_go( &NewGraphics,NULL,NULL),
		 senderid = NULL_OBJID,
                 targetid = NewEquip.objid,
                 targetos = NewEquip.osnum);
    as$status(sts = sts);
    __DBGpr_obj(" Graphics obj of New equipment",NewGraphics);
 
    sts = om$send( msg    = message GRconnector.GRdisconn( &retcode, &OldEquip),
		 senderid = NULL_OBJID,
                 targetid = OldGraphics.objid,
                 targetos = OldGraphics.osnum);
    as$status (sts = sts);
 
    sts = om$send( msg    = message GRconnector.GRdisconn( &retcode, &NewEquip),
		 senderid = NULL_OBJID,
                 targetid = NewGraphics.objid,
                 targetos = NewGraphics.osnum);
    as$status (sts = sts);
 
    sts = om$send( msg    = message GRconnector.GRrigidconn
                                        ( &retcode, &NewEquip, &index),
		 senderid = NULL_OBJID,
                 targetid = OldGraphics.objid,
                 targetos = OldGraphics.osnum);
    as$status (sts = sts);
 
    sts = om$send( msg    = message GRconnector.GRrigidconn
                                        ( &retcode, &OldEquip, &index),
		 senderid = NULL_OBJID,
                 targetid = NewGraphics.objid,
                 targetos = NewGraphics.osnum);
    as$status (sts = sts);

    __DBGpr_com(" connections between graphics and objs of old and new equipment swapped");



/*-----------------------
#6.  Swap all New children to OldEquip.
*    Swap Old (VRNozzle and VCTerm) ACpretend children to NewEquip.
*	    (OldPretend and OldChldTerm).
-------------------------*/
    if ( OldChild ) { _FREE( OldChild); OldChild = NULL;} NumOldChild=0;
    if ( NewChild ) { _FREE( NewChild); NewChild = NULL;} NumNewChild=0;

    sts = vr$get_channel_objects ( objid            = NewEquip.objid,
                                   osnum            = NewEquip.osnum,
                                   chan_name        = "children",
                                   operation        = VR_INCLUDE,
                                   count            = &NumNewChild,
                                   object_list      = &NewChild);
    as$status( sts = sts);
 
    for ( k = 0; k < NumNewChild; k=k+1) {
    __DBGpr_obj("Child reconnected from New to Old Equipment", NewChild [ k ]);
            sts = om$send( msg   = message NDnode.NDchange_connect
                                    (1, &NewEquip , &OldEquip ),
                        senderid = NULL_OBJID,
                        targetid = NewChild [ k ].objid,
                        targetos = NewChild [ k ].osnum);
            as$status(sts = sts);
    }


    for ( k = 0; k < NumOldPretend; k=k+1) {
    __DBGpr_obj("VRNozzle Chld move frm Old to New Equipment",OldPretend [ k ]);
            sts = om$send( msg   = message NDnode.NDchange_connect
                                    (1, &OldEquip , &NewEquip ),
                        senderid = NULL_OBJID,
                        targetid = OldPretend [ k ].objid,
                        targetos = OldPretend [ k ].osnum);
            as$status(sts = sts);
    }

    for ( k = 0; k < NumOldChldTerm; k=k+1) {
    __DBGpr_obj("VCTerm  Chld move frm Old to New Equipment",OldChldTerm [ k ]);
            sts = om$send( msg   = message NDnode.NDchange_connect
                                    (1, &OldEquip , &NewEquip ),
                        senderid = NULL_OBJID,
                        targetid = OldChldTerm [ k ].objid,
                        targetos = OldChldTerm [ k ].osnum);
            as$status(sts = sts);
    }

/*-----------------------------
#7.   Match Old VRNozzle grand child and New VRNozzle grand child.
*	(two nozzles are matching if have the same VRNozzleHold Feet name.
*
* Note: Old VRNozzle grand child is a child of OldPretend[i], and the index i
*	is the same for the corresponding template VRNozzleHold OldFeet[i]. 
-----------------------------*/

    for ( i = 0; i < NumOldFeet; i=i+1 ) {
    for ( j = 0; j < NumNewFeet; j=j+1 ) {
 
        if ( strcmp(OldFeet [ i ].name , NewFeet [ j ].name) )  continue;
 
    __DBGpr_str("Matching Feet Name ", OldFeet [ i ].name);
    __DBGpr_obj("OldPretend         ", OldPretend[i]);
    __DBGpr_obj("NewPretend         ", NewPretend[j]);
 
        if ( OldNozzle ) { _FREE( OldNozzle ); OldNozzle=NULL;} NumOldNozzle=0;
        if ( NewNozzle ) { _FREE( NewNozzle ); NewNozzle=NULL;} NumNewNozzle=0;

        sts = vr$get_channel_objects ( objid            = OldPretend[i].objid,
                                       osnum            = OldPretend[i].osnum,
                                       chan_name        = "children",
                                       ancestry_class   = "VRNozzle",
                                       operation        = VR_INCLUDE,
                                       count            = &NumOldNozzle,
                                       object_list      = &OldNozzle);
 
        sts = vr$get_channel_objects ( objid            = NewPretend[j].objid,
                                       osnum            = NewPretend[j].osnum,
                                       chan_name        = "children",
                                       ancestry_class   = "VRNozzle",
                                       operation        = VR_INCLUDE,
                                       count            = &NumNewNozzle,
                                       object_list      = &NewNozzle);

        if ( (NumNewNozzle != NumOldNozzle) || (NumOldNozzle != 1) ) continue;


        /*-- Grand children OldNozzle and NewNozzle match. Replace them. --*/

	/* Below if condition added for CR 179900908 by Anand */
	if( ! bRetainParams )
	{
	    __DBGpr_com(" Do not retain params. Put new nozzle params");

/*-----------------------------
#7.1. Union User + Merge (System & Instance) attributes of OldNozz and NewNozz.
-----------------------------*/

	    sts    = om$send( msg      = message VRGeneric.VRGetInstance
						    (&retcode, &VROldInstance),
			      senderid = NULL_OBJID,
			      targetid = OldNozzle[0].objid,
			      targetos = OldNozzle[0].osnum);

	    sts    = om$send( msg      = message VRGeneric.VRGetInstance
						    (&retcode, &VRNewInstance),
			      senderid = NULL_OBJID,
			      targetid = NewNozzle[0].objid,
			      targetos = NewNozzle[0].osnum);


	    sts    = om$send( msg      = message VRGeneric.VRGetParams
					(&retcode, &OldSysId, &OldUsrId, NULL),
			      senderid = NULL_OBJID,
			      targetid = OldNozzle[0].objid,
			      targetos = OldNozzle[0].osnum);

	    sts    = om$send( msg      = message VRGeneric.VRGetParams
					(&retcode, &NewSysId, &NewUsrId, NULL),
			      senderid = NULL_OBJID,
			      targetid = NewNozzle[0].objid,
			      targetos = NewNozzle[0].osnum);


	    VR$ModifyCollection(  p_msg                 = &retcode,
				  Operation             = VR_MERGE_COLL,
				  p_InputCollectionId   = &NewSysId,
				  p_OutputCollectionId  = &OldSysId);


	    VR$ModifyCollection(  p_msg                 = &retcode,
				  Operation             = VR_UNION_COLL,
				  p_InputCollectionId   = &NewUsrId,
				  p_OutputCollectionId  = &OldUsrId);


	/* Those component attributes come from VRstructs.h:"struct VRGenInfo"*/

	    strcpy( VROldInstance.szAABBCC, VRNewInstance.szAABBCC);
	    strcpy( VROldInstance.szNumber, VRNewInstance.szNumber);
	    strcpy( VROldInstance.szNotes , VRNewInstance.szNotes );
	    VROldInstance.cNoMtoFlg = VRNewInstance.cNoMtoFlg;
	    VROldInstance.nOption = VRNewInstance.nOption;

	    sts    = om$send( msg      = message VRGeneric.VRSetInstance
						    (&retcode, &VROldInstance),
			      senderid = NULL_OBJID,
			      targetid = OldNozzle[0].objid,
			      targetos = OldNozzle[0].osnum);

	    __DBGpr_com("OldNozzle VRSetInstance"); 
	}
	/* Above added for CR 179900908 by Anand */

/*-----------------------------
#7.2. Swap (return back OldPretend to OldEquip) NewPretend and OldPretend.
-----------------------------*/

        sts = om$send( msg      = message NDnode.NDchange_connect
                                    (1, &OldEquip , &NewEquip ),
                       senderid = NULL_OBJID,
                       targetid = NewPretend[j].objid,
                       targetos = NewPretend[j].osnum);
 
    __DBGpr_obj("NewPretend reconnected to NewEquip", NewEquip); 

 
         sts = om$send( msg      = message NDnode.NDchange_connect
                                    (1, &NewEquip , &OldEquip ),
                        senderid = NULL_OBJID,
                        targetid = OldPretend[i].objid,
                        targetos = OldPretend[i].osnum);

    __DBGpr_obj("OldPretend reconnected to OldEquip", OldEquip); 

//        GRnotifylisteners( &retcode, &retmsg, &action_mask,
//                              OPPmargs, &OldPretend[i].objid);
    }
    }


/*-----------------------
#8.   For Matching Old VCTerm children and New VCTerm children:
*    (two terminals match if have same tag_number and macro name)
*       - Connect back ACpretend corresponding to Old VCTerm grand child. 
*         The terminal tag number & macro are same, i.e. graphically this is 
*         the same terminal, only connected (possibly) to some cables.
*
* Note: 
*    Old VCTerm grand child is in fact child of Old child ACpretend. 
*    One VCTerm per ACpretend.
-------------------------*/

//    if ( !vd$prd_get_product_info( run_name = "Cable")) goto cont1; 

    for ( j = 0; j < NumNewChldTerm ; j=j+1 ) { TermUsedFlag[j] = 0; }

    __DBGpr_com("I/Cable VREquipment being processed...."); 

    for ( i = 0; i < NumOldChldTerm ; i=i+1 ) {
    for ( j = 0; j < NumNewChldTerm ; j=j+1 ) {
 
	if ( TermUsedFlag[j] ) continue; 	/* This VCTerm already used */

	/*-- Get VCTerm grand child from ACpretend child --*/
        if ( NewTerm ) { _FREE( NewTerm ) ; NewTerm = NULL;} NumNewTerm = 0;
        if ( OldTerm ) { _FREE( OldTerm ) ; OldTerm = NULL;} NumOldTerm = 0;
 
    __DBGpr_obj("ACpretend child of Old Equip ", OldChldTerm[i]);

        sts = vr$get_channel_objects( objid          = OldChldTerm[i].objid,
                                      osnum          = OldChldTerm[i].osnum,
                                      chan_name      = "children",
                                      ancestry_class = "VCTerm",
                                      operation      = VR_INCLUDE,
                                      count          = &NumOldTerm,
                                      object_list    = &OldTerm);
	if ( NumOldTerm != 1 ) { 
           vd$report_error( error = "Error in VCPidEqp_GetTerminals", mode =-1);
           break;
        }

        sts = vr$get_channel_objects( objid          = NewChldTerm[j].objid,
                                      osnum          = NewChldTerm[j].osnum,
                                      chan_name      = "children",
                                      ancestry_class = "VCTerm",
                                      operation      = VR_INCLUDE,
                                      count          = &NumNewTerm,
                                      object_list    = &NewTerm);

	if ( (NumNewTerm != NumOldTerm) ) continue; 

        OldInstance.szTagno[0] = '\0';
	NewInstance.szTagno[0] = '\0';
	OldMacroName[0]        = '\0';
	NewMacroName[0]        = '\0';

	sts = om$send( msg      = message VCTerm.VCTembed( &Embedded ),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[ 0 ].objid,
                       targetos = OldTerm[ 0 ].osnum);
        if ( !Embedded) {
           vd$report_error( error = "Error in VCPidEqp_GetTerminals", mode =-1);
           break;
        }

	__DBGpr_obj("Old Embedded Term in ACprtnd ", OldTerm[0]);

        sts = om$send( msg      = message VCTerm.VCTembed( &Embedded ),
                       senderid = NULL_OBJID,
                       targetid = NewTerm[ 0 ].objid,
                       targetos = NewTerm[ 0 ].osnum);
        if ( !Embedded) { continue; }
	__DBGpr_obj("New Embedded Term in ACprtnd ", NewTerm[0]);


/*----------------------
*  4-98 KDD. TR #179800067
*  Get the offsets from the new embeded terminals and put them in the old ones.
*  Dirty definition of VCTermInfo requires to allocate memory.
*
*                      mode     = OM_e_wrt_message,
*---------------------*/
     {
        IGRshort                NewConPoints = 0, count = 0;
        IGRint                  NewSize=16;
        IGRmatrix               NewMatrix, OldMatrix;
        struct VCP_ptmgr        VCP_VCoff;
#ifdef vdsDEBUG
	IGRchar			OldCompCode[80],NewCompCode[80];
#endif
 
        for ( k = 0; k < 16; k++ )  OldMatrix [ k ] = NewMatrix[ k ] = 0.0;

		NewInstance.Attr.Term.dOffVal = NewMatrix;
		OldInstance.Attr.Term.dOffVal = OldMatrix;

        sts = om$send( msg      = message VCRoot.VCGetInstance
        		                           (&retcode, &NewInstance),
                       senderid = NULL_OBJID,
                       targetid = NewTerm[ 0 ].objid,
                       targetos = NewTerm[ 0 ].osnum);

        sts = om$send( msg      = message VCRoot.VCGetInstance
                                        	   (&retcode, &OldInstance),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[ 0 ].objid,
                       targetos = OldTerm[ 0 ].osnum);

	__DBGpr_str("Old Embedded Term Tag number ", OldInstance.szTagno); 
	__DBGpr_str("New Embedded Term Tag number ", NewInstance.szTagno); 

        if ( strcmp(OldInstance.szTagno, NewInstance.szTagno) ) continue;

		/* One more check has to be done at this level. i.e If the user has
		modified the "Tag Number" of Embedded Terminal through the "Set Cabling
		Attributes" command, then we would've changed the Terminal Instance
		data but we don't change the "down_scan" of the parent ACpretend. As 
		a result whenever the Equipment is recomputed this would result in
		error's b'cas ACpretends are not upto date. Trying to accomplish this
		at the Set Cabling Attributes level would recompute the Equipment and
		that's not desired. Hence fixed at this point.  Alwin*/ 
		{
			IGRchar	oldDownScan[100], newDownScan[100];
			IGRchar	*tag=NULL;

			om$send( msg = message ACpretend.ACgive_downscan( oldDownScan ),
								targetid = OldChldTerm[i].objid,
								targetos = OldChldTerm[i].osnum );
								
			tag = strchr( oldDownScan, ':' );
			__DBGpr_str( " New Pretends downscan ", oldDownScan );
			if( tag )
			{
				__DBGpr_str( " downscan tag ", &tag[1] );
				if( strcmp( &tag[1], OldInstance.szTagno ) )
				{
					IGRchar *temp=NULL;

					/* i.e. If the Tag attached to the DownScan doesn't match
					with the "Tag Number" from the instance, it means the
					property has been modified. */

				   __DBGpr_com( " Tag Number property has been modified" );

					/* disconnect the pretend from Equipment */
					om$send( msg = message GRconnector.GRdisconn( &retcode,
												&NewEquip ),
										targetid = OldChldTerm[i].objid,
										targetos = OldChldTerm[i].osnum );
										
					/* disconnect the Terminal from pretend */
					om$send( msg = message GRconnector.GRdisconn( &retcode,
												&OldChldTerm[i] ),
										targetid = NewTerm[0].objid,
										targetos = NewTerm[0].osnum );

					/* generate the newDown Scan */
					temp = strtok( oldDownScan, ":" ); 
					sprintf( newDownScan, "%s:%s", temp, OldInstance.szTagno );

					__DBGpr_str( " Broken string ", temp );
					__DBGpr_str( " newDownScan ", newDownScan );

					// set it to the ACpretend object
					retcode = 0; // normal behaviour...??????
					sts =
					om$send ( msg = message ACpretend.ACpconnect
										   ( (IGRint)retcode, 
											 NewEquip, newDownScan ),
						 targetid = OldChldTerm[i].objid,
						 targetos = OldChldTerm[i].osnum );
					as$status(sts = sts);
						
					// Connect the Terminal back to the ACpretend 
					sts = om$send( msg = message GRconnector.GRrigidconn
									  ( &retcode, &OldChldTerm[i], &index ),
								 targetid = NewTerm[0].objid,
								 targetos = NewTerm[0].osnum );
					as$status(sts = sts);
				}
			}
		}

        sts = om$send( msg      = message VCMac.VCMmacname
						   (&retcode, NewMacroName),
                       senderid = NULL_OBJID,
                       targetid = NewTerm[ 0 ].objid,
                       targetos = NewTerm[ 0 ].osnum);

        sts = om$send( msg      = message VCMac.VCMmacname
						   (&retcode, OldMacroName),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[ 0 ].objid,
                       targetos = OldTerm[ 0 ].osnum);

    __DBGpr_str("Old Embedded Term Macro name ", OldMacroName);
    __DBGpr_str("New Embedded Term Macro name ", NewMacroName);

#ifdef vdsDEBUG
        sts = om$send( msg      = message VCRoot.VCGetCode (NewCompCode),
                       senderid = NULL_OBJID,
                       targetid = NewTerm[ 0 ].objid,
                       targetos = NewTerm[ 0 ].osnum);

        sts = om$send( msg      = message VCRoot.VCGetCode (OldCompCode),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[ 0 ].objid,
                       targetos = OldTerm[ 0 ].osnum);

	__DBGpr_str("Old Embedded Term CompCode ", OldCompCode);
	__DBGpr_str("New Embedded Term CompCode ", NewCompCode);
#endif

	/* Below lines added by Anand for TR 179802479 */
	if ( strcmp(OldMacroName, NewMacroName) )
	{
	     sts = om$send( msg    = message NDnode.ASreturn_go(&OldGraphics,
								NULL,NULL),
			  senderid = NULL_OBJID,
			  targetid = OldTerm[0].objid,
			  targetos = OldTerm[0].osnum);
	     as$status(sts = sts);
	     __DBGpr_obj(" Graphics obj of Old Terminal",OldGraphics);
	  
	     sts = om$send( msg    = message NDnode.ASreturn_go(&NewGraphics,
								NULL,NULL),
			  senderid = NULL_OBJID,
			  targetid = NewTerm[0].objid,
			  targetos = NewTerm[0].osnum);
	     as$status(sts = sts);
	     __DBGpr_obj(" Graphics obj of New Terminal",NewGraphics);
	  
	     sts = om$send( msg    = message GRconnector.GRdisconn( &retcode,
								&OldTerm[0]),
			  senderid = NULL_OBJID,
			  targetid = OldGraphics.objid,
			  targetos = OldGraphics.osnum);
	     as$status (sts = sts);
	  
	     sts = om$send( msg    = message GRconnector.GRdisconn( &retcode,
								&NewTerm[0]),
			  senderid = NULL_OBJID,
			  targetid = NewGraphics.objid,
			  targetos = NewGraphics.osnum);
	     as$status (sts = sts);
	  
	     sts = om$send( msg    = message GRconnector.GRrigidconn
						 ( &retcode, &NewTerm[0],
						     &index),
			  senderid = NULL_OBJID,
			  targetid = OldGraphics.objid,
			  targetos = OldGraphics.osnum);
	     as$status (sts = sts);
	  
	     sts = om$send( msg    = message GRconnector.GRrigidconn
						 ( &retcode, &OldTerm[0],
						     &index),
			  senderid = NULL_OBJID,
			  targetid = NewGraphics.objid,
			  targetos = NewGraphics.osnum);
	     as$status (sts = sts);

	     sts = om$send (msg	= message VCMac.VCMchgdn ( &retcode,
						     NewMacroName, NULL ),
			    senderid = NULL_OBJID,
			    targetid = OldTerm[0].objid,
			    targetos = OldTerm[0].osnum);

	     sts = om$send( msg = message NDnode.NDchange_node(md_env),
			    senderid = NULL_OBJID,
			    targetid = OldTerm[0].objid,
			    targetos = OldTerm[0].osnum);

	     /*goto TR2479;Commented for TR179901199 - set the instance back.Alwin*/
	}
	/* Above lines added by Anand for TR 179802479 */

	/*-- Grand children OldTerm and NewTerm match. Replace takes place. --*/

/*----------------------
#8.4.  4-98 KDD. TR #179800067
*  Replace both VCMac and VCP offsets, of Old Terminal. 
*  Tricks like OldMatrix = NewMatrix, will speed up things and will 
*  make the code much less readable.  
*---------------------*/
 
__DBGpr_mat("Old Matrix", OldInstance.Attr.Term.dOffVal);
__DBGpr_mat("New Matrix", NewInstance.Attr.Term.dOffVal);
__DBGpr_mat("Old Matrix", OldInstance.Attr.Term.dOffVal);

__DBGpr_int("Old Offset size ", OldInstance.Attr.Term.nOff);
__DBGpr_int("New Offset size ", NewInstance.Attr.Term.nOff);

        OldInstance.Attr.Term.nOff = NewInstance.Attr.Term.nOff;
 
        for ( k = 0; k < NewInstance.Attr.Term.nOff; k++ )  {
	    OldInstance.Attr.Term.dOffVal[k] = NewInstance.Attr.Term.dOffVal[k];
	}

        sts = om$send( msg      = message VCRoot.VCSetInstance
                                                   (&retcode, &OldInstance),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[ 0 ].objid,
                       targetos = OldTerm[ 0 ].osnum);

        sts = om$send( msg      = message VCP.VCP_num (&retcode, &NewConPoints),
                       senderid = NULL_OBJID,
                       targetid = NewTerm[ 0 ].objid,
                       targetos = NewTerm[ 0 ].osnum);

        if ( NewConPoints > 0 ) { 
           sts = om$send( msg      = message VCP.VCP_init(&retcode, NULL, NULL),
                          senderid = NULL_OBJID,
                          targetid = OldTerm[ 0 ].objid,
                          targetos = OldTerm[ 0 ].osnum);
	}

	__DBGpr_int("Number of Connect Points", NewConPoints);

	for ( k = 1; k <= NewConPoints; k++ ) { 
            sts = om$send( msg      = message VCP.VCP_get
						(&retcode, k, &VCP_VCoff),
                           senderid = NULL_OBJID,
                           targetid = NewTerm[ 0 ].objid,
                           targetos = NewTerm[ 0 ].osnum);

            sts = om$send( msg      = message VCP.VCP_add
						(&retcode, &VCP_VCoff, &count),
                           senderid = NULL_OBJID,
                           targetid = OldTerm[ 0 ].objid,
                           targetos = OldTerm[ 0 ].osnum);

#ifdef vdsDEBUG
printf("\tVCP_add (%f, %f, %f)\n", VCP_VCoff.dX, VCP_VCoff.dY, VCP_VCoff.dZ);
#endif
	}

/* test only */
/**
        sts = om$send( msg      = message VCRoot.VCGetInstance
                                                   (&retcode, &OldInstance),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[ 0 ].objid,
                       targetos = OldTerm[ 0 ].osnum);

    __DBGpr_mat("Old!Matrix", OldInstance.Attr.Term.dOffVal);
**/
		OldInstance.Attr.Term.dOffVal = NULL;
		NewInstance.Attr.Term.dOffVal = NULL;
     }

TR2479:
/*-----------------------------
#8.2. Swap (return back OldChild to OldEquip) NewChldTerm[j] and OldChldTerm[i]
#8.1. UNION User and MERGE System attributes of OldTerm with those of NewTerm.
-----------------------------*/
        __DBGpr_obj(" Old Child terminal",OldChldTerm[i]);
        sts = om$send( msg      = message NDnode.NDchange_connect
                                    (1, &NewEquip , &OldEquip ),
                       senderid = NULL_OBJID,
                       targetid = OldChldTerm[i].objid,
                       targetos = OldChldTerm[i].osnum);
 
        __DBGpr_obj(" New Child terminal",NewChldTerm[j]);
        sts = om$send( msg      = message NDnode.NDchange_connect
                                    (1, &OldEquip , &NewEquip ),
                       senderid = NULL_OBJID,
                       targetid = NewChldTerm[j].objid,
                       targetos = NewChldTerm[j].osnum);
 

        if(OldAttrList){_FREE(OldAttrList); OldAttrList=NULL;} NumOldAttrList=0;
        if(NewAttrList){_FREE(NewAttrList); NewAttrList=NULL;} NumNewAttrList=0;
        if(OldUsrAttr) {_FREE(OldUsrAttr);  OldUsrAttr=NULL;}  NumOldUsrAttr=0;
        if(NewUsrAttr) {_FREE(NewUsrAttr);  NewUsrAttr=NULL;}  NumNewUsrAttr=0;

        vd$getUsrAttributes( sts        = &retcode,
                             object     = NewTerm[0],
                             nbAttrs    = &NumNewUsrAttr,
                             att        = &NewUsrAttr,
                             md_env     = md_env);

	vd$getUsrAttributes( sts	= &retcode,
			     object	= OldTerm[0],
			     nbAttrs	= &NumOldUsrAttr,
			     att	= &OldUsrAttr,
			     md_env	= md_env);

        VR$ModifyCollection(  p_msg                 = &retcode,
                              Operation             = VR_UNION_COLL,
			      p_ParamsListToModify  = NewUsrAttr,
			      NbParamsToModify	    = NumNewUsrAttr,
			      OutParList            = &OldUsrAttr,
			      OutNumPar       	    = &NumOldUsrAttr);

	vd$modUsrAttributes( sts	= &retcode,
			     object	= OldTerm[0],
			     nbAttrs	= NumOldUsrAttr,
			     att	= OldUsrAttr,
			     md_env	= md_env);


        sts = om$send( msg      = message VCRoot.VCgetSysAttributes (&retcode, 
					&NumNewAttrList , &NewAttrList, md_env),
                       senderid = NULL_OBJID,
                       targetid = NewTerm[0].objid,
                       targetos = NewTerm[0].osnum);

        sts = om$send( msg      = message VCRoot.VCgetSysAttributes (&retcode, 
					&NumOldAttrList , &OldAttrList, md_env),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[0].objid,
                       targetos = OldTerm[0].osnum);

        VR$ModifyCollection(  p_msg                 = &retcode,
                              Operation             = VR_MERGE_COLL,
                              p_ParamsListToModify  = NewAttrList,
                              NbParamsToModify      = NumNewAttrList,
                              OutParList            = &OldAttrList,
                              OutNumPar             = &NumOldAttrList);

        sts = om$send( msg      = message VCRoot.VCmodSysAttributes (&retcode,
                                        NumOldAttrList , OldAttrList, md_env),
                       senderid = NULL_OBJID,
                       targetid = OldTerm[0].objid,
                       targetos = OldTerm[0].osnum);


	/*-- This NewChldTerm[j] may NO LONGER be used for whatever swaps --*/
	TermUsedFlag[ j ] = 1; 

	break;
    }
    }

cont1:

/*-----------------------
9.   Move OldEquip to its old place.

    new_env = *md_env;
    new_env.md_id.objid = NULL_OBJID;

    MAtypemx( &retcode, matrix, &matrix_type);
 
    sts = om$send(msg  = message GRgraphics.GRxform( &retcode,
                           &new_env, &matrix_type, matrix, &new_objid),
              senderid = NULL_OBJID,
              targetid = OldEquip.objid,
              targetos = OldEquip.osnum);
    as$status(sts = sts);
-------------------------*/
 
/*-----------------------
# 	Add object back to to R-tree Range-tree 
-------------------------*/
    sts = om$send( msg   =  message GRgraphics.GRaddwrng(&retcode,md_env),
                senderid = NULL_OBJID,
                targetid = OldEquip.objid,
                targetos = OldEquip.osnum);
    as$status(sts=sts);
    __DBGpr_com(" Just done with Adding object back to to R-tree Range-tree");



/*-----------------------
# 	Notify Depandencies to recompute.
-------------------------*/
    sts = om$send(    msg = message NDnode.NDchange_node ( md_env ),
                 senderid = NULL_OBJID,
                 targetid = OldEquip.objid,
                 targetos = OldEquip.osnum );


/*-----------------------
#       Wrapup.
-------------------------*/
wrapup:
        if ( OldFeet     ){ _FREE ( OldFeet     ); OldFeet = NULL;}
        if ( NewFeet     ){ _FREE ( NewFeet     ); NewFeet = NULL;}

        if ( OldPretend  ){ _FREE ( OldPretend  ); OldPretend  = NULL;}
        if ( NewPretend  ){ _FREE ( NewPretend  ); NewPretend  = NULL;}

        if ( OldNozzle   ){ _FREE ( OldNozzle   ); OldNozzle   = NULL;}
        if ( NewNozzle   ){ _FREE ( NewNozzle   ); NewNozzle   = NULL;}

        if ( Child       ){ _FREE ( Child       ); Child   = NULL;}
        if ( Parent      ){ _FREE ( Parent      ); Parent  = NULL;}

        if ( NewChild    ){ _FREE ( NewChild    ); NewChild   = NULL;}
        if ( OldChild    ){ _FREE ( OldChild    ); OldChild   = NULL;}

        if ( OldTerm     ){ _FREE ( OldTerm     ); OldTerm = NULL;}
        if ( NewTerm     ){ _FREE ( NewTerm     ); NewTerm = NULL;}

        if ( OldCompTerm ){ _FREE ( OldCompTerm ); OldCompTerm = NULL;}
        if ( NewCompTerm ){ _FREE ( NewCompTerm ); NewCompTerm = NULL;}

        if ( OldChldTerm ){ _FREE ( OldChldTerm ); OldChldTerm = NULL;}
        if ( NewChldTerm ){ _FREE ( NewChldTerm ); NewChldTerm = NULL;}

        if ( OldAttrList ){ _FREE ( OldAttrList ); OldAttrList = NULL;}
        if ( NewAttrList ){ _FREE ( NewAttrList ); NewAttrList = NULL;}

        if ( OldUsrAttr  ){ _FREE ( OldUsrAttr  ); OldUsrAttr  = NULL;}
        if ( NewUsrAttr  ){ _FREE ( NewUsrAttr  ); NewUsrAttr  = NULL;}

	*msg = retcode & sts;

End
return ( OM_S_SUCCESS );
}



end implementation VREquipment;

