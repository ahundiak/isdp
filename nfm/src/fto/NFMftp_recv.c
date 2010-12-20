#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <unistd.h>
#include <glib.h>

#include "ERR.h"
#include "DEBUG.h"
#include "MEM.h"

#include "NFMerrordef.h"
#include "NFMxferstrct.h"
#include "NFMxferextrn.h"
#include "NFMfto_buf.h"
#include "NFMsysstruct.h"

#include "TFERproto.h"
#include "SYSTproto.h"
#include "NETstruct.h"

static int tracex = 1;

#define OS_SOLARIS

long NFMunzip(char *file);

/* Static structure used by  ftp commands only */
static NFMxfer_ftp	NFMxfer_ftp_def = { 1 , 1, 0};

long NFMftp_receive (node_name, user_name, passwd, src_file, dst_file, type, size)
  char  *node_name, *user_name, *passwd;
  char  *src_file, *dst_file;
  char  *type;
  long  *size;
{
  char *fname="NFMftp_receive";
  char  f_script [NFM_FILENAME], f_stderr [NFM_FILENAME], f_stdout [NFM_FILENAME];

  /* ftp -n "NFM_NODENAME" < "f_script" > "f_stdout" 2> "f_stderr" */
  char shell_str[NFM_NODENAME + 4*NFM_FILENAME + 96];

  char tmp_str[2048]; // Just make it big

  char     file_name[NFM_FILENAME*4];
  FILE    *infile, *fopen ();
  struct   stat  fbuff;
  long     status,size1,no_of_retries;
  char     ftp_path[100];
  char    *whence();

  /* OV - IGI-320. Look for the comment below, where these var's are used */
  char *modified_src_file;
  char *modified_file_name;
   
  if (tracex)
  {
    printf(">>> %s %s %s %s %s %s\n",fname,node_name,user_name,src_file,dst_file,type,*size);
  }
  *size = -2;

  /* Get the complete name of the dst_file */
  status = NFMget_full_name (dst_file, file_name);
  g_return_val_if_fail(status == NFM_S_SUCCESS,status);
     
  sprintf (f_script,  "/usr/tmp/%s",  mktemp ("FTPnfm1XXXXXXX"));
  sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPnfm2XXXXXXX"));
  sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPnfm3XXXXXXX"));

    /* OV - IGI-320.
       Before generating the ftp scipt look for backward slashes in the
       src and dst file paths and duplicate the slashes.
       These modified paths shouldn't be used anyware else except to
       generate the ftp script, just to avoid confusion of slashes. */
  // Really should not need anymore
  //status = Duplicate_backward_slash(src_file, &modified_src_file);
  //status = Duplicate_backward_slash(dst_file, &modified_file_name);
  modified_src_file  = src_file;
  modified_file_name = dst_file;

  // ftp command
  sprintf (tmp_str, "user %s %s\nbinary\nget %s %s\nquit\n",
           user_name, passwd, modified_src_file, modified_file_name);

  infile = fopen (f_script, "w");
  if (! infile) return (NFM_E_FTP_FOPEN_WRITE_F_SCRIPT);

  size1 = strlen(tmp_str);
  status = fwrite (tmp_str, sizeof (char), size1, infile);
  fclose (infile);

  // The ftp command
  strcpy(ftp_path,"/bin/ftp");
  sprintf (shell_str, "%s -n -v %s  < %s > %s 2> %s",
           ftp_path, node_name, f_script, f_stdout, f_stderr);

  // Do it
  no_of_retries = 0;
  while (no_of_retries <  NFMxfer_ftp_def.no_of_retries)
  {
    system(shell_str);
    status = NFMscan_ftp_output1(f_stdout);
	  if(status != NFM_S_SUCCESS)
	  {
		  sleep(NFMxfer_ftp_def.sleep_time);
	  }
	  else break;

    if(no_of_retries== 0)
    {
      // Cat results
      sprintf (shell_str, "%s -n -v %s < %s >> %s 2>> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
    }
	  no_of_retries++;
  }
  unlink (f_script);

  if(status != NFM_S_SUCCESS)
	{
	  unlink (f_stderr);
    status = NFM_E_FTP_RECEIVE_FILE;
    return (status);
	} 
  unlink (f_stderr);
  unlink (f_stdout);

  status = stat (file_name, &fbuff);
  if (status) /* 0 = OK */
  {
    status = NFM_E_STAT;
    return (status);
  }

  // Un gzip
  NFMunzip(file_name);

  // Return size
   stat (file_name, &fbuff);
  *size = fbuff.st_size;

  return (NFM_S_SUCCESS);
}

long NFMunzip(char *file)
{
  int status;

  char cmd[2048];

  char f_stderr[256];
  char f_stdout[256];

  struct stat statx;

  // Verify have file, 0 means found it
  status = stat(file,&statx);
  if (status) return 0;

  sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPunzip1XXXXXXX"));
  sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPunzip2XXXXXXX"));

  // Add extension
  sprintf(cmd,"/bin/mv %s %s.gz > %s 2> %s",file,file,f_stdout,f_stderr);
  system (cmd);

  // Unzip
  sprintf(cmd,"/bin/gunzip %s.gz > %s 2> %s",file,f_stdout,f_stderr);
  system (cmd);

  // Check results
  status = stat(file,&statx);
  if (status == 0)
  {
    return NFMunzip(file); // Recuse for multiple compressions
  }

  // Move back to original
  sprintf(cmd,"/bin/mv %s.gz %s > %s 2> %s",file,file,f_stdout,f_stderr);
  system (cmd);

  unlink(f_stderr);
  unlink(f_stdout);

  return 1;
}
