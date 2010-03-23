
/*****************************************************************************
*                                                                            *
*               Copyright 1988, Bitstream Inc., Cambridge, MA                *
*                            Patent No. 4,785,391                            *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/* 
 *              FONTWARE CHARACTER GENERATOR TEST MODULE
 *
 * This is an illustration of what external resources are required to
 * load a Fontware outline and use the Fontware character generator
 * to generate bitmaps according to the desired specification.
 *
 * This program loads a Fontware outline, defines a set of character
 * generation specifications, generates one bitmap character and prints
 * it on the standard output.
 */

#include "stdef.h"             /* Bitstream standard macros */
#include "comp2_3.h"           /* Data structures for Fontware outline */
#include "mkbm.h"              /* Definitions for Fontware character generator */
#include "errchk.h"

#define MAX_BITS  256          /* Max line length of generated bitmap */
#define ONE_SEG_MEM 0          /* 1 if one segment of memory is required */
                               /* in MSDOS, 0 for two segments */
#if (!__MSDOS)
#define ALLOCSIZE 262144  /* number of bytes in dynamic storage area (Apollo) */
#endif /* apollo */

#if __MSDOS

#if ONE_SEG_MEM
#define ALLOCSIZE 62500
#else
#define ALLOCSIZE 128000  /* max num bytes in single memory block (ms_dos) */
#endif /* one segment or two of data */

#endif /* MSDOS */

#define SAMPLE2 1              /* Activates the first sample program */
/* #define DEBUG 1                /* Turns on debugging output */

static  fix15  raswid;             /* raster width  */
static  fix15  rashgt;             /* raster height */
static  fix15  offhor;             /* horizontal offset from left edge of emsquare */
static  fix15  offver;             /* vertical offset from baseline */
static  fix15  set_width;          /* character set width */
static  fix15  y_cur;              /* Current y value being generated and printed */
static  char   line_of_bits[MAX_BITS]; /* Buffer for row of generated bits */
static  ufix16 choff;              /* Offset of character to be generated   */

static ufix8 *alloc_buf=NULL;      /* pointer to storage area */
static ufix8 *allocp;              /* next free position */
static ufix32 m = ALLOCSIZE;       /* ammount of free space */
static cft_outl_str cfont;         /* Fontware outline structure            */


FUNCTION main(argc, argv)
int argc;
char *argv[];
{
char       cfont_name[100];    /* Fontware outline file name            */
fix        cfont_fd;           /* Fontware outline file descriptor      */
comp_char_desc compchar;       /* Bundle of character generation specs  */
fix31      search_cid();
void       alloc_reset();
fix        cft_load();         /* Loads Fontware outline into data struct */
boolean    fw_make_char();     /* Generates one bitmap character */
ufix16 cd[1024];               /* array of character offsets*/
fix        csd_load();         /* Loads Character Set Descriptor file*/
fix        i;                  /* Just a utilitarian variable */
fix     highest_char; /* highest char number of character in character set */

if (argc != 2) 
    {
    fprintf(stderr,"Usage sample font\n\n"); 
    exit (1);
    }

/* Initializations */
fw_reset();                    /* Reset Fontware character generator */
initalloc();                   /* Initialize dynamic memory allocation */

/* Load the Fontware outline file */
sprintf(cfont_name, argv[1]);
if ((cfont_fd = open (cfont_name, READ)) < 0)   /* Open the Fontware outline file */
    {
    printf("\n*** Cannot open Fontware outline file %s\n\n", cfont_name);
    return;
    }
if (cft_load (cfont_fd, &cfont) != 0)  /* Load Fontware outline */
    {
    close (cfont_fd);
    printf("Cannot load Fontware outline file \"%s\"\n", cfont_name);
    return;
    }

/* Set specifications for character to be generated */
compchar.compf = &cfont;         /* Pointer to Fontware outline structure */
compchar.mode = 1;
compchar.point_size_y = 25.0;    /* Point size (vertically in character) */
compchar.point_size_x = 25.0;    /* Point size (horizontally in character) */
compchar.res_hor = 300.0;        /* Horizontal device resolution */
compchar.res_ver = 300.0;         /* Vertical device resolution */
compchar.rot_angle = 0.0;        /* Rotation angle clockwise in degrees */
compchar.obl_angle = 0.0;        /* Obliquing angle clocksise in degrees */
compchar.whitewrite = FALSE;     /* TRUE if whitewriter bitmaps required */
compchar.thresh = 0.0;           /* Pixel activation threshold in pixel units */
compchar.import_widths = FALSE;  /* TRUE if width values imported */
compchar.clip.left = FALSE;      /* TRUE if clipping required at left side bearing */
compchar.clip.right = FALSE;     /* TRUE if clipping required at right side bearing */
compchar.clip.top = FALSE;       /* TRUE if clipping required at top of em square */
compchar.clip.bottom = TRUE;    /* TRUE if clipping required at bottom of em square */
compchar.squeeze.left = FALSE;   /* TRUE if squeezing required at left side bearing */
compchar.squeeze.right = FALSE;  /* TRUE if squeezing required at right side bearing */
compchar.squeeze.top = FALSE;    /* TRUE if squeezing required at top of em square */
compchar.squeeze.bottom = FALSE; /* TRUE if squeezing required at bottom of em square */
compchar.bogus_mode = FALSE;     /* TRUE if quality enhancement mechanism to be ignored */
fw_set_specs(&compchar);         /* Set character generation specifications */

#ifdef SAMPLE1
choff = 4;                       /* Position of required character in font */
if (!fw_make_char(choff))
    {
    printf("can't generate the requested bitmap\n", cfont_name);
    }                                              
#endif

#ifdef SAMPLE2       

/* compchar.point_size_y = 15.0;    Point size (vertically in character) */
/* compchar.point_size_x = 15.0;    Point size (horizontally in character) */
/* fw_set_specs(&compchar);         Set character generation specifications */

/* initialize the character offset array*/
for (i=0;i<1024;i++)  cd[i] = -1; 

highest_char = csd_load("ascii.txt", &cd[0], (fix)1024);
for (i=0;i <= highest_char;i++)
{
    if (cd[i] != -1)
    {
        choff = (ufix16)search_cid((fix31)cd[i]);
#ifdef DEBUG
        if (choff != -1) printf ("i=%d  cd[i]=%d choff=%d\n",i,cd[i],choff);
        else  printf ("i=%d  cd[i]=%d ****character id not found****\n",i,cd[i]);
#endif       
        cd[i] = choff;                              
    }
}

/* Generate and output one character */
for (i=0;i<highest_char;i++)
{                            

   /* Position of required character in font */
   if (cd[i] != -1) 
   {
       if (!fw_make_char(choff = cd[i]))
        {
        printf("can't generate the requested bitmap\n", cfont_name);
        }
   }
}
#endif
}


FUNCTION initalloc()
/* Called to initialize dynamic memory allocation
 *
 * NOTE: this routine should only be called once at the start of the 
 * the program. it gets the maximum amount of memory that it will need
 * from the system (malloc).
 */

#if (!__MSDOS) 
    DECLARE
    char *malloc();
    BEGIN
    set_sbrk_size (8388608);

    if ((alloc_buf = (ufix8 *)malloc ((ufix32) ALLOCSIZE)) == 0)
        {
        printf("initalloc: unable to malloc alloc_buf\n");
        return;
        } 
#endif /* apollo */

#if (__MSDOS) 

#if ONE_SEG_MEM
    DECLARE
    char *malloc();
    BEGIN   if ((alloc_buf = (char *)malloc ((ufix16) ALLOCSIZE)) == 0)
        {
        printf("initalloc: unable to malloc alloc_buf\n");
        return;
        } 
#else   
    DECLARE
    char huge *halloc();
    BEGIN   if ((alloc_buf = (char huge *)halloc ((ufix32) ALLOCSIZE, 1)) == 0)
        {
        printf("initalloc: unable to malloc alloc_buf\n");
        return;
        }
#endif /* one segment or two of data */

#endif /* MSDOS */

    alloc_reset();
    END


FUNCTION  ufix8  *alloc(n)   
  ufix32 n;          /* Number of bytes of memory requested */

/* Called by Fontware outline loader to allocate dynamic memory.
 * Returns pointer to block of memory if successful, NULL otherwise.
 */

    DECLARE
    BEGIN
    n = (n + 3) & 0xfffffffc;   /* assign on 32-bit bdries */
    if (n <= m)                 /* if enough mem left */
        {
        allocp += n;            /* pt to next block*/
        m -= n;
        return(allocp - n);     /* return ptr to block */
        }
    else                        /* not enough memory */
        return(NULL);
    END



FUNCTION  ufix32  alloccount()  

/* Called by Fontware outline loader to determine how much dynamic memory
 * is available.
 * Returns number of bytes of free space available.
 */

    DECLARE
    BEGIN
    return(m);
    END



FUNCTION  bool  dealloc(p)
  ufix8    *p;                  /* pointer to block of mem to be freed */

/* Called by Fontware outline loader to deallocate a block of dynamic memory.
 * The block returned must be the most recently allocated
 * Returns TRUE if successful, FALSE otherwise
 */
    DECLARE
    ufix32  n;

    BEGIN
    n = (ufix32)p;
    n = (n + 3) & 0xfffffffc;   /* deassign on 32-bit bdries */
    p = (ufix8 *)n;
    if ((p < alloc_buf)  ||  (p > allocp))     /* Kosher ptr? */
        return(FALSE);
    m += (ufix32)(allocp - p);
    allocp = p;                 /* recover space */
    return(TRUE);
    END



FUNCTION void alloc_reset() /* resets storage area */
/*
 *  resets global variables used by the memory allocation
 *  functions in this module. initalloc() should be called
 *  once before this routine is called.
 */
    DECLARE
    BEGIN
    allocp = (ufix8 huge *)alloc_buf;   /* beginning of storage area */
    m = ALLOCSIZE;                 /* amnt of free space */
    END


FUNCTION open_bitmap(width, xmin, xmax, ymin, ymax)
fix15 width;   /* Set width (whole pixels) */
fix15 xmin;    /* Pixel boundary at left extent of bitmap character */
fix15 xmax;    /* Pixel boundary at right extent of bitmap character */
fix15 ymin;    /* Pixel boundary of bottom extent of bitmap character */
fix15 ymax;    /* Pixel boundary of top extent of bitmap character */

/* Called by Fontware character generator to prepare memory to receive bitmap data.
 */

{
fix15 i;

set_width = width;
raswid = xmax - xmin;
rashgt = ymax - ymin;
offhor = xmin;
offver = ymin;     

printf("\n\nCharacter ID %d (offset %d)\n",
        cfont.chdir_dat[choff].char_id, choff);
printf("Generated bitmap character:\n");
printf("set width = %d\n", set_width);
printf("X offset  = %d\n", offhor);
printf("Y offset  = %d\n\n", offver);
for (i = 0; i < raswid; i++)
    {
    line_of_bits[i] = '.';
    }
line_of_bits[raswid] = '\0';
y_cur = 0;
}


FUNCTION  set_bitmap_bits (y, xbit1, xbit2)
  fix15     y;     /* Scan line (0 = first row above baseline) */
  fix15     xbit1; /* Pixel boundary where run starts */
  fix15     xbit2; /* Pixel boundary where run ends */

/* Called by Fontware character generator to write one row of pixels 
 * into the generated bitmap character.                               
 */

{
fix15 i;

while (y_cur != y)
    {
    printf("    %s\n", line_of_bits);
    for (i = 0; i < raswid; i++)
        {
        line_of_bits[i] = '.';
        }
    y_cur++;
    }
for (i = xbit1; i < xbit2; i++)
    {
    line_of_bits[i] = 'X';
    }
}


FUNCTION close_bitmap()

/* Called by Fontware character generator to indicate all bitmap data
 * has been generated.
 */

{
printf("    %s\n", line_of_bits);
}


#if VECT_OUT

FUNCTION open_outline(width)
real  width;   /* Set width (real pixels) */

/* Called by Fontware character generator to prepare memory to receive vector data.
 */

    {
    printf("\n\nCharacter ID %d (offset %d)\n",
              cfont.chdir_dat[choff].char_id, choff);
    printf("open outline with set_width %f\n", width);
    }
               

FUNCTION start_curve(x, y, outside)
real        x, y; 
boolean     outside;
    {                                             
    if (outside)
        printf("start outside curve (%f, %f)\n", x, y);
    else
        printf("start inside  curve (%f, %f)\n", x, y);
    }


FUNCTION  line_to (x, y)
real       x, y;     /* Scan line (0 = first row above baseline) */
    {              
    printf("line to (%f, %f)\n", x, y);
    }


FUNCTION start_new_char()
    {                                  
    printf("start new sub char\n");
    }


FUNCTION close_curve()
    {                              
    printf("close curve\n");
    }


FUNCTION close_outline(width)
real width;
/* Called by Fontware character generator to indicate all bitmap data
 * has been generated.
 */

    {                           
    printf("close outline with set width %f\n", width);
    printf("\n\n\n********************************\n");
    }       

#endif


FUNCTION  fix31  search_cid (chr_id)
  fix31     chr_id;

/*  SEARCH_CID -- returns a character offset number.
 *  Input argument:  chr_id is a character id number.
 *  Returns:         character offset number. Set to -1 if no match found for
 *                     a character id number.
 */
    DECLARE
    char   *aa;
    fix31   char_off;
    fix31   ii;

    BEGIN
    char_off = -1;
    for (ii=0; ii < cfont.fonthead.layout_size; ii++)
        {
        if (chr_id == cfont.chdir_dat[ii].char_id)
            {
            char_off = ii;
            break;
            }
        }
    return (char_off);
    END


FUNCTION  fix  csd_load(pname, cd, max)
  char   *pname;
  ufix16 cd[];
  int     max;

/*  CSD_LOAD -- loads a text format character set description file.

    The text file format that this routine supports consists of
        '$CSDTXT'   Required first seven characters of first line
        [whitespace] device_char_num ':' bitmap_char_num comment 

    Input arguments:
      pname -- name of character set descriptor file
      max -- max number of char ids permitted in csd file
      cd[] -- array for Bitstream character IDs
    Returns:
      hightest device character number referenced
      else, -1 if failure: can't open file or first line is not "$CSDTXT" 
*/

    DECLARE

    char    buff[80];
    FILE   *fp;
    fix31   ii,jj;
    ufix16 *p;
    char    tag[7];
    fix     num_chars;
    fix     highest_char; 
      
BEGIN
    highest_char = 0;
    fp = fopen (pname, "r");
    if (fp == NULL)
        {
        perror(pname);
        return(-1);
        }

    /* is it a binary csd file? (i.e. not text) */
    getln (fp, tag, (fix15)80);
    if (strncmp(tag,"$CSDTXT",7))
        {
        fclose(fp);
        return(-1);
        }
    /* is it a text csd file? */
    else
        {
        num_chars = 0;
        while ((ii = getln (fp, buff, (fix15)80)) >= 0)
            {
            if (sscanf (buff, "%ld:%ld", &jj, &ii) == 2)  
            /* device character number ':' Bitstream ID comment */
                {
                if (ii < 0  ||  ii > 65535)
                    {
#ifdef DEBUG
                    printf ("Invalid character ID %d in CSD file \"%s\"", ii, pname);
#endif
                    fclose(fp);
                    return(-1);
                    }
#ifdef DEBUG
                printf("cd[%d] = %d\n",jj,ii);
#endif
                cd[jj] = (ufix16)ii;
                num_chars++;
                if (jj > highest_char) highest_char = jj;
                }                             

            if (num_chars >= 1024  ||  num_chars >= max)
                break;
            }
        fclose(fp);
        }

    return(highest_char);
    END


FUNCTION  fix  getln(fp, buf, count)  /* Get line into buffer, return length */

  FILE  *fp;                /* file pointer */
  char  *buf;               /* buffer for input line */
  fix15  count;             /* maximum length string returned in 'buf' */

/*  GETLN (FP, BUF, COUNT)
 *  Reads an entire line, including the line ending, from a file (or stdin)
 *  Returns a 0-terminated string in 'buf' with a maximum length of 'count'
 *      bytes. The line ending is NOT a part of the string.
 *  Will detect either  <LF>  or  <CR><LF>  as a line ending
 *  Return value = string length of 'buf'.  = -1 if EOF found and no input.
 */

    DECLARE
    register    int c, i;

    BEGIN

    i = 0;
    count--;
    while ((c = getc(fp)) != EOF && c != '\n')
        {
        if (i < count)
            buf[i] = c;
        i++;
        }
    if (c == EOF && i == 0)
        return(-1);
    if (i > count)  i = count;
    if (i > 0  &&  buf[i-1] == '\015')
        i--;                        /* Remove the <CR> at the line ending */
    buf[i] = '\0';
    return(i);
    END


FUNCTION report_error (sev,id,cryptic,format,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9)
  fix sev;          /* severity of error: 0=WARNING,1=ERROR,2=FATAL_ERROR... */
  fix id;           /* error number that uniquely idenitfies call to report_error */
  bool cryptic;     /* TRUE when error message is too cryptic for end-users */
  char *format;     /* printf type argument list */
  int   a0,a1,a2,a3,a4,a5,a6,a7,a8,a9;

  DECLARE
  char message_buff[128];

  BEGIN
  strcpy(message_buff,"");
  sprintf(&message_buff[strlen(message_buff)],format,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9);
  fprintf(stderr,"\n*** ERROR (%d): %s ***\n",id,message_buff);
  END

