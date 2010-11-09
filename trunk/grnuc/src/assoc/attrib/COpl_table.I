class implementation COtable;

#include "AS_status.h"
#include "exmacros.h"
#include <stdio.h>
#include "ACattrib.h"
#include <sys/types.h>
#include <sys/dirent.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMmacros.h"
#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include "nddef.h"
#include "madef.h"

#include "FI.h"

#define	TAB_MAX_VALUES	20

extern	IGRchar		*getenv();
extern	IGRchar		*strtok();	
extern	GRclassid	OPP_ACdyn_col_class_id;

from	NDnode		import	NDgive_structure;
from	ACdyn_col	import	ACcreate;
from	NDnode		import	NDplace;
from	NDnode		import	NDget_objects;
from	NDnode		import	NDs_compute_node;
from	ACrg_collect	import	ACset_list_attribute;
from	ACrg_collect	import	ACget_named_attribute;


method place_table()
{
IGRlong			sts, msg;
struct	GRid		DCOLT;
struct  GRas            as_list;
struct  ACcol_info      my_col_info;


	/*| create ACdyn_col */
	DCOLT.osnum	= me->ModuleInfo.md_id.osnum;
	sts = om$construct(	classid	= OPP_ACdyn_col_class_id,
				p_objid	= &DCOLT.objid,
				osnum	= DCOLT.osnum );
	as$status( sts = sts );

        sts = om$send(  msg      = message ACdyn_col.ACcreate
                                        ( &msg, me->hdr_name ),
                        targetid = DCOLT.objid,
                        targetos = DCOLT.osnum );
        as$status( sts = sts, msg = "Error in msg ACcreate" );

	/*| get list of attributes */
        as_list.num_parents     = 2;
        as_list.parents         = me->Temp_List;
        as_list.as_attr         = (IGRchar *) &my_col_info;

	strcpy( my_col_info.pl_fct_name, "" );
	strcpy( my_col_info.cp_fct_name, "table_updt" );

        sts = om$send(  msg      = message NDnode.NDplace(
                                        &as_list,
                                        &me->ModuleInfo,
                                        NULL ),
                        targetid = DCOLT.objid,
                        targetos = DCOLT.osnum );
        as$status( sts = sts );

return	sts;
}

#argsused
table_updt( rc, dcol, attr, md_env, count, list, state, context )

IGRlong			*rc;
struct	GRid		dcol;
struct	ACrg_coll	*attr;
struct	GRmd_env	*md_env;
IGRint			count;
struct	GRid		*list;
IGRint			*state;
struct	GRid		*context;
{
IGRlong			sts, msg;
IGRint			nb_par;
struct	ret_struct	temp_rts[2];
IGRint			ft_count;
IGRdouble		*ft_values;
IGRdouble		buf_val[TAB_MAX_VALUES];
IGRint			nb_att;
struct	ACrg_coll	*list_att;
IGRint			i;

	/*| initialization */
	list_att	= NULL;
	*rc		= ND_COMP_SUCC;
	ft_values	= buf_val;

	if( count != 2 )
		printf(" Warning : dyn col table may have two templates\n");

	sts = om$send(	msg	 = message NDnode.NDgive_structure(
					&msg,
					&temp_rts[0],
					md_env ),
			targetid = list[0].objid,
			targetos = list[0].osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

	sts = om$send(	msg	 = message NDnode.NDgive_structure(
					&msg,
					&temp_rts[1],
					md_env ),
			targetid = list[1].objid,
			targetos = list[1].osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

	ft_count	= TAB_MAX_VALUES;

	sts = VDpm_out( temp_rts[1].var.text_st.text_string, &temp_rts[0],
							&ft_count, ft_values);
	as$status( sts = sts );
	if( ft_count > TAB_MAX_VALUES ){

		ft_values = (IGRdouble *) malloc
					( ft_count * sizeof( IGRdouble ) );
		if( ft_values == NULL ){
			printf(" Error not enougth memory to allocate ft_values \n");
			sts = 0;
			as$status( sts = sts );
			ft_count  = TAB_MAX_VALUES;
			ft_values = buf_val;
		}

		sts = VDpm_out( temp_rts[1].var.text_st.text_string, 
					&temp_rts[0], &ft_count, ft_values);
	}

	list_att = (struct ACrg_coll*) malloc
			( ft_count * sizeof( struct ACrg_coll ) );
	if( list_att == NULL && ft_count != 0 ){

		printf(" Error not enough memory to allocate list_att \n");
		sts = 0;
		goto	wrapup;
	}

	for( i=0; i<ft_count; i++ ){

		/*" ft_values[%d] : %f\n", i, ft_values[i] */
		list_att[i].desc.value.att_exp	= ft_values[i];
		list_att[i].desc.type		= AC_ATTRIB_DOUBLE;
	}
	nb_att	= 0;
	sts = VD_get_att_name(	temp_rts[1].var.text_st.text_string,
				&temp_rts[0],
				ft_count,
				list_att,
				&nb_att );
	as$status( sts = sts );

/*^
	printf(" nb_att : %d\n", nb_att );
	for( i=0; i<nb_att; i++ ){

		printf(" list_att[%d].name : %s\n", i, list_att[i].name );
		printf(" type  : %x\n", list_att[i].desc.type );
		if( i )
		printf(" value : %f\n", list_att[i].desc.value.att_exp );
		else 
		printf(" value : %s\n", list_att[i].desc.value.att_txt );
	}
*/
	sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
					( &msg, nb_att, list_att ),
			targetid = dcol.objid,
			targetos = dcol.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

wrapup :

	if( list_att != NULL )		free( list_att );
	if( ft_values != buf_val )	free( ft_values );

return	OM_S_SUCCESS;
}

#argsused
VD_get_att_name( table_name, key, len_list, list_att, nb_att )

IGRchar			*table_name;
struct ret_struct 	*key;
int len_list;
IGRint			*nb_att;
struct	ACrg_coll	*list_att;
{
FILE	*pmfile	;
char	line[1+BUFSIZ],
	*ptr,
	*next; 
IGRint	rc;

	VDfind_file(table_name, &pmfile) ;
	if(pmfile == NULL) return OM_W_ABORT;

	/* Use 1st line to count feet */
	if( fgets( line, BUFSIZ, pmfile ) == NULL ){

		rc = FALSE;
		goto WRAPUP;
	}

	for( *nb_att=0, ptr=line, next= strtok( ptr, " \t\n" ); 
		next!=NULL; 
		ptr = NULL, (*nb_att) ++, next = strtok( ptr, " \t\n" ) )

			strcpy( list_att[*nb_att].name, next );

WRAPUP:
	fclose( pmfile ) ;

return	OM_S_SUCCESS;
}


VDpm_out(
  char              *table_name,
  int               *feet_count,
  struct ret_struct *key,
  double            *feet_values)
{

	FILE	*pmfile	;
	char	line[1+BUFSIZ],
		*previous_line,
		*ptr,
		*next, *token; 
	int	i, rc ;
	IGRlong sts ;
	double key_value;

        /* init */
	*feet_count = 0;

	/* Open the file */

	VDfind_file(table_name, &pmfile) ;
	if(pmfile == NULL) return OM_W_ABORT;

	/* Use 1st line to count feet */

	if( fgets( line, BUFSIZ, pmfile ) == NULL ) {
			rc = FALSE	;
			goto WRAPUP	;
			}

	ptr = line ;

	do {
	    next = strtok( ptr, " \t\n" ) ;
	    ptr = NULL ;
	    if( next != NULL )
	     { *feet_count = *feet_count + 1 ; }
	   } while( next != NULL ) ;

	/* Look for requested section name */

	previous_line = NULL;
	while(1)
	{
	 if( fgets( line, BUFSIZ, pmfile ) == NULL )
	  {
	    /* take last line for default */
	    if(previous_line == NULL)
	      {rc = FALSE ; goto WRAPUP ; }
	  }
	 else 
	  {
	   previous_line = line;
	   token = strtok(line, " \t\n") ;
	   if(key->type == double_type)
	    {
	     sts = sscanf(token,"%lf",&key_value);
	     if(!sts || key->var.root_pm_st.value > key_value+1.e-8) continue;
	    }
	   else if(key->type == text_type &&
	           strcmp(key->var.text_st.text_string,token)) continue;
	  }
	    
	  /* Read the line at the given key */

	  for(i=0;i<*feet_count;i=i+1)
	    {
	     token = strtok(NULL, " \t\n") ;
	     if (token == NULL) break;
	     sts = sscanf(token,"%lf",feet_values+i);
	     if(!sts) feet_values[i] = 0;
	    }

	  /* Default the rest to zeros */
	  for( ; i < *feet_count ; i = i + 1 ) { feet_values[i] = 0 ; }
	  rc = TRUE 	;
	  goto WRAPUP	;
	}

	WRAPUP:
	fclose( pmfile ) ;
	return OM_S_SUCCESS;

} /* pm_out() */

VDfind_file( table_name, pmfile )

char * table_name;		// table name
FILE ** pmfile	;		// output full unix file name
{
  char config[180],full_name[180];
  long status;
  int i;
  char *dirpath,*c,*c1,*strchr();
  
  *pmfile = NULL;

  /* search in current directory */

  sprintf(full_name,"%s.t",table_name);
  *pmfile = fopen(full_name,"r");
  if (*pmfile) return OM_S_SUCCESS;

  /* search in config/table directories */

  for(i=0;i<30;i=i+1)
   {
    status = ex$get_path(index = i,
			 path = config,
			 len = 180,
			 type = EX_CONFIG_PATH);
    if(!(status&1)) break;
    sprintf(full_name,"%s/config/table/%s.t",config,table_name);
    *pmfile = fopen(full_name,"r");
    if (*pmfile) return OM_S_SUCCESS;
   }

  /* search in path defined  by UNIX variable */

  dirpath = getenv("TABLE_PATH");
  if(dirpath == NULL) return OM_W_ABORT;
  c = dirpath;
  while(1)
   {
    c1 = strchr(c,':');
    if(c1) *c1='\0';
    sprintf(full_name,"%s/%s.t",c,table_name);
    if(c1) *c1=':';
    *pmfile = fopen(full_name,"r");
    if (*pmfile) return OM_S_SUCCESS;
    if(c1 == NULL) return OM_W_ABORT;
    c = c1+1;
   }
}

end implementation COtable;

