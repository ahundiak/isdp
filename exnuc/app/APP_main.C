 
#include <stdio.h>
#include <sys/param.h>
#include <OMminimum.h>
#include <igetypedef.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>

main(argc,argv)
int argc;
char *argv[];
{
    extern char *optarg;
    int mode,i;
    int create_flag;
    int firstcmd_flag;
    int status;
    int retmsg;
    int my_argc = 1;
    char *my_argv[16];
    char product[24];
    char d_name[OM_K_MAXOSNAME_LEN];
    char f_name[OM_K_MAXOSNAME_LEN];
    char r_name[OM_K_MAXOSNAME_LEN];   
    char s_name[OM_K_MAXOSNAME_LEN];   
    char S_name[OM_K_MAXOSNAME_LEN];   
    char pd[MAXPATHLEN];
    char depth[40];
    char type[40];
    char wmcolors[40];
    char ingrcolors[40];
    char double_buffer[40];
#ifdef X11
    char display[512];
#endif

    char c_command[512];
    OM_S_OBJID  mod_id; 
    OMuword os_num;
    int errflag;
   
    mode = EX_INTERACT;
    errflag = 0;
    d_name[0] = '\0';
    f_name[0] = '\0';
    r_name[0] = '\0';
    s_name[0] = '\0';
    S_name[0] = '\0';
    create_flag = 0;
    firstcmd_flag = 0;
    my_argv[0] = argv[0];
    /***********************************************************/
    /* process command line arguments                          */
    /* have to put every possible option here                  */
    /***********************************************************/

    for ( i= 1; i< argc; i++ )
    {
        char *arg = argv[i];
        if ( arg[0] == '-' )
        {
            if ( !(strncmp(argv[i],"-window_depth",13)))
            {
                if (arg[13])
                {
                    strcpy(depth,&arg[13]);
                    my_argv[my_argc++] = "-window_depth";
                    my_argv[my_argc++] = depth;

                }
                else
                {
                    if(++i >= argc)++errflag;
                    else
                    {
                        strcpy(depth,argv[i]);             
                        my_argv[my_argc++] = "-window_depth";
                        my_argv[my_argc++] = depth;
                    }
                }
            }
            else if  ( !(strncmp(argv[i],"-window_type",12)))
            {
                if (arg[12])
                {
                    strcpy(type,&arg[12]);             
                    my_argv[my_argc++] = "-window_type";
                    my_argv[my_argc++] = type;
                }
                else
                {
                    if(++i >= argc)++errflag;
                    else
                    {
                        strcpy(type,argv[i]);             
                        my_argv[my_argc++] = "-window_type";
                        my_argv[my_argc++] = type;
                    }
                }
            }

            else if  ( !(strncmp(argv[i],"-double_buffer",14)))
            {
                if (arg[14])
                {
                    strcpy(double_buffer,&arg[14]);
                    my_argv[my_argc++] = "-double_buffer";
                    my_argv[my_argc++] = double_buffer;
                }
                else
                {
                    if(++i >= argc)++errflag;
                    else
                    {
                        strcpy(double_buffer,argv[i]);             
                        my_argv[my_argc++] = "-double_buffer";
                        my_argv[my_argc++] = double_buffer;
                    }
                }
            }
            else if  ( !(strncmp(argv[i],"-num_wm_colors",14)))
            {
                if (arg[14])
                {
                    strcpy(wmcolors,&arg[14]);
                    my_argv[my_argc++] = "-num_wm_colors";
                    my_argv[my_argc++] = wmcolors;
                }
                else
                {
                    if(++i >= argc)++errflag;
                    else
                    {
                        strcpy(wmcolors,argv[i]);             
                        my_argv[my_argc++] = "-num_wm_colors";
                        my_argv[my_argc++] = wmcolors;
                    }
                }
            }
            else if  ( !(strncmp(argv[i],"-num_ingr_colors",16)))
            {
                if (arg[16])
                {
                    strcpy(ingrcolors,&arg[16]);
                    my_argv[my_argc++] = "-num_ingr_colors";
                    my_argv[my_argc++] = ingrcolors;
               }
                else
                {
                    if(++i >= argc)++errflag;
                    else
                    {
                        strcpy(ingrcolors,argv[i]);             
                        my_argv[my_argc++] = "-num_ingr_colors";
                        my_argv[my_argc++] = ingrcolors;
                    }
                }
            }
            else if  ( !(strncmp(argv[i],"-pd",3)))
            {
                if (arg[3])
                {
                    strcpy(pd,&arg[3]);
                    my_argv[my_argc++] = "-pd";
                    my_argv[my_argc++] = pd;
                }
                else
                {
                    if(++i >= argc)++errflag;
                    else
                    {
                        strcpy(pd,argv[i]);             
                        my_argv[my_argc++] = "-pd";
                        my_argv[my_argc++] = pd;
                    }
                }
            }
#ifdef X11
            else if  ( !(strncmp(argv[i],"-display",8)))
            {
                if (arg[8])
                {
                    strcpy(display,&arg[8]);
                    my_argv[my_argc++] = "-display";
                    my_argv[my_argc++] = display;
                }
                else
                {
                    if(++i >= argc)++errflag;
                    else
                    {
                        strcpy(display,argv[i]);             
                        my_argv[my_argc++] = "-display";
                        my_argv[my_argc++] = display;
                    }
                }
            }
#endif
            else
            {        

                switch (arg[1])
                {
                  case 'd':
                    if( ++i >= argc )  ++errflag;
                    else
                    {
                        strcpy(d_name, argv[i]);
                        switch (arg[2])
                        {
                          case 'i':
                            my_argv[my_argc++] = "-di";
                            break;
                          case '\0':                   
                            my_argv[my_argc++] = "-d";
                            break;
                        }
                        my_argv[my_argc++] = d_name;
                    }
                    break;

                  case 'f':
                    if (arg[2])
                    {
                        strcpy(f_name, &arg[2]);
                        my_argv[my_argc++] = "-f";
                        my_argv[my_argc++] = f_name;
                    }
                    else
                    {
                        if ( ++i >= argc ) 
                            ++errflag;
                        else
                        {
                            strcpy(f_name, argv[i]);
                            my_argv[my_argc++] = "-f";
                            my_argv[my_argc++] = f_name;
                        }
                    }
                    break;

                  case 'c':
                    create_flag = TRUE;
                    my_argv[my_argc++] = "-c";
                    switch( arg[2] )
                    {
                      case 'b':
                        mode = EX_BATCH;
                        my_argv[my_argc++] = "-b";
                        break;  
                      case 'd':
                        if( ++i >= argc )  ++errflag;
                        else
                        {
                            strcpy(d_name, argv[i]);
                            switch (arg[3])
                            {
                              case 'i':
                                my_argv[my_argc++] = "-di";
                                break;
                              case '\0':                   
                                my_argv[my_argc++] = "-d";
                                break;
                            }
                            my_argv[my_argc++] = d_name;
                        }
                        break;

                      case 'f':
                        if (arg[3])
                            strcpy(f_name, &arg[3]);
                        else {
                            if ( ++i >= argc ) 
                                ++errflag;
                            else
                                strcpy(f_name, argv[i]);
                        }
                        my_argv[my_argc++] = "-f";
                        my_argv[my_argc++] = f_name;
                        break;

                      case 'C':
                        if (arg[3])
                        {
                            firstcmd_flag = TRUE;
                            strcpy (c_command, &arg[3]);
                            my_argv[my_argc++] = "-C";
                            my_argv[my_argc++] = c_command;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                firstcmd_flag = TRUE;
                                strcpy (c_command, argv[i]);
                                my_argv[my_argc++] = "-C";
                                my_argv[my_argc++] = c_command;
                            }
                        }
                        break; 

                      case 'r':
                        if ((arg[3]=='n') && arg[4])
                        {
                            strcpy(r_name,&arg[4]);
                            my_argv[my_argc++] = "-rn";
                            my_argv[my_argc++] = r_name;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                strcpy(r_name,argv[i]);             
                                my_argv[my_argc++] = "-rn";
                                my_argv[my_argc++] = r_name;
                            }
                        }
                        break;

                      case 's':
                        if (arg[3])
                        {
                            strcpy(s_name,&arg[3]);
                            my_argv[my_argc++] = "-s";
                            my_argv[my_argc++] = s_name;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                strcpy(s_name,argv[i]);             
                                my_argv[my_argc++] = "-s";
                                my_argv[my_argc++] = s_name;
                            }
                        }
                        break;

                      case 'S':
                        if (arg[3])
                        {
                            strcpy(S_name,&arg[3]);
                            my_argv[my_argc++] = "-S";
                            my_argv[my_argc++] = S_name;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                strcpy(S_name,argv[i]);             
                                my_argv[my_argc++] = "-S";
                                my_argv[my_argc++] = S_name;
                            }
                        }
                        break;

                      case 'Z':
                        my_argv[my_argc++] = "-Z";
                        break;  
                    }
                    break; 

                  case 'C':
                    if (arg[2])
                    {
                        firstcmd_flag = TRUE;
                        strcpy (c_command, &arg[2]);
                        my_argv[my_argc++] = "-C";
                        my_argv[my_argc++] = c_command;
                    }
                    else
                    {
                        if( ++i >= argc ) ++errflag;
                        else
                        {
                            firstcmd_flag = TRUE;
                            strcpy (c_command, argv[i]);
                            my_argv[my_argc++] = "-C";
                            my_argv[my_argc++] = c_command;
                        }
                    }
                    break; 

                  case 'b':
                    mode = EX_BATCH;
                    my_argv[my_argc++] = "-b";

                    switch( arg[2] )
                    {
                      case 'c':
                        create_flag = TRUE;
                        my_argv[my_argc++] = "-c";
                        break;  

                      case 'd':
                        if( ++i >= argc )  ++errflag;
                        else
                        {
                            strcpy(d_name, argv[i]);
                            switch (arg[3])
                            {
                              case 'i':
                                my_argv[my_argc++] = "-di";
                                break;
                              case '\0':                   
                                my_argv[my_argc++] = "-d";
                                break;
                            }
                            my_argv[my_argc++] = d_name;
                        }
                        break;

                      case 'f':
                        if (arg[3])
                        {
                            strcpy(f_name, &arg[3]);
                            my_argv[my_argc++] = "-f";
                            my_argv[my_argc++] = f_name;
                        }
                        else
                        {
                            if ( ++i >= argc ) 
                                ++errflag;
                            else
                            {
                                strcpy(f_name, argv[i]);
                                my_argv[my_argc++] = "-f";
                                my_argv[my_argc++] = f_name;
                            }
                        }
                        break;

                      case 'C':
                        if (arg[3])
                        {
                            firstcmd_flag = TRUE;
                            strcpy (c_command, &arg[3]);
                            my_argv[my_argc++] = "-C";
                            my_argv[my_argc++] = c_command;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                firstcmd_flag = TRUE;
                                strcpy (c_command, argv[i]);
                                my_argv[my_argc++] = "-C";
                                my_argv[my_argc++] = c_command;
                            }
                        }
                        break; 

                      case 's':
                        if (arg[3])
                        {
                            strcpy(s_name,&arg[3]);
                            my_argv[my_argc++] = "-s";
                            my_argv[my_argc++] = s_name;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                strcpy(s_name,argv[i]);             
                                my_argv[my_argc++] = "-s";
                                my_argv[my_argc++] = s_name;
                            }
                        }
                        break;

                      case 'r':
                        if ((arg[3]=='n') && arg[4])
                        {
                            strcpy(r_name,&arg[4]);
                            my_argv[my_argc++] = "-rn";
                            my_argv[my_argc++] = r_name;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                strcpy(r_name,argv[i]);             
                                my_argv[my_argc++] = "-rn";
                                my_argv[my_argc++] = r_name;
                            }
                        }
                        break;

                      case 'S':
                        if (arg[3])
                        {
                            strcpy(S_name,&arg[3]);
                            my_argv[my_argc++] = "-S";
                            my_argv[my_argc++] = S_name;
                        }
                        else
                        {
                            if( ++i >= argc ) ++errflag;
                            else
                            {
                                strcpy(S_name,argv[i]);             
                                my_argv[my_argc++] = "-S";
                                my_argv[my_argc++] = S_name;
                            }
                        }
                        break;

                      case 'Z':
                        my_argv[my_argc++] = "-Z";
                        break;  
                    }
                    break;  

                  case 'p':
                    if (arg[2])
                        strcpy (product, &arg[2]);
                    else
                        if ( ++i >= argc ) 
                            ++errflag;
                        else
                            strcpy (product, argv[i]);
                    my_argv[0] = product;
                    break;

                  case 'r':
                    if ((arg[2]=='n') && arg[3])
                    {
                        strcpy(r_name,&arg[3]);
                        my_argv[my_argc++] = "-rn";
                        my_argv[my_argc++] = r_name;
                    }
                    else
                    {
                        if( ++i >= argc ) ++errflag;
                        else
                        {
                            strcpy(r_name,argv[i]);             
                            my_argv[my_argc++] = "-rn";
                            my_argv[my_argc++] = r_name;
                        }
                    }
                    break;

                  case 's':
                    if (arg[2])
                    {
                        strcpy(s_name,&arg[2]);
                        my_argv[my_argc++] = "-s";
                        my_argv[my_argc++] = s_name;
                    }
                    else
                    {
                        if( ++i >= argc ) ++errflag;
                        else
                        {
                            strcpy(s_name,argv[i]);             
                            my_argv[my_argc++] = "-s";
                            my_argv[my_argc++] = s_name;
                        }
                    }
                    break;

                  case 'S':
                    if (arg[2])
                    {
                        strcpy(S_name,&arg[2]);
                        my_argv[my_argc++] = "-S";
                        my_argv[my_argc++] = S_name;
                    }
                    else
                    {
                        if( ++i >= argc ) ++errflag;
                        else
                        {
                            strcpy(S_name,argv[i]);             
                            my_argv[my_argc++] = "-S";
                            my_argv[my_argc++] = S_name;
                        }
                    }
                    break;

                  case '?':
                    errflag++;
                    break;
       
                  case 'Z':
                    my_argv[my_argc++] = "-Z";
                    break;
                }               /* switch */
            }
        }
    }

    if(errflag)
    {
        fprintf(stderr, "usage: %s -c [-f file-name ] [-s seed-file-name] [-C first-cmd ] [-p product-name] [-S user-search-path ]\n [-display node:0.0] [-rn resource-name] [-pd product_data-path]\n [-window_depth depth] [-window_type type] [-double_buffer dbl-buffer]\n [-num_wm_colors num] [-num_ingr_colors num]",argv[0]);
        exit(0);
    }

    if( mode == EX_INTERACT )
    {
        printf(" Interactive mode\n");    
	ex$startup(argc = my_argc, argv=my_argv, mode=mode ); 
    }
    else if ( (mode == EX_BATCH) && ( f_name[0] != '\0') && 
             (firstcmd_flag == TRUE) )
    {
        /*     								*/
        /* user specified batch mode, file name and the command to execute */
        /*									*/
        ex$startup(argc = my_argc, argv=my_argv, mode=mode ); 
        create_flag = 1;

        status = ex$start_cmdserver( init = TRUE);	

        status = ex$retrieve_module(ftype = EX_visible, filename = f_name,
                                    seedfile = s_name, create = create_flag,
                                    activate = 1, 
                                    osnum = &os_num, modid = &mod_id, msg = &retmsg);
        if ( !( 1 & status) )
        {
            printf(" In main retrieve module failed \n ");
            printf(" retmsg = <%d> check exdef.h for detail\n",retmsg);
        }
        else
        {
            /*								*/
            /* note: Once cmdserver took controle, it wont return		*/
            /*	   unless a response of EX_CMDSVR_RETURN or		*/
            /*	   an exit command was found in the software queue      */
            /*								*/
            /*    make sure the you have EX_CMDSVR_RETURN or exit command */
            /*    in your command line when running batch mode.           */
            /*								*/

            status = ex$start_cmdserver( exec = TRUE);
            ex$exit( save = FALSE );
            exit(0);
	}
    }

}                               /* ige_main */
