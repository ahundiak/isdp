#include "machine.h"
/* The global variables used in systools will be defined here 
   Hence do not define INCLUDE_EXTERN here */

#include "NFMsysinc.h"

#include "NFMporttypes.h"

NFMsys_buf_status sys_buf_status;

/************************************************************************
*									*	
* Contents:								*	
*		NFMload_user_info()					*
*		NFMset_file_mode()					*
*		NFMget_full_name()					*
*		NFMmk_name()						*
*		NFMmk_unique_mountpoint()				*
*		NFMappend_path_file()					*
*		NFMftp_scan_output()					*
*		NFMftp_scan_output1()					*
*		NFM_mkpath()						*
************************************************************************/



/* Save the user information for future use */

struct NFMuser_info_struct NFMuser_info;

int NFMload_user_info (user_name)
  char  *user_name;
  {
    char *fname="NFMload_user_info ";
    int   status,uid;

    /* the line below was copied here by B.W. 10-18-91 Due to compilation */
         struct  passwd *pswd_ptr;


    _NFMdebug ((fname,"User Name = <%s>\n", user_name));

     if (! strlen (user_name))
      {
        pswd_ptr = getpwuid ((NFM_UID_T)(uid=getuid ()));
        if (! pswd_ptr)
         {
           status = NFM_E_GETPWUID;
	   ERRload_struct(NFM,status,"%d%s",uid,user_name);
	   _NFMdebug((fname,"getpwuid failed for uid <%d>. User_name <%s> \
status <0x%.8x>\n",uid,user_name,NFM_E_GETPWUID));
           return (status);
         }
      }
     else
      {
        pswd_ptr = getpwnam (user_name);
        if (! pswd_ptr)
         {
           status = NFM_E_GETPWNAM;
	   ERRload_struct(NFM,status,"%s",user_name);
	   _NFMdebug((fname,"getpwnam failed for username <%s>: status <0x%.8x>\
\n",user_name,status));
           return (status);
         }
      }

     NFMuser_info.uid = pswd_ptr -> pw_uid;
     NFMuser_info.gid = pswd_ptr -> pw_gid;
     sprintf (NFMuser_info.name, "%s", pswd_ptr -> pw_name);
     sprintf (NFMuser_info.dir,  "%s", pswd_ptr -> pw_dir);

     status = setgid (pswd_ptr -> pw_gid);
     if (status) /* OK */
      {
        status = NFM_E_SETGID;
	ERRload_struct(NFM,status,"%d%d%d%s",pswd_ptr -> pw_gid,errno,pswd_ptr->pw_uid,pswd_ptr->pw_name);
	_NFMdebug((fname,"setgid failed: GID <%d> : UID <%d> : errno <%d>:\
 username <%s> : status <0x%.8x>\n",pswd_ptr->pw_gid, pswd_ptr->pw_uid, errno,
pswd_ptr->pw_name, status));
        return (status);
      }

     status = setuid (pswd_ptr -> pw_uid);
     if (status) /* OK */
      {
        status = NFM_E_SETUID;
	ERRload_struct(NFM,status,"%d%d%d%s",pswd_ptr -> pw_uid,errno,pswd_ptr->pw_gid,pswd_ptr->pw_name);
	_NFMdebug((fname,"setuid failed: GID <%d> : UID <%d> : errno <%d>:\
 username <%s> : status <0x%.8x>\n",pswd_ptr->pw_gid, pswd_ptr->pw_uid, errno,
pswd_ptr->pw_name, status));
        return (status);
      }
     status = chdir (pswd_ptr -> pw_dir);
     if (status) /* OK */
      {
        status = NFM_E_CHDIR;
	ERRload_struct(NFM,status,"%s%d",pswd_ptr->pw_dir,errno);
        _NFMdebug((fname,"chdir failed: DIR <%s> : errno <%d>: status <0x%.8x>\
\n",pswd_ptr->pw_dir,errno,status));
        return (status);
      }

     setpwent();  /* rewind passwd file to the beginning. */ 
     endpwent();  /* close the passwd file. */ 

    _NFMdebug((fname,"Name <%s> dir <%s> Uid <%d> Gid <%d>\n",NFMuser_info.name,
NFMuser_info.dir,NFMuser_info.uid,NFMuser_info.gid));

    _NFMdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

int NFMset_file_mode (filename, file_info)
 char    *filename;
 NFMfile_info  *file_info;
 {
    char *fname="NFMset_file_mode ";
    int     status;
    struct utimbuf times;

    _NFMdebug ((fname," File Name = <%s>\n", filename));
    _NFMdebug ((fname," File Mode = <%d>\n", file_info->mode)); /* PS */

    times.actime  = file_info -> atime; 
    times.modtime = file_info -> mtime; 

     status = utime (filename, &times);
     if (status) /* OK */
      {
        status = NFM_E_UTIME;
	ERRload_struct(NFM,status,"%s%d%d%d",filename,times.actime,times.modtime,errno);
	_NFMdebug((fname,"utime failed. Filename <%s> actime <%d> modtime <%d>\
errno <%d> status <0x%.8x>\n",filename,times.actime,times.modtime,errno,status));
        sys_buf_status.status2 = errno; 
        sys_buf_status.status3 = file_info -> mtime; 
        return (NFM_E_UTIME);
      }

     /* set the mode of the filename to that of the srcfile. */

     status = chmod (filename, file_info -> mode);
     if (status) /* OK */
      {
        status = NFM_E_CHMOD;
	ERRload_struct(NFM,status,"%s%d%d",filename,file_info->mode,errno);
	_NFMdebug((fname,"chmod failed. Filename <%s> mode <%d> errno <%d>\
 status <0x%.8x>\n",filename,file_info->mode,errno,status));
        sys_buf_status.status2 = errno; 
        sys_buf_status.status3 = file_info -> mode; 
        return (NFM_E_CHMOD);
      }

     /* set the uid and gid of the file to be the same as the users. */

     status = chown (filename, (NFM_UID_T)NFMuser_info.uid, (NFM_GID_T)NFMuser_info.gid);
     if (status) /* OK */
      {
        status = NFM_E_CHOWN;
	ERRload_struct(NFM,status,"%s%d%d%d",filename,NFMuser_info.uid,NFMuser_info.gid,errno);
	_NFMdebug((fname,"chown failed. Filename <%s> uid <%d> gid <%d> errno \
<%d> status <0x%.8x>\n",filename,NFMuser_info.uid,NFMuser_info.gid,errno,status));
        sys_buf_status.status2 = errno; 
        sys_buf_status.status3 = NFMuser_info.uid; 
        return (NFM_E_CHOWN);
      }


   _NFMdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
   return (NFM_S_SUCCESS);
 } 


int NFMget_full_name (file_name, full_name)
  char    *file_name;
  char    *full_name;
  {
    char *fname="NFMget_full_name";
    int     status;

    full_name [0] = 0;

    _NFMdebug ((fname,"Entry : File Name = <%s> Full name <%s>\n  ", file_name,full_name));

    if (! strlen (file_name))
     {
       status = NFM_E_NO_FILENAME;
       ERRload_struct(NFM,status,"%s",file_name);
       _NFMdebug((fname,"FIlename <%s> has 0 length . : status <0x%.8x>\n",file_name,status));
       return (status);
     }

    if (file_name [0] == '/')        sprintf (full_name, "%s", file_name);
    else if (file_name [0] == ':')   sprintf (full_name, "%s", file_name);
    else
     {
       sprintf (full_name, "%s/%s", NFMuser_info.dir, file_name);
     }
    _NFMdebug ((fname,"SUCCESSFUL:Full Name = <%s>\n", full_name));

    return (NFM_S_SUCCESS);
  }

int NFMmk_name(name)
	char *name;
/* Path is a caller supplied variable which has atleast 15 bytes to store a
   temporary name generated by system */
{
	long status,tloc,pid;
	char tmp1[48],tmp2[48],*fname="NFMmk_name",*l64a();
        static long add_time = 0;
	_NFMdebug((fname,"Entry: name <%s>\n",name));
        if((status= time(&tloc)) < 0)
	{
		_NFMdebug((fname,"time Call failed: status <%d> errno <%d>\n",status,errno));
                ERRload_struct(NFM,NFM_E_TIME,"%d%d",status,errno);
                return(NFM_E_TIME);
	}
/* Make the time small by removing a constant Base */
	add_time++;
	tloc = tloc - TIME_CONSTANT+add_time;
        pid = getpid();
        strcpy(tmp1,l64a(tloc));
        strcpy(tmp2,l64a(pid));
        sprintf(name,"NF%6.6s%6.6s",tmp1,tmp2);
/* Replace space by '_' and '/' by '-' */
        status=0;
        while(name[status]!='\0')
        {
                 if(name[status]=='/') name[status]='-' ;
                 if(name[status]==' ') name[status]='_' ;
                 status++;
        }
	_NFMdebug((fname,"SUCCESSFUL:Unique Name <%s> status <0x%.8x>\n",name,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
int NFMmk_unique_mountpoint(path)
	char *path;
/* path is a caller supplied variable which has atleast 25 bytes to store a
   temporary path generated by system */
{
	char *fname="NFMmk_unique_mountpoint",tmp[15] ;
	long status,flag;
	struct stat fbuff;
	_NFMdebug((fname,"Entry: Path <%s>\n",path));
	flag=0;
	while(!flag)
	{
/* make a unique name */
		status= NFMmk_name(tmp);
		if(status!=NFM_S_SUCCESS) return(status);
/* make a unique path */
		sprintf(path,"/usr/tmp/%s",tmp);
/* verify file does not exists */

/* 12/8/92 - KT - replace 'Stat' with 'stat'
		status = Stat(path,&fbuff);
*/
		status = stat(path,&fbuff);
		if(status) flag = 1;
	}
	_NFMdebug((fname,"Exit: Path <%s> status <0x%.8x>\n",path,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}


 long NFMappend_path_file (op_sys, path_name, file_name, name)
   char    *op_sys;
   char    *path_name, *file_name, *name;
   {
     char *fname="NFMappend_path_file ";
     int flag = 0;

     name [0] = 0;

     _NFMdebug((fname,"Entry> OPSYS <%s> Path <%s> \n filename <%s> Name <%s>\n",
op_sys,path_name,file_name,name));

          if (! strcmp (op_sys, "CLIX") || ! strcmp (op_sys,"UNIX")) flag = 1;
     else if (! strcmp (op_sys, "VMS"))  flag = 2;
     else if (! strcmp (op_sys, "VM/SP")) flag = 3;
     else       			  flag = 4;

	switch(flag)
	{
		case 1:
     		if ((file_name [0] != '/') && (file_name [0] != ':'))
      		{
        		if (strlen (path_name))
           		sprintf (name, "%s%s%s", path_name, "/", file_name);
        		else
           		sprintf (name, "%s", file_name);
     		}
    		else
       		sprintf (name, "%s", file_name);
			break;
		case 2:
     			if (file_name [0] != '[')
      			{
        			if (strlen (path_name))
           			sprintf (name, "%s%s", path_name,  file_name);
        			else
       				sprintf (name, "%s", file_name);
     			}
    			else
       			sprintf (name, "%s", file_name);
			break;
		case 3:
        		if (strlen (path_name))
           		sprintf (name, "%s%s%s", path_name, ".", file_name);
        		else
           		sprintf (name, "%s", file_name);    
			break;
		case 4:
                default:
        		if (strlen (path_name))
           		sprintf (name, "%s%s", path_name,  file_name);
        		else
           		sprintf (name, "%s", file_name);    
			break;
	}


     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

NFMscan_ftp_output(out_file)
    char *out_file;
{
	char *fname="NFMscan_ftp_output";
	FILE	*fopen(), *out_fptr;
	long	status;
	char	ss[1024], err_code[32], sx[40];
	int	err_no, entry_found;
	int	i,k;

        _NFMdebug((fname,"out_file = <%s>\n ",out_file));

	out_fptr = fopen(out_file,"r");
	if(!out_fptr)
	{
		status = NFM_E_FOPEN;
		_NFMdebug((fname,"Scan Ftp : Open File : filename <%s> : errno\
 <%d>: type <%s>: status = <0x%.8x>\n",out_file,errno,"r",status));
                ERRload_struct (NFM, status, "%s%d%s", out_file,errno,"r");
		return(status);
	}
	while(fgets(ss,1024,out_fptr))
	{
	    entry_found = 0;
	    _NFMdebug((fname,"ss -> %s\n",ss));
	    for(i=0;i<14;i++)
		sx[i] = ss[i];
            sx[14] = '\0';
	    _NFMdebug((fname,"sx -> %s\n",sx));
	    if(!strcmp(sx,"Not connected."))
	    {
		fclose(out_fptr);
		_NFMdebug((fname,"SCAN FTP : ftp Not Connected \n"));
                ERRload_struct (NFM, NFM_E_FAILURE, "%s", "Not Connected");
		return(NFM_E_FAILURE);
	    }
	    if(isdigit(ss[0]) && isdigit(ss[1]) && isdigit(ss[2]))
	    {
   	      k = 2;
	      for(i=3;i<strlen(ss);i++)
	      {
  			if(isdigit(ss[i]))
			{
		 	   k = k + 1;
			}
			else
			{
				break;
			}
          }
	      sx[0] = ss[k+2]; sx[1] = ss[k+3]; 
	      sx[2] = ss[k+4]; sx[3] = ss[k+5]; 
	      sx[4] = ss[k+6];
	      sx[5] = '\0';
	      if(strncmp(sx,"bytes",5))
	      {
	         entry_found = 1;
	      }
	      if(entry_found)
	      {
	    	err_code[0] = 0;
	    	strncpy(err_code,ss,k+1);
		err_code[k+1] = '\0' ;
	    	err_no = atoi(err_code);
	        if(err_no > 350)
		{
			fclose(out_fptr);
			_NFMdebug((fname,"SCAN FTP : Found ftp error  <%d>\n",err_no));
/* LET THE CALLING PROGRAM LOAD AN ERROR
                        ERRload_struct (NFM, NFM_E_FAILURE, "%s", "ftp Error");
*/
			return(NFM_E_FAILURE);
                }
		else if(err_no == 230)
		{
		    k = strlen(ss) - 1;
		    for(i=0;i<10;i++)
		    {
		    	sx[i] = ss[k-10+i]; 
		    }
	      	    sx[10] = '\0';
		   _NFMdebug((fname,"SCAN FTP : sx  <%s>\n",sx));
 		    if(!strcmp(sx, "(ReadOnly)")) 
		    {
			fclose(out_fptr);
			_NFMdebug((fname,"SCAN FTP : ReadOnly error  <%d>\n",err_no));
/* LET THE CALLING PROGRAM LOAD ERROR
                        ERRload_struct (NFM, NFM_E_FAILURE, "%s", "ReadOnly");
*/
			return(NFM_E_FAILURE);
		    }
		}
/*	    	switch(err_no)
     		{
			    case 550:
					fclose(out_fptr);
				    _NFMdebug((fname,"SCAN FTP: Found ftp error:<%d>\n",
                                             err_no));
					return(NFM_E_FAILURE);
					break;
		
	 		    default:
					break;
		     }
*/
	       }
	    }
	}
	fclose(out_fptr);
	_NFMdebug((fname,"SUCCESS <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

NFMscan_ftp_output1(out_file)
    char *out_file;
{
        char *fname="NFMscan_ftp_output1";
	FILE	*fopen(), *out_fptr;
	long	status;
	char	ss[1024], err_code[32], sx[40];
	int	err_no, entry_found;
	int	i,k;

        _NFMdebug((fname,"SCAN FTP1 : out_file = <%s>\n ",out_file));

	out_fptr = fopen(out_file,"r");
	if(!out_fptr)
	{
		status = NFM_E_FOPEN;
		_NFMdebug((fname,"Scan Ftp : Open File : filename <%s> : errno\
 <%d>: type <%s>: status = <0x%.8x>\n",out_file,errno,"r",status));
                ERRload_struct (NFM, status, "%s%d%s", out_file,errno,"r");
		return(status);
	}
	while(fgets(ss,1024,out_fptr))
	{
            _NFMdebug((fname," ss -> %s\n",ss));
	    entry_found = 0;
	    for(i=0;i<14;i++)
		sx[i] = ss[i];
            sx[14] = '\0';
            _NFMdebug((fname," sx -> %s\n",sx));
	    if(!strcmp(sx,"Not connected."))
	    {
		fclose(out_fptr);
		_NFMdebug((fname,"SCAN FTP1 : ftp Not Connected \n"));
                ERRload_struct (NFM, NFM_E_FAILURE, "%s", "Not Connected");
		return(NFM_E_FAILURE);
	    }

/* PS - STATOIL FTP problem. Check for login failed string also */
            if(!strncmp(ss,"Login failed", strlen("Login failed")))
            {
                fclose(out_fptr);
                _NFMdebug((fname,"SCAN FTP1 : Login failed \n"));
                ERRload_struct (NFM, NFM_E_FAILURE, "%s", "Login failed");
                return(NFM_E_FAILURE);
            }

	    if(isdigit(ss[0]) && isdigit(ss[1]) && isdigit(ss[2]))
	    {
   	      k = 2;
	      for(i=3;i<strlen(ss);i++)
	      {
  			if(isdigit(ss[i]))
			{
		 	   k = k + 1;
			}
			else
			{
				break;
			}
          }
	      sx[0] = ss[k+2]; sx[1] = ss[k+3]; 
	      sx[2] = ss[k+4]; sx[3] = ss[k+5]; 
	      sx[4] = ss[k+6];
	      sx[5] = '\0';
	      if(strncmp(sx,"bytes",5))
	      {
	         entry_found = 1;
	      }
	      if(entry_found)
	      {
	    	err_code[0] = 0;
	    	strncpy(err_code,ss,k+1);
		err_code[k+1] = '\0' ;
	    	err_no = atoi(err_code);
	        if(err_no > 350)
		{
			fclose(out_fptr);
			_NFMdebug((fname,"SCAN FTP1 : Found ftp error  <%d>\n",err_no));
/* LET THE CALLING PROGRAM LOAD ERROR
                        ERRload_struct (NFM, NFM_E_FAILURE, "%s", "ftp Error");
*/
			return(NFM_E_FAILURE);
                }

/*	    	switch(err_no)
     		{
			    case 550:
					fclose(out_fptr);
				    _NFMdebug((fname,"SCAN FTP: Found ftp error:<%d>\n",
                                             err_no));
					return(NFM_E_FAILURE);
					break;
		
	 		    default:
					break;
		     }
*/
	       }
	    }
	}
	fclose(out_fptr);
    _NFMdebug((fname,"SUCCESS  <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}



/* 12/8/92 - KT - SUN Port - SUN compiler doesn't like this. */
/* HP PORT-IGI- 10 Jun 1994 */
#if ( defined( OS_CLIX) || defined (OS_HPUX))
int NFM_mkpath(char *path, mode_t mode) 
/* char *path; 		/#* path can be atmost char(MAX_PATH_SIZE-1) *#/ 
mode_t mode;
*/
#endif


#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX))
int NFM_mkpath(path, mode)

char *path; 		/* path can be atmost char(MAX_PATH_SIZE-1) */ 
mode_t mode;
#endif

{
	char temp_path[MAX_PATH_SIZE],temp_path2[MAX_PATH_SIZE];
	char work_path[MAX_PATH_SIZE];
	int path_size;
	int status,length;
	char *last_slash;
	char *nodes[MAX_DIRS];
	int node_index,index,depth;
	char *fname = "NFM_mkpath";

	struct passwd *password_entry;

/* Commented out by B.W. 10-18-91 due to compiler giving errors on this 
	struct passwd *getpwuid();
*/
	int user_id,group_id;

	_NFMdebug((fname,"Entry : Path <%s>\n",path));
	length = strlen(path);
	if(length >= MAX_PATH_SIZE)
	{
		_NFMdebug((fname,"Path is too long. Maximum allowable path \
length <%d>: Actual path length <%d>\nPath <%s>\n",MAX_PATH_SIZE,length,path));
		status = NFM_E_PATH_TOO_LONG;
		ERRload_struct(NFM,status,"%d%d%s",MAX_PATH_SIZE,length,path);
		return(status);
	}


	strncpy(work_path,path,MAX_PATH_SIZE-1);
	work_path[MAX_PATH_SIZE-1] = '\0';
	
	password_entry = getpwuid(NFMuser_info.uid);
	if(password_entry == NULL)
        {
                status = NFM_E_GETPWNAM;
                _NFMdebug((fname,"Bad user id %d, status: <0x%.8x>\n",NFMuser_info.uid,status));
		ERRload_struct(NFM,status,"%d",NFMuser_info.uid);

                return(status);
        }	
	user_id = password_entry->pw_uid;
	group_id = password_entry->pw_gid; 

	path_size = strlen(work_path);
	if(work_path[path_size] == '/')	/* get rid of / if it is the last*/
		work_path[path_size] = '\0'; /* character of the path name */

	last_slash = strrchr(work_path,'/'); /* get rid of the file name at   */
	last_slash[0] = '\0';		/* the end of the path name 	 */

       	if (work_path[0] == 0)
		return(NFM_S_SUCCESS); 

	strcpy(temp_path,work_path);
	depth = 0;
	while(NFM_mkdir(temp_path,user_id,group_id,mode)== NFM_E_MKDIR)
	{
		if(errno == EIO)
		{
		 status = NFM_E_MKDIR_IO;
		 _NFMdebug((fname,"mkdir <%s> an I/O error occured while accessing the file system,status:<0x%.8x>\n",temp_path,status)); 
		 ERRload_struct(NFM,status,"%s",temp_path); 
			return(status);
		}
		else if(errno == ENOSPC)
		{
		 status = NFM_E_MKDIR_FULL;
		 _NFMdebug((fname,"mkdir <%s> device full/can't extend directory,status:<0x%.8x>\n",temp_path,status));  
		 ERRload_struct(NFM,status,"%s",temp_path);  
			return(status);
		}
		else if(errno == ENOTDIR)
		{
		 status = NFM_E_MKDIR_COMPONENT;
		 _NFMdebug((fname,"mkdir <%s> a component of the path is not a directory,status:<0x%.8x>\n",temp_path,status)); 
		 ERRload_struct(NFM,status,"%s",temp_path); 
		 	return(status);
		}
		else if(errno == EEXIST)
		{
		 _NFMdebug((fname,"mkdir <%s> already exists\n",temp_path)); 
			break;
		}
		else if(errno != ENOENT)
		{
		 status = NFM_E_MKDIR;
		_NFMdebug((fname,"error creating directory %s,status:<0x%.8x>\n",temp_path,status)); 
		ERRload_struct(NFM,status,"%s",temp_path); 
			return(status);	
		}
		depth++;
		last_slash = strrchr(temp_path,'/');
		last_slash[0] = '\0';
	}
	status = NFM_S_SUCCESS;	
	if(depth == 0)
	{
	        _NFMdebug((fname,"SUCCESSFUL ...,status:<0x%.8x>\n",status)); 
		return(NFM_S_SUCCESS);
	}

	strcpy(temp_path,work_path);
	nodes[0] = strtok(temp_path,"/");/* First token; 	and	 */
	node_index = 1;			/* Rest of the tokens to follow  */
	while((nodes[node_index] = strtok(NULL,"/")) && (node_index < 20))
	{
		node_index++;	
	}

	if(node_index == 20)
	{
	 status = NFM_E_MKDIR_OVERFLOW;
	 _NFMdebug((fname,"Number of subdirectories in the path exceeded 20,status:<0x%.8x>\n",status)); 
	 ERRload_struct(NFM,status,"%s",work_path); 
		return(status);

	}
	
	strcpy(temp_path2,work_path);
	for(index=0;index<depth;index++)
	{
		last_slash = strrchr(temp_path2,'/');
		last_slash[0] ='\0';
	}
	for(index=(node_index-depth);index <=node_index;index++)
	{
    	_NFMdebug((fname,"mkdir --> %s, %d, %d\n",temp_path2,user_id,group_id)); 
		NFM_mkdir(temp_path2,user_id,group_id, mode);
		strcat(temp_path2,"/");
		strcat(temp_path2,nodes[index]);
	}
	status = NFM_S_SUCCESS;
	_NFMdebug((fname,"SUCCESSFUL ...,status:<0x%.8x>\n",status));
	return(status);
}

/* 12/8/92 - KT - SUN Port - SUN compiler doesn't like this. */
/* HP PORT-IGI- 10 Jun 1994 */
#if  ( defined( OS_CLIX) || defined (OS_HPUX))
int NFM_mkdir(char *path,int user_id,int group_id, mode_t mode)
/*
char *path;          /#* Path should be char(MAX_PATH_SIZE-1) atmost*#/
int user_id,group_id; 
mode_t mode; 
*/
#endif

#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX))
int NFM_mkdir(path, user_id, group_id, mode)

char *path;          /* Path should be char(MAX_PATH_SIZE-1) atmost */
int user_id,group_id; 
mode_t mode; 
#endif

{
	int status;
	struct stat stat_buff;
	char *fname="NFM_mkdir";
	_NFMdebug((fname,"Entry: Path <%s>: User_ID <%d>:group_id <%d>: Mode <%d>\n",path, user_id,group_id, mode));


 	status = stat(path, &stat_buff);
	if(status==0)
	{
		_NFMdebug((fname,"Path <%s> already exists, status <0x%.8x>\n",
	  	           path, NFM_S_SUCCESS));
		return(NFM_S_SUCCESS);
	}
	status = mkdir(path,mode);
	
	if(status==0)
	{
		chown(path,(NFM_UID_T)user_id,(NFM_GID_T)group_id);
		_NFMdebug((fname,"SUCCESSFUL:status <0x%.8x>\n",NFM_S_SUCCESS));
		return(NFM_S_SUCCESS);
	}
	else
		return(NFM_E_MKDIR);
}
