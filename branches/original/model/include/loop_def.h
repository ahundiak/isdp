/*
3-Dec-1986 added undef's for NULL, TRUE and FALSE
-- J. Brooke King
*/

# ifndef loop_def_include
# define loop_def_include

#ifdef NULL
#undef NULL
#endif
#define NULL 0

#ifdef TRUE
#undef TRUE
#endif
#define TRUE    1

#ifdef FALSE
#undef FALSE
#endif
#define FALSE   0

/* Define tracing directions. */
#define FORWARD 1
#define BACKWARD 0

/* Define loop types */
#define C_LOOP 0
#define P_LOOP 1
#define CLOSED 100
#define OPEN 101

/* Define standard return status for VS funcions. */
#define FAIL    0
#define SUCCESS 1
#define NO_MEMORY 2
#define INVALID_ARG 3
#define ZERO_DIVIDE 4
#define ERROR 5
#define TOO_MANY_POINTS 6
#define DEGENERATE 7

/* Define vertex and edge locations. */
#define UNDEFINED       0
#define ON_VERTEX       1       /* not valid for edges */
#define ON_EDGE         2
#define INSIDE          3
#define OUTSIDE         4
#define ABOVE           5       /* Not a valid location outside the routine
                                   'define_vertex_locations'. */

typedef unsigned char byte;

typedef struct vertex
{
        double          u, v;           /* Paramtric repesentation.          */
        byte            location;       /* With respect to the other loop.   */
        byte            above;          /* Temporary flag used by inside_loop*/
};

typedef struct edge
{
        struct edge     *flink;         /* Forward link.                     */
        struct edge     *blink;         /* Backward link.                    */

        struct vertex   *vertex_0;      /* Endpoints.                        */
        struct vertex   *vertex_1;      /*                                   */
        byte            traced;         /*True after the edge has been traced*/
        byte            intersection;   /* Edge produced by intersection.    */
        byte            location;       /* With respect to the other loop.   */
};

typedef struct loop
{
        double          min_u, max_u,   /* Range in u.                       */
                        min_v, max_v;   /* Range in v.                       */
        double          x, y, z;        /* 3D point inside loop, but not     */
                                        /* inside interior loops.            */
        struct edge     *edges;         /* Doubly linked list of edges.      */
        struct loop     *flink;         /* Next loop.                        */
        byte            type;           /* P_LOOP -- perimeter loop. (solid) */
                                        /* C_LOOP -- center loop. (hole)     */
        byte            tracing;        /* Location of edges to be traced.   */
};

# endif
