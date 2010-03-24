#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"
#include <math.h>
#include "OMminimum.h"
#include "OMintprims.h"


/********************** DB_rtree_cluster_obj_3d_dbl ******************/
DB_rtree_cluster_obj_3d_dbl( root_page_p, key_p, neighbor_objid )

R_PAGE_3D_DBL   *root_page_p;
DB_3D_DBL_BOX      *key_p;
OM_S_OBJID          *neighbor_objid;

{
R_PAGE_3D_DBL *cur_page_p;
int candidate_key_num, cur_entry_num;
double volume, least_volume, enlargement, least_enlargement;
DB_3D_DBL_BOX box, *cur_key_p;
OM_p_OBJID cur_objid_p;
OM_S_RIP rip;


 
cur_page_p = root_page_p;
box = *key_p;
while ( NOT_R_LEAF( cur_page_p->Header.Page_type ) )
  {
  candidate_key_num = cur_entry_num = 0;
  cur_key_p = cur_page_p->Key;
  cur_objid_p = cur_page_p->Objid;
  VOLUME( (*cur_key_p), least_volume );
  ENLARGE_VOLUME( (*cur_key_p), box, least_volume, least_enlargement);
           

  /* compare least_enlargement and/or least_volume with the enlargement */
  /* and/or volume of the other entries in the current page             */

 for (++cur_entry_num, ++cur_key_p, ++cur_objid_p;
                        cur_entry_num < cur_page_p->Header.Key_count;
                          cur_key_p++, cur_objid_p++, cur_entry_num++)
   {
   VOLUME( (*cur_key_p), volume );
   ENLARGE_VOLUME( (*cur_key_p), box, volume, enlargement );
   if ( least_enlargement > enlargement ) 
     {
     least_enlargement = enlargement;
     candidate_key_num = cur_entry_num;
     }
   else if ( (least_enlargement == enlargement) && (least_volume > volume)) 
     {
     least_volume = volume;
     candidate_key_num = cur_entry_num;
     }  
   } /* for */

 cur_page_p = DEREF(R_PAGE_3D_DBL, (cur_page_p->Objid[candidate_key_num]), rip);

 if (cur_page_p == NULL)
   {
   return(DB_E_NULLDEREF);
   }
 }   /* while */

candidate_key_num = cur_entry_num = 0;
cur_key_p = cur_page_p->Key;
cur_objid_p = cur_page_p->Objid;
VOLUME( (*cur_key_p), least_volume );
ENLARGE_VOLUME( (*cur_key_p), box, least_volume, least_enlargement);

/* compare least_enlargement and/or least_volume with the enlargement */
/* and/or volume of the other entries in the current page             */

for (++cur_entry_num, ++cur_key_p, ++cur_objid_p; 
                    cur_entry_num < cur_page_p->Header.Key_count;
                      cur_key_p++, cur_objid_p++, cur_entry_num++) 
  {
  VOLUME( (*cur_key_p), volume );
  ENLARGE_VOLUME( (*cur_key_p), box, volume, enlargement);
  if ( least_enlargement > enlargement ) 
    {
    least_enlargement = enlargement;
    candidate_key_num = cur_entry_num;
    }
  else if ( (least_enlargement == enlargement) && (least_volume > volume)) 
    {
    least_volume = volume;
    candidate_key_num = cur_entry_num;
    }  
  } /* for */

*neighbor_objid = cur_page_p ->Objid[candidate_key_num];
return( DB_SUCCESS );
    
}





/********************* DB_rtree_reinsert_3d_dbl.c ********************/
DB_rtree_reinsert_3d_dbl(root_page_p, reinsert_set_p )

R_PAGE_3D_DBL *root_page_p;
R_REINSERT_SET_3D_DBL     *reinsert_set_p;

{
int              status;
R_REINSERT_ENTRY_3D_DBL *reinsert_entry_p;
R_PATH_HISTORY   reinsert_path;
R_PAGE_3D_DBL   *level_page_p, *empty_page_p;
DB_3D_DBL_BOX    old_page_coord, new_page_coord;
OM_S_RIP rip;


 
for ( reinsert_entry_p = reinsert_set_p->Reinsert_array;
      reinsert_entry_p < &reinsert_set_p->Reinsert_array[reinsert_set_p->Entry_count]; reinsert_entry_p++ )

  {
  if ( reinsert_entry_p->Entry_type == LEAF )
    {
    status = DB_rtree_insert_3d_dbl( root_page_p, reinsert_entry_p->Reinsert_entry );

    if (status !=  DB_SUCCESS ) return(status);
    }
  else
    {  
    /*     reinsert the non-leaf entry into a non-leaf page at the       */
    /*     same level                                                    */

    empty_page_p = NULL;
    status = DB_rtree_choose_level_3d_dbl( root_page_p, 
                        reinsert_entry_p->Level, 
	                reinsert_entry_p->Reinsert_entry,
	        	&level_page_p, 
                        &reinsert_path );
    if (status !=  DB_SUCCESS ) return( status );
    if ( level_page_p->Header.Key_count < R_MAX_KEYS_3D_DBL )
      {
      level_page_p->Key[level_page_p->Header.Key_count  ]
                        = reinsert_entry_p->Reinsert_entry.Coordinates;
      level_page_p->Objid[level_page_p->Header.Key_count++]
                   = reinsert_entry_p->Reinsert_entry.Objid;
      }
    else
      {
      GET_FREE_PAGE(R_PAGE_3D_DBL, empty_page_p, "OMrtree", rip);
      if ( empty_page_p == NULL )
	return( DB_E_GETPAGEFAIL );

      (root_page_p->Header.Page_count)++;

      status = DB_rtree_split_page_3d_dbl(
                        &reinsert_entry_p->Reinsert_entry, 
                        &level_page_p,
                        &old_page_coord, 
                        &new_page_coord, 
                        &empty_page_p   );

      if (status !=  DB_SUCCESS ) return( status );
      }
    if ( NOT_R_ROOT( level_page_p->Header.Page_type ) )
      {
      status = DB_rtree_adjust_tree_3d_dbl( 
                         &reinsert_path, 
                         &(reinsert_entry_p->Reinsert_entry.Coordinates),
                         &old_page_coord, 
                         &new_page_coord, 
                         &empty_page_p,
                         &root_page_p );

      if (status !=  DB_SUCCESS ) return( status );
      }
    else
      {
      root_page_p = level_page_p;
      }
      
    if ( empty_page_p != NULL )
      { 
      /* root was split */
      status = DB_rtree_make_root_3d_dbl ( root_page_p, old_page_coord,
                       			   new_page_coord, empty_page_p );
      if (status !=  DB_SUCCESS ) return( status );
      }
    } /* else */
  } /* for */
return (  DB_SUCCESS  );
}





/*********************** DB_rtree_choose_level_3d_dbl ****************/
DB_rtree_choose_level_3d_dbl(root_page_p, level, reinsert_key_entry,
			             level_page_pp, reinsert_path_p)

R_PAGE_3D_DBL *root_page_p;
int level;
R_PACKED_KEYENTRY_3D_DBL   reinsert_key_entry;
R_PAGE_3D_DBL     **level_page_pp;
R_PATH_HISTORY   *reinsert_path_p;

{
int            status, level_index, 
               least_enlargement_entry_index, cur_entry_index;
double           volume, least_volume, enlargement, least_enlargement;
R_PAGE_3D_DBL      *cur_page_p;
DB_3D_DBL_BOX *cur_key_p;
OM_p_OBJID cur_objid_p;
OM_S_OBJID objid;
OM_S_RIP rip;



reinsert_path_p->Path_count = 0;

/* get root page */
cur_page_p = root_page_p;

for ( level_index=0; level_index < level; level_index++ )
  {
  least_enlargement_entry_index = cur_entry_index = 0;
  cur_key_p = cur_page_p->Key;
  cur_objid_p = cur_page_p->Objid;
  VOLUME( (*cur_key_p), least_volume );
  ENLARGE_VOLUME( (*cur_key_p), reinsert_key_entry.Coordinates, least_volume, least_enlargement );

  /* compare least_enlargement and/or least_volume with the enlargement */
  /* and/or volume of the other entries in the current page             */
  for (++cur_entry_index, ++cur_key_p, ++cur_objid_p; 
                      cur_entry_index < cur_page_p->Header.Key_count;
                        cur_key_p++, cur_objid_p++, cur_entry_index++) 
    {
    VOLUME( (*cur_key_p), volume );
    ENLARGE_VOLUME( (*cur_key_p), reinsert_key_entry.Coordinates, volume, enlargement );
    if ( least_enlargement > enlargement ) 
      {
      least_enlargement = enlargement;
      least_enlargement_entry_index = cur_entry_index;
      }
    else if ( (least_enlargement == enlargement) && (least_volume > volume)) 
           {
           least_volume = volume;
           least_enlargement_entry_index = cur_entry_index;
           }  

    } /* for */
          
  objid = REF(OM_S_OBJID, cur_page_p);
  if ( IF_EQ_OBJID(objid, NULL_OBJID) )
    {
    return(DB_E_NULLIDREF);
    }
  reinsert_path_p->Path_array[reinsert_path_p->Path_count].Child_page_objid = objid;
  reinsert_path_p->Path_array[reinsert_path_p->Path_count++].Entry_number = least_enlargement_entry_index;
  cur_page_p = DEREF(R_PAGE_3D_DBL, (cur_page_p->Objid[least_enlargement_entry_index]), rip);
  if (cur_page_p == NULL)
    {
    return(DB_E_NULLDEREF);
    }

  }   /* outer for loop */
  
*level_page_pp = cur_page_p;
   
return ( DB_SUCCESS );

}





/********************** DB_rtree_insert_3d_dbl ***********************/
DB_rtree_insert_3d_dbl( root_page_p, new_entry )

R_PAGE_3D_DBL *root_page_p;
R_PACKED_KEYENTRY_3D_DBL   new_entry;

{
int              status;
R_PATH_HISTORY   insert_path;
R_PAGE_3D_DBL    *leaf_page_p, *new_page_p;
DB_3D_DBL_BOX    old_page_coord, new_page_coord;
OM_S_RIP rip;



new_page_p = NULL;
status = DB_rtree_choose_leaf_3d_dbl( root_page_p, &new_entry, &leaf_page_p, &insert_path );   
if (status !=  DB_SUCCESS )return( status );
if ( leaf_page_p->Header.Key_count < R_MAX_KEYS_3D_DBL )
  {
  leaf_page_p->Key[leaf_page_p->Header.Key_count] = new_entry.Coordinates;
  leaf_page_p->Objid[leaf_page_p->Header.Key_count++] = new_entry.Objid;
  }
else
  {
  GET_FREE_PAGE(R_PAGE_3D_DBL, new_page_p, "OMrtree", rip);
  if ( new_page_p == NULL )
    return ( DB_E_GETPAGEFAIL);
 
  (root_page_p->Header.Page_count)++;

  status = DB_rtree_split_page_3d_dbl(&new_entry, &leaf_page_p,
			        &old_page_coord, &new_page_coord, &new_page_p);
  if (status !=  DB_SUCCESS )return( status );
  }
if ( NOT_R_ROOT( leaf_page_p->Header.Page_type ) )
  {
  status = DB_rtree_adjust_tree_3d_dbl(&insert_path, &(new_entry.Coordinates), &old_page_coord, &new_page_coord, &new_page_p, &root_page_p);
  if (status !=  DB_SUCCESS )return( status );
  }
else
  {
  root_page_p = (R_PAGE_3D_DBL *)leaf_page_p;
  }
if ( new_page_p != NULL )
  {
  /* root was split */

  status = DB_rtree_make_root_3d_dbl ( root_page_p, old_page_coord,
					 new_page_coord, new_page_p );
  if (status !=  DB_SUCCESS )return( status );
  }
return (  DB_SUCCESS  );
}





/************************ DB_rtree_choose_leaf_3d_dbl *****************/
DB_rtree_choose_leaf_3d_dbl ( root_page_p, new_entry_p, leaf_page_pp, insert_path_p)

R_PAGE_3D_DBL   *root_page_p;
R_PACKED_KEYENTRY_3D_DBL   *new_entry_p;
R_PAGE_3D_DBL      **leaf_page_pp; 
R_PATH_HISTORY   *insert_path_p;

{
int            status, least_enlargement_entry_index, cur_entry_index;
double           volume, least_volume, enlargement, least_enlargement;
register R_PAGE_3D_DBL      *cur_page_p;
register DB_3D_DBL_BOX *cur_key_p;
register OM_p_OBJID cur_objid_p;
OM_S_OBJID objid;
OM_S_RIP rip;


 
insert_path_p->Path_count = 0;

/* get root page */
cur_page_p = root_page_p;

while ( NOT_R_LEAF( cur_page_p->Header.Page_type ) )
  {
  least_enlargement_entry_index = cur_entry_index = 0;
  cur_key_p = cur_page_p->Key;
  cur_objid_p = cur_page_p->Objid;
  VOLUME( (*cur_key_p), least_volume );
  ENLARGE_VOLUME( (*cur_key_p), new_entry_p->Coordinates, least_volume, least_enlargement);
           
  /* compare least_enlargement and/or least_volume with the enlargement */
  /* and/or volume of the other entries in the current page             */

  for (++cur_entry_index, ++cur_key_p, ++cur_objid_p; 
                        cur_entry_index < cur_page_p->Header.Key_count;
                         cur_key_p++, cur_objid_p++, cur_entry_index++) 
    {
    VOLUME( (*cur_key_p), volume );
    ENLARGE_VOLUME((*cur_key_p), new_entry_p->Coordinates, volume, enlargement);
    if ( least_enlargement > enlargement ) 
      {
      least_enlargement = enlargement;
      least_enlargement_entry_index = cur_entry_index;
      }
    else if ( (least_enlargement == enlargement) && (least_volume > volume)) 
           {
           least_volume = volume;
           least_enlargement_entry_index = cur_entry_index;
           }  
    } /* for */
          
  objid = REF(OM_S_OBJID, cur_page_p);
  if ( IF_EQ_OBJID(objid, NULL_OBJID) )
    {
    return(DB_E_NULLIDREF);
    }
  insert_path_p->Path_array[insert_path_p->Path_count].Child_page_objid
		 					        = objid;

  insert_path_p->Path_array[insert_path_p->Path_count++].Entry_number
                                        = least_enlargement_entry_index;
  cur_page_p = DEREF(R_PAGE_3D_DBL, (cur_page_p->Objid[least_enlargement_entry_index]), rip);     
  if (cur_page_p == NULL)
    {
    return(DB_E_NULLDEREF);
    }

  }   /* while */
*leaf_page_pp = cur_page_p;
return ( DB_SUCCESS );
}





/*********************** DB_rtree_adjust_tree_3d_dbl ******************/
DB_rtree_adjust_tree_3d_dbl(insert_path_p, newentry_coord_p, old_page_coord_p, new_page_coord_p, new_page_pp, root_page_pp)

R_PATH_HISTORY   *insert_path_p;
DB_3D_DBL_BOX    *newentry_coord_p, *old_page_coord_p, *new_page_coord_p;
R_PAGE_3D_DBL    **new_page_pp, **root_page_pp;

{
int              path_index, status;
R_PATH_HISTORY   insert_path;
R_PATH_ENTRY     parent;
DB_3D_DBL_BOX    old_page_coord, new_page_coord;
R_PAGE_3D_DBL        *local_new_page_p, *parent_page_p;
R_PACKED_KEYENTRY_3D_DBL   new_entry;
OM_S_OBJID  objid;
OM_S_RIP rip;



local_new_page_p = *new_page_pp;
do
  {
  /* get parent page */
  parent = insert_path_p->Path_array[--insert_path_p->Path_count];
  parent_page_p = DEREF(R_PAGE_3D_DBL, parent.Child_page_objid, rip);
  if (parent_page_p == NULL)
    {
    return(DB_E_NULLDEREF);
    }
   
  if ( local_new_page_p == NULL )  /* no page split */
    {
    TIGHT_CUBE(parent_page_p->Key[parent.Entry_number], (*newentry_coord_p));
    }	 
  else
    {
    /* for old page....*/
    parent_page_p->Key[parent.Entry_number] = *old_page_coord_p;

    /* for new page....*/
    if (parent_page_p->Header.Key_count < R_MAX_KEYS_3D_DBL)
      {
      /* empty slot in parent's key array */
      parent_page_p->Key[parent_page_p->Header.Key_count] = *new_page_coord_p;
      objid = REF(OM_S_OBJID, local_new_page_p);
      if ( IF_EQ_OBJID(objid, NULL_OBJID) )
        {
        return(DB_E_NULLIDREF);
        }
      parent_page_p->Objid[parent_page_p->Header.Key_count++] = objid;
      local_new_page_p = NULL;
      }
    else
      {
      /* no empty slot */
      new_entry.Coordinates = *new_page_coord_p;
      new_entry.Objid = REF(OM_S_OBJID, local_new_page_p);
      if ( IF_EQ_OBJID(new_entry.Objid, NULL_OBJID) )
        {
        return(DB_E_NULLIDREF);
        }

      GET_FREE_PAGE(R_PAGE_3D_DBL, local_new_page_p, "OMrtree", rip);
      if ( local_new_page_p == NULL )
        return ( DB_E_GETPAGEFAIL);

      ((*root_page_pp)->Header.Page_count)++;

      status = DB_rtree_split_page_3d_dbl( &new_entry, &parent_page_p, 
                                     &old_page_coord, &new_page_coord, 
                                     &local_new_page_p );
      if (status != DB_SUCCESS ) return( status );
      *old_page_coord_p = old_page_coord;
      *new_page_coord_p = new_page_coord;
      } 
				             
    } /* else page was split */

  if ( IS_R_ROOT(parent_page_p->Header.Page_type) )
    {
    *old_page_coord_p = old_page_coord;
    *new_page_coord_p = new_page_coord;
    *new_page_pp = local_new_page_p;
    *root_page_pp = parent_page_p;
    return ( DB_SUCCESS );
    }
  } /* do */
while ( TRUE );

}





/********************** DB_rtree_make_root_3d_dbl ********************/
DB_rtree_make_root_3d_dbl
        ( root_page_p, root_page_coord, new1_page_coord, new1_page_p ) 

R_PAGE_3D_DBL     *root_page_p;
DB_3D_DBL_BOX     root_page_coord, new1_page_coord;
R_PAGE_3D_DBL     *new1_page_p;

{
R_PAGE_3D_DBL     *new2_page_char_p;
OM_S_OBJID objid;
OM_S_RIP rip;



/* get the 2nd new page for root split */
GET_FREE_PAGE(R_PAGE_3D_DBL, new2_page_char_p, "OMrtree", rip);
if ( new2_page_char_p == NULL )
  return ( DB_E_GETPAGEFAIL );

(root_page_p->Header.Page_count)++;

DB_MOV_N_BYTES(root_page_p, new2_page_char_p, DB_BYTES_RPAGE);
if ( root_page_p->Header.Page_type == R_LF_RT_PAGE )
  {
  new2_page_char_p->Header.Page_type = R_LF_NR_PAGE;
  }
else  
  {
  new2_page_char_p->Header.Page_type = R_NL_NR_PAGE;
  }
/* create two new entries for the empty root */
root_page_p->Header.Page_type = R_NL_RT_PAGE;
root_page_p->Header.Rtree_type = RTREE_3D_DBL;
root_page_p->Header.Key_count = 2;
root_page_p->Key[0] = new1_page_coord;
root_page_p->Key[1] = root_page_coord;
objid = REF(OM_S_OBJID, new1_page_p);
if ( IF_EQ_OBJID(objid, NULL_OBJID) )
  {
  return(DB_E_NULLIDREF);
  }
root_page_p->Objid[0] = objid;

objid = REF(OM_S_OBJID, new2_page_char_p);
if ( IF_EQ_OBJID(objid, NULL_OBJID) )
  {
  return(DB_E_NULLIDREF);
  }
root_page_p->Objid[1] = objid;
return ( DB_SUCCESS );
}





/******************** DB_rtree_compress_page_3d_dbl *******************/
DB_rtree_compress_page_3d_dbl(cur_page_pp, stat_array, newentry_p)

R_PAGE_3D_DBL            *(*cur_page_pp);
char                 stat_array[];
R_PACKED_KEYENTRY_3D_DBL       *newentry_p;

{
R_PAGE_3D_DBL         *local_cur_page_p;
int               f_index, e_index;
int               end_index;



local_cur_page_p = *cur_page_pp;
f_index = end_index = R_MAX_KEYS_3D_DBL;
e_index = -1;
if ( stat_array[ end_index ] == 'f' )
  {
  while (stat_array[ ++e_index ] != 'e' && e_index <= R_MAX_KEYS_3D_DBL);
  local_cur_page_p->Key[ e_index ] = newentry_p->Coordinates;
  local_cur_page_p->Objid[ e_index ] = newentry_p->Objid;
  }

while (e_index + 1 < f_index - 1)
  {
  while (stat_array[ ++e_index ] != 'e' && e_index <= R_MAX_KEYS_3D_DBL);
  while (stat_array[ --f_index ] != 'f' && f_index >= 0);
  if ( e_index < f_index )
    {
    local_cur_page_p->Key[ e_index ] = local_cur_page_p->Key[ f_index ];
    local_cur_page_p->Objid[e_index] = local_cur_page_p->Objid[f_index];
    }
  }
*cur_page_pp = local_cur_page_p;
return( DB_SUCCESS );
}





/*********************** DB_rtree_pick_next_3d_dbl ********************/
DB_rtree_pick_next_3d_dbl(fullpage_p, newentry_p, statusarray,
                   statusarrayindex,  grp1volume, grp2volume, grp1coord_p,
		   grp2coord_p, group1newindex_p, group2newindex_p)

R_PAGE_3D_DBL    *fullpage_p;
R_PACKED_KEYENTRY_3D_DBL   *newentry_p;
char             statusarray[];
int              statusarrayindex;
double           grp1volume, grp2volume;
DB_3D_DBL_BOX    *grp1coord_p, *grp2coord_p;
int              *group1newindex_p, *group2newindex_p;

{
DB_3D_DBL_BOX    temp_grp1coord, temp_grp2coord, inx_key_coord;
int              ptr_to_index;
double           save_difference[3];
                 /*   [ 0 ] = Norm ( [ 1 ] - [ 2 ] )         */
                 /*   [ 1 ] = group 1 enlargement difference */
                 /*   [ 2 ] = group 2 enlargement difference */
char             *start_status_array_p;
double           intersect_1, intersect_2;



*group1newindex_p = -1;
*group2newindex_p = -1;
ptr_to_index = &statusarray[ statusarrayindex ] - statusarray;
if (ptr_to_index == R_MAX_KEYS_3D_DBL)
  inx_key_coord = newentry_p->Coordinates;
else
  inx_key_coord = fullpage_p->Key[ptr_to_index];

ENLARGE_VOLUME(inx_key_coord, (*grp1coord_p), grp1volume, save_difference[1]);
ENLARGE_VOLUME(inx_key_coord, (*grp2coord_p), grp2volume, save_difference[2]);
temp_grp1coord = *grp1coord_p;
temp_grp2coord = *grp2coord_p;
TIGHT_CUBE(temp_grp1coord, inx_key_coord);
INTERSECT_VOLUME(grp2coord_p, &temp_grp1coord, &intersect_1);
TIGHT_CUBE(temp_grp2coord, inx_key_coord);
INTERSECT_VOLUME(grp1coord_p, &temp_grp2coord, &intersect_2);
if (intersect_1 == intersect_2 )
  {
  if (save_difference[ 1 ] > save_difference[ 2 ])
    *group2newindex_p = ptr_to_index;
  else if (save_difference[ 1 ] < save_difference[ 2 ])
         *group1newindex_p = ptr_to_index;
       else
         {
         if (grp1volume < grp2volume )
           *group1newindex_p = ptr_to_index;
         else
           *group2newindex_p = ptr_to_index;
         } /** else **/
  }
else if ( intersect_1 < intersect_2 )
       {
       *group1newindex_p = ptr_to_index;
       }
     else
       {
       *group2newindex_p = ptr_to_index;
       }
return(  DB_SUCCESS  );
}
 




/********************** DB_rtree_seed_pick_3d_dbl *********************/
DB_rtree_seed_pick_3d_dbl(cur_page_p, new_entry_p, grp1newindex_p, grp2newindex_p)

R_PAGE_3D_DBL         *cur_page_p;
R_PACKED_KEYENTRY_3D_DBL    *new_entry_p;
int                   *grp1newindex_p, *grp2newindex_p;

{
double   zh_small, zl_small, yh_small, yl_small, xh_small, xl_small;
double   zh_large, zl_large, yh_large, yl_large, xh_large, xl_large;
int      zh_small_index, yh_small_index, xh_small_index;
int      zl_large_index, yl_large_index, xl_large_index;
int      search_index, end_search_index;
double   norm_z_axis, norm_y_axis, norm_x_axis;



end_search_index = R_MAX_KEYS_3D_DBL;

xl_small = xl_large = new_entry_p->Coordinates.xmin;
xh_small = xh_large = new_entry_p->Coordinates.xmax;
yl_small = yl_large = new_entry_p->Coordinates.ymin;
yh_small = yh_large = new_entry_p->Coordinates.ymax;
zl_small = zl_large = new_entry_p->Coordinates.zmin;
zh_small = zh_large = new_entry_p->Coordinates.zmax;

/***** new entry is the selected entry right now *******/

zh_small_index = yh_small_index = xh_small_index =  R_MAX_KEYS_3D_DBL;
zl_large_index = yl_large_index = xl_large_index =  R_MAX_KEYS_3D_DBL;

for (search_index = 0; search_index != end_search_index; ++search_index )
  {  
  xh_large = MAX( xh_large, cur_page_p->Key[ search_index ].xmax );       
  xl_small = MIN( xl_small, cur_page_p->Key[ search_index ].xmin );       
  yh_large = MAX( yh_large, cur_page_p->Key[ search_index ].ymax );       
  yl_small = MIN( yl_small, cur_page_p->Key[ search_index ].ymin );       
  zh_large = MAX( zh_large, cur_page_p->Key[ search_index ].zmax );       
  zl_small = MIN( zl_small, cur_page_p->Key[ search_index ].zmin );       

  if ( xh_small >  cur_page_p->Key[ search_index ].xmax )
    {
    xh_small = cur_page_p->Key[ search_index ].xmax;
    xh_small_index = search_index;
    }           

  if ( yh_small >  cur_page_p->Key[ search_index ].ymax )
    {
    yh_small = cur_page_p->Key[ search_index ].ymax;
    yh_small_index = search_index;
    }           

  if ( zh_small >  cur_page_p->Key[ search_index ].zmax )
    {
    zh_small = cur_page_p->Key[ search_index ].zmax;
    zh_small_index = search_index;
    }           

  } /* for */

for (search_index = 0; search_index != end_search_index; ++search_index )
  {
  if ( zl_large < cur_page_p->Key[ search_index ].zmin )
    {
    if ( zh_small_index != search_index )
      {
      zl_large = cur_page_p->Key[ search_index ].zmin;
      zl_large_index = search_index;
      }
    }           

  if ( yl_large < cur_page_p->Key[ search_index ].ymin )
    {
    if ( yh_small_index != search_index )
      {
      yl_large = cur_page_p->Key[ search_index ].ymin;
      yl_large_index = search_index;
      }
    }           

  if ( xl_large < cur_page_p->Key[ search_index ].xmin )
    {
    if ( xh_small_index != search_index )
      {
      xl_large = cur_page_p->Key[ search_index ].xmin;
      xl_large_index = search_index;
      }
    }           
  } /* for */

norm_z_axis = NORM( zh_small, zl_large,  zh_large,  zl_small );
norm_z_axis = NORMALIZE(norm_z_axis);
norm_y_axis = NORM( yh_small, yl_large,  yh_large,  yl_small );
norm_y_axis = NORMALIZE(norm_y_axis);
norm_x_axis = NORM( xh_small, xl_large, xh_large,  xl_small );
norm_x_axis = NORMALIZE(norm_x_axis);
    
if (xh_small_index == xl_large_index)
  norm_x_axis = -1;
if (yh_small_index == yl_large_index)
  norm_y_axis = -1;
if (zh_small_index == zl_large_index)
  norm_z_axis = -1;
  
if (norm_x_axis >= norm_y_axis && norm_x_axis >= norm_z_axis)
  {
  *grp1newindex_p = xh_small_index;
  *grp2newindex_p = xl_large_index;
  return(DB_SUCCESS); 
  }
else if (norm_y_axis >= norm_z_axis)
       {
       *grp1newindex_p = yh_small_index;
       *grp2newindex_p = yl_large_index;
       return(DB_SUCCESS); 
       }
     else
       {
       *grp1newindex_p = zh_small_index;
       *grp2newindex_p = zl_large_index;
       return(DB_SUCCESS); 
       }
}





/*********************** DB_rtree_split_page_3d_dbl *******************/
DB_rtree_split_page_3d_dbl(newentry_p, full_page_pp, 
		           grp1_coord_p, grp2_coord_p, empty_page_pp)

R_PACKED_KEYENTRY_3D_DBL   *newentry_p;
R_PAGE_3D_DBL        **full_page_pp;
DB_3D_DBL_BOX        *grp1_coord_p, *grp2_coord_p;
R_PAGE_3D_DBL        **empty_page_pp;

{
R_PAGE_3D_DBL        *local_full_page_p, *local_empty_page_p;
char             status_array[ R_MAX_KEYS_3D_DBL_PLUS_ONE ];
                 /*    u - unassigned             */
                 /*    f - assigned to full page  */
                 /*    e - assigned to empty page */
char             *status_array_p; /* next place to start search */
char             *start_status_array_p;
char             *end_status_array_p;
char		 *newentry_status_array_p;
int              group1_new_index, group2_new_index, i;
int              rtn; 
int              rtn_stat;
double           grp1_volume, grp2_volume;
int              ptr_to_index;
int              status_array_index;
int		 DB_seed_pick_3d_dbl();
int      	 DB_pick_next_3d_dbl();
int		 DB_compress_page_3d_dbl();
int 	       *index_to_key_p, max_keys, assignment[R_MAX_KEYS_3D_DBL-1];
static int     h[8]={ 1, 4, 13, 40, 121, 364, 1093, 3280 };
int            max_h =8;
double         enlarge_to_new, save_difference[R_MAX_KEYS_3D_DBL-1];
int	       j, assign_index = 0;



local_full_page_p = *full_page_pp;
end_status_array_p = &status_array[ R_MAX_KEYS_3D_DBL_PLUS_ONE ];
for (status_array_p = start_status_array_p = status_array;     
         status_array_p != end_status_array_p; ++status_array_p)
  *status_array_p = 'u';

local_empty_page_p = *empty_page_pp;
if (local_full_page_p->Header.Page_type == R_LF_RT_PAGE)
  {
  local_empty_page_p->Header.Page_type = R_LF_NR_PAGE; 
  }
else if (local_full_page_p->Header.Page_type == R_NL_RT_PAGE)
       {
       local_empty_page_p->Header.Page_type = R_NL_NR_PAGE;
       }
     else
       {
       local_empty_page_p->Header.Page_type = local_full_page_p->Header.Page_type;
       }
local_empty_page_p->Header.Rtree_type = local_full_page_p->Header.Rtree_type;

rtn_stat = DB_rtree_seed_pick_3d_dbl (local_full_page_p, newentry_p, 
			      &group1_new_index, &group2_new_index);
if (rtn_stat !=  DB_SUCCESS )
  {
  return ( rtn_stat );
  }

if (group1_new_index == group2_new_index)
  group2_new_index = 0;

status_array [ group1_new_index ] = 'f';
max_keys = R_MAX_KEYS_3D_DBL;
if (group1_new_index != R_MAX_KEYS_3D_DBL)
  {
  *grp1_coord_p = local_full_page_p->Key[ group1_new_index];
  max_keys--;
  }
else
  *grp1_coord_p = newentry_p->Coordinates;

VOLUME ((*grp1_coord_p), grp1_volume);
status_array [ group2_new_index ] = 'e';
if (group2_new_index != R_MAX_KEYS_3D_DBL)
  {
  local_empty_page_p->Key[0] = local_full_page_p->Key[group2_new_index];
  local_empty_page_p->Objid[0] = local_full_page_p->Objid[group2_new_index];
  *grp2_coord_p = local_empty_page_p->Key[0];
  max_keys--;
  }
else
  {
  local_empty_page_p->Key[0] = newentry_p->Coordinates;
  local_empty_page_p->Objid[0] = newentry_p->Objid;
  *grp2_coord_p = newentry_p->Coordinates;
  }
local_empty_page_p->Header.Key_count = 1;
local_full_page_p->Header.Key_count = 1;
VOLUME ((*grp2_coord_p), grp2_volume) ;
status_array_index = 0;
newentry_status_array_p = &status_array[ R_MAX_KEYS_3D_DBL ];    

for (i = 0, j = 0; i < R_MAX_KEYS_3D_DBL; i++)
  {
  if (i != group1_new_index && i != group2_new_index)
    {
    ENLARGE_VOLUME((*grp2_coord_p), local_full_page_p->Key[i],
		   	     grp2_volume, save_difference[j]);
    assignment[j++] = i;		
    }
  }

rtn = shell_sort(save_difference, max_keys, h, max_h, assignment);
if ( rtn !=  DB_SUCCESS )
  {
  return ( rtn );
  }

if (max_keys == (R_MAX_KEYS_3D_DBL - 2))
  {
  ENLARGE_VOLUME(local_full_page_p->Key[group2_new_index],
		 newentry_p->Coordinates, grp2_volume, enlarge_to_new);
  if (enlarge_to_new < save_difference[max_keys / 2])
    {
    TIGHT_CUBE((*grp2_coord_p), newentry_p->Coordinates);
    local_empty_page_p->Key[local_empty_page_p->Header.Key_count] = newentry_p->Coordinates;
    local_empty_page_p->Objid[local_empty_page_p->Header.Key_count++] = newentry_p->Objid;
    status_array[R_MAX_KEYS_3D_DBL] = 'e';
    }
  else
    {
    TIGHT_CUBE((*grp1_coord_p), newentry_p->Coordinates);
    local_full_page_p->Header.Key_count++;
    status_array[R_MAX_KEYS_3D_DBL] = 'f';
    }
  }



while ( (local_empty_page_p->Header.Key_count + local_full_page_p->
		     Header.Key_count) < R_MAX_KEYS_3D_DBL_PLUS_ONE )
  {
  if (local_empty_page_p->Header.Key_count >= (R_MAX_KEYS_3D_DBL / 2))

    /** assign rest to the full page  **/
    {
    for ( ; assign_index < max_keys; assign_index++)
      {
      status_array_p = &status_array[assignment[assign_index]];
      if (*status_array_p == 'u')
        {
        *status_array_p = 'f';
        local_full_page_p->Header.Key_count++;
        if (status_array_p < newentry_status_array_p)
          {
 	  ptr_to_index = status_array_p - start_status_array_p;
	  TIGHT_CUBE((*grp1_coord_p), local_full_page_p->Key[ptr_to_index]);
          }
        else
          {
	  TIGHT_CUBE((*grp1_coord_p), newentry_p->Coordinates);
	  }
        }
      } /* for */
    rtn_stat = DB_rtree_compress_page_3d_dbl(&local_full_page_p, status_array, newentry_p);
    return (rtn_stat);
    } /* if */

  if (local_full_page_p->Header.Key_count >= (R_MAX_KEYS_3D_DBL / 2))

    /** assign rest to empty page  **/
    {
    for ( ; assign_index < max_keys; assign_index++)
      {
      status_array_p = &status_array[assignment[assign_index]];
      if (*status_array_p == 'u')
        {
        *status_array_p = 'e';
        if (status_array_p < newentry_status_array_p )
          {
          ptr_to_index = status_array_p - start_status_array_p;
          TIGHT_CUBE((*grp2_coord_p), local_full_page_p->Key[ptr_to_index]);
          local_empty_page_p->Key[local_empty_page_p->Header.Key_count] = local_full_page_p->Key[ptr_to_index];
          local_empty_page_p->Objid[local_empty_page_p->Header.Key_count++] = local_full_page_p->Objid[ptr_to_index];
          }
        else
          {
          TIGHT_CUBE((*grp2_coord_p), newentry_p->Coordinates);
          local_empty_page_p->Key[local_empty_page_p->Header.Key_count] = newentry_p->Coordinates;
          local_empty_page_p->Objid[local_empty_page_p->Header.Key_count++] = newentry_p->Objid;
          }  
        } /* if */
      } /* for */
    rtn_stat = DB_rtree_compress_page_3d_dbl(&local_full_page_p,status_array, newentry_p );
    return (rtn_stat);
    } /* if */


  status_array_index = assignment[assign_index++];

  rtn_stat = DB_rtree_pick_next_3d_dbl(local_full_page_p, newentry_p,
                       status_array, status_array_index, grp1_volume,
                       grp2_volume, grp1_coord_p, grp2_coord_p, 
		       &group1_new_index, &group2_new_index);
  if (rtn_stat !=  DB_SUCCESS )
    return ( rtn_stat );
  if ( group1_new_index == -1 )
    /***  assign group2_new_index to lf_empty_page ***/
    {
    status_array [ group2_new_index ] = 'e';
    if (group2_new_index < R_MAX_KEYS_3D_DBL )
      {
      local_empty_page_p->Key[local_empty_page_p->Header.Key_count] = local_full_page_p->Key[group2_new_index];
      local_empty_page_p->Objid[local_empty_page_p->Header.Key_count++] = local_full_page_p->Objid[group2_new_index];
      TIGHT_CUBE((*grp2_coord_p), local_full_page_p->Key[group2_new_index]);
      }
    else
      {
      local_empty_page_p->Key[local_empty_page_p->Header.Key_count]
				          = newentry_p->Coordinates;
      local_empty_page_p->Objid[local_empty_page_p->Header.Key_count++]
				                    = newentry_p->Objid;
      TIGHT_CUBE(( *grp2_coord_p),  newentry_p->Coordinates);
      }
    VOLUME ( (*grp2_coord_p), grp2_volume ) ;
    } 
  else
    {
    /*** assign group1_new_index to lf_full_page ***/
    status_array [ group1_new_index ] = 'f';
    if (group1_new_index < R_MAX_KEYS_3D_DBL )
      {
      TIGHT_CUBE((*grp1_coord_p), local_full_page_p->Key[group1_new_index]);
      }
    else
      { 
      TIGHT_CUBE(( *grp1_coord_p),newentry_p->Coordinates);
      }
    local_full_page_p->Header.Key_count++;
    VOLUME ((*grp1_coord_p), grp1_volume ) ;
    } /* else */

  } /* while */

return( DB_SUCCESS );
}
           




/*********************** DB_rtree_search_3d_dbl ***********************/
/* This function is called to asynchronously search an RTREE for
   overlapping rectangles of a specified rectangle. An action
   routine is passed in to this function which will be executed
   once for each instance of an overlapping rectangle. GDK. */

DB_rtree_search_3d_dbl (root_page_p,
       	                coordinate_p,
           	        user_action_routine_p,
	                user_context_p,
			classStatMap)

  R_PAGE_3D_DBL *root_page_p;
  DB_3D_DBL_BOX	*coordinate_p;
  int		(*user_action_routine_p)();
  char		*user_context_p;
  OMbyte	*classStatMap;
  {
  RTREE_LOCAL_CONTEXT_3D_DBL	local_context;
  int			DB_rtree_page_search_3d_dbl();

    

  if (root_page_p->Header.Key_count == 0)
    {
    return(DB_SUCCESS);
    }

  /* build local context */
  local_context.coordinate_p = coordinate_p;
  local_context.user_action_routine_p = user_action_routine_p;
  local_context.user_context_p = user_context_p;
  
  /* initiate search with root node */
  DB_rtree_page_search_3d_dbl( root_page_p, &local_context, classStatMap);
  return(DB_SUCCESS);
  }





/******************* DB_rtree_page_search_3d_dbl ******************/
/* this routine is responsible for searching an rtree node
   and invoking the appropiate routine. */

int DB_rtree_page_search_3d_dbl(root_page_p, local_context_p, classStatMap)

  R_PAGE_3D_DBL      *root_page_p;
  RTREE_LOCAL_CONTEXT_3D_DBL	*local_context_p;
  OMbyte *classStatMap;

  {
  R_PAGE_3D_DBL  *cur_page_p, *next_page_p;
  int	i, return_code;
  R_PACKED_KEYENTRY_3D_DBL packed_keyentry;
  DB_3D_DBL_BOX *key_p;
  OM_p_OBJID    objid_p;
  OM_S_RIP rip;


  
  cur_page_p = root_page_p;
  key_p = cur_page_p->Key;
  objid_p = cur_page_p->Objid;
  if ( NOT_R_LEAF(cur_page_p->Header.Page_type) )
    {
    /* process non-leaf page */

    for (i = 0; i < cur_page_p->Header.Key_count; i++)
      {
      if ( DB_3D_BOX_INTERSECT(local_context_p->coordinate_p, key_p) )
        {
        next_page_p = DEREF(R_PAGE_3D_DBL, (*objid_p), rip);
        if (next_page_p == NULL)
          {
          return(DB_E_NULLDEREF);
          }
    
        if ((return_code = DB_rtree_page_search_3d_dbl(next_page_p,
                     local_context_p, classStatMap)) != DB_CONTINUE)
          {
          return(return_code);
          }
        }
      key_p += 1;
      objid_p += 1;
      }
    }
  else
    {
    /* process leaf page */
    for (i = 0; i < cur_page_p->Header.Key_count; i++)
      {
      if ( DB_3D_BOX_INTERSECT(local_context_p->coordinate_p, key_p) )
        {
        if (!classStatMap || classStatMap[OM_GA_active_to_filed[OM_GA_OSDs[OM_Gw_current_OS]->Spacemap[*objid_p].p_acld->w_classid]])
          {
          packed_keyentry.Coordinates = *key_p;
          packed_keyentry.Objid = *objid_p;
        
          /* invoke user supplied action routine. */
          if ( (return_code = (*local_context_p->user_action_routine_p)
              (&packed_keyentry, local_context_p->user_context_p)) == DB_TERMINATE )
            {
            return(return_code);
            }
          }     /* if user specified class */
        }	/* if intersect */
      key_p += 1;
      objid_p += 1;
      }	   /* for */
    }
   return(DB_CONTINUE);
  }




/************************* DB_rtree_skewsrch_3d_dbl *********************/
/*----
 
     MODULE NAME:	DB_rtree_skewsrch_3d_dbl
 
     Abstract:		Skewscan is a method of selecting elements
			from an rtree by rejecting those elements
			that do not meet the criteria. An action routine
			is passed in to this function and executed once
			for each instance of an intersecting rectangle.
			
     VALUE = DB_rtree_skewsrch_3d_dbl(root_page_p, range1, range2, sx, sy, sz, user_action, user_context )

     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
   root_page_p  R_PAGE_3D_DBL        rtree 3dd root page
   range1       DB_3D_DBL_BOX           default range criteria
   range2       DB_3D_DBL_BOX           range of small cube moved along
					view vector to find non-intersecting
					elements which will be rejected
   sx		double			rate the cube moves in the x direction
   sy		double			rate the cube moves in the y direction
   sz		double			rate the cube moves in the z direction
   user_action  int			user action routine
   user_context ptr to character        ptr to user context block

     MODULES INVOKED:	DB_rtree_page_skewsrch_3d_dbl

     CHANGE HISTORY:
	
     TLG created 1/86
     001 sss may-30-1988   added the new argument classStatMap

----*/

DB_rtree_skewsrch_3d_dbl( root_page_p,
       	                range1,
			range2, 
			sx, sy, sz, 
           	        user_action_routine_p,
	                user_context_p,
			classStatMap)

  R_PAGE_3D_DBL 	*root_page_p;
  DB_3D_DBL_BOX		range1;
  DB_3D_DBL_BOX		range2;
  double sx, sy, sz;
  int		(*user_action_routine_p)();
  char		*user_context_p;
  OMbyte	*classStatMap;
  
  {
  RTREE_SKEW_CONTEXT_3D_DBL	local_context;
  int				DB_rtree_page_skewsrch_3d_dbl();
  int				ret;
  
  /* build local context */

  local_context.range1 = range1;
  local_context.range2 = range2;
  local_context.sx = sx;
  local_context.sy = sy;
  local_context.sz = sz;
  local_context.user_action_routine_p = user_action_routine_p;
  local_context.user_context_p = user_context_p;

  /* Initiate search with root node */
  
  ret =  DB_rtree_page_skewsrch_3d_dbl( root_page_p, &local_context, classStatMap);

  if ( ret != DB_CONTINUE )
	return( ret );
  else
	return( DB_SUCCESS );

  }




/********************** DB_rtree_page_skewsrch_3d_dbl ******************/
/* this routine is responsible for searching an rtree node
   and invoking the appropiate routine. */

int DB_rtree_page_skewsrch_3d_dbl ( root_page_p, local_context_p, classStatMap)

  R_PAGE_3D_DBL		*root_page_p;
  RTREE_SKEW_CONTEXT_3D_DBL	*local_context_p;
  OMbyte   *classStatMap;

  {
  R_PAGE_3D_DBL	*cur_page_p, *next_page_p;
  int i, return_code;
  R_PACKED_KEYENTRY_3D_DBL packed_keyentry;
  DB_3D_DBL_BOX *key_p;
  OM_p_OBJID objid_p;
  OM_S_RIP rip;


  
  cur_page_p = root_page_p;
  key_p = cur_page_p->Key;
  objid_p = cur_page_p->Objid;
  if ( NOT_R_LEAF(cur_page_p->Header.Page_type) )
    {
    /* process non-leaf page */

    for (i = 0; i < cur_page_p->Header.Key_count; i++)
      {
      if ( DB_lr_intersect_3d_dbl(&local_context_p->range1,
              &local_context_p->range2, local_context_p->sx,
	      local_context_p->sy, local_context_p->sz, key_p) )
        {
        next_page_p = DEREF(char, *objid_p, rip);
        if (next_page_p == NULL)
          {
          return(DB_E_NULLDEREF);
          }
    
        if ( (return_code = DB_rtree_page_skewsrch_3d_dbl(next_page_p, 
 		       local_context_p, classStatMap)) != DB_CONTINUE )
          {
          return(return_code);
          }
        }
      key_p += 1;
      objid_p += 1;
      }
    }
  else
    {
    /* process leaf page */

    for (i = 0; i < cur_page_p->Header.Key_count; i++)
      {
      if ( DB_lr_intersect_3d_dbl(&local_context_p->range1,
	     &local_context_p->range2, local_context_p->sx,
	     local_context_p->sy, local_context_p->sz, key_p) )
        {
        if (!classStatMap || classStatMap[OM_GA_active_to_filed[OM_GA_OSDs[OM_Gw_current_OS]->Spacemap[*objid_p].p_acld->w_classid]])
          {
    
          /* invoke user supplied action routine. */

          packed_keyentry.Coordinates = *key_p;
          packed_keyentry.Objid = *objid_p;
          if ((return_code = (*local_context_p->user_action_routine_p)
                (&packed_keyentry, local_context_p->user_context_p))
   					             != DB_CONTINUE)
            {
            return(return_code);
            }
          }    /* if user specified class */
        }      /* if intersect */
      key_p += 1;
      objid_p += 1;
      }
    }
  return(DB_CONTINUE);
  }





/******************** DB_lr_intersect_3d_dbl *********************/
/*----
     MODULE NAME:	DB_rtree_skewsrch_3d_dbl
 
     Abstract:		Skewscan is a method of selecting elements
			from an rtree by rejecting those elements
			that do not meet the criteria. 

     VALUE = DB_rtree_skewsrch_3d_dbl( range1, range2, sx, sy, sz, coordr )

     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
   range1       DB_3D_DBL_BOX           default range criteria
   range2       DB_3D_DBL_BOX           range of small cube moved along
					view vector to find non-intersecting
					elements which will be rejected
   sx		double			rate the cube moves in the x direction
   sy		double			rate the cube moves in the y direction
   sz		double			rate the cube moves in the z direction
   coordr	DB_3D_DBL_BOX		range of element

     MODULES INVOKED:	none

     CHANGE HISTORY:
	
     TLG created 1/86
----*/


int DB_lr_intersect_3d_dbl( range1, range2, sx, sy, sz, coordr )

	DB_3D_DBL_BOX *range1;
	DB_3D_DBL_BOX *range2;
	double        sx, sy, sz;
	DB_3D_DBL_BOX *coordr;

{

double dxlo, dxhi, dylo, dyhi, dzlo, dzhi;
double va1, va2, va3, va4, vb1, vb2, vb3, vb4, vc1, vc2, vc3, vc4;
double temp;

if ( ! DB_3D_BOX_INTERSECT( range1, coordr ) )
	return( FALSE );
else
    {

    dxlo = coordr->xmin - range2->xmax;
    dxhi = coordr->xmax - range2->xmin;
    dylo = coordr->ymin - range2->ymax;
    dyhi = coordr->ymax - range2->ymin;
    dzlo = coordr->zmin - range2->zmax;
    dzhi = coordr->zmax - range2->zmin;


    if ( sx < 0 )
	{
	temp = dxlo;
	dxlo = dxhi;
	dxhi = temp;
	}
    if ( sy < 0 )
	{
	temp = dylo;
	dylo = dyhi;
	dyhi = temp;
	}
    if ( sz < 0 )
	{
	temp = dzlo;
	dzlo = dzhi;
	dzhi = temp;
	}


    /* Test for intersection in the x-y plane */
 
    va1 = SIGN(sx) * dxlo * fabs(sy);
    vb2 = SIGN(sy) * dyhi * fabs(sx);
    
    if ( va1 > vb2 )
	return( FALSE );
	

    vb1 = SIGN(sy) * dylo * fabs(sx);
    va2 = SIGN(sx) * dxhi * fabs(sy);

    
    if ( va2 < vb1 )
	return( FALSE );
	

    /* Check for intersection in the x-z plane */
	
    va3 = SIGN(sx) * dxlo * fabs(sz);
    vc2 = SIGN(sz) * dzhi * fabs(sx);
	

    if ( va3 > vc2 )
        return( FALSE );
	   

    va4 = SIGN(sx) * dxhi * fabs(sz);
    vc1 = SIGN(sz) * dzlo * fabs(sx);


    if ( va4 < vc1 )
       	return( FALSE );
		

    /* Check for intersection in the y-z plane */

    vb3 = SIGN(sy) * dylo * fabs(sz);
    vc4 = SIGN(sz) * dzhi * fabs(sy);


    if ( vb3 > vc4 )
        return( FALSE );
	   

    vb4 = SIGN(sy) * dyhi * fabs(sz);
    vc3 = SIGN(sz) * dzlo * fabs(sy);
	    

    if ( vb4 < vc3 )
       	return( FALSE );
    }

return( TRUE );

}





/*********************** DB_rtree_delete_3d_dbl *******************/
/*  remove key entry (box) from leaf node in rtree  */

DB_rtree_delete_3d_dbl (root_page_p, box, find_criteria)

R_PAGE_3D_DBL *root_page_p;
R_PACKED_KEYENTRY_3D_DBL box;
int find_criteria;

{
int  i, j, key_notfound = TRUE;      
R_PATH_HISTORY path_history;
R_PAGE_3D_DBL *leaf_page_p;
R_PAGE_3D_DBL *nonleaf_page_p;
int mov_bytes, old_page_count;
OM_S_OBJID objid;
OM_S_RIP rip;



/* initialize path history */
path_history.Path_count = 0;
objid = REF(OM_S_OBJID, root_page_p);
if ( IF_EQ_OBJID(objid, NULL_OBJID) )
  {
  return(DB_E_NULLIDREF);
  }

path_history.Path_array[0].Child_page_objid = objid;
path_history.Path_array[0].Entry_number = 0;
      
/* search for key entry in rtree */  
if ((key_notfound = DB_rtree_findleaf_3d_dbl (&box, 
       	   &path_history, &leaf_page_p, find_criteria)) == TRUE)
  {
  /* leaf node index record of specified coordinates not found */

  return( DB_KEYNOTFOUND );
  }
else
  {
  /*  delete index record from leaf node, compact index records, adjust 
      key count  */
     
  i = path_history.Path_array[path_history.Path_count].Entry_number;
  j = leaf_page_p->Header.Key_count;

  if (j-i < 1)
    return(  DB_PATH_HISTORY_ERR  );   /* error in path_history */
  if (j-i > 1)  /* delete found key and compact keys by shifting left */
    { 
    leaf_page_p->Key[i] = leaf_page_p->Key[ leaf_page_p->Header.Key_count - 1];
    leaf_page_p->Objid[i] = leaf_page_p->Objid[ leaf_page_p->Header.Key_count - 1];
    }

  leaf_page_p->Header.Key_count = leaf_page_p->Header.Key_count - 1; 
  if ( leaf_page_p->Header.Page_type == R_LF_RT_PAGE )
    return( DB_SUCCESS );

  /* merge empty nodes */
  if ( (i = DB_rtree_condense_tree_3d_dbl(root_page_p, &path_history, &(box.Coordinates), leaf_page_p)) !=  DB_SUCCESS )
    {
    return(i);  
    }
  /* shorten tree if root node has only 1 child */
  if (root_page_p->Header.Page_type == R_NL_RT_PAGE)
    {
    if (root_page_p->Header.Key_count == 1)

      /*  write child into logical page 0 */
      {
      old_page_count = root_page_p->Header.Page_count;
      nonleaf_page_p = DEREF(R_PAGE_3D_DBL, root_page_p->Objid[0], rip);
      if (nonleaf_page_p == NULL)
        {
        return(DB_E_NULLDEREF);
        }

      DB_MOV_N_BYTES((char *)nonleaf_page_p, (char *)root_page_p, DB_BYTES_RPAGE);
      if (nonleaf_page_p->Header.Page_type == R_NL_NR_PAGE)
        {
        root_page_p->Header.Page_type = R_NL_RT_PAGE;
        }
      else
        {
        root_page_p->Header.Page_type = R_LF_RT_PAGE;
        }
      PUT_FREE_PAGE(nonleaf_page_p);
      root_page_p->Header.Page_count = old_page_count - 1;
      }   
    }
  return( DB_SUCCESS );
  }
}





/********************** DB_rtree_findleaf_3d_dbl ***********************/
DB_rtree_findleaf_3d_dbl( box_p, history_p, leaf_page_pp, find_criteria )

R_PACKED_KEYENTRY_3D_DBL *box_p;
R_PATH_HISTORY *history_p;
R_PAGE_3D_DBL **leaf_page_pp;
int find_criteria;

{
 register R_PAGE_3D_DBL *current_page_p;
 int current_entry_number;
 int key_notfound;
 int qualified_nl_mbr = FALSE, qualified_lf_mbr = FALSE;
 OM_S_OBJID objid;
 OM_S_RIP rip;



 current_page_p = DEREF(R_PAGE_3D_DBL, (history_p->Path_array[history_p->Path_count].Child_page_objid), rip);
 if (current_page_p == NULL)
   {
   return(DB_E_NULLDEREF);
   }

 key_notfound = TRUE; 
/* keep track of the entry_number being checked */
 current_entry_number = history_p->Path_array[history_p->
                                                 Path_count].Entry_number;
 if ( NOT_R_LEAF(current_page_p->Header.Page_type) )
   {
   while (current_entry_number < current_page_p->Header.Key_count)
     {
     if (find_criteria == 0)
       {
       qualified_nl_mbr = OVERLAP_3D(current_page_p->Key[current_entry_number], box_p->Coordinates);
       }
     else
       {
       qualified_nl_mbr = DB_3D_BOX_INTERSECT(&(current_page_p->Key[current_entry_number]), &(box_p->Coordinates));
       }
     if (qualified_nl_mbr)
       {
       current_page_p = DEREF(R_PAGE_3D_DBL, (current_page_p->Objid[current_entry_number]), rip);
       if (current_page_p == NULL)
         {
         return(DB_E_NULLDEREF);
         }

       history_p->Path_array[history_p->Path_count].Entry_number = 
						      current_entry_number;
       history_p->Path_count++;
       history_p->Path_array[history_p->Path_count].Entry_number = 0;
       objid = REF(OM_S_OBJID, current_page_p);
       if ( IF_EQ_OBJID(objid, NULL_OBJID) )
         {
         return(DB_E_NULLIDREF);
         }
       history_p->Path_array[history_p->Path_count].Child_page_objid = objid;
       key_notfound = DB_rtree_findleaf_3d_dbl( box_p, history_p,
					     leaf_page_pp, find_criteria );
       if (key_notfound)
         {
         key_notfound = TRUE;
	 (history_p->Path_count)--;
	 (history_p->Path_array[history_p->Path_count].Entry_number)++;
	 key_notfound = DB_rtree_findleaf_3d_dbl( box_p, history_p,
			                     leaf_page_pp, find_criteria );
         }
       return(key_notfound);
       }
     else
       {
       current_entry_number++;
       }
     }		/* while loop */
   return(key_notfound);
   } 
 else
   {
   for (current_entry_number = 0; current_entry_number < 
                 current_page_p->Header.Key_count; current_entry_number++)
     {
     if (find_criteria == 0)
       {
       qualified_lf_mbr = MATCH_3D(current_page_p->Key[current_entry_number], box_p->Coordinates);
       }
     else
       {
       qualified_lf_mbr = DB_3D_BOX_INTERSECT(&(current_page_p->Key[current_entry_number]), &(box_p->Coordinates));
       }       
     if (qualified_lf_mbr)
       {
       if ( IF_EQ_OBJID(box_p->Objid, current_page_p->Objid[current_entry_number]) )
         {
         key_notfound = FALSE;
	 history_p->Path_array[history_p->Path_count]
		              .Entry_number = current_entry_number;
         *leaf_page_pp = current_page_p;
	 return(key_notfound);
	 }
       }
     }		/* for loop */
   key_notfound = TRUE;
   return(key_notfound);
   }		/* leaf_page */
}





/************************* DB_rtree_condense_tree_3d_dbl *****************/
/* examine all parents of leaf node, saving all entries which shall be reinserted by another routine in rtree (entries in nodes reaching  m/2 emptiness) */

DB_rtree_condense_tree_3d_dbl(root_page_p, path_history_p, deleted_box_p, leaf_page_p)

R_PAGE_3D_DBL *root_page_p;
R_PATH_HISTORY *path_history_p;		 /* pathway to leaf node */
DB_3D_DBL_BOX *deleted_box_p;
R_PAGE_3D_DBL *leaf_page_p;

{
R_PAGE_3D_DBL *parent_page_p, *next_condense_page_p;
int i,j, E_OF_N, half_full_size;
R_REINSERT_SET_3D_DBL reinsert_set;
OM_S_RIP rip;



/* maximum emptiness allowed in nonleaf page */
half_full_size = R_MAX_KEYS_3D_DBL/2;

reinsert_set.Entry_count = 0;

path_history_p->Path_count --;
parent_page_p = DEREF(R_PAGE_3D_DBL, (path_history_p->Path_array[path_history_p->Path_count].Child_page_objid), rip);
if (parent_page_p == NULL)
  {
  return(DB_E_NULLDEREF);
  }

E_OF_N = path_history_p->Path_array[path_history_p->Path_count].Entry_number;

if ((leaf_page_p->Header.Key_count < half_full_size
     && root_page_p->Header.Filler_1 != RTREE_M_NOMERGE))
     || leaf_page_p->Header.Key_count == 0)
  {
  /* delete En from P,compact keys */

  j = parent_page_p->Header.Key_count;
  if (j - E_OF_N < 1)
     return(  DB_PATH_HISTORY_ERR  ); 	/* error in path_history */

  if (j - E_OF_N > 1)    
    {
    *deleted_box_p = parent_page_p->Key[E_OF_N];
    parent_page_p->Key[E_OF_N] = parent_page_p->Key[ parent_page_p->Header.Key_count - 1];
    parent_page_p->Objid[E_OF_N] = parent_page_p->Objid[ parent_page_p->Header.Key_count - 1];
    }	

  parent_page_p->Header.Key_count --; 		/* update key count */
 
  /* put all N entries in reinsert array */
  for (i=0; i < leaf_page_p->Header.Key_count; i++, reinsert_set.Entry_count++)
    { 
    reinsert_set.Reinsert_array[reinsert_set.Entry_count].Level = path_history_p->Path_count+1;
    reinsert_set.Reinsert_array[reinsert_set.Entry_count].Entry_type = LEAF;
    reinsert_set.Reinsert_array[reinsert_set.Entry_count].Reinsert_entry.Coordinates = leaf_page_p->Key[i];
    reinsert_set.Reinsert_array[reinsert_set.Entry_count].Reinsert_entry.Objid = leaf_page_p->Objid[i];
    }
  PUT_FREE_PAGE( leaf_page_p );
  (root_page_p->Header.Page_count)--;
  } /* end if */
else
  { 
  if ( IS_BORDER_OVERLAP_3D(parent_page_p->Key[E_OF_N], (*deleted_box_p)) )
    {
    /* set En coordinates to tightly contain all N entries */

    parent_page_p->Key[E_OF_N] = leaf_page_p->Key[0];
    for (i=1; i < leaf_page_p->Header.Key_count; i++)
      {
      TIGHT_CUBE(parent_page_p->Key[E_OF_N], leaf_page_p->Key[i]);
      }
    }
  }

/*  set N=P  */

next_condense_page_p = parent_page_p;

/* all other pages are nonleafs */
while (next_condense_page_p->Header.Page_type != R_NL_RT_PAGE)
  {
  path_history_p->Path_count --;
  parent_page_p = DEREF(R_PAGE_3D_DBL, (path_history_p->Path_array[path_history_p->Path_count].Child_page_objid), rip);
  if (parent_page_p == NULL)
    {
    return(DB_E_NULLDEREF);
    }

  E_OF_N = path_history_p->Path_array[path_history_p->Path_count].Entry_number;

  if ((next_condense_page_p->Header.Key_count < half_full_size
       && root_page_p->Header.Filler_1 != RTREE_M_NOMERGE)
       || next_condense_page_p->Header.Key_count == 0)

    /* if N is 'empty', delete En from P, compact keys */
    {
    j = parent_page_p->Header.Key_count;
    if (j - E_OF_N < 1)
      return(  DB_PATH_HISTORY_ERR  ); /* error in path_history, detected in db_rtree_condense_3d_dbl */
    if (j - E_OF_N > 1)    
      {
      parent_page_p->Key[E_OF_N] = parent_page_p->Key[parent_page_p->Header.Key_count -1 ];
      parent_page_p->Objid[E_OF_N] = parent_page_p->Objid[parent_page_p->Header.Key_count -1 ];
      }	
    parent_page_p->Header.Key_count --; /* update key count */

    /* put all N entries in reinsert array */
    if (reinsert_set.Entry_count + next_condense_page_p->Header.Key_count > 500)
      {
      return( DB_REINSERT_ARRAY_ERR); /* Reinsert array overflow */
      }
    for (i=0; i < next_condense_page_p->Header.Key_count; i++, reinsert_set.Entry_count++)
      { 
      reinsert_set.Reinsert_array[reinsert_set.Entry_count].Level = path_history_p->Path_count+1;
      reinsert_set.Reinsert_array[reinsert_set.Entry_count].Entry_type = NONLEAF;
      reinsert_set.Reinsert_array[reinsert_set.Entry_count].Reinsert_entry.Coordinates = next_condense_page_p->Key[i];
     reinsert_set.Reinsert_array[reinsert_set.Entry_count].Reinsert_entry.Objid = next_condense_page_p->Objid[i];
      }
    PUT_FREE_PAGE( next_condense_page_p );   	/* deallocate nonleaf page node */
    (root_page_p->Header.Page_count)--;
	
    } /* end if */
  else
    { 
    if ( IS_BORDER_OVERLAP_3D(parent_page_p->Key[E_OF_N], (*deleted_box_p)) )
      {
      /* set parent key's coordinates to tightly contain all N's entries */

      parent_page_p->Key[E_OF_N] = next_condense_page_p->Key[0];
      for (i = 1; i < next_condense_page_p->Header.Key_count; i++)
        {
        TIGHT_CUBE(parent_page_p->Key[E_OF_N], next_condense_page_p->Key[i]);
        }
      }
    }

  /*  set N=P  */
  next_condense_page_p = parent_page_p;
    
  }  /* end while loop */

if (reinsert_set.Entry_count > 0)
  {
  /* reinsert entries in tree */

  if ((i = DB_rtree_reinsert_3d_dbl( root_page_p, &reinsert_set )) !=  DB_SUCCESS )
    return(i);
  }
 return( DB_SUCCESS );

}





/************************ DB_rtree_deltree_3d_dbl ************************/
DB_rtree_deltree_3d_dbl( my_id, page_p )

OM_S_OBJID my_id;
R_PAGE_3D_DBL *page_p;
	
{
short i;
OM_S_OBJID tobj;
R_PAGE_3D_DBL *nl_page_p;
OM_S_RIP rip;
OM_p_OBJECTHDR p_object;
int sts;



if ( NOT_R_LEAF(page_p->Header.Page_type) )
  {
  for ( i = 0; i < page_p->Header.Key_count; i++ )
    {
    nl_page_p = DEREF(R_PAGE_3D_DBL, page_p->Objid[i], rip);
    if (nl_page_p == NULL)
      {
      return(DB_E_NULLDEREF);
      }

    DB_rtree_deltree_3d_dbl( my_id, nl_page_p);
    }

  tobj = REF( OM_S_OBJID, page_p );
  if ( IF_EQ_OBJID(tobj, NULL_OBJID) )
    {
    return(DB_E_NULLIDREF);
    }

  if ( ! IF_EQ_OBJID( my_id, tobj ) )
    {
    p_object = (OM_p_OBJECTHDR)((int)page_p - (int)sizeof(OM_S_OBJID) - (int)sizeof(int) - (int)sizeof(OM_S_OBJECTHDR));
    sts = om$delete_object(osnum=OM_Gw_current_OS, object=p_object, objid=tobj);
    if (!(sts&1))
      {
      om$report_error(sts=sts);
      exit();
      }
    }

  }
else			/* leaf page */
  {
  tobj = REF( OM_S_OBJID, page_p );
  if ( IF_EQ_OBJID(tobj, NULL_OBJID) )
    {
    return(DB_E_NULLIDREF);
    }

  if ( ! IF_EQ_OBJID( my_id, tobj ) )
    {
    p_object = (OM_p_OBJECTHDR)((int)page_p - (int)sizeof(OM_S_OBJID) - (int)sizeof(int) - (int)sizeof(OM_S_OBJECTHDR));
    sts = om$delete_object( osnum=OM_Gw_current_OS, object=p_object, objid=tobj );
    if (!(sts&1))
      {
      om$report_error(sts=sts);
      exit();
      }
    }
  }
}




/************************************************************************/
DB_rtree_get_status_3d_dbl(root_page_p, status_p)

R_PAGE_3D_DBL *root_page_p;
OM_p_RTREESTAT   status_p;

{
OM_S_RTREESTAT local_stat;
register R_PAGE_3D_DBL      *cur_page_p;
double l_xmin, l_ymin, l_zmin, h_xmax, h_ymax, h_zmax;
int tree_height = 0, level_index, page_index, rtn;
short i;
OM_S_RIP rip;



cur_page_p = root_page_p;
while ( NOT_R_LEAF(cur_page_p->Header.Page_type) )
  {
  (tree_height)++;
  cur_page_p = DEREF(R_PAGE_3D_DBL, (cur_page_p->Objid[0]), rip);
  if (cur_page_p == NULL)
    {
    return(DB_E_NULLDEREF);
    }
  }   /* while */
       
switch (status_p->request_type)
  {
  case RTREE_MISC_STATUS:
       status_p->rtree_status.misc.tree_type = root_page_p->Header.Rtree_type;
       status_p->rtree_status.misc.nl_maxkeys = R_MAX_KEYS_3D_DBL;
       status_p->rtree_status.misc.lf_maxkeys = R_MAX_KEYS_3D_DBL;
       status_p->rtree_status.misc.page_count = root_page_p->Header.Page_count;
       status_p->rtree_status.misc.tree_height = tree_height;
       return(DB_SUCCESS);

  case RTREE_LEVEL_STATUS:
       if (status_p->rtree_status.level.level_no > tree_height)
         {
         return (DB_E_LEVELGTTREEHI);
	 }
       else if (status_p->rtree_status.level.level_no == 0)
              {
              status_p->rtree_status.level.num_pages = 1;
              if ( IS_R_LEAF(root_page_p->Header.Page_type) )
	  	{
                status_p->rtree_status.level.level_type = RTREE_LF_LEVEL;
	        }
	      else
	        {
                status_p->rtree_status.level.level_type = RTREE_NL_LEVEL;
		}
	      return (DB_SUCCESS);
              }

       if ( status_p->rtree_status.level.level_no == tree_height )
         {
         status_p->rtree_status.level.level_type = RTREE_LF_LEVEL;
         }
       else
         {
         status_p->rtree_status.level.level_type = RTREE_NL_LEVEL;
         }

       status_p->rtree_status.level.num_pages = 0;
       level_index = status_p->rtree_status.level.level_no;
       if ((rtn = DB_rtree_getstatus_level_3d_dbl(
                  root_page_p, &level_index, status_p)) != DB_SUCCESS)
	 {
         return (rtn);
	 }
       return (DB_SUCCESS);

  case RTREE_PAGE_STATUS:
       if (status_p->rtree_status.page.level_no > tree_height)
         {
         return (DB_E_LEVELGTTREEHI);
	 }
       else if (status_p->rtree_status.page.level_no == 0)
              {
    	      l_xmin = root_page_p->Key[0].xmin;
	      l_ymin = root_page_p->Key[0].ymin;
	      l_zmin = root_page_p->Key[0].zmin;
	      h_xmax = root_page_p->Key[0].xmax;
	      h_ymax = root_page_p->Key[0].ymax;
	      h_zmax = root_page_p->Key[0].zmax;
	      for (i = 1; i < root_page_p->Header.Key_count; i++)
	        {
	        if (root_page_p->Key[i].xmin < l_xmin)
     	          l_xmin = root_page_p->Key[i].xmin;
	        if (root_page_p->Key[i].ymin < l_ymin)
	          l_ymin = root_page_p->Key[i].ymin;
	        if (root_page_p->Key[i].zmin < l_zmin)
	          l_zmin = root_page_p->Key[i].zmin;
	        if (root_page_p->Key[i].xmax > h_xmax)
	          h_xmax = root_page_p->Key[i].xmax;
	        if (root_page_p->Key[i].ymax > h_ymax)
	          h_ymax = root_page_p->Key[i].ymax;
	        if (root_page_p->Key[i].zmax > h_zmax)
	          h_zmax = root_page_p->Key[i].zmax;
	        }
             
              status_p->rtree_status.page.page_range.r3ddkey.xmin = l_xmin;
              status_p->rtree_status.page.page_range.r3ddkey.ymin = l_ymin;
              status_p->rtree_status.page.page_range.r3ddkey.zmin = l_zmin;
              status_p->rtree_status.page.page_range.r3ddkey.xmax = h_xmax;
              status_p->rtree_status.page.page_range.r3ddkey.ymax = h_ymax;
              status_p->rtree_status.page.page_range.r3ddkey.zmax = h_zmax;
              status_p->rtree_status.page.num_keys = root_page_p->Header.Key_count;
              return (DB_SUCCESS);
              }
 
       level_index = status_p->rtree_status.page.level_no;
       local_stat.rtree_status.level.level_no = level_index ;
       local_stat.rtree_status.level.num_pages = 0 ;
       if ((rtn = DB_rtree_getstatus_level_3d_dbl(
              root_page_p, &level_index, &local_stat)) != DB_SUCCESS)
	 {
         return (rtn);
	 }

       if (status_p->rtree_status.page.page_no > (local_stat.rtree_status.level.num_pages - 1))
         {
  	 return (DB_E_NOSUCHPAGE);
	 }

       level_index = status_p->rtree_status.page.level_no;
       page_index = -1;
       if ((rtn = DB_rtree_getstatus_page_3d_dbl(root_page_p,
     	          &level_index, &page_index, status_p)) != DB_SUCCESS)
	 {
         return (rtn);
	 }
       return (DB_SUCCESS);

  default:
       return ( DB_E_BADREQTYPE );   
  }
}



/******************* DB_rtree_getstatus_level_3d_dbl ******************/
DB_rtree_getstatus_level_3d_dbl(page_p, level_index_p, stat_p)

R_PAGE_3D_DBL *page_p;
int *level_index_p;
OM_p_RTREESTAT stat_p;

{
short i;
R_PAGE_3D_DBL *nl_page_p;
OM_S_RIP rip;



if (*level_index_p != 1)
  {
  for ( i = 0; i < page_p->Header.Key_count; i++ )
    {
    nl_page_p = DEREF(R_PAGE_3D_DBL, page_p->Objid[i], rip);
    if (nl_page_p == NULL)
      {
      return(DB_E_NULLDEREF);
      }
    (*level_index_p)--;
    DB_rtree_getstatus_level_3d_dbl(nl_page_p, level_index_p, stat_p);
    }
  (*level_index_p)++;
  }
else
  {
  (stat_p->rtree_status.level.num_pages) += page_p->Header.Key_count;
  (*level_index_p)++;
  }
return(DB_SUCCESS);
}



/****************** DB_rtree_getstatus_page_3d_dbl *******************/
DB_rtree_getstatus_page_3d_dbl(page_p, level_index_p, page_index_p, stat_p)

R_PAGE_3D_DBL *page_p;
int *level_index_p, *page_index_p;
OM_p_RTREESTAT stat_p;

{
R_PAGE_3D_DBL *local_page_p;
short i;
int rtn;
OM_S_RIP rip;



if (*level_index_p != 0)
  {
  for ( i = 0; i < page_p->Header.Key_count; i++ )
    {
    local_page_p = DEREF(R_PAGE_3D_DBL, page_p->Objid[i], rip);
    if (local_page_p == NULL)
      {
      return(DB_E_NULLDEREF);
      }

    (*level_index_p)--;
    rtn = DB_rtree_getstatus_page_3d_dbl(local_page_p, level_index_p, page_index_p, stat_p);

    if (rtn == DB_CONTINUE)
      {
      if (*page_index_p == stat_p->rtree_status.page.page_no)
        {
        stat_p->rtree_status.page.num_keys = local_page_p->Header.Key_count;
        stat_p->rtree_status.page.page_range.r3ddkey = page_p->Key[i];
        return (DB_SUCCESS); 
        }
      }
    }
  (*level_index_p)++;
  return (DB_SUCCESS);
  }
else
  {
  (*page_index_p)++;
  (*level_index_p)++;
  return (DB_CONTINUE);
  }
}




/****************** DB_rtree_replace_3d_dbl *******************/
DB_rtree_replace_3d_dbl(root_page_p, keyentry, dim, new_keys, new_objids)

R_PAGE_3D_DBL     *root_page_p;
R_PACKED_KEYENTRY_3D_DBL keyentry;
int 		  dim;
OM_p_KEY_DESC     new_keys;
OM_p_OBJID	  new_objids;

{
int  i, j, key_notfound = TRUE;      
R_PATH_HISTORY path_history;
R_PAGE_3D_DBL *leaf_page_p, *parent_page_p;
OM_S_OBJID objid;
OM_S_RIP rip;
OM_S_KEY_ENTRY new_entry;
int rtn, entry_n_parent;



/* initialize path history */
path_history.Path_count = 0;
objid = REF(OM_S_OBJID, root_page_p);
if ( IF_EQ_OBJID(objid, NULL_OBJID) )
  {
  return(DB_E_NULLIDREF);
  }

path_history.Path_array[0].Child_page_objid = objid;
path_history.Path_array[0].Entry_number = 0;
      
/* search for key entry in rtree */  
if ((key_notfound = DB_rtree_findleaf_3d_dbl(&keyentry, 
         	        &path_history, &leaf_page_p, 0)) == TRUE)
  {
  return( DB_KEYNOTFOUND );
  }
else
  {
  j = path_history.Path_array[path_history.Path_count].Entry_number;
  if (path_history.Path_count == 0)
    {
    i = 0;
    do
      {
      if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type,
                  &new_keys[i], &new_objids[i], &new_entry)) != DB_SUCCESS)
        {
        return(rtn);
        }

      if (i == 0)
        {
        leaf_page_p->Key[j] = new_entry.r3ddkey.Coordinates;
        leaf_page_p->Objid[j] = new_entry.r3ddkey.Objid;
        }
      else
        {
        leaf_page_p->Key[leaf_page_p->Header.Key_count] = new_entry.r3ddkey.Coordinates;
        leaf_page_p->Objid[leaf_page_p->Header.Key_count++] = new_entry.r3ddkey.Objid;
        }
      i = i + 1;          
      }
    while(i < dim && leaf_page_p->Header.Key_count < R_MAX_KEYS_3D_DBL);

    while (i < dim)
      {
      if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type,
                  &new_keys[i], &new_objids[i], &new_entry)) != DB_SUCCESS)
        {
        return(rtn);
        }
     
      if ((rtn = DB_rtree_insert_3d_dbl(root_page_p, new_entry.r3ddkey)) != DB_SUCCESS)
        {
	return(rtn);
	}
      i = i + 1;
      }
    }
  else
    {
    path_history.Path_count --;
    parent_page_p = DEREF(R_PAGE_3D_DBL, (path_history.Path_array[path_history.Path_count].Child_page_objid), rip);
    if (parent_page_p == NULL)
      {
      return(DB_E_NULLDEREF);
      }
    entry_n_parent = path_history.Path_array[path_history.Path_count].Entry_number;

    if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type,
                &new_keys[0], &new_objids[0], &new_entry)) != DB_SUCCESS)
      {
      return(rtn);
      }
    if ( OVERLAP_3D(parent_page_p->Key[entry_n_parent], new_entry.r3ddkey.Coordinates) ) 
      {
      leaf_page_p->Key[j] = new_entry.r3ddkey.Coordinates;
      leaf_page_p->Objid[j] = new_entry.r3ddkey.Objid;
      for (i = 1; i < dim; i++)
        {
        if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type,
                  &new_keys[i], &new_objids[i], &new_entry)) != DB_SUCCESS)
          {
          return(rtn);
          }

        if ( (OVERLAP_3D(parent_page_p->Key[entry_n_parent], new_entry.r3ddkey.Coordinates)) && leaf_page_p->Header.Key_count < R_MAX_KEYS_3D_DBL )
          {
          leaf_page_p->Key[leaf_page_p->Header.Key_count] = new_entry.r3ddkey.Coordinates;
          leaf_page_p->Objid[leaf_page_p->Header.Key_count++] = new_entry.r3ddkey.Objid;
          }
        else
          {
          break;
          }
        }

      while (i < dim)
        {
        if ((rtn = DB_rtree_insert_3d_dbl(root_page_p, new_entry.r3ddkey)) != DB_SUCCESS)
          {
  	  return(rtn);
  	  }
        i = i + 1;
        if (i < dim)
          {
          if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type,
                  &new_keys[i], &new_objids[i], &new_entry)) != DB_SUCCESS)
            {
            return(rtn);
            }
          }
        }
      }
    else
      {
      if ((rtn = DB_rtree_delete_3d_dbl(root_page_p, keyentry, 0)) != DB_SUCCESS)
        {
        return(rtn);
        }
      if ((rtn = DB_rtree_insert_3d_dbl(root_page_p, new_entry.r3ddkey)) != DB_SUCCESS)
        {
        return(rtn);
        }
      for (i = 1; i < dim; i++)
        {
        if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type,
                  &new_keys[i], &new_objids[i], &new_entry)) != DB_SUCCESS)
          {
          return(rtn);
          }
        if ((rtn = DB_rtree_insert_3d_dbl(root_page_p, new_entry.r3ddkey)) != DB_SUCCESS)
          {
  	  return(rtn);
          }
        }
      }

    }
  }

return(DB_SUCCESS);
}




/********************** DB_rtree_seed_3d_dbl ***********************/
DB_rtree_seed_3d_dbl( root_page_p, new_entry )

R_PAGE_3D_DBL *root_page_p;
R_PACKED_KEYENTRY_3D_DBL   new_entry;

{
int              status;
R_PATH_HISTORY   insert_path;
R_PAGE_3D_DBL    *leaf_page_p, *new_page_p, *p_empty_page;
DB_3D_DBL_BOX    old_page_coord, new_page_coord;
OM_S_OBJID       objid;
OM_S_RIP rip;



GET_FREE_PAGE(R_PAGE_3D_DBL, p_empty_page, "OMrtree", rip);
if ( p_empty_page == NULL )
  return ( DB_E_GETPAGEFAIL);
new_entry.Objid = REF(OM_S_OBJID, p_empty_page);
if ( IF_EQ_OBJID(new_entry.Objid,  NULL_OBJID) )
  return(DB_E_NULLIDREF);

(root_page_p->Header.Page_count)++;
p_empty_page->Header.Page_type = R_LF_NR_PAGE;
p_empty_page->Header.Rtree_type = root_page_p->Header.Rtree_type;
p_empty_page->Header.Key_count = 0;

new_page_p = NULL;
status = DB_rtree_choose_leaf_3d_dbl( root_page_p, &new_entry, &leaf_page_p, &insert_path );   
if (status !=  DB_SUCCESS )return( status );

if (insert_path.Path_count > 0)
  {
  --insert_path.Path_count;
  objid = insert_path.Path_array[insert_path.Path_count].Child_page_objid;
  leaf_page_p = DEREF(R_PAGE_3D_DBL,  objid,  rip);
  if (leaf_page_p == NULL)
    return(DB_E_NULLDEREF);
  }

/* The root page type will become R_NL_RT_PAGE once seeded */
if (root_page_p->Header.Key_count == 0)
  root_page_p->Header.Page_type = R_NL_RT_PAGE;

if ( leaf_page_p->Header.Key_count < R_MAX_KEYS_3D_DBL )
  {
  leaf_page_p->Key[leaf_page_p->Header.Key_count] = new_entry.Coordinates;
  leaf_page_p->Objid[leaf_page_p->Header.Key_count++] = new_entry.Objid;
  }
else
  {
  GET_FREE_PAGE(R_PAGE_3D_DBL, new_page_p, "OMrtree", rip);
  if ( new_page_p == NULL )
    return ( DB_E_GETPAGEFAIL);
 
  (root_page_p->Header.Page_count)++;

  status = DB_rtree_split_page_3d_dbl(&new_entry, &leaf_page_p,
			        &old_page_coord, &new_page_coord, &new_page_p);
  if (status !=  DB_SUCCESS )return( status );
  }

if ( NOT_R_ROOT( leaf_page_p->Header.Page_type ) )
  {
  status = DB_rtree_adjust_tree_3d_dbl(&insert_path, &(new_entry.Coordinates), &old_page_coord, &new_page_coord, &new_page_p, &root_page_p);
  if (status !=  DB_SUCCESS )return( status );
  }
else
  {
  root_page_p = (R_PAGE_3D_DBL *)leaf_page_p;
  }
if ( new_page_p != NULL )
  {
  /* root was split */

  status = DB_rtree_make_root_3d_dbl ( root_page_p, old_page_coord,
					 new_page_coord, new_page_p );
  if (status !=  DB_SUCCESS )return( status );
  }
return (  DB_SUCCESS  );
}



/********************* DB_rtree_find_key_3d_dbl **********************/

DB_rtree_find_key_3d_dbl(page_p, p_sear_range, p_myobjid, p_mykey)

R_PAGE_3D_DBL 		 *page_p;
R_PACKED_KEYENTRY_3D_DBL *p_sear_range;
OM_p_OBJID    		 p_myobjid;
OM_p_KEY_DESC 		 p_mykey;

{
 short 		i;
 OM_S_OBJID 	tobj;
 R_PAGE_3D_DBL  *nl_page_p;
 OM_S_RIP 	rip;
 DB_3D_DBL_BOX  *key_p;
 OM_p_OBJID     objid_p;
 int 		sts, qualified=FALSE;



 if ( NOT_R_LEAF(page_p->Header.Page_type) ){
   for ( i=0; i<page_p->Header.Key_count; i++ ){
     if (p_sear_range)
       qualified = (DB_3D_BOX_INTERSECT(&(page_p->Key[i]), &(p_sear_range->Coordinates)));
     else
       qualified = TRUE;

     if (qualified){
       nl_page_p = DEREF(R_PAGE_3D_DBL, page_p->Objid[i], rip);
       if (nl_page_p == NULL)	return(DB_E_NULLDEREF);
       sts = DB_rtree_find_key_3d_dbl(nl_page_p, p_sear_range, p_myobjid, p_mykey);
       if (sts == DB_TERMINATE) return(sts);
     }
   }	/* for loop */
   return(DB_KEYNOTFOUND);
 }
 else{                  /* leaf page */
   objid_p = page_p->Objid;
   key_p = page_p->Key;
   for (i = 0; i < page_p->Header.Key_count; i++, key_p++, objid_p++){
     if (IF_EQ_OBJID(*p_myobjid, *objid_p)){
       p_mykey->type = KEY_3D_DBL;
       *(p_mykey->key.p_3ddbl) = *key_p;
       return(DB_TERMINATE);
     }
   }	/* for */
 }

 return(DB_CONTINUE);
}
