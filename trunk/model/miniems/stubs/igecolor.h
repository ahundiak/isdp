#ifndef igecolor_include

#define	igecolor_include

/* 
	DEPENDENCIES 
include "wl.h"
include "OMminimum.h"
include "igetypedef.h"
*/

struct IGEcolor2_data
{
   int version;
   int user_cube_size;
   int num_ramp_colors;
};

struct IGEvlt	
{
     unsigned short red;
     unsigned short green;
     unsigned short blue;
};
#if defined (SUNOS5)
#undef index
#endif

struct IGEcol_names
{
     IGRchar	name[24];
     IGRshort	index;
};

struct IGEcolor_mapping
{
	IGRshort  phys_slot;
	IGRushort phys_red;         /* [0 .. 65535] */
	IGRushort phys_green;       /* [0 .. 65535] */
	IGRushort phys_blue;        /* [0 .. 65535] */
	IGRushort log_red;          /* [0 .. 65535] */
	IGRushort log_green;        /* [0 .. 65535] */
	IGRushort log_blue;         /* [0 .. 65535] */
};

struct IGEphys_color_mapping
{
	IGRshort  phys_slot;
	IGRushort phys_red;         /* [0 .. 65535] */
	IGRushort phys_green;       /* [0 .. 65535] */
	IGRushort phys_blue;        /* [0 .. 65535] */
};

struct IGElogical_color
{
	IGRushort log_red;          /* [0 .. 65535] */
	IGRushort log_green;        /* [0 .. 65535] */
	IGRushort log_blue;         /* [0 .. 65535] */
};

#ifndef BASE_EMS
struct IGEcontext_info
{
	WLuint32 context_no;
	IGRint table_depth;
	IGRint num_win_mgr_colors;
	struct IGEcolor_mapping *win_mgr;
	IGRint num_ingr_res_colors;
	struct IGEcolor_mapping *ingr_res;
	IGRint num_bg_log_hl_colors;
	struct IGEphys_color_mapping *bg_log_hl;
	short *rgb_table;
	int cube_size;                            /* current cube size           */
        int user_cube_size;                       /* user cube size pound define */
        IGRint num_ramp_colors;                   /* number of logical colors that are ramps */
        IGRint num_ramp_shades;                   /* number of ramps per shade */
        IGRboolean using_ramp;                    /* whether using ramp or not */
        IGRint user_ramp_start_slot;              /* slot special user ramp starts (only valid [!=-1] */ 
                                                  /* when using_ramp=TRUE) and a ramp was set up */
};

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


/* IGEcolortbl.I */
extern IGRint IGEload_context __((WLuint32 context_no, struct IGEcontext_info *context_info));
extern IGRint IGEsave_context __((WLuint32 context_no, struct IGEcontext_info *context_info));
extern IGRint IGEload_logical_array __((IGRint *bg_log_hl_colors, IGRint start_slot, IGRint num_slots));
extern IGRint IGEcolor_compensate __((IGRint num_colors, IGRushort *colors, IGRdouble *gamma, IGRboolean convert_opt ));
extern void IGEcalc_best_match __((IGRushort red, IGRushort green, IGRushort blue, IGRboolean *within_tol, IGRdouble tolerance, IGRint search, IGRint not_search, IGRint num_colors, IGRint *matched_slot));
extern IGRint IGEinit_physical_vlt __((IGRint num_planes, IGRint reserve_hilite_plane, IGRint hilite_color));
extern IGRint IGEres_special_area __((IGRint num_slots_requested, IGRushort *special_colors, IGRint num_slots_available, IGRint num_win_mgr_colors, struct IGEcolor_mapping *win_mgr_colors, IGRint num_ingr_res_colors, struct IGEcolor_mapping *ingr_res_colors));
extern IGRint IGEload_cube __((IGRint cube_size, IGRint num_slots_available, IGRdouble *gamma));
extern IGRint IGEload_window_manager __((IGRboolean assign_slot, IGRdouble tolerance, IGRint num_win_mgr_colors, struct IGEcolor_mapping *win_mgr_colors, IGRint total_colors));
extern IGRint IGEload_ingr_res __((IGRboolean assign_slot, IGRdouble tolerance, IGRint num_ingr_res_colors, struct IGEcolor_mapping *ingr_res_colors, IGRint total_colors));
extern IGRint IGEload_logical __((IGRdouble tolerance, IGRdouble *gamma, IGRint num_bg_log_hl_colors, struct IGEphys_color_mapping *bg_log_hl_mapping, struct IGElogical_color *bg_log_hl_colors, IGRint total_colors));
extern IGRint IGEremap_logical_table __((WLuint32 context_no, IGRdouble tolerance, IGRdouble *gamma, IGRint *bg_log_hl, IGRint num_bg_log_hl_colors, IGRint start_color, IGRint num_changed_colors));
extern void IGEindex_to_rgb __((WLuint32 context_no, IGRint flag, IGRint index, IGRint *out_red, IGRint *out_green, IGRint *out_blue));
extern IGRint IGErgb_to_index __((WLuint32 context_no, IGRint x, IGRint y, IGRint red, IGRint grn, IGRint blu));
extern void IGEcopy_pack_to_map __((IGRint num_colors, IGRint *packed_colors, struct IGEcolor_mapping *map_colors));
extern void IGEcopy_map_to_pack __((IGRint num_colors, struct IGEcolor_mapping *map_colors, IGRint *packed_colors));
extern IGRint IGEswap __((IGRboolean swap_type, struct IGEcolor_mapping *map_colors, IGRint slot));
extern IGRint IGEcreate_exact_match __((IGRint assign, struct IGEcolor_mapping *color, IGRint slot));
extern IGRint IGElog_create_exact_match __((IGRint assign, struct IGEphys_color_mapping *color_mapping, IGRint slot));
extern IGRint IGEassign_to_slot __((IGRint assign, struct IGEcolor_mapping *color, IGRint slot));
extern IGRint IGElog_assign_to_slot __((IGRint assign, struct IGEphys_color_mapping *color, IGRint slot));
extern IGRint IGEfree_slot __((IGRint index, IGRint slot, IGRint num_bg_log_hl_colors, struct IGEphys_color_mapping *bg_log_hl_colors));
extern IGRint IGEslot_available __((IGRint available, IGRint *available_slot, IGRint num_slots));
extern IGRint IGEconfigure_table __((WLuint32 context_no, IGRshort cube_dimension, IGRshort special_size, IGRushort *special_colors, IGRdouble tolerance_pct, IGRdouble *gamma));
extern IGRint IGEget_special_area_info __((WLuint32 context_no, IGRint *beginning_special_slot, IGRint *num_special_area_slots));
extern IGRint IGEinq_cube_wmgr_ingr_sizes __((WLuint32 context_no, IGRint *cube_size, IGRint *wmgr_size, IGRint *ingr_size));
extern IGRint IGErgb_to_logical __((WLuint32 context_no, IGRint color, IGRint *logical_index));
extern void IGEcolor_debug __((void));
extern IGRint IGEcmap_color_to_index __((WLuint32 context_no, WLuint32 index, WLuint32 red, WLuint32 green, WLuint32 blue, WLuint32 flag, WLuint32 *phy_index));
extern IGRint IGEcmap_color_to_rgb __((WLuint32 context_no, WLuint32 index, WLuint32 red, WLuint32 green, WLuint32 blue, WLuint32 flag, WLuint32 *out_red, WLuint32 *out_green, WLuint32 *out_blue));
extern IGRint IGEcmap_init __((WLuint32 context_no));
extern IGRint IGEadd_context __((WLuint32 context_no, IGRint num_win_mgr, IGRint num_ingr_res, IGRint num_bg_log_hl));
extern IGRint IGEdelete_context __((WLuint32 context_no));

#if defined( PPL )

extern IGRint *IGEset_gamma_compensate_ptr __(( IGRint (*func)( IGRint, IGRushort *, IGRdouble *, IGRboolean ) )) __(( IGRint, IGRushort *, IGRdouble *, IGRboolean ));

extern IGRint *IGEget_gamma_compensate_ptr __(( )) __(( IGRint, IGRushort *, IGRdouble *, IGRboolean ));

#else

extern IGRint ( *IGEset_gamma_compensate_ptr __(( IGRint (*func)( IGRint, IGRushort *, IGRdouble *, IGRboolean ) )) ) __(( IGRint, IGRushort *, IGRdouble *, IGRboolean ));

extern IGRint ( *IGEget_gamma_compensate_ptr __(( )) ) __(( IGRint, IGRushort *, IGRdouble *, IGRboolean ));

#endif

extern IGRboolean IGEset_ramp_mode_getenv __(( void ));
extern IGRboolean IGEset_using_ramp_mode __(( IGRboolean using_ramp ));
extern IGRboolean IGEget_using_ramp_mode __(( void ));
extern IGRint IGEget_ambient_light __(( IGRushort *red, IGRushort *green, IGRushort *blue));
extern IGRint IGEset_ambient_light __(( IGRushort red, IGRushort green, IGRushort blue));
extern IGRint IGEset_min_ramp_shades __(( int min_ramp_shades ));
extern IGRint IGEload_ramp __(( IGRint start_slot, IGRushort red, IGRushort green, IGRushort blue, IGRdouble *gamma, struct IGEcontext_info *IGEcontext_info));
extern IGRint IGEload_ramps __((IGRint num_bg_log_hl_colors, struct IGElogical_color *bg_log_hl_colors, IGRdouble *gamma, struct IGEcontext_info *context_info ));


/* IGEconclrtab.I */

#if defined( PPL )

extern IGRint *DPset_load_vlt_ptr __(( int (*func)( ))) __(( ));

#else

extern IGRint ( *DPset_load_vlt_ptr __(( int (*func)( )))) __(( ));

#endif


#if defined(__cplusplus)
}
#endif

#endif

#undef __

#endif

