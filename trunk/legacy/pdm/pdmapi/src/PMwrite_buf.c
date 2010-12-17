#include <stdio.h>
#include <MEMstruct.h>
#include <PDUerror.h>
#include <MEMerrordef.h>

extern int PDMdebug_on;
extern char PDM_DEBUG_FILE[];

int PDMbuffer_to_file (orig_buffer,format_filename, data_filename)
  MEMptr	orig_buffer;
  char		*format_filename;
  char		*data_filename;
  {
        char    *fname = "PDMbuffer_to_file";
       long status = PDM_S_SUCCESS;
	int     no_buf= 0, cur_buf = 0, i, j, k;
	int		nxi;
	char	**column, **format, **data;
	char	for_data[2048];
        char    *data_data = NULL;
	FILE	*infile, *fopen ();
	FILE	*data_infile;
        MEMptr  buffer = NULL;

      _PDMdebug(fname, "ENTER\n");

   infile = NULL;
   buffer = orig_buffer;
   if(PDMdebug_on)
   {
   		MEMprint_buffer("buffer to be written",buffer,PDM_DEBUG_FILE);
   }
   if ((infile = fopen (format_filename, "w")) == NULL)
   {
       _PDMdebug (fname, "Could not open file <%s> \n",format_filename);
	status = PDM_E_OPEN_FILE;
	return (status);
   }
   if ((data_infile = fopen (data_filename, "w")) == NULL)
   {
       _PDMdebug (fname, "Could not open file <%s> \n",data_filename);
	status = PDM_E_OPEN_FILE;
	return (status);
   }
   if(!buffer)
   {
       _PDMdebug (fname, "MEMbuild_array failed : %d",status);
	   fputs ("0\n", infile);
	   fputs ("####\n", infile);
	   fputs ("^\n", data_infile);
        fclose (infile);
        fclose (data_infile);
	status = PDM_E_BUILD_ARRAY;
	return (status);
    }
   MEMno_buffers(buffer, &no_buf);
   sprintf(for_data, "%d\n", no_buf);
   fputs (for_data, infile);
   fputs ("######\n", infile);
   fputs ("#Attribute|Datatype\n", infile);
   fputs ("######\n", infile);
   fputs ("\n", infile);

   for(k = 0; k < no_buf; k++)
   {
   status = MEMreset_buffer(buffer, &cur_buf);
   if(status != MEM_S_SUCCESS)
   {
       _PDMdebug (fname, "MEMreset_buffer failed : %d",status);
        fclose (infile);
	   fputs ("^\n", data_infile);
        fclose (data_infile);
	status = PDM_E_BUILD_ARRAY;
	return (status);
   }
   if( k != 0)
   {
   sprintf(for_data, "@%d\n", cur_buf);
   fputs (for_data, infile);
   }
   status = MEMbuild_array(buffer);
   if(status != MEM_S_SUCCESS)
   {
       _PDMdebug (fname, "MEMbuild_array failed : %d",status);
	   fputs ("####", infile);
	   fputs ("^\n", data_infile);
        fclose (infile);
        fclose (data_infile);
	status = PDM_E_BUILD_ARRAY;
	return (status);
   }
   column = (char **) buffer->column_ptr;
   format = (char **) buffer->format_ptr;
   data   = (char **) buffer->data_ptr;

   if(buffer->columns == 0)
     {
	   fputs ("^\n", data_infile);
     }
   for(i = 0; i < buffer->columns; i++)
    {
       for_data[0] = '\0';
       sprintf(for_data, "%s|%s\n", column[i], format[i]);
       fputs (for_data, infile);
     }
   for_data[0] = '\0';
   if( k == 0)
   {
   sprintf(for_data, "@%d\n", 1);
   fputs (for_data, infile);
   }
   for_data[0] = '\0';
   if(k != 0)
   {
   sprintf(for_data, "@%d\n", cur_buf);
   fputs (for_data, data_infile);
   }

   for_data[0] = '\0';
   for(i = 0; i < buffer->columns; i++)
    {
       strcat(for_data, column[i]);
       /* if((i+1)  < buffer->columns) strcat(for_data, "|"); */
       strcat(for_data, "|");
    }
     strcat(for_data,"\n");
    fputs (for_data, data_infile);
    data_data = (char *) malloc (buffer->row_size + 2);
   for(i = 0; i < buffer->rows; i++)
     {
      data_data[0] = '\0';
      nxi = i * buffer->columns;
       for(j = 0; j < buffer->columns; j++)
        {
       if(!strcmp(data[nxi+j],""))
        strcat(data_data, "~");
        else
       strcat(data_data, data[nxi+j]);
       /* if((j+1)  < buffer->columns) strcat(data_data, "|"); */
        strcat(data_data, "|");
        }
     strcat(data_data,"\n");
       fputs (data_data, data_infile);
      }
    free(data_data); data_data = NULL;
   }

        fclose (infile);
        fclose (data_infile);
  _PDMdebug(fname, "EXIT:PDMbuffer_to_file\n");
  return (PDM_S_SUCCESS);
}



