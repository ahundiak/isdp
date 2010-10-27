/* $Id: VDitblnCorr.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDitblnCorr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitblnCorr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.3  1996/05/02  12:08:12  pinnacle
# Replaced: ./vdannot/imp/VDitblnCorr.I for:  by azuurhou for vds.240
#
# Revision 1.2  1996/01/10  17:24:20  pinnacle
# Replaced: vdannot/imp/VDitblnCorr.I for:  by jwfrosch for vds.240
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
 *	01/09/96	  HF		Enable  PREVIOUS CALCULATION
 *					Disable NEW CALCULATION
 *					Modify txt_heigt & txt_width in case of SPLIT_BALLOON
 *					Necessary because otherwise text & balloon will overlap.
 *
 * -------------------------------------------------------------------*/

/*
 * Temporary file to correct the text width factor for ITEM NUMBER.
 *
 * CORRECTION FOR TEXT WITH BALLOON
 *
 * Creation Date	01-10-1992.
 */

class implementation DMtxbln;

#define AS_DEBUG 1

#include "dimmod.h"
#include "dimgraph.h"
#include "dpdef.h"
#include "fielddef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

#define 	NO_INPUT	0
#define 	NORMAL_INPUT	1
#define 	KANJI_INPUT	2

extern IGRshort GRfwd_esc_seq();
extern double sqrt();

from GRtext import GRgettxattr;

IGRint DMget_bln_txt_width ( flag, txt_length, par_senv, text_grid, md_env )
  IGRboolean		 flag;
  IGRshort		*txt_length;
  struct DMsenv_param	*par_senv;
  struct GRid		 text_grid;
  struct GRmd_env	*md_env;
{
	IGRint     status;
	IGRshort   text_length, test_length;
	IGRlong    long_rc;
	IGRuchar  *text_string, test_str[80];
	IGRdouble  str_limit, str_width;
	IGRboolean inp_type;
	IGRboolean bln_type = FALSE;

	/* **********************************
		IGRint	rc;
		IGRshort true, start_index, num_chars;
	   ********************************** */

  __enterFunction ( name = "DMget_bln_txt_width" );

	text_string = NULL;

	if(flag)
	{
		text_string = NULL;

		status =
		om$send(msg = message GRtext.GRgettxattr(
						&long_rc,
						NULL,
						&text_length,
						&text_string),
			senderid = NULL_OBJID,
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		__CheckRC( status, long_rc, "GRtext.GRgettxattr", wrapup );

		DMget_exact_str(text_string,
				text_length,
				test_str,
				&test_length);

		DMisinput_kanji(test_str,test_length,&inp_type);

	/* ***********************************
		true = TRUE;
		start_index = 0;

		GRfwd_esc_seq( &long_rc, text_string, &text_length,
				&true, &start_index, &num_chars);
	   *********************************** */

		_FREE( text_string );

		if(inp_type == KANJI_INPUT)
			text_length = test_length/2;
		else
			text_length = test_length;
	/* ************************************
		text_length = text_length - num_chars;
	   ************************************ */
	}
	else
	{
		/*^ printf("txt_length = %d\n",*txt_length); */
		__printf("txt_length = %d",*txt_length);
		text_length = *txt_length;
	}

/* ********************************************
	* HF 01/09/96
	PREVIOUS CALCULATION : Enabled
	Enable  PREVIOUS CALCULATION ( is better than NEW CALCULATION )
   ******************************************** */

	str_limit = (par_senv->bln_size - 1) * par_senv->txt_heig;
	str_width = text_length * par_senv->txt_widt;

/* ********************************************
	* HF 01/09/96
	NEW CALCULATION : disabled
	str_limit = sqrt(par_senv->bln_size*par_senv->bln_size - 1) * par_senv->txt_heig;
	str_width = text_length * par_senv->txt_widt;
   ******************************************** */

	if(str_width > str_limit)
	{
		par_senv->txt_widt = str_limit / text_length;
	}

	/*
	 * HF 01/09/96
	 * Modify txt_heig & txt_widt in case of SPLIT_BALLOON
	 * Necessary because otherwise text & balloon will overlap.
	 */
	bln_type = par_senv->bln_type == BLN_TYPE_SPLIT_CIRCLE		||
		   par_senv->bln_type == BLN_TYPE_SPLIT_TRIANGLE	||
		   par_senv->bln_type == BLN_TYPE_SPLIT_SQUARE		||
//		   par_senv->bln_type == BLN_TYPE_SPLIT_RECTANGLE	||
		   par_senv->bln_type == BLN_TYPE_SPLIT_POLYGON		||
		   par_senv->bln_type == BLN_TYPE_SPLIT_ELLIPSE		||
		   par_senv->bln_type == BLN_TYPE_SPLIT_INV_TRIANGLE;

	if ( text_length > 0.0 && bln_type )
	{
		par_senv->txt_heig *= 0.8;
		par_senv->txt_widt *= 0.8;
	}

	/*^
		printf("str_limit = %f\n",str_limit);
		printf("str_width = %f\n",str_width);
		printf("txt_heig  = %f\n",par_senv->txt_heig );
		printf("txt_width = %f\n",par_senv->txt_widt);
		printf("bln_size  = %f\n",par_senv->bln_size );
		printf("bln_type  = %d\n",par_senv->bln_type );
		printf("text_length = %d\n\n",text_length);
	 */
		__printf("str_limit = %f",str_limit);
		__printf("str_width = %f",str_width);
		__printf("txt_heig  = %f",par_senv->txt_heig );
		__printf("txt_width = %f",par_senv->txt_widt);
		__printf("bln_size  = %f",par_senv->bln_size );
		__printf("bln_type  = %d",par_senv->bln_type );
		__printf("text_length = %d",text_length);

  __exitFunction ( name = "DMget_bln_txt_width" );

wrapup:

	_FREE( text_string );

	return(OM_S_SUCCESS);
}
end implementation DMtxbln;
