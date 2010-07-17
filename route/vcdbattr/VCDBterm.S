
/* $Id: VCDBterm.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBterm.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   General terminals specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBterm.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/14  21:44:44  pinnacle
# Replaced: vcdbattr/VCDBterm.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:54:22  pinnacle
# Created: vcdbattr/VCDBterm.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBterm (0:0) of VCDBgen;

instance  VCDBterm
{
  variable struct VCdbmod      Mod[0];
};

override  VCDB_ghdr;
override  VCDB_init;
override  VCGpAnum;

override  VCGetLayout;
override  VCGetModules;

end specification VCDBterm;

