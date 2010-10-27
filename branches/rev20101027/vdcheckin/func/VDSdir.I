/* $Id: VDSdir.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / VDSdir.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdir.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include	"igrtypedef.h"
#include	"igetypedef.h"
#include	"igr.h"
#include	"gr.h"

#include	"DItypedef.h"
#include	"DIdef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"expression.h"
#include	"expmacros.h"

#include	"OMmacros.h"
#include	"exmacros.h"

#include	"VDSris_def.h"
#include	"VDSris_siz.h"

#define		MODEL_KEY	":IGENOD:VDmodel_key"
#define		DWG_KEY		"design"

from	NDnode	import	NDgive_structure;
from	NDmacro	import	ACgive_structure;

int VDSset_model_key ( catalog, partnum, revision)

	char			*catalog;
	char			*partnum;
	char			*revision;

{

	int			modify = 0;
	char			model_exp[MAXWORD];
	char			model_val[MAXWORD];
	int			status;
	struct	GRid		exp;
	IGRlong			msg;
	struct	ret_struct	str;
	struct	GRmd_env	md_env;
	char			filepath[MAXWORD];


	/*|Concatenate model key value */
        sprintf ( model_val, "%s%s%s%s%s",
                  catalog, SEP_STRING, partnum, SEP_STRING, revision);

	/*|Get current md_env */
	ex$get_cur_mod( id    = &md_env.md_id.objid,
                        osnum = &md_env.md_id.osnum);

	/*|Get filename*/
	di$give_pathname ( osnum    = md_env.md_id.osnum,
			   pathname = filepath );

	/*|Concatenate model key expression */
	sprintf ( model_exp, "%s%s", filepath, MODEL_KEY);

	/*|Search model key expression in EMS directories */
        status = di$translate ( osnum   = md_env.md_id.osnum,
				objname = model_exp,
                                p_objid = &exp.objid);

        if (!(status&1))
          {
	   exp$create ( exp_name   = model_exp,
			exp_syntax = model_val, 
			osnum	   = md_env.md_id.osnum,
			p_exp_id   = &exp.objid,
			p_osnum    = &exp.osnum,
			type_rq    = EXP_TEXT );
          }
	else
          {
	   status = om$send ( msg = message NDnode.NDgive_structure
					    ( &msg,
					      &str,
					      &md_env ),
			      senderid = NULL_OBJID,
			      targetid = exp.objid,
			      targetos = md_env.md_id.osnum);

	   if ( (strcmp ( str.var.text_st.text_string, model_val) != 0)
           ||   (!(status&msg&1)) )
	     {
	      exp$modify ( exp_name   = model_exp,
			   osnum      = md_env.md_id.osnum,
			   exp_syntax = model_val );
	      modify = 1;
	     }
          }

	return modify;
}


int VDSget_model_key ( object, catalog, partnum, revision)

	struct	GRid		object;
	char			*catalog;
	char			*partnum;
	char			*revision;

{

	char			model_val[MAXWORD];
	int			status;
	int			suc;
	struct	ret_struct	str;
	struct	GRmd_env	md_env;
	int			sep[3];
	int			i, j, len;

	catalog[0] = 0;
	partnum[0] = 0;
	revision[0] = 0;

	/*|Get current md_env */
	ex$get_cur_mod( id    = &md_env.md_id.objid,
                        osnum = &md_env.md_id.osnum);

	/*|Get expression value */
	status = om$send ( msg = message NDmacro.ACgive_structure
					 ( &suc,
					   NULL,
					   DWG_KEY,
					   &str,
					   &md_env ),
			   senderid = NULL_OBJID,
			   targetid = object.objid,
			   targetos = object.osnum );
        if (!(status&suc&1)) return 0;

	/*|Retrieve catalog, partnum & revision */
	strcpy ( model_val, str.var.text_st.text_string);

	/*|Split string in 3 */
	len = strlen (model_val);

	sep[0] = sep[1] = 0;
	j = 0;
	for ( i=0; i<len; i++)
	  {
	   if (model_val[i] == SEP_CHAR)
	     {
	      sep[j] = i;
	      j++;
	     }
	  }

	for ( i=0; i<sep[0]; i++) catalog[i] = model_val[i];
	catalog[sep[0]] = 0;

	for ( i=1+sep[0]; i<sep[1]; i++) partnum[i-1-sep[0]] = model_val[i];
	partnum[sep[1]-1-sep[0]] = 0;

	for ( i=1+sep[1]; i<len;  i++) revision[i-1-sep[1]] = model_val[i];
	revision[len-1-sep[1]] = 0;

	return 1;
}

end implementation Root;
