/*
$Log: flibtpa.h,v $
Revision 1.1.1.1  2001/12/17 22:39:13  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:16:15  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:32  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:27  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:53:20  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:31:26  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  19:17:12  tim
 * COMMENT : added Log variable
 *
*/
#include "local.h"

	typedef struct 
	    {

	/*  command qualifiers */

	    union
		{
		struct
		    {
		    bits	q_compress	: 1 ;
		    bits	q_copy		: 1 ;
		    bits	q_create	: 1 ;
		    bits	q_delete	: 1 ;
		    bits	q_extract	: 1 ;
		    bits	q_insert	: 1 ;
		    bits	q_list		: 1 ;
		    bits	q_modify	: 1 ;
		    bits	q_replace	: 1 ;
		    bits	q_dump		: 1 ;
		    } c;
		long    q ;
		} commands ;

	/* insert qualifiers */

	    union
		{
		struct
		    {
		    bits	ins_class	: 1 ;
		    bits	ins_descr	: 1 ;
		    bits	ins_dimen	: 1 ;
		    bits	ins_fastf	: 1 ;
		    bits	ins_height	: 1 ;
		    bits	ins_name	: 1 ;
		    bits	ins_number	: 1 ;
		    bits	ins_origin	: 1 ;
		    bits	ins_toler	: 1 ;
		    bits	ins_vsize	: 1 ;
		    bits	ins_kludge	: 1 ;
		    bits	ins_scale	: 1 ;
		    bits	ins_unused1	: 4 ;
		    bits	idt_font	: 1 ;
		    bits	ins_unused2	: 7 ;
		    bits	dsp_full	: 1 ;
		    } i ;
		long	ins ;
	    } insert_qual ;

	/* flag qualifers and keywords */

	    union
		{
		struct
		    {
		    bits	flg_symbol	: 1 ;
		    bits	flg_byte	: 1 ;
		    bits	flg_word	: 1 ;
		    bits	flg_long	: 1 ;
		    bits	flg_fnum	: 1 ;
		    bits	flg_fnam	: 1 ;
		    bits	flg_pattern	: 1 ;
		    } f ;
		long	flags;
	    } command_flags;

	    long	libfil[2];
	    long	celfil[2];
    char    clibnm[256];			/* cell library name */
    char    flibnm[256];			/* font library name */
    char    fontnm[40];			/* font name */
    char    fontdesc[80];			/* font description */


	    long	descr[2];
	    long	dimen;
	    long	height;
	    long	name[2];
	    long	number;
	    long	origin[2];
	    double	scale[2];
	    long	toler;

	    long	font[2];

	    long	scrtch[4];
	    }cmd_qual ;
