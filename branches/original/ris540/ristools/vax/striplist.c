/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/***************************

	NAME   

		striplist

	PURPOSE 	
	
		Convert a VMS C listing file back to a C source file.

		Syntax is:  STRIPLIST <filename> 

			Given: striplist filename, 
			it takes filename.lis, produces filename99.c
		
	ASSUMPTIONS

		the listing has been produced with LIST, SHOW(expansion)

		each page of the listing file has the form: 

			formfeed
			header line
			header line
			blank line
			<text lines>

			where each <text line> has the form

				<line/level numbers> <tab> <original or expanded line>

		any line that was a macro is printed TWICE, once in its
			original form with a substitution count at line[12],
			and once in its expanded form -- so we have to throw
			out the previous line whenever we encounter a macro.

		any line that is broken up by the compiler will have its remaining
			piece on the next line and will begin <tab><tab>.  We have to
			re-attach the pieces.

		any line that was ifdef'd out has an X in line[8]; these are thrown out.

		any C error line begins "%CC" at line[0].
			Additional error lines begin <tab><tab>.

		at the end of the listing there are lines that look like

			Command Line\n
			------------

		starting in column 0.  This and everything that follows is ignored.

*************************************************************************/

#define SKIPLINES 3		/* lines to skip after a formfeed */
#define EXTENSION "99"	/* added to filename to distinguish from original */

#include <stdio.h>
#include <ctype.h>

	/*
	** We use the following characters to identify places in a line
	** where we can split the line in two without adding a backslash.
	** Don't use a comma, it is used too much.
	** Don't use a semicolon, it is used in VAX __FILE__ filenames.
	*/
#define BREAK_CHAR_COUNT 2
char	break_chars[BREAK_CHAR_COUNT] = { '{', '}'};

main(argc, argv)
int argc;
char *argv[];
{
	FILE	*input;		/* input file pointer */
	FILE	*output;	/* output file pointer */

	char	filename[200];	/* a buffer to hold the filename for modification */
	char	line[256];		/* a buffer to hold a line */
	char	*goodpart;		/* part of text line after line/level numbers */

	char	*tempcharp1,
			*tempcharp2;	/* temporary character pointers */
	char	savechars[2];	/* temporary storage of characters */

	int		incount;		/* # of lines read (approximately) */
	int		outcount;		/* # of lines written (maybe) */
	int		status;
	int		i;
	int		position;		/* for backing up a line to overwrite orig. macro */
	int		highwater;		/* highest byte position ever in the output file */

	int		in_error;		/* flag - are we among error messages */
	int		last_size;		/* size of last line printed */
	int		attach;			/* flag - attach this to preceding line? */
	int		in_macro;		/* flag - we are processing an expanded macro */

	extern char *strchr();


	attach = 0;
	last_size=0;
	in_error=0;
	in_macro=0;
	highwater=0;

		/*
		** Check to see that we have been given an argument
		*/

	if (argc != 2)
	{
		fprintf(stderr, "\n\nSyntax:  %s  <listing-file>\n\n", argv[0]);
		exit(1);
	}

		/*
		** Add the .LIS extension to the argument to get the input filename
		** and then open the file.
		*/

	sprintf(filename,"%s.lis", argv[1]);

	if (!(input = fopen(filename, "r")))
	{
		fprintf(stderr, "\n\nERROR: cannot open input file <%s>\n\n", filename);
		exit(1);
	}
	
		/*
		** Add the EXTENSION.C extension to the argument to get the output 
		** filename and then open the file.
		*/

	sprintf(filename,"%s%s.c", argv[1], EXTENSION); 
	if (!(output = fopen(filename, "w")))
	{
		fprintf(stderr, "\n\nERROR: cannot open output file <%s>\n\n",filename);
		exit(1);
	}

		/*
		** initialize the counters
		*/

	incount = outcount = 0;

		/*
		** Loop forever on the read-line/write-line operation.  We
		** break out when we detect the end.
		*/

	while (1)
	{
			/*
			** read the line, quit on error
			*/

		status = (int) fgets(line, sizeof(line), input);
		if (status == NULL)
			break;
		++incount;

			/*
			** if formfeed, skip this and next few lines 
			*/

		if (line[0] == '\f')
		{
			for (i=0; i<=SKIPLINES; ++i)
				status = (int) fgets(line, sizeof(line), input);
			if (status == NULL)
				break;
			incount += SKIPLINES;
		}

			/*
			** We want only the part of the line after the tab.
			*/

		goodpart = strchr(line,'\t');

		if (!goodpart)
		{
				/*
				** If there was no good part, we might be at the ending garbage.
				*/

			goodpart = line;	/* reset pointer */

				/*
				** Check to see if we have reached the end of the listing
				*/

			if (!strcmp(line, "Command Line\n"))
				break;

			in_error = 1;	/* assume we have an error line */

			continue;	/* throw the line away */
		}
		else
			++goodpart;		/* skip tab */

			/*
			** Is this a continuation line (<tab><tab>)?
			*/

		if (goodpart == &line[1]) 
		{
			/*
			** Yes.
			** If this is the continuation of an error message,
			** throw it out.
			*/

			if (in_error)
				continue;
			else
			{
				attach = 1;		/* we have to reattach this to preceding line */
				++goodpart;		/* advance over 2nd tab */
			}
		}
		else
			/*
			** Not a continuation line.  Clear the macro flag.
			*/
			in_macro = 0;

		in_error = 0;	/* we are no longer among error messages */
		
			/*
			** If this line was ifdef'd out, skip it.
			*/

		if ( ((goodpart-line)>=8) && (line[8] == 'X') )
			continue;

/* vvv tdm Mon May 22 16:09:34 CDT 1989 vvv */
			/* This section removes any #ifdef, #ifndef, #else #endif's
			   left behind by the preprocessor.  This is necessary because
			   the Ingres preprocessor complains about any of these 
			   statements in the declare section */
/* vvv dvk Sat Jul  8 11:49:05 CDT 1989 vvv */
			/* 
			** Add "if " to the list to handle "#if defined(x) || defined(y)" 
			*/

		if (*goodpart == '#')
		{
			int i;
			char *ptr = goodpart;
			static char *removeList[] = { "if ",
										  "ifdef",
										  "ifndef",
										  "else",
										  "endif"};
			int removeListCount = sizeof(removeList)/sizeof(char *);

			while (isspace(*(++ptr)));

			if (*ptr)
			{
				for (i = 0; i < removeListCount; i++)
				{
					if (strncmp(ptr,removeList[i],strlen(removeList[i])) == 0)
						break;
				}
				if (i < removeListCount) continue;
			}
		}
/* ^^^ tdm Mon May 22 16:09:34 CDT 1989 ^^^ */

			/*
			** If this is a macro expansion, back up over the previous line.
			** (The previous line was the unexpanded macro.)
			*/

		if (((goodpart-line)>= 14) && isdigit(line[12]))	
			{
			fseek(output,position, 0);
			in_macro = 1;
			}

			/*
			** sometimes during macro expansion a line will be expanded to
			** the degree that it spills over into continuation lines.
			** Reattach them by backing up and continuing to write a
			** single continuous line.  This results in some lines that
			** are too long.  Because of this, we generally need to
			** break it off at some point.  The question then becomes,
			** "Where to break the line"?  Rather than worry about
			** whether or not I am in a quoted string and need to
			** add a backslash, I am going to risk looking for characters
			** that usually indicate a C statement break.
			** The three characters "{};" are reasonably safe, particularly
			** for our macros.
			*/

		if (attach)
			{
			fseek(output,position+last_size, 0);
			attach = 0;

			/*
			** Find the first line-break character in our current piece.
			*/

			tempcharp2 = (char *)0;
			for (i=0; i<BREAK_CHAR_COUNT; ++i)
				{
				tempcharp1 = strchr(goodpart+1, break_chars[i]);
				if (tempcharp1)
					{
					if (tempcharp2)
						{
						if (tempcharp1 < tempcharp2)
							tempcharp2 = tempcharp1;
						}
					else
						tempcharp2 = tempcharp1;
					}
				}

			/*
			** If we found one, print the line up to that point
			**  with a newline, and adjust our "current line".
			*/

			if (tempcharp2)
				{
				savechars[0] = *tempcharp2;
				savechars[1] = *(tempcharp2+1);
				*tempcharp2 = '\n';
				*(tempcharp2+1) = '\0';
				fputs(goodpart, output);
				++outcount;
				*tempcharp2 = savechars[0];
				*(tempcharp2+1) = savechars[1];
				goodpart = tempcharp2;
				}
			}

		/* standard writing mechanism for current line */

			/*
			** Save position before writing so we know where to back up to
			** if we need to overwrite the line.
			*/

		position = ftell(output);	/* save position before writing */

			/*
			** Save length before writing so we know where to back up to
			** if we need to attach another piece to this line.  
			** 
			*/

		last_size = strlen(goodpart)-1;

			/*
			** Consider the following:  write a long line, fseek back,
			** 	overwrite the long line with a short line, then exit.
			**  This leaves you with the last portion of the long line
			**  as garbage at the end of the file.  We need to keep
			**  track of the farthest point in the file so that before
			**  we exit we can scribble over any garbage at the end.
			*/  

		if (position + last_size > highwater)
			highwater = position + last_size;

		fputs(goodpart, output);
		++outcount;
	}

	position = ftell(output);	/* save position before writing */
	if (position < highwater)
		print_blanks(output,highwater-position+1);

	fclose(output);

/*	fprintf(stderr, 
		"\n\nNormal termination.  %d lines read, %d lines written.\n\n",
		incount, outcount);
*/
}

/*
** Write lines full of blanks to a file
*/
print_blanks(fp, count)
FILE *fp;
int count;
{
	static char blanks[] = 
		"                                                             \n";
	
	/*
	** This is the hog-slop method.  Just dump blank lines until we
	** have definitely written the required number of bytes.
	*/
	while (count>0)
	{
		fputs(blanks, fp);
		count -= sizeof(blanks);
	}
}
