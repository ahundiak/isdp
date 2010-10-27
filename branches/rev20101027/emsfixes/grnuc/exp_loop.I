/* $Id: exp_loop.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	emsfixes/grnuc/exp_loop.I
 *
 * Description:
 *		ASSOC checking file to validate expression.
 *
 * Dependencies:
 *		NONE
 *
 * Revision History:
 *	$Log: exp_loop.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/08/16  14:53:00  pinnacle
# Created: emsfixes/grnuc/exp_loop.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/16/95	adz		Override for TR179526707
 *
 ***************************************************************************/

class implementation expression;

#include <stdio.h>
#include <string.h>
#include <OMminimum.h>
#include <OMmacros.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "madef.h"
#include "AS_status.h"
#include "GMdef.h"
#include "GM.h"
#include "expression.h"
#include "grdpbmacros.h"
#include "gocmacros.h"

#define AS_DEBUG

static int *EQnumber, *EQlow, *EQtag;
static int EQcount, EQloop_count, EQsccount, EQindex, EQsize;
static int **EQloop, *EQloop_sizes, *EQsclist;
static struct GRid *EQlist;

extern GRclassid OPP_NDnodein_class_id;

/*
	Function EQfind_loop_elmts()

	This function returns the strong components of the given
	expression object.

	Arguments:

	struct GRid object	 (I)	object of which the strong
					components need to be done.

	struct GRid *cyclic_grid (O)	List of GRid's of the strong
					components.

					Memory needs to allocated for
					the above argument. Generally
					it is allocated to MAX_NUM_EQN_VAR.

	int *cyclic_count	 (O)	No of strong components.
*/

EQfind_loop_elmts(object, cyclic_grid, cyclic_count)
IGRint *cyclic_count;
struct GRid object, *cyclic_grid;
{
	IGRint i, j, k, status, index, size;
	OM_S_CHANSELECT chan_sel;
        GRclassid  ob_classid;
        
	size = 0;
	*cyclic_count = 0;

        om$get_classid( objid = object.objid, osnum = object.osnum,
                           p_classid = &ob_classid );
        if(om$is_ancestry_valid ( subclassid = ob_classid,
		            superclassid = OPP_expression_class_id ) != OM_S_SUCCESS)
            return(OM_S_SUCCESS);

	status =
	om$make_chanselect(channame = "NDchildren.children",
			p_chanselect = &chan_sel);
	as$status(action = RET_STATUS);

	status =
	om$get_channel_count(
		objid = object.objid,
		osnum = object.osnum,
		p_chanselect = &chan_sel,
		count = (OMuint *)&size);
	as$status(action = RET_STATUS);

	if (!size)
	{
		/* No Children present, no strong could be
		   detected. Return. */

		return(OM_S_SUCCESS);
	}

	/* Initialise the static variables */

	EQindex = 0;
	EQsccount = 0;
	*cyclic_count = 0;
	EQloop_count = 0;
	EQsize = 100;
	EQcount = 0;
	EQloop = 0;

	/* allocate the static variables */

	size = EQsize * sizeof(int);
	EQnumber = (int *)om$malloc(size = size);
	EQlow = (int *)om$malloc(size = size);
	EQtag = (int *)om$malloc(size = size);
	EQsclist = (int *)om$malloc(size = size);
	EQloop_sizes = (int *)om$malloc(size = size);

	EQloop = (int **)om$malloc(size = (EQsize * sizeof(int *)));

	size = EQsize * sizeof(struct GRid);
	EQlist = (struct GRid *)om$malloc(size = size);

	if ((!EQnumber) && (!EQlow) && (!EQtag) && (!EQsclist)
	&& (!EQloop) && (!EQloop_sizes) && (!EQlist))
	{
		printf("EQfind_loop_elmts(): malloc failed\n");
		return(OM_E_ABORT);
	}

	for (i=0; i<EQsize; i++)
	{
		EQnumber[i] = EQtag[i] = EQloop_sizes[i] = 0;
		EQloop[i] = 0;
	}

	EQlist[0] = object;
	EQcount++;

	status = EQfind_loops(0);

	/*"EQloop_count = %d\n", EQloop_count*/

	for (i=0; i<EQloop_count; i++)
	{
		/*"EQloop_sizes[%d] = %d\n", i, EQloop_sizes[i]*/

		for (j=0; j<EQloop_sizes[i]; j++)
		{
			/*"EQloop[%d][%d] = %d\n", i,j, EQloop[i][j]*/

			if (EQloop[i][j] == 0)
			{
				if (EQloop_sizes[i] > MAX_NUM_EQN_VAR)
				{
					printf("EQfind_loop_elmts(): cyclic_grid array insufficent, count = %d\n",
						EQloop_sizes[i]);
					return(OM_E_ABORT);
				}

				*cyclic_count = EQloop_sizes[i];

				for (k=0; k<*cyclic_count; k++)
				{
					index = EQloop[i][k];
					cyclic_grid[k].objid = EQlist[index].objid;
					cyclic_grid[k].osnum = EQlist[index].osnum;
				}

				break;
			}
		}
	}

	/* deallocate the static variables */

	if (EQnumber) om$dealloc(ptr = EQnumber);
	if (EQtag) om$dealloc(ptr = EQtag);
	if (EQlow) om$dealloc(ptr = EQlow);
	if (EQloop_sizes) om$dealloc(ptr = EQloop_sizes);
	if (EQsclist) om$dealloc(ptr = EQsclist);
	if (EQlist) om$dealloc(ptr = EQlist);

	for(i=0; i<EQloop_count; i++)
	{
	   if (EQloop[i])
	   {
		om$dealloc(ptr = EQloop[i]);
		EQloop[i] = 0;
	   }
	}

	if (EQloop) om$dealloc(ptr = EQloop);

        if (*cyclic_count == 0)
        {
#ifdef	PREV_VERSION
          struct GRid child_grid[MAX_NUM_EQN_VAR];
#endif
	  struct GRid *child_grid = NULL ;
          int num_children, counter;

	  status = om$send(msg = message NDnode.NDget_objects(  ND_CHILDREN,
							NULL,
							0, NULL,
							0, OM_K_MAXINT,
							&num_children),
  		   senderid = NULL_OBJID,
       		   targetos = object.osnum,
                   targetid = object.objid );
	  if( !( status & 1 )){
		om$dealloc(ptr = child_grid);
                as$status(action = RET_STATUS);
	  }

	  if( num_children ){
		child_grid = (struct GRid *)om$malloc(size =
                                       sizeof(struct GRid) * num_children );
                if (!child_grid){
                     printf("EQfind_loop_elmts(): malloc failed\n");
                     return(OM_E_ABORT);
                }

		status =
		om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,
							child_grid,
							num_children, NULL,
							0, num_children,
                                                        &num_children ),
  		   senderid = NULL_OBJID,
       		   targetos = object.osnum,
                   targetid = object.objid );
		if( !( status & 1 )){
		   om$dealloc(ptr = child_grid);
          	   as$status(action = RET_STATUS);
		}

	  } /* if( num_children ) */
	
#ifdef	PREV_VERSION
	  if( num_children >= MAX_NUM_EQN_VAR ){
            Error_Text( EXP_MEM_FAIL, (int *) "in cycle check" );
	    printf("<< EQfind_loop_elmts EXP_MEM_FAIL \n");
            return EXP_MEM_FAIL;
	  }
#endif

          for (counter = 0; counter < num_children; counter++)
            if ((child_grid[counter].osnum == object.osnum) &&
                (child_grid[counter].objid == object.objid))
            {
              *cyclic_count = 1;
              cyclic_grid[0].osnum = object.osnum;
              cyclic_grid[0].objid = object.objid;
              break;
            }

	    /* Free the temp buffer. */
	    om$dealloc(ptr = child_grid);
        } /*  if (*cyclic_count == 0) */

	return(status);
}

/*
	Function: EQfind_loops()

	Description:

	This function returns the all the strong components involved
	in the graph.

	Alogrithm:

	This functions starts with one node in graph and traverses
	through the children objects and detects a cycle. The graph
	maintains the following static arrays to store the nodes
	involved in the search and the cycles.

	EQlist	-> This list maintains the list of nodes in the graph.
	EQsclist -> This keeps trak of the nodes to be assigned to a
		    strong component in the graph.
	EQloop	-> This array stores the strong components detected.
	EQloop_sizes -> This array stores the loop sizes.

	EQnumber -> Ths algorithm traverses the graph in a depth first
		    search manner. This array stores the order in
		    which each node is visted.

	EQtag -> This array stores whether a node is already outputted
		 as a strong component.

	EQlow -> This array is initially stores the EQnumber value and
		 later adjusted as and when a cross edge or back edge
		 is detected in the graph. This array helps in determining
		 the strong component.

*/

IGRint EQfind_loops(node)
IGRint node;
{
	int status, index, i, edge_count;
	struct GRid *edge, *buffer;
        GRclassid  ob_classid;

	edge_count = 0;
	edge = 0;
        status = OM_S_SUCCESS;
	if (!EQnumber[node])
	{
                om$get_classid( objid = EQlist[node].objid, 
                                osnum = EQlist[node].osnum,
                                p_classid = &ob_classid );
                if(om$is_ancestry_valid ( subclassid = ob_classid,
	            superclassid = OPP_expression_class_id ) != OM_S_SUCCESS)
                {
                    edge_count = 0;                  
                }
                else
                {
    		    /*|- Find if there exists any children */

                    status = om$send(msg = message NDnode.NDget_objects
                                          (ND_CHILDREN|ND_IN_BUF, NULL,0,
                                           &buffer,0,OM_K_MAXINT,&edge_count),
    				senderid = NULL_OBJID,
    				targetid = EQlist[node].objid,
    				targetos = EQlist[node].osnum);

                }		
		if (!(1 & status))
		{
			printf("NDget_objects failed: node = (%d,%d), status = %d\n",
			EQlist[node].objid, EQlist[node].osnum, status);
			om$dealloc(ptr = edge);
			return(OM_E_ABORT);
		}

		else if (edge_count)
		{

			edge = (struct GRid *)om$malloc(size = 
			                          sizeof(struct GRid) * edge_count);
			if (!edge)
			{
				printf("EQfind_loops(): malloc failed\n");
				return(OM_E_ABORT);
			}

                       OM_BLOCK_MOVE(buffer, edge, sizeof(struct GRid) * edge_count);
		}
	}

	/* Intialise the node */

	EQindex++;
	EQnumber[node] = EQindex;
	EQlow[node] = EQindex;
	EQtag[node] = 0;

	/* Process the edges on this node */

	index = -1;
	for (i=0; i<edge_count; i++)
	{
		index = EQadd_list(edge[i]);
		if (index < 0)
		{
			printf("EQfind_loops(): EQadd_list() failed\n");
			if (edge) om$dealloc(ptr = edge);
			return(OM_E_ABORT);
		}

		if (!EQnumber[index])
		{
			/* If node on the edge is not visited, visit that node*/

			status = EQfind_loops(index);
			if (!(1 & status))
			{
				if (edge) om$dealloc(ptr = edge);
				printf("EQfind_loops() failed\n");
				return(OM_E_ABORT);
			}

			if (EQlow[node] > EQlow[index])
			   EQlow[node] = EQlow[index];
		}
		else
		{
			/* If the visited edge node is not found in another SC*/

			if (!EQtag[index])
			{
				if (EQlow[node] > EQnumber[index])
				   EQlow[node] = EQnumber[index];
			}
		}
	}

	/*"EQlow = %d, EQnumber = %d\n", EQlow[node], EQnumber[node]*/

	if (EQlow[node] == EQnumber[node])
	{
		EQtag[node] = 1;
		if (EQsccount)
		{
			/*"allocate loop_array: size = %d\n", EQsccount*/

			EQloop[EQloop_count] =
			(int *)om$malloc(size = (EQsccount+1) * sizeof(int));
			if (!EQloop[EQloop_count])
			{
				printf("EQfind_loops(): malloc failed\n");
				if (edge) om$dealloc(ptr = edge);
				return(OM_E_ABORT);
			}

			index = 0;
			EQloop[EQloop_count][index++] = node;

			while((EQsccount)
			&& (EQnumber[EQsclist[EQsccount -1]] > EQnumber[node]))
			{
			   EQtag[EQsclist[EQsccount - 1]] = 1;
			   EQloop[EQloop_count][index++] = EQsclist[EQsccount - 1];
			   EQsccount--;
			}

			EQloop_sizes[EQloop_count++] = index;
		}
	}
	else
	{
		EQsclist[EQsccount++] = node;
	}

	if (edge) om$dealloc(ptr = edge);

	return(TRUE);
}

IGRint EQadd_list(grid)
struct GRid grid;
{
	int i, size;

	for(i=0; i<EQcount; i++)
	{
		/* compare the grid with the list */

		if ((grid.objid == EQlist[i].objid)
		&&  (grid.osnum == EQlist[i].osnum))
		{
			/* grid already added to list */
			return(i);
		}
	}

	if (EQcount >= EQsize)
	{
		/* Reallocate the static variables */


		size = (EQsize + 50) * sizeof(int);
		EQnumber = (int *)om$realloc(ptr = (char *) EQnumber, size = size);
		EQlow = (int *)om$realloc(ptr = (char *)EQlow, size = size);
		EQtag = (int *)om$realloc(ptr = (char *)EQtag, size = size);
		EQsclist = (int *)om$realloc(ptr = (char *)EQsclist, size = size);
		EQloop = (int **)om$realloc(ptr = (char *)EQloop, size = size);
		EQloop_sizes = (int *)om$realloc(ptr = (char *)EQloop_sizes, size = size);

		size = (EQsize + 50) * sizeof(struct GRid);
		EQlist = (struct GRid *)om$realloc(ptr = (char *)EQlist, size = size);

		if ((!EQnumber) && (!EQlow) && (!EQtag) && (!EQsclist)
		&& (!EQloop) && (!EQloop_sizes) && (!EQlist))
		{
			printf("EQadd_list(): realloc failed\n");
			return(-1);
		}

		for (i=EQsize; i<(EQsize+50); i++)
		{
			EQnumber[i] = EQtag[i] = EQloop_sizes[i] = 0;
		}

		EQsize += 50;
	}

	EQlist[EQcount] = grid;
	EQcount++;

	return(EQcount-1);
}


int EQfind_all_sc(object, pnum_sc, psc_size, psc, pnode_list)
struct GRid object;
int *pnum_sc, **psc_size, ***psc;
struct GRid **pnode_list;
{
	IGRint i, status, size;
	OM_S_CHANSELECT chan_sel;
        GRclassid  ob_classid;
        

	/* Initialise the static variables */

	EQindex = 0;
	EQsccount = 0;
	EQloop_count = 0;
	EQsize = 100;
	EQcount = 0;
	EQloop = 0;

	size = 0;
    
        om$get_classid( objid = object.objid, osnum = object.osnum,
                           p_classid = &ob_classid );
        if(om$is_ancestry_valid ( subclassid = ob_classid,
		            superclassid = OPP_NDnodein_class_id ) != OM_S_SUCCESS)
            return(OM_S_SUCCESS);

	status =
	om$make_chanselect(channame = "NDchildren.children",
			p_chanselect = &chan_sel);
	as$status(action = RET_STATUS);

	status =
	om$get_channel_count(
		objid = object.objid,
		osnum = object.osnum,
		p_chanselect = &chan_sel,
		count = (OMuint *)&size);
	as$status(action = RET_STATUS);

	if (!size)
	{
		/* No Children present, no strong could be
		   detected. Return. */

		return(OM_S_SUCCESS);
	}

	/* allocate the static variables */

	size = EQsize * sizeof(int);
	EQnumber = (int *)om$malloc(size = size);
	EQlow = (int *)om$malloc(size = size);
	EQtag = (int *)om$malloc(size = size);
	EQsclist = (int *)om$malloc(size = size);
	EQloop_sizes = (int *)om$malloc(size = size);

	EQloop = (int **)om$malloc(size = (EQsize * sizeof(int *)));

	size = EQsize * sizeof(struct GRid);
	EQlist = (struct GRid *)om$malloc(size = size);

	if ((!EQnumber) && (!EQlow) && (!EQtag) && (!EQsclist)
	&& (!EQloop) && (!EQloop_sizes) && (!EQlist))
	{
		printf("EQfind_loop_elmts(): malloc failed\n");
		return(OM_E_ABORT);
	}

	for (i=0; i<EQsize; i++)
	{
		EQnumber[i] = EQtag[i] = EQloop_sizes[i] = 0;
		EQloop[i] = 0;
	}

	EQlist[0] = object;
	EQcount++;

	status = EQfind_loops(0);

   	*pnum_sc = EQloop_count;
        
        *psc_size = EQloop_sizes;
        *psc = EQloop;
        *pnode_list = EQlist;

	return(status);
}


int EQfree_sc_mem()
{
        int i;
        
	/* deallocate the static variables */

	if (EQnumber) om$dealloc(ptr = EQnumber);
	if (EQtag) om$dealloc(ptr = EQtag);
	if (EQlow) om$dealloc(ptr = EQlow);
	if (EQloop_sizes) om$dealloc(ptr = EQloop_sizes);
	if (EQsclist) om$dealloc(ptr = EQsclist);
	if (EQlist) om$dealloc(ptr = EQlist);

	for(i=0; i<EQloop_count; i++)
	{
	   if (EQloop[i])
	   {
		om$dealloc(ptr = EQloop[i]);
		EQloop[i] = 0;
	   }
	}

	if (EQloop) om$dealloc(ptr = EQloop);
        return(1);
}



end implementation expression ;
