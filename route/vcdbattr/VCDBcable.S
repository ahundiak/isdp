
/* $Id: VCDBcable.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBcable.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   General cable layout specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBcable.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.1  1997/07/14  21:46:08  pinnacle
# Created: vcdbattr/VCDBcable.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBcable (0:0) of VCDBcbgd;

instance  VCDBcable
{
  variable struct VCdbmap      Map[0];
};

override  VCGpAnum;
override  VCGetLayout;

end specification VCDBcable;

