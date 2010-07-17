
/* $Id: VCCONctab.I,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONctab.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONctab.I,v $
 *     Revision 1.2  2002/05/08 15:48:24  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:29  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.3  1997/01/24  00:10:12  pinnacle
# Replaced: vccmdconn/VCCONctab.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:55:20  pinnacle
# Replaced: vccmdconn/VCCONctab.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:31:40  pinnacle
# Created: vccmdconn/VCCONctab.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VCCmdCON;

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define MY_DEBUG
*/


/*=======================================================================*/

method VCCONctab ( int       form_label ;
                   char    * form_ptr )  
{
  IGRlong       status;
  IGRint        row;
  IGRint        col;
  IGRint        NbRows;
  IGRint        NbCols;
  IGRint        r_pos;
  IGRint        SelFlag = TRUE;
  IGRint        SelOff  = FALSE;
  IGRchar       szLocSig[VC_MAX_SIG_ID];
  IGRchar       szLocMark[VC_MAX_MARK_ID];

  FIfld_get_active_row (form_ptr, VC_CONGDG_CNDLIST, &row, &NbRows);
  FImcf_get_active_col (form_ptr, VC_CONGDG_CNDLIST, &col, &NbCols);

  if (row >= me->nCndNum) goto DONE;

  FIfld_set_select (form_ptr, VC_CONGDG_CNDLIST, row, VC_CNDCOL_LEAD, SelOff);
  FIfld_set_select (form_ptr, VC_CONGDG_CNDLIST, row, VC_CNDCOL_CAB, SelOff);

  if ((col != VC_CNDCOL_SIG) && (col != VC_CNDCOL_MARK))
  {
    status =
    om$send (msg = message VCCmdCON.VCCONactv
                          (form_ptr, me->nActPos, me->nActSide, row),
        targetid = my_id);
  }
  else
  {
    FIfld_get_text (form_ptr,VC_CONGDG_CNDLIST,row,VC_CNDCOL_SIG,
		    VC_MAX_SIG_ID, (unsigned char *)szLocSig, &SelFlag,
		    &r_pos);
    FIfld_get_text (form_ptr,VC_CONGDG_CNDLIST,row,VC_CNDCOL_MARK,
		    VC_MAX_MARK_ID, (unsigned char *)szLocMark, &SelFlag,
		    &r_pos);

#ifdef MY_DEBUG
    printf (" form getsignal %s %d\n",szLocSig, row);
#endif

    if (me->CndTab[row].GR.osnum != me->WRT_os)
    {
      strcpy (me->szMSG,
               "Cannot change signal/marker in reference file");
      FIfld_set_text (form_ptr,VC_CONGDG_CNDLIST,row, VC_CNDCOL_SIG,
                      me->CndSig[row].sig, SelOff);
      FIfld_set_text (form_ptr,VC_CONGDG_CNDLIST,row, VC_CNDCOL_MARK,
                      me->CndSig[row].marker, SelOff);
    }
    else
    /*C   propagate change in signal    */
    {
      if (strcmp (me->CndSig[row].sig, szLocSig) != 0)
      {
        strcpy (me->CndSig[row].sig, szLocSig);
        me->CndSig[row].bSWsig = TRUE;
      }
      if (strcmp (me->CndSig[row].marker, szLocMark) != 0)
      {
        strcpy (me->CndSig[row].marker, szLocMark);
      }
    }
  }

  DONE:
  return OM_S_SUCCESS;
}

end implementation VCCmdCON;
