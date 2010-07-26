#include "stdio.h"
#include "string.h"
#include "igrtypedef.h"
#include "exlocaledef.h"
#include "exlocale.h"


/*
	This function will take an opened file locale file
	and parse the contents and place them in the locale structure.
*/

int EX_read_locale (locale, file)

struct EX_locale_struct *locale;
FILE   *file;

{
    IGRchar buffer[256],
            *equal_char;


    locale->pid = 0;
    strcpy (locale->language, "");
    strcpy (locale->logkbd, "");
    strcpy (locale->def_msg_font, "");
    strcpy (locale->def_text_font, "");
    strcpy (locale->def_msg_font16, "");
    strcpy (locale->def_text_font16, "");
    locale->font = NULL;
    locale->next = NULL;
 
    while ( EXfgets (buffer, 256, file) != NULL ) {
        equal_char = strchr (buffer, '=');
	if (equal_char) {
	    *equal_char = '\0';
	    equal_char++;
	    if (!strcmp (buffer, "def_msg_font")) {
 		strcpy (locale->def_msg_font, equal_char);
	    }
	    if (!strcmp (buffer, "def_text_font")) {
		strcpy (locale->def_text_font, equal_char);
	    }
	    if (!strcmp (buffer, "def_msg_font16")) {
		strcpy (locale->def_msg_font16, equal_char);
	    }
	    if (!strcmp (buffer, "def_text_font16")) {
		strcpy (locale->def_text_font16, equal_char);
	    }
	    if (!strcmp (buffer, "logkbd")) {
		strcpy (locale->logkbd, equal_char);
	    }
	    if (!strcmp (buffer, "sdbflag")) {
		locale->sdbflag = 1;
	    }
	}
    }
return(1);    
}
