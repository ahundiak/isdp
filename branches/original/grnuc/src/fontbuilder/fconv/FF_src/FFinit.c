/*
$Log: FFinit.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:12  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:24  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:27  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:50:29  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:28:56  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:41:43  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sdl.h> 
#include <errno.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include <tools.h>
#include <itools.h>
#include "FSBmap.h"
#include "FFdac.h"
#include "FFdef.h"
#include "FFicons.h"
#include "FFmacros.h"
#include "FFstructs.h"
#include "FFerrdef.h"
#include "flibstruct.h"



   extern         int           Num_typefaces,  Num_fms, Num_tracks,
                                Typeface_num, Flib_font_offsets[],
                                Num_flibs, Num_flib_files, Char_sys, FF_icons;
   extern          short        Num_flib_fonts, Flib_font_num;
   extern unsigned short        Num_flib_chars;
   extern          char         Icons[20][2];
   extern          Typepath     Typeface_path, Typeface_file,
                                Cur_typeface, New_typeface,
                                FM_path, FM_file,
                                Flib_path, Flib_file, Flib_font, Flib_name;
   extern          Conv_table  *Flib_chars;
   extern          GGitem_list *Typefaces,  *Typeface_names,
                               *FM_files,   *FM_names,
                               *Flib_files, *Flib_fonts;
   extern          GGlist       Typeface_name, FM_name;
   extern          FFview      *FFviews, *FFcur_view, *FFprev_view, *FFnext_view;
   extern struct   dac_vars    *Dac;
                   GPxyz        CharMetrics[40];
          static   int          EndCharMetrics;

FFinit_wind( mod_type_path, init_path, FF_menu, FFw_id )

        Typepath  mod_type_path;
        char      init_path[];
        int      *FF_menu, *FFw_id;
{
          int     sts, status, count,
                  height, width, xo, yo, x, y, w_no,
                  gadget_ids[25], id;
          short  *CX8to16();
          char    dpvlt[80];
          char   *ff_icons[80];

          uInt32  font_flags;

   status = FF_S_SUCCESS;

   Enter_tools();

   font_flags = 0;
   FSEnter(font_flags);

   Enter_Itools();

   Set_message_mode(4);
   Set_logo("FontFact");

   FF_MESSAGE("Display in progress. . .");

   if( !(UTcheck_path(mod_type_path)) ) {
      status = FF_DIR_PATH_ERROR;
      printf("\nError in directory path to publish");
      goto end_FFinit_wind;
      }

   strcpy( dpvlt, init_path );
   strcat( dpvlt, "/DPvlt\0" );

   strcpy( ff_icons, init_path );
   strcat( ff_icons, "/fontfact_icons" );

   /* initialize system wide variables */
   Num_typefaces    = 0;
   Num_fms          = 0;
   Num_flibs        = 0;
   Num_tracks       = 0;
   Typeface_num     = 0;
   Num_flib_files   = 0;
   Num_flib_fonts   = 0;
   Num_flib_chars   = 0;
   Flib_font_num    = 0;
   Char_sys         = 1;
   Typeface_path[0] = 0;
   Typeface_file[0] = 0;
   Cur_typeface[0]  = 0;
   New_typeface[0]  = 0;
   FM_path[0]       = 0;
   FM_file[0]       = 0;
   Flib_path[0]     = 0;
   Flib_name[0]     = 0;
   Flib_font[0]     = 0;
   Flib_file[0]     = 0;
   Typefaces        = NULL;
   Typeface_names   = NULL;
   Typeface_name[0] = 0;
   FM_files         = NULL;
   FM_names         = NULL;
   FM_name[0]       = 0;
   Flib_files       = NULL;
   Flib_fonts       = NULL;
   Flib_chars       = NULL;
   FFviews          = NULL;
   FFcur_view       = NULL;
   FFprev_view      = NULL;
   FFnext_view      = NULL;
   for(count = 0; count < 256; count++)
      Flib_font_offsets[count] = NULL;

   FFinit_colors( ff_icons );
   
   /* Em square RED */
   CharMetrics[0].x =     0.0;
   CharMetrics[0].y =     0.0;
   CharMetrics[0].z =     0.0;
   CharMetrics[1].x =     0.0;
   CharMetrics[1].y = -2042.0;
   CharMetrics[1].z =     0.0;
   CharMetrics[2].x =  8640.0;
   CharMetrics[2].y = -2042.0;
   CharMetrics[2].z =     0.0;
   CharMetrics[3].x =  8640.0;
   CharMetrics[3].y =  6598.0;
   CharMetrics[3].z =     0.0;
   CharMetrics[4].x =     0.0;
   CharMetrics[4].y =  6598.0;
   CharMetrics[4].z =     0.0;
   CharMetrics[5].x =     0.0;
   CharMetrics[5].y =     0.0;
   CharMetrics[5].z =     0.0;

   /* Base line BLACK*/
   CharMetrics[6].x =     0.0;
   CharMetrics[6].y =     0.0;
   CharMetrics[6].z =     0.0;
   CharMetrics[7].x = 17280.0;
   CharMetrics[7].y =     0.0;
   CharMetrics[7].z =     0.0;

   /* Reverence lines GREEN */
   CharMetrics[8].x  = -1440.0;
   CharMetrics[8].y  =  6738.0;
   CharMetrics[8].z  =     0.0;
   CharMetrics[9].x = 17280.0;
   CharMetrics[9].y =  6738.0;
   CharMetrics[9].z =     0.0;

   CharMetrics[10].x =  -1440.0;
   CharMetrics[10].y =   6458.0;
   CharMetrics[10].z =     0.0;
   CharMetrics[11].x =  17280.0;
   CharMetrics[11].y =   6458.0;
   CharMetrics[11].z =     0.0;

   CharMetrics[12].x =  -1440.0;
   CharMetrics[12].y =   -140.0;
   CharMetrics[12].z =     0.0;
   CharMetrics[13].x =  17280.0;
   CharMetrics[13].y =   -140.0;
   CharMetrics[13].z =     0.0;

   CharMetrics[14].x =  -1440.0;
   CharMetrics[14].y =  -1902.0;
   CharMetrics[14].z =     0.0;
   CharMetrics[15].x =  17280.0;
   CharMetrics[15].y =  -1902.0;
   CharMetrics[15].z =     0.0;

   CharMetrics[16].x =  -1440.0;
   CharMetrics[16].y =  -2182.0;
   CharMetrics[16].z =     0.0;
   CharMetrics[17].x =  17280.0;
   CharMetrics[17].y =  -2182.0;
   CharMetrics[17].z =     0.0;

   CharMetrics[18].x =   -140.0;
   CharMetrics[18].y =   7600.0;
   CharMetrics[18].z =     0.0;
   CharMetrics[19].x =   -140.0;
   CharMetrics[19].y =  -3040.0;
   CharMetrics[19].z =     0.0;
   EndCharMetrics    =    19;

   sts = Create_menu( WINDOW, 64, 870, FF_menu, dpvlt );

   gadget_ids[0]              = SELECT_FONTS_GAD;
   Icons[SELECT_FONTS_GAD][0] = (char)SELECT_FONTS_SYM;
   Icons[SELECT_FONTS_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[0], 5, 8, 54, 54, UNSELECTED,
                       FF_icons, Icons[SELECT_FONTS_GAD], YELLOW, BLACK);

   gadget_ids[1]         = METRICS_GAD;
   Icons[METRICS_GAD][0] = (char)METRICS_SYM;
   Icons[METRICS_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[1], 5, 62, 54, 54, UNSELECTED,
                       FF_icons, Icons[METRICS_GAD], YELLOW, BLACK);

   gadget_ids[2]             = CREATE_CHAR_GAD;
   Icons[CREATE_CHAR_GAD][0] = (char)CREATE_CHAR_SYM;
   Icons[CREATE_CHAR_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[2], 5, 116, 54, 54, UNSELECTED,
                       FF_icons, Icons[CREATE_CHAR_GAD], YELLOW, BLACK);

   gadget_ids[3]           = EDIT_CHAR_GAD;
   Icons[EDIT_CHAR_GAD][0] = (char)EDIT_CHAR_SYM;
   Icons[EDIT_CHAR_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[3], 5, 170, 54, 54, UNSELECTED,
                       FF_icons, Icons[EDIT_CHAR_GAD], YELLOW, BLACK);

   gadget_ids[4]             = DELETE_CHAR_GAD;
   Icons[DELETE_CHAR_GAD][0] = (char)DELETE_CHAR_SYM;
   Icons[DELETE_CHAR_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[4], 5, 224, 54, 54, UNSELECTED,
                       FF_icons, Icons[DELETE_CHAR_GAD], YELLOW, BLACK);

   gadget_ids[5]          = ADD_CHAR_GAD;
   Icons[ADD_CHAR_GAD][0] = (char)ADD_CHAR_SYM;
   Icons[ADD_CHAR_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[5], 5, 278, 54, 54, UNSELECTED,
                       FF_icons, Icons[ADD_CHAR_GAD], YELLOW, BLACK);

   gadget_ids[6]          = MERGE_CHAR_GAD;
   Icons[ADD_CHAR_GAD][0] = (char)MERGE_CHAR_SYM;
   Icons[ADD_CHAR_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[6], 5, 332, 54, 54, UNSELECTED,
                       FF_icons, Icons[MERGE_CHAR_GAD], YELLOW, BLACK);

   gadget_ids[7]         = ZOOM_IN_GAD;
   Icons[ZOOM_IN_GAD][0] = (char)ZOOM_IN_SYM;
   Icons[ZOOM_IN_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[7], 5, 386, 54, 54, UNSELECTED,
                       FF_icons, Icons[ZOOM_IN_GAD], YELLOW, BLACK);

   gadget_ids[8]          = ZOOM_OUT_GAD;
   Icons[ZOOM_OUT_GAD][0] = (char)ZOOM_OUT_SYM;
   Icons[ZOOM_OUT_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[8], 5, 440, 54, 54, UNSELECTED,
                       FF_icons, Icons[ZOOM_OUT_GAD], YELLOW, BLACK);

   gadget_ids[9]        = CENTER_GAD;
   Icons[CENTER_GAD][0] = (char)CENTER_SYM;
   Icons[CENTER_GAD][1] = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[9], 5, 494, 54, 54, UNSELECTED,
                       FF_icons, Icons[CENTER_GAD], YELLOW, BLACK);

   gadget_ids[10]       = AREA_GAD;
   Icons[AREA_GAD][0]   = (char)AREA_SYM;
   Icons[AREA_GAD][1]   = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[10], 5, 548, 54, 54, UNSELECTED,
                       FF_icons, Icons[AREA_GAD], YELLOW, BLACK);

   Icons[GRID_ON_OFF_GAD][0] = (char)GRID_ON_OFF_SYM;
   Icons[GRID_ON_OFF_GAD][1] = '\0';
   id = GRID_ON_OFF_GAD;
   sts = Create_button( *FF_menu, &id, 5, 602, 54, 54, UNSELECTED, FF_icons,
                        Icons[GRID_ON_OFF_GAD], YELLOW, BLACK );

   gadget_ids[11]      = FACE_GAD;
   Icons[FACE_GAD][0]  = (char)FACE_SYM;
   Icons[FACE_GAD][1]  = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[11], 5, 656, 54, 54, UNSELECTED,
                       FF_icons, Icons[FACE_GAD], YELLOW, BLACK);

   gadget_ids[12]      = SAVE_GAD;
   Icons[SAVE_GAD][0]  = (char)SAVE_SYM;
   Icons[SAVE_GAD][1]  = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[12], 5, 710, 54, 54, UNSELECTED,
                       FF_icons, Icons[SAVE_GAD], L_GREEN, L_GREEN);

   gadget_ids[13]      = QUIT_GAD;
   Icons[QUIT_GAD][0]  = (char)QUIT_SYM;
   Icons[QUIT_GAD][1]  = '\0';
   sts = Create_button(*FF_menu, &gadget_ids[13], 5, 764, 54, 54, UNSELECTED,
                       FF_icons, Icons[QUIT_GAD], D_BROWN, D_BROWN);

   gadget_ids[14]  = -1;

   sts = Associate ( *FF_menu, gadget_ids, 1 );

   Display_menu( *FF_menu, 1119, 0 );
   sts = Inq_menu( *FF_menu, &height, &width, &x, &y, &w_no );

   flushbuffer( *FFw_id );

   sts = GPenter();

   /* create the base window used by fontfactory */
   
   FFmap_vlt();

   FFcreate_view( &FFviews, FFw_id );

end_FFinit_wind:

   return ( status );
}




FFcreate_view( view, FFw_id )

               FFview  **view ;
               int      *FFw_id;
{
               int       status, sts, count, vs_no;
        static int       view_num = 1;
        static short     dim      = 4;
               char      cval[126];
               double    x2, y2, z2;
               FFview   *new_view, *view_ptr, *next_view, *prev_view;

   status = FF_S_SUCCESS;
   Inq_displayed_vs( &vs_no );

   new_view = (FFview *)malloc(sizeof(FFview));
   if(! new_view ) {
      status = FF_MALLOC_ERROR + ERRO;
      goto end_FFcreate_view;
      }

   memset( (char *)new_view, (char)NULL, sizeof(FFview) );

   new_view->View_attributes &= GRID_OFF;
   new_view->W_id             = *FFw_id;
   new_view->V_Xlo            =      0.0;
   new_view->V_Ylo            =      0.0;
   new_view->V_Zlo            =      0.0;
   new_view->V_Xhi            =   1110.0;
   new_view->V_Yhi            =    792.0;
   new_view->V_Zhi            =      0.0;
   new_view->V_trans_x        =    100.0;
   new_view->V_trans_y        =     72.0;
   new_view->W_xy_ext         =  12533.333333333;
   new_view->W_z_ext          =  12533.333333333;
   new_view->Rotate           =      0.0;
   new_view->W_tol            =     13.3333333333;
   new_view->V_tol            =      1.0;
   new_view->W_trans_x        =      0.0;
   new_view->W_trans_y        =      0.0;
   new_view->W_Xlo            =      0.0;
   new_view->W_Ylo            =  -2042.0;
   new_view->W_Zlo            =      0.0;
   new_view->W_Xhi            =   8640.0;
   new_view->W_Yhi            =   6598.0;
   new_view->W_Zhi            =      0.0;
   new_view->W_scale          =      0.075;

   if ( ! *view ) {
       *view = view_ptr       = new_view;
       view_ptr->prev_view    = NULL;
       view_ptr->next_view    = NULL;
       }
     else {
       view_ptr  = *view;
       prev_view = NULL;
       if( view_ptr->next_view )
           next_view = view_ptr->next_view;
         else
           next_view = NULL;

       while( next_view ) {
          if( next_view ) {
             prev_view = view_ptr;
             view_ptr  = next_view;
             if( view_ptr->next_view )
                 next_view = view_ptr->next_view;
               else
                 next_view = NULL;
             view_num++;
             }
          }

       new_view->prev_view    = view_ptr;
       view_ptr->next_view    = new_view;
       new_view->next_view    = NULL;
       view_ptr               = new_view;
       }

   sprintf( cval, "Character view %2d\0", view_num );
   Create_win( vs_no, cval,
               5, 32,
               (int)(view_ptr->V_Xhi +  5.0),
               (int)(view_ptr->V_Yhi + 32.0),
                FFw_id );
   Display_win( *FFw_id );

   GPCreateWin( 1, *FFw_id, &view_ptr->GPwin_id );

   sts = BScalc_TransMatrix( view_ptr->Rotate,  view_ptr->W_scale,
                             view_ptr->W_trans_x, view_ptr->W_trans_y,
                             view_ptr->V_trans_x, view_ptr->V_trans_y,
                             view_ptr->W_Xlo,     view_ptr->W_Ylo,
                             view_ptr->W_Xhi,     view_ptr->W_Yhi,
                             view_ptr->V_matrix );

   MAinvmx( &sts, &dim, view_ptr->V_matrix, view_ptr->W_matrix );

   sts = GPResetMatrix( view_ptr->GPwin_id );
   sts = GPPutMatrix( view_ptr->GPwin_id, view_ptr->V_matrix );

   sts = GPPutViewport(view_ptr->GPwin_id,
                       view_ptr->V_Xlo, view_ptr->V_Ylo, view_ptr->V_Zlo,
                       view_ptr->V_Xhi, view_ptr->V_Yhi, view_ptr->V_Zhi );

/* remove when debuged */
BS_Trans( view_ptr->V_matrix,
           view_ptr->W_Xlo,  view_ptr->W_Ylo,  view_ptr->W_Zlo,
          &view_ptr->V_Xlo, &view_ptr->V_Ylo, &view_ptr->V_Zlo );

   for( count = 0; count <= EndCharMetrics; count++ )
        BS_Trans( view_ptr->V_matrix,
                  CharMetrics[count].x,
                  CharMetrics[count].y,
                  CharMetrics[count].z,
                 &CharMetrics[count].x,
                 &CharMetrics[count].y,
                 &CharMetrics[count].z );

   FFcolor_view( view_ptr, HIGHLIGHT );

   FFdisplay_char_wind( view_ptr );

   FFcur_view = view_ptr;

end_FFcreate_view:

   return( status );
}




FFdisplay_char_wind( view )

        FFview  *view;

{
        int sts, count;

   hidecursor(view->W_id);
   weight( view->W_id, 0 );
   fgcolor( view->W_id, RED + Dac->vlt_offset);
   move( view->W_id, view->Metrics[0], view->Metrics[1] );
   for (count = 2; count < 12; count += 2 )
      draw( view->W_id,  view->Metrics[count], view->Metrics[count + 1] );

   fgcolor( view->W_id, BLACK + Dac->vlt_offset);
   move( view->W_id, view->Metrics[12], view->Metrics[13] );
   draw( view->W_id,  view->Metrics[14], view->Metrics[15] );

   fgcolor( view->W_id, L_GREEN + Dac->vlt_offset);
   for (count = 16; count <= (EndCharMetrics * 2); count += 4 ) {
      move( view->W_id, view->Metrics[count], view->Metrics[count + 1] );
      draw( view->W_id, view->Metrics[count + 2], view->Metrics[count + 3] );
      }

   showcursor(view->W_id);
   flushbuffer(view->W_id);

   return;

}



FFcolor_view( view , bgcolor )

        FFview *view;
        int     bgcolor;
{
   hidecursor( view->W_id );

   UTcreate_label( view->W_id, (int)view->V_Xlo, (int)view->V_Ylo,
                   (int)(view->V_Xhi - view->V_Xlo + 0.5),
                   (int)(view->V_Yhi - view->V_Ylo + 0.5),
                   bgcolor, bgcolor, -1 );

   showcursor( view->W_id );
   flushbuffer( view->W_id );

   return;

}




FFdisplay_char_grid( view, color )

        FFview  *view;
        int      color;
{
        int     sts;
        double  xo, yo, zo, delta, xorg, yorg;

   hidecursor( view->W_id );

   fgcolor(view->W_id, color);

   xo = (int)((view->V_matrix[0] *  0.0)
            + (view->V_matrix[4] *  0.0)
            + (view->V_matrix[8] *  0.0)
            +  view->V_matrix[12] + 0.5);

   yo = (int)((view->V_matrix[0] * 120.0)
            + (view->V_matrix[4] *   0.0)
            + (view->V_matrix[8] *   0.0)
            +  view->V_matrix[12] +  0.5);

   delta = yo - xo;
   if( (int)delta < 0 )
     delta *= -1;
 
   if( (int)delta < 9 )
      goto end_FFdisplay_char_grid;

   yo = (int)((view->V_matrix[0] *  0.0)
            + (view->V_matrix[4] *  0.0)
            + (view->V_matrix[8] *  0.0)
            +  view->V_matrix[12] + 0.5);

   xorg = xo - xo;
   yorg = yo - yo;

   for(yo = yorg; (int)yo <= (int)view->V_Yhi; yo += delta) {
      for(xo = xorg; (int)xo <= (int)view->V_Xhi; xo += delta) {
         move( view->W_id, (int)xo, (int)yo );
         draw( view->W_id, (int)xo, (int)yo );
         }
      }

   showcursor(view->W_id);
   flushbuffer(view->W_id);

end_FFdisplay_char_grid:

   return;
}




FFinit_colors( ff_icons )

	char ff_icons[];

{
           int      status = FF_S_SUCCESS;
           int      sts,
                    count1, count2, count3, val,
                    gadget_descr, gadget_ids[25], id, num_slots,
                    color_map[16];
           short   *CX8to16();
           char    *CX16to8();
           FontId   font_id;

   /* initialize system wide variables */
   Load_symbol_file( ff_icons, &FF_icons );
   TXsetTypefaceFile( CX8to16(GADGET_FONT), &font_id, PUBLISHER_CHARS,
                      (double)12, (double)0, (double)1, (double)0, NULL );
   TXsetTypefaceFile( CX8to16(GADGET_FONT), &font_id, PUBLISHER_CHARS,
                      (double)18, (double)0, (double)1, (double)0, NULL );

   return ( status );

}

/*
ord[0].x =     0.0;
ord[0].y =     0.0;
ord[0].z =     0.0;
ord[1].x =     0.0;
ord[1].y = -2042.0;
ord[1].z =     0.0;
ord[2].x =  8640.0;
ord[2].y = -2042.0;
ord[2].z =     0.0;
ord[3].x =  8640.0;
ord[3].y =  6598.0;
ord[3].z =     0.0;
ord[4].x =     0.0;
ord[4].y =  6598.0;
ord[4].z =     0.0;
ord[5].x =     0.0;
ord[5].y =     0.0;
ord[5].z =     0.0;
ord[6].x =     0.0;
ord[6].y =     0.0;
ord[6].z =     0.0;
ord[7].x =     0.0;
ord[7].y =     0.0;
ord[7].z =     0.0;
sts = GPLinestr3D( FFviews->GPbuff_id, 8 , &ord[0] );
int_ptr1  = (int *)buffer;
buff_ptr1 = buff_ptr2 = buff_ptr3 = buffer;
buff_ptr1++; buff_ptr2 += 2; buff_ptr3 += 3;
printf("The tab is: %d\n", *int_ptr1);
int_ptr1++;
printf("The number of quadwords is: %d\n", *int_ptr1);
for (count1 = 0;
     count1 < 7;
     count1++, buff_ptr1 += 3, buff_ptr2 += 3, buff_ptr3 += 3) {
   printf("%c%1d: %.3lf", 'x', count1, *buff_ptr1);
   printf(" %c%1d: %.3lf", 'y', count1, *buff_ptr2);
   printf(" %c%1d: %.3lf", 'z', count1, *buff_ptr3);
   printf("   %c%1d: %.3lf", 'x', count1, ((FFviews->V_matrix[0] * ord[count1].x)
                                         + (FFviews->V_matrix[4] * ord[count1].y)
                                         + (FFviews->V_matrix[8] * ord[count1].z)
                                         +  FFviews->V_matrix[12]));
   printf(" %c%1d: %.3lf", 'y', count1, ((FFviews->V_matrix[1] * ord[count1].x)
                                       + (FFviews->V_matrix[5] * ord[count1].y)
                                       + (FFviews->V_matrix[9] * ord[count1].z)
                                       +  FFviews->V_matrix[13]));
   printf(" %c%1d: %.3lf%c", 'z', count1,((FFviews->V_matrix[2] * ord[count1].x)
                                        + (FFviews->V_matrix[6] * ord[count1].y)
                                        + (FFviews->V_matrix[10] * ord[count1].z)
                                        +  FFviews->V_matrix[14]), '\n');
   }
*/



/*
int_ptr1 = (int *)buffer;
*int_ptr1 = 0;
int_ptr1++;
*int_ptr1 = 0;
for (buff_ptr1 = buffer + 1,  count1 = 0;
     count1 < 50; count1++)
   buff_ptr1 = 0.0;

ord[0].x =   108.0;
ord[0].y =   570.0;
ord[0].z =     0.0;
ord[1].x =   108.0;
ord[1].y =   723.15;
ord[1].z =     0.0;
ord[2].x =   756.0;
ord[2].y =   723.15;
ord[2].z =     0.0;
ord[3].x =   756.0;
ord[3].y =    75.15;
ord[3].z =     0.0;
ord[4].x =   108.0;
ord[4].y =    75.15;
ord[4].z =     0.0;
ord[5].x =   108.0;
ord[5].y =   570.0;
ord[5].z =     0.0;
ord[6].x =     0.0;
ord[6].y =     0.0;
ord[6].z =     0.0;
ord[7].x =     0.0;
ord[7].y =     0.0;
ord[7].z =     0.0;

sts = GPLinestr3D( FFviews->GPbuff_id, 8 , &ord[0] );

int_ptr1  = (int *)buffer;
buff_ptr1 = buff_ptr2 = buffer;
buff_ptr1++; buff_ptr2 += 2; buff_ptr3 += 3;
printf("The tab is: %d\n", *int_ptr1);
int_ptr1++;
printf("The number of quadwords is: %d\n", *int_ptr1);
for (count1 = 0;
     count1 < 7;
     count1++, buff_ptr1 += 3, buff_ptr2 += 3, buff_ptr3 += 3) {
   printf("%c%1d: %.3lf", 'x', count1, *buff_ptr1);
   printf(" %c%1d: %.3lf", 'y', count1, *buff_ptr2);
   printf(" %c%1d: %.3lf", 'z', count1, *buff_ptr3);
   printf("   %c%1d: %.3lf", 'x', count1,
                                      ((FFviews->W_matrix[0] * ord[count1].x)
                                     + (FFviews->W_matrix[4] * ord[count1].y)
                                     + (FFviews->W_matrix[8] * ord[count1].z)
                                     +  FFviews->W_matrix[12]));
   printf(" %c%1d: %.3lf", 'y', count1,
                                      ((FFviews->W_matrix[1] * ord[count1].x)
                                     + (FFviews->W_matrix[5] * ord[count1].y)
                                     + (FFviews->W_matrix[9] * ord[count1].z)
                                     +  FFviews->W_matrix[13]));
   printf(" %c%1d: %.3lf%c", 'z', count1,
                                     ((FFviews->W_matrix[2] * ord[count1].x)
                                    + (FFviews->W_matrix[6] * ord[count1].y)
                                    + (FFviews->W_matrix[10] * ord[count1].z)
                                    +  FFviews->W_matrix[14]), '\n');
   }
*/
