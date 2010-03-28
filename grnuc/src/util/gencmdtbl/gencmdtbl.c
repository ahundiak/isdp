#include	"stdio.h"
#include	"ctype.h"
#include	"tools.h"
#include	"sys/types.h"
#include	"dirent.h"
#include	"stdlib.h"

main ( argc, argv)
int	argc;
char	**argv;

{
  FILE		* fp_in, * fp_out, * fp_err ,* fp_cmdsrc;
  char          * suffix_ptr;
  char          dir_path[80],file_path[80];

/* Used to select files from specified directory */
  DIR		*dp;
  struct	dirent	*dp_ptr;
  int		dir_cnt;

/* Number of ptrs to modules entered on command line */
  char		* mod_ptr[10];
  int		mod_cnt;

/* Array of structures used to hold command table source data. */
  struct  xref_tbl
  {
          char    buffer[101];
          char    cmd_key[11];
          char    msg_key[51];
          char    cmd_strg[51];
  } cmd_key[2000];

  int		key_max; /* Total of keys from all .cmd files */
  int		key_cnt; /* Pointer to key in cmd_key[] */
  int		key_tot; /* Number of key occurances found */

/* Other Stuff */
  char		test_key[11];
  int		test_cnt;
  char		test_buffer[101];
  char		def_htr[100];
 

  if ( argc > 3 && argc < 11 )
  {  
    fp_err = 0;

    /* Decode environment variables from command line. Abort if all */
    /* not valid. */
    for ( mod_cnt = 0; mod_cnt <= argc - 4; ++mod_cnt )
    {
      mod_ptr[ mod_cnt ] = getenv( argv[ mod_cnt + 3] );
      if ( !mod_ptr[ mod_cnt ] )
      {
        printf( "Bad Env Variable:%d %s\n\n",mod_cnt,argv[mod_cnt + 3] );
        cleanup();
      }
    } 

    /* Open file for "xxx.cmd" file creation */
    if ( !( fp_out = ( FILE * )fopen( argv[2], "w" ) ) )
    {
       printf( "Could Not Open File:%s\n",argv[1] );
       cleanup();
    }

    /* Open .cmd definition file for reading */
    if ( !( fp_in = ( FILE * )fopen( argv[1], "r" ) ) )
    {
       printf( "Could Not Open File:%s\n",argv[2] );
       cleanup();
    }
 

  /******************************************************************/
  /* This loop processes the .cmd files                             */
  /******************************************************************/

    key_max = 0;
    for( dir_cnt = 0; dir_cnt < mod_cnt; ++dir_cnt ) 
    {
      strcpy( dir_path, mod_ptr[ dir_cnt ] );
      strcat( dir_path, "/config" );

      /* Open directory containing cmd_tbl source files */
      if ( dp = (DIR *)opendir( dir_path ) )
      {
        printf( "\n\nReading Cmds For:%s", dir_path );
        if ( dp_ptr = (struct dirent * ) readdir( dp ) )
        {
          while( dp_ptr )
          {
            strcpy( file_path, dir_path );
            strcat( file_path, "/" );
            strcat( file_path, dp_ptr->d_name );

            suffix_ptr = dp_ptr->d_name;
            while ( *suffix_ptr != '.'  && *suffix_ptr != '\0' )
               ++suffix_ptr;

            if (dp_ptr->d_name[0] != '.' && strcmp( suffix_ptr, ".cmd" ) == 0)
            {
              key_cnt = 0;
              printf( "\n\tProcessing:%s",dp_ptr->d_name );
              if ( fp_cmdsrc = ( FILE * )fopen( file_path, "r" ))
              {
                while (fgets( cmd_key[key_max].buffer, 100, fp_cmdsrc ) != NULL)
                { 
                  if ( cmd_key[key_max].buffer[0] != '#' && 
                       cmd_key[key_max].buffer[0] != ' ' &&
                       cmd_key[key_max].buffer[0] != '/' &&
                       cmd_key[key_max].buffer[0] != '*' )
                  {

                  /* Some people do not yet use UMS and put string in */
                  /* .cmd table. We check for these wise guys using a leading */
                  /* quote test. */
                    if ( cmd_key[key_max].buffer[0] == '"' )
                    {
                      sscanf(cmd_key[key_max].buffer, "%[^,]%*c%[^,]", 
                             cmd_key[key_max].cmd_strg,
                             cmd_key[key_max].cmd_key );
                      key_cnt++;
                      key_max++;

                    }  
                    else
                    {
                      sscanf(cmd_key[key_max].buffer, "%[^,]%*c%[^,]",
                             cmd_key[key_max].msg_key,
                             cmd_key[key_max].cmd_key );
                      key_cnt++;
                      key_max++;
                    }
                  }
                }
                fclose( fp_cmdsrc );
              }
              printf("  %d Entries Found   %d Total ",key_cnt,key_max ); 
            }
            dp_ptr = readdir( dp );
          }  
          closedir( dp );
        } 
      }
    }
    key_max--;


    /******************************************************************/
    /* This loop processes the .h files and writes then to .cmd file  */
    /******************************************************************/

    for( dir_cnt = 0; dir_cnt < mod_cnt; ++dir_cnt ) 
    {
      strcpy( dir_path, mod_ptr[ dir_cnt ] );
      strcat( dir_path, "/include" );

      /* Open directory containing command include files */
      if ( dp = (DIR *)opendir( dir_path ) )
      {
        printf( "\n\nReading Include Files For:%s", dir_path);
        if ( dp_ptr = (struct dirent * ) readdir( dp ) )
        {
          while( dp_ptr )
          {
            strcpy( file_path, dir_path );
            strcat( file_path, "/" );
            strcat( file_path, dp_ptr->d_name );

            suffix_ptr = dp_ptr->d_name;
            while ( *suffix_ptr != '.'  && *suffix_ptr != '\0' )
               ++suffix_ptr;

            /* Lets back up to cmd.h */
            --suffix_ptr;
            --suffix_ptr;
            --suffix_ptr;

            /* Lets test for good ones and process them */
            if (dp_ptr->d_name[0] != '.' && !strcmp( suffix_ptr,"cmd.h") )
            {
               printf( "\n\tOutputting:%s",dp_ptr->d_name );
               fprintf( fp_out, "#include \"%s\"\n", dp_ptr->d_name );
            }

            dp_ptr = readdir( dp );
          }  
          closedir( dp );
        } 
      }
    }





    /******************************************************************
      Loop to write out command table for product                    
     ******************************************************************/
    fgets( def_htr, 100, fp_in ); 
    printf( "\n\nProcessing Definition File:%s\n",def_htr );
    
    test_cnt = 1;
    while (fgets( test_buffer, 100, fp_in ) != NULL)
    {
      key_cnt = 0;
      key_tot = 0;
      sscanf(test_buffer, "%s",test_key );
      while (key_cnt <= key_max )
      {
        if ( strcmp( test_key, cmd_key[key_cnt].cmd_key ) == 0 ) 
        {
          fprintf( fp_out, "%s",cmd_key[key_cnt].buffer );
          key_cnt++;
          key_tot++;
        }
        else
          key_cnt++;
      }

      if ( key_tot == 0 )
      {
        printf( "\nKey Not Found:%s  Line#:%d", test_key, test_cnt );

        /* Open file gencmdtbl.err  */
        if ( !fp_err )
          if ( !( fp_err = ( FILE * )fopen("gencmdtbl.err", "w" ) ) )
          {
             printf( "Could Not Open File:%s\n",argv[1] );
             cleanup();
          }
        
        fprintf( fp_err,"\nKey Not Found:%s  Line#:%d", test_key, test_cnt );
      
      }
      test_cnt++;
    }
    /* End Loop */


  }  
  else
  {
    printf( "\n Wrong Number of Arguments:%d",argc );
    printf( "\n Command Line: " );
    printf( "< Input Definition File> " ); 
    printf( "< Output Cmd Table File> " ); 
    printf( "<Env Var,...> \n " );
  }
  cleanup();
}

cleanup()
{
  exit(0);
}
