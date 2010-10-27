/* $Id: vdannotppl.m,v 1.4 2001/04/12 22:22:08 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdannot/imp/vdannotppl.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdannotppl.m,v $
 *      Revision 1.4  2001/04/12 22:22:08  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/04/12 22:05:08  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/04/12 21:51:30  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/08 18:59:08  art
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/03/00  ah      Created
 *
 ***************************************************************************/

CCIOPT   -Xnoptrchk -Xnoargchk -m -q
/* fms_annot221.u  */
#if ISDP_MAKE_SP
format_text.u   

#else
format_text.u   
/* PPL SKIP forms_annot.u */
#endif
