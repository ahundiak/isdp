#ifdef apollo
#define ALLOCSIZE 262144  /* number of bytes in dynamic storage area for APOLLO */
#endif /* apollo */
#ifdef MSDOS
#define ALLOCSIZE 65500  /* num bytes in dynamic storage area for ms_dos */
#define ALLOCSIZE2 128000 /* num bytes in a second dynamic storage area */
#endif /* MSDOS */
#ifdef IPRO
#define ALLOCSIZE 262144	/* for interpro */
#endif
