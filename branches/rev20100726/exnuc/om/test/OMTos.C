#define MAXOS 2
#define MAXA  3
#define MAXB  3

/* this file contains the includes and externs for the test routine */
#define report_result(RESULT,MESSAGE)	if(sts != RESULT)\
{\
printf("Error in test. Status reported as %X should have been %X\n",\
	sts,RESULT);\
printf("What was being attempted:");\
printf(MESSAGE);printf("\n");\
printf("Description of what was returned follows:\n");\
som_report_error(sts); }

#include <stdio.h>
#include "OMintprims.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmetaclass.h"
#include "OMparameters.h"

/* these are macros for commonly used functions */

/* constucting an object space */

#define TRANS	OM_K_OMTRANSOS_ACTCLASSID
#define FILED	OM_K_OMFILEDOS_ACTCLASSID

#define CONSTRUCT_OS(TYPE,NAME,OSNUM)  \
{	sts = om$construct_os(classid=TYPE, \
	 		    osnum = OSNUM, \
			    resultcount=NULL, \
			    p_objid = &f_objid, \
			    osname= NAME); \
	if((sts != OM_S_SUCCESS) && (sts != OM_I_READ_FROM_FILE))\
	report_result(OM_S_SUCCESS,"normal os construct"); }


/*.. construct a cluster .. */

#define CONSTRUCT_CL(OSNUM,CLS_NUM,OBJID) \
{	init_cluster_arg.cluster_num = CLS_NUM; \
	sts = om$construct(classname = "OMCluster",osnum = OSNUM, \
		    msg = &init_cluster_msg, p_objid = OBJID); \
	report_result(OM_S_SUCCESS,"Tried to construct a cluster .."); }

/*.. construct a group .. */

char *groupname;
int init_count, extend_count;
OMuword clusternum;

#define CONSTRUCT_GR(OSNUM,OBJID) \
{	sts = om$construct(classname = "OMGroup",osnum = OSNUM, \
		    msg = &init_group_msg, p_objid = OBJID); \
	report_result(OM_S_SUCCESS,"Tried to construct a cluster .."); }

/* construct object */

#define GRP_DEF  1
#define CLS_DEF  0
#define CONSTRUCT_OB(CLASS,OSNUM,CLS_NUM,GRP_NUM,OBJID) \
{	neighbor.groupid = GRP_NUM; \
	neighbor.clusterid = CLS_NUM; \
		sts = om$construct(classname=CLASS,osnum = OSNUM, \
		p_objid=OBJID,neighbor = neighbor); \
		if(!(1&sts))  \
		  report_result(OM_S_SUCCESS," CLASS object construct"); }

/* write an object space .. */

#define OSWRITE(NAME,OSNUM) \
{ write_arg.new_osname = NAME; \
  printf("writing out to a new os \"%s\" \n",write_arg.new_osname); \
	sts = om$send(msg = &write_msg, \
			targetid = 0, \
			targetos = OSNUM); \
	report_result(OM_S_SUCCESS,"normal write attempt..");}


/* delete an object space .. */

#define DELETE_OS(OSNUM) \
{  	sts = om$send(msg = &deleteos_msg, \
			targetid = 0, \
			targetos = OSNUM); \
	report_result(OM_S_SUCCESS,"normal os delete");}


/* delete a cluster */

#define REMOVE_CL(OSNUM,OBJID) \
{  sts = om$send(targetid=OBJID, \
		  targetos = OSNUM, \
		  msg = &cl_remove_msg); \
  report_result(OM_S_SUCCESS,"Tried to remove a cluster ..");}

#define REMOVE_GR(OSNUM,OBJID) \
{  sts = om$send(targetid=OBJID, \
		  targetos = OSNUM, \
		  msg = &gr_remove_msg); \
  report_result(OM_S_SUCCESS,"Tried to remove a group ..");}

/* merge two clusters */
#define MERGE_CL(OSNUM,FROM,TO) \
{ cl_merge_arg = TO; \
  sts= om$send(targetid=FROM,targetos=OSNUM,msg=&cl_merge_msg); \
  report_result(OM_S_SUCCESS,"Tried to merge clusters "); }

/* merge two groups */
#define MERGE_GR(OSNUM,FROM,TO) \
{ gr_merge_arg = TO; \
  sts= om$send(targetid=FROM,targetos=OSNUM,msg=&gr_merge_msg); \
  report_result(OM_S_SUCCESS,"Tried to merge clusters "); }

/* connect two objects */

#define CONNECT(OSNUM1,OBJID1,CHAN1,OSNUM2,OBJID2,CHAN2) \
{ a_chan.type = OM_e_name; \
  a_chan.u_sel.name = CHAN1; \
  b_chan.type = OM_e_name; \
  b_chan.u_sel.name = CHAN2; \
  connect_arg.to_sel = a_chan; \
  connect_arg.fr_sel = b_chan; \
  connect_arg.fr_os = OSNUM2; \
  connect_arg.fr_objid = OBJID2; \
  sts =  om$send(targetos=OSNUM1, \
		   msg=&connect_msg,targetid=OBJID1); \
	if(!(sts&1))printf("MAIN-- failed to connect osnum/oid %d/%d to %d/%d \n", \
	OSNUM1,OBJID1,OSNUM2,OBJID2);\
	 report_result(OM_S_SUCCESS,"connect attempt");}


/* disconnect two objects */

#define DISCONNECT(OSNUM1,OBJID1,CHAN1,OSNUM2,OBJID2,CHAN2) \
{ a_chan.type = OM_e_name; \
  a_chan.u_sel.name = CHAN1; \
  b_chan.type = OM_e_name; \
  b_chan.u_sel.name = CHAN2; \
  disconnect_arg.to_sel = a_chan; \
  disconnect_arg.fr_sel = b_chan; \
  disconnect_arg.fr_os = OSNUM2; \
  disconnect_arg.fr_objid = OBJID2; \
  sts =  om$send(targetos=OSNUM1, \
		   msg=&disconnect_msg,targetid=OBJID1); \
	if(sts != 1)printf("MAIN-- failed to disconnect osnum/oid %d/%d to %d/%d \n", \
	OSNUM1,OBJID1,OSNUM2,OBJID2);\
	 report_result(OM_S_SUCCESS,"disconnect attempt");}

/* define a disconnect that should fail...*/

#define DISCONNECTF(OSNUM1,OBJID1,CHAN1,OSNUM2,OBJID2,CHAN2) \
{ a_chan.type = OM_e_name; \
  a_chan.u_sel.name = CHAN1; \
  b_chan.type = OM_e_name; \
  b_chan.u_sel.name = CHAN2; \
  disconnect_arg.to_sel = a_chan; \
  disconnect_arg.fr_sel = b_chan; \
  disconnect_arg.fr_os = OSNUM2; \
  disconnect_arg.fr_objid = OBJID2; \
  sts =  om$send(targetos=OSNUM1, \
		   msg=&disconnect_msg,targetid=OBJID1); \
	if(sts != OM_W_NOTONCHAN)\
	  printf("MAIN-- failed to disconnect osnum/oid %d/%d to %d/%d \n", \
	OSNUM1,OBJID1,OSNUM2,OBJID2);\
	 report_result(OM_W_NOTONCHAN,"disconnect attempt which should fail");}

/*  delete an object */
#define  DELETE_OB(OSNUM,OBJID) \
	{sts = om$send(msg = &delete_msg,targetos=OSNUM,targetid=OBJID); \
	report_result(OM_S_SUCCESS,"normal object delete");}

#define SET_STATE(OSNUM,STATE)\
	{set_state_arg = STATE;\
	 om$send(targetos = OSNUM, targetid = 0, msg = &set_state_msg);\
 	report_result(OM_S_SUCCESS,"normal set state attempt");}
	 
/*********************************** beginning of program *******/
main(argc,argv)
int argc;
char *argv[];
{
int sts,ii,write_sts,tot_objects;
char	*descript[20],msg_buffer[100];
int cond[11],buffer_cond[11];
int a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,before1,before2,before3,before;
long time(),tod;

int delete_flag,intcount,extcount;
char osname[OM_K_MAXOSNAME_LEN],osname_tst[OM_K_MAXOSNAME_LEN];
char osname_toolong[OM_K_MAXOSNAME_LEN+1];
char *ptr;

OM_S_OBJID	f_objid;
OMuint resultcount;
OM_S_NEIGHBOR  neighbor;

/******************** declarations for the messages *******/
/* this file contains the declarations appropriate for the messages */

int assign_a_arg,delete_arg,deleteos_arg,assign_b_arg,set_state_arg;
OMuword cl_merge_arg;
OM_S_OBJID gr_merge_arg;

OM_S_MESSAGE	write_msg,assign_a_msg,show_a_msg,pass_thru_msg,
		get_OS_list_msg,deleteos_msg,delete_msg,debug_msg,
		ch_send_a_msg,connect_msg,assign_b_msg,pass_msg,group_pass_msg,
		init_cluster_msg,cl_remove_msg,cl_merge_msg,set_state_msg,
		gr_merge_msg,gr_remove_msg,init_group_msg,disconnect_msg;


struct {
OM_S_CHANSELECT to_sel;
OM_S_OBJID fr_objid;
OMuword fr_os;
OM_S_CHANSELECT fr_sel;
} disconnect_arg;

struct {
char *groupname;
int init_count, extend_count;
OMuword clusternum;
} init_group_arg;

struct {
char *new_osname;
} write_arg;

struct {
OMuword *cluster_num;
} init_cluster_arg;

struct {
OM_S_CHANSELECT to_sel;
int to_idx;
OM_S_OBJID fr_objid;
OMuword fr_os;
OM_S_CHANSELECT fr_sel;
int fr_idx; }
connect_arg;

struct {
int size;
int *count;
OMuword 	*OSnumbers;
OM_S_OBJID 	*OSoids;
} get_OS_list_arg;

struct {
OM_S_CLASSLIST *classlist;
OM_E_WRT_FLAG   wrt_flag;
OM_S_MESSAGE	msg;
} pass_thru_arg,pass_arg;

struct {
OM_E_WRT_FLAG   wrt_flag;
OM_S_CLASSLIST *classlist;
OM_S_MESSAGE	msg;
} group_pass_arg;

char **override;
OM_S_OBJID a_objid[10],b_objid[10],cluster_objid[10],group_objid[10];
OMuword cluster_num[10];

OM_S_CHANSELECT a_chan,b_chan;
int saved_osnum,osnum[OM_K_MAXOSNUMBER],my_id;
if(!(1&(sts = om$runtime_init())))
  om$report_error(sts=sts);
else
{
if(argc > 1){
 printf("Runtime init successful... \n");
}
}

/* definitions for all the messages we will use.. */
/* this file contains the message definitions .. */

#define pass_thru(MSG) { pass_thru_arg.msg = MSG;\
pass_thru_arg.wrt_flag = OM_e_wrt_object;\
pass_thru_arg.classlist = NULL;\
sts=om$send(msg=&pass_thru_msg,senderid=NULL,targetid=OM_GO_current_MOSD,\
targetos=0);}

#define pass(MSG,OSNUM) { pass_arg.msg = MSG;\
pass_arg.wrt_flag = OM_e_wrt_object;\
pass_arg.classlist = NULL;\
sts=om$send(msg=&pass_msg,senderid=NULL,targetid=0,targetos=OSNUM);}

#define group_pass(MSG,OSNUM) { group_pass_arg.msg = MSG;\
group_pass_arg.wrt_flag = OM_e_wrt_object;\
group_pass_arg.classlist = NULL;\
sts=om$send(msg=&group_pass_msg,senderid=NULL,targetid=2,targetos=OSNUM);}

 om$make_message (classname = "OMObjSpace",methodname="pass",
		  size = sizeof(pass_msg),p_arglist=&pass_arg,
		  p_msg = &pass_msg);

 om$make_message (classname = "OMFiledOS",methodname="delete",size=4,
		  p_arglist = &deleteos_arg, p_msg = &deleteos_msg);

 om$make_message (classname = "Root",methodname="connect",
		  size=sizeof(connect_arg),
		  p_arglist = &connect_arg,p_msg = &connect_msg);

 om$make_message (classname = "Root",methodname="disconnect",
		  size=sizeof(disconnect_arg),
		  p_arglist = &disconnect_arg,p_msg = &disconnect_msg);

 om$make_message (classname = "Root",methodname="delete",size=4,
		  p_arglist = &delete_arg,p_msg = &delete_msg);

 om$make_message (classname = "Root",methodname="debug", p_msg = &debug_msg);

 om$make_message (classname = "OMgroup",methodname="pass",
		  p_msg=&group_pass_msg);

 sts = om$make_message( classname = "OMCluster", methodname = "merge",
			p_arglist = &cl_merge_arg, p_msg = &cl_merge_msg,
			size = sizeof(cl_merge_arg) );

 sts = om$make_message( classname = "OMCluster",methodname = "remove",
			p_msg = &cl_remove_msg);

 report_result(OM_S_SUCCESS,"attempted to make a cluster remove message ");

 sts = om$make_message( classname = "OMGroup",methodname = "remove",
			p_msg = &gr_remove_msg);

 report_result(OM_S_SUCCESS,"attempted to make a group remove message ");

 sts = om$make_message( classname = "OMGroup", methodname = "merge",
			p_arglist = &gr_merge_arg, p_msg = &gr_merge_msg,
			size = sizeof(gr_merge_arg) );

 om$make_message (classname = "OMCluster",
		  methodname = "init_OMCluster",
		  size = sizeof(init_cluster_arg),
		  p_arglist = &init_cluster_arg,
		  p_msg = &init_cluster_msg);

/* use the defaults in the group construction .. */
	init_group_arg.groupname = NULL;
	init_group_arg.init_count = init_group_arg.extend_count = NULL;
	init_group_arg.clusternum = NULL;
 om$make_message (classname = "OMGroup",
		  methodname = "init_OMGroup",
		  size = sizeof(init_group_arg),
		  p_arglist = &init_group_arg,
		  p_msg = &init_group_msg);

 sts = om$make_message ( classname="A",
                         methodname="assign_a",
                         size=sizeof(int),
                         p_arglist=&assign_a_arg,
                         p_msg    =&assign_a_msg);

 report_result(OM_S_SUCCESS,"tried to make an assign a messsage");

 sts = om$make_message ( classname="B",
                         methodname="assign_b",
                         size=sizeof(int),
                         p_arglist=&assign_b_arg,
                         p_msg    =&assign_b_msg);

 report_result(OM_S_SUCCESS,"tried to make an assign b messsage");

 sts = om$make_message ( classname = "A",
                   methodname= "show_a",
                   p_msg     = &show_a_msg); 

 report_result(OM_S_SUCCESS,"tried to make a show a messsage");

 sts = om$make_message ( classname = "A",
                   methodname= "ch_send_a",
                   p_msg     = &ch_send_a_msg); 


 sts = om$make_message ( classname = "OMMOSD",
		   methodname= "pass_thru",
 		   p_msg     = &pass_thru_msg,
		   p_arglist = &pass_thru_arg);

 report_result(OM_S_SUCCESS,"tried to make a pass through messsage");

get_OS_list_arg.size = 32;
get_OS_list_arg.count = (int *) malloc(4);
get_OS_list_arg.OSnumbers = (OMuword *)    malloc (32*sizeof(OMuword));
get_OS_list_arg.OSoids    = (OM_S_OBJID *) malloc (32*sizeof(OM_S_OBJID));


 sts = om$make_message ( classname = "OMMOSD",
		   methodname= "get_OS_list",
 		   p_msg     = &get_OS_list_msg,
		   p_arglist = &get_OS_list_arg );

om$make_message(classname = "OMFiledOS", methodname="write",
			size = sizeof(write_arg),
			p_arglist=&write_arg,p_msg = &write_msg);

report_result(OM_S_SUCCESS,"os write message construct");

om$make_message(classname = "OMFiledOS", methodname="set_state",
			size = sizeof(set_state_arg),
			p_arglist=&set_state_arg,p_msg = &set_state_msg);

/* this is the code for the regression tests for an os.. */

if(argc > 1){
printf("Testing the object space name ... \n");
}

/* pass a null string as the name */
	sts = om$construct_os(classid=OM_K_OMTRANSOS_ACTCLASSID,
			      p_objid=&f_objid,
			      osnum = &osnum[0],
			      osname = "");
	report_result(OM_E_NULL_STRING,"Null string as name");

if(argc > 1){
printf(" pass the longest name allowed\n");
}

	for(i=0; i<OM_K_MAXOSNAME_LEN-1; i++) osname[i] = 'X';
        osname[OM_K_MAXOSNAME_LEN-1] = '\0';
	sts = om$construct_os(classid=OM_K_OMTRANSOS_ACTCLASSID,
			      p_objid=&f_objid,
			      osnum  = &osnum[0],
			      osname = osname);

	report_result(OM_S_SUCCESS,"Longest allowable name");

if(argc > 1){
printf("Attempt to create os with duplicate name \n");
}
	sts = om$construct_os(classid=OM_K_OMTRANSOS_ACTCLASSID,
			      p_objid=&f_objid,
			      osnum  = &osnum[0],
			      osname = osname);

	report_result(OM_W_OBJSPACE_EXISTS,"Object space exists");

/* get rid of the one we have so far.. */

	DELETE_OS(osnum[0]);

if(argc > 1){
printf(" pass a name longer than the one allowed\n");
}

	for(i=0; i<=OM_K_MAXOSNAME_LEN; i++) osname_toolong[i] = 'X';
        osname_toolong[OM_K_MAXOSNAME_LEN] = '\0';
	sts = om$construct_os(classid = OM_K_OMTRANSOS_ACTCLASSID,
			      p_objid = &f_objid,
			      osnum   = &osnum[0],
			      osname  = osname_toolong);

	report_result(OM_E_NAMETOOLONG,"Name too long");

if(argc > 1){
printf(" create the maximum number and try to add one more \n");
}

	for(i=0; i< OM_K_MAXOSNUMBER - 2; i++)
	{
	   sprintf(osname,"OS%d",i);
	   CONSTRUCT_OS(TRANS,osname,&osnum[i]);
	}

/* this one should blow up */
	sprintf(osname,"OSblow up");
	sts = om$construct_os(classid = OM_K_OMTRANSOS_ACTCLASSID,
			      p_objid=&f_objid,
				 osnum   = &osnum[0],
				 osname  = osname);
	report_result(OM_E_NO_OS_AVAIL,"Should be out of OS slots");

if(argc > 1){
printf(" delete the ones we created to free up the slots..\n");
}

	for(i=0; i<OM_K_MAXOSNUMBER-2; i++)
	   DELETE_OS(osnum[i]);

if(argc > 1){
printf(" to be sure that they were all deleted, try to create the maximum \n");
printf(" number again \n");
}

	for(i=0; i< OM_K_MAXOSNUMBER-2; i++)
	{
	   sprintf(osname,"OS%d",i);
	   CONSTRUCT_OS(TRANS,osname,&osnum[i]);
	}
	
if(argc > 1) printf(" I'm convinced. Delete them all again \n");

	for(i=0; i<OM_K_MAXOSNUMBER-2; i++)
	   DELETE_OS(osnum[i]);

if(argc > 1) printf(" try to use the construct_os_by_name routine \n");
	
	sts = om$construct_os(classname = "OMTransOS",
			      p_objid=&f_objid,
			      osnum     = &osnum[0],
			      osname    = "ghgh");

	report_result(OM_S_SUCCESS,"Normal OS construct attempt ");

/* delete that one */

	DELETE_OS(osnum[0]);

if(argc > 1) printf(" Try to construct one with a bad classname \n");

	sts = om$construct_os(classname = "badclassname",
			      p_objid=&f_objid,
			      osnum     = &osnum[0],
			      osname    = "ghgh");

        report_result(OM_E_BADCLASSNAME,
		"tried to construct os with bad classname");

if(argc > 1) printf(" construct one with a bad classid. Give it Root\n");

	sts = om$construct_os(classid   = OM_K_ROOT_ACTCLASSID,
			      p_objid=&f_objid,
			      osnum     = &osnum[0],
			      osname    = "ghgh");

        report_result(OM_E_BADCLASSNAME,
		"tried to construct os with bad classname");
	
if(argc > 1) printf(" Try to construct an os of type OMObjSpace. \n");

	sts = om$construct_os(classname = "OMObjSpace",
			      p_objid=&f_objid,
			      osnum     = &osnum[0],
			      osname    = "ghgh");

        report_result(OM_E_BADCLASSNAME,
		"tried to construct os with bad classname");

if(argc > 1){
printf(" make sure that existing os number is preserved before and after a\n");
printf(" construct. Try it with transos first \n");
}

	saved_osnum = OM_Gw_current_OS;

	CONSTRUCT_OS(TRANS,"GHGH",&osnum[0]);

	if(saved_osnum != OM_Gw_current_OS)
	{
	   printf("Error is test. Current OS number was not preserved \n");
	   printf("after a construct of a transient os \n");
	}

	DELETE_OS(osnum[0]);

if(argc > 1)printf(" now try that with a new and existing filed os \n");

	saved_osnum = OM_Gw_current_OS;

	strcpy(osname,"FOSRGRTEST");

/*.. insure that the file is not already out there .. */

	sprintf(msg_buffer,"rm %s 2>1 >/dev/null ",osname);
	system(msg_buffer);

	CONSTRUCT_OS(FILED,osname,&osnum[0]);

	if(saved_osnum != OM_Gw_current_OS)
	{
	   printf("Error is test. Current OS number was not preserved \n");
	   printf("after a construct of a new filed os \n");
	}

if(argc > 1) printf("allow  os to be written out .. \n");

	DELETE_OS(osnum[0]);
	if(saved_osnum != OM_Gw_current_OS)
	{
	   printf("Error is test. Current OS number was not preserved \n");
	   printf("after a construct of a new filed os \n");
	}

if(argc >1)
    printf("now reconstruct to make sure that we have the same current os\n");

	sts = om$construct_os(classid=OM_K_OMFILEDOS_ACTCLASSID,
			   osnum  = &osnum[0],
			   osname = osname,
			   p_objid= &f_objid);

	report_result(OM_I_READ_FROM_FILE,"Reconstructing filed os ");

	if(saved_osnum != OM_Gw_current_OS)
	{
	   printf("Error is test. Current OS number was not preserved \n");
	   printf("after a construct of a new filed os \n");
	}

/* delete and get rid of the os */
	
	DELETE_OS(osnum[0]);

	system(msg_buffer);

if(argc > 1)
printf(" try out the various support routines such as change os name, \n");


	CONSTRUCT_OS(TRANS,"GHGH",&osnum[0]);

if(argc > 1){
printf("use os name to number to  see if we get back the same number as\n");
printf(" the one returned from construct\n");
}

	sts = om$os_name_to_number(osname = "GHGH",p_osnum = &saved_osnum);
	report_result(OM_S_SUCCESS,"Tried converting os name to number");

	if(saved_osnum != osnum[0])
	{
		printf("Error in os_name_to_number. returned osnum not the\n");
		printf("same as the one returned from construct \n");
	}

if(argc > 1){
printf("See if we can feed that number back in and get back\n");
printf(" the original os name\n");
}
	sts = om$os_number_to_name(osnum = saved_osnum, osname = osname_tst);
	report_result(OM_S_SUCCESS,"Tried converting os number to name");

	if(strncmp(osname_tst,"GHGH",OM_K_MAXOSNAME_LEN))
	     printf("Error in os_number_to_name. Returned name incorrect\n");


if(argc > 1)
 printf(" now try using the internal name. first get the internal name \n");

	sts = om$os_number_to_internal_name(
		osnum = osnum[0], osname = osname_tst);
	report_result(OM_S_SUCCESS,
		"Tried converting os number to internal name");

if(argc > 1) printf(" now see if we get back the original os number \n");

	sts = om$os_internal_name_to_number(
		osname = osname_tst,p_osnum = &saved_osnum);
	report_result(OM_S_SUCCESS,
		"Tried converting internal os name to number");

	if(saved_osnum != osnum[0])
	{
	   printf("Error in internal_os_name_to_number. returned osnum not\n");
	   printf("the same as the one returned from construct \n");
	}

if(argc > 1) printf(" now lets see how well the change os name works. \n");

	sts = om$change_os_name(osnum=osnum[0],
				new_osname="Fred",
				overwrite=0);
	report_result(OM_S_SUCCESS,"Tried to change os name \n");

if(argc > 1) printf(" see if the old name is still around \n");

	sts = om$os_name_to_number(osname = "GHGH",p_osnum = &saved_osnum);
	report_result
	   (OM_E_NOSUCHOS,"Tried converting illegal name to number\n");

if(argc > 1)
printf("change name to number to see if the new name is the same os as old\n");

	sts = om$os_name_to_number(osname = "Fred",p_osnum = &saved_osnum);
	report_result(OM_S_SUCCESS,"Tried converting os name to number");

	if(saved_osnum != osnum[0])
	{
		printf("Error in os_name_to_number after change_os_name.\n");
		printf("OS number returned not the same as the original\n");
	}

	DELETE_OS(osnum[0]);

if(argc > 1) printf("Now for some iso connection tests.. \n");

/* start simple */

	CONSTRUCT_OS(TRANS,"Trans0",&osnum[0]);
	CONSTRUCT_OS(TRANS,"Trans1",&osnum[1]);

        CONSTRUCT_OB("A",osnum[0],CLS_DEF,GRP_DEF,&a_objid[0]);
        CONSTRUCT_OB("B",osnum[1],CLS_DEF,GRP_DEF,&b_objid[0]);

        CONNECT   (osnum[1],b_objid[0],"bcca",osnum[0],a_objid[0],"acany");
        DISCONNECT(osnum[1],b_objid[0],"bcca",osnum[0],a_objid[0],"acany");

	DELETE_OS(osnum[0]);
	DELETE_OS(osnum[1]);

if(argc > 1) printf("have a filed to trans connection \n");

	system("rm Filed0 2>1 1>/dev/null");

	CONSTRUCT_OS(FILED,"Filed0",&osnum[0]);
	CONSTRUCT_OS(TRANS,"Trans1",&osnum[1]);

        CONSTRUCT_OB("A",osnum[0],CLS_DEF,GRP_DEF,&a_objid[0]);
        CONSTRUCT_OB("B",osnum[1],CLS_DEF,GRP_DEF,&b_objid[0]);

        CONNECT   (osnum[1],b_objid[0],"bcca",osnum[0],a_objid[0],"acany");

	DELETE_OS(osnum[0]);

	sts = om$construct_os(classid=OM_K_OMFILEDOS_ACTCLASSID,
			      osname = "Filed0",
			      osnum  = &osnum[0],
			      p_objid=&f_objid);

	report_result(OM_I_READ_FROM_FILE,"Reconstrucing a filed os ");

if(argc  > 1) printf("the connection should have been dissolved. \n");

        DISCONNECTF(osnum[1],b_objid[0],"bcca",osnum[0],a_objid[0],"acany");

	DELETE_OS(osnum[0]);
	DELETE_OS(osnum[1]);
	system("rm Filed0 2>1 1>/dev/null");

if(argc > 1) printf("Now have more OS's, objects and more connections \n");

	for(i=0; i<MAXOS; i+=2)
	{
	  sprintf(osname,"Trans%d",i);
	  CONSTRUCT_OS(TRANS,osname,&osnum[i]);
	  for(j=0; j<MAXA; j++)
          CONSTRUCT_OB("A",osnum[i],CLS_DEF,GRP_DEF,&a_objid[j]);
	}

	for(i=1; i<MAXOS; i+=2)
	{
	  sprintf(osname,"Trans%d",i);
	  CONSTRUCT_OS(TRANS,osname,&osnum[i]);
	  for(j=0; j<MAXB; j++)
            CONSTRUCT_OB("B",osnum[i],CLS_DEF,GRP_DEF,&b_objid[j]);
	}

/* .. connect them .. */

	for(i=1; i<MAXOS; i+=2)
	 for(j=0; j<MAXA; j++)
 	  for(k=0; k<MAXB; k++)
            CONNECT(osnum[i],  b_objid[k],"bcca",
		    osnum[i-1],a_objid[j],"acany");

/* now disconnect them */

	for(i=1; i<MAXOS; i+=2)
	 for(j=0; j<MAXA; j++)
 	  for(k=0; k<MAXB; k++)
            DISCONNECT(osnum[i],  b_objid[k],"bcca",
		       osnum[i-1],a_objid[j],"acany");
	  
/* now delete all the OS's */

	for(i=0; i<MAXOS; i++)
	   DELETE_OS(osnum[i]);

if(argc > 1) printf("Same but with filed to transient connections \n");

/* now do transient to filed */

	for(i=0; i<MAXOS; i+=2)
	{
	  sprintf(osname,"Trans%d",i);
	  CONSTRUCT_OS(TRANS,osname,&osnum[i]);
	  for(j=0; j<MAXA; j++)
          CONSTRUCT_OB("A",osnum[i],CLS_DEF,GRP_DEF,&a_objid[j]);
	}

	for(i=1; i<MAXOS; i+=2)
	{
	  sprintf(osname,"Filed%d",i);
	  CONSTRUCT_OS(FILED,osname,&osnum[i]);
	  for(j=0; j<MAXB; j++)
	  {
            CONSTRUCT_OB("B",osnum[i],CLS_DEF,GRP_DEF,&b_objid[j]);
            CONNECT(osnum[i],b_objid[j],"bcca",osnum[i-1],a_objid[j],"acany");
	  }
	}

	/* delete and reconstruct the filed os's */
	for(i=1; i<MAXOS; i+=2)
	{
	   DELETE_OS(osnum[i]);
	   sprintf(osname,"Filed%d",i);
	   sts = om$construct_os(classid= OM_K_OMFILEDOS_ACTCLASSID,
			         osname = osname,
			         osnum  = &osnum[i],
			         p_objid= &f_objid);

 	   report_result(OM_I_READ_FROM_FILE,"Reconstrucing a filed os ");
	}
	   
/* now attempt to disconnect them. all attempts should fail */

	for(i=1; i<MAXOS; i+=2)
	 for(j=0; j<MAXA; j++)
    	  for(k=0; k<MAXB; k++)
           DISCONNECTF(osnum[i],  b_objid[k],"bcca",
		      osnum[i-1],a_objid[j],"acany");

/* now delete all the object spaces and files */

	for(i=0; i<MAXOS; i++)
	{
	   DELETE_OS(osnum[i]);
	   if(!((i+1)%2)) 
	   {
	      sprintf(msg_buffer,"rm Filed%d 2>1 1> /dev/null",i);
	      system (msg_buffer);
	   }
	}

/*****************/
if(argc > 1) printf("Same but with filed to filed connections \n");

/* now do filed to filed */

	for(i=0; i<MAXOS; i++)
	{
	  sprintf(osname,"Filed%d",i);
	  CONSTRUCT_OS(FILED,osname,&osnum[i]);
	  for(j=0; j<MAXA; j++)
            CONSTRUCT_OB("A",osnum[i],CLS_DEF,GRP_DEF,&a_objid[j]);
	  for(j=0; j<MAXB; j++)
            CONSTRUCT_OB("B",osnum[i],CLS_DEF,GRP_DEF,&b_objid[j]);
	}

	/* .. connect them .. */

	for(i=1; i<MAXOS; i+=2)
	 for(j=0; j<MAXA; j++)
 	  for(k=0; k<MAXB; k++)
            CONNECT(osnum[i],  b_objid[k],"bcca",
		    osnum[i-1],a_objid[j],"acany");


	/* delete and reconstruct the filed os's */
	for(i=1; i<MAXOS; i++)
	{
	   DELETE_OS(osnum[i]);
	   sprintf(osname,"Filed%d",i);
	   sts = om$construct_os(classid= OM_K_OMFILEDOS_ACTCLASSID,
			         osname = osname,
			         osnum  = &osnum[i],
			         p_objid= &f_objid);

 	   report_result(OM_I_READ_FROM_FILE,"Reconstrucing a filed os ");
	}
	   
/* now attempt to disconnect them. all attempts should succeed */

	for(i=1; i<MAXOS; i+=2)
	 for(j=0; j<MAXA; j++)
    	  for(k=0; k<MAXB; k++)
           DISCONNECT(osnum[i],  b_objid[k],"bcca",
		      osnum[i-1],a_objid[j],"acany");

/* now delete all the object spaces and files */

	for(i=0; i<MAXOS; i++)
	{
	   DELETE_OS(osnum[i]);
     	   sprintf(msg_buffer,"rm Filed%d 2>1 1> /dev/null",i);
	   system (msg_buffer);
	}

}
