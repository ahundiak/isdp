/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intatod.c
**	AUTHORS:						David Michal
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include <sys/types.h>
#include <time.h>
#include "intrface.h"
#include "riscom.h"
#include "ris_inf.h"

/*
**	DEFINES
*/
#define SPECIFIED(x)	(x != -1)

#define	NON_ORD_NUM		1
#define	ORD_NUM			1

#define AM				0
#define PM				1

#define NO_ARG			0
#define DOW_3_MODE		1
#define DOW_FULL_MODE	2
#define HH_24_MODE		1
#define HH_12_MODE		2
#define MON_3_MODE		1
#define MON_FULL_MODE	2
#define YY_4_MODE		1
#define YY_2_MODE		2



/*
** 	TYPES
*/

typedef struct name_s
{
	char	*name;
	int		len;
} name_s;

typedef struct format_data_s
{
	char	*str;
	int		len;
	int		(*func)();
	int		arg;
	char	ord_num;
} format_data_s;

/*
**	FUNCTION PROTOTYPES
*/
#define intatod_c
#include "comdate.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comstcmi.prt"
#include "comumsg.prt"
#include "intatod.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static name_s dow_name[] =
{
	{	"sunday",		6	},
	{	"monday",		6	},
	{	"tuesday",		7	},
	{	"wednesday",	9	},
	{	"thursday",		8	},
	{	"friday",		6	},
	{	"saturday",		8	},
};

static name_s mon_name[] =
{
	{	"",				0	},
	{	"january",		7	},
	{	"february",		8	},
	{	"march",		5	},
	{	"april",		5	},
	{	"may",			3	},
	{	"june",			4	},
	{	"july",			4	},
	{	"august",		6	},
	{	"september",	9	},
	{	"october",		7	},
	{	"november",		8	},
	{	"december",		8	},
};

static	 int	ampm;
static	 int	doy;
static	 int	dow;
static	 int	dd;
static	 int	hh24;
static	 int	hh12;
static	 int	mm;
static	 int	nn;
static	 int	ss;
static	 int	yy;
static	 int	ord_num;
static	 char	err_str[256];
static	 char	ats_str[256];

/*
**	FUNCTIONS
*/


/******************************************************************************/

static void fill_err_str(
	char *msg,
	char *s,
	int len)
{
	int i;
	char *ptr;
	/*
	**	Messages should be in the form:
	**		Expected ....., got \"...\".
	**	This routine will fill in the "got" part.
	*/

	ptr = err_str;
	ptr += sprintf(ptr,"%s, %s \"", msg, RIScom_umsg(RIS_I_GOT));
	for (i = 0; i < len && *s; i++)
	{
		*ptr++ = *s++;
	}
	strcpy(ptr, "\".");
}

/******************************************************************************/

static void calc_date_from_year_doy(
	int year,
	int doy,
	datetime *date)
{
	int month_days;

	date->year = year;
	for (date->month = 1; date->month < 12; date->month++)
	{
		month_days = RIScom_days_in_month(date->month, date->year);
		/*
		**	September 1752 was an unusual month.  That is the month 11 days 
		**	were skipped to make up for lack of leap year adjustments. 
		*/
		if (date->year == 1752 && date->month == 9)
			month_days -= 11;

		if (doy <= month_days) break;
		doy -= month_days;
	}
	date->day = doy;

	if (date->year == 1752 && date->month == 9 && date->day > 2)
		date->day += 11;
}

/******************************************************************************/

static int get_optional_digits(
	int count,
	char *s,
	int *dp)
{
	int sts;

	if (count > 0 && RIScom_isdigit(*s))
	{
		if (count > 1 && RIScom_isdigit(*(s+1)))
		{
			if (count > 2 && RIScom_isdigit(*(s+2)))
			{
				if (count > 3 && RIScom_isdigit(*(s+3)))
				{
					*dp = (* s    - '0') * 1000 +
						  (*(s+1) - '0') * 100 +
						  (*(s+2) - '0') * 10 +
						  (*(s+3) - '0');
					sts = 4;
				}
				else
				{
					*dp = (* s    - '0') * 100 +
						  (*(s+1) - '0') * 10 +
					  	(*(s+2) - '0');
					sts = 3;
				}
			}
			else
			{
				*dp = (* s    - '0') * 10 +
				  	(*(s+1) - '0');
				sts = 2;
			}
		}
		else
		{
			*dp = (*s - '0');
			sts = 1;
		}
	}
	else
	{
		sts = -1;
	}

	return sts;
}

/******************************************************************************/

static int get_ampm(
	char *s)
{
	int sts;
	int l_ampm;

	if (!RIScom_strncmp_ic(s, "a.m.", 4))
	{
		l_ampm = AM;
		sts = 4;
	}
	else if (!RIScom_strncmp_ic(s, "am", 2))
	{
		l_ampm = AM;
		sts = 2;
	}
	else if (!RIScom_strncmp_ic(s, "p.m.", 4))
	{
		l_ampm = PM;
		sts = 4;
	}
	else if (!RIScom_strncmp_ic(s, "pm", 2))
	{
		l_ampm = PM;
		sts = 2;
	}
	else
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_MERIDIAN_INDICATOR), s, 4);
		return -1;
	}

	if (SPECIFIED(ampm))
	{
		if (ampm != l_ampm)
		{
			sprintf(err_str,RIScom_umsg(RIS_I_INCONSISTENT_MERIDIAN));
			return -1;
		}
	}
	else
		ampm = l_ampm;

	return sts;
}

/******************************************************************************/

static int get_doy(
	char *s)
{
	int	sts;
	int l_doy;

	if ((sts = get_optional_digits(3, s, &l_doy)) < 0)
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_DAY_YEAR_FOR), s, 3);
		return -1;
	}

	if (l_doy < 1 || l_doy > 366)
	{
		sprintf(err_str, RIScom_umsg(RIS_I_INVALID_DAY_YEAR_BETWEEN), l_doy);
		return -1;
	}

	if (SPECIFIED(doy))
	{
		if (doy != l_doy)
		{
			sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_DAY_YEAR),
				doy, l_doy);
			return -1;
		}
	}
	else
		doy = l_doy;

	ord_num = l_doy;

	return sts;
}

/******************************************************************************/

static int get_dow(
	char *s,
	int mode)
{
	int len = 0;
	int l_dow;

	for (l_dow = 0; l_dow < 7; l_dow++)
	{
		if (mode == DOW_FULL_MODE)
			len	= dow_name[l_dow].len;
		else
			len = 3;

		if (!RIScom_strncmp_ic(s, dow_name[l_dow].name, len))
		{
			if (SPECIFIED(dow))
			{
				if (dow != l_dow)
				{
					sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_DAY_WEEK),
						dow_name[dow].name, dow_name[l_dow].name);
					return -1;
				}
			}
			else
				dow = l_dow;

			return len;
		}
	}

	fill_err_str(RIScom_umsg(RIS_I_INVALID_DAY_OF_THE_WEEK),s,len);
	return -1;
}

/******************************************************************************/

static int get_dd(
	char *s)
{
	int sts;
	int l_dd;

	if ((sts = get_optional_digits(2, s, &l_dd)) < 0)
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_DAY_MONTH_FOR), s, 2);
		return -1;
	}

	if (l_dd < 1 || l_dd > 31)
	{
		sprintf(err_str, RIScom_umsg(RIS_I_INVALID_DAY_MONTH_BETWEEN), l_dd);
		return -1;
	}

	if (SPECIFIED(dd))
	{
		if (dd != l_dd)
		{
			sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_DAY_MONTH),
				dd, l_dd);
			return -1;
		}
	}
	else
		dd = l_dd;

	ord_num = l_dd;
	return sts;
}

/******************************************************************************/

static int get_hh(
	char *s,
	int mode)
{
	int sts;
	int l_hh;
	int *hhp;
	int max;
	int min;

	if (mode == HH_24_MODE)
	{
		hhp = &hh24;
		min = 0;
		max = 23;
	}
	else
	{
		hhp = &hh12;
		min = 1;
		max = 12;
	}

	if ((sts = get_optional_digits(2, s, &l_hh)) < 0)
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_HOUR_FOR), s, 2);
		return -1;
	}

	if (l_hh < min || l_hh > max)
	{
		sprintf(err_str, RIScom_umsg(RIS_I_INVALID_HOUR_BETWEEN), 
			min, max, l_hh);
		return -1;
	}

	if (SPECIFIED(*hhp))
	{
		if (*hhp != l_hh)
		{
			sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_HOUR), *hhp, l_hh);
			return -1;
		}
	}
	else
		*hhp = l_hh;

	ord_num = l_hh;
	return sts;
}

/******************************************************************************/

static int get_mon(
	char *s,
	int mode)
{
	int l_mm;
	int len = 0; /* _MSDOS initialize it */


	for (l_mm = 1; l_mm <= 12; l_mm++)
	{
		len = (mode == MON_FULL_MODE) ? mon_name[l_mm].len : 3;
		if (!RIScom_strncmp_ic(s, mon_name[l_mm].name, len))
		{
			if (SPECIFIED(mm))
			{
				if (mm != l_mm)
				{
					sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_MONTH), 
						mm, mon_name[mm].name, l_mm, mon_name[l_mm].name);
					return -1;
				}
			}
			else
				mm = l_mm;

			return len;
		}
	}

	fill_err_str(RIScom_umsg(RIS_I_INVALID_MONTH_NAME), s, len);
	return -1;
}

/******************************************************************************/

static int get_mm(
	char *s)
{
	int sts;
	int l_mm;

	if ((sts = get_optional_digits(2, s, &l_mm)) < 0)
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_MONTH_NUMBER), s, 2);
		return -1;
	}

	if (l_mm < 1 || l_mm > 12)
	{
		sprintf(err_str, RIScom_umsg(RIS_I_INVALID_MONTH_BETWEEN), l_mm);
		return -1;
	}

	if (SPECIFIED(mm))
	{
		if (mm != l_mm)
		{
			sprintf(err_str,RIScom_umsg(RIS_I_INCONSISTENT_VALUES_FOR_MONTH), 
				mm, l_mm);
			return -1;
		}
	}
	else
		mm = l_mm;

	ord_num = l_mm;
	return sts;
}

/******************************************************************************/

static int get_nn(
	char *s)
{
	int sts;
	int l_nn;

	if ((sts = get_optional_digits(2, s, &l_nn)) < 0)
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_MINUTE_FOR), s, 2);
		return -1;
	}

	if (l_nn < 0 || l_nn > 59)
	{
		sprintf(err_str, RIScom_umsg(RIS_I_INVALID_MINUTE_BETWEEN), l_nn);
		return -1;
	}

	if (SPECIFIED(nn))
	{
		if (nn != l_nn)
		{
			sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_MINUTES), nn, l_nn);
			return -1;
		}
	}
	else
		nn = l_nn;

	ord_num = l_nn;
	return sts;
}

/******************************************************************************/

static int get_ss(
	char *s)
{
	int sts;
	int l_ss;

	if ((sts = get_optional_digits(2, s, &l_ss)) < 0)
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_SECOND_FOR), s, 2);
		return -1;
	}

	if (l_ss < 0 || l_ss > 59)
	{
		sprintf(err_str, RIScom_umsg(RIS_I_INVALID_SECOND_BETWEEN), l_ss);
		return -1;
	}

	if (SPECIFIED(ss))
	{
		if (ss != l_ss)
		{
			sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_SECOND), ss, l_ss);
			return -1;
		}
	}
	else
		ss = l_ss;

	ord_num = l_ss;
	return sts;
}

/******************************************************************************/

static int get_yy(
	char *s,
	int mode)
{
	int sts;
	int len;
	int max;
	int l_yy;
	int century;
	time_t clck;
	struct tm *tm;

	if (mode == YY_4_MODE)
	{
		len = 4;
		max = 9999;
	}
	else
	{
		len = 2;
		max = 99;
	}

	if ((sts = get_optional_digits(len, s, &l_yy)) < 0)
	{
		fill_err_str(RIScom_umsg(RIS_I_INVALID_YEAR_FOR), s, len);
		return -1;
	}

	if (l_yy < 0 || l_yy > max)
	{
		sprintf(err_str,RIScom_umsg(RIS_I_INVALID_YEAR_BETWEEN), max, l_yy);
		return -1;
	}

	if (mode == YY_2_MODE)
	{
		clck = time((long *)0);
		tm = localtime(&clck);
		century = (tm->tm_year+1900)/100;
		l_yy += (century*100);
	}

	if (SPECIFIED(yy))
	{
		if (yy != l_yy)
		{
			sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_YEAR), yy, l_yy);
			return -1;
		}
	}
	else
		yy = l_yy;

	ord_num = l_yy;
	return sts;
}

/******************************************************************************/

static int get_th(
	char *s)
{
	char *suffix;
	char msg[80];

	switch(ord_num % 100)
	{
		case 11: case 12: case 13:
			suffix = "th";
			break;

		default:
			switch(ord_num % 10)
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
				default:
					suffix = "th";
					break;
			}
			break;
	}

	if (!RIScom_strncmp_ic(s, suffix, 2))
		return 2;

	sprintf(msg,RIScom_umsg(RIS_I_INVALID_ORDINAL_SUFFIX), suffix);
	fill_err_str(msg, s, 2);
	return -1;
}

/******************************************************************************/

static void add_days(
	datetime *date,
	int days)
{
	unsigned int month_days;
	
	date->day += days;
	month_days = RIScom_days_in_month(date->month, date->year);
	if (date->day > month_days)
	{
		date->day -= month_days;
		date->month++;
		if (date->month > 12)
		{
			date->month = 1;
			date->year++;
		}
	}
}

/******************************************************************************/

static format_data_s format_data[] =
{
	{ "a.m.",	4,	get_ampm,	NO_ARG,			NON_ORD_NUM },
	{ "p.m.",	4,	get_ampm,	NO_ARG,			NON_ORD_NUM },
	{ "am",		2,	get_ampm,	NO_ARG,			NON_ORD_NUM },
	{ "pm",		2,	get_ampm,	NO_ARG,			NON_ORD_NUM },

	{ "ddd",	3,	get_doy,	NO_ARG,			ORD_NUM		},
	{ "day",	3,	get_dow,	DOW_FULL_MODE,	NON_ORD_NUM },
	{ "dy",		2,	get_dow,	DOW_3_MODE,		NON_ORD_NUM },
	{ "dd",		2,	get_dd,		NO_ARG,			ORD_NUM		},
	{ "d",		1,	get_dd,		NO_ARG,			ORD_NUM 	},

	{ "hh24",	4,	get_hh,		HH_24_MODE,		ORD_NUM 	},
	{ "h24",	3,	get_hh,		HH_24_MODE,		ORD_NUM 	},
	{ "hh12",	4,	get_hh,		HH_12_MODE,		ORD_NUM 	},
	{ "h12",	3,	get_hh,		HH_12_MODE,		ORD_NUM 	},
	{ "hh",		2,	get_hh,		HH_12_MODE,		ORD_NUM 	},
	{ "h",		1,	get_hh,		HH_12_MODE,		ORD_NUM 	},

	{ "month",	5,	get_mon,	MON_FULL_MODE,	ORD_NUM 	},
	{ "mon",	3,	get_mon,	MON_3_MODE,		ORD_NUM 	},
	{ "mm",		2,	get_mm,		NO_ARG,			ORD_NUM 	},
	{ "m",		1,	get_mm,		NO_ARG,			ORD_NUM 	},

	{ "nn",		2,	get_nn,		NO_ARG,			ORD_NUM 	},
	{ "n",		1,	get_nn,		NO_ARG,			ORD_NUM 	},

	{ "ss",		2,	get_ss,		NO_ARG,			ORD_NUM 	},
	{ "s",		1,	get_ss,		NO_ARG,			ORD_NUM 	},

	{ "yyyy",	4,	get_yy,		YY_4_MODE,		ORD_NUM 	},
	{ "yy",		2,	get_yy,		YY_2_MODE,		ORD_NUM 	},
	{ "y",		1,	get_yy,		YY_4_MODE,		ORD_NUM 	},
};
static	int		format_data_cnt = sizeof(format_data)/sizeof(format_data_s);

/******************************************************************************/

extern char * RISAPI RISXascii_to_datetime(
	datetime *date,
	char *buffer,
	char *format)
{
	int i;
	int	sts;
	int hh;
	int data_specified;
	time_t clck;
	struct tm *tm;
	char *fptr;
	char *sptr;
	format_data_s	*fdp;
	datetime	doy_date;

	INT_DBG(("RISascii_to_datetime(date:0x%x buffer:0x%x: format:0x%x)\n",
			date, buffer, format));

	ampm = -1;
	doy = -1;
	dow = -1;
	dd = -1;
	hh24 = -1;
	hh12 = -1;
	mm = -1;
	nn = -1;
	ss = -1;
	yy = -1;

	fptr = format;
	sptr = buffer;

	while(*fptr)
	{
		if (!*sptr)
		{
		    strcpy(ats_str, RIScom_umsg(RIS_I_UNEXPECTED_END_OF_LINE));
        	return ats_str;
		}

		ord_num = -1;

		for (i = 0, fdp = format_data; i < format_data_cnt; i++, fdp++)
		{
			if (!RIScom_strncmp_ic(fptr, fdp->str, fdp->len))
			{
				if (fdp->arg == NO_ARG)
					sts = fdp->func(sptr);
				else
					sts = fdp->func(sptr,fdp->arg);

				if (sts < 0)
					return err_str;

				sptr += sts;
				fptr += fdp->len;

				break;
			}
		}

		if (i == format_data_cnt)
		{
			/*
			**	Literal
			*/
			switch(*fptr)
			{
				case '\'':
					fptr++;
					if (*fptr == '\'')
					{
						if (*sptr != *fptr)
						{
							sprintf(err_str, RIScom_umsg(RIS_I_EXPECTED),
								*fptr, *sptr);
							return err_str;
						}
						sptr++;
						fptr++;
						break;
					}

					while (*fptr)
					{
						if (*fptr == '\'')
						{
							fptr++;
							if (*fptr == '\'')
							{
								if (*sptr != *fptr)
								{
									sprintf(err_str,RIScom_umsg(RIS_I_EXPECTED),
										*fptr, *sptr);
									return err_str;
								}
								sptr++;
								fptr++;
							}
							else
							{
								break;
							}
						}
						else
						{
							if (*sptr != *fptr)
							{ 
								sprintf(err_str, RIScom_umsg(RIS_I_EXPECTED),
									*fptr, *sptr);
								return err_str;
							}
							sptr++;
							fptr++;
						}
					}
					break;

				case ' ':
				case '\t':
				case '\n':
					while(*sptr && RIScom_isspace(*sptr))
						sptr++;
					fptr++;	
					break;

				default:
					if (*sptr != *fptr)
					{
						sprintf(err_str, RIScom_umsg(RIS_I_EXPECTED),
							*fptr, *sptr);
						return err_str;
					}
					sptr++;
					fptr++;
					break;
			}
		}
	
		if (ord_num != -1)
		{
			if (!RIScom_strncmp_ic(fptr,"th",2))
			{
				if ((sts = get_th(sptr)) < 0)
					return err_str;
				sptr += sts;
				fptr += 2;
			}
		}
	}

	if (*sptr)
	{
		fill_err_str(RIScom_umsg(RIS_I_EXPECTED_END_OF_INPUT), sptr, 100);
		return err_str;
	}

	data_specified = 0;
	clck = time((long *)0);
	tm = localtime(&clck);

	/*
	**	Year
	*/
	if (SPECIFIED(yy))
	{
		data_specified = 1;
		date->year = yy;
	}
	else
	{
		date->year = tm->tm_year + 1900;
	}

	/*
	**	Day of year
	*/
	if (SPECIFIED(doy))
	{
		calc_date_from_year_doy(date->year, doy, &doy_date);
		data_specified = 1;
	}
	
	/*
	**	Month
	*/
	if (SPECIFIED(mm))
	{
		if (SPECIFIED(doy) && (unsigned int)mm != doy_date.month)
		{
        	strcpy(ats_str, RIScom_umsg(RIS_I_HAVE_CONFLICTING_VALUES));
        	return ats_str;
		}

		data_specified = 1;
		date->month = mm;
	}
	else
	{
		if (SPECIFIED(doy))
			date->month = doy_date.month;
		else if (data_specified)
			date->month = 1; 
		else
			date->month = tm->tm_mon + 1;
	}

	/*
	**	Day
	*/
	if (SPECIFIED(dd))
	{
		if (SPECIFIED(doy) && (unsigned int)mm != doy_date.month)
		{
        	strcpy(ats_str, RIScom_umsg(RIS_I_HAVE_CONFLICTING_VALUES));
        	return ats_str;
		}
		data_specified = 1;
		date->day = dd;
	}
	else
	{
		if (SPECIFIED(doy))
			date->day = doy_date.day;
		else if (data_specified)
			date->day = 1; 
		else
			date->day = tm->tm_mday;
	}

	/*
	**	Day of the week
	*/
	if (SPECIFIED(dow))
	{
		int l_dow;
		int diff;

		l_dow = RIScom_calc_dow(date);
		if (l_dow != dow)
		{
			diff = dow - l_dow;
			if (diff < 0) diff += 7;
			add_days(date, diff);
			data_specified = 1;
		}
	}

	/*
	**	Hour
	*/
	if (SPECIFIED(hh12))
	{
		hh = hh12;
		if (ampm == PM)
			hh += 12;

		if (SPECIFIED(hh24))
		{
			if (hh24 != hh)
			{
				sprintf(err_str, RIScom_umsg(RIS_I_INCONSISTENT_HOUR),
					hh24, hh);
				return err_str;
			}
		}
		else
			hh24 = hh;
	}
	if (SPECIFIED(hh24))
	{
		data_specified = 1;
		date->hour = hh24;
	}
	else
	{
		if (data_specified)
			date->hour = 0; 
		else
			date->hour = tm->tm_hour;
	}

	/*
	**	minute
	*/
	if (SPECIFIED(nn))
	{
		data_specified = 1;
		date->minute = nn;
	}
	else
	{
		if (data_specified)
			date->minute = 0; 
		else
			date->minute = tm->tm_min;
	}

	/*
	**	second
	*/
	if (SPECIFIED(ss))
	{
		date->second = ss;
	}
	else
	{
		if (data_specified)
			date->second = 0; 
		else
			date->second = tm->tm_sec;
	}

	if (RIScom_invalid_date(date))
	{
    	strcpy(ats_str, RIScom_umsg(RIS_I_INVALID_DATE));
    	return ats_str;
	}

	return NULL;
}

#ifdef TESTING

main()
{
	char *sts;
	char s[80];
	static char format[80] = "";
	static char data[80] = "";
	datetime date;

	while(1)
	{
		printf("\n%s <%s>:\n",
			RIScom_umsg(RIS_I_ENTER_A_FORMAT_STRING), format);
		RIScom_gets(s);
		if (*s) strcpy(format, s);
        printf("%s <%s>:\n",
        	RIScom_umsg(RIS_I_ENTER_A_DATA_STRING), data);
		RIScom_gets(s);
		if (*s) strcpy(data, s);

		if ((sts = RISascii_to_datetime(&date, data, format)) != NULL)
		{
			printf("%s:%s\n", RIScom_umsg(RIS_I_ERROR), sts);
		}
		else
		{
			printf("date.year:%d\n", date.year);
			printf("date.month:%d\n", date.month);
			printf("date.day:%d\n", date.day);
			printf("date.hour:%d\n", date.hour);
			printf("date.minute:%d\n", date.minute);
			printf("date.second:%d\n", date.second);
		}

	}
}
#endif
