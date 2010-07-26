/*
/*---------------------------------------------------------------------------
/*  ACpreroot.S
/*  robert patience
/*  21_feb_88
/*
/*  ABSTRACT
/*		This class implements the object that survived to an 
/*	ACpretend when the object the ACpretend was connected to 
/*	is deleted.  the ACpreroot object saves the returned structure
/*	that was given by the ACpretend before it dies.
/*---------------------------------------------------------------------------*/
class specification ACpreroot (0:0) of NDnodein;

#include "parametric.h"
#include "macro.h"

instance ACpreroot 
{
 struct ret_struct fts;
};



override 	NDmove_to_root,
		NDcopy_to_root,
		NDprint_root,NDprint,
		NDgive_structure;


message ACplace(int *suc;struct ret_struct *fts );
/*---------------------------------------------------------------------------
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	struct ret_struct *fts	I : the returned structure that we want to be
/*				kept in this root pretend.
/*
/*---------------------------------------------------------------------------*/

end specification ACpreroot;
