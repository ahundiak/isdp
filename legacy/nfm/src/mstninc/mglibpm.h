/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   mglibpm.h  $
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
|   mglibpm.h -- describes how MicroStation interacts with Protected	|
|		 Mode Graphics Drivers					|
|									|
+----------------------------------------------------------------------*/
#ifndef __mglibpmH__
#define __mglibpmH__

/*----------------------------------------------------------------------+
|									|
|  MGL Function Codes							|
|									|
+----------------------------------------------------------------------*/
#define SETTEXT     1
#define SETGRAPH    2
#define SLINPATN    3
#define SLINSTYL    4
#define RSTLPAT     5
#define GPLOTPOS    6
#define PLOTLINE    7
#define PLOT2D	    8
#define PLOT3D	    9
#define PLOTPT	    10
#define OUTLBOX     11
#define STEXTSTYL   12
#define RASTERTEXT  13
#define HWRESET	    14
#define GSCRNPARM   15
#define CLRRECT     16
#define CLRSWAP     17
#define SSCRNSIG    18
#define SAVESCRN    19
#define RESTSCRN    20
#define CHNGPAGE    21
#define SETCLUT     22
#define INITCOLS    23
#define SETLWGHT    24
#define	SAVERECT    25
#define	RESTRECT    26
#define	COPYRECT    27
#define	SCURSSTYL   28
#define	DRAWCURS    29

/*----------------------------------------------------------------------+
|									|
|  MGL Data Structures							|
|									|
+----------------------------------------------------------------------*/
typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    char    data[1];		    /* data follows... */
    } Mglpacket;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    } Settext;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int bios;			    /* TRUE if bios directed to this screen */
    } Setgraph;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    unsigned short _far *linpatn;   /* line pattern array */
    } Slinpatn;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int patnindex;		    /* line pattern index */
    int color;			    /* line color */
    int drawmode;		    /* line drawing mode */
    int weight;			    /* pixel width of lines */
    } Slinstyl;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    } Rstlpat;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    short _far *x;		    /* returned x coord */
    short _far *y;		    /* returned y coord */
    } Gplotpos;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int x;			    /* new x coord */
    int y;			    /* new y coord */
    int pen;			    /* pen status */
    } Plotline;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    Point2d _far *array;	    /* 2d point array */
    int vertices;		    /* no. points */
    } Plot2d;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    Point3d _far *array;	    /* 3d point array */
    int vertices;		    /* no. points */
    } Plot3d;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int x;			    /* x coord */
    int y;			    /* y coord */
    } Plotpt;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int color;			    /* box color */
    Spoint2d origin;		    /* upper left */
    Spoint2d corner;		    /* lower right */
    } Outlbox;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int xmag;			    /* magnification of char width */
    int ymag;			    /* magnification of char height */
    int fgcolor;		    /* character color */
    int bgcolor;		    /* background color */
    int drawmode;		    /* char drawing mode */
    int font;			    /* raster character font index */
    } Stextstyl;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    Spoint2d point;		    /* text origin */
    char _far *string;		    /* null terminated text string */
    int direction;		    /* text draw direction */
    } Rastertext;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int xmax;			    /* max. visible x coord. */
    int ymax;			    /* max. visible y coord. */
    int origin;			    /* origin location */
    int chwidth;		    /* current raster char width */
    int chheight;		    /* current raster char height */
    int colors;			    /* no. colors */
    int scrnx;			    /* screen width in mm */
    int scrny;			    /* screen height in mm */
    int bios;			    /* bios directed to this screen */
    short capability;		    /* graphic card capability level */
    short extParm0;		    /* extended parameters 0 */
    short extParm1;		    /* extended parameters 1 */
    short reserved[14];		    /* reserved */
    } Gscrnparm;

/* ---- Defines for extParm0 ---- */	
				    /* For SAVERECT/RESTRECT:	    */
#define EPARM0_PIXFMT0	0x0001	    /*   format 0 - compact	    */
#define EPARM0_PIXFMT1	0x0002	    /*   format 1 - byte	    */
#define EPARM0_PIXFMT2	0x0004	    /*   format 2 - RGB		    */
#define EPARM0_COPYRECT 0x0080	    /* COPYRECT supported	    */
#define EPARM0_CURSOR	0x0100	    /* raster cursor supported	    */
#define EPARM0_SWAP	0x0200	    /* swap screen available	    */
#define EPARM0_PROTMODE 0x8000	    /* protected mode driver	    */

/* ---- Defines for extParm1 ---- */	
#define EPARM1_PALGUNSZ	0x0007	    /* bits per palette gun (0=8)   */

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int color;			    /* fill color */
    Rectangle rect;		    /* rectangle definition */
    } Clrrect;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    } Clrswap;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int dispenb;		    /* enable or disable display */
    } Sscrnsig;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    char _far *tempdir;		    /* path to temporary save directory */
    } Savescrn;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    } Restscrn;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int display;		    /* displayed page no. */
    int drawing;		    /* modified page no. */
    } Chngpage;

typedef struct 
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    Rectangle srcrect;
    Point2d destpt;
    } Copyrect;

typedef struct 
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    long _far *enablepattern;
    long _far *datapattern;
    Spoint2d hotspot;
    int	fgcolor;
    int bgcolor;
    } Scursstyl;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    int	visible;
    Spoint2d position;
    } Drawcurs;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    char _far *cmap;		    /* color table array */
    int readflag;		    /* read or write table */
    } Setclut;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    } Initcols;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    short _far *lwmap;		    /* lineweight translation array */
    int readflag;		    /* read or write table */
    } Setlwght;

typedef struct
    {
    int mglfunc;		    /* function code */
    int status;			    /* status */
    Spoint2d upperleft;		    /* first pixel */
    Spoint2d lowerright;	    /* last pixel */
    char _far *array;		    /* data area (offset only) */
    int reqsize;		    /* requested buffer size */		
    int actsize;		    /* actual buffer size */	
    int pixfmt;			    /* pixel storage format */		    
    long tag;			    /* internal data */		    
    } PixrectPM;

#endif
