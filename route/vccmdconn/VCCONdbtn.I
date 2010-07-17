
/* $Id: VCCONdbtn.I,v 1.2 2001/02/20 01:10:09 build Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONdbtn.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONdbtn.I,v $
 *     Revision 1.2  2001/02/20 01:10:09  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:29  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:08:28  pinnacle
# Replaced: vccmdconn/VCCONdbtn.I for:  by r250_int for route
#
# Revision 1.5  1997/11/21  00:12:56  pinnacle
# Replaced: vccmdconn/VCCONdbtn.I for:  by kddinov for cabling
#
# Revision 1.4  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.3  1997/01/24  00:10:28  pinnacle
# Replaced: vccmdconn/VCCONdbtn.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:55:34  pinnacle
# Replaced: vccmdconn/VCCONdbtn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:31:54  pinnacle
# Created: vccmdconn/VCCONdbtn.I by hverstee for cabling
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
#define MY_DEBUG 1
#define vdsDEBUG 1
*/

#include "vrdbgmacros.h"
#include "vdreporterr.h"


/*=======================================================================*/

method VCCONdbtn ( int       form_label ;
                   char    * form_ptr )  
{
  IGRint        NbRows;
  IGRint        SelFlag = FALSE;
  IGRint        i;
  IGRint        status;

  /*C   Add to candidates table       */
  me->nCndNum++;
  NbRows = me->nCndNum;

  FIfld_set_num_rows (form_ptr, VC_CONGDG_CNDLIST, NbRows);
  NbRows--;   /*   go to index    */
  i = 0;

  if (me->bICB)
  {
    if (me->nActSide == VC_CONCOL_MPOS1)
    {
      me->CndTab[NbRows] = me->ConTab1[me->nActPos];
      me->CndSig[NbRows] = me->ConSig1[me->nActPos];
      me->ConTab1[me->nActPos] = me->INITstr;
      me->ConTab1[me->nActPos].nCstat = VCFO_A_REMOVE;

      FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_SIG1,
                      me->ConSig1[me->nActPos].sig , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_CAB1,
                      me->ConTab1[me->nActPos].Ctag , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_LEAD1,
                      me->ConTab1[me->nActPos].ps.Conn.Cable.szLeadId,SelFlag);
    }
    else
    {
      me->CndTab[NbRows] = me->ConTab2[me->nActPos];
      me->CndSig[NbRows] = me->ConSig2[me->nActPos];
      me->ConTab2[me->nActPos] = me->INITstr;
      me->ConTab2[me->nActPos].nCstat = VCFO_A_REMOVE;

      FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_SIG2,
                      me->ConSig2[me->nActPos].sig , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_CAB2,
                      me->ConTab2[me->nActPos].Ctag , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_LEAD2,
                      me->ConTab2[me->nActPos].ps.Conn.Cable.szLeadId,SelFlag);
      i = 1;
    }
  }
  else
  {
      me->CndTab[NbRows] = me->ConTab1[me->nActPos];
      me->CndSig[NbRows] = me->ConSig1[me->nActPos];
      me->ConTab1[me->nActPos] = me->INITstr;
      me->ConTab1[me->nActPos].nCstat = VCFO_A_REMOVE;

      FIfld_set_text (form_ptr, VC_CONGDG_STAB, me->nActPos, VC_CONCOL_SIG,
                      me->ConSig1[me->nActPos].sig , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_STAB, me->nActPos, VC_CONCOL_CAB,
                      me->ConTab1[me->nActPos].Ctag , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_STAB, me->nActPos, VC_CONCOL_LEAD,
                      me->ConTab1[me->nActPos].ps.Conn.Cable.szLeadId,SelFlag);
  }

  FIfld_set_text (form_ptr, VC_CONGDG_CNDLIST, NbRows, VC_CNDCOL_LEAD,
                  me->CndTab[NbRows].ps.Conn.Cable.szLeadId , SelFlag);
  FIfld_set_text (form_ptr, VC_CONGDG_CNDLIST, NbRows, VC_CNDCOL_CAB,
                  me->CndTab[NbRows].Ctag , SelFlag);
  FIfld_set_text (form_ptr, VC_CONGDG_CNDLIST, NbRows, VC_CNDCOL_SIG,
                  me->CndSig[NbRows].sig , SelFlag);
  
  /*---- KDD 11-97 Decrease the number of connections for that pin ----*/
{
    struct VCpos     	*Locstr;
    IGRlong		retmsg;
    int			index = -1, count;
    char		text[256];
 
    if ((me->bICB) && (me->nActSide == VC_CONCOL_MPOS2))
      Locstr = &me->PosTab[me->nActPos].pAlt;
    else
      Locstr = &me->PosTab[me->nActPos].pDef;
 
    status = om$send (msg = message VCCmdCON.VCGetNumOfConnections (
                                        &retmsg,
                                        &Locstr->Conn.Term,
                                        &index,
                                        &count),
                 targetid = my_id);
 
    if ( index == -1) {
        sprintf( text, "Pin <%s,%s> not found", Locstr->Conn.Term.szModId,
                                                Locstr->Conn.Term.szPosId);
        vd$report_error( error = text, mode = VD_UNIX_WINDOW);
        strcpy (me->szMSG, text);
	goto wrapup;
    }
 
    me->PinConnect[ index ].NumConnect -= 1;
}


  status =
  om$send (msg = message VCCmdCON.VCCONactv (form_ptr, -1, -1, -1),
      targetid = my_id);

  me->nCurC_S = VCFO_T_NONE;

wrapup:

  return OM_S_SUCCESS;
}

end implementation VCCmdCON;
