/* #######################    APOGEE COMPILED   ######################## */
#include <stdio.h>
#include <string.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "OMmacros.h"

#define MAX_STR 80 

IGRint GUget_changed_numeral( name, number)

       IGRchar *name;
       IGRshort *number;
{
   /*
      NT server does not recognize typeface and charmap files as the Clipper
      server does. It only considers the font numbers to distinguish 
      between different fonts. So every font should have different font 
      number. This function extracts the required font number after 
      comparing the filenames. 
                              -- CR# 119421203
                                 subhasish
    */

    /* CR# 119524931
	Earlier this function was hard mapping the extra fonts. With
	the introduction of a font_map, the function looks at the
	font_map file for getting the correct font number - Satish 
    */

	IGRint num;
	IGRboolean file_exists;
	IGRint status,i,len;
	FILE *file_des;
	IGRchar path[256],kyword[30];
	IGRchar curr_line[MAX_STR],tmp_line[MAX_STR],*tmp;

	status = OM_S_SUCCESS;

	/* search thru product data path until you encounter the first
	   font_map file 
        */ 
	file_exists = FALSE;

        for (i = 0; (1 & status); i++)
        {
            if (status = ex$get_path(index = i,path = path,len = sizeof(path)))
            {
		strcat(path, "config/english/font_map");
                file_des = fopen(path, "r");
 
                if (file_des == NULL)
                {
		    continue;
                }
		else
		{
			file_exists = TRUE;
			break;
		}
	    }
	}

	/* get each line from the font_map file
	   if keyword is 'font' continue parsing the line otherwise ignore line.
	   extract the tf name 
	   extract font_num if match found with font_name 
        */
	
	if (file_exists == TRUE)
	{
		while (fgets(curr_line, MAX_STR,file_des) != NULL)
		{
			tmp = strchr(curr_line, ':');
			if (tmp == NULL)
				continue;
			strcpy(tmp_line, tmp+1);
			len = strlen(curr_line) - strlen(tmp_line);
			strncpy(kyword , curr_line ,len);
			kyword[len+1] = '\0';

			tmp = strstr(kyword, "font");
			if (tmp == NULL) 
				continue;

			tmp = NULL;
			if ((tmp = strstr(tmp_line,name)) != NULL)  		
			{
				tmp = strstr(tmp_line,"->");
				if (tmp == NULL)
					continue;
				tmp += 2;

				sscanf(tmp,"%d",&num);	
				*number = (IGRshort) num;
				if (*number > 255) 
					continue;

				fclose(file_des);
				return(OM_S_SUCCESS); 
			}
		}
		fclose(file_des);
	}
	return (OM_S_SUCCESS); 
}

	
