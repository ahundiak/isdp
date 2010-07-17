
/* $Id: VCDBgen.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBgen.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   abstract class implementing methods for master record access
 *   also incorporate basic desired AC behaviour
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBgen.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/14  21:44:26  pinnacle
# Replaced: vcdbattr/VCDBgen.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:53:34  pinnacle
# Created: vcdbattr/VCDBgen.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBgen (0:0) of VCDB,VDSroot;

#include   "VCproto.h"

instance  VCDBgen
{
  struct VCdbmain   DBMain;
};

override  VCGpAnum;
override  VCDB_init;
override  VCDB_ghdr;

override  NDsleep;
override  NDupdate;
override  ACconstruct_feet;

end specification VCDBgen;

