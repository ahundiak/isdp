/*
$Log: FFinitVLT.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:13  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:26  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:28  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:50:32  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:01  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:41:46  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <sdl.h>
#include <tools.h>
#include "FFdac.h"
#include "FFdef.h"



   struct dac_vars *Dac    = NULL;

   static int FF_color_table[] = { 
           BACKGROUND, BLUE,    L_GREEN, L_BLUE, RED,     MAGENTA, YELLOW, WHITE, 
           HIGHLIGHT,  M1_GREY, M2_GREY, D_GREY, D_GREEN, D_BROWN, ORANGE, BLACK,
           -1 };



   static unsigned short Default_vlt[] = {
                                     BACKGROUND,     0,     0,     0,
                                     BLUE      ,     0,     0, 65535,
                                     L_GREEN   ,     0, 65535,     0,
                                     L_BLUE    ,     0, 65535, 65535,
                                     RED       , 65535,     0,     0,
                                     MAGENTA   , 65535,     0, 65535,
                                     YELLOW    , 65535, 65535,     0,
                                     WHITE     , 65535, 65535, 65535,
                                     HIGHLIGHT , 57344, 57344, 53248,
                                     M1_GREY   , 49152, 49152, 49152,
                                     M2_GREY   , 45056, 45056, 45056,
                                     D_GREY    , 36864, 36864, 36864,
                                     D_GREEN   ,     0, 36864,     0,
                                     D_BROWN   , 36864,     0,     0,
                                     ORANGE    , 65535, 32768,  8192,
                                     FORGROUND , 65535, 65535, 65535,
                                     16,             0,     0,     0,
                                     17,             0,     0, 65535,
                                     18,             0, 65535,     0,
                                     19,             0, 65535, 65535,
                                     20,         65535,     0,     0,
                                     21,         65535,     0, 65535,
                                     22,         65535, 65535,     0,
                                     23,         65535, 65535, 65535,
                                     24,         57344, 57344, 53248,
                                     25,         49152, 49152, 49152,
                                     26,         45056, 45056, 45056,
                                     27,         36864, 36864, 36864,
                                     28,             0, 36864,     0,
                                     29,         36864,     0,     0,
                                     30,         65535, 32768,  8192,
                                     31,         65535, 65535, 65535 };

/******************************* FFmap_vlt routine ****************************/
/* Font Factory uses seven colors: an off-white, medium-grey, black, yellow,  */
/* light-grey, dark-grey, and white                                           */
/* Font Factory uses the color table /usr/ip32/resrc/vlt/fix14.vlt as a model */
/* for color indices.  If a color table is specified in FFmap_vlt that has    */
/* different colors in these slots, (but has the colors mentioned above in    */
/* other slots),  Map_vlt can be called to map these other slots to the ones  */
/* that Font Factory will be using                                            */

FFmap_vlt()

{
                 int        count,
                            status,
                            vs_no,
                            offset;
                 int        color = 0;
                 FILE      *f_ptr = NULL;
                 FILE      *fopen();
        struct   vlt_entry  entry[COLORTBLSIZE];
        struct   scr_info   info[MAX_SCREENS];

   Dac    = (struct dac_vars *)malloc( sizeof (struct dac_vars) );

   Inq_screen_info( info );
   Inq_displayed_vs( &vs_no );
   Dac->vlt_slots = info[vs_no].vsi_vlt_size;
   Dac->dac_size  = info[vs_no].vsi_DAC_size;
   if( Dac->vlt_slots <= 16 )
       Dac->vlt_offset = 0;
     else if( !((Dac->vlt_slots <= 16) || (Dac->vlt_slots > 32)) )
       Dac->vlt_offset = 16;
     else
       Dac->vlt_offset = 32;

   Dac->all_planes = info[vs_no].vsi_num_planes;
   Dac->hilite     = 0;
   Dac->no_hilite  = 0;
   Dac->shades     = 0;

   /* load bottom half of color table */
   /* shift color value into upper 1 byte(ROP), 2 bytes(IFB) */
   for( count = 0; (count + Dac->vlt_offset) < Dac->vlt_slots; count++ )
      FF_color_table[count] += Dac->vlt_offset;

   Readvlt( vs_no, Dac->vlt, Dac->vlt_slots, 0);

   for (  count = 0;
          (count < Dac->vlt_slots) && (count < 32);
          count++, color += 4 ) {
      if( info[vs_no].vsi_screen_num == -1)
         break;

      if( !(   (Default_vlt[color] == 0)
            || (Default_vlt[color] == Dac->vlt_slots - 1)) ) {
          Dac->vlt[Default_vlt[color]].v_slot  = Default_vlt[color];
          Dac->vlt[Default_vlt[color]].v_red   = Default_vlt[color + 1];
          Dac->vlt[Default_vlt[color]].v_green = Default_vlt[color + 2];
          Dac->vlt[Default_vlt[color]].v_blue  = Default_vlt[color + 3];
          }
      }

   /* need to load our color table into all defined screens */
   for( vs_no = 0; vs_no < MAX_SCREENS; vs_no++) {
      if( info[vs_no].vsi_screen_num == -1)
         break;

      status = Loadvlt( vs_no, Dac->vlt, Dac->vlt_slots );
      if( status != 0 )
         goto CLOSE;
      }

   FF_color_table[BACKGROUND] += Dac->vlt_offset;
   FF_color_table[BLUE]       += Dac->vlt_offset;
   FF_color_table[L_GREEN]    += Dac->vlt_offset;
   FF_color_table[L_BLUE]     += Dac->vlt_offset;
   FF_color_table[RED]        += Dac->vlt_offset;
   FF_color_table[MAGENTA]    += Dac->vlt_offset;
   FF_color_table[YELLOW]     += Dac->vlt_offset;
   FF_color_table[WHITE]      += Dac->vlt_offset;
   FF_color_table[HIGHLIGHT]  += Dac->vlt_offset;
   FF_color_table[M1_GREY]    += Dac->vlt_offset;
   FF_color_table[M2_GREY]    += Dac->vlt_offset;
   FF_color_table[D_GREY]     += Dac->vlt_offset;
   FF_color_table[D_GREEN]    += Dac->vlt_offset;
   FF_color_table[D_BROWN]    += Dac->vlt_offset;
   FF_color_table[ORANGE]     += Dac->vlt_offset;
   FF_color_table[BLACK]      += Dac->vlt_offset;

CLOSE:

   return;

}

