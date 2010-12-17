#include "machine.h"

#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

/* Static structure used by  ftp commands only */

static NFMxfer_ftp	NFMxfer_ftp_def = { 1 , 1, 0};

/* Set the parameters which are >= 0 */

 long NFMset_ftp_def(no_of_retries,sleep_time,verify)
	long	no_of_retries,sleep_time,verify;
 {
	char *fname="NFMset_ftp_def";
	_NFMdebug((fname,"Entry: no_of_retries <%d> sleep_time <%d> verify <%d>\n",no_of_retries,sleep_time,verify));
	if(no_of_retries >= 0 ) NFMxfer_ftp_def.no_of_retries = no_of_retries;
	if(sleep_time >= 0 ) NFMxfer_ftp_def.sleep_time = sleep_time;
	if(verify >= 0 ) NFMxfer_ftp_def.verify = verify;
	_NFMdebug((fname,"SUCCESSFUL: <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
 }

 long NFMftp_rename (node_name, user_name, passwd, 
                      src_file, dst_file, machid) /* VAX - IGI */
   char     *node_name, *user_name, *passwd;
   char     *src_file, *dst_file, *machid; /* VAX - IGI */
   {
      char *fname="NFMftp_rename";
      char     f_script [NFM_FILENAME], f_stderr [NFM_FILENAME], f_stdout [NFM_FILENAME];
/* ftp -n "NFM_NODENAME" < "f_script" > "f_stdout" 2> "f_stderr" */
      char shell_str[NFM_NODENAME + 4*NFM_FILENAME + 96];
      char *tmp_str;
      FILE     *infile, *fopen ();
      long     status,size1,no_of_retries,NFMftp_delete();
      char ftp_path[100];
      char *whence();
    

      _NFMdebug((fname,"Nodename <%s> username <%s> password <%s>\n Source file\
 <%s> Dst File <%s> \n",node_name,user_name,"IS NOT PRINTED",src_file,dst_file));

     
/* Delete the dst_file so that rename does not fail */
      status = NFMftp_delete(node_name,user_name,passwd,dst_file, machid); /* VAX - IGI */

      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("FTPnfm1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPnfm2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPnfm3XXXXXXX"));

/* figure out size of tmp_str required
   user <username> <passwd> \nbinary\nrename <src_file> <dst_file>\nquit\n
   malloc it
   use it
   free it */
      size1 = 48 + strlen(user_name) + strlen(passwd) + strlen(src_file) + strlen(dst_file);

      tmp_str = (char *)malloc(size1);
      if(tmp_str == (char *)0)
      {
	 _NFMdebug((fname,"Malloc failed for temporary string. size <%d>:\
status <0x%.8x>\n",size1,NFM_E_MALLOC));
	ERRload_struct(NFM,NFM_E_MALLOC,"%d",size1);
	return(NFM_E_MALLOC);
      }
      sprintf (tmp_str, "user %s %s\nbinary\nrename %s %s\nquit\n",
              user_name, passwd, src_file, dst_file);

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
      sprintf (shell_str, "%s -n %s < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
     /* Removed additional %s - SSRS - 6/12/93 */
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
        sprintf (shell_str, "%s -n %s < %s >> %s 2>> %s",
                ftp_path, f_script, f_stdout, f_stderr);
#else
        /* Removed additional %s. SSRS - 6/12/93 */
        sprintf (shell_str, "%s -n -h %s < %s | grep -v -i user >> %s 2>> %s",
                ftp_path, f_script, f_stdout, f_stderr);
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
              status = NFM_E_FTP_RENAME_FILE;
	      _NFMdebug((fname,"Failure: Rename <%s> to <%s>:Nodename <%s>:\
Username <%s>:\npasswd <%s>:errorfile <%s>:status <0x%.8x>\n",src_file,dst_file,
node_name,user_name,"IS NOT PRINTED",f_stdout,status));
              ERRload_struct (NFM, status,"%s%s%s%s%s%s",src_file,dst_file,node_name,user_name,"IS NOT PRINTED",f_stdout);
              return (status);
	  } 
      unlink (f_stderr);
      unlink (f_stdout);
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }


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

/* figure out size of tmp_str required
   user <username> <passwd> \nbinary\nget <src_file> <file_name>\nquit\n 
   malloc it
   use it
   free it */
      size1 = 48 + strlen(user_name) + strlen(passwd) + strlen(src_file) + strlen(file_name);

      tmp_str = (char *)malloc(size1);
      if(tmp_str == (char *)0)
      {
	 _NFMdebug((fname,"Malloc failed for temporary string. size <%d>:\
status <0x%.8x>\n",size1,NFM_E_MALLOC));
	ERRload_struct(NFM,NFM_E_MALLOC,"%d",size1);
	return(NFM_E_MALLOC);
      }
      sprintf (tmp_str, "user %s %s\nbinary\nget %s %s\nquit\n",
              user_name, passwd, src_file, file_name);

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
      sprintf (shell_str, "%s -n %s  < %s > %s 2> %s",
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
        sprintf (shell_str, "%s -n %s < %s >> %s 2>> %s",
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

 long NFMftp_send (node_name, user_name, passwd, 
                      src_file, dst_file, type, size)
   char     *node_name, *user_name, *passwd;
   char     *src_file, *dst_file;
   char     *type;
   long     *size;
   {
      char *fname="NFMftp_send";
      char     f_script [NFM_FILENAME], f_stderr [NFM_FILENAME], f_stdout [NFM_FILENAME];
/* ftp -n "NFM_NODENAME" < "f_script" > "f_stdout" 2> "f_stderr" */
      char shell_str[NFM_NODENAME + 4*NFM_FILENAME + 96];
      char *tmp_str,f_verify[NFM_FILENAME];
      char file_name[4*NFM_FILENAME];
      FILE     *infile, *fopen ();
      struct   stat  fbuff;
      long     status,size1,no_of_retries,verify_size;
      char     ftp_path[100];
      char     *whence();
    

      _NFMdebug((fname,"Nodename <%s> username <%s> password <%s>\n Source file\
 <%s> Dst File <%s> type <%s> size <%d>\n",node_name,user_name,"IS NOT PRINTED",src_file,dst_file,type,*size));
	
      *size = verify_size  = -2 ;

/* Get the complete name of the src_file */
      status = NFMget_full_name (src_file, file_name);
      if (status != NFM_S_SUCCESS)
       {
          _NFMdebug ((fname,"NFMget_full_name: status = <0x%.8x>\n", status));
          return (status);
       }

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

     
      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("FTPnfm1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPnfm2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPnfm3XXXXXXX"));
      sprintf (f_verify,  "/usr/tmp/%s",  mktemp ("FTPnfm4XXXXXXX"));

/* figure out size of tmp_str required
   user <username> <passwd> \nbinary\nput <file_name> <dst_file>\nquit\n 
   malloc it
   use it
   free it */
      size1 = 48 + strlen(user_name) + strlen(passwd) + strlen(dst_file) + strlen(file_name);

      tmp_str = (char *)malloc(size1);
      if(tmp_str == (char *)0)
      {
	 _NFMdebug((fname,"Malloc failed for temporary string. size <%d>:\
status <0x%.8x>\n",size1,NFM_E_MALLOC));
	ERRload_struct(NFM,NFM_E_MALLOC,"%d",size1);
	return(NFM_E_MALLOC);
      }
      sprintf (tmp_str, "user %s %s\nbinary\nput %s %s\nquit\n",
              user_name, passwd, file_name, dst_file);

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
      /* Additional %s removed. ftp has no '-h' option on SUN.
         SSRS - 4/12/93
      */
      sprintf (shell_str, "%s -n %s < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
      /* sprintf has five '%s' and only four arguments are given.
         Removing additional '%s'. SSRS - 4/12/93
      */
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
        sprintf (shell_str, "%s -n %s < %s >> %s 2>> %s",
                ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
      /* sprintf has five '%s' and only four arguments are given.
         Removing additional '%s'. SSRS - 4/12/93
      */
        sprintf (shell_str, "%s -n -h %s %s < %s | grep -v -i user >> %s 2>> %s",
                ftp_path, node_name, f_script, f_stdout, f_stderr);
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
              status = NFM_E_FTP_SEND_FILE;
	      _NFMdebug((fname,"Failure: Send <%s> to <%s> To :Nodename <%s>:\
Username <%s>:\npasswd <%s>:errorfile <%s>:status <0x%.8x>\n",src_file,dst_file,
node_name,user_name,"IS NOT PRINTED",f_stdout,status));
              ERRload_struct (NFM, status,"%s%s%s%s%s%s",src_file,dst_file,node_name,user_name,"IS NOT PRINTED",f_stdout);
              return (status);
	  } 
      unlink (f_stderr);
      unlink (f_stdout);

/* If verify mode is on */
      if(NFMxfer_ftp_def.verify)
      {
 	status = NFMftp_receive (node_name, user_name, passwd, dst_file, f_verify, type, &verify_size);
/* file f_verify is no longer needed */

	unlink(f_verify);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Verify FTP SEND Failed : status <0x%.8x>\n",status));
		return(status);
	}
	if(verify_size != fbuff.st_size)
	{
		_NFMdebug((fname,"Verify size mismatch size1 <%d>: size2 <%d>\n",
fbuff.st_size,verify_size));
		status = NFM_E_FTP_SEND_FILE_VERIFY_SIZE;
                ERRload_struct (NFM, status,"%s%s%s%s%s%d%d",src_file,dst_file,
node_name,user_name,"IS NOT PRINTED",fbuff.st_size,verify_size);
		return(status);
	}
/* Additional check to see if the files are same can be performed using diff 
   this test is skipped at this time */
      }
      *size = fbuff.st_size;

      _NFMdebug ((fname," File Size = <0x%.8x>\n", *size));

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }



 long NFMftp_delete (node_name, user_name, passwd, 
                      src_file, machid) /* VAX - IGI */
   char     *node_name, *user_name, *passwd;
   char     *src_file, *machid; /* VAX - IGI */
   {
      char *fname="NFMftp_delete";
      char     f_script [NFM_FILENAME], f_stderr [NFM_FILENAME], f_stdout [NFM_FILENAME];
/* ftp -n "NFM_NODENAME" < "f_script" > "f_stdout" 2> "f_stderr" */
      char shell_str[NFM_NODENAME + 4*NFM_FILENAME + 96];
      char *tmp_str;
      FILE     *infile, *fopen ();
      long     status,size1,no_of_retries;
      char     ftp_path[100];
      char     *whence();
    

      _NFMdebug((fname,"Nodename <%s> username <%s> password <%s>\n Source file\
 <%s> \n",node_name,user_name,"IS NOT PRINTED",src_file));

     
      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("FTPnfm1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPnfm2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPnfm3XXXXXXX"));

/* figure out size of tmp_str required
   user <username> <passwd> \nbinary\ndelete <src_file> \nquit\n 
   malloc it
   use it
   free it */
      size1 = 48 + strlen(user_name) + strlen(passwd) + strlen(src_file) ;

      tmp_str = (char *)malloc(size1);
      if(tmp_str == (char *)0)
      {
	 _NFMdebug((fname,"Malloc failed for temporary string. size <%d>:\
status <0x%.8x>\n",size1,NFM_E_MALLOC));
	ERRload_struct(NFM,NFM_E_MALLOC,"%d",size1);
	return(NFM_E_MALLOC);
      }
      if(!strcmp(machid, "VAX")) /* VAX - IGI */
          strcat(src_file, ";");
      sprintf (tmp_str, "user %s %s\nbinary\ndelete %s\nquit\n",
              user_name, passwd, src_file);

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
      sprintf (shell_str, "%s -n %s < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
      /* Removed addtional %s. SSRS - 6/12/93 */
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
      sprintf (shell_str, "%s -n %s < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
      /* Removed addtional %s. SSRS - 6/12/93 */
      sprintf (shell_str, "%s -n -h %s < %s | grep -v -i user > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
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
              status = NFM_E_FTP_DELETE_FILE;
	      _NFMdebug((fname,"Failure: DELETE <%s> :Nodename <%s>:\
Username <%s>:\npasswd <%s>:errorfile <%s>:status <0x%.8x>\n",src_file,
node_name,user_name,"IS NOT PRINTED",f_stdout,status));
              ERRload_struct (NFM, status,"%s%s%s%s%s",src_file,node_name,user_name,"IS NOT PRINTED",f_stdout);
              return (status);
	  } 
      unlink (f_stderr);
      unlink (f_stdout);
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMftp_check_local (node_name, user_name, passwd, 
                      src_file)
   char     *node_name, *user_name, *passwd;
   char     *src_file;
   {
      char *fname="NFMftp_check_local";
      char     f_script [NFM_FILENAME], f_stderr [NFM_FILENAME], f_stdout [NFM_FILENAME];
/* ftp -n "NFM_NODENAME" < "f_script" > "f_stdout" 2> "f_stderr" */
      char shell_str[NFM_NODENAME + 4*NFM_FILENAME + 96];
      char *tmp_str;
      FILE     *infile, *fopen ();
      long     status,size1,no_of_retries;
      char     ftp_path[100];
      char     *whence();
    

      _NFMdebug((fname,"Nodename <%s> username <%s> password <%s>\n Source file\
 <%s> \n",node_name,user_name,"IS NOT PRINTED",src_file));

/* DISABLED DUE TO NON STD FTP ERROR OUTPUT */

      _NFMdebug ((fname,"SUCCESSFUL :File not found status = <0x%.8x>\n", NFM_E_FAILURE));
      return (NFM_E_FAILURE);

     
      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("FTPnfm1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("FTPnfm2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("FTPnfm3XXXXXXX"));

/* figure out size of tmp_str required
   user <username> <passwd> \nbinary\nls <src_file> \nquit\n 
   malloc it
   use it
   free it */
      size1 = 48 + strlen(user_name) + strlen(passwd) + strlen(src_file) ;

      tmp_str = (char *)malloc(size1);
      if(tmp_str == (char *)0)
      {
	 _NFMdebug((fname,"Malloc failed for temporary string. size <%d>:\
status <0x%.8x>\n",size1,NFM_E_MALLOC));
	ERRload_struct(NFM,NFM_E_MALLOC,"%d",size1);
	return(NFM_E_MALLOC);
      }
      sprintf (tmp_str, "user %s %s\nbinary\nls %s\nquit\n",
              user_name, passwd, src_file);

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
      sprintf (shell_str, "%s -n %s < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
      /* Removed addtional %s. SSRS - 6/12/93 */
      sprintf (shell_str, "%s -n -h %s < %s > %s 2> %s",
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
      sprintf (shell_str, "%s -n %s < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
#else
      /* Removed addtional %s. SSRS - 6/12/93 */
      sprintf (shell_str, "%s -n -h %s < %s > %s 2> %s",
               ftp_path, node_name, f_script, f_stdout, f_stderr);
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
              status = NFM_E_FTP_CHECK_LOCAL_FILE;
	      _NFMdebug((fname,"Failure: Check local file <%s> :Nodename <%s>:\
Username <%s>:\npasswd <%s>:errorfile <%s>:status <0x%.8x>\n",src_file,
node_name,user_name,"IS NOT PRINTED",f_stdout,status));

/* MEEILING BRADLEY'S CODE WILL HANDLE THIS ERROR
              ERRload_struct (NFM, status,"%s%s%s%s%s",src_file,node_name,user_name,"IS NOT PRINTED",f_stdout);
*/
              return (status);
	  } 
      unlink (f_stderr);
      unlink (f_stdout);
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }


long NFMftp_rexec ( node_name, user_name, passwd, command_str )
     char *node_name;
     char *user_name;
     char *passwd;
     char *command_str;
{
     
     int            fdp2;
     int            rexec();
     char           *fname = "NFMftp_rexec";
     long           sock;
     struct servent *serv_info;
     struct servent *getservbyname();


     _NFMdebug ((fname, "ENTER..\n"));
     _NFMdebug ((fname, "Node <%s> : User <%s> : Cmd <%s>\n",
					node_name, user_name, command_str));

     serv_info = getservbyname ("exec", "tcp");

     if (serv_info == NULL)
     {
         _NFMdebug ((fname, 
		"Error obtaining server info from network services database"));
         return (NFM_E_FAILURE);
     }
    
     sock = rexec (&node_name, serv_info->s_port, user_name, passwd, 
							command_str, &fdp2); 
     if (sock < 0)
     {
         _NFMdebug ((fname, "rexec failed : cmd_str <%s>\n", command_str));
         return (NFM_E_FAILURE);
     }
     close (sock); 
   
     _NFMdebug ((fname, "EXIT...\n"));
     return (NFM_S_SUCCESS);
} 
