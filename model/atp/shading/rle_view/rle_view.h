#define	TRUE	1
#define FALSE	0

#ifndef BIG_ENDIAN
#define TYPE_09		0x0908
#define TYPE_10		0x000a
#define TYPE_15		0x000f
#define TYPE_25		0x0019
#define TYPE_26		0x001a
#define TYPE_27		0x001b
#define TYPE_29		0x001d
#define	TYPE_89		89<<8
#endif
#define DTM		8

#define TWO_BLOCKS	1024	/* Length of type 25 header */

struct image_info
	{
	int			rle_type;
	int			num_rows, num_cols;
	int			num_planes;
	int			vlt_size;
	int			data_type_modifier;
	short			scanable;
	unsigned char		*red, *green, *blue;
	long                    *index_buf;
	char			name[256];
	};

struct HEADER_BLOCK 
	{
	short		level_type;	
	short		wds_to_follow;	
	short		data_type_code;
	short		app_type_code;
	double		view_origin[3];
	double		view_extent[3];
	double		transformation[16];
	long		num_cols;
	long		num_rows;
	short		device_resolution;
	char		scanline_orient;	/* bits 0-2	*/
	char		scannable_flag;		/* bit 0	*/
	long		rotation_angle[2];	/* double	*/
	long		skew_angle[2];		/* double	*/
	short		data_type_modifier;
	char		design_filename[66];
	char		dbase_filename[66];
	char		parent_gridfile[66];
	char		file_descript[80];
	char		min_value[8];
	char		max_vlaue[8];
	char		reserved2[3];
	char		gridfile_version;	/* latest = 2	*/
	char		gain;	/* start of block 2 */
	char		offset;
	char		vwfull_scr1;
	char		vwfull_scr2;
	char		view_number;
	char		reserved3;
	short		entity_number;
	short		coded_value;
	short		polygon_id;
	short		run_id;
	short		integer_value;
	long		concat_file_ptr;
	short		color_table_type;
	short		reserved5;
	long		num_ctbl_entries;
	short		reserved4[104];
	short		vlt_size;
	short		colors;
	short		shades;
	short		color_bits;
	short		len_bits;
	short		planes;
	short		height;
	short		width;	
	short		x_off;
	short		y_off;
	char		ctbl[256][3];
	} ;
		
struct TYPE_89_HEADER
	{
	short	level_type;
	short	wtf;
	short	row;
	short	col;
	} ;

struct RLE_RECORD
	{
	short color_shade;
	short run_length;
	} ;

