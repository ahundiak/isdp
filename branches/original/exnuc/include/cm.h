#if !defined( cm_include )
#define cm_include 1

#if !defined( TRUE )
#define TRUE 1
#endif

#if !defined( FALSE )
#define FALSE 0
#endif

/* slot_used flag */
#define CM_SLOT_USED 0x00000001
#define CM_SHARABLE  0x00000002

#define CM_MAX_CONTEXTS  1000

/* error codes */
#define CM_SUCCESS		0x00000000
#define CM_BAD_PARAMETER	0x00000001
#define CM_SYSTEM_ERROR		0x00000002

/* Priorities for selecting contexts */

#define CM_HL_PRIORITY_1        0x10000000
#define CM_HL_PRIORITY_2        0

#define CM_DB_PRIORITY_1        0x01000000
#define CM_DB_PRIORITY_2        0

/* Color priorities                  */
#define CM_CL_PRIORITY_1        0x00100000
#define CM_CL_PRIORITY_2        0x00010000


/* error checking macro */
#if defined( REPORT_ERRORS )
 
#define CM_REPORT_ERROR( err_num ) \
   fprintf( stderr, "CM ERROR: %d; File: %s; Line: %d\n", (err_num), __FILE__, __LINE__ );
#else
#define CM_REPORT_ERROR( err_num )
 
#endif


/* Context manager structure */

struct CMctx_mgr
{
   OM_S_OBJID color_objid;
   WLuint32 context_no;
   WLuint16 lscreen_no;
   int flag;
};

#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#endif

extern int CMcreate_context __((
   OM_S_OBJID color_objid,
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
   int share_context, 
   WLuint32 *context_no));

extern int CMdelete_context __((
   WLuint16 lscreen_no,
   WLuint32 context_no));

extern int CMchange_context_info __((
   WLuint32 context_no,
   OM_S_OBJID  color_objid,
   int (*cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (*cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (*cmap_init)(
      WLuint32 context_no ) ));

extern int CMget_context_info __((
   WLuint32 context_no,
   OM_S_OBJID  *color_objid,
   int (**cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (**cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (**cmap_init)(
      WLuint32 context_no ),
   struct WLcontext_info *context_info ));

extern int CMget_contexts __((
   struct CMctx_mgr **ctx_arr,
   int *num_of_contexts ));

extern int CMset_active_context __((
   WLuint16 lscreen_no,
   WLuint32 context_no ));

extern int CMget_active_context __((
   WLuint16 lscreen_no,
   WLuint32 *context_no ));

extern int CMinitialize_context __((
   WLuint32 context_no ));

extern int CMcreate_context_native_info __((
   OM_S_OBJID color_objid,
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
   struct WLnative_info *native_info,
   int share_context,
   WLuint32 *context_no ));

extern int CMadd_form_to_wl __((
   WLhwin_no hwin_no,
   int share,
   OM_S_OBJID color_objid,
   OMuword osnum,
   int save_restore,
   WLuint16 *lscreen_no,
   WLuint32 *context_no,
   WLuint32 *lwin_no ));

extern int CMremove_form_from_wl __((
   WLuint16 lscreen_no,
   WLuint32 lwin_no,
   WLuint32 context_no ));

extern int CMset_exnuc_forms_context __((
   WLuint16 lscreen_no,
   WLuint32 context_no ));

extern int CMget_exnuc_forms_context __((
   WLuint16 lscreen_no,
   WLuint32 *context_no ));

#undef __

#endif
