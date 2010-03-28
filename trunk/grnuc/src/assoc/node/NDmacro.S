/*
  ABSTRACT

  The abstract class NDmacro is the parent class for all the objects 
  that can be used in a macro definition.

  
  HISTORY

  Unknown
*/

class specification NDmacro (0:0) of Root;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "msdef.h"
#include "parametric.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message ACin_macro_def
(
  IGRint *in_def;
);


message ACbecome_macro
(
  IGRlong *msg;
  IGRint position;
  struct GRmd_env *md_env;
);

message ACgive_structure
(
  int *suc;
  int *direct_index;
  char *footname;
  struct ret_struct *ptr_rst;
  struct GRmd_env *md_env;
);

message ACreturn_foot
(
  IGRlong *msg;
  char *footname;
  struct GRid *foot_obj;
  IGRshort *mat_type;
  IGRdouble *matrix;
);

message ACgive_foot
(
  int *suc;
  char *footname;
  struct GRid *foot_obj;
);

message ACtest_foot
(
  long *suc;
  char *footname;
);

message ACcopy_to_Groot
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
);

message ACconsume
(
  IGRlong *msg;
  char *footname;
  int cpy_req;
  struct GRid *cpy_GRid;
  struct GRmd_env *md_env;
);

message ACunconsume
(
  IGRlong *msg;
  char *footname;
);

message ACntf_consume
(
  IGRlong *msg;
);

message ACntf_unconsume
(
  IGRlong *msg;
);

message ACtest_consumed
(
  IGRlong *msg;
);

message ACbubble_up
(
  long *msg;
  char *footname;
  int up_index;
  OM_p_MESSAGE Condition;
  OM_p_MESSAGE Action;
  enum OM_e_wrt_flag delAction;
);

message ACpass_up
(
  long *msg;
  int count;
  struct GRid list [];
  int up_index;
  OM_p_MESSAGE Condition;
  OM_p_MESSAGE Action;
  enum OM_e_wrt_flag delAction;
);

message ACbecome_foot
(
  long *msg;
  struct GRid *new_id;
  struct GRmd_env *md_env;
);

message ACmap_from_visible
(
  OM_S_OBJID **list;
  int *cur_obj_buf;
  int *count;
  int *sz_inst_save;
  int *cur_inst_buf;
  char **inst_save;
);

message ACcompute_node
(
  IGRlong *msg;
  IGRint cn_type;
  IGRint count;
  struct GRid list [];
  struct GRmd_env *md_env;
  int *prop;
  int *size_inst;
  int *no_go;
  char *inst_save;
);

reject 
  ACreturn_foot,
  ACin_macro_def,
  ACcompute_node,
  ACcopy_to_Groot,
  ACconsume,
  ACunconsume,
  ACntf_consume,
  ACntf_unconsume,
  ACtest_consumed,
  ACpass_up,
  ACbubble_up;

#endif

end specification NDmacro;
