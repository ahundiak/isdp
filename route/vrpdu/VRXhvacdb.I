/* $Id: VRXhvacdb.I,v 1.2 2001/02/20 01:15:19 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRhvacdb.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXhvacdb.I,v $
 *  Revision 1.2  2001/02/20 01:15:19  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/05  20:54:26  pinnacle
# Replaced: vrpdu/*.I for: AXFAN crash in 02.04.03.04 03-Nov-97 by aharihar for route
#
# Revision 1.1  1997/08/15  19:43:00  pinnacle
# Created: vrpdu/VRXhvacdb.I by hverstee for route
#
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.6  1996/04/22  13:57:54  pinnacle
 * Replaced: vrpdu/VRhvacdb.c for:  by hverstee for route240
 *
 * Revision 1.5  1996/01/17  17:31:14  pinnacle
 * Replaced: vrpdu/VRhvacdb.c for:  by r240_int for route240
 *
 *
 * History:
 *  01/17/96   tlb  Add prototypes
 *  12/06/97 Anand  Moved up the call to VdsRisFreeBuffer in VRdbRisCol
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "dberror.h"

#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "VDmem.h"
#include "VDSris_def.h" 
#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRdef.h"
#include "VRmsg.h"
#include "VRDbStruct.h"
#include "VRDbTbl.h"
#include "vrpdu_pto.h"
#include "vrdbgmacros.h"

/*   #include "sql.h" This is for RIS 4.0 */
/*   *include "ris.h" See note below      */

#define VRSEPARATOR  ','
#define VRRANGECHAR  'R'

/*
#define MY_DEBUG
*/

/**************************************************************/
/*   Because the RIS developers in their unending wisdom      */
/*   decided to create ris.h in such a manner that inclusion  */
/*   in a .I file yields syntax errors I have duplicated the  */
/*   following #defines.......        HV 6/20/97              */
/**************************************************************/

#define RIS_UNKNOWN_TYPE                0
#define RIS_CHARACTER                   1
#define RIS_DECIMAL                     3
#define RIS_INTEGER                     4
#define RIS_SMALLINT                    5
#define RIS_FLOAT                       6   /* Currently Unsupported        */
#define RIS_REAL                        7
#define RIS_DOUBLE                      8
#define RIS_TEXT                        16

/**************************************************************/
/*   these static externals to be initialized at DB change    */
%safe
static
IGRint           nCOL = 0;

static
IGRchar          CUR_tabnam[30];

static
struct VRriscol  *COL = NULL;
%endsafe
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_ClCdl ()
{

  CUR_tabnam[0] = '\0';

  nCOL = 0;

  _FREE (COL);

  return;
}
/**************************************************************/



/**************************************************************/

int VRDbParseSel (char         *crit_str,  /* Criteria string           (I) */
           struct VRSelectAttr  seldata[], /* Select Criteria structure (O) */
                  short        *crit_no)   /* No of select criteria     (O) */

{
   /*********************************************************************/
   /*                                                                   */
   /* This routine parses the select criteria string, extracts the      */
   /* code_nums, determine range dependencies and returns the number    */
   /* of select criteria                                                */
   /*                                                                   */
   /*********************************************************************/

  short         nEnd=0;
  short         nIndexAttr = 0;
  char          *p_cSep=NULL, *p_cAttr;
  char          *strchr();

  *crit_no = 0;
  if ( !crit_str ) return 1;

  /* point on first attribute */
  p_cAttr = crit_str;

  /* look for separator */

  while (!nEnd)
  {
        /* restore separator */
        if (p_cSep)     *p_cSep = VRSEPARATOR;


        if ( ! (p_cSep = strchr(p_cAttr,VRSEPARATOR)))
        {
                nEnd=1;
                /* Points on the end */
                p_cSep = &p_cAttr[strlen(p_cAttr)];
        }

        /* isolate attribute */
        *p_cSep = '\0';

        /* look for range character */
        if ( *(p_cSep-1) == VRRANGECHAR && *(p_cSep-2) == ' ')
        {
                seldata[nIndexAttr].range = 1;
                *(p_cSep-2) = '\0';
                /* store attribute name */
                strcpy(seldata[nIndexAttr].sel.name, p_cAttr);
                /* restore criteria string */
                *(p_cSep-2) = ' ';
                *(p_cSep-1) = VRRANGECHAR;
        }
        else
        {
            seldata[nIndexAttr].range = 0;
            /* store attribute number */
            strcpy(seldata[nIndexAttr].sel.name, p_cAttr);
        }

        /* point on next attribute */
        nIndexAttr++;
        p_cAttr = p_cSep+1;

  }/* end while */

  *crit_no = nIndexAttr;
  return (1);
}



int VRdbform_hvac_dyn_search_str (
   struct VRSelectAttr  seldata[], /* Select criteria structure  (I) */
   short                 *crit_no,  /* No. of select criteria     (I) */
   char                  *search)   /* Search string              (O) */
{
  /*****************************************************************/
  /*                                                               */
  /* This routine forms the dynamic search string for accessing    */
  /* HVAC catalog                                                  */
  /*                                                               */
  /*****************************************************************/
   
  IGRint        i;
  IGRchar       tmp_str[100];
  IGRchar       szconn[8];

  search[0] = '\0';

  strcpy (szconn, " ");

  for (i=0; i<*crit_no; i++)
  {
    if(seldata[i].type == VR_RISDB_TEXT)
    {
      strcat(search, szconn);

      sprintf(tmp_str, "%s = '%s'",
         seldata[i].sel.name, seldata[i].sel.desc.value.att_txt);
      strcat(search, tmp_str);

      strcpy (szconn, " and ");
    }
    else
    if(seldata[i].type == VR_RISDB_INT)
    {
      strcat(search, szconn);

      if(seldata[i].range)
      {
        sprintf(tmp_str, "%d between %s_min and %s_max",
                      (int)seldata[i].sel.desc.value.att_exp, 
                       seldata[i].sel.name, 
                       seldata[i].sel.name );
      }
      else
      {
        sprintf(tmp_str, "%s = %d", seldata[i].sel.name, 
                      (int)seldata[i].sel.desc.value.att_exp);    
      }
      strcat(search, tmp_str);
      strcpy (szconn, " and ");
    }
    else
    if(seldata[i].type == VR_RISDB_DOUBLE)
    {
      strcat(search, szconn);
      if(seldata[i].range)
      {
        sprintf(tmp_str, "%lf between %s_min and %s_max",
                      seldata[i].sel.desc.value.att_exp, 
                      seldata[i].sel.name, 
                      seldata[i].sel.name );
      }
      else
      {
        sprintf(tmp_str, "%s = %lf", seldata[i].sel.name, 
                      seldata[i].sel.desc.value.att_exp);    
      }
      strcat(search, tmp_str);
      strcpy (szconn, " and ");
    }
  }

  return (1);

}
 

int VRdbacc_hvac_catalog (
   char     *catalog,             /* hvac catalog name             (I)   */
   char     *search,              /* search string "where .."      (I)   */
   char     *macro_name,          /* Macro name                    (O)   */
   struct ACrg_coll mac_pm[],     /* macro parameters              (O)   */
   int      *pm_no,               /* No. of params in mac_pm       (I/O) */
   char     *err_ptr)             /* Error message buffer          (O)   */
{
  IGRchar       dum;
  IGRint        currcol;
  IGRint        i;
  IGRint        sts;
  IGRlong       retmsg;
  IGRint        iret;
  IGRint        nCol;
  IGRint        iCol;
  IGRchar       szSelect[300];
  IGRchar     **DbIO;
  IGRint        rows;
  IGRchar      *ep;

  struct VRriscol   *RSC;
  struct VRriscol   *RSM;

  SetProc( VRdbacc_hvac_catalog ); Begin

  ep   = err_ptr;                   /*   get rid of warning   */
  dum  = macro_name[0];
  RSM  = NULL;
  iCol = 0;
  iret = 0;

   
  __DBGpr_str( " catalog name ", catalog );
  __DBGpr_str( " search string ", search );
 
  if (VdsVerifyRisTable (catalog) != VDS_DBTABLE_FOUND)
  {
    for( i=0; i<strlen(catalog); i++ )
      catalog[i] = tolower(catalog[i]);
 
    __DBGpr_str( "revised catalog name ", catalog );
 
    if (VdsVerifyRisTable (catalog) != VDS_DBTABLE_FOUND)
       goto wrapup;
  }

  sts = VRdbRisCol (&retmsg, catalog, &nCol, &RSC);
  if (!(sts & OM_S_SUCCESS) || (nCol == 0))
  {
    __DBGpr_com( " VRdbRisCol  failed " );
    goto wrapup;
  }

  RSM = _MALLOC (nCol, struct VRriscol);

  for (i=0; i< nCol; i++)
  {
    if(strncmp(RSC[i].colname, "p_", 2) == 0 ||
       strncmp(RSC[i].colname,"n_", 2) == 0   )     continue;

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

  sts =
  vdb$RisSelect (select     = szSelect,
                 table_name = catalog,
                 where      = search,
                 numselect  = iCol,
                 p_numrows  = &rows,
                 p_buffer   = &DbIO);

  if (!(sts & OM_S_SUCCESS) || (rows == 0)) goto wrapup;

  /* Load parameters into mac_pm */

  currcol = 0;

  __DBGpr_int( " No. of Rows ", rows );

  for (currcol = 0; currcol < iCol; currcol++)
  {
    __DBGpr_str( " Attribute name ", RSM[currcol].colname );

    VRDBstr(mac_pm[*pm_no].name, RSM[currcol].colname);

    if(RSM[currcol].coltype == VR_RISDB_TEXT)
    {
      __DBGpr_str( " Attr. Text ", DbIO[currcol] );

      VRDBstr(mac_pm[*pm_no].desc.value.att_txt, DbIO[currcol]);
      mac_pm[*pm_no].desc.type = RSM[currcol].partype;
      *pm_no += 1;
    }
    else
    if(RSM[currcol].coltype == VR_RISDB_INT)
    {
      __DBGpr_str( " Attr. int ", DbIO[currcol] );

      mac_pm[*pm_no].desc.value.att_exp = (double) VRDBint (DbIO[currcol]);
      mac_pm[*pm_no].desc.type = RSM[currcol].partype;
      *pm_no += 1;
    }
    else
    if(RSM[currcol].coltype == VR_RISDB_DOUBLE)
    {
      __DBGpr_str( " Attr. double ", DbIO[currcol] );

      mac_pm[*pm_no].desc.value.att_exp = VRDBdbl (DbIO[currcol]);
      mac_pm[*pm_no].desc.type = RSM[currcol].partype;
      *pm_no += 1;
    }
  }

  iret = 1;

  VdsRisFreeBuffer (DbIO, rows);

  wrapup:
  _FREE (RSM);
  return (iret);
}

int VRdbGetRisColType (
    char    *table_name,  /* table name                       (I) */
    char    *param_name,  /* Parameter name                   (I) */
    short   *range,       /* Range flag                       (I) */
    short   *param_type,  /* Parameter data type              (O) */
    short   *type,        /* Parameter data type for ACrg_coll(O) */
    char    *err_ptr)     /* Error message  buffer            (O) */
{
  IGRint        sts;
  IGRint        i;
  IGRchar       column_name[100];
  IGRlong       retmsg;
  IGRint        nCol;
  IGRint        iret;
  IGRchar      *ep;

  struct VRriscol   *RSC;

  ep = err_ptr;

  iret = 0;

  sts = VRdbRisCol (&retmsg, table_name, &nCol, &RSC);

  if ((sts & OM_S_SUCCESS) && (nCol > 0))
  {
    /* FORM THE COLUMN NAME  */

    if(*range == 1)
      sprintf(column_name, "%s_min", param_name);
    else
      sprintf(column_name, "%s", param_name);
 
    for (i=0; i<nCol; i++)
    {
      if (strcmp (column_name, RSC[i].colname) == 0)
      {
        *param_type = RSC[i].coltype;
        *type       = RSC[i].partype;
        iret = 1;
        break;
      }
    }
  }

  return (iret);
}


/**************************************************************/

IGRint   VRdbRisCol (IGRlong     *msg,
                     IGRchar     *tabnam,
                     IGRint      *nNum,
              struct VRriscol   **RSC)
{
  IGRint         sts,i;
  IGRchar      **DbIO;
  IGRint         rows;
  IGRint         RIStp;
  IGRchar        szWhere[30];

  *msg  = MSFAIL;
  *nNum = 0;
  rows = 0;
  szWhere[0] ='\0';

#ifdef MY_DEBUG
  printf ("into riscols\n");
#endif
  sprintf (szWhere, "table_name = '%s'",tabnam);

  if (VdsVerifyRisTable (VRDB_RISCOLUMNS) != VDS_DBTABLE_FOUND)
                  return (OM_E_ABORT);

  if (strcmp (tabnam, CUR_tabnam) == 0)
  {
    *nNum = nCOL;

    if (RSC)
    {
      *RSC = COL;
    }
  }
  else
  {
    *nNum = 0;

    sts =
    vdb$RisSelect (select     = "ris_type,column_name",
                   table_name = VRDB_RISCOLUMNS,
                   where      = szWhere,
                   numselect  = 2,
                   p_numrows  = &rows,
                   p_buffer   = &DbIO);
    if (!(sts & OM_S_SUCCESS) || (rows == 0))
    {
      *msg = VR_E_DbShortErrMsg;
      return(OM_E_ABORT);
    }

    _FREE (COL);

    COL = _MALLOC (rows, struct VRriscol);
    if (COL == NULL) return (OM_E_NODYNMEM);

    for (i=0; i<rows; i++)
    {
      RIStp = VRDBint (DbIO[i*2]);

      VRDBstr (COL[i].colname, DbIO[i*2 + 1]);

      switch (RIStp)
      {
        case RIS_CHARACTER:
        case RIS_TEXT:
          COL[i].coltype = VR_RISDB_TEXT;
          COL[i].partype = AC_ATTRIB_TEXT;
          break;
        case RIS_FLOAT:
        case RIS_REAL:
        case RIS_DOUBLE:
          COL[i].coltype = VR_RISDB_DOUBLE;
          COL[i].partype = AC_ATTRIB_DOUBLE;
          break;
        case RIS_DECIMAL:
        case RIS_INTEGER:
        case RIS_SMALLINT:
        default:
          COL[i].coltype = VR_RISDB_INT;
          COL[i].partype = AC_ATTRIB_DOUBLE;
          break;
      }
#ifdef MY_DEBUG
      printf ("RISCOLS %s %d %d\n",COL[i].colname, COL[i].coltype,
                     COL[i].partype);
#endif

    }

    if (RSC)
      *RSC = COL;

    CUR_tabnam[0]='\0';

    strcpy (CUR_tabnam, tabnam);
    *nNum = nCOL = rows;

    VdsRisFreeBuffer (DbIO, rows);

/* DbIO should be freed only when it is allocated. It should be inside this
   else loop. Call to free DbIO pushed up by Anand */

#ifdef MY_DEBUG
  printf ("from riscols %d rows\n",rows);
#endif

  }

  return (OM_S_SUCCESS);
}

end implementation Root;

