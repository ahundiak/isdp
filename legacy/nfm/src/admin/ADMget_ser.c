#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "ADMser.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "ERR.h"
#include "DEBUG.h"


long ADMfind_server(ps_buf, ps_count, actual_count)

struct ps_buffer ps_buf[200];
int    *ps_count, *actual_count;

{
        long    status;
	char    *strstr();
	FILE    *fp;
	char    buffer[200];
     	char    *result;
        char    temp_str[250];
        int     i,j;
	int    count=0, new_count = 0;

 static char  *fname = "ADMfind_server";

 _NFMdebug (( fname, "ENTER\n"));
 
	fp = fopen("/usr/tmp/NFMserver.log","r");
	if(!fp)
	{
           status = NFM_E_OPEN_FILENAME;
	   _NFMdebug((fname,"Unable to open /usr/tmp/NFMserver.log"));
           return (status);
	}
	
	while(fgets(buffer,199,fp))
	{
		
/*      Following two lines added by MVR to take care of entries which
        don't start with Client or Server . This update	avoids a  SEGV.
                                         	     -- MVR 1/12/93
*/
        if ((buffer[0] != 'S')  &&  (buffer[0] != 'C'))
                continue;

        if (buffer[0]=='S')
            { 
              status=ADMfill_ps_struct(buffer,&ps_buf[count],SERVER);
              count++;
             
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname,"ADMfill_ps_struct:<0x%.8x>\n",status));
                  return(status);
               }
                continue;
           }
           status=ADMfill_ps_struct(buffer,&ps_buf[count],CLIENT);
           if (status !=NFM_S_SUCCESS)
            {
              _NFMdebug ((fname,"ADMfill_ps_struct:<0x%.8x>\n", status));
              return(status);
            }
             if(count == 100)
              {
               _NFMdebug((fname,"Array overflow\n"));
               status= NFM_E_FAILURE;
               ERRload_struct(NFM, NFM_E_FAILURE, "%s", "Array overflow",NULL);
               return(status);
              }
            
       }
	
   fclose(fp);

           for (i=0; i<count; ++i)
            {
               if ((ps_buf[i].connect == OFF)|| 
                  (ps_buf[i].connect == DISCARD))
                    continue;
                 
                 for (j=i; j< count; ++j)
                  {
                     if((ps_buf[i].spid == ps_buf[j].spid) &&
                         (ps_buf[i].connect != ps_buf[j].connect))
                      {
                       ps_buf[i].connect = DISCARD;
                       ps_buf[j].connect = DISCARD;
                      }

                  }

             }
	   new_count = 0;
           for(i=0;i<count;++i)
            {
               if(ps_buf[i].connect !=DISCARD)
                {
                  sprintf(temp_str,"%s, %s, %s, %d, %s, %d\n",ps_buf[i].node, ps_buf[i].date, ps_buf[i].time, ps_buf[i].spid, ps_buf[i].path, ps_buf[i].connect); 
		new_count++;
                _NFMdebug((fname,"List contain of %s\n",temp_str));
		
                }
            }
        
_NFMdebug((fname, "This is a successfull exit\n"));
 
*ps_count = count; 
*actual_count = new_count; 

return (NFM_S_SUCCESS);

}

ADMfill_ps_struct(buffer,ps_buf,flag)
char   *buffer;
struct ps_buffer *ps_buf;
int    flag;
{
	char *junk;
        long  status;
        char  tmp_value[5];
 static char *fname = "ADMfill_ps_struct";


                _NFMdebug((fname, "ENTER\n"));

            if (flag == CLIENT)
             {

                junk = (char *)strtok(buffer, " "); /*Client is ignored*/
                junk = (char *)strtok(NULL, " "); /* : is ignored*/ 
                junk = (char *)strtok(NULL, " "); /* Node is ignored*/
                junk = (char *)strtok(NULL, " "); /* Name is ignored*/

               if((ps_buf->node = (char *)malloc(16 * sizeof(char)))==NULL)

                {
                _NFMdebug((fname,"ps_buf->node: <0x%.8x>", ps_buf->node));
                 status = ERRload_struct(NFM,NFM_E_FAILURE,"%s", ps_buf->node);
                if(status != ERR_S_SUCCESS)
                  {
                    _NFMdebug((fname, "ERRload_struct status <0x%.8x>\n",status));
                    return(NFM_E_FAILURE);
                  }
                 status = NFM_E_MALLOC;
                 return(status);
                }

		strcpy(ps_buf->node,(char *)strtok(NULL," "));
		_NFMdebug((fname,"Node:%s\n",ps_buf->node));

                junk = (char *)strtok(NULL, " "); /* Date is ignored*/		
	     if((ps_buf->date = (char *)malloc(16 * sizeof(char)))==NULL)

              {
                _NFMdebug((fname,"ps_buf->date: <0x%.8x>", ps_buf->date));
                 status = ERRload_struct(NFM,NFM_E_FAILURE,"%s", ps_buf->date);
                if(status != ERR_S_SUCCESS)
                  {
                   _NFMdebug((fname, "ERRload_struct status <0x%.8x>\n",status));
                   return(NFM_E_FAILURE);
                  }
                  status = NFM_E_MALLOC;
                  return(status);             
              }
   
		strcpy(ps_buf->date,(char *)strtok(NULL," "));
		_NFMdebug((fname,"Date:%s\n",ps_buf->date)); 
  

                junk = (char *)strtok(NULL, " "); /* Time is ignored*/
	
             if ((ps_buf->time = (char *)malloc(16 * sizeof(char)))==NULL)
              {
                _NFMdebug((fname,"ps_buf->Time: <0x%.8x>", ps_buf->time));
                 status = ERRload_struct(NFM,NFM_E_FAILURE,"%s", ps_buf->time);
                if(status != ERR_S_SUCCESS)
                  {
                   _NFMdebug((fname, "ERRload_struct status <0x%.8x>\n",status));
                   return(NFM_E_FAILURE);
                  }
                 status = NFM_E_MALLOC;
                 return(status);
              } 
		strcpy(ps_buf->time,(char *)strtok(NULL," "));
		_NFMdebug((fname,"TIme:%s\n",ps_buf->time)); 
            
		junk = (char *)strtok(NULL," "); /** PID is ignored */
/*		junk = (char *)strtok(NULL," ");*/  /** pid is ignored */

              ps_buf->pid = atoi((char *)strtok(NULL, " "));
              _NFMdebug((fname,"Pid:%d\n",ps_buf->pid)); 

              junk = (char *)strtok(NULL," "); /** Path is ignored */

             if((ps_buf->path = (char *)malloc(50 * sizeof(char)))==NULL)
              {
                _NFMdebug((fname,"ps_buf->path: <0x%.8x>", ps_buf->path));
                 status = ERRload_struct(NFM,NFM_E_FAILURE,"%s", ps_buf->path);
                if(status != ERR_S_SUCCESS)
                 {
                  _NFMdebug((fname, "ERRload_struct status <0x%.8x>\n",status));
                   return(NFM_E_FAILURE);
                  }
                 status = NFM_E_MALLOC;
                 return(status);
               }
             strcpy(ps_buf->path,(char *)strtok(NULL," "));
             _NFMdebug((fname,"Path:%s\n",ps_buf->path));

             junk = (char *)strtok(NULL," "); /** Status is ignored */

		strcpy(tmp_value,(char *)strtok(NULL," "));
                if (!strcmp(tmp_value, "OFF"))
                  ps_buf->connect = OFF;
                else
                  ps_buf->connect = ON;
     
		_NFMdebug((fname,"Connect:%s\n",tmp_value));
      }

      else if (flag == SERVER)
        {

          junk = (char *)strtok(buffer, " "); /*SERVER is ignored*/
          junk = (char *)strtok(NULL, " "); /* : is ignored*/
          junk = (char *)strtok(NULL, " "); /* Date is ignored*/
          junk = (char *)strtok(NULL, " "); /* date is ignored*/
          junk = (char *)strtok(NULL, " "); /* Time is ignored*/
          junk = (char *)strtok(NULL, " "); /* time is ignored*/
          junk = (char *)strtok(NULL, " "); /* pid is ignored*/

          ps_buf->spid = atoi((char *)strtok(NULL," "));
          _NFMdebug((fname, "spid:%d\n",ps_buf->spid));
        }
        _NFMdebug((fname, "EXIT Successfully\n"));            
        return(NFM_S_SUCCESS);
}
			



