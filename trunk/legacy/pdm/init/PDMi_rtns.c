#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#define		TRUE			 1
#define		FALSE			 0

#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "SQLerrordef.h"

#include "PDMmach_id.h"
#include "PDMinit.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "MSGstruct.h"
#include "PDMproto.h"

/* local definitions */

#define	NOT !

/* These are variables for storing the return codes of 
   the four sub-system calls. They can be externed to find the 
   return codes. */

static  int	 status; 
static  char	s[1024];

/* Globals for manipulating column names in attribute buffer */

extern	int	 	offsets[];
extern  char    *attr_names[];
extern  int		no_cols;

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		PDMdebug_on;
extern	char    PDM_DEBUG_FILE[];


PDMinit_init(user_id)
long	user_id;
{
	int		offset;
	int		i,k;
	char		**column;
	MEMptr		attr_buffer = NULL;

 /* set the globals  the no. and the names */

	PDMdebug("ENTER:PDMinit_init\n");
	no_cols = 16;
	for(i=0;i<no_cols;i++)
	{
	   attr_names[i] = (char *) malloc(30 * sizeof(char));
    }
	strcpy(attr_names[0],"n_name");
	strcpy(attr_names[1],"n_datatype");
	strcpy(attr_names[2],"n_synonym");	
	strcpy(attr_names[3],"n_nfmname");	
	strcpy(attr_names[4],"n_opentonfm");	
	strcpy(attr_names[5],"n_application");	
	strcpy(attr_names[6],"n_read");	
	strcpy(attr_names[7],"n_write");	
	strcpy(attr_names[8],"n_update");	
	strcpy(attr_names[9],"n_delete");	
	strcpy(attr_names[10],"n_null");	
	strcpy(attr_names[11],"n_keyin");	
	strcpy(attr_names[12],"n_checkin");	
	strcpy(attr_names[13],"n_checkout");	
	strcpy(attr_names[14],"n_seqno");	
	strcpy(attr_names[15],"n_listno");	

/*  Get def. table attributes from NFM  and set the offsets of
    the above names in this buffer */

     status = NFMquery_table_template (user_id,&attr_buffer);
     if (status != NFM_S_SUCCESS)
     {
			PDMdebug("PDMinit_init:\n");
			sprintf(s,
	 		 "NFMquery_table_template failed; status = %d\n", status);
			PDMdebug(s);
			MEMclose (&attr_buffer);
			for(i=0;i<no_cols;free(attr_names[i]),i++);
			return (PDM_E_QUERY_TABLE_TEMPLATE);
     }
     status = MEMbuild_array (attr_buffer);
     if (status != MEM_S_SUCCESS)
     {
			PDMdebug("PDMinit_init:\n");
			sprintf(s,
		 	"MEMbuild_array failed; status = %d\n", status);
			PDMdebug(s);
			for(i=0;i<no_cols;free(attr_names[i]),i++);
			MEMclose (&attr_buffer);
			return (PDM_E_BUILD_ARRAY);
     }
     column = (char **) attr_buffer->column_ptr;
     for(i=0;i<no_cols;i++)
     {
        offset = -1;
        for(k=0;k<attr_buffer->columns;k++)
        {
		   if(!strcmp(attr_names[i],column[k]))
           {
		 	    offset = i;
	    	    break;
    	   }
        }
        if(offset == -1)
        {
  			 PDMdebug("PDMinit_init:\n");
  			 sprintf("Attribute <%s> not in buffer\n",attr_names[i]);
  			 PDMdebug(s);
		 	 for(k=0;i<no_cols;free(attr_names[k]),k++);
			 if(PDMdebug_on)
			 MEMprint_buffer("attr_buffer from NFMquery_table_template",
			 attr_buffer,PDM_DEBUG_FILE);
			 MEMclose(&attr_buffer);
   			 return(PDM_E_BUFFER_FORMAT);
        }
        else
        {
		     offsets[i] = offset;
        }
     }
	 PDMdebug("EXIT:PDMinit_init\n");
     MEMclose(&attr_buffer);
     return(PDM_S_SUCCESS);
}


PDMiexpand_databuffer(attr_buffer,data_buffer,data1_buffer)
MEMptr		attr_buffer;
MEMptr		data_buffer;
MEMptr		*data1_buffer;
{
 	int		rows;
	int		cols;
	int		data_cols;
	int		i,j;
	int		name_offset;
	int		dtype_offset;
	int		nx1,nx2;
	char		s[300];
	char		dummy_row[1200];
	char		**data_data;
	char		**data_column;
	char		**data;
	char		**column;
	MEMptr		tmp_bufr = NULL;
	
/* create data_buffer  */
   PDMdebug("ENTER:PDMiexpand_databuffer\n");
   status = MEMbuild_array(attr_buffer);
   if(status != MEM_S_SUCCESS)
   {
	PDMdebug("PDMiexpand_databuffr 1 \n");
	sprintf(s,"MEMbuild_array failed status = %d",status);
	PDMdebug(s);
	status = PDM_E_BUILD_ARRAY;
	return (status);
   }

   rows = attr_buffer->rows;
   cols = attr_buffer->columns;
   data = (char **)attr_buffer->data_ptr;
   column = (char **)attr_buffer->column_ptr;
   name_offset = -1;
   dtype_offset = -1;

/* find offsets of n_name and n_datatype in the attr_buffer */

   for(i=0;i<cols;i++)
   {
       if(!strcmp(column[i],"n_name"))
       {
	   name_offset = i;
       }
       if(!strcmp(column[i],"n_datatype"))
       {
	   dtype_offset = i;
       }
       if(name_offset != -1 && dtype_offset != -1)
	   break;
   }
   if(name_offset == -1 || dtype_offset == -1)
   {
       PDMdebug("PDMiexpand_databuffr \n");
       PDMdebug("Input buffer format is invalid\n");
       status = PDM_E_BUFFER_FORMAT;
       return(status);
   }
   status = MEMopen(&tmp_bufr,2048);
   if(status != MEM_S_SUCCESS)
   {
		PDMdebug("PDMiexpand_databuffr \n");
		sprintf(s,"MEMopen failed status = %d",status);
		PDMdebug(s);
		status = PDM_E_OPEN_BUFFER;
		return (status);
   }
   for(i=0;i<rows;i++)
   {
       nx1 = i * cols + name_offset;
       nx2 = i * cols + dtype_offset;
       status = MEMwrite_format(tmp_bufr,data[nx1],data[nx2]);
       if(status != MEM_S_SUCCESS)
       {
		  PDMdebug("PDMiexpand_databuffr \n");
 		  sprintf(s,"MEMwrite_format failed status = %d",status);
	 	  PDMdebug(s);
          MEMclose(&tmp_bufr);
   		  status = PDM_E_WRITE_FORMAT;
          return (status);
       }
   }
   strcpy(dummy_row,"");
   for(i=0;i<rows;i++)
   {
		strcat(dummy_row,"\1");
   }   
   status = MEMwrite(tmp_bufr,dummy_row);
   if(status != MEM_S_SUCCESS)
   {
        PDMdebug("PDMiexpand_databuffr \n");
		sprintf(s,"MEMwrite failed status = %d",status);
		PDMdebug(s);
        MEMclose(&tmp_bufr);
		status = PDM_E_WRITE_COLUMN;
		return (status);
   }
   status = MEMwrite(tmp_bufr,dummy_row);
   if(status != MEM_S_SUCCESS)
   {
        PDMdebug("PDMiexpand_databuffr \n");
		sprintf(s,"MEMwrite failed status = %d",status);
		PDMdebug(s);
        MEMclose(&tmp_bufr);
		status = PDM_E_FAILURE;
		return (status);
   }
   status = MEMbuild_array(tmp_bufr);
   if(status != MEM_S_SUCCESS)
   {
		PDMdebug("PDMiexpand_databuffr 2 \n");
		sprintf(s,"MEMbuild_array failed status = %d",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		return (status);
   }

   rows = tmp_bufr->rows;
   cols = tmp_bufr->columns;
   data = (char **)tmp_bufr->data_ptr;
   column = (char **)tmp_bufr->column_ptr;

   status = MEMbuild_array(data_buffer);
   if(status != MEM_S_SUCCESS)
   {
		PDMdebug("PDMiexpand_databuffr 3\n");
		sprintf(s,"MEMbuild_array failed status = %d",status);
	 	PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		return (status);
   }

   data_cols = data_buffer->columns;
   data_data = (char **)data_buffer->data_ptr;
   data_column = (char **) data_buffer->column_ptr;
   nx1 = 0 * data_cols;
   nx2 = 1 * data_cols;

   /* copy init or def vals if available
 			else */

    for(i=0;i<cols;i++)
    {
      for(j=0;j<data_cols;j++)
      {
        if(!(strcmp(column[i],data_column[j])))
        {
           status = MEMwrite_data(tmp_bufr,data_data[nx1+j],1,i+1);
    	   if(status != MEM_S_SUCCESS)
    	   {
		      PDMdebug("PDMdatafile_to_buffer \n");
 	   	      sprintf(s,"MEMwrite_data failed status = %d",status);
  	 	      PDMdebug(s);
  		      MEMclose(&tmp_bufr);
   		      status = PDM_E_WRITE_COLUMN;
   	 	      return (status);
           }
	   	   break;
        }  /* if */
       }  /* for j = */
   }     /* for i = */
   PDMdebug("EXIT:PDMdatafile_to_buffer\n");
   *data1_buffer = tmp_bufr;
   return(PDM_S_SUCCESS);
}

int	PDMwrite_initlog()
{
	FILE		*fopen(), *fp1;
	char		init_file[200];
	char		cr_time[40];
	char		cr_date[40];

#if defined (sco)
	char *PDM_DIR;
	char pdm_proddir[200];
#endif

#if defined (sco)
        PDMdebug("Create SCO specific PDM_DIR");
	status = PDMget_proddir(pdm_proddir);
        if(status != PDM_S_SUCCESS)
          {
              PDMdebug("PDMget_proddir failed \n");
          }	
        PDM_DIR = (char *)malloc(strlen(pdm_proddir)+1+strlen("config/initial")+
1);
        sprintf(PDM_DIR, "%s%s%s", pdm_proddir, DELIM, "config/initial");
#endif

	PDMdebug("ENTER:PDMwrite_initlog\n");
	sprintf(init_file,"%s%s%s",PDM_DIR,DELIM,"pdm.init");
	cr_date[0] = '\0';
	cr_time[0] = '\0';

	PDMget_date_time(cr_date,cr_time,"/",1);
	fp1 = fopen(init_file,"w");
	if(fp1 == NULL)
	{
		return(PDM_E_FAILURE);
	}
	fprintf(fp1,"I/PDM VERSION : 2.0.0\n");
	fprintf(fp1,"INSTALLED ON : %s :: %s\n",cr_date,cr_time);
	fclose(fp1);
	PDMdebug("EXIT:PDMwrite_initlog\n");
	return(PDM_S_SUCCESS);
}
