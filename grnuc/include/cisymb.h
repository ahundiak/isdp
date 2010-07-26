// General variable containing the symbology for the Associative Geometry
// "place" messages.
// This must be included if object are set with non interactive functions
// using the construction list.
//
// N.B.: the order of following fields is very important and must not 
// be changed
//
// File dependency: none

#ifndef cisymb_include
#define cisymb_include
struct {
	// display attributes
	short	color;		// 1
	char	weight;		// 2
	char	style;		// 3
	short	level;		// 4
	char	locatable;	// 5
	char	displayable;	// 6
	// text attributes
	short	font;		// 7
	short	just;		// 8
	double	width;		// 9	transformed to y_scale
	double	height;		// 10	transformed to x_scale
	short	num_char;	// 11
	double	line_spac;	// 12
	double	char_spac;	// 13
	short	text_length;	// 14
	char	*text_string;	// 15
	char	*geometry;	// 16
} cnst_list;

// old functions keeped for historical reasons
#define setcolor(n)	cnst_list.color = n; set_symb()
#define setweight(n)	cnst_list.weight = n; set_symb()
#define setstyle(n)	cnst_list.style = n; set_symb()
#define setlevel(n)	cnst_list.level = n; set_symb()

#define set_galcolor(n)	cnst_list.color = n; set_gal_symb()
#define set_galweight(n)	cnst_list.weight = n; set_gal_symb()
#define set_galstyle(n)	cnst_list.style = n; set_gal_symb()
#define set_gallevel(n)	cnst_list.level = n; set_gal_symb()

#define setfont(n)	cnst_list.font = n; set_text_attr()

#endif
