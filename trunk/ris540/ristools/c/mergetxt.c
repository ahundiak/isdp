/*
**	NAME:							merge.c
**	AUTHORS:						Terrence D. McIntyre
**	CREATION DATE:					11/93
**	ABSTRACT: 
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <ctype.h>
#include <time.h>

/*
**	DEFINES
*/
#define EXE					"mergetxt"
#define RIS_MAX_ERROR_NAME	40
#define RIS_MAX_ERROR_MSG	160
#define RIS_MAX_PATH_SIZE	256

#define DBG(s)				if (debug) printf s
#define STRING(s)			((s) ? (s) : "NULL")

#define RIS					0
#define NET					1
#define UTL					2
#define TYPE_COUNT			3

#define SOURCE				0
#define TARGET				1

#define UMS_HEADER			"::UMS"

#if defined(sun)
#define MEMORY		char *
#elif defined(unix)
#define MEMORY		void *
#endif

/*
**	TYPES
*/
typedef struct error_s
{
	char name[RIS_MAX_ERROR_NAME + 1];
	char msg[RIS_MAX_ERROR_MSG + 1];
	struct error_s *next;
} error_s;

typedef struct file_s
{
	int		count;
	error_s	*error;
	error_s	**current;
	error_s	**sorted;
	error_s *diff;
} file_s;

typedef struct data_s
{
	int		type;
	char	*cmdline;
	char	*indexname;
	char	*indexvalue;
	char	*targetfile;
	char	**sourcefile;
	int		sourcefilecount;
} data_s;

/*
**	FUNCTION PROTOTYPES
*/

/*
**	VARIABLES
*/

int debug = 0;
char *risdevdir = NULL;
extern int errno;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void printcopyright(
	FILE *fp)
{
	time_t clock;
	struct tm *tm;
	static char *copyright[3] = 
	{
		"#\n",
		"# Copyright %d, Intergraph Corporation, All Rights Reserved\n",
		"#\n"
	};

	clock = time(NULL);
	tm = localtime(&clock);	

	fprintf(fp, copyright[0]);
	fprintf(fp, copyright[1], tm->tm_year + 1900);
	fprintf(fp, copyright[2]);
}

/******************************************************************************/

static int compare(
	const void *error1,
	const void *error2)
{
	return strcmp((*((error_s **)error1))->name,(*((error_s **)error2))->name);
}

/******************************************************************************/

static int read_file(
	int		type,			/* target or source */
	char	*filename,
	char	*indexname,
	char	*indexvalue,
	file_s	*file)
{
	int			line;
	int			prefixlen;
	int			validindex;

	char		*s;
	char		*tok;
	char		*msg;
	char		*name;
	char		prefix[32];
	char		buffer[300];
	char		orgbuffer[300];
	FILE		*fp;

	DBG(("read_file(type:%d filename:<%s> )\n", type, STRING(filename)));


	/* filename */
	if ((fp = fopen(filename, "r")) == NULL)
	{
		fprintf(stderr, "Error opening file: \"%s\"\n", filename);
		return 1;
	}

	/* reset line number */
	line = 0;

	if (type == TARGET)
	{
		if (fgets(orgbuffer, 300, fp) == NULL)
		{
			fprintf(stderr, "\"%s\",line:%d: Unexpected EOF\n", filename,
				line);
			return 1;
		}
		line++;
		if ((s = strchr(orgbuffer, '\n')) != NULL) *s = '\0';
		strcpy(buffer, orgbuffer);

		if ((tok = strtok(buffer, " \t\n")) == NULL || strcmp(tok, UMS_HEADER))
		{
			fprintf(stderr, "\"%s\",line:%d: Expected \"%s\", got \"%s\"\n",
				filename, line, UMS_HEADER, orgbuffer);
			return 1;
		}

		validindex = 0;
		while(1)
		{
			if (fgets(orgbuffer, 300, fp) == NULL)
			{
				fprintf(stderr, "\"%s\",line:%d: Unexpected EOF\n", filename,
					line);
				return 1;
			}
			line++;
			if (orgbuffer[0] == '#' || orgbuffer[0] == '\n') continue;
			if ((s = strchr(orgbuffer, '\n')) != NULL) *s = '\0';
			strcpy(buffer, orgbuffer);

			if ((tok = strtok(buffer, " \t\n")) == NULL) break;
			if (strcmp(tok, indexname)) break;
			if ((tok = strtok(NULL, " \t\n")) == NULL) break;
			if (strcmp(tok, indexvalue)) break;

			validindex = 1;
			break;
		}
		if (!validindex)
		{
			fprintf(stderr,
				"\"%s\",line:%d: Expected \"%s %s\", got \"%s\"\n",
				filename, line, indexname, indexvalue, orgbuffer);
			return 1;
		}
	}

	prefixlen = sprintf(prefix, "%s_", indexname);

	while(fgets(orgbuffer, 300, fp) != NULL)
	{
		line++;
		if (orgbuffer[0] == '#' || orgbuffer[0] == '\n') continue;
		if ((s = strchr(orgbuffer, '\n')) != NULL) *s = '\0';
		strcpy(buffer, orgbuffer);

		if (strncmp(buffer, prefix, prefixlen))
		{
			fprintf(stderr,
				"\"%s\",line:%d: Expected \"%s...\", got \"%s\"\n",
				filename, line, prefix, orgbuffer);
			return 1;
		}

		s = buffer;
		name = buffer;
		while(*s && !isspace(*s))
		{
			s++;
		}

		if (*s)
		{
			*s++ = '\0';
			/* skip white space */
			while(*s && isspace(*s))
			{
				s++;
			}
			msg = s;
		}
		else
		{
			msg = "";
		}

		if ((int)strlen(name) > RIS_MAX_ERROR_NAME)
		{
			fprintf(stderr, "\"%s\",line:%d: Error name too long: \"%s\"\n",
				filename, line, name);
			return 1;
		}

		if ((int)strlen(msg) > RIS_MAX_ERROR_MSG)
		{
			fprintf(stderr, "\"%s\",line:%d: Error message too long: \"%s\"\n",
				filename, line, msg);
			return 1;
		}

		(*(file->current)) = (error_s *)malloc(sizeof(error_s));
		strcpy((*(file->current))->name, name);
		strcpy((*(file->current))->msg, msg);
		(*(file->current))->next = NULL;
		file->current = &((*(file->current))->next);

		file->count++;
	}
	fclose(fp);

	return 0;
}

/******************************************************************************/

static int sort_file(
	file_s *file)
{
	int i;
	error_s *ptr;

	file->sorted = (error_s **)malloc(file->count * sizeof(error_s *));

	for (i = 0, ptr = file->error; i < file->count && ptr; i++, ptr = ptr->next)
	{
		file->sorted[i] = ptr;
	}

	if (i < file->count || ptr)
	{
		fprintf(stderr, "file->count:%d inconsistent with linked list.\n",
			file->count);	
		return 1;
	}

	qsort(file->sorted, file->count, sizeof(error_s *), compare);

	for (i = 1; i < file->count; i++)
	{
		if (!strcmp(file->sorted[i]->name, file->sorted[i-1]->name))
		{
			file->sorted[i-1] = NULL;	
		}
	}
	return 0;
}

/******************************************************************************/

static void merge_files(
	file_s *target,
	file_s *source,
	int	mflag)
{
	int sts;
	int itarget;
	int isource;
	int msgchange = 0;
	error_s *ptr;
	error_s **added;
	error_s **missing;

	itarget = 0;
	isource = 0;

	missing = &source->diff;
	added = &target->diff;
	while(1)
	{
		while(itarget < target->count && target->sorted[itarget] == NULL)
			itarget++;
		while(isource < source->count && source->sorted[isource] == NULL)
			isource++;
		if (itarget >= target->count || isource >= source->count)
			break;

		sts = strcmp(target->sorted[itarget]->name,
			source->sorted[isource]->name);
		if (sts < 0)
		{
			(*missing) = (error_s *)malloc(sizeof(error_s));
			memcpy((MEMORY)(*missing), (MEMORY)target->sorted[itarget],
				sizeof(error_s));
			(*missing)->next = NULL;
			missing = &((*missing)->next);
			itarget++;
		}
		else if (sts > 0)
		{
			(*added) = (error_s *)malloc(sizeof(error_s));
			memcpy((MEMORY)(*added), (MEMORY)source->sorted[isource],
				sizeof(error_s));
			(*added)->next = NULL;
			added = &((*added)->next);
			isource++;	
		}
		else
		{
			if (strcmp(target->sorted[itarget]->msg,
				source->sorted[isource]->msg))
			{
				if (msgchange == 0)
				{
					printf("\n\nMESSAGE CHANGE ONLY:\n");
				}
				printf("%s\n",
					target->sorted[itarget]->name);
				printf("  from: \"%s\"\n", target->sorted[itarget]->msg);
				printf("  to  : \"%s\"\n", source->sorted[isource]->msg);

				strcpy(target->sorted[itarget]->msg,
					source->sorted[isource]->msg);

				msgchange++;
			}
			itarget++;
			isource++;	
		}
	}

	while(1)
	{
		while(itarget < target->count && target->sorted[itarget] == NULL)
			itarget++;
		if (itarget >= target->count)
			break;

		(*missing) = (error_s *)malloc(sizeof(error_s));
		memcpy((MEMORY)(*missing), (MEMORY)target->sorted[itarget],
			sizeof(error_s));
		(*missing)->next = NULL;
		missing = &((*missing)->next);
		itarget++;
	}

	while(1)
	{
		while(isource < source->count && source->sorted[isource] == NULL)
			isource++;
		if (isource >= source->count)
			break;

		(*added) = (error_s *)malloc(sizeof(error_s));
		memcpy((MEMORY)(*added), (MEMORY)source->sorted[isource],
			sizeof(error_s));
		(*added)->next = NULL;
		added = &((*added)->next);
		isource++;	
	}

	if (target->diff)
	{
		printf("\n\nMESSAGE%s ADDED TO TARGET FILE:\n",
			target->diff->next ? "S" : "");
		for (ptr = target->diff; ptr; ptr = ptr->next)
		{
			printf("%s \"%s\"\n", ptr->name, ptr->msg);
		}
	}

	if (mflag)
	{
		if (source->diff)
		{
			printf("\n\nMESSAGE%s MISSING FROM SOURCE FILE%s:\n",
				source->diff->next ? "S" : "", mflag > 1 ? "S" : "");
			for (ptr = source->diff; ptr; ptr = ptr->next)
			{
				printf("%s \"%s\"\n", ptr->name, ptr->msg);
			}
		}
	}

	printf("\n\n");
}

/******************************************************************************/

static int write_file(
	char	*filename,
	char	*indexname,
	char	*indexvalue,
	file_s *file)
{
	error_s	*ptr;
	FILE	*fp;

	if ((fp = fopen(filename, "w")) == NULL)
	{
		fprintf(stderr, "Unable to open \"%s\" to write: %s\n",
			strerror(errno));
		return 1;
	}

	fprintf(fp, "%s\n", UMS_HEADER);
	printcopyright(fp);
	fprintf(fp, "%s %s\n", indexname, indexvalue);

	for (ptr = file->error; ptr; ptr = ptr->next)
	{
		fprintf(fp, "%s %s\n", ptr->name, ptr->msg);
	}

	for (ptr = file->diff; ptr; ptr = ptr->next)
	{
		fprintf(fp, "%s %s\n", ptr->name, ptr->msg);
	}

	fclose(fp);

	return 0;
}

/******************************************************************************/

extern int merge(
	data_s	*data,
	int		mflag)
{
	int		i;
	char	filename[RIS_MAX_PATH_SIZE];
	file_s	target;
	file_s	source;


	/* SOURCE */
	memset((MEMORY)&source, '\0', sizeof(source));
	source.current = &source.error;

	printf("\n\nSOURCE FILE%s:\n", data->sourcefilecount > 1 ? "S" : "" );
	for (i = 0; i < data->sourcefilecount; i++)
	{
		sprintf(filename, "%s/%s", risdevdir, data->sourcefile[i]);

		printf("\t%s\n", filename);
		if (read_file(SOURCE, filename, data->indexname, data->indexvalue,
			&source))
			return 1;
		if (sort_file(&source))
			return 1;
	}

	/* TARGET */
	memset((MEMORY)&target, '\0', sizeof(target));
	target.current = &target.error;
	sprintf(filename, "%s/%s", risdevdir, data->targetfile);

	printf("\n\nTARGET FILE:\n");
	printf("\t%s\n", filename);

	if (read_file(TARGET, filename, data->indexname, data->indexvalue, &target))
		return 1;
	if (sort_file(&target))
		return 1;

	merge_files(&target, &source, mflag);

	if (write_file(filename, data->indexname, data->indexvalue, &target))
		return 1;

	return 0;
}

/******************************************************************************/

static void Usage(
	data_s data[])
{
	int i;

	fprintf(stderr, "Usage: %s [-m] {", EXE);
	for (i = 0; i < TYPE_COUNT - 1; i++)
	{
		fprintf(stderr, "%s|", data[i].cmdline);
	}
	fprintf(stderr, "%s}\n", data[i].cmdline);
	fprintf(stderr, "    -m display messages missing from source files\n");
}

/******************************************************************************/

extern int main(
	int argc,
	char *argv[])
{
	int i;
	int j;
	int type = -1;
	int mflag = 0;
	static char *rissource[] =
	{
		"riscom/config/english/messages/src/risdyn.txt",
		"riscom/config/english/messages/src/riserr.txt",
		"riscom/config/english/messages/src/risinf.txt",
		"riscom/config/english/messages/src/rispmt.txt",
		"riscom/config/english/messages/src/ristpg.txt"
	};
	static char *netsource[] =
	{
		"riscom/config/english/messages/src/risnet.txt"
	};
	static char *utlsource[] =
	{
		"risutl/config/english/messages/src/risutl.txt"
	};
	data_s data[TYPE_COUNT] =
	{
		{
			RIS,
			"ris",
			"RIS",
			"660",
			"riscom/config/english/messages/ris.txt",
			rissource,
			(sizeof(rissource)/sizeof(char *))
		},
		{
			NET,
			"net",
			"NET",
			"461",
			"riscom/config/english/messages/net.txt",
			netsource,
			(sizeof(netsource)/sizeof(char *))
		},
		{
			UTL,
			"utl",
			"RISUTL",
			"462",
			"risutl/config/english/messages/utl.txt",
			utlsource,
			(sizeof(utlsource)/sizeof(char *))
		},
	};

	for (i = 1; i < argc; i++)
	{
		if (!strcmp(argv[i], "-db"))
		{
			if (debug)
			{
				Usage(data);
				return 1;
			}
			debug = 1;
		}
		else if (!strcmp(argv[i], "-m"))
		{
			if (mflag)
			{
				Usage(data);
				return 1;
			}
			mflag = 1;
		}
		else if (type != -1)
		{
			Usage(data);
			return 1;
		}
		else
		{
			for (j = 0; j < TYPE_COUNT; j++)
			{
				if (!strcmp(argv[i], data[j].cmdline))
				{
					type = j;
					break;
				}
			}
			if (j == TYPE_COUNT)
			{
				Usage(data);
				return 1;
			}
		}
	}

	if (type == -1)
	{
		Usage(data);
		return 1;
	}

	if ((risdevdir = getenv("RISDEVDIR")) == NULL)
	{
		fprintf(stderr, "RISDEVDIR must be defined\n");
		return 1;
	}

	if (mflag)
	{
		mflag = data[type].sourcefilecount;
	}

	if (merge(&data[type], mflag))
		return 1;

	return 0;
}

/******************************************************************************/
