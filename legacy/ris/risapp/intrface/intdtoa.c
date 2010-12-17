/* Do not alter this SPC information: $Revision: 1.2.34.1 $ */
/*
**	NAME:							intdtoa.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <ctype.h>
#include <sys/types.h>
#include <time.h>
#include "riscom.h"
#include "intrface.h"

/*
**	DEFINES
*/

/*
**	FUNCTIONS
*/

/*******************************************************************************
Format string:

yyyy			Year; 4 digits; padded with leading zeros.
yy				Year; last 2 digits; padded with leading zeros.
y				Year; 1,2,3 or 4 digits; no padding.

mm				Month; 2 digits; padded with leading zeros.
m				Month; 1 or 2 digits; no padding
month			Name of month; Up to 9 characters; no padding.
mon				Name of month; 3 character abbreviation; no padding.

ddd				Day of the year; 1,2 or 3 digits; no padding.
dd				Day of the month; 2 digits; padded with leading zeros.
d				Day of the month; 1 or 2 digits; no padding.
day				Name of day of the week; Up to 9 characters; no padding.
dy				Name of day of the week; 3 character abbreviation; no padding.

hh24			Hour, 24 hour mode; 2 digits; padded with leading zeros.
h24				Hour, 24 hour mode; 1 or 2 digits; no padding.
hh12 or hh		Hour, 12 hour mode; 2 digits; padded with leading zeros.
h12 or h		Hour, 12 hour mode; 1 or 2 digits; no padding.

nn				Minute; 2 digits; padded with leading zeros.
n				Minute; 1 or 2 digits; no padding.

ss				Second; 2 digits; padded with leading zeros.
s				Second; 1 or 2 digits; no padding.

am or pm		Meridian indicator; 2 characters; no padding.
a.m. or p.m.	Meridian indicator with periods; 4 characters; no padding.

'text'			Single quoted string is reproduced in destination string.
''				Single quote is reproduced in destination string.

default			Any other character is reproduced in destination string.


Capitalization in a word or abbreviation follows capitalization in the
corresponding format element.  For example:

			MONTH -> SEPTEMBER
			Month -> September
			month -> september

*******************************************************************************/
/*
**	VARIABLES
*/


static char *dow_name[] =
{
	"sunday",
	"monday",
	"tuesday",
	"wednesday",
	"thursday",
	"friday",
	"saturday",
};

static char *month_name[] =
{
	"",
	"january",
	"february",
	"march",
	"april",
	"may",
	"june",
	"july",
	"august",
	"september",
	"october",
	"november",
	"december"
};

/*
**      FUNCTION PROTOTYPES
*/
#define intdtoa_c
#include "comdate.prt"
#include "comisfn.prt"
#include "comstcmi.prt"
#include "intdtoa.prt"
#include "sys.prt"




/******************************************************************************/

static void add_upper_lower_string(
	char *s,
	char *d,
	int len,
	char *format)
{
	if (RIScom_islower(format[0]))
	{
		/*
		**	The first letter of format is lower case, copy s to d, 
		**	converting to lower case.
		*/
		for(;len > 0; len--, d++, s++)
		{
			if (RIScom_isupper(*s))
			{
				*d = (char)RIScom_tolower(*s);
			}
			else
			{
				*d = *s;
			}
		}
	}
	else
	{
		/*
		** The first letter is upper case, so copy the first letter of
		** s to d, converting to upper case if needed.
		*/
		if (RIScom_islower(*s))
		{
			*d = (char)RIScom_toupper(*s);
		}
		else
		{
			*d = *s;
		}
		d++;
		s++;
		len--;

		if (RIScom_islower(format[1]))
		{
			/*
			**	The second letter of format is lower case, copy the rest of
			**	s to d, converting to lower case.
			*/
			for(;len > 0; len--, d++, s++)
			{
				if (RIScom_isupper(*s))
				{
					*d = (char)RIScom_tolower(*s);
				}
				else
				{
					*d = *s;
				}
			}
		}
		else
		{
			/*
			**	The second letter of format is upper case, copy the rest of
			**	s to d, converting to upper case.
			*/
			for(;len > 0; len--, d++, s++)
			{
				if (RIScom_islower(*s))
				{
					*d = (char)RIScom_toupper(*s);
				}
				else
				{
					*d = *s;
				}
			}
		}
	}
}

/******************************************************************************/

static void add_ampm(
	unsigned int hour,
	char *d,
	int len,
	char *format)
{
	int i;

	if (hour < 12)	/* AM */
	{
		if (RIScom_isupper(*format))
			*d++ = 'A';
		else
			*d++ = 'a';
	}
	else 			/* PM */
	{
		if (RIScom_isupper(*format))
			*d++ = 'P';
		else
			*d++ = 'p';
	}
	format++;
	len--;

	for (i = 0; i < len; i++)
	{
		*d++ = *format++;
	}
}

/******************************************************************************/

static void add_th(
	int number,
	char *d,
	char *format)
{
	char *suffix = "";

	switch(number % 100)
	{
		case 11:
		case 12:
		case 13:
			suffix = "th";
			break;

		default:
			switch(number % 10)
			{
				case 1:
					suffix = "st";
					break;
				case 2:
					suffix = "nd";
					break;
				case 3:
					suffix = "rd";
					break;
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
				case 0:
					suffix = "th";
					break;
			}
			break;
	}
	add_upper_lower_string(suffix,d,2,format);
}

/******************************************************************************/

extern int RISAPI RISXdatetime_to_ascii(
	datetime *date,
	char *buffer,
	char *format)
{
	int dow;
	int len;
	int char_used;
	int number;
	char *sptr;
	char *dptr;
	char s[8];


	if (RIScom_invalid_date(date)) return(1);

	sptr = format;
	dptr = buffer;

	while(*sptr)
	{
		char_used = 0;
		number = -1;
		switch(*sptr)
		{
			case 'a':
			case 'A':
				if (!RIScom_strncmp_ic(sptr,"a.m.",4))
				{
					char_used = 1;
					add_ampm(date->hour,dptr,4,sptr);
					dptr += 4;
					sptr += 4;
				}
				else if (!RIScom_strncmp_ic(sptr,"am",2))
				{
					char_used = 1;
					add_ampm(date->hour,dptr,2,sptr);
					dptr += 2;
					sptr += 2;
				}
				break;

			case 'd':
			case 'D':
				if (!RIScom_strncmp_ic(sptr,"ddd",3))
				{
					char_used = 1;
					number = RIScom_calc_doy(date);
					dptr += sprintf(dptr,"%d",number);
					sptr += 3;
				}
				else if (!RIScom_strncmp_ic(sptr,"dd",2))
				{
					char_used = 1;
					number = date->day;
					dptr += sprintf(dptr,"%02d", number);
					sptr += 2;
				}
				else if (!RIScom_strncmp_ic(sptr,"day",3))
				{
					char_used = 1;
					dow = RIScom_calc_dow(date);
					len = strlen(dow_name[dow]);
					add_upper_lower_string(dow_name[dow],dptr,len,sptr);
					dptr += len;
					sptr += 3;
				}
				else if (!RIScom_strncmp_ic(sptr,"dy",2))
				{
					char_used = 1;
					dow = RIScom_calc_dow(date);
					len = 3;
					add_upper_lower_string(dow_name[dow],dptr,len,sptr);
					dptr += len;
					sptr += 2;
				}
				else /* 'd' */
				{
					char_used = 1;
					number = date->day;
					dptr += sprintf(dptr,"%d", number);
					sptr += 1;
				}
				break;

			case 'h':
			case 'H':
				if (!RIScom_strncmp_ic(sptr,"hh24",4))
				{
					char_used = 1;
					number = date->hour;
					dptr += sprintf(dptr, "%02d", number);
					sptr += 4;
				}
				else if (!RIScom_strncmp_ic(sptr,"h24",3))
				{
					char_used = 1;
					number = date->hour;
					dptr += sprintf(dptr, "%d", number);
					sptr += 3;
				}
				else
				{
					char_used = 1;

					if (date->hour == 0)
						number = 12;
					else if (date->hour > 12)
						number = date->hour - 12;
					else
						number = date->hour;

					if (!RIScom_strncmp_ic(sptr,"hh",2))
					{
						dptr += sprintf(dptr, "%02d", number);
						sptr += 2;
					}
					else
					{
						dptr += sprintf(dptr, "%d", number);
						sptr++;
					}

					if (!RIScom_strncmp_ic(sptr,"12",2))
						sptr += 2;
				}
				break;

			case 'm':
			case 'M':
				if (!RIScom_strncmp_ic(sptr,"month",5))
				{
					char_used = 1;
					len = strlen(month_name[date->month]);
					add_upper_lower_string(month_name[date->month],
						dptr,len,sptr);
					dptr += len;
					sptr += 5;
				}
				else if (!RIScom_strncmp_ic(sptr,"mon",3))
				{
					char_used = 1;
					len = 3;
					add_upper_lower_string(month_name[date->month],
						dptr,len,sptr);
					dptr += len;
					sptr += 3;
				}
				else if (!RIScom_strncmp_ic(sptr,"mm",2))
				{
					char_used = 1;
					number = date->month;
					dptr += sprintf(dptr,"%02d", number);
					sptr += 2;
				}
				else /* 'm' */
				{
					char_used = 1;
					number = date->month;
					dptr += sprintf(dptr,"%d", number);
					sptr ++;
				}
				break;

			case 'n':
			case 'N':
				if (!RIScom_strncmp_ic(sptr,"nn",2))
				{
					char_used = 1;
					number = date->minute;
					dptr += sprintf(dptr,"%02d", number);
					sptr += 2;
				}
				else
				{
					char_used = 1;
					number = date->minute;
					dptr += sprintf(dptr,"%d", number);
					sptr++;
				}
				break;

			case 'p':
			case 'P':
				if (!RIScom_strncmp_ic(sptr,"p.m.",4))
				{
					char_used = 1;
					add_ampm(date->hour,dptr,4,sptr);
					dptr += 4;
					sptr += 4;
				}
				else if (!RIScom_strncmp_ic(sptr,"pm",2))
				{
					char_used = 1;
					add_ampm(date->hour,dptr,2,sptr);
					dptr += 2;
					sptr += 2;
				}
				break;


			case 's':
			case 'S':
				if (!RIScom_strncmp_ic(sptr,"ss",2))
				{
					char_used = 1;
					number = date->second;
					dptr += sprintf(dptr,"%02d", number);
					sptr += 2;
				}
				else
				{
					char_used = 1;
					number = date->second;
					dptr += sprintf(dptr,"%d", number);
					sptr++;
				}
				break;

			case 'y':
			case 'Y':
				if (!RIScom_strncmp_ic(sptr,"yyyy",4))
				{
					char_used = 1;
					number = date->year;
					dptr += sprintf(dptr, "%04d", number);
					sptr += 4;
				}
				else if (!RIScom_strncmp_ic(sptr,"yy",2))
				{
					char_used = 1;
					number = date->year;
					sprintf(s, "%04d", number);
					strncpy(dptr, s+2, 2); /*itbokic*/
					dptr += 2;
					sptr += 2;
				}
				else
				{
					char_used = 1;
					number = date->year;
					dptr += sprintf(dptr,"%d", number);
					sptr ++;
				}
				break;

			case '\'':
				char_used = 1;
				sptr++;

				if (*sptr == '\'')
				{
					*dptr++ = *sptr++;
					break;
				}

				while (*sptr)
				{
					if (*sptr == '\'')
					{
						sptr++;
						if (*sptr == '\'')
						{
							*dptr++ = *sptr++;
						}
						else
						{
							break;
						}
					}
					else
					{
						*dptr++ = *sptr++;
					}
				}
				break;
		} /* switch */

		if (number != -1)
		{
			if (!RIScom_strncmp_ic(sptr,"th",2))
			{
				add_th(number,dptr,sptr);
				dptr += 2;
				sptr += 2;
			}
		}

		if (char_used == 0)
		{
			*dptr++ = *sptr++;
		}
	}
	*dptr = 0;
	return(0);
}

#ifdef TESTING

extern void print_date(
	datetime *date,
	char *format)
{
	char buffer[200];

	RISdatetime_to_ascii(date,buffer,format);
	printf("format = <%s>\n",format);
	printf("  date = <%s>\n\n", buffer);
}

main()
{
	long ltime;
	datetime date;
	struct tm *today;

	time(&ltime);
	today = localtime(&ltime);

	date.year = today->tm_year + 1900;
	date.month = today->tm_mon + 1;
	date.day = today->tm_mday;
	date.hour = today->tm_hour;
	date.minute = today->tm_min;
	date.second = today->tm_sec;

	print_date(&date,"m/d/y");
	print_date(&date,"mm/dd/yy");
	print_date(&date,"mm/dd/yyyy");
	print_date(&date,"dy, mon d  yyyy");
	print_date(&date,"day, month d  yyyy");
	print_date(&date,"'''day = 'day'', month d  yyyy");
	print_date(&date,"'day = 'day, month d  yyyy");

	print_date(&date,"Dy, Mon d  yyyy");
	print_date(&date,"Day, Month d  yyyy");

	print_date(&date,"DY, MON d  yyyy");
	print_date(&date,"DAY, MONTH d  yyyy");

	print_date(&date,"DAY, MONTH d  yyyy hh12:nn:ss AM");
	print_date(&date,"DAY, MONTH d  yyyy hh:nn:ss P.M.");

	print_date(&date,"day, month d  yyyy hh12:nn:ss am");
	print_date(&date,"day, month d  yyyy hh:nn:ss p.m.");

	print_date(&date,"day, month d  yyyy hh24:nn:ss");

	print_date(&date,"Day' the 'ddth' day of 'Month, yyyy");

	print_date(&date,"'The 'sth' second of the 'nth' minute of the 'h24th' hour");
}
#endif
