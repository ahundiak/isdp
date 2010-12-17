#include <stdio.h>
#include <errno.h>
#include <MEMstruct.h>
#include <PDUerror.h>
#include <MEMerrordef.h>
#include <sys/types.h>
#include <sys/stat.h>

extern int PDMdebug_on;
extern char PDM_DEBUG_FILE[];


int PDMfile_to_tmp_bufr (data_buffer, format_filename, data_filename)
  char		*format_filename, *data_filename;
  MEMptr	*data_buffer;
  {
      char *fname = "PDMfile_to_tmp_bufr";
      long status = PDM_S_SUCCESS;
      FILE	*infile = NULL, *data_infile = NULL, *fopen ();
      char	ss[1024] ;
      char	*col_name = NULL, *col_type = NULL;
      MEMptr	tmp_bufr = NULL;
      int		no_fields;
      int		found, no_buf, done;
      int		i, k;
      int		nx1;
      char	**column;
      char      sz[2048],tmp_bufr_string[4096];
      char    *fields[50];
      char    *field_names[50];

/*  Open the .data file  */

   _PDMdebug(fname, "ENTER:\n");
   if ((infile = fopen (format_filename, "r")) == NULL)
   {
       _PDMdebug(fname,"fopen failed status %d: \n", errno);
        *data_buffer = NULL;
	status = PDM_E_OPEN_FILE;
	return (status);
   }
   if ((data_infile = fopen (data_filename, "r")) == NULL)
   {
       _PDMdebug(fname,"fopen failed status %d: \n", errno);
        *data_buffer = NULL;
	status = PDM_E_OPEN_FILE;
	return (status);
   }
   ss[0] = '\0';
  fgets (ss, 2, infile);
    no_buf = atoi(ss);

   _PDMdebug(fname, "no_buf %d:\n", no_buf);

   for(i = 0; i < no_buf; i++)
   {
  
    status = MEMopen(&tmp_bufr);
    if(status != MEM_S_SUCCESS)
    {
	_PDMdebug(fname, "MEMbuild_array failed status = %d",status);
	fclose (infile);
	status = PDM_E_BUILD_ARRAY;
	return (status);
   }
   done = 1;
  while (done)
  {
   ss[0] = '\0';
   fgets (ss, 1024, infile);
   _PDMdebug (fname, "string <%s>\n",ss);
   if(ss[0] != '~')
    {
    /*  Check for comment in file  */
    if (!strcmp(ss,"")) continue;
    else if ((ss[0] == '#') || (ss[0] == '\n') || (ss[0] == ' ')) continue;
    else if ((ss[0] == '@') ) break;
    if ((col_name = (char *) strtok (ss, "|")) == NULL)
    {
	_PDMdebug(fname, "Col name in unrecognized format \n");
	_PDMdebug (fname, "File in unrecognized format <%s>\n",ss);
	MEMclose(&tmp_bufr);
	status = PDM_E_FILE_FORMAT;
	fclose (infile);
	return (status);
    }
    if ((col_type = (char *) strtok (NULL, "|\n")) == NULL)
    {
	_PDMdebug(fname, "Col type in unrecognized format \n");
	_PDMdebug (fname, "File in unrecognized format <%s>\n",ss);
		MEMclose(&tmp_bufr);
		status = PDM_E_FILE_FORMAT;
		fclose (infile);
		return (status);
    }

    if(strlen(col_name) && strlen(col_type))
    {
       status = MEMwrite_format(tmp_bufr,col_name,col_type);
       if(status != MEM_S_SUCCESS)
       {
         _PDMdebug(fname,"MEMwrite_format failed status = %d",status);
   	fclose (infile);
        MEMclose(&tmp_bufr);
    	status = PDM_E_WRITE_FORMAT;
       	return (status);
       }
     }
   }
  }
   if(PDMdebug_on)
   		MEMprint_buffer("empty tmp_bufr",tmp_bufr,PDM_DEBUG_FILE);
   status = MEMbuild_array(tmp_bufr);
   if(status != MEM_S_SUCCESS)
   {
       _PDMdebug (fname, "MEMbuild_array failed : %d",status);
	status = PDM_E_BUILD_ARRAY;
	return (status);
   }
   column = (char **) tmp_bufr->column_ptr;

 /* read the file until no more data . there are "no_fields" fields
    in each row in this type of files */

   if(fgets (sz, 1024, data_infile) == NULL)
    {
   		_PDMdebug(fname,"empty open buffer\n");
			fclose (infile);
			fclose (data_infile);
			return (PDM_S_SUCCESS);
    }
   if(sz[0] == '^')
    {
   		_PDMdebug(fname,"empty open buffer\n");
			fclose (infile);
			fclose (data_infile);
			return (PDM_S_SUCCESS);
    }
   while((sz[0] == '#') || (sz[0] == '\n')) 
   {
	   fgets (sz, 1024, data_infile);
   }
   		_PDMdebug(fname,"Out of the wait loop\n");
   if ((field_names[0] = (char *) strtok (sz, "|")) == NULL)
   {
        if(sz[0] == '#')
         {
   		_PDMdebug(fname,"empty open buffer\n");
			fclose (infile);
			fclose (data_infile);
			return (PDM_S_SUCCESS);
          }
   		_PDMdebug(fname,"File in unrecognized format\n");
   		status = PDM_E_FILE_FORMAT;
   		fclose (infile);
   		fclose (data_infile);
   		return (status);
   }

   no_fields = 1;

   while((field_names[no_fields] = (char *) strtok (NULL, "|\n")) != NULL)
   {
		no_fields  = no_fields + 1 ;
   }

  
   		_PDMdebug(fname,"No of fields %d\n", no_fields);
   /* Check if the field names tally with columns in tmp_bufr */

   for(i=0;i<no_fields;i++)
   {
		found = 0;
		for(k=0;k<tmp_bufr->columns;k++)
		{
			if(!strcmp(column[k],field_names[i]))
			{
				found = 1; break;
			}

		}	
		if(!found)
		{
	         _PDMdebug(fname, "Field Name -> %s in File -> %s is Illegal\n",
			field_names[i],data_filename);	
	   		status = PDM_E_FILE_FORMAT;
	   		fclose (infile);
	   		fclose (data_infile);
	   		return (status);			
		}	
   }

   while (fgets (ss, 1024, data_infile))
   {
	/*  Check for comment in file  */
	_PDMdebug(fname, "<%s>\n", ss);

     if ((ss[0] == '#') || (ss[0] == '\n')) continue;
     if((ss[0] == '@')) break;

     if ((fields[0] = (char *) strtok (ss, "|")) == NULL)
     {
	   		_PDMdebug(fname, "File in unrecognized format\n");
	   		status = PDM_E_FILE_FORMAT;
	   		fclose (infile);
	   		fclose (data_infile);
	   		return (status);
     }

     for(i=1;i<no_fields-1;i++)
     {
		if ((fields[i] = (char *) strtok (NULL, "|")) == NULL)
		{
  	  		_PDMdebug(fname,"File in unrecognized format2\n");
  	  		_PDMdebug(fname," no_fields i%d\n", i);
  	  		_PDMdebug(fname," no_fields %d\n", no_fields);
  	  		status = PDM_E_FILE_FORMAT;
   	  		fclose (infile);
   	  		fclose (data_infile);
   	  		return (status);
        }
     }
     if(no_fields != 1)
     {
     if ((fields[no_fields-1] = (char *) strtok (NULL, "|\n")) == NULL)
       {
                if(no_fields != 1)
                       {
  	  		_PDMdebug(fname,"File in unrecognized format3\n");
  	  		_PDMdebug(fname," no_fileds %d\n", no_fields);
			status = PDM_E_FILE_FORMAT;
			fclose (infile);
			fclose (data_infile);
			return (status);
                        }
        }
      }

     /* write a row in tmp_bufr  */

     tmp_bufr_string[0] = '\0';

     for (i = 0; i < tmp_bufr->columns; ++i)
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
          if(strcmp(fields[nx1],"~"))
           strcat (tmp_bufr_string, fields[nx1]);
        }
	strcat(tmp_bufr_string,"\1");
     }
     status = MEMwrite (tmp_bufr, tmp_bufr_string);
     if (status != MEM_S_SUCCESS)
     {
		_PDMdebug(fname,"MEMwrite failed status = %d\n",status);
		fclose (infile);
		fclose (data_infile);
		status = PDM_E_WRITE_ROW;
		return (status);
     }
     status = MEMbuild_array (tmp_bufr);
     if (status  != MEM_S_SUCCESS)
     {
	_PDMdebug(fname,"MEMbuild_array failed status = %d\n",status);
	fclose (infile);
	fclose (data_infile);
	return (PDM_E_BUILD_ARRAY);
     }
     column = (char **) tmp_bufr->column_ptr;
    }   /* end of while */
       done = 0;
  if (*data_buffer == NULL) 
    {
    status = MEMsplit_copy_buffer(tmp_bufr, data_buffer, 0);
     if (status  != MEM_S_SUCCESS)
     {
	_PDMdebug(fname,"MEMsplit_copy_buffer failed status = %d\n",status);
	fclose (infile);
	fclose (data_infile);
	return (status);
     }
    }
  else
    {
    status = MEMappend(&data_buffer, tmp_bufr);
     if (status  != MEM_S_SUCCESS)
     {
	_PDMdebug(fname,"MEMappend failed status = %d\n",status);
	fclose (infile);
	fclose (data_infile);
	return (status);
     }
     }
     MEMclose(&tmp_bufr);

     continue;
   }
   if(PDMdebug_on)
   {
   		MEMprint_buffer("bufr",*data_buffer,PDM_DEBUG_FILE);
   }
  fclose (infile);
  fclose (data_infile);
  _PDMdebug(fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}


int PDUsave_format_to_file()
{

  int     status = PDM_S_SUCCESS;
  char    path[512];
  FILE    *outfile, *fopen ();
  char    *msg_str = NULL;

  _pdm_debug("in the function PDUsave_format_to_file", 0);

  strcpy(path, "/usr/tmp/format.dat");
  _pdm_debug("file path = <%s>", path);

  if ((outfile = fopen (path, "w")) == NULL)
    {
          _pdm_debug ("api_ckin: error opening <%s>", path);
          _pdm_debug ("api_ckin: errno = <%d>", (char *)errno);
          return(PDM_E_OPEN_FILE);
    }

  msg_str = (char *) PDUtranslate_message(PDM_E_FILE_NOT_PDU);
  status = PDUwrite_refresh_file (msg_str, outfile);
  if (status != PDM_S_SUCCESS)
    {
          _pdm_debug("error writing to format.dat", 0);
          fclose (outfile);
          return(status);
    }

  _pdm_debug("Closing ascii file and returning SUCCESS", 0);
  fclose (outfile);
  return (PDM_S_SUCCESS);
}

int PDUread_format_from_file(file_format)
  char **file_format;
{

  int     status = PDM_S_SUCCESS;
  char    path[512];
  FILE    *infile, *fopen ();
  struct  stat buf;

  _pdm_debug("in the function PDUread_format_from_file", 0);

  strcpy(path, "/usr/tmp/format.dat");
  _pdm_debug("file path = <%s>", path);

  if (stat (path, &buf))
    {
          _pdm_debug ("PDUread_format_from_file: stat failed; errno = %d",
                       (char *)errno);
          _pdm_debug ("PDUread_format_from_file: returning %d",
                      (char *)PDM_E_OPEN_FILE);
          return (PDM_E_OPEN_FILE);
    }

  if (buf.st_size == 0)
    {
          _pdm_debug ("PDUread_format_from_file: file is empty", 0);

          _pdm_debug ("PDUread_format_from_file: returning %d",
                      (char *)PDM_S_SUCCESS);
          return (PDM_S_SUCCESS);
    }

  if ((infile = fopen (path, "r")) == NULL)
    {
          _pdm_debug ("PDUread_format_from_file: error opening <%s>", path);
          _pdm_debug ("PDUread_format_from_file: errno = <%d>", (char *)errno);
          return (PDM_E_OPEN_FILE);
    }

  status = PDUread_refresh_file (file_format, path, infile);
  if (status != PDM_S_SUCCESS)
    {
          fclose (infile);
          return (status);
    }

  _pdm_debug("Closing ascii file and returning SUCCESS", 0);
  fclose (infile);
  return (PDM_S_SUCCESS);
}
