#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <math.h>
#include "wl.h"

#if defined (CLIX)
#include <EG.h>
#endif
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "hstiler.h"
#include "hslight.h"
#include "hplot.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

/*------------------------
 *  for
 *    HSset_line_style
 */

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------*/


/*---HPget_scale----------------------------------------------------------*/

/*
NAME
   HPget_scale
        
KEYWORDS
   HSplot
   utilities
        
DESCRIPTION
   Compute the world to viewport scale
        
RETURN VALUES
   The world to viewport scale
        
ALGORITHM
   Take a normalized vector, transform it to the
   view and compute it's magnitude.
        
GLOBALS USED
   HPglobal		: global structure
           xform.m16	:
           viewport	:
           perspective	:
                
HISTORY
   ??/??/??	M. Lanier
           Created
*/

double HPget_scale (void)

   {
   double sqrt ();
   double a[3], b[3];
   double xs, ys, zs;

   a[0] = 0.577350269;
   a[1] = 0.577350269;
   a[2] = 0.577350269;

   b[0] = (HPglobal.xform.m16[0] * a[0]) +
      (HPglobal.xform.m16[4] * a[1]) +
      (HPglobal.xform.m16[8] * a[2]) +
      (HPglobal.xform.m16[12]);

   b[1] = (HPglobal.xform.m16[1] * a[0]) +
      (HPglobal.xform.m16[5] * a[1]) +
      (HPglobal.xform.m16[9] * a[2]) +
      (HPglobal.xform.m16[13]);

   b[2] = (HPglobal.xform.m16[2] * a[0]) +
      (HPglobal.xform.m16[6] * a[1]) +
      (HPglobal.xform.m16[10] * a[2]) +
      (HPglobal.xform.m16[14]);

   if (HPglobal.perspective)
      {
      xs = (HPglobal.viewport[3] - HPglobal.viewport[0]) / 2;
      ys = (HPglobal.viewport[4] - HPglobal.viewport[1]) / 2;
      zs = (HPglobal.viewport[5] - HPglobal.viewport[2]) / 2;

      b[0] *= xs;
      b[1] *= ys;
      b[2] *= zs;
      }

   return (sqrt ((b[0] * b[0]) + (b[1] * b[1]) + (b[2] * b[2])));
   }

/*---HPtranspose_matrix-----------------------------------------------*/

/*
NAME
   HPtranspose_matrix

KEYWORDS
   HSplot
   utilities
        
DESCRIPTION
   Given a 4x4 matrix, compute its transpose
        
HISTORY
   ??/??/??	M. Lanier
           Created
*/

void HPtranspose_matrix (double a[4][4])

   {
   double b;

   b = a[0][1];
   a[0][1] = a[1][0];
   a[1][0] = b;
   b = a[0][2];
   a[0][2] = a[2][0];
   a[2][0] = b;
   b = a[0][3];
   a[0][3] = a[3][0];
   a[3][0] = b;
   b = a[1][2];
   a[1][2] = a[2][1];
   a[2][1] = b;
   b = a[1][3];
   a[1][3] = a[3][1];
   a[3][1] = b;
   b = a[2][3];
   a[2][3] = a[3][2];
   a[3][2] = b;
   }

/*---HPmake_scaling_matrix-----------------------------------------------*/

/*
NAME
   HPmake_scaling_matrix
        
KEYWORDS
   HSplot
   utilities
        
DESCRIPTION
   Create a scaling matrix
        
PAREMETERS
   m		:(OUT):  The output scale matrix
   scale_factor	:(IN) :  The scale factor
        
HISTORY
   ??/??/??	M. Lanier
           Created
*/

void HPmake_scaling_matrix (double m[4][4],
                                 double scale_factor)

   {
   m[0][0] = scale_factor;
   m[0][1] = 0.0;
   m[0][2] = 0.0;
   m[0][3] = 0.0;

   m[1][0] = 0.0;
   m[1][1] = scale_factor;
   m[1][2] = 0.0;
   m[1][3] = 0.0;

   m[2][0] = 0.0;
   m[2][1] = 0.0;
   m[2][2] = scale_factor;
   m[2][3] = 0.0;

   m[3][0] = 0.0;
   m[3][1] = 0.0;
   m[3][2] = 0.0;
   m[3][3] = 1.0;
   }

/*---HPmatrix_multiply---------------------------------------------------*/

/*
NAME
   HPmatrix_multiply
        
KEYWORDS
   HSplot
   utilities
        
DESCRIPTION
   Multiply two matrices
        
PARAMETERS
   a, b	:(IN) :  The input matrices to multiply
   c	:(OUT):  The product matrix
        
HISTORY
   ??/??/??	M. Lanier
           Created
*/

void HPmatrix_multiply (double a[4][4],
                             double b[4][4],
                             double c[4][4])

   {
   int i, j, k;

   for (i = 0; i < 4; i++)
      for (j = 0; j < 4; j++)
         {
         c[i][j] = 0.0;

         for (k = 0; k < 4; k++)
            c[i][j] += (a[i][k] * b[k][j]);
         }
   }

/*---HPcopy_matrix----------------------------------------------------*/

/*
NAME
   HPcopy_matrix
        
KEYWORDS
   HSplot
   utilities
        
DESCRIPTION
   Copy a matrix
        
PARAMTERS
   a	:(IN) :  The source matrix
   b	:(OUT):  The destination matrix
        
HISTORY
   ??/??/??	M. Lanier
           Created
*/

void HPcopy_matrix (double a[4][4],
                         double b[4][4])

   {
   int i, j;

   for (i = 0; i < 4; i++)
      for (j = 0; j < 4; j++)
         b[i][j] = a[i][j];
   }

/*---HPdump_matrix----------------------------------------------------*/

/*
NAME
   HPdump_matrix
        
KEYWORDS
   HSplot
   utilities
   debug
        
DESCRIPTION
   Create ascii display of the matrix
        
PARAMETERS
   s	:(IN) :  Title for the matrix
   m	:(IN) :  The matrix
*/

void HPdump_matrix (char s[],
                         double m[4][4])

   {
   fprintf (stderr, "%s\n", s);
   fprintf (stderr, "   %17.8f %17.8f %17.8f %17.8f\n", m[0][0], m[1][0], m[2][0], m[3][0]);
   fprintf (stderr, "   %17.8f %17.8f %17.8f %17.8f\n", m[0][1], m[1][1], m[2][1], m[3][1]);
   fprintf (stderr, "   %17.8f %17.8f %17.8f %17.8f\n", m[0][2], m[1][2], m[2][2], m[3][2]);
   fprintf (stderr, "   %17.8f %17.8f %17.8f %17.8f\n", m[0][3], m[1][3], m[2][3], m[3][3]);
   }

/*---HPscale_matrix-----------------------------------------------------*/

/*
NAME
   HPscale_matrix
        
KEYWORDS
   HSplot
   utilities
        
DESCRIPTION
   Apply a scale to a matrix
        
PARAMTERS
   m	:(IN/OUT): matrix to scale
   s	:(IN)    : scale factor
        
HISTORY
   ??/??/??	M. Lanier
           Created
*/

void HPscale_matrix (double m[4][4],
                          double s)

   {
   int i, j;

   for (i = 0; i < 4; i++)
      for (j = 0; j < 4; j++)
         m[i][j] *= s;

   m[3][3] = 1;
   }

/*---HPfree_band_memory----------------------------------------------*/

/*
NAME
   HPfree_band_memory
        
KEYWORDS
   HSplot
   utilities
   memory
        
DESCRIPTION
   Free memory allocated for image/zbuffer
        
GLOBALS USED
   HPglobal		: global structure
           band_buffer	: address of the memory to free
                
HISTORY
   ??/??/??	M. Lanier
           Created
*/

void HPfree_band_memory (void)

   {
   if (HPglobal.band_buffer != NULL)
      free (HPglobal.band_buffer);
   }

/*---DPinq_style-----------------------------------------------------*/

/*
NAME
   DPinq_style
        
KEYWORDS
   HSplot
   utilities
   style
        
DESCRIPTION
   The HSplot replacement for the DPinq_style function in EMS. This
   allows HSplot to call HSset_line_style, which calls this function
        
PARAMETERS
   index		:(IN) :  The line style to retrieve
   pattern		:(OUT):  pointer to the line style buffer
        
GLOBALS USED
   HPglobal		: global structure
           user_line_styles: array of line styles
                
HISTORY
   ??/??/??	M. Lanier
           Created
*/

void DPinq_style (unsigned int index,
                       unsigned short *pattern)

   {
   *pattern = HPglobal.user_line_styles[index];
   }

/*---HPin_ignore_list-------------------------------------------------*/

int	HPin_ignore_list( int objid, short osnum )
   {
   struct HPignore_list	*l;

   l = HPglobal.ignore_list;
   while( l != NULL )
      {
      if( l->objid == objid && l->osnum == osnum ) return TRUE;
      l = l->next;
      }

   return FALSE;
   }


static struct tms tms_data;
static int last_time = 0;
static int curr_time = 0;

void HPheartbeat()
   {
   curr_time = times( &tms_data );
   if( (curr_time - last_time) > 30 )
      {
      printf( "." );
      fflush(stdout);
      last_time = curr_time;
      }
   }
