#include "machine.h"
#include "WFF.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/*  Global error processor structure  */

extern struct _ERRstruct _ERRstruct;

void _WFFparse_input (argc, argv, errflag)
  int	argc;
  char	*argv[];
  int	*errflag;
  {
	int		c;

	extern int opterr;
	extern char *optarg;
	extern int optind;
	opterr = 0;

	/*  Parse input arguments  */

	while ((c = getopt (argc, argv, "s:u:p:e:AR:P:T:D:S:d:r:m:E:")) != -1)
	  {
		switch (c)
		  {
			case 'u':
				strncpy (WFFglobal.username,
				optarg, (sizeof (WFFglobal.username)) - 1);
			break;

			case 'p':
				strncpy (WFFglobal.password,
				optarg, (sizeof (WFFglobal.password)) - 1);
			break;

			case 'e':
				strncpy (WFFglobal.environment,
				optarg, (sizeof (WFFglobal.environment)) - 1);
			break;

			case 'S': /* SQL debug on */
				_NFMdebug_st.SQLdebug_on = TRUE;
				strncpy (_NFMdebug_st.SQLdebug_file,
				optarg, NFM_DEBUG_FILE_SIZE - 1);
			break;

			case 'r':
				_NFMdebug_st.NFIdebug_on = TRUE; 
                                WFFglobal.debug_on = TRUE;
				strncpy (WFFglobal.debug_file,
				  optarg, (sizeof (WFFglobal.debug_file)) - 1);
				strncpy (_NFMdebug_st.NFIdebug_file,
                                         optarg, NFM_DEBUG_FILE_SIZE - 1);
			break;

			case 'd':
                            if( strcmp( optarg, "isplay" ) == 0 )
                            {
		               strcpy( WFFglobal.display_name, argv[optind] );
	                       ++optind;
 	                    }
			    else
			    {
				_NFMdebug_st.NFMdebug_on = TRUE;
				strncpy (_NFMdebug_st.NFMdebug_file,
					optarg, NFM_DEBUG_FILE_SIZE - 1);
			    }
			break;

			case 'm':
				_NFMdebug_st.MEMdebug_on = TRUE;
				strncpy (_NFMdebug_st.MEMdebug_file,
					optarg, NFM_DEBUG_FILE_SIZE - 1);
			break;

			case 'E':
				_NFMdebug_st.ERRdebug_on = _ERRstruct.debug_on = TRUE;
				strncpy (_ERRstruct.debug_file,
					optarg, (sizeof (_ERRstruct.debug_file)) - 1);
				strncpy (_NFMdebug_st.ERRdebug_file,
					optarg, NFM_DEBUG_FILE_SIZE - 1);
			break;

                        case 'A':
                                ;
                        break;

			case '?':
				++(*errflag);
				break;
		  }
	  }

	return;
  }
