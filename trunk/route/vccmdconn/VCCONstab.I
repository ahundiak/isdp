
/* $Id: VCCONstab.I,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONstab.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONstab.I,v $
 *     Revision 1.2  2002/05/08 15:48:24  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *     Initial import to CVS
 *
# Revision 1.2  1998/10/20  18:01:12  pinnacle
# Replaced: vccmdconn/VCCONstab.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/09  23:55:30  pinnacle
# Replaced: vccmdconn/VCCONstab.I for:  by kddinov for route
#
# Revision 1.4  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.3  1997/01/24  00:11:48  pinnacle
# Replaced: vccmdconn/VCCONstab.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:57:10  pinnacle
# Replaced: vccmdconn/VCCONstab.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:33:42  pinnacle
# Created: vccmdconn/VCCONstab.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *	12-97		kdd	propagate signal inside the form. 
 *      10/06/98        Alwin   Modified for TR179801275.
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

method VCCONstab (int       form_label ;
                  char    * form_ptr )  
{
  IGRlong       status;
  IGRint        row = 0;
  IGRint        col = 0;
  IGRint        NbRows;
  IGRint        NbCols;
  IGRint        r_pos;
  IGRint        SelFlag = TRUE;
  IGRint        SelOff  = FALSE;
  IGRchar       szLocSig[VC_MAX_SIG_ID];
  IGRchar       szLocMark[VC_MAX_MARK_ID];
  struct VCpos	*Pos; 
  int           i;


  FIfld_get_active_row (form_ptr, VC_CONGDG_STAB, &row, &NbRows);
  FImcf_get_active_col (form_ptr, VC_CONGDG_STAB, &col, &NbCols);

#ifdef MY_DEBUG
  printf (" tabin, acive = %d %d\n",row,col);
#endif

  if (row >= me->nNumConTab) goto DONE;

  switch (col)
  {
    case VC_CONCOL_SMOD:
    case VC_CONCOL_SPOS:
    case VC_CONCOL_LEAD:
    case VC_CONCOL_CAB:
      FIfld_set_select (form_ptr, VC_CONGDG_STAB, row, VC_CONCOL_SMOD, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_STAB, row, VC_CONCOL_SPOS, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_STAB, row, VC_CONCOL_LEAD, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_STAB, row, VC_CONCOL_CAB, SelOff);

      status =
      om$send (msg = message VCCmdCON.VCCONactv
                              (form_ptr, row, VC_CONCOL_SPOS, me->nActCnd),
          targetid = my_id);

      /* revised this condition and added the second line. Alwin */
      if( (me->Product == VC_PROD_FO) && ( me->nActPos >= 0 ) )
      {
        IGRboolean    bSET = FALSE;

	if( me->nActCnd >= 0 )
	    sprintf (me->szMSG, "Select connector");

        status =
        om$send (msg = message VCCmdCON.VCCONlst
                            (bSET, form_label, form_ptr),
            targetid = my_id);
        as$status();
      }
      break;

    case VC_CONCOL_MARK:
      FIfld_get_text (form_ptr,VC_CONGDG_STAB,row,VC_CONCOL_MARK, VC_MAX_MARK_ID,
                      (unsigned char *)szLocMark, &SelFlag, &r_pos);

      if ((me->ConTab1[row].GR.osnum != me->WRT_os) &&
          (me->RefId.osnum           != me->WRT_os))
      {
        strcpy (me->szMSG, "Cannot change marker name in reference file");
        FIfld_set_text (form_ptr,VC_CONGDG_STAB,row, VC_CONCOL_MARK,
                         me->ConSig1[row].marker, SelOff);
      }
      else { 
         /*C   propagate change in signal    */
/* KDD 12-97 Propagate this signal inside the whole form 
*         if (strcmp (me->ConSig1[row].sig, szLocSig) != 0) {
*            strcpy (me->ConSig1[row].sig, szLocSig);
*            me->ConSig1[row].bSWsig = TRUE;
*         }
*/

         Pos = &me->PosTab[ row ].pDef;

         for ( i = 0; i < me->nNumConTab; i++ ) { 
	     if ( VC_posequal(&me->PosTab[ i ].pDef, Pos) ) {
	        strcpy (me->ConSig1[ i ].marker, szLocMark);
                me->ConSig1[ i ].bSWsig = TRUE;
	     }
         }

         me->bRedisplay = TRUE;
      }

      break;

    case VC_CONCOL_SIG:
 
      FIfld_get_text (form_ptr,VC_CONGDG_STAB,row,VC_CONCOL_SIG, VC_MAX_SIG_ID,
                      (unsigned char *)szLocSig, &SelFlag, &r_pos);

#ifdef MY_DEBUG
      printf (" form getsignal %s %d\n",szLocSig, row);
#endif

      if ((me->ConTab1[row].GR.osnum != me->WRT_os) &&
          (me->RefId.osnum           != me->WRT_os))
      {
        strcpy (me->szMSG, "Cannot change signal name in reference file");
        FIfld_set_text (form_ptr,VC_CONGDG_STAB,row, VC_CONCOL_SIG,
                         me->ConSig1[row].sig, SelOff);
      }
      else { 
         /*C   propagate change in signal    */
/* KDD 12-97 Propagate this signal inside the whole form 
*         if (strcmp (me->ConSig1[row].sig, szLocSig) != 0) {
*            strcpy (me->ConSig1[row].sig, szLocSig);
*            me->ConSig1[row].bSWsig = TRUE;
*         }
*/

         Pos = &me->PosTab[ row ].pDef;

         for ( i = 0; i < me->nNumConTab; i++ ) { 

	     if ( VC_posequal(&me->PosTab[ i ].pDef, Pos) ) {
	        strcpy (me->ConSig1[ i ].sig, szLocSig);
                me->ConSig1[ i ].bSWsig = TRUE;
	     }
         }

         me->bRedisplay = TRUE;
      }

      break;

    default:
      break;
  }

  DONE:
  return OM_S_SUCCESS;
}

end implementation VCCmdCON;
