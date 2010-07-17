/* $Id: VRhvdbpb.I,v 1.3 2002/04/15 20:01:46 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRhvdbpb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRhvdbpb.I,v $
 *  Revision 1.3  2002/04/15 20:01:46  anand
 *  Removed version.h and associated dependencies. version.h is
 *  an include file in $EXNUC.
 *
 *  Revision 1.2  2001/02/20 01:15:16  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1999/04/30  21:51:04  pinnacle
# traceFlag 150
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/12/10  17:06:52  pinnacle
# Replaced: vrpdu/VRhvdbpb.I for:  by r250_int for route
#
# Revision 1.3  1997/12/05  20:54:26  pinnacle
# Replaced: vrpdu/*.I for: AXFAN crash in 02.04.03.04 03-Nov-97 by aharihar for route
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/22  13:50:20  pinnacle
# Replaced: vrpdu/VRhvdbpb.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  17:30:06  pinnacle
# Replaced: vrpdu/VRhvdbpb.I for:  by r240_int for route240
#
 *
 * History:
 *  01/17/96  tlb    Add prototypes, Change to ANSII style: VRaccess_hvac_db
 *  12/06/98 Anand   'occlst' now passed as triple pointer to char in
 *                   VRdbGetHvCatOccList
 *  04/30/99   ah    Added traceFlag 150
 *
 *************************************************************************/
class implementation Root;

#include  <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "AS_status.h"
#include "gr.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "dberror.h"

#include "VDmem.h"
#include "VDDbDef.h"
#include "vdbmacros.h"
#include "vrdbgmacros.h"

#include "VRdef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbParamDef.h"
#include "VRDbTbl.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"

#include "vrpdu_pto.h"

/*#define DEBUG 1  */

from NDnode             import  NDchg_state;
from ACrg_collect       import  ACshow_data;
 
static int traceFlag;

/**************************************************************/
/*   these static externals to be initialized at DB change    */
/* VRdbget_hvac_catalog_occ() */

#define      VR_HVCATOCCLIST_CHAR      50

%safe
static
IGRchar         C_cat[20] = "";
static
IGRshort        nC_catlist = 0;
static
IGRchar        *C_catlist = NULL;
%endsafe
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clhdb ()
{
  C_cat[0]   = '\0';
  nC_catlist = 0;

  _FREE (C_catlist);

  return;
}
/**************************************************************/

/************************************************************************
 *                                                                      *
 * For application HVAC only:                                           *
 *                                                                      *
 * This routine extracts parameters from the reference database and     *
 * constructs and returns a parameter box or returns an array of        *
 * structures of the select criteria needed for accessing the HVAC      *
 * catalog.                                                             *
 *                                                                      *
 ************************************************************************/
IGRint VRaccess_hvac_db (
   IGRlong             *msg,         /* message                      (O)  */
   IGRchar             *spec_name,   /* hvac class                   (I)  */
   IGRchar             *comp_name,   /* AABBCC code                  (I)  */
   IGRshort            option,       /* shape code                   (I)  */
   IGRchar             *fam_name,    /* macro name/catalog name      (O)  */
   IGRshort            *comp_topo,   /* component topology           (O)  */
   IGRshort            *comp_type,   /* component reporting category (O)  */
   struct GRid         *pbid,        /* parameter box (I=osnum)    (I/O)  */  
   struct VRSelectAttr seldat[],     /* Hvac catalog select criteria (I)  */
   IGRshort            *crit_no,     /* No.of select criteria        (I)  */
   IGRchar             *err_ptr      /* error message buffer         (O)  */
   )
{
  struct ACrg_coll   mac_pm[MAX_MACRO_PARAMS];  /* struct for params    */
  IGRint             pm_no;        /* Count for the mac_pm struct       */
  IGRint             sts;

  SetProc( VRaccess_hvac_db ); Begin

  traceFlag = VDdbgGetTraceFlag(150);

  if (traceFlag) {
    printf(">>> VRaccess_hvac_db\n");
  }
  
  pm_no = 0;     /* Initialize the count for the mac_pm struct */

  VR$HDB_SET (p_msg = msg);

  if (*msg != MSSUCC)
  {
    if (traceFlag) {
      printf("*** VRaccess_hvac_db, VR$HDB_SET error\n");
    }
    End
    return(OM_E_ABORT);
  }

  __DBGpr_com("Entering the  access_hvac");

  /* Get data from VDS tables */
  sts = access_hvac ( spec_name, comp_name, option, fam_name, comp_topo,
                      comp_type, mac_pm, &pm_no, seldat, crit_no, err_ptr );
  if (sts != 1)
  {
    *msg = VR_E_DbShortErrMsg;
    if (traceFlag) {
      printf("*** VRaccess_hvac_db, access_hvac error\n");
    }

    End
    return ( OM_E_ABORT );
  }

  /* Create the parameter box */
  pbid->objid = NULL_OBJID;

  __DBGpr_com("About to execute VR$ModifyCollection");

  sts = 
  VR$ModifyCollection (p_msg       = msg,
                     Operation     = VR_MERGE_COLL,
            p_ParamsListToModify   = mac_pm,
                NbParamsToModify   = pm_no,
            p_OutputCollectionId   = pbid );

#ifdef vdsDEBUG
  printf("pbid = %d %d\n", pbid->objid, pbid->osnum );
 
  sts = om$send( msg      = message ACrg_collect.ACshow_data( msg ),
                    senderid = NULL_OBJID,
                    targetid = pbid->objid,
                    targetos = pbid->osnum );
#endif
  if (traceFlag) {
    printf("pbid = %d %d\n", pbid->objid, pbid->osnum );
    sts = om$send( msg      = message ACrg_collect.ACshow_data( msg ),
		   senderid = NULL_OBJID,
		   targetid = pbid->objid,
		   targetos = pbid->osnum );
  }
  
  sts =
  om$send( msg = message NDnode.NDchg_state(
                                ( (IGRchar)  ND_DEL_NO_CH ),
                                ( (IGRchar) ~ND_DEL_NO_CH ) ),
    senderid = NULL_OBJID,
    targetid = pbid->objid,
    targetos = pbid->osnum ) ;

  *msg = ACC_S_SUCCESS;
  if (traceFlag) {
    printf("### VRaccess_hvac_db, worked\n");
  }

  End
  return sts;
}

IGRint VRdbaccess_hvac (
   IGRlong             *mesg,        /* message                      (O)  */
   IGRchar             *comp_name,   /* component code               (I)  */
   IGRchar             *catalog,     /* Hvac catalog name            (I)  */
   IGRchar             *cat_occ,     /* Catalog occurence            (I)  */
   struct VRSelectAttr seldata[],    /* Hvac catalog select criteria (I)  */
   IGRshort            *crit_no,     /* No.of select criteria        (I)  */
   IGRchar             *fam_name,    /* family or macro name         (O)  */
   IGRshort            *comp_topo,   /* component topology           (O)  */
   IGRshort            *comp_type,   /* component reporting category (O)  */
   struct GRid         *pbid,        /* parameter box (I=osnum)    (I/O)  */  
   IGRchar             *err_ptr)     /* error message buffer         (O)  */
    
{
  IGRint              pm_no;        /* Count for the mac_pm struct       */
  IGRlong             msg;
  IGRint              sts;
  IGRchar             cat_search[MAX_WHERE_SIZE];
  IGRshort            NN;

  struct ACrg_coll    mac_pm[MAX_MACRO_PARAMS];  /* struct for params    */
  struct VRHDB_ct_key CtK;
  struct VRHDB_ct     CtR;

  pm_no = 0;     /* Initialize the count for the mac_pm struct */
  sts   = 0;

  /* Store Catalog name in mac_pm     */

  strcpy(mac_pm[pm_no].name, VR_N_CATAL_NAME_AN);
  mac_pm[pm_no].desc.type = AC_ATTRIB_TEXT;
  strcpy(mac_pm[pm_no].desc.value.att_txt, catalog);
  pm_no += 1;

  /*-----------------------------------*/
  /* ACCESS THE HVAC COMP TYPE TABLE   */
  /*-----------------------------------*/

  strcpy (CtK.comp_code, comp_name);
  strcpy (CtK.sh_code, "");

  VR$HDB_CT (p_msg = mesg,
             keyin = &CtK,
             p_num = &NN,
             p_rec = &CtR);

  if ((*mesg != MSSUCC) || (NN == 0))
  {
     *mesg = VR_E_DbShortErrMsg;
     return(OM_E_ABORT);
  }   
    
  /* Format input buffer */

  *comp_topo = CtR.data.ct_topo;
  strcpy(mac_pm[pm_no].name,VR_N_COMP_TOPO_IN);
  mac_pm[pm_no].desc.type = AC_ATTRIB_DOUBLE;
  mac_pm[pm_no].desc.value.att_exp = (double) CtR.data.ct_topo;
  pm_no += 1;

  *comp_type = CtR.data.ct_cat;
  strcpy(mac_pm[pm_no].name,VR_N_COMP_TYPE_IN);
  mac_pm[pm_no].desc.type = AC_ATTRIB_DOUBLE;
  mac_pm[pm_no].desc.value.att_exp = (double) CtR.data.ct_cat;
  pm_no += 1;

  if(cat_occ[0] == 0 )
     VRdbform_hvac_dyn_search_str ( seldata, crit_no, cat_search );
  else
     sprintf(cat_search, "partnum = '%s'", cat_occ );

  sts = VRdbacc_hvac_catalog ( catalog, cat_search, fam_name, mac_pm, 
                                &pm_no, err_ptr );
  if( sts != 1 )
  {
      *mesg = VR_E_DbShortErrMsg;
      return( OM_E_ABORT );
  }

  pbid->objid = NULL_OBJID;

  sts = 
  VR$ModifyCollection (p_msg       = &msg,
                     Operation     = VR_MERGE_COLL,
            p_ParamsListToModify   = mac_pm,
                NbParamsToModify   = pm_no,
            p_OutputCollectionId   = pbid );

  sts =
  om$send( msg = message NDnode.NDchg_state(
                                  ( (IGRchar)  ND_DEL_NO_CH ),
                                  ( (IGRchar) ~ND_DEL_NO_CH ) ),
    senderid = NULL_OBJID,
    targetid = pbid->objid,
    targetos = pbid->osnum ) ;
     
  *mesg = OM_S_SUCCESS;
  return ( OM_S_SUCCESS );

}


IGRint VRdbGetHvCatOccList (
   IGRlong             *msg,         /* Message                       (O)  */
   IGRchar             *catalog,     /* Hvac Catalog name             (I)  */
   IGRchar             ***occList,     /* List of catalog occurences    (O)  */
   IGRshort            *listsize,    /* No. of catalog occurences     (O)  */
   IGRchar             *err_ptr)     /* Error Message Buffer          (O)  */
{
  /************************************************************************/
  /*                                                                      */
  /* This routine returns the list of occurences in the catalog of a Hvac */
  /* component whose catalog name is given                                */
  /*                                                                      */
  /************************************************************************/

  IGRchar      **DbIO;
  IGRchar      **occlst = NULL ; /* Variable added by Anand */
  IGRint         NbRow;
  IGRint         sts,i;
  IGRchar       *ep;

  SetProc( VRdbGetHvCatOccList ); Begin
 
  /* Initialize */

  *listsize = 0;
  DbIO = NULL;
  ep   = err_ptr;   /*  get rid of warning   */

  if( !(strcmp(catalog, C_cat )) )
  {
     *listsize = nC_catlist;
     __DBGpr_int("No. of catalog occurences",*listsize);

//     *occlst   = C_catlist;
/* Above line just doesn't work! Commented by Anand. */
 
     occlst = _MALLOC( nC_catlist , IGRchar* );
 
     for( i=0 ; i < nC_catlist ; i=i+1)
     {
         __DBGpr_str("C_catlist",&C_catlist[i*VR_HVCATOCCLIST_CHAR]);
         occlst[i] = _MALLOC( VR_HVCATOCCLIST_CHAR , IGRchar );
         VRDBstr(occlst[i],&C_catlist[i*VR_HVCATOCCLIST_CHAR]);
         __DBGpr_str("occlist",occlst[i]);
     }
  }
  else
  {
    sts =
    vdb$RisSelect (select     = "partnum",
                   table_name = catalog,
                   numselect  = 1,
                   p_numrows  = &NbRow,
                   p_buffer   = &DbIO);

    if (!(sts & OM_S_SUCCESS) || (NbRow == 0))
    {
      *msg = VR_E_DbShortErrMsg;

      End
      return(OM_E_ABORT);
    }

    if (NbRow != nC_catlist)
    {
      if (C_catlist == NULL)
        C_catlist = _MALLOC (NbRow * VR_HVCATOCCLIST_CHAR, IGRchar);
      else
        C_catlist = _REALLOC(C_catlist, NbRow * VR_HVCATOCCLIST_CHAR, IGRchar);

      nC_catlist = NbRow;
    }

    for ( i=0; i<NbRow; i++)
    {       
      VRDBstr (&C_catlist[i * VR_HVCATOCCLIST_CHAR], DbIO[i]);

      if (C_catlist[i * VR_HVCATOCCLIST_CHAR] == '\0')
        strcpy (&C_catlist[i * VR_HVCATOCCLIST_CHAR], " ");
    }

    VdsRisFreeBuffer (DbIO, NbRow);

    *listsize = nC_catlist;
     __DBGpr_int("Number of catalog occurences",*listsize);

//    *occlst   = C_catlist;
/* Above line commented by Anand */
 
     occlst = _MALLOC( nC_catlist , IGRchar* );
 
     for( i=0 ; i < nC_catlist ; i=i+1)
     {
         __DBGpr_str("C_catlist",&C_catlist[i*VR_HVCATOCCLIST_CHAR]);
         occlst[i] = _MALLOC( VR_HVCATOCCLIST_CHAR , IGRchar );
         VRDBstr(occlst[i],&C_catlist[i*VR_HVCATOCCLIST_CHAR]);
         __DBGpr_str("occlist",occlst[i]);
     }
 

    strcpy(C_cat, catalog );
  }

  *occList = occlst ; /* This line added by Anand */

  *msg = OM_S_SUCCESS;

  End
  return OM_S_SUCCESS;
}
        
end implementation Root;
