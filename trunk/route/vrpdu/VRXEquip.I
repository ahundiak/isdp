/* $Id: VRXEquip.I,v 1.3 2002/04/15 20:01:45 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VREquipLst.c
 *
 * Description:
 * Functions accessing database to get equipments informations
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXEquip.I,v $
 *  Revision 1.3  2002/04/15 20:01:45  anand
 *  Removed version.h and associated dependencies. version.h is
 *  an include file in $EXNUC.
 *
 *  Revision 1.2  2001/02/20 01:15:08  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1999/04/05  04:08:44  pinnacle
# Replaced: vrpdu/VRXEquip.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:16  pinnacle
# Created: vrpdu/VRXEquip.I by hverstee for route
#
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.5  1996/05/07  19:14:40  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by hverstee for route240
 *
 * Revision 1.4  1996/04/22  13:57:36  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by hverstee for route240
 *
 * Revision 1.3  1996/04/04  21:43:20  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by ashankar for route240
 *
 * Revision 1.2  1996/01/17  17:31:02  pinnacle
 * Replaced: vrpdu/VREquipLst.c for:  by r240_int for route240
 *
 *
 * History:
 *  01/17/96   tlb     Add prototypes
 *  1 Apr.99   Reddy   TR179900483 - System crashes if Equiment no. more 
 *		       is more than 18 characters 
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "dberror.h"

#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRdef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbParamDef.h"
#include "VRDbTbl.h"
#include "vrpdu_pto.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

/**************************************************************/
/*   these static externals to be initialized at DB change    */
/* VRdbget_hvac_catalog_occ() */

#define         VR_EQNUM_LEN_LOCAL     30

typedef   IGRchar *    CHARPTR;

%safe
static
IGRchar         CUR_catalog[30];
static
IGRshort        nC_eqplist = 0;
static
IGRchar        *C_eqpbuff = NULL;
static
CHARPTR        *C_eqplist = NULL;
%endsafe
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Cleql ()
{
  _FREE (C_eqplist);
  _FREE (C_eqpbuff);

  nC_eqplist = 0;
  CUR_catalog[0] = '\0';

  return;
}

/**************************************************************/

IGRint VRdbGetEqOccList (
          IGRlong        *msg,          /* Message                (O)*/
          IGRchar        *catalog,      /* Catalog name           (I)*/
          IGRchar        *select_crit,  /* find with a criteria   (I)*/
          IGRchar       **EqNumber,     /* EqNumber list          (O)*/
          IGRint         *NbOcc,        /* Nb return occurrences  (O)*/
   struct VRdbEquipDesc  *occlst,       /* List of catalog occur  (O)*/
          IGRchar        *err_ptr)      /* Error Message Buffer   (O)*/
{
  IGRint         sts,i;
  IGRchar      **DbIO;
  IGRint         Num;
  IGRchar       *pWhere;
  IGRint         rows;
  IGRchar        select[50];   // *select changed to select[50] - TR179900483
  IGRchar       *ep;

SetProc(VRdbGetEqOccList ); Begin 
  ep = err_ptr;                   /*   get rid of warning   */

  if (VdsVerifyRisTable (catalog) != VDS_DBTABLE_FOUND) return (OM_E_ABORT);

  if( select_crit )
  {
    IGRchar        szWhere[50]; // Array size is increased from 30 to 50

    Num    = 2;
    strcpy(select,"eqp_descr, eqp_location"); 
    sprintf (szWhere, "eqp_number = '%s'", select_crit);
    __DBGpr_str( " szWhere is ",szWhere);
    pWhere = szWhere;

    sts =
    vdb$RisSelect (select     = select,
                   table_name = catalog,
                   where      = szWhere,
                   numselect  = 2,
                   p_numrows  = &rows,
                   p_buffer   = &DbIO);
    if (!(sts & OM_S_SUCCESS) || (rows == 0))
    {
      printf("Failed accessing %s for %s where %s\n",catalog, select, szWhere);
      *msg = VR_E_DbShortErrMsg;
      return(OM_E_ABORT);
    }

    VRDBstr (occlst->Desc, DbIO[0]);
    VRDBstr (occlst->Location, DbIO[1]);

    VdsRisFreeBuffer (DbIO, rows);
  }
  else
  {
    IGRchar      *ptr;

    if ((strcmp (CUR_catalog, catalog) == 0) &&
        (nC_eqplist > 0))
    {
       *EqNumber = (IGRchar *)C_eqplist;
       *NbOcc    = nC_eqplist;
       *msg = OM_S_SUCCESS;
       return OM_S_SUCCESS;
    }

    *NbOcc      = 0;
    *EqNumber   = (IGRchar *) NULL;

    sts =
    vdb$RisSelect (select     = "eqp_number",
                   table_name = catalog,
                   numselect  = 1,
                   p_numrows  = &rows,
                   p_buffer   = &DbIO);

    if (!(sts & OM_S_SUCCESS) || (rows == 0))
    {
      printf("Failed accessing %s for occ list.\n",catalog);
      *msg = VR_E_DbShortErrMsg;
      return(OM_E_ABORT);
    }

    if (rows != nC_eqplist)
    {
      if (nC_eqplist > 0)
      {
        C_eqpbuff = _REALLOC (C_eqpbuff, rows * VR_EQNUM_LEN_LOCAL, IGRchar);
        C_eqplist = _REALLOC (C_eqplist, rows , CHARPTR);
      }
      else
      {
        C_eqpbuff = _MALLOC (rows * VR_EQNUM_LEN_LOCAL, IGRchar);
        C_eqplist = _MALLOC (rows , CHARPTR);
      }

      if ((C_eqpbuff == NULL) || (C_eqplist == NULL)) return (OM_E_NODYNMEM);

      nC_eqplist = rows;
    }

    VRDBstr (CUR_catalog, catalog);
    *EqNumber = (IGRchar *)C_eqplist;
    *NbOcc    = nC_eqplist;

    for ( i=0; i<rows ;i++)
    {
      ptr = &(C_eqpbuff[i*VR_EQNUM_LEN_LOCAL]);

      VRDBstr (ptr, DbIO[i]);

      C_eqplist[i] = ptr;
    }

    VdsRisFreeBuffer (DbIO, rows);
  }
End
   *msg = OM_S_SUCCESS;
   return OM_S_SUCCESS;
}

/*************************************************************************/

IGRint VRdbGetEqOccur (
          IGRlong        *msg,          /* Message                (O)*/
          IGRchar        *catalog,      /* Catalog name           (I)*/
          IGRchar        *select_crit,  /* find with a criteria   (I)*/
          IGRchar        *MacroName,    /* PID macro name is returned*/
   struct VRdbEquipPart  *occlst,       /* List of catalog occur  (O)*/
          IGRchar        *err_ptr)      /* Error Message Buffer   (O)*/
{
  IGRint         sts;
  IGRchar      **DbIO;
  IGRint         Num;
  IGRchar        szWhere[300];
  IGRint         rows;
  IGRchar       *select;
  IGRchar       *ep;

  ep = err_ptr;                   /*   get rid of warning   */

  if (VdsVerifyRisTable (catalog) != VDS_DBTABLE_FOUND) return (OM_E_ABORT);

  sprintf (szWhere," eqp_number = '%s'", select_crit);

  if( MacroName )
  {
    select = "macro_name";
    Num    = 1;
  }
  else
  {
    select = "eqp_family, eqp_partno, eqp_partrev";
    Num    = 3;
  }

  sts =
  vdb$RisSelect (select     = select,
                 table_name = catalog,
                 where      = szWhere,
                 numselect  = Num,
                 p_numrows  = &rows,
                 p_buffer   = &DbIO);

  if (!(sts & OM_S_SUCCESS) || (rows == 0))
  {
    printf("Failed accessing %s from %s.\n",select,catalog);
    *msg = VR_E_DbShortErrMsg;
    return(OM_E_ABORT);
  }

  if( MacroName )
  {
    VRDBstr (MacroName, DbIO[0]);
  }
  else
  {
    VRDBstr (occlst->Familly, DbIO[0]);
    VRDBstr (occlst->PartNb , DbIO[1]);
    VRDBstr (occlst->PartRev, DbIO[2]);
  }

  VdsRisFreeBuffer (DbIO, rows);

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}


end implementation Root;
