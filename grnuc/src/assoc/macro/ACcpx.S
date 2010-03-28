/*
/*---------------------------------------------------------------------------
/*  ACcpx.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*	 The abstact class ACcpx defines instance and methods required for 
/*	the correct behaviour of a complex node entity. A complex node
/*	entity differs from simple node because it manages more than one
/*	geometric or expression entity (foot). That is in a parallel line
/*	the resultant is always a line whereas a complex node representing a
/*	wall might contain 3 lines.
/*	 Complex nodes also can attach to other complex nodes and hence 
/*	contain the name of the feet in their parents that they need to
/*	access to  recompute.
/*	 The data structures defining the feet internal and the access to 
/*	feet in the parents are contained in the class ACcpx_defn. Permiting
/*	all instances of a type of complex to access this data.
/*---------------------------------------------------------------------------*/
class specification ACcpx (0:1) of ASnode;

#include "macro.h"

instance ACcpx 
{
  int  			STATE; 		/* used by ci_macro and ACsym */
/*
  channel {(many_to_many)ACcpx_defn.to_macro_hdr;} to_macro_defn;
*/
  char 			xform_chan,
			xform_pos; 	/* open pathway */
  struct ret_struct 	**rtstr; 	/* virtual feet */
  struct  GRid  mac_def;
};

override 	NDgive_structure,   /* return ACtcomplex as type */
	        NDmove_to_root,
		NDcopy_to_root,
		NDprint_root,
		NDcopy,
		NDdelete,
		NDsleep,
		NDget_parent_type,
		NDctl_parent_type;

override 	GRgetobjinfo,
		ASpossible_parent, 
		GRlocate,		 /* top down locate to cmp */
		GRplotyourself,
		GRcopy,			 /* complex have more than one cmp */
		GRget_locate_properties, /* overiden to allow locate of any of 
					   the graphic object of the complex */
                GRlocate_processing,
                GRxform_owner,
		GRgetsymb; 		 /* override to return the symbology */
					 /* of the first go and "NO_LAYER"   */
	

message find_macro(struct GRid *macro);

/*---------------------------------------------------------------------------
/*		This message is used to find the macro definition
/*	 wich is defined in instance
/*
/*      Argument description :
/*      --------------------
/*
/*	struct GRid *macro	O : the macro definition GRid.
/*
/*---------------------------------------------------------------------------*/

message ACload_macro(struct GRid macro);

/*---------------------------------------------------------------------------
/*		This message is used to load the macro definition
/*
/*
/*      Argument description :
/*      --------------------
/*
/*	struct GRid macro	O : the macro definition GRid.
/*
/*---------------------------------------------------------------------------*/

message ACattach (int *suc;char *macro_name);
/*---------------------------------------------------------------------------
/*		Searches the ":constructs:" directory for the macro 
/*	definition. If not found performs dynamic load of macro 
/*	definition. The dynamic load tries to find a CI file whose name 
/*	is macro_name suffixed by ".u"
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	char *macro_name	I : the macro definition to attach to.
/*
/*---------------------------------------------------------------------------*/


message ACfind_exp_temp_obj   (int *suc,pos;    struct GRid *temp_obj);
/*---------------------------------------------------------------------------
/* 		Given posion in expanded template give object by 
/*	searching complex template.
/*
/*      Argument description :
/*      --------------------
/*	
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	int pos			I : the position of the template to find.
/*				This position is the index relative to the
/*				order that was used to define templates
/*				at macro definition creation.
/*	
/*	struct GRid *temp_obj	O : the object found.
/*	
/*---------------------------------------------------------------------------*/

message ACfind_exp_temp_struct(int *suc,pos;
		struct ret_struct *ptr_rst;struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* 		Given posion in expanded template give back the
/*	returned structure corresponding to the found object.
/*
/*      Argument description :
/*      --------------------
/*	
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	int pos			I : the position of the template to find.
/*				This position is the index relative to the
/*				order that was used to define templates
/*				at macro definition creation.
/*	
/*	struct ret_struct *ptr_rst 
/*				O : the structure corresponding to the
/*				found object.
/*	
/*	struct GRmd_env	*md_env	
/*				I : structure containing 
/*				the module environement
/*	
/*---------------------------------------------------------------------------*/

message ACdrop(struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* 	Drop complex characteristics.
/*	the only objects that will remain will be the basic graphic ones.
/*	The user must notice that he will not get back the associative
/*	objects corresponding to the macro definition. 
/*
/*      Argument description :
/*      --------------------
/*
/*	struct GRmd_env *md_env 	I :
/*
/*---------------------------------------------------------------------------*/

message  ACbuild_rtn_str(struct GRmd_env *md_env; int cn_type );
/*---------------------------------------------------------------------------
/* 	Virtual return structure management. This method is responsible 
/* 	for allocating the space necessary for the virtual feet
/*	( corresponding to associative objects in the  definition ).
/*	This method generate a NDcompute_node if the returned
/*	structures were not built.
/*
/*      Argument description :
/*      --------------------
/*
/*	struct GRmd_env *md_env I : structure containing 
/*				the module environement.
/*
/* 	int cn_type 		I :
/*
/*---------------------------------------------------------------------------*/

message  ACtbuild_rtn_str(int tsize;struct GRid *list );
/*---------------------------------------------------------------------------
/*     Virtual return structure management allocate space.
/*
/*      Argument description :
/*      --------------------
/*
/*	int tsize		I : template for compute node
/*
/*      struct GRid *list	I : the list of templates 
/*
/*---------------------------------------------------------------------------*/

message  ACfree_rtn_str();
/*---------------------------------------------------------------------------
/*	Free the space allocated by the previos method 
/*	This is called by :
/*		ACdrop		ACkill		NDcopy
/*		NDdelete	NDsleep 	
/*---------------------------------------------------------------------------*/

message  ACload_temp_feet(int tsize;struct GRid *list;struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/*	Load virtual feet that are in  template
/*---------------------------------------------------------------------------*/

message ACfind_temp_obj   (int *suc;char *name;    struct GRid *temp_obj);
/*---------------------------------------------------------------------------
/* 		Given name of template give object  by searching 
/*	complex template( template that might be itself a macro occurence)..
/*		This method returns the template and not the macro it can 
/*	be a foot of( if templates are mapped ).
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	char *name		I : the template to find
/*	
/*	struct GRid *temp_obj	O : the found object.
/*	
/*---------------------------------------------------------------------------*/

message ACfind_temp_struct(int *suc;char *name;struct ret_struct *ptr_rst;
			   struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/*		Given name of template give object  by searching 
/*	complex template( template that might be itself a macro occurence ).
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	char *name		I : the template to find.
/*
/*	struct ret_struct *ptr_rst 
/*				O : the returned structure corresponding 
/*				to the object found.
/*	
/*	struct GRmd_env *md_env	I ;
/*
/*---------------------------------------------------------------------------*/

message ACrebuild(int *suc; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* 		Given a macro with template the complex is initialized.
/*	the graphics objects of the definition are copied and connected
/*	to the complex.
/* 	This method needs to be overriden 
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	struct GRmd_env *md_env	I : the module env to use.
/*	
/*---------------------------------------------------------------------------*/


message ACfind_go(int bf_size,*count; struct GRid **gos_GRid);
/*---------------------------------------------------------------------------
/*
/* Find graphic objects attached to ACcomplexes
/*
/*      Argument description :
/*      --------------------
/*
/*	int bf_size		I : size of graphic object buffer
/*
/*	int count	      I/O : current position in buffer
/*
/*	struct GRid **gos_GRid   O : pointer to found object buffer
/*
/*---------------------------------------------------------------------------*/


reject ACrebuild;


end specification ACcpx;

