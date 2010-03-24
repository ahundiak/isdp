class implementation Root;
/* maini.I */

/*#include <sys/types.h>
#include <sys/times.h>*/
#include "OMobjectcomm.h"
#include "OMcluster.h"

#define MAXOBJ		300
#define MAXCLU		9
/*#define HIOID		MAXOBJ*MAXCLU+MAXCLU+7*//*OSCOs*//*+2*//*OSO&Group*/
#define HIOID		2700

void	srand48();
double	drand48();

/*struct tms	buffer1, buffer2;*/

/* for verbose printing define DBGPRT */
/*#define DBGPRT		1*/

/* for printing of times define TIMEPRT */
/*#define TIMEPRT		1*/

OM_S_OBJID	 oid[MAXCLU][MAXOBJ]; /* oids of constructed objects */
OMuword     osnum;

 from c1    import show_a;
 from OMCluster import init_OMCluster;
 from OMFiledOS import write;

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ conobj */
/* construct objects */
 OM_S_OBJID conobj (neighbor)
    OM_S_NEIGHBOR	neighbor;
 {
  int sts;
  OM_S_OBJID oid;

  sts = om$construct(classname = "c1", p_objid = &oid, 
		neighbor=neighbor, osnum=osnum);
  error("conobj OM$construct fail",sts);

  return(oid);
 };

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ error */
/* check status - exit if bad */
/* error (str,sts)
 char *str;
 int sts;
 {
  if(1&sts) return;
  printf("\n!!!!! test failed in %s\n",str);
  om$report_error(sts=sts);
  exit();
 };
*/
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++break */
/* routine to break at */
int breakhere()
{
  return(OM_S_SUCCESS);
};

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ maini */
maini()
{
int sts, i, j, k, m, ii, count;
OM_S_OBJID	clustoid[MAXCLU], transclustoid[MAXCLU], target_oid;
OMuword		clustnum[MAXCLU], transclustnum[MAXCLU], c1_classid,
		random_classid, target_osnum;
OM_S_OBJID  osid, random_oid, minoid;
OMuint      rc, setsize;
OM_S_NEIGHBOR	neighbor;

/*=============================*/
/* Construct Swap Test FiledOS */
/*=============================*/
#ifdef DBGPRT
printf("\nConstructing Swap Test FiledOS.\n");
#endif

/*=============================*/
/* make FiledOS named file.fil */
/*=============================*/

sts=om$construct_os(classname="OMFiledOS", osnum=&osnum,
		    osname="file.fil", extcount=100, resultcount=&rc,
		    p_objid=&osid);
if(!(1&sts))
{
    error("Construct Filed OS", sts);
}

/*==========================*/
/* Construct New Cluster    */
/*==========================*/
#ifdef DBGPRT
printf("\nConstructing MAXCLU new clusters; printing debug for each.\n");
#endif

 neighbor.clusterid = 1;
 neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;

for(i=0; i<MAXCLU; i++)
{
sts = om$construct(classname="OMCluster", osnum=osnum, neighbor=neighbor,
		p_objid=&clustoid[i], msg=message OMCluster.init_OMCluster(
		&clustnum[i]));
if(!(1&sts))
{
  error("Construct Cluster", sts);
}

#ifdef	DBGPRT
/*
sts = om$send(msg=message OMCluster.debug(),
		senderid=clustoid[i],
		targetos=osnum,
		targetid=clustoid[i]);
if(!(1&sts))
{
    error("Send OMCluster.debug", sts);
}
*/
printf("Constructed %dth cluster\n",i);
#endif

/*================================================*/
/* Construct MAXOBJ c1 guys within each cluster   */
/*================================================*/

for (ii=0; ii<MAXOBJ; ii++)
{
  OM_S_NEIGHBOR neighbor;

  neighbor.clusterid = clustnum[i];
  neighbor.groupid = OM_Gp_CurOSD->Group0_Oid;
  oid[i][ii] = conobj(neighbor);
/*
#ifdef	 DBGPRT
  printf("oid for c1%d of cluster %u is %u\n", ii, i, oid[i][ii]);
#endif
*/
}
}

/*=================================================*/
/* Simple msg intercept within swap environment    */
/* use cluster1's oid1, i.e. oid[0][0]             */
/*=================================================*/

 if(!(1&(sts = om$set_intercept(objid=oid[0][0], target_objid=oid[0][1],
				osnum=osnum, target_osnum=osnum))))
 {
  error("Set intercept for oid[0][0] msgs", sts);
 }
 if(!(1&(sts = om$get_intercept(objid=oid[0][0], osnum=osnum,
			p_target_objid=&target_oid,
                        p_target_osnum=&target_osnum))))
 {
   printf("oid %d \n",oid[0][0]);
   error("Get intercept for oid[0][0]'s msgs",sts);
 }
 if(target_oid != oid[0][1] || target_osnum != osnum)
   printf("wrong oid or osnum returned from get_intercept\n");
if(!(1&(sts = om$send(msg=message c1.show_a(), senderid=NULL_OBJID,
		 targetid=oid[0][0], targetos=osnum))))
  {
    error("Send c1.show_a to some intercept c1 object[0][0]", sts);
  }
if(!(1&(sts = om$cancel_intercept(objid=oid[0][0],osnum=osnum))))
{
   error("Cancel intercept for oid[0][0]'s msgs.", sts);
}

/*=================================================*/
/* Randomly select oid & if c1 object send to it */
/*=================================================*/

sts = om$get_classid(osnum=osnum, classname="c1",
		p_classid=&c1_classid);
if(!(1&sts))
{
    error("Get c1 Classid", sts);
}

#ifdef	TIMEPRT
printf("\n--- Start Timing for 90 sends to random oids (constant swapping)\n");
times(&buffer1);
#endif

srand48(1);
count = 0;
do
{
  /* get random oid */
  random_oid = (int)(345733 * drand48()) % (HIOID+1);
  sts = om$get_classid(osnum=osnum, objid=random_oid,
		p_classid=&random_classid);
  if(!(1&sts))
  {
    error("Get random oid's Classid", sts);
  }
  if(c1_classid == random_classid)
  {
    count++;
    /* send */
    sts = om$send(msg=message c1.show_a(),
		senderid=random_oid, targetos=osnum,
		targetid=random_oid);
    if(!(1&sts))
    {
      error("Sending show_a msg to random oid", sts);
    }
  }  
} while(count < 90);

#ifdef	TIMEPRT
printf("\n--- Total Time for 90 sends to random oids (constant swapping)\n");
times(&buffer2);
printf("user time: %d\n", buffer2.tms_utime - buffer1.tms_utime);
printf("syst time: %d\n", buffer2.tms_stime - buffer1.tms_stime);
#endif

/*============================================*/
/* Write Filed OS out; exercises write change */
/*============================================*/

#ifdef	TIMEPRT
printf("\n--- Start Time for deleting FiledOS\n");
times(&buffer1);
#endif

sts = om$send(msg=message OMFiledOS.delete(TRUE),
		senderid=osid, targetos=osnum,
		targetid=osid);
if(1 != sts)
{
    error("Writing Filed OS via delete", sts);
}

#ifdef	TIMEPRT
printf("\n--- Total Time for deleting FiledOS\n");
times(&buffer2);
printf("user time: %d\n", buffer2.tms_utime - buffer1.tms_utime);
printf("syst time: %d\n", buffer2.tms_stime - buffer1.tms_stime);
#endif

/*=================================================*/
/* Reconstruct FiledOS; file.fil gets read back in */
/*=================================================*/

sts=om$construct_os(classname="OMFiledOS", osnum=&osnum,
		    osname="file.fil", resultcount=&rc, p_objid=&osid);
if(1 != sts)
{
    error("Construct Filed OS", sts);
}

/*=================================================================*/
/* Send to random oids within 2 clusters; changing the 2 clusters  */
/* one at a time, going thru all MAXCLU clusters - sample working set */
/*=================================================================*/

setsize = 2*MAXOBJ+1;	/* initial working set is 10 to 2 * MAXOBJ+10; */
			/* except cluster oid (~ MAXOBJ+10) */
		/* range of two clusters' oids make up working set */
		/* remains setsize so no need to change */ 
minoid = 10;    /* so mod setsize and add 10 to skip 1-9 oids */

#ifdef	TIMEPRT
printf("\n--- Start Timing for %d sends to working set which gradually moves thru clusters\n",(MAXCLU-1)*10);
times(&buffer1);
#endif

for(i=0; i<MAXCLU-1; i++)
{
count = 0;
do
{
  /* get random oid */
  random_oid = ((int)(3778233 * drand48()) % setsize) + minoid;
  sts = om$get_classid(osnum=osnum, objid=random_oid,
		p_classid=&random_classid);
  if(!(1&sts))
  {
/*    error("Get random oid's Classid", sts); */
      printf("OMTswaptsti: Found a free oid, random_oid=%d\n",random_oid);
  }
  else
  {
     if(c1_classid == random_classid)
     {
       count++;
       /* send */
       sts = om$send(msg=message c1.show_a(),
		senderid=random_oid, targetos=osnum,
		targetid=random_oid);
       if(!(1&sts))
       {
         error("Sending show_a msg to random oid", sts);
       }
      }
  }  
} while(count < 10);
	/* next working set */
minoid += MAXOBJ;	/* maxoid no need to change still 21 oid range */
}	/* for loop */

#ifdef	TIMEPRT
printf("\n--- Total Time for 90 sends to working set which gradually moves thru clusters\n");
times(&buffer2);
printf("user time: %d\n", buffer2.tms_utime - buffer1.tms_utime);
printf("syst time: %d\n", buffer2.tms_stime - buffer1.tms_stime);
#endif

/*=====================================================*/
/* Write Filed OS out; exercises swap more than delete */
/*=====================================================*/

#ifdef	TIMEPRT
printf("\n--- Start time for writing FiledOS\n");
times(&buffer1);
#endif

sts = om$send(msg=message OMFiledOS.write (NULL),
		senderid=osid, targetos=osnum,
		targetid=osid);
if(!(1&sts))
{
    error("Writing Filed OS", sts);
}

#ifdef	TIMEPRT
printf("\n--- Total Time for writing FiledOS\n");
times(&buffer2);
printf("user time: %d\n", buffer2.tms_utime - buffer1.tms_utime);
printf("syst time: %d\n", buffer2.tms_stime - buffer1.tms_stime);
#endif

/*======================================*/
/* Send to 1 oid of each of clusters    */
/*======================================*/

random_oid = MAXOBJ/2+10;
for(i=0; i<MAXCLU; i++)
{
    /* send */
    sts = om$send(msg=message c1.show_a(),
		senderid=random_oid, targetos=osnum,
		targetid=random_oid);
    if(!(1&sts))
    {
      error("Sending show_a msg to random oid", sts);
    }
    random_oid += MAXOBJ;
}

/* delete FiledOS to remove all swap files from disk */

sts = om$send(msg=message OMFiledOS.delete(TRUE),
		senderid=osid, targetos=osnum,
		targetid=osid);
if(!(1&sts))
{
    error("Writing Filed OS via delete", sts);
}

/* remove FiledOS from disk */

unlink("file.fil");

};


end implementation Root;
