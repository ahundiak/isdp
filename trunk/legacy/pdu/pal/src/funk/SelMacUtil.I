class implementation expression ;
#include "expmacros.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "nddef.h"
#include "MOmacros.h"

/*extern  DIint DIuntranslate();*/

#define DEBUG 0
from ACcpx import ACfind_exp_temp_obj    ;
from ACcpx import ACfind_exp_temp_struct ;
from ACpretend import ACgive_downscan    ;

static int sts ;
static long msg ;

change_text_to_index(num_stat,temp_val,sel_grid, num_exp_objs,md_env)
char *temp_val[] ;
struct GRid sel_grid[] ;
int num_stat, *num_exp_objs  ;
struct GRmd_env *md_env ;
{

     int ind , i, j , k=0,sts , str_len;
     char *arry[30],*arry_tmp[30], indx[10] ;
     GRobjid tmp_objid ;
     struct  GRid tgrid ;

     _pdm_debug("Inside change_text_to_index() ",0);
     ind = 0 ;

     for( i= 0 ; i < 30 ; i = i + 1 )
           arry_tmp[i] = NULL ;

     for( i = 0 ; i < num_stat ; i = i + 1 ) {


          _pdm_debug("temp_val: %s", temp_val[i]);

	  if( !strcmp(temp_val[i],"=,0"))
		continue ;

          parse_expr(temp_val[i],&ind,arry);

if (DEBUG)
	  printf("no. of exps in temp_val[i]: %d\n", ind);

          k = 0 ;
          for( j = 0 ; j < ind ; j = j + 1 ) {

	       _pdm_debug("exp name: %s", arry[j]);

               sts = exp$translate( exp_name = arry[j] , p_exp_id = &tmp_objid );

               if ( sts & 1 ) {

                       if(arry_tmp[k] == NULL ){
                            str_len = strlen(arry[j]);
                            str_len = str_len + 2 ;
                            arry_tmp[k]= (char *)malloc((unsigned)str_len) ;

                            tgrid.objid = tmp_objid ;
                            tgrid.osnum = md_env -> md_id.osnum ;
                            
                            as$make_source(go_grid = tgrid,
                                           as_os = tgrid.osnum,
                                           as_grid = &sel_grid[k]);
 
if ( DEBUG )
			    printf("exp id & name :%d %s %d\n", 
				sel_grid[k].objid, arry[j],
                                               num_stat+k );

                       }

                       if( arry_tmp[k] == NULL ) 
                           printf("arry_tmp[k] is NULL !!!\n");

                       strcpy(arry_tmp[k],arry[j]);

if ( DEBUG )
                       printf("arry_tmp[ %d] = %s , i = %d\n", k,arry_tmp[k], i);


                       k = k + 1 ;
               }
          }
      
          for( j = 0 ; j < k ; j = j + 1 ) {

              
               sprintf(indx,"\\%d",num_stat + j );


if ( DEBUG )
               printf("arry_tmp[j]:%s  indx:%s, temp_val[i]:%s ",
                         arry_tmp[j], indx, temp_val[i],"\n");


               EXPsubstitute(arry_tmp[j],indx,temp_val[i]);


               _pdm_debug("after debug the temp:%s ", temp_val[i]);

          }
     }

     *num_exp_objs = k ;

     for( i = 0 ; i < 30 ; i = i + 1 ) 
       if( arry_tmp[i] ) free ( arry_tmp[i] );

     free_ptrs();

     return(1);
}

#define MAX_TEMP 45 
extern ACname_template();
extern OMuword OPP_ACpretend_class_id ;
extern OMuword OPP_text_exp_class_id ;

change_index_to_text(temp_val,num_stat,num_exps,grid,md_env)
struct GRid     grid    ;  
struct GRmd_env *md_env ;  // this routine changes index nos in
char   *temp_val[]      ;  // criteria back to exp names
int    num_stat         ;
int    num_exps         ;
{

	int i, k , j , is_pretend ,cnt;
	char *arry[MAX_TEMP], indx[10], downscan[10];
	struct GRid tmpid ;
	OMuword obj_class ;
	struct ret_struct ret_st ;
	IGRshort mat_type ;
	IGRmatrix tmat ; 

	/* get all expression templates of grid */

	_pdm_debug("Entered:change_index_to_text",0);

	_pdm_debug("osnum:%d ", grid.osnum);

	k = 0 ;
	for( i = num_stat ; i < num_stat+num_exps ; i = i + 1 ) {  

        	if( grid.osnum == 2 ) {
	     		sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, &tmpid, 1,
						    NULL,i,i, &cnt),
                        	      senderid = grid.objid,
	                              targetid = grid.objid,
        	                      targetos = grid.osnum );
     			_MO_omerr_chk("change_index () : NDnode.NDgetobjects ",  sts,  wrapup);
			_pdm_debug("1.temid:%d  ", tmpid.objid);
		}
      
		else {
			downscan[0] = '\0' ;
			ACindex_template(&grid,i,downscan,&tmpid);
			_pdm_debug("temid:%d  ", tmpid.objid);
		}

		sts = om$get_classid(objid = tmpid.objid,
   					osnum = tmpid.osnum,
					p_classid = &obj_class);

		_MO_omerr_chk("change_index () : get_classid ",  sts,  wrapup);

		is_pretend = 0 ;

		/* if it a pretend get original object */
		if(om$is_ancestry_valid(superclassid = OPP_ACpretend_class_id,
			      subclassid = obj_class) == OM_S_SUCCESS){

         
                	is_pretend = 1 ;

			arry[k] = (char *)malloc(DI_PATH_MAX);
			if( ! get_pretends_name(&tmpid,arry[k]) )
				is_pretend = 2 ;
 
			_pdm_debug("object is a pretend ",0);

			sts = om$send(msg = message NDnode.ASreturn_go(&tmpid,
							&mat_type, 
							tmat),
						senderid = tmpid.objid,
						targetid = tmpid.objid,
						targetos = tmpid.osnum);
       

			om$get_classid(objid = tmpid.objid,
		        			osnum = tmpid.osnum,
						p_classid = &obj_class);
		}

		/* Get value of exp obj */

		sts = 0 ;

		if( is_pretend == 1 ) 
			sts = 1 ;

		else if( is_pretend == 0  ) {
			arry[k] = (char *)malloc(DI_PATH_MAX);

			sts = di$untranslate(    objname = arry[k],
                                         osnum   = tmpid.osnum,
                                         objid   = tmpid.objid);

			_pdm_debug("untranslated to: arry[k] = %s", arry[k]);

			if( sts & 1 && tmpid.osnum == 2 ) 
                        	remove_path(arry[k]);
		}


		if( ! (sts & 1 ))  {
			sts = om$send(	msg	 = message NDnode.NDgive_structure(
							&msg,
							&ret_st,
							md_env ),
	        		senderid = tmpid.objid,
		        	targetid = tmpid.objid,
			        targetos = tmpid.osnum);

                	_MO_emerr_chk("NDgive_structure : ", msg, wrapup);
                	_MO_omerr_chk("NDgive_structure : ", sts, wrapup);

			if( ret_st.type == text_type )
				strcpy(arry[k],ret_st.var.text_st.text_string);
			else
				sprintf(arry[k],"%lf", ret_st.var.root_pm_st.value);
			_pdm_debug(" value of arry[k]: %s", arry[k]);
		}
		_pdm_debug("arry[k]: %s", arry[k]);
		k = k + 1 ;
	}


	_pdm_debug("no. of objects to be replaced :%d", k );

	/* replace indexes in criteria by name/values */

	for( i = 0 ; i < num_stat ; i = i + 1 ) {

		if( strcmp(temp_val[i],"=,0") == 0 ) 
			continue ;
           
		for( j = 0 ; j < k ; j = j + 1 ) {
			sprintf(indx,"\\%d",num_stat  + j );
			
			EXPsubstitute(indx,arry[j],temp_val[i]);

			_pdm_debug("after debug the temp:%s ", temp_val[i]);
		}
	}

	for( j = 0 ; j < k ; j = j + 1 )
        	free(arry[j]);

	return(1);
wrapup:
	return(0);

} 

get_pretends_name(grid,crt_name)
struct GRid *grid ;
char crt_name[];
{

     struct GRid list[20] ;
     int cnt ;
     char footname[30] ;

     sts = om$send(msg = message ACpretend.ACgive_downscan(footname),
                                      senderid = grid -> objid,
                                      targetid = grid -> objid,
                                      targetos = grid -> osnum);

if ( DEBUG )
     printf("footname:%d\n ", footname, "\n");

     /* get root objid */     
     sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT,list,
                                                       20,NULL,0,100,&cnt),
                          senderid = grid -> objid,
                          targetid = grid -> objid,
                          targetos = grid -> osnum);

     _MO_omerr_chk("NDnode: NDgetobjects", sts, wrapup);

     sts = di$untranslate(    objname = crt_name,
                              osnum   = list[0].osnum,
                              objid   = list[0].objid);

if ( DEBUG )
     printf("macro placement name with path:%s\n ", crt_name);

     if( sts & 1  ) 
               remove_path(crt_name);

     else 
               return(0) ;


     strcat(crt_name,":");
     strcat(crt_name,footname);

     return(1);

wrapup:
 
    return(0);
}

end implementation expression ;
