/*
*	mkmk driver for NT.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>
#include <malloc.h>

extern int	optind;
extern char	*optarg;
extern int	getopt();

static void	print_usage(void)
{
	fprintf(stderr, "usage: makemake [-D definename ...] [-i ignorefile] [-v] test.m [makefile]\n");
}

static char	*getTempFileName(void)
{
	static char	name[_MAX_PATH] = { 0 };

	if (!name[0])
	{
		char	*tmpdir = 0;
		char	pid[512];
		
		if (!(tmpdir = getenv("TMP")))
		{
			fprintf(stderr, "makemake: error: TMP env variable not set\n");
			exit(1);
		}
		strcpy(name, tmpdir);
		strcat(name, "\\DES");
		sprintf(pid, "%d", _getpid());
		strcat(name, pid);
	}
	return name;
}

static int	removeFile(char *name)
{
	char	buf[4096];

#ifdef NT
	strcpy(buf, "del/q ");
#else
	strcpy(buf, "rm ");
#endif
	strcat(buf, name);
	strcat(buf, " 2>nul");
	return system(buf);
}


static char	*getPreprocessedFile(char *dopt, char *infile)
{		
	/*
	*	Spawn the compiler to preprocess the input
	*	specfile.
	*/

	int	ret;
	char	buf[4096];
	char	*name;
	
	strcpy(buf, "cl ");
	strcat(buf, dopt);
	strcat(buf, " /EP");
	strcat(buf, " /c");
	strcat(buf, " /nologo");
	strcat(buf, " /Tc ");
	strcat(buf, infile);
	strcat(buf, " > ");
	strcat(buf, name = getTempFileName());

	if (0 != (ret = system(buf)))
	{
		fprintf(stderr, "makemake: error: unable to preprocess: %s\n", infile);
		fprintf(stderr, "\"%s\"\n", buf);
		fprintf(stderr, "ret = %d\n", ret);
		exit(ret);
	}
	return name;
}

static int	mkmk(char *infile, char *outfile, char *ignore_file, int verbose, char *path, char nowhy)
{
	char	buf[4096];
	int	ret = 0;
	
	if (path)
	{
		strcpy(buf, path);
		strcat(buf, "mkmk");
	}
	else
		strcpy(buf, "mkmk");
	if (ignore_file)
	{
		strcat(buf, " -i ");
		strcat(buf, ignore_file);
	}
	if (verbose)
		strcat(buf, " -v");

	if (nowhy)
		strcat(buf, " -w");
		
	strcat(buf, " -o ");
	strcat(buf, outfile);
	strcat(buf, " ");
	strcat(buf, infile);
	if (0 != (ret = system(buf)))
	{
		fprintf(stderr, "makemake: error: mkmk failed\n");
		fprintf(stderr, "\"%s\"\n", buf);
		fprintf(stderr, "ret = %d\n", ret);
	}
	return ret;
}

static char	*getdir(char *path)
{
	char	*separator = 0;
	char	*dir = 0;
	
	if (separator = strrchr(path, '\\'))
	{
		dir = strcpy(malloc(strlen(path)+1), path);
		separator = strrchr(dir, '\\');
		++separator;
		*separator = 0;
	}
	return dir;
}

main(int argc, char *argv[])
{
	int	c;
	char	dopt[4096];
	char	*ignore_file = 0;
	int	verbose = 0;
	int	ret = 0;
        char    nowhy=0; /* By default, add WHY clause to makefile */
	
	dopt[0] = 0;
	while (EOF != (c = getopt(argc, argv, "D:i:vw")))
		switch(c)
		{
		case 'D':
			strcat(dopt, " /D");
			strcat(dopt, optarg);
			break;
			
		case 'i':
			ignore_file = optarg;
			break;
			
		case 'v':
			verbose = 1;
			break;
			
		case 'w':
			nowhy = 1; /* Don't want WHY clause in makefile */
			break;
			
		case '?':
		default:
			print_usage();
			exit(1);
		}

	if (optind < argc)
	{
		char	*inname = 0;
		char	*outname = 0;
		
		inname = getPreprocessedFile(dopt, argv[optind]);
		++optind;
		if (!argv[optind])
			outname = "makefile";
		else
			outname = argv[optind];
		ret = mkmk(inname, outname, ignore_file, verbose, getdir(argv[0]), nowhy);
		removeFile(inname);
		if (ret)
			removeFile(outname);
	}
	else
	{
		print_usage();
		exit(1);
	}
	return ret;
}

