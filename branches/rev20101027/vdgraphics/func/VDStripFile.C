
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/func / VDStripFile.C
 *
 * Description:
 *               The function strips the filename from setname[filename] and
 *   returns the setname. It compares the stripped filename and filename of
 *   the input OS,if they are equal it returns the setname otherwise it returns
 *   same as input setname i.e setname[filename].. 
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      01/30/96         Ravi            Creation 
 * --------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>

extern	long VDget_filename_from_os();


long  VDStrip_filename_from_setname( char *str,	       /* I-setname[filename]*/ 
			             char *set_name,   /* O-setname */ 
				     int *os_num       /* I-OS number */ 
							)

 {

	char *s1;
        int  token,
	     len, len1;
        char file_name[20], text[25];
	long sts;


        token = (int)'[';
        len1= strlen(str);
        strcpy(set_name,str );

        if ( (strrchr( str, token ) && strrchr( str, (int)']' )) )
        {
        	s1=strrchr( str,token );
                sts= VDget_filename_from_os ( os_num, file_name );
                sprintf(text,"[%s]",file_name );
        	len =strlen (s1 );
                if ( ! strcmp( s1, text ) )
        		set_name[len1-len] = '\0';
        }
        return 1;

 }

           

  
