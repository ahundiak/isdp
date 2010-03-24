SRC
$(EXNUC)/icob/ceo

INCLUDE
$(EXNUC)/include
$(UMS_INC_PATH)
#if defined (ENV5)
$(FORMS_INC_PATH)
#elif defined (X11)
$(XFORMSDP_INC_PATH)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/spec

SOURCE
action.I
arg_button.I
arg_name.I
delete.I
dynamics.I
error_box.I
execute.I
filter.I
form.I
init.I
msg.I
predicate.I
prompt.I
read_t_file.I
real_execute.I
sleep.I
shove_str.C
status.I
status_disp.I
wakeup.I

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/icob/lib/ceo.o
#elif defined (NT)
ARCHIVE
$(TARGET)/icob/lib/ceo.lib
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

