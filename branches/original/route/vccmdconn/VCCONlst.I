
/* $Id: VCCONlst.I,v 1.2 2001/02/20 01:10:13 build Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONlst.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONlst.I,v $
 *     Revision 1.2  2001/02/20 01:10:13  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:29  cvs
 *     Initial import to CVS
 *
# Revision 1.2  1998/10/20  15:35:44  pinnacle
# Replaced: vccmdconn/VCCONlst.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/01/24  00:10:56  pinnacle
# Replaced: vccmdconn/VCCONlst.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:32:26  pinnacle
# Created: vccmdconn/VCCONlst.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *      10/06/98          Alwin         Modified the function call to get the
 *                                      Connector/Splice list. Later this call
 *                                      may have to be modified while working
 *                                      on the fiber-optic stuff in detail.
 *
 * -------------------------------------------------------------------*/

class implementation VCCmdCON;

%safe
#include "VX_FIproto.h"
%endsafe

#include <string.h>
#include "VCDBpar.h"
#include "VCproto.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

from   VCDB   import   VCGetAnum;

/*
#define MY_DEBUG
*/



/*=======================================================================*/


method VCCONlst ( IGRboolean  bSET;
                  int         form_label ;
                  char      * form_ptr )  
{
  IGRlong       retmsg;
  IGRlong       status;
  IGRint        SelFlag = TRUE;
  IGRint        i;
  IGRint        iWhich;

  struct GRid   GRid1;
  struct GRid   GRid2;
  struct VCpos *pPos1;
  struct VCpos *pPos2;

  struct ret_struct   szMtc1;
  struct ret_struct   szMtc2;

  SetProc( Md VCCONlst ); Begin 

  me->nCurC_S = VCFO_T_CONNECT;

  if (me->nActSide == VC_CONCOL_MPOS2)
  {
    GRid1.objid = me->ConTab2[me->nActPos].GR.objid;
    GRid1.osnum = me->ConTab2[me->nActPos].GR.osnum;
    pPos1       = &me->ConTab2[me->nActPos].ps;
    iWhich      = 2;
  }
  else
  {
    GRid1.objid = me->ConTab1[me->nActPos].GR.objid;
    GRid1.osnum = me->ConTab1[me->nActPos].GR.osnum;
    pPos1       = &me->ConTab1[me->nActPos].ps;
    iWhich      = 1;
  }

  if (me->PosTab[me->nActPos].nTOPO == VC_TOPO_TIC)
  {
    if (me->nActSide == VC_CONCOL_MPOS1)
    {
      GRid2.objid = me->ConTab2[me->nActPos].GR.objid;
      GRid2.osnum = me->ConTab2[me->nActPos].GR.osnum;
      pPos2       = &me->ConTab2[me->nActPos].ps;
    }
    else
    {
      GRid2.objid = me->ConTab1[me->nActPos].GR.objid;
      GRid2.osnum = me->ConTab1[me->nActPos].GR.osnum;
      pPos2       = &me->ConTab1[me->nActPos].ps;
    }

    if (GRid2.objid == NULL_OBJID)
    {
      strcpy (me->szMSG,
              "Connector/splice assign failed, connect other end first");
      goto DONE;
    }

    /*  change to type splice if necessary  */
    /*  get iotype for thruconn pins        */

  }
  else
  {
      GRid2.objid = me->RefId.objid;
      GRid2.osnum = me->RefId.osnum;
      pPos2       = &me->PosTab[me->nActPos].pDef;
  }

  status =
  om$send (msg = message VCDB.VCGetAnum
                         (&retmsg, pPos1, VC_X_CON_MATCH_AN, &szMtc1),
      targetid = GRid1.objid,
      targetos = GRid1.osnum);

  status =
  om$send (msg = message VCDB.VCGetAnum
                         (&retmsg, pPos2, VC_X_CON_MATCH_AN, &szMtc2),
      targetid = GRid2.objid,
      targetos = GRid2.osnum);

  __DBGpr_com( " Calling dn VC_FOCONlist ..." );
  status =
  VC_FOCONlist (&retmsg, szMtc1.var.text_st.text_string,
                         szMtc2.var.text_st.text_string,
                         &me->CSPnum, NULL ); 
  as$status();
  as$status(action = GOTO_VALUE, value = DONE );

  __DBGpr_int( " Nb. of Connectors found ", me->CSPnum );

  //added by alwin for tr179801275
  if( me->CSPnum > 0 )
  {
      me->CSPlist = _MALLOC( me->CSPnum*VC_MAX_CCODE, IGRchar );

      if( me->CSPlist == NULL )
      {
        End
        return( OM_E_NODYNMEM );
      }

      status =
      VC_FOCONlist (&retmsg, szMtc1.var.text_st.text_string,
                             szMtc2.var.text_st.text_string,
                             &me->CSPnum, me->CSPlist);
      as$status();
      as$status(action = GOTO_VALUE, value = DONE );

      /*A   update /set connector assign list     */

      __DBGpr_int( " Nb. of Splices ", me->CSPnum );
      FIfld_set_list_num_rows (form_ptr, VC_CONGDG_CONFLD, 0, (int) me->CSPnum);

      if( me->CSPnum < 5 )
          FIfld_set_list_scroll (form_ptr, VC_CONGDG_CONFLD, 0, 0);

      for(i=0; i<me->CSPnum; i++)
      {
        IGRint index;

        index = i * VC_MAX_CCODE;

        __DBGpr_str( " Connector/Splice Code ", &me->CSPlist[index] );

        FIfld_set_list_text (form_ptr, VC_CONGDG_CONFLD, i, 0,
                         &me->CSPlist[index], FALSE);
      }
  }
  //added for tr179801275

  if (bSET)
  {
    if (me->CSPnum != 1) 
    {
      FIfld_set_text (form_ptr, VC_CONGDG_CONFLD, 0,0, "", SelFlag);

      /* commenting the below line...by alwin for TR179801275 ...
      *
      * sprintf (me->szMSG,"Autoassign failed, %d candidates\n",me->CSPnum);
      *
      * The fiber-optic Terminals will be worked later when Clark files
      * a CR for this. Still there are lot of unfinished stuff in Fiber-Optic
      * Terminals. ***********/
    }
    else
    {
      FIfld_set_text (form_ptr, VC_CONGDG_CONFLD, 0,0, me->CSPlist, SelFlag);

      sprintf (me->szMSG,"Connector %s Assigned\n",me->CSPlist);

      if (iWhich == 1)
      {
        strcpy (me->ConTab1[me->nActPos].CON, me->CSPlist);
        me->ConTab1[me->nActPos].nCstat = VCFO_A_AUTOASSIGN;
        me->ConTab1[me->nActPos].nCtype = me->nCurC_S;
      }
      else
      {
        strcpy (me->ConTab2[me->nActPos].CON, me->CSPlist);
        me->ConTab2[me->nActPos].nCstat = VCFO_A_AUTOASSIGN;
        me->ConTab2[me->nActPos].nCtype = me->nCurC_S;
      }
    }
  }

  DONE:
  End
  return OM_S_SUCCESS;
}

end implementation VCCmdCON;
