/*
  ACcpx_defni.I
  robert patience
  21_jul_86
*/
class implementation ACtmp_defn;

#include "ctype.h"
#include "ASmacroi.h"
#include "macro.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"
/* START VDS CORRECTION */
#include "exmacros.h"
/* START VDS CORRECTION */

#include "acdef.h"
#include "acmacros.h"

#define AS_DEBUG

from IGRdir import translate;
from OMObjSpace import pass;

extern GRclassid OPP_ACtmp_defn_class_id;

char *strrchr();

struct ACsymbol_struct
       { struct GRid symb_def ,  /* symbolic definition                       */
                     real_def ;  /* real definition                           */
	 int    used;            /* number of time the symb definition is used*/
       } ;

%safe
IGRint ACnb_symb = 0,         /* number of elements in list */
       ACsize_symb = 0;       /* size of list */

struct ACsymbol_struct *ACsymbol_def = NULL;
%endsafe

ACinit_symbol()
/*.ACint_symbol*/
{
ACnb_symb = 0;
return(OM_S_SUCCESS);
}

/*
  Initialise the symbol <--> real correspondance table with the
  symbolic macro definition existing in the current OS
*/

ACload_symbol(osid,osnum)
OM_S_OBJID osid;
GRspacenum osnum;
/*.ACload_symbol*/
{
 int status;
 OM_S_CLASSLIST clist;
 struct GRid real_grid;

  clist.w_count=1;
  clist.w_flags=OM_CLST_subclass;
  clist.p_classes=&OPP_ACtmp_defn_class_id;

  ACalloc_symbol();

  status = om$send(msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                              message ACtmp_defn.ACreturn_real_def
					(&real_grid,(IGRchar *)ACsymbol_def)),
		   senderid = NULL_OBJID,
		   targetid = osid,
		   targetos = osnum);

  as$status();

  return(OM_S_SUCCESS);
 }



ACalloc_symbol()
/*.ACalloc_symbol*/
{
/* START VDS CORRECTION */
        int     i;
/* END   VDS CORRECTION */

  ACsize_symb += 50;


  if(ACsymbol_def == NULL)
    {
     /*" alloc _symbol size %d\n",ACsize_symb */
     ACsymbol_def = (struct ACsymbol_struct *) om$malloc
			  (size = ACsize_symb * sizeof(struct ACsymbol_struct));
    }
  else
    {
     /*" realloc _symbol size %d\n",ACsize_symb */
     ACsymbol_def = (struct ACsymbol_struct *) om$realloc
			(size = ACsize_symb * sizeof(struct ACsymbol_struct),
			 ptr  = (IGRchar *)ACsymbol_def);
    }

/* START VDS CORRECTION */
    for( i=ACnb_symb ; i<ACsize_symb ; i++ ){
       ACsymbol_def[i].symb_def.objid = NULL_OBJID ;
       ACsymbol_def[i].symb_def.osnum = 0 ;
       ACsymbol_def[i].real_def.objid = NULL_OBJID ;
       ACsymbol_def[i].real_def.osnum = 0 ;
       ACsymbol_def[i].used           = 0 ;
    }
/* END   VDS CORRECTION */

  return(OM_S_SUCCESS);
}

ACfree_symbol()
/*.ACfree_symbol*/
{
  if(ACsymbol_def != NULL) om$dealloc(ptr = ACsymbol_def);
  ACsymbol_def = NULL;
  ACsize_symb = 0;
  return(OM_S_SUCCESS);
}


/*
   Return the grid of the real macro definition corresponding to the
   symbolic one if the couple is already store in the correspondance 
   table 
*/

ACret_in_symbol(symb_def,real_def,used)
struct GRid symb_def,*real_def;
int used;
/*.ACret_in_symbol*/
{
 IGRint i;
 

 real_def->objid = NULL_OBJID;

 for(i=0;i<ACnb_symb;i++)
  {
   if(   IF_EQ_OBJID(symb_def.objid ,  ACsymbol_def[i].symb_def.objid)
      && 	     symb_def.osnum == ACsymbol_def[i].symb_def.osnum)
   {
    /*| found */
   
    ACsymbol_def[i].used += used;
    *real_def = ACsymbol_def[i].real_def;
    break;
   }
  }
 /*"ret %d %d --> %d %d used %d\n",symb_def.objid,symb_def.osnum,real_def->objid,real_def->osnum,ACsymbol_def[i].used*/
 return(OM_S_SUCCESS);
}

/*
   Return the grid of the symbolic macro definition corresponding to the
   real one if the couple is already store in the correspondance table 
*/


ACret_in_real(real_def,symb_def,used)
struct GRid real_def,*symb_def;
int used;
/*.ACret_in_real*/
{
 IGRint i;
 

 symb_def->objid = NULL_OBJID;

 for(i=0;i<ACnb_symb;i++)
  {
   if(   IF_EQ_OBJID(real_def.objid ,  ACsymbol_def[i].real_def.objid)
      && 	     real_def.osnum == ACsymbol_def[i].real_def.osnum)
   {
    /*| found */
   
    ACsymbol_def[i].used += used;
    *symb_def = ACsymbol_def[i].symb_def;
    break;
   }
  }
 /*"ret %d %d --> %d %d used %d\n",real_def.objid,real_def.osnum,symb_def->objid,symb_def->osnum,ACsymbol_def[i].used*/
 return(OM_S_SUCCESS);
}

/*
   Clear non used symbol definition and return remaining number of
   symbol definition 
*/

ACclear_symbol(nb_symb)
int *nb_symb;
/*.ACclear_symbol */
{
 long status;
 int i;

/* START VDS MODIFICATION */
        char    className[40];
/* END   VDS MODIFICATION */

 *nb_symb = 0;
 for(i=0;i<ACnb_symb;i++)
  {
/*"used[%d] = %d\n",i,ACsymbol_def[i].used */

   if(ACsymbol_def[i].used == 0)
     {
 /*^{
        char debug_file[80],debug_macro[80];
 
    om$send(msg = message ACtmp_defn.ACget_mac_name(debug_file,debug_macro),
	    senderid = NULL_OBJID,
            targetid = ACsymbol_def[i].symb_def.objid,
            targetos = ACsymbol_def[i].symb_def.osnum);

    printf("delete %d %d connection for  name %s %s\n",
           ACsymbol_def[i].symb_def.objid,ACsymbol_def[i].symb_def.osnum,
           debug_file,debug_macro);
    }
  */
/* START VDS CORRECTION */
        *className = '\0';
        status =
        om$get_classname( objid = ACsymbol_def[i].real_def.objid,
                          osnum = ACsymbol_def[i].real_def.osnum,
                          classname = className );
        if( !(status&1) || !strlen( className) ){
          continue ;
        }

        if( om$is_ancestry_valid( superclassname = "ACcpx_defn",
                                subclassname = className ) == OM_S_SUCCESS){

          status =
          om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = ACsymbol_def[i].symb_def.objid,
                       targetos = ACsymbol_def[i].symb_def.osnum);
          as$status();
/* END   VDS CORRECTION */     
        }
     }
   else
     {
      *nb_symb += 1;
     }
  }
 /*"%d symbol used \n",*nb_symb */
 return(OM_S_SUCCESS);
}
ACadd_in_symbol(symb_def,real_def,used)
struct GRid symb_def,real_def;
int used;
/*.ACadd_in_symbol*/
{

 /*"add %d %d --> %d %d\n",symb_def.objid,symb_def.osnum,real_def.objid,real_def.osnum*/
 if(ACnb_symb >= ACsize_symb) ACalloc_symbol();

 ACsymbol_def[ACnb_symb].symb_def = symb_def;
 ACsymbol_def[ACnb_symb].real_def = real_def;
 ACsymbol_def[ACnb_symb++].used = used;

 return(OM_S_SUCCESS);
}
  
 
method ACreturn_real_def(struct GRid *real_def;char *h_table)
{
 struct GRid my_grid,dir;
 IGRchar *macro_name,*file_name,*new_file_name;
 char *separ,*strchr();
 IGRlong status;
 IGRint msg;
 IGRint open_index,open_mode;
 char new_name[256],full_name[DI_PATH_MAX]; 
 int name_len;

/* START VDS CORRECTION */
/*
 * When the temp_def object is found in the process of looking for the
 * real macro definition, we need to attach the library to the list of
 * existing macros.
 */
extern  int             ACpath_gr_number ;
extern  int             ACpath_gr_total ;
extern  struct  GRid    *ACpath_grid ;
extern  int             *ACpath_in_open ;
extern  int             ACopen_number ;
/* END   VDS CORRECTION */

/* return real definition valid for myself */

 new_file_name = NULL;

 /*" Is this definition %s already in the hcode table\n",me->total_name */
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;


 if(h_table != NULL) ACret_in_symbol(my_grid,real_def,0);
 else 		     real_def->objid = NULL_OBJID;


 if(IF_NULL_OBJID(real_def->objid))
  {
 /*| no ---> need to mount corresponding file */

   separ  = strchr(me->total_name,',');
   if(!separ) return OM_W_ABORT;
   *separ = '\0';
   macro_name = separ+1;
   file_name = me->total_name;

   /*"file_name %s \n  macro_name %s\n",file_name,macro_name*/

 
/*" code commented out for file name "." case
   else
    {
     char path_name[80];
     ACos_to_path(OM_Gw_current_OS,path_name);
     status = ACactivate(path_name,&dir,EX_read_only,&open_index,&open_mode);
    }
*/
  if(!strcmp(file_name,"."))
    {
       /* Macro exists in the current file, get the macro id
	  from the translation
	*/
       sprintf(full_name,"constructs:%s",macro_name);

       msg = di$translate(osnum = OM_Gw_current_OS,
			  objname =full_name, 
			  p_objid = &real_def->objid,
			  p_osnum = &real_def->osnum);
       *separ = ',';
       new_file_name = NULL;
			  
     }
   else
     {
/* START VDS CORRECTION */
        int             tmpMax ;
        GRspacenum      curOs ;

        status = ex$get_cur_mod( osnum = &curOs );

       tmpMax = ACopen_number ;
/* END   VDS CORRECTION */

     status = ACactivate(file_name,&dir,EX_read_only,&open_index,&open_mode);

     /* 
       JLA 11 June 89 : Some dim macros are with the full file name instead of
       the path name relative to the PPL path (I don't know why ....)
     */
       if(!(status&1))
	 {
	   new_file_name = strrchr(file_name,'/');
	   if(new_file_name != NULL)
	     {
	       new_file_name++ ;
	       status = ACactivate(new_file_name,&dir,EX_read_only,
				   &open_index,&open_mode);
	       if(status&1)
		 {
		   *separ = ',';
		   strncpy(new_name,new_file_name,256);
		   new_name[255] = '\0';
		   new_file_name = new_name;
		 }
	       else new_file_name = NULL;
	     }
	 }
       
       *separ = ',';

       if(status&1)
	 {
	   /*"translate %s in dir %d %d\n",macro_name,dir.objid,dir.osnum */
	   status = om$send( msg = message IGRdir.translate(&msg,macro_name,
						   0,NULL,&real_def->objid),
			    targetid = dir.objid,
			    targetos = dir.osnum);
	   real_def->osnum = dir.osnum;
	 }

/* START VDS CORRECTION */

        /*
         * ADD the information to the global structures, only when symbolic
         * macro is from the active design file.
         * When the total number of libraries changed, tmpMax is different
         * from ACopen_number and we need to add the library to the list
         * of attached libraries.
         */
        if((curOs == OM_Gw_current_OS) && (tmpMax != ACopen_number)){
         if(ACpath_gr_number >= ACpath_gr_total){
          ACpath_gr_total += 10;
          if(ACpath_grid == NULL){
            /*| allocate ACpath_gr */
            ACpath_grid = (struct GRid *)om$malloc(
                            size = ACpath_gr_total*sizeof(struct GRid));
            ACpath_in_open = (IGRint *)om$malloc(
                                    size = ACpath_gr_total*sizeof(IGRint));
          }
          else{
            /*| reallocate ACpath_gr */
            ACpath_grid =(struct GRid *)om$realloc(ptr = (IGRchar
*)ACpath_grid,
                            size = ACpath_gr_total*sizeof(struct GRid));
            ACpath_in_open = (IGRint *)om$realloc(ptr=(IGRchar
*)ACpath_in_open,
                           size = ACpath_gr_total*sizeof(IGRint));
          }
         }
         ACpath_in_open[ACpath_gr_number] = open_index;
         ACpath_grid[ACpath_gr_number++]  = dir ;
        } /* end add in library ... */
     }

/* END   VDS CORRECTION */

/*
   else
     {
      msg = 0;
     }
*/
   if(msg != DIR_S_SUCCESS)
     {
      /*| Try to find the macro def in the current ACpath */
      status = ac$find_macro_defn(action = ACfind_no_load,
				  macro_name = macro_name,
				  p_macro_defn_id = real_def);
      if(status&1)
       {
	 /*" found in the os %d\n",real_def->osnum */
	 status = ac$lib_name(osnum = real_def->osnum,
			      name_size = 256,
			      name = new_name,
			      name_len = &name_len);
	/*"Its name is %s len %d\n",new_name,name_len*/
       }
      if((status&1) && (name_len + strlen(macro_name)+1 < 256))
       {
	new_name[name_len-1] = ',';
	strcpy(new_name+name_len,macro_name);
	new_file_name = new_name;
	/*"new info stored %s\n",new_file_name */
       }
      else status = OM_W_ABORT;
  
      
      if(status&1)
        {
 	 msg = DIR_S_SUCCESS;
        }
     }

/* If the real macro is not found error message only if it is not during
   save
*/

   if(msg != DIR_S_SUCCESS)
     {
      if (h_table == NULL)
       {
	printf("macro %s not found in %s\n",macro_name,file_name);
	return OM_W_ABORT;
       }
      else
       {
	return OM_S_SUCCESS;
       }
     }

   if(h_table != NULL) ACadd_in_symbol(my_grid,*real_def,0);
  }

/* JLA 11 June 89 : Correct file name if necessary */

if(new_file_name != NULL) 
  {
   as$status(sts = 0,
string=("obj %d %d macro name was %s\n",my_id,OM_Gw_current_OS,me->total_name));

   status = om$vla_set_dimension(varray = me->total_name,
				 size = strlen(new_file_name)+1);
   as$status(action = RET_STATUS);
   
   strcpy(me->total_name,new_file_name);

   as$status(sts = 0,
             string =("is changed to %s\n",me->total_name));
  }
   
   /*" return %d %d\n",real_def->objid,real_def->osnum */
/* START VDS CORRECTION */
        if( real_def->objid == NULL_OBJID ){
                return OM_W_ABORT;
        }
/* END   VDS CORRECTION */

   return(OM_S_SUCCESS);
}

method ACset_mac_name(char *file_name,*macro_name)
{
 IGRlong status;
/*
   store in my instance the macro definition name and the file name 
   where this macro is found
*/

  /*"set name to file %s macro %s\n",file_name,macro_name */
  status = om$vla_set_dimension(varray = me->total_name,
				size = strlen(file_name)+strlen(macro_name)+2);
  as$status(action = RET_STATUS);
  strcpy(me->total_name,file_name);
  strcat(me->total_name,",");
  strcat(me->total_name,macro_name);
  return(OM_S_SUCCESS);
}

method ACget_mac_name(char *file_name,*macro_name)
{
 IGRchar *separ,*strchr();
/*
    Return the name of the macro and the name of the file where this
    macro is located
*/
  separ  =  strchr(me->total_name,',');
  if(!separ) return OM_W_ABORT;
  *separ = '\0'; 
  strcpy(file_name,me->total_name);
  *separ = ',';
  strcpy(macro_name,separ+1);

  /*"get name returns %s %s\n",file_name,macro_name */

  return(OM_S_SUCCESS);
}

/* ========================================================================= */

method unknown (OM_S_MESSAGE *msg)
{
  /*^
  char classname1 [OM_K_MAXCLASS_LEN], classname2 [OM_K_MAXCLASS_LEN];
  int   status;
  IGRchar       name [80];

  om$get_classname( classid = msg->select.ReqClassid,
                    classname = classname2 );
  om$get_classname( classid = msg->select.DefClassid,
                    classname = classname1 );
  status = om$get_message_name ( classid = msg->select.ReqClassid,
                                 method_index = msg->select.FuncIndex,
                                 msg_name = name );

  printf ( "Unknown Message from %s to %s,%s\n",classname1, classname2,
                name);
  */

 return(0);

} /* end method unknown */


method ACreturn_symb_def(struct GRid *symb;GRspacenum osnum)
{
 struct GRid my_grid,real_grid;
 char file_name[OM_K_MAXOSNAME_LEN];
 char my_file[OM_K_MAXOSNAME_LEN];
 char macro_name[macro_MAX_CHAR];
 IGRlong status;
 IGRint invisible_index;
 

/*" return symbolic definition valid for myself in the OS %d\n", osnum */

my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;

/* I'm probably this definition */

if(osnum == OM_Gw_current_OS)
 {
  *symb = my_grid;  
  ACret_in_symbol(my_grid,&real_grid,1); /* to mark it used */
 }

/* I'm really in the macro library at the place of a deleted macro */

else
 {
  /* Is this definition already in the hcode table */
  ACret_in_real(my_grid,symb,1);


  if(IF_NULL_OBJID(symb->objid))
  {
    ACos_to_path(OM_Gw_current_OS,file_name,&invisible_index);
    if(file_name[0] == '\0')
      {
       status = om$os_number_to_name(osnum = OM_Gw_current_OS,
                                     osname = file_name);
       as$status();
      }
    status = om$construct(osnum = osnum,
                          p_objid = &symb->objid,
                          classid = OPP_ACtmp_defn_class_id);
    as$status();
    symb->osnum = osnum;
    status = om$send(msg = message ACtmp_defn.ACget_mac_name
						(my_file,macro_name),
		     targetid = my_id);
    as$status(action = RET_STATUS);
    status = om$send(msg = message ACtmp_defn.ACset_mac_name
                                                (file_name,macro_name),
                     targetos = symb->osnum,
                     targetid = symb->objid);
    as$status();
    ACadd_in_symbol(*symb,my_grid,1);
  }
 }


/*" %d %d return %d %d\n",my_id,OM_Gw_current_OS,symb->objid,symb->osnum */

return (OM_S_SUCCESS);
}




end implementation ACtmp_defn;
