/*
/*---------------------------------------------------------------------------
/*  ACmodel.S
/*  ludovic Le Corvec
/*  15_sept_90
/*
/*  Abstract
/*	New class for model of symbol macro.
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification ACmodel (0:0) of ACconst;


instance ACmodel
{
};

override	GRlocate_owner;	/* stop propagation up of locate */
override	NDdelete;	/* model is out of rtree chg mod_id */
override	NDsleep;	/* delete model if no header is attach */

/*  PRIVATE MESSAGES */


/* PUBLIC MESSAGES */
/* ********************************************************************	*/
/*  ACsame_temp_values
/*
/*	This method test if the given list of templates is compatible with
/*	template of model.
/*		if type of template is an expression test equal values
/*		if type of template is an text compare string.
/*		
/*
/*	*msg		/* return code if TRUE same values FALSE not */
/*	nb_temp		/* number of template */
/*	*temp_list	/* list GRid of templates */
/*	*mod_env	/* module env of header */
/*
/* --------------------------------------------------------------------	*/

message ACsame_temp_values( IGRlong *msg; IGRint nb_temp; 
			struct GRid *temp_list; struct GRmd_env *mod_env );

/* ********************************************************************	*/
/*  ACdisconnect_head
/*
/*	disconnect the header pass and kill itself if they are no more
/*	header connect to him
/*
/*	*msg		/* return code */
/*	*header		/* GRid of header to disconnect */
/*	*md_env		/* module environment of header */
/*
/* --------------------------------------------------------------------	*/

message ACdisconnect_head( IGRlong *msg; struct GRid *header; 
						struct GRmd_env *md_env );


/* ********************************************************************	*/
/*  AChead_place
/*
/*	The model place an header with respect of the given coordinate system
/*
/*	*msg		OUT	/* return code */
/*	temp_prop	IN	/* propriete for create template of header */
/*				/* AC_TEMP_COPY || to be define */
/*	*ref_id		IN	/* template cs id	*/
/*	*header		OUT	/* created header id	*/
/*
/* --------------------------------------------------------------------	*/

message	AChead_place( IGRlong *msg; IGRshort temp_prop; struct GRid *ref_id;
			struct GRid *header; struct GRmd_env *mod_env );


end specification ACmodel;

