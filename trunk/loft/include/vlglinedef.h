/* 
  glinedef.h
  ludovic Le Corvec
  5_oct_92

  History :

  13_jan_93 : Change macro description
*/

#ifndef vlglinedef_include
#define	vlglinedef_include

#define	plug_generic	0x00100000

/* ----------------- Generic Definition -------------------------------	*/

	/* ---- Base Line ---- */
#define	GEN_DEF_1	"BaseGenLine"

/* --- List of template for macros --- */
#define	INDEX_HULL	0
#define	NAME_HULL	"hull"
#define	INDEX_CS	1
#define	NAME_CS		"direction"
#define	INDEX_GR_INFO	2
#define	NAME_GR_INFO	"data"
#define	INDEX_PT_SELECT	3
#define	NAME_PT_SELECT	"pt_select"
#define	INDEX_AL_CS	4
#define NAME_AL_CS	"allowance_dir"
#define INDEX_ATT_BOX	5
#define NAME_ATT_BOX	"attrib_box"

/* --- Name of optional attributs store in attribute box --- */
#define	N_ATT_SELECTOR	"@selector"
#define N_ATT_AL_VAL	"@allow_val"
#define N_ATT_EXTRA_AL	"@extra_allow_val"

	/* ---- Next Line ---- */
#define GEN_DEF_2	"NextGenLine"

/* ---- Templates add to Base Line list ----- */
#define	INDEX_START_CL	6
#define NAME_CNTRL_LINE	"cntrl_line"

/* --- Name of optional attributs stored in attribute box --- */
#define	N_ATT_LEN_ALONG		"@length_along"
#define	N_ATT_LEN_ALONG2	"@length_along2"
#define	N_ATT_LAW		"@law"
#define	N_ATT_DIVISOR		"@divisor"
#define	N_ATT_ITERATION		"@iteration"

/* --- Name of optional attributs stored in contents box --- */
#define N_ATT_MR_LEN		"mr_len"
#define	N_ATT_MR_WID		"mr_wid"
#define	N_ATT_3D_LEN		"3d_len"
#define N_ATT_DATA_NAME		"dataName"

/* define of index and name for feet */
#define MAX_BASE_FEET	2
#define MAX_NEXT_FEET	4

#define I_MF_CV		0
#define	MAN_GR_FEET	"graphics"
#define I_MF_CONTENTS	1
#define N_MF_CONTENTS	"contents"
#define I_MF_PT_LIM	2
#define N_MF_PT_LIM	"pt_lim"
#define I_MF_TG		3
#define N_MF_TG		"tangent"

/* ------------------------ BUTT definition ---------------------------	*/

/* definition name */
#define	BUTT_DEF_1	"BaseButt"
#define BUTT_DEF_2	"NextButt"
#define BUTT_DEF_3	"NextButtDev"
#define	BUTT_DEF_4	"CurvedButt"

/* ---- Add attribut on GenLine list ---- */
#define N_ATT_TST_W	"@test_width"

/* ------------------------ SEAM definition ---------------------------	*/

/* definition name */
#define	SEAM_DEF_1	"BaseSeam"
#define	SEAM_DEF_2	"NextSeam"
#define	SEAM_DEF_3	"NextSeamDev"
#define	SEAM_DEF_4	"CurvedSeam"

/* ------------------------ Water Line definition ---------------------	*/

/* definition name */
#define	WatLine_DEF_1	"WatLine"

/* ------------------------ Trace definition -------------------------- */
#define TRACE_DEF_4   "VLtrace"

/* ====== Define Values for selector attribute ====== */
#define V_ATT_TYPE_MASK	0x0007
#define V_ATT_BASE	0x0000
#define V_ATT_CURVED	0x0001
#define	V_ATT_NEXT	0x0002
#define	V_ATT_DEV	0x0003

/* ===== Define specific seam attributs ===== */
/* -- law of distribition -- */
#define V_ATT_LAW_MASK	0x000f
#define	V_ATT_LINEAR	0x0000
#define	V_ATT_PARABOLIC	0x0001		
#define	V_ATT_OT_PARA	0x0002		
#define	V_ATT_CUBIC	0x0003
#define	V_ATT_CUBIC2	0x0004
#define	V_ATT_QUINTIC	0x0005
/* -- seam properties -- */
#define V_ATT_S_PROP_MASK	0x00f0
#define	V_ATT_S_PROJ		0x0010	/* project curve on surface */
#define V_ATT_S_LISS		0x0020	/* smooth line string */


/* --------------- Properties definition ------------ */
#define V_PROP_CUT      0x0001          // Cut or Mark Line

#endif
