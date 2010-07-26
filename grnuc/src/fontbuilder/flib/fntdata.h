/*
$Log: fntdata.h,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:17  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:35  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:29  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:23  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:28  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  19:17:14  tim
 * COMMENT : added Log variable
 *
*/
#include "local.h"

typedef struct  
{
  char    clib_nm[256];        /* cell library name */
  char    flib_nm[256];        /* font library name */
  char    font_nm[40];         /* font name */
  char    font_desc[80];       /* font description */
  short   font_num;            /* font number */
  short   char_num;            /* character number */
  short   class;               /* 0 for char,1 for symbol, 2 for pattern */
  short   type;                /* 1=byte, 2=word, 4=longword */
  short   scale;               /* x, y scale */
  short   tile_hgt;            /* tile_hgt of font */
  short   toler;               /* tolerance to stroke font */
  bool    dimen;               /* if true then dashed box is present */
  short   xorg;                /* x origin of character */
  short   yorg;                /* y origin of character */    
  bool    fast;                /* true if fast font, false if regular */
  long    tot_byt_cnt;         /* total byte count of all ch hdrs */
  short   num_ch;              /* number of defined characters in font */
  bool    three_d;             /* indicates if cell library is 3D */
  double  x_scale;             /* number to scale the font box by */
  double  y_scale;             /* number to scale the font box by */
  short   num_font;            /* number of fonts to be processed */
  long    xmin;                /* x on bottom left of solid box */
  long    xmax;                /* x max on solid box */
  long    ymin;                /* y on bottom left of solid box */
  long    ymax;                /* y max on solid box */
  bool    comp_bit;            /* False unless user wants to run old way */
  bool    lis_br;              /* list brief = TRUE; full=FALSE */
  bool    lis_dmp;             /* dump if TRUE */
  bool    intl_chars;          /* True if want international */
  double  pat_rep[2];          /* scale for dit replication */
} fontdata ;
