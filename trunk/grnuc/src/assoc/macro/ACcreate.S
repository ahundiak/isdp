/*
/*---------------------------------------------------------------------------
/*
/*  ACcreate.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/* 		This class defines a temporary object which is used 
/*	at definition creation to collects the data.
/*
/*---------------------------------------------------------------------------*/
class specification ACcreate (0:0) of ACmacro_hdr;

#include "macro.h"


instance ACcreate 
{
};

message ACplace(int *suc,prop     ; char *macro_name;
		 int temp_num; OM_S_OBJID *temp_list;char **temp_name;
		 int feet_num; OM_S_OBJID *feet_list;char **feet_name );
message ACmplace(int *suc,prop     ; char *macro_name;
		 int temp_num; OM_S_OBJID *temp_list;char **temp_name;
		 int feet_num; OM_S_OBJID *feet_list;char **feet_name;
		 struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/*		Use to create a macro definition. This message is 
/*	used from ci. It defines the macro with defaults :
/*
/*		up prompt set to template names
/*		upscan set to "."
/*		downscan set to "."
/*
/*	This method makes a call to ACfull_place.
/*	It is not necessary to do an edit_template
/*
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	prop			I :
/*
/*	  #define ACkeep_no_real_template 1
/*	  #define AChmc_nocopy      	2 /* take the original as def graph   */
/*	  #define ACsame_feet_in_set  	4
/*	  #define ACcant_place_sym	8 /*also used if overflow in map from */
/*	  #define ACextern_no_copy	16/* copy extern of the def graph     */
/*	
/*	char *macro_name	I : the macro name
/*	
/*	int temp_num		I : the number of template
/*	
/*	OM_S_OBJID *temp_list	I : the list of template
/*	
/*	char **temp_name	I : the template names
/*				  if a template name begins with '_', for
/*				  example "_line1" the type(as defined in
/*				  parametric.h) will not be checked
/*	
/*	int feet_num		I : the number of feet
/*	
/*	OM_S_OBJID *feet_list	I : the list of feet
/*	
/*	char **feet_name	I : the feet names
/*	
/*	struct GRmd_env *md_env I :
/*
/*---------------------------------------------------------------------------*/

message ACfull_place( 	
		int *suc, prop; char *macro_name;
		int tot_up; 	struct GRid *template; 	struct sup *xdup;
                int tot_temp;	struct stemp *xdtemp; 
		int feet_num;	struct myfeet *myfeet;	struct GRid *feetlist;
				struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* 	Place used with full definition of downscans 
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	int prop		I :
/*
/*	  #define ACkeep_no_real_template 1
/*	  #define AChmc_nocopy      	2 /* take the original as def graph   */
/*	  #define ACsame_feet_in_set  	4
/*	  #define ACcant_place_sym	8 /*also used if overflow in map from */
/*	  #define ACextern_no_copy	16/* copy extern of the def graph     */
/*
/*	char *macro_name	I : the macro name
/*
/*	int tot_up		I : the number of real template
/*
/*	struct GRid *template	I : the list of template
/*
/*	struct sup *xdup	I : strusture describing upscan.
/*
/*	int tot_temp		I : the number of template definition 
/*
/*	struct stemp *xdtemp	I : strusture describing the template.
/*
/*	int feet_num		I : the number of feet
/*
/*	struct myfeet *myfeet	I : structure describing the feet
/*
/*	struct GRid *feetlist	I : the list of feet
/*	
/*	struct GRmd_env *md_env I :
/*
/*---------------------------------------------------------------------------*/

message ACedit_template(int *suc, num_up, num_down;
		char **up_prompt,**upscan,**temp_name,**dwnscan;
		int template_to_up[]);
/*---------------------------------------------------------------------------
/*		This method is used to define a mapping between the formal
/*	parents that appears in the definition and the real ones that
/*	will be given at placement of an occurence
/*		the user must be carefull not to give twice the same name to
/*	template element.
/*
/*      Argument description :
/*      --------------------
/*	
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	num_up			I : number of real parent that will be given 
/*				at placement of an occurence
/*	
/*	num_down		I : number of template edited
/*	
/*	char **up_prompt	I : prompt used at placement of an occurence 
/*				to locate the real parent
/*	
/*	**upscan		I : string used to check if the parent 
/*				is of the right type(using its macro name):
/*				it is a regular expression as used under unix
/*				
/*	
/*	**temp_name		I : the templates we are mapping
/*	
/*	**dwnscan		I : wath we are looking for in the located
/*				parent. it is a feet name in the parent 
/*				definition
/*		
/*	int template_to_up[]	I : if template_to_up[i] = j that means that
/*				the i th element as defined in the temp_name 
/*				array is mapped to the j th parent as
/*				defined in the upscan	array whith the i th
/*				dwnscan as definied in the dwnscan array.
/*	
/*---------------------------------------------------------------------------*/

end specification ACcreate;
