/* $Id: VDSstatus.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDSstatus.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSstatus.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
        VDSstatus.C
        
        - Functions to display advancement of sequential process
                
        History :
        
*/

#include <stdio.h>                /* sprintf */
#include "igrtypedef.h"           /* IGRchar, ... */
#include "VDSstatus.h"            /* VDSDP_BY... */
#include "AS_status.h"
#include "msmacros.h"
#include "msdef.h"

#define AS_DEBUG

VDSshow_rel_advance( what, unit, current, max, step, dp_type, previous, just )
IGRchar     what[]   ;        /* I : string describing action being 
                                       processed */

IGRchar     unit[]   ;        /* I : string describing processed objects */

IGRlong     current  ;        /* I : current index */
        
IGRlong     max      ;        /* I : maximal index */
        
IGRlong     *previous;        /* I/O : last index where display was done */

IGRdouble   step     ;        /* I : display status every <step>% of work */

IGRshort    dp_type  ;        /* I : display as number, percent or dots */

IGRint      just     ;        /* I : justification : LEFT_JUS, RIGHT_JUS,
                                                     or CENTER_JUS */

/* VDSshow_rel_advance */
{
        IGRlong                int_step = step * 0.01 * max ;
        
        /* " max      = %d\n", max */
        /* " current  = %d\n", current */
        /* " previous = %d\n", *previous */
        /* " int_step = %d\n", int_step */
        
        if( current > *previous + int_step )
        {
                IGRchar                sts_string[100] ;
                IGRint                max_dots = 10 ;
                IGRint                nb_dots, i ;

                /*" current  = %d\n", current */
                sts_string[0] = '\0' ;                
                *previous = current ;
                switch( dp_type ) {
                        case VDSDP_BY_NB :
                                sprintf( sts_string, " %s  at %6d / %d %ss",
                                         what, current, max, unit ) ;
                                break ;
                        case VDSDP_BY_PC :
                                sprintf( sts_string, " %s  at %3d%%", what,
                                         (IGRlong) (100.0 * current) / max  ) ;
                                break ;
                        case VDSDP_BY_DOT:
                                sprintf( sts_string, "%s", what ) ;
                                nb_dots = max_dots * step / 100.0 ;
                                for( i=0; i<nb_dots; i++ )
                                        strcat( sts_string, "." ) ;
                                break ;
                }
                ex$message( in_buff       = sts_string,
                            field         = ERROR_FIELD,
                            justification = just );
        }
}
                


VDSshow_abs_advance( what, unit, current, step, dp_type, previous, just )
IGRchar     what[]   ;        /* I : string describing action being 
                                        processed */
                                        
IGRchar     unit[]   ;        /* I : string describing processed objects */

IGRlong     current  ;        /* I : current index */
        
IGRlong     *previous;        /* I/O : last index where display was done */

IGRlong     step     ;        /* I : number of elements between 2 refresh */

IGRshort    dp_type  ;        /* I : display as number, percent or dots */

IGRint      just     ;        /* I : justification : LEFT_JUS, RIGHT_JUS,
                                                     or CENTER_JUS */

/* VDSshow_abs_advance */
{
        /* " current  = %d\n", current */
        /* " previous = %d\n", *previous */
        /* " int_step = %d\n", step */
        
        if( current > *previous + step )
        {
                IGRchar                sts_string[100] ;
                IGRlong                nb_dots, i ;

                sts_string[0] = '\0' ;                
                *previous = current ;
                switch( dp_type ) {
                        case VDSDP_BY_NB :
                                sprintf( sts_string, " %s  at %s #%4d",
                                         what, unit, current ) ;
                                break ;
                        case VDSDP_BY_DOT:
                                sprintf( sts_string, "%s", what ) ;
                                nb_dots = current / step ;
                                for( i=0; i<nb_dots; i++ )
                                        strcat( sts_string, "." ) ;
                                break ;
                }
                ex$message( in_buff       = sts_string,
                            field         = ERROR_FIELD,
                            justification = just );
        }
}
                



