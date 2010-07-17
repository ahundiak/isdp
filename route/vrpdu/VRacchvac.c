/* $Id: VRacchvac.c,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRacchvac.c
 *
 * Description:
 *      Access VDS database for hvac parameters
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRacchvac.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  14:59:18  pinnacle
 * Created: vrpdu/VRacchvac.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:28  pinnacle
 * Replaced: vrpdu/acchvac.c for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/

#include	<stdio.h>
#include        <stdlib.h>
#include        "ACattrib.h"
#include        "dberror.h"
#include        "VRDbParamDef.h"
#include        "VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include        "VRDbCache.h"

#include 	"vrpdu_pto.h"

#if 0

/*-------------------------------------------------------------------------*/

int access_hvac (

  char		*class  ,    /*  Hvac class name                    (I)   */
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
  /*  Routines :                                                          */
  /*              RISexecute_query                                        */
  /*                                                                      */
  /************************************************************************/
     
  int		sts,i;
  struct VRrisdat      outdata[10];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;            /* table name     */
  char		*select=NULL;        /* select list    */
  char		search[MAX_WHERE_SIZE];         /* where clause of a select */
  char		pr_search[MAX_WHERE_SIZE];         
  char          ris_str[MAX_RIS_STR_SIZE];
  char          in_buf[10][20];
  int           in_cnt;
  char          disp_err[100];
  char          sel_crit_str[100];
  struct VRSelectAttr locsel[100];
  short         loc_crit_no;
  char          cat_search[MAX_WHERE_SIZE];
  char          catalog[50];
  int           proj_no;

    /* Get project no */

    sts = VdsGetPrjNo ( &proj_no );
    if(!sts)
        return (0);

    VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );

    /* IF NOT CATALOG ACCESS */
    
    if( macro_name[0] == 0 )
    {
       /* ACCESS HVAC COMPS TABLE */
       /*---------------------------*/

       table = VRDB_HVCOMPS_TBL;
       select = "family_name, cat_name, sel_crit";

       /* Check if shape code indicates a device ( SHAPE_CODE = -1 )*/
       if( shape == -1 )
       {
         sprintf( search, "where comp_code = '%s' and shape_code is NULL and tblno in (select class_no from hvac_spec where hvac_class = '%s' and prj_no = %d)", compname, class, proj_no);
         sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

         sts = RISexecute_query( ris_str,outdata,&rows,&cols, &par_cnt);   
         if (sts != 1 || rows == 0)
         {
           if(err_ptr == NULL)
           {
             printf("Failed accessing hvac_comps.\n");
             printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
           }
           sprintf(disp_err,"comp_code '%s',class '%s', prj_no %d",
                             compname,class,proj_no);
           VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
           return( ACC_E_HVAC_COMPS );
         }
       }
      else
       {
         sprintf( search, "where comp_code = ? and shape_code = ? and tblno in (select class_no from hvac_spec where hvac_class = ? and prj_no = ?)");
         sprintf( pr_search, "where comp_code = '%s' and shape_code = %d and tblno in (select class_no from hvac_spec where hvac_class = '%s' and prj_no = %d)", compname, shape, class, proj_no);
         sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
   
         /* Prepare RIS query (only once) */
   
         sts = RISprepare_query( ris_str, HVAC_COMPS_PREP_ID7);
         if(sts != 1 )
         {
           printf("Error in preparing query for HVAC_COMPS, id:%d\n",HVAC_COMPS_PREP_ID7); 
           printf("%s\n", ris_str );
           VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
           return(0);
         }   
         /* Format input buffer */
         strcpy(in_buf[0], compname);
         sprintf(in_buf[1], "%hd", shape);
         strcpy(in_buf[2], class);
         sprintf(in_buf[3], "%hd", proj_no);

         in_cnt = 4;
         sts = RISexecute_query1( HVAC_COMPS_PREP_ID7, in_buf, in_cnt, outdata,&rows,&cols, &par_cnt);
         if (sts != 1)
         {
           if(err_ptr == NULL)
           {
             printf("Failed accessing hvac_comps.\n");
             printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, pr_search);
           }
           sprintf(disp_err,"comp_code '%s',shape_code %d,class '%s',prj_no %d",
                             compname,shape,class,proj_no);
           VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
           return( ACC_E_HVAC_COMPS );
         }
         else if ( rows == 0 ) /* Shape independent device */
         {
             /* Access database with shape code NULL*/
	     sprintf( search, "where comp_code = '%s' and shape_code is NULL and tblno in (select class_no from hvac_spec where hvac_class = '%s' and prj_no = %d)", compname, class, proj_no);

             sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

             sts = RISexecute_query( ris_str,outdata,&rows,&cols, &par_cnt);   
             if (sts != 1 || rows == 0)
             {
               if(err_ptr == NULL)
               {
                 printf("Failed accessing hvac_comps.\n");
                 printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
               }
               sprintf(disp_err,"comp_code '%s',shape_code NULL,class '%s',prj_no %d",
                                compname,class,proj_no);
               VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
               return( ACC_E_HVAC_COMPS );
             }
         }
       } 
       if ( outdata[0].data.val.attr_c[0] == 0 || 
            outdata[0].data.val.attr_c[0] == ' ')
        {
           strcpy (macro_name, outdata[1].data.val.attr_c);
           strcpy (sel_crit_str, outdata[2].data.val.attr_c);
       
           VRDbParseSel(sel_crit_str, locsel, &loc_crit_no);
           catalog[0] = 0;
           strcpy(catalog, macro_name);
           for(i=0; i<strlen(catalog); i++)    
           {
             catalog[i] = tolower(catalog[i]);
           }
       
           /* Check if catalog table exists */

           sts = VRdbChkRisTblExists ( catalog, err_ptr);
           if (sts != 1 )
              return(0);

           for ( i = 0; i < loc_crit_no; i++ )
           {
                   sts = VRdbGetRisColType( catalog, locsel[i].sel.name,
                                                    &locsel[i].range,
                                                    &locsel[i].type,
                                                    &locsel[i].sel.desc.type,
                                                    err_ptr );
                   if(sts != 1)
                     return(0);

           }
           for ( i = 0; i < loc_crit_no; i++ )
           {
              strcpy(mac_pm[*pm_no].name, locsel[i].sel.name );
              if( locsel[i].type == VR_RISDB_TEXT )
              {
                mac_pm[*pm_no].desc.type = locsel[i].sel.desc.type;
                sprintf(mac_pm[*pm_no].desc.value.att_txt, "%d", locsel[i].type);
              }
              else if( locsel[i].type == VR_RISDB_INT ) 
              {
                mac_pm[*pm_no].desc.type = locsel[i].sel.desc.type;
                if(locsel[i].range == 1 )
                   mac_pm[*pm_no].desc.value.att_exp = (double)(locsel[i].type | locsel[i].range);
                else
                   mac_pm[*pm_no].desc.value.att_exp = (double)locsel[i].type;
              }
              else if( locsel[i].type == VR_RISDB_DOUBLE ) 
              {
                mac_pm[*pm_no].desc.type = locsel[i].sel.desc.type;
                if(locsel[i].range == 1 )
                  mac_pm[*pm_no].desc.value.att_exp = (double)(locsel[i].type | locsel[i].range);
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
           return(1);
        }
       else
        {
          strcpy (macro_name, outdata[0].data.val.attr_c);

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

      if( sts != 1 )	return (0);
    }
    

    /* ACCESS THE HVAC COMP TYPE TABLE   */
    /*-----------------------------------*/
 

    table = VRDB_HVCOMPTYP_TBL;
    select = "comp_topo, comp_cat";
    sprintf( search, "where comp_code = ?");
    sprintf( pr_search, "where comp_code = '%s'", compname);
    sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
 
    /* Prepare RIS query (only once) */
   
    sts = RISprepare_query( ris_str, HVAC_COMPTYP_PREP_ID8);
    if(sts != 1 )
    {
        printf("Error in preparing query for HVAC_COMPS_TYP, id:%d\n",HVAC_COMPTYP_PREP_ID8); 
        printf("%s\n", ris_str );
        VRdb_err_msg(VR_E_DbErrPrepQuery,err_ptr,NULL,NULL,NULL);
        return(0);
    }   
    
    /* Format input buffer */
    strcpy(in_buf[0], compname);

    in_cnt = 1;

    sts = RISexecute_query1(HVAC_COMPTYP_PREP_ID8, in_buf, in_cnt, outdata, &rows, &cols, &par_cnt);
    if (sts != 1 || rows == 0)
    {
        if(err_ptr == NULL)
        {
          printf("Failed accessing hvac_comp_type.\n");
          printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, pr_search);
        }
          sprintf(disp_err,"comp_code '%s'",compname);
          VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
          /*return( ACC_E_HVAC_COMP_TYPE );*/
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
