/*
/*---------------------------------------------------------------------------
/*  ACcpx_defn.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*	 ACcpx_defn store data structures common to all occurences of a
/*	type of complex node.
/*	 These are the name of the construction,the feet names and their
/*	position, and how to find feet in parent complex nodes that this
/*	complex node uses.
/*---------------------------------------------------------------------------*/

class specification ACcpx_defn (0:0) of Root;
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "macro.h"

instance ACcpx_defn 
{
  char macro_name[macro_MAX_CHAR];
  /*
   properties word :
     ACkeep_no_real_template
     ACsame_feet_in_set 
  */
  int prop;

  /* 
    Table mapping real template to template in father channel
    and feet names understood by that template 
  */    
  int tot_temp;
  variable struct stemp xdtemp[0];

  /* 
    Table mapping footname to position internal or template 
    know object lists 
  */  
  int feet_num;
  variable struct myfeet myfeet[0];


};

message ACgive_temp_desc(int *temp_num; struct stemp  **temp_defn );
/*---------------------------------------------------------------------------
/* 	This message returned all the information concerning template
/*	This information is in the following structure
/*
/*	struct stemp
/*	{
/*	  char down_scan[ macro_MAX_CHAR ]; /* downscan used to find the    */
/*				            /* of the macro I am mapped to  */
/*					    /* means : take the boject      */
/*	  char name[ macro_MAX_CHAR ];/* template name			    */
/*	  int  type;		      /* type as defined in parametric.h    */
/*	  int  back;		      /* the real parent number I am mapped */
/*				      /* to				    */
/*	  int  direct_index;	      /* 				    */
/*	};
/*
/*      Argument description :
/*      --------------------
/*
/*	int *temp_num		  O : number of templates returned
/*
/*	struct stemp  **temp_defn O : the array of structures
/*
/*---------------------------------------------------------------------------*/


message ACgive_feet_desc(int *feet_num; struct myfeet **myfeet) ;
/*---------------------------------------------------------------------------
/* 		This message returns a full description of my feet
/*	This information is in the following structure :
/*	
/*	struct myfeet
/*	{
/*	  char name[macro_MAX_CHAR]; /* feet name */
/*	  int  chan; /* type of the feet , in one of the following :    */
/*		     /*	#define feet_in_template 0			*/
/*		     /* #define feet_virtual     1			*/
/*		     /* #define feet_in_graphic  2			*/
/*	  int pos;   /* my index on my associated channel 		*/
/*	  int prop;  /* the type as defined in parametric.h		*/
/*	};
/*
/*      Argument description :
/*      --------------------
/*
/*	int *feet_num		O : number of feet returned
/*
/*	struct myfeet **myfeet	O : array of structure returned
/*
/*---------------------------------------------------------------------------*/


message ACintpt_foot(int *suc;char *foot_name;int *chan,*index, *type);
/*---------------------------------------------------------------------------
/* 		Given a feet name returns the type of feet and its
/*	index.
/*
/*      Argument description :
/*      ----------------------
/*	
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	char *foot_name		I : the foot name 
/*	
/*	int *chan		O : type of the feet , in one of the following :
/*				#define feet_in_template 0
/*	 			#define feet_virtual     1
/*	 			#define feet_in_graphic  2
/*	
/*	int *index		O : the index of this foot on its
/*				associated channel.
/*	
/*	int *type 		O : the type of the feet as defined 
/*				in parametric.h
/*	
/*---------------------------------------------------------------------------*/

message ACintpt_foot_dir(int *suc,*direct_index;char *foot_name;
			 int *chan,*pos, *type,*index);
/*---------------------------------------------------------------------------
/*		Given a feet name or its direct index 
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	int *direct_index	I/O : index of the feet in the array of feet
/*				the order being the one of the macro 
/*				definition creation
/*				if -1 use foot_name
/*				this direct index is set on return
/*	
/*	char *foot_name		I : the foot name
/*	
/*	int *chan		O : type of the feet , in one of the following :
/*				#define feet_in_template 0
/*	 			#define feet_virtual     1
/*	 			#define feet_in_graphic  2
/*
/*	
/*	int *pos		O : the position of this foot on its
/*				associated channel.
/*	
/*	int *type 		O : the type of the feet as defined 
/*				in parametric.h
/*	
/*---------------------------------------------------------------------------*/

message ACmax_graph_ft( int *max);
/*---------------------------------------------------------------------------
/* 		Counts graphic feet  
/*
/*      Argument description :
/*      --------------------
/*
/*		int *max	O :Max graphic feet.
/*
/*---------------------------------------------------------------------------*/

message ACgive_name(char **name);
/*---------------------------------------------------------------------------
/* 		Access to macro name 
/*
/*      Argument description :
/*      --------------------
/*
/*	char **name		O : macro name.
/*
/*---------------------------------------------------------------------------*/


message ACreturn_real_def(struct GRid *real_def;char *hcode);

/*---------------------------------------------------------------------------
/*  Returns the real Grid of the construction that I pretend to bo
/*    - my_self (implementation at this level)
/*  or
/*    - a construction in a contruction library loaded in an other OS 
/*      (override by the AStmp_defn class)
/*
/*      Argument description :
/*      --------------------
/*
/*  struct GRid *real_def	O : Grid of the real definition of
/*				    the construction  
/*  char *h_code		I : This GRid can be searched in an optional
/*				    hcode table 
/*
/*---------------------------------------------------------------------------*/



message ACreturn_symb_def(struct GRid *symb_def;
                          OMuword osnum);

/*---------------------------------------------------------------------------
/*  Returns a symbolic definition valid for myself in the oject space osnum
/*  This symbolic definition created in the class ACtmp_defn store 
/*  my name and the name of my lybrary

/*      Argument description :
/*      --------------------
/*
/*  struct GRid *real_def	O : Grid of my symbolic definition
/*  OMuword     osnum           I : Object space where this definition
/*				    has to be created
/*
/*---------------------------------------------------------------------------*/
 



end specification ACcpx_defn;
