/* $Id: vdtvw.h,v 1.2 2001/10/26 20:23:55 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtvw/vdtvw.h
 *              Supports operations of "Tree Node Selection"
 *
 * Description: Definitions for basic generic item selection
 *
 * Dependencies:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/22/01  pn      Creation
 ***************************************************************************/


#ifndef vdtvw_include
#define vdtvw_include


#define EXP_EXP "+"
#define EXP_CON "-"
#define EXP_EMP " "

/* 
 * definitions for gadgets on the form 
 */
/* multicolumn */
#define VDTVW_MCOL_TREE   12

/* toggles */
#define VDTVW_TG_ITEM     31
#define VDTVW_TG_MOD      14
#define VDTVW_TG_STAGE    32
#define VDTVW_TG_NAME     33
#define VDTVW_TG_ATTR     41

/* rolling text boxes */
#define VDTVW_RT_HI       16
#define VDTVW_RT_ALL      50

/* text boxes */
#define VDTVW_T_SETS      18
#define VDTVW_T_BLN       13
#define VDTVW_T_STAGE     36
#define VDTVW_T_NAME      37
#define VDTVW_T_ANAME     20 
#define VDTVW_T_AVAL      21
#define VDTVW_T_FROM      25
#define VDTVW_T_TO        26
#define VDTVW_T_EXPR      51   

/* buttons */
#define VDTVW_B_SEL_1     19
#define VDTVW_B_SEL_2     27
#define VDTVW_B_SEL_3     38
#define VDTVW_B_CLR_1     24
#define VDTVW_B_CLR_2     28
#define VDTVW_B_CLR_3     39
#define VDTVW_B_LOAD_SS   47
#define VDTVW_B_SAVE_SS   48
#define VDTVW_B_DEl_SS    49
#define VDTVW_B_ADD_SS    52
#define VDTVW_B_CLR_SS    53
#define VDTVW_B_FROM      22
#define VDTVW_B_TO        23

/* Labels */

#define VDTVW_L_TITLE     11
#define VDTVW_L_SETS      15
#define VDTVW_L_HILITE    17
#define VDTVW_L_STAGE     34
#define VDTVW_L_NAME      35
#define VDTVW_L_ANAME     42
#define VDTVW_L_AVAL      43
#define VDTVW_L_ATTR      45
#define VDTVW_L_BLN       44    
#define VDTVW_L_ITEMS     29   

/* check gadgets */

#define VDTVW_C_SETS      54   
#define VDTVW_C_EXPR      55   

/* gadget group */

#define VDTVW_G_SS	  57

/* 
 * structure used to remember
 * form settings for return
 */
typedef struct {
  IGRint  itemTog;
  IGRint  modTog;
  IGRint  stageTog;
  IGRint  nameTog;
  IGRint  attrTog;
  IGRint  parent;
  IGRint  hilite;
  IGRchar sets[128];
  IGRchar stage[128];
  IGRchar name[128];
  IGRchar afrom[128];
  IGRchar ato[128];
  IGRchar attrName[128];
  IGRchar attrValue[128];
  IGRchar bln[128];
  TGRid   rootID;
  TGRid   fromID;
  TGRid   toID;
} VDtvwFrmSet;

 

/* 
 * prototypes 
 */

/***********************************************
 *
 * macro to bring up the form into action
 *
 ***********************************************/
extern IGRint VDtvwNotifyForm __((char   *form,
				  IGRint gadget));
#omdef vdtvw$NotifyForm(form,
			gadget)

VDtvwNotifyForm((form),
		(gadget))
#endomdef
#endif 
