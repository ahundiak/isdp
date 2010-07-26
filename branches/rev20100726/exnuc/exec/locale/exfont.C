#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "igrtypedef.h"
#include "exlocale.h"
#include "exlocaledef.h"
#include "exmacros.h"
static struct EX_alias *locale_alias = NULL;

static char *field[] = { "unknown","logical name","type face","character map",
                         "font file","properties","resolution factor" };
static int EX_process_font_table( file_name,locale)
char *file_name;
struct EX_locale_struct *locale;

{
    IGRchar line[256];
    char    line1[256];
    FILE    *file_ptr;
    int     err_num;
    int     status;
    
	    file_ptr = fopen (file_name, "r");
	    if (file_ptr) {
		while (EXfgets (line, 256, file_ptr) != NULL) {
		/*
		    Check to see if the line defines an alias
		*/
		    
                    if (!strncmp (line, "alias", 5)) {
                        EXprocess_alias (line);
                    }

		/*
		    Otherwise try to read it as a line with font information
		*/
                    else {
                        strcpy(line1,line);
		        status = EX_read_font_line(line, locale,&err_num);
			if( !status)
			  printf("\npossible error in <%s> \n<%s>\nsuspect field <%d>, %s field.\n",
			          file_name,line1,err_num,field[err_num]);
                    }
                }
                fclose (file_ptr);
  	    }
	return (1);
}


EX_read_font_table(language, locale)

IGRchar *language;
struct EX_locale_struct *locale;

{
    IGRint jj,
           status;

    IGRchar path_name[80],
            file_name[80];
    

    EX_process_font_table("font_table",locale); /* look in current dir first */

    for (jj = 0, status = 1; status == 1; jj++) {
        if(status=ex$get_path(index=jj,path=path_name,len=sizeof(path_name))) {
	    sprintf (file_name, "%s/config/%s/font_table", path_name, language);
            EX_process_font_table(file_name,locale); 
        }
    }
	return (1);
}


EX_read_font_line (line, locale, p_err_num)
IGRchar    *line;
struct EX_locale_struct *locale;
int *p_err_num;
{
    register IGRchar *separator, *copier;
    struct  EX_next_font *temp_font;
    IGRchar name[50];
    char    *end;
    char   *line_end;
    IGRint  nchar;
    IGRint  found = 0;

    copier = separator = line;
    line_end = line + strlen(line);
    *p_err_num = 0;
    separator = strchr (separator, ',');
    if(separator)
        *separator = '\0';
    else
    {
        *p_err_num = 2; 
        return(0);
    }

    nchar = strlen(copier);
    strcpy (name, copier);
    copier = ++separator;

    if (locale && locale->font) {
        temp_font = locale->font;
        while (temp_font) {
            if (! (strcmp (temp_font->desc.name, name))) {
                found = 1;
                break;
            }
            else {
                temp_font = temp_font->ptr_next;
            }
        }
    }
    if (!found) {

/*
 *	Malloc memory for the new font defintion being read in.
 */
        temp_font = (struct EX_next_font *) malloc (sizeof (struct EX_next_font));

/*
 *  	Process the line and fill in the newly malloced memory
 */

        strcpy (temp_font->desc.name, name);

     /* type face */
        separator = strchr (separator, ',');
        if ( separator ) *separator = '\0';
        nchar = strlen(copier);
        if (nchar > 0 )
	{
           strcpy (temp_font->desc.tf, copier);
           if(separator) copier = ++separator;
	   else copier += nchar;
	}
	else
	{
           *p_err_num = 2; 
           free(temp_font);
	   return(0);
	}

     /* char map */
        separator = strchr (separator, ',');
        if ( separator ) *separator = '\0';
        nchar = strlen(copier);
        if (nchar > 0 )
	{
           strcpy (temp_font->desc.cm, copier);
           if(separator) copier = ++separator;
	   else copier += nchar;
	}
	else
	{
           *p_err_num = 3; 
           free(temp_font);
	   return(0);
	}

     /* font file   optional */
        if(*copier == ',') 
        {
          /* no characters for font file, proceed to next field */
	   separator = copier;
	   *copier++ = '\0';
	}
	else
	{
           separator = strchr (separator, ',');
           if ( separator ) *separator = '\0';
           if ( *copier == '\0')
           {
              *p_err_num = 4; 
              free(temp_font);
              return(0);
           }
           else
           {
              nchar = strlen(copier);
              if (nchar > 0 )
              {
                 strcpy (temp_font->desc.ff, copier);
                 if(separator) copier = ++separator;
                 else copier += nchar;
              }
           }
        }        

     /* properties mask */
        separator = strchr (separator, ',');
        if ( separator )  *separator = '\0';
        else if ( *copier == '\0')
        {
           *p_err_num = 5; 
           free(temp_font);
           return(0);
	}
        end = 0;
        temp_font->desc.properties = strtol(copier,&end,10);
        if ( end == copier ) /* error translate number */
	{
           *p_err_num = 5; 
           free(temp_font);
	   return(0);
	}
	else
	{
           if( end < line_end )
	   {
	      copier = ++end;
	   }
	   else  copier = line_end;
	}


     /* resolution factor ( optional ) */

        temp_font->desc.body_size = 0;  /* in font code will set to 24 */  
        end = 0;
        temp_font->desc.body_size = (short)strtol(copier,&end,10); 
        if(( end == copier ) && ( !( (*copier == '\0') || (*copier == ',') ) ))
        {
            *p_err_num = 6; 
            free(temp_font);
            return(0);
        }

    /*
     *  Link the font into the global list of fonts
     */
        temp_font->ptr_next = locale->font;
        locale->font = temp_font;
    }
    return(1);
}

int EXprocess_alias (line)
IGRchar *line;

{
    struct EX_alias *temp;
    IGRchar         *t_char1;
    IGRchar         s_char[256];
    IGRchar         alias[50];
    IGRint          found = 0;
    IGRint          ii = 0;

    /*
	Decode the line
    */

    strcpy (s_char, line);
    t_char1 = strchr (s_char, '=');
    *t_char1 = '\0';
    strcpy (alias, &s_char[5]);
    t_char1++;
    strcpy (s_char, t_char1);

    /*
	Check to see if alias is allready in list.
    */

    if (locale_alias) {
        temp = locale_alias;
        while (temp && !found) {
            if (!(strcmp (alias, temp->alias))) {
                found = 1;
            }        
            else {
                temp = temp->next;
            }
        }
    }

    /*
	If not in list add it, otherwise the alias has been overriden.
    */

    if (!found) {
        
        /*
	    Get the typefaces the alias refers to
        */

        temp = (struct EX_alias *)malloc (sizeof (struct EX_alias));
        temp->number_alias = 0;
        strcpy (temp->alias, alias);
        temp->name = NULL;
        temp->next = NULL;
        temp->name = (struct EX_alias_name *) 
                             malloc (sizeof (struct EX_alias_name) * 40); 
        /*
		Check to see if this is the first alias being created.
	*/

        if (locale_alias) {
            temp->next = locale_alias->next;
            locale_alias->next = temp;
        }
        else {
            locale_alias = temp;
        }

        while (t_char1 = strchr (s_char, ',')) {
            *t_char1 = '\0';
            strcpy (temp->name[ii].name, s_char);
            temp->number_alias++;
            t_char1++;
            strcpy (s_char, t_char1);
            ii++;
        }
        strcpy (temp->name[ii].name,s_char);
        temp->number_alias++;
        temp->name = (struct EX_alias_name *) realloc (temp->name, 
                      sizeof (struct EX_alias_name) * temp->number_alias); 

        /*
  	    If the input is an alias exand it to a typeface
        */
    }
return(1);    
}

EXget_alias (alias_name, alias)
IGRchar *alias_name;
struct  EX_alias *alias;
{
    struct EX_alias *temp;
    IGRint ret_code = 0;

    temp = locale_alias;
    while (temp) {
        if (!strcmp (alias_name, temp->alias)) {
            *alias = *temp;
            temp = NULL;
            ret_code = 1;
        }
        else {
            temp = temp->next;
        }
    }
    return (ret_code);
}
