/*
   ABSTRACT :
 Subclass of macro definition to implement conditional 
*/


class specification ACcond_def(0:1) of ACmacro_defn;

#include "ACcondit.h"
instance ACcond_def
 { 
  variable struct ACcond_descrip condit[0]; 
  variable struct ACcond_temp    temp_default[0];
  variable int  	         feet_default[0];
  struct GRid active_rep;
 };

override	ACbuild_macro,		/* builds defn without graph */
		ACconstruct_feet,	/* user representation to find true*/
		ACcopy_definition,	/* jla march 93 */
		ACcontext_compute_feet;


message ACfind_rep(IGRlong *msg; int tempsz ;
		   struct GRid sym; struct GRid *list;
		   struct GRid *rep_def;
		   int *active_index;
		   struct GRmd_env *md_env);


/*---------------------------------------------------------------------------
/*   Find the construction corresponding to the value of the conditionnal
/*
/*      Argument description :
/*      --------------------
/* long *msg     O : return code 1 --> definition found
/*			        0 --> not found
/* int  tempsz   I : template size
/* GRid sym      I : computed macro occurence
/* GRid *list    I : template of the occurence
/* GRid *rep_def O : returned macro definition
/* 
/*---------------------------------------------------------------------------*/

message ACmap_temp(int active_index; int my_temp_num; struct GRid *my_temp;
		   int his_temp_num; struct sup *his_temp_desc;
		   struct GRid *his_temp; struct GRmd_env *md_env);

message ACmap_feet(int active_index; int my_temp_num; struct myfeet *his_feet_desc;
		   struct GRid *his_feet, *my_feet; int *fmax);

message ACtake_feet(int feet_num; char *feet_name; int *chan_index);

message ACtake_condit(char *condit_name; int num_condit; struct GRid *macro;
		      struct ACcond_val *value;
		      int *num_default;struct ACcond_temp *def_temp);

message ACgive_condit_desc(int *num_condit; struct ACcond_descrip **condit_desc;
			   int *num_default;struct ACcond_temp **temp_default);
end specification ACcond_def;
