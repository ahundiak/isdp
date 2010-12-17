/*
 * Include file for Raster Graphics Objects 
 * 
 */

/*
 * Include files that this depends on
 *
 * igrtypedef.h igr.h
 */
 
#ifndef igrraster_include

#define igrraster_include

#define IGRoutline IGRpolyline

struct IGRraster
{
	IGRlong	num_rows;		/* number of rows in matrix	*/
	IGRlong num_cols;		/* number of cols in matrix	*/
	IGRchar *records;		/* matrix of raster records	*/
	IGRshort *types;		/* array of types of attributes	*/
	IGRshort rec_size;		/* size of each raster record	*/
					/* (measured in bytes, except 	*/
					/* for single-attr bit data)	*/
	IGRshort num_attrs;		/* number of attributes in 	*/
					/* each raster record		*/
	IGRshort *offsets;		/* array of offsets to attrs	*/
	IGRmatrix matrix;		/* local-to-world transform-	*/
					/* ation matrix			*/
	IGRboolean swch;		/* swch/function indicator	*/
	IGRlong	stdapp_len;		/* length (in bytes) of stand-	*/
					/* ard application data		*/
	IGRchar *stdapp_data;		/* standard application data	*/
}; 

struct IGRcomprast_fcd			/* composite raster file 	*/
					/* control data			*/
{
	IGRchar *filename;		/* file name of composite	*/
	IGRlong num_row_subfiles;	/* number of subfiles in row	*/
					/* direction			*/
	IGRlong num_col_subfiles;	/* number of subfiles in col	*/
					/* direction			*/
	IGRlong memory_left;		/* amount of virtual memory	*/
					/* remaining for composite	*/
	IGRlong memory_lock;		/* locks a subfile number in	*/
					/* memory			*/
	IGRchar *edited;		/* current file edited flag	*/
	IGRchar *to_process;		/* bit matrix of subfiles to be */
					/* processed			*/
	IGRchar *temp_files;		/* bit matrix of tempory	*/
					/* files which exist		*/
	IGRlong *in_memory;		/* subfiles that currently	*/
					/* reside in memory		*/
	IGRlong num_in_memory;		/* size of in_memory array	*/
	IGRlong *in_mem_chan;		/* channel indexes of the 	*/
					/* subfiles in memory		*/
	IGRlong num_in_mem_chan;	/* size of in_mem_chan array	*/
	IGRlong *s_num_rows;		/* number of rows in subfiles	*/
	IGRlong *s_num_cols;		/* number of cols in subfiles	*/
};

struct IGResrg				/* element specific data for	*/
					/* raster graphics		*/
{
	unsigned short rgprops;		/* raster graphics properties	*/
					/* word				*/
	IGRchar  *filename;		/* name of file containing	*/
					/* raster data			*/
	IGRboolean void_specified;	/* reserved for future		*/
	IGRdouble void_value;		/* reserved for future		*/
	unsigned short min_color;	/* min color value		*/
	unsigned long min_rgb;		/* min red green and blue	*/
	unsigned short max_color;	/* max color value		*/
	unsigned long max_rgb;		/* max red green and blue	*/
};

struct RSchar_color_entry
{
    unsigned char	red;
    unsigned char	green;
    unsigned char	blue;
};

struct IGRfastrasdis{
                      IGRlong start_row;
                      IGRlong start_col;
                      IGRlong stop_row;
                      IGRlong stop_col;
                      IGRboolean solid;
                      IGRlong *py;
                      IGRlong *pyscan;
                      IGRlong num_bytes_allocated;
                      IGRlong mask_flag;
                      IGRlong num_masks1;
                      IGRlong *mask1_flags;
                      struct RSmask **mask1;
                      IGRlong num_masks2;
                      IGRlong *mask2_flags;
                      struct RSmask **mask2;
                      IGRlong *res1;
                      IGRlong res2;
                    };

struct IGRfastrasdis_ext
{
    IGRint	flags;
    IGRint	num_polyline_sets;
    struct IGRset_polyline **setpolyline;
    struct IGRfastrasdis   *rasdis;
    IGRint (*drawfunction)();
unsigned  char *records;
};

struct IGRrasdishead
{
	IGRlong num_buffers;
	struct IGRfastrasdis *single_buf;
	struct IGRfastrasdis **multi_buf;
};

struct IGRmaskconlist
{
  IGRchar *filename;                    /* if not NULL, create from file      */
  struct RSmask *mask;                  /* else if not NULL, create from mask */
  struct IGRraster *raster;             /* else if not NULL, create from rast */
  struct IGRfastrasdis *scan_data;      /* else if not NULL, create from scan */
  IGRlong mask_prop;                    /* mask properties                    */
  IGRlong sf_row_index;                 /* subfile row index                  */
  IGRlong sf_col_index;                 /* subfile column index               */
  IGRlong num_rows;                     /* if scan_data, then this is the num-*/
  IGRlong num_cols;                     /* ber of rows and cols in the mask   */
};

struct RSfile_specs
{
	IGRshort	data_type_code;
	IGRshort	app_type_code;
	short unsigned	file_props;
	IGRlong		num_rows;
	IGRlong		num_cols;
   	IGRlong		num_row_subs;
	IGRlong		num_col_subs;
	IGRlong		*s_num_rows;
	IGRlong		*s_num_cols;
	IGRshort	num_attrs;
	IGRlong		stdapp_len;
	IGRshort	attr_num;
	IGRlong		pix_line_num;
	IGRlong		start_row;
	IGRlong		stop_row;
	IGRlong		start_col;
	IGRlong		stop_col;
        IGRshort        data_type_modifier;
        IGRshort        res1;
        IGRshort        res2;
};


struct RS84007_hdr_blk1
{
	unsigned short		level_type;	/* level - bits 0-5 	*/
						/* 2d/3d - bits 6-7	*/
						/* type  - bits 8-15	*/
	IGRshort		wds_to_follow;	/* all header blocks	*/
	IGRshort		data_type_code;
	IGRshort		app_type_code;
	IGRdouble		view_origin[3];
	IGRdouble		view_extent[3];
	IGRdouble		transformation[16];
	IGRlong			num_cols;
	IGRlong			num_rows;
	IGRshort		device_resolution;
	IGRchar			scanline_orient;	/* bits 0-2	*/
	IGRchar			scannable_flag;		/* bit 0	*/
	IGRlong			rotation_angle[2];	/* IGRdouble	*/
	IGRlong			skew_angle[2];		/* IGRdouble	*/
	IGRshort		reserved1;
	IGRchar			design_filename[66];
	IGRchar			dbase_filename[66];
	IGRchar			parent_gridfile[66];
	IGRchar			file_descript[80];
	IGRchar			min_value[8];
	IGRchar			max_vlaue[8];
	IGRchar			reserved2[3];
	IGRchar			gridfile_version;	/* latest = 2	*/
};


struct RS84007_hdr_blk2
{
	IGRchar			gain;
	IGRchar			offset;
	IGRchar			vwfull_scr1;
	IGRchar			vwfull_scr2;
	IGRchar			view_number;
	IGRchar			reserved3;
	IGRshort		entity_number;
	IGRshort		coded_value;
	IGRshort		polygon_id;
	IGRshort		run_id;
	IGRshort		integer_value;
	IGRlong			concat_file_ptr;
	IGRshort		color_table_type;
	IGRshort		reserved4;
	IGRlong			num_ctb_entries;
	IGRshort		reserved5[114];
	IGRshort		ctb_app[128];
};

struct RS84007_header
{
	struct RS84007_hdr_blk1	blk1;
	struct RS84007_hdr_blk2	blk2;
};

/*
 *  Structures for CCITT Group 4 expansion and compression.
 */
 
struct RSexpand_table_index 
{
    unsigned g4_code : 13;
    unsigned first_second : 1;
    unsigned color : 1;
    unsigned command_data : 1;
};

struct RSexpand_table
{
    unsigned run_length : 12;
    unsigned blank : 1;
    unsigned first_second : 1;
    unsigned color : 1;
    unsigned command_data : 1;
    unsigned shift_count : 4;
    unsigned proc_code : 5;
    unsigned reserved : 7;
};

struct RScompress_table_index 
{
    unsigned run_length : 15;
    unsigned color : 1;
};

struct RScompress_table
{
    unsigned run_length : 15;	/* this will be (table_index.run_length - table.g4_code) */
    unsigned g4_code : 13;
    unsigned shift_count : 4;
};

struct RSshift_table_index 
{
    unsigned shift_count : 4;
    unsigned shift_pos : 4;
};

struct RSshift_table 
{
    unsigned 	      pre_shift : 4;
    unsigned 	      shift_pos : 4;
    unsigned 	      post_shift : 4;
    unsigned 	      load_flag : 4;
    unsigned short blank;
};

struct RSshift_reg
{
    unsigned short low;
    unsigned short high;
};

struct RSrl_gen
{
    unsigned short value;
    unsigned short g4_code;
    unsigned short length;
};

struct RScode_gen
{
    unsigned short w_value;
    unsigned short b_value;
    unsigned short g4_code;
    unsigned short length;
};

/*
 *  Structures for I/IMAGE data packets.
 */
 
struct RSpacksearch
{
    IGRshort	typecode;
    IGRshort	subtype;
    IGRlong	numfields;
    IGRshort	*types;
    IGRshort	*offsets;
    IGRchar	*values;
};
    
struct RSdata_packet		/* data packet header, all data	*/
{				/* packets must contain this	*/
    IGRshort	typecode;
    IGRshort	subtype;
    IGRlong	wtf;
};

struct RSptc1sub1_data
{
    IGRshort	version;
    IGRshort	id;
    IGRshort	res1;
    IGRshort	res2;
    IGRshort	res3;
    IGRshort	res4;            
    IGRshort	num_attrs;
    IGRshort	types;
};

struct RSptc1sub1			/* attribute types packet,	*/
{					/* necessary only for multiple	*/
    struct RSdata_packet	header;	/* attribute data files		*/
    struct RSptc1sub1_data	data;
};

struct RSptc1sub2_data		/* This packet contains a raster data	*/
{				/* mapping.  It may be of the following	*/
    IGRshort	version;	/* types:				*/
    IGRshort	id;		/*	 0 -				*/
    IGRshort	res1;
    IGRshort	res2;
    IGRshort	res3;
    IGRshort	res4;            
    IGRshort	maptype;	/*	 1 -				*/
    IGRshort	mapdim;		/*	 2 - 				*/
    IGRshort	start;		/* The actual red, green, and blue 	*/
    IGRshort	nrshades;	/* intensities are listed respectively 	*/
    IGRshort	ngshades;	/* beginning at the shades field of the	*/
    IGRshort	nbshades;	/* structure.  The mapping data begins  */
    IGRshort	shades;		/* on the first quadword boundary	*/
    IGRshort	res5;		/* immediately following the shades.	*/
    IGRshort	res6;
    IGRshort	res7;    
};

struct RSptc1sub2		/* I/IMAGE raster data mapping 		*/
{
    struct RSdata_packet	header;
    struct RSptc1sub2_data	data;
};

struct RScolor_entry
{
    unsigned short	red;
    unsigned short	green;
    unsigned short	blue;
};

struct RSptc1sub3_data
{
    IGRshort	version;
    IGRshort	id;
    IGRshort	res1;
    IGRshort	res2;
    struct RScolor_entry color[256];
};

struct RSptc1sub3		/* I/IMAGE raster color table data 	*/
{
    struct RSdata_packet	header;
    struct RSptc1sub3_data	data;
};

struct RSptc1sub4_data
{
    IGRshort	version;
    IGRshort	id;
    IGRshort	res1;
    IGRshort	res2;
    IGRshort	res3;
    IGRshort	res4;            
    IGRshort	low_high_hist;
};

struct RSptc1sub4		/* I/IMAGE raster histogram data 	*/
{
    struct RSdata_packet	header;
    struct RSptc1sub4_data	data;
};

struct RSptc1sub5_data
{
    IGRshort	version;
    IGRshort	id;
    IGRshort	res1;
    IGRshort	dis_plot_flags;
};

struct RSptc1sub5		/* I/IMAGE raster display/plotting data	*/
{
    struct RSdata_packet	header;
    struct RSptc1sub5_data	data;
};

struct RSptc1sub6_data
{
    IGRshort	version;
    IGRshort	id;
    IGRshort	res1;
    IGRshort	res2;
};

struct RSptc1sub6		/* I/IMAGE dither map association data */
{
    struct RSdata_packet	header;
    struct RSptc1sub6_data	data;
};

struct RSptc1sub7_data
{
    IGRshort	version;
    IGRshort	id;
    IGRshort	res1;
    IGRshort	res2;
    IGRshort	propword;
    IGRshort	dtm;
    IGRchar	res3[100];
    IGRlong	tilesize;
    IGRlong     res4;
    IGRlong	tiledata;    
};

struct RSptc1sub7		/* I/IMAGE raster tiled data info      */
{
    struct RSdata_packet	header;
    struct RSptc1sub7_data	data;
};

struct RSptc1sub8_data
{
    IGRshort	version;	/* current value is 1			*/
    IGRshort	resolution;	/* resolution field from 84-007 file	*/
    IGRshort	res1;		/* set to zero				*/
    IGRshort	res2;		/* set to zero				*/
};

struct RSptc1sub8		/* I/IMAGE misc. file data		*/
{
    struct RSdata_packet	header;
    struct RSptc1sub8_data	data;
};

struct RSptc1sub9_data
{
    IGRshort	version;
    IGRshort	id;
    IGRshort	res1;
    IGRshort	res2;
    short 	unsigned red_table[256];
    short 	unsigned green_table[256];
    short 	unsigned blue_table[256];
};

struct RSptc1sub9		/* I/IMAGE calibration tables		*/
{
    struct RSdata_packet	header;
    struct RSptc1sub9_data	data;
};

struct RSptc1sub10_data
{
    IGRshort    version;
    IGRshort    id;
    IGRshort    res1;
    IGRshort    res2;
    IGRlong     num_overvws;
    IGRlong     ovdata;
};

struct RSptc1sub10              /* I/IMAGE overview info		*/
{
    struct RSdata_packet        header;
    struct RSptc1sub10_data     data;
};

struct RSptc1sub11_data                 /* frastmgr edit/placement dpb  */
{
    IGRshort	version;
    IGRshort    geometry_mode;          /* geometry editing mode:       */
                                        /* 0 - polygon, 1 - block,      */
                                        /* 2 - vector geometry          */
    IGRshort    up_down;                /* flag (1) for increase or (2) */
                                        /* decrease edits               */
    IGRshort    pattern_mode;           /* archaic - now used as a gen- */
                                        /* eral properties mask         */
    IGRshort    resolution_mode;        /* screen (1) vs. dots/unit (0) */
    IGRshort    definition_mode;        /* dynamic (1) vs. predefined (0)*/
    IGRint      dots_per_unit;          /* default dots/units           */
    IGRdouble   canvas_x_dim;           /* default x dimension          */
    IGRdouble   canvas_y_dim;           /* default y dimension          */
    IGRdouble   spray_density;          /* spray density                */
    IGRdouble   edit_factor;            /* intensity/saturation etc.    */
                                        /* edit factor                  */
    IGRdouble   val1;                   /* hue/color/etc value one      */
    IGRdouble   val2;                   /* hue/color/etc value two      */
    IGRdouble   val3;                   /* hue/color/etc value three    */
    IGRdouble   val4;                   /* hue/color/etc value four     */
    IGRdouble   red_coef;               /* black and white red coeff.   */
    IGRdouble   green_coef;             /* black and white green coeff. */
    IGRdouble   blue_coef;              /* black and white blue coeff.  */
    IGRdouble   trans_factor;		/* translucency factor		*/
unsigned   char grayscale_percent;	/* color/grayscale preference   */
					/* 100 = 100% grayscale 0% color*/
    IGRchar	res10;			/* not used			*/
    IGRshort	res11;			/* not used			*/
    IGRlong	res12;			/* not used			*/
    IGRdouble   res13;			/* not used			*/
    IGRdouble   res14;			/* not used			*/
};

struct RSptc1sub11                      /* frastmgr edit/placement dpb  */
{                                       /* data packet                  */
    struct RSdata_packet	header;
    struct RSptc1sub11_data	data;
};

struct RSptc1sub12_data                 /* raster mask object id        */
{
    unsigned int maskid;                /* object id of mask object     */
    IGRlong  global_mask;               /* composite vs. tile mask      */
    IGRlong  row_index;                 /* subfile row index            */
    IGRlong  col_index;                 /* subfile col index            */
    IGRlong  res1;
    IGRlong  res2;
};

struct RSptc1sub12
{
  struct RSdata_packet  header;
  struct RSptc1sub12_data data;
};

struct RSptc1sub13_data
{
    IGRshort	version;
    IGRshort	res1;
    IGRlong	flags;
    IGRlong	num_polygons;
    IGRlong	num_points;
    IGRdouble   points;
};

struct RSptc1sub13		/* I/IMAGE display mask		*/
{
    struct RSdata_packet	header;
    struct RSptc1sub13_data	data;
};


struct RSptc1sub14_data
{
    IGRshort	version;
    IGRshort	num_colors;
    IGRlong	res1;
    IGRlong	colors;		/* starting address of colors   	*/
				/* There are 3 reserved colors followed */
				/* by num_colors colors.  The colors    */
				/* are of type struct RSvc_entry	*/
};

struct RSptc1sub14		/* I/IMAGE virtual color table		*/
{
    struct RSdata_packet	header;
    struct RSptc1sub14_data	data;
};


struct RSptc1sub15_data
{
    IGRshort	version;
    IGRshort	res1;
    IGRlong	properties;
    IGRlong	res2;
    IGRlong	res3;
};

struct RSptc1sub15		/* I/IMAGE properties 			*/
{
    struct RSdata_packet	header;
    struct RSptc1sub15_data	data;
};

struct RSptc1sub20_data
{
    IGRshort    version;
    IGRshort    num_colors;
    IGRshort    res1;
    IGRshort    res2;
    unsigned char color;
};

struct RSptc1sub20              /* I/IMAGE CMYK color table */
{
    struct RSdata_packet        header;
    struct RSptc1sub20_data     data;
};

 struct RSspec
{
	IGRlong   mssg;
	IGRint    mat_size;
	IGRint    num_pass;
	IGRint    bkgnd_val;
	IGRint    pcount;
};

struct RSfeather
{
  IGRlong flag;
  IGRlong radius;
  IGRdouble *distribution;
  IGRlong min;
  IGRlong max;
  IGRchar *edit_func_info;
  IGRboolean (*edit_func)();
  IGRchar *eightbitedit_func_info;
  IGRboolean (*eightbitedit_func)();
};

#endif

