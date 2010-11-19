/* ===============================================================
 * Way too much nonsense in here
 * See if it can be completely replaced
 *
 * 19 Nov 2010
 * Started to convert to a more reasonable format but gave up after awhile
 * Need a nice test case for this
 */

#define OS_SOLARIS

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <glib.h>

#include "UMS.h"
#include "pums_pub.h"

#include "ERR.h"
#include "DEBUG.h"
#include "NFIerrordef.h"
#include "NFMerrordef.h"
#include "UTIerrordef.h"

/*  Global I/NFM error structure  */

struct _ERRstruct _ERRstruct =
{ NFI_S_SUCCESS, NULL,
  NFM_S_SUCCESS, NULL,
  NET_S_SUCCESS, NULL,
  NET_S_SUCCESS, NULL,
  NFM_S_SUCCESS, NULL,
  NFM_S_SUCCESS, NULL,
  SQL_S_SUCCESS, NULL,
  MEM_S_SUCCESS, NULL,
  UTI_S_SUCCESS, NULL };

/***********************************************************************

 This function loads the I/NFM error structure argc and argv members
 with the variables passed in.  All dynamic memory allocation and
 deallocation is taken care of.  Subsequent calls to this function
 for the same subsystem will result in previously loaded data being
 overwritten.

 Return values:

  ERR_S_SUCCESS           -  Successful completion
  ERR_I_OVERWRITE         -  Previously loaded data for this subsystem
                             was overwritten
  ERR_E_MALLOC            -  Error allocating dynamic memory
  ERR_E_INVALID_INPUT     -  Invalid input arguments


 Sample calls:

  {
    long      status;

    status = ERRload_struct (NFM, NFM_E_BAD_SEARCH,
        "%s%s%s%s", catalog, item, rev, search_name);
    if (status != ERR_S_SUCCESS)
        _NFMdebug (fname, "ERRload_struct = <%ld>\n", status);
    return (NFM_E_BAD_SEARCH);
  }

  {
    long      status;

    status = ERRload_struct (SQL, SQL_E_QUERY, "%s", sqlca.sqlerrm);
    if (status != ERR_S_SUCCESS)
        _SQLdebug (fname, "ERRload_struct = <%ld>\n", status);
    return (SQL_E_QUERY);
  }

************************************************************************/

long ERRload_struct (int type, long status, char *format, ...)
{
  char       *token_fmt = NULL;
  long       ERRstatus;
  va_list    vars;

  long       _ERRload_arguments ();
  static     char *fname = "ERRload_struct";

  _ERRdebug ((fname, "type = <%d>\n", type));
  _ERRdebug ((fname, "status = <0x%.8x>\n", status));

  if (format != NULL)
  {
    _ERRdebug ((fname, "format = <%s>\n", format));

    /*  Copy the input format so that
        it won't be destroyed by strtok - Glenn 6/18/91  */

    token_fmt = g_malloc(strlen(format) + 1);

    strcpy (token_fmt, format);
  }
  va_start (vars, format);

  switch (type)
   {
        case NFI:
            _ERRstruct.NFIstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.NFIargv), vars);
            break;

        case NFMR:
            _ERRstruct.NFMRstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.NFMRargv), vars);
            break;

        case NETC:
            _ERRstruct.NETCstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.NETCargv), vars);
            break;

        case NETS:
            _ERRstruct.NETSstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.NETSargv), vars);
            break;

        case NFMS:
            _ERRstruct.NFMSstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.NFMSargv), vars);
            break;

        case NFM:
            _ERRstruct.NFMstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.NFMargv), vars);
            break;

        case SQL:
            _ERRstruct.SQLstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.SQLargv), vars);
            break;

        case MEM:
            _ERRstruct.MEMstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.MEMargv), vars);
            break;

        case UTI:
            _ERRstruct.UTIstatus = status;
            ERRstatus = _ERRload_arguments
                (token_fmt, &(_ERRstruct.UTIargv), vars);
            break;

        default:
            _ERRdebug ((fname, "invalid subsystem specified <%d>\n", type));
            va_end (vars);
            g_free (token_fmt);
            _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
                ERR_E_INVALID_INPUT));
            return (ERR_E_INVALID_INPUT);
      }

  _ERRdebug ((fname, "ending argument list ...\n"));

  va_end (vars);
  g_free (token_fmt);

  if (ERRstatus != ERR_S_SUCCESS)
  {
    _ERRdebug ((fname, "_ERRload_arguments = <0x%.8x>\n", ERRstatus));
    _ERRdebug ((fname, "returning <0x%.8x>\n", ERRstatus));
    return (ERRstatus);
  }

  _ERRdebug ((fname, "returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
  return (ERR_S_SUCCESS);
}

long _ERRload_arguments (format, arg_array, vars)
  char      *format;      /*  i   - printf () format specification
                                    for variables to be loaded     */
  char      ***arg_array; /*  i/o - array to store arguments in    */
  va_list   vars;         /*  i   - variables to be loaded in the
                                    I/NFM error structure          */
{
    int     i;
    int     size = 0;
    int     argc = 0;
    long    int_arg = 0;
    char    *token = NULL;
    char    **argv = NULL;
    char    char_arg = NULL;
    char    *str_arg = NULL;
    double   dbl_arg = 0.0;

    long    ERRstatus = ERR_S_SUCCESS;

    static    char *fname = "_ERRload_arguments";

    /*  Save the pointer to work with  */

    argv = *arg_array;

    if (format != NULL)
      {
        /*  The macro expands to more than 1 line  */

        _ERRdebug ((fname, "format = <%s>\n", format));
      }
    else
      {
        /*  The macro expands to more than 1 line  */

        _ERRdebug ((fname, "format is NULL\n"));
      }

    _ERRdebug ((fname, "argv = <%d>\n", argv));

    /*  Check to see if space is already allocated for the subsystem;
        If it is, free all arguments, free argv[] and set to NULL  */

    if (argv != NULL)
      {
        _ERRdebug ((fname, "freeing up argv[] ...\n"));

        /*  Free up the previous argument list  */

        for (i = 1; i <= (int) argv[0]; ++i)
            if (argv[i]) free (argv[i]);

        /*  Free up the array  */

        if (argv) free (argv);
        argv = NULL;

        ERRstatus = ERR_I_OVERWRITE;
      }

    /*  Scan the format string for number of
        arguments; NULL or "" if no arguments  */

    _ERRdebug ((fname, "checking format string ...\n"));

    if (format == NULL)
      {
        _ERRdebug ((fname, "format string is NULL\n"));
        *arg_array = argv;
        _ERRdebug ((fname, "returning <0x%.8x>\n", ERRstatus));
        return (ERRstatus);
      }
    else if ((strcmp (format, "")) == 0)
      {
        _ERRdebug ((fname, "format string is empty\n"));
        *arg_array = argv;
        _ERRdebug ((fname, "returning <0x%.8x>\n", ERRstatus));
        return (ERRstatus);
      }

    /*  Find the number of arguments  */

    _ERRdebug ((fname, "getting argument count ...\n"));

    for (i = 0, argc = 0; i < strlen (format); ++i)
        if (format[i] == '%') ++argc;

    _ERRdebug ((fname, "argc = <%d>\n", argc));

    /*  Allocate space for the arguments  */

    _ERRdebug ((fname, "allocating space for array; size = <%d>\n",
        (argc + 1) * sizeof (char *)));

    if ((argv = (char **) malloc ((argc + 1) * sizeof (char *))) == NULL)
      {
        _ERRdebug ((fname, "malloc failed; size = <%d>\n",
            (argc + 1) * sizeof (char *)));
        *arg_array = argv;
        _ERRdebug ((fname, "returning ERR_E_MALLOC <0x%.8x>\n", ERR_E_MALLOC));
        return (ERR_E_MALLOC);
      }

    /*  Put the number of arguments in the first element  */

    _ERRdebug ((fname, "loading first element ...\n"));

    argv[0] = (char *) argc;

    _ERRdebug ((fname, "beginning to parse argument list ...\n"));

    i = 1;
    token = strtok (format, "%");
    while (token != NULL)
      {
        _ERRdebug ((fname, "token = <%s>\n", token));

        /*  Determine the argument size  */

        switch (token[0])
          {
            case 'l':
            case 'L':
            case 'd':
            case 'D':
            case 'u':
            case 'U':
            case 'x':
            case 'X':
                int_arg = va_arg (vars, long);
                size = 15;
                break;

            case 's':
            case 'S':
                str_arg = va_arg (vars, char *);
              /* size = strlen (str_arg) + 1;*/
              /* The above line is replaced by following 4 lines . As it
                   is resulting in SEGV sometimes. -- for SUN port --.
                   SSRS - 23/11/93
              */
                if(str_arg != NULL)
                    size = strlen (str_arg) + 1;
                else
                    size = 1;
                break;

            case 'f':
            case 'F':
            case 'g':
            case 'G':
                dbl_arg = va_arg (vars, double);
                size = 50;
                break;

            case 'c':
            case 'C':
                char_arg = va_arg (vars, char);
                size = 2;
                break;

            default:
                _ERRdebug ((fname, "unrecognized format <%s>\n", token));
                *arg_array = argv;
                _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
                    ERR_E_INVALID_INPUT));
                return (ERR_E_INVALID_INPUT);
          }

        /*  Allocate space for the argument  */

        _ERRdebug ((fname,
            "allocating space for element %d; size = <%d>\n", i, size));

        if ((argv[i] = (char *) malloc (size)) == NULL)
          {
            _ERRdebug ((fname, "malloc failed; size = <%d>\n", size));
            *arg_array = argv;
            _ERRdebug ((fname,
                "returning ERR_E_MALLOC <0x%.8x>\n", ERR_E_MALLOC));
            return (ERR_E_MALLOC);
          }

        /*  Load the argument  */

        _ERRdebug ((fname, "loading the argument ...\n"));

        switch (token[0])
          {
            case 'l':
            case 'L':
                sprintf (argv[i], "%ld", int_arg);
                break;

            case 'd':
            case 'D':
                sprintf (argv[i], "%d", int_arg);
                break;

            case 'u':
            case 'U':
                sprintf (argv[i], "%u", int_arg);
                break;

            case 'x':
            case 'X':
                sprintf (argv[i], "%x", int_arg);
                break;

            case 's':
            case 'S':
                strcpy (argv[i], str_arg);
                break;

            case 'f':
            case 'F':
            case 'g':
            case 'G':
                sprintf (argv[i], "%f", dbl_arg);
                break;

            case 'c':
            case 'C':
                argv[i][0] = char_arg;
                argv[i][1] = NULL;
                break;

            default:
                _ERRdebug ((fname, "unrecognized format <%s>\n", token));
                *arg_array = argv;
                _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
                    ERR_E_INVALID_INPUT));
                return (ERR_E_INVALID_INPUT);
          }

        _ERRdebug ((fname, "argv[%d] = <%s>\n", i, argv[i]));

        /*  Get the next token from the format string  */

        _ERRdebug ((fname, "getting next token from format string ...\n"));

        token = strtok (NULL, "%");
        ++i;
      }

    /*  Copy the pointer back  */

    *arg_array = argv;

    _ERRdebug ((fname, "returning <0x%.8x>\n", ERRstatus));
    return (ERRstatus);
  }


/***********************************************************************

 This function interprets the information in the I/NFM error structure
 and returns a proper error message.

 Return values:

  ERR_S_SUCCESS           -  Successful completion
  ERR_E_UMS               -  A UMS function call failed
  ERR_E_INVALID_INPUT     -  Invalid input arguments

************************************************************************/

long ERRget_message (message)
  char      *message;  /*  o - string for error message  */
  {
    int     i;
    int     argc;
    int     error_no;
    int     status;
    char    **argv;
    char    *format;

    /*  Argument place holders (expects 16 arguments now)  */

    static  char *args[MAX_ARGS] = { NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL };

    static  char *fname = "ERRget_message";

    /*  Find the error code to translate  */

    if (_ERRstruct.NFIstatus != NFI_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.NFIstatus;
        argv = _ERRstruct.NFIargv;
        _ERRdebug ((fname, "using NFIstatus <0x%.8x>\n", error_no));
      }
    else if (_ERRstruct.NFMRstatus != NFM_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.NFMRstatus;
        argv = _ERRstruct.NFMRargv;
        _ERRdebug ((fname, "using NFMRstatus <0x%.8x>\n", error_no));
      }
    else if (_ERRstruct.NFMstatus != NFM_S_SUCCESS)
      {
        /*  Added specific checks for SQL and MEM errors - 3/5/91 Glenn  */

        if ((_ERRstruct.NFMstatus == NFM_E_SQL_STMT) ||
            (_ERRstruct.NFMstatus == NFM_E_SQL_QUERY))
          {
            error_no = (int) _ERRstruct.SQLstatus;
            argv = _ERRstruct.SQLargv;
            _ERRdebug ((fname, "using SQLstatus <0x%.8x>\n", error_no));
          }
        else if (_ERRstruct.NFMstatus == NFM_E_MEM)
          {
            error_no = (int) _ERRstruct.MEMstatus;
            argv = _ERRstruct.MEMargv;
            _ERRdebug ((fname, "using MEMstatus <0x%.8x>\n", error_no));
          }
        else
          {
            error_no = (int) _ERRstruct.NFMstatus;
            argv = _ERRstruct.NFMargv;
            _ERRdebug ((fname, "using NFMstatus <0x%.8x>\n", error_no));
          }
      }
    else if (_ERRstruct.NETCstatus != NET_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.NETCstatus;
        argv = _ERRstruct.NETCargv;
        _ERRdebug ((fname, "using NETCstatus <0x%.8x>\n", error_no));
      }
    else if (_ERRstruct.NETSstatus != NET_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.NETSstatus;
        argv = _ERRstruct.NETSargv;
        _ERRdebug ((fname, "using NETSstatus <0x%.8x>\n", error_no));
      }
    else if (_ERRstruct.NFMSstatus != NFM_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.NFMSstatus;
        argv = _ERRstruct.NFMSargv;
        _ERRdebug ((fname, "using NFMSstatus <0x%.8x>\n", error_no));
      }
    else if (_ERRstruct.UTIstatus != UTI_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.UTIstatus;
        argv = _ERRstruct.UTIargv;
        _ERRdebug ((fname, "using UTIstatus <0x%.8x>\n", error_no));
      }

    /*  Commented out checks for low-level subsystems;
        if all of the higher subsystems were successful,
        then the command was successful - 1/4/91 Glenn Scott  */
/*
    else if (_ERRstruct.SQLstatus != SQL_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.SQLstatus;
        argv = _ERRstruct.SQLargv;
        _ERRdebug ((fname, "using SQLstatus <0x%.8x>\n", error_no));
      }
    else if (_ERRstruct.MEMstatus != MEM_S_SUCCESS)
      {
        error_no = (int) _ERRstruct.MEMstatus;
        argv = _ERRstruct.MEMargv;
        _ERRdebug ((fname, "using MEMstatus <0x%.8x>\n", error_no));
      }
*/
    else
      {
        error_no = (int) NFM_S_SUCCESS;
        argv = NULL;
        _ERRdebug ((fname, "using NFM_S_SUCCESS <0x%.8x>\n", error_no));
      }

    if (argv == NULL)
      {
        if ((status = UMSGetByNum
            (message, error_no, NULL)) != UMS_S_SUCCESS)
          {
            _ERRdebug ((fname, "UMSGetByNum = <0x%x>\n", status));
            _ERRdebug ((fname, "returning ERR_E_UMS <0x%.8x>\n", ERR_E_UMS));
            return (ERR_E_UMS);
          }

        _ERRdebug ((fname, "message = <%s>\n", message));

        _ERRdebug ((fname,
            "returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
        return (ERR_S_SUCCESS);
      }

    /*  Get any arguments out of the structure  */

    argc = (int) argv[0];

    _ERRdebug ((fname, "argc = <%d>\n", argc));

    if (argc == 0)
      {
        if ((status = UMSGetByNum
            (message, error_no, NULL)) != UMS_S_SUCCESS)
          {
            _ERRdebug ((fname, "UMSGetByNum = <0x%x>\n", status));
            _ERRdebug ((fname, "returning ERR_E_UMS <0x%.8x>\n", ERR_E_UMS));
            return (ERR_E_UMS);
          }

        _ERRdebug ((fname, "message = <%s>\n", message));

        _ERRdebug ((fname,
            "returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
        return (ERR_S_SUCCESS);
      }

    if (argc > MAX_ARGS)
      {
        _ERRdebug ((fname, "too many arguments; maximum is <%d>\n", MAX_ARGS));
        _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
            ERR_E_INVALID_INPUT));
        return (ERR_E_INVALID_INPUT);
      }

    /*  Allocate space for the format string  */

    if ((format = (char *) malloc ((argc * 2) + 1)) == NULL)
      {
        _ERRdebug ((fname, "malloc failed; size = <%d>\n", (argc * 2) + 1));
        _ERRdebug ((fname, "returning ERR_E_MALLOC <0x%.8x>\n", ERR_E_MALLOC));
        return (ERR_E_MALLOC);
      }

    /*  Build the format string and load the arguments  */

    strcpy (format, "");
    for (i = 0; i < (int) argv[0]; ++i)
      {
        strcat (format, "%s");
        args[i] = argv[i + 1];
      }

    /*  Get the message  */

    if ((status = UMSGetByNum
        (message, error_no, format, args[0], args[1],
        args[2], args[3], args[4], args[5], args[6],
        args[7], args[8], args[9], args[10], args[11],
        args[12], args[13], args[14], args[15])) != UMS_S_SUCCESS)
      {
        _ERRdebug ((fname, "UMSGetByNum = <0x%x>\n", status));
        if (format) free (format);
        _ERRdebug ((fname, "returning ERR_E_UMS <0x%.8x>\n", ERR_E_UMS));
        return (ERR_E_UMS);
      }

    _ERRdebug ((fname, "message = <%s>\n", message));

    if (format) free (format);

    _ERRdebug ((fname, "returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
    return (ERR_S_SUCCESS);
  }

/***********************************************************************

 This function finds the error message for the indicated subsystem.

 Return values:

  ERR_S_SUCCESS           -  Successful completion
  ERR_E_UMS               -  A UMS function call failed
  ERR_E_INVALID_INPUT     -  Invalid input arguments

************************************************************************/

long ERRget_specific_message (type, message)
  int       type;      /*  i - subsystem #defined in ERR.h      */
  char      *message;  /*  o - string for error message         */
  {
    int     i;
    int     argc;
    int     error_no;
    int     status;
    char    **argv;
    char    *format;

    /*  Argument place holders (expects 16 arguments now)  */

    static  char *args[MAX_ARGS] = { NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL };

    static  char *fname = "ERRget_specific_message";

    /*  Find the correct error number and argument vector  */

    switch (type)
      {
        case NFI:
            error_no = (int) _ERRstruct.NFIstatus;
            argv = _ERRstruct.NFIargv;
            _ERRdebug ((fname, "using NFIstatus <0x%.8x>\n", error_no));
            break;

        case NFMR:
            error_no = (int) _ERRstruct.NFMRstatus;
            argv = _ERRstruct.NFMRargv;
            _ERRdebug ((fname, "using NFMRstatus <0x%.8x>\n", error_no));
            break;

        case NETC:
            error_no = (int) _ERRstruct.NETCstatus;
            argv = _ERRstruct.NETCargv;
            _ERRdebug ((fname, "using NETCstatus <0x%.8x>\n", error_no));
            break;

        case NETS:
            error_no = (int) _ERRstruct.NETSstatus;
            argv = _ERRstruct.NETSargv;
            _ERRdebug ((fname, "using NETSstatus <0x%.8x>\n", error_no));
            break;

        case NFMS:
            error_no = (int) _ERRstruct.NFMSstatus;
            argv = _ERRstruct.NFMSargv;
            _ERRdebug ((fname, "using NFMSstatus <0x%.8x>\n", error_no));
            break;

        case NFM:
            error_no = (int) _ERRstruct.NFMstatus;
            argv = _ERRstruct.NFMargv;
            _ERRdebug ((fname, "using NFMstatus <0x%.8x>\n", error_no));
            break;

        case SQL:
            error_no = (int) _ERRstruct.SQLstatus;
            argv = _ERRstruct.SQLargv;
            _ERRdebug ((fname, "using SQLstatus <0x%.8x>\n", error_no));
            break;

        case MEM:
            error_no = (int) _ERRstruct.MEMstatus;
            argv = _ERRstruct.MEMargv;
            _ERRdebug ((fname, "using MEMstatus <0x%.8x>\n", error_no));
            break;

        case UTI:
            error_no = (int) _ERRstruct.UTIstatus;
            argv = _ERRstruct.UTIargv;
            _ERRdebug ((fname, "using UTIstatus <0x%.8x>\n", error_no));
            break;

        default:
            _ERRdebug ((fname, "invalid subsystem specified <%d>\n", type));
            _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
                ERR_E_INVALID_INPUT));
            return (ERR_E_INVALID_INPUT);
      }

    if (argv == NULL)
      {
        if ((status = UMSGetByNum
            (message, error_no, NULL)) != UMS_S_SUCCESS)
          {
            _ERRdebug ((fname, "UMSGetByNum = <0x%x>\n", status));
            _ERRdebug ((fname, "returning ERR_E_UMS <0x%.8x>\n", ERR_E_UMS));
            return (ERR_E_UMS);
          }

        _ERRdebug ((fname, "message = <%s>\n", message));

        _ERRdebug ((fname,
            "returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
        return (ERR_S_SUCCESS);
      }

    /*  Get any arguments out of the structure  */

    argc = (int) argv[0];

    _ERRdebug ((fname, "argc = <%d>\n", argc));

    if (argc == 0)
      {
        if ((status = UMSGetByNum
            (message, error_no, NULL)) != UMS_S_SUCCESS)
          {
            _ERRdebug ((fname, "UMSGetByNum = <0x%x>\n", status));
            _ERRdebug ((fname, "returning ERR_E_UMS <0x%.8x>\n", ERR_E_UMS));
            return (ERR_E_UMS);
          }

        _ERRdebug ((fname, "message = <%s>\n", message));

        _ERRdebug ((fname,
            "returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
        return (ERR_S_SUCCESS);
      }

    if (argc > MAX_ARGS)
      {
        _ERRdebug ((fname, "too many arguments; maximum is <%d>\n", MAX_ARGS));
        _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
            ERR_E_INVALID_INPUT));
        return (ERR_E_INVALID_INPUT);
      }

    /*  Allocate space for the format string  */

    if ((format = (char *) malloc ((argc * 2) + 1)) == NULL)
      {
        _ERRdebug ((fname, "malloc failed; size = <%d>\n", (argc * 2) + 1));
        _ERRdebug ((fname, "returning ERR_E_MALLOC <0x%.8x>\n", ERR_E_MALLOC));
        return (ERR_E_MALLOC);
      }

    /*  Build the format string and load the arguments  */

    strcpy (format, "");
    for (i = 0; i < (int) argv[0]; ++i)
      {
        strcat (format, "%s");
        args[i] = argv[i + 1];
      }

    /*  Get the message  */

    if ((status = UMSGetByNum
        (message, error_no, format, args[0], args[1],
        args[2], args[3], args[4], args[5], args[6],
        args[7], args[8], args[9], args[10], args[11],
        args[12], args[13], args[14], args[15])) != UMS_S_SUCCESS)
      {
        _ERRdebug ((fname, "UMSGetByNum = <0x%x>\n", status));
        if (format) free (format);
        _ERRdebug ((fname, "returning ERR_E_UMS <0x%.8x>\n", ERR_E_UMS));
        return (ERR_E_UMS);
      }

    _ERRdebug ((fname, "message = <%s>\n", message));

    if (format) free (format);

    _ERRdebug ((fname, "returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
    return (ERR_S_SUCCESS);
  }

/***********************************************************************

  This function finds the message number that will be used when
  ERRget_message () is called.  There is no return value.

***********************************************************************/

void ERRget_number (error_no, subsystem)
  long   *error_no;
  int    *subsystem;
  {
    static  char *fname = "ERRget_number";

    _ERRdebug ((fname, "entering ...\n"));

    /*  Find the error code to translate  */

    if (_ERRstruct.NFIstatus != NFI_S_SUCCESS)
      {
        *error_no = _ERRstruct.NFIstatus;
        *subsystem = NFI;
        _ERRdebug ((fname, "using NFIstatus <0x%.8x>\n", *error_no));
      }
    else if (_ERRstruct.NFMRstatus != NFM_S_SUCCESS)
      {
        *error_no = _ERRstruct.NFMRstatus;
        *subsystem = NFMR;
        _ERRdebug ((fname, "using NFMRstatus <0x%.8x>\n", *error_no));
      }
    else if (_ERRstruct.NFMstatus != NFM_S_SUCCESS)
      {
        /*  Added specific checks for SQL and MEM errors  */

        if ((_ERRstruct.NFMstatus == NFM_E_SQL_STMT) ||
            (_ERRstruct.NFMstatus == NFM_E_SQL_QUERY))
          {
            *error_no = _ERRstruct.SQLstatus;
            *subsystem = SQL;
            _ERRdebug ((fname, "using SQLstatus <0x%.8x>\n", *error_no));
          }
        else if (_ERRstruct.NFMstatus == NFM_E_MEM)
          {
            *error_no = _ERRstruct.MEMstatus;
            *subsystem = MEM;
            _ERRdebug ((fname, "using MEMstatus <0x%.8x>\n", *error_no));
          }
        else
          {
            *error_no = _ERRstruct.NFMstatus;
            *subsystem = NFM;
            _ERRdebug ((fname, "using NFMstatus <0x%.8x>\n", *error_no));
          }
      }
    else if (_ERRstruct.NETCstatus != NET_S_SUCCESS)
      {
        *error_no = _ERRstruct.NETCstatus;
        *subsystem = NETC;
        _ERRdebug ((fname, "using NETCstatus <0x%.8x>\n", *error_no));
      }
    else if (_ERRstruct.NETSstatus != NET_S_SUCCESS)
      {
        *error_no = _ERRstruct.NETSstatus;
        *subsystem = NETS;
        _ERRdebug ((fname, "using NETSstatus <0x%.8x>\n", *error_no));
      }
    else if (_ERRstruct.NFMSstatus != NFM_S_SUCCESS)
      {
        *error_no = _ERRstruct.NFMSstatus;
        *subsystem = NFMS;
        _ERRdebug ((fname, "using NFMSstatus <0x%.8x>\n", *error_no));
      }
    else if (_ERRstruct.UTIstatus != UTI_S_SUCCESS)
      {
        *error_no = _ERRstruct.UTIstatus;
        *subsystem = UTI;
        _ERRdebug ((fname, "using UTIstatus <0x%.8x>\n", *error_no));
      }

    /*  Commented out checks for low-level subsystems;
        if all of the higher subsystems were successful,
        then the command was successful - 1/4/91 Glenn Scott  */
/*
    else if (_ERRstruct.SQLstatus != SQL_S_SUCCESS)
      {
        *error_no = _ERRstruct.SQLstatus;
        *subsystem = SQL;
        _ERRdebug ((fname, "using SQLstatus <0x%.8x>\n", *error_no));
      }
    else if (_ERRstruct.MEMstatus != MEM_S_SUCCESS)
      {
        *error_no = _ERRstruct.MEMstatus;
        *subsystem = MEM;
        _ERRdebug ((fname, "using MEMstatus <0x%.8x>\n", *error_no));
      }
*/
    else
      {
        *error_no = NFM_S_SUCCESS;
        *subsystem = NFM;
        _ERRdebug ((fname, "using NFM_S_SUCCESS <0x%.8x>\n", *error_no));
      }

    _ERRdebug ((fname, " returning ...\n"));
    return;
  }

/***********************************************************************

  This function finds the message number for the specified subsystem.
  
  Return values:

  ERR_S_SUCCESS           -  Successful completion
  ERR_E_INVALID_INPUT     -  Invalid input arguments

***********************************************************************/

long ERRget_specific_number (subsystem, error_no)
  int    subsystem;
  long   *error_no;
  {
    static  char *fname = "ERRget_specific_number";

    _ERRdebug ((fname, "subsystem = <%d>\n", subsystem));

    /*  Find the correct error number  */

    switch (subsystem)
      {
        case NFI:
            *error_no = _ERRstruct.NFIstatus;
            _ERRdebug ((fname, "using NFIstatus <0x%.8x>\n", *error_no));
            break;

        case NFMR:
            *error_no = _ERRstruct.NFMRstatus;
            _ERRdebug ((fname, "using NFMRstatus <0x%.8x>\n", *error_no));
            break;

        case NETC:
            *error_no = _ERRstruct.NETCstatus;
            _ERRdebug ((fname, "using NETCstatus <0x%.8x>\n", *error_no));
            break;

        case NETS:
            *error_no = _ERRstruct.NETSstatus;
            _ERRdebug ((fname, "using NETSstatus <0x%.8x>\n", *error_no));
            break;

        case NFMS:
            *error_no = _ERRstruct.NFMSstatus;
            _ERRdebug ((fname, "using NFMSstatus <0x%.8x>\n", *error_no));
            break;

        case NFM:
            *error_no = _ERRstruct.NFMstatus;
            _ERRdebug ((fname, "using NFMstatus <0x%.8x>\n", *error_no));
            break;

        case SQL:
            *error_no = _ERRstruct.SQLstatus;
            _ERRdebug ((fname, "using SQLstatus <0x%.8x>\n", *error_no));
            break;

        case MEM:
            *error_no = _ERRstruct.MEMstatus;
            _ERRdebug ((fname, "using MEMstatus <0x%.8x>\n", *error_no));
            break;

        case UTI:
            *error_no = _ERRstruct.UTIstatus;
            _ERRdebug ((fname, "using UTIstatus <0x%.8x>\n", *error_no));
            break;

        default:
            _ERRdebug ((fname,
                "invalid subsystem specified <%d>\n", subsystem));
            _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
                ERR_E_INVALID_INPUT));
            return (ERR_E_INVALID_INPUT);
      }

    _ERRdebug ((fname, " returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
    return (ERR_S_SUCCESS);
  }

/***********************************************************************

  This function resets all of the status' in the error structure
  to a successful status.  There is no return value.

***********************************************************************/

void ERRreset_struct ()
  {
    short    debug_was_on = FALSE;
    static   char *fname = "ERRreset_struct";

    _ERRdebug ((fname, "entering ...\n"));

    /*  Turn debug off if it is on  */

    if (_NFMdebug_st.ERRdebug_on)
      {
        debug_was_on = TRUE;
        _NFMdebug_st.ERRdebug_on = FALSE;
      }

    ERRload_struct (NFI, NFI_S_SUCCESS, NULL);
    ERRload_struct (NFMR, NFM_S_SUCCESS, NULL);
    ERRload_struct (NETC, NET_S_SUCCESS, NULL);
    ERRload_struct (NETS, NET_S_SUCCESS, NULL);
    ERRload_struct (NFMS, NFM_S_SUCCESS, NULL);
    ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
    ERRload_struct (SQL, SQL_S_SUCCESS, NULL);
    ERRload_struct (MEM, MEM_S_SUCCESS, NULL);
    ERRload_struct (UTI, UTI_S_SUCCESS, NULL);

    /*  Turn debug back on if it was on before  */

    if (debug_was_on)
        _NFMdebug_st.ERRdebug_on = TRUE;

    _ERRdebug ((fname, "returning ...\n"));
    return;
  }

/***********************************************************************

  This function initializes all of the message files associated
  with I/NFM.  The path argument is the complete full directory
  path to the message files (other applications might set up their
  product configuration different from the I/NFM clients).  The
  optflag argument determines how much of the UMS message structure
  is kept in memory.  It is documented in the UMS document.

***********************************************************************/

long ERRinit_messages (path, optflag)
  char    *path;     /*  i - full path to message files    */
  int     optflag;   /*  i - bit flag to indicate
                             which data to save in memory  */
  {
    int     i, status;
    FILE    *infile;
    char    *p, *_ERRfgets ();
    char    known_path[128];
    char    language[20];

    static  char *fname = "ERRinit_messages";

    static  char message_files[NUMBER_OF_MESSAGE_FILES][20] = {
            NFI_MSG_FILE, NFM_MSG_FILE, NET_MSG_FILE,
            SQL_MSG_FILE, MEM_MSG_FILE, UTI_MSG_FILE, ERR_MSG_FILE };

    _ERRdebug ((fname, "path = <%s>\n", path));
    _ERRdebug ((fname, "optflag = <%d>\n", optflag));

    /*  Copy in the known path for the language file  */

    strncpy (known_path,
        "/usr/ip32/nfm/config/language", sizeof (known_path) - 1);

    /*  Copy in the default language  */

    strncpy (language, DEFAULT_LANGUAGE, sizeof (language) - 1);

    /*  Open the "language" file to find the preferred language  */

    if ((infile = fopen (known_path, "r")) == NULL)
      {
        _ERRdebug ((fname, "failed to open <%s>\n", known_path));
        _ERRdebug ((fname, "defaulting language to \"%s\"\n", language));
      }
    else
      {
        /*  Read the language out of the file  */

        if ((_ERRfgets (language, sizeof (language) - 1, infile)) == NULL)
          {
            _ERRdebug ((fname, "failed to read <%s>\n", known_path));
            strncpy (language, DEFAULT_LANGUAGE, sizeof (language) - 1);
            _ERRdebug ((fname, "defaulting language to \"%s\"\n", language));
          }

        fclose (infile);
      }

    /*  Remove "/language"  */

    p = strrchr (known_path, '/');
    *p = NULL;

    strncat (known_path, "/", sizeof (known_path) - 1);
    strncat (known_path, language, sizeof (known_path) - 1);
    strncat (known_path, "/messages", sizeof (known_path) - 1);

    _ERRdebug ((fname, "path = <%s>\n", known_path));

    for (i = 0; i < NUMBER_OF_MESSAGE_FILES; ++i)
      {
        strcat (known_path, "/");
        strcat (known_path, message_files[i]);

        /*  Hardcode the optflag - GS 1/25/91  */

        if ((status = UMSInitMsg (known_path, UMS_INDEX)) != UMS_S_SUCCESS)
          {
            _ERRdebug ((fname, "UMSInitMsg = <0x%x>\n", status));
            _ERRdebug ((fname, "message path is <%s>\n", known_path));
            _ERRdebug ((fname, " returning FAILURE\n"));
            return (ERR_E_UMS);
          }

        /*  Remove last message filename  */

        p = strrchr (known_path, '/');
        *p = NULL;
      }

    _ERRdebug ((fname, " returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
    return (ERR_S_SUCCESS);
  }

/***********************************************************************

  This function allocates space for all context specific data
  associated with the input subsystem.  Space for the array is
  allocated first and then space for each element is allocated.
  The context data is then copied into the array.  The argc argument
  is set to tell how many elements have been allocated.

  NOTE:  The calling function is responsible for freeing up the
         space allocated.  All elements of the array need to be
         freed up first and then the array itself needs to be
         freed when the data is no longer needed.

  If there is no context specific data for the input subsystem,
  argc is set to 0 and the array itself is set to NULL.

***********************************************************************/

long ERRget_context_data (subsystem, argc, argv)
  int    subsystem;   /*  i - #defined in ERR.h               */
  int    *argc;       /*  o - number of context data strings  */
  char   ***argv;     /*  o - array of pointers to strings    */
  {
    int     i;
    char    **i_argv;

    static  char *fname = "ERRget_context_data";

    _ERRdebug ((fname, "subsystem = <%d>\n", subsystem));

    /*  Initialize argc and argv variables  */

    *argc = 0;
    *argv = (char **) NULL;
    i_argv = (char **) NULL;

    switch (subsystem)
      {
        case NFI:

            if (_ERRstruct.NFIargv != NULL)
              {
                *argc = (int) _ERRstruct.NFIargv[0];
                i_argv = _ERRstruct.NFIargv;
              }

            break;

        case NFMR:

            if (_ERRstruct.NFMRargv != NULL)
              {
                *argc = (int) _ERRstruct.NFMRargv[0];
                i_argv = _ERRstruct.NFMRargv;
              }

            break;

        case NETC:

            if (_ERRstruct.NETCargv != NULL)
              {
                *argc = (int) _ERRstruct.NETCargv[0];
                i_argv = _ERRstruct.NETCargv;
              }

            break;

        case NETS:

            if (_ERRstruct.NETSargv != NULL)
              {
                *argc = (int) _ERRstruct.NETSargv[0];
                i_argv = _ERRstruct.NETSargv;
              }

            break;

        case NFMS:

            if (_ERRstruct.NFMSargv != NULL)
              {
                *argc = (int) _ERRstruct.NFMSargv[0];
                i_argv = _ERRstruct.NFMSargv;
              }

            break;

        case NFM:

            if (_ERRstruct.NFMargv != NULL)
              {
                *argc = (int) _ERRstruct.NFMargv[0];
                i_argv = _ERRstruct.NFMargv;
              }

            break;

        case SQL:

            if (_ERRstruct.SQLargv != NULL)
              {
                *argc = (int) _ERRstruct.SQLargv[0];
                i_argv = _ERRstruct.SQLargv;
              }

            break;

        case MEM:

            if (_ERRstruct.MEMargv != NULL)
              {
                *argc = (int) _ERRstruct.MEMargv[0];
                i_argv = _ERRstruct.MEMargv;
              }

            break;

        case UTI:

            if (_ERRstruct.UTIargv != NULL)
              {
                *argc = (int) _ERRstruct.UTIargv[0];
                i_argv = _ERRstruct.UTIargv;
              }

            break;

        default:
            _ERRdebug ((fname,
                "invalid subsystem specified <%d>\n", subsystem));
            _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
                ERR_E_INVALID_INPUT));
            return (ERR_E_INVALID_INPUT);
      }

    _ERRdebug ((fname, "argc = <%d>\n", *argc));

    if (*argc == 0)
      {
        _ERRdebug ((fname,
            "There are no arguments for subsystem <%d>\n", subsystem));
        _ERRdebug ((fname,
            " returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
        return (ERR_S_SUCCESS);
      }

    /*  Allocate space for the arguments  */

    _ERRdebug ((fname,
        "allocating space for array; size = <%d>\n", *argc * sizeof (char *)));

    if ((*argv = (char **) malloc (*argc * sizeof (char *))) == NULL)
      {
        _ERRdebug ((fname,
            "malloc failed; size = <%d>\n", *argc * sizeof (char *)));
        _ERRdebug ((fname, "returning ERR_E_MALLOC <0x%.8x>\n", ERR_E_MALLOC));
        return (ERR_E_MALLOC);
      }

    /*  Allocate space for each piece of context data  */

    for (i = 0; i < *argc; ++i)
      {
        /*  Check to see if the argv array is corrupted  */

        if (i_argv[i + 1] == NULL)
          {
            _ERRdebug ((fname,
                "_ERRstruct argv array is corrupted; argv[%d] is NULL\n",
                i + 1));
            _ERRdebug ((fname, "returning ERR_E_INVALID_INPUT <0x%.8x>\n",
                ERR_E_INVALID_INPUT));
            return (ERR_E_INVALID_INPUT);
          }

        _ERRdebug ((fname, "allocating space for element %d; size = <%d>\n",
            i, strlen (i_argv[i + 1]) + 1));

        if (((*argv)[i] = (char *) malloc
            (strlen (i_argv[i + 1]) + 1)) == NULL)
          {
            _ERRdebug ((fname,
                "malloc failed; size = <%d>\n", strlen (i_argv[i + 1]) + 1));
            _ERRdebug ((fname,
                "returning ERR_E_MALLOC <0x%.8x>\n", ERR_E_MALLOC));
            return (ERR_E_MALLOC);
          }

        /*  Copy the context data into the output array  */

        _ERRdebug ((fname, "copying <%s> into argv[%d]\n", i_argv[i + 1], i));

        strcpy ((*argv)[i], i_argv[i + 1]);
      }

    _ERRdebug (("IMPORTANT", "NOTE --\n"));
    _ERRdebug (("IMPORTANT",
        "calling function needs to free up all elements first\n"));
    _ERRdebug (("IMPORTANT",
        "and then free up the array itself when it is done.\n"));

    _ERRdebug ((fname, " returning ERR_S_SUCCESS <0x%.8x>\n", ERR_S_SUCCESS));
    return (ERR_S_SUCCESS);
  }


char *_ERRfgets (s, n, stream)
  char   *s;
  int    n;
  FILE   *stream;
  {
    char *sts, *strchr ();

    if ((sts = fgets (s, n, stream)) == NULL)
        return (sts);

    if ((sts = strchr (s, '\n')) == NULL)
        return (s);

    *sts = NULL;

    return (s);
  }
