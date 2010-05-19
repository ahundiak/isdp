/* $Id $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdassoc / ACrg_coli.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	10/23/90	LLC		Creation Date
 * [1] The method ACreturn_foot had non-defined CHANSELECT occurence.
 *     ACrg_collect objects and associative objects defined in the :IGENOD
 *     directory as activated (wake_up) before super_para.wake_up() method.
 *
 * [2] There is a memory overwritten problem in the method ACreturn_foot.
 *     The argument "foot_name" can loose it's buffer when the instance
 *     variable attr_name needs to be extended. The first entry of the
 *     collector is the most dangerous one.  (adz/rad).
 *
 * adz: 05/28/94 : integrated as dloadable for in I/VDS.
 *
 *      10/21/00	Rama Rao	Check for instance and add if it is
 *					NULL, set nb_attr to zero.
 *				if( me->attr_name == NULL ) me->nb_attr = 0;
 *	08/15/01	AdZ	Add method translate to avoid a crash. MP2625;
 * -------------------------------------------------------------------*/
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

#define	AS_DEBUG
#define	AC_ATTRIB_REF	0x8	/* define type for cs attribute */

extern	GRclassid	OPP_ACpretend_class_id,OPP_text_exp_class_id,
			OPP_expression_class_id;
from	ACpretend	import	ACgive_downscan;
from	ACpretend	import	ACpconnect;
from expression import modify,NDset_value;

extern IGRboolean ASbroadcast_in_progress;

#include <alloca.h>

/* ************** MSG AClist_attribute () *****************************	*/

method AClist_attribute( IGRlong *rc; IGRint list_len; 
				struct ACrg_coll *list_att; IGRint *nb_attr )

{
IGRint		i;


	/*| initialization */

	if( me->attr_name == NULL ) me->nb_attr = 0;
        else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

	if(rc != NULL) *rc = MSSUCC;
	if( nb_attr != NULL) *nb_attr = me->nb_attr;
	if( list_att == NULL )	return	OM_S_SUCCESS;

	for( i=0; i<me->nb_attr && i<list_len; i++ ) {

		strcpy( list_att[i].name, 
				&me->attr_name[me->attr_def[i].name] );

		list_att[i].desc.type = me->attr_type[i]&AC_ATTRIB_MASK_TYPE;

		switch( list_att[i].desc.type ) {

		case AC_ATTRIB_REF :
		case AC_ATTRIB_DOUBLE :

			list_att[i].desc.value.att_exp = 
					me->attr_exp[me->attr_def[i].index ];
			break;

		case AC_ATTRIB_TEXT :

			strcpy( list_att[i].desc.value.att_txt, 
					&me->attr_txt[me->attr_def[i].index ] );
			break;

		case AC_ATTRIB_CONNECT :

			printf("\tvalue : not trait \n");
			break;

		default :

			printf(" unknown type %d of attribute\n", 
							me->attr_type[i] );
		}

	}/*end for*/


return	OM_S_SUCCESS;
}

/* *********** MSG ACrem_attribute () ********************************	*/

method ACrem_attribute( IGRlong *rc; IGRchar *name )

{
IGRlong		sts;
IGRint		i;

	if( me->attr_name == NULL ) me->nb_attr = 0;
	else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

	/*| find name in attribute list */
	for( i=0; i<me->nb_attr; i++ )
		if( strcmp( name, &me->attr_name[me->attr_def[i].name] ) == 0 )
			break;
	if( i >= me->nb_attr ){
		*rc	= OM_E_ABORT;
		return	OM_S_SUCCESS;
	}

	/*" name : %s is the %dth attribute\n", name, i */
	sts = om$send(	msg	 = message ACdiowner.ACrem_att_at_index
						( rc, i ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACrem_att_at_index", 
							action = RET_STATUS );

return	OM_S_SUCCESS;
}


/* ************ MSG ACrem_att_at_index () *****************************	*/

method ACrem_att_at_index( IGRlong *rc; IGRint index )

{
IGRlong		sts;
IGRint		previous_size;
IGRint		name_size;
IGRint		name_index;
IGRint		i, j, total_attr_size;
IGRint		val_ind;
IGRint		cond;
int remove_type;


	/*| initialization */
	*rc	= MSSUCC;

	if( me->attr_name == NULL ) 
	{
		*rc     = MSFAIL;
                return  OM_S_SUCCESS;
	}
        else if( om$dimension_of(varray=me->attr_name) == 0 )
        {
                *rc     = MSFAIL;
                return  OM_S_SUCCESS;
        }

	if( me->prop_mgr & AC_BOX_LOCKED ){

		printf(" box is locked \n");
		*rc	= MSFAIL;
		return	OM_S_SUCCESS;
	}

	val_ind = me->attr_def[index].index;

	me->nb_attr -= 1;

	/*| compress name */

	name_index	= me->attr_def[index].name;
	name_size	= strlen(&me->attr_name[name_index])+1;
	previous_size = om$dimension_of(varray = me->attr_name);

	OM_BLOCK_MOVE(	&me->attr_name[name_index+name_size],
			&me->attr_name[name_index],
			previous_size - name_index - name_size);

	sts = om$vla_set_dimension(	varray	= me->attr_name,
					size	= previous_size - name_size );

 	/* compress attr_def */

	total_attr_size = om$dimension_of(varray = me->attr_def);

	for( i=index; i<total_attr_size-1; i++ )
	       {
		me->attr_def[i].name  = me->attr_def[i+1].name - name_size;
		me->attr_def[i].index = me->attr_def[i+1].index;
	       }
	sts = om$vla_set_dimension(	varray = me->attr_def,
		  			size = total_attr_size -1);
	as$status( sts = sts );

	/*| compress array of attr_type */

	remove_type = me->attr_type[index];
	for( i=index; i<me->nb_attr; i++ )
		me->attr_type[i] = me->attr_type[i+1];
	sts = om$vla_set_dimension(	varray	= me->attr_type,
					size	= me->nb_attr );
	as$status( sts = sts );



	/*| compress value */

	switch( remove_type  ){

	case AC_ATTRIB_REF :
	case AC_ATTRIB_DOUBLE :

		previous_size	= om$dimension_of( varray = me->attr_exp );
		previous_size--;
		for( i=val_ind; i<previous_size; i++ )
			me->attr_exp[i] = me->attr_exp[i+1];
		sts = om$vla_set_dimension(	varray	= me->attr_exp,
						size	= previous_size );
		as$status( sts = sts );

		/* modify attr_def[x].index */
		for( i=index; i<me->nb_attr; i++ )
			if( me->attr_type[i] == AC_ATTRIB_DOUBLE )
				me->attr_def[i].index -= 1 ;
		break;

	case AC_ATTRIB_TEXT :

		previous_size	= om$dimension_of( varray = me->attr_txt );
		name_size	= strlen( &me->attr_txt[val_ind] ) + 1;

		/*| transfert text */
		cond = val_ind + name_size;
		for( i=cond, j=val_ind; i<previous_size; i++, j++ )
			me->attr_txt[j] = me->attr_txt[i];

		/*| reduce vla dim */
		sts = om$vla_set_dimension(
				varray	= me->attr_txt,
				size	= previous_size - name_size );
		as$status( sts = sts );

		/*| modify index of attr_def */
		for( i=index; i<me->nb_attr; i++ )
			if( me->attr_type[i] == AC_ATTRIB_TEXT )
				me->attr_def[i].index -= name_size;
		break;

	case AC_ATTRIB_CONNECT :

		/*| free channel at val_ind  not yet implemented */
		break;

	default :
		printf(" unknow type %d for attribute\n", me->attr_type[index] );
		*rc	= MSFAIL;
		return	OM_E_ABORT;
	}

return	OM_S_SUCCESS;
}

/* **************** MSG ACgive_structure () ***************************	*/

method ACgive_structure( IGRint	*rc; IGRint *direct_index; IGRchar *footname;
				struct ret_struct *foot_str;
				struct GRmd_env *md_env )
{
IGRlong		msg;
IGRint		i;

	/*| initialization */
	*rc	= 1;

	/*" footname : %s\n", footname */
	if( me->attr_name == NULL ) me->nb_attr = 0;
	else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

	for( i=0; i<me->nb_attr; i++ )
		if( strcmp( footname, 
				&me->attr_name[me->attr_def[i].name] ) == 0 )
			break;
	if( i >= me->nb_attr ){

		/*| no corresponding attribute */
		*rc	= 0;
		return	OM_S_SUCCESS;
	}

	switch( me->attr_type[i] ) {

	case AC_ATTRIB_DOUBLE :
		foot_str->type = double_type;
		foot_str->var.root_pm_st.value = 
					me->attr_exp[me->attr_def[i].index];
		break;

	case AC_ATTRIB_REF :
		foot_str->type = ref_generic;
		MAidmx( &msg, foot_str->var.ref_st.t );
		break;

	case AC_ATTRIB_TEXT :
		foot_str->type = text_type;
		strcpy( foot_str->var.text_st.text_string,
					&me->attr_txt[me->attr_def[i].index] );
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

method  NDsleep(struct GRmd_env *md_env)
{
 long status;
 char *length,*strchr();


/* Delete members created by ACreturn_foot */

 if( me->attr_name == NULL ) me->nb_attr = 0;
 else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

status = om$send(msg = message NDnode.NDdelete(md_env),
                 p_chanselect = &AS_to_comp);

/* reduce size of my instances if possible */

status = om$vla_set_dimension(varray = me->attr_def, size = me->nb_attr);

length  = 0;
if( me->nb_attr ){
        length = strchr(me->attr_name+me->attr_def[me->nb_attr-1].name,'\0');
        if(length)      length = (char *)(length - me->attr_name + 1);
}
status = om$vla_set_dimension(varray = me->attr_name,
                              size = (IGRuint)length );
return om$send(msg = message NDnodein.NDsleep(md_env),
               mode = OM_e_wrt_message,
               targetid = my_id);
}

/* **************** MSG ACreturn_foot () ****************************** */

method ACreturn_foot( IGRlong *rc; IGRchar *foot_name; struct GRid *foot_GRid;
                        IGRshort *mat_type; IGRdouble *matrix )

{
IGRlong                 loc_msg, status;
struct  GRid            my_grid;
GRclassid               exp_class,exp_class1;
struct  ACrg_coll       attrib;
int total_size, i_attr, nb_comp;
int name_size, previous_size;
long owner_index;
short exp_rc;
IGRboolean save_br;

/*| initialization */
  *rc           = 1;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  if( me->attr_name == NULL ) me->nb_attr = 0;
  else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

/*" foot_name : %s\n", foot_name */

  if( foot_name[0] == '\0' )
   {
    *foot_GRid = my_grid;
    if( mat_type != NULL ) *mat_type = MAIDMX;
    if( matrix != NULL ) MAidmx( &loc_msg, matrix );
    return OM_S_SUCCESS;
   }

/*| test if foot name exist */

  strcpy( attrib.name, foot_name );
  status=om$send(msg= message ACrg_collect.ACget_named_attribute
                                                            (&loc_msg, &attrib),
                 targetid = my_id );
  as$status( );

  if( !(loc_msg&1)){ *rc = 0; return OM_S_SUCCESS; }

  if(attrib.desc.type == AC_ATTRIB_TEXT) exp_class = OPP_text_exp_class_id;
  else exp_class = OPP_expression_class_id;

/* Make sure attr_def has a correct size */
   status = om$get_channel_count(objid = my_id,
                            p_chanselect = &AS_to_comp,
                            count = (OMuint *) &nb_comp);

   total_size = om$dimension_of(varray = me->attr_def);
   total_size = total_size < nb_comp+me->nb_attr ?
                total_size : nb_comp+me->nb_attr ;

/* Search if I have already a temporary member expression with that name */

   for(i_attr = me->nb_attr ; i_attr<total_size ; i_attr++)
     {
      if(!(strcmp(foot_name,me->attr_name+me->attr_def[i_attr].name))) break;
     }

/* initialize stored info for this new created temporary member expression*/

   if(i_attr >= total_size)
     {
      status = om$vla_set_dimension(varray = me->attr_def,
                                    size   = total_size+1);
      as$status(action = RET_STATUS);

      name_size = strlen(foot_name)+1;
      previous_size = om$dimension_of(varray = me->attr_name);
      status = om$vla_set_dimension(varray = me->attr_name,
                         size   =  name_size + previous_size);
      as$status(action = RET_STATUS);

/* START VDS CORRECTION */
      /* OM_BLOCK_MOVE(foot_name,me->attr_name+previous_size,name_size); */
      OM_BLOCK_MOVE(attrib.name,me->attr_name+previous_size,name_size);
/* END   VDS CORRECTION */
      me->attr_def[total_size].name = previous_size;

      status = om$get_channel_count(objid = my_id,
                            p_chanselect = &AS_to_comp,
                            count = (OMuint *) &me->attr_def[total_size].index);

      status = om$construct(classid = exp_class,
                            msg = message NDnode.NDchg_state
                             (ND_SUP_ONLY|ND_WAIT_DEL,ND_SUP_ONLY|ND_WAIT_DEL),
                            p_objid = &foot_GRid->objid);
      foot_GRid->osnum = OM_Gw_current_OS;
      owner_index = OM_K_MAXINT ;
      status = om$send( msg = message GRconnector.GRrigidconn
                                        ( &loc_msg, &my_grid, &owner_index ),
                    targetid = foot_GRid->objid);
      as$status(action = RET_STATUS);
     }
    else
     {
      /* Make sure the type of the expression is correct */

      status = om$get_objid_at_index(objid = my_id,
                            p_chanselect = &AS_to_comp,
                            index = me->attr_def[i_attr].index,
                            objidaddr = &foot_GRid->objid,
                            osnumaddr = &foot_GRid->osnum);
      as$status(action = RET_STATUS);

      om$get_classid (objid = foot_GRid->objid,osnum = foot_GRid->osnum,
                      p_classid = &exp_class1);
      if(exp_class != exp_class1)
       {
        if(exp_class == OPP_text_exp_class_id)
         om$change_class(objid = foot_GRid->objid,classname = "text_exp");
        else
         om$change_class(objid = foot_GRid->objid,classname = "expression");
       }

     }

    /* Update its value */

    save_br = ASbroadcast_in_progress;
    ASbroadcast_in_progress = TRUE;

    if(attrib.desc.type == AC_ATTRIB_TEXT)
     {
      status = om$send(msg = message expression.modify
                                (NULL,attrib.desc.value.att_txt,&exp_rc),
                       targetid = foot_GRid->objid);

     }
    else
     {
      status = om$send(msg = message expression.NDset_value
                                (NULL,attrib.desc.value.att_exp,NULL, &exp_rc),
                       targetid = foot_GRid->objid);
     }
    as$status();


    ASbroadcast_in_progress = save_br;


/* now dummy context */

  if( mat_type != NULL ) *mat_type = MAIDMX;
  if( matrix != NULL ) MAidmx( &loc_msg, matrix );

return  OM_S_SUCCESS;

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



	if(options & OPT_SYS){

		/*| Dump returns nothing because after NDsleep or before AC wakeup */
		*count = 0;
		*stat = DIR_S_SUCCESS;
		return	OM_S_SUCCESS;
	}

	/*" nb_attr : %d\n", me->nb_attr */

	if( me->attr_name == NULL ) me->nb_attr = 0;
	else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

        ft = NULL;
	mname = NULL;
	if( me->nb_attr ){

		ft = (struct GRid *) om$malloc 
			( size = me->nb_attr * sizeof( struct GRid ));
		mname = (char **) om$malloc 
			( size = me->nb_attr * sizeof( char ** ));
	}

	*count = *count + me->nb_attr;

	for( i=0; i<me->nb_attr; i++ ){

		/*| get temporary pretend */
		sts = om$send(	msg	 = message ACrg_collect.ACreturn_foot(
						&msg,
						&me->attr_name[me->attr_def[i].
									name],
						&ft[i],
						NULL,
						NULL ),
				targetid = my_id );
		as$status( sts = sts, msg = "Error in msg ACreturn_foot" );
		/*" pret[%d] : id/os = (%d/%d)\n", i, ft[i].objid, ft[i].osnum */

		/*| feel name array */
		mname[i] = om$malloc( 
			size = strlen(&me->attr_name[me->attr_def[i].name])+1); 
		/*" malloc %d\n", strlen(&me->attr_name[me->attr_def[i].name])+1 */

		strcpy( mname[i],&me->attr_name[me->attr_def[i].name] );
		/*"attr %d name %s id %d %d\n",i,mname[i],ft[i].objid,ft[i].osnum*/

	}/*end for*/

	*grids= (DIgrid *) ft;
	*lines=mname;
	*stat= DIR_S_SUCCESS;

return	OM_S_SUCCESS;
}

/* *************** MSG ACget_named_attribute () ***********************	*/

method ACget_named_attribute( IGRlong *rc; struct ACrg_coll *attrib )

{
IGRint		i;
IGRlong		sts;

	/*| initialization */
	*rc	= TRUE;
	if( me->attr_name == NULL ) me->nb_attr = 0;
	else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

	for( i=0; i<me->nb_attr; i++ )

		if( ! strcmp( attrib->name, 
				&me->attr_name[me->attr_def[i].name] ) ) {

			sts = om$send(	msg	 = message 
					ACrg_collect.ACget_attribute_at_index
							( rc, i, attrib ),
					targetid = my_id );
			as$status( sts = sts );

			break;
		}

	if( i == me->nb_attr )	*rc	= FALSE;

return	OM_S_SUCCESS;
}

/* *********** MSG ACget_attribute_at_index () ************************	*/

method ACget_attribute_at_index( IGRlong *rc; IGRint index; 
					struct ACrg_coll *attrib )
{

	/*| initialization */
	*rc	= MSSUCC;

	if( me->attr_name == NULL ) me->nb_attr = 0;
	else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

	if( index < 0 || index >= me->nb_attr ) {

		/*" no attribut a index : %d\n", index */
		*rc	= MSFAIL;
		return	OM_S_SUCCESS;
	}

	*rc	= MSSUCC;

	strcpy( attrib->name, &me->attr_name[me->attr_def[index].name] );

	attrib->desc.type = me->attr_type[index] & AC_ATTRIB_MASK_TYPE;

	switch( attrib->desc.type ) {

	case AC_ATTRIB_REF :
	case AC_ATTRIB_DOUBLE :

		attrib->desc.value.att_exp = 
			me->attr_exp[me->attr_def[index].index ];
		break;

	case AC_ATTRIB_TEXT :
		/* Added this check - RR TR# 5063 */
                if( strlen( &me->attr_txt[me->attr_def[index].index ] ) 
                    < ATTR_TXT )
		{
		   strcpy( attrib->desc.value.att_txt,  
		           &me->attr_txt[me->attr_def[index].index ] );
		}
		else
		{
		   strncpy( attrib->desc.value.att_txt,
			    &me->attr_txt[me->attr_def[index].index ], 
			    ATTR_TXT );
		}
		break;

	default :
		printf(" unknown type %d for attribut \n");
		*rc	= MSFAIL;
	}

return	OM_S_SUCCESS;
}

/* *************** MSG ACadd_list_attribute () ************************	*/

method ACadd_list_attribute( IGRlong *rc; IGRint list_len; 
					struct ACrg_coll *list_att )

{

IGRlong		sts;
IGRint		name_size;
IGRint		previous_size;
IGRint		i;
IGRint		ind;
int nb_save,total_att_size,size_att,size_name,init_name_size,new_name_size;
char *saved_name, *saved_attr;
int		nb_comp;


	/*| initialization */
        size_att        = 0;
        size_name       = 0;
        init_name_size  = 0;
        saved_name      = NULL;
        saved_attr      = NULL;
	*rc		= MSSUCC;

	if( me->prop_mgr & AC_BOX_LOCKED ){

		printf(" box is locked \n");
		*rc	= MSFAIL;
		return	OM_S_SUCCESS;
	}

        if( list_att == NULL )	return	OM_S_SUCCESS;

	if( me->attr_name == NULL ) me->nb_attr = 0;
	else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

	/* save info on temporary connected expression */
        sts = om$get_channel_count(     objid   = my_id,
                                p_chanselect    = &AS_to_comp,
                                count = (OMuint *) &nb_comp );
        total_att_size = om$dimension_of(varray = me->attr_def);

        nb_save = total_att_size < me->nb_attr+nb_comp ?
                        total_att_size - me->nb_attr : nb_comp;

	if(nb_save > 0 )
	 {
	  size_att = nb_save * sizeof(struct ACattr);
	  saved_attr = (char *) alloca(size_att);

	  init_name_size = me->attr_def[me->nb_attr].name;
	  size_name = om$dimension_of(varray = me->attr_name) - init_name_size;
	  saved_name = (char *) alloca(size_name);
	  
	  
	  if(saved_attr == NULL || saved_name == NULL) return OM_W_ABORT;

	  OM_BLOCK_MOVE(me->attr_def+me->nb_attr,saved_attr,size_att);
	  OM_BLOCK_MOVE(me->attr_name+me->attr_def[me->nb_attr].name,
			saved_name,size_name);
	  om$vla_set_dimension(varray = me->attr_name,
			   size = me->attr_def[me->nb_attr].name);
	  om$vla_set_dimension(varray = me->attr_def,
				size = me->nb_attr );
 	 }

	for( ind=0; ind<list_len; ind++ ){

		/*| check if name no not exist */
		for( i=0; i<me->nb_attr; i++ )
			if( strcmp( list_att[ind].name, 
					&me->attr_name[me->attr_def[i].name] ) 
						== 0 ){

				*rc		= MSFAIL;
				break;
			}
		if( i < me->nb_attr) continue;

		/*| check if type is AC_ATTRIB_TYPE_NOT_DEF */
		if( (list_att[ind].desc.type & AC_ATTRIB_MASK_TYPE) 
				== AC_ATTRIB_TYPE_NOT_DEF )
			ACcol_set_type_val(	list_att[ind].desc.value.att_txt,
						&list_att[ind] );

		/*| store name of attribut in ACrg_collect */
		name_size = strlen( list_att[ind].name ) + 1;
	
		previous_size = om$dimension_of( varray	= me->attr_name );

		sts = om$vla_set_dimension(	
					varray	= me->attr_name,
					size	= previous_size + name_size );
		as$status( sts = sts, action = RET_STATUS );
		OM_BLOCK_MOVE( list_att[ind].name, 
				&me->attr_name[previous_size], name_size );

		/*| store info about attr_name */
		sts = om$vla_set_dimension(	varray	= me->attr_def,
						size 	= me->nb_attr + 1 );
		as$status( sts = sts, action = RET_STATUS );
		me->attr_def[me->nb_attr].name = previous_size;


		/*| store type of component */
		sts = om$vla_set_dimension(	varray	= me->attr_type,
						size 	= me->nb_attr + 1 );
		as$status( sts = sts, action = RET_STATUS );
		me->attr_type[me->nb_attr] =
				 list_att[ind].desc.type & AC_ATTRIB_MASK_TYPE;

		switch( me->attr_type[me->nb_attr] ) {

		case AC_ATTRIB_REF :
		case AC_ATTRIB_DOUBLE :

			previous_size = om$dimension_of(varray	= me->attr_exp);

			sts = om$vla_set_dimension(varray = me->attr_exp,
						   size = previous_size + 1 );
			as$status( sts = sts, action = RET_STATUS );

			me->attr_exp[previous_size] = 
					list_att[ind].desc.value.att_exp;

			me->attr_def[me->nb_attr].index = previous_size;
			break;

		case AC_ATTRIB_TEXT :

			name_size = 
				strlen( list_att[ind].desc.value.att_txt ) + 1;

			previous_size = om$dimension_of( 
						varray	= me->attr_txt );

			sts = om$vla_set_dimension(
					varray	= me->attr_txt,
					size	= previous_size + name_size );
			as$status( sts = sts, action = RET_STATUS );
			OM_BLOCK_MOVE( list_att[ind].desc.value.att_txt, 
				&me->attr_txt[previous_size], name_size );
			me->attr_def[me->nb_attr].index = previous_size;
			break;

		case AC_ATTRIB_CONNECT :
			printf(" connect a faire \n");
			/*| stocker dans index l'index du channel to_component */
			break;

		default :
			printf(" unknown type %d for attribut \n");
			*rc	= MSFAIL;
			return	OM_E_ABORT;
		}

		me->nb_attr++;

	}/*end for*/

	/* restore info on temporary connected expression */

	if(nb_save > 0)
	 {
	  om$vla_set_dimension(varray = me->attr_def,
			   size   = me->nb_attr + nb_save);
	  OM_BLOCK_MOVE(saved_attr,me->attr_def+me->nb_attr,size_att);

	  new_name_size = om$dimension_of(varray = me->attr_name);
	  om$vla_set_dimension(varray = me->attr_name,
			   size = new_name_size + size_name);

	  OM_BLOCK_MOVE(saved_name,me->attr_name+new_name_size,
			size_name);
	  for(i=me->nb_attr;i<me->nb_attr+nb_save;i++)
	   { me->attr_def[i].name +=  new_name_size - init_name_size; }

 	 }

return	OM_S_SUCCESS;
}

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

	if( me->attr_name == NULL ) me->nb_attr = 0;
	else if( om$dimension_of(varray=me->attr_name) == 0 ) me->nb_attr = 0;

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

/* ****************** MSG translate () ******************************** */

method translate( DIint *rc; DIchar *name; DIint index; DIchar *p_name;
                        DIobjid *objid )

{
IGRlong         sts, msg;
struct  GRid    foot;

        *rc     = DIR_W_NAME_NOT_FOUND;

	if( ! objid ){
		*rc = DIR_W_NOT_IMPL;
		return  OM_S_SUCCESS;
	}

        *objid  = NULL_OBJID;
	  
        /*" translate : %s\n", name */
        sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                        &msg,
                                        name,
                                        &foot,
                                        NULL,
                                        NULL ),
                        targetid = my_id );
        /*" foot : id/os = (%d/%d)\n", foot.objid, foot.osnum */
        if( sts & msg & 1 ){
                if( objid) *objid  = foot.objid;
                *rc     = DIR_S_SUCCESS;
        }

	return  OM_S_SUCCESS;
}


end implementation ACrg_collect;

