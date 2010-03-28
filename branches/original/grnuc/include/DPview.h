


#ifndef DPview_h
#define DPview_h

#define DP_FUNC_SUCC	0	/* function return, same as C */
#define DP_FUNC_FAIL	1	/* function return, same as C */
#define DP_MTHD_SUCC	1	/* method return, same as OM */
#define DP_MTHD_FAIL	0	/* method return, same as OM */

#define PI		3.1415927

#define MAX_WIN		20	/* windows[] array length */

/* define for wrk_p->phase_state */

#define DP_DYN_END	901	/* this dyn phase ended completely */
#define DP_DYN_CON	902	/* this dyn phase is continuing    */
#define DP_DYN_ABORT    903	/* this dyn phase is abort, (right button) */
#define DP_DYN_OUTSIDE_DATA 904 /* will get next data outside this dyn phase */

#define RUB_LINE	2001
#define DP_DRAW		0

#define DP_VIEW_CMD_END 102	/* this cmd object is dead */

#define DP_VIEW_END	701
#define DP_SYS_ERR 	-1


#define MAX_DOUBLE	1000000000000.0  /* used to prevent overflow in auto mode */
#define INV_MAX_DOUBLE  0.0000000000001  /* 1.0/MAX_DOUBLE */
#define MAX_ZOOM_FACTOR	10               /* max zoom factor */
#define INV_MAX_ZOOM_FACTOR   0.1        /* 1.0/MAX_ZOOM_FACTOR */
#define DISPLAY_DELTA   0.0001           /* the smallest dist between eye and near */
#define MIN_EYE_COI	0.0002	         /* min distance between eye coi */
#define MIN_ANGLE 	0.001	         /* considered 0 if less than this */


/* cmd_type */

#define NOT_CMD 	0
#define DP_ZOOM		10
#define DP_AROUND_COI   11
#define DP_AROUND_EYE   12
#define DP_PAN		13
#define DP_WIN_AREA	14
#define DP_MV_EYE_TAR   15
#define DP_TILT		16
#define DP_VWANGLE	17
#define DP_LOAD_DYN	18
#define DP_UNLOAD_DYN	19

/* in_flags for IDcal_xxx() */

#define EN_AUTO 	0x00000001	/* consider auto case in DPcal_xxx() */
#define EN_INDEXING	0x00000002	/* consider indexing in DPcal_xxx() */



/* #define for DPmveyetar.sl */


#define  INVALID_WIN    4
#define TOO_CLOSE	1
#define MOVE_EYE 	2
#define MOVE_TAR 	3

/* #define for indexing */

#define NUM_FOCAL_INDEX	20	/* number of focal indexing slots */

/* for wrk_p->idx_flag */

#define CURSOR_INDEXED	0x00000001	/* cursor indexing happened */
#define VIEW_XY_INDEXED 0x00000010	/* view indexing happened */
#define VIEW_XZ_INDEXED 0x00000020	/* view indexing happened */
#define VIEW_YZ_INDEXED 0x00000040	/* view indexing happened */
#define VIEW_XYZ_INDEXED 0x00000080	/* view indexing happened */
#define LEVEL_HRZN_INDEXED 0x00000100  /* level horizon indexing happened */
#define FOCAL_INDEXED	0x00000200	/* focal length indexing happend */

/* for form DPvieww */

#define DYNAMICS_TGL	25	/* want real dynamics or not */
#define CLIP_ON_TGL	24
#define TARGET_LOCK_TXT 15
#define TARGET_LOCK_TGL	22
#define ANGLE_ZOOM_TXT	14	/* "eye point" text */
#define ANGLE_ZOOM_TGL  21  	/* eye lock */
#define INDEX_ON_TGL	23
#define ANGLE_TXT	26	/* only for change persp. view angle command */
#define ANGLE_FLD	28	
#define AUTO_MOVE_TGL	20	/* continuous/drag */
#define AUTO_LOAD_TGL	19	/* manual/auto load */

/* on/off  */

#define ON		1
#define OFF		0

#define IGEFRAME	0
#define HSFRAME		1


/*
 * pyrmd_clip[0] is the front plane, pyrmd_clip[1] is the back plane 
 * pyrmd_lines[0] is the center line, from eye to coi
 */
struct DPpyramid_t 
{
   struct DPele_header elements[7];       /* one pyramid has 7 parts */
   struct IGRpolyline  lines[5];	  /* 5 lines in the pyrmd */
   IGRdouble	       lines_pts[5][6];   /* 2 points for each of the 5 line */
   struct IGRpolyline  planes[2];         /* front and back clip planes */
   IGRdouble	       planes_pts[2][15]; /* 5 points for each of the 2 plane */
   struct IGRdisplay   dis_att;	   	  /* for this pyramid */

   IGRdouble 	      *p_lines[14];	  /* pointer to each lines */
};


struct DPview_wrk_t
{
   IGRint		cmd_type;	   /* current command */
   IGRint		cmd_type2;	   /* sub command */
   IGRint		phase_state;	   /* state of one dyn phase */
   IGRlong		time_leaving;	   /* the time stamp when sleep */

   struct IGRdisplay    dis_att;	   /* for this rubber line */
   IGRint		x0,y0;		   /* 1st pnt of rubline on window (in dit) */
   IGRint		prev_x,prev_y;     /* (in dynamics) Mouse's prev */
					   /* position. Used to check if mouse*/
					   /* is moved */
   IGRint               cursor_axis_lock;  /* 1-X direciton, 2-Y direction, 0-initial, no lock */

   IGRdouble		ratio_x, ratio_y;  /* tmp var, used to accumulate values for auto mode */

   struct GRid	       	windows[MAX_WIN];   /* all the windows */
   IGRint		gpipe_id[MAX_WIN];  /* gpipe */
   IGRint		winflags[MAX_WIN];  /* original windows flags saved */
   IGRint		win_no[MAX_WIN];
   IGRdouble		win_dit_rng[MAX_WIN][6];
   IGRdouble		win_act_z_screen[MAX_WIN];
   IGRdouble		win_viewport_to_wld[MAX_WIN][16];
   IGRdouble		win_wld_to_viewport[MAX_WIN][16];
   IGRint	       	num_wins;	    /* # of windows in the above array */
    IGRint	       	curr_win;           /* the current working window */


   /* working (tmp) gragad var's */

   IGRint	flags;		/* gragad flags */
   IGRdouble	eye_pt[3],
	   	origin[3],
   		coi[3],
  		vpn[3],
		vup[3],
		vw_volume[6],
		vw_angle;
   IGRdouble	act_z;
   IGRdouble	eye_pt_vw[3],	   	/* eye point in VCS */
		coi_vw[3];		/* coi point in VCS */
   IGRdouble    abs_up[3];
   IGRdouble	tilt_angle;		/* counter clock wise */

   IGRdouble    rotation[16];
   IGRdouble    wld_to_view[16];
   IGRdouble    view_to_wld[16];

   IGRdouble    tan_x,tan_y;

   /* for indexing degrees ( cosin(angle) ) */

   IGRdouble	idx_view_tol;		/* for Orthogonal view indexing */
   IGRdouble 	idx_cursor_tol;	 	/* tan(),for Orthogonal cursor indexing */
   IGRdouble 	idx_horizon_tol;	/* for Level horizon indexing */
   IGRdouble 	idx_angle_tol;		/* for Focal length indexing  */
   IGRdouble	idx_angle[NUM_FOCAL_INDEX];  /* each Focal index, ordered increasingly */
   IGRint	idx_len[NUM_FOCAL_INDEX];  /* corresponding lenght (mm) */

   IGRint	idx_flag;		/* which indexing happened */

   /* form toggle status */

   Form    view_form;
   IGRint  s_clipping;	     /* 1 --- ON, 0 -- OFF */
   IGRint  s_target_locked;
   IGRint  s_angle_zoom; 
   IGRint  s_indexing;
   IGRint  s_auto;	     /* automatic moving */
   IGRint  s_real_dyn;       /* real dynamics flag: OFF means NOT real dynamics */ 
   IGRint  s_auto_load;	     /* is auto loading dynmics */
 
   /* frames loaded information */

   IGRint  win_class; 		/* IGEFRAME, HSFRAME */

   struct frame_ld_info 	/* !! This var should be reset when changing design file */
   {
	IGRint levels[32];	/* which levels were loaded */
   	IGRint frame_loaded;	/* TRUE or FALSE, should test before "out_of_date" */
	IGRint out_of_date;	/* TRUE -- at the begining of a view cmd group */
   } frame_info[2];		/* IGEFRAME, HSFRAME */

   /* hilite plane dynamics on/off */

   IGRboolean hi_dyn_on;	/* affected by the dyn on/off command on the BAR_MENU */

   IGRint	tmp_int;	   /* tmp var, usage depends on command */
  
};


struct DPbase_gg_t
{
   struct DPgra_gad gg;	/* original gragad, some value modified when DPget_base() */

   IGRdouble    abs_up[3];  /* body's up direction. different from head's up direction -- vup */  

   IGRdouble	scrn_width,scrn_length; /* current screen window width, and length */
   IGRdouble	tan_x,tan_y;		/* tan of the x-, y- angle */

   IGRdouble	coi_vw[3];		/* in VCS1 */
   IGRdouble    view_to_wld[16];
   IGRdouble    inv_rotation[16];

   IGRdouble	vup_v[3];	/* vup or proj of vup in the coord. sys.: */
				/* z -- eye to coi, y -- proj of abs_up; RIGHT hand */

};


struct func_parm_t			/* used for DPdyn_func() */
{
    struct DPbase_gg_t    *base_p;
    struct DPpyramid_t    *pyrmd_p;
    struct DPview_wrk_t   *wrk_p;
};

#endif
