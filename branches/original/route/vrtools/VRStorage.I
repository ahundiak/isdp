/* $Id: VRStorage.I,v 1.2 2001/02/20 01:18:09 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip / VRStorage.I
 *
 * Description:
 *		General I/Route static storage utility. 
 *		Use this one instead of statis declarations. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRStorage.I,v $
 *	Revision 1.2  2001/02/20 01:18:09  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/20  15:35:04  pinnacle
# Created: vrtools/VRStorage.I by kddinov for route
#
# Revision 1.1  1997/10/01  20:58:38  pinnacle
# Created: vrtools/VRStorage.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	8-97	   KDD		creation 
*-------------------------------------------------------------------------------
*
*  PARAMETERS
*
*  char         *data   :I  - pointer to memory location to operate on.
*                             You will cast this to other types when adding new
*                             features here.
*
*  int          index   :I  - index for the storage type, as in VRutildef.h.
*
*  char         *name   :I  - if != NULL, then use name to indicate the
*                             storage data type. Index then may indicate the
*                             element from a list.
*
*  int          Operation :I -If 1 set to static storage from data,
*                             If 0 get from static storage to data.
*-------------------------------------------------------------------------------
*************************************************************************/
class implementation Root;

/*
#define vdsDEBUG	1
*/


#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "nddef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "AS_status.h"
#include "VRutildef.h"
#include "vrdbgmacros.h"

extern  GRclassid       OPP_ACrg_collect_class_id;

from 	NDnode	import	NDchg_state;

/*****************************************************************************/
int VRStorage(          char    *data,
                        int     index,
                        char    *name,
                        int     Operation)
{
#define GET     0
#define SET     1

  int                   status = 1;
  struct GRid           *p_ObjectId;
  int			*p_int; 

/*------------------------  Storage declarations --------------------------*/

static struct GRid      PidModifyEquip ={ (GRspacenum) 0, (GRobjid) -1};
static struct GRid      PidSelectEquip ={ (GRspacenum) 0, (GRobjid) -1};
static struct GRid      PidPlaceEquip  ={ (GRspacenum) 0, (GRobjid) -1};
static struct GRid      PidSysParId={ (GRspacenum) 0, (GRobjid) -1};
static struct GRid      PidUsrParId={ (GRspacenum) 0, (GRobjid) -1};
static char		PidEquipDescr[41]={""}; 
static char		PidEquipNumber[41]={""}; 
static char		PidTableName[41]={""}; 

static int		PidSelCmd = 0; 

static int		FlowDirOldSymbol=0; 


/*------------------------  Initialization       --------------------------*/
  if ( !data ) {goto wrapup; }


/*-------------------------
#  Select the data storage type. By name or index. 
---------------------------*/
  if ( name ) {
     if ( !strcmp( name, "VRPidSelectEquip") ) 	goto l_PidSelectEquip;
     if ( !strcmp( name, "VRPidEquipDescr") )  	goto l_PidEquipDescr;
     if ( !strcmp( name, "VRPidSysParId") )  	goto l_PidSysParId;
     if ( !strcmp( name, "VRPidUsrParId") )  	goto l_PidUsrParId;
  }

  switch ( index )  {
     case VRPidSelectEquip:     goto l_PidSelectEquip;
     case VRPidEquipDescr :     goto l_PidEquipDescr;
     case VRPidSysParId   :     goto l_PidSysParId;
     case VRPidUsrParId   :     goto l_PidUsrParId;
     case VRPidSelCmd     :     goto l_PidSelCmd;
     case VRPidEquipNumber:	goto l_PidEquipNumber;
     case VRPidTableName  :	goto l_PidTableName;
     case VRPidPlaceEquip :	goto l_PidPlaceEquip;
     case VRPidModifyEquip:	goto l_PidModifyEquip;

     case VRFlowDirOldSymbol:	goto l_FlowDirOldSymbol;

     default:                   goto wrapup;
  }


/*-------------------------
#  Apply the Operation to the storage and input data. 
---------------------------*/
l_FlowDirOldSymbol:
	p_int = (int *) data;
        if ( Operation == SET  ) FlowDirOldSymbol = *p_int;
        else                     *p_int           = FlowDirOldSymbol;
	goto wrapup;


l_PidTableName:
        if ( Operation == SET  ) strncpy(PidTableName, data,         40);
        else                     strncpy(data,         PidTableName, 40);
        goto wrapup;


l_PidEquipNumber:
        if ( Operation == SET  ) strncpy(PidEquipNumber, data,           40);
        else                     strncpy(data,           PidEquipNumber, 40);
	goto wrapup;


l_PidEquipDescr:
        if ( Operation == SET  ) strncpy(PidEquipDescr, data,          40);
        else                     strncpy(data,          PidEquipDescr, 40);
        goto wrapup;


l_PidModifyEquip:
        p_ObjectId = (struct GRid *) data;
        if ( Operation == SET  ) PidModifyEquip  = *p_ObjectId;
        else                     *p_ObjectId     = PidModifyEquip;
        goto wrapup;
 
 

l_PidPlaceEquip:
        p_ObjectId = (struct GRid *) data;
        if ( Operation == SET  ) PidPlaceEquip  = *p_ObjectId;
        else                     *p_ObjectId    = PidPlaceEquip;
        goto wrapup;
 
 
l_PidSelectEquip:
        p_ObjectId = (struct GRid *) data;
        if ( Operation == SET  ) PidSelectEquip = *p_ObjectId;
        else                     *p_ObjectId    = PidSelectEquip;
        goto wrapup;


l_PidSelCmd:
	p_int = (int *) data;
        if ( Operation == SET  ) PidSelCmd = *p_int;
        else                     *p_int    = PidSelCmd; 
        goto wrapup;



l_PidSysParId:
	if ( PidSysParId.objid == (GRobjid) -1 ) {
	  PidSysParId.osnum = OM_Gw_current_OS;

          status =
          om$construct( classid = OPP_ACrg_collect_class_id,
                        p_objid = &PidSysParId.objid,
                        osnum   = PidSysParId.osnum,
                        msg     = message NDnode.NDchg_state( ~0, ND_DEFAULT));
          as$status( action = GOTO_VALUE, value = wrapup );
	}
 
        p_ObjectId = (struct GRid *) data;
        if ( Operation == SET  ) printf("Invalid operation 1 in VRStorage.I\n");
        else                     *p_ObjectId = PidSysParId;
        goto wrapup;



l_PidUsrParId:
        if ( PidUsrParId.objid == (GRobjid) -1 ) {
	  PidUsrParId.osnum = OM_Gw_current_OS;

          status =
          om$construct( classid = OPP_ACrg_collect_class_id,
                        p_objid = &PidUsrParId.objid,
                        osnum   = PidUsrParId.osnum,
                        msg     = message NDnode.NDchg_state( ~0, ND_DEFAULT));
          as$status( action = GOTO_VALUE, value = wrapup );
        }

        p_ObjectId = (struct GRid *) data;
        if ( Operation == SET  ) printf("Invalid operation 2 in VRStorage.I\n");
        else                     *p_ObjectId = PidUsrParId;
        goto wrapup;




wrapup:
return status;
}



end implementation Root;
