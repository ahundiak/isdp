/* $Id: VCPidGetTerm.I,v 1.2 2001/02/20 01:13:34 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	route/vrequip / VRPidGetTerm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCPidGetTerm.I,v $
 *      Revision 1.2  2001/02/20 01:13:34  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:50  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/29  22:24:12  pinnacle
# Replaced: vrequip/VCPidGetTerm.I for:  by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	Sept 97		kdd	VCPidEqp_GetTerminals
 *
*------------------------------------------------------------------------------
*  This one is different from VRPidEqp_GetNozzles, because the feet name for
*  terminals is not the guide to replace, rather the tag number is. 
 *************************************************************************/
class implementation Root;
 
/*
#define vdsDEBUG        1
*/
 
 
#include <stdio.h>
 
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "nddef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VRutildef.h"
#include "VRattr_def.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "vrdbgmacros.h"
#include "VDmem.h"

#include "VRutildef.h"
#include "VRchannel.h"

#include "vc_define.h"
#include "vc_structs.h"
#include "VCstructs.h" 


from	VRGeneric	import	VRGetParams;
from	VCRoot		import	VCGetInstance;
from 	VCMac		import	VCMmacname,
				VCGetEquipTag;

extern int 	VRGetAttribute();


from NDnode	import 	ASreturn_go;
from NDmacro	import 	ACreturn_foot;
from ACcpx	import 	find_macro;
from ACcpx_defn	import 	ACgive_feet_desc;
from VCTerm	import	VCTembed;


/*******************************************************************************
* KDD Sept 1997
*  Gets VCTerm feet templates and corresponding VCTerm placed child terminals 
*  of Pid Equipment (if any, Cable doesn't do post-placement by default).
*-------------------------------------------------------------------------------
*
* I: EquipId	struct GRid	- Pid Equipment object ID.
*
* O: NumFeet	*int		- number of template terminals (components).
*
* O: Feet[]     *(struct GRid ) - list of template terminals, ancestry of VCTerm
*				  I allocate memory, the caller must free it. 
*
* O: NumChild	*int		- number of children (placed terminals).
*
* O: Child[]  	*(struct GRid)	- list of placed terminals ACpretend IDs. 
*				  The actual VCTerm are children of ACpretend.
*				  I allocate memory, the caller must free it. 
*
* I: md_env     *(struct GRmd_env) - Module environment as returned from locate.
*-------------------------------------------------------------------------------
*
* RETURN status:
*
* 1     - OK
* even  - problems
*******************************************************************************/

int VCPidEqp_GetTerminals( 	   struct GRid		EquipId,
				   int			*p_NumFeet,
				   struct GRid		**Feet,
				   int			*p_NumChild,
				   struct GRid		**Child,
				   struct GRmd_env      *md_env)
{
   struct GRid		GraphicsId, MacDefId, FootId,
			SysParId, UsrParId, MisParId,
			*ACpretend = NULL,
			*VCTerm    = NULL,
			*p_Feet    = NULL, 
			*p_Child   = NULL;

   struct myfeet        *FeetDesc = NULL;

   char			ClassName[64]={""};

   IGRlong		sts = 1, retcode;

   int			i, j, count, 
			NumFeet = 0, NumChild = 0, NumVCTerm = 0,
			NumACpretend = 0; 

   struct VCGenInfo	Instance;
   char			MacroName[80], TagName[80];

   IGRboolean           Embedded;


SetProc(VCPidEqp_GetTerminals); Begin

   GraphicsId.objid = NULL_OBJID;
   MacDefId.objid   = NULL_OBJID;
   FootId.objid     = NULL_OBJID;

   SysParId.objid   = NULL_OBJID;
   UsrParId.objid   = NULL_OBJID;
   MisParId.objid   = NULL_OBJID;
/*-------------------------
# Initialize 
-------------------------*/
   if ( EquipId.objid == NULL_OBJID ) { sts = 0; goto wrapup; } 

__DBGpr_obj("Equipment ID                ", EquipId); 

/*-------------------------
* KDD 12-97 
* We can skip step 1. because terminals coming from the macro definition 
* of the equipment have instance data me->nVCType set to VC_GEN_EXTERN
* Or you can use VCTerm.VCEmbed method and ask for this info. 
-------------------------*/

/*-------------------------
#1  Get VCEmbed feet (same function as VRNozHold).
-------------------------*/
   sts = om$send( msg     = message NDnode.ASreturn_go( &GraphicsId, NULL,NULL),
		 senderid = NULL_OBJID,
                 targetid = EquipId.objid,
		 targetos = EquipId.osnum);
   as$status(sts = sts, action = GOTO_VALUE, value = wrapup);
 
    sts = om$send(  msg   = message ACcpx.find_macro (&MacDefId),
		 senderid = NULL_OBJID,
                 targetid = GraphicsId.objid,
                 targetos = GraphicsId.osnum);
    as$status(sts = sts, action = GOTO_VALUE, value = wrapup);
 
 
    sts = om$send( msg      = message ACcpx_defn. ACgive_feet_desc
                                        ( &count, &FeetDesc ),
		   senderid = NULL_OBJID,
                   targetid = MacDefId.objid,
                   targetos = MacDefId.osnum );
    if ( !(sts&1) ) count = 0; 
 
    NumFeet = 0;
    for (i=0; i < count; i++ ) {
        sts = om$send ( msg = message NDmacro.ACreturn_foot
                               (&retcode, FeetDesc[i].name, &FootId,NULL, NULL),
		   senderid = NULL_OBJID,
                   targetid = GraphicsId.objid,
                   targetos = GraphicsId.osnum);
	as$status(sts = sts);
        if ( !(sts & 1) || !(retcode & 1) ) continue;
 
        om$get_classname( objid           = FootId.objid,
                          osnum           = FootId.osnum,
                          classname       = ClassName);

        if( om$is_ancestry_valid( subclassname   = ClassName,
                                  superclassname = "VCEmbed" ) != OM_S_SUCCESS){
	    continue; 
	}

	if ( NumFeet == 0 ) p_Feet = _MALLOC( 1, struct GRid); 
	else          	    p_Feet = _REALLOC(p_Feet, NumFeet+1, struct GRid);

        p_Feet [ NumFeet ] = FootId;
__DBGpr_obj("Feet VCTerm                  ", p_Feet [ NumFeet ]); 
	NumFeet++; 
    }
 

/*-------------------------
#2  Get VCTerm children (ACpretend connection).
-------------------------*/
    sts = vr$get_channel_objects(  objid            = EquipId.objid,
                                   osnum            = EquipId.osnum,
                                   chan_name        = "children",
                                   filter_class     = "ACpretend,ACpretendin",
                                   operation        = VR_INCLUDE,
                                   count            = &NumACpretend,
                                   object_list      = &ACpretend);

    if ( !(sts & 1) ) NumACpretend = 0; 

    NumChild = 0; 

    for ( i = 0; i < NumACpretend; i++) {
        if ( VCTerm ) { _FREE( VCTerm ) ; VCTerm = NULL;}
	NumVCTerm = 0;

	sts = vr$get_channel_objects( objid          = ACpretend[i].objid,
				      osnum	     = ACpretend[i].osnum,
                                      chan_name      = "children",
                                      ancestry_class = "VCTerm",
                                      operation      = VR_INCLUDE,
                                      count          = &NumVCTerm,
                                      object_list    = &VCTerm);

	if ( !(sts & 1) || (NumVCTerm != 1) ) continue; 

	Embedded = FALSE;

        sts = om$send( msg      = message VCTerm.VCTembed( &Embedded ),
                       senderid = NULL_OBJID,
                       targetid = VCTerm[ 0 ].objid,
                       targetos = VCTerm[ 0 ].osnum);
        if ( !Embedded) { continue; }


        if (NumChild == 0) p_Child = _MALLOC( 1, struct GRid);
        else               p_Child = _REALLOC( p_Child, NumChild+1,struct GRid);

	p_Child [ NumChild ] = ACpretend [ i ] ; 

__DBGpr_obj("Child VCTerm                 ", p_Child [ NumChild ] ); 
	NumChild++;
    }

/*-------------------------
#  Wrapup
-------------------------*/
wrapup:

/* NOTE (KDD Sept, 1997): 
*  ACcpx_defn. ACgive_feet_desc doesn't allocate memory, instead returns 
*  pointer to the actual memory location for the feet description. 
*  This is a violation of the Data Encapsulation Principle.
*   if ( FeetDesc ) { _FREE ( FeetDesc ) ; FeetDesc = NULL; } 
*/

   if ( ACpretend) { _FREE ( ACpretend) ; ACpretend= NULL; } 
   if ( VCTerm ) { _FREE ( VCTerm ) ; VCTerm = NULL; } 

   if ( p_NumChild ) *p_NumChild = NumChild;
   if ( p_NumFeet  ) *p_NumFeet  = NumFeet;

   if ( Child ) *Child = p_Child;
   else         { _FREE ( p_Child); p_Child = NULL;} 

   if ( Feet  ) *Feet  = p_Feet;
   else         { _FREE ( p_Feet); p_Feet = NULL;} 

End;
return ( sts); 
}




end implementation Root;

