/* $Id: VCCONcbtn.I,v 1.2 2001/02/20 01:10:04 build Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONcbtn.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONcbtn.I,v $
 *     Revision 1.2  2001/02/20 01:10:04  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:29  cvs
 *     Initial import to CVS
 *
# Revision 1.3  1999/02/10  21:33:18  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by lawaddel for route
#
# Revision 1.2  1998/10/20  15:13:04  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/12/09  23:53:24  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by kddinov for route
#
# Revision 1.9  1997/12/06  23:31:18  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by kddinov for cabling
#
# Revision 1.8  1997/11/21  00:11:30  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by kddinov for cabling
#
# Revision 1.7  1997/11/17  23:14:50  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by kddinov for cabling
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.5  1997/01/24  00:09:56  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by hverstee for cabling
#
# Revision 1.4  1996/09/18  18:55:56  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by hverstee for cabling
#
# Revision 1.3  1996/08/30  21:22:06  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:55:04  pinnacle
# Replaced: vccmdconn/VCCONcbtn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:31:22  pinnacle
# Created: vccmdconn/VCCONcbtn.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *      08/21/96          HV            New
 *	11-97		KDD		Limit number of connectiond to DB input.
 *	12-97		KDD	One sided terminals: signal comes from cable. 
 *				Two sided terminals: signal comes from terminal
 *	10-98		Alwin	Intialized and added DEBUG statements
 *      2/10/99         law     TR179802033-corrected posting for splices
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


method VCCONcbtn ( int       form_label ;
                   char    * form_ptr )  
{
  IGRlong       status, retmsg;
  IGRint        SelFlag = FALSE;
  IGRint        i;
  IGRshort      locAct;
  IGRboolean    bSET = TRUE;
  IGRboolean    bInsert= FALSE;
  IGRchar       szSig[VC_MAX_SIG_ID];
  IGRboolean    bSWsav;

  int		count, index;
  char		text[256];
  IGRchar   	szLocSig[VC_MAX_SIG_ID]={""};
  IGRchar   	szCndSig[VC_MAX_SIG_ID]={""},
		*p_Sig;


SetProc(VCCONcbtn); Begin;

  locAct = me->nActPos;
__DBGpr_int("locAct index",locAct);
  /*A   check signal names if requested */

  if (me->bSigChk)
  {
    if ((me->bICB) && (me->nActSide == VC_CONCOL_MPOS2))
      strcpy (szLocSig, me->ConSig2[me->nActPos].sig);
    else
      strcpy (szLocSig, me->ConSig1[me->nActPos].sig);

    strcpy (szCndSig, me->CndSig[me->nActCnd].sig);

    if ((!VC_EMPTYSTR(szLocSig)) && (!VC_EMPTYSTR(szCndSig)) &&
        (strcmp (szLocSig, szCndSig) != 0))
    {
      strcpy (me->szMSG, "Signal names mismatch, Select other Position");
      goto DONE;
    }

__DBGpr_str("szCndSig", szCndSig);
__DBGpr_str("szLocSig", szLocSig);
  }

  /*---- KDD 11-97 Check the number of connections CR179701619 ----*/
{
    struct VCpos     *Locstr;
 
    if ((me->bICB) && (me->nActSide == VC_CONCOL_MPOS2))
      Locstr = &me->PosTab[me->nActPos].pAlt;
    else
      Locstr = &me->PosTab[me->nActPos].pDef;

    index = -1;
    count = 0; //Alwin - intialized

    __DBGpr_com( " Calling VCGetNumOfConnections ... " );
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
        goto DONE;
    }
    else if ( count >= me->PinConnect[ index ].DBlimit ) {
              sprintf( text, "Pin <%s,%s> is connected %d (DB max is %d)",
                                me->PinConnect[ index ].PinId.szModId,
                                me->PinConnect[ index ].PinId.szPosId,
                                (int) count, me->PinConnect[ index ].DBlimit);
 
              vd$report_error( error = text, mode = VD_UNIX_WINDOW);
	      strcpy (me->szMSG, text);
              goto DONE;
    }

    me->PinConnect[ index ].NumConnect += 1; 
}


  if ((me->bICB) && (me->nActSide == VC_CONCOL_MPOS2)) 
         bInsert = (me->ConTab2[me->nActPos].GR.objid != NULL_OBJID);
  else 
     bInsert = (me->ConTab1[me->nActPos].GR.objid != NULL_OBJID);


  if (bInsert) {
#ifdef MY_DEBUG
    printf (" multiple connect, insert line at %d\n",locAct);
#endif
    status =
    om$send (msg = message VCCmdCON.VCCONinsert (locAct),
        targetid = my_id);

    locAct++;
  }

/*-- KDD 12-97. Signal comes from cable by default (if any). --*/
/*--            For two sided terms, signal comes from terminal (if any). --*/
  p_Sig = me->CndSig[me->nActCnd].sig;

  if ( me->bICB) {
    if((me->nActSide==VC_CONCOL_MPOS2)&&(!VC_EMPTYSTR(me->ConSig2[locAct].sig)))
	p_Sig = me->ConSig2[locAct].sig;

    if((me->nActSide==VC_CONCOL_MPOS1)&&(!VC_EMPTYSTR(me->ConSig1[locAct].sig)))
        p_Sig = me->ConSig1[locAct].sig;
  }
  else if ( VC_EMPTYSTR(me->CndSig[me->nActCnd].sig) )
     	p_Sig = me->ConSig1[locAct].sig; 
 

  /*C   Add to positions table       */

#ifdef MY_DEBUG
printf("Candidate %d = [%s, %s], end %d", 
	me->nActCnd,
	me->CndTab[me->nActCnd].Ctag,
	me->CndTab[me->nActCnd].ps.Conn.Cable.szLeadId,
	me->CndTab[me->nActCnd].ps.Conn.Cable.nCpt); 
#endif

  /*A   Move candidate to form position    */
  if ((me->bICB) && (me->nActSide == VC_CONCOL_MPOS2))
  {
    /*-- KDD 12-97 update tab2 and candidate signals --*/
    strcpy(me->ConSig2[locAct].sig,      p_Sig);
    strcpy(me->CndSig [me->nActCnd].sig, p_Sig);

    strcpy (szSig, me->ConSig2[locAct].sig);
    bSWsav = me->ConSig2[locAct].bSWsig;

    me->ConTab2[locAct]        = me->CndTab[me->nActCnd];
    me->ConSig2[locAct]        = me->CndSig[me->nActCnd];
    me->ConTab2[locAct].nCstat = VCFO_A_AUTOASSIGN;
    me->ConTab2[locAct].nCtype = VCFO_T_NONE;
/*    VC_INITSTR (me->ConTab2[locAct].CON); Deleted for TR179802033 */

    if ((bSWsav) || (!VC_EMPTYSTR(szSig)))
    {
      strcpy (me->ConSig2[locAct].sig, szSig);
      me->ConSig2[locAct].bSWsig = bSWsav;
    }

    if (me->PosTab[locAct].nTOPO == VC_TOPO_TIC)
      me->ConSig1[locAct] = me->ConSig2[locAct];

#ifdef MY_DEBUG
printf("ConTab2   %d = [%s, %s], end %d", 
        locAct,
        me->ConTab2[locAct].Ctag,
        me->ConTab2[locAct].ps.Conn.Cable.szLeadId,
        me->ConTab2[locAct].ps.Conn.Cable.nCpt); 
#endif
  }
  else
  {
    /*-- KDD 12-97 update tab1 and candidate signals --*/
    strcpy(me->ConSig1[locAct].sig,      p_Sig);
    strcpy(me->CndSig [me->nActCnd].sig, p_Sig);

    strcpy (szSig, me->ConSig1[locAct].sig);
    bSWsav = me->ConSig1[locAct].bSWsig;

    me->ConTab1[locAct]        = me->CndTab[me->nActCnd];
    me->ConSig1[locAct]        = me->CndSig[me->nActCnd];
    me->ConTab1[locAct].nCstat = VCFO_A_AUTOASSIGN;
    me->ConTab1[locAct].nCtype = VCFO_T_NONE;
/*    VC_INITSTR (me->ConTab1[locAct].CON); Deleted for TR179802033 */

    if ((bSWsav) || (!VC_EMPTYSTR(szSig)))
    {
      strcpy (me->ConSig1[locAct].sig, szSig);
      me->ConSig1[locAct].bSWsig = bSWsav;
    }

    if (me->PosTab[locAct].nTOPO == VC_TOPO_TIC)
      me->ConSig2[locAct] = me->ConSig1[locAct];

#ifdef MY_DEBUG
printf("ConTab1   %d = [%s, %s], end %d", 
        locAct,
        me->ConTab1[locAct].Ctag,
        me->ConTab1[locAct].ps.Conn.Cable.szLeadId,
        me->ConTab1[locAct].ps.Conn.Cable.nCpt); 
#endif
  }

  /*A   auto assign connector/splice ..... MESSAGE    */

  if (me->Product == VC_PROD_FO)
  {
    IGRint     isav;

    isav = me->nActPos;
    me->nActPos = locAct;

    status =
    om$send (msg = message VCCmdCON.VCCONlst
                              (bSET, form_label, form_ptr),
        targetid = my_id);
    as$status();

    me->nActPos = isav;
  }

  me->nCndNum--;

  for (i=me->nActCnd; i < me->nCndNum; i++)
  {
    me->CndTab[i] = me->CndTab[i+1];
    me->CndSig[i] = me->CndSig[i+1];
  }

  for (i=me->nCndNum; i < me->nMaxCnd; i++)
  {
    me->CndTab[i] = me->INITstr;
    me->CndSig[i] = me->INITsig;
  }

  /*    Update form.   KDD 12-97 let redisplay always do it  */
  if (!(bInsert) && 0 )
  { /*   update form directly    */

#ifdef MY_DEBUG
    printf (" update form, tab at %d \n", me->nActPos);
    printf (" remove candidate at %d \n", me->nActCnd);
#endif

    FIfld_delete_rows (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd, 1);

    if (me->bICB)
    {
      if (me->nActSide == VC_CONCOL_MPOS1)
      {
        FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_SIG1,
                      me->ConSig1[me->nActPos].sig , SelFlag);
        FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_CAB1,
                      me->ConTab1[me->nActPos].Ctag , SelFlag);
        FIfld_set_text (form_ptr, VC_CONGDG_MTAB, me->nActPos, VC_CONCOL_LEAD1,
                      me->ConTab1[me->nActPos].ps.Conn.Cable.szLeadId,SelFlag);
      }
      else
      {
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
      FIfld_set_text (form_ptr, VC_CONGDG_STAB, me->nActPos, VC_CONCOL_SIG,
                      me->ConSig1[me->nActPos].sig , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_STAB, me->nActPos, VC_CONCOL_CAB,
                      me->ConTab1[me->nActPos].Ctag , SelFlag);
      FIfld_set_text (form_ptr, VC_CONGDG_STAB, me->nActPos, VC_CONCOL_LEAD,
                      me->ConTab1[me->nActPos].ps.Conn.Cable.szLeadId,SelFlag);
    }
  }

  /*	or let redisplay always do it  */
  me->bRedisplay = TRUE;

  status =
  om$send (msg = message VCCmdCON.VCCONactv (form_ptr, -1, -1, -1),
      targetid = my_id);

  me->nCurC_S = VCFO_T_NONE;

  DONE:
  End;
  return OM_S_SUCCESS;
}

end implementation VCCmdCON;

