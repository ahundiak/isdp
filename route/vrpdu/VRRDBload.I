
/* $Id: VRRDBload.I,v 1.3 2001/02/20 01:15:02 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpdu/VRRDBload.I
 *
 * Description:
 *      interface implementation for RWAY database access
 *        (private DB cacheload methods)
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRRDBload.I,v $
 *        Revision 1.3  2001/02/20 01:15:02  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/11 19:22:55  anand
 *        SP merge
 *
# Revision 1.1  2000/07/10  19:08:02  pinnacle
# Created: route/vrpdu/VRRDBload.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:39:46  pinnacle
# Created: vrpdu/VRRDBload.I by hverstee for route
#
 *
 * History:
 *        05/29/96        hv        	Initial
 *        07/10/00        Alwin     	Added method to load the Raceway Nozzle
 *				    	Contents from the DB. CR179901003
 *
 *************************************************************************/

class implementation VRRDB;

extern IGRdouble   fabs();

/*
#define MY_DEBUG
*/

extern
IGRint   VRRDB_error (IGRchar    *tabnam)
{
  printf (" VRRDB error reading table %s -- disregarded\n", tabnam);

  return (0);
}


method   RDB_lPROJ  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_RWPROJ_TBL, me->nCUR_prj);
  UI_status (szStat);

  *msg = MSSUCC;
  DbIO = NULL;
  Num  = 2;

  if (VdsVerifyRisTable (VRDB_RWPROJ_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "prj_no = %d",me->nCUR_prj);

  status =
  vdb$RisSelect (select     = VRRDB_SELECT,
                 table_name = VRDB_RWPROJ_TBL,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if ((status & OM_S_SUCCESS) && (NbRow > 0))
  {
    VRDBstr (me->VRprj.opt_set_name, DbIO[1]);

  }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_RWPROJ_TBL,szWhere,1);
#endif

  me->VRprj.prj_no     = me->nCUR_prj;

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   RDB_lSPEC (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_RWSPEC_TBL, me->nCUR_prj);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 11;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRspec,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_RWSPEC_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "prj_no = %d",me->nCUR_prj);

  status =
  vdb$RisSelect (select     = VRRDB_SELECT,
                 table_name = VRDB_RWSPEC_TBL,
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
      VRDBstr ( me->VRspec[i].key.vendor_code, DbIO[i*Num + 1]);
      me->VRspec[i].key.vendor_no  = VRDBint (DbIO[i*Num + 2]);

      VRDBstr ( me->VRspec[i].data.d_desc,      DbIO[i*Num + 3]);
      VRDBstr ( me->VRspec[i].data.dflt_run,    DbIO[i*Num + 4]);

      me->VRspec[i].data.tbl_chdir  = VRDBint (DbIO[i*Num + 5]);
      me->VRspec[i].data.tbl_branch = VRDBint (DbIO[i*Num + 6]);

      VRDBstr ( me->VRspec[i].data.dflt_con,  DbIO[i*Num + 7]);
      VRDBstr ( me->VRspec[i].data.dflt_ecc,  DbIO[i*Num + 8]);

      VRDBstr ( me->VRspec[i].data.d_matl,  DbIO[i*Num + 9]);

      me->VRspec[i].data.units_set  = VRDBint (DbIO[i*Num + 10]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_RWSPEC_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   RDB_lCT  (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_RWCOMPTYP_TBL, 0);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 9;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRct,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_RWCOMPTYP_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  status =
  vdb$RisSelect (select     = VRRDB_SELECT,
                 table_name = VRDB_RWCOMPTYP_TBL,
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
      VRDBstr ( me->VRct[i].key.sh_code,    DbIO[i*Num + 2]);

      me->VRct[i].key.comp_type   = VRDBint (DbIO[i*Num + 1]);

      me->VRct[i].data.ct_topo    = VRDBint (DbIO[i*Num + 3]);
      me->VRct[i].data.ct_cat     = VRDBint (DbIO[i*Num + 4]);
      me->VRct[i].data.ct_rptc    = VRDBint (DbIO[i*Num + 5]);
      me->VRct[i].data.ct_nmcp    = VRDBint (DbIO[i*Num + 6]);

      VRDBstr ( me->VRct[i].data.descr,    DbIO[i*Num + 7]);

      me->VRct[i].data.ct_2_cp    = VRDBint (DbIO[i*Num + 8]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_RWCOMPTYP_TBL,"all",NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


method   RDB_lCOMP (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_RWCOMPS_TBL, me->nCUR_spc);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 18;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRcomps,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_RWCOMPS_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "vendor_no = %d",me->nCUR_spc);

  status =
  vdb$RisSelect (select     = VRRDB_SELECT,
                 table_name = VRDB_RWCOMPS_TBL,
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
      me->VRcomps[i].key.rType       = VRDBint (DbIO[i*Num + 6]);

      me->VRcomps[i].data.dWid1      = VRDBdbl (DbIO[i*Num + 2]);
      me->VRcomps[i].data.dDep1      = VRDBdbl (DbIO[i*Num + 3]);
      me->VRcomps[i].data.dWid2      = VRDBdbl (DbIO[i*Num + 4]);
      me->VRcomps[i].data.dDep2      = VRDBdbl (DbIO[i*Num + 5]);


      VRDBstr (me->VRcomps[i].data.famnam,     DbIO[i*Num + 7]);
      VRDBstr (me->VRcomps[i].data.part_num,   DbIO[i*Num + 8]);

      me->VRcomps[i].data.famcode    = VRDBint (DbIO[i*Num + 9]);
      me->VRcomps[i].data.partcode   = VRDBint (DbIO[i*Num + 10]);

      VRDBstr (me->VRcomps[i].data.sh_code,   DbIO[i*Num + 11]);
      VRDBstr (me->VRcomps[i].data.commodity, DbIO[i*Num + 12]);

      me->VRcomps[i].data.unit_wt    = VRDBdbl (DbIO[i*Num + 13]);

      me->VRcomps[i].data.pdm_flag   = *(DbIO[i*Num + 14]);

      me->VRcomps[i].data.par_1      = VRDBdbl (DbIO[i*Num + 15]);
      me->VRcomps[i].data.par_2      = VRDBdbl (DbIO[i*Num + 16]);
      me->VRcomps[i].data.par_3      = VRDBdbl (DbIO[i*Num + 17]);
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_RWCOMPS_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   RDB_lBEND (IGRlong      *msg)
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
    szTab = VRDB_RWBENDSEL_TBL;
  }
  else
  {
    Num   = 5;
    szTab = VRDB_RWCODSEL_TBL;
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
  vdb$RisSelect (select     = VRRDB_SELECT,
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
    printf ("LOAD %s %s , %d records\n",VRDB_RWCODSEL_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

method   RDB_lBRNC (IGRlong      *msg)
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
    szTab = VRDB_RWBRANSEL_TBL;
  }
  else
  {
    Num   = 5;
    szTab = VRDB_RWBRSEL_TBL;
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
  vdb$RisSelect (select     = VRRDB_SELECT,
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

        me->VRbranch[i].rec.old.ctype       = VRDBint (DbIO[i*Num + 3]);

        VRDBstr (me->VRbranch[i].rec.old.comp_code, DbIO[i*Num + 4]);
      }
    }

#ifdef MY_DEBUG
    printf ("LOAD %s %s , %d records\n",VRDB_RWBRSEL_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}


method   RDB_lCDL (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szWhere[20];
  IGRchar        szStat[60];

  sprintf (szStat,"Loading %s - %d",VRDB_RWCODELIST_TBL, me->nCUR_cdl);
  UI_status (szStat);

  *msg  = MSSUCC;
  DbIO  = NULL;
  Num   = 4;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRcdl,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_RWCODELIST_TBL) != VDS_DBTABLE_FOUND)
    return OM_S_SUCCESS;

  sprintf (szWhere, "list_num = %d",me->nCUR_cdl);

  status =
  vdb$RisSelect (select     = VRRDB_SELECT,
                 table_name = VRDB_RWCODELIST_TBL,
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
    printf ("LOAD %s %s , %d records\n",VRDB_RWCODELIST_TBL,szWhere,NbRow);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (OM_S_SUCCESS);
}

#include "vrdbgmacros.h"
method   RDB_lRWAYNOZZ (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;
  IGRchar        szStat[60];
 
  SetProc( Md RDB_lRWAYNOZZ ); Begin 

  __DBGpr_str( " Loading ", VRDB_RWNOZZLE_TBL );
  sprintf ( szStat,"Loading %s ", VRDB_RWNOZZLE_TBL );
  UI_status (szStat);

  *msg  = MSFAIL;
  DbIO  = NULL;
  Num   = 10;
  NbRow = 0;

  status =
  om$vla_set_dimension (varray = me->VRrwnozz,
                        size   = NbRow);

  if (VdsVerifyRisTable (VRDB_RWNOZZLE_TBL) != VDS_DBTABLE_FOUND)
  {
    *msg = MSFAIL;
    __DBGpr_com( " Raceway Nozzle Table not found " ); 
    End
    return OM_E_ABORT;
  }

  status =
  vdb$RisSelect (select     = VRRDB_SELECT,
                 table_name = VRDB_RWNOZZLE_TBL,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  __DBGpr_int( " Nb. of Rows ", NbRow );

  if( status & OM_S_SUCCESS )
  {
    *msg  = MSSUCC;

    status =
    om$vla_set_dimension (varray = me->VRrwnozz,
                          size   = NbRow);

    for (i=0; i<NbRow; i++)
    {
      me->VRrwnozz[i].vendor_no	= VRDBint (DbIO[i*Num + 0]);
      me->VRrwnozz[i].shape    	= VRDBint (DbIO[i*Num + 1]);
      me->VRrwnozz[i].width    	= VRDBdbl (DbIO[i*Num + 2]);
      me->VRrwnozz[i].depth    	= VRDBdbl (DbIO[i*Num + 3]);
      me->VRrwnozz[i].units_set	= VRDBint (DbIO[i*Num + 4]);
      me->VRrwnozz[i].d1    	= VRDBdbl (DbIO[i*Num + 5]);
      me->VRrwnozz[i].t1    	= VRDBdbl (DbIO[i*Num + 6]);
      me->VRrwnozz[i].b1    	= VRDBdbl (DbIO[i*Num + 7]);
      me->VRrwnozz[i].f1    	= VRDBdbl (DbIO[i*Num + 8]);
      VRDBstr (me->VRrwnozz[i].macro_name, DbIO[i*Num + 9]);
    }
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  End
  return (OM_S_SUCCESS);
}

end implementation VRRDB;

