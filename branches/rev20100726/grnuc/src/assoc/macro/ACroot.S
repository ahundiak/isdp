/*
/*---------------------------------------------------------------------------
/*  ACroot.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*		This class implement the object that survives to a symbol
/*	macro when one of it parents dies. the created ACroot will save
/*	the returned structure of its feet with no way to ever recompute them.
/*	  	Thus if A GRxform is received, it will be dispatched 
/*	to the graphic objects but the feet wont be recomputed.
/*
/*---------------------------------------------------------------------------*/
class specification ACroot (0:0) of ACcpx;

#include "parametric.h"
#include "macro.h"

instance ACroot 
{
variable struct ret_struct fts[0];
};



override 	ACreturn_foot, /* suc = 2 for temporary internal foot */
		ACgive_structure,
		ACgive_path,
		NDmove_to_root,
		NDcopy_to_root,
		ACbuild_rtn_str,
		NDprint;
override 	GRgetobjinfo, 	
		GRxform;


message ACplace(int *suc,prop; 		char *macro_name;
		 int numb_obj;  	struct GRid  *grp_objs;
		 int feet_num;  	struct ret_struct *fts);

message ACmplace(int *suc,prop; 		char *macro_name;
		 int numb_obj;  	struct GRid  *grp_objs;
		 int feet_num;  	struct ret_struct *fts;
		 struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	int prop		I :
/*
/*	char *macro_name	I : the macro definition to connect to
/*
/*	int numb_obj		I : the number of graphic objects
/*
/*	struct GRid  *grp_objs	I : the graphic objects
/*
/*	int feet_num		I : the number of returned structures
/*
/*	struct ret_struct *fts	I : the returned structure to keep as
/*				as a memory of the bygone past.
/*
/*	struct GRmd_env *md_env I :
/*
/*---------------------------------------------------------------------------*/

end specification ACroot;
