/* $Id: vldbgmacros.h,v 1.3 2001/02/20 18:03:30 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loft/include/vldbgmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vldbgmacros.h,v $
 *      Revision 1.3  2001/02/20 18:03:30  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/19 21:18:45  ramarao
 *      *** empty log message ***
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/19/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

#include "bsfreecv.h"
#include "bsfreesf.h"

#define DBG_PROD_NAME  "Loft"

#define DBG_PROD	0x0000004

#include "vIdbgmacros.h"

#define _FREECV( bsrc, pointer )        if( (pointer) ) BSfreecv(  (bsrc), (pointer) )
#define _FREESF( bsrc, pointer )        if( (pointer) ) BSfreesf(  (bsrc), (pointer) )
