/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:38:41 $
$Locker:  $
*/

class implementation IGEcolor2;
#include <stdio.h>
#include <string.h>
#include "wl.h"

#include "exmacros.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "msdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "cm.h"

#define IGENOT_ENOUGH_MEM   2
%safe

/* add when a ANSI prototype naming convention is agreed upon */
/*
#include "DPcolors.h"     -> DPchek_clr_tbl, DPret_clr_tab
#include "IGEconclrtab.h" -> DPset_load_vlt_ptr
*/
/* NOTE: THE LAST 2 BITS ARE NOT USED ONLY 8 BITS */
/*EXTRA     RED           GREEN         BLUE       */
/*  00  00 0000 0000   0000 0000 00   00 0000 0000 */
/*1.O = 1111 1111 11*/
/*0.75= 1011 1111 11*/
/*.625= 1001 1111 11*/
/*0.5 = 0111 1111 11*/
/*0.25= 0011 1111 11*/
/*0.0 = 0000 0000 00*/
static IGRint colors[DEFAULT_NUM_BG_LOG_HL] = 
/* here is the color_table.a file or new file for 2.4 for ramp shading */
{
   0, 0XFFC00, 0X3FF00000, 0X3FF, 0X3FFFFC00, /* 0 - 4 */
   0XFFFFF, 0X3FF003FF, 0X3FFFFFFF, 0X3FF80800, 0X80BFF, /* 5 - 9 */
   0X1FF003FF, 0X1FFFFC00, 0XFFDFF, 0X3FF00200, 0X1FFFFDFF, /* 10 - 14 */
   0X3FF7FDFF, 0X2007FFFF, 0X3FFFFDFF, 0X200FFFFF, 0X3FF803FF, /* 15 - 19 */
   0X1FF7FDFF, 0X7FC00, 0X1FF00000, 0X1FF, 0X1FF7FC00, /* 20 - 24 */
   0X7FDFF, 0X1FF001FF, 0X3FFFFEFF, 0X3FFFFCFF, 0X2FFFFFFF, /* 25 - 29 */
   0X2FFFFEFF, 0X2FFFFDFF, 0X2FFFFCFF, 0X2FFFFC00, 0X1FFFFEFF, /* 30 - 34 */
   0X1FFFFCFF, 0XFFFFFFF, 0XFFFFEFF, 0XFFFFDFF, 0XFFFFCFF, /* 35 - 39 */
   0XFFFFC00, 0XFFEFF, 0XFFCFF, 0X3FFBFFFF, 0X3FFBFEFF, /* 40 - 44 */
   0X3FFBFDFF, 0X3FFBFCFF, 0X3FFBFC00, 0X2FFBFFFF, 0X2FFBFEFF, /* 45 - 49 */
   0X2FFBFDFF, 0X2FFBFCFF, 0X2FFBFC00, 0X1FFBFFFF, 0X1FFBFEFF, /* 50 - 54 */
   0X1FFBFDFF, 0X1FFBFCFF, 0X1FFBFC00, 0XFFBFFFF, 0XFFBFEFF, /* 55 - 59 */
   0XFFBFDFF, 0XFFBFCFF, 0XFFBFC00, 0XBFFFF, 0XBFEFF, /* 60 - 64 */
   0XBFDFF, 0XBFCFF, 0XBFC00, 0X3FF7FEFF, 0X3FF7FCFF, /* 65 - 69 */
   0X2FF7FFFF, 0X2FF7FEFF, 0X2FF7FDFF, 0X2FF7FCFF, 0X2FF7FC00, /* 70 - 74 */
   0X1FF7FEFF, 0X1FF7FCFF, 0XFF803FF, 0XFF7FEFF, 0XFF7FDFF, /* 75 - 79 */
   0XFF7FCFF, 0XFF7FC00, 0X7FEFF, 0X7FCFF, 0X3FF3FFFF, /* 80 - 84 */
   0X3FF3FEFF, 0X3FF3FDFF, 0X3FF3FCFF, 0X3FF3FC00, 0X2FF3FFFF, /* 85 - 89 */
   0X2FF3FEFF, 0X2FF3FDFF, 0X2FF3FCFF, 0X2FF3FC00, 0X1FF3FFFF, /* 90 - 94 */
   0X1FF3FEFF, 0X1FF3FDFF, 0X1FF3FCFF, 0X1FF3FC00, 0XFF3FFFF, /* 95 - 99 */
   0XFF3FEFF, 0XFF3FDFF, 0X100400FF, 0XFF40000, 0X3FFFF, /* 100 - 104 */
   0X3FEFF, 0X3FDFF, 0X3FCFF, 0X3FC00, 0X3FF002FF, /* 105 - 109 */
   0X3FF000FF, 0X2FF003FF, 0X2FF002FF, 0X2FF001FF, 0X2FF000FF, /* 110 - 114 */
   0X2FF00000, 0X1FF002FF, 0X1FF000FF, 0XFF003FF, 0XFF002FF, /* 115 - 119 */
   0XFF001FF, 0XFF000FF, 0XFF00000, 0X2FF, 0XFF, /* 120 - 124 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 125 - 129 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 130 - 134 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 135 - 139 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 140 - 144 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 145 - 149 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 150 - 154 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 155 - 159 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 160 - 164 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 165 - 169 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 170 - 174 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 175 - 179 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 180 - 184 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 185 - 189 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 190 - 194 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 195 - 199 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 200 - 204 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 205 - 209 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 210 - 214 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 215 - 219 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 220 - 224 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 225 - 229 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 230 - 234 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 235 - 239 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 240 - 244 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 245 - 249 */
   0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, 0X3FFFFFFF, /* 250 - 254 */
   0X3FFFFFFF /* 255 */
};

static  struct IGEcol_names   names[7] = 
{ {"green",   0},
  {"red",     1},
  {"blue",    2},
  {"yellow",  3},
  {"cyan",    4},
  {"magenta", 5},
  {"white",   6} };

/* here is the NT color_table values */
#if defined (COLOR_TABLEB)
static IGRint colors[DEFAULT_NUM_BG_LOG_HL] = 
{0x00000000, 
 0x3FF7FDFF, 0x3FFFFDFF, 0x1FFFFDFF, 0x000FFDFF, 0x1FFFFFFF, /* 1- 5*/
 0x0007FFFF, 0x3FF7FEFF, 0x3FF7FFFF, 0x3FF00000, 0x3FFFFC00, /* 6-10*/
 0x1FFFFC00, 0x000FFCFF, 0x000FFFFF, 0x0FF7FDFF, 0x1FF7FDFF, /*11-15*/
 0x3FF003FF, 0x1FF3FCFF, 0x3FF7FCFF, 0x000FFC00, 0x0007FDFF, /*16-20*/ 
 0x0003FDFF, 0x1FF7FFFF, 0x1FF000FF, 0x3FF001FF, 0x1FF00000, /*21-25*/
 0x3FF7FC00, 0x0007FC00, 0x0007FCFF, 0x000003FF, 0x0000027F, /*26-30*/ 
 0x1FF001FF, 0x1FF003FF, 0x0FF00000, 0x1FF3FC00, 0x0003FC00, /*31-35*/
 0x0003FCFF, 0x000001FF, 0x000000FF, 0x0FF000FF, 0x0FF001FF, /*36-40*/
 0x00000000, 0x1FF7FC00, 0x1FF7FCFF, 0x1FF7FDFF, 0x0FF7FDFF, /*41-45*/
 0x2FFBFEFF, 0x3FFFFEFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*46-50*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*51-55*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*56-60*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*61-65*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*66-70*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*71-75*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*76-80*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*81-85*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*86-90*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*91-95*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*96-100*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*101-105*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*106-110*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*111-115*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*116-120*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*121-125*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*126-130*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*131-135*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*136-140*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*141-145*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*146-150*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*151-155*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*156-160*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*161-165*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*166-170*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*171-175*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*176-180*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*181-185*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*186-190*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*191-195*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*196-200*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*201-205*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*206-210*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*211-215*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*216-220*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*221-225*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*226-230*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*231-235*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*236-240*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*241-245*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, /*246-250*/
 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF, 0x3FFFFFFF  /*251-255*/
};

static  struct IGEcol_names   names[7] = 
{ {"red",    8},
  {"yellow",    9},
  {"cyan",   12},
  {"magenta",   15},
  {"green",   18},
  {"blue",   28},
  {"white",   47} };
#endif
 
%endsafe
extern OMuword OM_Gw_current_OS;

/******************* super_construct ******************************/
/*   These values are only used if you remove $EMS/config/seed_file*/
/*and $GRNUC/config/color_table.  It is based on 10 bits and the least*/
/*significant 2 bits are not used. */


method super_construct()
{
/*
NAME
   IGEcolor2.super_construct
DESCRIPTION
   this method constructs the object if there isn't one
PARAMETERS

RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint   i;
   IGRint   file_type = IGE_COLORS;
   IGRint   status = TRUE;
   IGRint   bg_color;
   IGRint   fg_color;
   IGRint   hl_color;
   IGRshort no_clrs;
   IGRshort no_names;
   IGRint   logical_colors[256];
   IGRint   *clrs_ptr;
   IGRint   col_malloced = FALSE;
   IGRint   nam_malloced = FALSE;
   IGRint   msg;
   struct IGEcol_names  logical_names[256],*name_ptr;
   GRspacenum   modos;
   GRobjid      modid;
   struct IGEcolor2_data *IGEcolor2_data_ptr;

   if (DPchek_clr_tbl("color_table"))
   {
      /* file color_table exists (that is all we know now) */
      /* load the color table in $PRODUCT/config/color_table if IGEcolor2 object didn't exist */
      no_clrs = 256;
      no_names = 256;
      clrs_ptr = logical_colors;
      name_ptr = logical_names;
      
      status = DPret_clr_tbl(&msg,"color_table",&file_type,&bg_color,&fg_color,
         &hl_color,&no_clrs,logical_colors,&no_names,logical_names);

      if (!( 1 & status))
      {
#ifdef DEBUG
         om$report_error(sts = status);
#endif
         goto load_default;
      }

      if (msg == IGENOT_ENOUGH_MEM)
      {
         /* color_table was not loaded because of arrays too small */
         if (no_clrs > 256)
         {
            if(!(clrs_ptr = (IGRint *) om$malloc(size=no_clrs * sizeof(IGRint))))
            {
#ifdef DEBUG
               printf("Error in IGEcolor2.super_construct .. Can't allocate memory\n");
#endif
               status = FALSE;
               goto load_default;
            }
            col_malloced = TRUE;
         }
         else
         {
            clrs_ptr = logical_colors;
         }
            
         if (no_names > 256)
         {
            if(!(name_ptr = (struct IGEcol_names *) om$malloc(size=no_names * sizeof(struct IGEcol_names))))
            {
#ifdef DEBUG
               printf("\n Error in IGEcolor2.super_construct .. Can't allocate memory");
#endif
               status = FALSE;
               goto load_default;
            }
            nam_malloced = TRUE;
         }
         else
         {
            name_ptr = logical_names;
         }

         status = DPret_clr_tbl(&msg,"color_table",&file_type,&bg_color,&fg_color,&hl_color,
                      &no_clrs,clrs_ptr,&no_names,name_ptr);

         if (!(status & 1) || (msg == MSFAIL))
	 {
            /* the file is bad.  construct default one. */
            status = FALSE;
            goto load_default;
         }
      }

      ex$get_cur_mod( id = &modid, osnum = &modos);

      me->num_bg_log_hl_colors = DEFAULT_NUM_BG_LOG_HL;
      status = om$send ( msg = message IGEcolor2.change_clr_tbl(0,1,(void *) &bg_color,
                                 PACKED_COLORS|IGE_CHANGE_BACKGROUND),
               senderid = NULL_OBJID,
               targetid = my_id,
               targetos = modos);

      if (!( 1 & status))
      {
#ifdef DEBUG
         om$report_error(sts = status);
#endif
         goto load_default;
      }

      status = om$send ( msg = message IGEcolor2.change_clr_tbl(0,1,(void *) &hl_color,
                                 PACKED_COLORS|IGE_CHANGE_HIGHLIGHT),
               senderid = NULL_OBJID,
               targetid = my_id,
               targetos = modos);

      if (!( 1 & status))
      {
#ifdef DEBUG
         om$report_error(sts = status);
#endif
         goto load_default;
      }

      status = om$send ( msg = message IGEcolor2.change_clr_tbl(0,no_clrs,(void *) clrs_ptr,
                                 PACKED_COLORS),
               senderid = NULL_OBJID,
               targetid = my_id,
               targetos = modos);


      if (!( 1 & status))
      {
#ifdef DEBUG
         om$report_error(sts = status);
#endif
         goto load_default;
      }

      me->num_names = 7;
      status = om$send ( msg = message IGEcolor2.change_clr_nam(no_names, name_ptr, 0),
            senderid = NULL_OBJID,
            targetid = my_id,
            targetos = modos);

      if (!( 1 & status))
      {
#ifdef DEBUG
         om$report_error(sts = status);
#endif
         goto load_default;
      }

      for (i = 0; i < 3; i++)
      {
         me->gamma[i] = 2.2;
      }
   
      me->tolerance_pct[0] = 0.01;

      om$vla_set_dimension( varray =  me->data, 
                            size = sizeof( struct IGEcolor2_data ) );
      IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;
      IGEcolor2_data_ptr->version = 1;
      IGEcolor2_data_ptr->user_cube_size = IGE_USER_CUBE_SIZE_DEFAULT;
      IGEcolor2_data_ptr->num_ramp_colors = 10;

      return(status);
   }

load_default:
   status = OM_S_SUCCESS;

   /* no valid $PRODUCT/config/color_table file just give default colors and shades */
   me->num_bg_log_hl_colors = DEFAULT_NUM_BG_LOG_HL;
   for (i=0;i<me->num_bg_log_hl_colors;i++)
   {
      me->bg_log_hl_colors[i] = colors[i];
   }

   me->num_names = 7;
   for (i=0;i<me->num_names;i++)
   {
      strcpy(me->names[i].name,names[i].name);
      me->names[i].index = names[i].index;
   }

   for (i=0;i<3;i++)
   {
      me->gamma[i]=2.2;
   }

   me->tolerance_pct[0]=0.01;

   om$vla_set_dimension( varray =  me->data, 
                         size = sizeof( struct IGEcolor2_data ) );
   IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;
   IGEcolor2_data_ptr->version = 1;
   IGEcolor2_data_ptr->user_cube_size = IGE_USER_CUBE_SIZE_DEFAULT;
   IGEcolor2_data_ptr->num_ramp_colors = 10;

   return(status);
}

/************************ wake_up ******************************/

method  wake_up()
{
/*
NAME
   IGEcolor2.wake_up
DESCRIPTION
   this method wakes up the IGEcolor2 object
PARAMETERS

RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint   sts = 1;
   int num_contexts, i;
   struct CMctx_mgr *cm_contexts;
   int num_win_mgr, num_ingr_res;
   struct WLcmap_entry *WLwin_mgr=(struct WLcmap_entry *)NULL;
   struct WLcmap_entry *WLingr_res=(struct WLcmap_entry *)NULL;
   struct IGEcolor2_data *IGEcolor2_data_ptr;
   int data_instance_size = 0, data_struct_size = 0;
   
   data_instance_size = om$dimension_of( varray = me->data );
   data_struct_size = sizeof( struct IGEcolor2_data );
   if (data_instance_size > sizeof( int ) )
   {
      /* data has atleast version in there, compare and change if necessary */
      IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;
      if (IGEcolor2_data_ptr->version == 1)
      {
         /* this is the current version do nothing */
      }
   }
   else
   {
      /* data is empty */
      om$vla_set_dimension( varray =  me->data, 
                                  size = data_struct_size,
                                  move_data = FALSE );
      IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;
      IGEcolor2_data_ptr->version = 1;
      IGEcolor2_data_ptr->user_cube_size = IGE_USER_CUBE_SIZE_DEFAULT;
      IGEcolor2_data_ptr->num_ramp_colors = 10;
   }

   if (! ex$is_invis(mod_osnum = OM_Gw_current_OS) && !ex$is_temp_wakeup())
   {
      if ( ex$is_interactive() )
      {
         /* the function that will do compensation */
         IGEset_gamma_compensate_ptr( IGEcolor_compensate ); 
         CMget_contexts( &cm_contexts, &num_contexts );
         for (i = 0; i < num_contexts; i++)
         {
            /* for all contexts with NULL_OBJID take over them */
            if (cm_contexts[i].color_objid == NULL_OBJID)
            {
               WLget_wm_colors(cm_contexts[i].context_no, &num_win_mgr, &WLwin_mgr, &num_ingr_res, &WLingr_res);  
               if (WLwin_mgr)
               {
                  free(WLwin_mgr);
               }
               if (WLingr_res)
               {
                  free(WLingr_res);
               }

               if (IGEadd_context( cm_contexts[i].context_no, num_win_mgr, num_ingr_res, me->num_bg_log_hl_colors ))
               {   
                  /* UNsuccessfuly added context (already had internal data structures for this context) */
                  /* context info already there (and resized if needed) */
                  /* configure all of the color tables taken over */
                  CMchange_context_info(cm_contexts[i].context_no,my_id,
                     (int (*)()) NULL,(int (*)()) NULL,(int (*)()) NULL);
                  sts = om$send( msg = message IGEcolor2.configure_table(cm_contexts[i].context_no),
                     targetid = my_id);
               }
               else
               {
                  /* Successfully added the context to internal data structures */
                  /* this will initialize the color table.  This is the case for the contexts
                     created and then a retrieve of a new file these data structures have been
                     deleted.  Thus a context is left up, but should be initialized for new IGEcolor2 
                     object.  The CMinitialize_context calls cmap_init like on first retrieval.  
                     Then we call IGEadd_context again to set number of colors correctly (set to 
                     default when CMinitialize_context called without obj_id set.)  Set the objid and 
                     send a configure table.  We can't just call CMinitialize_context with the objid
                     already set because this is the wake_up method and when macros are called in 
                     cmap_init it adds another IGEcolor2 object. */
                  CMinitialize_context( cm_contexts[i].context_no );
                  IGEadd_context( cm_contexts[i].context_no, num_win_mgr, num_ingr_res, me->num_bg_log_hl_colors );
                  CMchange_context_info(cm_contexts[i].context_no,my_id,
                     (int (*)()) NULL,(int (*)()) NULL,(int (*)()) NULL);
                  sts = om$send( msg = message IGEcolor2.configure_table(cm_contexts[i].context_no),
                     targetid = my_id);
               }
            }
         }
         if (cm_contexts)
         {
            free( cm_contexts );
         }
      }
   }
   IGEset_color_id(my_id);

   return(sts);
}

/******************* app_con ******************************/

method app_con(IGRint type; GRobjid appcolor_objid; GRspacenum appcolor_osnum)
{
/*
NAME
   IGEcolor2.app_con
DESCRIPTION
   this method connects to the applications object
PARAMETERS
   type (in) - the type of object
   appcolor_objid (in) - the application object id
   appcolor_osnum (in) - the object space number
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint      status;
   OM_S_CHANSELECT   to_chandef;
   OM_S_CHANSELECT   fr_chandef;

   switch (type)
   {
      case IGECOLAPP:
         fr_chandef.type = OM_e_addr;
         fr_chandef.u_sel.addr = &ME.IGEcolor2->to_APPcolor2;
         to_chandef.type = OM_e_name;
         to_chandef.u_sel.name = "APPcolor2.to_IGEcolor2";
         break;
      case IGECOLNOT:
         /* IGEcolsup */
         fr_chandef.type = OM_e_addr;
         fr_chandef.u_sel.addr = &ME.IGEcolor2->notify;
         to_chandef.type = OM_e_name;
         to_chandef.u_sel.name = "IGEcolsup.listener";
         break;
      case IGEAPPUSR:
         fr_chandef.type = OM_e_addr;
         fr_chandef.u_sel.addr = &ME.IGEcolor2->to_IGEuserramp;
         to_chandef.type = OM_e_name;
         to_chandef.u_sel.name = "IGEuserramp.to_IGEcolor2";
         break;
   }

   status = om$send(msg = message Root.connect(to_chandef,NULL,my_id,
                   OM_Gw_current_OS,fr_chandef,
                   OM_K_MAXINT),
          targetid = appcolor_objid,
          targetos = appcolor_osnum);

   if (!(1 & status)) 
   {
#ifdef DEBUG_CL
      om$report_error(sts = status);
#endif
      goto wrapup;
   }

wrapup:
   return(status);
}

method   set_inq_color_params(
   IGRint inq0_set1;
   IGRdouble *tolerance_pct;
   IGRdouble *gamma_correction;
   IGRint    *num_ramp_colors;
   IGRint    *user_cube_size)
{
/*
NAME
   IGEcolor2.set_inq_color_params
DESCRIPTION
   this method sets or inquires the color parameters.  
PARAMETERS
   tolerance_pct (in/out) - the percentage of distance in the rgb
      cube to constitute a match with a color. default 0.01
   gamma_correction (in/out) - the gamma correction values for the
      3 guns r g b.  2.2 for on 1.0 for off 
RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   IGRint status = TRUE;
   IGRlong msg;
   IGRint calibration_flag;
   struct IGEcolor2_data *IGEcolor2_data_ptr;
   IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;

   if (inq0_set1)
   {
      /* setting the values */
      if (tolerance_pct)
      {
         me->tolerance_pct[0] = *tolerance_pct;
      }
      if (gamma_correction)
      {
         if (gamma_correction[0] != 1.0 || gamma_correction[1] != 1.0 || gamma_correction[2] != 1.0 )
         {
            /* set the ems data to calibration on */
            calibration_flag = TRUE;
            GRsetinqcolcal( &msg, 1, &calibration_flag );
         }
         else
         {
            /* set the ems data to calibration off */
            calibration_flag = FALSE;
            GRsetinqcolcal( &msg, 1, &calibration_flag );
         }
         me->gamma[0] = gamma_correction[0];
         me->gamma[1] = gamma_correction[1];
         me->gamma[2] = gamma_correction[2];
      }
      if (user_cube_size)
      {
         IGEcolor2_data_ptr->user_cube_size = *user_cube_size; 
      }
      if (num_ramp_colors)
      {
         IGEcolor2_data_ptr->num_ramp_colors = *num_ramp_colors; 
      }
      goto wrapup;
   }
   else
   {
      /* inquiring the values */
      if (tolerance_pct)
      {
         *tolerance_pct = me->tolerance_pct[0];
      }
      if (gamma_correction)
      {
         gamma_correction[0] = me->gamma[0];
         gamma_correction[1] = me->gamma[1];
         gamma_correction[2] = me->gamma[2];
      }
      if (user_cube_size)
      {
         *user_cube_size = IGEcolor2_data_ptr->user_cube_size; 
      }
      if (num_ramp_colors)
      {
         *num_ramp_colors = IGEcolor2_data_ptr->num_ramp_colors; 
      }
      goto wrapup;
   }

wrapup:
   return(status);
}

/********************* debug ******************************/

method debug()
/*
NAME
   IGEcolor2.debug
DESCRIPTION
   this method Prints out instance data
PARAMETERS

RETURN VALUES
   TRUE = SUCCESS
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{
   int i=0;
   struct IGEcolor2_data *IGEcolor2_data_ptr;
   IGEcolor2_data_ptr = (struct IGEcolor2_data *) me->data;

   fprintf( stderr, "IGEcolor2 INSTANCE DATA\n\n" );
   fprintf( stderr, "   BACKGROUND COLOR:    %x \n",  
      me->bg_log_hl_colors[0]);
   fprintf( stderr, "   HIGHLIGHT COLOR:    %x\n", 
      me->bg_log_hl_colors[me->num_bg_log_hl_colors-1]);
   fprintf( stderr, "   NUMBER OF BG+LOGICAL+HL COLORS:    %d\n", 
      me->num_bg_log_hl_colors);
   fprintf( stderr, "   NUMBER OF NAMES:    %d\n", me->num_names);
   fprintf( stderr, "   NUMBER RAMP COLORS: %d\n", IGEcolor2_data_ptr->num_ramp_colors);
   fprintf( stderr, "   USER COLOR CUBE SZ: %#X\n", IGEcolor2_data_ptr->user_cube_size);
   fprintf( stderr, "   NUMBER OF NAMES:    %d\n", me->num_names);
   fprintf( stderr, "   TOLERANCE_PCT:    %lf\n", me->tolerance_pct[0]);
   fprintf( stderr, "   GAMMA:    %lf %lf %lf\n", me->gamma[0], 
      me->gamma[1], me->gamma[2]);
   fprintf( stderr, "\n");

   fprintf( stderr,   "   LOGICAL      log rgb\n");
   for (i=1; i<me->num_bg_log_hl_colors-1; i++)
     fprintf( stderr, "         %3d %13X\n",
        i, me->bg_log_hl_colors[i]);
   fprintf( stderr, "\n");

   for (i=0; i<me->num_names; i++)
       fprintf( stderr, "               %s   %d\n", 
           me->names[i].name, me->names[i].index );

   return( OM_S_SUCCESS );

}  /* debug */


end implementation IGEcolor2;
