#include "machine.h"
#include "QUI.h"

/* Gadgets */

extern long QUI_num_strings;
extern FILE *jwa_dbg_ptr;
extern long   jwa_dbg;

/******************************************************************************

Doc: QUI_clearfrm

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: QUI_clear_ok.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine clears the Query form

Examples: sts = QUI_clear_form();

Return Status: 0

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

void QUI_clear_form(form)

Form form;

{
  QUI_clear_values(form);
}
