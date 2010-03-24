class implementation Root;
/* maini.I */

#include "OMobjectcomm.h"
#include "OMcluster.h"

#define MAXOBJ		500 

/* for verbose printing define DBGPRT */
/* #define DBGPRT		1   */

OM_S_OBJID	 oid[MAXOBJ]; /* oids of constructed objects */

 from g    import send_chan;
 from OMCluster import init_OMCluster, merge, remove;
 from OMGroup import init_OMGroup, merge, remove;
 from OMObjSpace import translate_group_name;
 from OMFiledOS import write;

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ conobj */
/* construct objects */
 OM_S_OBJID conobj (neighbor)
    OM_S_NEIGHBOR	neighbor;
 {
  int sts;
  OM_S_OBJID oid;

  sts = om$construct(classname = "g", p_objid = &oid, 
		neighbor=neighbor, osnum=OM_Gw_current_OS);
  error("conobj OM$construct fail",sts);
#ifdef	 DBGPRT
  printf("oid for g of group %u is %u\n", neighbor.groupid, oid);
#endif

  return(oid);
 };

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ error */
/* check status - exit if bad */
 error (str,sts)
 char *str;
 int sts;
 {
  if(1&sts) return;
  printf("\n!!!!! test failed in %s\n",str);
  om$report_error(sts=sts);
  exit();
 };

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++break */
/* routine to break at */
int breakhere()
{
  return(OM_S_SUCCESS);
};

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ maini */
maini()
{
int sts, i, j, k, m, ii;
OM_S_OBJID	clustoid[5], transclustoid[5], grpoid[5], transgrpoid[5];
OMuword		clustnum[5], transclustnum[5];
char		*grpname[5];

/*==========================*/
/* Construct New Cluster    */
/*==========================*/
#ifdef DBGPRT
printf("\nConstructing 5 new clusters; printing debug for each.\n");
#endif

for(i=0; i<5; i++)
{
sts = om$construct(classname="OMCluster", osnum=OM_Gw_current_OS,
		p_objid=&clustoid[i], msg=message OMCluster.init_OMCluster(
		&clustnum[i]));
if(!(1&sts))
{
  error("Construct Cluster", sts);
}

#ifdef	DBGPRT
sts = om$send(msg=message OMCluster.debug(),
		senderid=clustoid[i],
		targetid=clustoid[i]);
if(!(1&sts))
{
    error("Send OMCluster.debug", sts);
}
#endif
}

/*===========================*/
/* Create 5 new Groups       */
/*===========================*/
#ifdef	DBGPRT
printf("\nConstructing 5 new groups; translating their names; constructing 10 g objects in each one; printing debug for each.\n");
#endif

grpname[0] = "Group1";
grpname[1] = "Group2";
grpname[2] = "Group3";
grpname[3] = "Group4";
grpname[4] = "Group5";
for(i=0; i<5; i++)
{

sts = om$construct(classname="OMGroup", osnum=OM_Gw_current_OS,
		p_objid=&grpoid[i], msg=message OMGroup.init_OMGroup(
		grpname[i], NULL, OM_K_NOEXTEND, OM_K_NOTACLUSTER));
if(!(1&sts))
{
  error("Construct Group", sts);
}

sts = om$send(msg=message OMObjSpace.translate_group_name(grpname[i],
		&transgrpoid[i]),
		senderid=NULL_OBJID,
		targetid=OM_GO_current_OS_objid);
if(!(1&sts))
{
  error("Translate Group Name", sts);
}
if(transgrpoid[i] != grpoid[i])
  printf("\ntransgrpoid: %u != grpoid: %u\n", transgrpoid[i], grpoid[i]);
for (ii=0; ii<10; ii++)
{
  OM_S_OBJID	oid[10];
  OM_S_NEIGHBOR neighbor;

  neighbor.clusterid = clustnum[i];
  neighbor.groupid = grpoid[i];
  sts = om$construct(classname="g", osnum=OM_Gw_current_OS,
			p_objid=&oid[ii], neighbor=neighbor);
  if (!(1&sts))
  {
    error("Construct g", sts);
  }
#ifdef	 DBGPRT
  printf("oid for g%d of group %u is %u\n", ii, i, oid[ii]);
#endif
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[i],
		targetid=grpoid[i]);
if(!(1&sts))
{
    error("Group Debug", sts);
}
#endif
}
/*========================*/
/* Merge Group 0: ERROR   */
/*========================*/
#ifdef	DBGPRT
printf("\ntry to merge group 0: ERROR case \n");
#endif
sts = om$send(msg=message OMGroup.merge(grpoid[0]),
		senderid=OM_Gp_CurOSD->Group0_Oid,
		targetid=OM_Gp_CurOSD->Group0_Oid);
if(sts != OM_E_ILLEGAL_GROUP0)
{
    error("Merge of Group 0 did not fail", sts);
}
/*=========================*/
/* Remove Group 0: ERROR   */
/*=========================*/
#ifdef	DBGPRT
printf("\ntry to remove group 0: ERROR case \n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=OM_Gp_CurOSD->Group0_Oid,
		targetid=OM_Gp_CurOSD->Group0_Oid);
if(sts != OM_E_ILLEGAL_GROUP0)
{
    error("Remove of Group 0 did not fail", sts);
}
/*==================*/
/* Remove Group 4   */
/*==================*/
#ifdef	DBGPRT
printf("\nRemove Group 4: Should succeed\n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=grpoid[3],
		targetid=grpoid[3]);
if(!(1&sts))
{
    error("Remove Group 4", sts);
}
/*===================================================*/
/* Merge Group 1 into Group 2: ERROR NOT EXTENDABLE  */
/*===================================================*/
#ifdef	DBGPRT
printf("\nMerge into an nonempty, nonextendable group ERROR\n");
#endif
sts = om$send(msg=message OMGroup.merge(grpoid[1]),
		senderid=grpoid[0],
		targetid=grpoid[0]);
if(sts != OM_E_NOEXTEND_GROUP)
{
    error("Merge into nonextendable group did not fail", sts);
}
/*============================*/
/* Merge Group 1 into group_0 */
/*============================*/
#ifdef	DBGPRT
printf("\nMerge Group 1 into group_0\n");
#endif
sts = om$send(msg=message OMGroup.merge(OM_Gp_CurOSD->Group0_Oid),
		senderid=grpoid[0],
		targetid=grpoid[0]);
if(!(1&sts))
{
    error("Merging Group1 into group_0", sts);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[0],
		targetid=grpoid[0]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
sts = om$send(msg=message OMGroup.debug(),
		senderid=OM_Gp_CurOSD->Group0_Oid,
		targetid=OM_Gp_CurOSD->Group0_Oid);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*==============================================================*/
/* Merge Group 5 into Group 1: Group 1 is empty & NONextendable */
/*==============================================================*/
#ifdef	DBGPRT
printf("\nMerge Group 5 into Group 1\n");
#endif
sts = om$send(msg=message OMGroup.merge(grpoid[0]),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("Merging Group5 into Group1", sts);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[0],
		targetid=grpoid[0]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*==================*/
/* Remove Group 5   */
/*==================*/
#ifdef	DBGPRT
printf("\nRemove Group 5: Should succeed - empty group case\n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("Remove Group 5", sts);
}
/*==================*/
/* Remove Group 2   */
/*==================*/
#ifdef	DBGPRT
printf("\nRemove Group 2: Should succeed - frees OS oids 768-1023\n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=grpoid[1],
		targetid=grpoid[1]);
if(!(1&sts))
{
    error("Remove Group 2", sts);
}
/*===================================================*/
/* Reconstruct Group 2: smaller init size & ext size */
/*===================================================*/
#ifdef	DBGPRT
printf("\nReconstruct Group2: init=1 & ext=1; needed < free oids case\n");
#endif
sts = om$construct(classname="OMGroup", osnum=OM_Gw_current_OS,
		p_objid=&grpoid[1], msg=message OMGroup.init_OMGroup(
		grpname[1], 1, 1, OM_K_NOTACLUSTER));
if(!(1&sts))
{
  error("Construct Group", sts);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[1],
		targetid=grpoid[1]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*================================================================*/
/* Reconstruct Group 4: extendable 100 init 511: = OSO holes case */
/*================================================================*/
#ifdef	DBGPRT
printf("\nReconstruct Group4: ext=100 init=511: = OSO holes case\n");
#endif
sts = om$construct(classname="OMGroup", osnum=OM_Gw_current_OS,
		p_objid=&grpoid[3], msg=message OMGroup.init_OMGroup(
		grpname[3], 511, 100, OM_K_NOTACLUSTER));
if(!(1&sts))
{
  error("Construct Group", sts);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[3],
		targetid=grpoid[3]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*==================*/
/* Remove Group 2   */
/*==================*/
#ifdef	DBGPRT
printf("\nRemove Group 2: Should succeed - frees OS oid 768\n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=grpoid[1],
		targetid=grpoid[1]);
if(!(1&sts))
{
    error("Remove Group 2", sts);
}
/*===================================================================*/
/* Reconstruct Group 5: extendable 10 init 25: need > OSO holes case */
/*===================================================================*/
#ifdef	DBGPRT
printf("\nReconstruct Group5: ext=10 init=25: needed > OSO holes case\n");
#endif
sts = om$construct(classname="OMGroup", osnum=OM_Gw_current_OS,
		p_objid=&grpoid[4], msg=message OMGroup.init_OMGroup(
		grpname[4], 25, 10, OM_K_NOTACLUSTER));
if(!(1&sts))
{
  error("Construct Group", sts);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*==================*/
/* Remove Group 3   */
/*==================*/
#ifdef	DBGPRT
printf("\nRemove Group 3: Should succeed - frees OS oids 1024-1279\n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=grpoid[2],
		targetid=grpoid[2]);
if(!(1&sts))
{
    error("Remove Group 3", sts);
}
/*====================================================================*/
/* Construct 30 g objects in Group 5: Extend Grp - Needed < Free Case */
/*====================================================================*/
#ifdef	DBGPRT
printf("\nExtend Group 5: Needed < Free Case\n");
#endif
for(i=0; i<30; i++)
{
    OM_S_NEIGHBOR	neigh;
	neigh.groupid = grpoid[4];
	neigh.clusterid = NULL;
	oid[i] = conobj(neigh);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*============================*/
/* Merge Group 5 into Group 4 */
/*============================*/
#ifdef	DBGPRT
printf("\nMerge Group 5 into Group 4\n");
#endif
sts = om$send(msg=message OMGroup.merge(grpoid[3]),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("Merging Group 5 into Group 4", sts);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[3],
		targetid=grpoid[3]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*=======================================*/
/* Recreate Group 3: init 236 extend 300 */
/*=======================================*/
#ifdef	DBGPRT
printf("\nReconstruct (New) Group3: ext=300 init=236: < OSO holes case\n");
#endif
sts = om$construct(classname="OMGroup", osnum=OM_Gw_current_OS,
		p_objid=&grpoid[2], msg=message OMGroup.init_OMGroup(
		grpname[2], 236, 300, OM_K_NOTACLUSTER));
if(!(1&sts))
{
  error("Construct Group", sts);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[2],
		targetid=grpoid[2]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*====================================================================*/
/* Construct 10 g objects in Group 5: Extend Grp - Needed = Free Case */
/*====================================================================*/
#ifdef	DBGPRT
printf("\nExtend Group 5: Needed = Free Case\n");
#endif
for(i=0; i<10; i++)
{
    OM_S_NEIGHBOR	neigh;
	neigh.groupid = grpoid[4];
	neigh.clusterid = NULL;
	oid[i] = conobj(neigh);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*=================================================================*/
/* Construct 10 g objects in Group 5: Extend Grp No Free Oids Case */
/*=================================================================*/
#ifdef	DBGPRT
printf("\nExtend Group 5: No Free Oids Case\n");
#endif
for(i=0; i<10; i++)
{
    OM_S_NEIGHBOR	neigh;
	neigh.groupid = grpoid[4];
	neigh.clusterid = NULL;
	oid[i] = conobj(neigh);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[4],
		targetid=grpoid[4]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*===============================================================*/
/* Filed OS create, write, read back in; small init & ext counts */
/*===============================================================*/
/*
#ifdef	DBGPRT
printf("\nFiled OS test with small init & extend counts\n");
#endif
{
  OM_S_OBJID  osid;
  OMuword     osnum;
  OMuint      rc;


sts=om$construct_os(classname="OMFiledOS", osnum=&osnum,
		    osname="file.fil", initcount=2,
		    extcount=1, resultcount=&rc, p_objid=&osid);
if(!(1&sts))
{
    error("Construct Filed OS", sts);
}

sts = om$send(msg=message OMFiledOS.delete(TRUE),
		senderid=osid, targetos=osnum,
		targetid=osid);
if(!(1&sts))
{
    error("Writing Filed OS via delete", sts);
}

sts=om$construct_os(classname="OMFiledOS", osnum=&osnum,
		    osname="file.fil", initcount=2,
		    extcount=1, resultcount=&rc, p_objid=&osid);
if(!(1&sts))
{
    error("Construct Filed OS - reading it in", sts);
}

}
*/
/*==================*/
/* Remove Group 1   */
/*==================*/
#ifdef	DBGPRT
printf("\nRemove Group 1: free oids 1536-1791\n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=grpoid[0],
		targetid=grpoid[0]);
if(!(1&sts))
{
    error("Remove Group 1", sts);
}
/*======================================================================*/
/* Construct 300 g objects in Grp 3: Extend Grp Free Oids < Needed Case */
/*======================================================================*/
#ifdef	DBGPRT
printf("\nExtend Group 3: Free Oids < Needed Case\n");
#endif
for(i=0; i<300; i++)
{
    OM_S_NEIGHBOR	neigh;
	neigh.groupid = grpoid[2];
	neigh.clusterid = NULL;
	oid[i] = conobj(neigh);
}
#ifdef	DBGPRT
sts = om$send(msg=message OMGroup.debug(),
		senderid=grpoid[2],
		targetid=grpoid[2]);
if(!(1&sts))
{
    error("OMGroup debug", sts);
}
#endif
/*====================================*/
/* Remove Group 3: Shrink Space Map   */
/*====================================*/
#ifdef	DBGPRT
printf("\nRemove Group 3: Shrink Space Map\n");
#endif
sts = om$send(msg=message OMGroup.remove(),
		senderid=grpoid[2],
		targetid=grpoid[2]);
if(!(1&sts))
{
    error("Remove Group 3", sts);
}
#ifdef	DBGPRT
if(OM_Gp_CurOSD->CurSpaceMapSize != 1826)
printf("\nProblem when Shrinking Space Map: Current Space Map Size != 1826\n");
#endif


};

end implementation Root;
