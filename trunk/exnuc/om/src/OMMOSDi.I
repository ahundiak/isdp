class	implementation	OMMOSD;

#include	<string.h>
#include 	"OMobjectcomm.h"
#include 	"OMMOSD.h"
#include 	"OMmetaclass.h"
#include 	"OMmacros.h"
#include 	"OMparameters.h"

from OMObjSpace import pass;
from OMFiledOS  import write;

method modified_OS_wrt()
{

OMuword *list_of_os;
int     sts;
OMuword i, j;

#ifdef DEBUG
printf("MOSD.modified_OS_wrt -- entering.. \n");
#endif

	/* gather the list of os numbers which are filed and have modified
	/* ISO's .. */

        list_of_os = (OMuword *)om$calloc(num=1,
                                          size=sizeof(OMuword)*OM_Gw_maxOS);
        if (!list_of_os) return(OM_E_NODYNMEM);

	for(i=0,j=0; i< OM_Gw_maxOS; i++)
		if((OM_GA_OSDs[i]->flags&OM_OSD_ISOmodified) &&
		   (OM_GA_OSDs[i]->type &OM_OSD_filed	   ))
		     list_of_os[j++] = i;

	
#ifdef DEBUG
if(!j) printf("MOSD.modified_OS_wrt -- no OS's found to match criteria \n");
else
for(i=0; i<j; i++)
 printf("MOSD.modified_OS_wrt -- os %d will be written .. \n",list_of_os[i]);
#endif

	if(!j) {
          om$dealloc ( ptr = (char *) list_of_os );
          return(OM_S_SUCCESS);
        }
	/* next release .. compute disk space of os's to be written.. */

	/* now, reset the iso modified bit and THEN send a write message
	/* to the oso. This ordering will prevent a loop, since the write
	/* message will invoke this method if it has modified ISO's..*/

	for(i=0; i<j; i++)
	{
	    OM_GA_OSDs[list_of_os[i]]->flags &= ~OM_OSD_ISOmodified;
	    sts = om$send(targetos = list_of_os[i],
		    targetid = OM_GA_OSDs[list_of_os[i]]->OSO_Oid,
		    msg = message OMFiledOS.write(NULL));

 	    if(!(1&sts)) {
              om$dealloc ( ptr = (char *) list_of_os ); 
              return(sts);
            }
	}

        om$dealloc ( ptr = (char *) list_of_os );
	return(OM_S_SUCCESS);
}


/*****************************************************************/
method  get_OS_list	(int size; int *count; 
			 OMuword *OSnumbers; OM_S_OBJID *OSoids)
{
OMuword i,j;

	for(i=0, j=0;((int) i<size) && (i<ME.OMMOSD->w_number_entries); i++)
	  if(!IF_NULL_OBJID(ME.OMMOSD->st_oslist[i].OS_oid))
	  {
	    OSnumbers[j]   = ME.OMMOSD->st_oslist[i].OS_number;
	    OSoids   [j++] = ME.OMMOSD->st_oslist[i].OS_oid;
	  }
	  *count = j;
	  return(OM_S_SUCCESS);
}


method MOSD_init()
{
int i;
#ifdef DEBUG
printf("MOSD.MOSD_init -- entering .. \n");
#endif
	/* initialize the MOSD to ten entries, the
	/* first being the MOSDOS entry. We coulndt
	/* use the add entry method since the MOSD didnt exist. */

	om$vla_set_dimension(varray=ME.OMMOSD->st_oslist,size=10);
	ME.OMMOSD->st_oslist[0].OS_number = 0;
	ME.OMMOSD->st_oslist[0].OS_oid    = 0;
	strcpy(ME.OMMOSD->st_oslist[0].OS_name,OM_GA_OSDs[0]->name);

	/*  initialize the entries .. */
	for(i=1; i<10; i++)
	{
 	  ME.OMMOSD->st_oslist[i].OS_number = 0;
	  ME.OMMOSD->st_oslist[i].OS_oid   = NULL_OBJID;
	  ME.OMMOSD->st_oslist[i].OS_name[0] = '\0';
	}

	ME.OMMOSD->w_number_entries = 10;
	ME.OMMOSD->w_number_used    = 1;
	return(OM_S_SUCCESS);
}


method	delete (int flag)
{
  return (OM_E_NOTIMPL);
}


method	pass (char *p_arg)
{
  return (OM_E_NOTIMPL);
}

method	pass_thru (  OM_S_CLASSLIST *classlist;
		   OM_E_WRT_FLAG  wrt_flag;
		   OM_S_MESSAGE *msg  )
{
int i,k,size,used,sts;

#ifdef DEBUG
printf("MOSD.passthru -- entering .. \n");
#endif

	/* insure that the message to be passed is NOT this message */
	if((msg->select.DefClassid == OM_K_OMMOSD_ACTCLASSID) &&
	   (msg->select.FuncIndex  == OMMOSD_OPP_pass_thru_method_index))
        return(OM_E_INVARG);

	size = ME.OMMOSD->w_number_entries;
	used = ME.OMMOSD->w_number_used;
	
	for(i=0,k=0; (i<size) && (k<used) ; i++)
	   if(!IF_NULL_OBJID(ME.OMMOSD->st_oslist[i].OS_oid) &&
		            (ME.OMMOSD->st_oslist[i].OS_number))
		{
			k++;
#ifdef DEBUG
printf("MOSD.pass_thru -- sending to os/oid %d/%d\n",
	ME.OMMOSD->st_oslist[i].OS_number,ME.OMMOSD->st_oslist[i].OS_oid);
#endif

		    sts=om$send(targetos = ME.OMMOSD->st_oslist[i].OS_number,
				targetid = ME.OMMOSD->st_oslist[i].OS_oid,
				msg = 
                        message OMObjSpace.pass(classlist,wrt_flag,msg));
		    if(!(1&sts)) return(sts);

		}


  return (OM_S_SUCCESS);
}

method	add_entry (OMuint osnum; OM_S_OBJID oid; char *name)

{
OMuword used,size,i;
#ifdef DEBUG
printf("MOSD.add_entry osnum = %d oid = %d name = %s \n",osnum,oid,name);
#endif

	/* if the number used is equal to the number of entries, extend
	/* the vla by 10. */

	used = ME.OMMOSD->w_number_used;
	size = ME.OMMOSD->w_number_entries;

	if (used == size)
	{
	   om$vla_set_dimension(varray=ME.OMMOSD->st_oslist,size=size+10);
  	   ME.OMMOSD->w_number_entries += 10;

	   /* initialize the new entries */
	   for(i=size; i < ME.OMMOSD->w_number_entries; i++)
	   {
	     ME.OMMOSD->st_oslist[i].OS_number = 0;
	     ME.OMMOSD->st_oslist[i].OS_oid   = NULL_OBJID;
	     ME.OMMOSD->st_oslist[i].OS_name[0] = '\0';
	   }
	   size = ME.OMMOSD->w_number_entries;
	}

	/* find the first available slot.. */

	for(i=0; i<size; i++)
	  if(IF_NULL_OBJID(ME.OMMOSD->st_oslist[i].OS_oid)) break;

#ifdef DEBUG
printf("MOSD.add_entry -- found empty slot at index %d \n",i);
#endif
	/* increment number used */
	ME.OMMOSD->w_number_used++;

	/* add the new os to the list .. */
        ME.OMMOSD->st_oslist[i].OS_number = osnum;
	ME.OMMOSD->st_oslist[i].OS_oid    = oid;
	strncpy(ME.OMMOSD->st_oslist[i].OS_name,name,OM_K_MAXOSNAME_LEN);
	
  return (OM_S_SUCCESS);
}

method	delete_entry (OMuint osnum)

{
int     found;
OMuword i;
#ifdef DEBUG
printf("MOSD.delete_entry osnum = %d \n",osnum);
#endif

	/* find the entry based on osnum */

	for(i=0, found = 0; i< ME.OMMOSD->w_number_entries; i++)
	  if(ME.OMMOSD->st_oslist[i].OS_number == osnum)
	  {
		found = 1;
	  	ME.OMMOSD->st_oslist[i].OS_oid = NULL_OBJID;
		break;
	  }		  	

	if(!found) return(OM_W_OS_NOT_IN_MOSD);
	ME.OMMOSD->w_number_used --;
  return (OM_S_SUCCESS);
}

method	save_envr (char *filename)

{
  return (OM_E_NOTIMPL);
}

method	restore_envr (char *filename)

{
  return (OM_S_SUCCESS);
}

method	translate_entry (char *name; OMuword *resultOS; 
  			 OM_p_OBJID result_oid)

{
  return (OM_E_NOTIMPL);
}

method	modify_entry (char *name; OMuint modtype; int modvalue)

{
  return (OM_S_SUCCESS);
}

end	implementation	OMMOSD;
