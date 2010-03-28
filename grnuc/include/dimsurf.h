#ifndef dimsurf_include
#define dimsurf_include

/* - Suface symbol component index */

#define SURF_TEXTA	0
#define SURF_TEXTB	1
#define SURF_TEXTC	2
#define SURF_TEXTD	3
#define SURF_TEXTE	4
#define SURF_TEXTF	5
#define SURF_DIR_SYM	6
#define SURF_TERM	7
#define SURF_LEADER	8
#define SURF_SYM_LINE	9
#define SURF_SYM_CIRCLE 10
#define SURF_EXTN_LINE	11

#define MAX_SURF_COMP	12

/*- Surf point index */

#define MID_PT		0
#define START_PT	3
#define BASE_PT		6
#define END_PT		9
#define EXTN_PT		12
#define CEN_PT		15
#define TEXT_A		18
#define TEXT_B		21
#define TEXT_C		24
#define TEXT_D		9
#define TEXT_E		27
#define TEXT_F		30
#define DIR_SYM		33

/*- Surf symbol position */

#define SURF_ABOVE	0
#define SURF_BELOW	1

/*- Surf symbol direction */

#define SURF_RIGHT	0
#define SURF_LEFT	1

/*- Surf basic symbol type -*/

#define SURF_TRIANGLE	0 
#define SURF_ANGLE	1     
#define SURF_CIRCLE	2 

/*- Surf direction of lay symbol type -*/

#define SURF_DIR_NONE	0
#define SURF_DIR_C	1
#define SURF_DIR_M	2
#define SURF_DIR_R	3
#define SURF_DIR_X	4
#define SURF_DIR_P	5
#define SURF_DIR_E	6
#define SURF_DIR_T	7

/*- Surf Form labels */

#define SURF_FORM	7
#define SURF_SUB_FORM	8

struct DMsurf_param
{
	IGRuchar sym_posn;
	IGRuchar line_on;
	IGRuchar basic_sym;
	IGRuchar dir_sym;
	IGRchar text_a[30];
	IGRchar text_b[30];
	IGRchar text_c[30];
	IGRchar text_d[30];
	IGRchar text_e[30];
	IGRchar text_f[30];
};

struct DMdyn_surf
{
	struct DMsenv_param par_senv;
	struct DMplan_info plan_info;
	IGRdouble start_pt[3];
	IGRdouble norm[3];
	IGRdouble src_dir[3];
	IGRdouble txt_orie[3];
	IGRshort ter_just;
	struct GRid go_grid[MAX_SURF_COMP];
	IGRdouble line[6];
	struct GRid win_grid;
	IGRboolean src_type;
};

#endif
