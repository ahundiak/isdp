#ifndef DPvd_include
#define DPvd_include

/*
** header file for Display View Dynamically
*/

/* defines */
#define DPvd_LEFT_MOUSE	  0
#define DPvd_MIDDLE_MOUSE 1
#define DPvd_RIGHT_MOUSE  2

#define DPvd_UP              0
#define DPvd_DOWN            1
#define DPvd_SINGLE_CLICK    2
#define DPvd_DOUBLE_DOWN     3
#define DPvd_DOUBLE_CLICK    4
#define DPvd_TRIPLE_DOWN     5
#define DPvd_UP_DOWN_UP      6
#define DPvd_UP_DOWN         7
#define DPvd_WINDOW_EVENT    8
#define DPvd_TIMEOUT         999

/* defines for INGR keyboard */
#define KEY_IN_PF1             (unsigned char) 0XF5
#define KEY_IN_PF1_SHIFT       (unsigned char) 0XF6
#define KEY_IN_PF2             (unsigned char) 0XAF
#define KEY_IN_PF2_SHIFT       (unsigned char) 0XF7
#define KEY_IN_PF3             (unsigned char) 0XAA
#define KEY_IN_PF3_SHIFT       (unsigned char) 0XF8

/* defines for DEC3 keyboard mode */
#define KEY_IN_C1             (unsigned char) 0X4e   /* on SUN,SGI F1 */
#define KEY_IN_C2             (unsigned char) 0X50   /* on SUN,SGI F2 */
#define KEY_IN_C3             (unsigned char) 0X52   /* on SUN,SGI F3 */
#define KEY_IN_B2             (unsigned char) 0X30   /* on SUN,SGI SHIFT_F2 */

#define C1              1001
#define C2              1002
#define C3              1003
#define B2              1004

#define PF1		1004
#define PF1_SHIFT	1005
#define PF2		1006
#define PF2_SHIFT	1007
#define PF3		1008
#define PF3_SHIFT	1009
#define NO_BUTTON	1010

#define ROTATE_STATE	1
#define SCALE_STATE	2
#define TRANSL_STATE	3
#define NODYNM_STATE	4

/* command (gnomen) modes */
#define DPvd_STEP   0x00 
#define DPvd_DRAG   0x10
#define DPvd_CONT   0x20 

/* gnomen areas */
/*
#define DPvd_GN_XARROW  0x001
#define DPvd_GN_YARROW  0x002
*/
#define DPvd_GN_XAXIS   0x004
#define DPvd_GN_YAXIS   0x008
#define DPvd_GN_ZAXIS   0x010
#define DPvd_GN_CENTER  0x020
#define DPvd_GN_RUBBER  0x040
#define DPvd_GN_ELEMENT 0x080


#define DPvd_VIEW_DELTA 0.0001
#define DPvd_VIEW_2DELTA 0.0002



struct DPvd_actwin {
   struct GRid grid;      /* osnum and objid of gragad */
   WLuint32    win_no;    /* window number of window   */
   IGRboolean  view_changed; /* TRUE,FALSE: if view changed since this window becomes active window */

   /* IGRint old_event_mask; */
 
} ;

struct DPvd_draw_GN_t 
{
    int draw_flags;   /* gnomen areas */
    struct WLpoint rubber_band[2];
    struct GRid *elem_id;
    struct GRid *gg_id;
    double *elem_tangent;	/* point to wrk's array */
    int first_elem_line;	/* TRUE/FALSE */
    char step_string[20];
};

struct DPvd_wrk_t 
{
    int dyn_state;
    double wld_to_view[16];
    double view_to_wld[16];
    double wld_ref_point[3];
    double locate_pt_type;
    double rotation_axis[3];
    int button, transition;
    int start_x, start_y, x, y, last_x, last_y;
    struct DPgra_gad orig_gg, new_gg;

    double model_center[3], model_radius;

    int selected_axis;
    int rubber_tolerance;
    int new_orig_same, last_new_orig_same;
    int curr_gn_mode;

    struct GRid element_id;
    double element_tangent_vw[3];

    double step_value;
    double speed;
    int limited_zoom;

    int get_model_size_by_fit; /* TRUE: use fit to get model size */
    int got_fitted_size;       /* TRUE: got model size by fit for Curr view */
};



/* the struct save_DPgra_gad contains a copy of all elements
** of struct DPgra_gad, which are needed for restore view
**
** for better reference the complete struct DPgra_gad is copied
** and all unused fields are enclosed in #ifdef UNUSED ... #endif
**
*/
struct save_DPgra_gad {
                /** flags is saved, but only the bit IS_PERS is used **/
                IGRint	  flags;   	   /* view flags       */
#ifdef UNUSED
!		struct    DPfnt_os_tbl *fnt_os_ptr;/* font os ptr      */
!               IGRlong   grid_per_ref_x;          /* # of grid dots
!                                                     between x-axis 
!						      cross  	       */
!		IGRlong	  grid_per_ref_y;	   /* # of grid dots 
!						      between y-axis
!						      cross	       */
!		IGRshort  wld_viewport_type;	   /* world to viewport
!						      matrix type      */
!               IGRshort  display_mode;              /* which type display
!							is to take place */
!
!		IGRint	  levels[32];		   /* levels	       */
!		IGRint	  gpipe_id;
!               IGRdouble uor_per_ref_x;           /* uor value between
!                                                     grid reference
!						      x-axis crosses   */
!               IGRdouble uor_per_ref_y;           /* uor value between
!                                                     grid reference
!						      y-axis crosses   */
#endif
                IGRdouble origin[3];               /* view origin      */
                IGRdouble rotation[4][4];          /* view rotation
                                                      matrix           */
                IGRdouble vw_volume[6];            /* view volume NOTE:
						      stored as 0,1,2
						      minimums & 3,4,5
						      are the maxs     */
                IGRdouble act_z;                   /* active z in viewing
                                                      coordinate system*/
#ifdef UNUSED
!               IGRdouble act_z_screen;            /* active z in screen
!                                                     coordinate       */
!               IGRdouble dit_tol;                 /* dit tolerance    */
!               IGRdouble wld_to_viewport[4][4];   /* world to viewport 
!                                                     transformation
!                                                     matrix           */
!               IGRdouble viewport_to_wld[4][4];   /* viewport to world
!                                                     transformation
!                                                     matrix           */
!               IGRdouble alt_vwport_to_wld[4][4]; /* alternate viewport
!                                                     to world
!                                                     transformation
!                                                     matrix           */
!		IGRdouble construct_plane[4][4];   /* construction
!						      plane matrix     */
!		IGRdouble wld_to_view[4][4];       /* viewport to view
!						      transformation   */
#endif
                IGRdouble dit_clip_range[6];       /* dit clip range in
                                                      screen units relative
						      to the window origin
						      & stored as 0,1,2
						      minimums & 3,4,5
						      are the maximums */
#ifdef UNUSED
!               IGRdouble vvol_viewport_scale;     /* view volume to
!                                                     viewport scale   */
#endif
/**********  Perspective data *****************************************/
		IGRdouble  eye_pt[3];		   /* eye point for 
						      perspective     */
		IGRdouble  coi[3];		  /*  center of interest */
	        IGRdouble  vw_angle;		  /*  view angle       */
		IGRdouble  vrp[3];		  /* view reference point */
		IGRdouble  vpn[3];		  /* view plane normal    */
		IGRdouble  vup[3];		  /* view up vector     */
  /**********************************************************************/
#ifdef UNUSED
!		struct DPrange_check range_chk;	   /* used for range
!						      checking	       */
!
!		struct DPrange_check vv_range_chk; /* used for range
!						      checking	       */
#endif

};


#define ORIG_STORED	(0x1)
#define TEMP_STORED	(0x2)

#define GRMODIFIED 	(0x4)

/*
** struct save_view contains the information for one
** window:
**
**  win_obj           - objectid and osnum of window, for reference
**  stored            - contains flags:
**                      original view stored,             ORIG_STORED
**                      temporary view stored,            TEMP_STORED
**                      view changed (has to be written to journal file)
**                                                        GRMODIFIED
**  orig_gg           - information stored for original view
**  temp_gg           - information stored for temporary view
*/
struct save_view {
  struct GRid win_obj;

  IGRint      stored;    /* Flags: ORIG_STORED - orig_gg stored, 
			           TEMP_STORED - temp_gg stored */

  /* information stored for "original" view */
  struct save_DPgra_gad *orig_gg;
  /* information stored for temporary "marked" view */
  struct save_DPgra_gad *temp_gg;
};

#define DPvd_JNL_START          5551
#define DPvd_JNL_END            5552
#define DPvd_JNL_VIEW           5553
#define DPvd_JNL_MARKED_VIEW    5554


struct jnl_storage {
    struct GRid             grid; 
    struct save_DPgra_gad   gragad;
} ;



    

/* -----  routine headers ------------------------------------------- */



/* DPvd_actwin.I */
extern int DPvd_get_active_window(struct DPvd_actwin *awin);
extern int DPvd_get_active_window_id(int hwwin, struct DPvd_actwin *awin);
extern int DPvd_activate_window(struct GRid *winid, struct DPvd_actwin *awin);

/* DPvd_event.I */
extern int DPvd_get_next_event(int mouse_movement, WLuint32 lwin_no,
			int *button, int *transition, int *x, int *y, 
                        int *hwwin);

/* DPvd_form.I */
extern void DPvd_attach_wrk_to_form(struct DPvd_wrk_t *wrk_p);
extern void DPvd_erase_status_form(void);
extern void DPvd_delete_status_form(void);
extern DPvd_display_status_form(IGRboolean);



/* DPvd_gnomen.I */
extern void DPvd_set_GN_size(int size);
extern int DPvd_get_GN_size(void);
extern void DPvd_draw_GN(struct DPvd_draw_GN_t *draw_info,int clear_first, int use_hilite);
extern void DPvd_draw_GN_center(WLuint32 lwin_no);
extern void DPvd_erase_GN();
extern int DPvd_check_toggle_GN_mode(WLuint32 lwin_no,int x,int y);
extern int DPvd_get_GN_mode(void);
extern int DPvd_check_select_GN_axis(WLuint32 lwin_no,int x,int y);
extern int DPvd_check_set_GN_align_state(WLuint32 lwin_no, int x, int y);
extern int DPvd_get_GN_align_state(void);
extern int DPvd_set_GN_align_state(int align_axis);
extern int DPvd_get_GN_location(WLuint32 *lwin, IGRdouble *loc_vwport, IGRdouble *loc_wld);
extern int DPvd_set_GN_location(WLuint32 lwin, IGRdouble *loc_vwport, IGRdouble *loc_wld);


/* DPvd_mark.I */
extern int DPvd_mark_view(int original, struct GRid *actid, struct save_DPgra_gad *in_save_buf);
extern int DPvd_restore_view(int original, struct GRid *actid);
extern int DPvd_clear_view(int original, struct GRid *actid);
extern int DPvd_mark_changed(struct GRid *actid);
extern int DPvd_jnl_view_changed();
extern int DPvd_jnl_playback();
extern void DPvd_jnl_mark_start();
extern void DPvd_jnl_mark_end();
extern void DPvd_jnl_mark_view(IGRint original,  struct GRid *actid);
extern void DPvd_jnl_save_changed();
extern void DPvd_get_rng_radius_center(IGRdouble *pts, IGRdouble *radius, IGRdouble *center);
extern int DPvd_fit_model_range(struct GRid *p_gg, struct DPgra_gad *p_gragad,
				int win_no, IGRdouble *rng );

/* DPvd_select.I */
extern int DPvd_locate_element(struct DPvd_actwin *actwin, struct DPvd_wrk_t *wrk,
        int *response, char *response_data);

/* DPvd_transf.I */
extern int DPvd_change_view(struct DPvd_actwin *actwin, struct DPvd_wrk_t *wrk);
extern int DPvd_align_view(struct DPvd_actwin *actwin,struct DPvd_wrk_t *wrk);

#endif
