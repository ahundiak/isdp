/* $Id: VDStorage.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	usr/kddinov/vds/vdtools / VDStorage.I
 *
 * Description:
 *		General I/VDS storage utility. 
 *		To be used instead of statis declarations. 
 *		Template taken from Route. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDStorage.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/29  21:15:08  pinnacle
# Replaced: vdtools/VDStorage.I for:  by kddinov for vds
#
# Revision 1.1  1997/11/24  20:54:28  pinnacle
# Created: vdtools/VDStorage.I by kddinov for vds
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	Oct-97	kdd		creation
 *
*-------------------------------------------------------------------------------
*
*  PARAMETERS
*
* I/O:  char    *data   - pointer to memory location to operate on.
*                             You must cast this to other types when adding new
*                             features here.
*
* I:    int     index   - index for the storage type, as in VDToolsDef.h.
*
* I:    char    *name   - if != NULL then this is the name of data storage.
*
* I:    int     Operation - If 1 set to static storage from data,
*                             If 0 get from static storage to data.
*
*-------------------------------------------------------------------------------
*
*  Notes:
*
*  If data == NULL, the storage corresponding to index (name) is initialized.
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
#include "ACrg_collect.h"
#include "VDToolsDef.h"
#include "v_dbgmacros.h"

#define GET     0
#define SET     1

/*----------------------------------------------------------------------------*/
int VDStorage(          char    *data,
                        int     index,
                        char    *name,
                        int     Operation)
{
  int			status = 1;
  IGRlong		retmsg;
  struct GRid           *p_ObjectId;
  struct ACrg_coll      Attrib;
  struct GRmd_env	*p_EqpStoreEnv;


/*------------------------  Storage declarations --------------------------*/

static struct GRid      PidSelectEquip ={ (GRspacenum) 0, (GRobjid) -1};
static struct GRid      PlaceEqpFromPID={ (GRspacenum) 0, (GRobjid) -1};
static struct GRid      PlacedEquipment={ (GRspacenum) 0, (GRobjid) -1};
static struct GRmd_env  EqpStoreEnv;


/*------------------------  Initialize declarations -------------------*/
static struct GRid      Init_GRid ={ (GRspacenum) 0, (GRobjid) -1};


/*-------------------------
#  Get index from name.
---------------------------*/
  if ( name ) {
     if      (!strcmp( name, "PidSelectEquip"))  index = VDPidSelectEquip;
     else if (!strcmp( name, "PlaceEqpFromPID")) index = VDPlaceEqpFromPID;
     else if (!strcmp( name, "PlacedEquipment")) index = VDPlacedEquipment;
     else if (!strcmp( name, "EqpStoreEnv")) 	 index = VDEqpStoreEnv;
  }


/*-------------------------
#  Apply the Operation to the storage and input data. 
---------------------------*/
  switch ( index )  {
  case VDPlacedEquipment:
        if ( data == NULL )  { PlacedEquipment = Init_GRid; break;}

        p_ObjectId = (struct GRid *) data;
        if ( Operation == SET  ) PlacedEquipment = *p_ObjectId;
        else                     *p_ObjectId     = PlacedEquipment;

        break;



  case VDPlaceEqpFromPID: 
        if ( data == NULL ) { PlaceEqpFromPID = Init_GRid; break;}

       	p_ObjectId = (struct GRid *) data;
       	if ( Operation == SET  ) PlaceEqpFromPID = *p_ObjectId;
       	else                     *p_ObjectId     = PlaceEqpFromPID;

	break;



  case VDPidSelectEquip:     
	if ( data == NULL ) { PidSelectEquip = Init_GRid; break;}

        p_ObjectId = (struct GRid *) data;
 	if ( Operation == SET  ) PidSelectEquip = *p_ObjectId;
        else                     *p_ObjectId    = PidSelectEquip;

	break;



  case VDEqpStoreEnv   :
	if ( data == NULL ) break;

        p_EqpStoreEnv = (struct GRmd_env *) data;
        if ( Operation == SET  ) EqpStoreEnv = *p_EqpStoreEnv;
        else                     *p_EqpStoreEnv   = EqpStoreEnv;

        break;



  default: 
  	printf("Unimplemented feature of VDStorage.I.\n"); 
	break;

  }

wrapup:
return (1);
}



end implementation Root;
