#include <X11/Xlib.h>

#include <stdio.h>

#include "FI.h"
#include "FEI.h"
#include "FIdyn.h"
#include "UMS.h"
#include "XMB.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

char empty_string[100];

extern Form work_form;

extern Display *display;

/*----------------------------------------------------------------------*/

void Redisplay (Form form)
{
int xsize, ysize;

   FIf_get_size (form, &xsize, &ysize);

   FIf_paint_area (form, 0, 0, xsize, ysize);
}

/*----------------------------------------------------------------------*/

void Refresh_work_form(void)
{
   Redisplay (work_form);
}

/*--------------------------------------------------------------------------*/

void Report_fatal_form_error (int status,
                             char file_string[200])
{
char error_string[1000];
char extra_string[200];

   UMSGetByNum (error_string, MB_E_STATUS, "%d", status);
   strcat (error_string, "\n");

   if (status == FI_FORM_FILE_NOT_FOUND)
      UMSGetByNum (extra_string, MB_E_CANTLOCATE, "%s", file_string);
   else
      UMSGetByNum (extra_string, MB_E_BADFORMAT, "%s", file_string);
      
   strcat (error_string, extra_string);

/*
   FI_message_box (FI_CURRENT_SCREEN, -1, -1, "Fatal Error",
                   FI_RED, "swiss742b", 25.0,
                   error_string, FI_BLACK, "swiss742b", 25.0, 
                   FI_LEFT_JUSTIFIED, 60);
*/
   fprintf (stderr, "Exiting XMB due to:\n%s\n", error_string);
   exit(1);  /* dmb:04/13/93:Added arg to satisfy ANSI build on SUNOS5 */
}

/*--------------------------------------------------------------------------*/

void Report_fatal_error (char *error_string)
{
/*
   FI_message_box (FI_CURRENT_SCREEN, -1, -1, "Fatal Error",
                   FI_RED, "swiss742b", 25.0,
                   error_string, FI_BLACK, "swiss742b", 25.0, 
                   FI_LEFT_JUSTIFIED, 60);
*/
   fprintf (stderr, "Exiting XMB due to:\n%s\n", error_string);
   exit(1);  /* dmb:04/13/93:Added arg to satisfy ANSI build on SUNOS5 */
}

/*--------------------------------------------------------------------------*/

void Report_nonfatal_error (char *error_string)
{
   FI_message_box (FI_CURRENT_SCREEN, -1, -1, "Error",
                   FI_YELLOW, "swiss742b", 25.0,
                   error_string, FI_BLACK, "swiss742b", 25.0, 
                   FI_LEFT_JUSTIFIED, 60);
}

/*------------------------------------------------------------------------*/

void Form_multi_line_string (Form form,
                        int label,
                        char *string)
{
int rows, x, dummy;
char t_str[2000];
char line[500];	

      FIfld_get_num_rows (form, label, &rows);

      t_str[0] = 0;
      for (x = 0; x < rows; x++)
      {
         FIfld_get_text (form, label, x, 0, 499, (unsigned char *)line, &dummy, &dummy);

         strcat (t_str, line);
         if (x != (rows - 1))
            strcat (t_str, "\n");

         if ((x == (rows - 1)) &&
             (strlen (line) == 0))
                t_str[strlen(t_str)-1] = '\0';
      }
      strcpy (string, t_str);
}

/*--------------------------------------------------------------------------*/

void Break_up_multi_line_string (Form form,
                                int label,
                                char *string)
{
int i, index;
int spots[100];
char t_str[500];
   
   FIfld_set_num_rows (form, label, 0); 
  
   if (strlen (string) != 0)
   {
      index = 0;	
   
      for (i = 0; i < strlen (string); i++)
         if (string[i] == '\n')
         {
            spots[index] = i;
            index++;
         }
         
      if (index > 0)
         for (i = 0; i < index; i++)
         {
            if (i == 0) 
            {
               if (spots[0] > 0)
               {
                  strncpy (t_str, string, spots[0]);
                  t_str[spots[0]] = '\0';
                  FIfld_set_text (form, label, 0, 0, t_str, 0);
               }
               else
                  FIfld_set_text (form, label, 0, 0, "", 0);
            }
            else
               if ((spots[i] - spots[i-1]) > 1)
               {
               	  strncpy (t_str, &(string [spots[i-1]+1]),
               	                  spots[i] - (spots[i-1] + 1));
               	  t_str[spots[i] - (spots[i-1] + 1)] = '\0';
               	  FIfld_set_text (form, label, i, 0, t_str, 0);
               }
               else
                  FIfld_set_text (form, label, i, 0, "", 0);
         }

      if (index == 0)
         FIfld_set_text (form, label, 0, 0, string, 0);
      else
         if ((spots[index-1]+1) < strlen (string))
         {
            strcpy (t_str, &(string[spots[index-1]+1]));
            FIfld_set_text (form, label, index, 0, t_str, 0);
         }       
   }
}

