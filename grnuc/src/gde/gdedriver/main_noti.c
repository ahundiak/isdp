/*
$Log: main_noti.c,v $
Revision 1.1.1.1  2001/12/17 22:39:36  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:17:17  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:31:39  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  18:00:25  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/07  00:05:22  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:41:31  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:43:30  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex1.h"
#include "ex1gvare.h"
#include "UMS.h"
#include "grmsg.h"




/* Gadgets */
#define EXIT_NO_PROCESS 4
#define EXIT_AND_PROCESS 1
#define PROCESS_NO_EXIT 2

#define UNIX_INFO   12
#define UOM   13
#define CHECKLIST3   14
#define CHECKLIST4   15
#define CHECKLIST5   16
#define CHECKLIST6   17
#define CHECKLIST7   18
#define SCREEN_TOGGLE	   21
#define VERBOSE_TOGGLE   22
#define CHECKLIST10  32
#define FONTS  38
#define DESIGN_FILE_NAME 27
#define OUTPUT_FILE_NAME 26
#define MESSAGE_FIELD 37
#define ERROR_MESSAGE_FIELD 10
#define APP_NAME_FIELD 30

/* #define ERRORSTRING "Need Design File Name"
   #define FILEERRORSTRING "Design File Name Not Found"
*/

/*  declared in ex1gvar.h
char	unix_info[5], 
	uom_info[5], 
	window_info[5], 
	sview_info[5], 	
	drawsheet_info[5],
	element_info[5], 
	zero_info[5], 
	text_info[5], 
	font_info[5], 
	screen_mode[5], 
	verbose_mode[5], 

	batch_command[128], 
	design_file_name[128];
*/


notification_routine ( f_label, g_label, value, fp )
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
  int i;
  char file_message[80];
  struct stat buf;
  char ERRORSTRING[80];
  char FILEERRORSTRING[80];


  
     switch ( g_label )
     {
            case EXIT_NO_PROCESS:
                   /* Erase the displayed form */

                   FIf_erase ( fp );
		exit_flag = TRUE;
                 break;

            case EXIT_AND_PROCESS:
		if (!strcmp(design_file_name, ""))
	 	{
                  UMSGetByNum(ERRORSTRING,GR_P_EntDgnFlNm,0);
		  FIg_display(fp, ERROR_MESSAGE_FIELD);
                  FIg_set_text( fp, ERROR_MESSAGE_FIELD, ERRORSTRING );
		  FIg_set_value(fp, g_label, 0);
		}
		else
		{
                 if ( stat(design_file_name, &buf) == 0)
                 {
  		  sprintf(batch_command, 
"%s -f %s -b -C'\"ci=run_gde %s %s %s %s %s %s %s %s %s %s %s %s\" exit n'",
		  app_name, 
		  design_file_name, 
		  unix_info, uom_info, window_info, sview_info, drawsheet_info,
		  element_info, zero_info, text_info, font_info, screen_mode, 
		  verbose_mode, output_file);
		
		  printf("COMMAND:  %s\n", batch_command);

		  system(batch_command);

                  FIf_erase ( fp );

		  exit_flag = TRUE;
                 }
                else
                 {
                  UMSGetByNum(FILEERRORSTRING,GR_E_FileNotFound,0);
		  FIg_display(fp, ERROR_MESSAGE_FIELD);
                  FIg_set_text( fp, ERROR_MESSAGE_FIELD, FILEERRORSTRING );
                  FIg_set_value(fp, g_label, 0);
                 }

		}
                 break;

            case PROCESS_NO_EXIT:     

		if (!strcmp(design_file_name, ""))
	 	{
                  UMSGetByNum(ERRORSTRING,GR_P_EntDgnFlNm,0);
		  FIg_display(fp, ERROR_MESSAGE_FIELD);
                  FIg_set_text( fp, ERROR_MESSAGE_FIELD, ERRORSTRING );
		}
		else
		{

                 if ( stat(design_file_name, &buf) == 0)
                 {

  		  sprintf(batch_command, 
"%s -f %s -b -C'\"ci=run_gde %s %s %s %s %s %s %s %s %s %s %s %s\" exit n'",
		  app_name, 
		  design_file_name, 
		  unix_info, uom_info, window_info, sview_info, drawsheet_info,
		  element_info, zero_info, text_info, font_info, screen_mode, 
		  verbose_mode, output_file);

		  printf("COMMAND:  %s\n", batch_command);

		  system(batch_command);
                 }
                else
                 {
                  UMSGetByNum(FILEERRORSTRING,GR_E_FileNotFound,0);
		  FIg_display(fp, ERROR_MESSAGE_FIELD);
                  FIg_set_text( fp, ERROR_MESSAGE_FIELD, FILEERRORSTRING );
                 }
		}
		FIg_set_value(fp, g_label, 0);		
                break;

            case UNIX_INFO:     

		if (value == 1)		 
		  strcpy(unix_info, "-f");
		else 
		  strcpy(unix_info, "");
                 break;

            case UOM:     
		if (value == 1)
		  strcpy(uom_info, "-u");
		else
		  strcpy(uom_info, "");
                 break;

            case CHECKLIST3:     
		if (value == 1)
		  strcpy(window_info, "-w");
		else
		  strcpy(window_info, "");
                 break;

            case CHECKLIST4:     
		if (value == 1)
		  strcpy(sview_info, "-i");
		else
		  strcpy(sview_info, "");
                 break;

            case CHECKLIST5:     
		if (value == 1)
		  strcpy(drawsheet_info, "-d");
		else
		  strcpy(drawsheet_info, "");
                 break;

            case CHECKLIST6:     
		if (value == 1)
		  strcpy(element_info, "-g");
		else
		  strcpy(element_info, "");
                 break;

            case CHECKLIST7:     
		if (value == 1)
		  strcpy(zero_info, "-z");
		else
		  strcpy(zero_info, "");
                 break;

            case SCREEN_TOGGLE:     
		if (value == 1)
		  strcpy(screen_mode, "-s");
		else
		  strcpy(screen_mode, "");
                 break;

            case VERBOSE_TOGGLE:     
		if (value == 1)
		  strcpy(verbose_mode, "-v");
		else
		  strcpy(verbose_mode, "");
                 break;


            case CHECKLIST10:     
		if (value == 1)
		  strcpy(text_info, "-t");
		else
		  strcpy(text_info, "");
                 break;


            case FONTS:     
		if (value == 1)
		  strcpy(font_info, "-e");
		else
		  strcpy(font_info, "");
                 break;

	    case OUTPUT_FILE_NAME:
		FIg_get_text(fp, g_label, output_file);
		break;

	    case DESIGN_FILE_NAME:

		FIg_erase(fp, ERROR_MESSAGE_FIELD); 
		strcpy(file_message, "");
		FIfld_set_text(fp, MESSAGE_FIELD, 0, 0, file_message, FALSE);

		FIg_get_text(fp, g_label, design_file_name);

		break;

	    case APP_NAME_FIELD:

		FIg_get_text(fp, g_label, app_name);

		break;

     }
}
