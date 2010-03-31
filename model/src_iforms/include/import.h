/* These defines along with the init.s  	*/
/* make it possible to make a shared library	*/
/* without re-compiling all the source		*/

#define _ctype (*libforms__ctype)
#define _iob   (*libforms__iob)
#define errno  (*libforms_errno)
