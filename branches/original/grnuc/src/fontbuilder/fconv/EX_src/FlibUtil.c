/*
$Log: FlibUtil.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:02  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:13  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:17  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:50:05  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.1  1992/11/04  20:26:22  grnuc20
 * COMMENT : fixes for single source platform implementation
 *
 * Revision 220.0  1992/08/29  06:28:35  root
 * COMMENT : Corresponds to Rel201.10 in 2.0.1 RCS
 *
 * Revision 201.10  1992/07/13  20:41:48  tim
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

/* TGM 2/19/92 Removed Set_message_mode which caused a lock up in CSS 6.0 */

main(argc, argv)

	int   argc;
	char *argv[];
{
        int         sts, status, count, count1, len,
                    pub_convert;
        int         ctype;
 static int         fill_type = 1;
        int         ll = 0;
        int         oo = 0;
        int         nn = 0;
        short      *flib_font_nums, *font_ptr;
        short       num_fonts = 1;
        short      *s_ptr, *CX8to16();
        char       *cptr, *char_ptr, font_num[5], test[256],
                    sval[256], typeface_descr[256], *CX16to8();
 static char       *fontutil = {"FONTUTIL\0"};

        uInt32      font_flags;
        Typepath    mod_type_path, vax_flib_file, flib_path;
        GGlist     *flib_ptr;
        Conv_table *char_index;

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

   status = Flib_open_lib( Flib_file );
   if ( (status != FF_S_SUCCESS) || (Num_flib_fonts == 0) ) {
      printf("main(): Flib_open_lib()\n");
      printf("No Vax Library typefaces found.\n");
      goto end_main;
      }

/*   FF_MESSAGE( "Vax Font Lib conversion:" ); JWW */
/*   sprintf(sval,"%s%3hd%c", "Converting VAX font number ",
*flib_font_nums, '\0'); JWW */
/*   FF_STATUS( sval ); JWW */
   status = Flib_load_font( Flib_file, *flib_font_nums );
   if ( status == FF_CHAR_INVALID_TYPE + ERRO ) {
      printf( "\n*** ERROR ***\n");
      sprintf( sval, "%s%3hd%s",
               "main(): Flib_load_font( ", *font_ptr, ")\n");
      printf(sval);
      sprintf(sval,"%s%3hd%s", "Failure to load font number",
                               *font_ptr, "\n\0");
      printf(sval);
      printf("Invalid character element type found.");
      }

   /*******************************************************************/
   /*  sts = 0  Failure to retrieve a new typeface name. A duplicate  */
   /*           font file and number was found.                       */
   /*  sts = 1  Successful completion. No previous font file and      */
   /*           number was converted.                                 */
   /*******************************************************************/
   sprintf( typeface_descr, "%s%s%s%3hd%s%s", CX16to8(Flib_name), ": ",
            "font ", *flib_font_nums, "  -  ", "IGDS font" );

   status = Flib_convert_font(New_typeface, typeface_descr, 0, fill_type );
   if (status != FF_S_SUCCESS) {
       sprintf(sval,"%s%3hd%s", "Failure to convert font number",
               *font_ptr, "\n\0");
/*       FF_STATUS ( sval ); JWW * dmb:2/22/90 */
       }
     else if (sts == FF_S_SUCCESS) {
       sprintf(sval,"%s%3hd%s", "Font number ",
                            *flib_font_nums, " converted.\n\0");
/*                                *font_ptr, " converted.\n\0"); */
/*       FF_STATUS ( sval ); JWW * dmb: 2/22/90 */
       if (Flib_chars != NULL) {
           for (count1 = 0, char_index = Flib_chars;
                count1 < Flib_fontheader.end_char + 32;
                count1++, char_index++ ) {
              if (char_index->vect_elements != NULL)
                 free((unsigned char *)char_index->vect_elements);
              }
           free( (unsigned char *)Flib_chars );
           Flib_chars = NULL;
           }
       }

/*   FF_STATUS( "Font conversion complete" ); dmb:2/22/90 */
   if (Flib_fonts != NULL) free( (unsigned char *)Flib_fonts );
/*   FF_MESSAGE( " " ); JWW */

end_main:
  
   if (flib_font_nums != NULL) free( (unsigned char *)flib_font_nums ); 

/*   Exit_tools(); JWW */

   exit( 0 );
}
