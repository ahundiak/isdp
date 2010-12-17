#include "machine.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <errno.h>


char *get_id(char *str,char *id_name);

#define LINE_SIZE	512

main(argc,argv)
int argc;
char **argv;
{
	char *ser_file="/usr/tmp/NFMserver.log";
	char *tmp_file="/usr/tmp/TMP.log";
	char In_Line1[LINE_SIZE], In_Line2[LINE_SIZE], Error[LINE_SIZE];
	char *ptr1,*ptr2;
	struct Info
	{
		long line_num;
		char client_node[40];
		long status;
		long server_pid;
		struct Info *next;
	} *start,*local,*end,*prev;

        long line_num, action,status;
	FILE *fp1, *fp2, *fp3,*fopen();

	line_num=0;
	start=local=end= prev= (struct Info *)0;

	if((fp3=fopen("/dev/console","a")) == (FILE *)0)
        {
		sprintf(Error,"echo Cannot open file %s for input > /dev/console 2>&1","/dev/console");
		system(Error);
		fp3 = stdout;
		
        }

	if((fp2=fopen(ser_file,"r")) == (FILE *)0)
        {
		sprintf(Error,"NFMmonitor:Cannot open file <%s> for input\n",ser_file);
		fprintf(fp3,"%s\n",Error);
		fclose(fp2);
		fclose(fp3);
		exit(1);		
        }

	action = 0;
	while((ptr1 = fgets (In_Line1,LINE_SIZE,fp2)) != (char *)0)
	{
		line_num++;
		if(strncmp(In_Line1,"Client",6) == 0 )
		{
			if(action == 1)
			{
				if(start == (struct Info *)0)
				{
					start=end;
					prev=start;
				}
				if(prev!=end)
				{
					prev->next=end;
					prev=prev->next;
				}
				action = 0;
			}
			ptr2=get_id(In_Line1,"ClientId");
			if(ptr2!=NULL)
				if(strncmp(ptr2,"DMMGR",5) == 0 )
					action = 1;		

			if(action == 1 )
			{
				end = (struct Info *)malloc (sizeof(struct Info));
				if(end == (struct Info *)0)
				{
					sprintf(Error,"Cannot allocate structure\n");
					fprintf(fp3,"%s\n",Error);
					fclose(fp3);
					fclose(fp2);
					exit(2);
				}
				end->line_num = line_num;
				end->next = (struct Info *)0;
				end->server_pid = -1;
				ptr2=get_id(In_Line1,"Name");
				if(ptr2 == NULL )
				{
					sprintf(Error,"Cannot get Node Name for Client at line number %d\n",line_num);
					fprintf(fp3,"%s\n",Error);
					free(end);
					end= (struct Info *)0;
					action = 0;
					continue;
				}
				strcpy(end->client_node,ptr2);
				ptr2=get_id(In_Line1,"Status");
				if(ptr2 == NULL )
				{
					sprintf(Error,"Cannot get Status for Client at line number %d\n",line_num);
					fprintf(fp3,"%s\n",Error);
					free(end);
					end= (struct Info *)0;
					action = 0;
					continue;
				}
				if(strncmp(ptr2,"ON",2) == 0 )
					end->status = 1;
				else
					end->status = 0;
				
			}
			
		}
		else if(action==1)
		{	
		   if(strncmp(In_Line1,"Server",6) == 0 )
                   {
			action=2;
			ptr2=get_id(In_Line1,"Pid");
			if(ptr2 == NULL )
			{
				sprintf(Error,"Cannot get Server PID for Client at line number %d\n",line_num);
				fprintf(fp3,"%s\n",Error);
				free(end);
				end= (struct Info *)0;
				action = 0;
				continue;
			}
			end->server_pid=atol(ptr2);
		   }
		}
		
		if(action == 1)
		{
			if(start == (struct Info *)0)
			{
				start=end;
				prev=start;
			}
			
		}
		if(action == 2)
		{
			if(prev!=end)
			{
				prev->next=end;
				prev=prev->next;
			}
			action = 0;
		}
		
	} 
	fclose(fp2);
	end = start;
	while(end != (struct Info *)0)
	{
		local=end->next;
		while (local != (struct Info *)0)
		{
			if(strcmp(end->client_node,local->client_node) == 0 )
			{
				if(end->status == 1)
				{
			             status = kill((pid_t) end->server_pid,SIGKILL);
				     if(status < 0 )
				     {
					if(errno == ESRCH)
						end->status = 2;
					else
                                        {
						sprintf(Error,"Kill failed for Pid %d : Errno %d\n",end->server_pid,errno);
						fprintf(fp3,"%s\n",Error);
					}
				     }
				     else
				     {
				        sprintf(Error,"NFMmonitor:\nKilling \
orphan NFMserver PID %d \nConnected from DM/Manager Client Node: <%s>\n",end->server_pid,end->client_node);
				        fprintf(fp3,"%s\n",Error);
					end->status = 2;
				     }
	
				}
				
			}
			local=local->next;
		}
		end=end->next;
	}

	end = start;
	line_num=0;
	if((fp1=fopen(tmp_file,"w")) == (FILE *)0)
        {
		sprintf(Error,"Cannot open file <%s> for output\n",tmp_file);
		fprintf(fp3,"%s\n",Error);
		fclose(fp1);
		fclose(fp3);
		exit(4);
        }
	if((fp2=fopen(ser_file,"r")) == (FILE *)0)
        {
		sprintf(Error,"Cannot open file <%s> for input\n",ser_file);
		fprintf(fp3,"%s\n",Error);
		fclose(fp1);
		fclose(fp2);
		fclose(fp3);
		exit(5);
        }

	action = 0;
	while((ptr1 = fgets (In_Line1,LINE_SIZE,fp2)) != (char *)0)
	{
		line_num++;
	
		if(end==(struct Info * )0)
		{
			fputs(In_Line1,fp1);
			continue;
		}
		if(line_num < end->line_num)
		{
			fputs(In_Line1,fp1);
			continue;
		}
		if(line_num == end->line_num)
		{
			if(end->status == 2 )
			{
				strcpy(In_Line2,In_Line1);
				ptr2=strstr(In_Line1,"ON");
				if(ptr2 != NULL )
				{
					*ptr2='\0';
					ptr2=strstr(In_Line2,"ON");
					if(ptr2 != NULL)
					{
						ptr2+=2;
						strcat(In_Line1,"OFF");
						strcat(In_Line1,ptr2);
					}
				}
			}
			fputs(In_Line1,fp1);
			end=end->next;
			continue;
		}
		else
		{
			sprintf(Error,"Line number > end->line Number . Skipping\n");
			fprintf(fp3,"%s\n",Error);
			end=end->next;
		}
	}
	fclose(fp1);
	fclose(fp2);
/* Copy File back to original */
	sprintf(Error,"cp %s %s > /dev/null 2>&1",tmp_file,ser_file);
	status = system(Error);
	if ( status < 0 )
	{
		sprintf(Error, "Cannot copy %s to %s : errno %d\n",tmp_file,ser_file,errno);
		fprintf(fp3,"%s\n",Error);
	}
/* Delete link list */
	end=start;
	while(end != (struct Info * )0)
	{
		local=end->next;
		free(end);
		end=local;
	}
	fclose(fp3);
	
	return(0);
}
char *get_id(str,id_name)
char *str,*id_name;
{
	char *id, *name,*terminator;
	char buf[LINE_SIZE];
	if(strlen(str) <=0 || strlen(id_name) <= 0 ) return (NULL);
	id=strstr(str,id_name);
	if(id == NULL) return(NULL);
        name = strchr(id,' ');	
	if(name == NULL) return(NULL);
	name++;
	strcpy(buf,name);
        terminator = strpbrk(buf," \n\t");	
	if(terminator != NULL) *terminator='\0';
	return(buf);
	
}
