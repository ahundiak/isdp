#include "main.h"

int	month;		/* the date to do the loading */
int	day;
int	year;

int	maxdays;
int	when = NOW;	/* do it now by default, other values = TODAY, TOMORROW, SPECDATE */

Form	dateform;

short	st_group_enabled;
short	sd_group_enabled;

extern	int	this_month;  /* current date */
extern	int	this_day;
extern	int	this_year;

extern  int	hour;	/* the time to do the loading */
extern  int	min;
extern  int	meridian;

extern	Form	rem_delform;
extern	Form	rem_infoform;
extern	Form	timeform;

char *months[12] = {
	"JANUARY",
	"FEBRUARY",
	"MARCH",
	"APRIL",
	"MAY",
	"JUNE",
	"JULY",
	"AUGUST",
	"SEPTEMBER",
	"OCTOBER",
	"NOVEMBER",
	"DECEMBER"
};

/****************************************************************************/
/* this file contains                                                       */
/*									    */
/*  date_note		notification routine for the date form              */
/*  time_note		notification routine for the time form              */
/****************************************************************************/


#ifdef OBSOLETE

date_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

/*****************************************************************************/
/* this is the notification routine for the date form                        */
/*****************************************************************************/

{
	int  sts;
	int  row, pos;
	double num;
	int  selflag;

	switch (g_label)
	{
	 case FI_CANCEL:
	 case FI_ACCEPT:
		FIg_enable(timeform, 24);   /* group 24 has today, tomorrow & spec */
		FIg_enable(timeform, FI_CANCEL);
		FIg_enable(timeform, FI_ACCEPT);
		sts=FIf_erase(fp);
		if(chkerror(sts, "erasing form"))
			return;
		break;

	 case MONTHS:
	 case DATEDIAL:
		FIfld_get_select(fp, MONTHS, this_month-1, 0, &selflag);
		if (selflag) {
			month = this_month;
			row = month - 1;
		}
		else {
			FIfld_get_active_row(fp, MONTHS, &row, &pos);
			FIfld_get_select(fp, MONTHS, row, 0, &selflag);
			if (!selflag)  /* nothing is selected so select it */
				FIfld_set_select(fp, MONTHS, row, 0, TRUE);
			month = row + 1;
		} /* else */

		maxdays = inq_month_days(month, year);

		FIg_get_value(fp, DATEDIAL, &num);
		day = (int)num;

		if ((day > maxdays) || (day == 0))
		{
			FIg_set_value(fp, DATEDIAL, (double)maxdays);
			day = maxdays;
		}/* if */

		/* test if date if before current -- increase to next year */
		if (month < this_month)
			year = this_year +1;
		else
			if ((month == this_month) && 
			    (day < this_day))
				year = this_year +1;
			else
				year = this_year;
		break;
	} /* switch */
} /* date_note */

#endif

/*ARGSUSED*/
time_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

/****************************************************************************/
/* this is the notification routine for the date/time form                  */
/****************************************************************************/

{
	int  	sts;
	int  	row, pos;
	int  	selflag, r_pos;
	int	i;
	char	*cp;
	char	hourstr[3], minstr[3];
	char	monstr[11], datestr[3];
	double	num;
	char	path[MAXPATHLEN];

	switch (g_label)
	{
	 case MONTHS:
	 case DATEDIAL:
		FIfld_get_select(fp, MONTHS, this_month-1, 0, &selflag);
		if (selflag) {
			month = this_month;
			row = month - 1;
		} else {
			FIfld_get_active_row(fp, MONTHS, &row, &pos);
			FIfld_get_select(fp, MONTHS, row, 0, &selflag);
			if (!selflag)  /* nothing is selected so select it */
				FIfld_set_select(fp, MONTHS, row, 0, TRUE);
			month = row + 1;
		}

		FIfld_get_text(fp, MONTHS, row, pos, 11, monstr, &selflag, &r_pos);
		FIfld_set_text(fp, MON_FIELD, 0, 0, monstr, FALSE);

		maxdays = inq_month_days(month, year);

		FIg_get_value(fp, DATEDIAL, &num);
		day = (int)num;

		if ((day > maxdays) || (day == 0))
		{
			FIg_set_value(fp, DATEDIAL, (double)maxdays);
			day = maxdays;
		}/* if */

		sprintf(datestr, "%02d", day);
		FIfld_set_text(fp, DATE_FIELD, 0, 0, datestr, FALSE);

		/* test if date if before current -- increase to next year */
		if (month < this_month)
			year = this_year +1;
		else {
			if ((month == this_month) && 
			    (day < this_day))
				year = this_year +1;
			else
				year = this_year;
		}
		display_rem_date(rem_infoform);
		break;

	 case HDIAL:      /* hour dial */
		FIg_get_value(fp, HDIAL, &num);
		hour = (int)num;
		if (hour == 0)
			hour = 12;
		if (check_cur())
			FIg_set_value(fp, HDIAL, (double)hour);

		sprintf(hourstr, "%02d", hour);
		FIfld_set_text(fp, HFIELD, 0,0, hourstr, FALSE);
		display_rem_date(rem_infoform);
		break;

	 case MDIAL:  /* minute dial */
		FIg_get_value(fp, MDIAL, &num);
		min = (int)num;

		if (check_cur())
			FIg_set_value(fp, MDIAL, (double)min);

		sprintf(minstr, "%02d", min);
		FIfld_set_text(fp, MFIELD, 0,0, minstr, FALSE);
		display_rem_date(rem_infoform);
		break;

	 case HFIELD:  /* they entered an hour */
		sts = FIg_get_text(fp, HFIELD, hourstr);
		if (chkerror(sts, "getting the entered text"))
			return;
		hour = atoi(hourstr);
		check_cur();
		FIg_set_value(fp, HDIAL, (double)hour);
		display_rem_date(rem_infoform);
		break;

	 case MFIELD:  /* they entered a minute */
		sts = FIg_get_text(fp, MFIELD, minstr);
		if (chkerror(sts, "getting the entered text"))
			return;
		min = atoi(minstr);
		check_cur();
		FIg_set_value(fp, MDIAL, (double)min);
		display_rem_date(rem_infoform);
		break;

	 case MON_FIELD:	/* They entered a month */
		sts = FIg_get_text(fp, MON_FIELD, monstr);
                if (chkerror(sts, "getting the entered text"))
                        return;

		/* Convert the obtained string to upper case */
		for (i = 0; monstr[i] != '\0'; i++)
		    monstr[i] = toupper(monstr[i]);

		/* Check it against each of the month names */
		for (i = 0; i < 12; i++) {
		    if (strncmp(monstr, months[i], strlen(monstr)) == 0)
			break;
		}
		if (i == 12) {
		    /* Doesn't match any of the accepted month names */
		}
		
		month = i + 1;
		FIfld_set_select(fp, MONTHS, i, 0, TRUE);

		when = SPECDATE;
		display_rem_date(rem_infoform);
		
		break;

	 case DATE_FIELD:	/* They entered a date */
		sts = FIg_get_text(fp, DATE_FIELD, datestr);
		if (chkerror(sts, "getting the entered text"))
			return;

		day = atoi(datestr);
		maxdays = inq_month_days(month, year);

                if ((day > maxdays) || (day == 0))
                {
                        FIg_set_value(fp, DATEDIAL, (double)maxdays);
                        day = maxdays;
                }/* if */

                FIg_set_value(fp, DATEDIAL, (double)day);

		check_cur();
		when = SPECDATE;
		display_rem_date(rem_infoform);

		break;

	 case MERIDIAN:   /* the am/pm toggle */
		FIg_get_value(fp, MERIDIAN, &num);
		meridian = (int)num;

		if (check_cur()) 
			FIg_set_value(fp, MERIDIAN, (double)meridian);

		display_rem_date(rem_infoform);
		break;

	 case NOW:
		when = NOW;

		get_time(fp);
		get_date(fp);

		/* Disable time and date */
		if (sd_group_enabled) {
		    FIg_disable(fp, SD_GROUP); 
		    sd_group_enabled = 0;
		}
		if (st_group_enabled) {
		    FIg_disable(fp, ST_GROUP);
		    st_group_enabled = 0;
		}
		display_rem_date(rem_infoform);
		break;

	 case TODAY:
		when = TODAY;

		month = this_month;
		day   = this_day;
		year  = this_year;

		if (check_cur())
			get_time(fp);

		/* Update MONTH list and field with new info */
		FIfld_set_select(fp, MONTHS, month-1, 0, TRUE);
		strcpy(monstr, months[month-1]);
		for (cp = &monstr[1]; *cp; cp++)
		    *cp = tolower(*cp);

		FIfld_set_text(fp, MON_FIELD, 0, 0, monstr, FALSE);

		/* Update DATE dial and field with new info */
		FIg_set_value(fp, DATEDIAL, (double)day);
		sprintf(datestr, "%02d", day);
		FIfld_set_text(fp, DATE_FIELD, 0,0, datestr, FALSE);

		/* Enable time, but keep date disabled */
		if (!st_group_enabled) {
		    FIg_enable(fp, ST_GROUP);
		    st_group_enabled = 1;
		}
		if (sd_group_enabled) {
		    FIg_disable(fp, SD_GROUP);
		    sd_group_enabled = 0;
		}
		display_rem_date(rem_infoform);
		break;

	 case TOMORROW:
		when = TOMORROW;

		year  = this_year;
		month = this_month;

		/* value of tomorrow is put in day */
		get_tomorrow(this_month, this_day);

		/* Update MONTH list and field with new info */
		FIfld_set_select(fp, MONTHS, month-1, 0, TRUE);
		strcpy(monstr, months[month-1]);
		for (cp = &monstr[1]; *cp; cp++)
		    *cp = tolower(*cp);

		FIfld_set_text(fp, MON_FIELD, 0, 0, monstr, FALSE);

		/* Update DATE dial and field with new info */
		FIg_set_value(fp, DATEDIAL, (double)day);
	        sprintf(datestr, "%02d", day);
		FIfld_set_text(fp, DATE_FIELD, 0,0, datestr, FALSE);

		/* Enable time, but keep date disabled */
		if (!st_group_enabled) {
		    FIg_enable(fp, ST_GROUP);
		    st_group_enabled = 1;
		}
		if (sd_group_enabled) {
		    FIg_disable(fp, SD_GROUP);
		    sd_group_enabled = 0;
		}
		break;

	 case SPECDATE:
		when = SPECDATE;

		/* Enable time AND date */
		FIg_enable(fp, ST_GROUP);
		st_group_enabled = 1;

		FIg_enable(fp, SD_GROUP);
		sd_group_enabled = 1;

#ifdef REDUNDANT
		FIg_disable(fp, 24);   /* group 24 has today, tomorrow & spec */
		FIg_disable(fp, FI_CANCEL);
		FIg_disable(fp, FI_ACCEPT);

		when = SPECDATE;

		/* put up the form that lets them select a date */
		sprintf(path, "%s/date.form", MYSTUFFDIR);
		sts = FIf_new(DATEFORM, path,
			date_note, &form);
		if (chkerror (sts, "creating form"))
			return;
#ifdef XFORMS
		Set_form_class(form);
#endif
	
		dateform = form;

		sts = FIf_display(form);
		if (chkerror (sts, "displaying form"))
			return;

		maxdays = get_date(form);
#endif
		break;
	} /* switch */
} /* time_note */



display_rem_date(fp)
Form *fp;
{
    char timestr[80];

    if (meridian)
	sprintf(timestr, "%02d:%02dpm %02d-%3.3s-%02d",
	    hour, min, day, months[month-1], year%100);
    else
	sprintf(timestr, "%02d:%02dam %02d-%3.3s-%02d",
	    hour, min, day, months[month-1], year%100);

    FIfld_set_text(fp, INFO_TIME, 0, 0, timestr, FALSE);

}
