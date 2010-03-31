/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <sys/fcntl.h>
#include <FI.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "transdef.h"
#include "translate.h"
#include "trans_ele.h"
#include "transmacros.h"
#include "mapriv.h"

#include "HSplot.h"
#include "HSplot_def.h"

#include "wl.h"
#include "HSpr_hplot.h"


#define MAXBUFSIZ 256
#define DEBUG  0

static IGRint infile, outfile;

static Trans_ele plotting_type5;

/*
 *  Prototype declaration for static functions
 */

static HPfltvax_to_flt32 (IGRint no_floats,
                   unsigned long vax_float[],
                       IGRdouble * ieee_float);

static void HPflt32_to_fltvax (IGRint no_floats,
                            IGRdouble * ieee_float,
                        unsigned long vax_float[]);

static void HPattach_raster_file (IGRchar * rasfil);


/*---swp_int----------------------------------------------*/

/*
NAME
   swp_int: macro
        
KEYWORDS
   shaded plotting
   macro
        
DESCRIPTION
   Swap words of a long
        
HISTORY
   ??/??/?? M. Mathis, M. Lanier
      Created
*/

#define swp_int( long_addr )   \
 {    \
 union    \
  {   \
  long l;   \
  struct   \
   {  \
   short s0; \
   short s1; \
  }s;   \
 } tmp1, tmp2;    \
     \
 tmp1.l = *(long *)long_addr;  \
 tmp2.s.s0 = tmp1.s.s1;   \
 tmp2.s.s1 = tmp1.s.s0;   \
 *(long *)long_addr = tmp2.l;  \
 }

/*---HPfltvax_to_flt32----------------------------------------------------*/

/*
NAME
   HPfltvax_to_flt32
        
DESCRIPTION
   convert the VAX/VMS floating point number format to the IEEE
   floating point number format

PARAMETERS
   no_floats  :(IN) :  Number of floats to convert
   vax_float  :(IN) :  Array of vax floating point numbers
   ieee_float  :(OUT):  Array of ieee floating point numbers
        
ALGORITHM
   Convert the host VAX floating point numbers to 32032 IEEE flormat.
   A buffer of several floating point numbers
   can be converted at the same time.  The VAX floating point number
   is defined in two longwords.

      31               9 8     0
       -------------------------
       |     f        |s|   e  |
       -------------------------
       |           f           |
       -------------------------
      63         32

   VAX Floating Point Format (64 bit double precision):
      s = sign bit
      e = biased exponent (8 bits)   Bias = 2**(e-1)
      f = mantissa (55 bits)   0 <= f < 1
          implied high order bit (hidden bit)

          true exponent  E = e - Bias
          true mantissa  F = .1f
                        
          X = (-1)**s * F * 2**E

                
          31     0
           ---------------------------
           |             f           |
           ---------------------------
           |s|    e    |     f   |
           ---------------------------
          63     52   32

   IEEE Floating Point Format  (64 bit double precision):
      s = sign bit
      e = biased exponent (11 bits)   Bias = 2**(e-1) - 1
      f = mantissa (52 bits)   1 <= f < 2
          implied high order bit (hidden bit)

          true exponent  E = e - Bias
          true mantissa  F = 1.f

   X = (-1)**s * F * 2**E

GLOBALS USED
   -none-
        
NOTES
   Remember to pre_allocate enough buffer space in ieee_float
   to accommodate no_floats conversions.

HISTORY
   ??/??/?? M. Mathis, M. Lanier
      Created
*/

static HPfltvax_to_flt32 (IGRint no_floats,
                   unsigned long vax_float[],
                       IGRdouble * ieee_float)

   {
   union
      {
      IGRdouble *d;
      unsigned long *l;
      unsigned short *s;
      }     ptr;

   unsigned long temp[2];       /* temporary ieee format storage */
   register long sign;  /* sign bit */
   register long e;     /* ieee exponent mask */
   char zero;   /* is it zero */

   int i;


   for (i = 0; i < no_floats; i++)
      {
      temp[0] = vax_float[i * 2];
      temp[1] = vax_float[1 + (i * 2)];

#     if defined (BIG_ENDIAN)
      HSconv_int (temp, 2);
#     endif

      /* Swap the words in the VAX floating point number   */

      swp_int (&temp[0]);       /* swap first longword */
      swp_int (&temp[1]);       /* swap second longword */

      if ((temp[0] == 0) && (temp[1] == 0))
         zero = 1;
      else
         zero = 0;

      /* get the sign bit   */

      if (zero == 0)
         {

         sign = (long) temp[0] & (0x1 << 31);

         /*
          * Get the low order 3 bits from the first longword; these bits will
          * be transfered to the high order bits of the second longword; this
          * allows for the extended exponent field in the ieee format and the
          * mantissa being reduced from 55 bits to 53 bits.
          */

         temp[1] = (temp[1] >> 3) | ((temp[0] & 0x7) << 29);

         /*
          * Adjust the exponent field to 11 bits.  This bias is being changed
          * from 128 (VAX) to 1023 (IEEE).  In order to compensate for the
          * normalized mantissa, .1 for VAX and 1. for IEEE, add 1 to the
          * IEEE bias in the exponent.
          */

         e = (temp[0] >> 23) & 0xff;
         e = 1022 + (e - 128);

         /*
          * Add the new exponent along with the sign bit to the first
          * longword
          */

         temp[0] >>= 3;
         temp[0] &= ~(0x7ff << 20);
         temp[0] |= (e << 20);
         temp[0] |= sign;
         }

      /*
       * Cast the two longword integers representing the ieee format into a
       * double type variable.
       */

      if (zero == 1)
         {
         temp[0] = 0;
         temp[1] = 0;
         }

      ptr.d = (ieee_float + i);

#     if defined (BIG_ENDIAN)
         *ptr.l++ = temp[0];
         *ptr.l = temp[1];
#     else
         *ptr.l++ = temp[1];
         *ptr.l = temp[0];
#     endif
      }
   }


/*---HPflt32_to_fltvax--------------------------------------------------*/

/*
NAME
   HPflt32_to_fltvax

DESCRIPTION
   convert the IEEE floating point number format
   to the VAX/VMS floating point number format
                        
PARAMETERS
   no_floats  :(IN) :  Number of floats to convert
   ieee_float  :(IN) :  Array of ieee floating point numbers
   vax_float  :(OUT):  Array of vax floating point numbers
        
ALGORITHM
   Convert the  32032 IEEE format to host VAX floating point numbers.
   A buffer of several floating point numbers
   can be converted at the same time.  The VAX floating point number
   is defined in two longwords.

      31               9 8     0
       -------------------------
       |     f        |s|   e  |
       -------------------------
       |           f           |
       -------------------------
      63         32

   VAX Floating Point Format (64 bit double precision):
      s = sign bit
      e = biased exponent (8 bits)   Bias = 2**(e-1)
      f = mantissa (55 bits)   0 <= f < 1
          implied high order bit (hidden bit)

          true exponent  E = e - Bias
          true mantissa  F = .1f
                        
          X = (-1)**s * F * 2**E

                
      31     0
       ---------------------------
       |             f           |
       ---------------------------
       |s|    e    |     f   |
       ---------------------------
      63     52   32

      IEEE Floating Point Format  (64 bit double precision):
         s = sign bit
         e = biased exponent (11 bits)   Bias = 2**(e-1) - 1
         f = mantissa (52 bits)   1 <= f < 2
             implied high order bit (hidden bit)

             true exponent  E = e - Bias
             true mantissa  F = 1.f

             X = (-1)**s * F * 2**E


GLOBALS USED
   -none-

NOTES
   Remember to pre_allocate enough buffer space in vax_float
   to accommodate no_floats conversions.

HISTORY
   ??/??/?? M. Mathis, M. Lanier
      Created
*/

static void HPflt32_to_fltvax (IGRint no_floats,
                            IGRdouble * ieee_float,
                             unsigned long vax_float[])

   {
   unsigned short *vax_ptr;
   unsigned short *ieee_ptr;
   unsigned long *lvax_ptr;
   unsigned long *lieee_ptr;
   unsigned long expon;
   unsigned long sign;
   unsigned long msb;

   int i;


   for (i = 0; i < no_floats; i++)
      {
      vax_ptr = (unsigned short *) &vax_float[i * 2];
      lvax_ptr = (unsigned long *) vax_ptr;
      ieee_ptr = (unsigned short *) ieee_float++;
      lieee_ptr = (unsigned long *) ieee_ptr;

#     if defined (BIG_ENDIAN)
         sign = lieee_ptr[0];
         lieee_ptr[0] = lieee_ptr[1];
         lieee_ptr[1] = sign;
#     endif

      /* check for zero  */

      if (*lieee_ptr == 0 && (*(lieee_ptr + 1) & 0x7fffffff) == 0)
         {
         *lvax_ptr++ = 0;
         *lvax_ptr = 0;
         }
      else
         {

         /* copy to vax number */

         lvax_ptr[0] = lieee_ptr[0];
         lvax_ptr[1] = lieee_ptr[1];

         /* adjust exponent (ieee -1023 +128 -1 = VAX)  */

#        if defined (BIG_ENDIAN)
            expon = ((vax_ptr[2] >> 4) & 0x7ff) - 894;
#        else
            expon = ((vax_ptr[3] >> 4) & 0x7ff) - 894;
#        endif

         /* save sign */

         sign = lvax_ptr[1] & 0x80000000;

         /* we need to shift the entire f field left 3 bits. */
         /* we shift longwords, saving 3 msbs before shift */

         msb = (lvax_ptr[0] & 0xe0000000) >> 29;
         lvax_ptr[0] <<= 3;

         lvax_ptr[1] = (((lvax_ptr[1] << 3) | msb) & 0x007fffff) | (expon << 23) | sign;

         /* swap to vax word order  (use sign as a temp) */

         sign = vax_ptr[0];
         vax_ptr[0] = vax_ptr[3];
         vax_ptr[3] = sign;

         sign = vax_ptr[1];
         vax_ptr[1] = vax_ptr[2];
         vax_ptr[2] = sign;
         }
      }
   }

/*
 *  The following are type 90 header element and RGB class
 *  component
 */

struct RSext_attributes
   {
   IGRchar attr_length;
   IGRchar attr_type;
   IGRlong priority;
   };

struct RSraster_type_90
   {
   struct GUcommon_header_info header;
   IGRlong wds_in_descript;
   IGRchar comptype;
   IGRchar version;
   IGRchar filespec[66];
   IGRshort rasterid;
   IGRshort file_offset[2];
   IGRshort origin[12];
   IGRshort width[4];
   IGRshort height[4];
   IGRchar logical_name[24];
   IGRchar description[42];
   struct RSext_attributes ext_attributes;
   };

struct RScot_rgb_type_90
   {
   struct GUcommon_header_info header;
   IGRchar comptype;
   IGRchar version;
   IGRchar tp_color[4];
   IGRshort display_flags;
   };

#define SWAP( a, b, t ) { (t) = (a); (a) = (b); (b) = (t); }

/*---HPattach_raster_file--------------------------------------*/

/*
NAME
   HPattach_raster_file
        
KEYWORDS
   shaded plotting
   raster element by reference
        
DESCRIPTION
   This function will write a raster element by reference attachment
   into the textfile
        
PARAMETERS
   rasfil :(IN) : Name of the rasterfile being attached
        
GLOBALS USED
   outfile  : File pointer to the output igds file

FUNCTIONS CALLED
   GUswapint
   sprintf
   fopen
   fseek
   ftell
   memcpy
   HPfltvax_to_flt32
   HPflt32_to_fltvax
   MAnint
   GUswaprange_igeigds
   write
        
HISTORY
   ??/??/?? M. Lanier
      Created
*/

static void HPattach_raster_file (IGRchar * rasfil)

   {
   struct RSraster_type_90 *type90;
   struct RScot_rgb_type_90 cot_rgb_type90;
   IGRchar buffer[256];

   FILE *fileptr;
   IGRint file_offset;

   unsigned long vax_float[32];
   IGRdouble xform_plot_to_DB[16];

   IGRdouble origin[3];
   IGRdouble row_spacing, col_spacing;

   IGRlong int_range[6];
   IGRdouble range[6];

   IGRint i, bytes;
   unsigned short t;


   /*
    * Initialize the type90 header element
    */

   type90 = (struct RSraster_type_90 *) buffer;

   type90->header.type = 90;
   type90->header.level = 1;
   type90->header.words_to_follow = 108;
   type90->header.graphic_group = 0;
   type90->header.index_to_ae = 94;
   type90->header.properties = 0x5000;
   type90->header.symbology = 0;

   /*
    * 24 for the RGB element and 90 for this element
    */

   type90->wds_in_descript = 24 + 90;
   GUswapint (&type90->wds_in_descript, &type90->wds_in_descript);
   type90->version = 0;
   type90->comptype = 0;

   sprintf (type90->filespec, "RASTERFILE");

   type90->rasterid = 0;
   type90->logical_name[0] = '\0';
   type90->description[0] = '\0';

   fileptr = fopen (rasfil, "r");
   fseek (fileptr, 0, 0);
   file_offset = ftell (fileptr);
   GUswapint (&file_offset, &file_offset);
   memcpy (type90->file_offset, &file_offset, 4);

   memcpy (vax_float, plotting_type5.xform_plot_to_DB, 128);

   HPfltvax_to_flt32 (16, vax_float, xform_plot_to_DB);

   origin[0] = xform_plot_to_DB[12];
   origin[1] = xform_plot_to_DB[13];
   origin[2] = xform_plot_to_DB[14];

   HPflt32_to_fltvax (3, origin, vax_float);

   memcpy (type90->origin, vax_float, 24);

   range[0] = -2147483647;
   range[1] = -2147483647;
   range[2] = -2147483647;
   range[3] = 2147483647;
   range[4] = 2147483647;
   range[5] = 2147483647;

   for (i = 0; i < 6; i++)
      {
      int_range[i] = MAnint (range[i]);
      GUswaprange_igeigds (&int_range[i], &int_range[i]);

      type90->header.range[i] = int_range[i];
      cot_rgb_type90.header.range[i] = int_range[i];
      }

#  ifdef BIG_ENDIAN
      HSconv_int (&plotting_type5.clip_xhigh, 1);
      HSconv_int (&plotting_type5.clip_yhigh, 1);
#  endif

   row_spacing = plotting_type5.clip_xhigh;
   col_spacing = plotting_type5.clip_yhigh;

   HPflt32_to_fltvax (1, &col_spacing, vax_float);

   memcpy (type90->width, vax_float, 8);

   HPflt32_to_fltvax (1, &row_spacing, vax_float);

   memcpy (type90->height, vax_float, 8);

   bytes = (type90->header.words_to_follow + 2) << 1;

#  ifdef BIG_ENDIAN
      HSconv_short (&type90->header.words_to_follow, 1);
      HSconv_int (type90->header.range, 6);
      HSconv_short (&type90->header.graphic_group, 1);
      HSconv_short (&type90->header.index_to_ae, 1);
      HSconv_short (&type90->header.properties, 1);
      HSconv_short (&type90->header.symbology, 1);
      HSconv_int (&type90->wds_in_descript, 1);
      HSconv_short (&type90->rasterid, 1);
      HSconv_short (type90->file_offset, 2);

      SWAP( type90->origin[0], type90->origin[1], t )
      SWAP( type90->origin[2], type90->origin[3], t )
      SWAP( type90->origin[4], type90->origin[5], t )
      SWAP( type90->origin[6], type90->origin[7], t )
      SWAP( type90->origin[8], type90->origin[9], t )
      SWAP( type90->origin[10], type90->origin[11], t )

      SWAP( type90->width[0], type90->width[1], t )
      SWAP( type90->width[2], type90->width[3], t )

      SWAP( type90->height[0], type90->height[1], t )
      SWAP( type90->height[2], type90->height[3], t )

      HSconv_short (  type90->origin, 12 );
      HSconv_short (  type90->width, 4 );
      HSconv_short (  type90->height, 4 );

      HSconv_int (&type90->ext_attributes.priority, 1);
#  endif

   write (outfile, type90, bytes );

   cot_rgb_type90.tp_color[0] = 0;
   cot_rgb_type90.tp_color[1] = 0;
   cot_rgb_type90.tp_color[2] = 0;
   cot_rgb_type90.tp_color[3] = 0;

   cot_rgb_type90.header.level = 1;
   cot_rgb_type90.header.level |= 0x80; /* set complex bit  */
   cot_rgb_type90.header.type = 90;
   cot_rgb_type90.header.words_to_follow = 20;

   cot_rgb_type90.header.graphic_group = 0;
   cot_rgb_type90.header.index_to_ae = 7;
   cot_rgb_type90.header.properties = 0x5200;
   cot_rgb_type90.header.symbology = 0;
   cot_rgb_type90.version = 0;

   cot_rgb_type90.comptype = 3;

   cot_rgb_type90.display_flags = 1;

   bytes = (cot_rgb_type90.header.words_to_follow + 2) << 1;

#  ifdef BIG_ENDIAN
      HSconv_short (&cot_rgb_type90.header.words_to_follow, 1);
      HSconv_int (cot_rgb_type90.header.range, 6);
      HSconv_short (&cot_rgb_type90.header.graphic_group, 1);
      HSconv_short (&cot_rgb_type90.header.index_to_ae, 1);
      HSconv_short (&cot_rgb_type90.header.properties, 1);
      HSconv_short (&cot_rgb_type90.header.symbology, 1);
      HSconv_short (&cot_rgb_type90.display_flags, 1);
#  endif

   write (outfile, &cot_rgb_type90, bytes );
   }

/*---HPcreate_textfile_with_raster_attachment------------------------------------*/

/*
NAME
   HPcreate_textfile_with_raster_attachment
        
KEYWORDS
   shaded plotting
   raster element by reference
        
DESCRIPTION
   This function will create an IGDS textfile, *out_meta, using as input the
   existing IGDS textfile, *in_meta.  The function will copy the element of the
   existing textfile to the output textfile one at a time, inserting a raster
   element by referenc attachment for the rasterfile, *rasfil, after the plotting
   type 5.
        
PARAMETERS
   in_meta  :(IN) :  Name of the input igds file
   rasfil  :(IN) :  Name of the rasterfile to attach
   out_meta :(IN) :  Name of the output igds file
        
GLOBALS USED
   infile
   outfile
        
FUNCTIONS CALLED
   open
   read
   write
   HPattach_raster_file
        
HISTORY
   ??/??/?? M. Lanier
      Created
*/

HPcreate_textfile_with_raster_attachment (IGRchar * in_meta,
                                          IGRchar * rasfil,
                                          IGRchar * out_meta)

   {
   unsigned short header[2], levtype, wtf;
   unsigned char *addr = NULL;

   IGRint total_bytes, nread;
   IGRint bytes_read;
   IGRchar buffer[MAXBUFSIZ];


#  if DEBUG
   fprintf (stderr, "HPcreate_textfile_with_raster_attachment\n");
   fprintf (stderr, "   in_meta --- %s\n", in_meta);
   fprintf (stderr, "   rasfil ---- %s\n", rasfil);
   fprintf (stderr, "   out_meta -- %s\n", out_meta);
#  endif

   infile = open (in_meta, 0);
   outfile = open (out_meta, O_CREAT | O_RDWR, 0777);

   for (;;)
      {

      /*
       * Read the element header and determine how many bytes are to be
       * transfered.  Write the element header.  Stop when header[0] is
       * 0xffff
       */

      nread = read (infile, header, 4);
      if (nread <= 0)
         break;

      write (outfile, header, 4);

      levtype = header[0];
      wtf = header[1];

#     ifdef BIG_ENDIAN
      HSconv_short (&levtype, 1);
      HSconv_short (&wtf, 1);
#     endif

      if (levtype == 0xffff) break;

      if (((levtype >> 8) == 5) &&
          ((levtype & 0xf) == 4))
         {
         addr = (unsigned char *) &plotting_type5;
         memcpy (addr, header, 4);
         addr += 4;
         }

      total_bytes = (wtf << 1);
      bytes_read = MAXBUFSIZ;

      /*
       * Transfer the element, MAXBUFSIZ bytes at a time
       */

      while (total_bytes > 0)
         {
         if (bytes_read > total_bytes)
            bytes_read = total_bytes;
         total_bytes -= bytes_read;

         read (infile, buffer, bytes_read);
         write (outfile, buffer, bytes_read);

         if (((levtype >> 8) == 5) &&
             ((levtype & 0xf) == 4))
            {
            memcpy (addr, buffer, bytes_read);
            addr += bytes_read;
            }
         }

      if (((levtype >> 8) == 5) &&
          ((levtype & 0xf) == 4))
         HPattach_raster_file (rasfil);
      }

   close (outfile);
   }
