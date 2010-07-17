/* $Id: VRrwdbpb.I,v 1.1.1.1 2001/01/04 21:13:02 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRrwdbpb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRrwdbpb.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:43:38  pinnacle
# Created: vrpdu/VRrwdbpb.I by hverstee for route
#
 *
 * History:
 *  06/24/97  hv   Created from VRhvdbpb.I
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
#include "version.h"

#include "VDmem.h"
#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRdef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbParamDef.h"
#include "VRDbTbl.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"

#include "vrpdu_pto.h"

from NDnode  import  NDchg_state;

/**************************************************************/
/*   these static externals to be initialized at DB change    */
/* VRdbget_rway_catalog_occ() */

#define      VR_RWCATOCCLIST_CHAR      50

%safe
static
IGRchar         R_cat[20] = "";
static
IGRshort        nR_catlist = 0;
static
IGRchar        *R_catlist = NULL;
%endsafe
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clrdb ()
{
  R_cat[0]   = '\0';
  nR_catlist = 0;

  _FREE (R_catlist);

  return;
}
/**************************************************************/

/************************************************************************
 *                                                                      *
 * For application RWAY only:                                           *
 *                                                                      *
 * This routine extracts parameters from the reference database and     *
 * constructs and returns a parameter box or returns an array of        *
 * structures of the select criteria needed for accessing the RWAY      *
 * catalog.                                                             *
 *                                                                      *
 ************************************************************************/
IGRint VRaccess_rway_db (
   IGRlong             *msg,         /* message                      (O)  */
   IGRchar             *spec_name,   /* rway class                   (I)  */
   IGRchar             *comp_name,   /* AABBCC code                  (I)  */
   IGRdouble            dWidth1,
   IGRdouble            dDepth1,
   IGRdouble            dWidth2,
   IGRdouble            dDepth2,
   IGRshort             nShape,      /* shape code                   (I)  */
   IGRchar             *fam_name,    /* macro name/catalog name      (O)  */
   IGRshort            *comp_topo,   /* component topology           (O)  */
   IGRshort            *comp_type,   /* component reporting category (O)  */
   struct GRid         *pbid,        /* parameter box (I=osnum)    (I/O)  */  
   struct VRSelectAttr seldat[],     /* Rway catalog select criteria (I)  */
   IGRshort            *crit_no,     /* No.of select criteria        (I)  */
   IGRchar             *err_ptr      /* error message buffer         (O)  */
   )
{
  struct ACrg_coll   mac_pm[MAX_MACRO_PARAMS];  /* struct for params    */
  IGRint             pm_no;        /* Count for the mac_pm struct       */
  IGRint             sts;

  pm_no = 0;     /* Initialize the count for the mac_pm struct */

  VR$RDB_SET (p_msg = msg);

  if (*msg != MSSUCC) return(OM_E_ABORT);

  /* Get data from VDS tables */
  sts = access_rway ( spec_name, comp_name, dWidth1, dDepth1, dWidth2, dDepth2,
                      nShape, fam_name, comp_topo, comp_type,
                      mac_pm, &pm_no, seldat, crit_no, err_ptr );
  if (sts != 1)
  {
    *msg = VR_E_DbShortErrMsg;
    return ( OM_E_ABORT );
  }
     
  /* Create the parameter box */
  pbid->objid = NULL_OBJID;

  sts = 
  VR$ModifyCollection (p_msg       = msg,
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

  *msg = ACC_S_SUCCESS;
  return sts;
}

IGRint VRdbaccess_rway (
   IGRlong             *mesg,        /* message                      (O)  */
   IGRchar             *comp_name,   /* component code               (I)  */
   IGRdouble            dWidth1,
   IGRdouble            dDepth1,
   IGRdouble            dWidth2,
   IGRdouble            dDepth2,
   IGRchar             *catalog,     /* Rway catalog name            (I)  */
   IGRchar             *cat_occ,     /* Catalog occurence            (I)  */
   struct VRSelectAttr seldata[],   /* Rway catalog select criteria (I)  */
   IGRshort            *crit_no,      /* No.of select criteria        (I)  */
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
  IGRdouble           dDUMM;

  struct ACrg_coll    mac_pm[MAX_MACRO_PARAMS];  /* struct for params    */
  struct VRRDB_ct_key CtK;
  struct VRRDB_ct     CtR;

  pm_no = 0;     /* Initialize the count for the mac_pm struct */
  sts   = 0;

  /*   later use for sizes???   */

  dDUMM = dWidth1;
  dDUMM = dDepth1;
  dDUMM = dWidth2;
  dDUMM = dDepth2;

  /* Store Catalog name in mac_pm     */

  strcpy(mac_pm[pm_no].name, VR_N_CATAL_NAME_AN);
  mac_pm[pm_no].desc.type = AC_ATTRIB_TEXT;
  strcpy(mac_pm[pm_no].desc.value.att_txt, catalog);
  pm_no += 1;

  /* ACCESS THE RWAY COMP TYPE TABLE   */
  /*-----------------------------------*/

  strcpy (CtK.comp_code, comp_name);
  strcpy (CtK.sh_code, "");
  CtK.comp_type = VRRDB_UNDEF;

  VR$RDB_CT (p_msg = mesg,
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
  /*    this function is misnamed, hvac/rway catalog access.... */
     VRdbform_hvac_dyn_search_str ( seldata, crit_no, cat_search );
  else
     sprintf(cat_search, "partnum = '%s'", cat_occ );

  /*    this function is misnamed, hvac/rway catalog access.... */
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

/*    for later use, see vrco     */

IGRint VRdbGetRwCatOccList (
   IGRlong             *msg,         /* Message                       (O)  */
   IGRchar             *catalog,     /* Rway Catalog name             (I)  */
   IGRchar             **occlst,     /* List of catalog occurences    (O)  */
   IGRshort            *listsize,    /* No. of catalog occurences     (O)  */
   IGRchar             *err_ptr)     /* Error Message Buffer          (O)  */
{
  /************************************************************************/
  /*                                                                      */
  /* This routine returns the list of occurences in the catalog of a Rway */
  /* component whose catalog name is given                                */
  /*                                                                      */
  /************************************************************************/

  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         sts,i;
  IGRchar       *ep;

  /* Initialize */

  *listsize = 0;
  DbIO = NULL;
  ep   = err_ptr;   /*  get rid of warning   */

  if( !(strcmp(catalog, R_cat )) )
  {
     *listsize = nR_catlist;
     *occlst   = R_catlist;
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
      return(OM_E_ABORT);
    }

    if (NbRow != nR_catlist)
    {
      if (R_catlist == NULL)
        R_catlist =
           _MALLOC (NbRow * VR_RWCATOCCLIST_CHAR, IGRchar);
      else
        R_catlist =
           _REALLOC (R_catlist, NbRow * VR_RWCATOCCLIST_CHAR, IGRchar);

      nR_catlist = NbRow;
    }

    for ( i=0; i<NbRow; i++)
    {       
      VRDBstr (&R_catlist[i * VR_RWCATOCCLIST_CHAR], DbIO[i]);

      if (R_catlist[i * VR_RWCATOCCLIST_CHAR] == '\0')
        strcpy (&R_catlist[i * VR_RWCATOCCLIST_CHAR], " ");
    }

    VdsRisFreeBuffer (DbIO, NbRow);

    *listsize = nR_catlist;
    *occlst   = R_catlist;

    strcpy(R_cat, catalog );
  }

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}
        
end implementation Root;
