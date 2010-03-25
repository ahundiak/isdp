#ident "%W% %G%	Copyright (c) 1987 Intergraph Corporation"

#include	<stdlib.h>
#include	<stdio.h>
#include	<signal.h>
#include	<fcntl.h>
#ifdef SYSV
#include	<inc.h>
#include	<sys/types.h>
#include	<sys/param.h>
#include	<sys/dir.h>
#include	<sys/swap.h>
#include	<sys/immu.h>
#include	<sys/stat.h>
#include	<sys/sysclip.h>
#include	<sys/sysingr.h>
#include	<sys/sr.h>
#endif
#ifdef OSF
#include	<sys/types.h>
#include	<sys/param.h>
#endif

extern errno;
extern char *optarg;
extern int optind;
char	c;
int	val, val1;
int	ret, status=0xff;

/*
 * inqcptype
 * Try an inc call to figure out if we're booted on a streams kernel or not.
 */
/* ARGSUSED */
int	inqcptype(argc, argv)
int	argc;
char	*argv[];
{
	int	fd;

	if ((fd = t_open("/dev/xs", O_RDWR, NULL)) < 0)
		printf("IOP\n");
	else
		printf("STREAMS\n");

	return(0);
}

/*
 * inqcpuid
 * This utility simply asks the kernel the id of the cpu.
 */
/* ARGSUSED */
int	inqcpuid(argc, argv)
int	argc;
char	*argv[];
{
	if (getcpuid(&ret) < 0)
		return(2);

	/* Mask out upper bits because sometimes funky stuff gets
	 * in there (C300 can return 34, C400 can return 132, etc)
	 */

	switch (ret & 0x0f) {
	case 0:
		printf("C100\n");
		break;
	case 1:
		printf("C200\n");
		break;
	case 2:
		printf("C300\n");
		break;
	case 4:
		printf("C400\n");
		break;
	default:/* unknown */
		printf("CPU ID: %d\n", ret);
		break;
	}
	return(0);
}

/*
 * inqfpeg
 * This utility simply asks the kernel how many graphic FPE's exist to him. If
 * there is 1 or more, then the utility exits with a successful status (0).
 * If there are no graphic FPE's, or an error occurs, then the utility exits
 * with a status of failure (non 0). If the utility is invoked with the -n
 * option, the number of ROPs will be displayed on the standard output. The exit
 * status is still valid with the -n option.
 */
int	inqfpeg(argc, argv)
int	argc;
char	*argv[];
{
	val = syscall(SYSINGR, SINGRNFPE_G, &ret);
	if (val < 0)
		return(2);
	if (val)
		status=0;

	while ((c = getopt(argc, argv, "n")) != EOF)
		switch (c) {
			case 'n':
				printf("%d\n", val);
				break;
			default:
				printf("Usage: %s [-n]\n", argv[0]);
				return(2);
		}
	return(status);
}

/*
 * inqfpen
 * This utility simply asks the kernel how many numeric FPE's exist to him. If
 * there is 1 or more, then the utility exits with a successful status (0).
 * If there are no numeric FPE's, or an error occurs, the utility exits with
 * a status of failure (non 0). If the utility is invoked with the -n option,
 * the number of numeric FPE's will be displayed on the standard output.
 * The exit status is still valid with the -n option.
 */
int	inqfpen(argc, argv)
int	argc;
char	*argv[];
{
	val = syscall(SYSINGR, SINGRNFPE_N, &ret);
	if (val < 0)
		return(2);
	if (val)
		status=0;

	while ((c = getopt(argc, argv, "n")) != EOF)
		switch (c) {
			case 'n':
				printf("%d\n", val);
				break;
			default:
				printf("Usage: %s [-n]\n", argv[0]);
				return(2);
		}
	return (status);
}

/*
 * inqifb
 * This utility simply asks the kernel how many IFB's exist to him. If
 * there is 1 or more, then the utility exits with a successful status (0).
 * If there are no IFB's, or an error occurs, then the utility exits with
 * a status of failure (non 0). If the utility is invoked with the -n option,
 * the number of IFB's will be displayed on the standard output. The exit
 * status is still valid with the -n option.
 */
int	inqifb(argc, argv)
int	argc;
char	*argv[];
{
	val = syscall(SYSINGR, SINGRNIFB, &ret);
	if (val < 0)
		return(2);
	if (val)
		status=0;

	while ((c = getopt(argc, argv, "n")) != EOF)
		switch (c) {
			case 'n':
				printf("%d\n", val);
				break;

			default:
				printf("Usage: %s [-n]\n", argv[0]);
				return(2);
		}
	return (status);
}

/*
 * inqifbtype
 * This utility simply asks the kernel what type of IFB is on the system
 * and prints the type.
 */
char *ifb_type[] = {
		"IFB_2MEG_1MPIX",
		"IFB_8MEG_1MPIX",
		"IFB_8MEG_2MPIX",
		"IFB_SFB",
		"EDGE_M1_1MPIX",
		"EDGE_M1_2MPIX",
		"EDGE_M2_1MPIX",
		"EDGE_M2_2MPIX",
};
#define NIFBTYPES	(sizeof(ifb_type) / sizeof(char *))

/* ARGSUSED */
int	inqifbtype(argc, argv)
int	argc;
char	*argv[];
{
	if (syscall(SYSINGR, SINGRNIFB, &ret) < 0) {
		printf("IFB_UNKNOWN\n");
		return(-1);
	}
	val = syscall(SYSINGR, SINGRIFBTYPE);
	if ((val < 0) || (val >= NIFBTYPES))
		printf("IFB_UNKNOWN\n");
	else
		printf("%s\n", ifb_type[val]);
	return(val);
}

/*
 * inqiop
 * This utility simply asks the kernel what type of IO processor there is.
 * It will display 80186 on stdout in the case that there is an Intel 80186
 * doing the IO, or 80386 for Intel 80386.
 */
/* ARGSUSED */
int	inqiop(argc, argv)
int	argc;
char	*argv[];
{
	register val;
	int ret;

	val = syscall(SYSINGR, SINGRIOPTYPE, &ret);

	switch(val) {
	case 0:
		printf("80186\n");
		break;
	case 1:
		printf("80386\n");
		break;
	case 2:
	case 3:
		printf("Clipper\n");
		break;
	default:
		printf("Unknown IOP: %d\n", val);
		break;
	}

	return (0);
}

/*
 * inqmemory
 * This utility simply asks the kernel how much memory exists to him and prints
 * it out on standard output. The value displayed is memory minus the amount
 * used for z buffering.
 */
/* ARGSUSED */
int	inqmemory(argc, argv)
int	argc;
char	*argv[];
{
	val = syscall(SYSINGR, SINGRMEMSIZE, &ret);
	if (val < 0)
		return(2);

	printf("%d\n", val);

	return (0); /* better always have memory! */
}

/*
 * inqrop
 * This utility simply asks the kernel how many ROP's exist to him. If
 * there is 1 or more, then the utility exits with a successful status (0).
 * If there are no ROPs, or an error occurs, then the utility exits with
 * a status of failure (non 0). If the utility is invoked with the -n option,
 * the number of ROPs will be displayed on the standard output. The exit
 * status is still valid with the -n option.
 */
int	inqrop(argc, argv)
int	argc;
char	*argv[];
{
	val = syscall(SYSINGR, SINGRNROP, &ret);
	if (val < 0)
		return(2);
	if (val)
		status=0;

	while ((c = getopt(argc, argv, "n")) != EOF)
		switch (c) {
			case 'n':
				printf("%d\n", val);
				break;
			default:
				printf("Usage: %s [-n]\n", argv[0]);
				return(2);
		}
	return (status);
}

/*
 * inqscreens
 * This utility simply asks the kernel how many SCREENS's exist to him. If
 * there is 1 or more, then the utility exits with a successful status (0).
 * If there are no SCREENS, or an error occurs, then the utility exits with
 * a status of failure (non 0). If the utility is invoked with the -n option,
 * the number of SCREENS will be displayed on the standard output. The exit
 * status is still valid with the -n option.
 */
int	inqscreens(argc, argv)
int	argc;
char	*argv[];
{
	val = syscall(SYSINGR, SINGRNSCREEN, &ret);
	if (val < 0)
		return(2);
	if (val)
		status=0;

	while ((c = getopt(argc, argv, "n")) != EOF)
		switch (c) {
			case 'n':
				printf("%d\n", val);
				break;
			default:
				printf("Usage: %s [-n]\n", argv[0]);
				return(2);
		}
	return (status);
}


/*
 * inqdiskless
 * This routine uses the SINGRDISKLESS system call to ask the kernel if the
 * system is running in a diskless configuration or not.  If so , then the
 * root directory, swap file and server are printed to stdout and the program
 * exits with status 0.  Otherwise, the program exits with status 1.

 * No longer needed -- Diskless is dead.

 */

/* ARGSUSED */
int	inqdiskless(argc, argv)
int	argc;
char 	*argv[];
{
#ifdef DISKLESS
	int val;
	struct singrdiskless sd;
	
	val = syscall(SYSINGR, SINGRDISKLESS, &sd);

	if (val == 0) {
		printf("Workstation is not running as a diskless client.\n");
		return(1);
	}
	else {
		printf("Diskless server:\t%s\n", sd.serv_name);
		printf("Diskless root_dir:\t%s\n", sd.root_dir);
		printf("Diskless swap_file:\t%s\n", sd.swap_file);
		return(0);
	} 
#else
	return(1);
#endif
}

/*
 * inqswap
 * This utility simply asks the kernel how much SWAP space exists to him.
 * If there is no swap space known to the kernel, then the utility will
 * exit with a failure status (non 0).
 * Normally, the utility writes to the standard output the total swap space,
 * however, if the utility is invoked with the -f option, the number of free
 * swap blocks is also displayed.
 * The status is still valid with the -n option.
 *
 * Whether or not this feature is portable to OSF/1 is a big
 * question.
 */
int	inqswap(argc, argv)
int	argc;
char	*argv[];
{
#ifdef SYSV
	register swpt_t	*st;
	register swpi_t	*si;
	register int	i;
	swpt_t	swaptab[MSFILES];
	swpi_t	swpi;
	int	total_swap=0, total_free=0;

	st = swaptab;
	si = &swpi;
	si->si_cmd = SI_LIST;
	si->si_buf = (char *)st;

	val = syscall(SYSCLI, SCLISWPI, si);
	if (val < 0)
		return(2);

	for (i = 0; i < MSFILES; i++, st++) {
		if (st->st_ucnt == NULL)
			continue;
		total_swap += st->st_npgs << DPPSHFT;
		total_free += st->st_nfpgs << DPPSHFT;
	}

	if (total_swap)
		status=0;

	while ((c = getopt(argc, argv, "f")) != EOF)
		switch (c) {
			case 'f':
				printf("%d free from ", total_free);
				break;
			default:
				printf("Usage: %s [-f]\n", argv[0]);
				return(2);
		}
	printf("%d\n", total_swap);
#endif
	return (status);
}

/*
 * inqws
 * This utility simply asks the kernel what series of workstation that it's
 * running on. It will display "32C" for the 32C line, "200" for the 200 line
 * or "300" for the 300 line.
 *
 * Support for inqws was removed in september roll - this code excluded

int	inqws(argc, argv)
int	argc;
char	*argv[];
{
	register val;
	int ret;

	val = syscall(SYSINGR, SINGRMSERIES, &ret);

	if (val == 0)
		printf("32C\n");
	else if (val == 200)
		printf("200\n");
	else if (val == 300)
		printf("300\n");
	else
		printf("Unknown workstation series: %d\n", val);

	return (0);
}
*/

/*
 * inqzbuf
 * This utility simply asks the kernel where (if any) ZBUF memory exists. If
 * there is any, then the utility exits with a successful status (0).
 * If there is none, or an error occurs, then the utility exits with
 * a status of failure (non 0). If the utility is invoked with the -w option,
 * the location of the ZBUF will be displayed on the standard output. The exit
 * status is still valid with the -w option.
 */
int	inqzbuf(argc, argv)
int	argc;
char	*argv[];
{
	val = syscall(SYSINGR, SINGRZBUF, &ret);
	if (val < 0)
		return(2);
	if (val)
		status=0;

	while ((c = getopt(argc, argv, "nw")) != EOF)
		switch (c) {
			case 'n':
				printf("%d\n", val);
				break;
			case 'w':
				if (val == 0)
					printf("No Z buffer.\n");
				else if (val == 1)
					printf("Z buffer in memory.\n");
				else if (val == 2)
					printf("Z buffer on IFB.\n");
				else
					printf("Unknown Z buffer value: %d.\n", val);
				break;
			default:
				printf("Usage: %s [-n | -w]\n", argv[0]);
				return(2);
		}
	return (status);
}

/*
 * inqgra
 * display the graphics type
 */

/* XXX  DANGER!  Using PRELIMINARY Values for SINGRNS3 and SINGRS3TYPE!!! */

#define SINGRNS3	41
#define SINGRS3TYPE	42
#define S3_928		0

int	inqgra(argc, argv)
int	argc;
char	*argv[];
{
    int	ifbval = 0;
    int	mmgval = 0;
    int s3val = 0;
    int	typeval;
    int	mmgtype = 0;
    int s3type = 0;

    /* find out how many rops we have */
    val = syscall(SYSINGR, SINGRNROP, &ret);
    if (!val) {
	ifbval = syscall(SYSINGR, SINGRNIFB, &ret);
	if (!ifbval) {
	    mmgval = syscall(SYSINGR, SINGRNMMG, &ret);
	    if (!mmgval) {
		s3val = syscall(SYSINGR, SINGRNS3, &ret);
		if (s3val < 0)
			s3val = 0;
	    }
	}
    }

    if (argc == 1 && val > 0)
	printf("ROP\n");

    if (argc == 1 && s3val > 0) {
	s3type = syscall(SYSINGR, SINGRS3TYPE, &ret);
	switch (s3type) {
	    case S3_928:
	    default:
		printf("S3928\n");
		break;
	}
    }

    if (argc == 1 && mmgval > 0) {
	mmgtype = syscall(SYSINGR, SINGRMMGTYPE, &ret);
	switch(mmgtype) {
	    case MMG_GT:
	    default:
		printf("MMG\n");
		break;
	    case MMG_GTII:
		printf("GTII\n");
		break;
	    case MMG_GTPLUS:
		printf("GTPLUS\n");
		break;
	}
    }


    /* syscalls gave errors -- return with an error */
    if ((val || ifbval || mmgval || s3val) < 0)
	    return(2);

    if (val || ifbval || mmgval || s3val)
	    status = 0;

    /* if no rops and no ifbs, then must be a server */
    if (!val && !ifbval && !mmgval && !s3val && argc == 1)
	    printf("NONE\n");

    /* find out the type of IFB present */
    if (argc == 1 && ifbval > 0) {
	typeval = syscall(SYSINGR, SINGRIFBTYPE);
	switch (typeval) {
	    case 0:	/* 2MEG - 1MPIX */
	    case 1: /* 8MEG - 1MPIX */
	    case 2: /* 8MEG - 2MPIX */
		printf("IFB\n");
		break;
	    case 3:	/* SFB */
		printf("SFB\n");
		break;
	    case 4: /* ED/GE MARK 1 - 1MPIX */
	    case 5: /* ED/GE MARK 1 - 2MPIX */
	    case 6: /* ED/GE MARK 2 - 1MPIX */
	    case 7: /* ED/GE MARK 2 - 2MPIX */
		printf("EDGE\n");
		break;
	    default:
		printf("IFB:%d\n", typeval); 
		break;
	}
    }

    while ((c = getopt(argc, argv, "nt")) != EOF)
	switch(c) {
	    case 'n':
		if (val)
		    printf("%d\n", val);
		else if (ifbval)
		    printf("%d\n", ifbval);
		else if (mmgval)
		    printf("%d\n", mmgval);
		else if (s3val)
		    printf("%d\n", s3val);
		else 
		    printf("0\n");
		break;
	    case 't':
		if (!val && !ifbval && !mmgval && !s3val)
		    printf("NONE\n");
		else if (val)
		    printf("ROP\n");
		else if (mmgval)
		    printf("MMG\n");
		else if (s3val)
		    printf("S3\n");
		else if ((typeval < 0) || (typeval>=NIFBTYPES))
		    printf("IFB_UNKNOWN\n");
		else
		    printf("%s\n", ifb_type[typeval]);
		    break;
	    default:
		printf("Usage: %s [-n | -t]\n", argv[0]);
		return(2);
	}

    return (status);
}

/* ARGSUSED */
int	inqsecure(argc, argv)
int	argc;
char	*argv[];
{
    /* Switch logic for the Korn Shell, yuck!
     * and if it is a secure system see if you have a luid
     */
    
    if ( trustlevel() )	{
	if( getluid() < 0 ) { /* Then we are probably coming up in inittab */
	    printf("1\n");   /* Allow the scripts to run */
	    return(1);
	}
	else {
	    printf("0\n");
	    return(0);
	}
    }
    else {
	printf("1\n");
	return(1);
    }
}


void	sigbad() {
	exit(255);
}

int	main(argc, argv)
int	argc;
char	*argv[];
{
	char *cp;

	if ((cp = (char *)strrchr(argv[0], '/')) == NULL)
		cp = (char *)argv[0];
	else
		cp++;

	signal(SIGSYS, (void (*)())sigbad);

	if (!strcmp(cp, "inqfpeg"))
		exit (inqfpeg(argc, argv));
	else if (!strcmp(cp, "inqfpen"))
		exit (inqfpen(argc, argv));
	else if (!strcmp(cp, "inqifb"))
		exit (inqifb(argc, argv));
	else if (!strcmp(cp, "inqifbtype"))
		exit (inqifbtype(argc, argv));
	else if (!strcmp(cp, "inqiop"))
		exit (inqiop(argc, argv));
	else if (!strcmp(cp, "inqmemory"))
		exit (inqmemory(argc, argv));
	else if (!strcmp(cp, "inqrop"))
		exit (inqrop(argc, argv));
	else if (!strcmp(cp, "inqscreens"))
		exit (inqscreens(argc, argv));
#ifdef SYSV
	else if (!strcmp(cp, "inqswap"))
		exit (inqswap(argc, argv));
#endif
 	else if (!strcmp(cp, "inqcpuid"))
		exit (inqcpuid(argc, argv));
	else if (!strcmp(cp, "inqzbuf"))
		exit (inqzbuf(argc, argv));
	else if (!strcmp(cp, "inqgra"))
		exit (inqgra(argc, argv));
	else if (!strcmp(cp, "inqcptype"))
		exit (inqcptype(argc, argv));
	else if (!strcmp(cp, "inqdiskless"))
		exit (inqdiskless(argc, argv));
	else if (!strcmp(cp, "inqsecure"))
		exit (inqsecure(argc, argv));
	else
		printf("Unknown inquiry: %s\n", argv[0]);
	exit(1);
}
