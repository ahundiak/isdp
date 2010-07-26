/*
*	UNIX tee clone.
*/
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#define BUFSIZE	4096

char	*Image = "tee";
int	Errors = 0;

static void	usage(void)
{
	fprintf(stderr, "usage: %s [-a] file\n", Image);
	exit(++Errors);
}

int	main(int argc, char *argv[])
{
	char	buf[BUFSIZE];
	int	bytes = -1;
	int	append = 0;	/* append stdin to existing file. */
	int	file = 1;	/* index into argv of filename. */
	int	oflag;		/* flags for _open call. */
	int	ofh;		/* output file handle. */
	
	/*
	*	Process the command line args.
	*/
	
	oflag = _O_CREAT | _O_BINARY | _O_WRONLY;

	if (argc <= 1)
		usage();
	else
	{
		if ('-' == argv[1][0] || '/' == argv[1][0])
		{
			/*
			*	Check for append switch.
			*/

			file = 2;
			if ('a' != argv[1][1])
				usage();
			else
			{
				append = 1;
				oflag |= _O_APPEND;
			}
		}
		if (!argv[file])
			usage();
			
		if (-1 == (ofh = _open(argv[file], oflag, _S_IREAD | _S_IWRITE)))
		{
			fprintf(stderr, "%s: error: %s: unable to open for write: ", Image, argv[file]);
			perror(0);
			exit(++Errors);
		}
	}

	while (bytes = _read(_fileno(stdin), buf, BUFSIZE))
	{
		if (-1 == bytes)
		{
			if (EPIPE == errno)
			{
				/*
				*	EOF on a pipe.
				*/
				break;
			}
			fprintf(stderr, "%s: error %d: reading from stdin: ", Image, errno);
			perror(0);
			_close(ofh);
			exit(++Errors);
		}
		if (bytes != _write(_fileno(stdout), buf, bytes))
		{
			fprintf(stderr, "%s: error: writing %d bytes to stdout: ", Image, bytes);
			perror(0);
			_close(ofh);
			exit(++Errors);
		}
		if (bytes != _write(ofh, buf, bytes))
		{
			fprintf(stderr, "%s: error: %s: writing %d bytes: ", Image, argv[file], bytes);
			perror(0);
			_close(ofh);
			exit(++Errors);
		}
	}

	_close(ofh);	
	exit(Errors);
	return Errors;
}	
