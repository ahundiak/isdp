#include "machine.h"
#include "QUI.h"

/******************************************************************************

Doc: QUI_get_op

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: QUI_notify.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine returns the numerical equivalent of a relational
             operator

Examples: oper = QUI_get_op( oper )

Return Status: 1 = "    ="
               2 = "    !="
               3 = "    <"
               4 = "    >"
               5 = "    <="
               6 = "    >="
               7 = "    ><"

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

short QUI_get_op( oper )
/* this routines converts the operator string to an integer */
char *oper; /* I - the operator to translate */

{
  char small_oper[20];
  long index;
  static char *fname = "QUI_get_op";
    
/* strip off leading blanks */

_NFIdebug((fname, "Entering get op\n"));
  index=0;
  while ((index<strlen(oper))&&(oper[index]==' ')) index++;
  strcpy(small_oper,&oper[index]);

/* strip off trailing blanks */    

  if (small_oper[1]==' ') small_oper[1]=0;
  else if (small_oper[2]==' ') small_oper[2]=0;

/* perform compare */

  if (strcmp(small_oper, QUI_OPSTR1)==0)
    return(QUI_OPVAL1);
  else
  if (strcmp(small_oper, QUI_OPSTR2)==0)
    return(QUI_OPVAL2);
  else
  if (strcmp(small_oper, QUI_OPSTR3)==0)
    return(QUI_OPVAL3);
  else
  if (strcmp(small_oper, QUI_OPSTR4)==0)
    return(QUI_OPVAL4);
  else
  if (strcmp(small_oper, QUI_OPSTR5)==0)
    return(QUI_OPVAL5);
  else
  if (strcmp(small_oper, QUI_OPSTR6)==0)
    return(QUI_OPVAL6);
  else
  if (strcmp(small_oper, QUI_OPSTR7)==0)
    return(QUI_OPVAL7);
  else
    return(QUI_OPVAL1);
}

