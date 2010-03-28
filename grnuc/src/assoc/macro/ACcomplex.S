/* 
/*---------------------------------------------------------------------------
/*  ACcomplex.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*	The abstract class ACcomplex implements graph functionalities
/*	necessary for macros.
/*---------------------------------------------------------------------------*/
class specification ACcomplex (0:1) of NDnodein;
           
#include "macro.h"

instance ACcomplex 
{
	variable OM_S_OBJID	others[];	/* object gather with def */

/* MOD LU 
/*  channel {(rel_ordered,one_to_many)NDnodein.to_macros;} other;
/* 
END MOD LU */

};

/* PRIVATE MESSAGES */

/* PUBLIC MESSAGES */

message ACremove_all( int severity );
message ACmremove_all(int *msg, severity; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* 	Remove body of macro,template and macro object 
/*
/*      Argument description :
/*      --------------------
/*	int severity 		I :	0 leave template
/*            				1 kill  template
/*
/*	struct GRmd_env *md_env I :
/*
/*--------------------------------------------------------------------------*/

message ACget_other( IGRlong *msg; IGRint *nb_other; OM_S_OBJID **other_list );
/* ---------------------------------------------------------------------
/*	Get all object use in the definition 
/*	
/*	ARG :
/*	----
/*		*msg            ( OUT ) completion code
/* 		*nb_other	( OUT )	number of element store in list
/* 		**other_list	( OUT )	list of elements
/*
/* --------------------------------------------------------------------	*/

message ACset_other( IGRlong *msg; IGRint nb_other; OM_S_OBJID *other_list );
/* ---------------------------------------------------------------------
/*	Set all object use in the definition 
/*	
/*	ARG :
/*	----
/*		*msg            ( OUT ) completion code
/*		nb_other	( IN  )	number of element store in list
/*		*other_list	( IN  )	list of elements
/*
/* --------------------------------------------------------------------	*/

end specification ACcomplex;


