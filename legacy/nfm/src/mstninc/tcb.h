/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   tcb.h  $
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
|   tcb.h -- Typedefs and Defines for the MicroStation "terminal	|
|	     control block".  This data structure basically contains	|
|	     all of the "current" information about the design file	|
|	     being edited.						|
|									|
+----------------------------------------------------------------------*/
#if !defined (__tcbH__)
#define __tcbH__

#if !defined (__basetypeH__)
#   include    <basetype.h>
#endif
#if !defined (__basedefsH__)
#   include    <basedefs.h>
#endif
#if !defined (__msdefsH__)
#   include    <msdefs.h>
#endif
#if !defined (__mstypesH__)
#   include	<mstypes.h>
#endif	

#define MSVERSION	    0x400   /* MicroStation Version 4.0.0 */
    
typedef struct ext_dimflags
    {
#if !defined (mc68000)
    unsigned joiner:1;
    unsigned boxtext:1;
    unsigned semiauto:1;
    unsigned leading_zero:1;
    unsigned trailing_zeros:1;
    unsigned decimal_comma:1;
    unsigned captext:1;
    unsigned superscriptLSD:1;
    unsigned roundLSD:1;
    unsigned omitLeadingDelimeter:1;
    unsigned colorOverride:1;
    unsigned weightOverride:1;
    unsigned textColorOverride:1;
    unsigned textWeightOverride:1;
    unsigned fontOverride:1;
    unsigned levelOverride:1;
    unsigned textSizeOverride:1;
    unsigned compatible:1;           /* If set place as IGDS primitives     */
    unsigned arrowhead:2;	     /* 0=Open, 1=Closed, 2=Filled	    */
    unsigned useRefUnits:1;	     /* 1-use reference file units	    */
    unsigned relDimLine:1;
    unsigned underlineText:1;
    unsigned styleOverride:1;
    unsigned noAutoTextLift:1;
    unsigned arrowOut:1;	     /* Reverse terminators (JIS)	    */
    unsigned unused2:6;
#else
    unsigned unused2:6;
    unsigned arrowOut:1;
    unsigned noAutoTextLift:1;
    unsigned styleOverride:1;
    unsigned underlineText:1;
    unsigned relDimLine:1;
    unsigned useRefUnits:1;
    unsigned arrowhead:2;  
    unsigned msDimensionElm:1;
    unsigned textSizeOverride:1;
    unsigned levelOverride:1;
    unsigned fontOverride:1;
    unsigned textWeightOverride:1;
    unsigned textColorOverride:1;
    unsigned weightOverride:1;
    unsigned colorOverride:1;
    unsigned omitLeadingDelimeter:1;
    unsigned roundLSD:1;
    unsigned superscriptLSD:1;
    unsigned captext: 1;
    unsigned decimal_comma:1;
    unsigned trailing_zeros:1;
    unsigned leading_zero:1;
    unsigned semiauto:1;
    unsigned boxtext:1;
    unsigned joiner:1;
#endif
    } Ext_dimflags;

typedef struct dim_template
    {
#if !defined (mc68000)
    unsigned first_term:3;
    unsigned left_term:3;
    unsigned right_term:3;
    unsigned bowtie_symbol:3;
    unsigned pre_symbol:3;
    unsigned stacked:1;
    unsigned post_symbol:3;
    unsigned above_symbol:3;
    unsigned left_witness:1;
    unsigned right_witness:1;
    unsigned vertical_text:1;
    unsigned nofit_vertical:1;
    unsigned centermark: 1;
    unsigned centerLeft:1;
    unsigned centerRight:1;
    unsigned centerTop:1;
    unsigned centerBottom:1;
    unsigned reserved:1;
#else
    unsigned reserved:1;
    unsigned centerBottom:1;
    unsigned centerTop:1;
    unsigned centerRight:1;
    unsigned centerLeft:1;
    unsigned centermark:1;
    unsigned nofit_vertical:1;
    unsigned vertical_text:1;
    unsigned right_witness:1;
    unsigned left_witness:1;
    unsigned above_symbol:3;
    unsigned post_symbol:3;
    unsigned stacked:1;
    unsigned pre_symbol:3;
    unigned bowtie_symbol:3;
    unsigned right_term:3;
    unsigned left_term:3;
    unsigned first_term:3;
#endif
    } Dim_template;

typedef struct autodim1
    {
    byte	  english;    	    /* english format accuracy 		    */
    byte	  metric;	    /* metric format accuracy 		    */
    struct
	{
#if !defined (mc68000)
        UShort	  level:8;    	    /* auto dimensioning placement level    */
	UShort	  parallel:2;
	UShort	  automan:1;
	UShort	  term:1;
	UShort	  witness:1;
	UShort	  just:2;
	UShort	  labang:1;
#else
	unsigned  labang:1;
	unsigned  just:2;
	unsigned  witness:1;
	unsigned  term:1;
	unsigned  automan:1;
	unsigned  parallel:2;
        unsigned  level:8;    	    /* auto dimensioning placement level    */
#endif
	} mode;
#if defined (unix)
    short dummy1;
#endif
    struct
	{
#if !defined (mc68000)
	UShort	  actlev:8;	    /* active level 			    */
	UShort	  metric:1;	    /* use metric system as primary	    */
	UShort	  dual:1;	    /* dimensioning measurement system 	    */
	UShort	  tolerance:1;	    /* tolerance generation		    */
	UShort	  tolmode:1;	    /* tolerancing mode			    */
	UShort	  embedded:1;	    /* text placement mode		    */
	UShort	  horizontal:1;	    /* horizontal text			    */
	UShort	  aec:1;	    /* mechanical or aec dimensioning	    */
	UShort	  reserved:1;  
#else
	unsigned  reserved:1;	    
	unsigned  aec:1;	    /* mechanical or aec dimensioning	    */
	unsigned  horizontal:1;	    /* horizontal text 			    */
	unsigned  embedded:1;	    /* text placement mode 		    */
	unsigned  tolmode:1;	    /* tolerancing mode			    */
	unsigned  tolerance:1;	    /* tolerance generation		    */
	unsigned  dual:1;	    /* dimensioning measurement system 	    */
	unsigned  metric:1;	    /* use metric system as primary 	    */
	unsigned  actlev:8;	    /* active level			    */
#endif
	} params;		    /* auto dimensioning parameters 	    */

#if defined (unix)
    short dummy2;
#endif

    struct
	{
#if !defined (mc68000)
	UShort	  adres2:8;
	UShort	  ref_mastersub:2;
	UShort	  ref_decfract:1;
	UShort	  adp_subunits:1;
 	UShort	  adp_label:1;
	UShort	  adp_delimiter:1;
	UShort	  reserved:2;
#else
	unsigned  reserved:2;
	unsigned  adp_delimiter:1;
 	unsigned  adp_label:1;
	unsigned  adp_subunits:1;
	unsigned  ref_decfract:1;
	unsigned  ref_mastersub:2;
	unsigned  adres2:8;
#endif
	} format;
#if defined (unix)
    short dummy3;
#endif
    } Autodim1;
    	    	    	    	    
typedef struct autodim2
    {				      
    byte          arrfont;          /* font for active arrowhead terminator */
    byte          arrhead;          /* active arrowhead 		    */
    byte          oblqfont;    	    /* font number for oblique terminator   */
    byte          oblique;     	    /* oblique terminator 		    */
    byte          cofont;	    /* font # for common origin terminator  */
    byte          comorg;	    /* common origin terminator 	    */
    byte          diamfont;         /* font number for diameter terminator  */
    byte          diam;	            /* diameter terminator 		    */
    ULong         txheight;    	    /* text height 			    */
    long          lowtol;	    /* lower tolerance 			    */
    long          uptol;	    /* upper tolerance 			    */
    } Autodim2;

typedef struct
    {
    byte          angle;	    /* angle readout specification 	    */
    byte          refdispl;         /* refresh display 			    */
    } Autodim3;

typedef struct autodim4
    {
    double	  toltxt_scale;	    /* Size of tolerance text	      (*th) */
    double	  witness_offset;   /* Length of witness offset	      (*th) */
    double	  witness_extend;   /* Length or witness extension    (*th) */
    double	  dimension_scale;  /* Text value scale factor	      (*th) */
    double	  text_margin;	    /* Minimum leader with text inside(*th) */
    Ext_dimflags  ext_dimflg;	    /* 32 bit bit field 		    */			    
    Dim_template  dim_template[24]; /* Dimension command/tool settings	    */
    long	  stack_offset;	    /* Optional stack offset (uors)	    */
    long	  dimcen;	    /* Optional center mark size (uors)	    */
    short	  curr_dimcmd;	    /* Dimension command/template index	    */

    struct
	{
	char	  main_prefix;	    /* Optional prefix char for main text   */
	char	  main_suffix;	    /* Optional suffix char for main text   */
	char	  tol_prefix;	    /* Optional prefix char for tolerance   */
	char	  tol_suffix;	    /* Optional suffix char for tolerance   */
	char	  upper_prefix;	    /* Optional prefix char for upper text  */
	char	  upper_suffix;	    /* Optional suffix char for upper text  */
	char	  lower_prefix;	    /* Optional prefix char for lower text  */
	char	  lower_suffix;	    /* Optional suffix char for lower text  */
	} dimtxt;

    byte	  dim_color;	    /* Optional dimension element color	    */	
    byte	  dim_weight;	    /* Optional dimension element weight    */
    byte	  dimtxt_color;	    /* Optional dimension text color	    */
    byte	  dimtxt_weight;    /* Optional dimension text weight	    */
    byte	  dimfont;	    /* Optional dimension text font	    */
    byte	  bowtie_font;	    /* Optional font for joint terminator   */
    byte	  bowtie_symbol;    /* Optional char for joint terminator   */
    byte	  dim_style;	    /* Optional dimension element style	    */
    } Autodim4;

typedef struct
    {			    	    /* *th - Units = text height	    */
    double     	  textMarginV;	    /* Text dist above dimension line (*th) */
    double     	  textMarginH;	    /* Text dist from leader end      (*th) */
    double     	  tolMarginV;	    /* Tolerance dist from text base  (*th) */
    double     	  tolMarginH;	    /* Space from text to tolerance   (*th) */
    double     	  tolSepV;	    /* Vert space between tol values  (*th) */
    double     	  termHeight;	    /* Height of terminator tile      (*th) */
    double     	  termWidth;	    /* Width of terminator tile	      (*th) */
    ULong      	  textWidth;        /* Dimension text width (uors)     	    */
    struct
        {
        UShort	  useWidth:1;	    /* If set use ad5 text width over active*/
	UShort    altStyle:1;	    /* Use alt style			    */
	UShort    altWeight:1;	    /* Use alt weight			    */
	UShort    altColor:1;	    /* Use alt color			    */
	UShort    useSecUnits:1;    /* Use optionsl secondary units	    */
	UShort    reserved1:11;
	UShort    reserved2:16;
        } flags;
    struct
	{
    	UShort	  style:3;           /* Alternate line style		    */
    	UShort    weight:5;          /* Alternate line weight		    */
    	UShort	  color:8;           /* Alternate line color		    */
	} altSymb;
    byte     	  reserved[2];
    struct			     /* Optional secondary unit definition  */
    	{			     /* for override in dual dimensions	    */
    	ULong     subPerMast;        /* Sub-units per master unit	    */
    	ULong     uorPerSub;         /* uors per sub unit		    */
    	char      mastName[2];       /* Master units name 		    */
    	char      subName[2];        /* Sub units name 			    */
    	} secUnits;
    } Autodim5;

typedef struct		       /* Replacement dimension symbols/terminators */
    {
    struct
	{		       /* Flag values:				    */
	UShort  arrow:4;       /* 0 - None. Use built in terminator/symbol  */
	UShort  stroke:4;      /* 1 - Symbol from font 			    */
	UShort  origin:4;      /* 2 - Shared cell    	    	 	    */
	UShort  dot:4;	       /*     	    	    	    	    	    */
	UShort  prefix:4;      /* Dimension prefix			    */
	UShort  suffix:4;      /* Dimension suffix			    */
	UShort  diameter:4;    /* Diameter symbol			    */
	UShort  plusMinus:4;   /* Plus/Minus symbol			    */
	UShort  res2:16;
	UShort  res3:16;
	} flags;

    long       arrow;          /* Cell name for replacement arrow (Radix50) */	
    long       stroke;         /* Cell name for replacement stroke(Radix50) */	
    long       origin;         /* Cell name for replacement origin(Radix50) */	
    long       dot;	       /* Cell name for replacement dot   (Radix50) */
    long       prefix;         /* Cell name for dimension prefix  (Radix50) */
    long       suffix;         /* Cell name for dimension suffix  (Radix50) */
    byte       preChar;	       /* Replacement prefic character		    */
    byte       preFont;	       /* Replacement prefix font		    */
    byte       sufChar;	       /* Replacement suffix character		    */
    byte       sufFont;	       /* Replacement suffix font		    */
    byte       pmChar;	       /* Replacement Plus/Minus character	    */
    byte       res1[3];
    long       reserved[6];
    } Autodim6;

typedef struct
    {				     
    UShort	style:3;       	    /* Optional line style		    */	  
    UShort      weight:5;      	    /* Optional line weight		    */
    UShort	color:8;       	    /* Optional line color		    */
    UShort    	useStyle:1;	    /* Use optional style		    */
    UShort      useWeight:1;	    /* Use optional weight		    */
    UShort    	useColor:1;	    /* Use optional color		    */
    UShort    	capInArc:1;	    /* Show cap inner arcs		    */
    UShort    	capOutArc:1;	    /* Show cap outer arcs		    */
    UShort    	capLine:1;	    /* Show cap line			    */
    UShort      useClass:1;	    /* Use class bit over display header    */
    UShort    	reserved:1;
    UShort      level:7;	    /* Optional line level (0 for default)  */
    UShort    	conClass:1;	    /* Line is construction class	    */
    } MlineSymbology;
    
typedef struct
    {
    long           dist;            /* Line distance from work line	    */
    MlineSymbology symb;            /* Line symbology			    */
    } MlineProfile;

typedef struct 		    	    /* Current Multiline settings	    */
    {	       	    		    /* ** TYPEDEF IS USED IN STYLE FILE	**  */
    double             orgAngle;    /* Origin cap angle			    */
    double	       endAngle;    /* End cap angle			    */
    MlineProfile       profile[16]; /* Profiles				    */
    MlineSymbology     orgCap;	    /* Origin cap symbology		    */
    MlineSymbology     endCap;	    /* End cap symbology		    */
    MlineSymbology     midCap;	    /* Joint line symbology		    */

    long               orgRadius;   /* Origin cap arc radius		    */
    long               endRadius;   /* End cap arc radius		    */
    long               height;	    /* Multiline height (in z direction)    */
    byte               nLines;	    /* Number of lines per segment	    */
    byte    	       fillColor;   /* Color for filled multilines  	    */
    struct
	{
	UShort	       compatible:1;/* Place multilines as IGDS primitives  */
	UShort	       filled:1;	
	UShort	       reserved:14;
	} flags;
    byte	       reserved2[4];
    } MultilineTCB;

typedef struct			    /* Information about current element    */
    {			    	    /*     filled in by locate function     */
    Dpoint3d    point;	    	    /* Point on located element		    */
    ULong       filePos;	    /* File position of located element	    */
    byte        elemType;	    /* Type of element located		    */
    short	elemNumber;	    /* Number of element (if compound)	    */
    union			    /* Element specific information	    */
        {
	double		reserved[12];
        struct		    	    /* Line string locate information	    */
    	    {
    	    Dvector3d  segPoints;   /* Closest segment points		    */
    	    byte       vertex;	    /* Closest vertex to locate point	    */
    	    byte       segment;	    /* Located segment (zero based)	    */
    	    } lineString;

        struct		    	    /* Multiline locate information	    */
            {
    	    Dvector3d segPoints;    /* Closest segment to locate point	    */
            byte      vertex;	    /* Closest vertex to locate point	    */
            byte      segment;	    /* Located line segment (zero based)    */
            byte      lineNo;	    /* Profile line number		    */
	    byte      capNo;	    /* 0-None, 1-origin, 2-mid, 3-end	    */
            } mline;

        struct		    	    /* Dimension locate information	    */
            {
    	    Dvector3d segPoints;    /* Closest segment to locate point	    */
    	    double    stackHeight;  /* StackHeight at locate		    */
            byte      pointNo;      /* Closest point in dimension element   */
            byte      segment;      /* Selected dimension segment	    */
            byte      elemType;     /* Primitive element type located	    */
    	    byte      component;    /* Dimension component (witness, text..)*/
            } dim;
        struct		    	    /* Bspline locate information     	    */
    	    {
    	    boolean   polygonSnap;
    	    double    u;
    	    double    v;
    	    } bspline;
        } u;
    } LocateInfo;

typedef struct dyntable
    {
    double		zoom;	    /* dynamic zoom factor */
    short		panx;	    /* dynamic pan factors */
    short		pany;
    } Dyntable;

typedef struct
    {
    Seven_wd_lknm	name;	    /* file spec */
    short		levels[4];  /* level bit map */
    unsigned short	endsect;    /* ending sector */
    } Oldref;

typedef struct cntrlwd
    {
#if !defined (mc68000)
    unsigned	    grid_lock:1;    /* grid lock in effect */
    unsigned	    unit_lock:1;    /* unit lock in effect */
    unsigned	    rsrv3:1;	    /* reserved */
    unsigned	    stream_mode:1;  /* point/stream mode */
    unsigned	    delay_pattrn:1; /* delayed patterning */
    unsigned	    dis_asp:1;	    /* display aspect ratio */
    unsigned	    rsrv2:2;	    /* reserved */
    unsigned	    inh_msg:1;	    /* inhibit CF, ST and PR messages */
    unsigned	    inh_err:1;	    /* inhibit err msgs (except fatal) */
    unsigned	    rsrv1:4;	    /* reserved */
    unsigned	    wind_alt:1;	    /* display window altered */
    unsigned	    overview:1;	    /* overview on */
#else
    unsigned	    overview:1;	    /* overview on */
    unsigned	    wind_alt:1;	    /* display window altered */
    unsigned	    rsrv1:4;	    /* reserved */
    unsigned	    inh_err:1;	    /* inhibit err msgs (except fatal) */
    unsigned	    inh_msg:1;	    /* inhibit CF, ST and PR messages */
    unsigned	    rsrv2:2;	    /* reserved */
    unsigned	    dis_asp:1;	    /* display aspect ratio */
    unsigned	    delay_pattrn:1; /* delayed patterning */
    unsigned	    stream_mode:1;  /* point/stream mode */
    unsigned	    rsrv3:1;	    /* reserved */
    unsigned	    unit_lock:1;    /* unit lock in effect */
    unsigned	    grid_lock:1;    /* grid lock in effect */
#endif
    } Cntrlwd;

typedef struct ext_locks
    {
#if !defined (mc68000)
    unsigned	    axis_lock:1;
    unsigned	    auxinp:1;
    unsigned	    show_pos:1;
    unsigned	    autopan:1;
    unsigned	    axis_override:1;
    unsigned	    cell_stretch: 1;
    unsigned	    iso_grid:1;
    unsigned	    obsolete1:1;
    unsigned	    obsolete2:1;
    unsigned	    iso_plane:2;	/* 0=Top, 1=Left, 2=Right, 3=ALL*/
    unsigned	    selection_set:1;
    unsigned	    auto_handles:1;
    unsigned	    single_shot:1;	/* user selected single shot */
    unsigned	    dont_restart:1;	/* cmd doesnt want to be restart*/
    unsigned	    viewSingle_shot:1;
    unsigned	    snapCnstplane:1;
    unsigned	    cnstPlanePerp:1;
    unsigned	    fillMode:1;
    unsigned	    iso_lock:1;
    unsigned	    extendedLevels:1;
    unsigned	    intersectionSnap:1;
    unsigned	    association:1;	/* let snap create associations	    */
    unsigned	    sharedCells:1;	/* place cells in shared mode */
    unsigned	    fenceVoid:1;
    unsigned	    fastDynamics:1;
    unsigned	    snappablePatterns:1;
    unsigned	    unused2:5;
#else
    unsigned	    unused2:5;
    unsigned	    snappablePatterns:1;/* enable snappable patterns */
    unsigned	    fastDynamics:1;	/* set dynamics slow/fast */
    unsigned	    fenceVoid:1;	/* 0=inside, 1=outside */
    unsigned	    sharedCells:1;	/* place cells in shared mode */
    unsigned	    association:1;	/* lock as on/off */
    unsigned	    intersectionSnap:1;	/* lock snap intersection on/off */
    unsigned	    extendedLevels:1;
    unsigned	    iso_lock:1;		/* lock isoplane on/off */
    unsigned	    fillMode:1;		/* set fill on/off */
    unsigned	    cnstPlanePerp:1;	/* datapnts placed perp to con plane*/
    unsigned	    snapCnstplane:1;	/* snap to construction plane */
    unsigned	    viewSingle_shot:1;
    unsigned	    dont_restart:1;	/* cmd doesnt want to be restart*/
    unsigned	    single_shot:1;	/* single shot from palette */
    unsigned	    auto_handles:1;	/* new elements have handles */
    unsigned	    selection_set:1;
    unsigned	    iso_plane:2;	/* 0=Top, 1=Left, 2=Right, 3=ALL*/
    unsigned	    full_cursor: 1;	/* set cursor full */
    unsigned	    iso_cursor:1;	/* set cursor isometric */
    unsigned	    iso_grid:1;		/* active gridmode isometric */
    unsigned	    cell_stretch: 1;	/* lock cellstrech on/off */
    unsigned	    axis_override:1;	/* override active axis for blocks */
    unsigned	    autopan:1;		/* unused */
    unsigned	    show_pos:1;		/* unused */
    unsigned	    auxinp:1;		/* set auxinput on/off */
    unsigned	    axis_lock:1;	/* lock ax on/off */
#endif
    } Ext_locks;

typedef struct
    {
#if !defined (mc68000)
    unsigned	    dragen:1;
    unsigned	    dragact:1;
    unsigned	    snpele:1;
    unsigned	    allowuc:1;
    unsigned	    noele:1;
    unsigned	    inflin:1;
    unsigned	    noout:1;
    unsigned	    fcmail:1;
    unsigned	    prompt_uc:1;	/* prompt even though in UC */
    unsigned	    uc_messages:1;	/* use user cmd msg field */
    unsigned	    inhibit_parse:1;    /* inhibit T,E and keyin parse */
    unsigned	    spare:5;
#else
    unsigned	    spare:5;
    unsigned	    inhibit_parse:1;
    unsigned	    prompt_uc:1;
    unsigned	    uc_messages:1;
    unsigned	    fcmail:1;
    unsigned	    noout:1;
    unsigned	    inflin:1;
    unsigned	    noele:1;
    unsigned	    allowuc:1;
    unsigned	    snpele:1;
    unsigned	    dragact:1;
    unsigned	    dragen:1;
#endif
    } Outflg;

typedef struct
    {
    short	    len;
    char	    c[42];
    } Ucm_register;

/*----------------------------------------------------------------------+
|									|
|   This structure defines the portion of the TCB which is stored in 	|
|   the two type 9's in the design file.				|
|									|
+----------------------------------------------------------------------*/
typedef struct tcb
    {
    Cntrlwd	    control;	/* control word				1 */
    double	    rndunit;	/* unit lock roundoff val in uors	2 */
    unsigned long   uorgrid;	/* uors per grid			6 */
    short	    refgrid;	/* grid points per reference grid point	8 */
    byte	    vwfull1;	/* view # on scrn 1 (full scrn mode)	9 */
    byte	    vwfull2;	/* "    "      "  "    2 		9 */
    Viewinfo	    view[8];	/* view information for each view 	10 */
    Viewinfo	    dig;	/* digitizer information 		482 */
    Viewinfo	    aux;	/* auxiliary coord system information	541 */
    unsigned long   mastunits;	/* master units per design (unsigned) 	600 */
    unsigned long   subpermast;	/* sub-units per master unit (unsigned) 602 */
    unsigned long   uorpersub;	/* uors per sub unit (unsigned) 	604 */
    char	    mastname[2];/* master units name 			606 */
    char	    subname[2];	/* sub units name 			607 */
    double	    actangle;	/* active angle 			608 */
    double	    anglernd;	/* angle round-off 			612 */
    double	    xactscle;	/* active scale in x-axis 		616 */
    double	    yactscle;	/* active scale in y-axis 		620 */
    double	    zactscle;	/* active scale in z-axis 		624 */
    double	    rndscle;	/* scale lock roundoff value		628 */
    unsigned long   chheight;	/* character height (uors)		632 */
    unsigned long   chwidth;	/* character width (uors)		634 */
    unsigned long   nodespace;	/* vert uors between chars in text node	636 */
    byte	    nodelen;	/* maximum line length in node		638 */
    byte	    nodejust;	/* text node justification value (0-14)	638 */
    byte	    actfont;	/* active font number			639 */
    byte	    anglefmt;	/* angle readout format			639 */
    unsigned short  graphic;	/* next graphics group number		640 */
    byte	    txtjust;	/* text justification value (0-14)	641 */
    byte	    rfcntrl;	/* reference file control flag		641 */
    byte	    tentmode;	/* tentative point mode flag		642 */
    byte	    tentsubmode;/* tentative point sub mode		642 */
    double	    azimuth;	/* azimuth true north angle		643 */
    Autodim1	    ad1;	/* automatic dimensioning flags		647 */
    short	    props;	/* element properties word		651 */
    Symbology	    symbology;	/* element symbology word		652 */
    struct
	{
#if !defined (mc68000) 
	unsigned    solidhole:1;    /* solid/hole flag */
	unsigned    scalelk:1;	    /* scale lock on */
	unsigned    txnodelk:1;	    /* text node lock */
	unsigned    anglelk:1;	    /* angle lock */
	unsigned    snaplk:1;	    /* snap lock */
	unsigned    mirrorch:1;	    /* mirror characters */
	unsigned    design3d:1;	    /* design 3-d bit */
	unsigned    library3d:1;    /* library 3-d bit */
	unsigned    linewidth:1;    /* lines with width */
	unsigned    fenceclip:1;    /* fence clip mode */
	unsigned    gglk:1;	    /* graphic group lock */
	unsigned    levellk:1;	    /* level lock */
	unsigned    assactatt:1;    /* assign active attribute */
	unsigned    padding:1;	    /* pads to 16 bits */
	unsigned    attsrch:1;	    /* attribute search enabled */
	unsigned    overlap:1;	    /* overlap or inside fence lock */
#else
	unsigned    overlap:1;	    /* overlap or inside fence lock */
	unsigned    attsrch:1;	    /* attribute search enabled */
	unsigned    padding:1;	    /* pads to 16 bits */
	unsigned    assactatt:1;    /* assign active attribute */
	unsigned    levellk:1;	    /* level lock */
	unsigned    gglk:1;	    /* graphic group lock */
	unsigned    fenceclip:1;    /* fence clip mode */
	unsigned    linewidth:1;    /* lines with width */
	unsigned    library3d:1;    /* library 3-d bit */
	unsigned    design3d:1;	    /* design 3-d bit */
	unsigned    mirrorch:1;	    /* mirror characters */
	unsigned    snaplk:1;	    /* snap lock */
	unsigned    anglelk:1;	    /* angle lock */
	unsigned    txnodelk:1;	    /* text node lock */
	unsigned    scalelk:1;	    /* scale lock on */
	unsigned    solidhole:1;    /* solid/hole flag */
#endif
	} fbfdcn;		/* fb/fd control word			653 */
    Point3d	    low;	/* range - lo (reversed, unsigned)	654 */
    Point3d	    high;	/* range - high				660 */
    Dpoint3d	    globorg;	/* global origin - UORs			666 */
    Seven_wd_lknm   celllib;	/* cell library name			678 */
    unsigned short  cellendsec;	/* ending sector of cell file		685 */
    short	    cellendbyte;/* ending byte of cell file 		686 */
    unsigned short  grgrpbas;	/* graphics group base number		687 */
    unsigned short  nodebase;	/* node base number			688 */
    unsigned short  canode;	/* next node number			689 */
    Seven_wd_lknm   parent;	/* parent design file name		690 */
    short	    sysclass;	/* system class bit map			697 */
    Seven_wd_lknm   usercmd;	/* user command index file name		698 */
    short	    ucdata[16];	/* user command data 			705 */
    Seven_wd_lknm   dmrsfile;	/* DMRS file spec			721 */
    Oldref	    oldref[3];	/* old reference file space (dead)	728 */
    char	    linkgen;	/* linkage generation mode (DMRS) 	764 */
    byte	    dmrsflg;	/* DMRS flag				764 */
    byte	    tutview;	/* tutorial view number			765 */
    byte	    iactfl;	/* initial active file number ? 	765 */
    Autodim2	    ad2;	/* second part of auto dim stuff	766 */
    Point3d	    dynamicorg;	/* dynamic area/volume origin 		776 */
    Point3d	    dynamicext;	/* dynamic area/volume extent 		782 */
    Dyntable	    dytab[4];	/* dynamic zoom/pan factors for 4 views 788 */
    struct
	{
#if !defined (mc68000)
	unsigned    user_help:1;    /* user help mode */
	unsigned    boresite:1;	    /* standard or boresite locate mode */
	unsigned    prj_key:1;	    /* project or keypoint snap */
	unsigned    cnstplane:1;    /* enable construction aide */
	unsigned    stackfract:1;   /* enable stacked fractions */
	unsigned    cellgg:1;	    /* reserved */
	unsigned    capsurf:1;	    /* capped surface placement mode */
	unsigned    newElementsPresent4:1;  /* new 4.0 elements present */
	unsigned    rsrved:8;
#else
	unsigned    rsrved:8;
	unsigned    newElementsPresent4:1;  /* new 4.0 elements present */
	unsigned    capsurf:1;	    /* capped surface placement mode */
	unsigned    cellgg:1;	    /* reserved */
	unsigned    stackfract:1;   /* enable stacked fractions */
	unsigned    cnstplane:1;    /* enable construction aide */
	unsigned    prj_key:1;	    /* project or keypoint snap */
	unsigned    boresite:1;	    /* standard or boresite locate mode */
	unsigned    user_help:1;    /* user help mode */
#endif
	} cntrl1;		/* miscellaneous control flags		812 */
    Autodim3	    ad3;	/* more auto dimensioning stuff		813 */
    short	    auxtype;	/* type of auxiliary coord system	814 */
    Point3d	    dyndwnext;	/* dynamic download extents		815 */
    short	    fbfdcn2;	/* another control word (B-splines)	821 */
    short	    reserv[7];	/* nothing here in TCB			822 */
    short	    tcbend;	/* marks end of tcb */

/*  ----- User Command variables -------- */
    short	    uc_r[32];	/* R0, R1, ... R31 */
    short	    uc_err;	/* ERR */
    short	    uc_num;	/* NUM */
    long	    uc_i[16];	/* I0, I1, ... I15 */
    short	    uc_xdt;	/* XDT */
    short	    uc_ydt;	/* YDT */
    long	    uc_xur;	/* XUR */
    long	    uc_yur;	/* YUR */
    long	    uc_zur;	/* ZUR */
    short	    uc_vno;	/* VNO */
    double	    uc_a[16];	/* A0, A1, ... A15 */
    Ucm_register    uc_c[18];	/* C0, C1, ... C15, KEY, MSG */
    short	    uc_fno;	/* FNO */

/*--------- NOT SAVED IN TYPE 9 ELEMENT -------------*/
    short	    dgnfil[3];	    /* design file name (RAD50) */
    short	    dgnext;	    /* design file extension */
    unsigned short  dfsect;	    /* end_of_file sector */
    short	    dfbyte;	    /* end_of_file byte */
    unsigned short  wwsect;	    /* working window start sect */
    short	    wwbyte;	    /* working window start byte */
    short	    wwfile;	    /* working window start file */
    short	    fence;	    /* number of fence points */
    Point2d	    fenpts[101];    /* fence points */
    Point3d	    fenrng[2];	    /* fence range (x,y,z lo-hi range) */
    short	    fenvw;	    /* view number containing fence */
    long	    activecell;	    /* active cell  (radix 50) */
    unsigned short  actcell_sect;   /* active cell sector */
    short	    actcell_byte;   /* active cell byte */
    short	    acorgf;	    /* add cell origin flag */
    Point3d	    celor;	    /* add cell origin */
    long	    activeterm;	    /* active line terminator */
    unsigned short  actterm_sect;   /* active line terminator sector */
    short	    actterm_byte;   /* active line terminator byte */
    double	    actterm_scale;  /* active line terminator scale */	
    long	    activepat;	    /* active patterning cell */
    unsigned short  actpat_sect;    /* active pattern cell sector */
    short	    actpat_byte;    /* active pattern cell byte */
    double	    actpat_scale;   /* active patterning scale */
    double	    actpat_angle;   /* active patterning angle */
    long	    actpat_rowspc;  /* active patterning row spacing */
    long	    actpat_colspc;  /* active patterning column spacing */
    long	    actpnt;	    /* active point (radix 50) */
    unsigned short  actpnt_sect;    /* active point sector */
    short	    actpnt_byte;    /* active point byte */
    short	    tpnpts;	    /* number of tentative points in table */
    Point3d	    tptabl[2];	    /* tentative point table */
    short	    tptvw[2];	    /* views for tentative points in table */
    unsigned short  dspsec;	    /* sector of currently displayed elemnt */
    short	    dspbyt;	    /* byte of same */
    Outflg	    outflg;
    unsigned short  wssect;	    /* working set sector */
    unsigned short  lscans;	    /* locate/snap sector pointer */
    short	    lscanb;	    /* locate/snap byte pointer */
    double	    smobuf[9];	    /* floating point scratch area */
    short	    snapfl;	    /* file number for snap scan */
    unsigned short  snapsc;	    /* sector to start snap search */
    short	    snapby;	    /* byte to start snap search */
    double	    tmatrx[9];	    /* view transformation matrix */
    short	    dittol;	    /* locate tolerance */
    Point3d	    lstpnt;	    /* last data point entered */
    short	    lstvw;	    /* view for last point */
    unsigned short  curebl;	    /* current element, block */
    short	    cureby;	    /* current element, byte */
    short	    curefl;	    /* current element file */
    unsigned short  eleblk;	    /* next element, block */
    short	    elecnt;	    /* next element, byte */
    short	    propmsk;	    /* properties mask */
    short	    propval;	    /* properties value */
    short	    dynamics;	    /* NO LONGER USED   7/90 RBB */
    long	    handle;	    /* design file file handle */
    long	    cellhandle;	    /* cell library handle */
    short	    tagdel;	    /* tag increment binary delta */
    short	    tagadr;	    /* address of first char in tag field */
    short	    taglen;	    /* number of characters in tag field */
    short	    tagbin;	    /* binary value of tag increment */
    short	    relerr;	    /* error number for last command */
    unsigned short  cugraf;	    /* current graphics group, only in UCM */
    short	    ndices;	    /* # of axes, 2 or 3 */
    short	    angbyt;	    /* # of bytes in orientation (4 or 16) */
    short	    trabyt;	    /* cell xform matrix (16 or 36) */
    short	    pntbyt;	    /* bytes in a point (8 or 12) */
    short	    of_elo;	    /* element origin (0 or 12) */
    short	    of_txn;	    /* offset for text elements (0 or 8) */
    short	    of_clr;	    /* offset for cell rotation (0 or 8) */
    short	    of_clo;	    /* offset for cell origin (0 or 28) */
    unsigned long   strdelta;	    /* stream delta */
    unsigned long   strtol;	    /* stream tolerance */
    Point3d	    prjpnt;	    /* projected locate point */
    byte	    prjseg;	    /* projected segment */
    byte	    prjvw;	    /* projected view */
    short	    dctchs;	    /* terminal type (15=MicroStation) */
    char	    dgnfilenm[MAXFILELENGTH];  /* design file name */
    char	    celfilenm[MAXFILELENGTH];  /* cell library name */
    char	    ucifilenm[MAXFILELENGTH];  /* User Command Index name */
    char	    celindxnm[MAXFILELENGTH];  /* cell index file name */
    short	    ustn_version;   /* MicroStation version */
    short	    keypnt_divd;    /* divisor for keypoint snapping */
    unsigned short  ae;		    /* active entity database */
    unsigned long   mslink;	    /* MSLINK key field of ae record */
    char	    *db_cntrl;  /* database descriptors */
    unsigned long   record;	    /* basis for ae, last record written */
    double	    actpat_angle2;  /* second pattern angle (for x-hatch) */
    char	    schema[MAXFILELENGTH];  /* database master control file */
    short	    task_size;	    /* number of K bytes to save for tasks */
    Point3d	    iuor[4];	    /* File Builder scratch */
    short	    tutnam[2];	    /* tutorial name (radix 50) */
    unsigned short  tutsec;	    /* tutorial sector */
    struct
	{
#if !defined (mc68000)
	unsigned short	offset:15;  /* tutorial word offset */
	unsigned short	usertut:1;  /* is tutorial in user library */
#else
	unsigned short	usertut:1;  /* is tutorial in user library */
	unsigned short	offset:15;  /* tutorial word offset */
#endif
	}	    tutwrd;

    short	    tutsiz;	    /* tutorial size */
    Ext_viewflags   ext_viewflags[8];
    short	    lev_sym_mask;   /* level symbology enable mask */
    short	    lev_sym[63];    /* level symbology words */
#if defined (unix)
    short	    prompt_color[4];	/* normal prompt, alt, tut infields */
#else
    short	    prompt_color[6];	/* normal prompt, alt, tut infields */
#endif
    Ext_locks	    ext_locks;
    double	    axlock_angle;
    double	    axlock_origin;
    char	    fntfilenm[MAXFILELENGTH];	/* font library file name */
    long	    msgkey;	    /* indfpi message key for fb_only */
    short	    classmask[8];
    short	    window_mode;    /* saves funcname in window command */
    byte	    numScreens;
    byte	    currentScreen;
    short	    tutfont;	    /* font used in tutorials */
    Transform	    digtrans;
    short	    emm_size;
    short	    max_grdpnts;
    short	    max_grdrefs;
    char	    *refFileP;   /* pointer to reference file array */
    short	    maxRefs;	     /* maximum number of reference files */
    short	    bios_screen;
    short	    dimension_version;
    Autodim4	    ad4;
    Autodim5 	    ad5;
    Autodim6	    ad6;
    double	    grid_ratio;
    long	    dyno_buffsize;
    short	    small_text;

    /* information about the currently parsed command */
    long	    last_parsed_command;
    long	    current_command;
    short	    last_parsed_class;
    short	    command_class;
    short	    last_parsed_source;
    short	    command_source;

    /* the following values contain default (last entered) values for
	commands that require input */
    double	    chamfer_dist1;
    double	    chamfer_dist2;
    double	    autochain_tolerance;
    double	    consline_distance;
    double	    arc_radius;		/* for circles and arcs */
    double     	    arc_length;
    double	    cone_radius1;	/* used for cones only */
    double	    cone_radius2;
    double	    polygon_radius;
    double	    surrev_angle;
    double	    extend_distance;
    double	    fillet_radius;
    double	    coppar_distance;
    double	    array_row_distance;
    double	    array_column_distance;
    double	    array_fillangle;
    double	    point_distance;
    short	    polygon_edges;
    short	    points_between;
    short	    array_numitems;
    short	    array_numrows;
    short	    array_numcols;
    byte	    array_rotate;
    byte	    bspline_order;
    byte	    disp_attr_type;	/* displayable attribute type # */
    byte	    aux_coord_def;	/* type of aux coord being def'd */
    short	    searchType[8];	/* element locate type mask */
    long	    searchFile[MAX_FILEMASK];		/* file locate mask */
    byte	    updateorder[MAX_REFS+2];	/* update order for files */
#if defined (macintosh)
    union
        {
	short		s;
        MSText_Style	b;
	} textStyle;
    Dpoint2d	    clipPasteScale;
    double	    clipRotation;
    struct
	{
	unsigned    reserved:10;
	unsigned    transparentBitmaps:1;
	unsigned    pastePictFile:1;
	unsigned    rasterCopy:1;
	unsigned    graphicScale:1;
	unsigned    verticalFlip:1;
	unsigned    horizontalFlip:1;
	} clipMode;
#endif
    long	    ucmget_command; /* command number (in GET statement) */
    short	    ucmget_class;   /* command class (in GET statement) */
    short	    ucmget_source;  /* command source (in GET statement) */
    short	    help;	  

    Dpoint3d	    currentPosition;
    Dpoint3d	    currentDelta;
    double	    currentAngle;
    double	    currentDistance;
    struct 
	{
	double reference;
	double master;
	} refScale;
    Dpoint3d	    refAngle;
    Point3d	    precisionPoint;
#if defined (macintosh)
    char	    workFileName[MAXFILELENGTH];
#endif
    long	    activeAuxSystem;    /* Radix-50 for active ACS */
    long	    textAboveSpacing;   /* Space between characters above */
    double	    arcTolerance;
    short	    arcVectors; 
    short	    extendedLevels[8][4];
    short	    useRangeTree;	    /* TRUE r-tree should be used */
    double	    snapTolerance;	    /* tolerance for snap/locate */
    unsigned short  locateHdrSector;	    /* header for locate/snap */
    short	    locateHdrByte;	    /* header for locate/snap */
    unsigned short  locateComponentSector;  /* sector of component located */
    short	    locateComponentByte;    /* (curebl,cureby might be hdr) */
    unsigned short  snapComponentSector;    /* sector of primitive snapped */
    short	    snapComponentByte;	    /* (lscans,lscanb might be hdr) */
    short	    snap2ndFile;	    /* Loc of intrsctng snap elm */
    unsigned short  snap2ndSector;	
    short	    snap2ndByte;
    unsigned short  snap2HdrSector;	/* loc of hdr if inter elem cmplx */
    short	    snap2HdrByte;
    byte	    restartLocate;	/* restart location */
    byte	    inDynamics;		/* we are in dynamics */
    byte	    EDFieldChar;	/* enter data field character */
    byte	    angleReadoutPrec;	/* unused, use if a byte is needed */
    double	    strokeTolerance;
    short	    arcMinimum;
    char	    backgroundFile[MAXFILELENGTH];
    ULong	    componentOffset;	/* offset from header for complex
					   component on locate */
					    
    /* Rendering information */
    short	    stereoSeparation;
    short	    maxPolygonSize;
    RenderFlags	    renderFlags;
    RGBFactor	    ambientIntensity;
    RGBFactor	    flashIntensity;
    RGBFactor	    solarIntensity;
    Dpoint3d	    solarDirection;
    Latitude	    latitude;
    Longitude	    longitude;
    SolarTime	    solarTime;
    short	    filledEdgeColor; /* Filled edge color (-1 = no edges) */

    MultilineTCB    multiline;	    /* All current multiline settings	    */
    LocateInfo	    locateInfo;	    /* Info from last located element	    */
    
    short	    formsMode;	    /* database screen forms mode */
    short	    confirmMode;    /* database multi-row confirmation */
    CameraInfo	    camera[8];
    short	    platform;	    /* so UC's can tell what platform */
    byte	    streamAccept;   /* show acceptance criteria for stream */
    int		    snapElmNumber;  /* elm number if compound snapped elm */
    int		    snap2ElmNumber; /* elm number if 2nd compound snapped */
    } Tcb;

#endif	    /* __tcbH__ */
