/********************************************************************\

 *  DESCRIPTION:

     This module creates a brief or full listing of the font library

 *  AUTHOR:    M. Futch        DATE:    29-April-1985

 *  MODIFICATIONS:

        M. Futch    DATE:    NOV-1985

            Changed the open, close, read, and write routines
            (OPENLIB,CLOSELIB,READ_FOT,READ_FH,READ_CDT,READBLK)
            to be more generic by allowing additional arguments -
            file control block and input/output buffer.  These
            changes allow more flexibility within the font software.
            This also eliminates having duplicate routines within
            the software.

\********************************************************************/
/* 
$Log: list.c,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:20  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:38  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:32  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:30  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.2  1992/11/30  17:01:09  mrudula
 * COMMENT : Fixed again to remove microstation library dependancy
 *
 * Revision 201.7  1992/07/13  19:17:18  tim
 * COMMENT : added Log variable
 *
*/

#include "exsysdep.h"
#include  "flib_common.h"
#include "struct.h"
#include  <stdio.h>
#include "defnames.h"
FILE      *Flib_cb,*fopen();        /* font library file control block */

/********************************************************************\

 *  NAME:    list_flib - creates a brief listing of the font library

    bool list_flib ()

 *  DESCRIPTION:

    This routine creates a brief listing of the font library.  It
    list the header information and lists the brief information.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

        0 - error in listing font or I/O error
        1 - font listed successfully

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

        M. Futch    DATE:    NOV-1985

            Changed the call to OPENLIB to be more generic by
            allowing an additional argument - file control block
            (Flib_cb).

\********************************************************************/

int list_flib ()

{
void    list_brief();
/* extern fontdata  Fntdat;        * general info for font processing */
extern  bool  lis_br;
extern  char  flib_nm[256];
/*
bool    read_only = TRUE;    
*/
int     status = FALSE;

  Flib_cb=fopen(flib_nm,"r");
  if  (!status) 
  {
    status = list_header();
    if (!status)
    {
      list_brief ();
    }
    status = fclose ( Flib_cb );
  }

  return (status);
}

int list_header()

{
extern library_header     *Lh_o_ptr;
extern  char  flib_nm[256];
#ifdef BIG_ENDIAN
library_header    	  x_Lh_o_ptr;
library_header        	  *XLh_o_ptr;
#endif
/*extern long             Flib_cb;     font library file control block */

void    get_month();

/*char     exp_nam[256];        */   /* expanded font library name */
char    month[4];                /* month of cre/mod date */

short     blk_lh = 1;            /* initial virtual block number */
/*short     flib_buf[512];             buffer to hold font library */
buf_union       buffer;
/*
short    time[7];
*/

int    status2 = FALSE;

#ifdef BIG_ENDIAN
  XLh_o_ptr = &x_Lh_o_ptr;
#endif

  status2 = readblk (Flib_cb, blk_lh, BUF_512, buffer.flib_buf );
  if ( ISSUCCESS(status2) )
  {
    align_lh(&buffer.flib_buf[0]);

/*    printf ( "\nListing of FONT library %s", exp_nam ); dmb:2/27/90 */
    printf ( "\nListing of FONT library %s\n", flib_nm ); /* dmb */

#ifdef BIG_ENDIAN
    XLh_o_ptr->form_ver_num = Lh_o_ptr->form_ver_num;
    Xconv_int(&XLh_o_ptr->form_ver_num);
    printf ( "Format  V%04d\n", XLh_o_ptr->form_ver_num );
#else
    printf ( "Format  V%04d\n", Lh_o_ptr -> form_ver_num );
#endif
    printf ( "Font Librarian  V%d.%d.%d-%d\n", 
                Lh_o_ptr -> libr_ver_num.user,
                Lh_o_ptr -> libr_ver_num.nfnt,
                Lh_o_ptr -> libr_ver_num.chng,
                Lh_o_ptr -> libr_ver_num.fix );


    month[0]='\0';
    get_month ( Lh_o_ptr -> cre_date.month, month );


#ifdef BIG_ENDIAN
    XLh_o_ptr->cre_date.year = Lh_o_ptr->cre_date.year;
    Xconv_short(&XLh_o_ptr->cre_date.year);
    printf ( "Creation Date:  %02d-%3s-%4d",Lh_o_ptr -> cre_date.day,
                month, XLh_o_ptr->cre_date.year );
#else
    printf ( "Creation Date:  %02d-%3s-%4d",Lh_o_ptr -> cre_date.day,
                month, Lh_o_ptr -> cre_date.year );
#endif
    printf ( " %02d:%02d:%02d\n", Lh_o_ptr -> cre_time.hour,
           Lh_o_ptr -> cre_time.min, Lh_o_ptr -> cre_time.sec );

    get_month ( Lh_o_ptr -> mod_date.month, month );

#ifdef BIG_ENDIAN
    XLh_o_ptr->mod_date.year = Lh_o_ptr->mod_date.year;
    Xconv_short(&XLh_o_ptr->mod_date.year);
    printf ( "Revision Date:  %02d-%3s-%4d",Lh_o_ptr -> 
            mod_date.day, month, XLh_o_ptr->mod_date.year );
#else
    printf ( "Revision Date:  %02d-%3s-%4d",Lh_o_ptr -> 
            mod_date.day, month, Lh_o_ptr -> mod_date.year );
#endif
    printf ( " %02d:%02d:%02d\n", Lh_o_ptr -> mod_time.hour,
           Lh_o_ptr -> mod_time.min, Lh_o_ptr -> mod_time.sec );

#ifdef BIG_ENDIAN
    XLh_o_ptr->rec_len = Lh_o_ptr->rec_len;
    Xconv_int(&XLh_o_ptr->rec_len);
    printf ( "Recoverable Deleted Blocks:  %-d\n",
              XLh_o_ptr->rec_len / 256 );
#else 
    printf ( "Recoverable Deleted Blocks:  %-d\n",
              Lh_o_ptr -> rec_len / 256 );
#endif

#ifdef BIG_ENDIAN
    XLh_o_ptr->char_fst_fnt = Lh_o_ptr->char_fst_fnt;
    Xconv_short(&XLh_o_ptr->char_fst_fnt);

    XLh_o_ptr->sym_fst_fnt = Lh_o_ptr->sym_fst_fnt;
    Xconv_short(&XLh_o_ptr->sym_fst_fnt);

    XLh_o_ptr->pat_fst_fnt = Lh_o_ptr->pat_fst_fnt;
    Xconv_short(&XLh_o_ptr->pat_fst_fnt);

    if ( XLh_o_ptr->form_ver_num == 0 )
    {
      if ( XLh_o_ptr->sym_fst_fnt != -1 )
      {
        printf ( "Fast Fonts:  Character - %-3d   Symbol - %-3d\n",
                XLh_o_ptr->char_fst_fnt, XLh_o_ptr->sym_fst_fnt );
      }
      else
      {
        printf ( "Fast Fonts:  Character - %-3d;   Symbol - None;\n",
                XLh_o_ptr->char_fst_fnt );
      }
    }
    else if ( XLh_o_ptr->form_ver_num >= 1 )
    {
      if ( XLh_o_ptr->sym_fst_fnt != -1 )
      {  
        if ( XLh_o_ptr->pat_fst_fnt != -1 )
        {
      printf("Fast Fonts:  Character - %-3d   Symbol - %-3d   Pattern - %-3d\n",
                XLh_o_ptr->char_fst_fnt, XLh_o_ptr->sym_fst_fnt,
                XLh_o_ptr->pat_fst_fnt);
        }
        else
        {
      printf("Fast Fonts:  Character - %-3d   Symbol - %-3d   Pattern - None\n",
              	XLh_o_ptr->char_fst_fnt, XLh_o_ptr->sym_fst_fnt);
        }
      }
      else if ( XLh_o_ptr->pat_fst_fnt != -1 )
      { 
      printf("Fast Fonts:  Character - %-3d   Symbol - None   Pattern - %-3d\n",
                XLh_o_ptr->char_fst_fnt, XLh_o_ptr->pat_fst_fnt);
      }
      else
      {
      printf("Fast Fonts:  Character - %-3d   Symbol - None   Pattern - None\n",
                XLh_o_ptr->char_fst_fnt);
      }
    }
#else
    if ( Lh_o_ptr -> form_ver_num == 0 )
    {
      if ( Lh_o_ptr -> sym_fst_fnt != -1 )
      {
        printf ( "Fast Fonts:  Character - %-3d   Symbol - %-3d\n",
                Lh_o_ptr -> char_fst_fnt, Lh_o_ptr -> sym_fst_fnt );
      }
      else
      {
        printf ( "Fast Fonts:  Character - %-3d;   Symbol - None;\n",
                Lh_o_ptr -> char_fst_fnt );
      }
    }
    else if ( Lh_o_ptr -> form_ver_num >= 1 )
    {
      if ( Lh_o_ptr -> sym_fst_fnt != -1 )
      {  
        if ( Lh_o_ptr -> pat_fst_fnt != -1 )
        {
          printf ( "Fast Fonts:  Character - %-3d   Symbol - %-3d   Pattern - %-3d\n",
                Lh_o_ptr -> char_fst_fnt, Lh_o_ptr -> sym_fst_fnt,
                Lh_o_ptr -> pat_fst_fnt );
        }
        else
        {
          printf ( "Fast Fonts:  Character - %-3d   Symbol - %-3d   Pattern - None\n",
            Lh_o_ptr -> char_fst_fnt, Lh_o_ptr -> sym_fst_fnt );
        }
      }
      else if ( Lh_o_ptr -> pat_fst_fnt != -1 )
      { 
        printf ( "Fast Fonts:  Character - %-3d   Symbol - None   Pattern - %-3d\n",
                Lh_o_ptr -> char_fst_fnt, Lh_o_ptr -> pat_fst_fnt );
      }
      else
      {
         printf ( "Fast Fonts:  Character - %-3d   Symbol - None   Pattern - None\n",
                Lh_o_ptr -> char_fst_fnt );
      }

    }
#endif
  }
  printf("\n\n");
  return (status2);
}

/********************************************************************\

 *  NAME:    get_month - returns the alphabetic abbreviation for
                    the month received

 *  SYNOPSIS:

        void get_month ( month_in, month_out )

        short    month_in;        Decimal value of the month.
        char    month_out[4];        Alphabetic value of the month.

 *  DESCRIPTION:

    This routine accepts the numeric code (0-12) for a month and
        returns the appropriate alphabetic abbreviation for the month.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

\********************************************************************/
void get_month ( month_in, month_out )

short    month_in;
char    month_out[4];

{
typedef char *monthly;


static char   *mth[] ={"JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC"};
/*  
static monthly   mth[12] ={{"JAN\0"},
    {"FEB\0"},
    {"MAR\0"},
    {"APR\0"},
    {"MAY\0"},
    {"JUN\0"},
    {"JUL\0"},
    {"AUG\0"},
    {"SEP\0"},
    {"OCT\0"},
    {"NOV\0"},
    {"DEC\0"}};
*/     

    /* Added range check. dmb:2/20/90 */
    if ( month_in >=0  && month_in <= 11 )
    {
        strcpy ( month_out, mth[month_in]);

/*    if ( month_in >= 1 && month_in <= 12 ) */
/*        strcpy ( month_out, mth[month_in-1]); */

    }
    else
    {
        printf ( "\nWARNING: In get_month: month is out of range.\n" );
        strcpy ( month_out, "???" );
    }

}

/********************************************************************\

 *  NAME:    list_brief - creates a listing of the brief information
                 for each font in the font library

 *  SYNOPSIS:

        void list_brief ()

 *  DESCRIPTION:

    This routine creates a listing of brief information for
    each font in the font library.  It steps through the font
    library and lists the brief information for each font.  The
    entire brief listing will contain the header information and
    the brief information for each font in the font library.  If
    the /FULL qualifier was set, it calls the LIST_FULL routine
    for the full information for each font.  The following
    information is contained in the brief information:

            font number
            font classification (character, symbol, pattern, etc...)
            font name

        If the classification is character, then nothing is listed
        for the font's classification.  If there is no name associated
        with the font number, no name is listed for the font.

 *  GLOBAL DATA BEING CHANGED:

        struct    *Lh_o_ptr

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

    list_header (), list_full ()

 *  MODIFICATIONS:

        M. Futch    DATE:    NOV-1985

            Changed the call to READ_FOTs, READ_FH, and READBLK
            to be more generic by adding additional arguments -
            file control block and input/output buffer (Flib_cb &
            flib_buf).

\********************************************************************/
void list_brief ()

{
/* extern fontdata        Fntdat;     * general info for font processing */
extern library_header     *Lh_o_ptr;
extern font_header        *Fh_o_ptr;

#ifdef BIG_ENDIAN
       library_header     x_Lh_o_ptr;
       library_header     *XLh_o_ptr;
       font_header        x_Fh_o_ptr;
       font_header        *XFh_o_ptr;
#endif

/*extern long             Flib_cb;     font library file control block */

name_record        name_tbl[200];    /* table of all font names */
char    name_font[40];               /* current font name */
short    blk_lh = 1;                 /* block # at library header */
/*short    flib_buf[2048];                 buffer to hold font library */
buf_union buffer;
short   font_num;                    /* current font number */
short   ft_first;                    /* first font # in node */
short   ft_last;                     /* last font # in node */
short   num_names;                   /* # of fonts in name table */
short    ver_num;                    /* format version number */

long    blk_fh;                   /* block # at beg of font header */
long    blk_fot;                  /* block # at beg of font offset table */
long    byt_fh;                   /* byte # at beg of font header */
long    byt_fot;                  /* byte # at beg of font offset table) */
long    fnt_off_tbl[127];         /* offsets to fonts in this node */
long     next_fot;                /* offset to next font offset table */
long    tot_char = 0;             /* total # of character fonts present */
long     tot_sym = 0;             /* total # of symbol fonts present */
long    tot_pat = 0;              /* total # of pattern fonts present */

bool    end_flib = FALSE;         /* indicates end of font library */
bool    fnd_nm_tbl;               /* indicates name table present */
bool    fnd_name = FALSE;         /* indicates font name was present in name table */
bool    status = TRUE;
extern  bool  lis_br;

#ifdef BIG_ENDIAN
       XLh_o_ptr = &x_Lh_o_ptr;
       XFh_o_ptr = &x_Fh_o_ptr;
#endif
  status = readblk ( Flib_cb, blk_lh, BUF_512, buffer.flib_buf );

  if ( ISSUCCESS(status) )
  {
    align_lh(&buffer.flib_buf[0]);

    blk_fot = 1;
    byt_fot = 1;
#ifdef BIG_ENDIAN
    XLh_o_ptr->fot_ptr = Lh_o_ptr->fot_ptr;
    Xconv_int(&XLh_o_ptr->fot_ptr);
    next_fot = XLh_o_ptr->fot_ptr;
    
    XLh_o_ptr->form_ver_num = Lh_o_ptr->form_ver_num;
    Xconv_int(&XLh_o_ptr->form_ver_num);
    ver_num = XLh_o_ptr->form_ver_num;

    XLh_o_ptr->fnt_ptr = Lh_o_ptr->fnt_ptr;
    Xconv_int(&XLh_o_ptr->fnt_ptr);

    if ( XLh_o_ptr->fnt_ptr != 0 )
#else
    next_fot = Lh_o_ptr -> fot_ptr;
    ver_num = Lh_o_ptr -> form_ver_num;

    if ( Lh_o_ptr -> fnt_ptr != 0 )
#endif
    {
      status = init_name_tbl ( name_tbl, &num_names );
      if ( ISSUCCESS(status) )
      {
        fnd_nm_tbl = TRUE;
      }
      else
      {
        fnd_nm_tbl = FALSE;
      }
    }
    else
    {
      fnd_nm_tbl = FALSE;
    }
    if ( ISSUCCESS(status) )
    {
      status = read_fot ( Flib_cb, &ft_first, &ft_last, &blk_fot,
                &byt_fot, fnt_off_tbl, &next_fot, buffer.flib_buf );

      if ( ISSUCCESS(status) )
      {
        while ( !(end_flib)  &&  ISSUCCESS(status) )
        {
          if ( next_fot == 0 )
          {
            end_flib = TRUE;
          }
          for ( font_num = ft_first;  font_num <= ft_last; font_num++ )
          {

            if ( ISSUCCESS(status) )
            {
              if ( fnt_off_tbl[font_num - ft_first] != 0 )
              {
                status = read_fh ( Flib_cb, ft_first,
                           font_num, &blk_fh,
                           &byt_fh,blk_fot, byt_fot,
                           fnt_off_tbl, buffer.flib_buf );

                if ( ISSUCCESS(status) )
                {
                  if ( ISTRUE(fnd_nm_tbl) )
                  {
                    fnd_name = get_name ( font_num,
                                      num_names,
                                      name_tbl,
                                      name_font );
                  }
                  else
                  {
                    fnd_name = FALSE;
                  }
#ifdef BIG_ENDIAN
		  XFh_o_ptr->font_class	= Fh_o_ptr->font_class;
		  Xconv_short(&XFh_o_ptr->font_class);

                  if ( XFh_o_ptr->font_class == 1 )
#else
                  if ( Fh_o_ptr -> font_class == 1 )
#endif
                  {
                    if ( ISTRUE(fnd_name) )
                    {
                        printf ( "  %3d  %s  %-40s\n",
                              font_num, "SYMB",
                              name_font );
                    }
                    else
                    {
                      printf ( "  %3d  %s\n", font_num, "SYMB" );
                    }
                    tot_sym++;
                  }
#ifdef BIG_ENDIAN
                  else if ( XFh_o_ptr->font_class == 2 )
#else
                  else if ( Fh_o_ptr -> font_class == 2 )
#endif
                  {
                    if ( ISTRUE(fnd_name) )
                    {
                      printf ( "  %3d  %s   %-40s\n",
                              font_num, "PAT",
                              name_font );
                    }
                    else
                    {
                      printf ( "  %3d  %s\n", font_num, "PAT" );
                    }
                    tot_pat++;
                  }
                  else
                  {
                    if ( ISTRUE(fnd_name) )
                    {
                        printf ( "  %3d        %-40s\n",
                              font_num, name_font );
                    }
                    else
                    {                        
                        printf ( "  %3d\n",font_num );
                    }
                    tot_char++;
                  }

                  if ( ISFALSE(lis_br) )
                  {
                    status = list_full ( blk_fh, byt_fh );
                    printf ( "\n" );
                  }
                }
              }
            }
          }
          if ( ISSUCCESS(status) )
          {
            status = read_fot ( Flib_cb, &ft_first, &ft_last,
                        &blk_fot, &byt_fot, fnt_off_tbl,
                        &next_fot, buffer.flib_buf );
          }
        }

        if ( ISSUCCESS(status) )
        {
          printf ( "\nTotal Character Fonts:  %-3d\n", tot_char );
          printf ( "Total Symbol Fonts:  %-3d\n", tot_sym );
          if ( ver_num >= 1 )
          {
            printf ( "Total Pattern Fonts:  %-3d\n\n", tot_pat );
          }
        }
      }
    }
  }
}

/********************************************************************\

 *  NAME:    list_full - creates a listing of the full information
                for each font in the font library

 *  SYNOPSIS:

        bool list_full ( blk_fh, byt_fh )

        long    blk_fh;            Block number at beg of font header.
        long    byt_fh;            Byte number at beg of font header.

 *  DESCRIPTION:

    This routine creates a listing of the full information for
    each font in the font library.  The list is an addition to 
    the brief listing.  The entire full listing will contain the
    header information and the brief and full information for each
    font in the font library.  The following information is contained
    in the full listing:

            font description
            character vector size (byte or word)
            character origin
            character scale
            character tile height
            character code information (beginning, end, and total)
            number of bytes in character definitions
            double width 
            list of character codes present

        If there is no description present for the font, then nothing
        is listed for the font's description.  If the /double width
        qualifier is not in affect, then this key word is not listed.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

        RMS status

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

        list_header (), list_brief ()

 *  MODIFICATIONS:

        M. Futch    DATE:    NOV-1985

            Changed the call to READ_CDT to be more generic by
            adding additional arguments - file control block
            and input/output buffer (Flib_cb & flib_buf).

\********************************************************************/
bool list_full ( blk_fh, byt_fh )

long    blk_fh;                /* block # at beg of font header */
long    byt_fh;                /* byte # at beg of font header */

{
extern font_header    *Fh_o_ptr;
extern char_code_off_tbl    *Ccot_o_ptr;

#ifdef BIG_ENDIAN
       font_header        x_Fh_o_ptr;
       font_header        *XFh_o_ptr;
       char_code_off_tbl  x_Ccot_o_ptr;
       char_code_off_tbl  *XCcot_o_ptr;
#endif

extern char_dim_table    *Cdt_o_ptr;
/*extern long            Flib_cb;*/

void     print_alphanum();
void     print_other();
void     print_puntc();
void     put_alphanum();
void     put_other();
void     put_puntc();

short    alphanum_tbl[31][2];      /* beg and end char for alphanumerics */
short     chr_fst;                 /* current first character # */
/*short    count;*/                    /* current position on screen */
/*short    flib_buf[4096];             buffer to hold font library */
buf_union buffer;
short    fnt_type;                 /* font type - BYTE=1; WORD=2; */
short    num_alphanum = 0;         /* # of entries in ALPHANUM_TBL */
short    num_dim;                  /* # of dimensions present */
short    num_other = 0;            /* # of entries in OTHER_TBL */
short    num_puntc = 0;            /* # of entries in PUNTC_TBL */
short    offset;                   /* current offset within CH_HDR_PTR */
short    other_tbl[80][2];         /* beg and end char for others */
short    puntc_tbl[17][2];         /* beg and end char for puntcuations */

long    blk_cdt;          /* block # at beg of char dimension table */
long    byt_cdt;          /* byte # at beg of char dimension table */
long    next_cdt;         /* offset to next char dimension table table */
long    next_ccot;        /* offset to next char code offset table table */

bool    new_alphanum = TRUE;     /* indicates new font for ALPHANUM_TBL */
bool    new_other = TRUE;        /* indicates new font for OTHER_TBL */
bool    new_puntc = TRUE;        /* indicates new font for PUNTC_TBL */
bool    end_cdts = FALSE;        /* indicates end of char dimension tables for this font */
bool    status = TRUE;
bool    other_font = FALSE;      /* indicates symbol or pattern font (other than character) is present */

#ifdef BIG_ENDIAN
  XFh_o_ptr   = &x_Fh_o_ptr;
  XCcot_o_ptr = &x_Ccot_o_ptr;
#endif

  if ( Fh_o_ptr -> font_descrip[0] != '\0' )
  {
    printf ( "               Description: %s\n",
            Fh_o_ptr -> font_descrip );
  }
#ifdef BIG_ENDIAN
  XFh_o_ptr->vect_wrd_size = Fh_o_ptr->vect_wrd_size;
  Xconv_short(&XFh_o_ptr->vect_wrd_size);

  if ( XFh_o_ptr->vect_wrd_size == 1 )
#else
  if ( Fh_o_ptr -> vect_wrd_size == 1 )
#endif
  {
    printf ( "               Vector Size: Byte\n" );
  }
  else
  {
    printf ( "               Vector Size: Word\n" );
  }

  convert_double(1, Fh_o_ptr->x_scale, &Fh_o_ptr->x_scale);  /* dmb: was , */
  convert_double(1, Fh_o_ptr->y_scale, &Fh_o_ptr->y_scale);

#ifdef BIG_ENDIAN
  XFh_o_ptr->x_scale = Fh_o_ptr->x_scale;
  Xconv_double(&XFh_o_ptr->x_scale);

  XFh_o_ptr->y_scale = Fh_o_ptr->y_scale;
  Xconv_double(&XFh_o_ptr->y_scale);

  XFh_o_ptr->x_origin = Fh_o_ptr->x_origin;
  Xconv_int(&XFh_o_ptr->x_origin);

  XFh_o_ptr->y_origin = Fh_o_ptr->y_origin;
  Xconv_int(&XFh_o_ptr->y_origin);

  printf ( "               Origin: ( %d, %d );   Scale: ( %f, %f );\n",
                XFh_o_ptr->x_origin, XFh_o_ptr->y_origin,
                Fh_o_ptr->x_scale,
                Fh_o_ptr->y_scale);
#else
  printf ( "               Origin: ( %d, %d );   Scale: ( %f, %f );\n",
                Fh_o_ptr -> x_origin, Fh_o_ptr -> y_origin,
                Fh_o_ptr->x_scale,
                Fh_o_ptr->y_scale);
#endif

#ifdef BIG_ENDIAN
  XFh_o_ptr->font_class = Fh_o_ptr->font_class;
  Xconv_short(&XFh_o_ptr->font_class);

  XFh_o_ptr->tile_hgth = Fh_o_ptr->tile_hgth;
  Xconv_int(&XFh_o_ptr->tile_hgth);

  if ( XFh_o_ptr->font_class != 2 )
  {
    printf ( "               Tile Height: %d\n", XFh_o_ptr->tile_hgth );
  }

  XFh_o_ptr->beg_char = Fh_o_ptr->beg_char;
  Xconv_short(&XFh_o_ptr->beg_char);

  XFh_o_ptr->end_char = Fh_o_ptr->end_char;
  Xconv_short(&XFh_o_ptr->end_char);

  XFh_o_ptr->num_of_char = Fh_o_ptr->num_of_char;
  Xconv_short(&XFh_o_ptr->num_of_char);

  XFh_o_ptr->char_def_len = Fh_o_ptr->char_def_len;
  Xconv_int(&XFh_o_ptr->char_def_len);

  XFh_o_ptr->flags = Fh_o_ptr->flags;
  Xconv_int(&XFh_o_ptr->flags);

  printf("               Character Codes: Begin - %d;  End - %d;  Total - %d;\n",
                XFh_o_ptr->beg_char, XFh_o_ptr->end_char,
                XFh_o_ptr->num_of_char );
  printf ( "               Number of Bytes in Char Definitions: %d\n",
                XFh_o_ptr->char_def_len );

  if ( XFh_o_ptr->flags == 1 )
#else
  if ( Fh_o_ptr -> font_class != 2 )
  {
    printf ( "               Tile Height: %d\n", Fh_o_ptr -> tile_hgth );
  }

  printf ( "               Character Codes: Begin - %d;  End - %d;  Total - %d;\n",
                Fh_o_ptr -> beg_char, Fh_o_ptr -> end_char,
                Fh_o_ptr -> num_of_char );
  printf ( "               Number of Bytes in Char Definitions: %d\n",
                Fh_o_ptr -> char_def_len );
  if ( Fh_o_ptr -> flags == 1 )
#endif
  {
    printf ( "               Double Widths\n" );
  }
  printf ( "               Character Codes Present:" );

  blk_cdt = blk_fh;
  byt_cdt = byt_fh;
#ifdef BIG_ENDIAN
  XFh_o_ptr->cdt_ptr = Fh_o_ptr->cdt_ptr;
  Xconv_int(&XFh_o_ptr->cdt_ptr);

  XFh_o_ptr->ccot_ptr = Fh_o_ptr->ccot_ptr;
  Xconv_int(&XFh_o_ptr->ccot_ptr);

  next_cdt  = XFh_o_ptr->cdt_ptr;
  next_ccot = XFh_o_ptr->ccot_ptr;
  fnt_type  = XFh_o_ptr->vect_wrd_size;

  if ( XFh_o_ptr->font_class != 0 )
#else
  next_cdt = Fh_o_ptr -> cdt_ptr;
  next_ccot = Fh_o_ptr -> ccot_ptr;
  fnt_type = Fh_o_ptr -> vect_wrd_size;

  if ( Fh_o_ptr -> font_class != 0 )
#endif
  {
    other_font = TRUE;
  }
  else
  {
    other_font = FALSE;
  }
#ifdef BIG_ENDIAN
  XFh_o_ptr->dim_flag = Fh_o_ptr->dim_flag;
  Xconv_short(&XFh_o_ptr->dim_flag);
  if ( XFh_o_ptr->dim_flag == 32 )
#else
  if ( Fh_o_ptr -> dim_flag == 32 )
#endif
  {
    num_dim = 1;
  }
#ifdef BIG_ENDIAN
  else if ( XFh_o_ptr->dim_flag == 1 )
#else
  else if ( Fh_o_ptr -> dim_flag == 1 )
#endif
  {
    num_dim = 1;
  }
#ifdef BIG_ENDIAN
  else if ( XFh_o_ptr->dim_flag == 5 )
#else
  else if ( Fh_o_ptr -> dim_flag == 5 )
#endif
  {
    num_dim = 2;
  }
  else        /* dim_flag = 31 */
  {
    num_dim = 5;
  }

  status = read_cdt ( Flib_cb, &blk_cdt, &byt_cdt, &next_cdt, &next_ccot,
            fnt_type, num_dim, buffer.flib_buf );

  if ( ISSUCCESS(status) )
  {
    while ( ISFALSE(end_cdts)  &&  ISSUCCESS(status) )
    {
#ifdef BIG_ENDIAN
      XCcot_o_ptr->first_char = Ccot_o_ptr->first_char;
      Xconv_short(&XCcot_o_ptr->first_char);
      chr_fst = XCcot_o_ptr->first_char;
#else
      chr_fst = Ccot_o_ptr -> first_char;
#endif
      if ( next_cdt == 0 )
      {
        end_cdts = TRUE;
      }
#ifdef BIG_ENDIAN
      XCcot_o_ptr->last_char = Ccot_o_ptr->last_char;
      Xconv_short(&XCcot_o_ptr->last_char);
      for ( offset = 0;  offset <= XCcot_o_ptr->last_char - chr_fst;
          offset++ )
#else
      for ( offset = 0;  offset <= Ccot_o_ptr -> last_char - chr_fst;
          offset++ )
#endif
      {
#ifdef BIG_ENDIAN
        XCcot_o_ptr->ch_hdr_ptr[offset] = Ccot_o_ptr->ch_hdr_ptr[offset];
        Xconv_short(&XCcot_o_ptr->ch_hdr_ptr[offset]);
        if ( XCcot_o_ptr->ch_hdr_ptr[offset] != 0 )
#else
        if ( Ccot_o_ptr -> ch_hdr_ptr[offset] != 0 )
#endif
        {
          if ( ISTRUE(other_font) )
          {
            put_other ( other_tbl, &num_other, &new_other,
                        chr_fst + offset );
          }
          else
          {
            if ( chr_fst + offset >= 0  &&  chr_fst + offset <= 31 )
            {
              put_other ( other_tbl, &num_other, &new_other,
                    chr_fst + offset );
            }
            if ( chr_fst + offset >= 32  &&  chr_fst + offset <= 47 )
            {
              put_puntc ( puntc_tbl, &num_puntc, &new_puntc,
                    chr_fst + offset );
            }
            if ( chr_fst + offset >= 48  &&  chr_fst + offset <= 57 )
            {
              put_alphanum ( alphanum_tbl, &num_alphanum,
                    &new_alphanum, chr_fst + offset );
            }
            if ( chr_fst + offset >= 58  &&  chr_fst + offset <= 64 )
            {
              put_puntc ( puntc_tbl, &num_puntc, &new_puntc,
                    chr_fst + offset );
            }
            if ( chr_fst + offset >= 65  &&  chr_fst + offset <= 90 )
            {
              put_alphanum ( alphanum_tbl, &num_alphanum,
                    &new_alphanum, chr_fst + offset );
            }
            if ( chr_fst + offset >= 91  &&  chr_fst + offset <= 96 )
            {
              put_puntc ( puntc_tbl, &num_puntc, &new_puntc,
                    chr_fst + offset );
            }
            if ( chr_fst + offset >= 97  &&  chr_fst + offset <= 122 )
            {
              put_alphanum ( alphanum_tbl, &num_alphanum,
                    &new_alphanum, chr_fst + offset );
            }
            if ( chr_fst + offset >= 123  &&  chr_fst + offset <= 126 )
            {
              put_puntc ( puntc_tbl, &num_puntc, &new_puntc,
                    chr_fst + offset );
            }
            if ( chr_fst + offset >= 127  &&  chr_fst + offset <= 199 )
            {
              put_other ( other_tbl, &num_other, &new_other,
                    chr_fst + offset );
            }
            if ( chr_fst + offset == 200 )
            {
              put_puntc ( puntc_tbl, &num_puntc, &new_puntc,
                    chr_fst + offset );
            }
            if ( chr_fst + offset >= 201 )
            {
              put_other ( other_tbl, &num_other, &new_other,
                    chr_fst + offset );
            }
          }
        }
      }
      if ( next_cdt != 0 )
      {
        status = read_cdt ( Flib_cb, &blk_cdt, &byt_cdt, &next_cdt,
                    &next_ccot, fnt_type, num_dim, buffer.flib_buf );
      }
    }
  }

  if ( ISSUCCESS(status) )
  {
    if ( ISTRUE(other_font) )
    {
      print_other ( other_tbl, num_other );
    }
    else
    {
      if ( num_alphanum >= 1 )
      {
        print_alphanum ( alphanum_tbl, num_alphanum );
      }
      if ( num_puntc >= 1 )
      {
        print_puntc ( puntc_tbl, num_puntc );
      }
      if ( num_other >= 1 )
      {
        print_other ( other_tbl, num_other );
      }
    }
  }
  return (status);
}


/********************************************************************\

 *  NAME:    put_alphanum - creates a table which contains the
                   beginning and ending character codes
                   for the alphanumerics in the font

 *  SYNOPSIS:

        void put_alphanum ( alphanum_tbl, num_alphanum, new_alphanum,
                    chr_code )

        short    alphanum_tbl[][2];    Beginning and ending characters
                        for the alphanumerics.
        short    *num_alphanum;        Number of entries in ALPHANUM_TBL.
        bool    *new_alphanum;        Indicates new font for ALPHANUM_TBL.
        short     chr_code;        Current character number.

 *  DESCRIPTION:

    This routine creates a table which contains the beginning and
    ending character codes for the alphanumerics (0-9, A-Z, a-z)
    in the font.  Each set of beginning and ending character codes
    represent all of the character codes contained within that
    sequence.  A new set of character codes is generated when there
    is a break in the character codes.  Because there are character 
    codes in between the numeric values and the capital letters and
    in between the capital letters and little letters, there will
    always be separate beginning and ending character codes for each
    of those groups.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

    print_alphanum ()

 *  MODIFICATIONS:

\********************************************************************/
void put_alphanum ( alphanum_tbl, num_alphanum, new_alphanum, chr_code )

short    alphanum_tbl[][2];        /* beg and end chars for the alphanumerics */
short    *num_alphanum;            /* # of entries in ALPHANUM_TBL */
bool    *new_alphanum;            /* indicates new font for ALPHANUM_TBL */
short     chr_code;            /* current character # */

{
static short    chr_end;        /* current ending character # */
static short    index;            /* index into ALPHANUM_TBL */

    if ( ISTRUE(*new_alphanum) )
        {
        chr_end = chr_code;
        index = 0;
    alphanum_tbl[index][0] = chr_code;
    alphanum_tbl[index][1] = chr_code;
    (*num_alphanum)++;
        *new_alphanum = FALSE;
        }
    else if ( chr_code == chr_end + 1 )
    {
        chr_end = chr_code;
    alphanum_tbl[index][1] = chr_end;
        }
    else
        {
        (*num_alphanum)++;
        index++;
        chr_end = chr_code;
        alphanum_tbl[index][0] = chr_code;
        alphanum_tbl[index][1] = chr_code;
        }
}

/********************************************************************\

 *  NAME:    put_other - creates a table which contains the
                beginning and ending character codes
                for the others in the font


 *  SYNOPSIS:

        void put_other ( other_tbl, num_other, new_other, chr_code )

        short    other_tbl[][2];        Beginning and ending characters
                        for the others.
        short    *num_other;        Number of entries in OTHER_TBL.
        bool    *new_other;        Indicates new font for OTHER_TBL.
        short     chr_code;        Current character number.

 *  DESCRIPTION:

    This routine creates a table which contains the beginning and
    ending character codes for the others in the font.  The others
    are all of the character codes except for the numerics, alphas,
    and puntcuations (DEC0 - DEC31, DEC127 - DEC199, DEC201 - DEC255).
    Each set of beginning and ending character codes represent all
    of the character codes contained within that sequence.  A new
    set of character codes is generated when there is a break in
    the character codes.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

    print_other ()

 *  MODIFICATIONS:

\********************************************************************/
void put_other ( other_tbl, num_other, new_other, chr_code )

short    other_tbl[][2];            /* beg and end chars for the others */
short    *num_other;            /* # of entries in OTHER_TBL */
bool    *new_other;            /* indicates new font for OTHER_TBL */
short     chr_code;            /* current character # */

{
static short    chr_end;        /* current ending character # */
static short    index;            /* index into OTHER_TBL */

    if ( ISTRUE(*new_other) )
        {
        chr_end = chr_code;
        index = 0;
    other_tbl[index][0] = chr_code;
    other_tbl[index][1] = chr_code;
    (*num_other)++;
        *new_other = FALSE;
        }
    else if ( chr_code == chr_end + 1 )
    {
        chr_end = chr_code;
    other_tbl[index][1] = chr_end;
        }
    else
        {
        (*num_other)++;
        index++;
        chr_end = chr_code;
        other_tbl[index][0] = chr_code;
        other_tbl[index][1] = chr_code;
        }
}

/********************************************************************\

 *  NAME:    put_puntc - creates a table which contains the
                beginning and ending character codes
                for the puntcuations in the font


 *  SYNOPSIS:

        void put_puntc ( puntc_tbl, num_puntc, new_puntc, chr_code )

        short    puntc_tbl[][2];        Beginning and ending characters
                        for the puntcuations.
        short    *num_puntc;        Number of entries in PUNTC_TBL.
        bool    *new_puntc;        Indicates new font for PUNTC_TBL.
        short     chr_code;        Current character number.

 *  DESCRIPTION:

    This routine creates a table which contains the beginning and
    ending character codes for the puntcuations in the font.  The
    punctuations all have special names (see also print_puntc) that
    are used for easy recognition (DEC32 - DEC47, DEC58 - DEC64,
    DEC91 - DEC96, DEC123 - DEC126, DEC200).  Each set of beginning
    and ending character codes represent all of the character codes
    contained within that sequence.  A new set of character codes
    is generated when there is a break in the character codes.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

    print_puntc ()

 *  MODIFICATIONS:

\********************************************************************/
void put_puntc ( puntc_tbl, num_puntc, new_puntc, chr_code )

short    puntc_tbl[][2];            /* beg and end chars for the puntcuations */
short    *num_puntc;            /* # of entries in PUNTC_TBL */
bool    *new_puntc;            /* indicates new font for PUNTC_TBL */
short     chr_code;            /* current character # */

{
static short    chr_end;        /* current ending character # */
static short    index;            /* index into PUNTC_TBL */

    if ( ISTRUE(*new_puntc) )
        {
        chr_end = chr_code;
        index = 0;
    puntc_tbl[index][0] = chr_code;
    puntc_tbl[index][1] = chr_code;
    (*num_puntc)++;
        *new_puntc = FALSE;
        }
    else if ( chr_code == chr_end + 1 )
    {
        chr_end = chr_code;
    puntc_tbl[index][1] = chr_end;
        }
    else
        {
        (*num_puntc)++;
        index++;
        chr_end = chr_code;
        puntc_tbl[index][0] = chr_code;
        puntc_tbl[index][1] = chr_code;
        }
}

/********************************************************************\

 *  NAME:    print_alphanum - lists all of the alphanumerics present
                    in the font

 *  SYNOPSIS:

        void print_alphanum ( alphanum_tbl, num_alphanum )

        short    alphanum_tbl[26][2];    Beginning and ending characters
                        for the alphanumerics.
        short    num_alphanum;        Number of entries in ALPHANUM_TBL.

 *  DESCRIPTION:

    This routine lists all of the alphanumerics present in the
    font.  The beginning and ending character codes are listed
    for each entry in the ALPHANUM_TBL.  The little letters are
    listed as a dot and the equivalent capital letter (.A for a)
    since this is the legal name for the cell.  If there are any
    alphanumerics present, they will always appear first in the
    listing of character codes present (see also list_full).

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

    list_full (), put_alphanum ()

 *  MODIFICATIONS:

\********************************************************************/
void print_alphanum ( alphanum_tbl, num_alphanum )

short    alphanum_tbl[26][2];        /* beg and end chars for the alphanumerics */
short    num_alphanum;            /* # of entries in ALPHANUM_TBL */

{
short    chr_pos;            /* current char position on print line */
short     i;

    printf ( "\n                    " );
    chr_pos = 21;

    for ( i = 0;  i < num_alphanum;  i++ )
        {
        if ( chr_pos > 72 )
            {
            printf ( "\n                    " );
            chr_pos = 21;
            }

        if ( i == 0 )
            if ( alphanum_tbl[i][0] != alphanum_tbl[i][1] )
        if ( alphanum_tbl[i][0] >= 97  &&  alphanum_tbl[i][0] <= 122 )
            {
                printf ( ".%c - .%c", alphanum_tbl[i][0] - 32,
                          alphanum_tbl[i][1] - 32 );
                chr_pos += 7;
            }
        else
            {
                 printf ( "%c - %c", alphanum_tbl[i][0],alphanum_tbl[i][1] );
                chr_pos += 5;
                }
            else
        if ( alphanum_tbl[i][0] >= 97  &&  alphanum_tbl[i][0] <= 122 )
                {
                printf ( ".%c", alphanum_tbl[i][0] - 32 );
                chr_pos += 2;
                }
        else
                {
                printf ( "%c", alphanum_tbl[i][0] );
                chr_pos += 1;
                }
        else
            if ( alphanum_tbl[i][0] != alphanum_tbl[i][1] )
        if ( alphanum_tbl[i][0] >= 97  &&  alphanum_tbl[i][0] <= 122 )
                {
                printf ( ", .%c - .%c", alphanum_tbl[i][0] - 32,
                                    alphanum_tbl[i][1] - 32 );
                chr_pos += 9;
                }
        else
                {
                printf ( ", %c - %c", alphanum_tbl[i][0],
                                  alphanum_tbl[i][1] );
                chr_pos += 7;
                }
            else
        if ( alphanum_tbl[i][0] >= 97  &&  alphanum_tbl[i][0] <= 122 )
            {
            printf ( ", .%c", alphanum_tbl[i][0] - 32 );
            chr_pos += 4;
            }
        else
            {
            printf ( ", %c", alphanum_tbl[i][0] );
            chr_pos += 3;
            }
    }
}

/********************************************************************\

 *  NAME:    print_other - lists all of the others present in the
                  font

 *  SYNOPSIS:

        void print_other ( other_tbl, num_other )

        short    other_tbl[80][2];    Beginning and ending characters
                    for the others.
        short    num_other;        Number of entries in OTHER_TBL.

 *  DESCRIPTION:

    This routine lists all of the others present in the font.
    The beginning and ending character codes are listed for each
    entry in the OTHER_TBL.  The others are listed as DEC and the
    character code (DEC129 would be equivalent to octal 201, decimal
    129, and .1$2).  If there are any others present, they
    will always appear last in the listing of character codes
    present (see also list_full).

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

    list_full (), put_other ()

 *  MODIFICATIONS:

\********************************************************************/
void print_other ( other_tbl, num_other )

short    other_tbl[80][2];        /* beg and end chars for the others */
short    num_other;            /* # of entries in OTHER_TBL */

{
short    chr_pos;            /* current char position on print line */
short     i;

    printf ( "\n                    " );
    chr_pos = 21;
    for ( i = 0;  i < num_other;  i++ )
        {
        if ( other_tbl[i][0] != other_tbl[i][1] )
            {
        if ( (chr_pos + 17) > 75 )
        {
        printf ( "\n                    " );
        chr_pos = 21;
        }
            }
        else
            {
        if ( (chr_pos + 8) > 75 )
        {
        printf ( "\n                    " );
        chr_pos = 21;
        }
            }

        if ( i == (num_other - 1) )
            if ( other_tbl[i][0] != other_tbl[i][1] )
            {
            printf ( "DEC%d - DEC%d", other_tbl[i][0], other_tbl[i][1] );
            chr_pos += 15;
            }
            else
            {
            printf ( "DEC%d", other_tbl[i][0] );
            chr_pos += 6;
            }
        else
            if ( other_tbl[i][0] != other_tbl[i][1] )
            {
            printf ( "DEC%d - DEC%d, ", other_tbl[i][0], other_tbl[i][1] );
            chr_pos += 17;
            }
            else
        {
        printf ( "DEC%d, ", other_tbl[i][0] );
        chr_pos += 8;
        }
    }
}

/********************************************************************\

 *  NAME:    print_puntc - lists all of the puntcuations present in
                  the font

 *  SYNOPSIS:

        void print_puntc ( puntc_tbl, num_puntc )

        short    puntc_tbl[17][2];    Beginning and ending characters
                        for the puntcuations.
        short    num_puntc;        Number of entries in PUNTC_TBL.

 *  DESCRIPTION:

    This routine lists all of the puntcuations present in the
    font.  All of the character codes represented by each entry
    in the PUNTC_TBL are listed with its equivalent name.  This
    is the only group which each individual character code is
    listed.  The puntcuations are listed as special names rather
    than character codes (decimal 32 would be listed as SPACE).
    If there are any puntcuations present, they will always appear
    in the middle of the listing of character codes present (see
    also list_full).  The following is a list of the special names,
    their decimal value, and the character:

        SPACE    32        SEMCOL     59  ;
        EXCLAM     33  !        LT    60  <
        QUOTE    34  "        EQUALS    61  =
        NUMBER    35  #        GT    62  >
        DOLLAR    36  $        QSTION    63  ?
        PRCENT    37  %        ATSIGN  64  @
        ANDSGN    38  &        LBRACK    91  [
        SQUOTE    39  '        BSLASH    92  \
        LPAREN    40  (        RBRACK    93  ]
        RPAREN    41  )        CAROT    94  ^
        STAR    42  *        ULINE    95  _
        PLUS    43  +        GRAVE    96  `
        COMMA    44  ,        LBRACE    123 {
        MINUS    45  -        VLINE    124 |
        PERIOD    46  .        RBRACE    125 }
        SLASH    47  /        TILDE    126 ~
        COLON    58  :        PLSMIN    200 (plus/minus sign)

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:    none

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

    list_full (), put_puntc ()

 *  MODIFICATIONS:

\********************************************************************/
void print_puntc ( puntc_tbl, num_puntc )

short    puntc_tbl[17][2];        /* beg and end chars for the puntcuations */
short    num_puntc;            /* # of entries in PUNTC_TBL */

    {
char      char_name[7];            /* current character name */

short    char_code;            /* current character code */
short    chr_pos;            /* current char position on print line */
short     i, j = 0, k;

bool    end_array = FALSE;        /* indicates end of PUNTC_TBL */
bool    match = FALSE;            /* indicates match found in DEF_NMS for char */


    printf ( "\n                    " );
    chr_pos = 21;

    for ( i = 0;  i < num_puntc;  i++ )
        {
    for ( k = 0;  k <= puntc_tbl[i][1] - puntc_tbl[i][0];  k++ )
            {
            if ( i == (num_puntc - 1) )
            if ( k == puntc_tbl[i][1] - puntc_tbl[i][0] )
                end_array = TRUE;

        j = 0;
        match = FALSE;
            char_code = puntc_tbl[i][0] + k;
        while ( ISFALSE(match)  &&  j <= 33 )
        {
        if ( defnm_code[j] == char_code )
            {
            strncpy( char_name, def_nms[j], 7 );
            match = TRUE;
            }
        j++;
        }

        if ( ISTRUE(end_array) )
            {
            if ( (chr_pos + strlen(char_name)) > 75 )
            {
            printf ( "\n                    " );
            chr_pos = 21;
            }
            }
            else
            {
            if ( (chr_pos + strlen(char_name) + 2) > 75 )
            {
            printf ( "\n                    " );
            chr_pos = 21;
            }
            }

        if ( ISTRUE(end_array) )
            {
              printf ( "%s", char_name );
        chr_pos += ( strlen(char_name) );
            }
        else
            {
        printf ( "%s, ", char_name );
        chr_pos += ( strlen(char_name) + 2 );
        }
            }
    }
}

/********************************************************************\

 *  NAME:    init_name_tbl - initializes NAME_TBL with all of the
                font names in the name table

 *  SYNOPSIS:

        bool init_name_tbl ( name_tbl, num_names )

        struct name_record name_tbl[];    Table of all font names.
        short   *num_names;        Number of fonts in name table.

 *  DESCRIPTION:

    This routine initializes NAME_TBL with all of the font names 
    in the name table.  NUM_NAMES will contain the total number of
    entries in NAME_TBL.

 *  GLOBAL DATA BEING CHANGED:

    struct *Lh_o_ptr

 *  RETURN VALUE:

    RMS status

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

        M. Futch    DATE:    NOV-1985

            Changed the call to READBLK to be more generic by
            adding additional arguments - file control block
            and input/output buffer (Flib_cb & flib_buf).

\********************************************************************/
bool init_name_tbl ( name_tbl, num_names )
 name_record     name_tbl[];        /* table of all font names */
short           *num_names;        /* # of fonts in name table */

{

extern library_header     *Lh_o_ptr;
#ifdef BIG_ENDIAN
       library_header     x_Lh_o_ptr;
       library_header     *XLh_o_ptr;
#endif
/*extern long             Flib_cb;     font library file control block */

 fnt_nm_table           *fnt_o_ptr;

/*short     flib_buf[2048];                 buffer to hold font library */
buf_union buffer;
short    n;
short    nt_word;                /* word # where name table begins */

long     nt_blk;                /* virtual block number (font library) */

bool    status = TRUE;

#ifdef BIG_ENDIAN
    XLh_o_ptr = &x_Lh_o_ptr;
   
    XLh_o_ptr->fnt_ptr = Lh_o_ptr->fnt_ptr;
    Xconv_int(&XLh_o_ptr->fnt_ptr);
    nt_blk = XLh_o_ptr->fnt_ptr / 512 + 1;
    nt_word = ( XLh_o_ptr->fnt_ptr % 512 ) / 2  + 1;
#else
    nt_blk = Lh_o_ptr -> fnt_ptr / 512 + 1;
    nt_word = ( Lh_o_ptr -> fnt_ptr % 512 ) / 2  + 1;
#endif
    
    status = readblk ( Flib_cb, nt_blk, BUF_4096, buffer.flib_buf );    
    if ( ISSUCCESS(status) )
    {
    fnt_o_ptr = (fnt_nm_table *) &buffer.flib_buf[nt_word - 1];
#ifdef BIG_ENDIAN
    Xconv_short(&fnt_o_ptr->num_of_nm);
#endif
    *num_names = fnt_o_ptr->num_of_nm;

    for ( n = 0;  n < *num_names;  n++ )        
        {
#ifdef BIG_ENDIAN
        Xconv_short(&fnt_o_ptr->name[n].font_num);
#endif

        name_tbl[n].font_num = fnt_o_ptr -> name[n].font_num;
        strcpy( name_tbl[n].fnt_nm, fnt_o_ptr -> name[n].fnt_nm );
        }
    }
    return (status);
}

/********************************************************************\

 *  NAME:    get_name - retrieves the font name for the current font

 *  SYNOPSIS:

        bool get_name ( font_num, num_names, name_tbl, name_font )

        short     font_num;        Current font number.
        short    num_names;        Number of fonts in name table.
        struct name_record name_tbl[];    Table of all font names.
        char    name_font[];        Current font name.

 *  DESCRIPTION:

    This routine retrieves the font name for the current font.  It
    accepts the font number and searches NAME_TBL for that number.
    If the number is found, it returns the associated name in
        NAME_FONT.  If the number is not found, STATUS is returned with
        a false value.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

        0 - name not found or I/O error
        1 - name found

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

\********************************************************************/
bool get_name ( font_num, num_names, name_tbl, name_font )

short             font_num;        /* current font number */
short            num_names;        /* # of fonts in name table */
 name_record    name_tbl[];        /* table of all font names */
char            name_font[];        /* current font name */

{
short        m;
bool        status = TRUE;

    m = 0;

    while ( name_tbl[m].font_num != font_num  &&  m < num_names )
       ++m;
    if ( name_tbl[m].font_num == font_num )
        {
        strcpy( name_font, name_tbl[m].fnt_nm );
        status = TRUE;
    }
    else
        status = FALSE;
    
    return (status);
}


