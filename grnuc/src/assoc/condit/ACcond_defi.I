class implementation ACcond_def;

#include "macro.h"
#include "AS_status.h"
#include "OMprimitives.h"
#include "ASmacroi.h"
#include "expression.h"
#include "expmacros.h"
#include "acmacros.h"

%safe
static int ACsymb_hold_level = 0,
	ACsymb_hold_size = 0,
	ACsymb_hold_nb =0;
static struct GRid *ACsymb_hold_list = NULL;
%endsafe

#define AS_DEBUG

extern char *strpbrk();
extern GRclassid OPP_Gtext_exp_class_id,OPP_Gexp_class_id,
		 OPP_ACsymb_hold_class_id;

from expression import create;

/* Find the constructuction to be used by the conditional */


method ACfind_rep(IGRlong *msg; int tempsz; struct GRid sym; struct GRid *list;
	      struct GRid *rep_def; int *active_index; struct GRmd_env *md_env)
{
 char *wrk_name;
 int status;
 struct ret_struct rst;
 int i_const,nb_const;
 double fabs();
 char full_name[DI_PATH_MAX];
 int dir_index = -1;
 i_const = 0;

/* find condition value */

 status = om$send(msg = message NDmacro.ACgive_structure((int *)msg,&dir_index,
					me->xdtemp[0].down_scan,&rst,md_env),
		  targetid = list[me->xdtemp[0].back].objid,
		  targetos = list[me->xdtemp[0].back].osnum);

 nb_const = om$dimension_of(varray = me->condit);

 if(rst.type == text_type)
  {
   /*| text condit */
   for(i_const = 0; i_const<nb_const ; i_const++)
    {
   if(!strcmp(rst.var.text_st.text_string,me->condit[i_const].cond.value.str))
     									 break;
    }
  }
 else if(rst.type == double_type)
  {
   
   for(i_const = 0; i_const<nb_const ; i_const++)
    {
     /*"cond %d type %d value %lf\n",i_const,me->condit[i_const].cond.type,me->condit[i_const].cond.value.dbl*/
     /* just to support early condit */
     if(me->condit[i_const].cond.type == ACCOND_NUM )
        me->condit[i_const].cond.type =  ACCOND_EQUAL;
     if(ACCOND_EQUAL == (me->condit[i_const].cond.type&ACCOND_EQUAL))
      {
       /*| egality */
      
       if(fabs(rst.var.root_pm_st.value-me->condit[i_const].cond.value.dbl)
	  <1.e-6)
        {/*|  = OK */
         break;
        }
      }

     if( ACCOND_LESS ==(me->condit[i_const].cond.type&ACCOND_LESS))
      {
       /*| inegality */
       if(rst.var.root_pm_st.value < me->condit[i_const].cond.value.dbl)
        {/*| < OK */
         break;
        }
      }
     }
   }

/*"i_const %d\n",i_const */

 
if(i_const >= nb_const || i_const < 0)
 {
  printf("WARNING DEFAULT IS THE LAST CONSTRUCTION \n");
  i_const = nb_const-1;
 }
 
 wrk_name = me->condit[i_const].konst;

/*"macro is %s\n",wrk_name */
 *active_index = i_const;

/* chose corresponding construction */

  di$give_pathname(osnum = OM_Gw_current_OS,
		   pathname = full_name);
  strcat(full_name,":constructs:");
  strcat(full_name,wrk_name);

  rep_def->objid = NULL_OBJID;
  status = di$translate(  objname = full_name,
                           p_objid = &rep_def->objid,
                           p_osnum = &rep_def->osnum );
  if(status&1) *msg = MSSUCC;
  else         *msg = MSFAIL;

  if(!(status&*msg&1) || rep_def->objid == NULL_OBJID)
  if(rst.type == text_type)
  {
   printf
    ("WARNING construction %s NOT FOUND for conditional %s value %lf\n",
      me->condit[i_const].konst,me->macro_name,
      me->condit[i_const].cond.value.dbl);
  }
  else
  {
   printf
    ("WARNING construction %s NOT FOUND for conditional %s value %s\n",
      me->condit[i_const].konst,me->macro_name,
      me->condit[i_const].cond.value.str);
  }
	
  return (OM_S_SUCCESS);
 
}

/* ========================================================================= */

method ACbuild_macro(		
	int *suc, prop;	char *macro_name;
	int tot_up;	struct GRid *tlist;	struct sup *xdup;
        int tot_temp;	struct stemp *xdtemp; 
	int feet_num;	struct myfeet *v_myfeet; struct GRid *feet_list;
        struct GRid macro_hdr;			struct GRmd_env *md_env )
{
int status,i;

  me->prop  	= prop;
  me->comp_struct=0;
  me->map_struct=0;
  me->go_struct=0;
  me->symbol_macro.objid=NULL_OBJID;
  if(strlen(macro_name) > macro_MAX_CHAR-1)
   { printf(" macro name must be less than 15 characters\n");
     return OM_W_ABORT;
   }
  
  strcpy( me->macro_name, macro_name );

  status = om$send(msg =  message ACmacro_defn.ACtake_template(tot_up,xdup,
							tot_temp,xdtemp),
   		   targetid= my_id );
  as$status(action = RET_STATUS );

  status = om$vla_set_dimension(varray= me->myfeet,
                             size = feet_num );
  as$status( action = RET_STATUS );
  me->feet_num= feet_num;
  for(i=0;i< feet_num;i++)
   {
   me->myfeet[i]=v_myfeet[i];
   }
 
  return( OM_S_SUCCESS );
}/* build_ACmacro_defn */


/* ========================================================================= */
method ACconstruct_feet(IGRlong *msg;char rep;int tempsz;
		struct GRid sym;struct GRid *list;
		int *fcount;struct GRid *feet_list;struct GRmd_env *md_env)
{
int status,fmax;
struct GRid rep_def,*his_temp,*his_feet;
struct myfeet *his_feet_desc;
struct sup    *his_temp_desc;
int his_feet_num,his_temp_num,dh_f_n;
int dummy;
int active_index;

/* init */

  his_temp = NULL;
  his_feet = NULL;

/* Find the construction corresponding to the conditional value */

status = om$send(msg = message ACcond_def.ACfind_rep(msg, tempsz, sym, list,
		  				     &rep_def,&active_index,
						     md_env),
		 targetid = my_id);
  as$status(action = GOTO_VALUE, value = wrapup);

  if(!(*msg&1))
    {
     *fcount = 0;
     me->active_rep.objid = NULL_OBJID;
     return(OM_W_ABORT);
    }
  me->active_rep = rep_def;


/* Map the templates and creates if necessary default value template */

   status = om$send( msg = message ACmacro_defn.ACgive_upscan
		   (&his_temp_num, &dummy, &his_temp_desc),
		     targetid=rep_def.objid,targetos=rep_def.osnum );
   as$status(action = GOTO_VALUE, value = wrapup);

/* Map the template */

   if(his_temp_num)
     {
      his_temp=(struct GRid *) 
		om$malloc(size = his_temp_num*sizeof(struct GRid)); 
      status = om$send(msg =message ACcond_def.ACmap_temp
				(active_index,tempsz,list,
				 his_temp_num,his_temp_desc,his_temp,md_env),
		       targetid = my_id);
      as$status(action = GOTO_VALUE, value = wrapup);
     }
   

/* allocate space for the feet */
   status = om$send( msg = message ACcpx_defn.ACgive_feet_desc
		   (&his_feet_num, &his_feet_desc),
		     targetid=rep_def.objid,targetos=rep_def.osnum );
   as$status(action = GOTO_VALUE, value = wrapup);
   if(his_feet_num)
     {
      his_feet=(struct GRid *) 
		om$malloc(size = his_feet_num*sizeof(struct GRid)); 
     }
   dh_f_n=his_feet_num;

/*
   Does the construct feet for the construction corresponding to the
   condition 
*/


  /* get rid of symb_holder constructed before.  They have indeed be copied
     with copy to Groot and are no longer used, but only when I'm not in nested
     conditional compute !!!!!! */

if(ACsymb_hold_level == 0)
{
 long loc_msg;
 int i;
 struct GRmd_env md_env;
 md_env.md_id.objid = NULL_OBJID;
 md_env.md_env.matrix_type = MAIDMX;
 MAidmx(&loc_msg,md_env.md_env.matrix);

  for(i=0;i<ACsymb_hold_nb;i++)
   {
    GRclassid symb_class;
    extern OM_p_OSD *OM_GA_OSDs;
    
    if(ACsymb_hold_list[i].objid >= 
	       OM_GA_OSDs[ACsymb_hold_list[i].osnum]->CurSpaceMapSize) continue;
    if(om$get_classid(objid = ACsymb_hold_list[i].objid, 
    		    osnum = ACsymb_hold_list[i].osnum,
		    p_classid = &symb_class) != OM_S_SUCCESS) continue;

    if(   om$is_ancestry_valid(superclassid = OPP_ACsymb_hold_class_id,
			      subclassid = symb_class) != OM_S_SUCCESS
       && om$is_ancestry_valid(superclassname = "VDsymb_hold",
			      subclassid = symb_class) != OM_S_SUCCESS)continue;
    md_env.md_id.osnum = ACsymb_hold_list[i].osnum;
    om$send(msg = message NDnode.NDdelete(&md_env),
	    targetid = ACsymb_hold_list[i].objid,
	    targetos = ACsymb_hold_list[i].osnum);
   }
}
 
ACsymb_hold_level++;
   status = om$send(msg = message ACmacro_defn.ACconstruct_feet
		    (msg,rep,his_temp_num,sym,his_temp,&dh_f_n,his_feet,md_env),
		      targetid=rep_def.objid,targetos=rep_def.osnum); 
ACsymb_hold_level--;
   as$status(action = GOTO_VALUE, value = wrapup);


/* Evaluate the max number of feet of the conditionnal
*/

   if(his_feet_num)
     {
      status = om$send(msg =message ACcond_def.ACmap_feet
				(active_index,dh_f_n,his_feet_desc,
				 his_feet,feet_list,&fmax),
		       targetid = my_id);
      as$status();
     }

wrapup :
   if(his_temp) om$dealloc(ptr = his_temp); 
   if(his_feet) om$dealloc(ptr = his_feet);
   *fcount=fmax+1;

/*^{int i_jla;
    for(i_jla=0;i_jla<*fcount;i_jla++)
     {printf("%d --> %d %d\n",
	     i_jla,feet_list[i_jla].objid,feet_list[i_jla].osnum);
     }
   }
*/
 return status;
}

/* ========================================================================= */
method  ACcontext_compute_feet(char rep;int fcnt,ctxcnt;
		struct GRid *feet_list,*ctx_list;
		struct GRmd_env *md_env)
{
int status = OM_S_SUCCESS;

/*
   Evaluate the conditional using the representation obtained during the
   ACconstruct_feet method 
*/


  if(me->active_rep.objid != NULL_OBJID)
   {
   ACsymb_hold_level++;
   status = om$send(msg = message ACmacro_defn.ACcontext_compute_feet
			(rep,fcnt,ctxcnt,feet_list,ctx_list,md_env),
		    targetid=me->active_rep.objid,
		    targetos=me->active_rep.osnum); 
   ACsymb_hold_level--;
    if(!(status&1)) 
    printf("error when recomputing condit %s\n",me->macro_name);
   }

/* 
   jla jan 92 for object created to hold symbology, transfer symbology now 
   since these objects, not member of the dependency graph of the macro
   won't receive NDupdate message
*/

 {
  int i;
  struct GRid go;
  GRclassid go_class;
/*  extern GRclassid OPP_GRvg_class_id; */

  for(i=0;i<ctxcnt && i<fcnt;i++)
   {
    go = feet_list[i];
    
    status = om$get_classid(objid = go.objid,osnum = go.osnum,
			    p_classid = &go_class);
    if(!(status&1)) continue;
    /*if(om$is_ancestry_valid(superclassid =  OPP_ACsymb_hold_class_id,
			    subclassid = go_class) == OM_S_SUCCESS ||
       om$is_ancestry_valid(superclassname =  "VDsymb_hold",
			    subclassid = go_class) == OM_S_SUCCESS)*/
				ACtrans_symb(ctx_list[i],feet_list[i]);
   }
  }

  return(status);
}

/* Map the feet of the used macro with the feet of the conditional */

method ACmap_feet(int active_index; int his_feet_num;
		  struct myfeet *his_feet_desc;
		  struct GRid *his_feet, *my_feet; int *fmax)
{
 int i_his,i_my,pos;
 int status = OM_S_SUCCESS;

/* Map first real feet coming from the used macro inside the condit */

  for(i_my=0;i_my<me->feet_num;i_my++)
     my_feet[me->myfeet[i_my].pos].objid = NULL_OBJID;

  *fmax=-1;
  for(i_his=0;i_his<his_feet_num;i_his++)
   {
    if((his_feet_desc[i_his].chan & 3) == feet_in_graphic )
     {
     for(i_my=0;i_my<me->feet_num;i_my++)
      {
       if(!strcmp(me->myfeet[i_my].name,his_feet_desc[i_his].name))
        {
         /*^printf("mapping feet %s index condit %d cons %d obj %d\n",
		    me->myfeet[i_my].name,me->myfeet[i_my].pos,
		    his_feet_desc[i_his].pos,his_feet[i_his].objid);
         */
         my_feet[me->myfeet[i_my].pos]=his_feet[his_feet_desc[i_his].pos];
         if(me->myfeet[i_my].pos>*fmax) *fmax = me->myfeet[i_my].pos;
	 break;
        }
       if(i_my >= me->feet_num)
	{
	 printf("warning feet %s not found in conditional %s\n",
		 his_feet_desc[i_his].name);
	 status = OM_E_ABORT;
	}
      }
     }
   }

/* reallocate array of size not enought */

  if(ACsymb_hold_nb+me->feet_num > ACsymb_hold_size)
   {
    if(ACsymb_hold_size)
      ACsymb_hold_list=(struct GRid *) om$realloc(
 			ptr = (char *) ACsymb_hold_list,
		        size=(ACsymb_hold_nb+me->feet_num)*sizeof(struct GRid));
    else
      ACsymb_hold_list=(struct GRid *) om$malloc
		       (size=(ACsymb_hold_nb+me->feet_num)*sizeof(struct GRid));

    if(ACsymb_hold_list){ACsymb_hold_size = ACsymb_hold_nb+me->feet_num;}
    else {ACsymb_hold_size = 0; return OM_W_ABORT;}
   }

   for(i_my=0;i_my<me->feet_num;i_my++)
    {
     if((me->myfeet[i_my].chan & 3) != feet_in_graphic ) continue;

     pos = me->myfeet[i_my].pos;
     if(my_feet[pos].objid != NULL_OBJID) continue;
     if(ACfind_matching_name(me->myfeet[i_my].name,my_feet,me->myfeet,
			     me->feet_num) >= 0) continue;

     status = om$construct( classid = OPP_ACsymb_hold_class_id,
		  osnum = OM_Gw_current_OS,
		  p_objid = &my_feet[pos].objid);
     my_feet[pos].osnum = OM_Gw_current_OS;
   
     if(status&1)
      {
       om$send(msg = message NDnode.NDchg_state(ND_SUP_ONLY , ND_SUP_ONLY ),
	       targetid = my_feet[pos].objid,
	       targetos = my_feet[pos].osnum);
       if(me->myfeet[i_my].pos>*fmax) *fmax = me->myfeet[i_my].pos;
       ACsymb_hold_list[ACsymb_hold_nb++] = my_feet[pos];
      }
    }

  return(status);
}

/* Function to search if the name instanciated foot matches the passed name */

ACfind_matching_name(searched_name,feet_list,feet_desc,feet_num)
char *searched_name;
struct GRid *feet_list;
struct myfeet *feet_desc;
int feet_num;
{
 int i,ibis;
 char *c;
 int feet_name_len;

 feet_name_len = strlen(searched_name); 
 c = searched_name + feet_name_len -1;
 while(feet_name_len > 0 && *c >= '0' && *c <='9') 
     {c--; feet_name_len--;}
	   
 for(i=0; i<feet_num ; i++)
  {
   ibis = feet_desc[i].pos;
   if(feet_list[ibis].objid == NULL_OBJID) continue;
   if(pl_hold(feet_list[ibis])) continue;
   if(strncmp(searched_name,feet_desc[i].name,feet_name_len) == 0)
	return i;  /* found */
  }

 return -1; /* not found */
} 

/* Map conditional template to construction template */

method ACmap_temp(int active_index;
		  int my_temp_num ;struct GRid *my_temp;
		  int his_temp_num;struct sup *his_temp_desc;
		  struct GRid *his_temp; struct GRmd_env *md_env)
{
 int i_my,i_his;
 short index_default,temp_num;
 char *str,syntax[40];
 GRclassid exp_class;

 long msg,status = OM_S_SUCCESS;
 index_default = 0;


/* Initialize first template that have a default value */

 if(me->condit[active_index].temp_nb_def <= 0) temp_num = -1;
 else
  {
   index_default = me->condit[active_index].temp_first_def;
   temp_num = me->temp_default[index_default].index;
  }

 for(i_his=0 ; i_his<his_temp_num ; i_his++)
   {
      /* Is there a default value for this template ? */
      if(temp_num == i_his )
	{
	 /* construct corresponding template */
	 if(me->temp_default[index_default].type == ACTEMP_NUM)
           {
	    sprintf(syntax,"%20.9lf",me->temp_default[index_default].value.dbl);
	    str = syntax;
	    exp_class = OPP_Gexp_class_id;
	   }
	 else
	   {
	    str = me->temp_default[index_default].value.str;
	    exp_class = OPP_Gtext_exp_class_id;
	   }
      	 status = om$construct(classid = exp_class,
                                  osnum = md_env->md_id.osnum,
                                  p_objid = &his_temp[i_his].objid);
	 his_temp[i_his].osnum = md_env->md_id.osnum;
         as$status(action = RET_STATUS);

         status = om$send(msg = message expression.create
			  (NULL,str,(short *) &msg),
                    targetid = his_temp[i_his].objid,
                    targetos = his_temp[i_his].osnum);
         as$status(action = RET_STATUS);


	 /* points to the next default template */
	 index_default++;
	 if(index_default - me->condit[active_index].temp_first_def <
			    me->condit[active_index].temp_nb_def )
	  {
           temp_num = me->temp_default[index_default].index;
	  }
	 else
	  {
	   temp_num = -1;
	  }
	}
      else
	{
         for(i_my = 0 ; i_my<me->tot_temp ; i_my++)
          {
           if(strcmp(his_temp_desc[i_his].prompt,me->xdtemp[i_my].name) == 0)
	     {if(me->xdtemp[i_my].down_scan[0] == '.')
			 his_temp[i_his] = my_temp[me->xdtemp[i_my].back];
	      else
	       {
		status = om$send(msg = message NDmacro.ACreturn_foot
			      (&msg,me->xdtemp[i_my].down_scan,his_temp+i_his,
			       NULL,NULL),
             		     targetid = my_temp[me->xdtemp[i_my].back].objid,
                             targetos = my_temp[me->xdtemp[i_my].back].osnum);
		as$status(action = RET_STATUS);
		if(!(msg&1)) return OM_W_ABORT;
		status = as$make_source(go_grid  = his_temp[i_his],
		               as_os = his_temp[i_his].osnum,
			       as_grid  = his_temp+i_his); 
		as$status(action = RET_STATUS);
	       }
/*"temp %s of cons is %s in condit temp %s\n",his_temp_desc[i_his].prompt,me->xdtemp[i_my].down_scan,me->xdup[me->xdtemp[i_my].back].prompt*/
              break;
	     }
          }
         if(i_my >= me->tot_temp)
          {printf("template %s not found\n",his_temp_desc[i_his].prompt);
           return OM_W_ABORT;
          }
        }
    }
 return status;
}

method ACtake_feet(int feet_num; char *feet_name; int *chan_index)
{
 int i_feet;
 int num_graph;
 long status;

 me->feet_num = feet_num;
 status = om$vla_set_dimension(varray= me->myfeet,
                             size = me->feet_num );


/* Copy feet name and channel to use to get it */

 for(i_feet=0;i_feet<feet_num;i_feet++,feet_name += macro_MAX_CHAR)
    {
     strncpy(me->myfeet[i_feet].name,feet_name,macro_MAX_CHAR-1);
     me->myfeet[i_feet].name[macro_MAX_CHAR-1] = '\0';
/*     me->myfeet[i_feet].chan = channel[i_feet]; */
     me->myfeet[i_feet].chan = feet_in_graphic;
     
    }

/* Index of the feet on the owner channel */

  num_graph=0;
/*" num_feet %d me->feet %d\n",feet_num,me->feet_num */
  for(i_feet=0;i_feet<me->feet_num;i_feet++)
   {
   if((me->myfeet[i_feet].chan & 3) == feet_in_graphic)
    {
    /*| in graphic  */
    
    me->myfeet[i_feet].pos = num_graph;
    num_graph += 1;
    }
   /*%deme feet %s position %d\n",i_feet,me->myfeet[i_feet].name,me->myfeet[i_feet].pos*/
   }

 return OM_S_SUCCESS;
}

method ACtake_condit(char *condit_name; int num_condit; struct GRid *macro;
		     struct ACcond_val *value; int *num_default;
		     struct ACcond_temp *def_temp)
{
 int i,j;
 char *macro_name;
 long status;
 int index_default;


/* Alloc space */


 status = om$vla_set_dimension(varray= me->condit,
                             size = num_condit );

 index_default = 0;
 for(i=0;i<num_condit;i++)
  { /*" %d default %d\n",num_default[i] */
     index_default += num_default[i];
  }

 /*" condit_name %s num_condit %d num_default %d\n",condit_name,num_condit,index_default */
 if(index_default)
 status = om$vla_set_dimension(varray= me->temp_default,
                               size = index_default);
 
/* Store the information */

 index_default = 0;
 for(i=0;i<num_condit;i++)
  {
   /* Store macro name and condition value */
   status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		    targetid = macro[i].objid,
		    targetos = macro[i].osnum);

   strcpy(me->condit[i].konst,macro_name);
   me->condit[i].cond = value[i];

   /* Is there any default parameters */

   me->condit[i].temp_nb_def = num_default[i];
   me->condit[i].temp_first_def = index_default;

/*"%d first %d nb %d\n",i,me->condit[i].temp_first_def,me->condit[i].temp_nb_def*/

   for(j=0;j<num_default[i];j++,index_default++)
     me->temp_default[index_default] = def_temp[index_default];
  }

 /* add macro name in directory */

 /*"condit_name %s\n",condit_name*/

 ac$add_macro_name(macro_name = condit_name,
                   osnum = OM_Gw_current_OS,
                   macro_defn_id = my_id);

 strcpy(me->macro_name,condit_name);
 me->prop = ACcant_place_sym;

 return OM_S_SUCCESS;
}

method ACgive_condit_desc(int *num_condit;struct ACcond_descrip **condit_desc;
                          int *num_default;struct ACcond_temp **temp_default)

{
 *num_condit = om$dimension_of(varray = me->condit);
 *condit_desc = me->condit;
 *num_default = om$dimension_of(varray = me->temp_default);
 *temp_default = me->temp_default;
return OM_S_SUCCESS;
}
end implementation ACcond_def;
