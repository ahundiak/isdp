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

/* Globals for manipulating column names in attribute buffer */

static  char	s[1024];
static  int		status;

extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		PDMdebug_on;
extern	char    PDM_DEBUG_FILE[];
extern  int		offsets[];
extern  char	*attr_names[];

PDMexec_ptr PDMexec;

/* This function reads filename (.attr type) and writes the data into 
   buffer (attribute buffer of nfmattributes sys). The  attrbs 
   that make up the fields of a row are dynamic. indx is an array into
   global var. attr_names and no_fileds is the no. of. fields per row */

PDMattrfile_to_buffer (filename,buffer)
  char		*filename;
  MEMptr	buffer;
  {
	int		no_fields;
	int		found;
	int		i, k;
	int		nx1;
	char	**column;
	char	ss[1024], sz[1024],buffer_string[4096];
	char    *fields[16];
	char    *field_names[16];
	FILE	*infile, *fopen ();

  /*  Open the attr file  */

   PDMdebug("ENTER:PDMattrfile_to_buffer\n");
   infile = NULL;
   if ((infile = fopen (filename, "r")) == NULL)
   {
		sprintf (s, "Could not open file <%s> \n",filename);
		PDMdebug(s);
		status = PDM_E_OPEN_FILE;
		return (status);
   }
   if(PDMdebug_on)
   {
   		MEMprint_buffer("empty buffer",buffer,PDM_DEBUG_FILE);
   }
   status = MEMbuild_array(buffer);
   if(status != MEM_S_SUCCESS)
   {
		sprintf (s, "MEMbuild_array failed : %d",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		return (status);
   }
   column = (char **) buffer->column_ptr;

 /* read the file until no more data . there are "no_fields" fields
    in each row in this type of files */

   fgets (sz, 1024, infile);
   while((sz[0] == '#') || (sz[0] == '\n')) 
   {
	   fgets (sz, 1024, infile);
   }
   if ((field_names[0] = strtok (sz, "|")) == NULL)
   {
   		PDMdebug("File in unrecognized format\n");
   		status = PDM_E_FILE_FORMAT;
   		fclose (infile);
   		return (status);
   }

   no_fields = 1;
   while((field_names[no_fields] = strtok (NULL, "|\n")) != NULL)
   {
		no_fields  = no_fields + 1 ;
   }

/*  for(i=0;i<no_fields;i++)
   {
		sprintf(s,"%d -> %s\n",i,field_names[i]);
		PDMdebug(s);
   }
*/
  
   /* Check if the field names tally with 
		NFM columns in buffer */

   for(i=0;i<no_fields;i++)
   {
		found = 0;
		for(k=0;k<buffer->columns;k++)
		{
			if(!strcmp(column[k],field_names[i]))
			{
				found = 1; break;
			}
		}	
		if(!found)
		{
			sprintf(s,
            "Field Name -> %s in File -> %s is Illegal\n",
			field_names[i],filename);	PDMdebug(s);
	   		status = PDM_E_FILE_FORMAT;
	   		fclose (infile);
	   		return (status);			
		}	
   }

   while (fgets (ss, 1024, infile))
   {
		/*  Check for comment in file  */

     if ((ss[0] == '#') || (ss[0] == '\n')) continue;

     if ((fields[0] = strtok (ss, "|")) == NULL)
     {
	   		PDMdebug("File in unrecognized format\n");
	   		status = PDM_E_FILE_FORMAT;
	   		fclose (infile);
	   		return (status);
     }

     for(i=1;i<no_fields-1;i++)
     {
		if ((fields[i] = strtok (NULL, "|")) == NULL)
		{
  	  		PDMdebug("File in unrecognized format\n");
  	  		status = PDM_E_FILE_FORMAT;
   	  		fclose (infile);
   	  		return (status);
        }
     }
     if ((fields[no_fields-1] = strtok (NULL, "|\n")) == NULL)
     {
			PDMdebug("File in unrecognized format\n");
			status = PDM_E_FILE_FORMAT;
			fclose (infile);
			return (status);
     }

/*   for(i=0;i<no_fields;i++)
   {
		sprintf(s,"%d -> %s\n",i,fields[i]);
		PDMdebug(s);
   }
*/
            /* write a row in buffer  */

     strcpy (buffer_string, "");

     for (i = 0; i < buffer->columns; ++i)
     {
	       /* locate which field in file corresponds to column[i] */

	    nx1 = -1;
        for(k=0;k<no_fields;k++)
        {
		   if(!strcmp(column[i],field_names[k]))
           {
 	 	       nx1 = k;
	 	       break;
           }
        }
        if(nx1 != -1)
        {
           strcat (buffer_string, fields[nx1]);
        }
		strcat(buffer_string,"\1");
     }
     status = MEMwrite (buffer, buffer_string);
     if (status != MEM_S_SUCCESS)
     {
		PDMdebug("PDMattrfile_to_buffer \n");
		sprintf(s,"MEMwrite failed status = %d\n",status);
		PDMdebug(s);
		fclose (infile);
		status = PDM_E_WRITE_ROW;
		return (status);
     }
     status = MEMbuild_array (buffer);
     if (status  != MEM_S_SUCCESS)
     {
		PDMdebug("PDMattrfile_to_buffer \n");
		sprintf(s,"MEMbuild_array failed status = %d\n",status);
		PDMdebug(s);
		fclose (infile);
		return (PDM_E_BUILD_ARRAY);
     }
     column = (char **) buffer->column_ptr;
   }   /* end of while */

   if(PDMdebug_on)
   {
   		MEMprint_buffer("buffer",buffer,PDM_DEBUG_FILE);
   }
  fclose (infile);
  PDMdebug("EXIT:PDMattrfile_to_buffer\n");
  return (PDM_S_SUCCESS);
}

/* attr_buffer is used to create data_buffer. each attr_name and datatype
   columns in attr_buffer makeup the data_buffer format. 
   entries in filename is of fixed format. */

PDMdatafile_to_buffer (filename,attr_buffer,data_buffer)
  MEMptr	attr_buffer;
  char		*filename;
  MEMptr	*data_buffer;
  {
	FILE	*infile, *fopen ();
	int		i, j;
    int     nx1, nx2;
	int		rows,cols;
	int     name_offset, dtype_offset;
	char	ss[1024], s[1024] ;
	char    *init_val, *def_val;
	char	**data,**column;
 	char	dummy_row[1024];
	char	*attrname;
	MEMptr	tmp_bufr = NULL;

/*  Open the .data file  */

   PDMdebug("ENTER:PDMdatafile_to_buffer\n");
   if ((infile = fopen (filename, "r")) == NULL)
   {
		sprintf(s,"PDMdatafile_to_buffer: \n");
		PDMdebug(s);
		sprintf (s, "Could not open file <%s> \n",filename);
		PDMdebug(s);
		status = PDM_E_OPEN_FILE;
		return (status);
   }

/* create data_buffer  */

   status = MEMbuild_array(attr_buffer);
   if(status != MEM_S_SUCCESS)
   {
		PDMdebug("PDMdatafile_to_buffer \n");
		sprintf(s,"MEMbuild_array failed status = %d",status);
		PDMdebug(s);
		fclose (infile);
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
       PDMdebug("PDMdatafile_to_buffer \n");
       PDMdebug("Input buffer format is invalid\n");
       status = PDM_E_BUFFER_FORMAT;
       return(status);
   }
   status = MEMopen(&tmp_bufr,2048);
   if(status != MEM_S_SUCCESS)
   {
		PDMdebug("PDMdatafile_to_buffer \n");
		sprintf(s,"MEMopen failed status = %d",status);
		PDMdebug(s);
		fclose (infile);
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
 	  		PDMdebug("PDMdatafile_to_buffer \n");
 	  		sprintf(s,"MEMwrite_format failed status = %d",status);
	  		PDMdebug(s);
   	  		fclose (infile);
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
		PDMdebug("PDMdatafile_to_buffer \n");
		sprintf(s,"MEMwrite failed status = %d",status);
		PDMdebug(s);
        MEMclose(&tmp_bufr);
		fclose (infile);
		status = PDM_E_WRITE_ROW;
		return (status);
    }
    status = MEMwrite(tmp_bufr,dummy_row);
    if(status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMdatafile_to_buffer \n");
		sprintf(s,"MEMwrite failed status = %d",status);
		PDMdebug(s);
        MEMclose(&tmp_bufr);
		fclose (infile);
		status = PDM_E_WRITE_ROW;
		return (status);
    }
    status = MEMbuild_array(tmp_bufr);
    if(status != MEM_S_SUCCESS)
    {
		PDMdebug("PDMdatafile_to_buffer \n");
		sprintf(s,"MEMbuild_array failed status = %d",status);
		PDMdebug(s);
		fclose (infile);
		status = PDM_E_BUILD_ARRAY;
		return (status);
   }
   rows = tmp_bufr->rows;
   cols = tmp_bufr->columns;
   column = (char **) tmp_bufr->column_ptr;

 /* Load tmp_bufr with inital and default values     */

  while (fgets (ss, 1024, infile))
  {
    /*  Check for comment in file  */

    if ((ss[0] == '#') || (ss[0] == '\n')) continue;

    if ((attrname = strtok (ss, "|")) == NULL)
    {
		PDMdebug("PDMdatafile_to_buffer:\n");
		sprintf (s, "File in unrecognized format <%s>\n",ss);
		PDMdebug(s);
		MEMclose(&tmp_bufr);
		status = PDM_E_FILE_FORMAT;
		fclose (infile);
		return (status);
    }
    if ((init_val = strtok (NULL, "|")) == NULL)
    {
		PDMdebug("PDMdatafile_to_buffer:\n");
		sprintf (s, "File in unrecognized format <%s>\n",ss);
		PDMdebug(s);
		MEMclose(&tmp_bufr);
		status = PDM_E_FILE_FORMAT;
		fclose (infile);
		return (status);
    }
    if ((def_val = strtok (NULL, "|\n")) == NULL)
    {
		PDMdebug("PDMdatafile_to_buffer:\n");
		sprintf (s, "File in unrecognized format <%s>\n",ss);
		PDMdebug(s);
		MEMclose(&tmp_bufr);
		status = PDM_E_FILE_FORMAT;
		fclose (infile);
		return (status);
    }

 /* find the column to write the data */
   
    j = -1;
    for (i = 0; i < cols; ++i)
    {
      sprintf (s, "comparing %s with %s\n", attrname, column[i]);
      PDMdebug (s) ;
		if (!strcmp(attrname,column[i]))
 	   {
	 	   j= i ;
	  	   break;
        }
    }
    if(j == -1)
    {
		status = PDM_E_BUFFER_FORMAT;
		PDMdebug("PDMdatafile_to_buffer \n");
		PDMdebug("Data buffer is incorrect\n");
		MEMclose(&tmp_bufr);
		return(status);
    }

/* prepare two rows one for init and one for default */
    if(strlen(init_val))
    {
    	 status = MEMwrite_data(tmp_bufr,init_val,1,j+1);
    	 if(status != MEM_S_SUCCESS)
    	 {
				PDMdebug("PDMdatafile_to_buffer \n");
				sprintf(s,"MEMwrite_data failed status = %d",status);
				PDMdebug(s);
   			   	MEMclose(&tmp_bufr);
				fclose (infile);
				status = PDM_E_WRITE_COLUMN;
				return (status);
    	 }
    }
    if(strlen(def_val))
    {
	   	status = MEMwrite_data(tmp_bufr,def_val,2,j+1);
    	if(status != MEM_S_SUCCESS)
    	{
			PDMdebug("PDMdatafile_to_buffer \n");
			sprintf(s,"MEMwrite_data failed status = %d",status);
			PDMdebug(s);
 		    MEMclose(&tmp_bufr);
			fclose (infile);
			status = PDM_E_WRITE_COLUMN;
 			return (status);
        }
     }
  }  /* end of while */
  fclose (infile);
  *data_buffer = tmp_bufr;
  PDMdebug("EXIT:PDMdatafile_to_buffer\n");
  return (PDM_S_SUCCESS);
}

PDMlistfile_to_buffer (file, list_buffer)
/* to be developed . currently there are no lists to load */
char		*file[];
MEMptr  	*list_buffer;
{
/* ANSI */
file = NULL;
*list_buffer = NULL;
    
	PDMdebug("ENTER:PDMlistfile_to_buffer\n");
	PDMdebug("EXIT:PDMlistfile_to_buffer\n");
    return(PDM_S_SUCCESS);
}

PDMsub_catalog_attr_names (file_name,indx,no_fields,buffer)
  char		*file_name;
  int		indx[];
  int		no_fields;
  MEMptr	buffer;
  {
	int		i, k;
	int		rows,cols;
	int		nx1;
 	int		which_row;
 	char		ss[1024];
	char		**data;
	char 		**column;
	char		*fields[30];
	FILE		*infile, *fopen ();

	PDMdebug("ENTER:PDMsub_catalog_attr_names\n");
   infile = NULL;
   if ((infile = fopen (file_name, "r")) == NULL)
   {
		PDMdebug("PDMsub_catalog_attr_names:\n ");
		sprintf (s, "Could not open file <%s> \n",file_name);
		PDMdebug(s);
		status = PDM_E_OPEN_FILE;
		return (status);
   }
   status = MEMbuild_array(buffer);
   if(status != MEM_S_SUCCESS)
   {
		PDMdebug("PDMsub_catalog_attr_names:\n ");
		sprintf (s, "MEMbuild_array failed : %d",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		return (status);
   }
   if(PDMdebug_on)
   {
   		MEMprint_buffer("in sub_cat",buffer,PDM_DEBUG_FILE);
   }
   data = (char **)buffer->data_ptr;
   rows = buffer->rows;
   cols = buffer->columns;
   column = (char **) buffer->column_ptr;

 /* read the file until no more data . there are "no_fields" fields
    in each row in this type of files */

   while (fgets (ss, 1024, infile))
   {
	/*  Check for comment in file  */

     if ((ss[0] == '#') || (ss[0] == '\n')) continue;
     if ((fields[0] = strtok (ss, "|")) == NULL)
     {
	   PDMdebug("PDMsub_catalog_attr_names:\n ");
	   PDMdebug("File in unrecognized format\n");
	   status = PDM_E_FILE_FORMAT;
 	   fclose (infile);
  	   return (status);
     }
    /*  printf ("no of fields is %d\n", no_fields) ; */
     for(i=1;i<no_fields-1;i++)
     {
		if ((fields[i] = strtok (NULL, "|")) == NULL)
		{
		   PDMdebug("PDMsub_catalog_attr_names:\n ");
	 	   PDMdebug("File in unrecognized format\n");
	  	   status = PDM_E_FILE_FORMAT;
 	   	   fclose (infile);
  	   	   return (status);
        }
     }
     if ((fields[no_fields-1] = strtok (NULL, "|\n")) == NULL)
     {
			PDMdebug("PDMsub_catalog_attr_names:\n ");
			PDMdebug("File in unrecognized format\n");
			status = PDM_E_FILE_FORMAT;
			fclose (infile);
			return (status);
     }

    /* modify row in buffer with fields[1..no_fields-1]
	         whose n_name == fields[0]  */

     which_row = -1;
     for (i = 0; i < rows; i++)   /* first find matching row */
     {
		nx1 = i * cols;
/* BETH 2/11/92 remove the use of offsets array because it is not set up prior
		to call */
/*        if (!strncmp(fields[0],data[nx1+offsets[indx[0]]],
			strlen(fields[0])))
*/        if (!strncmp(fields[0],data[nx1+indx[0]], strlen(fields[0])))
       	{
				which_row = i;
				break;
		}
      }
     
      /* write fields[1..no_fields-1] in to nx1 th row */
    
      if(which_row != -1)
      {  
			for(k=1;k<=no_fields-1;k++)
 	        {
/* BETH 2/11/92 removed the use of offsets because it is not set up prior
	 to function */
/*   			    status = MEMwrite_data(buffer,fields[k],
								which_row+1,offsets[indx[k]]+1);
*/	    			    status = MEMwrite_data(buffer,fields[k],
						which_row+1,indx[k]+1);
	  		if(status != MEM_S_SUCCESS)
	  	  		{
	       		   PDMdebug("PDMsub_catalog_attr_names:\n ");
   	 	   		   sprintf (s, "MEMwrite_data failed : %d",status);
		   	 	   PDMdebug(s);
		   	 	   status = PDM_E_WRITE_COLUMN;
		   	 	   return (status);
       			}
			}
      }   
      else
      {
           PDMdebug("PDMsub_catalog_attr_names\n");
	   	   sprintf(s,"There is no n_name -> %s in buffer\n",fields[0]);
	   	   PDMdebug(s);
	       status = PDM_E_BUFFER_FORMAT;
	       return(status);	   
       }
  }    /* end of while */
  fclose (infile);
  if(PDMdebug_on)
  {
		MEMprint_buffer("exit sub_cat",buffer,PDM_DEBUG_FILE);
  }
  PDMdebug("EXIT:PDMsub_catalog_attr_names\n");
  return (PDM_S_SUCCESS);
}

void PDMheading()
{

  printf("\n\
      *****************************************************************\n\
      *                                                               *\n\
      *               I/PDM 3 Initialization Program                  *\n\
      *                                                               *\n\
      *****************************************************************\n\
    ") ;

printf("\n \
\tCopyright Intergraph Corporation, 1988, 1989, 1990, 1991, 1992\n\
\tincluding  software  and  its  file formats,  and audio-visual\n\
\tdisplays;  this is the  property of  Intergraph  Corporation;\n\
\tAll  Rights  Reserved.   May  only  be  used  pursuant to  the\n\
\tapplicable  software license agreement;  contains confidential\n\
\tand  proprietary  information of Intergraph and/or other third\n\
\tparties  which is  protected  by  copyright,  trade secret and\n\
\ttrademark law  and  may  not be  provide  or  otherwise  made\n\
\tavailable without prior written authorization;\n\
\n\
\t                 Restricted Rights Legend:\n\
\tUse, duplication or  disclosure  by the  government is subject\n\
\tto  restrictions as set forth in  subdivision  (b) (3) (ii) of\n\
\tthe rights in  technical data and  computer software clause at\n\
\t52.227-7013.\n\
\n\
\tIntergraph Corporation\n\
\tHuntsville, Alabama   35807-0001\n");
sleep (3);
printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
}

int PDMi_query_familyno()
{
 return(PDM_S_SUCCESS);
}
int PDMcheck_for_view()
{
 return(PDM_S_SUCCESS);
}

/*
 * Added By Narm Gadiraju
 * The following routines are required since the location of pdm 
 * is found in ingrconfig file only and does not follow a specific
 * pattern like that of the clix
 * 
 */

#if defined (sco)
int PDMget_substr(const char *mainstr, char *delim, char *searchstr) {
  char buffer[200];
  char *token;

  strcpy (buffer, mainstr);
  token = strtok(buffer, delim);
  while(NULL != token) {
    if (0 != strcmp(token, searchstr)) {
      token = strtok(NULL, delim);
      continue;
    }
    else {
      PDMdebug("PDMget_substr : Success \n");
      return TRUE;
    }
  }
  return FALSE;
}
  
int PDMget_proddir(char *pdm_proddir) 
{
  char *ingrhome;
  FILE *infile;
  char *ingrfile;
  char buf[200];
  char substr[20][200];
  char *tok;
  int counter, i;

  _PDMdebug("Enter : PDMget_proddir() \n");

  /* Get ingrhome */
  ingrhome = (char *)getenv("INGRHOME");
  if (!ingrhome) {
    PDMdebug("INGRHOME is not defined \n");
    return FALSE;
  }
  _PDMdebug("INGRHOME is %s \n", ingrhome);

  /* ingrfile name is ingrhome/ingrconfig */
  ingrfile = (char *)malloc(strlen(ingrhome)+1+strlen("ingrconfig")+1);
  if (!ingrfile) {
    _PDMdebug("malloc for ingrfile failed \n");
    return FALSE;
  }
  sprintf (ingrfile, "%s/ingrconfig", ingrhome);
  _PDMdebug("INGRFILE is %s \n", ingrfile);
  
  if ((FILE *)NULL == (infile = fopen(ingrfile, "r"))) {
    PDMdebug("Ingrconfig file could not be opened \n");
    return FALSE;
  }

  while (TRUE) {
    fgets (buf, 200, infile);
    if (feof(infile)) {
      PDMdebug("No PDM entry in config file \n");
      return FALSE;
    }
    if (PDMget_substr(buf, "#", "I_PDM")) 
        break;
  }
  tok = strtok(buf, "#");
  counter = 0;
  while (NULL != tok) {
    strcpy (substr[counter++], tok); 
    tok = strtok(NULL, "#");
  }

  for (i=0; i<=counter;i++) {
    if (PDMget_substr(substr[i], "/", "pdm")) {
      PDMdebug("The PDM path is %s \n", substr[i]);
      strcpy (pdm_proddir, substr[i]); 
      return TRUE;
    }
  }

  PDMdebug("The I_PDM path does not has pdm dir\n");
  return FALSE;
}
#endif
