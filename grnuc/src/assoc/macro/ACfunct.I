/*
  ACfunct.I
  robert patience
  21_jul_86
*/

class implementation ACcpx;

#define AS_DEBUG

#include "ASmacroi.h"
#include "macro.h"



/* ========================================================================= */
#define st_list_sz 20
static OM_S_OBJECT_LINKAGE jklist[st_list_sz];

ACmagic_read(my_id,xchan,list,cnt)
OM_S_OBJID 		my_id;
struct GRid		*list;
OM_S_CHANSELECT		*xchan;
int			cnt;
/*.ACmagic_read*/
{
  int 			scnt, status;
  OMuint 		i, pcnt;
  OM_S_OBJECT_LINKAGE 	*from_work = NULL;

  scnt=cnt;
  /*"ACmagic read on %d chan count %d  \n", my_id, scnt */
  if(scnt)
  {
    if(scnt<=st_list_sz)
	from_work= jklist;
    else
        from_work= (OM_S_OBJECT_LINKAGE *)
 		om$malloc (size = scnt * sizeof( OM_S_OBJECT_LINKAGE ));

    status = om$get_channel_objects(osnum 	= OM_Gw_current_OS,
                                  objid 	= my_id,
                                  p_chanselect 	= xchan,
                                  list 		= from_work,
                                  size 		= scnt,
                                  count 	= &pcnt);
    if (status!=OM_E_NO_RELATION) 
      as$status( action = GOTO_VALUE, value = CLEAN_MALLOC  );

    /*"ACmagic read objects found %d  \n", pcnt */
    for(i=0;i<scnt;i++)
    {
      if(i<pcnt)
       {
        list[i].objid = from_work[i].S_objid;
        list[i].osnum = from_work[i].osnum;
       }
      else
       {
        list[i].objid = NULL_OBJID;
       }
      /*"magic read object %d os %d \n", list[i].objid, list[i].osnum */
    }

  }

CLEAN_MALLOC:
    if(scnt > st_list_sz)   om$dealloc(ptr=from_work) ;

  return(1);
}

/* ========================================================================= */
ACread(mygrid,xchan,list,cnt)
struct GRid 		mygrid;
struct GRid		*list;
OM_S_CHANSELECT		*xchan;
int			cnt;
/*.ACread*/
{
  int 			scnt, status;
  OMuint 		i, pcnt;
  OM_S_OBJECT_LINKAGE 	*from_work = NULL;

  scnt=cnt;
  /*"read on %d chan count %d  \n", mygrid.objid, scnt */
  if(scnt)
  {
    if(scnt<=st_list_sz)
	from_work= jklist;
    else
        from_work= (OM_S_OBJECT_LINKAGE *)
 		om$malloc (size = scnt * sizeof( OM_S_OBJECT_LINKAGE ));

    status = om$get_channel_objects(osnum 	= mygrid.osnum,
                                  objid 	= mygrid.objid,
                                  p_chanselect 	= xchan,
                                  list 		= from_work,
                                  size 		= scnt,
                                  count 	= &pcnt);
    if (status!=OM_E_NO_RELATION) 
      as$status( action = GOTO_VALUE, value = CLEAN_MALLOC  );

    /*"ACmagic read objects found %d  \n", pcnt */
    for(i=0;i<scnt;i++)
    {
      if(i<pcnt)
       {
        list[i].objid = from_work[i].S_objid;
        list[i].osnum = from_work[i].osnum;
       }
      else
       {
	list[i].objid = NULL_OBJID;
       }
      /*"magic read object %d os %d \n", list[i].objid, list[i].osnum */
    }

  }

CLEAN_MALLOC:
    if(scnt > st_list_sz)   om$dealloc(ptr=from_work) ;

  return(1);
}

	  
end implementation ACcpx;
