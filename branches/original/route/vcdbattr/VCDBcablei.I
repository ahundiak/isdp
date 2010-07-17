
/* $Id: VCDBcablei.I,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCDBcablei.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCDBcable class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBcablei.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/07/28  22:24:46  pinnacle
# Replaced: vcdbattr/VCDBcablei.I for:  by hverstee for cabling
#
# Revision 1.2  1997/07/21  22:50:42  pinnacle
# Replaced: vcdbattr/VCDBcablei.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/14  21:46:22  pinnacle
# Created: vcdbattr/VCDBcablei.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCDBcable;


method  VCGpAnum (IGRlong         *msg;
                  IGRshort         nIndex;
                  IGRshort         nMAP;
                  IGRint           nAttnum;
           struct ret_struct      *res)
{
  IGRint        status;
  IGRshort      nEnt;

  *msg = MSFAIL;
  nEnt = om$dimension_of (varray = me->Map);

  if (nAttnum == VC_X_INSERT_BLOCK_AN)
  {
    *msg = MSSUCC;
    res->type = text_type;
    strcpy (res->var.text_st.text_string, me->DBMain.Insertblk);
  }
  else
  if (nAttnum == VC_X_NUM_CONDUCT_IN)
  {
    *msg = MSSUCC;
    res->type = double_type;
    res->var.root_pm_st.value = nEnt;
  }
  else
  if ((nMAP >= 0) && (nMAP < nEnt))
  {
    *msg = MSSUCC;

    switch (nAttnum)
    {
      case VC_X_LEAD_NBR_DB:
        res->type = double_type;
        res->var.root_pm_st.value = me->Map[nMAP].Con_number;
        break;
      case VC_X_DEF_SIGNAL_AN:
        res->type = text_type;
        strcpy (res->var.text_st.text_string, me->Map[nMAP].Def_signal);
        break;
      default:
        *msg = MSFAIL;
        break;
    }
  }

  /*    find in master   */

  if (*msg == MSFAIL)
  {
    status =
    om$send (msg = message VCDBcbgd.VCGpAnum (msg, nIndex, nMAP,nAttnum, res),
            mode = OM_e_wrt_message,
        targetid = my_id);
  }

  return (OM_S_SUCCESS);
}


method  VCGetLayout (IGRlong         *msg;
                     IGRchar         *Modnam;
                     IGRshort        *nEnt;
                     IGRshort        *nTab;
              struct VClayout        *Layout)
{
   IGRint        i;

   *msg      = MSSUCC;
   *nEnt     = om$dimension_of (varray = me->Map);
   *nTab     = *nEnt;

   if (Layout)
   {
     for (i=0; i< *nEnt; i++)
     {
       strcpy (Layout[i].pDef.Conn.Cable.szLeadId, me->Map[i].Con_name);
       strcpy (Layout[i].szDefSig, me->Map[i].Def_signal);

       Layout[i].pDef.nType = VC_CABLE_TYPE;
       Layout[i].pAlt.nType = VC_UNKNOWN;

       Layout[i].nTOPO      = VC_TOPO_CAB;
     }
   }

   return (OM_S_SUCCESS);
}

end implementation VCDBcable;

