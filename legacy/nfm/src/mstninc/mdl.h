/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   mdl.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   mdl.h -- Main include file for MDL applications.  Defines		|
|	     structures and constants used by MDL library functions.	|
|									|
+----------------------------------------------------------------------*/
#if !defined (__mdlH__)
#define __mdlH__

#if !defined (__basedefsH__)
#   include	<basedefs.h>
#endif
#if !defined (__basetypeH__)
#   include	<basetype.h>
#endif

/*----------------------------------------------------------------------+
|									|
|	Replace the obsolete names with the new names   		|
|									|
+----------------------------------------------------------------------*/
    
#define	    cmd_name		cmdName
#define	    cmd_number		cmdNumber
    
/*----------------------------------------------------------------------+
|									|
|	Constants for standard views					|
|									|
+----------------------------------------------------------------------*/
#define	    STDVIEW_TOP		1
#define	    STDVIEW_BOTTOM	2
#define	    STDVIEW_LEFT	3
#define	    STDVIEW_RIGHT	4
#define	    STDVIEW_FRONT	5
#define	    STDVIEW_BACK	6
#define	    STDVIEW_ISO		7

/*----------------------------------------------------------------------+
|									|
|	Text creation routine parameters				|
|									|
+----------------------------------------------------------------------*/
#define	    TXT_NO_TRANSFORM	    0x8000
#define	    TXT_BY_TILE_SIZE	    1
#define	    TXT_BY_MULT		    2
#define	    TXT_BY_TEXT_SIZE	    3
#define	    TXT_BY_WIDTH_ASPECT	    4

/*   Text Justifications   */
#define	    TXTJUST_LT	    0     	/* Left Top */
#define	    TXTJUST_LC	    1 		/* Left Center */
#define	    TXTJUST_LB	    2		/* Left Bottom */
#define	    TXTJUST_LMT	    3		/* Left Margin Top */
#define	    TXTJUST_LMC	    4		/* Left Margin Center */
#define	    TXTJUST_LMB	    5		/* Left Margin Bottom */
#define	    TXTJUST_CT	    6		/* Center Top */
#define	    TXTJUST_CC	    7		/* Center Center */
#define	    TXTJUST_CB	    8		/* Center Bottom */
#define	    TXTJUST_RMT	    9		/* Right Margin Top */
#define	    TXTJUST_RMC	    10		/* Right Margin Center */
#define	    TXTJUST_RMB	    11		/* Right Margin Bottom */
#define	    TXTJUST_RT	    12		/* Right Top */
#define	    TXTJUST_RC	    13		/* Right Center */
#define	    TXTJUST_RB	    14		/* Right Bottom */

    
/*** Text Font Info Defines Below ***/
    
/* Text Symbol Type */
#define	    TXTFONT_NORMAL	0	/* Normal font */
#define	    TXTFONT_SYMBOL	1	/* Symbol font */
    
/* Text Vector Size */
#define	    TXTFONT_BYTEVEC	1	/*  8-bits used for vector */
#define	    TXTFONT_WORDVEC	2	/* 16-bits used for vector */

/* Text Representation Size */
#define	    TXTFONT_BYTEREP	0	/*  8-bits represents font */
#define	    TXTFONT_WORDREP	1	/* 16-bits represents font */
    
/* Text Type */
#define	    TXTFONT_VECTOR	0	/* Vector font */
#define	    TXTFONT_RASTER	1	/* Raster font */
    

typedef struct textSize
    {
    double	width;
    double	height;
    } TextSize;

typedef struct textSizeParam
    {
    int		mode;
    TextSize	size;
    double	aspectRatio;
    } TextSizeParam;

typedef struct textParam
    {
    int		font;
    int		just;
    int		style;
    int		viewIndependent;
    } TextParam;
    
typedef struct textEDField
    {
    byte	start;
    byte	len;
    byte	just;
    } TextEDField;
    
typedef struct textEDParam
    {
    int		    numEDFields;
    TextEDField	    *edField;
    } TextEDParam;

typedef struct textScale
    {
    double	    x;		    /* magnification of vectors within tile */
    double	    y;		    /* magnification of vectors within tile */
    } TextScale;

typedef struct textFlags
    {
    UShort	    upper:1;	    /* upper case */
    UShort	    lower:1;	    /* lower case */
    UShort	    fract:1;	    /* fractions */
    UShort	    intl:1;	    /* international */
    UShort	    fast:1;	    /* fast */
    UShort	    reserved:4;	    /* reserved */
    } TextFlags;

typedef struct textStyleInfo
    {
    int		font;
    short	style;
    } TextStyleInfo;
    
typedef struct textFontInfo
    {
    TextFlags	    lettersType;    /* upper, lower, fractions, intl */
    byte	    charType;	    /* symbol or normal */
    byte	    vectorSize;	    /* byte or word */
    byte	    graphicType;    /* rastor or vector */
    byte	    charSize;	    /* 8 or 16 bit representation of font */
    short	    tileSize;	    /* size of "tile" making up characters */
    long	    dataSize;	    /* size of file including header */
    Point2d	    origin;	    /* origin of char in the "tile" */
    TextScale	    scale;	    /* scale factor of font */
    } TextFontInfo;
    
/*----------------------------------------------------------------------+
|									|
|   Defines for mdlElement_getFilePos & mdlElement_setFilePos routines.	|
|									|
+----------------------------------------------------------------------*/
#define FILEPOS_EOF		0
#define FILEPOS_CURRENT		1
#define FILEPOS_FIRST_ELE	2
#define FILEPOS_NEXT_ELE	3
#define FILEPOS_WORKING_SET	4
#define FILEPOS_WORKING_WINDOW	5
#define FILEPOS_COMPONENT	6

/*----------------------------------------------------------------------+
|									|
|   Defines for mdlElmdscr_ routines					|
|									|
+----------------------------------------------------------------------*/
#define	ELMD_ELEMENT	    (1<<0)
#define ELMD_PRE_HDR	    (1<<1)
#define	ELMD_POST_HDR	    (1<<2)
#define ELMD_PRE_NESTEDHDR  (1<<3)
#define	ELMD_POST_NESTEDHDR (1<<4)
#define ELMD_ALL_ONCE	    (ELMD_ELEMENT | ELMD_PRE_HDR | ELMD_PRE_NESTEDHDR)
#define ELMD_HDRS_ONCE	    (ELMD_PRE_HDR | ELMD_PRE_NESTEDHDR)

/*----------------------------------------------------------------------+
|									|
|   Parameters for mdlModify_ routines					|
|									|
+----------------------------------------------------------------------*/
typedef struct
    {
    int	    reserved1;
    int	    reserved2;
    void    *reserved3;
    } MdlCopyParams;
    
#define MODIFY_ORIG		    (1<<1)
#define MODIFY_COPY		    0
#define MODIFY_DRAWINHILITE	    (1<<3)
#define MODIFY_DONTDRAWNEW	    (1<<4)
#define MODIFY_DONTERASEORIG	    (1<<5)
					
#define MODIFY_REQUEST_NOHEADERS    0
#define MODIFY_REQUEST_HEADERS	    (1<<0)
#define MODIFY_REQUEST_ONLYONE	    (1<<1)

#define	MODIFY_STATUS_NOCHANGE	    0
#define MODIFY_STATUS_REPLACE	    (1<<0)
#define MODIFY_STATUS_DELETE	    (1<<1)
#define MODIFY_STATUS_ABORT	    (1<<2)
#define MODIFY_STATUS_FAIL	    (1<<3)
#define MODIFY_STATUS_REPLACEDSCR   (1<<4)
#define MODIFY_STATUS_MODIFIED	    (1<<5)
#define MODIFY_STATUS_ERROR	    (MODIFY_STATUS_FAIL | MODIFY_STATUS_ABORT)

/*----------------------------------------------------------------------+
|									|
|   Defines for mdlView_getDisplayControls() &				|
|		mdlView_setDisplayControls()				|
|									|
+----------------------------------------------------------------------*/
#define VIEWCONTROL_FAST_CURVE	    0
#define VIEWCONTROL_FAST_TEXT	    1
#define VIEWCONTROL_FAST_FONT	    2
#define VIEWCONTROL_LINE_WEIGHTS    3
#define VIEWCONTROL_PATTERNS	    4
#define VIEWCONTROL_TEXT_NODES	    5
#define VIEWCONTROL_ED_FIELDS	    6
#define VIEWCONTROL_GRID	    9
#define VIEWCONTROL_LEV_SYMB	    10
#define VIEWCONTROL_POINTS	    11
#define VIEWCONTROL_CONSTRUCTION    12
#define VIEWCONTROL_DIMENSIONS	    13
#define VIEWCONTROL_AREA_FILL	    16
#define VIEWCONTROL_RASTER_TEXT	    17
#define VIEWCONTROL_AUX_DISPLAY	    18
#define VIEWCONTROL_CAMERA	    22
#define VIEWCONTROL_RENDERMODE	    23
#define VIEWCONTROL_BACKGROUND	    26
#define VIEWCONTROL_REF_BOUND	    27
#define VIEWCONTROL_FAST_BOUND_CLIP 28
#define VIEWCONTROL_DEPTH_CUE	    29
#define VIEWCONTROL_NO_DYNAMICS	    30

#define VIEWMODE_WIREFRAME	    0
#define VIEWMODE_CROSSSECTION	    1
#define VIEWMODE_WIREMESH	    2
#define VIEWMODE_HIDDENLINE	    3
#define VIEWMODE_FILLEDHLINE	    4
#define VIEWMODE_CONTANTSHADE	    5
#define VIEWMODE_SMOOTHSHADE	    6
#define VIEWMODE_PHONGSHADE	    7

/*----------------------------------------------------------------------+
|									|
|   Defines for mdlParams_getActive() & mdlParams_setActive()		|
|									|
+----------------------------------------------------------------------*/
#define	ACTIVEPARAM_COLOR	    1
#define	ACTIVEPARAM_COLOR_BY_NAME   2
#define	ACTIVEPARAM_LINESTYLE	    3
#define	ACTIVEPARAM_LINEWEIGHT	    4
#define	ACTIVEPARAM_LEVEL	    5
#define	ACTIVEPARAM_ANGLE	    6
#define	ACTIVEPARAM_FONT	    7
#define	ACTIVEPARAM_GRIDUNITS	    8
#define	ACTIVEPARAM_GRIDREF  	    9
#define	ACTIVEPARAM_TEXTHEIGHT      10
#define	ACTIVEPARAM_TEXTWIDTH       11
#define	ACTIVEPARAM_UNITROUNDOFF    12
#define	ACTIVEPARAM_TEXTJUST        13
#define	ACTIVEPARAM_NODEJUST        14
#define	ACTIVEPARAM_CELLNAME        15
#define	ACTIVEPARAM_LINELENGTH      16
#define	ACTIVEPARAM_LINESPACING     17
#define	ACTIVEPARAM_TERMINATOR      18
#define	ACTIVEPARAM_TAGINCREMENT    19
#define	ACTIVEPARAM_TAB             20
#define	ACTIVEPARAM_STREAMDELTA     21
#define	ACTIVEPARAM_STREAMTOLERANCE 22
#define	ACTIVEPARAM_STREAMANGLE     23
#define	ACTIVEPARAM_STREAMAREA      24
#define	ACTIVEPARAM_POINT           25
#define	ACTIVEPARAM_KEYPOINT        26
#define	ACTIVEPARAM_PATTERNDELTA    27
#define	ACTIVEPARAM_PATTERNANGLE    28
#define	ACTIVEPARAM_PATTERNSCALE    29
#define	ACTIVEPARAM_PATTERNCELL     30
#define	ACTIVEPARAM_AREAMODE        31
#define	ACTIVEPARAM_AXISANGLE       32
#define	ACTIVEPARAM_CLASS           33
#define	ACTIVEPARAM_CAPMODE         34
#define	ACTIVEPARAM_GRIDMODE        35
#define	ACTIVEPARAM_GRIDRATIO       36
#define	ACTIVEPARAM_FILLMODE        37
#define	ACTIVEPARAM_SCALE    	    38
#define	ACTIVEPARAM_TERMINATORSCALE 39
#define ACTIVEPARAM_DIMCOMPAT	    40
#define ACTIVEPARAM_MLINECOMPAT	    41
#define ACTIVEPARAM_AXISORIGIN	    42

#define ACTIVELOCK_ASSOCIATION	    500


/*----------------------------------------------------------------------+
|									|
|   Defines for mdlOutput_printf.  					|
|									|
+----------------------------------------------------------------------*/
#define MSG_MESSAGE		0
#define MSG_ERROR		1
#define MSG_PROMPT		2
#define MSG_STATUS		3
#define MSG_COMMAND		4
#define MSG_KEYIN		5

/*----------------------------------------------------------------------+
|									|
|   Defines for mdlWindow_ routines					|
|									|
+----------------------------------------------------------------------*/
#if defined (mdl)
typedef void MSWindow;
#endif

/*----------------------------------------------------------------------+
|									|
|   Constants for dimension and multiline points			|
|									|
+----------------------------------------------------------------------*/
#define POINT_CHECK    	    	   0
#define POINT_ASSOC    	    	   1
#define POINT_STD    	    	   2

/* Arc association options */
#define ASSOC_ARC_ANGLE    	   0
#define ASSOC_ARC_CENTER    	   1
#define ASSOC_ARC_START     	   2
#define ASSOC_ARC_END	    	   3

/*----------------------------------------------------------------------+
|									|
|   Constants for mdlMline functions					|
|									|
+----------------------------------------------------------------------*/
#define MLBREAK_FROM_JOINT  0x8000
#define MLBREAK_TO_JOINT    0x4000
#define MLBREAK_STD    	    0

#define MLCAP_NONE	    0x0
#define MLCAP_LINE     	    0x1
#define MLCAP_OUTER_ARCS    0x2
#define MLCAP_INNER_ARCS    0x4
#define MLCAP_CLOSE	    0x8

#define SHIFT_BREAKS	    0x2
/*----------------------------------------------------------------------+
|									|
|   Constants for mdlLevel functions					|
|									|
+----------------------------------------------------------------------*/
#define DUPLICATE_GROUP		    2227
#define DUPLICATE_LEVEL		    2228
						
/*----------------------------------------------------------------------+
|									|
|   Constants for mdlText functions					|
|									|
+----------------------------------------------------------------------*/
#define	FRACTIONS		(1<<1)
#define	INTERNATIONAL		(1<<2)
#define	CONTROL			(1<<3)
    
#endif	/* __mdlH__ */
