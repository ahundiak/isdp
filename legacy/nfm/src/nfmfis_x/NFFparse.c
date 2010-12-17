
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

int _NFFparse_input (argc, argv)
  int    argc;
  char   *argv[];
  {
    auto   int  c;
    auto   int  errflag = 0;
    extern int  opterr;
    extern char *optarg;
    extern int  optind;

    opterr = 0;
    NFFglobal.admin_or_user = USER;
    NFFglobal.collapse_flag = FALSE;

    /*  Parse input arguments  */


#ifdef COMBINED_CLIENT_SERVER

/* X-Windows based versions of NFM still have not been provided with 
   Recording and Playback features   - Jujare-IGI-15 FEB 1995 */

#ifdef XWINDOWS
    while ((c = getopt
        (argc, argv, "u:p:e:AcS:d:n:N:Q:m:E:")) != -1)
#else
    while ((c = getopt
        (argc, argv, "u:p:e:AcR:P:T:D:S:d:n:N:Q:m:E:")) != -1)
#endif

#else

/* X-Windows based versions of NFM still have not been provided with 
   Recording and Playback features   - Jujare-IGI-15 FEB 1995 */

#ifdef XWINDOWS
    while ((c = getopt
        (argc, argv, "s:u:p:e:AcS:d:r:n:m:E:")) != -1)
#else
    while ((c = getopt
        (argc, argv, "s:u:p:e:AcR:P:T:D:S:d:r:n:m:E:")) != -1)
#endif

#endif
      {
        switch (c)
          {
#ifndef COMBINED_CLIENT_SERVER
            case 's':
                strncpy (NFFglobal.server,
                    optarg, (sizeof (NFFglobal.server)) - 1);
                break;
#endif
            case 'u':
                strncpy (NFFglobal.username,
                    optarg, (sizeof (NFFglobal.username)) - 1);
                break;

            case 'p':
                strncpy (NFFglobal.password,
                    optarg, (sizeof (NFFglobal.password)) - 1);
                break;

            case 'e':
                strncpy (NFFglobal.environment,
                    optarg, (sizeof (NFFglobal.environment)) - 1);
                break;

            case 'A':
                NFFglobal.admin_or_user = ADMIN;
                break;

            case 'c':
                NFFglobal.collapse_flag = TRUE;
                break;

/* X-Windows based versions of NFM still have not been provided with 
   Recording and Playback features   - Jujare-IGI-15 FEB 1995 */

#ifndef XWINDOWS
            case 'R':
                strncpy (NFFglobal.record_file,
                    optarg, (sizeof (NFFglobal.record_file)) - 1);
                break;

            case 'P':
                strncpy (NFFglobal.playback_file,
                    optarg, (sizeof (NFFglobal.playback_file)) - 1);
                break;

            case 'T':
                NFFglobal.playback_time = atoi (optarg);
                break;

            case 'D':
                NFFglobal.delay_time = atoi (optarg);
                break;
#endif
            case 'S':
                NFFglobal.timestamp_enabled = TRUE;
                strncpy (NFFglobal.timestamp_file,
                    optarg, (sizeof (NFFglobal.timestamp_file)) - 1);
                break;

            case 'd':
                if( strcmp( optarg, "isplay" ) == 0 )
                {
                    strcpy( NFFglobal.display_name, argv[optind] );
                    ++optind;
                }
                else
                {
                    _NFMdebug_st.NFIdebug_on = TRUE;
                    strncpy (_NFMdebug_st.NFIdebug_file,
                        optarg, NFM_DEBUG_FILE_SIZE - 1);
                }
 
                break;

            case 'r':
                _NFMdebug_st.NFMRdebug_on = TRUE;
                strncpy (_NFMdebug_st.NFMRdebug_file,
                    optarg, NFM_DEBUG_FILE_SIZE - 1);
                break;

            case 'n':
                _NFMdebug_st.NETCdebug_on = TRUE;
                strncpy (_NFMdebug_st.NETCdebug_file,
                    optarg, NFM_DEBUG_FILE_SIZE - 1);
                break;

            case 'N':
                _NFMdebug_st.NFMdebug_on = TRUE;
                strncpy (_NFMdebug_st.NFMdebug_file,
                    optarg, NFM_DEBUG_FILE_SIZE - 1);
                break;

            case 'Q':
                _NFMdebug_st.SQLdebug_on = TRUE;
                strncpy (_NFMdebug_st.SQLdebug_file,
                    optarg, NFM_DEBUG_FILE_SIZE - 1);
                break;

            case 'm':
                _NFMdebug_st.MEMdebug_on = TRUE;
                strncpy (_NFMdebug_st.MEMdebug_file,
                    optarg, NFM_DEBUG_FILE_SIZE - 1);
                break;

            case 'E':
                _NFMdebug_st.ERRdebug_on = TRUE;
                strncpy (_NFMdebug_st.ERRdebug_file,
                    optarg, NFM_DEBUG_FILE_SIZE - 1);
                break;

            case '?':
                ++errflag;
                break;
          }
      }

    return (errflag);
  }
