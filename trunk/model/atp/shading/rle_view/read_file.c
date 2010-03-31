#include	<tools.h>
#include	<stdio.h>
#include	"math.h"
#include	"rle_view.h"

#define GS_TO_GXGZ_VLT_OFFSET 14

extern short true_color;
extern int   batch;


/*--- load_rle_file_vlt -------------------------------------------------*/

static void load_rle_file_vlt( hdr26, image, vs_no, term_planes )

	struct HEADER_BLOCK *hdr26;
	struct image_info   *image;
	int                  vs_no;
	int                  term_planes;

/*
DESCRIPTION
	This function loads the VLT stored in an RLE file into the hardware
	adjusting for files that were saved on a machine with a different
	number of planes than the machine on which the file is to be
	displayed.
*/

	{
#ifdef X11
        fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	int             ii;
	struct vlt_slot vlt[512];

	if ( (hdr26->planes > 6) && ( term_planes > 6) )
	   {
	   /* RLE file saved on a GX/GZ machine and  */
	   /* we are recalling it on a GX/GZ machine */
	   Readvlt( vs_no, vlt, 256, 0 );

	   for ( ii = 15; ii < image->vlt_size - 1; ii++ )
	      {
	      vlt[ii].v_slot = ii;
	      vlt[ii].v_red = hdr26->ctbl[ii][0] << 8;
	      vlt[ii].v_green = hdr26->ctbl[ii][1] << 8;
	      vlt[ii].v_blue = hdr26->ctbl[ii][2] << 8;
	      }

	   vlt[0].v_slot = 0;
	   vlt[0].v_red = hdr26->ctbl[0][0] << 8;
	   vlt[0].v_green = hdr26->ctbl[0][1] << 8;
	   vlt[0].v_blue = hdr26->ctbl[0][2] << 8;

	   Loadvlt( vs_no, vlt, 256 );
	   }
	else if ( (hdr26->planes < 6) && ( term_planes < 6 ) )
	   {
	   /* RLE file saved on a GS machine and  */
	   /* we are recalling it on a GS machine */
	   Readvlt( vs_no, vlt, 32, 0 );

	   for ( ii = 0; ii < 32; ii++)
	      {
	      vlt[ii].v_slot = ii;
	      vlt[ii].v_red = hdr26->ctbl[ii][0] << 8;
	      vlt[ii].v_green = hdr26->ctbl[ii][1] << 8;
	      vlt[ii].v_blue = hdr26->ctbl[ii][2] << 8;
	      }	  	 

	   Loadvlt( vs_no, vlt, 32 );
	   }
	else if ( (hdr26->planes < 6) && ( term_planes > 6) )
	   {
	   /* RLE file saved on a GS machine and     */
	   /* we are recalling it on a GX/GZ machine */
	   Readvlt( vs_no, vlt, 256, 0 );

	   for ( ii = 1; ii < 32; ii++ )
	      {
	      vlt[ii].v_slot = ii + GS_TO_GXGZ_VLT_OFFSET;
	      vlt[ii].v_red = hdr26->ctbl[ii][0] << 8;
	      vlt[ii].v_green = hdr26->ctbl[ii][1] << 8;
	      vlt[ii].v_blue = hdr26->ctbl[ii][2] << 8;
	      }	  	 

	   vlt[0].v_slot = 0;
	   vlt[0].v_red = hdr26->ctbl[0][0] << 8;
	   vlt[0].v_green = hdr26->ctbl[0][1] << 8;
	   vlt[0].v_blue = hdr26->ctbl[0][2] << 8;

	   Loadvlt( vs_no, vlt, 32 );
	   }	

#endif
	}  /* load_rle_file_vlt */


/*--- read_27_line -----------------------------------------------------------------*/

static void read_27_line( infile, image, red, green, blue )

	FILE *infile;
	struct image_info *image;
	unsigned char *red, *green, *blue;

/*
DESCRIPTION
	This function reads a line from a type 27 RLE file and stores
	the red, green, and blue values in the character arrays 'red',
	'green', and 'blue'.
*/

	{
	int           color, count;
	char          head;
	short         short_head;
	unsigned char shade;
	unsigned char *RGB;

	for ( color = 0; color < 3; color++ )
	   {
	   switch ( color )
	      {
	      case 0:
	         RGB = red;
	         break;
	      case 1:
	         RGB = green;
	         break;
	      case 2:
	         RGB = blue;
	         break;
	      }

	   for ( count = 0; count < image->num_rows; )
	      {
	      /* Read another atom 'head' */
	      fread( &head, 1 /* bytes */, 1, infile );

	      if ( head > 0 )
	         {
	         /* Read 'head' bytes to get the tail of the atom */
	         fread( &RGB[count], head, 1, infile );
	         count += head;
	         }
	      else
	         {
	         /* -head gives the run-length of the shade in next byte */
	         short_head = -head;  /* assign to short to keep from overflowing byte */
	         fread( &shade, 1, 1, infile );
	         memset( &RGB[count], shade, short_head );
	         count += short_head;
	         }

	      } /* for ( count = ... */

	   } /* for ( color = ... */

	} /* read_27_line */


/*--- index_27_line -----------------------------------------------------------------*/

static void index_27_line( x, image, red, green, blue )

	int x;
	unsigned char *red, *green, *blue;
	struct image_info *image;

/*
DESCRIPTION
	This function takes the red, green, and blue values for a line from a
	type 27 line file and stores them in the red, green, and blue buffers
	used for displaying and differencing.  This function is needed because the
	type 27 RLE file is stored in row-major format with the origin at the
	lower left and the buffers for displaying and differencing are in column-
	major format with the origin at the upper left.
*/

	{
	register int y;
	int index;
	register long *index_buffer;
	register unsigned char *red_buffer, *green_buffer, *blue_buffer;

	y = image->num_rows;
	index = (image->num_rows - 1) * image->num_cols + x;
	index_buffer = &image->index_buf[index];
	red_buffer = &image->red[index];
	green_buffer = &image->green[index];
	blue_buffer = &image->blue[index];

	for ( y = image->num_rows; y > 0; y-- )
	   {
	   if ( true_color )
	      *index_buffer = (*blue << 16) | (*green << 8) | *red;
	   else
#ifdef X11
              fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	      *index_buffer = (long) index_rgb( x, y, (int)*red, (int)*green, (int)*blue );
#endif

	   *red_buffer = *red++;
	   *green_buffer = *green++;
	   *blue_buffer = *blue++;

	   index_buffer -= image->num_cols;
	   red_buffer -= image->num_cols;
	   green_buffer -= image->num_cols;
	   blue_buffer -= image->num_cols;
	   }

	} /* index_27_line */


/*--- read_type27 -----------------------------------------------------------------*/

static void read_type27( f_ptr, image )

	FILE  *f_ptr;
	struct image_info *image;

/*
DESCRIPTION
	This function reads in a type 27 file.  It fills in the red, green, and blue
	buffers and the VLT index buffer in the 'image' structure.
*/

	{
	int i;
	unsigned char *red, *green, *blue;

	red = (unsigned char *) malloc( image->num_rows );
	green = (unsigned char *) malloc( image->num_rows );
	blue = (unsigned char *) malloc( image->num_rows );

	for ( i = 0; i < image->num_cols; i++ )
	   {
	   read_27_line( f_ptr, image, red, green, blue );

	   index_27_line( i, image, red, green, blue );
	   }

	if ( red ) free( red );
	if ( green ) free( green );
	if ( blue ) free( blue );

	} /* read_type27 */


/*--- read_29_line -----------------------------------------------------------------*/

static int read_29_line( infile, image, Length, indices, slot_offset )

	FILE              *infile;
	struct image_info *image;
	int               Length;
	long              *indices;
	int               slot_offset;

/*
DESCRIPTION
	This function reads a line from a type 29 RLE file and stores it in
	a VLT index buffer that is passed in.
*/

	{
	int            i, count, end_run;
	char           head;
	char           buffer[127];
	unsigned short line_header[2];
	int            total_bytes, words_to_follow;

	total_bytes = count = 0;

	if ( image->scanable )
	   {
	   if (! fread( line_header, 4 /* bytes */, 1, infile ) )
	      return( 1 );
	   words_to_follow = line_header[1];
	   if ( ! fread( line_header, 4 /* bytes */, 1, infile ) )
	      return( 1 );
	   total_bytes += 8;
	   }

	for ( count = 0; count < Length; )
	   {
	   /* Read another atom 'head' */
	   if ( ! fread( &head, 1 /* bytes */, 1, infile ) )
	      return( 1 );
	
	   if ( image->scanable )
	      total_bytes += 1;

	   /* Read 'head' bytes to get the tail of the atom */
	   if ( head > 0 )
	      {
	      if ( ! fread( buffer, head, 1, infile ) )
	         return( 1 );

	      if ( image->scanable )
	         total_bytes += head;

	      end_run = count + head;
	      for ( i = 0; count < end_run; count++,i++ )
	         if ( buffer[i] != 0 )
	            indices[count] = buffer[i] + slot_offset;
	         else
	            indices[count] = buffer[i];
	      }
	   else 
	      {
	      /* Read one byte to get the tail of the atom */
	      if ( ! fread ( buffer, 1, 1, infile ) )
	         return( 1 );
	      if ( image->scanable )
	         total_bytes += 1;

	      end_run = count - head; /* 'head' is negative */
	      if ( buffer[0] != 0 )
	         buffer[0] += slot_offset;
	      for ( ; count < end_run; count++ )
	         indices[count] = buffer[0];
	      }

	   } /* for ( count = ... */

	if ( image->scanable )
	   {
	   /* Check for a pad byte (in the case of odd number of total bytes read) */
	   if ( (total_bytes / 2) < ( words_to_follow + 2 ) )
	      {
	      if ( !fread ( buffer, 1, 1, infile ) )
	         return( 1 );
	      }

	   }

	return( 0 );
	} /* read_29_line() */


/*--- read_type29 -----------------------------------------------------------------*/

static int read_type29( f_ptr, image, slot_offset )

	FILE              *f_ptr;
	struct image_info *image;
	int               slot_offset;

/*
DESCRIPTION
	This function reads in a type 29 RLE file.  It fills in the VLT index buffer
	in the 'image' structure.
*/

	{
	int i, index;

	for ( i = 0, index = 0; i < image->num_rows; i++, index += image->num_cols )
	   {
	   if ( read_29_line( f_ptr, image, image->num_cols, &image->index_buf[index], slot_offset ) )
	      return( 1 );  /* failure */
	   }

	return( 0 );
	} /* read_type29 */


/*--- read_26_line -------------------------------------------------------*/

static void read_26_line( infile, indices, slot_offset, run_mask, value_mask )

	FILE              *infile;
	long              *indices;
	int               slot_offset;
	unsigned short    run_mask, value_mask;

/*
DESCRIPTION
	This function reads a line from a type 26 RLE file and stores it in
	a VLT index buffer that is passed in.
*/

	{
	int                   ii, jj, num_rle, length;
	int                   index;
	unsigned char         value;
	unsigned short        len_val;
	struct TYPE_89_HEADER hdr89;


	index = 0;
	fread( &hdr89, 8, 1, infile);
	num_rle = hdr89.wtf - 2;

	for ( ii = 0; ii < num_rle; ii++ )
	   {
	   fread( &len_val, 2, 1, infile ); 

	   length = (len_val & run_mask) >> (16-DTM);

	   if ( length == 0 )
	      {
	      value  = len_val & value_mask;
	      fread( &len_val, 2, 1, infile );
	      length = len_val;
	      ii++;
	      }		    	
	   else
	      {
	      value = len_val & value_mask;
	      }

	   if ( value != 0 ) value += slot_offset;

	   for ( jj = 0; jj < length; jj++ )
	      indices[index++] = value;
	   }/* end: for ii */

	}  /* read_26_line */


/*--- read_type26 -----------------------------------------------------------------*/

static void read_type26( f_ptr, image, slot_offset )

	FILE              *f_ptr;
	struct image_info *image;
	int               slot_offset;

/*
DESCRIPTION
	This function reads in a type 26 RLE file.  It fills in the VLT index buffer
	in the 'image' structure.
*/

	{
	int            i, index;
	unsigned short run_mask, value_mask;

	run_mask = pow( 2.0, (double)(16-image->data_type_modifier)) *
	                   ( pow(2.0, (double)(image->data_type_modifier))-1.0) + 0.5;

	value_mask = pow(2.0,(double)(16-image->data_type_modifier))-1.0+0.5;

	for ( i = 0, index = 0; i < image->num_rows; i++, index += image->num_cols )
	   read_26_line( f_ptr, &image->index_buf[index], slot_offset, run_mask, value_mask );

	} /* read_type26 */


/*--- read_10_line -------------------------------------------------------*/

static void read_10_line( infile, indices, slot_offset )

	FILE              *infile;
	long              *indices;
	int               slot_offset;

/*
DESCRIPTION
	This function reads a line from a type 10 RLE file and stores it in
	a VLT index buffer that is passed in.
*/

	{
	int                   ii, num_rle, jj;
	int                   index;
	unsigned char         value;
	unsigned short        length;
	struct TYPE_89_HEADER hdr89;
	struct RLE_RECORD     rle;

	index = 0;
	fread( &hdr89, sizeof(struct TYPE_89_HEADER), 1 , infile);
	num_rle = (hdr89.wtf - 2) / 2;

	for ( ii = 0; ii < num_rle; ii++)
	   {
	   fread( &rle, 4, 1, infile ); 

	   value = (unsigned char)( rle.color_shade);
	   if ( value != 0 ) value += slot_offset;
	   length = (unsigned short) rle.run_length;
		    
	   for ( jj = 0; jj < length; jj++ )
	      indices[index++] = value;
	   }/* end: for ii */

	}  /* read_10_line */


/*--- read_type10 -----------------------------------------------------------------*/

static void read_type10( f_ptr, image, slot_offset )

	FILE              *f_ptr;
	struct image_info *image;
	int               slot_offset;

/*
DESCRIPTION
	This function reads in a type 10 RLE file.  It fills in the VLT index buffer
	in the 'image' structure.
*/

	{
	int i, index;

	for ( i = 0, index = 0; i < image->num_rows; i++, index += image->num_cols )
	   read_10_line( f_ptr, &image->index_buf[index], slot_offset );

	} /* read_type10 */


/*--- read_rle_file -----------------------------------------------------------------*/

void read_rle_file( image )

	struct image_info *image;

/*
DESCRIPTION
	This function reads an RLE file and stores its information in the
	structure pointed to by 'image'.  An array of VLT indices for the image
	is always generated.  If the RLE file was type 27, then arrays of the
	red, green, and blue values for the image are also generated.
*/

	{
	FILE                *f_ptr;
#ifndef X11
	int                 vs_no;
#endif
	int                 slot_offset;
	struct HEADER_BLOCK hdr26;
#ifndef X11
	struct scr_info     screen_info[MAX_SCREENS];
#endif

	if ( !batch )
	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   Inq_displayed_vs( &vs_no );
	   Inq_screen_info( screen_info );
#endif
	   }

	f_ptr = fopen( image->name, "r" );

	fread( &hdr26, sizeof(struct HEADER_BLOCK), 1, f_ptr );

	image->rle_type = hdr26.data_type_code;

	image->num_cols = hdr26.width;
	image->num_rows = hdr26.height;
	image->scanable = hdr26.scannable_flag;

	image->data_type_modifier = hdr26.data_type_modifier;
	image->num_planes         = hdr26.planes;
	image->vlt_size           = hdr26.vlt_size;

	if ( image->rle_type == TYPE_27 )
	   {
	   /* rendering type 27's have vertical scan lines */
	   image->num_cols = hdr26.num_rows;
	   image->num_rows = hdr26.num_cols;
	   }
	else if ( image->rle_type == TYPE_26 )
	   {
	   image->num_cols = hdr26.num_cols;
	   image->num_rows = hdr26.num_rows;
	   }


	if ( !batch )
	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   if ( (image->rle_type == TYPE_10) ||
	     (image->rle_type == TYPE_26) ||
	     (image->rle_type == TYPE_29) )
	      load_rle_file_vlt( &hdr26, image, vs_no, screen_info[vs_no].vsi_num_planes );
#endif
	   }

	rewind( f_ptr );

	if ( !batch )
	   {
#ifdef X11
           fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	   if ( (hdr26.planes < 6) && (screen_info[vs_no].vsi_num_planes > 6) )
	      slot_offset = GS_TO_GXGZ_VLT_OFFSET;
	   else
	      slot_offset = 0;
#endif
	   }

	image->index_buf = (long *) malloc( image->num_rows * image->num_cols * sizeof( long ) );
	image->red = image->green = image->blue = NULL;

	switch ( image->rle_type )
	   {
	   case TYPE_27 :
	      if ( !batch )
	         {
#ifdef X11
                 fprintf( stderr, "rle_view: Not ported to X yet\n" );
#else
	         if ( (screen_info[vs_no].vsi_VLT_size == 256) && (screen_info[vs_no].vsi_num_planes == 9) )
	            init_rgb( 8 );  /* we are on an EDGE I => don't use vsi_num_planes because it lies */
	         else
	            init_rgb( screen_info[vs_no].vsi_num_planes );
#endif
	 	 }	

	      image->red   = (unsigned char *) malloc( image->num_rows * image->num_cols );
	      image->green = (unsigned char *) malloc( image->num_rows * image->num_cols );
	      image->blue  = (unsigned char *) malloc( image->num_rows * image->num_cols );
	      fseek( f_ptr, TWO_BLOCKS, 0 );
	      read_type27( f_ptr, image );
	      break;

	   case TYPE_10 :
	      fseek( f_ptr, sizeof(struct HEADER_BLOCK), 0 );
	      read_type10( f_ptr, image, slot_offset );
	      break;

	   case TYPE_26 :
	      /* TYPE 26 RECALLS HAVE NEVER BEEN TESTED */
	      fseek( f_ptr, sizeof(struct HEADER_BLOCK), 0 );
	      read_type26( f_ptr, image, slot_offset );
	      break;

	   case TYPE_29 :
	      fseek( f_ptr, sizeof(struct HEADER_BLOCK), 0 );
	      read_type29( f_ptr, image, slot_offset );
	      break;

	   }  /* end: switch */

	}  /* read_rle_file */
