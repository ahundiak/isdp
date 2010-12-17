/****************************************************************************/
/*                                                                          */
/*    On selecting a level, the routines in this file, display the catalogs */
/*    and the subsequent levels under the current level and also an option  */
/*    for user to do search on common attributes of the catalogs under the  */
/*    current level                                                         */
/*                   Date Created 1/06/92 :   MMS  (IGI)                    */
/*                                                                          */
/****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "PDUstr.h"
#include "PDUerror.h"
#include "PDMmessage.h"
#include "PDUcommand.h"
#include "MEMerrordef.h"
#include "PALglbs.h"
#include "PDMexec.h"
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif


#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"

/*#include "PDUproto.h" */
#include "PALfunkpro.h"
#include "PALpdmrpro.h"

#define PROJECT        38

/* -------------------- Extern Variables  ----------------------------- */

extern struct PDUrefresh *refresh ;
extern PDMexec_ptr PDMexec ;
extern char             *s_text ;
extern char *PDU_search_format ;
extern int PDU_command;
extern int NumAttribs;

/* -------------------------------------------------------------------- */


DispClsAndCtlgs(Form fp,int form_no,int *cur_level,char **lclcatpath,
		int glabel)

	/* This routine gets list of valid fields at a selected level
	   brings up a pull down list, prompts user to select a field.
	   Also gives an option for search on common attributes for 
	   catalogs under a level
	*/
{

	int  i, j , k,  sts ,  num_ctlgs , ind ;
	char str[55] , tmp[10] , **cat_list, *ptr , **data_ptr , *cplcl ;
        char *msg;

	MEMptr in_buffr=NULL , out_buffr= NULL ;

        if ( (sts = MEMopen(&in_buffr,MEM_SIZE) ) != MEM_S_SUCCESS ){
		printf("MEMopen Error : Status : %d\n",sts );
		return(0);
	}

	/* define column 1 & 2 */ 
	if( format_column(&in_buffr,"p_classlevel","integer") )
		if( ! format_column(&in_buffr,"p_class","char(40)") )
			return(0);

	_pdm_debug("curlevel : %d",*cur_level);

	/* Construct input buffer containing the preceding classes	*/
	/* and their numbers.						*/

	cplcl = (char *) malloc( strlen(*lclcatpath) + 1 );
	strcpy(cplcl, *lclcatpath);

	ptr = strtok( cplcl,":");
	for ( j  = 1 ; (j < *cur_level) && ( ptr ) ; j = j + 1 ) {

		str[0] = '\0';
		sprintf(tmp,"%d",j);

		strcat(str,tmp);
		strcat(str,"\1");

		strcat(str,ptr);
		strcat(str,"\1");

		ptr = strtok(NULL,":") ;

		_pdm_debug( "write str %s", str );

		if( (sts = MEMwrite(in_buffr,str)) != MEM_S_SUCCESS){
				printf("MEMwrite Error : Status  = %d\n", sts );
				free( str );
				MEMclose(&in_buffr);
				return(0);
		}
	}		

	PDMexec -> operation = 0;
	if( Get_text(fp, PROJECT, 0, 0))   /* TR#139307592 */
		mystrcpy( &(PDMexec->project), s_text );

	_pdm_debug("before query");

	sts = PDMquery_classification( in_buffr, &out_buffr);

	_pdm_debug("after query:sts= %d", sts);

	if( sts != PDM_S_SUCCESS ){
		MEMclose(&in_buffr);
		PDUmessage(PDM_E_RETRIEVE_CLASS, 's');
		MEMclose(&out_buffr );
		return(0);
	}

	/* Get list and call pull down for select */

	MEMbuild_array(out_buffr);

	_pdm_debug("no of rows obtained: %d", out_buffr->rows );

	if (out_buffr -> rows < 1 ) {
		MEMclose(&in_buffr);
                msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS_FOUND);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
		return(0);
	}

	cat_list = (char **)malloc((2*(out_buffr -> rows)+2)*sizeof(char *));


	data_ptr = (char **)out_buffr -> data_ptr ;

	num_ctlgs = 0 ;

	/* Add display common attributes option */
	cat_list[num_ctlgs] = (char *)malloc(45);
	strcpy(cat_list[num_ctlgs++],"Search Across Catalogs - Common Attributes");
	cat_list[num_ctlgs] = (char *)malloc(35);
	strcpy(cat_list[num_ctlgs++],"Search Across Catalogs - List");
	cat_list[num_ctlgs] = (char *)malloc(25);
	strcpy(cat_list[num_ctlgs++],"Display Catalogs");

	for( i = 0 ; i < out_buffr -> rows ; i = i + 1 ){

		k = i * out_buffr -> columns ;

		_pdm_debug( "membufr col 1: %s", data_ptr[k+1]);

		if( data_ptr[k+1] != NULL && strlen(data_ptr[k+1]) > 0 )

			if(is_a_new_entry(data_ptr[k+1],cat_list,num_ctlgs)){
				cat_list[num_ctlgs] = malloc(strlen(data_ptr[k+1]) + 1 );
				strcpy(cat_list[num_ctlgs],data_ptr[k+1]);
				++num_ctlgs ;
			}
	}
			
	for( i = 0 ; i < num_ctlgs ; ++i )
		_pdm_debug("pull down list: %s", cat_list[i]);

	/* NO classes and catalogs at this level */
	if ( num_ctlgs == 2 ){
		MEMclose(&in_buffr);	
		return( 0 );
	}
	

	/* display in a pull down list, existing projects */
	pull_main( form_no, fp,CATALOG,0,0, cat_list,
			   num_ctlgs,0,0,12,&sts,&ind );

	_pdm_debug("selected  %s", cat_list[ind]);


	if( !sts ){
		MEMclose(&in_buffr);
		goto CleanUp;
	}


	if( ind == 0 || ind == 1 || ind == 2 ) {

		MEMclose(&out_buffr);

		PDMexec -> operation = 1;

		_pdm_debug("before query");

		sts = PDMquery_classification( in_buffr, &out_buffr);

		_pdm_debug("after query:sts= %d", sts);

/* Fix for TR#139307592 */
		if( sts != PDM_S_SUCCESS ){
			MEMclose(&in_buffr);
			_pdm_debug("PDMquery_classification:No catalogs in this path ",0);
                        msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOG_MAP);
			FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
			MEMclose(&out_buffr );
			return(0);
		}

		MEMclose(&in_buffr);

		MEMbuild_array(out_buffr);
		_pdm_debug("no of catalogs obtained: %d", out_buffr->rows );

		if( ind == 0 ) {
                        PDUmessage(PDC_M_SEARCH_ACROSS_CATS, 'c');
                        PDU_command = PDS_M_GET_COMM_ATTR;
			if ( search_common_attribs(fp,out_buffr) )
				sts = COMM_ATTRIBS ;
			else 
				goto CleanUp;
		}

		else if( ind == 1 ) {
                        _pdm_debug("enter search across list", 0);
                        PALget_format();

                        sts = WaitForEvent();
                        _pdm_status("WaitForEvent", sts);

                        if (!sts)
                          {
                           _pdm_debug("search format form was cancelled", 0);
                           PDUmessage(PDM_E_CMD_CANCELLED, 's');
                           return(0);
                          }
                        
                        if (!(strlen(PDU_search_format)))
                          {
                          PDUmessage(PDM_E_NO_FORMAT_SELECTED, 's');
                          return(0);
                          }
                        else if (strcmp(PDU_search_format, "All Attributes")==0)
                          {
                          PDUmessage(PDC_M_SEARCH_ACROSS_CATS, 'c');
                          PDU_command = PDS_M_GET_UNION_ATTR;
			  if ( search_union_attribs(fp,out_buffr) )
				  sts = COMM_ATTRIBS ;
			  else 
                                  {
                                  sts = 0;
                                  NumAttribs = 0;
				  goto CleanUp;
                                  }
                          }
                        else
                          {
                          PDUmessage(PDC_M_SEARCH_ACROSS_CATS, 'c');
                          PDU_command = PDS_M_GET_LIST_ATTR;
			  if ( search_list_format_attribs(fp,PDU_search_format,out_buffr) )
				  sts = COMM_ATTRIBS ;
			  else 
                                  {
                                  sts = 0;
                                  NumAttribs = 0;
				  goto CleanUp;
                                  }
                          }
		}

	}
	else{
		sts = SUCCESS ;

		MEMclose(&in_buffr);
	}
	
	if( ind == 2) {
		
		FreeArrayPtr(cat_list,num_ctlgs);
	
		cat_list = (char **)malloc( (out_buffr -> rows + 1) * sizeof(char *));

	
		for( i = 0 ; i < out_buffr -> rows ; ++i )
			cat_list[i] = (char *)malloc(TBL_LEN);

		if( PALgetcatlist(fp,out_buffr,&num_ctlgs,cat_list,0) ) {

			/* display in a pull down list, existing projects */
			pull_main( form_no, fp,CATALOG,0,0, cat_list,
				   num_ctlgs,0,0,12,&sts,&ind );

			_pdm_debug("selected  %s", cat_list[ind]);
			
			if( !sts )
				goto CleanUp;
		}

		sts = CATALOG_SELECTED ;
	}

	if( sts == SUCCESS ){
		for( i = 0 ; i < out_buffr -> rows ; i = i + 1) 
			if(!strcmp(cat_list[ind],
					data_ptr[(i*out_buffr->columns)+1])
			   && !strcmp(data_ptr[(i*out_buffr ->columns)+4],"C") )
			{
				sts = CATALOG_SELECTED ;
				break;
			}

	}

	if( sts ==  CATALOG_SELECTED )  {

		_pdm_debug("catalog selected: %s", cat_list[ind]);
/*		if( refresh -> rev_catalog != NULL )
		{
			_pdm_debug("PDMClscats: rev_ctalog realloc",0);
			(refresh -> rev_catalog) = (char *)realloc((refresh -> rev_catalog),
						strlen(cat_list[ind]) +1);
			_pdm_debug("realloc done",0);
		}
		else
			refresh -> rev_catalog = (char *)malloc( strlen(cat_list[ind]) + 1);

		MemCheck( refresh->rev_catalog );


		strcpy(refresh -> rev_catalog,cat_list[ind]);
*/
		mystrcpy(&(refresh -> rev_catalog), cat_list[ind]);
		_pdm_debug("mystrcpy: catalog: %s",refresh -> rev_catalog );

	}
	else if( sts == SUCCESS ) {

		_pdm_debug( "before append: lclcatpath %s", *lclcatpath );
		_pdm_debug("strlen of lelcatpath: %d", strlen(*lclcatpath));

		*lclcatpath = (char *)realloc(*lclcatpath, strlen(*lclcatpath) +
						strlen(cat_list[ind]) + 2);

		MemCheck(*lclcatpath);

		if( strlen(*lclcatpath) > 1  )
			strcat(*lclcatpath,":");

		_pdm_debug( "lclcatpath 1 %s", *lclcatpath );

		strcat(*lclcatpath,cat_list[ind]);
	}

	_pdm_debug( "lclcatpath %s", *lclcatpath );

CleanUp:

	FreeArrayPtr(cat_list,num_ctlgs);

	num_ctlgs = 0;

	MEMclose(&out_buffr);

	return(sts);

}

