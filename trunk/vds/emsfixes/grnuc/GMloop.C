/* $Id: GMloop.C,v 1.3 2001/01/13 00:23:11 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc / GMloop.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GMloop.C,v $
 *	Revision 1.3  2001/01/13 00:23:11  hans
 *	SP16 modifications
 *	
 *	Revision 1.2  2001/01/13 00:05:23  hans
 *	SP16 modifications
 *
 * Revision 1.1  2000/05/24  14:23:40  pinnacle
 * Created: vds/emsfixes/grnuc/GMloop.C by jwfrosch for Service Pack
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      05/24/2000      HF              Modifications for TR 179901132 179901121
 *                                                           179901116 179901102
 *                                                           179900909
 *                                      GraphManager entering infinite recursive loop
 * -------------------------------------------------------------------*/

#include <sys/types.h>
#include <stdio.h>
#include <alloca.h>
#include "OMminimum.h"
#include "EXgrid.h"
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "igrtypedef.h"

#define  VD_DEBUG
#include "VDdebug.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function GMget_loop_elmts                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_loop_elmts(p_object, p_graph, pl_object, p_count)

  struct GRid    *p_object;  /* IN     Object to test the loops               */
  struct GMgraph *p_graph;   /* IN     Graph which contain the loop           */
  struct GRid    **pl_object;/* IN/OUT List of the loop objects               */
  int             *p_count;  /* OUT    Number of loop objects                 */
  /*
  Description : Returns the elements belonging to the same loop as an object.
                The loops are "strong components" that can include several
                nested loops.
  */
  /*.GMget_loop_elmts*/
{
  struct GMgraph   tmp_graph;  /* Temporary graph to get the loops            */
  int              nb_elmt;    /* Number of objects in the loop               */
  struct GMelmt    *p_content; /* Content of a temporary graph element        */
  struct GMhcode   *p_hcode;   /* Pointer to the hcode table for the graph    */
  static struct GRid *l_obj=0; /* list of the indexes in the hcode            */
  static int       s_lobj = 0; /* Size of the list of indexes                 */
  IGRushort        *l_index=0; /* List of indexes for loop objects            */
  int status=GM_I_NEG_RESPONSE;/* Status returned by functions                */
  int              ind;        /* Index for a loop                            */
  int exception_type = NULL;   /* Type of exception if degraded mode          */
  extern int GMget_anc_loop(); /* Function to get the loop ancestors          */

  if(GMh_give_content(p_object,p_graph->p_hcode,&p_content,NULL)
     &&(p_content->int_attr & GM_LOOP))
  {
    /*| Initialize the temporay graph */

    nb_elmt = p_graph->nb_elmt;
    status = GMinit_graph(nb_elmt, nb_elmt, nb_elmt, &tmp_graph);
    gm$status();

    /*| Get the loop list */

    tmp_graph.f_get_suc = GMget_anc_loop;
    tmp_graph.p_arg_suc = (char *)p_graph;
    status = GMget_suc_gr(p_object,1,0,0,&tmp_graph,0);
    gm$status(type = EXCEPTION_1);

    /*| Get loop graph elements */

    p_hcode = tmp_graph.p_hcode;
    status = GMh_getlist(p_hcode, NULL, NULL, &l_index, p_count);
    gm$status(type = EXCEPTION_1);

    if(pl_object && (*p_count))
    {
      /*| Have to fill the list */

      if(!(*pl_object))
      {
        /*| The list is not given by the caller */

        status = GMajust_buf(*p_count*sizeof(struct GRid),&l_obj,&s_lobj);
        gm$status(type = EXCEPTION_1);
        *pl_object = l_obj;
      }/* if(!*pl_object)*/

      for(ind=0; ind<*p_count; ind++)
        (*pl_object)[ind] = *((struct GRid *)GMh_key(p_hcode,l_index[ind]));
    }/* if(pl_object)*/

    GMremove_graph(&tmp_graph);
  }
  else
  {
    /*| This element is not in a loop */

    if(p_count) *p_count = 0;
  }/* if */

 exception:
  if(exception_type == EXCEPTION_1) GMremove_graph(&tmp_graph);
  return(status);
}/* GMget_loop_elmts */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function GMfind_loop                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMfind_loop(p_object, p_graph, p_response)

  struct GRid    *p_object;  /* IN     Object to test the loops               */
  struct GMgraph *p_graph;   /* IN     Graph which contain the loop           */
  int            *p_response;/* OUT    response of the function               */
  /*
  Description : Return TRUE if the object *p_object have his successors which
                are also ancestors. In this case mark all the objects of the
                loop(s) by the type GM_LOOP.
  */
  /*.GMfind_loop*/
{
  struct GMgraph   tmp_graph;  /* Temporary graph to get the loops            */
  int              status;     /* Status returned by functions                */
  struct GRid      *p_obj;     /* Temporary object                            */
  IGRushort        *l_index=0; /* List of indexes for loop objects            */
  IGRushort        object_ind; /* Index of the beginning of the loop          */
  struct GMelmt    *p_content; /* Content of a temporary graph element        */
  int              ind;        /* Index for a loop                            */
  int              nb_loop_el=0; /* Number of loop elements                   */
  int        GMget_anc_ingr(); /* Function to get the ancestors               */
  int exception_type = NULL;   /* Type of exception if degraded mode          */
  int recurse_lvl = 0;         /* To mark nodes in the Trajan algorithm       */
  int children_min_level;
  *p_response = FALSE;

  /*| Get the loop list */
  status = GMinit_graph(p_graph->nb_elmt, p_graph->nb_elmt, p_graph->nb_elmt, &tmp_graph);
  gm$status();

  tmp_graph.f_get_anc = GMget_anc_ingr;
  tmp_graph.p_arg_anc = (char *)p_graph;

  status = GMdepth_first(&tmp_graph,p_object,&recurse_lvl,&nb_loop_el,&children_min_level);
  gm$status(type = EXCEPTION_1);

  GMremove_graph(&tmp_graph);
  *p_response = (nb_loop_el > 0);

 exception:
  if(exception_type == EXCEPTION_1) GMremove_graph(&tmp_graph);
  return(status);
}/* GMfind_loop */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function GMdepth_first                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMdepth_first(p_graph, p_object, recurse_lvl, nb_loop_el, returned_min_level)

  struct GMgraph    *p_graph;     /* IN     Pointer to the graph               */
  struct GRid       *p_object;    /* IN     Pointer to the object to expand    */
  long              *recurse_lvl; /* IN/OUT Counter of recursion               */
  int               *nb_loop_el;  /* IN/OUT Nb of elements detected in the loops  */
  int               *returned_min_level;
  /*
  Description : Do a depth first research in a non directed graph
  Constraint  : The graph must be allocated before
  */
  /*.GMdepth_first*/
{
  int         status = GM_S_SUCCESS; /* Return code of the function               */
  int         in_graph;              /* Flag = TRUE if the object is in the Graph */
  struct GMelmt attribute;           /* Attribute stored in the list              */
  struct GMelmt *p_attribute = NULL; /* Pointer to an attribute                   */
  struct GMelmt *p_attr_in_initial_graph;
  struct GMelmt *p_attr_in_secondary_graph;
  int         index, index1;         /* Index for a loop                          */
  struct GRid *l_connex=NULL,
              *l_connex1 = NULL;     /* List of the connexions                    */
  int         nb_connex=0,
              nb_connex1= 0;         /* Number of connexions in the list          */

  struct GRid* p_object_in_loop;
  int         found;
  int  children_min_level,
       child_level;

  static int  total;

  __enterFunction ( name = "GMdepth_first", argfmt = "recurse_lvl = %d, total = %d, p_object = [%d,%d]",
                    args = `*recurse_lvl, ++total, p_object->osnum,p_object->objid` );

  in_graph = GMh_give_content(p_object,p_graph->p_hcode,&p_attribute,NULL);

  if(in_graph)
  {
    if (p_attribute->state < GM_UNKNOWN)
    {
      // Element investigated but still active
      // --> Mark it as a potential candidate for the status of "head of non singleton strong component"
      __printf("[%d,%d] found in graph with level %d --> potential candidate for loop", `p_object->osnum, p_object->objid,p_attribute->state`);
      p_attribute->int_attr |= GM_LOOP;
    }
    else
    {
      // The element and all the elements part of the same string component have been already investigated
      __printf("[%d,%d] totally investigated already", `p_object->osnum, p_object->objid`);
    }
    children_min_level = p_attribute->state;
  }
  else
  {
    /* This element has not been investigated yet. Add it to the graph and recurse */
    attribute.int_attr = 0;
    attribute.state = *recurse_lvl;
    children_min_level = (*recurse_lvl)++;
    __printf("Add [%d,%d] in the recursive search with level %d, and recurse on ancestors", `p_object->osnum, p_object->objid,attribute.state`);
    status = GMh_add(p_object,&attribute,p_graph->p_hcode);
    gm$status();

    status = p_graph->f_get_anc(p_object,p_graph->p_arg_anc,NULL,&nb_connex);
    if(!status) nb_connex =0;

    if(nb_connex)
    {
      l_connex = (struct GRid *)malloc( nb_connex * sizeof(struct GRid));
      if(!l_connex){status = GM_E_NODYNMEM; gm$status();}
      status = p_graph->f_get_anc(p_object,p_graph->p_arg_anc,&l_connex,&nb_connex);
      gm$status();

      for(index=0; index < nb_connex; index++)
      {
        /*"Expand %d.%d\n",l_connex[index].objid,l_connex[index].osnum*/
        found = GMh_give_content( &l_connex[index],
                                  ((struct GMgraph *) p_graph->p_arg_anc)->p_hcode,
                                  &p_attr_in_initial_graph,
                                  NULL );
        if(!found)
        {
          __printf("Programming error,%d %d should be found in initial graph!!!",`l_connex[index].objid,l_connex[index].osnum`);
        }
        else if(p_attr_in_initial_graph->state !=   GM_UNKNOWN)
        {
          __printf("Skipping l_connex[%d] = [%d,%d] (already ordered)", `index, l_connex[index].osnum, l_connex[index].objid`);
        }
        else
        {
          /* recusion on that element */
          status = GMdepth_first(p_graph,&l_connex[index],recurse_lvl,nb_loop_el,&child_level);
          if(children_min_level > child_level)  children_min_level = child_level;
        }
      }/* for */
    }

    // The complete dependency of the element has been investigated.
    // Is the element head of a "strong component"
    found = GMh_give_content(p_object,p_graph->p_hcode,&p_attribute,NULL);
    if(children_min_level == p_attribute->state)
    {
      if(!(p_attribute->int_attr & GM_LOOP))
      {
        /* Just skip strong components that are singleton */
        p_attribute->state = GM_UNKNOWN;
        __printf("[%d %d] is not in LOOP",`p_object->osnum,p_object->objid`);
      }
      else
      {
         /*
         - Only report a loop to the primary graph if all the inputs of the elements in the loop are
           either already ordered or in the loop themselve.  This make sure we break loop L1 first
           in the case of loop L2 succeeding loop L1
         - Desactivate all the elements of that strong component
         */
        IGRboolean first_level_loop = TRUE;
        __printf("[%d %d] level %d is head of a strong component",`p_object->osnum,p_object->objid,p_attribute->state`);
        for ( index=0; index<p_graph->p_hcode->cur_elmt && first_level_loop; index++ )
        {
          p_attribute = (struct GMelmt *) GMh_content(p_graph->p_hcode,index);
          if(p_attribute->state >= children_min_level)
          {
            p_object_in_loop = (struct GRid *) GMh_key(p_graph->p_hcode,index);
            status = p_graph->f_get_anc(p_object_in_loop,p_graph->p_arg_anc,NULL,&nb_connex1);
            if(!status) nb_connex1 =0;

            if(nb_connex1)
            {
              l_connex1 = (struct GRid *)malloc( nb_connex1 * sizeof(struct GRid));
              if(!l_connex1){status = GM_E_NODYNMEM; gm$status();}
              status = p_graph->f_get_anc(p_object_in_loop,p_graph->p_arg_anc,&l_connex1,&nb_connex1);
              gm$status();

              for(index1=0; index1 < nb_connex1 && first_level_loop; index1++)
              {
                found = GMh_give_content( &l_connex1[index1],
                                          ((struct GMgraph *) p_graph->p_arg_anc)->p_hcode,
                                          &p_attr_in_initial_graph,
                                          NULL );
                if(!found)
                {
                  __printf("Programming error,%d %d should be found in initial graph!!!",`l_connex1[index].objid,l_connex1[index].osnum`);
                  first_level_loop = FALSE;
                }
                else if(p_attr_in_initial_graph->state == GM_UNKNOWN)
                {
                  found = GMh_give_content( &l_connex1[index1],
                                            p_graph->p_hcode,
                                            &p_attr_in_secondary_graph,
                                            NULL );
                  if(!found)
                  {
                    __printf("Programming error,%d %d should be found in secondary graph!!!",`l_connex1[index].objid,l_connex1[index].osnum`);
                    first_level_loop = FALSE;
                  }
                  if(   p_attr_in_secondary_graph->state <  children_min_level
                        || p_attr_in_secondary_graph->state == GM_UNKNOWN) first_level_loop = FALSE;
                }
              }
              if ( l_connex1 ) {free ( l_connex1 ); l_connex1 = NULL;}
            }
          }
        }

        for ( index1=0; index1<p_graph->p_hcode->cur_elmt; index1++ )
        {
          p_attr_in_secondary_graph = (struct GMelmt *) GMh_content(p_graph->p_hcode,index1);
          if(p_attr_in_secondary_graph->state >= children_min_level && p_attr_in_secondary_graph->state != GM_UNKNOWN)
          {
            p_object_in_loop = (struct GRid *) GMh_key(p_graph->p_hcode,index1);
            p_attr_in_secondary_graph->state = GM_UNKNOWN;
            if(first_level_loop)
            {
              found = GMh_give_content( p_object_in_loop,
                                        ((struct GMgraph *) p_graph->p_arg_anc)->p_hcode,
                                        &p_attr_in_initial_graph,
                                        NULL );
              if(!found)
              {
                __printf("Programming error,%d %d should be found in initial graph!!!",`l_connex1[index].objid,l_connex1[index].osnum`);
              }
              else
              {
                __printf("Marking [%d %d] IN LOOP of first level",`p_object_in_loop->osnum,p_object_in_loop->objid`);
                *nb_loop_el += 1;
                p_attr_in_initial_graph->int_attr |= GM_LOOP;
              }
            }
            else
            {
              __printf("[%d %d] is in a loop, but not first level --> ignored",`p_object_in_loop->osnum,p_object_in_loop->objid`);
            }
          }
        }
      }
    }
    else
    {
      __printf("[%d %d] belongs to a strong component (but is not its head)",`p_object->osnum,p_object->objid`);
    }
  }
exception:

  if ( l_connex ) {free ( l_connex ); l_connex = NULL;}
  __exitFunction  ( name = "GMdepth_first", argfmt = "[%d,%d], level %d, children_min_level %d",
                    args = `p_object->osnum,p_object->objid, p_attribute->state, children_min_level` );
  *returned_min_level = children_min_level;
  return(status);
}/* GMdepth_first */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       INTERNAL function GMget_anc_loop                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

GMget_anc_loop(p_object, p_graph, pl_object, p_count)

  struct GRid    *p_object;   /* IN     Object to update                      */
  struct GMgraph *p_graph;    /* IN     Pointer to the graph                  */
  struct GRid    **pl_object; /* IN/OUT List of the ancestors objects         */
  int            *p_count;    /* OUT    Number of ancestor objects            */

  /*.GMget_anc_loop*/
{
  /*
    Description : Returns the ancestor list of an object in a graph wich are also
    in a loop.(List of ancestors stored in the graph for this
    object with GM_LOOP attribute).
    Constraint  : The graph must be allocated before.
  */
  int            ind0;         /* Index for a loop                            */
  int            ind1;         /* Index for a loop                            */
  int            status;       /* Returned status of the function             */
  struct GMelmt  *p_content;   /* Content of a temporary graph element        */
  struct GRid    *l_connex=0;  /* List of the connexions                      */

  status = GMget_anc_ingr(p_object, p_graph, &l_connex, p_count);
  gm$status();

  if((pl_object)&&(*pl_object))
  {
    /*| Fill the argument list */

    for(ind0=ind1=0; ind0 < *p_count; ind0++)
    {
      if(GMh_give_content(&(l_connex[ind0]),p_graph->p_hcode,&p_content,NULL)
         &&(p_content->int_attr & GM_LOOP))

        (*pl_object)[ind1++] = l_connex[ind0];
    }/* for(ind0)*/
    *p_count = ind1;
  }
  else
  {
    if(pl_object) *pl_object = l_connex;

    /*| Update the buffer */

    for(ind0=0; ind0 < *p_count;)
    {
      if(GMh_give_content(&(l_connex[ind0]),p_graph->p_hcode,&p_content,NULL)
         &&(!(p_content->int_attr & GM_LOOP)))
      {
        /*| This object is not a loop , remove it */

        (*p_count)--;
        for(ind1=ind0; ind1<*p_count; ind1++) l_connex[ind1]=l_connex[ind1+1];
      }
      else ind0++;
    }/* for(ind0)*/
  }/*if(pl_object)*/

 exception:
  return(status);
}/* GMget_anc_loop*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
