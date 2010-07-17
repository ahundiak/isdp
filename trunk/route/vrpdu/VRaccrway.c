/* $Id: VRaccrway.c,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/* I/ROUTE
 *
 * File:        vrpdu/VRaccrway.c
 *
 * Description:
 *
 *	Access VDS database for rway component and parameters.
 *
 * Dependencies:
 *	RISexecute_query().
 *
 * Revision History:
 *	$Log: VRaccrway.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  15:01:06  pinnacle
 * Created: vrpdu/VRaccrway.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:46  pinnacle
 * Replaced: vrpdu/accrway.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 ****************************************************************/

#include	<stdio.h>
#include        <stdlib.h>
#include        "igrtypedef.h"
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "dberror.h"
#include        "VRDbParamDef.h"
#include        "VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include        "VRDbCache.h"
#include	"VRdef.h"
#include "vrpdu_pto.h"

#if 0

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
       ACC_E_RWAY_COMPS			if access to RWAY_COMPS fails.
       ACC_E_RWAY_COMP_TYPE 		if access to RWAY_COMP_TYPE fails.
       1				if successful.

*/


int access_rway (

  char		*vendor_code,/*  Vendor catalog code                (I)   */
  char          *compname,   /*  AABBCC code of the component       (I)   */
  double        width1,      /*  width1                             (I)   */
  double        depth1,      /*  depth1                             (I)   */
  double        width2,      /*  width2                             (I)   */
  double        depth2,      /*  depth2                             (I)   */
  int           rway_type,   /*  Raceway component type             (I)   */
  char          *macro_name, /*  Macro name                         (O)   */
  short         *topology,   /*  Component topology                 (O)   */
  short         *type,       /*  Component reporting category       (O)   */
  struct ACrg_coll mac_pm[], /*  Extension,bend_rad & trans_leng    (O)   */
  int           *pm_no,      /*  Number of params in mac_pm         (O)   */
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
  /*  Routines :                                                          */
  /*              RISexecute_query                                        */
  /*                                                                      */
  /************************************************************************/
     
  int		sts;
  struct VRrisdat     outdata[10];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;             /* table name  */
  char		*select=NULL;         /* select list */
  char		search[MAX_WHERE_SIZE];          /* where clause of a select*/
  char          ris_str[MAX_RIS_STR_SIZE];
  char          disp_err[200];
  int           proj_no;

    /* Get project no */

    sts = VdsGetPrjNo( &proj_no );
    if(!sts)
       return(0);

    VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );   

    /* ACCESS RWAY COMPS TABLE */
    /*---------------------------*/

    table = VRDB_RWCOMPS_TBL;
    select = "family_name,par_1,par_2,par_3";

    if(rway_type == VR_RECT || rway_type == VR_TRAY ) 
    {
    sprintf( search, "where comp_code = '%s' and width_g = %lf and depth_g = %lf and width_r = %lf and depth_r = %lf and rway_type = %d and vendor_no in (select vendor_no from rway_spec where vendor_code = '%s' and prj_no = %d)",compname,width1,depth1,width2,depth2,rway_type,vendor_code,proj_no);
    }
    else /* Circular */
    {
    sprintf( search, "where comp_code = '%s' and width_g = %lf and width_r = %lf and rway_type = %d and vendor_no in (select vendor_no from rway_spec where vendor_code = '%s' and prj_no = %d)",compname,width1,width2,rway_type,vendor_code,proj_no);
    }
    sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

    sts = RISexecute_query( ris_str, outdata,&rows,&cols, &par_cnt);
    if (sts != 1 || rows == 0)
     {
         printf("Failed accessing rway comps table.\n");
         printf("SELECT<%s>\nFROM<%s>\n%s\n", select, table, search);
         sprintf(disp_err,"comp_code '%s',width_g %f,depth_g %f,width_r %f,depth_r %f,rway_type %d,vendor_code '%s',prj_no %d",
                   compname,width1,depth1,width2,depth2,rway_type,vendor_code,proj_no);
         VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
         return ( ACC_E_RWAY_COMPS ); 
     }

    else
     {
         strcpy (macro_name, outdata[0].data.val.attr_c);
        
         /* Copy params into the mac_pm structures */

         strcpy(mac_pm[*pm_no].name,VR_N_MACRO_NAME_AN);
         mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
         strcpy(mac_pm[*pm_no].desc.value.att_txt, macro_name);
         *pm_no += 1;     


         strcpy(mac_pm[*pm_no].name,VR_N_PAR_1_DB);
         mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
         mac_pm[*pm_no].desc.value.att_exp = outdata[1].data.val.attr_dbl;
         *pm_no += 1;     


         strcpy(mac_pm[*pm_no].name,VR_N_PAR_2_DB);
         mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
         mac_pm[*pm_no].desc.value.att_exp = outdata[2].data.val.attr_dbl ;
         *pm_no += 1;     

         strcpy(mac_pm[*pm_no].name,VR_N_PAR_3_DB);
         mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
         mac_pm[*pm_no].desc.value.att_exp = outdata[3].data.val.attr_dbl;
         *pm_no += 1;     
      
     }

     /* ACCESS THE RWAY COMP TYPE TABLE   */
     /*-----------------------------------*/
 
    table = VRDB_RWCOMPTYP_TBL;
    select =  "comp_topo, comp_cat";
    sprintf( search, "where comp_code = '%s'",compname);
    sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

    sts = RISexecute_query( ris_str, outdata,&rows, &cols, &par_cnt);
    if (sts != 1 || rows == 0)
     {
       printf("Failed accessing rway comp type table.\n");
       printf("SELECT<%s>\nFROM<%s>\n%s\n", select, table, search);
       sprintf(disp_err,"comp_code '%s'",compname);
       VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
       return( ACC_E_RWAY_COMP_TYPE );
     }

    else
     {
       *topology = (short)outdata[0].data.val.attr_int;
       strcpy(mac_pm[*pm_no].name,VR_N_COMP_TOPO_IN);
       mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
       mac_pm[*pm_no].desc.value.att_exp = (double)outdata[0].data.val.attr_int;
       *pm_no += 1;

       *type = (short)outdata[1].data.val.attr_int;
       strcpy(mac_pm[*pm_no].name,VR_N_COMP_TYPE_IN);
       mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
       mac_pm[*pm_no].desc.value.att_exp = (double)outdata[1].data.val.attr_int;
       *pm_no += 1;
     }

  return(1);
 }
#endif

