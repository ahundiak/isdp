/*----------------------------------------------------------------------*/
/*	this structure defines the font library header.			*/
/*----------------------------------------------------------------------*/

/*
$Log: struct.h,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:25  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:43  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:37  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:46  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:47  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  19:17:26  tim
 * COMMENT : added Log variable
 * 
*/

typedef struct		
   {
   short 	year;
   char		month;
   char		day;
   }lh_d;

typedef struct	   {
   char		hour;
   char		min;
   char		sec;
   char		sec_100th;
   }lh_t;

typedef struct		
   {
   long		form_ver_num;		/* format version number */
   struct
    	{
    	char	user;			/* change that effects the user interface */
    	char	nfnt;			/* added a new font class(es) */
    	char	chng;			/* change to font_librarian */
    	char	fix;			/* fixed a problem */
    	} libr_ver_num;			/* librarian verion number */

   lh_d	cre_date;		/* library creation date */
   lh_t  cre_time;		/* library creation time */
   lh_d	mod_date;		/* library modification date */
   lh_t	mod_time;		/* library modification time */
   long		last_font;		/* last font manipulated */
   char		lib_descrip[80];	/* general library description */
   short	char_fst_fnt;		/* character fast font */
   short	sym_fst_fnt;		/* symbol fast font */
   short	pat_fst_fnt;		/* pattern fast font */
   short	line_fst_fnt;		/* line fast font */
   char		reserve[56];		/* reserved for future fast fonts */
   long		fnt_ptr;		/* offset to font name table */
   long		fot_ptr;		/* offset to font offset table */
   long		nxt_av_blk;		/* next available position's block # */
   short	nxt_av_wrd;		/* next available position's word # */
   long		rec_len;		/* # of words recoverable in font lib */
   short	reserv[161];		/* reserved for future use */
   }library_header;


typedef struct		
   {
   long		form_ver_num;		/* format version number */
   struct
    	{
    	char	user;			/* change that effects the user interface */
    	char	nfnt;			/* added a new font class(es) */
    	char	chng;			/* change to font_librarian */
    	char	fix;			/* fixed a problem */
    	} libr_ver_num;			/* librarian verion number */

   lh_d	cre_date;		/* library creation date */
   lh_t  cre_time;		/* library creation time */
   lh_d	mod_date;		/* library modification date */
   lh_t	mod_time;		/* library modification time */
   long		last_font;		/* last font manipulated */
   char		lib_descrip[80];	/* general library description */
   short	char_fst_fnt;		/* character fast font */
   short	sym_fst_fnt;		/* symbol fast font */
   short	pat_fst_fnt;		/* pattern fast font */
   short	line_fst_fnt;		/* line fast font */
   char		reserve[56];		/* reserved for future fast fonts */
   long		fnt_ptr;		/* offset to font name table */
   long		fot_ptr;		/* offset to font offset table */
   long		nxt_av_blk;		/* next available position's block # */
   short	nxt_av_wrd;		/* next available position's word # */
   }lh_sub1;

typedef struct		
   {
   long		rec_len;		/* # of words recoverable in font lib */
   short	reserv[161];		/* reserved for future use */
   }lh_sub2;

/*----------------------------------------------------------------------*/
/*	this structure defines the font name table structure and 	*/
/*	the name record structure.				        */
/*----------------------------------------------------------------------*/
typedef struct	
    {
    short	font_num;		/* font number */
    char	fnt_nm[40];		/* font name */
    }name_record;
    			    
typedef struct	
    {
    short		num_of_nm;	/* number of names in name table */
    name_record	name[200];	/* font numbers and names */
    }fnt_nm_table;   		

/*----------------------------------------------------------------------*/
/*	this structure defines the font offset node.			*/
/*----------------------------------------------------------------------*/
typedef struct 	
    {
    short	first_font;		/* beg font # for this node */
    short	last_font;		/* end font # for this node */
    long	next_node;		/* offset to next font offset table */
    long	fnt_hdr_ptr[256];	/* offset to font headers for this node */
    }font_offset_table;

typedef struct 	
    {
    short	first_font;		/* beg font # for this node */
    short	last_font;		/* end font # for this node */
    }fot_sub1;

typedef struct 	
    {
    long	next_node;		/* offset to next font offset table */
    long	fnt_hdr_ptr[256];	/* offset to font headers for this node */
    }fot_sub2;

/*----------------------------------------------------------------------*/
/*	this structure defines the font header.				*/
/*----------------------------------------------------------------------*/
typedef struct	
    {
    lh_d	cre_date;		/* font creation date */
    lh_t cre_time;		/* font creation time */
    lh_d	mod_date;		/* font modification date */
    lh_t	mod_time;		/* font modification time */
    char	font_descrip[80];	/* general font description */
    short	font_class;		/* font class (char, symbol) */
    short	display_font;		/* display font */
    short	vect_wrd_size;		/* vector word size */
    int		x_origin;		/* x character origin */
    int		y_origin;		/* y character origin */
    double	x_scale;		/* x scale factor */
    double	y_scale;		/* y scale factor */
    int		tile_hgth;		/* face perfect tile height */
    short	res_bm;			/* resolution bit mask */
    long	res_0;			/* offset to dct for res 0 */
    long	res_1;			/* offset to dct for res 1 */
    long	res_2;			/* offset to dct for res 2 */
    long	res_3;			/* offset to dct for res 3 */
    long	res_4;			/* offset to dct for res 4 */
    long	res_5;			/* offset to dct for res 5 */
    long	res_6;			/* offset to dct for res 6 */
    long	res_7;			/* offset to dct for res 7 */
    short	reserv;			/* reserved for future use */
    short	beg_char;		/* beg character code for font */
    short	end_char;		/* end character code for font */
    short	num_of_char;		/* # of defined characters in font */
    short	code_size;		/* variable character code size (1 or 2 bytes) */
    short	face_fnt_dir;		/* reserved */
    int		char_def_len;		/* # of bytes in character definitions */
    int		ccot_ptr;		/* offset to character code offset table */
    int		cdt_ptr;		/* offset to character dimension table */
    short	dim_flag;		/* dimension flag word */
    long	vcot_ptr;		/* offset to vertice class offset table */
    int		flags;			/* # of representation fonts/representation font #'s */
    long	hdr_exp;		/* offset to header expansion (reserved ) */
    long	fnt_len;		/* # of bytes in font */
    }font_header;

typedef struct	
    {
    lh_d	cre_date;		/* font creation date */
    lh_t cre_time;		/* font creation time */
    lh_d	mod_date;		/* font modification date */
    lh_t	mod_time;		/* font modification time */
    char	font_descrip[80];	/* general font description */
    short	font_class;		/* font class (char, symbol) */
    short	display_font;		/* display font */
    short	vect_wrd_size;		/* vector word size */
    } fh_sub1;

typedef struct
    {
    int		x_origin;		/* x character origin */
    int		y_origin;		/* y character origin */
    double	x_scale;		/* x scale factor */
    double	y_scale;		/* y scale factor */
    int		tile_hgth;		/* face perfect tile height */
    short	res_bm;			/* resolution bit mask */
    } fh_sub2;

typedef struct
 {   
    long	res_0;			/* offset to dct for res 0 */
    long	res_1;			/* offset to dct for res 1 */
    long	res_2;			/* offset to dct for res 2 */
    long	res_3;			/* offset to dct for res 3 */
    long	res_4;			/* offset to dct for res 4 */
    long	res_5;			/* offset to dct for res 5 */
    long	res_6;			/* offset to dct for res 6 */
    long	res_7;			/* offset to dct for res 7 */
    short	reserv;			/* reserved for future use */
    short	beg_char;		/* beg character code for font */
    short	end_char;		/* end character code for font */
    short	num_of_char;		/* # of defined characters in font */
    short	code_size;		/* variable character code size (1 or 2 bytes) */
    short	face_fnt_dir;		/* reserved */
    int		char_def_len;		/* # of bytes in character definitions */
    int		ccot_ptr;		/* offset to character code offset table */
    int		cdt_ptr;		/* offset to character dimension table */
    short	dim_flag;		/* dimension flag word */
    }fh_sub3;

typedef struct
 
 { 
    long	vcot_ptr;		/* offset to vertice class offset table */
    int		flags;			/* # of representation fonts/representation font #'s */
    long	hdr_exp;		/* offset to header expansion (reserved ) */
    long	fnt_len;		/* # of bytes in font */
 } fh_sub4;

/*----------------------------------------------------------------------*/
/*	this structure defines the character dimension table		*/
/*----------------------------------------------------------------------*/
typedef struct		
    {
    short	first_char;		/* beg character code for this node */
    short	last_char;		/* end character code for this node */
    short	next_node;		/* offset to next character dimension table */
union					
    {
    char	byt[1280];		/* byte dimension data */
    short	wrd[1280];		/* word dimension data */
    long	lng[1];			/* long dimension data-FUTURE */
    }  dim_data;
    }char_dim_table;

typedef struct		
    {
    short	first_char;		/* beg character code for this node */
    short	last_char;		/* end character code for this node */
    short	next_node;		/* offset to next character dimension table */
    }cdt_sub1;

typedef struct					
    {
    char	byt[1280];		/* byte dimension data */
    short	wrd[1280];		/* word dimension data */
    long	lng[1];			/* long dimension data-FUTURE */
    }cdt_sub2;
   
/*----------------------------------------------------------------------*/
/*	this structure defines the character code offset table		*/
/*----------------------------------------------------------------------*/
typedef struct		
    {
    short	first_char;		/* beg character code for this node */
    short	last_char;		/* end character code for this node */
    short	next_node;		/* offset to next char code offset table */
    short	ch_hdr_ptr[256];	/* offset to char headers for this node */
    }char_code_off_tbl;
 
typedef union
    {
     short flib_buf[4096];
     double dummy;
    }buf_union;
