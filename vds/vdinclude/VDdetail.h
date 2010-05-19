/* $Id: VDdetail.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDdetail.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdetail.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.8  1996/03/24  15:15:34  pinnacle
 * Replaced: vdinclude/VDdetail.h for:  by azuurhou for vds.240
 *
 * Revision 1.7  1996/01/04  06:41:48  pinnacle
 * Replaced: vdinclude/VDdetail.h for:  by rgade for vds.240
 *
 * Revision 1.6  1995/08/29  20:28:38  pinnacle
 * Replaced: vdinclude/VDdetail.h for:  by azuurhou for vds.240
 *
 * Revision 1.5  1995/08/04  12:29:22  pinnacle
 * Replaced: vdinclude/VDdetail.h for:  by msbraju for vds.240
 *
 * Revision 1.4  1995/03/22  14:59:08  pinnacle
 * Replaced: vdinclude/VDdetail.h by azuurhou r#
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


/****************************************************************************


		File:	VDdetail.h
		Type:   c include file
		Use:	Defines constants for VDSdetail class 
		Date:	18 December 1991 
		Autr:	adz - isdc
		
***************************************************************************/

#ifndef VDdetail_include

#define VDdetail_include

/* text size */
#define	VD_DET_TEXT_MAX		80

#defile VD_DET_NOTVALID		101
#define VD_DET_INV_CLASS	102

/* window information */
#define	VD_DET_WINDOW_NAME	"draw_vw"
#define	VD_DET_VIEWORIENT	"ViewOrient"
#define VD_DET_VIEWVOLUME	"ViewVolume"

#define	VD_DET_AXIS_LIST_MIN	3
#define	VD_DET_VOLUME_LIST_MIN	6

/* window limits */
#define	VD_DET_LEFT_MARGIN	4.0
#define VD_DET_RIGHT_MARGIN	194.0
#define	VD_DET_TOP_MARGIN	134.0
#define	VD_DET_BOTTOM_MARGIN	84.0

#define	VD_DET_DIMENS_MAX_X	1000.0
#define	VD_DET_DIMENS_MAX_Y	1000.0

#define	VD_DET_DIMENS_WIDTH	1184.0
#define	VD_DET_DIMENS_HEIGHT	884.0

/* definition for the structure of reference file */
struct VDdet_reffile{
	IGRchar		ref_name[VD_DET_TEXT_MAX];

	IGRshort	mx_type;	/* GRcontext instance */
	IGRmatrix	matrix;
	IGRshort	flags;
	GRspacenum	osnum;
	struct GRid	ctx_id;
	struct GRmd_env	md_env;
};

/* command object types */
#define	VD_drawview	4	/* equal to CO_drawview : see detailco.h */
#define VD_viewplane	20	/* added to list in detailco.h 	*/

#define		VD_DET_EPSILON		1e-5

#define		VD_DET_DEF_SCALE	"1:12"
#define		VD_DET_DEF_LAYER	"0-1023"
/* form constants	*/

#define		VD_DET_MAIN_FORM	0
#define		VD_DET_FORM_INIT	-1
#define		VD_DET_FORM_ACCEPT	261
#define		VD_DET_FORM_EXECUTE	262
#define		VD_DET_FORM_CANCEL	263
#define		VD_DET_FORM_INFO	255 /* exist from form_notification */

#define		VD_DET_EXT_DRAWING	13	/* form name */
#define		VD_DET_EXT_WINDOW	20	/* form name */
#define		VD_DET_ORIGIN_NAME	15
#define		VD_DET_SCALE_NAME	31

#define		VD_DET_SCALE		32 
#define		VD_DET_AXIS_TOGGLE	23
#define		VD_DET_VOLUME_TOGGLE	22
#define		VD_DET_Z_DEPTH_TOGGLE	28

#define		VD_DET_ORIGIN		11
#define		VD_DET_X_AXIS		17
#define		VD_DET_Y_AXIS		12
#define		VD_DET_Z_AXIS		33
#define		VD_DET_VOL_MIN		18
#define		VD_DET_VOL_MAX		24
#define		VD_DET_Z_DEPTH		29

#define		VD_DET_NAME		-1
#define		VD_DET_NAME_DESC	-2

#define		VD_DET_REF_TXT		47
#define		VD_DET_REF_FLD		48

#define		VD_DET_LAYER_NAME	39
#define		VD_DET_LAYERS		38

/* plane offset toggle and field */
#define		VD_DET_OFFSET_TOGGLE	30
#define		VD_DET_OFFSET_VALUE	37

/* window name */
#define		VD_DET_WIN_NAME		40
#define		VD_DET_WIN_NAME_DESC	41

/* distance units */
#define		VD_DET_DIST_UNITS	42

/* read options */
#define		VD_DET_NAME_DISPLAY	0
#define		VD_DET_NAME_SEARCH	1
#define		VD_DET_NAME_COUNT	2

/* selection flags */
#define		VD_DET_ORIGIN_FLAG	0x00000001
#define		VD_DET_AXIS_FLAG	0x00000002
#define		VD_DET_ZDEPTH_FLAG	0x00000004
#define		VD_DET_ALT_FLAG		0x00000008

#define		VD_DET_USER_FLAG	0x00000001
#define		VD_DET_EXTENDED		0x00000002
#define		VD_DET_DEP_EXT		0x00000004
#define		VD_DET_OBJ_RNG		0x00000008
#define		VD_DET_ADD_RNG		0x00000010
#define		VD_DET_PTS_RNG		0x00000020



/* form gagdget structure */
struct VDdet_formdata{

	IGRint		flag;

	IGRchar		text_scale[VD_DET_TEXT_MAX];
	IGRchar		layer_str[VD_DET_TEXT_MAX];	

	IGRchar		name[VD_DET_TEXT_MAX];
	IGRchar		name_desc[VD_DET_TEXT_MAX];

	IGRdouble	z_depth[2];
	IGRdouble	usr_z_depth[2];

	IGRchar		volume_name[VD_DET_TEXT_MAX];
	IGRdouble	vw_volume[6];
	IGRdouble	dep_volume[6];

	IGRchar		orient_name[VD_DET_TEXT_MAX];
	IGRvector	x_vec;
	IGRvector	y_vec;
	IGRvector	z_vec;
	IGRpoint	origin;
	IGRchar		viewchar;

	IGRint		toggle;
	IGRint		vol_toggle;

	IGRint		offset_toggle;
	IGRdouble	offset_value;
};

/* definition for the gragag flags GRID_ON or GRID_LOCK */
struct VDdet_vw_grid{
	struct GRid	grid; 
	int		flags;
};

/* added form gadgets - Raju 03-02-1995 */

#define  VD_DET_VIEW_TXT  43
#define  VD_DET_VIEW_FLD  44
#define  VD_DET_ROT_TXT   45
#define  VD_DET_ROT_FLD   46

/* Added the text gadgets - Ravi 04-01-1996   */

#define	 VD_DET_X_AXIS_TXT	21
#define	 VD_DET_Y_AXIS_TXT	14
#define	 VD_DET_Z_AXIS_TXT	34



#define  VD_NODIR	-1
#define  VD_XPOS	0
#define  VD_XNEG	1
#define  VD_YPOS	2
#define  VD_YNEG	3
#define  VD_ZPOS	4
#define  VD_ZNEG	5

#define  VD_RANGE_BY_OBJECTS	1000
#define  VD_EXTEND_RANGE	1001
#define  VD_RANGE_BY_POINTS	1002


/*
 * Temporary objects
 */
#define	VD_Obj_Max	3

#define	VD_Obj_boxId	0
#define	VD_Obj_csId	1
#define	VD_Obj_arrId	2


#endif
