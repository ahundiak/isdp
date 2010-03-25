/* Copyright (c) 1982, 1983, 1984, 1985,1986, 1987, and 1988
** Intergraph Corporation: All Rights Reserved
** Including Application Programs, File Formats, and Visual Displays 
*/

#ifdef unix
#  define UNLINK unlink		/* INTERPRO 32 */
#  define FILENAMELEN 12
#  define dotz ".Z"
#else
#  define UNLINK delete		/* VAX */
#  define FILENAMELEN 100
#  define dotz "_z"
#endif

/* 
 * Compress - data compression program 
 */
#define	min(a,b)	((a>b) ? b : a)

/*
 * Set USERMEM to the maximum amount of physical user memory available
 * in bytes.  USERMEM is used to determine the maximum BITS that can be used
 * for compression.
 *
 * SACREDMEM is the amount of physical memory saved for others; compress
 * will hog the rest.
 */

#ifndef SACREDMEM
#define SACREDMEM	0
#endif

#ifndef USERMEM
# define USERMEM 	450000	/* default user memory */
#endif

#ifdef interdata		/* (Perkin-Elmer) */
#define SIGNED_COMPARE_SLOW	/* signed compare is slower than unsigned */
#endif

#ifdef USERMEM
# if USERMEM >= (433484+SACREDMEM)
#  define PBITS	16
# else
#  if USERMEM >= (229600+SACREDMEM)
#   define PBITS	15
#  else
#   if USERMEM >= (127536+SACREDMEM)
#    define PBITS	14
#   else
#    if USERMEM >= (73464+SACREDMEM)
#     define PBITS	13
#    else
#     define PBITS	12
#    endif
#   endif
#  endif
# endif
# undef USERMEM
#endif /* USERMEM */

#ifdef PBITS		/* Preferred BITS for this memory size */
# ifndef BITS
#  define BITS PBITS
# endif BITS
#endif /* PBITS */

#if BITS == 16
# define HSIZE	69001		/* 95% occupancy */
#endif
#if BITS == 15
# define HSIZE	35023		/* 94% occupancy */
#endif
#if BITS == 14
# define HSIZE	18013		/* 91% occupancy */
#endif
#if BITS == 13
# define HSIZE	9001		/* 91% occupancy */
#endif
#if BITS <= 12
# define HSIZE	5003		/* 80% occupancy */
#endif

/*
 * a code_int must be able to hold 2**BITS values of type int, and also -1
 */
#if BITS > 15
typedef long int	code_int;
#else
typedef int		code_int;
#endif

#ifdef SIGNED_COMPARE_SLOW
typedef unsigned long int count_int;
typedef unsigned short int count_short;
#else
typedef long int	  count_int;
#endif

#ifdef NO_UCHAR
 typedef char	char_type;
#else
 typedef	unsigned char	char_type;
#endif /* UCHAR */

char_type magic_header[] = { "\037\235" };	/* 1F 9D */

/* Defines for third byte of header */
#define BIT_MASK	0x1f
#define BLOCK_MASK	0x80
/* Masks 0x40 and 0x20 are free.  I think 0x20 should mean that there is
   a fourth header byte (for expansion).
*/
#define INIT_BITS 9			/* initial number of bits/code */

/*
 * compress.c - File compression ala IEEE Computer, June 1984.
 *
 * Authors:	Spencer W. Thomas	(decvax!harpo!utah-cs!utah-gr!thomas)
 *		Jim McKie		(decvax!mcvax!jim)
 *		Steve Davies		(decvax!vax135!petsd!peora!srd)
 *		Ken Turkowski		(decvax!decwrl!turtlevax!ken)
 *		James A. Woods		(decvax!ihnp4!ames!jaw)
 *		Joe Orost		(decvax!vax135!petsd!joe)
 *
 * Header: compress.c,v 4.0 85/07/30 12:50:00 joe Release $
 * Log:	compress.c,v 4.0
 * Revision 1.0  86/08/22  rene dahdah
 */

static char rcs_ident[] = "$Header: /usr7/deltools/Deltools/src/compress/RCS/compress.c 1.1.51.1.1.1 1997/09/08 21:46:38 pinnacle Exp $";

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <ctype.h>
#include <signal.h>
#include <memory.h>
#ifdef unix 	/* unix */
#  include <sys/types.h>
#  include <sys/stat.h>
#else		/* vms */
#  include <stat.h>
#  include <types.h>
#endif

#define ARGVAL() (*++(*argv) || (--argc && *++argv))

int n_bits;				/* number of bits/code */
int maxbits = BITS;			/* user settable max # bits/code */
code_int maxcode;			/* maximum code, given n_bits */
code_int maxmaxcode = 1 << BITS;	/* should NEVER generate this code */

#ifdef COMPATIBLE		/* But wrong! */
# define MAXCODE(n_bits)	(1 << (n_bits) - 1)
#else
# define MAXCODE(n_bits)	((1 << (n_bits)) - 1)
#endif /* COMPATIBLE */

/* Normal machine */

count_int htab [HSIZE];
unsigned short codetab [HSIZE];

#define htabof(i)	htab[i]
#define codetabof(i)	codetab[i]

code_int hsize = HSIZE;			/* for dynamic table sizing */
count_int fsize;

/*
 * To save much memory, we overlay the table used by compress() with those
 * used by decompress().  The tab_prefix table is the same size and type
 * as the codetab.  The tab_suffix table needs 2**BITS characters.  We
 * get this from the beginning of htab.  The output stack uses the rest
 * of htab, and contains characters.  There is plenty of room for any
 * possible stack (stack used to be 8000 characters).
 */

#define tab_prefixof(i)	codetabof(i)

/* Normal machine */
# define tab_suffixof(i)	((char_type *)(htab))[i]
# define de_stack		((char_type *)&tab_suffixof(1<<BITS))


code_int free_ent = 0;			/* first unused entry */
int exit_stat = 0;
char buffer[8192];	/*input buffer. Hopefully buffering input will*/
			/*speed things up.				*/
int countdone,readin;   /*used in buffering. countdone is # chars done in*/
			/*buffer. readin is the #of chars read into buffer*/
code_int getcode();

/*************Usage()*********************************************/
Usage() 
{
#ifdef DEBUG
fprintf(stderr,"Usage: compress [-dDrfc] [-b maxbits] [file ...]\n");
}
int debug = 0;
#else
#ifdef vms
fprintf(stderr,
"\nUsage: compress [-fvcr?] [-d [-s fixrecordsize]] [-b maxbits] [file ...]\n");
#else
fprintf(stderr,"Usage: compress [-dfvcr?] [-b maxbits] [file ...]\n");
#endif
}
#endif /* DEBUG */

/**************more global variables**********************/

int nomagic = 0;	/* Use a 3-byte magic number header, unless old file */
int zcat_flg = 0;	/* Write output on stdout, suppress messages */
int quiet = 1;		/* don't tell me about compression */

/*
 * block compression parameters -- after all codes are used up,
 * and compression rate changes, start over.
 */

int block_compress = BLOCK_MASK;
int clear_flg = 0;
long int ratio = 0;
#define CHECK_GAP 10000	/* ratio check interval */
count_int checkpoint = CHECK_GAP;

/*
 * the next two codes should not be changed lightly, as they must not
 * lie within the contiguous general code space.
 */ 

#define FIRST	257	/* first free entry */
#define	CLEAR	256	/* table clear output code */

/*
 * VAX -- if '-s' is present the ouput is fixed record format
 */
int fixed_rec_flag = 0;			/* default stream LF */
int fixed_rec_size = 512;		/* default block size */
int ofd;
int write_error = 0;

int force = 0;
char ofname [100];

#ifdef DEBUG
int verbose = 0;
#endif /* DEBUG */

void (*bgnd_flag)();

int do_decomp = 0;
char fileptr[100];	/*name of the file to compress*/

/*****************************************************************
 * TAG( main )
 *
 * Algorithm from "A Technique for High Performance Data Compression",
 * Terry A. Welch, IEEE Computer Vol 17, No 6 (June 1984), pp 8-19.
 *
 * Usage: compress [-dfrvc] [-b bits] [file ...]
 * Inputs:
 *	-d:	    If given, decompression is done instead.
 *
 *      -c:         Write output on stdout, don't remove original.
 *
 *      -r: 	    Write release or version being used.
 *
 *      -b:         Parameter limits the max number of bits/code.
 *
 *	-f:	    Forces output file to be generated, even if one already
 *		    exists, and even if no space is saved by compressing.
 *		    If -f is not used, the user will be prompted if stdin is
 *		    a tty, otherwise, the output file will not be overwritten.
 *
 *      -v:	    Write compression statistics
 *
 *      -s:         forces output file to be fixed_length record format, with
 *		    block size <n>, instead of stream format with line-feed
 *		    terminator. (VMS only)
 *
 *	-?:	    Print manual.
 *
 * 	file ...:   Files to be compressed.  If none specified, stdin
 *		    is used.
 * Outputs:
 *	file.Z:	    Compressed form of file with same mode, owner, and utimes
 * 	or stdout   (if stdin used as input)
 *
 * Assumptions:
 *	When filenames are given, replaces with the compressed version
 *	(.Z suffix) only if the file decreases in size.
 * Algorithm:
 * 	Modified Lempel-Ziv method (LZW).  Basically finds common
 * substrings and replaces them with a variable size code.  This is
 * deterministic, and can be done on the fly.  Thus, the decompression
 * procedure needs no input table, but tracks the way the table was built.
 */

main( argc, argv )
register int argc; char **argv;
{
	int overwrite = 0;	/* Do not overwrite unless given -f flag */
	int dummy;
	char tempname[100];
	char *cp, *rindex();
	struct stat statbuf;
	extern onintr(), oops();	/*signal handlers*/
	int doitonce = 1;	/* flag , if 1 set value for maxbits, maxmaxcode*/
	int filename_exist = 0;	/* flag. if 1 the user gave us a file to work on*/
	int no_input = 0;


	if ( (bgnd_flag = signal ( SIGINT, SIG_IGN )) != SIG_IGN ) {
		signal ( SIGINT, onintr );
		signal ( SIGSEGV, oops );
	}

#ifdef COMPATIBLE
	nomagic = 1;	/* Original didn't have a magic number */
#endif /* COMPATIBLE */

	if((cp = rindex(argv[0], '/')) != 0)  /*take off leading / from program name */
		cp++;
	else 
		cp = argv[0];

	if(strcmp(cp, "uncompress") == 0) 
	{
		do_decomp = 1;
	} 
	else if(strcmp(cp, "zcat") == 0) 
	{
		do_decomp = 1;
		zcat_flg = 1;
	}


    /* Argument Processing
     * All flags are optional.
     * -D => debug
     * -r => print (release) Version; debug verbose
     * -d => do_decomp
     * -v => unquiet
     * -f => force overwrite of output file
     * -n => no header: useful to uncompress old files
     * -b maxbits => maxbits.  If -b is specified, then maxbits MUST be
     *	    given also.
     * -c => cat all output to stdout
     * -C => generate output compatible with compress 2.0.
     * if a string is left, must be an input filename.
     */
	for (argc--, argv++; argc > 0; argc--, argv++) 
	{
		if (**argv == '-') 
		{	/* A flag argument */
			while (*++(*argv)) 
			{	/* Process all flags in this arg */
				switch (**argv) 
				{
#ifdef DEBUG
					case 'D':
						debug = 1;
					break;
					case 'r':
						verbose = 1;
						version();
					break;
#else
					case 'r':
						version();
					break;
#endif /* DEBUG */
					case '?':
						printman();
						no_input = 1;
					break;
					case 's':
#ifdef vax
			/* 		VAX ONLY
			 * force output file to be in a fixed record format
 			 * with block size 'n' if 'n' is specified by the user
			 * or 512 as default
			 */
						fixed_rec_flag = 1;      	/* vax fix rec format */
						if(!ARGVAL()) 
							fixed_rec_size = 512;
						else 
							fixed_rec_size = atoi(*argv);
						if (fixed_rec_size == 0) 
							fixed_rec_size == 512;
						goto nextarg;
#else /* unix */
						fprintf(stderr, "Unknown flag: '%c'; ", **argv);
						Usage();
						exit(1);
#endif
					case 'v':
						quiet = 0;
					break;
					case 'd':
						do_decomp = 1;
					break;
					case 'f':
					case 'F':
						overwrite = 1;
						force = 1;
					break;
					case 'n':
						nomagic = 1;
					break;
					case 'C':
						block_compress = 0;
					break;
					case 'b':
						if (!ARGVAL()) 
						{
							fprintf(stderr, "Missing maxbits\n");
							Usage();
							exit(1);
						}
						maxbits = atoi(*argv);
						goto nextarg;
					case 'c':
						zcat_flg = 1;
					break;
					case 'q':
						quiet = 1;
					break;
					default:
						fprintf(stderr, "Unknown flag: '%c'; ", **argv);
						Usage();
						exit(1);
				} /*end of switch for type of arguement*/
			} /*end of while loop going through arguements*/
		} /*end of an arguement beginning with a "-" */
		else 
		{		/* Input file name */
			if (doitonce) 
			{
				filename_exist = 1;
				if(maxbits < INIT_BITS) 
					maxbits = INIT_BITS;
				if (maxbits > BITS) 
					maxbits = BITS;
				maxmaxcode = 1 << maxbits;
			doitonce = 0;
			}
#ifdef vms
		if (fmu_parse_fspec(*argv)) {
		fprintf(stderr, "CX: unable to access '%s'",*argv);
		exit(2);
		}
		while (fmu_search(fileptr) == NULL) {
		stripsc (fileptr); /* strip ; */
		if (strcmp(fileptr + strlen(fileptr) - 4, ".dir") == 0){
			fprintf(stderr,"CX: %s not compressed\n", fileptr);
			continue;
		}
		if ((strcmp(fileptr + strlen(fileptr) - 2, dotz) == 0) &&
			(!do_decomp)) continue;
#else /* unix */
			strcpy(fileptr, *argv);
#endif
			exit_stat = 0;
			if (do_decomp != 0) 
			{	/* DECOMPRESSION */
			/* Check for .Z suffix */
#ifdef unix
				if ((strcmp(fileptr + strlen(fileptr) - 2, ".Z") != 0) &&
				   (strcmp(fileptr + strlen(fileptr) - 2, ".z") != 0)  &&
				   (strcmp(fileptr + strlen(fileptr) - 2, "_z") != 0) )
#else
			if (strcmp(fileptr + strlen(fileptr) - 2, dotz) != 0) 
#endif
				{

					/* No .Z: tack one on */
					strcat(fileptr, dotz);
				}
				/* Open input file */
				if ((freopen(fileptr, "r", stdin)) == NULL) 
				{
					perror(fileptr); 
					continue;
				}
			/* Check the magic number */
				if (nomagic == 0) 
				{
					if ((getchar() != (magic_header[0] & 0xFF))
					 || (getchar() != (magic_header[1] & 0xFF))) 
					{
						fprintf(stderr, "%s: not in compressed format\n",
							fileptr);
						continue;
					}
					maxbits = getchar();	/* set -b from file */
					block_compress = maxbits & BLOCK_MASK;
					maxbits &= BIT_MASK;
					maxmaxcode = 1 << maxbits;
					if(maxbits > BITS) 
					{
						fprintf(stderr,
						"%s: compressed with %d bits, can only handle %d bits\n",
						fileptr, maxbits, BITS);
						continue;
					}
				}
				/* Generate output filename */
				strcpy(ofname, fileptr);
				ofname[strlen(fileptr) - 2] = '\0';  /* Strip off .Z */
			} 
			else 	/* COMPRESSION */
			{
				if (strcmp(fileptr + strlen(fileptr) - 2, dotz) == 0) 
				{
					fprintf(stderr, 
					  "%s: already has %s suffix -- no change\n",
					  fileptr, dotz);
					continue;
				}
				dummy = stat ( fileptr, &statbuf );
				if(dummy < 0)
				{
					perror("compress");
					exit(1);
				}
				fsize = (long) statbuf.st_size;
			/*
			 * tune hash table size for small files -- ad hoc,
			 * but the sizes match earlier #defines, which
			 * serve as upper bounds on the number of output codes. 
			 */
				hsize = HSIZE;
				if ( fsize < 4096 )
					hsize = min ( 5003, HSIZE );
				else if ( fsize < 8192 )
					hsize = min ( 9001, HSIZE );
				else if ( fsize < 16384 )
					hsize = min ( 18013, HSIZE );
				else if ( fsize < 32786 )
					hsize = min ( 35023, HSIZE );
				else if ( fsize < 47000 )
					hsize = min ( 50021, HSIZE );

			/* Generate output filename */
				strcpy(ofname, fileptr);

			/* Short filenames */
				if ((cp=rindex(ofname,'/')) != NULL)	
					cp++;
				else
					cp = ofname;
				if (strlen(cp) > FILENAMELEN) 
				{
#ifdef vms
					 fprintf(stderr,"%s: filename too long to tack on _z\n",cp);
#else /* UNIX */
					 fprintf(stderr,"%s: filename too long to tack on .Z\n",cp);
#endif
					continue;
				}
				strcat(ofname, dotz);
			}
			/* Check for overwrite of existing file */
#ifdef unix
			if (overwrite == 0 && zcat_flg == 0) 
			{
				if (stat(ofname, &statbuf) == 0) 
				{
					char response[2];
					response[0] = 'n';
					fprintf(stderr, "%s already exists;", ofname);
					if (foreground()) 
					{
						fprintf(stderr,
						" do you wish to overwrite %s (y or n)? ", ofname);
						fflush(stderr);
						read(2, response, 2);
						while (response[1] != '\n') 
						{
							if (read(2, response+1, 1) < 0) 
							{  /* Ack! */
								perror("stderr"); 
								break;
							}
						}
					}
					if (response[0] != 'y') 
					{
						fprintf(stderr, "\tnot overwritten\n");
						continue;
					}
				}
			}
#endif
			if(zcat_flg == 0) 
			{		/* Open output file */
				if (freopen(ofname, "w", stdout) == NULL) 
				{
					perror(ofname);
					continue;
				}
				if(!quiet)
					fprintf(stderr, "%s: ", fileptr);
			}

			/* Actually do the compression/decompression */
			if (do_decomp == 0)	
				compress();
#ifndef DEBUG
			else
				decompress();
#else
			else if (debug == 0)	
				decompress();
			else	
				printcodes();
			if (verbose)		
				dump_tab();
#endif /* DEBUG */
			if(zcat_flg == 0) 
			{
				copystat(fileptr, ofname);	/* Copy stats */
				if((exit_stat == 1) || (!quiet))
				putc('\n', stderr);
			}

#ifdef vms
		}  /* while loop */
#endif
		} /*end of if this is a filename the user has given us*/
		nextarg: continue;
	}/*end of for loop going through command line arguements*/


#ifdef unix
	if ((!filename_exist) && (!no_input))	/* Standard input */
	{	
		if (do_decomp == 0) 
		{
			if(maxbits < INIT_BITS)
				maxbits = INIT_BITS;
			if(maxbits > BITS)
				maxbits = BITS;
			maxmaxcode = 1 << maxbits;
			compress();
#ifdef DEBUG
			if(verbose)
				dump_tab();
#endif /* DEBUG */
			if(!quiet)
				putc('\n', stderr);
		} 
		else 	/* do decompress */
		{ 
		/* Check the magic number */
			if (nomagic == 0) 
			{
				if ((getchar()!=(magic_header[0] & 0xFF))
				 || (getchar()!=(magic_header[1] & 0xFF))) 
				{
					fprintf(stderr, "stdin: not in compressed format\n");
					exit(1);
				}
				maxbits = getchar();	/* set -b from file */
				block_compress = maxbits & BLOCK_MASK;
				maxbits &= BIT_MASK;
				maxmaxcode = 1 << maxbits;
				fsize = 100000;		/* assume stdin large for USERMEM */
				if(maxbits > BITS) 
				{
					fprintf(stderr,
					"stdin: compressed with %d bits, can only handle %d bits\n",
					maxbits, BITS);
					exit(1);
				}
			}
#ifndef DEBUG
			decompress();
#else
			if (debug == 0)	
				decompress();
			else		
				printcodes();
			if (verbose)	
				dump_tab();
#endif /* DEBUG */
		} /* else do decompress */
	} /* end of else standard input */
#endif unix

/* RENE */
#ifdef vax 
	if (!fixed_rec_flag)
		fclose(stdout);
	if (exit_stat == 0) 
		exit(1);
	exit(0);
#else  /* unix */
	fclose(stdout);
	exit(exit_stat);
#endif

} /* end of  main */

static int offset;
long int in_count = 1;			/* length of input */
long int bytes_out;			/* length of compressed output */
long int out_count = 0;			/* # of codes output (for debugging) */

/*
 * compress stdin to stdout
 *
 * Algorithm:  use open addressing double hashing (no chaining) on the 
 * prefix code / next character combination.  We do a variant of Knuth's
 * algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime
 * secondary probe.  Here, the modular division first probe is gives way
 * to a faster exclusive-or manipulation.  Also do block compression with
 * an adaptive reset, whereby the code table is cleared when the compression
 * ratio decreases, but after the table fills.  The variable-length output
 * codes are re-sized at this point, and a special CLEAR code is generated
 * for the decompressor.  Late addition:  construct the table according to
 * file size for noticeable speed improvement on small files.  Please direct
 * questions about this implementation to ames!jaw.
 */

compress() 
{
	register long fcode;
	register code_int i = 0;
	register int c;
	register code_int ent;
	register int disp;
	register code_int hsize_reg;
	register int hshift;
	int firsttime = 1, fd;

#ifndef COMPATIBLE
	if (nomagic == 0) 
	{
		putchar(magic_header[0]); 
		putchar(magic_header[1]);
		putchar((char)(maxbits | block_compress));
		if(ferror(stdout))
			writeerr();
	}
#endif /* COMPATIBLE */

	offset = 0;
	bytes_out = 3;		/* includes 3-byte header mojo */
	out_count = 0;
	clear_flg = 0;
	ratio = 0;
	in_count = 1;
	checkpoint = CHECK_GAP;
	maxcode = MAXCODE(n_bits = INIT_BITS);
	free_ent = ((block_compress) ? FIRST : 256 );
	hshift = 0;
	for ( fcode = (long) hsize;  fcode < 65536L; fcode *= 2L )
		hshift++;
	hshift = 8 - hshift;		/* set hash code range bound */

	hsize_reg = hsize;
	cl_hash( (count_int) hsize_reg);		/* clear hash table */

	/*open the file*/
	if(fileptr[0] != 0) /*doing from file or stdin? */
	{
		fd = open(fileptr,O_RDONLY);
		if(fd < 0)
		{
			perror("compress: opening file");
			exit(1);
		}
	}
	else
		fd = 0;   /*use stdin instead*/
	firsttime = 1;
	while( (readin = read(fd,buffer,sizeof(buffer))) > 0)
	{
		countdone = 0;
		while(countdone < readin)
		{
			if(firsttime)
			{
				ent = getbyte();
				firsttime = 0;
				countdone++;
			}
			c = getbyte();
			countdone++;
			in_count++;
			fcode = (long) (((long) c << maxbits) + ent);
		 	i = ((c << hshift) ^ ent);	/* xor hashing */
			if ( htabof (i) == fcode ) 
			{
				ent = codetabof (i);
				continue;
			} 
			else if ( (long)htabof (i) < 0 )	/* empty slot */
				goto nomatch;
		 	disp = hsize_reg - i;		/* secondary hash (after G. Knott) */
			if ( i == 0 )
				disp = 1;
probe:
			if ( (i -= disp) < 0 )
				i += hsize_reg;

			if ( htabof (i) == fcode ) 
			{
				ent = codetabof (i);
				continue;
			}
			if ( (long)htabof (i) > 0 ) 
				goto probe;
nomatch:
			output ( (code_int) ent );
			out_count++;
	 		ent = c;
#ifdef SIGNED_COMPARE_SLOW
			if ( (unsigned) free_ent < (unsigned) maxmaxcode) {
#else
			if ( free_ent < maxmaxcode ) {
#endif
		 		codetabof (i) = free_ent++;	/* code -> hashtable */
				htabof (i) = fcode;
			}
			else if ( (count_int)in_count >= checkpoint && block_compress )
				cl_block ();
		}  /*end of while(countdone < readin) */
	}	/*end of while(there is something to read from file)*/

	if(readin < 0)
	{
		perror("compress: reading file");
		exit(1);
	}
	close(fd);
	/*
	 * Put out the final code.
	 */
	output( (code_int)ent );
	out_count++;
	output( (code_int)-1 );

	/*
	 * Print out stats on stderr
	 */
	
	if(zcat_flg == 0 && !quiet) 
	{
#ifdef DEBUG
		fprintf( stderr,
			"%ld chars in, %ld codes (%ld bytes) out, compression factor: ",
			in_count, out_count, bytes_out );
		prratio( stderr, in_count, bytes_out );
		fprintf( stderr, "\n");
		fprintf( stderr, "\tCompression as in compact: " );
		prratio( stderr, in_count-bytes_out, in_count );
		fprintf( stderr, "\n");
		fprintf( stderr, "\tLargest code (of last block) was %d (%d bits)\n",
			free_ent - 1, n_bits );
#else /* !DEBUG */
		fprintf( stderr, "Compression: " );
		prratio( stderr, in_count-bytes_out, in_count );
#endif /* DEBUG */
	}
	if(bytes_out > in_count)
	{	/* exit(2) if no savings */
		exit_stat = 2;
		if (quiet && (!force)) 
			fprintf(stderr,"no saving -- file unchanged\n");
#ifdef vms
		fclose(stdout);
		UNLINK(ofname);
#endif
	}
	return;
} /*end of compress()*/

/*****************************************************************
 * TAG( output )
 *
 * Output the given code.
 * Inputs:
 * 	code:	A n_bits-bit integer.  If == -1, then EOF.  This assumes
 *		that n_bits =< (long)wordsize - 1.
 * Outputs:
 * 	Outputs code to the file.
 * Assumptions:
 *	Chars are 8 bits long.
 * Algorithm:
 * 	Maintain a BITS character long buffer (so that 8 codes will
 * fit in it exactly).  Use the VAX insv instruction to insert each
 * code in turn.  When the buffer fills up empty it and start over.
 */

static char buf[BITS];

#ifndef nvms  /*RENE 5-27-6*/
char_type lmask[9] = {0xff, 0xfe, 0xfc, 0xf8, 0xf0, 0xe0, 0xc0, 0x80, 0x00};
char_type rmask[9] = {0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff};
#endif /* vms */

output( code )
code_int  code;
{
#ifdef DEBUG
	static int col = 0;
#endif /* DEBUG */

	/*
	 * On the VAX, it is important to have the register declarations
	 * in exactly the order given, or the asm will break.
	 */
	register int r_off = offset, bits= n_bits;
	register char * bp = buf;

#ifdef DEBUG
	if ( verbose )
		fprintf( stderr, "%5d%c", code,
			(col+=6) >= 74 ? (col = 0, '\n') : ' ' );
#endif /* DEBUG */
	if ( code >= 0 ) 
	{
#ifdef nvms  /* RENE 5-27-6 */
	/* VAX DEPENDENT!! Implementation on other machines is below.
	 *
	 * Translation: Insert BITS bits from the argument starting at
	 * offset bits from the beginning of buf.
	 */
		0;	/* Work around for pcc -O bug with asm and if stmt */
		asm( "insv	4(ap),r11,r10,(r9)" );
#else /* not a vms */
/* 
 * byte/bit numbering on the VAX is simulated by the following code
 */
	/*
	 * Get to the first byte.
	 */
		bp += (r_off >> 3);
		r_off &= 7;
	/*
	 * Since code is always >= 8 bits, only need to mask the first
	 * hunk on the left.
	 */
		*bp = (*bp & rmask[r_off]) | (code << r_off) & lmask[r_off];
		bp++;
		bits -= (8 - r_off);
		code >>= 8 - r_off;
	/* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
		if ( bits >= 8 ) 
		{
			*bp++ = code;
			code >>= 8;
			bits -= 8;
		}
	/* Last bits. */
		if(bits)
			*bp = code;
#endif /* vms */
		offset += n_bits;
		if ( offset == (n_bits << 3) ) 
		{
			bp = buf;
			bits = n_bits;
			bytes_out += bits;
			do
				putchar(*bp++);
			while(--bits);
			offset = 0;
		}

	/*
	 * If the next entry is going to be too big for the code size,
	 * then increase it, if possible.
	 */
		if ( free_ent > maxcode || (clear_flg > 0))
		{
		/*
		 * Write the whole buffer, because the input side won't
		 * discover the size increase until after it has read it.
		 */
			if ( offset > 0 ) 
			{
				if( fwrite( buf, 1, n_bits, stdout ) != n_bits)
					writeerr();
				bytes_out += n_bits;
			}
			offset = 0;
			if ( clear_flg ) 
			{
				maxcode = MAXCODE (n_bits = INIT_BITS);
				clear_flg = 0;
			}
			else 
			{
				n_bits++;
				if ( n_bits == maxbits )
					maxcode = maxmaxcode;
				else
					maxcode = MAXCODE(n_bits);
			}
#ifdef DEBUG
			if ( debug ) {
				fprintf( stderr, "\nChange to %d bits\n", n_bits );
				col = 0;
			}
#endif /* DEBUG */
		}
	} 
	else 
	{
	/*
	 * At EOF, write the rest of the buffer.
	 */
		if ( offset > 0 )
			fwrite( buf, 1, (offset + 7) / 8, stdout );
		bytes_out += (offset + 7) / 8;
		offset = 0;
		fflush( stdout );
#ifdef DEBUG
		if ( verbose )
			fprintf( stderr, "\n" );
#endif /* DEBUG */
		if( ferror( stdout ) )
			writeerr();
	}
} /*end of output*/

/*
 * Decompress stdin to stdout.  This routine adapts to the codes in the
 * file building the "string" table on-the-fly; requiring no table to
 * be stored in the compressed file.  The tables used herein are shared
 * with those of the compress() routine.  See the definitions above.
 */

decompress() 
{
	register char_type *stackp;
	register int finchar;
	register code_int code, oldcode, incode;
	short *codetab_p = (short *)codetab;
	/*
	 * As above, initialize the first 256 entries in the table.
	 */
	maxcode = MAXCODE(n_bits = INIT_BITS);
	(void)memset(codetab_p,0,512); /*zero the 1st 256 elements in this table*/
	for ( code = 255; code >= 0; code-- ) 
	{
		tab_suffixof(code) = (char_type)code;
	}
	free_ent = ((block_compress) ? FIRST : 256 );

	finchar = oldcode = getcode();
	if(oldcode == -1)	/* EOF already? */
		return;			/* Get out of here */
	putchar( (char)finchar );		/* first code must be 8 bits = char */
	if(ferror(stdout))		/* Crash if can't write */
		writeerr();
	stackp = de_stack;

	while ( (code = getcode()) > -1 ) 
	{
		if ( (code == CLEAR) && block_compress ) 
		{
			(void)memset(codetab_p,0,512); /*zero 1st 256 elements in this table*/
			clear_flg = 1;
			free_ent = FIRST - 1;
			if ( (code = getcode ()) == -1 )	/* O, untimely death! */
				break;
		}
		incode = code;
	/*
	 * Special case for KwKwK string.
	 */
		if ( code >= free_ent ) 
		{
			*stackp++ = finchar;
			code = oldcode;
		}

	/*
	 * Generate output characters in reverse order
	 */
#ifdef SIGNED_COMPARE_SLOW
		while ( ((unsigned long)code) >= ((unsigned long)256) ) {
#else
		while ( code >= 256 ) {
#endif
			*stackp++ = tab_suffixof(code);
			code = tab_prefixof(code);
		}
		*stackp++ = finchar = tab_suffixof(code);

	/*
	 * And put them out in forward order
	 */
		do
			putchar ( *--stackp );
		while ( stackp > de_stack );

	/*
	 * Generate the new entry.
	 */
		if ( (code=free_ent) < maxmaxcode ) 
		{
			tab_prefixof(code) = (unsigned short)oldcode;
			tab_suffixof(code) = finchar;
			free_ent = code+1;
		} 
	/*
	 * Remember previous code.
	 */
		oldcode = incode;
	}
	fflush( stdout );
	if(ferror(stdout))
	{
		writeerr();
	}
#ifdef vax
	else if (fixed_rec_flag){
		fclose(stdout);
		if (changeattr(ofname, fixed_rec_size)) 
			exit_stat = 9;	
	}
#endif
}/*end of decompress*/

/*****************************************************************
 * TAG( getcode )
 *
 * Read one code from the standard input.  If EOF, return -1.
 * Inputs:
 * 	stdin
 * Outputs:
 * 	code or -1 is returned.
 */

code_int
getcode() 
{
	/*
	 * On the VAX, it is important to have the register declarations
	 * in exactly the order given, or the asm will break.
	 */
	register code_int code;
	static int offset = 0, size = 0;
	static char_type buf[BITS];
	register int r_off, bits;
	register char_type *bp = buf;

	if ( clear_flg > 0 || offset >= size || free_ent > maxcode ) 
	{
	/*
	 * If the next entry will be too big for the current code
	 * size, then we must increase the size.  This implies reading
	 * a new buffer full, too.
	 */
		if ( free_ent > maxcode ) 
		{
			n_bits++;
			if ( n_bits == maxbits )
				maxcode = maxmaxcode;	/* won't get any bigger now */
			else
				maxcode = MAXCODE(n_bits);
		}
		if ( clear_flg > 0) 
		{
			maxcode = MAXCODE (n_bits = INIT_BITS);
			clear_flg = 0;
		}
		size = fread( buf, 1, n_bits, stdin );
		if ( size <= 0 )
			return -1;			/* end of file */
		offset = 0;
	/* Round size down to integral number of codes */
		size = (size << 3) - (n_bits - 1);
	}
	r_off = offset;
	bits = n_bits;
#ifdef nvms /* RENE 5-27-6 */
	asm( "extzv   r10,r9,(r8),r11" );
#else /* not a vms */
	/*
	 * Get to the first byte.
	 */
	bp += (r_off >> 3);
	r_off &= 7;

	/* Get first part (low order bits) */
#ifdef NO_UCHAR
	code = ((*bp++ >> r_off) & rmask[8 - r_off]) & 0xff;
#else
	code = (*bp++ >> r_off);
#endif /* NO_UCHAR */
	bits -= (8 - r_off);
	r_off = 8 - r_off;		/* now, offset into code word */

	/* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
	if ( bits >= 8 ) 
	{
#ifdef NO_UCHAR
		code |= (*bp++ & 0xff) << r_off;
#else
		code |= *bp++ << r_off;
#endif /* NO_UCHAR */
		r_off += 8;
		bits -= 8;
	}
	/* high order bits. */
	code |= (*bp & rmask[bits]) << r_off;
#endif /* vms */
	offset += n_bits;

	return code;
}/*end of getcode*/

char *
rindex(s, c)		/* For those who don't have it in libc.a */
register char *s, c;
{
	char *p;
	for (p = NULL; *s; s++)
		if (*s == c)
		p = s;
	return(p);
}/*end of rindex*/

#ifdef DEBUG
printcodes()
{
	/*
	 * Just print out codes from input file.  For debugging.
	 */
	code_int code;
	int col = 0, bits;

	bits = n_bits = INIT_BITS;
	maxcode = MAXCODE(n_bits);
	free_ent = ((block_compress) ? FIRST : 256 );
	while ( ( code = getcode() ) >= 0 ) 
	{
		if ( (code == CLEAR) && block_compress ) 
		{
   			free_ent = FIRST - 1;
	   		clear_flg = 1;
		}
		else if ( free_ent < maxmaxcode )
			free_ent++;
		if ( bits != n_bits ) 
		{
			fprintf(stderr, "\nChange to %d bits\n", n_bits );
			bits = n_bits;
			col = 0;
		}
		fprintf(stderr, "%5d%c", code, (col+=6) >= 74 ? (col = 0, '\n') : ' ' );
	}
	putc( '\n', stderr );
	exit( 0 );
}/*end of printcodes*/

code_int sorttab[1<<BITS];	/* sorted pointers into htab */

dump_tab()	/* dump string table */
{
	register int i, first;
	register ent;
#define STACK_SIZE	15000
	int stack_top = STACK_SIZE;
	register c;

	if(do_decomp == 0) 	/* compressing */
	{	
		register int flag = 1;

		for(i=0; i<hsize; i++) 	/* build sort pointers */
		{	
			if((long)htabof(i) >= 0) 
			{
				sorttab[codetabof(i)] = i;
			}
		}
		first = block_compress ? FIRST : 256;
		for(i = first; i < free_ent; i++) 
		{
			fprintf(stderr, "%5d: \"", i);
			de_stack[--stack_top] = '\n';
			de_stack[--stack_top] = '"';
			stack_top = in_stack((htabof(sorttab[i])>>maxbits)&0xff, 
				stack_top);
			for(ent=htabof(sorttab[i]) & ((1<<maxbits)-1);
				ent > 256;
				ent=htabof(sorttab[ent]) & ((1<<maxbits)-1)) 
			{
				stack_top = in_stack(htabof(sorttab[ent]) >> maxbits,
					stack_top);
			}
			stack_top = in_stack(ent, stack_top);
			fwrite( &de_stack[stack_top], 1, STACK_SIZE-stack_top, stderr);
	   		stack_top = STACK_SIZE;
		}
   	} 
	else if(!debug) 	/* decompressing */
	{	
		for ( i = 0; i < free_ent; i++ ) 
		{
			ent = i;
			c = tab_suffixof(ent);
			if ( isascii(c) && isprint(c) )
				fprintf( stderr, "%5d: %5d/'%c'  \"",
			   		ent, tab_prefixof(ent), c );
	   		else
		   		fprintf( stderr, "%5d: %5d/\\%03o \"",
			   		ent, tab_prefixof(ent), c );
	   		de_stack[--stack_top] = '\n';
			de_stack[--stack_top] = '"';
	   		for ( ; ent != NULL;
			   ent = (ent >= FIRST ? tab_prefixof(ent) : NULL) ) 
			{
				stack_top = in_stack(tab_suffixof(ent), stack_top);
			}
	   		fwrite( &de_stack[stack_top], 1, STACK_SIZE - stack_top, stderr );
	   		stack_top = STACK_SIZE;
		}
	}
} /*end of dumptab*/

int
in_stack(c, stack_top)
	register c, stack_top;
{
	if ( (isascii(c) && isprint(c) && c != '\\') || c == ' ' ) 
	{
		de_stack[--stack_top] = c;
	} 
	else 
	{
		switch( c ) 
		{
			case '\n': de_stack[--stack_top] = 'n'; break;
			case '\t': de_stack[--stack_top] = 't'; break;
			case '\b': de_stack[--stack_top] = 'b'; break;
			case '\f': de_stack[--stack_top] = 'f'; break;
			case '\r': de_stack[--stack_top] = 'r'; break;
			case '\\': de_stack[--stack_top] = '\\'; break;
			default:
			 	de_stack[--stack_top] = '0' + c % 8;
			 	de_stack[--stack_top] = '0' + (c / 8) % 8;
			 	de_stack[--stack_top] = '0' + c / 64;
	 		break;
		}
		de_stack[--stack_top] = '\\';
	}
	return stack_top;
}
#endif /* DEBUG */

writeerr()
{
	perror ( ofname );
	UNLINK ( ofname );
	exit ( 2 );
}

copystat(ifname, ofname)
char *ifname, *ofname;
{
	struct stat statbuf;
	int mode;
	time_t timep[2];

/* RENE 
	fclose(stdout);
*/
	if (stat(ifname, &statbuf)) 	/* Get stat on input file */
	{
		perror(ifname);
		return;
	}
	if ((statbuf.st_mode & S_IFMT/*0170000*/) != S_IFREG/*0100000*/) 
	{
		if(quiet)
			fprintf(stderr, "%s: ", ifname);
		fprintf(stderr, " -- not a regular file: unchanged");
		exit_stat = 1;
	} 
	else if (statbuf.st_nlink > 1) 
	{
		if(quiet)
			fprintf(stderr, "%s: ", ifname);
		fprintf(stderr, " -- has %d other links: unchanged",
			statbuf.st_nlink - 1);
		exit_stat = 1;
	} 
	else if (exit_stat == 2 && (!force)) 	/* No compression: remove file.Z */
	{ 
		if(!quiet)
			fprintf(stderr, " -- file unchanged");
	} 
	else 	/* ***** Successful Compression ***** */
	{
		exit_stat = 0;
		mode = statbuf.st_mode & 07777;
		if (chmod(ofname, mode))		/* Copy modes */
			perror(ofname);
		chown(ofname, statbuf.st_uid, statbuf.st_gid);	/* Copy ownership */
		timep[0] = statbuf.st_atime;
		timep[1] = statbuf.st_mtime;
#ifndef vms	/* RENE 5-27-6 */
		utime(ofname, timep);	/* Update last accessed and modified times */
#endif
		if (UNLINK(ifname))	/* Remove input file */
			perror(ifname);
		if(!quiet)
			fprintf(stderr, " -- replaced with %s", ofname);
		return;		/* Successful return */
	}

	/* Unsuccessful return -- one of the tests failed */
	if (UNLINK(ofname))
		perror(ofname);
}/*end of copystat*/
/*
 * This routine returns 1 if we are running in the foreground and stderr
 * is a tty.
 */
foreground()
{
	if(bgnd_flag) 	/* background? */
	{	
		return(0);
	} 
	else 	/* foreground */
	{
		if(isatty(2)) 	/* and stderr is a tty */
		{
			return(1);
		} 
		else 
		{
			return(0);
		}
	}
}/*end of foreground*/

onintr ( )
{
	UNLINK ( ofname );
	exit ( 2 );
}

oops ( )	/* wild pointer -- assume bad input */
{
	if ( do_decomp == 1 ) 
		fprintf ( stderr, "uncompress: corrupt input\n" );
	UNLINK ( ofname );
	exit ( 2 );
}

cl_block ()		/* table clear for block compress */
{
	register long int rat;

	checkpoint = in_count + CHECK_GAP;
#ifdef DEBUG
	if ( debug ) 
	{
		fprintf ( stderr, "count: %ld, ratio: ", in_count );
	 		prratio ( stderr, in_count, bytes_out );
		fprintf ( stderr, "\n");
	}
#endif /* DEBUG */

	if(in_count > 0x007fffff) 	/* shift will overflow */
	{	
		rat = bytes_out >> 8;
		if(rat == 0) /* Don't divide by zero */
		{		
			rat = 0x7fffffff;
		} 
		else 
		{
			rat = in_count / rat;
		}
	} 
	else 
	{
		rat = (in_count << 8) / bytes_out;	/* 8 fractional bits */
	}
	if ( rat > ratio ) 
	{
		ratio = rat;
	} 
	else 
	{
		ratio = 0;
#ifdef DEBUG
		if(verbose)
			dump_tab();	/* dump string table */
#endif
	 	cl_hash ( (count_int) hsize );
		free_ent = FIRST;
		clear_flg = 1;
		output ( (code_int) CLEAR );
#ifdef DEBUG
		if(debug)
			fprintf ( stderr, "clear\n" );
#endif /* DEBUG */
	}
}/*end of cl_block*/

cl_hash(hsize)		/* reset code table */
	register count_int hsize;
{
	register count_int *htab_p = htab;
	register long m1 = -1;

	/*set the code table to be all -1's */

	(void)memset(htab_p,m1,(hsize * 4));
}

prratio(stream, num, den)
FILE *stream;
long int num, den;
{
	double dnum, dden, dq;
#ifdef thisdoesnotwork
	register int q;			/* Doesn't need to be long */

	if(num > 214748L) 	/* 2147483647/10000 */
	{
		q = num / (den / 10000L);
	} 
	else 
	{
		q = 10000L * num / den;		/* Long calculations, though */
	}
	if (q < 0) 
	{
		putc('-', stream);
		q = -q;
	}
	fprintf(stream, "%d.%02d%%", q / 100, q % 100);
#endif
/* RENE 7-11-86 */
	dnum = (double) num;
	dden = (double) den;
	dq = dnum / dden;
	fprintf(stream, "%.2f%%",dq * 100);
}

version()
{
	fprintf(stderr, "%s\n", rcs_ident);
	fprintf(stderr, "Options: ");
#ifdef vms
	fprintf(stderr, "vms, ");
#endif
#ifdef NO_UCHAR
	fprintf(stderr, "NO_UCHAR, ");
#endif
#ifdef SIGNED_COMPARE_SLOW
	fprintf(stderr, "SIGNED_COMPARE_SLOW, ");
#endif
#ifdef COMPATIBLE
	fprintf(stderr, "COMPATIBLE, ");
#endif
#ifdef DEBUG
	fprintf(stderr, "DEBUG, ");
#endif
#ifdef BSD4_2
	fprintf(stderr, "BSD4_2, ");
#endif
	fprintf(stderr, "BITS = %d\n", BITS);
}

printman()
{
#ifdef unix
fprintf(stderr,
" * Usage: compress [-dfvcr] [-b bits] [file ...]\n");
#else
fprintf(stderr,
" * Usage: compress [-fvcr] [-d [-s fixrecordsize]] [-b bits] [file ...]\n");
#endif
fprintf(stderr,
" * Inputs:\n");
fprintf(stderr,
" *	-d		If given, decompression is done instead.\n");
fprintf(stderr,
" *	-c		Write output on stdout, don't remove original.\n");
fprintf(stderr,
" *	-r  		Write release or version being used.\n");
fprintf(stderr,
" *	-b		Parameter limits the max number of bits/code.\n");
fprintf(stderr,
" *	-f 		Forces output file to be generated, even if one already\n");
fprintf(stderr,
" *			exists, and even if no space is saved by compressing.\n");
fprintf(stderr,
" *			If -f is not used, the user will be prompted if stdin is\n");
fprintf(stderr,
" *			a tty, otherwise, the output file will not be overwritten.\n");
fprintf(stderr,
" *	  -v 		Write compression statistics.\n");
fprintf(stderr,
" *	  -? 		print manual.\n");
#ifdef vax
fprintf(stderr,
" *	  -s:		 forces output file to be fixed_length record format, with\n");
fprintf(stderr,
" *			 block size <n>, instead of stream format with line-feed\n");
fprintf(stderr,
" *			 terminator. (VMS only)\n");
#endif
fprintf(stderr,
" * 	  file ...	 List of files to be compressed (or decompressed).\n");
fprintf(stderr,
" * Outputs:\n");
#ifdef unix
fprintf(stderr,
" *	file.Z 		Compressed form of file with same mode, owner, and utimes.\n");
#else /* vms */
fprintf(stderr,
" *	file_z 		Compressed form of file with same mode, owner, and utimes.\n");
#endif
fprintf(stderr,
" *\n");
sleep(8);
fprintf(stderr,
" * Examples:\n");
fprintf(stderr,
" *	1. The following command  'compress -v file.dgn' will compress \n");
#ifdef unix
fprintf(stderr,
" *	file.dgn by creating file.dgn.Z and deleting file.dgn .\n");
#else  /* vms */
fprintf(stderr,
" *	file.dgn by creating file.dgn_z and deleting file.dgn .\n");
#endif
fprintf(stderr,
" *	The 'v' flag will print out some compression statistic.\n");
#ifdef unix 
fprintf(stderr,
" *	2. compress -d file.dgn.Z	  (or compress -d file.dgn)\n");
fprintf(stderr,
" *	  will decompress file.dgn.Z, create file.dgn and removes\n");
fprintf(stderr,
" *	file.dgn.Z\n");
#else
fprintf(stderr,
" *	2. compress -d file.dgn_z	  (or compress -d file.dgn)\n");
fprintf(stderr,
" *	  will decompress file.dgn_z, create file.dgn and removes\n");
fprintf(stderr,
" *	file.dgn_z\n");
#endif
}

stripsc(filename)
char *filename;
{
	int i;

	i = strlen(filename);
	for (i = strlen(filename); i > 0; i--)
		if (filename[i] == ';') {
			filename[i] = '\0';
			return(0);
		}
}
#ifdef vax
/* Program to modify the record attributes of a file.
  	Note: The file contents are not changed. */
#include descrip
#include iodef
#include ssdef
#include rms
/*	File Information Block definitions	*/

struct	FIB	
{
		int	fib$l_acctl : 24;
#define	FIB$V_WRITE  0x00000008
#define	FIB$M_WRITE  0x00000100
		char	fib$b_wsize;
		short	fib$w_fid[3];
		short	fib$w_did[3];
	   unsigned	int	fib$l_wcc;
	   unsigned	short	fib$w_nmctl;
	   unsigned	short	fib$w_exctl;
		int	fib$l_exsz;
		int	fib$l_exvbn;
	   unsigned	char	fib$b_alopts;
		char	fib$b_alalign;
		short	fib$w_alloc[5];
		short	fib$w_verlimit;
	   unsigned		: 16;
};

struct 
{
	unsigned	: 32;
	unsigned short	fib$w_fid_num;
	unsigned short	fib$w_fid_seq;
	unsigned short	fib$w_fid_rvn;
	unsigned short	fib$w_did_num;
	unsigned short	fib$w_did_seq;
	unsigned short	fib$w_did_rvn;
	unsigned	: 32;
	unsigned	: 16;
	unsigned short	fib$w_cntrlfunc;
		 int	fib$l_cntrlval;
	unsigned	: 32;
	unsigned	: 16;
	unsigned short	fib$w_loc_num;
	unsigned short	fib$w_loc_seq;
	unsigned short	fib$w_loc_rvn;
	unsigned int	fib$l_loc_addr;
};

struct {
	unsigned	: 32;
	unsigned	: 32;
	unsigned char	fib$b_fid_rvn;
	unsigned char	fib$b_fid_nmx;
	unsigned	: 32;
	unsigned char	fib$b_did_rvn;
	unsigned char	fib$b_did_nmx;
	unsigned short	fib$w_loc_fid[3];
};

struct {
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 32;
	unsigned	: 16;
	unsigned char	fib$b_loc_rvn;
	unsigned char	fib$b_loc_nmx;
	};

globaldef struct FIB cc$acp_fib = 0;
/*	Record Attributes Area definitions	*/

struct	FAT	{
#define	FAT$S_RTYPE  0x00000004
	unsigned	fat$b_rtype :FAT$S_RTYPE;
#define	FAT$V_RTYPE  0x00000000
#define FAT$M_RTYPE  (((1 << FAT$S_RTYPE) - 1) << FAT$V_RTYPE)
#define	FAT$C_FIXED  0x00000001

#define	FAT$S_FILEORG  0x00000004
	unsigned	fat$b_fileorg :FAT$S_FILEORG;
#define	FAT$V_FILEORG  0x00000004
#define FAT$M_FILEORG  (((1 << FAT$S_FILEORG) - 1) << FAT$V_FILEORG)
#define	FAT$C_SEQUENTIAL  0x00000000

	unsigned char	fat$b_rattrib;
#define	FAT$M_FORTRANCC  0x00000001
#define	FAT$M_IMPLIEDCC  0x00000002
#define	FAT$M_NOSPAN  0x00000008
#define	FAT$M_PRINTCC  0x00000004
#define	FAT$V_FORTRANCC  0x00000000
#define	FAT$V_IMPLIEDCC  0x00000001
#define	FAT$V_NOSPAN  0x00000003
#define	FAT$V_PRINTCC  0x00000002

	unsigned short	fat$w_rsize;

	unsigned int	fat$l_hiblk;

	unsigned int	fat$l_efblk;

		short	fat$w_ffbyte;

	unsigned char	fat$b_bktsize;

	unsigned char	fat$b_vfcsize;

	unsigned short	fat$w_maxrec;

	unsigned short	fat$w_defext;

	unsigned	:32;
	unsigned	:32;
	unsigned	:16;

	unsigned short	fat$w_versions;
};
#define	FAT$C_LENGTH  0x00000020
#define	FAT$K_LENGTH  0x00000020
struct		{

	unsigned	:32;

	unsigned short	fat$w_hiblkh;

	unsigned short	fat$w_hiblkl;

	unsigned short	fat$w_efblkh;

	unsigned short	fat$w_efblkl;

	unsigned	:32;
	unsigned	:32;

		short	fat$w_gbc;
};

#define	ATR$C_RECATTR  0x00000004
#define	ATR$S_RECATTR  0x00000020

struct FAB iofab;
struct NAM ionam;
char result_file_name[200];
char expand_file_name[200];
char default_name[] = "";

struct FIB iofib;
struct dsc$descriptor_s fib_desc = 
			{sizeof iofib,DSC$K_DTYPE_T,DSC$K_CLASS_S,&iofib};
struct FAT rec_attr;
struct
{ unsigned short size;
  unsigned short type;
  int *addr;
} atr[2] = {{ATR$S_RECATTR,ATR$C_RECATTR,&rec_attr},{0,0,0}};

unsigned short input_chan;
unsigned short disk_chan;
struct dsc$descriptor_s disk = 
			{0,DSC$K_DTYPE_T,DSC$K_CLASS_S,&ionam.nam$t_dvi[1]};
struct dsc$descriptor_s file = {0,DSC$K_DTYPE_T,DSC$K_CLASS_S,0};

char prompt[100];

#define FAILURE 999

changeattr(file_name, maxrecsize)
char *file_name;
int maxrecsize;
{
  int x;
  unsigned short iosb[4];
  int rsl;
  char rsa[256];
  struct dsc$descriptor_s rsd = {sizeof rsa,DSC$K_DTYPE_T,DSC$K_CLASS_S,rsa};

  iofab = cc$rms_fab;
  iofab.fab$l_dna = default_name;
  iofab.fab$b_dns = sizeof default_name - 1;
  iofab.fab$l_fna = file_name;
  iofab.fab$b_fns = strlen(file_name);
  iofab.fab$l_fop = FAB$M_NAM;
  iofab.fab$w_ifi = 0;
  iofab.fab$l_nam = &ionam;
  ionam = cc$rms_nam;
  ionam.nam$l_rsa = result_file_name;
  ionam.nam$b_rss = sizeof result_file_name;
  ionam.nam$l_esa = expand_file_name;
  ionam.nam$b_ess = sizeof expand_file_name;
  x = sys$parse(&iofab);
  if (x != RMS$_NORMAL)
  { fprintf(stderr,"\nError in parse of file name %1.*s",
	ionam.nam$b_rsl?ionam.nam$b_rsl:
			(ionam.nam$b_esl?ionam.nam$b_esl:iofab.fab$b_fns),
		 ionam.nam$b_rsl?ionam.nam$l_rsa:
			(ionam.nam$b_esl?ionam.nam$l_esa:iofab.fab$l_fna));
	return(FAILURE);
  }
  x = sys$search(&iofab);
  if (x != RMS$_NORMAL)
  { printf("\nError in search");
	return(FAILURE);
  }
  disk.dsc$w_length = ionam.nam$t_dvi[0];
  x = sys$assign(&disk,&disk_chan,0,0);
  if (x != SS$_NORMAL)
  { fprintf(stderr,"\nError in assign");
	return(FAILURE);
  }
  iofib = cc$acp_fib;
  iofib.fib$l_acctl = FIB$M_WRITE;
  for (x=0;x != 3;x++) iofib.fib$w_did[x] = ionam.nam$w_did[x];
  file.dsc$w_length = ionam.nam$b_name+ionam.nam$b_type+ionam.nam$b_ver;
  file.dsc$a_pointer = ionam.nam$l_name;
  rsl = 0;
  x = sys$qiow(0,disk_chan,IO$_ACCESS|IO$M_ACCESS,iosb,0,0,
		  		&fib_desc,&file,&rsl,&rsd,atr,0);
  if (x != SS$_NORMAL)
  { fprintf(stderr,"\nError in qio");
	return(FAILURE);
  }
  if (iosb[0] != SS$_NORMAL)
  { fprintf(stderr,"\nError from driver");
	if (rsl != 0) printf("\n%1.*s",rsl,rsa);
	return(FAILURE);
  }
  rec_attr.fat$b_rtype = FAT$C_FIXED;
  rec_attr.fat$b_fileorg = FAT$C_SEQUENTIAL;
  rec_attr.fat$b_rattrib = 0;
  rec_attr.fat$w_rsize = maxrecsize;
  rec_attr.fat$w_maxrec = maxrecsize;

/* write the attributes */
  x = sys$qiow(0,disk_chan,IO$_DEACCESS,iosb,0,0,&fib_desc,0,0,0,atr,0);
  if (x != SS$_NORMAL)
  { fprintf(stderr,"\nError in qio");
	return(FAILURE);
  }
  if (iosb[0] != SS$_NORMAL)
  { fprintf(stderr,"\nError from driver");
	if (rsl != 0) printf("\n%1.*s",rsl,rsa);
	return(FAILURE);
  }
  return(0);
}
#endif

int getbyte()
{
	return(buffer[countdone] & 0xff);
}
