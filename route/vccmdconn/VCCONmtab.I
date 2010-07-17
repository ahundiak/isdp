
/* $Id: VCCONmtab.I,v 1.3 2002/05/08 15:48:24 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONmtab.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONmtab.I,v $
 *     Revision 1.3  2002/05/08 15:48:24  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.2  2001/02/20 01:10:17  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *     Initial import to CVS
 *
# Revision 1.2  1998/10/20  18:01:02  pinnacle
# Replaced: vccmdconn/VCCONmtab.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/20  09:26:16  pinnacle
# Replaced: vccmdconn/VCCONmtab.I for: TR179800932 by aharihar for route
#
# Revision 1.2  1997/12/09  23:56:08  pinnacle
# Replaced: vccmdconn/VCCONmtab.I for:  by kddinov for route
#
# Revision 1.4  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.3  1997/01/24  00:11:14  pinnacle
# Replaced: vccmdconn/VCCONmtab.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:56:38  pinnacle
# Replaced: vccmdconn/VCCONmtab.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:33:14  pinnacle
# Created: vccmdconn/VCCONmtab.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *	12-97		kdd		Update form with new signal 
 *      Apr 20, 98      Anand		Select state in VCConnect form now
 *					being set in method VCCONactv.
 *					Therefore, any calls to function
 *					FIfld_set_select should be placed
 *					before calling VCCONactv.
 *      10/06/98        Alwin           Modified for TR179801275
 * -------------------------------------------------------------------*/

class implementation VCCmdCON;

#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define MY_DEBUG
*/


/*=======================================================================*/

method VCCONmtab ( int       form_label ;
                   char    * form_ptr ) 
{
  IGRlong       status;
  IGRint        row = 0;
  IGRint        NbRows;
  IGRint        r_pos;
  IGRint        SelFlag = TRUE;
  IGRint        SelOff  = FALSE;
  IGRint        col;
  IGRboolean    bSET = FALSE;
  IGRchar       szLocSig[VC_MAX_SIG_ID];
  IGRchar       szLocMark[VC_MAX_MARK_ID];
  struct VCpos  *Pos;
  int		i;

  SetProc( Md VCCONmtab ); Begin 

  FIfld_get_active_row (form_ptr, VC_CONGDG_MTAB, &row, &NbRows);
  FImcf_get_active_col (form_ptr, VC_CONGDG_MTAB, &col, &r_pos);

  if (row >= me->nNumConTab) goto DONE;

  switch (col)
  {
    case VC_CONCOL_CAB1:
    case VC_CONCOL_LEAD1:
    case VC_CONCOL_MPOS1:
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_CAB2, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_LEAD2, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_MPOS2, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_CAB1, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_LEAD1, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_MPOS1, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_MMOD, SelOff);

      status =
      om$send (msg = message VCCmdCON.VCCONactv 
                              (form_ptr, row, VC_CONCOL_MPOS1, me->nActCnd),
          targetid = my_id);
      goto CCCC;

    case VC_CONCOL_CAB2:
    case VC_CONCOL_LEAD2:
    case VC_CONCOL_MPOS2:
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_CAB2, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_LEAD2, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_MPOS2, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_CAB1, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_LEAD1, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_MPOS1, SelOff);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, row, VC_CONCOL_MMOD, SelOff);

      status =
      om$send (msg = message VCCmdCON.VCCONactv 
                              (form_ptr, row, VC_CONCOL_MPOS2, me->nActCnd),
          targetid = my_id);

      CCCC:

/* The FIfld_set_select calls were originally placed here - after the CCCC
   label and before the following if (me->Product == VC_PROD_FO) condition.
   They were shifted to precede call to method VCCONactv, where the select
   states in various fields in form VCConnect were set. Anand for TR179800932
*/
      /* revised this condition. Alwin for TR179801275 */
      if( ( me->Product == VC_PROD_FO ) && ( me->nActPos >= 0 ) )
      {

	if( me->nActCnd >= 0 )
	    sprintf (me->szMSG, "Select connector");

        status =
        om$send (msg = message VCCmdCON.VCCONlst
                            (bSET, form_label, form_ptr),
            targetid = my_id);
        as$status();
      }
      break;

    case VC_CONCOL_SIG1:

      FIfld_get_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG1,VC_MAX_SIG_ID,
                      (unsigned char *)szLocSig, &SelFlag, &r_pos);

#ifdef MY_DEBUG
      printf (" form getsignal %s %d\n",szLocSig, row);
#endif

      if ((me->ConTab1[row].GR.osnum != me->WRT_os) &&
          (me->RefId.osnum           != me->WRT_os))
      {
        strcpy (me->szMSG,
                 "Cannot change signal name in reference file");
        FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG1,
                        me->ConSig1[row].sig, SelOff);
      }
      else {
      /*C   propagate change in signal    */
/* KDD 12-97 Propagate this signal inside the whole form 
*      if (strcmp (me->ConSig1[row].sig, szLocSig) != 0)
*      {
*        strcpy (me->ConSig1[row].sig, szLocSig);
*        me->ConSig1[row].bSWsig = TRUE;
*      }
*
*      if (me->PosTab[row].nTOPO == VC_TOPO_TIC)
*      {
*        me->ConSig2[row] = me->ConSig1[row];
*        FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG2,
*                         me->ConSig2[row].sig, SelOff);
*      }
*/

         Pos = &me->PosTab[ row ].pDef;
 
         for ( i = 0; i < me->nNumConTab; i++ ) {
             if ( VC_posequal(&me->PosTab[ i ].pDef, Pos) ) {
                  strcpy (me->ConSig1[ i ].sig, szLocSig);
                  me->ConSig1[ i ].bSWsig = TRUE;

	          if ( me->PosTab[row].nTOPO == VC_TOPO_TIC) { 
		     strcpy (me->ConSig2[ i ].sig, szLocSig);
		     me->ConSig2[ i ].bSWsig = TRUE;
	          }
             }
         }

	 me->bRedisplay = TRUE;
      }

      break;

    case VC_CONCOL_SIG2:

      FIfld_get_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG2,VC_MAX_SIG_ID,
                      (unsigned char *)szLocSig, &SelFlag, &r_pos);

#ifdef MY_DEBUG
      printf (" form getsignal %s %d\n",szLocSig, row);
#endif

      if ((me->ConTab2[row].GR.osnum != me->WRT_os) &&
          (me->RefId.osnum           != me->WRT_os))
      {
        strcpy (me->szMSG,
                 "Cannot change signal name in reference file");
        FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG2,
                         me->ConSig2[row].sig, SelOff);
      }
      else { 
         /*C   propagate change in signal    */
/* KDD 12-97 Propagate this signal inside the whole form 
*         if (strcmp (me->ConSig2[row].sig, szLocSig) != 0) {
*           strcpy (me->ConSig2[row].sig, szLocSig);
*           me->ConSig2[row].bSWsig = TRUE;
*         }
*
*         if (me->PosTab[row].nTOPO == VC_TOPO_TIC) {
*           me->ConSig1[row] = me->ConSig2[row];
*           FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG1,
*                            me->ConSig1[row].sig, SelOff);
*         }
*/

         Pos = &me->PosTab[ row ].pAlt;
 
         for ( i = 0; i < me->nNumConTab; i++ ) {
             if ( VC_posequal(&me->PosTab[ i ].pAlt, Pos) ) {

                  strcpy (me->ConSig2[ i ].sig, szLocSig);
                  me->ConSig2[ i ].bSWsig = TRUE;
 
                  if ( me->PosTab[row].nTOPO == VC_TOPO_TIC) { 
                     strcpy (me->ConSig1[ i ].sig, szLocSig);
                     me->ConSig1[ i ].bSWsig = TRUE;
                  }
             }
         }

	 me->bRedisplay = TRUE;
      }

      break;


    case VC_CONCOL_MARK1:

      FIfld_get_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_MARK1,VC_MAX_MARK_ID,
                      (unsigned char *)szLocMark, &SelFlag, &r_pos);

#ifdef MY_DEBUG
      printf (" form getsignal %s %d\n",szLocSig, row);
#endif

      if ((me->ConTab1[row].GR.osnum != me->WRT_os) &&
          (me->RefId.osnum           != me->WRT_os))
      {
        strcpy (me->szMSG,
                 "Cannot change marker name in reference file");
        FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_MARK1,
                        me->ConSig1[row].marker, SelOff);
      }
      else {
      /*C   propagate change in signal    */
/* KDD 12-97 Propagate this signal inside the whole form 
*      if (strcmp (me->ConSig1[row].sig, szLocSig) != 0)
*      {
*        strcpy (me->ConSig1[row].sig, szLocSig);
*        me->ConSig1[row].bSWsig = TRUE;
*      }
*
*      if (me->PosTab[row].nTOPO == VC_TOPO_TIC)
*      {
*        me->ConSig2[row] = me->ConSig1[row];
*        FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG2,
*                         me->ConSig2[row].sig, SelOff);
*      }
*/

         Pos = &me->PosTab[ row ].pDef;
 
         for ( i = 0; i < me->nNumConTab; i++ ) {
             if ( VC_posequal(&me->PosTab[ i ].pDef, Pos) ) {
                  strcpy (me->ConSig1[ i ].marker, szLocMark);
                  me->ConSig1[ i ].bSWsig = TRUE;

	          if ( me->PosTab[row].nTOPO == VC_TOPO_TIC) { 
		     strcpy (me->ConSig2[ i ].marker, szLocMark);
		     me->ConSig2[ i ].bSWsig = TRUE;
	          }
             }
         }

	 me->bRedisplay = TRUE;
      }

      break;

    case VC_CONCOL_MARK2:

      FIfld_get_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_MARK2,VC_MAX_MARK_ID,
                      (unsigned char *)szLocMark, &SelFlag, &r_pos);

#ifdef MY_DEBUG
      printf (" form getsignal %s %d\n",szLocSig, row);
#endif

      if ((me->ConTab2[row].GR.osnum != me->WRT_os) &&
          (me->RefId.osnum           != me->WRT_os))
      {
        strcpy (me->szMSG,
                 "Cannot change marker name in reference file");
        FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_MARK2,
                         me->ConSig2[row].marker, SelOff);
      }
      else { 
         /*C   propagate change in signal    */
/* KDD 12-97 Propagate this signal inside the whole form 
*         if (strcmp (me->ConSig2[row].sig, szLocSig) != 0) {
*           strcpy (me->ConSig2[row].sig, szLocSig);
*           me->ConSig2[row].bSWsig = TRUE;
*         }
*
*         if (me->PosTab[row].nTOPO == VC_TOPO_TIC) {
*           me->ConSig1[row] = me->ConSig2[row];
*           FIfld_set_text (form_ptr,VC_CONGDG_MTAB,row,VC_CONCOL_SIG1,
*                            me->ConSig1[row].sig, SelOff);
*         }
*/

         Pos = &me->PosTab[ row ].pAlt;
 
         for ( i = 0; i < me->nNumConTab; i++ ) {
             if ( VC_posequal(&me->PosTab[ i ].pAlt, Pos) ) {

                  strcpy (me->ConSig2[ i ].marker, szLocMark);
                  me->ConSig2[ i ].bSWsig = TRUE;
 
                  if ( me->PosTab[row].nTOPO == VC_TOPO_TIC) { 
                     strcpy (me->ConSig1[ i ].marker, szLocMark);
                     me->ConSig1[ i ].bSWsig = TRUE;
                  }
             }
         }

	 me->bRedisplay = TRUE;
      }

      break;

    default:
      break;
  }

  DONE:
  End
  return OM_S_SUCCESS;
}

end implementation VCCmdCON;
