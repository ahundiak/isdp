/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   pltstrct.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   pltstrct.h -- Plotting Related Definitions				|
|									|
+----------------------------------------------------------------------*/
#ifndef __basetypeH__
#include <basetype.h>
#endif

#ifndef __pltstrctH__
#define __pltstrctH__

/*----------------------------------------------------------------------+
|									|
|   Local Defines							|
|									|
+----------------------------------------------------------------------*/
#define PLOT_BUF_SIZE 1024
#define M_UNITS 1
#define DM_UNITS 2
#define CM_UNITS 3
#define MM_UNITS 4
#define FT_UNITS 5
#define IN_UNITS 6

#define MM_PER_M 1000.0
#define MM_PER_DM 100.0
#define MM_PER_CM 10.0
#define MM_PER_MM 1.0
#define MM_PER_FT 304.8
#define MM_PER_IN 25.4

#define CC907_TYPE  0
#define HP_TYPE	    1
#define HI_TYPE	    2
#define CC960_TYPE  3
#define PS_TYPE	    4
#define HP2_TYPE    5
#define ADI_TYPE    6
    
#define HP7475A	    1
#define HP7580B	    2
#define HP7585B	    3
#define HP7586B	    4
#define HP7550A	    5
#define HP7470A	    6
#define HP7440A	    7
#define HP7595B	    8
#define HP7596B	    9
#define HIDMP52	    10
#define HIDMP56	    10
#define CAL960	    20
#define CAL907	    30
#define CAL906	    31
#define POSTSCRIPT  40
#define LASERWRITER 41
#define HPGL2MODEL  50
#define HPLJET3	    50
#define MDLPLOTTER  60

#define HANDSHAKE_DIRECT    0
#define HANDSHAKE_XONXOFF   1
#define HANDSHAKE_ACKNAK    2

#define EOP_PAUSE	1
#define EOP_EJECT	2
#define EOP_REPLOT	3
#define EOP_BEEP	4

#define PENCHANGE_COLOR	    1
#define PENCHANGE_WEIGHT    2
#define PENCHANGE_BOTH	    3
#define PENCHANGE_LEVEL	    4

#define MOVE_ABSOLUTE	1
#define MOVE_RELATIVE	2

#if !defined (min)
#define min(x,y)    ((x) < (y) ? (x) : (y))
#endif

#define UP			0	    /* plotting pen up */
#define DOWN			1	    /* plotting pen down */
#define MAX_OUTPUT_RESOLUTION	6500
#define LW_SIZE			100
#define PLOTTER_EQUALS		544

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct paper_pnt
    {
    long h;				/* horizontal direction */
    long v;				/* vertical direction */
    } Paper_pnt;

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct dpaper_pnt
    {
    double  h;				/* horizontal direction */
    double  v;				/* vertical direction */
    } Dpaper_pnt;

typedef struct fontmap
    {
    char  fontName[80];   /* plotter font name for activation        */
    short activated;      /* mapping from IGDS font to plotter font. */
			  /* -1 means no hardware font - stroke it   */
    short kern;		  /* user-defined inter-char spacing	     */
    } FontMap;

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct plot_spec		/* plot specification */
    {
    Point3d     origin;			/* origin of plot */
    Dpoint3d    delta;			/* upper right corner */
    Dpoint2d	size;			/* size of plot in plot units */
    Paper_pnt	ll;			/* paper coords-lower left & upper */
    Paper_pnt	ur;			/*  right corner of view to plot */
    Paper_pnt	p1, p2;			/* paper coords of ll & ur on paper */
    Dpaper_pnt	user_off;		/* user specified offset */
    Transform	trans;			/* unrotated paper coords =>rotated */
    short	rotate;			/* rotation query field */
    short	paper_size;		/* integer for paper size */
    short	paper_num;		/* number of paper size (plttr cfg) */
    short	pf_fence;		/* plot from fence flag */
    short	manual_origin;		/* origin set on plotter */
    short	to_file;		/* plot to file instead of device */
    short	vRefNum;		/* plt output fil vol ref num (Mac) */
    double	scale;			/* (master units / plot units) */
    char	bdr_comment [81];	/* comment on border */
    char 	file_name   [MAXFILELENGTH]; /* plot file name */
    char 	config_name [MAXFILELENGTH]; /* config file name */
    char	plotSpec_name [MAXFILELENGTH]; /* fill plotspec frm file */
    } Plot_spec;

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct pltr_papsz
    {
    Dpaper_pnt  bound;			/* size in plot units */
    char	name[10];		/* name for this size */
    short	num;			/* number for this size */
    Dpaper_pnt	offset;			/* offset for origin */
    byte	manual_origin;		/* does this size allow manual orig */
    } Pltr_papsz;

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct pltr_cfg			/* plotter configuration structure */
    {
    double	tolerance;		/* stroking tolerance */
    short	num_papsz;		/* number of different size paper */
    Pltr_papsz	size[5];		/* up to five paper sizes */
    short	num_pens;		/* number of pens */
    short 	units;			/* code for units */
    short	plt_mode;		/* connected in eaves mode */
    short	model;			/* plotter model */
    Dpaper_pnt  resolution;		/* plotting units */
    short	draw_bdr;		/* draw border flag */
    short	bdr_pen;		/* color to use for border */
    short	bdr_time;		/* draw time on border */
    short	bdr_name;		/* draw filename on bdr */
    short	bdr_outline;		/* draw outline around border */
    double	pen_speed[256];		/* pen speed and force */
    long	pen_force[256];
    long	pen_accel[256];		/* pen acceleration */
    double	pattern_len[16]; 	/* pattern length */
    double	pen_separation;		/* sep between pens (CAL960) */
    long	min_line;		/* minimum line length */
    double 	bdr_text_sz;		/* border text size */
    double	scalefctr;		/* default scale factor */
    byte	checksum;		/* use checksumming? */
    byte	eom;			/* end of message character */
    byte	eol1;			/* end of line 1 */
    byte	eol2;			/* end of line 2 */
    byte	handshake;		/* handshake mode */
    byte	sync_codes;		/* number of sync codes */
    byte	sync_value;		/* sync code value */
    byte	auto_center;		/* "auto center" the plot */
    byte	rotate_direction;	/* 0=ccw, 1=cw */
    short	buffersize;		/* plot buffer size */
    short	start_plot;		/* commnd executed at start of plot */
    short	end_plot;		/* command executed at end of plot */
    short	pen_change;		/* command executed on pen change */
    byte	move_mode;		/* movement mode (HP plotters only) */
    byte	def_scale;		/* use a default scale factor */
    byte	hardware_arcs;		/* use hardware arcs */
    short	raster_resolution;	/* use hardware raster plotting */
    short	raster_background;	/* use white or black background */
    int 	linecap;		/* linecap style 0,1,2-PostScript */
    int 	linejoin;		/* linejoin style 0,1,2-PostScript */
    int 	tray;			/* Tray number for Paper */
    double	miter_limit;		/* limits "spikes" frm miter joints */
    FontMap	fMap[128];
    int		replots;		/* number of times to replot dwg */
    int		numbits;		/* number of bits per byte 7 or 8 */
    short	draw_fence;		/* draw fence clip shape */
    short	fence_pen;		/* pen for fence clip shape */
    char	defExtension[10];	/* default extension */
    } Pltr_cfg;

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct pen_chart
    {
    short	curr_pen;		/* current pen number */
    short	using_pen;		/* pen in holder */
    short	new_pen;		/* change pen (1=color, 2=weight) */
    byte	index[256];		/* color index */
    byte 	num_strokes[32];	/* number of strokes for line_wts */
    double 	pen_width[256];		/* pen width (units defnd in resl) */
    byte	hardware_styles[8];	/* use hardware pattern types */
    short	num_style[8];		/* number of vectors in line style */
    unsigned short style[8][16];	/* pattern definitions, (down,up) */
    short	current_weight;		/* curr. line weight if plttr able */
    } Pen_chart;

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct
    {
    unsigned short style[16];		/* table of pattern definitions */
    short num_style;			/* number of vectors in style */
    unsigned short currseg;		/* position into current segment */
    byte pendown;			/* is pen down (TRUE) or up (FALSE) */
    } Style_table;

/*----------------------------------------------------------------------+
|									|
|	Pointers to plotting functions					|
|									|
+----------------------------------------------------------------------*/
typedef struct plot_functions
    {
    int (*initialize)();		/* plotter initialization */
    int (*finishup)();			/* cleanup function */
    int (*plot_text)();			/* text func (NULL if not supprtd) */
    int (*borderText)();		/* border text */
    int (*newPen)();			/* select new pen */
    int (*newLineType)();		/* change line type */
    int (*move)();			/* pen up move */
    int (*draw)();			/* pen down draw */
    int (*raise)();			/* raise pen */
    int (*weight)();			/* weight */
    int (*arc)();			/* plot an arc */
    int (*rasterElmBegin)();		/* start raster element */
    int (*rasterElmEnd)();		/* finish raster element */
    int (*rasterElmDraw)();		/* Plot raster */
    int (*set_clipping)();		/* set hardware clipping limits */
    int (*fillPolygon)();		/* plotting filled shapes and text */
    } Plot_functions;

/*----------------------------------------------------------------------+
|									|
|   Static structure maintained during plot.    			|
|									|
+----------------------------------------------------------------------*/
typedef struct plotStatic
    {
    byte	    plottingBuffer[PLOT_BUF_SIZE];
    short	    plotbuffPtr;
    int		    plotView;
    Point2d	    penPosition;
    int		    posValid;
    int		    penIsDown;
    int		    numFonts;
    short	    plotFileHandle;
    byte	    diskFull;
    byte	    hardwareStyles;
    Plot_spec	    plotSpec;
    Pltr_cfg	    plotter;
    Pen_chart	    penChart;
    Style_table	    stytbl;
    Point3d	    rasterOrigin;
    int		    inRasterElm;
    byte	    mgdsCTable[768];
    char	    plotDriver[128];
    Plot_functions  plotFuncs;
    } PlotStatic;

typedef	struct	plotDrawParam
    {
    int		numPts;
    Point2d	*pts;
    } PlotDrawParam;

typedef struct	plotArcParam
    {
    double	    primary;
    double	    secondary;
    RotMatrix	    *rotMatrix;
    Dpoint3d	    *origin;
    double	    start;
    double	    sweep;
    RITransform	    *currTrans;
    } PlotArcParam;

typedef struct	plotRasterParam
    {
    void    *gwP;	    /* => window */
    long    x1;		    /* => start and end coordinates */
    long    y1;
    long    x2;
    long    y2;
    byte    *buffer;	    /* => data buffer */
    long    bufsiz;	    /* => size of data buffer */
    int	    transparent;
    int	    background;
    int	    format;
    } PlotRasterParam;

typedef struct	plotTextParam
    {
    char	*str;
    byte	fontNum;
    int		height;
    Transform   aug;
    } PlotTextParam;
#endif
