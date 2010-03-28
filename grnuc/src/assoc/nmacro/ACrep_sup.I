class implementation ACncpx;

#define AS_DEBUG

extern char *regcmp();
extern char *regex();
extern char *strpbrk();


#include "ASmacroi.h"
#include "acrepdef.h"
#include "expression.h"
#include "expmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

from ACrg_collect import ACset_list_attribute,ACcreate,
 		         ACadd_attribute_by_type, AClist_attribute;
from expression import NDgive_value,create;

extern GRclassid OPP_expression_class_id;

method  ACput_rep(int rep,rep_mask)
{
int new_rep;
/*"set NVrep of obj %d rep %x rep_mask %x\n",my_id,rep,rep_mask */

/* Fix the shit I did between march and april 91 using only 4 bits per     */
/* character. Can be removed when all the files will be saved with this    */

 me->xform_chan = me->xform_chan | me->xform_pos<<4;
 me->xform_pos = 0;

 new_rep = rep            &  rep_mask |
           me->xform_chan & ~rep_mask;
 me->xform_chan = new_rep&0xff;

/*"xform_chan %x\n",me->xform_chan */
 return(OM_S_SUCCESS);
}

/* ========================================================================= */

method  ACget_rep(int *rep)
{
/* Fix the shit I did between march and april 91 using only 4 bits per     */
/* character. Can be removed when all the files will be saved with this    */
/* modif JLA 29/april/91						   */


 me->xform_chan = me->xform_chan | me->xform_pos<<4;
 me->xform_pos = 0;


 *rep = me->xform_chan;
/*"get rep of object %d rep %x\n",my_id,*rep*/
 return(OM_S_SUCCESS);
}

/* ========================================================================= */
/*
   This function evaluates the representation of the entity
   from its own representation 
   and eventualy from its parents representation
*/

ACcompute_rep_value(rep_in,root,count,rep_out)
int rep_in,*rep_out;
struct GRid *root;
int count;
/*.ACcompute_rep_value*/
{
 int i,temp_rep,union_rep;
 int status;
 long loc_msg;

 if(rep_in&AC_FREE_REP)
   { /*| representation of the entity is free */
      *rep_out = rep_in;
   }
 else
   { /*" Check root representation consistency count %d\n",count */
    union_rep = 0;
    for(i=0;i<count;i++)
     {
      struct GRid go;
      /* jla 3.dec.92 didn't work accross reference file */
      status = om$send(msg = message NDmacro.ACreturn_foot
					(&loc_msg,"",&go,NULL,NULL),
		       senderid = NULL_OBJID,
		       targetid = root[i].objid,
		       targetos = root[i].osnum);

  
      if(status&1)
      status = om$send(msg = message ACncpx.ACget_rep(&temp_rep),
		       senderid = NULL_OBJID,
		       targetid = go.objid,
		       targetos = go.osnum);
      if(!(status&1)) continue;
      if(!(temp_rep)) continue;
      if(temp_rep&AC_SUB_REP) goto error;
      if(union_rep)
       {
        /*"union_rep %x temp_rep %x\n",union_rep, temp_rep&AC_VDS_REP */
	if(union_rep != (temp_rep&AC_VDS_REP)) goto error;
       }
      else
       {
	 union_rep = temp_rep&AC_VDS_REP;
       }
     }
    /* What to do with the parent representation */
    /*"union_rep %x\n",union_rep*/

    if(rep_in&AC_DEP_REP)
      {
       if(!union_rep) goto error;
       *rep_out = AC_DEP_REP | union_rep;
      }

    else 
      {
       if(union_rep) *rep_out = AC_DEP_REP | union_rep;
       else 	     *rep_out = AC_FREE_REP;
      }
   }
  /*"rep in %x rep_out %x\n",rep_in,*rep_out*/
  return 1;

error :

  *rep_out = AC_ERROR_REP;
  /*"rep in %x rep_out %x\n",rep_in,*rep_out*/
  return 1;
}

/*
   This function creates an expression corresponding
   to the representation value .
*/


ACgenerate_rep(rep,osnum,temp_rep)
int rep;
GRspacenum osnum;
struct GRid *temp_rep;
/*.ACgenerate_rep*/
{
 int status;
 int to_affect, irep;
 char syntax[20];
 double rep_db;
 short rc;
 
 static int nb_rep = 0, 
	    size_rep = 0;
 static struct GRid *rep_obj = NULL;

 /*" generate rep with value %x\n",rep */
 /* Search if I already have this value somewhere */

 to_affect = nb_rep;
 for (irep=0; irep<nb_rep;irep++)
  {
   if(rep_obj[irep].osnum != osnum) continue;

   status = om$send(msg = message expression.NDgive_value(&rep_db),
		      senderid = NULL_OBJID,
		      targetid = rep_obj[irep].objid,
		      targetos = rep_obj[irep].osnum);
   if(!(status&1))
      {
       if(to_affect == nb_rep) to_affect = irep;
       continue;
      }
   if(rep_db == rep)
      {
       *temp_rep = rep_obj[irep];
       /*"%d %d already exists\n",rep_obj[irep].objid,rep_obj[irep].osnum */
       return OM_S_SUCCESS;
      }
    
  }

 /* Need to create it */

 if(to_affect >= size_rep)
  {
   if (rep_obj == NULL)
    {
     size_rep = 10;
     rep_obj = (struct GRid *) om$malloc (size = size_rep*sizeof(struct GRid));
    }
   else 
    {
     size_rep = size_rep*2;
     rep_obj = (struct GRid *) om$realloc(size = size_rep*sizeof(struct GRid),
					  ptr = (char *)rep_obj);
    }
  }
 if(rep_obj == NULL)
  {
   temp_rep->objid = NULL_OBJID;
   return OM_W_ABORT;
  }

 sprintf(syntax,"%d",rep);
 status = om$construct(classid = OPP_expression_class_id,
		       osnum = osnum,
		       p_objid = &temp_rep->objid,
		       msg = message expression.create(NULL,syntax,&rc));
 as$status(action = RET_STATUS);
 temp_rep->osnum = osnum;

 status = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH,ND_DEL_NO_CH ),
		  senderid = NULL_OBJID,
		  targetid = temp_rep->objid,
		  targetos = temp_rep->osnum);
 as$status();
 rep_obj[to_affect] = *temp_rep;
 /*" create %d %d \n",rep_obj[irep].objid,rep_obj[irep].osnum */
 if(to_affect >= nb_rep) nb_rep++;
 return status;
}


/* message to get and put NAVSEA representation */
method  ACset_NV_rep(unsigned char rep;struct GRmd_env *mod_env)
{
int status;
/*"set NVrep of obj %d rep %x\n",my_id,rep */
/* Fix the shit I did between march and april 91 using only 4 bits per     */
/* character. Can be removed when all the files will be saved with this    */

 me->xform_chan = me->xform_chan | me->xform_pos<<4;
 me->xform_pos = 0;

 if(me->xform_chan != rep)
  {
  me->xform_chan = me->xform_chan&  (AC_FREE_REP|AC_DEP_REP) |
		             rep & ~(AC_FREE_REP|AC_DEP_REP);
/* note computes top level assoc entity */
  status = om$send(msg = message ACncpx.ACchange_node(NULL),
		     targetid = my_id );
  as$status();
  }
 return(OM_S_SUCCESS);
}

method  ACput_NV_rep(unsigned char rep)
{
/*"set NVrep of obj %d rep %x\n",my_id,rep */
/* Fix the shit I did between march and april 91 using only 4 bits per     */
/* character. Can be removed when all the files will be saved with this    */

 me->xform_chan = me->xform_chan | me->xform_pos<<4;
 me->xform_pos = 0;


  me->xform_chan = me->xform_chan&  (AC_FREE_REP|AC_DEP_REP) |
		             rep & ~(AC_FREE_REP|AC_DEP_REP);
 return(OM_S_SUCCESS);
}

/* ========================================================================= */

method  ACget_NV_rep(unsigned char *rep)
{
 /*"get NVrep of %d is %x\n",my_id,me->xform_chan */
 
/* Fix the shit I did between march and april 91 using only 4 bits per     */
/* character. Can be removed when all the files will be saved with this    */

 me->xform_chan = me->xform_chan | me->xform_pos<<4;
 me->xform_pos = 0;


 *rep = me->xform_chan & ~(AC_FREE_REP|AC_DEP_REP);
 return(OM_S_SUCCESS);
}

#define ACTIVE_SYMB   ":IGENOD:ACsymb"
#define POSSIBLE_SYMB ":IGENOD:ACpossible_symb"

/* ========================================================================= */
/* This function retrieves the active representation 			     */
/* If representation and symbology collection doesn't exist create it        */
/* return values not collection id					     */
/* ========================================================================= */
ACget_def_NVrep(prep,esymb)
unsigned char *prep;
struct GRsymbology *esymb;
{
int status,data_size;
struct GRid coll;
long  msg;
struct GRid	mod;
IGRchar	path_name[DI_PATH_MAX];
IGRlong S1,S2;
struct ACrg_coll list[6];

  status = ex$get_cur_mod( id = &mod.objid, osnum = &mod.osnum);
  as$status();

  status= di$give_pathname( osnum = mod.osnum,
			     pathname = path_name );
  strcat( path_name, ACTIVE_SYMB );
  /*^printf( "User path name is %s \n", path_name );*/
  status= di$translate ( objname = path_name,
			 osnum	  = mod.osnum,
			 p_objid  = &coll.objid, 
			 p_osnum  = &coll.osnum );


  if( !(status  & SUCC ) ) 
   {
   /*| ACget_def_NVrep return default */
   *prep=AC_2D_REP;
   S1 = sizeof( struct IGRdisplay );
   gr$get_active_display(
			msg    = &msg,
			sizbuf = &S1,
			buffer = &(esymb->display_attr),
			nret   = &S2 );
   esymb->level=1;
   /*"create with name %s\n",path_name */
   status = om$construct(classid = OPP_ACrg_collect_class_id,
                       osnum = mod.osnum,
                       p_objid = &coll.objid,
                       msg = message ACrg_collect.ACcreate(&msg,path_name));
   coll.osnum = mod.osnum;
   as$status(action = GOTO_VALUE,
             value  = error);

   strcpy(list[0].name,"rgb_value");
   list[0].desc.type= AC_ATTRIB_DOUBLE;
   list[0].desc.value.att_exp = 0;

   strcpy(list[1].name,"color");
   list[1].desc.type= AC_ATTRIB_DOUBLE;
   list[1].desc.value.att_exp = esymb->display_attr.color;

   strcpy(list[2].name,"weight");
   list[2].desc.type= AC_ATTRIB_DOUBLE;
   list[2].desc.value.att_exp = esymb->display_attr.weight;

   strcpy(list[3].name,"style");
   list[3].desc.type= AC_ATTRIB_DOUBLE;
   list[3].desc.value.att_exp = esymb->display_attr.style;

   strcpy(list[4].name,"level");
   list[4].desc.type= AC_ATTRIB_DOUBLE;
   list[4].desc.value.att_exp = esymb->level;

   strcpy(list[5].name,"representation");
   list[5].desc.type= AC_ATTRIB_DOUBLE;
   list[5].desc.value.att_exp = *prep;

   status =om$send(msg = message ACrg_collect.ACset_list_attribute(&msg,6,list),
                  senderid = NULL_OBJID,
                  targetid = coll.objid,
                  targetos = coll.osnum);
   as$status(action = GOTO_VALUE,
             value  = error);


   }
  else
   {
   /*| ACget_def_NVrep found occurence */
   data_size=0;
   status =om$send(msg = message ACrg_collect.AClist_attribute(&msg,6,list,
								&data_size ),
                  senderid = NULL_OBJID,
                  targetid = coll.objid,
                  targetos = coll.osnum);
   as$status(action = GOTO_VALUE,
             value  = error);

   esymb->display_attr.color     = list[1].desc.value.att_exp ;
   esymb->display_attr.weight    = list[2].desc.value.att_exp ;
   esymb->display_attr.style     = list[3].desc.value.att_exp ;
   esymb->level     		 = list[4].desc.value.att_exp ;
   *prep			 = list[5].desc.value.att_exp ;
   }
   
return(1);
error :

  *prep = AC_ERROR_REP;

return(1);  
}


/* ========================================================================= */
/* This function retrieves the collection of possible representations 	     */
ACget_possible_rep_col(coll)
struct GRid *coll;
/*.ACget_possible_rep_coll */
{
IGRlong status;
struct GRid mod;
IGRchar	path_name[DI_PATH_MAX];

  status = ex$get_cur_mod( id = &mod.objid, osnum = &mod.osnum);
  as$status();

  status= di$give_pathname( osnum = mod.osnum,
			     pathname = path_name );
  strcat( path_name, POSSIBLE_SYMB );
  status= di$translate ( objname = path_name,
			 osnum	  = mod.osnum,
			 p_objid  = &coll->objid, 
			 p_osnum  = &coll->osnum );
  if(!(status&1)) coll->objid = NULL_OBJID;
  return 1;
}

/* ========================================================================= */
/* This function creates  the collection of possible representations 	     */

ACcreate_possible_rep_col(coll)
struct GRid *coll;
/*.ACcreate_possible_rep_coll */
{
IGRlong status,msg;
struct GRid mod;
IGRchar	path_name[DI_PATH_MAX];
struct ACrg_coll list[3];


/* Does it already exist */

 ACget_possible_rep_col(coll);
 if(coll->objid != NULL_OBJID) return OM_S_SUCCESS;

/* Creates it */

 status = ex$get_cur_mod( id = &mod.objid, osnum = &mod.osnum);
 as$status();

 status= di$give_pathname( osnum = mod.osnum,
			   pathname = path_name );
 as$status(action = GOTO_VALUE,
	   value  = error);
 strcat( path_name, POSSIBLE_SYMB );

 /*"create with name %s\n",path_name */
 status = om$construct(classid = OPP_ACrg_collect_class_id,
		       osnum = mod.osnum,
		       p_objid = &coll->objid,
 		       msg = message ACrg_collect.ACcreate(&msg,path_name));
 coll->osnum = mod.osnum;
 as$status(action = GOTO_VALUE,
	   value  = error);

 strcpy(list[0].name,"Symbolic");
 list[0].desc.type= AC_ATTRIB_DOUBLE;
 list[0].desc.value.att_exp = AC_2D_REP; 

 strcpy(list[1].name,"Detailed");
 list[1].desc.type= AC_ATTRIB_DOUBLE;
 list[1].desc.value.att_exp = AC_3D_REP; 

 strcpy(list[2].name,"Envelope");
 list[2].desc.type= AC_ATTRIB_DOUBLE;
 list[2].desc.value.att_exp = AC_ENV_REP; 

 status = om$send(msg = message ACrg_collect.ACset_list_attribute(&msg,3,list),
		  senderid = NULL_OBJID,
		  targetid = coll->objid,
		  targetos = coll->osnum);
 as$status(action = GOTO_VALUE,
	   value  = error);

 return OM_S_SUCCESS;

 error : coll->objid = NULL_OBJID;
	 return OM_W_ABORT;
}

ACadd_representation(name,value)
char *name;
int value;
{
 struct GRid col;
 char syntax[20];
 IGRlong status,rc;
 
 status = ACcreate_possible_rep_col(&col);
 as$status(action = RET_STATUS);

 sprintf(syntax,"%d",value);
 status = om$send(msg = message ACrg_collect.ACadd_attribute_by_type
				  (&rc, AC_ATTRIB_DOUBLE,name,syntax),
		  senderid = NULL_OBJID,
		  targetid = col.objid,
		  targetos = col.osnum);
 as$status(action = RET_STATUS);
 return 1;
}
end implementation ACncpx;
