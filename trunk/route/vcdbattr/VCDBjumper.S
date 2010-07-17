
/* $Id: VCDBjumper.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vcdbattr/VCDBJumper.S
 *
 * Description:
 *
 * Specification file for cabling DB cache - Jumper specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBjumper.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/01/19  09:26:16  pinnacle
# Created: vcdbattr/VCDBjumper.S by aharihar for route
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      09/21/98          Alwin            Creation
 *
 * -------------------------------------------------------------------*/

class specification VCDBjumper (0:0) of VCDBgen;

#include "VCdbstructs.h"

instance  VCDBjumper
{
  struct VCdbjumper      Jumper;
};

override  VCDB_ghdr;
override  VCDB_init;
override  VCGpAnum;
override  VCDB_fill;
override  VCGetAttr;

end specification VCDBjumper;
