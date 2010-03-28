/*
 *  History :
 *	LLC :- 23_oct_90	 + creation date
 *      scw :  16 jun 94         + Added conditionals on dload_address
 *                                 for PDM group
 *
 */

class implementation ACdyn_col;

#include "OMmacros.h"
#include "OMprimitives.h"

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

#include <alloca.h>

#define	AS_DEBUG
#define	AC_ATTRIB_REF	0x8	/* define type for cs attribute */

extern		dload_address_lookup();

extern	struct	GRid	NULL_GRID;

extern	GRclassid	OPP_ACpretend_class_id;
from	ACpretend	import	ACgive_downscan;
from	ACpretend	import	ACpconnect;


/* ************ MSG ACshow_attribute () *******************************	*/

method ACshow_attribute( IGRlong *rc; struct ACrg_coll *attrib )

{
IGRint	cond;


	printf("\t%s,", attrib->name );
	switch( attrib->desc.type & AC_ATTRIB_MASK_TYPE ){

	case AC_ATTRIB_REF :
		printf(" \tcs identity,");
		break;

	case AC_ATTRIB_DOUBLE :
		printf(" \tdouble = %f,", attrib->desc.value.att_exp );
		break;

	case AC_ATTRIB_TEXT :
		printf(" \ttext   = %s,", attrib->desc.value.att_txt );
		break;

	default :
		printf(" unknown (x) : %x,", attrib->desc.type & AC_ATTRIB_MASK_TYPE );

	}/*end base type*/

	cond = attrib->desc.type & AC_ATTRIB_MASK_PROP;
	
	if( cond == 0x0000 )			printf(" \tno prop");
	if( cond & AC_ATTRIB_LOCK )		printf(" \tlock &");
	if( cond & AC_ATTRIB_UPDATE )		printf(" \tupdate &");
	if( cond & AC_ATTRIB_EVAL )		printf(" \tevaluable &");
	if( cond & AC_ATTRIB_PRIVATE )		printf(" \tprivate &");

	printf("\n");

return	OM_S_SUCCESS;
}

/* *********** MSG ACshow_data () *************************************	*/

method ACshow_data( IGRlong *rc )

{
IGRchar			box_name[120];
IGRlong			sts, msg;
IGRint			i;
struct	ACrg_coll	attrib;
IGRint			size_fct_att;


	/*| initialization */
	*rc	= MSSUCC;

	printf("\n ~~~~~~~~~~~~ Collection (%d/%d) ::", 
						my_id, OM_Gw_current_OS );

	box_name[0] = '\0';
	sts = om$send(	msg	 = message ACdiowner.GRgetname
					( rc, box_name ),
			targetid = my_id );
	as$status( sts = sts );

	if( *rc & 1 )	printf(" Name --> %s\n", box_name );
	else		printf(" Not Named \n");

	printf(" number of stored attributes : %d\n", me->nb_attr );

	for( i=0; i<me->nb_attr; i++ ) {

		/*" index for name  : %d\n", me->attr_def[i].name */
		/*" index for value : %d\n", me->attr_def[i].index */

		sts = om$send(	msg	 = message ACrg_collect.ACget_attribute_at_index
					( &msg, i, &attrib ),
				targetid = my_id );
		as$status( sts = sts );

		attrib.desc.type = me->attr_type[i];

		sts = om$send(	msg	 = message ACdyn_col.ACshow_attribute
					( &msg, &attrib ),
				targetid = my_id );
		as$status( sts = sts );

		if( attrib.desc.type & AC_ATTRIB_MASK_PROP & AC_ATTRIB_EVAL ){

			sts = om$send(	msg	 = message ACdyn_col.ACeval_attributes
						( &msg, 1, &attrib, NULL ),
					targetid = my_id );
			as$status( sts = sts );
			switch( attrib.desc.type & AC_ATTRIB_MASK_TYPE ){

			case AC_ATTRIB_REF :
				printf("\t\t evaluation --> cs identity\n");
				break;

			case AC_ATTRIB_DOUBLE :
				printf("\t\t evaluation --> double = %f\n",
						attrib.desc.value.att_exp );
				break;

			case AC_ATTRIB_TEXT :
				printf("\t\t evaluation -->  text  = %s\n",
						attrib.desc.value.att_txt );
				break;

			default :				
				printf("\t\t evaluation -->  unknown (x) %u\n",
					attrib.desc.type & AC_ATTRIB_MASK_TYPE );
			}
		}/*end eval*/

	}/*end for*/

	size_fct_att = om$dimension_of( varray = me->fct_def );

	printf(" number of overrided functions : %d\n", size_fct_att );
	for( i=0; i<size_fct_att; i++ ){

		printf(" select[%d]   : %d --> %s\n", i, me->fct_def[i].select,
					&me->fct_txt[me->fct_def[i].select] );
		printf(" fct_name[%d] : %d --> %s\n", i, me->fct_def[i].fct_name,
					&me->fct_txt[me->fct_def[i].fct_name] );
		printf(" fct_add[%d]  : %x (x)\n", i, me->fct_def[i].fct_add );
	}

/*
	printf(" me->prop_mgr (x) : %x\n", me->prop_mgr );
	printf(" show list of text attribute \n");
	txt_size = om$dimension_of(varray = me->attr_txt);
	printf(" txt_size : %d\n", txt_size );
	for( i=0; i<txt_size; i++ ){

		if( me->attr_txt[i] == '\0' )	printf(" fin de texte ind : %d\n", i );
		printf("%c", me->attr_txt[i] );
	}
*/

	printf(" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n");


return	OM_S_SUCCESS;
}

/* **************** MSG ACgive_structure () ***************************	*/

method ACgive_structure( IGRint	*rc; IGRint *direct_index; IGRchar *footname;
				struct ret_struct *foot_str;
				struct GRmd_env *md_env )
{
IGRlong			msg, sts;
IGRint			i;
struct	ACrg_coll	loc_attr;


	/*| initialization */
	*rc	= 1;

	/*" footname : %s\n", footname */

	for( i=0; i<me->nb_attr; i++ )
		if( strcmp( footname, 
				&me->attr_name[me->attr_def[i].name] ) == 0 )
			break;
	if( i >= me->nb_attr ){

		/*| no corresponding attribute */
		*rc	= 0;
		return	OM_S_SUCCESS;
	}

	sts = om$send(	msg	 = message ACdyn_col.ACget_attribute_at_index
					( &msg, i, &loc_attr ),
			targetid = my_id );
	as$status( sts = sts );
	as$status( sts = msg );

	loc_attr.desc.type = me->attr_type[i];

	if( loc_attr.desc.type & AC_ATTRIB_MASK_PROP & AC_ATTRIB_EVAL ) {

		sts = om$send(	msg	 = message ACdyn_col.ACeval_attributes
						( &msg, 1, &loc_attr, md_env ),
				targetid = my_id );
		as$status( sts = sts );
		as$status( sts = msg );
	}

	switch( loc_attr.desc.type & AC_ATTRIB_MASK_TYPE ) {

	case AC_ATTRIB_DOUBLE :
		foot_str->type = double_type;
		foot_str->var.root_pm_st.value = 
					loc_attr.desc.value.att_exp;
		break;

	case AC_ATTRIB_REF :
		foot_str->type = ref_generic;
		MAidmx( &msg, foot_str->var.ref_st.t );
		break;

	case AC_ATTRIB_TEXT :
		foot_str->type = text_type;
		strcpy( foot_str->var.text_st.text_string,
					loc_attr.desc.value.att_txt );
		break;

	case AC_ATTRIB_CONNECT :
		printf(" type connect not yet implemented \n");
		*rc	= 0;
		break;

	default :
		printf(" unknown type %d for attribut \n");
		*rc	= 0;
	}

return	OM_S_SUCCESS;
}

/* ************** MSG NDplace () **************************************	*/

method NDplace( struct GRas *as_list; struct GRmd_env *md_env; 
						char *go_cnst_lis )

{
IGRlong			sts, msg;
struct	GRid		my_grid, context;
struct	ACrg_coll	attrib;
struct	ACcol_info	*col_info;
IGRint			*par_state;
IGRint			i;

	/*| initialization */
	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;
	col_info	= (struct ACcol_info *) as_list->as_attr;

/*^
	{
	IGRint		i;
	printf(" as_list->num_parents : %d\n", as_list->num_parents );
	for( i=0; i<as_list->num_parents; i++ ){
		printf(" parents[%d] : %d/%d \n", i, 
			as_list->parents[i].objid, as_list->parents[i].osnum );
	}

	printf(" place fct name   : %s\n", col_info->pl_fct_name );
	printf(" compute fct name : %s\n", col_info->cp_fct_name );
	}
*/

	/*| set fct compute */
	strcpy( attrib.name, "~UPDT" );
	strcpy( attrib.desc.value.att_txt, col_info->cp_fct_name );
	attrib.desc.type	= AC_ATTRIB_TEXT | 
					AC_ATTRIB_EVAL | AC_ATTRIB_PRIVATE;
	sts = om$send(	msg	 = message ACdyn_col.ACadd_fct
					( &msg, attrib ),
			targetid = my_id );
	as$status( sts = sts );

	/*| connect parents */
	sts = om$send(	msg	 = message NDnode.NDconnect(
					as_list->num_parents,
					as_list->parents,
					NULL_GRID,
					ND_FULL ),
			targetid = my_id );
	as$status( sts = sts );

	if( col_info->pl_fct_name[0] != '\0' ){

		/*| msg for evaluate */
		strcpy( attrib.name, "~PLC" );
		strcpy( attrib.desc.value.att_txt, 
					col_info->pl_fct_name );
		attrib.desc.type = AC_ATTRIB_TEXT | AC_ATTRIB_EVAL;
		sts = om$send(	msg	 = message ACdyn_col.ACeval_attributes
					( &msg, 1, &attrib, md_env ),
				targetid = my_id );
		as$status( sts = sts );
		as$status( sts = msg );

	} else {

		if( ! as_list->num_parents )	return	sts;

		par_state = (IGRint *) alloca( 
				as_list->num_parents * sizeof( IGRint ));
		if( par_state == NULL ){
			printf(" Error : not enougth memory to allocate par_state\n");
			return	OM_W_ABORT;
		}

		for( i=0; i<as_list->num_parents; i++ )
			par_state[i] = ND_COMP_SUCC;

		context = my_grid;
		sts = om$send(	msg	 = message NDnode.NDupdate(
						(int *)&msg,
						0,
						as_list->num_parents,
						as_list->parents,
						par_state,
						&context, &my_grid,
						md_env ),
				targetid = my_id );
		as$status( sts = sts );
	}

return	sts;
}

/* ************** MSG NDupdate () *************************************	*/

method NDupdate(	int *rc; IGRint cn_type; 
			IGRint count; struct GRid list[]; int *parent_state;
			struct GRid *context,*new_objid;
			struct GRmd_env	*md_env )
{
IGRlong			sts, msg;
struct	ACrg_coll	attrib;
IGRint			(*fct_ptr)();
IGRint			index;
IGRint			addr;
IGRchar			fct_name[ATTR_NAME+1];


	/*| initialization */
	NDcontrol_parent_state( count, parent_state, rc );
	if(*rc != ND_COMP_SUCC) return OM_S_SUCCESS;

	new_objid->objid	= my_id;
	new_objid->osnum	= OM_Gw_current_OS;
	*rc = ND_COMP_SAME;

	index	= -1;
	strcpy( attrib.name, "~UPDT" );
	sts = om$send(	msg	 = message ACdyn_col.ACget_fct
					( &msg, &attrib, &index, &addr ),
			targetid = my_id );

	if( msg != MSSUCC ){
		/* look for compute */
		strcpy( attrib.name, "~CMPT" );
		sts = om$send(	msg	 = message ACdyn_col.ACget_fct
					( &msg, &attrib, &index, &addr ),
				targetid = my_id );
	}
	if( ! (sts&msg&1))	return	OM_S_SUCCESS;
	if( attrib.desc.value.att_txt == NULL )	return	OM_S_SUCCESS;

	if( addr != 0 )	fct_ptr = (IGRint (*)())addr;

	else {
#if ( defined( SUNOS5 ) || defined( IRIX ) )
		  strcpy( fct_name, attrib.desc.value.att_txt );
#else
		  sprintf( fct_name, "_%s", attrib.desc.value.att_txt );
#endif
		fct_ptr = (IGRint (*)()) dload_address_lookup( fct_name );
		if( fct_ptr == NULL ){
			printf(" function %s is not loaded\n", fct_name );
			*rc	= ND_COMP_FAIL;
			return	OM_S_SUCCESS;
		}

		/*| store address */
		sts = om$send(	msg	 = message ACdyn_col.ACset_fct_ptr( 
						&msg, 
						attrib, 
						&index, 
						(IGRint) fct_ptr ),
				targetid = my_id );
		as$status( sts = sts );
	}

	/*" CMPT fct_ptr : %x\n", fct_ptr */
	fct_ptr( &msg, *new_objid, &attrib, md_env, 
					count, list, parent_state, context );
	if( msg == ND_COMP_SAME)	*rc = msg;
	else if( msg & 1 )		*rc = ND_COMP_SUCC;
	else				*rc = ND_COMP_FAIL;

return	OM_S_SUCCESS;
}

/* ********************* MSG ACeval_attributes () *********************	*/

method ACeval_attributes( IGRlong *rc; IGRint list_len;
			struct ACrg_coll *list_att; struct GRmd_env *md_env )
{
IGRint		ind;
IGRchar         fct_name[ATTR_NAME+1];
IGRint          (*fct_ptr)();
struct	GRid	my_grid;

	/*| initialization */
	*rc	= MSSUCC;
	my_grid.objid   = my_id;
	my_grid.osnum   = OM_Gw_current_OS;

	for( ind=0; ind<list_len; ind++ ){

		if( list_att[ind].desc.value.att_txt == NULL ) continue;

		if( (list_att[ind].desc.type & AC_ATTRIB_MASK_PROP) & 
							AC_ATTRIB_EVAL ){

#if ( defined( SUNOS5 ) || defined( IRIX ) )
			strcpy( fct_name, list_att[ind].desc.value.att_txt );
#else
			sprintf( fct_name, "_%s", 
					list_att[ind].desc.value.att_txt );
#endif
			fct_ptr = (IGRint (*)()) 
					dload_address_lookup( fct_name );
			if( fct_ptr == NULL ){
				printf(" function %s is not loaded\n", fct_name );
				*rc	= MSFAIL;
				continue;
			}

			/*| run function */
			fct_ptr( rc, my_grid, &list_att[ind], md_env );
			as$status( sts = *rc );
		}

	}/*end for*/

return	OM_S_SUCCESS;
}

/* ************* MSG dump () ******************************************	*/

method dump ( DIint *stat; DIchar *reg_exp; OM_p_CLASSLIST classlist;
                DIchar ***lines; DIgrid **grids; DIint *count; 
                DIchar options )
{
IGRlong			sts, msg;
char 			**mname;
struct GRid		*ft;
IGRint			i;
IGRint			nb_private;
IGRint			nb_visible;


	if(options & OPT_SYS){

		/*| Dump returns nothing because after NDsleep or before AC wakeup */
		*count = 0;
		*stat = DIR_S_SUCCESS;
		return	OM_S_SUCCESS;
	}

	/*" nb_attr : %d\n", me->nb_attr */

	/*| get nb of attribute private */
	for( i=0, nb_private=0; i<me->nb_attr; i++ )
		if( (me->attr_type[i] & AC_ATTRIB_MASK_PROP) & 
			AC_ATTRIB_PRIVATE ) nb_private++;

	nb_visible = me->nb_attr - nb_private;

        ft = NULL;
	mname = NULL;
	if( nb_visible ){

		ft = (struct GRid *) om$malloc 
			( size = me->nb_attr * sizeof( struct GRid ));
		mname = (char **) om$malloc 
			( size = me->nb_attr * sizeof( char ** ));
	}

	*count = *count + nb_visible;

	for( i=0, nb_visible=0; i<me->nb_attr; i++ ){

		if( (me->attr_type[i] & AC_ATTRIB_MASK_PROP) & 
			AC_ATTRIB_PRIVATE )	continue;

		/*| get temporary pretend */
		sts = om$send(	msg	 = message ACrg_collect.ACreturn_foot(
						&msg,
						&me->attr_name[me->attr_def[i].
									name],
						&ft[nb_visible],
						NULL,
						NULL ),
				targetid = my_id );
		as$status( sts = sts, msg = "Error in msg ACreturn_foot" );
		/*" pret[%d] : id/os = (%d/%d)\n", nb_visible, ft[nb_visible].objid, ft[nb_visible].osnum */

		/*| feel name array */
		mname[nb_visible] = om$malloc( 
			size = strlen(&me->attr_name[me->attr_def[i].name])+1); 
		/*" malloc %d\n", strlen(&me->attr_name[me->attr_def[i].name])+1 */

		strcpy( mname[nb_visible],&me->attr_name[me->attr_def[i].name] );
		/*"attr %d name %s id %d %d\n",nb_visible,mname[nb_visible],ft[nb_visible].objid,ft[nb_visible].osnum*/

		nb_visible++;

	}/*end for*/

	*grids= (DIgrid *) ft;
	*lines=mname;
	*stat= DIR_S_SUCCESS;

return	OM_S_SUCCESS;
}

/* **************** MSG AClist_attributes_by_type () ******************	*/

method AClist_attributes_by_type( IGRlong *rc; IGRint list_len;
				struct ACrg_coll *list_att; IGRint *nb_attr;
				IGRshort att_natur;
				IGRchar	*test_nat;
				IGRshort int_prop;
				IGRchar	*test_int;
				IGRshort user_prop;
				IGRchar	*test_user )
{
IGRlong			msg, sts;
IGRint			ind;
struct	ACrg_coll	attrib;
IGRint			resp;

	/*| initialization */
	*rc		= MSSUCC;
	*nb_attr	= 0;

	for( ind=0; ; ind++ ){

		sts = om$send(	msg	 = message ACrg_collect.ACget_attribute_at_index
					( &msg, ind, &attrib ),
				targetid = my_id );
		as$status( sts = sts );
		if( ! (msg&1))	break;

		/*| test prop with given masks */
		resp = ACrg_test_prop(	attrib.desc.type, 
					att_natur, 
					test_nat, 
					AC_ATTRIB_MASK_TYPE );
		if( ! (resp&1) )	continue;

		resp = ACrg_test_prop(	attrib.desc.type, 
					int_prop, 
					test_int, 
					AC_ATTRIB_MASK_PROP );
		if( ! (resp&1) )	continue;

		resp = ACrg_test_prop(	attrib.desc.type, 
					user_prop, 
					test_user, 
					AC_ATTRIB_MASK_USER );
		if( ! (resp&1) )	continue;

		/*| set elemt in list */
		if( ( *nb_attr < list_len ) && (list_att != NULL) )
			list_att[*nb_attr] = attrib;

		*nb_attr += 1;
	}

return	OM_S_SUCCESS;
}

/* ********************** FCT ACrg_test_prop () ***********************	*/

int ACrg_test_prop( propert, mask_pro, test, range )

IGRshort	propert, mask_pro;
IGRchar		*test;
IGRshort	range;
/*.ACrg_test_prop*/
{

	propert 	= propert & range;
	mask_pro	= mask_pro & range;

	if( test == NULL )	return	TRUE;

	if( ! strcmp( test, ACTEST_TRUE ) )	return	TRUE;

	if( ! strcmp( test, ACTEST_EQUAL ) ){
		if( propert == mask_pro )	return	TRUE;
		else				return	FALSE;
	}
	if( ! strcmp( test, ACTEST_DIFF ) ){
		if( propert != mask_pro )	return	TRUE;
		else				return	FALSE;
	}
	if( ! strcmp( test, ACTEST_ONE_OR_MORE ) ){
		if( propert & mask_pro )	return	TRUE;
		else				return	FALSE;
	}
	if( ! strcmp( test, ACTEST_ALL_PROP ) ){
		if( (propert & mask_pro) == mask_pro )	return	TRUE;
		else					return	FALSE;
	}
	if( ! strcmp( test, ACTEST_NO_PROP ) ){
		if( (propert & mask_pro) == 0 )	return	TRUE;
		else				return	FALSE;
	}

return	FALSE;
}
/* *********************** MSG ACadd_fct () ***************************	*/

method ACadd_fct( IGRlong *rc; struct ACrg_coll fct_attrib )
{
IGRlong		sts;
IGRint		size_fct_att;
IGRint		prev_size;
IGRint		name_size;
IGRint		val_size;
IGRint		i;

	*rc	= MSSUCC;

	/*| find seletor */
	size_fct_att = om$dimension_of( varray = me->fct_def );

	for( i=0; i<size_fct_att; i++ )
		if( ! strcmp( fct_attrib.name, 
			&me->fct_txt[me->fct_def[i].select] )){
			*rc = MSFAIL;
			return OM_S_SUCCESS;
		}

	sts = om$vla_set_dimension(	varray	= me->fct_def,
					size	= size_fct_att + 1 );
	as$status( sts = sts, action = RET_STATUS );

	prev_size = om$dimension_of( varray = me->fct_txt );

	name_size = strlen( fct_attrib.name ) + 1;
	val_size  = strlen( fct_attrib.desc.value.att_txt ) + 1;

	sts = om$vla_set_dimension(	varray	= me->fct_txt,
				size	= prev_size + name_size + val_size );
	as$status( sts = sts, action = RET_STATUS );

	OM_BLOCK_MOVE( fct_attrib.name,
			&me->fct_txt[prev_size], name_size );
	me->fct_def[size_fct_att].select = prev_size;

	OM_BLOCK_MOVE( fct_attrib.desc.value.att_txt, 
			&(me->fct_txt[prev_size + name_size]), val_size );
	me->fct_def[size_fct_att].fct_name = prev_size + name_size;

	me->fct_def[size_fct_att].fct_add = 0;

return	OM_S_SUCCESS;
}

/* *********************** MSG ACrm_fct () ****************************	*/

method ACrm_fct( IGRlong *rc; IGRchar *fct_select )
{
IGRlong		sts;
IGRint		i, j;
IGRint		size_fct_att;
IGRint		sel_size, fct_size;
IGRint		prev_size;
IGRint		tot_off;

	*rc	= MSFAIL;

	/*| find seletor */
	size_fct_att = om$dimension_of( varray = me->fct_def );

	for( i=0; i<size_fct_att; i++ )
		if( ! strcmp( fct_select, 
				&me->fct_txt[me->fct_def[i].select] ))
			break;

	if( i == size_fct_att )	return	OM_S_SUCCESS;

	sel_size  = strlen( me->fct_txt[me->fct_def[i].select] ) + 1;
	fct_size  = strlen( me->fct_txt[me->fct_def[i].fct_name] ) + 1;
	prev_size = om$dimension_of( varray = me->fct_txt );

	OM_BLOCK_MOVE(	&me->fct_txt[me->fct_def[i].fct_name + fct_size],
			&me->fct_txt[me->fct_def[i].select],
			prev_size - me->fct_def[i].fct_name - fct_size );

	sts = om$vla_set_dimension(	varray	= me->fct_txt,
				size	= prev_size - sel_size - fct_size );

	tot_off = sel_size + fct_size;
	for( j=i; j<size_fct_att - 1; j++ ){
		me->fct_def[j].select   = me->fct_def[j+1].select - tot_off;
		me->fct_def[j].fct_name = me->fct_def[j+1].fct_name - tot_off;
		me->fct_def[j].fct_add	= me->fct_def[j+1].fct_add;
	}

	sts = om$vla_set_dimension(	varray	= me->fct_def,
					size	= size_fct_att - 1 );

	*rc	= MSSUCC;

return	OM_S_SUCCESS;
}

/* ******************** MSG ACset_fct_ptr () **************************	*/

method ACset_fct_ptr( IGRlong *rc; struct ACrg_coll attrib; IGRint *index;
				IGRint fct_ptr )
{
IGRint		i;
IGRint		size_fct_att;

	*rc	= MSSUCC;
	size_fct_att = om$dimension_of( varray = me->fct_def );

	if( (index != NULL) && (*index != -1) ) i = *index;

	else 
		for( i=0; i<size_fct_att; i++ )
			if( ! strcmp( attrib.name, 
					&me->fct_txt[me->fct_def[i].select] ))
				break;

	if( size_fct_att > i ){

		if( index != NULL )	*index = i;
		me->fct_def[i].fct_add	= fct_ptr;
	}

return	OM_S_SUCCESS;
}

/* *********************** MSG ACget_fct () ***************************	*/

method ACget_fct( IGRlong *rc; struct ACrg_coll *fct_attrib; IGRint *index;
			IGRint	*fct_ptr )
{
IGRint		i;
IGRint		size_fct_att;

	*rc	= MSSUCC;
	size_fct_att = om$dimension_of( varray = me->fct_def );

	if( (index != NULL) && (*index != -1) ) i = *index;

	else 
		for( i=0; i<size_fct_att; i++ )
			if( ! strcmp( fct_attrib->name, 
					&me->fct_txt[me->fct_def[i].select] ))
				break;

	if( size_fct_att > i ){

		if( index != NULL )	*index = i;

		strcpy( fct_attrib->name, &me->fct_txt[me->fct_def[i].select] );

		fct_attrib->desc.type = AC_ATTRIB_TEXT | 
					AC_ATTRIB_EVAL | 
					AC_ATTRIB_PRIVATE | AC_ATTRIB_LOCK;

		strcpy( fct_attrib->desc.value.att_txt,
				&me->fct_txt[me->fct_def[i].fct_name]);

		*fct_ptr = me->fct_def[i].fct_add;

	} else *rc = MSFAIL;

return	OM_S_SUCCESS;
}

/* *********************** MSG NDsleep () *****************************	*/

method NDsleep( struct GRmd_env *md_env )
{
IGRlong		sts;
IGRint		size_fct_att;
IGRint		i;

	/*| send normal sleep */
	sts = om$send(	msg	 = message ACrg_collect.NDsleep( md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

	/*| set to NULL ptr_fct */
	size_fct_att = om$dimension_of( varray = me->fct_def );

	for( i=0; i<size_fct_att; i++ )	me->fct_def[i].fct_add = 0;

return	sts;
}

/* **************** MSG ACget_att_prop () *****************************	*/

method ACget_att_prop( IGRlong *rc; IGRchar *att_name; 
				IGRshort *int_prop; IGRshort *user_prop )
{
IGRint	i;

	for( i=0; i<me->nb_attr; i++ )
		if( ! strcmp( att_name, &me->attr_name[me->attr_def[i].name] ))
			break;

	if( i >= me->nb_attr )	*rc = MSFAIL;

	else {

		*int_prop  = me->attr_type[i] & AC_ATTRIB_MASK_PROP;
		*user_prop = me->attr_type[i] & AC_ATTRIB_MASK_USER;
		*rc = MSSUCC;
	}

return	OM_S_SUCCESS;
}

/* **************** MSG ACset_att_prop () *****************************	*/

method ACset_att_prop( IGRlong *rc; IGRchar *att_name; 
				IGRshort int_prop; IGRshort user_prop )
{
IGRint	i;

	for( i=0; i<me->nb_attr; i++ )
		if( ! strcmp( att_name, &me->attr_name[me->attr_def[i].name] ))
			break;

	if( i >= me->nb_attr )	*rc = MSFAIL;

	else {
		me->attr_type[i] &=  ~ (AC_ATTRIB_MASK_PROP |
					AC_ATTRIB_MASK_USER );
		me->attr_type[i] |=  int_prop & AC_ATTRIB_MASK_PROP;
		me->attr_type[i] |=  user_prop & AC_ATTRIB_MASK_USER;
		*rc = MSSUCC;
	}

return	OM_S_SUCCESS;
}


end implementation ACdyn_col;
