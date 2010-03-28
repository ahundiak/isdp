/*
/*  History :
/*	LLC :- 15_9_91	 + creation date
/*
/* */

class implementation ACci_header;

#include "OMmacros.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "acrepdef.h"
#include "acrepmacros.h"
#include "macro.h"

#define	gen_rg_collect		0x00010800	/* temp def */
#define	AS_DEBUG

from	ACmacro_defn	import	ACgive_upscan;
from	ACcpx_defn	import	ACgive_temp_desc;
from	ACmodel_mgr	import	ACreturn_model;

from	ACmodel		import	ACdisconnect_head;

/* *************** MSG GRdrop () **************************************	*/

method	GRdrop( IGRlong *rc; struct GRmd_env *md_env )

{
IGRlong			sts, msg;
IGRint			nb_feet;
struct	GRid		*feet_list;
GRobjid			*copy_list;
struct	GRid		model;
struct	GRid		my_grid;
struct	GRid		loc_foot;
struct	GRmd_env	loc_env;
IGRint			i;
OM_S_OBJID 		objid;


	/*| initialization */
	*rc		= MSFAIL;
	feet_list	= NULL;
	copy_list	= NULL;
	my_grid.objid	= my_id,
	my_grid.osnum	= OM_Gw_current_OS;

	/*| clean header of tf_foot */
	sts = om$send(	msg	 = message ACheader.ACclean_tf_foot
					( &msg, md_env, TRUE ),
			targetid = my_id );

	/*| get share feet */
	sts = om$send(	msg	 = message ACheader.ACget_share_feet_list(
					&msg,
					0,
					NULL,
					&nb_feet ),
			targetid = my_id );
	as$status( sts = sts );
	/*" nb feet : %d\n", nb_feet */

	feet_list = (struct GRid *) malloc( sizeof( struct GRid ) * nb_feet );
	if( feet_list == NULL && nb_feet != 0 ){
		printf(" Error not enougth memory to allocate feet_list\n");
		sts	= OM_E_ABORT;
		goto	wrapup;
	}

	copy_list = (GRobjid *) malloc( sizeof( GRobjid ) * nb_feet );
	if( copy_list == NULL && nb_feet != 0 ){
		printf(" Error not enougth memory to allocate feet_list\n");
		sts	= OM_E_ABORT;
		goto	wrapup;
	}

	sts = om$send(	msg	 = message ACheader.ACget_share_feet_list(
					&msg,
					nb_feet,
					feet_list,
					&nb_feet ),
			targetid = my_id );
	as$status( sts = sts );

	/*| copy to env --> loc_env */
	loc_env	= *md_env;

	/*| build matrix */
	for( i=0; i<3; i++)	loc_env.md_env.matrix[i] = me->matrix[i];
	loc_env.md_env.matrix[3]	= me->origin[0];
	for( i=4; i<7; i++)	loc_env.md_env.matrix[i] = me->matrix[i-1];
	loc_env.md_env.matrix[i]	= me->origin[1];
	for( i=8; i<11; i++)	loc_env.md_env.matrix[i] = me->matrix[i-2];
	loc_env.md_env.matrix[11]	= me->origin[2];
	for( i=12; i<15; i++)	loc_env.md_env.matrix[i] = 0;
	loc_env.md_env.matrix[15]	= 1;

	MAtypemx( &msg, loc_env.md_env.matrix, &loc_env.md_env.matrix_type );

	/*| copy the share feet */
	for( i=0; i<nb_feet; i++ ){

		sts = om$send(	msg	 = message GRgraphics.GRcopy(
						&msg,
						&loc_env,
						md_env,
						&copy_list[i] ),
				targetid = feet_list[i].objid,
				targetos = feet_list[i].osnum );
		as$status( sts = sts );

		/*| up date symbology */
		loc_foot.objid	= copy_list[i];
		loc_foot.osnum	= OM_Gw_current_OS;
		ACSset_tf_foot_symb( &my_grid, &loc_foot );
	}

	/*| disconnect header */
	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message ACmodel.ACdisconnect_head(
					&msg,
					&my_grid,
					md_env ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

	/*| connect copy share feet */
	for( i=0; i<nb_feet; i++ ){

		sts = om$send(	msg	= message Root.connect(
						AS_to_owner,
						i,
						my_id,
						OM_Gw_current_OS,
						AS_to_comp,
						0 ),
				targetid = copy_list[i] );
		as$status( sts = sts );
	}

	/*| chg class header --> const */
	sts = om$change_class(	objid		= my_id,
				classname	= "nci_macro",
				sd_override	= OM_K_change_class_sd_override );
	as$status( sts = sts, action  = RET_STATUS );

	/*| send drop to the nci_macro */
	objid = my_id;
	sts = om$send(	msg	 = message GRowner.GRdrop
					( &msg, md_env ),
			targetid = objid );
	as$status( sts = sts );

	*rc	= MSSUCC;

wrapup :

	/*| free memory */
	if( feet_list != NULL )		free( feet_list );
	if( copy_list != NULL )		free( copy_list );


return	OM_S_SUCCESS;
}

/* ********************************************************************	*/

#define acfail() \
    status = om$send(msg = message ACncpx.NDdelete(&emp_env), \
		       targetid = my_id ); \
    as$status(action = RET_STATUS); \
    return(1);

/* *************** MSG ACmplace_from_def () ***************************	*/

method ACmplace_from_def(int *rc, prop; 	char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
IGRlong			msg, sts;
IGRint			i;
IGRint			tot_up;
IGRint			mac_prop;
struct	GRmd_env	emp_env;
struct	sup		*dsup;
IGRlong			status;
struct	GRid		md_mgr;
struct	GRid		model;
IGRint			j;
struct	GRid		mac_def;
IGRboolean		chg_class_flag;
struct	GRid		my_grid;
struct	GRsymbology	symb;

struct	ret_struct	pardef;
IGRint 			tot_temp;
struct	stemp		*dtemp;
IGRint			int_msg;
int ideb_rep,new_rep;
struct GRid *list;
IGRint			cn_type;
IGRboolean		no_cs;


	/*| initialization */
	*rc			= OM_S_SUCCESS;
	chg_class_flag		= FALSE;
	emp_env 		= *md_env;
	emp_env.md_id.objid 	= NULL_OBJID;
	my_grid.objid		= my_id;
	my_grid.osnum		= OM_Gw_current_OS;
	list = NULL;


/*"rep is %x num_temp %d\n",rep,num_temp */

/* Remove if necessary template 0 which is representation */

  if(rep && temp_list[0].objid == NULL_OBJID)
    {
     num_temp --;
     temp_list++;
     ideb_rep = 1;
    }
  else    ideb_rep = 0;

	if( ! ( prop & AChdr_noprotect )){
		for( i=0;i<num_temp;i++ )
			as$make_source(	go_grid = temp_list[i], 
					as_grid = &temp_list[i] );
	}

	sts = om$send(	msg	 = message NDnode.NDconnect( 
					num_temp, 
					temp_list, 
					NULL_GRID, 
					ND_NEW),
			targetid = my_id);
	as$status( sts = sts, msg = "Error in msg NDconnect" );

/* Verify parent representation consistency */

  if(rep&(AC_FREE_REP|AC_DEP_REP))
   {
    status = ac$compute_rep_value(initial_rep = 0,
                                p_root = temp_list,
                                nb_root = num_temp,
                                resulting_rep = &new_rep);

    if(new_rep&AC_ERROR_REP) return OM_W_ABORT;        /* Inconsistent roots */
    else if(new_rep&AC_FREE_REP)rep=AC_FREE_REP | rep & ~AC_DEP_REP;
                                                       /*roots without rep*/
    else                        rep = new_rep;         /* roots with rep  */
   }

  status = om$send(msg = message ACncpx.ACput_rep(rep,~0),
                   targetid = my_id);
  as$status(action = RET_STATUS);


	/* find macro definition */
	sts = om$send(	msg	 = message ACncpx.ACattach
					( &int_msg, macro_name ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS);
	if( int_msg != 1 ) {acfail()}

	sts = om$send(	msg	 = message ACheader.ACget_model_mgr
					( &msg, &md_mgr ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACget_model_mgr" );
	/*" model_mgr : id/os = (%d/%d)\n", md_mgr.objid, md_mgr.osnum */

	sts = om$send(	msg	 = message ACcpx.find_macro( &mac_def ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg find_macro", action = RET_STATUS );
	/*" mac_def : id/os = (%d/%d)\n", mac_def.objid, mac_def.osnum */

	if( ! ( prop & AChdr_noprotect )) {

		sts = om$send(	msg	 = message ACmacro_defn.ACgive_upscan( 
						&tot_up,
						&mac_prop, 
						&dsup ),
				targetid = mac_def.objid,
				targetos = mac_def.osnum );
		as$status( sts = sts, msg = "Error in msg ACgive_upscan");

		if( mac_prop & ACwith_instances ){
			printf("ACci_header cannot place macros prepared for symbol macro. \n");
			printf("definition needs internal data\n");
			msg = 0; {acfail()}
		}

		if( tot_up != num_temp+ideb_rep) {
			printf("ACncpx.place_real bad template\n");
			msg = 0; {acfail()}
		}


		/* check valid expanded template ( one ref and a list of expression 
			or text_attribut or parameter box */

		sts = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
						( &tot_temp, &dtemp ),
				targetid = mac_def.objid,
				targetos = mac_def.osnum );
		as$status( sts = sts, msg = "Error in msg ACgive_temp_desc" );

		no_cs	= TRUE;
		for( i=ideb_rep; i<tot_temp; i++ ) {

			sts = om$send(	msg	 =  message ACcpx.ACfind_exp_temp_struct( 
							&int_msg, 
							i, 
							&pardef, 
							md_env ),
					targetid = my_id );
		        as$status( sts = sts, action = RET_STATUS );
			/*" found type %x expected %x  \n",pardef.type,dtemp[i].type */
			if( ! (int_msg&1) || 
				( ! IS_SAME_GEOM( pardef.type,dtemp[i].type)&&
					! (dtemp[i].type==~0) )){

				printf( "Place symbol_macro illegal template defn for %s\n",
					dtemp[i].down_scan );
				*rc = 0;
				return	OM_S_SUCCESS;
			}

			/*" shake type of temp : %d\n", pardef.type */
			if( chg_class_flag != TRUE ) 
			switch( pardef.type ){

			case ref_generic :
				no_cs = FALSE;
				/*| ref */
				break;
			case double_type :
				/*| double */
				break;
			case text_type :
				/*| text */
				break;
			case gen_rg_collect :
				/*| rg_collect */
			case macro_generic :
				/*| macro_generic */
				break;

			default :
				chg_class_flag = TRUE;
			}/*end switch*/

		}/*end for*/

		if( no_cs == TRUE || chg_class_flag == TRUE ){

			printf(" Error in template type. Change class of ocurrence from ACheader to nci_macro\n");

			sts = om$change_class(	objid	   = my_id,
						classname   = "nci_macro",
						sd_override = OM_K_change_class_sd_override );
			as$status( sts = sts, msg = "Error in mc change_class",
						action  = RET_STATUS );
			chg_class_flag = TRUE;
			my_grid.objid	= my_id;

		}/*end chg class*/

	}/*end noprotect*/

	if( chg_class_flag != TRUE ) {

		/*| set coordinate systeme data */

		sts = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
						( &tot_temp, &dtemp ),
				targetid = mac_def.objid,
				targetos = mac_def.osnum );
		as$status( sts = sts, msg = "Error in msg ACgive_temp_desc" );

	        /*"tot_temp %d\n",tot_temp */

		for( i=ideb_rep; i<tot_temp; i++ )
	             {
		       /*"temp %d type %d\n",i,dtemp[i].type */
		      
			if( dtemp[i].type & ref_generic ){

				sts = om$send(	msg	 =  message ACcpx.ACfind_exp_temp_struct( 
								&int_msg, 
								i, 
								&pardef, 
								md_env ),
						targetid = my_id );
			        as$status( sts = sts, action = RET_STATUS );

				/*| type ref : set instance data */
				me->origin[0] = pardef.var.ref_st.t[3];
				me->origin[1] = pardef.var.ref_st.t[7];
				me->origin[2] = pardef.var.ref_st.t[11];

				for( j=0; j<3; j++ ){

					me->matrix[j] 	= 
						pardef.var.ref_st.t[j];
					me->matrix[j+3]	= 
						pardef.var.ref_st.t[j+4];
					me->matrix[j+6]	= 
						pardef.var.ref_st.t[j+8];
				}				

				break;
			}/*end ref*/
		      }

		if( i==tot_temp ){
			printf(" Error no cs template for ACheader \n");
			*rc = 0;
			return	OM_S_SUCCESS;
		}

		/*| ask to model_mgr for a model */
/*^
		printf(" num_temp : %d\n", num_temp );
		for( i=0; i<num_temp; i++ )
			printf(" temp[%d] : id/os = (%d/%d)\n", i,
				temp_list[i].objid, temp_list[i].osnum );
*/

/* Generate template for representation */

   
    if((sts&1) && rep&(AC_FREE_REP|AC_DEP_REP))
      {
       if(ideb_rep == 1) temp_list--;
       else
	{
         list =(struct GRid *)om$malloc(size=(num_temp+1)*sizeof(struct GRid));
         if(!list) goto wrapup;
         OM_BLOCK_MOVE(temp_list,list+1,num_temp*sizeof(struct GRid));
         temp_list = list;
	}

       rep  = rep&AC_VDS_REP;
       /*" call generate_rep with value %x rep\n",rep */
       sts = ACgenerate_rep(rep,OM_Gw_current_OS,temp_list);
       num_temp += 1;
      }

		sts = om$send(	msg	= message ACmodel_mgr.ACreturn_model(
						&msg,
			      AChdr_norange | AChdr_nodisplay | AChdr_noprotect,
						rep,
						macro_name,
						num_temp,
						temp_list,
						def_occ,
						md_env,
						&model ),
				targetid = md_mgr.objid,
				targetos = md_mgr.osnum );
		as$status( sts = sts, msg = "Error in msg ACreturn_model", action = RET_STATUS );
		/*" model : id/os = (%d/%d)\n", model.objid, model.osnum */
	
		/*| connect model and header (header owner of model) */
		sts = om$send(	msg	= message Root.connect(
						AS_to_owner,
						0,
						my_id,
						OM_Gw_current_OS,
						AS_to_comp,
						OM_K_MAXINT ),
				targetid = model.objid,
				targetos = model.osnum );
		as$status( sts = sts, msg = "Error in msg connect", action = RET_STATUS );

		/*| set model symbology */
		sts = om$send(	msg	 = message GRvg.GRgetsymb
						( &msg, &symb ),
				targetid = model.objid,
				targetos = model.osnum );
		as$status( sts = sts, msg = "Error in msg getsymb" );

		sts = om$send(	msg	 = message GRvg.GRputsymb
						( &msg, &symb ),
				targetid = my_id );
		as$status( sts = sts, msg = "Error in msg GRputsymb" );

		/*| set instance data */
		me->owner_properties	= 0;
		me->properties		= GRIS_LOCATABLE | GRIS_DISPLAYABLE;

	}/*end chg_class_flag*/

	if( chg_class_flag == TRUE ) {

		if( prop & AChdr_nocompute )	return	OM_S_SUCCESS;
		/*| NDs_compute */
		cn_type = ND_COMP;
		sts = om$send(	msg	 = message ACncpx.NDcompute_node(
						&msg,
						cn_type,
						num_temp,
						temp_list,
						&emp_env ),
				targetid = my_grid.objid );
		as$status( sts = sts, action = RET_STATUS );
	}

	if( prop & AChdr_norange )	return	OM_S_SUCCESS;
	/*| addwrng */
	sts = om$send(	msg 	 = message GRgraphics.GRaddwrng( &msg, md_env ),
			targetid = my_grid.objid );
	as$status( sts = sts, msg = "Error in msg GRaddwrng" );

	if( prop & AChdr_nodisplay )	return	OM_S_SUCCESS;
	/*| display */
	sts = om$send(	msg 	 = message NDnode.NDdisplay
					( 0, GRbd, md_env ),
			targetid = my_grid.objid );
	as$status( sts = sts, action = RET_STATUS );

wrapup :
 if(list != NULL) om$dealloc(ptr = list);

return	OM_S_SUCCESS;
}

/* ************************ MSG init () *******************************	*/

method ci_macro.init( IGRint *rc; IGRint prop; IGRchar *cpx_name; OMuint count;
		struct GRid *list; IGRchar *internal; struct GRmd_env *md_env )

{
IGRlong			sts, msg;
struct	GRid		def_occ;
IGRlong			status;
IGRint			int_msg;
IGRint			tot_up;
IGRint			mac_prop;
struct	sup		*dsup;
struct	GRid		mac_def;
struct	GRmd_env	emp_env;

	def_occ.objid		= NULL_OBJID;
	emp_env 		= *md_env;
	emp_env.md_id.objid 	= NULL_OBJID;

	/* find macro definition */
	sts = om$send(	msg	 = message ACncpx.ACattach
					( &int_msg, cpx_name ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS);
	if( int_msg != 1 ) {acfail()}

	sts = om$send(	msg	 = message ACcpx.find_macro( &mac_def ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg find_macro", action = RET_STATUS );
	/*" mac_def : id/os = (%d/%d)\n", mac_def.objid, mac_def.osnum */

	if( mac_prop & ACwith_instances ){
		printf("ACci_header cannot place macros prepared for symbol macro. \n");
		printf("definition needs internal data\n");
		msg = 0; {acfail()}
	}

	sts = om$send(	msg	 = message ACmacro_defn.ACgive_upscan( 
						&tot_up,
						&mac_prop, 
						&dsup ),
			targetid = mac_def.objid,
			targetos = mac_def.osnum );
	as$status( sts = sts, msg = "Error in msg ACgive_upscan");

	sts = om$send(	msg	 = message ACncpx.ACmplace_from_def(
					rc,
					prop,
					0,
					cpx_name,
					count,
					list,
					&def_occ,
					md_env ),
			targetid = my_id );
return	sts;
}

end implementation ACci_header;

