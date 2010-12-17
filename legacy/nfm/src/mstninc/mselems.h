/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   mselems.h  $
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
|   mselems.h -- This file contains the structures that define		|
|		  MicroStation elements.				|
|									|
+----------------------------------------------------------------------*/
#if !defined (__mselemsH__)
#define __mselemsH__

#if !defined (__basedefsH__)
#   include <basedefs.h>
#endif
#if !defined (__basetypeH__)
#   include <basetype.h>
#endif
#if !defined (__mstypesH__)
#   include <mstypes.h>
#endif

/* Definitions specific to element conversion processing */

#define	FIXEDDEPTH  0	    /* Fixed Z depth */
#define	ELEMHIGH    1	    /* High range value of Z range */
#define	ELEMLOW	    2	    /* Low range value of Z range */

/*----------------------------------------------------------------------+
|									|
|   Type	Description						|
|    1		Cell Library Header					|
|    2		Cell (complex)						|
|    3 		Line							|
|    4		Line String						|
|    5 		Group Data						|
|    6		Shape							|
|    7		Text Node (complex)					|
|    8 		Digitizer Setup Data					|
|    9		Design File Header					|
|    10		Level Symbology						|
|    11		Curve							|
|    12		Complex String (complex)				|
|    13	    	Conic							|
|    14		Complex Shape (complex)					|
|    15		Ellipse							|
|    16		Arc							|   
|    17		Text							|
|    18		Surface (complex)					|
|    19		Solid (complex)						|
|    20		not used						|
|    21		B-Spline Pole						|
|    22		Point String						|
|    23		Circular Truncated Cone					|
|    24		B-Spline Surface (complex)				|
|    25		B-Spline Surface boundary				|
|    26		B-Spline Knot Element					|
|    27		B-Spline Curve (complex)				|
|    28		B-Spline Weight Factor					|
|    33         Dimension Element		    			|
|    34		Shared Cell Definition Element				|
|    35		Shared Cell Element					|
|    36         Multiline Element	    		    	    	|
|    58         MicroStation Text Array Element				|
|    59         MicroStation Text Stack Element				|
|    66		MicroStation Application				|
|    87		Raster Header						|
|    88		Raster Component					|
|									|
+----------------------------------------------------------------------*/
#define	    CELL_LIB_ELM	1 
#define	    CELL_HEADER_ELM	2 
#define	    LINE_ELM		3 
#define	    LINE_STRING_ELM	4 
#define	    GROUP_DATA_ELM	5 
#define	    SHAPE_ELM		6 
#define	    TEXT_NODE_ELM	7 
#define	    DIG_SETDATA_ELM	8 
#define	    DGNFIL_HEADER_ELM	9 
#define	    LEV_SYM_ELM		10 
#define	    CURVE_ELM		11 
#define	    CMPLX_STRING_ELM	12 
#define	    CONIC_ELM		13 
#define	    CMPLX_SHAPE_ELM	14 
#define	    ELLIPSE_ELM		15 
#define	    ARC_ELM		16 
#define	    TEXT_ELM		17 
#define	    SURFACE_ELM		18 
#define	    SOLID_ELM		19 
#define	    BSPLINE_POLE_ELM	21
#define	    POINT_STRING_ELM	22
#define	    CONE_ELM		23
#define	    BSPLINE_SURFACE_ELM	24
#define	    BSURF_BOUNDARY_ELM	25
#define	    BSPLINE_KNOT_ELM	26
#define	    BSPLINE_CURVE_ELM	27
#define	    BSPLINE_WEIGHT_ELM	28
#define	    DIMENSION_ELM	33
#define	    SHAREDCELL_DEF_ELM	34
#define	    SHARED_CELL_ELM	35
#define     MULTILINE_ELM	36
#define	    TEXT_ARRAY_ELM	58
#define	    TEXT_STACK_ELM	59
#define	    MICROSTATION_ELM	66
#define	    RASTER_HDR		87
#define	    RASTER_COMP		88

/*----------------------------------------------------------------------+
|									|
|  Element Type Masks - Can be used to set up type masks for scanner	|
|			or element modification commands		|
|									|
+----------------------------------------------------------------------*/
/* The following masks must be 'OR'ed with typemask[0] */
#define ELMBITMSK(elmNum)	(1<<((elmNum-1)%16))
#define TMSK0_CELL_LIB		ELMBITMSK (CELL_LIB_ELM)
#define TMSK0_CELL_HEADER	ELMBITMSK (CELL_HEADER_ELM)
#define TMSK0_LINE		ELMBITMSK (LINE_ELM)
#define TMSK0_LINE_STRING	ELMBITMSK (LINE_STRING_ELM)
#define TMSK0_GROUP_DATA	ELMBITMSK (GROUP_DATA_ELM)
#define TMSK0_SHAPE		ELMBITMSK (SHAPE_ELM)
#define TMSK0_TEXT_NODE		ELMBITMSK (TEXT_NODE_ELM)
#define TMSK0_DIG_SETDATA	ELMBITMSK (DIG_SETDATA_ELM)
#define TMSK0_DGNFIL_HEADER	ELMBITMSK (DGNFIL_HEADER_ELM)
#define TMSK0_LEV_SYM		ELMBITMSK (LEV_SYM_ELM)
#define TMSK0_CURVE		ELMBITMSK (CURVE_ELM)
#define TMSK0_CMPLX_STRING	ELMBITMSK (CMPLX_STRING_ELM)
#define TMSK0_CONIC		ELMBITMSK (CONIC_ELM)
#define TMSK0_CMPLX_SHAPE	ELMBITMSK (CMPLX_SHAPE_ELM)
#define TMSK0_ELLIPSE		ELMBITMSK (ELLIPSE_ELM)
#define TMSK0_ARC		ELMBITMSK (ARC_ELM)

/* These following masks must be 'OR'ed with typemask[1] */
#define TMSK1_TEXT		ELMBITMSK (TEXT_ELM)
#define TMSK1_SURFACE		ELMBITMSK (SURFACE_ELM)
#define TMSK1_SOLID		ELMBITMSK (SOLID_ELM)
#define TMSK1_BSPLINE_POLE	ELMBITMSK (BSPLINE_POLE_ELM)
#define TMSK1_POINT_STRING	ELMBITMSK (POINT_STRING_ELM)
#define TMSK1_CONE		ELMBITMSK (CONE_ELM)
#define TMSK1_BSPLINE_SURFACE	ELMBITMSK (BSPLINE_SURFACE_ELM)
#define TMSK1_BSURF_BOUNDARY	ELMBITMSK (BSURF_BOUNDARY_ELM)
#define TMSK1_BSPLINE_KNOT	ELMBITMSK (BSPLINE_KNOT_ELM)
#define TMSK1_BSPLINE_CURVE	ELMBITMSK (BSPLINE_CURVE_ELM)
#define TMSK1_BSPLINE_WEIGHT	ELMBITMSK (BSPLINE_WEIGHT_ELM)
    
/* These following masks must be 'OR'ed with typemask[2] */
#define TMSK2_DIMENSION	    	ELMBITMSK (DIMENSION_ELM)
#define TMSK2_SHAREDCELL_DEF	ELMBITMSK (SHAREDCELL_DEF_ELM)
#define TMSK2_SHARED_CELL	ELMBITMSK (SHARED_CELL_ELM)
#define TMSK2_MULTILINE	    	ELMBITMSK (MULTILINE_ELM)

/* These following masks must be 'OR'ed with typemask[3] */
#define TMSK3_TEXT_ARRAY	ELMBITMSK (TEXT_ARRAY_ELM)
#define TMSK3_TEXT_STACK	ELMBITMSK (TEXT_STACK_ELM)

/* These following masks must be 'OR'ed with typemask[5] */
#define	TMSK5_RASTER_HDR	ELMBITMSK (RASTER_HDR)
#define	TMSK5_RASTER_COMP	ELMBITMSK (RASTER_COMP)


/*----------------------------------------------------------------------+
|									|
|	Level definitions						|
|									|
+----------------------------------------------------------------------*/
#define	    MSDIM_LEVEL		1
#define	    MSREF_LEVEL		5
#define	    MSLEVELNAME_LEVEL	6
#define	    MSDIG_LEVEL		8
#define	    MSTCB_LEVEL		9
#define	    MSVIEW_LEVEL	7
#define	    MSSTARTAPP_LEVEL	10
						
/* NOTE: database control elements have levels 11-19 reserved */
#define	    MSDB_LEVEL		10	/* dBASE	    */
#define	    MSIX_LEVEL		11	/* Informix	    */
#define	    MSRIS_LEVEL		12	/* RIS		    */
#define	    MSORACLE_LEVEL	13	/* Oracle	    */
						
#define	    MSAPPINFO_LEVEL	20
#define	    MSSTARTMDL_LEVEL	21
#define	    MSMLINE_LEVEL	22

/*----------------------------------------------------------------------+
|									|
|	Class definitions						|
|									|
+----------------------------------------------------------------------*/
#define	    PRIMARY_CLASS		0
#define	    PATTERN_COMPONENT_CLASS	1
#define	    CONSTRUCTION_CLASS		2
#define	    DIMENSION_CLASS		3
#define	    PRIMARY_RULE_CLASS		4
#define	    LINEAR_PATTERNED_CLASS	5
#define	    CONSTRUCTION_RULE_CLASS	6

/*----------------------------------------------------------------------+
|									|
|	Element transformation structures				|
|									|
+----------------------------------------------------------------------*/
typedef struct lTrans2d
    {
    long    t11;
    long    t12;
    long    t21;
    long    t22;    
    } LTrans2d;

typedef struct lTrans3d
    {
    long    t11;
    long    t12;
    long    t13;
    long    t21;
    long    t22;    
    long    t23;
    long    t31;
    long    t32;
    long    t33;
    } LTrans3d;

/*----------------------------------------------------------------------+
|									|
|   Element Header structure - common to all MicroStation elements	|
|									|
+----------------------------------------------------------------------*/
typedef struct elm_hdr
    {
#if !defined (mc68000)
    unsigned	    level:6;    /* level element is on */
    unsigned	    igresvd:1;  /* reserved by Intergraph */
    unsigned	    complex:1;  /* part of complex element (cell) if set */
    unsigned	    type:7;	/* type of element */
    unsigned	    deleted:1;  /* set if element is deleted */
#else				/* bit fields in reverse order for 680x0 */
    unsigned	    deleted:1;  /* set if element is deleted */
    unsigned	    type:7;	/* type of element */
    unsigned	    complex:1;  /* part of complex element (cell) if set */
    unsigned	    igresvd:1;  /* reserved by Intergraph */
    unsigned	    level:6;    /* level element is on */
#endif
    unsigned short  words;	/* number of words to follow in element */
    unsigned long   xlow;	/* range of element - low (reversed longs) */
    unsigned long   ylow;
    unsigned long   zlow;
    unsigned long   xhigh;	/* range of element - high (reversed longs) */
    unsigned long   yhigh;
    unsigned long   zhigh;		
    } Elm_hdr;

/*----------------------------------------------------------------------+
|									|
|   Extended Level Element Header Structure - used for 127 level cases  |
|									|
+----------------------------------------------------------------------*/
typedef struct extlev_hdr
    {
#if !defined (mc68000)
    unsigned	    level:7;	/* level element is on */
    unsigned	    complex:1;	/* part of complex element (cell) if set */
    unsigned	    type:7;	/* type of element */
    unsigned	    deleted:1;	/* set if element is deleted */
#else				/* bit fields in reverse order for 680x0 */
    unsigned	    deleted:1;	/* set if element is deleted */
    unsigned	    type:7;	/* type of element */
    unsigned	    complex:1;	/* part of complex element (cell) if set */
    unsigned	    level:7;	/* level element is on */
#endif
    unsigned short  words;	/* number of words to follow in element */
    unsigned long   xlow;	/* range of element - low (reversed longs) */
    unsigned long   ylow;
    unsigned long   zlow;
    unsigned long   xhigh;	/* range of element - high (reversed longs) */
    unsigned long   yhigh;
    unsigned long   zhigh;		
    } Extlev_hdr;

/*----------------------------------------------------------------------+
|    									|
|   Display header - common to all displayed MicroStation elements	|
|									|
+----------------------------------------------------------------------*/
typedef struct disp_hdr
    {
    unsigned short  grphgrp;	/* graphics group number */
    short	    attindx;	/* words between this and attribute linkage */

    union
	{
	short	    s;
	struct
	    {
#if !defined (mc68000)
	    unsigned	class:4;    /* element class */
	    unsigned	:4;	    /* reserved by Intergraph */
	    unsigned	l:1;	    /* locked */
	    unsigned	n:1;	    /* new */
	    unsigned	m:1;	    /* modified */
	    unsigned	a:1;	    /* attributes present */
	    unsigned	r:1;	    /* relative to: 0=database 1=screen */    
	    unsigned	p:1;	    /* planar */
	    unsigned	s:1;	    /* 0=snappable, 1=nonsnappable */
	    unsigned	h:1;	    /* hole or solid (usually) */
#else
	    unsigned	h:1;	    /* hole or solid (usually) */
	    unsigned	s:1;	    /* 0=snappable, 1=nonsnappable */
	    unsigned	p:1;	    /* planar */
	    unsigned	r:1;	    /* relative to: 0=database 1=screen */    
	    unsigned	a:1;	    /* attributes present */
	    unsigned	m:1;	    /* modified */
	    unsigned	n:1;	    /* new */
	    unsigned	l:1;	    /* locked */
	    unsigned	:4;	    /* reserved by Intergraph */
	    unsigned	class:4;    /* element class */
#endif
	    } b;
	} props;
    
    union
	{
	short	    s;
	Symbology   b;
	} symb;

    } Disp_hdr;
						
typedef struct header 
    {
    Elm_hdr	    ehdr;
    Disp_hdr	    dhdr;
    } Header;
						
/*----------------------------------------------------------------------+
|									|
|   Cell Library Header Element (type 1, only in cell libraries)	|
|									|
+----------------------------------------------------------------------*/
typedef struct cell_lib_hdr
    {
    Elm_hdr	    ehdr;	    /* element header */
    short	    celltype;	    /* cell type */
    short	    attindx;	    /* attribute linkage */
    long	    name;	    /* radix-50 cell name */
    unsigned short  numwords;	    /* number of words in descriptions */
    short	    properties;	    /* properties */
    short	    dispsymb;	    /* display symbology */
    short	    class;	    /* cell class (always 0) */
    short	    levels[4];	    /* levels used in cell */
    short	    descrip[9];	    /* cell description */
    } Cell_Lib_Hdr;

/*----------------------------------------------------------------------+
|    									|
|   2-D Cell Element (complex element, type 2)				|
|									|
+----------------------------------------------------------------------*/
typedef struct cell_2d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    unsigned short  totlength;	    /* total length of cell */
    long	    name;	    /* radix 50 name */
    short	    class;	    /* class bit map */
    short	    levels[4];	    /* levels used in cell */
    Point2d	    rnglow;	    /* range block lo */
    Point2d	    rnghigh;	    /* range block hi */
    LTrans2d	    trans;	    /* transformation matrix */
    Point2d	    origin;	    /* cell origin */
    } Cell_2d;

/*----------------------------------------------------------------------+
|    									|
|   3-D Cell Element (complex element, type 3)				|
|									|
+----------------------------------------------------------------------*/
typedef struct cell_3d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    unsigned short  totlength;	    /* total length of cell */
    long	    name;	    /* radix 50 name */
    short	    class;	    /* class bit map */
    short	    levels[4];	    /* levels used in cell */
    Point3d	    rnglow;	    /* range block lo */
    Point3d	    rnghigh;	    /* range block hi */
    LTrans3d	    trans;	    /* transformation matrix */
    Point3d	    origin;	    /* cell origin */
    } Cell_3d;

/*----------------------------------------------------------------------+
|									|
|   2-D Line Element (type 3)						|
|									|
+----------------------------------------------------------------------*/
typedef struct line_2d
    {
    Elm_hdr	ehdr;	    /* element header */
    Disp_hdr	dhdr;	    /* display header */
    Point2d	start;	    /* starting point */
    Point2d	end;	    /* ending point */
    } Line_2d;

/*----------------------------------------------------------------------+
|									|
|   3-D Line Element (type 3)						|
|									|
+----------------------------------------------------------------------*/
typedef struct line_3d
    {
    Elm_hdr	ehdr;	    /* element header */
    Disp_hdr	dhdr;	    /* display header */
    Point3d	start;	    /* starting point */
    Point3d	end;	    /* ending point */
    } Line_3d;

/*----------------------------------------------------------------------+
|									|
|   2-D Line String Element (type 4)					|
|									|
|   Same structure represents 2-D Shape Elements (type 6), 2-D Curve	|
|   Elements (type 11), and 2-D Conic Elements (type 13).  Shapes differ|
|   from line strings in that shape elements always start and end at	|
|   the same point.  Curve and conic elements use the first and last    |
|   vertices to establish the slope at the beginning and end.		|
|									|
+----------------------------------------------------------------------*/
typedef struct line_string_2d
    {
    Elm_hdr	ehdr;		/* element header */
    Disp_hdr	dhdr;		/* display header */
    short	numverts;	/* number of vertices */
    Point2d	vertice[1];	/* points */
    } Line_String_2d;

/*----------------------------------------------------------------------+
|									|
|   3-D Line String Element (type 4)					|
|									|
|   See comments for 2-D Line String Element.				|
|									|
+----------------------------------------------------------------------*/
typedef struct line_string_3d
    {
    Elm_hdr	ehdr;		/* element header */
    Disp_hdr	dhdr;		/* display header */
    short	numverts;	/* number of vertices */
    Point3d	vertice[1];	/* points */
    } Line_String_3d;

/*----------------------------------------------------------------------+
|									|
|   Reference File Attachment Element (type 5, level 9)			|
|									|
+----------------------------------------------------------------------*/
typedef struct ref_file_type5
    {
    Elm_hdr	ehdr;		    /* element header */
    Disp_hdr	dhdr;		    /* display header */
    short	file_chars;	    /* number of characters in file spec */
    char	file_spec[65];	    /* file specification */
    byte	file_num;	    /* file number */
    Fb_opts	fb_opts;	    /* file builder options mask */
    Fd_opts	fd_opts;	    /* file displayer options mask */
    byte	disp_flags[16];	    /* display flags */
    short	lev_flags[8][4];    /* level on/of flags */
    long	ref_org[3];	    /* origin in reference file uors */
    double	trns_mtrx[9];	    /* transformation matrix */
    double	cnvrs_fact;	    /* conversion factor */
    long	mast_org[3];	    /* origin in master file uors */
    short	log_chars;	    /* characters in logical name */
    char	log_name[22];	    /* logical name (padded) */
    short	desc_chars;	    /* characters in description */
    char	description[42];    /* description (padded) */
    short	lev_sym_mask;	    /* level symbology enable mask */
    short	lev_sym[63];	    /* level symbology descriptor */	
    long	z_delta;	    /* Z-direction delta */
    short	clip_vertices;	    /* clipping vertices */
    Point2d	clip_poly[1];	    /* clipping polygon */
    } Ref_file_type5;

/*----------------------------------------------------------------------+
|									|
|   Named view element (type 5, level 3)				|
|									|
+----------------------------------------------------------------------*/
typedef struct named_view_type5
    {
    Elm_hdr	ehdr;		    /* element header */
    short	grphgrp;	    /* graphics group number */
    short	attindx;	    /* words between this and attrb linkage */
    short	properties;	    /* property bits (always the same) */
#if !defined (mc68000)
    unsigned	short num_views:3;  /* number of views */
    unsigned	short reserved:13;  /* reserved for Intergraph */
#else
    unsigned	short reserved:13;  /* reserved for Intergraph */
    unsigned	short num_views:3;  /* number of views */
#endif
    char	viewdef_descr[18];  /* view definition description */
    byte	full_scr1;
    byte	full_scr2;
    Viewinfo	view[1];
    char	rest_of_elem[1];    /* record has variable length */
    } Named_view_type5;

/*----------------------------------------------------------------------+
|									|
|   Color table element (type 5, level 1)				|
|									|
+----------------------------------------------------------------------*/
typedef struct color_table_type5
    {
    Elm_hdr	ehdr;		/* element header */
    Disp_hdr	dhdr;		/* display header */
    short	screen_flag;	/* screen flag */
    byte	color_info[1];  /* color table information */
    } Color_table_type5;

/*----------------------------------------------------------------------+
|									|
|   short pattern (type 5, level 0)					|
|									|
+----------------------------------------------------------------------*/
typedef struct short_pattern_type5
    {
    Elm_hdr	ehdr;		/* element header */
    Disp_hdr	dhdr;		/* display header */
    short	indicator;
    long	name;
    double	scale;
    double	angle;
    long	row_spacing;
    long	column_spacing;
    } Short_pattern_type5;

/*----------------------------------------------------------------------+
|									|
|   long pattern (type 5, level 0)					|
|									|
+----------------------------------------------------------------------*/
typedef struct long_pattern_type5
    {
    Elm_hdr	    ehdr;		/* element header */
    Disp_hdr	    dhdr;		/* display header */
    short	    indicator;
    long	    name;
    double	    scale;
    double	    angle;
    long	    row_spacing;
    long	    column_spacing;
    Seven_wd_lknm   library;		/* file spec */
    Symbology	    symbology;
    short	    fbfdcn;
    byte	    master_type;
    byte	    request_type;
    Point2d	    idpoint;
    Point2d	    accpoint;
    } Long_pattern_type5;

/*----------------------------------------------------------------------+
|									|
|   Auxilliary Coordinate System (type 5, level 3)			|
|									|
+----------------------------------------------------------------------*/
typedef struct aux_coordinate
    {
    Elm_hdr	ehdr;		    /* element hdr (origin stored in range) */
    short	grphgrp;	    /* graphics group number */
    short	attindx;	    /* words between this and attrb linkage */
    short	properties;	    /* property bits (always the same) */
#if !defined (mc68000)
    unsigned	short type:3;	    /* number of views */
    unsigned	short reserved:13;  /* reserved for Intergraph */
#else
    unsigned	short reserved:13;  /* reserved for Intergraph */
    unsigned	short type:3;	    /* number of views */
#endif
    char	description[18];    /* definition description */
    double	trans[3][3];		
    short	attribute;	    /* 0001000000000011 */
    short	user_id;	    /* always 22 */
    long	name;		    /* 6 characters stored RAD50 */
    } Aux_coordinate;

/*----------------------------------------------------------------------+
|									|
|   2-D Text Node Element (complex element, type 7)			|
|									|
+----------------------------------------------------------------------*/
typedef struct text_node_2d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    unsigned short  totwords;	    /* total words following (cmplx ele) */
    short	    numstrngs;	    /* number of text strings in node */
    unsigned short  nodenumber;	    /* text node number */
    byte	    maxlngth;	    /* maximum length allowed */
    byte	    maxused;	    /* maximum length used */
    byte	    font;	    /* text font used */
    byte	    just;	    /* justification type */
    long	    linespc;	    /* line spacing */
    long	    lngthmult;	    /* length multiplier */
    long	    hghtmult;	    /* height multiplier */
    long	    rotation;	    /* rotation angle */
    Point2d	    origin;	    /* origin */
    } Text_node_2d;

/*----------------------------------------------------------------------+
|									|
|   3-D Text Node Element (complex element, type 7)			|
|									|
+----------------------------------------------------------------------*/
/* Text Node Element (note: this is a complex element) */
typedef struct text_node_3d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    unsigned short  totwords;	    /* total words following (cmplx ele) */
    short	    numstrngs;	    /* number of text strings in node */
    unsigned short  nodenumber;	    /* text node number */
    byte	    maxlngth;	    /* maximum length allowed */
    byte	    maxused;	    /* maximum length used */
    byte	    font;	    /* text font used */
    byte	    just;	    /* justification type */
    long	    linespc;	    /* line spacing */
    long	    lngthmult;	    /* length multiplier */
    long	    hghtmult;	    /* height multiplier */
    long	    quat[4];	    /* quaternion rotations */
    Point3d	    origin;	    /* origin */
    } Text_node_3d;

/*----------------------------------------------------------------------+
|    									|
|   Design file header (type 9) 					|
|									|
+----------------------------------------------------------------------*/
typedef struct dgn_header
    {
    Elm_hdr	    ehdr;	    /* element header */
    short	    tcbinfo[1];	    /* tcb information */
    } Dgn_header;

/*----------------------------------------------------------------------+
|									|
|    Complex string (type 12, complex)					|
|									|
+----------------------------------------------------------------------*/
typedef struct complex_string
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    unsigned short  totlength;	    /* total length of surface */
    unsigned short  numelems;	    /* number of elements in surface */
    short	    attributes[4];  /* to reach minimum elem size */
    } Complex_string;


/*----------------------------------------------------------------------+
|    									|
|   2-D Ellipse Element (type 15)					|
|									|
+----------------------------------------------------------------------*/
typedef struct ellipse_2d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    double	    primary;	    /* primary axis */
    double	    secondary;	    /* secondary axis */
    long	    rotation;	    /* rotation angle */
    Dpoint2d	    origin;	    /* origin */
    } Ellipse_2d;

/*----------------------------------------------------------------------+
|    									|
|   3-D Ellipse Element (type 15)					|
|									|
+----------------------------------------------------------------------*/
typedef struct ellipse_3d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    double	    primary;	    /* primary axis */
    double	    secondary;	    /* secondary axis */
    long	    quat[4];	    /* quaternion rotations */
    Dpoint3d	    origin;	    /* origin */
    } Ellipse_3d;


/*----------------------------------------------------------------------+
|									|
|   2-D Arc Element (type 16)						|
|									|
+----------------------------------------------------------------------*/
typedef struct arc_2d
    {
    Elm_hdr	    ehdr;
    Disp_hdr	    dhdr;
    long	    startang;	    /* start angle */
    long	    sweepang;	    /* sweep angle */
    double	    primary;	    /* primary axis */
    double	    secondary;	    /* secondary axis */
    long	    rotation;	    /* rotation angle */
    Dpoint2d	    origin;	    /* origin */
    } Arc_2d;

/*----------------------------------------------------------------------+
|									|
|   3-D Arc Element (type 16)						|
|									|
+----------------------------------------------------------------------*/
typedef struct arc_3d
    {
    Elm_hdr	    ehdr;
    Disp_hdr	    dhdr;
    long	    startang;	    /* start angle */
    long	    sweepang;	    /* sweep angle */
    double	    primary;	    /* primary axis */
    double	    secondary;	    /* secondary axis */
    long	    quat[4];	    /* quaternion rotations */
    Dpoint3d	    origin;	    /* origin */
    } Arc_3d;

/*----------------------------------------------------------------------+
|									|
|   2-D Text Element (type 17)						|
|									|
+----------------------------------------------------------------------*/
typedef struct text_2d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    byte	    font;	    /* text font used */
    byte	    just;	    /* justification type */
    long	    lngthmult;	    /* length multiplier */
    long	    hghtmult;	    /* height multiplier */
    long	    rotation;	    /* rotation angle */
    Point2d	    origin;	    /* origin */
    byte	    numchars;	    /* # of characters */
    byte	    edflds;	    /* # of enter data fields */
    char	    string[2];	    /* characters */
    } Text_2d;
    
/*----------------------------------------------------------------------+
|									|
|   3-D Text Element (type 17)						|
|									|
+----------------------------------------------------------------------*/
typedef struct text_3d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    byte	    font;	    /* text font used */
    byte	    just;	    /* justification type */
    long	    lngthmult;	    /* length multiplier */
    long	    hghtmult;	    /* height multiplier */
    long	    quat[4];	    /* quartion angle */
    Point3d	    origin;	    /* origin */
    byte	    numchars;	    /* # of characters */
    byte	    edflds;	    /* # of enter data fields */
    char	    string[2];	    /* characters */
    } Text_3d;

/*----------------------------------------------------------------------+
|									|
|    Surface (type 18, complex)	    3d only				|
|									|
+----------------------------------------------------------------------*/
typedef struct surface
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    unsigned short  totlength;	    /* total length of surface */
    unsigned short  numelems;	    /* number of elements in surface */
    byte	    surftype;	    /* surface type */
    byte	    boundelms;	    /* number of boundary elements */
#ifdef unix
    short	    filler;	    /* needed for proper alignment */
#endif
    short	    attributes[4];  /* attribute data */
    } Surface;

/*----------------------------------------------------------------------+
|									|
|   2-D  B-Spline pole element (type 21)				|
|									|
+----------------------------------------------------------------------*/
typedef struct bspline_poles_2d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    short	    numpoles;	    /* number of poles */
    Point2d	    poles[1];	    /* points */
    } Bspline_pole_2d;

/*----------------------------------------------------------------------+
|									|
|   3-D  B-Spline pole element (type 21)				|
|									|
+----------------------------------------------------------------------*/
typedef struct bspline_pole_3d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    short	    numpoles;	    /* number of poles */
    Point3d	    poles[1];	    /* points */
    } Bspline_pole_3d;

/*----------------------------------------------------------------------+
|									|
|   Circular truncated cone  (type 23)    3-D files only		|
|									|
+----------------------------------------------------------------------*/
typedef struct cone_3d
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    struct
	{
#if !defined (mc68000)
	unsigned short	type:3;	    /* cone type */
	unsigned short	rsrv:12;    /* reserved */
	unsigned short	surf:1;	    /* 0 = solid, 1 = surface */
#else
	unsigned short	surf:1;	    /* 0 = solid, 1 = surface */
	unsigned short	rsrv:12;    /* reserved */
	unsigned short	type:3;	    /* cone type */
#endif
	} b;
    long	    quat[4];	    /* orientation quaternion */
    Dpoint3d	    center_1;	    /* center of first circle */
    double	    radius_1;	    /* radius of first circle */
    Dpoint3d	    center_2;	    /* center of second circle */
    double	    radius_2;	    /* radius of second cirele */    
    } Cone_3d;

/*----------------------------------------------------------------------+
|									|
|   Bspline flags							|
|									|
+----------------------------------------------------------------------*/
typedef struct	bspline_flags 
    {
#if !defined (mc68000)
    unsigned short  order:4;		/* order - 2*/
    unsigned short  curve_display:1;	/* curve display flag */
    unsigned short  poly_display:1;	/* polygon display flag */
    unsigned short  rational:1;		/* rationalization flag */
    unsigned short  closed:1;		/* closed curve flag */
    unsigned short  curve_type:8;	/* curve type */
#else
    unsigned short  curve_type:8;	/* curve type */
    unsigned short  closed:1;		/* closed curve flag */
    unsigned short  rational:1;		/* rationalization flag */
    unsigned short  poly_display:1;	/* polygon display flag */
    unsigned short  curve_display:1;	/* curve display flag */
    unsigned short  order:4;		/* order - 2 */
#endif
    } Bspline_flags;
    
/*----------------------------------------------------------------------+
|									|
|   Bspline surface flags						|
|									|
+----------------------------------------------------------------------*/
typedef struct bsurf_flags 
    {
#ifndef mc68000
    unsigned short v_order:4;		/* b-spline order - 2 (v Direction)*/
    unsigned short reserved1:2;		/* reserved */
    unsigned short arcSpacing:1;	/* rule lines spaced by arc length */
    unsigned short v_closed:1;		/* closed curve flag */
    unsigned short reserved2:8;		/* reserved */
#else
    unsigned short reserved2:8;		/* reserved */
    unsigned short v_closed:1;		/* closed curve flag */
    unsigned short arcSpacing:1;	/* rule lines spaced by arc length */
    unsigned short reserved1:2;		/* reserved */
    unsigned short v_order:4;		/* b-spline order (v Direction)*/
#endif
    } Bsurf_flags;
    
/*----------------------------------------------------------------------+
|									|
|   Bspline surface header	(type 24)				|
|									|
+----------------------------------------------------------------------*/
typedef struct bspline_surface
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    long	    desc_words;	    /* # words in description */
    Bspline_flags   flags;	    /* miscellaneous flags */
    short	    num_poles_u;    /* number of poles */
    short	    num_knots_u;    /* number of knots */
    short	    rule_lines_u;   /* number of rule lines */
    Bsurf_flags	    bsurf_flags;    /* bspline surface flags */
    short	    num_poles_v;    /* number of poles */
    short	    num_knots_v;    /* number of knots */
    short	    rule_lines_v;   /* number of rule lines */
    short	    num_bounds;	    /* number of boundaries */
    } Bspline_surface;

/*----------------------------------------------------------------------+
|									|
|   B-spline Surface boundary (type 25)					|
|									|
+----------------------------------------------------------------------*/
typedef struct bsurf_boundary
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    short	    number;	    /* boundary number */
    short	    numverts;	    /* number of boundary vertices */
    Point2d	    vertices[1];    /* boundary points (in UV space) */
    } Bsurf_boundary;

/*----------------------------------------------------------------------+
|									|
|   B-spline weight	factor (type 26)				|
|									|
+----------------------------------------------------------------------*/
typedef struct bspline_weight 
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    long	    weights[1];	    /* bspline weights (variable length) */
    } Bspline_weight;

/*----------------------------------------------------------------------+
|									|
|   B-spline curve header  (type 27)					|
|									|
+----------------------------------------------------------------------*/
typedef struct bpsline_curve
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    long	    desc_words;	    /* # words in description */
    Bspline_flags   flags;	    /* miscellaneous flags */
    short	    num_poles;	    /* number of poles */
    short	    num_knots;	    /* number of knots */
    } Bspline_curve;

/*----------------------------------------------------------------------+
|									|
|   B-spline knot vector (type 28)					|
|									|
+----------------------------------------------------------------------*/
typedef struct bspline_knot 
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    long	    knots[1];	    /* knots (variable length) */
    } Bspline_knot;
	
/*----------------------------------------------------------------------+
|									|
|   Shared Cell Instance (type 35) - complete definition unpublished    |
|									|
+----------------------------------------------------------------------*/
typedef struct scOverride
    {
    unsigned short  level:1;	    /* level override (true for pnt cells)  */
    unsigned short  relative:1;	    /* relative or absolute		    */
    unsigned short  class:1;	    /* class value */
    unsigned short  color:1;	    /* color of all components */
    unsigned short  weight:1;	    /* weight of all components */
    unsigned short  style:1;	    /* style of all components */
    unsigned short  assocPnt:1;	    /* origin of cell is associative point */
    unsigned short  unused:9;
    } SCOverride;

/*----------------------------------------------------------------------+
|									|
| name		element_union - union of all element types		|
|									|
+----------------------------------------------------------------------*/
typedef union msElementUnion
    {
    Cell_Lib_Hdr    cell_lib_hdr;
    Cell_2d         cell_2d;
    Cell_3d	    cell_3d;
    Line_2d	    line_2d;
    Line_3d	    line_3d;
    Line_String_2d  line_string_2d;
    Line_String_3d  line_string_3d;
    Text_node_2d    text_node_2d;
    Text_node_3d    text_node_3d;
    Complex_string  complex_string;
    Ellipse_2d	    ellipse_2d;
    Ellipse_3d	    ellipse_3d;
    Arc_2d	    arc_2d;	
    Arc_3d	    arc_3d; 
    Text_2d	    text_2d;
    Text_3d	    text_3d;
    Cone_3d	    cone_3d;
    Surface	    surf;
    Bspline_pole_2d bspline_pole_2d;
    Bspline_pole_3d bspline_pole_3d;
    Bspline_curve   bspline_curve;
    Bspline_surface bspline_surface;
    Bspline_weight  bspline_weight;
    Bspline_knot    bspline_knot;
    Bsurf_boundary  bsurf_boundary;
    short	    tmp[768];
#if defined (ip32)
    short	    buf[780];
#else
    short	    buf[780];
#endif
    Extlev_hdr	    extlevhdr;
    Elm_hdr	    ehdr;
    Header	    hdr;
    } MSElementUnion, MSElement;

/*----------------------------------------------------------------------+
|									|
|   Element Descriptor structure					|
|									|
+----------------------------------------------------------------------*/
typedef struct msElementDescr MSElementDescr;
struct msElementDescr
    {
    struct 
	{
	MSElementDescr	*next;		/* ptr to first entry in list */
	MSElementDescr	*previous;	/* ptr to last entry in list */
	MSElementDescr	*myHeader;	/* ptr to my hdr (NULL = not cmplx) */
	MSElementDescr	*firstElem;	/* ptr to first element if header */
	int		isHeader;	/* is this a complex header */
	int		isValid;	/* INTERNAL USE ONLY */
	long		userData1;	/* available for user */
	long		userData2;	/* available for user */
	} h;
    MSElement     	el;		/* elem data (hdr only if complex) */
    };

#endif	/* __mselemsH__ */
