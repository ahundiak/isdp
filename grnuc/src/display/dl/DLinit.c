#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern double *DLIbuf /*= NULL*/;  /* Big Dog malloc for polygon/linestrings */
extern int DLIterm_flag /*= FALSE*/;
extern int DLIfb_tags_flag /*= 0*/;
extern int DLIreport_errors /*= FALSE*/;

/* globals for linestring buffering */
extern struct WLpoint DLIsaved_points[DLI_NUM_SAVED_POINTS];
extern int DLInum_points /*= 0*/;

#if defined( ENV5 )
static int DLIuse_gpipe;
static int DLIuse_eg;
#endif

static struct DLpipeline *DLIpipes[DL_MAX_PIPES] = {0};

#if defined( OPENGL )

struct DLIgl_enable_query
{
   int cap;
   char name[50];
};

#define NUM_GL_ENABLE_QUERIES 18
static struct DLIgl_enable_query gl_enable_queries[NUM_GL_ENABLE_QUERIES] =
{
   GL_ALPHA_TEST, "GL_ALPHA_TEST",
   GL_AUTO_NORMAL, "GL_AUTO_NORMAL",
   GL_BLEND, "GL_BLEND",
   GL_COLOR_MATERIAL, "GL_COLOR_MATERIAL",
   GL_CULL_FACE, "GL_CULL_FACE",
   GL_DEPTH_TEST, "GL_DEPTH_TEST",
   GL_DITHER, "GL_DITHER",
   GL_FOG, "GL_FOG",
   GL_LIGHTING, "GL_LIGHTING",
   GL_LINE_SMOOTH, "GL_LINE_SMOOTH",
   GL_LINE_STIPPLE, "GL_LINE_STIPPLE",
   GL_LOGIC_OP, "GL_LOGIC_OP",
   GL_NORMALIZE, "GL_NORMALIZE",
   GL_POINT_SMOOTH, "GL_POINT_SMOOTH",
   GL_POLYGON_SMOOTH, "GL_POLYGON_SMOOTH",
   GL_POLYGON_STIPPLE, "GL_POLYGON_STIPPLE",
   GL_SCISSOR_TEST, "GL_SCISSOR_TEST",
   GL_STENCIL_TEST, "GL_STENCIL_TEST",
};

/*--- DLIquery_gl_enable_status --------------------------------------------------*/

void DLIquery_gl_enable_status(
   void )

/*
NAME
	DLIquery_gl_enable_status

DESCRIPTION
	This function dumps the current state of GL to stderr

SYNOPSIS
	void DLIquery_gl_enable_status(
	   void )

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	01/12/93    S.P. Rogers
	   Creation Date
*/

{
   int ii;

   fprintf( stderr, "ENABLE DATA\n" );

   for ( ii = 0; ii < NUM_GL_ENABLE_QUERIES; ii++ )
   {
      fprintf( stderr, "   %s:  %s\n", gl_enable_queries[ii].name,
         glIsEnabled( gl_enable_queries[ii].cap ) ? "yes" : "no" );
   }

}  /* DLIquery_gl_enable_status */


void DLIquery_gl_state(
   void )

{
   int ii;
   GLint iparms[20];
   GLdouble dparms[20];
   GLboolean bparms[20];

   glGetBooleanv( GL_INDEX_MODE, bparms );
   fprintf( stderr, "   GL_INDEX_MODE: %d\n", bparms[0] );

   if ( bparms[0] )
   {
      glGetIntegerv( GL_CURRENT_INDEX, iparms );
      fprintf( stderr, "   GL_CURRENT_INDEX: %d\n", iparms[0] );

      glGetIntegerv( GL_INDEX_WRITEMASK, iparms );
      fprintf( stderr, "   GL_INDEX_WRITEMASK: %#X\n", iparms[0] );
   }

   glGetBooleanv( GL_RGBA_MODE, bparms );
   fprintf( stderr, "   GL_RGBA_MODE: %d\n", bparms[0] );

   if ( bparms[0] )
   {
      glGetDoublev( GL_CURRENT_COLOR, dparms );
      fprintf( stderr, "   GL_CURRENT_COLOR: %lf %lf %lf %lf\n",
               dparms[0], dparms[1], dparms[2], dparms[3] );
   }

   glGetIntegerv( GL_RENDER_MODE, iparms );
   fprintf( stderr, "   GL_RENDER_MODE:  " );
   switch ( iparms[0] )
   {
      case GL_RENDER :
         fprintf( stderr, "GL_RENDER\n" );
         break;
      case GL_SELECT :
         fprintf( stderr, "GL_SELECT\n" );
         break;
      case GL_FEEDBACK :
         fprintf( stderr, "GL_FEEDBACK\n" );
         break;
   }

   glGetIntegerv( GL_DRAW_BUFFER, iparms );
   fprintf( stderr, "   GL_DRAW_BUFFER: ", iparms[0] );
   switch ( iparms[0] )
   {
      case GL_NONE :
         fprintf( stderr, "GL_NONE\n" );
         break;
      case GL_FRONT_LEFT :
         fprintf( stderr, "GL_FRONT_LEFT\n" );
         break;
      case GL_FRONT_RIGHT :
         fprintf( stderr, "GL_FRONT_RIGHT\n" );
         break;
      case GL_BACK_LEFT :
         fprintf( stderr, "GL_BACK_LEFT\n" );
         break;
      case GL_BACK_RIGHT :
         fprintf( stderr, "GL_BACK_RIGHT\n" );
         break;
      case GL_FRONT :
         fprintf( stderr, "GL_FRONT\n" );
         break;
      case GL_BACK :
         fprintf( stderr, "GL_BACK\n" );
         break;
      case GL_LEFT :
         fprintf( stderr, "GL_LEFT\n" );
         break;
      case GL_RIGHT :
         fprintf( stderr, "GL_RIGHT\n" );
         break;
      case GL_FRONT_AND_BACK :
         fprintf( stderr, "GL_FRONT_AND_BACK\n" );
         break;
      default:
         fprintf( stderr, "%d\n", iparms[0] );
         break;
   }

   glGetIntegerv( GL_LOGIC_OP_MODE, iparms );
   fprintf( stderr, "   GL_LOGIC_OP_MODE: " );
   switch ( iparms[0] )
   {
      case GL_CLEAR :
         fprintf( stderr, "GL_CLEAR\n" );
         break;
      case GL_SET :
         fprintf( stderr, "GL_SET\n" );
         break;
      case GL_COPY :
         fprintf( stderr, "GL_COPY\n" );
         break;
      case GL_COPY_INVERTED :
         fprintf( stderr, "GL_COPY_INVERTED\n" );
         break;
      case GL_NOOP :
         fprintf( stderr, "GL_NOOP\n" );
         break;
      case GL_INVERT :
         fprintf( stderr, "GL_INVERT\n" );
         break;
      case GL_AND :
         fprintf( stderr, "GL_AND\n" );
         break;
      case GL_NAND :
         fprintf( stderr, "GL_NAND\n" );
         break;
      case GL_OR :
         fprintf( stderr, "GL_OR\n" );
         break;
      case GL_NOR :
         fprintf( stderr, "GL_NOR\n" );
         break;
      case GL_XOR :
         fprintf( stderr, "GL_XOR\n" );
         break;
      case GL_EQUIV :
         fprintf( stderr, "GL_EQUIV\n" );
         break;
      case GL_AND_REVERSE :
         fprintf( stderr, "GL_AND_REVERSE\n" );
         break;
      case GL_AND_INVERTED :
         fprintf( stderr, "GL_AND_INVERTED\n" );
         break;
      case GL_OR_REVERSE :
         fprintf( stderr, "GL_OR_REVERSE\n" );
         break;
      case GL_OR_INVERTED :
         fprintf( stderr, "GL_OR_INVERTED\n" );
         break;
   }

   for ( ii = 0; ii < 2; ii++ )
   {
      if ( ii == 0 )
      {
         glGetIntegerv( GL_BLEND_SRC, iparms );
         fprintf( stderr, "   GL_BLEND_SRC: " );
      }
      else
      {
         glGetIntegerv( GL_BLEND_DST, iparms );
         fprintf( stderr, "   GL_BLEND_DST: " );
      }

      switch ( iparms[0] )
      {
         case GL_ZERO :
            fprintf( stderr, "GL_ZERO\n" );
            break;
         case GL_ONE :
            fprintf( stderr, "GL_ONE\n" );
            break;
         case GL_SRC_COLOR :
            fprintf( stderr, "GL_SRC_COLOR\n" );
            break;
         case GL_ONE_MINUS_SRC_COLOR :
            fprintf( stderr, "GL_ONE_MINUS_SRC_COLOR\n" );
            break;
         case GL_DST_COLOR :
            fprintf( stderr, "GL_DST_COLOR\n" );
            break;
         case GL_ONE_MINUS_DST_COLOR :
            fprintf( stderr, "GL_ONE_MINUS_DST_COLOR\n" );
            break;
         case GL_SRC_ALPHA :
            fprintf( stderr, "GL_SRC_ALPHA\n" );
            break;
         case GL_ONE_MINUS_SRC_ALPHA :
            fprintf( stderr, "GL_ONE_MINUS_SRC_ALPHA\n" );
            break;
         case GL_DST_ALPHA :
            fprintf( stderr, "GL_DST_ALPHA\n" );
            break;
         case GL_ONE_MINUS_DST_ALPHA :
            fprintf( stderr, "GL_ONE_MINUS_DST_ALPHA\n" );
            break;
         case GL_SRC_ALPHA_SATURATE :
            fprintf( stderr, "GL_SRC_ALPHA_SATURATE\n" );
            break;
      }

   }  /* end: for */

   glGetIntegerv( GL_LINE_WIDTH, iparms );
   fprintf( stderr, "   GL_LINE_WIDTH: %d\n", iparms[0] );

   glGetIntegerv( GL_POINT_SIZE, iparms );
   fprintf( stderr, "   GL_POINT_SIZE: %d\n", iparms[0] );

   glGetIntegerv( GL_LINE_STIPPLE_PATTERN, iparms );
   fprintf( stderr, "   GL_LINE_STIPPLE_PATTERN: 0x%X\n", iparms[0] );

   glGetIntegerv( GL_LINE_STIPPLE_REPEAT, iparms );
   fprintf( stderr, "   GL_LINE_STIPPLE_REPEAT: %d\n", iparms[0] );

   glGetIntegerv( GL_POLYGON_MODE, iparms );
   fprintf( stderr, "   GL_POLYGON_MODE: " );
   switch ( iparms[0] )
   {
      case GL_FRONT :
         fprintf( stderr, "   GL_FRONT" );
         break;
      case GL_BACK :
         fprintf( stderr, "   GL_BACK" );
         break;
      case GL_FRONT_AND_BACK :
         fprintf( stderr, "   GL_FRONT_AND_BACK" );
         break;
   }

   switch ( iparms[1] )
   {
      case GL_POINT :
         fprintf( stderr, "   GL_POINT\n" );
         break;
      case GL_LINE :
         fprintf( stderr, "   GL_LINE\n" );
         break;
      case GL_FILL :
         fprintf( stderr, "   GL_FILL\n" );
         break;
   }

   glGetIntegerv( GL_MATRIX_MODE, iparms );
   fprintf( stderr, "   GL_MATRIX_MODE: " );
   switch ( iparms[0] )
   {
      case GL_MODELVIEW :
         fprintf( stderr, "GL_MODELVIEW\n" );
         break;
      case GL_PROJECTION :
         fprintf( stderr, "GL_PROJECTION\n" );
         break;
      case GL_TEXTURE :
         fprintf( stderr, "GL_TEXTURE\n" );
         break;
   }

   glGetDoublev( GL_MODELVIEW_MATRIX, dparms );
   fprintf( stderr, "   GL_MODELVIEW_MATRIX:  %lf %lf %lf %lf\n",
            dparms[0], dparms[1], dparms[2], dparms[3] );
   fprintf( stderr, "                         %lf %lf %lf %lf\n",
            dparms[4], dparms[5], dparms[6], dparms[7] );
   fprintf( stderr, "                         %lf %lf %lf %lf\n",
            dparms[8], dparms[9], dparms[10], dparms[11] );
   fprintf( stderr, "                         %lf %lf %lf %lf\n",
            dparms[12], dparms[13], dparms[14], dparms[15] );

   glGetDoublev( GL_PROJECTION_MATRIX, dparms );
   fprintf( stderr, "   GL_PROJECTION_MATRIX:  %lf %lf %lf %lf\n",
            dparms[0], dparms[1], dparms[2], dparms[3] );
   fprintf( stderr, "                         %lf %lf %lf %lf\n",
            dparms[4], dparms[5], dparms[6], dparms[7] );
   fprintf( stderr, "                         %lf %lf %lf %lf\n",
            dparms[8], dparms[9], dparms[10], dparms[11] );
   fprintf( stderr, "                         %lf %lf %lf %lf\n",
            dparms[12], dparms[13], dparms[14], dparms[15] );

   glGetIntegerv( GL_VIEWPORT, iparms );
   fprintf( stderr, "   GL_VIEWPORT: %d %d %d %d\n",
            iparms[0], iparms[1], iparms[2], iparms[3] );

}  /* DLIquery_gl_state */

#endif

#if defined( ENV5 )
/*--- DLIquery_eg_state -----------------------------------------_*/

void DLIquery_eg_state(
   int pipe_id,
   int show_lights )

/*
NAME
	DLIquery_eg_state

DESCRIPTION
	This function dumps the current state of an EG
        pipeline to stderr

SYNOPSIS
	void DLIquery_eg_state(
	   int pipe_id,
           int show_lights )

PARAMETERS
	pipe_id (IN) - the pipeline whose EG data is to be
                       dumped
        show_lights (IN) - if TRUE, dump light source info

GLOBALS USED
	none

HISTORY
	07/15/93    S.P. Rogers
	   Creation Date
*/

{
   int sts;
   int ii;
   int win_no;
   struct DLpipeline *pipe;
   EGBoolean mode;
   EGRGBColor color;
   EGFaceCull cull_mode;
   EGReflEqn refl_eqn;
   EGRenderMethod render_method;


   fprintf( stderr, "EG Data for pipe: %d\n", pipe_id );

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      fprintf( stderr, "   Pipe is invalid\n" );
      return;
   }

   if ( !pipe->using_eg )
   {
      fprintf( stderr, "   Pipe is not using EG\n" );
      return;
   }

   fprintf( stderr, "   VC: %d\n", pipe->eg_vc );

   EGInqVCWindow( pipe->eg_vc, &win_no );
   fprintf( stderr, "   VCWindow: %d\n", win_no );

   EGInqAntiAliasedLineMode( pipe->eg_vc, &mode );
   fprintf( stderr, "   AnitAliasedLineMode: " );
   switch ( mode )
   {
      case EG_OFF :
         fprintf( stderr, "EG_OFF" );
         break;
      case EG_ON :
         fprintf( stderr, "EG_ON" );
         break;
   }
   fprintf( stderr, "\n" );

   EGInqBaseColor( pipe->eg_vc, &color );
   fprintf( stderr, "   BaseColor: %f %f %f\n",
            color.red, color.green, color.blue );

   EGInqDepthCueMode( pipe->eg_vc, &mode );
   fprintf( stderr, "   DepthCueMode: " );
   switch ( mode )
   {
      case EG_OFF :
         fprintf( stderr, "EG_OFF" );
         break;
      case EG_ON :
         fprintf( stderr, "EG_ON" );
         break;
   }
   fprintf( stderr, "\n" );

   EGInqFaceCullingMode( pipe->eg_vc, &cull_mode );
   fprintf( stderr, "   FaceCullingMode: " );
   switch ( cull_mode )
   {
      case EG_BACKFACE_CULL :
         fprintf( stderr, "EG_BACKFACE_CULL" );
         break;
      case EG_FRONTFACE_CULL :
         fprintf( stderr, "EG_FRONTFACE_CULL" );
         break;
      case EG_NO_CULL :
         fprintf( stderr, "EG_NO_CULL" );
         break;
   }
   fprintf( stderr, "\n" );

   EGInqLightingMode( pipe->eg_vc, &mode );
   fprintf( stderr, "   LightingMode: " );
   switch ( mode )
   {
      case EG_OFF :
         fprintf( stderr, "EG_OFF" );
         break;
      case EG_ON :
         fprintf( stderr, "EG_ON" );
         break;
   }
   fprintf( stderr, "\n" );

   EGInqNormReorientMode( pipe->eg_vc, &mode );
   fprintf( stderr, "   NormReorientMode: " );
   switch ( mode )
   {
      case EG_OFF :
         fprintf( stderr, "EG_OFF" );
         break;
      case EG_ON :
         fprintf( stderr, "EG_ON" );
         break;
   }
   fprintf( stderr, "\n" );

   EGInqReflectEqn( pipe->eg_vc, &refl_eqn );
   fprintf( stderr, "   ReflectEqn: " );
   switch (  refl_eqn )
   {
      case EG_REFL_NONE :
         fprintf( stderr, "EG_REFL_NONE" );
         break;
      case EG_REFL_AMB :
         fprintf( stderr, "EG_REFL_AMB" );
         break;
      case EG_REFL_AMB_DIF :
         fprintf( stderr, "EG_REFL_AMB_DIF" );
         break;
      case EG_REFL_AMB_DIF_SPEC :
         fprintf( stderr, "EG_REFL_AMB_DIF_SPEC" );
         break;
   }
   fprintf( stderr, "\n" );

   EGInqRenderMethod( pipe->eg_vc, &render_method );
   fprintf( stderr, "   RenderMethod: " );
   switch ( render_method )
   {
      case EG_RENDER_FLAT :
         fprintf( stderr, "EG_RENDER_FLAT" );
         break;
      case EG_RENDER_GOUR :
         fprintf( stderr, "EG_RENDER_GOUR" );
         break;
      case EG_RENDER_ENV_V :
         fprintf( stderr, "EG_RENDER_ENV_V" );
         break;
   }
   fprintf( stderr, "\n" );

   EGInqZBufferMode( pipe->eg_vc, &mode );
   fprintf( stderr, "   ZBufferMode: " );
   switch ( mode )
   {
      case EG_OFF :
         fprintf( stderr, "EG_OFF" );
         break;
      case EG_ON :
         fprintf( stderr, "EG_ON" );
         break;
   }
   fprintf( stderr, "\n" );

   if ( show_lights )
   {
      for ( ii = 0; ii < EG_NUM_LIGHT_SRC; ii++ )
      {
         EGInqLightSrcState( pipe->eg_vc, ii, &mode );
         if ( mode == EG_OFF )
         {
            fprintf( stderr, "   Light #%d: EG_OFF\n", ii );
         }
         else
         {
            fprintf( stderr, "   Light #%d: EG_ON\n", ii );
         }
      }
   }


}  /* DLIquery_eg_state */
#endif

/*--- DLIdump_fb_buffer --------------------------------------------------*/

int DLIdump_fb_buffer(
   void *fb_buffer )

/*
NAME
   DLIdump_fb_buffer

DESCRIPTION
   This function prints out a DL feedback buffer to stderr.

SYNOPSIS
   int DLIdump_fb_buffer(
      void *fb_buffer )

PARAMETERS
   fb_buffer (IN) - the feedback buffer to print

GLOBALS USED
   none

RETURN VALUES
   DL_SUCCESS
      Always

HISTORY
   05/18/93 S.P. Rogers
      Creation Date
*/

{
   WLuint16 tag;
   unsigned short flag;
   int total_qwtf, curve_qwtf, poly_qwtf, set_qwtf, qwtf;
   int num_points;
   double *d_ptr;
   int *i_ptr;

   i_ptr = (int *) fb_buffer;
   d_ptr = (double *) i_ptr;

   tag = ((WLuint16 *)i_ptr)[0];
   flag = ((short *)i_ptr)[1];

   total_qwtf = i_ptr[1];
   
   fprintf( stderr, "TAG: 0x%X   FLAG: 0x%X\n", tag, flag );
   fprintf( stderr, "TOTAL QWTF: %d\n", total_qwtf );
   switch( tag )
   {
      case DL_FB_LXYZ :
         qwtf = i_ptr[1];
         i_ptr += 2;
         total_qwtf--;

         d_ptr = (double *) i_ptr;

         num_points = qwtf / 3;
         fprintf( stderr, "3D Line String: %d points\n", num_points );
         while ( num_points )
         {
            fprintf( stderr, "   %lf %lf %lf\n", d_ptr[0], d_ptr[1], d_ptr[2] );
            d_ptr += 3;
            num_points--;
         }  /* end: while */

         i_ptr = (int *) d_ptr;
         total_qwtf -= qwtf;
         break;

      case DL_FB_PNTXYZ :
         qwtf = i_ptr[1];
         i_ptr += 2;
         total_qwtf--;

         d_ptr = (double *) i_ptr;

         num_points = qwtf / 3;
         fprintf( stderr, "3D Point String: %d points\n", num_points );
         while ( num_points )
         {
            fprintf( stderr, "   %lf %lf %lf\n", d_ptr[0], d_ptr[1], d_ptr[2] );
            d_ptr += 3;
            num_points--;
         }  /* end: while */

         i_ptr = (int *) d_ptr;
         total_qwtf -= qwtf;
         break;

      case DL_FB_BSC_LXYZ :

         /* skip header */
         i_ptr += 2;
  
         fprintf( stderr, "3D BSpline Curve\n" );
         while ( total_qwtf )
         {
            fprintf( stderr, "   Attribute flag:  " );
            switch ( i_ptr[0] )
            {
               case DL_FB_BS_SOLID_HOLE :
                  fprintf( stderr, "DL_FB_BS_SOLID_HOLE" );
                  break;
               case DL_FB_BS_BOUNDARY :
                  fprintf( stderr, "DL_FB_BS_BOUNDARY" );
                  break;
               case DL_FB_BS_ATTRIBUTE :
                  fprintf( stderr, "DL_FB_BS_ATTRIBUTE" );
                  break;
            }
            fprintf( stderr, "  Attribute Data: %d\n", i_ptr[1] );
            i_ptr += 2;
            total_qwtf--;

            /* read linestring wtf */
            qwtf = i_ptr[1];
            i_ptr += 2;
            total_qwtf--;

            d_ptr = (double *) i_ptr;

            num_points = qwtf / 3;
            fprintf( stderr, "      3D Line String: %d points\n", num_points );
            while ( num_points )
            {
               fprintf( stderr, "         %lf %lf %lf\n", d_ptr[0], d_ptr[1], d_ptr[2] );
               d_ptr += 3;
               num_points--;
            }  /* end: while */

            i_ptr = (int *) d_ptr;
            total_qwtf -= qwtf;

         }  /* end: while */

         break;

      case DL_FB_BSS_LXYZ :

         /* skip header */
         i_ptr += 2;

         fprintf( stderr, "3D BSpline Surface\n" );
         while ( total_qwtf )
         {
            curve_qwtf = i_ptr[1];
            total_qwtf -= (curve_qwtf + 1);
            i_ptr += 2;

            fprintf( stderr, "   3D BSpline Curve\n" );
            while ( curve_qwtf )
            {
               fprintf( stderr, "      Attribute flag:  " );
               switch ( i_ptr[0] )
               {
                  case DL_FB_BS_SOLID_HOLE :
                     fprintf( stderr, "DL_FB_BS_SOLID_HOLE" );
                     break;
                  case DL_FB_BS_BOUNDARY :
                     fprintf( stderr, "DL_FB_BS_BOUNDARY" );
                     break;
                  case DL_FB_BS_ATTRIBUTE :
                     fprintf( stderr, "DL_FB_BS_ATTRIBUTE" );
                     break;
               }
               fprintf( stderr, "  Attribute Data: %d\n", i_ptr[1] );
               i_ptr += 2;
               curve_qwtf--;

               /* read linestring wtf */
               qwtf = i_ptr[1];
               i_ptr += 2;
               curve_qwtf--;

               d_ptr = (double *) i_ptr;

               num_points = qwtf / 3;
               fprintf( stderr, "         3D Line String: %d points\n", num_points );
               while ( num_points )
               {
                  fprintf( stderr, "            %lf %lf %lf\n", d_ptr[0], d_ptr[1], d_ptr[2] );
                  d_ptr += 3;
                  num_points--;
               }  /* end: while */
  
               i_ptr = (int *) d_ptr;
               curve_qwtf -= qwtf;

            }  /* end: while */

         }  /* end: while */

         break;

      case DL_FB_PXYZ :

         /* skip header */
         i_ptr += 2;

         fprintf( stderr, "3D Filled Polygon Set\n" );

         while ( total_qwtf )
         {
            poly_qwtf = i_ptr[0];
            num_points = poly_qwtf / 3;
            fprintf( stderr, "   Polygon: %d points\n", num_points );

            i_ptr += 2;
            total_qwtf -= (poly_qwtf + 1);
            d_ptr = (double *) i_ptr;
            while ( num_points )
            {
               fprintf( stderr, "      %lf %lf %lf\n", d_ptr[0], d_ptr[1], d_ptr[2] );
               d_ptr += 3;
               num_points--;
            }  /* end: while */

            i_ptr = (int *) d_ptr;
         }  /* end: while */
         break;

      case DL_FB_BSC_PXYZ :
         /* skip header */
         i_ptr += 2;

         fprintf( stderr, "3D Filled Bspline Curve\n" );

         while ( total_qwtf )
         {
            set_qwtf = i_ptr[1];
            i_ptr += 2;
            total_qwtf -= (set_qwtf + 1);

            while ( set_qwtf )
            {
               poly_qwtf = i_ptr[0];
               num_points = poly_qwtf / 3;
               fprintf( stderr, "   Polygon: %d points\n", num_points );

               i_ptr += 2;
               set_qwtf -= (poly_qwtf + 1);
               d_ptr = (double *) i_ptr;
               while ( num_points )
               {
                  fprintf( stderr, "      %lf %lf %lf\n", d_ptr[0], d_ptr[1], d_ptr[2] );
                  d_ptr += 3;
                  num_points--;
               }  /* end: while */

               i_ptr = (int *) d_ptr;
            }  /* end: while */

         }  /* end: while */
         break;

      default:
         fprintf( stderr, "Unknown tag\n" );

   }  /* end: switch */

   return( DL_SUCCESS );

}  /* DLIdump_fb_buffer */

/*--- DLIerror_code_to_string -------------------------------------------*/

void DLIerror_code_to_string(
   FILE *pfile,
   int err_code )

/*
NAME
	DLIerror_code_to_string

DESCRIPTION
	This function takes a DL error code and prints a character
	string version of it to a file.

SYNOPSIS
	void DLIerror_code_to_string(
	   FILE *pfile,
	   int err_code )

PARAMETERS
	pfile (IN) - the file pointer for the output string
	err_code (IN) - the error code to translate to a string

GLOBALS USED
	none

HISTORY
	11/25/92    S.P. Rogers
	    Creation Date
*/

{
   switch( err_code )
   {
      case DL_SUCCESS :
         fprintf( pfile, "DL_SUCCESS" );
         break;

      case DL_CANNOT_INITIALIZE :
         fprintf( pfile, "DL_CANNOT_INITIALIZE" );
         break;

      case DL_BAD_PIPELINE_TYPE :
         fprintf( pfile, "DL_BAD_PIPELINE_TYPE" );
         break;

      case DL_BAD_WINDOW_NUMBER :
         fprintf( pfile, "DL_BAD_WINDOW_NUMBER" );
         break;

      case DL_BAD_PIPELINE_ID :
         fprintf( pfile, "DL_BAD_PIPELINE_ID" );
         break;

      case DL_BAD_PARAMETER :
         fprintf( pfile, "DL_BAD_PARAMETER" );
         break;

      case DL_BAD_MULT_TYPE :
         fprintf( pfile, "DL_BAD_MULT_TYPE" );
         break;

      case DL_BAD_DRAW_OPTIONS :
         fprintf( pfile, "DL_BAD_DRAW_OPTIONS" );
         break;

      case DL_BAD_COLOR_REF :
         fprintf( pfile, "DL_BAD_COLOR_REF" );
         break;

      case DL_BAD_WEIGHT :
         fprintf( pfile, "DL_BAD_WEIGHT" );
         break;

      case DL_BAD_STYLE :
         fprintf( pfile, "DL_BAD_STYLE" );
         break;

      case DL_FEEDBACK_OVERFLOW :
         fprintf( pfile, "DL_FEEDBACK_OVERFLOW" );
         break;

      case DL_BAD_POLYGON :
         fprintf( pfile, "DL_BAD_POLYGON" );
         break;

      case DL_NO_MORE_PIPES :
         fprintf( pfile, "DL_NO_MORE_PIPES" );
         break;

      case DL_ERROR :
         fprintf( pfile, "DL_ERROR" );
         break;

      case DL_ILLEGAL_BSPLINE_ORDER :
         fprintf( pfile, "DL_ILLEGAL_BSPLINE_ORDER" );
         break;

      case DL_CANT_ALLOC_TEMP_MEM :
         fprintf( pfile, "DL_CANT_ALLOC_TEMP_MEM" );
         break;

      case DL_CANT_SPLIT_BEZIER :
         fprintf( pfile, "DL_CANT_SPLIT_BEZIER" );
         break;

      case DL_BSPLINE_ERROR :
         fprintf( pfile, "DL_BSPLINE_ERROR" );
         break;

      case DL_FEEDBACK_NOT_ALLOWED :
         fprintf( pfile, "DL_FEEDBACK_NOT_ALLOWED" );
         break;

      default :
         fprintf( pfile, "UNKNOWN: %d", err_code );
         break;

   }  /* end: switch */

}  /* DLIerror_code_to_string */


/*--- DLIvalidate_pipe -----------------------------------------*/

int DLIvalidate_pipe(
   int pipe_id,
   struct DLpipeline **pipe )

/*
NAME
	DLIvalidate_pipe

DESCRIPTION
	This function validates a pipe id

SYNOPSIS
	int DLIvalidate_pipe(
	   int pipe_id,
	   struct DLpipeline **pipe )

PARAMETERS
	pipe_id (IN) - the pipe id to validate
	pipe (OUT) - a pointer to the pipe structure for the
                     pipe, if pipe_id is valid; NULL if not
                     desired

GLOBALS USED
	DLIpipes

RETURN VALUES
	DL_SUCCESS
		The pipe id is valid
	DL_BAD_PIPELINE_ID
		The pipe id is invalid.

HISTORY
	11/24/92    S.P. Rogers
	   Creation Date
*/

{
   if ( (pipe_id < 0) || (pipe_id > DL_MAX_PIPES) )
   {
      DL_REPORT_ERROR( DL_BAD_PIPELINE_ID );
      return( DL_BAD_PIPELINE_ID );
   }

   if ( ! DLIpipes[pipe_id] )
   {
      DL_REPORT_ERROR( DL_BAD_PIPELINE_ID );
      return( DL_BAD_PIPELINE_ID );
   }

   if ( pipe )
   {
      *pipe = DLIpipes[pipe_id];
   }

   return( DL_SUCCESS );

}  /* DLIvalidate_pipe */

/*--- DLIinit_pipe ---------------------------------------------*/

static int DLIinit_pipe(
   struct DLpipeline *pipe )

/*
NAME
	DLIinit_pipe (static)

DESCRIPTION
	This function initializes the fields of the pipeline
	structure for a newly created pipeline.

SYNOPSIS
	static int DLIinit_pipe(
	   struct DLpipeline *pipe )

PARAMETERS
	pipe (IN/OUT) - the pipeline structure to initialize

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/25/92   S.P. ROgers
	   Documented
*/

{
   int ii;

   pipe->clip_flag = DLI_CL_IDENTITY | DLI_CL_MOD_IDENTITY;

   /* set the matrices to an identity */
   for ( ii = 0; ii < 16; ii++ )
   {
      pipe->matrix[ii] = pipe->viewing_matrix[ii] = pipe->modelling_matrix[ii] = 0.0;
   }

   pipe->matrix[0] = pipe->viewing_matrix[0] = pipe->modelling_matrix[0] = 1.0;
   pipe->matrix[5] = pipe->viewing_matrix[5] = pipe->modelling_matrix[5] = 1.0;
   pipe->matrix[10] = pipe->viewing_matrix[10] = pipe->modelling_matrix[10] = 1.0;
   pipe->matrix[15] = pipe->viewing_matrix[15] = pipe->modelling_matrix[15] = 1.0;

   /* initialize the matrix map */
   pipe->matmap[0] = 0xF;
   pipe->matmap[1] = 0xF;
   pipe->matmap[2] = 0xF;
   pipe->matmap[3] = 0xF;

   /* set the viewport to something that  */
   /* won't cause errors => an applcation */
   /* must set a viewport before anything */
   /* reasonable can be drawn             */
   pipe->view.xlo = 0.0;
   pipe->view.ylo = 0.0;
   pipe->view.zlo = 0.0;
   pipe->view.xhi = 1.0;
   pipe->view.yhi = 1.0;
   pipe->view.zhi = 1.0;

   pipe->vw_volume[0] = 0.0;
   pipe->vw_volume[1] = 0.0;
   pipe->vw_volume[2] = 0.0;
   pipe->vw_volume[3] = 1.0;
   pipe->vw_volume[4] = 1.0;
   pipe->vw_volume[5] = 1.0;

   /* equiv to (1.0 / (2.0 * 0.5)) */
   pipe->bspl.world_tol = 1.0;

   /* equiv to (1.0 / (2.0 * 2.0)) */
   pipe->bspl.dev_tol = 0.25;

   pipe->bspl.maxpts = 3;

#if defined( XGL )
   pipe->using_xgl = FALSE;
#endif

#if defined( OPENGL )
   pipe->using_opengl = FALSE;
#endif

#if defined ( ENV5 )
   pipe->using_gpipe = FALSE;
   pipe->using_eg = FALSE;
#endif

   return( DL_SUCCESS );

}  /* DLIinit_pipe */

/*--- DLIupdate_wl_data ---------------------------------------*/

static int DLIupdate_wl_data(
   struct DLpipeline *pipe )

/*
NAME
	DLIupdate_wl_data (static)

DESCRIPTION
	This function updates the WL information for a pipeline

SYNOPSIS
	static int DLIupdate_wl_data(
	   struct DLIpipeline *pipe )

PARAMETERS
	pipe (IN) - the pipeline structure to update

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_ERROR
		A WL called failed

HISTORY
	02/26/93   S.P. Rogers
	   Initial definition, design, and implementation
*/

{
   int sts;
   struct WLnative_info native_info;

   sts = WLget_window_base_context( pipe->lwin_no, &pipe->base_context_no );
   if ( sts != WL_SUCCESS )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   sts = WLget_context_info( pipe->base_context_no, &pipe->base_context_info );
   if ( sts != WL_SUCCESS )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   sts = WLget_native_info( pipe->lwin_no, pipe->base_context_no, &native_info );
   if ( sts != WL_SUCCESS )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

   pipe->hwin_no = native_info.base_win;

#if defined( XGL )
   pipe->using_xgl = (native_info.xgl_context_3D != NULL );
#endif

#if defined( OPENGL )
   pipe->using_opengl = (native_info.glx_context != NULL);
#endif

   return( DL_SUCCESS );

}  /* DLIupdate_wl_data */

/*---DLuse_gpipe-------------------------------------------------------------*/

/*
Add for mapping.  They have a problem with using the DL_USE_GPIPE environment
variable, so this is provided so that they can do the same thing by
making a function call from their APPmain.c
*/

static char   DLforce_gpipe = 0;

void   DLuse_gpipe()
   {
   DLforce_gpipe = 1;
   }
   
/*--- DLinitialize ----------------------------------------------------------*/

int DLinitialize(
   void )

/*
NAME
	DLinitialize

DESCRIPTION
	This function initializes the drawing layer routines.  It must
	be called before any other drawing layer routines are called.

SYNOPSIS
	int DLinitialize(
	   void )

PARAMETERS
	none

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_CANNOT_INITIALIZE
		The drawing layer cannot be initialized.

RELATED INFORMATION
	Functions: DLexit()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int ii;
   char *expansion;

   if ( ! DLIbuf )
   { 
      /* first invocation of DLinitialize() for the process */
      DLIbuf = (double *) malloc( DLI_MAX_VERTICES * sizeof( double ) * 4 );
      if ( ! DLIbuf )
      {
         DL_REPORT_ERROR( DL_CANNOT_INITIALIZE );
         return( DL_CANNOT_INITIALIZE );
      }

      for ( ii = 0; ii < DL_MAX_PIPES; ii++ )
      {
         DLIpipes[ii] = NULL;
      }

#if defined( ENV5 )
      expansion = getenv( "DL_USE_EG" );
      if ( expansion )
      {
         DLIuse_eg = (expansion[0] != '0');
      }
      else
      {
         /* always set up EG because it is fastest for the */
         /* single precision data from display lists       */
         DLIuse_eg = TRUE;
      }

      if( DLforce_gpipe )
         {
         DLIuse_gpipe = 1;
         }
      else
      {
         expansion = getenv( "DL_USE_GPIPE" );
         if ( expansion )
         {
            DLIuse_gpipe = (expansion[0] != '0');
         }
         else
         {
            /* Use GPIPE on machines with a Floating point engine */
            GPInqStatus( &DLIuse_gpipe );
         }
      }
   
      if ( DLIuse_gpipe )
      {
         GPEnter();
      }

#endif
   }

   expansion = getenv( "DL_REPORT_ERROR" );
   DLIreport_errors = (expansion) && (expansion[0] == '1');

   return( DL_SUCCESS );

}  /* DLinitialize */


/*--- DLexit ---------------------------------------------------------------*/

int DLexit(
   void )

/*
NAME
	DLexit

DESCRIPTION
	This function terminates the drawing layer.  After it has been
	called, no more calls to drawing layer functions can be made.

SYNOPSIS
	int DLexit(
	   void )

PARAMETERS
	none

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

RELATED INFORMATION
	Functions: DLinitialize()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int ii;

   for ( ii = 0; ii < DL_MAX_PIPES; ii++ )
   {
      if ( DLIpipes[ii] )
      {
         free( ( char * ) ( DLIpipes[ii] ) );
         DLIpipes[ii] = NULL;
      }
   }

#if defined( ENV5 )
   if ( DLIuse_gpipe )
   {
      GPExit();
   }
#endif

   return( DL_SUCCESS );

}  /* DLexit */


/*--- DLreset_for_wireframe --------------------------------*/

int DLreset_for_wireframe(
   int pipe_id )

/*
NAME
	DLreset_for_wireframe

DESCRIPTION
	This function resets a DL pipeline for wireframe
        display.  It takes care of setting graphics
        library specific items (e.g., Zbuffering, lighting,
        etc.) back to the state used for wireframe display.
        This function is designed to be called after the
        graphics library information for a pipeline has
        been changed outside of DL (e.g., for shading).

SYNOPSIS
	int DLreset_for_wireframe(
	   int pipe_id )

PARAMETERS
	pipe_id (IN) - the id of the drawing pipeline to reset

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_ERROR
		A graohics library call failed

HISTORY
	07/13/93   S.P. Rogers
	   Initial definition, design, and implementation
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      WLglx_make_window_current( pipe->lwin_no, WL_GLX_BASE_WIN );

      glDisable( GL_ALPHA_TEST );
      glDisable( GL_DEPTH_TEST );
      glDisable( GL_FOG );
      glDisable( GL_LIGHTING );
      glDisable( GL_STENCIL_TEST );
      glDisable( GL_BLEND );
      glDisable( GL_LINE_SMOOTH );
      glDisable( GL_POINT_SMOOTH );
      glDisable( GL_POLYGON_SMOOTH );
      glDisable( GL_SCISSOR_TEST );

      if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE )
      {
         WLglx_make_window_current( pipe->lwin_no, WL_GLX_HILITE_WIN );

         glDisable( GL_ALPHA_TEST );
         glDisable( GL_DEPTH_TEST );
         glDisable( GL_FOG );
         glDisable( GL_LIGHTING );
         glDisable( GL_STENCIL_TEST );
         glDisable( GL_BLEND );
         glDisable( GL_LINE_SMOOTH );
         glDisable( GL_POINT_SMOOTH );
         glDisable( GL_POLYGON_SMOOTH );
         glDisable( GL_SCISSOR_TEST );
      }
   }

#endif

#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      EGSetAntiAliasedLineMode( pipe->eg_vc, EG_OFF );

      EGSetDepthCueMode( pipe->eg_vc, EG_OFF );

      EGSetLightingMode( pipe->eg_vc, EG_OFF );

      EGSetRenderMethod( pipe->eg_vc, EG_RENDER_ENV_V );

      EGSetZBufferMode( pipe->eg_vc, EG_OFF );
   }

   if ( pipe->using_gpipe )
   {
      GPEnableZbuffer( pipe->gpipe_id, GP_OFF );
   }
#endif

   return( DL_SUCCESS );
} /* DLreset_for_wireframe */

/*--- DLcreate_drawing_pipeline ---------------------------------------------*/

int DLcreate_drawing_pipeline(
   int type,
   WLuint32 lwin_no,
   int *p_pipe_id )

/*
NAME
	DLcreate_drawing_pipeline

DESCRIPTION
	This function creates and associates a drawing pipeline with a
	logical window.

SYNOPSIS
	int DLcreate_drawing_pipeline(
	   int type,
	   WLuint32 lwin_no,
	   int *p_pipe_id )

PARAMETERS
	type (IN) - the type of pipeline to create (ortho or perspective)
	lwin_no (IN) - the logical window to associate with the pipeline
	p_pipe_id (OUT) - the drawing pipeline id

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_TYPE
		The pipeline type is invalid.
	DL_BAD_WINDOW_NUMBER
		The logical window is invalid.
	DL_NO_MORE_PIPES
		If another pipe cannot be allocated.
	DL_ERROR
		A WL called failed.

RELATED INFORMATION
	Functions: DLdelete_drawing_pipeline, DLcreate_feedback_pipeline()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int i;
   int sts = DL_SUCCESS;
   struct DLpipeline *pipe;

#if defined( XGL )
   Xgl_trans	model_trans;
   Xgl_trans    local_model_trans;
   Xgl_trans	view_trans;
   struct WLnative_info native_info;
   WLuint32 base_context_no;
#endif

   if ( ( type < 0 ) || ( type > 2 ) )
   {
      DL_REPORT_ERROR( DL_BAD_PIPELINE_TYPE );
      return( DL_BAD_PIPELINE_TYPE );
   }

   if ( p_pipe_id == NULL )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   /* Establish a pipeline with the specified clipping mode set. */
   i = 0;
   while ( (DLIpipes[i] != NULL) && (i < DL_MAX_PIPES) )
   {
      i++;
   }

   if ( i < DL_MAX_PIPES )
   {
      DLIpipes[i] = (struct DLpipeline *) malloc( sizeof( struct DLpipeline ) );
      if ( DLIpipes[i] == NULL )
      {
         DL_REPORT_ERROR( DL_NO_MORE_PIPES );
         return( DL_NO_MORE_PIPES );
      }
      *p_pipe_id = i;
   }
   else
   {
      DL_REPORT_ERROR( DL_NO_MORE_PIPES );
      return( DL_NO_MORE_PIPES );
   }

   /* Initialize all the pipeline attributes. */
   pipe = DLIpipes[*p_pipe_id];

   pipe->pipe_id = *p_pipe_id;

   pipe->type = type;
   pipe->lwin_no = lwin_no;
   pipe->fb_size = 0;
   pipe->fb_index = 0;

   DLIinit_pipe( pipe );

   if ( DLIupdate_wl_data( pipe ) != DL_SUCCESS )
   {
      free( DLIpipes[i] );
      DLIpipes[i] = NULL;
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }

#if defined( XGL )       
   sts = WLget_window_base_context( lwin_no, &base_context_no );
   if ( sts != WL_SUCCESS )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }
       
   sts = WLget_native_info( lwin_no, base_context_no, &native_info );

   pipe->xgl_context_3D = native_info.xgl_context_3D;
   xgl_object_get( pipe->xgl_context_3D,
                   XGL_CTX_GLOBAL_MODEL_TRANS,
                   &pipe->global_model_trans );
   xgl_object_get( pipe->xgl_context_3D,
                   XGL_CTX_LOCAL_MODEL_TRANS,
                   &pipe->local_model_trans );
   xgl_object_get( pipe->xgl_context_3D,
                   XGL_CTX_VIEW_TRANS,
                   &pipe->view_trans );

   if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE )
   {
      pipe->hl_xgl_context_3D = native_info.hl_xgl_context_3D;
      xgl_object_get( pipe->hl_xgl_context_3D,
                      XGL_CTX_GLOBAL_MODEL_TRANS,
                      &pipe->hl_global_model_trans );
      xgl_object_get( pipe->hl_xgl_context_3D,
                      XGL_CTX_LOCAL_MODEL_TRANS,
                      &pipe->hl_local_model_trans );
      xgl_object_get( pipe->hl_xgl_context_3D,
                      XGL_CTX_VIEW_TRANS,
                      &pipe->hl_view_trans );
      
   }
#endif


#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );

      /* initialize the context with identity matrices */
      glMatrixMode( GL_PROJECTION );
      glLoadIdentity();

      glMatrixMode( GL_MODELVIEW );
      glLoadIdentity();

      glDisable( GL_DITHER );

      if ( pipe->base_context_info.flags & WL_SEPARATE_HILITE )
      {
         /* initialize the hilite context with identity matrices */
         WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );

         glMatrixMode( GL_PROJECTION );
         glLoadIdentity();

         glMatrixMode( GL_MODELVIEW );
         glLoadIdentity();

         glDisable( GL_DITHER );
      }
   }
#endif

#if defined( ENV5 )
   if ( DLIuse_eg )
   {
      if ( (EGCreateVC( &pipe->eg_vc ) == 0) &&
           (EGSetVCWindow( pipe->eg_vc, pipe->hwin_no) == 0) )
      {
         pipe->using_eg = TRUE;

         {
            /* workaround for the EGFillArea3 crash => EG should be fixed */
            /* w/ the 7.x fixes release in Jan. 1994                      */
            EGPoint3 verts[9] = { 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.1, 0.1, 0.0 };
            EGFillArea3Info triangle;

            triangle.verts = verts;
            triangle.shape = EG_COMPLEX;
            triangle.numVerts = 3;
            triangle.vertOffset = sizeof( EGPoint3 );
            EGSetRenderMethod( pipe->eg_vc, EG_RENDER_FLAT );
            MathErrSilence( 1 );
            EGFillArea3( pipe->eg_vc, &triangle );
            MathErrSilence( 0 );
         }

         sts = DLreset_for_wireframe( *p_pipe_id );
         if ( sts == DL_SUCCESS )
         {
            /* initialize some values that will never change */
            pipe->view_rep.clipLimits.xMin = 0.0;
            pipe->view_rep.clipLimits.yMin = 0.0;
            pipe->view_rep.clipLimits.zMin = 0.0;

            pipe->view_rep.clipLimits.xMax = 1.0;
            pipe->view_rep.clipLimits.yMax = 1.0;
            pipe->view_rep.clipLimits.zMax = 1.0;

            pipe->view_rep.clipXY = EG_ON;
            pipe->view_rep.clipFront = EG_ON;
            pipe->view_rep.clipBack = EG_ON;
         }
         else
         {
            pipe->using_eg = FALSE;
         }
      }
   }

   if ( DLIuse_gpipe )
   {
      /* we're on a machine that has hardware accelerated GPIPE */
      /* and we're not doing true color => use GPIPE            */
      sts = GPCreateWin( (type == DL_PERSP_PIPE) ? GP_3D_PERSPECTIVE : GP_3D_PARALLEL,
                         pipe->hwin_no,
                         &pipe->gpipe_id );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
   
      if ( sts == DL_SUCCESS )
      {
         pipe->using_gpipe = TRUE;
         sts = DLreset_for_wireframe( *p_pipe_id );
         if ( sts != DL_SUCCESS )
         {
            pipe->using_gpipe = FALSE;
         }
      }
   }
#endif

   return( sts );

}  /* DLcreate_drawing_pipeline */

/*--- DLcreate_feedback_pipeline --------------------------------------------*/

int DLcreate_feedback_pipeline(
   int type,
   double *buffer,
   int bufsize,
   int *p_pipe_id )

/*
NAME
	DLcreate_feedback_pipeline

DESCRIPTION
	This function creates a drawing pipeline that places the output
	in a feedback buffer instead of drawing to the screen.

SYNOPSIS
	int DLcreate_feedback_pipeline(
	   int type,
	   double *buffer,
	   int bufsize,
	   int *p_pipe_id )

PARAMETERS
	type (IN) - the type of drawing pipeline (ortho or perspective)
	buffer (IN) - the buffer that is to receive the feedback
	buf_size (IN) - the number of doubles in the buffer
	p_pipe_id (OUT) - the id of the drawing pipeline

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_TYPE
		The pipeline type is invalid.
	DL_BAD_PARAMETER
		The 'buf_size' parameter is less than zero or 'p_pipe_id'
                is NULL.
	DL_NO_MORE_PIPES
		If another pipe cannot be allocated.

RELATED INFORMATION
	Functions: DLcreate_drawing_pipeline(), DLdelete_drawing_pipeline()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   struct DLpipeline *pipe;
   int i;

   if ( ( type < 0 ) || ( type > 2 ) )
   {
      DL_REPORT_ERROR( DL_BAD_PIPELINE_TYPE );
      return( DL_BAD_PIPELINE_TYPE );
   }

   if ( (bufsize < 0) || (p_pipe_id == NULL) )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   i = 0;
   while ( ( DLIpipes[i] != NULL ) && ( i < DL_MAX_PIPES ) )
   {
      i++;
   }
   if ( i < DL_MAX_PIPES )
   {
      DLIpipes[i] = ( struct DLpipeline * ) malloc( sizeof( struct DLpipeline ) );
      if ( DLIpipes[i] == NULL )
      {
         DL_REPORT_ERROR( DL_NO_MORE_PIPES );
         return( DL_NO_MORE_PIPES );
      }
      *p_pipe_id = i;
   }
   else
   {
      DL_REPORT_ERROR( DL_NO_MORE_PIPES );
      return( DL_NO_MORE_PIPES );
   }

   /* Initialize all the pipeline attributes. */

   pipe = DLIpipes[*p_pipe_id];
   pipe->pipe_id = *p_pipe_id;
   pipe->type = type;
   pipe->lwin_no = WL_UNDEFINED_WINDOW;
   pipe->fb_size = bufsize;
   pipe->fb_buf = buffer;
   pipe->fb_index = 0;
   pipe->fb_flag = 0;
   DLIinit_pipe( pipe );
   return( DL_SUCCESS );

}  /* DLcreate_feedback_pipeline */


/*--- DLdelete_drawing_pipeline ---------------------------------------------*/

int DLdelete_drawing_pipeline(
   int pipe_id )

/*
NAME
	DLdelete_drawing_pipeline

DESCRIPTION
	This function deletes a drawing pipeline.

SYNOPSIS
	int DLdelete_drawing_pipeline(
	   int pipe_id )

PARAMETERS
	pipe_id (IN) - the id of the drawing pipeline to delete

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.

RELATED INFORMATION
	Functions: DLcreate_drawing_pipeline(), DLcreate_feedback_pipeline()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      EGDeleteVC( pipe->eg_vc );
   }

   if ( pipe->using_gpipe )
   {
      GPDelete( pipe->gpipe_id );
   }
#endif

   free( ( char * ) ( pipe ) );
   DLIpipes[pipe_id] = NULL;

   return( DL_SUCCESS );

}  /* DLdelete_drawing_pipeline */


/*--- DLupdate_windowing_data ---------------------------*/

int DLupdate_windowing_data(
   int pipe_id,
   WLuint32 new_lwin_no )

/*
NAME
	DLupdate_windowing_data

DESCRIPTION
	This function causes the pipeline to update the
	WL windowing data that it maintains.  It should be 
	called if the window gets a new WL logical window 
        number (i.e., it changes screens ) or if the base
	context of the window changes.

SYNOPSIS
	int DLupdate_windowing_data(
	   int pipe_id,
	   WLuint32 new_lwin_no )

PARAMETERS
	pipe_id (IN) - the id of the drawing pipeline to update
	new_lwin_no (IN) - the new logical window number for the
	                   pipeline (WL_UNDEFINED_WINDOW if the
	                   logical window number has not changed)

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_ERROR
		A WL call failed

RELATED INFORMATION
	Functions: DLcreate_drawing_pipeline(), DLcreate_feedback_pipeline()

HISTORY
	02/26/93   S.P. Rogers
	   Initial definition, design, and implementation
*/

{
   int sts;
   struct DLpipeline *pipe;
   WLuint32 old_lwin_no;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   old_lwin_no = pipe->lwin_no;

   if ( new_lwin_no != WL_UNDEFINED_WINDOW )
   {
      pipe->lwin_no = new_lwin_no;
   }

   if ( DLIupdate_wl_data( pipe ) != DL_SUCCESS )
   {
      /* reset back to good stuff */
      pipe->lwin_no = old_lwin_no;
      DLIupdate_wl_data( pipe );

      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }
   
   return( DL_SUCCESS );

}  /* DLupdate_windowing_data */

#if defined( ENV5 )
/*--- DLget_EG_data ---------------------------------_*/

int DLget_EG_data(
   int pipe_id,
   int *vc_no )

/*
NAME
	DLget_EG_data

DESCRIPTION
        This function gets the EG data for a pipeline.

SYNOPSIS
	int DLget_EG_data(
	   int pipe_id,
	   int *vc_no )

PARAMETERS
	pipe_id (IN) - the id of the drawing pipeline 
        vc_no (OUT) - the EG viewing context for the pipeline

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
        DL_BAD_PARAMETER
                The 'vc_no' parameter is NULL.
	DL_ERROR
		The pipeline is not using EG.

HISTORY
	07/13/93   S.P. Rogers
	   Initial definition, design, and implementation
*/

{
   int sts;
   struct DLpipeline *pipe;

   if ( ! vc_no )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( pipe->using_eg )
   {
      *vc_no = pipe->eg_vc;
   }
   else
   {
      return( DL_ERROR );
   }

   return( DL_SUCCESS );
   
} /* DLget_EG_data */

/*--- DLget_GPIPE_data ---------------------------------_*/

int DLget_GPIPE_data(
   int pipe_id,
   int *gpipe_id )

/*
NAME
	DLget_GPIPE_data

DESCRIPTION
        This function gets the GPIPE data for a pipeline.

SYNOPSIS
	int DLget_GPIPE_data(
	   int pipe_id,
	   int *gpipe_id )

PARAMETERS
	pipe_id (IN) - the id of the drawing pipeline 
        gpipe_id (OUT) - the GPIPE id of the pipeline

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
        DL_BAD_PARAMETER
                The 'vc_no' parameter is NULL.
	DL_ERROR
		The pipeline is not using GPIPE.

HISTORY
	08/19/93   S.P. Rogers
	   Initial definition, design, and implementation
*/

{
   int sts;
   struct DLpipeline *pipe;

   if ( ! gpipe_id )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( pipe->using_gpipe )
   {
      *gpipe_id = pipe->gpipe_id;
   }
   else
   {
      return( DL_ERROR );
   }

   return( DL_SUCCESS );
   
} /* DLget_GPIPE_data */
   
#endif

static int DLxxflag;

void DLset_flag( int flag )

   {
   DLxxflag |= flag;
   }

void DLclear_flag( int flag )

   {
   DLxxflag &= ~flag;
   }

int  DLflag( int flag )

   {
   return( DLxxflag & flag );
   }

