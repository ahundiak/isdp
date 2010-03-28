
#ifndef dimform_include

#define dimform_include

#ifndef EX_D_EXFI
#include "exfi.h"       /* pick up EXFI_STRLEN */
#endif

struct DMkeyin_desc
{
	char	*keyin;
	char	**option;
	char	type;
	int	label;
	int	form_no;
};

struct DM_data_st
{
	short	label;
	short	form_no;
	char	origin;
	char	type;
	char	stackable;
	union
	{
		char	alpha[EXFI_STRLEN];
		int	ivalue;
		double	dvalue;
	} val;
};

struct DMgadget_stack
{
	short  count;
	struct DM_data_st gadget[EDIT_STACK_SIZE];
};

struct DMkeyboard
{
	char  response[80];
	char  status[80];
	char  previous_value[80];
};

struct lab_val
{
	int label;
	int ivalue;
};

struct DMform_info
{
	char  *form_name;	/* form name			*/
	Form  form_id;		/* pointer to form		*/
	int   sr_display;	/* SR_DSP_FORCE - force save res
				   SR_DSP_AUTO  - dsp save res
				   SR_DSP_NO    - not save res	*/
	int   parent;		/* form_no: -1 if none		*/
	int   x_orig;
	int   y_orig;		/* origin of the form		*/

	int   map_size;
	struct lab_val *map;	/* mapping from internal value to
				   label on the form */
};

#endif


	
