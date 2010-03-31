/*
 *  HSpr_co_func.h: The prototype file for the 
 *                  hsurf/src/co_func directory
 */
 

#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*---HSalert_box.C-----------------------------------------------------*/

extern void HSpix_count                   __(( void ));
extern void HSout_of_zrange               __(( WLuint32 ));
extern void HSwrong_window                __(( void ));
extern void HSnew_vs                      __(( void ));
extern void HSreconfiguring_user_table    __(( IGRboolean ));
extern void HSnot_enough_planes_to_render __(( void ));
extern void HSnot_enough_planes_for_RGB   __(( void ));
extern void HSnot_enough_planes_to_shade  __(( char *));
extern void HStexture_file_not_found      __(( IGRchar *));
extern void HStexture_file_same_as_output_file __(( IGRchar *));

/*---HSbldphyctbl.C----------------------------------------------------*/

extern int HScolor_compensate __(( int,
                                   int ));

extern IGRint build_phys_tbl     __(( int,
                                      int,
                                      struct WLcmap_entry *,
                                      int ));

/*---HScbox.c----------------------------------------------------------*/

#ifdef X11
extern int HFI_confirm_box __(( int,
                                int,
                                int,
                                char *,
                                int,
                                char *,
                                double,
                                char *,
                                int,
                                char *,
                                double,
                                int,
                                int,
                                int ));

extern int HFI_msg_box     __(( char *,
                                int,
                                char *,
                                int ));

extern int HFI_msg_box2    __(( char *,
                                int,
                                char *,
                                int ));

extern int HFI_message_box __((	int,
                                int,
                                int,
                                char *,
                                int,
                                char *,
                                double,
                                char *,
                                int,
                                char *,
                                double,
                                int,
                                int ));

extern int HFI_message_box2 __(( int,
                                 int,
                                 int,
                                 char *,
                                 int,
                                 char *,
                                 double,
                                 char *,
                                 int,
                                 char *,
                                 double,
                                 int,
                                 int ));

/*
extern int HFI_confirm_box __(( int,
                                int,
                                int,
                                char *,
                                int,
                                char *,
                                double,
                                char *,
                                int,
                                char *,
                                double,
                                int,
                                int,
                                int ));
*/
#endif

/*---HSformat_rle.c-----------------------------------------------------------------*/

/*---------------------------------------
 *
 *  For XGL, I had to add another argument to HStranspose.  This
 *  contains the depth of the raster data being transposed
 *
 */

#if defined (XGL)
extern void HStranspose __(( char *,
                             int, int ));
#else
extern void HStranspose __(( char *,
                             int ));
#endif

extern void HSwl_put_line __(( char *,
                               WLuint32,
                               WLuint32,
                               int,
                               int,
                               int,
                               int,
                               int ));
 
extern void HScleanup_putline __(( void ));

extern void HSset_LineByLine_off __(( void ));

extern void HSset_LineByLine_on  __(( WLuint32,
                                      WLuint32,
                                      int,
                                      int,
                                      int,
                                      int,
                                      int ));

extern int  HSformat_type26      __(( FILE *,
                                      short,
                                      int,
                                      int,
                                      char *));

extern int  HSformat_type10      __(( FILE *,
                                      int,
                                      int,
                                      char *));

extern int  HSformat_type15      __(( FILE *,
                                      short,
                                      short,
                                      char *));

extern void HSformat_type27      __(( FILE *,
                                      int,
                                      short,
                                      short,
                                      char *,
                                      int,
                                      int,
                                      int,
                                      int,
                                      short,
                                      unsigned short ));

extern void HSformat_indexed     __(( FILE *,
                                      int,
                                      int,
                                      int,
                                      int,
                                      char *,
                                      int,
                                      int,
                                      int,
                                      int,
                                      int,
                                      IGRboolean,
                                      short,
                                      int,
                                      struct WLcmap_entry *,
                                      int,
                                      unsigned short));

/*---HSheartbeat.C--------------------------------------------------------*/

extern void HSinit_heartbeat   __(( IGRchar *));
extern void HSupdate_heartbeat __(( void ));

/*---HShs_collect.C-------------------------------------------------------*/

extern IGRboolean HScollect_hidden_symbology_overrides __(( struct GRid *,
                                                            struct GRid *,
                                                            OM_S_CHANSELECT *,
                                                            IGRint,
                                                            IGRdouble *));

/*---HShs_process.I-------------------------------------------------------*/

extern void HSinit_delete_detail_display   __(( struct GRid *,
                                                IGRint,
                                                IGRdouble *));

extern void HSprocess_soos_on_solid        __(( struct GRid *,
                                                IGRshort *,
                                                IGRmatrix,
                                                struct GRmd_env *,
                                                IGRint ));

extern void HSprocess_soos_on_surface_edge __(( struct GRid *,
                                                IGRshort *,
                                                IGRmatrix ));

extern void HSprocess_soos_on_curve        __(( struct GRid *,
                                                IGRshort *,
                                                IGRmatrix ));
			     
/*---HSlin_to_exp.c-------------------------------------------------------*/

extern int HSlin_to_exp __(( int ));

extern int HSexp_to_lin __(( int ));

/*---HSmatch.C------------------------------------------------------------*/

extern int HSfork             __(( int,
                                   char **,
                                   int ));

extern int HSget_file_o_files __(( char *,
                                   FILE **,
                                   char *));

/*---HSmsg.C--------------------------------------------------------------*/

extern int HSfile_error __(( int ));

extern int HSget_msg    __(( int,
                             char *,
                             char *));

extern int HSdisplay_memory_realloc_message __(( void ));

extern int HSerase_memory_realloc_message   __(( void ));

extern int HSdisplay_update_message __(( IGRuchar ));

/*---HSparser.c-----------------------------------------------------------*/

extern int HSparse_command_option __(( char *,
                                       struct option_set *));

/*---HSread_hdr.C---------------------------------------------------------*/

extern void HSalter_vlt      __(( WLuint32,
                                  struct WLcmap_entry *,
                                  int ));

extern int HSread_rle_header __(( char *,
                                  char *,
                                  WLuint32,
                                  WLuint32,
                                  int,
                                  int *,
                                  IGRboolean *,
                                  int *,
                                  int,
                                  short *,
                                  short *,
                                  struct frame *,
                                  int,
                                  int *,
                                  struct WLcmap_entry *,
                                  int *,
                                  unsigned short *));

extern int HSget_num_frames  __(( char *));

extern int HSinq_phong_file  __(( char *,
                                  int *,
                                  int *,
                                  int *));

extern void HSdetermine_offset __(( int,
                                    int,
                                    int,
                                    int *));

/*---HSrecall_rle.C----------------------------------------------------------*/

extern int HSget_put_block_size __(( int,
                                     int,
                                     int,
                                     int ));

#ifdef X11	     
extern Bool animate_predproc __(( Display *,
                                  XEvent *,
                                  char *));
#endif
		     
extern void HSXget_button_data __(( int *,
                                    int *,
                                    int *,
                                    int *,
                                    int * ));

extern void HSfree_buffers     __(( int ));

extern void HSrecall_rle       __(( WLuint32,
                                    WLuint32,
                                    char *,
                                    int,
                                    int,
                                    int,
                                    int ));

extern int  HSrapid_display    __(( WLuint32,
                                    WLuint32,
                                    int,
                                    int,
                                    int,
                                    int,
                                    double,
                                    double,
                                    short,
                                    int,
                                    int,
                                    IGRboolean ));

extern int  HSslide_show       __(( WLuint32,
                                    WLuint32,
                                    char *,
                                    int,
                                    int,
                                    int,
                                    int,
                                    double,
                                    double,
                                    int,
                                    int,
                                    int ));

extern int  HSread_raster_data __(( char *,
                                    int,
                                    int,
                                    IGRboolean,
                                    int,
                                    WLuint32,
                                    WLuint32,
                                    int,
                                    int,
                                    int,
                                    int,
                                    int,
                                    int,
                                    int,
                                    int *,
                                    int,
                                    int,
                                    short,
                                    int,
                                    short,
                                    short,
                                    int,
                                    struct WLcmap_entry *,
                                    int,
                                    unsigned short));

extern int HSread_rle_files    __(( WLuint32,
                                    WLuint32,
                                    char *,
                                    int,
                                    int,
                                    int,
                                    int,
                                    double,
                                    int,
                                    int,
                                    int,
                                    int,
                                    int,
                                    int ));

extern int HSread_num_frames_from_journal __(( IGRboolean ));

/*---HSref_plane.I--------------------------------------------------------------*/

extern void HSsetup_ref_plane_for_window __(( OM_S_OBJID,
                                              OMuword ));

/*---HSsave_image.c----------------------------------------------------------*/

extern int HScapture_image __(( char *,
                                unsigned short,
                                unsigned short,
                                unsigned short,
                                unsigned short,
                                WLuint32,
                                WLuint32 ));

/*---HStex_dis.C--------------------------------------------------------------*/

extern int HSread_type27  __(( FILE *,
                               short,
                               short,
                               int,
                               int,
                               int,
                               int,
                               int,
                               unsigned short *));

extern int HSwrite_type27 __(( WLuint32,
                               WLuint32,
                               int,
                               char *,
                               int,
                               int,
                               int,
                               int,
                               int,
                               unsigned short sph_rgb[3][RGB_YMAX],
                               int,
                               int ));

extern int HSreadtexture_type27 __(( FILE *,
                                     short,
                                     short,
                                     int,
                                     unsigned short *));
extern int HSreadtexture_type25 __(( int *,
                                     short,
                                     short,
                                     int ,
                                     unsigned short *));

extern int HSstore_line_type27  __(( int,
                                     int,
                                     unsigned short **,
                                     unsigned short **,
                                     unsigned short **,
                                     int,
                                     int,
                                     int,
                                     unsigned short *));

extern int HSstore_line_type25  __(( int,
                                     int,
                                     unsigned char **,
                                     unsigned char **,
                                     unsigned char **,
                                     int,
                                     int,
                                     int,
                                     unsigned short *));

extern int HSsphmem_man         __(( unsigned short **,
                                     int,
                                     int ));

extern int HSread_line_from_rle27 __(( FILE *,
                                       int *,
                                       int,
                                       unsigned short *,
                                       unsigned short *,
                                       unsigned short *));

/*---HSvm_stats.C--------------------------------------------------------------*/

extern int HSget_vm_stats __(( unsigned long *,
                               unsigned long *,
                               unsigned long *));

/*---XHSbldpctbl.C-------------------------------------------------------------*/

extern void X_build_phys_tbl __(( int,
                                  int,
                                  struct vlt_slot *,
                                  int ));

/*---HSwin_util.C------------------------------------------------------------*/

extern void HSinit_full_screen_window __(( WLuint32  *,
                                           WLuint32  *,
                                           int       *,
                                           int       *,
                                           int         ));

extern void HSdelete_full_screen_window __(( WLuint32 ));

extern int HSconvert_to_indexed_context __(( WLuint32,
                                             OM_S_OBJID,
                                             OMuword ));

extern int HSrestore_window_context __(( WLuint32,
                                         OM_S_OBJID,
                                         OMuword ));

extern void NCget_rgb_from_logical_color __(( IGRuint,
                                              IGRuint *,
                                              IGRuint *,
                                              IGRuint * ));
#if defined(__cplusplus)
}
#endif


#undef __

#include "HSpr_rle_uti.h"

