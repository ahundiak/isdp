#include "machine.h"
/******************************************************************************

Doc: QUIget_type

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: QUIget_type.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number:

Description: This routine extracts the data type and data length from
             any valid NFM data type.

Examples: QUIget_type("char(20)", data_type, data_length)

Return Status: None

History:  10/26/89 - mgw - Creation
            6/5/90 - jwa - modified for forms
            9/4/91 - JWA - added header
          10/08/91 - JWA - guarantee length > 0
          11/06/91 - JWA - changed maximum lengths of various datatypes to
                           follow RIS manual restrictions. Also, set default
                           to 10 for max length
          11/08/91 - JWA - reset max lengths to jive with DE.

******************************************************************************/

#include "QUI.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <memory.h>

void QUIget_type(type_string, data_type, data_length)

char	*type_string;	/* I - NFM data string (i.e. char(16))*/

short	*data_type;	    /* O - Data type of data string (i.e. char) */

short	*data_length;	/* O - Data length of data string (i.e. 16) */


{

	char	*ptr1;
	char	*ptr2;
	char	temp_type[20];
	int	    len;
    static  char  *fname = "QUIget_type";

    _NFIdebug ((fname, "type_string = <%s>\n", type_string));

	ptr1 = type_string;
	ptr2 = strchr(type_string, '(');
	if (ptr2)
	{
	  len = ptr2 - ptr1;
	  strncpy(temp_type, type_string, len);
	  temp_type[len] = '\0';
	}
	else
	{
	  strncpy(temp_type,type_string,20);
	}

	if (!strcmp(temp_type,"char"))
	{
      *data_type=QUI_CHAR_TYPE;
      _NFIdebug ((fname, "datatype is char\n"));
	}
	else if (!strcmp(temp_type,"smallint"))
	{
	  *data_type=QUI_SMALLINT_TYPE;
      *data_length=5;
      _NFIdebug ((fname, "datatype is smallint\n"));
	}
	else if (!strcmp(temp_type,"integer"))
	{
	  *data_type=QUI_INTEGER_TYPE;
      *data_length=10;
      _NFIdebug ((fname, "datatype is integer\n"));
	}
	else if (!strcmp(temp_type,"double"))
	{
	  *data_type=QUI_DOUBLE_TYPE;
      *data_length=11;
      _NFIdebug ((fname, "datatype is double\n"));
	}
	else if (!strcmp(temp_type,"real"))
	{
	  *data_type=QUI_REAL_TYPE;
      *data_length=8;
      _NFIdebug ((fname, "datatype is real\n"));
	}
	else if (!strcmp(temp_type,"timestamp"))
	{
	  *data_type=QUI_TIMESTAMP_TYPE;
      *data_length=19;
      _NFIdebug ((fname, "datatype is timestamp\n"));
	}
    if (*data_type==QUI_CHAR_TYPE)
    {
      if (ptr2)
      {
        ptr2++;
        ptr1=ptr2;
        ptr2 = strchr(ptr2, ')');
        len = ptr2 - ptr1;
        *data_length=atoi(ptr1);
      }
      else
      {
        *data_length=0;
      }
    }
    if (*data_length==0)
      *data_length=10;
} /* end QUIget_type */
