/*
Name
        translate.h

Description
        This file contains structures used during the translation
        to and from IGDS.

Dependencies
   	igrtypedef.h
        igr.h
        transdef.h

History
        created 'way back when the earth was young
*/

#ifndef translate_include

#define translate_include

struct GUcvt_bufs
{
    IGRdouble		reserved;			/* force alignment */
    IGRchar		bs_buf[GUBSBUF_SIZE];		/* must fall on    */
    IGRchar		ele_buf[GUELE_BUF_SIZ];		/* double word     */
    IGRchar		dgn_buf[GUDGN_BUF_SIZ];		/* boundary	   */
    IGRint		file_des;
    IGRint		ele_size;
    IGRint		ele_type;
};    

struct GUcommon_header_info
{
    IGRuchar 		level;		/* c-bit, r-bit, level number	*/
    IGRuchar		type;		/* u-bit, element type		*/
    IGRshort	        words_to_follow;/* # of words in element	*/
    IGRlong	        range[6];	/* range of element		*/
    IGRshort    	graphic_group;	/* graphic group number		*/
    IGRshort	        index_to_ae;	/* index to attribute linkage	*/
    short unsigned	properties;	/* properties indicator		*/
	     				/* 0-3	class			*/
					/* 4-7	reserved		*/
					/* 8	locked			*/
					/* 9	new element		*/
					/* 10	modify			*/
					/* 11  	attribute present	*/
					/* 12	relative		*/
					/* 13	planar			*/
					/* 14	snappable		*/
    short unsigned 	symbology;	/* display symbology		*/
	    				/* 0-2	style			*/
					/* 3-7	weight			*/
					/* 8-15	color			*/
};

struct GUpoints
{
    IGRshort	num_points;
    IGRchar	pnts_ptr;
};

struct IGDS_line
{
    struct GUcommon_header_info	header;
    IGRchar			pnts_ptr;  /* structure for IGDS line */
};

struct IGDS_linestring
{
    struct GUcommon_header_info	header;
    struct GUpoints     	lnstr;	  /* structure for IGDS shape */
};

struct IGDS_shape
{
    struct GUcommon_header_info	header;	/* common to all elements   */
    struct GUpoints		shape;	/* structure for IGDS shape */
};

struct IGDS_arc_info
{
    IGRlong		start;
    IGRlong		sweep;
    unsigned long	primary[2];
    unsigned long	secondary[2];
    IGRlong		rot_org;
};

struct IGDS_arc
{
    struct GUcommon_header_info	header;
    struct IGDS_arc_info	arc;	/* structure for IGDS arc  */
};

struct IGDS_ellipse_info
{
    IGRlong 	primary[2];
    IGRlong	secondary[2];
    IGRlong	rot_org;
};

struct IGDS_ellipse
{
    struct GUcommon_header_info	header;
    struct IGDS_ellipse_info    ellipse; /* structure for IGDS ellipse */
};

struct IGDS_text_ele
{
    struct GUcommon_header_info	header;	/* common to all elements  */
    IGRchar			font;  	/* text font number        */
    IGRchar			justification;
    IGRchar			text_data;
};

struct IGDS_color_table
{
    struct GUcommon_header_info	header;
    short unsigned		screen_select;
    struct
    {
	IGRuchar 	red;
	IGRuchar	green;
	IGRuchar	blue;
    } color[256];
    IGRshort			num_chars;
    IGRchar			filename[64];
};

struct IGDS_cell
{
    struct GUcommon_header_info	header;
    short unsigned		cell_data;
};

struct IGDS_cell_lib_header
{
    struct GUcommon_header_info header;
    IGRuchar 		        cell_index_file[14];
};

struct IGDS_cell_header
{
    IGRuchar			level;
    IGRuchar			type;
    IGRshort			words_to_follow;
    IGRlong	 	 	range[6];
    short unsigned		cell_type;
    IGRshort		        index_to_ae;
    IGRuchar			cell_name[4];
    IGRshort			wds_in_descrp;
    short unsigned		properties;
    short unsigned		symbology;
    IGRshort			cell_class;
    short unsigned		levels[4];
    IGRuchar			cell_descrp[8];
};

struct IGDS_cone
{
    struct GUcommon_header_info	header;
    IGRshort			cone_type;
    IGRchar			cone_data;
};

struct	IGDS_curve
{
    struct GUcommon_header_info	header;
    struct GUpoints     	curve;
};

struct IGDS_complex
{
    struct GUcommon_header_info	header;
    IGRshort 			wds_in_descript;
    IGRshort			num_elements;
    IGRuint			dummy_linkage;
};

struct IGDS_bsc_header
{
    unsigned long	wds_in_descript;
    IGRchar		order;
    IGRchar		curve_type;
    IGRshort		num_poles;
    IGRshort		num_knots;
};

struct IGDS_bss_header
{
    unsigned long	wds_in_descript;
    IGRchar		order_u;
    IGRchar		surf_type;
    IGRshort		num_poles_u;
    IGRshort		num_knots_u;
    IGRshort		rules_u;
    IGRchar		order_v;
    IGRchar		reserved;
    IGRshort		num_poles_v;
    IGRshort		num_knots_v;
    IGRshort		rules_v;
    IGRshort		num_boundaries;
};

struct IGDS_bscurve
{
    struct GUcommon_header_info	header;	
    struct IGDS_bsc_header	curve;	/* structure for IGDS line */
};

struct IGDS_bssurf
{
    struct GUcommon_header_info	header; 
    struct IGDS_bss_header	surf;
};

struct IGDS_bscomponent
{
    struct GUcommon_header_info	header;
    IGRchar			components;
};

struct IGDS_o_bscomponent
{
    struct GUcommon_header_info	header;
    IGRchar			components[1500];
};

struct IGDS_raster_header
{
    struct GUcommon_header_info	header;
    IGRlong			wds_in_descript;
    IGRchar			format_just;
    IGRchar			flags;
    IGRchar			bgclr;
    IGRchar			fgclr;
    IGRshort			x_pix_extent;
    IGRshort			y_pix_extent;
    IGRlong 			reserved;
    IGRlong			resolution[2];
    IGRlong			conversion[2];
    IGRlong			origin[3];
    IGRshort			num_vertices;
    IGRshort			vertices;
};

struct IGDS_raster_data
{
    struct GUcommon_header_info	header;
    IGRchar			format_just;
    IGRchar			flags;
    IGRchar			bgclr;
    IGRchar			fgclr;
    IGRshort			x_pix_offset;
    IGRshort			y_pix_offset;
    IGRshort			num_pixels;
    IGRchar			rasdata;
};

struct GUcontrol_struct
{
	struct IGRbsp_curve curve;	/* structure for B-spline curve	*/
	struct IGRbsp_surface surf;	/* structure for surface	*/
	IGRboolean iscurve;		/* curve (TRUE) / surface 	*/
					/* (FALSE) indicator		*/
	IGRshort  knotu;		/* number of knots stored in u	*/
	IGRshort  knotv;		/* number of knots stored in v	*/
	IGRlong rules[2];		/* number of rule lines in u	*/
					/* and v			*/
	IGRshort  slow;			/* slow (=1) / fast (=0) surf	*/
	IGRdouble *startbuf;		/* pointer to start to data 	*/
					/* buffer			*/
	IGRdouble *endbuf;		/* pointer to end of data 	*/
					/* buffer			*/
	IGRdouble *nextdat;		/* pointer to next data buffer	*/
					/* position to fill		*/
	IGRdouble *nextpol;		/* pointer to next data buffer	*/
					/* position to put poles	*/
	IGRdouble *nextweight;		/* pointer to next data buffer	*/
					/* position to put weights	*/
	IGRshort  curbdry;		/* current boundary number	*/
	IGRlong  eledon;		/* number of pole/weight ele-	*/
					/* ments processed		*/
	IGRshort  bdrysdon;		/* number of complete bound-	*/
					/* aries processed		*/
	IGRshort  first_call;		/* first call indicator		*/
	IGRshort  *bdry_nums;		/* pointer to list of boundary	*/
					/* numbers			*/
	IGRdouble *scratch_buffer;	/* pointer to scratch buffer	*/
};

struct IGDS_linkage
{
    IGRuchar  words_to_follow;		/* # of words in linkage 	*/
    IGRuchar  properties;		/* property bits      		*/
    IGRshort user_id;			/* user identification		*/
};

struct GUlinkage
{
    struct IGDS_linkage header;		/* common linkage header	*/
    IGRchar	length;			/* length of linkage		*/
    IGRchar	type;			/* type  of linkage		*/
    IGRshort    data;               	/* used for data, or as data_ptr*/
};

struct GUpolyfill_linkage
{
    struct IGDS_linkage	header;		/* common linkage header	*/
    IGRchar	length;			/* attribute length		*/
    IGRchar	type;			/* attribute type		*/
    IGRshort	color_flag;		/* flag for vlt or rgb		*/
    IGRshort	fill_color;		/* fill color			*/
    IGRshort	data_ptr;		/* filler to quad-word boundry	*/
};

struct GUfont_linkage
{
    struct IGDS_linkage header;         /* common linkage header           */
    IGRuchar		length;         /* attribute length                */
    IGRuchar		type;           /* attribute type                  */
    short   unsigned    properties;     /* font specific properties        */
    IGRuchar 		data_ptr;       /* typeface and char mapping names */
                                        /* and length of char mapping name */
};
	
#define BS_STRUCT_SIZE sizeof(struct GUcontrol_struct) * 2 /* size in words */

struct GUplot_element_args
{
    IGRlong		*internal_msg;
    struct GRmd_env 	*md_env;
    IGRchar		*design_buffer;
    IGRchar		*object_buffer;
    IGRchar		*element_buffer;
    IGRlong		*element_size;
    IGRlong		*file_descriptor;
    IGRdouble		*max_overflow;
    struct GRid		*id_info;
    IGRdouble		*scale_factor;
};

struct GUplot_user_info
{
    OM_p_MESSAGE 	plot_msg;
    struct IGRcv_prism	*prism_array;
    IGRint 		num_prisms;
    IGRlong		index1,index2;
    IGRint 		*levels;
    IGRint		(*filter_function)();
    IGRchar		*filter_data;
};

#endif
