#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMschema.h"
#include "DEBUG.h"
#include "ERR.h"

long CVTread_report_search (search_file, search_name, search_str)
   char *search_file;
   char *search_name;
   char **search_str;

{
char str[101];
char search[NFM_REPORTNAME+1];
int  x, atoi ();
FILE *fopen(), *in_file;
static char *fname = "CVTread_report_search";

_NFMdebug ((fname, "Enter.\n"));
_NFMdebug ((fname, "search_file: <%s>\n", search_file));
_NFMdebug ((fname, "search_name: <%s>\n", search_name));

if ((in_file = fopen (search_file, "r")) == 0)
    {
    _NFMdebug ((fname, "Fopen Failed.\n"));
    fprintf (stderr, "Error opening search file <%s>. \n", search_file);
    return (NFM_E_FOPEN);
    } 

if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Read Search Name failure.\n"));
    return (NFM_E_FAILURE);
    }

if (strcmp (str, "SEARCH NAME   :"))
    {
    _NFMdebug ((fname, "Bad Search Name Format.\n"));
    return (NFM_E_FAILURE);
    }

if (! CVTfgets (str, 100, in_file))
    {
    _NFMdebug ((fname, "Read Search Name failure.\n"));
    return (NFM_E_FAILURE);
    }

strcpy (search, str);
if (strcmp (search, search_name))
    {
    _NFMdebug ((fname, "Search Name Mismatch - CONTINUE Anyway.\n    Expecting \
search: <%s>; Got search: <%s>\n", search_name, search));
    }

if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Bad Search Format.\n"));
    return (NFM_E_FAILURE);
    }

if (strcmp (str, "SEARCH STRING :"))
    {
    _NFMdebug ((fname, "Bad Search String Format.\n"));
    return (NFM_E_FAILURE);
    }

if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Bad Search Format.\n"));
    return (NFM_E_FAILURE);
    }

x = atoi (strtok (str, ":")) + 5;

if (x < 20) x = 21;

_NFMdebug ((fname, "Malloc: <%d>.\n", x+1));
*search_str = (char *) malloc (x + 1);
if (! *search_str)
    {
    _NFMdebug ((fname, "Malloc Failure.\n"));
    return (NFM_E_FAILURE);
    }

if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Read Search String Failure.\n"));
    return (NFM_E_FAILURE);
    }

if (strcmp (str, "STRING        :"))
    {
    _NFMdebug ((fname, "Bad Search String Format.\n"));
    return (NFM_E_FAILURE);
    }

if (! CVTfgets (*search_str, x, in_file))
    {
    _NFMdebug ((fname, "Read Search String Failure.\n"));
    return (NFM_E_FAILURE);
    }

fclose (in_file);

_NFMdebug ((fname, "Exit. search_str: <%s>\n", *search_str));

return (NFM_S_SUCCESS);
}


long CVTread_report_sort (sort_file, sort_name, sort_str)
   char *sort_file;
   char *sort_name;
   char **sort_str;

{
char str[101];
int  x, atoi ();
FILE *fopen(), *in_file;
static char *fname = "CVTread_report_sort";

_NFMdebug ((fname, "Enter.\n"));
_NFMdebug ((fname, "sort_file: <%s>\n", sort_file));
_NFMdebug ((fname, "sort_name: <%s>\n", sort_name));

if ((in_file = fopen (sort_file, "r")) == 0)
    {
    _NFMdebug ((fname, "Fopen Failed.\n"));
    fprintf (stderr, "Error opening sort file <%s>. \n", sort_file);
    return (NFM_E_FOPEN);
    } 

str [0] = 0;

memset (str, 0, 100);
if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Read Sort Name Failure.\n"));
    return (NFM_E_FAILURE);
    }

if (strcmp (str, "SORT NAME     :"))
    {
    _NFMdebug ((fname, "Bad Sort Format.\n"));
    return (NFM_E_FAILURE);
    }

memset (str, 0, 100);
if (! CVTfgets (str, 100, in_file))
    {
    _NFMdebug ((fname, "Bad Sort Name.\n"));
    return (NFM_E_FAILURE);
    }

strcpy (sort_name, str);

memset (str, 0, 100);
if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Bad Sort Format.\n"));
    return (NFM_E_FAILURE);
    }

if (strcmp (str, "SORT STRING   :"))
    {
    _NFMdebug ((fname, "Bad Sort Format.\n"));
    return (NFM_E_FAILURE);
    }

memset (str, 0, 100);
if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Bad Sort Format.\n"));
    return (NFM_E_FAILURE);
    }

x = atoi (strtok (str, ":")) + 5;

str [0] = 0;

if (x < 20) x = 21;

_NFMdebug ((fname, "Malloc: <%d>.\n", x+1));
*sort_str = (char *) malloc (x + 1);
if (! *sort_str)
    {
    _NFMdebug ((fname, "Malloc Failure.\n"));
    return (NFM_E_FAILURE);
    }

memset (str, 0, x);
if (! CVTfgets (str, 16, in_file))
    {
    _NFMdebug ((fname, "Bad Sort Format.\n"));
    return (NFM_E_FAILURE);
    }

if (strcmp (str, "STRING        :"))
    {
    _NFMdebug ((fname, "Bad Sort Format.\n"));
    return (NFM_E_FAILURE);
    }

memset (*sort_str, 0, x);
if (! CVTfgets (*sort_str, x, in_file))
    {
    _NFMdebug ((fname, "Bad Sort Format.\n"));
    return (NFM_E_FAILURE);
    }

fclose (in_file);

_NFMdebug ((fname, "Exit. sort_str: <%s>\n", *sort_str));

return (NFM_S_SUCCESS);
}

