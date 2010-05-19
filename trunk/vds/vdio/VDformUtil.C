/* # $Id: VDformUtil.C,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $ */
 
/* # -------------------------------------------------------------------
# I/VDS
#
# File: vds/vdpts/VDformUtil.C
#
# Description:
#
# Dependencies:
#
# Revision History:
#       $Log: VDformUtil.C,v $
#       Revision 1.1.1.1  2001/01/04 21:08:52  cvs
#       Initial import to CVS
#
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/06/13  18:26:32  pinnacle
 * (No comment)
 *
 * Revision 1.1  1997/06/13  17:40:56  pinnacle
 * CR179527294: moved from vdpts to vdio to keep all subform (input/output) utilities together; added VDfi_prompt.
 *
 * Revision 1.1  1997/05/30  09:14:54  pinnacle
 * initial revision
 *
# History:
#       MM/DD/YY        AUTHOR  DESCRIPTION
#       05/30/97        Sundar  Creation Date
#       06/13/97        ejm     CR179527294: moved file to vds/vdio
#                               Added VDfi_prompt
#
# ------------------------------------------------------------------- */

#ifdef ENV5
#include <stdarg.h>
#elif defined(X11)
#include "standards.h"
#include "varargs.h"
#include "stdarg.h"
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define FALSE 0
#define TRUE 1
#include <FEI.h>
#include <FI.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "v_cmd.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "v_ioproto.h"
#include "v_strngproto.h"
/*----------------------------------------------------------------------------*/
int VDfi_msgkey( form, msg ) char *form ; long msg ; {
 
        return VDfi_msg( form, VDmsgkey2string( msg ) ) ;
 
} /* VDfi_msgkey */
/*----------------------------------------------------------------------------*/
int VDfi_msg( form, msg ) char *form, *msg ; {
 
        return FIfld_set_text( form, FI_MSG_FIELD, 0, 0, msg, FALSE ) ;
 
} /*  VDfi_msg */
/*----------------------------------------------------------------------------*/
int VDfi_prompt( form, prompt ) char *form, *prompt ; {

        return FIfld_set_text( form, FI_PROMPT_FIELD, 0, 0, prompt, FALSE ) ;

} /*  VDfi_prompt */
/*----------------------------------------------------------------------------*/
int VDfld_set_list( form, label, size, list )
 
char    *form ;
int     label,
        size ;
char    **list ; {
 
        /*
         * Sets number of row, then fills them with list.
         */
        int     rc,
                row ;
 
        rc = FIfld_set_list_num_rows(   form,
                                        label,
                                        0,
                                        size ) ;
 
        for( row = 0 ; row < size ; row++ ) {
                rc = VDfld_set_list_text( form, label, row, 0,
                                          list[row], FALSE ) ;
        }
 
        return rc ;
 
} /* VDfld_set_list */
