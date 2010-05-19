/* $Id: VDSdbparcat.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbparcat.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbparcat.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.7  1996/06/11  23:04:56  pinnacle
 * Replaced: vddb/source/VDSdbparcat.c for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/06/07  14:39:32  pinnacle
 * Replaced: vddb/source/VDSdbparcat.c for:  by sljenks for vds.240
 *
 * Revision 1.5  1996/05/29  19:09:54  pinnacle
 * Replaced: vddb/source/VDSdbparcat.c for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1996/05/20  05:05:00  pinnacle
 * Replaced: vddb/source/VDSdbparcat.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/22  15:14:28  pinnacle
 * Replaced: vddb/source/VDSdbparcat.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbparcat.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/14/96 tlb	Add VDS memory checking, 
 *			Add prototypes
 *			Add delimiters before MEMprint_buffer
 *		 	VDScreate_parametric_catalog - change 'null' to "null"
 *	04/22/96   tlb	Fix log comment problem 
 *	04/30/96   tlb	Change functions to single exit  - memory alloc
 *			Removed close of input buffers:
 *				VDScreate_parametric_catalog 
 *				VDSstore_classification 
 *			Adopt NFMstart_transaction from PDU function
 *			Give explicit error messages/status
 *			VDScreate_parametric_catalog:   
 *		 	        dyn_table was used as an input arg - 
 * 					should be output only
 *				remove cat_attr parameter
 *				added failure labels 
 *			VDScreate_dynamic_table - added retry if exists
 *			Use error checking routines
 *	05/29/96    tlb Fix error messages
 *
 *	06/07/96    slj Changed status != NFM_E_DUP_TABLE_NAME in dynamic
 *			table creation to ==.
 *	06/10/96   tlb	MEMprint_buffer crashes on NULL output for Solaris
 *			Add checks for null data_ptr and column_ptr
 *			Check for no data in VDSstore_parameters
 * -------------------------------------------------------------------*/


#include <stdio.h>
#include <string.h>
#include <memory.h>
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "MEMproto.h"
#include "SQLerrordef.h"
#include "SQLproto.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "NFMAproto.h"
#include "WFstruct.h"
#include "VDSdberrdef.h"
#include "VDmem.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

/*-------------------------------------------------------------------*/
/* This function was adapted from  PDMpara_cat.c */
long VDScreate_parametric_catalog (
     		MEMptr   cat_data, 
		MEMptr   attr_list, 
		MEMptr   data_list, 
		MEMptr   value_list,
		MEMptr   dyn_attr, 
		MEMptr   dyn_data,
		MEMptr   dyn_list,
		char     *dyn_table	/* O: dynamic attr table name */
		)
{
     int      dyn_no;
     char     **data, **column ;
     char     pdc_table[21], cat_name[20];
     char     table_no[32], out_str[25];
     int      catalog_no, acl =0;
     short    y=0, i = -1, comma = 0, count = 0, add = 0;
     char     *sql_str = NULL;
     char     *sql_str1 = NULL;
     MEMptr   attr_list1 = NULL; 
     MEMptr   data_list1 = NULL;
     MEMptr   attr_list2 = NULL; 
     MEMptr   data_list2 = NULL;
     MEMptr   identifier_list = NULL ;
     long     status = VDS_S_SUCCESS;
    
    
#ifdef DEBUG
   	VDSdebug ( "ENTER create_parametric_catalog \n") ;
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
        MEMprint_buffer("VDScreate_parametric:cat_data",
						cat_data,VDS_DEBUG_FILE);
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
        MEMprint_buffer("VDScreate_parametric:attr_list",
						attr_list,VDS_DEBUG_FILE);
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
        MEMprint_buffer("VDScreate_parametric:data_list",
						data_list,VDS_DEBUG_FILE);
	}
#endif

     status = MEMbuild_array (cat_data);
     if (status != MEM_S_SUCCESS) {
        WFload_catalog_no (-1) ;
        VDSprintMemErr( "\t", "MEMbuild_array", status, VDS_E_BUILD_ARRAY);
        status = VDS_E_BUILD_ARRAY;
	goto wrapup;
      }


     /* Initailize column */
     if (!cat_data->column_ptr) {
	VDSprintErr ("\t", "No columns in catalog data buffer\n");
	status = VDS_E_BUILD_ARRAY;
	goto wrapup;
	}
     column = (char **) cat_data -> column_ptr;

     if (!cat_data->data_ptr) {
	VDSprintErr ("\t", "No data in catalog data buffer\n");
	status = VDS_E_BUILD_ARRAY;
	goto wrapup;
	}
     data  = (char **) cat_data -> data_ptr;

     for (y = 0; y < cat_data -> columns; ++y) {
        if (! strcmp (column [y], "n_catalogname"))  i = y;
        if (! strcmp (column [y], "n_aclno"))  acl = y;
        }
 

     /* Check catalog name */
     sprintf (cat_name, "%s",   data [i]);
     if (!strlen (cat_name) ) {
         WFload_catalog_no (-1) ;
         VDSprintErr ("\t", " cannot get catalog name from buffer\n");
         status = VDS_E_GET_CATALOG_NAME ;
	 goto wrapup;
       }

     status = NFMsplit_template_attributes (attr_list, data_list,
                                            &attr_list1, &data_list1,
                                            &attr_list2, &data_list2,
                                            &identifier_list) ;
     if (status != NFM_S_SUCCESS) {
	VDSprintErr( "\t", "Error splitting table attributes\n" );
        VDSprintNfmErr( "\t", "NFMsplit_template_attributes", status);
        WFload_catalog_no (-1) ;
	status = VDS_E_GET_CAT_TEMP;
	goto wrapup;
      }

#ifdef FOO
     /*  Adopted from PDU 04/30/96
      * ALR   4/28/94  Data Definition stmts can not occur in a
      * transaction. Can not determine where the transaction has
      * started and not been committed. Turn transactions off to
      * insure the create table will work.   PDU TR 139418848 
      */
     status = NFMstart_transaction(0);
     if (status != NFM_S_SUCCESS) {
           VDsdebug("NFMstart_transaction failed <0x%.8x>\n",status);
           }
#endif

#ifdef DEBUG
	   VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
           MEMprint_buffer("VDScreate_parametric:attr_list1",
						attr_list1,VDS_DEBUG_FILE);
	   VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
           MEMprint_buffer("VDScreate_parametric:data_list1",
						data_list1,VDS_DEBUG_FILE);
	   VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
           MEMprint_buffer("VDScreate_parametric:value_list",
						value_list,VDS_DEBUG_FILE);
#endif

     /* ------------------------------------------ 
      * Create parametric family table 
      */
     VDSprintUsrMsg ("\t... Creating parametric family catalog: <%s>\n", 
							cat_name);
     status = _NFMcreate_table ("CATALOG", cat_name, "PDM",  &catalog_no,
              				attr_list1, data_list1, value_list);
     if (status != NFM_S_SUCCESS) {
	VDSprintErr ("\t", "cannot create <%s> family table\n", cat_name);
        VDSprintNfmErr( "\t", "_NFMcreate_table", status);
        if (status != NFM_E_DUP_CATALOG) {
	    status = VDS_E_CREAT_TABLE;
	    goto fail1;
	    }	
	VDSprintUsrMsg("\t\t--- Table <%s> should be deleted or the family renamed\n",
							cat_name);
	status = VDS_E_CATALOG_EXISTS;
	goto wrapup;
        }

    /* ------------------------------------------ 
     *  Create dynamic attribute table
     */
    status = MEMbuild_array (dyn_attr);
    if (status != MEM_S_SUCCESS) {
            VDSprintMemErr( "\t", "MEMbuild_array", status, 
						VDS_E_BUILD_BUFFER_ARRAY);
	    status = VDS_E_BUILD_BUFFER_ARRAY;
	    goto fail1;
      	    }

    /* if has dynamic attributes - create dynamic attribute table */
    dyn_table[0] ='\0';		/* default */
    if(dyn_attr->rows > 0 ) {
      	sprintf(pdc_table,"y_%s",cat_name);
	strcpy (dyn_table, pdc_table);

	VDSprintUsrMsg ("\t... Creating dynamic attribute table: <%s>\n", 
							pdc_table);

    	status = VDSget_table_no(pdc_table,pdc_table,&dyn_no);
    	if(status != VDS_S_SUCCESS && status != VDS_E_TABLE_NOT_FOUND) {
	 	VDSprintErr("\t", "cannot get n_tableno from %s\n", pdc_table );
     		VDSprintVdsErr( "\t", "VDSget_table_no", status );
	 	goto fail1;
    		}

   	status = VDScreate_dynamic_table(VDSuser_id,
						 pdc_table,
						 dyn_attr,
						 dyn_data, 
						 dyn_list);
   	if(status != VDS_S_SUCCESS) 
	 	goto fail1;
  	}

     /* ------------------------------------------ 
      * Updating nfmcatalogs 
      */

     VDSprintUsrMsg ("\t... Updating <nfmcatalogs>\n");
     sql_str = _MALLOC ((4*cat_data->row_size)+MEM_SIZE, char );
     _CheckAlloc(sql_str, "sql statment", status, VDS_E_ALLOC_MEMORY, fail2 )			\
     sql_str [0] = '\0';

     sql_str1 = _MALLOC (((4 * cat_data -> row_size) + MEM_SIZE), char);
     _CheckAlloc(sql_str1, "sql statment", status, VDS_E_ALLOC_MEMORY, fail2 )			\
     sql_str1 [0] = '\0';

     status = WFload_catalog_name (cat_name);
     status = WFload_catalog_no (catalog_no) ;

     sprintf (sql_str,  "INSERT INTO %s (", "NFMCATALOGS");
     sprintf (sql_str1, ") VALUES (");

     comma = 0; i = -1;
     for (count = 0; count < cat_data -> columns; ++count) {
        add = 0;

        if (! strcmp (column [count ], "n_catalogno")) {
           add = 1;
           sprintf (table_no, "%d", catalog_no);
           status = MEMwrite_data (cat_data, table_no, 1, count + 1);
           if (status != MEM_S_SUCCESS) {
              VDSprintMemErr( "\t", "MEMwrite_data", status, 
							VDS_E_WRITE_COLUMN);
              status = VDS_E_WRITE_COLUMN;
	      goto fail2;
              }
            }
        else if (! strcmp (column [count], "n_identifier")) {
           add = 1;

           status = MEMwrite_data (cat_data, "PDM", 1, count + 1);
           if (status != MEM_S_SUCCESS) {
              VDSprintMemErr( "\t", "MEMwrite_data", status, 
							VDS_E_WRITE_COLUMN);
              status = VDS_E_WRITE_COLUMN;
	      goto fail2;
              }
            }
        else if (! strcmp (column [count], "n_aclno")) {
           if (! strlen (data [count])) {
               VDSprintErr ("\t", "no Acl specified in buffer\n") ;
               status = NFM_E_BAD_ACL;
	       goto fail2;
               }
           add = 1;
           }
        else if (! strcmp (column [count], "n_stateno"))
          add = 0;
        else if (! strcmp (column [count], "n_updater"))
           add = 0;
        else if (! strcmp (column [count ], "n_updatedate"))
           add = 0;
        else if (! strcmp (column [count ], "n_updatetime"))
           add = 0;
        else if (! strcmp (column [count ], "n_archivestate"))
           add = 0;
        else if (! strcmp (column [count ], "n_archiveno"))
           add = 0;
        else if (! strcmp (column [count ], "n_pendingflag"))
           add = 0;
        else if (! strcmp (column [count ], "n_pendinguser"))
           add = 0;
        else if (! strcmp (column [count ], "t_basic"))
           add = 0;
        else if (! strcmp (column [count ], "t_appl"))
           add = 0;
        else if (strlen (column [count])) add = 1;

        if (add) {
           if (comma) {
               strcat (sql_str,  ", ");
               strcat (sql_str1, ", ");
            }
           else
               comma = 1;

           strcat (sql_str, column [count]);

           if ((strcmp(column[count], "n_stateno")) &&
                (strcmp(column[count],"n_catalogno")) &&
                (strcmp(column[count], "n_aclno")) &&
                (strcmp(column[count], "n_archiveno")) &&
                (strcmp(column[count],"n_creationdate")) &&
                (strcmp(column[count],"n_updatedate")))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, data [count]);
               strcat (sql_str1, "'");
            }
            else if ((! strcmp (column [count], "n_creationdate")) ||
                      (! strcmp (column[count], "n_updatedate")))
              {
                status = NFMascii_to_timestamp_format (data [count], out_str) ;
                if (status != NFM_S_SUCCESS) {
                    VDSprintNfmErr( "\t", "NFMascii_to_timestamp_format", 
									status);
		    status = VDS_E_WRITE_FORMAT;
	   	    goto fail2;
                    }

                strcat (sql_str1, "TIMESTAMP '") ;
                strcat (sql_str1, out_str);
                strcat (sql_str1, "'") ;
              }
           else
              {
               if (strlen (data [count]))  
		    strcat (sql_str1, data [count]);
               else  	
		    strcat (sql_str1, "null");
               }
         }
      }
     WFload_acl_st (atol (data [acl])) ;

     status = WFload_wf_struct_for_sts () ;
     if (status != NFM_S_SUCCESS) {
         VDSprintErr ("\t","load transition for acl %d failed \n", 
							atol (data [i])) ;
         VDSprintNfmErr( "\t", "WFload_wf_struct_for_sts", status);
	 status = NFM_E_BAD_ACL; 
	 goto fail2;
         }

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_DUPLICATE_VALUE) {
            VDSprintErr ("\t", "Catalog <%s> already exists in nfmcatalogs\n",
								cat_name);
            status = VDS_E_CATALOG_EXISTS;
            }
	 else {
            VDSprintErr ("\t", "cannot add catalog <%s> to nfmcatalogs: %s\n",
					cat_name, VDSgetSqlErrStr(status));
	    status =  VDS_E_SQL_STMT;
	    }
	    goto fail2;
         }

	 status = VDS_S_SUCCESS;
wrapup:
     _FREE (sql_str);
     _FREE (sql_str1);
     MEMclose (&identifier_list);
     MEMclose (&attr_list1);
     MEMclose (&data_list1);
     MEMclose (&attr_list2);
     MEMclose (&data_list2);
     VDSdebug ( "EXIT create_parametric_catalog \n") ;
     return(status);

fail2:
	/* creation failed after dynaamic attribute table created */
         NFMdelete_table (VDSuser_id, pdc_table, pdc_table);

fail1:
	/* creation failed after family catalog created */
         NFMdelete_table (VDSuser_id, "CATALOG", cat_name);
	
	goto wrapup;

}


/* --------------------------------------------------------------------*/
int	VDScreate_dynamic_table ( 
		long	user_id,
		char	*pdc_tbl,
		MEMptr	dynamic_attr,
		MEMptr	dynamic_data,
		MEMptr	dynamic_list
		)
{
	long	status;

	if ( dynamic_attr == NULL || dynamic_attr->rows == 0) {
		status = VDS_E_GET_CATALOG_NAME;
     		VDSprintErr( "\t", "dynamic attribute buffer is empty\n");
		goto wrapup;
	        }
#ifdef DEBUG
	   VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
           MEMprint_buffer("dynamic_attr",dynamic_attr,VDS_DEBUG_FILE);
	   VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
           MEMprint_buffer("dynamic_data",dynamic_data,VDS_DEBUG_FILE);
	   VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
           MEMprint_buffer("dynamic_list",dynamic_list,VDS_DEBUG_FILE);
#endif

	status = NFMcreate_table ( user_id, pdc_tbl, pdc_tbl, "PDM",
				dynamic_attr, dynamic_data, dynamic_list );

	/* If duplicate exists - remove and try again */
	/* 6/7/96 slj - changed this to == instead of != */
	if (status == NFM_E_DUP_TABLE_NAME ) {
		VDSprintDbgMsg ("\tWarning: table <%s> exists - removing\n",
							pdc_tbl);
         	NFMdelete_table (user_id, pdc_tbl, pdc_tbl);
		status = NFMcreate_table ( user_id, pdc_tbl, pdc_tbl, "PDM",
				dynamic_attr, dynamic_data, dynamic_list );
		}

	if (status != NFM_S_SUCCESS ) {
     		VDSprintErr ("\t",
				"cannot create dyanamic attribute table <%s>\n",
							pdc_tbl);
         	VDSprintNfmErr( "\t", "NFMcreate_table", status);
		status = VDS_E_CREAT_TABLE;
		goto wrapup;
		}
	status = VDS_S_SUCCESS;

wrapup:
	return (status);
}

/* -----------------------------------------------------------*/
int VDSstore_classification( 	MEMptr  class_path,
				char	*dyn_table
				)
{
        char            search[100];
        char            search_str[1024];
        char            sql_str[1024];
        char            value_str[1024];
        char            usage_id[100];
        int             i,nxi, current_depth = 0, cat_no;
        char            **cat_data;
        char            **data = NULL, **column = NULL;
        MEMptr          class_bufr = NULL;
        long            status = VDS_S_SUCCESS; 
	long		sts;


#   ifdef DEBUG
    	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
       	MEMprint_buffer("class_path",class_path, VDS_DEBUG_FILE);
#   endif

    status = MEMbuild_array(class_path);
    if(status != MEM_S_SUCCESS) {
        VDSprintMemErr( "\t", "MEMbuild_array", status, 
						VDS_E_BUILD_BUFFER_ARRAY);
      	status = VDS_E_BUILD_ARRAY;
	goto wrapup;
        }

    if (!class_path->data_ptr) {
	VDSprintErr ("\t","No data in class path data buffer \n");
	status = VDS_E_BUILD_ARRAY;
	goto wrapup;
	}
    data    = (char **) class_path->data_ptr;

    if (!class_path->column_ptr) {
	VDSprintErr ("\t","No columns in class path data buffer \n");
	status = VDS_E_BUILD_ARRAY;
	goto wrapup;
	}
    column  = (char **) class_path->column_ptr;

    current_depth = atoi(data[0]);

    for (i=0 ; i < class_path->rows; i++) {
        nxi = i * class_path->columns;
        status =  VDSget_catno (data[nxi], &cat_no);
     	sql_str[0]=0;
        
        if((strlen(data[nxi+1]) > 1) && (strcmp(data[nxi+1],""))) 
             strcpy(usage_id, data[nxi+1]);
        else strcpy(usage_id, "");

     	sprintf(sql_str, "SELECT p_defname, p_depth FROM  pdmcatalogs WHERE n_catalogno = %d", cat_no);

	status = SQLquery(sql_str, &class_bufr, 1024);
        if(status != SQL_S_SUCCESS) {
            if(status != SQL_I_NO_ROWS_FOUND) {
		VDSprintSqlErr ( "\t", "cannot select classification", 
							sql_str, status);
		status = VDS_E_SQL_QUERY;
 		goto wrapup;
               	}
            }
            else {
             	status = MEMbuild_array(class_bufr);
             	if(status != MEM_S_SUCCESS) {
            	    VDSprintMemErr( "\t", "MEMbuild_array", status, 
						VDS_E_BUILD_BUFFER_ARRAY);
		     status = VDS_E_SQL_QUERY;
 		     goto wrapup;
            	     } 

     		if (!class_bufr->data_ptr) {
			VDSprintErr ("\t", "No data in class buffer \n");
			status = VDS_E_BUILD_ARRAY;
			goto wrapup;
			}
    	     	cat_data  = (char **) class_bufr->data_ptr;
           
    	     	if(!strcmp(usage_id,""))
           	strcpy(usage_id, cat_data[0]);
		sprintf(sql_str,
		   "DELETE  FROM  pdmcatalogs WHERE n_catalogno = %d", cat_no);

     		status = SQLstmt(sql_str);
       	     	if(status != SQL_S_SUCCESS) {
		    VDSprintSqlErr ( "\t", "cannot delete from pdmcatalogs", 
							sql_str, status);
		     status = VDS_E_SQL_QUERY;
 		     goto wrapup;
             	     }
             }
              
     	current_depth = 0;

       	strcpy(search_str,""); 
        strcpy(value_str,""); 
       	for (i=2 ; i < class_path->columns; i++) {
       	    if( (strlen(data[i]) > 1) && (strcmp(data[i],""))) {
            	current_depth++;
            	search[0] = '\0';
            	strcat(search_str,", "); 
            	sprintf(search,"p_level%d",current_depth);
            	strcat(search_str, search); 
            	strcat(value_str,",'"); 
            	strcat(value_str, data[nxi+i]); 
            	strcat(value_str,"'"); 
            	}
            }

      	if(!strcmp(dyn_table,""))
     	    sprintf(sql_str,"INSERT INTO  pdmcatalogs(n_catalogno, p_depth, p_defname %s)  VALUES (%d,%d, '%s' %s )",
					search_str, cat_no, current_depth, 
					usage_id, value_str);
       else
     	   sprintf(sql_str,"INSERT INTO  pdmcatalogs(n_catalogno, p_depth, p_dyntable, p_defname %s)  VALUES (%d,%d, '%s', '%s' %s )",
					search_str, cat_no, current_depth, 
					dyn_table,usage_id, value_str);

      	status = SQLstmt(sql_str);
       	if(status != SQL_S_SUCCESS) {
	   VDSprintSqlErr ( "\t", "cannot insert into pdmcatalogs", 
							sql_str, status);
	   status = VDS_E_SQL_QUERY;
	   goto wrapup;
           }
        } /* end of loop */

      status = VDS_S_SUCCESS;

wrapup:
      sts = MEMclose(&class_bufr);
      if (sts != MEM_S_SUCCESS) 
            VDSprintMemErr( "\t", "MEMclose", sts, VDS_E_OPEN_BUFFER);

      return(status);

} /* end VDSstore_classification */

/***********************************************************************
 *          STORE THE PARAMETERS IN THE PDMPARAMETERS TABLE
 *
 *
 *   All the parameters of the macros are stored  in the pdmparameters table.
 *   A index to the palloc table is the macro name. The parametric family is
 *   the view of the tables. 
 *
 * int VDSstore_parameters(parameters)
 * MEMptr parameters;  Input buffer of parameters 
 *
 * Format of input buffer:
 *
 * n_catalogname char(20) p_library char(40) p_macro char (20)
 * p_parametername char(40) p_parametertype char(10) p_iotype char (5)
 *----------------------------------------------------------------------*/

int VDSstore_parameters( MEMptr parm_bufr)
{
    char **	data;
    int   	i ,nxi;
    char  	str1[512], sql_str[1024];
    int		status;

    status = MEMbuild_array(parm_bufr);
    if(status != MEM_S_SUCCESS) {
        VDSprintMemErr( "\t", "MEMbuild_array", status, VDS_E_BUILD_ARRAY);
        status = VDS_E_BUILD_ARRAY;
        goto fail;
        }

    /* nothing to store */
    if (!parm_bufr->rows) 
    	return(VDS_S_SUCCESS);


    if (!parm_bufr->data_ptr) {
	VDSprintErr ("\t", "No data in pdm parameters buffer \n");
	status = VDS_E_BUILD_ARRAY;
	goto fail;
	}
    data = (char **) parm_bufr->data_ptr;

    /*Turn off AUTO_COMMIT */
    status = NFMstop_transaction(1200);
    if (status != NFM_S_SUCCESS) {
         VDSprintNfmErr( "\t", "NFMstop_transaction", status);
	 }

    sprintf(sql_str,"DELETE FROM pdmparameters  WHERE n_catalogname = '%s'",  
								data[0]);
    status = SQLstmt(sql_str);
    if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
	VDSprintSqlErr ( "\t", "cannot delete from pdmparameters", 
							sql_str, status);
	status = VDS_E_SQL_STMT;
	goto fail;
        }

    /* add parameters to pdmparameters table */
    str1[0]='\0';
    sprintf(str1,"%s (%s,%s) ", "INSERT INTO pdmparameters ", 
	"n_catalogname,n_synonym", "p_templatename,p_type,p_iotype,p_units");

    for(i=0;i<parm_bufr->rows;i++) {
    	nxi = i * parm_bufr->columns;
	sprintf(sql_str,"%s VALUES('%s','%s','%s','%s','%s','%s')",
				str1,data[nxi], data[nxi+1],data[nxi+2],
				data[nxi+3],data[nxi+4], data[nxi+5]);

	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS) {
		VDSprintSqlErr ( "\t", "cannot insert into pdmparameters", 
							sql_str, status);
		status = VDS_E_SQL_STMT;
	       	goto fail;
	        }
    	}

    /* commit work */
    status = NFMstart_transaction(1200);
    if(status != NFM_S_SUCCESS) {
         VDSprintNfmErr( "\t", "NFMstart_transaction", status);
	 status = VDS_E_FAILURE;
	 goto fail;
         }

    return(VDS_S_SUCCESS);

fail:
     NFMrollback_transaction(1200);
     return(status);
} /* end VDSstore_parameters */

/***********************************************************************
 *              STORE THE RELATIONSHIP between MACRO and Parametric Catalog
 * 
 * 
 *    All the parameters of the macros are stored  in the pdmparameters table.
 *    A index to the pdmparamloc table is the n_catalogname. p_macrocat is the
 *    catalog to which the macro library belongs. It is equivalent of a
 *    pdmlibraries catalog. From PDM2.0.0 there is no restriction that macro
 *    libraries should belong to one catalog type. They co-exist with with other
 *    parts. n_catalogname is the catalog which contains the parametric catalog.
 *    Each macro library contains multiple macros. This table is a contained-in-
 *    table of macrolib->macros. The sketch file *.rle [p_rle] is also stored
 *    in this table.
 * 
 * int VDSmap_catalog_macro(macros)
 * MEMptr macros; - Input buffer of macros
 * 
 * Format of input buffer:
 * 
 * n_catalogname char(18) -  Name of the parametric catalog
 * p_macrocat    char(18) -  Name of the macro library catalog -n_catalogname
 * p_macropartno char(40) -  Name of the macro library - n_itemname
 * p_macrorev    char(40) -  Revision of the macro library - n_itemrev
 * p_macroname   char(30) -  Name of the macro - EMS macro
 * p_rle         char(14) -  Sketch file associated with the EMS macro
 * 
 * E-R
 * 
 * Mac Cat - Mac Lib - Macro - Sketch
 *       1 : n     1 : n   1 : 1
 * 
 *----------------------------------------------------------------------*/

int VDSmap_catalog_macro( MEMptr macro_bufr)
{
  char **data;
  int   i ,nxi;
  char  str1[250], sql_str[1024];
  MEMptr bufr = NULL;
  int	status = VDS_S_SUCCESS;

    status = MEMbuild_array(macro_bufr);
    if(status != MEM_S_SUCCESS) {
       VDSprintMemErr( "\t", "MEMbuild_array", status, VDS_E_BUILD_ARRAY);
	status = VDS_E_BUILD_ARRAY;
	return (status);
	}

    if (!macro_bufr->data_ptr) {
	VDSprintErr ("\t", "No data in pdm macro parameters buffer \n");
	status = VDS_E_BUILD_ARRAY;
	return (status);
        }
    data = (char **) macro_bufr->data_ptr;

    if(macro_bufr->rows == 0)
       return(VDS_E_NO_MACROS_FOUND);

    /* Turn off AUTO_COMMIT */
    status = NFMstop_transaction(1200);
    if(status != NFM_S_SUCCESS) {
        VDSprintNfmErr( "\t", "NFMstop_transaction", status);
     	status = VDS_E_FAILURE;
	return(status);
        }

    /* add parameters to pdmparameters table */
    sprintf(str1,"%s (%s,%s) ", "INSERT INTO pdmparamloc ", 
				"n_catalogname,p_macrocat", 
				"p_macropartno,p_macrorev,p_macroname,p_rle");

    data = (char **) macro_bufr->data_ptr;
    for(i=0;i<macro_bufr->rows;i++) {

	 /* Get macroname */
	 nxi = i * macro_bufr->columns;
	 sprintf(sql_str,
	      "SELECT p_macroname FROM pdmparamloc WHERE n_catalogname = '%s' ",
	 	data[nxi]);
	 status = SQLquery(sql_str,&bufr,512);
	 if(status == SQL_I_NO_ROWS_FOUND) {
	      if(!strcmp(data[nxi+4],""))
	           return(VDS_E_MACRO_NOT_FOUND);

	      /* Add macroname to pdmparamloc */
	      sprintf(sql_str,"%s VALUES('%s','%s','%s','%s','%s','%s')",
	         			str1,data[nxi], data[nxi+1],data[nxi+2],
	         			data[nxi+3],data[nxi+4], data[nxi+5]);
	      status = SQLstmt(sql_str);
	      if (status != SQL_S_SUCCESS) {
		   VDSprintSqlErr ("\t", 
				"cannot insert macro into <pdmparamloc>",
							sql_str, status);
	           status = VDS_E_SQL_STMT;
	           goto fail;
	           }
	 	}
	 else {
	      /* Uppdate macroname in pdmparamloc */
	      sprintf(sql_str,"UPDATE pdmparamloc SET  p_macrocat = '%s' , p_macropartno = '%s' , p_macrorev = '%s' , p_macroname = '%s', p_rle = '%s' WHERE n_catalogname = '%s'", 
					data[nxi+1],data[nxi+2],data[nxi+3],
					data[nxi+4], data[nxi+4], data[nxi]);
	      status = SQLstmt(sql_str);
	      if(status != SQL_S_SUCCESS) {
		  VDSprintSqlErr ( "\t", "cannot update macroname  in <pdmparamloc>", 
							sql_str, status);
	          status = VDS_E_SQL_STMT;
	          goto fail;
	          }
	       }
          }

    /* commit work */
    status = NFMstart_transaction(1200);
    if(status != NFM_S_SUCCESS) {
         VDSprintNfmErr( "\t", "NFMstart_transaction", status);
	 goto fail;
         }

    return(VDS_S_SUCCESS);

fail:
     NFMrollback_transaction(1200);
     return(status);
}
