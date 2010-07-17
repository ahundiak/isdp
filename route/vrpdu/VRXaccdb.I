/* $Id: VRXaccdb.I,v 1.2 2002/04/15 20:01:45 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRaccess_db.c
 *
 * Description:
 *  Extracts macro params and connect point attributes from 
 *  PDM/PDU database 
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXaccdb.I,v $
 *  Revision 1.2  2002/04/15 20:01:45  anand
 *  Removed version.h and associated dependencies. version.h is
 *  an include file in $EXNUC.
 *
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:20  pinnacle
# Created: vrpdu/VRXaccdb.I by hverstee for route
#
 * Revision 1.1  1996/04/22  14:59:00  pinnacle
 * Created: vrpdu/VRaccess_db.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:20  pinnacle
 * Replaced: vrpdu/access_db.c for:  by r240_int for route240
 *
 *
 * History:
 *  MM/DD/YY   AUTHOR  DESCRIPTION
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "dberror.h"

#include "VDmem.h"
#include "VDSris_def.h"
#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRPDBdef.h"
#include "vrpdu_pto.h"

/*
#define MY_DEBUG
*/

extern        UI_status();

extern
struct VRPDB_project   VRGL_PROJ;


int access_db (

char             *fam_name,    /* family or macro name                  (I) */
char             *part_num,    /* part number of the component          (I) */
short             comp_type,
struct ACrg_coll  mac_pm[],    /* macro parameters                      (O) */
int              *pm_no,       /* cnt of parameters already in mac_pm (I/O) */
char             *err_ptr,     /* error message buffer                  (O) */
int              *flag)        /* flag for column "o1"                  (O) */

{

/****************************************************************************/
/*                                                                          */
/* This routine extracts connect point attributes and macro parameters from */
/* the PDM/PDU tables.                                                      */
/*                                                                          */
/****************************************************************************/

  IGRint        sts, i;
  IGRint        rows;
  IGRchar       search[MAX_WHERE_SIZE];    /* where clause of a select */
  IGRint        firstcol,  currcol, unit_col;
  IGRchar       tmp[20];
  IGRint        part_units;
  IGRchar       szSelect[300];

  IGRint        nLocal;
  IGRdouble     dLocal;
  IGRlong       retmsg;
  IGRint        iret;
  IGRint        nCol;
  IGRint        iCol;
  IGRchar     **DbIO;

  struct VRriscol    *RSC;
  struct VRriscol    *RSM;

#ifdef MY_DEBUG
  printf (" ACCESS DB\n");
#endif

  firstcol   = -1;
  unit_col   = -1;
  iCol       = 0;
  iret       = 0;
  DbIO       = NULL;
  RSM        = NULL;
  part_units = VRGL_PROJ.prj_units;

  if (VdsVerifyRisTable (fam_name) != VDS_DBTABLE_FOUND) goto wrapup;

  sts = VRdbRisCol (&retmsg, fam_name, &nCol, &RSC);
  if (!(sts & OM_S_SUCCESS) || (nCol == 0)) goto wrapup;

  /*   seen that the riscolumns are not in sequence I'll do
       the select first    */

  RSM = _MALLOC (nCol, struct VRriscol);

  /*   locate units_set first    */

  for (i=0; i< nCol; i++)
    if(strcmp(RSC[i].colname, "units_set" )==0)
      {
         strcpy (RSM[iCol].colname, RSC[i].colname);
         unit_col = iCol;
         iCol++;
         break;
      }

  /* If units_set is not defined in the PDM family table */
  if (unit_col < 0)
  {
    /* Set units_set to VRGL_PROJ.prj_units */
    part_units = VRGL_PROJ.prj_units;
    printf("Units_set not defined in family table\n");
    printf("Family name:%s\n",fam_name);
    printf("Setting project units set as the default units set...\n");
    VRdb_err_msg(VR_E_DbUnitErrMsg,err_ptr,NULL,NULL,NULL);
  }

  /*   and bypass all NFM/PDM stuff   */

  for (i=0; i< nCol; i++)
  {
    if(strncmp(RSC[i].colname, "p_", 2) == 0 ||
       strncmp(RSC[i].colname,"n_", 2) == 0   )     continue;

    if(strcmp(RSC[i].colname, "units_set") == 0)    continue;

    RSM[iCol] = RSC[i];
    iCol++;
  }

  /*    construct the select statement    */

  strcpy (szSelect, RSM[0].colname);

  for (i=1; i< iCol; i++)
  {
    strcat (szSelect,",");
    strcat (szSelect, RSM[i].colname);
  }

  sprintf( search, "%s = '%s'", "n_itemname", part_num );

#ifdef MY_DEBUG
  printf (" PDMsearch table %s\n", fam_name);
  printf (" Select  %s\n",szSelect);
#endif

  sts =
  vdb$RisSelect (select     = szSelect,
                 table_name = fam_name,
                 where      = search,
                 numselect  = iCol,
                 p_numrows  = &rows,
                 p_buffer   = &DbIO);

  if (!(sts & OM_S_SUCCESS) || (rows == 0)) goto wrapup;

  /* If units_set is not defined in the PDM family table */
  if (unit_col < 0)
  {
    /* Set units_set to VRGL_PROJ.prj_units */
    part_units = VRGL_PROJ.prj_units;
    printf("Units_set not defined in family table\n");
    printf("Family name:%s\n",fam_name);
    printf("Setting project units set as the default units set...\n");
    VRdb_err_msg(VR_E_DbUnitErrMsg,err_ptr,NULL,NULL,NULL);
  }
  else
  {
    part_units = VRDBint (DbIO[unit_col]);
  }

  *flag = 0;

  for (currcol=(unit_col+1); currcol<iCol; currcol++)
  {

#ifdef MY_DEBUG
    printf (" Table got %s -- %s\n",RSM[currcol].colname, DbIO[currcol]);
    printf (" Column loop  %d of %d name %s\n", currcol, nCol,
               RSM[currcol].colname);
#endif

    if(( strcmp( RSM[currcol].colname,"dry_wt") == 0) &&
         (( comp_type == 0) || (comp_type == 12 )))
    {
       strcpy(tmp,"dry_uwt");
    } 
    else
    if(( strcmp( RSM[currcol].colname,"wet_wt") == 0) &&
           (( comp_type == 0) || (comp_type == 12 )))
    {
       strcpy(tmp,"wet_uwt");
    }
    else
       VRDBstr(tmp, RSM[currcol].colname);

    VRDBstr(mac_pm[*pm_no].name, RSM[currcol].colname);

    /* Set flag if column o1 exists */
    if(strcmp(mac_pm[*pm_no].name, "o1") == 0 )      *flag = 1;

    if(RSM[currcol].coltype == VR_RISDB_TEXT)
    {
       VRDBstr(mac_pm[*pm_no].desc.value.att_txt, DbIO[currcol]);
       mac_pm[*pm_no].desc.type = RSM[currcol].partype;
       *pm_no += 1;
    }
    else
    if (RSM[currcol].coltype == VR_RISDB_INT)
    {
       nLocal = VRDBint (DbIO[currcol]);
      
       if(( VRGL_PROJ.prj_units != part_units ) &&
          (nLocal != -9999) && (nLocal != -32768))
       {
         mac_pm[*pm_no].desc.value.att_exp = 
            converted_to_vds (tmp, part_units,VRGL_PROJ.prj_units,
                               (double) nLocal, err_ptr);
       }
       else
         mac_pm[*pm_no].desc.value.att_exp = (double) nLocal;

       mac_pm[*pm_no].desc.type = RSM[currcol].partype;
       *pm_no += 1;
    }
    else
    if (RSM[currcol].coltype == VR_RISDB_DOUBLE)
    {
#ifdef MY_DEBUG
       printf (" DECODE FLOAT from %s\n",DbIO[currcol]);
#endif

       dLocal = VRDBdbl (DbIO[currcol]);

       if(( VRGL_PROJ.prj_units != part_units ) &&
          (dLocal != -9999) && (dLocal != -32768))
       {
         mac_pm[*pm_no].desc.value.att_exp = 
            converted_to_vds(tmp,part_units, VRGL_PROJ.prj_units,
                                      dLocal, err_ptr);
       }
       else
         mac_pm[*pm_no].desc.value.att_exp = dLocal;

       mac_pm[*pm_no].desc.type = RSM[currcol].partype;
       *pm_no += 1;
    }
  }

  iret = 1;
  strcpy(mac_pm[*pm_no].name,"units_set");
  mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
  mac_pm[*pm_no].desc.value.att_exp = VRGL_PROJ.prj_units;
  *pm_no += 1;

  wrapup:
  _FREE (RSM);
  VdsRisFreeBuffer (DbIO, rows);
  return (iret);
}

end implementation Root;

