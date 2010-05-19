/* $Id: VDtblExecPpl.I,v 1.3 2001/02/16 20:43:09 ylong Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/func/VDtblExecPpl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtblExecPpl.I,v $
 *      Revision 1.3  2001/02/16 20:43:09  ylong
 *      set return sts for check
 *
 *      Revision 1.2  2001/02/09 14:42:25  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/07 18:19:53  ramarao
 *      *** empty log message ***
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/07/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "ci.h"
#include "ciexecmacros.h"
#include "VDobj.h"
#include "v_pplslc.h"
#include "v_dbgmacros.h"

#define vdsDEBUG	1
#define vserrDEBUG	1

IGRlong	VDtblRowExecPplName( IGRlong		*msg,
			     struct GRid	*model_obj,
			     struct GRid	*row_obj,
			     IGRchar		*pplName,
			     IGRchar		*funcName,
			     IGRchar		*objName    )
{
IGRlong			sts;
IGRint			count;
struct GRobj_env	objOE, rowOE;

   SetProc( VDtblRowExecPplName ); Begin

   sts = *msg = MSFAIL;

   objOE.obj_id = *model_obj;
   rowOE.obj_id = *row_obj;

   __DBGpr_obj( "Input Object", objOE.obj_id );
   __DBGpr_obj( "Row Object",rowOE.obj_id );
   __DBGpr_str( "PPL name", pplName );
   __DBGpr_str( "Function Name", funcName );

   objName[0] = '\0';

   vd$ppl_set_size( which_info = INPUT_INFO,
                    size       = 2              );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index = 0,
                           type  = VD_object,
                           value = &objOE );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index = 1,
                           type  = VD_object,
                           value = &rowOE );

   ci$exec( file_name = pplName,
            sender_id = NULL_OBJID,
            entry     = funcName  );

   count = 0;
   vd$ppl_get_size( which_info = OUTPUT_INFO,
                    size       = &count );
   __DBGpr_int( "PPL output count", count );
   if( count < 1 ) goto wrapup;

   vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                           index      = 0,
                           value      = objName  );
   __DBGpr_str( "Output Name", objName );

   sts = *msg = MSSUCC;

wrapup:
   vd$ppl_free_args( which_info = INPUT_INFO );
   vd$ppl_free_args( which_info = OUTPUT_INFO );
   End
   return sts;
}

IGRlong	VDtblRowExecPplCheck( IGRlong		*msg,
			      struct GRid	*model_obj,
			      struct GRid	*row_obj,
			      IGRchar		*pplName,
			      IGRchar		*funcName,
			      IGRchar		*oldName,
			      IGRint		*isModified    )
{
IGRlong			sts;
IGRint			count;
struct GRobj_env	objOE, rowOE;

   SetProc( VDtblRowExecPplCheck ); Begin

   sts = *msg = MSFAIL;

   *isModified = 0;

   objOE.obj_id = *model_obj;
   rowOE.obj_id = *row_obj;

   __DBGpr_obj( "Input Object", objOE.obj_id );
   __DBGpr_obj( "Row Object",rowOE.obj_id );
   __DBGpr_str( "PPL name", pplName );
   __DBGpr_str( "Function Name", funcName );
   __DBGpr_str( "Object Old Name", oldName );

   vd$ppl_set_size( which_info = INPUT_INFO,
                    size       = 3              );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index = 0,
                           type  = VD_object,
                           value = &objOE );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index = 1,
                           type  = VD_object,
                           value = &rowOE );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index = 2,
                           type  = VD_string,
                           value = oldName );

   ci$exec( file_name = pplName,
            sender_id = NULL_OBJID,
            entry     = funcName  );

   count = 0;
   vd$ppl_get_size( which_info = OUTPUT_INFO,
                    size       = &count );
   __DBGpr_int( "PPL output count", count );
   if( count < 1 ) goto wrapup;

   vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                           index      = 0,
                           value      = isModified  );
   __DBGpr_int( "isModified", *isModified  );

   sts = *msg = MSSUCC;

wrapup:
   vd$ppl_free_args( which_info = INPUT_INFO );
   vd$ppl_free_args( which_info = OUTPUT_INFO );
   End
   return sts;
}

end implementation VDSroot;
