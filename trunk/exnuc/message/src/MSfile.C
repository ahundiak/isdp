#include "ctype.h"
#include "malloc.h"
#include "igrtypedef.h"
#include "string.h"
#include "stdio.h"
#include "exms.h"
#include "mspriv.h"
#include "msdef.h"
#include "msmacros.h"
#include "exmacros.h"
#include "exlocale.h"
#include <UMS.h>

extern IGRshort           MS_Gs_messages_on;
static int              first_msinit = 1;
static first = 1;
static struct MS_session_config *MS_session_config = 0;
static int file_found = 0;


int MS_init_file (rc, in_file)
IGRlong *rc;
IGRchar *in_file;
{
char *comma;
comma = (char *)strchr(in_file, ',');
  if ( comma )
   {
   *comma = 0;
   *rc=UMSInitMsg(in_file, UMS_MESSAGE );
   }
  else
  {
   *rc=UMSInitMsg(in_file,0);
  }
 if (*rc != UMS_S_SUCCESS)
  {
   printf("error in opening message file %s ,%d\n",in_file,*rc);
  }

    return (1);
}

/*
 *	Read a file and call MS_init_file for each of the 
 *	file entries.
 *
 *	This is the routine that should be called from the wings exec
 *
 *	This reads in the file 'message_file' from the config/mod_type_x
 *	directory
 */

void MS_init_files(message_file)
IGRchar *message_file;
{
    IGRint status = 1, jj, sts;
    IGRchar filename [132], messageFile[132], msg_file[132], path[80];
    char temp_path[80];
    FILE *fp;
    IGRlong rc;

    char MSlanguage[15];
    char config_name[15];
    int found;
    struct MS_session_config *temp_session;
    struct MS_session_config *temp1_session;
    char *slash;

     ms$function ();
     MS_Gs_messages_on = 1;
    if (strlen (message_file) ){
        strcpy (filename, message_file);
    }
    else {
        strcpy (filename, "message_file");
    }
    ex$language (language = MSlanguage );
    for (jj = 0; status == 1; jj++)
     {
     if (status = ex$get_path (index = jj, path = path, 
            len = sizeof (path)))
       {
        strcpy (temp_path,path);
        slash = strrchr(temp_path,'/');
        if (slash)
          *slash = 0;
        slash = strrchr(temp_path,'/');
        sprintf (messageFile, "%sconfig/%s/message_file",path, MSlanguage);
        if (slash)
          {
          slash++;
          strncpy(config_name, slash, 14);
          config_name [14] = 0;
          /*look to see if this config is already there*/
          found = 0;
          temp1_session = MS_session_config;
          while ( temp1_session )
            {
            sts = strcmp (temp1_session->config_name,config_name);
            if ( !sts )
              {
              found = 1;
              break;
              }
            else 
              {
              temp1_session = temp1_session -> next_session_config;
              }
             }/*end while*/
         if (!found)
           {
            /*did not find it read in file and add to list*/
            if ( fp = fopen (messageFile, "r") )
             {
              char temp_file[256];
              if (! MS_session_config)
                {
                MS_session_config = (struct MS_session_config *)
                              malloc (sizeof (struct MS_session_config));
                temp1_session = MS_session_config;
                temp1_session->config_memory = 0;
                strncpy(temp1_session->config_name,config_name,14);
                temp1_session->next_session_config = 0;
                }
              else
                {
                temp_session = MS_session_config;
                while (temp_session->next_session_config != NULL)
                   {
                   temp_session = temp_session->next_session_config;
                   }
                 temp1_session = (struct MS_session_config *)
                              malloc (sizeof (struct MS_session_config));
                 temp_session->next_session_config = temp1_session;
                 strncpy(temp1_session->config_name,config_name,14);
                 temp1_session->config_memory = 0;
                 temp1_session->next_session_config = 0;
                                
                }
              file_found = 1;
              while (!feof (fp))
               {
               fscanf (fp, "%[^\n]\n",temp_file);
               if ( temp_file[0] == '/')
                  {
                  strcpy(msg_file, temp_file);
                  }
                 else
                  {
                  sprintf (msg_file, "%sconfig/%s/%s",path,
                                        MSlanguage,temp_file);
                  }
                  MS_init_file (&rc, &msg_file[0]);
               }
               fclose (fp);
            }/*end if found file*/
           }/*end if not found in session config*/
          }

        }/*end if path defined*/
    }/*end for*/
    if (!file_found) {
        printf ("\n NO message files found \n");
    }
     if ( first )  
         {
         first = 0;
         MSgetfont();/*create message form*/
         }

}

void MS_file_init ( message_file, msg_file )
IGRchar *message_file;
IGRchar *msg_file;
{
    IGRlong rc;
    
    if (msg_file) {
        MS_init_file (&rc, msg_file);
    }
    if (message_file) {
        MS_init_files (message_file);
    }
    if (!message_file && !msg_file) {
        MS_init_files ("message_file");
    }
}

