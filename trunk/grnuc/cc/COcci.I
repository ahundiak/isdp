/*----
%GP% CODE CLASSIFICATION
----
%HD%
     CLASS NAME:    COcc

     METHOD NAMES:  wakeup, sleep, execute

     Abstract:  This command objects loads and executes dynamically c code.
----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:   

     Methods: 

----
%RL%
     RELATIONS REFERENCED:

----
%UI%
     USER INTERFACE DESCRIPTION:

----
%NB%
     NOTES:

----
%CH%
     HGB  01/11/89   : Design date.
----
%PD%
     PROGRAM DESCRIPTION:


     Method Name:

     Method Description:

----*/
/*EH*/

class implementation COcc;

#include <limits.h>
#include <stdio.h>

#include "DIdef.h"	/* DI_PATH_MAX on the SUN */

#include "igrtypedef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include <xc/dload.h>


char read_line ( fet, line )
                 FILE *fet;
                 char *line;
/*
   This routine reads a line on the file specified by fet.  Lines starting
   with a '#' are skipped.
*/
{
  char not_eof, *ptr;

  do
  {
    ptr = line;
    do
     not_eof = fread ( ptr++, 1, 1, fet );
    while (not_eof && (*(ptr - 1) != '\n'));
  }
  while ((*line == '#') && *line);
  *(ptr - 1) = '\0';

  return not_eof;
}

static char *expand_shell_var ( in )
char *in;
/*
   This function expands shell variables in the input string.
*/
{
  static char out [DI_PATH_MAX];
  char        *ptr, *ptr_out, *var_ptr, *var_value, *var_name, *getenv (), c;
  
  for (ptr = in, ptr_out = out, c = 1; *ptr && c; )
    if (*ptr == '$')
    {
      /* we have a variable to expand */
      ptr++;
      var_name = var_ptr = ptr; 

      /* we scan until a space, a / or \0 */
      for (; *ptr != ' ' && *ptr != '/' && *ptr; var_ptr++, ptr++)
        ;
      c = *ptr;
      *var_ptr = '\0';
      
      /* get the value of the shell variable */
      if (!(var_value = getenv ( var_name )))
        /* not known, the value is the variable */
        var_value = var_name;
      for (; *var_value;)
        *ptr_out++ = *var_value++;
      *ptr_out++ = *ptr++ = c;
    }
    else
      if (*ptr == '~')
      {
        /*
         * We mean $HOME
         */
        if (!(var_value = getenv ( "HOME" )))
          var_value = "~";
        for (; *var_value;)
          *ptr_out++ = *var_value++;
        ptr++;
      }
      else
        *ptr_out++ = *ptr++;

  *ptr_out = '\0';
    
  return out;
}


method wakeup ( int pos )
{
  UI_prompt ( "" );
  UI_status ( "" );
  UI_message ( "Dynamic C" );

  return OM_S_SUCCESS;
}


method sleep ( int pos )
{
  UI_message ( "" );
  UI_prompt ( "" );

  return OM_S_SUCCESS;
}


%safe
static char COcc_save_file [DI_PATH_MAX], COcc_init = 0;
%endsafe

method execute ( int *response; char *response_data; int  pos )
{
  int            size;
  struct GRevent event;
  long           mask, temp_msg;
  char           *ccpath, *getenv (); 
  char           fname [DI_PATH_MAX],
                 filepath [DI_PATH_MAX],	/* absolute name for ccpath, or the source */
                 dircour [DI_PATH_MAX],	/* one possible directory */
                 tmp [DI_PATH_MAX];	/* temporary string */
  int            ind, k,	/* mere index */
                 last,	        /* .TRUE. if ccpath has been entirely scanned */
                 success = 1;	/* return code */
  extern char    CS_path_name [];

  if (!COcc_init)
  {
    /* init file name */
    COcc_init = 1;
    COcc_save_file [0] = '\0';
    sprintf ( tmp, "File Name" );
  }
  else
    sprintf ( tmp, "File Name (%s)", COcc_save_file );

  UI_prompt ( tmp );

  mask = GRm_STRING;
  size = sizeof ( event );

  ccpath = getenv ( "CCPATH" );
  if (!ccpath)
    ccpath = getenv ( "ccpath" );

  if (ccpath)
  {
    strcpy ( tmp, "ccpath : " );
    strcat ( tmp, ccpath );
    UI_status ( tmp );
  }
  else
  {
    UI_status ( "NO ccpath (default is .:/)" );
    ccpath = ".:/";
  }

  GRgetevent( &temp_msg, &mask, &size, &event, response, response_data );

  /* before the test */
  if (event.response == STRING)
  {
    if (event.event.keyin [0] != 0)
    {
      strcpy ( fname, expand_shell_var ( event.event.keyin ) );
      if (ccpath == NULL)
 	 strcpy ( COcc_save_file, fname );
      else
        for (ind = 0, success = 0, last = 0; !last && !success; ind++)
        {
          /* Get a directory name */
  	  k = 0;
          while ( ccpath[ind] != 0 && ccpath[ind] != ':' && ind < 512 )
              dircour[k++] = ccpath[ind++];
          if (ccpath[ind] == 0)
             last = 1;
          if (k)
          {
            if (dircour[k-1] == '/')
              dircour[k-1] = 0;
            else
              dircour[k] = 0;

    	    /* Look for the source file */ 
            sprintf ( filepath, "%s/%s", dircour, fname );
            success = !access ( filepath, 04 );
          }
        }

        if (success)
          strcpy ( COcc_save_file, filepath );
        else
          strcpy ( COcc_save_file, fname );
    }
    else
      strcpy ( filepath, COcc_save_file );
    
    /*
     * Remove double '/'
     */
    {
      char *ptr1, *ptr2;

      for (ptr1 = COcc_save_file, ptr2 = COcc_save_file; *ptr2; )
      {
        if (*ptr2 == '/' && *(ptr2 + 1) == '/')
          ptr2++;
        *ptr1++ = *ptr2++;
      }
      *ptr1 = '\0';
    }

    if (success)
    {
      void      *load_descr;
      FILE      *fet;

      strcpy ( tmp, "Loading file " );
      strcat ( tmp, COcc_save_file );
      UI_status ( tmp );

      /* dynamic load ... */
      strcpy ( tmp, "File " );
      strcat ( tmp, COcc_save_file );

      dload_ctrl(INITIAL);
      
      /* before loading a file, we make sure that no other file need to be
         loaded before (listed in cclistlib) */
      fet = fopen ( "cclistlib", "r" );
      if (fet)
      {
        char line [DI_PATH_MAX];
        
        while (read_line ( fet, line )){
	  dload ( expand_shell_var ( line ),INCRLOAD|TEXTREF|TEXTREDEF );
	  }
         fclose ( fet );

	 dload_ctrl(LOADCMPL,(void *)DLOAD_PEND,(int)0);
      }

      if (load_descr = dload ( COcc_save_file ,HIDEGLOBAL|TEXTREF))
      {
            char tmp2 [DI_PATH_MAX];
	    int (*function)();
	    int num;
	    struct symdef *sym_buff;
          
            strcpy ( tmp2, tmp );
            strcat ( tmp2, " executing..." );
            UI_status ( tmp2 );
            
	    num = dload_symbol_lookup(load_descr,(char *)0, &sym_buff);

	    if (num <= 0)
	    {
                sprintf ( tmp, " NO SYMBOLS; NOT loaded" );
	    }
	    else
	    {
	       if (num>1) 
	       {
                  int i;
	       
	       /* if there's more than one symbol, check for symbol _main  */

		  for (i=0;i<num;i++)
		  {
		     if (!strncmp("_main",sym_buff[i].name,5))
		     {
			  function = (int (*)()) sym_buff[i].value;
			  break;
		      }
		   }

                   /* load the first symbol, if _main was not found */

		   if (i==num) function = (int (*)()) sym_buff[0].value;
		}
		else 
		   function = (int (*)()) sym_buff[0].value;
		
		/* call the function */

		function ();
		 
		strcat ( tmp, " executed." );
		*response = TERMINATE;
	     }
       }
       else
         sprintf ( tmp, " NOT loaded" );
    }
    else
      sprintf ( tmp, "CANNOT Access %s", event.event.keyin );

    UI_status ( tmp );
  }

  *response = TERMINATE;
  *response_data = 0;

  return OM_S_SUCCESS;
}

end implementation COcc;
