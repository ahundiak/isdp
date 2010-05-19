/* $Id: main.c,v 1.2 2001/02/11 17:24:17 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/main.c
 *
 * Description: Stand alone test driver
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: main.c,v $
 *      Revision 1.2  2001/02/11 17:24:17  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/07/00  ah      Creation
 *
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDrisc.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"

VDASSERT_FFN("vdct1/part/VDct1IOC.c");

main()
{
  VDrsxOpenSchema(NULL);
  
  VDct1DumpIOCTable();
}
