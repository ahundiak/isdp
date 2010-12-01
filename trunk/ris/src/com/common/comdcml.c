/* Do not alter this SPC information: $Revision: 1.2.54.1 $ */
/*
**	NAME:							comdcml.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					2/90
**	ABSTRACT:
**		Miscellaneous functions for handling RIS parameters.
**	
**	REVISION HISTORY:
*/
#include <stdlib.h>
#include <string.h>

#include "riscom.h"
#include "risdebug.h"

/******************************************************************************/

extern void RIScom_get_prec_scale(char *s, int s_len, int *precp, int *scalep)
{
/*
**	assumes s is a valid number string
**	sets scale to -1 if number is an integer
*/
	int len;
	char *ptr;

	if ((len = strlen(s)) < s_len)
		s_len = len;

	if (*s == '-' || *s == '+')
	{
		s_len--;
		s++;
	}

	while(*s == '0')
	{
		s_len--;
		s++;
	}

	if ((ptr = strchr(s,'.')) == (char *)0)
	{
		*precp = s_len;
		*scalep = -1;
	}
	else
	{
		*precp = s_len - 1;
		*scalep = *precp - (ptr - s);
	}
}

/******************************************************************************/

extern int RIScom_set_prec_scale(char *s, int s_len, char *d, int d_len, int d_prec, int d_scale)
{
/*
**	assumes s is a valid number string
*/
	int i;
	int diff;
	int carry;
	int s_index, d_index;
	int s_prec,s_scale,dec_pt;
	char temp[80];

	COM_DBG(("RIScom_set_prec_scale: s:<%s> s_len:%d\n",s,s_len));
	COM_DBG(("RIScom_set_prec_scale: d_len:%d d_prec:%d d_scale=%d\n",
		d_len,d_prec,d_scale));

	for (i = 0; i < s_len; i++)
	{
		if (s[i] == '\0') break;
		temp[i] = s[i];
	}
	s_len = i;
	temp[s_len] = '\0';

	RIScom_get_prec_scale(temp,s_len,&s_prec,&s_scale);
	COM_DBG(("RIScom_set_prec_scale: s_prec:%d s_scale:%d\n",s_prec,s_scale));
	if (s_scale == -1)
	{
		dec_pt = s_len;
		temp[s_len++] = '.';
		temp[s_len] = '\0';
		s_scale = 0;
	}
	else
	{
		dec_pt = s_len - s_scale - 1;
	}

	carry = 0;

	/* check scales */
	if (s_scale > d_scale)
	{
		diff = s_scale - d_scale;
		s_scale -= diff;
		s_prec -= diff;

		s_index = dec_pt + s_scale + 1;
		if (temp[s_index] > '4')
		{
			carry = 1;
			temp[s_index] = '\0';
			do
			{
				s_index--;
				if (temp[s_index] == '-' || temp[s_index] == '+')
				{
					break;
				}
				if (temp[s_index] == '9')
				{
					temp[s_index] = '0';
					carry = 1;
				}
				else if (temp[s_index] != '.')
				{
					temp[s_index] = temp[s_index] + (char)1;
					carry = 0;
				}
			}
			while (carry && s_index);
			if (carry) s_prec++;
		}
		else
		{
			temp[s_index] = '\0';
		}
	}
	else if (s_scale < d_scale)
	{
		diff = d_scale - s_scale;

		for (i = 0; i < diff; i++)
		{
			temp[s_len++] = '0';
		}
		temp[s_len] = '\0';
	
		s_scale += diff;
		s_prec += diff;
	}

	/* check precisions */
	COM_DBG(("RIScom_set_prec_scale: s_prec=%d d_prec=%d\n",s_prec,d_prec));
	if (s_prec > d_prec)
		return(1);

	d_index = s_index = 0;

	if (temp[s_index] == '-' || temp[s_index] == '+')
	{
		if (d_index < d_len-1) d[d_index++] = temp[s_index++];
	}

/* the following "if" statement enclosure fixes problem with 99.95 put
   into a 10,1 decimal column coming out to be 1.0 instead of 100.0) ***/

	if (!((s[0] == '9')  || ((s[0] == '-')  && (s[1] == '9'))))
	{
		while(temp[s_index] == '0') 
			s_index++;
	}

	if (carry)
	{
		if (d_index < d_len-1) d[d_index++] = '1';
	}
	else
	{
		if (d_prec > d_scale && temp[s_index] == '.')
		{
			if (d_index < d_len-1) d[d_index++] = '0';
		}
	}
	while(temp[s_index] && d_index < d_len-1)
	{
		d[d_index++] = temp[s_index++];
	}

	d[d_index] = '\0';

	COM_DBG(("RIScom_set_prec_scale: d=<%s> d_len=%d\n",d,d_len));
	return(0);
}

/******************************************************************************/
