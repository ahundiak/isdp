class implementation COplytext;



#include     "grdpbmacros.h"
#include     "dpdef.h"
#include     "dpmacros.h"
#include     "godef.h"
#include     "execmsg.h"
#include     "grmessage.h"
#include     "growner.h"
#include     "bsvalues.h"

#define NUM_OBJ_A 50
#define NUM_STRK_DBLS 9000
#define NUM_STRK_PTS 3000
#define INC_STRK_PTS 1500

from GRvg import GRgetgeom;
from GRtext import GRgettxattr;
from GRgraphics import GRaltconstruct;


#define _strt_state 0

method cvt_text ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    struct IGRlbsys lbsys;
    struct IGResintx txt_ele_info;
    struct IGRdisplay display;
    struct IGRestx text_attr;
    IGRshort text_lng;
    IGRuchar *text_string;
    IGRlong which_error;
    IGRlong ret_bytes;
    struct var_list var_list[5];
    IGRdouble strk_buf[NUM_STRK_DBLS];
    IGRdouble *ptr_strk_buf;
    IGRdouble *sav_ptr_buf;
    IGRdouble *start_pt;
    IGRint num_points;
    IGRint alloc_mem_pts = NUM_STRK_PTS;
    IGRint tot_num_pts;
    IGRint num_pts;
    struct GRobj_env obj_env[NUM_OBJ_A];
    struct GRobj_env *p_obj;
    struct GRobj_env *sav_p_obj;
    IGRint num_obj;
    IGRint array_size;
    IGRint malloc_size;
    IGRint win_no;
    struct DPfnt_os_tbl *fnt_os_ptr;
    IGRint gpipe_id;
    IGRint gragad_flags;
    IGRchar malc_buf=0;
    IGRchar nostrokes;
    IGRint count=0; /* count the doubles as I increment looking for disconnect */
    IGRlong siz_buf;
    IGRshort active_layer;
    struct GRvg_construct arglist;
    struct IGRpolyline polyln;
    IGRboolean ststf;
    IGRint index;
    GRspacenum txt_os;
    GRobjid txt_id;
    struct GRid poly_txt_id;

    siz_buf = sizeof(IGRshort);

    gr$get_active_level( msg= &msg, sizbuf= &siz_buf, buffer= &active_layer,
				    nret= &ret_bytes);

    siz_buf = sizeof(struct IGRdisplay);

    gr$get_active_display( msg= &msg, sizbuf= &siz_buf, buffer= &display, 
				    nret= &ret_bytes);

    arglist.msg = &msg;
    arglist.newflag = 0;
    arglist.level = active_layer;
    arglist.properties =  GRIS_DISPLAYABLE | GRIS_LOCATABLE;
    arglist.display = &display;
    arglist.name = NULL;
    arglist.class_attr = 0;

    /* style must be solid 0 */

    display.style = 0;

    p_obj = obj_env;
    ptr_strk_buf = strk_buf;

    var_list[0].var = WIN_NO;
    var_list[0].var_ptr = (IGRchar *) &win_no;
    var_list[0].num_bytes = sizeof (IGRint);
    var_list[0].bytes_returned = &ret_bytes;

    var_list[1].var = GPIPE_ID;
    var_list[1].var_ptr = (IGRchar *) &gpipe_id;
    var_list[1].num_bytes = sizeof (IGRint);
    var_list[1].bytes_returned = &ret_bytes;

    var_list[2].var = FONT_OS_PTR;
    var_list[2].var_ptr = (IGRchar *) &fnt_os_ptr;
    var_list[2].num_bytes = 4;
    var_list[2].bytes_returned = &ret_bytes;

    var_list[3].var = GRAGAD_FLAGS;
    var_list[3].var_ptr = (IGRchar *) &gragad_flags;
    var_list[3].num_bytes = sizeof (IGRint);
    var_list[3].bytes_returned = &ret_bytes;

    var_list[4].var = END_PARAM;

    status = dp$inq_set_gragad(msg = &msg,
                               osnum = me->event1.event.button.osnum, 
    		               gragad_objid = me->event1.event.button.objid,
		               which_error= &which_error,
		               var_list= var_list);

    if(!(status & 1))
    {
	    me->ret= status;
	    om$report_error(sts = status);
    }

    status = gr$gsremove_fence (msg = &msg, p_chanselect = &me->located_chansel);

    if(!(status & 1))
    {
	    me->ret= status;
	    om$report_error(sts = status);
    }
    status = gr$gsinqcount (msg = &msg, count = &num_obj, 
				p_chanselect = &me->located_chansel);
    if(!(status & 1))
    {
	om$report_error(sts = status);
    }

    if (num_obj > NUM_OBJ_A)
    {
	array_size = (sizeof (struct GRobj_env) * num_obj);
	p_obj = (struct GRobj_env *)om$malloc (size = array_size);
    }
    else
    {
	array_size = sizeof (struct GRobj_env) * NUM_OBJ_A;
    }
    sav_p_obj = p_obj;
    status = gr$gsget_objects (msg = &msg,array = p_obj, size = array_size, 
		    count = &num_obj,p_chanselect = &me->located_chansel);
    if(!(status & 1))
    {
	om$report_error(sts = status);
    }

    arglist.env_info = &obj_env[0].mod_env;

    /* for loop handles when fence finds more than one text string */

    for (index=0; index < num_obj; index++)
    {

	num_points = alloc_mem_pts;
	tot_num_pts = 0;
	nostrokes = 1;
       txt_id = p_obj->obj_id.objid;
       txt_os = p_obj->obj_id.osnum;
     
	status = om$send( msg = message GRtext.GRgetgeom( &msg, 
			&obj_env[0].mod_env.md_env.matrix_type,
			obj_env[0].mod_env.md_env.matrix,
	    (IGRchar *) &lbsys),
	    targetid = txt_id,
	    targetos = txt_os );

	if(!(status & 1))
	{
		me->ret= status;
		om$report_error(sts = status);
	}

	status = om$send( msg = message GRtext.GRgettxattr( &msg, 
			    &text_attr,&text_lng,&text_string ),
	    targetid = txt_id,
	    targetos = txt_os );
	if(!(status & 1))
	{
		me->ret= status;
		om$report_error(sts = status);
	}

	txt_ele_info.font_id = txt_os;
	txt_ele_info.flags = 0;
	txt_ele_info.prev_font = text_attr.font;
	txt_ele_info.estx = &text_attr;
	txt_ele_info.text_string = (IGRchar *)text_string;

	while (nostrokes)
	{
	    ststf = DPtxstrk(&msg,&lbsys,&txt_ele_info,&display,win_no,
				    gpipe_id,fnt_os_ptr,gragad_flags,
 				    0,1.0,0,ptr_strk_buf,&num_points);
	    if (ststf == FALSE)
	    {
		num_points = alloc_mem_pts + INC_STRK_PTS;
		alloc_mem_pts = num_points;
		if(malc_buf)
		{
		    om$dealloc(ptr = ptr_strk_buf);
		}
		malc_buf = 1;
		malloc_size = (sizeof(IGRdouble) * num_points * 3.0);
		ptr_strk_buf = (IGRdouble *) om$malloc(size = malloc_size);
		if (ptr_strk_buf == NULL)
		{
			printf("\nerror too much memory\n");
			goto fini;
		}
	    }
	    else
	    {
		nostrokes = 0;
	    }
	} /* close for while */
	om$dealloc(ptr = text_string);
	sav_ptr_buf = ptr_strk_buf;
	while ( tot_num_pts < num_points )
	{
	    start_pt = ptr_strk_buf;
	    while ( *ptr_strk_buf != MAXDOUBLE)
	    {
		    ptr_strk_buf = ptr_strk_buf + 3;
		    count = count + 3;
	    }
	    num_pts = (count) / 3;
	    tot_num_pts = tot_num_pts + num_pts + 1;

	    polyln.num_points = num_pts;
	    polyln.points = start_pt;

	    arglist.geometry = (IGRchar *) &polyln;

	    status = om$construct ( classname ="GR3dlinestr",
				    osnum = txt_os, 
				p_objid = &poly_txt_id.objid, 
			msg = message GRgraphics.GRaltconstruct(&arglist));
	    if(!(status & 1))
	    {
		    printf("\n construct line\n");
		    me->ret= status;
		    om$report_error(sts = status);
	    }
	    poly_txt_id.osnum = txt_os;

	    status = dp$display (msg = &msg, mode = GRbd, osnum = txt_os, 
					    oids = &poly_txt_id);

	    if(!(status & 1))
	    {
		    printf("\n display line\n");
		    me->ret= status;
		    om$report_error(sts = status);
	    }
		 /* increment past the disconnect */
	    ptr_strk_buf = ptr_strk_buf + 3;
	    count = 0;
	
	} /* close for while constructing polygons from text string */

	ptr_strk_buf = sav_ptr_buf;
    	p_obj++;

    }/* close for for  */

    if (malc_buf)
    {
	om$dealloc(ptr = ptr_strk_buf);
    }

fini:

    if (num_obj > NUM_OBJ_A )
    {
	om$dealloc(ptr = sav_p_obj);
    }

quit:
  return OM_S_SUCCESS;
}

end implementation COplytext;
