#ifndef _VLA_H
#define _VLA_H  1

#define vla(t)     struct { unsigned int incr; unsigned int dim; t *body;}

#ifndef VLA_C
#define Vdat(v)      ((v).body)
#define Vset(v,d)    ((_vla = (d)-1), _vladim (&(v), sizeof (*Vdat(v))))
#define Vinit(v,i,d) ((v).incr = (i), (v).dim = 0, Vdat(v) = 0, Vset (v,d))
#define Vdim(v,d)    ((_vla = (d)-1) >= (v).dim ? \
                     _vladim (&(v), sizeof (*Vdat(v))) : 0)
#define Vndx(v,i)    (((_vla = (i)) >= (v).dim ? \
                     _vladim (&(v), sizeof (*Vdat(v))) : 0), Vdat(v))[_vla]

extern unsigned int _vla;
extern int          _vladim();
#endif

/*===========================================================================*/
/*			      SUPPORT FOR OLD WAY			     */
/*===========================================================================*/

#include <malloc.h>

#define  vlainit(name,idim,inc) {\
\
(name).dim  = idim;\
(name).incr = inc;\
(name).body = malloc (idim * sizeof (*(name).body)); }

#define  vlafree(name)  free ((name).body)

#define  vlai(name,index) (\
\
(_vla = (unsigned int)(index)) < (name).dim ?\
(name).body :\
((name).body = realloc ((name).body, ((name).dim += (((_vla) - (name).dim + (name).incr) / (name).incr * (name).incr)) * sizeof (*(name).body)))) [_vla]

/*===========================================================================*/
/*===========================================================================*/

#endif
