#include <stdio.h>
#include <sys/stat.h>
#include <MEMstruct.h>
#include <MEMerrordef.h>
#include <NFMerrordef.h>
#include <NFMstruct.h>
#include <tiuser.h>
#include <PDUmacros.h>

Display_message(no, where, mtext)
int  no;
int  where;
char  *mtext;
{
    /*_pdm_debug ("Display_message: Message is %s", mtext);*/
    return;
}


/*
NFMls_nodes( prefx, ret_bufr )
MEMptr   *ret_bufr;
{
    _pdm_debug("NFMls_nodes: Stubbed for now", 0);
    return ( NFM_S_SUCCESS);
}
*/


int  Stat (buf, st)
char *buf;
struct stat *st;
{
	int status;
	status = stat ( buf, st );
	return (status);
}


Exit ()
{
	/*_pdm_debug("Exit not available. Using exit.", 0);*/
	exit(0);
}


int  RPScreate_report_file(flg,fpath,tblnm, grpnm,inbuf,inlist)
int  flg;
char *fpath,
     *tblnm,
     *grpnm;
MEMptr	inlist;
MEMptr	inbuf;
{
     /*_pdm_debug ("RPScreate_report_file: stubbed for now", 0);*/
     return ( 0 );
}

struct NFMglobal_st NFMglobal;
int    t_errno;
FILE   net_err;
int    net_client_id;
