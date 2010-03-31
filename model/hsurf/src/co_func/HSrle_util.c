
/*
 *  Utilities for reading and writing clipper formatted files
 */

#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "exsysdep.h"

#include "hskyoptypes.h"
#include "HSsara.h"
#include "hsanimate.h"
#include "HSrle.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "HSpr_co_func.h"

/*
 *  Prototype declaration for static functions
 */

static HScreate_type27_header( int file_des,
                               int x_dits,
                               int y_dits);


static int                        outfile;
static char                       *scanline;

#define ECHO_WRITE                0

#define RED                       0
#define GREEN                     1
#define BLUE                      2

#define MAX_NEGATIVE_RUN_LENGTH  -128
#define MAX_SHADES_IN_TAIL        127

#define DEBUG                     0

/*---HSconv_double------------------------------------------------------------*/

int HSconv_double( double *d, int n )

{
   union
   {
      char   c[8];
      double   d;
   } x, y;

   if( d == NULL )
   {
      return(0);
   }

   while( n )
   {
      x.d = *d;

      y.c[0] = x.c[7];
      y.c[1] = x.c[6];
      y.c[2] = x.c[5];
      y.c[3] = x.c[4];
      y.c[4] = x.c[3];
      y.c[5] = x.c[2];
      y.c[6] = x.c[1];
      y.c[7] = x.c[0];

      *d = y.d;

      d++;
      n--;
   }

   return(1);
}

/*---HSconv_short-------------------------------------------------------------*/

int HSconv_short( short *s, int n )

{
   union
   {
      char   c[2];
      short   s;
   } x, y;

   if( s == NULL )
   {
      return(0);
   }

   while( n )
   {
      x.s = *s;

      y.c[0] = x.c[1];
      y.c[1] = x.c[0];

      *s = y.s;

      s++;
      n--;
   }
   return(1);
}

/*---HSconv_int---------------------------------------------------------------*/

int HSconv_int( int *i, int n )

{
   union
   {
      char   c[4];
      int   i;
   } x, y;

   if( i == NULL )
   {
      return(0);
   }

   while( n )
   {
      x.i = *i;

      y.c[0] = x.c[3];
      y.c[1] = x.c[2];
      y.c[2] = x.c[1];
      y.c[3] = x.c[0];

      *i = y.i;

      i++;
      n--;
   }
}


#if DEBUG

/*---HSdump_rasterfile_header-------------------------------------------------*/

int HSdump_rasterfile_header( struct HEADER_BLOCK   *header )

{
   int i;
   int j;


   fprintf( stderr, "rasterfile header\n" );
   fprintf( stderr, "  header_type_code ---------- %d %x: %3d %3d\n",
                    header->header_type_code,
                    header->header_type_code,
                    header->header_type_code >> 8,
                    header->header_type_code & 0xff );
   fprintf( stderr, "  wds_to_follow ------- %d\n",
                    header->wds_to_follow );
   fprintf( stderr, "  data_type_code ------ %d\n",
                    header->data_type_code );
   fprintf( stderr, "  app_type_code ------- %d\n",
                    header->app_type_code );
   fprintf( stderr, "  view_origin --------- %f %f %f\n",
                    header->view_origin_x,
                    header->view_origin_y,
                    header->view_origin_z );
   fprintf( stderr, "  view_extent --------- %f %f %f\n",
                    header->view_extent_x,
                    header->view_extent_y,
                    header->view_extent_z );
   fprintf( stderr, "  transformation ------ %f %f %f %f\n",
                    header->transformation[0],
                    header->transformation[1],
                    header->transformation[2],
                    header->transformation[3] );
   fprintf( stderr, "                        %f %f %f %f\n",
                    header->transformation[4],
                    header->transformation[5],
                    header->transformation[6],
                    header->transformation[7] );
   fprintf( stderr, "                        %f %f %f %f\n",
                    header->transformation[8],
                    header->transformation[9],
                    header->transformation[10],
                    header->transformation[11] );
   fprintf( stderr, "                        %f %f %f %f\n\n",
                    header->transformation[12],
                    header->transformation[13],
                    header->transformation[14],
                    header->transformation[15] );
   fprintf( stderr, "  num_cols ------------ %d\n", header->num_cols );
   fprintf( stderr, "  num_rows ------------ %d\n", header->num_rows );
   fprintf( stderr, "  device_resolution --- %d\n",
                    header->device_resolution );
   fprintf( stderr, "  scanline_orient ----- %d\n",
                    header->scanline_orient );
   fprintf( stderr, "  scannable_flag ------ %d\n",
                    header->scannable_flag );
   fprintf( stderr, "  rotation_angle ------ %f\n",
                    header->rotation_angle );
   fprintf( stderr, "  skew_angle ---------- %f\n",
                    header->skew_angle );
   fprintf( stderr, "  data_type_modifier -- %d\n",
                    header->data_type_modifier );
   fprintf( stderr, "  design_filename ----- %s\n",
                    header->design_filename );
   fprintf( stderr, "  dbase_filename ------ %s\n",
                    header->dbase_filename );
   fprintf( stderr, "  parent_gridfile ----- %s\n",
                    header->parent_gridfile );
   fprintf( stderr, "  file_descript ------- %s\n",
                    header->file_descript );

   fprintf( stderr, "  reserved1 ----------- %s\n",
                    header->reserved1 );

   fprintf( stderr, "  gridfile_version ---- %d\n",
                    header->gridfile_version );
   fprintf( stderr,"\n");

   fprintf( stderr, "Block Two\n");
   fprintf( stderr, "---------\n");
   fprintf( stderr, "  gain ---------------- %d\n", header->gain );
   fprintf( stderr, "  offset -------------- %d\n", header->offset );
   fprintf( stderr, "  vwfull_scr1 --------- %d\n", header->vwfull_scr1 );
   fprintf( stderr, "  vwfull_scr2 --------- %d\n", header->vwfull_scr2 );
   fprintf( stderr, "  view_number --------- %d\n", header->view_number );

   fprintf( stderr, "  reserved2 ----------- %d\n", header->reserved2 );
   fprintf( stderr, "  reserved3 ----------- %d\n", header->reserved3 );
   fprintf( stderr, "  aspect_ratio -------- %d\n", header->aspect_ratio );

   fprintf( stderr, "  concat_file_ptr ----- %d\n", header->concat_file_ptr );
   fprintf( stderr, "  color_table_type ---- %d\n", header->color_table_type );
   fprintf( stderr, "  reserved4 ----------- %d\n", header->reserved4 );
   fprintf( stderr, "  num_ctbl_entries ---- %d\n", header->num_ctbl_entries );

   fprintf( stderr, "  app_packet_pointer -- %d\n", header->app_packet_pointer);
   fprintf( stderr, "  app_packet_length --- %d\n", header->app_packet_length );

   for( i = 0; i < 110; i++)
   {
      fprintf( stderr, "  header->reserved5[%d] %d\n", i, header->reserved5[i]);
   }

   fprintf( stderr, "  planes -------------- %d\n", header->reserved5[105] );
   fprintf( stderr, "  x_off --------------- %d\n", header->reserved5[108] );
   fprintf( stderr, "  y_off --------------- %d\n\n", header->reserved5[109] );


   fprintf( stderr,"Color Table Information\n");
   fprintf( stderr,"-----------------------\n\n");
   for( i = 0; i < 256; i++)
   {
      for( j = 0; j < 3; j++)
      {
         fprintf( stderr, " ctbl[%d][%d] -------------- %d\n",
                  i, j, header->ctbl[i][j] );
      }

      fprintf( stderr, "\n");
   }
}

#endif

/*---HSread_rasterfile_header-------------------------------------------------*/

void HSread_rasterfile_header( int    *fp,
                               short  *data_type_code,
                               short  *app_type_code,
                               long   *num_rows,
                               long   *num_cols,
                               char   *colortable,
                               char   *colortable_size )

{
   struct header_info   header;
   int                  status;

   /*
    *  Read the first four bytes of the header to get
    *  the number of words to follow, this will tell me
    *  how many bytes are left to read
    */

   status = read( *fp, &header, 4 );

#ifdef BIG_ENDIAN
   HSconv_short(  &header.level_type, 1 );
   HSconv_short(  &header.wds_to_follow, 1 );
#endif

   status = read( *fp, &header.data_type_code, header.wds_to_follow*2 );

#ifdef BIG_ENDIAN
   HSconv_short(  &header.data_type_code, 1 );
   HSconv_short(  &header.app_type_code, 1 );
   HSconv_double(  header.view_origin, 3 );
   HSconv_double(  header.view_extent, 3 );
   HSconv_double(  header.transformation, 16 );
   HSconv_int((int *)&header.num_cols, 1 );
   HSconv_int((int *)&header.num_rows, 1 );
   HSconv_short(  &header.device_resolution, 1 );
   HSconv_double( (double *)&header.rotation_angle, 1 );
   HSconv_double( (double *)&header.skew_angle, 1 );
   HSconv_short(  &header.data_type_modifier, 1 );
   HSconv_short(  &header.entity_number, 1 );
   HSconv_short(  &header.coded_value, 1 );
   HSconv_short(  &header.polygon_id, 1 );
   HSconv_short(  &header.run_id, 1 );
   HSconv_short(  &header.integer_value, 1 );
   HSconv_int((int *)&header.concat_file_ptr, 1 );
   HSconv_short(  &header.vlt_size, 1 );
   HSconv_short(  &header.colors, 1 );
   HSconv_short(  &header.shades, 1 );
   HSconv_short(  &header.color_bits, 1 );
   HSconv_short(  &header.len_bits, 1 );
   HSconv_short(  &header.planes, 1 );
   HSconv_short(  &header.height, 1 );
   HSconv_short(  &header.width, 1 );
   HSconv_short(  &header.x_off, 1 );
   HSconv_short(  &header.y_off, 1 );
#endif

#if DEBUG
   HSdump_rasterfile_header((struct HEADER_BLOCK *) &header );
#endif

   if( data_type_code ) *data_type_code = header.data_type_code;
   if( app_type_code )  *app_type_code = header.app_type_code;
   if( num_rows )       *num_rows = header.num_rows;
   if( num_cols )       *num_cols = header.num_cols;

   if( colortable && colortable_size )
   {
      ;
   }
}

/*---HSwrite_rasterfile_header------------------------------------------------*/

void   HSwrite_rasterfile_header( int   *fp,
                                  short data_type_code,
                                  short app_type_code,
                                  long  num_rows,
                                  long  num_cols,
                                  char  *colortable,
                                  char  *colortable_size )

{
   struct header_info   header;
   int                  status;

   memset( &header, 0, sizeof( header ) );

   if( data_type_code )
   {
      header.data_type_code = data_type_code;
   }

   if( app_type_code )
   {
      header.app_type_code = app_type_code;
   }

   if( num_rows )
   {
       header.num_rows = num_rows;
   }

   if( num_cols )
   {
       header.num_cols = num_cols;
   }

   if( colortable && colortable_size )
   {
       ;
   }

   /*
    *  Read the first four bytes of the header to get
    *  the number of words to follow, this will tell me
    *  how many bytes are left to read
    */

   header.level_type       = 0x0908;
   header.wds_to_follow    = 0x1fe;
   header.scanline_orient  = 0x04;
   header.scannable_flag   = 0x00;
   header.gridfile_version = 3;

#ifdef BIG_ENDIAN
   HSconv_short(  &header.level_type, 1 );
   HSconv_short(  &header.wds_to_follow, 1 );
   HSconv_short(  &header.data_type_code, 1 );
   HSconv_short(  &header.app_type_code, 1 );
   HSconv_double(  header.view_origin, 3 );
   HSconv_double(  header.view_extent, 3 );
   HSconv_double(  header.transformation, 16 );
   HSconv_int((int *)&header.num_cols, 1 );
   HSconv_int((int *)&header.num_rows, 1 );
   HSconv_short(  &header.device_resolution, 1 );
   HSconv_double( (double *)&header.rotation_angle, 1 );
   HSconv_double( (double *)&header.skew_angle, 1 );
   HSconv_short(  &header.data_type_modifier, 1 );
   HSconv_short(  &header.entity_number, 1 );
   HSconv_short(  &header.coded_value, 1 );
   HSconv_short(  &header.polygon_id, 1 );
   HSconv_short(  &header.run_id, 1 );
   HSconv_short(  &header.integer_value, 1 );
   HSconv_int((int *)&header.concat_file_ptr, 1 );
   HSconv_short(  &header.vlt_size, 1 );
   HSconv_short(  &header.colors, 1 );
   HSconv_short(  &header.shades, 1 );
   HSconv_short(  &header.color_bits, 1 );
   HSconv_short(  &header.len_bits, 1 );
   HSconv_short(  &header.planes, 1 );
   HSconv_short(  &header.height, 1 );
   HSconv_short(  &header.width, 1 );
   HSconv_short(  &header.x_off, 1 );
   HSconv_short(  &header.y_off, 1 );
#endif

#if DEBUG
   HSdump_rasterfile_header( (struct HEADER_BLOCK *)&header );
#endif

   status = write( *fp, &header, 0x400 );
}


/* ---HSread_type27_scanline--------------------------------------------------*/

/*
 *  HSread_type27_scanline() reads one scanline worth of rle from the file
 *  'infile' and places pixel information into the buffers 'Red', 'green',
 *  and 'blue'.
 *
 *  SIDE EFFECT: Sets the value for the 'unscaled' 'ScanLine'.
 *
 *  HISTORY: 07/12/89   Created.                      Trevor Mink
 *           10/20/89   Changed to read rle type 27.  Trevor Mink
 *           12/10/91   Stole from HRmipmap.c         Mike Lanier
 */

int   HSread_type27_scanline( int            *infile,
                              int            length,
                              int            step,
                              unsigned char  *red,
                              unsigned char  *green,
                              unsigned char  *blue )

{
   int            i;
   int            count = 0;
   int            end_run;
   int            color;
   char           head;
   unsigned char  buffer[127];
   unsigned char  *RGB=NULL;
   int            bytes_read = 1;

#if SCANNABLE
   int            Total_bytes = 0;
   int            Words_to_follow;

   bytes_read = read( *infile, Lineheader, 4 );
   Words_to_follow = Lineheader[1];

   Total_bytes += bytes_read;

#if ECHO_READ
   printf( "Lineheader[0] = %x\n", Lineheader[0] );
   printf( "Lineheader[1] = %x\n", Lineheader[1] );
#endif

#endif

#if SCANNABLE
   bytes_read = read( *infile, Lineheader, 4 );
   *ScanLine = Lineheader[0];

   Total_bytes += bytes_read;

#if ECHO_READ
   printf( "Lineheader[0] = %x\n", Lineheader[0] );
   printf( "Lineheader[1] = %x\n", Lineheader[1] );
#endif

#endif

   for( color = 0; color < 3; color++ )
   {
      switch ( color )
      {
         case RED:
            RGB = red;
            break;

         case GREEN:
            RGB = green;
            break;

         case BLUE:
            RGB = blue;
            break;
      }

      for( count=0; count<length && (bytes_read >= 0); )
      {

         /* Read another atom 'head' */

         bytes_read = read( *infile, &head, 1 );

         if ( bytes_read >= 0 )
         {
#if SCANNABLE
            Total_bytes += bytes_read;
#endif

            /* Read 'head' bytes to get the tail of the atom */

            if( head > 0 )
            {
               bytes_read = read( *infile, buffer, head );

               if( bytes_read >= 0 )
               {
#if SCANNABLE
                  Total_bytes += bytes_read;
#endif

                  end_run = count + head;

                  for ( i=0; count<end_run && count<length; count++,i++ )
                  {
                     *RGB = buffer[i];
                     RGB += step;
                  }
               }
            }
            else
            {

               /* -head gives the run-length of the shade in next byte */

               bytes_read = read( *infile, buffer, 1 );

               if ( bytes_read >= 0 )
               {
#if SCANNABLE
                  Total_bytes += bytes_read;
#endif

                  end_run = count - head; /* 'head' is negative */

                  for( ;count<end_run && count<length; count++ )
                  {
                     *RGB = buffer[0];
                     RGB += step;
                  }
               }
            }
         }
      }
   }

#if SCANNABLE
   /* Check for a pad byte (in the case of odd number of total bytes read) */

   printf("Total_bytes = %d\n", Total_bytes);
   if ( (Total_bytes / 2) < ( Words_to_follow + 2 ) )
      bytes_read = read( *infile, buffer, 1 );
#endif

   return ( bytes_read );
}

/*---HSread_type25_scanline---------------------------------------------------*/

int HSread_type25_scanline( int            *infile,
                            unsigned short *file_buffer,
                            int            length,
                            unsigned char  *red,
                            unsigned char  *green,
                            unsigned char  *blue )
{
   unsigned short  header;
   unsigned short  wtf;
   unsigned short  *bf;
   unsigned char   r;
   unsigned char   g;
   unsigned char   b;
   unsigned char   count;
   int             bytes_read;

   bytes_read = 0;

   bytes_read += read( *infile, &header, 2 );
   bytes_read += read( *infile, &wtf, 2 );

#ifdef BIG_ENDIAN
   HSconv_short( (short *)&wtf, 1 );
#endif

   bytes_read += read( *infile, file_buffer, wtf*2 );

#ifdef BIG_ENDIAN
   HSconv_short( (short *)file_buffer, wtf+1 );
#endif

   bf = file_buffer;
   bf++;
   bf++;

   wtf--;
   wtf >>= 1;
   while( wtf-- )
   {
      g = (unsigned char)(*bf >> 8);
      b = (unsigned char)(*bf++ & 0xff);
      r = (unsigned char)(*bf & 0xff);
      count = (unsigned char)(*bf++ >> 8);

      while( count-- )
      {
         *red++ = r;
         *green++ = g;
         *blue++ = b;
      }
   }

   return( bytes_read );
}


/*---HSwrite_type27_scanline--------------------------------------------------*/

/*
 * HSwrite_type27_scanline() takes the RGB values of a line of pixels, arranges
 * them in a Run-length Encoding Scheme (type 27), and places this information
 * into a file.
 *
 * HISTORY: 10/19/89   Adapted from a version to write in type 25 rle format.
 *                        Trevor Mink
 *
 */

void HSwrite_type27_scanline( int            *fp,
                              int            scanx,
                              int            length,
                              char           *scanline,
                              unsigned short *red,
                              unsigned short *green,
                              unsigned short *blue )

{
   int             color;
   short           p = 0;
   short           head;
   short           index;
   unsigned short  *line=NULL;

#if ECHO_WRITE
   printf( "Within HSwrite_type27_scanline\n" );
   printf( "scanx = %d\tlength = %d\n", scanx, length );
#endif

#if SCANNABLE
   unsigned short  *Scan;
   int             Total_bytes = 0;

   Scan = (unsigned short *)scanline;
   Scan[0] = 0x5900;
   Scan[1] = 0;
   Scan[2] = scanx;
   Scan[3] = 0;

   p = 8;
#endif

   for( color=0; color<3; color++ )
   {
      switch( color )
      {
         case RED:
            line = red;
            /* p is initialized above ( 0 or 8 according to whether SCANNABLE
               flag is turned on or not ) */
            break;

         case GREEN:
            line = green;
            p = 0;
            break;

         case BLUE:
            line = blue;
            p = 0;
            break;
      }

      index = 0;

      while( index <= length - 1 )
      {
         /* Begin with the head of the atom. 'p' will then progress through  */
         /* the tail of the atom (the tail may be only one byte or up to 127 */
         /* bytes)                                                           */

         head = p;

         /* Check for a run-length of at least two */

         if( (index <= length - 2) && (line[index] == line[index+1]) )
         {
            /* Use negative to indicate a run-length ( rather than a number  */
            /* of bytes to follow which each contain a shade )               */

            scanline[p++] = -2;
            scanline[p] = line[index];

            index += 2;

#if ECHO_WRITE
            printf( "\nA run-length has begun\n" );
            printf( "index = %d\n", index );
            printf( "scanline[head] = %d\n", scanline[head] );
            printf( "line[index] = %x\tline[index+1] = %x\n",
                     line[index], line[index+1] );
#endif

            while( index <= (length - 1) &&
                   (line[index] == line[index-1]) &&
                   (scanline[head] > MAX_NEGATIVE_RUN_LENGTH) )
            {
               (scanline[head])--; /* Remember negative sign for run-length*/
               index++;

#if ECHO_WRITE
               printf( "decrementing scanline[head] to %d and index to %d\n",
                        scanline[head], index );
#endif

            }
         }
         else
         {
            scanline[p++] = 1;
            scanline[p] = line[index++];

#if ECHO_WRITE
            printf( "\nDiffering shades are being collected\n" );
            printf( "index = %d\tp = %d\n", index, p );
            printf( "scanline[p] = %d\n", scanline[p] );
            printf( "line[index] = %x\tline[index-1] = %x\t",
                     line[index], line[index+1] );
            printf( "line[index-2] = %x\n", line[index-2] );
#endif

            while( (index <= length - 1) &&
                   !((index <= length - 3) &&
                     (line[index] == line[index+1]) &&
                     (line[index] == line[index+2])) &&
                   (scanline[head] < MAX_SHADES_IN_TAIL) )
            {
               p++;
               scanline[p] = line[index];
               scanline[head]++;

               index++;
            }
         }

         p++; /* Start a new head */
      }

      write( *fp, scanline, p );

#if SCANNABLE
         Total_bytes += p;
#endif
   }

#if SCANNABLE
   /* Get 'Total_bytes' in terms of words for writing Words-to-follow in the */
   /* scanline header                                                        */
   Scan[0] = 0x5900;
   Scan[1] = ( Total_bytes + 1 ) / 2 - 2;

   printf( "Total_bytes = %d\tWords to follow = %d\n", Total_bytes, Scan[1] );

   lseek( *fp, -Total_bytes, 1 );   /* Seek to beginning of scanline */
   write( *fp, Scan, 4 );      /* Re-write scan line header */
   lseek( *fp, 0, 2 );         /* Seek to end */
   if ( ( (p / 2) * 2 ) != p )
   {
      write ( *fp, Scan, 1 );   /* Write a null pad byte if p is odd */
   }
#endif
}


/*---HSwrite_type25_scanline--------------------------------------------------*/

/* HSwrite_type25_scanline() takes the RGB values of a line of pixels,       */
/* arranges them in a Run-length Encoding Scheme (type 25), and places this  */
/* information into a file.                                                  */

void   HSwrite_type25_scanline( int             *fp,
                                int             scanx,
                                int             length,
                                unsigned short  *scanline,
                                unsigned short  *red,
                                unsigned short  *green,
                                unsigned short  *blue )

{
   short          p;
   int            count;
   int            index;
   unsigned char  r;
   unsigned char  g;
   unsigned char  b;

   count = 1;
   index = 0;

   r = red[0];
   g = green[0];
   b = blue[0];

   scanline[0] = 0x5900;
   scanline[1] = 0;
   scanline[2] = scanx;
   scanline[3] = 0;
   p = 4;

   index = length - 1;

   while( index >= 0 )
   {
      if( (r == red[index]) &&
          (g == green[index]) &&
          (b == blue[index]) &&
          (count < 255) )
      {
         count++;
      }
      else
      {
         scanline[p++] = (g << 8) | b;
         scanline[p++] = (count << 8) | r;

         r = red[index];
         g = green[index];
         b = blue[index];

         count = 1;
      }

      index--;
   }

   scanline[p++] = (g << 8) | b;
   scanline[p++] = (count << 8) | r;
   scanline[1] = p-2;

#ifdef BIG_ENDIAN
   HSconv_short( (short *)scanline, p );
#endif

   write( *fp, scanline, p*2 );
}

/*---- HSconvert_header ------------------------------------------------------*/
#ifdef BIG_ENDIAN
void HSconvert_header( struct HEADER_BLOCK   *header )

/*   This function is used to convert a index data type header fron a SUN
 *   format to a CLIPPER and vica versa. (Adapted from Mike Lanier's func.)
 *
 *   HISTORY:   12/19/91   Created      Bob Druzynski
 *
 */

{
   HSconv_short(   (short *)&header->header_type_code, 1 );
   HSconv_short(   (short *)&header->wds_to_follow, 1 );
   HSconv_short(   (short *)&header->data_type_code, 1 );
   HSconv_short(   (short *)&header->app_type_code, 1 );

   HSconv_double(  &header->view_origin_x, 1 );
   HSconv_double(  &header->view_origin_y, 1 );
   HSconv_double(  &header->view_origin_z, 1 );

   HSconv_double(  &header->view_extent_x, 1 );
   HSconv_double(  &header->view_extent_y, 1 );
   HSconv_double(  &header->view_extent_z, 1 );

   HSconv_double(  header->transformation, 16 );
   HSconv_int(     (int *)&header->num_cols, 1 );
   HSconv_int(     (int *)&header->num_rows, 1 );

   HSconv_short(   &header->device_resolution, 1 );

   HSconv_int(     (int *)header->rotation_angle, 2 );
   HSconv_int(     (int *)header->skew_angle, 2 );

   HSconv_short(   (short *)&header->data_type_modifier, 1 );


   /* Block Two */
   HSconv_short(  (short *)&header->reserved3, 1 );
   HSconv_double( &header->aspect_ratio, 1 );
   HSconv_int(    (int *)&header->concat_file_ptr, 1 );
   HSconv_short(  (short *)&header->color_table_type, 1 );

   HSconv_short(  (short *)&header->reserved4, 1 );
   HSconv_int(    (int *)&header->num_ctbl_entries, 1 );
   HSconv_int(    (int *)&header->app_packet_pointer, 1 );
   HSconv_int(    (int *)&header->app_packet_length, 1);

   HSconv_short(  (short *)header->reserved5, 110 );
}

/*----HSconvert_hdr89---------------------------------------------------------*/
void HSconvert_hdr89( struct TYPE_89_HEADER   *header )

{
   HSconv_short( &header->level_type, 1);
   HSconv_short( &header->wtf, 1);
   HSconv_short( &header->row, 1);
   HSconv_short( &header->col, 1);
}
#endif


/*---HScreate_type27_header---------------------------------------------------*/

static HScreate_type27_header( int file_des,
                               int x_dits,
                               int y_dits )
{
#if ECHO_WRITE
   printf ( "Within HScreate_type27_header\n" );
   printf ( "file_des = %d\tx_dits = %d\ty_dits = %d\tscale_factor = 0\n",
                     file_des, x_dits, y_dits );
#endif

   HSwrite_rasterfile_header( &file_des,
                              TYPE_27,
                              7,
                              x_dits,
                              y_dits,
                              NULL,
                              NULL );
}


/*---HSwrite_line_in_rle27----------------------------------------------------*/

void HSwrite_line_in_rle27( int            scanx,
                            int            DisplayLength,
                            unsigned short *Red,
                            unsigned short *Green,
                            unsigned short *Blue )

{
   HSwrite_type27_scanline( &outfile,
                            scanx,
                            DisplayLength,
                            scanline,
                            Red,
                            Green,
                            Blue );
}

/*---HSinit_rle--------------------------------------------------------------*/

/* HSinit_rle() opens the Run-Length Encoding file, writes a header to it,
 * and allocates a buffer for a scanline of rle data.
 *
 * HISTORY: ??/??/??   Created by Mike Lanier.
 *       07/25/89   Added ScaleFactor and FileName parameters.
 *                        Trevor Mink
 *
 *       10/19/89   Changed to support type 27 rle format rather than type 25.
 *                        Trevor Mink
 *       6/3/93     Created from defunct function HRinit_rle
                          Bob Druzynski
 */

int HSinit_rle( int       pixel_size,
                int       x_dits,
                int       y_dits,
                char      *FileName )

{

#if ECHO_WRITE
   printf( "Within HSinit_rle\n" );
   printf( "x_dits = %d\ty_dits = %d\tFileName = %s\n", x_dits, y_dits,
            FileName );
#endif
   outfile = creat( FileName, 0777 );
   if ( outfile == -1)
   {
      return( 1 );
   }

   HScreate_type27_header( outfile, x_dits, y_dits );

   /*
    *  Allocate memory for a line.  The worst case line size is
    *  the number of pixels in a scanline divided by 127 plus 1,
    *  giving the number of 127 bytes segments in the scanline,
    *  times 128 (127 shade pixels plus the count), times the size
    *  of the raster data. Also, add 8 for the 4 word header.
    */

   scanline = (char *)malloc( ( ( ( x_dits + 1 / 127 ) + 1 ) * 128 ) * pixel_size +
                               8 );

   return(0);
} /* HSinit_rle() */

/*---HSfini_rle---------------------------------------------------------------*/

/*
 * HSfini_rle() checks for processing having been prematurely ‚STOPped. If so
 * the header is re-written to reflect the number of x scanlines written. The
 * file is closed regardless.
 *
 * HISTORY: 07/25/89   Created.
 *                        Trevor Mink
 *
 *          10/19/89   Changed to support type 27 rle format rather than type
 *                     25.
 *                        Trevor Mink
 *
 *          06/03/93   Created from defunct function HRfini_rle
 *                        Bob Druzynski
 */

int HSfini_rle( int scanx,
                int x_dits,
                int y_dits )

{

#if ECHO_WRITE
   printf( "Within HSfini_rle\n" );
   printf( "scanx = %d\tx_dits = %d\ty_dits = %d\n", scanx, x_dits, y_dits);
#endif

   if (scanx !=  x_dits)
   {
      lseek( outfile, 0, 0 );              /* Seek to beginning */
      HScreate_type27_header ( outfile, scanx, y_dits  ); /* Re-write header */
      lseek( outfile, 0, 2 );              /* Seek to end */
   }
   close( outfile );

   /* Free scanline buffer */
   if (scanline)
   {
      free( (char *)scanline );
   }
   return(0);
} /* HSfini_rle() */

