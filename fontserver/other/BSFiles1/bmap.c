




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/******************************** B M A P . C ********************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)  17-Mar-86  mby   Merged bmap0.c, bmap1.c, bmap2.c, bmap3.c, bmap4.c
                      into one module (bmap.c). Eliminated unused functions
                      to conserve space.

 2)  12-Nov-86  tpl   Changed all code that assumed 68000 byte order to 
                      also support dec byte order.
                      Added an optional compile flag designed to conserve
                      memory at run-time.

 3)  16-Jan-87  tpl   Changed code that generates a temporary pathname
                      (if can't open in the standard temp directory, then
                      trys to open a temporary file in the current dir.)

 4)  27-Feb-87  mby   Added code for putting kerning pairs in font.

 5)  13-Mar-87  tpl   Changed the code that generates a temporary pathname
                      to use the temporary pathname (char temp_path[]),
                      and changed the temporary filename to always be
                      'bitmaps.tmp'


 Note: to cause bitmap images to be stored in a temporary file insert the
 definition:
    #define BMAPS_IN_TEMP_FILE      - store bmap image data in temp file
 in your stdef.h file. This will significantly reduce memory requirements
 but has some drawbacks:
    - increases execution times
    - this code becomes less flexible. You must be more careful about the 
      sequence you call these functions. (only call attach_map when you know
      that you will not need to use the map anymore)
    - a temporary file is opened and written to. If the program aborts
      after calling bmap_initiate() but before calling bmap_free(), then
      the temp file will still exist after the program terminates! normally
      bmap_free() deletes the temporary file.

 *****************************************************************************

   Access functions for Bitstream Standard Bitmap Format, version B1.1
   Created by Nardy Henigan.

 ****************************************************************************/


#include "../hfiles/stdef.h"                  /* Bitstream standard macros  */
#include "../hfiles/bmap.h"
#include <malloc.h>
#include <stdio.h>



#ifdef BMAPS_IN_TEMP_FILE
extern  char    temp_path[];        /* directory for temporary files        */
global  char    temp_images_filename[128];
static  int     temp_images_file = NULL; /* Temporary file for images */

bit8     temp_bmap[MAX_STORED_BMAP];
int      i;
char     c;

FUNCTION bool start_temp_images_file()
        /*
         * Opens a temporary file (called 'bitmaps.tmp') in the temporary
         * specified by temp_path[]. 
         * 
         * Called by bmap_initiate ()
         * 
         * Returns: FALSE If it doesn't work
         *          TRUE  if no problem
         */
        DECLARE

        BEGIN
        sprintf(temp_images_filename,"%sbitmaps.tmp",temp_path);
        temp_images_file = open (temp_images_filename,WRITE, (fix) OMODE);
        if (temp_images_file < 0)
            {
            fprintf(stderr,"Cannot start a new temporary image file '%s'\n",
                temp_images_filename);
            return (FALSE);
            }
        else
            return(TRUE);
        END

FUNCTION bool examine_temp_images_file()
        /*
         * Closes the temporary image file, and reopens it for
         * read access.
         * 
         * Called by bmap_write_map_sec ()
         * 
         * Returns: FALSE If it doesn't work
         *          TRUE  if no problem
         */
        DECLARE
        BEGIN
        close (temp_images_file);
        temp_images_file = open (temp_images_filename,READ);
        if (temp_images_file < 0)
            {
            fprintf(stderr,"Cannot examine temporary image file '%s'\n",
                temp_images_filename);
            return (FALSE);
            }
        else
            return (TRUE);
        END

FUNCTION bool end_temp_images_file()
        /*
         * Closes the temporary image file, and deletes it.
         * 
         * Called by bmap_free (bmap_descr)
         * 
         * Returns: FALSE If it doesn't work
         *          TRUE  if no problem
         */
        DECLARE
        BEGIN
        close (temp_images_file);
        if (remove (temp_images_filename) != -1)
            {
            temp_images_filename[0]='\0';
            temp_images_file = -1;
            return (TRUE);
            }
        else
            {
            fprintf(stderr,"Cannot close and erase temporary image file '%s'\n",
                 temp_images_filename);
            return (FALSE);
            }
        END

#endif /* defined BMAPS_IN_TEMP_FILE */


FUNCTION void date_stamp (string)

     chr8                *string;

     DECLARE
     chr8                *ascii_month;
     chr8                ascii_day[8];
     fix15               year, month, day, hour, minute, second;

#ifdef apollo
     void                aplo_todays_date();
#endif /* apollo */
#ifdef MSDOS
     void                msdos_todays_date();
#endif /* MSDOS */
#ifdef IPRO
     void                ipro_todays_date();
#endif /* interpro */
     
     BEGIN
#ifdef apollo
     aplo_todays_date (&year, &month, &day, &hour, &minute, &second);
#endif /* apollo */
#ifdef MSDOS
     msdos_todays_date  (&year, &month, &day, &hour, &minute, &second);
#endif /* MSDOS */
#ifdef IPRO
     ipro_todays_date (&year, &month, &day, &hour, &minute, &second);
#endif /* interpro */

     switch (month)
          {
          case 1:        {ascii_month = "Jan"; break;}
          case 2:        {ascii_month = "Feb"; break;}
          case 3:        {ascii_month = "Mar"; break;}
          case 4:        {ascii_month = "Apr"; break;}
          case 5:        {ascii_month = "May"; break;}
          case 6:        {ascii_month = "Jun"; break;}
          case 7:        {ascii_month = "Jul"; break;}
          case 8:        {ascii_month = "Aug"; break;}
          case 9:        {ascii_month = "Sep"; break;}
          case 10:       {ascii_month = "Oct"; break;}
          case 11:       {ascii_month = "Nov"; break;}
          case 12:       {ascii_month = "Dec"; break;}
          }

     if (day < 10)
          sprintf (ascii_day, "0%d", day);
     else
          sprintf (ascii_day, "%d", day);

     sprintf (string, "%-2.2s %-3.3s %2d ",
              ascii_day, ascii_month, year - 1900);

     return;
     END




FUNCTION fix31 bmap_autoset_copyright (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     chr8                copyright_notice[80];
     fix15               year, month, day, hour, minute, second;

#ifdef apollo
     void                aplo_todays_date();
#endif /* apollo */
#ifdef MSDOS
     void                msdos_todays_date();
#endif /* MSDOS */
#ifdef IPRO
     void                ipro_todays_date();
#endif /* interpro */
     
     BEGIN
#ifdef apollo
     aplo_todays_date (&year, &month, &day, &hour, &minute, &second);
#endif /* apollo */
#ifdef MSDOS
     msdos_todays_date (&year, &month, &day, &hour, &minute, &second);
#endif /* MSDOS */
#ifdef IPRO
     ipro_todays_date (&year, &month, &day, &hour, &minute, &second);
#endif /* interpro */
     sprintf (copyright_notice,
              "(c) Copyright Bitstream Inc. %d. All rights reserved", year);
     strncpy (bmap_descr->hdr->copyrt, copyright_notice, 34);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_autoset_format_version (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     strncpy (bmap_descr->hdr->fmt_versn, "B1.1", 4);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_autoset_mfg_date (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     void                date_stamp();
     chr8                date[12];

     BEGIN
     date_stamp (date);
     strncpy (bmap_descr->hdr->mfg_date, date, 10);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_autoset_start_byte_nbr (bmap_descr, kern_records, dir_records, map_bytes)

     bmap_font_desc_t   bmap_descr;
     fix31               kern_records;
     fix31               dir_records;
     fix31               map_bytes;

     DECLARE
     chr8                version_spec[8];
     chr8               *bmap_format_version();

     BEGIN
     bmap_descr->hdr->nbr_kern_rec = kern_records;
     bmap_descr->hdr->nbr_dir_rec  = dir_records;
     bmap_descr->hdr->bytes_map_sec = map_bytes;

     if (strncmp (bmap_format_version (bmap_descr, version_spec), "B1.1", 4)
          == 0)
          {
          bmap_descr->hdr->start_gen_sec = sizeof (bmap_hdr_type);
          bmap_descr->hdr->bytes_gen_sec = sizeof (bmap_gen_type);
          bmap_descr->hdr->start_kern_sec = bmap_descr->hdr->start_gen_sec
               + bmap_descr->hdr->bytes_gen_sec;
          bmap_descr->hdr->bytes_kern_rec = sizeof (bmap_pair_type);
          bmap_descr->hdr->start_dir_sec = bmap_descr->hdr->start_kern_sec
               + (bmap_descr->hdr->bytes_kern_rec
               * bmap_descr->hdr->nbr_kern_rec);
          bmap_descr->hdr->bytes_dir_rec = sizeof (bmap_cdir_type);
          bmap_descr->hdr->start_map_sec = bmap_descr->hdr->start_dir_sec
               + (bmap_descr->hdr->bytes_dir_rec
               * bmap_descr->hdr->nbr_dir_rec);
          return ((fix31) SUCCEED);
          }
     else
          return ((fix31) FAIL);
     END




FUNCTION fix31 bmap_autoset_time_stamp (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
#ifdef apollo
     fix31               aplo_clock_high_32();
#endif /* apollo */
#ifdef MSDOS
     fix31               msdos_clock_high_32();
#endif /* MSDOS */
#ifdef IPRO
     fix31               ipro_clock_high_32();
#endif /* interpro */
     
     BEGIN
#ifdef apollo
     bmap_descr->hdr->time_stamp = aplo_clock_high_32 ();
#endif /* apollo */
#ifdef MSDOS
     bmap_descr->hdr->time_stamp = msdos_clock_high_32 ();
#endif /* MSDOS */
#ifdef IPRO
     bmap_descr->hdr->time_stamp = ipro_clock_high_32 ();
#endif /* interpro */
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_below_baseline (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return ((fix31) (bmap_descr->gen->below));
     END




FUNCTION fix31 bmap_bytes_map_sec (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return ((fix31) (bmap_descr->hdr->bytes_map_sec));
     END




FUNCTION bit8 *bmap_char_bitmap (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return ((bit8 *) (bmap_descr->curr_ch->bits));
     END




FUNCTION fix31 bmap_char_bitmap_bytes (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return ((fix31) (bmap_descr->curr_ch->data->n_map));
     END




FUNCTION fix31 bmap_char_bitmap_offset (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return ((fix31) (bmap_descr->curr_ch->data->s_map));
     END




FUNCTION bmap_char_desc_t bmap_first_char (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     bmap_descr->curr_ch = bmap_descr->head_ch;
     return (bmap_descr->head_ch);
     END




FUNCTION bmap_char_desc_t bmap_this_char (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return (bmap_descr->curr_ch);
     END




FUNCTION bmap_char_desc_t bmap_next_char (bmap_descr)

     bmap_font_desc_t   bmap_descr;
     
     DECLARE

     BEGIN
     if (bmap_descr->curr_ch == NULL)
          return (NULL);
     else
          bmap_descr->curr_ch = bmap_descr->curr_ch->next;
     return (bmap_descr->curr_ch);
     END




FUNCTION bmap_pair_desc_t bmap_first_pair (bmap_descr)

     bmap_font_desc_t bmap_descr;

     DECLARE

     BEGIN
     bmap_descr->curr_pair = bmap_descr->head_pair;
     return (bmap_descr->head_pair);
     END




FUNCTION bmap_pair_desc_t bmap_this_pair (bmap_descr)

     bmap_font_desc_t   bmap_descr;     

     DECLARE

     BEGIN
     return (bmap_descr->curr_pair);
     END




FUNCTION bmap_pair_desc_t bmap_next_pair (bmap_descr)

     bmap_font_desc_t bmap_descr;
     
     DECLARE

     BEGIN
     if (bmap_descr->curr_pair == NULL)
          return (NULL);
     else
          bmap_descr->curr_pair = bmap_descr->curr_pair->next;
     return (bmap_descr->curr_pair);
     END




FUNCTION chr8 *bmap_format_version (bmap_descr, version_specifier)

     bmap_font_desc_t   bmap_descr;
     chr8                *version_specifier;

     DECLARE

     BEGIN
     strncpy (version_specifier, bmap_descr->hdr->fmt_versn, 4);
     version_specifier[4] = '\0';
     return (version_specifier);
     END




FUNCTION fix31 bmap_nbr_dir_rec (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return ((fix31) bmap_descr->hdr->nbr_dir_rec);
     END




FUNCTION fix31 bmap_nbr_kern_rec (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return ((fix31) (bmap_descr->hdr->nbr_kern_rec));
     END




FUNCTION fix31 bmap_set_below_baseline (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->gen->below = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_blinker_height (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->gen->blink_hgt = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_blinker_width (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->gen->blink_wid = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_bmap_name (bmap_descr, name)

     bmap_font_desc_t   bmap_descr;
     chr8                *name;

     DECLARE

     BEGIN
     strncpy (bmap_descr->hdr->bmap_name, name, 70);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_bmap_revision (bmap_descr, revision_nbr)

     bmap_font_desc_t   bmap_descr;
     fix31               revision_nbr;

     DECLARE

     BEGIN
     bmap_descr->hdr->bmap_rev = revision_nbr;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_bmap_sequence (bmap_descr, sequence_nbr)

     bmap_font_desc_t   bmap_descr;
     fix31               sequence_nbr;

     DECLARE

     BEGIN
     bmap_descr->hdr->bmap_seq = sequence_nbr;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_bytes_map_sec (bmap_descr, size_in_bytes)

     bmap_font_desc_t   bmap_descr;
     fix31               size_in_bytes;

     DECLARE

     BEGIN
     bmap_descr->hdr->bytes_map_sec = size_in_bytes;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_bitmap_bytes (bmap_descr, size_in_bytes)

     bmap_font_desc_t   bmap_descr;
     fix31               size_in_bytes;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->n_map = size_in_bytes;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_bitmap_offset (bmap_descr, offset_in_bytes)

     bmap_font_desc_t   bmap_descr;
     fix31               offset_in_bytes;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->s_map = offset_in_bytes;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_bs_nbr (bmap_descr, bs_nbr)

     bmap_font_desc_t   bmap_descr;
     fix31               bs_nbr;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->bs_nbr = bs_nbr;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_flags (bmap_descr, flags)

     bmap_font_desc_t   bmap_descr;
     fix31               flags;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->flags = flags;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_horiz_offset (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->h_off = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_raster_height (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->r_hgt = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_raster_width (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->r_wid = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_vert_offset (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->v_off = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_char_set_width (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->curr_ch->data->set_wid = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_empty1 (bmap_descr, string)

     bmap_font_desc_t   bmap_descr;
     chr8                *string;

     DECLARE

     BEGIN
     strncpy (bmap_descr->hdr->empty1, string, 18);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_em_resolution (bmap_descr, resolution)

     bmap_font_desc_t   bmap_descr;
     fix31               resolution;

     DECLARE

     BEGIN
     bmap_descr->gen->em_res = resolution;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_horizontal_res (bmap_descr, pixels_per_inch)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels_per_inch;

     DECLARE

     BEGIN
     bmap_descr->gen->horiz_res = pixels_per_inch;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_layout_id (bmap_descr, identifier)

     bmap_font_desc_t   bmap_descr;
     chr8                *identifier;

     DECLARE

     BEGIN
     strncpy (bmap_descr->hdr->layout_id, identifier, 4);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_layout_sequence (bmap_descr, sequence_nbr)

     bmap_font_desc_t   bmap_descr;
     fix31               sequence_nbr;

     DECLARE

     BEGIN
     bmap_descr->hdr->layout_seq = sequence_nbr;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_nbr_dir_rec (bmap_descr, nbr_records)

     bmap_font_desc_t   bmap_descr;
     fix31               nbr_records;

     DECLARE

     BEGIN
     bmap_descr->hdr->nbr_dir_rec = nbr_records;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_nbr_kern_rec (bmap_descr, nbr_records)

     bmap_font_desc_t   bmap_descr;
     fix31               nbr_records;

     DECLARE

     BEGIN
     bmap_descr->hdr->nbr_kern_rec = nbr_records;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_outline_id (bmap_descr, identifier)

     bmap_font_desc_t   bmap_descr;
     chr8                *identifier;

     DECLARE

     BEGIN
     strncpy (bmap_descr->hdr->outl_id, identifier, 4);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_outline_name (bmap_descr, name)

     bmap_font_desc_t   bmap_descr;
     chr8                *name;

     DECLARE

     BEGIN
     strncpy (bmap_descr->hdr->outl_name, name, 70);
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_outline_revision (bmap_descr, revision_nbr)

     bmap_font_desc_t   bmap_descr;
     fix31               revision_nbr;

     DECLARE

     BEGIN
     bmap_descr->hdr->outl_rev = revision_nbr;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_point_size (bmap_descr, points)

     bmap_font_desc_t   bmap_descr;
     fix31               points;

     DECLARE

     BEGIN
     bmap_descr->gen->pt_size = points;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_space_width (bmap_descr, pixels)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;

     DECLARE

     BEGIN
     bmap_descr->gen->space_wid = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_track (bmap_descr, pixels, index)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels;
     fix31               index;

     DECLARE

     BEGIN
     bmap_descr->gen->track[index] = pixels;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_set_vertical_res (bmap_descr, pixels_per_inch)

     bmap_font_desc_t   bmap_descr;
     fix31               pixels_per_inch;

     DECLARE

     BEGIN
     bmap_descr->gen->vert_res = pixels_per_inch;
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_start_gen_sec (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return (bmap_descr->hdr->start_gen_sec);
     END




FUNCTION fix31 bmap_start_kern_sec (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return (bmap_descr->hdr->start_kern_sec);
     END




FUNCTION fix31 bmap_start_dir_sec (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return (bmap_descr->hdr->start_dir_sec);
     END




FUNCTION fix31 bmap_start_map_sec (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE

     BEGIN
     return (bmap_descr->hdr->start_map_sec);
     END


FUNCTION fix31 bmap_initiate ()

     DECLARE
#ifdef apollo
     void    aplo_memory_init();
#endif /* apollo */

     BEGIN
#ifdef BMAPS_IN_TEMP_FILE
     if (!start_temp_images_file())
        return ((fix31) FAIL);
#endif /* defined BMAPS_IN_TEMP_FILE */

#ifdef apollo
     aplo_memory_init();
#endif /* apollo */

     return (SUCCEED);
     END




FUNCTION fix31 bmap_terminate ()

     DECLARE
     
     BEGIN
     return (SUCCEED);
     END




FUNCTION bmap_font_desc_t bmap_create_bmap ()

     DECLARE
     bmap_font_desc_t   bmap_descr;
     
     BEGIN
     /* allocate font node */
     if ((bmap_descr = (bmap_font_desc_t) malloc ((ufix)sizeof (bmap_font_node_type)))
            == NULL)
          {
          fprintf (stderr, "bmap_create_bmap: unable to malloc bmap_descr\n");
          return (NULL);
          }

     /* allocate header section */
     if ((bmap_descr->hdr = (bmap_hdr_type *) malloc (sizeof (bmap_hdr_type)))
            == NULL)
          {
          fprintf (stderr, "bmap_create_bmap: unable to malloc header section\n");
          return (NULL);
          }

     /* allocate general information section */
     if ((bmap_descr->gen = (bmap_gen_type *) malloc (sizeof (bmap_gen_type)))
            == NULL)
          {
          fprintf (stderr, "bmap_create_bmap: unable to malloc general info section\n");
          return (NULL);
          }

     /* initialize pointers */
     bmap_descr->head_pair = NULL;
     bmap_descr->curr_pair = NULL;
     bmap_descr->head_ch   = NULL;
     bmap_descr->curr_ch   = NULL;

     /* initialize values */
     bmap_autoset_format_version  (bmap_descr);
     bmap_set_outline_id          (bmap_descr, "\0\0\0\0");
     bmap_set_outline_name        (bmap_descr, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0");
     bmap_autoset_mfg_date        (bmap_descr);
     bmap_set_bmap_name           (bmap_descr, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0");
     bmap_set_outline_revision    (bmap_descr, (fix31) 0);

     bmap_autoset_start_byte_nbr  (bmap_descr, (fix31) 0, (fix31) 0, (fix31) 0);

     bmap_set_layout_id           (bmap_descr, "\0\0\0\0");
     bmap_set_layout_sequence     (bmap_descr, (fix31) 0);
     bmap_set_bmap_revision       (bmap_descr, (fix31) 0);
     bmap_set_bmap_sequence       (bmap_descr, (fix31) 0);
     bmap_autoset_time_stamp      (bmap_descr);
     bmap_set_empty1              (bmap_descr, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0");
     bmap_autoset_copyright       (bmap_descr);
     bmap_set_em_resolution       (bmap_descr, (fix31) 0);
     bmap_set_below_baseline      (bmap_descr, (fix31) 0);
     bmap_set_blinker_width       (bmap_descr, (fix31) 0);
     bmap_set_blinker_height      (bmap_descr, (fix31) 0);
     bmap_set_space_width         (bmap_descr, (fix31) 0);
     bmap_set_track               (bmap_descr, (fix31) 0, (fix31) 0);
     bmap_set_track               (bmap_descr, (fix31) 0, (fix31) 1);
     bmap_set_track               (bmap_descr, (fix31) 0, (fix31) 2);
     bmap_set_track               (bmap_descr, (fix31) 0, (fix31) 3);
     bmap_set_point_size          (bmap_descr, (fix31) 0);
     bmap_set_vertical_res        (bmap_descr, (fix31) 0);
     bmap_set_horizontal_res      (bmap_descr, (fix31) 0);

     return (bmap_descr);
     END




FUNCTION fix31 bmap_free (bmap_descr)

     bmap_font_desc_t   bmap_descr;         /* ptr to font control structure */

     DECLARE
     bmap_char_desc_t   bmap_first_char();
     bmap_pair_desc_t   bmap_first_pair();
     bmap_char_desc_t   bmap_this_char();
     bmap_pair_desc_t   bmap_this_pair();
     bmap_char_desc_t   bmap_next_char();
     bmap_pair_desc_t   bmap_next_pair();
     bmap_char_desc_t   prev_char;
     bmap_pair_desc_t   prev_pair;
     
     BEGIN
     /* free header section */
     free ((chr8 *) bmap_descr->hdr);

     /* free general information section */
     free ((chr8 *) bmap_descr->gen);

     /* free each kern pair data node */
     /* it would SEEM more straightforward to free each node directly, but */
     /* this would mean finding next node by looking into memory that you */
     /* just freed.  Thus, the need to free the PREVIOUS node */
     if (bmap_nbr_kern_rec (bmap_descr) > 0)
          {
          for (prev_pair = 0, bmap_first_pair (bmap_descr);
               bmap_this_pair (bmap_descr) != 0;
               bmap_next_pair (bmap_descr))
               {
               if (prev_pair != 0)
                    free ((chr8 *) prev_pair);
               prev_pair = bmap_this_pair (bmap_descr);
               }
          free ((chr8 *) prev_pair);
          }

     if (bmap_nbr_dir_rec (bmap_descr) > 0)
          {
          /* free all memory pointed to in character directory */
          /* NOTE: no other directory should point to this data or you lose */
          for (bmap_first_char (bmap_descr);
               bmap_this_char (bmap_descr) != 0;
               bmap_next_char (bmap_descr))
               {
/*              printf ("about to free: data=%d bits=%d\n",
                    bmap_descr->curr_ch->data,
                    bmap_descr->curr_ch->bits);
*/
               if (bmap_descr->curr_ch->data)   /* in case the bitmap has been freed */
                   free ((chr8 *) bmap_descr->curr_ch->data);
               if (bmap_descr->curr_ch->bits)   /* in case the bitmap has been freed */
                   free ((chr8 *) bmap_descr->curr_ch->bits);
               }
          /* free all character directory entries */
          /* same problem here as with freeing kern data nodes */
          for (prev_char = 0, bmap_first_char (bmap_descr);
               bmap_this_char (bmap_descr) != 0;
               bmap_next_char (bmap_descr))
               {
               if (prev_char != 0)
                    free ((chr8 *) prev_char);
               prev_char = bmap_this_char (bmap_descr);
               }
          free ((chr8 *) prev_char);
          }

     /* free font node */
     free ((chr8 *) bmap_descr);
#ifdef BMAPS_IN_TEMP_FILE
    /* close and erase temp file */
    if (!end_temp_images_file())
        return ((fix31) FAIL);
#endif /* defined BMAPS_IN_TEMP_FILE */

     return (SUCCEED);
     END




#ifdef m68000
FUNCTION fix15 swap10 (number)

     fix15     number;

     DECLARE
     chr8      temp,
               *ptr;
     
     BEGIN
     ptr = (chr8 *) (&number);
     temp = ptr[0];
     ptr[0] = ptr[1];
     ptr[1] = temp;
     return (number);
     END
#endif /* defined m68000 */




#ifdef m68000
FUNCTION fix31 swap3210 (number)

     fix31     number;

     DECLARE
     chr8      temp,
               *ptr;
     
     BEGIN
     ptr = (chr8 *) (&number);
     temp = ptr[0];
     ptr[0] = ptr[3];
     ptr[3] = temp;
     temp = ptr[1];
     ptr[1] = ptr[2];
     ptr[2] = temp;
     return (number);
     END
#endif /* defined m68000 */




#ifdef m68000
FUNCTION fix31 bmap_swap_hdr_bytes (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     fix31     swap3210();
     fix15     swap10();

     BEGIN
     bmap_descr->hdr->outl_rev       = swap10   (bmap_descr->hdr->outl_rev);
     bmap_descr->hdr->start_gen_sec  = swap3210 (bmap_descr->hdr->start_gen_sec);
     bmap_descr->hdr->bytes_gen_sec  = swap10   (bmap_descr->hdr->bytes_gen_sec);
     bmap_descr->hdr->start_kern_sec = swap3210 (bmap_descr->hdr->start_kern_sec);
     bmap_descr->hdr->bytes_kern_rec = swap10   (bmap_descr->hdr->bytes_kern_rec);
     bmap_descr->hdr->nbr_kern_rec   = swap10   (bmap_descr->hdr->nbr_kern_rec);
     bmap_descr->hdr->start_dir_sec  = swap3210 (bmap_descr->hdr->start_dir_sec);
     bmap_descr->hdr->bytes_dir_rec  = swap10   (bmap_descr->hdr->bytes_dir_rec);
     bmap_descr->hdr->nbr_dir_rec    = swap10   (bmap_descr->hdr->nbr_dir_rec);
     bmap_descr->hdr->start_map_sec  = swap3210 (bmap_descr->hdr->start_map_sec);
     bmap_descr->hdr->bytes_map_sec  = swap3210 (bmap_descr->hdr->bytes_map_sec);
     bmap_descr->hdr->layout_seq     = swap10   (bmap_descr->hdr->layout_seq);
     bmap_descr->hdr->bmap_rev       = swap10   (bmap_descr->hdr->bmap_rev);
     bmap_descr->hdr->bmap_seq       = swap10   (bmap_descr->hdr->bmap_seq);
     bmap_descr->hdr->time_stamp     = swap3210 (bmap_descr->hdr->time_stamp);
     return ((fix31) SUCCEED);
     END
#endif /* defined m68000 */




#ifdef m68000
FUNCTION fix31 bmap_swap_gen_bytes (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     fix15     swap10();
     
     BEGIN
     bmap_descr->gen->em_res    = swap10 (bmap_descr->gen->em_res);
     bmap_descr->gen->below     = swap10 (bmap_descr->gen->below);
     bmap_descr->gen->blink_wid = swap10 (bmap_descr->gen->blink_wid);
     bmap_descr->gen->blink_hgt = swap10 (bmap_descr->gen->blink_hgt);
     bmap_descr->gen->space_wid = swap10 (bmap_descr->gen->space_wid);
     bmap_descr->gen->track[0]  = swap10 (bmap_descr->gen->track[0]);
     bmap_descr->gen->track[1]  = swap10 (bmap_descr->gen->track[1]);
     bmap_descr->gen->track[2]  = swap10 (bmap_descr->gen->track[2]);
     bmap_descr->gen->track[3]  = swap10 (bmap_descr->gen->track[3]);
     bmap_descr->gen->pt_size   = swap10 (bmap_descr->gen->pt_size);
     bmap_descr->gen->vert_res  = swap10 (bmap_descr->gen->vert_res);
     bmap_descr->gen->horiz_res = swap10 (bmap_descr->gen->horiz_res);
     return ((fix31) SUCCEED);
     END
#endif /* defined m68000 */




#ifdef m68000
FUNCTION bmap_swap_kern_bytes (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     bmap_pair_desc_t   bmap_first_pair();
     bmap_pair_desc_t   bmap_next_pair();
     bmap_pair_desc_t   bmap_this_pair();
     bmap_pair_desc_t   pair;
     
     BEGIN
     for (bmap_first_pair (bmap_descr);
          (pair = bmap_this_pair (bmap_descr)) != 0;
          bmap_next_pair (bmap_descr))
          {
          pair->data.c1   = swap10 (pair->data.c1);
          pair->data.c2   = swap10 (pair->data.c2);
          pair->data.kern = swap10 (pair->data.kern);
          }
     return ((fix31) SUCCEED);
     END
#endif /* defined m68000 */




#ifdef m68000
FUNCTION bmap_swap_all_dir_bytes (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     fix31               swap3210();
     fix15               swap10();
     bmap_char_desc_t   bmap_first_char();
     bmap_char_desc_t   bmap_next_char();
     bmap_char_desc_t   bmap_this_char();
     bmap_char_desc_t   ch;
     
     BEGIN
     for (bmap_first_char (bmap_descr);
          (ch = bmap_this_char (bmap_descr)) != 0;
          bmap_next_char (bmap_descr))
          {
          ch->data->bs_nbr  = swap10   (ch->data->bs_nbr);
          ch->data->alt     = swap10   (ch->data->alt);
          ch->data->h_off   = swap10   (ch->data->h_off);
          ch->data->v_off   = swap10   (ch->data->v_off);
          ch->data->r_wid   = swap10   (ch->data->r_wid);
          ch->data->r_hgt   = swap10   (ch->data->r_hgt);
          ch->data->set_wid = swap10   (ch->data->set_wid);
          ch->data->s_map   = swap3210 (ch->data->s_map);
          ch->data->n_map   = swap10   (ch->data->n_map);   
          ch->data->flags   = swap10   (ch->data->flags);
          }
     return ((fix31) SUCCEED);
     END
#endif /* defined m68000 */




#ifdef m68000
FUNCTION bmap_swap_critical_dir_bytes (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     fix31               swap3210();
     fix15               swap10();
     bmap_char_desc_t   bmap_first_char();
     bmap_char_desc_t   bmap_next_char();
     bmap_char_desc_t   bmap_this_char();
     bmap_char_desc_t   ch;
     
     BEGIN
     for (bmap_first_char (bmap_descr);
          (ch = bmap_this_char (bmap_descr)) != 0;
          bmap_next_char (bmap_descr))
          {
          ch->data->s_map   = swap3210 (ch->data->s_map);
          ch->data->n_map   = swap10   (ch->data->n_map);   
          }
     return ((fix31) SUCCEED);
     END
#endif /* defined m68000 */




FUNCTION bmap_font_desc_t bmap_unload (bmap_descr, pathname, scratch)

     bmap_font_desc_t   bmap_descr;
     chr8                *pathname;
     bool32              scratch;

     DECLARE
     fix                 fdesc;
     fix31 bmap_write_hdr_sec ();
     fix31 bmap_write_gen_sec ();
     fix31 bmap_write_kern_sec ();
     fix31 bmap_write_dir_sec ();
     fix31 bmap_write_map_sec ();

     BEGIN
     if (pathname[0] != '\0')
          {
/*          if ((fdesc = creat (pathname, (fix) 0222)) < 0)  changed for PC needs djm */
          if ((fdesc = open (pathname, WRITE, (fix) OMODE)) < 0)
               {
               fprintf (stderr, "bmap_unload: unable to open \"%s\"\n", pathname);
               return (bmap_descr);
               }
          /* write data to file */
          if (bmap_write_hdr_sec (bmap_descr, fdesc) == FAIL)
               return (bmap_descr);
          if (bmap_write_gen_sec (bmap_descr, fdesc, scratch) == FAIL)
               return (bmap_descr);
          if (bmap_write_kern_sec (bmap_descr, fdesc, scratch) == FAIL)
               return (bmap_descr);
          if (bmap_write_dir_sec (bmap_descr, fdesc, scratch) == FAIL)
               return (bmap_descr);
          if (bmap_write_map_sec (bmap_descr, fdesc, scratch) == FAIL)
               return (bmap_descr);
          if (close (fdesc) != SUCCEED)
               {
               fprintf (stderr, "bmap_unload: unable to close \"%s\"\n", pathname);
               return (bmap_descr);
               }
          if (! scratch)
               return (bmap_descr);
          }
     bmap_free (bmap_descr);
     return (NULL);
     END





FUNCTION fix31 bmap_write_hdr_sec (bmap_descr, fdesc)

     bmap_font_desc_t   bmap_descr;    /* ptr to font control structure */
     fix                 fdesc;

     DECLARE

     BEGIN
#ifdef m68000
     bmap_swap_hdr_bytes (bmap_descr);
#endif /* defined m68000 */
     /* position file */
     if (lseek (fdesc, (fix31) 0, (fix) 0) != 0)
          {
          fprintf (stderr, "bmap_write_header_sec: unable to lseek header section\n");
          return ((fix31) FAIL);
          }
/***** if (write (fdesc, (char *)(bmap_descr->hdr), (int)sizeof (bmap_hdr_type)) != sizeof (bmap_hdr_type))*/
	if (write_bmap_hdr_struct (fdesc, bmap_descr->hdr) == FAIL)
          {
          fprintf (stderr, "bmap_write_header_sec: unable to write header section\n");
          return ((fix31) FAIL);
          }

#ifdef m68000
     bmap_swap_hdr_bytes (bmap_descr);
#endif /* defined m68000 */
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_write_gen_sec (bmap_descr, fdesc, scratch)

     bmap_font_desc_t   bmap_descr;    /* ptr to font control structure */
     fix                 fdesc;
     bool32              scratch;

     DECLARE

     BEGIN
#ifdef m68000
     bmap_swap_gen_bytes (bmap_descr);
#endif /* defined m68000 */
     /* position file */
     if (lseek (fdesc, bmap_start_gen_sec (bmap_descr), (fix) 0)
          != bmap_start_gen_sec (bmap_descr))
          {
          fprintf (stderr, "bmap_write_gen_sec: unable to malloc general info section\n");
          return ((fix31) FAIL);
          }

     /* write data from file */
/***** if (write (fdesc, (char *)(bmap_descr->gen), (int)sizeof (bmap_gen_type)) != sizeof (bmap_gen_type))*/
	if (write_bmap_gen_struct (fdesc, bmap_descr->gen) == FAIL)
          {
          fprintf (stderr, "bmap_write_gen_sec: unable to write general info section\n");
          return ((fix31) FAIL);
          }

#ifdef m68000
     if (! scratch)
          bmap_swap_gen_bytes (bmap_descr);
#endif /* defined m68000 */
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_write_kern_sec (bmap_descr, fdesc, scratch)

     bmap_font_desc_t   bmap_descr;    /* ptr to font control structure */
     fix                 fdesc;
     bool32              scratch;

     DECLARE
     bmap_pair_desc_t   pair;
     bmap_pair_desc_t   bmap_first_pair();
     bmap_pair_desc_t   bmap_this_pair();
     bmap_pair_desc_t   bmap_next_pair();

     BEGIN
#ifdef m68000
     bmap_swap_kern_bytes (bmap_descr);
#endif /* defined m68000 */
     /* position file */
     if (lseek (fdesc, bmap_start_kern_sec (bmap_descr), (fix) 0)
          != bmap_start_kern_sec (bmap_descr))
          {
          fprintf (stderr, "bmap_write_kern_sec: unable to malloc kern info section\n");
          return ((fix31) FAIL);
          }
     /* for each kern pair, write data to file */
     if (bmap_nbr_kern_rec (bmap_descr) > 0)
          {
          if (lseek (fdesc, bmap_start_kern_sec (bmap_descr), (fix) 0)  !=
                 bmap_start_kern_sec (bmap_descr))
               {
               fprintf (stderr, "bmap_write_kern_sec: unable to lseek kern section\n");
               return ((fix31) FAIL);
               }
          for (bmap_first_pair (bmap_descr);
               (pair = bmap_this_pair (bmap_descr)) != 0;
               bmap_next_pair (bmap_descr))
               {
/***** if (write (fdesc, (char *)(&pair->data), (int)sizeof (bmap_pair_type)) != sizeof (bmap_pair_type))*/
             if (write_bmap_pair_struct (fdesc, &pair->data) == FAIL)
                    {
                    fprintf (stderr, "bmap_write_kern_sec: unable to write kern record\n");
                    return ((fix31) FAIL);
                    }
               }
          }
#ifdef m68000
     if (! scratch)
          bmap_swap_kern_bytes (bmap_descr);
#endif /* defined m68000 */
     return ((fix31) SUCCEED);
     END




FUNCTION fix31 bmap_write_dir_sec (bmap_descr, fdesc, scratch)

     bmap_font_desc_t   bmap_descr;    /* ptr to font control structure */
     fix                 fdesc;
     bool32              scratch;

     DECLARE
     bmap_char_desc_t   ch;
     bmap_char_desc_t   bmap_first_char();
     bmap_char_desc_t   bmap_this_char();
     bmap_char_desc_t   bmap_next_char();

     BEGIN
#ifdef m68000
     bmap_swap_all_dir_bytes (bmap_descr);
#endif /* defined m68000 */
     /* position file */
     if (lseek (fdesc, bmap_start_dir_sec (bmap_descr), (fix) 0)
          != bmap_start_dir_sec (bmap_descr))
          {
          fprintf (stderr, "bmap_write_dir_sec: unable to lseek directory section\n");
          return ((fix31) FAIL);
          }
     /* for each character, write data to file */
     if (bmap_nbr_dir_rec (bmap_descr) > 0)
          {
          for (bmap_first_char (bmap_descr);
               (ch = bmap_this_char (bmap_descr)) != 0;
               bmap_next_char (bmap_descr))
               {
               if (write_bmap_cdir_struct (fdesc, (char *)ch->data) == FAIL)
/**** if (write (fdesc, (char *)(ch->data), (int)sizeof (bmap_cdir_type)) != sizeof (bmap_cdir_type))*/
                    {
                    fprintf (stderr, "bmap_write_dir_sec: unable to write record\n");
                    return ((fix31) FAIL);
                    }
               }
          }
#ifdef m68000
     if (! scratch)
          bmap_swap_all_dir_bytes (bmap_descr);
     else
          bmap_swap_critical_dir_bytes (bmap_descr);
#endif /* defined m68000 */
     return ((fix31) SUCCEED);
     END





FUNCTION fix31 bmap_write_map_sec (bmap_descr, fdesc, scratch)

     bmap_font_desc_t   bmap_descr;    /* ptr to font control structure */
     fix                 fdesc;
     bool32              scratch;

     DECLARE
     bmap_char_desc_t   bmap_first_char();
     bmap_char_desc_t   bmap_this_char();
     bmap_char_desc_t   bmap_next_char();
     bit8               *bmap_char_bitmap();
     bit8               *bmap_new_map ();

     BEGIN
#ifdef BMAPS_IN_TEMP_FILE
     if (!examine_temp_images_file())
        return ((fix31) FAIL);
#endif /* defined BMAPS_IN_TEMP_FILE */
     /* for each character, allocate and load bitmap data */
     if (lseek (fdesc, bmap_start_map_sec (bmap_descr), (fix) 0)
         != bmap_start_map_sec (bmap_descr))
          {
          fprintf (stderr, "bmap_write_map_sec: unable to lseek bitmap section\n");
          return ((fix31) FAIL);
          }
     for (bmap_first_char (bmap_descr);
          bmap_this_char (bmap_descr) != 0;
          bmap_next_char (bmap_descr))
          {
#ifdef BMAPS_IN_TEMP_FILE
            /* read in the next bitmap from the temp file */
            if (!(bmap_descr->curr_ch->bits 
                  = bmap_new_map(bmap_char_bitmap_bytes (bmap_descr))))
                {
                fprintf (stderr,"Can't allocate new bitmap\n");
                return ((fix31) FAIL);
                }
            if (read (temp_images_file, (char *)bmap_char_bitmap (bmap_descr),
                     (int) (bmap_char_bitmap_bytes (bmap_descr)))
                   != bmap_char_bitmap_bytes (bmap_descr))
                {
                fprintf (stderr,"Can't read bitmap from temp file\n");
                return ((fix31) FAIL);
                }
#endif /* defined BMAPS_IN_TEMP_FILE */
          if (write (fdesc, (char *)bmap_char_bitmap (bmap_descr),
                     (int) (bmap_char_bitmap_bytes (bmap_descr)))
               != bmap_char_bitmap_bytes (bmap_descr))
               {
               fprintf (stderr, "bmap_write_map_sec: unable to write bitmap\n");
               return ((fix31) FAIL);
               }
#ifdef BMAPS_IN_TEMP_FILE
          bmap_descr->curr_ch->bits = NULL;
#endif /* defined BMAPS_IN_TEMP_FILE */
          }
     return ((fix31) SUCCEED);
     END


FUNCTION fix31 bmap_hierarchical_update (bmap_descr)

     bmap_font_desc_t   bmap_descr;

     DECLARE
     fix31               i;
     bmap_pair_desc_t   bmap_first_pair();
     bmap_pair_desc_t   bmap_this_pair();
     bmap_pair_desc_t   bmap_next_pair();
     bmap_char_desc_t   bmap_first_char();
     bmap_char_desc_t   bmap_this_char();
     bmap_char_desc_t   bmap_next_char();
     fix31               prev_char_bitmap_bytes;
     fix31               prev_char_bitmap_offset;

     BEGIN
     /* update kern section: affirm number of nodes == header number */
     for (i = 0, bmap_first_pair (bmap_descr);
          bmap_this_pair (bmap_descr) != 0; i++, bmap_next_pair (bmap_descr))
          ;
     bmap_set_nbr_kern_rec (bmap_descr, i);

     /* update character section: affirm number of nodes == header number */
     for (i = 0, bmap_first_char (bmap_descr);
          bmap_this_char (bmap_descr) != 0; i++, bmap_next_char (bmap_descr))
          {
          if (i == 0)
               {
               bmap_set_char_bitmap_offset (bmap_descr, (fix31) 0);
               prev_char_bitmap_offset = 0;
               prev_char_bitmap_bytes = bmap_char_bitmap_bytes (bmap_descr);
               }
          else
               {
               bmap_set_char_bitmap_offset (bmap_descr,
                    prev_char_bitmap_offset + prev_char_bitmap_bytes);
               prev_char_bitmap_offset = bmap_char_bitmap_offset (bmap_descr);
               prev_char_bitmap_bytes = bmap_char_bitmap_bytes (bmap_descr);
               }
          }

     bmap_set_nbr_dir_rec (bmap_descr, i);
     bmap_set_bytes_map_sec
          (bmap_descr, prev_char_bitmap_offset + prev_char_bitmap_bytes);

     /* update header section summary */
     bmap_autoset_start_byte_nbr (bmap_descr,
          bmap_nbr_kern_rec  (bmap_descr),
          bmap_nbr_dir_rec   (bmap_descr),
          bmap_bytes_map_sec (bmap_descr));

     END




FUNCTION fix31 bmap_attach_map (bmap_descr, map_ptr)

     bmap_font_desc_t  bmap_descr;
     bit8                *map_ptr;

     DECLARE

     BEGIN
#ifdef BMAPS_IN_TEMP_FILE
     if (write (temp_images_file, (char *)map_ptr,
            (int) (bmap_char_bitmap_bytes (bmap_descr)))
            != bmap_char_bitmap_bytes (bmap_descr))
          {
          fprintf (stderr, "bmap_attach_map: unable to write bitmap to temp file\n");
          return ((fix31) FAIL);
          }
     bmap_descr->curr_ch->bits = NULL;
#else /* bmaps in memory */
     bmap_descr->curr_ch->bits = map_ptr;
#endif /* if defined BMAPS_IN_MEMORY */
     return (SUCCEED);
     END




FUNCTION bmap_pair_desc_t bmap_insert_kern_rec (bmap_descr, pair_descr)

     bmap_font_desc_t   bmap_descr;
     bmap_pair_desc_t   pair_descr;

     DECLARE
    
     BEGIN
     if (bmap_descr->head_pair == NULL)
          {
          bmap_descr->head_pair = pair_descr;
          bmap_descr->curr_pair = pair_descr;
          bmap_descr->curr_pair->next = NULL;
          }
     else
          {
          if (bmap_descr->curr_pair == NULL)
               bmap_descr->curr_pair = bmap_descr->head_pair;
          pair_descr->next = bmap_descr->curr_pair->next;
          bmap_descr->curr_pair->next = pair_descr;
          bmap_descr->curr_pair = pair_descr;
          }
     return (bmap_descr->curr_pair);
     END




FUNCTION bmap_char_desc_t bmap_insert_dir_rec (bmap_descr, char_descr)

     /*
      *   inserts new char after current char, makes current char be new char
      */

     bmap_font_desc_t   bmap_descr;
     bmap_char_desc_t   char_descr;

     DECLARE
    
     BEGIN
     if (bmap_descr->head_ch == NULL)
          {
          bmap_descr->head_ch = char_descr;
          bmap_descr->curr_ch = char_descr;
          bmap_descr->curr_ch->next = NULL;
          }
     else
          {
          if (bmap_descr->curr_ch == NULL)
               bmap_descr->curr_ch = bmap_descr->head_ch;
          char_descr->next = bmap_descr->curr_ch->next;
          bmap_descr->curr_ch->next = char_descr;
          bmap_descr->curr_ch = char_descr;
          }
     return (bmap_descr->curr_ch);
     END




FUNCTION bmap_pair_desc_t bmap_new_kern_rec (chr1, chr2, kern_value)

     fix31               chr1;
     fix31               chr2;
     fix31               kern_value;

     DECLARE
     bmap_pair_desc_t   pair_descr;
     
     BEGIN
     if ((pair_descr = (bmap_pair_desc_t) malloc
          (sizeof (bmap_pair_node_type))) == 0)
          {
          fprintf (stderr, "bmap_new_kern_rec: unable to malloc kern node\n");
          return ((bmap_pair_desc_t) NULL);
          }
     pair_descr->data.c1   = chr1;
     pair_descr->data.c2   = chr2;
     pair_descr->data.kern = kern_value;
     return (pair_descr);
     END




FUNCTION bmap_char_desc_t bmap_new_dir_rec ()

     DECLARE
     bmap_char_desc_t   char_descr;
     
     BEGIN
     if ((char_descr = (bmap_char_desc_t) malloc
          ((ufix)sizeof (bmap_char_node_type))) == NULL)
          {
          fprintf (stderr, "bmap_new_dir_rec: unable to malloc character node\n");
          return ((bmap_char_desc_t) NULL);
          }
     if ((char_descr->data = (bmap_cdir_type *) malloc
          ((ufix)sizeof (bmap_cdir_type))) == NULL)
          {
          fprintf (stderr, "bmap_new_dir_rec: unable to malloc directory record\n");
          return ((bmap_char_desc_t) NULL);
          }
     char_descr->bits          = NULL;
     char_descr->data->bs_nbr  = 0;
     char_descr->data->alt     = 0;
     char_descr->data->h_off   = 0;
     char_descr->data->v_off   = 0;
     char_descr->data->r_wid   = 0;
     char_descr->data->r_hgt   = 0;
     char_descr->data->set_wid = 0;
     char_descr->data->s_map   = 0;
     char_descr->data->n_map   = 0;
     char_descr->data->flags   = 0;

     return (char_descr);
     END




FUNCTION bit8 *bmap_new_map (size_in_bytes)

     fix31     size_in_bytes;

     BEGIN

     DECLARE
#ifdef BMAPS_IN_TEMP_FILE
     if (size_in_bytes > MAX_STORED_BMAP)
         return (NULL);
     else
         return ((bit8 *)temp_bmap);
#else /* bmaps in memory */
     return ((bit8 *) malloc ((ufix) size_in_bytes));
#endif /* if defined BMAPS_IN_TEMP_FILE */
     END

/***************************************************************

The following 'write' routines were written by Scott Heeschen
so that fontware packs the bitmap structures as it writes them
to a file.  This is the only way to guarantee that there will
be no alignment problems.

These routines write structures out piece by piece.  Some machines
force certain types of variables to be aligned on even or word
boundaries.  This makes structures 'expand', leaving blanks between
certain members so that the alignment works out.  Writing the
members out one by one avoids the defferences in alignment from
machine to machine.

These are the write routines:

	write_bmap_hdr_struct - writes bmap_hdr_type
	write_bmap_gen_struct - writes bmap_gen_type
	write_bmap_pair_struct - writes bmap_pair_type
	write_bmap_cdir_struct - writes bmap_cdir_type

***************************************************************/

write_bmap_hdr_struct (fdesc, hdr)
int fdesc;
bmap_hdr_type *hdr;
{
    int num_bytes;

    num_bytes = write (fdesc, &(hdr->fmt_versn[0]), sizeof(chr8) * 4);
    num_bytes += write (fdesc, &(hdr->outl_id[0]), sizeof(chr8) * 4);
    num_bytes += write (fdesc, &(hdr->outl_name[0]), sizeof(chr8) * 70);
    num_bytes += write (fdesc, &(hdr->mfg_date[0]), sizeof(chr8) * 10);
    num_bytes += write (fdesc, &(hdr->bmap_name[0]), sizeof(chr8) * 70);
    num_bytes += write (fdesc, &(hdr->outl_rev), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->start_gen_sec), sizeof(fix31) * 1);
    num_bytes += write (fdesc, &(hdr->bytes_gen_sec), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->start_kern_sec), sizeof(fix31) * 1);
    num_bytes += write (fdesc, &(hdr->bytes_kern_rec), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->nbr_kern_rec), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->start_dir_sec), sizeof(fix31) * 1);
    num_bytes += write (fdesc, &(hdr->bytes_dir_rec), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->nbr_dir_rec), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->start_map_sec), sizeof(fix31) * 1);
    num_bytes += write (fdesc, &(hdr->bytes_map_sec), sizeof(fix31) * 1);
    num_bytes += write (fdesc, &(hdr->layout_id[0]), sizeof(chr8) * 4);
    num_bytes += write (fdesc, &(hdr->layout_seq), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->bmap_rev), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->bmap_seq), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(hdr->time_stamp), sizeof(fix31) * 1);
    num_bytes += write (fdesc, &(hdr->empty1[0]), sizeof(chr8) * 18);
    num_bytes += write (fdesc, &(hdr->copyrt[0]), sizeof(chr8) * 34);

    if (num_bytes == 256)
	return (SUCCEED);
    else
	return (FAIL);
}

write_bmap_gen_struct (fdesc, info)
int fdesc;
bmap_gen_type *info;
{
    int num_bytes;

    num_bytes = write (fdesc, &(info->em_res), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->below), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->blink_wid), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->blink_hgt), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->space_wid), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->track[0]), sizeof(fix15) * 4);
    num_bytes += write (fdesc, &(info->pt_size), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->vert_res), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->horiz_res), sizeof(fix15) * 1);

    if (num_bytes == 24)
	return (SUCCEED);
    else
	return (FAIL);
}

write_bmap_pair_struct (fdesc, kernPair)
int fdesc;
bmap_pair_type *kernPair;
{
    int num_bytes;

    num_bytes = write (fdesc, &(kernPair->c1), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(kernPair->c2), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(kernPair->kern), sizeof(fix15) * 1);

    if (num_bytes == 6)
	return (SUCCEED);
    else
	return (FAIL);
}

write_bmap_cdir_struct (fdesc, info)
int fdesc;
bmap_cdir_type *info;
{
    int num_bytes;

    num_bytes = write (fdesc, &(info->bs_nbr), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->alt), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->h_off), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->v_off), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->r_wid), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->r_hgt), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->set_wid), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->s_map), sizeof(fix31) * 1);
    num_bytes += write (fdesc, &(info->n_map), sizeof(fix15) * 1);
    num_bytes += write (fdesc, &(info->flags), sizeof(fix15) * 1);

    if (num_bytes == 22)
	return (SUCCEED);
    else
	return (FAIL);
}
