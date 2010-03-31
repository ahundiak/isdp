#include <stdio.h>
#include "wl.h"
#include "preview.h"
#include "options.h"

/*---GetOptions------------------------------------------------*/

char	GetOptions( int argc, char **argv, struct option_node **option )
   {
   extern char		*optarg;
   extern int		optind, opterr;
   char			ch;
   struct option_node	*op;

   *option = NULL;

   while( (ch=getopt( argc, argv, "?b:f:" )) != EOF )
      {
      switch( ch )
         {
         case 'f':
            op = (struct option_node *)malloc( sizeof( struct option_node ) );
            op->next = *option;
            op->type = OPTION_DISP_IMAGE;
            op->filename = (char *)malloc( strlen( optarg ) + 1 );
            strcpy( op->filename, optarg );

            *option = op;
            break;

         case 'b':
            op = (struct option_node *)malloc( sizeof( struct option_node ) );
            op->next = *option;
            op->type = OPTION_CONV_BMP;
            op->filename = (char *)malloc( strlen( optarg ) + 1 );
            strcpy( op->filename, optarg );

            *option = op;
            break;

         case '?':
            printf( "preview <filename>\n" );
            break;
         }
      }
  
   if( optind < argc )
      {
      op = (struct option_node *)malloc( sizeof( struct option_node ) );
      op->next = *option;
      op->type = OPTION_DISP_IMAGE;
      op->filename = (char *)malloc( strlen( argv[argc-1] ) + 1 );
      strcpy( op->filename, argv[argc-1] );

      *option = op;

      return 1;
      }
   else
      return 0;
   }
