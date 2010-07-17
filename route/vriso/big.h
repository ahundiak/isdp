/* -------------------------------------------------------------- */
/*
/*
/*	* 31-Oct-91	1.4.3.7	
/*
/*		Bruno
/*		- Add definition of the Unix environment.
/*
 *  10/31/96  KDD	user_mail (for batch jobs).
 *			QUEUE (batch jobs). 
 *			VR_ISO_CLIENT_KSH_NAME
/*
/* -------------------------------------------------------------- */
 
#ifndef big_def
#define big_def

/* Unix environment definition */

#define VR_DEFAULT_DESIGN_NAME		"design"

#define VR_ISO_PROD_NAME		"Isogen"
#define VR_ISO_KSH_NAME			"isogen.sh"

#define VR_ROUTE_PROD_NAME              "Route"
#define VR_ISO_CLIENT_KSH_NAME		"iso/ISOclient.sh"
#define VR_ISO_SEED_NAME		"config/iso/bimpseed.dgn"
#define VR_ISO_DEF_IMP_NAME		"config/iso/imperial.dflt"
#define VR_ISO_DEF_MET_NAME		"config/iso/metric.dflt"
#define VR_ISO_DEF_MIX_NAME		"config/iso/mixed.dflt"

#define VR_TRI_KSH_NAME			"config/iso/triflex.sh"
#define VR_TRI_SEED_NAME		"config/iso/triflex.sh"
#define VR_TRI_DEFAULTS_NAME		"config/iso/triflex.dflt"


/* db_aci.I */
#define MAX_SEARCH 100
#define MAX_DASH   20
#define MAX_FIELD  60
#define PATH_MAX   60
#define MAX_CRIT    5    
/* number of row in big array */
#define ROW	  	32
#define MAX_DEF5	5
#define MAX_DEF7	7
#define MAX_DEF11	11
#define MAX_DEF14	14
#define MAX_DEF20	20

#define INCR 100    /* Increment d'allocation memoire */

/* words of big array */
#define B_NAME  	0
#define B_OCC  		2
#define B_X		4
#define B_Y		6
#define B_Z		8
#define B_NODE		10
#define B_1213		11
#define B_INFO14	13
#define B_1518		14
#define B_18		17
#define B_ORIENT	18
#define B_INFO22	21
#define B_SEG		22
#define B_CP		24
#define B_NBCP		25
#define B_OBJID		26
#define B_OSNUM		28
#define B_3032		29


/* Maximum number of cp available for a component */
#define MAX_CP 20

/* Mask used to set or get some attributs of the info of component	*/
#define IS_TYPE 	0xFF00   /* defined the type of component 	*/
#define IS_COMP 	0x0004   /* pipe or component		 	*/
#define IS_TAPNB 	0x0018   /* 0 for now			 	*/
#define IS_BIT6 	0x0020   /* 0 for now			 	*/


/* Mask used to set or get some attributs of the info2 word 	*/
#define IS_BRANCH 	0x0001   /* branch type  		*/
#define IS_ILKS 	0x0038   /* 0 for now    		*/
#define IS_END  	0x0200   /* end pt with a connected to	*/
#define IS_TAP  	0x0000   /* 0 for now 			*/
#define IS_CP1	 	0x0000   /* 0 for now			*/

#define IS_FLOT 	0x0180   /* flot information		*/
#define IS_DPMODE	0x0040	 /* display mode information	*/


/* Mask used for the word 26 */
#define IS_CP26 	0x0007
#define IS_MTO1  	0x0060
#define IS_MTO2  	0x0180
#define IS_MTO3  	0x0600
#define IS_MTO4  	0x1800

/* Structure and define used from the criteria selection */

#define LINE_ID 1
#define LINE_ATTRIBUTES 2

struct ISsel
 {
   int			 nb_ext;
   int 		 	 nb_cc;
   int		 	 size;
   short		 type; /* LINE_ID or LINE_ATTRIBUTES */
   struct GRid  	*cc;
   struct ISOcriter 	*crit;
 };

struct ISOfile
 {
   char 	seed_name[MAX_FIELD];
   char		design_name[MAX_FIELD];
   char		default_name[MAX_FIELD];
/*   int	nb_sect;  */
   
};

 struct ISOcriter
 {
   short	 other; 
   char		 fluid_text[MAX_DEF20];
   char 	 line_seq_number[MAX_DEF11];
   char 	 block_number[MAX_DEF7]; 
   char		 pds_class[MAX_DEF14];
   short 	 nb_page;
 };
 
struct ISOform
 {
  struct ISOfile	file;
  struct ISOcriter	crit[MAX_CRIT];
  int                   index_crit;
 };
 
/* comment out next 2 lines for dload testing.
*/
char	user_mail[PATH_MAX]; 
char	QUEUE[PATH_MAX]; 

#endif

