#ifndef acdyn_col_include
#define acdyn_col_include

/* range of attribute properties */
#define	AC_ATTRIB_MASK_TYPE	0x000f
#define AC_ATTRIB_MASK_PROP	0x0ff0
#define AC_ATTRIB_MASK_USER	0xf000

/* description of internal properties */
#define AC_ATTRIB_LOCK		0x0100
#define AC_ATTRIB_UPDATE	0x0200
#define AC_ATTRIB_EVAL		0x0400
#define AC_ATTRIB_PRIVATE	0x0800
#define AC_ATTRIB_INVISIBLE	0x0010

/* test to check attribute properties */
#define ACTEST_TRUE		"="
#define ACTEST_EQUAL		"=="
#define ACTEST_DIFF		"!="
#define ACTEST_ONE_OR_MORE	"&"
#define ACTEST_ALL_PROP		"&==M"
#define	ACTEST_NO_PROP		"&==0"

struct	ACcol_info
{

	IGRchar	pl_fct_name[ATTR_TXT];
	IGRchar	cp_fct_name[ATTR_TXT];
};

#endif

