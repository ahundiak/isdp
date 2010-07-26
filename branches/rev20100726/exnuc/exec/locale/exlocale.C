#include <stdio.h>
#include <malloc.h>
#include "igrtypedef.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include "exmacros.h"
#include <string.h>

extern struct EX_locale_struct *EX_locale;
extern struct EX_locale_struct *EX_text_locale;
extern struct EX_locale_struct *EX_message_locale;

void EX_set_locale (flag, language)
IGRint	flag;
IGRchar *language;

{
    struct EX_locale_struct *temp;

    IGRint 	not_found = 1,
           	jj,
           	status;

    IGRchar 	path[80],
            	file_name[100];

    FILE        *loc_file = NULL;

    temp = EX_locale;

    /*
	Check to see if the language requested has allready been
	read in.
    */

    EX_set_language (language);
    if (temp) {
        while (temp && not_found) {
            if (!strcmp (temp->language, language)) {

                not_found = 0;
                /*
			Set the locale correctly based on the flag sent
			in
		*/

                if (flag & EX_Text) {
                    EX_text_locale = temp;
                }
                if (flag & EX_Message) {
                    EX_message_locale = temp;
                }

		/*
			Check the logical keyboar and create it if it does
			not exist
		*/

		if (strlen (temp->logkbd)) {
		    if (!temp->pid) {
			EX_create_logical_keyboard();
                    }
                }
            }
            temp = temp -> next;
        }
    } /*  end if there are any locales in memory */

    /*
	Now must try and read from the config directory the language
	specified.
    */

    if (not_found) {
        temp = (struct EX_locale_struct *) malloc 
			(sizeof (struct EX_locale_struct));

        strcpy (temp->language, language);
        temp->pid = 0;
	for (jj = 0, status = 1; status == 1; jj++) {
	    if (status = ex$get_path (index = jj, path = path,
				      len = sizeof (path))) {
		sprintf (file_name, "%sconfig/%s/locale", path, language);
		loc_file = fopen (file_name,  "r");
		if (loc_file) {
		    EX_read_locale (temp, loc_file);
		    temp->next = EX_locale->next;
		    EX_locale->next = temp;
		    if (flag & EX_Text) {
		        EX_text_locale = temp;

		    /*  if there is a logical keyboard create it */

                        if (strlen (temp->logkbd)) {
#ifndef NT                            
			    EX_create_logical_keyboard ();
#endif 
                        }
                    }
                    if (flag & EX_Message) {
			EX_message_locale = temp;
                    }
		    fclose (loc_file);
		    status = 0;
		}
            }
        }
        if (!loc_file) {
	    printf ("Error -- NO locale files defined \n");
        }
        status = EX_read_font_table(language, temp);

    }
}
