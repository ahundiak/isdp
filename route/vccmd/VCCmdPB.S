
 /* $Id: VCCmdPB.S,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPB.S
 *
 * Description:
 *
 *  Specification file for Place Backshell command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPB.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/09/10  17:40:34  pinnacle
# Replaced: vccmd/VCCmdPB.S for:  by apazhani for cabling
#
# Revision 1.1  1997/07/14  22:57:58  pinnacle
# Created: vccmd/VCCmdPB.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      09/10/97          Alwin         Added method dynamics and VCBEvaluate
 *
 * -------------------------------------------------------------------*/


class specification VCCmdPB (0:0) of VCCmdParam;

instance VCCmdPB
{
  /* Templates or parents */
  IGRshort              nVal;      /* offset values                 */
  IGRboolean            bFree;     /* orientation free              */

  /* Its data from forms */
  IGRshort              nVCConn_type;   /* type flags    */
  
  /* Its geom data */
  IGRdouble             dValues[16];
};


override VCCmdStart;
override VCCmdInit;
override VCCmdInsert;
override VCCmdGetRef;
override dynamics;

message VCCmdPosition ( int * sts );

message VCCmdRotate   ( int * sts );

message VCBEvaluate   ( int * sts );

end specification VCCmdPB;

