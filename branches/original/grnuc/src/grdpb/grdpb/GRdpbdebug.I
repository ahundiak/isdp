/*
Name
        GRdpb$debug

Description
        This method is overridden to dump all the information stored
        in the dpb.

History
        05/01/91:mrm:creation
	01/03/93:Carlos:header
Notes
 Not using the message system intentionally.
Keywords
 dpb, debug, message
*/

class implementation GRdpb;

#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include <stdio.h>

method debug()
{
    int i, j, k, n, sts;
    long *l;
    char c[64];
    double *d;
    struct GRelclass *p;
    struct GRdpbdata *dpb;

    dpb = (struct GRdpbdata *)me->data;
    printf("GRdpb: version %d\n", dpb->version);
    printf("dbtype = %s\n", dpb->dbtype);
    printf("model mode = %d\n", dpb->model_mode);
    printf("projection angle = %d\n", dpb->proj_angle);
    printf("coordsys type = %s\n", dpb->cstype);
    printf("local abs flag = %d\n", (dpb->bflags & DPB_LOCAL_ABS_FLAG)?1:0);
    i = (dpb->bflags & DPB_ARC_DIRECTION) ? 1 : 0;
    printf("arc direction = %d (%s)\n", i, (i) ? "ccw" : "cw");
    printf("apparent flag = %d\n", (dpb->bflags & DPB_APPARENT_FLAG)?1:0);
    printf("bore locate = %d\n", (dpb->bflags & DPB_BORE_LOCATE)?1:0);
    printf("dynamics on = %d\n", (dpb->bflags & DPB_DYNAMICS_ON)?1:0);
    printf("dynamics all windows = %d\n", (dpb->bflags & DPB_DYNAMICS_ALL_WINDOWS)?1:0);
    printf("dynamics copy flag = %d\n", (dpb->bflags & DPB_DYNAMICS_COPY_FLAG)?1:0);
    printf("assoc flag = %d\n", (dpb->bflags & DPB_ASSOCIATIVE_FLAG)?1:0);
    printf("name mode = %d\n", dpb->name_mode);
    printf("layer = %d\n", dpb->layer);
    printf("object props = %#x\n", dpb->objprops);
    printf("locate layers =\n");
    for (l = dpb->locate_layers, i = 0; i < 32; i += 8)
        printf("\t%08x %08x %08x %08x %08x %08x %08x %08x\n",
               l[i], l[i+1], l[i+2], l[i+3], l[i+4], l[i+5], l[i+6], l[i+7]);
    printf("hidden surface symbology = %d\n", dpb->hidsurfsym);
    printf("locate props = %#x\n", dpb->locprops);
    printf("edge pattern delta = %g\n", dpb->epdelta);
    printf("area pattern deltas = %g, %g\n", dpb->apdelta[0], dpb->apdelta[1]);
    printf("angle = %g\n", dpb->angle);
    printf("dit tol = %g\n", dpb->dit_tol);
    printf("chord height tol = %g\n", dpb->cht);
    printf("offset tol = %g\n", dpb->offset_tol);
    printf("arclength tol = %g\n", dpb->arc_tol);
    printf("basis tol = %g\n", dpb->bastol);
    printf("maximum step size = %g\n", dpb->maxstep);
    printf("xhatch spacing = %g\n", dpb->xhatch_spacing);
    printf("xhatch angle = %g\n", dpb->xhatch_angle);
    printf("scale = %g %g %g\n", dpb->scale[0], dpb->scale[1], dpb->scale[2]);
    printf("textsymb.Active_font = %d\n", dpb->textsym.Active_font);
    printf("\t.Active_fraction_font = %d\n", dpb->textsym.Active_fraction_font);
    printf("\t.Active_symbol_font = %d\n", dpb->textsym.Active_symbol_font);
    printf("\t.Active_ascii_font = %d\n", dpb->textsym.Active_ascii_font);
    printf("\t.Active_just = %d\n", dpb->textsym.Active_just);
    printf("\t.Active_width = %g\n", dpb->textsym.Active_width);
    printf("\t.Active_height = %g\n", dpb->textsym.Active_height);
    printf("\t.Active_charspac = %g\n", dpb->textsym.Active_charspac);
    printf("\t.Active_linespac = %g\n", dpb->textsym.Active_linespac);
    printf("\t.Active_flags = %#x\n", dpb->textsym.Active_flags);
    printf("lastpoint.x = %g\n", dpb->lastpoint.x);
    printf("\t.y = %g\n", dpb->lastpoint.y);
    printf("\t.z = %g\n", dpb->lastpoint.z);
    printf("\t.window = %d\n", dpb->lastpoint.window);
    printf("\t.objid = %d\n", dpb->lastpoint.objid);
    printf("\t.osnum = %d\n", dpb->lastpoint.osnum);
    printf("\t.numb = %d\n", dpb->lastpoint.numb);
    printf("\t.clicks = %d\n", dpb->lastpoint.clicks);
    printf("\t.button_down = %d\n", dpb->lastpoint.button_down);
    printf("module.md_id = %d, %d\n", dpb->module.md_id.osnum, dpb->module.md_id.objid);
    printf("\t.md_env.matrix_type = %d, matrix = \n", dpb->module.md_env.matrix_type);
    for (d = dpb->module.md_env.matrix, i = 0; i < 15; i += 4)
        printf("\t%17.7f%17.7f%17.7f%17.7f\n", d[i], d[i+1], d[i+2], d[i+3]);
    printf("raster.attr_num = %d\n", dpb->raster.attr_num);
    printf("\tauto_def = %d\n", dpb->raster.auto_def);
    printf("\tauto_init = %d\n", dpb->raster.auto_init);
    printf("\trg_props = %d\n", dpb->raster.rg_props);
    printf("\trow_scale = %g\n", dpb->raster.row_scale);
    printf("\tcolumn_scale = %g\n", dpb->raster.column_scale);
    printf("\tcomprast_memory = %d\n", dpb->raster.comprast_memory);
    printf("\tbrush_type = %d\n", dpb->raster.brush_type);
    printf("\tfg = %d\n", dpb->raster.fg);
    printf("\tbg = %d\n", dpb->raster.bg);
    printf("\tfill_mode = %d\n", dpb->raster.fill_mode);
    printf("unit_lock.on_off = %d\n", dpb->unit_lock.on_off);
    printf("\t.round_off = %g\n", dpb->unit_lock.round_off);
    printf("display.color = %u\n", dpb->display.color);
    printf("\t.weight = %u\n", dpb->display.weight);
    printf("\t.style = %u\n", dpb->display.style);
    printf("hesym.color = %d\n", dpb->hesym.color);
    printf("\t.weight = %d\n", dpb->hesym.weight);
    printf("\t.style = %d\n", dpb->hesym.style);
    printf("\t.flags = %#x\n", dpb->hesym.flags);
    if (dpb->version > 0)
    {
        printf("visible_edge_sym.color = %d\n", dpb->visible_edge_sym.color);
        printf("\t.weight = %d\n", dpb->visible_edge_sym.weight);
        printf("\t.style = %d\n", dpb->visible_edge_sym.style);
        printf("\t.flags = %#x\n", dpb->visible_edge_sym.flags);
    }
    k = om$dimension_of (varray = me->classids);
    for (i = 0; i < k; i++)
    {
        sts = om$get_classname (classid = me->classids[i], classname = c);
        if (!(sts & 1)) strcpy (c, "Unknown class");
        printf("classids[%d] = %d\t[%s]\n", i, me->classids[i], c);
    }
    k = om$dimension_of (varray = me->elclass);
    for (i = 0; i < k; i++)
    {
        p = &me->elclass[i];
        p->classlist.p_classes = &me->classids[p->index];
        printf("elclass[%d]:\n", i);
#ifndef BELIEVE_RETURN_CODE
        c[0] = NULL;
#endif
        sts = ex$message (msgname = p->ascii_key, buff = c);
#ifndef BELIEVE_RETURN_CODE
        if (c[0] == NULL)
#else
        if (!(sts & 1))
#endif
            strcpy (c, "Unknown message key");
        printf("\tascii_key = %s\t[%s]\n", p->ascii_key, c);
        printf("\tproperties = %x\n", p->properties);
        printf("\tdepth = %d\n", p->depth);
        printf("\tindex = %d\n", p->index);
        printf("\tclasslist.w_count = %d\n", p->classlist.w_count); 
        printf("\tclasslist.w_flags = %x\n", p->classlist.w_flags);
        for (j = 0; j < (int)p->classlist.w_count && j < 100; j++)
        {
            n = p->classlist.p_classes[j];
            sts = om$get_classname (classid = n, classname = c);
            if (!(sts & 1)) strcpy (c, "Unknown class");
            printf("\tclasslist.p_classes[%d] = %d\t[%s]\n", j, n, c);
        }
    }
    return (OM_S_SUCCESS);
}

method atp_debug()
{
    int i;
    long *l;
    double *d;
    struct GRdpbdata *dpb;

    dpb = (struct GRdpbdata *)me->data;
    fprintf(stderr, "GRdpb: version %d\n", dpb->version);
    fprintf(stderr, "dbtype = %s\n", dpb->dbtype);
    fprintf(stderr, "model mode = %d\n", dpb->model_mode);
    fprintf(stderr, "projection angle = %d\n", dpb->proj_angle);
    fprintf(stderr, "coordsys type = %s\n", dpb->cstype);
    fprintf(stderr, "local abs flag = %d\n", (dpb->bflags & DPB_LOCAL_ABS_FLAG)?1:0);
    i = (dpb->bflags & DPB_ARC_DIRECTION) ? 1 : 0;
    fprintf(stderr, "arc direction = %d (%s)\n", i, (i) ? "ccw" : "cw");
    fprintf(stderr, "apparent flag = %d\n", (dpb->bflags & DPB_APPARENT_FLAG)?1:0);
    fprintf(stderr, "bore locate = %d\n", (dpb->bflags & DPB_BORE_LOCATE)?1:0);
    fprintf(stderr, "dynamics on = %d\n", (dpb->bflags & DPB_DYNAMICS_ON)?1:0);
    fprintf(stderr, "dynamics all windows = %d\n", (dpb->bflags & DPB_DYNAMICS_ALL_WINDOWS)?1:0);
    fprintf(stderr, "dynamics copy flag = %d\n", (dpb->bflags & DPB_DYNAMICS_COPY_FLAG)?1:0);
    fprintf(stderr, "assoc flag = %d\n", (dpb->bflags & DPB_ASSOCIATIVE_FLAG)?1:0);
    fprintf(stderr, "name mode = %d\n", dpb->name_mode);
    fprintf(stderr, "layer = %d\n", dpb->layer);
    fprintf(stderr, "object props = %#x\n", dpb->objprops);
    fprintf(stderr, "locate layers =\n");
    for (l = dpb->locate_layers, i = 0; i < 32; i += 8)
        fprintf(stderr, "\t%08x %08x %08x %08x %08x %08x %08x %08x\n",
               l[i], l[i+1], l[i+2], l[i+3], l[i+4], l[i+5], l[i+6], l[i+7]);
    fprintf(stderr, "hidden surface symbology = %d\n", dpb->hidsurfsym);
    fprintf(stderr, "locate props = %#x\n", dpb->locprops);
    fprintf(stderr, "edge pattern delta = %g\n", dpb->epdelta);
    fprintf(stderr, "area pattern deltas = %g, %g\n", dpb->apdelta[0], dpb->apdelta[1]);
    fprintf(stderr, "angle = %g\n", dpb->angle);
    fprintf(stderr, "dit tol = %g\n", dpb->dit_tol);
    fprintf(stderr, "chord height tol = %g\n", dpb->cht);
    fprintf(stderr, "offset tol = %g\n", dpb->offset_tol);
    fprintf(stderr, "arclength tol = %g\n", dpb->arc_tol);
    fprintf(stderr, "basis tol = %g\n", dpb->bastol);
    fprintf(stderr, "maximum step size = %g\n", dpb->maxstep);
    fprintf(stderr, "xhatch spacing = %g\n", dpb->xhatch_spacing);
    fprintf(stderr, "xhatch angle = %g\n", dpb->xhatch_angle);
    fprintf(stderr, "scale = %g %g %g\n", dpb->scale[0], dpb->scale[1], dpb->scale[2]);
    fprintf(stderr, "textsymb.Active_font = %d\n", dpb->textsym.Active_font);
    fprintf(stderr, "\t.Active_fraction_font = %d\n", dpb->textsym.Active_fraction_font);
    fprintf(stderr, "\t.Active_symbol_font = %d\n", dpb->textsym.Active_symbol_font);
    fprintf(stderr, "\t.Active_ascii_font = %d\n", dpb->textsym.Active_ascii_font);
    fprintf(stderr, "\t.Active_just = %d\n", dpb->textsym.Active_just);
    fprintf(stderr, "\t.Active_width = %g\n", dpb->textsym.Active_width);
    fprintf(stderr, "\t.Active_height = %g\n", dpb->textsym.Active_height);
    fprintf(stderr, "\t.Active_charspac = %g\n", dpb->textsym.Active_charspac);
    fprintf(stderr, "\t.Active_linespac = %g\n", dpb->textsym.Active_linespac);
    fprintf(stderr, "\t.Active_flags = %#x\n", dpb->textsym.Active_flags);
    fprintf(stderr, "lastpoint.x = %g\n", dpb->lastpoint.x);
    fprintf(stderr, "\t.y = %g\n", dpb->lastpoint.y);
    fprintf(stderr, "\t.z = %g\n", dpb->lastpoint.z);
    fprintf(stderr, "\t.window = %d\n", dpb->lastpoint.window);
    fprintf(stderr, "\t.objid = %d\n", dpb->lastpoint.objid);
    fprintf(stderr, "\t.osnum = %d\n", dpb->lastpoint.osnum);
    fprintf(stderr, "\t.numb = %d\n", dpb->lastpoint.numb); 
    fprintf(stderr, "\t.clicks = %d\n", dpb->lastpoint.clicks); 
    fprintf(stderr, "\t.button_down = %d\n", dpb->lastpoint.button_down); 
    fprintf(stderr, "module.md_id = %d, %d\n", dpb->module.md_id.osnum, dpb->module.md_id.objid);
    fprintf(stderr, "\t.md_env.matrix_type = %d, matrix = \n", dpb->module.md_env.matrix_type);
    for (d = dpb->module.md_env.matrix, i = 0; i < 15; i += 4)
        fprintf(stderr, "\t%17.7f%17.7f%17.7f%17.7f\n", d[i], d[i+1], d[i+2], d[i+3]);
    fprintf(stderr, "raster.attr_num = %d\n", dpb->raster.attr_num);
    fprintf(stderr, "\tauto_def = %d\n", dpb->raster.auto_def);
    fprintf(stderr, "\tauto_init = %d\n", dpb->raster.auto_init);
    fprintf(stderr, "\trg_props = %d\n", dpb->raster.rg_props);
    fprintf(stderr, "\trow_scale = %g\n", dpb->raster.row_scale);
    fprintf(stderr, "\tcolumn_scale = %g\n", dpb->raster.column_scale);
    fprintf(stderr, "\tcomprast_memory = %d\n", dpb->raster.comprast_memory);
    fprintf(stderr, "\tbrush_type = %d\n", dpb->raster.brush_type);
    fprintf(stderr, "\tfg = %d\n", dpb->raster.fg);
    fprintf(stderr, "\tbg = %d\n", dpb->raster.bg);
    fprintf(stderr, "\tfill_mode = %d\n", dpb->raster.fill_mode);
    fprintf(stderr, "unit_lock.on_off = %d\n", dpb->unit_lock.on_off);
    fprintf(stderr, "\t.round_off = %g\n", dpb->unit_lock.round_off);
    fprintf(stderr, "display.color = %u\n", dpb->display.color);
    fprintf(stderr, "\t.weight = %u\n", dpb->display.weight);
    fprintf(stderr, "\t.style = %u\n", dpb->display.style);
    fprintf(stderr, "hidden edge display on = %d\n", 
	(dpb->bflags & DPB_HIDDEN_SO_ON) ? 1 : 0 );
    fprintf(stderr, "hesym.color = %d\n", dpb->hesym.color);
    fprintf(stderr, "\t.weight = %d\n", dpb->hesym.weight);
    fprintf(stderr, "\t.style = %d\n", dpb->hesym.style);
    fprintf(stderr, "\t.flags = %#x\n", dpb->hesym.flags);
    if (dpb->version > 0)
    {
        fprintf(stderr, "visible_edge_sym.color = %d\n", dpb->visible_edge_sym.color);
        fprintf(stderr, "\t.weight = %d\n", dpb->visible_edge_sym.weight);
        fprintf(stderr, "\t.style = %d\n", dpb->visible_edge_sym.style);
        fprintf(stderr, "\t.flags = %#x\n", dpb->visible_edge_sym.flags);
    }
    return (OM_S_SUCCESS);
}
end implementation GRdpb;
