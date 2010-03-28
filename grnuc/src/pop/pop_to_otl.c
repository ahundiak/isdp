#include	"stdio.h"
#include	"ctype.h"
/*
Removed this include files as them seem not be necessary and
are causing compiler problems on the Sun.

Richard Watson 02/25/92

#include	"tools.h"
#include	"sys/dir.h"
*/
#include	"sys/types.h"
#include	"dirent.h"
#include	"stdlib.h"

struct	xref_tbl
{
	char	cmd_key[11];
        char	msg_key[51];
        char    cmd_strg[51];
}; 

main ( argc, argv)
int	argc;
char	**argv;

{
  FILE		* fp_in, * fp_out;
  char		pal_path[80];
  char		config_path[80];

/* Used to select files from specified directory */
  DIR		*dp;
  struct	dirent	*dp_ptr;
  int		dir_cnt;

/* Number of ptrs to modules entered on command line */
  char		* mod_ptr[10];
  int		mod_cnt;

/* Palette Header Data */
  char		version[20];
  int		cmd_cnt;
  int		properties, rows, cols, color, xpos, ypos, xsize, ysize;
  int		btn_x, btn_y;
  int		btn_on_color, btn_off_color;
  int   	row, col, command_type, symbol;
  char  	command[11], symbol_file[15];

/* Array of Structures to store .cmd - .mb xref data for command strings */
  struct	xref_tbl	cmd_x_key_x_strg[1500]; 
  int		max_strgs;
  int		cmd_strg_idx;


  if ( argc > 2 )
  {  
    /* Decode environment variables from command line. Abort if all */
    /* not valid. */
    for ( mod_cnt = 0; mod_cnt <= argc - 3; ++mod_cnt )
    {
      mod_ptr[ mod_cnt ] = getenv( argv[ mod_cnt + 2] );
      if ( !mod_ptr[ mod_cnt ] )
      {
        printf( "Bad Env Variable:%s\n\n",argv[mod_cnt + 2] );
        cleanup();
      }
    } 

    /* Create .cmd <-> .mb xref */
    init_xref( cmd_x_key_x_strg, 
               mod_ptr,
               &mod_cnt,
               &max_strgs);     

    /* Open file for outline file creation & write header*/
    if ( !( fp_out = ( FILE * )fopen( argv[1], "w" ) ) )
    {
       printf( "Could Not Open Outline File:%s\n",argv[1] );
       cleanup();
    }
 
    /* Write outline file header data */
    fprintf( fp_out, "PANEL,2.0,HT=50,WD=80," );
    fprintf( fp_out, "ON=white,ON2=white,OFF2=black\n" );


    /* Process palettes for each module entered on command line */
    for ( dir_cnt = 0; dir_cnt < mod_cnt; ++dir_cnt )
    {
      strcpy( config_path, mod_ptr[ dir_cnt ] );
      strcat( config_path, "/config/english/palettes" );

      /* Continue on if palette directory is not found for module*/
      if ( !(dp = (DIR *)opendir( config_path )) ) 
      {
        printf("Cannot Open Palettes Dir:%s\n",config_path );
        continue;
      }

      /* Read Palette Files and Output to otlfile */
      if (dp_ptr = ( struct dirent * )readdir( dp ))
      {
        while (dp_ptr)
        { 
          if ( dp_ptr->d_name[0] != '.' )
          {
            strcpy( pal_path, config_path );
            strcat( pal_path, "/" );
            strcat( pal_path, dp_ptr->d_name );

            if ( fp_in = ( FILE * )fopen( pal_path, "r" ))
            {
              printf( "Processing File:%s\n", pal_path );

              /* Read Outline Header data for a new palette */
              fscanf( fp_in, "%[^,],%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                      version, &properties, &rows, &cols, &color, &xpos,
                      &ypos, &xsize, &ysize, &btn_x, &btn_y, &btn_on_color,
                      &btn_off_color );

              cmd_strg_idx = get_cmd_strg ( cmd_x_key_x_strg, 
                                            max_strgs, 
                                            dp_ptr->d_name );

              /* Write Outline Header data for a new palette */
              fprintf( fp_out, "\tp_%s,\"%s\",text,%d NUM=2 #%s\n", 
                       dp_ptr->d_name, 
                       dp_ptr->d_name, 
                       strlen( dp_ptr->d_name ),
                       cmd_x_key_x_strg[ cmd_strg_idx].cmd_strg );

              /* Print entry for each row found in palette file */
              for ( cmd_cnt = 0; cmd_cnt < rows*cols; cmd_cnt++ )
              {
                fscanf( fp_in, "%d,%d,%[^,],%d,%[^,],%d\n",
                        &row, 
                        &col, 
                        command, 
                        &command_type, 
                        symbol_file,
                        &symbol );
  
                cmd_strg_idx = get_cmd_strg( cmd_x_key_x_strg, 
                                             max_strgs, 
                                             command );

                if ( symbol <= 0 )
                  fprintf( fp_out, "\t\t%s,\"%s\",text,%d #%s\n", 
                           command, 
                           command, 
                           strlen( command ),
                           cmd_x_key_x_strg[ cmd_strg_idx].cmd_strg );
                else
                  /* Write entry to otl file if popup command not the same*/ 
                  /* as invoking command. */
                  if ( strcmp( command,dp_ptr->d_name ) )
                    fprintf( fp_out, "\t\t%s,%s,%d,-1 #%s\n", 
                             command, 
                             symbol_file, 
                             symbol,
                             cmd_x_key_x_strg[ cmd_strg_idx].cmd_strg );
              }
            }
          }
          dp_ptr = readdir( dp );
        }
      }
      closedir( dp ); 
    }   
  }
  else
  {
    printf( "\n Wrong Number of Arguments:%d",argc );
    printf( "\n Command Line: " );
    printf( "<Output File> " ); 
    printf( "<Env Var,...> \n " );
  }
}

cleanup()
{
  exit(0);
}


/* This function returns the index into the xref_tbl array for a */
/* specified cmd_key. max_cmd_strgs returned of cmd_key not found. */

int get_cmd_strg ( cmd_x_key_x_strg, max_cmd_strgs, cmd_key )

struct	xref_tbl	*cmd_x_key_x_strg;
char	cmd_key[];
int	max_cmd_strgs;

{
  int		cmd_key_cnt;

  for ( cmd_key_cnt = 0; cmd_key_cnt < max_cmd_strgs; ++cmd_key_cnt )
    if ( strcmp( cmd_x_key_x_strg[ cmd_key_cnt].cmd_key, cmd_key ) == 0 )
      break;  
  return( cmd_key_cnt );
}

/* Builds the xref between cmd_key, msg_key, and cmd_strg bu decomposition */
/* of .mb and .cmd files. */
init_xref( cmd_x_key_x_strg, mod_ptr,mod_max,msg_cnt )

struct	xref_tbl	*cmd_x_key_x_strg;
char		* mod_ptr[];
int 		* mod_max;
int		* msg_cnt;		
{
  DIR           * dp;
  struct        dirent  * dp_ptr;
  char		* suffix_ptr;
  char		msg_path[80];
  FILE		* fp_read;
  int		dir_cnt;
  int		junk_cnt;
  char		buffer[100];
  char   	file_path[80];
  char		msg_key[51];
  char		cmd_strg[51];


/* This for loop processes the .cmd files building a xref of cmd_key */
/* and msg_key. */
  *msg_cnt = 0;

  for( dir_cnt = 0; dir_cnt < *mod_max; ++dir_cnt ) 
  {
    strcpy( msg_path, mod_ptr[ dir_cnt ] );
    strcat( msg_path, "/config" );

/* Open directory containing cmd_tbl source files */
    if ( dp = (DIR *)opendir( msg_path ) )
    {
      printf( "\nReadind Cmds For:%s\n",mod_ptr[ dir_cnt ] );
      if ( dp_ptr = (struct dirent * ) readdir( dp ) )
      {

        while( dp_ptr )
        {
          strcpy( file_path, msg_path );
          strcat( file_path, "/" );
          strcat( file_path, dp_ptr->d_name );

          suffix_ptr = dp_ptr->d_name;
          while ( *suffix_ptr != '.'  && *suffix_ptr != '\0' )
             ++suffix_ptr;

          if ( dp_ptr->d_name[0] != '.'  &&  strcmp( suffix_ptr, ".cmd" ) == 0 )
          {
            printf( "\tProcessing:%s\n",dp_ptr->d_name );
            if ( fp_read = ( FILE * )fopen( file_path, "r" ))
            {
              while ( fgets( buffer, 100, fp_read ) != NULL )
              { 
                if ( buffer[0] != '#' && buffer[0] != ' ' )
                {

/* Some people do not yet use UMS and put string in .cmd table.  We check */
/* for these wise guys using a leading quote test. */
                  if ( buffer[0] == '"' )
                  {
                    sscanf(buffer, "%[^,]%*c%[^,]", 
                           cmd_x_key_x_strg[*msg_cnt].cmd_strg,
                           cmd_x_key_x_strg[*msg_cnt].cmd_key );
                    (*msg_cnt)++;

                  }  
                  else
                  {
                    sscanf(buffer, "%[^,]%*c%[^,]",
                           cmd_x_key_x_strg[*msg_cnt].msg_key,
                           cmd_x_key_x_strg[*msg_cnt].cmd_key );
                    (*msg_cnt)++;
                  }
                }
              }
              fclose( fp_read );
            }
          }
          dp_ptr = readdir( dp );
        }  
        closedir( dp );
      } 
    }
  }


/* This for loop processes the .mb files building a xref of cmd_key */
/* and cmd_strg based upon a common msg_key. */

  for( dir_cnt = 0; dir_cnt < *mod_max; ++dir_cnt ) 
  {
    strcpy( msg_path, mod_ptr[ dir_cnt ] );
    strcat( msg_path, "/config/english/messages/src" );

/* Open directory containing message source files */
    if ( dp = (DIR *)opendir( msg_path ) )
    {
      printf( "\nReading Messages For:%s\n",mod_ptr[ dir_cnt ] );
      if ( dp_ptr = (struct dirent * ) readdir( dp ) )
      {

        while( dp_ptr )
        {
          strcpy( file_path, msg_path );
          strcat( file_path, "/" );
          strcat( file_path, dp_ptr->d_name );

          suffix_ptr = dp_ptr->d_name;
          while ( *suffix_ptr != '.'  && *suffix_ptr != '\0' )
            ++suffix_ptr;

          if ( dp_ptr->d_name[0] != '.'  &&  
               strcmp( suffix_ptr - 3, "cmd.mb" ) == 0 )
          {
            printf( "\tProcessing:%s\n",dp_ptr->d_name );
            if ( fp_read = ( FILE * )fopen( file_path, "r" ))
            {
              fgets( buffer, 100, fp_read );
              fgets( buffer, 100, fp_read );

              while ( fgets( buffer, 100, fp_read ) != NULL )
              { 
                sscanf(buffer, "%[^,]%*s%*[^0-z]%[ -z]", msg_key, cmd_strg ); 

                for ( junk_cnt = 0; junk_cnt < *msg_cnt; ++junk_cnt )
                {
                  if (strcmp(cmd_x_key_x_strg[junk_cnt].msg_key,msg_key) == 0 )
                  {
                    strcpy( cmd_x_key_x_strg[junk_cnt].cmd_strg, cmd_strg );
                    break;
                  }
                }
              }

              fclose( fp_read );
            }
          }
          dp_ptr = readdir( dp );
        }  
        closedir( dp );
      }
    } 
  }
}
