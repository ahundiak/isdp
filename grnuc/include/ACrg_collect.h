#ifndef acrg_collect_include
#define acrg_collect_include

#define ATTR_NAME	80
#define ATTR_TXT	ATTR_NAME

#define	gen_rg_collect	0x00010800

/* description of the type mask for an attribut */

#define	AC_ATTRIB_CONNECT	0x4/* bit 2 type of attribut is connect	*/

/* description of ACrg_collect properties */

#define	AC_BOX_LOCKED	0x1	/* box can not be modified	*/
#define	AC_BOX_CACHE	0x2	/* box is use for a cache info	*/

/* structure who describe an attribut value and type */

struct	att_value
{

	IGRshort	type;
	union 
	{

		IGRchar		att_txt[ATTR_NAME];
		IGRdouble	att_exp;
	} value;
};


struct	ACrg_coll
{

	IGRchar			name[ATTR_TXT];
	struct	att_value	desc;
};

#endif

