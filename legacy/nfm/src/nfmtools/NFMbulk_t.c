#include "machine.h"
#include <stdio.h>
#include "DEBUG.h"

/* 12/8/92 - KT - remove 'ifdef __unix__'
#ifdef __unix__
#endif
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <ftw.h>
#include <string.h>

/* 12/8/92 - KT - remove 'ifdef __unix__'
#ifdef __unix__
#endif
*/
      DIR       *infile;
      struct dirent *dirp;

#ifdef vms 
#include <types.h>
#include <stat.h>
#endif

#include "MEMstruct.h"
#include "NETerrordef.h"
#include "NFMerrordef.h"
#include "ERR.h"


/* GLOBAL VARIABLE */
MEMptr *out_buffer ;
long max_size_directory = 0 ;

int NFMclix_get_dir(name, buf, flag)

  char *name ;
  struct stat *buf ;
  int flag ;

{

char *fname= "NFMclix_get_dir";

#ifdef __unix__

  char directory_name[50], file_name[50], name1[50] ;
  int  status;
  char *err_msg;
  char file_path[256], prev_token[50] ;
  char *str ;
  char record[250] ;
  struct stat stat_buff;

  _NFMdebug((fname,"CLIX COMPLETE PATH : stat : <%s>\n, <%d>", name,flag));

  strcpy (name1, name) ;

  directory_name[0] = 0 ;

  if (flag == FTW_F) {

    str =  (char *) strtok (name1, "/") ;
    strcpy(prev_token, str);

    while (str != NULL) 
    {
      str = (char*) strtok (NULL,"/");
      if (str != NULL ) {
	strcat (directory_name, "/") ;
	strcat (directory_name, prev_token) ;
      }
      else break ;

      strcpy (prev_token, str) ;
    }

    strcpy (file_name, prev_token) ;


  if (file_name[0] != '.')
    {
      _NFMdebug ((fname,"FTW BULK FILENAME : stat : <%s>\n", file_name));
      _NFMdebug ((fname,"FTW BULK DIR : stat : <%s>\n", directory_name));
      
      strcpy (file_path,directory_name);
      strcat (file_path, "/");
      strcat (file_path, file_name);
      err_msg = (char *) stat (file_path, &stat_buff);
      if (err_msg)
	{
	  _NFMdebug ((fname,"FTW STAT ERROR : stat : <%s>\n", err_msg));
	  perror ("FTW STAT ERROR : stat ");
          /*status = NFM_E_STAT;*/
          /*ERRload_struct (NFM, status, "%s", file_path);*/
	  return (-1) ;
	}

      _NFMdebug ((fname,"FTW STAT OK\n")) ;
      
      strcpy (record, file_name);
      strcat (record, "\1");
      strcat (record, directory_name);
      strcat (record, "\1");

      _NFMdebug ((fname,"FTW BULK MEMwrite\n")) ;
      if ((status = MEMwrite (*out_buffer, record)) != MEM_S_SUCCESS)
	{
	  MEMclose (out_buffer);
	  _NFMdebug ((fname,"FTW BULK DIR : MEMwrite = <0x%.8x>\n", status));
          status = NFM_E_MEM;
          ERRload_struct(NFM, NFM_E_MEM, "", NULL);
	  return (status);
	}
      _NFMdebug ((fname,"FTW BULK MEMwrite exit successfully\n")) ;
    }
  }
  _NFMdebug ((fname,"NFMclix_get_dir exit success\n")) ;

#endif

  return (0) ;
}
/* The fourth argument 'max_dir_size' is added to the function, 
   as the calling function is sending four arguments.
   SSRS - 30/11/93
*/
/*int NFMclix_bulk_dir (dirname,  output_buffer,  mode)*/
int NFMclix_bulk_dir (dirname, output_buffer, mode,  max_dir_size)
  char     *dirname;           /* input */
  MEMptr   *output_buffer;     /* output */
  char     *mode;              /* input */
  long     *max_dir_size;
  {

char *fname= "NFMclix_bulk_dir";

#ifdef OS_UNIX

    int  status;
    char *err_msg;
    char file_path[256];
    char str[80];
    struct stat stat_buff;
    int (*fn_ptr) ();
   
    /*  Open output_buffer  */
     
     fn_ptr = NFMclix_get_dir;
    _NFMdebug ((fname,"CLIX BULK DIR : directory : <%s>", dirname));
    _NFMdebug ((fname,"CLIX BULK MODE : mode : <%s>",mode ));

    if ((status = MEMopen (output_buffer, 2* MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname,"CLIX BULK DIR : MEMopen = <0x%.8x>\n", status));
        status = NFM_E_MEM;
        return (status);
      }
    
    status = MEMwrite_format (*output_buffer, "n_name", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (output_buffer);
        _NFMdebug((fname,"CLIX BULK DIR : MEMwrite_format = <0x%.8x>\n", status));
        status = NFM_E_MEM;
        return (status);
      }
    
    status = MEMwrite_format (*output_buffer, "n_directory", "char(50)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (output_buffer);
        _NFMdebug ((fname,"CLIX BULK DIR : MEMwrite_format = <0x%.8x>\n", status));
        status = NFM_E_MEM;
        ERRload_struct(NFM, NFM_E_MEM, "", NULL);
        return (status);
      }
    
    if (strcmp(mode,"A") == 0)
      {
    	out_buffer = output_buffer ;
    	status = ftw (dirname, fn_ptr, 20) ;
        if (status)
         {
           _NFMdebug((fname, "CLIX BULK DIR : ftw : <0x.%8x>\n", status));
           status = NFM_E_STAT;
           ERRload_struct(NFM, NFM_E_STAT, "", NULL);
           return(status);
         }
      }
    else
      {
	
	if ((infile = opendir (dirname)) == NULL)
	  {
      _NFMdebug ((fname, "CLIX BULK DIR : error opening directory file <%s>\n", dirname));
            status = NFM_E_OPEN_FILENAME;
            _NFMdebug ((fname,"CLIX BULK DIR : status = <0x%.8x>\n", status));
            ERRload_struct (NFM, status, "%s", dirname); 
            return (status);
	  }
	
	while ((dirp = readdir (infile)) != NULL)
	  {
	    if (strncmp (dirp->d_name, ".", 1) != 0)
              {
		strcpy (file_path, dirname);
		strcat (file_path, "/");
		strcat (file_path, dirp->d_name);
		err_msg = (char *) stat (file_path, &stat_buff);
		if (err_msg)
		  {
		    _NFMdebug ((fname,"CLIX BULK DIR : stat : <%s>\n", err_msg));
		    perror ("CLIX BULK DIR : stat ");
		  }
		
		if (!(stat_buff.st_mode & S_IFDIR))
		  {
		    _NFMdebug ((fname,"CLIX BULK DIR : found: <%s>\n", dirp->d_name));
		    strcpy (str, dirp->d_name);
		    strcat (str, "\1");
		    strcat (str, dirname);
		    strcat (str, "\1");
		    status = MEMwrite (*output_buffer, str);
		    if (status != MEM_S_SUCCESS)
		      {
			MEMclose (output_buffer);
                        _NFMdebug ((fname,"CLIX BULK DIR : MEMwrite = <0x%.8x>\n", status));
			closedir (infile);
                        status = NFM_E_MEM;
			return (status);
		      }
                    (*max_dir_size)++;
		  }
	      }
	  }
	
	closedir (infile);

      }
	return (NFM_S_SUCCESS);
#endif
  }
     

int NFMvms_bulk_dir (dirname, output_buffer, mode)
  char     *dirname;
  MEMptr   *output_buffer;
  char     *mode;

  {
char *fname="NFMvms_bulk_dir";

    int  status;
    char str[80];

    /*  Open output_buffer  */

    _NFMdebug ((fname,"VMS BULK DIR : directory : <%s>", dirname));
    _NFMdebug ((fname, "VMS BULK DIR : mode : <%s>", mode));

    if ((status = MEMopen (output_buffer, MEM_SIZE)) != MEM_S_SUCCESS)
        {
        _NFMdebug ((fname,"VMS BULK DIR : MEMopen = <0x%.8x>\n", status));
        status = NFM_E_MEM;
        return (status);
        }

    status = MEMwrite_format (*output_buffer, "name", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (output_buffer);
        _NFMdebug ((fname,"VMS BULK DIR : MEMwrite_format = <0x%.8x>\n", status));
        status = NFM_E_MEM;
        return (status);
        }

    status = MEMwrite_format (*output_buffer, "n_directory", "char(50)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (output_buffer);
        _NFMdebug ((fname,"CLIX BULK DIR : MEMwrite_format = <0x%.8x>\n", status));
        status = NFM_E_MEM;
        return (status);
        }
    
    if (strcmp(mode,"A") == 0)
        {
        }
    else
        {
        strcpy (str, dirp->d_name);
        strcat (str, "\1");
        strcat (str, dirname);
        strcat (str, "\1");
        status = MEMwrite (*output_buffer, str);
        if (status != MEM_S_SUCCESS)
	    {
            MEMclose (output_buffer);
            _NFMdebug((fname,"VMS BULK DIR : MEMwrite = <0x%.8x>\n", status));
            closedir (infile);
            return (status);
            }
        }

  return (NFM_S_SUCCESS);
  }


