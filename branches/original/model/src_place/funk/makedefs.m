#   HISTORY
#
#   02 Feb 1989 jBk Changed definition of TOUCHN to include
#                   mandatory invocation of ksh.
#   07 Apr 1988 jBk Additions and modifications to allow linting
#                   of files. 
#   ?? ??? 198? jBk Genesis.

.SUFFIXES: .I .S .C .c .o .ln

suffix = o

version = 256

model_lib = ${MODEL}/lib
model_src_lib = ${MODEL}/src_lib
model_src_shlib = ${MODEL}/src_shlib
model_etc = ${MODEL}/etc

# CC (after OPP and OMCPP) include path

OPPIPATH = -I${om}/include

TOUCHN = ksh ${model_etc}/bin/${touchdir}/touchn.sh
