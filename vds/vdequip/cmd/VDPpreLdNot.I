/* $Id */

/* I/VDS
 *
 * File:	vdequip/cmd/VDPpreLdNot.I
 *
 * Description:
 *
 * This file contains functions and methods for manipulating PME preloaded 
 * Equipments form.
 *
 * Dependencies:
 *
 * History :
 * 10/31/95  MSM   Creation
 * 10/08/96  MRA   Added fix for TR#179602619.
 * 11/11/96  MRA   Added fix for TR#179603650.
 * 10/30/97  ah	   Fix warnings
 * 04/29/99  ah    Fixed compile problem when debug is enabled
 *----------------------------------------------------------------------------
 */

class implementation VDm_place;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "griomacros.h"

#include "vdsmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"
#include "VDPDatFrmDf.h"

#include "FI.h"

#define OBID_LEN	26

%safe
#include "VX_FIproto.h"
%endsafe

%safe
static char Catalog[macro_MAX_CHAR];
static char PartNum[macro_MAX_CHAR];
static char PartRev[macro_MAX_CHAR];
static char PMobid[26];
%endsafe

from VDPEqBuffer 	import 	VDPgetEquipList;
from VDPEqBuffer	import	VDPrsrvEquipment;

#argsused // Eliminate warnings

VDPPreldLstForm_notif(form_label,label,value,FormPtr)
int form_label,label;
IGRdouble value;
char *FormPtr;
{
    IGRlong		msg, status=OM_S_SUCCESS;
    IGRint		sel, row, pos, index=0;
    int                 IsReserved = FALSE;
    struct GRid 	cmd_obj;
    unsigned int   	cmd_oid;
    unsigned short 	cmd_os;
    char		PlFlag[6], tmpstr[VDPDESC_LEN];
    char                tmpbuf[2];
    char		*pStr;

    SetProc( VDPPreldLstForm_notif ); Begin

    FIf_get_cmd_oid_os(FormPtr,&cmd_oid,&cmd_os);
    cmd_obj.objid = (GRobjid)cmd_oid;
    cmd_obj.osnum = (GRspacenum)cmd_os;

    __DBGpr_obj ( "Command Obj OBID:", cmd_obj );

    FIfld_set_text( FormPtr, FI_MSG_FIELD, 0, 0, " ", FALSE );

    switch(label)
    {
	case FI_EXECUTE:
	    if( Catalog[0] && PartNum[0] && PartRev[0] )
	    {
		status =
		_VD_SEND_OBJN ( cmd_obj, VDm_place.VDPsetSelectedPart (
							&msg,
							Catalog,
							PartNum,
							PartRev,
							PMobid ));
		__CheckRC( status, msg, "VDPsetSelectedPart", wrapup );
	    }
	    FIf_erase( FormPtr);
	    break;

        case FI_CANCEL:
	    FIf_erase( FormPtr);
            break;

	case G_EQUIPMENT:
	    FIfld_get_active_row( FormPtr, G_EQUIPMENT, &row, &pos );
	    FIfld_get_text( FormPtr, G_EQUIPMENT, row, 2, 5, (unsigned char *)PlFlag, &sel, &pos );
	    __DBGpr_int( "select option:", sel );
	    __DBGpr_str("Placement Flag:", PlFlag );

	    if (!sel )
	    {
		Catalog[0] = PartNum[0] = PartRev[0] = '\0';
		PMobid[0] = '\0';
		break;
	    }

	    if( PlFlag[0] == 'Y' )
	    {
		FIfld_set_text( FormPtr, FI_MSG_FIELD, 0, 0, "Equipment Already Placed", FALSE );
		Catalog[0] = PartNum[0] = PartRev[0] = '\0';
	    }
	    else 
	    {
		FIfld_get_text( FormPtr, G_EQUIPMENT, row, 0, VDPDESC_LEN, (unsigned char *)tmpstr, &sel, &pos );
		__DBGpr_str("TmpStr :", tmpstr );

		Catalog[0] = PartNum[0] = PartRev[0] = '\0';
		index =0;
                pStr = NULL;

                pStr = (char *)strtok( tmpstr,":" );

                if( pStr )
                 strcpy( Catalog, pStr );

		index = strlen(Catalog)+1;

                pStr = NULL;

                if( tmpstr[index] != ':' )
                 pStr = (char *)strtok( &tmpstr[index], ":" );

                if( pStr )
                 strcpy( PartNum, pStr );

		index += strlen(PartNum)+1;

                pStr = NULL;

                if( tmpstr[index] != ':' )
                 pStr = &tmpstr[index];

                if( pStr )
                 strcpy( PartRev, pStr );

		__DBGpr_str("   Catalog :", Catalog );
		__DBGpr_str("   PartNum :", PartNum );
		__DBGpr_str("   PartRev :", PartRev );
		FIfld_get_text( FormPtr, G_EQUIPMENT, row, 3, VDPOBID_LEN, (unsigned char *)PMobid, &sel, &pos );

                if( !(Catalog[0] && PartNum[0] && PartRev[0]) )
                {
                  FIfld_set_text( FormPtr, FI_MSG_FIELD, 0, 0,
                        "Cannot place equipment with NULL Cat/Part/Rev",
                                  FALSE );
                  Catalog[0] = PartNum[0] = PartRev[0] = '\0';
		  break;
                }

		/* Check if this eguip item is reserved for placement.
		 TR 179602619 */
		IsReserved = VDPIsEquipReserved( &msg, PMobid );

		if( IsReserved == TRUE )
		{/* Set the "is_reserved" column and notify the user
		  that the equipment Item has already been placed.*/
		  tmpbuf[0] = 'Y';
		  tmpbuf[1] = '\0';
		  FIfld_set_text( FormPtr, G_EQUIPMENT, row, 2, tmpbuf, FALSE );
		  FIfld_set_text( FormPtr, FI_MSG_FIELD, 0, 0,
				  "Equipment Already Placed", FALSE );
		  Catalog[0] = PartNum[0] = PartRev[0] = '\0';

		  FIfld_set_text( FormPtr, FI_MSG_FIELD, 0, 0,
				  "Equipment Already Placed", FALSE );

		  /* Reserve Equipment Item in the Cache */
		  status = VDPreserveEquip( &msg, PMobid );

		  if( status != OM_S_SUCCESS )
		   UI_status( "Failed to reserve equipment item in cache" );
		}
		/* end fix for TR 179602619 */
	    }
	    
	    break;

        default :
            break;
    }

wrapup:
    End
    return  status;
}


VDPInitialiseForm( FormPtr )
char	*FormPtr;
{
    IGRlong			msg, status=OM_S_SUCCESS;
    IGRchar			PlacementCtx[VDPNAME_LEN];
    IGRchar			ContextId[VDPOBID_LEN];
    IGRchar			ListName[DI_PATH_MAX],
				EqpString[VDPDESC_LEN],
				tmpbuf[2];
    IGRint			i, nbEqp;
    OMuword			curOs;
    struct GRid			Buf;
    struct VDPpre_ld_eqp	*EqpList;

    SetProc( VDPInitialiseForm ); Begin

    ex$get_cur_mod( osnum = &curOs );
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = ListName );

    __CheckRC( status, 1, "di$give_pathname", wrapup );
    __DBGpr_str( "Path name", ListName );
    strcat (ListName, PME_GLOBAL_DIR );
    strcat (ListName, PME_EQP_LIST );

    status =
    di$translate  ( objname = ListName,
		    p_objid = &Buf.objid,
		    p_osnum = &Buf.osnum ) ;

    __DBGpr_obj( "Equipment Buffer Id", Buf );

    if( status == DIR_S_SUCCESS )
    {
	/* Query the Equipment List buffer */
	status =
	_VD_SEND_OBJN ( Buf, VDPEqBuffer.VDPgetEquipList (
						&msg,
						&nbEqp,
						&EqpList ));
	__CheckRC( status, msg, "VDPgetEquipList", wrapup );

	FIfld_set_num_rows(FormPtr, G_EQUIPMENT, nbEqp );


	for( i=0; i < nbEqp; i++ )
	{
	    EqpString[0] = '\0';

	    __DBGpr_str(" ------->Catalog:", EqpList[i].Catalog );
	    __DBGpr_str(" ------->PartNumber:", EqpList[i].PartNumber );
	    __DBGpr_str(" ------->PartRev:", EqpList[i].PartRev );

	    sprintf( EqpString,"%s:%s:%s", EqpList[i].Catalog, 
					   EqpList[i].PartNumber,
					   EqpList[i].PartRev );

	    FIfld_set_text ( FormPtr, G_EQUIPMENT, i, 0, EqpString, 0 );
	    FIfld_set_text ( FormPtr, G_EQUIPMENT, i, 1, EqpList[i].Desc, 0 );
	    tmpbuf[0] = EqpList[i].PlacedFlag; tmpbuf[1] = '\0';
	    FIfld_set_text ( FormPtr, G_EQUIPMENT, i, 2, tmpbuf, 0);
	    FIfld_set_text ( FormPtr, G_EQUIPMENT, i, 3, EqpList[i].PMobid, 0);
	}

    /* for now use some dummy data */
/*
    FIfld_set_text ( FormPtr, G_EQUIPMENT, 0, 0,"chair:chair:1", 0);
    FIfld_set_text ( FormPtr, G_EQUIPMENT, 0, 1,"Desc1", 0);
    FIfld_set_text ( FormPtr, G_EQUIPMENT, 0, 2,"N", 0);

    FIfld_set_text ( FormPtr, G_EQUIPMENT, 1, 0,"chair:chair:1", 0);
    FIfld_set_text ( FormPtr, G_EQUIPMENT, 1, 1,"Desc2", 0);
    FIfld_set_text ( FormPtr, G_EQUIPMENT, 1, 2,"Y", 0);
*/

	status = VDPGetPlacementContext( &msg, PlacementCtx, ContextId );
	FIfld_set_text ( FormPtr, G_PLACEMENT_CTX, 0, 0, PlacementCtx, 0 );
    }

wrapup :
    _FREE ( EqpList );
    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPreserveEquip

  Abstract
  Given an equipment item OBID, this function reserves it in the
  PME_EQP_LIST Named Object.

  Returns OM_S_SUCCESS if sucessful, or an appropriate ERROR value otherwise.

  Algorithm

-fi*/
VDPreserveEquip( IGRlong *msg,		/* O */
		 IGRchar *EqpObid )	/* I */
{
  struct GRid Buf;
  OMuword     curOs;
  IGRchar     ListName[DI_PATH_MAX];
  IGRlong     status = OM_S_SUCCESS;

  SetProc( VDPreserveEquip ); Begin

  *msg = MSSUCC;

  /* Reserve the item for further Placement in the local buffer */
  ex$get_cur_mod( osnum = &curOs );
  status = di$give_pathname(  osnum           = curOs,
                              pathname        = ListName );

  __CheckRC( status, 1, "di$give_pathname", wrapup );
  __DBGpr_str( "Path name", ListName );
  strcat( ListName, PME_GLOBAL_DIR );
  strcat( ListName, PME_EQP_LIST );

  status =
  di$translate( objname = ListName,
                p_objid = &Buf.objid,
                p_osnum = &Buf.osnum ) ;

   __DBGpr_obj( "Equipment Buffer Id", Buf ); 

   if( status == DIR_S_SUCCESS )
   {
     /* Reserve equipment item in the equipment Buffer */
     status =
     _VD_SEND_OBJN( Buf, VDPEqBuffer.VDPrsrvEquipment( msg, EqpObid) );
     __CheckRC( status, *msg, "VDPrsrvEquipment", wrapup );
   }

 wrapup:
 End
 return status;
}

end implementation VDm_place;
