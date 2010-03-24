/*
-------------------------------------------------------------------------------
Name:			OMclasses.c
Author:			Chuck Puckett
Creation Date:		10-sep-1985
Operating System(s):	Unix SYSV, v2
Abstract:

	This module contains class definition routines.

Revision History:

cgp001	31-oct-1985	Add channel definition validity checks against 
			relation specifications.

cgp002	12-nov-1985	Change create classes.

jhm001  21-nov-1985     Add test to OM_create_classes to set ordered bit in
			chan defn if the relation is ordered.

cgp003	26-nov-1985	Better version mismatch warning messages. Change 
			include setup to be more efficient.

cgp004	5-dec-1985	Take out "consistent" check on minor version number
			mismatch

ems001  13-mar-1986     Added class ancestry and parent routines.

ems002  24-mar-1986     Added OM_report_class_version routines.

ems003  16-may-1986     Added classid range check to OM_report_class_version.

rme001  27-june-1986    Removed class support routines to OMclasssupp.c

jaj001  14-jul-1986	Major 4.0 changes to OM_create_class function
			(such as renaming it to som_create_class)

ems004  21-may-1987     Removed make_message calls.

tlg	18-jun-1987	Add shared memory calls

geo001	23-jul-1987	Remove OM_Gf_consistent_class

plh     06-aug-1987	Rework create_class logic for 4.3

rme	25-may-1988	Remove MOSD.pass_thru, now send add_class message
			directly to each object space.

-------------------------------------------------------------------------------
*/

#include	"exsysdep.h"
#include 	"OMobjectcomm.h"
#include 	"OMmetaclass.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include	"OMintprims.h"
#include	"OMport.h"
#include	<assert.h>
#include	<string.h>
#include	<stdio.h>

extern	OMuword			OM_Gw_min_opp_major_version;
extern	OMuword			OM_Gw_last_opp_minor_version;
extern	OMuword			OM_Gw_major_version;
extern	OMuword			OM_Gw_minor_version;
extern  OMuword                 OMObjSpace_OPP_add_class_method_index;
extern  OMuword                 OMMOSD_OPP_get_OS_list_method_index;
extern  int			OM_Gf_class_init;

/*--------------------------------------*/
/*  stub function for rejected methods  */
/*--------------------------------------*/

int  som_stub_method()
{
   return (OM_W_REJECTED_METHOD);
}

static int add_class_to_all_os (name, w_classid)
/*-------------------------------------------------------------------------
   Sends an add class message to all object spaces to add the
   specified class.
---------------------------------------------------------------------------*/
char    *name;		/* class name */
OMuword w_classid;	/* active classid */
{
   int oso_count;	/* returned count of the number of object space objects */
   int sts;
   OMuword ii;

   struct get_OS_list_args_struct
   {
      int        size;		/* size of arrays below. */
      int        *p_count;	/* ptr to return count. */
      OMuword    *osnums;	/* array of all object space numbers. */
      OM_S_OBJID *os_objids;	/* array of all object space oids. */
   } get_OS_list_args;

   struct add_class_args_struct
   {
      char    *name;
      OMuword active_classid;
   } add_class_args;

   OM_S_MESSAGE get_OS_list_mess, add_class_mess;	

   /*------------------------------------------------------------------*/
   /*  Get a list of all the OS numbers and oids from the MOSD object. */
   /*------------------------------------------------------------------*/

   get_OS_list_mess.select.DefClassid = OM_K_OMMOSD_ACTCLASSID;
   get_OS_list_mess.select.ReqClassid = OM_K_OMMOSD_ACTCLASSID;
   get_OS_list_mess.select.FuncIndex  = OMMOSD_OPP_get_OS_list_method_index;
   get_OS_list_mess.size              = sizeof( struct get_OS_list_args_struct );
   get_OS_list_mess.p_arglist         = (char *)&get_OS_list_args;
   
   get_OS_list_args.size = OM_Gw_maxOS;
   get_OS_list_args.p_count = &oso_count;
   get_OS_list_args.osnums = 
      (OMuword *)om$malloc(size=(OM_Gw_maxOS*sizeof(OMuword)));
   get_OS_list_args.os_objids = 
      (OM_p_OBJID)om$malloc(size=(OM_Gw_maxOS*sizeof(OM_S_OBJID)));

   if (!(1&(sts = om$send (targetid = OM_GO_current_MOSD,
                           targetos = 0,
                           senderid = NULL_OBJID,
                           msg = &get_OS_list_mess) )))
   {
#ifdef DEBUGADDCLASS
printf("bad sts from get_OS_list\n");
om$report_error(sts=sts);
#endif
      return (sts);
   }

   /*------------------------------------------------*/
   /*  Loop through and send add_class to all OSOs.  */
   /*------------------------------------------------*/

   add_class_mess.select.DefClassid = OM_K_OMOBJSPACE_ACTCLASSID;
   add_class_mess.select.ReqClassid = OM_K_OMOBJSPACE_ACTCLASSID;
   add_class_mess.select.FuncIndex  = OMObjSpace_OPP_add_class_method_index;
   add_class_mess.size              = sizeof( struct add_class_args_struct );
   add_class_mess.p_arglist         = (char *)&add_class_args;
   
   add_class_args.name = name;
   add_class_args.active_classid = w_classid;
   
   for (ii=0; (int) ii < oso_count; ++ii)
   {
      if (!(1&(sts = om$send(targetid = get_OS_list_args.os_objids[ii], 
                             targetos = get_OS_list_args.osnums[ii],
                             senderid = NULL_OBJID,
                             msg = &add_class_mess) )))
      {
#ifdef DEBUGADDCLASS
printf("bad send of add class to osnum %d:  ",get_OS_list_args.osnums[ii]);
om$report_error(sts=sts);
#endif
         return (sts);
      }
   }/* for all OS */
                  
   om$dealloc(ptr=(char *) get_OS_list_args.osnums);
   om$dealloc(ptr=(char *) get_OS_list_args.os_objids);

   return (OM_S_SUCCESS);
}

/*
-------------------------------------------------------------------------------
Routine Name:	som_create_class
Abstract:

  This routine takes class 
  definition omputs and creates a Class Definition
  structure,  filling in certain areas.

Sample Invocation:

	som_create_class (p_arglist, p_classid)

Entry Variable Description:

OM_p_CREATECLASS_ARGS		p_arglist
OMuword				*p_classid

Modules Invoked:
	om$get_classid
	om$calloc

-------------------------------------------------------------------------------
*/
int som_create_class (p_arglist, p_classid)

OM_p_CREATECLASS_ARGS		p_arglist;
OMuword				*p_classid;

{
  OM_p_CLASSDEF		p_ACLD;
  OMuword		sts, ii, jj, kk, dummy;
  int old_class_index = OM_Gw_next_class_index, len;
  char *new_p, new_class=0;
  OM_p_CHANNEL_TYPE_DEFN tmp_type;
  OMuword                **tmp_classids;
  OM_p_METHDEFN		p_methdefns;
  int                   Root_processed;

#ifdef DEBUG
  printf ( "*****  som_create_class:   %s    *****\n", p_arglist->s_name);
  printf ( " version %d.%d OPPversion %d.%d\n",
	   p_arglist->MajVer, p_arglist->MinVer, 
	   p_arglist->oppMajVer, p_arglist->oppMinVer);
  printf ( " Instance_size = %d\n", p_arglist->InstanceSize);
  printf ( " NewInstanceSize = %d\n", p_arglist->NewInstanceSize);
  printf ( " numchans = %d\n", p_arglist->NumChannels);
  printf ( " Numvlas  = %d\n", p_arglist->NumVLAs);
  printf ( " NumMethods = %d\n", p_arglist->NumMethods);
  printf ( " NumParents = %d\n", p_arglist->NumParents);
#endif

  *p_classid = (OMuword) -1;/* assume we won't create this class because of  */
			/* errors, so return an obviously bad classid */


/**********************************************************************/
/******************       check opp version numbers   *****************/
/**********************************************************************/

  if (p_arglist->oppMajVer != OM_Gw_min_opp_major_version)
    {
       OMERRMSG3("OM_F_VERSION_MISMATCH, Class %s compiled w/ incompatible opp %d.%d\n", 
 	 p_arglist->s_name, p_arglist->oppMajVer, p_arglist->oppMinVer);
       OMERRMSG3("OM is version %d.%d, and requires opp %d.x\n", 
	 OM_Gw_major_version, OM_Gw_minor_version, OM_Gw_min_opp_major_version);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_F_VERSION_MISMATCH);
    }

  if (p_arglist->oppMinVer > OM_Gw_last_opp_minor_version)
    {
      OMWARNING1 
        ("OM-W-VERSION_MISMATCH, Class %s opped by newer minor version than known\n", 
	 p_arglist->s_name);
      OMWARNING2 ("  OM is version %d.%d; \n", 
        OM_Gw_major_version, OM_Gw_minor_version);
      OMWARNING2 ("  Current version of opp is %d.%d\n", 
	OM_Gw_min_opp_major_version, OM_Gw_last_opp_minor_version);
      OMWARNING2 ("  opp that generated this class was version %d.%d\n\n", 
	p_arglist->oppMajVer, p_arglist->oppMinVer);
    }
  

/* check for valid class name string and to insure we still have room */

  if (strlen(p_arglist->s_name) >= OM_K_MAXCLASS_LEN)	/* name too long ? */
  {
    OMERRMSG2("OM_E_BADCLASSNAME, Class name %s is longer than %d character maximum.\n", p_arglist->s_name, OM_K_MAXCLASS_LEN);
    OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
    return (OM_E_BADCLASSNAME);
  }


  
/*************************************************************************/
/* insure that parent class(es) for this class is here, and that this 
   class has not been defined yet (that is, that no class of the same 
   name with the same ancestor has been defined. 1st, scan for "already 
   defined"...
*/
/*************************************************************************/
  OM_Gf_class_init = 1;
  if (OM_S_SUCCESS == om$get_classid (classname = p_arglist->s_name, p_classid = &dummy))
    {
      *p_classid = dummy;

      OM_Gf_class_init = 0;
/*    OMWARNING1("OM_W_CLASS_EXISTS, Class %s already exists.\n",
                  p_arglist->s_name);
      OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
      return (OM_W_CLASS_EXISTS); */

      return(OM_S_SUCCESS);
    }
    OM_Gf_class_init = 0;

  
/**********************************************************************/
/*        check to see that this class has at least one parent        */
/*		(unless it's the root class)			      */
/**********************************************************************/

  if ( p_arglist->ancestors == NULL )
    if ( 0 != strcmp (p_arglist->s_name, "Root"))
    {
      OMERRMSG1("OM_E_NOPARENT, Class %s has no ancestors.\n", p_arglist->s_name);
      OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
      return(OM_E_NOPARENT);
    }

/**********************************************************************/
/* For each parent in this class' p_arglist->ancestors list, check 
/*   to see that:
/*   	1) the parent class already has an ACLD (else create parent)
	2) the p_arglist MajVer matches the parent's MajVer (else ERROR)
	3) the p_arglist MinVer matches the parent's MinVer else
		      WARNING
*/

/**********************************************************************/

 if ( 0 != strcmp (p_arglist->s_name, "Root"))
  for ( ii = 0 ; ii <  p_arglist->NumParents ; ii++ )
    {

    /* define a local temporary variable to cut down on access time */
    OM_p_ANCESTRY oldman = &p_arglist->ancestors[ii];
    OM_p_CLASSDEF p_parent;

#ifdef DEBUG
    printf ( " parent #%d has classid %d\n", ii, *oldman->p_classid);
#endif

      if ( *oldman->p_classid == OM_K_CLASS_NOT_DEFINED) /* see "OMminimum.h"*/
  	{
#if 1
          if (oldman->p_create_args) {
             OM_p_CREATECLASS_ARGS cca = 
               (OM_p_CREATECLASS_ARGS)((OM_p_FUNCPTR)oldman->p_create_args)();
             som_create_class (cca, cca->p_class_id);
             *oldman->p_classid = *cca->p_class_id;
          }
          else {
             printf (" ===================================================\n");
             printf (" ***** Parent class undefined for dload of class %s\n",
                       p_arglist->s_name);
             printf (" ===================================================\n");
             return(OM_E_NOPARENT);
          }
#else
	  /* this particular parent has no ACLD */
	  OMERRMSG2("OM_E_NOPARENT, Class %s claims parent with classid %u, which is undefined.\n",
		     p_arglist->s_name, *oldman->p_classid );
	  OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
	  return(OM_E_NOPARENT);
#endif
	}

      /**********************************************************************/
      /* this parent is here, now check Major version compile compatibility */
      /**********************************************************************/

      p_parent = OM_GA_active_classes[*oldman->p_classid];
      if ( oldman->MajVer != p_parent->w_major_version )
	{
          char *name = OM_GA_active_classes[*oldman->p_classid]->s_name;
	  /*  parent class' MajVer doesn't match this class';
	      look up parent class' name for ERROR message    */
	  OMERRMSG2("OM_W_BADPARENT, Class %s was compiled with old parent %s\n",
	            p_arglist->s_name, name);
	  OMERRMSG2("Parent class' expected version:  V%d.%d\n",
		    oldman->MajVer, oldman->MinVer );
	  OMERRMSG2("                 found version:  V%d.%d\n",
		    p_parent->w_major_version, p_parent->w_minor_version);
	  OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
	  return(OM_F_VERSION_MISMATCH);
	}

      /***************************************************/
      /*  now check Minor version compile compatibility  */
      /***************************************************/

      if ( oldman->MinVer != p_parent->w_minor_version )
	{
	  /*  parent class' MinVer doesn't match this class';
	      look up parent class' name for WARNING message    */
	  OMWARNING2("OM_W_BADPARENT, Class %s was compiled with old parent %s\n",
	    	     p_arglist->s_name,
		     OM_GA_active_classes[ *oldman->p_classid ] -> s_name );
	  OMWARNING2("Parent class' expected version:  V%d.%d\n",
		    oldman->MajVer, oldman->MinVer );
	  OMWARNING2("                 found version:  V%d.%d\n",
		    p_parent->w_major_version, p_parent->w_minor_version );
	}

    }      /* end of 'for' loop */



/*****************************************************************/
/*                     now, allocate an ACLD                     */
/*****************************************************************/

  if (NULL == (p_ACLD = 
    (OM_S_CLASSDEF *) om$calloc (num = 1, size =  sizeof(OM_S_CLASSDEF) ))) 
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
    }

  *p_classid =  OM_Gw_next_class_index;

#ifdef DEBUG
  printf ( " classid is %d\n", *p_classid);
#endif  

 /************************************************/
 /* Do we need to grow the active classes array? */
 /************************************************/

 if (OM_Gw_next_class_index >= OM_Gw_numclasses)
    {
   
    /* We have a class that was loaded at run time. */

    new_class = TRUE;
    new_p = om$realloc( ptr=(char *) OM_GA_active_classes, 
            size=(++OM_Gw_numclasses)*sizeof(OM_p_FUNCPTR) );
    if ( new_p == NULL ) return(OM_E_NODYNMEM);
    OM_GA_active_classes = (OM_p_CLASSDEF *)new_p;
    }

  /***************************************************************/
  /*                allocate space for TransMap:                 */
  /*                ----------------------------		 */
  /*   FIRST, FIND:
  /*   p_ACLD-> w_baseclass = lowest non-zero classid in components list   */
  /*   p_ACLD-> w_maxclass  = highest	    classid in components list   */
  /***************************************************************/

#define  OM_K_MAX_OMUWORD	65535

    p_ACLD-> w_baseclass = OM_K_MAX_OMUWORD;	    /* initialize this really high  */
    p_ACLD-> w_maxclass  = 0;			    /* initialize this very low     */

  {
    OM_p_COMPCLASSDEF	p = p_arglist->components, lastp = p + p_arglist->NumComponents;
    
    for ( ;   p <  lastp  ;  p++ )
      {
	OMuword		pcld = *p-> p_classid;

#ifdef DEBUG
	printf ( " component is classid#%d\n", pcld);
#endif
	if ( (pcld > 0) && (pcld < p_ACLD->w_baseclass) )
	    p_ACLD->w_baseclass = pcld;

	if (  pcld > p_ACLD->w_maxclass )
	    p_ACLD->w_maxclass = pcld;
      }
    }

#ifdef DEBUG
   printf ( " baseclass = %d    maxclass = %d\n\n",
	    p_ACLD->w_baseclass, p_ACLD->w_maxclass);
#endif

     /**************************************/
     /*  now, allocate the right amount of */
     /*        memory for TransMap	   */
     /**************************************/
if ( p_ACLD->w_maxclass  >  0 )  /* make sure w_maxclass got a good value */
  if ( NULL == ( p_ACLD-> p_transmap = (OMbyte *)
	om$calloc ( num = (p_ACLD->w_maxclass - p_ACLD->w_baseclass + 1), size = sizeof (OMbyte))))
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
	*p_classid = (OMuword) -1;
       OM_Gw_next_class_index = old_class_index;
       return (OM_E_NODYNMEM);
    }

   /****************************************************************/
   /*		allocate space for class'  MsgMap                  */
   /****************************************************************/

    if ( NULL == ( p_ACLD->MsgMap = (OM_S_MSGMAP *)
		om$calloc ( num = p_arglist->NumComponents, size = sizeof (OM_S_MSGMAP))))

       {
          OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
          OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
  	  *p_classid = (OMuword) -1;
          OM_Gw_next_class_index = old_class_index;
          return (OM_E_NODYNMEM);
       }

/*************************************************************************/
/************             start filling in the ACLD           ************/
/*************************************************************************/

  OM_GA_active_classes[OM_Gw_next_class_index] = p_ACLD; /* fill in table */

  p_ACLD -> w_classid 		=  OM_Gw_next_class_index++;  /* classid */

  strcpy 			(p_ACLD -> s_name, p_arglist->s_name);

/*if (p_ACLD->w_classid < OM_K_NUM_META_CLASSES)
    p_ACLD->p_createclass_args = (int *)p_arglist;
else */
  {
  /***** Allocate space for p_createclass_args out of shared memory ******/

   if (NULL == (p_ACLD->p_createclass_args = 
    (int *)om$calloc(num=1,size=sizeof(OM_S_CREATECLASS_ARGS) ))) 
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
    }

   OM_BLOCK_MOVE((int *)p_arglist,p_ACLD->p_createclass_args,
		sizeof(OM_S_CREATECLASS_ARGS) );

  /**********************************************************************/
  }


  p_ACLD -> w_major_version	=  p_arglist -> MajVer;
  p_ACLD -> w_minor_version	=  p_arglist -> MinVer;
  p_ACLD -> w_oppmaj_version	=  p_arglist -> oppMajVer;
  p_ACLD -> w_oppmin_version	=  p_arglist -> oppMinVer;
  p_ACLD -> p_instance_def	=  NULL;
  p_ACLD -> i_instance_size	=  p_arglist -> InstanceSize;
  p_ACLD -> NewInstanceSize	=  p_arglist -> NewInstanceSize;
  p_ACLD -> flags               =  0;

  if ( p_arglist->oppFlags & OM_CCAf_TAGGABLE )
     p_ACLD->flags |= OM_CLDf_TAGGABLE;

/*if (p_ACLD->w_classid < OM_K_NUM_META_CLASSES || */
if ( p_arglist->NumVLAs == 0 )
   p_ACLD->p_varlenarr_defns = p_arglist->p_VLAdefns;
else
  {
  /***** Allocate space for p_varlenarr_defns out of shared memory ******/

     if (NULL == (p_ACLD->p_varlenarr_defns = 
       (OM_p_VARLENARR_DEFN)om$calloc(num=p_arglist->NumVLAs,
   		   size=sizeof(OM_S_VARLENARR_DEFN) ))) 
     {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
     }

     OM_BLOCK_MOVE(p_arglist->p_VLAdefns,p_ACLD->p_varlenarr_defns,
   	(sizeof(OM_S_VARLENARR_DEFN)*p_arglist->NumVLAs) );

  /**********************************************************************/
  }

  p_ACLD -> w_num_varlenarrays	=  p_arglist -> NumVLAs;

  p_ACLD -> w_numparents 	=  p_arglist -> NumParents;

/*if (p_ACLD->w_classid < OM_K_NUM_META_CLASSES || */
if ( p_arglist->NumParents == 0 ) 
   p_ACLD->A_ancestor_list = p_arglist->ancestors;
else
  {
  /****** Allocate space for A_ancestor_list out of shared memory ******/

    if (NULL == (p_ACLD->A_ancestor_list = 
      (OM_p_ANCESTRY)om$calloc(num=p_arglist->NumParents,
		   size=sizeof(OM_S_ANCESTRY) ))) 
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
    }

    OM_BLOCK_MOVE(p_arglist->ancestors,p_ACLD->A_ancestor_list,
   	(sizeof(OM_S_ANCESTRY)*p_arglist->NumParents) );

  /*********************************************************************/
  }

  p_ACLD -> NumMsgClasses	=  p_arglist -> NumComponents;	

  p_ACLD -> w_numchannels	=  p_arglist -> NumChannels;

/*if (p_ACLD->w_classid < OM_K_NUM_META_CLASSES ||  */
if ( p_arglist->NumChannels == 0 )
   p_ACLD->ChanDefns = p_arglist->p_ChannelDefns;
else
  {
  /***** Allocate space for ChanDefns out of shared memory ******/
    if (NULL == (p_ACLD->ChanDefns = 
      (OM_p_CHANNEL_DEFN)om$calloc(num=p_arglist->NumChannels,
		   size=sizeof(OM_S_CHANNEL_DEFN) ))) 
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
    }

    OM_BLOCK_MOVE(p_arglist->p_ChannelDefns,p_ACLD->ChanDefns,
   	(sizeof(OM_S_CHANNEL_DEFN)*p_arglist->NumChannels) );

    for (ii=0; ii<p_arglist->NumChannels; ii++)
    {

      if (NULL == (p_ACLD->ChanDefns[ii].s_name = 
        om$calloc(num=1,
		   size=OM_K_MAXCHANNAME_LEN ))) 
      {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
      }
      strcpy(p_ACLD->ChanDefns[ii].s_name,p_arglist->p_ChannelDefns[ii].s_name);
      tmp_type = p_ACLD->ChanDefns[ii].p_type;

      if (NULL == (p_ACLD->ChanDefns[ii].p_type = (OM_p_CHANNEL_TYPE_DEFN)
        om$calloc(num=1,
		   size=sizeof(OM_S_CHANNEL_TYPE_DEFN)))) 
      {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
      }

      OM_BLOCK_MOVE (tmp_type, p_ACLD->ChanDefns[ii].p_type,
                     sizeof(OM_S_CHANNEL_TYPE_DEFN));      

      len = strlen(tmp_type->s_name) + 1;
      if (NULL == (p_ACLD->ChanDefns[ii].p_type->s_name = 
               om$malloc(size=len))) 
      {
        OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
        OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
        return (OM_E_NODYNMEM);
      }
      strncpy (p_ACLD->ChanDefns[ii].p_type->s_name, tmp_type->s_name, len);
      
      if ( p_ACLD->ChanDefns[ii].p_type->ClassCount )
      {
        tmp_classids = p_ACLD->ChanDefns[ii].p_type->classids;

        if ( p_ACLD->ChanDefns[ii].p_type->w_flags & OM_CH_restricted )
        {
          len = strlen((char *) tmp_classids) + 1;
          if (NULL == (p_ACLD->ChanDefns[ii].p_type->classids = (OMuword **)
            om$malloc(size=len))) 
          {
           OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
           OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
           return (OM_E_NODYNMEM);
          }
          strncpy ((char *) p_ACLD->ChanDefns[ii].p_type->classids,
             (char *) tmp_classids, len);
        }
        else
        {  
          if (NULL == (p_ACLD->ChanDefns[ii].p_type->classids = (OMuword **)
            om$calloc(num=p_ACLD->ChanDefns[ii].p_type->ClassCount,
		     size=sizeof(int)))) 
          {
           OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
           OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
           return (OM_E_NODYNMEM);
          }
          OM_BLOCK_MOVE(tmp_classids, p_ACLD->ChanDefns[ii].p_type->classids,
                    p_ACLD->ChanDefns[ii].p_type->ClassCount*sizeof(int));
        }
      }
    }

  /**********************************************************************/
  }

  p_ACLD -> w_nummethods	=  p_arglist -> NumMethods;

/*if (p_ACLD->w_classid < OM_K_NUM_META_CLASSES || */
if ( p_arglist->NumMethods == 0 )
   p_ACLD->p_methdefns = 0;
else
  {

  /***** Allocate space for p_methdefns out of shared memory ******/

#if 1
  if (NULL == (p_methdefns = 
    (OM_p_METHDEFN)om$calloc(num=p_arglist->NumMethods,
		   size=sizeof(OM_S_METHDEFN) ))) 
    {
       OMERRMSG1(
         "OM_E_NODYNMEM, No dynamic memory available to create class %s.\n",
         p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
    }

  p_ACLD->p_methdefns = p_methdefns;

  { /* Copy METHDEFNs into shared memory */
   register OM_p_METHDEFN p1 = p_arglist->p_MethDefns;
   register OM_p_METHDEFN p2 = p_methdefns;
   register OM_p_METHDEFN stop = p1 + p_arglist->NumMethods;

   for (; p1 < stop; ++p1)
    {
     /* Initialize method_index variable. */
     *(OMuword *)p1->next = p2->w_methidx = p1->w_methidx;
     p2->w_sizeargs = p1->w_sizeargs;
     p2->b_numargs = p1->b_numargs;
     p2->s_name = om$calloc(num=1, size=(strlen (p1->s_name)+1));
     if (!p2->s_name)
      {
       OMERRMSG1(
	"OM_E_NODYNMEM, No dynamic memory available to create class %s.\n",
	 p_ACLD->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_ACLD->s_name);
       return (OM_E_NODYNMEM);
      }
     strcpy(p2->s_name, p1->s_name);

#ifdef DEBUG
   printf("*** Address of methdefn: %x ***\n", p2);
   printf("         next      : %x\n", p2+1);
   printf("         w_methidx : %d\n", p2->w_methidx);
   printf("         w_sizeargs: %d\n", p2->w_sizeargs);
   printf("         b_numargs : %d\n", p2->b_numargs);
   printf("         s_name    : %s\n", p2->s_name);
#endif

     p2 = p2->next = p2 + 1;
    } /* for */
   (--p2)->next = 0; /* terminate list */
  } /* copy METHDEFNs */

#else /* old way */
  prev = NULL;  

  for (ii=0; ii<p_arglist->NumMethods; ii++)
  {
  if (NULL == (p_methdefns = 
    (OM_p_METHDEFN)om$calloc(num=1,
		   size=sizeof(OM_S_METHDEFN) ))) 
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
    }

   p_methdefns->next = prev;
   prev = p_methdefns;
  } 

  p_ACLD->p_methdefns = p_methdefns;
  p_arg_tmp = p_arglist;

  while ( p_arg_tmp->p_MethDefns != NULL )
   {
   p_methdefns->w_methidx = p_arg_tmp->p_MethDefns->w_methidx;
   p_methdefns->w_sizeargs = p_arg_tmp->p_MethDefns->w_sizeargs;
   p_methdefns->b_numargs = p_arg_tmp->p_MethDefns->b_numargs;
   p_methdefns->s_name = p_arg_tmp->p_MethDefns->s_name;
   if (NULL == (p_methdefns->s_name = 
        om$calloc(num=1,
		   size=(strlen (p_arg_tmp->p_MethDefns->s_name)+1))))
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_ACLD->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_ACLD->s_name);
       return (OM_E_NODYNMEM);
    }
   strcpy(p_methdefns->s_name,p_arg_tmp->p_MethDefns->s_name);

#ifdef DEBUG
   printf("*** Address of methdefn: %x ***\n", p_methdefns);
   printf("         next      : %x\n", p_methdefns->next);
   printf("         w_methidx : %d\n", p_methdefns->w_methidx);
   printf("         w_sizeargs: %d\n", p_methdefns->w_sizeargs);
   printf("         b_numargs : %d\n", p_methdefns->b_numargs);
   printf("         s_name    : %s\n", p_methdefns->s_name);
#endif

   p_arg_tmp->p_MethDefns = p_arg_tmp->p_MethDefns->next;
   p_methdefns = p_methdefns->next;
   }

#endif /* new way / old way */

  /**********************************************************************/

  }

  p_ACLD -> NumRecClasses	=  0;

  /* this class has no sub-classes yet ... */
  p_ACLD -> p_subclass_list	=  NULL;

   /*==============================*/
   /*  get initial size of object  */
   /*==============================*/

   if (!(1&(sts = om$vla_find_initial_size(p_cld=p_ACLD,p_size=&p_ACLD->initial_size))))
   {
      return (sts);
   }

   /****************************************************************/
   /*            fill  in  values   for  TransMap                  */
   /****************************************************************/

if ( p_ACLD->w_maxclass  >  0 )  /* make sure w_maxclass got a good value */
  {
             /* initialize it to OM_K_NULL_TRANS */
   {
   OMuint    tmphowmany = p_ACLD->w_maxclass - p_ACLD->w_baseclass + 1;
   for ( kk = 0; kk < tmphowmany ;  kk++)
	p_ACLD->p_transmap[kk] = OM_K_NULL_TRANS;
   }

#ifdef DEBUG
   printf ( "Filling in Transmap\n");
#endif

   for ( kk = 0 ;  kk < p_arglist->NumComponents ;   kk++)
	{
	 OMuword cid = *p_arglist->components[kk].p_classid;

	 int  tmpindex = cid - p_ACLD->w_baseclass; 
#ifdef DEBUG
         printf("cid = %d\n",cid);
         printf("tmpindex = %d\n",tmpindex);
#endif
	 if  ( tmpindex >= 0 )
	     p_ACLD->p_transmap[ tmpindex ] = (OMbyte) kk;
	}

#ifdef DEBUG
   {
   OMuint    tmphowmany = p_ACLD->w_maxclass - p_ACLD->w_baseclass + 1;
   for ( kk = 0; kk < tmphowmany ;  kk++)
         printf ( " index #%d has value %d\n", kk, p_ACLD->p_transmap[kk] );
   }
   printf ( "\nFilling in MsgMap \n");
#endif
  }

  /*****************************************************************/
  /*                     Fill in MsgMap                            */
  /*****************************************************************/

  Root_processed = 0;

  for ( ii = 0;  ii < p_arglist->NumComponents;	  ii++ )
    {

#ifdef DEBUG
    printf ( " ---values coming from---\n");
    printf ( " MsgMapindex = %d\n", ii );
    printf ( "   offset = %d\n", p_arglist-> components[ii].offset);
    printf ( "   classid= %d\n",* p_arglist-> components[ii].p_classid);
    printf ( "   NumChan= %d\n",
		 OM_GA_active_classes [*p_arglist->components[ii].p_classid] -> w_numchannels);
#endif

    p_ACLD-> MsgMap[ ii ].offset    =  p_arglist->components[ii].offset;
    p_ACLD-> MsgMap[ ii ].classid   = *p_arglist->components[ii].p_classid;
    if ( !p_arglist->components[ii].offset ) {
      if ( Root_processed ) {
        p_ACLD->MsgMap[ii].NumChan = 0;     /* instance data rejected */
        p_ACLD->MsgMap[ii].ChanDefns = 0;   /* therefore no channels  */
      }
      else {
        Root_processed = 1;
        p_ACLD-> MsgMap[ ii ].NumChan   = 
		 OM_GA_active_classes [*p_arglist->components[ii].p_classid] -> w_numchannels;
        p_ACLD-> MsgMap[ ii ].ChanDefns = 
		 OM_GA_active_classes [*p_arglist->components[ii].p_classid] -> ChanDefns;

      }
    }
    else {
      p_ACLD-> MsgMap[ ii ].NumChan   = 
		 OM_GA_active_classes [*p_arglist->components[ii].p_classid] -> w_numchannels;
      p_ACLD-> MsgMap[ ii ].ChanDefns = 
		 OM_GA_active_classes [*p_arglist->components[ii].p_classid] -> ChanDefns;
    }
#ifdef DEBUG
    printf ( " ---values going to---\n");
    printf ( " MsgMapindex = %d\n", ii );
    printf ( "   offset = %d\n", p_ACLD-> MsgMap[ ii ].offset);
    printf ( "   classid= %d\n", p_ACLD-> MsgMap[ ii ].classid);
    printf ( "   NumChan= %d\n", p_ACLD-> MsgMap[ ii ].NumChan);
#endif

    }

  /*****************************************************************/
  /*      For each ancestor of this class, copy the ancestor's     */
  /*  pointer to its MethTbl into this class' MsgMap		   */
  /*****************************************************************/

 {
  for (ii = 0; ii < p_ACLD->w_numparents; ++ii)
   {
    OM_p_CLASSDEF parcldef = OM_GA_active_classes
			  [*p_arglist->ancestors[ii].p_classid];
    OM_p_MSGMAP p = parcldef->MsgMap, last_p = p + parcldef->NumMsgClasses;
  
    for (; p < last_p; ++p)
     {
        p_ACLD->MsgMap
        [p->classid ?  p_ACLD->p_transmap [p->classid - p_ACLD->w_baseclass] : 0]
         .MethTbl = p->MethTbl;

     }
   }
 } /* end of "inherit_dispatch_tables", donated by Paul Hammond  */

  /*****************************************************************/
  /*  copy the MethTbl pointer from p_arglist->ClassDispTbl        */
  /*      for the last component (the class itself)                */
  /*****************************************************************/

/*if (p_ACLD->w_classid < OM_K_NUM_META_CLASSES || */
if ( p_arglist->NumMethods == 0 )
  {
  p_ACLD -> MsgMap[ p_arglist->NumComponents - 1 ].MethTbl = p_arglist->ClassDispTbl;
  }
else
  {
  /****** Allocate space for MethTbl out of shared memory ******/

    OM_p_FUNCPTR  *p_methtbl;

    if (NULL == (p_ACLD->MsgMap[p_arglist->NumComponents-1].MethTbl = 
      (OM_p_FUNCPTR *)om$calloc(num=p_arglist->NumMethods,
		   size=sizeof(OM_p_FUNCPTR) ))) 
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
       OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
       return (OM_E_NODYNMEM);
    }

    p_methtbl = p_ACLD->MsgMap[p_arglist->NumComponents-1].MethTbl;

    OM_BLOCK_MOVE(p_arglist->ClassDispTbl, p_methtbl,
   	(sizeof(OM_p_FUNCPTR)*p_arglist->NumMethods) );

    for ( ii=0; ii < p_arglist->NumMethods; ++ii )
    {
       if (!p_methtbl[ii]) p_methtbl[ii] = som_stub_method;
    }

  /**********************************************************************/
  }

  /******************************************************************/
  /*    apply  overrides (if any) to MethTbl for each entry in      */
  /*    this class' MsgMap					    */
  /******************************************************************/

  {
    for ( jj = 0  ;  jj < p_arglist->NumComponents ; jj++)
      {
	if ( (p_arglist->components[jj].NumOverRides > 0 ) ||
             (p_arglist->components[jj].NumInherits  > 0 ))
	   {
	    /*  there are some overrides   */

            OM_p_COMPCLASSDEF p_comp = &p_arglist->components[jj];

	    /**************************************/
	    /*  make a "virgin" copy of that      */
	    /*    component's MethTbl		  */
	    /**************************************/

	     OMuword	num = OM_GA_active_classes [*p_comp->p_classid]->w_nummethods;

	    /****************************************/
	    /*   allocate some memory for the copy  */
	    /****************************************/
	     OM_p_FUNCPTR	*temptbl = (OM_p_FUNCPTR *)
				    om$calloc( num = num, size = sizeof (OM_p_FUNCPTR));

		if ( temptbl == NULL )
  		   {
			OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_arglist->s_name);
			OMERRMSG1("Class %s was not created.\n\n", p_arglist->s_name);
			*p_classid = (OMuword) -1;
          	        OM_Gw_next_class_index = old_class_index;
			return (OM_E_NODYNMEM);
		    }

	    /****************************************/
	    /*     copy the MethTbl pointers        */
	    /****************************************/
	      for ( kk = 0 ; kk < num ; kk++)
		{
		  temptbl[kk] = p_ACLD->MsgMap[jj].MethTbl[kk];
		}

	    /*****************************************/
	    /*      apply  overrides to copy         */
	    /*****************************************/

	       for ( kk = 0; kk < p_comp->NumOverRides; kk++)
		  {
                    if (!p_comp->OverRides[kk].p_method)
                    {
 		       temptbl[*p_comp->OverRides[kk].p_index]=
                           som_stub_method;
                    }
                    else
                    {
 		       temptbl[*p_comp->OverRides[kk].p_index]=
			   p_comp->OverRides[kk].p_method;
                    }
		  }

	    /*****************************************/
	    /*      apply  inherits to copy          */
	    /*****************************************/

               for ( kk=0; kk<p_comp->NumInherits; ++kk )
               {
                  OMuword inh_classid = *p_comp->Inherits[kk].p_classid;
                  OM_p_MSGMAP p_msgmap =
                               OM_GA_active_classes[inh_classid]->MsgMap;

                  while ( p_msgmap->classid != *p_comp->p_classid ) ++p_msgmap;
                  temptbl[*p_comp->Inherits[kk].p_index] = 
                       p_msgmap->MethTbl[*p_comp->Inherits[kk].p_index];
               }

	    /*****************************************/
	    /*    finally, point the real MethTbl    */
	    /*  pointer to this overridden copy      */
	    /*****************************************/
		p_ACLD->MsgMap[jj].MethTbl = temptbl;

	  }    /* end of if any overrides block */
	 }    /* end of for jj loop */
	}    /* end of big apply overrides block */


  /*******************************************************************************/
  /* now fix up p_subclasslist of parents, and p_sibling of this class' siblings */ 
  
    /*      For each ancestor in this class' ancestors list,        */
    /*  make p_classdef = classid of this class			    */
    /*  and  p_sibling  = NULL for this class			    */
  /*******************************************************************************/


    /*  now hook this class into the p_subclasslist/p_sibling organization   */
    /*  of each of its parents and siblings				     */

  for ( ii = 0 ; ii < p_ACLD->w_numparents ;  ii++ )
      {
	OM_p_ANCESTRY	tmpanc    = &p_arglist->ancestors[ii];
	OM_p_CLASSDEF	tmpancdef = OM_GA_active_classes[*tmpanc->p_classid];
#ifdef DEBUG
   printf ( " ancestor #%d with classid %d points to my classid of %d\n",
	ii, *tmpanc->p_classid, *p_classid);
#endif
	tmpanc->p_classdef = p_ACLD;
	tmpanc->p_sibling  = tmpancdef->p_subclass_list;
	tmpancdef->p_subclass_list = tmpanc;

	} /* end of for loop */
	  /* now sibling linkage trail and parents subclasslist are OK */

    
if ( new_class )
{
   if (!(1&(sts = add_class_to_all_os (p_ACLD->s_name, p_ACLD->w_classid) )))
   {
      printf("som_create_class: could not add class '%s' to all os\n", p_ACLD->s_name);
      return (sts);
   }
}

  /* add the class to the hash table	*/
  {
    OM_p_CLASSDEF ppcld = NULL;

    om$get_class(classname=p_ACLD->s_name, pp_cld=&ppcld);
  }

#ifdef DEBUG
  printf ( "/som_create_class\n\n");
#endif
  return (OM_S_SUCCESS);			/* return success */
}


/*
-------------------------------------------------------------------------------
Routine Name:	som_dynamic_class
Abstract:

  This routine takes the new dynamic class's name and a list of 
  its ancestors and builds an ACLD for the new class.

Sample Invocation:

	som_dynamic_class (p_parent_class, num_parents, 
		maj_version, min_version, p_dynamic_class)

Entry Variable Description:

char *p_parent_class	array of parent class names in left to right
			order
OMuword num_parents	number of parents
OMuword maj_version	major version of new class
OMuword min_version	minor version of new clas
char *p_dynamic_class	name of new class

Modules Invoked:
			om$get_classid
			om$get_class
			om$realloc
			om$malloc
			om$calloc
			om$dealloc

-------------------------------------------------------------------------------
*/

int som_dynamic_class(char *p_parent_class[],
                      OMuword num_parents, OMuword maj_version,
                      OMuword min_version, char *p_dynamic_class)
{

int                     sts;
int                     taggable=0;
OM_p_CLASSDEF		p_ACLD, p_acld;
char 			*new_p;
int old_class_index  =  OM_Gw_next_class_index;
OMbyte			present;
int			parent_i, kk, next_i;
OMuword			dummy, num_components,minus1=OM_K_NOTUSING_CLASSID;
OMuword			rootid=OM_K_ROOT_ACTCLASSID,total_num_varlenarrs;
OMuword			total_num_components; /* total of parents
components */
OMuint			offset, offset1, array_offset;
OM_p_COMPCLASSDEF	p_component_list;
OM_p_ANCESTRY		p_ancestor_list;
OMuword                 ii;
OMword                  jj;

#ifdef DEBUG
printf("\n*** Entering som_dynamic_class ***\n");
printf("num_parents : %d\n", num_parents);
for ( ii=0; ii<num_parents; ii++)
   {
   printf(" parent %d : %s\n", ii, p_parent_class[ii]);
   }
printf("major version : %d\n", maj_version);
printf("minor version : %d\n", min_version);
printf("p_dynamic_class : %s\n", p_dynamic_class);
#endif

/*******************************************************************/
/*            Check for valid class name string                    */
/*******************************************************************/

if ( strlen(p_dynamic_class) >= OM_K_MAXCLASS_LEN) /* name too long ? */
  {
    OMERRMSG2("OM_E_BADCLASSNAME, Class name %s is longer than %d character maximum.\n", p_dynamic_class, OM_K_MAXCLASS_LEN);
    OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
    return (OM_E_BADCLASSNAME);
  }

if ( strlen(p_dynamic_class) == 0 )	/* Sent in NULL class name */
  {
    OMERRMSG2("OM_E_BADCLASSNAME, Class name %s has length %d.\n",
p_dynamic_class, 0);
    OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
    return (OM_E_BADCLASSNAME);
  }

/*******************************************************************/
/*            Check to see if class already exists                
*/  
/*******************************************************************/

if (OM_S_SUCCESS == om$get_classid(classname=p_dynamic_class,p_classid=&dummy))
    {
    OMWARNING1("OM_W_CLASS_EXISTS, Class %s already exists.\n", p_dynamic_class);
    OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
    return (OM_W_CLASS_EXISTS);
    }

/**********************************************************************/
/*        Check to see that this class has at least one parent      
 */
/**********************************************************************/

  if ( num_parents <= 0 )
    {
      OMERRMSG1("OM_E_NOPARENT, Class %s has no ancestors.\n",p_dynamic_class);
      OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
      return(OM_E_NOPARENT);
    }

/************************************************************/
/*              Malloc the Ancestor List                    */
/************************************************************/

if (NULL == (p_ancestor_list = 
    (OM_p_ANCESTRY)om$malloc(size=sizeof(OM_S_ANCESTRY)*num_parents))) 
    {
     OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n",p_dynamic_class);
     OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
     return (OM_E_NODYNMEM);
    }

/************************************************************/
/* Get aclds of parents and build new ancestry list         */
/* (Parent list ordered from left to right)                 */
/************************************************************/

for ( ii=0; ii<num_parents; ii++ )
  {
  
  sts = om$get_class(classname=p_parent_class[ii],
			p_classid=&dummy,
			pp_cld=&p_acld);
  if ( !(sts&1) )    
        {
	  /* this particular parent has no ACLD */
	  OMERRMSG2("OM_E_NOPARENT, Parent %s has classid %d, which is undefined.\n",p_parent_class[ii], dummy );
	  OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
	  return(OM_E_NOPARENT);
	}


   if ( p_acld->flags & OM_CLDf_TAGGABLE ) taggable = 1;

   p_ancestor_list[ii].p_classid = &(p_acld->w_classid);
   p_ancestor_list[ii].MajVer = p_acld->w_major_version;
   p_ancestor_list[ii].MinVer = p_acld->w_minor_version;

#ifdef DEBUG
printf("\nBuilding ancestor list\n");
printf("*** p_acld of %s : %x ***\n", p_parent_class[ii], p_acld);
printf("*** p_acld->w_classid : %d\n", p_acld->w_classid);
printf("*p_acnestor_list[%d].p_classid : %d\n", ii, *(p_ancestor_list[ii].p_classid) );
#endif

   }

/******************************************************/
/* Grow OM_GA_active_classes array by one for dynamic */
/******************************************************/

OM_Gw_numclasses++;
#ifdef DEBUG
printf("\n******* OM_Gw_numclasses after inc: %d **********************\n",OM_Gw_numclasses);
#endif

new_p = om$realloc(ptr=(char *) OM_GA_active_classes,
   size=(OM_Gw_numclasses)*sizeof(OM_p_FUNCPTR));
if ( new_p == NULL )
	return(OM_E_NODYNMEM);

OM_GA_active_classes = (OM_p_CLASSDEF *)new_p;

if (OM_Gw_next_class_index >= OM_Gw_numclasses) /* Bounds check */
  {
    OMERRMSG1("OM_E_TOOMANYCLASSES, The maximum number of classes, %d, already exist.\n",OM_Gw_numclasses);
    OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
    return (OM_E_TOOMANYCLASSES);
  }

/*****************************************************************/
/*          Allocate an ACLD for the new class                   */
/*****************************************************************/

if (NULL == (p_ACLD = 
    (OM_S_CLASSDEF *) om$calloc (num = 1, size = sizeof(OM_S_CLASSDEF) ))) 
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_dynamic_class);
       OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
       return (OM_E_NODYNMEM);
    }


/*******************************************************/
/*  Fill in table and assign the new class a classid   */
/*******************************************************/

OM_GA_active_classes[OM_Gw_next_class_index] = p_ACLD;
p_ACLD->w_classid =  OM_Gw_next_class_index++;

#ifdef DEBUG
  printf ("\n New p_ACLD allocated for this class\n");
  printf ( "New classid is %d\n", p_ACLD->w_classid);
#endif

/*************************************************************/
/*    Start filling in the new class's ACLD                  */
/*************************************************************/

p_ACLD->w_major_version = maj_version;
p_ACLD->w_minor_version = min_version;

strcpy(p_ACLD->s_name, p_dynamic_class);

p_ACLD->NewInstanceSize = 0; /* Dynamic class defines no new
instance data */

p_ACLD->w_oppmaj_version = 0;
p_ACLD->w_oppmin_version = 0;

p_ACLD->p_subclass_list = NULL;

p_ACLD->p_instance_def = NULL;

p_ACLD->ChanDefns = NULL;
p_ACLD->w_numchannels = 0;

p_ACLD->p_methdefns = NULL;
p_ACLD->w_nummethods = 0;

p_ACLD->NumRecClasses = 0;
p_ACLD->p_createclass_args = NULL;

p_ACLD->w_numparents = num_parents;
p_ACLD->A_ancestor_list = p_ancestor_list;
p_ACLD->flags = 0;

if ( taggable ) p_ACLD->flags |= OM_CLDf_TAGGABLE;

/********************************************************************/
/*              Build component list of new class                   */
/********************************************************************/

#ifdef DEBUG
printf("\nBuild the component list of new class\n");
#endif

total_num_components = 1;
for (ii=0; ii<num_parents; ii++)
    total_num_components += OM_GA_active_classes[*(p_ancestor_list[ii].p_classid)]->NumMsgClasses;   
if (NULL == (p_component_list = 
(OM_p_COMPCLASSDEF)om$malloc(size=sizeof(OM_S_COMPCLASSDEF)*total_num_components))) 
    {
     OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n",p_dynamic_class);
     OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
     return (OM_E_NODYNMEM);
    }

/* Initialize the component list ( no override info and -1 classids
) */

for (ii=0; ii<total_num_components; ii++ )
   {
   p_component_list[ii].NumOverRides = 0;
   p_component_list[ii].OverRides = NULL;
   p_component_list[ii].p_classid = &minus1;
   p_component_list[ii].offset = 0;
   }

next_i = total_num_components - 2;
parent_i = total_num_components - 1;
p_component_list[parent_i].p_classid = &p_ACLD->w_classid;
p_ACLD->i_instance_size = 0;

/* Loop to create component list */

while ( parent_i >= 0 )
   {
   if ( *(p_component_list[parent_i].p_classid)==OM_K_NOTUSING_CLASSID) break;
   p_acld = OM_GA_active_classes[*(p_component_list[parent_i].p_classid)];
   for (ii=0; ii<p_acld->w_numparents; ii++)
	{

	/* Is this class already in the component list? */

	present = 0;
	for (jj=total_num_components-1; jj>(OMword) next_i; jj--)
	   {
	   if (*(p_component_list[jj].p_classid) == *(p_acld->A_ancestor_list[ii].p_classid) )

		present = 1;
	   }
	if ( (!present) && 
	   (*p_acld->A_ancestor_list[ii].p_classid!=OM_K_ROOT_ACTCLASSID) )
	   {
	   p_component_list[next_i].p_classid = p_acld->A_ancestor_list[ii].p_classid;
	   next_i--;
	   }
	}
	parent_i--;
   }			/* End while */

/* Add Root to top slot in component list */

p_component_list[next_i--].p_classid = &rootid;

/* Compute num of components for this class and store in NumMsgClasses */

num_components = total_num_components - next_i - 1;   
p_ACLD->NumMsgClasses = num_components;

#ifdef BIG_ENDIAN
	/*
	**	Create dictionary information for this class.
	*/

	p_ACLD->p_instance_def = (struct OM_sd_Dclass *)
		om$calloc(num=1, size=sizeof(*p_ACLD->p_instance_def));
	if (!p_ACLD->p_instance_def)
		return OM_E_NODYNMEM;
	p_ACLD->p_instance_def->CompDef = (struct OM_sd_Dcomp *)
 		om$calloc(num=num_components, size=sizeof(*p_ACLD->p_instance_def->CompDef));
	if (!p_ACLD->p_instance_def->CompDef)
	{
		om$dealloc(ptr=(char *) p_ACLD->p_instance_def);
		p_ACLD->p_instance_def = NULL;
		return OM_E_NODYNMEM;
	}
	p_ACLD->p_instance_def->Nc = num_components;
#endif

#ifdef DEBUG
printf("\n*** total_num_components: %d\n", total_num_components);
printf("*** next_i: %d\n", next_i);
printf("*** num_components: %d\n\n", num_components);
#endif

/* Compute offsets of component list */

offset = 0;

#ifdef BIG_ENDIAN
	jj = 0;
#endif

for ( ii=next_i+1; ii<total_num_components; ii++ )
   {
   p_acld = OM_GA_active_classes[*(p_component_list[ii].p_classid)];
   p_component_list[ii].offset = offset;      

#ifdef BIG_ENDIAN
	p_ACLD->p_instance_def->CompDef[jj].p_acld = p_acld;
	p_ACLD->p_instance_def->CompDef[jj].offset = offset;
	++jj;
#endif
   offset += p_acld->NewInstanceSize;
   if (p_acld->NewInstanceSize % 8)
     offset += 8 - (p_acld->NewInstanceSize % 8);
   }

p_ACLD->i_instance_size = offset;

#ifdef BIG_ENDIAN
	p_ACLD->p_instance_def->size = p_ACLD->i_instance_size;
	p_ACLD->p_instance_def->CompDef[p_ACLD->p_instance_def->Nc - 1].offset = 0;
#endif

#ifdef DEBUG
printf("*** Component List ***\n");
printf("p_ACLD->NumMsgClasses : %d\n", p_ACLD->NumMsgClasses);
for ( ii=next_i+1; ii<total_num_components; ii++)
   {
   printf("**** Entry %d ****\n", ii - (next_i + 1) );
   printf("*p_classid : %d\n", *(p_component_list[ii].p_classid) );
   printf("offset : %d\n\n", p_component_list[ii].offset);
   }
printf("p_ACLD->i_instance_size: %d\n", p_ACLD->i_instance_size);
#endif

/***************************************************************/
/*                Allocate space for TransMap:                 */
/*                ----------------------------		       */
/*   FIRST, FIND:
/*   p_ACLD-> w_baseclass = lowest non-zero classid in components
list   */
/*   p_ACLD-> w_maxclass  = highest	    classid in components
list   */
/***************************************************************/


p_ACLD-> w_baseclass = OM_K_MAX_OMUWORD; /* initialize this really
high  */
p_ACLD-> w_maxclass  = 0;        	 /* initialize this very low
    */

  {
   OM_p_COMPCLASSDEF p = &p_component_list[next_i+1], lastp = p +
(total_num_components - (next_i+1) );
#ifdef DEBUG
printf("\nDetermine maxclass and baseclass\n");
#endif

    for ( ;   p <  lastp  ;  p++ )
      {
	OMuword		pcld = *p-> p_classid;

#ifdef DEBUG
	printf ( "Component is classid # %d\n", pcld);
#endif
	if ( (pcld > 0) && (pcld < p_ACLD->w_baseclass) )
	    p_ACLD->w_baseclass = pcld;

	if (  pcld > p_ACLD->w_maxclass )
	    p_ACLD->w_maxclass = pcld;
      }
    }

#ifdef DEBUG
   printf ( " new baseclass = %d    new maxclass = %d\n\n",
	    p_ACLD->w_baseclass, p_ACLD->w_maxclass);
#endif

/********************************************************************/
/*     Allocate the right amount of memory for TransMap             */
/********************************************************************/

if ( p_ACLD->w_maxclass  >  0 ) /* make sure w_maxclass got a good value */
  if ( NULL == ( p_ACLD->p_transmap = (OMbyte *)
	om$calloc ( num = (p_ACLD->w_maxclass - p_ACLD->w_baseclass
+ 1), size = sizeof (OMbyte))))
    {
       OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_dynamic_class);
       OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
       p_ACLD->w_classid = minus1;  /* ?????????? */
       OM_Gw_next_class_index = old_class_index;
       return (OM_E_NODYNMEM);
    }

/****************************************************************/
/*		Allocate space for class'  MsgMap               */
/****************************************************************/

if ( NULL == ( p_ACLD->MsgMap = (OM_S_MSGMAP *)
	om$calloc ( num = num_components,size = sizeof (OM_S_MSGMAP))))

       {
          OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n", p_dynamic_class);
          OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
  	  p_ACLD->w_classid = (OMuword) -1;
          OM_Gw_next_class_index = old_class_index;
          return (OM_E_NODYNMEM);
       }


/****************************************************************/
/*            Fill  in  values   for  TransMap                  */
/****************************************************************/

if ( p_ACLD->w_maxclass  >  0 ) /* make sure w_maxclass got a good
value */
  {
             /* initialize it to OM_K_NULL_TRANS */
   {
   OMuint    tmphowmany = p_ACLD->w_maxclass - p_ACLD->w_baseclass +
1;
   for ( kk = 0; (OMuint) kk < tmphowmany ;  kk++)
	p_ACLD->p_transmap[kk] = OM_K_NULL_TRANS;
   }

#ifdef DEBUG
   printf ( "\n\n*** Filling in Transmap ***\n\n");
   printf("next_i+1 : %d   total_num_components: %d \n", (next_i+1), total_num_components );
#endif


   for ( kk = next_i+1 ;  (OMuword) kk < total_num_components ;   kk++)
	{
	 OMuword cid = *(p_component_list[kk].p_classid);

	 int  tmpindex = cid - p_ACLD->w_baseclass; 
#ifdef DEBUG
         printf("class id = %d\n",cid);
         printf("tmpindex = %d\n",tmpindex);
#endif
	 if  ( tmpindex >= 0 )
	     p_ACLD->p_transmap[ tmpindex ] = kk - (next_i + 1);
	}

#ifdef DEBUG
   {
   OMuint    tmphowmany = p_ACLD->w_maxclass - p_ACLD->w_baseclass+1;
   printf("\n*** TransMap ***\n");
   for ( kk = 0; kk < tmphowmany ;  kk++)
	 printf ("p_ACLD->p_transmap[%d] : %d\n", kk, p_ACLD->p_transmap[kk] );
   }
   printf ( "\n\n*** Filling in MsgMap ***\n");
#endif
  }

/*****************************************************************/
/*                     Fill in MsgMap                            */
/*****************************************************************/

  for ( ii = next_i+1;  ii < total_num_components;  ii++ )
    {

#ifdef DEBUG
printf (" ---values coming from---\n");
printf ("p_component_list[%d].offset = %d\n",ii, p_component_list[ii].offset);
printf ("*p_component_list[%d].classid= %d\n",ii, *p_component_list[ii].p_classid);
printf ("   NumChan= %d\n\n\n", OM_GA_active_classes[*p_component_list[ii].p_classid]-> w_numchannels);
#endif

    p_ACLD-> MsgMap[ii-(next_i+1)].offset    = p_component_list[ii].offset;
    p_ACLD-> MsgMap[ii-(next_i+1)].classid   =  *(p_component_list[ii].p_classid);
    p_ACLD-> MsgMap[ii-(next_i+1)].NumChan   = OM_GA_active_classes[*(p_component_list[ii].p_classid)]->w_numchannels;
    p_ACLD-> MsgMap[ii-(next_i+1)].ChanDefns = OM_GA_active_classes[*(p_component_list[ii].p_classid)]->ChanDefns;

#ifdef DEBUG
 printf ("MsgMap[%d].offset = %d\n",ii-(next_i+1), p_ACLD-> MsgMap[ii-(next_i+1)].offset);
 printf ("MsgMap[%d].classid= %d\n",ii-(next_i+1), p_ACLD-> MsgMap[ii-(next_i+1)].classid);
 printf ("MsgMap[%d].NumChan= %d\n\n\n",ii-(next_i+1), p_ACLD-> MsgMap[ii-(next_i+1)].NumChan);
#endif

 }

/*****************************************************************/
/*      For each ancestor of this class, copy the ancestor's     */
/*      pointer to its MethTbl into this class' MsgMap		 */
/*****************************************************************/

#ifdef DEBUG
printf("\n*** Filling in Method Table pointers of parents ***\n");
#endif

 {
  for (ii = 0; ii < p_ACLD->w_numparents; ++ii)
   {
    OM_p_CLASSDEF parcldef = OM_GA_active_classes
			  [*(p_ancestor_list[ii].p_classid)];
    OM_p_MSGMAP p = parcldef->MsgMap, last_p = p + parcldef->NumMsgClasses;

#ifdef DEBUG
printf("...filling in parent %s with classid %d\n", parcldef->s_name,parcldef->w_classid);
#endif  

    for (; p < last_p; ++p)
     {
#ifdef DEBUG
printf("...in loop, p->classid: %d transmapindex: %d, p->MethTbl: %x\n", p->classid, (p->classid-p_ACLD->w_baseclass), p->MethTbl);
#endif
        p_ACLD->MsgMap
        [p->classid ?  p_ACLD->p_transmap [p->classid - p_ACLD->w_baseclass] : 0].MethTbl = p->MethTbl;

     }
   }
 } /* end of "inherit_dispatch_tables" */

/*****************************************************************/
/*   Fill in NULL for the MethTbl pointer of the new class       */
/*****************************************************************/


p_ACLD -> MsgMap[ num_components - 1 ].MethTbl = NULL;

#ifdef DEBUG
printf("\n\n*** Filled in MsgMap[%d].MethTbl with NULL\n", num_components-1);
printf("\n*****   MsgMap   ****\n");
for ( ii=0; ii<p_ACLD->NumMsgClasses; ii++)
   {
   printf("MsgMap[%d].MethTbl: %x\n",ii,p_ACLD->MsgMap[ii].MethTbl);
   printf("MsgMap[%d].offset: %d\n",ii,p_ACLD->MsgMap[ii].offset);
   printf("MsgMap[%d].classid: %d\n",ii,p_ACLD->MsgMap[ii].classid);
   printf("MsgMap[%d].NumChan: %d\n\n",ii,p_ACLD->MsgMap[ii].NumChan);
   }
#endif

/********************************************************************/
/*            Fix up p_subclasslist of parents                     
*/ 
/********************************************************************/

for ( ii = 0 ; ii < p_ACLD->w_numparents ;  ii++ )
      {
	OM_p_ANCESTRY	tmpanc    = &p_ancestor_list[ii];
	OM_p_CLASSDEF	tmpancdef = OM_GA_active_classes[*tmpanc->p_classid];
#ifdef DEBUG
   printf ( "\nAncestor #%d with classid %d points to my classid of %d\n",
	ii, *tmpanc->p_classid, p_ACLD->w_classid);
#endif
	
	tmpanc->p_classdef = p_ACLD;
	tmpanc->p_sibling  = tmpancdef->p_subclass_list;
	tmpancdef->p_subclass_list = tmpanc;

	} /* end of for loop */


/***************************************************************/
/*         Build p_varlenarr_defns list                        */
/***************************************************************/

#ifdef DEBUG
printf("\nBuild varlen array definition list\n");
#endif

p_ACLD->p_varlenarr_defns = NULL;
p_ACLD->w_num_varlenarrays = 0;
total_num_varlenarrs = 0;

for (ii=0; ii<num_parents; ii++ )
  total_num_varlenarrs += OM_GA_active_classes[*(p_ancestor_list[ii].p_classid)]->w_num_varlenarrays;

if ( total_num_varlenarrs > 0 )
{
if (NULL == (p_ACLD->p_varlenarr_defns = (OM_p_VARLENARR_DEFN)om$malloc(size=sizeof(OM_S_VARLENARR_DEFN)*total_num_varlenarrs))) 
    {
     OMERRMSG1("OM_E_NODYNMEM, No dynamic memory available to create class %s.\n",p_dynamic_class);
     OMERRMSG1("Class %s was not created.\n\n", p_dynamic_class);
     return (OM_E_NODYNMEM);
    }

kk = total_num_varlenarrs - 1;
for ( ii=total_num_components-2; ii>(OMuword) (next_i+1); ii-- )
   {

   p_acld = OM_GA_active_classes[*(p_component_list[ii].p_classid)];

#ifdef DEBUG
printf("\n*** Processing class %s ***\n", p_acld->s_name);
printf("*** p_acld->w_num_varlenarrays: %d\n", p_acld->w_num_varlenarrays);
printf("\n**** MsgMap of %s ****\n", p_acld->s_name);
for ( ll=0; ll<p_acld->NumMsgClasses; ll++)
   {
   printf("MsgMap[%d].MethTbl: %x\n",ll,p_acld->MsgMap[ll].MethTbl);
   printf("MsgMap[%d].offset: %d\n",ll,p_acld->MsgMap[ll].offset);
   printf("MsgMap[%d].classid: %d\n",ll,p_acld->MsgMap[ll].classid);
   printf("MsgMap[%d].NumChan: %d\n\n",ll,p_acld->MsgMap[ll].NumChan);
   }
printf("**** Varlenarr definition of p_acld ***\n");
for ( ll=0; ll<p_acld->w_num_varlenarrays; ll++)
   {
   printf("p_varlenarr_defns[%d].w_offset: %d\n",
		ll,p_acld->p_varlenarr_defns[ll].w_offset);
   printf("p_varlenarr_defns[%d].w_count: %d\n",
		ll,p_acld->p_varlenarr_defns[ll].w_count);
   printf("p_varlenarr_defns[%d].w_per_elt_size: %d\n\n",
		ll,p_acld->p_varlenarr_defns[ll].w_per_elt_size);
   }
#endif

   offset1 = p_acld->MsgMap[p_acld->NumMsgClasses - 1].offset;
   if (!offset1) offset1 = p_component_list[ii].offset;
 
  if ( p_acld->w_num_varlenarrays > 0 )
   {
   jj = (OMword) p_acld->w_num_varlenarrays - 1;

#ifdef DEBUG
printf("\nEntering offset compare loop...\n");
printf("offset1: %d \n", offset1);
#endif

   while ( p_acld->p_varlenarr_defns[jj].w_offset >= offset1 )
	{
        p_ACLD->p_varlenarr_defns[kk] = 
		p_acld->p_varlenarr_defns[jj];
        array_offset = p_acld->p_varlenarr_defns[jj--].w_offset - offset1;
   	p_ACLD->p_varlenarr_defns[kk--].w_offset = 
		p_component_list[ii].offset + array_offset;
#ifdef DEBUG	
printf("kk: %d array_offset: %d p_acld->p_varlenarr_defns[%d].w_offset : %d\n", kk+1,array_offset,jj+1, p_acld->p_varlenarr_defns[jj+1].w_offset);
#endif
	if (jj<0) break;
        }        /* end while */

    }	/* end if this component class has VLAs */
   else
    {
#ifdef DEBUG
    printf("\n*** No VLAs for this component class ***\n");
#endif
     }

   } /* end for all the component classes minus itself and Root */

p_ACLD->w_num_varlenarrays = total_num_varlenarrs - kk - 1;

/* Move vararray definitions to start of p_varlenarr_defns array */

OM_BLOCK_MOVE(&p_ACLD->p_varlenarr_defns[kk+1],&p_ACLD->p_varlenarr_defns[0],p_ACLD->w_num_varlenarrays*sizeof(OM_S_VARLENARR_DEFN));

#ifdef DEBUG
printf("\n\n******* Varlen Array Definition List *******\n");
for ( ii=0; ii<p_ACLD->w_num_varlenarrays; ii++)
   {
   printf("*** Entry %d ***\n", ii );
   printf("w_offset : %d\n", p_ACLD->p_varlenarr_defns[ii].w_offset);
   printf("w_count : %d\n", p_ACLD->p_varlenarr_defns[ii].w_count);
   printf("w_per_elt_size : %d\n\n", p_ACLD->p_varlenarr_defns[ii].w_per_elt_size);
   printf("type : %d\n\n", p_ACLD->p_varlenarr_defns[ii].type);
   }
#endif

} /* endif there are some vararrays */
else 
{
#ifdef DEBUG
printf("\n*** There are no VLAs present ***\n");
#endif
}

/*==============================*/
/*  get initial size of object  */
/*==============================*/

if (!(1&(sts = om$vla_find_initial_size(p_cld=p_ACLD,p_size=&p_ACLD->initial_size))))
   {
      return (sts);
   }

#ifdef DEBUG
printf("\n\n\n******************************************************\n");
printf("                   NEW ACLD \n");
printf("******************************************************\n");
dump_class(p_ACLD);
printf("******************************************************\n");
printf("******************************************************\n\n\n");
#endif


sts = add_class_to_all_os (p_dynamic_class, p_ACLD->w_classid); 
if ( ! ( sts & 1 ) )
{
   printf("som_dynamic_class: error adding class '%s' to all os\n",p_dynamic_class);
   return(sts);
}

#ifdef DEBUG
printf("\n*** Leaving som_dynamic_class ***\n");
#endif

/*************************************************************/
/*		   Free the Component List		     */
/*************************************************************/

om$dealloc(ptr=(char *) p_component_list);

return(OM_S_SUCCESS);
}
