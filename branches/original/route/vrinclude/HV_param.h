/*********************************************************************

Author	:	

Creation:	November 12th, 1990


		This file contains the definition of Piping parameter form
	
Change History :


	  date	|  name	|	modification's description
	  --------+-------+-----------------------------------
	10/24/94| Lori  | CR#179422038 Add HVAC material class (spec)
        02/27/98| law   | TR179800553 Add HVUSER_ATTR_BUTTON
        06/24/98| law   | TR179801141 Add vendor to rway params form
*********************************************************************/

#ifndef	vr_HV_param_include

#define vr_HV_param_include

#define		MESSAGE			10
#define		USER_ATTR_FLD		12
#define		GAP			13
#define 	USER_ATTR_BUTTON    	15
#define 	HVUSER_ATTR_BUTTON    	136
#define		CIRCULAR_SHAPE		17
#define		RECTANGULAR_SHAPE	18
#define		OVAL_SHAPE		19
#define		LOAD_BUTTON		20
#define		W_SIZE			22
#define		D_SIZE			23
#define         RW_D_SIZE_TEXT          91
#define         RW_D_SIZE_TX_IN         35
#define         RW_D_SIZE_TX_MM         27
#define		MAX_FIELD		25
#define		LINE_NUMBER		41
#define		HVAC_MAT_CLASS	       122
#define		RWAY_VNDR_CODE	       122 /* TR179801141-added to rway form */
#define		PRESS_CLASS		42
#define		SERVICE			43
#define		SIZE_METHOD		44
#define		AIR_FLOW    		45
#define		MAX_VELOCITY		46
#define		EQUIV_DIAM  		47
#define		MAX_WIDTH		48
#define		DUCT_MATER		49
#define		DUCT_THICK		50
#define		INSULA_MATER		51
#define		INSULA_THICK		36
#define		THROAT_RADIUS		39
#define		TRANS_LENGTH		40
#define		SYSTEM			56
#define		ZONE			57
#define		CONST_STATUS		58
#define		APPROVAL_STAT		59
#define		MOD_LOAD_BUTTON		67
#define 	MOD_USER_ATTR_BUTTON    83


#define SYMB_SHAPE			12
#define SYMB_LINE_NUMBER		16
#define SYMB_PRESS_CLASS		62
#define SYMB_SERVICE			63
#define SYMB_SIZE_METHOD		64
#define SYMB_AIR_FLOW			65
#define SYMB_MAX_VELOCITY		66
#define SYMB_MAX_WIDTH			68
#define SYMB_DUCT_MATER			69
#define SYMB_DUCT_THICK			70
#define SYMB_INSULA_MATER		71
#define SYMB_INSULA_THICK		72
#define SYMB_CONST_STATUS		73
#define SYMB_APPROVAL_STAT		74
#define SYMB_W_SIZE			75
#define SYMB_D_SIZE			76
#define SYMB_THROAT_RADIUS		77
#define SYMB_TRANS_LENGTH		78
#define SYMB_GAP			79
#define SYMB_SYSTEM			80
#define SYMB_ZONE			81
#define SYMB_RWAY_VNDR_CODE		129 /* TR179801141-added to rway form*/


#endif
