
           /*************************************/
           /*                                   */
           /*          symbol_dir.c             */
           /*                                   */
           /*    This file allows the operator  */
           /* to add a directory to the symbol  */
           /* file search path.                 */
           /*                                   */
           /*      Programmer: Mack Draper      */
           /*      Date:       Feb 23, 1989     */
           /*                                   */
           /*************************************/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <fcntl.h>

#include "FI.h"
#include "FIdyn.h"
#include "XMBpriv.h"
#include "UMS.h"
#include "XMB.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

#define CUR_DIR_FLD    15
#define SYM_FILES_FLD  13
#define NEW_DIR_FLD    17
#define ADD_DIR_BTN    19


#define NULLchar	'\0'	/* The NULL character to pad end of strings */

/*************************************/
/* Global variables for this Command */
/*************************************/

Form Sym_dir_form = NULL;

/************************************/
/*  External variable declarations  */
/************************************/

extern Form work_form;
extern char execute_dir[200];

extern Form button_form;

extern char SYM_search_directory[100][300];
extern int  SYM_dir_count;
extern char symbol_search_string[5000];

extern char language[80];
extern void fi_button_form();
extern char *expand_shell_vars();

/*--------------------------------------------------------------------*/
/* Document:	BSfilter
 * Abstract:	This routine returns non zero if a file fits
 *	 the Bit Stream Font format, and 0 if it does not.
 * Algorithm:	The file name is checked for a '.' in it.  If it has
 *	 a period then the text to the left of it is converted to a
 *	 number.  If this is successful, then the file is opened and
 *       the first 4 bytes are tested against
 *	"FONT" (which is the designated font format.
 * Date:	17-JUL-1989
 *********************************************************************/
 /* filters BS */
static int BSfilter(char *font_file)
{
  int	fdes, bytesread;
  char	buf[5];

  if( (fdes = open(font_file, O_RDONLY, 0)) < 0)
    {
	return 0;
    }

  bytesread = read(fdes, buf, 4);
  buf[4] = NULLchar;
  close(fdes);

  if(strcmp(buf, "FONT")) 
    {
      return 0;
    }
  else
    {
      return 1;
    }
}

/**********************************************************************/
/*                         list_symbol_files()                        */
/*                                                                    */
/*    This function is used to read the contents of a directory and   */
/* then list all valid symbol files to the Symbol directory search    */
/* path form.  These items will be listed to the SYM_FILES_FLD gadget.*/
/**********************************************************************/

static void list_symbol_files (char sym_dir[300])
{
    int	   x;
    struct dirent     *dp;
    DIR    *dirp;

    char form_filename[1000][20];
    char temp_filename[20];
    char t_str[1000], t_str2[200];
    int y, z;

    FIfld_set_num_rows (Sym_dir_form, SYM_FILES_FLD, 0);

    dirp = opendir ( sym_dir );
    if ( dirp == NULL )
    {
       UMSGetByNum (t_str, MB_E_BADOPNDIR, 0);
       sprintf (t_str2, " %s", sym_dir);
       strcat (t_str, t_str2);
       print_error (Sym_dir_form, 10, t_str);
       FIfld_set_text (Sym_dir_form, NEW_DIR_FLD, 0, 0, "", 0);
    }
    else
    {
        UMSGetByNum (t_str, MB_I_SCANFILE, 0);
    
	x = 0;
	while (( dp = readdir ( dirp )) != NULL )
	{	
	    if (( strcmp ( dp->d_name, ".." ) != (int) NULL ) &&
		( strcmp ( dp->d_name, "." ) != (int) NULL ))
	    {
                strcpy (t_str, sym_dir);
                strcat (t_str, "/");
                strcat (t_str, dp->d_name);

	        if ( BSfilter ( t_str ) )
		{
                   strcpy(&(form_filename[x][0]),dp->d_name);
                   x++;
		}
	    }
	}

	if ( x )   /* There are forms in the directory */
	{
           if (x == 1)   /* Only one entry, so no need to sort */
	   {
              strcpy(t_str, &(form_filename[0][0]));

              FIfld_set_text(Sym_dir_form, SYM_FILES_FLD, 0, 0, 
                                      t_str, 0);
	   }
           else   /* Need to sort the files into alphabetical order */
           {      /* before placing them into the form.             */

              for (y=0; y < x - 1; y++)
              {
                 for (z=y+1; z < x; z++)
                 {
                    if (strcmp (&(form_filename[y][0]),
                                &(form_filename[z][0])) > 0)
                    {
                       strcpy(temp_filename, &(form_filename[y][0]));
                       strcpy(&(form_filename[y][0]),&(form_filename[z][0]));
                       strcpy(&(form_filename[z][0]),temp_filename);
                    }
                 }
              }

              /* Now that they are sorted, place them into the form */

              for (y = 0; y < x; y++)
              {
                 strcpy(t_str, &(form_filename[y][0]));

                 FIfld_set_text(Sym_dir_form, SYM_FILES_FLD, y, 0, 
                                         t_str, 0);
              }
           }
/*
           FIfld_set_active_row (define_form, FORM_LIST, 0, 0);
*/           
           FIg_erase (Sym_dir_form, 10);
	}
	else
	{
           UMSGetByNum (t_str, MB_E_NOSYMFIL, 0);
	   print_error (Sym_dir_form, 10, t_str);
        }

	closedir ( dirp );
    }
}

/**********************************************************************/
/*                        fi_sym_dir_form()                           */
/*                                                                    */
/*    This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!)                                */
/*                                                                    */
/*    This form is used to allow the operator to change the default   */
/* settings for a new button gadget, or alter the settings of an      */
/* existing button gadget.                                            */
/**********************************************************************/

/* ARGSUSED */
void fi_sym_dir_form (int    form_label,
                     int    gadget_label,
                     double value,
                     Form   form)
{
    int x;
    int sym_found;
    int state;
    char t_str[200], t_str2[400];
    int dummy_int;

   FIg_erase (Sym_dir_form, 10);   /* Error message field */

   switch (gadget_label)
   {
       case NEW_DIR_FLD:

          /*  First de-select all entries in CUR_DIR_FLD  */

          for (x = 0; x < SYM_dir_count; x++)
	    {
                FIfld_set_select (Sym_dir_form, CUR_DIR_FLD, x, 0, 0); 
	    }

          FIfld_get_text (Sym_dir_form, NEW_DIR_FLD, 0, 0, 200,
             (unsigned char *)t_str, &dummy_int, &dummy_int);

          strcpy (t_str2, t_str);
          strcpy (t_str, expand_shell_vars (t_str2));

          FIfld_set_text (Sym_dir_form, NEW_DIR_FLD, 0, 0, t_str, 0);

          list_symbol_files (t_str);
          break;         

       case CUR_DIR_FLD:
          
          FIfld_set_select (Sym_dir_form, CUR_DIR_FLD, (int)value, 0, 1);
          FIfld_get_text (Sym_dir_form, CUR_DIR_FLD, (int)value, 0, 200,
            (unsigned char *)t_str, &dummy_int, &dummy_int);
          list_symbol_files (t_str);
          break;
     
       case ADD_DIR_BTN:

  	  sym_found = 0;
   
          FIfld_get_text (Sym_dir_form, NEW_DIR_FLD, 0, 0, 190, (unsigned char *)t_str, &x, &x);
          if (strlen (t_str) > 0)
          {
             x = strlen (t_str);
             if (t_str[x-1] == '/')
                t_str[x-1] = '\0';

             for (x = 0; x < SYM_dir_count; x++)
                {
                   if (strcmp (t_str, &SYM_search_directory[x][0]) == 0)
                   {
                      sym_found = 1;
               	      break;
                   }
                }
          }
           
          if ((sym_found == 0) &&    /* Wasn't in the list, so add it */ 
              (strlen (t_str) > 0))
          {
             strcpy (&SYM_search_directory[SYM_dir_count][0], t_str);
             FIfld_set_text (Sym_dir_form, CUR_DIR_FLD, SYM_dir_count, 0,
                             &(SYM_search_directory[SYM_dir_count][0]), 0);
             SYM_dir_count++;
             FI_append_symbol_path (t_str);
          }
          FIg_set_state_off (Sym_dir_form, ADD_DIR_BTN);
          break;

       case SYM_FILES_FLD:

          FIfld_get_select (Sym_dir_form, SYM_FILES_FLD, (int)value, 0, &state);

          if (state == 0)
             FIfld_set_select (Sym_dir_form, SYM_FILES_FLD, (int)value, 0, 1);
          else
          {
             FIfld_get_text (Sym_dir_form, SYM_FILES_FLD, (int)value, 0, 200,
               (unsigned char *)t_str, &dummy_int, &dummy_int);

             if ( button_form )
             {
                FIf_is_displayed (button_form, &state);
                if (state == 1)
                {
                   FIfld_set_text (button_form, 40, 0, 0, t_str, 0); /* FONT_FLD */
                   fi_button_form (111, 40, (double)0, button_form);   /* Force update  */
                }
             }
          }
          break;

       case FI_CANCEL:
   
          FIf_erase (Sym_dir_form);
          FIg_set_state_off (Sym_dir_form, FI_CANCEL);

          if ( button_form )
          {
             FIf_is_displayed (button_form, &state);
             if (state == 1)             
                FIg_set_state_off (button_form, 30);   /* ADD_DIRECTORY_BTN */
          }
          break; 
   }
}

/*--------------------------------------------------------------------*/

void Display_symbol_dir_form (void)
{
   int x, state;
   char t_str[1000];
   int status;

   if (Sym_dir_form == NULL)
   {
      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/MBSelSymDir");
      status = FIf_new (444, t_str, (int (*)())fi_sym_dir_form, &Sym_dir_form);

      if ( status != FI_SUCCESS )
         Report_fatal_form_error (status, t_str);
   }                

   /* Set up Symbol Directory form */

   FIfld_set_num_rows (Sym_dir_form, CUR_DIR_FLD, 0);
   FIfld_set_num_rows (Sym_dir_form, SYM_FILES_FLD, 0);
   FIfld_set_text (Sym_dir_form, NEW_DIR_FLD, 0, 0, "", 0);
   FIg_set_state_off (Sym_dir_form, ADD_DIR_BTN);

   for ( x = 0; x < SYM_dir_count; x++ )
     {
       FIfld_set_text (Sym_dir_form, CUR_DIR_FLD, x, 0,
                         &(SYM_search_directory[x][0]), 0);
     }

   if ( button_form )
   {
      FIf_is_displayed (button_form, &state);
      if (state == 1)             
         FIf_set_location (Sym_dir_form, 415, 510);
   }

   FIf_display ( Sym_dir_form );
}

