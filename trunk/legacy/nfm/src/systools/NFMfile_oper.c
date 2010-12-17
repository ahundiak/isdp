#include "machine.h"
#define INCLUDE_EXTERN  1

#include "NFMsysinc.h"
/************************************************************************
*									*	
* Contents:								*
*		NFMcopy_file()						*
*		NFMappend_str_to_file()					*
*		NFMcheck_str_entry_in_file()				*
*		NFMdelete_str_entry_from_file()				*
*		NFMfopen_write()					*
*		NFMverify_file_info()					*
*		NFMconvert_to_vax_file()				*
************************************************************************/


/************************************************************************
*									*
*			NFMcopy_file					*
*									*
*	This function copies the src_file to dst_file.			*
*	If delete_src_flag is non zero the src_file will be deleted	*
************************************************************************/

/************************************************************************
*                                                                       *
* 12/17/92 - KT - SUN Port - Changed 'Stat' to 'stat'                   *
*                                                                       *
************************************************************************/

int NFMcopy_file (src_file, dst_file, type, size,delete_src_flag)
   char    *src_file, *dst_file, *type;
   long    *size,delete_src_flag; /* 0 DO NOT DELETE */
   { 
     char *fname="NFMcopy_file";
     long    status;
     char    in_name [MAX_FILENAME], out_name [MAX_FILENAME],buffer[MAX_FILENAME];
     FILE    *fopen (), *in_file, *out_file;
     int     tr_size,tr_size2,char_size;
     struct  stat f_buff1,f_buff2;
     NFMfile_info  file_info;

     *size = -2;
     char_size = sizeof(char);
    _NFMdebug((fname,"Src File <%s> Dst File <%s>\n Type <%s> Size <%d> delete_src_flag <%d>\n",
src_file,dst_file,type,*size,delete_src_flag));


     status = NFMget_full_name (src_file, in_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,"NFMget_full_name: src_file : status = <0x%.8x>\n", status));
        return (NFM_E_NO_FILENAME_SRC);
      }
     status = NFMget_full_name (dst_file, out_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,"NFMget_full_name: dst_file : status = <0x%.8x>\n", status));
        return (NFM_E_NO_FILENAME_DST);
      }

      _NFMdebug((fname,"In_name <%s> Out_name <%s>\n",in_name,out_name));

     in_file = fopen (in_name, "r");
     if (in_file == (FILE *)0)
      {
        status = NFM_E_FOPEN;
        ERRload_struct(NFM,status,"%s%d%s",in_name,errno,"r");
	_NFMdebug((fname,"fopen failed: filename <%s> errno <%d> fopen type <%s>\
 status <0x%.8x>\n",in_name,errno,"r",status));
	sys_buf_status.status2 = errno;
	sys_buf_status.status3 = 0;
        return (NFM_E_FOPEN_SRC);
      }

     status = NFMfopen_write(out_name,type,&out_file);
     if (status != NFM_S_SUCCESS )
      {
	_NFMdebug((fname,"fopen failed: filename <%s> errno <%d> fopen type <%s>\
 status <0x%.8x>\n",out_name,errno,"w",status));
	fclose(in_file);
	fclose(out_file);
	sys_buf_status.status2 = errno;
	sys_buf_status.status3 = 0;
        return (NFM_E_FOPEN_DST);
      }
    
     while ((tr_size = fread (buffer,char_size,MAX_FILENAME,in_file)) > 0 )
      {
	tr_size2 = fwrite(buffer,char_size,tr_size,out_file);
	if(tr_size != tr_size2)
	{
           fclose (in_file);
           fclose (out_file);
           unlink (out_name);
           status = NFM_E_FWRITE;
           ERRload_struct(NFM,status,"%s%d%d%d",out_name,tr_size,tr_size2,errno);
	   _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",out_name,tr_size,tr_size2,errno,status));
	   sys_buf_status.status2 = tr_size;
	   sys_buf_status.status3 = tr_size2;
           return (status);
        }
      }

     status = fclose (in_file);
     if (status) /* OK */
      {
        fclose (out_file);
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_FCLOSE,"%s%d",in_name,status);
        _NFMdebug((fname,"fclose failed for file <%s> status <%d> return status\
<0x%.8x>\n",in_name,status,NFM_E_FCLOSE));
        return (NFM_E_FCLOSE_SRC);
      }

     status = fclose (out_file);
     if (status) /* OK */
      {
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_FCLOSE,"%s%d",out_name,status);
        _NFMdebug((fname,"fclose failed for file <%s> status <%d> return status\
<0x%.8x>\n",out_name,status,NFM_E_FCLOSE));
        return (NFM_E_FCLOSE_DST);
      }

     status = stat (in_name, &f_buff1);
     if (status) /* OK */
      {
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_STAT,"%s%d%d",in_name,status,errno);
        _NFMdebug ((fname, "Stat failed : filename <%s> status <%d> errno <%d>\
return_status <0x%.8x>\n",in_name,status,errno,NFM_E_STAT));
	sys_buf_status.status2 = errno ;
        return (NFM_E_STAT_SRC);
      }

     strncpy (file_info.name, dst_file, NFM_FILENAME);
     file_info.name [NFM_FILENAME] = 0;

     file_info.size  = f_buff1.st_size;
     file_info.mode  = f_buff1.st_mode;
     file_info.mode  = f_buff1.st_mode;
     file_info.atime = f_buff1.st_atime;
     file_info.mtime = f_buff1.st_mtime;

     status = NFMset_file_mode (out_name, &file_info); 
     if (status != NFM_S_SUCCESS) 
      {
        unlink (out_name);
	_NFMdebug((fname,"NFMset_file_mode: Failed: status <0x%.8x>\n",status));
        return (status);
      }
     status = stat (out_name, &f_buff2);
     if (status) /* OK */
      {
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_STAT,"%s%d%d",out_name,status,errno);
        _NFMdebug ((fname, "Stat failed : filename <%s> status <%d> errno <%d>\
return_status <0x%.8x>\n",out_name,status,errno,NFM_E_STAT));
	sys_buf_status.status2 = errno ;
        return (NFM_E_STAT_DST);
      }


     status = NFMverify_file_info (dst_file, &f_buff2, &file_info);
     if (status != NFM_S_SUCCESS)
      {
        unlink (out_name);
        _NFMdebug ((fname,"NFMverify_file_info : status = <0x%.8x>\n", status));
        return (status);
      }

     *size = f_buff2.st_size;
     if(delete_src_flag)
     {
	status = unlink ( in_name);
	if(status)
	{
		ERRload_struct(NFM,NFM_E_UNLINK,"%s%d",src_file,errno);
		_NFMdebug((fname,"Unlink source file <%s> failed: \
delete_src_flag <%d> errno <%d> status <0x%.8x>\n",src_file,delete_src_flag,
errno,NFM_E_UNLINK));
		sys_buf_status.status2 = errno;
		sys_buf_status.status3 = 0;
		return(NFM_E_UNLINK);
	}
     }
 
      _NFMdebug ((fname,"SUCCESSFUL :file_size <%d>: status = <0x%.8x>\n" ,*size,NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }


int NFMappend_str_to_file(line,file)
	char *line,*file;
{
	char *fname="NFMappend_str_to_file";
	long status,size ,flag;
	struct stat fbuff ;
	FILE *fp1,  *fopen() ;

	_NFMdebug((fname,"Entry: line = <%s>:file = <%s>\n",line,file));
/* Open file to append */
/* Keep the directories accessible to all users */
	status = NFM_mkpath(file, 00777);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"NFM_mkpath failed for file <%s>: status <0x%.8x>\n",file,status));
		return(status);
	}
	status = stat(file,&fbuff);
	if(status)	/* This means the file does not exist */
		flag = 1;
	else flag = 0;
	fp1 = fopen(file,"a");
	if(fp1 == (FILE *)0)
	{
		_NFMdebug((fname,"Failed to open file <%s> errno <%d>\n",file,errno));
		ERRload_struct(NFM,NFM_E_FOPEN,"%s%d%s",file,errno,"a");
		sys_buf_status.status2 = errno;
		sys_buf_status.status3 = 0;
		return(NFM_E_FOPEN);
	}
/* Figure out amount of data to write */
	size = strlen(line);
	status = fwrite(line,sizeof(char),size,fp1);
	if(status != size)
	{
		_NFMdebug((fname,"Failed to write <%d> bytes to file <%s>: \
Bytes written <%d>\n",size,file,status));
		ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",file,size,status,errno);
		status = fseek(fp1,fbuff.st_size,0);
		if(status)
		{
			_NFMdebug((fname,"Fseek Failed for file <%s>: Offset <%d>\n",
file,fbuff.st_size));
			ERRload_struct(NFM,NFM_E_FSEEK,"%s%d%d%d",file,fbuff.st_size,0,errno);
			status = NFM_E_FSEEK ;
		}
		else status= NFM_E_FWRITE ;
	}
	else status = NFM_S_SUCCESS ;
	fclose(fp1);
	if(flag) NFMchmod(file,00666);
	_NFMdebug((fname,"Exit: Status <0x%.8x>\n",status));
	return(status);
}

int NFMcheck_str_entry_in_file(identifier,identifier2,file,type,line_num,line_in)
	char *identifier,*file,*identifier2,*line_in;
	int type, *line_num;
{
	char *fname="NFMcheck_str_entry_in_file";
	long status,size,flag ,size2,flag2;
	struct stat fbuff ;
        char temp_str[TEMP_SIZE];
	char *line ;
	FILE *fp1, *fopen() ;

	_NFMdebug((fname,"Entry: identifier = <%s> identifier2 <%s> file = <%s>\
\n type = <%d> *line_num <%d> line_in <%s>\n", identifier,identifier2,file,type,
*line_num,line_in));
	*line_num=0;
	status = stat(file,&fbuff);
	if(status)
	{
		_NFMdebug((fname,"Stat failed for file <%s> status = <%d> errno <%d>\n",file,status,errno));
		ERRload_struct(NFM,NFM_E_STAT,"%s%d%d",file,status,errno);
		sys_buf_status.status2 = errno;
		sys_buf_status.status3 = 0;
		return(NFM_E_STAT);
	}
	size = strlen(identifier);
	size2 = strlen(identifier2);
	fp1 = fopen(file,"r");
	if(fp1 == (FILE *)0)
	{
		_NFMdebug((fname,"Failed to open file <%s> errno <%d>\n",file,errno));
		ERRload_struct(NFM,NFM_E_FOPEN,"%s%d%s",file,errno,"r");
		return(NFM_E_FOPEN);
	}
	flag =  0 ;
	while((line=fgets(temp_str,TEMP_SIZE,fp1)) != (char *)0 && !flag)
	{
		(*line_num)++;
		strcpy(line_in,temp_str);
		switch(temp_str[0])
		{
			case '#':
			case '\n':
				break;
			default:
				line=strtok(temp_str," \t");
				flag2= 0 ;
				while(line != (char *)0 && !flag )
				{
					if(strncmp(line,identifier,size) == 0) flag2++;
					else if(type && strncmp(line,identifier2,size2) == 0) flag2++;
					if(type && flag2 == 2) flag = 1;
					if(!type && flag2) flag = 1;
					line=strtok(NULL," \t");
				}
		}
	}
	fclose(fp1);
	_NFMdebug((fname,"Line_num = <%d> line_in <%s>\n",*line_num,line_in));
	if(flag) status = NFM_S_SUCCESS;
	else	status = NFM_I_NOT_PRESENT;
	_NFMdebug((fname,"Exit: status <0x%.8x>\n",status));
	return(status);
}

int NFMdelete_str_entry_from_file(identifier,file, type )
	char *identifier,*file;
	int type;
{
	char *fname="NFMdelete_str_entry_from_file";
	long status,status1,size,flag ;
	struct stat fbuff ;
	char *line ,path[25],tmp[TEMP_SIZE];
        char temp_str[TEMP_SIZE];
	FILE *fp1, *fp2, *fopen() ;

	_NFMdebug((fname,"Entry: identifier = <%s> file = <%s> type = <%d>\n",
identifier,file,type));
	status = stat(file,&fbuff);
	if(status)
	{
		_NFMdebug((fname,"Stat failed for file <%s> status = <%d> errno <%d>\n",file,status,errno));
		ERRload_struct(NFM,NFM_E_STAT,"%s%d%d",file,status,errno);
		return(status);
	}
/* create a unique filename for temporary file */
        status = NFMmk_unique_mountpoint(path);
        if(status != NFM_S_SUCCESS)
        {
               _NFMdebug((fname,"Failed to create unique filename for temporary file: status <0x%.8x>\n",status));
               return(status);
        }
	status = NFMcopy_file(file,path,"",&size,(long)0);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Unable to copy file <%s> to file <%s>: status\
 <0x%.8x>\n",file,path,status));
		return(status);
	}
	fp1 = fopen(path,"r");
	if(fp1 == (FILE *)0)
	{
		_NFMdebug((fname,"Failed to open file <%s> errno <%d>\n",path,errno));
		ERRload_struct(NFM,NFM_E_FOPEN,"%s%d%s",path,errno,"r");
		return(NFM_E_FOPEN);
	}
	fp2 = fopen(file,"w");
	if(fp2 == (FILE *)0)
	{
		fclose(fp1);
		_NFMdebug((fname,"Failed to open file <%s> errno <%d>\n",file,errno));
		ERRload_struct(NFM,NFM_E_FOPEN,"%s%d%s",file,errno,"w");
		return(NFM_E_FOPEN);
	}
	flag = 0 ;
	size = strlen(identifier);
	status1= NFM_S_SUCCESS ;
	while((line=fgets(temp_str,TEMP_SIZE,fp1)) != (char *)0 )
	{
		if(!flag)
		   switch(temp_str[0])
		   {
			case '#':
			case '\n':
				status=fputs(temp_str,fp2);
				break;
			default:
		                strcpy(tmp,temp_str);	
				line=strtok(temp_str," \t");
				while(line != (char *)0 && !flag)
				{
					if(strncmp(line,identifier,size) == 0) flag = 1;
					else
						line=strtok(NULL," \t");
				}
				if(!flag) status=fputs(tmp,fp2);
				else 
				{
					flag = 0;
					continue;
				}
		    }
		else
			status=fputs(temp_str,fp2);
		if(status == EOF)
		{
			_NFMdebug((fname,"Write error. Fputs returned EOF\n\
for str <%s> file <%s> errno <%d>\n",temp_str,file,errno));
			ERRload_struct(NFM,NFM_E_FPUTS,"%s%s%d",file,temp_str,errno);
			status1 = NFM_E_FPUTS;
		}
	}
	fclose(fp1);
	fclose(fp2);
	
	_NFMdebug((fname,"Exit: status <0x%.8x>\n",status1));
	return(status1);
}


int NFMfopen_write (filename, attr, outfile)
  char    *filename, *attr;
  FILE    **outfile;
  {
    char *fname="NFMfopen_write ";
    int   status;
    struct stat stat_buf;
    FILE  *fopen ();

    _NFMdebug ((fname,"Entry:File Name = <%s> Attr <%s>\n  ", filename,attr));

    status = NFM_mkpath(filename, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    if(status != NFM_S_SUCCESS)
    {
	_NFMdebug((fname,"NFM_mkpath Failed.filename <%s> status <0x%.8x>\n",filename,status));
	return(status);
    }
    *outfile = NULL;

    status = stat(filename, &stat_buf);

    if((status==0) && (S_ISREG(stat_buf.st_mode)==0))
    {
        _NFMdebug((fname,"<%s> is NOT a regular file\n", filename));
    }
    else
    	*outfile = fopen (filename, "w");

    if (!(*outfile))
     {
	status = NFM_E_FOPEN ;
	ERRload_struct(NFM,status,"%s%d%s",filename,errno,"w");
        _NFMdebug((fname,"fopen failed: filename <%s>: errno <%d>: fopen_type <%s> status <0x%.8x>\n",filename,errno,"w",status));
	
	sys_buf_status.status2 = errno;
	sys_buf_status.status3 = 0;
	return(status);
     }

	_NFMdebug((fname,"SUCCESSFUL: FILE pointer <%x>: status <0x%.8x>\n",*outfile,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
  }


int NFMverify_file_info (file_name, fbuff, file_info)
  char                    *file_name;
  struct    stat          *fbuff;
  NFMfile_info  *file_info;
  {
    char *fname="NFMverify_file_info ";
    int    status;

    _NFMdebug((fname,"Entry: filename <%s> stat pointer *fbuff <%x> NFMfile_info\
pointer *file_info <%x>\n",file_name, *fbuff, *file_info));
    status = NFM_S_SUCCESS;

    if (strcmp (file_info -> name, file_name))
     {
       status = NFM_E_FILENAME_MISMATCH;
	ERRload_struct(NFM,status,"%s%s",file_info->name,file_name);
       _NFMdebug ((fname,"Mismatch File Name file1 <%s> file2 <%s> : status = <0x%.8x>\n",
       file_info->name,file_name,status));
       return (status);
     }
    else if (file_info -> size != fbuff -> st_size)
     {
       status = NFM_E_FILESIZE_MISMATCH;
	ERRload_struct(NFM,status,"%s%d%s%d",file_info->name,file_info->size,file_name,fbuff->st_size);
       _NFMdebug ((fname,"Mismatch File Size filename1 <%s> filesize1 <%d> \
filename2 <%s> filesize2 <%d> : status = <0x%.8x>\n",file_info->name,
 file_info->size,file_name,fbuff->st_size,status));
       sys_buf_status.status2 = file_info->size;
       sys_buf_status.status3 = fbuff->st_size;
       return (status);
     }

     _NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
     return(NFM_S_SUCCESS);
  }


int NFMcp_file (src_file, dst_file,delete_src_flag)
   char    *src_file, *dst_file;
   long    delete_src_flag; /* 0 DO NOT DELETE */
   { 
     char *fname="NFMcp_file";
     long    status;
     char    in_name [MAX_FILENAME], out_name [MAX_FILENAME],buffer[MAX_FILENAME];
     FILE    *fopen (), *in_file, *out_file;
     int     tr_size,tr_size2,char_size;
     struct  stat f_buff1,f_buff2;
     NFMfile_info  file_info;

     char_size = sizeof(char);
    _NFMdebug((fname,"Src File <%s> Dst File <%s>\n delete_src_flag <%d>\n",
src_file,dst_file,delete_src_flag));


      strcpy(in_name,src_file);
      strcpy(out_name,dst_file);

      _NFMdebug((fname,"In_name <%s> Out_name <%s>\n",in_name,out_name));

     in_file = fopen (in_name, "r");
     if (in_file == (FILE *)0)
      {
        status = NFM_E_FOPEN;
        ERRload_struct(NFM,status,"%s%d%s",in_name,errno,"r");
	_NFMdebug((fname,"fopen failed: filename <%s> errno <%d> fopen type <%s>\
 status <0x%.8x>\n",in_name,errno,"r",status));
	sys_buf_status.status2 = errno;
	sys_buf_status.status3 = 0;
        return (NFM_E_FOPEN_SRC);
      }

     status = NFMfopen_write(out_name,"",&out_file);
     if (status != NFM_S_SUCCESS )
      {
	_NFMdebug((fname,"fopen failed: filename <%s> errno <%d> fopen type <%s>\
 status <0x%.8x>\n",out_name,errno,"w",status));
	fclose(in_file);
	fclose(out_file);
	sys_buf_status.status2 = errno;
	sys_buf_status.status3 = 0;
        return (NFM_E_FOPEN_DST);
      }
    
     while ((tr_size = fread (buffer,char_size,MAX_FILENAME,in_file)) > 0 )
      {
	tr_size2 = fwrite(buffer,char_size,tr_size,out_file);
	if(tr_size != tr_size2)
	{
           fclose (in_file);
           fclose (out_file);
           unlink (out_name);
           status = NFM_E_FWRITE;
           ERRload_struct(NFM,status,"%s%d%d%d",out_name,tr_size,tr_size2,errno);
	   _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",out_name,tr_size,tr_size2,errno,status));
	   sys_buf_status.status2 = tr_size;
	   sys_buf_status.status3 = tr_size2;
           return (status);
        }
      }

     status = fclose (in_file);
     if (status) /* OK */
      {
        fclose (out_file);
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_FCLOSE,"%s%d",in_name,status);
        _NFMdebug((fname,"fclose failed for file <%s> status <%d> return status\
<0x%.8x>\n",in_name,status,NFM_E_FCLOSE));
        return (NFM_E_FCLOSE_SRC);
      }

     status = fclose (out_file);
     if (status) /* OK */
      {
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_FCLOSE,"%s%d",out_name,status);
        _NFMdebug((fname,"fclose failed for file <%s> status <%d> return status\
<0x%.8x>\n",out_name,status,NFM_E_FCLOSE));
        return (NFM_E_FCLOSE_DST);
      }

     status = stat (in_name, &f_buff1);
     if (status) /* OK */
      {
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_STAT,"%s%d%d",in_name,status,errno);
        _NFMdebug ((fname, "Stat failed : filename <%s> status <%d> errno <%d>\
return_status <0x%.8x>\n",in_name,status,errno,NFM_E_STAT));
	sys_buf_status.status2 = errno ;
        return (NFM_E_STAT_SRC);
      }

     strncpy (file_info.name, dst_file, NFM_FILENAME);
     file_info.name [NFM_FILENAME] = 0;

     file_info.size  = f_buff1.st_size;
     file_info.mode  = f_buff1.st_mode;
     file_info.mode  = f_buff1.st_mode;
     file_info.atime = f_buff1.st_atime;
     file_info.mtime = f_buff1.st_mtime;

     status = NFMset_file_mode (out_name, &file_info); 
     if (status != NFM_S_SUCCESS) 
      {
        unlink (out_name);
	_NFMdebug((fname,"NFMset_file_mode: Failed: status <0x%.8x>\n",status));
        return (status);
      }
     status = stat (out_name, &f_buff2);
     if (status) /* OK */
      {
        unlink (out_name);
        ERRload_struct(NFM,NFM_E_STAT,"%s%d%d",out_name,status,errno);
        _NFMdebug ((fname, "Stat failed : filename <%s> status <%d> errno <%d>\
return_status <0x%.8x>\n",out_name,status,errno,NFM_E_STAT));
	sys_buf_status.status2 = errno ;
        return (NFM_E_STAT_DST);
      }


     status = NFMverify_file_info (dst_file, &f_buff2, &file_info);
     if (status != NFM_S_SUCCESS)
      {
        unlink (out_name);
        _NFMdebug ((fname,"NFMverify_file_info : status = <0x%.8x>\n", status));
        return (status);
      }

     if(delete_src_flag)
     {
	status = unlink ( in_name);
	if(status)
	{
		ERRload_struct(NFM,NFM_E_UNLINK,"%s%d",in_name,errno);
		_NFMdebug((fname,"Unlink source file <%s> failed: \
delete_src_flag <%d> errno <%d> status <0x%.8x>\n",src_file,delete_src_flag,
errno,NFM_E_UNLINK));
		sys_buf_status.status2 = errno;
		sys_buf_status.status3 = 0;
		return(NFM_E_UNLINK);
	}
     }
 
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n" ,NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

/******************************************************************************
*				NFMconvert_to_vax_file			      *
*  									      *
* This function checks to see if a filename conforms to VAX/VMS filenaming    *
* convention. If not then appropriate ".", ";" are added to the end of the    *
* file. 								      *
*									      *
* The filename must have atleast enough space to accomodate additional two    *
* characters if required						      *
******************************************************************************/


NFMconvert_to_vax_file(filename)				
	char *filename;
	
{
	long pos,flag;
	char *fname="NFMconvert_to_vax_file" ;
	_NFMdebug((fname,"Entry: filename <%s>\n",filename));
        pos = flag = 0;
        while ( filename[pos] != '\0' ) 
	{
		if(filename[pos] == '[') flag=1;

		if(flag)
		{
			if(filename[pos] == ']') flag=0;
		}
		else
		{
			if(filename[pos] == '.') break ;
		}
		pos++;
	}
        if(filename[pos] == '\0' ) strcat(filename,".");
        pos = 0;
        while ( filename[pos] != '\0' && filename[pos] != ';') pos++;
        if(filename[pos] == '\0' ) strcat(filename,";");
	_NFMdebug((fname,"Exit: status <0x%.8x> filename <%s>\n",NFM_S_SUCCESS,filename));
}
