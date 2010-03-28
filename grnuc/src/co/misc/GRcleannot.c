/*
Name
        GRcleannot

Description
        This file contains functions relating to notifying interested parties
        to clean up before switching the products.

History
        msm     09/29/92    creation
*/

#include <stdlib.h>
#include <FI.h>

/* number of functions pointers to allocate when new slots are needed */
#define ChunkSize       10

/* typedef to make life easier */
typedef void (*p_function)();

/* the list of functions to call */
static p_function *list = NULL;

/* number of slots allocated for function pointers (*not* the number filled) */
static int num_allocated= 0;

/*
Name
        GRregister_switch_prod_callback

Synopsis
        void GRregister_switch_prod_callback(void (*function)())

Description
        This function is used to register a function to be called each time
        the product is changed.

        The function will be invoked with the following argument list:

            void function(prod)
            char *prod;    The name of the product
*/

void GRregister_switch_prod_callback(function)
void (*function)();
{
    int i;

    /* make sure memory has been allocated */
    if (list == NULL)
    {
        list = (p_function *)calloc((unsigned)ChunkSize, sizeof(p_function));
        num_allocated = ChunkSize;
    }

    /* find an empty slot */
    for (i = 0; i < num_allocated; i++)
    {
        /*
            make sure the function is not already in the list - this might
            happen if the app registers the function in a global_class.wake_up,
            which is a handy place to do things, but subject to be hit multiple
            times on saves and retrieves
        */

        if (list[i] == function)
            return;
        else if (list[i] == NULL)
        {
            list[i] = function;
            break;
        }
    }

    /* check whether an empty slot was found */
    if (i == num_allocated)
    {
        /* allocate another chunk of memory */
        list = (p_function *)realloc(list, 
                                     (sizeof(p_function) * num_allocated) +
                                     (sizeof(p_function) * ChunkSize));

        /* NULL out the new slots */
        for (i = num_allocated; i < num_allocated + ChunkSize; i++)
            list[i] = NULL;

        /* store the function pointer */
        list[num_allocated] = function;

        /* bump the allocation counter */
        num_allocated += ChunkSize;
    }
}

/*
Name
        GRswitch_prod_notification

Synopsis
        void GRswitch_prod_notification(char *cur_prod, *prod)
        char *cur_prod The name of current product.
        char *prod;    The name of the product switching to.

Description
        This function calls all the previously registered functions to
        indicate that a product has been changed.
*/

void GRswitch_prod_notification(cur_prod, prod)
char *cur_prod;
char *prod;
{
    int i;

    for (i = 0; i < num_allocated; i++)
        if (list[i])
            list[i](cur_prod, prod);
        else
            break;
}
