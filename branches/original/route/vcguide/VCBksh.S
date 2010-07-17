
/* $Id: VCBksh.S,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide/VCBksh.S
 *
 * Description:
 *
 *      Implementation of Terminal Backshell
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCBksh.S,v $
 *      Revision 1.2  2002/05/08 15:48:24  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/02/24  23:06:30  pinnacle
# Replaced: vcguide/VCBksh.S for:  by kddinov for route
#
# Revision 1.2  1997/12/08  09:36:28  pinnacle
# Replaced: vcguide/VCBksh.S for:  by apazhani for route
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/10/24  12:41:14  pinnacle
# Replaced: vcguide/VCBksh.S for:  by apazhani for cabling
#
# Revision 1.1  1997/07/14  22:25:56  pinnacle
# Created: vcguide/VCBksh.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *      10/24/97    Alwin       Overridden the method ACgive_structure and
 *                              ACcheckin_candidate method.
 *      12/08/97    Alwin       Overridden the method NDdelete
 *
 *************************************************************************/

class specification VCBksh (0:0) of VCMac;

instance VCBksh
{
};

/*   OVERRIDES           */

override VCGetEquipId;

override NDplace;

override GRget_siblings;

override VCBaseMat;
override VCTransMat;

override VCGetNumberOfCpts;

override VCGetModel;
override VCSetTagNo;
override GRgetobjinfo;

/* added by alwin - for TR179701824 */
override ACcheckin_candidate;
override ACgive_structure;
/* added by alwin */

override NDdelete;

override VDgetObjDef;

/* methods for using the me->Data backdoor provided in VCRoot */
override      VCSetDataVLA, VCGetDataVLA, VCDataTypeSize;

end specification VCBksh;

