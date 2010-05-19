/* $Id: vddrwppl.m,v 1.2 2001/04/27 19:36:08 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddrawing/cmd/vddrwppl.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vddrwppl.m,v $
 *      Revision 1.2  2001/04/27 19:36:08  ylong
 *      TR5120, "Move Drawing View" is not in the pload
 *
 *      Revision 1.1  2001/01/08 19:02:59  art
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/03/00  ah      Created
 *
 ***************************************************************************/

CCIOPT        -Xnoargchk -m -q
#if ISDP_MAKE_SP
scale_option.u

#else
COrename.u
chg_scale.u  
scale_option.u
#endif

