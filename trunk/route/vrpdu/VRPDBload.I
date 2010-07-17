
/* $Id: VRPDBload.I,v 1.2 2001/02/20 01:14:53 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRPDBload.I
 *
 * Description:
 *      interface implementation for PIPING database access
 *        (private DB cacheload methods)
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRPDBload.I,v $
 *        Revision 1.2  2001/02/20 01:14:53  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/02/26  20:04:52  pinnacle
# Replaced: vrpdu/VRPDBload.I for:  by kddinov for route
#
# Revision 1.1  1997/08/15  19:38:24  pinnacle
# Created: vrpdu/VRPDBload.I by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *	 Feb-98		KDD	RisSelect failure fixed for VRDB_PIPPROJ_TBL.
 *
 *************************************************************************/

class implementation VRPDB;

extern IGRdouble   fabs();

/*
#define MY_DEBUG 	1
#define vdsDEBUG	1
*/

#include "vrdbgmacros.h"
#include "vdreporterr.h"


extern
IGRint   VRPDB_error (IGRchar    *tabnam)
{
  printf (" VRPDB error reading table %s -- disregarded\n", tabnam);

  return (0);
}


method   PDB_lNPD  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_PIPNPDALL_TBL, me->nCUR_npd);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 3;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRnpd,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_PIPNPDALL_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "tblno = %d",me->nCUR_npd);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPNPDALL_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRnpd,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      me->VRnpd[i].npd    = VRDBdbl (DbIO[i*Num + 1]);
      me->VRnpd[i].npd_eq = VRDBdbl (DbIO[i*Num + 2]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPNPDALL_TBL,szWhere,NbRow);
#endif
  }

  if (DbIO != NULL) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   PDB_lNPDB (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

SetProc(PDB_lNPDB); Begin 

  sprintf (szStat,"Loading %s - %d",VRDB_PIPNPDALL_TBL, me->nCUR_npdb);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 3;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRnpdbase,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_PIPNPDALL_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "tblno = %d",me->nCUR_npdb);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPNPDALL_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRnpdbase,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      me->VRnpdbase[i].npd    = VRDBdbl (DbIO[i*Num + 1]);
      me->VRnpdbase[i].npd_eq = VRDBdbl (DbIO[i*Num + 2]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPNPDALL_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO) VdsRisFreeBuffer (DbIO, NbRow);

End
  return (OM_S_SUCCESS);
}

method   PDB_lPROJ  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow=0;
  IGRint         Num;
  IGRint         VdsUnits;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

SetProc(PDB_lPROJ); Begin

  sprintf (szStat,"Loading %s - %d",VRDB_PIPPROJ_TBL, me->nCUR_prj);
  UI_status (szStat);

  *msg = MSSUCC;
  DbIO = NULL;
  Num  = 4;

  if (VdsVerifyRisTable (VRDB_PIPPROJ_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "prj_no = %d",me->nCUR_prj);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPPROJ_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

/* KDD 2-98 NbRow check + else option */

  if ( (status & OM_S_SUCCESS) && (NbRow > 0) )
  {
    me->VRprj.npd_tbl    = VRDBint (DbIO[2]);
    me->VRprj.npd_eqflag = VRDBint (DbIO[3]);

    VRDBstr (me->VRprj.prj_name, DbIO[1]);
  }
  else {
    char	text[256];
    sprintf(text,"vds$RisSelect failed for\n\tSELECT %s\n\tFROM %s\n\tWHERE %s",
			VRDB_PIPPROJ_TBL, VRPDB_SELECT, szWhere); 

    vd$report_error( mode = VD_UNIX_WINDOW, error = text);

    me->VRprj.npd_tbl    = 0;
    me->VRprj.npd_eqflag = 0;
    strcpy( me->VRprj.prj_name, ""); 
  }

    me->VRprj.prj_no     = me->nCUR_prj;
    VdsGetProjectUnits (&VdsUnits);

    me->VRprj.prj_units  = VdsUnits;

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPPROJ_TBL,szWhere,1);
#endif

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

End
  return (OM_S_SUCCESS);
}

method   PDB_lSPEC (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_PIPSPEC_TBL, me->nCUR_prj);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 26;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRspec,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_PIPSPEC_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "prj_no = %d",me->nCUR_prj);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPSPEC_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRspec,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      VRDBstr ( me->VRspec[i].key.spec_name, DbIO[i*Num + 1]);
      me->VRspec[i].key.spec_no  = VRDBint (DbIO[i*Num + 2]);

      VRDBstr ( me->VRspec[i].data.serv,      DbIO[i*Num + 3]);
      VRDBstr ( me->VRspec[i].data.d_mtl,     DbIO[i*Num + 4]);
      VRDBstr ( me->VRspec[i].data.d_fld,     DbIO[i*Num + 5]);
      VRDBstr ( me->VRspec[i].data.dflt_pipe, DbIO[i*Num + 6]);

      me->VRspec[i].data.tbl_chdir  = VRDBint (DbIO[i*Num + 7]);
      me->VRspec[i].data.tbl_branch = VRDBint (DbIO[i*Num + 8]);

      VRDBstr ( me->VRspec[i].data.dflt_con,  DbIO[i*Num + 9]);
      VRDBstr ( me->VRspec[i].data.dflt_ecc,  DbIO[i*Num + 10]);

      me->VRspec[i].data.tbl_adapt  = VRDBint (DbIO[i*Num + 11]);
      me->VRspec[i].data.tbl_compat = VRDBint (DbIO[i*Num + 12]);
      me->VRspec[i].data.tbl_minlen = VRDBint (DbIO[i*Num + 13]);
      me->VRspec[i].data.tbl_gskgap = VRDBint (DbIO[i*Num + 14]);
      me->VRspec[i].data.tbl_npd    = VRDBint (DbIO[i*Num + 15]);
      me->VRspec[i].data.tbl_tplim  = VRDBint (DbIO[i*Num + 16]);
      me->VRspec[i].data.tbl_mtl    = VRDBint (DbIO[i*Num + 17]);
      me->VRspec[i].data.tbl_tap    = VRDBint (DbIO[i*Num + 18]);
      me->VRspec[i].data.eqn_wall   = VRDBint (DbIO[i*Num + 19]);

      VRDBstr ( me->VRspec[i].data.vds_assm,  DbIO[i*Num + 20]);

      me->VRspec[i].data.corr_allow   = VRDBdbl (DbIO[i*Num + 21]);
      me->VRspec[i].data.gask_sep     = VRDBdbl (DbIO[i*Num + 22]);

      me->VRspec[i].data.note_a      = VRDBint (DbIO[i*Num + 23]);
      me->VRspec[i].data.note_b      = VRDBint (DbIO[i*Num + 24]);
      me->VRspec[i].data.units       = VRDBint (DbIO[i*Num + 25]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPSPEC_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   PDB_lSCH  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %f",VRDB_PIPSCHTHK_TBL, me->dCUR_dia);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 6;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRsch,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_PIPSCHTHK_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "npd = %f",me->dCUR_dia);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPSCHTHK_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);


  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRsch,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      me->VRsch[i].end_std    = VRDBint (DbIO[i*Num + 0]);
      me->VRsch[i].gentyp     = VRDBint (DbIO[i*Num + 1]);

      VRDBstr ( me->VRsch[i].sched,  DbIO[i*Num + 2]);

      me->VRsch[i].dia        = VRDBdbl (DbIO[i*Num + 3]);
      me->VRsch[i].thick      = VRDBdbl (DbIO[i*Num + 4]);

      me->VRsch[i].thk_units  = VRDBint (DbIO[i*Num + 5]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPSCHTHK_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   PDB_lCT  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_PIPCOMPTYP_TBL, 0);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 8;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRct,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_PIPCOMPTYP_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPCOMPTYP_TBL,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);


  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRct,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      VRDBstr ( me->VRct[i].key.comp_code,  DbIO[i*Num]);
      VRDBstr ( me->VRct[i].key.sh_code,    DbIO[i*Num + 1]);

      me->VRct[i].data.ct_topo    = VRDBint (DbIO[i*Num + 2]);
      me->VRct[i].data.ct_cat     = VRDBint (DbIO[i*Num + 3]);
      me->VRct[i].data.ct_rptc    = VRDBint (DbIO[i*Num + 4]);
      me->VRct[i].data.ct_nmcp    = VRDBint (DbIO[i*Num + 5]);
      me->VRct[i].data.ct_2_cp    = VRDBint (DbIO[i*Num + 6]);

      VRDBstr ( me->VRct[i].data.descr,    DbIO[i*Num + 7]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPCOMPTYP_TBL,"all",NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


method   PDB_lCOMM  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  if (me->nLST_dia == 0)
    sprintf (szStat,"Loading %s - %f in prim",
                VRDB_PIPCOMMCOD_TBL, me->dAL1_dia);
  else
    sprintf (szStat,"Loading %s - %f in alt",
                VRDB_PIPCOMMCOD_TBL, me->dAL2_dia);

  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 7;
  NbRow = 0;

  if (me->nLST_dia == 0)
  {
    status =
    om$vla_set_dimension (varray = me->VRcomm,
                          size   = NbRow);
    sprintf (szWhere, "size_g = %f",me->dAL1_dia);
  }
  else
  {
    status =
    om$vla_set_dimension (varray = me->VRaltcomm,
                          size   = NbRow);
    sprintf (szWhere, "size_g = %f",me->dAL2_dia);
  }

  if (VdsVerifyRisTable (VRDB_PIPCOMMCOD_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;


  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPCOMMCOD_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    if (me->nLST_dia == 0)
    {
      status = 
      om$vla_set_dimension (varray = me->VRcomm,
                            size   = NbRow);

      for (i=0; i<NbRow; i++)
      {
        VRDBstr ( me->VRcomm[i].si_comm_code,    DbIO[i*Num]);

        me->VRcomm[i].dia1    = VRDBdbl (DbIO[i*Num + 1]);
        me->VRcomm[i].dia2    = VRDBdbl (DbIO[i*Num + 2]);

        VRDBstr ( me->VRcomm[i].sch_t_g,        DbIO[i*Num + 3]);
        VRDBstr ( me->VRcomm[i].sch_t_r,        DbIO[i*Num + 4]);
        VRDBstr ( me->VRcomm[i].sd_comm_code,   DbIO[i*Num + 5]);
        VRDBstr ( me->VRcomm[i].pdm_part,       DbIO[i*Num + 6]);

        if (me->VRcomm[i].sch_t_g[0] == ' ')
            me->VRcomm[i].sch_t_g[0] = '\0';
        if (me->VRcomm[i].sch_t_r[0] == ' ')
            me->VRcomm[i].sch_t_r[0] = '\0';
      }
    }
    else
    {
      status =
      om$vla_set_dimension (varray = me->VRaltcomm,
                            size   = NbRow);

      for (i=0; i<NbRow; i++)
      {
        VRDBstr ( me->VRaltcomm[i].si_comm_code,    DbIO[i*Num]);

        me->VRaltcomm[i].dia1    = VRDBdbl (DbIO[i*Num + 1]);
        me->VRaltcomm[i].dia2    = VRDBdbl (DbIO[i*Num + 2]);

        VRDBstr ( me->VRaltcomm[i].sch_t_g,        DbIO[i*Num + 3]);
        VRDBstr ( me->VRaltcomm[i].sch_t_r,        DbIO[i*Num + 4]);
        VRDBstr ( me->VRaltcomm[i].sd_comm_code,   DbIO[i*Num + 5]);
        VRDBstr ( me->VRaltcomm[i].pdm_part,       DbIO[i*Num + 6]);

        if (me->VRaltcomm[i].sch_t_g[0] == ' ')
            me->VRaltcomm[i].sch_t_g[0] = '\0';
        if (me->VRaltcomm[i].sch_t_r[0] == ' ')
            me->VRaltcomm[i].sch_t_r[0] = '\0';
      }
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPCOMMCOD_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   PDB_lCOMP (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_PIPCOMPS_TBL, me->nCUR_spc);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 36;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRcomps,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_PIPCOMPS_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "spec_no = %d",me->nCUR_spc);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPCOMPS_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRcomps,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      me->VRcomps[i].key.option  = VRDBint (DbIO[i*Num + 6]);
      VRDBstr (me->VRcomps[i].key.comp_code, DbIO[i*Num + 1]);

      me->VRcomps[i].dia.dia1_l    = VRDBdbl (DbIO[i*Num + 2]);
      me->VRcomps[i].dia.dia1_h    = VRDBdbl (DbIO[i*Num + 3]);
      me->VRcomps[i].dia.dia2_l    = VRDBdbl (DbIO[i*Num + 4]);
      me->VRcomps[i].dia.dia2_h    = VRDBdbl (DbIO[i*Num + 5]);

      VRDBstr (me->VRcomps[i].data.famnam,     DbIO[i*Num + 7]);
      VRDBstr (me->VRcomps[i].data.part_pfx,   DbIO[i*Num + 8]);

      me->VRcomps[i].data.famcode    = VRDBint (DbIO[i*Num + 9]);
      me->VRcomps[i].data.partcode   = VRDBint (DbIO[i*Num + 10]);
      me->VRcomps[i].data.wtdata     = VRDBint (DbIO[i*Num + 11]);
      me->VRcomps[i].data.end_tbl_g  = VRDBint (DbIO[i*Num + 12]);
      me->VRcomps[i].data.end_idx_g  = VRDBint (DbIO[i*Num + 13]);
      me->VRcomps[i].data.end_tbl_r  = VRDBint (DbIO[i*Num + 14]);
      me->VRcomps[i].data.end_idx_r  = VRDBint (DbIO[i*Num + 15]);
      me->VRcomps[i].data.subfam     = VRDBint (DbIO[i*Num + 16]);
      me->VRcomps[i].data.subpart    = VRDBint (DbIO[i*Num + 17]);

      VRDBstr (me->VRcomps[i].data.sh_code,   DbIO[i*Num + 18]);

      me->VRcomps[i].data.maxtemp    = VRDBdbl (DbIO[i*Num + 19]);
      me->VRcomps[i].data.prep_g     = VRDBint (DbIO[i*Num + 20]);
      me->VRcomps[i].data.prep_r     = VRDBint (DbIO[i*Num + 21]);

      VRDBstr (me->VRcomps[i].data.rating_g,   DbIO[i*Num + 22]);
      VRDBstr (me->VRcomps[i].data.rating_r,   DbIO[i*Num + 23]);
      VRDBstr (me->VRcomps[i].data.sch_thk_g,  DbIO[i*Num + 24]);
      VRDBstr (me->VRcomps[i].data.sch_thk_r,  DbIO[i*Num + 25]);

      me->VRcomps[i].data.geom_std   = VRDBint (DbIO[i*Num + 26]);
      me->VRcomps[i].data.end_std_g  = VRDBint (DbIO[i*Num + 27]);
      me->VRcomps[i].data.end_std_r  = VRDBint (DbIO[i*Num + 28]);

      me->VRcomps[i].data.modifier   = VRDBdbl (DbIO[i*Num + 29]);
      me->VRcomps[i].data.material   = VRDBint (DbIO[i*Num + 30]);

      VRDBstr (me->VRcomps[i].data.commodity,  DbIO[i*Num + 31]);

      me->VRcomps[i].data.fabcat     = VRDBint (DbIO[i*Num + 32]);
      me->VRcomps[i].data.wt_fctr    = VRDBint (DbIO[i*Num + 33]);
      me->VRcomps[i].data.note_a     = VRDBint (DbIO[i*Num + 34]);
      me->VRcomps[i].data.note_b     = VRDBint (DbIO[i*Num + 35]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPCOMPS_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   PDB_lBEND (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar       *szTab;
  IGRchar        szStat[60];

  *msg  = MSSUCC;
  DbIO  = NULL;
  NbRow = 0;

  if (me->bNEW_bend)
  {
    Num   = 6;
    szTab = VRDB_PIPBENDSEL_TBL;
  }
  else
  {
    Num   = 5;
    szTab = VRDB_PIPCODSEL_TBL;
  }

  sprintf (szStat,"Loading %s - %d",szTab, me->nCUR_bend);
  UI_status (szStat);

  status =
  om$vla_set_dimension (varray = me->VRbend,
                        size   = NbRow);

  if (VdsVerifyRisTable (szTab) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "tblno = %d",me->nCUR_bend);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = szTab,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);


  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRbend,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      if (me->bNEW_bend)
      {
        me->VRbend[i].rec.new.ang_code    = VRDBint (DbIO[i*Num + 1]);
        me->VRbend[i].rec.new.npd1        = VRDBdbl (DbIO[i*Num + 2]);
        me->VRbend[i].rec.new.npd2        = VRDBdbl (DbIO[i*Num + 3]);
        me->VRbend[i].rec.new.type        = VRDBint (DbIO[i*Num + 4]);

        VRDBstr (me->VRbend[i].rec.new.comp_code, DbIO[i*Num + 5]);
      }
      else
      {
        me->VRbend[i].rec.old.ang_low     = VRDBdbl (DbIO[i*Num + 1]);
        me->VRbend[i].rec.old.ang_high    = VRDBdbl (DbIO[i*Num + 2]);
        me->VRbend[i].rec.old.type        = VRDBint (DbIO[i*Num + 3]);

        VRDBstr (me->VRbend[i].rec.old.comp_code, DbIO[i*Num + 4]);
      }
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPCODSEL_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}



method   PDB_lBRNC (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar       *szTab;
  IGRchar        szStat[60];

  *msg  = MSSUCC;
  DbIO  = NULL;
  NbRow = 0;

  if (me->bNEW_branch)
  {
    Num   = 8;
    szTab = VRDB_PIPBRANSEL_TBL;
  }
  else
  {
    Num   = 7;
    szTab = VRDB_PIPBRSEL_TBL;
  }

  sprintf (szStat,"Loading %s - %d",szTab, me->nCUR_branch);
  UI_status (szStat);

  status =
  om$vla_set_dimension (varray = me->VRbranch,
                        size   = NbRow);

  if (VdsVerifyRisTable (szTab) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "tblno = %d",me->nCUR_branch);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = szTab,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);


  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRbranch,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      if (me->bNEW_branch)
      {
        me->VRbranch[i].rec.new.ang_code    = VRDBint (DbIO[i*Num + 1]);
        me->VRbranch[i].rec.new.dia.dia1_h  = VRDBdbl (DbIO[i*Num + 2]);
        me->VRbranch[i].rec.new.dia.dia1_l  = VRDBdbl (DbIO[i*Num + 3]);
        me->VRbranch[i].rec.new.dia.dia2_h  = VRDBdbl (DbIO[i*Num + 4]);
        me->VRbranch[i].rec.new.dia.dia2_l  = VRDBdbl (DbIO[i*Num + 5]);

        me->VRbranch[i].rec.new.type        = VRDBint (DbIO[i*Num + 6]);

        VRDBstr (me->VRbranch[i].rec.new.comp_code, DbIO[i*Num + 7]);
      }
      else
      {
        me->VRbranch[i].rec.old.npd_high    = VRDBdbl (DbIO[i*Num + 1]);
        me->VRbranch[i].rec.old.npd_low     = VRDBdbl (DbIO[i*Num + 2]);
        me->VRbranch[i].rec.old.ang_low     = VRDBdbl (DbIO[i*Num + 3]);
        me->VRbranch[i].rec.old.ang_high    = VRDBdbl (DbIO[i*Num + 4]);

        me->VRbranch[i].rec.old.type        = VRDBint (DbIO[i*Num + 5]);

        VRDBstr (me->VRbranch[i].rec.old.comp_code, DbIO[i*Num + 6]);
      }
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPBRSEL_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


method   PDB_lCDL (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_PIPCODELIST_TBL, me->nCUR_cdl);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 4;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRcdl,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_PIPCODELIST_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "list_num = %d",me->nCUR_cdl);

  status =
  vdb$RisSelect (select     = VRPDB_SELECT,
                 table_name = VRDB_PIPCODELIST_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);


  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRcdl,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      me->VRcdl[i].ncode    = VRDBint (DbIO[i*Num + 1]);

      VRDBstr (me->VRcdl[i].stxt, DbIO[i*Num + 2]);
      VRDBstr (me->VRcdl[i].ltxt, DbIO[i*Num + 3]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_PIPCODELIST_TBL,szWhere,NbRow);
#endif
  }

  if ( DbIO ) VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


end implementation VRPDB;

