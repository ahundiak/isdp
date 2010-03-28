#ifndef dim_weld_include
#define dim_weld_include
 
struct DMdyn_weld
{
	struct DMsenv_param par_senv;
	struct DMplan_info plan_info;
	IGRdouble attach_pt[3];
	IGRdouble norm_pl[3];
	IGRdouble src_dir[3];
	IGRshort ter_just;
	struct GRid go_grid[22];
	struct GRid win_grid;
	IGRint src_type;
};

/* - Weld Dash line Dir */

#define ABOVE		1
#define BELOW		2

/* - Weld Symbol Component Index */

#define AFTEXT		0
#define ARTEXT		1
#define AATEXT		2
#define BFTEXT		3
#define BRTEXT		4
#define BATEXT		5
#define SYMBOL1		6
#define SYMBOL2		7
#define ZSTEXT		8
#define AZTEXT		9
#define	BZTEXT		10
#define TLTEXT		11
#define FLAG		12
#define CIRCLE		13
#define TERM		14
#define DASH_LINE	15
#define LEAD_LINE	16
#define TAIL_LINE	17
#define CS_LINE1	18
#define CS_LINE2	19
#define CS_ARC1		20
#define CS_ARC2		21

/* - Weld type */

#define WL_BLANK	11
#define WL_FLUSH	12
#define WL_CONVEX	13
#define WL_CONCAVE	14


/* - Types of Cross_section */

#define VWELD_CS	1
#define BEVEL_CS	2
#define FILLET_CS	3

#endif
