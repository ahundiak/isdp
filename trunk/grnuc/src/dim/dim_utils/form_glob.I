class implementation DMroot;

%safe
#include "math.h"
%endsafe

#include "FI.h"
#include "FEI.h"
#include "CIforms.h"
#include "dimformdef.h"
#include "dimform.h"

#include "form_env.h"
#include "form_loc.h"

%safe

static  char *opt[][MAX_OPTIONS+1] = {

#define NONE		0
                    {NULL},
#define ON_OFF		1
                    { "On", "Off" },
#define OFF_ON		2
                    { "Off", "On" },
#define LIN_UNITS	3
		    { "ft-in", "meters", "mm", "inches" },
#define DOT_COMMA	4
                    { ".", "," },
#define BEF_AFT_NON	5
                    { "Before", "After", "None" },
#define MODE		6
                    { "Modeling", "Detailing" },
#define STANDARDS	7
                    { "ANSI", "ISO", "BSI", "JIS", "DIN"},
#define ABO_EMBB	8
                    { "Above", "Embedded" },
#define TERM_TYPE	9
                    { "Hollow", "Filled", "Open", "Slash", "Back_slash",
                                                   "Blank", "Dot", "Circle" },
#define REF_TYPE	10
                    { "Parens", "Suffix", "Subfix" },
#define PAR_HOR		11
                    { "Horizontal", "Vertical", "Parallel", "Perpendicular" },
#define DIM_DISP	12
                    { "Default", "All", "Parallel" },
#define DECIMAL		13
                    { "10", "1", ".1", ".12", ".123", ".1234",".12345",
                                                     ".123456", ".1234567" },
#define FRACTIONAL	14
                    { "1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64" },
#define IN_OUT		15
                    { "Inside", "Outside" },
#define JUST		16
                    { "Center", "Left", "Right", "Just_?"},
#define SIDE		17
                    { "Center", "1st point", "2nd point" },
#define AUTO_IN_OUT	18
                    {"Auto","Internal","External" },
#define FORMAT		19
                    { "Nominal", "Up_low", "Symbol", "Limits", "Box", "Ref" },
#define PRI_SEC		20
                    { "Primary", "Secondary" },
#define DEC_FRAC	21
                    { "Decimal", "Fraction" },
#define STAT_DYN	22
                    { "Static", "Dynamic" },
#define AXIS		23
                    { "Parallel", "Perpendicular", "By 2 points", "Horizontal",
                                               "Vertical", "Orthogonal" },
#define OPTEND		24
                    { "end" },
#define TERM_DISP	25
                    { "Off", "Origin", "Measurement", "Both"},
#define ADD_TEXT_DISP	26
                    { "Off", "Prefix", "Suffix", "Both" },
#define PROJ_LIN_DISP   27
		    { "Off", "Origin", "Measure", "Both" },
#define RAD_DEG         28
		    { "Deg-Min-Sec", "Radians", "Degrees" },
#define FEET_INCHES	29
		    { "Normal", "Feet-Inches" },
#define ROFF_UNITS	30
		    { "Degrees", "Minutes", "Seconds" },
#define COMM_ORIG	31
                    { "Dot", "Circle", "None" },
#define BAL_TYPE	32
		    { "Circle", "Triangle", "Square", "Polygon" },
#define ANNOT_POSN	33
		    { "Bottom", "Center", "Above", "Underline" },
#define DATUM_TERM	34
		    { "Normal", "Anchor" },
#define ANNOT_ORIE      35
                    { "Horizontal", "Vertical", "Parallel" },
#define PROJ_METHOD	36
		    { "first angle", "third angle" },
             };

struct DMkeyin_desc DMkeyin_list[] =
{
	{	"possible values", opt[NONE], DIM_ALPHA,
		KEY_POSS_VALUES, NOT_ON_FORM
	},

	{	"actual values", opt[NONE], DIM_ALPHA,
		KEY_ACT_VALUES, NOT_ON_FORM
	},

	{	"fraction font",  opt[NONE], DIM_ALPHA,
		KEY_FRAC_FONT, NOT_ON_FORM
	},

	{	"origin terminator type", opt[TERM_TYPE], DIM_INT,
		KEY_TER_TYPE0, NOT_ON_FORM
	},

	{	"terminator display", opt[TERM_DISP], DIM_INT,
		KEY_TER_DISP, NOT_ON_FORM
	},
                                
	{	"upper tolerance", opt[NONE], DIM_ALPHA,
		KEY_PRI_TOLE_UP, NOT_ON_FORM
	},

	{	"lower tolerance", opt[NONE], DIM_ALPHA,
		KEY_PRI_TOLE_LOW, NOT_ON_FORM
	},

	{	"tolerance symbol", opt[NONE], DIM_ALPHA,
		KEY_PRI_TOLE_SYM, NOT_ON_FORM
	},

	{	"secondary upper tolerance", opt[NONE], DIM_ALPHA,
		KEY_SEC_TOLE_UP, NOT_ON_FORM
	},

	{	"secondary lower tolerance", opt[NONE], DIM_ALPHA,
		KEY_SEC_TOLE_LOW, NOT_ON_FORM
	},

	{	"secondary tolerance symbol", opt[NONE], DIM_ALPHA,
		KEY_SEC_TOLE_SYM, NOT_ON_FORM
	},

	{	"units", opt[LIN_UNITS], DIM_ROLL,
		KEY_PRI_UNITS, NOT_ON_FORM
	},

	{	"secondary units", opt[LIN_UNITS], DIM_ROLL,
		KEY_SEC_UNITS, NOT_ON_FORM
	},

	{	"leading zeros", opt[OFF_ON], DIM_TOGGLE,
		KEY_PRI_LEADING, NOT_ON_FORM
	},

	{	"trailing zeros", opt[OFF_ON], DIM_TOGGLE,
		KEY_PRI_TRAILING, NOT_ON_FORM
	},

	{	"secondary leading zeros", opt[OFF_ON], DIM_TOGGLE,
		KEY_SEC_LEADING, NOT_ON_FORM
	},

	{	"secondary trailing zeros", opt[OFF_ON], DIM_TOGGLE,
		KEY_SEC_TRAILING, NOT_ON_FORM
	},

	{	"width",  opt[NONE], DIM_DOUBLE,
		KEY_TXT_WIDT, NOT_ON_FORM
	},

	{	"terminator size",  opt[NONE], DIM_DOUBLE,
		KEY_TERM_SIZE, NOT_ON_FORM
	},

	{	"label", opt[NONE], DIM_ALPHA,
		KEY_PRI_LABEL, NOT_ON_FORM
	},

	{	"subunits label", opt[NONE], DIM_ALPHA,
		KEY_PRI_SUB_LABEL, NOT_ON_FORM
	},

	{	"secondary label", opt[NONE], DIM_ALPHA,
		KEY_SEC_LABEL, NOT_ON_FORM
	},

	{	"secondary subunits label", opt[NONE], DIM_ALPHA,
		KEY_SEC_SUB_LABEL, NOT_ON_FORM
	},

	{	"balloon type", opt[BAL_TYPE], DIM_INT,
		KEY_BLN_TYPE, NOT_ON_FORM
	},

	{	"balloon size", opt[NONE], DIM_DOUBLE,
		KEY_BLN_SIZE, NOT_ON_FORM
	},

	{	"num sides", opt[NONE], DIM_INT,
		KEY_NUM_SIDES, NOT_ON_FORM
	},

	{	"datum terminator type", opt[DATUM_TERM], DIM_TOGGLE,
		KEY_DATUM_TERM, NOT_ON_FORM
	},

	{	"dual display", opt[OFF_ON], DIM_TOGGLE,
		GAD_DUAL_MODE, FORM_ENVIRON
	},

	{	"angular units", opt[RAD_DEG], DIM_ROLL,
		GAD_ANG_UNITS, FORM_ENVIRON
	},

	{	"delimiter", opt[DOT_COMMA], DIM_TOGGLE,
		GAD_DELIMITER, FORM_ENVIRON
	},

	{	"height", opt[NONE], DIM_DOUBLE,
		GAD_TXT_HEIG, FORM_ENVIRON
	},

	{	"ratio",  opt[NONE], DIM_DOUBLE,
		GAD_ASP_RATI, FORM_ENVIRON
	},

	{	"text weight",  opt[NONE], DIM_INT,
		GAD_TXT_WEIG, FORM_ENVIRON
	},

	{	"tolerance weight",  opt[NONE], DIM_INT,
		GAD_TOL_WEIG, FORM_ENVIRON
	},

	{	"dim line weight",  opt[NONE], DIM_INT,
		GAD_DIM_WEIG, FORM_ENVIRON
	},

	{	"font",  opt[NONE], DIM_ALPHA,
		GAD_TXT_FONT, FORM_ENVIRON
	},

	{	"color",  opt[NONE], DIM_ALPHA,
		GAD_DIM_COLR, FORM_ENVIRON
	},

	{	"layer",  opt[NONE], DIM_ALPHA,
		GAD_DIM_LAYR, FORM_ENVIRON
	},

	{	"projection above",  opt[NONE], DIM_DOUBLE,
		GAD_PROJ_EXTN, FORM_ENVIRON
	},

	{	"stack dimension pitch",  opt[NONE], DIM_DOUBLE,
		GAD_LIN_OFFS, FORM_ENVIRON
	},

	{	"gap",  opt[NONE], DIM_DOUBLE,
		GAD_PROJ_OFFS, FORM_ENVIRON
	},

	{	"angle",  opt[NONE], DIM_DOUBLE,
		GAD_PROJ_ANGL, FORM_DISPLAY
	},

	{	"terminator inside limit", opt[NONE], DIM_DOUBLE,
		GAD_TER_LIMIT, FORM_ENVIRON
	},

	{	"offset",  opt[NONE], DIM_DOUBLE,
		GAD_TXT_YOFF, FORM_ENVIRON
	},

	{	"tolerance height ratio", opt[NONE], DIM_DOUBLE,
		GAD_TOL_SIZE, FORM_ENVIRON
	},

	{	"dim line connect", opt[OFF_ON], DIM_TOGGLE,
		GAD_LIN_DISP, FORM_ENVIRON
	},

	{	"standard", opt[STANDARDS], DIM_ROLL,
		GAD_DIM_STAN, FORM_ENVIRON
	},

	{	"common origin", opt[COMM_ORIG], DIM_INT,
		GAD_COMM_ORIG, FORM_ENVIRON
	},

	{	"symbol position", opt[BEF_AFT_NON], DIM_ROLL,
		GAD_SYM_POSN, FORM_ENVIRON
	},

	{	"maximum subunits", opt[NONE], DIM_INT,
		GAD_MAX_SUB, FORM_ENVIRON
	},

	{	"terminator type", opt[TERM_TYPE], DIM_INT,
		SUB_FORM_LABEL, FORM_DIMTERM
	},

	{	"text position", opt[ABO_EMBB], DIM_ROLL,
		GAD_TXT_POSN, FORM_DISPLAY
	},

	{	"coordinate text position", opt[ABO_EMBB], DIM_TOGGLE,
		KEY_CTXT_POSN, NOT_ON_FORM
	},

	{	"annotation position", opt[ANNOT_POSN], DIM_INT,
		KEY_ANNOT_POSN, NOT_ON_FORM
	},

	{	"text orientation", opt[PAR_HOR], DIM_ROLL,
		GAD_TXT_ORIE, FORM_DISPLAY
	},

	{	"annotation orientation", opt[ANNOT_ORIE], DIM_INT,
		KEY_ANNOT_ORIE, NOT_ON_FORM
	},

	{	"origin line display", opt[OFF_ON], DIM_TOGGLE,
		GAD_ORI_DISP, FORM_DISPLAY
	},

	{	"measurement line display", opt[OFF_ON], DIM_TOGGLE,
		GAD_MEA_DISP, FORM_DISPLAY
	},

	{	"auto center mode", opt[OFF_ON], DIM_TOGGLE,
		GAD_AUT_CENT, FORM_LOCAL
	},

	{	"auto suppress diameter", opt[OFF_ON], DIM_TOGGLE,
		KEY_AUT_SUPPRESS, NOT_ON_FORM
	},

	{	"toggle terminator location", opt[NONE], DIM_NOTYPE,
		GAD_TOG_TERM, FORM_LOCAL
	},

	{	"format", opt[FORMAT], DIM_INT,
		SUB_FORM_LABEL, FORM_FORMAT
	},

	{	"prefix",  opt[NONE], DIM_ALPHA,
		GAD_PREFIX, FORM_LOCAL
	},

	{	"suffix",  opt[NONE], DIM_ALPHA,
		GAD_SUFFIX, FORM_LOCAL
	},

	{	"prefix display", opt[OFF_ON], DIM_TOGGLE,
		GAD_PRE_DISP, FORM_LOCAL
	},

	{	"suffix display", opt[OFF_ON], DIM_TOGGLE,
		GAD_SUF_DISP, FORM_LOCAL
	},

	{	"round off type", opt[DEC_FRAC], DIM_TOGGLE,
		GAD_DECI_FRAC, FORM_LOCAL
	},

	{	"primary decimal round off", opt[DECIMAL], DIM_INT,
		SUB_FORM_LABEL, FORM_DECACC_PRI
	},

	{	"primary fraction round off", opt[FRACTIONAL], DIM_INT,
		SUB_FORM_LABEL, FORM_FRAACC_PRI
	},

	{	"secondary decimal round off", opt[DECIMAL], DIM_INT,
		SUB_FORM_LABEL, FORM_DECACC_SEC
	},

	{	"secondary fraction round off", opt[FRACTIONAL], DIM_INT,
		SUB_FORM_LABEL, FORM_FRAACC_SEC
	},

	{	"angular decimal round off", opt[DECIMAL], DIM_INT,
		SUB_FORM_LABEL, FORM_DECACC_ANG
	},

	{	"angular fraction round off", opt[FRACTIONAL], DIM_INT,
		SUB_FORM_LABEL, FORM_FRAACC_ANG
	},

	{	"angular round off units", opt[ROFF_UNITS], DIM_INT,
		SUB_FORM_LABEL, FORM_ANG_ROFF
	},

	{	"nts underline", opt[OFF_ON], DIM_TOGGLE,
		GAD_NTS_ULINE, FORM_LOCAL
	},

	{	"override",  opt[NONE], DIM_ALPHA,
		GAD_OVERRIDE, FORM_LOCAL
	},

	{	"scale",  opt[NONE], DIM_DOUBLE,
		GAD_SCA_FACT, FORM_DISPLAY,
	},

	{	"character pitch",  opt[NONE], DIM_DOUBLE,
		KEY_CAR_SPAC, NOT_ON_FORM
	},

	{	"line spacing",  opt[NONE], DIM_DOUBLE,
		KEY_LIN_SPAC, NOT_ON_FORM
	},

	{	"detached dim color",  opt[NONE], DIM_ALPHA,
		GAD_DET_COLR, FORM_ENVIRON
	},

	{
		"driving dim color", opt[NONE], DIM_ALPHA,
		GAD_DRVG_COLR, FORM_ENVIRON
	},

	{
		"driven dim color", opt[NONE], DIM_ALPHA,
		GAD_DIM_COLR, FORM_ENVIRON
	},

	{
		"mode", opt[MODE], DIM_INT,
		GAD_DIM_MODE, FORM_ENVIRON
	},

	{
		"reference dimension type", opt[REF_TYPE], DIM_INT,
		KEY_REF_TYPE, NOT_ON_FORM
	},

	{
		"dimension display", opt[DIM_DISP], DIM_INT,
		KEY_DIM_DISP, NOT_ON_FORM
	},

	{
		"maximum view angle", opt[NONE], DIM_DOUBLE,
		KEY_VIEW_ANG, NOT_ON_FORM
	},

	{
		"text clearance gap", opt[NONE], DIM_DOUBLE,
		GAP_TXT_CLEARANCE, NOT_ON_FORM
	},

	{
		"prefix suffix gap", opt[NONE], DIM_DOUBLE,
		GAP_PRE_SUFF, NOT_ON_FORM
	},

	{
		"symbol gap", opt[NONE], DIM_DOUBLE,
		GAP_SYMBOL, NOT_ON_FORM
	},

	{
		"dual mode vertical gap", opt[NONE], DIM_DOUBLE,
		GAP_DUAL_DIM, NOT_ON_FORM
	},

	{
		"horizontal tolerance gap", opt[NONE], DIM_DOUBLE,
		GAP_TOL_HOR, NOT_ON_FORM
	},

	{
		"vertical tolerance gap", opt[NONE], DIM_DOUBLE,
		GAP_TOL_VER, NOT_ON_FORM
	},

	{
		"vertical limits gap", opt[NONE], DIM_DOUBLE,
		GAP_VER_LIMI, NOT_ON_FORM
	},

	{
		"horizontal box gap", opt[NONE], DIM_DOUBLE,
		GAP_BOX_HOR, NOT_ON_FORM
	},

	{
		"vertical box gap", opt[NONE], DIM_DOUBLE,
		GAP_BOX_VER, NOT_ON_FORM
	},

	{
		"super user", opt[OFF_ON], DIM_TOGGLE,
		SUPER_USER, NOT_ON_FORM
	},

	{
		"projection method", opt[PROJ_METHOD], DIM_INT,
		KEY_PROJ_METHOD, NOT_ON_FORM
	},

	{
		"ansi weld details", opt[OFF_ON], DIM_TOGGLE,
		KEY_ANSI_WELD, NOT_ON_FORM
	},

	{
		"weld identification line", opt[OFF_ON], DIM_TOGGLE,
		KEY_DASH_LINE, NOT_ON_FORM
	},
};

int DMkeyin_count = sizeof(DMkeyin_list)/sizeof(struct DMkeyin_desc); 

static struct lab_val tole_map[] =
{
	{	GAD_FORMAT_NONE,	TOLE_MODE_OFF},
	{	GAD_FORMAT_UP_LOW,	TOLE_MODE_UP_LOW},
	{	GAD_FORMAT_MIDDLE,	TOLE_MODE_MIDDLE},
	{	GAD_FORMAT_LIMITS,	TOLE_MODE_LIMITS},
	{	GAD_FORMAT_BOX,		TOLE_MODE_BOX},
	{	GAD_FORMAT_REF,		TOLE_MODE_REF},
};

#define tole_map_size		sizeof(tole_map)/sizeof(struct lab_val)

static struct lab_val ter_map[] =
{
	{	GAD_HOLLOW_ARROW,	TER_TYPE_HOLLOW_ARROW},
	{	GAD_FILLED_ARROW,	TER_TYPE_FILLED_ARROW},
	{	GAD_OPEN_ARROW,		TER_TYPE_OPEN_ARROW},
	{	GAD_SLASH,		TER_TYPE_SLASH},
	{	GAD_BACK_SLASH,		TER_TYPE_BACK_SLASH},
	{	GAD_BLANK,		TER_TYPE_BLANK},
	{	GAD_DOT,		TER_TYPE_DOT},
	{	GAD_CIRCLE,		TER_TYPE_CIRCLE},
};

#define ter_map_size		sizeof(ter_map)/sizeof(struct lab_val)

struct lab_val decacc_map[] =
{
	{	GAD_DEC_ACC10,		DECI_ACC10},
	{	GAD_DEC_ACC1,		DECI_ACC1},
	{	GAD_DEC_ACC_1,		DECI_ACC_1},
	{	GAD_DEC_ACC_2,		DECI_ACC_2},
	{	GAD_DEC_ACC_3,		DECI_ACC_3},
	{	GAD_DEC_ACC_4,		DECI_ACC_4},
	{	GAD_DEC_ACC_5,		DECI_ACC_5},
	{	GAD_DEC_ACC_6,		DECI_ACC_6},
	{	GAD_DEC_ACC_7,		DECI_ACC_7},
};

#define decacc_map_size		sizeof(decacc_map)/sizeof(struct lab_val)

struct lab_val fraacc_map[] =
{
	{	GAD_FRA_ACC_1,		FRAC_ACC_1},
	{	GAD_FRA_ACC_2,		FRAC_ACC_2},
	{	GAD_FRA_ACC_4,		FRAC_ACC_4},
	{	GAD_FRA_ACC_8,		FRAC_ACC_8},
	{	GAD_FRA_ACC_16,		FRAC_ACC_16},
	{	GAD_FRA_ACC_32,		FRAC_ACC_32},
	{	GAD_FRA_ACC_64,		FRAC_ACC_64},
};

#define fraacc_map_size		sizeof(fraacc_map)/sizeof(struct lab_val)

struct DMform_info DMform_list[FORM_COUNT + 1] =
{
		{	/* - FORM_ENVIRON - */

			"DMDimEnv", NULL,
			SR_DSP_NO, -1, -1, -1,
			0, NULL
		},

		{	/* - FORM_LOCAL - */

			"DMDimPar", NULL,
			SR_DSP_NO, -1, -1, -1,
			0, NULL
		},

		{	/* - FORM_DIMTERM - */

			"DMSubTerm", NULL,
			SR_DSP_AUTO, FORM_ENVIRON, 325, 365,
			ter_map_size, ter_map
		},

		{	/* - FORM_FORMAT - */

			"DMSubTole", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 11, 47,
			tole_map_size, tole_map
		},

		{	/* - FORM_DECACC_PRI - */

			"DMSubDeci", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 340, 50,
			decacc_map_size, decacc_map
		},

		{	/* - FORM_DECACC_SEC - */

			"DMSubDeci", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 435, 75,
			decacc_map_size, decacc_map
		},

		{	/* - FORM_DECACC_ANG - */

			"DMSubDeci", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 340, 75,
			decacc_map_size, decacc_map
		},

		{	/* - FORM_FRAACC_PRI - */

			"DMSubFrac", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 340, 50,
			fraacc_map_size, fraacc_map
		},

		{	/* - FORM_FRAACC_SEC - */

			"DMSubFrac", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 435, 75,
			fraacc_map_size, fraacc_map
		},

		{	/* - FORM_FRAACC_ANG - */

			"DMSubFrac", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 340, 75,
			fraacc_map_size, fraacc_map
		},

		{	/* - FORM_DISPLAY - */

			"DMSubDisp", NULL,
			SR_DSP_FORCE, FORM_LOCAL, 680, 50,
			0, NULL
		},

		{	/* - FORM_ANG_ROFF - */

			"DMSubAngl", NULL,
			SR_DSP_AUTO, FORM_LOCAL, 340, 75,
			0, NULL
		},

		{	/* - NOT_ON_FORM - */

			"dummy", NULL,
			SR_DSP_NO, -1, -1, -1,
			0, NULL
		}
};

%endsafe

#ifdef OFFLINE

main ( )
{
	DMkeyin_desc_print(DMkeyin_count, DMkeyin_list);
}

DMkeyin_desc_print ( )
{
	int i,j;

	for (i=0; i<DMkeyin_count; i=i+1)
	{
		printf ("\t%s=\n", DMkeyin_list[i].keyin);
		for (j=0; DMkeyin_list[i].option[j]; j=j+1)
			printf("\t\t%s\n", DMkeyin_list[i].option[j]);
		printf("\n\n\n");
	}

	printf ("\n");
}

#endif

end implementation DMroot;


