#include "machine.h"
#include "NFMRextern.h"

void _NFMRdebug_NFMoperation_set( fname, operation )
    char   *fname;
    struct NFMoperation *operation;
{
    int    i;

    for( i=0; ; ++i )
    {
	if( strcmp( (operation+i)->catalog, "" ) == 0 )
	    break;
        _NFMRdebug(( fname, "NFMoperation->transfer      : <%d>\n",(operation+i)->transfer ));
        _NFMRdebug(( fname, "NFMoperation->delete        : <%d>\n",(operation+i)->delete ));
        _NFMRdebug(( fname, "NFMoperation->purge         : <%d>\n",(operation+i)->purge ));
        _NFMRdebug(( fname, "NFMoperation->catalog       : <%s>\n",
			 (operation+i)->catalog ));
	_NFMRdebug(( fname, "NFMoperation->catalog_no    : <%ld\n",
			 (operation+i)->catalog_no ));
        _NFMRdebug(( fname, "NFMoperation->item_name     : <%s>\n",
 			 (operation+i)->item_name ));
        _NFMRdebug(( fname, "NFMoperation->item_rev      : <%s>\n",
 			 (operation+i)->item_rev ));
    }
}

void _NFMRdebug_NFMwf_info( fname, wf_info )
    char   *fname;
    struct NFMwf_info wf_info;
{

    _NFMRdebug(( fname, "NFMwf_info.workflow      : <%d>\n",
			 wf_info.workflow ));
    if( wf_info.workflow == NFM_WORKFLOW )
    {
        _NFMRdebug(( fname, "NFMwf_info.command       : <%s>\n", 
			 wf_info.command ));
        _NFMRdebug(( fname, "NFMwf_info.workflow_name : <%s>\n", 
 			 wf_info.workflow_name ));
        _NFMRdebug(( fname, "NFMwf_info.project_name  : <%s>\n",
 			 wf_info.project_name ));
        _NFMRdebug(( fname, "NFMwf_info.app_name      : <%s>\n",
			 wf_info.app_name ));
    }
}

void _NFMRdebug_NFMoperation_item( fname, operation )
    char   *fname;
    struct NFMoperation operation;
{

    _NFMRdebug(( fname, "NFMoperation.transfer      : <%d>\n",
			 operation.transfer ));
    _NFMRdebug(( fname, "NFMoperation.delete        : <%d>\n", 
			 operation.delete ));
    _NFMRdebug(( fname, "NFMoperation.purge 	       : <%d>\n", 
			 operation.purge ));
}

void _NFMRdebug_NFMmember_info( fname, member_info, members_to_define )
    char   *fname;
    struct NFMmember_info *member_info;
    short  members_to_define;
{
    int  i;

    for( i=0; i<members_to_define; ++i )
    {
        _NFMRdebug(( fname, "NFMmember_info->operation      : <%d>\n",
			 (member_info+i)->operation));
        _NFMRdebug(( fname, "NFMmember_info->citno          : <%ld>\n", 
			 (member_info+i)->citno ));
        _NFMRdebug(( fname, "NFMmember_info->catalog_name   : <%s>\n", 
			 (member_info+i)->catalog_name ));
        _NFMRdebug(( fname, "NFMmember_info->catalog_no     : <%ld>\n",
			 (member_info+i)->catalog_no ));
        _NFMRdebug(( fname, "NFMmember_info->item_name      : <%s>\n",
			 (member_info+i)->item_name ));
        _NFMRdebug(( fname, "NFMmember_info->item_rev       : <%s>\n",
			 (member_info+i)->item_rev ));
        _NFMRdebug(( fname, "NFMmember_info->item_no     : <%ld>\n",
			 (member_info+i)->item_no ));
        _NFMRdebug(( fname, "NFMmember_info->type           : <%s>\n",
			 (member_info+i)->type ));
    }
}

void _NFMRdebug_NFMquery_info( fname, query_info )
    char   *fname;
    struct NFMquery_info query_info;
{

    _NFMRdebug(( fname, "NFMquery_info.select_clause  : <%s>\n",
			 query_info.select_clause));
    _NFMRdebug(( fname, "NFMquery_info.from_clause    : <%s>\n", 
			 query_info.from_clause ));
    _NFMRdebug(( fname, "NFMquery_info.where_clause   : <%s>\n", 
			 query_info.where_clause ));
    _NFMRdebug(( fname, "NFMquery_info.order_by_clause : <%s>\n",
			 query_info.order_by_clause ));
    _NFMRdebug(( fname, "NFMquery_info.prompts         : <%s>\n",
			 query_info.prompts ));
}

void _NFMRdebug_synonym_list( fname, syn_info )
    char *fname;
    char **syn_info;
{
    int  i;
 
    for( i=0; ; ++i )
    {
	if( *(syn_info+i) == NULL )
	    break;
	_NFMRdebug(( fname, "Synonym <%s>\n", *(syn_info+i) ));
    }
}
