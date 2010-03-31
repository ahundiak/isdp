/*
    This file contains the data structures for the Baisc Topology
    (Engine) generated in the 'Analyze Adjacency between Surfaces' command.
    the structures are based on linked lists defined by a header and tail 
    element
*/
#ifndef TOstruct1
#define TOstruct1

    struct Ext_data_surface;  
    struct Ext_data_edge;  

/*  surface list */ 
    struct surface {
		  struct surface   *next;	  /*pointer to the next list
                                                    element                  */	
                  struct Ext_data_surface  *ext;  /*pointer to the EMS
                                                     dependent surface data   */
		  short		   num_ed; 	  /*number of surface edges   */
		  struct  elist    *elehead;      /*header of the linked list
                                                    with pointers to the edges*/
		  struct  elist    *eletail;      /*tail of the linked list
                                                    with pointers to the edges*/
    };
/*  edge list */    
    struct edge {
		  struct edge      *next;        /*pointer to the next list
                                                   ele ment                   */
		  short            status;       /*status of an edge
                                                   1 generation state
                                                   2 member of a super edge
                                                   3 root of part edges
                                                   4 member of a splitted edge
                                                  10 edge is connected to an-
                                                     other one only at the end
                                                     points
                                                  <0 edge is member of a super
                                                     edge                     */
                  struct Ext_data_edge  *ext;     /*pointer to the EMS
                                                    dependent edge data       */
		  struct edge	   *edid0;        /*pointer of the edge       */
		  struct edge	   *edid1;        /*member of a super edge if
                                                    status=2
                                                    part edge if status=3     */
		  struct edge	   *edid2;        /* analogous to edid1*/
		  struct surface   *sf;           /*reference to the surface 
                                                    list                      */
		  struct point	   *p1;           /*pointer to one end point
                                                    of the edge in the point
                                                    list                      */
		  struct point	   *p2;           /*analogous p1              */
		  short            num_te;        /*number of top edges       */
		  struct telist    *elehead;      /*header and tail of the    */
		  struct telist    *eletail;      /*top edge pointer list     */
    };
/*  point list*/
    struct point {
                  struct point     *next;         /*next list element         */
                  short            status;        /*status of the point       */
                  double           x;             /*x,y,z coordinate          */
                  double           y;             /*of                        */
                  double           z;             /*the point                 */
                  struct edge      *ed;           /*pointer to the referenced
                                                    edge                      */
                  struct top_point *tp;           /*pointer to the referenced
                                                    topological point         */
    };
/*  topological point list*/
    struct top_point {
                  struct top_point *next;         /*next list element         */
		  short            status;        /*status of the top point   */
		  short            num_ele;       /*number of points of the
                                                    top point                 */
		  struct plist     *elehead;      /*header and tail of the    */
		  struct plist     *eletail;      /*point pointer list        */
    };
/*  topological edge list*/
    struct top_edge {
                  struct top_edge *next;          /*next list element         */
		  short           status;         /*status of the top edge    */
		  short           num_ele;        /*number of edges in the
                                                    top edge =2 for manifold
                                                    geometry                  */ 
		  struct  elist   *elehead;       /*header and tail of the    */
		  struct  elist   *eletail;       /*edge pointer list         */
    };
/*  list of edge pointers */
    struct elist {
                  struct elist *next;             /*next list element         */
                  struct edge  *ied;              /*pointer to edge list      */
    };  

    struct plist {
                  struct plist *next;            /*next list element          */
                  struct point  *ipt;            /*pointer to point list      */
    };  

    struct telist {
                  struct telist    *next;        /*next list element          */
                  struct top_edge  *ied;         /*pointer to top edge list   */
    };
  
#endif
