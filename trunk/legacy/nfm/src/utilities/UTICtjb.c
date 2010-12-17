#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

#define UTI_E_JB_NOT_EXISTS 999

long UTICprepare_TJB_media (tjb_spec, hdr)
char *tjb_spec;
script_header hdr;
{
	long status;
	long UTICdisplay_slot_info();
	long UTICget_slot_info();
	int input_buf[10] = { 0, 0, 0, 0, 0, 
			      0, 0, 0, 0, 0 };
	/**char drive_no; **/
	char tjb_eject[50];

	status = UTICget_slot_info(input_buf, tjb_spec );

	if(status == UTI_E_JB_NOT_EXISTS)
	{
		fprintf(stdout, "Nfmutil :  TJB specification <%s> does not exist\n", tjb_spec);
		return(UTI_E_FAILURE);
	}
	if(status != UTI_S_SUCCESS)
	{
		fprintf(stdout, "Nfmutil :  Error getting Slot information\n");
		return(UTI_E_FAILURE);
	}

	sprintf(tjb_eject, "/usr/ip32/tjb/tjb_eject %s", tjb_spec);
	status = system(tjb_eject);
	if(status != 0)
	{
		fprintf(stdout, "Nfmutil :  Error ejecting the drive for <%s>\n", tjb_spec);
		return(UTI_E_FAILURE);
	}
	status = UTICdisplay_slot_info(input_buf);
	if(status != UTI_S_SUCCESS)
	{
		fprintf(stdout, "Nfmutil :  Error displaying Slot information\n");
		return(UTI_E_FAILURE);
	}

	return(UTI_S_SUCCESS);

/*************************************************************************/
	/** open the script file and substitute all "mt?" with "mt<drive>"

	status = update_script_file(argv[2],"/usr/tmp/util.temp", drive_no);
	if(status != 0)
		printf("Error updating the script\n"); 
	**/
}
long UTICget_slot_info(input_buf, tjb_spec)
int *input_buf; /** i -- bitmap of slot information **/
char *tjb_spec;  /** i -- Juke Box specification eg., TJB01 **/
/***char *drive_no; / *  o -- Drive number **/
{
	FILE *fp, *popen();
	char buffer[257];
	int i, no_drives, spec_len, status;
	char *pos, drive;

	status = system("/usr/ip32/tjb/tjb_config > /dev/null 2>&1"); 
							/** dummy tjb_config **/

	if(status != 0)
	{
		fprintf(stdout, "Nfmutil :  Error executing tjb_config\n");
		return(UTI_E_FAILURE);
	}

	fp = popen("/usr/ip32/tjb/tjb_config", "r");
	
	if(fp == NULL)
	{
		fprintf(stdout, "Nfmutil :  Error executing tjb_config\n");
		return(UTI_E_FAILURE);
	}	


/***********
	while(!feof(fp))
	{
**********/
		
		for(i=0;i<6;i++)
		{
			fgets(buffer, 255, fp); /** Ignore JB Info **/
			if(i==1)
			{
				pos = (char *)strchr(buffer,'\"');
				
				spec_len = strlen(tjb_spec);
				if(strncmp(tjb_spec, pos+1, spec_len)!= 0)
					return(UTI_E_JB_NOT_EXISTS);
			}
			if(i==3)
			{
				pos = (char *)strchr(buffer, ':');
				sscanf(pos, ": %d\n", &no_drives);
			}
			/**fprintf(stdout, "%s",buffer); ***/
		}

		/**fprintf(stdout, "Nfmutil :  No of Drives %d\n",no_drives); **/
		for(i=0;i<no_drives;i++)
		{
			fgets(buffer, 255, fp);
		
			pos = (char *)strstr(buffer, "Drive Info");
			if(pos == NULL)
				return(UTI_E_FAILURE);

			fgets(buffer, 255, fp);
			pos = (char *)strstr(buffer,"/dev/gs/");

			if(pos == NULL)
				return(UTI_E_FAILURE);

			drive = pos[9]; /** char drive; **/
		/*********************************
			if(isdigit(drive))
				*drive_no =  drive;
			else
				*drive_no = '6'; / ** default is mt6** /

			printf("Drive # is <%c>\n", *drive_no);
		***********************************/

			fgets(buffer, 255, fp); /** drive address **/
			fgets(buffer, 255, fp); /** drive status **/
			pos = (char *)strstr(buffer, "OCCUPIED");
			if(!pos)
			{
				fprintf(stdout, 
				"Nfmutil :  Drive mt%c: Empty\n", drive); 
			}
			else
			{
				fprintf(stdout, 
				"Nfmutil :  Drive mt%c: Occupied\n", drive); 
			}
			fgets(buffer, 255, fp); /** New Line **/
		}

		/****Assume there are only 10 slots ***/
		for(i=0;i<10; i++)
		{	
			fgets(buffer, 255, fp); /** New Line **/

			fgets(buffer, 255, fp); /** Slot Info **/
			fgets(buffer, 255, fp); /** Slot address **/
			fgets(buffer, 255, fp); /** Slot Info **/
			if(strstr(buffer, "OCCUPIED"))
				input_buf[i] = 1;
		}
		

/********
	}
*********/

	pclose(fp);
	return(UTI_S_SUCCESS);
}

long UTICdisplay_slot_info(display_map)
int *display_map;
{
	int i,count;

	char *buf[7] = 
	{
	"_______________________________________________________________",
	"| Slot     1       |  2       |  3       |  4       |  5       |",
	"| Status   Empty   |  Occupied|  Empty   |  Empty   |  Empty   |",
	"|__________________|__________|__________|__________|__________|",
     	"| Slot     6       |  7       |  8       |  9       |  10      |",
     	"| Status   Empty   |  Empty   |  Empty   |  Empty   |  Empty   |",
     	"|__________________|__________|__________|__________|__________|"
	};


	count = 11;
	for(i=0;i<5;i++)
	{
		if(display_map[i] == 1)
			strncpy(&buf[2][count],"Occupied", 8);
		else
			strncpy(&buf[2][count],"Empty   ", 8);

		count += 11;
	}
	count = 11;
	for(i=5;i<10;i++)
	{
		if(display_map[i] == 1)
			strncpy(&buf[5][count],"Occupied", 8);
		else
			strncpy(&buf[5][count],"Empty   ", 8);

		count += 11;
	}
			
		
	fprintf(stdout, "Nfmutil :  Current TJB configuration is:\n");
	for(i=0;i<7;i++)
		fprintf(stdout, "\t%s\n", buf[i]);
	fprintf(stdout, "\n");
	return(UTI_S_SUCCESS);
}
long UTICload_TJB_tape(tjb_slot, tjb_spec)
int tjb_slot;
char *tjb_spec;
{
	char tjb_move[80];
	int status;

	sprintf(tjb_move, "/usr/ip32/tjb/tjb_move %s %d 0", tjb_spec, tjb_slot);
	status = system(tjb_move);

	if(status == 0)
		return(UTI_S_SUCCESS);
	else
	{
		fprintf(stdout, "Nfmutil :  Error moving tape from slot <%d> into the drive on <%s>\n", tjb_slot, tjb_spec);
		return(UTI_E_FAILURE);
	}
}
