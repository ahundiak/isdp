#include <exsysdep.h>
#ifdef X11
#ifdef OPENGL
#include "wl.h"
#endif
#endif

GPEnter()
{
	printf("EXNUCX stub:\t");
	printf("GPEnter is not implemented\n");
	printf("first referenced in (igestartup.o)\n");
	return 1;
}
GPExit()
{
	printf("EXNUCX stub:\t");
	printf("GPExit is not implemented\n");
	printf("first referenced in (igestartup.o)\n");
	return 1;
}

IGEclosest_match_colors()
{
        printf("EXNUCX stub:\t");
        printf("IGEclosest_match_colors is not implemented\n");
	return 0;
}
#ifdef IRIX
Help_kill()
{
	printf("EXNUCX stub:\t");
	printf("Help_kill is not implemented\n");
	return 0;
}
Help_active()
{
	printf("EXNUCX stub:\t");
	printf("Help_active is not implemented\n");
	return 0;
}
Help_remove()
{
	printf("EXNUCX stub:\t");
	printf("Help_remove is not implemented\n");
	return 0;
}
Help_toc()
{
	printf("EXNUCX stub:\t");
	printf("Help_toc is not implemented\n");
	return 0;
}
Help_set_Xdisplay()
{
	printf("EXNUCX stub:\t");
	printf("Help_set_Xdisplay is not implemented\n");
	return 0;
}
Help_origin()
{
	printf("EXNUCX stub:\t");
	printf("Help_origin is not implemented\n");
	return 0;
}
Help_document()
{
	printf("EXNUCX stub:\t");
	printf("Help_document is not implemented\n");
	return 0;
}
Help_topic()
{
	printf("EXNUCX stub:\t");
	printf("Help_topic is not implemented\n");
	return 0;
}
#endif
#ifdef X11
#ifdef OPENGL
int DPglx_choose_visual( struct WLcontext_info *context,
                         XVisualInfo *avail_visuals,
                         int num_avail,
                         int *chosen_index )
{
	printf("EXNUCX stub:\t");
	printf("DPglx_choose_visual is not implemented\n");
	return 0;
}
#endif
#endif

