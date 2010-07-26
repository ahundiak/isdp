#include	"OMminimum.h"
#include 	"OMprimitives.h"
#include	"OMerrordef.h"
#include	"OMcluster.h"
#include	"OMmacros.h"

/* define DBGPRT if want to see verbose printing */
/* #define	DBGPRT	1  */

#define NUMGROUPS 7
#define NUMSUPGROUPS 4
#define error(errMsg, omsts) \
	{ \
	printf("%s\n", errMsg); \
        om$report_error(sts=omsts); \
	exit(); \
        }

main()
{
 int		sts, i, gg;
 OM_S_NEIGHBOR	neighbor;
 OM_S_MESSAGE	msg, supmsg, passmsg, addmsg, transgrpmsg, findmsg, remmsg;
 OM_S_OBJID	Aobjid, grpoids[NUMGROUPS], supgrpoids[NUMSUPGROUPS];
 OM_S_OBJID     tarGrpOid=NULL_OBJID, starSupGrpOid;
 static char	*OMparams[]={"DEFTRANS_GROUP_EXTOBJS=200", NULL};
 OM_S_CHANSELECT cs_to, cs_fr;

 struct OM_sd_pass_args
 {
  OM_S_MESSAGE	*msg;
  OM_p_CLASSLIST classlist;
  OM_E_WRT_FLAG flag;
 } pass_args, pass_args2;

 OM_S_MESSAGE pass_args_msg;

 OM_S_CLASSLIST	classlist;
 OMuword        list[1];

 struct OM_sd_GROUP_CONST_ARGS
 {
  char	*groupname;
  int	init_count, extend_count;
  OMuword	clusternum;
 }	initgrpargs;

 struct OM_sd_SUPGROUP_CONST_ARGS
 {
  char	*name;
 }	initsupgrpargs;

 struct
 {
  OM_S_OBJID oid;
 }	addmsgargs;

 struct
 {
  OM_S_OBJID oid;
 }	remmsgargs;

 struct 
 {
  char *name;
  OM_p_OBJID p_oid;
  int search;
 }	findmsgargs;

 struct	OM_sd_transgrpname_args
 {
  char		*name;
  OM_p_OBJID	p_oid;
 } transgrpname_args;

 struct
 {
  int *ans;
 } B_mess_args;
 int locAns=0;



 if (!(1&(sts = om$runtime_init(paramc=1, param_list=OMparams) )))
   error("Run Time Init", sts);

#ifdef DBGPRT 
  printf("Construct a Group taking defaults.\n"); 
#endif

 /* taking defaults for constructing groups */
 initgrpargs.clusternum=OM_K_NOTACLUSTER;
 initgrpargs.extend_count=NULL;
 initgrpargs.init_count=NULL;
 initgrpargs.groupname=NULL;
 if (!(1&(sts = om$make_message( classname="OMGroup",
	  			 methodname="init_OMGroup",
				 size=sizeof(initgrpargs),
				 p_arglist=&initgrpargs,
				 p_msg=&msg) )))
   error("Make Message for construct group", sts);


 /*==================================*/
 /* To construct NUMGROUPS of Groups */
 /*==================================*/
 for (gg=0; gg<NUMGROUPS; gg++){
   if (gg == 3)
     initgrpargs.groupname="myTarGroup";
   else
     if (gg == 1)
       initgrpargs.groupname="removeGroup";
     else
       initgrpargs.groupname=NULL;

   if (!(1&(sts = om$construct(classname="OMGroup",osnum=OM_Gw_current_OS,
		               msg=&msg, p_objid=&grpoids[gg]) )))
     error("Construct Group", sts);

   neighbor.groupid=grpoids[gg];
   neighbor.clusterid=NULL;

   if (gg == 1 || gg == 3){
     for (i=0; i<10; i++)
       if (!(1&(sts = om$construct(classname="B", p_objid=&Aobjid, neighbor=neighbor, osnum=OM_Gw_current_OS,) )))
         error("Construct B", sts);
   }
   else{
     for (i=0; i<10; i++)
       if (!(1&(sts = om$construct(classname="A", p_objid=&Aobjid, neighbor=neighbor, osnum=OM_Gw_current_OS,) )))
         error("Construct A", sts);
   }
 }

 if (!(1&(sts = om$make_message( classname="OMSupGroup",
	  			 methodname="init_OMSupGroup",
				 size=sizeof(initsupgrpargs),
				 p_arglist=&initsupgrpargs,
				 p_msg=&supmsg) )))
   error("Make Message for construct SupGroup", sts);

 /*========================================*/
 /* To construct NUMSUPGROUPS of SupGroups */
 /*========================================*/
 for (gg=0; gg<NUMSUPGROUPS; gg++){
   if (gg == 1)
     initsupgrpargs.name="starSupGrp";
   else
     initsupgrpargs.name=NULL;
   if (!(1&(sts = om$construct(classname="OMSupGroup",osnum=OM_Gw_current_OS,
		               msg=&supmsg, p_objid=&supgrpoids[gg])))){
     printf("gg: %d\n", gg);
     error("Something went wrong in creating SupGrp", sts);
   }
 }

 if (!(1&(sts = om$make_message( classname="OMSupGroup",
	  			 methodname="add_member",
				 size=sizeof(addmsgargs),
				 p_arglist=&addmsgargs,
				 p_msg=&addmsg) )))
   error("Make Message for SupGroup.add_member", sts);

 addmsgargs.oid=supgrpoids[0];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[2]))))
   error("Send OMSupGroup.add_member to add SupGroup0 to SupGroup2", sts);

 addmsgargs.oid=supgrpoids[1];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[2]))))
   error("Send OMSupGroup.add_member to add SupGroup1 to SupGroup2", sts);

 addmsgargs.oid=supgrpoids[1];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[0]))))
   error("Send OMSupGroup.add_member to add SupGroup1 to SupGroup0", sts);

 addmsgargs.oid=grpoids[0];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[0]))))
   error("Send OMSupGroup.add_member to add group0 to SupGroup0", sts);

 addmsgargs.oid=grpoids[1];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[0]))))
   error("Send OMSupGroup.add_member to add group1 to SupGroup0", sts);

 addmsgargs.oid=grpoids[2];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[1]))))
   error("Send OMSupGroup.add_member to add group2 to SupGroup1", sts);

 addmsgargs.oid=grpoids[3];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[1]))))
   error("Send OMSupGroup.add_member to add group3 to SupGroup1", sts);

 addmsgargs.oid=grpoids[4];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[2]))))
   error("Send OMSupGroup.add_member to add group4 to SupGroup1", sts);

/*=================================================================*/
/* Send via SupGroup.pass A.answer to all objects under SupGroup2. */
/*=================================================================*/
 if (!(1&(sts = om$make_message(classname="OMSupGroup",
				methodname="pass",
				size=sizeof(pass_args),
				p_arglist=&pass_args,
				p_msg=&passmsg) )))
   error("Make Message for OMSupGroup.pass", sts);

 if (!(1&(sts = om$make_message( classname="A",
				methodname="answer",
				p_msg=&pass_args_msg) )))
   error("Make Message for A.answer", sts);

#ifdef DBGPRT 
 printf("Send via SupGroup pass A.answer to all A objects under SupGroup2\n"); 
#endif

 pass_args.msg = &pass_args_msg;
 pass_args.classlist = NULL;
 pass_args.flag = OM_e_wrt_object;

 if (!(1&(sts = om$send(msg=&passmsg, senderid=NULL_OBJID, targetid=supgrpoids[2]))))
   error("Send OMSupGroup.pass to all SupGroup2", sts);

#ifdef DBGPRT 
  printf("Send B.answer via SupGroup pass with classlist to all B objects under SupGroup2\n"); 
#endif

 if (!(1&(sts = om$make_message( classname="B",
				methodname="answer",
				size=sizeof(B_mess_args),
                                p_arglist=&B_mess_args,
				p_msg=&pass_args_msg) )))
   error("Make Message for B.answer", sts);

 B_mess_args.ans = &locAns;
 pass_args.msg = &pass_args_msg;
 pass_args.classlist = &classlist;
 classlist.w_count=sizeof(list)/sizeof(OMuword);
 classlist.w_flags=NULL;
 classlist.p_classes=list;
 if (!(1&(sts=om$get_classid(classname="B", p_classid=&(list[0])))))
   error("Get Classid of B for SupGroup pass", sts);

 pass_args.flag = OM_e_wrt_object;
 if (!(1&(sts = om$send(msg=&passmsg, senderid=NULL_OBJID, targetid=supgrpoids[2]))))
   error("Send OMSupGroup.pass to SupGroup2", sts);

 addmsgargs.oid=grpoids[5];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[3]))))
   error("Send OMSupGroup.add_member to add group5 to SupGroup3", sts);

 addmsgargs.oid=grpoids[6];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[3]))))
   error("Send OMSupGroup.add_member to add group6 to SupGroup3", sts);

 addmsgargs.oid=supgrpoids[2];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[3]))))
   error("Send OMSupGroup.add_member to add SupGroup2 to SupGroup3", sts);

 addmsgargs.oid=supgrpoids[0];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[3]))))
   error("Send OMSupGroup.add_member to add SupGroup0 to SupGroup3", sts);

#ifdef DBGPRT
 printf("To add a new member which will result in a cycle \n");
#endif

 printf("Send OMSupGroup.add_member to add SupGroup3 to SupGroup1.\n");
 addmsgargs.oid=supgrpoids[3];
 if (!(1&(sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[1]))))
   if (sts == OM_E_CYCLEINSUPGROUP)  
     printf("--resulted in a cycle in the SupGroup graph\n");
   else
     om$report_error(sts=sts); 

if (!(1&(sts = om$make_message(classname="OMSupGroup",
				methodname="find",
				size=sizeof(findmsgargs),
				p_arglist=&findmsgargs,
				p_msg=&findmsg) )))
  error("Make Message for OMSupGroup.find", sts);

#ifdef DBGPRT
 printf("To find a member by using its name.\n");
#endif

 findmsgargs.name = "myTarGroup";
 findmsgargs.p_oid = &tarGrpOid;
 findmsgargs.search = 1;
 if (!(1&(sts = om$send(msg=&findmsg, senderid=NULL_OBJID, targetid=supgrpoids[3])))){
   printf("Send OMSupGroup.find to search for myTarGroup\n");
   om$report_error(sts=sts);
 }
 else{
   if (IF_EQ_OBJID(tarGrpOid, NULL_OBJID))
     printf("\n!!!!!! The member group, myTarGroup, is not found !!!!!!\n");
   else
     printf("\n--The member group, myTarGroup, is found\n\n");
 }

#ifdef DBGPRT
 printf("To remove a member.\n");
#endif

 if (!(1&(sts = om$make_message(classname="OMSupGroup",
				methodname="remove_member",
				size=sizeof(remmsgargs),
				p_arglist=&remmsgargs,
				p_msg=&remmsg) )))
   error("Make Message for OMSupGroup.remove_member", sts);

 remmsgargs.oid = grpoids[1];
 if (!(1&(sts = om$send(msg=&remmsg, senderid=NULL_OBJID, targetid=supgrpoids[0])))){
   printf("\nSend OMSupGroup.remove_member to remove the group1 from SupGroup0\n", grpoids[1]);
   om$report_error(sts=sts);
 }

#ifdef DBGPRT
 printf("To find the just deleted member.\n");
#endif

 findmsgargs.name = "removeGroup";
 findmsgargs.p_oid = &tarGrpOid;
 findmsgargs.search = 1;
 if (!(1&(sts = om$send(msg=&findmsg, senderid=NULL_OBJID, targetid=supgrpoids[3])))){
   printf("\nSend OMSupGroup.find to search for the removeGroup\n");
   om$report_error(sts=sts);
 }
 else{
   if (IF_EQ_OBJID(tarGrpOid, NULL_OBJID))
     printf("--The member group1 has been deleted.\n\n");
   else
     printf("Something went wrong in the previous remove_member operation.\n");
 }

#ifdef DBGPRT
 printf("To remove the just deleted member.\n");
#endif

 printf("To send OMSupGroup.remove_member to disconnect the group1 from SupGroup0.\n");
 remmsgargs.oid = grpoids[1];
 sts = om$send(msg=&remmsg, senderid=NULL_OBJID, targetid=supgrpoids[0]);
 if (sts == OM_W_NOSUCHMEMBER)
   printf("--no such member exists in the SupGroup\n\n");
 else
   printf("!!!!!! Failed to test out deleting non-existing member!!!!!!\n\n");

 printf("To add an A object to the SupGroup2.\n");
 if (!(1&(sts = om$construct(classname="A", p_objid=&Aobjid, neighbor=neighbor, osnum=OM_Gw_current_OS,) )))
   error("construct an A object", sts);

 addmsgargs.oid=Aobjid;
 sts = om$send(msg=&addmsg, senderid=NULL_OBJID, targetid=supgrpoids[2]);
 if (sts == OM_E_NOSUCHCLASS)
   printf("--The A class is not on the legal class list\n\n");
 else
   om$report_error(sts=sts);

#ifdef DBGPRT
 printf("To construct a SupGroup with an existing name.\n");
#endif

 printf("Construct a SupGroup with the name of starSupGrp.\n");
 initsupgrpargs.name="starSupGrp";
 sts = om$construct(classname="OMSupGroup",osnum=OM_Gw_current_OS,
		               msg=&supmsg, p_objid=&starSupGrpOid);
 if (sts == OM_E_DUPGRPNAME)
   printf("--The name is already in use\n\n");
 else
   printf("\n!!!!!! Fail to check out the duplicate name. !!!!!!\n");

 printf("To make a pass pass.\n");
 if (!(1&(sts = om$make_message(classname="OMSupGroup",
				methodname="pass",
				size=sizeof(pass_args2),
				p_arglist=&pass_args2,
				p_msg=&pass_args_msg) )))
   error("Make Message for OMSupGroup.pass", sts);

 pass_args2.msg = &pass_args_msg;

 sts = om$send(msg=&passmsg, senderid=NULL_OBJID, targetid=supgrpoids[2]);
 if (sts == OM_E_NOPASSPASS)
   printf("--It's illegal to make a pass pass\n");
 else
   printf("\n!!!!!! Fail to test out the PASSPASS case. !!!!!!\n");
}

