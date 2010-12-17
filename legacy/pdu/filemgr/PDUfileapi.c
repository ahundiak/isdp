#include <stdio.h>
#include <errno.h>
#include <MEMstruct.h>
#include <MEMerrordef.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUintdef.h"
#include "PDMmessage.h"
#include "PDUstr.h"
#include "NFMerrordef.h"
#include "PDUintdef.h"
#include "PDMproto.h"
#include "PDUproto.h"
#include "pwd.h"

extern int PDMdebug_on;
extern char PDU_DEBUG_FILE[80];
extern MEMptr PDU_states_bufr;
extern MEMptr PDU_add_bufr;
extern MEMptr PDU_file_bufr;
extern MEMptr PDU_ret_bufr;
extern struct PDUrefresh *refresh;

/*  ALR  7/23/93   This file contains functions that are used by the API and
    the interface. These functions were pulled out of the regular interface
    code to be used with less dependencies on other functions. 
*/

#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
int PDUget_envs(MEMptr *env_bufr)
{
        FILE *fp = NULL;
        char env_file[80];
        char *s_ptr = NULL, *token1 = NULL,*token2 = NULL, env_str[30], string[1024];
        char *fname = "PDMget_envs", *token3;
        struct stat buf;
        long   status ;
        struct passwd *pwd;
        char   *ingr_loc = NULL;


        _PDMdebug(fname,"Enter\n");

/*  12/15/95 MJG - Use NFM's location for the NFMenv.dat file */

#if defined (i386) || defined (__sgi)

   ingr_loc = ((char *)getenv ("INGRHOME"));
   if (!ingr_loc)
     {
     _PDMdebug(fname, "ERROR:  INGRHOME is not set\n");
     return(PDM_E_INGRHOME_NOT_SET);
     }
   _PDMdebug(fname, "INGRHOME = <%s>\n", ingr_loc);
   sprintf(env_file, "%s/%s", ingr_loc, "nfm/NFMenv.dat");
#endif

#if defined (sparc) && defined (__Sol2__) && !defined (i386)
   pwd = getpwnam( "nfmadmin" );
   if (!pwd)
     {
     _PDMdebug(fname, "ERROR getting NFM path\n");
     return(PDM_E_NFMADMIN_ACCOUNT);
     }
   _PDMdebug(fname, "NFM path = <%s>\n", pwd->pw_dir);
   sprintf(env_file, "%s/%s", pwd->pw_dir, "clh_info/NFMenv.dat");
#endif
/* END 12/15/95 */

   _PDMdebug(fname, "ENV file = <%s>\n", env_file);

        if (stat (env_file, &buf))
          {
          _PDMdebug(fname, "NFMenv.dat file is not loaded\n");
          status = PDM_E_NFM_DAT_FILE;
          PDUmessage(status, 's');
          return(status);
          }

        _PDMdebug(fname,"Checking buf.st_size\n");
        if (buf.st_size == 0)
          {
             _PDMdebug(fname,"env_file <%s> is empty\n",env_file);
                return (NFM_E_OPEN_FILE);
          }
         
        _pdm_debug("opening env file", 0);
        if((fp=fopen(env_file,"r")) == (FILE *)0)
        {
       _PDMdebug(fname,"Cannot open file <%s>: errno <%d>\n",env_file,errno);
         return (NFM_E_OPEN_FILE);
        }
        status = MEMopen(env_bufr, 512);
        if(status != MEM_S_SUCCESS)
         {
         _PDMdebug(fname,"Cannot open env_bufr - status <%s>: \n",status);
         MEMclose(env_bufr);
         return(status);
         }

        _pdm_debug("formatting env bufr", 0);
        status = MEMwrite_format(*env_bufr, "env", "char(25)");
        if(status != MEM_S_SUCCESS)
         {
         _PDMdebug(fname,"MEMwrite_format failed - status <%s>: \n",status);
         MEMclose(env_bufr);
         return(status);
         }
        _pdm_debug("processing env file", 0);
        while((s_ptr=fgets(string,1023,fp)) != (char *)0)
        {
        _pdm_debug("string = <%s>", string);

                if(string[0] == '#')
                  {
                  _pdm_debug("skipping comment line", 0);
                  continue;
                  }
                else if(!strncmp(string,"::",2)) 
                  {
                  _pdm_debug("skipping :: delimeter", 0);
                  continue;
                  }
                else
                {
                token1 = (char *)strtok(string,"\001");
                _pdm_debug("looking for cntl A delimeter", 0);
                if(token1 == (char *)0)
                  {
                   _PDMdebug(fname,"ctl A delimiter not found \n");
                      continue;
                  }
                if(!strncmp("pdme_",token1,5))
                {
			_pdm_debug("checking for PDM", 0);
                        token2=(char *)strtok(NULL,"\001");
                        if(!strncmp("PDM",token2,3))
                        {
                         env_str[0] = '\0';
                         sprintf(env_str, "%s\1", (token1+5));
                         status = MEMwrite(*env_bufr, env_str);
                         if(status != MEM_S_SUCCESS)
                           {
                           _PDMdebug(fname,"MEMwrite failed - status <%s>: \n",status);
                           MEMclose(env_bufr);
                           fclose(fp);
                           return(status);
                           }
                        }
                 }
/* MJG 8/21/95 - TR 139526968 - function altered so that PDM can read the
   NFMenv.dat file that is created by NFM.  We know that all NFM envs do not
   necessarily have a corresponding PDM env.
*/
                else if (!strncmp("nfme_",token1,5))
                 {
                        _pdm_debug("checking for NFM", 0);
                        token2=(char *)strtok(NULL,"\001");
                        if (!token2)
                          {
                          _pdm_debug("token2 is NULL", 0);
                          token2=(char *)strtok(NULL,"NFM");
                          }
                        _pdm_debug("token1 = <%s>", token1);
                        if((token2) && (!strncmp("NFM",token2,3)))
                        {
                         env_str[0] = '\0';
                         sprintf(env_str, "%s\1", (token1+5));
                         status = MEMwrite(*env_bufr, env_str);
                         if(status != MEM_S_SUCCESS)
                           {
                           _PDMdebug(fname,"MEMwrite failed - status <%s>: \n",status);
                           MEMclose(env_bufr);
                           fclose(fp);
                           return(status);
                           }
                        }
/*
                        else if((token1) && (!strncmp("NFM",token1,3)))
                        {
                         env_str[0] = '\0';
                         sprintf(env_str, "%s\1", (token1+5));
                         status = MEMwrite(*env_bufr, env_str);
                         if(status != MEM_S_SUCCESS)
                           {
                           _PDMdebug(fname,"MEMwrite failed - status <%s>: \n",status);
                           MEMclose(env_bufr);
                           fclose(fp);
                           return(status);
                           }
                        }
*/
                 }
                string[0] = '\0';
                token1 = (char *) NULL;
                token2 = (char *) NULL;
                }
        }
        _pdm_debug("after processing env file", 0);
        fclose(fp);
 
        if(PDMdebug_on)
         MEMprint_buffer("ENV LIST", *env_bufr,PDU_DEBUG_FILE);
        _PDMdebug(fname,"Exit\n");
        return(PDM_S_SUCCESS);
}
#endif

#if defined (sparc) && defined (__Sol2__) && !defined (i386)
int PDUget_ris_path(ris_path)
char ris_path[80];
{
        FILE *fp = NULL;
        char  config_file[20];
        char *s_ptr = NULL, string[1024];
        char *temp_string = NULL;
        char *fname = "PDUget_ris_path";
        struct stat buf;
        long   status ;
        int    index = 0;
        int    length = 0;
        struct passwd *pwd;


   _PDMdebug(fname,"Enter\n");

   strcpy(config_file, "/etc/risconfig");
   _PDMdebug(fname, "config_file = <%s>\n", config_file);

   if (stat (config_file, &buf))
     {
     _PDMdebug(fname, "/etc/risconfig file does not exist\n");
     status = PDM_E_RISCONFIG_NOT_FOUND;
     PDUmessage(status, 's');
     return(status);
     }

   _PDMdebug(fname,"Checking buf.st_size\n");
   if (buf.st_size == 0)
     {
     _PDMdebug(fname,"risconfig <%s> is empty\n",config_file);
     return (PDM_E_RIS_PATH);
     }
    
   _PDMdebug(fname, "opening risconfig file\n");
   if ((fp=fopen(config_file,"r")) == (FILE *)0)
     {
     _PDMdebug(fname,"Cannot open file <%s>: errno <%d>\n",config_file,errno);
     return (PDM_E_OPEN_FILE);
     }

   _PDMdebug(fname, "processing config file\n");
   while((s_ptr=fgets(string,1023,fp)) != (char *)0)
     {
     _PDMdebug(fname, "string = <%s>\n", string);

     length = strlen(string);
     _PDMdebug(fname, "length = <%d>\n", length);
     index = length - 3;
     while (index >= 0)
       {
     _PDMdebug(fname, "index = <%d>\n", index);
       _PDMdebug(fname, "examining character <%c>\n", string[index]);
       if (string[index] != '#')
         --index;
       else
         break;
       }
     PDUfill_in_string(&temp_string, string + (index + 1));
     _PDMdebug(fname, "temp_string = <%s>\n", temp_string);

     if ((temp_string) && (strlen(temp_string)))
       break;

     string[0] = '\0';
     }
    _PDMdebug(fname,"after processing config file\n");
    fclose(fp);

    index = strlen(temp_string) - 1;
    while (temp_string[index] != '/')
      --index;

    temp_string[index] = '\0';
     _PDMdebug(fname, "temp_string = <%s>\n", temp_string);

    strcpy(ris_path, temp_string);

    if (temp_string)
      free(temp_string);
    if (s_ptr)
      free(s_ptr);

    _PDMdebug(fname,"Exit\n");
    return(PDM_S_SUCCESS);
}
#endif


int PDUget_buffer_col(bufr,col_name,col_num)

MEMptr bufr;
char *col_name;
int  *col_num;

{
   int  i;
   char **data_col;
   short found = FALSE;
   int  status = PDM_S_SUCCESS;

   status = PDUsetup_buffer(bufr,COL,&data_col);
   
   if (status == PDM_S_SUCCESS)
      {
      for (i = 0; i < bufr->columns; ++i)
         {
         if (strcmp(data_col[i],col_name) == 0)
            {
            *col_num = i;
            found = TRUE;
            break;
            }
         }

      if (!found)
          {
           _pdm_debug("SEVERE error: column <%s> not found in buffer",col_name);
           return(PDM_E_COL_NOT_IN_BUFFER);
          }
      }
   return(status);
}

char *PDUgetcwd( buf, size )
char *buf;
int size;
{
register int ret_status;
 int fildes[2];

 if( buf  ||  ( buf = ((char *)malloc( size )) ) ) {
    if( pipe( fildes ) == 0 ) {
#if defined (__sgi)
if( ret_status = fork() ) {
#else
if( ret_status = vfork() ) {
#endif
if( ret_status != -1 ) {
do {
ret_status = read( fildes[0], buf, size );/* read pipe */
} while ( ret_status == -1  &&errno == EINTR );

close( fildes[0] );/* close input pipe */
close( fildes[1] );/* close output pipe */

if( ret_status != -1 ) {

/* eliminate NULL placed on end by "pwd" */

if( ret_status < size ) buf[ ret_status - 1 ] = '\0';
#ifdef DBG
fprintf( stdout, "CWD = %s\n", buf );
#endif
return( buf );

}

#ifdef DBG_PAUSE
pause();
#endif
}
 
        } else {
 
            /* Don't use fclose because of having used "vfork".  Since the
             * process is not actually copied the use of fclose would wind
             * up corrupting the data structures representing the stream
             * in the parent.
             */
 
            close( fileno(stdout) );    /* close standard out   */
            dup( fildes[1] );           /* dup O/P pipe into stdout slot */
            close( fildes[1] );         /* close output pipe */
 
#ifdef DBG_PAUSE
            execlp( "pg", "pg", "/etc/profile", (char *)0 );
#endif
            execlp( "pwd", "pwd", (char *)0 );
        }
    }
 }
 return( (char *)NULL );
}

int PDUsetup_buffer(buffer, type, data)
MEMptr    buffer;
int       type;
char   ***data;
{
int       status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDUsetup_buffer", 0);

  if ((buffer->rows > 0) && (buffer))
    {
       if (type == COL)
          *data = (char **) buffer->column_ptr;
       else if (type == ROW)
          *data = (char **) buffer->data_ptr;
       else if (type == FORMAT)
          *data = (char **) buffer->format_ptr;

       status = PDM_S_SUCCESS; 
    } 
  return(status);
} /* end PDUsetup_buffer */


int PDUsetup_buffer_list(buffer, vert_bufr_no, horz_bufr_no, data_row,
                         data_col,data_format,temp_bufr)

MEMptr    buffer;
int       vert_bufr_no;
int       horz_bufr_no;
char   ***data_row;
char   ***data_col;
char   ***data_format;
MEMptr   *temp_bufr;

{
int       status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUsetup_buffer_list", 0);

  if (buffer == NULL)
    {
    _pdm_debug("buffer is NULL", 0);
    status = PDM_E_NULL_BUFFER;
    return(status);
    }

     if (horz_bufr_no == 0)
        {
          status = MEMreset_buffer_no (buffer, vert_bufr_no);
          _pdm_status("MEMreset_buffer_no", status);
          if (status != MEM_S_SUCCESS)
            return(status);
          status = MEMsplit_copy_buffer(buffer, temp_bufr, 0);
          _pdm_status("MEMsplit_copy_buffer", status);
          if (status != MEM_S_SUCCESS)
            return(status);
          status = MEMbuild_array(*temp_bufr);
          _pdm_status("MEMbuild_array", status);
          if (status != MEM_S_SUCCESS)
            return(status);

          *data_col = (char **) (*temp_bufr)->column_ptr;
          *data_row = (char **) (*temp_bufr)->data_ptr;
          *data_format = (char **) (*temp_bufr)->format_ptr;
       }
    else
        {
	_pdm_debug("horiz buffer != 0", 0);
        status = MEMreset_buffer_no (buffer, vert_bufr_no);
          _pdm_status("MEMreset_buffer_no", status);
          if (status != MEM_S_SUCCESS)
            return(status);

        if (status == MEM_S_SUCCESS)
          {
          status = MEMsplit_copy_buffer(buffer, temp_bufr, 1);
          _pdm_status("MEMsplit_copy_buffer", status);
          if (status != MEM_S_SUCCESS)
            return(status);
	  if (PDMdebug_on)
            MEMprint_buffers("temp buffer", *temp_bufr, PDU_DEBUG_FILE);
          status = MEMreset_buffer_no (*temp_bufr, horz_bufr_no);
          _pdm_status("MEMreset_buffer_no", status);
          if (status != MEM_S_SUCCESS)
            return(status);
          status = MEMsplit_copy_buffer(*temp_bufr, temp_bufr, 0);
          _pdm_status("MEMsplit_copy_buffer", status);
          if (status != MEM_S_SUCCESS)
            return(status);
	  if (PDMdebug_on)
            MEMprint_buffer("temp buffer", *temp_bufr, PDU_DEBUG_FILE);
          status = MEMbuild_array(*temp_bufr);
          _pdm_status("MEMbuild_array", status);
          if (status != MEM_S_SUCCESS)
            return(status);

          *data_col = (char **) (*temp_bufr)->column_ptr;
          *data_row = (char **) (*temp_bufr)->data_ptr;
          *data_format = (char **) (*temp_bufr)->format_ptr;
          }
       else
          {
          _pdm_debug("MEM status = %d",(char *)status);
          }
        }

    if (status == MEM_S_SUCCESS)
       return(PDM_S_SUCCESS);
    else
       return(status);
    }
 

int PDUget_col_number(bufr,col_name,data_col,col_num)
MEMptr bufr;
char *col_name;
char **data_col;
int  *col_num;

{
   int   i;
   short found = FALSE;

      for (i = 0; i < bufr->columns; ++i)
         {
         if (strcmp(data_col[i],col_name) == 0)
            {
            *col_num = i;
            found = TRUE;
            break;
            }
         }
   if (found != TRUE)
      {
      _pdm_debug("SEVERE error: column <%s> not found in buffer",col_name);
      return(PDM_E_COL_NOT_IN_BUFFER);
      }
   else
      return(PDM_S_SUCCESS);
}

int PDUmake_transition(to_state)
char  *to_state;
{
  int   status = PDM_S_SUCCESS;
  char   **dummy_row;
  char   **dummy_col;
  char   **dummy_format;
  char   **data_row;
  char   statename[41];
  int    status_col = 0;
  int    statename_col = 0;
  int    row = 0;
  short  found = FALSE;
  MEMptr attr_bufr = NULL;
  MEMptr states_bufr = NULL;

  _pdm_debug("in the function PDUmake_transition", 0);

  status = PDUsetup_buffer_list(PDU_states_bufr,1,0,&dummy_row, &dummy_col,
                                &dummy_format, &attr_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&data_row, &dummy_col,
                                &dummy_format, &states_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = MEMbuild_array(states_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
 
  if (PDMdebug_on)
    MEMprint_buffer("states_bufr", states_bufr, PDU_DEBUG_FILE);
 
  status = PDUget_buffer_col(states_bufr, "n_statename", &statename_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(states_bufr, "n_status", &status_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  _pdm_debug("input statename = <%s>", to_state);
 
  _pdm_debug("marking transition in buffer", 0);
  statename[0] = '\0';
  for (row = 0; row < states_bufr->rows; ++row)
     {
     strcpy(statename, data_row[(states_bufr->columns * row) + statename_col]);
     _pdm_debug("buffer statename = <%s>", statename);
 
     if (strcmp(to_state, statename) == 0)
       {
       _pdm_debug("writing to buffer", 0);
       status = MEMwrite_data(states_bufr, "next", (row + 1), (status_col + 1));
       _pdm_status("MEMwrite_data", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       found = TRUE;
       }
     }
 
  if (!found)
    {
    _pdm_debug("matching row not found in buffer", 0);
    return(PDM_E_SET_TO_STATE);
    }
 
  PDUmessage(PDS_M_MAKE_TRANSITION, 's');

  if (PDMdebug_on)
    MEMprint_buffer("states_bufr", states_bufr, PDU_DEBUG_FILE);
 
  status = PDMrmake_transition( refresh->rev_catalog,
                                refresh->rev_partid,
                                refresh->rev_revision,
                                attr_bufr,
                                states_bufr);
  _pdm_status("PDMrmake_transition", status);

  PDUunlock_item(refresh->rev_catalog, refresh->rev_partid,
                 refresh->rev_revision);

  return(status);
}

int PDUverify_add_file_list(cpr_catalog,
			    cpr_partnum,
			    cpr_revision,
			    cpr_stg_name,
			    spr_file_list)		
char   *cpr_catalog;
char   *cpr_partnum;
char   *cpr_revision;
char   *cpr_stg_name;
struct file_info *spr_file_list;
{
  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUverify_add_file_list", 0);

  while(spr_file_list)
    {
    if (spr_file_list->mode != ADD)
      return(PDM_E_INVALID_MODE);

    if (strlen(spr_file_list->local_fn) == 0)
      return(PDM_E_FILENAME_BLANK);

    if (strlen(spr_file_list->file_desc))
      {
      status = PDUverify_file_desc(spr_file_list->file_desc);
      _pdm_status("PDUverify_file_desc", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }

    if (strlen(spr_file_list->local_fn))
      {
      status = PDUverify_addpart_filename(spr_file_list->local_fn);
      _pdm_status("PDUverify_addpart_filename", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }
      
    if (strlen(spr_file_list->storage_fn))
      {
      status = PDUverify_addpart_filename(spr_file_list->storage_fn);
      _pdm_status("PDUverify_addpart_filename", status);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = PDMrcheck_dup_sa_fname(cpr_catalog, cpr_partnum, cpr_revision,
                                  spr_file_list->storage_fn, cpr_stg_name);
      _pdm_status("PDMrcheck_dup_sa_fname", status);
      if (status == NFM_E_SQL_QUERY)
        {
        status = PDM_E_ERROR_VERIFYING_FILENAME;
        return(status);
        }
      if (status != PDM_S_SUCCESS)
        return(status);
      }
      
    if (strlen(spr_file_list->file_type))
      {
      status = PDUverify_filetype(spr_file_list->file_type);
      _pdm_status("PDUverify_filetype", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }
      
    spr_file_list = spr_file_list->next;
    }

  return(status);
}

int PDUverify_attr_list(attr_list, attr_bufr, list_bufr, data_bufr, mode)
  struct attribute_info  *attr_list;
  MEMptr attr_bufr;
  MEMptr list_bufr;
  MEMptr *data_bufr;
  short  mode;
{
  long   status = PDM_S_SUCCESS;
  int    write_col = 0;
  int    update_col = 0;
  int    attr_row = 0;
  char   **data_row;

  _pdm_debug("in the function PDUverify_attr_list", 0);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  while(attr_list)
    {
    if (strlen(attr_list->value) == 0)
      strcpy(attr_list->value, "");

    if ((strlen(attr_list->attr_name) == 0) &&
        (strlen(attr_list->synonym) == 0))
       return(PDM_E_ATTR_NOT_FOUND);

    else if (strlen(attr_list->attr_name))
      {
      _pdm_debug("looking for <%s> in attr_bufr", attr_list->attr_name);
      attr_row = PDUfind_attr_in_buffer(attr_bufr, attr_list->attr_name);
      _pdm_debug("attr_row = %d", (char *)attr_row);
      if (attr_row == -1)
        return(PDM_I_ATTR_NOT_FOUND);

      status = PDUvalidate_api_data_value(attr_list->attr_name, 
                                          attr_list->value, 
                                          attr_bufr, list_bufr);
      _pdm_status("PDUvalidate_data_value", status);
      if (status != PDM_S_SUCCESS)
        return(PDM_E_INVALID_ATTR);
      }
    else if (strlen(attr_list->synonym))
      {
      _pdm_debug("looking for synonym in attr_bufr", 0);
      attr_row = PDUfind_attr_in_buffer(attr_bufr, attr_list->synonym);
      _pdm_debug("attr_row = %d", (char *)attr_row);
      if (attr_row == -1)
        return(PDM_I_ATTR_NOT_FOUND);

      status = PDUvalidate_api_data_value(attr_list->synonym, 
                                          attr_list->value, 
                                          attr_bufr, list_bufr);
      _pdm_status("PDUvalidate_data_value", status);
      if (status != PDM_S_SUCCESS)
        return(PDM_E_INVALID_ATTR);
      }
    else
      return(PDM_I_ATTR_NOT_FOUND);

    _pdm_debug("testing for write permission", 0);
    status = MEMbuild_array(attr_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    PDUsetup_buffer(attr_bufr, ROW, &data_row);

    status = PDUget_buffer_col(attr_bufr, "n_write", &write_col);
    _pdm_status("PDUget_buffer_col",status);
    if (status != PDM_S_SUCCESS)
      return(status);

    if (strcmp(data_row[(attr_bufr->columns * attr_row) + write_col], "N")==0)
       return(PDM_E_NOT_WRITABLE);

    if (mode == CHANGE)
      {
      status = PDUget_buffer_col(attr_bufr, "n_update", &update_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);
  
      if (strcmp(data_row[(attr_bufr->columns * attr_row) + update_col],"N")==0)
         return(PDM_E_NOT_UPDATABLE);
      }

    _pdm_debug("writing to data_bufr", 0);
    status = MEMbuild_array(*data_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

/*
    status = PDUget_buffer_col(*data_bufr, attr_list->attr_name, &name_col);
    _pdm_status("PDUget_buffer_col",status);
    if (status != PDM_S_SUCCESS)
      return(status);
*/

    status = MEMwrite_data(*data_bufr,attr_list->value,1,attr_row+1);
    _pdm_status("MEMwrite",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);

    attr_list = attr_list->next;
    }

  if (PDM_debug_on)
    MEMprint_buffer("data_bufr", *data_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;
  
  return(status);
}

int PDUverify_PDUattr_list(attr_list, attr_bufr, list_bufr, data_bufr, mode)
  struct PDUattribute_info  *attr_list;
  MEMptr attr_bufr;
  MEMptr list_bufr;
  MEMptr *data_bufr;
  short  mode;
{
  long   status = PDM_S_SUCCESS;
  int    write_col = 0;
  int    update_col = 0;
  int    attr_row = 0;
  char   **data_row;

  _pdm_debug("in the function PDUverify_attr_list", 0);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  while(attr_list)
    {
    if (strlen(attr_list->value) == 0)
      strcpy(attr_list->value, "");

    if ((strlen(attr_list->attr_name) == 0) &&
        (strlen(attr_list->synonym) == 0))
       return(PDM_E_ATTR_NOT_FOUND);

    else if (strlen(attr_list->attr_name))
      {
      _pdm_debug("looking for <%s> in attr_bufr", attr_list->attr_name);
      attr_row = PDUfind_attr_in_buffer(attr_bufr, attr_list->attr_name);
      _pdm_debug("attr_row = %d", (char *)attr_row);
      if (attr_row == -1)
        return(PDM_I_ATTR_NOT_FOUND);

      status = PDUvalidate_api_data_value(attr_list->attr_name, 
                                          attr_list->value, 
                                          attr_bufr, list_bufr);
      _pdm_status("PDUvalidate_data_value", status);
      if (status != PDM_S_SUCCESS)
        return(PDM_E_INVALID_ATTR);
      }
    else if (strlen(attr_list->synonym))
      {
      _pdm_debug("looking for synonym in attr_bufr", 0);
      attr_row = PDUfind_attr_in_buffer(attr_bufr, attr_list->synonym);
      _pdm_debug("attr_row = %d", (char *)attr_row);
      if (attr_row == -1)
        return(PDM_I_ATTR_NOT_FOUND);

      status = PDUvalidate_api_data_value(attr_list->synonym, 
                                          attr_list->value, 
                                          attr_bufr, list_bufr);
      _pdm_status("PDUvalidate_data_value", status);
      if (status != PDM_S_SUCCESS)
        return(PDM_E_INVALID_ATTR);
      }
    else
      return(PDM_I_ATTR_NOT_FOUND);

    _pdm_debug("testing for write permission", 0);
    status = MEMbuild_array(attr_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    PDUsetup_buffer(attr_bufr, ROW, &data_row);

    status = PDUget_buffer_col(attr_bufr, "n_write", &write_col);
    _pdm_status("PDUget_buffer_col",status);
    if (status != PDM_S_SUCCESS)
      return(status);

    if (strcmp(data_row[(attr_bufr->columns * attr_row) + write_col], "N")==0)
       return(PDM_E_NOT_WRITABLE);

    if (mode == CHANGE)
      {
      status = PDUget_buffer_col(attr_bufr, "n_update", &update_col);
      _pdm_status("PDUget_buffer_col",status);
      if (status != PDM_S_SUCCESS)
        return(status);
  
      if (strcmp(data_row[(attr_bufr->columns * attr_row) + update_col],"N")==0)
         return(PDM_E_NOT_UPDATABLE);
      }

    _pdm_debug("writing to data_bufr", 0);
    status = MEMbuild_array(*data_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

/*
    status = PDUget_buffer_col(*data_bufr, attr_list->attr_name, &name_col);
    _pdm_status("PDUget_buffer_col",status);
    if (status != PDM_S_SUCCESS)
      return(status);
*/

    status = MEMwrite_data(*data_bufr,attr_list->value,1,attr_row+1);
    _pdm_status("MEMwrite",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);

    attr_list = attr_list->next;
    }

  if (PDM_debug_on)
    MEMprint_buffer("data_bufr", *data_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;
  
  return(status);
}

int PDUprint_file_list(file_list)
  struct file_info   *file_list;
{
  long   status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();
 
  _pdm_debug("in the function PDUprint_file_list", 0);

  if (!file_list)
    {
    _pdm_debug("File Structure Linklist is NULL", 0);
    return(PDM_S_SUCCESS);
    }
 
  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (file_list)
    {
    fprintf(pdu_debug_file, "cpr_file_desc  = %s\n", file_list->file_desc);
    fprintf(pdu_debug_file, "cpr_local_fn   = %s\n", file_list->local_fn);
    fprintf(pdu_debug_file, "cpr_storage_fn = %s\n", file_list->storage_fn);
    fprintf(pdu_debug_file, "cpr_file_type  = %s\n", file_list->file_type);
    fprintf(pdu_debug_file, "ir_mode        = %d\n", file_list->mode);
    fprintf(pdu_debug_file, "\n");
    file_list = file_list->next;
    }
 
  fclose (pdu_debug_file);
  return(status);
} 

int PDUprint_change_list(file_list)
  struct chg_file_info   *file_list;
{
  long   status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();
 
  _pdm_debug("in the function PDUprint_chg_list", 0);

  if (!file_list)
    {
    _pdm_debug("Change File Structure Linklist is NULL", 0);
    return(PDM_S_SUCCESS);
    }
 
  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (file_list)
    {
    fprintf(pdu_debug_file, "cpr_file_desc      = %s\n", 
            file_list->file_desc);
    fprintf(pdu_debug_file, "cpr_chg_file_desc  = %s\n", 
            file_list->chg_file_desc);
    fprintf(pdu_debug_file, "cpr_local_fn       = %s\n", 
            file_list->local_fn);
    fprintf(pdu_debug_file, "cpr_chg_local_fn   = %s\n", 
            file_list->chg_local_fn);
    fprintf(pdu_debug_file, "cpr_storage_fn     = %s\n", 
            file_list->storage_fn);
    fprintf(pdu_debug_file, "cpr_chg_storage_fn = %s\n", 
            file_list->chg_storage_fn);
    fprintf(pdu_debug_file, "cpr_file_type      = %s\n", 
            file_list->file_type);
    fprintf(pdu_debug_file, "cpr_chg_file_type  = %s\n", 
            file_list->chg_file_type);
    fprintf(pdu_debug_file, "ir_mode            = %d\n", 
            file_list->mode);
    fprintf(pdu_debug_file, "\n");
    file_list = file_list->next;
    }
 
  fclose (pdu_debug_file);
  return(status);
} 

int PDUadd_files_to_buffer(file_bufr, add_list, saname)
MEMptr    *file_bufr;
struct file_info *add_list;
char      *saname;
{

  long    status = PDM_S_SUCCESS;
  int     cifile_col = 0;
  int     cofile_col = 0;
  int     row = 0;
  int     char_index = 0;
  int     col = 0;
  char    cifilename[15];
  char    cofilename[15];
  char    *line = NULL;
  char    **data_row;

  _pdm_debug("in the function PDUadd_files_to_buffer", 0);

  if (!*file_bufr)
    {
    /* create the file_bufr */
    status = PDUformat_buffer(PDU_ADD_FILE_BUFFER, file_bufr);
    _pdm_status("PDUformat_buffer", status);
  
    if (status != PDM_S_SUCCESS)
      return(status);
  
    line = (char*) malloc ((*file_bufr)->row_size);
    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;
  
    /* write a blank first row to the file buffer */
    for (col = 0; col < (*file_bufr)->columns; ++col)
       line[col] = '\1';
  
    status = MEMwrite (*file_bufr, line);
    _pdm_status("MEMwrite", status);
     
    if (status != MEM_S_SUCCESS)
      {
      _pdm_debug("Error writing to file_bufr", 0);
      return(PDM_E_WRITE_BUFFER);
      }
    else 
      status = PDM_S_SUCCESS;
    }
  else
    line = (char*) malloc ((*file_bufr)->row_size);

  if (!add_list)
    return(PDM_E_NULL_FILE_LIST);

  if (PDMdebug_on)
    {
    MEMprint_buffer("original file_bufr", *file_bufr, PDU_DEBUG_FILE);
    PDUprint_file_list(add_list);
    }

  status = MEMbuild_array(*file_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  cifilename[0] = '\0';
  cofilename[0] = '\0';

  status = PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);
  if (status != PDM_S_SUCCESS)
    {
    cifile_col = 0;
    strcpy(cifilename, "");
    _pdm_debug("ci_filename is READ ONLY", 0);
    }

  status = PDUget_buffer_col(*file_bufr, "n_cofilename", &cofile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  /* add each node in the linklist to the file_bufr */
  while (add_list)
    {
    _pdm_debug("memsetting line", 0);
    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;

    _pdm_debug("checking for duplicate filenames", 0);

    status = MEMbuild_array(*file_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
  
    PDUsetup_buffer(*file_bufr, ROW, &data_row);

    for (row = 1; row < (*file_bufr)->rows; ++row)
       {
       if (cifile_col)
       strcpy(&cifilename,data_row[((*file_bufr)->columns * row) + cifile_col]);
       strcpy(&cofilename,data_row[((*file_bufr)->columns * row) + cofile_col]);

       if (((strlen(add_list->local_fn) > 0) && 
            (strcmp(add_list->local_fn, cofilename) == 0)) ||
            (strlen(add_list->storage_fn) > 0) &&
            (strcmp(add_list->storage_fn, cifilename) == 0))
         {
         _pdm_debug("duplicate filename found in add_list", 0);
         return(PDM_E_DUPLICATE_FILENAME);
         }
       }

     _pdm_debug("setting entry for n_filenum", 0);
     line[char_index++] = '\1';  /* entry for n_filenum */

     if (add_list->local_fn && (strlen (add_list->local_fn )))
       PDUadd_buffer_string(line, &char_index, add_list->local_fn);
     else
       line[char_index++] = '\1';
 
     if (add_list->file_type && (strlen (add_list->file_type )))
       PDUadd_buffer_string(line, &char_index, add_list->file_type);
     else
       line[char_index++] = '\1';
 
     if (saname && (strlen (saname )))
       PDUadd_buffer_string(line, &char_index, saname);
     else
       line[char_index++] = '\1';
 
     if (cifile_col)
       {
       if (add_list->storage_fn && (strlen (add_list->storage_fn )))
         PDUadd_buffer_string(line, &char_index, add_list->storage_fn);
       else
         line[char_index++] = '\1';
       }
 
     line[char_index++] = '\1';  /* entry for n_cosano */
     line[char_index++] = '\1';  /* entry for n_couser */

     if (add_list->file_desc && (strlen (add_list->file_desc )))
       PDUadd_buffer_string(line, &char_index, add_list->file_desc);
     else
       line[char_index++] = '\1';

     _pdm_debug("line = <%s>", line);
     status = MEMwrite (*file_bufr, line);
     _pdm_status("MEMwrite", status);
 
     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to file_bufr", 0);
       return(PDM_E_WRITE_BUFFER);
       }
     else 
       status = PDM_S_SUCCESS;

   add_list = add_list->next;
   }

  if (PDMdebug_on)
  MEMprint_buffer("modified file_bufr", *file_bufr, PDU_DEBUG_FILE);

  free(line);

  return(status);
}

int PDUchange_files_in_buffer(file_bufr, chg_list)
MEMptr    *file_bufr;
struct chg_file_info *chg_list;
{

  long    status = PDM_S_SUCCESS;
  int     cifile_col = 0;
  int     cofile_col = 0;
  int     desc_col = 0;
  int     type_col = 0;
  int     status_col = 0;
  int     row = 0;
  int     char_index = 0;
  char    cifilename[15];
  char    cofilename[15];
  char    filedesc[256];
  char    filetype[6];
  char    *line = NULL;
  char    **data_row;
  short   found = FALSE;

  _pdm_debug("in the function PDUchg_files_in_buffer", 0);

  if (!*file_bufr)
    return(PDM_E_NULL_BUFFER);

  if (!chg_list)
    return(PDM_E_NULL_FILE_LIST);

  if (PDMdebug_on)
  MEMprint_buffer("original file_bufr", *file_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(*file_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(*file_bufr, ROW, &data_row);

  status = PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_cofilename", &cofile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_filetype", &type_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "p_filedesc", &desc_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_status", &status_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  line = (char*) malloc ((*file_bufr)->row_size);

  cifilename[0] = '\0';
  cofilename[0] = '\0';

  /* change each node in the linklist to the file_bufr */
  found = FALSE;
  while (chg_list)
    {
    status = MEMbuild_array(*file_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
    
    PDUsetup_buffer(*file_bufr, ROW, &data_row);

    _pdm_debug("row to match is:", 0);

    _pdm_debug("cpr_local_fn = <%s>", chg_list->chg_local_fn);
    _pdm_debug("cpr_storage_fn = <%s>", chg_list->chg_storage_fn);
    _pdm_debug("cpr_file_desc = <%s>", chg_list->chg_file_desc);
    _pdm_debug("cpr_file_type = <%s>", chg_list->chg_file_type);

    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;

    /* search through the file_bufr for duplicate filenames */
    for (row = 1; row < (*file_bufr)->rows; ++row)
       {
       strcpy(cifilename, data_row[((*file_bufr)->columns * row) + cifile_col]);
       strcpy(cofilename, data_row[((*file_bufr)->columns * row) + cofile_col]);

       if ((strlen(chg_list->chg_local_fn)) && (strlen(cofilename)) &&
           (strcmp(chg_list->chg_local_fn, cofilename) == 0))
         {
         _pdm_debug("duplicate filename found in chg_list", 0);
         return(PDM_E_DUPLICATE_FILENAME);
         }

       if ((strlen(chg_list->chg_storage_fn)) && (strlen(cifilename)) &&
           (strcmp(chg_list->chg_storage_fn, cifilename) == 0))
         {
         _pdm_debug("duplicate filename found in chg_list", 0);
         return(PDM_E_DUPLICATE_FILENAME);
         }
       }

     /* find the matching row in the buffer */
     _pdm_debug("looking for matching row in buffer", 0);
     for (row = 0; row < (*file_bufr)->rows; ++row)
        {
        _pdm_debug("row = %d", (char *)row);
	cifilename[0] = '\0';
	cofilename[0] = '\0';
	filedesc[0] = '\0';
	filetype[0] = '\0';

        strcpy(&cifilename,data_row[((*file_bufr)->columns*row) + cifile_col]);
        strcpy(&cofilename,data_row[((*file_bufr)->columns*row) + cofile_col]);
        strcpy(&filedesc, data_row[((*file_bufr)->columns * row) + desc_col]);
        strcpy(&filetype, data_row[((*file_bufr)->columns * row) + type_col]);

        _pdm_debug("cifilename = <%s>", cifilename);
        _pdm_debug("cofilename = <%s>", cofilename);
        _pdm_debug("filedesc = <%s>", filedesc);
        _pdm_debug("filetype = <%s>", filetype);

        if (!chg_list->local_fn)
          strcpy(chg_list->local_fn, NULL_STRING);
        if (!chg_list->storage_fn)
          strcpy(chg_list->storage_fn, NULL_STRING);
        if (!chg_list->file_desc)
          strcpy(chg_list->file_desc, NULL_STRING);
        if (!chg_list->file_type)
          strcpy(chg_list->file_type, NULL_STRING);

        if ((strcmp(chg_list->local_fn, cofilename) == 0) ||
            (strcmp(chg_list->storage_fn, cifilename) == 0) ||
            (strcmp(chg_list->file_desc, filedesc) == 0) ||
            (strcmp(chg_list->file_type, filetype) == 0))
          {
          found = TRUE;
          /* write change information to file_bufr */

          if (strlen (chg_list->chg_local_fn ))
            {
            _pdm_debug("writing new local filename", 0);
            status = MEMwrite_data(*file_bufr, chg_list->chg_local_fn,
                                   row + 1, cofile_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
     
          if (strlen (chg_list->chg_storage_fn ))
            {
            _pdm_debug("writing new storage filename", 0);
            status = MEMwrite_data(*file_bufr, chg_list->chg_storage_fn,
                                   row + 1, cifile_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
     
          if (strlen (chg_list->chg_file_desc ))
            {
            _pdm_debug("writing new file desc", 0);
            status = MEMwrite_data(*file_bufr, chg_list->chg_file_desc,
                                   row + 1, desc_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
     
          if (strlen (chg_list->chg_file_type ))
            {
            _pdm_debug("writing new file type", 0);
            status = MEMwrite_data(*file_bufr, chg_list->chg_file_type,
                                   row + 1, type_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
          }
        }

   chg_list = chg_list->next;
   }

  free(line);

  if (!found)
    return(PDM_E_FILE_NOT_FOUND_AVAILABLE);

  if (PDMdebug_on)
  MEMprint_buffer("modified file_bufr", *file_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}

int PDUmark_files_for_delete(file_bufr, delete_list)
MEMptr    *file_bufr;
struct file_info *delete_list;
{

  long    status = PDM_S_SUCCESS;
  int     cifile_col = 0;
  int     cofile_col = 0;
  int     row = 0;
  int     status_col = 0;
  char    cifilename[15];
  char    cofilename[15];
  char    **data_row;
  short   found = FALSE;

  _pdm_debug("in the function PDUmark_files_for_delete", 0);

  if (!*file_bufr)
    return(PDM_E_NULL_BUFFER);

  if (!delete_list)
    return(PDM_E_NULL_FILE_LIST);

  if (PDMdebug_on)
  MEMprint_buffer("original file_bufr", *file_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(*file_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(*file_bufr, ROW, &data_row);

  status = PDUget_buffer_col(*file_bufr, "n_status", &status_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_cofilename", &cofile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  cifilename[0] = '\0';
  cofilename[0] = '\0';

  found = FALSE;

  while (delete_list)
    {
    for (row = 0; row < (*file_bufr)->rows; ++ row)
       {
       /* load file information from current row */
       strcpy(cifilename, data_row[((*file_bufr)->columns * row) + cifile_col]);
       strcpy(cofilename, data_row[((*file_bufr)->columns * row) + cofile_col]);

       _pdm_debug("local filename = <%s>", cofilename);
       _pdm_debug("storage filename = <%s>", cifilename);

       if (strcmp(delete_list->local_fn, cofilename) == 0)
         {
         found = TRUE;
         _pdm_debug("marking row for deletion", 0);
         status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
         _pdm_status("MEMwrite_data", status);
         if (status != MEM_S_SUCCESS)
           return(PDM_E_WRITE_BUFFER);
         }
       }
       
       delete_list = delete_list->next;
    }

  if (!found)
    return(PDM_E_FILE_NOT_FOUND_AVAILABLE);

  if (PDMdebug_on)
  MEMprint_buffer("modified file_bufr", *file_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}

int PDUverify_change_file_list(cpr_catalog,
			       cpr_partnum,
			       cpr_revision,
			       cpr_stg_name,
			       spr_files)		
char   *cpr_catalog;
char   *cpr_partnum;
char   *cpr_revision;
char   *cpr_stg_name;
struct chg_file_info *spr_files;
{
  long   status = PDM_S_SUCCESS;
  MEMptr bufr = NULL;

  _pdm_debug("in the function PDUverify_change_file_list", 0);

  while(spr_files)
    {
    if (spr_files->mode != CHANGE)
      return(PDM_E_INVALID_MODE);

    if ((strlen(spr_files->chg_local_fn) == 0) && 
        (strlen(spr_files->chg_file_desc) == 0) &&
        (strlen(spr_files->chg_file_type) == 0) &&
        (strlen(spr_files->chg_storage_fn) == 0))
      return(PDM_E_NO_DATA_IN_FILE_LIST);

    if (strlen(spr_files->chg_file_desc))
      {
      status = PDUverify_file_desc(spr_files->chg_file_desc);
      _pdm_status("PDUverify_file_desc", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }

    if (strlen(spr_files->chg_local_fn))
      {
      status = PDUverify_addpart_filename(spr_files->chg_local_fn);
      _pdm_status("PDUverify_addpart_filename", status);
      if (status != PDM_S_SUCCESS)
        return(status);

      _pdm_debug("checking where used", 0);
      status = PDMrget_imm_parents(cpr_catalog,cpr_partnum,cpr_revision,&bufr);
      _pdm_status("PDMrget_imm_parents", status);
      MEMclose(&bufr);
     
      if ((status != PDM_E_NO_PARENTS) && (status != SQL_I_NO_ROWS_FOUND))
        return(PDM_I_PART_IN_ASS);
      else
        status = PDM_S_SUCCESS;
      }
      
    if (strlen(spr_files->chg_storage_fn))
      {
      status = PDUverify_addpart_filename(spr_files->chg_storage_fn);
      _pdm_status("PDUverify_addpart_filename", status);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = PDMrcheck_dup_sa_fname(cpr_catalog, cpr_partnum, cpr_revision,
                                   spr_files->chg_storage_fn, cpr_stg_name);
      _pdm_status("PDMrcheck_dup_sa_fname", status);
      if (status == NFM_E_SQL_QUERY)
        {
        status = PDM_E_ERROR_VERIFYING_FILENAME;
        return(status);
        }
      if (status != PDM_S_SUCCESS)
        return(status);
      }
      
    if (strlen(spr_files->chg_file_type))
      {
      status = PDUverify_filetype(spr_files->chg_file_type);
      _pdm_status("PDUverify_filetype", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }
      
    spr_files = spr_files->next;
    }

  return(status);
}

void PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision,
                            attr_bufr, data_bufr, file_bufr, add_bufr,
			    acl_bufr, stg_bufr)
char *cpr_catalog;
char *cpr_partnum;
char *cpr_revision;
MEMptr attr_bufr;
MEMptr data_bufr;
MEMptr file_bufr;
MEMptr add_bufr;
MEMptr acl_bufr;
MEMptr stg_bufr;
{

  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the fucntion PDUcleanup_change_part", 0);

  status = PDMcancel_modify_part(cpr_catalog, cpr_partnum, cpr_revision,
                                 attr_bufr, data_bufr);
  _pdm_status("PDMcancel_modify_part", status);

  if (PDU_add_bufr)
    {
    MEMclose(&PDU_add_bufr);
    PDU_add_bufr = NULL;
    }
  
  if (PDU_file_bufr)
    {
    MEMclose(&PDU_file_bufr);
    PDU_file_bufr = NULL;
    }
  
  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }
  
  if (attr_bufr)
      MEMclose(&attr_bufr);
 
   if (data_bufr)
      MEMclose(&data_bufr);
 
   if (acl_bufr)
      MEMclose(&acl_bufr);
 
   if (stg_bufr)
      MEMclose(&stg_bufr);
 
   if (file_bufr)
      MEMclose(&file_bufr);
 
   if (add_bufr)
      MEMclose(&add_bufr);
}

int PDUprint_PDUattr_list(list)
  struct PDUattribute_info   *list;
{
  long   status = PDM_S_SUCCESS;
  FILE  *pdu_debug_file, *fopen();
 
  _pdm_debug("in the function PDUprint_PDUattr_list", 0);

  if (!list)
    {
    _pdm_debug("Attr Structure Linklist is NULL", 0);
    return(PDM_S_SUCCESS);
    }
 
  _pdm_debug("opening debug file", 0);
  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }
  _pdm_debug("after opening debug file", 0);

  while (list)
    {
    _pdm_debug("checking values for NULL", 0);
    if (!list->attr_name)
      PDUfill_in_string(&(list->attr_name), "");
    if (!list->datatype)
      PDUfill_in_string(&(list->datatype), "");
    if (!list->synonym)
      PDUfill_in_string(&(list->synonym), "");
    if (!list->value)
      PDUfill_in_string(&(list->value), "");

    fprintf(pdu_debug_file, "attr_name  = %s\n", list->attr_name);
    fprintf(pdu_debug_file, "datatype = %s\n", list->datatype);
    fprintf(pdu_debug_file, "synonym   = %s\n", list->synonym);
    fprintf(pdu_debug_file, "value  = %s\n", list->value);
    fprintf(pdu_debug_file, "\n");
    list = list->next;
    }
 
  fclose (pdu_debug_file);
  return(status);
} 
