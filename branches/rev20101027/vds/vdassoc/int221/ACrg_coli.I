/* $Id: ACrg_coli.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACrg_coli.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACrg_coli.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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

/*
/*  History :
/*	LLC :- 23_oct_90	 + creation date
/*
/* */

class implementation ACrg_collect;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msmacros.h"
#include "ASmsg.h"
#include "asbox.h"
#include <alloca.h>

#define	AS_DEBUG
#define	AC_ATTRIB_REF	0x8	/* define type for cs attribute */

extern	GRclassid	OPP_ACpretend_class_id,OPP_text_exp_class_id,
			OPP_expression_class_id;
from	ACpretend	import	ACgive_downscan;
from	ACpretend	import	ACpconnect;
from expression import modify,NDset_value;

extern IGRboolean ASbroadcast_in_progress;


/* *************** MSG ACmod_list_attribute () ************************	*/

method ACmod_list_attribute( IGRlong *rc; IGRint list_len; 
					struct ACrg_coll *list_att )

{
IGRlong			sts;
IGRint			i, j;
IGRint			name_size;
IGRint			new_size;
IGRint			previous_size;
IGRint			cond;
IGRint			new_end;
IGRint			ind;


	/*| initialization */
	*rc	= MSSUCC;

	if( me->prop_mgr & AC_BOX_LOCKED ){

		printf(" box is locked \n");
		*rc	= MSFAIL;
		return	OM_S_SUCCESS;
	}

	for( ind=0; ind<list_len; ind++ ){

		/*| find name in attribute list */
		for( i=0; i<me->nb_attr; i++ )
			if( strcmp( list_att[ind].name, 
				&me->attr_name[me->attr_def[i].name] ) == 0 )
				break;
		if( i >= me->nb_attr ){
			*rc	= MSFAIL;
			continue;
		}

		/*" name : %s is the %dth attribute\n", list_att[ind].name, i */

		/*| check if type is AC_ATTRIB_TYPE_NOT_DEF */
		if( (list_att[ind].desc.type & AC_ATTRIB_MASK_TYPE)
				== AC_ATTRIB_TYPE_NOT_DEF )
			ACcol_set_type_val(	list_att[ind].desc.value.att_txt,
						&list_att[ind] );

		/*| test the type */
		if( (list_att[ind].desc.type & AC_ATTRIB_MASK_TYPE) != 
			(me->attr_type[i] & AC_ATTRIB_MASK_TYPE) ){
			printf(" type %d of attribute %d of list is not compatible type %d in collecttion\n",
				list_att[ind].desc.type, ind, me->attr_type[i] );
			*rc	= MSFAIL;
			continue;
		}

		if( (me->attr_type[i] & AC_ATTRIB_MASK_PROP) & AC_ATTRIB_LOCK ){

			*rc = MSFAIL;
			continue;
		}

		switch( me->attr_type[i] & AC_ATTRIB_MASK_TYPE ) {

		case AC_ATTRIB_REF :
		case AC_ATTRIB_DOUBLE :

			me->attr_exp[me->attr_def[i].index] =
					list_att[ind].desc.value.att_exp;
			break;

		case AC_ATTRIB_TEXT :

			previous_size	= om$dimension_of( varray = me->attr_txt );
			name_size	= strlen( 
				&me->attr_txt[me->attr_def[i].index] ) + 1;
			new_size	= strlen( 
				list_att[ind].desc.value.att_txt ) + 1;

/*^
			printf(" previous_size	: %d\n", previous_size );
			printf(" name_size	: %d\n", name_size );
			printf(" new_size	: %d\n", new_size );
*/

			if( new_size > name_size ){

				/*| redim vla */
				sts = om$vla_set_dimension(	
					varray	= me->attr_txt,
					size	= 
					previous_size + new_size - name_size ); 
				as$status( sts = sts );

				/*| push memory on right */
				cond = me->attr_def[i].index + name_size - 1;
				new_end = previous_size + new_size - name_size;
				for( j = previous_size - 1; j>cond; j-- )
					me->attr_txt[--new_end] = 
								me->attr_txt[j];

				/*| store new text */
				OM_BLOCK_MOVE(	
					list_att[ind].desc.value.att_txt, 
					&me->attr_txt[me->attr_def[i].index],
					new_size );

				/*| modify index of attr_def */
				cond = new_size - name_size;
				for( j=i+1; j<me->nb_attr; j++ )
				  if( (me->attr_type[j] & AC_ATTRIB_MASK_TYPE) 
							== AC_ATTRIB_TEXT )
						me->attr_def[j].index += cond;

			} else {

				/*" set new value : %s\n", list_att[ind].desc.value.att_txt */
				OM_BLOCK_MOVE(
					list_att[ind].desc.value.att_txt, 
					&me->attr_txt[me->attr_def[i].index],
					new_size );

				/*" compress end vla : %d\n", previous_size - me->attr_def[i].index - name_size */
				OM_BLOCK_MOVE(	
					&me->attr_txt[me->attr_def[i].index] + 
							name_size,
					&me->attr_txt[me->attr_def[i].index] + 
							new_size,
					previous_size - 
						me->attr_def[i].index - 
							name_size  );
			
				/*" normale dim : %d\n", previous_size - name_size +  new_size */
				sts = om$vla_set_dimension(
						varray	= me->attr_txt,
						size	= previous_size - 
								name_size + 
								new_size );
				as$status( sts = sts );

				/*| modify index of attr_def */
				cond = name_size - new_size;
				for( j=i+1; j<me->nb_attr; j++ )
				  if( (me->attr_type[j] & AC_ATTRIB_MASK_TYPE) 
							== AC_ATTRIB_TEXT )
						me->attr_def[j].index -= cond;

			  }
			break;

		case AC_ATTRIB_CONNECT :
			break;

		default :
			*rc	= MSFAIL;
		}

	}/*end for*/

return	OM_S_SUCCESS;
}
end implementation ACrg_collect;

