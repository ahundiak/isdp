/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsdef_include
#define hsdef_include 1

/*
 * hsdef.h contains HSURF definitions needed above the tiler level.
 */


/* Options copied from gpipe.h , we don't necessarily use all of them */

#define		GR_DONT_CLIP	0x00000001  /* don't clip linestr, poly etc */
#define		GR_DONT_XFORM	0x00000002  /* don't transform */
#define		GR_BS_BOUNDARY	0x00020000  /* Bspline stroke boundary */
#define		GR_BSC_CONSTANT 0x00040000  /* Bspline curve constant */
					    /* shading */
#define		GR_BSC_SOLID	0x00080000  /* Bspline curve solid fill */
#define		GR_BST_CONSTANT 0x00100000  /* Bspline surface tiler */
					    /* constant shading */
#define		GR_BST_SMOOTH	0x00200000  /* Bspline surface tiler smooth */
					    /* Gouraud shading */
#define		GR_BST_SOLID	0x00400000  /* Bspline surf tiler solid fill */
#define		GR_BST_TRANSP	0x00800000  /* Bspline tiler transparancy */
#define		GR_POLY_CONVEX  0x01000000  /* Polygons are convex only */
#define		GR_POLY_TRAP_FB 0x02000000  /* Feedback polygon trapezoids */
#define		GR_SHD_RGB	0x04000000  /* Shade color table in RGB */ 
#define		GR_CULL_BACKFACE 0x08000000 /* Cull backfaces */
#define		GR_SPECULAR	0x10000000  /* Use specular reflection */

/*
 *  Extra GPIPE options currently not supported.
 */

#define		HS_BST_EDGES		0x00000010
#define		HS_BST_REV_EDGES	0x00000020
#define		HS_BST_DELETE		0x00000040
#define		HS_BST_EDGES_DELETE	0x00000080
#define		HS_BST_STYLED_EDGES	0x00000100
#define		HS_OLD_EDGES		0x00001000
#define		HS_OLD_REV_EDGES	0x00002000
#define		HS_OLD_EDGES_DELETE	0x00008000
#define		HS_BST_POLYLINE		0x10000000
#define		HS_BST_POLYLINE_DELETE	0x20000000
#define		HS_BST_POINT		0x40000000
#define		HS_BST_POINT_DELETE	0x80000000

/*
 *  FEM shading options.
 */

#define		HS_FEM			0x00001000
#define		HS_FEM_DITHERED		0x00002000
#define		HS_FEM_MESH		0x00004000
#define		HS_FEM_DELETE		0x00008000

/*
 *  ASAPII shading options
 */

#define		HS_ASAPII_FEEDBACK	0x00000800

/*
 *  Inquire/Set switch flags for window data.
 */

#define HS_TOTAL_INSTANCE     1
#define HS_WIN_FLAGS          2
#define HS_WIN_SHADING_STYLE  3

/*
 * Rendering values.
 */

#define		HR_TOSS_SURFACE		32768		/* this cannot be a possible	*/
							/* viewing coordinate x-value	*/

/*
 *  Masks for setting bits in the global shading_flags integer
 */

#define	HS_SHADING_SHADE_MODE	  		0x00000001
#define	HS_SHADING_STYLE_MODE	  		0x00000002   /* 0 -> active, 1 -> element */
#define	HS_SHADING_TRANS_MODE	  		0x00000004   /* 0 -> active, 1 -> element */
#define	HS_SHADING_TABLE_DISP	  		0x00000008
#define	HS_SHADING_TABLE_CALC	  		0x00000010
#define	HS_SHADING_ACCUR_MODE	  		0x00000060
#define HS_SHADING_WINDOW_ACCUR   		0x00000020
#define HS_SHADING_ACTIVE_ACCUR   		0x00000040
#define HS_SHADING_ELEMENT_ACCUR  		0x00000060
#define	HS_SHADING_FEM_MESH	  		0x00000080
#define	HS_SHADING_FEM_STYLE	  		0x00000100
#define HS_SHADING_TRANS_GRID	  		0x00000200
#define HS_SHADING_REFLECT_MODE   		0x00000400   /* 0 -> element, 1 -> active */
#define HS_SHADING_FINISH_MODE    		0x00000800   /* 0 -> element, 1 -> active */
#define HS_SHADING_SHOW_HIDDEN    		0x00001000   /* 0 -> don't show hidden, 1 -> do */
#define HS_SHADING_CULLING_MODE   		0x00002000   /* 0 -> cull, 1 -> dont cull */
#define HS_SHADING_STEREO_DISPLAY 		0x00004000   /* 0 -> mono, 1 -> stereo */
#define HS_SHADING_STYLED_WIRE    		0x00008000   /* 0 -> don't honor wireframe style,weight,
								1 -> do */
#define HS_SHADING_LIGHT_SOURCE_UNDISPLAY	0x00010000   /* 0 -> on, 1 -> off */

/*
 *  Masks for setting bits in the global rendering_flags integer
 */

#define HS_RENDER_IMAGE_SIZE   0x0000000F   /* mask for rendering image size */
#define HS_RENDER_SIZE_WINDOW  0x00000001   /* set -> render image at window size */
#define HS_RENDER_SIZE_SCREEN  0x00000002   /* set -> render image at screen size */
#define HS_RENDER_SIZE_OTHER   0x00000004   /* set -> render image at other device size */
#define HS_RENDER_SIZE_USER    0x00000008   /* set -> render image at user defined size */
#define HS_RENDER_RESOLUTION   0x00000070   /* mask for rendering resolution */
#define HS_RENDER_FULL_RES     0x00000010   /* set -> render image at full resolution */
#define HS_RENDER_MEDIUM_RES   0x00000020   /* set -> render image at medium resolution */
#define HS_RENDER_LOW_RES      0x00000040   /* set -> render image a low resolution */
#define HS_RENDER_RGB          0x00000080   /* 0 -> don't use RGB attr, 1 -> use RGB attr */
#define HS_RENDER_BG_FILE_DISP 0x00000100   /* 0 -> no bg file, 1 -> bg file */
#define HS_RENDER_ANTI_ALIAS   0x00000200   /* 0 -> no anti-aliasing, 1 -> anti-aliasing */
#define HS_RENDER_VALID_FILE   0x00000400   /* 0 -> invalid file, 1-> valid file*/

/*
 *  Masks for setting bits in the global save_image_flags integer
 */

#define HS_SAVE_IMAGE_AREA             0x00000001   /* 0 -> window, 1 -> defined region */
#define HS_SAVE_IMAGE_TYPE             0x00000006   /* mask for save image type */
#define HS_SAVE_IMAGE_AS_IS            0x00000002   /* set -> save image as is on the screen */
#define HS_SAVE_IMAGE_TYPE_27          0x00000004   /* set -> save image as a type 27 file */
#define HS_SAVE_IMAGE_TYPE_29          0x00000006   /* set -> save image as a type 29 file */
#define HS_SAVE_IMAGE_8BIT             0x00000008   /* set -> use 8 bit raster data */
#define HS_DIS_IMAGE_SLIDE             0x00000010   /* 0 -> slide show, 1 -> animate */
#define HS_DIS_IMAGE_DELAY             0x00000020   /* 0 -> time delay, 1 -> single step */
#define HS_DIS_IMAGE_CYCLE             0x00000040   /* 0 -> cycle, 1 -> don't cycle */
#define HS_DIS_IMAGE_CLEAR             0x00000080   /* 0 -> don't clear, 1 -> clear */
#define HS_DIS_IMAGE_SCALE             0x00003F00   /* mask for clearing scale bits */
#define HS_DIS_IMAGE_SCALE_ONE         0x00000100   /* set -> scale is one */
#define HS_DIS_IMAGE_SCALE_TWO         0x00000200   /* set -> scale is two */
#define HS_DIS_IMAGE_SCALE_FOUR        0x00000400   /* set -> scale is four */
#define HS_DIS_IMAGE_SCALE_ONE_QUARTER 0x00000800   /* set -> scale is one quarter */
#define HS_DIS_IMAGE_SCALE_ONE_HALF    0x00001000   /* set -> scale is one half */
#define HS_DIS_IMAGE_SCALE_ONE_EIGHTH  0x00002000   /* set -> scale is one eighth*/
#define HS_DIS_IMAGE_SPEED	       0x00010000   /* 0 -> speed, 1 -> appearance */
#define HS_DIS_IMAGE_NEW_WIN           0x00020000   /* 0 -> full screen win, 1 -> existing window */
#define HS_DIS_IMAGE_FILE_CT           0x00040000   /* 0 -> use files colortable, 1 use windows */


/*
 *  Masks for setting bits in the global vhl_flags integer
 */

#define HS_VHL_RESOLUTION           0x00000003   /* mask for VHL resolution */
#define HS_VHL_LOW_RES              0x00000001   /* set -> low resolution VHL */
#define HS_VHL_MEDIUM_RES           0x00000002   /* set -> medium resolution VHL */
#define HS_VHL_HIGH_RES             0x00000003   /* set -> high resolution VHL */
#define HS_VHL_RESULTS_DIM          0x00000004   /* 0 -> 2D, 1 -> 3D */
#define HS_VHL_TEXT_COPY            0x00000008   /* 0 -> don't copy, 1 -> copy */
#define HS_VHL_REF_DISPLAY_OFF      0x00000010   /* 0 -> ref file display on, 1 -> display off */
#define HS_VHL_CLIP_TO_FENCE        0x00000020   /* 0 -> don't clip, 1 -> clip */
#define HS_VHL_PROCESS_WIREFRAME    0x00000040   /* 0 -> don't process, 1 -> do process */
#define HS_VHL_HIDING               0x00000080   /* 0 -> projecting, 1 -> hiding */
#define HS_VHL_DISPLAY_HIDDEN       0x00000200   /* NOT USED ANYMORE - DATA IS IN GRNUC GRDPB */
#define HS_VHL_DELETE_OVERRIDES     0x00000400   /* 0 -> don't delete symbology overrides, 1 -> delete */
#define HS_VHL_DONT_PROCESS_TANGENT 0x00000800   /* 0 -> process tangent edges, 1 -> don't process */

/*
 *  Masks for setting bits in the global rendering attr flags integer
 */

#define HS_REND_ATTR_COPY_TO_OPT    0x00000006
#define HS_REND_ATTR_COPY_TO_ACTIVE 0x00000001  /* 1 -> copy to active attributes */
#define HS_REND_ATTR_COPY_TO_ORIG   0x00000002  /* 1 -> copy to original element */
#define HS_REND_ATTR_COPY_TO_OTHER  0x00000004  /* 1 -> copy to other elements   */
#define HS_REND_ATTR_COPY_TRANS     0x00000008  /* 1 -> copy translucency        */
#define HS_REND_ATTR_COPY_DIFFUSE   0x00000010  /* 1 -> copy diffuse refl. coeff. */
#define HS_REND_ATTR_COPY_SPECULAR  0x00000020  /* 1 -> copy specular refl. coeff. */
#define HS_REND_ATTR_COPY_FINISH    0x00000040  /* 1 -> copy finish */
#define HS_REND_ATTR_COPY_COLOR     0x00000080  /* 1 -> copy color */
#define HS_REND_ATTR_COPY_TEXTURE   0x00000100  /* 1 -> copy texture */
#define HS_REND_ATTR_FINISH_RANGE   0x00000200  /* 0 -> linear, 1 -> exponentional */
#define HS_REND_ATTR_ASSIGN_TEXTURE 0x00000400  /* 0 -> no, 1 -> yes */

/*
 *  Masks for setting bits in the global hplot flags integer
 */

#define HS_PLOT_SAVE_PLOTFILE       0x00000001
#define HS_PLOT_SAVE_RASTERFILE     0x00000002
#define HS_PLOT_SAVE_TEXTFILE       0x00000004
#define HS_PLOT_PLOT_BY_SIZE        0x00000008
#define HS_PLOT_WINDOW_CONTENTS     0x00000010
#define HS_PLOT_MAIL_AT_BEGIN       0x00000020
#define HS_PLOT_MAIL_AT_END         0x00000040
#define HS_PLOT_BG_COLOR            0x00000080
#define HS_PLOT_EDGE_COLOR          0x00000100
#define HS_PLOT_BLACK_AND_WHITE     0x00000200
#define HS_PLOT_WHITE_BACKGROUND    0x00000400
#define HS_PLOT_CREATE_TEXTFILE     0x00000800
#define HS_PLOT_OLD_FILE            0x00001000 /* 1 -> old design file, 0 -> new file */
#define HS_PLOT_EXCLUDE_WIREFRAME   0x00002000
	
/*
 * Masks for setting bits in the global place light flags integer
 */

#define HS_PLACE_LIGHT_MODIFY_MASK  0x000000FF /* 1 -> corresponding light to be modified */
#define HS_PLACE_LIGHT_SLIDER_RANGE 0x00000100 /* 0 -> 0-100, 1->0-255 */
#define HS_PLACE_LIGHT_AMBIENT      0x00000200 /* 0 -> changing normal lights, 1 -> changing ambient */

/*
 *  special display modes.  Used by HSset_active_max_z() when initializing the size
 *  of the z's
 */

#define HS_SPECIAL_STYLE_NORMAL			0
#define	HS_SPECIAL_STYLE_STYLED_RASTER		1
#define	HS_SPECIAL_STYLE_RENDERING		2
#define	HS_SPECIAL_STYLE_VIEW_DYNAMICS		3
#define HS_SPECIAL_STYLE_NC			4
#define HS_SPECIAL_STYLE_FEM			5
#define HS_SPECIAL_STYLE_SHADED_PLOTS		6

#define	STYLED_RASTER	0

/*
 *  "Get Edges" modes for calls to HSget_surface_edges function
 */
 
#define	HS_GET_EDGES_MODE_RHL		0x0001
#define	HS_GET_EDGES_MODE_LVHL		0x0002
#define	HS_GET_EDGES_MODE_PLOTTING	0x0004
#define	HS_GET_EDGES_MODE_DELETE_VESO	0x0008
#define	HS_GET_EDGES_MODE_DUMP_SO	0x0010

#endif
