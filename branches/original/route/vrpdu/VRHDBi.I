
/* $Id: VRHDBi.I,v 1.2 2001/02/20 01:14:45 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRHDBi.I
 *
 * Description:
 *      interface implementation for HVAC database access
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRHDBi.I,v $
 *        Revision 1.2  2001/02/20 01:14:45  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *        Initial import to CVS
 *
# Revision 1.2  2000/02/08  21:04:28  pinnacle
# added methods to cache the material & insulation table contents
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:35:54  pinnacle
# Created: vrpdu/VRHDBi.I by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        02/08/2000      Alwin     Added methods to cache the 
 *									hvac_material_list and hvac_insul_list 
 *									tables. CR179900696
 *
 *************************************************************************/

class implementation VRHDB;

/*
#define MY_DEBUG
*/

#include        "v_risproto.h"
#include        "vrdbgmacros.h"

extern IGRdouble fabs();

method   HDB_init  (IGRlong      *msg)
{
  SetProc( Md HDB_init ); Begin

  *msg             = MSSUCC;

  me->bDB_open     = FALSE;
  me->bNEW_bend    = FALSE;
  me->bNEW_branch  = FALSE;
  me->bNEW_trans   = FALSE;

  me->dCUR_wid     = 0.0;
  me->dCUR_dep     = 0.0;

  me->nCUR_prj     = VRHDB_UNDEF;
  me->nCUR_spc     = VRHDB_UNDEF;
  me->nCUR_spc_idx = VRHDB_UNDEF;
  me->nCUR_bend    = VRHDB_UNDEF;
  me->nCUR_branch  = VRHDB_UNDEF;
  me->nCUR_trans   = VRHDB_UNDEF;
  me->nCUR_cdl     = VRHDB_UNDEF;

  me->szCUR_mat_spec[0] = '\0'; //added for CR179900696

  om$vla_set_dimension (varray = me->VRct,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRspec,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRcomps,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRbend,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRbranch,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRtrans,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRcdl,
                        size   = 0);

  /* Following added by Alwin for CR179900696 */
  om$vla_set_dimension (varray = me->VRmaterial,
                        size   = 0);

  om$vla_set_dimension (varray = me->VRinsulation,
                        size   = 0);

  End
  return (OM_S_SUCCESS);
}

method   HDB_set   (IGRlong      *msg;
                    IGRshort      nProj;
                    IGRshort      nSpec)
{
  IGRint        status;
  IGRshort      i;
  IGRboolean    bLoad;

  SetProc( Md HDB_set ); Begin

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
    om$send (msg = message VRHDB.HDB_lCT (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    /*  check if new bend/branch tables exist    */

    if (VdsVerifyRisTable (VRDB_HVBENDSEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_bend = TRUE;

    if (VdsVerifyRisTable (VRDB_HVBRANSEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_branch = TRUE;

    if (VdsVerifyRisTable (VRDB_HVTRA1SEL_TBL) == VDS_DBTABLE_FOUND)
      me->bNEW_trans = TRUE;
  }

  /*     make sure we've got a project ....   */

  if (nProj == VRHDB_UNDEF)
  {
    IGRint   iP;
    extern
    IGRint   VdsGetPrjNo();

    iP = VRHDB_UNDEF;

    status = VdsGetPrjNo (&iP);

    nProj = iP;
  }

  if ((nProj != VRHDB_UNDEF) && (nProj != me->nCUR_prj))
  { /*    load project info    */
    me->nCUR_prj = nProj;

    bLoad = TRUE;

    status =
    om$send (msg = message VRHDB.HDB_lPROJ (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    /*   load spec records     */

    status =
    om$send (msg = message VRHDB.HDB_lSPEC (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;
  }

  if ((nSpec != VRHDB_UNDEF) && (nSpec != me->nCUR_spc))
  {
    IGRshort     iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (nSpec == me->VRspec[i].key.class_no)
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
    om$send (msg = message VRHDB.HDB_lCOMP (msg),
        targetid = my_id);

    if (*msg != MSSUCC) goto wrapup;

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_chdir != me->nCUR_bend)
    { /*   load bend table   */
      me->nCUR_bend = me->VRspec[me->nCUR_spc_idx].data.tbl_chdir;

      bLoad = TRUE;

      status =
      om$send (msg = message VRHDB.HDB_lBEND (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_branch != me->nCUR_branch)
    { /*   load branch table   */
      me->nCUR_branch = me->VRspec[me->nCUR_spc_idx].data.tbl_branch;

      bLoad = TRUE;

      status =
      om$send (msg = message VRHDB.HDB_lBRNC (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

    if (me->VRspec[me->nCUR_spc_idx].data.tbl_trans != me->nCUR_trans)
    { /*   load trans table   */
      me->nCUR_trans = me->VRspec[me->nCUR_spc_idx].data.tbl_trans;

      bLoad = TRUE;

      status =
      om$send (msg = message VRHDB.HDB_lTRAN (msg),
          targetid = my_id);

      if (*msg != MSSUCC) goto wrapup;
    }

	/* Update the Material Table list. Alwin */
	/* When the spec changes then change the material list also, so that
	user can pick up the list corresponding to that. */ 
	if( strcmp( me->VRspec[me->nCUR_spc_idx].data.d_matl, me->szCUR_mat_spec ) )
	{
		bLoad = TRUE;

		__DBGpr_str("def. mat. spec",me->VRspec[me->nCUR_spc_idx].data.d_matl );
		__DBGpr_str( " changed spec ", me->szCUR_mat_spec );
		strcpy( me->szCUR_mat_spec, me->VRspec[me->nCUR_spc_idx].data.d_matl);

		status = 
		om$send (msg = message VRHDB.HDB_lMATERIAL (msg),
			targetid = my_id);

		if (*msg != MSSUCC) goto wrapup;
	}
  }

  me->bDB_open = TRUE;

  wrapup:
#ifdef MY_DEBUG
  printf (" HDB SET done Proj %d Spec %d W/h %f %f\n",
                     me->nCUR_prj,me->nCUR_spc,me->dCUR_wid,me->dCUR_dep);
  printf (" HDB SET done trans  %d bend %d branch %d\n",
                     me->nCUR_trans,me->nCUR_bend,me->nCUR_branch);
#endif

  if (bLoad) UI_status (" ");

  End
  return (OM_S_SUCCESS);
}


method   HDB_gprj  (IGRlong         *msg;
                    IGRshort         nProj;
             struct VRHDB_project   *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRHDB.HDB_set (msg, nProj, me->nCUR_spc),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    *Rec = me->VRprj;
  }

  return (OM_S_SUCCESS);
}

method   HDB_act   (IGRshort     *nNum;
             struct VRHDB_ct    **Rec)
{
  *nNum = om$dimension_of (varray = me->VRct);

  if (*nNum == 0) *Rec = NULL;
  else            *Rec = me->VRct;

  return (OM_S_SUCCESS);
}


method   HDB_gct   (IGRlong      *msg;
             struct VRHDB_ct_key *keyin;
                    IGRshort     *nNum;
             struct VRHDB_ct     *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRHDB.HDB_set (msg, me->nCUR_prj, me->nCUR_spc),
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
        if ((keyin->sh_code[0] != '\0') &&
            (strcmp (keyin->sh_code, me->VRct[i].key.sh_code) != 0)) continue;
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

method   HDB_aspec (IGRshort     *nNum;
             struct VRHDB_spec  **Rec)
{
  *nNum = om$dimension_of (varray = me->VRspec);

  if (*nNum == 0) *Rec = NULL;
  else            *Rec = me->VRspec;

  return (OM_S_SUCCESS);
}


method   HDB_gspec (IGRlong        *msg;
                    IGRshort        nProj;
             struct VRHDB_spec_key *keyin;
                    IGRshort       *nNum;
             struct VRHDB_spec     *Rec)
{
  IGRint          status;

  status =
  om$send (msg = message VRHDB.HDB_set (msg,nProj,me->nCUR_spc),
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
        if ((keyin->class_no != VRHDB_UNDEF) &&
            (keyin->class_no != me->VRspec[i].key.class_no)) continue;

        if ((keyin->hvac_class[0] != '\0') &&
            (strcmp (keyin->hvac_class, me->VRspec[i].key.hvac_class) != 0))
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
  printf (" gspec exit\n");
#endif

  return (OM_S_SUCCESS);
}

method   HDB_acmps (IGRshort     *nNum;
             struct VRHDB_comps **Rec)
{
  *nNum = om$dimension_of (varray = me->VRcomps);

  if (*nNum == 0) *Rec = NULL;
  else            *Rec = me->VRcomps;

  return (OM_S_SUCCESS);
}


method   HDB_gcmps (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRHDB_comps_key *keyin;
                    IGRshort        *nNum;
             struct VRHDB_comps     *Rec)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" HDB gcmps\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (msg, nProj, nSpec),
      targetid = my_id);

  *nNum = 0;

#ifdef MY_DEBUG
  if (keyin != NULL)
    printf (" looking for %s %d \n",keyin->comp_code, keyin->shapecode);

#endif

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRcomps);

    for (i=0; i<iBuf; i++)
    {
      if (keyin != NULL)
      {
        if ((keyin->comp_code[0] != '\0') &&
            (strcmp (keyin->comp_code, me->VRcomps[i].key.comp_code) != 0))
                                  continue;

#ifdef MY_DEBUG
         printf (" check: %d %s\n",me->VRcomps[i].key.shapecode,
                                   me->VRcomps[i].key.comp_code);
#endif

        if ((keyin->shapecode != VRHDB_UNDEF) &&
            (keyin->shapecode != me->VRcomps[i].key.shapecode)) continue;
      }

      if (Rec != NULL)
        Rec[*nNum] = me->VRcomps[i];
      (*nNum)++;

      *msg = MSSUCC;
    }
  }

#ifdef MY_DEBUG
  printf (" gcomps exit\n");
#endif
  return (OM_S_SUCCESS);
}


method   HDB_gbend (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid;
                    IGRdouble        dDep;
                    IGRchar         *Code)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" HDB gbend\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (msg, nProj, nSpec),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;
    IGRshort     iAcode;

    *msg = MSFAIL;

    Code[0] = '\0';

    iAcode = VRHDB_ANG_ALL;

    if (dAng < 44.9995)      iAcode = VRHDB_ANG_L45;
    else
    if (dAng < 45.0005)      iAcode = VRHDB_ANG_45;
    else
    if (dAng < 89.9995)      iAcode = VRHDB_ANG_L90;
    else
    if (dAng < 90.0005)      iAcode = VRHDB_ANG_90;

    iBuf = om$dimension_of (varray = me->VRbend);

    for (i=0; i<iBuf; i++)
    {
      if (me->bNEW_bend)
      {
        if (cType != me->VRbend[i].rec.new.ctype)        continue;

        if ((dWid < me->VRbend[i].rec.new.dwlow) ||
            (dWid > me->VRbend[i].rec.new.dwhig))         continue;

        if ((dDep < me->VRbend[i].rec.new.ddlow) ||
            (dDep > me->VRbend[i].rec.new.ddhig))         continue;

        if ((me->VRbend[i].rec.new.ang_code != VRHDB_ANG_ALL) &&
            (me->VRbend[i].rec.new.ang_code != iAcode))             continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbend[i].rec.new.comp_code);
      }
      else
      {
        if (cType != me->VRbend[i].rec.old.ctype)        continue;

        if ((dAng < me->VRbend[i].rec.old.ang_low) ||
            (dAng > me->VRbend[i].rec.old.ang_high))      continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbend[i].rec.old.comp_code);
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   HDB_gbran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRdouble        dAng;
                    IGRshort         cType;
                    IGRdouble        dWid1;
                    IGRdouble        dDep1;
                    IGRdouble        dWid2;
                    IGRdouble        dDep2;
                    IGRchar         *Code)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" HDB gbranch\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (msg, nProj, nSpec),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;
    IGRshort     iAcode;

    *msg = MSFAIL;

    Code[0] = '\0';

    iAcode = VRHDB_ANG_ALL;
    if (dAng < 44.9995)      iAcode = VRHDB_ANG_L45;
    else
    if (dAng < 45.0005)      iAcode = VRHDB_ANG_45;
    else
    if (dAng < 89.9995)      iAcode = VRHDB_ANG_L90;
    else
    if (dAng < 90.0005)      iAcode = VRHDB_ANG_90;

    iBuf = om$dimension_of (varray = me->VRbranch);

    for (i=0; i<iBuf; i++)
    {
      if (me->bNEW_branch)
      {
        if (cType != me->VRbranch[i].rec.new.ctype)        continue;

        if (((dWid1 < me->VRbranch[i].rec.new.dwlow1) &&
             (dWid1 > me->VRbranch[i].rec.new.dwhig1))       ||
            ((dWid2 < me->VRbranch[i].rec.new.dwlow2) &&
             (dWid2 > me->VRbranch[i].rec.new.dwhig2)))           continue;

        if (((dDep1 < me->VRbranch[i].rec.new.ddlow1) &&
             (dDep1 > me->VRbranch[i].rec.new.ddhig1))       ||
            ((dDep2 < me->VRbranch[i].rec.new.ddlow2) &&
             (dDep2 > me->VRbranch[i].rec.new.ddhig2)))           continue;

        if ((me->VRbranch[i].rec.new.ang_code != VRHDB_ANG_ALL) &&
            (me->VRbranch[i].rec.new.ang_code != iAcode))             continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbranch[i].rec.new.comp_code);
        break;
      }
      else
      {
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

method   HDB_gtran (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
                    IGRshort         tType;
                    IGRshort         sCode;
                    IGRdouble        dWid;
                    IGRdouble        dDep;
                    IGRchar         *Code)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" HDB gtrans\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (msg, nProj, nSpec),
      targetid = my_id);

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    Code[0] = '\0';

    iBuf = om$dimension_of (varray = me->VRtrans);

    for (i=0; i<iBuf; i++)
    {
      if (me->bNEW_trans)
      {
        if (tType != me->VRtrans[i].rec.new.transtype)        continue;

        if (sCode != me->VRtrans[i].rec.new.shapecode)        continue;

        if ((dWid < me->VRtrans[i].rec.new.dwlow) &&
            (dWid > me->VRtrans[i].rec.new.dwhig))            continue;

        if ((dDep < me->VRtrans[i].rec.new.ddlow) &&
            (dDep > me->VRtrans[i].rec.new.ddhig))            continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbranch[i].rec.new.comp_code);
        break;
      }
      else
      {
        if (tType != me->VRtrans[i].rec.old.transtype)        continue;

        if (sCode != me->VRtrans[i].rec.old.shapecode)        continue;

        *msg = MSSUCC;
        strcpy (Code, me->VRbranch[i].rec.old.comp_code);
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}

method   HDB_gClist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort         nSpec;
                     IGRshort        *nNum;
              struct VRHDB_comps_key *Comps)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" HDB gClist\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (msg, nProj, nSpec),
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


method   HDB_gSlist (IGRlong         *msg;
                     IGRshort         nProj;
                     IGRshort        *nNum;
              struct VRHDB_spec_key  *Specs)
{
  IGRint          status;

#ifdef MY_DEBUG
  printf (" HDB gSlist\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (msg,nProj,me->nCUR_spc),
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

method   HDB_Stonum (IGRchar         *Spec;
                     IGRshort        *nSpec)
{
  IGRint          status;
  IGRlong         retmsg;

#ifdef MY_DEBUG
  printf (" HDB tonum\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (&retmsg,me->nCUR_prj,me->nCUR_spc),
      targetid = my_id);

  *nSpec  = VRHDB_UNDEF;

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (strcmp (me->VRspec[i].key.hvac_class , Spec) == 0)
      {
        *nSpec = me->VRspec[i].key.class_no;

        /*   force this one to be the current.......... */
        status =
        om$send (msg = message VRHDB.HDB_set (&retmsg,me->nCUR_prj,*nSpec),
            targetid = my_id);

        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method   HDB_Stonam (IGRshort         nSpec;
                     IGRchar         *Spec)
{
  IGRint          status;
  IGRlong         retmsg;

#ifdef MY_DEBUG
  printf (" HDB toname\n");
#endif

  status =
  om$send (msg = message VRHDB.HDB_set (&retmsg,me->nCUR_prj,me->nCUR_spc),
      targetid = my_id);

  Spec[0] = '\0';

  if (retmsg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    iBuf = om$dimension_of (varray = me->VRspec);

    for (i=0; i<iBuf; i++)
    {
      if (me->VRspec[i].key.class_no == nSpec)
      {
        strcpy (Spec, me->VRspec[i].key.hvac_class);
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method  HDB_gCDL   (IGRlong         *msg;
                    IGRshort         nList;
                    IGRshort         nCode;
                    IGRshort        *nNum;
             struct VRHDB_cdl       *Cdl)
{
  IGRint          status;
  IGRlong         retmsg;

  *nNum = 0;

  if (nList != me->nCUR_cdl)
  {
    me->nCUR_cdl = nList;

    status =
    om$send (msg = message VRHDB.HDB_lCDL (&retmsg),
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
      if ((nCode != VRHDB_UNDEF) && (nCode != me->VRcdl[i].ncode)) continue;

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


method  HDB_cdlnum (IGRlong         *msg;
                    IGRshort         nList;
                    IGRchar         *sTxt;
                    IGRshort        *nNum)
{
  IGRint          status;
  IGRlong         retmsg;

  *nNum = VRHDB_UNDEF;

  if (nList != me->nCUR_cdl)
  {
    me->nCUR_cdl = nList;

    status =
    om$send (msg = message VRHDB.HDB_lCDL (&retmsg),
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

/* added by Alwin for CR179900696 */
method   HDB_gmaterial (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         nSpec;
             struct VRHDB_mat_key   *keyin;
                    IGRshort        *nNum;
             struct VRHDB_material  *Rec)
{
  IGRint          status;

  SetProc( HDB_gmaterial ); Begin

  status =
  om$send (msg = message VRHDB.HDB_set (msg, nProj, nSpec),
      targetid = my_id);

  *nNum = 0;

  if (keyin != NULL)
    __DBGpr_str( " Looking for ", keyin->material_class );

  if (*msg == MSSUCC)
  {
    IGRshort     i;
    IGRint       iBuf;

    *msg = MSFAIL;

    iBuf = om$dimension_of (varray = me->VRmaterial);

    for (i=0; i<iBuf; i++)
    {
      if (keyin != NULL)
      {
        if ((keyin->material_class[0] != '\0') &&
			(strcmp( keyin->material_class, 
					 me->VRmaterial[i].key.material_class) != 0))
                                  continue;

         __DBGpr_str( " check ", me->VRmaterial[i].key.material_class );
      }

      if (Rec != NULL)
        Rec[*nNum] = me->VRmaterial[i];
      (*nNum)++;

      *msg = MSSUCC;
    }
  }

  End
  return (OM_S_SUCCESS);
}

method   HDB_ginsulation (IGRlong         *msg;
                    IGRshort         nProj;
                    IGRshort         *nNum;
             struct VRHDB_insulation *Rec)
{
  IGRint          status;

  SetProc( HDB_ginsulation ); Begin

  *nNum = 0;

  {
	  IGRshort     i;
	  IGRint       iBuf=0;

	  *msg = MSFAIL;

	  iBuf = om$dimension_of (varray = me->VRinsulation);

	  if ( iBuf == 0 )
	  {
		/* Fetch it from the Database */
		status = om$send( msg = message VRHDB.HDB_lINSULATION( msg ),
							targetid = my_id );

	  }

	  /* Get the number of records in the table */
	  *nNum = om$dimension_of (varray = me->VRinsulation);

	  if (Rec != NULL)
	  {
		  for( i=0; i<(*nNum); i++ )
			Rec[i] = me->VRinsulation[i];
	  }
  }

  End
  return (OM_S_SUCCESS);
}

method   HDB_amaterial (IGRshort     *nNum;
             			struct VRHDB_material **Rec)
{
  *nNum = om$dimension_of (varray = me->VRmaterial);

  if (*nNum == 0) *Rec = NULL;
  else            *Rec = me->VRmaterial;

  return (OM_S_SUCCESS);
}

method   HDB_ainsulation (IGRshort     *nNum;
						  struct VRHDB_insulation **Rec)
{
  *nNum = om$dimension_of (varray = me->VRinsulation);

  if (*nNum == 0) *Rec = NULL;
  else            *Rec = me->VRinsulation;

  return (OM_S_SUCCESS);
}

end implementation VRHDB;
