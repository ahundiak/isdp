#include <stdio.h>
#include <string.h>
#include "util.h"

#define Usage "Usage: evtoxbm font index output\n"

typedef struct _XBM_SymbolInfo
{
    char          *name;
    unsigned char *bitmap;
    int           bbox_width;
    int           bbox_height;
} XBM_SymbolInfo;


#ifdef __STDC__
int evtoxbm    (char *in, int index, char *out);
void write_xbm (FILE *fp, XBM_SymbolInfo *symptr);
#else
void write_xbm ();
#endif


/****************************************************************************/
main (argc, argv)
char *argv[];
int  argc;
{
    char *env = NULL;
    char *xbm = NULL;
    int  index;
    int  status;

    /* the command line has a fixed format */
    if (argc != 4) {
	fprintf (stderr, Usage);
	exit (-1);
	}
    env = strdup (argv[1]);
    sscanf (argv[2], "%d", &index);
    xbm = strdup (argv[3]);

    status = evtoxbm (env, index, xbm);
    exit (status);
    
} /* main */


/****************************************************************************/
int evtoxbm (ifn, index, ofn)
char *ifn;		/* name of EV symbol file to translate */
int  index;		/* index of EV symbol to output */
char *ofn;		/* name of output XBM file */
{
    /* general stuff */
    char           *basename;
    char           *filepart;
    
    /* EV symbol file stuff */
    unsigned long  bitmapstart;
    unsigned char  rash, rasw;
    unsigned short boff;
    unsigned char  *ibuf, *cp;
    int            hdrndx;
    
    /* bdf font file stuff */
    FILE           *ofp;
    XBM_SymbolInfo sym;

    /* read input file */
    if ((ibuf=read_symfile(ifn)) == NULL) return -1;
    cp = ibuf;

    /* find the filename part of output file name */
    filepart = strrchr(ofn, (int)'/');
    if (filepart == NULL) basename = strdup(ofn);
    else basename = strdup(filepart+1);

    /* strip off any common suffix in filename */
    if      (strstr(basename,".xbm")  != NULL) basename[strlen(basename)-4] = '\0';
    else if (strstr(basename,".icon") != NULL) basename[strlen(basename)-5] = '\0';

    sym.name = strdup(basename);

    /* get bitmap starting address */
    bitmapstart = get_ulong (ibuf);
    cp += sizeof(unsigned long);

    /* find information for requested symbol */
    hdrndx = (int) *(cp+index);

    /* get symbol header */
    cp = ibuf + 252 + (hdrndx * 8);
    boff = get_ushort (cp);
    cp += sizeof(short);
    rasw = *cp++;
    rash = *cp++;

    sym.bbox_width = rasw;
    sym.bbox_height = rash;
    
    /* get bitmap for current symbol */
    sym.bitmap = ibuf + bitmapstart + boff;

    /* open output file */
    if ((ofp=fopen(ofn, "w")) == NULL) {
	fprintf(stderr, "Unable to open output XBM file \"%s\"\n", ofn);
	return (-1);
	}
    
    /* write symbol information */
    write_xbm (ofp, &sym);

    fclose(ofp);
    
    /* free allocated memory */
    free(ibuf);
    
    return 0;
    
} /* evtoxbm */


/****************************************************************************/
void write_xbm (fp, sym)
FILE          *fp;
XBM_SymbolInfo  *sym;
{
   int           bytes_wide;
   unsigned char *cp;
   int           i, j, k;

   fprintf (fp, "#define %s_width  %d\n", sym->name, sym->bbox_width);
   fprintf (fp, "#define %s_height %d\n", sym->name, sym->bbox_height);
   fprintf (fp, "static char %s_bits[] = {\n    ", sym->name);

   cp = sym->bitmap;
   bytes_wide = (int) ((sym->bbox_width+7) / 8);
   for (k=0, i=0; i<sym->bbox_height; i++) {
       for (j=0; j<bytes_wide; j++) {

	   /* print 12 bytes per line */
	   if (k) fprintf (fp, "%s", ((((k)%12)==0) ? ",\n    " : ", "));
	   k++;
	       
	   fprintf (fp, "0x%02x",  (unsigned char ) *cp++);
	   }
       }

   fprintf (fp, "};\n");

} /* write_xbm */
