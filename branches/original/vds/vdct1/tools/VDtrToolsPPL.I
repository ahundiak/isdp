/* $Id: VDtrToolsPPL.I,v 1.8 2001/05/09 14:28:51 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tools/VDtrToolsPPL.I
 *
 * Description: Drivers for PPL Access form
 *
 * Dependencies: $Log: VDtrToolsPPL.I,v $
 * Dependencies: Revision 1.8  2001/05/09 14:28:51  paul_noel
 * Dependencies: CR4987 Review PPL Program updated  New Dir vds/config/ppl/ppl_programs
 * Dependencies:
 * Dependencies: Revision 1.7  2001/03/22 19:09:13  paul_noel
 * Dependencies: Add Exclusive search to review ppl programs
 * Dependencies:
 * Dependencies: Revision 1.6  2001/03/21 18:36:39  paul_noel
 * Dependencies: Update and fix issues on Review PPL Programs
 * Dependencies:
 * Dependencies: Revision 1.5  2001/03/16 16:20:34  paul_noel
 * Dependencies: Update Review PPL Programs to include Run option
 * Dependencies:
 * Dependencies: Revision 1.4  2001/03/16 14:58:32  paul_noel
 * Dependencies: fix up COPPLinfo
 * Dependencies:
 * Dependencies: Revision 1.3  2001/03/15 12:10:21  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.2  2001/03/15 12:07:57  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.1  2001/03/14 15:10:22  paul_noel
 * Dependencies: Add VDtrToolsPPL.I
 * Dependencies:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/01  pn      Creation
 ***************************************************************************/

// PPL display controls
class implementation VDct1Base;

#include "vdtr_macros.h"
#include "VDassert.h"
#include "VDmem.h"
#include "VDctx.h"
#include "vdtr_ppl.h"
#include "VDfrm.h"
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDppl1.h"
#include "v_pplslc.h"

VDASSERT_FFN("vdct1/tools/VDtrToolsPPL.I");

IGRstat VDtrInitForm(char **form_ptr);
IGRstat VDtrWakeForm(char *form_ptr);
IGRstat VDtrSleepForm(char *form_ptr);
IGRstat VDtrDeleteForm(char *form_ptr);
IGRstat VDtrListSelected(char *form_ptr);
IGRstat VDtrReadList();
IGRstat VDtrRunSelected(char *form_ptr,IGRint gadget, IGRint col);
IGRstat VDtrFillPPLList(char *form_ptr,IGRint gadget,IGRint col);
IGRstat VDtrFillPPLCmdDesc(char *form_ptr,IGRint gadget,IGRint source, IGRint col);
IGRstat VDtrFillPPLInfoList(char *form_ptr,IGRint gadget,IGRint source, IGRint col);
IGRstat VDtrGetbufDat(VDioBufDat *bufDat);
IGRstat VDtrSetbufDat(VDioBufDat *bufDat);
IGRstat VDtrFillPPLListByKey(char *form_ptr,IGRint gadget,IGRint col,IGRint keyGadget);
IGRstat IsKeyWordInString(IGRchar *strCmd,IGRchar *keyWords);
IGRstat VDtrFillPPLListByExKey(char *form_ptr,IGRint gadget,IGRint col,IGRint keyGadget);
IGRstat AreKeyWordsInString(IGRchar *strCmd,IGRchar *keyWords);

static char *form_ptr;
static VDioBufDat pplList;
/* ----------------------------------------
 * form notification routine
 * ***/
static IGRint notifyForm(IGRint      f_label,
	                 IGRint      g_label,
			 IGRdouble   value,
			 Form        form)
{
    VDASSERT_FN("notifyForm");

    IGRstat retFlag = 1;
    IGRstat sts;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    switch(g_label) {
      /* the cancel button was selected */
      case FI_CANCEL:
        VDtrDeleteForm( form );
        break;

        /* the list was selected */
      case VDTR_PPL_LIST:
        VDtrListSelected( form );
        /* fill up the Command Description */
        VDtrFillPPLCmdDesc(form, VDTR_PPL_SEL_PPL,VDTR_PPL_LIST,0);
        /* fill up the InfoList */
        VDtrFillPPLInfoList(form,VDTR_PPL_DATA,VDTR_PPL_LIST,0);
        break;

        /* Inclusive keyWord Search */
      case VDTR_PPL_KEY_B: /* 21 */
        /* fill the list from the keywords */
        VDtrFillPPLListByKey(form,VDTR_PPL_LIST,0,VDTR_PPL_KEY_TXT); // 12/19
        /* fill up the Command Description */
        VDtrFillPPLCmdDesc(form, VDTR_PPL_SEL_PPL,VDTR_PPL_LIST,0);
        /* fill up the InfoList */
        VDtrFillPPLInfoList(form,VDTR_PPL_DATA,VDTR_PPL_LIST,0);
        break;

        /* exclusive keyWord Search */
      case VDTR_PPL_KEYX_B: /* 22 */
        /* fill the list from the keywords */
        VDtrFillPPLListByExKey(form,VDTR_PPL_LIST,0,VDTR_PPL_KEY_TXT); // 12/19
        /* fill up the Command Description */
        VDtrFillPPLCmdDesc(form, VDTR_PPL_SEL_PPL,VDTR_PPL_LIST,0);
        /* fill up the InfoList */
        VDtrFillPPLInfoList(form,VDTR_PPL_DATA,VDTR_PPL_LIST,0);
        break;


        /* clear keyWord Search */
      case VDTR_PPL_KEYC_B: /* 24 */
        /* empty the text in the keyWords */
        VIg_set_text(form,VDTR_PPL_KEY_TXT,"");
        /* fill the list from the keywords */
        VDtrFillPPLListByKey(form,VDTR_PPL_LIST,0,VDTR_PPL_KEY_TXT); // 12/19
        /* fill up the Command Description */
        VDtrFillPPLCmdDesc(form, VDTR_PPL_SEL_PPL,VDTR_PPL_LIST,0);
        /* fill up the InfoList */
        VDtrFillPPLInfoList(form,VDTR_PPL_DATA,VDTR_PPL_LIST,0);
        break;

        /*the run button was selected */
      case VDTR_PPL_B_RUN:
        VDtrRunSelected( form, VDTR_PPL_LIST,0);
        /* delete the form */
        //VDfrmDeleteForm( form, 0 );
        break;

        /* default does nothing */
      default:
        break;

    }

wrapup:
    return retFlag;
}

/*****************************************************
 *
 * The run button was selected
 *
 *****************************************************/
IGRstat VDtrRunSelected(char *form_ptr,IGRint gadget, IGRint col)
{
  VDASSERT_FN("VDtrRunSelected");
  IGRstat   retFlag = 0;
  IGRint    row,rows,i,selFlag,pos;
  IGRchar   pplName[128],buf[128];

  /* init */
  row = rows = i = selFlag = pos = 0;
  pplName[0] = '\0';
  buf[0] = '\0';
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn);
  }
  /* clear the messages */
  vdfrm$SetStatus(form = form_ptr, txt = buf);

  /* args checks */
  if(gadget < 11) goto wrapup;
  if(col < 0) goto wrapup;
  if(form_ptr == NULL) goto wrapup;

  /* look up the selected gadget in the list */
  VIfld_get_num_rows(form_ptr, gadget, &rows);
  if(rows == 0) {
    strcpy(buf,"No PPL's to select from.");
    vdfrm$SetStatus(form = form_ptr, txt = buf);
    goto wrapup;
  }
  
  for(i = 0;i<rows;i++) {
    /* get the selection status */
    VIfld_get_text(form_ptr, gadget,i,0, 15, pplName,&selFlag,&pos);
    /* if the selection is ok stop */
    if(selFlag & 1) {
      if(strcmp(pplName,"")) {
        /* sleep the form */
        VDtrSleepForm( form_ptr );
        /* run the new ppl */
        vd$ppl_exec(  file_name = pplName);
        /* wake the form */
        VDtrWakeForm( form_ptr );
        sprintf(buf,"PPL selected: [%s] \n",pplName);
        vdfrm$SetStatus(form = form_ptr, txt = buf);
      }
      retFlag = 1;
      goto wrapup;
    }
  }


  strcpy(buf,"Please select a PPL. \n");
  vdfrm$SetStatus(form = form_ptr, txt = buf);
  
  retFlag = 1;

 wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}



/*****************************************************
 *
 * The list was clicked
 *
 *****************************************************/
IGRstat VDtrListSelected(char *form_ptr)
{
  VDASSERT_FN("VDtrListSelected");
  IGRstat   retFlag = 0;
  IGRint    row,rows,i,j,selFlag,sts,pos;
  IGRchar   pplName[128],buf[128];

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* init */
  row = rows = i = j = selFlag = 0;
  pplName[0] = '\0';
  buf[0] = '\0';
  selFlag = 0;
  pos = 0;
  
  vdfrm$SetStatus(form = form_ptr, txt = "");
  
  /* get the number of rows */
  FIfld_get_num_rows( form_ptr, VDTR_PPL_LIST, &rows );
  if(rows == 0) {
    strcpy(buf,"No PPL to select from. \n");
    vdfrm$SetStatus(form = form_ptr, txt = buf);
    goto wrapup;
  }
  
  /* cycle throught the rows to see if any are selected */
  for(i = 0;i < rows;i++) {
    VIfld_get_text(form_ptr, VDTR_PPL_LIST,i,0, 15, pplName,&selFlag,&pos);
    if(selFlag & 1) {
      if(!strcmp(pplName,"")) {
        goto wrapup;
      }
      sprintf(buf,"PPL selected: [%s] \n",pplName);
      vdfrm$SetStatus(form = form_ptr, txt = buf);
      retFlag = 1;
      goto wrapup;
    }
  }

  VIfld_set_select(form_ptr,VDTR_PPL_LIST, 0, 0, 1);
  VIfld_get_text(form_ptr, VDTR_PPL_LIST,0,0, 15, pplName,&selFlag,&pos);
  sprintf(buf,"PPL selected: [%s] \n",pplName);
  vdfrm$SetStatus(form = form_ptr, txt = buf);
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Read the pplList from disk
 *
 *****************************************************/
IGRstat VDtrReadList()
{
  VDASSERT_FN("VDtrReadList");

  IGRstat   retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* Set file pointer to NULL  */
  pplList.filebuf = NULL ;
  pplList.lines = 0 ;
  strcpy(pplList.partpath,"config/ppl/");
  pplList.linelength = 128 ;
  strcpy( pplList.filename, "ppl_programs" );
  /* read the expr_table file */
  retFlag = VDio_read_file( &pplList );

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}
/*****************************************************
 *
 * Load up the list gadget
 * this will load the data from pplList into any form
 * in any list gadget  in any col
 * the data must filled however!
 * see  VDtrReadList() for this functionality
 *
 *****************************************************/
IGRstat VDtrFillPPLList(char *form_ptr,IGRint gadget,IGRint col)
{
  VDASSERT_FN("VDtrFillPPLList");

  IGRstat   retFlag = 0;
  IGRint    i,rows,row,sts,cnt,selFlag;
  IGRchar  *ptr,*p,buf[128],str[128];

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn);
  }

  /* args checks */ 
  if(gadget < 11) goto wrapup;
  if(col < 0) goto wrapup;

  /* clear out the gadget */
  VIfld_set_num_rows(form_ptr,gadget,0);

  rows = pplList.lines;

  if(rows < 1) goto wrapup;
  ptr = pplList.filebuf;
  strcpy(buf,ptr);
  cnt = 0;
  selFlag = 0;
  row = 0;

  // loop through the data from the file
  for(i = 0;i < pplList.lines;i++) {
    strcpy(buf,ptr);
    p = buf;
    if(*p == '%') {
      p += 2;
      strcpy(str,p);
        vdtr$GetDelimitedStr(impStr = str,
                       outStr = buf,
                       delChr = ' ',
                       posStr = 1);
      VIfld_set_num_rows(form_ptr,gadget,row);
      VIfld_set_text(form_ptr, gadget, row, col, buf, selFlag);
      row++;
    }
   VIfld_set_select(form_ptr,gadget,0,col,1);
 
    ptr += VDTR_BUF_SIZE;
  }


  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}
/*****************************************************
 *
 * check to see if the keyWords are in the strCmd 
 * all of them must be present
 *
 *****************************************************/
IGRstat AreKeyWordsInString(IGRchar *strCmd,IGRchar *keyWords)
{
  VDASSERT_FN("AreKeywordsInString");

  IGRstat   retFlag = 0;
  IGRint    i,strLen = 0;
  IGRchar  *p,*q,buf[128],strLocal[128],strTest[128];

  // say hi
  if (traceFlag) {
    printf("\n**>> %s %s\n",ffn(),fn);
    /* printf("strCmd [%s] keyWords [%s]\n",strCmd,keyWords); */
  }

  /* inits */
  buf[0]      = '\0';
  strLocal[0]      = '\0';

  /* args check */
  VDASSERTW(strCmd);
  VDASSERTW(keyWords);
  if (strCmd[0] == '\0') goto wrapup;
  if (keyWords[0] == '\0') goto wrapup;

  /* copy it across */
  strcpy(strLocal,strCmd);
  VDstrupr(strLocal);


  /* break out each key word */
  i = 1;
  p = NULL;
  strLen = strlen(keyWords);
  vdtr$GetDelimitedStr(impStr = keyWords,
                       outStr = buf,
                       delChr = ' ',
                       posStr = i);
  if((!strcmp(buf,"")) && (strLen < 2)) strcpy(buf,keyWords);

  while(strcmp(buf,"")) {
    VDstrupr(buf);
    p = strstr(strLocal,buf);
    if(p == NULL)  goto wrapup;
    i++;
    vdtr$GetDelimitedStr(impStr = keyWords,
                         outStr = buf,
                         delChr = ' ',
                         posStr = i);
  }

  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}
/*****************************************************
 *
 * check to see if the keyWords are in the strCmd 
 *
 *****************************************************/
IGRstat IsKeyWordInString(IGRchar *strCmd,IGRchar *keyWords)
{
  VDASSERT_FN("IsKeywordInString");

  IGRstat   retFlag = 0;
  IGRint    i,strLen = 0;
  IGRchar  *p,*q,buf[128],strLocal[128],strTest[128];

  // say hi
  if (traceFlag) {
    printf("\n**>> %s %s\n",ffn(),fn);
  }

  /* inits */
  buf[0]      = '\0';
  strLocal[0]      = '\0';

  /* args check */
  VDASSERTW(strCmd);
  VDASSERTW(keyWords);
  if (strCmd[0] == '\0') goto wrapup;
  if (keyWords[0] == '\0') goto wrapup;

  /* copy it across */
  strcpy(strLocal,strCmd);
  VDstrupr(strLocal);


  /* break out each key word */
  i = 1;
  p = NULL;
  strLen = strlen(keyWords);
  vdtr$GetDelimitedStr(impStr = keyWords,
                       outStr = buf,
                       delChr = ' ',
                       posStr = i);

  if((!strcmp(buf,"")) && (strLen < 2)) strcpy(buf,keyWords);
  while(strcmp(buf,"")) {
    VDstrupr(buf);
    p = strstr(strLocal,buf);
    if(!(p == NULL)) {
      retFlag = 1;
      goto wrapup;
    }
    
    i++;
    vdtr$GetDelimitedStr(impStr = keyWords,
                         outStr = buf,
                         delChr = ' ',
                         posStr = i);
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}
/*****************************************************
 *
 * Load up the list gadget
 * this will load the data from pplList into any form
 * in any list gadget  in any col
 * the data must filled however!
 * see  VDtrReadList() for this functionality
 * reads the Key words and searches for them in the 
 * Command description
 * fills exclusively any item matching all keywords
 *
 *****************************************************/
IGRstat VDtrFillPPLListByExKey(char *form_ptr,IGRint gadget,IGRint col,IGRint keyGadget)
{
  VDASSERT_FN("VDtrFillPPLListByKey");

  IGRstat   retFlag = 0;
  IGRint    i,rows,row,sts,cnt,selFlag;
  IGRchar  *ptr,*p,buf[128],str[128],keyWords[128],strCmd[128];

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn);
  }

  /* args checks */ 
  if(gadget < 11) goto wrapup;
  if(col < 0) goto wrapup;
  if(keyGadget < 11) goto wrapup;

 /* read the keyGadget */
  VIg_get_text(form_ptr,keyGadget,keyWords);
  if(!strcmp(keyWords,"")) {
  /* fill up the list gadget */
    VDtrFillPPLList(form_ptr,VDTR_PPL_LIST,0);
  strcpy(buf,"PPL List -- No Keyword Search\n");
  vdfrm$SetStatus(form = form_ptr, txt = buf);
    goto wrapup;
  }

  /* clear out the gadget */
  VIfld_set_num_rows(form_ptr,gadget,0);

  rows = pplList.lines;

  if(rows < 1) goto wrapup;
  ptr = pplList.filebuf;
  strcpy(buf,ptr);
  cnt = 0;
  selFlag = 0;
  row = 0;
  buf[0]      = '\0';
  str[0]      = '\0';
  strCmd[0]   = '\0';

  // loop through the data from the file
  for(i = 0;i < pplList.lines;i++) {
    strcpy(buf,ptr);
    p = buf;
    if(*p == '%') {
      p += 2;
      strcpy(str,p);
      vdtr$GetDelimitedStr(impStr = str,
                           outStr = buf,
                           delChr = ' ',
                           posStr = 1);
      vdtr$GetDelimitedStr(impStr = str,
                           outStr = strCmd,
                           delChr = '"',
                           posStr = 2);
      /* if it is a match */
      if(AreKeyWordsInString(strCmd,keyWords)) {
        VIfld_set_num_rows(form_ptr,gadget,row);
        VIfld_set_text(form_ptr, gadget, row, col, buf, selFlag);
        row++;
      } /* end if not match check */
    } /* end if it is a command string */
    
    VIfld_set_select(form_ptr,gadget,0,col,1);
    ptr += VDTR_BUF_SIZE;
  }

  sprintf(buf,"PPL List Exclusive Matching '%s'\n",keyWords);
  vdfrm$SetStatus(form = form_ptr, txt = buf);
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}


/*****************************************************
 *
 * Load up the list gadget
 * this will load the data from pplList into any form
 * in any list gadget  in any col
 * the data must filled however!
 * see  VDtrReadList() for this functionality
 * reads the Key words and searches for them in the 
 * Command description fills matching any keywords
 *
 *****************************************************/
IGRstat VDtrFillPPLListByKey(char *form_ptr,IGRint gadget,IGRint col,IGRint keyGadget)
{
  VDASSERT_FN("VDtrFillPPLListByKey");

  IGRstat   retFlag = 0;
  IGRint    i,rows,row,sts,cnt,selFlag;
  IGRchar  *ptr,*p,buf[128],str[128],keyWords[128],strCmd[128];

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn);
  }

  /* args checks */ 
  if(gadget < 11) goto wrapup;
  if(col < 0) goto wrapup;
  if(keyGadget < 11) goto wrapup;

 /* read the keyGadget */
  VIg_get_text(form_ptr,keyGadget,keyWords);
  if(!strcmp(keyWords,"")) {
  /* fill up the list gadget */
    VDtrFillPPLList(form_ptr,VDTR_PPL_LIST,0);
  strcpy(buf,"PPL List -- No Keyword Search\n");
  vdfrm$SetStatus(form = form_ptr, txt = buf);
    goto wrapup;
  }

  /* clear out the gadget */
  VIfld_set_num_rows(form_ptr,gadget,0);

  rows = pplList.lines;

  if(rows < 1) goto wrapup;
  ptr = pplList.filebuf;
  strcpy(buf,ptr);
  cnt = 0;
  selFlag = 0;
  row = 0;
  buf[0]      = '\0';
  str[0]      = '\0';
  strCmd[0]   = '\0';

  // loop through the data from the file
  for(i = 0;i < pplList.lines;i++) {
    strcpy(buf,ptr);
    p = buf;
    if(*p == '%') {
      p += 2;
      strcpy(str,p);
      vdtr$GetDelimitedStr(impStr = str,
                           outStr = buf,
                           delChr = ' ',
                           posStr = 1);
      vdtr$GetDelimitedStr(impStr = str,
                           outStr = strCmd,
                           delChr = '"',
                           posStr = 2);
      if(IsKeyWordInString(strCmd,keyWords)) {
        VIfld_set_num_rows(form_ptr,gadget,row);
        VIfld_set_text(form_ptr, gadget, row, col, buf, selFlag);
        row++;
      }
    }
   VIfld_set_select(form_ptr,gadget,0,col,1);
    ptr += VDTR_BUF_SIZE;
  }

  sprintf(buf,"PPL List Inclusive Matching '%s'\n",keyWords);
  vdfrm$SetStatus(form = form_ptr, txt = buf);
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}

/*****************************************************
 *
 * Fill the PPL Command Secification
 *
 *****************************************************/
IGRstat VDtrFillPPLCmdDesc(char *form_ptr,IGRint gadget,IGRint source, IGRint col)
{
  VDASSERT_FN("VDtrFillPPLCmdDesc");

  IGRstat   retFlag = 0;
  IGRint    i,rows,row,selFlag,pos;
  IGRchar   buf[128],strCmd[128],strList[128],*ptr;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn);
  }

  /* args checks */
  if(form_ptr == NULL) goto wrapup;
  if(gadget < 11) goto wrapup;
  if(col < 0 ) goto wrapup;
  if(source < 11) goto wrapup;
  if(gadget == source) goto wrapup;
  

  /* inits */
  buf[0] = '\0';
  strCmd[0] = '\0';
  strList[0] = '\0';
  row = 0;
  rows = 0;
  selFlag = 0;
  pos = 0;
  

  /* clear out the stuff */
  VIg_set_text(form_ptr, gadget, buf);

  /* look up the selected gadget in the list */
  VIfld_get_num_rows(form_ptr, source, &rows);
  for(i = 0;i<rows;i++) {
    /* get the selection status */
    VIfld_get_text(form_ptr, source,i,0, 15, strList,&selFlag,&pos);
    /* if the selection is ok stop */
    if(selFlag & 1) {
      break;
    }
  }

  /* check to make sure you have something */
  if(strList[0] == '\0') goto wrapup;
  
  /* go down through the pplList and find the command description that matches */
  /* note:  PPL names had better be unique! */
  ptr = pplList.filebuf;
  strcpy(buf,ptr);
  for(i = 0;i<pplList.lines;i++) {
    /* is it a command */
    if(*ptr == '%') {
      strcpy(buf,ptr);
      vdtr$GetDelimitedStr(impStr = buf,
                           outStr = strCmd,
                           delChr = ' ',
                           posStr = 2);
      /* does the command match with the one from the list */
      if(!strcmp(strCmd,strList)){
        strCmd[0] = '\0';
        vdtr$GetDelimitedStr(impStr = buf,
                             outStr = strCmd,
                             delChr = '"',
                             posStr = 2);
        /* post the results */
        VIg_set_text(form_ptr, gadget, strCmd);
        retFlag = 1;
      }
    }
    ptr += VDTR_BUF_SIZE;
  }


wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}
/*****************************************************
 *
 * Fill the PPL Information List
 *
 *****************************************************/
IGRstat VDtrFillPPLInfoList(char *form_ptr,IGRint gadget,IGRint source, IGRint col)
{
  VDASSERT_FN("VDtrFillPPLInfoList");

  IGRstat   retFlag = 0;
  IGRint    i,j,rows,row,selFlag,pos,gotCom;
  IGRchar   buf[128],strCmd[128],strList[128],*ptr,*p;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn);
  }

  /* args checks */
  if(form_ptr == NULL) goto wrapup;
  if(gadget < 11) goto wrapup;
  if(col < 0 ) goto wrapup;
  if(source < 11) goto wrapup;
  if(gadget == source) goto wrapup;
  

  /* inits */
  buf[0] = '\0';
  strCmd[0] = '\0';
  strList[0] = '\0';
  row = 0;
  rows = 0;
  selFlag = 0;
  pos = 0;
  gotCom = 0;
  j = 0;
   
  /* clear out the gadget */
  VIfld_set_num_rows(form_ptr,gadget,0);

  /* look up the selected gadget in the list */
  VIfld_get_num_rows(form_ptr, source, &rows);
  for(i = 0;i<rows;i++) {
    /* get the selection status */
    VIfld_get_text(form_ptr, source,i,0, 15, strList,&selFlag,&pos);
    /* if the selection is ok stop */
    if(selFlag & 1) {
      break;
    }
  }

  /* check to make sure you have something */
  if(strList[0] == '\0') goto wrapup;
  
  /* go down through the pplList and find the command description that matches */
  /* note:  PPL names had better be unique! */
  ptr = pplList.filebuf;
  strcpy(buf,ptr);
  for(i = 0;i<pplList.lines;i++) {
    /* is it a command */
    if(*ptr == '%') {
      strcpy(buf,ptr);
      vdtr$GetDelimitedStr(impStr = buf,
                           outStr = strCmd,
                           delChr = ' ',
                           posStr = 2);
      /* does the command match with the one from the list */
      if(!strcmp(strCmd,strList)){
        ptr += VDTR_BUF_SIZE;
        gotCom = 1;
        i++;
        break;
      }
    }
    ptr += VDTR_BUF_SIZE;
  }
  /* do we have the command now? */
  if(gotCom & 1) {
    /* continue looping for commands to stick into the display rows */
    for(j = i;j<pplList.lines;j++) {
      /* is this a command if so quit */
      if(*ptr == '%') { 
        break;
      } 
      /* is this to be listed */
      if(*ptr == '#') {
        p = ptr;
        p += 2;
        strcpy(buf,p);
        /* put the stuff in the gadget */
        VIfld_set_num_rows(form_ptr,gadget,row);
        VIfld_set_text(form_ptr, gadget, row, col, buf,0);
        row++;
      }
      /* goto the next line in the file */
      ptr += VDTR_BUF_SIZE;
    }
  }
  

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;

}

/*****************************************************
 *
 * Init the form
 *
 *****************************************************/
IGRstat VDtrInitForm(char **form_ptr)
{
  VDASSERT_FN("VDtrInitForm");
  IGRstat   retFlag = 0;
  IGRint    formFlag = 1;
  IGRint    i,rows,pos = 0,selFlag,notify = 0;
  IGRstat   sts = 0;
  Form      form;
  IGRchar   pplName[128],buf[128];
  IGRint    disp_flag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* init */
  *form_ptr = NULL;
  pplName[0] = '\0';
  buf[0] = '\0';

  /* start up the form */
  VDfrmNewForm(557,"VDRevPPLInfo.F",notifyForm,0,&form);
  sts = VDfrmDisplayForm( form, 1, &disp_flag );

  /* load up the data in the list */
  VDtrReadList();

  /* load the data into the form */
  rows = 0;
  rows = pplList.lines;
  /* fill up the list gadget */
  VDtrFillPPLList(form,VDTR_PPL_LIST,0);
  /* fill up the Command Description */
  VDtrFillPPLCmdDesc(form, VDTR_PPL_SEL_PPL,VDTR_PPL_LIST,0);
  /* fill up the InfoList */
  VDtrFillPPLInfoList(form,VDTR_PPL_DATA,VDTR_PPL_LIST,0);
  
  VIfld_get_text(form, VDTR_PPL_LIST,0,0, 15, pplName,&selFlag,&pos);
  sprintf(buf,"PPL selected: [%s] \n",pplName);
  vdfrm$SetStatus(form = form, txt = buf);
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Wake the form
 *
 *****************************************************/
IGRstat VDtrWakeForm(char *form_ptr)
{
  VDASSERT_FN("VDtrWakeForm");
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* make the form appear */
  VIf_display(form_ptr);
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}




/*****************************************************
 *
 * Sleep the form
 *
 *****************************************************/
IGRstat VDtrSleepForm(char *form_ptr)
{
  VDASSERT_FN("VDtrSleepForm");
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* make the form disappear */ 
  vdfrm$EraseForm(form = form_ptr,show = 0,flag = NULL);
  
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Destroy the form
 *
 *****************************************************/
IGRstat VDtrDeleteForm(char *form_ptr)
{
  VDASSERT_FN("VDtrDeleteForm");
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  

  VDfrmDeleteForm( form_ptr, 0 );
  retFlag = 1;
  
wrapup:
  // say bye 
  _FREE( pplList.filebuf );

  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Expose the pplList to the world
 *
 *****************************************************/
IGRstat VDtrGetbufDat(VDioBufDat *bufDat)
{
  VDASSERT_FN("VDtrGetbufDat");
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* send the address over */
  bufDat = &pplList;

  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Set pplList 
 *
 *****************************************************/
IGRstat VDtrSetbufDat(VDioBufDat *bufDat)
{
  VDASSERT_FN("VDtrSetbufDat");
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  pplList = *bufDat;
  
  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Starts up the "Review PPL Programs" command operations
 * The PPL calls this to start the functionality
 *
 *****************************************************/
IGRstat VDtrReviewPPLPrograms()
{
  VDASSERT_FN("VDtrReviewPPLPrograms");
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  form_ptr = NULL;

  VDtrInitForm(&form_ptr);
  
  //VDtrDeleteForm(form_ptr);

  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


end implementation VDct1Base;
