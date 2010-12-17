#include "machine.h"
#include <stdio.h>
#include <stdarg.h>
#define MAX_MSG_LENGTH 79 


void CLIprint(FILE *file_ptr, char *format, ...)
{ 
      char msg[1024]={"\0"};
      char prnt_str[MAX_MSG_LENGTH+1]={"\0"};
      int start;
      int stop;
      int length;
      int finished=0;
      va_list args;
      start = 0;
      stop  = 0;
     
 


      va_start (args, format);
    
      vsprintf (msg, format, args);

      va_end (args);

      length = strlen(msg);
      while (isspace(msg[start]) && start < length-1)
         start++;
     
      if (strlen (&msg[start]) > MAX_MSG_LENGTH)
      {
         while (!finished)
         { 
            stop = start + MAX_MSG_LENGTH;
            if (stop >= length -1)
               finished = 1;
            else
               while(!(isspace(msg[stop])) && (stop != start) )
               stop--;
            if (stop == start)
            {
               stop = start + MAX_MSG_LENGTH;
            }
            
            strncpy (prnt_str, &msg[start], (stop-start)); 
            prnt_str[MAX_MSG_LENGTH]='\0';
            if (stop >= length -1)
               finished = 1;
            else
               start = stop + 1;

            fprintf (file_ptr, "%s\n", prnt_str);
            prnt_str[0] = '\0'; 

            while (isspace(msg[start]) && start < length-1)
               start++;
         }       
      }
      else
      {
         strncpy(prnt_str, &msg[start], MAX_MSG_LENGTH);
         fprintf (file_ptr,"%s\n", prnt_str);
      }
} 
