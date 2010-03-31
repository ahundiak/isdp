# ifndef EMSlogic_include
# define EMSlogic_include 1

# ifndef EMSreleased_include
# include "EMSreleased.h"
# endif

# define EMSokay(x)  ((x) & 1)
# define EMSerror(x)  (!((x) & 1))

# ifndef NULL
# define NULL 0
# endif

# ifndef IS
# define IS     ==
# endif
# ifndef ISNT
# define ISNT   !=
# endif
# ifndef AND
# define AND    &&
# endif
# ifndef OR
# define OR     ||
# endif
# ifndef NOT
# define NOT    !
# endif

# ifndef TRUE
# define TRUE  1
# endif
# ifndef FALSE
# define FALSE 0
# endif

# define X 0
# define Y 1
# define Z 2

# define U 0
# define V 1

/* Too many people use this symbols for minima and maxima!
# define MIN 0
# define MAX 1
*/

# define LO 0
# define HI 1

# define forever for (;;)

# endif /* EMSlogic_include */
