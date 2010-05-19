/* $Id: VDbtTest.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDbtTest.I
 *
 * Description: Test the low level routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtTest.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/07  14:33:40  pinnacle
# ah
#
# Revision 1.1  1998/04/02  21:21:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

//#include "VDmaster.h"
#include "VDbt.h"
#include "VDsaProto.h"

IGRstar VDbtTestBase()
{
  IGRstat retFlag = 0;
/*  
  TGRid mgrID;
  TGRid objID;
  TGRid miscID;
*/
  TGRid catsID;
  
//  TVDfld fld;
  IGRchar tableName[128];
  
  //vdbt$GetCache  (mgrID = &mgrID);
  //vdbt$DeleteBase(objID = &mgrID);

  // vdbt$GetCache  (miscID = &mgrID);
  // vdbro$PrintObject(objID = &mgrID);

  //vdbt$GetCache(miscID = &miscID);
  //vdbro$PrintObject(objID = &miscID);
  
  vdsa$GetCache(catsID = &catsID);
  vdbro$PrintObject(objID = &catsID);
  
  vdsa$GetDynTable(i_family = "us_plate", tableName = tableName);
  vdsa$GetDynTable(i_family = "chair",    tableName = tableName);
  vdsa$GetDynTable(i_family = "nozz1",    tableName = tableName);
  
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

end implementation VDbtBase;
