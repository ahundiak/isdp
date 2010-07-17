
/* $Id: VCDBGuide.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBGuide.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   General cable guide
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBGuide.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/14  21:43:36  pinnacle
# Replaced: vcdbattr/VCDBGuide.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:51:58  pinnacle
# Created: vcdbattr/VCDBGuide.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBGuide (0:0) of VCDBcbgd;

instance  VCDBGuide
{
};

override VCDB_fill;

end specification VCDBGuide;

