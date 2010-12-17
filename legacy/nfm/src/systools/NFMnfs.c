#include "machine.h"
/************************************************************************
*									*
* Contents:								*
*		NFMnfs_file_transfer()					*
*		NFMnfs_file_remove()					*
*		NFMnfs_mount()						*
*		NFMnfs_umount()						*
*		NFMget_mount_point()					*
************************************************************************/

/************************************************************************
*                                                                       *
* 12/17/92 - KT - SUN Port - Changed 'Stat' to 'stat'                   *
*                                                                       *
************************************************************************/

#define INCLUDE_EXTERN  1

#include "NFMsysinc.h"

int NFMnfs_file_transfer (local_nodename,nodename,resource,cifilename,cofilename,cofilepath,mountpoint,lfm_check)
	char *local_nodename ;
	char *nodename,*resource,*cifilename,*cofilename,*cofilepath,*mountpoint;
	long lfm_check;
{
	char *fname="NFMnfs_file_transfer",tmp[TEMP_SIZE],tmp2[TEMP_SIZE],tmp3[TEMP_SIZE];
        char source[TEMP_SIZE];
	long status,flag,old_copy_flag,line_num;
	struct stat fbuff;
	_NFMdebug((fname,"Entry: local_nodename <%s> nodename <%s> resource <%s> cifilename <%s>\n\
cofilename <%s> cofilepath <%s> mountpoint <%s> lfm_check <%d>\n",
local_nodename,nodename,resource,cifilename, cofilename,cofilepath,mountpoint,lfm_check));
	old_copy_flag = 0;
/* cofilepath/cofilename EXIST ? */
/* If lfm_check is 0 do not perform this check */
	sprintf(tmp2,"%s/%s",cofilepath,cofilename);
	if(lfm_check)
	{
		status=stat(tmp2,&fbuff);
/* YES  ABORT WITH ERROR */
		if(!status)
		{
                _NFMdebug((fname,"Check out filename <%s> already exists in\
check out file directory <%s>\n. NFS Operations Aborted\n",cofilename,cofilepath));
		ERRload_struct(NFM,NFM_E_COFILE_EXISTS,"%s%s%s",cofilename,cofilepath,local_nodename);
		return(NFM_E_COFILE_EXISTS);
		}
	}
/* NO cofilepath EXISTS ? */
	status=stat(cofilepath,&fbuff);
	if(status)
	{
		_NFMdebug((fname,"Check out location directory <%s> does not exists. status <%d> errno <%d>\n",cofilepath,status,errno));
		ERRload_struct(NFM,NFM_E_BAD_COPATH,"%s%s",cofilepath,local_nodename);
/* Call NFM_mkpath and try to generate the path */
		status = NFM_mkpath(tmp2,00777);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"Unable to mkpath for <%s> errno <%d>:\
status <0x%.8x>\n",tmp2,errno,status));
/* NFM_mkpath will LOAD APPROPRIATE ERROR 
**********************	ERRload_struct(NFM,NFM_E_MKPATH,"%s%d",tmp2,errno);*****
*/
			return(status);
		}
	}

/* MOUNTPOINT GIVEN ? */
	if ((strlen(mountpoint))> 0 )
	{
		flag = 1 ;
/* YES   MOUNTPOINT EXIST ? */
		status = stat(mountpoint,&fbuff);
		if(status)
		{
			_NFMdebug((fname,"Mountpoint does not exist mountpoint\
<%s> errno <%d>\n",mountpoint,errno));
			ERRload_struct(NFM,NFM_E_INVALID_MOUNTPOINT,"%s%s",mountpoint,local_nodename);
			return(NFM_E_INVALID_MOUNTPOINT);
		}
	}
	else
	{
/* Mount point not given */
		flag = 2 ;
/* is nodename and resource mounted ?? */
		if((status = NFMget_mount_point(nodename,resource,mountpoint))==NFM_S_SUCCESS)
			if((status=stat(mountpoint,&fbuff))== 0 ) 
			{
/* does the retrieved mountpoint still exist ?? */
/*#### DONE LATER if yes is it a directory */
				flag = 3 ;
				_NFMdebug((fname,"Old mountpoint <%s> exists \
for nodename <%s> resource <%s>\nUsing old mountpoint ...",mountpoint,nodename,resource));
			}

		

		if(flag == 2)
		{
		 status = NFMnfs_mount(mountpoint,nodename,resource,"soft");
		 if(status != NFM_S_SUCCESS)
		 {
			_NFMdebug((fname,"Failed to perform NFS mount for \
nodename <%s> resource <%s>\n  at mountpoint <%s> on node <%s> \n",
nodename,resource,mountpoint,local_nodename));
			return(status);
		 }
                }
		status = stat(mountpoint,&fbuff);
		if(status)
		{
			_NFMdebug((fname,"Mountpoint does not exist mountpoint\
<%s> errno <%d>\n",mountpoint,errno));
			ERRload_struct(NFM,NFM_E_INVALID_MOUNTPOINT,"%s%s",mountpoint,local_nodename);
			return(NFM_E_INVALID_MOUNTPOINT);
		}
	}
/* mountpoint/cifilename EXISTS ? */
	sprintf(tmp,"%s/%s",mountpoint,cifilename);
	status = stat(tmp,&fbuff);
	if(status)
	{
		_NFMdebug((fname,"Checked in filename <%s> does not exist at mountpoint\
<%s> errno <%d>\n",cifilename,mountpoint,errno));
		if(flag == 2)
			 NFMnfs_umount(mountpoint);
		ERRload_struct(NFM,NFM_E_NO_CIFILE_AT_MOUNT,"%s%s%s%s%s",cifilename,mountpoint,resource,nodename,local_nodename);
		return(NFM_E_NO_CIFILE_AT_MOUNT);
	}
/* Check to see if old copy is nfsed copy or not. If lfm_check = 0 then an
   existing file will be destroyed by the new link. If lfm_check was NON zero
   checking for local file is not required. Also if flag is = 2 it means
   that a fresh mountpoint was created, hence checking for an existing
   nfsed cofilename is not required  */
/*  Link mountpoint/cifilename to cofilepath/cofilename */ 
	if(!lfm_check== 0 && flag != 2)
	{
		status=stat(tmp2,&fbuff);
		if(!status)
		{
                _NFMdebug((fname,"Check out filename <%s> already exists in\
check out file directory <%s>\n. Figure out if it was nfsed.\n",cofilename,cofilepath));
		status = NFMis_nfs_copy(mountpoint,tmp2,source);
			if(status == NFM_S_SUCCESS)
			{
				status = NFMunln(tmp2);
				if(status != NFM_S_SUCCESS)
				{
				_NFMdebug((fname,"Unable to unlink file <%s>\
This needs to be performed so that\n a new link can be established to reflect\
a new copy \n", tmp2));
				return(status);
				}
				old_copy_flag = 1;
			}
		}
	}

	status= NFMln(tmp,tmp2);
	if(status!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Unable to link file1 <%s> to file2 <%s>\n",
tmp,tmp2));
		if(flag == 2)
			 NFMnfs_umount(mountpoint);
		if(old_copy_flag )
			 NFMln(source,tmp2);
		return(status);
	}
	strcat(tmp," ");
	strcat(tmp,tmp2);
	strcat(tmp,"\n");
/* Check if the file entry exists in the NFMNFSLINKS FILE 
   IF SO DELETE IT */
	if(!old_copy_flag) status= NFMcheck_str_entry_in_file(tmp2,"",NFMNFSLINKS,0, (int *)&line_num,tmp3);
	else status = NFM_S_SUCCESS ;
	if(status == NFM_S_SUCCESS)
	{
		status = NFMdelete_str_entry_from_file(tmp2,NFMNFSLINKS,0);
		if(status!=NFM_S_SUCCESS)
		{
		_NFMdebug((fname,"Unable to delete string <%s> from file <%s>\n",
tmp2,NFMNFSLINKS));
			NFMunln(tmp2);
			if(flag == 2)
			 NFMnfs_umount(mountpoint);
 			if(old_copy_flag)
			NFMln(source,tmp2);
			return(status);
		}
	}
	status=NFMappend_str_to_file(tmp,NFMNFSLINKS);
	if(status!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Unable to add string <%s> to file <%s>\n",
NFMNFSLINKS,tmp));
		NFMunln(tmp2);
		if(flag == 2)
			 NFMnfs_umount(mountpoint);
		if(old_copy_flag )
		{
			 NFMln(source,tmp2);
			 sprintf(tmp,"%s %s\n",source,tmp2);
			 NFMappend_str_to_file(tmp,NFMNFSLINKS);
		}
		return(status);
	}
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);

}
int NFMnfs_file_remove (local_nodename,nodename,resource,cifilename,cofilename,cofilepath,mountpoint, umount_flag)
	char *local_nodename ;
	char *nodename,*resource,*cifilename,*cofilename,*cofilepath,*mountpoint;
	long umount_flag;
{
	char *fname="NFMnfs_file_remove",tmp[TEMP_SIZE],tmp2[TEMP_SIZE];
	long status,line_num;
	struct stat fbuff;
        char temp_str[TEMP_SIZE];
	_NFMdebug((fname,"Entry: local_nodename <%s> nodename <%s> resource <%s> cifilename <%s>\n\
cofilename <%s> cofilepath <%s> mountpoint <%s>\n",local_nodename,nodename,resource,cifilename,
cofilename,cofilepath,mountpoint));
/*  cofilepath EXISTS ? */
        status=stat(cofilepath,&fbuff);
        if(status)
        {
                _NFMdebug((fname,"Check out location directory <%s> does not exists. status <%d> errno <%d>\n",cofilepath,status,errno));
                ERRload_struct(NFM,NFM_E_BAD_COPATH,"%s%s",cofilepath,local_nodename);
                return(NFM_E_BAD_COPATH);
        }


/* cofilepath/cofilename EXIST ? */
	sprintf(tmp2,"%s/%s",cofilepath,cofilename);
	status=stat(tmp2,&fbuff);
/* YES  ABORT WITH ERROR */
	if(status)
	{
		_NFMdebug((fname,"Check out filename <%s> does not exists. status <%d> errno <%d>\n",tmp,status,errno));
		ERRload_struct(NFM,NFM_E_NO_COFILE,"%s%s%s",cofilename,cofilepath,local_nodename);
		return(NFM_E_NO_COFILE);
	}

/* MOUNTPOINT GIVEN ? */

      if (umount_flag > 0 )
      {
	if ((strlen(mountpoint))> 0 )
	{
/* YES   MOUNTPOINT EXIST ? */
		status = stat(mountpoint,&fbuff);
		if(status)
		{
			_NFMdebug((fname,"Mountpoint does not exist mountpoint\
<%s> errno <%d>\n",mountpoint,errno));
			ERRload_struct(NFM,NFM_E_INVALID_MOUNTPOINT,"%s%s",mountpoint,local_nodename);
			return(NFM_E_INVALID_MOUNTPOINT);
		}
	}
	else
	{
		if((status=NFMget_mount_point(nodename,resource,mountpoint))==NFM_S_SUCCESS)
		{
		  status = stat(mountpoint,&fbuff);
		  if(status)
		  {
			_NFMdebug((fname,"Mountpoint does not exist mountpoint\
<%s> errno <%d>\n",mountpoint,errno));
			ERRload_struct(NFM,NFM_E_INVALID_MOUNTPOINT,"%s%s",mountpoint,local_nodename);
			return(NFM_E_INVALID_MOUNTPOINT);
		  }
		}
		else
		{
		 _NFMdebug((fname,"Mountpoint is NULL\n"));
		 ERRload_struct(NFM,NFM_E_INVALID_MOUNTPOINT,"%s%s",mountpoint,local_nodename);
		 return(NFM_E_INVALID_MOUNTPOINT);
		}
	}
      }
/*  Check if the cofilename entry exists in the boot up file */
	status= NFMcheck_str_entry_in_file(tmp2,"",NFMNFSLINKS,0, (int *)&line_num,temp_str);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Filename <%s> was not an NFSED FILE status <0x%.8x>\n",tmp2,status));
		return(NFM_S_SUCCESS);
	}
/*  Unlink  cofilepath/cofilename */ 
	status= NFMunln(tmp2);
	if(status!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Unable to unlink file <%s> \n",
tmp2));
		return(status);
	}
	status=NFMdelete_str_entry_from_file(tmp2,NFMNFSLINKS,0);
	if(status!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Unable to delete string <%s> from file <%s>\n",
tmp2,NFMNFSLINKS));
		return(status);
	}


/* Check if the mountpoint is in use for any other file */
      if(umount_flag > 0 )
      {
	status= NFMcheck_str_entry_in_file(mountpoint,"",NFMNFSLINKS,0, (int *)&line_num,temp_str);
	if(status == NFM_I_NOT_PRESENT )
	{
/* Unmount the mountpoint and delete entry from NFMNFSTABS */
		status=NFMnfs_umount(mountpoint);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"Failed to NFS umount <%s> errno <%d>\n",
mountpoint, errno));
			return(status);
		}
	}
	else if (status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"CHeck entry <%s> in file <%s> Failed\n",mountpoint,NFMNFSLINKS));
			return(status);
	}
       }
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}




/* /usr/bin/npmount -r -f NFS,<options> <nodename>:<resource> <mountpoint> */
int NFMnfs_mount(mountpoint,nodename,resource,options)
	char *mountpoint,*nodename,*resource,*options ;

/* Caller supplies the mountpoint buffer ( ATleast  24 bytes long 
   The program generates a unique mountpoint and returns it to the
   caller. 

   The nodename is the name of the remote machine.

   The options is a character buffer. If the buffer is null no options will
   be used otherwise the buffer must contain options separated by commas
   e.g.
   *options="soft,nosuid"   or "soft" or "", or "soft,nosuid,bg,rsize=10"
*/

{
	long status;
        char tmp[TEMP_SIZE];
	char *fname="NFMnfs_mount";
	_NFMdebug((fname,"Entry:mountpoint <%s> nodename <%s> resource <%s>\n\
options <%x>\n",mountpoint,nodename,resource,options));
       
/* create a unique mount point */
	status = NFMmk_unique_mountpoint(mountpoint);
       	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to create unique mountpoint: status <0x%.8x>\n",status));
		return(status);
	}
        status=NFMmkdir(mountpoint,0777);
        if(status!=NFM_S_SUCCESS)
        {
                _NFMdebug((fname,"Failed to mkdir <%s>\n",mountpoint));
                return(status);
        }

/* generate the mount command */

	if(options != (char *)0 && ((strlen(options) > 0))) 
		sprintf(tmp,"/usr/bin/npmount -r -f NFS,%s %s:%s %s",options,nodename,
resource,mountpoint);
	else
		sprintf(tmp,"/usr/bin/npmount -r -f NFS %s:%s %s",nodename,
resource,mountpoint);
/* Call NFMsystem to complete the mount */
	status = NFMsystem(tmp);
        if(status != NFM_S_SUCCESS)
	{
		unlink(mountpoint);	
		_NFMdebug((fname,"Failed to mount <%s:%s> at <%s>: status <0x%.8x>\n",nodename,resource,mountpoint,status));
		return(status);
	}


	sprintf(tmp,"%s %s %s %s\n",resource,mountpoint,nodename,options);
/* If successful make entries in the BOOT file */
	status = NFMappend_str_to_file(tmp,NFMNFSTABS);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to enter string <%s> in file <%s>: status <0x%.8x>\n",tmp,NFMNFSTABS,status));
/* Undo the mount and return */
		NFMnfs_umount(mountpoint);
		unlink(mountpoint);	
		return(status);
	}

	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}



int NFMnfs_umount(mountpoint)
	char *mountpoint;
{
	char *fname="NFMnfs_umount";
	long status ;
	struct stat fbuff ;
	struct utsname name ;
        char tmp[TEMP_SIZE];
	_NFMdebug((fname,"Entry: mountpoint <%s> \n",mountpoint));
/* Check if the mountpoint exists */
	status = stat(mountpoint,&fbuff);
	if(status)
	{
		_NFMdebug((fname,"Mountpoint <%s> does not exist: status <%d>\
errno <%d>\n",mountpoint,status,errno));
		uname(&name);
		ERRload_struct(NFM,NFM_E_INVALID_MOUNTPOINT,"%s%s",mountpoint,name.nodename);
		return(NFM_E_INVALID_MOUNTPOINT);
	}
	sprintf(tmp,"/usr/bin/npumount %s",mountpoint);
/* Call NFMsystem to complete the umount */
	status = NFMsystem(tmp);
        if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to umount  <%s>: status <0x%.8x>\n",mountpoint,status));
		return(status);
	}
/* If successful delete entries in the BOOT file */
	status = NFMdelete_str_entry_from_file(mountpoint,NFMNFSTABS,0);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to delete entry <%s> in file <%s>: status <0x%.8x>\n",mountpoint,NFMNFSTABS,status));
		return(status);
	}
	sprintf(tmp,"rmdir %s",mountpoint);
/* Call NFMsystem to complete the umount */
	status = NFMsystem(tmp);
        if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to umount  <%s>: status <0x%.8x>\n",mountpoint,status));
		return(status);
	}

	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

int NFMget_mount_point(nodename,resource,mountpoint)
	char *nodename,*resource,*mountpoint;
{
	long status,line_num;
	char *fname="NFMget_mount_point" ;
	char *line,tmp[TEMP_SIZE];
	
	_NFMdebug((fname,"Entry: nodename <%s> resource <%s> mountpoint <%s>\n",
nodename,resource,mountpoint));
	status= NFMcheck_str_entry_in_file(nodename,resource,NFMNFSTABS,1, (int *)&line_num,tmp);
	if(status != NFM_S_SUCCESS) return(status);
	line=strtok(tmp," \t");
	line=strtok(NULL," \t");
	strncpy(mountpoint,line,NFM_MOUNTPOINT);
	_NFMdebug((fname,"SUCCESSFUL: Mountpoint is <%s> status <0x%.8x>\n",mountpoint,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

int NFMis_nfs_copy(mountpoint,cofilename,source)
	char *mountpoint,*cofilename; /* Complete path */
	char *source;
{
	long status,line_num;
	char *fname="NFMis_nfs_copy" ;
	char *line,tmp[TEMP_SIZE];
	
	_NFMdebug((fname,"Entry: mountpoint <%s> cofilename <%s> \n",
mountpoint,cofilename));
	status= NFMcheck_str_entry_in_file(mountpoint,cofilename,NFMNFSLINKS,1, (int *)&line_num,tmp);
	if(status != NFM_S_SUCCESS) return(status);
	line=strtok(tmp," \t");
	strncpy(source,line,NFM_MOUNTPOINT);
	_NFMdebug((fname,"SUCCESSFUL: Source  is <%s> status <0x%.8x>\n",source,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
