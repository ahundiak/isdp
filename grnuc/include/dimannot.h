#ifndef dim_annot_include
#define dim_annot_include

struct ANtext_data 
{
	struct IGRdisplay	active_display;
	struct GRdpb_text_symb	active_symb;
	struct vfont_entry	font_info;
	struct IGResintx	text_info;
	struct IGRestx		estx;
	struct extents		text_extents;
};

struct GTattr
{
	IGRshort geom_font;
	IGRshort text_font;
	IGRshort ter_font;
	IGRshort active_font;
	IGRchar	  tol_symbol;
	IGRchar	  sep_symbol;
	IGRchar  field_num;
	IGRchar  prev_disp_char;
	IGRshort disp_char_index;
	IGRshort num_disp_char;
	IGRchar  disp_char[1024];
        IGRboolean fraction_flag;
        IGRchar substring[32];
        IGRshort substr_len;
};

struct DMdyn_annot
{
	struct DMsenv_param par_senv;
	struct DMmisc_param par_misc;
	struct DMplan_info plan_info;
	struct ANtext_data  text_st;
	struct DPele_header ele_header;
	struct DPele_header cur_header;
	struct IGRlbsys	lbsys_geom;
	struct GTattr gtattr;
	unsigned char *text_string;
	IGRshort text_length;
	IGRshort text_buff_size;
	IGRdouble attach_pt[3];
	IGRdouble norm_pl[3];
	IGRdouble src_dir[3];
	IGRdouble txt_orie[3];
	IGRshort ter_just;
	IGRshort txt_just;
	IGRint go_count;
	IGRint display_count;
	struct GRid go_grid[10];
	IGRdouble box[4][3];
	struct GRid win_grid;
	IGRint src_type;
};

#define NO_TEXT_LEADER_ROOTS	3
#define NO_LEADER_ROOTS		4

#define AN_ROOT_ELEM1		2
#define AN_ROOT_ELEM2		3

#define PNT_MOVED	0x0001
#define TEXT_ENTERED	0x0002
#define SET_DUAL_MODE	0x1000
#define SET_SINGLE_MODE	0x0100

#define AN_TER_TEXT	0	/* DIM_ORI_TERM */
#define AN_POLY_LINE	1	/* DIM_LEADER */
#define AN_ANNOT_TEXT	2	/* DIM_TEXT */
#define AN_BALLOON	3	/* DIM_BALLOON */

/* - bln stack dir - */

#define RIGHT_SIDE	0
#define LEFT_SIDE	1

#define DELETE_VERTEX	0
#define ADD_VERTEX	1
#define UPDATE_VERTEX	2

#define	AN_NORMAL	1
#define TOL_SYMBOL	2
#define SEPERATOR	3
#define GEOM_SYMBOL	4
#define AN_CHANGE_FONT	5
#define AN_16BIT_CHAR	6
#define AN_8BIT_CHAR	7
#define TOL_MODE	8
#define AN_BEFORE	9
#define AN_AFTER	10
#define AN_TEXT_BEGIN	11
#define MOVE_TO_FIELD	12
#define AN_DUAL_BEGIN	13
#define AN_END_FIELD	14
#define AN_SPACE	15

#define TOL_FIELD	1

#define MAX_AN_TXSTR	75

/*    TOLERANCE TYPES         */
#define STRAIGHTNESS		13
#define FLATNESS		14
#define CIRCULARITY		15
#define CYLINDRICITY		16
#define ANGULARITY		17
#define PERPENDICULARITY	18
#define PARALLELISM		19
#define SYMMETRY		20
#define PROFILE_LINE		21
#define PROFILE_SURFACE		22
#define PROFILE_LINE_TOT	23
#define PROFILE_SURFACE_TOT	24
#define POSITION		25
#define CONCENTRICITY		26
#define CIRCULAR_RUNOUT		27
#define TOTAL_RUNOUT		28
#define TOL_SYMBOL_NONE		23

/*#include "DMannot.h"*/
#endif
