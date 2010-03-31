#ifndef GRaxhatch_h
#define GRaxhatch_h 1

#define GR_axhatch_elem 0x1

struct GRaxhatch_info
{
    IGRdouble             xhatch_spacing;
    IGRdouble             xhatch_angle;
    IGRpoint              origin;
    struct GRxhatchpat    pattern_def;
    struct GRid           window_grid;
    IGRshort              xhatch_color;
};

#endif
