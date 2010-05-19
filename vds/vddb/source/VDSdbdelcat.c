 /* $Id: VDSdbdelcat.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbdelcat.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbdelcat.c,v $
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
 * Revision 1.7  1996/05/31  20:55:40  pinnacle
 * Replaced: vddb/source/VDSdbdelcat.c for:  by sljenks for vds.240
 *
 * Revision 1.6  1996/05/24  00:16:18  pinnacle
 * Replaced: vddb/source/ *delcat.c for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1996/05/20  03:55:34  pinnacle
 * Replaced: vddb/source/VDSdbdelcat.c for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/04/22  15:13:46  pinnacle
 * Replaced: vddb/source/VDSdbdelcat.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbdelcat.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/02/25  15:11:40  pinnacle
 * Replaced: vddb/source/VDSdbdelcat.c for:  by msbraju for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/18/96   tlb		Add prototypes
 *	04/22/96     tlb	Fix log comment problem 
 *	05/02/96     tlb	Add NFM prototypes
 *				Use new error routines
 *	05/20/96     tlb	Add user and debug messages, 
 *				Add VDSdelete_dyn_table			
 *
 *      05/31/96     slj        Added check in VDSdelete_dyn_table to see if 
 *                              the y_ table is already deleted.
 * -------------------------------------------------------------------*/

#include<stdio.h>
#include <string.h>
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "MEMproto.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "NETerrordef.h"
#include "NFMAproto.h"

#include "VDSdberrdef.h"
#include "v_risproto.h"
#include "v_dbloadprot.h"

/*---------------------------------------------------------------------*/
static
int VDSconvert_to_lower ( char *string ,
			char *string1 )
{
  int i=0 ;

  while( string[i] != '\0' ) {
     string1[i] = tolower (string[i]) ;
     i++;
     }
  return TRUE;
}
/*-----------------------------------------------------------------------*/
static
int VDSdelete_dyn_table(char * catalog_name)
{
	char  y_table[50];
	int	status = VDS_S_SUCCESS;
	int	num_records = 0;
        char	where[50];

	sprintf( y_table, "y_%s", catalog_name );
       	VDSconvert_to_lower( y_table, y_table );

        /* Check to see if table was already deleted by looking in */
        /* ris5tables. If the risschema changes, this call will need */
        /* to reflect the new schema changes */
        sprintf (where, "table_name = '%s'", y_table);
        status = VDSris_get_count (&num_records, "ris5tables", where);
        if (status != 1)
        {
               VDSprintDbgMsg("ERROR: Unable to verify table exists");
               status = VDS_E_DELETE_CATALOG;
               return(status);
          }

        if (num_records == 0)
        {
           /* Uncomment the next line if you want the user to see that */
           /* the y_ table is already deleted */
           /* VDSprintDbgMsg("       ... Dyanamic attribute table <%s> already delted\n", y_table); */
           status = NFM_S_SUCCESS;
           return(status);
         }

	status = NFMdelete_table( VDSuser_id, y_table, y_table );
	if (status != NFM_S_SUCCESS) {
	     VDSprintErr ("\t", "cannot delete dynamic attribute table <%s>\n",
								y_table);
        	VDSprintNfmErr( "\t", "NFMdelete_table", status);
		status = VDS_E_DELETE_CATALOG;
	 	}

	return (status);
}
/*-----------------------------------------------------------------------*/
/* Delete catalog
 *	No error checking - if a delete fails, continue anyway.
 *	catalog has been verified to exist
 */
int VDSdelete_catalog(catalog_name)
char	*catalog_name;
{
	long		status;
	char		sql_str[1024];
	MEMptr		dyn_bufr = NULL, cat_bufr = NULL;
	char		**dyn_data;
	long		n_catalogno;
	char            del_str[240];

	VDSdebug("ENTER: VDSdelete_catalog\n");

	VDSprintUsrMsg("  Deleting Catalog <%s> \n", catalog_name);

 	status = NFMset_autocommit_on (1200) ;
     	if (status != NFM_S_SUCCESS) {
        	VDSprintNfmErr( "\t", "NFMset_autocommit_on", status);
		/* continue */
		}

	/* 
 	 * Delete parts in catalog 
	 */
	VDSprintDbgMsg ("  ... Deleting catalog parts\n");
	VDSDeleteParts( catalog_name, "all", "all", "" );
		/* no status - always succeeds */
	

	/* 
	 * Delete catalog table 
	 */
	VDSprintDbgMsg ("  ... Deleting catalog table <%s> \n", catalog_name);
	status = NFMdelete_catalog(VDSuser_id,catalog_name, &n_catalogno);
        if(status != NFM_S_SUCCESS) {
                if(status == NFM_E_NOT_EMPTY_CAT) {
			VDSprintErr ("\t", 
				"cannot delete <%s>: catalog is not empty \n",
								catalog_name);
			status = VDS_E_CATALOG_NOT_EMPTY;
			goto wrapup;
			}
        	VDSprintNfmErr( "\t", "NFMdelete_catalog", status);
        	}


	/* 
	 * Delete pdmfnattrmap entry 
	 */
	VDSprintDbgMsg ("  ... Deleting entry from <pdmfnattrmap>\n");
       sprintf(del_str, "DELETE FROM pdmfnattrmap where n_catalogname = '%s'",
		  					catalog_name);
       status = SQLstmt(del_str);
       if(status != SQL_S_SUCCESS) 
		VDSprintDbgMsg ("\tNo <pdmfnattrmap> entry for this catalog\n");
	

       /* 
	* Delete pdmparamloc entry 
 	*/
	VDSprintDbgMsg ("  ... Deleting entry from <pdmparamloc>\n");
       sprintf( del_str, "DELETE FROM pdmparamloc where n_catalogname = '%s'",
							catalog_name );
       status = SQLstmt( del_str );
       if( status != SQL_S_SUCCESS ) 
		VDSprintDbgMsg ("\tNo <pdmparamloc> entry for this catalog\n");
	

       /* 
	* Delete pdmparameters entry 
	*/
	VDSprintDbgMsg ("  ... Deleting entry from <pdmparameters>\n");
       sprintf( del_str, "DELETE FROM pdmparameters where n_catalogname = '%s'",
							catalog_name );
       status = SQLstmt( del_str );
       if( status != SQL_S_SUCCESS ) 
		VDSprintDbgMsg ("\tNo <pdmparameters> entry for this catalog\n");


	/* 
	 * Delete dyanamic parameters table 
	 */
	sprintf(del_str, 
		"SELECT p_dyntable FROM pdmcatalogs where n_catalogno = %d", 
	   						n_catalogno);
	status = SQLquery(del_str,&dyn_bufr,512);
	if(status != SQL_S_SUCCESS) 
		status = VDSdelete_dyn_table(catalog_name);
	else {
           status = MEMbuild_array (dyn_bufr);
           if(status != MEM_S_SUCCESS) {
            	VDSprintMemErr( "\t", "MEMbuild_array", status, 
						VDS_E_BUILD_BUFFER_ARRAY);
		status = VDS_E_BUILD_BUFFER_ARRAY;
        	return (status);
                }

           dyn_data = (char **) dyn_bufr->data_ptr;
           sprintf(del_str,
		"SELECT n_catalogno FROM pdmcatalogs WHERE p_dyntable = '%s'", 
		 dyn_data[0]);
           status = SQLquery(del_str, &cat_bufr,512);
           if(status == SQL_S_SUCCESS) {
             status = MEMbuild_array (cat_bufr);
             if(status != MEM_S_SUCCESS) {
            	VDSprintMemErr( "\t", "MEMbuild_array", status, 
						VDS_E_BUILD_BUFFER_ARRAY);
		 status = VDS_E_BUILD_BUFFER_ARRAY;
		 return (status);
	         }

             if(cat_bufr->rows > 0) {
                 VDSconvert_to_lower(dyn_data[0], dyn_data[0]);
                 status = NFMdelete_table(VDSuser_id,dyn_data[0],dyn_data[0]);
                 if (status != NFM_S_SUCCESS) {
        	    VDSprintNfmErr( "\t", "NFMdelete_table", status);
		    status = VDS_E_DELETE_CATALOG;
		    return (status);
                    }
                  }
	     else 
		status = VDSdelete_dyn_table(catalog_name);

	     sprintf( del_str,
	     "DELETE FROM pdmcatalogs WHERE n_catalogno = %d AND p_dyntable = %s",
		      n_catalogno, dyn_data[0] );

	     status = SQLstmt( del_str );
	     if( status != SQL_S_SUCCESS )
	       	   VDSprintDbgMsg (
			"\tCould not delete <%s> entry from <pdmcatalogs>\n",
			dyn_data[0]); 
	   }
	   else 
		status = VDSdelete_dyn_table(catalog_name);

           MEMclose(&cat_bufr);
           MEMclose(&dyn_bufr);
	}
	
    /* delete pdmcatalogs entry if n_catalogno is known */
    if(n_catalogno != -1) {
          sql_str[0] = '\0';
          sprintf(sql_str,"%s %s %d", 
		"DELETE FROM pdmcatalogs", "WHERE n_catalogno = ",n_catalogno);
          status = SQLstmt(sql_str);

	  status = NFMdelete_loc_entry( VDSuser_id, n_catalogno );
	  if( status != NFM_S_SUCCESS ) 
            VDSprintNfmErr( "\t", "NFMdelete_loc_entry", status);
    	  }

    status = VDS_S_SUCCESS;

wrapup:
    VDSdebug("EXIT: VDSdelete_catalog\n");
    return(status);
}
