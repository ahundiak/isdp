class implementation DMroot;

#define   AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#ifndef SUNOS
#include <ctype.h>
#endif
#include "stdio.h"
#include "FI.h"
#include "FEI.h"
#include "exfi.h"
#include "CIforms.h"
#include "dimformdef.h"
#include "dimform.h"
#include "msmacros.h"
#include "msdef.h"
#include "DMmsg.h"

extern struct DMkeyin_desc DMkeyin_list[];
extern int    DMkeyin_count;
extern struct DMform_info DMform_list[];

extern double atof();
extern int    atoi();

from COdim import notify_form;

int DMstrncpy (s1,s2,n)
/*(
	 char  *s1,
	 char  *s2,
	 int  n
	)
*/
char *s1, *s2;
int n;
/*.DMstrncpy*/
{
	strncpy(s1,s2,n);
	s1[n-1]=0;
	return(TRUE);
}

int DMupper_to_lower (s)
/*(
	 char  *s
	)
*/
char *s;
/*.DMupper_to_lower*/
{
	while (*s)
	{
		*s = tolower(*s);
		s++;
	}

	return(TRUE);
}

int DMstrip (string,strip)
/*(
	 char  *string,
	 char  *strip
	)
*/
char *string;
char *strip;
/*.DMstrip*/
{
	int i, j;

	/* This routine strips the intial spaces and
	   copies the first word (including non-space delimiters)
	   into the 'strip'ped string - Used mainly for stripping
	   filenames keyed in by users.
	*/

	i = j = 0;
	while (string[i] && isspace(string[i])) i++;

	while (string[i] && !isspace(string[i]))
	{
		strip[j] = string[i];
		i++;
		j++;
	}

	strip[j] = '\0';

	/*"string=%s, strip=%s\n", string, strip*/

	return(TRUE);
}

int DMcar_pos (string,character)
/*(
	 char  *string,
	 char  character
	)
*/
char *string;
char character;
/*.DMcar_pos*/
{
	int i=0;

	while (string[i] &&  string[i] != character) i++;
	return (i);
}

int DMstrequ (sentence1,sentence0)
/*(
	 char  *sentence1,
	 char  *sentence0
	)
*/
char *sentence1;
char *sentence0;
/*.DMstrequ*/
{
	char string1[32];
	char string0[32];
	int  i, j, k;

	i=0;

	/* compare begining of words */ 

	DMstrncpy(string1, sentence1, 32);
	DMstrncpy (string0, sentence0, 32);
  
	while (string1[0] && string0[0])
	{
		j = DMcar_pos(string1, ' ');
		k = DMcar_pos(string0, ' ');

		if (j <= k)
			i = j;
		else	return (0);

		if (strncmp (string1, string0, i))
			return (0);

		if (string1[j] == ' ')
			strcpy (string1, &string1[j+1]);
		else	string1[0] = '\0';

		if (string0[k] == ' ')
			strcpy (string0, &string0[k+1]);
		else	string0[0] = '\0';
	}

	return(string1[0]?0:i);
}
 
int DMstrcat (s1,index,s2)
/*(
	 char  *s1,
	 int  index,
	 char  *s2
	)
*/
char *s1;
int  index;
char *s2;
/*.DMstrcat*/
{
	int i, len;

	len = strlen(s1);
	if (len < index)
	{
		for (i= len; i<index; i++)
			s1[i]= ' ';
		s1[index]= 0;
	}

	strcat (s1, s2);
	return(TRUE);
}

int DMkeyboard_to_internal (p_dm_keyboard,p_dm_gadget)
/*(
	 struct DMkeyboard  *p_dm_keyboard,
	 struct DM_data_st  *p_dm_gadget
	)
*/
struct DMkeyboard    *p_dm_keyboard;
struct DM_data_st    *p_dm_gadget;
/*.DMkeyboard_to_internal*/
{
	int    index, count;
	int    form_no, label, type;
	char   name[32];
	char   alpha[32];
	char   option[32];
	int    i, j, k;
	int    match_len, prev_match_len;
	int    match_ambigous, index_match;
	double x = 0.0;
	char temp_buff[132];

	/* find name and alpha part */

	k = DMcar_pos(p_dm_keyboard->response, '=');
	if (k > 31)
	{
		ex$message( msgnumb = DM_I_KeyinLong,
                buff    = p_dm_keyboard->status );

		return(FALSE);
	}

	DMstrncpy(name, p_dm_keyboard->response, k+1);
	DMupper_to_lower(name);
	DMstrncpy(alpha, &p_dm_keyboard->response[k+1], 32);

	/*"name=%s, alpha=%s\n", name, alpha*/

	/* analyse parameter name */ 

	for (index=0; index<DMkeyin_count; index++)
	{
		if (DMstrequ(name, DMkeyin_list[index].keyin))
			break;
	}

	if (index == DMkeyin_count)
	{
		ex$message( msgnumb = DM_I_ParamNmNotFound,
                buff    = p_dm_keyboard->status );
		return(FALSE);
	}

	form_no = p_dm_gadget->form_no = DMkeyin_list[index].form_no;
	label   = p_dm_gadget->label   = DMkeyin_list[index].label;
	type    = p_dm_gadget->type    = DMkeyin_list[index].type;

	/*"form_no=%d, label=%d, type = %d, index = %d\n", form_no, label, type, index*/

	if ((count = DMget_option_count(form_no, label)) > 0)
	{
		DMupper_to_lower (alpha);
		prev_match_len = match_ambigous = 0;
		index_match = -1;

		for (j=0; j<count; j++)
		{
			strcpy(option, DMkeyin_list[index].option[j]);
			DMupper_to_lower(option);
			if (match_len = DMstrequ(alpha, option))
			{
				if (match_len == strlen(option))
				{
					match_ambigous = 0;
					index_match = j;
					break;
				}

				if (prev_match_len < match_len)
				{
					prev_match_len = match_len;
					index_match = j;
				}
				else if (prev_match_len == match_len)
					match_ambigous = 1;
			}
		}

		if (index_match == -1)
		{
			strcpy(p_dm_keyboard->status, DMkeyin_list[index].keyin);
		        ex$message( msgnumb = DM_I_OptNotFound,
             	        buff    = temp_buff );
			strcat(p_dm_keyboard->status, temp_buff);
			return(FALSE);
		}

		if (match_ambigous)
		{
			strcpy(p_dm_keyboard->status, DMkeyin_list[index].keyin);
		        ex$message( msgnumb = DM_I_AmbOpt,
             	        buff    = temp_buff );
			strcat(p_dm_keyboard->status ,temp_buff);
			return(FALSE);
		}

		p_dm_gadget->val.ivalue = index_match;

		return(TRUE);
	}

	switch(type)
	{
		case DIM_ALPHA:

		DMstrncpy(p_dm_gadget->val.alpha, alpha, EXFI_STRLEN);
		break;

		case DIM_TOGGLE:
		case DIM_ROLL:
		case DIM_INT:

		if (!sscanf (alpha, "%d", &i))
		{
			strcpy(p_dm_keyboard->status, DMkeyin_list[index].keyin);
		        ex$message( msgnumb = DM_I_IllInt,
             	        buff    = p_dm_keyboard->status );
              
			return(FALSE);
		}

		p_dm_gadget->val.ivalue = i;
		break;

		case DIM_DOUBLE:

		if (!sscanf (alpha, "%lf", &x))
		{
			strcpy(p_dm_keyboard->status, DMkeyin_list[index].keyin);
		        ex$message( msgnumb = DM_I_IllDouble,
             	        buff    = p_dm_keyboard->status );
			return(FALSE);
		}

		p_dm_gadget->val.dvalue = x;
		break;

		case DIM_NOTYPE: break;

		default:

		printf("DMkeyboard_to_internal: Error in internal type %d\n",
				type);
		return(FALSE);
	}

	return (TRUE);
}

IGRint DMinternal_to_keyboard (p_dm_gadget,p_dm_keyboard,tabulation_flag)
/*(
	 struct DM_data_st  *p_dm_gadget,
	 struct DMkeyboard  *p_dm_keyboard,
	 int  tabulation_flag
	)
*/
struct DM_data_st *p_dm_gadget;
struct DMkeyboard *p_dm_keyboard;
int    tabulation_flag;
/*.DMinternal_to_keyboard*/
{
	int  index;
	int  form_no, label, i;
	char alpha[32];

	form_no = p_dm_gadget->form_no;
	label = p_dm_gadget->label;

	index = DMget_keyin_index(form_no, label);

	if (index == -1)
	{
		sprintf(p_dm_keyboard->response, "%d=???", label);
		return(FALSE);
	}
	else
	{
		strcpy(p_dm_keyboard->response, DMkeyin_list[index].keyin);
		if (p_dm_gadget->type == DIM_NOTYPE) return(TRUE);

		if (tabulation_flag)
			DMstrcat(p_dm_keyboard->response, 28, "= ");
		else	strcat(p_dm_keyboard->response, "=" );
  
		switch (p_dm_gadget->type)
		{
			case DIM_TOGGLE:
			case DIM_ROLL:

			i = p_dm_gadget->val.ivalue;
			strcat( p_dm_keyboard->response,
				DMkeyin_list[index].option[i]);
			break;

			case DIM_ALPHA:

			DMstrncpy(alpha, p_dm_gadget->val.alpha, 32);
			strcat(p_dm_keyboard->response, alpha);
			break;

			case DIM_INT:

			i = p_dm_gadget->val.ivalue;

			if (DMkeyin_list[index].option[0])
				strcpy(alpha, DMkeyin_list[index].option[i]);
			else
			{
				sprintf(alpha, "%d", i);
			}

			strcat(p_dm_keyboard->response, alpha);
			break;

			case DIM_DOUBLE:

			sprintf(alpha, "%lf", p_dm_gadget->val.dvalue);
			strcat(p_dm_keyboard->response, alpha);
			break;

			default:

			printf("internal_to_keyboard: Illegal type %d\n",
					p_dm_gadget->type);
			return(FALSE);
		}
	}

	return(TRUE);
}

int DMform_to_internal (form_st,p_dm_gadget)
/*
	 struct CIform_st  *form_st,
	 struct DM_data_st  *p_dm_gadget
	)
*/
struct CIform_st *form_st;
struct DM_data_st    *p_dm_gadget;
/*.DMform_to_internal*/
{
	int sts;
	int index;
	int form_no;
	int label;
	int g_type, f_type, attr_mask;
	Form form_id;

	form_no = p_dm_gadget->form_no = form_st->form_label;
	label = p_dm_gadget->label = form_st->gadget_label;
	form_id = DMform_list[form_no].form_id;

	sts = FIg_get_type(form_id, label, &g_type);
	fi$status(comment = "FIg_get_type");

	switch (g_type)
	{
		case FI_SLIDER:
		case FI_DIAL:
		f_type = FI_DOUBLE; break;

		case FI_TOGGLE:
		case FI_CHECKLIST:
		case FI_BUTTON:
		case FI_SYM:
		case FI_SCROLL:
		f_type = FI_INT; break;

		case FI_FIELD:
		sts = FIfld_get_type(form_id, label, 0, &f_type);
		fi$status(comment = "FIfld_get_type");

		sts = FIfld_get_attr(form_id, label, 0, &attr_mask);
		fi$status(comment = "FIfld_get_type");

		if (attr_mask & FI_ROLL_THRU)
		{
			p_dm_gadget->type = DIM_ROLL;
			p_dm_gadget->val.ivalue = form_st->value;
			p_dm_gadget->stackable = TRUE;
			return(TRUE);
		}

		if (f_type == FI_INT || f_type == FI_DOUBLE)
			FIg_get_value(form_id, label, &form_st->value);
		break;

		default:
		printf("DMform_to_internal: Unknown gad type %d\n", g_type);
		return(FALSE);
	}

	index = DMget_keyin_index(form_no, label);
	if (index == -1)
	{
		switch (f_type)
		{
			case FI_INT:

			p_dm_gadget->type = DIM_INT;
			p_dm_gadget->val.ivalue = form_st->value;
			break;

			case FI_DOUBLE:

			p_dm_gadget->type = DIM_DOUBLE;
			p_dm_gadget->val.dvalue = form_st->value;
			break;

			case FI_ALPHA:

			p_dm_gadget->type = DIM_ALPHA;
			sts = FIg_get_text(
				form_id,
				label,
				p_dm_gadget->val.alpha);
			fi$status(comment = "FIf_get_text");
			break;

			default:

			printf("DMform_to_internal: Invalid type %d\n",
					f_type);
			return(FALSE);
		}

		return(TRUE);
	}

	p_dm_gadget->stackable = TRUE;
	p_dm_gadget->type = DMkeyin_list[index].type;
	DMconvert_form_value(g_type, f_type, form_st, p_dm_gadget);

	return(TRUE);
}

int DMconvert_form_value (g_type,f_type,form_st,p_dm_gadget)
/*
	 int  g_type,
	 int  f_type,
	 struct CIform_st  *form_st,
	 struct DM_data_st  *p_dm_gadget
	)
*/
int g_type;
int f_type;
struct CIform_st *form_st;
struct DM_data_st *p_dm_gadget;
/*.DMconvert_form_value*/
{
	int sts;
	char val_string[EXFI_STRLEN];
	int form_no, label;
	Form form_id;
	int r_pos;

	form_no = form_st->form_label;
	label = form_st->gadget_label;
	form_id = DMform_list[form_no].form_id;

	if (g_type == FI_FIELD && p_dm_gadget->type == DIM_ROLL)
		f_type = FI_INT;

	switch (f_type)
	{
		case FI_INT:	/*|FI_INT*/

		sprintf(val_string, "%d", (int)form_st->value);
		break;

		case FI_DOUBLE: /*|FI_DOUBLE*/

		sprintf(val_string, "%lf", (double)form_st->value);
		break;

		case FI_ALPHA:  /*|FI_ALPHA*/

		sts = FIg_get_text(
				form_id,
				label,
				val_string);
		fi$status(comment = "FIg_get_text");
		break;

		default:

		printf("DMconvert_form_value: Unknown form type %d\n", f_type);
		return(FALSE);
	}

	/*"val_string = %s\n", val_string*/

	switch (p_dm_gadget->type)
	{
		case DIM_NOTYPE:	/*|DIM_NOTYPE*/

		break;

		case DIM_ROLL:		/*|DIM_ROLL*/

		sts = FIfld_get_active_row(
				form_id,
				label,
				&p_dm_gadget->val.ivalue,
				&r_pos);
		fi$status(comment = "FIfld_get_active_row");
		break;

		case DIM_TOGGLE:	/*|DIM_TOGGLE | DIM_INT*/
		case DIM_INT:

		p_dm_gadget->val.ivalue = atoi(val_string);
		/*"ivalue = %d\n", p_dm_gadget->val.ivalue*/
		break;

		case DIM_DOUBLE:	/*|DIM_DOUBLE*/

		DMatof(val_string, &p_dm_gadget->val.dvalue);
		/*"dvalue = %lf\n", p_dm_gadget->val.dvalue*/
		break;

		case DIM_ALPHA:		/*|DIM_ALPHA*/

		DMstrncpy(p_dm_gadget->val.alpha, val_string, EXFI_STRLEN);
		/*"alpha = %s\n", p_dm_gadget->val.alpha*/
		break;

		default:

		printf("DMconvert_form_value: Unknow internal type %d\n",
				p_dm_gadget->type);
		return(FALSE);
	}

	return(TRUE);
}

int DMput_by_value (p_dm_gadget)
/*(
	 struct DM_data_st  *p_dm_gadget
	)
*/
struct DM_data_st    *p_dm_gadget;
/*.DMput_by_value*/
{
	int label;
	int form_no;
	Form form_id;
	int sts;

	form_no = p_dm_gadget->form_no;
	label = p_dm_gadget->label;
	form_id = DMform_list[form_no].form_id;

	switch(p_dm_gadget->type)
	{
		case DIM_NOTYPE: return(TRUE);

		case DIM_TOGGLE:
		case DIM_INT:
		sts = FIg_set_value(
				form_id,
				label,
				(double)p_dm_gadget->val.ivalue);
		fi$status(comment = "FIg_set_value");
		break;

		case DIM_DOUBLE:
		sts = FIg_set_value(
				form_id,
				label,
				(double)p_dm_gadget->val.dvalue);
		fi$status(comment = "FIg_set_value");
		break;

		case DIM_ROLL:

		sts = FIfld_set_active_row(
				form_id,
				label,
				p_dm_gadget->val.ivalue,
				0);
		fi$status(comment = "FIfld_set_value");
		break;

		case DIM_ALPHA:

		sts = FIg_set_text(
				form_id,
				label,
				p_dm_gadget->val.alpha);
		fi$status(comment = "FIg_set_text");
		break;

		default:

		printf("DMinternal_to_form: Unknown internal type %d\n",
				p_dm_gadget->type);
		break;
	}

	return(TRUE);
}
  
int DMget_keyin_index (form_no,
                       label)
/*(
	 int  form_no,
	 int  label
	)
*/
int form_no, label;
/*.DMget_keyin_index*/
{
	int index;
	int klabel, kform_no;

	/*"keyin_count=%d\n", DMkeyin_count*/

	/*"form_no=%d, label=%d\n", form_no, label*/

	for (index=0; index<DMkeyin_count; index++)
	{
		kform_no = DMkeyin_list[index].form_no;
		klabel = DMkeyin_list[index].label;

		if ((label == klabel) && (form_no == kform_no))
		{
			/*"index=%d\n", index*/
			return(index);
		}
	}

	/*|no entry*/
	return(-1);
}

int DMget_option_count (form_no,label)
/*(
	 int  form_no,
	 int  label
	)
*/
int form_no, label;
/*.DMget_option_count*/
{
	int index, count;

	index = DMget_keyin_index(form_no, label);
	if (index < 0)
		return(index);

	for (count=0; DMkeyin_list[index].option[count]; count++) ;

	/*"count=%d\n", count*/

	return(count);
}

char *DMget_option (form_no,label,opt_index)
/*(
	 int  form_no,
	 int  label,
	 int  opt_index
	)
*/
int form_no;
int label;
int opt_index;
{
	int keyin_index;
	char *option;

	if (opt_index < 0 || opt_index >= MAX_OPTIONS)
	{
		printf("DMget_option: Error in opt_index=%d\n", opt_index);
		return(NULL);
	}

	keyin_index = DMget_keyin_index(form_no, label);
	if (keyin_index == -1)
	{
		printf("DMget_option: No such keyin %d, %d\n", form_no, label);
		return(NULL);
	}

	option = DMkeyin_list[keyin_index].option[opt_index];
	if (option == NULL)
		printf("DMget_option: No such option %d\n", opt_index);

	return(option);
}

int DMlist_keyins (filename)
/*(
	 char  *filename
	)
*/
char *filename;
/*.DMlist_keyins*/
{
	IGRint count, index;
	char strip[128];
	FILE *fp;
	struct DMkeyin_desc *dm;

	DMstrip(filename, strip);
	if (strip[0])
	{
		fp = fopen(strip, "w");
		if (fp == NULL)
		{
			/*"Cannot open <%s>\n", strip*/
			return(FALSE);
		}
	}
	else	fp = stdout;

	fprintf(fp, "Dimension Parameters\n");

	for (index=0; index<DMkeyin_count; index++)
	{
		dm = &DMkeyin_list[index];

		fprintf(fp, "\n%s", dm->keyin);

		for (count=0; dm->option[count]; count++)
		{
			if (count)
				fprintf(fp, "/");
			else	fprintf(fp, "=");
			fprintf(fp, "%s", dm->option[count]);
		}

		if (count) continue;

		switch (dm->type)
		{
			case DIM_NOTYPE:
			break;

			case DIM_INT:
			case DIM_TOGGLE:
			case DIM_ROLL:

			fprintf(fp, "=<INTEGER>");
			break;

			case DIM_DOUBLE:

			fprintf(fp, "=<DOUBLE>");
			break;

			case DIM_ALPHA:

			fprintf(fp, "=<STRING>");
			break;

			default:

			fprintf(stderr, "Error in valtype %d\n", dm->type);
			break;
		}
	}

	if (fp != stdout)
		fclose(fp);

	return(TRUE);
}

int DMactive_values (filename,par_env,par_loc,par_misc,par_senv, par_glob, par_weld)
/*(
	 char  *filename,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc,
	 struct DMsenv_param  *par_senv,
	struct DMglobal_param *par_glob,
	struct DMweld_param *par_weld
	)
*/
char   *filename;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
struct DMsenv_param *par_senv;
struct DMglobal_param *par_glob;
struct DMweld_param *par_weld;
/*.DMactive_values*/
{
	IGRint status, count, index;
	char string[128];
	struct DM_data_st dm_gadget;
	struct DMkeyin_desc *dm;
	FILE *fp;
	IGRdouble conv_factor;
	IGRint ivalue;

	struct DMenv_param env;
	struct DMloc_param loc;
	struct DMmisc_param misc;
	struct DMsenv_param senv;
	struct DMglobal_param glob;
	struct DMweld_param weld;

	if (par_env)
		env = *par_env;
	else	
                dm$get_dim_param(type = DM_ENV_PARAM, /*(char *)*/ p_data = &env);

	DMtxt_conv_fact(CONV_TO_DIM_UNITS, &conv_factor, env.pri_unit);
	env.txt_heig *= conv_factor;
	env.txt_widt *= conv_factor;

	if (par_loc)
		loc = *par_loc;
	else	dm$get_dim_param(type = DM_LOC_PARAM, /*(char *)*/ p_data = &loc);

	if (par_misc)
		misc = *par_misc;
	else	dm$get_dim_param(type = DM_MISC_PARAM, /*(char *)*/p_data = &misc);

	if (par_senv)
		senv = *par_senv;
	else	dm$get_dim_param(type = DM_SENV_PARAM,/*( char *)*/p_data = &senv);


	if (par_glob)
		glob = *par_glob;
	else	dm$get_dim_param(type = DM_GLOB_PARAM, p_data = &glob);


	if (par_weld)
		weld = *par_weld;
	else	dm$get_dim_param(type = DM_WELD_PARAM, p_data = &weld);

	DMstrip(filename, string);
	if (string[0])
	{
		fp = fopen(string, "w");
		if (fp == NULL)
		{
			/*"Cannot open <%s>\n", string*/
			return(FALSE);
		}
	}
	else	fp = stdout;

	fprintf(fp, "#Dimension Parameters\n");

	for (index=0; index<DMkeyin_count-1; index++)
	{
		dm = &DMkeyin_list[index];
		dm_gadget.label = dm->label;
		dm_gadget.form_no = dm->form_no;

		/* - Filter out non-parametric keyins - */

		status =
		DMprocess_keyin(
			FALSE,
			NULL,
			&dm_gadget,
			&env,
			&loc,
			&misc,
			&senv,
			&glob,
			&weld);
		if (!status) continue;

		for (count=0; dm->option[count]; count++);

		if (count)
		{
			ivalue = sval_int(dm_gadget);
			if (ivalue < 0 || ivalue >= count)
			{
				/*^
				printf("Error ival=%d, optcnt=%d at index=%d\n",
					ivalue, count, index);
				*/
				ivalue = 0;
			}
			strcpy(string, dm->option[ivalue]);
		}
		else if (dm->type == DIM_NOTYPE)
			continue;
		else switch(dm->type)
		{
			case DIM_INT:
			case DIM_TOGGLE:
			case DIM_ROLL:

			sprintf(string, "%d", sval_int(dm_gadget));
			break;

			case DIM_DOUBLE:

			sprintf(string, "%lf", sval_double(dm_gadget));
			break;

			case DIM_ALPHA:

			strcpy(string, sval_alpha(dm_gadget));
			break;

			default:

			fprintf(stderr, "Error in valtype %d\n", dm->type);
			break;
		}

		fprintf(fp, "%s=%s\n", dm->keyin, string);
	}

	if (fp != stdout)
		fclose(fp);

	return(TRUE);
}

IGRint DMnotify_form (form_label,label,value,form_ptr)
/*(
	 int  form_label,
	 int  label,
	 double  value,
	 Form  form_ptr
	)
*/
int form_label;
int label;
IGRdouble value;
Form form_ptr;
{
	int status;
	OM_S_OBJID objid;
	OMuword osnum;

	status =
	FIf_get_cmd_oid_os(form_ptr, &objid, &osnum);
	if (status != FI_SUCCESS)
	{
		/*|DMnotify_form: FI_get_cmd_oid_os fails*/
		return(FALSE);
	}

	status =
	om$send(msg = message COdim.notify_form(form_label,
						label,
						value,
						form_ptr),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
	dm$status(action = RET_STATUS);

	return(TRUE);
}

IGRint DMatof (s,d)
/*(
	 char  s[],
	 double  *d
	)
*/
char s[];
IGRdouble *d;
{
	char *t;

	for (t=s; *t && *t != '/' && *t != ':'; t++);

	if (*t == '/' || *t == ':')
	{
		t++;
		*d = atof(s)/atof(t);
	}
	else	*d = atof(s);

	return(TRUE);
}

end implementation DMroot;

