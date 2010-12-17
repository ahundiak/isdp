/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Header: /usr2/pinnacle/division/nfmspc/nfm/mstninc/RCS/userpref.h 1.1 1995/10/17 23:24:04 pinnacle Exp $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   userpref.h -- MicroStation User Preferences Definitions		|
|									|
+----------------------------------------------------------------------*/
#ifndef __mscfgH__
#define __mscfgH__

#include    <msdefs.h>
#define	    DEFDGNFILE_ID	-101
#define	    DEFIMAGEFILE_ID	-102
    
    
typedef struct userprefscomp
    {
    int		    major;		/* major revision */
    int		    minor;		/* minor revision */
    long	    reserved;		/* generally, in house revision */
    } UserPrefsComp;
    
typedef struct userprefsflags
    {
    unsigned	    iconSize:1;		    /* 0-small, 1-large */
    unsigned	    cursorIso:1;	    /* 0-normal, 1=iso */
    unsigned	    cursorFull:1;	    /* 0-normal, 1=full screen */
    unsigned	    fenceReset:1;	    /* 0-dont allow reset,1-allow it*/
    unsigned	    windowTitles:1;	    /* 0-no title bars, 1-have em */
    unsigned	    singleClick:1;	    /* 0-single shot, 1-locked */
    unsigned	    paletteBlackHighlight:1;/* 0-mgrey highlighting */
    unsigned	    paletteInterGap:2;	    /* pixels between palette icons */
    unsigned	    paletteBorderGap:2;	    /* pixels betw win brd & icons */
    unsigned	    paletteWideBevel:1;	    /* 0 = 1 pixel icon bevels */
    unsigned	    palettesBoth:1;	    /* TRUE = on both virtual */
    unsigned	    hiliteFocusWindow:1;    /* TRUE = hilite focus window */
    unsigned	    blinkCursor:1;	    /* TRUE = blink the cursor */
    unsigned	    unused:1;
    } UserPrefsFlags;

typedef struct moreprefsflags
    {
    unsigned	    refViewflags:1;     /* TRUE = use ref file viewflags */
    unsigned	    refLocateDef:1;     /* TRUE = ref locate on by default */
    unsigned	    refSnapDef:1;	/* TRUE = ref snap on by default */
    unsigned	    tileLikeIGDS:1;	/* TRUE = tile windows in IGDS mode */
    unsigned	    parseDefault:1;	/* TRUE = parseall on by default */
    unsigned	    textLineStyle:1;	/* TRUE = use line styles for text */
    unsigned	    conserveMemory:1;	/* TRUE = dont use range tree */
    unsigned	    useRefColorTables:1;/* TRUE = dont use ref color tables */
    unsigned	    applyLocksToTent:1;	/* TRUE = lock tentative points */
    unsigned	    unused:7;
    } MorePrefsFlags;

typedef struct userprefs
    {
    VersionNumber	version;	/* userpref version */
    UserPrefsFlags	flags;
    long		defCommand;	/* Default command (none, select) */
    UserPrefsComp	compatability;	/* MS compatability (4.0, 3.x) */
    long		cacheSize;	/* size of cache in K */
    long		pointerSize;	/* pointer size in K */
    int			taskSize;	/* ext. pgm conv. mem size in K */
    int			taskSizeExt;	/* ext. pgm ext. mem size in K */
    long		undoBufSize;	/* size of undo buffer in K */
    int			smallText;	/* size of smallest text */
    int			exactColors;	/* number of exact colors desired */
    int			maxRefFiles;	/* max number of reference file */
    int			locateTol;	/* location tolerance */
    int			maxGrid;	/* maximum grids per view */
    int			maxRefGrid;	/* maximum reference grids per view */
    char		edChar;		/* enter data character */
    long    	    	rscCacheSize; 	/* size of Rsc Mgr cache in K */
    int			backgroundColor;/* background color */
    int			cmdWindowID;	/* dialog box ID of Command Window */
    byte		chainConnects;	/* 0=forget it, 1=quick, 2=slow */
    MorePrefsFlags	moreFlags;
    short		classMask;	/* default displayable classes */
    short		doubleClickTime;/* double click time */
    short		editorEOLChar;	/* end of line in text editor */
    char		systemRoot[10];		/* system root name */
    char		titleRoot[10];		/* title root name */
    char		dlogNormRoot[10];	/* dialog normal root name */
    char		dlogBoldRoot[10];	/* dialog bold root name */
    char		dlogFixRoot[10];	/* dialog fixed root name */
    char		dlogFixBoldRoot[10];	/* dialog fixed bold root */
    short		systemPointSize[2];	/* system point Size r/l */
    short		titlePointSize[2];	/* title point size r/l */
    short		dialogPointSize[2];	/* dialog point size r/l */
#if defined (msdos)    
    Spoint2d		screenSizeOverride[2];	   /* screen size override */
    short		extParm0OverrideMask[2];   /* driver eparm override */
#endif    
    } UserPrefs;
#endif
