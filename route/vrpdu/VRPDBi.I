
/* $Id: VRPDBi.I,v 1.4 2002/04/10 19:55:18 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRPDBi.I
 *
 * Description:
 *      interface implementation for PIPING database access
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRPDBi.I,v $
 *        Revision 1.4  2002/04/10 19:55:18  louis
 *        TR5649-standardize tolerances
 *
 *        Revision 1.3  2001/02/20 01:14:51  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/12 23:22:24  anand
 *        SP merge
 *
# Revision 1.1  2000/08/01  14:25:14  pinnacle
# Created: route/vrpdu/VRPDBi.I by apazhani for Service Pack
#
# Revision 1.3  1999/05/05  13:00:14  pinnacle
# Replaced: vrpdu/VRPDBi.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:38:02  pinnacle
# Created: vrpdu/VRPDBi.I by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *      05/04/99    Reddy       Doble value comparision corrected
 *      08/01/00    Alwin       TR179901831 Modified PDB_gcmps method.
 *				Corrected the way diameter are checked with 
 *				diameter ranges. 
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

class implementation VRPDB;

/*
#define MY_DEBUG
*/

#include <math.h>
#include "VRMath.h"
#include        "v_risproto.h"
#include	"vrdbgmacros.h"
#include	"bsparameters.h"

extern IGRdouble fabs();

method   PDB_init  (IGRlong      *msg)
{
  *msg             = MSSUCC;

  me->bDB_open     = FALSE;
  me->bNEW_bend    = FALSE;
  me->bNEW_branch  = FALSE;

  me->dCUR_dia     = 0.0;
  me->dAL1_dia     = 0.0;
  me->dAL2_dia     = 0.0;

  me->nLST_dia     = VRPDB_UNDEF;

  me->nCUR_prj     = VRPDB_UNDEF;
  me->nCUR_spc     = VRPDB_UNDEF;
  me->nCUR_spc_idx = VRPDB_UNDEF;
  me->nCUR_npd     = VRPDB_UNDEF;
  me->nCUR_npdb    = VRPDB_UNDEF;
  me->nCUR_bend    = VRPDB_UNDEF;
  me->nCUR_branch  = VRPDB_UNDEF;
  me->nCUR_cdl     = VRPDB_UNDEF;

  om$vla_set_dimension (varray = me->VRsch,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRct,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRcomm,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRaltcomm,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRnpd,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRnpdbase,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRspec,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRcomps,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRbend,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRbranch,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRcdl,
                        size   = 0);

#ifdef MY_DEBUG
  printf (" PDB INIT\n");
#endif

  return (OM_S_SUCCESS);
}


method   PDB_set   (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec;
                    IGRdouble     dDia)
{
  IGRint        status;
  IGRshort      i;
  IGRboolean    bLoad;

  bLoad = FALSE;

  if (VDSverify_login() != PDM_S_SUCCESS)
  { /*   not currently logged in, init and terminate   */
    /*   clear caches if I was previously opened       */

    if (me->bDB_open)   VR_DbC_Clear();

    *msg = MSFAIL;

    goto wrapup;
  }

  *msg = MSSUCC;

  if (!(me->bDB_open))
  { /*   load components type table             */
    bLoad = TRUE;

    status =
    om$send (msg = message VRPDB.PDB_lCT (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    /*  check if new bend/branch tables exist    */

    if (VdsVerifyRisTable (VRDB_PIPBENDSEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_bend = TRUE;

    if (VdsVerifyRisTable (VRDB_PIPBRANSEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_branch = TRUE;
  }

  /*     make sure we've got a project ....   */

  if (nProj == VRPDB_UNDEF)
  {
    IGRint   iP;
    extern
    IGRint   VdsGetPrjNo();

    iP = VRPDB_UNDEF;

    status = VdsGetPrjNo (&iP);

    nProj = iP;
  }

  if ((nProj != VRPDB_UNDEF) && (nProj != me->nCUR_prj))
  { /*    load project info    */
    me->nCUR_prj = nProj;

    bLoad = TRUE;

    status =
    om$send (msg = message VRPDB.PDB_lPROJ (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    /*   load spec records     */

    status =
    om$send (msg = message VRPDB.PDB_lSPEC (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    if (me->VRprj.npd_tbl != me->nCUR_npdb)
    { /*   load npd base table             */
      me->nCUR_npdb = me->VRprj.npd_tbl;

      bLoad = TRUE;

      status =
      om$send (msg = message VRPDB.PDB_lNPDB (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

  }

  if ((nSpec != VRPDB_UNDEF) && (nSpec != me->nCUR_spc))
  {
    IGRshort     iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (nSpec == me->VRspec[i].key.spec_no)
      {
        me->nCUR_spc_idx = i;
        goto CONT;
      }
    }

    *msg = MSFAIL;    /*   unknown spec number   */
    goto wrapup;

    CONT:

    /*   load spec components list   */

    me->nCUR_spc = nSpec;

    bLoad = TRUE;

    status =
    om$send (msg = message VRPDB.PDB_lCOMP (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_chdir != me->nCUR_bend)
    { /*   load bend table   */
      me->nCUR_bend = me->VRspec[me->nCUR_spc_idx].data.tbl_chdir;

      bLoad = TRUE;

      status =
      om$send (msg = message VRPDB.PDB_lBEND (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_branch != me->nCUR_branch)
    { /*   load branch table   */
      me->nCUR_branch = me->VRspec[me->nCUR_spc_idx].data.tbl_branch;

      bLoad = TRUE;

      status =
      om$send (msg = message VRPDB.PDB_lBRNC (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_npd != me->nCUR_npd)
    { /*   load npd table   */
      me->nCUR_npd = me->VRspec[me->nCUR_spc_idx].data.tbl_npd;

      bLoad = TRUE;

      status =
      om$send (msg = message VRPDB.PDB_lNPD (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }
  }

  if ((dDia > 0.0) && (dDia != me->dAL1_dia) && (dDia != me->dAL2_dia))
  {
    bLoad = TRUE;

    if (me->nLST_dia == 0)
    { /*  first buff was most recently used, load in alt  */
      me->nLST_dia = 1;
      me->dAL2_dia = dDia;
    }
    else
    { /*  second buff was most recently used or first is empty   */
      /*  load in primary                                        */
      me->nLST_dia = 0;
      me->dAL1_dia = dDia;
    }

    status =
    om$send (msg = message VRPDB.PDB_lCOMM (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;
  }

  if ((dDia > 0.0) && (dDia != me->dCUR_dia))
  { /*   load schedule translation table   */
    me->dCUR_dia = dDia;

    bLoad = TRUE;

    status =
    om$send (msg = message VRPDB.PDB_lSCH (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;
  }

  me->bDB_open = TRUE;

  wrapup:
#ifdef MY_DEBUG
  printf (" PDB SET done Proj %d Spec %d Dia %f\n",
                            me->nCUR_prj,me->nCUR_spc,me->dCUR_dia);
  printf (" PDB SET done npd  %d npdb %d bend %d branch %d\n",
                     me->nCUR_npd,me->nCUR_npdb,me->nCUR_bend,me->nCUR_branch);
#endif

  if (bLoad) UI_status (" ");

  return (OM_S_SUCCESS);
}


method   PDB_gprj  (IGRlong         *msg;
                    IGRshort         nProj;
             struct VRPDB_project   *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRPDB.PDB_set
                        (msg, nProj, me->nCUR_spc, me->dCUR_dia),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    *Rec = me->VRprj;
  }

  return (OM_S_SUCCESS);
}

method   PDB_anpd  (IGRshort     *nNum;
             struct VRPDB_npd   **Rec)
{
  *nNum = om$dimension_of (varray = me->VRnpd);

  if (*nNum == 0)  *Rec = NULL;
  else             *Rec = me->VRnpd;

  return (OM_S_SUCCESS);
}

method   PDB_gnpd  (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec;
                    IGRshort     *nNum;
             struct VRPDB_npd    *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRPDB.PDB_set (msg, nProj, nSpec, me->dCUR_dia),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRnpd);

    for (i=0; i<iBuf; i++)
    {
      if (Rec != NULL)
        Rec[i] = me->VRnpd[i];
    }

    *nNum = iBuf;
  }

#ifdef MY_DEBUG
  printf (" gnpd exit\n");
#endif
  return (OM_S_SUCCESS);
}

method   PDB_abnpd  (IGRshort     *nNum;
              struct VRPDB_npd   **Rec)
{
  *nNum = om$dimension_of (varray = me->VRnpdbase);

  if (*nNum == 0)  *Rec = NULL;
  else             *Rec = me->VRnpdbase;

  return (OM_S_SUCCESS);
}

method   PDB_gbnpd (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort     *nNum;
             struct VRPDB_npd    *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRPDB.PDB_set
                          (msg, nProj, me->nCUR_spc, me->dCUR_dia),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRnpdbase);

    for (i=0; i<iBuf; i++)
    {
      if (Rec != NULL)
        Rec[i] = me->VRnpdbase[i];
    }

    *nNum = iBuf;
  }

#ifdef MY_DEBUG
  printf (" gnpd exit\n");
#endif
  return (OM_S_SUCCESS);
}


method   PDB_asch   (IGRshort         *nNum;
              struct VRPDB_sch_thk   **Rec)
{
  *nNum = om$dimension_of (varray = me->VRsch);

  if (*nNum == 0)  *Rec = NULL;
  else             *Rec = me->VRsch;

  return (OM_S_SUCCESS);
}

method   PDB_gsch  (IGRlong      *msg;
                    IGRshort      nEnd;
                    IGRshort      nGen;
                    IGRdouble     dDia;
                    IGRchar      *Sched;
                    IGRdouble    *dThk;
                    IGRshort     *nUnits)
{
  IGRint          status;

  status =
  om$send (msg = message VRPDB.PDB_set
                           (msg, me->nCUR_prj, me->nCUR_spc, dDia),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRsch);

    for (i=0; i<iBuf; i++)
    {
      if (strcmp (Sched, me->VRsch[i].sched) == 0)
      {
        *dThk = me->VRsch[i].thick;
        *nUnits = me->VRsch[i].thk_units;

        *msg = MSSUCC;
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   PDB_gcomm (IGRlong      *msg;
                    IGRchar      *si_comm;
                    IGRdouble     dia1;
                    IGRdouble     dia2;
                    IGRchar      *s_t1;
                    IGRchar      *s_t2;
                    IGRchar      *pdm_part)
{
  IGRint          status;
  IGRchar         zsT1[VRPDB_CHAR_SCHED];
  IGRchar         zsT2[VRPDB_CHAR_SCHED];

  strcpy (zsT1, s_t1);
  strcpy (zsT2, s_t2);

  if (zsT1[0] == ' ') zsT1[0] = '\0';
  if (zsT2[0] == ' ') zsT2[0] = '\0';

  pdm_part[0] = '\0';

  status =
  om$send (msg = message VRPDB.PDB_set (msg, me->nCUR_prj, me->nCUR_spc, dia1),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    /*BILLA  Double value comparison problem */
    if (fabs(dia1 - me->dAL1_dia) < VRGetTol(VR_DIST_TOL) )
    {
      iBuf = om$dimension_of (varray = me->VRcomm);

      for (i=0; i<iBuf; i++)
      {
        if (strcmp (me->VRcomm[i].si_comm_code, si_comm) != 0)   continue;

#ifdef MY_DEBUG
        printf (" checked  %f %f %s %s\n",
                  me->VRcomm[i].dia1, me->VRcomm[i].dia2,
                  me->VRcomm[i].sch_t_g, me->VRcomm[i].sch_t_r);
#endif
        if (fabs (dia1 - me->VRcomm[i].dia1) > VRGetTol(VR_DIST_TOL)) continue;
        if (fabs (dia2 - me->VRcomm[i].dia2) > VRGetTol(VR_DIST_TOL)) continue;

#ifdef MY_DEBUG
        printf (" dia match found\n");
#endif

        if (strcmp (zsT1, me->VRcomm[i].sch_t_g) != 0) continue;
        if (strcmp (zsT2, me->VRcomm[i].sch_t_r) != 0) continue;

        strcpy (pdm_part, me->VRcomm[i].pdm_part);

#ifdef MY_DEBUG
        printf (" found it, %s \n",pdm_part);
#endif

        me->nLST_dia = 0;
        *msg = MSSUCC;
        break;
      }
    }
    else
    {
      iBuf = om$dimension_of (varray = me->VRaltcomm);

      for (i=0; i<iBuf; i++)
      {
        if (strcmp (me->VRaltcomm[i].si_comm_code, si_comm) != 0)   continue;

#ifdef MY_DEBUG
        printf (" checked  %f %f %s %s\n",
                  me->VRaltcomm[i].dia1, me->VRaltcomm[i].dia2,
                  me->VRaltcomm[i].sch_t_g, me->VRaltcomm[i].sch_t_r);
#endif
        if (fabs (dia1 - me->VRaltcomm[i].dia1) > VRGetTol(VR_DIST_TOL)) continue;
        if (fabs (dia2 - me->VRaltcomm[i].dia2) > VRGetTol(VR_DIST_TOL)) continue;

#ifdef MY_DEBUG
        printf (" dia match found\n");
#endif

        if (strcmp (zsT1, me->VRaltcomm[i].sch_t_g) != 0) continue;
        if (strcmp (zsT2, me->VRaltcomm[i].sch_t_r) != 0) continue;

        strcpy (pdm_part, me->VRaltcomm[i].pdm_part);

#ifdef MY_DEBUG
        printf (" found it, %s \n",pdm_part);
#endif
        me->nLST_dia = 1;
        *msg = MSSUCC;
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}

method   PDB_act   (IGRshort     *nNum;
             struct VRPDB_ct    **Rec)
{
  *nNum = om$dimension_of (varray = me->VRct);

  if (*nNum == 0)  *Rec = NULL;
  else             *Rec = me->VRct;

  return (OM_S_SUCCESS);
}

method   PDB_gct   (IGRlong      *msg;
             struct VRPDB_ct_key *keyin;
                    IGRshort     *nNum;
             struct VRPDB_ct     *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRPDB.PDB_set
                           (msg, me->nCUR_prj, me->nCUR_spc, me->dCUR_dia),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRct);

    for (i=0; i<iBuf; i++)
    {
      if (keyin != NULL)
      {
        if (strcmp (keyin->comp_code, me->VRct[i].key.comp_code) != 0) continue;
        if (strcmp (keyin->sh_code, me->VRct[i].key.sh_code) != 0) continue;
      }

      if (Rec != NULL)
        Rec[*nNum] = me->VRct[i];
      (*nNum)++;

      *msg = MSSUCC;

      if (keyin != NULL) break;
    }
  }

  return (OM_S_SUCCESS);
}

method   PDB_aspec (IGRshort     *nNum;
             struct VRPDB_spec  **Rec)
{
  *nNum = om$dimension_of (varray = me->VRspec);

  if (*nNum == 0)  *Rec = NULL;
  else             *Rec = me->VRspec;

  return (OM_S_SUCCESS);
}

method   PDB_gspec (IGRlong        *msg;
                    IGRshort        nProj;
             struct VRPDB_spec_key *keyin;
                    IGRshort       *nNum;
             struct VRPDB_spec     *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRPDB.PDB_set (msg,nProj,me->nCUR_spc,me->dCUR_dia),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (keyin != NULL)
      {
        if ((keyin->spec_no != VRPDB_UNDEF) &&
            (keyin->spec_no != me->VRspec[i].key.spec_no)) continue;

        if ((keyin->spec_name[0] != '\0') &&
            (strcmp (keyin->spec_name, me->VRspec[i].key.spec_name) != 0))
                                  continue;
      }

      if (Rec != NULL)
        Rec[*nNum] = me->VRspec[i];
      (*nNum)++;

      *msg = MSSUCC;
      if (keyin != NULL) break;
    }
  }

#ifdef MY_DEBUG
  printf (" gspec exit\n");
#endif
  return (OM_S_SUCCESS);
}

method   PDB_acmps (IGRshort     *nNum;
             struct VRPDB_comps **Rec)
{
  *nNum = om$dimension_of (varray = me->VRcomps);

  if (*nNum == 0)  *Rec = NULL;
  else             *Rec = me->VRcomps;

  return (OM_S_SUCCESS);
}


method   PDB_gcmps (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRPDB_comps_key *keyin;
                    IGRdouble        dia1;
                    IGRdouble        dia2;
                    IGRshort        *nNum;
             struct VRPDB_comps     *Rec)
{
  IGRint          status;

  SetProc( Md PDB_gcmps ); Begin 

  status =
  om$send (msg = message VRPDB.PDB_set (msg, nProj, nSpec, me->dCUR_dia),
      targetid = my_id);

  *nNum = 0;

#ifdef vdsDEBUG
  if (keyin != NULL)
    printf (" looking for %s %d %f %f\n",keyin->comp_code, keyin->option,
                             dia1, dia2);

#endif

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRcomps);
    __DBGpr_int( " No. of rows found in cache ", iBuf );

    for (i=0; i<iBuf; i++)
    {
      if (keyin != NULL)
      {
        if ((keyin->comp_code[0] != '\0') &&
            (strcmp (keyin->comp_code, me->VRcomps[i].key.comp_code) != 0))
                                  continue;

#ifdef vdsDEBUG
         printf (" check: %d %s\n",me->VRcomps[i].key.option,
                                   me->VRcomps[i].key.comp_code);
#endif

        if ((keyin->option != VRPDB_UNDEF) &&
            (keyin->option != me->VRcomps[i].key.option)) continue;
      }
#ifdef vdsDEBUG
        printf (" G-low = %f : G-high = %f : R-low = %f : R-high = %f\n",
                         me->VRcomps[i].dia.dia1_l,
                         me->VRcomps[i].dia.dia1_h,
                         me->VRcomps[i].dia.dia2_l,
                         me->VRcomps[i].dia.dia2_h );
#endif

      /*
       * 	Green End:	dia1_h >= dia1 >- dia1_l
       *	Red End:	dia2_h >= dia2 >= dia2_l
       *
       * The earlier condition looked correct for some cases it wouldn't
       * fetch the correct result, hence this change. Now it works fine
       * with out any problem. Alwin For TR179901831
       */
      {
	 IGRdouble	dInputDia, dOutputDia;
	 IGRdouble	npd_g_low, npd_g_high;
	 IGRdouble	npd_r_low, npd_r_high;

	 dInputDia = dia1;
	 dOutputDia = dia2;

	 npd_g_low = me->VRcomps[i].dia.dia1_l;
	 npd_g_high = me->VRcomps[i].dia.dia1_h;

	 npd_r_low = me->VRcomps[i].dia.dia2_l;
	 npd_r_high = me->VRcomps[i].dia.dia2_h;

	 if( 
	   (  ( fabs( dInputDia - npd_g_high ) < VRGetTol(VR_DIST_TOL) ) ||
	      ( dInputDia < npd_g_high )        ) &&
	   (  ( fabs( dInputDia - npd_g_low ) < VRGetTol(VR_DIST_TOL) ) ||
	      ( npd_g_low < dInputDia )        ) &&
	   (  ( fabs( dOutputDia - npd_r_high ) < VRGetTol(VR_DIST_TOL) ) ||
	      ( dOutputDia < npd_r_high )        ) &&
	   (  ( fabs( dOutputDia - npd_r_low ) < VRGetTol(VR_DIST_TOL) ) ||
	      ( npd_r_low < dOutputDia )        )
	  )
	  {
	    if (Rec != NULL)
	      Rec[*nNum] = me->VRcomps[i];
	    (*nNum)++;

	    *msg = MSSUCC;
	  }
      }
    }
  }

  End
  return (OM_S_SUCCESS);
}


method   PDB_gbend (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         rCode;
                    IGRdouble        dDia;
                    IGRchar         *Code)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" PDB gbend\n");
#endif

  status =
  om$send (msg = message VRPDB.PDB_set (msg, nProj, nSpec, me->dCUR_dia),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;
    IGRshort     iAcode;

    *msg = MSFAIL;

    Code[0] = '\0';

    iAcode = VRPDB_ANG_ALL;

    if (dAng < 44.9995)      iAcode = VRPDB_ANG_L45;
    else
    if (dAng < 45.0005)      iAcode = VRPDB_ANG_45;
    else
    if (dAng < 89.9995)      iAcode = VRPDB_ANG_L90;
    else
    if (dAng < 90.0005)      iAcode = VRPDB_ANG_90;

    iBuf = om$dimension_of (varray = me->VRbend);

    for (i=0; i<iBuf; i++)
    {
      if (me->bNEW_bend)
      {
        if ((dDia < me->VRbend[i].rec.new.npd1) ||
            (dDia > me->VRbend[i].rec.new.npd2))         continue;

        if ((me->VRbend[i].rec.new.ang_code != VRPDB_ANG_ALL) &&
            (me->VRbend[i].rec.new.ang_code != iAcode))             continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbend[i].rec.new.comp_code);

        if (rCode == me->VRbend[i].rec.new.type) break;
      }
      else
      {

        if ((dAng < me->VRbend[i].rec.old.ang_low) ||
            (dAng > me->VRbend[i].rec.old.ang_high))      continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbend[i].rec.old.comp_code);

        if (rCode == me->VRbend[i].rec.old.type) break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   PDB_gbran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRdouble        dDia1;
                    IGRdouble        dDia2;
                    IGRchar         *Code)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" PDB gbranch\n");
#endif

  status =
  om$send (msg = message VRPDB.PDB_set (msg, nProj, nSpec, me->dCUR_dia),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;
    IGRshort     iAcode;

    *msg = MSFAIL;

    Code[0] = '\0';

    iAcode = VRPDB_ANG_ALL;
    if (dAng < 44.9995)      iAcode = VRPDB_ANG_L45;
    else
    if (dAng < 45.0005)      iAcode = VRPDB_ANG_45;
    else
    if (dAng < 89.9995)      iAcode = VRPDB_ANG_L90;
    else
    if (dAng < 90.0005)      iAcode = VRPDB_ANG_90;

    iBuf = om$dimension_of (varray = me->VRbranch);

    for (i=0; i<iBuf; i++)
    {
      if (me->bNEW_branch)
      {
        if (((dDia1 < me->VRbranch[i].rec.new.dia.dia1_l) &&
             (dDia1 > me->VRbranch[i].rec.new.dia.dia1_h))       ||
            ((dDia2 < me->VRbranch[i].rec.new.dia.dia2_l) &&
             (dDia2 > me->VRbranch[i].rec.new.dia.dia2_h)))           continue;

        if ((me->VRbranch[i].rec.new.ang_code != VRPDB_ANG_ALL) &&
            (me->VRbranch[i].rec.new.ang_code != iAcode))             continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbranch[i].rec.new.comp_code);
        break;
      }
      else
      {
        if ((fabs (me->VRbranch[i].rec.old.npd_high - dDia1) > VRGetTol(VR_DIST_TOL)) ||
            (fabs (me->VRbranch[i].rec.old.npd_low  - dDia2) > VRGetTol(VR_DIST_TOL))) continue;

        if ((dAng < me->VRbranch[i].rec.old.ang_low) ||
            (dAng > me->VRbranch[i].rec.old.ang_high))      continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbranch[i].rec.old.comp_code);
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   PDB_gClist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort         nSpec;
                     IGRshort        *nNum;
              struct VRPDB_comps_key *Comps)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" PDB gClist\n");
#endif

  status =
  om$send (msg = message VRPDB.PDB_set (msg, nProj, nSpec, me->dCUR_dia),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRcomps);

    if (Comps != NULL)
    for (i=0; i<iBuf; i++)
    {
      Comps[i] = me->VRcomps[i].key;
    }

    *nNum = iBuf;
  }

  return (OM_S_SUCCESS);
}


method   PDB_gSlist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort        *nNum;
              struct VRPDB_spec_key  *Specs)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" PDB gSlist\n");
#endif

  status =
  om$send (msg = message VRPDB.PDB_set (msg,nProj,me->nCUR_spc,me->dCUR_dia),
      targetid = my_id);

  *nNum = 0;

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    if (Specs != NULL)
    for (i=0; i<iBuf; i++)
    {
      Specs[i] = me->VRspec[i].key;
    }

    *nNum = iBuf;
  }

  return (OM_S_SUCCESS);
}

method   PDB_Stonum (IGRchar         *Spec;
                     IGRshort        *nSpec)
{
  IGRint          status;
  IGRlong         retmsg;

#ifdef MY_DEBUG
  printf (" PDB tonum\n");
#endif

  status =
  om$send (msg = message VRPDB.PDB_set
                         (&retmsg,me->nCUR_prj,me->nCUR_spc,me->dCUR_dia),
      targetid = my_id);

  *nSpec  = VRPDB_UNDEF;

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (strcmp (me->VRspec[i].key.spec_name , Spec) == 0)
      {
        *nSpec = me->VRspec[i].key.spec_no;

        /*   force this one to be the current.......... */
        status =
        om$send (msg = message VRPDB.PDB_set
                         (&retmsg,me->nCUR_prj,*nSpec,me->dCUR_dia),
            targetid = my_id);

        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   PDB_Stonam (IGRshort         nSpec;
                     IGRchar         *Spec)
{
  IGRint          status;
  IGRlong         retmsg;

#ifdef MY_DEBUG
  printf (" PDB toname\n");
#endif

  status =
  om$send (msg = message VRPDB.PDB_set
                         (&retmsg,me->nCUR_prj,me->nCUR_spc,me->dCUR_dia),
      targetid = my_id);

  Spec[0] = '\0';

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (me->VRspec[i].key.spec_no == nSpec)
      {
        strcpy (Spec, me->VRspec[i].key.spec_name);
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method  PDB_gCDL   (IGRlong         *msg;
                    IGRshort         nList;
                    IGRshort         nCode;
                    IGRshort        *nNum;
             struct VRPDB_cdl       *Cdl)
{
  IGRint          status;
  IGRlong         retmsg;

  *nNum = 0;

  if (nList != me->nCUR_cdl)
  {
    me->nCUR_cdl = nList;

    status =
    om$send (msg = message VRPDB.PDB_lCDL (&retmsg),
      targetid = my_id);
  }
  else
    retmsg = MSSUCC;

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRcdl);

    for (i=0; i<iBuf; i++)
    {
      if ((nCode != VRPDB_UNDEF) && (nCode != me->VRcdl[i].ncode)) continue;

      if (Cdl != NULL)
        Cdl[*nNum] = me->VRcdl[i];

      (*nNum)++;
      *msg  = MSSUCC;
    }
  }
  else
    *msg = retmsg;

  return (OM_S_SUCCESS);
}


method  PDB_cdlnum (IGRlong         *msg;
                    IGRshort         nList;
                    IGRchar         *sTxt;
                    IGRshort        *nNum)
{
  IGRint          status;
  IGRlong         retmsg;

  *nNum = VRPDB_UNDEF;

  if (nList != me->nCUR_cdl)
  {
    me->nCUR_cdl = nList;

    status =
    om$send (msg = message VRPDB.PDB_lCDL (&retmsg),
      targetid = my_id);
  }
  else
    retmsg = MSSUCC;

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRcdl);

    for (i=0; i<iBuf; i++)
    {
      if (strcmp (sTxt, me->VRcdl[i].stxt) == 0)
      {
        *nNum = me->VRcdl[i].ncode;
        *msg  = MSSUCC;
        break;
      }
    }
  }
  else
    *msg = retmsg;

  return (OM_S_SUCCESS);
}


end implementation VRPDB;

