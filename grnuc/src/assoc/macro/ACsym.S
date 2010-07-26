/*
/*---------------------------------------------------------------------------
/*  ACsym.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*---------------------------------------------------------------------------*/
class specification ACsym (0:0) of ACcpx;

#include "parametric.h"
#include "macro.h"

instance ACsym 
{
  int  inst_sz;   /* real size not vla which is max of cond */
  int  go_sz;     /* real size not pretgo count which is max of cond */
  variable char inst_save[0];
};

override 	NDcompute_node,
		NDchange_connect, /* unmap before change connect */
		ACbecome_macro;


override 	ACreturn_foot, /* suc = 2 for temporary internal foot */
		ACgive_structure,
		ACgive_path,
		ACrebuild, /* the graphic object are copied and the 	*/
			   /* inst_save vla is set to the right size    */
			   /* and initaliazed with what is in the 	*/
			   /* definition				*/
		ACcompute_node,
		ACmap_from_visible;

/* PRIVATE MESSAGES */
/* used  with give foot */
message ACmap_to_defn();
message ACunmap_fr_defn();

/* build instance save */
message ACput_s_inst(int *size;char *inst_buf);
message ACget_s_inst(int *size;char *inst_buf);
message ACcon_s_inst(int *size;char *inst_buf;int dpsize,obsize;
		    char *dpbuf,*macro_name);

/* kludges to make dim faster */
message ACchange_intn(int *suc,prop;char *full_name; struct GRmd_env *md_env;
                      OM_S_OBJID *list;int *count;
                      int *sz_inst_save;char *inst_save);
message ACchange_feet(int *suc,numb;char **feet_name,**macro_name;
		      struct GRmd_env *md_env );

message ACplace(int *suc,prop     ; char *macro_name;
		 int numb_obj;  struct GRid *uplist);
message ACmplace(int *suc,prop     ; char *macro_name;
		 int numb_obj;  struct GRid *uplist;struct GRmd_env *mod_env);
/*---------------------------------------------------------------------------
/* 	This message is used to place an occurence of a symbol macro 
/*	in the design file.  It copies visible data of the macro_definition 
/*	into the dgn space and recomputes depending on the real parent given.
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	prop			I : 
/*
/* 	#define AChdr_nobuild   	1  exit before rebuild  	*/
/* 	#define AChdr_nocompute 	2  exit before compute 		*/
/* 	#define AChdr_nodisplay 	4  exit before display  	*/
/* 	#define AChdr_noprotect 	8  exit before display  	*/
/* 	#define AChdr_norange        	16 exit before adding in range  */
/*
/*	char *macro_name	I : the macro to place
/*
/*	int numb_obj		I : the number of real template
/*
/*	struct GRid *uplist	I : the list of templates
/*
/*---------------------------------------------------------------------------*/

message ACchange(int *suc,prop;char *full_name; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* 	Deletes the current copy visible data of macro and replace it with the
/*   	macro definition of the given name 
/*  	note the user must ensure that template and feet structures 
/*   	are consistent between the macros.
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	char *full_name		I : the name of the new macro used to replace 
/*				the old one
/*
/*	struct GRmd_env *md_env I :
/*
/*---------------------------------------------------------------------------*/


end specification ACsym;
