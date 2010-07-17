
/* $Id: VRHDBload.I,v 1.5 2001/10/15 00:25:23 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRHDBload.I
 *
 * Description:
 *      interface implementation for HVAC database access
 *        (private DB cacheload methods)
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRHDBload.I,v $
 *        Revision 1.5  2001/10/15 00:25:23  anand
 *        Rollback of fix JTS TR MP 5586 (will need to redeliver fix
 *        for Pload).
 *
 *        Revision 1.3  2001/02/20 01:14:47  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/12 23:22:22  anand
 *        SP merge
 *
# Revision 1.1  2000/05/11  22:07:52  pinnacle
# Created: route/vrpdu/VRHDBload.I by apazhani for Service Pack
#
# Revision 1.3  2000/03/02  16:47:40  pinnacle
# (No comment)
#
# Revision 1.2  2000/02/08  21:03:50  pinnacle
# added methods to load the material & insulation table contents
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:36:10  pinnacle
# Created: vrpdu/VRHDBload.I by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        02/09/2000      Alwin 	Added methods to load Material & 
 *									Insulation spec's.
 *        03/02/2000      Alwin 	Modified to limit cache only the needed 
 *									columns of the material & insulation tables
 *        05/10/2000      Alwin 	Modified HDB_lInsulation method to add
 *									one more column ( insul_type ), to 
 *									distinguish the Acoustic insulation and
 *									Thermal insulation. CR179901312
 *
 *************************************************************************/

class implementation VRHDB;

#include "vrdbgmacros.h"
#include "VRHDBdef.h"

extern IGRdouble   fabs();

/*
#define MY_DEBUG
*/

extern
IGRint   VRHDB_error (IGRchar    *tabnam)
{
  printf (" VRHDB error reading table %s -- disregarded\n", tabnam);

  return (0);
}


method   HDB_lPROJ  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_HVPROJ_TBL, me->nCUR_prj);
  UI_status (szStat);

  *msg = MSSUCC;
  DbIO = NULL;
  Num  = 2;

  if (VdsVerifyRisTable (VRDB_HVPROJ_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "prj_no = %d",me->nCUR_prj);

  status =
  vdb$RisSelect (select     = VRHDB_SELECT,
                 table_name = VRDB_HVPROJ_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if ((status & OM_S_SUCCESS) && (NbRow > 0))
  {
#ifdef MY_DEBUG
    printf ("RISRETURN %s %s\n",DbIO[0], DbIO[1]);
#endif

    VRDBstr (me->VRprj.opt_set_name, DbIO[1]);
  }

  me->VRprj.prj_no     = me->nCUR_prj;

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_HVPROJ_TBL,szWhere,NbRow);
#endif

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   HDB_lSPEC (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_HVSPEC_TBL, me->nCUR_prj);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 38;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRspec,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_HVSPEC_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "prj_no = %d",me->nCUR_prj);

  status =
  vdb$RisSelect (select     = VRHDB_SELECT,
                 table_name = VRDB_HVSPEC_TBL,
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
      VRDBstr ( me->VRspec[i].key.hvac_class, DbIO[i*Num + 1]);
      me->VRspec[i].key.class_no  = VRDBint (DbIO[i*Num + 2]);

      VRDBstr ( me->VRspec[i].data.d_serv,      DbIO[i*Num + 3]);
      VRDBstr ( me->VRspec[i].data.d_presc,     DbIO[i*Num + 4]);
      VRDBstr ( me->VRspec[i].data.dflt_duct,   DbIO[i*Num + 5]);

      me->VRspec[i].data.tbl_chdir  = VRDBint (DbIO[i*Num + 6]);
      me->VRspec[i].data.tbl_branch = VRDBint (DbIO[i*Num + 7]);

      VRDBstr ( me->VRspec[i].data.dflt_con,  DbIO[i*Num + 8]);
      VRDBstr ( me->VRspec[i].data.dflt_ecc,  DbIO[i*Num + 9]);

      me->VRspec[i].data.tbl_trans  = VRDBint (DbIO[i*Num + 10]);

      VRDBstr ( me->VRspec[i].data.dflt_tws,  DbIO[i*Num + 11]);

      me->VRspec[i].data.d_rad      = VRDBdbl (DbIO[i*Num + 12]);
      me->VRspec[i].data.d_ang      = VRDBdbl (DbIO[i*Num + 13]);
      me->VRspec[i].data.d_gap      = VRDBdbl (DbIO[i*Num + 14]);

      VRDBstr ( me->VRspec[i].data.dmeth,  DbIO[i*Num + 15]);

      me->VRspec[i].data.d_fmax     = VRDBdbl (DbIO[i*Num + 16]);
      me->VRspec[i].data.d_vmax     = VRDBdbl (DbIO[i*Num + 17]);
      me->VRspec[i].data.d_vmin     = VRDBdbl (DbIO[i*Num + 18]);

      VRDBstr ( me->VRspec[i].data.d_matl,  DbIO[i*Num + 19]);

      me->VRspec[i].data.d_thk      = VRDBdbl (DbIO[i*Num + 20]);
      me->VRspec[i].data.d_dens     = VRDBdbl (DbIO[i*Num + 21]);
      me->VRspec[i].data.d_wmult    = VRDBdbl (DbIO[i*Num + 22]);
      me->VRspec[i].data.d_rough    = VRDBdbl (DbIO[i*Num + 23]);

      VRDBstr ( me->VRspec[i].data.fl_name,  DbIO[i*Num + 24]);

      me->VRspec[i].data.fl_temp    = VRDBdbl (DbIO[i*Num + 25]);
      me->VRspec[i].data.fl_dens    = VRDBdbl (DbIO[i*Num + 26]);
      me->VRspec[i].data.fl_visc    = VRDBdbl (DbIO[i*Num + 27]);

      me->VRspec[i].data.d_minw     = VRDBdbl (DbIO[i*Num + 28]);
      me->VRspec[i].data.d_maxw     = VRDBdbl (DbIO[i*Num + 29]);
      me->VRspec[i].data.d_mind     = VRDBdbl (DbIO[i*Num + 30]);
      me->VRspec[i].data.d_maxd     = VRDBdbl (DbIO[i*Num + 31]);

      me->VRspec[i].data.duct_inc   = VRDBdbl (DbIO[i*Num + 32]);

      me->VRspec[i].data.stdduct    = VRDBint (DbIO[i*Num + 33]);
      me->VRspec[i].data.altshape   = VRDBint (DbIO[i*Num + 34]);

      me->VRspec[i].data.m_vterm    = VRDBdbl (DbIO[i*Num + 35]);
      me->VRspec[i].data.fan_vout   = VRDBdbl (DbIO[i*Num + 36]);

      me->VRspec[i].data.units_set  = VRDBint (DbIO[i*Num + 37]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_HVSPEC_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   HDB_lCT  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_HVCOMPTYP_TBL, 0);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 9;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRct,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_HVCOMPTYP_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  status =
  vdb$RisSelect (select     = VRHDB_SELECT,
                 table_name = VRDB_HVCOMPTYP_TBL,
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
      me->VRct[i].data.ct_subc    = VRDBint (DbIO[i*Num + 5]);
      me->VRct[i].data.ct_nmcp    = VRDBint (DbIO[i*Num + 6]);

      VRDBstr ( me->VRct[i].data.descr,    DbIO[i*Num + 7]);

      me->VRct[i].data.ct_2_cp    = VRDBint (DbIO[i*Num + 8]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_HVCOMPTYP_TBL,"all",NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


method   HDB_lCOMP (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_HVCOMPS_TBL, me->nCUR_spc);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 11;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRcomps,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_HVCOMPS_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "tblno = %d",me->nCUR_spc);

  status =
  vdb$RisSelect (select     = VRHDB_SELECT,
                 table_name = VRDB_HVCOMPS_TBL,
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
      VRDBstr (me->VRcomps[i].key.comp_code, DbIO[i*Num + 1]);
      me->VRcomps[i].key.shapecode  = VRDBint (DbIO[i*Num + 2]);

      VRDBstr (me->VRcomps[i].data.famnam,     DbIO[i*Num + 3]);
      VRDBstr (me->VRcomps[i].data.part_pfx,   DbIO[i*Num + 4]);

      me->VRcomps[i].data.famcode    = VRDBint (DbIO[i*Num + 5]);
      me->VRcomps[i].data.partcode   = VRDBint (DbIO[i*Num + 6]);

      VRDBstr (me->VRcomps[i].data.sh_code,   DbIO[i*Num + 7]);

      me->VRcomps[i].data.pdm_flag   = *(DbIO[i*Num + 8]);

      VRDBstr (me->VRcomps[i].data.cat_name,   DbIO[i*Num + 9]);
      VRDBstr (me->VRcomps[i].data.sel_crit,   DbIO[i*Num + 10]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_HVCOMPS_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   HDB_lBEND (IGRlong      *msg)
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
    Num   = 8;
    szTab = VRDB_HVBENDSEL_TBL;
  }
  else
  {
    Num   = 5;
    szTab = VRDB_HVCODSEL_TBL;
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
  vdb$RisSelect (select     = VRHDB_SELECT,
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
        me->VRbend[i].rec.new.dwlow       = VRDBdbl (DbIO[i*Num + 2]);
        me->VRbend[i].rec.new.dwhig       = VRDBdbl (DbIO[i*Num + 3]);
        me->VRbend[i].rec.new.dwlow       = VRDBdbl (DbIO[i*Num + 4]);
        me->VRbend[i].rec.new.dwhig       = VRDBdbl (DbIO[i*Num + 5]);
        me->VRbend[i].rec.new.ctype       = VRDBint (DbIO[i*Num + 6]);

        VRDBstr (me->VRbend[i].rec.new.comp_code, DbIO[i*Num + 7]);
      }
      else
      {
        me->VRbend[i].rec.old.ang_low     = VRDBdbl (DbIO[i*Num + 1]);
        me->VRbend[i].rec.old.ang_high    = VRDBdbl (DbIO[i*Num + 2]);
        me->VRbend[i].rec.old.ctype       = VRDBint (DbIO[i*Num + 3]);

        VRDBstr (me->VRbend[i].rec.old.comp_code, DbIO[i*Num + 4]);
      }
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_HVCODSEL_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   HDB_lTRAN (IGRlong      *msg)
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

  if (me->bNEW_trans)
  {
    Num   = 8;
    szTab = VRDB_HVTRA1SEL_TBL;
  }
  else
  {
    Num   = 4;
    szTab = VRDB_HVTRANSEL_TBL;
  }

  sprintf (szStat,"Loading %s - %d",szTab, me->nCUR_trans);
  UI_status (szStat);

  status =
  om$vla_set_dimension (varray = me->VRtrans,
                        size   = NbRow);

  if (VdsVerifyRisTable (szTab) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "tblno = %d",me->nCUR_trans);

  status =
  vdb$RisSelect (select     = VRHDB_SELECT,
                 table_name = szTab,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRtrans,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      if (me->bNEW_trans)
      {
        me->VRtrans[i].rec.new.shapecode   = VRDBint (DbIO[i*Num + 1]);
        me->VRtrans[i].rec.new.transtype   = VRDBint (DbIO[i*Num + 2]);
        me->VRtrans[i].rec.new.dwlow       = VRDBdbl (DbIO[i*Num + 3]);
        me->VRtrans[i].rec.new.dwhig       = VRDBdbl (DbIO[i*Num + 4]);
        me->VRtrans[i].rec.new.ddlow       = VRDBdbl (DbIO[i*Num + 5]);
        me->VRtrans[i].rec.new.ddhig       = VRDBdbl (DbIO[i*Num + 6]);

        VRDBstr (me->VRtrans[i].rec.new.comp_code, DbIO[i*Num + 7]);
      }
      else
      {
        me->VRtrans[i].rec.old.shapecode   = VRDBint (DbIO[i*Num + 1]);
        me->VRtrans[i].rec.old.transtype   = VRDBint (DbIO[i*Num + 2]);

        VRDBstr (me->VRtrans[i].rec.old.comp_code, DbIO[i*Num + 3]);
      }
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_HVBRSEL_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


method   HDB_lBRNC (IGRlong      *msg)
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
    Num   = 12;
    szTab = VRDB_HVBRANSEL_TBL;
  }
  else
  {
    Num   = 4;
    szTab = VRDB_HVBRSEL_TBL;
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
  vdb$RisSelect (select     = VRHDB_SELECT,
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
        me->VRbranch[i].rec.new.dwlow1      = VRDBdbl (DbIO[i*Num + 2]);
        me->VRbranch[i].rec.new.dwhig1      = VRDBdbl (DbIO[i*Num + 3]);
        me->VRbranch[i].rec.new.ddlow1      = VRDBdbl (DbIO[i*Num + 4]);
        me->VRbranch[i].rec.new.ddhig1      = VRDBdbl (DbIO[i*Num + 5]);
        me->VRbranch[i].rec.new.dwlow2      = VRDBdbl (DbIO[i*Num + 6]);
        me->VRbranch[i].rec.new.dwhig2      = VRDBdbl (DbIO[i*Num + 7]);
        me->VRbranch[i].rec.new.ddlow2      = VRDBdbl (DbIO[i*Num + 8]);
        me->VRbranch[i].rec.new.ddhig2      = VRDBdbl (DbIO[i*Num + 9]);

        me->VRbranch[i].rec.new.ctype       = VRDBint (DbIO[i*Num + 10]);

        VRDBstr (me->VRbranch[i].rec.new.comp_code, DbIO[i*Num + 11]);
      }
      else
      {
        me->VRbranch[i].rec.old.ang_low     = VRDBdbl (DbIO[i*Num + 1]);
        me->VRbranch[i].rec.old.ang_high    = VRDBdbl (DbIO[i*Num + 2]);

        VRDBstr (me->VRbranch[i].rec.old.comp_code, DbIO[i*Num + 3]);
      }
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_HVBRSEL_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


method   HDB_lCDL (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_HVCODELIST_TBL, me->nCUR_cdl);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 4;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRcdl,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_HVCODELIST_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "list_num = %d",me->nCUR_cdl);

  status =
  vdb$RisSelect (select     = VRHDB_SELECT,
                 table_name = VRDB_HVCODELIST_TBL,
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
    printf ("LOAD %s %s , %d records\n",VRDB_HVCODELIST_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

/* following two methods written by Alwin.
Loads the hvac_material_list and hvac_insulation_list tables and stores it in
the Cache Object */
method   HDB_lMATERIAL (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow=0;
  IGRint         i;
  IGRint         NumCol;
  IGRchar        szWhere[80];
  IGRchar        szStat[60];
  IGRchar		 select[80];

  SetProc( method HDB_lMATERIAL ); Begin

  __DBGpr_str( " Default spec ", me->szCUR_mat_spec );

  sprintf (szStat,"Loading %s - %s", VRDB_HVMATERIAL_TBL, me->szCUR_mat_spec);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  NumCol= 4;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRmaterial,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_HVMATERIAL_TBL) != VDS_DBTABLE_FOUND)
  {
	End
    return OM_S_SUCCESS;
  }

  sprintf( szWhere, "matl_class = '%s'", me->szCUR_mat_spec );

  // select only what's going to cached. The table might have many other columns
  // we need to cache them, as they're not needed. CR179900696
  strcpy( select, "matl_class, duct_matl, duct_thk_m, duct_thk_e" );
  status =
  vdb$RisSelect (select     = select,
                 table_name = VRDB_HVMATERIAL_TBL,
                 where      = szWhere,
                 numselect  = NumCol,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  __DBGpr_int( " Nb. of row in hvac_material_list table ", NbRow );

  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRmaterial,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      VRDBstr(me->VRmaterial[i].key.material_class, DbIO[i*NumCol + 0]);
      VRDBstr(me->VRmaterial[i].data.duct_matl, DbIO[i*NumCol + 1]);

      me->VRmaterial[i].data.dDuctThick_met =  VRDBdbl(DbIO[i*NumCol + 2]);
      me->VRmaterial[i].data.dDuctThick_imp =  VRDBdbl(DbIO[i*NumCol + 3]);

	  __DBGpr_str( " Material class ", me->VRmaterial[i].key.material_class );
	  __DBGpr_dbl( " Metric thickness ", me->VRmaterial[i].data.dDuctThick_met);
	  __DBGpr_dbl( " Imperial thickness",me->VRmaterial[i].data.dDuctThick_imp);
    }
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  End
  return (OM_S_SUCCESS);
}

method   HDB_lINSULATION (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         NumCol;
  IGRchar        szWhere[80];
  IGRchar        szStat[60];
  IGRchar        select[80];

  SetProc( method HDB_lINSULATION ); Begin

  *msg  = MSSUCC;
  DbIO  = NULL;
  NumCol= 4;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRinsulation,
                        size   = NbRow);

  sprintf( szStat, "Loading %s table ", VRDB_HVINSULATION_TBL );
  UI_status( szStat );

  if (VdsVerifyRisTable (VRDB_HVINSULATION_TBL) != VDS_DBTABLE_FOUND)
  {
	End
    return OM_S_SUCCESS;
  }

  // select only what's going to cached. The table might have many other columns
  // we need to cache them, as they're not needed. CR179900696
  // Insert insul_type, new field to specify whether the data if for Thermal or
  // Acoustical Insulation. CR179901312
  strcpy( select, "insul_type, insul_class, d_insul_thk_m, d_insul_thk_e" );
  status =
  vdb$RisSelect (select     = select,
                 table_name = VRDB_HVINSULATION_TBL,
                 numselect  = NumCol,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  __DBGpr_int( " Nb. of rows in hvac_insulation_list table ", NbRow );
  if (status & OM_S_SUCCESS)
  {
    status =
    om$vla_set_dimension (varray = me->VRinsulation,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
	  VRDBstr( me->VRinsulation[i].insul_type, DbIO[i*NumCol + 0] );
	  VRDBstr( me->VRinsulation[i].insul_class, DbIO[i*NumCol + 1] );
      me->VRinsulation[i].dInsulThick_met =  VRDBdbl(DbIO[i*NumCol + 2]);
      me->VRinsulation[i].dInsulThick_imp =  VRDBdbl(DbIO[i*NumCol + 3]);

	  __DBGpr_str( " Insulation Type ", me->VRinsulation[i].insul_type );
	  __DBGpr_str( " Insulation class ", me->VRinsulation[i].insul_class );
	  __DBGpr_dbl( " metric thickness ", me->VRinsulation[i].dInsulThick_met );
	  __DBGpr_dbl( " imperial thickness ", me->VRinsulation[i].dInsulThick_imp);
    }
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  End
  return (OM_S_SUCCESS);
}

end implementation VRHDB;
