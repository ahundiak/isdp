/* ###################   APOGEE COMPILED   ################## */
/*
This file contains the support for interference analysis.
*/
class implementation EMSsurface;

#include "EMS.h"

#ifndef DEBUG
#define DEBUG 0
#endif

#if DEBUG
#define ResultBufInc	1
#else
#define ResultBufInc	10
#endif

#define MaxNameDup	10

#include <stdio.h>
#include <string.h>

#ifndef SUNOS5
%safe
#include <math.h>
%endsafe
#endif

#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emssfint.h"
#include "EMSintf.h"
#include "griodef.h"
#include "msdef.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "emserr.h"
#include "DItypedef.h"
#include "DIdef.h"	/* PATH_MAX */
#include "DIglob.h"	/* DItranslate */
#include "DImacros.h"   /* di$.. */
#include "DIprims.h"
#include "go.h"         /* GRobj_info for obj indentifier */
#include "EMSmsgdef.h"

/* ex$message */
# include "msmacros.h"
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */

from GRowner import GRget_number_components, GRget_components;

extern GRclassid OPP_GRgrset_class_id;

void EMintf_getname(id, md_env, elename)
struct GRid	*id;
struct GRmd_env *md_env;
IGRchar		*elename;
{
 IGRboolean	found;
 IGRlong	sts = OM_S_SUCCESS, rc = EMS_S_Success;
 IGRchar	locname[DI_PATH_MAX];
 GRclassid	objclass;

 om$get_classid (objid = id->objid, osnum = id->osnum, p_classid = &objclass);
 if (om$is_ancestry_valid (superclassid = OPP_GRgrset_class_id,
      subclassid = objclass) != OM_S_SUCCESS)
   {
   found = FALSE;
   sts = om$send(msg = message GRvg.GRgetname(&rc, locname), 
		senderid = NULL_OBJID, targetid = id->objid, 
		targetos = id->osnum);
   if(1&rc&sts)
    {
     sts = di$cvt_name_for_output(s_path = locname, u_path = elename);
     if(1&sts)
       found = TRUE;
    }

   if (!found)
    {
     if (!IF_NULL_OBJID (id->objid))
       sprintf(elename, "ID-%d/OS-%d", id->objid, id->osnum);
     else
       elename[0] = NULL;
    }
   }
 else
   elename[0] = NULL;

 return;
}
void EMintf_failureReport(failed, num_failed, ptr)
struct EMSintf_failure	*failed;
IGRint	num_failed;
IGRchar	*ptr;
{
 IGRint		i, junk;
 IGRchar		elename1[DI_PATH_MAX], elename2[DI_PATH_MAX];
 extern IGRint		EFprintcode() ;

 fprintf((FILE *) ptr, "  %s\n", "Failure record --\n");
 for(i=0; i<num_failed; i++)
  {
   if(!IF_NULL_OBJID(failed[i].ele1.objid))
    EMintf_getname(&failed[i].ele1, NULL, elename1);
   if(!IF_NULL_OBJID(failed[i].ele2.objid))
    EMintf_getname(&failed[i].ele2, NULL, elename2);
   else strcpy(elename2, "Unknown");

   if(!IF_NULL_OBJID(failed[i].ele1.objid))
    fprintf((FILE *) ptr, " Element:           %s\n", elename1);
   if(!IF_NULL_OBJID(failed[i].ele2.objid))
    fprintf((FILE *) ptr, " Analyzing against: %s\n", elename2);
   fprintf((FILE *) ptr, " Error:             ");
   junk = EFprintcode(ptr, failed[i].msgcode);

   if(failed[i].type == EMqualitative)
    {
     if(failed[i].msgcode == EMS_E_BoolFail)
      fprintf((FILE *) ptr, "  - Volume element not created");
     else if(failed[i].msgcode == EMS_E_Intersect)
      fprintf((FILE *) ptr, "  - Interference curves not created");
    }
   else if(failed[i].type == EMxsection)
    {
     if(failed[i].msgcode == EMS_E_Intersect)
      fprintf((FILE *) ptr, "  - Could not generate cross section");
     else if(failed[i].msgcode == EMS_E_NoMoreLoops)
      fprintf((FILE *) ptr, "  - Analysis areas not created");
     else if(failed[i].msgcode == EMS_E_Fail)
      fprintf((FILE *) ptr, "  - Failure in computing min max distances");
    }
   fprintf((FILE *) ptr, "\n");
  }
}



void EMintf_free(inptr, num)
struct EMSintf *inptr;
IGRint	num;
{
 IGRint i, j, m, n;

 for(i=0; i<num; i++)
  {
   if( (inptr[i].intfInfoType == EMqualitative) && inptr[i].info.qualitative)
     om$dealloc(ptr = inptr[i].info.qualitative);
   else if( (inptr[i].intfInfoType == EMxsection) && inptr[i].info.xsec)
    {
     for(j=0; j<inptr[i].numintf; j++)
      for(m=0; m<NumIntfCases; m++)
       for(n=0; n<2; n++)
        if(inptr[i].info.xsec[j].linesegs[m][n])
	  om$dealloc(ptr = inptr[i].info.xsec[j].linesegs[m][n]);
     om$dealloc(ptr = inptr[i].info.xsec);
    }

  }
 if(inptr) om$dealloc(ptr = inptr);
}


void EMintf_recordFailure(EMmsg, Ele1, Ele2, num_sofar, failed, 
				    bufSize, type)
IGRlong			*EMmsg;
struct GRlc_info	*Ele1, *Ele2;
IGRint			*num_sofar;
struct EMSintf_failure	**failed;
IGRint			*bufSize;
enum EMSintfInfoType	type;
{
 
 if(!*bufSize && !*failed)
  {
   *failed = (struct EMSintf_failure *) om$malloc(size = ResultBufInc *
					sizeof(struct EMSintf_failure));
   *bufSize = ResultBufInc;
  }
 else if(!*bufSize)
  {
   *failed = (struct EMSintf_failure *) om$realloc(ptr = (char *) *failed, 
			size = ResultBufInc * sizeof(struct EMSintf_failure));
   *bufSize = ResultBufInc;
  }

 if(*failed && *bufSize)
  {
   (*failed)[*num_sofar].type = type;
   if(Ele1)(*failed)[*num_sofar].ele1 = Ele1->located_obj;
   else (*failed)[*num_sofar].ele1.objid = NULL_OBJID;

   if(Ele2)(*failed)[*num_sofar].ele2 = Ele2->located_obj;
   else (*failed)[*num_sofar].ele2.objid = NULL_OBJID;

   if(EMmsg)(*failed)[*num_sofar].msgcode = *EMmsg;
   if(EMmsg)*EMmsg = EMS_S_Success;
   (*num_sofar)++;
   (*bufSize)--;
  }
 else *EMmsg = EMS_E_NoDynamicMemory;

}



void EMintfDisplay(disenv, obj, hilite)
struct GRmd_env *disenv;
struct GRid	*obj;
IGRboolean	hilite;
{
 IGRlong	sts, EMmsg;
 IGRshort	*mxtyp;
 IGRdouble	*mx;
 struct GRid	md;
 enum GRdpmode	Display_Mode;
 IGRint		m;

 mxtyp = &disenv->md_env.matrix_type;
 mx = disenv->md_env.matrix;
 md = disenv->md_id;

 for(m=0; m< (hilite ? 2 : 1); m++)
  {
   Display_Mode = m ? GRhd : GRbd;
   sts = om$send(msg = message GRgraphics.GRdisplay(
             		&EMmsg, mxtyp, mx, &Display_Mode, &md),
            targetid = obj->objid, senderid = NULL_OBJID, 
            targetos = obj->osnum);
  }
}




void EMintf_getident(id,str) 
struct GRid *id;
IGRchar *str;
{

    IGRlong sts = OM_S_SUCCESS, msg = EMS_S_Success;
    struct GRobj_info info;

    sts = om$send(msg = message GRgraphics.GRgetobjinfo(&msg, &info),
                  senderid = NULL_OBJID,
                  targetid = id->objid,
                  targetos = id->osnum);

    if (sts & msg & 1)
        strcpy(str,info.type);
    else
        strcpy(str,"unknown");

}

IGRlong EMintf_getrange(id,disenv,rng)
struct GRid     *id;
struct GRmd_env *disenv;
GRrange         rng;

{
 IGRboolean    world;
 IGRlong sts = OM_S_SUCCESS, msg = EMS_S_Success;

    world=TRUE;
    sts = om$send( msg = message GRgraphics.GRgetrang(&msg,
        &disenv->md_env.matrix_type,disenv->md_env.matrix,&world,rng),
        senderid = NULL_OBJID, 
        targetid = id->objid,
        targetos = id->osnum);

    
    if (! (sts & msg & 1))
        msg=EMS_E_Fail;
 
    return(msg);
}

IGRlong EMintf_keypoint(id,disenv,keypoint)
struct GRid     *id;
struct GRmd_env *disenv;
IGRpoint        keypoint;

{
    struct GRparms key_parm;
    struct IGRline dummyline;
    IGRpoint pt1, pt2;
    IGRlong sts = OM_S_SUCCESS, msg = EMS_S_Success;
    IGRlong RetErr;
    
     pt1[0]=0; 
     pt1[1]=0; 
     pt1[2]=0; 
     pt2[0]=0;
     pt2[1]=0; 
     pt2[2]=1;
   
     dummyline.point1=pt1;
     dummyline.point2=pt2;

     sts = om$send (msg = message GRvg.GRkeypoint
                               (&msg, &disenv->md_env.matrix_type,
                                disenv->md_env.matrix, &dummyline,
                                keypoint, &key_parm),
             senderid = NULL_OBJID,
             targetid = id->objid,
             targetos = id->osnum);

   
     RetErr=msg;
       
     return(RetErr);


}


void EMintf_christen(toid, refid1, refid2, str, elename)
struct GRid	*toid, *refid1, *refid2;
IGRchar		*str, *elename;
{
 IGRlong	sts = OM_S_SUCCESS, rc = EMS_S_Success;
 IGRchar	locname[DI_PATH_MAX], junk[2][DI_PATH_MAX], loccopy[DI_PATH_MAX], 
		num[10];
 IGRint		i;

 if(refid1)
  sprintf(junk[0], "%d.%d", refid1->osnum, refid1->objid);
 if(refid2)
  {
   if(refid1)
    sprintf(junk[1], ".%d.%d", refid2->osnum, refid2->objid);
   else
    sprintf(junk[1], "%d.%d", refid2->osnum, refid2->objid);
  }

 if(refid1)
  strcpy(locname, junk[0]);

 if(refid2)
  {
   if(refid1) strcat(locname, junk[1]);
   else strcpy(locname, junk[1]);
  }

 for(i=0; i<MaxNameDup; i++)
  {
   strcpy(loccopy, locname);
   sprintf(num, ".%d", i+1);
   strcat(loccopy, num);

   if(str)
    {
     strcat(loccopy, ".");
     strcat(loccopy, str);
    }

   sts = om$send(msg = message GRvg.GRputname(&rc, loccopy), 
		senderid = NULL_OBJID, targetid = toid->objid, 
		targetos = toid->osnum);
   if(1&rc&sts)
    {
     if(elename) strcpy(elename, loccopy);
     break;
    }
  }
}

#include <sys/types.h>
#include <time.h>
char * EMgettime()
{

  time_t ret,timinsec;
  time_t *timeptr;

  timinsec=0;
  timeptr=(&timinsec);

  ret=time(timeptr);

  if ( ret != -1 )
   {
    return(ctime(timeptr));
   }
  else
    return(0);
}


#include "DItypedef.h"
#include "DIdef.h"	/* DI_PATH_MAX */
#include "DIglob.h"	/* DItranslate */
#include "DImacros.h"   /* di$.. */
#include "DIprims.h"
#include "OMlimits.h"
#include "OMprimitives.h"

#define Gap	3
void EMintf_report (numcked,
                    ele1, num_ele1, setnum1, setinfo1,
                    ele2, num_ele2, setnum2, setinfo2,
                    result, num_result, options, ptr)
IGRint	numcked;
struct GRlc_info *ele1, *setinfo1;
IGRint num_ele1, setnum1;
struct GRlc_info *ele2, *setinfo2;
IGRint		num_ele2, setnum2;
struct EMSintf  *result;
IGRint		num_result;
IGRushort options;
IGRchar		*ptr;
{
 IGRint			i, j, totintf;
 struct EMSintf		*this_result;
 struct EMSintf_qualitative *ptr1;
 struct EMSintf_xsec	*ptr2;
 IGRchar		elename[DI_PATH_MAX];
 IGRchar		elename1[DI_PATH_MAX], elename2[DI_PATH_MAX];
 IGRboolean		quali = FALSE, xsec = FALSE, osfound = FALSE;
 extern void		MSget_master_string();
 IGRdouble		factor;
 IGRchar		master_units[80];
 GRspacenum		objos,tosnum;
 IGRint 		m, n, p;
 IGRlong 		msg;
 extern char            *EMgettime();
 IGRchar                obj_identifier[30];
 char                   obj_filenm[OM_K_MAXOSNAME_LEN];
 GRrange                rng;
 IGRpoint               keypt;
 struct GRlc_info	*eleinfo;

 fprintf ((FILE *)ptr, "\n  INTERFERENCE ANALYSIS REPORT           Run Date: %s\n",EMgettime());

 EMintf_getname (&setinfo1->located_obj, &setinfo1->module_info, elename1);
 if (setnum1 == setnum2)
   fprintf ((FILE *)ptr, "\tSet #%d (%s)\n\n", setnum1, elename1);
 else
   {
   EMintf_getname (&setinfo2->located_obj, &setinfo2->module_info, elename2);
   fprintf ((FILE *)ptr, "\tSet #%d (%s) - Set #%d (%s)\n\n",
    setnum1, elename1, setnum2, elename2);
   }

 if(num_result)
  {
   if(result[0].intfInfoType == EMqualitative)
    quali = TRUE;
   else if(result[0].intfInfoType == EMxsection)
    xsec = TRUE;

   fprintf ((FILE *)ptr, "\tSUMMARY:\n");
   fprintf ((FILE *)ptr, "\tNumber of elements in Set #%d = %d\n",
    setnum1, num_ele1);
   if (setnum1 != setnum2)
     fprintf ((FILE *)ptr, "\tNumber of elements in Set #%d = %d\n",
      setnum2, num_ele2);
   if (quali)
    {
    totintf = 0;
    for (i=0; i<num_result; i++)
      for (j=0; j<result[i].numintf; j++)
        totintf++;
    fprintf ((FILE *)ptr, "\tNumber of unique pairs of interfering elements = %d\n",
     totintf);
    if (setnum1 != setnum2)
      fprintf ((FILE *)ptr, "\tNumber of interfering elements in Set #%d = %d\n",
       setnum1, num_result);
    else
      fprintf ((FILE *)ptr, "\tNumber of elements describing the interferences = %d\n",
       num_result);
    }
   fprintf ((FILE *)ptr, "\n");

   if(xsec && result)
    {
     for(i=0; (i<num_result) && !osfound; i++)
      for(j=0; (j<result[i].numintf) && !osfound; j++)
       for(m=0; (m<NumIntfCases) && !osfound; m++)
        for(n=0; (n<2) && !osfound; n++)
         {
          if(!result[i].info.xsec[j].NumOcc[m][n]) continue;
          objos = result[i].info.xsec[j].linesegs[m][n][0].osnum;
	  osfound = TRUE;
         }
     if(osfound)
      {
       MSget_master_string(&msg, objos, master_units, &factor);
       if(!(1&msg)) osfound = FALSE;
       fprintf((FILE *)ptr, "\tAll distances in %s\n", master_units);
      }
    }

   fprintf ((FILE *)ptr, "\tDETAILS:\n");
   for(i=0; i<num_result; i++)
    {
     this_result = &result[i];
     EMintf_getname(&this_result->eleminfo.located_obj,
      &this_result->eleminfo.module_info, elename);
     if(quali)
      {
       fprintf((FILE *)ptr, "\t%2d) Element - %s - interferes with %d element(s)\n",
        i+1, elename, this_result->numintf);

       eleinfo = &this_result->eleminfo; 
       EMintf_getident (&eleinfo->located_obj, obj_identifier);
       fprintf((FILE *)ptr, "\t    identifier : %s\n", obj_identifier);
       tosnum= eleinfo->located_obj.osnum;
       om$os_number_to_name (osnum=tosnum, osname=obj_filenm); 
       fprintf((FILE *)ptr, "\t    filename   : %s\n", obj_filenm);
       if ((EMintf_getrange (&eleinfo->located_obj, &eleinfo->module_info,
             rng)) == EMS_E_Fail)
         fprintf((FILE *)ptr, "\t    range      : unknown\n");
       else
         {
         fprintf((FILE *)ptr, "\t    range (min): %g %g %g\n", 
          rng[0], rng[1], rng[2]);
         fprintf((FILE *)ptr, "\t    range (max): %g %g %g\n",
          rng[3], rng[4], rng[5]);
         }
       if ((EMintf_keypoint (&eleinfo->located_obj, &eleinfo->module_info,
             keypt)) == EMS_E_Fail)
         fprintf((FILE *)ptr, "\t    keypoint   : unknown\n");
       else
         fprintf((FILE *)ptr, "\t    keypoint   : %g %g %g\n",
          keypt[0], keypt[1], keypt[2]); 

       for(j=0; j<this_result->numintf; j++)
        {
         ptr1 = &this_result->info.qualitative[j];
         EMintf_getname(&ptr1->against_eleminfo.located_obj,
          &ptr1->against_eleminfo.module_info, elename);
         fprintf((FILE *)ptr, "\t\t%2d) %s\n", j+1, elename);
         EMintf_getident(&ptr1->against_eleminfo.located_obj,obj_identifier);
         fprintf((FILE *)ptr, "\t\t    identifier : %s\n", obj_identifier);
         tosnum=(&ptr1->against_eleminfo.located_obj)->osnum;
         om$os_number_to_name(osnum=tosnum,osname=obj_filenm); 
         fprintf((FILE *)ptr, "\t\t    filename   : %s\n", obj_filenm);
         if ((EMintf_getrange(&ptr1->against_eleminfo.located_obj,
               &ptr1->against_eleminfo.module_info,rng)) == EMS_E_Fail)
          fprintf((FILE *)ptr, "\t\t    range      : unknown\n");
         else
          {
          fprintf((FILE *)ptr, "\t\t    range (min): %g %g %g\n", 
           rng[0], rng[1], rng[2]);
          fprintf((FILE *)ptr, "\t\t    range (max): %g %g %g\n",
           rng[3], rng[4], rng[5]);
          }
         if ((EMintf_keypoint(&ptr1->against_eleminfo.located_obj,
               &ptr1->against_eleminfo.module_info,keypt)) == EMS_E_Fail)
          fprintf((FILE *)ptr, "\t\t    keypoint   : unknown\n");
         else
          fprintf((FILE *)ptr, "\t\t    keypoint   : %g %g %g\n",
           keypt[0], keypt[1], keypt[2]); 
        }
      }
     else
      {
       fprintf((FILE *)ptr, "Primary element- %s\n", elename);
       fprintf((FILE *)ptr, "---------------\n");

       ptr2 = &this_result->info.xsec[0];
       if(!IF_NULL_OBJID(ptr2->areas[0].objid))
        {
         EMintf_getname(&ptr2->areas[0], NULL, elename);
         fprintf((FILE *)ptr, "Cross section - %s\n", elename);
        }
       for(j=0; j<this_result->numintf; j++)
        {
         ptr2 = &this_result->info.xsec[j];
         EMintf_getname(&ptr2->against_eleminfo.located_obj,
          &ptr2->against_eleminfo.module_info, elename);
         fprintf((FILE *)ptr, "%d) Check element - %s\n", j+1, elename);
         fprintf((FILE *)ptr, "   -------------\n");
         if(!IF_NULL_OBJID(ptr2->areas[1].objid))
          {
           EMintf_getname(&ptr2->areas[1], NULL, elename);
           fprintf((FILE *)ptr, "Cross section -     %s\n", elename);
          }
         if(!IF_NULL_OBJID(ptr2->areas[2].objid))
          {
           EMintf_getname(&ptr2->areas[2], NULL, elename);
           fprintf((FILE *)ptr, "Interference area - %s\n", elename);
          }
         fprintf((FILE *)ptr, "Type                         Dist                  Segments\n");
         fprintf((FILE *)ptr, "----                         ----                  --------\n");
         for(m=0; m<NumIntfCases; m++)
          {
  	   for(n=0; n<2; n++)
  	    {
 	     if(!ptr2->NumOcc[m][n]) continue;
	
	     if( (m==Intf) && (n==0))
	      fprintf((FILE *)ptr, "Min interference          ");
	     else if( (m==Intf) && (n==1))
	      fprintf((FILE *)ptr, "Max interference          ");
	
	     if( (m==NestedIntf) && (n==0))
	      fprintf((FILE *)ptr, "Min nested interference   ");
	     else if( (m==NestedIntf) && (n==1))
	      fprintf((FILE *)ptr, "Max nested interference   ");
	
	     else if( (m==NestedCl) && (n==0))
	      fprintf((FILE *)ptr, "Min nested clearance      ");
	     else if( (m==NestedCl) && (n==1))
	      fprintf((FILE *)ptr, "Max nested clearance      ");
	
	     else if( (m==DisjointCl) && (n==0))
	      fprintf((FILE *)ptr, "Min disjoint clearance    ");
	     else if( (m==DisjointCl) && (n==1))
	      fprintf((FILE *)ptr, "Max disjoint clearance    ");
	
	     if(osfound)
	      fprintf((FILE *)ptr, "%3.13lf", (ptr2->dist[m][n])/factor);
	     else
	      fprintf((FILE *)ptr, "%3.13lf", ptr2->dist[m][n]);
	
             for(p=0; p<ptr2->NumOcc[m][n]; p++)
	      {
               EMintf_getname(&ptr2->linesegs[m][n][p], NULL, elename);
	       if(!p)
                fprintf((FILE *)ptr, "    %s\n",
                 elename);
	       else
                fprintf((FILE *)ptr, "                                             %s\n",
                 elename);
  	      }
	    }
          } 
         fprintf((FILE *)ptr, "\n");
        }
       }
      }
    }
   else
    {
     fprintf ((FILE *)ptr, "\tNo interference found\n");
     goto wrapup;
    }

wrapup:;
}

end implementation EMSsurface;

