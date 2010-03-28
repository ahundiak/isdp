




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

#ifndef igrdp_include



  /*  
   *   This include file is dependent on the following include files:
   *
   *		igrtypedef.h
   *		igr.h
   *
   */


#define igrdp_include

/*
 *  Display attributes definitions.
 *
 */


struct IGRdisplay			/* element display attributes	*/
{
	short    unsigned  color;	/* color index			*/
	IGRuchar           weight;	/* weight index			*/
	IGRuchar           style;	/* position # for line style    */
};

struct IGRaltdisplay			/* element display attributes	*/
{
	IGRuint	           *rgb_value;  /* RGB gun intensities		*/
	short    unsigned  *color;	/* color index			*/
	IGRuchar           *weight;	/* weight index			*/
	IGRuchar           *style;	/* position # for line style    */
};

union IGRgeometries			/* allowable element geometries	*/
{
	IGRpoint point;			/* point geometry		*/
	struct IGRline *line;		/* line geometry		*/
	struct IGRline_seg *lineseg;	/* line segment geometry	*/
	struct IGRpolyline *polyline;	/* polyline geometry		*/
	struct IGRpolygon *polygon;	/* polygon geometry		*/
	struct IGRarc *arc;		/* arc geometry			*/
	struct IGRellipse *ellipse;	/* ellipse geometry		*/
	struct IGRcone *cone;		/* cone geometry		*/
	struct IGRptstring *ptstring;	/* point string geometry	*/
	struct IGRlbsys *lbsys;		/* local bounded sys. geometry	*/
	struct IGRcurve *curve;		/* curve geometry		*/
	struct IGRbsp_curve *bspcurve;	/* B-spline curve geometry	*/
	struct IGRbsp_surface *bspsurf;	/* B-spline surface geometry	*/
	struct IGRrt_prism *prism;	/* right prism geometry		*/
	struct IGRcv_prism *cv_prism;	/* curve prism geometry		*/
};

/*
 *
 *  Element specific attributes.
 *
 */

struct IGRespy				/* polyline element spec attr	*/
{
	IGRboolean is_closed;		/* closed indicator		*/
};

struct IGRescn				/* cone element specific attr	*/
{
	IGRboolean is_surface;		/* indicator of surface/solid	*/
};

struct IGResps				/* point set ele spec attr	*/
{
	IGRboolean is_connected;	/* connected/disjoint indicator	*/
};

struct IGResbc				/* B-spline curve ele spec attr	*/
{
	IGRboolean is_polydis;		/* polygon display on/off	*/
	IGRboolean is_curvedis;		/* curve display on/off		*/
};

struct IGResbs				/* B-spline surf ele spec attr	*/ 
{
	IGRlong    u_rules;		/* number of displayed rule	*/
					/* lines in the u direction	*/
	IGRlong    v_rules;		/* number of displayed rule	*/
					/* lines in the v direction	*/
	IGRboolean is_polydis;		/* polygon display on/off	*/
	IGRboolean is_surfdis;		/* surface display on/off	*/
	IGRboolean is_slowdis;		/* slow (equal arc length) /	*/
					/* fast (equal parameter) rule	*/
					/* line spacing			*/
	IGRshort   type;		/* surface type			*/
};

struct IGResqbs				/* B-spline q surf ele spec	*/ 
{
	IGRlong    u_rules;		/* number of displayed rule	*/
					/* lines in the u direction	*/
	IGRlong    v_rules;		/* number of displayed rule	*/
					/* lines in the v direction	*/
	IGRboolean is_polydis;		/* polygon display on/off	*/
	IGRboolean is_surfdis;		/* surface display on/off	*/
	IGRboolean is_slowdis;		/* slow (equal arc length) /	*/
					/* fast (equal parameter) rule	*/
					/* line spacing			*/
	IGRshort   type;		/* surface type			*/
	IGRboolean rules_specified;	/* rule line parameters, clip	*/
					/* info is specified indicator	*/
	IGRdouble  *u_rule_values;	/* fixed v parameters defining	*/
					/* the u rule lines		*/
	IGRdouble  *v_rule_values;	/* fixed u parameters defining	*/
					/* the v rule lines		*/
	IGRint	   *u_num_bound;
	IGRint	   *v_num_bound;
	IGRdouble  **u_bdrys;		/* array of curve boundaries 	*/
					/* defining clip points		*/
					/* on the u rule lines (each	*/
					/* "boundary" contains u 	*/
					/* parameters equivalent to 	*/
					/* those on the B-spline curve	*/
					/* representing the 		*/
					/* corresponding u rule line)	*/
	IGRdouble  **v_bdrys;		/* array of curve boundary 	*/
					/* structs defining clip points	*/
					/* on the v rule lines (each	*/
					/* "boundary" contains v 	*/
					/* parameters equivalent to 	*/
					/* those on the B-spline curve	*/
					/* representing the 		*/
					/* corresponding v rule line)	*/
};

struct IGRestx				/* text ele specific attributes	*/
{
        IGRshort   font;                /* identifies specific font     */
        IGRshort   just;                /* specifies how text will be
                                           placed about placement point */
	IGRdouble  width;		/* x-axis scale factor		*/
	IGRdouble  height;		/* y-axis scale factor		*/ 
        IGRshort   flag;                /* indicates special attributes */
        IGRshort   num_char;            /* number of displayable char   */
        IGRdouble  line_spac;           /* vertical spacing used to 
                                           calculate new baseline       */
        IGRdouble  char_spac;           /* allows specification of 
                                           additional space between char*/
        IGRshort   text_length;         /* length of text string in 
                                           bytes                        */
};


struct IGResintx			/* text ele specific attributes	*/
{
	IGRshort   font_id;
	
	IGRchar	   just_moves[20];
	IGRint	   flags;
	IGRshort   prev_font;
	
	struct	IGRestx	*estx;		/* element specific structure	*/
 
        IGRchar    *text_string;        /* characters and imbedded
                                           escape sequences in string   */
};

struct IGResrs				/* element specific data for	*/
					/* raster graphics display	*/
{
	IGRshort index;			/* index of attribute to draw	*/
	IGRboolean (*function)();	/* function approach function	*/
	struct IGRfastrasdis		/* fast display structure	*/
	  *rasdis_ptr;
	IGRboolean trans_display;	/* display background 		*/
					/* transparently		*/
	IGRchar *info;			/* ptr to user info structure	*/
	IGRboolean (*getln)();		/* get line (decimation) func	*/
	IGRint	   (*stopdraw)();	/* stop draw function		*/
	unsigned short min_color;	/* min color value		*/
	unsigned long min_rgb;		/* min red green and blue	*/
	unsigned short max_color;	/* max color value		*/
	unsigned long max_rgb;		/* max red green and blue	*/
	unsigned long back_mask;	/* background plane mask	*/
	unsigned long hi_mask;		/* hilite plane mask		*/
	unsigned short dis_flags;	/* display flags		*/
	IGRshort num_bits;		/* number of displayable bits 	*/
	IGRshort max_table_index;	/* color table max index	*/
	IGRchar	maptype;		/* 8 bit or 24 bit data		*/
	IGRint	mapdim;			/* dimension of color maps	*/
	IGRchar *primmap;		/* primary color map		*/
	IGRchar *premap;		/* pre color map		*/
	IGRchar *postmap;		/* post color map		*/
	IGRchar *greenrec;		/* green records in 24 bit case */
	IGRchar *premapg;		/* pre map for green records	*/
	IGRchar *postmapg;		/* post map for green records 	*/
	IGRchar *bluerec;		/* blue records in 24 bit case	*/
	IGRchar *premapb;		/* pre mapping for blue records	*/
	IGRchar *postmapb;		/* post map for blue records	*/
	IGRshort *abscolor;		/* absolute color indexes	*/
	IGRchar *res1;			/* reserved for future use	*/
	IGRchar *res2;			/* reserved for future use	*/
};

union IGRele_attr			/* element specific attributes	*/
{
	struct IGRescn *cone;		/* cone data			*/
	struct IGResps *ptset;		/* point set data		*/
	struct IGResbc *bspcurve;	/* B-spline curve data		*/
	struct IGResbs *bspsurf;	/* B-spline surface data	*/
	struct IGResqbs *bsqsurf;	/* fast B-spline surface data	*/
	struct IGResintx *text;		/* text data			*/
	struct IGResrs *raster;		/* raster data			*/
	char *null;			/* other elements		*/
};

#endif
