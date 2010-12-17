/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   mstypes.h  $
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
|   mstypes.h -- Typedefs and Defines used the MicroStation TCB and	|
|	     other include files					|
|									|
+----------------------------------------------------------------------*/
#if !defined (__mstypesH__)
#define __mstypesH__

#if !defined (__basedefsH__)
#   include    <basedefs.h>
#endif
#if !defined (__basetypeH__)
#   include    <basetype.h>
#endif
#if !defined (__msdefsH__)
#   include    <msdefs.h>
#endif

/*----------------------------------------------------------------------+
|									|
|   Viewflags (IGDS)							|
|									|
+----------------------------------------------------------------------*/
typedef struct viewflags
    {
#if !defined (mc68000)
    unsigned	    fast_curve:1;   /* fast curve display */
    unsigned	    fast_text:1;    /* fast text */
    unsigned	    fast_font:1;    /* fast font text */
    unsigned	    line_wghts:1;   /* line weights */
    unsigned	    patterns:1;	    /* pattern display */
    unsigned	    text_nodes:1;   /* text node display */
    unsigned	    ed_fields:1;    /* enter data field underlines */
    unsigned	    on_off:1;	    /* view on or off */
    unsigned	    delay:1;	    /* delay on */
    unsigned	    grid:1;	    /* grid on */
    unsigned	    lev_symb:1;	    /* level symbology */
    unsigned	    points:1;	    /* points */
    unsigned	    constructs:1;   /* line constructs */
    unsigned	    dimens:1;	    /* dimensioning */
    unsigned	    fast_cell:1;    /* fast cells */
    unsigned	    def:1;	    /* def/undef ?? */
#else
    unsigned	    def:1;	    /* def/undef ?? */
    unsigned	    fast_cell:1;    /* fast cells */
    unsigned	    dimens:1;	    /* dimensioning */
    unsigned	    constructs:1;   /* line constructs */
    unsigned	    points:1;	    /* points */
    unsigned	    lev_symb:1;	    /* level symbology */
    unsigned	    grid:1;	    /* grid on */
    unsigned	    delay:1;	    /* delay on */
    unsigned	    on_off:1;	    /* view on or off */
    unsigned	    ed_fields:1;    /* enter data field underlines */
    unsigned	    text_nodes:1;   /* text node display */
    unsigned	    patterns:1;	    /* pattern display */
    unsigned	    line_wghts:1;   /* line weights */
    unsigned	    fast_font:1;    /* fast font text */
    unsigned	    fast_text:1;    /* fast text */
    unsigned	    fast_curve:1;   /* fast curve display */
#endif
    } Viewflags;

/*----------------------------------------------------------------------+
|									|
|   ViewInfo (IGDS)							|
|									|
+----------------------------------------------------------------------*/
typedef struct viewinfo
    {
    Viewflags	    flags;	    /* view flags */
    short	    levels[4];	    /* active levels (64 bit array) */
    Point3d	    origin;	    /* origin (3d point made of longs) */
    Upoint3d	    delta;	    /* delta to other corner of view */
    double	    transmatrx[9];  /* view transformation matrix */
    double	    conversion;	    /* conversion digitizer units to uors */
    unsigned long   activez;	    /* view active z */
    } Viewinfo;

/*----------------------------------------------------------------------+
|									|
|   CameraInfo								|
|									|
+----------------------------------------------------------------------*/
typedef struct camerainfo
    {
    double	    angle;
    double	    focalLength;
    Dpoint3d	    position;
    } CameraInfo;


/*----------------------------------------------------------------------+
|									|
|   Ext_viewflags							|
|									|
+----------------------------------------------------------------------*/
typedef struct ext_viewflags
    {
#if !defined (mc68000)
    unsigned	    fill:1;
    unsigned	    rasterText:1;
    unsigned	    auxDisplay:1;
    unsigned	    orientationDisplay:1;
    unsigned	    viewRendered:1;
    unsigned	    reserved:1;
    unsigned	    camera:1;
    unsigned	    renderMode:3;
    unsigned	    background:1;
    unsigned	    refBoundaryDisplay:1;
    unsigned	    fastBoundaryClip:1;
    unsigned	    depthCue:1;
    unsigned	    inhibitDynamics:1;
    unsigned	    appDisplay:1;
    unsigned	    unused:16;
#else
    unsigned	    unused:16;
    unsigned	    appDisplay:1;	/* reserved */
    unsigned	    inhibitDynamics:1;	/* set dynamics on/off */
    unsigned	    depthCue:1;		/* set depthcue  */
    unsigned	    fastBoundaryClip:1;	/* rectangle or polygon clip */
    unsigned	    refBoundaryDisplay:1;/* ref clipping boundry displayed */
    unsigned	    background:1;	/* set background on/off */
    unsigned	    renderMode:3;	/* see mdl.h VIEWMODE... defines */
    unsigned	    camera:1;		/* set camera on/off */
    unsigned	    reserved:1;		
    unsigned	    viewRendered:1;	/* reserved */
    unsigned	    orientationDisplay:1;/* reserved */
    unsigned	    auxDisplay:1;	/* acs display */
    unsigned	    rasterText:1;	/* mac only display raster text */
    unsigned	    fill:1;		/* set fill on/off */
#endif
    } Ext_viewflags;

/*----------------------------------------------------------------------+
|									|
|   MSTextStyle								|
|									|
+----------------------------------------------------------------------*/
typedef struct mstextstyle
    {
#if !defined (mc68000)
     unsigned	    t_bold:1;
     unsigned	    t_italic:1;
     unsigned	    t_underline:1;
     unsigned	    t_outline:1;
     unsigned	    t_shadow:1;
     unsigned	    t_condense:1;
     unsigned	    t_extend:1;
     unsigned	    unused1:9;
#else
     unsigned	    unused1:9;
     unsigned	    t_condense:1;
     unsigned	    t_extend:1;
     unsigned	    t_shadow:1;
     unsigned	    t_underline:1;
     unsigned	    t_italic:1;
     unsigned	    t_bold:1;
#endif
    } MSText_Style;

/*----------------------------------------------------------------------+
|									|
|   Ext_viewinfo							|
|									|
+----------------------------------------------------------------------*/
typedef struct ext_viewinfo
    {
    Ext_viewflags   ext_flags;		/* extended flags */
    short	    classmask;		/* class masks */
    short	    version;		/* 0=version 3.4 or earlier, 1=4.0 */
    double	    perspective;	/* perspective (not use in 4.0) */
    CameraInfo	    camera;		/* virtual camera information */
    short	    extendedLevels[4];	/* For extra levels */
    short	    padding[28];	/* reserved for future use */
    } Ext_viewinfo, ExtendedViewInfo;
    
/*----------------------------------------------------------------------+
|									|
|   Fb_opts (IGDS)							|
|									|
+----------------------------------------------------------------------*/
typedef struct fb_opts
    {
#if !defined (mc68000)
    unsigned	multi_attach:1;		/* multi-attach */
    unsigned	one_one_map:1;		/* 1:1 mapping */
    unsigned	slot_in_use:1;		/* slot in use */
    unsigned	upd_fildgn:1;		/* update on file design */
    unsigned	db_diff_mf:1;		/* data base different than mf */
    unsigned	snap_lock:1;		/* snap lock */
    unsigned	locate_lock:1;		/* locate lock */
    unsigned	missing_file:1;		/* missing file */
    unsigned	unused:7;		/* unused */
    unsigned	ref2D_master3D:1;	/* 2D file referenced to 3D file */
#else
    unsigned	ref2D_master3D:1;	/* 2D file referenced to 3D file */
    unsigned	unused:7;		/* unused */
    unsigned	missing_file:1;		/* missing file */
    unsigned	locate_lock:1;		/* locate lock */
    unsigned	snap_lock:1;		/* snap lock */
    unsigned	db_diff_mf:1;		/* data base different than mf */
    unsigned	upd_fildgn:1;		/* update on file design */
    unsigned	slot_in_use:1;		/* slot in use */
    unsigned	one_one_map:1;		/* 1:1 mapping */
    unsigned	multi_attach:1;		/* multi-attach */
#endif
    } Fb_opts;

/*----------------------------------------------------------------------+
|									|
|   Fd_opts (IGDS)							|
|									|
+----------------------------------------------------------------------*/
typedef struct fd_opts
    {
#if !defined (mc68000)
    unsigned	view_ovr:1;		/* view override */
    unsigned	display:1;		/* display */
    unsigned	line_width:1;		/* lines with width */
    unsigned	unused:13;		/* unused */
#else
    unsigned	unused:13;		/* unused */
    unsigned	line_width:1;		/* lines with width */
    unsigned	display:1;		/* display */
    unsigned	view_ovr:1;		/* view override */
#endif
    } Fd_opts;	   

    
/*----------------------------------------------------------------------+
|									|
|	common MicroStation structures					|
|									|
+----------------------------------------------------------------------*/
typedef struct seven_wd_lknm
    {
    short	name[3];	/* 3 word file name */
    short	extension;	/* 1 word file extension */
    short	uic;		/* user identification code */
    short	disk;		/* device */
    short	version;	/* version of file */
    } Seven_wd_lknm;

typedef struct symbology
    {
#if !defined (mc68000)
    unsigned	style:3;	/* element line style */
    unsigned	weight:5;	/* current line weight */
    unsigned	color:8;	/* current color */
#else			    	/* bit fields in opposite order */
    unsigned	color:8;	/* current color */
    unsigned	weight:5;	/* current line weight */
    unsigned	style:3;	/* element line style */
#endif
    } Symbology;		/* element symbology word */

/*----------------------------------------------------------------------+
|                                                                       |
|   Update view info passed to applications                             |
|                                                                       |
+----------------------------------------------------------------------*/
typedef struct asynch_update_view 
    {
    int		active;		/* TRUE if active, FALSE if not */
    int		viewnum;	/* MicroStation's view num (0-7) */
    int		window;		/* Environ V window number */
    int		phys_screen;	/* physical (or logical) screen number */
    Point3d	screen_origin;	/* origins for views, screen coords */
    Point3d	screen_corner;	/* corners for views, screen coords */
    Point3d	update_origin;	/* origin for region that needs updating */
    Point3d	update_corner;	/* corner for region that needs update */
    Point3d	vieworg;	/* view origin (from TCB) */
    Upoint3d	viewdelta;	/* view delta (from TCB) */
    double	rotmatrix[9];	/* rotation matrix (from TCB) */
    short	levels[8];	/* active levels (from TCB) */
    short	classmask;	/* active classes for this view */
    Viewflags	viewflags;	/* view flags (from TCB) */
    Ext_viewflags ext_viewflags;/* extended viewflags for this view */
    } Asynch_update_view;

/*----------------------------------------------------------------------+
|                                                                       |
|   Window event info passed to applications                            |
|                                                                       |
+----------------------------------------------------------------------*/
typedef struct asynch_window_event
    {
    int	    windowNumber;	    /* Environ V window */
    int	    windowId;		    /* MicroStation's window ID */
    int	    windowOp;		    /* operation performed */
    int     numCovers;		    /* number of covering windows */
    int	    virtualScreen;	    /* virtual screen window is on */
    int	    oldVirtualScreen;	    /* virtual screen window was on */
    Rectangle oldGlobal;	    /* old global rectangle */
    Rectangle newGlobal;	    /* new global rectangle */
    Rectangle newContent;	    /* new content rectangle */
    Rectangle covers[40];	    /* rectangles of covering windows */
    } Asynch_window_event;

/*----------------------------------------------------------------------+
|									|
|   Gui Window Attributes       					|
|									|
+----------------------------------------------------------------------*/
typedef struct guiwattributes
    {
    unsigned short modal:1;		    /* can't be sinkable, closeable */
    unsigned short moveable:1;
    unsigned short closeable:1;
    unsigned short sizeable:1;
    unsigned short closeOnNew:1;	    /* once used for floating */
    unsigned short sinkable:1;
    unsigned short nonVideo:1;		    /* used for plotting window */
    unsigned short backingStore:1;

    unsigned short popup:1;
    unsigned short alwaysSaveUnder:1;
    
    unsigned short userAllocated:1;
    unsigned short noWindowControlIcon:1;
    unsigned short isFocusable:1;	    /* can accept the input focus */
    unsigned short refusesAutoSwitch:1;	    /* lose focus only explicitly */
    unsigned short noRightIcons:1;	    /* draw right icons */
    unsigned short noTitleBar:1;	    /* skip title bar altogether */
    } GuiWAttributes;

/*----------------------------------------------------------------------+
|									|
|   RenderFlags								|
|									|
+----------------------------------------------------------------------*/
typedef struct renderFlags
    {
    unsigned	ambientLight:1;	    /*	Ambient light on/off */
    unsigned	solarLight:1;	    /*	Solar light on/off */
    unsigned	flashLight:1;	    /*	Flash light on/off */
    unsigned	unused1:13;	    /*  Not currently used */
    unsigned	unused2:16;	    /*  Not currently used */
    }	RenderFlags;
    
/*----------------------------------------------------------------------+
|									|
|   Latitude								|
|									|
+----------------------------------------------------------------------*/
typedef struct latitude
    {
    unsigned	degrees:16;
    unsigned	minutes:8;
    unsigned	seconds:8;
    }	Latitude;
typedef struct latitude    Longitude;

/*----------------------------------------------------------------------+
|									|
|   Solar Time								|
|									|
+----------------------------------------------------------------------*/
typedef struct solarTime    
    {
    unsigned	day:8;
    unsigned	hour:8;
    unsigned	minute:8;
    unsigned	month:4;
    unsigned	pm:1;
    unsigned	dst:1;		    
    unsigned	useCurrentTime:1;
    unsigned	unused:1;
    }	SolarTime;

/*----------------------------------------------------------------------+
|									|
|   Rendering Information (as stored in type 66 element)		|
|									|
+----------------------------------------------------------------------*/
typedef struct renderInfo
    {
    short	    version;
    short	    arcMinimum;
    short	    maxPolygonSize;
    unsigned short  ambientIntensity[3];
    unsigned short  flashIntensity[3];
    unsigned short  solarIntensity[3];
    double	    strokeTolerance;
    RenderFlags	    renderFlags;
    Latitude	    latitude;
    SolarTime	    solarTime;
    Longitude	    longitude;
    } RenderInfo;
    
#endif	/* __mstypesH__ */  
