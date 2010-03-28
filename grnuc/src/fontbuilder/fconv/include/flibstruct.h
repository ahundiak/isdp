/*----------------------------------------------------------------------*/
/*  	this structure defines the font library header.r                */
/*----------------------------------------------------------------------*/

/*
$Log: flibstruct.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:55  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:11  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:08  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:27  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:42  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:42:38  tim
 * COMMENT : added Log variable
 *
*/

#ifndef flib_struct_include
#define flib_struct_include

#define CHARACTER_CLASS (0)
#define SYMBOL_CLASS    (1)


struct	lh_d
   {
   short 	year;
   char		month;
   char		day;
   };

struct	lh_t
   {
   char		hour;
   char		min;
   char		sec;
   char		sec_100th;
   };

struct	library_header
   {
   int 		form_ver_num;	 /* format version number                    */
   struct
    	{
        char	user;		 /* change that effects the user interface   */
    	char	nfnt;		 /* added a new font class(es)               */
    	char	chng;		 /* change to font_librarian                 */
    	char	fix;		 /* fixed a problem                          */
    	} libr_ver_num;		 /* librarian verion number                  */

   struct lh_d	cre_date;	 /* library creation date                    */
   struct lh_t  cre_time;	 /* library creation time                    */
   struct lh_d	mod_date;	 /* library modification date                */
   struct lh_t	mod_time;	 /* library modification time                */
   int 		last_font;	 /* last font manipulated                    */
   char		lib_descrip[80]; /* general library description              */
   short	char_fst_fnt;	 /* character fast font                      */
   short	sym_fst_fnt;	 /* symbol fast font                         */
   short	pat_fst_fnt;	 /* pattern fast font                        */
   short	line_fst_fnt;	 /* line fast font                           */
   char		reserve[56];	 /* reserved for future fast fonts           */
   int 		fnt_ptr;	 /* offset to font name table                */
   int 		fot_ptr;	 /* offset to font offset table              */
   int 		nxt_av_blk;	 /* next available position's block #        */
   short	nxt_av_wrd;	 /* next available position's word  #        */
   int 		rec_len;	 /* # of words recoverable in font lib       */
   short	reserv[161];	 /* reserved for future use                  */
   };

/*----------------------------------------------------------------------*/
/*	this structure defines the font name table structure and 	*/
/*	the name record structure.				        */
/*----------------------------------------------------------------------*/

struct	name_record
    {
    short	font_num;		/* font number */
    char	fnt_nm[40];		/* font name   */
    };
    			    
struct	fnt_nm_table
    {
    short		num_of_nm;	/* number of names in name table */
    struct name_record	name[200];	/* font numbers and names        */
    };   		

/*----------------------------------------------------------------------*/
/*	this structure defines the font offset node.			*/
/*----------------------------------------------------------------------*/

struct 	font_offset_table
    {
    short	first_font;	  /* beg font # for this node             */
    short	last_font;	  /* end font # for this node             */
    int 	next_node;	  /* offset to next font offset table     */
    int 	fnt_hdr_ptr[256]; /* offset to font headers for this node */
    };

/*----------------------------------------------------------------------*/
/*	this structure defines the font header.				*/
/*----------------------------------------------------------------------*/

struct	font_header
    {
    struct lh_d	cre_date;	  /* font creation date                      */
    struct lh_t cre_time;	  /* font creation time                      */
    struct lh_d	mod_date;	  /* font modification date                  */
    struct lh_t	mod_time;	  /* font modification time                  */
    char	font_descrip[80]; /* general font description                */
    short	font_class;	  /* font class (char, symbol)               */
    short	display_font;	  /* display font                            */
    short	vect_wrd_size;	  /* vector word size                        */
    int		x_origin;	  /* x character origin                      */
    int		y_origin;	  /* y character origin                      */
    double	x_scale;	  /* x scale factor                          */
    double	y_scale;	  /* y scale factor                          */
    int		tile_hgth;	  /* face perfect tile height                */
    short	res_bm;		  /* resolution bit mask                     */
    int 	res_0;		  /* offset to dct for res 0                 */
    int 	res_1;		  /* offset to dct for res 1                 */
    int 	res_2;		  /* offset to dct for res 2                 */
    int 	res_3;		  /* offset to dct for res 3                 */
    int 	res_4;		  /* offset to dct for res 4                 */
    int 	res_5;		  /* offset to dct for res 5                 */
    int 	res_6;		  /* offset to dct for res 6                 */
    int 	res_7;		  /* offset to dct for res 7                 */
    short	reserv;		  /* reserved for future use                 */
    short	beg_char;	  /* beg character code for font             */
    short	end_char;	  /* end character code for font             */
    short	num_of_char;	  /* # of defined characters in font         */
    short	code_size;	  /* variable character code size
                                     (1 or 2 bytes)                          */
    short	face_fnt_dir;	  /* reserved                                */
    int		char_def_len;	  /* # of bytes in character definitions     */
    int		ccot_ptr;	  /* offset to character code offset table   */
    int		cdt_ptr;	  /* offset to character dimension table     */
    short	dim_flag;	  /* dimension flag word                     */
    int 	vcot_ptr;	  /* offset to vertice class offset table    */
    int		flags;		  /* # of representation fonts/representation
                                     font #'s                                */
    int 	hdr_exp;	  /* offset to header expansion (reserved )  */
    int 	fnt_len;	  /* # of bytes in font                      */
    };

/*----------------------------------------------------------------------*/
/*	this structure defines the character dimension table		*/
/*----------------------------------------------------------------------*/

struct	char_dim_table
    {
    short	first_char;	/* beg character code for this node          */
    short	last_char;	/* end character code for this node          */
    short	next_node;	/* offset to next character dimension table  */
    union
       {
       char	byt[1280];	/* byte dimension data                       */
       short	wrd[1280];	/* word dimension data                       */
       }  dim_data;
    };

/*----------------------------------------------------------------------*/
/*	this structure defines the character code offset table		*/
/*----------------------------------------------------------------------*/

struct	char_code_off_tbl
    {
    short	first_char;	 /* beg character code for this node         */
    short	last_char;	 /* end character code for this node         */
    short	next_node;	 /* offset to next char code offset table    */
    short	ch_hdr_ptr[256]; /* offset to char headers for this node     */
    };

#endif /* end flib_struct_include */
