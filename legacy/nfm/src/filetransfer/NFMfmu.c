#include "machine.h"

#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

NFMfmu_rcmd(command,output_file)
	char *command,*output_file;
{
	int status,line_num,size,output_flag;
	char *fname="NFMfmu_rcmd";
	char scratch_file[48],tmp_file[48],rcmd_com_file[48];
	char cmd_str[4*NFM_FILENAME +2],tmp_str[48],*mktemp();
	FILE *fp;

	_NFMdebug((fname,"Entry: command <%s>:output_file <%s>\n",command,output_file));

	output_flag = 0;
	if(output_file == NULL || output_file[0] == '\0') output_flag = 1;
	status = NFMmk_unique_mountpoint(tmp_file);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"NFMmk_unique_mountpoint Failed: status <0x%.8x>\n",status));
		return(status);
	}
	strcpy(tmp_str,mktemp("NFMRCMDXXXXXXX"));
	sprintf(scratch_file,"igr$scratch:%s.SCRATCH",tmp_str);
	sprintf(rcmd_com_file,"igr$scratch:%s.COM",tmp_str);
	status = NFMfopen_write(tmp_file,"",&fp);
         if (status != NFM_S_SUCCESS )
         {
            _NFMdebug((fname,"fopen failed: filename <%s> errno <%d> fopen type\
 <%s> status <0x%.8x>\n",tmp_file,errno,"w",status));
            return (status);
         }
	sprintf(cmd_str,"$ purge %s\n",scratch_file);
	size = strlen(cmd_str);
        status = fwrite(cmd_str,sizeof(char),size,fp);
        if(status != size)
        {
           fclose (fp);
           unlink (tmp_file);
           ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",tmp_file,status,size,errno);
           _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",tmp_file,status,size,errno, NFM_E_FWRITE));
           sys_buf_status.status2 = status;
           sys_buf_status.status3 = size;
           return (NFM_E_FWRITE);
        }
	sprintf(cmd_str,"$ delete %s;\n",scratch_file);
	size = strlen(cmd_str);
        status = fwrite(cmd_str,sizeof(char),size,fp);
        if(status != size)
        {
           fclose (fp);
           unlink (tmp_file);
           ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",tmp_file,status,size,errno);
           _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",tmp_file,status,size,errno, NFM_E_FWRITE));
           sys_buf_status.status2 = status;
           sys_buf_status.status3 = size;
           return (NFM_E_FWRITE);
        }
	strcpy(cmd_str,"$ define SYS$ERROR SYS$OUTPUT\n");
	size = strlen(cmd_str);
        status = fwrite(cmd_str,sizeof(char),size,fp);
        if(status != size)
        {
           fclose (fp);
           unlink (tmp_file);
           ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",tmp_file,status,size,errno);
           _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",tmp_file,status,size,errno, NFM_E_FWRITE));
           sys_buf_status.status2 = status;
           sys_buf_status.status3 = size;
           return (NFM_E_FWRITE);
        }
	sprintf(cmd_str,"$ define SYS$OUTPUT %s\n",scratch_file);
	size = strlen(cmd_str);
        status = fwrite(cmd_str,sizeof(char),size,fp);
        if(status != size)
        {
           fclose (fp);
           unlink (tmp_file);
           ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",tmp_file,status,size,errno);
           _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",tmp_file,status,size,errno, NFM_E_FWRITE));
           sys_buf_status.status2 = status;
           sys_buf_status.status3 = size;
           return (NFM_E_FWRITE);
        }
        size = 2 ;
        status = fwrite("$ ",sizeof(char),size,fp);
        if(status != size)
        {
           fclose (fp);
           unlink (tmp_file);
           ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",tmp_file,status,size,errno);
           _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",tmp_file,status,size,errno, NFM_E_FWRITE));
           sys_buf_status.status2 = status;
           sys_buf_status.status3 = size;
           return (NFM_E_FWRITE);
        }
	size = strlen(command);
        status = fwrite(command,sizeof(char),size,fp);
        if(status != size)
        {
           fclose (fp);
           unlink (tmp_file);
           ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",tmp_file,status,size,errno);
           _NFMdebug((fname,"fwrite failed for file <%s> size to write <%d>\
size written <%d> errno <%d> status <0x%.8x>\n",tmp_file,status,size,errno, NFM_E_FWRITE));
           sys_buf_status.status2 = status;
           sys_buf_status.status3 = size;
           return (NFM_E_FWRITE);
        }
	fclose(fp);
	status = NETfmu_send(tmp_file,rcmd_com_file,"",&line_num);
	if ( status != NET_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to send script file <%s> to perform\
  fmu_rcmd <%s>:status <0x%.8x>\n",tmp_file,command,status));
		return(status);
	}
	unlink(tmp_file);


	sprintf(cmd_str,"@%s",rcmd_com_file);
	status = NETfmu_rcmd(cmd_str);
	if(status != NET_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed execute fmu_rcmd command <%s>:status <0x%.8x>\n",cmd_str,status));
		return(NFM_E_FMU_RCMD);
	}
	sprintf(cmd_str,"delete %s;",rcmd_com_file);
	status = NETfmu_rcmd(cmd_str);
	if(status != NET_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed execute fmu_rcmd command <%s>:status <0x%.8x>\n",cmd_str,status));
		return(NFM_E_FMU_RCMD);
	}
	if(output_flag)
	  status = NETfmu_receive(scratch_file,tmp_file,"",&line_num);
	else
	  status = NETfmu_receive(scratch_file,output_file,"",&line_num);
	if ( status != NET_S_SUCCESS)
	{
		_NFMdebug((fname,"No output was created by fmu_rcmd <%s>:status\
 <0x%.8x>\n",command,status));
		return(NFM_I_NO_OUTPUT);
	}
/* Parse through the output file to check for errors */
	if(output_flag)
	  status = NFMcheck_str_entry_in_file("%","",tmp_file,0,&line_num,cmd_str);
	else
	  status = NFMcheck_str_entry_in_file("%","",output_file,0,&line_num,cmd_str);
	if(status == NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Command <%s> failed: <%s> detected in file <%s>\
\n",command,"%",output_file));
		status = NFM_E_FMU_RCMD_COMMAND_FAILURE ;
/* UPPER FUNCTION TO DECIDE
	      if(output_flag)
		ERRload_struct(NFM,status,"%s%s",command,tmp_file);
	      else
		ERRload_struct(NFM,status,"%s%s",command,output_file);
*/
		return(status);
	}
	unlink(tmp_file);
	_NFMdebug((fname,"SUCCESSFUL: <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
