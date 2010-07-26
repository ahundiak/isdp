#include	"OMminimum.h"
#include	"OMprimitives.h"
#include	"OMerrordef.h"

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ error */
/* check status - exit if bad */
 error(str,sts)
 char *str;
 int sts;
 {
  if (1&sts)
    return;
  printf("!!!!!!!!!!!!! test failed in %s\n",str);
  om$report_error(sts=sts);
  exit(0);
 }

main()
{
int		sts, i;
OM_S_NEIGHBOR	neighbor;
OM_S_MESSAGE	msg;
OMuint		flag=TRUE;
OM_S_OBJID	oid[350];
static char	*OMparams[]={"DEFTRANS_GROUP_EXTOBJS=500", "LOGCLUSTER_SIZE=4096",NULL};
OM_S_CHANSELECT	cs_to, cs_fr;
struct OM_sd_connect_args
{
  OM_S_CHANSELECT	to_sel;
  int			to_indx;
  OM_S_OBJID		fr_objid;
  OMuword		fr_os;
  OM_S_CHANSELECT	fr_sel;
  int			fr_indx;
} args;
struct OM_sd_disconnect_args
{
  OM_S_CHANSELECT	to_sel;
  OM_S_OBJID		fr_oid;
  OMuword		fr_os;
  OM_S_CHANSELECT	fr_sel;
} args_d;

if(!(1&(sts = om$runtime_init(paramc=2,param_list=OMparams) )))
  {
    error("Error from runtime_init",sts);
  }
if(!(1&(sts = om$make_neighbor(p_neighbor=&neighbor))))
  {
    error("error with make neighbor", sts);
  }
for(i=0; i<350; i++)
if(!(1&(sts = om$construct(classname="g",osnum=OM_Gw_current_OS,p_objid=&oid[i]) )))
  {
    error("error with construct", sts);
  }
if(!(1&(sts = om$make_message(classname="Root",
				methodname="delete",
				size=sizeof(OMuint),
				p_arglist=&flag, p_msg=&msg) )))
  {
    error("error with make message", sts);
  }
if(!(1&(sts = om$send(msg=&msg, senderid=oid[10], targetid=oid[10]))))
  {
    error("error with send delete", sts);
  }
if(!(1&(sts = om$send(msg=&msg, senderid=oid[12], targetid=oid[12]))))
  {
    error("error with send delete", sts);
  }
/*********Delete coalscing with rear then front*************/
/****where rear free space points to front as next free*****/
if(!(1&(sts = om$send(msg=&msg, senderid=oid[11], targetid=oid[11]))))
  {
    error("error with send delete", sts);
  }
if(!(1&(sts = om$send(msg=&msg, senderid=oid[325], targetid=oid[325]))))
  {
    error("error with send delete", sts);
  }
if(!(1&(sts = om$send(msg=&msg, senderid=oid[340], targetid=oid[340]))))
  {
    error("error with send delete", sts);
  }
if(!(1&(sts = om$send(msg=&msg, senderid=oid[327], targetid=oid[327]))))
  {
    error("error with send delete", sts);
  }
if(!(1&(sts = om$send(msg=&msg, senderid=oid[320], targetid=oid[320]))))
  {
    error("error with send delete", sts);
  }
/*********Delete coalscing with rear then front*************/
/****where rear free space does not point to front as next free*****/
if(!(1&(sts = om$send(msg=&msg, senderid=oid[326], targetid=oid[326]))))
  {
    error("error with send delete", sts);
  }
/**********Delete with no coalescing*********************/
if(!(1&(sts = om$send(msg=&msg, senderid=oid[346], targetid=oid[346]))))
  {
    error("error with send delete", sts);
  }
/**********Delete coalescing with front only*********************/
if(!(1&(sts = om$send(msg=&msg, senderid=oid[347], targetid=oid[347]))))
  {
    error("error with send delete", sts);
  }
/**********Delete coalescing with rear only*********************/
if(!(1&(sts = om$send(msg=&msg, senderid=oid[349], targetid=oid[349]))))
  {
    error("error with send delete", sts);
  }
/**********Delete coalescing with front then rear*********************/
if(!(1&(sts = om$send(msg=&msg, senderid=oid[348], targetid=oid[348]))))
  {
    error("error with send delete", sts);
  }
/**********Delete last obj of extent; free extent*********************/
if(!(1&(sts = om$send(msg=&msg, senderid=oid[345], targetid=oid[345]))))
  {
    error("error with send delete", sts);
  }
if(!(1&(sts = om$make_message(classname="Root",
				methodname="connect",
				size=sizeof(args),
				p_arglist=&args, p_msg=&msg) )))
  {
    error("error with make message", sts);
  }
for(i=4; i<10; i++)  /* i is oid being connected */
{
  cs_to.type = cs_fr.type = OM_e_name;
  cs_to.u_sel.name = cs_fr.u_sel.name = "g.many";
  args.to_sel = cs_to;
  args.to_indx = NULL;
  args.fr_objid = oid[i];
  args.fr_os = OM_Gw_current_OS;
  args.fr_sel = cs_fr;
  args.fr_indx = NULL;
  if(!(1&(sts = om$send(msg=&msg, senderid=NULL_OBJID, targetid=oid[100]))))
    {
      error("error with send connect", sts);
    }
}
if(!(1&(sts = om$make_message(classname="Root",
				methodname="disconnect",
				size=sizeof(args_d),
				p_arglist=&args_d, p_msg=&msg) )))
  {
    error("error with make message", sts);
  }
  args_d.to_sel = cs_to;
  args_d.fr_os = OM_Gw_current_OS;
  args_d.fr_sel = cs_fr;
 for(i=9; i>3; i--)  /* i is oid being connected */
 {
    args_d.fr_oid = oid[i];
  if(!(1&(sts = om$send(msg=&msg, senderid=NULL_OBJID, targetid=oid[100]))))
    {
      error("error with send disconnect", sts);
    }
  }		
exit();
};
