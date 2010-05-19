/* $Id: VDSdbdbase.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbdbase.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbdbase.c,v $
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
 * Revision 1.8  1996/06/11  23:01:58  pinnacle
 * Replaced: vddb/source/VDSdbdbase.c for:  by v240_int for vds.240
 *
 * Revision 1.7  1996/05/29  19:09:34  pinnacle
 * Replaced: vddb/source/VDSdbdbase.c for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/05/20  03:54:22  pinnacle
 * Replaced: vddb/source/VDSdbdbase.c for:  by v240_int for vds.240
 *
 * Revision 1.5  1996/04/22  15:13:34  pinnacle
 * Replaced: vddb/source/VDSdbdbase.c for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbdbase.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/14  16:54:52  pinnacle
 * Replaced: vddb/source/VDSdbdbase.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/05  22:33:32  pinnacle
 * Replaced: vddb/source/VDSdbdbase.c for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *  	05/04/92     MALLIK	Removed calls for checkin libraries
 *  	05/04/92     MALLIK	Removed reference to over_path
 *	04/05/96     tlb	Change i_* index to unique index
 *				Rename is_* index to conform to NFM index style
 *	04/14/96     tlb  	Fix is_* index name
 *	04/18/96     tlb	Add prototypes
 *				Rename VDSdbstr.h constants 
 *	04/22/96     tlb	Fix log comment problem, Remove extra vars 
 *	04/29/96     tlb	Fix user message, Add user message for progress
 *				Add NFM prototypes
 *				VDSadd_part - add RisFreeBuffer
 *				VDSadd_part - remove local* args
 *				VDSadd_family - move check for family to
 *					VDScreate_catalogs
 *				Use new error routines
 *				Remove VDSadd_dynamic_table - unused
 *	05/29/96     tlb 	VDSadd_family - cleanup if any step fails
 *	06/10/96     tlb Fix debug printouts
 *			 MEMprint_buffer crashes on NULL output for Solaris
 *
 * -------------------------------------------------------------------*/

#include 	<stdio.h>
#include 	<string.h>
#include 	<MEMerrordef.h>
#include 	<MEMstruct.h>
#include 	<MEMproto.h>
#include 	<NFMerrordef.h>
#include	<NFMstruct.h>
#include	<DEBUG.h>
#include	<NFMapi.h>
#include 	<NFMUproto.h>
#include 	"VDSdbmsg.h"
#include 	"VDSdbstr.h"
#include	"VDSdberrdef.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

/*----------------------------------------------------------------------------*/


int VDSadd_part ( 
		  MEMptr   desc_buffer	/* I: family description buffer*/
		)
	
{

   /***************************************************************************/
   /*                                                                         */
   /*   This routine add a part to the catalog "pdmlibraries". This part is   */
   /*   a macro library containing several macro definitions.		      */
   /*                                                                         */
   /*   Algorithm :                                                           */
   /*           1)  initialize the refresh area structure		      */
   /*           2)  search the part name in the description buffer	      */
   /*           3)  ask for the existence of this part on the database	      */
   /*           4)  begin workflow to create a part			      */
   /*           5)  ask for the attributes , default data & default list to   */
   /*		    the database ( attr_buffer, data_buffer, list_buffer)     */
   /*           6)  complete default data buffer with the description buffer  */
   /*           7)  add the part to "pdmlibraries"			      */
   /*           8)  close the workflow					      */
   /*           9)  close attr_buffer, data_buffer & list_buffer	      */
   /*           10) build and fill the storage buffer			      */
   /*           11) check in the library				      */
   /*           12) close the storage buffer				      */
   /*                                                                         */
   /*   Routines called :                                                     */
   /*                           MEMbuild_array                                */
   /*                           MEMclose                                      */
   /*                           MEMprint_array                                */
   /*                                                                         */
   /*                           PDMadd_part                                   */
   /*                           PDMcheckin_library                            */
   /*                           PDMget_table_data                             */
   /*                           PDMsql_query                                  */
   /*                                                                         */
   /*                           PDUget_storage_buffer                         */
   /*                           PDUmessage_trans                              */
   /*                                                                         */
   /*                           VDSclose_buffers			      */
   /*                           VDSextract_cofilename			      */
   /*                           VDSfill_part_data_buffer		      */
   /*                           VDSread_in_buffer			      */
   /*                                                                         */
   /***************************************************************************/

   char		format[VDS_BUF_MAX_WORD];	/* current attribute datatype */
   char		path_lib[VDS_BUF_MAX_WORD];	/* path to the macro library  */
   char		partdesc[VDS_BUF_MAX_WORD];	/* description to the macro library   */
   char		path[VDS_BUF_MAX_WORD];		/* relat path to the macro library    */
   char		cofilename[VDS_BUF_MAX_WORD];	/* name of the macro library */
   char		search_crit[VDS_BUF_MAX_LONG];	/* SQL search criteria	     */
   char		acl_format[VDS_BUF_MAX_WORD];	/* ACL workflow name 	*/
   char		acl_value[VDS_BUF_MAX_WORD];	/* ACL workflow value 	*/

   char		query[200];
   int		status = VDS_S_SUCCESS;
   int		MEMstatus = MEM_S_SUCCESS;
   int		sts;
   int		cols, rows;
   MEMptr	query_buffer   = NULL;	/* output buffer : PDMsql_query       */
   MEMptr	attr_buffer    = NULL;	/* output buffer : PDMget_table_data  */
   MEMptr	data_buffer    = NULL;	/* output buffer : PDMget_table_data  */
   MEMptr	list_buffer    = NULL;	/* output buffer : PDMget_table_data  */
   char		**result;

   VDSdebug ("ENTER: VDSadd_part\n");

   /* get the macro library name in description buffer */
   status = VDSread_in_buffer ( desc_buffer,
				VDS_FILENAME_ATTR,
				0,
				format,
				path_lib );
   if ( status != VDS_S_SUCCESS) {
     VDSprintUsrMsg( "Error reading description buffer\n" );
     VDSprintVdsErr( "\t", "VDSread_in_buffer", status );
     goto quit;
   }

   /* get the macro library description in description buffer */
   status = VDSread_in_buffer ( desc_buffer,
				VDS_DESCRIPTION_ATTR,
				0,
				format,
				partdesc );

   if( status != VDS_S_SUCCESS ) {
     VDSprintErr( "\t", "Error reading description buffer\n" );
     VDSprintVdsErr( "\t", "VDSread_in_buffer", status );
     goto quit;
     }

   /* extract macro library name */
   status = VDSextract_cofilename ( path_lib, path, cofilename );
   if ( status != VDS_S_SUCCESS ) {
     VDSprintErr( "\t", "could not extract macro library name\n", status );
     VDSprintVdsErr( "\t", "VDSextract_cofilename", status );
     goto quit;
     }

   /* prepare the query for database */
   sprintf ( search_crit, "WHERE %s = \'%s\'", VDS_PARTID_ATTR, cofilename);
   sprintf ( query, "SELECT %s FROM %s %s", VDS_PARTID_ATTR, LIBRARY, 
								search_crit );
   status = VDSsql_query ( query, &cols, &rows, &result );
   if ( !status ) {
	VDSprintSqlErr ( "\t", "cannot select part from library", query,status);
	status = VDS_E_FAILURE;
	goto quit; 
	}

   /* exit successfully if part already exists */
   if( rows >= 1 ) {
	VDSdebug ("\tpart <%s> Already exists\n", cofilename );
	goto wrapup;
        }

   /* begin the workflow to add a part */
   VDSprintUsrMsg ("\t... Adding the library part <%s> to <%s>\n", 
							cofilename, LIBRARY);

   /* Validate User Access */
   /* get informations on pdmlibraries catalog attributes & default values */
   status = WFvalidate_user_access( VDSuser_id,"Add Item","","",LIBRARY,
					"","");
   if ( status != NFM_S_SUCCESS) {
	VDSprintErr ( "\t", "cannot add item to \'%s\'\n", LIBRARY );
        VDSprintNfmErr( "\t", "WFvalidate_user_access", status);
	goto quit;
        }

   status = VDSget_table_data ( ADD_DATA,
				     PDM_PART,
				     LIBRARY,
				     &attr_buffer,
				     &data_buffer,
				     &list_buffer );
   if ( status != VDS_S_SUCCESS) {
     	VDSprintVdsErr( "\t", "VDSget_table_data", status );
	goto quit;
        }


   MEMstatus = MEMbuild_array ( attr_buffer);
   if( MEMstatus != MEM_S_SUCCESS ) {
    	status = VDS_E_BUILD_BUFFER_ARRAY;
        VDSprintErr( "\t", "Could not build attribute buffer\n");
        VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
	goto quit;
	}


   MEMstatus = MEMbuild_array ( data_buffer);
   if( MEMstatus != MEM_S_SUCCESS ) {
    	status = VDS_E_BUILD_BUFFER_ARRAY;
        VDSprintErr( "\t", "Could not build data buffer\n");
        VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
	goto quit;
	}

   MEMstatus = MEMbuild_array ( list_buffer);
   if( MEMstatus != MEM_S_SUCCESS ) {
    	status = VDS_E_BUILD_BUFFER_ARRAY;
        VDSprintErr( "\t", "Could not build list buffer\n");
        VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
	goto quit;
	}


   /* fill data_buffer */
   strcpy ( acl_format, ((char**)((list_buffer)->column_ptr))[0] );
   if (list_buffer->rows > 1)
      strcpy ( acl_value ,
               ((char**)((list_buffer)->data_ptr))[list_buffer->columns]);
   else
      strcpy ( acl_value , ((char**)((list_buffer)->data_ptr))[0]);

   status = VDSfill_part_data_buffer ( &data_buffer,
					 cofilename,
					 partdesc,
					 acl_format,
					 acl_value );
   if ( status != VDS_S_SUCCESS) {
     	VDSprintErr( "\t", "Could not fill part data buffer\n" );
     	VDSprintVdsErr( "\t", "VDSfill_part_data_buffer", status );
     	goto quit;
     	}

   /* add part to pdmlibraries */
   status = VDSadd_part_( LIBRARY, attr_buffer, data_buffer);
   if( status != VDS_S_SUCCESS ) {
     	VDSprintVdsErr( "\t", "VDSadd_part_", status );
	goto quit;
	}

   /* close the workflow to add a part */
   status = NFMset_wf_state("PDM",VDS_S_SUCCESS,"Successful completion");
   if ( status != NFM_S_SUCCESS) {
   	status = VDS_S_SUCCESS;
        VDSprintNfmErr( "\t", "NFMset_wf_state", status);
	goto quit;
        }

wrapup:
   status = VDS_S_SUCCESS;

quit :
   /* close buffers
    *	preserve exit status - use sts for checking
    */

   /* close query buffer */
   sts = MEMclose ( &query_buffer);
   if( sts != MEM_S_SUCCESS )
   	VDSprintMemErr( "\t", "MEMclose", sts, VDS_E_CLOSE_BUFFER);
 
   /* close buffers */
    sts = VDSclose_buffers ( &attr_buffer, &data_buffer, &list_buffer);
    if ( sts != VDS_S_SUCCESS) 
     	VDSprintVdsErr( "\t", "VDSclose_buffers", sts );

   /* Free select result */
    VdsRisFreeBuffer (result, rows * cols);

   VDSdebug ("EXIT: VDSadd_part\n");
   return ( status);
}


/*----------------------------------------------------------------------------*/

int VDSadd_family ( 
   	MEMptr	desc_buffer,	/* buffer of parametric family description    */
   	MEMptr	loc_attr_def,	/* loc_attr buffer definition 		      */
   	MEMptr	loc_data_def,	/* loc_data buffer definition 		      */
   	MEMptr	loc_list_def,	/* loc_list buffer definition 		      */
   	MEMptr	cat_attr_def,	/* cat_attr buffer definition 		      */
   	MEMptr	cat_data_def,	/* cat_data buffer definition 		      */
   	MEMptr	cat_list_def	/* cat_list buffer definition 		      */
	)
{

   /***************************************************************************/
   /*                                                                         */
   /*   This routine create a parametric family associated with a macro       */
   /* definition. This family is a database's catalog.	 		      */
   /*                                                                         */
   /*   Algorithm :                                                           */
   /*			1)  extract macro library_name, name & description    */
   /*			2)  build and fill the buffer of parameters	      */
   /*			3)  build and fill the buffer of user data	      */
   /*			4)  build the pdmparameters buffer		      */
   /*			5)  Build the classification buffer		      */
   /*			5)  update the refresh area			      */
   /*			6)  verify that macro_lib is a part of pdmlibraries   */
   /*			7)  begin workflow to add a parametric catalog	      */
   /*			8)  create the catalogs loc_attr,loc_data, cat_attr,  */
   /*				cat_data & cat_list.			      */
   /*			9)  add the parametric family to the database	      */
   /*			10) verify that family is added to the database	      */
   /*			11) close workflow				      */
   /*			12) close buffers				      */
   /*                                                                         */
   /*   Routines called :                                                     */
   /*                           MEMbuild_array                                */
   /*                           MEMclose                                      */
   /*                           MEMprint_array                                */
   /*                                                                         */
   /*                           PDMadd_family				      */
   /*                           PDMverify_catalog			      */
   /*                           PDMverify_part				      */
   /*                                                                         */
   /*                           PDUmessage_trans			      */
   /*                                                                         */
   /*                           VDSclose_buffers			      */
   /*                           VDScreate_family_catalog		      */
   /*                           VDSdisplay_refresh			      */
   /*                           VDSfamily_parameters			      */
   /*                           VDSparm_pmpt_user			      */
   /*                                                                         */
   /***************************************************************************/

   char 	lib_num[VDS_BUF_MAX_WORD];	/* macro library name	      */
   char 	family_name[VDS_BUF_MAX_WORD];	/* macro name		      */
   char 	pdm_dyn_table[VDS_BUF_MAX_WORD];/* dynamic tabl  name	*/
   char 	family_desc[VDS_BUF_MAX_WORD];	/* macro description	*/
   char		vds_product[VDS_BUF_MAX_WORD];  /* Product Name 	*/
   char 	vds_dyn_table[VDS_BUF_MAX_WORD];/* vds dynamic table name*/
   char 	vds_cit_table[VDS_BUF_MAX_WORD];/* vds contained in table name*/

   MEMptr	cat_attr        = NULL;	/* output buffer : PDMget_table_attr  */
   MEMptr	cat_data        = NULL;	/* output buffer : PDMget_table_attr  */
   MEMptr	cat_list        = NULL;	/* output buffer : PDMget_table_attr  */
   MEMptr	loc_attr        = NULL;	/* output buffer : PDMget_table_data  */
   MEMptr	loc_data        = NULL;	/* output buffer : PDMget_table_data  */
   MEMptr	parm_buffer     = NULL;	/* parameters buffer		      */
   MEMptr	user_buffer     = NULL;	/* user's parameters buffer	      */

   MEMptr	dyn_attr_def = NULL;
   MEMptr	dyn_attr = NULL;
   MEMptr	dyn_data = NULL;
   MEMptr	dyn_list = NULL;

   MEMptr	class_path = NULL;
   MEMptr	pdmparm_buf = NULL;
   MEMptr	macro_buf = NULL;

   int		VDSstatus;
   int		MEMstatus;
   char		row_of_data[VDS_BUF_MAX_STRING];
   int		status;

   VDSdebug ("ENTER: VDSadd_family\n");

#ifdef TRACE
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_array ( "desc_buffer", desc_buffer, VDS_DEBUG_FILE);
#endif

   VDSprintUsrMsg ("\t... Verifying catalog parameters\n");

   /* extract macro_library, macro_name, macro_description, dynamic table */
   vds_dyn_table[0] = 0;
   vds_cit_table[0] = 0;
   vds_product[0] = 0;
   VDSstatus = VDSfamily_parameters ( 	desc_buffer,
					lib_num,
					family_name,
					family_desc );

   if ( VDSstatus != VDS_S_SUCCESS) {
         VDSprintVdsErr( "\t", "VDSfamily_parameters", VDSstatus );
         goto wrapup;
         }

   /* creating parm_buffer & user_buffer */
   VDSstatus = VDSparm_pmpt_user( desc_buffer,
				  &parm_buffer,
				  &user_buffer );
   if ( VDSstatus != VDS_S_SUCCESS) {
     VDSprintVdsErr( "\t", "VDSparm_pmpt_user", VDSstatus );
     goto wrapup;
     }

   /* Create a buffer for PDM parameters and the macro buffer */
   VDSstatus = VDSpdm_parm_buf ( desc_buffer,
                                 family_name,
                                 LIBRARY,
                                 lib_num,
                                 LIBREV,
                                 &pdmparm_buf,
                                 &macro_buf );

   if ( VDSstatus != VDS_S_SUCCESS) {
	VDSprintErr ("\t", "Could not create buffer for PDM parameters\n");
        VDSprintVdsErr( "\t", "VDSpdm_parm_buf", VDSstatus );
	goto wrapup;
    }

   /* Read the classification from the desc_buffer */
   VDSstatus = VDSclass_path ( desc_buffer, family_name, &class_path );
   if ( VDSstatus != VDS_S_SUCCESS) {
	VDSprintErr ("\t", "Could not read classification from buffer\n");
        VDSprintVdsErr ("\t","VDSclass_path", VDSstatus);
	goto wrapup;
    	}


#ifdef TEST
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_array ( "VDSparm_pmpt_user: parm_buffer", parm_buffer, 
							VDS_DEBUG_FILE);
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_array ( "VDSparm_pmpt_user: user_buffer", user_buffer, 
							VDS_DEBUG_FILE);
#endif

   /* verify part */
   VDSstatus = VDSverify_part ( LIBRARY, lib_num, LIBREV);
   if ( VDSstatus != VDS_S_SUCCESS) {
    	VDSprintVdsErr( "\t", "VDSverify_part", VDSstatus );
     	goto wrapup;
    	}

   /* begin workflow to add a parametric catalog */
   VDSprintDbgMsg ("\t... Verifying access permission\n");
   status = WFvalidate_user_access( VDSuser_id,"Create Catalog","","",LIBRARY,
							lib_num,LIBREV);
   if ( status != NFM_S_SUCCESS) {
     	VDSprintNfmErr( "\t", "WFvalidate_user_access", status);
     	goto wrapup;
        }

   VDSprintDbgMsg ("\t... Retrieve table attributes\n");
   status = NFMquery_table_template ( VDSuser_id, &dyn_attr_def );
   if( status != NFM_S_SUCCESS ) {
        VDSprintNfmErr( "\t", "NFMquery_table_template", status);
	goto wrapup;
        }

   VDSstatus = VDSupdate_data_buffer ( &dyn_data, dyn_attr_def );
   if( VDSstatus != VDS_S_SUCCESS ) {
     	VDSprintVdsErr( "\t", "VDSupdate_data_buffer", VDSstatus );
     	goto wrapup;
     	}


  /* Create family catalog
   *	side-effect: links MEMPtrs
   *		loc_attr -> loc_attr_def
   *		loc_data -> loc_data_def
   *		cat_attr -> cat_attr_def
   *		cat_data -> cat_data_def
   *		cat_list -> cat_list_def
   *		dyn_attr -> dyn_attr_def 
   */
   VDSprintDbgMsg ("\t... Building catalog buffers\n");
   VDSstatus = VDScreate_family_catalog ( family_name,
                                          parm_buffer,
                                          user_buffer,
                                          &loc_attr,
                                          &loc_data,
                                          &cat_attr,
                                          &cat_data,
                                          &cat_list,
                                          loc_attr_def,
                                          loc_data_def,
                                          loc_list_def,
                                          cat_attr_def,
                                          cat_data_def,
                                          cat_list_def,
                                          dyn_attr_def,
                                          &dyn_attr,
					    row_of_data );

   if ( VDSstatus != VDS_S_SUCCESS ) {
     	VDSprintVdsErr( "\t", "VDScreate_family_catalog", VDSstatus );
	goto wrapup;
   	}

   VDSstatus = VDSupdate_data_buffer ( &dyn_data, dyn_attr );
   if( VDSstatus != VDS_S_SUCCESS ) {
        VDSprintVdsErr( "\t", "VDSupdate_data_buffer", VDSstatus );
  	goto wrapup;
        }

   /* Write the default dynamic data in dyn_data buffer */
   MEMstatus = MEMwrite ( dyn_data, row_of_data );
   if( MEMstatus != MEM_S_SUCCESS ) {
     	VDSprintErr ("\t", "Write of default dynamic data failed\n");
     	VDSstatus = VDS_E_WRITE_BUFFER;
     	VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
     	goto wrapup;
     	}

#ifdef DEBUG
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
   	MEMprint_buffer ( "LOC ATTR"   , loc_attr       , VDS_DEBUG_FILE);
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
   	MEMprint_buffer ( "LOC DATA"   , loc_data       , VDS_DEBUG_FILE);
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
   	MEMprint_buffer ( "CAT ATTR"   , cat_attr       , VDS_DEBUG_FILE);
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
   	MEMprint_buffer ( "CAT DATA"   , cat_data       , VDS_DEBUG_FILE); 
	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
	MEMprint_buffer ( "CAT LIST"   , cat_list       , VDS_DEBUG_FILE);
#endif

   /* add a parametric family to the database */
   VDSstatus = VDScreate_parametric_catalog( loc_data,
                                             cat_attr,
                                             cat_data,
                                             cat_list,
                                             dyn_attr,
                                             dyn_data,
                                             dyn_list,
                                             pdm_dyn_table);

   if ( VDSstatus != VDS_S_SUCCESS ) {
     	VDSprintVdsErr( "\t", "VDScreate_parametric_catalog", VDSstatus );
	goto wrapup;
   	}
 
   /* Create index on parameteric catalog */
   VDSprintDbgMsg ("\t... Creating catalog indices\n");
   VDSstatus = VDScreate_catalog_index( family_name );
   /* continue regardless of status */

   VDSprintUsrMsg ("\t... Storing classification in <pdmcatalogs>\n");
   VDSstatus = VDSstore_classification ( class_path, pdm_dyn_table );
   if( VDSstatus != VDS_S_SUCCESS ) {
        VDSprintVdsErr( "\t", "VDSstore_classification", VDSstatus );
	goto error;
	}

   VDSprintUsrMsg ("\t... Storing parameters in <pdmparameters> table\n");
   VDSstatus = VDSstore_parameters( pdmparm_buf );
   if( VDSstatus != VDS_S_SUCCESS )  {
     	VDSprintVdsErr( "\t", "VDSstore_parameters", VDSstatus );
	goto error;
	}


   VDSprintUsrMsg ("\t... Storing relationship between macro and catalog in <pdmparamloc>\n");
   VDSstatus = VDSmap_catalog_macro ( macro_buf );
   if( VDSstatus != VDS_S_SUCCESS ) {
     	VDSprintVdsErr( "\t", "VDSmap_catalog_macro", VDSstatus );
	goto error;
	}


   status = NFMset_wf_state("PDM",VDS_S_SUCCESS,"Successful completion");
   if ( status != NFM_S_SUCCESS) {
     	VDSprintNfmErr( "\t", "NFMset_wf_state", status);
     	VDSstatus = VDS_E_FAILURE;
    	}

wrapup :
   status = VDSclose_buffers ( &parm_buffer, &user_buffer, NULL );
   if ( status != VDS_S_SUCCESS) 
     	VDSprintVdsErr( "\t", "VDSclose_buffers", status );

   status = VDSclose_buffers ( &dyn_attr_def, &dyn_data, NULL);
   if ( status != VDS_S_SUCCESS) 
     	VDSprintVdsErr( "\t", "VDSclose_buffers", status );

   status = VDSclose_buffers ( &class_path, &pdmparm_buf, &macro_buf);
   if ( status != VDS_S_SUCCESS) 
     	VDSprintVdsErr( "\t", "VDSclose_buffers", status );

   /* The other buffers are freed elsewhere
    *	dyn_attr - ??
     *		loc_attr -> loc_attr_def
     *		loc_data -> loc_data_def
     *		cat_attr -> cat_attr_def
     *		cat_data -> cat_data_def
     *		cat_list -> cat_list_def
     */

   VDSdebug ("EXIT: VDSadd_family\n");
   return ( VDSstatus);

error:
   /* cleanup after nfmcatalogs has been updated */
   VDSprintUsrMsg ("\n\tCatalog creation failed: removing tables\n");
   VDSdelete_catalog (family_name);
   goto wrapup;
}

/*-----------------------------------------------------------------------*/
int VDScreate_catalog_index( family_name )
char	*family_name;
{
	char	sql_str[200];
	int	sts;


	/* create unique index i_<n_itemname>_1 on (n_itemno) */
	sprintf(sql_str,"create unique index i_%s_1 on %s ( %s )",
		 family_name, family_name, VDS_PARTID_NO );
	sts = SQLstmt( sql_str );
	if (sts != SQL_S_SUCCESS)
		VDSprintSqlErr ( "\t", "index on itemno not created",
							sql_str, sts);

   	/* create unique index i_<n_itenname>_2 on (n_itemname, n_itemrev) */
	sprintf(sql_str,"create unique index i_%s_2 on %s ( %s, %s )",
		 family_name, family_name, VDS_PARTID_ATTR, VDS_REVISION_ATTR);
	sts = SQLstmt( sql_str );
	if (sts != SQL_S_SUCCESS) 
		VDSprintSqlErr ( "\t", 
				"index on itemname and itemrev not created",
							sql_str, sts);
	return TRUE;
}
