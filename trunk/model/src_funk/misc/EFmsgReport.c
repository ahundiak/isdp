/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
NAME

EFmsgReport, EFtestSevLvl, EFsetSevLvl, EFgetSevLvl -- message printing

SYNOPSIS

int EFmsgReport (fp, code, string)
FILE *fp;
EMSrc code;
char string[];

int EFtestSevLvl (code)
EMSrc code;

void EFsetSevLvl (level)
int level;

int EFgetSevLvl ()

DESCRIPTION

EFmsgReport prints a message referring to code and string in
stream fp if the severity of code is greater than or equal to the
current minimum severity level for reporting.

EFtestSevLvl returns a value based upon a comparison the the
severity level of code and the severity of minSeverity.
EFtestSevLvl returns 1 if the severity level of code is greater
than that of the current minimum severity level for reporting. 
EFtestSevLvl returns 0 if the levels are the same and -1
otherwise.

EFcmpSevLvl is what EFtestSevLvl calls to compare severity
levels.

EFsetSevLvl causes the minimum severity level for reporting to be
set.

EFgetSevLvl returns the current minimum severity level for
reporting.

HISTORY

11-Feb-1988 jBk Broke comparison out of EFtestSevLvl to become
                EFcmpSevLvl.
09-Feb-1988 jBk Added global variable and function to check it
                thereof to see if messages need to be printed.
??-???-1987 jBk Genesis.
*/

# include <stdio.h>         /* FILE */
# include "EMSlogic.h"      /* EMSerror */
# include "EMStypedef.h"    /* EMSrc */
# include "EMSmsgassist.h"  /* EMS_SevLvl ... */

int EFmsgReport (fp, code, string)
FILE *fp;
EMSrc code;
char string[];
{
    int EFtestSevLvl ();
    extern unsigned int OM_Gf_verbose_warning;

/******** SM Sept 3, 1992.    
    if (!ems_do_print_error_messages && !OM_Gf_verbose_warning)
    {
      return(code);
    }
**********/

/****DLB - removed reference to ems_do_print_error_messages 12/8/92*****/
    if (!OM_Gf_verbose_warning)
    {
      return(code);
    }

    if (EFtestSevLvl (code) ISNT -1)
    {
        EMSrc EFprintcode ();
        int EFfprints ();

        (void)EFprintcode (fp, code);
        (void)EFfprints (fp, " ");
        (void)EFfprints (fp, string);
        (void)EFfprints (fp, "\n");
    }

    return EMSerror (code);
}

static int minSeverity = 1;
static severities[] = {2, 0, 3, 1, 4, 997, 998, 999};
/*
The definition of severities depends on the values of WARN, SUCC,
ERRO, INFO and FATL.  They are currently 0, 1, 2, 3 and 4,
respectively.  In the severities array, they are assigned
corresponding importance ranging from least important, SUCC, to
most important, FATL.  The other severity priorties (for
severities 5, 6 and 7) are filled in, but represent undefined
severity levels.
*/

int EFtestSevLvl (code)
EMSrc code;
{
    return EFcmpSevLvl (EMS_SeverityLevel (code), minSeverity);
}

int EFcmpSevLvl (seva, sevb)
int seva, sevb;
{
    int returnvalue = 0;

    if (severities[seva] > severities[sevb])
    {
        returnvalue = 1;
    }
    else if (severities[seva] < severities[sevb])
    {
        returnvalue = -1;
    }

    return returnvalue;
}

void EFsetSevLvl (level)
int level;
{
    minSeverity = level;

    return;
}

int EFgetSevLvl ()
{
    return minSeverity;
}
