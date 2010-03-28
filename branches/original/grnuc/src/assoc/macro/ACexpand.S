/*
/*---------------------------------------------------------------------------
/*  ACexpand.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*	This object is the header attach to the expanded occurence
/*	of a macro.
/*  NOTE 20/1/88 expanded headers are not properly supported by system
/*  	and hence are automaticly deleted by command object.
/*---------------------------------------------------------------------------*/
class specification ACexpand (0:0) of ACmacro_hdr;

#include "macro.h"

instance ACexpand 
{
};

/* public messages */


message ACplace(int *suc, prop; char *macro_name;
	 	int numb_obj;  struct GRid *uplist );
message ACmplace(int *suc, prop; char *macro_name;
	 	int numb_obj;  struct GRid *uplist;
		struct NDcp_struct *cp_info;
		struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* 		Copyies an occurence of the macro_definition into 
/*	the dgn space and place a header on the construction ( ACexpand ).
/*
/*      Argument description :
/*      --------------------
/*	
/*	suc		O : 0 FAILED 1 SUCCESS
/*	
/*	prop		I :
/*
/* 	#define AChdr_nobuild   	1  exit before rebuild  	*/
/* 	#define AChdr_nocompute 	2  exit before compute 		*/
/* 	#define AChdr_nodisplay 	4  exit before display  	*/
/* 	#define AChdr_noprotect 	8  exit before display  	*/
/* 	#define AChdr_norange        	16 exit before adding in range  */
/*	
/*	macro_name	I : the macro to place
/*	
/*	numb_obj	I : the number of real template
/*	
/*	uplist		I : the list of templates
/*
/*      cp_info         O : description of copied element.
/*			    Can be a null pointer. 
/*			    IF NOT THE CASE IT IS UP TO THE CALLER TO FREE THE
/*			    MEMORY ALLOCATED FOR cp_infolist.   
/*	
/*	struct GRmd_env *md_env I :
/*
/*---------------------------------------------------------------------------*/

message ACciplace(int *suc,prop; char *macro_name;
		 int numb_obj;  OM_S_OBJID  *uplist);
/*---------------------------------------------------------------------------
/*		Same message as above exept given with OM_S_OBJID.
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
/*	OM_S_OBJID  *uplist	I : the list of real templates
/* 
/*---------------------------------------------------------------------------*/
  
end specification ACexpand;
