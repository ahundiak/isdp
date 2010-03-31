typedef	unsigned short	IBUF;

struct	global_info
	{
	
	/*
	 *  Information about the window
	 */
	 
	int			wno;
	int			vs_no;
	int			no_planes, vlt_size;
	int			x_ext, y_ext;
	int			x_pix, y_pix;
	int			num_pixels;
	
	/*
	 *  Information about the file
	 */
	 
	FILE			*fp;
	int			rle_type;
	int			x_dits, y_dits;
	
	/*
	 *  Stuff preview use for doing its work
	 */
	 
	IBUF			*image, *merge;
	int			dfact;
	};
	

struct	header_info
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
	char		scannable_flag;	/* bit 0	*/
	long		rotation_angle[2];	/* double	*/
	long		skew_angle[2];	/* double	*/
	short		data_type_modifier; /* should be 0 if data_type_code is unambiguous */
	char		design_filename[66];
	char		dbase_filename[66];
	char		parent_gridfile[66];
	char		file_descript[80];
	char		min_value[8];
	char		max_value[8];
	char		reserved2[3];
	char		gridfile_version;	/* latest = 2	*/
	char		gain;
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
	long		 concat_file_ptr;
	
	/* Discrepancies with the SDN begin here. This may not be a problem, however, if V_LUT
	 * is all that is necessary for downloading the colortable.
 	 */
 	 
	short		reserved4[108];
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
	};
		

