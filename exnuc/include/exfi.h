#ifndef EX_D_EXFI
#define EX_D_EXFI 1

/*---------------------------------------------------------------------*/
/*  On 12/30/92 this file was created from fi.h and fidef.h to remove  */
/*  case insensitive conflicts with the file FI.h                      */
/*  All prefixes in this file were changed from FI to EXFI             */
/*---------------------------------------------------------------------*/

#define EXFI_FORMNAMELEN         32
#define EXFI_FORMDESCLEN        132
#define EXFI_DESCNUM              3
#define EXFI_STRLEN             132
#define EXFI_FILELEN            256
#define EXFI_LINE_LEN           132

#define STATUS_FORM             OM_K_MAXINT


	/********** Valid types for EXFI_data_st **********/

#define EXFI_STATE	1
#define EXFI_INT	2
#define EXFI_DOUBLE	3
#define EXFI_ALPHA	4
#define EXFI_SUBFORM	5
#define EXFI_SELECTION	6
#define EXFI_CLEAR	7
#define EXFI_POINT	8


	/********** Select_flag values for EXFI_data_st **********/

#define EXFI_EDIT_NOSELECT	0	/* must supply new string */
#define EXFI_EDIT_SELECT	1	/* must supply new string */
#define EXFI_NOTSELECTED	2	/* no string required */
#define EXFI_SELECTED		3	/* no string required */


struct EXFI_subform_st
{
    int label;
    int x;
    int y;
    OM_S_OBJID objid;
};

struct EXFI_mouse_st
{
    int x;
    int y;
    short numb;		/* button number */
    short click;	/* # of button clicks */
    short down;		/* 1 = down, 0 = up */
};

struct EXFI_data_st
{
    int label;
    int type;
    int index;        /* line number - in multi-line gadgets */
    int max_index;    /* max number of lines - in multi-line gadgets */
    int select_flag;  /* See #defines above, i.e. EXFI_SELECTED
			 in get_by_value - return if selected, not selected
			 doesn't matter.  In put_by_value - data is
			 selected or not selected -  used with checklist
			 and field with popup list */
    int sts;	     /* sts iff applicable e.g invalid range */
    union
    {
	OM_S_OBJID objid;
	char state;	/* TRUE or FALSE */
	int ivalue;
	double dvalue;
	char alpha [EXFI_STRLEN];
	struct EXFI_subform_st subform;
	struct EXFI_mouse_st btn;
    } value;
};

#endif
