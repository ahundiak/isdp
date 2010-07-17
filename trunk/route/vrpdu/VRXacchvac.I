/* $Id: VRXacchvac.I,v 1.3 2001/02/20 01:15:11 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRacchvac.c
 *
 * Description:
 *      Access VDS database for hvac parameters
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXacchvac.I,v $
 *  Revision 1.3  2001/02/20 01:15:11  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/12 23:22:26  anand
 *  SP merge
 *
# Revision 1.1  2000/04/14  19:55:06  pinnacle
# Created: route/vrpdu/VRXacchvac.I by apazhani for Service Pack
#
# Revision 1.3  1999/05/13  09:30:20  pinnacle
# Replaced: vrpdu/VRXacchvac.I for:  by apazhani for route
#
# Revision 1.2  1999/04/30  21:51:04  pinnacle
# traceFlag 150
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1997/12/10  17:05:12  pinnacle
# Replaced: vrpdu/VRXacchvac.I for:  by r250_int for route
#
# Revision 1.2  1997/12/05  20:54:26  pinnacle
# Replaced: vrpdu/*.I for: AXFAN crash in 02.04.03.04 03-Nov-97 by aharihar for route
#
# Revision 1.1  1997/08/15  19:42:24  pinnacle
# Created: vrpdu/VRXacchvac.I by hverstee for route
#
 * Revision 1.1  1996/04/22  14:59:18  pinnacle
 * Created: vrpdu/VRacchvac.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:28  pinnacle
 * Replaced: vrpdu/acchvac.c for:  by r240_int for route240
 *
 *
 * History:
 * MM/DD/YY   AUTHOR  DESCRIPTION
 * 04/30/99   	ah      Added traceFlag 150
 * 05/13/99   	Alwin	Commented a status check and modified a condition to
 *						perform an additional query. TR179802464
 * 04/14/2000   Alwin	Removed the comment and also the additional query.
 *						as its not needed any more. TR179900637
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include "ACattrib.h"
#include "dberror.h"

#include "VDmem.h"
#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"

#include "VRHDBdef.h"
#include "VRHDBmac.h"

#include "vrpdu_pto.h"
#include "vrdbgmacros.h"

static int traceFlag;

/*
#define MY_DEBUG
*/
/*-------------------------------------------------------------------------*/

int access_hvac (

  char          *class  ,    /*  Hvac class name                    (I)   */
  char          *compname,   /*  AABBCC code of the component       (I)   */
  int           shape,       /*  Shape code                         (I)   */
  char          *macro_name, /*  Macro name                         (O)   */
  short         *topology,   /*  Component topology                 (O)   */
  short         *type,       /*  Component reporting category       (O)   */
  struct ACrg_coll mac_pm[], /*  macro parameters                   (O)   */
  int           *pm_no,      /*  Number of params in mac_pm         (I/O) */
  struct VRSelectAttr seldat[],/* Select criteria structure        (I)   */
  short         *crit_no,    /* Number of select criteria           (I)   */
  char          *err_ptr)    /*  Error message buffer               (O)   */
 {
  /************************************************************************/
  /*                                                                      */
  /* This routine extracts macro name, topology and                       */
  /* reporting category of the component from the HVAC database           */
  /*                                                                      */
  /* Algoritm :                                                           */
  /*                                                                      */
  /*          1)Access hvac_comps table to extract macro_name             */
  /*          2)Access hvac_comp_type table to extract comp_topo and      */
  /*            comp_cat.                                                 */
  /*                                                                      */
  /************************************************************************/

  IGRint        sts,i;
  IGRchar       sel_crit_str[100];
  IGRshort      loc_crit_no;
  IGRchar       cat_search[MAX_WHERE_SIZE];
  IGRchar       catalog[50];

  IGRint        iret;
  IGRshort      class_no;
  IGRlong       retmsg;
  IGRshort      NN;
  IGRchar      *ep;

  struct VRHDB_comps_key  YY;
  struct VRHDB_comps     *XX;
  struct VRHDB_ct_key     CtK;
  struct VRHDB_ct         CtR;
  struct VRSelectAttr     locsel[100];

  SetProc( access_hvac ); Begin 

#ifdef MY_DEBUG
  printf ("Access hvac\n");
#endif

  traceFlag = VDdbgGetTraceFlag(150);

  if (traceFlag) {
    IGRint pm_nox;
    IGRint crit_nox;
    if (pm_no) pm_nox = *pm_no;
    else       pm_nox = -1;
    if (crit_no) crit_nox = *crit_no;
    else         crit_nox = -1;
    
    printf(">>> access_hvac \n class='%s' compname='%s' shape=%d *pm_no=%d, *crit_no=%d\n",
	   class,compname,shape,pm_nox,crit_nox);
  }
  
  VR$HDB_SET (p_msg = &retmsg);

  ep   = err_ptr;
  iret = 0;
  XX   = NULL;

  VR$HDB_SNUM (p_nam = class,
               p_num = &class_no);

  if (traceFlag) printf("class_no = %d\n",class_no);
  
  /* IF NOT CATALOG ACCESS */
    
  if( macro_name[0] == '\0' )
  {
       /* ACCESS HVAC COMPS TABLE */
       /*---------------------------*/

    if (traceFlag) {
      printf("macro_name is NULL, looking for it\n");
    }
    
    strcpy (YY.comp_code, compname);
    YY.shapecode = shape;

    VR$HDB_COMP (p_msg = &retmsg,
                 spec  = class_no,
                 keyin = &YY,
                 p_num = &NN);

    if (retmsg != MSSUCC) {
      if (traceFlag) printf("VR$HDB_COMP failed\n");
      goto wrapup;
    }
    
    /* Commented this condition to modify; or make a additional query in DB
    to check for other shapes as well
    if ((NN == 0) && (shape >= 0))
    added by Alwin for TR179802464. This would fix only th HVAC part of the

	// We don't need this additional query, b'cas the way the Manually placed
	// components has been changed. Hence removing the below peice of code.
	// This also lets place components which are not available in DB.
	// TR179900637. Alwin
    if( NN == 0 )
    {
	  __DBGpr_com( " Using the modified condition " );
      YY.shapecode = VRHDB_UNDEF;

      VR$HDB_COMP (p_msg = &retmsg,
                   spec  = class_no,
                   keyin = &YY,
                   p_num = &NN);
    }
    TR description. ***/

#ifdef MY_DEBUG
    printf ("Access hvac, after shapecode adjust, NN = %d\n", NN);
#endif

    if (NN == 0) {
      if (traceFlag) printf("NN is zero\n");
      goto wrapup;
    }
    
    XX = _MALLOC (NN, struct VRHDB_comps);

    VR$HDB_COMP (p_msg = &retmsg,
                 spec  = class_no,
                 keyin = &YY,
                 p_num = &NN,
                 p_rec = XX);

    if ((XX[0].data.famnam[0] == '\0') || (XX[0].data.famnam[0] == ' '))
    {
      strcpy (macro_name, XX[0].data.cat_name);
      strcpy (sel_crit_str, XX[0].data.sel_crit);

      VRDbParseSel(sel_crit_str, locsel, &loc_crit_no);
      catalog[0] = '\0';
      strcpy(catalog, macro_name);
      for(i=0; i<strlen(catalog); i++)    
      {
        catalog[i] = tolower(catalog[i]);
      }
      if (traceFlag) {
	printf("macro_name = '%s', catalog = '%s', loc_crit_no = %d\n",
	       macro_name,catalog,loc_crit_no);
      }
      
      __DBGpr_str(" catalog ", catalog );
      __DBGpr_int(" loc_crit_no ", loc_crit_no); 
       
      /* Check if catalog table exists */

      if (VdsVerifyRisTable (catalog) != VDS_DBTABLE_FOUND) {
	if (traceFlag) printf("Catalog not found\n");
	goto wrapup;
      }
      

      for ( i = 0; i < loc_crit_no; i++ )
      {
        __DBGpr_str ( " locsel.sel.name" ,locsel[i].sel.name );

        sts = VRdbGetRisColType( catalog, locsel[i].sel.name,
                                 &locsel[i].range,
                                 &locsel[i].type,
                                 &locsel[i].sel.desc.type,
                                  err_ptr );

#ifdef MY_DEBUG
        printf (" from riscoltype sts = %d\n",sts);
#endif
        if(sts != 1) {
	  if (traceFlag) printf("Problem in VRdbGetRisColType\n");
	  goto wrapup;
	}
	
      }

      for ( i = 0; i < loc_crit_no; i++ )
      {
        strcpy(mac_pm[*pm_no].name, locsel[i].sel.name );

        __DBGpr_int( " VR_RISDB_TEXT ", VR_RISDB_TEXT );
        __DBGpr_int( " VR_RISDB_INT ", VR_RISDB_INT );
        __DBGpr_int( " VR_RISDB_DOUBLE ", VR_RISDB_DOUBLE );
 
        __DBGpr_int( " Attribute Type", locsel[i].sel.desc.type );
 
        if( locsel[i].type == VR_RISDB_TEXT )
        {
          mac_pm[*pm_no].desc.type = locsel[i].sel.desc.type;
          sprintf(mac_pm[*pm_no].desc.value.att_txt, "%d", locsel[i].type);
          __DBGpr_str( " Text value ", mac_pm[*pm_no].desc.value.att_txt );
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
       
      __DBGpr_str( " Attribute's name ", mac_pm[*pm_no].name );
      __DBGpr_str( " Text 1 value ", macro_name );
 
      *pm_no += 1;
      iret = 1;
      goto wrapup;
    }
    else
    {
      strcpy (macro_name, XX[0].data.famnam);
      __DBGpr_str( " Macro Name ", macro_name );

      if (traceFlag) {
	printf("macro_name = '%s'\n",macro_name);
      }
      
      /* Copy params into the mac_pm structures */

      strcpy(mac_pm[*pm_no].name,VR_N_MACRO_NAME_AN);
      mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
      strcpy(mac_pm[*pm_no].desc.value.att_txt, macro_name);
      *pm_no += 1;     
    }

  }/* end if not catalog access */     
  else
  {
    VRdbform_hvac_dyn_search_str ( seldat, crit_no, cat_search );
    strcpy( catalog, macro_name);
    sts = VRdbacc_hvac_catalog ( catalog, cat_search, macro_name, mac_pm,
                                 pm_no, err_ptr );

    if( sts != 1 )  {
      if (traceFlag) printf("Problem from VRdbacc_hvac_catalog\n");
      goto wrapup;
    }
    
  }

  /* ACCESS THE HVAC COMP TYPE TABLE   */
  /*-----------------------------------*/

#ifdef MY_DEBUG
  printf (" comptype access\n");
#endif
 
  if (traceFlag) {
    printf("Access comptype\n");
  }
  
  strcpy (CtK.comp_code, compname);
  strcpy (CtK.sh_code, "");

  VR$HDB_CT (p_msg = &retmsg,
             keyin = &CtK,
             p_num = &NN,
             p_rec = &CtR);

  if ((retmsg != MSSUCC) || (NN == 0))  goto wrapup;

  *topology = CtR.data.ct_topo;
  strcpy(mac_pm[*pm_no].name,VR_N_COMP_TOPO_IN);
  mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
  mac_pm[*pm_no].desc.value.att_exp = (double) (*topology);
  *pm_no += 1;

  *type = CtR.data.ct_cat;
  strcpy(mac_pm[*pm_no].name,VR_N_COMP_TYPE_IN);
  mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
  mac_pm[*pm_no].desc.value.att_exp = (double) (*type);
  *pm_no += 1;
   
  iret = 1;

  wrapup:
  if (XX != NULL) _FREE (XX);
#ifdef MY_DEBUG
  printf (" leave acchvac iret = %d\n",iret);
#endif
 
  if (traceFlag) {
    printf("### access_hvac, %d\n",iret);
  }
  
  End
  return(iret);
}

end implementation Root;

