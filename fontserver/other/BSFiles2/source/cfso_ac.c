




/*****************************************************************************
*                                                                            *
*            Copyright 1987, 1988, Bitstream Inc., Cambridge, MA             *
*                            Patent No. 4,785,391                            *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/**************************** C F S C O _ A C . C ****************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 0)  25-Nov-85  mike yudis

 1)  05-Dec-85  mby   Version 2.1 update. Added 'layout_size' to
                      loadx_font_header & write_font_header

 2)  15-Jan-86  mby   Added optional char-id word to character directory

 3)  22-Jan-86  mby   Version 2.2 update. Added 'wordspace_width' to
                      loadx_font_header & write_font_header

 4)   5-May-86  mby   Version 2.3 update. 'compr_font_2.3.h" is now the
                      name of the "include" file

 5)   7-Jan-87  mby   include file name = comp2_3.h

 6)  27-Apr-87  mby   Fix bug reading & writing 2 word kerning pair recs

 7)   1-May-87  mby   Add 'O2' outline data record (outline data > 64K words)

 8)  23-Mar-88  mby   Fix memory allocation bug for outline data > 64K words

 9)  26-Apr-88  mby   Font decryption routine 'g2' (~line 1200). Bitstream
                      'sco' encryption scheme

 *****************************************************************************

    This module is used to access information in a Bitstream Compressed
    Outline file.

    The entry points into this module are 'cft_load',  'cft_load_header',
    and 'cft_write'.

    The procedure 'cft_load' is responsible for building the font information
    structure. It is assumed that a structure of the type 'cft_outl_str' has
    been declared in the calling module (see '/user/include/comp2_3.h').
    A pointer to this structure is passed as an argument to the function.
    Memory for the kerning pairs, kerning tracks, character directories, and
    outline data is allocated by this function. Pointers to these are stored
    within the font structure. 'cft_load' returns 0 if the font loads
    properly, or 1 if it is not a compressed outline.

    The procedure 'cft_load_header' loads the general font information
    section of a compressed outline into a structure of type 'cft_font_hdr'.
    The block header for this section is loaded into a structure of type
    'cft_block_hdr'. Pointers to these structure are passed as arguments to
    the function. 'cft_load_header' returns 0 if the font loads properly,
    or 1 if it is not a compressed outline.

    The procedure 'cft_write' writes a complete compressed outline font using
    the structure 'cft_outl_str'. A pointer to this structure is passed as an
    argument to the function. Pointers to memory containing the kerning pairs,
    kerning tracks, character directories, and outline data are stored within
    the font structure.

    The structures 'cft_outl_str', 'cft_block_hdr', 'cft_font_hdr',
    cft_kern_pair_rec', 'cft_trk_kern_rec', and 'cft_chardir_rec' are
    defined in the file '/user/include/comp2_3.h'

    Note: Memory allocation is handled by procedures 'allocmem', 'deallocmem',
    and 'allocinq'. '/user/library/alloc.c' or a copy thereof must be linked
    into the user's program. A file 'alloc.h' must be in the user's directory.
    ALLOCSIZE in 'alloc.h' should be set to an appropriate value (about 128K
    bytes is recommended).

    Note: The following declarations must be made in cfont_ac.h in order for
    this code to compile:
        #define MAX_READ  nnnn      - maximum number of bytes that can
        #define MAX_WRITE nnnn      - be read/written in one call
        #define READ_COMP           - turns on font loading code
        #define WRITE_COMP          - turns on font writing code

    Byte switching is taken care of by __BYTORD_68000 switch.

 ****************************************************************************/


#include "stdef.h"
#include "cfso_ac.h"
#include "comp2_3.h"
#include <malloc.h>
#include "errchk.h"
#include "error.h"


static  fix31   size_bh;        /* # bytes in block header record */
static  ufix16  t1=KEY1;

#define FH2_31  286     /* size of font information section with cust nr */
#define FH2_32  284     /* size of ... without cust number */


#ifdef READ_COMP
FUNCTION  fix  cft_load(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  CFT_LOAD is responsible for initializing a font data structure.
 *  It assumes that the font file has been opened, and that 'fd_font' is
 *  its file descriptor. Also, 'cmfont' points to a structure of the type
 *  'cft_outl_str' which has been declared in the calling module.
 *  Note:  this is an entry point into this Module.
 *  Called by:  ANOTHER MODULE
 *  Returns:    0 if font looks OK, else 1 if it's not a compressed font
 *              or cannot load it.
 */

    DECLARE
    bool    blockhs_load();         /* fcn to all load block headers */
    bool    format_check_read();    /* verifies valid font format */
    bool    load_char_dirs();       /* fcn to load char directories */
    bool    load_font_header();     /* fcn to load general font info */
    bool    load_kern_prs();        /* fcn to load kerning pairs */
    bool    load_kern_trks();       /* fcn to load kerning tracks */
    bool    load_outl_data();       /* fcn to load outline data */
    bool    memory_alloc();         /* fcn to allocate memory for font */

    BEGIN
    size_bh = sizeof(cft_block_hdr);
    if (!format_check_read(fd_font))
        {
        report_error(ERROR,ER_BAD_FONT_FORMAT,TRUE,"");
        return (1);
        }
    lseek(fd_font, 0L, (fix) 0);
    if (!load_font_header (fd_font, cmfont))
        return (1);
    if (!blockhs_load (fd_font, cmfont))
        return (1);
    if (!memory_alloc (cmfont))
        return (1);
    if (!load_kern_prs (fd_font, cmfont))
        return (1);
    if (!load_kern_trks (fd_font, cmfont))
        return (1);
    if (!load_char_dirs (fd_font, cmfont))
        return (1);
    if (!load_outl_data (fd_font, cmfont))
        return (1);
    return (0);                 /* all is OK */
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  fix  cft_load_header(fd_font, finf_blkhd, finf)
  fix             fd_font;      /* font file descriptor */
  cft_block_hdr  *finf_blkhd;   /* ptr to block header data descriptor */
  cft_font_hdr   *finf;         /* ptr to font information data descriptor */

/*  CFT_LOAD_HEADER loads the font information block header and the font
 *  font information section. It assumes that the font file has been opened,
 *  and that 'fd_font' is its file descriptor. 'finf_blkhd' and 'finf' point
 *  to structures which which have been declared in the calling module.
 *  Note:  this is an entry point into this Module.
 *  Called by:  ANOTHER MODULE
 *  Returns:    0 if font looks OK, else 1 if it's not a compressed font
 *              or cannot load it
 */

    DECLARE
    bool    format_check_read();    /* verifies valid font format */
    bool    load_block_header();    /* fcn to load font information blk hdr */
    bool    loadx_font_header();    /* fcn to load font information */

    BEGIN
    size_bh = sizeof(cft_block_hdr);
    if (!format_check_read(fd_font))
        {
        report_error(ERROR,ER_BAD_FONT_FORMAT_HDR,TRUE,"");
        return (1);
        }
    lseek(fd_font, 0L, (fix) 0);
    if (!load_block_header (fd_font, finf_blkhd))
        return (1);
    if (!loadx_font_header (fd_font, finf_blkhd, finf))
        return (1);

    return (0);                 /* all is OK */
    END
#endif /* defined READ_COMP */


#ifdef WRITE_COMP
FUNCTION  fix  cft_write(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  CFT_WRITE writes a font data structure into a file. It assumes that the
 *  font file has been opened for writing, and that 'fd_font' is its file
 *  descriptor. 'cmfont' points to a structure of the type 'cft_outl_str',
 *  which has been declared in the calling module. The format version is
 *  checked in the font information section.
 *  Note:  this is an entry point into this Module.
 *  Called by:  ANOTHER MODULE
 *  Returns:    0 if font looks OK, else 1 if it's not a compressed font
 *              or cannot write it for any reason
 *  The font is not written if the format is incorrect
 */

    DECLARE
    bool    format_check();          /* check format number for valid font */
    bool    write_char_dirs();       /* fcn to write char directories    */
    bool    write_font_header();     /* fcn to write general font info  */
    bool    write_kern_prs();        /* fcn to write kerning pairs    */
    bool    write_kern_trks();       /* fcn to write kerning tracks  */
    bool    write_outl_data();       /* fcn to write outline data  */

    BEGIN
    if (!format_check(cmfont->fonthead.outl_fmt_nr))
        {
        report_error(ERROR,ER_BAD_FONT_FORMAT_WRITE,TRUE,"");
        return (1);
        }
    size_bh = sizeof(cft_block_hdr);
    if (!write_font_header (fd_font, cmfont))
        return (1);
    if (!write_kern_prs (fd_font, cmfont))
        return (1);
    if (!write_kern_trks (fd_font, cmfont))
        return (1);
    if (!write_char_dirs (fd_font, cmfont))
        return (1);
    if (!write_outl_data (fd_font, cmfont))
        return (1);

    return (0);
    END
#endif /* defined WRITE_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  load_block_header(fd_font, block_header)
  fix             fd_font;      /* font file descriptor         */
  cft_block_hdr  *block_header; /* ptr to block header data descriptor */

/*  LOAD_BLOCK_HEADER loads a block header into the data structure.
 *  'block_header' is a pointer to a structure of type 'cft_block_hdr'.
 *  The index into the file is assumed to be properly positioned.
 *  Called by:  CFT_LOAD_HEADER, LOAD_FONT_HEADER, BLOCKHS_LOAD
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix16 *buff_s;

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    bool    read_chk();         /* verifies that read() worked OK */
    ufix16  swap16();           /* swap bytes in 16-bit word */

    BEGIN
    if ((buff = allocmem(size_bh)) == NULL)  return (FALSE);
    if (!read_chk (fd_font, (char huge *) buff, size_bh))  return (FALSE);
    buff_s = (ufix16 *)buff;
    block_header->block_id[0] = buff[0];
    block_header->block_id[1] = buff[1];
#if __BYTORD_68000
    block_header->nr_data_wds = swap16(buff_s[1]);
    block_header->rec_size = swap16(buff_s[2]);
    block_header->nr_recs = swap16(buff_s[3]);
#else
    block_header->nr_data_wds = buff_s[1];
    block_header->rec_size = buff_s[2];
    block_header->nr_recs = buff_s[3];
#endif  /*  __BYTORD_68000 */
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  blockhs_load(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor         */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  BLOCKHS_LOAD loads the block headers for the kerning pairs, kerning
 *  tracks, character directories, and outline data into the data structure,
 *  pointed to by 'cmfont'. The font information in 'cmfont->fonthead' is
 *  assumed to be already present, otherwise there is no way of locating
 *  the other sections.
 *  Called by:  CFT_LOAD
 */

    DECLARE
    bool    load_block_header();    /* fcn to load font information blk hdr */

    BEGIN

    lseek(fd_font, (fix31) cmfont->fonthead.offs_kernprs * 2, (fix) 0);
    if (!load_block_header (fd_font, &cmfont->knpr_hd))  return (FALSE);

    lseek(fd_font, (fix31) cmfont->fonthead.offs_kerntrks * 2, (fix) 0);
    if (!load_block_header (fd_font, &cmfont->kntrk_hd))  return (FALSE);

    lseek(fd_font, (fix31) cmfont->fonthead.offs_chardir * 2, (fix) 0);
    if (!load_block_header (fd_font, &cmfont->chdir_hd))  return (FALSE);

    lseek(fd_font, (fix31) cmfont->fonthead.offs_outldata * 2, (fix) 0);
    if (!load_block_header (fd_font, &cmfont->outl_hd))  return (FALSE);

    return (TRUE);
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  load_font_header(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor         */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  LOAD_FONT_HEADER is responsible for reading the header record into the
 *  font data structure, pointed to by 'cmfont->fonthead'.
 *  Called by:  CFT_LOAD
 *  Returns:    0 if font looks OK, else 1 if it's not a compressed font
 *              or cannot load it.
 */

    DECLARE
    bool    load_block_header();    /* fcn to load block header */
    bool    loadx_font_header();    /* fcn to load font information */

    BEGIN
    if (!load_block_header (fd_font, &cmfont->finf_hd))
        return (FALSE);
    return (loadx_font_header (fd_font, &cmfont->finf_hd, &cmfont->fonthead));
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  loadx_font_header(fd_font, fontinf_bhdr, fontinf_str)
  fix              fd_font;         /* font file descriptor         */
  cft_block_hdr   *fontinf_bhdr;    /* ptr to font info blk header structure */
  cft_font_hdr    *fontinf_str;     /* ptr to font information structure */

/*  LOADX_FONT_HEADER does the nitty-gritty of loading the font information
 *  section into the data structure 'fontinf_str'
 *  Called by:  LOAD_FONT_HEADER,  CFT_LOAD_HEADER
 *  Returns:    TRUE if OK, else FALSE if not a compressed font
 *              or cannot load it.
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    char   *buffp;
    ufix16 *buffp_s;
    ufix32 *buffp_l;
    fix15   fmnr;               /* font format code */
    fix31   size_fi;            /* # bytes of font information */

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    void    mbyte();            /* move byte */
    bool    read_chk();         /* verifies that read() worked OK */
    void    reverse16();        /* reverse bytes in 16-bit array */
    void    reverse32();        /* reverse bytes in 32-bit array */


    BEGIN
    size_fi = fontinf_bhdr->nr_data_wds * 2;    /* 142 or 143 words */
    if ((buff = allocmem ((fix31) sizeof(cft_font_hdr))) == NULL)  return (FALSE);
    lseek(fd_font, size_bh, (fix) 0);
    if (!read_chk (fd_font, (char huge *) buff, size_fi))  return (FALSE);
    buffp = buff;
#if __BYTORD_68000              /* byte swapping for 68000 type machines */
    buffp_s = (ufix16 *)buff;
    reverse16(buffp_s, (fix31)6, (fix31)1);
    buffp_l = (ufix32 *)(buff + 238);
    reverse32(buffp_l, (fix31)0, (fix31)1);
    reverse16(buffp_s, (fix31)121, (fix31)3);
    buffp_l = (ufix32 *)buff;
    reverse32(buffp_l, (fix31)62, (fix31)8);
    reverse16(buffp_s, (fix31)140, (fix31)4);
#endif  /*  __BYTORD_68000 */
    mbyte(buffp, fontinf_str->outl_fmt_nr, (fix31)8);
    buffp += 8;
    mbyte(buffp, fontinf_str->src_font_id, (fix31)4);
    buffp += 4;
    buffp_s = (ufix16 *)buffp;
    fontinf_str->src_font_vrsn = *buffp_s;
    buffp += 2;
    mbyte(buffp, fontinf_str->src_font_name, (fix31)70);
    buffp += 70;
    mbyte(buffp, fontinf_str->mfg_date, (fix31)10);
    buffp += 10;
    mbyte(buffp, fontinf_str->layout_name, (fix31)70);
    buffp += 70;
    mbyte(buffp, fontinf_str->cpyrt_notice, (fix31)74);
    buffp += 74;
    buffp_l = (ufix32 *)buffp;
    fontinf_str->timestamp = *buffp_l++;
    buffp += 4;
    buffp_s = (ufix16 *)buffp;
    fontinf_str->resl_per_em = *buffp_s++;
    fontinf_str->flag1 = *buffp_s++;
    fontinf_str->flag2 = *buffp_s++;
    buffp_l = (ufix32 *)buffp_s;
    fontinf_str->extent_x_min = *buffp_l++;
    fontinf_str->extent_x_max = *buffp_l++;
    fontinf_str->extent_y_min = *buffp_l++;
    fontinf_str->extent_y_max = *buffp_l++;
    fontinf_str->offs_kernprs = *buffp_l++;
    fontinf_str->offs_kerntrks = *buffp_l++;
    fontinf_str->offs_chardir = *buffp_l++;
    fontinf_str->offs_outldata = *buffp_l++;
    if ((ufix32)fontinf_str->offs_kernprs > 1000000  ||
         (ufix32)fontinf_str->offs_kerntrks > 1000000 ||
          (ufix32)fontinf_str->offs_chardir > 1000000  ||
           (ufix32)fontinf_str->offs_outldata > 1000000  )
        {
        deallocmem(buff);       /* invalid pointers */
        return (FALSE);
        }
   /*  Format C2.3 is the latest format and has a font information section
    *    either 142 or 143 words long. The longer field includes a 16-bit
    *    customer number field at the end.
    *  Format C1.0 is the absolute format. Don't worry about it  */
    buffp_s = (ufix16 *)buffp_l;
    fmnr = 10 * (fontinf_str->outl_fmt_nr[1] - '0') +
           (fontinf_str->outl_fmt_nr[3] - '0');
    if (fmnr == 10)             /* format "C1.0" */
        {
        fontinf_str->layout_size = 0xFFFF;  /* see 'load_char_dirs'    */
        fontinf_str->wordspace_width = 0;
        fontinf_str->cust_number = 0;
        }
    else                        /* format "C2.3" */
        {
        fontinf_str->layout_size = *buffp_s++;
        fontinf_str->wordspace_width = *buffp_s++;
        if (size_fi == FH2_31)
            fontinf_str->cust_number = *buffp_s++;
        else
            fontinf_str->cust_number = 0;
        }
    fontinf_str->rev_number = 0;

    if (!deallocmem (buff))     /* invalid pointers */
        return (FALSE);

    return(TRUE);
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  load_kern_prs(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor         */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  LOAD_KERN_PRS reads the kerning pairs from the font and puts them into
 *  an array of data structures. A pointer to these is in the font data
 *  structure (cmfont->knpr_dat).
 *  Called by:  CFT_LOAD
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix8  *buffp;
    ufix16 *buffp_s;
    fix15   ii;
    fix31   size_kp;            /* # bytes of kerning pairs */

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    bool    read_chk();         /* verifies that read() worked OK */
    ufix16  swap16();           /* swap bytes in 16-bit word */

    BEGIN
    size_kp = cmfont->knpr_hd.nr_data_wds * 2;
    if (size_kp == 0) return (TRUE);

    if ((buff = allocmem(size_kp)) == NULL)  return (FALSE);
    lseek(fd_font, (fix31) cmfont->fonthead.offs_kernprs * 2 + size_bh, (fix) 0);
    if (!read_chk (fd_font, buff, size_kp))  return (FALSE);
    buffp = (ufix8 *)buff;
    for (ii=0; ii < cmfont->knpr_hd.nr_recs;  ii++)
        {
        if (cmfont->knpr_hd.rec_size == 2)
            {
            cmfont->knpr_dat[ii].char1 = *buffp;buffp++;    /* Microsoft C bug */
            cmfont->knpr_dat[ii].char2 = *buffp;buffp++;    /*  *buffp++ doesn't work */
            buffp_s = (ufix16 *)buffp;                      /*  inside a loop */
            }
        else
            {
            buffp_s = (ufix16 *)buffp;
#if __BYTORD_68000
            cmfont->knpr_dat[ii].char1 = swap16(*buffp_s++);
            cmfont->knpr_dat[ii].char2 = swap16(*buffp_s++);
#else
            cmfont->knpr_dat[ii].char1 = *buffp_s;buffp_s++;
            cmfont->knpr_dat[ii].char2 = *buffp_s;buffp_s++;
#endif  /*  __BYTORD_68000 */
            }
#if __BYTORD_68000
        cmfont->knpr_dat[ii].adjustment = swap16(*buffp_s++);
#else
        cmfont->knpr_dat[ii].adjustment = *buffp_s;buffp_s++;
#endif  /*  __BYTORD_68000 */
        buffp = (ufix8 *)buffp_s;
        }
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  load_kern_trks(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor         */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  LOAD_KERN_TRKS reads the kerning tracks from the font and puts them into
 *  an array of data structures. A pointer to these is in the font data
 *  structure (cmfont->kntrk_dat).
 *  Called by:  CFT_LOAD
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix16 *buffp_s;
    fix15   ii;
    fix31   size_kt;            /* # bytes of kerning track data */

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    bool    read_chk();         /* verifies that read() worked OK */
    void    reverse16();        /* reverse bytes in 16-bit array */

    BEGIN
    size_kt = cmfont->kntrk_hd.nr_data_wds * 2;
    if (size_kt == 0) return (TRUE);

    if ((buff = allocmem(size_kt)) == NULL)  return (FALSE);
    lseek(fd_font, (fix31) cmfont->fonthead.offs_kerntrks * 2 + size_bh, (fix) 0);
    if (!read_chk (fd_font, (char huge *) buff, size_kt))  return (FALSE);
    buffp_s = (ufix16 *)buff;
#if __BYTORD_68000
    reverse16(buffp_s, (fix31)0, (fix31)cmfont->kntrk_hd.nr_data_wds);
#endif  /*  __BYTORD_68000 */
    for (ii=0; ii < cmfont->kntrk_hd.nr_recs;  ii++)
        {
        cmfont->kntrk_dat[ii].point_size = *buffp_s;buffp_s++;
        cmfont->kntrk_dat[ii].track_1_adj = *buffp_s;buffp_s++;
        if (cmfont->kntrk_hd.rec_size >= 3)
            {
            cmfont->kntrk_dat[ii].track_2_adj = *buffp_s;buffp_s++;
            if (cmfont->kntrk_hd.rec_size == 4)
                {
                cmfont->kntrk_dat[ii].track_3_adj = *buffp_s;buffp_s++;
                }
            }
        }
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  load_char_dirs(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor         */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  LOAD_CHAR_DIRS reads the character directories from the font and puts
 *  them into an array of data structures. A pointer to these is in the font
 *  data structure (cmfont->chdir_dat).
 *  Called by:  CFT_LOAD
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix16 *buffp_s;
    ufix32 *buffp_l;
    fix15   ii;
    fix31   size_cd;            /* # bytes in character directories */

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    bool    read_chk();         /* verifies that read() worked OK */
    ufix16  swap16();           /* swap bytes in 16-bit word */
    ufix32  swap32();           /* swap bytes in 32-bit word */

    BEGIN
    size_cd = cmfont->chdir_hd.nr_data_wds * 2;
    if (cmfont->fonthead.layout_size == 0xFFFF)   /* If not already defined */
        cmfont->fonthead.layout_size = cmfont->chdir_hd.nr_recs;
    if ((buff = allocmem (size_cd)) == NULL)  return (FALSE);
    lseek(fd_font, (fix31) cmfont->fonthead.offs_chardir * 2 + size_bh, (fix) 0);
    if (!read_chk (fd_font, (char huge *) buff, size_cd))  return (FALSE);
    buffp_s = (ufix16 *)buff;
    for (ii=0; ii < cmfont->chdir_hd.nr_recs;  ii++)
        {
#if __BYTORD_68000
        cmfont->chdir_dat[ii].set_width = swap16(*buffp_s++);
#else
        cmfont->chdir_dat[ii].set_width = *buffp_s;buffp_s++;
#endif  /*  __BYTORD_68000 */
        if ((cmfont->fonthead.flag1 & F_CHARID) == 0)   /* no char ID word */
            {
            if (cmfont->chdir_hd.rec_size == 2)
#if __BYTORD_68000
                cmfont->chdir_dat[ii].outline_offs = (ufix32)(swap16(*buffp_s++));
#else
                {
                cmfont->chdir_dat[ii].outline_offs = (ufix32)*buffp_s;buffp_s++;
                }
#endif  /*  __BYTORD_68000 */
            else        /* record size = 3 words */
                {
                buffp_l = (ufix32 *)buffp_s;
#if __BYTORD_68000
                cmfont->chdir_dat[ii].outline_offs = swap32(*buffp_l++);
#else
                cmfont->chdir_dat[ii].outline_offs = *buffp_l;buffp_l++;
#endif  /*  __BYTORD_68000 */
                buffp_s = (ufix16 *)buffp_l;
                }
            cmfont->chdir_dat[ii].char_id = 0;
            }
        else        /* char ID is last word in character directory record */
            {
            if (cmfont->chdir_hd.rec_size == 3)
                {
#if __BYTORD_68000
                cmfont->chdir_dat[ii].outline_offs = (ufix32)(swap16(*buffp_s++));
                cmfont->chdir_dat[ii].char_id = swap16(*buffp_s++);
#else
                cmfont->chdir_dat[ii].outline_offs = (ufix32)*buffp_s;buffp_s++;
                cmfont->chdir_dat[ii].char_id = *buffp_s;buffp_s++;
#endif  /*  __BYTORD_68000 */
                }
            else        /* record size = 4 words */
                {
                buffp_l = (ufix32 *)buffp_s;
#if __BYTORD_68000
                cmfont->chdir_dat[ii].outline_offs = swap32(*buffp_l++);
                buffp_s = (ufix16 *)buffp_l;
                cmfont->chdir_dat[ii].char_id = swap16(*buffp_s++);
#else
                cmfont->chdir_dat[ii].outline_offs = *buffp_l;buffp_l++;
                buffp_s = (ufix16 *)buffp_l;
                cmfont->chdir_dat[ii].char_id = *buffp_s;buffp_s++;
#endif  /*  __BYTORD_68000 */
                }
            }
        }
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined READ_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  load_outl_data(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor         */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  LOAD_OUTL_DATA reads the outline data block from the font and puts the
 *  data in an array. A pointer to the data is in the font data structure
 *  (cmfont->outl_dat).
 *  Called by:  CFT_LOAD
 */

    DECLARE
    char   huge *buff;
    fix31   n1;                 /* number of words of outline data to xfer */

    void    g2();
    bool    read_chk();         /* verifies that read() worked OK */
    void    reverse16();        /* reverse bytes in 16-bit array */

    BEGIN
    if (strncmp (cmfont->outl_hd.block_id, "O2", 2) == 0)   /* > 64K wds? */
        n1 = ((fix31)cmfont->outl_hd.rec_size << 16) + cmfont->outl_hd.nr_data_wds;
    else
        n1 = cmfont->outl_hd.nr_data_wds;                   /* the usual */
    lseek(fd_font, (fix31) cmfont->fonthead.offs_outldata * 2 + size_bh, (fix) 0);
    buff = (char huge *)cmfont->outl_dat;      /* 1st word of outline data */
    if (!read_chk (fd_font, (char huge *) buff, (fix31)(n1 * 2)))
        return (FALSE);

#if __BYTORD_68000
    reverse16(buff, (fix31)0, n1);
#endif  /*  __BYTORD_68000 */

    g2 (cmfont, 0);

    return (TRUE);
    END
#endif /* defined READ_COMP */


#ifdef WRITE_COMP
FUNCTION  static  bool  write_block_header(fd_font, block_header)
  fix             fd_font;      /* font file descriptor         */
  cft_block_hdr  *block_header; /* ptr to block header data descriptor */

/*  WRITE_BLOCK_HEADER is writes a block header data structure to a files.
 *  'block_header' is a pointer to a structure of type 'cft_block_hdr'.
 *  Called by:  WRITE_FONT_HEADER, WRITE_KERN_PRS, WRITE_KERN_TRKS,
 *              WRITE_CHAR_DIRS, WRITE_OUTL_DATA
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix16 *buff_s;

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    ufix16  swap16();           /* swap bytes in 16-bit word */
    bool    write_chk();        /* verifies that write() worked OK */

    BEGIN
    if ((buff = allocmem (size_bh)) == NULL)  return (FALSE);
    buff_s = (ufix16 *)buff;
    buff[0] = block_header->block_id[0];
    buff[1] = block_header->block_id[1];
#if __BYTORD_68000
    buff_s[1] = swap16(block_header->nr_data_wds);
    buff_s[2] = swap16(block_header->rec_size);
    buff_s[3] = swap16(block_header->nr_recs);
#else
    buff_s[1] = block_header->nr_data_wds;
    buff_s[2] = block_header->rec_size;
    buff_s[3] = block_header->nr_recs;
#endif  /*  __BYTORD_68000 */
    if (!write_chk (fd_font, (char huge *) buff, size_bh))  return (FALSE);
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined WRITE_COMP */


#ifdef WRITE_COMP
FUNCTION  static  bool  write_font_header(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor         */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  WRITE_FONT_HEADER is responsible for writing the general font information
 *  structure into the font file.
 *  Called by:  CFT_WRITE
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    char   *buffp;
    ufix16 *buffp_s;
    ufix32 *buffp_l;

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    void    mbyte();            /* move byte */
    void    reverse16();        /* reverse bytes in 16-bit array */
    void    reverse32();        /* reverse bytes in 32-bit array */
    bool    write_block_header();  /* writes header block to file */
    bool    write_chk();        /* verifies that write() worked OK */

    BEGIN
    if (!write_block_header(fd_font, &cmfont->finf_hd))  return (FALSE);
    if ((buff = allocmem ((fix31) sizeof(cft_font_hdr))) == NULL)  return (FALSE);
    buffp = buff;
    mbyte(cmfont->fonthead.outl_fmt_nr, buffp, (fix31)8);
    buffp += 8;
    mbyte(cmfont->fonthead.src_font_id, buffp, (fix31)4);
    buffp += 4;
    buffp_s = (ufix16 *)buffp;
    *buffp_s = cmfont->fonthead.src_font_vrsn;
    buffp += 2;
    mbyte(cmfont->fonthead.src_font_name, buffp, (fix31)70);
    buffp += 70;
    mbyte(cmfont->fonthead.mfg_date, buffp, (fix31)10);
    buffp += 10;
    mbyte(cmfont->fonthead.layout_name, buffp, (fix31)70);
    buffp += 70;
    mbyte(cmfont->fonthead.cpyrt_notice, buffp, (fix31)74);
    buffp += 74;
    buffp_l = (ufix32 *)buffp;
    *buffp_l = cmfont->fonthead.timestamp;
    buffp += 4;
    buffp_s = (ufix16 *)buffp;
    *buffp_s++ = cmfont->fonthead.resl_per_em;
    *buffp_s++ = cmfont->fonthead.flag1;
    *buffp_s++ = cmfont->fonthead.flag2;
    buffp_l = (ufix32 *)buffp_s;
    *buffp_l++ = cmfont->fonthead.extent_x_min;
    *buffp_l++ = cmfont->fonthead.extent_x_max;
    *buffp_l++ = cmfont->fonthead.extent_y_min;
    *buffp_l++ = cmfont->fonthead.extent_y_max;
    *buffp_l++ = cmfont->fonthead.offs_kernprs;
    *buffp_l++ = cmfont->fonthead.offs_kerntrks;
    *buffp_l++ = cmfont->fonthead.offs_chardir;
    *buffp_l++ = cmfont->fonthead.offs_outldata;
    buffp_s = (ufix16 *)buffp_l;
    *buffp_s++ = cmfont->fonthead.layout_size;
    *buffp_s++ = cmfont->fonthead.wordspace_width;
    *buffp_s++ = cmfont->fonthead.cust_number;
    *buffp_s++ = cmfont->fonthead.rev_number;

#if __BYTORD_68000              /* byte swapping for 68000 type machines */
    buffp_s = (ufix16 *)buff;
    reverse16(buffp_s, (fix31)6, (fix31)1);
    buffp_l = (ufix32 *)(buff + 238);
    reverse32(buffp_l, (fix31)0, (fix31)1);
    reverse16(buffp_s, (fix31)121, (fix31)3);
    buffp_l = (ufix32 *)buff;
    reverse32(buffp_s, (fix31)62, (fix31)8);
    reverse16(buffp_s, (fix31)140, (fix31)4);
#endif  /*  __BYTORD_68000 */

    if (!write_chk (fd_font, buff, (fix31) (cmfont->finf_hd.nr_data_wds * 2)))
        return (FALSE);

    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined WRITE_COMP */


#ifdef WRITE_COMP
FUNCTION  static  bool  write_kern_prs(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor        */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  WRITE_KERN_PRS is responsible for writing the kerning pair data
 *  structure into the font file.
 *  Called by:  CFT_WRITE
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix8  *buffp;
    ufix16 *buffp_s;
    fix15   ii;

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    ufix16  swap16();           /* swap bytes in 16-bit word */
    bool    write_block_header();  /* writes header block to file */
    bool    write_chk();        /* verifies that write() worked OK */

    BEGIN
    if (!write_block_header (fd_font, &cmfont->knpr_hd))  return (FALSE);
    if ((buff = allocmem ((fix31) (cmfont->knpr_hd.nr_data_wds * 2))) == NULL)
        return (FALSE);
    buffp = (ufix8 *)buff;
    for (ii=0; ii < cmfont->knpr_hd.nr_recs;  ii++)
        {
        if (cmfont->knpr_hd.rec_size == 2)
            {
            *buffp++ = (ufix8) cmfont->knpr_dat[ii].char1;
            *buffp++ = (ufix8) cmfont->knpr_dat[ii].char2;
            buffp_s = (ufix16 *)buffp;
            }
        else
            {
            buffp_s = (ufix16 *)buffp;
#if __BYTORD_68000
            *buffp_s++ = swap16(cmfont->knpr_dat[ii].char1);
            *buffp_s++ = swap16(cmfont->knpr_dat[ii].char2);
#else
            *buffp_s++ = cmfont->knpr_dat[ii].char1;
            *buffp_s++ = cmfont->knpr_dat[ii].char2;
#endif  /*  __BYTORD_68000 */
            }
#if __BYTORD_68000
        *buffp_s++ = swap16(cmfont->knpr_dat[ii].adjustment);
#else
        *buffp_s++ = cmfont->knpr_dat[ii].adjustment;
#endif  /*  __BYTORD_68000 */
        buffp = (ufix8 *)buffp_s;
        }
    if (!write_chk (fd_font, buff, (fix31) (cmfont->knpr_hd.nr_data_wds * 2)))
        return (FALSE);
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined WRITE_COMP */


#ifdef WRITE_COMP
FUNCTION  static  bool  write_kern_trks(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor        */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  WRITE_KERN_TRKS is responsible for writing the track kerning data
 *  structure into the font file.
 *  Called by:  CFT_WRITE
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix16 *buffp_s;
    fix15   ii;

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    void    reverse16();        /* reverse bytes in 16-bit array */
    bool    write_block_header();  /* writes header block to file */
    bool    write_chk();        /* verifies that write() worked OK */

    BEGIN
    if (!write_block_header (fd_font, &cmfont->kntrk_hd))  return (FALSE);
    if ((buff = allocmem((fix31) (cmfont->kntrk_hd.nr_data_wds * 2))) == NULL)
        return (FALSE);
    buffp_s = (ufix16 *)buff;
    for (ii=0; ii < cmfont->kntrk_hd.nr_recs;  ii++)
        {
        *buffp_s++ = cmfont->kntrk_dat[ii].point_size;
        *buffp_s++ = cmfont->kntrk_dat[ii].track_1_adj;
        if (cmfont->kntrk_hd.rec_size >= 3)
            {
            *buffp_s++ = cmfont->kntrk_dat[ii].track_2_adj;
            if (cmfont->kntrk_hd.rec_size == 4)
                *buffp_s++ = cmfont->kntrk_dat[ii].track_3_adj;
            }
        }
#if __BYTORD_68000
    buffp_s = (ufix16 *)buff;
    reverse16(buffp_s, (fix31)0, (fix31)cmfont->kntrk_hd.nr_data_wds);
#endif  /*  __BYTORD_68000 */

    if (!write_chk(fd_font, (char huge *) buff, (fix31) (cmfont->kntrk_hd.nr_data_wds * 2)))
        return (FALSE);
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined WRITE_COMP */


#ifdef WRITE_COMP
FUNCTION  static  bool  write_char_dirs (fd_font, cmfont)
  fix             fd_font;      /* font file descriptor        */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  WRITE_CHAR_DIRS is responsible for writing the character directory data
 *  structures into the font file.
 *  Called by:  CFT_WRITE
 */

    DECLARE
    char   *buff;               /* buffer for storing font header */
    ufix16 *buffp_s;
    ufix32 *buffp_l;
    fix15   ii;

    char   *allocmem();         /* allocates memory block, returns pointer */
    bool    deallocmem();       /* deallocates memory block */
    ufix16  swap16();           /* swap bytes in 16-bit word */
    ufix32  swap32();           /* swap bytes in 32-bit word */
    bool    write_block_header();  /* writes header block to file */
    bool    write_chk();        /* verifies that write() worked OK */

    BEGIN
    if (!write_block_header (fd_font, &cmfont->chdir_hd))  return (FALSE);
    if ((buff = allocmem ((fix31) (cmfont->chdir_hd.nr_data_wds * 2))) == NULL)
        return (FALSE);
    buffp_s = (ufix16 *)buff;
    for (ii=0; ii < cmfont->chdir_hd.nr_recs;  ii++)
        {
#if __BYTORD_68000
        *buffp_s++ = swap16(cmfont->chdir_dat[ii].set_width);
#else
        *buffp_s++ = cmfont->chdir_dat[ii].set_width;
#endif  /*  __BYTORD_68000 */
        if ((cmfont->fonthead.flag1 & F_CHARID) == 0)   /* no char ID word */
            {
            if (cmfont->chdir_hd.rec_size == 2)
#if __BYTORD_68000
                *buffp_s++ = swap16( (fix15)cmfont->chdir_dat[ii].outline_offs);
#else
                *buffp_s++ = (fix15)cmfont->chdir_dat[ii].outline_offs;
#endif  /*  __BYTORD_68000 */
            else        /* record size = 3 words */
                {
                buffp_l = (ufix32 *)buffp_s;
#if __BYTORD_68000
                *buffp_l++ = swap32(cmfont->chdir_dat[ii].outline_offs);
#else
                *buffp_l++ = cmfont->chdir_dat[ii].outline_offs;
#endif  /*  __BYTORD_68000 */
                buffp_s = (ufix16 *)buffp_l;
                }
            }
        else        /* char ID is last word in character directory record */
            {
            if (cmfont->chdir_hd.rec_size == 3)
                {
#if __BYTORD_68000
                *buffp_s++ = swap16( (fix15)cmfont->chdir_dat[ii].outline_offs);
                *buffp_s++ = swap16(cmfont->chdir_dat[ii].char_id);
#else
                *buffp_s++ = (fix15)cmfont->chdir_dat[ii].outline_offs;
                *buffp_s++ = cmfont->chdir_dat[ii].char_id;
#endif  /*  __BYTORD_68000 */
                }
            else        /* record size = 4 words */
                {
                buffp_l = (ufix32 *)buffp_s;
#if __BYTORD_68000
                *buffp_l++ = swap32(cmfont->chdir_dat[ii].outline_offs);
                buffp_s = (ufix16 *)buffp_l;
                *buffp_s++ = swap16(cmfont->chdir_dat[ii].char_id);
#else
                *buffp_l++ = cmfont->chdir_dat[ii].outline_offs;
                buffp_s = (ufix16 *)buffp_l;
                *buffp_s++ = cmfont->chdir_dat[ii].char_id;
#endif  /*  __BYTORD_68000 */
                }
            }
        }
    if (!write_chk (fd_font, buff, (fix31) (cmfont->chdir_hd.nr_data_wds * 2)))
        return (FALSE);
    if (!deallocmem(buff))  return (FALSE);

    return (TRUE);
    END
#endif /* defined WRITE_COMP */


#ifdef WRITE_COMP
FUNCTION  static  bool  write_outl_data(fd_font, cmfont)
  fix             fd_font;      /* font file descriptor        */
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  WRITE_OUTL_DATA is responsible for writing all the outline data into
 *  the font file.
 *  Called by:  CFT_WRITE
 */

    DECLARE
    char   huge *buff;
    fix31   n1;                 /* number of words of outline data to xfer */

    void    g2();
    void    reverse16();        /* reverse bytes in 16-bit array */
    bool    write_block_header();  /* writes header block to file */
    bool    write_chk();        /* verifies that write() worked OK */

    BEGIN
    if (!write_block_header (fd_font, &cmfont->outl_hd))  return (FALSE);
    if (strncmp (cmfont->outl_hd.block_id, "O2", 2) == 0)   /* > 64K wds? */
        n1 = ((fix31)cmfont->outl_hd.rec_size << 16) + cmfont->outl_hd.nr_data_wds;
    else
        n1 = cmfont->outl_hd.nr_data_wds;                   /* the usual */
    buff = (char huge *)cmfont->outl_dat;    /* 1st word of outline data */

    g2 (cmfont, 1);

#if __BYTORD_68000
    reverse16(buff, (fix31)0, n1);
#endif  /*  __BYTORD_68000 */

    if (!write_chk(fd_font, (char huge *) buff, (fix31)(n1 * 2)))  return (FALSE);

    return (TRUE);
    END
#endif /* defined WRITE_COMP */


#ifdef READ_COMP
FUNCTION  static  bool  read_chk(fd, buffer, count)
  fix        fd;             /* file descriptor */
  char huge *buffer;         /* buffer for read() */
  fix31      count;          /* # bytes read */

/*  READ_CHK verifies that the number of bytes read from a file is the same
 *  as the number requested.
 *  Returns FALSE if the number of bytes read != the number of bytes requested
 *  Called by:  LOAD_BLOCK_HEADER,  LOADX_FONT_HEADER,  LOAD_KERN_PRS,
 *              LOAD_KERN_TRKS,  LOAD_CHAR_DIRS,  LOAD_OUTL_DATA
 */

    DECLARE
    ufix          ct;
    fix31         nb;

    BEGIN

    while (count > 0)
        {
        ct = ((count > MAX_READ)? MAX_READ: count);

        if ((nb = (ufix)read(fd, buffer, ct)) != ct)
            {
            report_error(ERROR,ER_2FEW_BYTES_READ,TRUE,"");
#ifdef GETRECDBG
            printf ("\n*** READ ERROR. %ld bytes requested, %ld bytes read ***\n\n", (long)ct, (long)nb);
#endif
            return(FALSE);
            }
        count -= ct;
        buffer += ct;
        }
    return (TRUE);
    END
#endif /* defined READ_COMP */


#ifdef WRITE_COMP
FUNCTION  static  bool  write_chk(fd, buffer, count)
  fix        fd;             /* file descriptor */
  char huge *buffer;         /* buffer for read() */
  fix31      count;          /* # bytes read */

/*  WRITE_CHK verifies that the number of bytes written to a file is the same
 *  as the number requested.
 *  Returns FALSE if the number of bytes written is not the number expected.
 *  Called by:  WRITE_BLOCK_HEADER,  WRITE_FONT_HEADER,  WRITE_KERN_PRS,
 *              WRITE_KERN_TRKS,  WRITE_CHAR_DIRS,  WRITE_OUTL_DATA
 */

    DECLARE
    ufix          ct;
    fix31         nb;

    BEGIN

    while (count > 0)
        {
        ct = ((count > MAX_WRITE)? MAX_WRITE: count);

        if ((nb = (ufix)write(fd, (char huge *) buffer, ct)) != ct)
            {   
            report_error(ERROR,ER_2FEW_BYTES_WRITTEN,TRUE,"");
#ifdef GETRECDBG
            printf ("\n*** WRITE ERROR. %ld bytes requested, %ld bytes written ***\n\n", (long)ct, (long)nb);
#endif
            return(FALSE);
            }
        count -= ct;
        buffer += ct;
        }
    return (TRUE);
    END
#endif /* defined WRITE_COMP */


FUNCTION  static  bool  format_check(string)
  char     *string;         /* buffer for read() */

/*  FORMAT_CHECK is a boolean function that returns TRUE if the outline format
 *    number is either "C2.3", or "C1.0"
 *  Called by:  LOADX_FONT_HEADER
 */

    DECLARE

    BEGIN
    if (strncmp(string, "C2.", 3) != 0  &&
          strncmp(string, "C1.0", 4) != 0 )
        {
        report_error(ERROR,ER_NOT_A_CO,TRUE,"");
#ifdef GETRECDBG
        printf("\n*** Not a compressed outline. Format version = \"%.8s\" ***\n\n",
               string);
#endif
        return(FALSE);
        }
    return(TRUE);
    END


#ifdef READ_COMP
FUNCTION  static  bool  format_check_read(fd_font)
  fix   fd_font;            /* file descriptor */

    DECLARE
    char    buff[8];
    bool    format_check();
    bool    read_chk();

    BEGIN
    lseek (fd_font, size_bh, (fix) 0);
    if (!read_chk (fd_font, (char huge *) buff, (fix31) 8))  return (FALSE);
    return (format_check(buff));
    END
#endif /* defined READ_COMP */


FUNCTION  static  void  g2 (fnt, rw)
  cft_outl_str  *fnt;
  fix            rw;

    DECLARE
    ufix16 huge *bb;
    fix31   cs;
    fix31   ii;
    fix31   jj;
    fix31   k1, k2, k3, k4;
    fix31   n1;
    ufix16  p1, p2;
    fix31   ss, tt;
    fix     do_string_sco_sco();
    fix     do_word16_sco();
    fix     do_word32_sco();
    fix     sumchd_sco();
#ifdef CFONTDBG
    ufix16  char_nr, *pchar1, *pchar2;
#endif

static  ufix16  crtbl2[16] = { 0x2251, 0x7C88, 0xCDDF, 0x736D, 0x4876,
       0x20DA, 0x3C82, 0x994C, 0x9A04, 0x1057, 0x2A8A, 0xD8B1, 0x7042,
       0x8BE9, 0xDA6A, 0x0EBC };

    BEGIN
    n1 = fnt->outl_hd.nr_data_wds;
    bb = fnt->outl_dat;
    ss = tt = 0;
    do_string_sco (fnt->fonthead.outl_fmt_nr, 8, &ss, &tt);
    do_string_sco (fnt->fonthead.src_font_id, 4, &ss, &tt);
    do_word16_sco (fnt->fonthead.src_font_vrsn, &ss, &tt);
    do_string_sco (fnt->fonthead.src_font_name, 70, &ss, &tt);
    do_string_sco (fnt->fonthead.mfg_date, 10, &ss, &tt);
    do_string_sco (fnt->fonthead.layout_name, 70, &ss, &tt);
    do_string_sco (fnt->fonthead.cpyrt_notice, 74, &ss, &tt);
    do_word32_sco (fnt->fonthead.timestamp, &ss, &tt);
    do_word16_sco (fnt->fonthead.resl_per_em, &ss, &tt);
    do_word16_sco (fnt->fonthead.flag1, &ss, &tt);
    do_word16_sco (fnt->fonthead.flag2, &ss, &tt);
    do_word32_sco (fnt->fonthead.extent_x_min, &ss, &tt);
    do_word32_sco (fnt->fonthead.extent_x_max, &ss, &tt);
    do_word32_sco (fnt->fonthead.extent_y_min, &ss, &tt);
    do_word32_sco (fnt->fonthead.extent_y_max, &ss, &tt);
    do_word32_sco (fnt->fonthead.offs_kernprs, &ss, &tt);
    do_word32_sco (fnt->fonthead.offs_kerntrks, &ss, &tt);
    do_word32_sco (fnt->fonthead.offs_chardir, &ss, &tt);
    do_word32_sco (fnt->fonthead.offs_outldata, &ss, &tt);
    do_word16_sco (fnt->fonthead.layout_size, &ss, &tt);
    do_word16_sco (fnt->fonthead.wordspace_width, &ss, &tt);
    do_word16_sco (fnt->fonthead.cust_number, &ss, &tt);
    do_word16_sco (fnt->fonthead.rev_number, &ss, &tt);
    if (fnt->chdir_hd.nr_data_wds >= 120)
        {
        k1 = 12; k2 = k3 = 24; k4 = 30;
        }
    else
        {
        k1 = k2 = k3 = k4 = 0;
        }
    for (ii=k1; ii<k2; ii++)
        ss += sumchd_sco(&fnt->chdir_dat[ii]);
    for (ii=k3; ii<k4; ii++)
        tt += sumchd_sco(&fnt->chdir_dat[ii]);

    ss += (tt & 0xFFFF) * 3299;
    ss &= 0x0000FFFF;
#ifdef PCFONTWARE
    cs = (fix31)307;
#else
    if (fnt->fonthead.cust_number == CUS0)
        cs = KEY0;
    else
        cs = t1;
#endif
    p1 = ((cs * 25033) & 0xFFFF) ^ ss;
    p2 = ((p1 * 25031) & 0xFFFF) >> 4;

    k1 = p2 | 1;

/* Debugging code */
#ifdef CFONTDBG                 /* print character data */
    char_nr=1;
    pchar1 = fnt->outl_dat + fnt->chdir_dat[char_nr].outline_offs;
    pchar2 = fnt->outl_dat + fnt->chdir_dat[char_nr+1].outline_offs;
    printf ("Encrypted data: Character %d\n", char_nr);
    for (ii=1; pchar1 < pchar2; ii++, pchar1++)  {
        printf ("%4x  ", *pchar1);
        if (ii%8 == 0) printf ("\n");
        }
    printf ("\n");
#endif
    for (ii=0; ii<n1; ii++)
        {
        k1 = (k1 + k1 + k1 + ((k1 & 0x0000F000) >> 12)) & 0xFFFF;
        jj = crtbl2[(k1 & 0xF0) >> 4];
        k2 = bb[ii];
        k4 = (ii + k1 + jj) & 0xFFFF;
        if (rw == 0)
            {
            k2 = bb[ii] ^ k4;
            k3 = (k2 >> 11) & 0x1F;
            bb[ii] = ((k2 << 5) & 0xFFE0) + k3;
            }
        else
            {
            k3 = (k2 & 0x1F) << 11;
            k2 = ((k2 >> 5) & 0x7FF) + k3;
            bb[ii] = k2 ^ k4;
            }
        }
#ifdef CFONTDBG                 /* print character data */
    pchar1 = fnt->outl_dat + fnt->chdir_dat[char_nr].outline_offs;
    pchar2 = fnt->outl_dat + fnt->chdir_dat[char_nr+1].outline_offs;
    printf ("Decrypted data: Character %d\n", char_nr);
    for (ii=1; pchar1 < pchar2; ii++, pchar1++)  {
        printf ("%4x  ", *pchar1);
        if (ii%8 == 0) printf ("\n");
        }
    printf ("\n");
#endif
    END


FUNCTION  static do_string_sco (string, nbytes, ss, tt)
  ufix8  *string;
  fix     nbytes;
  fix31  *ss, *tt;

    DECLARE
    fix ii;
    fix jj=0;
    fix kk=0;

    BEGIN
    for (ii=0; ii<nbytes; ii++)
        {
        if (ii & 1)
            jj += string[ii];
        else
            kk += string[ii];
        }
    *ss += jj;
    *tt += kk;
    END


FUNCTION  static sumchd_sco (chd)
  cft_chardir_rec  *chd;

    DECLARE
    fix ii;

    BEGIN
    ii = (chd->set_width & 0xff) + ((chd->set_width >> 8) & 0xff);
    ii += (chd->outline_offs & 0xff) + ((chd->outline_offs & 0xff00) >> 8) +
          ((chd->outline_offs & 0xff0000) >> 16) + ((chd->outline_offs & 0xff000000) >> 24);
    ii += (chd->char_id & 0xff) + ((chd->char_id >> 8) & 0xff);
    return (ii);
    END



FUNCTION  static do_word16_sco (shortw, ss, tt)
  ufix16  shortw;
  fix31  *ss, *tt;
    DECLARE
    BEGIN
    *ss += shortw & 0xFF;
    *tt += shortw >> 8;
    END



FUNCTION  static do_word32_sco (longw, ss, tt)
  ufix32  longw;
  fix31  *ss, *tt;
    DECLARE
    BEGIN
    *ss += (longw & 0xFF) + ((longw & 0xFF0000) >> 16);
    *tt += ((longw & 0xFF00) >> 8) + ((longw & 0xFF000000) >> 24);
    END


FUNCTION  set_key (key)
  ufix16    key;
    DECLARE
    BEGIN
    t1 = key;
    return;
    END


FUNCTION  static  bool  memory_alloc(cmfont)
  cft_outl_str   *cmfont;       /* ptr to font data descriptor */

/*  MEMORY_ALLOC take a pointer to a compressed font structure 'cmfont'
 *    Memory is allocated for kerning pairs, kerning tracks, character
 *    directories, and outline data with 'allocmem'. The font information
 *    section and all the block headers must already be resident in the
 *    font data structure for this to work.
 *  Called by:  CFT_LOAD
 */

    DECLARE
    fix31   memcount;
    fix31   memwant;
    char   *s;

    char   *allocmem();
    fix31   allocinq();

    BEGIN
    if (strncmp (cmfont->outl_hd.block_id, "O2", 2) == 0)   /* > 64K wds? */
        memwant = (((fix31)cmfont->outl_hd.rec_size << 16) + cmfont->outl_hd.nr_data_wds) * 2;
    else
        memwant = (fix31)cmfont->outl_hd.nr_data_wds * 2;
    memwant = cmfont->knpr_hd.nr_recs * sizeof(cft_kern_pair_rec) +
              cmfont->kntrk_hd.nr_recs * sizeof(cft_trk_kern_rec) +
              cmfont->chdir_hd.nr_recs * sizeof(cft_chardir_rec) + memwant;
    if ((memcount = allocinq(memwant)) != memwant)
        {
        report_error(ERROR,ER_OUT_OF_MEMORY,TRUE,"");
#ifdef GETRECDBG
        printf("\n*** Insufficient memory. %ld bytes required, %ld bytes available***\n",
               (long)memwant, (long)memcount);
#endif
        }
    if ((s = allocmem(memwant)) == NULL)
        return (FALSE);
    cmfont->knpr_dat = (cft_kern_pair_rec *) (s);
    cmfont->kntrk_dat = (cft_trk_kern_rec *) ((char *)cmfont->knpr_dat +
                         cmfont->knpr_hd.nr_recs * sizeof(cft_kern_pair_rec));
    cmfont->chdir_dat = (cft_chardir_rec *) ((char *)cmfont->kntrk_dat +
                         cmfont->kntrk_hd.nr_recs * sizeof(cft_trk_kern_rec));
    cmfont->outl_dat = (ufix16 huge *) ((char huge *)cmfont->chdir_dat +
                         cmfont->chdir_hd.nr_recs * sizeof(cft_chardir_rec));

    return (TRUE);
    END


static ufix8 *allocated[256];
FUNCTION  static  char  *allocmem(n)    /* return pointer to n bytes    */
  fix31 n;                      /* uses '/user/library/alloc.c' */

    DECLARE
    ufix8  *p;
    ufix8  *alloc();

    BEGIN
    if ((p = alloc((ufix32) n)) == NULL)
        {
        report_error(ERROR,ER_ALLOCATION_PROBLEM,TRUE,"");
#ifdef GETRECDBG
        printf("*** DYNAMIC MEMORY ALLOCATION ERROR ***\n    alloc(%ld) = %lX ***\n",
            (long)n, (long)p);
#endif
        p = NULL;
        }
    return((char *)p);
    END






FUNCTION  static  bool  deallocmem(p)   /* free memory from pointer p   */
  char *p;                      /* uses '/user/library/alloc.c' */

    DECLARE
    bool    q;
    bool    dealloc();

    BEGIN
    if (!(q = dealloc ((ufix8 *)p) ))
        {
        report_error(ERROR,ER_DEALLOCATION_PROBLEM,TRUE,"");
#ifdef GETRECDBG
        printf("*** DYNAMIC MEMORY DEALLOCATION ERROR ***\n    dealloc(%lX) = FALSE ***\n", (long)p);
#endif
        }
    return(q);
    END






FUNCTION  static  fix31  allocinq(n)    /* inquire if n bytes free space available */
  fix31     n;                  /* uses '/user/library/alloc.c' */

/*  Returns either n, or the total memory available, whichever is less */

    DECLARE
    ufix32  alloccount();

    BEGIN
    return (MIN(alloccount(), n));
    END


FUNCTION  static  ufix16  swap16(n)  /* 16-bit unsigned integer: swaps bytes */
  ufix16    n;

    DECLARE
    BEGIN
    return(((n & 0xff) << 8) + ((n & 0xff00) >> 8));
    END




FUNCTION  static  ufix32  swap32(n)  /* 32-bit unsigned integer: interchanges
                                        1st & 4th, 2nd & 3rd bytes          */
  ufix32    n;

    DECLARE
    BEGIN
    return(((n & 0x000000ff) << 24) + ((n & 0x0000ff00) <<  8) +
           ((n & 0x00ff0000) >>  8) + ((n & 0xff000000) >> 24));
    END


/*  REVERSE16
 *  reverses byte order in an array of 16-bit numbers, beginning
 *  with element i, for j iterations
 *  array is a pointer to a 16-bit array
 */
FUNCTION  static  void  reverse16 (array, i, j)
  fix15    *array;
  fix31     i, j;

    DECLARE
    char  *byte, ch;
    fix   k;

    BEGIN
    byte = (char *)(array + i);
    for (k = 0; k < j; k++)
        {
        ch = *byte;
        *byte = *(byte + 1);
        *(++byte) = ch;
        byte++;
        }
    END




/*  REVERSE32
 *  reverses byte order in an array of 32-bit numbers, starting
 *  with element i, for j iterations
 *  array is a pointer to a 32-bit array
 */
FUNCTION  static  void  reverse32 (array, i, j)
  fix31    *array;
  fix31     i, j;

    DECLARE
    char  *byte, ch0, ch1;
    fix   k;

    BEGIN
    byte = (char *)(array + i);
    for (k = 0; k < j; k++)
        {
        ch0 = *byte;
        ch1 = *(byte + 1);
        *byte = *(byte + 3);
        *(byte + 1) = *(byte + 2);
        *(byte + 2) = ch1;
        *(byte + 3) = ch0;
        byte += 4;
        }
    END

/*  MBYTE
 *  moves n bytes from the source array to the destination array
 *  s_array & d_array are pointers to the source, destination
 */
FUNCTION  static  void  mbyte(s_array, d_array, n)
  char   *s_array,
         *d_array;
  fix31   n;

    DECLARE
    fix31 i;
    char *sarr, *darr;

    BEGIN
    if (n <= 0)
        return;

    if (s_array > d_array)
        {
        for (i=0; i<n; i++)
            *d_array++ = *s_array++;
        }
    else
        {
        sarr = (char *) (s_array + n);
        darr = (char *) (d_array + n);
        for (i=0; i<n; i++)
        *(--darr) = *(--sarr);
        }

    return;
    END

