
/* $Id: VCDBtermi.I,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCDBtermi.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCDBterm class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBtermi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/07/21  22:50:28  pinnacle
# Replaced: vcdbattr/VCDBtermi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:44:50  pinnacle
# Replaced: vcdbattr/VCDBtermi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:19:50  pinnacle
# Replaced: vcdbattr/VCDBtermi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:27:08  pinnacle
# Replaced: vcdbattr/VCDBtermi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:54:36  pinnacle
# Created: vcdbattr/VCDBtermi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCDBterm;

/*
#define MY_DEBUG
*/

method  VCGpAnum  (IGRlong         *msg;
                   IGRshort         nIndex;
                   IGRshort         nMAP;
                   IGRint           nAttnum;
            struct ret_struct      *res)
{
  IGRint        status;
  IGRshort      nEnt;

  *msg = MSFAIL;
  nEnt = om$dimension_of (varray = me->Mod);

  if (nAttnum == VC_X_MACRO_NAME_AN)
  {
    *msg = MSSUCC;

    res->type = text_type;
    strcpy (res->var.text_st.text_string, me->DBMain.Macro_name);
  }
  else
  if ((nMAP >= 0) && (nMAP < nEnt))
  {
    *msg = MSSUCC;

    switch (nAttnum)
    {
        case VC_X_V_MOD_NAME_AN:
          res->type = text_type;
          strcpy (res->var.text_st.text_string, me->Mod[nMAP].Mod_desc);
          break;

        case VC_X_V_POS_NM1_AN:
          res->type = text_type;
          strcpy (res->var.text_st.text_string, me->Mod[nMAP].Pos_id1);
          break;

        case VC_X_V_POS_NM2_AN:
          res->type = text_type;
          strcpy (res->var.text_st.text_string, me->Mod[nMAP].Pos_id2);
          break;

        case VC_X_V_IOTYPE1_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Mod[nMAP].Iotype1;
          break;

        case VC_X_V_IOTYPE2_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Mod[nMAP].Iotype2;
          break;

        case VC_X_V_CONNECTYPE_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Mod[nMAP].ConnecPAR;
          break;

        case VC_X_DEF_SIGNAL_AN:
          res->type = text_type;
          strcpy (res->var.text_st.text_string, me->Mod[nMAP].Def_signal);
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
    om$send (msg = message VCDBgen.VCGpAnum (msg, nIndex, nMAP, nAttnum, res),
            mode = OM_e_wrt_message,
        targetid = my_id);
  }

  return (OM_S_SUCCESS);
}

method VCDB_init (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  status =
  om$send (msg = message VCDBgen.VCDB_init (msg, Tabrec),
          mode = OM_e_wrt_message,
      targetid = my_id);

  strcpy (me->DBMain.Macro_name,  Tabrec->Macro_name);

  return (OM_S_SUCCESS);
}

method VCDB_ghdr (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  status =
  om$send (msg = message VCDBgen.VCDB_ghdr (msg, Tabrec),
          mode = OM_e_wrt_message,
      targetid = my_id);

  strcpy (Tabrec->Macro_name, me->DBMain.Macro_name);

  return (OM_S_SUCCESS);
}

method  VCGetModules (IGRlong         *msg;
                      IGRshort        *nEnt;
                      IGRshort        *nTopoTyp;
                      IGRchar         *Modlist)
{
   IGRint        i;
   IGRshort      nLoop;
   IGRchar      *ptr;
   IGRshort     *nTp;

   *msg      = MSSUCC;
   nLoop     = om$dimension_of (varray = me->Mod);
   *nEnt = 0;

   if (nLoop == 0) return (OM_S_SUCCESS);

   *nEnt = 1;
   ptr = Modlist;
   nTp = nTopoTyp;

   if (Modlist) strcpy (ptr, me->Mod[0].Mod_id);
   if (nTopoTyp) *nTp = VC_TOPO_TRG;

   for (i=1; i<nLoop; i++)
   {
     if (strcmp (me->Mod[i].Mod_id, me->Mod[i-1].Mod_id) != 0)
     {
       if (nTopoTyp)
       {
         nTp++;
         *nTp = VC_TOPO_TRG;
       }

       if (Modlist)
       {
         ptr += VC_MAX_MOD_ID;
         strcpy (ptr, me->Mod[i].Mod_id);
       }
       (*nEnt)++;
     }

     if (nTopoTyp)
     {
       if (me->Mod[i].Pos_id2[0] != '\0') *nTp = VC_TOPO_TIC;
       if (me->Mod[i].Pos_id1[0] == '\0') *nTp = VC_TOPO_TST;
     }
   }

   return (OM_S_SUCCESS);
}

method  VCGetLayout (IGRlong         *msg;
                     IGRchar         *Modnam;
                     IGRshort        *nEnt;
                     IGRshort        *nTab;
              struct VClayout        *Layout)
{
   IGRint        i, j;
   IGRshort      nLoop;
   IGRshort      nlTOPO;
   IGRchar       szLocMod[VC_MAX_MOD_ID];

   *msg      = MSSUCC;
   *nEnt     = 0;
   *nTab     = 0;
   nLoop     = om$dimension_of (varray = me->Mod);
   nlTOPO    = VC_TOPO_TRG;

   VC_INITSTR (szLocMod);

   for (i=0; i<nLoop; i++)
   {
     if (Modnam)
     {
       if (strcmp (me->Mod[i].Mod_id, Modnam) != 0) continue;
     }

     if (strcmp (me->Mod[i].Mod_id, szLocMod) != 0)
     {  /*  first line of next module, set topology   */
       nlTOPO    = VC_TOPO_TRG;

       strcpy (szLocMod, me->Mod[i].Mod_id);

#ifdef MY_DEBUG
       printf (" layout, check module %s\n",szLocMod);
#endif

       for (j=i; i<nLoop; j++)
       {
         if (strcmp (me->Mod[j].Mod_id, szLocMod) != 0) break;

         if (!(VC_EMPTYSTR (me->Mod[j].Pos_id2))) nlTOPO= VC_TOPO_TIC;
         if (  VC_EMPTYSTR (me->Mod[j].Pos_id1))  nlTOPO= VC_TOPO_TST;
       }
     }

     if (Layout)
     {
        Layout[*nTab].pDef.nType = Layout[*nTab].pAlt.nType = VC_UNKNOWN;
        strcpy (Layout[*nTab].szDefSig, me->Mod[i].Def_signal);
     }

     if (!(VC_EMPTYSTR (me->Mod[i].Pos_id1)))
     {
       if (Layout)
       {
         strcpy (Layout[*nTab].pDef.Conn.Term.szModId, me->Mod[i].Mod_id);
         strcpy (Layout[*nTab].pDef.Conn.Term.szPosId, me->Mod[i].Pos_id1);

         Layout[*nTab].pDef.nType = VC_TERM_TYPE;
       }

#ifdef MY_DEBUG
       printf (" layout, %d pos %s prim\n",i,me->Mod[i].Pos_id1);
#endif

       (*nEnt)++;
     }

     if (!(VC_EMPTYSTR (me->Mod[i].Pos_id2)))
     {
       if (Layout)
       {
         strcpy (Layout[*nTab].pAlt.Conn.Term.szModId, me->Mod[i].Mod_id);
         strcpy (Layout[*nTab].pAlt.Conn.Term.szPosId, me->Mod[i].Pos_id2);

         Layout[*nTab].pAlt.nType = VC_TERM_TYPE;
       }

#ifdef MY_DEBUG
       printf (" layout, %d pos %s prim\n",i,me->Mod[i].Pos_id1);
#endif

       (*nEnt)++;
     }

     if (Layout)
       Layout[*nTab].nTOPO = nlTOPO;

     (*nTab)++;
   }

   return (OM_S_SUCCESS);
}

end implementation VCDBterm;

