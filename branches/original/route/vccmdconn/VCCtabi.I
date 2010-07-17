
/* $Id: VCCtabi.I,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCtabi.I
 *
 * Description:
 *
 *  Implementation file for connectivity load function
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCtabi.I,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.1  1997/07/31  20:25:34  pinnacle
# Created: vccmdconn/VCCtabi.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VCCtab;

/*
#define MY_DEBUG
*/

from  VCRoot     import        VCGetProduct;
from  VCRoot     import        VCGetTopology;
from  VCRoot     import        VCGetType;
from  VCRoot     import        VCGetModel;
from  VCRoot     import        VCGetTagNo;

from  VCMac      import        VCGetEquipTag;
from  VCFoCable  import        VCFo_GetConn;

from  VCDB       import        VCGetLayout;

from  VCCon      import        VCGetSignal;
from  VCCon      import        VCConList;


/*=======================================================================*/


method VCCtInsert (IGRshort  index)
{
  IGRshort    ii;

  for (ii=me->nMaxCon-1; ii>=index+1; ii--)
  {
     me->ConTab1[ii] = me->ConTab1[ii-1];
     me->ConSig1[ii] = me->ConSig1[ii-1];
     me->ConTab2[ii] = me->ConTab2[ii-1];
     me->ConSig2[ii] = me->ConSig2[ii-1];
     me->PosTab[ii]  = me->PosTab[ii-1];
  }

  me->ConTab1[index+1]           = me->INITstr;
  me->ConSig1[index+1]           = me->ConSig1[index];
  me->ConTab2[index+1]           = me->INITstr;
  me->ConSig2[index+1]           = me->ConSig2[index];

  me->nNumConTab++;

#ifdef MY_DEBUG
  printf (" Insert %d now %d entries\n",index,me->nNumConTab);
#endif

  return OM_S_SUCCESS;
}


method VCCtClear (IGRlong     *sts)
{
  IGRint      status;

  *sts = MSSUCC;

  /*    fill initializer structures    */

  VC_INITSTR (me->INITsig.sig);
  me->INITsig.bSWsig   = FALSE;

  me->INITstr.GR.objid = NULL_OBJID;
  VC_INITSTR (me->INITstr.Ctag);
  VC_INITSTR (me->INITstr.CON);

  me->INITstr.nCstat   = VCFO_T_NONE;
  me->INITstr.nCtype   = VCFO_A_UNCHANGED;

  me->INITstr.ps.nType = VC_GEN_CABLE;
  me->INITstr.ps.Conn.Cable.nCpt = VC_REQ_ALL_CPT;
  me->INITstr.ps.Conn.Cable.bPass = FALSE;
  VC_INITSTR (me->INITstr.ps.Conn.Cable.szLeadId);

  me->INITtrm.nType = VC_GEN_TERM;
  VC_INITSTR (me->INITtrm.Conn.Term.szModId);
  VC_INITSTR (me->INITtrm.Conn.Term.szPosId);

  /*A initialize my instance data */

  me->TBref.objid    = NULL_OBJID;
  me->bICB           = FALSE;
  me->nMaxCnd        = 0;
  me->nMaxCon        = 0;
  me->nCndNum        = 0;
  me->nNumConTab     = 0;
  me->nNumConEnt     = 0;
  me->iTBprod        = VC_PROD_NONE;

  VC_INITSTR (me->szTBeqt);
  VC_INITSTR (me->szTBtag);

  status = om$vla_set_dimension (varray = me->CabTab,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->nCPS,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->PosTab,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->ConTab1,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->ConSig1,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->ConTab2,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->ConSig2,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->CndTab,
                                 size   = 0);

  status = om$vla_set_dimension (varray = me->CndSig,
                                 size   = 0);

  return (OM_S_SUCCESS);
}


method VCCtLoad (IGRlong     *sts;
          struct GRid        *LoadId;
          struct GRmd_env    *md_env)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRint          i;
  IGRshort        nThisno;
  IGRshort        nAltno;
  IGRshort        NbNeigh;
  IGRboolean      bCreate;

  /*A initialzation         */

#ifdef MY_DEBUG
  printf (" CtLoad entry\n");
#endif

  status =
  om$send (msg = message VCCtab.VCCtClear (sts),
      targetid = my_id);

  *sts   = MSFAIL;
  status = OM_S_SUCCESS;

  bCreate = FALSE;

  /*A get the located object */
  me->TBref = *LoadId;
 
#ifdef MY_DEBUG
  printf (" Connect, Refid <%d %d>\n",me->TBref.objid, me->TBref.osnum);
#endif

  status =
  om$send (msg = message VCRoot.VCGetType (&me->iTBType),
      targetid = me->TBref.objid,
      targetos = me->TBref.osnum);

  /*A change to virtual.....  */
  if (me->iTBType & VC_GEN_TERM)
  {

    status =
    VCT_virtualize (&retmsg, bCreate, &me->TBref, md_env,
                                      &me->TBref, md_env);
    as$status();

  }
  else
    return (OM_E_ABORT);

  status =
  om$send (msg = message VCRoot.VCGetModel (&retmsg, &me->TBmodel),
      targetid = me->TBref.objid,
      targetos = me->TBref.osnum);

  if ((retmsg != MSSUCC) || (me->TBmodel.objid == NULL_OBJID))
  {
    goto quit;
  }

#ifdef MY_DEBUG
  printf (" Connect, modelid <%d %d>\n",me->TBmodel.objid, me->TBmodel.osnum);
#endif

  status =
  om$send (msg = message VCRoot.VCGetProduct (&me->iTBprod, NULL),
      targetid = me->TBref.objid,
      targetos = me->TBref.osnum);

  status =
  om$send (msg = message VCRoot.VCGetTagNo (me->szTBtag),
      targetid = me->TBref.objid,
      targetos = me->TBref.osnum);

  status =
  om$send (msg = message VCMac.VCGetEquipTag
                                  (&retmsg, me->szTBeqt, md_env),
      targetid = me->TBref.objid,
      targetos = me->TBref.osnum);

#ifdef MY_DEBUG
  printf (" Refid = <%d %d>\n", me->TBref.objid,me->TBref.osnum);
  printf (" Tags  <%s> - <%s>\n",me->szTBtag, me->szTBeqt);
#endif

  /*   find the connect buffer sizes (max)  */
  status =
  om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, NULL, &me->nNumConEnt,
                                 &me->nNumConTab, NULL),
      targetid = me->TBmodel.objid,
      targetos = me->TBmodel.osnum);

  me->bICB = (me->nNumConEnt != me->nNumConTab);

#ifdef MY_DEBUG
  printf (" Layout %d entries on %d lines\n", me->nNumConTab,
                               me->nNumConEnt);
#endif

  /*A  count the number of leads     */

  status =
  om$send (msg = message VCRoot.VCGetTopology
                                   (&retmsg, VC_REQ_ALL_CPT, &NbNeigh,
                                     NULL, NULL, NULL, NULL),
      targetid = me->TBref.objid,
      targetos = me->TBref.osnum);

  if (NbNeigh <= 0)
  {
    NbNeigh = 1;
  }

#ifdef MY_DEBUG
  printf (" Cables connected %d \n", NbNeigh);
#endif

  status = om$vla_set_dimension (varray = me->CabTab,
                                 size   = NbNeigh);

  status = om$vla_set_dimension (varray = me->nCPS,
                                 size   = NbNeigh);

  NbNeigh = 0;
  status =
  om$send (msg = message VCRoot.VCGetTopology
                                   (&retmsg, VC_REQ_ALL_CPT, &NbNeigh,
                                     me->CabTab, me->nCPS, NULL, NULL),
      targetid = me->TBref.objid,
      targetos = me->TBref.osnum);

  /*A  Find the maximum total number of connected fibers    */
  me->nMaxCnd = 0;

  for (i=0; i<NbNeigh; i++)
  {
    status =
    om$send (msg = message VCDB.VCGetLayout
                                  (&retmsg, NULL, &nThisno, &nAltno, NULL),
        targetid = me->CabTab[i].objid,
        targetos = me->CabTab[i].osnum);

      me->nMaxCnd += nThisno;
#ifdef MY_DEBUG
    printf (" Cable <%d %d> %d leads\n",me->CabTab[i].objid,
                                     me->CabTab[i].osnum, nThisno);
#endif
  }

  /*C  make room for some extra   */

  *sts = MSSUCC;

  me->nMaxCon = me->nNumConTab + 20;
  me->nMaxCnd += 5;

#ifdef MY_DEBUG
  printf (" allocing Con, Cnd %d %d\n",me->nMaxCon,me->nMaxCnd);
#endif

  /*A    and allocate the memory needed    */

  status = om$vla_set_dimension (varray = me->PosTab,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConTab1,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConSig1,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConTab2,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->ConSig2,
                                 size   = me->nMaxCon);

  status = om$vla_set_dimension (varray = me->CndTab,
                                 size   = me->nMaxCnd);

  status = om$vla_set_dimension (varray = me->CndSig,
                                 size   = me->nMaxCnd);

  /*   retrieve all info             */

  for (i=0; i<me->nMaxCon; i++)
  {
    me->PosTab[i].pDef  = me->INITtrm;
    me->PosTab[i].pAlt  = me->INITtrm;
    me->PosTab[i].nTOPO = VC_TOPO_TRG;
  }

  status =
  om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, NULL, &me->nNumConEnt,
                                 &me->nNumConTab, me->PosTab),
      targetid = me->TBmodel.objid,
      targetos = me->TBmodel.osnum);

#ifdef MY_DEBUG
  printf (" Terminal layout loaded, %d lines\n",me->nNumConTab);
#endif

  for (i=0; i<me->nMaxCon; i++)
  {
    me->ConTab1[i] = me->INITstr;
    me->ConTab2[i] = me->INITstr;

    if (me->PosTab[i].pDef.nType == VC_TERM_TYPE)
    {
      status =
      om$send (msg = message VCCon.VCGetSignal
                     (&retmsg, &me->PosTab[i].pDef, me->ConSig1[i].sig),
          targetid = me->TBref.objid,
          targetos = me->TBref.osnum);
#ifdef MY_DEBUG
      printf (" Terminal signal %s loaded\n",me->ConSig1[i].sig);
#endif
    }

    if (me->PosTab[i].pAlt.nType == VC_TERM_TYPE)
    {
      status =
      om$send (msg = message VCCon.VCGetSignal
                     (&retmsg, &me->PosTab[i].pAlt, me->ConSig2[i].sig),
          targetid = me->TBref.objid,
          targetos = me->TBref.osnum);
#ifdef MY_DEBUG
      printf (" Terminal signal %s loaded\n",me->ConSig2[i].sig);
#endif
    }
  }

#ifdef MY_DEBUG
  printf (" Terminal signals done, to %d cables\n",NbNeigh);
#endif

  for (i=0; i<me->nMaxCnd; i++)
  {
    me->CndTab[i] = me->INITstr;
  }

  for (i=0; i<NbNeigh; i++)
  {
    IGRint           j, k;
    IGRshort         nStates[30];
    IGRchar          szCabTag[VC_MAX_TAGNO];

    struct   VCpos   cab[30];
    struct   VCpos   trm[30];

    status =
    om$send (msg = message VCCon.VCConList
                                 (&retmsg, me->nCPS[i], 
                           (VC_CBE_OPEN | VC_CBE_CONNECTED | VC_CBE_PASSTHRU),
                                    &nThisno, cab, trm, nStates, NULL),
        targetid = me->CabTab[i].objid,
        targetos = me->CabTab[i].osnum);

    status =
    om$send (msg = message VCRoot.VCGetTagNo (szCabTag),
        targetid = me->CabTab[i].objid,
        targetos = me->CabTab[i].osnum);


#ifdef MY_DEBUG
    printf (" Cable %d end %d leads returned  %d \n",i, me->nCPS[i],nThisno);
#endif

    for (j=0;j<nThisno; j++)
    {
#ifdef MY_DEBUG
      printf (" Cable %d lead %d state %x\n",i, j, nStates[j]);
#endif

      if (nStates[j] & VC_CBE_OPEN)
      {  /*  open lead, add to candidates    */
        me->CndTab[me->nCndNum].GR = me->CabTab[i];
        me->CndTab[me->nCndNum].ps = cab[j];

        strcpy (me->CndTab[me->nCndNum].Ctag, szCabTag);

        /*    get signal   */
        status =
        om$send (msg = message VCCon.VCGetSignal
                             (&retmsg, &cab[j], me->CndSig[me->nCndNum].sig),
            targetid = me->CabTab[i].objid,
            targetos = me->CabTab[i].osnum);

        (me->nCndNum)++;
#ifdef MY_DEBUG
        printf (" Open lead %d signal %s\n",me->nCndNum,
                                        me->CndSig[me->nCndNum].sig);
#endif

        continue;
      }

      /*    insert passthrough treatment .....    */
      if (nStates[j] & VC_CBE_PASSTHRU)               continue;

      /*    connected leads left      */

      for (k=0; k<me->nNumConTab; k++)
      {
        if (VC_posequal (&me->PosTab[k].pDef, &trm[j]))
        {
           if (me->ConTab1[k].GR.objid != NULL_OBJID)
           {   /*  multiple connect, expand   */
             status =
             om$send (msg = message VCCtab.VCCtInsert (k),
                 targetid = my_id);

             /*   add on new line    */
             k++;
           }

           me->ConTab1[k].GR = me->CabTab[i];
           me->ConTab1[k].ps = cab[j];
           strcpy (me->ConTab1[k].Ctag, szCabTag);

           /*    get signal   */
           status =
           om$send (msg = message VCCon.VCGetSignal
                             (&retmsg, &cab[j], me->ConSig1[k].sig),
               targetid = me->CabTab[i].objid,
               targetos = me->CabTab[i].osnum);

           /*   FO connector  */

           if (me->iTBprod == VC_PROD_FO)
           {
             status =
             om$send (msg = message VCFoCable.VCFo_GetConn
                             (&retmsg, cab[j].Conn.Cable.nCpt, 0, &cab[j],
                              me->ConTab1[k].CON, &me->ConTab1[k].nCtype),
                 targetid = me->CabTab[i].objid,
                 targetos = me->CabTab[i].osnum);
           }
        }

        if (!me->bICB)        continue;

        if (VC_posequal (&me->PosTab[k].pAlt, &trm[j]))
        {
          if (me->ConTab2[k].GR.objid != NULL_OBJID)
          {   /*  multiple connect, expand   */
             status =
             om$send (msg = message VCCtab.VCCtInsert (k),
                 targetid = my_id);

             /*   add on new line    */
             k++;
           }

           me->ConTab2[k].GR = me->CabTab[i];
           me->ConTab2[k].ps = cab[j];
           strcpy (me->ConTab2[k].Ctag, szCabTag);

           /*    get signal   */
           status =
           om$send (msg = message VCCon.VCGetSignal
                             (&retmsg, &cab[j], me->ConSig2[k].sig),
               targetid = me->CabTab[i].objid,
               targetos = me->CabTab[i].osnum);

           /*   FO connector  */

           if (me->iTBprod == VC_PROD_FO)
           {
             status =
             om$send (msg = message VCFoCable.VCFo_GetConn
                             (&retmsg, cab[j].Conn.Cable.nCpt, 0, &cab[j],
                              me->ConTab2[k].CON, &me->ConTab2[k].nCtype),
                 targetid = me->CabTab[i].objid,
                 targetos = me->CabTab[i].osnum);
           }
        }
      }
    }
#ifdef MY_DEBUG
        printf (" Next cable\n");
#endif

  }

#ifdef MY_DEBUG
        printf (" CtLoad - exit\n");
#endif

  quit:
  return (OM_S_SUCCESS);
}

end implementation VCCtab;
