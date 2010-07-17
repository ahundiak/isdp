
#define PAT_TITLE		25
#define PAT_SUMMARY		26
#define PAT_NODE		1
#define PAT_ELEMENT		2
#define PAT_MATERIAL		3
#define PAT_PROPERTY		4
#define PAT_COORD		5
#define PAT_DISTR_LOADS		6
#define PAT_NODE_FORCES		7
#define PAT_NODE_DISP		8
#define PAT_NODE_TEMP		10
#define PAT_ELEM_TEMP		11
#define PAT_NODE_HSRC		15
#define PAT_ELEM_HSRC		16
#define PAT_CONV_COEFF		17
#define PAT_RADI_EMIS		18
#define PAT_NDEL_SET		21
#define PAT_CONT_BODY		81
#define PAT_MAT_ORNT		82
#define PAT_ANL_OPTS		83
#define PAT_LAM_PROP		86
#define PAT_TABLE		88
#define PAT_DYN_LOAD		89
#define PAT_INERT_LOAD		90
#define PAT_LOAD_COMB		91
#define PAT_NODE_MASS		92
#define PAT_BCC_NAMES		95
#define PAT_INJ_PT		96
#define PAT_UNITS		97
#define PAT_FILE_END		99

#define PAT_ID		2
#define PAT_IV		10
#define PAT_KC		18
#define PAT_N1		26
#define PAT_N2		34
#define PAT_N3		42
#define PAT_N4		50
#define PAT_N5		58

#define TRANS_UID       1000
#define USE_START       1001
#define ADD_INCR        1002

extern	long	APlongField();
extern	double	APdoubleField();
extern	void	APstrField();

typedef struct UID_MAP {
	long	neu_uid;
	long	objid;
} UID_MAP;

typedef struct PROP_UID_MAP {
	long	neu_uid;
	long	objid;
	long	mat_uid;
} PROP_UID_MAP;

typedef struct BCCN_UID_MAP {
	long	neu_uid;
	char	name[18];
} BCCN_UID_MAP;
