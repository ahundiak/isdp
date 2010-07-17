
/* $Id: VCTermCon.S,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTermCon.S
 *
 * Description:
 *       Class defining crossfile connectors
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTermCon.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/07/14  22:08:42  pinnacle
# Replaced: vcterm/VCTermCon.S for:  by hverstee for cabling
#
# Revision 1.1  1997/03/12  16:25:00  pinnacle
# Created: vcterm/VCTermCon.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCTermCon (0:0) of VCTerm;

instance VCTermCon 
{
  IGRshort             nVCcabCpt;    /*   CB type, cable cpt I'm on   */
};

override VCGetNumberOfCpts;
override VCGetTopology;
override VCGetMatrix;

override ACcheckin_candidate;

override ACgive_structure;
override ACconstruct_feet;

override VCSetInstance;
override VCGetInstance;

/*    dummy the messages that do not make sense here   */

override VCGetEquipId;
override VCGetEquipTag;
override VCTcut;

end specification VCTermCon;

