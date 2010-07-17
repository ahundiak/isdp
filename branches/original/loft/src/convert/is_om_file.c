#include	<stdio.h>
#include	<sys/stat.h>
#include	<sys/types.h>
#include	<fcntl.h>
#include	<unistd.h>

#define	OM44		0x00040004
#define	OM45		0x00050004
#define	OM13		0x00030001
#define	OM14		0x00040001
#define	OM_MAGIC	0x4d4f

#define	PRODUCT_NAME	"Man"
#define	ARRAY_LENGTH	128

/*	#define	TRACE	*/

/* This C executable is directly copied from som_is_om_file() function of
   I/EXNUC. Only the LITTLE_ENDIAN case is taken in account. We don't matter
   with the other outputs of som_is_om_file(). We only need a TRUE/FALSE
   status returned by IsOmFile (filename). Thanks to I/EXNUC people.
   We need to known if an UNIX file is an design-file. This function do it
   out of I/EMS session. This function returns 0 in case of a design-file 
   and 1 for other files.
*/

main ( argc, argv)

	int	argc;
	char	*argv[];

{
	int	 sts=1, f, i, ihdr[ARRAY_LENGTH];
	int	 Sint=sizeof(int), Sshort=sizeof(short), Schar=sizeof(char);
	struct	 stat	buf;
	unsigned short	shdr[2*ARRAY_LENGTH];
	char	 chdr[4*ARRAY_LENGTH];

	if (argc != 2) {
		printf( "Call is : IsOmFile filename\n");
		goto wrapup;
	}

	if (stat ( argv[1], &buf)) {
#ifdef TRACE
		printf( "Error in stat(%s)\n", argv[1]);
#endif
		goto wrapup;
	}

	if (!(f = open ( argv[1], O_RDONLY))) {
#ifdef TRACE
		printf( "Error in open(%s)\n", argv[1]);
#endif
		goto wrapup;
	}

	for ( i=0; i<ARRAY_LENGTH; ++i) {
		if (Sint != read ( f, &ihdr[i], Sint)) {
			close(f);
#ifdef TRACE
			printf( "Error in read(%s,int)\n", argv[1]);
#endif
			goto wrapup;
		}
	}

	lseek (f,0,0);
	for ( i=0; i<2*ARRAY_LENGTH; ++i) {
		if (Sshort != read ( f, &shdr[i], Sshort)) {
			close(f);
#ifdef TRACE
			printf( "Error in read(%s,short)\n", argv[1]);
#endif
			goto wrapup;
		}
	}

	lseek (f,0,0);
	for ( i=0; i<4*ARRAY_LENGTH; ++i) {
		if (Schar != read ( f, &chdr[i], Schar)) {
			close(f);
#ifdef TRACE
			printf( "Error in read(%s,char)\n", argv[1]);
#endif
			goto wrapup;
		}
	}

	close(f);

	if (  (  (ihdr[0] == OM44)
	      && ((ihdr[11]-ihdr[9]) == 8) )
	   || (  (ihdr[0] == OM45)
              && (((ihdr[10]-ihdr[9]) == 68) && ((ihdr[10]-ihdr[11]) == 64)) )
	   || (  (ihdr[0] == OM13)
              && (((ihdr[10]-ihdr[9]) == 68) && ((ihdr[10]-ihdr[11]) == 64)) )
	   || (  (ihdr[0] == OM14)
              && (((ihdr[10]-ihdr[9]) == 68) && ((ihdr[10]-ihdr[11]) == 64)) )
	   || (  (shdr[0] == OM_MAGIC) ) ) {
		sts = search_product_name ( shdr, 2*ARRAY_LENGTH);
	}

wrapup:
	return (sts);
}

int search_product_name ( unsigned short *hdr, int siz)

{

	int	i, len=strlen(PRODUCT_NAME);

#ifdef TRACE
	printf( "Fancy name <%s>\n", &hdr[207]);
#endif

	for ( i=0; i<siz-len+1; i++) {
		if (!strcmp(&hdr[i],PRODUCT_NAME))	return 0;
	}

	return 1;
}
