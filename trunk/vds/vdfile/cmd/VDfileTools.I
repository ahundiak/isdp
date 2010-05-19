/* $Id: VDfileTools.I,v 1.5 2001/10/02 15:56:52 paul_noel Exp $  */


/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tools/VDfileTools.I
 *
 * Description: Misc tools from all over that need to be way up here
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/10/01  pn      Creation
 ***************************************************************************/

// Generic tools for files

class implementation Root;
#include "VDtypedef.h"
#include "VDmem.h"
#include "VDassert.h"
#include "VDfrm.h"
#include <sys/stat.h>
#include "ci.h"
#include <dirent.h>
#include "VDppl1.h"
#include "vdsmacros.h"
#include "vdtr_macros.h"
#include "VDfile.h"
#include "vdtvwtools.h"


FILE   *VDtrCmdSetOpenListOfSets();

VDASSERT_FFN("vds/vdfile/VDfileTools.I");
/********************************************
 *
 * Clip out the phrases for evaluation of 
 * wild cards from a string
 *
 ********************************************/
IGRint VDtvwClipWildCardStr(IGRchar *wildCard,IGRchar ***strList,IGRint *strListCnt)
{
  VDASSERT_FN("VDtvwClipWildCardStr");
  IGRint retFlag = 0;
  IGRchar *p,*q,buf[1028],tmp[1028];
  IGRint  lenWildCard,lenItem,lenWC;
  IGRint  i,next;
 
  /* say hi */
  if (traceFlag) printf(">>> %s %s wildCard [%s]\n",ffn(),fn,wildCard);

  /* inits */
  tmp[0] = '\0';
  buf[0] = '\0';
  /* clean up the list stuff */
  if(*strListCnt > 0) _LOOPFREE( *strList,*strListCnt);
  *strListCnt = 0;
  next = 0;
  p = wildCard;

 /* args check stuff */
  lenWC = strlen(wildCard);
  if(lenWC < 1) goto wrapup;
  
  /* start building strings for allocation */
  for(i = 0;i < lenWC;i++) {
    if(buf[0] != '\0') {
      if(buf[0] == '*') {
	if(*p != '*') {
	  VDtvwAddStrList(buf,strList,strListCnt);  
	  buf[0] = '\0';
	}
      } else {
	if(*p == '*') {
	  VDtvwAddStrList(buf,strList,strListCnt);  
  	  buf[0] = '\0';
	} else {
	  sprintf(tmp,"%s%c",buf,*p);
	  strcpy(buf,tmp);
	}
	
      }
      
    } 
    if(buf[0] == '\0') {
      sprintf(buf,"%c",*p);
    }
    p++;
  }
  /* clean up the last string if it exists */
  if(buf[0] != '\0') VDtvwAddStrList(buf,strList,strListCnt);  
  
  if(*strListCnt < 1) goto wrapup;
  retFlag = 1; 
wrapup:
  // say bye 

  
  if (traceFlag) {
    printf("<<< %s %s %d\n\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/********************************************
 *
 * add item to a text box unique 
 * checks to see if the item is in the box before 
 * adding it to the list
 * checks for special case of a "" blank item 
 *
 ********************************************/
IGRint VDtvwFormMakeTextItemsUnique(Form     form,
				    IGRint   gadget,
				    IGRint   flag,
				    IGRint   addItem)
{
  VDASSERT_FN("VDtvwFormMakeTextItemsUnique");
  IGRint  retFlag = 0;
  IGRint  row,rows,i;
  IGRchar **textList;
  IGRint  textListCnt = 0;
  IGRchar listText[128],name[128];

   
  
    /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  VDASSERTW(form);
  if(gadget < 11) goto wrapup;

  /* get the textbox viewed text */
  FIg_get_text(form,gadget,name);
  
  /* get the number of rows in the textbox list */
  FIfld_get_list_num_rows( form, gadget,0, &rows );
    
  if(rows < 1) goto wrapup;
  for(row = 0;row < rows;row++) {
    vdfrm$GetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = listText);
    VDtvwAddStrListUnique(listText,&textList,&textListCnt); 
  }

  if(addItem == 1) {
    VDtvwAddStrListUnique(name,&textList,&textListCnt); 
  }
   if(addItem == -1) {
    if(strcmp(name,"")) VDtvwAddStrListUnique(name,&textList,&textListCnt); 
  } 

  /* handle the case where nothing must be done */
  if(textListCnt == rows) goto wrapup;

  FIg_reset( form, gadget );
  /* put the stuff back */
  for(row = 0;row < textListCnt;row++) {
    vdfrm$SetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = textList[row]);
  }

  /* notify the count of rows */
  FIfld_set_list_num_rows(form,gadget,0,textListCnt);
  
  /* set the selection */
  if(flag == 1) FIg_set_text(form,gadget,textList[0]);
  if(flag == 0)  FIg_set_text(form,gadget,name);
  if(flag == -1) FIg_set_text(form,gadget,"");
  // FIg_enable(form,gadget);
  

  retFlag = 1;
wrapup:

  if(textListCnt > 0) _LOOPFREE( textList,textListCnt );
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * add item to a text box (not Unique)
 * checks to see if the item is in the box before 
 * adding it to the list
 * checks for special case of a "" blank item 
 * alphabetic least to highest 
 *
 ********************************************/
IGRint VDtvwFormMakeTextItemsAUp(Form     form,
				       IGRint   gadget,
				       IGRint   flag,
				       IGRint   addItem)
{
  VDASSERT_FN("VDtvwFormMakeTextItemsAUp");
  IGRint  retFlag = 0;
  IGRint  row,rows,i,j,cntOut,cntIn,comparison;
  IGRchar **textList;
  IGRint  textListCnt = 0;
  IGRchar listText[128],name[128],*address;

   
  
    /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  VDASSERTW(form);
  if(gadget < 11) goto wrapup;

  /* get the textbox viewed text */
  FIg_get_text(form,gadget,name);
  
  /* get the number of rows in the textbox list */
  FIfld_get_list_num_rows( form, gadget,0, &rows );
    
  if(rows < 1) goto wrapup;
  for(row = 0;row < rows;row++) {
    vdfrm$GetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = listText);
    VDtvwAddStrList(listText,&textList,&textListCnt); 
  }

  if(addItem == 1) {
    VDtvwAddStrList(name,&textList,&textListCnt); 
  }

  if(addItem == -1) {
    if(strcmp(name,"")) VDtvwAddStrList(name,&textList,&textListCnt); 
  }  
  cntOut = textListCnt;
  cntOut--;
  cntIn = cntOut;

  /* do the sort */
  for(i = 0;i < cntOut;i++) {
    for(j = 0;j < cntIn;j++) {
      comparison = strcmp(textList[j],textList[j+1]);
      if(comparison > 0) {
	address = textList[j];
	textList[j] = textList[j+1];
	textList[j+1] = address;
      }
    }
    cntIn--;
  }
  

  FIg_reset( form, gadget );
  /* put the stuff back */
  for(row = 0;row < textListCnt;row++) {
    vdfrm$SetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = textList[row]);
  }

  /* notify the count of rows */
  FIfld_set_list_num_rows(form,gadget,0,textListCnt);
  
  /* set the selection */
  if(flag == 1) FIg_set_text(form,gadget,textList[0]);
  if(flag == 0)  FIg_set_text(form,gadget,name);
  if(flag == -1) FIg_set_text(form,gadget,"");
  // FIg_enable(form,gadget);
  

  retFlag = 1;
wrapup:

  if(textListCnt > 0) _LOOPFREE( textList,textListCnt );
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * add item to a text box unique 
 * checks to see if the item is in the box before 
 * adding it to the list
 * checks for special case of a "" blank item 
 * alphabetic least to highest 
 *
 ********************************************/
IGRint VDtvwFormMakeTextItemsUniqueAUp(Form     form,
				       IGRint   gadget,
				       IGRint   flag,
				       IGRint   addItem)
{
  VDASSERT_FN("VDtvwFormMakeTextItemsUniqueAUp");
  IGRint  retFlag = 0;
  IGRint  row,rows,i,j,cntOut,cntIn,comparison;
  IGRchar **textList;
  IGRint  textListCnt = 0;
  IGRchar listText[128],name[128],*address;

   
  
    /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  VDASSERTW(form);
  if(gadget < 11) goto wrapup;

  /* get the textbox viewed text */
  FIg_get_text(form,gadget,name);
  
  /* get the number of rows in the textbox list */
  FIfld_get_list_num_rows( form, gadget,0, &rows );
    
  if(rows < 1) goto wrapup;
  for(row = 0;row < rows;row++) {
    vdfrm$GetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = listText);
    VDtvwAddStrListUnique(listText,&textList,&textListCnt); 
  }

  if(addItem == 1) {
    VDtvwAddStrListUnique(name,&textList,&textListCnt); 
  }

  if(addItem == -1) {
    if(strcmp(name,"")) VDtvwAddStrListUnique(name,&textList,&textListCnt); 
  }  
  cntOut = textListCnt;
  cntOut--;
  cntIn = cntOut;

  /* do the sort */
  for(i = 0;i < cntOut;i++) {
    for(j = 0;j < cntIn;j++) {
      comparison = strcmp(textList[j],textList[j+1]);
      if(comparison > 0) {
	address = textList[j];
	textList[j] = textList[j+1];
	textList[j+1] = address;
      }
    }
    cntIn--;
  }
  

  FIg_reset( form, gadget );
  /* put the stuff back */
  for(row = 0;row < textListCnt;row++) {
    vdfrm$SetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = textList[row]);
  }

  /* notify the count of rows */
  FIfld_set_list_num_rows(form,gadget,0,textListCnt);
  
  /* set the selection */
  if(flag == 1) FIg_set_text(form,gadget,textList[0]);
  if(flag == 0)  FIg_set_text(form,gadget,name);
  if(flag == -1) FIg_set_text(form,gadget,"");
  // FIg_enable(form,gadget);
  

  retFlag = 1;
wrapup:

  if(textListCnt > 0) _LOOPFREE( textList,textListCnt );
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * add item to a text box (not Unique)
 * checks to see if the item is in the box before 
 * adding it to the list
 * checks for special case of a "" blank item 
 * alphabetic Highest to Least 
 *
 ********************************************/
IGRint VDtvwFormMakeTextItemsADn(Form     form,
				 IGRint   gadget,
				 IGRint   flag,
				 IGRint   addItem)
{
  VDASSERT_FN("VDtvwFormMakeTextItemsADn");
  IGRint  retFlag = 0;
  IGRint  row,rows,i,j,cntOut,cntIn,comparison;
  IGRchar **textList;
  IGRint  textListCnt = 0;
  IGRchar listText[128],name[128],*address;

   
  
    /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  VDASSERTW(form);
  if(gadget < 11) goto wrapup;

  /* get the textbox viewed text */
  FIg_get_text(form,gadget,name);
  
  /* get the number of rows in the textbox list */
  FIfld_get_list_num_rows( form, gadget,0, &rows );
    
  if(rows < 1) goto wrapup;
  for(row = 0;row < rows;row++) {
    vdfrm$GetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = listText);
    VDtvwAddStrList(listText,&textList,&textListCnt); 
  }

  if(addItem == 1) {
    VDtvwAddStrList(name,&textList,&textListCnt); 
  }
  if(addItem == -1) {
    if(strcmp(name,"")) VDtvwAddStrList(name,&textList,&textListCnt); 
  }
  
  
  cntOut = textListCnt;
  cntOut--;
  cntIn = cntOut;

  /* do the sort */
  for(i = 0;i < cntOut;i++) {
    for(j = 0;j < cntIn;j++) {
      comparison = strcmp(textList[j],textList[j+1]);
      if(comparison < 0) {
	address = textList[j];
	textList[j] = textList[j+1];
	textList[j+1] = address;
      }
    }
    cntIn--;
  }
  
  FIg_reset( form, gadget );
  /* put the stuff back */
  for(row = 0;row < textListCnt;row++) {
    vdfrm$SetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = textList[row]);
  }

  /* notify the count of rows */
  FIfld_set_list_num_rows(form,gadget,0,textListCnt);
  
  /* set the selection */
  if(flag == 1) FIg_set_text(form,gadget,textList[0]);
  if(flag == 0)  FIg_set_text(form,gadget,name);
  if(flag == -1) FIg_set_text(form,gadget,"");
  //FIg_enable(form,gadget);
  

  retFlag = 1;
wrapup:

  if(textListCnt > 0) _LOOPFREE( textList,textListCnt );
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/********************************************
 *
 * add item to a text box (Unique)
 * checks to see if the item is in the box before 
 * adding it to the list
 * checks for special case of a "" blank item 
 * alphabetic Highest to Least 
 *
 ********************************************/
IGRint VDtvwFormMakeTextItemsUniqueADn(Form     form,
				       IGRint   gadget,
				       IGRint   flag,
				       IGRint   addItem)
{
  VDASSERT_FN("VDtvwFormMakeTextItemsUniqueADn");
  IGRint  retFlag = 0;
  IGRint  row,rows,i,j,cntOut,cntIn,comparison;
  IGRchar **textList;
  IGRint  textListCnt = 0;
  IGRchar listText[128],name[128],*address;

   
  
    /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  VDASSERTW(form);
  if(gadget < 11) goto wrapup;

  /* get the textbox viewed text */
  FIg_get_text(form,gadget,name);
  
  /* get the number of rows in the textbox list */
  FIfld_get_list_num_rows( form, gadget,0, &rows );
    
  if(rows < 1) goto wrapup;
  for(row = 0;row < rows;row++) {
    vdfrm$GetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = listText);
    VDtvwAddStrListUnique(listText,&textList,&textListCnt); 
  }

  if(addItem == 1) {
    VDtvwAddStrListUnique(name,&textList,&textListCnt); 
  }
  if(addItem == -1) {
    if(strcmp(name,"")) VDtvwAddStrListUnique(name,&textList,&textListCnt); 
  }
  
  
  cntOut = textListCnt;
  cntOut--;
  cntIn = cntOut;

  /* do the sort */
  for(i = 0;i < cntOut;i++) {
    for(j = 0;j < cntIn;j++) {
      comparison = strcmp(textList[j],textList[j+1]);
      if(comparison < 0) {
	address = textList[j];
	textList[j] = textList[j+1];
	textList[j+1] = address;
      }
    }
    cntIn--;
  }
  
  FIg_reset( form, gadget );
  /* put the stuff back */
  for(row = 0;row < textListCnt;row++) {
    vdfrm$SetListText( form   = form,
                       gadget = gadget,
                       row    = row,
                       txt    = textList[row]);
  }

  /* notify the count of rows */
  FIfld_set_list_num_rows(form,gadget,0,textListCnt);
  
  /* set the selection */
  if(flag == 1) FIg_set_text(form,gadget,textList[0]);
  if(flag == 0)  FIg_set_text(form,gadget,name);
  if(flag == -1) FIg_set_text(form,gadget,"");
  //FIg_enable(form,gadget);
  

  retFlag = 1;
wrapup:

  if(textListCnt > 0) _LOOPFREE( textList,textListCnt );
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Add a string to a list of text unique only
 * *NOTICE* memory is allocated *NOTICE* 
 * limited to 65,535 strings in the list (int)
 * You don't need to have a list to start with
 * this will initiate the list if you have
 * nothing in the list, just start with
 * *ListCnt = 0;
 *
 ********************************************/
IGRint VDtvwAddStrListUnique(IGRchar   *item,
			     IGRchar ***List,
			     IGRint    *ListCnt)
{
  VDASSERT_FN("VDtvwAddStrListUnique");
  IGRint retFlag = 0;
  IGRint  i,found,count,sizeOf = 0;
  IGRchar **localList,buf[128];
  
   
  
  /* say hi */
  if (traceFlag) {
    printf("\n>>> %s %s [%s]\n",ffn(),fn,item);
    printf(">>> ListCnt [%d]\n",*ListCnt);
  }
  /* inits */ 
  i = found = 0;

  /* checks */
  VDASSERTW(item);
  
  if(*ListCnt < 0) {
    *ListCnt = 0;
  }
  
  /* check to see if the item is in the list */
  if(VDtvwIsItemInList(item,*List,*ListCnt)) goto wrapup;

  /* allocate the ** pointers */
  count = *ListCnt;
  count++;

   /* allocate the memory for the * pointer */
  if( (localList = _MALLOC( count, IGRchar *  )) == NULL ) {
    printf("\nERROR: unable to allocate memory for *localList\n\n");
    goto wrapup;
  } 

  /* move in the array data */
  for(i = 0;i < *ListCnt;i++) {
    /* allocate the memory */
    sizeOf = (strlen((*List)[i]) + 1);
    if(( localList[i] = _MALLOC( sizeOf, IGRchar  )) == NULL)  {
      printf("\nERROR: unable to allocate memory for (*localList)[i]\n\n");
      goto wrapup;
    }

    /* copy the data over */
    strcpy(localList[i],(*List)[i]);
  }

  /* allocate the final bit of memory */
  if( !( localList[i] = _MALLOC( (strlen(item) + 1), IGRchar  )))  {
    printf("\nERROR: unable to allocate memory for (*localList)[i]\n\n");
    goto wrapup;
  }

  /* copy the item into the list */
  strcpy(localList[i],item);

  /* clear out the old list */
  if(*ListCnt > 0) _LOOPFREE ( *List,*ListCnt );

  /* move over the new list to the outgoing stuff */
  *ListCnt = count;
  *List = localList;

  retFlag = 1;
 wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Add a string to a list of text (NOT UNIQUE)
 * *NOTICE* memory is allocated *NOTICE* 
 * limited to 65,535 strings in the list (int)
 * You don't need to have a list to start with
 * this will initiate the list if you have
 * nothing in the list, just start with
 * *ListCnt = 0;
 *
 ********************************************/
IGRint VDtvwAddStrList(IGRchar   *item,
		       IGRchar ***List,
		       IGRint    *ListCnt)
{
  VDASSERT_FN("VDtvwAddStrList");
  IGRint retFlag = 0;
  IGRint  i,found,count,sizeOf = 0;
  IGRchar **localList,buf[128];
  
   
  
  /* say hi */
  if (traceFlag) {
    printf("\n>>> %s %s [%s]\n",ffn(),fn,item);
    printf(">>> ListCnt [%d]\n",*ListCnt);
  }
  /* inits */ 
  i = found = 0;

  /* checks */
  VDASSERTW(item);
  
  if(*ListCnt < 0) {
    *ListCnt = 0;
  }
  

  /* allocate the ** pointers */
  count = *ListCnt;
  count++;

   /* allocate the memory for the * pointer */
  if( (localList = _MALLOC( count, IGRchar *  )) == NULL ) {
    printf("\nERROR: unable to allocate memory for *localList\n\n");
    goto wrapup;
  } 

  /* move in the array data */
  for(i = 0;i < *ListCnt;i++) {
    /* allocate the memory */
    sizeOf = (strlen((*List)[i]) + 1);
    if(( localList[i] = _MALLOC( sizeOf, IGRchar  )) == NULL)  {
      printf("\nERROR: unable to allocate memory for (*localList)[i]\n\n");
      goto wrapup;
    }

    /* copy the data over */
    strcpy(localList[i],(*List)[i]);
  }

  /* allocate the final bit of memory */
  if( !( localList[i] = _MALLOC( (strlen(item) + 1), IGRchar  )))  {
    printf("\nERROR: unable to allocate memory for (*localList)[i]\n\n");
    goto wrapup;
  }

  /* copy the item into the list */
  strcpy(localList[i],item);

  /* clear out the old list */
  if(*ListCnt > 0) _LOOPFREE ( *List,*ListCnt );

  /* move over the new list to the outgoing stuff */
  *ListCnt = count;
  *List = localList;

  retFlag = 1;
 wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Is Item in the list (Rule check)
 *
 ********************************************/
IGRint VDtvwIsItemInList(IGRchar  *item,
			 IGRchar **List,
			 IGRint    ListCnt)
{
  VDASSERT_FN("VDtvwIsItemInList");
  IGRint retFlag = 0;
  IGRint  i;

  /* say hi */
  if (traceFlag) {
    printf("\n\n>>> %s %s\n",ffn(),fn);
    printf("item [%s] ListCnt = [%d]\n",item,ListCnt);
  }

  for(i = 0;i < ListCnt;i++) {
    if(!strcmp(item,List[i])) {
      retFlag = 1;
      break;
    }
  }

wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n\n",ffn(),fn,retFlag);
  return retFlag;
}
/*****************************************************
 *
 * fix the problem with scroll bars that don't update
 *
 *****************************************************/
IGRstat VDtrFixScrollBar(char *form,IGRint gadget)
{
  VDASSERT_FN("VDtrGet");
  IGRint   rows = 0;
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  if(gadget < 11) goto wrapup;
  VDASSERTW(form);

  FIfld_get_num_rows(form, gadget, &rows);
  FIfld_set_num_rows(form, gadget, rows);
  
  retFlag = 1;

wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Generic File opener give 
 * Returns file pointer
 * Example: of $VDS/config/drawing/expr_table
 * Send : fileName  -- "expr_table
 * Send : partPath  -- "/config/drawing/"
 *
 *****************************************************/

FILE *VDtrOpenFileByName(IGRchar *fileName, IGRchar *partPath,IGRchar *openTo)
{
  VDASSERT_FN("VDtrOpenFileByName");

  FILE     *file;
  IGRchar  absPathName[DI_PATH_MAX];
  IGRchar  openMethod[128];
  IGRlong  msg;
  IGRchar  status;
  IGRint   retFlag = 0;
  
   
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s \n",ffn(),fn); 
  }
  
  // init
  file = NULL;
  msg = 0;
  status = '\0';

  // args check
  VDASSERTW(fileName);
  VDASSERTW(partPath);
  if(openTo[0] == '\0') {
    strcpy(openMethod,"r");
  } else {
    strcpy(openMethod,openTo);
  }
  
  if(traceFlag) printf("openMethod [%s]\n",openMethod);
  
  
  

  // get the path of the file
  status = vd$file_path(   msg                       = &msg,
                           fileToFind                = fileName,
                           dirToSearchFirst          = ".",
                           dirInProdPathToSearchThen = partPath,
                           absPathName               = absPathName );
      
  if(traceFlag) printf("absPathName is [%s] \nfileName[%s] openMethod[%s]\n",
		       absPathName,fileName,openMethod);
  
  // open the file 
  file = fopen(absPathName,openMethod);

  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s [%d]\n",ffn(),fn,retFlag);
  }
  
  return file;
}
/*****************************************************
 *
 *  Taking a set of allocated fileLines and a
 *  lineCnt together with a fileName and a partPath
 *  the latter which can be most anything
 *  write the entire content of a file over existing
 *  file content (THIS IS NOT AN APPEND OPERATION)
 *  the file here should have null terminated strings if
 *  it is intended that the data should occur on seperate
 *  lines in the file.  Otherwise:  The data will just
 *  fill in one line endlessly!
 *
 *****************************************************/

IGRstat VDio_write_anyFile(IGRchar  *fileName, 
			  IGRchar   *partPath, 
			  IGRchar  **fileLines,
			  IGRint    *lineCnt)
{
  VDASSERT_FN("VDio_write_anyFIle");
  IGRstat  retFlag = 0;
  FILE     *file;
  IGRint   cnt = 0, i;
  IGRchar  buf[1028];
  
   
  
  
  /* say hi */
  if (traceFlag) {
    printf("\n>>> %s %s\n",ffn(),fn); 
  }
  /* args checks */
  VDASSERTW(partPath);
  VDASSERTW(fileName);
  VDASSERTW(lineCnt);

  /* inits */
  // *fileLines = NULL;
  file = NULL;

  /* args */
  if(*lineCnt < 1) goto wrapup;
  cnt = *lineCnt;

  /* open the file and check if it exists */
  file = VDtrOpenFileByName(fileName, partPath,"w");
  if(file == NULL) {
    if(traceFlag) printf("\nERROR: unable to open file[%s]\n\n",fileName);
    goto wrapup;
  }
  if(traceFlag) printf("\n OPENED: write fileName[%s] \n",fileName);
  
  /* write in each line of the strings */
  for(i = 0;i < cnt;i++) {
    /* we now have an open file */
    fputs(fileLines[i],file);
  }

  fclose(file);
  
  retFlag = 1;
  
wrapup:
  // say bye 

  
  if (traceFlag) {
    printf("<<< %s %s %d\n\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Read the file and return 
 * ***fileLines
 * *lineCnt
 * input fileName and partPath
 * ALLOCATES MEMORY! 
 *****************************************************/

IGRstat VDio_read_anyFile(IGRchar   *fileName, 
			  IGRchar   *partPath, 
			  IGRchar ***fileLines,
			  IGRint    *lineCnt)
{
  VDASSERT_FN("VDio_read_anyFIle");
  IGRstat  retFlag = 0;
  FILE     *file;
  IGRchar  buf[1024],*ptr;
  IGRint   cnt = 0, i;
  
   
  
  /* say hi */
  if (traceFlag) {
    printf("/n>>> %s %s\n",ffn(),fn); 
  }
  /* args checks */
  VDASSERTW(partPath);
  VDASSERTW(fileName);
  VDASSERTW(lineCnt);



  /* inits */
  // *fileLines = NULL;
  *lineCnt = 0;
  file = NULL;

  /* open the file and check if it exists */
  file = VDtrOpenFileByName(fileName, partPath,"r");
  if(file == NULL) {
    if(traceFlag) printf("\nERROR: unable to open file[%s]\n\n",fileName);
    goto wrapup;
  }
  if(traceFlag) printf("\nSUCCESS: opened file[%s]\n\n",fileName);
  cnt = 0;
  while(fgets(buf,sizeof(buf),file)) {
	cnt++;
  }

  if( cnt < 1 ) goto wrapup;
  
  if( (*fileLines = _MALLOC( cnt, IGRchar *  )) == NULL ) goto wrapup;

  /* Cycle through the records */
  cnt = 0;
  rewind(file);
  while(fgets(buf,sizeof(buf),file)) {
    if( !( (*fileLines)[cnt] = _MALLOC( (sizeof(buf) + 1), IGRchar  )))  {
      printf("\nERROR: unable to allocate memory for [%s]\n\n",fileName);
      goto wrapup;
    }
    strcpy((*fileLines)[cnt],buf);
    cnt++;
  }
  
  *lineCnt = cnt;
  fclose(file);
  
  retFlag = 1;
  
wrapup:
  // say bye 

  
  if (traceFlag) {
    printf("<<< %s %s %d\n\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Write the file with a buffer of data 
 *
 *****************************************************/

IGRstat VDio_write_anyFileToBuf(IGRchar *path,IGRchar **data)
{
  VDASSERT_FN("VDio_write_anyFileToBuf");
  IGRstat  retFlag = 0;
  IGRchar  buf[1024];
  IGRint   sts = 0,i = 0;
  IGRchar  **fileLines;
  IGRint   lineCnt = 0,byteCnt = 0;
  
   
  
  
  /* say hi */
  if (traceFlag) {
    printf("/n>>> %s %s\n",ffn(),fn); 
  }
  /* args checks */
  VDASSERTW(path);

  /* inits */
  buf[0] = '\0';

  /* read the file and get the line data */

  sts = VDio_read_anyFile(path, 
			  buf, 
			  &fileLines,
			  &lineCnt);

  if(!(sts & 1)) goto wrapup;
  if(lineCnt < 1) goto wrapup;

  /* get the number of bytes to allocate */
  for(i = 0;i < lineCnt;i++) {
    byteCnt += sizeof(fileLines[i]);
  }

  /* no data lets go home (being careful) */
  if(byteCnt < 1) {
    goto wrapup;
  }  
  
  /* allocate the memory */
  if(!( *data = _MALLOC( byteCnt, IGRchar ))) {
    printf("Unable to allocate memory for file buffer (data)\n");
    goto wrapup;
  }
  /* clear things up  to start with */
  buf[0] = '\0';
  strcpy( *data,buf);
  /* fix it up */
  for(i = 0;i < lineCnt;i++) {
    buf[0] = '\0';
    strcpy(buf,fileLines[i]);
    //printf("### buf = [%s]\n",buf);
    
    strcat( *data,buf);
  }
  retFlag = 1;
  
wrapup:
  // say bye 
  if(lineCnt) _LOOPFREE( fileLines, lineCnt );
  if (traceFlag) {
    printf("<<< %s %s %d\n\n",ffn(),fn,retFlag);
  }
  return retFlag;
}




/*****************************************************
 *
 * Open/Create a file by name
 * append the incomming buffer to it and close the 
 * file flushing the buffer
 * writes only to the current directory
 *
 *****************************************************/
IGRstat VDio_append_named_file(IGRchar *fileName,IGRchar *fileData)
{
  VDASSERT_FN("VDio_append_named_file");
  IGRstat retFlag = 0;
  FILE    *file;
  IGRchar buf[128];

   
  
  // say hi
  if (traceFlag) {
    printf("/n>>> %s %s\n",ffn(),fn); 
  }

  // args checks
  VDASSERTW(fileName);
  VDASSERTW(fileData);
  if(!strcmp(fileName,"")) goto wrapup;
  if(!strcmp(fileData,"")) goto wrapup;

  /* inits */
  file = NULL;
  
  /* open the file append mode only*/
  file = fopen(fileName,"a");
  if(file == NULL) {
    printf("File: %s could not be opened\n",fileName);
    goto wrapup;
  } else {
    if(traceFlag) printf("append opened filName[%s]\n",fileName);
  }
  
  
  /* we now have an open file */
  fputs(fileData,file);
  
  /* close up the file and go home */
  fclose(file);
  

wrapup:
  return retFlag;
}



/*****************************************************
 *
 * Read the file and return fileData
 * ALLOCATES MEMORY! buDat->filebuf[x]
 *****************************************************/

IGRstat VDio_read_file(VDioBufDat *bufDat)
{
  VDASSERT_FN("VDio_read_file");
  IGRstat  retFlag = 0;
  FILE     *file;
  IGRchar  buf[128],*ptr;
  IGRint   i;
  
   
  
  // say hi
  if (traceFlag) {
    printf("/n>>> %s %s\n",ffn(),fn); 
  }
  // args checks
  VDASSERTW(bufDat);

  // inits
  bufDat->filebuf = NULL;
  bufDat->lines == 0;
  file = NULL;

  // open the file and check if it exists
  file = VDtrOpenFileByName(bufDat->filename, bufDat->partpath,"r");
  if(file == NULL) {
    if(traceFlag) printf("\nERROR: unable to open file[%s]\n\n",bufDat->filename);
    goto wrapup;
  }

 // Cycle through the records and count records
  while(fgets(buf,sizeof(buf),file)) {
    bufDat->lines = bufDat->lines + 1;
  }
  
  rewind(file);
  // allocate the memory go home if it cannot be secured
  if( !( bufDat->filebuf  = _MALLOC( (VDTR_BUF_SIZE * (bufDat->lines)), IGRchar  )))  {
    printf("\nERROR: unable to allocate memory for [%s]\n\n",bufDat->filename);
    goto wrapup;
  }
  bufDat->filebuf[0] = '\0';
  ptr = bufDat->filebuf;
  
    // Cycle through and get the records 
  for(i = 0;i < bufDat->lines;i++) {
    fgets(buf,sizeof(buf),file);
    strcpy(ptr,buf);
    ptr += VDTR_BUF_SIZE;
  }
  fclose(file);
  
  retFlag = 1;
  
wrapup:
  // say bye 

  
  if (traceFlag) {
    printf("<<< %s %s %d\n\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/********************************************
 *
 * wildCard Text Check engine
 * will accept the positional '#' wildcard or the 
 * '*' full wildCard.
 * allows spaces to be checked as well
 * does not require a contiguious space free string
 *
 ********************************************/

IGRint VDtvwIsWildCardMatchItem(IGRchar *wildCard,IGRchar *item)
{
  VDASSERT_FN("VDtvwIsWildCardMatchItem");
  IGRint retFlag = 0;
  IGRchar *p,*q,*r,*s,*t;
  IGRint  lenWildCard,lenItem,spaceCnt = 0;
  IGRint  i,pCnt = 0;
  IGRchar **strList;
  IGRint  strListCnt = 0;
  IGRchar buf[1028];
  IGRchar tmp[1028];
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s wildCard [%s] item [%s]\n",ffn(),fn,wildCard,item);

  /* args check stuff */
  if(strlen(wildCard) < 1) goto wrapup;
 
  /* special case */ 
  if(!strcmp(wildCard,"*")) {
    retFlag = 1;
    goto wrapup;
  }
  /* clip up the wild card strings */
  VDtvwClipWildCardStr(wildCard,&strList,&strListCnt);

  if(strListCnt < 1) {
    goto wrapup;
  }
  if(strListCnt == 1) {
    if(!strcmp(strList[i],"*")) {
      retFlag = 1;
    } 
    if(!strcmp(strList[i],item)) {
      retFlag = 1;
    }
    goto wrapup;
  }

  /* are they in here and in order */
  p = item;
  for(i = 0;i < strListCnt;i++) {
    if(*p == '\0') goto wrapup;
    strcpy(buf,strList[i]);
    if(buf[0] != '*') {
      r = strstr(p,buf);
      /* wrapup the missed ones */
      if(r == NULL) {
	goto wrapup;
      }
      /* if it is the first item to check */
      if(i == 0) {
	if(p != r) {
	  goto wrapup;
	}
      }
      
	/* if it is the last item to check */
      if(i == strListCnt -1) {
	lenWildCard = strlen(buf);
	lenItem = strlen(item);
	p = p + (lenItem -lenWildCard) -1;
	r = strstr(p,buf);
	if(r == NULL) {
	  goto wrapup;
	}
	retFlag = 1;
	goto wrapup;
      }
      p = r;
      p = p + strlen(buf);
    }
    
    /* it is '*' */
    else {
      /* if it is the last one it is ok */
      if(i == strListCnt -1) {
	retFlag = 1;
	if(traceFlag) printf("%s: atline[%d]\n",fn,__LINE__);
	goto wrapup;
      }
    } 
  }


wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 *  MergeNode to a nodeList UNIQUE 
 *
 ********************************************/
IGRint VDtvwAddNodeToListUnique(TGRid  *addNode,
				TGRid  **nodeList,
				IGRint *nodeListCnt)
{
  VDASSERT_FN("VDtvwAddNodeToListUnque");
  IGRint retFlag = 0;
  IGRint   i,j,addCnt,totalCnt,found;

  traceFlag = 0;

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
 
  /* args */
  VDASSERTW(nodeList);

  if(addNode->objid == NULL_OBJID) goto wrapup;

  if(traceFlag) printf("addNode[%d][%d]\n",addNode->osnum,addNode->objid);
  
  /* lock out counts below zero */
  if(*nodeListCnt < 0) {

    *nodeListCnt = 0;
  }
  if(traceFlag) printf("\t\t%s %s: Location #3\n",ffn(),fn);
  
  if(VDtvwIsNodeInList(addNode,
		       *nodeList,
		       *nodeListCnt)) goto wrapup;

  if(traceFlag) printf("\t\t%s %s: Location #4\n",ffn(),fn);
  /* allocate a local list */
  if(traceFlag) printf("test #1\n");
  if(*nodeListCnt == 0) {
    if(traceFlag) printf("test #2 [%d] \n",((*nodeListCnt) +1) );
    *nodeList = _MALLOC( ((*nodeListCnt) +1) , TGRid  );
    
    if(*nodeList == NULL) {
      goto wrapup;
    }
  } else {
    if(traceFlag) printf("test #3 [%d]\n",((*nodeListCnt) +1));
    *nodeList = _REALLOC( *nodeList,((*nodeListCnt) +1) , TGRid  );
    if(*nodeList == NULL) {
      goto wrapup;
    }
  }
  (*nodeList)[*nodeListCnt] = *addNode;
  *nodeListCnt += 1;
 
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/********************************************
 *
 * Is the string actually a number?
 * only input is the testStr
 * a return value of zero indicates not a number
 * a return value not zero indicates a number was found
 * a return value -1 indicates a double
 * a return value  1 indicates an integer.
 * accepts signed or unsigned numbers and 
 * text
 *
 ********************************************/
IGRint VDtvwIsStrNumber(IGRchar *testStr)
{
  VDASSERT_FN("VDtvwIsStrNumber");
  IGRint retFlag = 0;
  IGRchar *p,*q;
  IGRint  i = 0,strLen = 0,decPoint = 0,start = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  p = testStr;

  /* make sure we have a string to use */
  strLen = strlen(testStr);
  if(strLen < 1) goto wrapup;

  /* is it signed if so advance the start */
  if((*p == '-') || (*p == '+')) {
    p++;
    start++;
  }

  /* loop through the string and check */
  for(i = start;i < strLen;i++) {
    if(*p == '.') {
      decPoint++;
      if(decPoint > 1) goto wrapup;
    } else if(!((*p >= '0') && (*p <= '9'))) goto wrapup;
    p++;
  }

  retFlag = 1;
  if(decPoint == 1) retFlag = -1;
  
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * remove node from list (for use with Unique lists)
 *
 ********************************************/
IGRint VDtvwRemoveNodeFromList(TGRid    *nodeID,
			       TGRid   **List,
			       IGRint   *ListCnt)  
{
  VDASSERT_FN("VDtvwRemoveNodeFromList");
  IGRint retFlag = 0;
  IGRint i,cnt;
  TGRid   localID,*localList;
  IGRint  localCnt;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

 /* checks */
  VDASSERTW(nodeID);
  VDASSERTW(List);  

  if(*ListCnt < 1) {
    *ListCnt = 0;
    goto wrapup;
  }
  

  if(nodeID->objid == NULL_OBJID) goto wrapup;
  /* is it in the list */
  if(!(VDtvwIsNodeInList(nodeID,
			 *List,
			 *ListCnt))) goto wrapup;
  /* allocate a local list */
  localList = NULL;
  if((*ListCnt -1) < 1) {
    _FREE( *List );
    *ListCnt = 0;
    goto wrapup;
  }

  localList = _MALLOC(((*ListCnt) -1) , TGRid );
  if(localList == NULL) goto wrapup;

  cnt = localCnt = 0;
  for(i = 0;i < *ListCnt;i++) {
    localID = (*List)[i];
    if(!((nodeID->osnum == localID.osnum) && (nodeID->objid == localID.objid))) {
      localList[cnt] = (*List)[i];
      cnt++;
    }   
  }

  /* clean up the node list */
  if(*ListCnt > 0) _FREE( *List );
  
  *ListCnt = cnt;
  *List = localList;

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Is Node in the list (Rule check)
 *
 ********************************************/
IGRint VDtvwIsNodeInList(TGRid    *nodeID,
			 TGRid    *List,
			 IGRint    ListCnt)
{
  VDASSERT_FN("VDtvwIsNodeInList");
  IGRint retFlag = 0;

  IGRint  i;

  traceFlag = 0;
  /*
  printf("\n Entered the function ListCnt %d \n",ListCnt);
  printf("\n NodeID [%d,%d] \n",nodeID->objid,nodeID->osnum);
  
  for(i=0; i<ListCnt; i++)
  {
    printf("\n List[%d] = [ %d,%d] \n",i,List[i].objid,List[i].osnum);    
  }
  */
  /* say hi */
  if (traceFlag) {
    printf("\n\n>>> %s %s\n",ffn(),fn);
    if(nodeID) printf("nodeID[%d][%d]\n",nodeID->osnum,nodeID->objid);
    printf("ListCnt = [%d]\n",ListCnt);
  }
  if(ListCnt < 1) goto wrapup;
  
 /* checks */
  VDASSERTW(nodeID);
  VDASSERTW(List);
 if(nodeID->objid == NULL_OBJID) goto wrapup;

  
  if(traceFlag) printf("loc #1\n");
  
 /* checks */
    if(traceFlag) printf("loc #2\n");
  /* fix any funny stuff */
  if(ListCnt < 0) {
    goto wrapup;
  }
    if(traceFlag) printf("loc #3\n");
  for(i = 0;i < ListCnt;i++) {
  if(traceFlag) printf("loc #4\n");
    if((List[i].osnum == nodeID->osnum) && (List[i].objid == nodeID->objid)) {

  if(traceFlag) printf("loc #5\n");
      retFlag = 1;
      break;
    }
  }
  if(traceFlag) printf("loc #6\n");
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * subtract a nodeList from a nodeList (Always Unique)
 *
 ********************************************/
IGRint VDtvwSubNodeListsUnique(TGRid **subIDs,
			       IGRint *subIDsCnt,
			       TGRid **listIDs,
			       IGRint *listIDsCnt)
{
  VDASSERT_FN("VDtvwSubNodeListsUnique");
  IGRint retFlag = 0;
  IGRint i;
  TGRid  nodeID;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  /* args */
  VDASSERTW(subIDs);
  VDASSERTW(listIDs);

  /* case of no base list items to subtract */
  if(*listIDsCnt < 1) {
    *listIDsCnt = 0;
    retFlag = 1;
    goto wrapup;
  }

  if(*subIDsCnt < 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  
  /* use the remove routine now */
  for(i = 0;i < *subIDsCnt;i++) {
    nodeID.osnum = (*subIDs)[i].osnum;
    nodeID.objid = (*subIDs)[i].objid;
    VDtvwRemoveNodeFromList(&nodeID,
			    listIDs,
			    listIDsCnt);
    if(*listIDsCnt < 1) {
      retFlag = 1;
      break;
    }
  }
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}






/********************************************
 *
 * Add nodeList to nodeList (Unique tested)
 *
 ********************************************/
IGRint VDtvwAddNodeListsUnique(TGRid **addIDs,
			       IGRint *addIDsCnt,
			       TGRid **listIDs,
			       IGRint *listIDsCnt)
{
  VDASSERT_FN("VDtvwAddNodeListsUnique");
  IGRint retFlag = 0;
  IGRint i;
  TGRid  nodeID;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  /* args */
  VDASSERTW(addIDs);
  VDASSERTW(listIDs);
  if(*addIDsCnt < 1) goto wrapup;
  
  /* case of no base list items */
  if(*listIDsCnt < 1) {
    *listIDsCnt = *addIDsCnt;
    listIDs = addIDs;
    retFlag = 1;
    goto wrapup;
  }
  
  /* use the adding routine now */
  for(i = 0;i < *addIDsCnt;i++) {
    nodeID.osnum = (*addIDs)[i].osnum;
    nodeID.objid = (*addIDs)[i].objid;
    VDtvwAddNodeToListUnique(&nodeID,
			     listIDs,
			     listIDsCnt);
  }

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/************************************************************
 *
 * open a file in the local directory and write a first blank
 * line ended with a '\n'
 *
 ************************************************************/
IGRint VDfileCreateLocalNewFile(IGRchar *fileName)
{  
  VDASSERT_FN("VDfileCreateLocalNewFile");
  IGRint retFlag = 0;
  
  
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  /*args */
  if(!strcmp(fileName,"")) goto wrapup;

  retFlag = VDio_append_named_file(fileName,"\n");
  
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/***************************************************************
 *
 * This is a check to see if an item is the same as 
 * a test item.  
 * item is the string you want to test
 * check is the string you are testing it with
 * this does a simple string compare (if match return 1) 
 * this looks to see if the check contains a wild_card
 * If it does not it goes home (failure to match, return 0)
 * If it does it does a wild_card check
 * This should not be used against file names as they are complex
 * in relationship to this.
 * 
 *
 ***************************************************************/
IGRstat VDfileIsItemSameAs(IGRchar *item,IGRchar *check) 
{
  VDASSERT_FN("VDfileIsItemSameAs");
  IGRint retFlag = 0;
  IGRchar *p,*q;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* check the arguments */
  VDASSERTW(item);
  VDASSERTW(check);
 
  if(traceFlag) printf("item[%s] check[%s]\n",item,check);
  /* do a simple string check */
  if(!strcmp(item,check)) {
    if(traceFlag) printf("No Wildcard check\n");
    retFlag = 1;
    goto wrapup;
  }

  /* check for wildcard '*' */

  p = strchr(check,'*');
 
  if(p == NULL) {
    if(traceFlag) printf("No Wildcard check\n");
    goto wrapup;
  }
  
  
  /* we found a wildcard of some type */
  retFlag = VDtvwIsWildCardMatchItem(check,item);
 
  
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/**************************************************************
 *
 * Internally called routine do not call externally 
 * Actually fetches the node lists per specification
 * Inputs are cleaned up by this point
 * Cannot be called unless already cleaned up input!
 *
 **************************************************************/
IGRstat VDfileGetNodeListChild(TGRid   *nodeID,
			      IGRint   child,
			      TGRid  **nodeList,
			      IGRint  *nodeListCnt)
{
  VDASSERT_FN("VDfileGetNodeListChild");
  IGRint  retFlag = 0;
  TGRid   childID,listID;
  IGRint i = 0;
  IGRint j = 0;

  // say hi
  if (traceFlag) {
    printf("\n\n>>> %s %s nodeListCnt[%d] child[%d] nodeID[%d][%d]\n",
	   ffn(),fn,*nodeListCnt,child,nodeID->osnum,nodeID->objid); 
  }

  /* get the first level kids no matter what */
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++) {
    if((childID.objid != NULL_OBJID)  && (childID.osnum == nodeID->osnum)) {
      VDtvwAddNodeToListUnique(&childID,nodeList,nodeListCnt);
      /* fetch all the kids here */
      if(child == 1) {
	VDfileGetNodeListChild(&childID,child,nodeList,nodeListCnt);
      }
    }
  }  
   
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d [%d]\n",ffn(),fn,retFlag,*nodeListCnt);
  }
  return retFlag;
}


/*****************************************************
 *
 * Generic node fetching function and it does not 
 * depend on all the old stuff
 * extreme self protection 
 * and a lot of powerful features
 * including wild cards! 
 * node  may be any nodeID from the top of the tree down to the 
 * bottom of the tree.
 *
 *  ***** optional inputs ******
 * type  is optional and may be NULL or a wild card or
 *       it may be a specific nodeType.  The process will
 *       check to see if it contains a wild card or is NULL
 * name  is optional and may be NULL or a wild card or
 *       it may be a specific nodeName.  The process will
 *       check to see if it contains a wild card or is NULL
 * child May be NULL if so defaults to (0) which limits the search 
 *       to only the direct children of the node.  
 *       if (1) all children are selected
 * flag  May be NULL if so it defaluts (0) which says do not include the 
 *       nodeID (treeID) or (topID) in the list.
 *       if (1) says include the nodeID ...
 * invt  May be NULL if so it defaults to (1) which says chose these items as 
 *       they are wanted.
 *       if (0) this means to chose those not equal to the condition.
 *
 *   **** outputs *****  REQUIRED *****
 * nodeList is the list of nodes returned.  It is entirely
 *          freed and cleaned on start.
 * nodeListCnt is the count of nodes and is always started at zero.  
 * 
 * ************** wrapper for internally used function ************
 *                call this if you  are wanting a list    
 *
 *****************************************************/
IGRstat VDfileGetNodeList(TGRid   *nodeID,
			  IGRchar *type, 
			  IGRchar *name,
			  IGRint  *child,
			  IGRint  *flag,
			  IGRint  *invt,
			  TGRid   **nodeList,
			  IGRint  *nodeListCnt)
{
  VDASSERT_FN("VDfileGetNodeList");
  IGRstat          retFlag = 0;
  IGRint           lChild = 0;
  IGRint           lFlag = 0;
  IGRint           lInvt = 1;
  TGRid            *childList = NULL;
  TGRid            *localList = NULL;
  IGRint           childListCnt = 0;
  IGRint           localListCnt = 0;
  IGRint           sendOut = 0;
  IGRint           nameOK = 0;
  IGRint           typeOK = 0;
  IGRint           i = 0;
  TGRid            childID,setID,mgrID,treeID;
  IGRchar          nodeType[128];
  IGRchar          nodeName[128];

  // say hi
  if (traceFlag) {
    printf("\n\n>>> %s %s\n",ffn(),fn); 
  }

  if(traceFlag) {
    if(nodeID) printf("nodeID[%d][%d]\n",nodeID->osnum,nodeID->objid);
    if(type) printf("type[%s]\n",type);
    if(name) printf("name[%s]\n",name);
  }

  /* inits */
  nodeName[0] = '\0';
  nodeType[0] = '\0';

  // argument checks
  VDASSERTW(nodeList);
  VDASSERTW(nodeID);
  if(*nodeListCnt > 0) _FREE( *nodeList );
  *nodeListCnt = 0;
  if(nodeID->objid == NULL_OBJID) goto wrapup;


  /* check the optional inputs and fix up the defaults */
  if(child) {
    if(*child == 1) lChild = 1;
  }
  if(flag) {
    if(*flag == 1) lFlag = 1;
  }
  if(invt) {
    if(*invt == 0) lInvt = 0;
  }
  /* if we start with the nodeID */
  childListCnt = 0;
  /* fetch the children */
  VDfileGetNodeListChild(nodeID,
			 lChild,
			 &localList,
			 &localListCnt);
  if(traceFlag) printf("got localListCnt [%d]\n",localListCnt);
  
  if(lFlag == 1) VDtvwAddNodeToListUnique(nodeID,&childList,&childListCnt);
  /* add up the children too! */
  for(i = 0;i < localListCnt;i++) {
    VDtvwAddNodeToListUnique(&localList[i],&childList,&childListCnt);
  }

  /* start filtering the childList */
  if(childListCnt < 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  for(i = 0;i < childListCnt;i++) {
    /* set the filters */
    sendOut = 1;
    childID =(childList)[i];
    /* be paranoid in filtering it against bad nodes */
    if((childID.objid != NULL_OBJID) && (childID.osnum == nodeID->osnum)) {
      /* did we send in a filter? */
      if((type) || (name)) {
 	/* get the nodeName and nodeType */
	VDctxGetNodeName(&childID,nodeName);
	VDctxGetNodeType(&childID,nodeType);
	/* lock out any accidental OK status */
	sendOut = 0;
      }
      /* filter by type */
      if(type) {
	typeOK = VDfileIsItemSameAs(nodeType,type);
      } else {
	typeOK = 1;
      }
      /* filter by name */
      if(name) {
	nameOK  = VDfileIsItemSameAs(nodeName,name);
      } else {
	nameOK = 1;
      }
      /* set the sendOut */
      if((nameOK == 1) && (typeOK == 1)) {
	sendOut = 1;
      }
      
      /* run the invert filter */
      if(lInvt == 0) {
	if(sendOut == 1) {
	  sendOut = 0;
	} else {
	  sendOut = 1;
	}
      }
      /* do the addNode stuff */
      if(sendOut == 1)  {
	if(childID.osnum != NULL_OBJID) {
	  VDtvwAddNodeToListUnique(&childID,nodeList,nodeListCnt);
	}
      }
    }
  }
  
    retFlag = 1;
wrapup:
  if(childListCnt > 0) _FREE( childList );
  if(localListCnt > 0) _FREE( localList );
  // say bye 
  if (traceFlag) {
    printf("************************************\n");
    printf("<<< %s %s %d nodeListCnt [%d]\n\n\n",ffn(),fn,retFlag,*nodeListCnt);

  }
  return retFlag;
}
/***************************************************
 * 
 * Given a node fetch its parents up to the tree Top:
 * note: the list will return empty if the node 
 * is the treeID 
 * The order is direct parent then each up to the 
 * treeID and includes treeID if parents exist.
 * Allows direct check of parent types/names/attributes
 * from this list
 * useful for makeing the queries work faster and easier
 *
 * don't try sending it any mgrID's or setID's or setsID's
 * cannot be sure exactly what would happen if this were 
 * done
 *
 ***************************************************/
IGRstat VDfileGetNodeParentList(TGRid    *nodeID,
				TGRid   **nodeList,
				IGRint   *nodeListCnt)

{
  VDASSERT_FN("VDfileGetParentNodeList");
  IGRstat          retFlag = 0;
  TGRid            parentID,treeID,nextID;

  // say hi
  if (traceFlag) {
    printf("\n\n>>> %s %s\n",ffn(),fn); 
    printf("************************************\n");
  }
  
  /* args checks */
  VDASSERTW(nodeID);
  VDASSERTW(nodeList);

  /* inits  */
  _FREE( nodeList );
  *nodeListCnt = 0;
  retFlag = 1;
  
  /* fetch the treeID */
  VDctxGetTree(nodeID,&treeID);
  if(treeID.objid == NULL_OBJID) goto wrapup;
  if(treeID.objid == nodeID->objid) goto wrapup;
  
  /* copy over local */
  nextID = *nodeID;
  
  /* start looping around looking for parents */
  while(nextID.objid != NULL_OBJID) {
    VDctxGetTreeParent(&nextID,&parentID);
    if((parentID.objid != NULL_OBJID) && (parentID.osnum == nodeID->osnum)) {
      /* save this guy */
      VDtvwAddNodeToListUnique(&parentID,nodeList,nodeListCnt);
    }
    /* start again */
    nextID = parentID;
    if(nextID.objid == treeID.objid) break;
  }

wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d\n\n\n",ffn(),fn,retFlag);
    printf("************************************\n");
  }
  return retFlag;
}


/**************************************************************
 *
 * Given a list of nodes fetch all the nodes by the 
 * Rules in VDfileGetNodeList (above) 
 *
 **************************************************************/
IGRstat VDfileGetNodeListFromList(TGRid  **nodeIDs,
				  IGRint   nodeIDsCnt,
				  IGRchar *type, 
				  IGRchar *name,
				  IGRint  *child,
				  IGRint  *flag,
				  IGRint  *invt,
				  TGRid  **nodeList,
				  IGRint  *nodeListCnt) 
{
  VDASSERT_FN("VDfileGetParentNodeListFromList");
  IGRstat          retFlag = 0;
  TGRid          **localList;
  IGRint           localListCnt = 0;
  IGRint           i = 0;
  IGRint           j = 0;
 
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* clean up any old nodeList content */ 
  /* prevent any loop memory problems  */
  if(*nodeListCnt > 0) _FREE( *nodeIDs);
  *nodeListCnt = 0;

  /* don't make any list if we don't have any data */
  if(nodeIDsCnt < 1) goto wrapup;

  /* loop through and get the nodes */
  for(i = 0;i < nodeIDsCnt;i++) {
    
    VDfileGetNodeList(&(*nodeIDs)[i],
		       type, 
		       name,
		       child,
		       flag,
		       invt,
		       localList,
		       &localListCnt);
    
    if(*nodeListCnt < 1) continue;
    /* add up the lists */
    for(j = 0;j < *nodeListCnt;j++) {
      if(((*localList)[j].osnum == (*nodeIDs)[i].osnum) && ((*localList)[j].objid != NULL_OBJID)) {
	VDtvwAddNodeToListUnique(&(*localList)[j],nodeList,nodeListCnt);
      }
    }
    _FREE(localList);
    localListCnt = 0;
  }
  retFlag = 1;
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/********************************************
 *
 * Given a list of nodes (1) or many
 * get a list of nodes that is one level
 * below that list.
 * 
 * Important Point here: One Level lists
 * make the requirement that all the nodesIn 
 * must be on a known set of levels to produce
 * a list of nodes actually fitting the definition
 * The User is responsible for making this
 * list proper before the input to this routine
 *
 ********************************************/
IGRint VDtvwGetOneLevelNodeList(TGRid **nodesIn,
				IGRint  nodesInCnt,
				TGRid **nodesOut,
				IGRint *nodesOutCnt)
{
  VDASSERT_FN("VDtvwVDtvwGetOneLevelNodeList");
  IGRint retFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  if(*nodesOutCnt > 0) _FREE( *nodesOut );
  vdfile$GetNodeListFromList(nodeIDs     = nodesIn,
			     nodeIDsCnt  = nodesInCnt,
			     nodeList    = nodesOut, 
			     nodeListCnt = nodesOutCnt);

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/*************************************************
 *
 * Useful tool for 
 * To get a node list with all the children below 
 * a node or group of nodes in a list.
 *
 *************************************************/
IGRint VDtvwGetAllChildNodeList(TGRid  **nodesIn,
				IGRint   nodesInCnt,
				TGRid  **nodesOut,
				IGRint  *nodesOutCnt)
{
  VDASSERT_FN("VDtvwVDtvwGetAllChildNodeList");
  IGRint retFlag = 0;
  IGRint child = 0;

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  if(*nodesOutCnt > 0) _FREE(nodesOut);
  vdfile$GetNodeListFromList(nodeIDs     = nodesIn,
			     nodeIDsCnt  = nodesInCnt,
			     child       = &child,
			     nodeList    = nodesOut, 
			     nodeListCnt = nodesOutCnt);

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/**************************************************
 *
 * Get MY LEVEL list COHORT
 * useful for determining if a node is 
 * on the same level as another node.
 *
 **************************************************/
IGRint VDtvwGetCohortList(TGRid   nodeID,
			  TGRid   **nodesOut,
			  IGRint  *nodesOutCnt)

{
  VDASSERT_FN("VDtvwGetCohortList");
  IGRint retFlag = 0;
  IGRint child   = 0;
  TGRid  parentID,childID;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* check args  */
  if(nodeID.objid == NULL_OBJID) goto wrapup;
  if(!nodesOut) goto wrapup;

  /* some cleanup */
  if(*nodesOutCnt > 0) _FREE(nodesOut);
  *nodesOutCnt = 0;

  /* get the parentID */
  VDctxGetTreeParent(&nodeID,&parentID);
  
  /* if parentID is NULL_OBJID  then we have the tree top */
  if(parentID.objid == NULL_OBJID) {
    VDtvwAddNodeToListUnique(&nodeID,nodesOut,nodesOutCnt);
    retFlag = 1;
    goto wrapup;
  }
  
  /* get the children */
  for(child = 0; VDctxGetNthTreeChild(&parentID,child,&childID); child++) {
    if((childID.osnum == nodeID.osnum) && (childID.objid != NULL_OBJID)) {
      VDtvwAddNodeToListUnique(&childID,nodesOut,nodesOutCnt);
    }
  }

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/**************************************************
 *
 * Order a filelist in a list gadget (simple list gadget)
 *
 **************************************************/
IGRint VDfileOrderFileList(char   *VD_FP,
			   IGRint  gadget,
			   IGRint *order,
			   IGRint *sensative)
{
  VDASSERT_FN("VDfileOrderFileList");
  IGRint   retFlag = 0;
  IGRint   i,row,rows,loops,loop;
  IGRint   col,ord,sense,sortord;
  IGRchar  listText[128],txtA[128],txtB[128];
  IGRint   selFlag = 0;
  IGRint   pos = 0;
  IGRchar **textList;
  IGRint    textListCnt = 0;
  IGRchar  *tmpItem,*item1,*item2;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* argument checks */
  if(!VD_FP) goto wrapup;
  if(gadget < 11) goto wrapup;
  
  /* inits */
  /* default order is ascending */
  ord = 1;
  if(order) {
    if(*order == 0) ord = 0;
  }
  
  /* default sensative is not case sensative */
  sense = 1;
  if(sensative) {  
    if(*sensative == 0) sense = 0;
  }
  

  /* default col is 0 */
  col = 0;
  
  /* get the number of rows */
  FIfld_get_num_rows(VD_FP, gadget, &rows);

  /* has to be at least 2 rows for order to make any difference */
  if(rows < 2) {
    goto wrapup;
  }
  
  
  /* fetch all the text from the gadget column */
  for(row = 0;row < rows;row++) {
    VIfld_get_text(VD_FP, gadget,row,0, 128, listText,&selFlag,&pos);
    /* add the text to a list */
    VDtvwAddStrList(listText,&textList,&textListCnt); 
  }
  if(textListCnt < 2) {
    goto wrapup;
  }

  loop = rows -1;
  /* sort the list up or down alpha and (sensative) */
  for(loop = 0;loop < (rows -1);loop++) {
    loops = rows -1 - loop;  
    for(row = 0;row < loops;row++) {
      if(sense == 1) {
	sortord = strcmp(textList[row],textList[row+1]);
      } else {
	sortord = strcasecmp(textList[row],textList[row+1]);
      }
      if(((sortord > 0) && (ord == 1)) || ((sortord < 0) && (ord == 0))) {
	/* execute a swap */
	tmpItem = textList[row];
	textList[row] = textList[row+1];
	textList[row+1] = tmpItem;
      } 
    }
  }

  /* order by the extension */
  loop = rows -1;
  for(loop = 0;loop < (rows -1);loop++) {
    loops = rows -1 - loop;  
    for(row = 0;row < loops;row++) {
      item1 = strrchr(textList[row],'.');
      item2 = strrchr(textList[row+1],'.');
      /* protect from NULL */
      if((item1 == NULL) || (item2 == NULL)) continue;
      if(sense == 1) {
	sortord = strcmp(item1,item2);
      } else {
	sortord = strcasecmp(item1,item2);
      }
      if(((sortord > 0) && (ord == 1)) || ((sortord < 0) && (ord == 0))) {
	/* execute a swap */
	tmpItem = textList[row];
	textList[row] = textList[row+1];
	textList[row+1] = tmpItem;
      } 
    }
  }

  /* put the list back in the gadget */
  FIg_reset( VD_FP, gadget );
  selFlag = 0;
  VIfld_set_num_rows(VD_FP,gadget,rows);
  for(row = 0;row < rows;row++) {
     FIfld_set_text( VD_FP,
		    gadget,
		    row,
		    col,
		    textList[row],
		    selFlag );
  }
  
  VDtrFixScrollBar(VD_FP,gadget);

  retFlag = 1;
  
wrapup:

  if(textListCnt > 0) _LOOPFREE( textList,textListCnt );
  
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/**************************************************
 *
 * strip the end blanks from a string
 *
 **************************************************/
IGRint VDstripstrend(IGRchar *testStr)

{
  VDASSERT_FN("VDstripstrend");
  IGRint   retFlag = 0;
  IGRint   testLen,i,strCnt = 0;
  IGRchar  *p;
  IGRchar  buf[4096],test[4096];
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s [%s]\n",ffn(),fn,testStr);

  /* check args  */
  if(!testStr) goto wrapup;
  if(testStr[0] == '\0') goto wrapup;

  /* get the testLen */
  testLen = strlen(testStr);
  p = testStr;
  /* start counting through the characters */
  for(i = 0;i < testLen;i++) {
    if(!(*p == ' ')) strCnt = i+1;
    p++;
  }
  buf[0] = '\0';
  test[0] = '\0';
  p = testStr;
  for(i = 0;i < strCnt;i++) {
    sprintf(buf,"%s%c",test,*p);
    strcpy(test,buf);
    p++;
  }
  strcpy(testStr,buf);
  
  retFlag = 1;
  
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

end implementation Root;







