/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comdate.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					5/90
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
#include <ctype.h>
#include <stdlib.h>
#include "riscom.h"
#include "ris_err.h"
#include "risdebug.h"
#include "risstjmp.h"
#include "ris.h"

/******************************************************************************/

extern int RIScom_leap_year(
	unsigned int year)
{
	/*
	**	Before 1752 leap years were incorrectly calculated.  In September 1752
	**	11 days were skipped to adjust for these miscalculations.  From then
	**	on leap years were calculated properly.
	*/
	if (year % 4 == 0)
	{
		if (year % 100 == 0)
		{
			if (year % 400 == 0 || year < 1752)
			{
				return(1);
			}
		}
		else
		{
			return(1);
		}
	}
	return(0);
}

/******************************************************************************/

extern unsigned int RIScom_days_in_month(
	unsigned int month,
	unsigned int year)
{
	unsigned int days;
	static unsigned int month_day[13] = {0,31,28,31,30,31,30,31,31,30,31,30,31};

	days = month_day[month];
	if (month == 2)
		if (RIScom_leap_year(year))
			days++;

	return(days);
}

/******************************************************************************/

extern int RIScom_invalid_date(
	datetime *date)
{
	unsigned int days;

	if (date->year < 1 || date->year > 9999)
		return (1);

	if (date->month < 1 || date->month > 12)
		return(1);

	days = RIScom_days_in_month(date->month,date->year);
	if (date->day < 1 || date->day > days)
		return(1);

	/*
	**	September 1752 was an unusual month.  That is the month 11 days 
	**	were skipped to make up for lack of leap year adjustments.  The
	**	days skipped were the 3rd through the 13th.
	*/
	if (date->year == 1752 &&
		date->month == 9 &&
		date->day > 2 && date->day < 14)
		return(1);

	return(0);	
}

/******************************************************************************/

extern unsigned int RIScom_calc_doy(
	datetime *date)
{
	unsigned int days;
	static unsigned int month_tot[12] = { 0,31,59,90,120,151,181,212,243,273,304,334 };

	/*
	**	Calculate the days from 1/1/year to month/day/year
	*/
	days = month_tot[date->month - 1] + date->day;
	if (RIScom_leap_year(date->year) && date->month > 2)
		days++;
	/*
	**	September 1752 was an unusual month.  That is the month 11 days 
	**	were skipped to make up for lack of leap year adjustments. 
	*/
	if ((date->year == 1752 && date->month > 9) ||
		(date->year == 1752 && date->month == 9 &&
		 date->day >= 14))
		days -= 11;

	return(days);
}

/******************************************************************************/

extern int RIScom_days_between(
	datetime *date1,
	datetime *date2)
{
	/*
	**	returns positive days if date1 greater than date2
	**	returns negative days if date1 less than date2
	*/

	int days;
	int negative = 0;
	unsigned int i;
	unsigned int days1,days2;
	datetime *temp;

	/*
	**	if date2 > date1 swap them
	*/
	if ((date2->year >  date1->year)
		||
		(date2->year == date1->year &&
		 date2->month > date1->month)
	 	||
		(date2->year == date1->year &&
		 date2->month == date1->month &&
		 date2->day > date1->day))
	{
		temp = date1;
		date1 = date2;
		date2 = temp;
		negative = 1;
	}
	/*
	** We now know that date1 is greater than date2
	*/

	/*
	**	Calculate the days from 1/1/year1 to month1/day1/year1
	*/
	days1 = RIScom_calc_doy(date1);

	/*
	**	Calculate the days from 1/1/year2 to month2/day2/year2
	*/
	days2 = RIScom_calc_doy(date2);
	
	/*
	**	Calculate days from 1/1/year1 to 12/31/year2-1
	*/
	days = (date1->year - date2->year) * 365;
	for (i = date2->year; i < date1->year; i++)
		if (RIScom_leap_year(i)) days++;

	/*
	**	September 1752 was an unusual month.  That is the month 11 days 
	**	were skipped to make up for lack of leap year adjustments. 
	*/
	if (date2->year <= 1752 && date1->year > 1752)
		days -= 11;

	days -= days2;
	days += days1;

	if (negative) days = -days;
	return(days);
}

/******************************************************************************/

extern int RIScom_calc_dow(
	datetime *date)
{
	int dow;
	int days;

	/*
	**	1/1/1990 was a Monday 
	*/
	static  int known_dow = 1;
	static  datetime known_date = { 0, 0, 0, 1, 1, 1990 };

	days = RIScom_days_between(date, &known_date);

	dow = (known_dow + days) % 7;
	if (dow < 0) dow = 7 + dow;

	return(dow);
}

/******************************************************************************/

extern char RIScom_dtseparator(
	char index)
{
	static char separators[DT_COUNT] =
	{
		0, ':', ':', ':', '-', '-'
	};
	
	if (index < 0 || index >= DT_COUNT) LONGJMP(RIS_E_INTERNAL_ERROR);
	return(separators[index]);
}

/******************************************************************************/

extern int RIScom_char_to_datetime(
	char *source,
	dtime *dest)
{
	/*
	**	Returns 0 if source string is a valid datetime string
	**	otherwise returns the location in the string which caused
	**	the syntax error + 1.
	*/
	int		len;
	char	s[32];
	char	*ptr;
	char	index,start,stop;


	COM_DBG(("RIScom_char_to_datetime(source:<%s> dest:0x%x)\n", source, dest));

	ptr = source;
	while(*ptr && RIScom_isspace(*ptr)) ptr++;

	start = DT_YEAR;
	stop = DT_SECOND;
	for (index = start; index >= stop; index--)
	{
		len = 0;
		while (*ptr && RIScom_isdigit(*ptr))
		{
			s[len++] = *ptr;
			if ((index == DT_YEAR && len > 4) ||
				(index != DT_YEAR && len > 2))
			{
				COM_DBG(("RIScom_char_to_datetime:returning %d\n",
					ptr - source + 1));
				return(ptr - source + 1);
			}
			ptr++;
		}
		if (!len) return(ptr - source + 1);
		s[len] = 0;

		dest->data[index] = atoi(s);
		if (index > stop)
		{
			if (*ptr != RIScom_dtseparator(index))
			{
				COM_DBG(("RIScom_char_to_datetime:returning %d\n",
					ptr - source + 1));
				return(ptr - source + 1);
			}
			ptr++;
		}
	}

	while(*ptr && RIScom_isspace(*ptr)) ptr++;
	if (*ptr) return(ptr - source + 1);

	COM_DBG(("RIScom_char_to_datetime:returning 0\n"));
	return(0);
}

/******************************************************************************/
