/*\
 *  
 *				INTERGRAPH  1985
 *
 *	INTERGRAPH Corporation assumes  NO responsibility for the use
 *	or reliability of software altered by the user.
 *
 *	The information in this document is subject to change without
 *	notice  and  should  not  be  construed  as  a  commitment by
 *	INTERGRAPH corporation.
 *
 *
\*/

/********************************************************************\

 *  FACILITY:	Font Librarian I/O, version 1.0

 *  FUNCTIONAL DESCRIPTION:

 	These utility functions are used for handling i/o for the font
 	librarian.

 *  ENVIRONMENT: ??

 *  AUTHOR:	M. Futch		DATE:	29-April-1985

 *  MODIFICATIONS:

    	M. Futch	DATE:	NOV-1985

	    Changed the open, close, read, and write routines
    	    (IB,CLOSELIB,READ_T,READ_FH,READ_CDT,rREADBLK,
	    WRITEBLK,WRT_TO_FLIB) to be more generic by allowing
    	    additional arguments - file control block and input/
    	    output buffer.  Added routine DELETELIB.  These changes
	    allow more flexibility within the font software.  This
	    also eliminates having duplicate routines within the
    	    software.

\********************************************************************/

/* 
$Log: io.c,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:19  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:36  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:30  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:26  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:31  root
 * COMMENT : Corresponds to Rel201.7 in 2.0.1 RCS
 *
 * Revision 201.7  1992/08/04  15:01:17  grnuc20
 * COMMENT : fixed build compilation error
 *
 * Revision 201.6  1992/07/13  13:47:26  tim
 * COMMENT : added Log variable
 *
*/

#include "offset_pos.h"
#include  "exsysdep.h"
#include  "flib_common.h"
#include  "struct.h"
#include  "msg.h"
#include  <stdio.h>


/********************************************************************\

 *  NAME:	read_fot - reads at the position of the next font offset
			   table

 *  SYNOPSIS:

	int read_fot ( fcb, ft_first, ft_last, blk_fot, byt_fot,
			fnt_off_tbl, next_fot, flib_buf )

	FILE	*fcb;		Font library file control block.
    	short	*ft_first;	First font number in font offset table.
    	short	*ft_last;	Last font number in font offset table.
    	long    *blk_fot;	Block number at beginning of font
				offset table.
    	long    *byt_fot;	Byte number at beginning of font offset
				table.
    	long 	fnt_off_tbl[];	Font offsets from font offset table.
    	long    *next_fot;	Offset to next font offset table.
    	short 	flib_buf[];	Buffer to hold font library.

 *  DESCRIPTION:

	This function determines the block and byte number of the next
	font offset table and reads at that position.  It then initializes
	the pointer to the font offset table structure.  Then it determines
	the first and last font in the table and loads FNT_OFF_TBL []
	with the offsets in the font offset table.  It then initializes
	the NEXT_FOT offset to prepare for the next read.  If this value
	is equal to zero, then this is the last node of fonts in the font
	library.


 *  GLOBAL DATA BEING CHANGED:

	struct 	*fot_o_ptr

 *  RETURN VALUE:

    	RMS status

 *  NOTES:

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

    	M. Futch	DATE:	NOV-1985

	    Changed the routine to be more generic by allowing
	    additional arguments - file control block and input/
	    output buffer (FCB & FLIB_BUF).

\********************************************************************/
int read_fot ( fcb, ft_first, ft_last, blk_fot, byt_fot, fnt_off_tbl,
    		next_fot, flib_buf )

FILE	*fcb;			/* address of FILE pointer variable */
short	*ft_first;		/* first font # in font offset table */
short	*ft_last;		/* last font # in font offset table */
long    *blk_fot;		/* block # at beg of font offset table */
long    *byt_fot;		/* byte # at beg of font offset table */
long 	fnt_off_tbl[];		/* font offsets from font offset table */
long    *next_fot;		/* offset to next font offset table */
short 	flib_buf[];		/* buffer to hold font library */
    
{
#define FOT_BUFSIZ 1024
       extern font_offset_table *Fot_o_ptr;
#ifdef BIG_ENDIAN
       font_offset_table x_Fot_o_ptr;
       font_offset_table *XFot_o_ptr;
#endif

       void	init_fot_tbl();
       long	fot_offset;		/* offset in buffer to font offset table */
       int	status = FALSE;
       static short    first_time = TRUE/*,counter*/;

#ifdef BIG_ENDIAN
       XFot_o_ptr = &x_Fot_o_ptr;
#endif

/* Shouldn't first_time be static? dmb:2/27/90 */
       if ( !first_time)
       {
         free(Fot_o_ptr);
       }
       first_time = FALSE; /* removed else */

   /* This shouldn't be here. We'll never free. dmb:2/27/90
       else
       {
         first_time = FALSE;
       }
*/

 if ( *next_fot >= 0 )
	{
	*blk_fot += ( *next_fot + *byt_fot ) / 512;
        *byt_fot = ( *next_fot + *byt_fot ) % 512;
	}
    else
    	{
    	*blk_fot += ( *next_fot - (512 - *byt_fot) ) / 512;
    	*byt_fot = 512 + ( *next_fot - (512 - *byt_fot) ) % 512;
    	}

    status = readblk ( fcb, *blk_fot, FOT_BUFSIZ, flib_buf );
    if ( !status )
    	{
	 fot_offset = *byt_fot;
	 Fot_o_ptr = (font_offset_table *) calloc(1,sizeof(font_offset_table));

         /* Can't be sure that flib_buf[fot_offset/2] is on a long boundary */

         memcpy(Fot_o_ptr,&flib_buf[fot_offset/2],sizeof(font_offset_table));
#ifdef BIG_ENDIAN
	 XFot_o_ptr->first_font = Fot_o_ptr->first_font;
	 Xconv_short(&XFot_o_ptr->first_font);

	 XFot_o_ptr->last_font = Fot_o_ptr->last_font;
	 Xconv_short(&XFot_o_ptr->last_font);

	 *ft_first = XFot_o_ptr->first_font;
	 *ft_last = XFot_o_ptr->last_font;
#else
	 *ft_first = Fot_o_ptr -> first_font;
	 *ft_last = Fot_o_ptr -> last_font;
#endif

	 init_fot_tbl ( fnt_off_tbl, *ft_first, *ft_last );
#ifdef BIG_ENDIAN
	 XFot_o_ptr->next_node = Fot_o_ptr->next_node;
	 Xconv_int(&XFot_o_ptr->next_node);
	 *next_fot = (long)XFot_o_ptr->next_node;
#else
	 *next_fot = Fot_o_ptr -> next_node;
#endif
    	}
#ifdef DEBUG
printf("read_fot:ft_first = %d\n",*ft_first);
printf("read_fot:ft_last = %d\n",*ft_last);
printf("read_fot:blk_fot = %d\n",*blk_fot);
printf("read_fot:byt_fot = %d\n",*byt_fot);
printf("read_fot:fnt_off_tbl[0] = %d\n",fnt_off_tbl[0]);
printf("read_fot:next_fot = %d\n",*next_fot);
#endif 

    return (status);
}


/********************************************************************\

 *  NAME:	init_fot_tbl - Initializes table with offsets to fonts

 *  SYNOPSIS:

	void 	init_fot_tbl ( fnt_off_tbl, ft_first, ft_last )

    	long	fnt_off_tbl[];	Offsets to the fonts in this node.
    	short	ft_first;	First font number in this node.
    	short 	ft_last;	Last font number in this node.

 *  DESCRIPTION:

	Initializes FNT_OFF_TBL[] with the font offset table's
	offsets to fonts in this node.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:	none

 *  NOTES:

	This routine is performed so that you may have easy access to
	all of the fonts in this particular node.  Saving the offsets
	prevents you from having to read at the position of the font
	offset table each time you wish to access one of the fonts in
	this node.

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

\********************************************************************/
void init_fot_tbl ( fnt_off_tbl, ft_first, ft_last )

int	fnt_off_tbl[];				/* offsets to fonts in this node */
short	ft_first;				/* first font # in this node */
short 	ft_last;				/* last font # in this node */

{
extern font_offset_table *Fot_o_ptr;

#ifdef BIG_ENDIAN
       font_offset_table x_Fot_o_ptr;
       font_offset_table *XFot_o_ptr;
#endif

short i;

#ifdef BIG_ENDIAN
       XFot_o_ptr = &x_Fot_o_ptr;
#endif

     for ( i = 0;  i  <=  ft_last - ft_first;  i++ )
     {
#ifdef BIG_ENDIAN
       	XFot_o_ptr->fnt_hdr_ptr[i] = Fot_o_ptr->fnt_hdr_ptr[i];
       	Xconv_int(&XFot_o_ptr->fnt_hdr_ptr[i]);
       	fnt_off_tbl[i] = XFot_o_ptr->fnt_hdr_ptr[i];
#else
       	fnt_off_tbl[i] = Fot_o_ptr -> fnt_hdr_ptr[i];
#endif
     } 
}    



/********************************************************************\

 *  NAME:	read_fh - reads at the position of the next font header

 *  SYNOPSIS:

	int read_fh ( fcb, ft_first, num_font, blk_fh, byt_fh,
		       blk_fot, byt_fot, fnt_off_tbl, flib_buf )

	long	*fcb;		Font library file control block.
    	short   ft_first;	First font number in font offset table.
    	short   num_font;	Current font number.
    	long    *blk_fh;	Block number at beginning of font header.
    	long    *byt_fh;	Byte number at beginning of font header.
    	long    blk_fot;	Block number at beginning of font offset
				table.
    	long    byt_fot;	Byte block at beginning of font offset
				table.
    	long    fnt_off_tbl[];	Offsets to fonts in this node.
    	short   flib_buf[];	Buffer to hold font library.

 *  DESCRIPTION:

	This function determines the block and byte number of the next
	font header and reads at that position.  It then initializes 
	the pointer to the font header structure.

 *  GLOBAL DATA BEING CHANGED:

	struct 	*Fh_o_ptr

 *  RETURN VALUE:

	RMS status

 *  NOTES:

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

    	M. Futch	DATE:	NOV-1985

	    Changed the routine to be more generic by allowing
	    additional arguments - file control block and input/
	    output buffer (FCB & FLIB_BUF).

\********************************************************************/
int read_fh ( fcb, ft_first, num_font, blk_fh, byt_fh, blk_fot,
	       byt_fot, fnt_off_tbl, flib_buf )

FILE	*fcb;			/* address of FILE pointer variable */
short   ft_first;		/* first font # in font offset table */
short   num_font;		/* current font number */
long    *blk_fh;		/* block # at beg of font header */
long    *byt_fh;	 	/* byte # at beg of font header */
long    blk_fot;		/* block # at beg of font offset table */
long    byt_fot;		/* byte # at beg of font offset table */
long    fnt_off_tbl[];		/* offsets to fonts in this node */
short   flib_buf[];		/* buffer to hold font library */

{
#define FH_BUFSIZ 4096
extern font_header 	*Fh_o_ptr;	/* font header ptr */

      long	fh_offset;      	/* font header offset */
      int	status = FALSE;
      
     *blk_fh = blk_fot + ( fnt_off_tbl[num_font - ft_first] + byt_fot ) / 512;
     *byt_fh = ( fnt_off_tbl[num_font - ft_first] + byt_fot ) % 512;
     status = readblk (fcb, *blk_fh, FH_BUFSIZ,flib_buf );	    /* read next four blocks */
     
      if ( !status )
    	{
	 fh_offset = *byt_fh;
	 align_fh(&flib_buf[fh_offset/2]);
        }

    return (status);
}


/********************************************************************\

 *  NAME:	read_cdt - reads at the position of the next character
			   dimension table

 *  SYNOPSIS:

	int read_cdt ( fcb, blk_cdt, byt_cdt, next_cdt, next_ccot,
			fnt_type, num_dim, flib_buf )

	long	*fcb;		Font library file control block.
    	long	*blk_cdt;	Block number at beginning of char dimension
				table.
    	long	*byt_cdt;	Byte number at beginning of char dimension
				table.
    	long 	*next_cdt;	Offset to next char dimension table table.
    	long	*next_ccot;	Offset to next char code offset table.
    	short	fnt_type;	Font type - BYTE = 1; WORD = 2;.
    	short	num_dim;	Number of dimensions present for the font.
    	short 	flib_buf[];	Buffer to hold font library.

 *  DESCRIPTION:

	This function determines the block and byte number of the next
	character dimension table and reads at that position.  It then
	initializes the pointer to the character dimension table
	structure and the character code offset table structure.  Then
	it initializes the NEXT_CDT and NEXT_CCOT offsets to prepare
	for the next read.  If these values are equal to zero, then this
	is the last node of characters in the font.

 *  GLOBAL DATA BEING CHANGED:

	struct 	*Cdt_o_ptr
	struct 	*Ccot_o_ptr

 *  RETURN VALUE:

	RMS status

 *  NOTES:

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

    	M. Futch	DATE:	NOV-1985

	    Changed the routine to be more generic by allowing
	    additional arguments - file control block and input/
	    output buffer (FCB & FLIB_BUF).

\********************************************************************/
int read_cdt ( fcb, blk_cdt, byt_cdt, next_cdt, next_ccot, fnt_type,
    		num_dim, flib_buf )

FILE    *fcb;			/* font library file control block */
long	*blk_cdt;		/* block # at beg of char dimension table */
long	*byt_cdt;	 	/* byte # at beg of char dimension table */
long 	*next_cdt;		/* offset to next char dimension table table */
long	*next_ccot;		/* offset to next char code offset table */
short	fnt_type;		/* font type - BYTE=1; WORD=2; */
short	num_dim;		/* # of dimensions present */
short	flib_buf[];		/* buffer to hold font library */

{
#define CDT_BUFSIZ 4096
extern font_header	*Fh_o_ptr;
extern char_dim_table 	*Cdt_o_ptr;	/* char dimension table ptr */
extern char_code_off_tbl *Ccot_o_ptr;	/* char code offset table ptr */

#ifdef BIG_ENDIAN
       char_dim_table 	 x_Cdt_o_ptr;	
       char_dim_table 	 *XCdt_o_ptr;	
       char_code_off_tbl x_Ccot_o_ptr;	
       char_code_off_tbl *XCcot_o_ptr;	
#endif


long    cdt_offset;				/* char dimension table offset */
long	ccot_offset;				/* char code offset table offset */
int	status = FALSE;
static  short first_time = TRUE;

#ifdef BIG_ENDIAN
       XCdt_o_ptr = &x_Cdt_o_ptr;	
       XCcot_o_ptr = &x_Ccot_o_ptr;	
#endif

    if ( ! first_time) 
              {
               free(Cdt_o_ptr);
               free(Ccot_o_ptr);
              }
        else
               first_time = FALSE;
    
      *blk_cdt += ( *next_cdt + *byt_cdt ) / 512;
      *byt_cdt = ( *next_cdt + *byt_cdt ) % 512;
    
      status = readblk ( fcb, *blk_cdt, CDT_BUFSIZ, flib_buf );	    /* read next four blocks */
      if ( !status )
    	{
	 cdt_offset = *byt_cdt;
         /*	Cdt_o_ptr = &flib_buf[cdt_offset/2];*/
         Cdt_o_ptr=(char_dim_table *) calloc(1,sizeof(char_dim_table)+20);
         memcpy(Cdt_o_ptr,&flib_buf[cdt_offset/2],6);
         memcpy(&Cdt_o_ptr->dim_data.wrd[0],&flib_buf[cdt_offset/2]+3,
                           sizeof(char_dim_table));
#ifdef BIG_ENDIAN
	 XCdt_o_ptr->first_char = Cdt_o_ptr->first_char;
	 Xconv_short(&XCdt_o_ptr->first_char);

	 XCdt_o_ptr->last_char = Cdt_o_ptr->last_char;
	 Xconv_short(&XCdt_o_ptr->last_char);

      	 ccot_offset = ( XCdt_o_ptr->last_char - XCdt_o_ptr->first_char + 1 )
		      * num_dim * fnt_type + 6 + cdt_offset;
#else
      	 ccot_offset = ( Cdt_o_ptr -> last_char - Cdt_o_ptr -> first_char + 1 )
		      * num_dim * fnt_type + 6 + cdt_offset;
#endif
         /*	Ccot_o_ptr = &flib_buf[ccot_offset/2];*/
         Ccot_o_ptr= (char_code_off_tbl *) calloc(1,sizeof(char_code_off_tbl));
         memcpy(Ccot_o_ptr,&flib_buf[ccot_offset/2],sizeof(char_code_off_tbl));
#ifdef BIG_ENDIAN
   	 XCdt_o_ptr->next_node = Cdt_o_ptr->next_node;
   	 Xconv_short(&XCdt_o_ptr->next_node);
   	 *next_cdt = XCdt_o_ptr->next_node;

    	 XCcot_o_ptr->next_node = Ccot_o_ptr->next_node;
    	 Xconv_short(&XCcot_o_ptr->next_node);
    	 *next_ccot = XCcot_o_ptr->next_node;
#else
   	 *next_cdt = Cdt_o_ptr -> next_node;
    	 *next_ccot = Ccot_o_ptr -> next_node;
#endif
    	}

    return (status);
}



/********************************************************************\

 *  NAME:	readblk - reads a designated number of bytes at the
			  designated block number

 *  SYNOPSIS:

	int readblk ( fcb, vbn, siz, buf )

    	FILE	*fcb;		File control block.
	long	vbn;		Virtual block number for read.
    	long  	siz;		Number of bytes to read into buffer.
    	short	buf[];		Buffer to hold blocks read.

 *  DESCRIPTION:

	This function reads a designated number of bytes from the
    	file indicated by the FCB at the designated block number,
    	and places it in BUF.


 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

	RMS status

 *  NOTES:

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

    	M. Futch	DATE:	NOV-1985

	    Changed the routine to be more generic by allowing
	    additional arguments - file control block and input/
	    output buffer (FCB & BUF).

    	M. Futch	DATE:	08-MAR-1986

    	    Changed status = FALSE; to be status = FONT_READERR;.
    	    This will allow the correct status to be returned to
    	    the calling routine.

\********************************************************************/
int readblk ( fcb, vbn, siz, buf )

FILE    *fcb;			/* file control block */
long	vbn;			/* virtual block number */
long  	siz;			/* # of bytes to read into BUF */
short	buf[4096];			/* buffer to hold bytes read */

{
/*static long	blk_num;*/
       long	offset;  
       int	nitems;
       short   data_length;
       int	status = FALSE;
       int ptrname = 0;
       int      data_read;
       offset = (vbn-1) * 512;
    
   status=fseek(fcb,offset,ptrname); /*Set file pointer vbn */
     
    if ( status ) status = FONT_READERR;
    	else
         { 	
          data_length=1;/*read nitems of 1 byte size */
          nitems=siz;
          data_read =  fread( buf,data_length, nitems ,fcb );
         } 
  if (!data_read )
    	{
    	status = FONT_READERR;
    	}

    return (status);
}


/********************************************************************\

 *  NAME:    writeblk - writes a designated number of bytes at the
               designated block number

 *  SYNOPSIS:

    int writeblk ( fcb, vbn, siz, buf )
    
        FILE    *fcb;        File control block.
    
        long     vbn;        Virtual block number for write.
        long    siz;        Number of bytes to write to font
                  library.
        short    buf[];        Buffer that contains the data.

 *  DESCRIPTION:

    This function writes a designated number of bytes from BUF
    at the designated block number in the font library indicated
        by the file control block (FCB).

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

    RMS status

 *  NOTES:

 *  AUTHOR:    M. Futch    DATE:    29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

        M. Futch    DATE:    NOV-1985

        Changed the routine to be more generic by allowing
        additional arguments - file control block and input/
        output buffer (FCB & BUF).

        M. Futch    DATE:    08-MAR-1986

            Changed status = FALSE; to be status = FONT_WRITEERR;.
            This will allow the correct status to be returned to
            the calling routine.

\********************************************************************/
int writeblk ( fcb, vbn, siz, buf )

FILE    *fcb;                /* file control block */
long     vbn;                /* virtual block number */
long    siz;                /* # of bytes to write to font lib */
short    buf[];                /* buffer that contains data */

{
int    status = FALSE;
    short data_length;
    int nitems;
    long offset;
    int ptrname=0;
    int data_writ;
    
    nitems=siz;
    offset=(vbn-1)*512; /*position file pointer to vbn */
    data_length=1;
    nitems=siz;

    status=fseek(fcb,offset,ptrname);
    if (status)
    {
      status=FONT_WRITEERR;
    }
    else
    {
      data_writ=fwrite( buf,data_length,nitems,fcb);
    }

    if ( !data_writ )
    {
      status = FONT_WRITEERR;
    }


    return (status);
}
    


/********************************************************************\

 *  NAME:	wrt_to_flib - writes to font library

 *  SYNOPSIS:

	int wrt_to_flib ( fcb, inbuf, num_byt, flush_buf, blk_num )
    
    	FILE	*fcb;		File control block.
    	short	inbuf[];	Input buffer that contains the data
    				to be written to the font library.
    	long	num_byt;	Number of bytes in new font library
				buffer - BUFFER[].
    	bool	flush_buf;	Indicates to flush output buffer -
    				OUTBUF[].
    	long	blk_num;	Initial block number to begin writing.

 *  DESCRIPTION:

	This routine buffers up the material to be written to the font
	library and then writes it to the font library.  If it is the
	first time thru the CUR_BLK is set to BLK_NUM.  It then checks
	to see if the number of bytes in the new font library buffer will
	fit into the output buffer.  If not, the the number of bytes that
	will fit into the current output buffer are put there.  The output
	buffer is then written to the font library.  The remaining number 
	of bytes in the new font library buffer are put into the output
	buffer.  If the FLUSH_BUF variable is set, the output buffer is
	flushed to the font library.

    	IF ( not flush_buf  and  num_byt == 0 )
    	  set cur_blk equal to initial block # to begin writing
    	  set fst_time_thru equal to false
    	ELSE
    	  IF ( first time thru routine )
    	    set outdex equal to 0
    	    set cur_blk equal to initial block # to begin writing
    	    set fst_time_thru equal to 0
    	  ENDIF
    	  IF ( flush_buf )
    	    write outbuf out to disk
    	    set fst_time_thru equal to true
    	  ELSE
    	    IF ( outdex + num_byt/2 >= 4096 )
    	      
    	    
    		WHILE ( cont_writing )
    		  update nxt_blk by 8 blocks
    		  set nbyt to be equal to 8192 (8 blocks)
    		  write outbuf out to disk
    		  IF ( number of bytes left in inbuf is >= 8 blocks )
    		    set cur_blk equal to nxt_blk
    		    move the next 8 blocks of data from inbuf to outbuf
    		    update flt_ptr by 4096 words (8 blocks)
    		    decrease byt_left by 8192 bytes (8 blocks)
    		  ELSE
    		    set cont_writing to FALSE
    		  ENDIF
    		ENDWHILE

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

	RMS status

 *  NOTES:

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

    	M. Futch	DATE:	NOV-1985

	    Changed the routine to be more generic by allowing
	    additional arguments - file control block and input/
	    output buffer (FCB & INBUF).  Also, changed calls to
    	    BLK_WRITE to be calls to WRITEBLK and deleted the
    	    error messages associated with BLK_WRITE.

    	M. Futch	DATE:   FEB-1986

    	    Changed the WHILE loops to be calls to the FORTRAN
    	    function MOVE and then updated the buffer pointers.  I
    	    deleted NWRD and instead used NUM_BYT / 2, I changed
    	    WRD_LEFT to be BYT_LEFT, and I changed WRD_TO_MOVE to be
    	    BYT_TO_MOVE to facilitate the FORTRAN function MOVE.  I
    	    added a WHILE loop to enable writing out OUTBUF to disk
    	    more than one time, if is necessary.  The WHILE loop
    	    continues writing out OUTBUF until there is less than 8
    	    blocks left in inbuf.

    	M. Futch	DATE:	11-JUL-1986

    	    Changed the call to the subroutine MOVE to be a call to
    	    the system routine LIB$MOVC3.  This will increase the
    	    font librarian's efficiency.

\********************************************************************/
int wrt_to_flib ( fcb, inbuf, num_byt, flush_buf, blk_num )
    
FILE	*fcb;				/* file control block */
short	inbuf[];			/* input buffer that contains the data to be written to the font library */
long	num_byt;			/* # of bytes in new font lib buffer */
bool	flush_buf;			/* indicates to flush buffer */
long	blk_num;			/* initial block # to begin writing */

{
#define BLOCK 255
#define OUTLEN 4096

static short	cur_blk;			/* current block #  to write at */
static short	nxt_blk = 0;			/* next block # to write at */
static short	outbuf[OUTLEN];			/* 12 blocks of output buffer */
       short	*flt_ptr;			/* flo
       ating pointer through new font lib buffer */

static long	outdex;				/* index for outbuf */
/*
       long	i,j,k;
*/
static long	nbyt = 0;			/* # of bytes to be written to the disk */
       long	byt_to_move;			/* # of bytes to move to outbuf before writing to disk */
       long	byt_left;			/* # of bytes to move to outbuf after writing to disk */

       bool	cont_writing = TRUE;		/* continue writing to font library */
static bool	fst_time_thru = TRUE;		/* indicates first time thru routine */
       int	status = FALSE;

    if ( (!flush_buf)  &&  num_byt == 0  )
    	{
    	cur_blk = blk_num;
    	fst_time_thru = FALSE;
    	}
    else
    	{
	if ( fst_time_thru )
	    {
	    outdex = 0;
	    cur_blk = blk_num;
	    fst_time_thru = FALSE;
	    }

	flt_ptr = &inbuf[0];

	if ( flush_buf )
	    {
	    nbyt = outdex  * 2;
    	    status = writeblk( fcb, (long)cur_blk, nbyt, outbuf );
	    if ( !status )
		fst_time_thru = TRUE;
	    }
	else
	    {
	    if ( (outdex + (num_byt/2)) >= OUTLEN )
		{
		byt_to_move = (OUTLEN - outdex) * 2;
		byt_left = num_byt - byt_to_move;
    		memcpy(&(outbuf[outdex]),flt_ptr,byt_to_move);
    		outdex += (byt_to_move / 2);
    		flt_ptr += (byt_to_move / 2);
    		while ( cont_writing )
    		    {
		    nxt_blk = cur_blk + outdex / BLOCK;
		    nbyt = outdex * 2;
		    status = writeblk( fcb, (long)cur_blk, nbyt, outbuf );
    		    if ( byt_left >= OUTLEN * 2 )
    			{
    			cur_blk = nxt_blk;
    			memcpy(outbuf,flt_ptr,nbyt);
    			flt_ptr += OUTLEN;
    			byt_left -= (OUTLEN * 2);
    			}
    		    else
    			cont_writing = FALSE;
    		    }
    		memcpy(outbuf,flt_ptr,byt_left);
    		flt_ptr += (byt_left / 2);
		outdex = (byt_left / 2);
		cur_blk = nxt_blk;
		}
	    else
		{
    		memcpy(&(outbuf[outdex]),flt_ptr, num_byt);
    		flt_ptr += (num_byt/2);
    		outdex += (num_byt/2);
		}
	    }
    	}
    return (status);
}



/********************************************************************\

 *  NAME:	fst_vec - retrieves the first character's vectors from
			  a scratch file

 *  SYNOPSIS:

	int	fst_vec ( stroke_cb, str_buf, amt_used, str_vbn,
			  str_ind, str_siz )

		 FILE	*stroke_cb	File control block.
		 short	str_buf[]	Buffer used for reading in cell library.
    		 long	*amt_used	Number of words read into buffer.
		 long	*str_vbn	Virtual block number.
	unsigned long	*str_ind	Index into STR_BUF.
    		 long	str_siz		Number of bytes in STR_BUF.

 *  DESCRIPTION:

	This routine retrieves the first character's vectors from a scratch
	file.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

	RMS status

 *  NOTES:

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

    	M. Futch	DATE:	03-MAR-1986

    	    Changed routine to accept an additional argument,
    	    STR_SIZ.  STR_SIZ contains the number of bytes in
    	    STR_BUF.  STR_SIZ is used in place of BUFSIZE.  This
    	    change allows STR_BUF to allocated dynamically in the
    	    calling routine.

\********************************************************************/
/* ARGSUSED */
int fst_vec ( stroke_cb, str_buf, amt_used, str_vbn, str_ind, str_siz )

    	 FILE *stroke_cb;		/* control block */
    	 short	str_buf[];		/* buffer used for reading in cell lib */
    	 long	*amt_used;		/* # of words read into buffer */
    	 long	*str_vbn;		/* virtual block number */
unsigned long	*str_ind;		/* buffer index */
    	 long	str_siz;		/* number of bytes in STR_BUF */
 
    {
#define	FST_BUFLEN 2048			/* # of words in 4 blocks */
/*
int	bufsize = FST_BUFLEN * 2;		 # of bytes to be read in 
*/
int	status = FALSE;

    *str_vbn = 1;
    *str_ind = 0;            
    status = readblk ( stroke_cb, *str_vbn, str_siz, str_buf );
    if ( (!status) )
    	*amt_used = str_siz / 2;

    return (status);
}



/********************************************************************\

 *  NAME:	next_vec - retrieves the next character's vector from
			   a scratch file

 *  SYNOPSIS:

	int	next_vec ( stroke_cb, str_buf, chr_num, str_vbn,
    			   str_ind )

		 FILE   *stroke_cb	File control block.
		 short	str_buf[]	Buffer containing elements.
    		 short	chr_num		Current character number.
		 long	*str_vbn	Virtual block number.
	unsigned long	*str_ind	Index to STR_BUF.
    		 long	str_siz		Number of bytes in STR_BUF.

 *  DESCRIPTION:

	This routine checks to see if the next character's vectors are
    	in the buffer.  If they are, the vectors are returned in STR_BUF.
	If not, a bad status is returned.

 *  GLOBAL DATA BEING CHANGED:

 *  RETURN VALUE:

	RMS status

 *  NOTES:

 *  AUTHOR:	M. Futch	DATE:	29-APR-1985

 *  SEE ALSO:

 *  MODIFICATIONS:

    	M. Futch	DATE:	03-MAR-1986

    	    Changed routine to accept an additional argument,
    	    STR_SIZ.  STR_SIZ contains the number of bytes in
    	    STR_BUF.  STR_SIZ is used in place of BUFSIZE.  This
    	    change allows STR_BUF to allocated dynamically in the
    	    calling routine.

\********************************************************************/
/* ARGSUSED */
int next_vec ( stroke_cb, str_buf, chr_num, amt_used, str_vbn,
    		str_ind, str_siz )

    	 FILE  *stroke_cb;		/* file control block */
    	 short  str_buf[];		/* buffer used for reading in cell lib */
    	 short  chr_num;		/* current char number */
    	 long   *amt_used;		/* # of words read into buffer - DEL */
    	 long   *str_vbn;		/* virtual block number - DONT PASS IN */
unsigned long   *str_ind;		/* buffer index */
    	 long	str_siz;		/* number of bytes in STR_BUF */

    {
#define	NEXT_BUFLEN 2048				/* # of words in 4 blocks */
#define	WRDSBLK 256
extern unsigned long	Offset_pos[256][2];

    	 /*long   bufsize = NEXT_BUFLEN * 2;*/		/* # of bytes in buffer */
    	 long   i;				/* used to update str_vbn */
unsigned long   idx;				/* buffer index */
    	 long   wtf;				/* words to follow */

int    	status = FALSE;

    wtf = 0;
    wtf = Offset_pos[chr_num][1] / 2;
    *str_ind = Offset_pos[chr_num][0];
    idx = *str_ind;

/*    if ( *str_ind  >  (*str_vbn - 1) * WRDSBLK   &&
    	 *str_ind + wtf - 1  <=  (*str_vbn - 1) * WRDSBLK + *amt_used )
    	idx = idx - (*str_vbn - 1) * WRDSBLK;
    else
    	{*/
    	*str_vbn = idx / WRDSBLK + 1;
    	i = idx / WRDSBLK;
    	idx = idx - (i * WRDSBLK);
	if ( idx <= 0 )
	    {
	    idx = idx + WRDSBLK;
	    *str_vbn -= 1;
	    }
    	status = readblk ( stroke_cb, *str_vbn, str_siz, str_buf );
/*    	if ( !status )
    	    *amt_used = str_siz / 2;
	}*/

    *str_ind = idx - 1;

    return (status);
}
int align_cdt (buf_ptr)

short *buf_ptr;

{
        extern char_dim_table *Cdt_o_ptr;
        static short fst_time=1;

        if (!fst_time)
        {
          free(Cdt_o_ptr);
        }
        fst_time=0;
	Cdt_o_ptr = (char_dim_table *) calloc(1,sizeof(char_dim_table));
	memcpy(Cdt_o_ptr,buf_ptr,6);
	memcpy(&Cdt_o_ptr->dim_data.byt[0],buf_ptr+3,2560);
        return(TRUE);
}
int align_fh (buf_ptr )

short *buf_ptr;

{
        extern font_header 	*Fh_o_ptr;	/* font header ptr */

        static short fst_time=1;
    
        if (!fst_time)
        {
          free(Fh_o_ptr);
        }
        fst_time=0;
        Fh_o_ptr = (font_header *) calloc(1,(sizeof(font_header)+20));
        memcpy(Fh_o_ptr,buf_ptr,102);
        memcpy(&Fh_o_ptr->x_origin,buf_ptr+51,30);
        memcpy(&Fh_o_ptr->res_0,buf_ptr+66,58);
        memcpy(&Fh_o_ptr->vcot_ptr,buf_ptr+95,16);
        return(TRUE);
                 
    
}

int align_fot (buf_ptr )

short buf_ptr[];

{
extern font_offset_table *Fot_o_ptr;

    static short fst_time=1;
    
    if (!fst_time)
    {
      free(Fot_o_ptr);
    }
    fst_time=0;
    Fot_o_ptr = (font_offset_table *) calloc(1,sizeof(font_offset_table));
    memcpy(Fot_o_ptr,buf_ptr,4);
    memcpy(&Fot_o_ptr->next_node,buf_ptr+2,1028);
    return(TRUE);
             

   }
int align_lh (buf_ptr )

short *buf_ptr;

{

    extern library_header 	*Lh_o_ptr;	
     
    static  short fst_time=1;
    if (!fst_time)
    {
      free(Lh_o_ptr);
    }
    fst_time=0;
    Lh_o_ptr = (library_header *) calloc(1,(sizeof(library_header)+20));
    memcpy(Lh_o_ptr,buf_ptr,186);
    memcpy(&Lh_o_ptr->rec_len,buf_ptr+93,326);
    return(TRUE);
}


int ualign_cdt (buf_ptr,numbytes)

short *buf_ptr;
long numbytes;
{
        extern char_dim_table *Cdt_o_ptr;

	memcpy(buf_ptr,Cdt_o_ptr,6);
	memcpy(buf_ptr+3,&Cdt_o_ptr->dim_data.byt[0],numbytes);
        return(TRUE);
}

int ualign_cdt_n (buf_ptr,numbytes)

short *buf_ptr;
long numbytes;
{
    extern char_dim_table *Cdt_n_ptr;
/*    char_dim_table *Cdt_n_ptr; */

    memcpy(buf_ptr,Cdt_n_ptr,6);
    memcpy(buf_ptr+3,&Cdt_n_ptr->dim_data.byt[0],numbytes);
    return(TRUE);
}

int ualign_fh (buf_ptr )

short *buf_ptr;

{
    extern font_header 	*Fh_o_ptr;	/* font header ptr */

    memcpy(buf_ptr,Fh_o_ptr,102);
    memcpy(buf_ptr+51,&Fh_o_ptr->x_origin,30);
    memcpy(buf_ptr+66,&Fh_o_ptr->res_0,58);
    memcpy(buf_ptr+95,&Fh_o_ptr->vcot_ptr,16);
    return(TRUE);
}

int ualign_fh_n (buf_ptr)

short *buf_ptr;

{
    extern font_header 	*Fh_n_ptr;	/* font header ptr */
/*    font_header 	*Fh_n_ptr;	* font header ptr */

    memcpy(buf_ptr,Fh_n_ptr,102);
    memcpy(buf_ptr+51,&Fh_n_ptr->x_origin,30);
    memcpy(buf_ptr+66,&Fh_n_ptr->res_0,58);
    memcpy(buf_ptr+95,&Fh_n_ptr->vcot_ptr,16);
    return(TRUE);
}

int ualign_fot (buf_ptr )

short buf_ptr[];

{
    extern font_offset_table *Fot_o_ptr;

    memcpy(buf_ptr,Fot_o_ptr,4);
    memcpy(buf_ptr+2,&Fot_o_ptr->next_node,1028);
    return(TRUE);
}

int ualign_lh (buf_ptr )

short *buf_ptr;

{
    extern library_header 	*Lh_o_ptr;	
    
    memcpy(buf_ptr,Lh_o_ptr,186);
    memcpy(buf_ptr+93,&Lh_o_ptr->rec_len,326);
    return(TRUE);
}




