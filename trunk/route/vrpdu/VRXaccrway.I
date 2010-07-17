/* $Id: VRXaccrway.I,v 1.3 2001/02/20 01:15:13 build Exp $  */

/* I/ROUTE
 *
 * File:        vrpdu/VRaccrway.c
 *
 * Description:
 *
 *      Access VDS database for rway component and parameters.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRXaccrway.I,v $
 *      Revision 1.3  2001/02/20 01:15:13  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/12 23:22:29  anand
 *      SP merge
 *
# Revision 1.1  2000/05/23  23:30:38  pinnacle
# Created: route/vrpdu/VRXaccrway.I by lawaddel for Service Pack
#
# Revision 1.3  1999/10/01  18:59:28  pinnacle
# Replaced: vrpdu/VRXaccrway.I for: TR 179900778 by aharihar for route
#
# Revision 1.2  1999/05/24  20:36:48  pinnacle
# Replaced: vrpdu/VRXaccrway.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:42:32  pinnacle
# Created: vrpdu/VRXaccrway.I by hverstee for route
#
 * Revision 1.1  1996/04/22  15:01:06  pinnacle
 * Created: vrpdu/VRaccrway.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:46  pinnacle
 * Replaced: vrpdu/accrway.c for:  by r240_int for route240
 *
 *
 * History:
 *
 *      01/17/96   tlb      Add prototypes
 *    09 Sep '99   Anand    For TR 179900778 - REMOVED some glitches in the
 *			    querying procedure for Raceways.
 *
 ****************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include "msdef.h"
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "dberror.h"

#include "VDmem.h"
#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"
#include "VRdef.h"

#include "VRRDBdef.h"
#include "VRRDBmac.h"

#include "vrpdu_pto.h"
#include "vrdbgmacros.h"

/*
#define MY_DEBUG
*/

/*-------------------------------------------------------------------------

+fi
  Internal Function  access_rway

  Abstract
      Accesses the RWAY_SPEC, RWAY_COMPS and RWAY_COMP_TYPE tables to retrieve
      the component data.

  Algorithm
      <Optional>

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Returns
       ACC_E_RWAY_COMPS   if access to RWAY_COMPS fails.
       ACC_E_RWAY_COMP_TYPE   if access to RWAY_COMP_TYPE fails.
       1    if successful.

*/


int access_rway (
  char          *vendor_code,/*  Vendor catalog code                (I)   */
  char          *compname,   /*  AABBCC code of the component       (I)   */
  double        width1,      /*  width1                             (I)   */
  double        depth1,      /*  depth1                             (I)   */
  double        width2,      /*  width2                             (I)   */
  double        depth2,      /*  depth2                             (I)   */
  int           rway_type,   /*  Raceway component type  (shapec)   (I)   */
  char          *macro_name, /*  Macro name                         (O)   */
  short         *topology,   /*  Component topology                 (O)   */
  short         *type,       /*  Component reporting category       (O)   */
  struct ACrg_coll mac_pm[], /*  Extension,bend_rad & trans_leng    (O)   */
  int           *pm_no,      /*  Number of params in mac_pm         (O)   */
  struct VRSelectAttr seldat[],     /* Rway catalog select criteria (I)  */
  IGRshort            *crit_no,     /* No.of select criteria        (I)  */
  char          *err_ptr)    /*  Error message buffer               (O)   */
{
  /************************************************************************/
  /*                                                                      */
  /* This routine extracts macro name, topology, reporting category and   */
  /* some parameters of the component from the Electrical cable tray      */    
  /* database.                                                            */
  /* Algoritm :                                                           */
  /*          1)Access rway_comps table to extract macro_name             */
  /*          2)Access rway_comp_type table to extract comp_topo and      */
  /*            comp_cat.                                                 */
  /*                                                                      */
  /************************************************************************/
     
  IGRint        sts,i;
  IGRchar       sel_crit_str[100];
  IGRshort      loc_crit_no;
  IGRchar       cat_search[MAX_WHERE_SIZE];
  IGRchar       catalog[50];

  IGRdouble     dw1, dw2;
  IGRdouble     dp1, dp2;
  IGRint        iret;
  IGRshort      vendor_no;
  IGRlong       retmsg;
  IGRshort      NN;
  IGRchar      *ep;

  struct VRRDB_comps_key  YY;
  struct VRRDB_comps     *XX;
  struct VRRDB_ct_key     CtK;
  struct VRRDB_ct         CtR;
  struct VRSelectAttr     locsel[100];

  SetProc( Fn access_rway ); Begin 

  VR$RDB_SET (p_msg = &retmsg);

  ep = err_ptr;
  iret = 0;
  XX   = NULL;

  VR$RDB_SNUM (p_nam = vendor_code,
               p_num = &vendor_no);

  if( macro_name[0] == 0 )
  {
    dw1 = width1;
    dp1 = depth1;
    dw2 = width2;
    dp2 = depth2;

			/*---------------------------*/
			/*  ACCESS RWAY COMPS TABLE  */
			/*---------------------------*/

    strcpy (YY.comp_code, compname);
    YY.rType  = rway_type;

    VR$RDB_COMP (p_msg = &retmsg,
                 spec  = vendor_no,
                 keyin = &YY,
                 wid1  = dw1,
                 dep1  = dp1,
                 wid2  = dw2,
                 dep2  = dp2,
                 p_num = &NN);

    if (NN == 0)
    {
       __DBGpr_int( "p_num from compcode error",NN);
       goto wrapup;
    }

    XX = _MALLOC (NN, struct VRRDB_comps);

    VR$RDB_COMP (p_msg = &retmsg,
                 spec  = vendor_no,
                 keyin = &YY,
                 wid1  = dw1,
                 dep1  = dp1,
                 wid2  = dw2,
                 dep2  = dp2,
                 p_num = &NN, 
                 p_rec = XX);

    if ((XX[0].data.famnam[0] == '\0') ||
        (XX[0].data.famnam[0] == ' '))
    {
      strcpy (macro_name, XX[0].data.cat_name);
      strcpy (sel_crit_str, XX[0].data.sel_crit);

      VRDbParseSel(sel_crit_str, locsel, &loc_crit_no);
      catalog[0] = 0;
      strcpy(catalog, macro_name);
      for(i=0; i<strlen(catalog); i++)
      {
        catalog[i] = tolower(catalog[i]);
      }

      /* Check if catalog table exists */

      if (VdsVerifyRisTable (catalog) != VDS_DBTABLE_FOUND)
      {
        __DBGpr_str("catalog not found", catalog);
        goto wrapup;
      }


      for ( i = 0; i < loc_crit_no; i++ )
      {
        sts = VRdbGetRisColType( catalog, locsel[i].sel.name,
                                 &locsel[i].range,
                                 &locsel[i].type,
                                 &locsel[i].sel.desc.type,
                                  err_ptr );

#ifdef MY_DEBUG
        printf (" from riscoltype sts = %d\n",sts);
#endif
        if(sts != 1)
        {
          __DBGpr_int("riscoltype sts",sts);
          goto wrapup;
        }

      }

      for ( i = 0; i < loc_crit_no; i++ )
      {
        strcpy(mac_pm[*pm_no].name, locsel[i].sel.name );

        if( locsel[i].type == VR_RISDB_TEXT )
        {
          mac_pm[*pm_no].desc.type = locsel[i].sel.desc.type;
          sprintf(mac_pm[*pm_no].desc.value.att_txt, "%d", locsel[i].type);
        }
        else
        if( locsel[i].type == VR_RISDB_INT )
        {
          mac_pm[*pm_no].desc.type = locsel[i].sel.desc.type;
          if(locsel[i].range == 1 )
            mac_pm[*pm_no].desc.value.att_exp =
                 (double)(locsel[i].type | locsel[i].range);
          else
            mac_pm[*pm_no].desc.value.att_exp = (double)locsel[i].type;
        }
        else
        if( locsel[i].type == VR_RISDB_DOUBLE )
        {
          mac_pm[*pm_no].desc.type = locsel[i].sel.desc.type;
          if(locsel[i].range == 1 )
            mac_pm[*pm_no].desc.value.att_exp =
                  (double)(locsel[i].type | locsel[i].range);
          else
            mac_pm[*pm_no].desc.value.att_exp = (double)locsel[i].type;
        }

        *pm_no += 1;
      }

      /* Store catalog name also in mac_pm */
      strcpy(mac_pm[*pm_no].name,"catalog_name");
      mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
      strcpy(mac_pm[*pm_no].desc.value.att_txt, macro_name);
      *pm_no += 1;
      iret = 1;
      __DBGpr_com("db entry found");
      goto wrapup;
    }
    else
    {
#ifdef vdsDEBUG
      printf (" Macro from fam %s\n",XX[0].data.famnam);
#endif
      __DBGpr_str("Macro from fam ",XX[0].data.famnam);
      strcpy (macro_name, XX[0].data.famnam);

      /* Copy params into the mac_pm structures */

      strcpy(mac_pm[*pm_no].name,VR_N_MACRO_NAME_AN);
      mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
      strcpy(mac_pm[*pm_no].desc.value.att_txt, macro_name);
      *pm_no += 1;     

      strcpy(mac_pm[*pm_no].name,VR_N_PAR_1_DB);
      mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
      mac_pm[*pm_no].desc.value.att_exp = XX[0].data.par_1;
      *pm_no += 1;     

      strcpy(mac_pm[*pm_no].name,VR_N_PAR_2_DB);
      mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
      mac_pm[*pm_no].desc.value.att_exp = XX[0].data.par_2;
      *pm_no += 1;     

      strcpy(mac_pm[*pm_no].name,VR_N_PAR_3_DB);
      mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
      mac_pm[*pm_no].desc.value.att_exp = XX[0].data.par_3;
      *pm_no += 1;     
    }

  }/* end if not catalog access */
  else
  {
    __DBGpr_com("Checking hvac catalog");
    VRdbform_hvac_dyn_search_str ( seldat, crit_no, cat_search );
    strcpy( catalog, macro_name);
    sts = VRdbacc_hvac_catalog ( catalog, cat_search, macro_name, mac_pm,
                                 pm_no, err_ptr );

    if( sts != 1 )
    {
       __DBGpr_com("Not found in hvac catalog");
       goto wrapup;
    }
  }

		    /*-----------------------------------*/
		    /*  ACCESS THE RWAY COMP TYPE TABLE  */
		    /*-----------------------------------*/
 
  /* Querying parameters added/modified for rway_comp_type table query */
  strcpy (CtK.comp_code, compname);
  CtK.comp_type = XX[0].key.rType;
  if( XX != NULL )
      strcpy( CtK.sh_code , XX[0].data.sh_code );
  else
      strcpy( CtK.sh_code , "" );

  __DBGpr_str("CtK.sh_code",CtK.sh_code );
#ifdef vdsDEBUG
  printf("Querying rway comp type with\n");
  printf(" compcode <%s>, short code <%s> and comp type %d\n",
				    CtK.comp_code, CtK.sh_code, CtK.comp_type);
#endif 

  __DBGpr_str("compcode",CtK.comp_code);
  __DBGpr_int("comptype",CtK.comp_type);
  VR$RDB_CT (p_msg = &retmsg,
             keyin = &CtK,
             p_num = &NN,
             p_rec = &CtR);

#ifdef vdsDEBUG
  printf (" Comptype access NN = %d\n",NN);
#endif

  if (retmsg != MSSUCC || NN == 0)
  {
     __DBGpr_int("Comptype access fail",NN);
     goto wrapup;
  }

  *topology = CtR.data.ct_topo;
  strcpy(mac_pm[*pm_no].name,VR_N_COMP_TOPO_IN);
  mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
  mac_pm[*pm_no].desc.value.att_exp = (double) CtR.data.ct_topo;
  *pm_no += 1;

  *type =  CtR.data.ct_cat;
  strcpy(mac_pm[*pm_no].name,VR_N_COMP_TYPE_IN);
  mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
  mac_pm[*pm_no].desc.value.att_exp = (double) CtR.data.ct_cat;
  *pm_no += 1;

  __DBGpr_com("dblookup is OK");
  iret = 1;

  wrapup:
  if (XX != NULL) _FREE (XX);

  End
  return(iret);
}

end implementation Root;
