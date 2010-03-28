/*
$Log: FlibConv.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:32  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:46  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:47  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:29  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.1  1992/09/14  14:19:30  grnuc20
 * COMMENT : SGI ANSI fixes
 *
 * Revision 220.0  1992/08/29  06:29:50  root
 * COMMENT : Corresponds to Rel201.7 in 2.0.1 RCS
 *
 * Revision 201.7  1992/07/13  20:42:10  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <time.h>
#include <itools.h>
#include "flibstruct.h"
#include "FFdef.h"
#include "FFerrdef.h"
#include "FFstructs.h"


Flib_convert_font( new_typeface, typeface_desc, append, fill_type )

	Typepath new_typeface;
	char     typeface_desc[];
	int      append;
	int      fill_type;

{

        static   char        layout_name[] = { 
        "Bitstream compressed font format\0"};

        static   char        cpyrt_notice[] = {
        "(c) Copyright Bitstream Inc., 1987\0"};

        static   char        null_char = '\0';
                 char       *c_ptr, CX16to8();
        unsigned short      *beg_outlbuff, *end_outlbuff, *end_buff, state,
                             lo_charid;
                 /*short       wrd_space_width;*/
        /*static   int         blksize = 1024;*/
                 long        date;
                 int         status, sts, /*cur_event_mask, kn_count,*/ new_font, len,
                             count1, count2, count3, num_words;
        unsigned int         outlbuff_len,/* blk_hd_offset, rec_offset,*/
                             chardir_offset, outldata_offset,
                             nr_data_wds;
                 FILE       *fout_ptr, *fopen();
                 Conv_table *char_index, *end_index, *font_dat;

        /*struct   stat        stat_buff;*/

            FF_outl_recs    *outl_recptr;
            cft_chardir_rec *chdir_ptr, *hidir;
            FF_outl_str     *comp_font;

	extern struct   font_header      Flib_fontheader;
	extern          Conv_table      *Flib_chars;
        extern          short            Flib_font_num;
        extern unsigned short            Num_flib_chars;

   status = FF_S_SUCCESS;

   beg_outlbuff = NULL;
   fout_ptr     = NULL;
   comp_font    = (FF_outl_str *)malloc( sizeof(FF_outl_str) );
   memset( (char *)comp_font, (char)NULL, sizeof(FF_outl_str) );

   if (append == 1) {
       fout_ptr = fopen( (char *)(CX16to8(new_typeface)), "a+" );
       if ( fout_ptr == NULL ) {
          printf("%s\n","Flib_convert_font:  fopen(fout_ptr)");
          status = FF_FONT_NOT_OPEN + ERRO;
          return( status );
          }

       sts = fseek(fout_ptr, 0, 2);
       if (sts < 0) {
          printf("%s\n","Flib_convert_font:  fseek(fout_ptr)");
          status = FF_FILE_SEEK_ERROR + ERRO;
          fclose( fout_ptr );
          return( status );
          }

       len = ftell(fout_ptr);

       fclose( fout_ptr );
       if (len >  288) {
           status = FS_load_typeface( new_typeface, comp_font );
           if (status != FF_S_SUCCESS) {
              printf("%s\n","Flib_convert_font:  FS_load_typeface()");
              fclose(fout_ptr);
              return( status );
              }
           new_font = 0;
           }
         else
           new_font = 1;
        }
      else
        new_font = 1;

   if( comp_font->outl_hd.block_id[1] == '1' )
       nr_data_wds = comp_font->outl_hd.nr_data_wds;
     else {
       nr_data_wds  = (unsigned int)comp_font->outl_hd.nr_data_wds;
       nr_data_wds += ((unsigned int)comp_font->outl_hd.rec_size) << 16;
       }

   fout_ptr = fopen( (char *)(CX16to8(new_typeface)), "w" );
   if ( fout_ptr == NULL ) {
      printf("%s\n","Flib_convert_font:  fopen(fout_ptr)");
      status = FF_FONT_NOT_OPEN + ERRO;
      return( status );
      }

   font_dat = char_index = Flib_chars;
   char_index++;

   if (new_font)
       beg_outlbuff = (unsigned short *)
                      malloc((font_dat->num_words * 2) * sizeof(unsigned short) );
     else {
       status = FSdecryptBuff( comp_font->outl_dat, nr_data_wds );
       beg_outlbuff = (unsigned short *)
                      malloc( (nr_data_wds * 2)
                           + (font_dat->num_words * 2 * sizeof(unsigned short)) );
       }

   if (beg_outlbuff == NULL) {
       printf("%s\n","Flib_convert_font: malloc(beg_outlbuff)");
       status = FF_MALLOC_ERROR + ERRO;
       goto end_Flib_convert_font;
       }

   if (new_font) {
       comp_font->outl_dat  = end_outlbuff = beg_outlbuff;
       end_outlbuff += font_dat->num_words + 48;
       }
     else {
       memcpy( (char *)beg_outlbuff, (char *)comp_font->outl_dat,
               (nr_data_wds * 2) );
       free( comp_font->outl_dat);
       comp_font->outl_dat = beg_outlbuff;
       beg_outlbuff += nr_data_wds - 1;
       end_outlbuff  = beg_outlbuff;
       end_outlbuff +=   font_dat->num_words + nr_data_wds + 48;
       }
       
   memset((char *)beg_outlbuff, (char)NULL,
          ((font_dat->num_words * 2) * sizeof(unsigned short)) );

   if (    (Flib_fontheader.font_class == 0)
        && (Flib_fontheader.end_char > 127)
        && (new_font))
       count1 = (int)Flib_fontheader.end_char + 1;
     else if (new_font)
       count1 = 127;

   if( (Flib_fontheader.font_class) && (new_font) )
       count1 = Num_flib_chars + 1;
     else if ((count1 < Num_flib_chars + 33)
           && (Flib_fontheader.font_class == 0)
           && (new_font) )
       count1 += (int)Num_flib_chars - count1 + 33;
     else if (!(new_font))
       count1 = (int)comp_font->chdir_hd.nr_recs + (int)Num_flib_chars + 2;

   end_index = char_index;     
   while( end_index->char_id < Flib_fontheader.end_char ) end_index++;

   chdir_ptr = (cft_chardir_rec *) malloc( count1 * sizeof(cft_chardir_rec) );
     	
   if (chdir_ptr == NULL) {
       printf("%s\n","Flib_convert_font: malloc(chdir_dat)");
       status = FF_MALLOC_ERROR + ERRO;
       goto end_Flib_convert_font;
       }

   if (new_font) {
       comp_font->chdir_dat = chdir_ptr;
       memset((char *)chdir_ptr, (char)NULL, (count1 * sizeof(cft_chardir_rec)));

       if (Flib_fontheader.font_class == 0 ) {
           for(count2 = 0; count2 <= 126; count2++, chdir_ptr++ )
              chdir_ptr->char_id   = -1;

           chdir_ptr = comp_font->chdir_dat;
           chdir_ptr += 32;
           chdir_ptr->char_id = 32;
           if (font_dat->set_width > 0)
               chdir_ptr->set_width = font_dat->set_width;
             else
               chdir_ptr->set_width = (short)(((double)Flib_fontheader.tile_hgth * 1.309487724) / 4.0 + 0.5);
           }
         else {
           for(count2 = 0; count2 < count1; count2++, chdir_ptr++ )
              chdir_ptr->set_width = -1;
           }

       chdir_ptr = comp_font->chdir_dat;
       }
     else {
       memcpy( (char *)chdir_ptr, (char *)comp_font->chdir_dat,
               (comp_font->chdir_hd.nr_recs * sizeof(cft_chardir_rec)) );
       free( comp_font->chdir_dat );
       comp_font->chdir_dat = chdir_ptr;
       chdir_ptr += comp_font->chdir_hd.nr_recs;
       memset((char *)chdir_ptr, (char)NULL,
              ((Num_flib_chars + 2) * sizeof(cft_chardir_rec)) ); 
       for(count2 = 0; (count2 < Num_flib_chars + 2); count2++, chdir_ptr++ )
          chdir_ptr->set_width = -1;
       chdir_ptr  = comp_font->chdir_dat;
       chdir_ptr += comp_font->chdir_hd.nr_recs;
       }
       
   end_buff  = beg_outlbuff;
   if (new_font) {
      *end_buff = 0xe300;
      end_buff++;
      }
   
   if (new_font)
       lo_charid = 0;
     else {
       while( (chdir_ptr->char_id == 0)
           && (chdir_ptr != comp_font->chdir_dat) )
          chdir_ptr--;
       
       lo_charid  = (((int)chdir_ptr->char_id + 256) / 256) * 256;
       }

   hidir = NULL;
   for (count1 = 1;
        char_index <= end_index;
        count1++, char_index++ ) {

      if (     (char_index->char_id + lo_charid < 127)
            && (Flib_fontheader.font_class == 0)
            && (char_index->vect_elements)
            && (new_font) ) {
          chdir_ptr  = comp_font->chdir_dat;
          chdir_ptr += (int)char_index->char_id;
          }
        else
          chdir_ptr++;
          
      if (char_index->vect_elements) {
         if (hidir < chdir_ptr) hidir = chdir_ptr;
         
         if (  (    (Flib_fontheader.font_class == 0 )
                 && (char_index->char_id + lo_charid != 32))
             || (Flib_fontheader.font_class) )
            chdir_ptr->set_width = char_index->set_width;

         chdir_ptr->outline_offs = (unsigned int)(end_buff - comp_font->outl_dat);
         chdir_ptr->char_id      =   (unsigned short)char_index->char_id
                                   + lo_charid;
         
         num_words   = 0;
         outl_recptr = char_index->vect_elements;
         
         if (outl_recptr->rec_type == END_CHAR) {
             /*  put min and max x values */
             status = FSput_rec( state, &end_buff, comp_font->outl_dat, 
                                 &outl_recptr, &num_words );
             if (status != FF_S_SUCCESS) {
                printf("\n%s\n","Flib_convert_font: FSput_rec(outl_recptr)");
                FF_report_error( status );
                }

             chdir_ptr->outline_offs = 0;
             goto next_char;
             }
           else if ( (char_index->x_min == 128) && (char_index->x_max == -127)
                  && (char_index->y_min == 128) && (char_index->y_max == -127)) {
             chdir_ptr->outline_offs = 0;
             goto next_char;
             }
           else {
             status = FSput_rec( state, &end_buff, comp_font->outl_dat,
                                 &outl_recptr, &num_words );
              if (status != FF_S_SUCCESS) {
                printf("\n%s\n","Flib_convert_font: FSput_rec(outl_recptr)");
                FF_report_error( status );
                }
 
             status = FSput_rec( state, &end_buff, comp_font->outl_dat,
                                 &outl_recptr, &num_words );
             if (status != FF_S_SUCCESS) {
                printf("\n%s\n","Flib_convert_font: FSput_rec(outl_recptr)");
                FF_report_error( status );
                }
                                      
             status = FSput_rec( state, &end_buff, comp_font->outl_dat,
                                &outl_recptr, &num_words );
             if (status != FF_S_SUCCESS) {
                printf("\n%s\n","Flib_convert_font: FSput_rec(outl_recptr)");
                FF_report_error( status );
                }

             state = 0;
             for( ; outl_recptr->rec_type != END_CHAR; ) {

                status = FSput_rec( state, &end_buff, comp_font->outl_dat,
                                   &outl_recptr, &num_words );
                if (status != FF_S_SUCCESS) {
                   printf("\n%s\n","Flib_convert_font: FSput_rec(outl_recptr)");
                   FF_report_error( status );
                   }                    
                }
             
             status = FSput_rec( state, &end_buff, comp_font->outl_dat,
                                &outl_recptr, &num_words );
             }
         }
next_char: ;
      }

   if (new_font) {
      sprintf(comp_font->fonthead.src_font_id, "%.4hd", Flib_font_num );
      comp_font->fonthead.src_font_vrsn  = 2;
      memset( (char *)(&comp_font->fonthead.src_font_name[0]), (char)NULL, 70 );
      strncat( typeface_desc, " (TM)", 5);
      strcpy(comp_font->fonthead.src_font_name, typeface_desc );
      comp_font->fonthead.layoutNumber = 0;
      date = 0;
      time( &date );
      c_ptr = ctime( &date );
      sprintf( comp_font->fonthead.mfg_date, "%10s", c_ptr );
      memset( (char *)(&comp_font->fonthead.layout_name[0]), (char)NULL, 70 );
      strncpy( comp_font->fonthead.layout_name, layout_name, 33);
      memset( (char *)(&comp_font->fonthead.cpyrt_notice[0]), (char)NULL, 74 );
      strncpy( comp_font->fonthead.cpyrt_notice, cpyrt_notice, 35);
      comp_font->fonthead.timestamp   = (unsigned int)date;
      comp_font->fonthead.resl_per_em =
          (unsigned short)((double)Flib_fontheader.tile_hgth * 1.309487724 + 0.5);
      comp_font->fonthead.flag1 = 0x0606;
      comp_font->fonthead.flag2 = fill_type;
      comp_font->fonthead.extent_x_min  = font_dat->x_min;
      comp_font->fonthead.extent_x_max  = font_dat->x_max;
      comp_font->fonthead.extent_y_min  = font_dat->y_min;
      comp_font->fonthead.extent_y_max  = font_dat->y_max;
      if ( ( Flib_fontheader.font_class == 0 ) && (font_dat->set_width <= 0) )
          comp_font->fonthead.wordspace_width = 
                           (unsigned short)(comp_font->fonthead.resl_per_em / 4);
        else if ( (Flib_fontheader.font_class == 0)
               && (font_dat->set_width > 0) )
          comp_font->fonthead.wordspace_width = (unsigned short)font_dat->set_width;
      }

   while( ( (chdir_ptr->char_id == 0) || ((short) chdir_ptr->char_id == -1) )
       && (chdir_ptr != comp_font->chdir_dat) )
      chdir_ptr--;


   comp_font->fonthead.layout_size = (int)(hidir - comp_font->chdir_dat) + 1;

   sts = fseek(fout_ptr, 0, 0);
   if (sts < 0) {
      printf("%s\n","Flib_convert_font:  fseek(fout_ptr)");
      status = FF_FILE_SEEK_ERROR + ERRO;
      goto end_Flib_convert_font;
      }

   comp_font->fonthead.offs_kernprs  = (unsigned int)0;
   comp_font->fonthead.offs_kerntrks = (unsigned int)0;
   comp_font->fonthead.offsLigTable  = (unsigned int)0;
   comp_font->fonthead.cust_number   = (unsigned short)0;

   status = FS_write_font_header( fout_ptr, &comp_font->finf_hd,
                                 &comp_font->fonthead );
   if (status != FF_S_SUCCESS) {
      printf("%s\n","Flib_convert_font: FS_write_buff(fout_ptr)");
      goto end_Flib_convert_font;
      }

   chardir_offset = (unsigned int)(ftell( fout_ptr ));
   if (chardir_offset <= (sizeof(cft_block_hdr) + (CFT_FHSIZE * 2))) {
      len = (CFT_FHSIZE * 2 + 8 + sizeof(cft_block_hdr)) - chardir_offset;
#ifdef SUNOS 
      for (count3 = 0; count3 < len; count3++)
	  sts = fwrite(&null_char, 1, 1, fout_ptr);
#else
      sts = fwrite(&null_char, 1, len, fout_ptr );
#endif
      if (sts <= 0 ) {
          printf("%s\n","Flib_convert_font: fwrite(NULL)");
          status = FF_FILE_WRITE_ERROR + ERRO;
          goto end_Flib_convert_font;
          }
        else
          chardir_offset = (unsigned int)(ftell( fout_ptr ));
      }

   outlbuff_len                     = (unsigned int)(end_buff - comp_font->outl_dat) + 1;
   comp_font->chdir_hd.block_id[0]  = 'C';
   comp_font->chdir_hd.block_id[1]  = '1';
   comp_font->chdir_hd.nr_recs      = (int)(hidir - comp_font->chdir_dat) + 1;
   if ( outlbuff_len < 65500 )
       comp_font->chdir_hd.rec_size = 3;
     else
       comp_font->chdir_hd.rec_size = 4;
       
   comp_font->chdir_hd.nr_data_wds  =   comp_font->chdir_hd.rec_size
                                      * comp_font->chdir_hd.nr_recs;
   comp_font->fonthead.offs_chardir = chardir_offset / 2;
   status = FS_write_char_dirs( fout_ptr, chardir_offset,
                                &comp_font->fonthead.flag1,
                                &comp_font->chdir_hd,
                                 comp_font->chdir_dat);
   if (status != FF_S_SUCCESS) {
       printf("%s\n","Flib_convert_font: FS_write_buff(fout_ptr)");
       goto end_Flib_convert_font;
       }

   comp_font->outl_hd.block_id[0] = 'O';
   if( outlbuff_len < 65500) {
       comp_font->outl_hd.block_id[1] = '1';
       comp_font->outl_hd.nr_data_wds = outlbuff_len;
       comp_font->outl_hd.rec_size    = 1;
       comp_font->outl_hd.nr_recs     = outlbuff_len;
       }
     else {
       comp_font->outl_hd.block_id[1] = '2';
       comp_font->outl_hd.nr_data_wds = (unsigned short)(outlbuff_len << 16 >> 16);
       comp_font->outl_hd.rec_size    = (unsigned short)(outlbuff_len >> 16);
       comp_font->outl_hd.nr_recs     = 1;
       }

#ifdef SUNOS 
   for (count3 = 0; count3 < 8; count3++)
       sts = fwrite(&null_char, 1, 1, fout_ptr);
#else
   sts = fwrite(&null_char, 1, 8, fout_ptr );
#endif
   if (sts <= 0 ) {
       printf("%s\n","Flib_convert_font: fwrite(NULL)");
       status = FF_FILE_WRITE_ERROR + ERRO;
       goto end_Flib_convert_font;
       }

   outldata_offset                   = (unsigned int)(ftell(fout_ptr));
   comp_font->fonthead.offs_outldata = outldata_offset / 2;
   status = FSencryptBuff( comp_font->outl_dat, outlbuff_len );

   status = FS_write_outl_data( fout_ptr, outldata_offset,
                               &comp_font->outl_hd, comp_font->outl_dat,
                               (outlbuff_len * 2 + 18 ));
   if (status != FF_S_SUCCESS) {
       printf("%s\n","Flib_convert_font: FS_write_buff(outl_hd)");
       goto end_Flib_convert_font;
       }
       
   fflush( fout_ptr );
#ifndef SUNOS 
   while(system("sync") < 0);
#endif
   fclose( fout_ptr );

   fout_ptr = fopen( (char *)(CX16to8(new_typeface)), "r+" );
   if ( fout_ptr == NULL ) {
      printf("%s\n","Flib_convert_font:  fopen(fout_ptr)");
      status = FF_FONT_NOT_OPEN + ERRO;
      return( status );
      }

   status = FS_write_font_header( fout_ptr, &comp_font->finf_hd,
                                 &comp_font->fonthead );
   if (status != FF_S_SUCCESS)
      printf("%s\n","Flib_convert_font: FS_write_buff(fout_ptr)");

end_Flib_convert_font:

   if (status != FF_S_SUCCESS) {
      FF_report_error( status );
      if( fout_ptr ) {
         fclose( fout_ptr );
         unlink( CX16to8(new_typeface) );
         fout_ptr = NULL;
         }
      }

   if( comp_font->chdir_dat ) {
      free( comp_font->chdir_dat );
      comp_font->chdir_dat = NULL;
      }
      
   if( comp_font->outl_dat ) {
      free( comp_font->outl_dat );
      comp_font->outl_dat = NULL;
      beg_outlbuff       = NULL;
      }

   if( comp_font ) free( comp_font );

   if( (status == FF_S_SUCCESS) && (fout_ptr) ) {
      fflush( fout_ptr );
#ifndef SUNOS 
      while(system("sync") < 0);
#endif
      }

   if ( fout_ptr )
      fclose( fout_ptr );

   return( status );

}
