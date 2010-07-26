/*
$Log: main_init.c,v $
Revision 1.1.1.1  2001/12/17 22:39:36  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:17:14  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:31:36  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  18:00:23  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/07  00:05:15  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.1  1992/09/09  14:16:30  scott
 * COMMENT : ANSI/SGI fixes
 *
 * Revision 220.0  1992/08/29  06:41:25  root
 * COMMENT : Corresponds to Rel201.6 in 2.0.1 RCS
 *
 * Revision 201.6  1992/07/13  20:43:27  tim
 * COMMENT : added Log variable
 *
*/

#include "stdio.h"
#include "tools.h"
#include "FI.h"
#include "FIdyn.h"
#include "ex1.h"
#include "ex1gvare.h"

#define MAIN_FORM 1
#define APP_NAME_FIELD 30






void notification_routine();
void continuous_routine();

Form main_form_id;
int form_created, main_displayed;


/*  main_form()
 *
 *  This function creates the wall form, creates a few gadgets
 *  dynamically, and sets up some groups.
 *
 *  NOTE:  to save some space, we are ORing the status
 *  returns of some groups of function calls and checking
 *  form an error once.  This is not neccessarily a
 *  recommendation of how to utilize the status returns;
 */

 /* 
    2/13/92 TGM changed product_path to use second field in product_data 
                changed application name field to display path to Ems 
                since it expects the contents of the field to be a path   */
 
 int main_form()
{
  int sts;
  char *product_path();
  char form_name[256];
  char appl_name_display[80];


  strcpy( form_name, product_path( "GRNUC" ));
  sprintf( form_name, "%s/%s", form_name, "config/english/forms/GRDesignFile");

  sts = FIf_new ( MAIN_FORM, form_name, notification_routine, &main_form_id );
  if ( chkerror( sts, "creating main form" ) )
    return (1);
  form_created = TRUE;

/* set APP_NAME_FIELD to the path to ems as default */
  strcpy(appl_name_display,product_path("EMS"));
  if (strcmp(appl_name_display,"not found") )
   {
    strcat(appl_name_display,"/bin/ems"); 
   }
  else
   {
    strcpy(appl_name_display,product_path("DRAFT"));
    if (strcmp(appl_name_display,"not found") )
     {
       strcat(appl_name_display,"/bin/draft"); 
     }
    else
     {
      strcpy(appl_name_display,product_path("MDS"));
      if (strcmp(appl_name_display,"not found") )
       {
         strcat(appl_name_display,"/bin/mds"); 
       }
      else
       {
        strcpy(appl_name_display,"");
       }
     }
   }
    

  FIfld_set_default_text(main_form_id,APP_NAME_FIELD,0,0,appl_name_display,1);

/*
 *  Display the main form and set the displayed
 *  flag to TRUE.
 */
  sts = FIf_display ( main_form_id );
  chkerror( sts, "displaying the main form" );
  main_displayed = TRUE;

  strcpy(output_file, "output");
  strcpy(app_name, appl_name_display);
  return (1);
}

char *product_path(product) 
char *product;
{
  FILE *fp;
  char line[1026];
  char *prod_path = 0;
  char error[100];
  int  i=0;

  fp = fopen( "/usr/ip32/product_data", "r");
  if ( !fp )
  {
    printf("Could not open product_data file\n");
    exit(0);
  }

  while ( fgets( line, 1025, fp ) )
  {
    i=0;
    line[strlen(line) - 1] = 0;
    while (line[i] != '/' )
        i=i+1;

    if ( !strncmp(&line[i+1],product, strlen (product) ) )
    {
       prod_path = ( char *) (strrchr( line, ' ') + 1);
       fclose( fp );
       return prod_path;
    }
  }
  strcpy( error, "not found" );
  return( error );
}
