
/* $Id: VCCsignal.I,v 1.3 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCCsignal.I
 *
 * Description:
 *   This file contains the signal name methods for cables
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCsignal.I,v $
 *        Revision 1.3  2002/05/08 15:48:23  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:09:13  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  19:49:40  pinnacle
# Replaced: vccable/VCCsignal.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/08/11  21:58:56  pinnacle
# Replaced: vccable/VCCsignal.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/22  15:01:06  pinnacle
# Replaced: vccable/VCCsignal.I for:  by hverstee for cabling
#
# Revision 1.3  1997/07/14  22:32:44  pinnacle
# Replaced: vccable/VCCsignal.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/06  22:56:08  pinnacle
# Replaced: vccable/VCCsignal.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:50:02  pinnacle
# Created: vccable/VCCsignal.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
*/
 
#include "vrdbgmacros.h"

method  VCPutSignal( IGRlong		*msg;
		     struct VCpos	*ConId;
                     IGRchar		*sigid )
{
    IGRshort       nIndex;
    IGRshort       nn;

    SetProc(VCCable_VCPutSignal ); Begin;

    /* Just for loop on me->Connect_Data and set the signal! */

    nn = om$dimension_of(varray = me->Connect_Data);

    for( nIndex=0 ; nIndex<nn ; nIndex++ )
    {
	if(!strcmp(me->Connect_Data[nIndex].LeadNam,ConId->Conn.Cable.szLeadId))
	{
	    strcpy(me->Connect_Data[nIndex].SigNam,sigid);
	    *msg = MSSUCC;
	    End;
	    return (OM_S_SUCCESS);
	}
    }

    *msg = MSFAIL;

    End;
    return (OM_E_ABORT);
}


method  VCGetSignal( IGRlong		*msg;
		     struct VCpos	*ConId;
                     IGRchar		*sigid )
{
    IGRshort       nIndex;
    IGRshort       nn;

    SetProc(VCCable_VCGetSignal ); Begin;

    /* Just for loop on me->Connect_Data and get the signal! */

    nn = om$dimension_of(varray = me->Connect_Data);

    for( nIndex=0 ; nIndex<nn ; nIndex++ )
    {
	if(!strcmp(me->Connect_Data[nIndex].LeadNam,ConId->Conn.Cable.szLeadId))
	{
	    strcpy(sigid,me->Connect_Data[nIndex].SigNam);
	    *msg = MSSUCC;
	    End;
	    return (OM_S_SUCCESS);
	}
    }

    *msg = MSFAIL;

    End;
    return (OM_E_ABORT);
}


end implementation VCCable;

