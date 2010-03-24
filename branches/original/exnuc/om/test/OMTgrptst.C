#include	"OMminimum.h"
#include 	"OMprimitives.h"
#include	"OMerrordef.h"
#include	"OMcluster.h"

/* define DBGPRT if want to see verbose printing */

/* #define	DBGPRT	1  */

main()
{
int		sts, i;
OM_S_NEIGHBOR	neighbor;
OM_S_MESSAGE	msg, passmsg, passargsmsg, transgrpmsg;
OMuint		flag=TRUE;
OM_S_OBJID	oid[350], grpoid, transgrpoid, grpoiderr;
static char	*OMparams[]={"DEFTRANS_GROUP_EXTOBJS=200", NULL};
OM_S_CHANSELECT	cs_to, cs_fr;
struct OM_sd_pass_args
{
  OM_p_MESSAGE	msg;
  OM_p_CLASSLIST classlist;
  OM_E_WRT_FLAG flag;
} pass_args;
OM_S_CLASSLIST	classlist;
OMuword		list[1];
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
struct OM_sd_GROUP_CONST_ARGS
{
  char	*groupname;
  int	init_count, extend_count;
  OMuword	clusternum;
}	initgrpargs;
struct	OM_sd_transgrpname_args
{
  char			*name;
  OM_p_OBJID		p_oid;
} transgrpname_args;


if(!(1&(sts = om$runtime_init(paramc=1, param_list=OMparams) )))
  {
    error("Run Time Init", sts);
  }

/* Construct a Group taking defaults */
#ifdef DBGPRT 
	printf("Construct a Group taking defaults.\n"); 
#endif
initgrpargs.clusternum=OM_K_NOTACLUSTER;
initgrpargs.extend_count=NULL;
initgrpargs.init_count=NULL;
initgrpargs.groupname=NULL;
if(!(1&(sts = om$make_message(classname="OMGroup",
				methodname="init_OMGroup",
				size=sizeof(initgrpargs),
				p_arglist=&initgrpargs,
				p_msg=&msg) )))
  {
    error("Make Message for construct group", sts);
  }
if(!(1&(sts = om$construct(classname="OMGroup",osnum=OM_Gw_current_OS,
		msg=&msg, p_objid=&grpoid) )))
  {
    error("Construct Group", sts);
  }

/* translate groupname to objid */

if(!(1&(sts = om$make_message(classname="OMObjSpace",
				methodname="translate_group_name",
				size=sizeof(transgrpname_args),
				p_arglist=&transgrpname_args,
				p_msg=&transgrpmsg) )))
  {
    error("Make Message for translate group name", sts);
  }
transgrpname_args.name = "group_0";
transgrpname_args.p_oid = &transgrpoid;
if(!(1&(sts = om$send(msg=&transgrpmsg, senderid=NULL_OBJID,
			targetid=OM_GO_current_OS_objid))))
  {
    error("Send to OSO translate group name", sts);
  }
#ifdef DBGPRT 
 printf("group_0 translated to group oid %u\n", transgrpoid); 
#endif
/* construct another group with group_0 name which is already in use */
#ifdef DBGPRT 
 printf("Construct another group with name already used: ERROR\n"); 
#endif
initgrpargs.groupname = "group_0";
if(OM_E_DUPGRPNAME != (sts = om$construct(classname="OMGroup",
				osnum=OM_Gw_current_OS,
				msg=&msg, p_objid=&grpoiderr) ))
  {
      error("Duplicate Group Name Error Did Not Fail\n"); 
  }

/* construct a bunch of g guys within new group */

#ifdef DBGPRT 
 printf("Construct 10 g objects in new group\n"); 
#endif
neighbor.groupid=grpoid;
neighbor.clusterid=NULL;

for(i=0; i<10; i++)
if(!(1&(sts = om$construct(classname="g", p_objid=&oid[i], neighbor=neighbor, osnum=OM_Gw_current_OS,) )))
  {
    error("Construct g", sts);
  }
if(!(1&(sts = om$make_message(classname="g",
				methodname="answer",
				p_msg=&passargsmsg) )))
  {
    error("Make Message for g.answer", sts);
  }
pass_args.msg = &passargsmsg;

/* Send all objects within new group; via pass to grpoid; answer message */
#ifdef DBGPRT 
 printf("Send via group pass g.answer to all objects in new group\n"); 
#endif
if(!(1&(sts = om$make_message(classname="OMGroup",
				methodname="pass",
				size=sizeof(pass_args),
				p_arglist=&pass_args,
				p_msg=&passmsg) )))
  {
    error("Make Message for OMGroup.pass", sts);
  }
pass_args.classlist = NULL;
pass_args.flag = OM_e_wrt_object;
if(!(1&(sts = om$send(msg=&passmsg, senderid=NULL_OBJID, targetid=grpoid))))
  {
    error("Send OMGroup.pass to all new group objects", sts);
  }

/* Send all g objects within new group; via pass to grpoid; answer message */

#ifdef DBGPRT 
 printf("Send via group pass g.answer to all g objects in new group\n"); 
#endif
pass_args.classlist = &classlist;
classlist.w_count=sizeof(list)/sizeof(OMuword);
classlist.w_flags=NULL;
classlist.p_classes=list;
if(!(1&(sts=om$get_classid(classname="g", p_classid=&(list[0])))))
  {
    error("Get Classid for group pass", sts);
  }
pass_args.flag = OM_e_wrt_object;
if(!(1&(sts = om$send(msg=&passmsg, senderid=NULL_OBJID, targetid=grpoid))))
  {
    error("Send OMGroup.pass to all new group g objects", sts);
  }

/*=======================================================*/
/* call maini to gain advantages of opp for rest of test */
/* test create cluster & translate cluster name          */
/*=======================================================*/

maini();

#ifdef	DBGPRT
printf("end of test\n");
#endif

exit();
};
