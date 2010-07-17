/* $Id $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsedge/VSbmodBvlAttr.I
 *
 * Description: Modify Bevel Attributes
 *	
 * Dependencies: form,       VSmodBvlAttr.frm
 *		 driver,     pplcmd/COmodBvlAttr.u
 *
 * Revision History:
 *	$Log: VSmodBvlAttr.I,v $
 *	Revision 1.1  2001/01/17 00:07:30  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/04/28  14:14:26  pinnacle
# Replaced: struct/vsedge/VSmodBvlAttr.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/24  21:53:44  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY	AUTHOR	DESCRIPTION
 * 04/17/00	ylong	CR179901351
 ***************************************************************************/

class implementation Root;


// #define  vsDEBUG 1

#include "VDmaster.h"
#include "VDatClass.h"		// VDAT_CHN_TO_CHILDREN
#include "VDahFrm.h"		// Wrappers for FI calls
#include "VSbevel.h"		// Function prototypes and constants
#include "vsAPImacros.h"	// vs$get_plate_attributes
#include "vsmiscmacros.h"       // vs$is_ancestry_valid
#include "VDobj.h"		// vdobj$GetParent
#include "VDfrm.h"
#include "vsdbgmacros.h"

extern	GRclassid	OPP_ACrg_collect_class_id;
extern	IGRlong		VSbev_ReadSetupProcessSpec();
extern	IGRboolean	GetMacroName() ;
extern	FILE*		VSbev_OpenBevelSetupFile() ;

from	NDnode		import	NDget_objects,
				NDchange_connect;
from	ACrg_collect	import	ACmod_list_attribute, 
				ACadd_list_attribute,
				AClist_attribute;

/*  bevelNo:	set in VSbvlMacCMD_ModInit, reset when form is exited;	*/
/*		prefixed to plate name on form only			*/
%safe
static IGRint bevelNo;
%endsafe



/* ----------------------------------------------------------------
 * Routine to fill columns in multi-column field
 * objName returned as 100 chars from VSgetName which removes path,
 *    [DI_PATH_MAX = 1023]
 */
IGRlong VSbvlMac_FillMCF( TVSbevelInfo *info )
{
  IGRlong	retFlag = 0, 
		msg, sts;
  IGRchar	value[MAX_FLD_LEN],   // value written to multi-column field
				      // also used as text buffer
		objName[MAX_FLD_LEN], // name of plate bevel attr obj belongs to
		macName[MAX_FLD_LEN], // macro name
		msgStr[MAX_FLD_LEN] ; // 
  IGRint	i, count,
		rows, num;
  IGRint	nrows, sel, pos;
  IGRdouble	objid;		      // bevel obj id from hidden column
  IGRuint	chdCnt;               // count of a collector's children
  TACrg_coll	*attList=NULL;	      // attributes from collector
  TGRid		*parent_list=NULL,    // parents of bevel object
		collID;
  TGRobj_env	tempOE, parentOE;

  SetProc( VSbvlMac_FillMCF ); Begin

  __DBGpr_obj("Located object", info->bevelOE.obj_id);

  // Initialize status bars
  VIg_set_text( info->form, FI_PROMPT_FIELD, ""); 
  VIg_set_text( info->form, FI_MSG_FIELD, "" ); 

  // Check if macro is a bevel macro
  if( !GetMacroName( info->bevelOE.obj_id, macName, msgStr) ) {
    UI_status(macName);
    VIg_set_text( info->form, FI_MSG_FIELD, msgStr ) ;
    __DBGpr_com("locate failed or wrong name of macro");
    goto wrapup ;
  }

  __DBGpr_str( "Macro Name ", macName );

  if( !strcmp( macName, "neat_plate" ) )
  {
      IGRint		bvl_count=0;
      struct GRid	*bvl_list = NULL;
      TVSbevelInfo 	bvlInfo ;

      bvlInfo = *info;

      sts = VSgetChildrenGoThruPretends( &msg, &info->bevelOE.obj_id,
					 &bvl_count, &bvl_list );

      __DBGpr_int( "Number Of Bevels on the Neat Plate ", bvl_count );
      __DBGpr_objlist("Bevel List ", bvl_count, bvl_list );
      for( i=0; i<bvl_count; ++i )
      {
	  bvlInfo.bevelOE.obj_id = bvl_list[i] ;
          VSbvlMac_FillMCF( &bvlInfo );
      }
      _FREE( bvl_list );
      retFlag = 1;
      __DBGpr_com("VSbvlMac_FillMCF done");
      goto wrapup;
  }

  if( strcmp( macName, "Bevel") && strcmp( macName, "EJ_Bevel") &&
      strcmp( macName, "VA_Bevel") && strcmp( macName, "Fab_Stock") ) {
    sprintf( msgStr, "%s is not a bevel macro", macName ) ;
    UI_status(msgStr);
    VIg_set_text( info->form, FI_MSG_FIELD, msgStr ); 
    goto wrapup ;
  }

  // Check if located object already listed on form
  VIfld_get_num_rows( info->form, VSMOD_BVL_MCF, &nrows );

  for( i=0; i<nrows; i++ )
  {
    sts=FIfld_get_value(info->form, VSMOD_BVL_MCF, i, 7, &objid, &sel, &pos);
    if( info->bevelOE.obj_id.objid == (int)objid ){
      VIfld_get_text(info->form,VSMOD_BVL_MCF,i,0,MAX_FLD_LEN,objName,&sel,&pos);
      sprintf(value,"%s%s%s %d %s", "Bevel, \"", objName, "\",  id",
		info->bevelOE.obj_id.objid, ", already listed");
      UI_status( value ); 
      goto wrapup;
    }
  }

  // Get parents of bevel attribute object;
  //   To get current collector
  sts = om$send ( msg =  message NDnode.NDget_objects(
                                 ND_IN_BUF | ND_ROOT,
                                 (struct GRid *)NULL,
                                 0,
                                 &parent_list,
                                 0,
                                 OM_K_MAXINT,
                                 &num ),
	    senderid  = NULL_OBJID,
            targetid  = info->bevelOE.obj_id.objid,
            targetos  = info->bevelOE.obj_id.osnum);
  __CheckRC(sts,1,"NDnode.NDget_objects",wrapup);

  __DBGpr_int("num parents", num);
#ifdef vsDEBUG
  for( i=0; i<num; i++ )
    printf("\t  os:%d  id:%d\n", parent_list[i].osnum, parent_list[i].objid);
#endif

  for( i=0; i<num; i++ )
  {
    if( vs$is_ancestry_valid( object = &parent_list[i],
                              classid= OPP_ACrg_collect_class_id ) )
      {
	// Get current collector attributes
	sts = VSbvlMac_GetAttrs( parent_list[i], &count, &attList );
	__CheckRC(sts,1,"VSbvlMac_GetAttrs",wrapup);
	__DBGpr_int("Attribute count", count);

	// If current collector has only one child (one VSedge3Datt
	//   object), keep, otherwise, create a new collector,
	//   unique to current edge (VDAT parent is really child)
	sts = VDahGetChnCount(&parent_list[i], VDAT_CHN_TO_PARENT, &chdCnt); 
	__DBGpr_int("num collector children", chdCnt);

	if( chdCnt > 1 )
	{
	  // Create new bevel collector, replacing original collector
	  sts = VSbvlMac_CreateColl( info, &parent_list[i], &collID ); 
	  __CheckRC(sts,1,"VSbvlMac_CreateColl",wrapup);

	  // Put original collector attributes into new bevel collector
	  sts = VSbvlMac_PutAttrs( &collID, count, attList );
	  __CheckRC(sts,1,"VSbvlMac_PutAttrs",wrapup);
	}
      }
  }

#ifdef vsDEBUG
  __DBGpr_com("attr names");
  for( i=0; i<count; i++ )
  {
    __DBGpr_str("  ", attList[i].name);
  }
#endif

  VIfld_get_num_rows( info->form, info->gadget, &rows );

  // Get wanted attributes
  for( i=0; i<count; i++ )
  {
    if( strcmp( attList[i].name, "macro_type" ) == 0 )
    {
      VDahFrmSetTextRC( info->form, info->gadget,
			rows, 1, attList[i].desc.value.att_txt);
      info->attr[macro_type].desc.type = 1 ;
      strcpy(info->attr[macro_type].name, "macro_type" );
      strcpy(info->attr[macro_type].desc.value.att_txt, 
		attList[i].desc.value.att_txt);
    }
    else if( strcmp( attList[i].name, "bevel_type" ) == 0 )
    {
      VDahFrmSetTextRC( info->form, info->gadget,
			rows, 2, attList[i].desc.value.att_txt);
      info->attr[bevel_type].desc.type = 1 ;
      strcpy(info->attr[bevel_type].name, "bevel_type" );
      strcpy(info->attr[bevel_type].desc.value.att_txt, 
		attList[i].desc.value.att_txt);
    }
    else if( strcmp( attList[i].name, "process_type" ) == 0 )
    {
      VDahFrmSetTextRC( info->form, info->gadget,
			rows, 3, attList[i].desc.value.att_txt);
      info->attr[process_type].desc.type = 1 ;
      strcpy(info->attr[process_type].name, "process_type" );
      strcpy(info->attr[process_type].desc.value.att_txt, 
		attList[i].desc.value.att_txt);
    }
    else if( strcmp( attList[i].name, "stock_value" ) == 0 )
    {
      __DBGpr_dbl("Stock Value", attList[i].desc.value.att_exp);
      sprintf(value,"%.1f",attList[i].desc.value.att_exp);
      VDahFrmSetTextRC( info->form, info->gadget,
			rows, 4, value);
      info->attr[stock_value].desc.type = 2 ;
      strcpy(info->attr[stock_value].name, "stock_value" );
      info->attr[stock_value].desc.value.att_exp=attList[i].desc.value.att_exp;
    }
    else if( strcmp( attList[i].name, "offset_value" ) == 0 )
    {
      sprintf(value,"%.1f",attList[i].desc.value.att_exp);
      VDahFrmSetTextRC( info->form, info->gadget,
			rows, 5, value);
      info->attr[offset_value].desc.type = 2 ;
      strcpy(info->attr[offset_value].name, "offset_value" );
      info->attr[offset_value].desc.value.att_exp=attList[i].desc.value.att_exp;
    }
    else if( strcmp( attList[i].name, "adjacent_plate_thickness" ) == 0 )
    {
      sprintf(value,"%.1f",attList[i].desc.value.att_exp);
      VDahFrmSetTextRC( info->form, info->gadget,
			rows, 6, value);
      info->attr[E_adjacent_plate].desc.type = 2 ;
      strcpy(info->attr[E_adjacent_plate].name, "adjacent_plate_thickness" );
      info->attr[E_adjacent_plate].desc.value.att_exp = 
				attList[i].desc.value.att_exp;
    }
  } // for

  // Get plate parent
  tempOE.obj_id.objid = NULL_OBJID ;
  parentOE.obj_id.objid = NULL_OBJID ;
  sts =vdobj$GetTemplate (	objOE = &info->bevelOE,
				nth   = 1,
				templateOE  = &tempOE, );
  if (!(sts & 1)) {
    printf("Failed to Get Parent\n");
    goto wrapup;
  }

  sts = vdobj$GetFoot(	objOE = &tempOE,
			footOE = &parentOE );
  if (!(sts & 1)) {
    printf("Failed to Get Parent\n");
    goto wrapup;
  }

  info->plateID = parentOE.obj_id;

  __DBGpr_obj("plate obj_id", info->plateID);

  // Now get plate name
  *objName = 0;
  VSgetName( &info->plateID, objName);
  if (*objName == 0) {
    strcpy(objName,"Defined");
  }
  __DBGpr_str("plate name", objName);

  sprintf(value,"%d %s", bevelNo, objName);
  
  // Get plate parent
  if( info->attr[macro_type].desc.value.att_txt[0] == '2' ) {
    tempOE.obj_id.objid = NULL_OBJID ;
    parentOE.obj_id.objid = NULL_OBJID ;
    sts =vdobj$GetTemplate (	objOE = &info->bevelOE,
  				nth   = 2,
				templateOE  = &tempOE, );
    if (!(sts & 1)) {
      printf("Failed to Get Parent\n");
      goto wrapup;
    }

    sts = vdobj$GetFoot(	objOE = &tempOE,
			footOE = &parentOE );
    if (!(sts & 1)) {
      printf("Failed to Get Parent\n");
      goto wrapup;
    }

    info->adjPlateID = parentOE.obj_id;

    __DBGpr_obj("plate 2 id", info->adjPlateID);

    // Now get plate name
    *objName = 0;
    VSgetName( &info->adjPlateID, objName);
    if (*objName == 0) {
      strcpy(objName,"Defined");
    }
    __DBGpr_str("plate name", objName);
    strcat(value, "/");
    strcat(value, objName);
  }

  VDahFrmSetTextRC(info->form, info->gadget, rows, 0, value);

  // Relate object to it's attributes - put objid in hidden column
  FIfld_set_value (	info->form, info->gadget,
			rows, 7, (double)info->bevelOE.obj_id.objid, 0);


  bevelNo = bevelNo + 1;

  retFlag = 1;
  __DBGpr_com("VSbvlMac_FillMCF done");

wrapup:
  _FREE( attList );
  End
  return retFlag;

} // VSbev_FillMCF

/* -----------------------------------------
 * Sort bevel attribute objects within fence,
 * Call VSbvlMac_FillMCF to fill form   
 */
IGRlong VSbvlMac_Fence_FillMCF( TVSbevelInfo *info )
{
  IGRlong	retFlag = 0;
  IGRint	i;
  IGRchar	text[MAX_FLD_LEN];

  IGRint      bevelCNT = 0;
  TGRobj_env *bevelOEs = NULL;

  // Don't do one without the other
  IGRint  response;
  IGRchar response_data[1024];

  SetProc( VSbvlMac_Fence_FillMCF ); Begin
 
  *response_data = 0;
   response = 0;
 
  as$start_fence(set       = &info->bevelOE.obj_id,
                 set_env   = &info->bevelOE.mod_env,
                 nb_obj    = &bevelCNT,
                 response  = &response,
                 response_data = response_data,
                 p_obj_env = &bevelOEs);

  if (response != EX_DATA) goto wrapup;

  *text=0;
  sprintf(text, "%s%d", "Bevels in fence: ", bevelCNT);
  UI_status(text);

  for( i=0; i<bevelCNT; i++ )
  {
    info->bevelOE = bevelOEs[i];
    VSbvlMac_FillMCF( info );
  }


  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbev_Fence_FillMCF

/* -----------------------------------------------------------------------
 * Read setup file for stocks and thicknesses
 */
IGRlong VSbev_ReadSetupStockThk(
		Form	form, 
		IGRint	gadStock,
		IGRint	gadThk )
{
  IGRlong	retFlag = 0;
  FILE		*fileptr;
  IGRint	col, rowStock, rowThk, pos, i, sts, nrows;
  IGRchar	buf[256], *p, text[MAX_FLD_LEN];
  
  SetProc(VSbev_ReadSetupStockThk); Begin

  p		= NULL ;
  fileptr	= NULL ;
  rowStock	= 0;
  rowThk	= 0;

  FIfld_set_list_num_rows( form, gadStock, 0, rowStock );
  FIfld_set_list_num_rows( form, gadThk,   0, rowThk );
 
  fileptr = VSbev_OpenBevelSetupFile();
  if(fileptr == NULL) goto wrapup;

  // Cycle through
  while(fgets(buf,sizeof(buf),fileptr)) {
      if(!strncmp(buf,"@STOCK", 6)){

        buf[strlen(buf)-1] = '\0';
        strcpy(buf,buf+1);
        for(i=0;buf[i]!=' ' && i<250 ;i++);
        p = &buf[i+1];

        vdfrm$SetListText(form   = form,
                          gadget = gadStock,
                          row    = rowStock,
                          txt    = p);
        rowStock++;
        continue ;
      }
      if(!strncmp(buf,"@THK", 4)){

        buf[strlen(buf)-1] = '\0';
        strcpy(buf,buf+1);
        for(i=0;buf[i]!=' ' && i<250 ;i++);
        p = &buf[i+1];

        vdfrm$SetListText(form   = form,
                          gadget = gadThk,
                          row    = rowThk,
                          txt    = p);
        rowThk++;
        continue ;
      }
  }

  FIfld_set_list_num_rows( form, gadStock, 0, rowStock );
  FIfld_set_list_num_rows( form, gadThk,   0, rowThk );
 
  fclose(fileptr);
  retFlag = 1;

wrapup:

  if(retFlag == 0) printf("Reading setup file failed\n");
  End
  return retFlag;
} // VSbev_ReadSetupStockThk


/* -----------------------------------------------------------------------
 * Read setup file, fill values for field list
 */
IGRlong VSbvlMac_ReadSetupFile( 
  Form form, IGRint gadget)
{
  IGRlong	retFlag = 0;
  IGRint	col,row, pos,
                sts,nrows,i;
  IGRchar	text[MAX_FLD_LEN];	// line read from ascii file
  
  row = 0;
  
  // Get the active column
  
  FImcf_get_active_col(form, VSMOD_BVL_MCF, &col, &pos);
  
  // Erase existing pick list
  FIfld_get_list_num_rows(form,gadget,0, &nrows );
  text[0]='\0';
  for( i=0; i<nrows; i++)
    vdfrm$SetListText(form   = form, 
		      gadget = gadget, 
		      row    = i, 
		      txt    = text);
  switch( col ) {
    case 2:
    VSbev_ReadSetupProcessSpec( form,VSMOD_BVL_FLD_LIST, VSMOD_BVL_FLD_LIST1);
    break ;

    case 3: 
    VSbev_ReadSetupProcessSpec( form,VSMOD_BVL_FLD_LIST1, VSMOD_BVL_FLD_LIST);
    break ;

    case 4:
    VSbev_ReadSetupStockThk( form, VSMOD_BVL_FLD_LIST, VSMOD_BVL_FLD_LIST1);
    break ;

    case 6:
    VSbev_ReadSetupStockThk( form, VSMOD_BVL_FLD_LIST1, VSMOD_BVL_FLD_LIST);
    break ;

  }

  retFlag = 1;
 wrapup:
  if(retFlag == 0)
    printf("Reading setup file failed\n");
  return retFlag;
} // VSbvlMac_ReadSetupFile


/* --------------------------------------------
 * Row, column was picked, fill associated list
 */
IGRlong VSbvlMac_PickedMCF(TVSbevelInfo *info)
{
  IGRlong	retFlag = 0;
  IGRint	row, col, pos, sel,	// Row, column selected
		nchar, nrows, cnt, 
		sts, i, length; 
  IGRchar	text[MAX_FLD_LEN];	// Text from field
  IGRchar	bvlType[MAX_FLD_LEN];	// bevel type
  IGRchar	msgStr[MAX_FLD_LEN];	// message


  SetProc( VSbvlMac_PickedMCF ); Begin

  // Indicate column selected on field button
  VIfld_get_active_row(info->form, info->gadget, &info->row, &pos);
  FImcf_get_active_col(info->form, info->gadget, &info->col, &pos);

  // Clear any leftover status
  VIg_set_text( info->form, FI_PROMPT_FIELD, " ");
  VIg_set_text( info->form, FI_MSG_FIELD, " ");
  
  // Get bevel type from form
  VIfld_get_text(info->form,VSMOD_BVL_MCF,info->row,1,MAX_FLD_LEN,
		text, &sel, &pos);
  __DBGpr_int("info->col", info->col);
  __DBGpr_str("bevel type", text);

  // If not applicable, return
  if( info->col == 0 || info->col == 1   || 
      (info->col == 2 && text[0] == 'F') ||
      (info->col == 6 && text[0] != '1') )
  {
    switch(info->col) {
    case 0:
    case 1:
      VIg_set_text(info->form, FI_MSG_FIELD,
			"1st and 2nd columns not Editable");
      break ;
    case 2:
      VIg_set_text(info->form, FI_MSG_FIELD, 
			"Bevel Type not applicable to Fabrication Stock");
      break ;
    case 6:
      sprintf(msgStr, "Adj Plate Thickness not applicable to \"%s\"", text) ;
      VIg_set_text(info->form, FI_MSG_FIELD, msgStr);
      break ;
    }
    
    FIg_set_text(info->form, VSMOD_BVL_FLD_BTN, "Update Button");
    // Update text on button
    FIg_disable(info->form, VSMOD_BVL_FLD_BTN);
    FIg_enable(info->form, VSMOD_BVL_FLD_BTN);
    
    // Erase existing pick list
    FIfld_get_list_num_rows(info->form,VSMOD_BVL_FLD_LIST,0, &nrows );
    text[0]='\0';
    for( i=0; i<nrows; i++)
    {
      vdfrm$SetListText(form   = info->form, 
			gadget = VSMOD_BVL_FLD_LIST, 
			row    = i, 
			txt    = text);
    }
    FIg_set_text(info->form,VSMOD_BVL_FLD_LIST,text);
    goto wrapup;
  }
  
  
  switch(info->col)
  {
    case 2:{
      FIg_set_text(info->form, VSMOD_BVL_FLD_BTN, "Update All Bevel Types");
      break;
    }
    case 3:{
      FIg_set_text(info->form, VSMOD_BVL_FLD_BTN, "Update All Process Types");
      break;
    }
    case 4:{
      FIg_set_text(info->form, VSMOD_BVL_FLD_BTN, "Update All Stock Values");
      break;
    }
    case 5:{
      FIg_set_text(info->form, VSMOD_BVL_FLD_BTN, "Update All Offset Values");
      break;
    }
    case 6:{
      FIg_set_text(info->form, VSMOD_BVL_FLD_BTN, "Update All Adj Plate Thicknesses");
      break;
    }


    default:
      break;
  }
  // Update text on button
  FIg_disable(info->form, VSMOD_BVL_FLD_BTN);
  FIg_enable(info->form, VSMOD_BVL_FLD_BTN);
  
  // Fill in input field list
  sts = VSbvlMac_ReadSetupFile(info->form,VSMOD_BVL_FLD_LIST);
  __CheckRC(sts,1,"VSbvlMac_ReadSetupFile",wrapup);
  
  // Fill in input field with selected value
  VIfld_get_text(info->form,VSMOD_BVL_MCF,info->row,info->col,MAX_FLD_LEN,text
  ,&sel,&pos);
  FIg_set_text(info->form,VSMOD_BVL_FLD_LIST,text);

  // Position cursor at end of input field
  if( info->col > 1 && info->col < 7 ) {
    pos = strlen(text);
    FIfld_pos_cursor( info->form, VSMOD_BVL_FLD_LIST, 0, 0, 0, 0, pos, pos);
  }

  // Disable, enable field gadget to make text appear NOW!
  FIg_disable(info->form, VSMOD_BVL_FLD_LIST);
  FIg_enable(info->form, VSMOD_BVL_FLD_LIST);
  
  // Update process type based on bevel type
  if( info->col == 2 ) {
    for( nchar = 0; nchar < strlen(text) && isdigit(text[nchar]) ; nchar++ ) ;
    strncpy( bvlType, text, nchar ) ;
    bvlType[nchar] = '\0' ;
    __DBGpr_str("bvlType, digit part",bvlType);

    nrows = 0 ;
    FIfld_get_list_num_rows(info->form,VSMOD_BVL_FLD_LIST1,0, &nrows );
    __DBGpr_int("nrows for process list", nrows);
    for( i=0; i<nrows; i++)
    {
      text[0] = '\0' ;
      FIfld_get_list_text(info->form,VSMOD_BVL_FLD_LIST1,i,0,MAX_FLD_LEN,
			(IGRuchar*)text, &sel);
      if( !strncmp( text, bvlType, nchar ) ) {
        VIfld_set_text(info->form,VSMOD_BVL_MCF,info->row,3,text,0);
        strcpy(info->attr[process_type].desc.value.att_txt, text );
        break ;
      }
    }

  }
  
  
  retFlag = 1;
  
  
 wrapup:
  End
    return retFlag;
  
} // VSbev_PickedMCF

/* ---------------------------------------------------------------------
 * List gadget was picked, insert it's text into intended row and column
 */
IGRlong VSbvlMac_PickedList(TVSbevelInfo *info)
{
  IGRlong	retFlag;
  IGRchar	text[MAX_FLD_LEN];
  
  
  SetProc( VSbvlMac_PickedList ); Begin
  retFlag = 0;
  
  // Do not update the first and second columns
  if(info->col == 0 || info->col == 1 ) {
    return retFlag;
  }
  
  text[0] = '\0';
  
  // Get text chosen from associated list or typed in,
  //   requires "Notify By Line" as editing option in Form Builder.
  //   FIfld_get_list_text gets text from list, not field gadget.
  
  FIg_get_text(info->form,VSMOD_BVL_FLD_LIST,text);
  
  VIfld_set_text(info->form, VSMOD_BVL_MCF, info->row, info->col, text, 0);
  
  retFlag = 1;
  
  End
  return retFlag;
  
} // VSbev_PickedList

/* ---------------------------------------------------
 * Update button gadget was picked, take list text and
 *   write it to all rows in appropriate column
 */
IGRlong VSbvlMac_PickedUpdButton(TVSbevelInfo *info)
{
  IGRlong	retFlag;
  IGRint	nrows, i, sel, pos;
  IGRchar	text[MAX_FLD_LEN], bvlType[MAX_FLD_LEN];


  SetProc( VSbvlMac_PickedUpdButton ); Begin

  nrows   = 0;
  text[0] = '\0';

  // Get bevel type
  VIfld_get_text(info->form,VSMOD_BVL_MCF,info->row,1,MAX_FLD_LEN,
			text,&sel,&pos);
  __DBGpr_str("text", text);

  if( info->col == 0 || info->col == 1 || 
     (info->col == 2 && text[0] == 'F')||
     (info->col == 6 && text[0] != '1') ) 
  {
     __DBGpr_com("Not applicable, goto wrapup");
     retFlag = 1;
     return retFlag;
  }
  // Get text chosen from associated list or typed in,
  //   requires "Notify at End" as editing option in Form Builder.
  //   FIfld_get_list_text gets text from list, not field gadget.

  FIg_get_text(info->form,VSMOD_BVL_FLD_LIST,text);

  VIfld_get_num_rows( info->form, VSMOD_BVL_MCF, &nrows );
  __DBGpr_int("num rows to update", nrows);
  __DBGpr_int("column   to update", info->col);

  for( i=0; i<nrows; i++ ) {
    VIfld_get_text(info->form,VSMOD_BVL_MCF,i,1,MAX_FLD_LEN,bvlType,&sel,&pos);
    if( info->col == 2 ) {
      if( bvlType[0] == 'F' ) continue ;
    }
    if( info->col == 6 ) {
      if( bvlType[0] != '1' ) continue ;
    }
    VIfld_set_text(info->form,VSMOD_BVL_MCF,i,info->col, text, 0);
  }

  retFlag = 1;

  End
  return retFlag;

} // VSbvlMac_PickedList

/* -----------------------------------------------------
 * Transfer single attribute value to object's collector
 * Puts value into ACrg_coll structure
 * "objId" is from the form
 * All arguments are inputs
 */
IGRlong VSbvlMac_Attrs( IGRint objId,    IGRchar *name,      IGRint type, 
		     IGRchar *value , TVSbevelInfo *info)
{
  IGRlong     retFlag;
  IGRlong     sts,msg;
  TACrg_coll  attrs;
  IGRint      cnt;
  IGRdouble   valueDbl;
  TGRid       bevelId, 	// bevel attribute object
	      collId;	// collector object of bevel attribute object

  SetProc( VSbvlMac_Attrs ); Begin

  retFlag = 0;

  __DBGpr_com("Inputs");
  __DBGpr_int("  objId", objId);
  __DBGpr_str("  name ", name);
  __DBGpr_str("  value", value);
  __DBGpr_int("  type ", type);

  // Move attribute information into collector structure.
  memset(&attrs,0,sizeof(TACrg_coll));

  strcpy ( attrs.name, name );
  attrs.desc.type = type;
  if ( attrs.desc.type == AC_ATTRIB_TEXT ) {
    strcpy ( attrs.desc.value.att_txt, value );
  }
  else {
    valueDbl = atof(value);
    attrs.desc.value.att_exp = valueDbl;
  }
 
  // Get ACrg collector of VSedge3Datt object (index=2)
  //   All bevels expected to be in same object space
  bevelId.objid = objId;
  bevelId.osnum = info->bevelOE.obj_id.osnum;

  // Get collector (3rd object, 2nd index) on NDfather channel
  sts = VDahGetChnObject(&bevelId,VDAT_CHN_TO_CHILDREN,0,&collId);
  __CheckRC(sts,1,"VDahGetChnObject",wrapup);
  __DBGpr_obj("collId", collId);

  cnt = 1;

  // Modify attribute, if changed
  sts = om$send(
    msg = message ACrg_collect.ACmod_list_attribute(&msg,cnt,&attrs),
    senderid = NULL_OBJID,
    targetid = collId.objid,
    targetos = collId.osnum
  );
  // msg = MSFAIL if attribute doesn't exist, so set second RC arg to 1 
  __CheckRC(sts,1,"ACmod_list_attribute",wrapup);

/*
  // Add any new ones
    sts = om$send(
      msg = message ACrg_collect.ACadd_list_attribute(&msg,cnt,&attrs),
      senderid = NULL_OBJID,
      targetid = collId.objid,
      targetos = collId.osnum
    );
    // msg = MSFAIL if attribute already exists, so set second RC arg to 1
    __CheckRC(sts,1,"ACadd_list_attribute",wrapup);
*/


  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbvlMac_Attrs

/* --------------------------------------------
 * Run form (FI_ACCEPT or FI_EXECUTE), 
 *    update edge attribute object's attributes
 * Object id retrieved from hidden column
 */
IGRlong VSbvlMac_ModAttrs(TVSbevelInfo *info)
{
  IGRint	nchars, nrows, i, sel, pos;
  IGRlong	sts, msg;
  IGRdouble	objid, curThk, adjThk, delThk;
  IGRchar	text[MAX_FLD_LEN], macType[MAX_FLD_LEN];
  IGRlong	retFlag;


  SetProc( VSbvlMac_ModAttrs ); Begin


  retFlag=0;
  nchars=MAX_FLD_LEN;

  // Get number of rows (= number of bevel attributes picked)
  VIfld_get_num_rows( info->form, VSMOD_BVL_MCF, &nrows );
  __DBGpr_int("nrows, number of bevel attribute objects selected", nrows);

  // Write values to object's collector
  for( i=0; i<nrows; i++ )
  {
    objid = NULL_OBJID ;
    sts=FIfld_get_value(info->form, VSMOD_BVL_MCF, i, 7, &objid, &sel, &pos);
    __DBGpr_int("object id", objid);

    // Macro type
    macType[0] = '\0' ;
    VIfld_get_text( info->form,VSMOD_BVL_MCF,i,1,nchars,macType,&sel,&pos); 
    sts = VSbvlMac_Attrs(objid, "macro_type", AC_ATTRIB_TEXT, macType, info);
    __CheckRC(sts,1,"VSbvlMac_Attrs for macro type",wrapup);


    // Bevel type for non-Fab_Stock
    if( macType[0] != 'F' ) {
      text[0] = '\0' ;
      VIfld_get_text( info->form,VSMOD_BVL_MCF,i,2,nchars,text,&sel,&pos); 
      sts = VSbvlMac_Attrs(objid, "bevel_type", AC_ATTRIB_TEXT, text, info);
      __CheckRC(sts,1,"VSbvlMac_Attrs for bevel type",wrapup);
    }

    // Process type
    text[0] = '\0' ;
    VIfld_get_text( info->form,VSMOD_BVL_MCF,i,3,nchars,text,&sel,&pos); 
    sts = VSbvlMac_Attrs(objid, "process_type", AC_ATTRIB_TEXT, text, info);
    __CheckRC(sts,1,"VSbvlMac_Attrs for process type",wrapup);

    // Stock value
    text[0] = '\0' ;
    VIfld_get_text( info->form,VSMOD_BVL_MCF,i,4,nchars,text,&sel,&pos); 
    sts = VSbvlMac_Attrs(objid, "stock_value", AC_ATTRIB_DOUBLE, text, info);
    __CheckRC(sts,1,"VSbvlMac_Attrs for stock value",wrapup);

    // Offset value
    text[0] = '\0' ;
    VIfld_get_text( info->form,VSMOD_BVL_MCF,i,5,nchars,text,&sel,&pos); 
    sts = VSbvlMac_Attrs(objid, "offset_value", AC_ATTRIB_DOUBLE, text, info);
    __CheckRC(sts,1,"VSbvlMac_Attrs for offset value",wrapup);

    // adjacent plate thickness for "1 Plate" bevel
    if( macType[0] == '1' ) {
      text[0] = '\0' ;
      VIfld_get_text( info->form,VSMOD_BVL_MCF,i,6,nchars,text,&sel,&pos); 
      __DBGpr_str("Update obj with new adjacent plate thickness",text);
      sts = VSbvlMac_Attrs(objid, "adjacent_plate_thickness",AC_ATTRIB_DOUBLE,text,info);
      __CheckRC(sts,1,"VSbvlMac_Attrs for offset value",wrapup);
    }

  } // for

  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbev_ModAttrs


/* --------------------------------------
 * FI_ACCEPT selected, clear form of data
 */
IGRlong VSbvlMac_ResetForm(TVSbevelInfo *info)
{
  IGRlong	retFlag;
  IGRchar	text[MAX_FLD_LEN];
  IGRint	nrows, i;


  SetProc( VSbev_ResetForm ); Begin

  bevelNo = 1;

  FIfld_set_num_rows(info->form, VSMOD_BVL_MCF, 0);
  memset(&text[0],0,sizeof(text));
  FIg_set_text(info->form,VSMOD_BVL_FLD_LIST,text);
  FIfld_get_list_num_rows( info->form,VSMOD_BVL_FLD_LIST,0, &nrows );
  for( i=0; i<nrows; i++)
    VIfld_set_list_text(info->form,VSMOD_BVL_FLD_LIST,i,0,text,0);
  FIg_set_text(info->form, VSMOD_BVL_FLD_BTN, "Update Button");
  // Reset button text
  FIg_disable(info->form, VSMOD_BVL_FLD_BTN);
  FIg_enable(info->form, VSMOD_BVL_FLD_BTN);
  // Clear any leftover status
  VIg_set_text( info->form, FI_MSG_FIELD, " ");
  VIg_set_text( info->form, FI_PROMPT_FIELD, " ");

  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbvlMac_ResetForm

/* -------------------------------------------------------
 * Create new collector (unique to edge), replace existing 
 *   shared collector (common to all plate edges) with new
 * I: Bevel object info
 * I: Old shared collector
 * O: New collector object 
 */
IGRlong VSbvlMac_CreateColl( TVSbevelInfo *info, TGRid *oldID, TGRid *collID )
{
  TGRid		sourceID;
  IGRlong	sts,
		retFlag;


  SetProc( VSbev_CreateColl ); Begin

  retFlag = 0;

  // Create collector object for bevel attribute object
  collID->osnum = info->bevelOE.obj_id.osnum;
  collID->objid = NULL_OBJID;

  om$construct(
    classid =  OPP_ACrg_collect_class_id,
    osnum   =  collID->osnum,
    p_objid = &collID->objid
  );
  if (collID->objid == NULL_OBJID) {
    printf("Problem Creating Collector object\n");
    goto wrapup;
  }

  __DBGpr_obj("collID", *collID);
  __DBGpr_obj("oldID",  *oldID);
  __DBGpr_obj("info->bevelOE", info->bevelOE.obj_id);

  // Swap existing collector with new collector (disconnects oldID)
  sts = om$send(msg	 = message NDnode.NDchange_connect(1, oldID, collID),
		senderid = NULL_OBJID,
		targetid = info->bevelOE.obj_id.objid,
		targetos = info->bevelOE.obj_id.osnum);
  __CheckRC(sts,1,"NDchange_connect",wrapup);


  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbvlMac_CreateColl

/* --------------------------------------------------------
 * Get attributes of input object
 * I: Collector object 
 * O: Count of collector's attributes
 * O: Attribute list 
 */
IGRlong VSbvlMac_GetAttrs( TGRid objID, IGRint *attCnt, TACrg_coll **attList )
{
  IGRint	i,
		count;
  IGRlong	sts, msg,
		retFlag;
  TACrg_coll	*aList=NULL;

  SetProc( VSbvlMac_GetAttrs ); Begin

  retFlag = 0;

  sts = om$send(
      msg = message ACrg_collect.AClist_attribute(&msg,0,NULL,&count),
      senderid = NULL_OBJID,
      targetid = objID.objid,
      targetos = objID.osnum
  );
  __CheckRC(sts,msg,"AClist_attribute1",wrapup);
  __DBGpr_int("attr count", count);

  *attCnt = count;

  // If none, it is unexpected
  if (count == 0) {
    printf("\tNo attributes found for attr object: %d\n", objID.objid);
    *attList = NULL;
    goto wrapup;
  }

  aList = _CALLOC(count,TACrg_coll); // Checks for null, prints line, file

  sts = om$send(
      msg = message ACrg_collect.AClist_attribute(&msg,count,aList,&count),
      senderid = NULL_OBJID,
      targetid = objID.objid,
      targetos = objID.osnum
  );
  __CheckRC(sts,msg,"AClist_attribute2",wrapup);

  *attList = aList;

  retFlag = 1;

wrapup:

  End
  return retFlag;

} // VSbev_GetAttrs


/* -----------------------------
 * Put attributes into collector
 * All arguments are inputs
 */
IGRlong VSbvlMac_PutAttrs( TGRid *attrID, IGRint cnt, TACrg_coll  *attrs )
{
  IGRlong	sts, msg,
		retFlag;


  SetProc( VSbev_PutAttrs ); Begin

  retFlag = 0;


  // Modifying any existing ones
  sts = om$send(
    msg = message ACrg_collect.ACmod_list_attribute(&msg,cnt,attrs),
    senderid = NULL_OBJID,
    targetid = attrID->objid,
    targetos = attrID->osnum
  );
  // msg = MSFAIL if attribute doesn't exist, so set second RC arg to 1 
  __CheckRC(sts,1,"ACmod_list_attribute",wrapup);


  // Add any new ones
  sts = om$send(
    msg = message ACrg_collect.ACadd_list_attribute(&msg,cnt,attrs),
    senderid = NULL_OBJID,
    targetid = attrID->objid,
    targetos = attrID->osnum
  );
  // msg = MSFAIL if attribute already exists, so set second RC arg to 1
  __CheckRC(sts,1,"ACadd_list_attribute",wrapup);


  retFlag = 1;

wrapup:

  End
  return retFlag;

} // VSbvlMac_PutAttrs


/* --------------------------------------
 * Misc stuff
 */
#argsused
IGRlong VSbvlMacCMD_ModInit(TVSbevelInfo *info)
{
  IGRint retFlag = 0;
  IGRint msg,sts;
  IGRint i;

  bevelNo=1;
 
  dp$erase_hilite(msg = &msg);
  memset(info,0,sizeof(TVSbevelInfo));

  sts = gr$get_module_env(buffer = &info->bevelOE.mod_env);
  if (!(sts & 1)) goto wrapup;
 
  retFlag = 1;
wrapup:
  return retFlag;
}

#argsused
IGRlong VSbvlMacCMD_ModSleep(TVSbevelInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);
  return 1;
}
#argsused
IGRlong VSbvlMacCMD_ModWakeup(TVSbevelInfo *info)
{
  //VDsupCMDEtcNotifyHiLite(info,1);
  return 1;
}

#argsused
IGRlong VSbvlMacCMD_ModDelete(TVSbevelInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);
  return 1;
}

end  implementation Root;
