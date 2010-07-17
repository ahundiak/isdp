
/* $Id: VCCmdPG.S,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPG.S
 *
 * Description:
 *
 *  Specification file for Place Guide command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPG.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/01/03  18:01:36  pinnacle
# Replaced: vccmd/VCCmdPG.S for:  by hverstee for cabling
#
# Revision 1.2  1996/11/25  17:42:42  pinnacle
# Replaced: vccmd/VCCmdPG.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:14:42  pinnacle
# Created: vccmd/VCCmdPG.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *
 * -------------------------------------------------------------------*/


class specification VCCmdPG (0:0) of VCCmdParam;

instance VCCmdPG
{
  IGRint                GdType;

  IGRboolean            bFromDB;
  IGRboolean            bFixXS;

  IGRdouble             dSize1;
  IGRdouble             dSize2;
  IGRint                sShape;

  /*   create linestring on the fly.....  */

  IGRshort              nVert;
  IGRshort              nCurSiz;

  variable
  IGRdouble             dVert[0];
};

override dynamics;

override VCCmdStart;
override VCCmdInit;
override VCCmdInsert;
override VCCmdGetRef;

message  VCCmdPGvt (long *sts);
message  VCCmdPGpl (long *sts);

end specification VCCmdPG;

