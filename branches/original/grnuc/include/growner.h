/*\
Description
   This include file represents strutures and typedefs that are used by
   owners. 

Files
   igrtypedef.h
   igetypedef.h
   gr.h
\*/

#ifndef growner_include
#define growner_include

/*
 *  Defines the structure which defines a object and its environment.
 */

struct GRobj_env
{
   struct GRid       obj_id;
   struct GRmd_env   mod_env;
};

/*
 *  Arguments to the GRclip_function.
 */

struct GRclip_args
{
   IGRlong           *msg;
   struct GRmd_env   *mod_env;
   struct GRmd_env   *target_env;
   IGRchar           *prism;
   struct GRid       *inside_id;
   struct GRid       *outside_id;
   struct GRid       *overlap_id;
   IGRlong           *clip_flag;
};

#endif
