/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:38:41 $
$Locker:  $
*/
class implementation IGEcolor2;

#include "igetypedef.h"
#include "exmacros.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "wl.h"
#include "igecolmacros.h"
#include "FI.h"

%safe
extern OM_S_OBJID   NULL_OBJID;
static GRobjid IGEcolor2_id = 0;
%endsafe

IGRint   IGEcnctclrtab(
   IGRint      type,
   GRobjid      app_id,
   GRspacenum   app_osnum,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{

   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
     ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);
 
   status = om$send ( msg = message IGEcolor2.app_con(type,app_id, app_osnum),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if ( 1 & status)
   {
      status = TRUE;
   }
   else
   {
      status = FALSE;
   }

   return(status);
}

IGRint IGEchgclrtab(
   IGRshort   num_colors,
   void      *colors,
   IGRint      flags,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   IGRshort      start_color;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
     ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);
 
   if (flags&IGE_CHANGE_BACKGROUND)
   {
      start_color = 0;
   }
   else
   {
      start_color = 1;
   }
   
   status = om$send ( msg = message IGEcolor2.change_clr_tbl(
                start_color,num_colors,colors,flags),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if (!( 1 & status))
   {
#ifdef DEBUG_CL
          om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint IGEmodclrtab(
   IGRshort   start_color,
   IGRshort   num_colors,
   void      *colors,
   IGRint      flags,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);

   status = om$send ( msg = message IGEcolor2.change_clr_tbl(
                start_color,num_colors,colors,flags),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if (!( 1 & status))
   {
#ifdef DEBUG
          om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint   IGEchgresclr(
   void      *fg_color,
   void      *bg_color,
   void      *hilite_color,
   IGRint      flags,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   status = 1;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);
   
   if (hilite_color)
   {
      status = om$send ( msg = message IGEcolor2.change_clr_tbl(0,1,hilite_color,flags|IGE_CHANGE_HIGHLIGHT),
               senderid = NULL_OBJID,
               targetid = clr_id,
               targetos = modos);
   }
   else /* give priority to highlight color */
   {   
     if (fg_color)
      {
      status = om$send ( msg = message IGEcolor2.change_clr_tbl(0,1,fg_color,flags|IGE_CHANGE_HIGHLIGHT),
               senderid = NULL_OBJID,
               targetid = clr_id,
               targetos = modos);
      }
   }

   if (bg_color)
   {
      status = om$send ( msg = message IGEcolor2.change_clr_tbl(0,1,bg_color,flags|IGE_CHANGE_BACKGROUND),
               senderid = NULL_OBJID,
               targetid = clr_id,
               targetos = modos);
   }

   if (!( 1 & status))
   {
#ifdef DEBUG
          om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint IGEchgclrnam(
   IGRshort      num_names,
   struct IGEcol_names   *names,
   IGRint         flags,
   GRobjid         mod_id,
   GRspacenum      mod_osnum)
{

   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;


   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);

   status = om$send ( msg = message IGEcolor2.change_clr_nam(
                num_names,names,flags),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if (!( 1 & status))
   {
#ifdef DEBUG
          om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint IGEdelclrnam(
   IGRshort   num_names,
   IGRint      *name_indexes,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);

   status = om$send ( msg = message IGEcolor2.delete_clr_nam(
                num_names,name_indexes),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if (!( 1 & status))
   {
#ifdef DEBUG
      om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint IGEreadclrtab(
   IGRshort   *num_colors,
   void    *colors,
   IGRint      flags,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);

   status = om$send ( msg = message IGEcolor2.read_clr_tbl(
                num_colors,colors,flags),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if (!( 1 & status))
   {
#ifdef DEBUG
      om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint   IGEreadresclr(
   void      *fg_color,
   void      *bg_color,
   void      *hilite_color,
   IGRint      flags,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   status = 1;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);
 
   if (hilite_color)
   {
      status = ige$get_rgb_value(log_color = IGE_LOGICAL_HILITE,
                  rgb_value = hilite_color,
                  flags = flags);
   }

   if (fg_color)
   {
      status = ige$get_rgb_value(log_color = IGE_LOGICAL_HILITE,
                  rgb_value = fg_color,
                  flags = flags);
   }

   if (bg_color)
   {
      status = ige$get_rgb_value(log_color = IGE_LOGICAL_BACKGROUND,
                  rgb_value = bg_color,
                  flags = flags);
   }

   if (!( 1 & status))
   {
#ifdef DEBUG
      om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint IGEreadclrnam(
      IGRshort      *num_names,
      struct IGEcol_names   *names,
      GRobjid      mod_id,
      GRspacenum      mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
     ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);
 
   status = om$send ( msg = message IGEcolor2.read_clr_nam(
                num_names,names),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if (!( 1 & status))
   {
#ifdef DEBUG
        om$report_error(sts = status);
#endif
      status = FALSE;
   }
   else
   {
      status = TRUE;
   }

   return(status);
}

IGRint   IGErdphytab(
   WLuint32      context_no,
   IGRshort      *num_slots,
   struct WLcmap_entry   *phys_slots)
{
   IGRint       status;
   IGRint      entries;
   struct IGEcontext_info      context_info;
   
   IGEload_context(context_no,&context_info);   
   
   entries = (IGRint) *num_slots;
   if (entries > (1<<context_info.table_depth))
   {
      return(FALSE);
   }
   
   /* the phys_slots array should be initialized when called */
   status = WLread_cmap_entries( context_no, entries, phys_slots);
   
   return(status == WL_SUCCESS);
}

IGRint   IGEgetcubemapping(
   WLuint32      context_no,
   IGRshort      *num_entries,
   IGRshort      *mapping)
{
   IGRshort   i = 0;
   IGRint      red, grn, blu;
   IGRint      cube_size,status = TRUE;
   IGRshort   *rgb_table;
   struct IGEcontext_info      context_info;
   
   IGEload_context(context_no,&context_info);   
   cube_size = context_info.cube_size;
   rgb_table = context_info.rgb_table;
   
   if (*num_entries<(cube_size*cube_size*cube_size))
   {
#ifdef DEBUG_CL
      printf("IGEgetcubemapping: not enough entries malloced\n");
#endif
      return(FALSE);
   }
   
   for ( blu = 0; blu < cube_size; blu++ )
   {
      for ( grn = 0; grn < cube_size; grn++ )
      {
         for ( red = 0; red < cube_size; red++ )
         {
            mapping[i++] = rgb_table[(blu << 6) | (grn << 3) | red];
         }
      }
   }

   *num_entries = i;      
   return(status);
}

IGRint   IGEgetnmfrclr(
   IGRshort   color,
   IGRchar      *name,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
     ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);

   status = om$send ( msg = message IGEcolor2.get_name_from_color( color,name),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if ( 1 & status)
   {
      status = TRUE;
   }
   else
   {
      status = FALSE;
   }

   return(status);
}


IGRint   IGEgetclrfrnm(
   IGRchar      *name,
   IGRshort   *color,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);
 
   status = om$send ( msg = message IGEcolor2.get_color_from_name(
                name,color),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if ( 1 & status)
   {
      status = TRUE;
   }
   else
   {
      status = FALSE;
   }

   return(status);
}

IGRint   IGEgetabsclrindx(
   WLuint32   context_no,
   IGRshort   log_color,
   IGRshort   *abs_color)
{
   IGRint       status;
   IGRuint phy_index;
   WLuint32 log_color_uint;
   
   log_color_uint = log_color;
   log_color_uint = log_color_uint & 0xFFFF;
   status = IGEcmap_color_to_index(context_no, log_color_uint, 0,0,0, 0, &phy_index);
   
   *abs_color = (IGRshort) phy_index;
   if (!(status & 1))
   {
      status = TRUE;
   }
   else
   {
      status = FALSE;
   }

   return(status);
}

IGRint   IGEgetrgbvalue(
   IGRshort   log_color,
   void      *rgb_value,
   IGRint      flags,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);

   status = om$send ( msg = message IGEcolor2.get_rgb_value(
                log_color,rgb_value,flags),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if ( 1 & status)
   {
      status = TRUE;
   }
   else
   {
      status = FALSE;
   }

   return(status);
}

IGRint   IGEgetnumactcol(
   WLuint32   context_no,
   IGRshort   *num_colors)
{
   IGRint       status = TRUE;
   struct IGEcontext_info      context_info;
   
   status = IGEload_context(context_no,&context_info);   
   
   *num_colors=context_info.num_bg_log_hl_colors-2;

   return(status);
}

IGRint   IGEconclrtab(
   GRobjid      mod_id,
   GRspacenum   mod_osnum,
   WLuint32   context_no)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
     ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);

   status = om$send ( msg = message IGEcolor2.configure_table(context_no),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if ( 1 & status)
   {
      status = TRUE;
   }
   else
   {
      status = FALSE;
   }

   return(status);
}

IGRint   IGEsetinqclrobjparam(
   IGRint      inq0_set1,
   IGRdouble   *tolerance_pct,
   IGRdouble   *gamma_correction,
   IGRint      *num_ramp_colors,
   IGRint      *user_cube_size,
   GRobjid      mod_id,
   GRspacenum   mod_osnum)
{
   IGRint       status;
   GRobjid      modid;
   GRobjid      clr_id;
   GRspacenum   modos;

   if (mod_id == NULL_OBJID)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
   }
   else
   {
      modid = mod_id;
      modos = mod_osnum;
   }

   IGEget_col_id(modid,modos,&clr_id);
 
   status = om$send ( msg = message IGEcolor2.set_inq_color_params(
            inq0_set1,tolerance_pct,gamma_correction,num_ramp_colors, user_cube_size),
            senderid = NULL_OBJID,
            targetid = clr_id,
            targetos = modos);

   if ( 1 & status)
   {
      status = TRUE;
   }
   else
   {
      status = FALSE;
   }

   return(status);
}   

IGRint IGEsetinqspecslots(
   IGRint         inq0_set1,
   WLuint32      context_no,
   struct WLcmap_entry   *phys_subtable,
   IGRint         *num_slots,
   IGRint         *start_slot)
{
   IGRint    status = WL_SUCCESS,i,j;
   IGRint   beginning_special_slot,num_special_area_slots,num_slots_returned,actual_start_slot;
   struct IGEcontext_info      context_info;
   
   IGEload_context(context_no,&context_info);   

   num_slots_returned = *num_slots;
   actual_start_slot = *start_slot;
   IGEget_special_area_info(context_no,&beginning_special_slot,&num_special_area_slots);

   if (num_slots_returned == -1) /* querying the size and start only */
   {
      num_slots_returned = num_special_area_slots;
      actual_start_slot = beginning_special_slot;
      goto wrap_up;
   }
      
   if ((actual_start_slot < beginning_special_slot)||
       (actual_start_slot >= beginning_special_slot+num_special_area_slots))
   {
      /* start_slot is not within special area, default to first slot */
      actual_start_slot = beginning_special_slot;
   }
   
   if (num_slots_returned>num_special_area_slots-(actual_start_slot-beginning_special_slot))
   {
      /* num_slots is more than we could return */
      num_slots_returned = num_special_area_slots-(actual_start_slot-beginning_special_slot);
   }

   for (i = 0,j = actual_start_slot;i<num_slots_returned;i++)
   {
      phys_subtable[i].slot = j+i;
   }

   if (inq0_set1)
   {
      status = WLload_cmap_entries(context_no,num_slots_returned,phys_subtable);
   }
   else
   {   
      status = WLread_cmap_entries(context_no,num_slots_returned,phys_subtable);
   }   
   
wrap_up:
   *num_slots = num_slots_returned;
   *start_slot = actual_start_slot;
   return(status == WL_SUCCESS);
}

IGRint IGEinqclrtblparam(
   WLuint32   context_no,
   IGRint      *cube_size,
   IGRint      *wmgr_size,
   IGRint      *ingr_menu_size)
{
   IGRint       status;

   status = IGEinq_cube_wmgr_ingr_sizes(context_no,cube_size,wmgr_size,ingr_menu_size);   
   return(status == 0);
}

IGRint IGErgbtological(
   WLuint32   context_no,
   void      *color,
   IGRint      *logical_index,
   IGRint      flags)
{
   IGRint       status;
   IGRint      rgb;
   struct IGEvlt   *unpacked_colors;
   
   if (flags & PACKED_COLORS)
   {
      rgb = *((IGRint *) color);
   }
   else
   {
      unpacked_colors = (struct IGEvlt *) color;
      rgb = CLpack_colors(unpacked_colors->red,
         unpacked_colors->green,unpacked_colors->blue);
   }

   status = IGErgb_to_logical(context_no,rgb,logical_index);   

   return(status == 0);
}

IGRint	IGEgetFI_COLORphys(
	WLuint32		context_no,
	IGRshort                FI_DEFINE,
	IGRshort                *phys_slot_num,
        IGRshort                *fixed_vlt)
{
   IGRint sts = TRUE,i;
   struct IGEcontext_info      context_info;

   sts = IGEload_context(context_no,&context_info);   
   if (!sts)
   {
      return(sts);
   }

   if (fixed_vlt)
   {
      *fixed_vlt = (context_info.num_ingr_res_colors == 14);
   }

   if (context_info.num_ingr_res_colors == 0)
   {
      if (context_info.table_depth <=2)
      {
         switch ( FI_DEFINE )
         {
            case FI_MED_GREY:
            case FI_BLACK:
            case FI_DK_GREY:
            case FI_RED:
            case FI_BLUE:
            case FI_DK_RED:
            case FI_DK_GREEN:
            case FI_DK_BLUE:
               /*** dark color ***/
               *phys_slot_num = 0;
               break;

            case FI_OFF_WHITE:
            case FI_YELLOW:
            case FI_LT_GREY:
            case FI_WHITE:
            case FI_GREEN:
            case FI_LT_YELLOW:
            default:
               /*** bright color ***/
               *phys_slot_num = 1;
               break;
         }
         return( sts );
      }
      else
      {
         return( FALSE );
      }
   }
      
   /* if FI_DEFINE sent in is -1 then wanted highest slot */
   if (FI_DEFINE == -1)
   {
      /* find the highest slot (for _FI_colormap_notify) */
      *phys_slot_num = 0;

      for (i = 0; i < context_info.num_ingr_res_colors; i ++)
      {
         if (*phys_slot_num < context_info.ingr_res[i].phys_slot)
         {
            *phys_slot_num = context_info.ingr_res[i].phys_slot;
         }
      }
      return(sts);
   }

   switch (context_info.num_ingr_res_colors)
   {
      case 14:
         /* for the normal clipper case this will be 1 + the 
            FI_DEFINE since it starts at slot 1 (after bg). 
            Examples of FI_DEFINE are FI_RED, FI_BLACK etc;
            found in FI.h */

         *phys_slot_num = context_info.ingr_res[FI_DEFINE].phys_slot;
         break;

      case  5:
         /* This is the standard case for the rop.  We will 
            map the colors to a ingr res color like the 
            logic before the IGEcolor2 object. */
         /*****************************************/
         /*** Map all colors to slots   	***/
         /***	0 - dark	ingr_res[0]	***/
         /***	1 - bright(grn)	ingr_res[1]	***/
         /***   13 - LT GREY	ingr_res[2]	***/
         /***   14 - MED GREY	ingr_res[3]	***/
         /***   15 - OFF WHITE	ingr_res[4]	***/
         /*****************************************/
      
         switch ( FI_DEFINE )
         {
            case FI_BLACK:
            case FI_DK_GREY:
            case FI_BLUE:
            case FI_DK_RED:
            case FI_DK_GREEN:
            case FI_DK_BLUE:
            default:
               /*** dark color ***/
               *phys_slot_num = context_info.ingr_res[0].phys_slot;
               break;
            
            case FI_YELLOW:
            case FI_GREEN:
            case FI_LT_YELLOW:
            case FI_RED:
               /*** bright color ***/
               *phys_slot_num = context_info.ingr_res[1].phys_slot;
               break;
            
            case FI_LT_GREY:
               /*** LT GREY ***/
               *phys_slot_num = context_info.ingr_res[2].phys_slot;
               break;
            
            case FI_MED_GREY:
               /*** MED GREY ***/
               *phys_slot_num = context_info.ingr_res[3].phys_slot;
               break;
            
            case FI_WHITE:
            case FI_OFF_WHITE:
               /*** OFF WHITE ***/
               *phys_slot_num = context_info.ingr_res[4].phys_slot;
               break;

         }
         break;
      default: 
         switch ( FI_DEFINE )
         {
            case FI_OFF_WHITE:
            case FI_YELLOW:
            case FI_LT_GREY:
            case FI_WHITE:
            case FI_GREEN:
            case FI_LT_YELLOW:
               /*** bright color ***/
               *phys_slot_num = context_info.ingr_res[1].phys_slot;
               break;
               
            case FI_MED_GREY:
            case FI_BLACK:
            case FI_DK_GREY:
            case FI_RED:
            case FI_BLUE:
            case FI_DK_RED:
            case FI_DK_GREEN:
            case FI_DK_BLUE:
            default:
               /*** dark color ***/
               *phys_slot_num = context_info.ingr_res[0].phys_slot;
               break;

         }
         break;

   }
   
   return(sts);
}

IGRint   IGEget_col_id(
      GRobjid   modid,
      GRspacenum   modos,
      GRobjid   *clr_id)
{
   IGRint   status;
   GRspacenum   col_os;

   status = ex$get_super(mod_id = modid,
                          mod_osnum = modos,
                          super_name = "IGECOLOR2",
                          create = TRUE,
                          super_class = "IGEcolor2",
                          super_id = clr_id,
                          super_osnum = &col_os);

   if (!( 1 & status))
   {
#ifdef DEBUG
       om$report_error(sts = status);
#endif
   }
   else
   {
      status = TRUE;
   }

    return(status);
}   

IGRint   IGEset_color_id(GRobjid   clr_id)
{
   IGEcolor2_id = clr_id;
   return(IGEcolor2_id);
}   

IGRint   IGEget_color_id(GRobjid   *clr_id)
{
   GRobjid      modid;
   GRspacenum   modos;

   if (IGEcolor2_id != 0)
   {
      ex$get_cur_mod( id = &modid, osnum = &modos);
      IGEget_col_id( modid, modos, clr_id);
   } 
   return(IGEcolor2_id != 0);
}   

end  implementation  IGEcolor2;
