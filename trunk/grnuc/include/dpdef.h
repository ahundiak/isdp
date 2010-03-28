#ifndef dpdef_include
#define dpdef_include
#include   "dperr.h"
         
#define DPMAX_STACK    40
#define DPSTACK_LEN     5
#define DISPLAY_BUF_SIZE 8*1024
#define PUSH          1
#define POP           2
#define CLEAR         3
#define REPLACE       4
#define CONCAT_PUSH   5
#define CONCAT_REPL   6
#define PRINT         7
         
#define DEF_UOR_PER_REF 1.000000e+02
#define DEF_GRID_PER_REF 10
#define MIN_GRID_DELTA   7
#define MIN_REF_DELTA    16

#define VVOLSMALLEST 0.0001         

#define dpceiling(x) ((((int)(x)) >= (x))?(int)(x):(int)(x) + 1)
#define dpround(x)  (   dpceiling ( (x) - 0.5 )    )

#define END_PARAM    -1

#define GRAGAD_NAME    1        /* graphics gadget's name     */
#define WIN_NO         2        /* window number              */
#define GRAGAD_DEP     3        /* gragad working area in 
				   screen units 	      */
#define GRAGAD_INDEP   4        /* gragad working area as 
				    percentages of the screen */
#define GRAGAD_FLAGS   5        /* gragad flags - If you are 
				inquiring the flags, you only
				need to pass an int.  If you're
setting the flags, then you should pass an array of two ints.
The first int should have bits set to indicate which flags you 
wish to influence.  The second int should the bits for the flags
that you wish to influence either set or off.  EXAMPLE:  If you 
want to set the IS_ACTIVE bit and turn the GRID_ON bit off, 
first_int = IS_ACTIVE | GRID_ON and second_int = IS_ACTIVE.   */

#define FONT_OS_PTR    6	/* font object space table    */
				/* pointer                    */
#define GRID_PER_REF_X 7	/* # of grid dots between 
				   x_axis cross		      */
#define GRID_PER_REF_Y 8	/* # of grid dots between 
				   y_axis cross		      */
#define VIEW_ORIGIN    9        /* view origin                */
#define VIEW_ROTATION 10        /* IGR standard view          */
                                /* rotation matrix            */
#define POST_ROTATION 11        /* post rotation matrix       */
#define VW_VOLUME     12        /* view volume                */
#define ACT_Z         13        /* active z in viewing        */
                                /* coordinate system          */
#define ACT_Z_SCREEN  14        /* active z in screen         */
                                /* coordinates                */
#define DIT_TOL       15        /* dit tolerance              */
#define WLD_TO_VIEWPORT 16      /* world to viewport          */
                                /* transformation matrix      */
#define VIEWPORT_TO_WLD     17  /* viewport to world          */
                                /* transformation matrix      */
#define ALT_VIEWPORT_TO_WLD 18  /* alternate viewport to      */
                                /* world transformation,      */
                                /* which may be used by       */
                                /* alternate coordinate system*/
#define WLD_TO_VIEW         19  /* wld to view                */
				/* transformation matrix      */
#define DIT_CLIP_RANGE      20  /* dit clip range in screen   */
                                /* unit                       */
#define VVOL_VIEWPORT_SCALE 21  /* view volume to viewport    */
                                /* scale                      */
#define WLD_VIEWPORT_TYPE   22  /* world to viewport matrix   */
				/* type			      */         
#define RANGE_CHK	    23  /* range check		      */
#define GRAGAD_STRUCT	    24  /* DPgragad structure 	      */
#define CONSTRUCT_PLANE     25  /* construction plane matrix   */
#define VW_ROT_NO_CON	    26  /* the view's rotation only. It 
				   is not dependent upon whether
				   the construction plane is on
				   or not.			*/
#define UOR_PER_REF_X	    27  /* uor value between grid reference
				   x_axis crosses		*/
#define UOR_PER_REF_Y	    28  /* uor value between grid reference
				   y-axis crosses		*/  	    
#define GRAGAD_INST_STRUCT  29  /* structure containing all of 
				   a graphics gadget's instance 
				   data				*/
#define DISPLAY_MODE	    30 
#define GPIPE_ID	    31
#define WLD_VOLUME	    32	/* the view volume in world coordinates */
#define SAV_VW_NAME	    35  /* saved view name		*/

#define SAV_VW_FLAGS	    36  /* saved view flags		*/

#define SAV_VW_STRUCT	    37  /* saved view structure		*/

#define DESCRIPT	    38  /* description of saved view    */
#define WLD_ACT_Z	    39  /* the active z in world coord. */
#define WLD_DISPLAY_DEPTHS  40  /* the display depths in "" ""  */
#define VIEW_PLANE	    41  /* the view plane		*/
#define LEVELS		    45  /* levels			*/
#define VRP		    46  /* view reference point		*/
#define VPN		    47  /* view plane normal		*/
#define VUP		    48  /* view up vector		*/
#define VIEW_ANGLE	    49  /* view angle			*/
#define COI		    50  /* center of interest		*/
#define EYE_PT		    51  /* eye point			*/
#define WLD_ACT_Z_PNT	    52
#define WLD_ACT_Z_VAL	    53
#define SIZE_DESCRIPT	    54
#define CONSTRUCT_PL_ORG    55  /* construction plane origin */
#define VIEW_TYPE	    56 /* this will return the view type of either
				gragad or saved view */
#define PERSP_SCALING       57 /* perspective scaling - array of 3 - x,y,z */

/* types returned in the int for inquires VIEW_TYPE */

#define TYPE_GRAGAD	0x00000001
#define TYPE_SAVVW	0x00000002

/* #defines for the rotate method */

#define ORIGIN_CENTER 0x0001
#define REPLACE_MTX   0x0002
#define LEFT_MULT     0x0004
#define RIGHT_MULT    0x0008

/* #defines for dp$viewvol */


#define WORLD_COOR 	0x0001
#define SETIN	   	0x0002
#define VIEW_COOR  	0x0004
/* left open for clips */
#define ACTIVE_Z_MIDDLE 0x0040
#define ACTIVE_Z_EDGE   0x0080
#define ACT_Z_FRONT     0x0100
#define ACT_Z_BACK      0x0200
#define NONABS_DD1	0x0400
#define NONABS_DD2	0x0800
#define NONABS_Z	0x1000



#define DP_STD_DEFAULTS 0x0001
#define DP_SET		0x0002
#define DP_FIR_PERSP	0x0004
#define DP_CVT_WN_ONLY  0x0008
#define DP_NOT_PERSP	0x0010
#define DP_FIT_VOL	0x0020
#define DP_NOFIT_Z	0x0040
#define DP_NOFIT_X	0x0080
#define DP_NOFIT_Y	0x0100
#define DP_STD_DEF_PSP  0x0200


/*  #define for graphic gadget flags    */

#define	IS_ACTIVE		0x00000001 /* View active flag  */
#define	IS_PERSP		0x00000002 /* perspective flag  */
#define	AXIS_WLD_ALIGN		0x00000004 /* vw axis aligned 
					      with wld axis     */
#define	CLIP			0x00000008 /* is rectang. clip
					      active		*/
#define	FRONT_CLIP		0x00000010 /* if front clip 
					      active		*/
#define	BACK_CLIP		0x00000020 /* is back clip 
					      active		*/
#define	GRID_ON			0x00000040 /* grid display
					      1 = on, 0 = off	*/
#define	GRID_LOCK		0x00000080 /* grid lock	
					      1 = on, 0 = off	*/
#define CONST_PL_DEF		0x00000100 /* construct plane 
					      defined		*/
#define	CONST_PLANE_ON		0x00000200 /* construction plane
					      1 - on and used for
					      pt. conversion when
					      valid
					      0 = off		*/    
#define	VALID_ALT_INV		0x00000400 /* is the const. plane's
					      alt. inv. vwport to
					      world matrix valid*/
#define	IS_WIN_ON		0x00000800 /* is window on	*/
#define DP_DELAY			0x00001000 /* set if delay is on */
#define DPLEFT_SCREEN		0x00002000 /* gragad is on left screen */
#define DP_NO_RULE_LINES	0x00004000 /* Rule lines are not displayed */
#define DP_GROUND_PLANE		0x00008000 /* set if ground plane is to be displayed */
#define DPVIEW_DYNAMICS		0x80000000 /* update for view dynamics */

/*********************/


/* #defines for flag in dp$get_gragad_id and DPgetggid and DPcolwin  */

#define ALL_TYPES	0x00000001
#define HIDDENLN_GG	0x00000002
#define IGE_GG		0x00000004
#define ALL_GG_CLASSES  0x00000006 /* this is a commbination of hidden
line and ige gragad */
#define ACTIVE_GG	0x00000008
#define INACTIVE_GG	0x00000010
#define GG_WIN_ON	0x00000020
#define GG_WIN_OFF	0x00000040
#define DELAY_GG	0x00000080
#define NO_DELAY_GG	0x00000100

/* #defines for DPcvtpersp method */

#define DP_CVT_TO_PERSP  0x00000001
#define DP_CVT_TO_PARAL  0x00000002
#define DP_CAL		 0x00000004
#define DP_CVT_UPDATE    0x00000008

/*  for dp$dynamics  */

#define DP_IGN_INV_PNT		0x00000001
#define DP_CUR_NOT_CHG		0x00000002
#define DP_ACTUAL_CURSOR	0x00000004
#define DP_OUTSIDE_WINDOW	0x00000008
#define DP_NO_CURSOR		0x00000010
#define DP_AUTO_DYN		0x00000020
#define DP_USE_WIN_FLAG		0x00000040
#define DP_ALL_WINDOWS		0x00000080
#define DP_EXIT_ON_ANY_INPUT	0x80000000

/*  for first out dummy in the dyn_fun that dynamics calls  */

#define DP_NEW_POINT		0x00000001
#define	DP_DYN_NOT_OK		0x00000002
#define	DP_WN_BUFFER		0x00000004
#define DP_DONT_ERASE		0x00000008
#define DP_VIEW_IND_BUF		0x00000010

/*  for first dummy in the dyn_fun that dynamics calls  */

#define DP_INVALID_POINT	0x00000001


#define DP_EXIT_DYNAMICS	0x05101986

/*  design file limits  */

#define	IGE_DESIGN_LIMITS_MIN	-10000000000.0
#define	IGE_DESIGN_LIMITS_MAX	 10000000000.0

#define DP_NUM_OF_LEVELS	1024
#define DPLVLDIR_MAX_NAME_SIZE  50

#define  DP_INVISIBLE_COLOR	0xffff 
#define  DPGRID_COLOR		0xfffe

/* text stroker information  */

#define ESCAPE_TYPE		1
#define LINEFEED_TYPE		2
#define CHAR_TYPE		3
#define ESCAPE			0x1b
#define	LINE_FEED		0x0a

#define FAST_CHAR_FONT		0x00000001
#define FAST_FRAC_FONT		0x00000002
#define FAST_16BIT_FONT		0x00000004

/* For saved view recall */

#define DP_UPDATE	0x00000001

/* for view dynamics  */

#define	ZOOM_IN		1
#define	ZOOM_OUT	2
#define PAN		3
#define ROTATE		4
#define CHANGE_STATE	5
#define WAIT		6
#define BACKUP		7
#define DP_EXIT		8



/* defines for view independence */

#define	ROTATION_IND		0
#define SCALE_IND		1
#define ROTATION_SCALE_IND	2

/* display flags */

#define	DPPOLY_FILL		0x0001

/* save view construct macro defines */

#define GG_STRUCT	1
#define GGI_STRUCT	2
#define SV_STRUCT	4

/* for perspective */

#define DEF_VWANGLE 1.047197551

/* For DPalignper and DPwld_to_vw */

#define DPRIGHT_VIEW	0x00000001
#define DPLEFT_VIEW	0x00000002
#define DPRIGHT_ROT	0x00000004
#define DPLEFT_ROT	0x00000008

/* For dp$find_defaultvw */
#define DPCONST_VW 	0x00000002

/* For DP$get_gragad_id and DPget_saved_vw_id */

/* this includes all graphic gadgets and all saved views */
#define GRDP_VIEWS	"views"
#define GRDP_VIEWSS	"views:*"
/* this includes all graphic gadgets */
#define GRDP_REGVIEWS	"regviews"
/* more complete path for the above */
#define GRDP_REGVWS     "views:regviews:*"

/* this includes only  "our" graphic gadgets i.e. not hidden surface etc. */
#define GRDP_GRVIEWS	"GRviews"

/* this includes all saved views */
#define GRDP_SAVEDVIEWS "savedviews"
#define GRDP_SAVVWS "views:savedviews:*"
/* this includes only "our" saved views i.e. not hidden surface etc. */
#define GRDP_GRSAVEDVIEWS "GRsavedviews"

/* defines for add view name */
#define DPCHG_VW_NAME 1
#define DP_PROTECTION 2

/* flags for view dynamics  */

#define DPWIREFRAME_FRAME	0

#define DPVIEW_IND	1

#define DPFORWARD	0
#define DPBACKWARD	1
#define DPOSCILATING	2
#define DPALL_FRAMES	-1
#define DPADD_TO_END	-1
#define DPLAST_FRAME	-2
#define DPUNLIMITED_CYCLES	-1
#define DPFRAME_PTRS_BLOCK_SIZE	100
#define DPMAX_FRAME_SIZE	1024*2000
#define DPFB_BUF_SIZE		100000


#define DPDEF_ZOOM_FACTOR	1.03125
#define DPDEF_PAN_FACTOR	0.1
#define DPDEF_MAX_ROTATE_FACTOR	3.14/6.0


#define DPFRAMELINK		1024

#define DPSOLID_PATTERN		0
#define DPSEMISOLID_PATTERN	1

#define DP_SOLID_LINE_STYLE	0
#define DP_DASHED_LINE_STYLE	1

#endif
