#ifndef dimsrc_include

#define dimsrc_include

#define DMkeypt		0
#define DMkeyseg	1
#define DM2ptseg	2
#define DMaxis		3
#define DMradcen	4
#define DMtanpt		5
#define DMintpt		6
#define DMmidpt		7
#define DMptdist	8
#define DMarc		9
#define DMcenpt		10
#define DMedgept	11
#define DMedgeseg	12
#define DMconstpt	13
#define DMconstln	14


/* - Axis directions - */

#define WIN_X_AXIS	0
#define WIN_Y_AXIS	1
#define ACT_X_AXIS	2
#define ACT_Y_AXIS	3

/* - Instance Data Structure Definitions - */

struct src_attr
{
	IGRint type;
	IGRdouble *attr;
};

struct DMkeypt_str
{
	IGRdouble	u_par;
	IGRdouble	point[3];
};

struct DMmidpt_str
{
	IGRdouble	u_par;
	IGRdouble	point[3];
};

struct DMptdist_str
{
	IGRdouble	u_par;
	IGRdouble	vec[3];
	IGRdouble	point[3];
};

struct DMkeyseg_str
{
	IGRdouble	u_par;
	IGRdouble	line[6];
};

struct DM2ptseg_str
{
	IGRdouble	u_par1, u_par2;
	IGRdouble	line[6];
};

struct DMaxis_str
{
	IGRdouble	u_par;
	IGRdouble	line[6];
	IGRint		axis;
};

struct DMradcen_str
{
	IGRdouble	u_par;
	IGRdouble	point[3];
	IGRdouble	center[3];
	IGRdouble	radius;
	IGRboolean	on_curve;
};

struct DMtanpt_str
{
	IGRdouble	u_par;
	IGRdouble	point[3];
};

struct DMintpt_str
{
	IGRdouble	u_par1, u_par2;
	IGRpoint	point;
};

struct DMarc_str
{
	IGRpoint center;
	IGRpoint start_pt;
	IGRpoint end_pt;
};

struct DMcenpt_str
{
	IGRdouble u_par;
	IGRpoint point;
};

struct DMedgept_str
{
	IGRdouble u_par;
	IGRpoint point;
};

struct DMedgeseg_str
{
	IGRdouble u_par;
	IGRdouble line[6];
};

struct DMpt_str 
{
	IGRpoint point; 
};
struct DMln_str 
{
	IGRdouble line[6]; 
};

struct dim_src_info
{
	IGRint type;

	IGRboolean degraded;
	IGRint num_parents;
	struct GRid parents[3];
	struct GRid context[3];

	union
	{
		struct DMkeypt_str	dm_keypt;
		struct DMmidpt_str	dm_midpt;
		struct DMptdist_str	dm_ptdist;
		struct DMkeyseg_str	dm_keyseg;
		struct DM2ptseg_str	dm_2ptseg;
		struct DMaxis_str	dm_axis;
		struct DMradcen_str	dm_radcen;
		struct DMtanpt_str	dm_tanpt;
		struct DMintpt_str	dm_intpt;
		struct DMarc_str	dm_arc;
		struct DMcenpt_str	dm_cenpt;
		struct DMedgept_str	dm_edgept;
		struct DMedgeseg_str	dm_edgeseg;
		struct DMpt_str		dm_pt;
		struct DMln_str		dm_line;
	} var;
};

struct dim_ret_struct
{
	IGRint type;

	union
	{
		struct DMkeypt_str	dm_keypt;
		struct DMmidpt_str	dm_midpt;
		struct DMptdist_str	dm_ptdist;
		struct DMkeyseg_str	dm_keyseg;
		struct DM2ptseg_str	dm_2ptseg;
		struct DMaxis_str	dm_axis;
		struct DMradcen_str	dm_radcen;
		struct DMtanpt_str	dm_tanpt;
		struct DMintpt_str	dm_intpt;
		struct DMarc_str	dm_arc;
		struct DMcenpt_str	dm_cenpt;
		struct DMedgept_str	dm_edgept;
		struct DMedgeseg_str	dm_edgeseg;
		struct DMpt_str		dm_pt;
		struct DMln_str		dm_line;
	} var;
};


#omdef dm$create_root(
		type,
		construct = TRUE,
		count,
		list,
		context,
		attr,
		md_env,
		p_root)

	DMcreate_root(
		type,
		construct,
		count,
		list,
		context,
		attr,
		md_env,
		p_root)

#endomdef

#endif

