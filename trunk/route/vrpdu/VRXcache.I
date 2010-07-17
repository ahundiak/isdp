/* $Id: VRXcache.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRdbCache.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXcache.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:36  pinnacle
# Created: vrpdu/VRXcache.I by hverstee for route
#
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/04/22  13:57:16  pinnacle
 * Replaced: vrpdu/VRdbCache.c for:  by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:08  pinnacle
 * Replaced: vrpdu/VRdbCache.c for:  by r240_int for route240
 *
 *
 * History:
 *     10/26/94  Lori  CR#179422038 added spec to HVAC - change
 *                         initial previous cache product from 0 to -1
 *                         so not to be confused with VR_HVAC (which is 0)
 *     01/17/96  tlb   Add prototypes
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>

#include "igrtypedef.h"

#include "VRDbCache.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"

#include "vrpdu_pto.h"

extern   IGRint    atoi();
extern   IGRdouble atof();

/* Global Cache structure */

int VR_DbC_Clear ()
{

  IGRlong      retmsg;

  VR_DbC_Clunt ();

  VR_DbC_Clnpd ();

  VR_DbC_Clpid ();

  VR_DbC_Clnoz ();

  VR_DbC_Clnfl ();

  VR_DbC_Clhdb ();

  VR_DbC_Clrdb ();

  VR_DbC_Cleql ();

  VR_DbC_ClCdl ();

  VR$PDB_INIT (p_msg = &retmsg);

  VR$HDB_INIT (p_msg = &retmsg);

  VR$RDB_INIT (p_msg = &retmsg);

  UI_status ("Route DB cache cleared");

  return 0;
}

void   VRDBstr  (IGRchar     *Cout,
                 IGRchar     *Cin)
{
  if (Cin == NULL)   Cout[0] = '\0';
  else
  if (Cin[0] == ' ') Cout[0] = '\0';
  else
                     strcpy (Cout, Cin);

  return;
}

IGRint   VRDBint  (IGRchar     *Cin)
{
  IGRint    iret;

  iret = 0;

  if (Cin != NULL) iret = atoi (Cin);

  return (iret);
}

IGRdouble   VRDBdbl  (IGRchar     *Cin)
{
  IGRdouble    dret;

  dret = 0;

  if (Cin != NULL) dret = atof (Cin);

  return (dret);
}


end implementation Root;

