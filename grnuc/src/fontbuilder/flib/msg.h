/*	.TITLE		FONTMSG -- MESSAGE FILE	*/
/*	.IDENT		"V8.8.1"	*/
/*	.FACILITY	FONT,18	*/
 
 
 
/*!			INTERGRAPH corporation  1985	*/
 
/*!	INTERGRAPH corporation  assumes NO responsibility for the use	*/
/*!	or reliability of software altered by the user.	*/
 
/*!	The information in this software is subject to change without	*/
/*!	notice  and  should  not  be  construed  as  a  commitment by	*/
/*!	INTERGRAPH corporation.	*/
 
 
 
 
/*!  Facility:	FONT	*/
 
/*!  Functional description:	*/
 
/*!	This module contains the definitions of the message	*/
/*!	parameters used for display and reporting status.	*/
 
 
/*!  Author:	M.Patterson	Creation date:	18-APR-1985	*/
 
/*!  Modified by:	*/
 
/*!	M.FUTCH		9-SEP-1985	*/
 
/*!		Added message for no characters found in cell	*/
/*!		file (NOCHAR) and the character tile box must	*/
/*!		be square for symbol fonts (NOTSQUARE).	*/
 
/*!	M.FUTCH		19-DEC-1985	*/
 
/*!		Added message for character not found in font	*/
/*!		library (CHRNOTFOUND) and error while dumping	*/
/*!		font library (DUMPERR).	*/
 
/*!	M.FUTCH		10-FEB-1986	*/
 
/*!		Added message for font library compressed	*/
/*!		(COMPRESSED),  minimum recoverable space not	*/
/*!		exceeded (MINSPACE), and font library not	*/
/*!		compressed (NOTCOMPRESSED).	*/
 
/*!	M.FUTCH		08-MAR-1986	*/
 
/*!		Added message for error compressing font library	*/
/*!		(COMPRESSERR), font library not created (NOTCREATED)	*/
/*!		and font not deleted from font library (NOTDELETED).	*/

/*
$Log: msg.h,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:23  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:41  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:34  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:39  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:42  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  19:17:23  tim
 * COMMENT : added Log variable
 *
*/
 
 
/*	.BASE		1	*/
/*	.SEVERITY	SUCCESS	*/
#define FONT_ADDED      0       /*<Font added - !UL  !AD>*/
#define FONT_COMPRESSED 0       /*<Font library !AD compressed>*/
#define FONT_CREATED    0       /*<Font library !AD created>*/
#define FONT_DELETED    0       /*<Font deleted - !UL  !AD>*/
#define FONT_REPLACED   0       /*<Font replaced - !UL  !AD>*/

 
/*	.BASE		8	*/
/*	.SEVERITY	INFORMATIONAL	*/
 
#define FONT_TOKEN     80  /*<token \!AD\>*/
#define FONT_FASTFONT  81  /*<Font inserted as fast font>*/
 
 
 
/*	.BASE		40	*/
/*	.SEVERITY	WARNING	*/
 
#define FONT_IVELEM       400  /*<Invalid element encountered - !UL>*/
#define FONT_IVLEV        401  /*<invalid level encountered - !UL>*/
#define FONT_CHRNOTFOUND  402  /*<character DEC!UL not found>*/
#define FONT_NAMNOTFOUND  403  /*<name !AD not found>*/
#define FONT_NUMNOTFOUND  404  /*<number !UL not found>*/
#define FONT_NAMEXIST     405  /*<name !AD already exist>*/
#define FONT_NOELEM       406  /*<no elements found>*/
#define FONT_NORANGBOX    407  /*<character range box(dotted shape) is missing>*/
#define FONT_NOTILEBOX    408  /*<character tile box(solid shape) is missing>*/
#define FONT_NOTSQUARE    409  /*<character tile box(solid shape) is not square>*/
#define FONT_NUMEXIST     410  /*<number !UL already exist>*/
#define FONT_NUMTOOBIG    411  /*<number !UL too large - maximum number is 127>*/
#define FONT_RANGE        412  /*<Coordinates out of range for vector size>*/
  
 
/*	.BASE		64	*/
/*	.SEVERITY	ERROR	*/
 
 
#define FONT_CELL3D     640  /*<3D cell files not allowed>*/
#define FONT_DESCRLEN   641  /*<Font description too long>*/
#define FONT_FILNOTSPEC 642  /*<Cell file specification required>*/
#define FONT_IVVECSIZ   643  /*<Longword vector size not allowed>*/
#define FONT_NAMELEN    644  /*<Font name too long>*/
#define FONT_NOIDENT    645  /*<No name or number specified>*/
#define FONT_SYNERRCMD  646  /*<Syntax error in command line>*/
#define FONT_SYNERRFNT  647  /*<Syntax error in $FONT$ cell>*/
 
/*	.BASE		80	*/
 
/*!	Errors from processing the cells	*/
#define FONT_CELLERR    80  /*<Error processing cell !AD>*/
#define FONT_DUPLCELL   81  /*<Cell is multiply defined>*/
#define FONT_INTBUFOVF  82  /*<Cell has too many vectors>*/
#define FONT_NOCHAR     83  /*<No characters found in cell file>*/
#define FONT_NOTADDED   84  /*<Cell file not added to font library>*/
#define FONT_NOTCELFIL  85  /*<File !AD is not a cell file>*/
#define FONT_PATTOVF    86  /*<Pattern cell is too large>*/
#define FONT_PATTBIN    87  /*<Pattern definition must be binary in X and Y>*/
#define FONT_UNKCELL    88  /*<!AD is not a recognized cell name>*/
 
 
/*	.BASE		100	*/
 
/*!	File/memory allocation related errors	*/
 
#define FONT_CLOSEERR  1000  /*<Error closing file - !AD>*/
#define FONT_CREATE    1001  /*<Error creating work file>*/
#define FONT_OPENIN    1002  /*<Error opening input file - !AD>*/
#define FONT_OPENOUT   1003  /*<Error opening output file - !AD>*/
#define FONT_READERR   1004  /*<Error reading input file - !AD>*/
#define FONT_WRITEERR  1005  /*<Error writing to output file - !AD>*/
#define FONT_MEMERR    1006  /* Error in allocating memory */ 
 
/*	.BASE		128	*/
 
/*!	Errors from font librarian	*/
 
#define FONT_COMPRESSERR    1280  /*<Error compressing font library>*/
#define FONT_DELERR         1281  /*<Error deleting font>*/
#define FONT_DUMPERR        1282  /*<Error dumping font>*/
#define FONT_LIBFULL        1283  /*<!AD contains maximum number of fonts>*/
#define FONT_MINSPACE       1284  /*<minimum recoverable space not exceeded>*/
#define FONT_NOTCOMPRESSED  1285  /*<Font library not compressed>*/
#define FONT_NOTCREATED     1286  /*<Font library not created>*/
#define FONT_NODELETE       1287  /*<fast font cannot be deleted>*/
#define FONT_NUMERR         1288  /*<Error in font number>*/
#define FONT_PREVDEF        1289  /*<Font previously defined>*/
#define FONT_NOTDELETED     1290  /*<Font not deleted from font library>*/
#define FONT_IS_FAST	    1291  /* Font specified is fast font */
 
/*	.BASE		150	*/
/*	.SEVERITY	SEVERE	*/
 
#define FONT_ACCCMDLIN      1500 /*<Error retrieving command line>*/
 
/*	.END	*/
 
 
