#include "machine.h"
#include "QUI.h"

/******************************************************************************

Doc: QUI_highlight_list

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: QUI_notify.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine highlights the appropriate row of a gadget's
             associated_list given the text to search for

Examples: QUI_highlight_list(fp,g_label,row_text)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

QUI_highlight_list(fp,g_label,row_text)

Form    fp;            /* I - Pointer to the form     */
long    g_label;       /* I - The label of the gadget */
char    *row_text;     /* I - the text to search for */

{
  long found=0;
  long num_rows;
  long row_ctr;
  long sts,pos;
  long text_len;
  long select_flag;

  FIfld_get_list_num_rows( fp, g_label, 0, &num_rows);
  for (row_ctr=found=0;((row_ctr<num_rows)&&(!found));row_ctr++)
  {
    FIfld_get_list_text_length(fp,g_label,row_ctr,0,&text_len);
    /* Increment text_len because of NULL */
    text_len++;
    if ( QUIglobal.text_size < text_len )
    {
      if ( QUIglobal.text_size > 0 )
      {
        /* Realloc space for larger string */
        QUIglobal.text = (char *) realloc ( QUIglobal.text, text_len );
      }
      else
      {
        /* Calloc space for string */
        QUIglobal.text = (char *) calloc ( 1, text_len );
      }
      QUIglobal.text_size = text_len;
    }
    sts = FIfld_get_list_text (fp,g_label,row_ctr,0,
                               QUIglobal.text_size,QUIglobal.text,&select_flag,&pos);
    if (strcmp(QUIglobal.text, row_text)==0)
    {
      FIfld_set_list_select( fp, g_label, row_ctr, 0, 1);
      found=1;
    }
  }
}
