/* $Id: VDct1DbTbl.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1DbTbl.C
 *
 * Description: Tree manager database tables for reviewing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1DbTbl.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.3  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.2  2000/09/07  18:04:04  pinnacle
 * js
 *
 * Revision 1.4  2000/08/23  14:51:24  pinnacle
 * ah
 *
 * Revision 1.3  2000/08/17  11:31:40  pinnacle
 * js
 *
 * Revision 1.2  2000/08/08  16:35:14  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/04  19:28:50  pinnacle
 * Created: vds/vdct1/cmd2/VDct1Part.C by jdsauby for Service Pack
 *
 * Revision 1.1  2000/07/27  15:13:14  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/05/00  js      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDris2.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

#include "VDct1Part.h"
#include "VDct1Ris.h"


VDASSERT_FFN("vdct1/cmd/VDct1DbTbl.C");

static TVDct1CmdInfo *cmdInfo;

static IGRstat qryElecDwgsTable(TVDrisInfo *info)
{
    VDASSERT_FN("qryElecDwgsTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from %s order by %s;",
	  VDCT1_RIS_TBLN_ELECDWG,
	  VDCT1_RIS_COLN_ELECDWG_DWG_NUM);
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

static IGRstat qryStructIOCTable(TVDrisInfo *info)
{
    VDASSERT_FN("qryStructIOCTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from %s order by %s;",
	  VDCT1_RIS_TBLN_SIOC,
	  VDCT1_RIS_COLN_SIOC_ISDP_FAMILY);
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

static IGRstat qryCableDynamicTable(TVDrisInfo *info)
{
    VDASSERT_FN("qryCableDynamicTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from tm_cable_dynamic order by file_key;");
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

static IGRstat qryOutfitDynamicTable(TVDrisInfo *info)
{
    VDASSERT_FN("qryOutfitDynamicTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from tm_outfit_dynamic order by file_key;");
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

static IGRstat qryPalletDynamicTable(TVDrisInfo *info)
{
    VDASSERT_FN("qryPalletDynamicTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from tm_pallet_dynamic order by file_key;");
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

static IGRstat qryWWayDynamicTable(TVDrisInfo *info)
{
    VDASSERT_FN("qryWWayDynamicTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from tm_wway_dynamic order by file_key;");
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}


/* -----------------------------------------
 * query the pallet code table
 */
static IGRstat qryPalletCodeTable(TVDrisInfo *info)
{
  VDASSERT_FN("qryPalletCodeTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from tm_pallet_codes order by pallet_code;");
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------
 * query the comm_code table
 */
static IGRstat qryCommCodeTable(TVDrisInfo *info)
{
  VDASSERT_FN("qryCommCodeTable");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  
  // build the query
  sprintf(info->sql,
	  "select * from %s order by %s;",
	  VDCT1_RIS_TBLN_COMMS,
	  VDCT1_RIS_COLN_COMMS_COMM_CODE);
  
  // execute
  VDrisQuery(info,NULL);
  
  if (info->cols < 1) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------
 * Form control to get list of tables that
 * can be queried.
 */
static IGRstat getTableListText(IGRint  i,
				IGRchar *buf)
{
  VDASSERT_FN("getTableListText");
  
  IGRstat retFlag = 1;
  
  // just a switch
  switch(i) {
    
    case  0: strcpy(buf,"COMM CODES");     goto wrapup;
    case  1: strcpy(buf,"PALLET CODES");   goto wrapup;  
    case  2: strcpy(buf,"STRUCT IOC");     goto wrapup;
    case  3: strcpy(buf,"ELEC DWGS");      goto wrapup;
    case  4: strcpy(buf,"CABLE DYNAMIC");  goto wrapup;
    case  5: strcpy(buf,"OUTFIT DYNAMIC"); goto wrapup;
    case  6: strcpy(buf,"PALLET DYNAMIC"); goto wrapup;
    case  7: strcpy(buf,"WWAY DYNAMIC");   goto wrapup;
   
    default: retFlag = 0; goto wrapup;
  }

  // done
 wrapup:
  return retFlag;
}

      

/* --------------------------------------
 * fill in the list of available queries
 */
static IGRstat fillFormTableList()
{
  VDASSERT_FN("fillFormTableList");
  
  IGRstat retFlag = 1;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->dbtbl;
  
  IGRint rows;
  IGRint i;

  IGRchar bufCurrent[64];
  IGRchar buf       [64];
  IGRint  gadget;
  
 
  // init
  *bufCurrent = 0;
  gadget      = VDCT_FORM_DBTBL_G_TABLES;
  
  // Save the existing selection (if any)
  VDfrmGetgText(formInfo->form,gadget,bufCurrent);
  
  // Reset list rows
  VDfrmSetgListNumRows(formInfo->form,gadget,0);
  
  // Cycle through
  for(i = 0; 
      getTableListText(i,buf);
      i++) {

    VDfrmSetgListText(formInfo->form,gadget,i,buf);

    // set the current buf to the first on the list if not already set
    if (*bufCurrent == 0) strcpy(bufCurrent,buf);
    
  }
  
  // Fill in actual value
  VDfrmSetgText(formInfo->form,gadget,bufCurrent);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------
 * get the name of the table and the data
 */
static IGRstat getTableNameAndInfo(IGRchar    *buf,
				   IGRchar    *table_name,
				   TVDrisInfo *info)
{
  VDASSERT_FN("getTableNameAndInfo");
  
  VDASSERTW(buf);
  VDASSERTW(table_name);
  VDASSERTW(info);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // do it
  if (!strcmp(buf,"COMM CODES")) {
    strcpy(table_name,VDCT1_RIS_TBLN_COMMS);
    return qryCommCodeTable(info);
  }
  
  if (!strcmp(buf,"PALLET CODES")) {
    strcpy(table_name,"tm_pallet_codes");
    return qryPalletCodeTable(info);
  }
  
  if (!strcmp(buf,"ELEC DWGS")) {
    strcpy(table_name,VDCT1_RIS_TBLN_ELECDWG);
    return qryElecDwgsTable(info);
  }
  
  if (!strcmp(buf,"STRUCT IOC")) {
    strcpy(table_name,VDCT1_RIS_TBLN_SIOC);
    return qryStructIOCTable(info);
  }
  
  if (!strcmp(buf,"CABLE DYNAMIC")) {
    strcpy(table_name,"tm_cable_dynamic");
    return qryCableDynamicTable(info);
  }
  
  if (!strcmp(buf,"OUTFIT DYNAMIC")) {
    strcpy(table_name,"tm_outfit_dynamic");
    return qryOutfitDynamicTable(info);
  }
  
  if (!strcmp(buf,"PALLET DYNAMIC")) {
    strcpy(table_name,"tm_pallet_dynamic");
    return qryPalletDynamicTable(info);
  }
  
  if (!strcmp(buf,"WWAY DYNAMIC"))  {
    strcpy(table_name,"tm_wway_dynamic");
    return qryWWayDynamicTable(info);
  }
  
  // done, nothing to do
  
 wrapup:
  if (traceFlag) printf(">>> %s %s 0\n",ffn(),fn);
  
  return 0;
}

/* ---------------------------------------
 * clear the form
 */
static IGRstat resetForm()
{
  VDASSERT_FN("resetForm");
  
  IGRstat retFlag = 1;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->dbtbl;
  
  IGRint rows;
  IGRint i;
  
  // the data
  VDfrmSetNumRows(formInfo->form,VDCT_FORM_DBTBL_G_COLS,0);
    
  // done
 wrapup:
  return retFlag;
}

  
/* ----------------------------------------
 * fill the form up
 */
static IGRstat fillFormRows(TVDrisInfo *info,
			    TVDrisInfo *col)
{
  VDASSERT_FN("fillFormRows");
  
  IGRstat retFlag = 1;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->dbtbl;
  
  IGRchar    buf[2056],buf1[2056];
  IGRint     i,len,lencolumn;
  IGRlong    row;
  

  VDASSERTW(info);
  VDASSERTW(col);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // do it

  // fill the column names
  strcpy(buf,"");
  len = 0;
  
  for(col->i = 0; col->i < col->rows; col->i++) {
    
    col->j = col->i * col->cols;
    lencolumn = atoi(col->buf[col->j+VDRIS_COLI_COLUMNS_LEN]) + 1;
    if (lencolumn < 12 ) lencolumn = 12;
    if (traceFlag) printf("### lencolumn = %d\n",lencolumn);
    
    len += lencolumn;
    
    strcat(buf,col->buf[col->j+VDRIS_COLI_COLUMNS_NAME]);
    while (strlen(buf) < len) strcat(buf," ");
    
  }  
  VDfrmSetfText(formInfo->form,VDCT_FORM_DBTBL_G_COLS,0,0,buf);

  // put in a seperator line
  strcpy(buf,"=");
  
  while (strlen(buf) < len) strcat(buf,"=");
  VDfrmSetfText(formInfo->form,VDCT_FORM_DBTBL_G_COLS,1,0,buf);
  
  // fill in the data section
  row = 2;
  
  for (info->i = 0; info->i < info->rows; info->i++) {
    strcpy(buf1,"");
    len = 0;
    
    info->j = info->i * info->cols;
    
    for(i = info->j; i < (info->j + info->cols); i++) {
    
      col->j = (i - info->j) * col->cols;
      
      lencolumn = atoi(col->buf[col->j+VDRIS_COLI_COLUMNS_LEN]) + 1;
      if (lencolumn < 12 ) lencolumn = 12;
      //if (traceFlag) printf("### lencolumn = %d\n",lencolumn);

      len += lencolumn;
      
      strcat(buf1,info->buf[i]);
      while (strlen(buf1) < len) strcat(buf1," ");
          
    }
    VDfrmSetfText(formInfo->form,VDCT_FORM_DBTBL_G_COLS,row,0,buf1);
    row++;    
  }
  
  // done
  retFlag = 1;

 wrapup:

  return retFlag;
}

/* ------------------------------------------
 * do it processor
 */
static IGRstat notifyDoit()
{
  VDASSERT_FN("notifyDoit");
  
  IGRstat retFlag = 1;
  IGRstat sts     = 0;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->dbtbl;
  
  TVDrisInfo info,col;
  IGRchar    table_name[64],buf[64];
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  VDrisInitInfo(&info);
  VDrisInitInfo(&col);

  // reset the form
  resetForm();
  
  // get the table from the form, process based on table  
  VDfrmGetgText(formInfo->form,VDCT_FORM_DBTBL_G_TABLES,buf);	

  sts = getTableNameAndInfo(buf,table_name,&info);
  if (!(sts & 1)) goto wrapup;

  // query for column names
  VDrisQryTableColumns(&col,table_name);
  if (col.rows < 1) goto wrapup;

  // Fill the form
  fillFormRows(&info,&col);
  
  // done
  
 wrapup:
  VDrisFreeInfo(&info);
  VDrisFreeInfo(&col);
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
static IGRstat notifyForm()
{
  VDASSERT_FN("notifyForm");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->dbtbl;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Process It
  switch(cmdInfo->gadget) {
    
    case FI_EXECUTE:
      notifyDoit();
      break;

      
    case FI_CANCEL:
      VDfrmDisplayForm(formInfo->form,0,&formInfo->displayed);
      break;

  }
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }
  return retFlag;
}


/* -------------------------------------------
 * Called to activate the form
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");
  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->dbtbl;

  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);
  
  // Fill in the list of available tables
  fillFormTableList();
  
wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitDbTblCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitDbTblCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Tracing
  traceFlagx = traceFlag = 0; //VDct1TraceFlag(VDCT1_TRACE_CMD_PART);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;
 
   // Default init
  formInfo = &cmdInfo->dbtbl;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_DBTBL_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->notifyForm   = notifyForm;
  formInfo->activateForm = activateForm;

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}




