/*
  These routines were developed by using a program written by Larry Hughes
  as a starting point.

  Modifications by Robert Tracy
*/

#include <stdio.h>
#include <malloc.h>
#include <string.h>

#include "evtobdf.h"
#include "util.h"

/* default font values */
#define FONT_RESOLUTION  100

#define GENERATE_XLFD 1

#define Usage "Usage: evtobdf [-t [-i -b]] [-o output] font\n"


#ifdef __STDC__
int evtobdf (char *in, char *out, int text_font, int italic, int bold);
int  get_font_ascent  (BDF_CharInfo *cptr);
void add_int_property (BDF_FontInfo *bdf, char *name, int value);
void add_str_property (BDF_FontInfo *bdf, char *name, char *value);
void alloc_property   (BDF_FontInfo *bdf);
char *get_property    (BDF_FontInfo *bdf, char *name);
void write_font_info  (FILE *fp, BDF_FontInfo *bdf);
void write_char_info  (FILE *fp, BDF_CharInfo *cptr);
#else
void add_int_property ();
void add_str_property ();
void alloc_property   ();
char *get_property    ();
void write_font_info  ();
void write_char_info  ();
#endif


extern int  optind;
extern char *optarg;



/****************************************************************************/
main (argc, argv)
char *argv[];
int  argc;
{
    char *env = NULL;
    char *bdf = NULL;
    int  text_font;
    int  italic;
    int  bold;
    int  status;
    char opt;

    /* command line options are used to help determine font characteristics */

    text_font = 0;
    italic = 0;
    bold = 0;
    while ( (opt = getopt (argc, argv, "o:tib?")) != (-1) )
	switch (opt) {
	    case 'o': bdf = strdup (optarg);	break;
	    case 't': text_font = 1;		break;
	    case 'i': italic = 1;		break;
	    case 'b': bold = 1;			break;
	    case '?': fprintf (stderr, Usage);	exit (-1);
	    }

    env = strdup (argv[optind]);
    
    status = evtobdf (env, bdf, text_font, italic, bold);

    exit (status);

} /* main */


/****************************************************************************/
/* ARGSUSED */
int evtobdf (ifn, ofn, text_font, italic, bold)
char *ifn;		/* name of EV symbol file to translate */
char *ofn;		/* name of output BDF file */
int  text_font;		/* is this a text font */
int  italic;		/* is this text font italisized */
int  bold;		/* is this text font boldfaced */
{
    /* general stuff */
    char           *basename;
    
    /* EV symbol file stuff */
    unsigned long  bitmapstart;
    unsigned char  rash, rasw, symw, symh;
    char           xoff, yoff;
    unsigned short boff;
    unsigned char  *ibuf, *cp;
    int            hdrndx[256];
    int            j, nbytes, bytes_wide;
    int            last = 0;
    int            i;
    
    /* bdf font file stuff */
    FILE           *ofp;
    BDF_FontInfo   bdf;
    BDF_CharInfo   chars[MAX_CHARS], *cptr;
    char           font_family[16];
    int            font_ascent = 0;
    int            average_width, nsymbols;
    int            proportional, osymw;
    int            height, xheight;

    /* read input file */
    if ((ibuf=read_symfile(ifn)) == NULL) return -1;
    cp = ibuf;

    /* find the base name of font */
    basename = strrchr(ifn,(int)'/');
    if (basename == NULL) basename = ifn;
    else basename++;
    
    /* font family is determined from file name */
    if (text_font) {
	if      (strstr(basename,"dutch")) strcpy(font_family, "dutch");
	else if (strstr(basename,"swiss")) strcpy(font_family, "swiss");
	else if (strstr(basename,"mono"))  strcpy(font_family, "fixed");
	else strcpy(font_family, "tracy");
	}
    
    bdf.text_font = text_font;
    bdf.ascent = 0;
    bdf.descent = 0;
    bdf.bbox_width = bdf.bbox_height = bdf.num_chars = bdf.point_size = 0;
    bdf.x_origin_offset = bdf.y_origin_offset = 1000;
    
    /* get bitmap starting address */
    bitmapstart = get_ulong (ibuf);
    cp += sizeof(unsigned long);
    
    average_width = 0;	nsymbols = 0;
    proportional = 0;	osymw = 0;

    /* determine what characters are defined */
    for (i=0; i<MAX_CHARS; i++) if (hdrndx[i] = (unsigned int) *cp++) last = i;
    bdf.num_chars = last+1;

    /* loop through symbols  */
    for (cptr=chars, i=0; i<=last; i++, cptr++) {

	/* skip symbols with no bitmap */
	if (hdrndx[i] == 0) {
	    cptr->name = i;
	    cptr->bbox_width  = 0;
	    cptr->bbox_height = 0;
	    cptr->x_origin_offset = 0;
	    cptr->y_origin_offset = 0;
	    cptr->scalable_width = 0;
	    cptr->device_width = 0;
	    continue;
	}

	cptr->name = i;

	/* get symbol header for current symbol */
	cp = ibuf + 252 + (hdrndx[i] * 8);
	boff = get_ushort (cp);
	cp += sizeof(short);
	
	rasw = *cp++;
	rash = *cp++;
	xoff = *cp++;
	yoff = *cp++;
        symw = *cp++;
	symh = *cp;

	/* text-specific calculations */
	if (text_font) {
	    
	    /* average width calculation */
	    average_width += symw;
	    nsymbols++;

	    /* proportional spacing determination */
	    if (!proportional) {
		if ((osymw != 0) && (osymw != symw)) proportional = 1;
		osymw = symw;
		}
	    }
	
	cptr->bbox_width = rasw;
	cptr->bbox_height = rash;
	cptr->x_origin_offset = xoff;
	cptr->y_origin_offset = -yoff-rash;

	height = MAX(symh, rash);

	/* the XNeWS server doesn't like the point size to be bigger than 72 */
	if (bdf.point_size == 0) {

	    /* use the real point size for text fonts */
	    if (text_font) bdf.point_size = ((double)symh * 72.27) / (double)FONT_RESOLUTION;

	    /* just make up a number (p <= 72) for symbol fonts */
	    else bdf.point_size = 72;
	    }

	cptr->scalable_width = ((cptr->bbox_width * 72000) / (FONT_RESOLUTION * bdf.point_size));
	cptr->device_width = symw;

	/* calculate global font values */
	bdf.bbox_height = MAX(bdf.bbox_height,cptr->bbox_height);
	bdf.bbox_width = MAX(bdf.bbox_width, cptr->bbox_width);
	bdf.x_origin_offset = MIN(bdf.x_origin_offset, cptr->x_origin_offset);
	bdf.y_origin_offset = MIN(bdf.y_origin_offset, cptr->y_origin_offset);
	bdf.descent = MAX(bdf.descent, height);

	/* get bitmap for current symbol */
	cp = ibuf + bitmapstart + boff;
	bytes_wide = (cptr->bbox_width+7)/8;
	nbytes = bytes_wide * cptr->bbox_height;
	cptr->bitmap = cp;
	for (j=0; j<nbytes; j++) flipbyte(&cptr->bitmap[j]);
	for (j=1; j<=cptr->bbox_height; j++)
	    maskbyte(&(cptr->bitmap[j*bytes_wide-1]), cptr->bbox_width);
	}

    /* text-specific processing */
    if (text_font) {

	/* determine ascent of font (from upper-case z) */
	cptr = &chars['Z'];
	font_ascent = get_font_ascent(cptr)
	              - cptr->bbox_height - cptr->y_origin_offset;

	/* compensate for font ascent */
	bdf.ascent = font_ascent;
	bdf.descent -= font_ascent;
	bdf.y_origin_offset += font_ascent;
	for (cptr=chars, i=0; i<=last; i++, cptr++)
	    if (hdrndx[i]) cptr->y_origin_offset += font_ascent;

	/* determine xheight */
	xheight = chars['x'].bbox_height;

	/* average width (in 1/10ths of a pixel) */
	average_width *= 10;
	average_width /= nsymbols;
	}


    /* generate font properties and name */
    
    bdf.nproperties = 0;
    add_int_property (&bdf, "FONT_ASCENT",	bdf.ascent);
    add_int_property (&bdf, "FONT_DESCENT",	bdf.descent);
    add_str_property (&bdf, "COPYRIGHT",	"Copyright 1991, Intergraph Corporation");
	
#if GENERATE_XLFD
    /* generate an appropriate font name */
    if (text_font) {

	/* X Logical Font Description stuff */
	add_str_property (&bdf, Pfoundry,		"intergraph");
	add_str_property (&bdf, Pfamily,		font_family);
	add_str_property (&bdf, Pweight_name,		(bold ? "bold" : "medium"));
	add_str_property (&bdf, Pslant,			(italic ? "i" : "r"));
	add_str_property (&bdf, Psetwidth_name,		"normal");
	add_str_property (&bdf, Padd_style_name,	"");
	add_int_property (&bdf, Ppixel_size,		xheight);
	add_int_property (&bdf, Ppoint_size,		bdf.point_size*10);
	add_int_property (&bdf, Presolution_x,		FONT_RESOLUTION);
	add_int_property (&bdf, Presolution_y,		FONT_RESOLUTION);
	add_str_property (&bdf, Pspacing,		(proportional ? "p" : "m"));
	add_int_property (&bdf, Paverage_width,		average_width);
	add_str_property (&bdf, Pcharset_registry,	"iso8859");
	add_str_property (&bdf, Pcharset_encoding,	"1");

	sprintf (bdf.name,
		 "-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s",
		 get_property (&bdf, Pfoundry),
		 get_property (&bdf, Pfamily),
		 get_property (&bdf, Pweight_name),
		 get_property (&bdf, Pslant),
		 get_property (&bdf, Psetwidth_name),
		 get_property (&bdf, Padd_style_name),
		 get_property (&bdf, Ppixel_size),
		 get_property (&bdf, Ppoint_size),
		 get_property (&bdf, Presolution_x),
		 get_property (&bdf, Presolution_y),
		 get_property (&bdf, Pspacing),
		 get_property (&bdf, Paverage_width),
		 get_property (&bdf, Pcharset_registry),
		 get_property (&bdf, Pcharset_encoding));

	/* alias (Environ V font name) */
	strcpy (bdf.alias, basename);
	}
    else
#endif
	strcpy (bdf.name, basename);
    
    /* open output file */
    if (ofn != NULL) {
	if ((ofp=fopen(ofn, "w")) == NULL) {
	    fprintf (stderr, "Unable to open BDF symbol file \"%s\"\n", ofn);
	    return (-1);
	    }
	}
    else ofp = stdout;
    
    /* write file header */
    write_font_info(ofp, &bdf);

    /* write each printable character's data */
    for (cptr=chars, i=0; i<=last; i++, cptr++)
	write_char_info(ofp, cptr);

    /* required keyword */
    fprintf (ofp, "ENDFONT\n");
    
    fclose (ofp);
    
    /* free allocated memory */
    free (ibuf);
    
    return 0;
    
} /* evtobdf */


/****************************************************************************/
get_font_ascent (cptr)
BDF_CharInfo *cptr;
{
    int bytes_wide;
    int blankrow;
    int i, j;

    bytes_wide = (cptr->bbox_width+7)/8;

    /* determine blank rows at bottom of 'A' */
    for (i=cptr->bbox_height-1; i>=0; i--) {
	blankrow = 1;
	for (j=bytes_wide*i; j<bytes_wide*(i+1); j++) {
	    if (cptr->bitmap[j] != 0x00) {
		blankrow = 0;
		break;
		}
	    }
	if (!blankrow) break;
	}

    return i+1;
    
} /* get_font_ascent */


/****************************************************************************/
void add_int_property (bdf, name, ivalue)
BDF_FontInfo *bdf;
char *name;
int ivalue;
{
    Property *property;

    alloc_property (bdf);

    property = &bdf->proplist[bdf->nproperties];
    property->name    = strdup(name);
    property->value.n = ivalue;
    property->type    = IntProperty;

    bdf->nproperties++;
    
} /* add_int_property */


/****************************************************************************/
void add_str_property (bdf, name, svalue)
BDF_FontInfo *bdf;
char *name;
char *svalue;
{
    Property *property;

    alloc_property (bdf);

    property = &bdf->proplist[bdf->nproperties];
    property->name    = strdup(name);
    property->value.s = strdup(svalue);
    property->type    = StrProperty;

    bdf->nproperties++;

} /* add_str_property */


/****************************************************************************/
void alloc_property (bdf)
BDF_FontInfo *bdf;
{
    if (bdf->nproperties == 0)
	bdf->proplist = (Property *) malloc (sizeof(Property));
    else
	bdf->proplist = (Property *) realloc (bdf->proplist, ((bdf->nproperties+1) * sizeof(Property)));

} /* alloc_property */


/****************************************************************************/
char *get_property (bdf, name)
BDF_FontInfo *bdf;
char *name;
{
    char svalue[256];
    int i;

    for (i=0; i<bdf->nproperties; i++) {
	if (strcmp(name, bdf->proplist[i].name) == 0) {
	    if (bdf->proplist[i].type == StrProperty)
		return bdf->proplist[i].value.s;
	    else {
		sprintf (svalue, "%d", bdf->proplist[i].value.n);
		return strdup(svalue);
		}
	    }
	}

    return NULL;

} /* get_property */


/****************************************************************************/
void write_font_info (fp, bdf)
FILE          *fp;
BDF_FontInfo  *bdf;
{
    int i;
    
    fprintf (fp, "STARTFONT 2.1\n");
#if GENERATE_XLFD
    if (bdf->text_font) fprintf (fp, "COMMENT ALIAS %s\n", bdf->alias);
#endif
    fprintf (fp, "FONT %s\n", bdf->name);
    fprintf (fp, "SIZE %d %d %d\n",
	     bdf->point_size, FONT_RESOLUTION, FONT_RESOLUTION);
    fprintf (fp, "FONTBOUNDINGBOX %d %d %d %d\n",
	     bdf->bbox_width, bdf->bbox_height,
	     bdf->x_origin_offset, bdf->y_origin_offset);

    fprintf (fp, "STARTPROPERTIES %d\n", bdf->nproperties);
    for (i=0; i<bdf->nproperties; i++) {
	if (bdf->proplist[i].type == StrProperty)
	    fprintf (fp, "%s \"%s\"\n",
		     bdf->proplist[i].name, bdf->proplist[i].value.s);
	else
	    fprintf (fp, "%s %d\n",
		     bdf->proplist[i].name, bdf->proplist[i].value.n);
	}
    
    fprintf (fp, "ENDPROPERTIES\n");
    fprintf (fp, "CHARS %d\n", bdf->num_chars);
    
} /* write_font_info */


/****************************************************************************/
void write_char_info (fp, cptr)
FILE          *fp;
BDF_CharInfo  *cptr;
{
   register             i, j, bytes_wide;
   unsigned char        *cp;

   fprintf (fp, "STARTCHAR char%02d\n", (int)cptr->name);
   fprintf (fp, "ENCODING %d\n", cptr->name);
   fprintf (fp, "SWIDTH %d 0\n", cptr->scalable_width);
   fprintf (fp, "DWIDTH %d 0\n", cptr->device_width);
   fprintf (fp, "BBX %d %d %d %d\n",
	    cptr->bbox_width, cptr->bbox_height,
	    cptr->x_origin_offset, cptr->y_origin_offset);

   fprintf (fp, "BITMAP\n");
   bytes_wide = (int) ((cptr->bbox_width+7) / 8);
   cp = cptr->bitmap;
   for (i=0; i<cptr->bbox_height; i++) {
       for (j=0; j<bytes_wide; j++)
	   fprintf (fp, "%02x",  (unsigned char ) *cp++);
       fprintf (fp, "\n");
       }

   fprintf (fp, "ENDCHAR\n");
   
} /* write_char_info */
