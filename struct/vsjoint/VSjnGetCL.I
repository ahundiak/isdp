/* $Id: VSjnGetCL.I,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsjoint/VSjnGetCL.I
 *
 * Description: Override VDSroot.VDGetCenterLine
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSjnGetCL.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/12/15  22:37:46  pinnacle
# VDGetCenterLine
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *	12/14/97  ah      Override VDSroot.VDGetCenterLine
 *
 ***************************************************************************/

class implementation VSjoint;

#include "VDmaster.h"

method VDGetCenterLine(	
  IGRlong   *msg;
  TGRmd_env *md_env;
  IGRint    *count;
  TGRid	    **list
)
{
  printf("VSjoint.VDGetCenterLine is not yet implemented\n");
  *msg = 0;
  return 0;
}

end implementation VSjoint;
