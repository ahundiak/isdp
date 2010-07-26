/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPtxstrk

          Abstract:    This routine will actually display the character 
                     string on the screen.

----
%SC%

     VALUE = DPtxstrk(msg,lbsys,txt_ele,dis_attr,win_no,os_tbl_ptr,type)
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *lbsys            struct IGRlbsys         local bounded system

      *txt_ele          struct IGRestx          text element 
                                                specific data

      *dis_attr         struct IGRdisplay       display attributes

      *win_no   	IGRlong                 hardware window no

      *os_tbl_ptr       struct DPfnt_os_tbl     font object space 
                                                pointer
        
      *type             IGRshort                type of matrix
     
----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------
        *msg          IGRlong                    return status
                                             MSSUCC - successfully completed
                                             MSFAIL - unsuccessfully completed

      VALUE() =    TRUE if successful
                   FALSE if something went wrong.

----
%MD%
 
     MODULES INVOKED:  


                   DPget_fnt_adr()
                   MAmulmx()
                   DPesc_handler()

----
%NB%

      NOTES:   None

----
%CH%

       AET   03/10/86   : Creation date
       AET   12/11/87	: Changed the text stroker to use the font server
       AET   07/30/88	: Added 16-bit capability and quick edit text
			  and fill capability
       AET   04/20/89	: Improved text speed by optimizing the matrix 
			  multiplies between each character


----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------

	This routine will use the font server to draw text

---*/
/*EH*/

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <math.h>
#include "exsysdep.h"
#if defined ( X11 )
#include <FSX.h>
#else
#include <FS.h>
#endif

#include <FSOutl.h>
#include <FSBmap.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "fontdef.h"
#include "dpfont.h"
#include "dpdef.h"
#include "dppriv.h"
#include "msdef.h"
#include "madef.h"
#include "exmacros.h"
#include "bsvalues.h"
#include "bstypes.h"

#ifdef GRAPHICS_ATP
#include "DIdef.h"
#endif

#include "dpgraphics.h"
#include "wl.h"
#include "dl.h"
#include "dl_internal.h"

/* prototype files */
#include "DPviewdyn.h"
#include "GRfndescchar.h"
#include "dptxstrk.h"
#include "dpeschdler.h"
#include "dpgetfntadr.h"

#include "maidmx.h"
#include "maang2vc.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "matrnmx.h"

#ifdef TIMING_TEST

extern long dptxstrk_time;
extern long	dptxsetup_time;
extern long    dptxvwsetup_time;
extern long    dptxvwsetup_time2;
extern long	dpfs_time;
extern long	dpactstrk_time;
extern long	dptxgp_fill;
extern long	dpnumtxvec;
#endif


static  IGRint	DPfill_text_enabled = TRUE;
#if defined( X11 )
static  IGRint  DPbitmap_display_enabled = FALSE;
#else 
static  IGRint  DPbitmap_display_enabled = FALSE;
#endif
static struct IGRdisplay *static_dis_attr;
static WLuint32 static_color_ref;
static int static_draw_opt;

#define MAX_TMP_BUF	2*1024
#define MAX_NUM_POINTS	300
#define MAX_NUM_POLYS	100

extern struct GRid DPdlist_wf_fb_gragad;
extern IGRdouble *DPdlist_fb_buffer;
extern int DPdlist_wf_fb_pipe_id;
extern IGRboolean DPdlist_feedback_in_progress;

/*-------------------------------------------------------------------------*/

static double   points[75];
static int      num_points[2];
static int      index[2];

static struct IGRbsp_curve   curveA, curveB;
static int                   num_p[2] = { 0, 0 };

static double   matrix[] = { 1.0, 0.0, 0.0, 0.0,
                             0.0, 1.0, 0.0, 0.0,
                             0.0, 0.0, 1.0, 0.0,
                             0.0, 0.0, 0.0, 1.0 };

/*---alloc_2_curves--------------------------------------------------------*/

static void   alloc_2_curves( int  *num_poles )

   {

   /*
    *  Allocate memory if the existing memory is not enough
    */
    
   if( num_poles[0] > num_p[0] )
      {
      if( num_p[0] != 0 )
         {
         free( curveA.poles );
         free( curveA.knots );
         }
         
      num_p[0] = num_poles[0];
      
      curveA.poles =   (IGRdouble *)malloc( sizeof( IGRdouble ) * 3 * num_poles[0] );
      curveA.knots =   (IGRdouble *)malloc( sizeof( IGRdouble ) *    (num_poles[0] + 2) );
      }

   if( num_poles[1] > num_p[1] )
      {
      if( num_p[1] != 0 )
         {
         free( curveB.poles );
         free( curveB.knots );
         }
         
      num_p[1] = num_poles[1];
      
      curveB.poles =   (IGRdouble *)malloc( sizeof( IGRdouble ) * 3 * num_poles[1] );
      curveB.knots =   (IGRdouble *)malloc( sizeof( IGRdouble ) *    (num_poles[1] + 2) );
      }
   }

/*---polygon_nesting-----------------------------------------------------*/

int   polygon_nesting( int *num_points, double *p1, double *p2, int edge_on )

   {   
   struct IGRcv_prism    cv_prism;
   IGRvector             nvec;
   BSrc                  rc;
   IGRint                ind_ab, ind_ba, status, i, j;


   /*
    *  Allocate memory for the two curves and generate the curve
    *  geometry from the array of points
    */

   /*
   fprintf( stderr, "%d\n", num_points[0] );
   for( j=i=0; i<num_points[0]; i++ )
	{
	fprintf( stderr, "  %f ", p1[j++] );
	fprintf( stderr, "%f ", p1[j++] );
	fprintf( stderr, "%f\n", p1[j++] );
	}
   fprintf( stderr, "%d\n", num_points[1] );
   for( j=i=0; i<num_points[1]; i++ )
	{
	fprintf( stderr, "  %f ", p2[j++] );
	fprintf( stderr, "%f ", p2[j++] );
	fprintf( stderr, "%f\n", p2[j++] );
	}
   */

   alloc_2_curves( num_points );   
   status = BSlininter( &rc, &num_points[0], p1, &curveA, nvec );
   status = BSlininter( &rc, &num_points[1], p2, &curveB, nvec );

   memcpy( cv_prism.matrix, matrix, 16 * sizeof( IGRdouble ) );
   cv_prism.height = 0.0;

   /*
    *  Force both curve onto a 2d plane
    */
    
   for( i=0, j=2; i<num_points[0]; i++, j+=3 )
      {
      if( edge_on ) curveA.poles[j-1] = curveA.poles[j];
      curveA.poles[j] = 0.0;
      }
      
   for( i=0, j=2; i<num_points[1]; i++, j+=3 )
      {
      if( edge_on ) curveB.poles[j-1] = curveB.poles[j];
      curveB.poles[j] = 0.0;
      }
   
   /*
    *  Put curve B in the prism structure and compare to curve A
    *  then put curve A in the prism structure and compare to
    *  curve B.
    */

   memcpy( &cv_prism.curve, &curveB, sizeof( struct IGRbsp_curve ) );
   BScvincvfnc( &cv_prism, &curveA, &ind_ab, &rc );

   memcpy( &cv_prism.curve, &curveA, sizeof( struct IGRbsp_curve ) );
   BScvincvfnc( &cv_prism, &curveB, &ind_ba, &rc );

/*
fprintf( stderr, "ind_ab, ind_ba: %d %d\n", ind_ab, ind_ba );
*/
   
   /*
    *  evaluate the results and return the status
    */
    
   if( ind_ab == 2 || ind_ba == 2 )
      return( 0 );

   else
   if( ind_ab == 0 && ind_ba == 0 )
      return( 2 );
      
   else
      return( 1 );

   }

/*-------------------------------------------------------------------------*/
/*---DLbust_3D_polygons--------------------------------------------------*/

void   DLbust_3D_polygons(    int pipe_id,
                           double *points,
                              int *num_points,
                              int num_polys,
                       WLcolorref color,
                              int style,
                         WLuint16 blend,
                              int lweight,
                              int draw_opt  )

   {
   int      ii, jj, kk, bust, index, sts, edge_on;
   double   min[4], max[4];
   double   a[3], b[3], n[3];
   
   struct DLpipeline   *pipe;

   
   sts = DLIvalidate_pipe( pipe_id, &pipe );

   edge_on = 0;
   if( pipe->fb_size != 0 )
      {   
      DLItri_magnitude( &points[0], &points[3], a );
      DLItri_magnitude( &points[3], &points[6], b );
      DLItri_cross( a, b, n );

      if( n[2] == 0.0 ) edge_on = 1;
      }

   if( num_polys > 1 )
      {
   /*
      if( num_polys == 2 )
         {
         for( kk=ii=0; ii<num_polys; ii++ )
            {
            fprintf( stderr, "%d\n", num_points[ii] );

            for( jj=0; jj<num_points[ii]; jj++ )
               {
               fprintf( stderr, "%f ", points[kk++] );
               fprintf( stderr, "%f ", points[kk++] );
               fprintf( stderr, "%f\n", points[kk++] );
               }
            }
         }
      */
         
      min[0] =  (double)(0x7fffffff);
      min[1] =  (double)(0x7fffffff);
      min[2] =  (double)(0x7fffffff);
      min[3] =  (double)(0x7fffffff);
      max[0] = -min[0];
      max[1] = -min[0];
      max[2] = -min[0];
      max[3] = -min[0];

      /*
       *  if edge on look at x/z else look at x/y
       */
       
      for( jj=kk=0; kk<num_points[0]; kk++ )
         {
         if( points[jj] > max[0] ) max[0] = points[jj];
         if( points[jj] < min[0] ) min[0] = points[jj];

         if( edge_on ) jj += 2; else jj++;
         
         if( points[jj] > max[1] ) max[1] = points[jj];
         if( points[jj] < min[1] ) min[1] = points[jj];

         if( edge_on ) jj++; else jj += 2;
         }

      index = jj;

      for( kk=0; kk<num_points[1]; kk++ )
         {
         if( points[jj] > max[2] ) max[2] = points[jj];
         if( points[jj] < min[2] ) min[2] = points[jj];

         if( edge_on ) jj += 2; else jj++;
         
         if( points[jj] > max[3] ) max[3] = points[jj];
         if( points[jj] < min[3] ) min[3] = points[jj];

         if( edge_on ) jj++; else jj += 2;
         }

      /*
       *  Test A inside B, then if not, test B inside A, then
       *  if not send polys separate
       */
       
      bust = 1;
      if( min[0] < min[2] && max[0] > max[2] &&
          min[1] < min[3] && max[1] > max[3] ) bust = 0;

      else
      if( min[2] < min[0] && max[2] > max[0] &&
          min[3] < min[1] && max[3] > max[1] ) bust = 0;

      if( !bust )
         {
         bust = ( polygon_nesting( num_points, points, &points[index], edge_on ) != 1 );
         }

      if( bust )
         {
         for( jj=ii=0; ii<num_polys; ii++ )
            {       
            DLdraw_3D_polygons( pipe_id,
                                &points[jj],
                                &num_points[ii],
                                1/*num_polys*/,
                                color,
                                style,
                                blend,
                                lweight,
                                draw_opt );

            jj += num_points[ii] * 3;
            }
         }
      else
         {
         DLdraw_3D_polygons( pipe_id,
                             points,
                             num_points,
                             num_polys,
                             color,
                             style,
                             blend,
                             lweight,
                             draw_opt );
	 }                             
      }
   else
      {
      DLdraw_3D_polygons( pipe_id,
                          points,
                          num_points,
                          num_polys,
                          color,
                          style,
                          blend,
                          lweight,
                          draw_opt );
      }

   } /* DLbust_3D_polygons */


/*---DPdrawtext--------------------------------------------------------------*/
   
/*  This routine is called from the font server when FSDrawString is called */
/*  This is because in the method GRadd_fnt_tbl on GRmodule, this function  */
/*  was set as the drawing function					    */

#if defined( X11 )
void DPdrawtext(mydisplay,outldraw,mygc,x,y,vertices,numverts,numpolys,charInfo)
	Display			*mydisplay;
	struct DPoutldraw 	*outldraw;
	GC			mygc;
	Real64 			x,y;
	Outl3DVertex 		vertices[];
	int			numverts[];
	int			numpolys;
	OutlCharInfo 		*charInfo;
#elif defined( ENV5 )
void DPdrawtext(outldraw,x,y,vertices,numverts,numpolys,charInfo)
	struct DPoutldraw 	*outldraw;
	Real64 			x,y;
	Outl3DVertex 		vertices[];
	int			numverts[];
	int			numpolys;
	OutlCharInfo 		*charInfo;
#endif

{
	IGRint i,j;
	IGRint total_vec = 0;
        IGRlong total_vec_long;
	IGRint  local_num_verts[MAX_NUM_POLYS];
	IGRint  *new_num_verts;
	IGRdouble  trn_mtx[16];
	IGRdouble  cur_x_off;
	IGRlong	   msg;
	IGRboolean value;
	Outl3DVertex  points[MAX_NUM_POINTS];
	Outl3DVertex *cur_pnt_ptr;
	Outl3DVertex  *pnts;
	IGRdouble  greek_point[15];
	IGRint	   cur_poly;
	IGRint	   malloced_points = FALSE;
	IGRint	   malloced_num_verts = FALSE;
        IGRlong    numverts_long; 
        IGRshort   four = 4;   /* value used in MAmulmx                 */

y = y;
#ifdef TIMING_TEST

long beg_time,end_time;
long beg_time1,end_time1;

   beg_time = clock();

#endif

	if (!outldraw->first_char)
	{

   /*  get next position to begin stroking                      */

           cur_x_off = ((x - outldraw->prev_x) * *outldraw->x_scale)  + 
	            *outldraw->intrchr_spc;


  /* modify the matrix by the next position to place the next character */

	   outldraw->fnt_to_local[3] += cur_x_off;

	   outldraw->fnt_to_screen[3] = (outldraw->fnt_to_local[3] * outldraw->loc_to_screen[0]) +
					  *outldraw->trans_x_const;

	   outldraw->fnt_to_screen[7] = (outldraw->fnt_to_local[3] * outldraw->loc_to_screen[4]) +
					  *outldraw->trans_y_const;

	   outldraw->fnt_to_screen[11] = (outldraw->fnt_to_local[3] * outldraw->loc_to_screen[8]) +
					  *outldraw->trans_z_const;



	   if (!(*outldraw->strk_buf) && !(outldraw->gragad_flags & IS_PERSP) &&
		!*outldraw->fill_text && !outldraw->greek_text)
	   {
	      MAtrnmx(&msg,&four,outldraw->fnt_to_screen,trn_mtx);
	      DLset_matrix( outldraw->gpipe_id, trn_mtx, NULL, NULL, NULL );
	   }

	}
	else
	{
	   if (outldraw->greek_text)
	   {
	       DLreset_matrix( outldraw->gpipe_id );
	   }
	   outldraw->first_char = FALSE;
	}
#ifdef  TIMING_TEST

   end_time = clock();
   dptxvwsetup_time2 += (end_time - beg_time);
#endif

/*  save previous x so the width of the character can be calculated  */

	outldraw->prev_x = x;

/*  send the vectors to gpipe to be transformed and drawn on the screen  */

        if (*outldraw->fill_text && !outldraw->greek_text)
        {
            if (numpolys > 0)
            {
                
                for (i = 0; i < numpolys; i++)
                {
                   total_vec += numverts[i];
                }

                if (total_vec > MAX_NUM_POINTS)
                {
                    malloced_points = TRUE;
                    pnts = (Outl3DVertex *) om$malloc(size = (sizeof(Outl3DVertex)
                                                        * total_vec));
                  
                }
                else
                {
                    pnts = points;
                }

                if (numpolys > MAX_NUM_POLYS)
                {
                    malloced_num_verts = TRUE;
                    new_num_verts = (IGRint *) om$malloc(size = (sizeof(IGRint)
                                                        * numpolys));
                  
                }
                else
                {
                    new_num_verts = local_num_verts;
                }


/*              MAtypemx(&msg,outldraw->fnt_to_screen,&mtx_type);
*/
                total_vec_long = total_vec;
                MAptsxform(&msg, &total_vec_long, outldraw->fnt_to_screen,
                            (IGRdouble *)vertices, (IGRdouble *)pnts);


#if REMOVED_BY_SRO_FOR_DISPLAY_LIST_KLUDGE
                if (!(outldraw->gragad_flags & IS_PERSP))
                {
                    cur_pnt_ptr = &pnts[0];
                    cur_poly = 0;
                    for ( i = 0; i < numpolys; i++)
                    {
                        *cur_pnt_ptr = pnts[cur_poly++];
                        new_num_verts[i] = 1;
                        for (j = 1; j < numverts[i]; j++)
                        {
                            if (((int)(cur_pnt_ptr->x + 0.5)) != ((int) (pnts[cur_poly].x + 0.5)))
                            {
                                cur_pnt_ptr++;
                                *cur_pnt_ptr = pnts[cur_poly];
                                new_num_verts[i]++;
                            }
                            else
                            {
                                if (((int)(cur_pnt_ptr->y + 0.5)) != ((int) (pnts[cur_poly].y + 0.5)))
                                {
                                    cur_pnt_ptr++;
                                    *cur_pnt_ptr = pnts[cur_poly];
                                    new_num_verts[i]++;
                                }
                            }
                            cur_poly++;
                        }
                        cur_pnt_ptr++;
                        
                    }

#ifdef  TIMING_TEST

  beg_time1 = clock();
#endif

#ifdef GRAPHICS_ATP
        if(TSisGraphicsATP())
	{
          int	ii, jj, kk;
	  FILE *wfp;
          extern char TSGraphicsATPFile [DI_PATH_MAX];

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPPolyFill3D\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", outldraw->gpipe_id);
	    fprintf(wfp, "%d polygons:\n", numpolys);
	    for(kk = jj = 0; kk < numpolys; kk ++)
	    {
	      fprintf(wfp, "%d points:\n", new_num_verts[kk]);
	      for(ii = 0; ii < new_num_verts[kk]; ii ++)
	      {
	        fprintf(wfp, "%.16LE %.16LE %.16LE\n",
		  pnts[jj].x, pnts[jj].y, pnts[jj ++].z);
	      }
	    }
	    fprintf(wfp, "\nEnd of arguments to GPPolyFill3D\n\n");
	    fclose (wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
	}
#endif
                    DLdraw_3D_polygons( outldraw->gpipe_id, (double *)pnts, new_num_verts, numpolys,
                                        static_color_ref, static_dis_attr->style, 0xFFFF, static_dis_attr->weight,
                                        static_draw_opt | DL_OPT_FILL );

                    if ( DPdlist_feedback_in_progress )
                    {
                        DPdlist_process_polygons_for_text();
                        DLreset_feedback( DPdlist_wf_fb_pipe_id );
                        ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
                        ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;
                    }
                                              

                   
#ifdef  TIMING_TEST

   end_time1 = clock();
   dptxgp_fill += (end_time1 - beg_time1);
#endif

                }
                else
#endif
                {
#ifdef GRAPHICS_ATP
        if(TSisGraphicsATP())
	{
          int	ii, jj, kk;
	  FILE *wfp;
          extern char TSGraphicsATPFile [DI_PATH_MAX];

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPPolyFill3D\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", outldraw->gpipe_id);
	    fprintf(wfp, "%d polygons:\n", numpolys);
	    for(kk = jj = 0; kk < numpolys; kk ++)
	    {
	      fprintf(wfp, "%d points:\n", numverts[kk]);
	      for(ii = 0; ii < numverts[kk]; ii ++)
	      {
	        fprintf(wfp, "%.16LE %.16LE %.16LE\n",
		  pnts[jj].x, pnts[jj].y, pnts[jj ++].z);
	      }
	   }
	   fprintf(wfp, "\nEnd of arguments to GPPolyFill3D\n\n");
	   fclose (wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
	}
#endif

                    DLbust_3D_polygons( outldraw->gpipe_id,
                                        (double *)pnts,
                                        numverts,
                                        numpolys,
	                                static_color_ref,
                                        static_dis_attr->style,
                                        0xFFFF,
                                        static_dis_attr->weight, 
                                        static_draw_opt | DL_OPT_FILL );
                                        
                             
                    if ( DPdlist_feedback_in_progress )
                    {
                       DPdlist_process_polygons_for_text();
                       DLreset_feedback( DPdlist_wf_fb_pipe_id );
                       ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
                       ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;
                    }

                }

                if (malloced_points)
                {
                    om$dealloc(ptr = pnts);
                    malloced_points = FALSE;
                }

                if (malloced_num_verts)
                {
                    om$dealloc(ptr = new_num_verts);
                    malloced_num_verts = FALSE;
                }

            }
        }
        else
        {
	   if (!outldraw->greek_text)
	   {
               for (i = 0; i < numpolys; i++)
               {

                  if (*outldraw->strk_buf)
                  {
                     if (!outldraw->error)
                     {
                        if ((*numverts + 1) <= outldraw->total_points)
                        {
                           numverts_long = *numverts;
                           if (!(value = MAptsxform(&msg, &numverts_long,
                                         (IGRdouble *)outldraw->fnt_to_screen,
                                         (IGRdouble *)vertices,
					 *outldraw->strk_buf)))
                           {
                              outldraw->error = TRUE;
                           }
                           else
                           {
                               outldraw->total_points -= (*numverts + 1);
                               *outldraw->num_points += (*numverts + 1);

                               *outldraw->strk_buf += ( 3 * *numverts);

                               **outldraw->strk_buf = MAXDOUBLE;
                               *outldraw->strk_buf += 3;
                           }

                        }
                        else
                        {
                           outldraw->error = TRUE;
                        }

                    }  /* end of if (!outldraw->error)  */

                 } /* end of if (*outldraw->strk_buf)  */
                 else
                 {

                    if (outldraw->gragad_flags & IS_PERSP)
                    {
                       if (*numverts > MAX_NUM_POINTS)
                       {
                         malloced_points = TRUE;
                         pnts = (Outl3DVertex *) om$malloc(size = (sizeof(IGRdouble) * 3 
                                                            * *numverts));
                      
                       }
                       else
                       {
                          pnts = points;
                       }


                       numverts_long = *numverts;
                       MAptsxform(&msg, &numverts_long,
					outldraw->fnt_to_screen,
                                        (IGRdouble *)vertices, (IGRdouble *)pnts);

#ifdef GRAPHICS_ATP
        if(TSisGraphicsATP())
	{
          int	ii;
	  FILE *wfp;
          extern char TSGraphicsATPFile [DI_PATH_MAX];

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPlinestr3d\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", outldraw->gpipe_id);
	    fprintf(wfp, "%d points:\n", *numverts);
	    for(ii = 0; ii < *numverts; ii ++)
	    {
	      fprintf(wfp, "%.16LE %.16LE %.16LE\n",
		  pnts[ii].x, pnts[ii].y, pnts[ii].z);
	    }
	    fprintf(wfp, "\nEnd of arguments to GPlinestr3d\n\n");
	    fclose (wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
	}
#endif

                DLdraw_3D_line_string( outldraw->gpipe_id, (double *)pnts, *numverts,
                                       static_color_ref, static_dis_attr->style, 0xFFFF, static_dis_attr->weight,
	                               static_draw_opt );
                
                if ( DPdlist_feedback_in_progress )
                {
                   DPdlist_process_lines_for_text();
                   DLreset_feedback( DPdlist_wf_fb_pipe_id );
                   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
                   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;
                }

                       if (malloced_points)
                       {
                         om$dealloc(ptr = pnts);
                         malloced_points = FALSE;
                       }
                    }
                    else
                    {               
#ifdef TIMING_TEST
            dpnumtxvec += *numverts;
#endif
#ifdef GRAPHICS_ATP
        if(TSisGraphicsATP())
	{
          int	ii;
	  FILE *wfp;
          extern char TSGraphicsATPFile [DI_PATH_MAX];

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPlinestr3d\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", outldraw->gpipe_id);
	    fprintf(wfp, "%d points:\n", *numverts);
	    for(ii = 0; ii < *numverts; ii ++)
	    {
	      fprintf(wfp, "%.16LE %.16LE %.16LE\n",
		vertices[ii].x, vertices[ii].y, vertices[ii].z);
	    }
	    fprintf(wfp, "\nEnd of arguments to GPlinestr3d\n\n");
	    fclose (wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
	}
#endif
                DLdraw_3D_line_string( outldraw->gpipe_id, (double *)vertices, *numverts,	
	                               static_color_ref, static_dis_attr->style, 0xFFFF, static_dis_attr->weight,
                                       static_draw_opt );
                if ( DPdlist_feedback_in_progress )
                {
                   DPdlist_process_lines_for_text();
                   DLreset_feedback( DPdlist_wf_fb_pipe_id );
                   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
                   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;
                }                   
                                         
                    }

                 } /* end of else of if (..strk_buf ...  */

                  vertices += *numverts;
                  numverts++;
               } /* end of for (i=....) */
	    }
	    else
	    {

/*
                if (FSGetOutlCharInfo(*outldraw->font_id,(unsigned short) outldraw->char_string[outldraw->char_num],
                                   &charinfo))
                {
                    not_valid_char = TRUE;
                    while (not_valid_char)
                    {
                        outldraw->char_num++;
                        if (!FSGetOutlCharInfo(*outldraw->font_id,(unsigned short) outldraw->char_string[outldraw->char_num],
                                   &charinfo))
                        {
                            not_valid_char = FALSE;
                        }
                    }
                }
                        
*/		

		greek_point[0] = 0.0;
		greek_point[1] = 0.0;
		greek_point[2] = 0.0;
		greek_point[3] =  0.0;
		greek_point[4] =  *outldraw->bodysize/2.0;
		greek_point[5] = 0.0;


		total_vec = 2;
                total_vec_long = total_vec;
                MAptsxform(&msg, &total_vec_long,outldraw->fnt_to_screen,
                                          greek_point,greek_point);

	

#ifdef GRAPHICS_ATP
        if(TSisGraphicsATP())
	{
	  FILE *wfp;
          extern char TSGraphicsATPFile [DI_PATH_MAX];

	  if(wfp = fopen(TSGraphicsATPFile, "a"))
	  {
	    fprintf(wfp, "Arguments to GPlinestr3d\n\n");
	    fprintf(wfp, "GPIPE ID:\t%d\n", outldraw->gpipe_id);
	    fprintf(wfp, "greek points:\n");
	    fprintf(wfp, "%.16LE %.16LE %.16LE\n%.16LE %.16LE %.16LE\n",
	      greek_point[0], greek_point[1], greek_point[2],
	      greek_point[0], greek_point[1], greek_point[2]);
	    fprintf(wfp, "\nEnd of arguments to GPlinestr3d\n\n");
	    fclose (wfp);
	  }
	  else fprintf(stderr, "Error opening output file.\n");
	}
#endif

                DLdraw_3D_line_string( outldraw->gpipe_id, greek_point, 2,
	                               static_color_ref, static_dis_attr->style, 0xFFFF, static_dis_attr->weight,
                                       static_draw_opt );
                if ( DPdlist_feedback_in_progress )
                {
                   DPdlist_process_lines_for_text();
                   DLreset_feedback( DPdlist_wf_fb_pipe_id );
                   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
                   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;
                }                                       

                outldraw->char_num++;

	    }

        } /* end of else of if (...fill_text.. */
	
#ifdef  TIMING_TEST

   beg_time = clock();
   dpactstrk_time += (beg_time - end_time);
#endif

}



#if defined( X11 )
void DPbmapdrawtext(mydisplay,myscreen,outldraw,mygc,x,y,width,height,bitmap,bx,by,charInfo)
	Display			*mydisplay;
	int			myscreen;
	struct DPoutldraw 	*outldraw;
	GC			mygc;
	int 			x,y;
	int			width;
	int			height;
	BmapBitmap		*bitmap;
	Real64			bx, by;
	BmapCharInfo		*charInfo;
#elif defined( ENV5 )
void DPbmapdrawtext(outldraw,x,y,width,height,bitmap,bx,by,charInfo)
	struct DPoutldraw 	*outldraw;
	int 			x,y;
	int			width;
	int			height;
	BmapBitmap		*bitmap;
	Real64			bx, by;
	BmapCharInfo		*charInfo;
#endif

{
        IGRlong total_vec_long = 0;
	IGRint not_valid_char;
	IGRdouble  trn_mtx[16];
	IGRdouble  cur_x_off;
	IGRdouble  width_diff;
	IGRdouble  x_dist;
	IGRdouble  y_dist;
	IGRlong	   msg;
	IGRint	   prev_char_valid = TRUE;
	IGRdouble  point[3];
        IGRshort   four = 4;   /* value used in MAmulmx                 */
	BmapCharInfo	charinfo;
        WLuint32  wl_mode;

#ifdef TIMING_TEST

long beg_time,end_time;
long beg_time1,end_time1;

   beg_time = clock();

#endif
	if (FSGetBmapCharInfo(*outldraw->font_id,(unsigned short) outldraw->char_string[outldraw->char_num],
			   &charinfo))
	{
	    prev_char_valid = FALSE;
	    not_valid_char = TRUE;
	    while (not_valid_char)
	    {
		outldraw->char_num++;
		if (!FSGetBmapCharInfo(*outldraw->font_id,(unsigned short) outldraw->char_string[outldraw->char_num],
			   &charinfo))
		{
		    not_valid_char = FALSE;
		}
	    }
	}
		


	if (!outldraw->first_char)
	{

	    if (!FSGetTextVect(*outldraw->font_id,&outldraw->char_string[outldraw->char_num - 1],
			  2,0.0,0.0,&x_dist,&y_dist))
	    {
		if (outldraw->txt_angle_cos != 1.0)
		{
		   if ((outldraw->txt_angle_cos > - TEXT_FP_ERR) && (outldraw->txt_angle_cos < TEXT_FP_ERR))
		   {
		       x_dist = MAabsolute(y_dist);
		   }
		   else
		   {
		       x_dist = x_dist / outldraw->txt_angle_cos;
		   }
		}

		if (prev_char_valid)
		{
	            width_diff = charinfo.setWid + outldraw->prev_char_width - x_dist;
		}
		else
		{
		    width_diff = 0.0;
		}
	    }
	    else
	    {
		width_diff = 0.0;
	    }

	    outldraw->prev_x += outldraw->prev_char_width - width_diff;

   /*  get next position to begin stroking                      */

           cur_x_off = ((outldraw->prev_char_width - width_diff) * *outldraw->x_scale)  + 
	            *outldraw->intrchr_spc;


  /* modify the matrix by the next position to place the next character */

	   outldraw->fnt_to_local[3] += cur_x_off;

	   outldraw->fnt_to_screen[3] = (outldraw->fnt_to_local[3] * outldraw->loc_to_screen[0]) +
					  *outldraw->trans_x_const;

	   outldraw->fnt_to_screen[7] = (outldraw->fnt_to_local[3] * outldraw->loc_to_screen[4]) +
					  *outldraw->trans_y_const;

	   outldraw->fnt_to_screen[11] = (outldraw->fnt_to_local[3] * outldraw->loc_to_screen[8]) +
					  *outldraw->trans_z_const;



	   if (!(*outldraw->strk_buf) && !(outldraw->gragad_flags & IS_PERSP) &&
		!*outldraw->fill_text)
	   {
	      MAtrnmx(&msg,&four,outldraw->fnt_to_screen,trn_mtx);
	      DLset_matrix( outldraw->gpipe_id, trn_mtx, NULL, NULL, NULL );
	   }

           point[0] = 0.0;

/*  save previous x so the width of the character can be calculated  */


	}
	else
	{
/*  save previous x so the width of the character can be calculated  */

	   outldraw->first_char = FALSE;
	}
#ifdef  TIMING_TEST

   end_time = clock();
   dptxvwsetup_time2 += (end_time - beg_time);
#endif


	outldraw->prev_char_width = charinfo.setWid;


	if ((width != 0) && (height != 0))
	{

            total_vec_long = 1;

            point[0] = 0.0;
            point[1] = 0.0;
            point[2] = 0.0;

            MAptsxform(&msg, &total_vec_long, outldraw->fnt_to_screen,
                                  point, point);


            x = point[0] + 0.5 + charinfo.hOff;
            y = point[1] + 0.5 - charinfo.vOff - height;

            switch ( static_draw_opt & DL_OPT_BASE_MODE )
            {
               case DL_OPT_BASE_DRAW :
                  wl_mode = WL_BASE_DRAW;
                  break;
               case DL_OPT_BASE_ERASE :
                  wl_mode = WL_BASE_ERASE;
                  break;
               default :
                  wl_mode = WL_BASE_NOOP;
                  break;
            }

            switch ( static_draw_opt & DL_OPT_HILITE_MODE )
            {
               case DL_OPT_HILITE_DRAW :
                  wl_mode |= WL_HILITE_DRAW;
                  break;
               case DL_OPT_HILITE_ERASE :
                  wl_mode |= WL_HILITE_ERASE;
                  break;
               default :
                  wl_mode |= WL_HILITE_NOOP;
                  break;
            }

            WLset_drawing_mode( outldraw->bitmap_win_no, wl_mode );

            WLset_active_symbology( outldraw->bitmap_win_no, static_color_ref,
                                    0, 0, 0, WL_SYMB_CHANGE_COLOR );

	    WLdraw_bitmap( outldraw->bitmap_win_no, x, y, width, height, bitmap );
	}

	outldraw->char_num++;

#ifdef  TIMING_TEST

   beg_time = clock();
   dpactstrk_time += (beg_time - end_time);
#endif

}

void	DPenable_fill_text()
{
    DPfill_text_enabled = TRUE;
}

void	DPdisable_fill_text()
{
    DPfill_text_enabled = TRUE;
}

void DPbmap_display(flag)
   int		flag;
{
    DPbitmap_display_enabled = flag;
}



int DPtxstrk(
        IGRint                 *msg,
        struct IGRlbsys         *lbsys,
        struct IGResintx        *txt_ele,
	struct IGRdisplay	*dis_attr,
	IGRint			win_no,
	IGRint			gpipe_id,
        struct DPfnt_os_tbl     *os_tbl_ptr,
	IGRint			flags,
	IGRuint			disp_flags,
	IGRdouble		vw_scale,
	IGRint			drawplanes,
	IGRdouble		*strk_buf,
	IGRint			*num_points,
        int			draw_opt )

     {  
        IGRdouble  cur_x_off = 0; /* current x offset from the stroking */
                                  /* origin                             */
        IGRdouble  cur_y_off = 0; /* current y offset from the stroking */
                                  /* origin                             */
        IGRint     value = TRUE;/* return value                         */
        IGRchar    *txt_index; /* pointer to current character          */
        IGRchar    *old_txt_index; /* pointer to character          */
        IGRchar    *txt_ptr = NULL; /* pointer to character          */
	IGRchar    *malloced_txt_ptr = NULL;
	IGRushort  txt_buf[MAX_TMP_BUF/2];
        IGRshort   four = 4;   /* value used in MAmulmx                 */
	IGRlong	   three = 3;
	IGRdouble  x,y;
        IGRint     i,j;      /* loop variables                    */
	IGRint	   font_flags;
	IGRint 	   fill_text = FALSE;
	IGRuint	   temp_fill_text;
	IGRint	   in_flags;
	IGRshort   cur_font;
	IGRshort   prev_font;
	IGRint	   font_id;
	IGRint	   use_bitmap = TRUE;
	IGRdouble  widthsize;
	IGRdouble  bodysize;
	IGRdouble  decent;
 	IGRdouble  trans_x_const;
	IGRdouble  trans_y_const;
	IGRdouble  trans_z_const;
	IGRdouble  bmap_x_scale;
	IGRdouble  bmap_y_scale;
	IGRdouble  angles[3];
	IGRdouble  txt_ratio;
	IGRdouble  aspect_ratio = 1.0;
	IGRdouble  scale_ratio = 1.0;
	IGRdouble  angle = 0.0;
	IGRint	   total_points;
	IGRshort   num_char;
        IGRdouble  intrchr_spc; /* space between characters             */
        IGRdouble  line_spacing;/* vertical spacing used to calculate   */
                                /* new baseline                         */
        IGRdouble  baseline = 0;/* current baseline                     */
        IGRdouble  txt_height;  /*  text height                         */
	IGRdouble  x_scale;	/* scale that maps from font coordinates*/
				/* to world coordinates			*/
	IGRdouble  y_scale;	/* scale that maps from font coordinates*/
				/* to world coordinates			*/
        IGRdouble  txt_width;   /*  text height                         */
	IGRdouble  tmp_pnts[9];
        IGRdouble  tmp_mtx[16]; /*  temporary matrix                    */
	IGRdouble  old_mtx[16];
	IGRdouble  trn_mtx[16];
	IGRdouble  mtx[16];
	IGRdouble  local_to_screen[16]; /*font to screen matrix		*/
        IGRdouble  fnt_to_local[16]; /* font to local matrix            */
        IGRdouble  fnt_to_screen[16];/* font to screen matrix           */
	int	   *old_func;
	int	   *old_bmap_func;
	struct DPoutldraw	outldraw;
	struct DPesc_args	esc_args;
        IGRlong    status;
        WLuint32   context_no;
        struct WLnative_info native_info;

#ifdef TIMING_TEST

long beg_time,end_time,beg_time1;

   beg_time = clock();

#endif
        *msg = MSSUCC;

	static_draw_opt = draw_opt;
	static_dis_attr = dis_attr;
	WLpack_index_colorref( dis_attr->color, &static_color_ref, FALSE );

 /* save old text stroking routine and set stroking routine to 
    my routine that strokes text				*/

	FSGetOutl3DDrawFunc(&old_func);
	FSSetOutl3DDrawFunc(DPdrawtext);	

	FSGetBmapDrawFunc(&old_bmap_func);
	FSSetBmapDrawFunc(DPbmapdrawtext);	

 /* save the current matrix  */

	if (!strk_buf) 
	{
		DLget_matrix( gpipe_id, old_mtx );
		MAtrnmx(&status,&four,old_mtx,mtx);
	}

	if (strk_buf)
	{
	   total_points = *num_points;
	   outldraw.total_points = total_points;
	   *num_points = 0;
	   outldraw.num_points = num_points;
	}

	outldraw.error = FALSE;
	outldraw.strk_buf = &strk_buf;

	cur_font = txt_ele->estx->font;
	prev_font = txt_ele->prev_font;

  /*  compute the text width and the text height                */

        txt_width   = txt_ele->estx->width;

        txt_height  = txt_ele->estx->height;

	txt_ratio = txt_width/txt_height;

  /* calculate inter character spacing (% of text width)	*/

        intrchr_spc = (txt_ele->estx->char_spac - 1) * txt_width;



  /*  get font information   */

	in_flags = 0;	

	if ( ! strk_buf )
	   {
           MAmulmx(&status,&four,&four,&four,mtx,lbsys->matrix,tmp_mtx);
    

           tmp_pnts[0] = 1.0;
           tmp_pnts[1] = 0.0;
           tmp_pnts[2] = 0.0;
           tmp_pnts[3] = 0.0;
           tmp_pnts[4] = 1.0;
           tmp_pnts[5] = 0.0;
           tmp_pnts[6] = 0.0;
           tmp_pnts[7] = 0.0;
           tmp_pnts[8] = 0.0;

           MAptsxform(&status,&three,tmp_mtx,tmp_pnts,tmp_pnts);
 
           tmp_pnts[0] -= tmp_pnts[6];
           tmp_pnts[1] -= tmp_pnts[7];
           tmp_pnts[2] -= tmp_pnts[8];
           tmp_pnts[3] -= tmp_pnts[6];
           tmp_pnts[4] -= tmp_pnts[7];
           tmp_pnts[5] -= tmp_pnts[8];

           tmp_pnts[6] = 0.0;
           tmp_pnts[7] = 0.0;
           tmp_pnts[8] = 0.0;

           MA2ptdis(&status,&tmp_pnts[6],&tmp_pnts[0],&bmap_x_scale);
           MA2ptdis(&status,&tmp_pnts[6],&tmp_pnts[3],&bmap_y_scale);
	   }

        if ( (!DPdlist_feedback_in_progress) &&
             (DPbitmap_display_enabled) &&
             (disp_flags & DPPOLY_FILL) && 
             (!strk_buf) &&
             !(flags & DPVIEW_DYNAMICS) &&
             (!(flags & IS_PERSP)) ) 
        {
            /* see if there is rotation   x or y rotation within a tolerance */
            if ((tmp_pnts[2] > - TEXT_FP_ERR) && (tmp_pnts[2] < TEXT_FP_ERR) && 
                (tmp_pnts[5] > - TEXT_FP_ERR) && (tmp_pnts[5] < TEXT_FP_ERR) && 
		(((tmp_pnts[0] * tmp_pnts[4]) - (tmp_pnts[1] * tmp_pnts[3]))) < 0.0)
            {
                scale_ratio = (bmap_x_scale/bmap_y_scale);
                aspect_ratio = scale_ratio * txt_ratio;

                tmp_pnts[6] = 1.0;

  /* zero out since it passsed the zero test (in case is was close to zero)  */

		tmp_pnts[2] = 0.0;

                MAang2vc(&status,&tmp_pnts[0],&tmp_pnts[6],angles);

                angle = angles[0] * 180.0/PI;

                vw_scale = bmap_y_scale;


  /* extract scale              */

                bodysize = txt_height * vw_scale;
		widthsize = txt_width * bmap_x_scale;
		
                if ((bodysize > MIN_BITMAP_SIZE) && 
                    (bodysize < MAX_BITMAP_SIZE) &&
		    (widthsize > MIN_BITMAP_SIZE) &&
		    (widthsize < MAX_BITMAP_SIZE))
                {
                    in_flags = BITMAP_FONT;
                }
		else
		{
		    aspect_ratio = 1.0;
		}
            }
            else
            {
                use_bitmap = FALSE;
            }
	}
	else
	{
	    use_bitmap = FALSE;
	}

        if (!(value = DPget_fnt_adr(&status,in_flags,os_tbl_ptr,txt_ele->font_id,
                    txt_ele->estx->font,angle,aspect_ratio,&font_id,&bodysize,&decent,&font_flags)))
        {
           *msg = MSFAIL;
           goto wrapup;
        }

	if ( (disp_flags & DPPOLY_FILL) &&
             (font_flags & FILLABLE_FONT) &&
	     (!strk_buf) &&
             (DPfill_text_enabled) &&
              ( (DPdlist_feedback_in_progress) || (!(flags & DPVIEW_DYNAMICS)) ) )
	{
	   fill_text = TRUE;
	   if (!(flags & IS_PERSP))
	   {
		if (!strk_buf) 
		{
		       DLreset_matrix( gpipe_id );
		}
	   }
	}
	else
	   aspect_ratio = 1.0;

  /*  get scale information                                     */

	x_scale = (txt_width / (bodysize - decent))/aspect_ratio;

	y_scale = txt_height / (bodysize- decent);

        line_spacing = (y_scale * bodysize) * txt_ele->estx->line_spac;


   /*   set up font to local matrix   */

	MAidmx(&status,fnt_to_local);
        fnt_to_local[0] = x_scale;
        fnt_to_local[5] = y_scale;


   /* set up the local to world matrix  */     


	if (!strk_buf && !(flags & IS_PERSP))
	{
           if ( !(value = MAmulmx(&status,&four,&four,&four,mtx,
        		lbsys->matrix,local_to_screen)))
           {
              goto wrapup;
           }
	}
	else
	{
	   OM_BLOCK_MOVE(lbsys->matrix,local_to_screen,sizeof(IGRdouble) * 16);
	}


        if ( !(value = MAmulmx(&status,&four,&four,&four,local_to_screen,
			fnt_to_local,fnt_to_screen)))
        {
           goto wrapup;
        }

  /* set up structure that is passed to the function that strokes the text */
	
	trans_x_const = local_to_screen[3];
	trans_y_const = local_to_screen[7];
	trans_z_const = local_to_screen[11];


	outldraw.greek_text = FALSE;

/*	if ((!(flags & IS_PERSP)) &&
	   (!(flags & DPVIEW_DYNAMICS)) &&
	   (!strk_buf))
	{
	    if (((txt_height * bmap_y_scale) < MIN_BITMAP_SIZE) || 
		((txt_width * bmap_x_scale) < MIN_BITMAP_SIZE))
	    {
		outldraw.greek_text = TRUE;
	    }
	}
*/
        temp_fill_text = (IGRuint)fill_text;

	outldraw.bodysize = &bodysize;
	outldraw.use_bitmap = use_bitmap;
	outldraw.bitmap_win_no = win_no;
	outldraw.bitmap_drawplanes = drawplanes;
	outldraw.txt_angle_cos = angles[2];
	outldraw.aspect_ratio = &aspect_ratio;
	outldraw.fnt_to_local = fnt_to_local;
	outldraw.loc_to_screen = local_to_screen;
	outldraw.fnt_to_screen = fnt_to_screen;
	outldraw.trans_x_const = &trans_x_const;
	outldraw.trans_y_const = &trans_y_const;
	outldraw.trans_z_const = &trans_z_const;
	outldraw.gpipe_id = gpipe_id;
	outldraw.flags = font_flags;
	outldraw.gragad_flags = flags;
	outldraw.x_scale = &x_scale;
	outldraw.y_scale = &y_scale;
	outldraw.txt_width = &txt_width;
	outldraw.txt_height = &txt_height;
	outldraw.intrchr_spc = &intrchr_spc;
	outldraw.fill_text = &temp_fill_text;
	outldraw.font_id = &font_id;

	esc_args.angle = angle;
	esc_args.scale_ratio = scale_ratio;
	esc_args.aspect_ratio = &aspect_ratio;
	esc_args.vw_scale = vw_scale;
	esc_args.use_bitmap = use_bitmap;
	esc_args.text_index = (IGRuchar **)&txt_index;
	esc_args.trans_x_const = &trans_x_const;
	esc_args.trans_y_const = &trans_y_const;
	esc_args.trans_z_const = &trans_z_const;
	esc_args.txt_height = &txt_height;
	esc_args.txt_width = &txt_width;
	esc_args.loc_to_screen = local_to_screen;
	esc_args.fnt_to_screen = fnt_to_screen;
	esc_args.txt_ele = txt_ele;
	esc_args.os_tbl_ptr = os_tbl_ptr;
	esc_args.line_spacing = &line_spacing;
	esc_args.intrchr_spc = &intrchr_spc;
	esc_args.x_scale = &x_scale;
	esc_args.y_scale = &y_scale;
	esc_args.fnt_to_local = fnt_to_local;
	esc_args.baseline = &baseline;
	esc_args.font_id = &font_id;
	esc_args.bodysize = &bodysize;
	esc_args.decent = &decent;
	esc_args.font_flags = &font_flags;
	esc_args.disp_flags = disp_flags;
	esc_args.fill_text = &fill_text;
	esc_args.strk_buf = strk_buf;
	esc_args.win_no = &win_no;
	esc_args.cur_font = &cur_font;
	esc_args.prev_font = &prev_font;

	if ( txt_ele->flags & 0x00000001 )
	{
	   txt_index = txt_ele->just_moves;
	   for ( j = 0 ; j < 2 ; j ++ )
	   {
	      txt_index ++ ;

              DPesc_handler ( &status , &esc_args);

	   }
	}

        txt_index = txt_ele->text_string;
        i=0;

#ifdef  TIMING_TEST

   end_time = clock();
   dptxsetup_time += (end_time - beg_time);
#endif

        while (i < txt_ele->estx->text_length)
        {

#ifdef  TIMING_TEST

   beg_time1 = clock();
#endif

        /*  multiply all three matrices together  world_to_screen X     */
        /*  local to world X font to local                              */


	   if (!strk_buf && !(flags & IS_PERSP) && !fill_text)
           {
	      MAtrnmx(&status,&four,fnt_to_screen,trn_mtx);
		if (!strk_buf) 
		{
		      DLset_matrix( gpipe_id, trn_mtx, NULL, NULL, NULL );
		}
	   }

           cur_y_off = 0;

/*  find escape sequence so that we can draw text strings and take
    advantage of kerning pairs						*/

	   GRfind_esc_char(&status, (IGRuchar *)txt_index, 
				(IGRshort)(txt_ele->estx->text_length - i),
				font_flags, &num_char);
           *msg = status;

	   if (num_char == 0)
	   {
	      if (!strk_buf && !(flags & DPVIEW_DYNAMICS))
	      {
		 if (IGEstop())
		 {
         	    break;
      		 }
	      }
		   
	      txt_index++;
	      i++;
              old_txt_index = txt_index;

/*  process escape sequences						*/

              DPesc_handler(&status,&esc_args);
              *msg = status;

/*
              if ((!(flags & IS_PERSP)) &&
                  (!(flags & DPVIEW_DYNAMICS)) &&
                  (!strk_buf))
              {
                  if (((txt_height * bmap_y_scale) < MIN_BITMAP_SIZE) || 
                    ((txt_width * bmap_x_scale) < MIN_BITMAP_SIZE))
                  {
                      outldraw.greek_text = TRUE;
                  }
		  else
		  {
		      outldraw.greek_text = FALSE;
		  }
              }

*/
	      
	      if (fill_text)
	      {
		  if (DPfill_text_enabled)
		  {
                      if ( !DPdlist_feedback_in_progress )
                      {
   		         if (!(flags & (IS_PERSP | DPVIEW_DYNAMICS)))
		         {
			   if (!strk_buf) 
		   	   {
			          DLreset_matrix( gpipe_id );
			   }
		         }
		         else
		         {
		  	   if (flags & DPVIEW_DYNAMICS)
			   {
			      fill_text = FALSE;
			   }
		         }
                     }
		  }
		  else
		  {
		       fill_text = FALSE;
		  }
	      }
              i += ( txt_index - old_txt_index);
	   }
	   else
	   {
	
	      outldraw.prev_x = 0.0;
	      outldraw.prev_y = 0.0;
	      outldraw.first_char = TRUE;
	      outldraw.char_num = 0;


  /*  draw the text string					   */
  /*  This will actually call DPdrawtext which is defined below    */

	      if (font_flags & SIXTEEN_BIT)
	      {

		 if (txt_ele->estx->text_length > MAX_TMP_BUF)
		 {
		    if (!malloced_txt_ptr)
		    {
		       malloced_txt_ptr = om$malloc(size = txt_ele->estx->text_length);
		       if (!malloced_txt_ptr)
		       {
		          *msg=MSFAIL;
		          goto wrapup;
		       }
		    }
		    txt_ptr = malloced_txt_ptr;
		 }
		 else
		 {
		    txt_ptr =  (char *)txt_buf;
		 }

#ifndef BIG_ENDIAN 
		 for (j = 0; j < (num_char << 1); j += 2)
		 {
		    txt_ptr[j] = txt_index[j + 1];
		    txt_ptr[j+1] = txt_index[j];
		 }
#else
	         /* don't swap chars on the SPARC */
	         memcpy( txt_ptr, txt_index, (num_char << 1) );
#endif


	      }
	      else
	      {

		 txt_ptr = txt_index;

	      }

#ifdef  TIMING_TEST

   end_time = clock();
   dptxvwsetup_time += (end_time - beg_time1);
#endif
	      outldraw.char_string = (IGRuchar *)txt_ptr;
	      outldraw.prev_char_width = 0.0;
              *outldraw.fill_text = fill_text;
#if defined( ENV5 )
	      FSDrawText(&outldraw,font_id,txt_ptr,num_char,0.0,0.0,
			 &x,&y);
#elif defined( X11 )
              WLget_window_base_context( win_no, &context_no );
              WLget_native_info( win_no, context_no, &native_info );
	      FSXDrawText(EXdisplay,native_info.screen,&outldraw,
                          native_info.gc,font_id,txt_ptr,
                          num_char,0.0,0.0,&x,&y);
#endif

#ifdef  TIMING_TEST

   beg_time1 = clock();
   dpfs_time += (beg_time1 - end_time);
#endif

	      if (outldraw.error)
	      {
		 value = FALSE;
		 goto wrapup;
	      }
	      else
	      {
	         if (font_flags & SIXTEEN_BIT)
	         {
		    num_char <<= 1;
	         }

	         txt_index += num_char;
	         i += num_char;

/*  if the msg from GRfind_esc_char is ESCAPE_TYPE then an escape-escape
    character has been found and we need to skip the second escape         */

		 if (*msg == ESCAPE_TYPE)
		 {
		    i++;
		    txt_index++;
		 }
   /*  get next position to begin stroking                      */
		
		 if (use_bitmap && (outldraw.prev_char_width != 0.0))
		 {
		     cur_x_off = outldraw.prev_char_width * x_scale + intrchr_spc;
		 }
		 else
		 {
                   cur_x_off = ((x - outldraw.prev_x) * x_scale) + intrchr_spc;
		 }



  /* modify the matrix by the next position to place the next character */

                 fnt_to_local[3] += cur_x_off;

		 fnt_to_screen[3] = (fnt_to_local[3] * local_to_screen[0]) + 
				    trans_x_const;

		 fnt_to_screen[7] = (fnt_to_local[3] * local_to_screen[4]) + 
				    trans_y_const;

		 fnt_to_screen[11] = (fnt_to_local[3] * local_to_screen[8]) + 
				    trans_z_const;

	      }
	   }
#ifdef  TIMING_TEST

   end_time = clock();
   dptxvwsetup_time += (end_time - beg_time1);
#endif

        }  /* end of while ( i < txt_ele->estx->text_length  */


	if (strk_buf)
	{
	   (*num_points)-- ;
	}

#ifndef IDRAW
	if ( flags & DPVIEW_DYNAMICS )
	{
		if (!strk_buf) 
		{
                        struct IGRdisplay tmp_dis_attr;

                        /* text always uses solid line style - TR119305348 */
                        tmp_dis_attr = *dis_attr;
                        tmp_dis_attr.style = 0;

			DLpass_to_feedback( gpipe_id, (WLint16) 0,(WLint16) 0, 0 );

                        if ( ! DPdlist_feedback_in_progress )
                        {
	   		   DPpack_buffer(IGRLB, &tmp_dis_attr);
                        }

			DLreset_feedback( gpipe_id );
		}
	}
#endif

wrapup:

	FSSetOutl3DDrawFunc(old_func);	
	FSSetBmapDrawFunc(old_bmap_func);	
	if (malloced_txt_ptr)
	{
	   om$dealloc(ptr = malloced_txt_ptr);
	}
	   
        if ( (!strk_buf) && !(flags & IS_PERSP) )
	{
		DLset_matrix( gpipe_id, old_mtx, NULL, NULL, NULL );
	}

#ifdef  TIMING_TEST

   end_time = clock();
   dptxstrk_time += (end_time - beg_time);
#endif

        return (value);
       
     } /* end DPtxstrk  */
