/* $Id: VDsupGen.S,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupGen.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupGen.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/18  14:39:28  pinnacle
# VDsupEtc
#
# Revision 1.3  1997/10/29  15:23:56  pinnacle
# Add VDmaster.h
#
# Revision 1.2  1997/10/28  18:16:14  pinnacle
# Assorted 2.5 Fixes
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/28/97  ah      Added header
 * 12/18/97  ah      Added Get/Set Longs Method
 ***************************************************************************/

class specification VDsupGen (0:0) of VDSroot;

/* ------------------------------------------
 * Common support curve methods
 */

#include "VDmaster.h"

/* Let 1 macro do various things */

instance VDsupGen 
{
  IGRlong             typeMacro;
  variable  IGRlong   typeTempList[0];
};

message VDsupChkMinInput(int *msg; TGRid *tl; char *form_buff);

message VDsupSetTempList(TGRid *tlId; IGRlong tlNum; IGRlong *tx; IGRlong *tempNum; TGRid *tempListId);
message VDsupGetTempList(TGRid *tlId; IGRlong tlNum; IGRlong *tx);

message VDsupSetType(IGRlong  type);
message VDsupGetType(IGRlong *type);

/*
 * 12/17/97 Add a generic interface to the variable long array
 */
message VDsupSetLongs(IGRlong *longs; IGRlong  cnt);
message VDsupGetLongs(IGRlong *longs; IGRlong *cnt);

override VDgetObjDef;
override ACconstruct_feet;

end specification VDsupGen;
