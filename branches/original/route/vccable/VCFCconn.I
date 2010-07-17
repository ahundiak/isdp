
/* $Id: VCFCconn.I,v 1.3 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCFCconn.I
 *
 * Description:
 *      methods to store / retrieve assigned connectors/splices
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCFCconn.I,v $
 *        Revision 1.3  2002/05/08 15:48:23  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:09:19  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1999/02/10  21:33:04  pinnacle
# Replaced: vccable/VCFCconn.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/08/11  21:59:12  pinnacle
# Replaced: vccable/VCFCconn.I for:  by hverstee for cabling
#
# Revision 1.3  1997/07/14  22:33:28  pinnacle
# Replaced: vccable/VCFCconn.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/06  22:56:38  pinnacle
# Replaced: vccable/VCFCconn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:51:30  pinnacle
# Created: vccable/VCFCconn.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class implementation VCFoCable;

#include "vrdbgmacros.h"

method  VCFo_PutConn  ( IGRlong         *msg;
                        IGRshort         nCpt;
                        IGRshort         nIdx;
                 struct VCpos           *IdStr;
                        IGRchar         *Conn;
                        IGRshort         CType)
{
  IGRlong              status;
  IGRlong              retmsg;
  IGRshort             nPrm;
  IGRint               nFib;
  IGRchar	       LeadName[VC_MAX_LEAD_ID];
  struct GRid          MyId;

  SetProc( VCFo_Putconn ); Begin;

  __DBGpr_int( " Connect point no. ", nCpt);
  __DBGpr_str( " Splice Connector . ", Conn );

  if (IdStr)
      strcpy( LeadName, IdStr->Conn.Cable.szLeadId );
  else
  {
      VC_INITSTR( LeadName );
      MyId.objid = my_id;
      MyId.osnum = OM_Gw_current_OS;
      status = VC_ConNum_LeadName( &retmsg, &MyId, LeadName, &nIdx );
  }
  __DBGpr_str("Splice Connector being set for LeadName", LeadName);

  /* Just for loop on me->Connect_Data and set the signal! */

  nFib = om$dimension_of(varray = me->Connect_Data);
  __DBGpr_int("No of Leads",nFib);
  for( nPrm=0 ; nPrm<nFib ; nPrm++ )
  {
      if(!strcmp(me->Connect_Data[nPrm].LeadNam,LeadName))
	  break;
  }

  nFib = om$dimension_of( varray = me->FO_con_splc);

  __DBGpr_int("No of elements in FO_con_splc",nFib);
  if ((nPrm >= 0) && (nPrm < nFib))
  {
    if (nCpt == 0)
    {
	strcpy (me->FO_con_splc[nPrm].FO_0, Conn);
	__DBGpr_str("Splice name stored", me->FO_con_splc[nPrm].FO_0);
    }
    else
    {
	strcpy (me->FO_con_splc[nPrm].FO_1, Conn);
	__DBGpr_str("Splice name stored", me->FO_con_splc[nPrm].FO_1);
    }
    me->FO_con_splc[nPrm].nTyp[nCpt] = CType;
  }

  End
  return (status);
}

method  VCFo_GetConn  ( IGRlong         *msg;
                        IGRshort         nCpt;
                        IGRshort         nIdx;
                 struct VCpos           *IdStr;
                        IGRchar         *Conn;
                        IGRshort        *CType)
{
  IGRlong              status;
  IGRlong              retmsg;
  IGRshort             nPrm;
  IGRint               nFib;
  IGRchar	       LeadName[VC_MAX_LEAD_ID];
  struct GRid          MyId;

  SetProc( VCFo_Getconn ); Begin

  __DBGpr_int( " Connect point no. ", nCpt);

  if (IdStr)
      strcpy( LeadName, IdStr->Conn.Cable.szLeadId );
  else
  {
      VC_INITSTR( LeadName );
      MyId.objid = my_id;
      MyId.osnum = OM_Gw_current_OS;
      status = VC_ConNum_LeadName( &retmsg, &MyId, LeadName, &nIdx );
  }
  __DBGpr_str("Splice Connector being set for LeadName", LeadName);

  /* Just for loop on me->Connect_Data and set the signal! */

  nFib = om$dimension_of(varray = me->Connect_Data);
  __DBGpr_int( "No. of Fibers ", nFib );
  for( nPrm=0 ; nPrm<nFib ; nPrm++ )
  {
      if(!strcmp(me->Connect_Data[nPrm].LeadNam,LeadName))
	  break;
  }


  nFib = om$dimension_of( varray = me->FO_con_splc);
  __DBGpr_int( "No. of elements in FO_con_splc ", nFib );

  __DBGpr_int( " nPrm = ", nPrm );
  if ((nPrm >= 0) && (nPrm < nFib))
  {
    if (nCpt == 0)
      strcpy (Conn, me->FO_con_splc[nPrm].FO_0);
    else
      strcpy (Conn, me->FO_con_splc[nPrm].FO_1);

    __DBGpr_str("Splice name fetched",Conn);
    *CType = me->FO_con_splc[nPrm].nTyp[nCpt];
  }

  End
  return (status);
}

end implementation VCFoCable;
