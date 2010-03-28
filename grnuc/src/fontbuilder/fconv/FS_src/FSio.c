/************************** F F _ C O M P _ I O . C ***************************
 ********************** R E V I S I O N   H I S T O R Y ***********************

  (1)  22-SEPT-87  Stan Williams

******************************************************************************/

/*
$Log: FSio.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:24  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:38  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:39  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:04  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:29  root
 * COMMENT : Corresponds to Rel201.6 in 2.0.1 RCS
 *
 * Revision 201.6  1992/07/13  20:41:59  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include "exsysdep.h"
#include <string.h>
#include <memory.h>
#include <math.h>
#include <tools.h>
#include <itools.h>
#include "FSTypeface.h"
#include "FSBmap.h"
#include "FFdef.h"
#include "FFerrdef.h"
#include "FFstructs.h"


FS_load_typeface( typeface_name, comp_font )

	Typepath           typeface_name;
        FF_outl_str       *comp_font;

{
                 FILE  *f_ptr, *fopen();
                 int    status; 
                 int    num_trks;
                 char  *CX16to8();
                 void   FSsortKernTbl();

   status = FF_S_SUCCESS;
   f_ptr = NULL;
   f_ptr = fopen( CX16to8(typeface_name), "r" );
   if ( f_ptr == NULL ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto end_FS_load_typeface;
      }

   if( comp_font->knpr_dat )
      free( comp_font->knpr_dat );
   comp_font->knpr_dat = NULL;

   if( comp_font->kntrk_dat )
      free( comp_font->kntrk_dat );
   comp_font->kntrk_dat = NULL;

   if( comp_font->chdir_dat )
      free( comp_font->chdir_dat );
   comp_font->chdir_dat = NULL;

   if( comp_font->outl_dat )
      free( comp_font->outl_dat );
   comp_font->chdir_dat = NULL;

   status = FS_read_font_header( f_ptr, &comp_font->finf_hd,
                                &comp_font->fonthead);
   if (status != FF_S_SUCCESS)
      goto end_FS_load_typeface;

   if (comp_font->fonthead.offs_kernprs >= comp_font->finf_hd.nr_data_wds) {
       status = FS_read_kern_prs( f_ptr,(comp_font->fonthead.offs_kernprs * 2),
                                 &comp_font->knpr_hd, &comp_font->knpr_dat);
       if (status != FF_S_SUCCESS)
           goto end_FS_load_typeface;
         else if( comp_font->knpr_hd.nr_recs > 0 )
           FSsortKernTbl( comp_font->knpr_dat, comp_font->knpr_hd.nr_recs );
       }

   if ( comp_font->fonthead.offs_kerntrks >= comp_font->finf_hd.nr_data_wds ) {
       status = FS_read_kern_trks( f_ptr,
                                   (comp_font->fonthead.offs_kerntrks * 2),
                                   &comp_font->kntrk_hd,
                                   &comp_font->kntrk_dat );
       if (status != FF_S_SUCCESS)
           goto end_FS_load_typeface;
         else if( comp_font->kntrk_hd.nr_recs > 0 )
           num_trks = (int)comp_font->kntrk_hd.rec_size - 1;
         else
           num_trks = 0;
       }

   status = FS_read_char_dirs( f_ptr,(comp_font->fonthead.offs_chardir * 2),
                              &comp_font->fonthead.layout_size,
                               comp_font->fonthead.flag1,
                              &comp_font->chdir_hd,
                              &comp_font->chdir_dat );
   if (status != FF_S_SUCCESS)
       goto end_FS_load_typeface;

   status = FS_read_outl_data(f_ptr,(comp_font->fonthead.offs_outldata * 2),
                                    &comp_font->outl_hd,
                                    &comp_font->outl_dat,
                                    &comp_font->num_bytes_outl );

end_FS_load_typeface :

   if ( status != FF_S_SUCCESS ) {
      if(comp_font->knpr_dat)
         free( comp_font->knpr_dat );
      comp_font->knpr_dat = NULL;
      if(comp_font->kntrk_dat)
         free( comp_font->kntrk_dat );
      comp_font->kntrk_dat = NULL;
      if(comp_font->chdir_dat)
         free( comp_font->chdir_dat );
      comp_font->chdir_dat = NULL;
      }

   if( f_ptr ) fclose( f_ptr );

   return ( status );

}





FS_get_name( typeface_file, typeface_name )

	Typepath   typeface_file;
	short     *typeface_name;

{
        int       status, sts, len, offset;
        char     *c1_ptr, *c2_ptr, linebuff[128], *CX16to8();
        short    *CX8to16();
        FILE     *f_ptr, *fopen();
        
        char *strfind();

   status = FF_S_SUCCESS;
   f_ptr  = NULL;

   f_ptr = fopen( CX16to8(typeface_file), "r" );
   if ( f_ptr == NULL ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto end_FS_get_name;
      }
   
   offset = sizeof(cft_block_hdr) + 14;
   sts = fseek(f_ptr, offset, 0 );
   if (sts < 0) {
      status = FF_FILE_SEEK_ERROR + ERRO;
      goto end_FS_get_name;
      }

   sts = fread( (char *)(&linebuff[0]), 70, 1, f_ptr );
   if (sts <= 0) {
      status = FF_FILE_READ_ERROR + ERRO;
      goto end_FS_get_name;
      }

   linebuff[69] = '\0';
   c1_ptr  = &linebuff[0];
   c2_ptr  = strfind( linebuff, "(TM)");
   if( c2_ptr ) {
       c2_ptr--;
       while( *c2_ptr == ' ' ) c2_ptr--;
       c2_ptr++;
       len = (int)(c2_ptr - c1_ptr);
       strncpy16( typeface_name, CX8to16(linebuff), len );
       typeface_name[len] = 0;
       }

end_FS_get_name:

   if( f_ptr ) fclose( f_ptr );
   
   return ( status );
}





FS_get_names( typefaces, num_typefaces, typeface_names, typeface_path )

        GGitem_list   *typefaces;
        int            num_typefaces;
        GGitem_list  **typeface_names;
        Typepath       typeface_path;
{
        int           status, count;
        short        *CX8to16();
        GGitem_list  *typeface_file_ptr, *typeface_name_ptr;
        Typepath      sval1;
        
   status = FF_S_SUCCESS;

   typeface_name_ptr = (GGitem_list *)malloc(num_typefaces * sizeof(GGitem_list));
   if (typeface_name_ptr == NULL) {
       status = FF_MALLOC_ERROR + ERRO;
       goto end_FS_get_names;
       }

   *typeface_names = typeface_name_ptr;
   memset((char *)typeface_name_ptr,(char)NULL,(num_typefaces * sizeof(GGitem_list)));

   typeface_file_ptr = typefaces;
   for (count = 0;
        count < num_typefaces;
        count++, typeface_name_ptr++, typeface_file_ptr++ ) {
      strcpy16( sval1, typeface_path );
      strcat16( sval1, CX8to16("/") );
      strcat16( sval1, typeface_file_ptr );
      FS_get_name( sval1, (short *)(&typeface_name_ptr->item[0]) );
      }
      
end_FS_get_names:

   return ( status );

}




FSgetCharDirs( typeface_name, chdir_buff, num_chdirs, end_index, orus_em )

	Typepath           typeface_name;
	cft_chardir_rec  **chdir_buff;
	IGRushort    *num_chdirs;
        IGRushort    *end_index;
        IGRushort    *orus_em;
{
        IGRuint    status;
     /*
	         int	count1, count2;
      */
                 char  /**cbuff,*/ *CX16to8();
                 FILE  *f_ptr, *fopen();

               cft_chardir_rec /**chdir_ptr1,*/ *chdir_ptr2, *hi_dir,
                               *chdir_dat;
               cft_block_hdr    finf_hd, chdir_hd;
               cft_font_hdr     fonthead;

   status = FF_S_SUCCESS;

   chdir_dat    = NULL;
   *num_chdirs  = 0;
   *chdir_buff  = NULL;
   f_ptr        = NULL;

   f_ptr = fopen( CX16to8(typeface_name), "r" );
   if (! f_ptr ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto endgetCharDirs;
      }

   status = FS_read_font_header( f_ptr, &finf_hd, &fonthead );
   if (status != FF_S_SUCCESS)
      goto endgetCharDirs;

   if( orus_em )
      *orus_em  = fonthead.resl_per_em;

   status = FS_read_char_dirs( f_ptr, (fonthead.offs_chardir * 2),
                               &fonthead.layout_size, fonthead.flag1,
                               &chdir_hd, &chdir_dat );
   if (status != FF_S_SUCCESS)
       goto endgetCharDirs;

   chdir_ptr2 = chdir_dat;
   hi_dir     = chdir_dat + ((int)fonthead.layout_size - 1);
   while(  ( (hi_dir->char_id   == 0)
          || (hi_dir->char_id   == -1)
          || (hi_dir->set_width <= 0) )
       && (hi_dir > chdir_dat) )
     hi_dir--;

   *num_chdirs = chdir_hd.nr_recs;
   *end_index = (IGRushort)(hi_dir - chdir_dat);
   *chdir_buff = chdir_dat;

endgetCharDirs:

   if (status != FF_S_SUCCESS) {
       if( *chdir_buff )
          free( *chdir_buff );
       *chdir_buff = NULL;
       *num_chdirs = (IGRushort)0;
       }

   if( f_ptr ) fclose( f_ptr );

   return ( status );
   
}




FSputCharDirWidths( typeface_name, chdir_buff, num_chdirs, end_index )

	Typepath           typeface_name;
	cft_chardir_rec   *chdir_buff;
	IGRushort    *num_chdirs;
        IGRushort     end_index;
{
        IGRuint    status;
	         int	count1, count2;
                 char  /**cbuff,*/ *CX16to8();
                 FILE  *f_ptr, *fopen();

               cft_chardir_rec *chdir_dat, *chdir_ptr1, *chdir_ptr2,
                               *hi_dir1, *hi_dir2;
               cft_block_hdr    finf_hd, chdir_hd;
               cft_font_hdr     fonthead;

   status = FF_S_SUCCESS;
   f_ptr = NULL;

   f_ptr = fopen( CX16to8(typeface_name), "r+" );
   if (! f_ptr ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto end_put_chardir_widths;
      }

   status = FS_read_font_header( f_ptr, &finf_hd, &fonthead );
   if (status != FF_S_SUCCESS)
      goto end_put_chardir_widths;

   status = FS_read_char_dirs( f_ptr, (fonthead.offs_chardir * 2),
                               &fonthead.layout_size, fonthead.flag1,
                               &chdir_hd, &chdir_dat);
   if (status != FF_S_SUCCESS)
       goto end_put_chardir_widths;

   hi_dir1 = chdir_dat  + ((int)fonthead.layout_size - 1);
   hi_dir2 = chdir_buff + ((int)end_index - 1);
   chdir_ptr1 = chdir_dat;
   chdir_ptr2 = chdir_buff;

   for ( count1 = count2 = 0;
         chdir_ptr2 <= hi_dir2;
         count1++, chdir_ptr2++) {

       while( ( (chdir_ptr2->char_id > chdir_ptr1->char_id)
             && (chdir_ptr1 < hi_dir1) )
           || ( (chdir_ptr1->char_id == -1) && (chdir_ptr1 < hi_dir1) ) )
          chdir_ptr1++;

       while( ( (chdir_ptr2->char_id < chdir_ptr1->char_id)
             && (chdir_ptr1 >= chdir_dat) )
           || ( (chdir_ptr1->char_id == -1) && (chdir_ptr1 >= chdir_dat) ) )
          chdir_ptr1--;

       if (  (chdir_ptr2->char_id > 0)
          && (chdir_ptr2->char_id != -1)
          && (chdir_ptr2->set_width > 0)
          && (chdir_ptr2->set_width != chdir_ptr1->set_width )
          && (chdir_ptr2->char_id == chdir_ptr1->char_id ) ) {
           chdir_ptr1->set_width = chdir_ptr2->set_width;
           count2++;
           }
       }

   if (count2 > 0) {
       status = FS_write_char_dirs( f_ptr, (fonthead.offs_chardir * 2),
                                   &fonthead.flag1, &chdir_hd, chdir_dat );
       if (status != FF_S_SUCCESS) {
           *num_chdirs = (IGRushort)0;
           goto end_put_chardir_widths;
           }

       fflush( f_ptr );
       *num_chdirs = (IGRushort)count2;
       }
     else
       *num_chdirs = (IGRushort)0;

end_put_chardir_widths:

   if( chdir_dat )
      free( chdir_dat );

   if( f_ptr ) fclose( f_ptr );

   return ( status );
}




FSgetKernPairs( typeface_name, knpr_dat, num_pairs, oru_em )

	Typepath            typeface_name;
	cft_kern_pair_rec **knpr_dat;
	IGRushort     *num_pairs;
        IGRushort        *oru_em;

{
               int             status;
               char           *CX16to8();
               cft_block_hdr   finf_hd, knpr_hd;
               cft_font_hdr    fonthead;
               void            FSsortKernTbl();
               FILE           *f_ptr, *fopen();

   status = FF_S_SUCCESS;

   *knpr_dat  = NULL;
   *num_pairs = 0;
   f_ptr      = NULL;

   f_ptr = fopen( CX16to8(typeface_name), "r" );
   if (! f_ptr ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto end_getKernPairs;
      }

   if( (! num_pairs) || (! knpr_dat) ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto end_getKernPairs;
      }

   status = FS_read_font_header(f_ptr, &finf_hd, &fonthead);
   if (status != FF_S_SUCCESS)
       goto end_getKernPairs;

   if( oru_em )
      *oru_em = fonthead.resl_per_em;

   if ( fonthead.offs_kernprs >= finf_hd.nr_data_wds ) {
       status = FS_read_kern_prs( f_ptr, (fonthead.offs_kernprs * 2),
                                  &knpr_hd, knpr_dat );
       if( (status != FF_S_SUCCESS) || (knpr_hd.nr_recs == 0) )
           goto end_getKernPairs;

       *num_pairs = knpr_hd.nr_recs;
       FSsortKernTbl( (*knpr_dat), knpr_hd.nr_recs );
       }
     else
       status = FF_KERNTBL_NOT_FOUND + WARN;
       
end_getKernPairs:

   if (status != FF_S_SUCCESS) {
      if( *knpr_dat ) free( *knpr_dat );
      *knpr_dat  = NULL;
      *num_pairs = 0;
      }

   if( f_ptr )
      fclose( f_ptr );

   return ( status );

}




FSputKernPairs( typeface_name, knpr_dat1, num_pairs, merge )

	Typepath            typeface_name;
	cft_kern_pair_rec  *knpr_dat1;
	IGRushort      num_pairs;
        int                 merge; /* 1 = yes   0 = no */
{
                 int    status, sts,
                        num_trks, type_chg,
                        offs_kernprs, offs_kerntrks, offs_chardirs,
                        offs_outldata, bufflen, offs,
                        num_bytes_outl;
        static   int    padint = NULL;
        IGRushort  num_changes, total_pairs, num_matches;
                 char   tmp_name[128], *CX16to8();
        IGRuchar  *charbuff;
                 FILE  *f_ptr, *ftmp_ptr, *fopen();
                 cft_kern_pair_rec *knpr_dat2, *knpr_dat3, *knpr_ptr;

                 cft_block_hdr      finf_hd, knpr_hd, knpr_hd2,
                                    kntrk_hd, chdir_hd, outl_hd;
                 cft_font_hdr       fonthead;
                 cft_trk_kern_rec  *kntrk_dat;
                 cft_chardir_rec   *chdir_dat;
                 IGRushort    *outl_dat;
                 void               FSmergeKerns(),
                                    FScompairChangeKerns(),
                                    FSsortKernTbl();

   status = FF_S_SUCCESS;

   total_pairs = num_pairs;
   kntrk_dat   = NULL;
   knpr_dat2   = NULL;
   knpr_dat3   = NULL;
   chdir_dat   = NULL;
   outl_dat    = NULL;
   charbuff    = NULL;
   f_ptr = ftmp_ptr = NULL;
   num_changes = 0;   /***************** type_chg **********************/
   type_chg    = 0;   /* 0 = changes to existing kern pairs only       */
                      /* 1 = new kern pairs (none previously existed)  */
                      /* 2 = merge two non matching sets of kern pairs */
                      /*************************************************/

   if( (num_pairs > 0) && (knpr_dat1) ) {
       offs_kerntrks = 0;
       offs_chardirs = 0;
       offs_outldata = 0;
       f_ptr = fopen( CX16to8(typeface_name), "r" );
       if (! f_ptr ) {
          status = FF_FONT_NOT_OPEN + ERRO;
          goto end_putKernPairs;
          }

       tmpnam(tmp_name);
       ftmp_ptr = fopen(tmp_name, "w+");
       if(! ftmp_ptr ) {
          status = FF_FONT_NOT_OPEN + ERRO;
          goto end_putKernPairs;
          }

       status = FS_read_font_header( f_ptr, &finf_hd, &fonthead );
       if (status != FF_S_SUCCESS)
          goto end_putKernPairs;

       offs = fonthead.offs_kernprs * 2;
       fonthead.offsLigTable = 0;
       status = FS_write_font_header( ftmp_ptr, &finf_hd, &fonthead );
       if ( status != FF_S_SUCCESS )
          goto end_putKernPairs;

       sts = fwrite( (char *)(&padint), sizeof(int), 1, ftmp_ptr );
       if (sts <= 0) {
           status = FF_FILE_WRITE_ERROR + ERRO;
           goto end_putKernPairs;
           } 

       fseek(ftmp_ptr, 0, 2);
       offs_kernprs = ftell( ftmp_ptr );
       status = FS_read_kern_prs( f_ptr, offs, &knpr_hd2, &knpr_dat2);
       if ( (status == FF_S_SUCCESS) && (merge) && (knpr_hd2.nr_recs > 0) ) {
           /* count the number of kern pair matches first */
           FSsortKernTbl( knpr_dat2, knpr_hd2.nr_recs );
           knpr_ptr = knpr_dat1;
           FScompairChangeKerns(knpr_ptr, num_pairs, 
                                knpr_dat2, (int)knpr_hd2.nr_recs,
                                &num_matches, 0 );

           if (num_matches == knpr_hd2.nr_recs) {
               FScompairChangeKerns(knpr_ptr, num_pairs, 
                                    knpr_dat2, (int)knpr_hd2.nr_recs,
                                    &num_changes, 1 );
               total_pairs = num_pairs;
               type_chg    = 0;
               }
             else {
               if( num_pairs >= num_matches )
                   total_pairs = num_pairs;
                 else
                   total_pairs = num_pairs + knpr_hd2.nr_recs - num_matches;

               knpr_dat3   = (cft_kern_pair_rec *)
                             malloc((int)total_pairs * sizeof(cft_kern_pair_rec) );
               if(! knpr_dat3 ) {
                  status = FF_MALLOC_ERROR + ERRO;
                  goto end_putKernPairs;
                  }

               FSmergeKerns( knpr_dat1, num_pairs, knpr_dat2,
                             knpr_hd2.nr_recs, knpr_dat3, total_pairs,
                             &num_changes );
               free( knpr_dat2 );
               knpr_dat2 = knpr_dat3;
               type_chg  = 2;
               }
           } /* end else if */
         else if( ! merge ) {
           if( status != FF_S_SUCCESS ) {
               num_changes = total_pairs = num_pairs;
               type_chg = 1; /******************** type_chg ******************/
               }             /* 0 = changes to existing kern pairs only      */
             else {          /* 1 = new kern pairs (none previously existed) */
               type_chg = 3; /* 2 = merge two non matching sets of kern pairs*/
                             /* 3 = replace existing kern pairs              */
                             /************************************************/
               num_changes = total_pairs = num_pairs;
               if( knpr_dat2 ) free( knpr_dat2 );
               knpr_dat2   = knpr_dat1;
               }
           }

       if ( (num_changes == 0) && ((type_chg == 0) || (type_chg == 2)) )
           goto end_putKernPairs;

       fonthead.offs_kernprs = (IGRuint)(offs_kernprs / 2);

       knpr_hd.block_id[0] = 'K';
       knpr_hd.block_id[1] = '1';
       knpr_hd.nr_recs     = total_pairs;
       knpr_hd.rec_size    = 3;
       knpr_hd.nr_data_wds = 3 * total_pairs;
       status = FS_write_kern_prs( ftmp_ptr, offs_kernprs, &knpr_hd, knpr_dat2 );
       if (status != FF_S_SUCCESS)
           goto end_putKernPairs;

       sts = fwrite( (char *)(&padint), sizeof(int), 1, ftmp_ptr );
       if (sts <= 0) {
          status = FF_FILE_WRITE_ERROR + ERRO;
          goto end_putKernPairs;
          } 

       fseek(ftmp_ptr, 0, 2);
       if( fonthead.offs_kerntrks >= finf_hd.nr_data_wds  ) {
           offs_kerntrks = ftell( ftmp_ptr );
           status = FS_read_kern_trks( f_ptr, (fonthead.offs_kerntrks * 2),
                                       &kntrk_hd, &kntrk_dat );
           if (status != FF_S_SUCCESS)
               goto end_putKernPairs;

           num_trks = (int)kntrk_hd.rec_size - 1;
           fonthead.offs_kerntrks = (IGRuint)(offs_kerntrks / 2);

           status = FS_write_kern_trks( ftmp_ptr, offs_kerntrks,
                                        &kntrk_hd, kntrk_dat);
           if (status != FF_S_SUCCESS)
               goto end_putKernPairs;

           sts = fwrite( (char *)(&padint), sizeof(int), 1, ftmp_ptr );
           if (sts <= 0) {
               status = FF_FILE_WRITE_ERROR + ERRO;
               goto end_putKernPairs;
               } 

           fseek(ftmp_ptr, 0, 2);
           }

       offs_chardirs = ftell( ftmp_ptr );
       status = FS_read_char_dirs( f_ptr,(fonthead.offs_chardir * 2),
                                   &fonthead.layout_size, fonthead.flag1,
                                   &chdir_hd, &chdir_dat );
       if (status != FF_S_SUCCESS)
           goto end_putKernPairs;

       fonthead.offs_chardir = (IGRuint)(offs_chardirs / 2);

       status = FS_write_char_dirs( ftmp_ptr, offs_chardirs,
                                    &fonthead.flag1, &chdir_hd, chdir_dat);
       if (status != FF_S_SUCCESS)
           goto end_putKernPairs;

       sts = fwrite( (char *)(&padint), sizeof(int), 1, ftmp_ptr );
       if (sts <= 0) {
           status = FF_FILE_WRITE_ERROR + ERRO;
           goto end_putKernPairs;
           } 

       fseek(ftmp_ptr, 0, 2);
       offs_outldata = ftell( ftmp_ptr );
       status = FS_read_outl_data( f_ptr, (fonthead.offs_outldata * 2),
                                   &outl_hd, &outl_dat, &num_bytes_outl );
       if (status != FF_S_SUCCESS)
           goto end_putKernPairs;

       fonthead.offs_outldata = (IGRuint)(offs_outldata / 2);

       status = FS_write_outl_data( ftmp_ptr, offs_outldata,
                                   &outl_hd, outl_dat, num_bytes_outl );
       if (status != FF_S_SUCCESS)
           goto end_putKernPairs;

       status = FS_write_font_header( ftmp_ptr, &finf_hd, &fonthead);
       if ( status != FF_S_SUCCESS )
          goto end_putKernPairs;

       fflush( ftmp_ptr );
       while(system("sync") < 0);
       fseek(ftmp_ptr, 0, 2);
       bufflen = ftell( ftmp_ptr );
       sts = fseek(ftmp_ptr, 0, 0);

       charbuff = (IGRuchar *)malloc(bufflen * sizeof(char));
       if(! charbuff ) {
           status = FF_MALLOC_ERROR + ERRO;
           goto end_putKernPairs;
           }

       sts = fread( charbuff, bufflen, 1, ftmp_ptr);
       if (sts <= 0) {
           status = FF_FILE_READ_ERROR + ERRO;
           goto end_putKernPairs;
           }

       if( f_ptr ) {
          fclose( f_ptr );
          f_ptr = NULL;
          }

       unlink( CX16to8(typeface_name) );
       f_ptr = fopen( CX16to8(typeface_name), "w" );
       if(! f_ptr ) {
           status = FF_FILE_NOT_OPEN + ERRO;
           goto end_putKernPairs;
           }

       sts = fwrite( charbuff, bufflen, 1, f_ptr);
       if (sts <= 0) {
           status = FF_FILE_WRITE_ERROR + ERRO;
           goto end_putKernPairs;
           }

       fflush( f_ptr );
       }
     else
       status = FF_KERNTBL_NOT_FOUND + WARN;
       
end_putKernPairs:

   if ( ftmp_ptr ) {
      fclose( ftmp_ptr );
      unlink( tmp_name );
      }

   if( f_ptr ) {
      fflush( f_ptr );
      fclose( f_ptr );
      while(system("sync") < 0);
      }

   if( type_chg != 3 )
      if( knpr_dat2 ) free( knpr_dat2 );

   if( charbuff  ) free( charbuff  );
   if( kntrk_dat ) free( kntrk_dat );
   if( chdir_dat ) free( chdir_dat );
   if( outl_dat  ) free( outl_dat  );

   return ( status );

}




void FSmergeKerns( knpr_dat1, num_pairs1, knpr_dat2, num_pairs2,
                   knpr_dat3, num_pairs3, num_changes )

	cft_kern_pair_rec *knpr_dat1;
        IGRushort     num_pairs1;
	cft_kern_pair_rec *knpr_dat2;
        IGRushort     num_pairs2;
	cft_kern_pair_rec *knpr_dat3;
        IGRushort     num_pairs3;
        IGRushort    *num_changes;

{
                 IGRushort     count1, bufflen;
                 cft_kern_pair_rec *knpr_ptr1, *knpr_ptr2, *knpr_ptr3,
                                   *endpr1,    *endpr2,    *endpr3,
                                   *endpr, *addpr;
                 void               FSsortKernTbl(),
                                    FS_match_pair();

   *num_changes = 0;
   endpr1       = knpr_dat1;
   endpr1      += (int)num_pairs1 - 1;
   endpr2       = knpr_dat2;
   endpr2      += (int)num_pairs2 - 1;
   endpr3       = knpr_dat3;
   endpr3      += (int)num_pairs3 - 1;
   knpr_ptr2    = knpr_dat2;
   knpr_ptr3    = knpr_dat3;
   for( count1 = 0;
        (count1 <  num_pairs2) && (knpr_ptr2 <= endpr2);
         count1++, knpr_ptr2++, knpr_ptr3++ ) {
      knpr_ptr3->char1      = knpr_ptr2->char1;
      knpr_ptr3->char2      = knpr_ptr2->char2;
      knpr_ptr3->adjustment = knpr_ptr2->adjustment;
      }

   endpr       = knpr_ptr3 - 1;
   addpr       = knpr_ptr3;
   knpr_ptr1    = knpr_dat1;
   for( ; knpr_ptr1 <= endpr1; knpr_ptr1++ ) {
       FS_match_pair( knpr_ptr1, knpr_dat3, &knpr_ptr3, endpr );

       if (      (knpr_ptr3)
              && (knpr_ptr1->char1 == knpr_ptr3->char1)
              && (knpr_ptr1->char2 == knpr_ptr3->char2)
              && (knpr_ptr1->adjustment != knpr_ptr2->adjustment) ) {
            *num_changes += 1;
            knpr_ptr3->adjustment = knpr_ptr1->adjustment;
            }
         else if (   (! knpr_ptr3)
                && (!((knpr_ptr1->char1 == knpr_ptr3->char1)
                   || (knpr_ptr1->char2 == knpr_ptr3->char2))) ) {
            addpr->char1      = knpr_ptr1->char1;
            addpr->char2      = knpr_ptr1->char2;
            addpr->adjustment = knpr_ptr1->adjustment;
            *num_changes += 1;
            addpr++;
            }
       } /* end for */

   bufflen = (IGRushort)(addpr - knpr_dat3);
   FSsortKernTbl( knpr_dat3, bufflen );
}




void FScompairChangeKerns( knpr_dat1, num_pairs1, 
                         knpr_dat2, num_pairs2,
                         num_match_change, comp_chg_flag )

	cft_kern_pair_rec *knpr_dat1;
        IGRushort     num_pairs1;
	cft_kern_pair_rec *knpr_dat2;
        IGRushort     num_pairs2;
        IGRushort    *num_match_change;
        int               *comp_chg_flag;

{
                 IGRushort     count1/*, count2*/;
                 cft_kern_pair_rec *knpr_ptr1, *knpr_ptr2,
                                   *endpr1,    *endpr2;
                 void               FS_match_pair();

   endpr1    = knpr_ptr1 = knpr_dat1;
   endpr1   += (int)num_pairs1 - 1;
   endpr2    = knpr_ptr2 = knpr_dat2;
   endpr2   += (int)num_pairs2 - 1;

   count1 = 0;
   *num_match_change = 0;
   for( ; knpr_ptr1 <= endpr1; knpr_ptr1++ ) {
       FS_match_pair( knpr_ptr1, knpr_dat2, &knpr_ptr2, endpr2 );

       if (      (knpr_ptr2)
              && (knpr_ptr1->char1 == knpr_ptr2->char1)
              && (knpr_ptr1->char2 == knpr_ptr2->char2)
              && ( ! comp_chg_flag) )
            *num_match_change += 1;
          else if ( (knpr_ptr2)
                 && (knpr_ptr1->char1      == knpr_ptr2->char1)
                 && (knpr_ptr1->char2      == knpr_ptr2->char2)
                 && (knpr_ptr1->adjustment != knpr_ptr2->adjustment) ) {
            *num_match_change    += 1;
            knpr_ptr2->adjustment = knpr_ptr1->adjustment;
            count1++;
            }
          else if( knpr_ptr2 )
            count1++;
          else if(! knpr_ptr2 )
            *num_match_change += 1;

       } /* end for */

   if( (count1 < num_pairs2 ) && (comp_chg_flag) )
      *num_match_change += num_pairs2 - count1;
}




void FS_match_pair( knpr_ptr1, knpr_dat2, knpr_ptr2, endpr2 )

	cft_kern_pair_rec  *knpr_ptr1, *knpr_dat2,
                          **knpr_ptr2, *endpr2;

{
	cft_kern_pair_rec  *knpr_ptr;

   knpr_ptr = knpr_dat2;

   if ( knpr_ptr1->char1 > knpr_ptr->char1 ) {
       while( (knpr_ptr1->char1 > knpr_ptr->char1)
            && (knpr_ptr != endpr2) )
          knpr_ptr++;
       }
     else if( knpr_ptr1->char1 < (int)knpr_ptr->char1 ) {
       while(  (knpr_ptr1->char1 < knpr_ptr->char1)
            && (knpr_ptr != knpr_dat2) )
          knpr_ptr--;
       }

   while(  (knpr_ptr1->char1 == knpr_ptr->char1)
        && (knpr_ptr->char2 < knpr_ptr1->char2)
        && (knpr_ptr != endpr2) )
      knpr_ptr++;

   while(  (knpr_ptr1->char1 == knpr_ptr->char1)
        && (knpr_ptr->char2 > knpr_ptr1->char2)
        && (knpr_ptr != knpr_dat2) )
      knpr_ptr--;

   if(      (knpr_ptr1->char1 == knpr_ptr->char1)
         && (knpr_ptr1->char2 == knpr_ptr->char2) )
       *knpr_ptr2 = knpr_ptr;
     else
       *knpr_ptr2 = NULL;
}




FSgetKernTracks( typeface_name, kntrk_dat, num_recs, num_tracks, oru_em )

        Typepath           typeface_name;
        cft_trk_kern_rec **kntrk_dat;
        IGRushort     *num_recs, *num_tracks;
        IGRushort     *oru_em;

{
               int            status;
               char          *CX16to8();
               cft_block_hdr  finf_hd, kntrk_hd;
               cft_font_hdr   fonthead;
               FILE          *f_ptr, *fopen();

   status = FF_S_SUCCESS;
   *num_tracks = 0;
   *kntrk_dat  = 0;
   f_ptr       = NULL;

   f_ptr = fopen( CX16to8(typeface_name), "r" );
   if (! f_ptr ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto end_getKernTracks;
      }

   status = FS_read_font_header( f_ptr, &finf_hd, &fonthead );
   if (status != FF_S_SUCCESS)
       goto end_getKernTracks;

   if( oru_em )
      *oru_em = fonthead.resl_per_em;

   if (fonthead.offs_kerntrks >= finf_hd.nr_data_wds) {
       *kntrk_dat = NULL;
       status = FS_read_kern_trks(f_ptr,(fonthead.offs_kerntrks * 2),
                                 &kntrk_hd, kntrk_dat );
       if( (status != FF_S_SUCCESS) || (kntrk_hd.nr_recs == 0) )
           goto end_getKernTracks;

       *num_tracks = (int)kntrk_hd.rec_size - 1;
       *num_recs   = (int)kntrk_hd.nr_recs;
       }
     else
       status = FF_TRACKTBL_NOT_FOUND + WARN;

end_getKernTracks:

   if(!((status == FF_S_SUCCESS) || (status == FF_TRACKTBL_NOT_FOUND + WARN))){
       *num_tracks = 0;
       if( *kntrk_dat ) free( *kntrk_dat );
       *kntrk_dat  = NULL;
       }

   if( f_ptr ) fclose( f_ptr );

   return ( status );

}




FSputKernTracks( typeface_name, kntrk_dat, num_recs, num_tracks )

        Typepath           typeface_name;
        cft_trk_kern_rec  *kntrk_dat;
        IGRushort     num_recs, num_tracks;

{
                 FILE  *f_ptr, *ftmp_ptr, *fopen();
                 int    status, sts, offs_kernprs,
                        offs_kerntrks, offs_chardirs, offs_outldata, bufflen,
                        num_bytes_outl;
        static   int    padint = NULL;
                 char   tmp_name[128], *CX16to8();
                 char *charbuff;

                 cft_block_hdr      finf_hd, knpr_hd,
                                    kntrk_hd, chdir_hd, outl_hd;
                 cft_font_hdr       fonthead;
                 cft_kern_pair_rec *knpr_dat;
                 /*cft_trk_kern_rec  *kntrk_ptr;*/
                 cft_chardir_rec   *chdir_dat;
                 IGRushort    *outl_dat;

   status = FF_S_SUCCESS;

   f_ptr = ftmp_ptr = NULL;
   f_ptr      = NULL;
   charbuff   = NULL;
   knpr_dat   = NULL;
   chdir_dat  = NULL;
   outl_dat   = NULL;

   if( ( num_recs > 0 ) && (kntrk_dat) ){
       offs_kernprs  = 0;
       offs_kerntrks = 0;
       offs_chardirs = 0;
       offs_outldata = 0;

       f_ptr = fopen( CX16to8(typeface_name), "r" );
       if (! f_ptr ) {
          status = FF_FONT_NOT_OPEN + ERRO;
          goto end_putKernTracks;
          }

       status = FS_read_font_header( f_ptr, &finf_hd, &fonthead);
       if (status != FF_S_SUCCESS)
          goto end_putKernTracks;

       tmpnam(tmp_name);
       ftmp_ptr = fopen(tmp_name, "w+");
       if (! ftmp_ptr ) {
          status = FF_FONT_NOT_OPEN + ERRO;
          goto end_putKernTracks;
          }

       fonthead.offsLigTable = 0;
       status = FS_write_font_header( ftmp_ptr, &finf_hd, &fonthead);
       if ( status != FF_S_SUCCESS )
          goto end_putKernTracks;

       sts = fwrite((char *)(&padint), sizeof(int), 1, ftmp_ptr);
       if (sts <= 0) {
           status = FF_FILE_WRITE_ERROR + ERRO;
           goto end_putKernTracks;
           } 

       fseek(ftmp_ptr, 0, 2);
       if( fonthead.offs_kernprs >= finf_hd.nr_data_wds ) {
           offs_kernprs = ftell( ftmp_ptr );
           knpr_dat     = NULL;
           status = FS_read_kern_prs( f_ptr,
                                      (int)(fonthead.offs_kernprs * 2),
                                      &knpr_hd, &knpr_dat);
           if (status != FF_S_SUCCESS)
               goto end_putKernTracks;

           fonthead.offs_kernprs = (IGRuint)(offs_kernprs / 2);

           status = FS_write_kern_prs( ftmp_ptr, offs_kernprs,
                                      &knpr_hd, knpr_dat);
           if (status != FF_S_SUCCESS)
               goto end_putKernTracks;

           sts = fwrite( (char *)(&padint), sizeof(int), 1, ftmp_ptr );
           if (sts <= 0) {
               status = FF_FILE_WRITE_ERROR + ERRO;
               goto end_putKernTracks;
               }

           fseek(ftmp_ptr, 0, 2);
           }
         else
           fonthead.offs_kernprs = 0;

       kntrk_hd.block_id[0] = 'T';
       kntrk_hd.block_id[1] = '1';
       kntrk_hd.nr_recs     = num_recs;
       kntrk_hd.rec_size    = num_tracks + 1;
       kntrk_hd.nr_data_wds = kntrk_hd.rec_size * num_recs;
       offs_kerntrks        = ftell( ftmp_ptr );
       status = FS_write_kern_trks( ftmp_ptr, offs_kerntrks,
                                   &kntrk_hd, kntrk_dat );
       if (status != FF_S_SUCCESS)
           goto end_putKernTracks;

       fonthead.offs_kerntrks = (IGRuint)(offs_kerntrks / 2);

       sts = fwrite( (char *)(&padint), sizeof(int), 1, ftmp_ptr );
       if (sts <= 0) {
            status = FF_FILE_WRITE_ERROR + ERRO;
            goto end_putKernTracks;
            } 

       sts = fseek(ftmp_ptr, 0, 2);
       offs_chardirs = ftell( ftmp_ptr );
       chdir_dat = NULL;
       status = FS_read_char_dirs( f_ptr,(int)(fonthead.offs_chardir * 2),
                                   &fonthead.layout_size, fonthead.flag1,
                                   &chdir_hd, &chdir_dat );
       if (status != FF_S_SUCCESS)
           goto end_putKernTracks;

       fonthead.offs_chardir = (IGRuint)(offs_chardirs / 2);

       status = FS_write_char_dirs( ftmp_ptr, offs_chardirs,
                                    &fonthead.flag1, &chdir_hd, chdir_dat);
       if (status != FF_S_SUCCESS)
           goto end_putKernTracks;

       sts = fwrite( (char *)(&padint), sizeof(int), 1, ftmp_ptr );
       if (sts <= 0) {
           status = FF_FILE_WRITE_ERROR + ERRO;
           goto end_putKernTracks;
           } 

       sts = fseek(ftmp_ptr, 0, 2);
       offs_outldata = ftell( ftmp_ptr );
       outl_dat = NULL;
       status = FS_read_outl_data( f_ptr,(int)(fonthead.offs_outldata * 2),
                                   &outl_hd, &outl_dat, &num_bytes_outl );
       if (status != FF_S_SUCCESS)
           goto end_putKernTracks;

       fonthead.offs_outldata = (IGRuint)(offs_outldata / 2);

       status = FS_write_outl_data( ftmp_ptr, offs_outldata,
                                   &outl_hd, outl_dat, num_bytes_outl );
       if (status != FF_S_SUCCESS)
           goto end_putKernTracks;

       status = FS_write_font_header( ftmp_ptr, &finf_hd, &fonthead );
       if ( status != FF_S_SUCCESS )
          goto end_putKernTracks;

       fflush( ftmp_ptr );
       while(system("sync") < 0);
       fseek(ftmp_ptr, 0, 2);
       bufflen = ftell( ftmp_ptr );
       sts = fseek(ftmp_ptr, 0, 0);
       charbuff = (char *)malloc(bufflen * sizeof(char));
       if(! charbuff ) {
           status = FF_MALLOC_ERROR + ERRO;
           goto end_putKernTracks;
           }

       sts = fread( charbuff, bufflen, 1, ftmp_ptr);
       if (sts <= 0) {
           status = FF_FILE_READ_ERROR + ERRO;
           goto end_putKernTracks;
           }

       if( f_ptr ) {
          fclose( f_ptr );
          f_ptr = NULL;
          }

       unlink( CX16to8(typeface_name) );
       f_ptr = fopen( CX16to8(typeface_name), "w" );
       if(! f_ptr ) {
           status = FF_FILE_NOT_OPEN + ERRO;
           goto end_putKernTracks;
           }

       sts = fwrite( charbuff, bufflen, 1, f_ptr);
       if (sts <= 0) {
           status = FF_FILE_WRITE_ERROR + ERRO;
           goto end_putKernTracks;
           }

       fflush( f_ptr );
       }
     else
       status = FF_TRACKTBL_NOT_FOUND + WARN;
       
end_putKernTracks:

   if ( ftmp_ptr ) {
      fflush( ftmp_ptr );
      fclose( ftmp_ptr );
      unlink( tmp_name );
      }

   if( f_ptr ) {
      fflush( f_ptr );
      fclose( f_ptr );
      while(system("sync") < 0);
      }

   if( charbuff  ) free( charbuff);
   if( knpr_dat  ) free( knpr_dat );
   if( chdir_dat ) free( chdir_dat );
   if( outl_dat  ) free( outl_dat );

   return ( status );

}




/*****************************************************************************
 *  FS_write_block_header is writes a block header data structure to a       *
 *  files.  'block_header' is a pointer to a structure of type               *
 *   'cft_block_hdr'.                                                        *
 *                                                                           *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_SEEK_ERROR        If there is a seek error.          *
 *              FF_FILE_READ_ERROR        If there is a write error          *
 *                                                                           *
 *****************************************************************************/

FS_write_block_header(fd_font, offset, block_header)

               FILE          *fd_font;      /* font file descriptor          */
               int            offset;       /* offset in bytes to the header */
               cft_block_hdr *block_header; /* ptr to blk header data desc   */

{
              char  *buff;        /* buffer for storing font header          */
              int    status, sts; /* FF return status                        */
#ifdef BIG_ENDIAN
              cft_block_hdr Xblock_header; /* ptr to blk header data desc   */
#endif

    status = FF_S_SUCCESS;


    sts = fseek(fd_font, offset, 0 );
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       return( status );
       }

#ifdef BIG_ENDIAN
    Xblock_header.block_id[0] = block_header->block_id[0];
    Xblock_header.block_id[1] = block_header->block_id[1];

    Xblock_header.nr_data_wds = block_header->nr_data_wds;
    Xconv_short(&Xblock_header.nr_data_wds);

    Xblock_header.rec_size    = block_header->rec_size;
    Xconv_short(&Xblock_header.rec_size);

    Xblock_header.nr_recs     = block_header->nr_recs;
    Xconv_short(&Xblock_header.nr_recs);

    buff = (char *)(&Xblock_header);
#else
    buff = (char *)block_header;
#endif

#ifdef DEBUG
    FS_print_block_header(block_header);
#endif

    sts = fwrite( buff, sizeof(cft_block_hdr), 1, fd_font );
    if (sts <=  0) {
        status = FF_FILE_WRITE_ERROR + ERRO;
        return ( status );
        } 

    return ( status );
}


#ifdef DEBUG
FS_print_block_header(block_header)
    cft_block_hdr *block_header; /* ptr to blk header data desc   */
{
    FILE *fp;

    fp = fopen("/usr/tmp/tmpFSbh.ftb", "w");
    fprintf(fp, "block_id[0] 		%d\n", block_header->block_id[0]);
    fprintf(fp, "block_id[1] 		%d\n", block_header->block_id[1]);
    fprintf(fp, "nr_data_wds 		%d\n", block_header->nr_data_wds);
    fprintf(fp, "rec_size 		%d\n", block_header->rec_size);
    fprintf(fp, "nr_recs 		%d\n", block_header->nr_recs);
    fclose(fp);

}
#endif



/*****************************************************************************
 *  FS_write_font_header is responsible for writing the general font         *
 *  information structure into the font file.                                *
 *                                                                           *
 *  Called by:  FS_write_typeface                                            *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_WRITE_ERROR       If there is a write error          *
 *                                                                           *
 *****************************************************************************/

FS_write_font_header(fd_font, finf_hd, fonthead)

        FILE          *fd_font;   /* font file descriptor            */
        cft_block_hdr *finf_hd;   /* ptr to the block header         */
        cft_font_hdr  *fonthead;  /* ptr to font information block   */

{
                 int    status, sts;      /* FS return status               */
                 char  *c_buff, *c_buffp; /* buffer for storing font header */
        IGRuchar  *uc_buff;          /* buffer for storing font header */
                 int    size_fi;          /* # bytes of font information    */
        static   char  custNotice[] = {
"This file structure may not be copied or reproduced without premission by Intergraph Inc.\0"};
#ifdef BIG_ENDIAN
		 short x_s;
		 int   x_i;
#endif
    status = FF_S_SUCCESS;

    c_buff  = NULL;
    uc_buff = (IGRuchar)NULL;

    finf_hd[0].block_id[0] = 'F';
    finf_hd[0].block_id[1] = '1';
    finf_hd[0].nr_data_wds = CFT_FHSIZE;
    finf_hd[0].rec_size    = 1;
    finf_hd[0].nr_recs     = CFT_FHSIZE;

    status = FS_write_block_header(fd_font, 0, finf_hd);

    if (status != FF_S_SUCCESS)
       goto end_write_font_header;

    fonthead->outl_fmt_nr[0] = 'C';
    fonthead->outl_fmt_nr[1] = '2';
    fonthead->outl_fmt_nr[2] = '.';
    fonthead->outl_fmt_nr[3] = '3';
    fonthead->outl_fmt_nr[4] = '2';
    fonthead->outl_fmt_nr[5] = '0';
    fonthead->outl_fmt_nr[6] = '0';
    fonthead->outl_fmt_nr[7] = '0';
    memset((char *)(&fonthead->custNotice[0]), (char)NULL, (100 * sizeof(char)));
    sprintf(fonthead->custNotice, "%80s", custNotice );
    fonthead->rev_number   = 0;
    memset((char *)(&fonthead->reserved[0]), (char)NULL, (110 * sizeof(char)) );

    size_fi  = finf_hd->nr_data_wds * 2;
    c_buff = (char *)malloc( size_fi * sizeof(char) );
    if(! c_buff ) {
        status = FF_MALLOC_ERROR + ERRO;
        goto end_write_font_header;
        }

    uc_buff = (IGRuchar *)c_buff;
    c_buffp = c_buff;
    memset( (char *)c_buff, (char)NULL, (size_fi * sizeof(char)) );

    move_ubytes((IGRuchar *)(&fonthead->outl_fmt_nr[0]), uc_buff, (int)8);
    if (!(FScheck_format(fonthead->outl_fmt_nr))) {
       status = FF_FILE_NOT_FS + ERRO;
       goto end_write_font_header;
       }

    uc_buff += 8;
    move_ubytes((IGRuchar *)(&fonthead->src_font_id[0]), uc_buff, (int)4);
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_s = fonthead->src_font_vrsn;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->src_font_vrsn), uc_buff, (int)2);
#endif
    uc_buff += 2;
    move_ubytes((IGRuchar *)(&fonthead->src_font_name[0]), uc_buff,(int)70);
    uc_buff += 70;
    move_ubytes((IGRuchar *)(&fonthead->mfg_date[0]), uc_buff, (int)10);
    uc_buff += 10;
    move_ubytes((IGRuchar *)(&fonthead->layout_name[0]),uc_buff,(int)70);
    uc_buff += 70;
#ifdef BIG_ENDIAN
    x_s = fonthead->layoutNumber;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->layoutNumber), uc_buff, (int)2);
#endif
    uc_buff += 2;
    move_ubytes((IGRuchar *)(&fonthead->cpyrt_notice[0]),uc_buff,(int)74);
    uc_buff += 74;
#ifdef BIG_ENDIAN
    x_i = fonthead->timestamp;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->timestamp), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_s = fonthead->resl_per_em;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->resl_per_em), uc_buff, (int)2);
#endif
    uc_buff += 2;
#ifdef BIG_ENDIAN
    x_s = fonthead->flag1;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->flag1), uc_buff, (int)2);
#endif
    uc_buff += 2;
#ifdef BIG_ENDIAN
    x_s = fonthead->flag2;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->flag2), uc_buff, (int)2);
#endif
    uc_buff += 2;
#ifdef BIG_ENDIAN
    x_i = fonthead->extent_x_min;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->extent_x_min), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->extent_x_max;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->extent_x_max), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->extent_y_min;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->extent_y_min), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->extent_y_max;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->extent_y_max), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->offs_kernprs;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->offs_kernprs), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->offs_kerntrks;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->offs_kerntrks), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->offsLigTable;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->offsLigTable), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->offs_chardir;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->offs_chardir), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->offs_outldata;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->offs_outldata), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_s = fonthead->layout_size;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->layout_size), uc_buff, (int)2);
#endif
    uc_buff += 2;
#ifdef BIG_ENDIAN
    x_s = fonthead->wordspace_width;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->wordspace_width),uc_buff,(int)2);
#endif
    uc_buff += 2;
#ifdef BIG_ENDIAN
    x_s = fonthead->cust_number;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->cust_number), uc_buff, (int)2);
#endif
    uc_buff += 2;
    move_ubytes((IGRuchar *)(&fonthead->custNotice[0]),uc_buff,(int)100);
    uc_buff += 100;
#ifdef BIG_ENDIAN
    x_s = fonthead->rev_number;
    Xconv_short(&x_s);
    move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
    move_ubytes((IGRuchar *)(&fonthead->rev_number), uc_buff, (int)2);
#endif
    uc_buff += 2;
#ifdef BIG_ENDIAN
    x_i = fonthead->userId;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->userId), uc_buff, (int)4);
#endif
    uc_buff += 4;
#ifdef BIG_ENDIAN
    x_i = fonthead->userData;
    Xconv_int(&x_i);
    move_ubytes((IGRuchar *)(&x_i), uc_buff, (int)4);
#else
    move_ubytes((IGRuchar *)(&fonthead->userData), uc_buff, (int)4);
#endif
    uc_buff += 4;
    move_ubytes((IGRuchar *)(&fonthead->reserved[0]),uc_buff,(int)110);

    sts = fwrite( c_buff, size_fi, 1, fd_font );
    if (sts < 0)
       status = FF_FILE_READ_ERROR + ERRO;

#ifdef DEBUG
    FS_print_font_header(fonthead);
#endif

end_write_font_header:

    if( c_buff )
       free ( c_buff );

    return ( status );
}


#ifdef DEBUG
FS_print_font_header(fonthead)
        cft_font_hdr  *fonthead;  /* ptr to font information block   */
{
     FILE *fp;

     fp = fopen( "/usr/tmp/tmpFSfh.ftb", "w");
     fprintf(fp, "FS_FONT_HEADER\n");
     fprintf(fp, "outl_fmt_nr 		%s\n", fonthead->outl_fmt_nr);
     fprintf(fp, "src_font_id 		%s\n", fonthead->src_font_id);
     fprintf(fp, "src_font_vrsn 	%d\n", fonthead->src_font_vrsn);
     fprintf(fp, "src_font_name 	%s\n", fonthead->src_font_name);
     fprintf(fp, "mfg_date 		%d\n", fonthead->mfg_date);
     fprintf(fp, "layout_name 		%s\n", fonthead->layout_name);
     fprintf(fp, "layoutNumber 		%d\n", fonthead->layoutNumber);
     fprintf(fp, "cpyrt_notice		%s\n", fonthead->cpyrt_notice);
     fprintf(fp, "timestamp 		%d\n", fonthead->timestamp);
     fprintf(fp, "resl_per_em 		%d\n", fonthead->resl_per_em);
     fprintf(fp, "flag1 		%d\n", fonthead->flag1);
     fprintf(fp, "flag2 		%d\n", fonthead->flag2);
     fprintf(fp, "extent_x_min 		%d\n", fonthead->extent_x_min);
     fprintf(fp, "extent_x_max 		%d\n", fonthead->extent_x_max);
     fprintf(fp, "extent_y_min 		%d\n", fonthead->extent_y_min);
     fprintf(fp, "extent_y_max 		%d\n", fonthead->extent_y_max);
     fprintf(fp, "offs_kernprs 		%d\n", fonthead->offs_kernprs);
     fprintf(fp, "offs_kerntrks 	%d\n", fonthead->offs_kerntrks);
     fprintf(fp, "offsLigTable 		%d\n", fonthead->offsLigTable);
     fprintf(fp, "offs_chardir 		%d\n", fonthead->offs_chardir);
     fprintf(fp, "offs_outldata 	%d\n", fonthead->offs_outldata);
     fprintf(fp, "layout_size 		%d\n", fonthead->layout_size);
     fprintf(fp, "wordspace_width 	%d\n", fonthead->wordspace_width);
     fprintf(fp, "cust_number 		%d\n", fonthead->cust_number);
     fprintf(fp, "custNotice 		%s\n", fonthead->custNotice);
     fprintf(fp, "rev_number 		%d\n", fonthead->rev_number);
     fprintf(fp, "userId 		%d\n", fonthead->userId);
     fprintf(fp, "userData 		%d\n", fonthead->userData);
     fprintf(fp, "reserved 		%s\n", fonthead->reserved);
     fclose(fp);
}
#endif


/*****************************************************************************
 *  FS_write_kern_prs is responsible for writing the kerning pair data       *
 *  structure into the font file.                                            *
 *                                                                           *
 *  Called by:  FS_write_typeface                                            *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_WRITE_ERROR       If there is a write error          *
 *                                                                           *
 *****************************************************************************/

FS_write_kern_prs(fd_font, offset, knpr_hd, knpr_dat)

        FILE               *fd_font;  /* font file descriptor         */
        int                 offset;   /* offset in bytes to kern pairs*/
        cft_block_hdr      *knpr_hd;  /* ptr to kern pair block header*/
        cft_kern_pair_rec  *knpr_dat; /* ptr to kern pair data records*/

{
	char  *buff;
        int    status, sts;

    status = FF_S_SUCCESS;

    status = FS_write_block_header(fd_font, offset, knpr_hd);
    if (status != FF_S_SUCCESS)
       return( status );

    sts = fseek(fd_font, offset + 8, 0 );
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       return( status );
       }

    buff = (char *)knpr_dat;
    sts  = fwrite( buff, (int)(knpr_hd->rec_size * knpr_hd->nr_recs * 2),
                   1, fd_font);
    if (sts <= 0) {
       status = FF_FILE_WRITE_ERROR + ERRO;
       return ( status );
       } 

    return ( status );
}




/*****************************************************************************
 *  FS_write_kern_trks is responsible for writing the track kerning data     *
 *  structure into the font file.                                            *
 *                                                                           *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS             If everything is OK                 *
 *              FF_FILE_READ_ERROR       If there is a read error            *
 *              FF_FILE_WRITE_ERROR      If there is a read error            *
 *                                                                           *
 *****************************************************************************/

FS_write_kern_trks( fd_font, offset, kntrk_hd, kntrk_dat )

        FILE              *fd_font;   /* font file descriptor         */
        int                offset;    /* offset in bytes to kern pairs*/
        cft_block_hdr     *kntrk_hd;  /* ptr to kern track blk header */
        cft_trk_kern_rec  *kntrk_dat; /* ptr to kern track record     */
{
	int      sts, status, size_kt, count1, count2, num_trks;
	short   *kntrk_buff, *kntrk_bptr;
        char    *cbuff;

        cft_trk_kern_rec *kntrk_ptr; /* ptr to kern track record     */

    status = FF_S_SUCCESS;

    kntrk_buff = NULL;

    status = FS_write_block_header(fd_font, offset, kntrk_hd);
    if (status != FF_S_SUCCESS)
       goto end_write_kern_trks;

    sts = fseek(fd_font, offset + 8, 0 );
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       goto end_write_kern_trks;
       }

    size_kt = (int)kntrk_hd->nr_data_wds * 2;
    if (size_kt == 0) {
       status = FF_TRACKTBL_NOT_FOUND + WARN;
       goto end_write_kern_trks;
       }

    kntrk_bptr = (short *)malloc( size_kt * sizeof(char) );
    if(! kntrk_bptr ) {
        status = FF_MALLOC_ERROR + ERRO;
        goto end_write_kern_trks;
        }

    kntrk_buff = kntrk_bptr;
    num_trks = (int)kntrk_hd->rec_size - 1;
    for (count1 = 0, kntrk_ptr = kntrk_dat;
         count1 < (int)kntrk_hd->nr_recs;
         count1++, kntrk_ptr++ ) {
       *kntrk_bptr = kntrk_ptr->pointSize;
       kntrk_bptr++;

       for( count2 = 0; count2 < num_trks; count2++, kntrk_bptr++ )
          *kntrk_bptr = kntrk_ptr->trackAdj[count2];
       }

    cbuff = (char *)kntrk_buff;
    sts   = fwrite( cbuff, size_kt, 1, fd_font);
    if (sts <= 0) {
       status = FF_FILE_WRITE_ERROR + ERRO;
       goto end_write_kern_trks;
       } 

end_write_kern_trks:

    if( kntrk_buff )
       free( kntrk_buff );

    return ( status );
}




/*****************************************************************************
 *  FS_write_char_dirs is responsible for writing the character directory    *
 *  data structures into the font file.                                      *
 *                                                                           *
 *  Called by:  FS_write_typeface                                            *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_WRITE_ERROR       If there is a write error          *
 *                                                                           *
 *****************************************************************************/

FS_write_char_dirs ( fd_font, offset, flag1, chdir_hd, chdir_dat)

        FILE             *fd_font;   /* font file descriptor            */
        int               offset;    /* offset in bytes to chardir head */
        IGRushort   *flag1;
        cft_block_hdr    *chdir_hd;  /* ptr to char dir block header    */
        cft_chardir_rec  *chdir_dat; /* ptr to char dir data records    */

{
	         char  *charbuff;
	IGRuchar  *uc_buff;
        IGRushort  s_outl_off, flag;
                 int    status, sts, ii, size_cd;
        IGRuint    l_outl_off;
        cft_chardir_rec  *chdir_ptr; /* ptr to kern pair data records*/
#ifdef BIG_ENDIAN
		 short	x_s;
#endif

    status = FF_S_SUCCESS;

    charbuff = NULL;

    status = FS_write_block_header(fd_font, offset, chdir_hd);
    if (status != FF_S_SUCCESS)
       goto end_write_char_dirs;

    size_cd = (int)chdir_hd->rec_size * (int)chdir_hd->nr_recs * 2;

    charbuff = (char *)malloc( size_cd * sizeof(char) );
    if(! charbuff ) {
        status = FF_MALLOC_ERROR + ERRO;
        goto end_write_char_dirs;
        }

    uc_buff   = (IGRuchar *)charbuff;
    chdir_ptr = chdir_dat;
    flag      = *flag1;
    for (ii = 0; ii < chdir_hd->nr_recs;  ii++ ) {
#ifdef BIG_ENDIAN
	x_s = chdir_ptr->set_width;
	Xconv_short(&x_s);
        move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
        move_ubytes((IGRuchar *)(&chdir_ptr->set_width), uc_buff, (int)2);
#endif
        uc_buff += 2;
        if ((flag & FS_CHARID) == 0) { /* no char ID word*/
            if (chdir_hd->rec_size == 2) {
                s_outl_off = (IGRushort)chdir_ptr->outline_offs;
#ifdef BIG_ENDIAN
		x_s = s_outl_off;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&s_outl_off),  uc_buff, (int)2);
#endif
                uc_buff += 2;
                }
              else {                                /* record size = 3 words */
                l_outl_off  = (IGRulong)chdir_ptr->outline_offs;
                s_outl_off  = (IGRushort)(l_outl_off << 16 >> 16);
#ifdef BIG_ENDIAN
		x_s = s_outl_off;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&s_outl_off),
                            uc_buff, (int)2);
#endif
                uc_buff += 2;
                s_outl_off  = (IGRushort)(l_outl_off >> 16);
#ifdef BIG_ENDIAN
		x_s = s_outl_off;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&s_outl_off),
                            uc_buff, (int)2);
#endif
                uc_buff += 2;
                }
            }
          else {       /* char ID is last word in character directory record */
            if (chdir_hd->rec_size == 3) {
                s_outl_off = (IGRushort)chdir_ptr->outline_offs;
#ifdef BIG_ENDIAN
		x_s = s_outl_off;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&s_outl_off),  uc_buff, (int)2);
#endif
                uc_buff += 2;
#ifdef BIG_ENDIAN
		x_s = chdir_ptr->char_id;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&chdir_ptr->char_id),
                            uc_buff, (int)2);
#endif
                uc_buff += 2;
                }
              else {                                /* record size = 4 words */
                l_outl_off  = (IGRulong)chdir_ptr->outline_offs;
                s_outl_off  = (IGRushort)(l_outl_off << 16 >> 16);
#ifdef BIG_ENDIAN
		x_s = s_outl_off;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&s_outl_off),
                            uc_buff, (int)2);
#endif
                uc_buff += 2;
                s_outl_off  = (IGRushort)(l_outl_off >> 16);
#ifdef BIG_ENDIAN
		x_s = s_outl_off;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&s_outl_off),
                            uc_buff, (int)2);
#endif
                uc_buff += 2;
#ifdef BIG_ENDIAN
		x_s = chdir_ptr->char_id;
		Xconv_short(&x_s);
        	move_ubytes((IGRuchar *)(&x_s), uc_buff, (int)2);
#else
                move_ubytes((IGRuchar *)(&chdir_ptr->char_id),
                            uc_buff, (int)2);
#endif
                uc_buff += 2;
                }
            }
        chdir_ptr++;
        }

    sts = fseek(fd_font, offset + 8, 0 );
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       goto end_write_char_dirs;
       }

    sts  = fwrite( charbuff,
                   ((int)chdir_hd->rec_size * (int)chdir_hd->nr_recs * 2),
                   1, fd_font);
    if (sts <= 0) {
       status = FF_FILE_WRITE_ERROR + ERRO;
       goto end_write_char_dirs;
       } 

end_write_char_dirs:

    if( charbuff )
       free( charbuff );

    return ( status );
}




/*****************************************************************************
 *  FS_write_outl_data is responsible for writing all the outline data into  *
 *  the font file.                                                           *
 *                                                                           *
 *  Called by:  FS_write_typeface                                            *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_WRITE_ERROR       If there is a write error          *
 *                                                                           *
 *****************************************************************************/


FS_write_outl_data( fd_font, offset, outl_hd, outl_dat, num_bytes_outl )

                 FILE           *fd_font;  /* font file descriptor         */
                 int             offset;   /* offset in bytes to kern pairs*/
                 cft_block_hdr  *outl_hd;  /* ptr to kern pair block header*/
        IGRushort          *outl_dat; /* ptr to kern pair data records*/
                 int             num_bytes_outl;
{
	char  *buff;
        int    status, sts;

    status = FF_S_SUCCESS;

    status = FS_write_block_header(fd_font, offset, outl_hd);
    if (status != FF_S_SUCCESS)
       return( status );

    sts = fseek(fd_font, offset + 8, 0 );
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       return( status );
       }

    buff = (char *)outl_dat;
    sts  = fwrite( buff, num_bytes_outl, 1, fd_font);
    if (sts <= 0) {
       status = FF_FILE_WRITE_ERROR + ERRO;
       return ( status );
       } 

    return ( status );
}



/*****************************************************************************
 *  FS_read_block_header is reads a block header data structure to a         *
 *  files.  'block_header' is a pointer to a structure of type               *
 *   'cft_block_hdr'.                                                        *
 *                                                                           *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_SEEK_ERROR        If there is a seek error           *
 *              FF_FILE_READ_ERROR        If there is a read error           *
 *                                                                           *
 *****************************************************************************/

int  FS_read_block_header(fd_font, offset, block_header)

        FILE          *fd_font;      /* font file descriptor          */
        int            offset;       /* offset in bytes to the header */
        cft_block_hdr *block_header; /* ptr to blk header data desc   */

{
        int    status, sts; /* FS return status                        */

    status = FF_S_SUCCESS;


    sts = fseek(fd_font, offset, 0 );
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       return( status );
       }

    fread( (char *)block_header, sizeof(cft_block_hdr), 1, fd_font );
    if (status != FF_S_SUCCESS) {
        status = FF_FILE_READ_ERROR + ERRO;
        return ( status );
        } 

    return ( status );
}




/*****************************************************************************
 *  FS_read_font_header is responsible for writing the general font          *
 *  information structure into the font file.                                *
 *                                                                           *
 *  Called by:  FS_read_typeface                                             *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS             If everything is OK                 *
 *              FF_FILE_READ_ERROR       If there is a read error            *
 *                                                                           *
 *****************************************************************************/

FS_read_font_header(fd_font, finf_hd, fonthead)

        FILE          *fd_font;   /* font file descriptor            */
        cft_block_hdr *finf_hd;   /* ptr to the block header         */
        cft_font_hdr  *fonthead;  /* ptr to font information block   */

{
                 int    status, sts;       /* FS return status               */
                 char  *charbuff, *c_buffp; /* buffer for storing font header*/
        IGRuchar  *uc_buff;
        IGRushort *buff_s;
                 short  fmnr;              /* font format code               */
                 int    size_fi;           /* # bytes of font information    */

    status = FF_S_SUCCESS;

    charbuff = NULL;

    status = FS_read_block_header(fd_font, 0, finf_hd);
    if (status != FF_S_SUCCESS )
       goto end_read_font_header;

    size_fi  = finf_hd->nr_data_wds * 2;
    charbuff = (char *)malloc( size_fi * sizeof(char) );
    if(! charbuff ) {
       status = FF_MALLOC_ERROR + ERRO;
       goto end_read_font_header;
       }

    memcpy( charbuff, (char)NULL, size_fi * sizeof(char) );

    sts = fread( charbuff, size_fi, 1, fd_font );
    if (sts <= 0) {
       status = FF_FILE_READ_ERROR + ERRO;
       free( charbuff );
       return( status );
       }

    uc_buff = (IGRuchar *)charbuff;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->outl_fmt_nr[0]), (int)8);
    if (!(FScheck_format(fonthead->outl_fmt_nr))) {
       status = FF_FILE_NOT_FS + ERRO;
       goto end_read_font_header;
       }

    uc_buff += 8;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->src_font_id[0]), (int)4);
    uc_buff += 4;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->src_font_vrsn), (int)2);
    uc_buff += 2;
    move_ubytes(uc_buff, (IGRuchar *)fonthead->src_font_name, (int)70);
    uc_buff += 70;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->mfg_date[0]), (int)10);
    uc_buff += 10;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->layout_name[0]),(int)70);
    uc_buff += 70;
    if (finf_hd->nr_data_wds == CFT_FHSIZE) {
       move_ubytes(uc_buff, (IGRuchar *)(&fonthead->layoutNumber), (int)2);
       uc_buff += 2;
       }
    move_ubytes(uc_buff,(IGRuchar *)(&fonthead->cpyrt_notice[0]),(int)74);
    uc_buff += 74;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->timestamp), (int)4);
    uc_buff += 4;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->resl_per_em), (int)2);
    uc_buff += 2;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->flag1), (int)2);
    uc_buff += 2;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->flag2), (int)2);
    uc_buff += 2;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->extent_x_min), (int)4);
    uc_buff += 4;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->extent_x_max), (int)4);
    uc_buff += 4;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->extent_y_min), (int)4);
    uc_buff += 4;
    move_ubytes(uc_buff, (IGRuchar *)(&fonthead->extent_y_max), (int)4);
    uc_buff += 4;
    c_buffp = (char *)uc_buff;
    move_bytes(c_buffp, (char *)(&fonthead->offs_kernprs), (int)4);
    c_buffp += 4;
    move_bytes(c_buffp, (char *)(&fonthead->offs_kerntrks), (int)4);
    c_buffp += 4;

    if (finf_hd->nr_data_wds == CFT_FHSIZE) {
       move_bytes(c_buffp, (char *)(&fonthead->offsLigTable), (int)4);
       c_buffp += 4;
       }

    move_bytes(c_buffp, (char *)(&fonthead->offs_chardir), (int)4);
    c_buffp += 4;
    move_bytes(c_buffp, (char *)(&fonthead->offs_outldata), (int)4);
    c_buffp += 4;
       
    if ((IGRuint)fonthead->offs_kernprs > 1000000  ||
         (IGRuint)fonthead->offs_kerntrks > 1000000 ||
          (IGRuint)fonthead->offs_chardir > 1000000  ||
           (IGRuint)fonthead->offs_outldata > 1000000  ) {
        status = FF_FILE_READ_ERROR + ERRO;
        goto end_read_font_header;
        }
        
   /*  Format C2.3 is the latest format and has a font information section
    *    either 142 or 143 words long. The longer field includes a 16-bit
    *    customer number field at the end.
    *  Format C1.0 is the absolute format. Don't worry about it  */
    buff_s = (IGRushort *)c_buffp;
    fmnr = 10 * (fonthead->outl_fmt_nr[1] - '0')
              + (fonthead->outl_fmt_nr[3] - '0')
              + (fonthead->outl_fmt_nr[4] - ' ');
    if (fmnr == 10) {           /* format "C1.0" */
        fonthead->layout_size = 0xffff;  /* see 'load_char_dirs'    */
        fonthead->wordspace_width = 0;
        fonthead->cust_number = 0;
        }
      else if ( (fmnr == 23)
             || (fmnr == 41) ) {      /* format "C2.3 & C2.32" */
        move_bytes(c_buffp, (char *)(&fonthead->layout_size), (int)2);
        c_buffp += 2;
        move_bytes(c_buffp, (char *)(&fonthead->wordspace_width), (int)2 );
        c_buffp += 2;

        if (fonthead->flag2 & 0x8000) {
            move_bytes(c_buffp, (char *)(&fonthead->cust_number), (int)2);
            }
          else
            fonthead->cust_number = 0;

        c_buffp += 2;
        if (fmnr == 41) {
           uc_buff = (IGRuchar *)c_buffp;
           move_ubytes(uc_buff, (IGRuchar *)(&fonthead->custNotice[0]),(int)100);
           uc_buff += 100;
           c_buffp = (char *)uc_buff;
           move_bytes(c_buffp, (char *)(&fonthead->rev_number),(int)2);
           c_buffp += 2;
           move_bytes(c_buffp, (char *)(&fonthead->userId),(int)4);
           c_buffp += 4;
           move_bytes(c_buffp, (char *)(&fonthead->userData),(int)4);
           c_buffp += 4;
           }
        }

end_read_font_header:

    if( charbuff )
       free( charbuff );

    return ( status );
}




/*****************************************************************************
 *  FS_read_kern_prs is responsible for writing the kerning pair data        *
 *  structure into the font file.                                            *
 *                                                                           *
 *  Called by:  FS_read_typeface                                             *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_READ_ERROR       If there is a read error            *
 *                                                                           *
 *****************************************************************************/

FS_read_kern_prs(fd_font, offset, knpr_hd, knpr_dat)

        FILE               *fd_font;  /* font file descriptor         */
        int                 offset;   /* offset in bytes to kern pairs*/
        cft_block_hdr      *knpr_hd;  /* ptr to kern pair block header*/
        cft_kern_pair_rec **knpr_dat; /* ptr to kern pair data records*/
 
{
	int                 sts, status, size_pr/*, count1*/;

    status = FF_S_SUCCESS;

    *knpr_dat = NULL;

    status = FS_read_block_header(fd_font, offset, knpr_hd);
    if( (status != FF_S_SUCCESS) || (! knpr_hd->nr_recs) )
        goto end_read_kern_prs;

    size_pr  = knpr_hd->nr_recs * sizeof(cft_kern_pair_rec);
    *knpr_dat = (cft_kern_pair_rec *)malloc( size_pr * sizeof(char) );
    if(! (*knpr_dat) ) {
        status = FF_MALLOC_ERROR + ERRO;
        goto end_read_kern_prs;
        }

    memset( (char *)(*knpr_dat), (char)NULL, (size_pr * sizeof(char)) );
    sts  = fread((char *)(*knpr_dat), size_pr, 1, fd_font);
    if (sts <= 0)
       status = FF_FILE_READ_ERROR + ERRO;

end_read_kern_prs:

    if (status != FF_S_SUCCESS) {
       if( *knpr_dat ) free( *knpr_dat );
       *knpr_dat = NULL;
       }

    return ( status );
}




/*****************************************************************************
 *  FS_read_kern_trks is responsible for writing the track kerning data      *
 *  structure into the font file.                                            *
 *                                                                           *
 *  Called by:  FS_read_typeface                                             *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_READ_ERROR       If there is a read error            *
 *                                                                           *
 *****************************************************************************/

FS_read_kern_trks( fd_font, offset, kntrk_hd, kntrk_dat )

        FILE              *fd_font;   /* font file descriptor         */
        int                offset;    /* offset in bytes to kern pairs*/
        cft_block_hdr     *kntrk_hd;  /* ptr to kern track blk header */
        cft_trk_kern_rec **kntrk_dat; /* ptr to kern track record     */
{
	int      sts, status, size_kt, count1, count2,
                 num_trks;
	short   *kntrk_buff, *kntrk_bptr;

        cft_trk_kern_rec *kntrk_ptr; /* ptr to kern track record     */

    status = FF_S_SUCCESS;

    kntrk_buff = NULL;
    *kntrk_dat = NULL;
    num_trks   = 0;

    status = FS_read_block_header(fd_font, offset, kntrk_hd);
    if( (status != FF_S_SUCCESS) || ( kntrk_hd->nr_recs == 0 ) )
        goto end_read_kern_trks;

    size_kt   = (int)kntrk_hd->nr_data_wds * 2 + sizeof(cft_trk_kern_rec);
    if (size_kt == 0) {
       status = FF_TRACKTBL_NOT_FOUND + WARN;
       goto end_read_kern_trks;
       }

    num_trks = (int)kntrk_hd->rec_size - 1;
    if ((int)kntrk_hd->nr_recs == 0) {
       status = FF_TRACKTBL_NOT_FOUND + WARN;
       goto end_read_kern_trks;
       }

    *kntrk_dat = (cft_trk_kern_rec *)
                 malloc( (int)kntrk_hd->nr_recs * sizeof(cft_trk_kern_rec) );
    kntrk_bptr = (short *)malloc( size_kt * sizeof(char) );
    if ( (! kntrk_bptr) || (! (*kntrk_dat)) ) {
        if( *kntrk_dat ) free( *kntrk_dat );
        if( kntrk_bptr ) free( kntrk_bptr );
        *kntrk_dat = NULL;
        status = FF_MALLOC_ERROR + ERRO;
        goto end_read_kern_trks;
        }

    memset( (char *)(*kntrk_dat), (char)NULL,
            ((int)kntrk_hd->nr_recs * sizeof(cft_trk_kern_rec)) );
    memset( (char *)(kntrk_bptr), (char)NULL, (size_kt * sizeof(char)) );
    kntrk_buff = kntrk_bptr;
    kntrk_ptr = *kntrk_dat;

    sts  = fread( (char *)kntrk_buff, size_kt, 1, fd_font);
    if (sts <= 0) {
       status = FF_FILE_READ_ERROR + ERRO;
       goto end_read_kern_trks;
       } 

    for (count1 = 0;
         count1 < (int)kntrk_hd->nr_recs;
         count1++, kntrk_ptr++ ) {
       kntrk_ptr->pointSize = *kntrk_bptr;
       kntrk_bptr++;

       for( count2 = 0; count2 < num_trks; count2++, kntrk_bptr++ )
          kntrk_ptr->trackAdj[count2] = *kntrk_bptr;
       }



end_read_kern_trks:

    if (status != FF_S_SUCCESS) {
       if( *kntrk_dat ) free( *kntrk_dat );
       *kntrk_dat = NULL;
       }

    if( kntrk_buff )
       free( kntrk_buff );

    return ( status );
}





/*****************************************************************************
 *  FS_read_char_dirs reads the character directories from the font and puts *
 *  them into an array of data structures. A pointer to these is in the      *
 *  font data structure (chdir_dat).                                         *
 *                                                                           *
 *  Called by:  FS_read_typeface                                             *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_READ_ERROR       If there is a read error            *
 *                                                                           *
 *****************************************************************************/

FS_read_char_dirs ( fd_font, offset, layout_size, flag1, chdir_hd, chdir_dat)

        FILE              *fd_font;     /* font file descriptor         */
        int                offset;      /* offset in bytes to kern pairs*/
        IGRushort    *layout_size; /* number of char directories   */
        IGRushort     flag1;       /* flag bits for char dir type  */
        cft_block_hdr     *chdir_hd;    /* ptr to kern pair block header*/
        cft_chardir_rec  **chdir_dat;   /* ptr to kern pair data records*/

{
	   int     status, sts;
           char   *charbuff;/*, *c_buff;*/  /* buffer for storing font header */
  IGRuchar   *uc_buff;
  IGRushort   s_outl_off;
           short   ii, ID;
           int     size_cd;            /* # bytes in character directories */

        cft_chardir_rec    *chdir_ptr; /* ptr to kern pair data records*/

    status = FF_S_SUCCESS;

    charbuff   = NULL;
    *chdir_dat = NULL;

    status = FS_read_block_header(fd_font, offset, chdir_hd);
    if (status != FF_S_SUCCESS)
       goto end_read_char_dirs;

    size_cd = (int)chdir_hd->rec_size * (int)chdir_hd->nr_recs * 2;

    if ((int)(*layout_size) == -1) /* If not already defined */
        *layout_size = (IGRushort)chdir_hd->nr_recs;

    charbuff = (char *)malloc( size_cd * sizeof(char) );
    if(! charbuff ) {
        status = FF_MALLOC_ERROR + ERRO;
        goto end_read_char_dirs;
        }

    memset((char *)charbuff, (char)NULL, (size_cd * sizeof(char)) );

    *chdir_dat = (cft_chardir_rec *)
                 malloc((int)chdir_hd->nr_recs * sizeof(cft_chardir_rec));
    if (! (*chdir_dat) ) {
        status = FF_MALLOC_ERROR + ERRO;
        goto end_read_char_dirs;
        }

    memset((char *)(*chdir_dat), (char)NULL,
           (int)chdir_hd->nr_recs * sizeof(cft_chardir_rec));
    chdir_ptr = *chdir_dat;

    sts  = fread( charbuff, size_cd, 1, fd_font);
    if (sts <= 0) {
       status = FF_FILE_READ_ERROR + ERRO;
       goto end_read_char_dirs;
       } 

    uc_buff = (IGRuchar *)charbuff;
    ID      = 1;
    for (ii = 0; ii < chdir_hd->nr_recs;  ii++ ) {
        move_ubytes(uc_buff, (IGRuchar *)(&chdir_ptr->set_width), (int)2);
        uc_buff += 2;
        if ((flag1 & FS_CHARID) == 0) { /* no char ID word*/
            if (chdir_hd->rec_size == 2) {
                move_ubytes(uc_buff, (IGRuchar *)(&chdir_ptr->outline_offs),
                            (int)2 );
                uc_buff += 2;
                }
              else {                                /* record size = 3 words */
                move_ubytes(uc_buff, (IGRuchar *)(&s_outl_off), (int)2);
                uc_buff += 2;
                chdir_ptr->outline_offs = s_outl_off;
                move_ubytes(uc_buff, (IGRuchar *)(&s_outl_off), (int)2);
                uc_buff += 2;
                chdir_ptr->outline_offs += (((IGRuint)s_outl_off) << 16);
                }
            move_ubytes((IGRuchar *)(&ID), chdir_ptr->char_id, (int)2);
            ID++;
            }
          else         /* char ID is last word in character directory record */
            {
            if (chdir_hd->rec_size == 3) {
                move_ubytes(uc_buff, (IGRuchar *)(&chdir_ptr->outline_offs),
                            (int)2 );
                uc_buff += 2;
                move_bytes(uc_buff, (IGRuchar *)(&chdir_ptr->char_id),
                            (int)2 );
                uc_buff += 2;
                }
              else {                                /* record size = 4 words */
                move_ubytes(uc_buff, (IGRuchar *)(&s_outl_off), (int)2);
                uc_buff += 2;
                chdir_ptr->outline_offs = s_outl_off;
                move_ubytes(uc_buff, (IGRuchar *)(&s_outl_off), (int)2);
                uc_buff += 2;
                chdir_ptr->outline_offs += (((IGRuint)s_outl_off) << 16);
                move_ubytes(uc_buff, (IGRuchar *)(&chdir_ptr->char_id),
                            (int)2 );
                uc_buff += 2;
                }
            }
        chdir_ptr++;
        }


end_read_char_dirs:

    if (status != FF_S_SUCCESS) {
       if( chdir_ptr ) free( (*chdir_dat) );
       *chdir_dat = NULL;
       }

    if( charbuff )
       free( charbuff );

    return ( status );
}




/*****************************************************************************
 *  FS_read_outl_data is responsible for writing all the outline data into   *
 *  the font file.                                                           *
 *                                                                           *
 *  Called by:  FS_read_typeface                                             *
 *                                                                           *
 *  Returns:    FF_S_SUCCESS              If everything is OK                *
 *              FF_FILE_READ_ERROR        If there is a read error           *
 *                                                                           *
 *****************************************************************************/


FS_read_outl_data( fd_font, offset, outl_hd, outl_dat, num_bytes_outl )

                 FILE           *fd_font;  /* font file descriptor         */
                 int             offset;   /* offset in bytes to kern pairs*/
                 cft_block_hdr  *outl_hd;  /* ptr to kern pair block header*/
        IGRushort         **outl_dat; /* ptr to kern pair data records*/
                 int            *num_bytes_outl;
{
                 int      sts, status, size_ot, end_outl;

    status = FF_S_SUCCESS;

    *outl_dat = NULL;

    status = FS_read_block_header(fd_font, offset, outl_hd);
    if (status != FF_S_SUCCESS)
       return( status );

    fseek(fd_font, 0, 2 );
    end_outl = ftell( fd_font );
    size_ot         = end_outl - offset - 8;
    *num_bytes_outl = size_ot;

    sts = fseek(fd_font, offset + 8, 0);
    if (sts < 0) {
       status = FF_FILE_SEEK_ERROR + ERRO;
       return( status );
       }

    *outl_dat = (IGRushort *)malloc( size_ot * sizeof(char) );
    if(! (*outl_dat) ) {
        status = FF_MALLOC_ERROR + ERRO;
        goto end_read_outl_data;
        }

    memset( (char *)(*outl_dat), (char)NULL, (size_ot * sizeof(char)) );

    sts  = fread( (char *)(*outl_dat), size_ot, 1, fd_font);
    if (sts <= 0) {
       status = FF_FILE_READ_ERROR + ERRO;
       goto end_read_outl_data;
       } 


end_read_outl_data:

    if (status != FF_S_SUCCESS) {
       if( *outl_dat ) free( *outl_dat );
       *outl_dat  = NULL;
       }

    return ( status );
}





/********************************************************************************
 *  FS_check_Font is responsible for checking to see if the file is a bitstream *
 *              compressed file structure.                                      *
 *                                                                              *
 *  Called by:                                                                  *
 *                                                                              *
 *  Returns:   FF_S_SUCCESS               If everything is OK                   *
 *             FF_FONT_NOT_OPEN   + ERRO  If the file could not be opened.      *
 *             FF_FILE_NOT_FS     + ERRO  If the file is not a Font Server File *
 *             FF_FILE_READ_ERROR + ERRO  If there is a read error              *
 *                                                                              *
 ********************************************************************************/

FS_check_Font( typeface_name )

        Typepath typeface_name;

{
                 int    status, sts;       /* FS return status                 */
                 char   charbuff[513], *c_buffp, *CX16to8();
        IGRuchar  *uc_buff;

                 FILE          *fd_font, *fopen(); /* font file descriptor     */
                 cft_block_hdr  finf_hd;           /* ptr to the block header  */
                 cft_font_hdr   fonthead;

   status  = FF_S_SUCCESS;
   fd_font = NULL;

   fd_font = fopen( CX16to8(typeface_name), "r" );
   if(! fd_font ) {
      status = FF_FONT_NOT_OPEN + ERRO;
      goto end_FS_check_Font;
      }

   status = FS_read_block_header(fd_font, 0, &finf_hd);
   if (status != FF_S_SUCCESS )
      goto end_FS_check_Font;

   c_buffp = &charbuff[0];
   sts = fread( c_buffp, 512, 1, fd_font );
   if (sts <= 0) {
      status = FF_FILE_READ_ERROR + ERRO;
      goto end_FS_check_Font;
      }

   uc_buff = (IGRuchar *)(c_buffp);
   move_ubytes(uc_buff, (IGRuchar *)(&fonthead.outl_fmt_nr[0]), (int)8);
   if (     (!(FScheck_format(fonthead.outl_fmt_nr)))
         || ((strncmp(finf_hd.block_id, "F1", 2)) != 0) ) {
       status = FF_FILE_NOT_FS + WARN;
       printf("\n%s%s%s\n","The file is not a Font Server file.\n",
                       "The file is:  ", CX16to8(typeface_name));
       }

end_FS_check_Font:

   if( fd_font ) fclose( fd_font );
   
   return( status );
   
}




/******************************************************************************
 * CHECK_FORMAT is a boolean function that returns TRUE if the outline format *
 *    number is either "C2.3", or "C1.0"                                      *
 *****************************************************************************/

FScheck_format( string )

  char     *string;         /* buffer for read() */

{

    if (strncmp(string, "C2.", 3) != 0  &&
        strncmp(string, "C1.0", 4) != 0 ) {
        return( 0 );
        }

    return( 1 );
}
