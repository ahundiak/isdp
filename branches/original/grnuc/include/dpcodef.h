/*
	Defines for flags words in the DPcodpb
*/

/* defines for cct_flags */
#define CCT_SLIDER_RANGE	0x0001    /* 0 -> 0-100, 1 -> 0-255 */
#define CCT_COLOR_NAME_MODE	0x0002    /* 0 -> select, 1 -> change */
#define CCT_INTERP_MODE		0x0004    /* 0 -> interp shades, 1 -> interp colors */
#define CCT_FILE_TYPE		0x0008    /* 0 -> IGE, 1 -> IGDS */

/* defines for persp. flags */
#define PERSP_CHANGE_ANGLE	0x0001    /* 0 -> change eyepoint, 1 -> change angle */

/* defines for sws_flags */
#define SWS_FIXED_MASK		0x0007
#define SWS_WIDTH_FIXED		0x0001
#define SWS_HEIGHT_FIXED	0x0002
#define SWS_ASPECT_FIXED	0x0004

/* defines for dls_flags */
#define DLS_COPY_MODE		0x0001   /* 0 -> edit mode, 1 -> copy mode */

/* defines for mvv_flags */
#define MVV_CHANGE_COI		0x0001   /* 1 -> change center of interest */
#define MVV_CHANGE_EYE		0x0002   /* 1 -> change eye point */
#define MVV_CHANGE_UP		0x0004   /* 1 -> change up vector */
#define MVV_CHANGE_ANGLE	0x0008   /* 1 -> change view angle */
#define MVV_CHANGE_NEAR		0x0010   /* 1 -> change near clipping plane */
#define MVV_CHANGE_FAR		0x0020   /* 1 -> change far clipping plane */
#define MVV_CHANGE_VRP          0x0040   /* 1 -> change view reference point */
#define MVV_CHANGE_VPN          0x0080   /* 1 -> change view plane normal point */
#define MVV_SET_VPN             0x0100   /* 1 -> set view plane normal */

/* defines of layer_flags */
#define LAYER_VAL_MODE		0x0001   /* 0 -> name mode, 1 -> value mode */
#define LAYER_SORT_NUMERIC      0x0002   /* 0 -> sort alphbetically, 1 -> numerically */
#define LAYER_OCCUPIED_ENABLED  0x0004   /* 0 -> occupied criteria disabled, 1 -> enabled */
#define LAYER_DIS_SEARCH        0x0038   /* mask for displayed search criteria */
#define LAYER_DIS_SEARCH_IGN    0x0008   /* 1 -> displayed search criteria is "ignored" */
#define LAYER_DIS_SEARCH_ON     0x0010   /* 1 -> displayed search criteria is "on" */ 
#define LAYER_DIS_SEARCH_OFF    0x0020   /* 1 -> displayed search criteria is "off" */
#define LAYER_OCC_SEARCH        0x01C0   /* mask for occupied search criteria */
#define LAYER_OCC_SEARCH_IGN	0x0040   /* 1 -> occupied search criteria is "ignored" */
#define LAYER_OCC_SEARCH_YES    0x0080   /* 1 -> occupied search criteria is "yes" */
#define LAYER_OCC_SEARCH_NO     0x0100   /* 1 -> occupied search criteria is "no */


/* defined of dvd flags */

#define DVD_DLIST_ON            0x0001   /* 1 -> dlist on */
#define DVD_PERF_BOOST          0x0002   /* 1 -> performance boost is on */
#define DVD_UNLIMITED_ZOOM      0x0004   /* 1 -> unlimited zoom */
#define DVD_DRAG_MODE           0x0010   /* => 00 is STEP mode  */
#define DVD_CONT_MODE           0x0020

/* defines for place symbology override form flags*/
#define SO_HIDDEN		0x0001	 /* 1 -> hidden symbology override on*/
#define SO_INVISIBLE		0x0002	 /* 1 -> invisible symbology override on*/
#define SO_VISIBLE		0x0004	 /* 1 -> visible symbology override on*/
#define SO_SPECIFIED		0x0008	 /* 1 -> override symbology has been user specified*/
#define SO_ENABLE_INVIS		0x0010	 /* 1 -> turns invisbility on, else visble*/
#define SO_ENABLE_TOTAL		0x0020	 /* 1 -> turns total symb override on, else partial*/

