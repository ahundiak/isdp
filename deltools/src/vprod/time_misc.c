#include "main.h"
#include <time.h>

extern	char *months[];
extern	int month;   /* time to do the loading */
extern	int day;
extern	int year;
extern	int when;
int	hour, min, meridian;

int this_month;     /* current time */
int this_day;
int this_year;
int this_hour;
int this_min;
int this_meridian;


/*************************************************************************/
/*  This module contains routines that compute time and manipulate the   */
/*  time form.								 */
/*									 */
/*  get_this_date    finds the current date.				 */
/*  get_time         finds the current time and puts it on the time form.*/
/*  get_tomorrow     gets the value of tomorrow.			 */
/*  isleap	     for a given year, it tells if it is a leap year     */
/*  check_curr       makes sure that the user selects a time after now.  */
/*  inq_month_days   finds the number of days in a month                 */
/*  get_date         puts the current date on the date form              */
/*************************************************************************/



get_this_date()

/****************************************************************************/
/* this routine gets the current date                                       */
/****************************************************************************/

{
	time_t	clock, time();
	struct tm *cur_time;

	clock = time(0);
	cur_time = localtime(&clock);

	this_month = cur_time->tm_mon +1;  
	this_day   = cur_time->tm_mday;
	this_year  = cur_time->tm_year;

	month = this_month;    /* by default do the loading now */
	day   = this_day;
	year  = this_year;
} /* get_this_date */



get_time(fp)

Form  fp;	/* form pointer */

/****************************************************************************/
/* this routine gets the current time/date and reflects it on the time form */
/****************************************************************************/

{
	time_t	clock, time();
	struct tm *cur_time;
	char	hourstr[3], minstr[3];
	
	clock = time(0);
	cur_time = localtime(&clock);

	/* set the current hour */

	hour = cur_time->tm_hour;
	if (hour >= 12)
	{
		meridian = TRUE;
		hour = hour - 12;
	} /* if */
	else
		meridian = FALSE;

	if (hour == 0)
		hour = 12;
	this_hour = hour;

	FIg_set_value(fp, HDIAL, (double)hour);
	sprintf(hourstr, "%02d", hour);
	FIfld_set_text(fp, HFIELD, 0, 0, hourstr, FALSE);

	/* set the current minute */

	min = cur_time->tm_min + 1;
	FIg_set_value(fp, MDIAL, (double)min);
	sprintf(minstr, "%02d", min);
	FIfld_set_text(fp, MFIELD, 0, 0, minstr, FALSE);
	this_min = min;

	/* set the meridian setting */

	FIg_set_value(fp, MERIDIAN, (double)meridian);
	this_meridian = meridian;
} /* get_time */



get_tomorrow(cur_month, cur_day)

int	cur_month;
int	cur_day;

/*****************************************************************************/
/* this function get tomorrow's date. it tests for end of months and leap yr */
/* and end of year                                                           */
/*****************************************************************************/

{
	/* if not at possible end of a month */
	if (cur_day <= 27)
	{
		day = cur_day + 1;
		return;
	}/* if */

	/* test for long months */
	if ((cur_month == 1) || (cur_month == 3) || (cur_month == 5) ||
	   (cur_month == 7) || (cur_month == 8) || (cur_month == 10) ||
	   (cur_month == 12))
		if (cur_day != 31)
		{
			day = cur_day +1;
			return;
		} /* if */
		else
		{
			day = 1;
			if (cur_month == 12)
			{
				month = 1;
				year = year+1;
				return;
			} /* if */
			else
			{
				month = cur_month +1;
				return;
			} /* else */
		} /* else */


	/* test for 30 day months */
	if (cur_month != 2)
		if (cur_day != 30)
		{
			day = cur_day +1;
			return;
		}/* if */
		else
		{
			day = 1;
			month = cur_month +1;
			return;
		} /* else */

	/* anything left at this point is 28th of Feb -- test for leap year */
	if (isleap(1900 + year))
	{
		day = 29;
		return;
	}/* if */
	else
	{
		day = 1;
		month = cur_month +1;
	} /* else */

}/* get_tomorrow */


isleap(lyear)
int lyear;

/****************************************************************************/
/* linwood's: returns TRUE if the year is a leap year and FALSE if it isn't */
/****************************************************************************/

{
	if (lyear % 4 != 0)	return(0);	/* not a leap year */
	if (lyear % 100 != 0)	return(1);	/* is a leap year  */
	if (lyear % 400 != 0)	return(0);	/* not a leap year */
	return(1);				/* a leap year  */
} /* isleap */


int check_cur()

/*****************************************************************************/
/* this makes sure that the user's time choice is not before the current time*/
/* if it is it resets the time choice to be the current time                 */
/* true is returned if a change had to be made                               */
/*****************************************************************************/

{
	int	cmp1, cmp2;


	if (month > this_month)		/* check for later month */
		return(FALSE);

	if (day > this_day)		/* check for later day */
		return(FALSE);
	/* everything from here on is the same day */
	
	if ((!this_meridian) && (meridian))	/* check am's and pm's */
		return(FALSE);

	if ((this_meridian) && (!meridian))
	{
		meridian = this_meridian;
		return(TRUE);
	} /* if */

	if (hour == 12)			/* easier comparisons */
		cmp1 = 0;
	else
		cmp1 = hour;

	if (this_hour == 12)
		cmp2 = 0;
	else
		cmp2 = this_hour;

	if (cmp1 > cmp2)		/* check for later hour */
		return(FALSE);

	if (cmp1 < cmp2)
	{
		hour = this_hour;
		min  = this_min;
		return(TRUE);
	} /* if */

	/* anything left is in the same hour */

	if (min >= this_min)		/* check for later minute */
		return(FALSE);

	min = this_min;	
	return(TRUE);
} /* check_cur */


int inq_month_days(mo, yr)

int mo;
int yr;

/**************************************************************************/
/* this routine finds the number of days in the the month month           */
/**************************************************************************/

{
	if (mo == 2)
	  if (isleap(1900 + yr))
		return(29);
	  else
		return(28);
	else
	if ((mo == 1) || (mo == 3) || (mo == 5) ||
	   (mo == 7) || (mo == 8) || (mo == 10) ||
	   (mo == 12))
		return(31);
	else
		return(30);
} /* inq_month_days */



int get_date(fp)

Form  fp;	/* form pointer */

/****************************************************************************/
/* this routine gets the current date and reflects it on the date form      */
/* it returns the maximum number of days for the month                      */
/****************************************************************************/

{
	char datestr[3];
	char monstr[11];
	char *cp;

	/* set the current month */
	if (this_month > 6)
		FIfld_set_active_row(fp, MONTHS, this_month-1, 4);

	FIfld_set_select(fp, MONTHS, this_month-1, 0, TRUE);
	
	strcpy(monstr, months[this_month-1]);
	for (cp = &monstr[1]; *cp; cp++)
	    *cp = tolower(*cp);

	FIfld_set_text(fp, MON_FIELD, 0, 0, monstr, FALSE);

	/* set the current date */
	sprintf(datestr, "%02d", this_day);
	FIg_set_value(fp, DATEDIAL, (double)this_day);
	FIfld_set_text(fp, DATE_FIELD, 0, 0, datestr, FALSE);

	return(inq_month_days(this_month, this_year));
} /* get_date */

