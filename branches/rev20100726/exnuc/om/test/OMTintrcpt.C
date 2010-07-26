#include	"OMminimum.h"
#include 	"OMprimitives.h"
#include	"OMerrordef.h"
#include	"OMcluster.h"
#include	"OMintercept.h"

/* define DBGPRT if want to see verbose printing */

/* #define	DBGPRT	1  */

#define NUMOIDS		1000

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ error
*/
/* check status - exit if bad */
 error (str,sts)
 char *str;
 int sts;
 {
  if(1&sts) return;
  printf("\n!!!!! test failed in %s\n",str);
  om$report_error(sts=sts);
  exit(1);
 };


main()
{
int		sts, i, j;
OM_S_NEIGHBOR	neighbor;
OM_S_MESSAGE	msg;
OMuint		flag=TRUE;
OM_S_OBJID	oid[NUMOIDS], grpoid, transgrpoid, grpoiderr, msgintroid,
		f_oid[10], osid;
OMuword		msgintros, f_osnum;
static char	*OMparams[]={"DEFTRANS_GROUP_EXTOBJS=200", "DEFTRANS_CLUSTER_SIZE=2048",NULL};
OM_S_CHANSELECT	cs_to, cs_fr;
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

if(!(1&(sts = om$runtime_init(paramc=2,param_list=OMparams) )))
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


/* construct a bunch of g guys within new group */

#ifdef DBGPRT 
 printf("Construct %d g objects in new group\n",NUMOIDS); 
#endif
neighbor.groupid=grpoid;
neighbor.clusterid=NULL;

for(i=0; i<NUMOIDS; i++)
if(!(1&(sts = om$construct(classname="g", p_objid=&oid[i], neighbor=neighbor, osnum=OM_Gw_current_OS) )))
  {
    error("Construct g", sts);
  }

if(!(1&(sts = om$make_message(classname="g",
				methodname="answer",
				p_msg=&msg) )))
  {
    error("Make Message for g.answer", sts);
  }


/*========================================*/
/* test error cases for message intercept */
/*========================================*/
	/* get intercept prior to setting it */
if(OM_W_NOINTERCEPT !=(sts = om$get_intercept(objid=oid[0], p_target_objid=&msgintroid,
			p_target_osnum=&msgintros)))
{
   error("Get intercept when none set, wrong sts returned", sts);
}
	/* cancel intercept prior to setting it */
if(OM_W_NOINTERCEPT !=(sts = om$cancel_intercept(objid=oid[0])))
{
   error("Cancel intercept when none set, wrong sts returned", sts);
}

/*========================================================*/
/* set message intercept for oid 0's msgs. to go to oid 9 */
/*========================================================*/

for(i=0, j=1; i<NUMOIDS; i+=2, j+=2)
{
 if(!(1&(sts = om$set_intercept(objid=oid[i], target_objid=oid[j]))))
 {
  error("Set intercept for oid msgs", sts);
 }
}
/*===============================================*/
/* error set message intercept after already set */
/*===============================================*/

if(OM_E_INTERCEPTED != (sts = om$set_intercept(objid=oid[0], target_objid=oid[9])))
{
   error("Set intercept when already active, wrong sts returned", sts);
}

/*===========================================================*/
/* get message intercept for oids set above, should be oid+1 */
/*===========================================================*/

for(i=0, j=1; i<NUMOIDS; i+=2, j+=2)
{
 if(!(1&(sts = om$get_intercept(objid=oid[i], p_target_objid=&msgintroid,
			p_target_osnum=&msgintros))))
 {
   printf("oid %d \n",oid[i]);
   error("Get intercept for oid's msgs",sts);
 }
 if(msgintroid != oid[j] || msgintros != OM_Gw_current_OS)
   printf("wrong oid or osnum returned from get_intercept\n");
}
/*============================================*/
/* cancel message intercept for oid 0's msgs. */
/*============================================*/

/* case oid[0] is in original hashtable; not overflow */
if(!(1&(sts = om$cancel_intercept(objid=oid[0]))))
{
   error("Cancel intercept for oid 0's msgs.", sts);
}
/* case oid[NUMOIDS-2] is in overflow area */
if(!(1&(sts = om$cancel_intercept(objid=oid[NUMOIDS-2]))))
{
   error("Cancel intercept for oid %d's msgs.", oid[NUMOIDS-2],sts);
}
/* case oid[142] is in original hashtable & has no next (when NUMOIDS=500) */
if(!(1&(sts = om$cancel_intercept(objid=oid[142]))))
{
   error("Cancel intercept for oid %d's msgs.", oid[142],sts);
}

/*===========================================================*/
/* Disable msg intercept for objid[n], given n=2,6,10,14 ... */
/*===========================================================*/
for(i=2; i<142; i+=4)
{
  if(!(1&(sts = om$disable_intercept(objid=oid[i]))))
  {
    error("Disable intercept for oid %d's msgs.", oid[i],sts);
  }
}


/*=======================================================*/
/* Send to each intercepted objid the g.answer msg       */
/*=======================================================*/

for(i=2; i<142; i+=2)
{
if(!(1&(sts = om$send(msg=&msg, senderid=NULL_OBJID, targetid=oid[i]))))
  {
    error("Send g.answer to some intercepted g objects", sts);
  }
}
/*===================================================================*/
/* construct a new os & som g's within it & set intercepts to 1st os */
/* in order to test send foreign to intercept oid                    */
/*===================================================================*/
sts=om$construct_os(classname="OMFiledOS", osnum=&f_osnum,
                    osname="file.fil", p_objid=&osid);
if(!(1&sts))
{
    error("Construct Filed OS", sts);
}
#ifdef DBGPRT 
 printf("f_osnum is %d\n",f_osnum);
#endif
for(i=0; i<10; i++)
if(!(1&(sts = om$construct(classname="g", p_objid=&f_oid[i], osnum=f_osnum) )))
  {
    error("Construct g", sts);
  }
#ifdef DBGPRT 
 printf("f_oid[0] is %d\n",f_oid[0]);
#endif
for(i=0,j=1; i<10; i++,j+=2)
if(!(1&(sts = om$set_intercept(objid=f_oid[i], target_objid=oid[j],
			 osnum=f_osnum, target_osnum=OM_Gw_current_OS))))
 {
  error("Set intercept for filedOS oid msg", sts);
 }
/* a nested intercept case within a foreign send */
if(!(1&(sts = om$set_intercept(objid=oid[1], target_objid=oid[3]))))
 {
  error("Set intercept for filedOS oid msg", sts);
 }
for(i=0; i<10; i++)
if(!(1&(sts = om$send(msg=&msg, senderid=NULL_OBJID,
		      targetid=f_oid[i], targetos=f_osnum))))
  {
    error("Send g.answer to some filedOS g object", sts);
  }

#ifdef	DBGPRT
printf("end of test\n");
#endif

exit(0);
};
