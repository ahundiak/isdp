/* $RCSfile: tools.h,v $$Revision: 1.1.1.1 $$Date: 2001/12/17 22:40:15 $ Copyright (c) 1990 Intergraph Corp. */

/* Tools library include file */
#ifndef TOOLS_H
#define TOOLS_H
/* Event Definitions */

#define	KEYBOARD_EVENT		0x00000001
#define	BUTTON_EVENT		0x00000002
#define REFRESH_EVENT		0x00000004
#define DELETE_EVENT		0x00000008
#define	COVER_EVENT		0x00000010
#define	KEYIN_EVENT		0x00000020
#define	MENUBAR_EVENT		0x00000040
#define	PTTY_EVENT		0x00000080
#define	AUX_EVENT		0x00000200
#define COLLAPSE_EVENT		0x00000400
#define	PROCESS_EVENT		0x00000800
#define	TIMER_EVENT		0x00001000
#define	WINDOW_ICON_EVENT	0x00002000
#define	WINDOW_USER_ICON_EVENT	0x00002000
#define	USER_EVENT		0x00004000
#define	SYSTEM_EVENT		0x00008000
#define MOTION_EVENT		0x00010000
#define DIGMOTION_EVENT		0x00020000
#define SWAPVS_EVENT		0x00040000
#define	EXTRA_EVENT		0x80000000

/* Buttons */

#define		LEFT_BUTTON	0		/* left button */
#define		MIDDLE_BUTTON	1		/* middle button */
#define		RIGHT_BUTTON	2		/* right button */

/* Button types */

#define		UP		0		/* up		*/
#define		DOWN		1		/* down		*/
#define		SINGLE_CLICK	2		/* click	*/
#define		DOUBLE_DOWN	3		/* double down	*/
#define		DOUBLE_CLICK	4		/* double click	*/
#define		TRIPLE_DOWN	5		/* triple down	*/
#define		UP_DOWN_UP	6		/* up down up	*/
#define		UP_DOWN		7		/* up down	*/

#define		TIMEOUT		999		/* timeout	*/

/* button modes */

#define	BUTTON_MODE_ALL	0	/* allow all transitions, except TIMEOUT */
#define	BUTTON_MODE_UDS	1	/* allow UP, DOWN, SINGLE_CLICK	transitions */
#define	BUTTON_MODE_UDT	2	/* allow UP, DOWN, TIMEOUT transitions */
#define	BUTTON_MODE_UD	3	/* allow UP AND DOWN transtions */

#ifndef MOTION_FLAGS
#define MOTION_FLAGS

/* Motion Setup Flags */
#define MS_ENTER	0x00000001
#define MS_EXIT		0x00000002
#define MS_MOTION	0x00000004
#define MS_WORKING_AREA	0x00008000

/* Digitizer Region Setup Flags */
#define DS_ENTER	0x00000100
#define DS_EXIT		0x00000200
#define DS_MOTION	0x00000400

/* Motion Event Flags */
#define	ME_ENTER	0x00000001
#define	ME_EXIT		0x00000002
#define	ME_MOTION	0x00000004

/* Digitizer Region Motion Events */
#define DE_ENTER	0x00000010
#define DE_EXIT		0x00000020
#define DE_MOTION	0x00000040

#endif

/* Pull Down Entry Types   */

#define		EN_TEXT		0x01		/* text in this entry */
#define		EN_TITLE	0x02		/* title of entry unit */
#define		EN_SUB		0x04		/* sub entry */
#define		EN_DISABLE	0x08		/* disable select of entry */
#define		EN_LAST		0x80000000	/* last entry in list */

/*  Dimensions of raster borders */

#define		MAX_SCREEN_WIDTH	1184
#define		MAX_SCREEN_HEIGHT	884

#define		MESSAGE_STRIP_HEIGHT	54
#define		MENUBAR_HEIGHT		27

#define		COLLAPSED_WIN_WIDTH	204
#define		COLLAPSED_WIN_HEIGHT	33
#define		WINDOW_TOP_BORDER	32
#define		WINDOW_BOTTOM_BORDER	5
#define		WINDOW_RIGHT_BORDER	5
#define		WINDOW_LEFT_BORDER	5

#define		AUX_MAX_COUNT		5
#define		PTTY_MAX_COUNT		5
#define		TIMER_MAX_COUNT		5

/* Window Level constants						*/

#define	LEVEL_HIGH_PRIORITY		32767
#define	LEVEL_NORMAL_PRIORITY		0
#define	LEVEL_LOW_PRIORITY		-32768

/* Window refresh conditions, see also "Refresh Event(3T)"		*/

#define		WN_WAS_COVERED			0x0001
#define		WN_IS_COVERED			0x0002
#define		WN_WAS_OFF_SCREEN		0x0004
#define		WN_IS_OFF_SCREEN		0x0008
#define		WN_CHANGED_POSITION		0x0010
#define		WN_CHANGED_SIZE			0x0020
#define		WN_CHANGED_VS			0x0040
#define		WN_ICON_REFRESH			0x0080
#define		WN_UNCOLLAPSED			0x0100

#define		wn_was_covered(mask)		(mask & WN_WAS_COVERED)
#define		wn_is_covered(mask)		(mask & WN_IS_COVERED)
#define		wn_was_off_screen(mask)		(mask & WN_WAS_OFF_SCREEN)
#define		wn_is_off_screen(mask)		(mask & WN_IS_OFF_SCREEN)
#define		wn_changed_position(mask)	(mask & WN_CHANGED_POSITION)
#define		wn_changed_size(mask)		(mask & WN_CHANGED_SIZE)
#define		wn_changed_vs(mask)		(mask & WN_CHANGED_VS)
#define		wn_icon_refresh(mask)		(mask & WN_ICON_REFRESH)
#define		wn_uncollapsed(mask)		(mask & WN_UNCOLLAPSED)
/* Window Icon constants 						*/

#define	USER_ICON		0	/* defines icon as user icon	*/
#define	SYSTEM_ICON		1	/* defines icon as system icon	*/

#define	LEFT_SIDE_ICON		0	/* defines icon on left side	*/
#define	RIGHT_SIDE_ICON		1	/* defines icon on right side	*/

/* Window "System Icon" values						*/

#define DELETE_ICON_VALUE	1
#define MODIFY_ICON_VALUE	2
#define REFRESH_ICON_VALUE	3
#define POPTOP_ICON_VALUE	4
#define POPBTM_ICON_VALUE	5
#define COLPSE_ICON_VALUE	6

/* Window and region constants */

#define	MAX_WINDOW	40
#define	MAX_REGION	20

/* keyin character types */

#define NOP_CHAR	0x0001
#define TRAN_CHAR	0x0002
#define DEL_CHAR	0x0004
#define TERM_CHAR	0x0008
#define LEFT_CHAR	0x0010
#define RIGHT_CHAR	0x0020
#define SOL_CHAR	0x0040
#define EOL_CHAR	0x0080
#define LIT_CHAR	0x0100
#define ONE_CHAR	0x0200
#define DELC_CHAR	0x0400
#define DELL_CHAR	0x0800

/* Justification definitions */

#define	CENTER	1
#define RIGHT	2
#define LEFT	3

/* Device types of digitizer */

#define DIGITIZER		0
#define FLOATING_MENU_TABLET	1

/* Structure definition used during stream digitizing */
struct	strm_dig_sample 
{
	int	timetag;
	int	x, y;
};

/* for hardware-independent vlt's in Readvlt/Loadvlt/Read_SR_vlt/Load_SR_vlt */
struct vlt_slot
{
	unsigned short v_slot;
	unsigned short v_red; 		/* max = 0xffff */
	unsigned short v_green;		/* max = 0xffff */
	unsigned short v_blue; 		/* max = 0xffff */
};

/* #includes necessary for Inq_vlt_info routine */

#define	VLTI_DB_ABILITY		0x0001

struct vlt_info
{
	unsigned short 	vlti_vlt_start;
	unsigned short	vlti_vlt_size;
	unsigned char	vlti_max_alloc_vlts;
	unsigned short	vlti_num_planes;
	unsigned short	vlti_num_bytes_per_pixel;
	unsigned short  vlti_flags;
	unsigned int	pad[10];
};


struct rgb_color
{
    unsigned short	red;
    unsigned short	green;
    unsigned short	blue;
};

/* #includes necessary for Inq_screen_info routine */

#define VSI_DB_ABILITY			0x00000001
#define VSI_VIRTUAL_SCREEN		0x00000002
#define VSI_ZB_ABILITY			0x00000004
#define VSI_VLT_FIXED			0x00000008
#define VSI_SR_VLT_ABILITY		0x00000010
#define VSI_LEFT_SCREEN			0x00000020
#define VSI_HL				0x00000040
#define VSI_32_ZB_ABILITY		VSI_ZB_ABILITY
#define VSI_24_ZB_ABILITY		0x00000080
#define	VSI_TRC_ABILITY			0x00000100
#define	VSI_PTC_ABILITY			0x00000200
#define	VSI_MULTIPLE_VLT_ABILITY	0x00000400
#define	VSI_OVERLAY_ABILITY		0x00000800
#define VSI_CURSOR_COLOR		0x00001000
#define VSI_STEREO_ABILITY		0x00002000

#define MAX_SCREENS		8
#define vsi_screen_num		vsi_0	/* physical screen it resides on */
#define vsi_num_planes		vsi_1	/* number of planes available */
#define vsi_plane_mask		vsi_2	/* physical plane mask of screen */
#define vsi_vlt_size		vsi_3	/* vsi_VLT_size tells the truth */
#define vsi_DAC_size		vsi_4	/* number of bits per primary color */
#define vsi_fixed_vlt_size	vsi_5	/* number of slots fixed by tools */
#define vsi_fixed_vlt_start	vsi_6	/* starting slot number of fixed vlt */
#define vsi_x			vsi_7	/* xy size of screen in dits */ 
#define vsi_y			vsi_8
#define	vsi_flags		vsi_9	/* set of generic booleans */
#define vsi_VLT_size		vsi_10	/* number of vlt slots available */
#define	vsi_SR_max_planes	vsi_11	/* max number of planes for SR ops */

struct scr_info
{	long vsi_0, vsi_1, vsi_2, vsi_3, vsi_4, vsi_5, vsi_6, vsi_7,
	     vsi_8, vsi_9, vsi_10,vsi_11,vsi_12,vsi_13,vsi_14,vsi_15,
	     vsi_16,vsi_17,vsi_18,vsi_19,vsi_20,vsi_21,vsi_22,vsi_23,
	     vsi_24;
};

/*   File based menu select area information.   */

struct fmn_select_area
{
	int sel_type;			/* selection area types */
				        /* -1=button select only */
				        /* 0=key input area */
					/* 1=output area only */
					/* 2=keyin,output area */
					/* 3=disable selection */
	short xlo,ylo;			/* select area upper left and */
	short xhi,yhi;			/* lower right corners */
	char cmd[128];			/* command string for this area */
};
	

/* digitizer types and subtypes, used for Inq_dig_system */

#define DT_INGR 	0
#define DT_INGR_300	1
#define DT_KURTA	2

#define DST_KURTA_4_BUTTON 	0
#define DST_KURTA_12_BUTTON 	1
#define DST_KURTA_STYLUS	2

/* (x,y) vertex types */
#define	VERT_DOUBLE			(0 << 1)
#define	VERT_FLOAT			(1 << 1)
#define	VERT_LONG			(2 << 1)
#define VERT_SHORT			(3 << 1)

/* linestring continuation flag */
#define LINESTR_CONT			0x8

/* fillpoly, fillpolyset constants */
#define POLY_FUNC_DP_TRAP		(0 << 4)
#define	POLY_FUNC_INT_TRAP		(1 << 4)
#define	POLY_FUNC_SCAN			(2 << 4)
#define	POLY_DECOMPOSE_IN_X		0x1

/* ALU operations */
#define	ALUand				0	/* dst = src AND dst */
#define	ALUandNOT			1	/* dst = src AND (NOT dst) */
#define	ALUxor				2	/* dst = src XOR dst */
#define	ALUor				3	/* dst = src OR dst */
#define	ALUinvert			4	/* dst = NOT dst */
#define	ALUorNOT			5	/* dst = src OR (NOT dst) */
#define	ALUcopy				6	/* dst = src */

/* Keyboard modes */
#define KEYBD_INGR_MODE		0x00
#define KEYBD_INGR_UPDOWN_MODE	0x01
#define KEYBD_DEC_MODE		0x02	/* look for user preference */
#define KEYBD_DEC_3AND2KEY_MODE	0x04
#define KEYBD_DEC_APPL_KEYPAD_MODE	0x08
#define KEYBD_DEC_3KEY_MODE	0x10

/*  Qualifier flags  */
#define KB_KEY_CAPSLOCK		0x01
#define KB_KEY_ALT		0x02
#define KB_KEY_CONTROL		0x04
#define KB_KEY_SHIFT		0x08

/* VLT types */
#define INDEXED_COLOR_VLT	0
#define PSEUDO_TRUE_COLOR_VLT	1
#define TRUE_COLOR_VLT		2
#define	OVERLAY_VLT		3
#define HIGHLIGHT_VLT		4

/* General raster data types */
#define	IMAGE_DATA		0
#define	OVERLAY_DATA		1
#define HIGHLIGHT_DATA		2

/* Raster data types for image data */
#define	INDEXED_COLOR_DATA	3
#define	PSEUDO_TRUE_COLOR_DATA	4
#define TRUE_COLOR_DATA		5

#define READSCREEN_RGB		0
#define READSCREEN_INDEXED	1

/* used by Error_box() to indicate message type */
#define	ERROR_BOX_FATAL		1
#define	ERROR_BOX_WARNING	2
#define	ERROR_BOX_NOTE		3

/* LED state masks used by keybdled() */
#define	LED_KEYBD_LOCKED	0x01
#define	LED_BAR			0x02
#define	LED_L1			0x04
#define	LED_L2			0x08
#define	LED_L3			0x10
#define	LED_L4			0x20

/* Ptty read mode masks used by Set_ptty_read_mode() */
#define	PTTY_READ_NORMAL	0
#define	PTTY_READ_NEWLINES	1

/* Stereo definitions - mgp */
/* values for stereomode() */
#define MONOSCOPIC		1	/* set window for monoscopic        */
#define STEREO_LEFT		2	/* set window for left view drawing */
#define STEREO_RIGHT		3	/* set window for right view drawing*/
/* values for stereosignal() */
#define GL_NORMAL		4	/* set glasses for normal stereo    */
#define GL_PSEUDO		5	/* set glasses for reversed stereo  */
#define GL_BRIGHT		6	/* set glasses wide open            */

#endif
