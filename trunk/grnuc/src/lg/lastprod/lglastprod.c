/* lglastprod.c  --  main, product_path

    This program opens the object space which was passed in on the command line
    and reads header information to determine the last product which wrote
    to the object space.  The program will then execute the product selected.

    Date : June 27, 1990
 
 */

#include <stdio.h>
#include "OMminimum.h"
#include "OMlimits.h"
#include "OMOSfilehdr.h"

#define RUNSETOPTS "/bin/.lgsetoptions"
#define PRODUCT_DATA "/usr/ip32/product_data"

char *product_path();

main( argc, argv )
int   argc;
char *argv[];
{
struct OM_sd_OS_filehdr_OM header;

FILE    *fp;
int      ret0;
int      i;
char     path[300];
char     product[100];
char     command[500];

/*
 *  os name is passed in as first argument
 */
  if ( argc > 0 ) {
    fp = fopen( argv[1] , "r" );
    if ( fp ) {

/*
 *  read name of product that last saved object space
 *  if it exists in product data file, invoke it
 *  otherwise, bring up a form to allow user to select
 *  a product to run
 */

      fread( &header, sizeof( header ), 1, fp );
      strcpy( path, product_path( header.image_name ));
      if ( !strcmp( path, "not found" )) { 
        printf("%s",product_path("Grnuc"));
        sprintf( command, "%sRUNSETOPTS MDEM_PRODUCTS %s \"SELECT.DEM....\"", 
                 product_path("Grnuc"), argv[1] );
      }

      else {                             /* if a known product */

        strcpy( command, "/bin/ksh " );
        strcat( command, path);  
        strcat( command, "/bin/.lgshell " );
/*
 * Handle NC products -- i.e., use IGRproduct entry if it exists
*/
        strcpy( product, "IGR" );
        strcat( product, header.image_name );
        product[3] = tolower( product[3] );
        strcpy( path, product_path( product ));
        if ( strcmp( path, "not found" ))
         { 
          strcpy( command, "/bin/ksh " );
          strcat( command, product_path(product)); 
          strcat( command, "/bin/.lgshell " );
         }
        strcat( command, "-f " );
        strcat( command, argv[1] );
/*
 * Invoke form executable or product shell-script
 */
      }
      system( command ); 
    } 
  }
}

char * product_path( product )
char *product;
{

/* get path of product from product_data */

  FILE *fp;
  char line[1026];
  char *prod_path = 0;
  char *lproduct;
  char error[10];
  
  fp = fopen( PRODUCT_DATA, "r");
  if ( !fp )
  {
    printf("Could not open product_data file\n");
    exit(0);
  }

  lproduct = (char *) malloc( strlen(product) + 3 );
  sprintf( lproduct, "\"%s\"", product ) ;

  while ( fgets( line, 1025, fp ) )
  {
    line[strlen(line) - 1] = 0;
    if ( !strncmp(line, lproduct, strlen (lproduct) ) )
    {
       prod_path = ( char *) (strrchr( line, ' ') + 1);
       fclose( fp );
       return prod_path;
    }
  }
  strcpy( error, "not found");
  return error;
}
