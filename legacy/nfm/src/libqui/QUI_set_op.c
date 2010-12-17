#include "machine.h"
#include "QUI.h"

/******************************************************************************

Doc: QUI_set_op

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: QUI_notify.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine returns the relational operator given the
             numerical euuivalent

Examples: QUI_set_op(1,oper)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

QUI_set_op( number, oper)
/* this routine returns the operator string given an integer */
long number; /* I - number to translate */
char *oper;  /* O - the operator translation */

{
  switch(number)
  {
    case 1: strcpy(oper, QUI_OPSTR1);break;
    case 2: strcpy(oper, QUI_OPSTR2);break;
    case 3: strcpy(oper, QUI_OPSTR3);break;
    case 4: strcpy(oper, QUI_OPSTR4);break;
    case 5: strcpy(oper, QUI_OPSTR5);break;
    case 6: strcpy(oper, QUI_OPSTR6);break;
    case 7: strcpy(oper, QUI_OPSTR7);break;
    case 8: strcpy(oper, QUI_OPSTR7);break;
    default: strcpy(oper, QUI_OPSTR1);break;
  }
  return;
}

