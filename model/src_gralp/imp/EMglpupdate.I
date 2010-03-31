/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/*
Notes
History:
  11-APR-91  JJC  Genesis
  18 Feb 92  AIC  Add support for MSCs (storekey, storeid)
  03 Oct 92  msm  ANSI-C conversion.
  02 Nov 92 Jack  Added a temporary fix to avoid reusing old part edges.

*/
class implementation EMSgraloop;

#include "emsdef.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "madef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "emstplydel.h"
#include "emsimpdef.h"
#include "EMSopt.h"
#include "EMSfrtdef.h"
#include "EMSprop.h"

#define MAX_NEW_EDGES           20
#define EDGE_INC                10

from EMSedge     import EMtrimyourself, 
                        EMget_props_type,
                        EMset_props,
                        EMget_bottom_edge;
from EMSpartedge import EMpeinit,
                        EMputbounds;
from EMSsubbs    import EMpartolbasis;


extern OMuword OPP_EMSpartedge_class_id;


method EMupdate_feature( IGRlong   *EMmsg;
                         IGRshort  *matrix_type;
                         IGRmatrix  matrix )

{
  IGRint                edge_num_bdrys, 
                        edge_count = 0,
                        ptedge_count = 0,
                        sv_ptedge_count = 0,
                        balance = 0, 
                        i, 
                        k;
  OMuint                count,
                        loopcount;
  IGRlong               sts;
  IGRshort              option;
  IGRdouble             parametric_tolerance;
  IGRboolean            in_area = FALSE, 
                        in_hole = FALSE, 
                        intersect, 
                        world = TRUE,
                        dup,
                        mal_edge = FALSE,
                        mal_ptedge = FALSE,
                        mal_chan = FALSE;
  GRobjid               bottom_edge,
                        loopset,
                        edges[MAX_NEW_EDGES],
                       *edge_ptr=NULL,
                        ptedges[MAX_NEW_EDGES],
                       *ptedgeptr=NULL,
                        new_edges[MAX_NEW_EDGES], 
                       *new_edge_ptr, 
                       *new_edge_buf;
  IGRuchar      edge_curve_type;
  IGRushort     trim_options = EMS_INTER_NO_MOREPRECISE |
                                       EMS_INTER_PROCOVERLAP |
                                       EMS_INTER_BDRYISAREA, 
                        props,
                        edge_props;
  struct EMSpartolbasis partolbasis;
  struct EMSsfintedpar *edge_bdrys, 
                       *ele_bdrys;
  OM_S_CHANSELECT       to_comps, 
                        to_loopset,
                        to_request, 
                        to_owner,
                        to_children;
  extern   void         EMsfintedpar_free();
  OM_S_OBJECT_LINKAGE   surf_link,
                        chan_elems[MAX_NEW_EDGES],
                       *chan_ptr=NULL; 
  struct EMSedgebound   edgebndlist[2];


  *EMmsg       = EMS_S_Success;
  sts          = OM_S_SUCCESS;
  edge_bdrys   = ele_bdrys = NULL;
  new_edge_ptr = new_edges;
  new_edge_buf = NULL;


  /* this channel will be used by the graphic loop to connect
   * with an edge or a partial edge.  it will also be used by
   * a partial edge to connect with its edge.
   */  
  sts = EMmake_chanselect( EMSbd_owner_to_comps, &to_comps );
  EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

  /* this channel will be used for the edge to connect to either the
   * graphic loop or a partial edge.
   */  
  sts = EMmake_chanselect( EMSedge_to_owner, &to_owner );
  EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

  /* this is the channel that connects the graphic loop(me) to the surface */
  sts = EMmake_chanselect( EMShelper_to_requesters, &to_request );
  EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

  /* this is the channel that connects the graphic loop(me) to the MSCs */
  sts = EMmake_chanselect( NDchildren_children, &to_children );
  EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

  /* Tell my MSCs to store their keys */
  sts = om$send(msg = message EMSpointerA.EMstore_key_from_id(EMmsg,NULL,NULL),
                p_chanselect = &to_children);
 
  count = 1;
  /* get the objid of the surface */
  sts = om$get_channel_objects( object       =  me,
                                p_chanselect = &to_request,
                                list         = &surf_link,
                                size         =  count,
                                count        = &count );
  EMerr_hndlr( !( 1 & *EMmsg & sts ), *EMmsg, EMS_E_Fail, wrapup );

  /* this channel connects our surface to its loopset */   
  sts = EMmake_chanselect( EMSsubbs_to_loopset, &to_loopset );
  EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

  /* find out if there is a loopset on the channel */
  sts = om$get_channel_count( objid        =  surf_link.S_objid,
                              p_chanselect = &to_loopset,
                              count        = &loopcount );

  if(loopcount)
   {
    /* get the objid of the loopset */
    sts = om$send( msg = message EMSboundary.EMget_objid( EMmsg, 
                                                         &loopset ), 
                   senderid     = surf_link.S_objid,
                   p_chanselect = &to_loopset );
    EMerr_hndlr( !( 1 & *EMmsg & sts ), *EMmsg, EMS_E_Fail, wrapup );
   }
     
  /* get the count of edges on the to_comps channel of our graphic loop */
  sts = om$get_channel_count( object       =  me,
                              p_chanselect = &to_comps,
                              count        = &count );
  mal_edge = FALSE;
  mal_ptedge = FALSE; 
  mal_chan = FALSE;
  if( count )
  {
    /* allocate memory for the channel object id's, also arrays for the
     * edges and the part edges.
     */
    if( count > MAX_NEW_EDGES )    
    {
        /* channel objects */
        chan_ptr = (OM_S_OBJECT_LINKAGE *)om$malloc(size = count * 
                                               sizeof(OM_S_OBJECT_LINKAGE));
        mal_chan = TRUE;       

        /* whole edge array */        
        edge_ptr = (GRobjid *)om$malloc(size = count * sizeof(GRobjid));
        mal_edge = TRUE;       
    
        /* partial edge array */
        ptedgeptr = (GRobjid *)om$malloc(size = count * sizeof(GRobjid));
        mal_ptedge = TRUE;
    }     
    else
    {
        /* channel objects */        
        chan_ptr = chan_elems;        
        mal_chan = FALSE;

        /* whole edge array */        
        edge_ptr = edges;        
        mal_edge = FALSE;

        /* partial edge array */
        ptedgeptr = ptedges;  
        mal_ptedge = FALSE;
    }

    /* get the list of objects on the to_comps channel */
    sts = om$get_channel_objects( object       =  me,
                                  p_chanselect = &to_comps,
                                  list         =  chan_ptr,
                                  size         =  count,
                                  count        = &count );

  /* loop through the edges on the channel and separate the edges and the
   * part edges.
   */
  edge_count = 0;
  ptedge_count = 0;      
  for( i = 0; i < count; i++ )
  {
     /* is this a part edge ? */
     sts = om$send( msg = message EMSedge.EMget_bottom_edge( EMmsg, 
                                                            &bottom_edge ), 
                    p_chanselect = &to_comps, 
                    from = i,
                    to = i );
     EMerr_hndlr( !( 1 & *EMmsg & sts ), *EMmsg, EMS_E_Fail, wrapup );
  
     if( chan_ptr[i].S_objid != bottom_edge )
      {
       /* we have a part edge, save its objid in the part edge array */
       ptedgeptr[ptedge_count] = chan_ptr[i].S_objid;
       ptedge_count++;
       
      } 

       /* save the objid of the whole edge in the edge array */
       if( edge_count > 0 )
       {
         /* it is possible that two part edges will own the same edge so
          * in calling EMget_bottom_edge we may end up with duplicate 
          * edges.  here we check for duplicate edges.
          */  
         dup = FALSE; 

         for( k = 0; k < edge_count; k++ )
         {
            if( edge_ptr[k] == bottom_edge )
               dup = TRUE;
         }
         if( !dup )
         {
           edge_ptr[edge_count] = bottom_edge;           
           edge_count++;      
         } 
       } 
       else  
       {
         edge_ptr[edge_count] = bottom_edge;           
         edge_count++;      
       } 

  } /* end for -- separating edges and part edges */


  /* Get the parametric tolerance for this surface.
   */
  world = TRUE;     
  sts = om$send( msg = message EMSsubbs.EMpartolbasis (
                                       EMmsg,
                                       matrix_type,
                                       matrix,
                                      &world, /* world coordinates? */
                                       FALSE, /* fresh computation? */
                                      &parametric_tolerance ), 
                 targetid = surf_link.S_objid );                        


  partolbasis.tol = parametric_tolerance;
  partolbasis.in_world = TRUE;
  partolbasis.is_valid = TRUE;
  partolbasis.mattyp = matrix_type;
  partolbasis.mat = matrix;

/* temporary */            sv_ptedge_count = ptedge_count;

  /* loop through the whole edges and send trim message to each */
  for( i = 0; i < edge_count; i++ )
  {
     in_area = TRUE;
     in_hole = TRUE;
     intersect = FALSE;

     edge_num_bdrys = 0;
     ele_bdrys = NULL;
     edge_bdrys = NULL;

     if(loopcount)
     {
       sts = om$send( msg=message EMSedge.EMtrimyourself(
                                 EMmsg, 
                                &loopset, 
                                 trim_options, 
                                &ele_bdrys,  /* need to dealloc this */ 
                                &edge_bdrys, /* need to dealloc this */ 
                                &edge_num_bdrys, 
                                 NULL, 
                                &partolbasis ), 
                      targetid = edge_ptr[i] );

       EMerr_hndlr( !( 1 & *EMmsg & sts ), *EMmsg, EMS_E_EdgeError, wrapup );
     }
    else 
       *EMmsg = EMS_I_InAreaTrim; /* if no loopset, just connect whole edge */


     if( *EMmsg == EMS_I_IntersectTrim ) 
     { 
        intersect = TRUE; 
        in_area = FALSE; 
        in_hole = FALSE;
     }
     else if( *EMmsg == EMS_I_InAreaTrim ) 
          in_hole = FALSE; 
     else if( *EMmsg == EMS_I_InHoleTrim ) 
          in_area = FALSE; 

     /* first break any connections between the edge and any of its 
      * previous part edges.
      */
     sts = om$send( msg = message Root.wild_disconnect( to_owner ),
                    targetid = edge_ptr[i] );
        
     if( in_area )
     {
       /* the edge is totally in an area with no trimming required,
          just connect it to the graphic loop.
        */   
       sts = om$send(msg = message Root.connect(          
                                        to_owner,       /* target channel */
                                        MAXINT,         /* add at end */
                                        my_id,          /* sender objid */
                                        OM_Gw_current_OS, /* sender os */
                                        to_comps,     /* sender channel */
                                        NULL ),        /* from index */
                     targetid = edge_ptr[i] );
       EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 

     } /* end if( in_area ) */
     else 
       if( intersect )
       {
           /* the edge was not totally in an area so we need to create some
            * part edges.
            */   
/* temporary ****/  ptedge_count = 0;

            balance = ptedge_count - edge_num_bdrys;


           if( balance >= 0 )
           { 
              /* we have enough part edges left over */
              while( edge_num_bdrys > 0 )
              {
                ptedge_count--;

                edgebndlist[0].param = edge_bdrys->edgepar.param;
                edgebndlist[0].span_inx = edge_bdrys->edgepar.span_inx;
                edge_bdrys = edge_bdrys->next;

                edgebndlist[1].param = edge_bdrys->edgepar.param;
                edgebndlist[1].span_inx = edge_bdrys->edgepar.span_inx;
                edge_bdrys = edge_bdrys->next;

                /* put the bounds of the new part edge on the old part edge */
                 sts = om$send( msg = message EMSpartedge.EMputbounds(
                                             EMmsg,
                                             edgebndlist ),
                                targetid = ptedgeptr[ptedge_count] ); 
                 EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 


                 /* connect the to_comps channel of the part edge to the 
                  * to_owner channel of the edge it is a part of.
                  * the part edge is already connected to the graphic
                  * loop.
                  */
                 sts = om$send( msg = message Root.connect(          
                                     to_owner,       /* target channel */
                                     MAXINT,         /* add at end */
                                     ptedgeptr[ptedge_count], /* sender objid */
                                     OM_Gw_current_OS, /* sender os */
                                     to_comps,         /* sender channel */
                                     NULL ),           /* from index */
                                targetid = edge_ptr[i] );
                 EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 

                 edge_num_bdrys--;

              }
           }
           else
           { 
               /* loop through the remaining left over part edges */
               while( ptedge_count > 0 )
               {
                  ptedge_count--;   

                  edgebndlist[0].param = edge_bdrys->edgepar.param;
                  edgebndlist[0].span_inx = edge_bdrys->edgepar.span_inx;
                  edge_bdrys = edge_bdrys->next;

                  edgebndlist[1].param = edge_bdrys->edgepar.param;
                  edgebndlist[1].span_inx = edge_bdrys->edgepar.span_inx;
                  edge_bdrys = edge_bdrys->next;

                  /* put the bounds of the new part edge on the old part edge */
                  sts = om$send( msg = message EMSpartedge.EMputbounds( 
                                              EMmsg,
                                              edgebndlist ),
                                 targetid = ptedgeptr[ptedge_count] ); 
                  EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

                  /* connect the to_comps channel of the part edge to the 
                   * to_owner channel of the edge it is a part of.
                   * the part edge is already connected to the graphic
                   * loop.
                   */
                  sts = om$send( msg = message Root.connect(          
                                      to_owner,       /* target channel */
                                      MAXINT,         /* add at end */
                                      ptedgeptr[ptedge_count], /* sender objid */
                                      OM_Gw_current_OS, /* sender os */
                                      to_comps,         /* sender channel */
                                      NULL ),           /* from index */
                                targetid = edge_ptr[i] );
                  EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 
                     
               }  

               /* we need to create balance more part edges */
               balance = MAabsolute(balance);
               if( balance > MAX_NEW_EDGES )
               {
                 /* need to allocate memory for the new edge id's */
                 new_edge_buf = (GRobjid *)om$malloc(size = balance * 
                                                            sizeof(GRobjid));
                 new_edge_ptr = new_edge_buf;
               }                 
               else  
               {
                 /* use the array we already have allocated */
                 new_edge_ptr = new_edges;
               }                   

               
               /* create the new part edges using the newly allocated 
                * edge id array.
                */   

                sts = om$send( msg = message EMSedge.EMget_props_type(
                                            EMmsg, 
                                           &edge_props,
                                           &edge_curve_type ),
                               targetid = edge_ptr[i] );
                                         

                edge_props &= ~EMED_XYZ_CLOSED & ~EMED_COMPATIBLE & 
                              ~EMED_MSCEXISTS;
                edge_props |= EMED_OPEN;


                for( k = 0; k < balance; k++ )
                {
                   edgebndlist[0].param = edge_bdrys->edgepar.param;
                   edgebndlist[0].span_inx = edge_bdrys->edgepar.span_inx;
                   edge_bdrys = edge_bdrys->next;

                   edgebndlist[1].param = edge_bdrys->edgepar.param;
                   edgebndlist[1].span_inx = edge_bdrys->edgepar.span_inx;
                   edge_bdrys = edge_bdrys->next;

                   /* construct the new part edge */
                   sts = om$construct( classid = OPP_EMSpartedge_class_id,
                                       p_objid = &new_edge_ptr[k],
                                       msg = message EMSpartedge.EMpeinit(
                                            EMmsg,
                                            edge_props,
                                            edgebndlist,
                                            edge_curve_type ));

                   /* connect the to_comps channel of the new part edge to
                    * the to_owner channel of its edge.
                    */
                   sts = om$send( msg = message Root.connect(          
                                       to_owner,         /* target channel */
                                       MAXINT,           /* add at end */
                                       new_edge_ptr[k],  /* sender objid */
                                       OM_Gw_current_OS, /* sender os */
                                       to_comps,         /* sender channel */
                                       NULL ),           /* from index */
                                  targetid = edge_ptr[i] );
                   EMerr_hndlr( !(1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 


                   /* connect the to_comps channel of the graphic loop(me)
                    * the to_owner channel of the new part edge.
                    */  
                   sts = om$send( msg = message Root.connect(          
                                       to_owner,         /* target channel */
                                       MAXINT,           /* add at end */
                                       my_id,            /* sender objid */
                                       OM_Gw_current_OS, /* sender os */
                                       to_comps,         /* sender channel */
                                       NULL ),           /* from index */
                                  targetid = new_edge_ptr[k] );
                   EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 
                      
                }  /* end for -- looping through balance of edges */
    
            } /* end else -- balance < 0 */
           
        } /* end if intersect */
        else
        {
           /* the edge is totally in a hole or just not in the area of the 
            * boundaries. previously we would just delete the edge in 
            * question, but since we are no longer connected to the loopset,
            * we don't use the dpr state tree, which means we can't backup,
            * which means we need to keep track of edges that are not 
            * currently being used.  we will control this by not displaying
            * an edge that is not in an area.  might be able to accomplish
            * by either setting an unused bit on the edge which could be
            * used as a display bit and have the edge code honor it...Or we
            * could create a partial edge for the edge which will set that 
            * display bit and have the part edge code honor it.  It is the
            * same bit since part edge is subclassed under edge.  
            */

           /* connect the to_comps channel of the graphic loop(me) to
            * the to_owner channel of its edge.
            */
           sts = om$send( msg = message Root.connect(          
                               to_owner,         /* target channel */
                               MAXINT,           /* add at end */
                               my_id,            /* sender objid */
                               OM_Gw_current_OS, /* sender os */
                               to_comps,         /* sender channel */
                               NULL ),           /* from index */
                          targetid = edge_ptr[i] );
           EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 

     
           props = 0;
           props |= EMED_NO_DISPLAY; /* currently being proposed */
           option = EMS_O_ON; /* turn specified prop bit on */ 

           /* set display for this edge off */
           sts = om$send( msg = message EMSedge.EMset_props(
                               EMmsg,
                               props,    /* bit indicator */
                               option ), /* how to set bit */
                          mode = OM_e_wrt_message,
                          targetid = edge_ptr[i] );       
            
           EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );
        }
    
   if( edge_bdrys )    EMsfintedpar_free( edge_bdrys, NULL );
   if( ele_bdrys )     EMsfintedpar_free( ele_bdrys, NULL );
   ele_bdrys = NULL;
   edge_bdrys = NULL;
   } /* end for looping through whole edge array */  

  } /* end if count of initial edges on graphic loop to_comps channel > 0 */



/* temporary */  ptedge_count = sv_ptedge_count;

  /* need to delete the remaining part edges */
  for(k=0;k<ptedge_count;k++)
   {
    sts = om$send(msg = message Root.delete(TRUE),
                  targetid = ptedgeptr[k] );
    EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup ); 
   }
  ptedge_count=0;



  sts = om$send( msg = message EMShelper.EMset_props( EMmsg,
                                                      EMGL_UPTODATE,
                                                      EMS_O_ON ),
                 mode = OM_e_wrt_message,
                 targetid = my_id );       


  /* Tell my MSCs to store the ids */
  sts = om$send(msg = message EMSpointerA.EMstore_id_from_key(EMmsg,NULL,NULL),
                p_chanselect = &to_children);
 
wrapup:
   /* may have been alloced in trimyourself */
   if( edge_bdrys )    EMsfintedpar_free( edge_bdrys, NULL );
   if( ele_bdrys )     EMsfintedpar_free( ele_bdrys, NULL );


   if( new_edge_buf )  om$dealloc( ptr = new_edge_buf );
   if( mal_chan )      om$dealloc( ptr = chan_ptr );
   if( mal_edge )      om$dealloc( ptr = edge_ptr );
   if( mal_ptedge )    om$dealloc( ptr = ptedgeptr );   

   if( in_area )  *EMmsg = EMS_I_InAreaTrim;
   else if( in_hole )  *EMmsg = EMS_I_InHoleTrim;
   else *EMmsg = EMS_I_IntersectTrim;

   EMWRAPUP( *EMmsg, sts, "In EMSgraloop.EMupdate_feature" );
   return( sts );
}

end implementation EMSgraloop;
