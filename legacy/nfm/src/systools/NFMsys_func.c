#include "machine.h"
#define INCLUDE_EXTERN  1

#include "NFMporttypes.h"

#include <signal.h>

#include "NFMsysinc.h"
/************************************************************************
*									*	
* Contents:	NFMln()							*
*		NFMcp()							*
*		NFMunln()						*
*		NFMchmod()						*
*		NFMmkdir()						*
*		NFMsystem()						*
*		NFMsystem2()						*
*		NFMsystem_imm()						*
*		NFMmalloc()						*
*		pw()							*
************************************************************************/


/* Generate a  link */

int NFMln(path1,path2)
	char *path1;
	char *path2;
{
	char *fname="NFMln";
	char tmp[TEMP_SIZE] ;
	long status;
	_NFMdebug((fname,"Entry: path1 <%s> path2 <%s>\n",path1,path2));
	sprintf(tmp,"ln -s %s %s",path1,path2);
	status = NFMsystem(tmp);
/* CANNOT CREATE SYMBOLIC LINK ACROSS FILE SYSTEMS  USING THIS FUNCTION
        status = link (path1,path2);
*/
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Link failed for path1 <%s> path2 <%s>: errno <%d>\n",
path1,path2,errno));
		ERRload_struct(NFM,NFM_E_LINK,"%s%s%d",path1,path2,errno);
		return(NFM_E_LINK);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

int NFMcp(path1,path2)
	char *path1;
	char *path2;
{
	char *fname="NFMcp";
	char tmp[TEMP_SIZE] ;
	long status;
	_NFMdebug((fname,"Entry: path1 <%s> path2 <%s>\n",path1,path2));
	sprintf(tmp,"/bin/cp %s %s",path1,path2);
	status = NFMsystem(tmp);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Copy failed for path1 <%s> path2 <%s>: errno <%d>\n",
path1,path2,errno));
		ERRload_struct(NFM,NFM_E_COPY,"%s%s%d",path1,path2,errno);
		return(NFM_E_COPY);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}



int NFMunln(path)
	char *path;
{
	char *fname="NFMunln";
	long status;
	_NFMdebug((fname,"Entry: path <%s> \n",path));
	status = unlink(path);
	if(status)
	{
		_NFMdebug((fname,"Unlink failed for path <%s> : errno <%d>\n",
path,errno));
		ERRload_struct(NFM,NFM_E_UNLINK,"%s%d",path,errno);
		return(NFM_E_UNLINK);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

int NFMchmod(path,mode)
	char *path;
	int mode;
{
	char *fname="NFMchmod";
	long status;
	_NFMdebug((fname,"Entry: path <%s> mode <%d> \n",path,mode));
	status = chmod(path,mode);
	if(status)
	{
		_NFMdebug((fname,"Chmod failed for path <%s> mode <%d>: errno <%d>\n",
path,mode,errno));
		ERRload_struct(NFM,NFM_E_CHMOD,"%s%d%d",path,mode,errno);
		return(NFM_E_CHMOD);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

int NFMmkdir(path,mode)
	char *path;
	int mode;
{
	char *fname="NFMmkdir";
	long status;
	_NFMdebug((fname,"Entry: path <%s> mode <%d> \n",path,mode));
	status = mkdir(path,(NFM_MODE_T)mode);
	if(status)
	{
		_NFMdebug((fname,"MKDIR failed for path <%s> mode <%d>: errno <%d>\n",
path,mode,errno));
		ERRload_struct(NFM,NFM_E_MKDIR_FAIL,"%s%d%d",path,mode,errno);
		return(NFM_E_MKDIR_FAIL);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}




int NFMsystem(shell_str)
	char *shell_str;
{
	char *fname="NFMsystem";
	long status, length ;
        char tmp[25],tmp2[15];
	char *sys_str;
	_NFMdebug((fname,"Entry: shell_str <%s> \n",shell_str));
	length = strlen(shell_str) + 50;
	sys_str = (char *) malloc(length);
	if(sys_str == (char *)0)
	{
		_NFMdebug((fname,"Malloc failed for string size <%d>: status <0x%.8x>\n",length,NFM_E_MALLOC));
		ERRload_struct(NFM,NFM_E_MALLOC,"%d",length);
		return(NFM_E_MALLOC);
	}
	strcpy(tmp2,"NFMsyst1XXXXXX");
	mktemp(tmp2);
	sprintf(tmp,"/usr/tmp/%s",tmp2);
	sprintf(sys_str,"%s > %s 2>&1",shell_str,tmp);
        /* signal call added. Otherwise system is sometimes resulting in error
           because of improper SIGCHLD handling. SSRS - 5 Jan 94 */
        signal(SIGCHLD, SIG_DFL);
	status = system(sys_str);
	if(status)
	{
		_NFMdebug((fname,"System  failed for shell_str <%s> : \
errno <%d> status <%d>:Error_file <%s>\n", shell_str,errno,status,tmp));
		ERRload_struct(NFM,NFM_E_SYSTEM,"%s%d%d%s",shell_str,errno,status,tmp);
		free(sys_str);
		return(NFM_E_SYSTEM);
	}
	free(sys_str);
	unlink(tmp);
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
int NFMsystem2(shell_str, error_file)
	char *shell_str, *error_file;
{
	char *fname="NFMsystem";
	long status, length ;
        char tmp[25],tmp2[15];
	char *sys_str;
	_NFMdebug((fname,"Entry: shell_str <%s> \n",shell_str));
	length = strlen(shell_str) + 50;
	sys_str = (char *) malloc(length);
	if(sys_str == (char *)0)
	{
		_NFMdebug((fname,"Malloc failed for string size <%d>: status <0x%.8x>\n",length,NFM_E_MALLOC));
		ERRload_struct(NFM,NFM_E_MALLOC,"%d",length);
		return(NFM_E_MALLOC);
	}
	strcpy(tmp2,"NFMsyst1XXXXXX");
	mktemp(tmp2);
	sprintf(tmp,"/usr/tmp/%s",tmp2);
	sprintf(sys_str,"%s > %s 2>&1",shell_str,tmp);
	status = system(sys_str);
	if(status)
	{
		_NFMdebug((fname,"System  failed for shell_str <%s> : \
errno <%d> status <%d>:Error_file <%s>\n", shell_str,errno,status,tmp));
		ERRload_struct(NFM,NFM_E_SYSTEM,"%s%d%d%s",shell_str,errno,status,tmp);
		free(sys_str);
		strcpy(error_file, tmp);
		return(NFM_E_SYSTEM);
	}
	free(sys_str);
	unlink(tmp);
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

int NFMsystem_imm(shell_str)
	char *shell_str;
{
	char *fname="NFMsystem_imm";
	long status ;
	_NFMdebug((fname,"Entry: shell_str <%s> \n",shell_str));
	status = system(shell_str);
	if(status)
	{
		_NFMdebug((fname,"System  failed for shell_str <%s> : \
errno <%d> status <%d>\n", shell_str,errno,status));
		ERRload_struct(NFM,NFM_E_SYSTEM,"%s%d%d%s",shell_str,errno,status,"UNKNOWN");
		return(NFM_E_SYSTEM);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}


int NFMmalloc(buf_ptr, size , malloced_size)
	char **buf_ptr;
	long size, *malloced_size;
{
	char *fname="NFMmalloc";
	long status,new_size,flag;
	_NFMdebug((fname,"Entry: buf_ptr <%x> size <%d> malloced_size ptr <%x>\
 \n",buf_ptr,size,malloced_size));
    	if(size == 0)	return(NFM_I_NULL_MALLOC_SIZE);
        *malloced_size = flag = 0;
	new_size = size;
	
	while(!flag)
	{
		if(new_size <=0 )
		{
			status = NFM_E_BAD_MALLOC_SIZE;
			_NFMdebug((fname,"Allocation size is bad <%d>\n",new_size));
			ERRload_struct(NFM,status,"%d",new_size);
			return(status);
		}
		*buf_ptr = (char *)malloc(new_size);
		if(*buf_ptr == (char *)0)
		{
			_NFMdebug((fname,"Allocation failed for <%d> trying <%d>\n",new_size,new_size/2));
			new_size = new_size/2;
		}
		else
		{
			flag = 1;
			*malloced_size = new_size;
		}
		
	}

	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}






/* Old function? I dont know where it is used */
int pw (x)          /*  Math function to find a power of 2  */
  int x;
  {
     int i, j;

     for (i = 0, j = 1; i < x; ++i)
       j *= 2;
       return (j);
  }

