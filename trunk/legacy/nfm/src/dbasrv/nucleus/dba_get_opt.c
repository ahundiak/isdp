/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"
#include "dmalloc.def"

extern char *dba_where, dba_els_input[], dba_asc_input[], *dba_prodname,
  *dba_lib, *dba_datbas, dba_find_name[], dba_output[], dba_menu_name[], 
  *dba_da_file, **dba_dap_dgn_files, dba_rtbnam[], *dba_batch_script_string,
  *dba_schema_list, dba_server_node[], dba_app_template[], *dba_stext, *dba_p[];
extern int dba_dap_batch_mode, dba_dap_num_files, dba_debug,
  dba_use_server_flag;

/* Function:	dba_get_opt */
int dba_get_opt (argc, argv)
int argc;
char *argv[];
{
    extern char *optarg;
    extern int  optind;
    char *char_ptr, text[100];
    int status, c, i, cnt, lng;
    int (*func)();

    static char options[] = "s:S:l:m:A:b:r:w:q:o:e:a:p:d:n:D?";

    while((c = getopt(argc, argv, options)) != EOF)
    {
        switch(c)
        {
          case 's':
            strcpy (dba_datbas, optarg);
	    break;

	  case 'l':
            strcpy (dba_lib, optarg);
	    break;

	  case 'b':
            dba_batch_script_string = (char *) dba_dstrdup (optarg, DM_OTHER);
	    break;

	  case 'r':
	    strncpy (dba_rtbnam, optarg, 20);  dba_rtbnam[20] = 0;
	    break;

	  case 'w':
            dba_where = (char *) dba_dstrdup (optarg, DM_OTHER);
	    break;

	  case 'e':
            strcpy (dba_els_input, optarg);
	    break;

	  case 'q':
	    strncpy (dba_find_name, optarg, 20);  dba_find_name[20] = 0;
	    break;

	  case 'a':
            strcpy (dba_asc_input, optarg);
	    break;

	  case 'p':
            char_ptr = optarg;
            for (cnt=0;cnt<6;++cnt) {
              status = dba_parse_string (&char_ptr, text, ' ', 1);
              if (status) dba_p[cnt] = dba_dstrdup (text, DM_OTHER);
              else dba_p[cnt] = 0;
            }
            func = dba_inq_service (DBA_CREATE_SYS_VAR);
            if (func) {
              (*func) ();
              func = dba_inq_service (DBA_RESET_SYS_VAR);
              if (func)
                (*func) (dba_p[0], dba_p[1], dba_p[2], dba_p[3], dba_p[4], dba_p[5]);
            }
	    break;

	  case 'o':
	    strncpy (dba_output, optarg, 63);  dba_output[63] = 0;
	    break;

	  case 'm':
	    strncpy (dba_menu_name, optarg, 20);  dba_menu_name[20] = 0;
	    break;
	    
	  case 'A':
	    strncpy (dba_app_template, optarg, 20);  dba_app_template[20] = 0;
	    break;

	  case 'S':
            lng = strlen (optarg) + 1;
            if (lng > strlen (dba_schema_list))
              dba_schema_list = dba_drealloc (dba_schema_list, lng);
            strcpy (dba_schema_list, optarg);
	    break;

          case 'd':
            dba_da_file = (char *) dba_dstrdup (optarg, DM_OTHER);
            dba_dap_batch_mode = 1;
            break;

          case 'n':
	    strncpy (dba_server_node, optarg, 50);  dba_server_node[50] = 0;
	    break;

          case 'D':
            dba_debug = 1;
            break;

          case '?':
	    dba_options();
	    exit (0);
	    break;

          default:
	    dba_options();
            exit (0);
	    break;
	}
    }

    if (optind != argc)
    {
	if (dba_dap_batch_mode)
	{
	    dba_dap_num_files = argc - optind;
	    dba_dap_dgn_files = (char **) dba_dmalloc
			(dba_dap_num_files * sizeof (char *), DM_GLOBAL);
	    for (i=optind; i<argc; i++)
		dba_dap_dgn_files[i-optind] = dba_dstrdup (argv[i], DM_OTHER);
	}
	else
	{
	    dba_options();
            exit (0);
	}
    }
#ifdef __WIN32__
    if (dba_use_server_flag && !*dba_server_node)
    {
        func = dba_inq_service (DBA_ERROR_BOX);
        if (func)
            (*func) (dba_get_msg (DBA_E_NO_SERVER_NAME, NP, 0, NP, NP));
        else
            dba_printf ("%s\n", dba_get_msg (DBA_E_NO_SERVER_NAME, NP, 0, NP,
                NP));
        dba_exit();
    }
#endif
    return (0);
}

/* Function:	dba_options */
int dba_options()
{
    int (*func)();
    
    strcpy (dba_stext,
"\nCommand switches:\n\
-s schema name\n\
-S schema list\n\
-l template library\n\
-m dialog template\n\
-b batch script\n\
-r report template (batch)\n\
-w where clause\n\
-q query template\n\
-o output filename\n\
-e element list file\n\
-a ascii/binary input file\n\
-p parameters (wtr_p0-wtr_p5)\n\
-D debug mode\n");
    if (strncmp (dba_prodname, "ris", 3) && strncmp (dba_prodname, "x_ris", 5))
        strcat (dba_stext, "\
-d DAP control file (batch)\n");
#if defined __WIN32__
    strcat (dba_stext, "\
-A application template\n\
-n DBASRV node\n");
#endif
    strcat (dba_stext, "\
-? print command switches\n");

    func = dba_inq_service (DBA_ERROR_BOX);
    if (func) (*func) (dba_stext);
    else dba_printf ("%s", dba_stext);

    return (0);
}
