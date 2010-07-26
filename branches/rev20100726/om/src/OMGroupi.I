/* NOTE:  number of group extents, i.e. dimension of extent vla;
	  is part of OM_S_VARLENARR_DESCR which OPP places in
	  group instance and which the vla code maintains.
	  The argument for this dimension is OPP_extent_dimension.
	  Upon creation this vla is dimensioned to one; thereafter
	  the dimension is kept to the number of valid extents by
	  using set dimension (vla code) to change it.   */

class	implementation	OMGroup;

#include	<stdio.h>
#include	<string.h>
#include	"OMspecify.h"
#include	"OMrelation.h"
#include	"OMsend.h"
#include	"OMerrordef.h"
#include	"OMmetaclass.h"
#include	"OMmacros.h"
#include	"OMcluster.h"
#include	"OMintprims.h"

from OMObjSpace	import translate_group_name;

extern  int		Root_Root_delete_method();
extern  int		som_build_internal_classlist();

extern	OMuint		OM_Gi_transOS_numobjs;
extern	OMuint		OM_Gi_filedOS_numobjs;
extern	OMuint		OM_Gi_defMOSD_numobjs;
extern	OMuint		OM_Gi_transOS_extobjs;
extern	OMuint		OM_Gi_filedOS_extobjs;
extern	OMuint		OM_Gi_defMOSD_extobjs;
extern  int             OMObjSpace_OPP_pass_method_index;
extern	OMuint		OM_Gf_min_caching_send;
extern	OM_S_CHANNUM	NULL_CHANNUM;
extern  int             OM_Gi_percent_extend_sm;


/*
Revision History:

	29-aug-1986 Initial release of this method.
	
        13-feb-1988 saw Fixed bug that caused swapped objects to be added
                        to the free oid list.

*/

  /* Build (or rebuild) free list; when group runs out of avail   */
  /* oids ( next_avail == NULLOBJID ) do garbage collection, i.e. */
  /* rebuild free list hunting for freed oids; if none found and  */
  /* if this group is extendable then extend this group.          */
  /* NOTES:  new groups have dimension of 1 for their extents,    */
  /*         and here their extend_size is their initial_size.    */
  /*         Logical Paths thru this function are combinations of */
  /*	          new groups vs extending old groups		  */
  /*		  NO OSOfreeoids vs <, =, or > needed oids free   */
  /*	     other misc cases:  initializing group_0 free list,   */
  /*			coalescing existing extent with new one.  */

static	int OMGroup_build_freelist( group, newflg )
  struct OMGroup_instance	*group;
  OMuint			newflg;		/* is this a new group  */
					/* for group_0 initialization   */
/* newflg is false because spacemap entries have already been allocated */
{
  OM_p_SPAMAPENT	ptr;
  OM_S_OBJID		j, prev_free=0;
  int			i;
  int                   oldgrpdim, extent_dimension;
  OM_S_GROUP_EXTENT     *extent;
  char			empty=TRUE;
  char                  coalesce=FALSE;
  OMuint		sts, oldSMsize, extendSMamount, incr;
  OM_p_VARLENARR_DESCR  nogrpoids;

  extent_dimension = om$dimension_of(varray=group->extent);
  extent = (OM_S_GROUP_EXTENT *)group->extent_descr.i_offset;

  if(!newflg)	/* rebuilding free list; not new group OR initializing group_0 */
  {
    /* loop thru extents of Group Instance ME and if spacemapentry */
    /* of extent is not in_use (flag) put it on the free list */

    for( i=0; i< extent_dimension; i++ )
    {
      for(j=extent[i].beg_oid;
          j<extent[i].beg_oid + extent[i].size;
	  j++)
      {
	if( OM_OBJ_INVALID(OM_Gp_CurSpaceMap[j].flags) )

	    if(empty) 
	    {		/* first free slot */
	      prev_free = group->next_avail = j;
	      empty = 0;
	    }
	    else	/* not first empty slot */
	    {
	      OM_Gp_CurSpaceMap[prev_free].state.freeoid = j;
	      prev_free = j;
	    }
      }
    }
    if(! empty) 	/* end of free list of oids */
	  OM_Gp_CurSpaceMap[prev_free].state.freeoid = NULL_OBJID;	
  }	/* not new group */

  /*================================================*/
  /* pass thru spacemap resulted in empty free list */
  /* or new group is being initialized 		    */
  /*================================================*/
  if(empty)
  {			/* Check For No Extend Error */
  /* Never true if new group since its extend_size is its initial_size */
    if(group->extend_size == (OMuint)OM_K_NOEXTEND 
			&&
       group->size >= group->initial_size)
    { 
	group->next_avail = NULL_OBJID;
	return(OM_I_NO_FREE_OIDS);
    }

    /*=================================================*/
    /* Try To Get Needed Oids From OSO's Free Oid List */
    /*=================================================*/

    oldgrpdim = extent_dimension;
    extendSMamount = group->extend_size;
    nogrpoids = (OM_p_VARLENARR_DESCR)((OMuint)OM_Gp_CurOSD + OM_Gp_CurOSD->OidFreelist);
    if(nogrpoids->i_count)	/* some free oids exist */
    {
      OM_p_GROUP_EXTENT	freeosoext, grpnewext;
      OMuword		decrOSOfree=0;
      OMuword           incrGRPext=0;

      if(!(grpnewext=om$calloc(num=nogrpoids->i_count,
   				  structure=OM_S_GROUP_EXTENT))) 
	return(OM_E_NODYNMEM);

      freeosoext = (OM_p_GROUP_EXTENT)(nogrpoids->i_offset);

      /* traverse OSO's freeoids extents taking amount needed */

      for(j=0, i=nogrpoids->i_count-1;
	  i>=0 && j<nogrpoids->i_count && extendSMamount;
	  i--, j++)
      {
	if(extendSMamount >= freeosoext[i].size)  /* need all these */
	{
	  decrOSOfree++;
	  incrGRPext++;
	  grpnewext[j] = freeosoext[i];
	  extendSMamount -= freeosoext[i].size;
	}
	else	/* need part of these */
	{
	  incrGRPext++;
	  grpnewext[j].beg_oid = freeosoext[i].beg_oid;
	  grpnewext[j].size = extendSMamount;
	  freeosoext[i].beg_oid = freeosoext[i].beg_oid+extendSMamount;
	  freeosoext[i].size = freeosoext[i].size - extendSMamount;
	  extendSMamount = 0;
	}
      }	/* use freeoids up to amount needed or amount available */
      if(newflg)
	incrGRPext--;	/* one extent exists for new groups */
      if(incrGRPext)
      {			/* grow the group's extents */
          if(!(1&(sts=om$vla_set_dimension(p_vladescr=&(group->extent_descr),
		size=extent_dimension+incrGRPext,
		objid=group->groupid,
	        p_cld=OM_Gp_CurSpaceMap[group->groupid].p_acld))))
	  {
	    BUGCHECK("Group Extent Grows: set dimension error");
	  }
          extent_dimension = group->extent_descr.i_count;
          extent = (OM_p_GROUP_EXTENT)group->extent_descr.i_offset;
			/* possibly changed by set dimension */
      }
      for(newflg?(i=0):(i=oldgrpdim), j=0;
	  i<extent_dimension;
	  i++, j++)
      {
	  extent[i] = grpnewext[j];
      }

      if(decrOSOfree)
      {			/* shrink the OSO's freeoids extents */
        if(!(1&(sts=om$vla_set_dimension(p_vladescr=nogrpoids,
			size=nogrpoids->i_count-decrOSOfree,
	                objid=OM_Gp_CurOSD->OSO_Oid,
	 p_cld=OM_Gp_CurSpaceMap[OM_Gp_CurOSD->OSO_Oid].p_acld))))
	{
	    BUGCHECK("OSO's FreeOIDS shrink: set dimension error");
	}
      }
      om$dealloc(ptr=(char *) grpnewext);
    }

    /*====================================*/
    /* OSO had no or not enough free oids */
    /*====================================*/

    if(extendSMamount)
    {
      /*=================================*/
      /* max spacemap index < NULL_OBJID */
      /* realloc spacemap   	         */
      /*=================================*/

      if(OM_Gp_CurOSD->CurSpaceMapSize + extendSMamount >= NULL_OBJID)
	return(OM_E_NOEXTEND_OS);

      incr = ((group->size * OM_Gi_percent_extend_sm)/100);
      if ( incr > extendSMamount ) extendSMamount = incr;

      if(!(ptr = (OM_p_SPAMAPENT)om$realloc(ptr=(char *) OM_Gp_CurSpaceMap,
	size=(OM_Gp_CurOSD->CurSpaceMapSize+extendSMamount)*sizeof(OM_S_SPAMAPENT))))
	  return(OM_E_NODYNMEM);

      OM_Gp_CurSpaceMap = OM_Gp_CurOSD->Spacemap = ptr;
      oldSMsize = OM_Gp_CurOSD->CurSpaceMapSize;
      OM_Gp_CurOSD->CurSpaceMapSize += extendSMamount;

      /*===============================================*/
      /* initialize all new spacemapentries to empties */
      /*===============================================*/
      for(i=oldSMsize;
	  i<(int) OM_Gp_CurOSD->CurSpaceMapSize;
	  i++)
          OM_Gp_CurSpaceMap[i] = OM_GS_NULL_SPAMAPENT;

      /*=====================================================*/
      /* Group is not new, OR new group used OSO's free oids */
      /* Try to coalesce with existing extent(s) 	     */
      /*=====================================================*/
      if((!newflg) || (extendSMamount < group->extend_size))
      {
	for(i=0; i<oldgrpdim; i++)
        {
	  if(oldSMsize == extent[i].beg_oid+extent[i].size)
	  {
	    coalesce = TRUE;
	    extent[i].size += extendSMamount;
	    break;
	  }
        }
	if (! coalesce)
	/* coalescing failed - increment group's extents */
	{
          if(!(1&(sts=om$vla_set_dimension(p_vladescr=&(group->extent_descr),
			size=extent_dimension+1,
			objid=group->groupid,
	p_cld=OM_Gp_CurSpaceMap[group->groupid].p_acld))))
	  {
	    BUGCHECK("Group Extent Grows: set dimension error");
	  }
          extent_dimension = group->extent_descr.i_count;
          extent = (OM_p_GROUP_EXTENT)group->extent_descr.i_offset;
			/* extent possibly changed by set dimension */
	}  /* not coalesced */
      }	/* not new group */
      if(! coalesce)
      {  /* initialize new extent if coalescing failed OR if new group */
        extent[extent_dimension-1].beg_oid = oldSMsize;
        extent[extent_dimension-1].size = extendSMamount;
      }
    }
    /* build group's free list traversing all extent(s)     */
    /* must traverse all extents in case new oids coalesced */
    for( i=0; i< extent_dimension; i++ )
    {
      for(j=extent[i].beg_oid;
          j<extent[i].beg_oid + extent[i].size;
	  j++)
      {
          if( OM_OBJ_INVALID(OM_Gp_CurSpaceMap[j].flags) )

	    if(empty) 
	    {		/* first free slot */
	      prev_free = group->next_avail = j;
	      empty = 0;
	    }
	    else	/* not first empty slot */
	    {
	      OM_Gp_CurSpaceMap[prev_free].state.freeoid = j;
	      prev_free = j;
	    }
      }
    }
    if(! empty) 	/* end of free list of oids */
	  OM_Gp_CurSpaceMap[prev_free].state.freeoid = NULL_OBJID;
    else
    {
	BUGCHECK("Group Build FreeList Failure\n");
    }
    group->size += extendSMamount;
  }	/* new group or no frees found */
  return (OM_S_SUCCESS);
}


/* 
Revision History:

	21-sep-1986  Initial release of this method.
*/

/*=======================================================*/
/* This internal function manages coalescing of group    */
/* extents.  To_extent and to_size may be zero and then  */
/* from_extent will be moved to to_extent.               */
/*=======================================================*/

static	int OMGroup_coalesce_extents (frextd, frsz, 
					toextd, tosz, toos, toobjid, toacld)
	OM_p_VARLENARR_DESCR	frextd, toextd;
	OMuword			frsz, tosz;
	OMuword 		toos;
	OM_S_OBJID		toobjid;
	OM_p_CLASSDEF		toacld;
{
  int		Found, sts;
  OM_p_GROUP_EXTENT	toext, frext;
  OMuint	newsize;   /* size to_extent will increase by */
  char		*flags;	   /* byte array to indicate if extent coalesced */
  OMuword       i, j;

  if( (!frextd) || (!frsz) || (!toacld) || (!toextd) )
  {
	BUGCHECK("Group Extents Coalescing: zero ptr");
  }
  frext = (OM_p_GROUP_EXTENT)(frextd->i_offset);
  toext = (OM_p_GROUP_EXTENT)(toextd->i_offset);
  if(!frext)
  {
	BUGCHECK("Group Extents Coalescing: zero ptr");
  }
  newsize = tosz;
  if(!(flags=om$calloc(size=1, num=frsz)))
	return(OM_E_NODYNMEM);

  /* Try to coalesce from_extent into to_extent */

  for(i=0; i<frsz; i++)
  {
    Found = FALSE;
    for(j=0; j<tosz; j++)
    {
      if(frext[i].beg_oid + frext[i].size == toext[j].beg_oid)
      {
	toext[j].beg_oid = frext[i].beg_oid;
	toext[j].size += frext[i].size;
	Found = TRUE;
	break;
      }
      else
        if(toext[j].beg_oid + toext[j].size == frext[i].beg_oid)
	{
	  toext[j].size += frext[i].size;
	  Found = TRUE;
	  break;
	}
    }
    if( (!Found) )
    {
      newsize++;
      flags[i] = TRUE;		/* mark extent as not coalesced */
    }
  }
  /* If to_extent is empty or above did not fully coalesce the extents */
  if(newsize > tosz)
  {
    if(!(1&(sts=om$vla_set_dimension(p_vladescr=toextd, 
                                     size=newsize, 
				     osnum=toos,
				     objid=toobjid,
                                     p_cld=toacld))))
    {
      BUGCHECK("Group Coalescing: set dimension failed");
    }
    toext = (OM_p_GROUP_EXTENT)(toextd->i_offset);
    			  /* possibly changed after set dimension */
    j=0 ;		  /* index for flags array */
    for(i=tosz; i<newsize; i++)
    {
      while(!flags[j])
         j++;
      toext[i] = frext[j];
      j++;
    }
  }
  om$dealloc(ptr=(char *) flags);
  return(OM_S_SUCCESS);
}



/* 
Revision History:

	29-aug-1986  Initial release of this method.
*/

/*=======================================================*/
/* This method is used to initialize new groups at their */
/* time of construction.  Instance data is initialized   */
/* and its free list of available oids is built.         */
/*=======================================================*/
method init_OMGroup( char *groupname; int init_count, extend_count;
			OMuword clusternum )
{
  OM_S_CHANSELECT	cs_to, cs_from;
  OMuint		sts;
  OM_S_OBJID		transgrpoid=NULL_OBJID;
  char			oidstring[11]; /* max # digits for objid is */
				       /* 10 plus NULL; so 11       */

	/*====================================================*/
	/* group name greater than limit error is checked for */
	/*====================================================*/
	if((groupname!=NULL) &&  strlen(groupname) >= OM_K_MAXGROUPNAME_LEN)
	  return(OM_E_NAMETOOLONG);
	ME.OMGroup->groupid = my_id;
	if(groupname==NULL)	/* use default group name */
	{
	    strcpy(ME.OMGroup->name, "group_");
	    sprintf(oidstring, "%u", ME.OMGroup->groupid);
	    strcat(ME.OMGroup->name, oidstring);
	}
	else
	{		/* check for group name already in use */
	    sts=om$send(msg=message OMObjSpace.translate_group_name(
			groupname, &transgrpoid),
			targetid=OM_GO_current_OS_objid);
	    if(!(1&sts))
	    {
	      return(sts);
	    }
	    if(transgrpoid != NULL_OBJID) return(OM_E_DUPGRPNAME);
	    strcpy(ME.OMGroup->name, groupname);
	}
	ME.OMGroup->clusternum = clusternum;
	ME.OMGroup->next_avail = NULL_OBJID;
	ME.OMGroup->size = 0;	/* build free list fills in */
	/* Set Up Extend Size to be init_count for build freelist */
	if(init_count)
	  ME.OMGroup->extend_size = ME.OMGroup->initial_size = init_count;
	else
	{
 	  switch(OM_Gp_CurOSD->type)
	  {
	   case OM_OSD_MOSDOS: 
			ME.OMGroup->extend_size = ME.OMGroup->initial_size = OM_Gi_defMOSD_numobjs;
			break;
	   case OM_OSD_trans:
			ME.OMGroup->extend_size = ME.OMGroup->initial_size = OM_Gi_transOS_numobjs;
			break;
	   case OM_OSD_filed:
			ME.OMGroup->extend_size = ME.OMGroup->initial_size = OM_Gi_filedOS_numobjs;
			break;
	   default:	{ BUGCHECK("GROUP INIT: bad ostype in OSD"); }
	  }
	}
  	if(!(1&(sts = OMGroup_build_freelist( ME.OMGroup, TRUE ) )))
	    return(sts);

	/*===============================================*/
	/* After build free list, initialize extend size */
	/*===============================================*/
	if( extend_count)
	  ME.OMGroup->extend_size = extend_count;
	else
	{
 	  switch(OM_Gp_CurOSD->type)
	  {
	   case OM_OSD_MOSDOS: 
			ME.OMGroup->extend_size = OM_Gi_defMOSD_extobjs;
			break;
	   case OM_OSD_trans:
			ME.OMGroup->extend_size = OM_Gi_transOS_extobjs;
			break;
	   case OM_OSD_filed:
			ME.OMGroup->extend_size = OM_Gi_filedOS_extobjs;
			break;
	   default:	{ BUGCHECK("GROUP INIT: bad ostype in OSD"); }
	  }
	}

	/*=======================*/
  	/* connect myself to OSO */
	/*=======================*/
  	cs_from.type = OM_e_addr;
  	cs_to.type = OM_e_name;
  	cs_from.u_sel.addr = &(ME.OMGroup->to_OSO);
  	cs_to.u_sel.name = "OMObjSpace.to_GrpDscs";
  	if(!(1&(sts = om$send(msg=message Root.connect (
			cs_to, 0, my_id, OM_Gw_current_OS,
			cs_from, 0),
			targetid=OM_GO_current_OS_objid))))
	    return(sts);

	return(OM_S_SUCCESS);	
}


/* 
Revision History:

	29-aug-1986  Initial release of this method.
*/

/*========================================================*/
/* method which does startup for an Object Space's Group0 */
/*========================================================*/

method init_spacemap(OMuint extend_size; OMuint init_size; OM_S_OBJID oid;
	             OMbyte ostype; OMuint init_flag)
{
  OM_S_CHANSELECT	cs_to, cs_from;
  OMuint		sts;

  /*=====================================================*/
  /* initialize instance data if init_flag says to do so */
  /*=====================================================*/

  if(init_flag)
  {
    if(extend_size && init_size)  /* no defaults */
    {
     ME.OMGroup->extend_size = extend_size;
     ME.OMGroup->size = ME.OMGroup->initial_size = init_size;
    }
    else	/* default(s) used */
    {
     switch(ostype)
     {
      case OM_OSD_MOSDOS:
			if(! extend_size)
			  ME.OMGroup->extend_size = OM_Gi_defMOSD_extobjs;
			if(! init_size)
			  ME.OMGroup->size = ME.OMGroup->initial_size = OM_Gi_defMOSD_numobjs;
 		        break;
      case OM_OSD_trans:
			if(! extend_size)
			  ME.OMGroup->extend_size = OM_Gi_transOS_extobjs;
			if(! init_size)
			  ME.OMGroup->size = ME.OMGroup->initial_size = OM_Gi_transOS_numobjs;
		        break;
      case OM_OSD_filed:   
			if(! extend_size)
			  ME.OMGroup->extend_size = OM_Gi_filedOS_extobjs;
			if(! init_size)
			  ME.OMGroup->size = ME.OMGroup->initial_size = OM_Gi_filedOS_numobjs;
			break;
      default:  return(OM_E_INVARG);
     }
     if(extend_size)
	ME.OMGroup->extend_size = extend_size;
     if(init_size)
	ME.OMGroup->size = init_size;
    }
    strcpy(ME.OMGroup->name, "group_0");
    ME.OMGroup->groupid = oid;
    ME.OMGroup->extent[0].beg_oid = 0;
    ME.OMGroup->extent[0].size = init_size;
    ME.OMGroup->clusternum = OM_K_NOTACLUSTER;

    /*=======================*/
    /* connect myself to OSO */
    /*=======================*/
    cs_from.type = OM_e_addr;
    cs_to.type = OM_e_name;
    cs_from.u_sel.addr = &(ME.OMGroup->to_OSO);
    cs_to.u_sel.name = "OMObjSpace.to_GrpDscs";
    if(!(1&(sts = om$send(msg=message Root.connect (
			cs_to, 0, my_id, OM_Gw_current_OS,
			cs_from, 0),
			targetid=OM_GO_current_OS_objid) )))
      return(sts);
  }

  /*======================*/
  /* initialize free list */
  /*======================*/

  if(!(1&(sts = OMGroup_build_freelist(ME.OMGroup, FALSE))))
	return(sts);

  return(OM_S_SUCCESS);
}


/* 
Revision History:

	29-aug-1986  geo  Initial release of this method.

	14-jan-1988  geo  Clusterid if default and if not specified
			  by group's clusternum becomes AUTOCLUSTER
			  in OM4.5 versus cluster0 in prior OMs.  
*/

/*=======================================================*/
/* Obtain the next available object id within this group */
/*=======================================================*/

method get_oid (OM_p_OBJID oid; OM_p_NEIGHBOR p_neighbor)
{
  OMuint	sts;

  /*=========================================*/
  /* Fill In Neighbor Structure if Defaulted */
  /*=========================================*/
  if(p_neighbor->clusterid == OM_K_NOTACLUSTER)
  {
    if(ME.OMGroup->clusternum != OM_K_NOTACLUSTER) /* clusternum of group */
	p_neighbor->clusterid = ME.OMGroup->clusternum;
	/* AUTO-CLUSTERING is the default */
  }

  /*=========================*/
  /* Next avail is not empty */
  /*=========================*/
  if(ME.OMGroup->next_avail != NULL_OBJID)
  {
    *oid = ME.OMGroup->next_avail;
    OM_Gp_CurSpaceMap[*oid].flags |= OM_SM_in_use;
    ME.OMGroup->next_avail = OM_Gp_CurSpaceMap[*oid].state.freeoid;
    sts = OM_S_SUCCESS;
  }
  /*================================================================*/
  /* Next avail is empty; rebuild free list perhaps extending group */
  /*================================================================*/

  else
  {
    if(OM_I_NO_FREE_OIDS == (sts = OMGroup_build_freelist(ME.OMGroup, FALSE)))
	sts = OM_E_NO_EXTEND_GROUP;
    else /* found one or some other failure within build free list */
    {
      if( sts == OM_S_SUCCESS )
      {
        *oid = ME.OMGroup->next_avail;
        OM_Gp_CurSpaceMap[*oid].flags |= OM_SM_in_use;
        ME.OMGroup->next_avail = OM_Gp_CurSpaceMap[*oid].state.freeoid;
      }
    }
  }
return(sts);
}


/* 
Revision History:

	29-aug-1986  Initial release of this method.
*/

/*=======================================================*/
/* This method is used by OMObjSpace's method translate  */
/* _group_name.  It returns the group's object id if its */
/* name matches the input name.                          */
/*=======================================================*/
						
method my_name (char *name; OM_p_OBJID p_groupoid)
{
  if(!(strcmp(name, ME.OMGroup->name)))
  {
    *p_groupoid = ME.OMGroup->groupid;
    return(OM_I_STOP_SENDING);
  }
  return(OM_S_SUCCESS);
}

/* 
Revision History:

	29-aug-1986  Initial release of this method.
*/

/*=======================================================*/
/* This method is used by the make neighbor primitive.   */
/* It returns the group's object id if the input oid is  */
/* within the group's range of oids.                     */
/*=======================================================*/

method my_oid (OM_S_OBJID oid; OM_p_OBJID p_groupoid)
{
  OMuint i;

  for(i=0; i<om$dimension_of(varray=ME.OMGroup->extent); i++)
  {
    if((oid>=ME.OMGroup->extent[i].beg_oid) &&
       (oid<ME.OMGroup->extent[i].beg_oid + ME.OMGroup->extent[i].size))
    {
	*p_groupoid = ME.OMGroup->groupid;
        return(OM_I_STOP_SENDING);
    }
  }
  return(OM_S_SUCCESS);
}


/* 
Revision History:

	29-aug-1986  Initial release of this method.
*/

/*=======================================================*/
/* This method is illegal for this class of objects.     */
/* Deletion of a group object must be a positive action; */
/* sending the remove method. This will catch  		 */
/* accidental sends of delete to group objects.          */
/*=======================================================*/

method delete (int flag)
{
return(OM_E_NO_DELETE_GROUP);
}


/* 
Revision History:

	29-aug-1986  Initial release of this method.
*/

/*=====================================================*/
/* This method prints out the object's information.    */
/*=====================================================*/

method debug ()
{
  int	 sts;
  OMuint i;

  sts=om$send(msg=message Root.debug(), targetid=my_id,
		mode=OM_e_wrt_message);
  if(!(1&sts))  return(sts);
/* Group's Instance Data */
  printf("group id is %u\n",ME.OMGroup->groupid);
  printf("group name is %s\n",ME.OMGroup->name);
  if(ME.OMGroup->clusternum == OM_K_NOTACLUSTER)
    printf("no cluster is associated with this group\n");
  else
    printf("associated cluster number is %u\n",ME.OMGroup->clusternum);
  printf("total number of group's object ids is %u\n",ME.OMGroup->size);
  printf("initial number of object ids is %u\n",ME.OMGroup->initial_size);
  if(ME.OMGroup->extend_size == (OMuint) OM_K_NOEXTEND)
    printf("this group is not extendable\n");
  else
    printf("extend number of object ids is %u\n",ME.OMGroup->extend_size);
  printf("next available object id is %u\n",ME.OMGroup->next_avail);
  printf("oid of OSO connected to %u\n",
                *((OM_p_OBJID)(ME.OMGroup->to_OSO + 2)));
  for(i=0; i<om$dimension_of(varray=ME.OMGroup->extent); i++)
  {
    printf("range of oids of extent %d is: %u to %u\n", i,
	ME.OMGroup->extent[i].beg_oid,
	ME.OMGroup->extent[i].beg_oid+ME.OMGroup->extent[i].size-1);
  }
  return(OM_S_SUCCESS);
}



/* 
Revision History:

	15-sep-1986  Initial release of this method.
*/

/*=======================================================*/
/* This method takes all my extents and adds them to the */
/* input group's extent list.			         */
/*=======================================================*/

method merge(OM_S_OBJID groupoid)
{
  int		sts;

  if(OM_Gp_CurOSD->Group0_Oid == my_id)  /* group 0 may not be merged */
    return(OM_E_ILLEGAL_GROUP0);
  if(groupoid == my_id)  		/* merge into myself? NOOP */
    return(OM_S_SUCCESS);
  if(!(1&(sts=om$send(msg=message OMGroup.mergeinto(
                &(ME.OMGroup->extent_descr),
		om$dimension_of(varray=ME.OMGroup->extent), ME.OMGroup->size),
		targetid=groupoid))))
    return(sts);

  /* Successful merge complete; now empty out my vla of extents */
  /* and null out necessary instance data.			*/
 
  if(!(1&(sts=om$vla_set_dimension(varray=ME.OMGroup->extent, size=0))))
  {
      BUGCHECK("Group Merged: set dimension failed");
  }
  ME.OMGroup->size = 0;
  ME.OMGroup->next_avail = NULL_OBJID;
return(OM_S_SUCCESS);
}


/* 
Revision History:

	15-sep-1986  Initial release of this method.
*/

/*======================================================*/
/* This method is used by group being merged into; it   */
/* handles merge functions of group acquiring extents.  */
/*======================================================*/
method mergeinto (OM_p_VARLENARR_DESCR frextd; OMuint frextsz, frtotsz)
	/* frextsz is from_group's vla dimension;       */
	/* frtotsz is from_group's total number of oids */
{
  int	sts;

  /* extendable Group ?? :  only allowed to be merged into if  */
  /* it's current size is < it's initial size AND only if size */
  /* being merged will not make it > its initial size          */
  if( (ME.OMGroup->extend_size == (OMuint) OM_K_NOEXTEND
			&&
      (ME.OMGroup->size >= ME.OMGroup->initial_size
			||
       frtotsz > ME.OMGroup->initial_size - ME.OMGroup->size) ))
	return(OM_E_NOEXTEND_GROUP);
  if(!(1&(sts=OMGroup_coalesce_extents(frextd, frextsz,
			&(ME.OMGroup->extent_descr),
			om$dimension_of(varray=ME.OMGroup->extent), OM_Gw_current_OS,my_id, p_ACLD))))
    return(sts);
  ME.OMGroup->size += frtotsz;
  return(OM_S_SUCCESS);
}



/*================================================*/
/* This method deletes all my objects and myself. */
/*================================================*/

%undef remove

method remove()
{
  int		sts;
  OMuint	oid, i, j;
  OM_p_SPAMAPENT ptr;
  OM_p_CLASSDEF	oso_p_acld;
  OM_p_VARLENARR_DESCR	OSO_FreeOids_vla;

  if(OM_Gp_CurOSD->Group0_Oid == my_id)  /* group 0 may not be removed */
    return(OM_E_ILLEGAL_GROUP0);

  /*====================================================*/
  /* If Group is not empty; delete all in use objects   */
  /* using wrt_object mode so as to use object's delete */
  /* if it's class overrides delete.                    */
  /*====================================================*/

  for(i=0; i<om$dimension_of(varray=ME.OMGroup->extent); i++)	/* group's extents */
  {
      for(oid=ME.OMGroup->extent[i].beg_oid; /* extent's range */
          oid<ME.OMGroup->extent[i].beg_oid + ME.OMGroup->extent[i].size;
	  oid++)
      {
	if( ! ( OM_OBJ_INVALID(OM_Gp_CurOSD->Spacemap[oid].flags) )
				&&
	  (!(OM_Gp_CurOSD->Spacemap[oid].flags & OM_SM_Rootdel_pending)))
        {
	  if(!(1&(sts=om$send(msg=message Root.delete(TRUE),
				targetid=oid))))
	    return(sts);
	}
      }
  }
  /*======================================================*/
  /* If Group is still not empty; pass thru group's range */
  /* of oids and delete wrt_message all in use.           */
  /*======================================================*/

  for(i=0; i<om$dimension_of(varray=ME.OMGroup->extent); i++)	/* group's extents */
  {
    for(oid=ME.OMGroup->extent[i].beg_oid; /* extent's range */
        oid<ME.OMGroup->extent[i].beg_oid + ME.OMGroup->extent[i].size;
        oid++)
    {
      if( ! ( OM_OBJ_INVALID(OM_Gp_CurOSD->Spacemap[oid].flags) )
				&&
	 (!(OM_Gp_CurOSD->Spacemap[oid].flags & OM_SM_Rootdel_pending)))
      {
	if(!(1&(sts=om$send(msg=message Root.delete(TRUE),
				targetid=oid, mode=OM_e_wrt_message))))
	      return(sts);
      }
    }
  }						

  /*=======================================================*/
  /* Store My Extents In OSO's Free List of SpaceMap Holes */
  /*=======================================================*/

  if(om$dimension_of(varray=ME.OMGroup->extent))
  {
    OSO_FreeOids_vla=(OM_p_VARLENARR_DESCR)((OMuint)OM_Gp_CurOSD + OM_Gp_CurOSD->OidFreelist);
    oso_p_acld = OM_Gp_CurSpaceMap[OM_Gp_CurOSD->OSO_Oid].p_acld;
    if(!(1&(sts=OMGroup_coalesce_extents(&(ME.OMGroup->extent_descr),
		om$dimension_of(varray=ME.OMGroup->extent),
		OSO_FreeOids_vla,
		OSO_FreeOids_vla->i_count,
		OM_Gw_current_OS,
		OM_Gp_CurOSD->OSO_Oid,
		oso_p_acld))))
      return(sts);

    /*=======================================*/
    /* Shrink SpaceMap if End Extent is Free */
    /*=======================================*/
    for(i=0; i<OSO_FreeOids_vla->i_count; i++)
    { 
      OM_p_GROUP_EXTENT	ext=(OM_p_GROUP_EXTENT)(OSO_FreeOids_vla->i_offset);

      if( ext[i].beg_oid + ext[i].size
	  == OM_Gp_CurOSD->CurSpaceMapSize )
      {  /* last extent of spacemap is in OSO's vla of free oids */
        if(!(ptr=(OM_p_SPAMAPENT)om$realloc(ptr=(char *) OM_Gp_CurSpaceMap,
	   size=(OM_Gp_CurOSD->CurSpaceMapSize-ext[i].size)
		*sizeof(OM_S_SPAMAPENT))))
	  return(OM_E_NODYNMEM);
        OM_Gp_CurSpaceMap = OM_Gp_CurOSD->Spacemap = ptr;
	OM_Gp_CurOSD->CurSpaceMapSize -= ext[i].size;
	/* move lower OSO_FreeOids extents up replacing freed one */
	for(j=i+1; j<OSO_FreeOids_vla->i_count; j++)
	{
	  ext[j-1] = ext[j];
	} 
	/* shrink OSO_FreeOids's extents */
        if(!(1&(sts=om$vla_set_dimension(p_vladescr=OSO_FreeOids_vla,
		size=OSO_FreeOids_vla->i_count-1,
		objid=OM_Gp_CurOSD->OSO_Oid,
		p_cld=oso_p_acld))))
    	{  
           BUGCHECK("OSO's FreeOIDS: set dimension failed");
    	}
        break;
      }
    }
  }

  /*===============================*/
  /* Delete Self; send wrt_message */
  /*===============================*/
  if(!(1&(sts=om$send(msg=message Root.delete(TRUE),
			targetid=my_id, mode=OM_e_wrt_message))))
    return(sts);
return(OM_S_SUCCESS);
}


/* 
Revision History:

	15-sep-1986       Initial release of this method.

        03-nov-1986  ems  Changed so as not to terminate pass on 
                           OM_E_NOSUCHCLASS.
                           
        13-feb-1988  saw  Changed to include swapped objects in msg send.

*/

/*=====================================================*/
/* This method sends all my objects the input message. */
/* If classlist is nonnull, only objects of class type */
/* specified in classlist are sent the message.        */
/*=====================================================*/

method pass (OM_p_MESSAGE msg; OM_p_CLASSLIST classlist; OM_E_WRT_FLAG flag)
{
  int			i, j, sts, internal_sts, count = 0;
  OM_p_SPAMAPENT	spacemap;
  OM_S_RIP		rip;
  OMbyte                *internal_classlist;
  OMbyte                classlist_exists;
  OM_S_OBJID		*group_objects;
  int			extent_size;
  OM_S_CLASSDEF		*p_target_acld=NULL;
  OM_S_SEND_CACHE	cache[OM_K_CACHE_SIZE], *p_cache=NULL;
  OMuword		saved_senderOS;
  OM_p_MESSAGE          p_msg=msg;

  /*=================================================*/
  /* insure that the message to be passed is NOT the */
  /* Group pass method or an ObjSpace pass method    */
  /*=================================================*/

  if(((p_msg->select.DefClassid == OM_K_OMGROUP_ACTCLASSID) &&
      (p_msg->select.FuncIndex  == OMGroup_OPP_pass_method_index)) ||
     ((p_msg->select.DefClassid == OM_K_OMOBJSPACE_ACTCLASSID) &&
      (p_msg->select.FuncIndex  == (OMuint) OMObjSpace_OPP_pass_method_index)))
    return(OM_E_NOPASSPASS);

  if(!(group_objects = (OM_S_OBJID *)
	om$malloc(size=sizeof(OM_S_OBJID)*ME.OMGroup->size)))
    return(OM_E_NODYNMEM);
  spacemap = OM_Gp_CurSpaceMap;

  /*====================================*/
  /* Build internal classlist if needed */
  /*====================================*/
  if ((classlist) && (classlist->w_count))
  {
    if ( classlist->w_flags & OM_CLST_internal )
    {
      internal_classlist = (OMbyte *)classlist->p_classes;
    }
    else
    {
      sts = som_build_internal_classlist ( classlist, &internal_classlist );
      if (!(1&sts))
      {
        om$dealloc (ptr=(char *) group_objects);
        return(sts);
      }
    }
    classlist_exists = TRUE;
  }
  else
  {
    classlist_exists = FALSE;
  }

  /*===============================*/
  /* Fill In Current Group Context */  
  /*===============================*/

  extent_size = om$dimension_of(varray=ME.OMGroup->extent);
  for(i=0; i<extent_size; i++)
  {
    for(j=ME.OMGroup->extent[i].beg_oid;
        j<(int) (ME.OMGroup->extent[i].beg_oid + ME.OMGroup->extent[i].size);
        j++)
    {
      if (((spacemap[j].flags & OM_SM_in_use) ||
           (spacemap[j].flags & OM_SM_in_mem)) &&
           !(spacemap[j].flags & OM_SM_unknown_obj))
      {
        if (spacemap[j].flags & OM_SM_in_mem)
        {
          if ( classlist_exists )
          {
            if ( internal_classlist[OM_GA_active_to_filed
                                   [spacemap[j].p_acld->w_classid]] )
            {
              group_objects[count] = j;
              count++;
            }
          }
          else
          {
            group_objects[count] = j;
            count++;
          }
        }
        else    /* object not in mem */
        {
          if ( classlist_exists )
          {
            if ( internal_classlist[OM_GA_active_to_filed
                              [spacemap[j].p_acld->w_classid]] )
            {
              group_objects[count] = j;
              count++;
            }
          }
          else
          {
            group_objects[count] = j;
            count++;
          }
        }
      }
    }
  }
  /*===============================*/
  /* Send Msg To Each Valid OID    */
  /*===============================*/

 if (count >= (int) OM_Gf_min_caching_send)
  {		/* clear local cache */
    for(i=0;i<OM_K_CACHE_SIZE;i++) cache[i].classid = OM_K_NOTUSING_CLASSID;
  }  
  for(i=0; i<count; i++)
  {
    if ( ! OM_OBJ_INVALID(spacemap[group_objects[i]].flags) )
    {
      if (count < (int) OM_Gf_min_caching_send)
      {
        sts = om$send(msg=p_msg, targetid=group_objects[i], mode=flag);
      }
      else	/* use cache to optimize send */
      {
        OM_CACHE_SEND(my_id, (group_objects[i]), rip, p_cache,
          cache, p_target_acld, flag, p_msg, NULL_CHANNUM, sts,
          internal_sts, err);
        if( (sts&1) && (1&internal_sts) )
        {
           if ( rip.p_mapentry->flags & OM_SM_send_depth )
           {
              OM_PREP_SEND(rip, saved_senderOS);
              sts = p_cache->p_method(p_msg, OM_Gw_current_OS, my_id,
                              group_objects[i], rip.p_mapentry,
                              NULL_CHANNUM, p_target_acld);
              OM_COMPLETE_SEND(rip, saved_senderOS, (group_objects[i]));
           }
           else
           {
	      if(p_cache->p_method != Root_Root_delete_method)
	      {
                  rip.p_mapentry->flags |= OM_SM_send_depth;
                  OM_PREP_SEND(rip, saved_senderOS);
                  sts = p_cache->p_method(p_msg, OM_Gw_current_OS, my_id,
                              group_objects[i], rip.p_mapentry,
                              NULL_CHANNUM, p_target_acld);
                  OM_COMPLETE_SEND_ROOTDEL(rip, p_target_acld, saved_senderOS, 
                             my_id, (group_objects[i]), NULL_CHANNUM, sts);
              }
              else
	      {
	          OMuword my_sdi;
	          my_sdi = rip.p_mapentry->sdi;
                  OM_PREP_SEND(rip, saved_senderOS);
                  sts = p_cache->p_method(p_msg, OM_Gw_current_OS, my_id,
                              group_objects[i], rip.p_mapentry,
                              NULL_CHANNUM, p_target_acld);
                  OM_Gw_senders_OS = saved_senderOS;
                  OM_GA_CSDarray[my_sdi].PostSendDepth++;
              }
           }
        }
      }
      if((sts == OM_I_STOP_SENDING) || ((!(1&sts)) && (sts & SEV_LEV)) &&
         (sts != OM_E_NOSUCHCLASS))
      {
        if ((classlist_exists) && 
            (!(classlist->w_flags & OM_CLST_internal)))
        {
          om$dealloc (ptr=(char *) internal_classlist);
        }
        om$dealloc (ptr=(char *) group_objects);
        return (sts);
      }
    }
  }  
  if ((classlist_exists) && (!(classlist->w_flags & OM_CLST_internal)))
  {
    om$dealloc (ptr=(char *) internal_classlist);
  }
  om$dealloc (ptr=(char *) group_objects);
  return (OM_S_SUCCESS);
}

end implementation OMGroup;
