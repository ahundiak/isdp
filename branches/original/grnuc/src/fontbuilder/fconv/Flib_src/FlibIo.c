/******************************************************************************/
/*                                                                            */
/*				Intergraph  1985                              */
/*                                                                            */
/*	INTERGRAPH Corporation assumes  NO responsibility for the use         */
/*	or reliability of software altered by the user.                       */
/*                                                                            */
/*	The information in this document is subject to change without         */
/*	notice  and  should  not  be  construed  as  a  commitment by         */
/*	INTERGRAPH corporation.                                               */
/*                                                                            */
/*                                                                            */
/******************************************************************************/

/*
$Log: FlibIo.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:34  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:47  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.1  1995/10/26  12:18:48  skathiri
 * COMMENT : Create Font: Rectified abort, corrected Cell numbering
 *
 * Revision 320.0  1994/12/12  17:58:48  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:33  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:54  root
 * COMMENT : Corresponds to Rel201.7 in 2.0.1 RCS
 *
 * Revision 201.7  1992/07/13  20:42:13  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include "exsysdep.h"
#include <string.h>
#include <math.h>
#include <itools.h>
#include "flibstruct.h"
#include "FFdef.h"
#include "FFstructs.h"
#include "FFerrdef.h"

          GGitem_list      *Flib_fonts;
          short             Num_flib_fonts;
          int               Flib_font_offsets[256];
 unsigned short             Num_flib_chars;
          Conv_table       *Flib_chars;
 struct   library_header    Flib_header;
 struct   font_header       Flib_fontheader;

/******************************************************************************/
/*                                                                            */
/*  FACILITY:	Font Librarian I/O, version 1.0                               */
/*                                                                            */
/*  FUNCTIONAL DESCRIPTION:                                                   */
/*                                                                            */
/* 	These utility functions are used for handling i/o for the font        */
/* 	librarian.                                                            */
/*                                                                            */
/*  AUTHOR:	S. Williams		DATE:	1-Dec-1987                    */
/*                                                                            */
/*  MODIFICATIONS:                                                            */
/*                                                                            */
/******************************************************************************/




/******************************************************************************/
/*                                                                            */
/*  NAME:	Flib_read_lib_header - Reads a font library header.           */
/*	This routine reades a Vax Library Header from a Vax Font Library File */
/*      into a buffer, then converts the buffer into a library sturcture      */
/*      for use on the interpro 32C.                                          */
/*                                                                            */
/*  RETURN VALUES:                                                            */
/*                                                                            */
/*         FF_S_SUCCESS                                                       */
/*         FF_FONT_INTER_ALLOCATE + ERRO                                      */
/*         FF_FILE_READ_ERROR     + ERRO                                      */
/*         FF_FILE_SEEK_ERROR     + ERRO                                      */
/*                                                                            */
/*                                                                            */
/*  NOTES:                                                                    */
/*                                                                            */
/*  AUTHOR:	S. Williams	DATE:	28-Aug-1987                           */
/*                                                                            */
/*  SEE ALSO:                                                                 */
/*                                                                            */
/*  MODIFICATIONS:                                                            */
/*        2/22/90   dmb   Added memcpy to ui_val for flib_header->last_font   */
/*                        and flib_header->rec_len to avoid alignment traps   */
/*                        on C300s.                                           */
/*                                                                            */
/******************************************************************************/

Flib_read_lib_header( flib_header, rec_size, num_recs, f_ptr, offset )

	struct library_header *flib_header;
	       int             rec_size;
	       int             num_recs;
	       FILE           *f_ptr;
	       int             offset;

{
	         int     sts, status;
                 int     count;
                 int    *i_ptr;
                 short  *s_ptr;
                 char   *char_ptr;
	unsigned char   *char_buff, *uc_ptr;

        unsigned int    ui_val; /* dmb:2/22/90 */
	unsigned short  *us_ptr;

   status = FF_S_SUCCESS;

   char_buff = (unsigned char *)malloc( rec_size );
   if (char_buff == NULL) {
      status = FF_FONT_INTER_ALLOCATE + ERRO;
      printf("Flib_read_lib_header(): malloc(char_buff)\n");
      FF_report_error( status );
      return( status );      
      }

   uc_ptr = char_buff;
   sts = fseek( f_ptr, offset, 0 );
   if (sts < 0) {
      status = FF_FILE_SEEK_ERROR + ERRO;
      free(char_buff);
      return( status );
      }

   sts = fread( char_buff, rec_size, num_recs, f_ptr );
   if (sts <= 0) {
      status = FF_FILE_READ_ERROR + ERRO;
      free(char_buff);
      return( status );
      }

   i_ptr = (int *)uc_ptr;
   flib_header->form_ver_num       = *i_ptr;
#ifdef BIG_ENDIAN
   Xconv_int(&flib_header->form_ver_num);
#endif
   uc_ptr += 4;
   flib_header->libr_ver_num.user  = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->libr_ver_num.nfnt  = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->libr_ver_num.chng  = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->libr_ver_num.fix  = (char)(*uc_ptr);
   uc_ptr++;
   s_ptr = (short *)uc_ptr;
   flib_header->cre_date.year      = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&flib_header->cre_date.year);
#endif
   uc_ptr += 2;
   flib_header->cre_date.month     = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->cre_date.day       = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->cre_time.hour      = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->cre_time.min       = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->cre_time.sec       = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->cre_time.sec_100th = (char)(*uc_ptr);
   uc_ptr++;
   s_ptr = (short *)uc_ptr;
   flib_header->mod_date.year      = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&flib_header->mod_date.year);
#endif
   uc_ptr += 2;
   flib_header->mod_date.month     = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->mod_date.day       = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->mod_time.hour      = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->mod_time.min       = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->mod_time.sec       = (char)(*uc_ptr);
   uc_ptr++;
   flib_header->mod_time.sec_100th = (char)(*uc_ptr);
   uc_ptr++;


/* dmb:2/22/90 */
   memcpy( &ui_val, uc_ptr, sizeof ( int ) );
   flib_header->last_font          = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&flib_header->last_font); 
#endif
/* dmb:2/22/90
   flib_header->last_font          = UTconv_int( (unsigned int *)uc_ptr );
*/

   uc_ptr += 4;

   for (char_ptr = (char *)(&flib_header->lib_descrip[0]), count = 0;
        count < 80;
        count++, char_ptr++, uc_ptr++ )
      *char_ptr = (char)(*uc_ptr);

/* This doesn't work if format is Big Endian - Yvonne 
   flib_header->char_fst_fnt = (short)(*uc_ptr);
*/
   s_ptr = (short *)uc_ptr;
   flib_header->char_fst_fnt = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&flib_header->char_fst_fnt);
#endif
   uc_ptr += 2;
/*
   flib_header->sym_fst_fnt = (short)(*uc_ptr);
*/
   s_ptr = (short *)uc_ptr;
   flib_header->sym_fst_fnt = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&flib_header->sym_fst_fnt);
#endif
   uc_ptr += 2;
/*
   flib_header->pat_fst_fnt = (short)(*uc_ptr);
*/
   s_ptr = (short *)uc_ptr;
   flib_header->pat_fst_fnt = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&flib_header->pat_fst_fnt);
#endif
   uc_ptr += 2;
/*
   flib_header->line_fst_fnt = (short)(*uc_ptr);
*/
   s_ptr = (short *)uc_ptr;
   flib_header->line_fst_fnt = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&flib_header->line_fst_fnt);
#endif
   uc_ptr += 2;

   for (char_ptr = (char *)(&flib_header->reserve[0]), count = 0;
        count < 56;
        count++, char_ptr++, uc_ptr++ )
      *char_ptr = (char)(*uc_ptr);

   i_ptr   = (int *)uc_ptr;
   flib_header->fnt_ptr    = *i_ptr;
#ifdef BIG_ENDIAN
   Xconv_int(&flib_header->fnt_ptr);
#endif
   uc_ptr += 4;
   i_ptr   = (int *)uc_ptr;
   flib_header->fot_ptr    = *i_ptr;
#ifdef BIG_ENDIAN
   Xconv_int(&flib_header->fot_ptr);
#endif
   uc_ptr += 4;
   i_ptr   = (int *)uc_ptr;
   flib_header->nxt_av_blk = *i_ptr;
#ifdef BIG_ENDIAN
   Xconv_int(&flib_header->nxt_av_blk);
#endif
   uc_ptr += 4;
/*
   flib_header->nxt_av_wrd = (short)(*uc_ptr);
*/
   us_ptr = (unsigned short *)uc_ptr;
   flib_header->nxt_av_wrd = *us_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&flib_header->nxt_av_wrd);
#endif
   uc_ptr += 2;
   i_ptr   = (int *)uc_ptr;

/* dmb:2/22/90 */
   memcpy( &ui_val, uc_ptr, sizeof ( int ) );
   flib_header->rec_len          = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&flib_header->rec_len);
#endif
/* dmb:2/22/90 
   flib_header->rec_len    = UTconv_int( (unsigned int *)uc_ptr );
*/
   uc_ptr += 4;

   for (char_ptr = (char *)(&flib_header->reserv[0]), count = 0;
        count < 161;
        count++, char_ptr++, uc_ptr++ )
      *char_ptr = (char)(*uc_ptr);

   free(char_buff);
#ifdef DEBUG
   Flib_print_lib_header(flib_header);
#endif

   return( status );
}


#ifdef DEBUG
Flib_print_lib_header(flib_header)
   struct library_header *flib_header;
{
   FILE *fp;

   fp = fopen("/usr/tmp/tmplh.ftb", "w");

   fprintf(fp, "FLIB_HEADER\n");
   fprintf(fp, "	form_ver_num      	%d\n",
					flib_header->form_ver_num);
   fprintf(fp, "	libr_ver_num.user 	%d\n",
					flib_header->libr_ver_num.user);
   fprintf(fp, "	libr_ver_num.nfnt 	%d\n",
					flib_header->libr_ver_num.nfnt);
   fprintf(fp, "	libr_ver_num.chng 	%d\n",
					flib_header->libr_ver_num.chng);
   fprintf(fp, "	libr_ver_num.fix  	%d\n",
					flib_header->libr_ver_num.fix);
   fprintf(fp, "	cre_date.year     	%d\n",
					flib_header->cre_date.year);
   fprintf(fp, "	cre_date.month	  	%d\n",
					flib_header->cre_date.month);
   fprintf(fp, "	cre_date.day	  	%d\n",
					flib_header->cre_date.day);
   fprintf(fp, "	cre_time.hour	  	%d\n",
					flib_header->cre_time.hour);
   fprintf(fp, "	cre_time.min	  	%d\n",
					flib_header->cre_time.min);
   fprintf(fp, "	cre_time.sec	  	%d\n",
					flib_header->cre_time.sec);
   fprintf(fp, "	cre_time.sec_100th 	%d\n",
					flib_header->cre_time.sec_100th);
   fprintf(fp, "	mod_date.year	  	%d\n",
					flib_header->mod_date.year);
   fprintf(fp, "	mod_date.month	  	%d\n",
					flib_header->mod_date.month);
   fprintf(fp, "	mod_date.day	  	%d\n",
					flib_header->mod_date.day);
   fprintf(fp, "	mod_time.hour	  	%d\n",
					flib_header->mod_time.hour);
   fprintf(fp, "	mod_time.min	  	%d\n",
					flib_header->mod_time.min);
   fprintf(fp, "	mod_time.sec	  	%d\n",
					flib_header->mod_time.sec);
   fprintf(fp, "	mod_time.sec_100th 	%d\n",
					flib_header->mod_time.sec_100th);
   fprintf(fp, "	last_font	  	%d\n",
					flib_header->last_font);
   fprintf(fp, "	lib_descrip	  	%s\n",
					flib_header->lib_descrip);
   fprintf(fp, "	char_fst_fnt	  	%d\n",
					flib_header->char_fst_fnt);
   fprintf(fp, "	sym_fst_fnt	  	%d\n",
					flib_header->sym_fst_fnt);	
   fprintf(fp, "	pat_fst_fnt 	  	%d\n",
					flib_header->pat_fst_fnt);
   fprintf(fp, "	line_fst_fnt	  	%d\n",
					flib_header->line_fst_fnt);
   fprintf(fp, "	reserve		  	%s\n",
					flib_header->reserve);
   fprintf(fp, "	fnt_ptr		  	%d\n",
					flib_header->fnt_ptr);
   fprintf(fp, "	fot_ptr		  	%d\n",
					flib_header->fot_ptr);
   fprintf(fp, "	nxt_av_blk  	  	%d\n",
					flib_header->nxt_av_blk);
   fprintf(fp, "	nxt_av_wrd	  	%d\n",
					flib_header->nxt_av_wrd);
   fprintf(fp, "	rec_len	  	  	%d\n",
					flib_header->rec_len);
   fprintf(fp, "	reserv		  	%s\n",
					flib_header->reserv);

   fclose(fp);
}
#endif


/******************************************************************************/
/*                                                                            */
/*  NAME:	Flib_read_font_header - Reads a font header.                  */
/*	This routine reades a Font Header from a Vax Font Library File into   */
/*      a buffer, then converts the buffer into a font header sturcture       */
/*      for use on the interpro 32C.                                          */
/*                                                                            */
/*  RETURN VALUES:                                                            */
/*                                                                            */
/*         FF_S_SUCCESS                                                       */
/*         FF_FONT_INTER_ALLOCATE + ERRO                                      */
/*         FF_FILE_READ_ERROR     + ERRO                                      */
/*         FF_FILE_SEEK_ERROR     + ERRO                                      */
/*                                                                            */
/*                                                                            */
/*  NOTES:                                                                    */
/*                                                                            */
/*  AUTHOR:	S. Williams	DATE:	28-Aug-1987                           */
/*                                                                            */
/*  SEE ALSO:                                                                 */
/*                                                                            */
/*  MODIFICATIONS:                                                            */
/*                                                                            */
/******************************************************************************/

Flib_read_font_header( fontheader, rec_size, num_recs, f_ptr, offset )

        struct font_header *fontheader;
               int          rec_size;
               int          num_recs;
               FILE        *f_ptr;
               int          offset;
{
	         int     sts, status;
                 int     count, num_floats;
        unsigned long    vax_float[10];
                 double  ieee_float[5];
        unsigned int     ui_val;
        unsigned short  *us_ptr;
                 short  *s_ptr;
                 char   *char_ptr;
	unsigned char   *char_buff, *uc_ptr;
    

   status = FF_S_SUCCESS;

   char_buff = (unsigned char *)malloc( rec_size );
   if (char_buff == NULL) {
      status = FF_FONT_INTER_ALLOCATE + ERRO;
      return( status );      
      }

   uc_ptr = char_buff;
   sts = fseek( f_ptr, offset, 0 );
   if (sts < 0) {
      status = FF_FILE_SEEK_ERROR + ERRO;
      free(char_buff);
      return( status );
      }

   sts = fread( char_buff, rec_size, num_recs, f_ptr );
   if (sts <= 0) {
      status = FF_FILE_READ_ERROR + ERRO;
      free(char_buff);
      return( status );
      }

   s_ptr   = (short *)uc_ptr;
   fontheader->cre_date.year      = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->cre_date.year);
#endif
   uc_ptr += 2;
   fontheader->cre_date.month     = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->cre_date.day       = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->cre_time.hour      = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->cre_time.min       = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->cre_time.sec       = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->cre_time.sec_100th = (char)(*uc_ptr);
   uc_ptr++;
   s_ptr   = (short *)uc_ptr;
   fontheader->mod_date.year      = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->mod_date.year);
#endif
   uc_ptr += 2;
   fontheader->mod_date.month     = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->mod_date.day       = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->mod_time.hour      = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->mod_time.min       = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->mod_time.sec       = (char)(*uc_ptr);
   uc_ptr++;
   fontheader->mod_time.sec_100th = (char)(*uc_ptr);
   uc_ptr++;

   for (char_ptr = (char *)(&fontheader->font_descrip[0]), count = 0;
        count < 80;
        count++, char_ptr++, uc_ptr++ )
      *char_ptr = (char)(*uc_ptr);

   s_ptr   = (short *)uc_ptr;
   fontheader->font_class    = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->font_class);
#endif
   uc_ptr += 2;
   s_ptr   = (short *)uc_ptr;
   fontheader->display_font  = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->display_font);
#endif
   uc_ptr += 2;
   s_ptr   = (short *)uc_ptr;
   fontheader->vect_wrd_size = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->vect_wrd_size);
#endif
   uc_ptr += 2;

   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->x_origin      = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->x_origin);
#endif
   uc_ptr += 4;

   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->y_origin      = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->y_origin);
#endif
   uc_ptr += 4;

#ifndef BIG_ENDIAN
   num_floats = 2;
   s_ptr      = (short *)uc_ptr;
   us_ptr     = (unsigned short *)(&vax_float[0]);
   for (count = 0; count < 8; count++, us_ptr++, s_ptr++)
   {
      *us_ptr = (unsigned short)(*s_ptr);
   }

   UTfltvax_to_flt32( num_floats, vax_float, &ieee_float[0]);
   fontheader->x_scale       = ieee_float[0];
   fontheader->y_scale       = ieee_float[1];
#else
/*
   Xconv_double(&fontheader->x_scale);
   Xconv_double(&fontheader->y_scale);
*/
   fontheader->x_scale       = 0.047244;   /* Scale is not used in   */ 
   fontheader->y_scale       = 0.047244;   /* creating typeface file */
#endif
   uc_ptr += 16;

   us_ptr  = (unsigned short *)uc_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val += (unsigned int)(*us_ptr);
   fontheader->tile_hgth     = UTconv_int( &ui_val );
   uc_ptr += 4;

   s_ptr   = (short *)uc_ptr;
   fontheader->res_bm        = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->res_bm);
#endif
   uc_ptr += 2;

   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_0         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_0);
#endif
   uc_ptr += 4;
   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_1         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_1);
#endif
   uc_ptr += 4;
   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_2         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_2);
#endif
   uc_ptr += 4;
   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_3         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_3);
#endif
   uc_ptr += 4;
   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_4         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_4);
#endif
   uc_ptr += 4;
   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_5         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_5);
#endif
   uc_ptr += 4;
   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_6         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_6);
#endif
   uc_ptr += 4;
   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->res_7         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->res_7);
#endif
   uc_ptr += 4;

   s_ptr   = (short *)uc_ptr;
   fontheader->reserv        = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->reserv);
#endif
   uc_ptr += 2;
   s_ptr   = (short *)uc_ptr;
   fontheader->beg_char      = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->beg_char);
#endif
   uc_ptr += 2;
   s_ptr   = (short *)uc_ptr;
   fontheader->end_char      = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->end_char);
#endif
   uc_ptr += 2;
   s_ptr   = (short *)uc_ptr;
   fontheader->num_of_char   = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->num_of_char);
#endif
   uc_ptr += 2;
   s_ptr   = (short *)uc_ptr;
   fontheader->code_size     = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->code_size);
#endif
   uc_ptr += 2;
   s_ptr   = (short *)uc_ptr;
   fontheader->face_fnt_dir  = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->face_fnt_dir);
#endif
   uc_ptr += 2;

   us_ptr  = (unsigned short *)uc_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val += (unsigned int)(*us_ptr);
   fontheader->char_def_len  = UTconv_int( &ui_val );
   uc_ptr += 4;

   us_ptr  = (unsigned short *)uc_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val += (unsigned int)(*us_ptr);
   fontheader->ccot_ptr      = UTconv_int( &ui_val );
   uc_ptr += 4;

   us_ptr  = (unsigned short *)uc_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val += (unsigned int)(*us_ptr);
   fontheader->cdt_ptr       = UTconv_int( &ui_val );
   uc_ptr += 4;

   s_ptr   = (short *)uc_ptr;
   fontheader->dim_flag      = *s_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(&fontheader->dim_flag);
#endif
   uc_ptr += 2;

   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->vcot_ptr      = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->vcot_ptr);
#endif
   uc_ptr += 4;

   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->flags         = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->flags);
#endif
   uc_ptr += 4;

   us_ptr  = (unsigned short *)uc_ptr;
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
   ui_val += (unsigned int)(*us_ptr);
   fontheader->hdr_exp       = UTconv_int( &ui_val );
#ifdef BIG_ENDIAN
   Xconv_int(&fontheader->hdr_exp);
#endif
   uc_ptr += 4;

   us_ptr  = (unsigned short *)uc_ptr;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val  = ((unsigned int)(*us_ptr) << 16);
   us_ptr++;
#ifdef BIG_ENDIAN
   Xconv_short(us_ptr);
#endif
   ui_val += (unsigned int)(*us_ptr);
   fontheader->fnt_len       = UTconv_int( &ui_val );

   free(char_buff);
#ifdef DEBUG
   Flib_print_font_header(fontheader);
#endif

   return( status );
}


#ifdef DEBUG
Flib_print_font_header(fontheader)
   struct font_header *fontheader;
{
   FILE *fp;

   fp = fopen("/usr/tmp/tmpfh.ftb", "w");

   fprintf(fp, "FONT_HEADER\n");
   fprintf(fp, "        cre_date.year 		%d\n",
					fontheader->cre_date.year);
   fprintf(fp, " 	cre_date.month 		%d\n",
					fontheader->cre_date.month);
   fprintf(fp, " 	cre_date.day 		%d\n",
					fontheader->cre_date.day);
   fprintf(fp, " 	cre_time.hour 		%d\n",
					fontheader->cre_time.hour);
   fprintf(fp, " 	cre_time.min 		%d\n",
					fontheader->cre_time.min);
   fprintf(fp, " 	cre_time.sec 		%d\n",
					fontheader->cre_time.sec);
   fprintf(fp, " 	cre_time.sec_100th 	%d\n",
					fontheader->cre_time.sec_100th);
   fprintf(fp, " 	mod_date.year 		%d\n",
					fontheader->mod_date.year);
   fprintf(fp, " 	mod_date.month 		%d\n",
					fontheader->mod_date.month);
   fprintf(fp, " 	mod_date.day 		%d\n",
					fontheader->mod_date.day);
   fprintf(fp, " 	mod_time.hour 		%d\n",
					fontheader->mod_time.hour);
   fprintf(fp, " 	mod_time.min 		%d\n",
					fontheader->mod_time.min);
   fprintf(fp, " 	mod_time.sec 		%d\n",
					fontheader->mod_time.sec);
   fprintf(fp, " 	mod_time.sec_100th 	%d\n",
					fontheader->mod_time.sec_100th);
   fprintf(fp, " 	font_descrip 		%s\n",
					fontheader->font_descrip);
   fprintf(fp, " 	font_class		%d\n", 
					fontheader->font_class);
   fprintf(fp, " 	display_font 		%d\n",
					fontheader->display_font);
   fprintf(fp, " 	vect_wrd_size 		%d\n",
					fontheader->vect_wrd_size);
   fprintf(fp, " 	x_origin 		%d\n",
					fontheader->x_origin);
   fprintf(fp, " 	y_origin 		%d\n",
					fontheader->y_origin);
   fprintf(fp, " 	x_scale 		%lf\n",
					fontheader->x_scale);
   fprintf(fp, " 	y_scale 		%lf\n",
					fontheader->y_scale);
   fprintf(fp, " 	tile_hgth 		%d\n",
					fontheader->tile_hgth);
   fprintf(fp, " 	res_bm 			%d\n",
					fontheader->res_bm);
   fprintf(fp, " 	res_0 			%d\n",
					fontheader->res_0);
   fprintf(fp, " 	res_1 			%d\n",
					fontheader->res_1);
   fprintf(fp, " 	res_2 			%d\n",
					fontheader->res_2);
   fprintf(fp, " 	res_3 			%d\n",
					fontheader->res_3);
   fprintf(fp, " 	res_4 			%d\n",
					fontheader->res_4);
   fprintf(fp, " 	res_5 			%d\n",
					fontheader->res_5);
   fprintf(fp, " 	res_6 			%d\n",
					fontheader->res_6);
   fprintf(fp, " 	res_7 			%d\n",
					fontheader->res_7);
   fprintf(fp, " 	reserv 			%d\n",
					fontheader->reserv);
   fprintf(fp, " 	beg_char 		%d\n",
					fontheader->beg_char);
   fprintf(fp, " 	end_char 		%d\n",
					fontheader->end_char);
   fprintf(fp, " 	num_of_char 		%d\n",
					fontheader->num_of_char);
   fprintf(fp, " 	code_size 		%d\n",
					fontheader->code_size);
   fprintf(fp, " 	face_fnt_dir 		%d\n",
					fontheader->face_fnt_dir);
   fprintf(fp, " 	char_def_len 		%d\n",
					fontheader->char_def_len);
   fprintf(fp, " 	ccot_ptr 		%d\n",
					fontheader->ccot_ptr);
   fprintf(fp, " 	cdt_ptr 		%d\n",
					fontheader->cdt_ptr);
   fprintf(fp, " 	dim_flag 		%d\n",
					fontheader->dim_flag);
   fprintf(fp, " 	vcot_ptr 		%d\n",
					fontheader->vcot_ptr);
   fprintf(fp, " 	flags 			%d\n",
					fontheader->flags);
   fprintf(fp, " 	hdr_exp 		%d\n",
					fontheader->hdr_exp);
   fprintf(fp, " 	fnt_len 		%d\n",
					fontheader->fnt_len);

   fclose(fp);
}
#endif



/******************************************************************************/
/*                                                                            */
/*  NAME:	Flib_open_lib - retrieves font names, numbers, and offsets.   */
/*                                                                            */
/*     This function opens a flib font library for read only and loads the    */
/*     font numbers and names into a variable "GGlist Flib_files."            */
/*     flib_file contains the path and name of the font library to open.      */
/*     The offsets to the font headers are loaded into a variable             */
/*     "int Flib_font_offsets[256]".                                          */
/*                                                                            */
/*  RETURN VALUES:                                                            */
/*                                                                            */
/*         FF_S_SUCCESS                                                       */
/*         FF_FONT_NOTOPENED  + ERRO                                          */
/*         FF_FILE_READ_ERROR + ERRO                                          */
/*         FF_FILE_SEEK_ERROR + ERRO                                          */
/*         FF_MALLOC_ERROR    + ERRO                                          */
/*         FF_FONT_NOTLOADED  + ERRO                                          */
/*                                                                            */
/*                                                                            */
/*  NOTES:                                                                    */
/*                                                                            */
/*  AUTHOR:	S. Williams	DATE:	28-Aug-1987                           */
/*                                                                            */
/*  SEE ALSO:                                                                 */
/*                                                                            */
/*  MODIFICATIONS:                                                            */
/*                                                                            */
/******************************************************************************/

Flib_open_lib ( flib_file )

	Typepath   flib_file;

{

	       int               sts, status, count1, count2, count3,
                                 init_font,
                                 cur_fontnode_offset, flib_font_offsets[256],
                                 font_offset;
               short             num_flib_fonts, *s_ptr,
                                *CX8to16();
               char             *CX16to8();
               GGitem_list      *flib_ptr;
               GGlist            font_name[256];
               FILE             *f_ptr, *fopen();
        struct font_offset_table offset_node;
        struct font_header       fontheader;

   status    = FF_S_SUCCESS;
   init_font = 0;
   f_ptr     = NULL;

   f_ptr = fopen( CX16to8(flib_file), "r" );
   if ( f_ptr == NULL ) {
	status = FF_FONT_NOT_OPEN + ERRO;
        goto end_Flib_open_lib;
        }

   for (count1 = 0; count1 < 256; count1++) {
      flib_font_offsets[count1] = 0;
      font_name[count1][0] = 0;
      }

   status = Flib_read_lib_header( &Flib_header, sizeof(struct library_header), 1, f_ptr, 0 );
   if (status != FF_S_SUCCESS ) {
      status = FF_FILE_READ_ERROR + ERRO;
      init_font = 1;
      goto end_Flib_open_lib;
      }

   font_offset = cur_fontnode_offset = Flib_header.fot_ptr;
   while( cur_fontnode_offset ) {

      if( cur_fontnode_offset ) {
         sts = fseek(f_ptr, cur_fontnode_offset, 0 );
         font_offset = ftell( f_ptr );
         if (sts < 0) {
            status = FF_FILE_SEEK_ERROR + ERRO;
            init_font = 1;
            goto end_Flib_open_lib;
            }

         sts = fread(&offset_node, 1, sizeof(struct font_offset_table), f_ptr);
         if (sts <= 0) {
            status = FF_FILE_READ_ERROR + ERRO;
            init_font = 1;
            goto end_Flib_open_lib;
            }

#ifdef BIG_ENDIAN
	 Xconv_short(&offset_node.first_font);
         Xconv_short(&offset_node.last_font);
#endif
         for (count2 =  (int)offset_node.first_font,
              count3 =  0;
              count2 <=  (int)offset_node.last_font;
              count2++, count3++) {
#ifdef BIG_ENDIAN
            Xconv_int(&offset_node.fnt_hdr_ptr[count3]);
#endif
            if (offset_node.fnt_hdr_ptr[count3] > 0)
            flib_font_offsets[count2] =  offset_node.fnt_hdr_ptr[count3]
                                        + font_offset;
            }
#ifdef BIG_ENDIAN
         Xconv_int(&offset_node.next_node);
#endif
         if( offset_node.next_node )
             cur_fontnode_offset += offset_node.next_node;
           else
             cur_fontnode_offset = 0;
         }
      }

   num_flib_fonts = 0;
   for ( count1 = 0; count1 < 256; count1++ ) {
      font_offset = flib_font_offsets[count1];
      if (font_offset > 0 ) {
         status = Flib_read_font_header( &fontheader, sizeof(struct font_header),
                                     1, f_ptr, font_offset );
         if (status != FF_S_SUCCESS) {
            status = FF_FILE_READ_ERROR + ERRO;
            goto end_Flib_open_lib;
            }

         if (!(   (fontheader.font_class == CHARACTER_CLASS)
               || (fontheader.font_class == SYMBOL_CLASS    )) ) {
             flib_font_offsets[count1] = 0;
             font_name[count1][0] = 0;
             }
           else {
              num_flib_fonts += 1;
              sprintf16( font_name[count1], CX8to16("%3d"), count1);
              s_ptr = &font_name[count1][3];
              if (fontheader.font_class == 0)
                  strcat16((char *)s_ptr , (char *)CX8to16(" character") );
                else if(fontheader.font_class == 1)
                  strcat((char *)s_ptr , (char *)CX8to16(" symbol   ") );
              }
         }
      }

   if (num_flib_fonts > 0) {

        Num_flib_fonts = num_flib_fonts;

        memcpy( (char *)(&Flib_font_offsets[0]), (char *)(&flib_font_offsets[0]),
                (256 * sizeof(int)) );

       if( Flib_fonts ) {
          free( Flib_fonts );
          Flib_fonts = NULL;
          }
 
       Flib_fonts = (GGitem_list *)malloc(
                    (Num_flib_fonts + 1) * sizeof(GGitem_list) );
       if ( Flib_fonts == NULL ) {
           printf("%s\n","Flib_open_lib: malloc(flib_fonts)");
           status = FF_MALLOC_ERROR + ERRO;
           FF_report_error( status );
           init_font = 1;
           goto end_Flib_open_lib;
           }

       memset( (char *)Flib_fonts, (char)NULL,
               ((Num_flib_fonts + 1) * sizeof(GGitem_list) ) );
       flib_ptr = Flib_fonts;
       }
     else {
       status = FF_FONT_NOT_LOADED + ERRO;
       printf("\nNo character or symbol fonts found.\n");
       FF_report_error( status );
       goto end_Flib_open_lib;
       }

   for (   count1 = 0, count2 = 0;
          (count1 < 256) && (count2 < Num_flib_fonts);
           count1++ ) {
      if( Flib_font_offsets[count1] ) {
         strcpy16( flib_ptr->item, font_name[count1] );
         if(count1 == 0)
            flib_ptr->state = 1;
           else
            flib_ptr->state = 0;
         flib_ptr++;
         count2++;
         }
      }

end_Flib_open_lib:

   if ( (status != FF_S_SUCCESS) && (init_font) ) {
      for (count1 = 0; count1 < 256; count1++) {
         Flib_font_offsets[count1] = 0;
         font_name[count1][0] = 0;
         }
      if( Flib_fonts ) free( Flib_fonts );
      Num_flib_fonts = 0;
      }

   if( f_ptr ) fclose ( f_ptr );

   return ( status );
}



/******************************************************************************/
/*                                                                            */
/*  NAME:	Flib_load_font - retrieves font names, numbers, and offsets.  */
/*                                                                            */
/*     This function opens a flib font library for read only and loads the    */
/*     font numbers and names into an external variable "GGlist Flib_files."  */
/*     flib_file contains the path and name of the font library to open.      */
/*     The offsets to the font headers are loaded into a variable             */
/*     "int Flib_font_offsets[256]".                                          */
/*                                                                            */
/*                                                                            */
/*  RETURN VALUES:                                                            */
/*                                                                            */
/*         FF_S_SUCCESS                                                       */
/*         FF_FONT_NOTOPENED  + ERRO                                          */
/*         FF_FILE_READ_ERROR + ERRO                                          */
/*         FF_FILE_SEEK_ERROR + ERRO                                          */
/*         FF_MALLOC_ERROR    + ERRO                                          */
/*         FF_FONT_NOTLOADED  + ERRO                                          */
/*                                                                            */
/*                                                                            */
/*  NOTES:                                                                    */
/*                                                                            */
/*  AUTHOR:	S. Williams	DATE:	28-Aug-1987                           */
/*                                                                            */
/*  SEE ALSO:                                                                 */
/*                                                                            */
/*  MODIFICATIONS:                                                            */
/*                                                                            */
/******************************************************************************/

Flib_load_font ( flib_file, flib_font_num )

	Typepath   flib_file;
	short      flib_font_num;

{
	         int                sts1, sts2, sts3, status, index, dim_index,
                                    count1, count2, count4, count5,
                                    header_offset, num_chars, 
                                    cur_charnode_offset, cur_metnode_offset,
                                    char_offset, next_offset, num_blks,
                                    wrd_size, trans_x, trans_y,
                                    prev_px, prev_py, px, py,
                                    num_elements;
        static   int                blk_size = 1024; /** 64 **/
                 short             *s1_blk_ptr, *s2_blk_ptr, *s_end_buff,
                                    element_type, num_edges, mono_width;
                 char              *char_buff, 
                                   *char_x, *char_y, *CX16to8();
                 double             beta, beta_prime, xo, yo, x1, y1, x2, y2;
                 FILE              *f_ptr, *fopen();
                 FF_outl_recs      *head_rec, *head_ptr, *outl_recptr, *prev_outlrec,
                                   *rec_ptr, *end_outl;
               Conv_table          *char_index, *font_dat;
        struct char_dim_table       char_metrics;
        struct char_code_off_tbl    char_node;
#ifdef DEBUG
		FILE *myfp;
#endif

   status         = FF_S_SUCCESS;
   char_buff      = NULL;
   Num_flib_chars = 0;
   f_ptr          = NULL;

#ifdef DEBUG
   myfp = fopen("/usr/tmp/tmpload_fn.ftb", "w");
   fprintf(myfp, "FLIB_LOAD_FONT\n");
#endif
   f_ptr = fopen( CX16to8(flib_file), "r" );
   if ( f_ptr == NULL ) {
	status = FF_FONT_NOT_OPEN + ERRO;
        goto end_Flib_load_font;
        }

   if( Flib_chars ) {
      for (count1 = 0, char_index = Flib_chars;
      count1 < Flib_fontheader.end_char + 32;
      count1++, char_index++ ) {
         if( char_index->vect_elements )
            free( char_index->vect_elements );
         }
      free( Flib_chars );
      Flib_chars = NULL;
      }

   header_offset  = Flib_font_offsets[flib_font_num];
   status = Flib_read_font_header( &Flib_fontheader, sizeof(struct font_header),
                                   1, f_ptr, header_offset );
   if (status != FF_S_SUCCESS) {
       status = FF_FILE_READ_ERROR + ERRO;
       goto end_Flib_load_font;
       }

   trans_x    = Flib_fontheader.x_origin * -1;
   trans_y    = Flib_fontheader.y_origin * -1;
   mono_width = 0;
   dim_index  = 1;
   if( (Flib_fontheader.dim_flag & 0x0002) == 2)
      dim_index += 1;
   if( (Flib_fontheader.dim_flag & 0x0004) == 4)
      dim_index += 1;
   if( (Flib_fontheader.dim_flag & 0x0008) == 8)
      dim_index += 1;
   if( (Flib_fontheader.dim_flag & 0x0010) == 16)
      dim_index += 1;
   if( (Flib_fontheader.dim_flag & 0x0020) == 32)
      dim_index += 1;

   Flib_chars = (Conv_table *)malloc( ((int)Flib_fontheader.end_char + 32) * sizeof(Conv_table));
   if (Flib_chars == NULL) {
       printf("Flib_load_font(): malloc(Flib_char_dims)\n");
       status = FF_MALLOC_ERROR + ERRO;
       FF_report_error( status );
       goto end_Flib_load_font;
       }

   Num_flib_chars = 0;
   memset((char *)Flib_chars, (char)NULL,
         (((int)Flib_fontheader.end_char + 32) * sizeof(Conv_table)) );
   char_index          = font_dat = Flib_chars;
   font_dat->x_min     = font_dat->y_min =  32768;
   font_dat->x_max     = font_dat->y_max = -32767;
   font_dat->num_words = 4;

   wrd_size = (int)Flib_fontheader.vect_wrd_size;
   char_buff = (char *)malloc( blk_size * wrd_size + 50 );
   if (char_buff == NULL) {
       printf("Flib_load_font(): malloc(char_buff)\n");
       status = FF_MALLOC_ERROR + ERRO;
       FF_report_error( status );
       goto end_Flib_load_font;
       }

   Num_flib_chars = 0;
   memset( char_buff, (char)NULL, (blk_size * wrd_size + 50) );

   if (    (Flib_fontheader.cdt_ptr  <= 0)
        || (Flib_fontheader.end_char <= 0)
        || (Flib_fontheader.ccot_ptr <= 0) ) {
       status = FF_FONT_NOT_LOADED + ERRO;
       printf("\nNo offset to character demsion table.\n");
       FF_report_error( status );
       goto end_Flib_load_font;
       }

   cur_charnode_offset = Flib_fontheader.ccot_ptr + header_offset;
   cur_metnode_offset  = Flib_fontheader.cdt_ptr  + header_offset;
   while( cur_charnode_offset ) {
      sts2 = fseek(f_ptr, cur_charnode_offset, 0 );
      if (sts2 < 0) {
         status = FF_FILE_SEEK_ERROR + ERRO;
         goto end_Flib_load_font;
         }
         
      sts2 = fread( &char_node, 1, sizeof(struct char_code_off_tbl), f_ptr ); 
      if (sts2 <= 0) {
         status = FF_FILE_READ_ERROR + ERRO;
         goto end_Flib_load_font;
         }

#ifdef BIG_ENDIAN
      Xconv_short(&char_node.first_char);
      Xconv_short(&char_node.last_char);
#endif
#ifdef DEBUG
fprintf(myfp, "char_node.first_char 		%d\n", char_node.first_char);
fprintf(myfp, "char_node.last_char 		%d\n", char_node.last_char);
#endif
         
      num_chars = (int)(char_node.last_char - char_node.first_char) + 1;

      sts1 = fseek(f_ptr, cur_metnode_offset, 0 );
      if (sts1 < 0) {
         status = FF_FILE_SEEK_ERROR + ERRO;
         goto end_Flib_load_font;
         }

      sts1 = fread( &char_metrics, 1, sizeof(struct char_dim_table), f_ptr ); 
      if (sts1 <= 0) {
           status = FF_FILE_READ_ERROR + ERRO;
           goto end_Flib_load_font;
           }

#ifdef BIG_ENDIAN
      Xconv_short(&char_metrics.first_char);
      Xconv_short(&char_metrics.last_char);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics.first_char 		%d\n", char_metrics.first_char);
fprintf(myfp, "char_metrics.last_char 		%d\n", char_metrics.last_char);
#endif

      for (count2  = (int)char_node.first_char, num_blks = 1;
           (count2 <= (int)char_node.last_char) && (num_chars > 0);
           count2++, num_blks = 1) {

         index = dim_index * (count2 - char_node.first_char);
#ifdef BIG_ENDIAN
	 Xconv_short(&char_node.ch_hdr_ptr[count2 - char_node.first_char]);
#endif
#ifdef DEBUG
fprintf(myfp, "char_node.ch_hdr_ptr[%d] %d, count2 %d\n",
	 		count2 - char_node.first_char, 
			char_node.ch_hdr_ptr[count2 - char_node.first_char],
			count2);
#endif
         if (char_node.ch_hdr_ptr[count2 - char_node.first_char] > 0) {
            char_offset = char_node.ch_hdr_ptr[count2 - char_node.first_char] + cur_charnode_offset;
            Num_flib_chars  += 1;
            
            char_index++;
            char_index->char_id  = count2;
/* char_index->char_id = char_index->char_id & 0x007f; */
            sts3 = fseek(f_ptr, char_offset, 0 );
            if (sts3 < 0) {
               status = FF_FILE_SEEK_ERROR + ERRO;
               goto end_Flib_load_font;
               }

            sts3 = fread( char_buff, 1, (blk_size * wrd_size), f_ptr ); 
            if (sts3 <= 0) {
                 status = FF_FILE_READ_ERROR + ERRO;
                 goto end_Flib_load_font;
                 }

            s1_blk_ptr = s_end_buff = (short *)char_buff;
            if (wrd_size == 1)
                s_end_buff += blk_size / 2;
              else
                s_end_buff += blk_size;
                  
            next_offset = ftell( f_ptr );
#ifdef BIG_ENDIAN
	    Xconv_short(&s1_blk_ptr[0]);
            char_index->options = s1_blk_ptr[0];
	    Xconv_short(&s1_blk_ptr[1]);		
						/******* CHK *******/
            num_elements        = (int)(s1_blk_ptr[1]);

#else
            char_index->options = s1_blk_ptr[0];
            num_elements        = s1_blk_ptr[1];
#endif
#ifdef DEBUG
fprintf(myfp, "s1_blk_ptr[0]              	%d\n", s1_blk_ptr[0]);
fprintf(myfp, "s1_blk_ptr[1]              	%d\n", s1_blk_ptr[1]);
fprintf(myfp, "num_elements			%d\n", num_elements);
#endif
            s1_blk_ptr         += 2;
            char_index->x_min = char_index->y_min =   32768;
            char_index->x_max = char_index->y_max =  -32767;
            if (wrd_size == 1) {
                char_index->set_width = (short)char_metrics.dim_data.byt[index];
						/******* CHK *******/
                char_index->set_width = char_index->set_width & 0x00ff;
                if ((Flib_fontheader.flags & 0x00000001) == 1)
                    char_index->set_width  = char_index->set_width * 2;

                index += 1;
                if( (Flib_fontheader.dim_flag & 0x0002) == 2) {
                    char_index->A_width    =  (unsigned short)char_metrics.dim_data.byt[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0004) == 4) {
                    char_index->C_width    = (unsigned short)char_metrics.dim_data.byt[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0008) == 8) {
                    char_index->ascender   = (unsigned short)char_metrics.dim_data.byt[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0010) == 16) {
                    char_index->descender  = (unsigned short)char_metrics.dim_data.byt[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0020) == 32) {
                    char_index->justification = (unsigned short)char_metrics.dim_data.byt[index];
                    index += 1;
                    }
                }
              else {
#ifdef BIG_ENDIAN
		Xconv_short(&char_metrics.dim_data.wrd[index]);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics.dim_data.wrd[%d]    %d\n", index, 
				char_metrics.dim_data.wrd[index]);
#endif

                char_index->set_width  = char_metrics.dim_data.wrd[index];
                if ((Flib_fontheader.flags & 0x00000001) == 1)
                    char_index->set_width  = char_index->set_width * 2;

                index += 1;
                if( (Flib_fontheader.dim_flag & 0x0002) == 2) {
#ifdef BIG_ENDIAN
		    Xconv_short(&char_metrics.dim_data.wrd[index]);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics.dim_data.wrd[%d]	%d\n", index,
					char_metrics.dim_data.wrd[index]);
#endif
                    char_index->A_width    = (short)char_metrics.dim_data.wrd[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0004) == 4) {
#ifdef BIG_ENDIAN
		    Xconv_short(&char_metrics.dim_data.wrd[index]);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics.dim_data.wrd[%d]	%d\n", index,
					char_metrics.dim_data.wrd[index]);
#endif
                    char_index->C_width    = (short)char_metrics.dim_data.wrd[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0008) == 8) {
#ifdef BIG_ENDIAN
		    Xconv_short(&char_metrics.dim_data.wrd[index]);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics.dim_data.wrd[%d]	%d\n", index,
					char_metrics.dim_data.wrd[index]);
#endif
                    char_index->ascender   = (short)char_metrics.dim_data.wrd[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0010) == 16) {
#ifdef BIG_ENDIAN
		    Xconv_short(&char_metrics.dim_data.wrd[index]);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics.dim_data.wrd[%d]	%d\n", index,
					char_metrics.dim_data.wrd[index]);
#endif
                    char_index->descender  = (short)char_metrics.dim_data.wrd[index];
                    index += 1;
                    }

                if( (Flib_fontheader.dim_flag & 0x0020) == 32) {
#ifdef BIG_ENDIAN
		    Xconv_short(&char_metrics.dim_data.wrd[index]);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics.dim_data.wrd[%d]	%d\n", index,
					char_metrics.dim_data.wrd[index]);
#endif
                    char_index->justification = (short)char_metrics.dim_data.wrd[index];
                    index += 1;
                    }
                }

            if (mono_width == 0)
                mono_width = char_index->set_width;
              else if ((mono_width > 0)
                    && (char_index->set_width != mono_width))
                mono_width = -1;

            char_index->num_outlines      = 0;
            char_index->num_line_strings  = 0;
            char_index->num_shapes        = 0;
            char_index->num_arcs          = 0;
            char_index->vect_elements = (FF_outl_recs *)
                                        malloc( blk_size * sizeof(FF_outl_recs));
            if (char_index->vect_elements == NULL) {
                printf("Flib_load_font(): malloc(char_index->vect_elements)\n");
                status = FF_MALLOC_ERROR + ERRO;
                FF_report_error( status );
                goto end_Flib_load_font;
                }
              else {
                memset((char *)char_index->vect_elements, (char)NULL,
                       (blk_size * sizeof(FF_outl_recs)) );
                end_outl  = char_index->vect_elements;
                end_outl += blk_size - 1;
                }

            head_rec        = head_ptr = outl_recptr = char_index->vect_elements;
            head_rec       += 2;
            head_ptr       += 3;
            
            outl_recptr += num_elements + 3;

            font_dat->num_words  += num_elements + 7;
            char_index->num_recs  = num_elements + 3;
            head_rec->px          = num_elements;
            head_rec->py          = 0;
            head_rec->rec_type    = HIER_HEAD;
         
            for (count4 = 0; count4 < num_elements; count4++, head_ptr++) {
            	
               head_ptr->pbeta = 0;
               head_ptr->py    = 1;
               if (outl_recptr >= (end_outl - 8) ) {
            	   num_blks++;
         	   status = Flib_realloc_outlrecs( &char_index->vect_elements,
            	                                   &outl_recptr, &head_rec, &head_ptr,
            	                                   &end_outl, blk_size, num_blks );
                   if (status != FF_S_SUCCESS) {
                     status = FF_MALLOC_ERROR + ERRO;
                     FF_report_error( status );
                     goto end_Flib_load_font;
                     }
                  }
        
               if (s1_blk_ptr >= s_end_buff) {
                  status = Flib_read_nxt_blk( char_buff, &next_offset, 
                                              blk_size, wrd_size, 1, f_ptr );
                  if (status != FF_S_SUCCESS)
                     goto end_Flib_load_font;
                  s1_blk_ptr  = (short *)char_buff;
                  }

						/******* CHK *******/
#ifdef BIG_ENDIAN
	       Xconv_short(&s1_blk_ptr[0]);
#endif
#ifdef DEBUG
fprintf(myfp, "s1_blk_ptr		%d\n", s1_blk_ptr[0]);
#endif
               element_type = (s1_blk_ptr[0] << 8 >> 8);
               s1_blk_ptr++;
               
               if ( s1_blk_ptr >= s_end_buff) {
                  status = Flib_read_nxt_blk(char_buff,&next_offset,blk_size,wrd_size,1,f_ptr);
                  if (status != FF_S_SUCCESS)
                     goto end_Flib_load_font;
                  s1_blk_ptr  = (short *)char_buff;
                  }
#ifdef BIG_ENDIAN
	       Xconv_short(&s1_blk_ptr[0]);
#endif
#ifdef DEBUG
fprintf(myfp, "s1_blk_ptr               %d\n", s1_blk_ptr[0]);
#endif
               num_edges = s1_blk_ptr[0];
               s1_blk_ptr++;

               if (num_edges == 0) {
                   head_rec              = char_index->vect_elements;
                   char_index->num_recs  = 0;
                   break;
                   }

               if (element_type == 1) {
                   char_index->num_line_strings += 1;
                   head_ptr->px = 2;
                   }
                 else if (element_type == 2) {
                   char_index->num_shapes += 1;
                   head_ptr->px = 1;
                   }
                 else if (element_type == 3) {
                   char_index->num_arcs += 1;
                   head_ptr->px = 2;
                   }
                 else {
                   status = FF_CHAR_INVALID_TYPE + ERRO;
                   FF_report_error( status );
                   goto end_Flib_load_font;
                   }

               font_dat->num_words      += 6;
               char_index->num_outlines += 1;
               head_ptr->rec_type        = HIER_TYPE;
               prev_outlrec              = outl_recptr;
               outl_recptr->rec_type     = MOVE_TO;
               outl_recptr->px           = 0;
               outl_recptr->py           = 0;
               outl_recptr->pbeta        = 0;
               prev_outlrec--;
               for(count5 = 0; count5 < num_edges; ) {

                  if (s1_blk_ptr >= s_end_buff) {
                     status = Flib_read_nxt_blk(char_buff,&next_offset,blk_size,wrd_size,1,f_ptr);
                     if (status != FF_S_SUCCESS)
                        goto end_Flib_load_font;
                     s1_blk_ptr  = (short *)char_buff;
                     }

                  if (wrd_size == 1) {
                      char_x = char_y = (char *)s1_blk_ptr;
                      char_y++;
                      px = (int)(*char_x);
                      py = (int)(*char_y);
							/****** CHK ******/
                      s1_blk_ptr++;
                      }
                    else {
                      s2_blk_ptr = s1_blk_ptr;
                      s2_blk_ptr++;
#ifdef BIG_ENDIAN
		      Xconv_short(s1_blk_ptr);
		      Xconv_short(s2_blk_ptr);
#endif
#ifdef DEBUG
fprintf(myfp, "s1_blk_ptr               %d\n", *s1_blk_ptr);
fprintf(myfp, "s2_blk_ptr               %d\n", *s2_blk_ptr);
#endif
                      px = (int)(*s1_blk_ptr);
                      py = (int)(*s2_blk_ptr);
#ifdef DEBUG
fprintf(myfp, "px			%d\n", px);
fprintf(myfp, "py			%d\n", py);
#endif
							/****** CHK ******/
                      s1_blk_ptr += 2;
                      }
                      
                  if (     (  (px == -128)
                           && (py == -128)
                           && (wrd_size == 1) )
                        || (  (px == -32768)
                           && (py == -32768)
                           && (wrd_size == 2) )  ) { 
                      char_index->num_outlines += 1;

                      outl_recptr->rec_type = MOVE_TO;
                      outl_recptr->pbeta    = 0;

                      font_dat->num_words   += 4;
                      char_index->num_recs  += 1;
                      head_ptr->py          += 1;
                       
                      if (element_type == 1)
                          char_index->num_line_strings += 1;
                        else if (element_type == 2)
                          char_index->num_shapes += 1;
                        else if (element_type == 3)
                          char_index->num_arcs += 1; 

                      count5++;
	              goto next_point;
                      }
                    else {
                      head_ptr->pbeta += 1;
                      outl_recptr->px  = px + trans_x;
                      outl_recptr->py  = py + trans_y;

                      if (outl_recptr->rec_type == MOVE_TO)
                         outl_recptr->pbeta    = 1;

                      count5++;
                      } 

                  if (char_index->x_min > outl_recptr->px)
                     char_index->x_min = outl_recptr->px;

                  if (char_index->x_max < outl_recptr->px)
                     char_index->x_max = outl_recptr->px;

                  if (char_index->y_min > outl_recptr->py)
                     char_index->y_min = outl_recptr->py;

                  if (char_index->y_max < outl_recptr->py)
                     char_index->y_max = outl_recptr->py;

                  if (      ( (element_type == 1)
                           || (element_type == 2)
                           || (element_type == 3)
                           || (Flib_fontheader.font_class == 0) )
                        && (outl_recptr->rec_type != MOVE_TO) ) {

                      outl_recptr->pbeta = 0;

                      if (     (outl_recptr->py      == prev_py)
                            && (abs(outl_recptr->px - prev_px) <= 8191   )
                            && (abs(outl_recptr->py - prev_py) <= 8191   ) ) {
                          outl_recptr->rec_type  = HORZ_VECT;
                          outl_recptr->px        = outl_recptr->px - prev_px;
                          prev_px                = px + trans_x;
                          outl_recptr->py        = 0;
                          font_dat->num_words   += 1;
                          char_index->num_recs  += 1;
                          }
                        else if ((outl_recptr->px == prev_px)
                              && (abs(outl_recptr->px - prev_px) <= 8191)
                              && (abs(outl_recptr->py - prev_py) <= 8191) ) {
                          outl_recptr->rec_type  = VERT_VECT;
                          outl_recptr->py        = outl_recptr->py - prev_py;
                          prev_py                = py + trans_y;
                          outl_recptr->px        = 0;
                          font_dat->num_words   += 1;
                          char_index->num_recs  += 1;
                          }
                        else {
                          outl_recptr->px        = outl_recptr->px - prev_px;
                          outl_recptr->py        = outl_recptr->py - prev_py;
                          prev_px                = px + trans_x;
                          prev_py                = py + trans_y;
                          char_index->num_recs  += 1;

                          if (      (abs(outl_recptr->px) <= 8191)
                                 && (abs(outl_recptr->py) <= 8191) ) {
                              outl_recptr->rec_type  = SHORT_VECT;
                              font_dat->num_words   += 2;
                              }
                            else {
                              outl_recptr->rec_type  = LONG_VECT;
                              font_dat->num_words   += 3;
                              }
                          }
                      }
                    else if ( (element_type == 3)
                           && (Flib_fontheader.font_class)
                           && (prev_outlrec->rec_type != MOVE_TO )
                           && (outl_recptr->rec_type  != MOVE_TO ) ){
                       rec_ptr         = prev_outlrec;
                       rec_ptr--;
                       outl_recptr->px = outl_recptr->px - prev_px;
                       outl_recptr->py = outl_recptr->py - prev_py;
                       prev_px         = px + trans_x;
                       prev_py         = py + trans_y;
                       x2              = (double)px;
                       y2              = (double)py;
                       x1              = (double)prev_px;
                       y1              = (double)prev_py;
                       xo              = (double)(prev_px - prev_outlrec->px);
                       yo              = (double)(prev_py - prev_outlrec->py);
                       beta            = ((-2.0 * x1) + xo + x2) / (y2 - yo);
                       beta_prime      = ((sqrt(beta * beta + 1.0)) - 1.0) / beta;

                       if ((rec_ptr->rec_type        == MOVE_TO)
                            && (abs(outl_recptr->px) <= 511)
                            && (abs(outl_recptr->py) <= 511)) {
                           prev_outlrec->rec_type = SHORT_ARC;
                           prev_outlrec->pbeta    = (int)(beta_prime * 65536.0);
                           prev_outlrec->pbeta    = prev_outlrec->pbeta >> 7 <<  23;
                           }
                        else if (rec_ptr->rec_type == MOVE_TO) {
                           prev_outlrec->rec_type = LONG_ARC;
                           prev_outlrec->pbeta    = (int)(beta_prime * 65536.0);
                           prev_outlrec->pbeta    = prev_outlrec->pbeta << 16;
                           font_dat->num_words   += 1;
                           }
                          
                       char_index->num_recs += 1;

                       if (     (abs(outl_recptr->px) <= 511)
                             && (abs(outl_recptr->py) <= 511) ) {
                           outl_recptr->rec_type = SHORT_ARC;
                       	   outl_recptr->pbeta = (int)(beta_prime * 65536.0);
                           outl_recptr->pbeta = prev_outlrec->pbeta >> 7 <<  23;
                           font_dat->num_words  += 2;
                           }
                         else {
                           outl_recptr->rec_type = LONG_ARC;
                           outl_recptr->pbeta    = (int)(beta_prime * 65536.0);
                           font_dat->num_words  += 4;
                           }

                       }
                    else if ( (element_type == 3)
                           && (Flib_fontheader.font_class)
                           && (prev_outlrec->rec_type == MOVE_TO) ) {
                      outl_recptr->px = outl_recptr->px - prev_px;
                      outl_recptr->py = outl_recptr->py - prev_py;
                      prev_px         = px + trans_x;
                      prev_py         = py + trans_y;

                      if (      (abs(outl_recptr->px - prev_px) <= 8191)
                             && (abs(outl_recptr->py - prev_py) <= 8191) ) {
                          outl_recptr->rec_type  = SHORT_VECT;
                          char_index->num_recs += 1;
                          font_dat->num_words  += 2;
                          }
                        else {
                          outl_recptr->rec_type  = LONG_VECT;
                          char_index->num_recs += 1;
                          font_dat->num_words  += 3;
                          }
                      }
                    else if (outl_recptr->rec_type == MOVE_TO) {
                      prev_px = outl_recptr->px;
                      prev_py = outl_recptr->py;
                      }
               
next_point:

                  if (   !( (outl_recptr->rec_type == MOVE_TO)
                         && (outl_recptr->pbeta    == 0 ) ) ) {
                      prev_outlrec = outl_recptr;
                      outl_recptr++;
                      }

                  if (outl_recptr >= (end_outl - 5) ) {
               	      num_blks++;
           	      status = Flib_realloc_outlrecs( &char_index->vect_elements,
            	                               &outl_recptr, &head_rec, &head_ptr,
            	                               &end_outl, blk_size, num_blks );
                      if (status != FF_S_SUCCESS)
                        goto end_Flib_load_font;
                     }
        
                  if (s1_blk_ptr >= s_end_buff) {
                     status = Flib_read_nxt_blk( char_buff, &next_offset,
                                                 blk_size, wrd_size, 1, f_ptr );
                     if (status != FF_S_SUCCESS)
                        goto end_Flib_load_font;

                     s1_blk_ptr  = (short *)char_buff;
                     }
                  }
               }

            outl_recptr->rec_type  = END_CHAR;
            outl_recptr->px        = 0;
            outl_recptr->py        = 0;
            outl_recptr->pbeta     = 0;

            font_dat->num_recs         += char_index->num_recs;
            font_dat->num_outlines     += char_index->num_outlines;
            font_dat->num_line_strings += char_index->num_line_strings;
            font_dat->num_shapes       += char_index->num_shapes;
            font_dat->num_arcs         += char_index->num_arcs;
            font_dat->num_words        += 1;

            char_index->num_recs  += 1;

            if (mono_width > 0)
               font_dat->set_width = mono_width;
              else if (char_index->char_id == 32)
               font_dat->set_width = char_index->set_width;

            head_rec = char_index->vect_elements;
            head_rec->rec_type = MIN_MAX_X;
            head_rec->px       = char_index->x_min;
            head_rec->py       = char_index->x_max;
            head_rec->pbeta    = 0;
            head_rec++;
            head_rec->rec_type = MIN_MAX_Y;
            head_rec->px       = char_index->y_min;
            head_rec->py       = char_index->y_max;
            head_rec->pbeta    = 0;
            head_rec++;

            if (char_index->x_min < font_dat->x_min)
               font_dat->x_min = char_index->x_min;
            if (char_index->y_min < font_dat->y_min)
               font_dat->y_min = char_index->y_min;
            if (char_index->x_max > font_dat->x_max)
               font_dat->x_max = char_index->x_max;
            if (char_index->y_max > font_dat->y_max)
               font_dat->y_max = char_index->y_max;
            }
           else
            font_dat->num_words   += 1;
         }

#ifdef BIG_ENDIAN
      Xconv_short(&char_metrics.next_node);
      Xconv_short(&char_node.next_node);
#endif
#ifdef DEBUG
fprintf(myfp, "char_metrics 		%d\n", char_metrics.next_node);
fprintf(myfp, "char_node		%d\n", char_node.next_node);
#endif
      if (char_metrics.next_node) {
          cur_charnode_offset += char_node.next_node;
          cur_metnode_offset  += char_metrics.next_node;
          }
        else {
          cur_charnode_offset  = 0;
          cur_metnode_offset   = 0;
          }
      }   


end_Flib_load_font:

   if (status != FF_S_SUCCESS) {
       if( Flib_chars ) {
          for (count5 = 0, char_index = Flib_chars;
               count5 < Flib_fontheader.end_char + 32;
               count5++, char_index++ ) {
             if( char_index->vect_elements )
                free( char_index->vect_elements );
             }

          free( Flib_chars );
          }

       Num_flib_chars = 0;
       Flib_chars     = NULL;
       }

#ifdef DEBUG
fclose(myfp);
#endif

   if( f_ptr ) fclose( f_ptr );

   if( char_buff ) free( char_buff );

   return( status );

}



Flib_check_font_num ( flib_file, font_num )

	Typepath   flib_file;
	short	   font_num;

{

	       int               sts, status, count1, count2, count3,
                                 init_font,
                                 cur_fontnode_offset, flib_font_offsets[256],
                                 font_offset;
               short             *CX8to16();
               char             *CX16to8();
               GGlist            font_name[256];
               FILE             *f_ptr, *fopen();
        struct font_offset_table offset_node;

   status    = FF_S_SUCCESS;
   init_font = 0;
   f_ptr     = NULL;

   f_ptr = fopen( CX16to8(flib_file), "r" );
   if ( f_ptr == NULL ) {
	status = FF_FONT_NOT_OPEN + ERRO;
        goto end_Flib_check_font_num;
        }

   for (count1 = 0; count1 < 256; count1++) {
      flib_font_offsets[count1] = 0;
      font_name[count1][0] = 0;
      }

   status = Flib_read_lib_header( &Flib_header, sizeof(struct library_header), 1, f_ptr, 0 );
   if (status != FF_S_SUCCESS ) {
      status = FF_FILE_READ_ERROR + ERRO;
      init_font = 1;
      goto end_Flib_check_font_num;
      }

   font_offset = cur_fontnode_offset = Flib_header.fot_ptr;
   while( cur_fontnode_offset ) {

      if( cur_fontnode_offset ) {
         sts = fseek(f_ptr, cur_fontnode_offset, 0 );
         font_offset = ftell( f_ptr );
         if (sts < 0) {
            status = FF_FILE_SEEK_ERROR + ERRO;
            init_font = 1;
            goto end_Flib_check_font_num;
            }

         sts = fread(&offset_node, 1, sizeof(struct font_offset_table), f_ptr);
         if (sts <= 0) {
            status = FF_FILE_READ_ERROR + ERRO;
            init_font = 1;
            goto end_Flib_check_font_num;
            }

#ifdef BIG_ENDIAN
	 Xconv_short(&offset_node.first_font);
         Xconv_short(&offset_node.last_font);
#endif

         for (count2 =  (int)offset_node.first_font,
              count3 =  0;
              count2 <=  (int)offset_node.last_font;
              count2++, count3++) {
#ifdef BIG_ENDIAN
            Xconv_int(&offset_node.fnt_hdr_ptr[count3]);
#endif
            if (offset_node.fnt_hdr_ptr[count3] > 0)
		if (font_num == count2) 
			goto end_Flib_check_font_num;
            }
#ifdef BIG_ENDIAN
         Xconv_int(&offset_node.next_node);
#endif
         if( offset_node.next_node )
             cur_fontnode_offset += offset_node.next_node;
           else
             cur_fontnode_offset = 0;
         }
      }

   status = FF_FILE_READ_ERROR + ERRO;	/* font num not found in font lib */

end_Flib_check_font_num:

   return ( status );
}

 

Flib_read_nxt_blk( char_buff, next_offset, blk_size, wrd_size, num_blks, f_ptr )

                  char   *char_buff;
                  int    *next_offset, blk_size, wrd_size, num_blks;
                  FILE   *f_ptr;
{
	          int                  sts, status;

    status = FF_S_SUCCESS;
    sts = fseek(f_ptr, (*next_offset), 0 );
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       return( status );
       }

    sts = fread( char_buff, 1, ((blk_size * wrd_size) * num_blks), f_ptr ); 
    if (sts <= 0) {
       status = FF_FILE_READ_ERROR + ERRO;
       return( status );
       }
       
     sts = ferror( f_ptr );
     if (sts > 0)
     printf("%s%d\n","read_nxt_blk: fread(char_buff)   status = ",sts);
     
/*   clearerr( f_ptr ); */

   *next_offset = ftell( f_ptr );

   return( status );
}




Flib_realloc_outlrecs( vect_elements, buff_ptr, vect_head, vect_ptr,
                    end_rec, blk_size, num_blks )

           FF_outl_recs **vect_elements, **buff_ptr,
                        **vect_head,     **vect_ptr, **end_rec;
                  int     blk_size, num_blks;
{
	          int                  status, save_index, save_head,
	                               save_headptr, save_end;
                  FF_outl_recs        *v_beg, *v_head, *v_ptr, *v_end,
                                      *s_end, *new_buff;

    status = FF_S_SUCCESS;

   v_beg        = *vect_elements;
   v_head       = *vect_head;
   v_ptr        = *vect_ptr;
   v_end        = *buff_ptr;
   s_end        = *end_rec;
   save_head    = (int)(v_head - v_beg);
   save_headptr = (int)(v_ptr  - v_beg);
   save_index   = (int)(v_end  - v_beg);
   save_end     = (int)(s_end  - v_beg);
   
   new_buff = (FF_outl_recs *)malloc(blk_size * num_blks * sizeof(FF_outl_recs));
   if (new_buff == NULL) {
       status = FF_MALLOC_ERROR + ERRO;
       FF_report_error( status );
       return ( status );
       }
     else {
       memset((char *)new_buff, (char)NULL, 
              (blk_size * num_blks * sizeof(FF_outl_recs)) );
       memcpy( (char *)new_buff, (char *)v_beg,
               ((int)((v_end - v_beg) + 1) * sizeof(FF_outl_recs)) );
       *vect_elements = new_buff;
       *vect_head     = new_buff;
       *vect_ptr      = new_buff;
       *end_rec       = new_buff;
       *buff_ptr      = new_buff;
       *vect_head    += save_head;
       *vect_ptr     += save_headptr;
       *buff_ptr     += save_index;
       *end_rec      += blk_size * num_blks;
       free( v_beg );
       }

   return( status );
}

