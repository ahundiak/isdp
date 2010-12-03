/* $Id$  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1SirGrp.h
 *
 * Description: Group placeable object info
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1SirGrp.h,v $
 *      Revision 1.1  2003/05/23 21:35:37  ylong
 *      Created for Placement Group Tree
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/20/03  yl      creation
 ***************************************************************************/

typedef struct {

TGRobj_env	objOE;
IGRchar		comptNo[80];
IGRchar		partType[80];
IGRchar		grpName[80];
IGRchar		itemName[80];

} TVDSirGrpInfo;

