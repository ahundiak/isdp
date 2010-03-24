#include "stdio.h"
#include "igrtypedef.h"
#include "exlocale.h"
#include "exlocaledef.h"
#include <string.h>

extern struct EX_locale_struct *EX_text_locale;
extern struct EX_locale_struct *EX_message_locale;

static int Kbd_read_pipe = -1;
static int Kbd_write_pipe = -1;
#argsused
EXset_locale (msg, count, which_error, var, flags, identifier)
IGRlong                 *msg;
IGRint 			count;
IGRint 			*which_error;
struct EX_locale_var 	*var;
IGRint			flags;
IGRchar			*identifier;

{
    struct EX_locale_var *temp_var;

    *msg = EX_Success;
    temp_var = var;

    while (count) {
	switch (temp_var->var) {

	/*  Set the read pipe for the logical keyboard */

	case EX_Kbd_Read_Pipe:
	    Kbd_read_pipe = *((int *)(temp_var->var_ptr));
	break;
	
	/*  Set the write pipe for the logical keyboard */
	
	case EX_Kbd_Write_Pipe:
	    Kbd_write_pipe = *((int *)(temp_var->var_ptr));
	break;

	/* Set the logical keyboard pid */

	case EX_Kbd_Pid:
	    EX_text_locale->pid = *((int *)(temp_var->var_ptr));
	break;
	
	default:
	    printf ("Error in settin locale %d\n", temp_var->var);
	break;
	}
        count--;
        temp_var++;
    }
    return (1);
}

#argsused
EXinq_locale (msg, count, which_error, var, flags, identifier)
IGRlong			*msg;
IGRint 			count;
IGRint 			*which_error;
struct EX_locale_var 	*var;
IGRint			flags;
IGRchar			*identifier;

{
    struct EX_locale_var *temp_var;
    struct EX_locale_struct *locale = NULL;
    struct EX_alias alias;
    struct EX_fonts *temp_font;
    IGRint ii;
    int status;

    *msg = EX_Success;
    temp_var = var;

    while (count) {
	switch (temp_var->var) {

	/*  Get the font parameters so the font can be downloaded */
	
        case EX_font_parameters:
	    if ((flags & EX_Text) && (flags & EX_Typeface_Charmap))
	    {
	       locale = EX_text_locale;
	       EX_get_font (msg, locale, identifier, 
                            (struct EX_fonts *)temp_var, flags);
	       break;
	    }

	    if (flags & EX_Message) {
		locale = EX_message_locale;
	    }
	    else if (flags & EX_Text) {
		locale = EX_text_locale;
	    }
	    EX_get_font (msg, locale, identifier, temp_var->var_ptr, flags);
        break;

	/* get the pipe that is used for reads from the logical
	   keyboard */
	
        case EX_Kbd_Read_Pipe:
	    *((int *)(temp_var->var_ptr)) = Kbd_read_pipe;
	break;
	
	/* get the pipe that can be used for writes to logical
	   keyboard */
	
	case EX_Kbd_Write_Pipe:
	     *((int *)(temp_var->var_ptr)) = Kbd_write_pipe;
	break;
	
	/* get name of logical keyboard */
	
	case EX_Kbd_Name:
	    strcpy ((char *) temp_var->var_ptr, EX_text_locale->logkbd);
	break;
	
	/*  Get process id of logical keyboard */
	
	case EX_Kbd_Pid:
	    *((int *)(temp_var->var_ptr)) = EX_text_locale->pid;
	break;

	case EX_alias_fonts:
	    if (flags & EX_Message) {
		locale = EX_message_locale;
	    }
	    else if (flags & EX_Text) {
		locale = EX_text_locale;
	    }
            temp_font = (struct EX_fonts *)temp_var->var_ptr;

	    EXget_alias(identifier, &alias);
            for (ii = 0; ii < alias.number_alias; ii++) {
   	        EX_get_font (msg, locale, alias.name[ii].name, &temp_font[ii], flags);
            }
	break;

	case EX_number_alias:
	    status = EXget_alias(identifier, &alias);
	    if (status)
	      {
              *((int *)(temp_var->var_ptr)) = alias.number_alias;
              }
            else
              {
              *((int *)(temp_var->var_ptr)) = 0;
              }
	break;

	case EX_number_fonts:
	    if (flags & EX_Message) {
		locale = EX_message_locale;
	    }
	    else if (flags & EX_Text) {
		locale = EX_text_locale;
	    }
            *((int *) (temp_var->var_ptr)) = EXfont_number (locale);
        break;

        case EX_all_fonts:
	    if (flags & EX_Message) {
		locale = EX_message_locale;
	    }
	    else if (flags & EX_Text) {
		locale = EX_text_locale;
	    }
            temp_font = (struct EX_fonts *)temp_var->var_ptr;
            EXfill_font (locale, temp_font);
        break;

	default:
	    printf ("Error in inquiry locale %d\n", temp_var->var);
	break;
	
	}
	count--;
        temp_var++;
    }
    return (1);
}

int EX_get_font (msg, locale, identifier, parameters, flags)
IGRlong			*msg;
struct EX_locale_struct	*locale;
IGRchar 		*identifier;
struct EX_fonts 	*parameters;
IGRint 			flags;
{
    struct EX_locale_var *var_list;
    struct EX_fonts *font_params;
    struct EX_next_font *temp_font;
    IGRint not_found = 1;

    *msg = EX_Success;
    temp_font = locale->font;
    while (temp_font && not_found) {
	if (flags & EX_Typeface) {
	    if ((!strcmp (identifier, temp_font->desc.tf)) &&
 (((temp_font->desc.properties & EX_Msg_Font) && (flags & EX_Message)) ||
 (!(temp_font->desc.properties & EX_Msg_Font) && (flags & EX_Text)) ))
        {
		*parameters = temp_font->desc;
		not_found = 0;
	    }
	}
	else
	{
	    if (flags & EX_Logical_Name)
	    {
	       if (!strcmp (identifier, temp_font->desc.name)) 
	       {
		  *parameters = temp_font->desc;
		  not_found = 0;
	       }
	    }
	    else
	    {
	       if (flags & EX_Typeface_Charmap)
	       {
		 var_list = (struct EX_locale_var *)parameters;
	         if ((!strcmp (identifier, temp_font->desc.tf)) && 
		   (!strcmp (var_list[1].var_ptr, temp_font->desc.cm)) &&
 		   (((temp_font->desc.properties & EX_Msg_Font) && (flags & EX_Message)) ||
 		   (!(temp_font->desc.properties & EX_Msg_Font) && (flags & EX_Text)) ))
		 {
		   font_params = (struct EX_fonts *)var_list[0].var_ptr;
		   *font_params = temp_font->desc;
		   not_found = 0;
		 }
	       }

	    }
	}
	temp_font = temp_font->ptr_next;
    }
    if (not_found) {
	*msg = EX_Font_Not_Found;
    }
return(1);    
}

EXfont_number (locale)
struct EX_locale_struct	*locale;
{
    struct EX_next_font *temp_font;
    int ii = 0;

    temp_font = locale->font;
    while (temp_font) {
	temp_font = temp_font->ptr_next;
	ii++;
    }
    return (ii);
}

int EXfill_font (locale, temp_font)

struct EX_locale_struct	*locale;
struct EX_fonts temp_font[];
{
    struct EX_next_font *t1;
    int ii = 0;

    t1 = locale->font;
    while (t1) {
	temp_font[ii] = t1->desc;
	t1 = t1->ptr_next;
	ii++;
   }
return(1);   
}
