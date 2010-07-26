/*
  ACcpxi.I
  ludovic le corvec
  7-jan-91
*/

class implementation ACcpx;

#define AS_DEBUG

#include "asbox.h"
#include "AS_status.h"

#define	ACS_CMP_LEAVE	0x3

extern	GUprocessplot();

/* ********************** MSG GRlocate () *****************************	*/

method GRlocate( struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key )

{
IGRlong		sts;
OMuint		nb_foot;
OMuint		i;
IGRint		j;
OM_S_OBJID	*cmp_list;
IGRint		list_len;
IGRint		nb_cmp;
IGRint		resp;
IGRshort	loc_os;


	/*| initialization */
	cmp_list	= NULL;

	if( cvl->attributes.type == GR_nam_loc ){

		/*| loacate obj by name */
		sts = om$send(	msg	= message ASnode.GRlocate
					( cvl, range_key ),
				mode	= OM_e_wrt_message,
				targetid = my_id );
		as$status( sts = sts );

	} else {

		sts = om$get_channel_count(	objid	= my_id,
						p_chanselect = &AS_to_comp,
						count	= &nb_foot );
		as$status( sts = sts );
		/*" nb_foot : %d\n", nb_foot */

		/*| allocation of array of cmp */
		list_len = nb_foot + 20;
		cmp_list = (OM_S_OBJID *) malloc( 
				sizeof( OM_S_OBJID ) * list_len );
		if( cmp_list == NULL ){
			printf(" Error not enougth memory to allocate cmp\n");
			return 	OM_E_ABORT;
		}

		for( i=0; i<nb_foot; i++ ){
 
			sts = om$get_objid_at_index(	
					p_chanselect	= &AS_to_comp,
					object		= me,
					index		= i,
					objidaddr	= &cmp_list[0],
					osnumaddr	= (OMuword *)&loc_os );
			as$status( sts = sts );
			/*" cmp_list : id = %d\n", cmp_list[0] */

			nb_cmp = 1;

			for( j=0; j<nb_cmp; j++ ){

				resp = ACSget_cmp_leave(	loc_os,
								j, 
								&list_len, 
								&cmp_list, 
								&nb_cmp );
				if( ! resp ){
					printf(" Error in fct ACSget_cmp_leave\n");
					return	OM_E_ABORT;
				}

				if( resp == ACS_CMP_LEAVE ){

					/*" leave : id = %d\n", cmp_list[j] */
					sts = om$send(	msg	= message 
							GRgraphics.GRlocate 
								( cvl, range_key ),
							targetid = cmp_list[j] );
					as$status( sts = sts );
					if( sts == OM_I_STOP_SENDING )	goto wrapup;
				}
			}/*end for*/
		}/*end for*/
	  }/*end else*/

wrapup :

	/*| free memory */
	if( cmp_list != NULL )	free( cmp_list );

return	sts;
}


/* ****************** FCT ACSget_cmp_live () **************************	*/

ACSget_cmp_leave( w_os, ind_cmp, list_len, cmp_list, nb_cmp ) 

IGRshort	w_os;
IGRint		ind_cmp;
IGRint		*list_len;
OM_S_OBJID	**cmp_list;
IGRint		*nb_cmp;

/*.ACSget_cmp_leave*/
{
IGRlong		sts;
OMuint		node_nb;
IGRint		i;
struct	GRid	COMP;
IGRshort	cid;
struct	GRid	CMP;
OM_S_OBJID	*LIST;
IGRint		j;


	/*| initialization */
	LIST		= *cmp_list;
	CMP.objid	= LIST[ind_cmp];
	CMP.osnum	= w_os;

	/*| test start_id */
	node_nb	= 0;
	sts = om$get_channel_count(	osnum	= CMP.osnum,
					objid	= CMP.objid,
					p_chanselect	= &AS_to_comp,
					count	= &node_nb );
	/*" node_nb : %d\n", node_nb */

	sts = om$get_classid(	osnum		= CMP.osnum,
				objid		= CMP.objid,
				p_classid	= (OMuword *)&cid );
	as$status( sts = sts );

	if( node_nb == 0 || om$is_ancestry_valid(	
					subclassid	= cid,
					superclassid	= OPP_ACcpx_class_id ) 
						== OM_S_SUCCESS ){

		/*" CMP : id/os = (%d/%d) is a leave \n", CMP.objid, CMP.osnum */
		return	ACS_CMP_LEAVE;
	}

	if( *list_len - *nb_cmp < node_nb ){

		*list_len += (node_nb + 20);

		/*" realloc the list : %d\n", list_len */
		LIST = (OM_S_OBJID *) realloc ( LIST, 
					sizeof( OM_S_OBJID ) * *list_len );
		if( LIST == NULL ){
			printf(" Error not enougth memory to reallocate LIST\n");
			*cmp_list = NULL;
			return	FALSE;
		}
	}

	for( i=0; i<node_nb; i++ ){

		sts = om$get_objid_at_index(	osnum	= CMP.osnum,
						objid	= CMP.objid,
						p_chanselect	= &AS_to_comp,
						index		= i,
						objidaddr	= &COMP.objid,
						osnumaddr	= &COMP.osnum );
		as$status( sts = sts );

		for( j=0; j<*nb_cmp; j++ )
			if( LIST[j] == COMP.objid )	break;

		if( j == *nb_cmp ){

			LIST[*nb_cmp]	= COMP.objid;
			*nb_cmp +=1;
		}

	}/*end i*/

	*cmp_list = LIST;

return	TRUE;
}

/* for plot */
#include "grsymdef.h"

method GRplotyourself ( IGRlong *msg; struct GRmd_env *mod_env;
		        IGRchar *dgn_buf; IGRchar *bs_buf;
		        IGRchar *ele_buf; IGRint *ele_size;
		        IGRint *file_des; IGRdouble *max_overflow;
		        struct GRid *window_id; IGRdouble *scale_factor )

{
    IGRlong                 om_msg;
    OM_S_CHANSELECT         chansel;
    struct GRfunction_info *func_info;
    struct GRmd_env        *old_md_env;
    IGRlong                 old_index1, old_index2;

    struct plot_element_args
    {
	IGRlong		*internal_msg;
	struct GRmd_env *md_env;
	IGRchar		*design_buffer;
	IGRchar		*object_buffer;
	IGRchar		*element_buffer;
	IGRlong		*element_size;
	IGRlong		*file_descriptor;
	IGRdouble	*max_overflow;
	struct GRid	*id_info;
	IGRdouble	*scale_factor;
    } *plot_args;

    struct user_info
    {
	OM_S_MESSAGE   *plot_msg;
	struct IGRcv_prism *prism_array;
	IGRlong	   	num_prisms;
	IGRlong	   	index1,index2;
	IGRint		*levels;
    } *my_info;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        GUgetfunc_info(msg, &func_info);

        my_info = (struct user_info *)func_info->info;
        plot_args = (struct plot_element_args *)
                        (my_info->plot_msg->p_arglist);
        old_md_env = plot_args->md_env;
        plot_args->md_env = mod_env;

        /*
            Save the current channel indices so that nothing already
            on the owner channel gets unintentionally deleted.
        */

        old_index1 = my_info->index1;
        old_index2 = my_info->index2;

        om$get_channel_count (osnum = plot_args->id_info[1].osnum,
                              objid = plot_args->id_info[1].objid,
                              p_chanselect = &chansel,
                              count = (OMuint *)&my_info->index1);

        my_info->index2 = my_info->index1;

        /*
         * The GUprocessplot is sent instead of a GRplotyourself
         * because none of the graphic elements have received the
         * GRplotprep message since they are not in the rtree.
         * GUprocessplot will send the GRplotprep and then the
         * GRplotyourself to each component in the symbol definition.
         */
	om_msg = om$send (msg = message GRgraphics.GRfunction
                                                ( msg,
                                                  GUprocessplot,
                                                  (IGRchar *)func_info ),
                          p_chanselect = &chansel );

        my_info->index1 = old_index1;
        my_info->index2 = old_index2;
        plot_args->md_env = old_md_env;

    }

    return (om_msg);

}


end implementation ACcpx;

