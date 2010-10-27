/* $Id: v_postproto.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include/prototypes / v_postproto.h
 *
 * Description:
 *	Prototypes for table post functions
 *
 * Dependencies:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	11/17/95	htv		Created
 *
 *************************************************************************/

#ifndef v_postproto_include
#define v_postproto_include

#include <standards.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

extern void
VD_mv_Esc_Quote     __((IGRchar      *szOut,
                        IGRchar      *szIn,
                        IGRint        MaxLen));

extern void
VD_mv_Iin_Quote     __((IGRchar      *szOut,
                        IGRchar      *szIn));

extern void
VD_post_prt         __((IGRint     columns,
                        IGRint    *col_typ,
                        IGRchar  **col_value));

extern IGRboolean
VD_db_table_haskey  __((IGRchar      *tabnam,
                        IGRchar      *keynam,
                        IGRchar      *keyval));

extern IGRint
VD_post_SqlInsVal   __((IGRchar      *tabnam,
                        IGRint        col_num,
                        IGRint       *col_typ,
                        IGRint       *num_chr,
                        IGRchar     **col_val));


#endif /* v_postproto_include */
