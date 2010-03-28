/*
Name
        GRmenunot

Description
        This file contains functions relating to notifying interested parties
        when the bar menu is swapped.

History
        mrm     07/23/92    creation
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
static int nallocated = 0;

/*
Name
        GRregister_swap_menu_callback

Synopsis
        void GRregister_swap_menu_callback(void (*function)())

Description
        This function is used to register a function to be called each time
        the EMS (or application) bar menu is swapped.

        The function will be invoked with the following argument list:

            void function(name, form)
            char *name;    The name of the new bar menu
            Form form;     The new bar menu form
*/

void GRregister_swap_menu_callback(function)
void (*function)();
{
    int i;

    /* make sure memory has been allocated */
    if (list == NULL)
    {
        list = (p_function *)calloc((unsigned)ChunkSize, sizeof(p_function));
        nallocated = ChunkSize;
    }

    /* find an empty slot */
    for (i = 0; i < nallocated; i++)
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
    if (i == nallocated)
    {
        /* allocate another chunk of memory */
        list = (p_function *)realloc(list, 
                                     (sizeof(p_function) * nallocated) +
                                     (sizeof(p_function) * ChunkSize));

        /* NULL out the new slots */
        for (i = nallocated; i < nallocated + ChunkSize; i++)
            list[i] = NULL;

        /* store the function pointer */
        list[nallocated] = function;

        /* bump the allocation counter */
        nallocated += ChunkSize;
    }
}

/*
Name
        GRswap_menu_notification

Synopsis
        void GRswap_menu_notification(char *name, Form form)
        char *name;    The name of the new bar menu
        Form form;     The new bar menu form

Description
        This function calls all the previously registered functions to
        indicate that a new bar menu has been installed.  This function should
        be called from any code which swaps the bar menu.
*/

void GRswap_menu_notification(name, form)
char *name;
Form form;
{
    int i;

    for (i = 0; i < nallocated; i++)
        if (list[i])
            list[i](name, form);
        else
            break;
}

#ifdef TestThisStuff

/* redefine ChunkSize to 3 or so for a decent test */

void func1() {printf("func1\n");}
void func2() {printf("func2\n");}
void func3() {printf("func3\n");}
void func4() {printf("func4\n");}
void func5() {printf("func5\n");}
void func6() {printf("func6\n");}
void func7() {printf("func7\n");}
void func8() {printf("func8\n");}
void func9() {printf("func9\n");}
void func10() {printf("func10\n");}
void func11() {printf("func11\n");}
void func12() {printf("func12\n");}
void func13() {printf("func13\n");}

main()
{
    GRregister_swap_menu_callback(func1);
    GRregister_swap_menu_callback(func2);
    GRregister_swap_menu_callback(func3);
    GRregister_swap_menu_callback(func4);
    GRregister_swap_menu_callback(func5);
    GRregister_swap_menu_callback(func6);
    GRregister_swap_menu_callback(func7);
    GRregister_swap_menu_callback(func8);
    GRregister_swap_menu_callback(func9);
    GRregister_swap_menu_callback(func10);
    GRregister_swap_menu_callback(func11);
    GRregister_swap_menu_callback(func12);
    GRregister_swap_menu_callback(func13);
    GRswap_menu_notification();
}

#endif
