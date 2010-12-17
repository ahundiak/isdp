/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   global.h  $
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
|   global.h - structure definitions for global data areas in		|
|		MicroStation.						|
|									|
+----------------------------------------------------------------------*/
#if !defined (__globalH__)
#define __globalH__

#if !defined (__msdefsH__)
#   include	<msdefs.h>
#endif
#if !defined (__basedefsH__)
#   include	<basedefs.h>
#endif

/*----------------------------------------------------------------------+
|									|
|   MGDS modes structure 						|
|									|
+----------------------------------------------------------------------*/
typedef struct mgds_modes
    {
    byte	three_d;	      /* drawing is 3-d */
    byte	loc_ele_hilited;      /* is an element currently hilited */
    byte	rangedisplay;	      /* show ranges (for debugging) */
    byte	libindexed;	      /* cell library is indexed */
    short	tmp_element;	      /* temporary element is on the screen */
    byte	noDgnFile;	      /* There is no design file */
    byte	workFileWritten;      /* the work file has been written */
    byte	dgn_read_only;	      /* design file is read only */
    byte	cell_read_only;	      /* cell file is read only */
    byte	fb_only;	      /* file builder only */
    byte	always_read_only;     /* MicroStation started read_only */
#if defined (ip32)
    byte	use_blitsymbols;      /* use blit symbols */
    byte	noMenubar;	      /* no menu bar */
#endif
    byte	dontCheckLock;	      /* don't check file locking */
    byte	enableFork;	      /* enable forking to operating system */
    byte	filemode;	      /* direct or workfile mode */
    byte	panZoomActive;	      /* in a pan/zoom */
    byte	noIntTransform;	      /* don't use integer scale algorithm */
    byte	recording;	      /* we are currently recording */
    byte	playback;	      /* we are currently playing back */
    byte	noReferenceFiles;     /* dont bring up reference files */
    } Mgds_modes;

/*----------------------------------------------------------------------+
|                                                                       |
|      Graphics Configuration                                           |
|                                                                       |
+----------------------------------------------------------------------*/
typedef struct msGraphConfig
    {
    short	    numScreens;		/* number of physical screens */
    short	    currentScreen;	/* displayed screen w 2 virt scrns */
    short	    windowBorderStyle;  /* 0 normal, 1-9 = wide, 128 = none */
    struct msDisplayDescr *displayDescrP[MAX_PHYSSCREEN];
    short	    swapPossible;	/* TRUE if screen can swap */
    short	    needUpdateOnSwap;	/* TRUE if we need update on a swap */
    Rectangle	    swapUpdateRect;	/* Rectangle we need update for */
    void	   *updateHereBack;	/* frontmost wind that needs update */
    } MSGraphConfig;

/*----------------------------------------------------------------------+
|                                                                       |
|     MicroStation State data                                           |
|                                                                       |
+----------------------------------------------------------------------*/
#if !defined (__bsiH__)
typedef void GuiWindow;
#endif

typedef struct
    {
    Point3d	rawUors;	    /* database coordinates */
    Point3d	uors;		    /* database coords (adjusted for locks) */
    Uspoint3d	input;		    /* input device coordinates */
    Spoint2d	screen;		    /* screen coordinate system */
    GuiWindow  *gwP;		    /* M/S window we are in */
    short	region;		    /* region on input device */
    short	screenNumber;	    /* screen cursor is in */
    short	view;		    /* view cursor is in */
    short	buttonTrans;	    /* button transition type */
    short	qualifierMask;	    /* keyboard qualifiers */
    } CursorInfo;

#if defined (mdl)
typedef struct	msStateData
    {
    CursorInfo	current;	    /* current cursor information */
    CursorInfo	old;		    /* last time through cursor information */
    CursorInfo	inPoint;	    /* datapoint entered by user */
    CursorInfo	tentative;	    /* tentative point information */
    short	viewflags[MAX_VIEWS];	/* views command will operate on */
    short	precision;	    /* indicates precision input */
    Point3d	*pointstack;	    /* database point stack */
    Dpoint3d    *dPointStack;	    /* double precision version */
    short	pointpntr;	    /* point stack pointer */
    Point3d	viewpntstack[5];    /* point stack for view commands */
    short	vwpntpntr;	    /* view point stack pointer */
    short	tntPointActive;	    /* data point should go to tentative pt */
    short	snappedElement;	    /* tent point identified an element */
    char	cmdstring[128];	    /* commandstring */
    short	datapnt3d_active;   /* first part of 3D data entered */
    Point3d	datapnt3d;	    /* first part 3D data point */
    short	datapnt3d_view;	    /* view for first part of 3D data pnt */
    short	tentpnt3d_active;   /* first part of 3D tent pt entered */
    Point3d	tentpnt3d;	    /* first part of 3D tent point */
    short	tentpnt3d_view;	    /* view for first part of 3D tent pnt */
    byte    	pointFlags[16];	    /* flag array to parallel point stack   */
    struct
	{
	unsigned short	dragging:1;
	unsigned short	mouseup:1;
	unsigned short	closeCmd:1;
	unsigned short	unused:13;
	} flags;		    
    } MSStateData;

typedef struct msDisplayDescr
    {
    short	 id;		 /* card identity */
    short	 colors;	 /* number of colors supported */
    short	 xResolution;    /* x resolution (pixels) */
    short	 yResolution;    /* y resolution (pixels) */
    short	 screenWidth;    /* physical size of screen used, x */
    short	 screenHeight;   /* physical size of screen used, y */
    double	 aspect;	 /* aspect ratio of screen */
    short	 charHeight;	 /* character height (pixels) */
    short	 charWidth;	 /* width of characters (pixels) */
    short	 cursorWidth;    /* 1/2 of graphics cursor width */
    short	 cursorHeight;   /* 1/2 of graphics cursor height */
    short	 xorColor;	 /* exclusive or color */
    short	 hiliteColor;    /* color used for hilight */
    byte	 *colormap;	 /* mapping from dgn to display color */
    short     	 nPlanes;        /* number of planes on screen */
    byte    	 ditherShades[256];  /* 8 bit intensity to avail resolutn. */
    byte     	 rgb9BitToCtbl[512]; /* 9 bit rgb to colortbl-index map. */
    byte	 menuColors[NUM_MENU_COLORS+1];	/* number of menu colors */
    } MSDisplayDescr;
#endif

#endif	    /* __globalH__ */ 
