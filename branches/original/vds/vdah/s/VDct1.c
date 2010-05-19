/* $Id: VDct1.c,v 1.2 2001/05/02 15:13:20 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/s/VDct1.c
 *
 * Description: Tree Manager Stubs
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1.c,v $
 *      Revision 1.2  2001/05/02 15:13:20  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/02/09 22:25:32  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/09/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDct1.h"

IGRstat VDctxInitCt1CP(void *v1, void *v2)
{
  return 0;
}

IGRstat VDctxInitOmCP(void *v1, void *v2)                     
{
  return 0;
}
IGRstat VDctxInitAtCP(void *v1, void *v2)
{
  return 0;
}

IGRstat VDatGetSetMgr(VDosnum osnum, TGRid *mgrID)
{
  if (mgrID) mgrID->objid = NULL_OBJID;
  return 1;
}

IGRstat VDct1GetManager(VDosnum osnum, TGRid *mgrID)
{
  if (mgrID) mgrID->objid = NULL_OBJID;
  return 1;
}

// Proto is in VDct1CmdTree.h which is obsolete
IGRstat VDct1PreExpandContractNode(TGRid *nodeID, IGRchar *op)
{
  return 1;
}

// This is a big hairy .I
IGRstat VDitemdbGetMatIDForObject(TGRid   *myGRid, 
				  IGRchar *keyValue)
{
  if (keyValue) *keyValue = 0;
  return 1;
}



