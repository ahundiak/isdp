#ifndef EX_D_EXFI
#define EX_D_EXFI 1

/*---------------------------------------------------------------------------*/
/*  On 12/30/92 the file exfi.h was created from fi.h and fidef.h to remove  */
/*  case insensitive conflicts with the file FI.h                            */
/*  All prefixes in this exfi.h were changed from FI to EXFI                 */
/*                                                                           */
/*  All was well in munchkinville until one day the good witch noticed that  */
/*  customers and internal test procedures needed the old file fi.h or else  */
/*  they would have to edit all of their PPL source files to change fi.h to  */
/*  exfi.h - so the kind wizard decided to provide the exact same file under */
/*  both names (fi.h,exfi.h) to make all the munchkins happy.  So, the moral */
/*  of this story is that this file is exactly the same as exfi.h - except   */
/*  that the prefixes to the structs are FI instead of EXFI                  */
/*---------------------------------------------------------------------------*/

#define FI_FORMNAMELEN         32
#define FI_FORMDESCLEN        132
#define FI_DESCNUM              3
#define FI_STRLEN             132
#define FI_FILELEN            256
#define FI_LINE_LEN           132

#define STATUS_FORM             OM_K_MAXINT


	/********** Valid types for FI_data_st **********/

#define FI_STATE	1
#define FI_INT	2
#define FI_DOUBLE	3
#define FI_ALPHA	4
#define FI_SUBFORM	5
#define FI_SELECTION	6
#define FI_CLEAR	7
#define FI_POINT	8


	/********** Select_flag values for FI_data_st **********/

#define FI_EDIT_NOSELECT	0	/* must supply new string */
#define FI_EDIT_SELECT	1	/* must supply new string */
#define FI_NOTSELECTED	2	/* no string required */
#define FI_SELECTED		3	/* no string required */


struct FI_subform_st
{
    int label;
    int x;
    int y;
    OM_S_OBJID objid;
};

struct FI_mouse_st
{
    int x;
    int y;
    short numb;		/* button number */
    short click;	/* # of button clicks */
    short down;		/* 1 = down, 0 = up */
};

struct FI_data_st
{
    int label;
    int type;
    int index;        /* line number - in multi-line gadgets */
    int max_index;    /* max number of lines - in multi-line gadgets */
    int select_flag;  /* See #defines above, i.e. FI_SELECTED
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
	char alpha [FI_STRLEN];
	struct FI_subform_st subform;
	struct FI_mouse_st btn;
    } value;
};

#endif
