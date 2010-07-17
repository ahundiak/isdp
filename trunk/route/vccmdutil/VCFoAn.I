
/* $Id: VCFoAn.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCElAn.I
 *
 * Description:
 *      Fiberoptic analysis functions
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCFoAn.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/03/12  22:27:34  pinnacle
# Replaced: vccmdutil/VCFoAn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:03:58  pinnacle
# Created: vccmdutil/VCFoAn.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdAnal;


#include "VCproto.h"

from    VCDB         import    VCGetLayout;
from    VCCon        import    VCGetTopo;
from    ACncpx       import    ACgive_db_structure;
from    ACncpx       import    ACgive_structure;
from    VCFoCable    import    VCFo_GetConn;

/*
#define  MY_DEBUG
*/


/*****************************************************************************/

/*       Fiberoptic analysis functions                */

/*****************************************************************************/

IGRint   VC_FoAnalyze   (IGRlong         *msg,
                         IGRshort         nTrac,
                  struct VC_contrace     *TracTab,
                         FILE            *OutFil,
                         IGRint           IFunc,
                  struct GRid            *Refid,
                  struct GRmd_env        *md_env)
{

#ifdef FO_ANALYSIS
  switch (IFunc)
  {
        case 0:
          if (me->nTrac <= 0)
            VR_FoAn_dummy (&retmsg, me->nTrac, me->TracTab, me->pFile, i,
                              &me->RefId, &me->ModuleInfo);
          else
            VR_FoAn_trloss (&retmsg, me->nTrac, me->TracTab, me->szSigId,
                              me->pFile, &me->ModuleInfo);
          break;

        case 1:
          if (me->nTrac <= 0)
            VR_FoAn_cablen (&retmsg, &me->RefId, me->pFile, &me->ModuleInfo);
          else
            VR_FoAn_fiblen (&retmsg, me->nTrac, me->TracTab, me->pFile,
                              &me->ModuleInfo);
          break;

        case 2:
          if (me->nTrac <= 0)
            VR_FoAn_cabcsp (&retmsg, &me->RefId, me->pFile, &me->ModuleInfo);
          else
            VR_FoAn_fibcsp (&retmsg, me->nTrac, me->TracTab, me->pFile,
                              &me->ModuleInfo);
          break;

        case 3:
        case 5:
        case 6:
        default:
          VR_FoAn_dummy (&retmsg, me->nTrac, me->TracTab, me->pFile, i,
                              &me->RefId, &me->ModuleInfo);
          break;

        case 4:
        case 7:
          if (me->nTrac <= 0)
            VR_FoAn_conrep (&retmsg, &me->RefId, me->pFile,  &me->ModuleInfo);
          else
            VR_FoAn_f2list (&retmsg, me->nTrac, me->TracTab, me->szSigId,
                              me->pFile, &me->ModuleInfo);
          break;
  }
#endif

  return (0);
}

#ifdef FO_ANALYSIS
/*       dummy (unimplemented)     */

int   VR_FoAn_dummy  (IGRlong         *msg,
                      IGRshort         nTrac,
               struct VR_contrace     *TracTab,
                      FILE            *OutFil,
                      IGRint           IFunc,
               struct GRid            *RefId,
               struct GRmd_env        *md_env)
{
  IGRshort                lnTrac;
  struct VR_contrace     *lTracTab;
  struct GRid            *lRefId;
  struct GRmd_env        *lmd_env;

  *msg = MSSUCC;

  lnTrac = nTrac;
  lTracTab = TracTab;
  lRefId = RefId;
  lmd_env = md_env;

  if (OutFil)
  {
    fprintf (OutFil," Unimplemented function  %d\n", IFunc);

    fprintf (OutFil,
        "-----------------------------------------------------------------\n");
  }

  return (0);
}


/*****************************************************************************/

/*       loss calculation                           */

/*****************************************************************************/

int   VR_FoAn_trloss (IGRlong         *msg,
                      IGRshort         nTrac,
               struct VR_contrace     *TracTab,
                      IGRchar         *szSigId,
                      FILE            *OutFil,
               struct GRmd_env        *md_env)

{
  IGRshort        nPrm, nSec, nIO;
  IGRint          i, j;
  int             FootIndex = -1;
  IGRint          intmsg;
  IGRlong         retmsg;
  IGRlong         status;
  IGRchar         szTmp[50];
  GRclassid       parentClassId;
  VRConstring     Fibnams[10];
  IGRshort        nEnt;
  IGRdouble       Fiblengths[10];
  IGRchar         szAdd[13];
  VRConstring     Connams[10];
  IGRshort        nCSP;
  IGRint          CType;
  IGRshort        nQtys[10];
  IGRshort        nUnass;
  IGRboolean      bFspl;
  IGRdouble       dAtten;
  IGRchar         szWhere[30];

  struct GRid         Last;
  struct ret_struct   p_rs;

  *msg       = MSSUCC;
  status     = OM_S_SUCCESS;
  nEnt       = 0;
  Last.objid = NULL_OBJID;
  nCSP       = 0;
  bFspl      = FALSE;
  nUnass     = 0;
  dAtten     = 0.0;

  if (OutFil)
  {
    fprintf (OutFil,
        "        Attenuation calculation for trace - signal %s\n\n", szSigId);
  }

  /* summarize fibers   */
  for (i=0; i< nTrac; i++)
  {
    if (Last.objid == TracTab[i].OutGRid.objid) continue;

    parentClassId = TracTab[i].ClassId;

    if (om$is_ancestry_valid
           (subclassid = parentClassId,
          superclassid = OPP_VRLink_class_id) != OM_S_SUCCESS)
    {
      Last.objid = NULL_OBJID;
      continue;
    }

    Last.objid = TracTab[i].OutGRid.objid;

    status =
    om$send ( msg = message VRConMgt.VRConGetIdx
                     (&retmsg, TracTab[i].szOutId, &nPrm, &nSec, &nIO, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();

    sprintf (szTmp, VR_N_SNG_INDEX_FMT,VR_N_V_FOPTIC_CODE_AN, nPrm);

    status =
    om$send ( msg = message ACncpx.ACgive_db_structure
                      (&intmsg, &FootIndex, szTmp, &p_rs, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();

#ifdef MY_DEBUG
    printf (" find fibercode for %s = %s\n",szTmp,
                   p_rs.var.text_st.text_string);
#endif

    for (j=0; j< nEnt; j++)
    {
      if (strcmp (p_rs.var.text_st.text_string, Fibnams[j]) == 0) goto FOUND;
    }

    (nEnt)++;
    strcpy (Fibnams[j], p_rs.var.text_st.text_string);
    j             = (nEnt) - 1;
    Fiblengths[j] = 0.0;

    FOUND:         /*   summarize lengths by code     */

    status =
    om$send ( msg = message ACncpx.ACgive_db_structure
                      (&intmsg, &FootIndex, VR_N_CAB_LENGTH_DB, &p_rs, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();

    Fiblengths[j] += p_rs.var.root_pm_st.value;

#ifdef MY_DEBUG
    printf (" Fiblength %d = %f total %f\n",j,p_rs.var.root_pm_st.value,
                              Fiblengths[j]);
#endif
  }

  /*   summarize connectors/splices     */

  for (i=0; i < nTrac; i++)
  {
#ifdef MY_DEBUG
    printf (" item %d GRID %d %d\n",i,TracTab[i].OutGRid.objid,
                                      TracTab[i].OutGRid.osnum);
#endif
    parentClassId = TracTab[i].ClassId;

    if (om$is_ancestry_valid
         (subclassid = parentClassId,
        superclassid = OPP_VRFiber_class_id) != OM_S_SUCCESS) continue;

    if (om$is_ancestry_valid
         (subclassid = parentClassId,
        superclassid = OPP_VRLink_class_id) != OM_S_SUCCESS) continue;

    status =
    om$send ( msg = message VRFiber.VRFo_GetConn
               (&retmsg, TracTab[i].nCpt, 0, (IGRchar *)TracTab[i].szOutId,
                szAdd, &CType, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();

    /*C   bypass each second splice     */
    if ((CType == VRFO_T_SPLICE) && bFspl)   continue;

    if (szAdd[0] == '\0')
    {
      nUnass++;
      continue;
    }
    /*     add a connector or splice to the output array   */

    if (CType == VRFO_T_SPLICE) bFspl = !bFspl;

    for (j=0; j< nCSP; j++)
    {
      if (strcmp (szAdd, Connams[j]) == 0) goto FNDCON;
    }

    (nCSP)++;
    strcpy (Connams[j], szAdd);
    j             = (nCSP) - 1;
    nQtys[j] = 0;
#ifdef MY_DEBUG
    printf (" New entry %d at %d\n",j,i);
#endif

    FNDCON:
    (nQtys[j])++;
#ifdef MY_DEBUG
    printf (" Add entry at %d\n",j);
#endif
  }

  if (nUnass > 0)
    printf (" Unassigned connectors/splices found, result unreliable\n");

  /*   calculate total attenuation for fibers     */

  for (i=0; i<nEnt; i++)
  {
    IGRint         NbRows;
    IGRchar      **szTabs;
    IGRdouble      dAtt;
    IGRdouble      dThis;

    VREFDB_mkwhere (VRDB_FOCOND_TBNO, Fibnams[i], szWhere);

#ifdef MY_DEBUG
    printf (" TO DB %s %s %s\n",VR_N_ATTENUATION_DB, VRDB_FOCOND_TBL,
                                 szWhere);
#endif

    status = vdb$RisSelect( select     = VR_N_ATTENUATION_DB,
                            table_name = VRDB_FOCOND_TBL,
                            where      = szWhere,
                            numselect  = 1,
                            p_numrows  = &NbRows,
                            p_buffer   = &szTabs);
#ifdef MY_DEBUG
    printf (" From DB NbRows,tab %d %f\n",NbRows, szTabs[0]);
    printf (" From DB NbRows,tab %d %s\n",NbRows, szTabs[0]);
#endif

    sscanf (szTabs[0], "%lf", &dAtt);

    dThis  = Fiblengths[i] * (dAtt);

#ifdef MY_DEBUG
    printf (" Atten fiber %s - %f %f\n",Fibnams[i], dAtt, dThis);
#endif

    if (OutFil)
      fprintf (OutFil," Attenuation fiber     %-15s - %-10f @ %-10f = %-10f\n",
                          Fibnams[i],Fiblengths[i],dAtt,dThis);

    dAtten += dThis;

    VdsRisFreeBuffer (szTabs, NbRows);
    szTabs = NULL;
  }

  /*   calculate total attenuation for connectors/splices   */

  for (i=0; i<nCSP; i++)
  {
    IGRint         NbRows;
    IGRchar      **szTabs;
    IGRdouble      dAtt;
    IGRdouble      dThis;

    VREFDB_mkwhere (VRDB_FOCONN_TBNO, Connams[i], szWhere);

    status = vdb$RisSelect( select     = VR_N_ATTENUATION_DB,
                            table_name = VRDB_FOCONN_TBL,
                            where      = szWhere,
                            numselect  = 1,
                            p_numrows  = &NbRows,
                            p_buffer   = &szTabs);

    sscanf (szTabs[0], "%lf", &dAtt);

    dThis   = nQtys[i] * (dAtt);

#ifdef MY_DEBUG
    printf (" Atten connector %s - %f %f\n",Connams[i], dAtt, dThis);
#endif

    if (OutFil)
      fprintf (OutFil," Attenuation connector %-15s - %-10d @ %-10f = %-10f\n",
                          Connams[i],nQtys[i],dAtt,dThis);

    dAtten += dThis;

    VdsRisFreeBuffer (szTabs, NbRows);
    szTabs = NULL;
  }

  if (OutFil)
  {
    fprintf (OutFil, "\n Total attenuation =                  %f\n", dAtten);
    fprintf (OutFil,
      "-----------------------------------------------------------------\n");
  }
  else
    printf (" Total attenuation = %f\n", dAtten);

  return (0);
}


/*****************************************************************************/

/*       fiber length table                           */

/*****************************************************************************/

int   VR_FoAn_fiblen (IGRlong         *msg,
                      IGRshort         nTrac,
               struct VR_contrace     *TracTab,
                      FILE            *OutFil,
               struct GRmd_env        *md_env)

{
  IGRshort        nPrm, nSec, nIO;
  IGRint          i, j;
  int             FootIndex = -1;
  IGRint          intmsg;
  IGRlong         retmsg;
  IGRlong         status;
  IGRchar         szTmp[50];
  GRclassid       parentClassId;
  VRConstring     Fibnams[10];
  IGRshort        nEnt;
  IGRdouble       Fiblengths[10];

  struct GRid         Last;
  struct ret_struct   p_rs;

  *msg       = MSSUCC;
  status     = OM_S_SUCCESS;
  nEnt       = 0;
  Last.objid = NULL_OBJID;

#ifdef MY_DEBUG
    printf (" Fiblen entry..nTrac = %d..\n",nTrac);
#endif

  for (i=0; i< nTrac; i++)
  {
    if (Last.objid == TracTab[i].OutGRid.objid) continue;

    parentClassId = TracTab[i].ClassId;

    if (om$is_ancestry_valid
           (subclassid = parentClassId,
          superclassid = OPP_VRLink_class_id) != OM_S_SUCCESS)
    {
      Last.objid = NULL_OBJID;
      continue;
    }

    Last.objid = TracTab[i].OutGRid.objid;

    status =
    om$send ( msg = message VRConMgt.VRConGetIdx
                     (&retmsg, TracTab[i].szOutId, &nPrm, &nSec, &nIO, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();

    sprintf (szTmp, VR_N_SNG_INDEX_FMT,VR_N_V_FOPTIC_CODE_AN, nPrm);

    status =
    om$send ( msg = message ACncpx.ACgive_db_structure
                      (&intmsg, &FootIndex, szTmp, &p_rs, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();

#ifdef MY_DEBUG
    printf (" find fibercode for %s = %s\n",szTmp,
                   p_rs.var.text_st.text_string);
#endif

    for (j=0; j< nEnt; j++)
    {
      if (strcmp (p_rs.var.text_st.text_string, Fibnams[j]) == 0) goto FOUND;
    }

    (nEnt)++;
    strcpy (Fibnams[j], p_rs.var.text_st.text_string);
    j             = (nEnt) - 1;
    Fiblengths[j] = 0.0;

    FOUND:         /*   summarize lengths by code     */

    status =
    om$send ( msg = message ACncpx.ACgive_db_structure
                      (&intmsg, &FootIndex, VR_N_CAB_LENGTH_DB, &p_rs, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();

    Fiblengths[j] += p_rs.var.root_pm_st.value;

#ifdef MY_DEBUG
    printf (" Fiblength %d = %f total %f\n",j,p_rs.var.root_pm_st.value,
                              Fiblengths[j]);
#endif
  }

  /*A     Print fiber length summary   */
  if (OutFil)
  {
    fprintf (OutFil,"    Trace Fiber lengths summary\n\n");
    fprintf (OutFil,"      Fiber Type      Length\n\n");

    for (j=0; j<nEnt; j++)
      fprintf (OutFil,"       %s         %f\n",
                                  Fibnams[j],Fiblengths[j]);

    fprintf (OutFil,
        "-----------------------------------------------------------------\n");
  }
  else
  {
    for (j=0; j<nEnt; j++)
      printf (" Trace Fiber lengths %s %f\n",Fibnams[j], Fiblengths[j]);
  }

  return (0);
}


/*****************************************************************************/

/*       cable length report                           */

/*****************************************************************************/

int   VR_FoAn_cablen (IGRlong         *msg,
               struct GRid            *RefId,
                      FILE            *OutFil,
               struct GRmd_env        *md_env)

{
  int             FootIndex = -1;
  IGRint          intmsg;
  IGRlong         status;
  GRclassid       parentClassId;
  IGRshort        nEnt;
  IGRdouble       dCabLen;

  struct ret_struct   p_rs;

  *msg       = MSSUCC;
  status     = OM_S_SUCCESS;
  nEnt       = 0;

  om$get_classid (objid = RefId->objid,
                  osnum = RefId->osnum,
              p_classid = &parentClassId);

  if (om$is_ancestry_valid (
             subclassid   = parentClassId,
             superclassid = OPP_VRLink_class_id) == OM_S_SUCCESS)
  {
    status =
    om$send ( msg = message ACncpx.ACgive_db_structure
                      (&intmsg, &FootIndex, VR_N_CAB_LENGTH_DB, &p_rs, md_env),
         targetid = RefId->objid,
         targetos = RefId->osnum,
         senderid = NULL_OBJID);
    as$status();

    dCabLen = p_rs.var.root_pm_st.value;

    if (OutFil)
    {
      fprintf (OutFil,"    Cable length  %f\n", dCabLen);
      fprintf (OutFil,
      "-----------------------------------------------------------------\n");
    }
    else
    {
      printf (" Cable length %f\n",dCabLen);
    }
  }

  return (0);
}



/*****************************************************************************/

/*       connectors/splices summary cable                       */

/*****************************************************************************/

int   VR_FoAn_cabcsp (IGRlong         *msg,
               struct GRid            *RefId,
                      FILE            *OutFil,
               struct GRmd_env        *md_env)

{
  IGRint       i;
  int          FootIndex = -1;
  IGRint       intmsg;
  IGRlong      retmsg;
  IGRlong      status;
  GRclassid    parentClassId;
  IGRchar      szAdd[13];
  IGRchar      szAdd1[13];
  IGRshort     nEnt;
  IGRint       CType;
  IGRshort     nUnass;
  IGRboolean   bFspl;
  IGRchar      Laytab[1000];
  IGRint       CT1;
  VRConstring *pLay;

  struct ret_struct   tag_rs;

  *msg       = MSSUCC;
  nEnt       = 0;
  bFspl      = FALSE;
  nUnass     = 0;

  om$get_classid (objid = RefId->objid,
                  osnum = RefId->osnum,
              p_classid = &parentClassId);

  if (om$is_ancestry_valid
         (subclassid = parentClassId,
        superclassid = OPP_VRFiber_class_id) != OM_S_SUCCESS)
              return (OM_S_SUCCESS);

  pLay = (VRConstring *) Laytab;

  status =
  om$send (msg = message ACncpx.ACgive_structure
                 (&intmsg, &FootIndex, VR_N_TAG_NUMBER_AN, &tag_rs, md_env),
      targetid = RefId->objid,
      targetos = RefId->osnum,
      senderid = NULL_OBJID);
  as$status();

  if (OutFil)
    fprintf (OutFil,"        Connector/splice report for %s\n\n\n",
                  tag_rs.var.text_st.text_string);
  else
    printf ("Connectors for tag %s\n",
                  tag_rs.var.text_st.text_string);

  status =
  om$send ( msg = message VRConMgt.VRConGetLayo
                   (&retmsg, (IGRshort) 0, &nEnt, Laytab, md_env),
       targetid = RefId->objid,
       targetos = RefId->osnum,
       senderid = NULL_OBJID);
  as$status();

  for (i=0; i<nEnt; i++)
  {
    status =
    om$send ( msg = message VRFiber.VRFo_GetConn
               (&retmsg, (IGRshort) 0, i, NULL, szAdd, &CType, md_env),
         targetid = RefId->objid,
         targetos = RefId->osnum,
         senderid = NULL_OBJID);
    as$status();

    status =
    om$send ( msg = message VRFiber.VRFo_GetConn
               (&retmsg, (IGRshort) 1, i, NULL, szAdd1, &CT1, md_env),
         targetid = RefId->objid,
         targetos = RefId->osnum,
         senderid = NULL_OBJID);
    as$status();

    if (OutFil)
      fprintf (OutFil,"  %s    -%s-    %s\n",szAdd, pLay[i], szAdd1);
    else
      printf ("  %s  %d  -%s- %s %d\n",szAdd, CType,pLay[i], szAdd1, CT1);
  }

  if (OutFil)
    fprintf (OutFil,
      "-----------------------------------------------------------------\n");

  return (0);
}


/*****************************************************************************/

/*       connectors/splices summary trace                        */

/*****************************************************************************/

int   VR_FoAn_fibcsp (IGRlong         *msg,
                      IGRshort         nTrac,
               struct VR_contrace     *TracTab,
                      FILE            *OutFil,
               struct GRmd_env        *md_env)

{
  IGRint       i, j;
  IGRlong      retmsg;
  IGRlong      status;
  GRclassid    parentClassId;
  IGRchar      szAdd[13];
  VRConstring  Connams[10];
  IGRshort     nEnt;
  IGRint       CType;
  IGRshort     nQtys[10];
  IGRshort     nUnass;
  IGRboolean   bFspl;

  *msg       = MSSUCC;
  nEnt       = 0;
  bFspl      = FALSE;
  nUnass     = 0;

  for (i=0; i < nTrac; i++)
  {
#ifdef MY_DEBUG
    printf (" item %d GRID %d %d\n",i,TracTab[i].OutGRid.objid,
                                      TracTab[i].OutGRid.osnum);
#endif
    parentClassId = TracTab[i].ClassId;

    if (om$is_ancestry_valid
         (subclassid = parentClassId,
        superclassid = OPP_VRFiber_class_id) != OM_S_SUCCESS) continue;

    status =
    om$send ( msg = message VRFiber.VRFo_GetConn
               (&retmsg, TracTab[i].nCpt, 0, (IGRchar *)TracTab[i].szOutId,
                szAdd, &CType, md_env),
         targetid = TracTab[i].OutGRid.objid,
         targetos = TracTab[i].OutGRid.osnum,
         senderid = NULL_OBJID);
    as$status();
#ifdef MY_DEBUG
    printf (" link at %d, reset\n",i);
#endif

    /*C   bypass each second splice     */
    if ((CType == VRFO_T_SPLICE) && bFspl)   continue;

    if (szAdd[0] == '\0')
    {
      nUnass++;
      continue;
    }
    /*     add a connector or splice to the output array   */

    if (CType == VRFO_T_SPLICE) bFspl = !bFspl;

    for (j=0; j< nEnt; j++)
    {
      if (strcmp (szAdd, Connams[j]) == 0) goto FOUND;
    }

    (nEnt)++;
    strcpy (Connams[j], szAdd);
    j             = (nEnt) - 1;
    nQtys[j] = 0;
#ifdef MY_DEBUG
    printf (" New entry %d at %d\n",j,i);
#endif

    FOUND:
    (nQtys[j])++;
#ifdef MY_DEBUG
    printf (" Add entry at %d\n",j);
#endif

  }

  if (OutFil)
  {
    fprintf (OutFil,
             "     Fiberoptic Connectors/splices  summary\n\n");
    fprintf (OutFil,
             "              Type            Quantity\n\n");

    for (j=0; j<nEnt; j++)
      fprintf (OutFil,
             "              %s           %d\n",Connams[j], nQtys[j]);

    if (nUnass > 0)
      fprintf (OutFil,"\n  Unassigned connectors %d\n", nUnass);

    fprintf (OutFil,
      "-----------------------------------------------------------------\n");
  }
  else
  {
    for (j=0; j<nEnt; j++)
      printf (" Connector summary %s %d\n",Connams[j], nQtys[j]);
    if (nUnass > 0)
      printf (" Unassigned connectors %d\n", nUnass);
  }

  return (0);
}


/*****************************************************************************/

/*       connectivity report                           */

/*****************************************************************************/

int   VR_FoAn_conrep (IGRlong         *msg,
               struct GRid            *ConnId,
                      FILE            *OutFil,
               struct GRmd_env        *md_env)

{
  IGRint          i;
  int             FootIndex = -1;
  IGRchar         cBuffer[20000];
  VRCondblstr    *pTopo;

  struct GRid     GRidTab[200];
  IGRshort        nTop, nCnd;
  IGRshort        nCpt, nEnd;
  GRclassid       parentClassId;
  VRConstring     Locstr1;
  VRConstring     Locstr2;
  IGRint          intmsg;
  IGRlong         retmsg;
  IGRlong         status;

  struct ret_struct   tag_rs;
  struct ret_struct   eqp_rs;
  struct ret_struct   xtg_rs;

  *msg       = MSSUCC;
  status     = OM_S_SUCCESS;
  eqp_rs.var.text_st.text_string[0] = '\0';

#ifdef MY_DEBUG
  printf (" Enter FoAn_conrep for %d %d\n",ConnId->objid,ConnId->osnum);
#endif

  om$get_classid (objid = ConnId->objid,
                  osnum = ConnId->osnum,
              p_classid = &parentClassId);

  if (om$is_ancestry_valid (
            subclassid   = parentClassId,
            superclassid = OPP_VRLink_class_id) == OM_S_SUCCESS)
  {
    nEnd = 1;
#ifdef MY_DEBUG
    printf (" Connectivity link\n");
#endif
  }
  else
  {
    nEnd = 0;

#ifdef MY_DEBUG
    printf (" Connectivity connector\n");
#endif
    status =
    om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VD_N_EQP_NUMBER_AN, &eqp_rs, md_env),
        senderid = NULL_OBJID,
        targetid = ConnId->objid,
        targetos = ConnId->osnum );
    as$status();
  }

  status =
  om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VR_N_TAG_NUMBER_AN, &tag_rs, md_env),
      senderid = NULL_OBJID,
      targetid = ConnId->objid,
      targetos = ConnId->osnum );
  as$status();

  if (OutFil)
    fprintf (OutFil,"        Connectivity report for %s %s\n\n\n",
                    tag_rs.var.text_st.text_string,
                    eqp_rs.var.text_st.text_string);
  else
    printf ("Connectivity for tag %s %s\n",
                    tag_rs.var.text_st.text_string,
                    eqp_rs.var.text_st.text_string);

  pTopo = (VRCondblstr *) cBuffer;

  for (nCpt = 0; nCpt <= nEnd; nCpt++)
  {
    IGRchar          cBuff[2000];
    struct GRid      CGRid[100];

    status =
    om$send ( msg = message VRConMgt.VRConGetTopo
                         (&retmsg, nCpt, &nTop, cBuffer, GRidTab,
                            &nCnd, cBuff, CGRid, md_env),
         senderid = NULL_OBJID,
         targetid = ConnId->objid,
         targetos = ConnId->osnum );
    as$status();

    for (i=0; i< nTop; i++)
    {
      VR_deconcat_str (pTopo[i], Locstr1, Locstr2);

#ifdef MY_DEBUG
      printf (" CC %s %s <%d>\n", Locstr1, Locstr2,GRidTab[i].objid);
#endif
      xtg_rs.var.text_st.text_string[0] = '\0';

      if (nEnd != 0)
      {
        if (GRidTab[i].objid != NULL_OBJID)
        {
           om$get_classid (objid = GRidTab[i].objid,
                           osnum = GRidTab[i].osnum,
                       p_classid = &parentClassId);
#ifdef MY_DEBUG
           printf (" Added tags for %d\n",parentClassId);
#endif

           if (parentClassId == OPP_VRFoMxConn_class_id)
           {
             status =
             om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VR_N_TAG_NUMBER_AN, &xtg_rs, md_env),
                 senderid = NULL_OBJID,
                 targetid = GRidTab[i].objid,
                 targetos = GRidTab[i].osnum );
             as$status();
           }
           else
           if (parentClassId == OPP_VRConnect_class_id)
           {
             status =
             om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VD_N_EQP_NUMBER_AN, &xtg_rs, md_env),
                 senderid = NULL_OBJID,
                 targetid = GRidTab[i].objid,
                 targetos = GRidTab[i].osnum );
             as$status();
           }
        }
      }

      if (OutFil)
      {
        if (nEnd != 0)
          fprintf (OutFil," Fiber %-10s connected to %-15s %-15s at End %d\n",
                    Locstr1, Locstr2, xtg_rs.var.text_st.text_string, nCpt);
        else
          fprintf (OutFil," %-15s connected to Fiber %-15s\n",
                               Locstr1, Locstr2);
      }
      else
      {
        if (nEnd != 0)
          printf (" %-15s to %-15s  %-15s at %d\n",
                    Locstr1, Locstr2, xtg_rs.var.text_st.text_string, nCpt);
        else
          printf (" %-15s to %-15s  %s \n",
                    Locstr1, Locstr2, xtg_rs.var.text_st.text_string);
      }
    }
  }

  if (OutFil)
    fprintf (OutFil,
        "-----------------------------------------------------------------\n");
  return (0);
}


/*****************************************************************************/

/*       fromto list       */

/*****************************************************************************/

int   VR_FoAn_f2list (IGRlong         *msg,
                      IGRshort         nTrac,
               struct VR_contrace     *TracTab,
                      IGRchar         *szSigId,
                      FILE            *OutFil,
               struct GRmd_env        *md_env)

{
  IGRint          iindex;
  IGRint          iFrom, iTo;
  int             FootIndex = -1;
  IGRint          intmsg;
  IGRlong         status;
  GRclassid       parentClassId;

  struct ret_struct   eqp1_rs;
  struct ret_struct   eqp2_rs;

  /*   fromtolist for element (non trace) is equivalent to
       connections report                                             */

  *msg       = MSSUCC;
  iindex     = 0;

  if (OutFil)
  {
    fprintf (OutFil,
        "        Fromtos report for trace - signal %s\n\n", szSigId);
    fprintf (OutFil,
        "  Fiberid           From                          To\n\n");
  }
  else
    printf (" Fromtos report for signal %s\n",szSigId);

  while (iindex < nTrac)
  {
#ifdef MY_DEBUG
    printf (" item %d GRID %d %d\n",iindex,TracTab[iindex].OutGRid.objid,
                                           TracTab[iindex].OutGRid.osnum);
#endif

    parentClassId = TracTab[iindex].ClassId;

    if (om$is_ancestry_valid
           (subclassid = parentClassId,
          superclassid = OPP_VRLink_class_id) != OM_S_SUCCESS)
    {
      iindex++;
      continue;
    }

    /*   found a fiber, retrieve origin and destination eq tags   */

    iFrom = iindex - 1;
    iTo   = iindex + 2;
    eqp1_rs.var.text_st.text_string[0] = '\0';
    eqp2_rs.var.text_st.text_string[0] = '\0';

    if (iFrom >= 0)
    {
      if (TracTab[iFrom].ClassId == OPP_VRFoMxConn_class_id)
      {
        status =
        om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VR_N_TAG_NUMBER_AN, &eqp1_rs, md_env),
            targetid = TracTab[iFrom].OutGRid.objid,
            targetos = TracTab[iFrom].OutGRid.osnum,
            senderid = NULL_OBJID);
        as$status();

      }
      else
      {
        status =
        om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VD_N_EQP_NUMBER_AN, &eqp1_rs, md_env),
            targetid = TracTab[iFrom].OutGRid.objid,
            targetos = TracTab[iFrom].OutGRid.osnum,
            senderid = NULL_OBJID);
        as$status();
      }
    }

    if (iTo < nTrac)
    {
      if (TracTab[iTo].ClassId == OPP_VRFoMxConn_class_id)
      {
        status =
        om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VR_N_TAG_NUMBER_AN, &eqp2_rs, md_env),
            targetid = TracTab[iTo].OutGRid.objid,
            targetos = TracTab[iTo].OutGRid.osnum,
            senderid = NULL_OBJID);
        as$status();

      }
      else
      {
        status =
        om$send (msg = message ACncpx.ACgive_structure
                   (&intmsg, &FootIndex, VD_N_EQP_NUMBER_AN, &eqp2_rs, md_env),
            targetid = TracTab[iTo].OutGRid.objid,
            targetos = TracTab[iTo].OutGRid.osnum,
            senderid = NULL_OBJID);
        as$status();
      }
    }

    if (eqp1_rs.var.text_st.text_string[0] == '\0')
            strcpy (eqp1_rs.var.text_st.text_string, "    ");
    if (eqp2_rs.var.text_st.text_string[0] == '\0')
            strcpy (eqp2_rs.var.text_st.text_string, "    ");

    if (OutFil)
    {
      fprintf (OutFil,
         " %.15s %.15s %-10s  -- %.15s %-10s\n",
          TracTab[iindex].szOutId,
          TracTab[iFrom].szOutId, eqp1_rs.var.text_st.text_string,
          TracTab[iTo].szOutId,   eqp2_rs.var.text_st.text_string);
    }
    else
    {
      printf (" %.15s %.15s %-10s -- %.15s %-10s\n",
          TracTab[iindex].szOutId,
          TracTab[iFrom].szOutId, eqp1_rs.var.text_st.text_string,
          TracTab[iTo].szOutId,   eqp2_rs.var.text_st.text_string);
    }

    iindex += 2;
  }


  if (OutFil)
    fprintf (OutFil,
        "-----------------------------------------------------------------\n");

  return (0);
}
#endif

end implementation VCCmdAnal;

