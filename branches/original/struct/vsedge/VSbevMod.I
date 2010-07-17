/* $Id: VSbevMod.I,v 1.2 2001/02/05 17:07:57 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsedge/VSbevMod.I
 *
 * Description: Modify Bevel Attribute
 *		Provides capability to change certain attributes of an edge
 *		  attribute object with values obtained from an ascii setup
 *		  file. These attributes are:
 *			Spec Number, Process Number, Stock (Allowance), and
 *			Gap (V). The Adjacent Plate Thickness, "THK" in the
 *		  setup file, is used to calculate the value, delta plate
 *		  thickness, obtained from,
 *			delta thickness = current plate thickness - (minus)
 *					  adjacent plate thickness.
 *		It is the delta value that is inserted into the object's 
 *		  collector object and it is a major reason for the crea-
 *		  tion of this command.
 *
 *		A sample expected format of the setup file follows:
 *			#@ SPEC_NUMBER 2A
 *			#@ SPEC_NUMBER 2B
 *			#@ SPEC_NUMBER 3A
 *			#@ PROCESS Manual
 *			#@ STOCK 0.0
 *			#@ STOCK 1.0
 *			#@ STOCK 25.4
 *			#@ GAP 0.0
 *			#@ THK 18.0
 *			#@ THK 20.0
 *			#@ THK 22.0
 *			#@ THK 25.0
 *
 *		Place Edge Attributes command creates a shared attribute
 *		  collector which is eliminated if encountered and replaced
 *		  with a unique collector for each edge attribute object.
 *	
 * Dependencies: form,       VSmodBevel.F
 *		 driver,     pplcmd/COmodBevel.u
 *		 setup file, "edge_setup" (searched for in current dir or
 *					   config/drawing  directories)
 *
 * Revision History:
 *	$Log: VSbevMod.I,v $
 *	Revision 1.2  2001/02/05 17:07:57  jayadev
 *	VSbev_ReadSetupFileOLD() for old bevel command
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.10  2000/04/04  16:49:20  pinnacle
# Replaced: vsedge/VSbevMod.I for:  by impd252 for struct
#
# Revision 1.9  2000/04/04  16:09:30  pinnacle
# Replaced: vsedge/VSbevMod.I for:  by impd252 for struct
#
# Revision 1.8  1999/12/06  18:07:08  pinnacle
# tr179900739
#
# Revision 1.4  1999/05/31  17:44:36  pinnacle
# CR_179900195
#
# Revision 1.2  1999/04/23  15:17:20  pinnacle
# (No comment)
#
# Revision 1.1  1999/04/09  20:29:32  pinnacle
# CR_179900195: Creation, for Modify Bevel Attribute command
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 03/22/99  ejm       CR179900195: Creation for Modify Bevel Attributes cmd
 * 04/23/99  ejm       CR179900195: Change delta thickness name to DTHK.
 * 05/06/99  ejm       CR179900195: Replace an existing shared attr collector
 *				    with one unique to edge
 * 05/26/99  ejm       CR179900195: Added VSbev_Fence_FillMCF, vdobj$GetParent
 *				    call, retain current dTHK value if Adj
 *				    Plate Thickness not selected
 * 08/20/99  Jayadev   TR179900739  Done some clean up work on this command and
 *                                  rewritten the function VSbev_ReadSetupFile.
 *                                  Also the function VSbev_OpenSetupFile was 
 *                                  added. Added functions inside the ppl 
 *                                  COmodBevel.u to update the edge attributes 
 * 04/04/00  adz 	Add functionality to support reading bevel_setup file.
 * 02/05/01  Jayadev    VSbev_ReadSetupFile changed to VSbev_ReadSetupFileOLD
 *                      to handle old modify bevel command	
 ***************************************************************************/

class implementation VSedge3Datt;


//#define  vdsDEBUG 1

#include "VDmaster.h"

#include "VDatClass.h"		// VDAT_CHN_TO_CHILDREN
#include "VDahFrm.h"		// Wrappers for FI calls
#include "VSbevMod.h"		// Function prototypes
#include "vsAPImacros.h"	// vs$get_plate_attributes
#include "vsmiscmacros.h"       // vs$is_ancestry_valid
#include "VDobj.h"		// vdobj$GetParent
#include "VDfrm.h"

extern GRclassid OPP_ACrg_collect_class_id;

from ACrg_collect  import ACmod_list_attribute, ACadd_list_attribute,
			  AClist_attribute;

/*  edgeNo:	set in VSbevCMD_ModInit, reset when form is exited;	*/
/*		prefixed to plate name on form only			*/
%safe
static IGRint edgeNo;
%endsafe



/* ----------------------------------------------------------------
 * Routine to fill columns in multi-column field
 * objName returned as 100 chars from VSgetName which removes path,
 *    [DI_PATH_MAX = 1023]
 */
IGRlong VSbev_FillMCF( TVSbevModInfo *info )
{
  IGRlong	retFlag = 0, 
		msg, sts;
  IGRchar	value[MAX_FLD_LEN],   // value written to multi-column field
				      // also used as text buffer
		objName[MAX_FLD_LEN]; // name of plate edge attr obj belongs to
  IGRint	i, count,
		rows, num;
  IGRint	nrows, sel, pos;
  IGRdouble	objid;		      // VSedge3Datt id from hidden column
  IGRuint	chdCnt;               // count of a collector's children
  TACrg_coll	*attList=NULL;	      // attributes from collector
  TGRid		*parent_list=NULL,    // parents of edge attribute object
		collID, parentID;



  SetProc( VSbev_FillMCF ); Begin


  __DBGpr_obj("Located object", info->edgeOE.obj_id);

  // Initialize status bars
  VIg_set_text( info->form, FI_PROMPT_FIELD, ""); 
  VIg_set_text( info->form, FI_MSG_FIELD, "" ); 

  // Check if located object already listed on form
  VIfld_get_num_rows( info->form, VSBEV_FORM_MCF, &nrows );

  for( i=0; i<nrows; i++ )
  {
    sts=FIfld_get_value(info->form, VSBEV_FORM_MCF, i, 6, &objid, &sel, &pos);
    if( info->edgeOE.obj_id.objid == (int)objid ){
      VIfld_get_text(info->form,VSBEV_FORM_MCF,i,0,MAX_FLD_LEN,objName,&sel,&pos);
      sprintf(value,"%s%s%s %d %s", "Plate edge, \"", objName, "\",  id",
		info->edgeOE.obj_id.objid, ", already listed");
      UI_status( value ); 
      goto wrapup;
    }
  }

  // Get parents of edge attribute object;
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
            targetid  = info->edgeOE.obj_id.objid,
            targetos  = info->edgeOE.obj_id.osnum);
  __CheckRC(sts,1,"NDnode.NDget_objects",wrapup);

  __DBGpr_int("num parents", num);
#ifdef vdsDEBUG
  for( i=0; i<num; i++ )
    printf("\t  os:%d  id:%d\n", parent_list[i].osnum, parent_list[i].objid);
#endif

  for( i=0; i<num; i++ )
  {
    if( vs$is_ancestry_valid( object = &parent_list[i],
                              classid= OPP_ACrg_collect_class_id ) )
      {
	// Get current collector attributes
	sts = VSbev_GetAttrs( parent_list[i], &count, &attList );
	__CheckRC(sts,1,"VSbev_GetAttrs",wrapup);

	// If current collector has only one child (one VSedge3Datt
	//   object), keep, otherwise, create a new collector,
	//   unique to current edge (VDAT parent is really child)
	sts = VDahGetChnCount(&parent_list[i], VDAT_CHN_TO_PARENT, &chdCnt); 
	__DBGpr_int("num collector children", chdCnt);

	if( chdCnt > 1 )
	{
	  // Create new edge collector, replacing original collector
	  sts = VSbev_CreateColl( info, &parent_list[i], &collID ); 
	  __CheckRC(sts,1,"VSbev_CreateColl",wrapup);

	  // Put original collector attributes into new edge collector
	  sts = VSbev_PutAttrs( &collID, count, attList );
	  __CheckRC(sts,1,"VSbev_PutAttrs",wrapup);
	}
      }
  }

#ifdef NEEDED
  __DBGpr_com("attr names");
  for( i=0; i<count; i++ )
  {
    __DBGpr_str("  ", attList[i].name);
  }
#endif

  VIfld_get_num_rows( info->form, info->gadget, &rows );

  // Initialize info->dTHK
  info->dTHK[rows] = -1;   // not set

  // Get wanted attributes
  for( i=0; i<count; i++ )
  {
    if( strcmp( attList[i].name, "SPEC NUMBER" ) == 0 )
      VDahFrmSetTextRC(
	info->form,info->gadget,rows,1,attList[i].desc.value.att_txt);
    else if( strcmp( attList[i].name, "PROCESS" ) == 0 )
      VDahFrmSetTextRC(
	info->form,info->gadget,rows,2,attList[i].desc.value.att_txt);
    else if( strcmp( attList[i].name, "ALLOWANCE" ) == 0 )
    {
      sprintf(value,"%.1f",attList[i].desc.value.att_exp);
      VDahFrmSetTextRC(info->form,info->gadget,rows,3,value);
    }
    else if( strcmp( attList[i].name, "V" ) == 0 )
    {
      sprintf(value,"%.1f",attList[i].desc.value.att_exp);
      VDahFrmSetTextRC(info->form,info->gadget,rows,4,value);
    }
    else if( strcmp( attList[i].name, "DTHK" ) == 0 )
    {
      // Retain current delta plate thickness, using row number as index
      info->dTHK[rows] = attList[i].desc.value.att_exp;
    }
  } // for

  // Get plate parent
  sts =vdobj$GetParent(objOE = &info->edgeOE,
                       idx   = 0,
                       parentID  = &parentID,  // The real parent, no pretend
                       );
  if (!(sts & 1)) {
    printf("Failed to Get Parent\n");
    goto wrapup;
  }

  info->plateID = parentID;

  __DBGpr_int("plate objid", info->plateID.objid);

  // Now get plate name
  *objName=0;
  VSgetName( &info->plateID, objName);
  if (*objName == 0) {
    strcpy(objName,"Defined");
  }
  __DBGpr_str("plate name", objName);

  sprintf(value,"%d %s",edgeNo,objName);
  VDahFrmSetTextRC(info->form,info->gadget,rows,0,value);

  // Relate object to it's attributes - put objid in hidden column
  FIfld_set_value(
	info->form,info->gadget,rows,6,(double)info->edgeOE.obj_id.objid,0);

  // Info for user
  VIg_set_text( info->form, FI_PROMPT_FIELD, 
		"Select Adj Plate Thickness to set Delta THK, DTHK");

  edgeNo = edgeNo + 1;

  retFlag = 1;

wrapup:
  _FREE( attList );
  End
  return retFlag;

} // VSbev_FillMCF

/* -----------------------------------------
 * Sort edge attribute objects within fence,
 * Call VSbev_FillMCF to fill form   
 */
IGRlong VSbev_Fence_FillMCF( TVSbevModInfo *info )
{
  IGRlong	retFlag = 0;
  IGRint	i;
  IGRchar	text[MAX_FLD_LEN];

  IGRint      edgeCNT = 0;
  TGRobj_env *edgeOEs = NULL;

  // Don't do one without the other
  IGRint  response;
  IGRchar response_data[1024];


  SetProc( VSbev_Fence_FillMCF ); Begin


 
  *response_data = 0;
   response = 0;
 
  as$start_fence(set       = &info->edgeOE.obj_id,
                 set_env   = &info->edgeOE.mod_env,
                 nb_obj    = &edgeCNT,
                 response  = &response,
                 response_data = response_data,
                 p_obj_env = &edgeOEs);

  if (response != EX_DATA) goto wrapup;

  *text=0;
  sprintf(text, "%s%d", "Edges in fence: ", edgeCNT);
  UI_status(text);

  for( i=0; i<edgeCNT; i++ )
  {
    info->edgeOE = edgeOEs[i];
    VSbev_FillMCF( info );
  }


  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbev_Fence_FillMCF

/*
 * Read the "edge_setup" file.
 */
FILE *VSbev_OpenSetupFile()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file;

  // Look in local directory
  file = fopen("edge_setup","rt");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    ex$get_path( index = i,
		 path  = buf,
		 len   = sizeof(buf),
		 type  = EX_CONFIG_PATH );
    if (*buf == 0) {
      file = NULL;
      return file;
    }
    
    strcat(buf,"config/drawing/edge_setup");
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}

/*
 * Read the "bevel_setup" file.
 */

FILE *VSbev_OpenBevelSetupFile()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file;

  // Look in local directory
  file = fopen("bevel_setup","rt");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    ex$get_path( index = i,
		 path  = buf,
		 len   = sizeof(buf),
		 type  = EX_CONFIG_PATH );
    if (*buf == 0) {
      file = NULL;
      return file;
    }
    
    strcat(buf,"config/drawing/bevel_setup");
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}
/* -----------------------------------------------------------------------
 * Read setup file, fill values for field list
 */
IGRlong VSbev_ReadSetupFileOLD( 
  Form form, IGRint gadget)
{
  IGRlong	retFlag = 0;
  FILE          *fileptr;
  IGRint	col,row, pos, 
                sts,nrows,i;
  IGRchar	buf[256], *p=NULL, text[MAX_FLD_LEN];	// line read from ascii file
  
  row = 0;
  
  fileptr = VSbev_OpenSetupFile();
  if(fileptr == NULL) goto wrapup;
  
  // Get the active column
  
  FImcf_get_active_col(form, VSBEV_FORM_MCF, &col, &pos);
  
  // Erase existing pick list
  FIfld_get_list_num_rows(form,gadget,0, &nrows );
  text[0]='\0';
  for( i=0; i<nrows; i++)
    vdfrm$SetListText(form   = form, 
		      gadget = gadget, 
		      row    = i, 
		      txt    = text);
  if(col== 0) {
    retFlag = 1;
    goto wrapup;
  }
  // Cycle through
  while(fgets(buf,sizeof(buf),fileptr)) {
    
    if (!strncmp(buf,"#@ ",3)) {
      strcpy(buf,buf+3);
      for(i=0;buf[i]!=' ' ;i++);
      p = &buf[i+1];
      
      if((col == 1) && !strncmp(buf,"SPEC", 4)){
	vdfrm$SetListText(form   = form, 
			  gadget = gadget, 
			  row    = row, 
			  txt    = p);
	row++;
      }
      else if((col == 2) && !strncmp(buf,"PROCESS", 7)){
	vdfrm$SetListText(form   = form, 
			  gadget = gadget, 
			  row    = row, 
			  txt    = p);
	row++;
      }
      else if((col == 3) && !strncmp(buf,"STOCK", 5)){
	vdfrm$SetListText(form   = form, 
			  gadget = gadget, 
			  row    = row, 
			  txt    = p);
	row++;
      }
      else if((col == 4) && !strncmp(buf,"GAP", 3)){
	vdfrm$SetListText(form   = form, 
			  gadget = gadget, 
			  row    = row, 
			  txt    = p);
	row++;
      }
      else if((col == 5) && !strncmp(buf,"THK", 3)){
	vdfrm$SetListText(form   = form, 
			  gadget = gadget, 
			  row    = row, 
			  txt    = p);
	row++;
      }
    }
  }
  fclose(fileptr);
  retFlag = 1;
 wrapup:
  if(retFlag == 0)
    printf("Reading setup file failed\n");
  return retFlag;
} // VSbev_ReadSetupFileOLD

/* -----------------------------------------------------------------------
 * Read setup file, fill values for new bevel command
 */
IGRlong VSbev_ReadSetupProcessSpec( 
  Form form, IGRint gadSpec, IGRint gadProc )
{
  IGRlong	retFlag = 0;
  FILE          *fileptr;
  IGRint	col, rowSpec, rowProc, pos, 
                sts,nrows,i;
  IGRchar	buf[256], *p=NULL, text[MAX_FLD_LEN];	// line read from ascii file
  
  rowProc = 0;
  rowSpec = 0;

  // Get the active column
  FIfld_set_list_num_rows( form, gadSpec, 0, rowSpec );
  FIfld_set_list_num_rows( form, gadProc, 0, rowProc );
  
  fileptr = NULL ;
  fileptr = VSbev_OpenBevelSetupFile();
  if(fileptr == NULL) goto wrapup;
  
  // Cycle through
  while(fgets(buf,sizeof(buf),fileptr)) {

#ifdef	vdsDEBUG
       	printf(" >%s\n", buf );
#endif
    
      if(!strncmp(buf,"% ", 2)){

	buf[strlen(buf)-1] = '\0';
        strcpy(buf,buf+1);
        for(i=0;buf[i]!=' ' && i<250 ;i++);
        p = &buf[i+1];
	
#ifdef	vdsDEBUG
        printf("P>%s\n", buf );
#endif
	vdfrm$SetListText(form   = form, 
			  gadget = gadProc, 
			  row    = rowProc, 
			  txt    = p);
	rowProc++;
	continue ;
      }
      if(!strncmp(buf,"# ", 2)){

	buf[strlen(buf)-1] = '\0';
        strcpy(buf,buf+1);
        for(i=0;buf[i]!=' ' && i<250 ;i++);
        p = &buf[i+1];

#ifdef	vdsDEBUG
        printf("S>%s\n", buf );
#endif
	
	vdfrm$SetListText(form   = form, 
			  gadget = gadSpec, 
			  row    = rowSpec, 
			  txt    = p);
	rowSpec++;
	continue ;
      }
  }

  FIfld_set_list_num_rows( form, gadSpec, 0, rowSpec );
  FIfld_set_list_num_rows( form, gadProc, 0, rowProc );
  
  fclose(fileptr);
  retFlag = 1;

wrapup:

  if(retFlag == 0)
    printf("Reading setup file failed\n");
  return retFlag;
} // VSbev_ReadSetupProcessSpec


/* --------------------------------------------
 * Row, column was picked, fill associated list
 */
IGRlong VSbev_PickedMCF(TVSbevModInfo *info)
{
  IGRlong	retFlag = 0;
  IGRint	row, col, pos, sel,	// Row, column selected
		nchar, nrows, cnt, 
		sts, i, length; 
  IGRchar	text[MAX_FLD_LEN];	// Text from field


  SetProc( VSbev_PickedMCF ); Begin

  // Indicate column selected on field button
  VIfld_get_active_row(info->form, info->gadget, &info->row, &pos);
  FImcf_get_active_col(info->form, info->gadget, &info->col, &pos);
#ifdef vdsDEBUG
  printf("\tselected row:%d  col:%d\n", info->row, info->col);
#endif

  // Clear any leftover status
  VIg_set_text( info->form, FI_PROMPT_FIELD, " ");
  VIg_set_text( info->form, FI_MSG_FIELD, " ");
  
  if( info->col == 0 ){
    VIg_set_text(
      info->form, FI_MSG_FIELD, "First column not an attribute column");
    FIg_set_text(info->form, VSBEV_FORM_FLD_BTN, "Update Button");
    // Update text on button
    FIg_disable(info->form, VSBEV_FORM_FLD_BTN);
    FIg_enable(info->form, VSBEV_FORM_FLD_BTN);
    
    // Erase existing pick list
    FIfld_get_list_num_rows(info->form,VSBEV_FORM_FLD_LIST,0, &nrows );
    text[0]='\0';
    for( i=0; i<nrows; i++)
      vdfrm$SetListText(form   = info->form, 
			gadget = VSBEV_FORM_FLD_LIST, 
			row    = i, 
			txt    = text);
    FIg_set_text(info->form,VSBEV_FORM_FLD_LIST,text);
    goto wrapup;
  }
  
  if( info->col == 5 ){
    *text=0;
    if( info->dTHK[info->row] == -1 )
      sprintf(text, "%s", "DTHK not set");
    else
      sprintf(text,"%s = %.2f", "DTHK", info->dTHK[info->row]);
    VIg_set_text( info->form, FI_MSG_FIELD, text);
  }
  
  switch(info->col)
  {
    case 1:{
      FIg_set_text(info->form, VSBEV_FORM_FLD_BTN, "Update All SPEC Numbers");
      break;
    }
    case 2:{
      FIg_set_text(info->form, VSBEV_FORM_FLD_BTN, "Update All PROCESS Numbers");
      break;
    }
    case 3:{
      FIg_set_text(info->form, VSBEV_FORM_FLD_BTN, "Update All STOCK Numbers");
      break;
    }
    case 4:{
      FIg_set_text(info->form, VSBEV_FORM_FLD_BTN, "Update All GAP Numbers");
      break;
    }
    case 5:{
      FIg_set_text(info->form, VSBEV_FORM_FLD_BTN, "Update All THICKNESS Numbers");
      break;
    }
    default:
      break;
  }
  // Update text on button
  FIg_disable(info->form, VSBEV_FORM_FLD_BTN);
  FIg_enable(info->form, VSBEV_FORM_FLD_BTN);
  
  //nchar=MAX_FLD_LEN;
  //VIfld_get_text(info->form,info->gadget,info->row,info->col,nchar,text,&sel,&pos); 
  
  sts = VSbev_ReadSetupFileOLD(info->form,VSBEV_FORM_FLD_LIST);
  __CheckRC(sts,1,"VSbev_ReadSetupFileOLD",wrapup);
  
  // Get first list row and insert into accompanying field
/*  FIfld_get_list_text(
    info->form,VSBEV_FORM_FLD_LIST,0,0,MAX_FLD_LEN,(unsigned char *)text,&sel);
  FIg_set_text(info->form,VSBEV_FORM_FLD_LIST,text);
*/ 

  VIfld_get_text(info->form,VSBEV_FORM_MCF,info->row,info->col,MAX_FLD_LEN,text
  ,&sel,&pos);
  FIg_set_text(info->form,VSBEV_FORM_FLD_LIST,text);
  /*
    Position cursor at end of field text- No!, list takes it as an entry!
    FIg_get_text_length(info->form,VSBEV_FORM_FLD_LIST,&length);
    FIfld_pos_cursor(info->form,VSBEV_FORM_FLD_LIST,0,0,0,0,length+1,length+1);
  */
  
  // Disable, enable field gadget to make text appear NOW!
  FIg_disable(info->form, VSBEV_FORM_FLD_LIST);
  FIg_enable(info->form, VSBEV_FORM_FLD_LIST);
  
  retFlag = 1;
  
  
 wrapup:
  End
    return retFlag;
  
} // VSbev_PickedMCF

/* ---------------------------------------------------------------------
 * List gadget was picked, insert it's text into intended row and column
 */
IGRlong VSbev_PickedList(TVSbevModInfo *info)
{
  IGRlong	retFlag;
  IGRchar	text[MAX_FLD_LEN];
  
  
  SetProc( VSbev_PickedList ); Begin
  retFlag = 0;
  
  // Do not update the first column
  if(info->col == 0)
    return retFlag;
  
  text[0] = '\0';
  
  // Get text chosen from associated list or typed in,
  //   requires "Notify By Line" as editing option in Form Builder.
  //   FIfld_get_list_text gets text from list, not field gadget.
  
  FIg_get_text(info->form,VSBEV_FORM_FLD_LIST,text);
  
  VIfld_set_text(info->form, VSBEV_FORM_MCF, info->row, info->col, text, 0);
  
  // Clear DTHK info
  if( info->col == 5 ) 
    VIg_set_text( info->form, FI_MSG_FIELD, "");
  
  retFlag = 1;
  
  End
    return retFlag;
  
} // VSbev_PickedList

/* ---------------------------------------------------
 * Update button gadget was picked, take list text and
 *   write it to all rows in appropriate column
 */
IGRlong VSbev_PickedUpdButton(TVSbevModInfo *info)
{
  IGRlong	retFlag;
  IGRint	nrows, i;
  IGRchar	text[MAX_FLD_LEN];


  SetProc( VSbev_PickedUpdButton ); Begin

  nrows   = 0;
  text[0] = '\0';

  if(info->col == 0) // this check added for TR179900739
  {
     retFlag = 1;
     return retFlag;
  }
  // Get text chosen from associated list or typed in,
  //   requires "Notify at End" as editing option in Form Builder.
  //   FIfld_get_list_text gets text from list, not field gadget.

  FIg_get_text(info->form,VSBEV_FORM_FLD_LIST,text);

  VIfld_get_num_rows( info->form, VSBEV_FORM_MCF, &nrows );
  __DBGpr_int("num rows to update", nrows);
  __DBGpr_int("column   to update", info->col);

  for( i=0; i<nrows; i++ )
    VIfld_set_text(info->form, VSBEV_FORM_MCF, i, info->col, text, 0);

  retFlag = 1;

  End
  return retFlag;

} // VSbev_PickedList

/* -----------------------------------------------------
 * Transfer single attribute value to object's collector
 * Puts value into ACrg_coll structure
 * "objId" is from the form, VSedge3Datt object
 * All arguments are inputs
 */
IGRlong VSbev_Attrs( IGRint objId,    IGRchar *name,      IGRint type, 
		     IGRchar *value , TVSbevModInfo *info)
{
  IGRlong     retFlag;
  IGRlong     sts,msg;
  TACrg_coll  attrs;
  IGRint      cnt;
  IGRdouble   valueDbl;
  TGRid       edgeId, 	// edge attribute object
	      collId;	// collector object of edge attribute object

  SetProc( VSbev_Attrs ); Begin

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
  if ( attrs.desc.type == AC_ATTRIB_TEXT )
    strcpy ( attrs.desc.value.att_txt, value );
  else
  {
    valueDbl = atof(value);
    attrs.desc.value.att_exp = valueDbl;
  }
 
  // Get ACrg collector of VSedge3Datt object (index=2)
  //   All edges expected to be in same object space
  edgeId.objid = objId;
  edgeId.osnum = info->edgeOE.obj_id.osnum;

  // Get collector (3rd object, 2nd index) on NDfather channel
  sts = VDahGetChnObject(&edgeId,VDAT_CHN_TO_CHILDREN,2,&collId);
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


  // Add any new ones
    sts = om$send(
      msg = message ACrg_collect.ACadd_list_attribute(&msg,cnt,&attrs),
      senderid = NULL_OBJID,
      targetid = collId.objid,
      targetos = collId.osnum
    );
    // msg = MSFAIL if attribute already exists, so set second RC arg to 1
    __CheckRC(sts,1,"ACadd_list_attribute",wrapup);


  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbev_Attrs

/* --------------------------------------------
 * Run form (FI_ACCEPT or FI_EXECUTE), 
 *    update edge attribute object's attributes
 * Object id retrieved from hidden column
 */
IGRlong VSbev_ModAttrs(TVSbevModInfo *info)
{
  IGRint	nchars, nrows, i, sel, pos;
  IGRlong	sts, msg;
  IGRdouble	objid, curThk, adjThk, delThk;
  IGRchar	text[MAX_FLD_LEN];
  IGRlong	retFlag;


  SetProc( VSbev_ModAttrs ); Begin


  retFlag=0;
  nchars=MAX_FLD_LEN;

  // Get number of rows (= number of edge attributes picked)
  VIfld_get_num_rows( info->form, VSBEV_FORM_MCF, &nrows );
  __DBGpr_int("nrows, number of edge attribute objects selected", nrows);

  // Write values to object's collector
  for( i=0; i<nrows; i++ )
  {
    sts=FIfld_get_value(info->form, VSBEV_FORM_MCF, i, 6, &objid, &sel, &pos);
    __DBGpr_int("object id", objid);

    // Spec
    VIfld_get_text( info->form,VSBEV_FORM_MCF,i,1,nchars,text,&sel,&pos); 
    sts = VSbev_Attrs(objid, "SPEC NUMBER", AC_ATTRIB_TEXT, text, info);
    __CheckRC(sts,1,"VSbev_Attrs for Spec",wrapup);

    // Process
    VIfld_get_text( info->form,VSBEV_FORM_MCF,i,2,nchars,text,&sel,&pos); 
    sts = VSbev_Attrs(objid, "PROCESS", AC_ATTRIB_TEXT, text, info);
    __CheckRC(sts,1,"VSbev_Attrs for Process",wrapup);

    // Stock
    VIfld_get_text( info->form,VSBEV_FORM_MCF,i,3,nchars,text,&sel,&pos); 
    sts = VSbev_Attrs(objid, "ALLOWANCE", AC_ATTRIB_DOUBLE, text, info);
    __CheckRC(sts,1,"VSbev_Attrs for Stock",wrapup);

    // Gap
    VIfld_get_text( info->form,VSBEV_FORM_MCF,i,4,nchars,text,&sel,&pos); 
    sts = VSbev_Attrs(objid, "V", AC_ATTRIB_DOUBLE, text, info);
    __CheckRC(sts,1,"VSbev_Attrs for Gap",wrapup);

    // Adjacent Plate Thickness
    // Value to pass: Delta plate thickness, =
    //			current plate thickness (plate_attribute) -
    //			adjacent plate thickness (form value)
    // If Adj Plate Thickness not selected (=0), use current value of DTHK

    // Get adjacent plate thickness from form
    VIfld_get_text( info->form,VSBEV_FORM_MCF,i,5,nchars,text,&sel,&pos); 

    adjThk = (double) atof(text);

    if( adjThk == 0 )
    {
      delThk = info->dTHK[i];
      __DBGpr_dbl("delThk", delThk);
    }
    else
    {
      __DBGpr_obj("plateID", info->plateID);

      sts = vs$get_plate_attributes( msg       = &msg,
				     plateId   = &info->plateID ,
				     thickness = &curThk );
      __CheckRC(sts,msg,"vs$get_plate_attributes",wrapup);

      delThk = curThk - adjThk;
#ifdef vdsDEBUG
      printf("\tdelThk: %.2f = curThk: %.2f - adjThk: %.2f\n", 
					delThk,curThk,adjThk);
#endif
    }

    // VSbev_Attrs converts text to double
    text[0]='\0';
    sprintf(text,"%.2f",delThk);

    sts = VSbev_Attrs(objid, "DTHK", AC_ATTRIB_DOUBLE, text, info);
    __CheckRC(sts,1,"VSbev_Attrs for THicKness",wrapup);

  } // for

  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbev_ModAttrs


/* --------------------------------------
 * FI_ACCEPT selected, clear form of data
 */
IGRlong VSbev_ResetForm(TVSbevModInfo *info)
{
  IGRlong	retFlag;
  IGRchar	text[MAX_FLD_LEN];
  IGRint	nrows, i;


  SetProc( VSbev_ResetForm ); Begin

  edgeNo = 1;

  FIfld_set_num_rows(info->form, VSBEV_FORM_MCF, 0);
  memset(&text[0],0,sizeof(text));
  FIg_set_text(info->form,VSBEV_FORM_FLD_LIST,text);
  FIfld_get_list_num_rows( info->form,VSBEV_FORM_FLD_LIST,0, &nrows );
  for( i=0; i<nrows; i++)
    VIfld_set_list_text(info->form,VSBEV_FORM_FLD_LIST,i,0,text,0);
  FIg_set_text(info->form, VSBEV_FORM_FLD_BTN, "Update Button");
  // Reset button text
  FIg_disable(info->form, VSBEV_FORM_FLD_BTN);
  FIg_enable(info->form, VSBEV_FORM_FLD_BTN);
  // Clear any leftover status
  VIg_set_text( info->form, FI_MSG_FIELD, " ");
  VIg_set_text( info->form, FI_PROMPT_FIELD, " ");

  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbev_ResetForm

/* -------------------------------------------------------
 * Create new collector (unique to edge), replace existing 
 *   shared collector (common to all plate edges) with new
 * I: Edge object info
 * I: Old shared collector
 * O: New collector object 
 */
IGRlong VSbev_CreateColl( TVSbevModInfo *info, TGRid *oldID, TGRid *collID )
{
  TGRid		sourceID;
  IGRlong	sts,
		retFlag;


  SetProc( VSbev_CreateColl ); Begin

  retFlag = 0;

  // Create collector object for edge attribute object
  collID->osnum = info->edgeOE.obj_id.osnum;
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
  __DBGpr_obj("info->edgeOE", info->edgeOE.obj_id);

  // Swap existing collector with new collector (disconnects oldID)
  sts = om$send(msg = message NDnode.NDchange_connect
                    (1,oldID,collID),
		    senderid = NULL_OBJID,
                    targetid = info->edgeOE.obj_id.objid,
                    targetos = info->edgeOE.obj_id.osnum);
  __CheckRC(sts,1,"NDchange_connect",wrapup);


  retFlag = 1;

wrapup:
  End
  return retFlag;

} // VSbev_CreateColl

/* --------------------------------------------------------
 * Get attributes of input object
 * I: Collector object 
 * O: Count of collector's attributes
 * O: Attribute list 
 */
IGRlong VSbev_GetAttrs( TGRid objID, IGRint *attCnt, TACrg_coll **attList )
{
  IGRint	i,
		count;
  IGRlong	sts, msg,
		retFlag;
  TACrg_coll	*aList=NULL;

  SetProc( VSbev_GetAttrs ); Begin

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
IGRlong VSbev_PutAttrs( TGRid *attrID, IGRint cnt, TACrg_coll  *attrs )
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

} // VSbev_PutAttrs


/* --------------------------------------
 * Misc stuff
 */
#argsused
IGRlong VSbevCMD_ModInit(TVSbevModInfo *info)
{
  IGRint retFlag = 0;
  IGRint msg,sts;
  IGRint i;

  edgeNo=1;
 
  dp$erase_hilite(msg = &msg);
  memset(info,0,sizeof(TVSbevModInfo));

  sts = gr$get_module_env(buffer = &info->edgeOE.mod_env);
  if (!(sts & 1)) goto wrapup;
 
  retFlag = 1;
wrapup:
  return retFlag;
}

#argsused
IGRlong VSbevCMD_ModSleep(TVSbevModInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);
  return 1;
}
#argsused
IGRlong VSbevCMD_ModWakeup(TVSbevModInfo *info)
{
  //VDsupCMDEtcNotifyHiLite(info,1);
  return 1;
}

#argsused
IGRlong VSbevCMD_ModDelete(TVSbevModInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);
  return 1;
}

end  implementation VSedge3Datt;
