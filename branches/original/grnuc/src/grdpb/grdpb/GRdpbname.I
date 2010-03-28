/*
Name
        GRdpbname

Description
        This file contains the methods GRgetname and GRputname for the
        dpb.  These methods are used to maintain the lists used to
        determine locatablity based on classlists.

History
        rc      ??/??/??    creation
        mrm     10/25/90    removed references to name_tab, changed arglists
*/

class implementation GRdpb;

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ex.h"
#include "grdpbdef.h"
#include "dpdef.h"
#include "dp.h"

method GRgetname(IGRlong *msg; struct var_list *vlist)
{
    IGRint i, j, k, size;
    IGRlong *layer;
    struct GRelclass_f *elclass_f;

    while (vlist->var != END_PARAM)
    {
        *msg = 0;
        switch (vlist->var)
        {
          case DPB_GET_LAYER:   /* return layers */
            layer = (IGRlong *) vlist->var_ptr;
            for (j = 0; j < 32; j++) layer[j] = me->layer[j];
            break;

          case DPB_NUMBER_CLASSES:  /* return number of GRelclass'es stored */
            *((IGRint *)(vlist->var_ptr)) = OM_DIMENSION_OF (me->elclass);
            *msg = 1;
            break;

          case DPB_GET_CLASSES: /* return all GRelclass'es (as GRelclass_f) */
            k = om$dimension_of (varray = me->elclass);
            elclass_f = (struct GRelclass_f *) vlist->var_ptr;
            for (j = 0; j < k; j++)
            {
                strcpy (elclass_f[j].ascii_key, me->elclass[j].ascii_key);
                elclass_f[j].properties = me->elclass[j].properties;
                elclass_f[j].depth = me->elclass[j].depth;
            }
            break;

          case DPB_PROPERTIES:  /* return properties of a specified entry */
            elclass_f = (struct GRelclass_f *) vlist->var_ptr;
            elclass_f->properties = 0;
            elclass_f->depth = 0;
            *msg = 0;
            size = OM_DIMENSION_OF (me->elclass);
            for (i = 0; i < size; i++)
            {
                if (!strncmp (elclass_f->ascii_key, me->elclass[i].ascii_key,
                              DPB_NAME_LENGTH))
                {
                    *msg = 1;
                    elclass_f->properties = me->elclass[i].properties;
                    elclass_f->depth = me->elclass[i].depth;
                    break;
                }
            }
            break;
        }
        vlist++;
    }
    return (OM_S_SUCCESS);
}

method GRputname(IGRlong *msg; struct var_list *vlist)
{
    IGRint i, j, k, n, size, size1, found, index, depth;
    IGRlong *layer;
    IGRchar *c;
    struct GRelclass *p = NULL;
    struct GRelclass_a *elclass;
    struct GRelclass_f *elclass_f;

    *msg = 1;

    while (vlist->var != END_PARAM)
    {
        switch (vlist->var)
        {
          case DPB_ADD_CLASSLIST:   /* add a GRelclass to the list */

            elclass = ((struct GRelclass_a *)(vlist->var_ptr));

            if (strlen (elclass->ascii_key) >= DPB_NAME_LENGTH)
            {
                /* the entry has an invalid key, cannot add it to the list */

                *msg = 0;
		break;
            }

            /* make sure entry is marked as valid */

            elclass->properties |= DPB_ACTIVE_ENTRY;

            /* check whether the entry already exists */

            found = FALSE;
            for (k = 0; k < om$dimension_of (varray = me->elclass); k++)
            {
                if (!strncmp (elclass->ascii_key, me->elclass[k].ascii_key,
                              DPB_NAME_LENGTH))
                {
                    found = TRUE;
                    j = me->elclass[k].index;
                    if (elclass->classlist->w_count <=
                        me->elclass[k].classlist.w_count)
                    {
                        for (i = j, n = 0; 
                             i < j + (IGRint)elclass->classlist->w_count;
                             i++, n++)
                        {
                            /* update the classids */

                            me->classids[i] = elclass->classlist->p_classes[n];
                        }
                    }
                    else
                    {
                        // "Oh my, the classlist has grown!"

                        // TR119221144 - I/DESIGN added some stuff without
                        // specifying the actual classids.  When they tried to
                        // fix that, it uncovered a weakness here, in that the
                        // code did not handle increasing the number of
                        // classids in the list, and in fact would overwrite
                        // other entries in the list.  Whoops.  This should
                        // take care of that problem.

                        // Wipe the old classid entries
                        for (i = j;
                             i < j + (IGRint)me->elclass[k].classlist.w_count;
                             i++)
                            me->classids[i] = 0;

                        // Add the new classids
                        size = om$dimension_of(varray = me->classids);
                        size1 = size + elclass->classlist->w_count;
                        om$vla_set_dimension(varray = me->classids,
                                             size = size1);
                        me->elclass[k].index = size;
                        for (j = 0; size < size1; size++, j++)
                            me->classids[size] = 
                                elclass->classlist->p_classes[j];
                        me->elclass[k].classlist.w_count = 
                            elclass->classlist->w_count;
                    }
                    me->elclass[k].classlist.w_flags = 
                        elclass->classlist->w_flags;
                    break;
                }
            }

            if (!found) /* add the entry to the list */
            {
                size = index = om$dimension_of (varray = me->classids);
                size1 = index + elclass->classlist->w_count;

                /* set the classids array size */

                om$vla_set_dimension (varray = me->classids, size = size1);

                /* copy the classids into instance data */

                for (j = 0; size < size1; size++, j++)
                {
                    me->classids[size] = elclass->classlist->p_classes[j];
                }
                
                /* increment the eligible class list array size */

                size = om$dimension_of (varray = me->elclass) + 1;

                om$vla_set_dimension (varray = me->elclass, size = size);

                /* insert the data */

                if (elclass->owner_key == NULL)
                {
                    /* no owner, so add the element to the end of the list */

                    p = &me->elclass[size - 1];
                    p->depth = 0;
                }
                else
		{
                    /* search for the owner */

                    for (i = 0; i < size - 1; i++)
		    {
                        c = me->elclass[i].ascii_key;
#ifdef OLDWAY
                        if (!(strncmp (elclass->owner_key,
                                       me->elclass[i].ascii_key, 
                                       DPB_NAME_LENGTH)))
#else
                        if (!(strcmp (elclass->owner_key, c)))
#endif
			{
                            /* found owner, so set depth */

                            found = TRUE;
                            depth = me->elclass[i].depth + 1;

                            /* scan past existing components */

                            n = me->elclass[i].depth;
                            while ((++i < (size - 1)) && 
                                   me->elclass[i].depth > n);

                            /* move the rest of the list down to make room */

                            for (j = size - 1; j > i; j--)
			    {
                                me->elclass[j] = me->elclass[j - 1];
                            }

                            /* insert the data in the empty slot */

                            p = &me->elclass[i];
                            p->depth = depth;
                            break;
                        }
                    }

                    if (p == NULL)
                    {
                        /* couldn't find the owner, so just add to the end */

                        p = &me->elclass[size - 1];
                        p->depth = 0;
                    }
                }

                /* fill in the rest of the data */

                strcpy (p->ascii_key, elclass->ascii_key);
                p->properties = elclass->properties;
                p->index = index;
                p->classlist = *elclass->classlist;
            }
            break;

          case DPB_SET_PROPERTIES:  /* set properties in ALL GRelclass'es */
            size = om$dimension_of (varray = me->elclass);
            elclass_f = (struct GRelclass_f *)(vlist->var_ptr);
            for (j = 0; j < size; j++)
            {
                me->elclass[j].properties = elclass_f[j].properties;
            }
            break;

          case DPB_PROPERTIES: /* change a single GRelclass's property */
            elclass_f = (struct GRelclass_f *) vlist->var_ptr;
            *msg = 0;
            size = OM_DIMENSION_OF (me->elclass);
            for (i = 0; i < size; i++)
            {
                if (!strncmp (elclass_f->ascii_key, me->elclass[i].ascii_key,
                              DPB_NAME_LENGTH))
                {
                    *msg = 1;
                    me->elclass[i].properties = elclass_f->properties;
                    break;
                }
            }
            break;

          case DPB_SET_LAYER: /* set layers */
            layer = (IGRlong *)vlist->var_ptr;
            for (j = 0; j < 32; j++) me->layer[j] = layer[j];
            *msg = 1;
            break;
        }
        vlist++;
    }
    return (OM_S_SUCCESS);
}
end implementation GRdpb;

