#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#include "revasmipc.h"

/* if this function is being called from external process, the f_sem will be
   emssem and t_sem will be extsem
*/
void build_tree_from_shm(tree_head, shmptr, f_sem, t_sem)
REVASM_TREE **tree_head;
NodeInfo *shmptr;
int t_sem, f_sem; 
{
REVASM_TREE *ptr_tree, *tree_end = NULL;

    /* Wait for the semaphore to be set to 1 */
    sem_wait(t_sem);

    *tree_head = NULL;

    /* If not end_of_tree, add the node to the tree */
    while(shmptr->op_type != END_OF_TREE)
    {
        /* Set up the memory for the current node */
        if(*tree_head == NULL)
        {
            *tree_head = (REVASM_TREE *)calloc(1, sizeof(REVASM_TREE));
            ptr_tree = *tree_head;
        }    
        else
        {
            ptr_tree = *tree_head;

            /* goto the end of the tree */
            while(ptr_tree->next)
                ptr_tree = ptr_tree->next;

            tree_end = ptr_tree;
            ptr_tree->next = (REVASM_TREE *)calloc(1, sizeof(REVASM_TREE));
            ptr_tree = ptr_tree->next;
        }
        /* Fill up the new node in the tree */
        ptr_tree->info = *shmptr;
        ptr_tree->next = NULL;
        ptr_tree->child = NULL;
        ptr_tree->sibling = NULL;

	if( tree_end == NULL )
	{
        	sem_signal(f_sem);
        	sem_wait(t_sem);
		continue;
	}
        /* connect the parent, child and siblings */
        if(tree_end->info.depth < ptr_tree->info.depth)
        {
            /* Setup the parent and child */
            tree_end->child = ptr_tree;
            ptr_tree->parent = tree_end;
        }     
        else if(tree_end->info.depth == ptr_tree->info.depth)
        {
            /* Setup the sibling and parent */
            tree_end->sibling = ptr_tree;
            ptr_tree->parent = tree_end->parent;
        }
        else if(tree_end->info.depth > ptr_tree->info.depth)
        {
            /* Go up the tree until we get the sibling with same depth */
            while(tree_end->info.depth != ptr_tree->info.depth)
                tree_end = tree_end->parent;

            tree_end->sibling = ptr_tree;
            ptr_tree->parent = tree_end->parent;
        }
        sem_signal(f_sem);
        sem_wait(t_sem);
    }
#ifdef DEBUG
print_revasm_tree(*tree_head);
#endif
}

/*
If this function is being called by the external process, f_sem will be
emssem and t_sem will be extsem.
*/

void send_tree_thru_shm(tree_head, shmptr, f_sem, t_sem)
REVASM_TREE *tree_head;
NodeInfo *shmptr;
int t_sem, f_sem; 
{
REVASM_TREE *tree_ptr;
NodeInfo end_of_tree;

    /* Starting from the top of the tree, copy the nodeinfo into the
       shared memory ptr and signal the other process to read it, and
       wait for the other process to signal you to write a new node.
       At the end of the tree, write the node with op_type set to
       END_OF_TREE.
    */
    tree_ptr = tree_head;

    *shmptr = tree_ptr->info;

    sem_signal(t_sem);
    sem_wait(f_sem);
    while(tree_ptr->next)
    {
        tree_ptr = tree_ptr->next;
        *shmptr = tree_ptr->info;

        sem_signal(t_sem);
        sem_wait(f_sem);
    }
    end_of_tree.op_type = END_OF_TREE;
    *shmptr = end_of_tree;

    sem_signal(t_sem);
}

print_revasm_tree(REVASM_TREE *tree_head)
{
int  i;
char indent[120];
REVASM_TREE *tree_ptr;

    tree_ptr = tree_head;

    while(tree_ptr)
    {
        for(i=0; i < tree_ptr->info.depth; i++)
            indent[i] = ' ';

        indent[i] = 0;

        printf("%s%s(:%s_%s:)\n",indent,tree_ptr->info.o_part.filename,
                                   tree_ptr->info.o_part.number,
			           tree_ptr->info.o_part.revision);
        printf("%s%s(:%s_%s:)\n",indent,tree_ptr->info.n_part.filename,
                                   tree_ptr->info.n_part.number,
			           tree_ptr->info.n_part.revision);

        tree_ptr = tree_ptr->next;
    }
    printf("\n\n\n");
}

