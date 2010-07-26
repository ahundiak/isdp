/* lgsetoptions.c -- prod_list, get_last_time, get_check_list,
 *                   display_error, product_path, find_file, create_pref_file,
 *                   notification_routine, depends_on_grnuc, get_runname
 *
 *   Brings up a form to select a product's command line options.  These 
 *   options are stored in the user's $HOME/lg directory.  Past options,
 *   taken from $HOME/lg/"product"_pref, are displayed when the form is 
 *   brought up.  The configuration file(GRlgcfg) is used to determine
 *   what options will be displayed on the form to be selected.
 *
 *   Arguments : .lgsetoptions Product [OS filename] [Def. Product]
 *               (A special product, SELECT_DEM is passed when the scroll
 *                window to select a DEM product is required.  The list of
 *                DEM products is extracted from the product_data file.
 *
 *   Action Buttons : Check - save the options selected in the user's 
 *                            $HOME/lg directory.  If SELECT_DEM is the
 *                            product, also execute the product selected
 *                            from the scroll window.
 *                    X     - exit with no save (or execute)
 *         Restore Defaults - read the product configuration file and apply
 *                            the listed options to the form.
 *
 *   Files : $HOME/"product"_pref
 *           $GRNUC/config/english/forms/GRlgopt
 *           $GRNUC/config/english/forms/GRlgcfg
 *           /usr/ip32/product_data
 *
 *   Date : June 27, 1990
 *
 *
 *   Check to disregard MODEL as a Product. TGM 11/26/90
 *   Modify for EMS productization - display logo instead of product name
 *                                   clean up ansi compile errors - jet 3/20/93
 *
 *
 */

#ifdef X11
#include <X11/Xatom.h>
#endif
#include "dpgraphics.h"

#include <stdio.h>
#include <math.h>
#ifdef X11
#include <time.h>
#else
#include <tools.h>
#endif
#include <FI.h>

#define MAXCHECK 9
#define BASE     100
#define STRSIZE  256

#ifdef X11
  struct vlt_slot
  {
     unsigned long pixel;
     unsigned short red;
     unsigned short green;
     unsigned short blue;
     char flags;
     char pad;
  };
#endif


struct check {
  char option[10];
  int  add;
  int  field;
}; 
struct check check_list[MAXCHECK];

#define MODEL "Model"
#define SHOW_PRODUCTS "SELECT.DEM...."
#define FORM_NAME "config/english/forms/GRlgopt"
#define LGCONFIG "config/english/forms/GRlgcfg"
#define LG "lg"
#define BIN "bin"

#define FALSE 0
#define TRUE 1

#define FILEPROD 16
#define PRODUCTS 18
#define DIR      27
#define LABEL    11
#define SOURCE   25
#define ERROR    10

#define CHECK0   100
#define CHECK1   101
#define CHECK2   102
#define CHECK3   103
#define CHECK4   104
#define CHECK5   105
#define CHECK6   106
#define CHECK7   107
#define CHECK8   108

#define FIELD0   200
#define FIELD1   201
#define FIELD2   202
#define FIELD3   203
#define FIELD4   204
#define FIELD5   205
#define FIELD6   206
#define FIELD7   207
#define FIELD8   208

#define DEFAULT  12

/* Declaration of global variables */

int SHOW_DEM = 0;
int RUN_IT = 0;

int  maxline=0;
char CURRENT_PROD[STRSIZE];
char CURRENT_LOGO[STRSIZE];
char *prodlist[STRSIZE];
char *logolist[STRSIZE];

int status;

Form my_form;

long swiss14_desc;

char key_buf[256];

long event;
int exit_flag = FALSE;

#ifndef X11
int vs;
#endif
    
void prod_list();
void get_last_time();
void get_check_list();
void display_error();
char *product_path();
char *find_file();
int get_runname();


int create_pref_file( )

/*
 *  This function is called when the user selects a product to run 
 *  and "accepts" it ( hits the check box )
 *
 *  Its mission in life is to write the product's command line
 *  to the looking glass preference file in the user's $HOME/lg
 *  directory.  The name of the preference file is "runname"_pref,
 *  where runname is a tolower() of the first field of the product's
 *  product_data table entry, e.g., emspp
 *
 *  To accomplish this mission, find_file() is called to look for a file
 *  called "runname" in the bin directory of the product or any submodule
 *  of the product, where runname is as defined above, e.g., emspp. 
 *  Once a file of that name is found in one of the bin directories, a
 *  command string is constructed of the form:
 * 
 *     /usr/ip32/emsppp/bin/emspp
 *
 *  where emspp is derived from the runname and the directory path is
 *  extracted from the product data file.  Note that if there were no
 *  emspp file in the location specified by te "Emspp" product, the
 *  software would continue to search for the file in any bin directory
 *  of all products in the dependency list of the product's product_data
 *  table entry.
 *
 *  The options specified by the user are added to this command line
 *  resulting in the final command string that invokes the product.  This
 *  command line is then written to the preference file.
 */

{
  FILE *fp;
  int   i;
  int   state;
  char  filename[STRSIZE];
  char  buffer[STRSIZE];  
  char  home[STRSIZE];
  char *tmp;
  char  product[STRSIZE];
  char  prod[STRSIZE];
  char  command[1000];
  char  os_name[80];

  strcpy( home, getenv("HOME"));

  strcpy ( product, CURRENT_PROD );
  tmp = (char *)strrchr( product, '/' );
  if ( tmp ) strcpy( prod, &tmp[1] );
    else strcpy( prod, product );
  FIg_get_text( my_form, DIR, os_name );

  for ( i = 0; i < strlen(prod); i ++ )
    {
    prod[i] = tolower( prod[i] );
    }
  sprintf( filename, "%s/%s/%s_pref", home, LG, prod );

  sprintf( buffer, "%s/%s", BIN, prod );
  prod[0] = toupper( prod[0] );
  strcpy( command, find_file( prod, buffer ));

    for ( i = 0 ; i < MAXCHECK ; i ++ )
      {
      if ( check_list[i].option[0] != '\0' )
        {
        FIg_get_state( my_form, 100+i, &state );
        if ( state & check_list[i].add )
          {
          if ( check_list[i].field )
            {
            FIg_get_text( my_form, 200+i, buffer );
            if ( ( strlen( buffer ) == 0 ) ||
                 ( ( strlen( buffer ) < 3 ) && ( buffer[0] == '"' ) ) ) {
              FIfld_pos_cursor( my_form, 200+i, 0, 0, 0, 0, 0, 0 );
              return( 0 );
            }
         /*
          * Note that single tics are added around the value field
          * associated with an option. This protects them from the shell
          */
            sprintf( command, "%s %s \'%s\'", 
                     command, check_list[i].option, buffer );
            }
          else
            {
            sprintf( command, "%s %s", command, check_list[i].option );
            }
          }
        else if ( ! check_list[i].add & ! state )
          {
          sprintf( command, "%s %s", command, check_list[i].option );
          }
        }
      }

  strcat( command, " $*" );
  fp = fopen( filename, "w");
  if ( !fp )
  {
    printf("Could not open product preference file\n");
    exit(0);
  }
  fprintf( fp, "%s\n", command );
  close( fp );

  if( RUN_IT ) {
    command[strlen( command ) - 3] = '\0';
    strcat( command, " -f " );
    strcat( command, os_name );
    strcpy( buffer, "/bin/ksh " );
    strcat( buffer, command );
    printf( "%s\n", buffer );
    FIf_erase ( my_form );
    system( buffer  );
    return ( 0 );
  }
  else
   return( 1 );
}

void notification_routine ( form_label, gadget_label, value, form )
  int	  form_label;
  int	  gadget_label;
  double  value;
  Form	  form;
{
  int  state;
  char file[100];

    FIg_erase( my_form, ERROR ); 
    switch ( gadget_label )
      {
			
	  case FI_ACCEPT:	
                if ( create_pref_file( ) )
                  {
    	 	  FIf_erase ( form );
                  }
	        FIg_set_state_off ( form, gadget_label );
                break;

	  case FI_CANCEL:	

		FIf_erase ( form );
		FIg_set_state_off ( form, gadget_label );
		break;		
				

	  case DEFAULT:	
                get_check_list();
		FIg_set_state_off ( form, DEFAULT );
                break;

	  case PRODUCTS:
                if ( SHOW_DEM )
                  {
		  FIg_get_text( my_form, PRODUCTS, file );
		  get_runname( file, CURRENT_PROD, prodlist, logolist,&maxline);
                  FIg_erase( my_form, LABEL );
                  FIg_set_text( my_form, LABEL, file );
                  FIg_display( my_form, LABEL );
                  get_check_list();
                  get_last_time();
                  }
                break;

	  case 100:	
	  case 101:	
	  case 102:	
	  case 103:	
	  case 104:	
	  case 105:	
	  case 106:	
	  case 107:	
	  case 108:	
                FIg_get_state( my_form, gadget_label, &state );
                if ( state & check_list[gadget_label-100].field )
                  {
                  FIg_display( my_form, gadget_label+100 );
                  FIfld_pos_cursor( my_form, gadget_label+100, 
                                    0, 0, 0, 0, 0, 0 );
                  }
                else
                  {
                  FIg_erase( my_form, gadget_label+100 );
                  }
                break;

      }
}

main ( argc, argv )
int   argc;
char *argv[];
{
  struct    vlt_slot * vlt;
  int       slots;
  char      tmp[256];

#ifdef X11
  Display   *xdisplay;
  char      *display_name;
  int 	    xvs;
  int 	    i;

  if ((xdisplay = XOpenDisplay(display_name)) == NULL)
  {
     (void) fprintf(stderr, "lgsetoptions.c: Cannot connect to X server %s\n",
		XDisplayName(display_name)); 
     exit(-1);
  }
  xvs = DefaultScreen(xdisplay);

  FSEnter(xdisplay, 0);
  FI_enter (xdisplay, DefaultColormap(xdisplay, xvs), 32);  
					/* Initialize the forms system */

#else
  Enter_tools ();

  Set_logo ( "Options" );

  Inq_displayed_vs (&vs);

  /* Load vlt */
   
  Get_fixed_vlt ( &vlt, &slots );

  Loadvlt ( vs, vlt, slots );

  Enable_events ( FI_EVENT_MASK );

  FI_enter ( );  /* Initialize the forms system */
#endif

  FI_set_symbol_path ( "../../sym" );
  FI_set_form_path ( "." );


  /*
   Load form into memory.  The function notification_routine will be called
   whenever a gadget is updated.  
  */

  strcpy( tmp, product_path( "Grnuc" ));
  sprintf( tmp, "%s/%s", tmp, FORM_NAME );
  status = FIf_new ( 100, tmp, notification_routine, &my_form );
  if ( status ) 
  {	
    fprintf(stderr,"FORM <%s> CREATE ERROR %d\n",tmp,status );
    return(FALSE);
  }

/* argc == 4 => .lgsetoptions has been called to display MDEM products
 *              so that the user can select a product to run, optionally
 *              set runtime options and then invoke the product.
 * 
 *              The call looks like:
 *                /bin/ksh -c "echopath GRNUC'/bin/.lgsetoptions MDEM_PRODUCTS
 *                             filename SELECT.DEM...."
 */

  if( argc == 4 ) {
    strcpy ( CURRENT_PROD, argv[1] );
    FIg_set_text( my_form, DIR, argv[2] );  /* display file name */
    FIg_set_text( my_form, LABEL, argv[1] );

    if( !strcmp( argv[3], SHOW_PRODUCTS ) ) {
      FIg_erase( my_form, FILEPROD );
      FIg_set_text( my_form, FILEPROD, "Product:" );
      FIg_display( my_form, FILEPROD );
      FIg_set_text( my_form, PRODUCTS , "" );

      FIg_display( my_form, PRODUCTS );
      SHOW_DEM = TRUE;
      prod_list(); 
      if( strcmp( argv[2], "" ) )          
      {
        RUN_IT = TRUE;           /* if filename not null, enable execution */
      }  
    }
  }
  else
  {
    strcpy ( CURRENT_LOGO, argv[1] );
    prod_list(); 
    get_runname( CURRENT_LOGO, CURRENT_PROD, prodlist, logolist,&maxline);
    FIg_set_text( my_form, LABEL, CURRENT_LOGO );
  }

  get_check_list();

  get_last_time();

	/* display the form */

  FIf_display ( my_form );

  /* This will process all forms until 
     there are no forms left displayed */

  FI_process_forms();

#ifdef X11
  XCloseDisplay(xdisplay);
#else
  Exit_tools();
#endif
}

char * product_path( product )
char *product;

/*  This function accesses product_data to get the path to the product
 *  specified in the input argument
 */

{
  FILE *fp;
  char line[1026];
  char *prod_path = 0;
  char *lproduct;
  char error[100];

  fp = fopen( "/usr/ip32/product_data", "r");
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
  strcpy( error, "not found" );
  return( error );
}

int in_list( buffer, lprod, prodlist, logolist, maxline)
 char buffer[STRSIZE];
 char *prodlist[STRSIZE];
 char *logolist[STRSIZE];
 char lprod[STRSIZE];
 int *maxline;
{
  int i;

  for (i=0;i < *maxline;i++)
   {
    if ( ! strcmp(buffer, prodlist[i]))
     {
       return(1);
     }
   }
 
  prodlist[*maxline]=(char *)malloc(STRSIZE);
  logolist[*maxline]=(char *)malloc(STRSIZE);
  strcpy(prodlist[*maxline],buffer);
  strcpy(logolist[*maxline],lprod);
  *maxline=*maxline+1;
  return(0);
}

int get_runname( buffer, runname, prodlist, logolist, maxline)
 char buffer[STRSIZE];
 char *prodlist[STRSIZE];
 char *logolist[STRSIZE];
 char runname[STRSIZE];
 int *maxline;
{
  int i;

  for (i=0;i < *maxline;i++)
   {
    if ( ! strcmp(buffer, logolist[i]))
     {
       strcpy(runname, prodlist[i]);
       return(0);
     }
   }
  return(1);
}

void prod_list()
{
  FILE    *list;
  char    command[STRSIZE];
  char    tmp[STRSIZE];
  char    lprod[STRSIZE];
  char    buffer[STRSIZE];
  char    tmpfile[STRSIZE];
  char    *stindex, *stindex1;
  int     row;

  if ( SHOW_DEM )
    FIfld_set_list_num_rows( my_form, PRODUCTS, 0, 0 );

  strcpy( tmpfile, tmpnam(0));

  sprintf( command, "\\cat /usr/ip32/product_data | \\awk '{ if ($2 !~ /IGR/) print $1, $2}' > %s", tmpfile );
  system( command );

  row = 0;
  list = fopen( tmpfile, "r" );
  while ( fgets( buffer, 255, list ) )
  {
    buffer[strlen(buffer) - 1] = 0;
    stindex = (char *)strtok( buffer, " " );
    strcpy ( tmp, NULL );
    strcpy ( lprod, NULL );
    if(stindex) {
      strcpy (tmp, stindex );
      stindex = (char *)strtok( NULL, " " );
      if(stindex) {
        strcpy( lprod, stindex );
      }
    }
    stindex = tmp;
    stindex1 = buffer;
    while ( stindex[0] != '\0' )  { /* eliminate " */
      if( stindex[0] != '\"' ) {
        stindex1[0] = stindex[0];
        stindex1 = stindex1 + 1;
      }
      stindex = stindex + 1;
    }
    stindex1[0] = '\0';
    strcpy( tmp, buffer );
    if ( depends_on_grnuc( tmp ) )
    {
      if (strcmp(buffer,MODEL))
       {
          if (! in_list(buffer,lprod,prodlist,logolist,&maxline))
           {
            if ( SHOW_DEM )
              FIfld_set_list_text( my_form, PRODUCTS, row, 0, lprod, FALSE );
            if ( strlen(lprod) != 0 )
             row = row + 1;
           }
       }
    }
  }
  fclose( list );

}

#define get_arg( buffer, arg, ch ) strcpy( arg, buffer ); \
                                   stindex = (char *)strchr( arg , ch ); \
                                   if ( stindex ) \
                                     { \
                                     strcpy( arg, &stindex[1] ); \
                                     stindex = (char *)strchr( arg, ch ); \
                                     if ( stindex )  \
                                       { \
                                       stindex[0] = 0; \
                                       } \
                                     } 

void get_last_time()
/* 
 *  update form by reading preference file in $HOME/lg
 */
{
  int   i;
  FILE *fp;
  char  buffer[1000];
  char  file[1000];
  char  tmp[1000];
  char *stindex;


  strcpy ( tmp, CURRENT_PROD );
  for ( i = 0; i < strlen(tmp); i ++ )
    tmp[i] = tolower( tmp[i] );
  sprintf( file, "%s/%s/%s_pref", getenv("HOME"), LG, tmp );
  fp = fopen ( file , "r" );
  if ( fp == NULL )
    return;

  for ( i = 0 ; i < MAXCHECK ; i ++ )
    {
    FIg_set_text( my_form, 200+i, "" );
    FIg_erase( my_form, 200+i );
    if ( check_list[i].add )
      FIg_set_state_off( my_form, BASE+i );
    else
      FIg_set_state_on( my_form, BASE+i );
    }
  i = 0;

  fgets ( buffer, sizeof(buffer), fp );
  buffer[strlen(buffer)-1] = '\0';
  fclose( fp );

  while ( (stindex = (char *)strchr( buffer, ' ' )) != NULL )
    {
    strcpy( buffer, &stindex[1] );
    if ( buffer[0] == '-' )
      {
      for ( i = 0 ; i < MAXCHECK ; i ++ )
        {
        if ( check_list[i].option[1] != '\0' )
          {
          if ( buffer[1] == check_list[i].option[1] )
            {
            if ( ! check_list[i].add )
              FIg_set_state_off( my_form, 100+i );
            else
              FIg_set_state_on( my_form, 100+i );

            if ( check_list[i].field )
              {
         /*
          * Note that value fields associated with an option
          * must be enveloped by single tics to protect them from
          * the shell. We use this fact to extract the quoted string
          * associated with the option.
          */
              tmp[0] = '\0';
              get_arg( buffer, tmp, '\'' );
              stindex = stindex + strlen( tmp ) + 2;  /* bump ptr past value */
              FIg_set_text( my_form, 200+i, tmp );
              FIg_call_notification_routine( my_form, 100+i );
              }
            }
          }
        }
      }
    }
}

void display_error( string )
char *string;
{
  FIg_display( my_form, ERROR );
  FIg_set_text( my_form, ERROR, string );
}

void get_check_list()
{
  FILE *fp;
  int i=0;
  int state;
  char line[STRSIZE];
  char lgformfile[STRSIZE];
  char tmp[STRSIZE];
  char *stindex, *ptr1;


  for ( i = 0 ; i < MAXCHECK ; i ++ ) {
    check_list[i].option[0] = '\0';
    FIg_set_text( my_form, 200+i, "" );
    FIg_set_state_off( my_form, BASE+i );
    FIg_erase( my_form, BASE+i );
    FIg_erase( my_form, 200+i );
  }
  i = 0;

  strcpy ( tmp, CURRENT_PROD );
  stindex = (char *)strchr( tmp , '/' );
  if ( stindex ) strcpy( tmp, &stindex[1] );
  for ( i = 1 ; i < strlen(tmp) ; i ++ )
    tmp[i] = tolower(tmp[i]);

  strcpy( lgformfile, find_file( tmp, LGCONFIG) );
  if ( ! strcmp( lgformfile, "not found" )) return;

  i = 0;
  fp = fopen( lgformfile, "r");
  if ( fp ) {
    while ((( fgets( line, sizeof(line), fp ) ) != NULL ) & ( i < MAXCHECK )) {
      if ( line[0] != '#' ) {
        line[strlen(line)-1] = '\0';

        stindex = (char *)line; 
      /*
       * get string to display
       */
        while ( stindex[0] != '\0' )  {   /* replace tabs with blanks */
          if( stindex[0] == '\t' ) {
            stindex[0] = ' '; 
          }
        stindex = stindex + 1;
        }
        stindex = (char *)strtok( line, "\"" );
        if( stindex ) {
          FIg_set_text( my_form, BASE+i, stindex );
          FIg_display( my_form, BASE+i, stindex );
      /*
       * get yes or no whether to default
       * to checked
       */
          stindex = (char *)strtok( NULL, " " );
          if ( stindex ) {
            if( !strcmp( stindex, "yes" )) 
              FIg_set_state_on( my_form, BASE+i );
       /*
        * get option in form -?
        */
            stindex = (char *)strtok( NULL, " " ); 
            if( stindex ) {
              strcpy( check_list[i].option, stindex );
       /*
        * get yes or no - whether or not to add option if 
        * selected reverse logic if no
        */
              stindex = (char *)strtok( NULL, " " ); 
              if( stindex ) {
                if ( !strcmp( stindex, "yes" ))
                  check_list[i].add = 1;
                else
                  check_list[i].add = 0;
       /*
        * get field default 
        * - no string means no field
        * - "" means empty field
        * - "xxxx" gives default string
        */
                check_list[i].field = 0; 
                stindex = (char *)strtok( NULL, "\"" );
                if ( stindex ) {
                  check_list[i].field = 1;
       /*
        *  add back "" around string
        */
                  ptr1 = stindex + strlen( stindex );
                  *ptr1 = '"';
                  ptr1[1] = '\0';
                  stindex = stindex - 1;
                  *stindex = '"';
                  FIg_set_text( my_form, 200+i, stindex);
                  FIg_get_state( my_form, BASE+i, &state);
                  if ( state ) FIg_display( my_form, 200+i );
                }
              }
            }
          }
        }
        i = i + 1 ;
      }
    }
  fclose( fp );
  }
}

char * find_file( product, file )
char *product;
char *file;
{
  FILE *fp;
  char *stindex;
  char save[1026];
  char line[1026];
  char tmp[35];
  char lproduct[37];
  char filename[300];
  char tmpfile[300];
  char tmpdir[300];

    fp = fopen( "/usr/ip32/product_data", "r");
    if ( !fp )
      {
      printf("Could not open product_data file\n");
      exit(0);
      }

    sprintf( tmpdir, product_path( product ));
    sprintf( tmpfile,"%s/%s", tmpdir, file);
    if ( ( access( tmpfile, 0 )) != -1 )
      {
      fclose( fp );
      return( tmpfile );
      }
    sprintf( lproduct, "\"%s\"", product );
    
    while ( fgets( line, 1025, fp ) )
      {
      line[strlen(line) - 1] = 0;
      if ( !strncmp(line, lproduct, strlen (lproduct) ) )
        {
        strcpy( save, line );
        while( (stindex = (char *)strchr( line, ':' )) != NULL )
          {
          strcpy( line, &stindex[1] );
          strcpy( tmp, line );
          stindex = (char *)strchr( tmp, ':' );
          if ( stindex ) 
            stindex[0] = '\0';
          else
            {
            stindex = (char *)strchr( tmp, ' ' );
            if ( stindex ) stindex[0] = '\0';
            }
          sprintf( tmpdir, product_path( tmp ));
          sprintf( tmpfile,"%s/%s", tmpdir, file );
          if ( ( access( tmpfile, 0 )) != -1 )
            {
            fclose( fp );
            return( tmpfile );
            }
          }
        strcpy( line, save );
        while( (stindex = (char *)strchr( line, ':' )) != NULL )
          {
          strcpy( line, &stindex[1] );
          strcpy( tmp, line );
          stindex = (char *)strchr( tmp, ':' );
          if ( stindex ) 
            stindex[0] = '\0';
          else
            {
            stindex = (char *)strchr( tmp, ' ' );
            if ( stindex ) stindex[0] = '\0';
            }
          strcpy( filename, find_file( tmp, file ));
          if ( strcmp( filename, "not found" ))
            {
            fclose( fp );
            return( filename );
            }
          }
        break;
        }
      }
    strcpy( tmp, "not found" );
    fclose( fp );
    return ( tmp );
}

int depends_on_grnuc( product )
char *product;
{
  FILE *fp;
  char *stindex;
  char line[1026];
  char tmp[35];
  char lproduct[37];

  

    sprintf( lproduct, "\"%s\"", product );
    
    fp = fopen( "/usr/ip32/product_data", "r");
    if ( !fp )
      {
      printf("Could not open product_data file\n");
      exit(0);
      }

    while ( fgets( line, 1025, fp ) )
      {
      line[strlen(line) - 1] = 0;
      if ( !strncmp(line, lproduct, strlen (lproduct) ) )
        {
        while( (stindex = (char *)strchr( line, ':' )) != NULL )
          {
          strcpy( line, &stindex[1] );
          strcpy( tmp, line );
          stindex = (char *)strchr( tmp, ':' );
          if ( stindex ) 
            stindex[0] = '\0';
          else
            {
            stindex = (char *)strchr( tmp, ' ' );
            if ( stindex ) stindex[0] = '\0';
            }
          if ( ! strcmp( tmp, "Grnuc" ))
            {
            fclose( fp );
            return( 1 );
            }
          if ( depends_on_grnuc( tmp ))
            {
            fclose( fp );
            return( 1 );
            }
          }
        break;
        }
      }

    fclose( fp );
    return ( 0 );
}
