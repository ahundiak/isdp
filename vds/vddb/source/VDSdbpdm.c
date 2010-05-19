/* $Id: VDSdbpdm.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbpdm.c
 *
 * Description:
 *	VDScreate_family
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbpdm.c,v $
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
 * Revision 1.8  1996/06/11  23:00:44  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by v240_int for vds.240
 *
 * Revision 1.7  1996/05/20  15:40:38  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by v240_int for vds.240
 *
 * Revision 1.6  1996/05/20  05:05:38  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by v240_int for vds.240
 *
 * Revision 1.5  1996/04/22  15:14:40  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/03/18  11:11:58  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by msbraju for vds.240
 *
 * Revision 1.2  1995/11/30  23:34:00  pinnacle
 * Replaced: vddb/source/VDSdbpdm.c for:  by azuurhou for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/12/96   tlb	Move VDS_DEBUG_FILE declartion to VDSdbdbg.c
 *			Add prototypes
 *			Rename VDSdbstr.h constants 
 *	04/22/96   tlb	Fix log comment problem 
 *	04/29/96   tlb	Remove PDU logout/login after failed creation
 *			Remove commented out code
 *			buffer_in, buff_no  not initialized
 *			Remove args to VDScreate_catalogs
 *			Move user_id checking to main
 *			Check if catalog exists in VDScreate_catalog
 *			Use new error handling functions
 *			Replace '<' with '!=' for  MEM_S_SUCCESS check
 *	06/10/96   tlb	MEMprint_buffer crashes on NULL output for Solaris
 *
 * -------------------------------------------------------------------*/
#include	<stdio.h>
#include	<string.h>
#include 	<sys/utsname.h>

#include 	"MEMerrordef.h"
#include 	"MEMstruct.h"
#include 	"MEMproto.h"
#include 	"NFMerrordef.h"
#include 	"VDSdbmsg.h"
#include 	"VDSdbstr.h"
#include	"VDSdberrdef.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"


/*--------------------------------------------------------*/
/* Private Function
 *	Check if last family in buffer 
 */
static 
int VDSreset_buffer (
   	MEMptr	buffer_in,	/* MEMptr buffer build from ASCII file*/
   	int 	*buff_no 	/* current buffer number     */
	)
{
	int	current, MEMstatus;
	int	sts = TRUE;

      	current = *buff_no;
      	MEMstatus = MEMreset_buffer ( buffer_in, buff_no);
      	if (MEMstatus != MEM_S_SUCCESS) 
		sts = FALSE;
      	if ( current == *buff_no ) 
		sts = FALSE;

	return (sts);
}
 
/*------------------------------------------------------------------------*/
int VDScreate_catalogs ( )
{

   /***************************************************************************/
   /*									      */
   /*    This routine generate parametric families on the I/PDM database from */
   /* an ASCII file.							      */
   /*									      */
   /*    Algorithm :							      */
   /*		1)  initialize variables				      */
   /*		3)  convert the ASCII file into a MEMptr buffer	              */
   /*		5)  choose storage data (default values)		      */
   /*		6)  add the "macro library" part to pdmlibraries, if needed   */
   /*		7)  create the "parametric family" catalogs		      */
   /*		8)  put the I/PDM debugs off (option)                         */
   /*		9)  close MEMptr buffer					      */
   /*									      */
   /*     Errors are printed here					      */
   /*									      */
   /*    Routines called :						      */
   /*				MEMclose				      */
   /*				MEMreset_buffer				      */
   /*				MEMsplit_copy_buffer			      */
   /*									      */
   /*				VDSadd_family				      */
   /*				VDSadd_part				      */
   /*				VDSascii_to_buffer			      */
   /*				VDSdisplay_PDUsts			      */
   /*				VDSdisplay_refresh			      */
   /*				VDSlogin				      */
   /*				VDSlogout				      */
   /*				VDSread_in_buffer			      */
   /*									      */
   /***************************************************************************/


   int 		VDSstatus;		/* return code from VDS routine	      */
   int 		status;			/* internal return code 	      */
   int 		MEMstatus;		/* return code from MEM routine       */
   char		format[VDS_BUF_MAX_WORD];/* attribute format in MEMptr buffer */
   char		value[VDS_BUF_MAX_WORD];/* attribute value  in MEMptr buffer  */
   int 		buff_no = -1;		/* current buffer number 	      */
   MEMptr	buffer_in = NULL;	/* MEMptr buffer build from ASCII file*/
   MEMptr	loc_attr_def = NULL;	/* MEMptr buffer loc_attr definition  */
   MEMptr	loc_data_def = NULL;	/* MEMptr buffer loc_data definition  */
   MEMptr	loc_list_def = NULL;	/* MEMptr buffer loc_list definition  */
   MEMptr	cat_attr_def = NULL;	/* MEMptr buffer cat_attr definition  */
   MEMptr	cat_data_def = NULL;	/* MEMptr buffer cat_data definition  */
   MEMptr	cat_list_def = NULL;	/* MEMptr buffer cat_list definition  */
   MEMptr	loc_attr_sav = NULL;	/* MEMptr buffer loc_attr saved       */
   MEMptr	loc_data_sav = NULL;	/* MEMptr buffer loc_data saved       */
   MEMptr	loc_list_sav = NULL;	/* MEMptr buffer loc_list saved       */
   MEMptr	cat_attr_sav = NULL;	/* MEMptr buffer cat_attr saved       */
   MEMptr	cat_data_sav = NULL;	/* MEMptr buffer cat_data saved       */
   MEMptr	cat_list_sav = NULL;	/* MEMptr buffer cat_list saved       */

   VDSdebug ("ENTER: VDScreate_catalogs\n");

   /* ascii family file --> MEMptr buffer */
   VDSprintDbgMsg ("   Creating buffers from family files\n");
   VDSstatus = VDSascii_to_buffer ( VDS_FAM_TEMP_FILE, &buffer_in);
   if ( VDSstatus != VDS_S_SUCCESS) {
     VDSprintVdsErr( "\t", "VDSascii_to_buffer", VDSstatus );
     goto quit1;
     }

   /*** Get the default buffers for creating the catalogs and adding data ***/
   /*** The default values are also obtained.				  ***/
   VDSprintDbgMsg ("   Creating buffers using default values\n"); 
   VDSstatus = VDSdefault_buffer ( &loc_attr_sav, 
	      			   &loc_data_sav,
	      			   &loc_list_sav,
	      			   &cat_attr_sav,
	      			   &cat_data_sav,
	      			   &cat_list_sav );
   if ( VDSstatus != VDS_S_SUCCESS) {
      VDSprintVdsErr( "\t", "VDSdefault_buffer", VDSstatus );
      goto quit;
      }

   /* Read buffer 
    *	loop over catalogs
    */
   while ( VDSreset_buffer( buffer_in, &buff_no)) {

      VDSstatus = VDSread_in_buffer ( buffer_in, 
				      VDS_NFM_CATALOG_NAME, 
                                      0,
				      format, 
				      value );
      if ( VDSstatus != VDS_S_SUCCESS) {
         VDSprintVdsErr( "\t", "VDSread_in_buffer", VDSstatus );
         goto quit;
         }

#   ifdef TRACE
      else
        {
         printf ( "name : <%s>, format : <%s>, value : <%s>\n",
                   VDS_NFM_CATALOG_NAME, format, value);
    	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
        MEMprint_array ( "CATALOG", buffer_in, VDS_DEBUG_FILE);
        }
#    endif

      /* Inform user processing has starting on new catalog */
      VDSprintUsrMsg ("   Creating family: <%s>\n", value); 
	

      /* Check if catalog already exists */
      VDSstatus = VDSverify_catalog( value );
      if ( VDSstatus == VDS_S_SUCCESS || VDSstatus == VDS_E_CATALOG_EXISTS) {
	 VDSstatus = VDS_S_SUCCESS;
	 VDSprintUsrMsg ("\tfamily <%s> already exists\n", value);
	 continue;
         }

      /** Add the PDM library part to PDMLIBRARIES	**
       * 	function already writes user message
       */
      VDSstatus = VDSadd_part ( buffer_in );
      if ( VDSstatus == VDS_E_PART_EXISTS)
         VDSdebug ( "VDSadd_part, VDS_E_PART_EXISTS\n");
      else if ( VDSstatus != VDS_S_SUCCESS) {
         VDSprintVdsErr( "\t", "VDSadd_part", VDSstatus );
         goto quit;
         }

      VDSprintDbgMsg ("\t... Preparing buffers\n");
      loc_attr_def = NULL;
      if ( loc_attr_sav != NULL) {
         MEMstatus = MEMsplit_copy_buffer ( loc_attr_sav, &loc_attr_def, 0);
         if ( MEMstatus != MEM_S_SUCCESS) {
            VDSstatus = VDS_E_COPY_BUFFER;
            VDSprintMemErr( "\t", "MEMsplit_copy_buffer", MEMstatus, VDSstatus);
            goto quit;
           }
        }

      loc_data_def = NULL;
      if ( loc_data_sav != NULL) {
         MEMstatus = MEMsplit_copy_buffer ( loc_data_sav, &loc_data_def, 0);
         if ( MEMstatus != MEM_S_SUCCESS) {
            VDSstatus = VDS_E_COPY_BUFFER;
            VDSprintMemErr( "\t", "MEMsplit_copy_buffer", MEMstatus, VDSstatus);
            goto quit;
           }
        }

      loc_list_def = NULL;
      if ( loc_list_sav != NULL) {
         MEMstatus = MEMsplit_copy_buffer ( loc_list_sav, &loc_list_def, 0);
         if ( MEMstatus != MEM_S_SUCCESS) {
            VDSstatus = VDS_E_COPY_BUFFER;
            VDSprintMemErr( "\t", "MEMsplit_copy_buffer", MEMstatus, VDSstatus);
            goto quit;
           }
        }

      cat_attr_def = NULL;
      if ( cat_attr_sav != NULL) {
         MEMstatus = MEMsplit_copy_buffer ( cat_attr_sav, &cat_attr_def, 0);
         if ( MEMstatus != MEM_S_SUCCESS) {
            VDSstatus = VDS_E_COPY_BUFFER;
            VDSprintMemErr( "\t", "MEMsplit_copy_buffer", MEMstatus, VDSstatus);
            goto quit;
           }
        }

      cat_data_def = NULL;
      if ( cat_data_sav != NULL) {
         MEMstatus = MEMsplit_copy_buffer ( cat_data_sav, &cat_data_def, 0);
         if ( MEMstatus != MEM_S_SUCCESS) {
            VDSstatus = VDS_E_COPY_BUFFER;
            VDSprintMemErr( "\t", "MEMsplit_copy_buffer", MEMstatus, VDSstatus);
            goto quit;
           }
        }

      cat_list_def = NULL;
      if ( cat_list_sav != NULL) {
         MEMstatus = MEMsplit_copy_buffer ( cat_list_sav, &cat_list_def, 0);
         if ( MEMstatus != MEM_S_SUCCESS) {
            VDSstatus = VDS_E_COPY_BUFFER;
            VDSprintMemErr( "\t", "MEMsplit_copy_buffer", MEMstatus, VDSstatus);
            goto quit;
           }
        }

      /** Creation of the family with default buffers and the input buffer **/

      VDSstatus = VDSadd_family ( buffer_in, 
				  loc_attr_def,
				  loc_data_def,
				  loc_list_def,
				  cat_attr_def,
				  cat_data_def,
				  cat_list_def );

     } /* end reading buffer */

quit :

   status = VDSclose_buffers ( &loc_attr_def, &loc_data_def, &loc_list_def);
   if ( status != VDS_S_SUCCESS) {
      VDSprintVdsErr( "\t", "VDSclose_buffers", VDSstatus );
      }

   status = VDSclose_buffers ( &loc_attr_sav, &loc_data_sav, &loc_list_sav);
   if ( status != VDS_S_SUCCESS) {
      VDSprintVdsErr( "\t", "VDSclose_buffers", VDSstatus );
      }

   status = VDSclose_buffers ( &cat_attr_def, &cat_data_def, &cat_list_def);
   if ( status != VDS_S_SUCCESS) {
      VDSprintVdsErr( "\t", "VDSclose_buffers", VDSstatus );
      }

   status = VDSclose_buffers ( &cat_attr_sav, &cat_data_sav, &cat_list_sav);
   if ( status != VDS_S_SUCCESS) {
      VDSprintVdsErr( "\t", "VDSclose_buffers", VDSstatus );
      }

quit1:
   MEMstatus = MEMclose ( &buffer_in);
   if ( MEMstatus !=  MEM_S_SUCCESS) {
      VDSstatus = VDS_E_CLOSE_BUFFER; 
      VDSprintMemErr( "\t", "MEMclose", MEMstatus, VDSstatus);
      }

   VDSdebug ("EXIT: VDScreate_catalogs\n");

   /* print End of family generation message */
   if (VDSstatus == VDS_S_SUCCESS) {
	VDSdebug( "SUCCESSFUL CREATION OF CATALOGS\n");
	return TRUE;
   	}
   else {
	VDSdebug("UNSUCCESSFUL CATALOG CREATION\n");
	return FALSE;
   	}
}
