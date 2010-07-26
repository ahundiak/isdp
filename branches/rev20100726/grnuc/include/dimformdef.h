#ifndef dimformdef_include

#define dimformdef_include

#define FORM_ENVIRON		0
#define FORM_LOCAL		1
#define FORM_DIMTERM		2
#define FORM_FORMAT		3
#define FORM_DECACC_PRI		4
#define FORM_DECACC_SEC		5
#define FORM_DECACC_ANG		6
#define FORM_FRAACC_PRI		7
#define FORM_FRAACC_SEC		8
#define FORM_FRAACC_ANG		9
#define FORM_DISPLAY		10
#define FORM_ANG_ROFF		11
#define NOT_ON_FORM		12

#define FORM_COUNT		12

#define MAX_LABEL_COUNT		400

#define STATE_NONE		0
#define STATE_GLOBAL		1
#define STATE_DIMENSION		2
#define STATE_REPLAY		3

#define FORM_INPUT		0
#define KEYBOARD_INPUT		1

#define DIM_NOTYPE		0
#define DIM_INT			1
#define DIM_DOUBLE		2
#define DIM_TOGGLE		3
#define DIM_ALPHA		4
#define DIM_ROLL		5

#define SR_DSP_NO		0
#define	SR_DSP_FORCE		1
#define SR_DSP_AUTO		2

#define OFF			0
#define ON			1

#define SUB_FORM_LABEL		-1

#define MAX_OPTIONS		10

#define PLACE_STACK		0
#define EDIT_STACK		1

#define MAX_PLACE_SIZE		100
#define MAX_EDIT_SIZE		100
#define EDIT_STACK_SIZE		100

#define error_chk(flag) if (!(flag & 1)) return(flag)

#define get_value_int(p_gadget) p_gadget->val.ivalue
#define get_value_double(p_gadget) p_gadget->val.dvalue
#define get_value_alpha(s, p_gadget) strcpy(s, p_gadget->val.alpha)
#define get_value_toggle(p_gadget) p_gadget->val.ivalue

#define val_int(p_gadget) p_gadget->val.ivalue
#define val_double(p_gadget) p_gadget->val.dvalue
#define val_alpha(p_gadget) p_gadget->val.alpha

#define sval_int(gadget) gadget.val.ivalue
#define sval_double(gadget) gadget.val.dvalue
#define sval_alpha(gadget) gadget.val.alpha

#define store_int(flag, ivalue, p_gadget) \
	if (flag) \
		ivalue = val_int(p_gadget); \
	else	val_int(p_gadget) = ivalue

#define store_color(flag, ivalue, p_gadget) \
	if (flag) \
		ivalue = atoi(val_alpha(p_gadget)); \
	else	strcpy(val_alpha(p_gadget),(char)ivalue)

#define store_double(flag, dvalue, p_gadget) \
	if (flag) \
		dvalue = val_double(p_gadget); \
	else	val_double(p_gadget) = dvalue

#define store_str(flag, string, p_gadget) \
	if (flag) \
		strcpy(string, val_alpha(p_gadget)); \
	else	strcpy(val_alpha(p_gadget), string)

#define store_str9(flag, string, p_gadget) \
	if (flag) \
		DMstrncpy(string, val_alpha(p_gadget), 9); \
	else	strcpy(val_alpha(p_gadget), string)

#define store_str8(flag, string, p_gadget) \
	if (flag) \
		DMstrncpy(string, val_alpha(p_gadget), 8); \
	else	strcpy(val_alpha(p_gadget), string)

#ifdef FI_DEBUG

#define trace_in(name) char *fname; fname = name; write("BEGIN: ", fname, "\n")
#define RETURN(x) { write("END: ", fname, "\n"); return(x); }
#define trace_out(name) write("END: ", name, "\n")
#define debug(action) printf("\t"); action;  printf("\n");

#else

#define trace_in(name) /* empty */
#define RETURN(x) return(x)
#define trace_out(name) /* empty */
#define debug(action) /* empty */

#endif

#omdef fi$status(sts = sts, comment, form_no=NULL, label=NULL)

	if ( (sts) && ( sts != FI_QUIET_MODE_ON) ) 
	{
		printf("\nError in file %s at line %d\n", __FILE__, __LINE__);
#if om$specified(form_no)
		printf("form_no = %d\n", form_no);
#endif
#if om$specified(label)
		printf("label = %d\n", label);
#endif
		printf("sts = %d, %s\n", sts, comment);
		return(FALSE);
	}

#endomdef

#endif

