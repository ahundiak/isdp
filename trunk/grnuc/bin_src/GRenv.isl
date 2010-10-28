# Make sure to enable for ProWorks compiler ("-xO1 -Xc -W0,-xd") OR Forte 6 compiler ("-xCC -Xc")
#
# Dot this file after dotting integ/grnuc.env
#
# Really need to combine the two
#
# Solaris 8
# export COMPOPT="-xO1 -Xa -xCC -W0,-xd"
# export COMPOPT="-xCC -Xc"

export COMPILER="cc"
#export MKDOPT="-DX11 -DNOT_SHARABLE -DINTEL -DSUNOS5 -DLITTLE_ENDIAN -DSYSV -DSYS5"
#export MKDOPT="${MKDOPT} -Di386 -D__i386 -DINGR -DRUN_X=1"
#export MKMKOPT="-DRUN_X -DX11 -DSUNOS5 -Di386 -D__i386 -DLITTLE_ENDIAN -DSYSV -DSYS5 -DNOT_SHARABLE -DINTEL -i ${GRNUC}/Isl.mkmk"
export GRLIB=$GRTARG
export PLATFORMMAKELIB=$GRNUC/islmakelib
export EXNUCMAKELIB=$EXTARG/exnucmakelib
export INGRHOME=${INGRHOME:-/opt/ingr}
export CPUTYPE=isl

# ah - Solaris 10
export COPT="-g"

# Want to replace with ISDP_C_DEFINES after checking
export MKDOPT="-DX11 -DNOT_SHARABLE -DINTEL -DLITTLE_ENDIAN -DSYSV -DSYS5"
export MKDOPT="${MKDOPT} -Di386 -D__i386 -D__i386__ -DINGR -DRUN_X=1"
export MKDOPT="${MKDOPT} -DSVR4 -DSUNOS -DSUNOS5 -DSUNOS58 -DUNIX -D__BUILTIN_VA_ARG_INCR -D__EXTENSIONS__=1"

# -Xc is strict ANSI conformance, compiles most stuff but under Solaris 10
# _STDC_STRICT ends up getting set and messing certain things up
# -Xa is ANSI with K&R extensions
export CC="cc   -xCC -Xa -m32 -Kpic -g -features=no%conststrings"
export COMPOPT="-xCC -Xa -m32 -Kpic -g -features=no%conststrings"

export MKMKOPT="-DRUN_X -DX11 -DSUNOS5 -Di386 -D__i386 -DLITTLE_ENDIAN -DSYSV -DSYS5 -DNOT_SHARABLE -DINTEL -i ${GRNUC}/Isl.mkmk"
export MKMKOPT="${MKMKOPT} -D__BUILTIN_VA_ARG_INC -D__EXTENSIONS__=1"
