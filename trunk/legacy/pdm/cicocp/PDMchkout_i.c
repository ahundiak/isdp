#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"PDMproto.h"

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
/* APOGEE START static 		long		RIScode; APOGEE END */
static 		long		status;
static 		int		curbuf_no;
static 		char		s[1024];


/* This function takes an item as input moves its
   file(s) from the requester to server */

int PDMcomplete_item_checkout(PDMexec)
PDMexec_ptr	PDMexec;
{
	char		n_setindicator[3];
/* APOGEE START char		n_status[3]; APOGEE END */
	char		**strg_data;
	int			n_itemno,n_catalogno;
	MEMptr		strg_bufr = NULL;
	MEMptr		attr_bufr = NULL;
	MEMptr		data_bufr = NULL;

   PDMdebug("ENTER:PDMcomplete_item_checkout:\n");

   /* check if part exists */

   status = PDMstop_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
                sprintf(s,
           "PDMstop_transaction failed status %d\n",status);
   }
   status = PDMverify_part(PDMexec->catalog,PDMexec->part_num,
						   PDMexec->revision);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"PDMverify_part failed status %d\n",status);
		PDMdebug(s);
		return(status);
   }
   status = PDMquery_catalog_partnos(PDMexec->catalog,
									 PDMexec->part_num,
									 PDMexec->revision,
									&n_catalogno,&n_itemno);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"%s %d\n",
		"PDMquery_catalog_partnos failed ",status);
		PDMdebug(s);
		return(status);
   }

   /* pull out file_bufr,strg_bufr from input */

   status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s,"MEMreset_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
   }
   status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&attr_bufr,0);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s,
		"MEMcopy_split_copy_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
   }
   status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);    
		sprintf(s,"MEMreset_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
   }
   status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&data_bufr,0);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);    
		sprintf(s,"MEMcopy_split_copy_buffer failed : status %d\n",
			status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
   }
   status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);  MEMclose(&data_bufr);
		sprintf(s,"MEMreset_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
   }
   status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&strg_bufr,0);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);   MEMclose(&data_bufr);
		sprintf(s,"MEMcopy_split_copy_buffer failed : status %d\n",
			status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
   }
   status = MEMbuild_array(strg_bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);
		MEMclose(&data_bufr);
		MEMclose(&strg_bufr);
		sprintf(s," %s %s %d",
		"MEMbuild_array "," failed status -> ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   strg_data = (char **) strg_bufr->data_ptr;

   if(PDMdebug_on)
   {
		MEMprint_buffer("attr_bufr",attr_bufr,PDM_DEBUG_FILE);
		MEMprint_buffer("data_bufr",data_bufr,PDM_DEBUG_FILE);
		MEMprint_buffer("strg_bufr",strg_bufr,PDM_DEBUG_FILE);
   }

   n_setindicator[0] = '\0';
   status = PDMquery_assembly_ind(PDMexec->catalog,
				  PDMexec->part_num,
				  PDMexec->revision,n_setindicator);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);
		MEMclose(&data_bufr);
		MEMclose(&strg_bufr);
		sprintf(s,"%s %d\n",
		"PDMquery_assembly_ind failed ",status);
		PDMdebug(s);
		return(status);
   }
   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
                sprintf(s,
           "PDMstop_transaction failed status %d\n",status);
   }
	
/* 10/23/95 - MJG - TR 139424087 DM Manager */
   if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"A",1))
   {

	   	/* check if the part is already checked in */

     status = NFMcheck_item(PDMexec->user_id,PDMexec->catalog,
						n_itemno,NFM_SET_OUT);
     if(status != NFM_S_SUCCESS)
     {
		MEMclose(&attr_bufr);
		MEMclose(&data_bufr);
		MEMclose(&strg_bufr);
		sprintf(s,"NFMcheck_item failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("Part can not be checked in\n");
		return(PDM_E_FAILURE);
     }

     status = NFMcomplete_set_checkout(PDMexec->user_id,
					  strg_data[0],strg_data[1],
					  strg_data[2],strg_data[3],
		  			  strg_data[4],
					  attr_bufr,data_bufr);
     if(status != NFM_S_SUCCESS)
     {
		MEMclose(&strg_bufr);
		MEMclose(&attr_bufr); MEMclose(&data_bufr);
		sprintf(s," %s %d\n",
		"NFMcomplete_set_checkout failed status -> ",status);
		PDMdebug(s);
		return(PDM_E_COMPLETE_SET_CHECKOUT);
     }    
   }
   else   /* if not a set */
   {
     status = NFMcheck_item(PDMexec->user_id,
							PDMexec->catalog,
					        n_itemno,NFM_ITEM_IN);
     if(status != NFM_S_SUCCESS)
	 {
		MEMclose(&strg_bufr);
		PDMdebug("Part can not be checked in\n");
		sprintf(s,"NFMcheck_item failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_FAILURE);
	 }

     status = NFMcomplete_item_checkout(PDMexec->user_id,
					  strg_data[0],strg_data[1],
					  strg_data[2],strg_data[3],
		  			  strg_data[4],
					  attr_bufr,data_bufr);
     if(status != NFM_S_SUCCESS)
     {
        MEMclose(&strg_bufr);
		MEMclose(&attr_bufr); MEMclose(&data_bufr);
		sprintf(s," %s %d\n",
		"NFMcomplete_item_checkout failed status -> ",status);
		PDMdebug(s);
		return(PDM_E_COMPLETE_PART_CHECKOUT);
     }    
   }
   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
                sprintf(s,
           "PDMstop_transaction failed status %d\n",status);
   }
   MEMclose(&data_bufr);
   MEMclose(&strg_bufr);
   PDMdebug("EXIT:PDMcomplete_item_checkout\n");
   return(PDM_S_SUCCESS);
}

int PDMprepare_item_checkout(PDMexec)
PDMexec_ptr	PDMexec;
{
	char		n_setindicator[3];
/* APOGEE START char		n_status[3]; APOGEE END */
	int			n_itemno,n_catalogno;
	MEMptr		attr_bufr = NULL;
	MEMptr		data_bufr = NULL;

   PDMdebug("ENTER:PDMprepare_item_checkout:\n");

   status = PDMstop_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
                sprintf(s,
           "PDMstop_transaction failed status %d\n",status);
   }
   /* check if part exists */

   status = PDMverify_part(PDMexec->catalog,
						   PDMexec->part_num,
						   PDMexec->revision);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"PDMverify_part failed status %d\n",status);
		PDMdebug(s);
		return(status);
   }
   status = PDMquery_catalog_partnos(PDMexec->catalog,
									 PDMexec->part_num,
									 PDMexec->revision,
									&n_catalogno,&n_itemno);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"%s %d\n",
		"PDMquery_catalog_partnos failed ",status);
		PDMdebug(s);
		return(status);
   }

   n_setindicator[0] = '\0';
   status = PDMquery_assembly_ind(PDMexec->catalog,
				  PDMexec->part_num,
				  PDMexec->revision,n_setindicator);
   if(status != PDM_S_SUCCESS)
   {
		sprintf(s,"%s %d\n",
		"PDMquery_assembly_ind failed ",status);
		PDMdebug(s);
		return(status);
   }
   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
                sprintf(s,
           "PDMstop_transaction failed status %d\n",status);
   }
	
/* 10/23/95 - MJG - TR 139424087 DM Manager */
   if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"A",1))
   {

	   	/* check if the part is already checked in */

     status = NFMcheck_item(PDMexec->user_id,PDMexec->catalog,
						n_itemno,NFM_SET_IN);
     if(status != NFM_S_SUCCESS)
     {
		sprintf(s,"NFMcheck_item failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("Part can not be checked in\n");
		return(PDM_E_FAILURE);
     }

     status = NFMprepare_set_checkout(PDMexec->user_id,
									 PDMexec->catalog,
									 PDMexec->part_num,
									 PDMexec->revision,
									 PDMexec->operation,
									 &attr_bufr,&data_bufr);
     if(status != NFM_S_SUCCESS)
     {
		sprintf(s," %s %d\n",
		" NFMprepare_set_checkout failed status -> ",status);
		PDMdebug(s);
		if(status ==  NFM_E_ITEM_IN)
		{
			PDMdebug("Part in checked-in status\n");
			return(PDM_E_PART_CHECKEDIN);
		}
		else if(status == NFM_E_NOT_CO_USER)
		{
			PDMdebug("User not checked-out user\n");
			return(PDM_E_NOT_CO_USER);
		}
		else
		{
			return(PDM_E_PREPARE_PART_CHECKOUT);
		}
     }
   }
   else   /* if not a set */
   {
     status = NFMcheck_item(PDMexec->user_id,
							PDMexec->catalog,
					        n_itemno,NFM_ITEM_IN);
     if(status != NFM_S_SUCCESS)
	 {
		PDMdebug("Part can not be checked in\n");
		sprintf(s,"NFMcheck_item failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_FAILURE);
	 }

	   /* prepare and complete NFMcheckin */

     status = NFMprepare_item_checkout(PDMexec->user_id,
									 PDMexec->catalog,
									 PDMexec->part_num,
									 PDMexec->revision,
									 &attr_bufr,&data_bufr);
     if(status != NFM_S_SUCCESS)
     {
		sprintf(s," %s %d\n",
		" NFMprepare_item_checkout failed status -> ",status);
		PDMdebug(s);
		if(status == NFM_E_ITEM_IN)
		{
			PDMdebug("Part in checked-in status\n");
			return(PDM_E_PART_CHECKEDIN);
		}
		else if(status == NFM_E_NOT_CO_USER)
		{
			PDMdebug("User not checked-out user\n");
			return(PDM_E_NOT_CO_USER);
		}
		else
		{
			return(PDM_E_PREPARE_PART_CHECKOUT);
		}
     }
   }
   status = MEMappend(data_bufr,attr_bufr);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s,"MEMappend failed status %d\n",status);
		PDMdebug(s);MEMclose(&attr_bufr); MEMclose(&data_bufr);
		return(PDM_E_APPEND_BUFFER);
   }
   PDMexec->return_buffer = attr_bufr;
   MEMclose(&data_bufr);
   PDMdebug("EXIT:PDMprepare_item_checkout\n");
   return(PDM_S_SUCCESS);
}

int PDMcancel_item_checkout(PDMexec)
PDMexec_ptr	PDMexec;
{
	char		n_setindicator[3];
/* APOGEE START char		n_status[3]; APOGEE END */
	int			n_itemno,n_catalogno;
	MEMptr		attr_bufr = NULL;
	MEMptr		data_bufr = NULL;

   PDMdebug("ENTER:PDMcancel_item_checkout\n");

   status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
   if(status != MEM_S_SUCCESS)
   {
		return(PDM_E_RESET_BUFFER);
   }
   status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&attr_bufr,0);
   if(status != MEM_S_SUCCESS)
   {
		return(PDM_E_COPY_BUFFER);
   }
   status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);
		return(PDM_E_RESET_BUFFER);
   }
   status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&data_bufr,0);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&attr_bufr);
		return(PDM_E_COPY_BUFFER);
   }

   /* check if part exists */

   status = PDMverify_part(PDMexec->catalog,
						   PDMexec->part_num,
						   PDMexec->revision);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&attr_bufr); MEMclose(&data_bufr);
		sprintf(s,"PDMverify_part failed status %d\n",status);
		PDMdebug(s);
		return(status);
   }
   status = PDMquery_catalog_partnos(PDMexec->catalog,
									 PDMexec->part_num,
									 PDMexec->revision,
									&n_catalogno,&n_itemno);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&attr_bufr); MEMclose(&data_bufr);
		sprintf(s,"%s %d\n",
		"PDMquery_catalog_partnos failed ",status);
		PDMdebug(s);
		return(status);
   }

   n_setindicator[0] = '\0';
   status = PDMquery_assembly_ind(PDMexec->catalog,
				  PDMexec->part_num,
				  PDMexec->revision,n_setindicator);
   if(status != PDM_S_SUCCESS)
   {
		MEMclose(&attr_bufr); MEMclose(&data_bufr);
		sprintf(s,"%s %d\n",
		"PDMquery_assembly_ind failed ",status);
		PDMdebug(s);
		return(status);
   }
	
/* 10/23/95 - MJG - TR 139424087 DM Manager */
   if(!strncmp(n_setindicator,"Y",1) || !strncmp(n_setindicator,"A",1))
   {

	   	/* check if the part is already checked in */

/*     status = NFMcheck_item(PDMexec->user_id,PDMexec->catalog,
						n_itemno,NFM_SET_IN);
     if(status != NFM_S_SUCCESS)
     {
		sprintf(s,"NFMcheck_item failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("Part can not be checked in\n");
		return(PDM_E_FAILURE);
     }
*/
	   /* CANCEL NFMcheckout */

     status = NFMcancel_set_checkout(PDMexec->user_id,
									 attr_bufr,data_bufr);
     if(status != NFM_S_SUCCESS)
     {
		MEMclose(&attr_bufr); MEMclose(&data_bufr);
		sprintf(s," %s %d\n",
		" NFMcancel_set_checkin failed status -> ",status);
		PDMdebug(s);
		if(status == NFM_E_ITEM_IN)
		{
			PDMdebug("Part in checked-in status\n");
			return(PDM_E_PART_CHECKEDIN);
		}
		else if(status == NFM_E_NOT_CO_USER)
		{
			PDMdebug("User not checked-out user\n");
			return(PDM_E_NOT_CO_USER);
		}
		else
		{
			return(PDM_E_PREPARE_SET_CHECKIN);
		}
     }
   }
   else   /* if not a set */
   {
/*     status = NFMcheck_item(PDMexec->user_id,
							PDMexec->catalog,
					        n_itemno,NFM_ITEM_IN);
     if(status != NFM_S_SUCCESS)
	 {
		PDMdebug("Part can not be checked in\n");
		sprintf(s,"NFMcheck_item failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_FAILURE);
	 }
*/

	   /* prepare  NFMcheckin */

     status = NFMcancel_item_checkout(PDMexec->user_id,
									 attr_bufr,data_bufr);
     if(status != NFM_S_SUCCESS)
     {
		MEMclose(&attr_bufr); MEMclose(&data_bufr);
		sprintf(s," %s %d\n",
		" NFMcancel_item_checkin failed status -> ",status);
		PDMdebug(s);
		if(status == NFM_E_ITEM_IN)
		{
			PDMdebug("Part in checked-in status\n");
			return(PDM_E_PART_CHECKEDIN);
		}
		else if(status == NFM_E_NOT_CO_USER)
		{
			PDMdebug("User not checked-out user\n");
			return(PDM_E_NOT_CO_USER);
		}
		else
		{
			return(PDM_E_PREPARE_PART_CHECKIN);
		}
     }
   }
   MEMclose(&attr_bufr);
   MEMclose(&data_bufr);
   PDMdebug("EXIT:PDMcancel_item_checkout\n");
   return(PDM_S_SUCCESS);
}
