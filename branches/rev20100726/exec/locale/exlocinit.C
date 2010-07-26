#include "igrtypedef.h"
#include "string.h"
#include "stdio.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include "exmacros.h"

extern struct EX_locale_struct *EX_locale;
extern struct EX_locale_struct *EX_text_locale;
extern struct EX_locale_struct *EX_message_locale;

static int first_locale = 1;

EX_init_locale ()
{
    IGRint      jj,
                status;
    IGRchar     path[80],
                language[80],
                string[256], 
                locale_path[80];

    IGRchar     *EXfgets();

    FILE        *locale_file;

    EX_locale = (struct EX_locale_struct *) 
			malloc (sizeof (struct EX_locale_struct));
    EX_text_locale = EX_locale;
    EX_message_locale = EX_locale;

    /*
	Have at least one locale to use,  in case all are deleted or are
	missing.
    */

    EX_default_init (EX_locale);

    /*
	Look for a locale file in the config directory.
    */

    for (jj = 0,  status = 1; status == 1; jj++) {
	if (status = ex$get_path (index = jj,  path = path, 
	                          len = sizeof (path))) {
	    strcpy (locale_path, path);
	    strcat (locale_path, "config/language");

	    locale_file = fopen (locale_path, "r");
            if (locale_file) {
                EXfgets (string, 256, locale_file);
                if (!sscanf (string, "%s", language)) {
                    printf ("Error reading language file \n");
                    return (0);
                }
                EX_set_locale (EX_Message | EX_Text, language);
                fclose (locale_file);
                status = 0;
            }
	} 		/* if statement */
    }			/* for loop */
    return(1);
}

/*
	Hardcode a locale.
	This will be called so that at least one locale is always
	active.
	
*/	

EX_default_init (locale)
struct EX_locale_struct *locale;

{
    locale->pid = 0;
    strcpy (locale->language, "default");
    strcpy (locale->def_msg_font, "fontlib_1.tf");
    strcpy (locale->def_msg_font16, "");
    strcpy (locale->def_text_font16, "");
    strcpy (locale->def_text_font, "");
    strcpy (locale->logkbd, "");
    locale->font = NULL;
    locale->next = NULL;
    locale->sdbflag = 0;

    return (1);
}

char * EXfgets (string, size, locale_file)
IGRchar *string;
IGRint size;
FILE *locale_file;

{
    IGRchar *return_value, *current_char, *copy_char;
    IGRchar *new_line;
    IGRint  no_line = 1, ii;

    while (no_line) {
        return_value = fgets (string, size, locale_file);

        if (return_value) {
	    if (string[0] != '#') {
		no_line = 0;
	/*
		Strip new line character and replace it with a 
		NULL terminator.  fgets does not do this
	*/

                new_line = strchr (string, '\n');
                *new_line = '\0';
	/*
		Strip all blanks and tabs from the line.
	*/

		copy_char = current_char = string;
                for (ii = 0; ii <= strlen (string);  ii++) {
		    if ( (*copy_char != ' ') && (*copy_char != '\t') ) {
			*current_char++ = *copy_char++;
                    }
                    else {
			copy_char++;
                    }
                }
	/*
		Check to see if it is a blank line.
	*/
                if (!strlen (string)) {
		    no_line = 1;
                }
            }
        }
        else {
            no_line = 0;
        }
    }
    return (return_value);
}


