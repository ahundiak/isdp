/*   Functions for graph printer support.
     These function were before in COgraph_pti.I. It was then impossible
     to build system whitout copara.

CHANGE STORY
     jla  25-oct-87 : design date
		      add printer_print_parents
		      modify printer_print_symbology argument
     ch      jan-88 : Update for release 1.1
*/

class implementation ASnode;


#include "expression.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "macro.h"
#include "ci_macro.h"
#include "var.h"
#include "vardef.h"
#include "grsymdef.h"
#define AS_DEBUG

#define macro_MAX 		40

extern GRclassid OPP_NDnode_class_id,
		 OPP_ASnode_class_id,
		 OPP_ASsource_class_id;

from	ci_mac_def import	ACgive_cim_desc;
from	ACcpx	   import	find_macro;
from	GRsymbol   import	GRset_inq_symbol;

IGRdouble cos(), sin();
extern char *malloc();
extern char *realloc();

struct id_name {
  OM_S_OBJID id;
  char name[30];
};

IGRint max_tab;
IGRint current_suffix;
IGRint current_tab;
struct id_name *name_tab;
struct GRsymbology old_symb;
IGRshort  old_prop;
FILE *stream;
IGRchar min_dir[DI_PATH_MAX];

struct GRmd_env *printer_env;
/*
-----------------------------------------------------------------------
printer_init
initialize graph printer global data 
and print declaration in the ci file
-----------------------------------------------------------------------
*/
asprinter_init(md_env,str,is_it_a_macro)
struct GRmd_env *md_env;
FILE *str;
IGRint is_it_a_macro;
 {
    /* global info and table initialization */
    stream = str;
    current_suffix = 0;
    current_tab = 0;
    max_tab = 0;
    printer_env = md_env;

    /* symbology initialisation */
/*    old_symb.display_attr.rgb_value = 64000; no longer used  -PCW 06/10/91 */
    old_symb.display_attr.color     = 64000;
    old_symb.display_attr.weight    = 127;
    old_symb.display_attr.style     = 127;
    old_symb.level                  = -1;

    old_prop = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

    /* print declaration in the ci file */
    fprintf(stream,"#include \"cieveryone.h\"\n");
    fprintf(stream,"#include \"cisymb.h\"\n");
    fprintf(stream,"double  ptr[20];\n");
    fprintf(stream,"GRobj *obj[100];\n");
    fprintf(stream,"GRobj   list[100];\n");
    fprintf(stream,"int suc;\n");
    fprintf(stream,"short rc;\n");
    fprintf(stream,"GRobj dir_id;\n");
    fprintf(stream,"char  str[80];\n");
    fprintf(stream,"struct ret_struct rst[40];\n");
    fprintf(stream,"struct\n");
    fprintf(stream,"      {  char name[80];\n");
    fprintf(stream,"         double vz[3];\n");
    fprintf(stream,"       }  angl_attr;\n");
    fprintf(stream,"struct GRsymbology ACsymb;\n");
    fprintf(stream,"struct IGRestx ACtext_attr;\n");
    fprintf(stream,"char *symb_name;\n");


    /*| additionnal declaration for macro */
    if(is_it_a_macro)
       {
        fprintf(stream,"GRobj   TEMP[%d], FEET[%d];\n",
		macro_MAX,macro_MAX);
        fprintf(stream,"char *tstr[%d],*fstr[%d],*up[%d],*us[%d],*ds[%d];\n",
		macro_MAX,macro_MAX, macro_MAX,macro_MAX, macro_MAX);
        fprintf(stream,"int map[%d];\n",macro_MAX);
       /* fprintf(stream,"GRobj   MACHDR;\n"); */
       }
  return 1;
 }

/*
-----------------------------------------------------------------------
In the graph to print detect the precence of
- ci_macro
- cell and symbol
- ACcpx,ACpretend and expression removed 22-06-88 jla
print the necessary declaration
-----------------------------------------------------------------------
*/
as_printer_cimachdr(count,list,md_env,ci_macro_flag)
IGRint count;
struct GRid list[];
struct GRmd_env *md_env;
int *ci_macro_flag;
/*. as_printer_cimachdr */
{
  int			ci_mac_max_inter, body_nb,
			i, stat, status, assoc_count,
			temp_feet_num, intern_feet_num, extern_feet_num;
  struct GRid 		*extern_buffer, *list_assoc,as_prov;
  GRclassid 		obj_classid; 
  struct ci_mac_st 	*desc;
  extern GRclassid OPP_ci_macro_class_id;

  if(count == 0) return(OM_W_ABORT);
  list_assoc = (struct GRid *)malloc(count * sizeof(struct GRid));
  if(list_assoc == NULL) return(OM_W_ABORT);

/* initialisation */

  *ci_macro_flag = 0;
  ci_mac_max_inter = 1;
  asprinter_init_min_dir("");


/*
   separate  graphic root and associative ones
   Graphic roots are checked for sub class of cell
   Associative roots will be used to find the sub graph
*/

  for(assoc_count=0,i=0 ; i<count ; i++)
  {
    as$make_source( go_grid = list[i], as_grid = &as_prov,
		    as_os = md_env->md_id.objid, mod_env = md_env );
    if(as_prov.objid != NULL_OBJID)
      {
       list_assoc[assoc_count++] =  as_prov;
      }
  }
  

/* get the list of dependent elements */

  nd$get_graph(	p_root = list_assoc, 	nb_root = assoc_count);

  nd$get_list_in_graph(	acc_type = ND_BODY | ND_ROOT | ND_EXTERN,
			p_count  = &body_nb,
			buf_addr = &extern_buffer ); 
  
  for(i=0; i<body_nb; i++)
  {
    om$get_classid( 	osnum 		= extern_buffer[i].osnum, 
			objid 		= extern_buffer[i].objid,
			p_classid 	= &obj_classid );

/* Is it a ci_macro ? */

    if( om$is_ancestry_valid(	subclassid   = obj_classid,
			superclassid = OPP_ci_macro_class_id ) == OM_S_SUCCESS)
    {
    struct GRid mdef;
      /*^
         printf(" objid %d classid %d super classid %d\n",
		extern_buffer[i].objid, obj_classid,OPP_ci_macro_class_id);
      */
      *ci_macro_flag = 1;
      
      stat = om$send( msg = message ACcpx.find_macro( &mdef),
		      senderid 	= NULL_OBJID,
		      targetid 	= extern_buffer[i].objid,
		      targetos  = extern_buffer[i].osnum);
      as$status ( sts = stat, action = RET_STATUS );
      stat = om$send( msg = message ci_mac_def.ACgive_cim_desc 
				( &status, &desc,
			&temp_feet_num, &intern_feet_num, &extern_feet_num),
		      senderid 	= NULL_OBJID,
		      targetid 	= mdef.objid,
		      targetos  = mdef.osnum);
      as$status ( sts = stat, action = RET_STATUS );
      if (desc->int_size > ci_mac_max_inter) 
	ci_mac_max_inter = desc->int_size;
    }

/* seach minimal directory */

    asprinter_find_min_dir(extern_buffer[i]);

  }               /* loop on body element */


/* print ci macro declaration */

  if(*ci_macro_flag == 1)
    fprintf(stream,"int ci_mac_inter[%d];\n", ((ci_mac_max_inter / 4)+ 1) );


/* free array */

  if((list_assoc)&&(count)) free(list_assoc);
  return 1;
}
   

/*
-----------------------------------------------------------------------
printer_end
end a graph printer 
-----------------------------------------------------------------------
*/

asprinter_end()
  {
   fprintf(stream,"}\n");
   if(max_tab>0) free(name_tab);
   return 1;
  }

/*
-----------------------------------------------------------------------
asprinter_exec_print
print the sub graph  defined by the count object contained in list
-----------------------------------------------------------------------
*/
#undef AS_DEBUG
asprinter_exec_print(count,list)
IGRint count;
struct GRid list[];
/*.asprinter_exec_print */
{
  struct GRid *entry_tab;
  IGRint i,size,assoc_count;
  struct GRid as_prov;
  IGRint status;
  IGRint ci_macro_flag;

#define AS_DEBUG
  size = (count+1)*sizeof(struct GRid);
  entry_tab = (struct GRid *)om$malloc(size = size);
  if(entry_tab == NULL) return(OM_W_ABORT);

  as_printer_cimachdr(count,list,printer_env,&ci_macro_flag);

#undef AS_DEBUG
  fprintf(stream,"\n\nmain() {\n");
  /* } for AS_DEBUG .... */
#define AS_DEBUG

  /* print the entry point as root node */

  for(assoc_count=0,i=0 ; i<count ; i++)
  {
    as$make_source( go_grid = list[i], as_grid = &as_prov,
		    as_os = printer_env->md_id.objid, mod_env = printer_env );
    if(as_prov.objid != NULL_OBJID)
      {
       /*" print_root message of %d %d\n",as_prov.objid,as_prov.osnum */
       entry_tab[assoc_count++] = as_prov;
       status = om$send(msg = message NDnode.NDprint_root(printer_env,stream),
               senderid = NULL_OBJID, targetid = as_prov.objid,
               targetos = as_prov.osnum);
       as$status();
      }
  }

  /*| print the sub graph */
  /*" nb_root %d premier %d\n", assoc_count, entry_tab[0].objid */

    if(assoc_count > 0)
      {
       status=nd$get_graph(p_root = entry_tab, nb_root = assoc_count);
       as$status();
       status=nd$broadcast_graph(p_msg = message NDnode.NDprint(printer_env,stream),
			   acc_type = ND_BODY,
			   rej_type = ND_ROOT);
       as$status();
      }
  om$dealloc(ptr = entry_tab);
  return(1);
#undef AS_DEBUG
} /* exec_print */


#define AS_DEBUG
/*
-----------------------------------------------------------------------
  asprinter_store_name
  Store the name and the object_id of an object
-----------------------------------------------------------------------
*/

asprinter_store_name(object_id,name)
OM_S_OBJID object_id;
char *name;
/*.asprinter_store_name*/
{

/* first malloc for name_tab */

  if( current_tab == 0 )
   {
    name_tab = ( struct id_name * ) malloc( 25 * sizeof( struct id_name ) );  
    if( name_tab == 0 )
      {
       printf("error malloc in asprinter_store_name\n");
       return(0);
      }
    max_tab = 25;  
   }

/* realloc if size is no enought */

  if( current_tab >= max_tab )
   {
    name_tab = (struct id_name * ) realloc( name_tab,
                                   ((max_tab + 25) * sizeof(struct id_name)));  
    if( name_tab == 0 )
      {
       printf("error realloc in asprinter_store_name\n");
       return(0);
      }
    max_tab += 25;
   }

/* store the name */

  strcpy(name_tab[current_tab].name,name);
  name_tab[current_tab].id = object_id;
  current_tab++;
  return(1);
}
/*
-----------------------------------------------------------------------
  asprinter_find_name
  try to find the object_id object in the stored name.
   If success return the name
   If not return a null string
-----------------------------------------------------------------------
*/

asprinter_find_name(object_id,name)
OM_S_OBJID object_id;
char *name;
/*.asprinter_find_name*/
{
  IGRint i;

  for( i = 0; i < current_tab; i++ )
   {
    if( IF_EQ_OBJID( name_tab[i].id, object_id ))
     {
      strcpy( name, name_tab[i].name );      
      return(1);
     } 
   }
  strcpy( name, "" );
  return(1);
}

/*
-----------------------------------------------------------------------
  asprinter_set_name
   Create a name associated to the object_id object and return this name
   in *name . This name begins with the prefix given as argument.
   If the name can't be created because a name is already associated to 
   obect_id , return null string. (This test is skipped if
   object_id = NULL_OBJID)
-----------------------------------------------------------------------
*/

asprinter_set_name(object_id,prefix,name)
OM_S_OBJID object_id;
char *prefix;
char *name;
/*.asprinter_set_name*/
{
  char suffix[6];
  char find_name[20];
  if(!IF_EQ_OBJID(object_id,NULL_OBJID))
    {
     strcpy( name , "" );
     asprinter_find_name( object_id, find_name );
     if( strcmp( find_name, "" )) return(1);
    }

  sprintf(suffix,"%d",current_suffix);
  strcpy(name,prefix);
  strcat(name,suffix);
  asprinter_store_name(object_id,name);
  current_suffix++;
  return(1);
}

/*
-----------------------------------------------------------------------
  asprinter_get_name
-----------------------------------------------------------------------
*/
asprinter_get_name(parent_id,name)
OM_S_OBJID parent_id;
char *name;
/*.asprinter_get_name*/
{
    asprinter_find_name( parent_id, name );
    if(strcmp( name, "" )) return(1);
    om$send(msg = message NDnode.NDprint_root(printer_env,stream),
	    senderid = NULL_OBJID,
	    targetid = parent_id);

    asprinter_find_name(parent_id,name);
    if(!strcmp( name, "" )) strcpy(name,"XXXXXX");
    return(1);
}

/*
-----------------------------------------------------------------------
  asprinter_print_root
-----------------------------------------------------------------------
*/



asprinter_print_root(objid,osnum,flag)
OM_S_OBJID objid;
GRspacenum osnum;
IGRint flag;
/*.asprinter_print_root*/
  {
  IGRchar ref_name[80],name[80];
  struct ret_struct  obj_struct;
  IGRint father;
  IGRint num_par;
  IGRlong msg,status;
  int  index;
  GRclassid obj_classid,contents_classid;
  extern GRclassid OPP_GRclhdr_class_id,OPP_GRsmhdr_class_id,
		   OPP_AScontents_class_id;

  struct GRid root_GRid, go_GRid;
  IGRshort cmp_matrix_type;
  IGRmatrix cmp_matrix;
  struct IGRlbsys lb;
  
  /* if NDnode subclass get the go */

  root_GRid.objid = objid;
  root_GRid.osnum = osnum;

  status = om$send(msg = message NDnode.ASreturn_go(&go_GRid,&cmp_matrix_type,
					    cmp_matrix),
		   senderid = NULL_OBJID,
	           targetid = objid,
		   targetos = osnum);
  if(!(status&1)){go_GRid.objid=objid;go_GRid.osnum=osnum;}
					
  msg = om$get_classid( osnum = go_GRid.osnum, 
    			     objid = go_GRid.objid,
			     p_classid = &obj_classid );

  /*| Ask for the definition of the object */

     msg=ASany_give_struct(go_GRid.objid,go_GRid.osnum,printer_env,&obj_struct);
     if(!(msg&1))
      {
      UI_status("Doesn't know how to print this object");
      return(1);
      }


  /* get its name and return if already printed */

  if(obj_struct.type & line_generic)
				asprinter_set_name(objid,"ROOT_LINE",name);
  else if( obj_struct.type & point_generic )
    				asprinter_set_name(objid,"ROOT_POINT",name);
  else if( obj_struct.type == arc_type )
    				asprinter_set_name(objid,"ROOT_ARC",name);
  else if( obj_struct.type & conic_generic )
    				asprinter_set_name(objid,"ROOT_CIRCLE",name);
  else if(obj_struct.type & parameter_generic)
    				asprinter_set_name(objid,"PM",name);
  else if( obj_struct.type & ref_generic )
    				asprinter_set_name(objid,"ROOT_REF",name);
  else if( om$is_ancestry_valid(subclassid = obj_classid,
                         superclassid = OPP_GRclhdr_class_id ) == OM_S_SUCCESS )
  {
    				asprinter_set_name(objid,"ROOT_CELL",name );
  }
  else if( om$is_ancestry_valid(subclassid = obj_classid,
                        superclassid = OPP_GRsmhdr_class_id ) == OM_S_SUCCESS )
  {
     				asprinter_set_name(objid,"ROOT_SYMBOL",name );
  }
  else
  {
        asprinter_set_name(objid,"XXXXXX",name);
	fprintf(stream,"%s print not implemented\n",name);
	return(1);
  }
  /*"name of obj to print %s\n",name */

  if(strcmp(name,"")==0) return(1);

  num_par = 0;
  if(flag & AS_PR_WITH_REF) 
    { 
     struct GRid ref, contents;

     /*"coord system the object %d --> %d depends on\n",objid,go_GRid.objid */

     /*| sub class of source */
     contents.objid = NULL_OBJID;
     status = om$send ( msg = message NDnode.NDget_objects
			       (ND_ROOT,&contents,1,NULL,0,OM_K_MAXINT,&father),
			senderid = NULL_OBJID,
                 	targetid = objid,
			targetos = osnum );
     as$status();

     if(!IF_NULL_OBJID( contents.objid ))
       {
	om$get_classid(objid = contents.objid, osnum = contents.osnum,
		       p_classid = &contents_classid);
	if(om$is_ancestry_valid( superclassid = OPP_AScontents_class_id,
				subclassid = contents_classid) == OM_S_SUCCESS)
         {
          /*| The object depends on a coordinate system */

          status = om$send ( msg = message NDnode.NDget_objects
			            (ND_ROOT,&ref,1,NULL,0,OM_K_MAXINT,&father),
			     senderid = NULL_OBJID,
                 	     targetid = contents.objid,
			     targetos = contents.osnum );
	  as$status(action = RET_STATUS);
		
          if(father == 1)
           {
            /*" One root: %d, %d\n", ref.objid, ref.osnum */
            asprinter_get_name( ref.objid, ref_name);
    	    fprintf(stream,"list[0]=%s;\n",ref_name);
	    num_par = 1;
           }
          else
           {
            /*| Erreur in asprinter_print_root */
           }
	 }
      }
    }

 /*| Print the symbology */

  asprinter_print_symb(NULL, NULL, objid, osnum);

  /* Print the different possible types of geometry */
  /* specifique information and message             */
/*|apres print symb */


  /*****************************/
  /*  Print the SRC LINE type  */
  /*****************************/

  if(obj_struct.type & line_generic) 
    {
    for (index=0; index<3 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",index,obj_struct.var.line_st.p0[index]);
    for (index=0; index<3 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",index+3,obj_struct.var.line_st.p1[index]);

      fprintf(stream,"send ASsrcline.place(%d,list,ptr) to %s;\n\n",
	      num_par, name);
    }
    

  /******************************/
  /*  Print the SRC POINT type  */
  /******************************/

  else if( obj_struct.type & point_generic )
   {
    for (index=0; index<3 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",index,obj_struct.var.point_st.pt[index]);

      fprintf(stream,"send ASsrcpoint.place(%d,list,ptr) to %s;\n\n",
		num_par,name);
  }

   
  /****************************/
  /*  Print the ROOT ARC type */
  /****************************/

  else if( obj_struct.type == arc_type )
   {
    IGRshort trois = 3, un = 1;
    IGRdouble pt1[3], pt2[3], teta, rad, mat[9], start_p[3], sweep_p[3], v[3];
    IGRboolean mat4_3(), MAmulmx(), MAaddvc();

    
    /*| compute the start and sweep point of the arc */
   
    teta = obj_struct.var.circle_st.start_angle;
    rad = obj_struct.var.circle_st.rad;
    pt1[0] = rad * cos(teta); pt1[1] = rad * sin(teta); pt1[2] = 0;
    teta = obj_struct.var.circle_st.sweep_angle;    
    pt2[0] = rad * cos(teta); pt2[1] = rad * sin(teta); pt2[2] = 0;

    mat4_3( obj_struct.var.circle_st.mat, mat );
    MAmulmx( &msg, &trois, &trois, &un, mat, pt1, v );
    MAaddvc( &msg, v, obj_struct.var.circle_st.cent_p, start_p );  
    MAmulmx( &msg, &trois, &trois, &un, mat, pt2, v );
    MAaddvc( &msg, v, obj_struct.var.circle_st.cent_p, sweep_p );  

    /*| Print the instances */
    
    for (index=0; index<3 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",
	      index,obj_struct.var.circle_st.cent_p[index]);
    for (index=0; index<3 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",index+3,start_p[index]);
    for (index=0; index<3 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",index+6,sweep_p[index]);

    fprintf(stream,"ptr[10]=%lf;\n",obj_struct.var.circle_st.mat[2]);
    fprintf(stream,"ptr[11]=%lf;\n",obj_struct.var.circle_st.mat[6]);
    fprintf(stream,"ptr[12]=%lf;\n",obj_struct.var.circle_st.mat[10]);

    fprintf(stream,"ptr[9]=%lf;\n",obj_struct.var.circle_st.rad);

    /*| Print the message */

      fprintf(stream,"send ASsrcarc.place(%d,list,ptr) to %s;\n\n",
	      num_par,name);
 }


  /*******************************/
  /*  Print the ROOT CIRCLE type */
  /*******************************/

  else if( obj_struct.type & conic_generic )
   {
    fprintf(stream,"ptr[9]=%lf;\n",obj_struct.var.circle_st.rad);
    for (index=0; index<3 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",
	      index,obj_struct.var.circle_st.cent_p[index]);

    fprintf(stream,"ptr[10]=%lf;\n",obj_struct.var.circle_st.mat[2]);
    fprintf(stream,"ptr[11]=%lf;\n",obj_struct.var.circle_st.mat[6]);
    fprintf(stream,"ptr[12]=%lf;\n",obj_struct.var.circle_st.mat[10]);

    /*| Print the message */

    fprintf(stream,"send ASsrccircle.place(%d,list,ptr) to %s;\n\n",
	    num_par,name);
 }


  /*****************************/
  /*  Print the PARAMETER type */
  /*****************************/

  else if(obj_struct.type & parameter_generic)
   {
    char param_name[EXP_MAX_LEN];
    IGRint rc;

    rc = di$untranslate ( objid = objid, objname = param_name );
    fprintf(stream,"send expression.place(\"%s\",\"%lf\") to %s;\n\n",
    param_name, obj_struct.var.root_pm_st.value,name);

   }

  /*******************************/
  /*  Print the ROOT REF type    */
  /*******************************/

  else if( obj_struct.type & ref_generic )
   {
    for (index=0; index<16 ; index++)
      fprintf(stream,"ptr[%d]=%lf;\n",index,obj_struct.var.ref_st.t[index]);

      fprintf(stream,"send ASsrcref.place(%d,list,ptr) to %s;\n\n",
	      num_par,name);
   }


   /*******************************/
   /*  Print the ROOT SYMBOL type */
   /*******************************/


   else
    { /*"avant test obj_class %d\n",obj_classid */
      /*"avant test OPP_GRsmhdr_class_id %d\n",OPP_GRsmhdr_class_id  */
    
      if( om$is_ancestry_valid(subclassid = obj_classid,
                      superclassid = OPP_GRsmhdr_class_id ) == OM_S_SUCCESS 
        ||om$is_ancestry_valid(subclassid = obj_classid,
                      superclassid = OPP_GRclhdr_class_id ) == OM_S_SUCCESS  )
    {
    struct GRvar_list	var_list[2];
    char name1[16];
    char name2[16];
    long nbbyte1,nbbyte2;

    /*| on recupere le symbol name */

   var_list[0].var = GR_SYMBOL_NAME;
   var_list[0].var_ptr = name1;
   var_list[0].num_bytes = 16;
   var_list[0].bytes_returned = &nbbyte1;

   var_list[1].var = END_PARAM;
   var_list[1].var_ptr = name2;
   var_list[1].num_bytes = 16;
   var_list[1].bytes_returned = &nbbyte2;

/*| avant  set_inq_symbol */

   if( om$is_ancestry_valid(subclassid = obj_classid,
                      superclassid = OPP_GRsmhdr_class_id ) == OM_S_SUCCESS )
     {
      status = om$send(  msg = message GRsymbol.GRset_inq_symbol(
                     	&msg,
			0,
			var_list ),
		senderid = go_GRid.objid,
		targetos = go_GRid.osnum,
		p_chanselect = &AS_to_comp);
     }
   else
     {
      status = om$send(  msg = message GRsymbol.GRset_inq_symbol(
                     	&msg,
			0,
			var_list ),
		senderid = NULL_OBJID,
		targetos = go_GRid.osnum,
		targetid = go_GRid.objid);
     }

    as$status(action = RET_STATUS);

/*| apres set_inq */

/*"symbol name %s\n",name1 */
    status = om$send(msg = message GRvg.GRgetgeom(&msg, 
		                           &(printer_env->md_env.matrix_type),
	                                   printer_env->md_env.matrix,
					   (char *) &lb),
		     senderid = NULL_OBJID,
                     targetid = go_GRid.objid,
                     targetos = go_GRid.osnum);

    as$status(action = RET_STATUS);

/*| apres get_matrix */
    for(index=0;index<16;index++)
	 fprintf(stream,"ptr[%d] = %lf;\n",index,lb.matrix[index]);
    fprintf(stream,"symb_name = (IGRchar *) &ptr[16];\n");
    fprintf(stream,"strcpy(symb_name,\"%s\");\n",name1);
   if( om$is_ancestry_valid(subclassid = obj_classid,
                      superclassid = OPP_GRsmhdr_class_id ) == OM_S_SUCCESS )
       {
        fprintf(stream,"send GRsmhdr.place(%d,list,ptr) to %s;\n\n",
	        num_par,name);
       }
   else
       {
        fprintf(stream,"send GRclhdr.place(%d,list,ptr) to %s;\n\n",
	        num_par,name);
       }
   }
  else
   {
     fprintf(stream,"%s  error  in print\n",name);
     return(1);
   }
  }
  return 1;
 }/* end asprinter_print_root */
   
/*
-----------------------------------------------------------------------
     This routine is used with the graph_printer and list the symbology 
   when it changes of state.
-----------------------------------------------------------------------
*/


asprinter_print_symb(symb, prop, objid, osnum)

struct GRsymbology *symb;
IGRshort *prop;
OM_S_OBJID objid;
GRspacenum osnum;
/*.asprinter_print_symb*/
{
 struct GRsymbology loc_symb;
 short loc_prop;
 long msg;
 IGRint modif;
 struct GRid obj, dummy, other;

/* symboly pass in argument call or defined by object */

  if(!IF_NULL_OBJID(objid))
    {
     GRclassid obj_class,dummy_class;
     /* ch Nov 14. To do the goog thing for partial delete and extend */
     om$get_classid( osnum = osnum,objid = objid,
		     p_classid = &obj_class);
     if (om$is_ancestry_valid(subclassid = obj_class,
	 		      superclassid = OPP_NDnode_class_id)==OM_S_SUCCESS)
      {
       IGRchar user_state;
       user_state = 0;
       om$send( msg = message NDnode.NDget_state(&user_state),
	        senderid = NULL_OBJID, targetid = objid, targetos = osnum);

       if( user_state & ND_DIS_BY_CH )
        {
         obj.objid = objid;
         obj.osnum = osnum;
         other.objid = NULL_OBJID;
         other.osnum = osnum;
         ASfind_modifier(obj, other, &dummy);
         if(IF_NULL_OBJID( dummy.objid ))
	  {
	   /* if something wrong */
	   dummy.objid = objid;
           dummy.osnum = osnum;
	  }
        }
       else /* If not extend or partial delete */
        {
         dummy.objid = objid;
         dummy.osnum = osnum;
        }
      }
     else /* If not class node */
      {
       /* not assoc */
       dummy.objid = objid;
       dummy.osnum = osnum;
      }
      
     om$send(msg = message GRvg.GRgetsymb(&msg,&loc_symb),
 	     senderid = NULL_OBJID,
	     targetid = dummy.objid,
	     targetos = dummy.osnum);

     om$get_classid( osnum = dummy.osnum,objid = dummy.objid,
		     p_classid = &dummy_class);
     if(om$is_ancestry_valid(subclassid = obj_class,
	 		      superclassid = OPP_ASnode_class_id) == OM_S_SUCCESS)
       {
        om$send(msg = message GRvg.GRgetprops(&msg,&loc_prop),
	     senderid = dummy.objid,
	     targetos = dummy.osnum,
	     p_chanselect = &AS_to_comp);
       }
     else
       {
        om$send(msg = message GRvg.GRgetprops(&msg,&loc_prop),
	     senderid = NULL_OBJID,
	     targetid = dummy.objid,
	     targetos = dummy.osnum);
       }

     symb = &loc_symb;
     prop = &loc_prop;
    }

  modif = 0;

  if( symb->display_attr.color != old_symb.display_attr.color ) 
   {
    fprintf(stream, "cnst_list.color = %d;\n", symb->display_attr.color );     
    old_symb.display_attr.color = symb->display_attr.color;
    modif = 1;
   }
  if( symb->display_attr.weight != old_symb.display_attr.weight )
   {
   fprintf(stream, "cnst_list.weight = %d ;\n", symb->display_attr.weight );
   old_symb.display_attr.weight = symb->display_attr.weight;
   modif = 1;
   }
  if( symb->display_attr.style != old_symb.display_attr.style)
   {
    fprintf(stream, "cnst_list.style = %d;\n", symb->display_attr.style);
    old_symb.display_attr.style = symb->display_attr.style;
    modif = 1;
   }
  if( symb->level != old_symb.level )
   {
   fprintf(stream, "cnst_list.level = %d;\n", symb->level );
   old_symb.level = symb->level;
   modif = 1;
   }
  if((*prop&GRIS_DISPLAYABLE) != (old_prop&GRIS_DISPLAYABLE))
   {
    fprintf(stream, "cnst_list.displayable = %d;\n",
 	    (*prop&GRIS_DISPLAYABLE) == GRIS_DISPLAYABLE );
    old_prop = old_prop & ~GRIS_DISPLAYABLE | *prop &  GRIS_DISPLAYABLE ;
    modif = 1;
   }
  if((*prop&GRIS_LOCATABLE) != (old_prop&GRIS_LOCATABLE))
   {
    fprintf(stream, "cnst_list.locatable = %d;\n",
	   (*prop&GRIS_LOCATABLE) == GRIS_LOCATABLE );
    old_prop = old_prop & ~GRIS_LOCATABLE | *prop &  GRIS_LOCATABLE ;
    modif = 1;
   }

  if(modif) fprintf(stream, "set_symb();\n");
  return(1);
}


/*
-----------------------------------------------------------------------
Print the list of parents of an associative object  
and return the number of parents in nb_parent
-----------------------------------------------------------------------
*/
#define MAX_PARENTS 10                     /* Number maximum of parents       */
#define MAX_CHAR    80                     /* Number maximum of char for name */

asprinter_print_parents(objid,osnum,root,root_size,nb_parent)
OM_S_OBJID objid;
GRspacenum osnum;
struct GRid *root;
IGRint root_size;
IGRint *nb_parent;
/*.asprinter_print_parents*/
 {

  IGRint count,icount;               /* Number of parents               */
  struct GRid _list[MAX_PARENTS],    /* List of the parents objid     */
	 *list,*buf;
  IGRlong status;                    /* Returned message from om        */
  char _par_name[MAX_PARENTS*MAX_CHAR],*par_name,*c;   /* parents names       */


/* Get parent list */
    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
							NULL,0,&buf,
							0,OM_K_MAXINT,&count),
		     senderid = NULL_OBJID,
             	     targetid = objid,
		     targetos = osnum);

    if(count <= MAX_PARENTS)
     {
      list = _list;
      par_name = _par_name;
     }
    else
     {
      list = (struct GRid *) om$malloc(size = count*sizeof(struct GRid));
      par_name = (char *) om$malloc(size = count*MAX_CHAR);
      if(!list || !par_name) return OM_W_ABORT;
     }

    for (icount=0 ; icount<count ; icount++) list[icount]= buf[icount];


/* Get parent name */

    c = par_name;
    for (icount=0 ; icount<count ; icount++,c += MAX_CHAR)
      asprinter_get_name(list[icount].objid,c);

/* Print parent name */

    c = par_name;
    for (icount=0; icount<count ; icount++, c += MAX_CHAR)
      fprintf(stream,"list[%d]=%s;\n",icount,c);

/* return optionnal information */

    if(nb_parent != NULL) *nb_parent = count;

    if(root != NULL)
    for(icount = 0; icount<count && icount<root_size; icount++)
       { root[icount].objid = list[icount].objid;
         root[icount].osnum = list[icount].osnum;}

/* dealloc when necessary */

    if(count > MAX_PARENTS)
      {
       om$dealloc(ptr = list);
       om$dealloc(ptr = par_name);
      }
   return 1;
  }

/*
-----------------------------------------------------------------------
   This function returns the length of string s1 corresponding to string 
   s2. If s1 is shortest than s2 returns -1.
-----------------------------------------------------------------------
*/

asstrcmp(s1,s2)
char *s1,*s2;
{
 int i;
 char c1,c2;

 for(i=0;;i++)
   {
    c1=s1[i];
    c2=s2[i];
    if(c1 != c2) break;
    if(c2 == '\0') {break;}
    if(c1 == '\0') {i = -1; break;}
   }
 return(i);
}


/*
-----------------------------------------------------------------------
   Initialize min dir name 
-----------------------------------------------------------------------
 */

asprinter_init_min_dir(name)
char *name;
/*.asprinter_init_min_dir*/
{
strcpy(min_dir,name);
return 1;
}
 
/*
-----------------------------------------------------------------------
   function used to find the minimal directory commun to the entities to 
   print 
-----------------------------------------------------------------------
 */

 asprinter_find_min_dir(obj)
 struct GRid obj;
/*.asprinter_find_min_dir*/
 {
  IGRlong rc;
  IGRchar loc_name[DI_PATH_MAX];
  IGRint min_len;
  char *posit;
  char *strrchr();

/* name of the object */

/*"obj %d %d\n",obj.objid,obj.osnum */
  rc = di$untranslate(  objid = obj.objid,
			osnum = obj.osnum,
                      objname = loc_name);


  /*" expression name %s\n",loc_name */



 if( rc == DIR_S_SUCCESS )
 {
  /* corresponding name of directory */
  posit = strrchr(loc_name,':');
  if(posit == NULL) return (OM_S_SUCCESS);
  *posit = '\0';

  /*" name %s\n",loc_name */

  /* search minimal dir */
 
  if(min_dir[0] == '\0')
   {
    /*| init min dir */
    strcpy(min_dir,loc_name);
   }
  else
   {
    min_len = asstrcmp(min_dir,loc_name);
    /*"min_len %d\n",min_len */
    if(min_len != -1)  min_dir[min_len] = '\0';
   }
  /*" min_dir %s\n",min_dir */
  }
 else if(rc != DIR_W_NAME_NOT_FOUND )
  {
    /*^ di$report_error(sts = rc); */
  }
 return (OM_S_SUCCESS);
}
   
/*
-----------------------------------------------------------------------
   Routine used to get the name of an entity
   This name is relative to the min dir obtained.
-----------------------------------------------------------------------
*/

 asprinter_get_di_name(obj,name)
 struct GRid obj;
 char *name;
/*.asprinter_get_di_name*/
 {
  IGRlong rc;
  IGRchar loc_name[DI_PATH_MAX];
  IGRint min_len;

/* name of the object */

/*"obj %d %d\n",obj.objid,obj.osnum */
  rc = di$untranslate(  objid = obj.objid,
			osnum = obj.osnum,
                      objname = loc_name);
/*"rc %d\n",rc */

 if(( rc != DIR_S_SUCCESS ))
  { /*^ di$report_error(sts = rc); */
    name[0]='\0';
    return (OM_S_SUCCESS);
  }

/* take out min_dir name */

   {
    min_len = asstrcmp(loc_name,min_dir);
    /*"min_len %d\n",min_len */
    if(loc_name[min_len] == ':') min_len = min_len + 1;
    strcpy(name,&loc_name[min_len]);
   }
  /*" returned name%s\n",name */
 
 return(OM_S_SUCCESS);
}

/*
-----------------------------------------------------------------------
   routine used to print the directory regeneration used by the expression
   name
   modify jla 20-dec-88 : directory regeneration is done by ciplace.
-----------------------------------------------------------------------
 */

#argsused
asprinter_print_dir(name_init)
char *name_init;
/*.asprinter_print_dir*/
{
 return(1);
}
end implementation ASnode;
