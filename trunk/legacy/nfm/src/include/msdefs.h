/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   msdefs.h  $
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
|   msdefs.h -- Defines for MicroStation data structures		|
|									|
+----------------------------------------------------------------------*/
#if !defined (__msdefsH__)
#define __msdefsH__

#define	    MAX_REFS		    255
#define	    MAX_REFCLIPPNTS	    100	  /* maximum reference clip points */
#define	    MAX_REFBOUNDS	    50	  /* maximum bounds + voids */
#define	    MAX_FILEMASK	    8	  /* enough for 255 refs and main */
#define	    MAX_VIEWS		    8
#define	    MAX_VERTICES	    101
#define	    MAX_EDFIELDS	    20	  /* max enter data fields / line */
#define	    MAX_ATTRIBSIZE	    650   /* largest attributes (words) */
#define	    MAX_PHYSSCREEN	    2	  /* max number of graphic screens */
#define	    MAX_ELEMENT_SIZE	    (768*2)
#define	    MAX_FONTS		    128
	
#define	    MAXFILELENGTH	    128
#define	    MAXDEVICELENGTH	    32
#define	    MAXDIRLENGTH	    128
#define	    MAXNAMELENGTH	    64
#define	    MAXEXTENSIONLENGTH	    32
#define	    MAXVERSIONLENGTH	    16
#define	    MAXKEYINPROMPT	    40
#define	    MAX_CMAPENTRIES	    256
	
#define	    CELL_LIB		    256
#define	    MASTERFILE		    0

#define	TASK_ID_SIZE	16

/*----------------------------------------------------------------------+
|									|
|	File Filter Masks - Used for specifying file filter attributes  |
|			    for mdlFile_findFirst			|
|									|
|									|
+----------------------------------------------------------------------*/
#define	    FFILTER_READONLY	    0x0001
#define	    FFILTER_SUBDIR	    0x0002
    
    
/*----------------------------------------------------------------------+
|									|
|   DISCONNECT is a coordinate value that signifies a disconnected	|
|	vertex in a string of points.  These vertices can occur in	|
|	linestrings or reference file clip boundaries.			|
|									|
+----------------------------------------------------------------------*/
#define DISCONNECT  (-2147483647L  - 1L)

/*----------------------------------------------------------------------+
|									|
|   Dialog Box Color Constants  					|
|									|
+----------------------------------------------------------------------*/
#if !defined (NUM_MENU_COLORS)    
#define	NUM_MENU_COLORS	     12	    /* number of menu colors */
#endif    

/*  Basic Color Indexes */
#define BLACK_INDEX	0
#define BLUE_INDEX	1
#define GREEN_INDEX	2
#define CYAN_INDEX	3
#define RED_INDEX	4
#define MAGENTA_INDEX	5
#define YELLOW_INDEX	6
#define WHITE_INDEX	7
#define LGREY_INDEX	8
#define DGREY_INDEX	9
#define MGREY_INDEX	10
#define PSEUDOWHITE_INDEX 11	    /* actually BLACK on mono screens */

/* icon style constants */
#define ICON_STYLE_NORMAL   0
#define ICON_STYLE_LGREY    1
#define ICON_STYLE_DGREY    2
#define ICON_STYLE_DISABLED 3

/*----------------------------------------------------------------------+
|									|
|   MicroStation Raster Font constants  				|
|									|
+----------------------------------------------------------------------*/
#define FONT_INDEX_NUMBER	6

#define FONT_INDEX_SYSTEM	0	/* cmd window, screen menus */
#define FONT_INDEX_BORDER	1	/* window borders */
#define FONT_INDEX_DIALOG	2	/* most dialog boxes */
#define FONT_INDEX_BOLD		3	/* bold text in dialog boxes */
#define FONT_INDEX_FIXED	4	/* fixed width font */
#define FONT_INDEX_FIXEDBOLD	5	/* bold fixed width font */

/*----------------------------------------------------------------------+
|									|
|   These are drawing modes for mdlElement_display.             	|
|									|
+----------------------------------------------------------------------*/
#define	    NORMALDRAW		    0	    /* drawing mode = set */
#define	    ERASE		    1	    /* erase from screen */
#define	    HILITE		    2	    /* highlight */
#define	    TEMPDRAW		    3	    /* draw temporarily */
#define	    TEMPERASE		    4	    /* erase temporarily drawn */
#define	    TEMPROTATE		    5	    /* exclusive-or and halftone */
#define	    XORDRAW		    6	    /* use exclusive or */
#define	    SET_ALLOWBGCOLOR	    7

#define	    RMINI4		    (-2147483648.)
#define	    LMAXI4		    2147483647L
#define	    LMINI4		    (-2147483647L)
#define	    RMAXI4		    2147483647.
#define	    RMAXUI4		    4294967295.

/*----------------------------------------------------------------------+
|									|
|   These are the Viewing Modes for 3D files				|
|									|
+----------------------------------------------------------------------*/
#define WIREFRAME	0
#define CROSSSECTION	1
#define WIREMESH	2
#define HIDDENLINE	3
#define SOLIDFILL	4
#define CONSTANTSHADE	5
#define SMOOTHSHADE     6	    
#define PHONG		7

/*----------------------------------------------------------------------+
|									|
|   Many MicroStation internal data structures that hold the address of	|
|   elements in a design file are defined in terms of "Block and	|
|   Byte" for compatibility with VAX based IGDS.  All MDL functions	|
|   accept arguments in the more logical concept of "File Position".	|
|   The following macros are provide for conversion between		|
|   block/byte and file position.					|
|									|
+----------------------------------------------------------------------*/
#define	    DGN_FILEPOS(x,y)	(((x)<<9) + (y))
#define	    DGN_BLOCK(x)	((x)>>9)
#define	    DGN_OFFSET(x)	((x)&511)

/*----------------------------------------------------------------------+
|									|
|   Types of Button Transitions 					|
|									|
+----------------------------------------------------------------------*/
#define BUTTONTRANS_UP		0x0001
#define BUTTONTRANS_DOWN	0x0002
#define BUTTONTRANS_TIMEOUT	0x0004
#define BUTTONTRANS_MOTION	0x0008
#define BUTTONTRANS_CLICK	0x0010
#define BUTTONTRANS_STARTDRAG	0x0020
#define BUTTONTRANS_DCLICK	0x0040


/*----------------------------------------------------------------------+
|                                                                       |
|    These are the window corner designations for resizing windows      |
|                                                                       |
+----------------------------------------------------------------------*/
#define CORNER_UPPERLEFT    0
#define CORNER_LOWERLEFT    1
#define CORNER_LOWERRIGHT   2
#define CORNER_UPPERRIGHT   3
#define CORNER_ALL	    4


/*----------------------------------------------------------------------+
|									|
|   Auxilliary Coordinate System (ACS) types				|
|									|
+----------------------------------------------------------------------*/
#define	ACS_RECTANGULAR    1
#define ACS_CYLINDRICAL	   2
#define ACS_SPHERICAL	   3
    
#endif	/* __msdefsH__ */
