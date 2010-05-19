class implementation Root;

#include 	<stdio.h>
#include	"exdef.h"

#include	"OMminimum.h"
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"igr.h"
#include	"griodef.h"
#include	"godef.h"
#include	"gr.h"
#include	"igrdp.h"
#include	"go.h"
#include	"ex.h"
#include	"grio.h"
#include	"exmacros.h"
#include	"DItypedef.h"
#include	"DIdef.h"
#include	"DIglob.h"
#include	"DIprims.h"
#include	"griomacros.h"
#include	"msdef.h"
#include	"msmacros.h"
#include	"dp.h"
#include 	"FI.h"
#define	 VD_LIST_FLD  15
#define	 VD_CRT_QRY   16

#include	"vdmemmacros.h"
#include	"vderrmacros.h"
#include	"vdmdlvwdef.h"    /* for VD_MAX_QRY_NAME_LEN, DESC_LEN */
#include	"v_miscmacros.h"  

from VDquery import VDgetPfxInfo;

%safe
#include	"VX_FIproto.h"
static  int			num_qry;
static  struct GRid		*qry_id_list = NULL;
static  struct GRmd_env		*qry_env_list = NULL;
static  char			**qry_name_list = NULL,
				**qry_desc_list  = NULL;
static  char			*selected_qry;

static  int                     num_qry_no_pfx;
static  struct GRid             *qry_id_list_no_pfx = NULL;
static  struct GRmd_env         *qry_env_list_no_pfx = NULL;
static  char                    **qry_name_list_no_pfx = NULL,
                                **qry_desc_list_no_pfx  = NULL;
%endsafe

int   VDselQry_form_notif();
int   VDform_events_loop1();

struct VDSortQryInSelFrm
{
        IGRchar                 qryName[80];
        IGRchar                 qryDesc[200];
        struct  GRid            qryId;
        struct  GRmd_env        qryEnv;
};

/*
Internal Function : VDdispQryForm

  When this function is called, a form showing all defined queries appear.
User can select one or more queries. This function returns the list
of selected queries.

Memory:
 This function allocates memory for qry_ids, qry_envs, qry_names and
qry_desc.

 It should be freed by caller.
 if ( qry_ids )  free ( qry_ids );
 if ( qry_envs )  free ( qry_envs );
 if ( qry_names ) VDfree_str_list ( qry_names, num_qry_sel );
 if ( qry_desc ) VDfree_str_list ( qry_desc, num_qry_sel );
*/

long  VDdispQryForm(
  long			*msg,		/* O - return status */
  int			*num_qry_sel,	/* O - no. of queries selected	*/
  struct GRid		**qry_ids,	/* O - list of ids of selected queries.
						= NULL, if not needed	*/
  struct GRmd_env	**qry_envs,	/* O - list of envs of selected queries.
						= NULL, if not needed	*/
  char			***qry_names,	/* O - list of names of selected queries.
						= NULL, if not needed	*/
  char			***qry_desc	/* O - list of desc of selected queries.
						= NULL, if not needed	*/
)
{
 long			sts;
 int			ii, jj;
 char			filename[15];
 Form			fp;


 sts = VDget_qry_list ( msg, &num_qry,  &qry_id_list, &qry_env_list,
			&qry_name_list, &qry_desc_list  );
 VDS_ERR_HNDLR( "VDget_qry_list", sts, *msg, VD_VERBOSE, wrapup );
 if ( num_qry == 0 )
 {
    ex$message (  in_buff = "No queries defined",
		  field   = ERROR_FIELD,
		  justification = CENTER_JUS );
    sts = OM_W_ABORT;
    goto wrapup;
 }

 selected_qry = (char *) malloc( sizeof(char) * num_qry );
 for ( ii =0; ii<num_qry; ii++)  selected_qry[ii] = FALSE;

 sts = FIf_new( 0, "VDselQry", VDselQry_form_notif, &fp);

#ifdef VDS_DBG
 FIf_cvrt_to_perm_win(fp);
#endif

 if (sts != FI_SUCCESS)
 {
   fprintf (stderr, "FIf_new failed: sts = %d\n",sts);
   goto wrapup;
 }

 FIfld_set_max_num_rows( fp, VD_LIST_FLD, num_qry );
 FIfld_set_num_rows ( fp, VD_LIST_FLD, num_qry );

 for(ii=0; ii<num_qry; ii++)
 {
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 0, qry_name_list[ii], FALSE );
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 1, qry_desc_list[ii], FALSE );

     FIfld_set_select( fp, VD_LIST_FLD, ii, 0, FALSE );
     FIfld_set_select( fp, VD_LIST_FLD, ii, 1, FALSE );

     sts = VDget_filename_from_os (  qry_id_list[ii].osnum,  filename );
     if ( !(1&sts) ) continue;
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 2, filename, FALSE );
     FIfld_set_select( fp, VD_LIST_FLD, ii, 2, FALSE );
 }

 FIf_display ( fp );

 sts = VDform_events_loop1 ( fp );
 if ( sts != FI_SUCCESS ) 
 {
   *num_qry_sel = 0;
   goto wrapup;
 }

 *num_qry_sel = 0;
 for ( ii=0; ii<num_qry; ii++)
    if ( selected_qry[ii] ) (*num_qry_sel)++;

 if ( *num_qry_sel )
 {
   /*
    *  allocate memory
    */

   if ( qry_ids )
      *qry_ids = (struct GRid *) malloc( sizeof(struct GRid) *(*num_qry_sel));

   if ( qry_envs )
      *qry_envs = (struct GRmd_env *)
			malloc( sizeof(struct GRmd_env) * (*num_qry_sel) );

   if ( qry_names )
   {
     sts = vd$malloc_str_list ( str_list = qry_names,
				num_str  = (*num_qry_sel),
				str_size = VD_MAX_QRY_NAME_LEN );
     if( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   if ( qry_desc )
   {
     sts = vd$malloc_str_list ( str_list = qry_desc,
				num_str  = (*num_qry_sel),
				str_size = VD_MAX_QRY_DESC_LEN );
     if( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }

   for ( ii=0, jj=0; ii<num_qry; ii++)
   {
     if ( selected_qry[ii] )
     {
        if ( qry_ids )  (*qry_ids)[jj] = qry_id_list[ii];
	if ( qry_envs ) (*qry_envs)[jj] = qry_env_list[ii];
	if ( qry_names ) strcpy( (*qry_names)[jj], qry_name_list[ii] );
	if ( qry_desc ) strcpy( (*qry_desc)[jj], qry_desc_list[ii] );
	jj++;
     }
   } /* for ( ii=0, jj=0; ii<num_qry; ii++) */
 } /* if ( *num_qry_sel ) */

wrapup:
 if ( qry_id_list ) { free (qry_id_list ); qry_id_list = NULL; }
 if ( qry_env_list ) { free (qry_env_list ); qry_env_list = NULL; }
 if ( qry_name_list )
 {
    vd$free_str_list (	str_list = qry_name_list,
			num_str  = num_qry );
    qry_name_list = NULL;
 }
 if ( qry_desc_list )
 {
    vd$free_str_list (	str_list = qry_desc_list,
			num_str  = num_qry );
    qry_desc_list = NULL;
 }
 if ( selected_qry ) { free ( selected_qry); selected_qry = NULL; }
 num_qry = 0;
 return sts;
}

int VDselQry_form_notif (
  int           f_label,        /* i - The label of the form    */
  int           g_label,        /* i - The label of the gadget  */
  double        value,          /* i - The value of the gadget  */
  Form          fp              /* i - Form pointer             */
)
{
 int			ii,
 			sel_flag;
 long			msg;


  FIg_set_text( fp, FI_MSG_FIELD, "" );

  switch ( g_label )
  {
    case VD_CRT_QRY:
        break;
    case VD_LIST_FLD:
	break;

     case FI_CANCEL:
	{ int   rsp = EX_FORM_FINISHED;
	  ex$putque(msg = &msg, response = &rsp);
	}
	break;

     case FI_ACCEPT:
	for ( ii=0; ii < num_qry; ii++ )
	{
	  FIfld_get_select ( fp, VD_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag )  selected_qry[ii] = TRUE;
	}
	{ int   rsp = EX_FORM_FINISHED;
	  ex$putque(msg = &msg, response = &rsp);
	}
	break;

   }

  /*
   * The following statement is only to make compiler not to say
   * that f_label and value are not referenced.
   * This can be the last statement in case of any changes 
   */
  if ( f_label || value ) ;

 return OM_S_SUCCESS;

}


int VDform_events_loop1( Form fp )
{
int		status, response;
IGRlong		ret, done=0;
IGRchar		response_data[256];
struct GRevent	event;

	do {

		done = 1;

		status = co$getevent (
			msg             = &ret,
			event_mask      = ( GRm_BACK_UP | GRm_FORM_FINISHED ),
			event           = &event,
			response        = &response,
			response_data   = response_data);

		if ( response == CMD_STRING || response == STRING ||
		     response == EX_OBJID ) {
			ex$message( field = ERROR_FIELD,
				    in_buff = "Input Ignored");
			done = 0;
		}

	/* While not trying to stack a command or enter a string */
	} while ( !done );

	/* Undisplay form and free the memory it allocated */
	FIf_delete (fp);

	/* kill command event detected? */
	if ( response ==  TERMINATE ) {

	/* Place the kill command event back on the queue */
		ex$putque(
			msg = &ret,
			response	= &response,
			buffer		= response_data);
	}

	if ( event.response != EX_FORM_FINISHED ) return( event.response );
		
/*
		This code would replace the event code above on non-GRnuc apps

		Wait_for_next ( FI_EVENT_MASK, &event );
		if( !FI_process_event(event) ) FI_clear_event(event);
*/
	return(FI_SUCCESS);
}
/****************************************************************************
 Function VDSortQryName
  a sort function for query in the select query form
*****************************************************************************/
int  VDSortQryName( struct VDSortQryInSelFrm *elm1,
                    struct VDSortQryInSelFrm *elm2 )
{
     return strcmp( elm1->qryName, elm2->qryName);
}

/*------------------------------------------------------------------------
 Function  VDdispQryPfxForm 

 Description: This function is a modification of VDdispQryForm. It can be used 
              for displaying the "select query" form like VDdispQryForm. It
              give the flag to allow usr to list all queries or only the 
              queries without prefix. The last option is used for "Define Item 
              Prefix Definition" command.
              The "create query button" is added to "select query" form. 
              Relative code is added for create query action.
Argument:
  long             *msg,           O - return status 
  int              *num_qry_sel,   O - no. of queries selected 
  struct GRi       **qry_ids,      O - list of ids of selected queries.
                                                = NULL, if not needed  
  struct GRmd_env  **qry_envs,     O - list of envs of selected queries.
                                                = NULL, if not needed  
  char             ***qry_names,   O - list of names of selected queries
                                                = NULL, if not needed 
  char             ***qry_desc     O - list of desc of selected queries.
                                                = NULL, if not needed
  int              pfxflag         I - =0 query without prefix in design file 
                                       =1 all queries   
History:
              7/8/95     YZhu               create
Return
       sts == OM_SSUCCESS      if success
-------------------------------------------------------------------------*/
long  VDdispQryPfxForm(
  		long                  *msg,           
  		int                   *num_qry_sel,  
  		struct GRid           **qry_ids,    
  		struct GRmd_env       **qry_envs,     
  		char                  ***qry_names,  
  		char                  ***qry_desc,
                int                   pfxflag)
{
long                   sts = OM_S_SUCCESS;
int                    ii, jj,i;
char                   filename[15];
Form                   fp;
char                   pfxName[80];
int                    pfxIndex,len;
long                   status;
GRspacenum             curOS;
struct VDSortQryInSelFrm  *sortList = NULL ;


	#ifdef VDS_DBG
 		printf(" VDdispQryPfxForm \n");
	#endif

   /* get current module */
   status =
   ex$get_cur_mod(  osnum   = &curOS);
   if( !(status&1)) goto wrapup;    


   /* 
    * get query list 
    */ 
   sts = VDget_qry_list ( msg, &num_qry,  &qry_id_list, &qry_env_list,
                        &qry_name_list, &qry_desc_list  );
   VDS_ERR_HNDLR( "VDget_qry_list", sts, *msg, VD_VERBOSE, wrapup );
   if ( num_qry == 0 ) {
       ex$message (  in_buff = "No queries defined",
                  field   = ERROR_FIELD,
                  justification = CENTER_JUS );
       sts = OM_W_ABORT;
       goto wrapup;
   }

   /* sort query */
   sortList = NULL;
   sortList = _MALLOC( num_qry, struct VDSortQryInSelFrm ); 
   if( !sortList ) {
      goto wrapup;
   } 
               
   for( i = 0; i < num_qry; i ++ ) {
      sortList[i].qryId = qry_id_list[i];
      sortList[i].qryEnv = qry_env_list[i];
      sortList[i].qryName[0] = '\0';
      strcpy(sortList[i].qryName, qry_name_list[i]);
      sortList[i].qryDesc[0] = '\0';
      strcpy(sortList[i].qryDesc, qry_desc_list[i]);
   }

   if( num_qry > 1) {
          qsort( sortList, num_qry, sizeof(struct VDSortQryInSelFrm),
                      (int (*)())VDSortQryName);

          for( i = 0; i < num_qry; i ++ ) {
            qry_id_list[i] = sortList[i].qryId;
            qry_env_list[i] =sortList[i].qryEnv;
            len = strlen( sortList[i].qryName );
            strncpy(qry_name_list[i],sortList[i].qryName, len);
            qry_name_list[i][len] = '\0';
            len = strlen( sortList[i].qryDesc );
            strncpy(qry_desc_list[i],sortList[i].qryDesc, len);
            qry_desc_list[i][len] = '\0';
          }
   }

 
   /* 
    * get query list without the prefix in design file 
    * and all queries in ref files.
    */
   ii = 0;
   if( !pfxflag) {
      for (i = 0; i < num_qry; i ++ ) { 
           /* read pfxIndex and pfxName from collector */
           pfxIndex = -1;
           pfxName[0] = '\0';
           status =
           om$send(msg = message VDquery.VDgetPfxInfo( &sts,
                                                       &pfxIndex,
                                                       pfxName),
                                        targetid = qry_id_list[i].objid,
                                        targetos = qry_id_list[i].osnum,
                                        senderid = NULL_OBJID );
           if( !(status & sts & 1) || qry_id_list[i].osnum != curOS ){
              ii = ii + 1 ;
           }
      }
   } 
   num_qry_no_pfx = ii;

   /*
    *  allocate memory: qry_id_list_no_pfx, qry_env_list_no_pfx, 
    *                   qry_name_list_no_pfx, qry_desc_list_no_pfx 
    */
   if ( num_qry_no_pfx && !pfxflag) {
      qry_id_list_no_pfx =  _MALLOC( num_qry_no_pfx, struct GRid); 
      
      qry_env_list_no_pfx = _MALLOC(num_qry_no_pfx, struct GRmd_env );

      sts = vd$malloc_str_list ( str_list =  &qry_name_list_no_pfx,
                                   num_str  = num_qry_no_pfx,
                                   str_size = VD_MAX_QRY_NAME_LEN );
      if( !sts ) {
      printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
        goto wrapup;
      }
      
      sts = vd$malloc_str_list ( str_list = &qry_desc_list_no_pfx,
                                   num_str  = num_qry_no_pfx,
                                   str_size = VD_MAX_QRY_DESC_LEN );
      if( !sts ) {
        printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
        goto wrapup;
      }
   } /* if */
   /* 
    * make query list without prefix 
    */ 
   ii = 0;
   if ( num_qry_no_pfx && !pfxflag) {
      for (i = 0; i < num_qry; i ++ ) {
           /* read pfxIndex and pfxName from collector */
           pfxIndex = -1;
           pfxName[0] = '\0';
           status =
           om$send(msg = message VDquery.VDgetPfxInfo( &sts,
                                                       &pfxIndex,
                                                       pfxName),
                                        targetid = qry_id_list[i].objid,
                                        targetos = qry_id_list[i].osnum,
                                        senderid = NULL_OBJID );
           if( !(status & sts & 1) || qry_id_list[i].osnum != curOS ){
              qry_id_list_no_pfx[ii] = qry_id_list[i]; 
              qry_env_list_no_pfx[ii] = qry_env_list[i]; 
              qry_name_list_no_pfx[ii][0] = '\0';  
              qry_desc_list_no_pfx[ii][0] = '\0';  
              strcpy(qry_name_list_no_pfx[ii], qry_name_list[i]); 
              strcpy(qry_desc_list_no_pfx[ii], qry_desc_list[i]); 
              ii = ii + 1 ;
           }
      }
   } 
   /*
    * make selected query list
    */
   selected_qry =  _MALLOC(num_qry, char );
   for ( ii =0; ii<num_qry; ii++)  selected_qry[ii] = FALSE;

   /* 
    * set "select query"  form 
    */
   sts = FIf_new( 0, "VDselQry", VDselQry_form_notif, &fp);

		#ifdef VDS_DBG
 			FIf_cvrt_to_perm_win(fp);
		#endif

   if (sts != FI_SUCCESS) {
          fprintf (stderr, "FIf_new failed: sts = %d\n",sts);
          goto wrapup;
   }

   if(pfxflag) { /* select all queries */
        FIfld_set_max_num_rows( fp, VD_LIST_FLD, num_qry );
        FIfld_set_num_rows ( fp, VD_LIST_FLD, num_qry );

        for(ii=0; ii<num_qry; ii++) {
         /* set query name and description */
 
         FIfld_set_text ( fp, VD_LIST_FLD, ii, 0, qry_name_list[ii], FALSE );
         FIfld_set_text ( fp, VD_LIST_FLD, ii, 1, qry_desc_list[ii], FALSE );

         FIfld_set_select( fp, VD_LIST_FLD, ii, 0, FALSE );
         FIfld_set_select( fp, VD_LIST_FLD, ii, 1, FALSE );
     
         /* set file name the query belongs to */
         sts = VDget_filename_from_os (  qry_id_list[ii].osnum,  filename );
         if ( !(1&sts) ) continue;
         FIfld_set_text ( fp, VD_LIST_FLD, ii, 2, filename, FALSE );
         FIfld_set_select( fp, VD_LIST_FLD, ii, 2, FALSE );
        }
   }
   else if ( num_qry_no_pfx && !pfxflag) {
        /* select queies without prefix */
        FIfld_set_max_num_rows( fp, VD_LIST_FLD, num_qry_no_pfx );
        FIfld_set_num_rows ( fp, VD_LIST_FLD, num_qry_no_pfx );
        for(ii=0; ii<num_qry_no_pfx; ii++) {
         /* set query name and description */

         FIfld_set_text ( fp, VD_LIST_FLD, ii, 0, qry_name_list_no_pfx[ii],
			  FALSE );
         FIfld_set_text ( fp, VD_LIST_FLD, ii, 1, qry_desc_list_no_pfx[ii],
			  FALSE );

         FIfld_set_select( fp, VD_LIST_FLD, ii, 0, FALSE );
         FIfld_set_select( fp, VD_LIST_FLD, ii, 1, FALSE );

         /* set file name the query belongs to */
         sts = VDget_filename_from_os(qry_id_list_no_pfx[ii].osnum,  filename );
         if ( !(1&sts) ) continue;
         FIfld_set_text ( fp, VD_LIST_FLD, ii, 2, filename, FALSE );
         FIfld_set_select( fp, VD_LIST_FLD, ii, 2, FALSE );
        }
   }
   /* work on select query form */
   FIf_display ( fp );
   sts = VDform_events_loop1 ( fp );
   /* back from select query form */

   if ( sts != FI_SUCCESS ) {
   	*num_qry_sel = 0;
   	goto wrapup;
   }

   *num_qry_sel = 0;
   if(pfxflag) { /* select all queries */
        for ( ii=0; ii<num_qry; ii++)
    	  if ( selected_qry[ii] ) (*num_qry_sel)++;
   }
   else if ( num_qry_no_pfx && !pfxflag) {
        /* select queries without prefix */
        for ( ii=0; ii<num_qry; ii++)
          if ( selected_qry[ii] ) (*num_qry_sel)++;
   }

   /*
    *  allocate memory: qry_ids, qry_envs, qry_names, qry_desci for selected
    *                   query,
    */
   if ( *num_qry_sel ) {
      if ( qry_ids )
      *qry_ids = _MALLOC( (*num_qry_sel), struct GRid);

      if ( qry_envs )
      *qry_envs = _MALLOC( (*num_qry_sel), struct GRmd_env);

      if ( qry_names ) {
        sts = vd$malloc_str_list ( str_list = qry_names,
                                num_str  = (*num_qry_sel),
                                str_size = VD_MAX_QRY_NAME_LEN );
        if( !sts ) {
        printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
        goto wrapup;
        }
      }
      if ( qry_desc ) {
        sts = vd$malloc_str_list ( str_list = qry_desc,
                                 num_str  = (*num_qry_sel),
                                str_size = VD_MAX_QRY_DESC_LEN );
        if( !sts ) {
        printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
        goto wrapup;
        }
      }
      
      /* 
       * pick up seleted queries from query list 
       */ 
   
      if(pfxflag) { /* select all queries */
        for ( ii=0, jj=0; ii<num_qry; ii++) {
           if ( selected_qry[ii] ) {
        	if ( qry_ids )  (*qry_ids)[jj] = qry_id_list[ii];
        	if ( qry_envs ) (*qry_envs)[jj] = qry_env_list[ii];
        	if ( qry_names ) strcpy( (*qry_names)[jj], qry_name_list[ii] );
        	if ( qry_desc ) strcpy( (*qry_desc)[jj], qry_desc_list[ii] );
        	jj++;
           }
         } /* for ( ii=0, jj=0; ii<num_qry; ii++) */
      }  
      else if ( num_qry_no_pfx && !pfxflag) {
        for ( ii=0, jj=0; ii<num_qry_no_pfx; ii++) {
           if ( selected_qry[ii] ) {
                if ( qry_ids )  (*qry_ids)[jj] = qry_id_list_no_pfx[ii];
                if ( qry_envs ) (*qry_envs)[jj] = qry_env_list_no_pfx[ii];
                if ( qry_names ) strcpy( (*qry_names)[jj], 
                                          qry_name_list_no_pfx[ii] );
                if ( qry_desc ) strcpy( (*qry_desc)[jj], 
                                          qry_desc_list_no_pfx[ii] );
                jj++;
           }
         } /* for ( ii=0, jj=0; ii<num_qry_no_pfx; ii++) */
      }
   } /* if ( *num_qry_sel ) */

wrapup:

    _FREE(qry_id_list ); 
            qry_id_list = NULL; 

    _FREE(qry_env_list ); 
            qry_env_list = NULL; 

    if ( qry_name_list ) {
         vd$free_str_list (  str_list = qry_name_list,
                             num_str  = num_qry );
         qry_name_list = NULL;
    }
    if ( qry_desc_list ) {
    	 vd$free_str_list (  str_list = qry_desc_list,
                             num_str  = num_qry );
         qry_desc_list = NULL;
    }

    _FREE(qry_id_list_no_pfx ); 
                qry_id_list_no_pfx = NULL; 
    _FREE(qry_env_list_no_pfx ); 
                qry_env_list_no_pfx = NULL;

    if ( qry_name_list_no_pfx ) {
         vd$free_str_list (  str_list = qry_name_list_no_pfx,
                             num_str  = num_qry_no_pfx );
         qry_name_list_no_pfx = NULL;
    }
    if ( qry_desc_list_no_pfx ) {
         vd$free_str_list (  str_list = qry_desc_list_no_pfx,
                             num_str  = num_qry_no_pfx );
         qry_desc_list_no_pfx = NULL;
    }

    _FREE( sortList );
    _FREE( selected_qry); 
           selected_qry = NULL; 
    num_qry = 0;
    num_qry_no_pfx = 0;
    return sts;

} /* VDdispQryPfxForm */ 

          
end implementation Root;

