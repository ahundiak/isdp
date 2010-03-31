EXEC
$(MDTARG)/bin/load_mf.x

CC
acc -knr

COPT 
-ga

SRC
$(MODEL)/hplot/src/load

SOURCE
color_table.c
curve_elem.c
depth_cues.c
edge_elem.c
get_bound.c
get_doubles.c
get_pairs.c
get_points.c
get_pts_arr.c
get_rgb.c
get_run.c
get_s_dbl.c
get_soos.c
get_token.c
header.c
hidden.c
light_source.c
line_elem.c
main.c
parser.c
rendering.c
rotation.c
set_color.c
surf_elem.c
translucency.c
user_line.c
view.c

LINKLIB
$(MDTARG)/hplot/src/hplot/HPdload.o
/usr/lib/c100/libxc.a
/usr/lib/libix.a
/usr/lib/libUMS.a

INCLUDE
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
