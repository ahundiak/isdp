#include <stdio.h>

#if defined (CLIX)
#include "odi.h"
#endif

#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "hsdef.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPdef.h"

#include "dump.h"

/*---dump_bytes---------------------------------------*/

int dump_bytes ( FILE *ofp,                   /* output file pointer */
                 long number,                 /* number of bytes to dump/print */
                 unsigned char *buffer_ptr )  /* pointer to buffer to dump */


   {
   int           count = 1;       /* number of bytes with same value */
   int           line_ct = 4;     /* entries per line counter */
   unsigned char previous;        /* previous byte */
   unsigned char this;            /* current byte */

   /* null case, number not positive */

   if (number <= 0) return HSplot_success;


   /* get first byte to start things off */

   previous = *buffer_ptr++;

   while (--number)
      {
      this = *buffer_ptr++;
      if (this == previous)
         ++count;
      else
         {
         if (line_ct >= 20)
            {
            putc ('\n', ofp);
            line_ct = 0;
            }

         if (line_ct++) putc (' ', ofp);

         if (count > 1)
            {
            ++line_ct;
            fprintf (ofp, "%d*%d", count, previous);
            }
         else
            fprintf (ofp, "%d", previous);

         count = 1;
         previous = this;
         }
      }

   if (line_ct > 20)
      {
      putc ('\n', ofp);
      line_ct = 0;
      }

   if (line_ct++) putc (' ', ofp);

   if (count > 1)
      fprintf (ofp, "%d*%d", count, previous);
   else
      fprintf (ofp, "%d", previous);

   return HSplot_success;
   }
