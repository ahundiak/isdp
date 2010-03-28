/*
/*---------------------------------------------------------------------------
/*  ACmodel_mgr.S
/*  ludovic Le Corvec
/*  15_sept_90
/*
/*  Abstract
/*	New class to collect all model create with a macro_defn.
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification ACmodel_mgr (0:0) of GRcmpowner;


instance ACmodel_mgr
{
};


/*  PRIVATE MESSAGES */

/*  PUBLIC MESSAGES  */

/* ********************************************************************	*/
/*  ACreturn_model
/*
/*	Look on components to find a model corresponding to the parents 
/*	values.
/*	If not find model, create a new one.
/*
/*	*msg		OUT	/* return code */
/*	prop		IN	/* properties to create model */
/*	rep		IN	/* representation of model */
/*	*mac_def_name	IN	/* name of the macro definition */
/*	nb_temp		IN	/* number of template */
/*	*temp		IN	/* GRid list of template */
/*	*def_occ	IN	/* GRid used to store symbologie */
/*	*mod_env	IN	/* module environment to create model */
/*	*model_id	OUT	/* GRid of model find or construct */
/*
/* --------------------------------------------------------------------	*/

message ACreturn_model( IGRlong *msg; IGRint prop; IGRchar rep; IGRchar *mac_def_name;
			IGRint nb_temp; struct GRid *temp; struct GRid *def_occ;
			struct GRmd_env *mod_env;
			struct GRid *model_id );


end specification ACmodel_mgr;

