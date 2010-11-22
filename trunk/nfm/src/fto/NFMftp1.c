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

extern char *mktemp(char *);

/* Static structure used by  ftp commands only */
static NFMxfer_ftp	NFMxfer_ftp_def = { 1 , 1, 0};

 long NFMftp_receive (node_name, user_name, passwd, 
                      src_file, dst_file, type, size)
   char     *node_name, *user_name, *passwd;
   char     *src_file, *dst_file;
   char     *type;
   long     *size;
   {
      char *fname="NFMftp_receive";
      char     f_script [NFM_FILENAME], f_stderr [NFM_FILENAME], f_stdout [NFM_FILENAME];
/* ftp -n "NFM_NODENAME" < "f_script" > "f_stdout" 2> "f_stderr" */
      char shell_str[NFM_NODENAME + 4*NFM_FILENAME + 96];
      char *tmp_str;
      char file_name[4*NFM_FILENAME];
      FILE     *infile, *fopen ();
      struct   stat  fbuff;
      long     status,size1,no_of_retries;
      char     ftp_path[100];
      char     *whence();

     /* OV - IGI-320. Look for the comment below, where these var's are used */
    char *modified_src_file;
    char *modified_file_name;
   
    if (tracex)
    {
      printf(">>> %s %s %s %s %s %s %s\n",fname,node_name,user_name,passwd,src_file,dst_file,type,*size);
    }
      _NFMdebug((fname,"Nodename <%s> username <%s> password <%s>\n Source file\
 <%s> Dst File <%s> type <%s> size <%d>\n",node_name,user_name,"IS NOT PRINTED",src_file,dst_file,type,*size));

      *size = -2;

/* Get the complete name of the dst_file */
      status = NFMget_full_name (dst_file, file_name);
      if (status != NFM_S_SUCCESS)
       {
          _NFMdebug ((fname,"NFMget_full_name: status = <0x%.8x>\n", status));
          return (status);
       }

     
      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("FTPnfm1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPnfm2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPnfm3XXXXXXX"));

    /* OV - IGI-320.
       Before generating the ftp scipt look for backward slashes in the
       src and dst file paths and duplicate the slashes.
       These modified paths shouldn't be used anyware else except to
       generate the ftp script, just to avoid confusion of slashes. */
    status = Duplicate_backward_slash(src_file, &modified_src_file);
    status = Duplicate_backward_slash(dst_file, &modified_file_name);

/* figure out size of tmp_str required
   user <username> <passwd> \nbinary\nget <src_file> <file_name>\nquit\n 
   malloc it
   use it
   free it */
      size1 = 48 + strlen(user_name) + strlen(passwd) + strlen(modified_src_file) + strlen(modified_file_name);

      tmp_str = (char *)malloc(size1);
      if(tmp_str == (char *)0)
      {
	 _NFMdebug((fname,"Malloc failed for temporary string. size <%d>:\
status <0x%.8x>\n",size1,NFM_E_MALLOC));
	ERRload_struct(NFM,NFM_E_MALLOC,"%d",size1);
	return(NFM_E_MALLOC);
      }
      sprintf (tmp_str, "user %s %s\nbinary\nget %s %s\nquit\n",
              user_name, passwd, modified_src_file, modified_file_name);

      _NFMdebug ((fname,"SCRIPT = <%s>\n", tmp_str));

      infile = fopen (f_script, "w");
      if (! infile)
       {
	  free(tmp_str);
          status = NFM_E_FOPEN;
          _NFMdebug ((fname,"fopen : filename <%s>:type <%s>;errno <%d>: status = <0x%.8x>\n",f_script,"w",errno, status));
          ERRload_struct (NFM, status, "%s%d%s", f_script,errno,"w");
          return (NFM_E_FTP_FOPEN_WRITE_F_SCRIPT);
       }
      size1 = strlen(tmp_str);
      status = fwrite (tmp_str, sizeof (char), size1, infile);
      if (status < size1)
       {
	 free(tmp_str);
         fclose (infile);
         unlink (f_script);
         _NFMdebug ((fname,"fwrite:filename <%s>:size1 <%d>:size2 <%d>:\
 errno <%d> : status = <0x%.8x>\n",f_script,size1,status,errno, status));
         ERRload_struct (NFM, NFM_E_FWRITE, "%s%d%d%d", f_script,size1,status,errno);
	 xfer_buf_status.status2 = size1;
	 xfer_buf_status.status3 = status;
         return (NFM_E_FTP_FWRITE_F_SCRIPT);  
       }

      fclose (infile);
      free(tmp_str);

      ftp_path[0] = '\0';
      strcpy(ftp_path, whence("ftp", NULL));

/*  ftp option -n  only is used for SUN , SOLARIS and SCO_UNIX
    as -h is not available SSRS 27 Dec 1993 */
#if (defined(OS_SUNOS) || defined (OS_SOLARIS) || defined (OS_SCO_UNIX) || defined (OS_HPUX) )
	/* -v option added as it is required MVV */
      sprintf (shell_str, "%s -n -v %s  < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
      /* Removed addtional %s. SSRS - 3/12/93 */
      sprintf (shell_str, "%s -n -h %s < %s | grep -v -i user > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#endif

      _NFMdebug ((fname,"System Script = <%s>\n", shell_str));
      no_of_retries = 0;
      while (no_of_retries <  NFMxfer_ftp_def.no_of_retries)
      {
      	status = NFMsystem_imm(shell_str);
      	if(status!=NFM_S_SUCCESS)
      	{
      		unlink (f_script);
		unlink(f_stderr);
		_NFMdebug((fname,"NFMsystem_imm: errorfile <%s>:status <0x%.8x>\n",f_stdout,status));
		return(status);
      	}
        status = NFMscan_ftp_output1(f_stdout);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"NFMscan_ftp_output1: status <0x%.8x>\n",status));
		sleep(NFMxfer_ftp_def.sleep_time);
	}
	else break;
      if(no_of_retries== 0)
       {
/*  ftp option -n  only is used for SUN , SOLARIS and SCO_UNIX
    as -h is not available SSRS 27 Dec 1993 */
#if (defined(OS_SUNOS) || defined (OS_SOLARIS) || defined (OS_SCO_UNIX) || defined (OS_HPUX) )
	/* -v option added as it is required MVV */
        sprintf (shell_str, "%s -n -v %s < %s >> %s 2>> %s",
                ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
        /* Removed additional %s. SSRS - 3/12/93 */
        sprintf (shell_str, "ftp -n -h %s < %s | grep -v -i user >> %s 2>> %s",
                node_name, f_script, f_stdout, f_stderr);
#endif
       }
	no_of_retries++;
      }


     _NFMdebug ((fname,"Total No of Actual Ftp Retries = <%d>\n", 
	 no_of_retries));
      unlink (f_script);

      if(status != NFM_S_SUCCESS)
	  {
	      unlink (f_stderr);
              status = NFM_E_FTP_RECEIVE_FILE;
	      _NFMdebug((fname,"Failure: Receive <%s> to <%s> from:Nodename <%s>:\
Username <%s>:\npasswd <%s>:errorfile <%s>:status <0x%.8x>\n",src_file,dst_file,
node_name,user_name,"IS NOT PRINTED",f_stdout,status));
              ERRload_struct (NFM, status,"%s%s%s%s%s%s",src_file,dst_file,node_name,user_name,"IS NOT PRINTED",f_stdout);
              return (status);
	  } 
      unlink (f_stderr);
      unlink (f_stdout);

/* 12/9/92 - KT - Replace 'Stat' with 'stat'
      status = Stat (file_name, &fbuff);
*/
      status = stat (file_name, &fbuff);
      if (status) /* OK */
       {
          status = NFM_E_STAT;
          _NFMdebug ((fname,"Stat Failed : status = <0x%.8x>\n", status));
          ERRload_struct (NFM, status, "%s", file_name);
          return (status);
       }

      *size = fbuff.st_size;

      _NFMdebug ((fname," File Size = <0x%.8x>\n", *size));

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

