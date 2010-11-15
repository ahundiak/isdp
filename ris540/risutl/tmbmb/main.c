/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							main.c
**	AUTHORS:						Terrence D. McIntyre
**	CREATION DATE:					11/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "risstjmp.h"
#include "rislimit.h"

/*
**	DEFINES
*/
#define START_YEAR	70
#define START_MONTH	0
#define START_DAY	1


/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define main_c
#include "main.prt"
#include "sys.prt"
#include "comjmp.prt"
#include "compd.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int leap_year(
	int year)
{
	if (year % 4 == 0)
	{
		if (year % 100 == 0)
		{
			if (year % 400 == 0)
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

static time_t mytime(
	struct tm *tm)
{
	int i;
	time_t seconds;
	int total_days;
	static int month_tot[] = { 0,31,59,90,120,151,181,212,243,273,304,334 };
	extern long timezone;


	total_days = (tm->tm_year - START_YEAR) * 365 + month_tot[tm->tm_mon] +
		tm->tm_mday - 1;

	for (i = START_YEAR; i < tm->tm_year; i++)
		if (leap_year(i + 1900))
			total_days++;

	if (leap_year(tm->tm_year + 1900) && tm->tm_mon >= 2)
			total_days++;

	seconds = total_days * 24 * 60 * 60 +
		tm->tm_hour * 60 * 60 +
		tm->tm_min * 60 +
		tm->tm_sec;

	if (tm->tm_isdst)
		seconds -= 60 * 60;

	seconds += timezone;

	return(seconds);
}

/******************************************************************************/

static int parse_date(
	char *s,
	struct tm *tm)
{
	int day;
	int year;
	int month;

	if (sscanf(s, "%d/%d/%d", &month, &day, &year) != 3) 
	{
		return 1;
	}

	tm->tm_mday = day;
	tm->tm_year = year;
	tm->tm_mon = month - 1;
	tm->tm_hour = 0;
	tm->tm_min = 0;
	tm->tm_sec = 0;

	return 0;
}

/******************************************************************************/

extern int main(
	int argc,
	char *argv[])
{
	int status;
	time_t ltime;
	struct tm tm;

	char *date;
	char buffer[32] = "";

	tzset();

	if (argc == 1)
	{
		printf("Enter the date of the timebomb [mm/dd/yy]: ");
		fgets(buffer, 32, stdin);
		date = buffer;
	}
	else if (argc == 2)
	{
		date = argv[1];
	}
	else
	{
		printf("Usage: timebomb [mm/dd/yy]\n");
		return 1;
	}

	if (parse_date(date, &tm))
	{
		printf("timebomb: invalid date\n");
		return 1;
	}

	ltime = mytime(&tm);

	printf("The timebomb will explode on %s", ctime(&ltime));
	printf("\nTo hard code the timebomb use the following define\n");
	printf("#define TIMEBOMB %d\n", ltime);

	if ((status = SETJMP()) != 0)
	{
		RESETJMP();
		printf("Encrytion failed: status:%d\n", status);
		return 1;
	}

	sprintf(buffer, "%d", ltime);
	RIScom_pd(buffer, buffer);	

	RESETJMP();

	printf("\nTo override the hard coded timebomb, place the following\n");
	printf("string in the timebomb file.\n");
	printf("%s\n", buffer);

	return 0;
}

/******************************************************************************/
