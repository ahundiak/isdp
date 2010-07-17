
 /* $Id: VCCmdPT.S,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPT.S
 *
 * Description:
 *
 *  Specification file for Place Terminal commands
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPT.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/09/10  17:41:22  pinnacle
# Replaced: vccmd/VCCmdPT.S for:  by apazhani for cabling
#
# Revision 1.4  1997/04/28  22:25:16  pinnacle
# Replaced: vccmd/VCCmdPT.S for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  21:42:40  pinnacle
# Replaced: vccmd/VCCmdPT.S for:  by hverstee for cabling
#
# Revision 1.2  1997/01/03  18:01:18  pinnacle
# Replaced: vccmd/VCCmdPT.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:15:52  pinnacle
# Created: vccmd/VCCmdPT.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      09/10/97          Alwin         Overridden dynamics and added 
 *                                      VCTEvaluate.
 *
 * -------------------------------------------------------------------*/


class specification VCCmdPT (0:0) of VCCmdParam;

instance VCCmdPT
{
  /* Templates or parents */
  IGRshort              nCpt;      /* parent's connect point for CB */
  IGRshort              nVal;      /* offset values                 */
  IGRboolean            bFree;     /* orientation free              */

  /* Its data from forms */
  IGRshort              nVCConn_type;   /* terminal type     */
  
  /* Its geom data */
  IGRdouble             dValues[16];
};


override VCCmdStart;
override VCCmdInit;
override VCCmdInsert;
override VCCmdGetRef;
override dynamics;

message VCCmdCbInsert ( int * sts );

message VCCmdPosition ( int * sts );

message VCCmdRotate   ( int * sts );

message VCCmdNulPar   ( int * sts );

message VCTEvaluate   ( int * sts );

end specification VCCmdPT;

