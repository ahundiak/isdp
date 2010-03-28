#ifndef dim_glob_include

#define dim_glob_include

#define CONV_TO_DIM_UNITS	0
#define CONV_TO_FILE_UNITS	1

struct DMsymbol_info
{
		IGRshort	font_num;
		IGRchar		font_char;
		IGRdouble	sym_size;
};

struct DMterm_info
{
		IGRshort	font_num;
		IGRchar		font_char;
		IGRchar		center_just;
};

struct DMglobal
{
	struct DMsymbol_info ansi_sym_info[MAX_SYM_TYPE];
	struct DMsymbol_info misc_sym_info[MAX_SYM_TYPE];
	struct DMsymbol_info *symbol_info[MAX_STD_TYPE];
	struct DMterm_info term_info[MAX_TER_TYPE];
	double conv_factor[MAX_MEA_UNIT];
};

#endif

