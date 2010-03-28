/*
$Log: FlibChFn.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:14:58  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:09  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:13  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:46  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.1  1992/11/13  19:33:57  grnuc20
 * COMMENT : removed commented out include reference so makemake will work correctly
 *
 * Revision 220.0  1992/08/29  06:31:05  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:44  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <string.h>
#include <tools.h>
#include <itools.h>
#include "FSBmap.h"
#include "FFdef.h"
#include "FFmacros.h"
#include "FFstructs.h"
#include "FFerrdef.h"
#include "flibstruct.h"


   char CS_path_name[256];

        int               Num_typefaces,
                          Num_flibs,
                          Num_flib_files;
        short             Flib_font_num;
        GGitem_list      *Typefaces,
                         *Typeface_names;
        GGlist           *Flib_files;
        Typepath          Typeface_file,
                          Typeface_name,
                          Cur_typeface,
                          New_typeface,
                          Flib_font,
                          Flib_file,
                          Flib_name;
 struct font_offset_table Flib_font_node;

main(argc, argv)

	int   argc;
	char *argv[];
{
        int         status, len;
        int         ctype;
 static int         fill_type = 1;
        int         ll = 0;
        int         oo = 0;
        int         nn = 0;
        short      *flib_font_nums;
        short      *s_ptr, *CX8to16();
        char        *CX16to8();
        uInt32      font_flags;
        Typepath    vax_flib_file, flib_path;
        extern        char        *optarg;
        extern        short        Num_flib_fonts;
        extern        Typepath     New_typeface;
        extern        GGitem_list *Flib_fonts;
        extern        Conv_table  *Flib_chars;
        extern struct font_header  Flib_fontheader;                
        extern        int          optind, opterr;

   if (argc < 2) {
      printf( "\n*** Invalid argument list ***\n");
      printf( "\n" );
      goto end_main;
      }

   font_flags = 0;
   FSEnter(font_flags);

   Flib_name[0]     = 0;
   flib_path[0]     = 0;
   Flib_file[0]     = 0;
   vax_flib_file[0] = 0;
   Flib_chars       = NULL;
   flib_font_nums   = (short *)malloc( 10 * sizeof(short) );
   if (flib_font_nums == NULL) {
       status = FF_MALLOC_ERROR + ERRO;
       printf("main(): malloc(flib_font_nums)\n");
       FF_report_error( status );
       goto end_main;
       }

   while( (ctype = getopt( argc, argv, "l:o:n:t:" )) != EOF ) {
      /* -l = Path to a VAX IGDS font library                            */
      /* -o = Path to the new Bitstream file created from the font library */
      /* -n = Font number in the VAX IGDS font library to convert        */
      /* -t = filled or outline fonts                                    */

      switch( ctype ) {

         case 'l' :
            strcpy16(Flib_file, CX8to16(optarg) );
            if( !(UTcheck_file(Flib_file)) ) {
                printf( "\n*** USAGE: Invalid argument list ***\n");
                printf( "fontutil -l[Path to VAX font library]\n");
                printf( "         -n[Font number in VAX font library to convert]\n");
                printf( "         -o[Path to Bitstream file name - output]\n\n\n");
                goto end_main;
                }
              else {
                len = strlen( CX16to8(Flib_file) );
                s_ptr = &Flib_file[len];
                for( len--; (*s_ptr != 47) && (len > 0); len-- ) s_ptr--;
                if (len > 0) s_ptr++;
                strcpy16(Flib_name, s_ptr );
                strncpy16(flib_path, Flib_file, (len + 1));
                }
            ll++;
            break;

         case 'o' :
            strcpy16( New_typeface, CX8to16(optarg) );
            oo++;
            break;

         case 'n' :
            *flib_font_nums = (short)atoi(optarg);
            nn++;
            break;

         case 't' :
            if( (optarg[0] == 'o') || (optarg[0] == 'O') )
                fill_type = 1;
              else if( (optarg[0] == 'f') || (optarg[0] == 'F') )
                fill_type = 0;
            break;

         default :
            break;

         }      
      }

   if( !(ll && oo && nn) ) {
      printf( "\n*** USAGE: Invalid argument list ***\n");
      printf( "fontutil -l[Path to VAX font library]\n");
      printf( "         -n[Font number in VAX font library to convert]\n");
      printf( "         -o[Path to Bitstream file name - output]\n\n\n");
      goto end_main;
      }

   status = Flib_check_font_num( Flib_file, *flib_font_nums );

   if ( status != FF_S_SUCCESS) 
      goto main_error;

end_main:
  
   if (flib_font_nums != NULL) free( (unsigned char *)flib_font_nums ); 
   exit( 0 );

main_error:

   exit(-1);

}
