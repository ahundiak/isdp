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

/* Static structure used by  ftp commands only */
static NFMxfer_ftp	NFMxfer_ftp_def = { 1 , 1, 0}; // retries sleep verify

long NFMzip  (char *file);
long NFMunzip(char *file);

long NFMftp_send (node_name, user_name, passwd, src_file, dst_file, type, size)
  char *node_name, *user_name, *passwd;
  char *src_file, *dst_file;
  char *type;
  long *size;
{
  char  *fname="NFMftp_send";
  char   f_script [NFM_FILENAME], f_stderr [NFM_FILENAME], f_stdout [NFM_FILENAME];
  /* ftp -n "NFM_NODENAME" < "f_script" > "f_stdout" 2> "f_stderr" */
  char   shell_str[NFM_NODENAME + 4*NFM_FILENAME + 96];
  char   tmp_str[2048],f_verify[NFM_FILENAME];
  char   file_name[4*NFM_FILENAME];
  FILE  *infile;
  struct stat  fbuff;
  long   status,size1,no_of_retries,verify_size;
  char   ftp_path[100];
    
  /* OV - IGI-320. Look for the comment below, where these var's are used */
  char *modified_file_name;
  char *modified_dst_file;

  if (tracex)
  {
    printf(">>> %s %s %s %s %s %s\n",fname,node_name,user_name,src_file,dst_file,type,*size);
  }
  *size = verify_size  = -2 ;

  /* Get the complete name of the src_file */
  status = NFMget_full_name (src_file, file_name);
  g_return_val_if_fail(status == NFM_S_SUCCESS,status);

  // Make sure have file
  status = stat (file_name, &fbuff);
  g_return_val_if_fail(status == 0,status);
     
  sprintf (f_script,  "/usr/tmp/%s",  mktemp ("FTPnfm1XXXXXXX"));
  sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPnfm2XXXXXXX"));
  sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPnfm3XXXXXXX"));
  sprintf (f_verify,  "/usr/tmp/%s",  mktemp ("FTPnfm4XXXXXXX"));

  /* OV - IGI-320.
     Before generating the ftp scipt look for backward slashes in the
     src and dst file paths and duplicate the slashes.
     These modified paths shouldn't be used anyware else except to
     generate the ftp script, just to avoid confusion of slashes. */
  // ah - Really should not need anymore
  // status = Duplicate_backward_slash(src_file, &modified_file_name);
  // status = Duplicate_backward_slash(dst_file, &modified_dst_file);
  modified_dst_file  = dst_file;
  modified_file_name = src_file;

  /* Zip up the file */
  NFMzip(file_name);

  // ftp command
  sprintf (tmp_str, "user %s %s\nbinary\nput %s %s\nquit\n",user_name, passwd, modified_file_name, modified_dst_file);

  infile = fopen (f_script, "w");
  g_return_val_if_fail(infile,NFM_E_FTP_FOPEN_WRITE_F_SCRIPT);

  size1 = strlen(tmp_str);
  status = fwrite (tmp_str, sizeof (char), size1, infile);
  g_return_val_if_fail(status == size1,NFM_E_FTP_FOPEN_WRITE_F_SCRIPT);

  fclose (infile);
      
  strcpy (ftp_path, "/bin/ftp");
  sprintf(shell_str, "%s -n -v %s < %s > %s 2> %s", ftp_path, node_name, f_script, f_stdout, f_stderr);

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
      sprintf (shell_str, "%s -n -v %s < %s >> %s 2>> %s", ftp_path, node_name, f_script, f_stdout, f_stderr);
    }
	  no_of_retries++;
  }
  unlink (f_script);
	unlink (f_stderr);
  unlink (f_stdout);

  g_return_val_if_fail(status == NFM_S_SUCCESS,NFM_E_FTP_SEND_FILE);

  /* If verify mode is on */
  if(NFMxfer_ftp_def.verify)
  {
 	  status = NFMftp_receive(node_name, user_name, passwd, dst_file, f_verify, type, &verify_size);
	  unlink(f_verify);

    g_return_val_if_fail(status == NFM_S_SUCCESS,status);
    g_return_val_if_fail(verify_size == fbuff.st_size,NFM_E_FTP_SEND_FILE_VERIFY_SIZE);
  }
  *size = fbuff.st_size;

  // probably work on a copy in case of failures
  NFMunzip(file_name);

  return (NFM_S_SUCCESS);
}

long NFMzip(char *file)
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

  // Zip
  sprintf(cmd,"/bin/gzip %s > %s 2> %s",file,f_stdout,f_stderr);
  system (cmd);

  // And restore name
  sprintf(cmd,"/bin/mv %s.gz %s > %s 2> %s",file,file,f_stdout,f_stderr);
  system (cmd);

  unlink(f_stderr);
  unlink(f_stdout);

  return 1;
}
