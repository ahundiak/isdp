
/* $Id: VCDBcbgd.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBcbgd.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   General cable/guide specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBcbgd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/14  21:44:14  pinnacle
# Replaced: vcdbattr/VCDBcbgd.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:53:06  pinnacle
# Created: vcdbattr/VCDBcbgd.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBcbgd (0:0) of VCDBgen;

instance  VCDBcbgd
{
};

override  VCDB_ghdr;
override  VCGpAnum;
override  VCDB_init;

end specification VCDBcbgd;

