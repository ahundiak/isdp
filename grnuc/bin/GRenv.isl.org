# Make sure to enable for ProWorks compiler ("-xO1 -Xc -W0,-xd") OR Forte 6 compiler ("-xCC -Xc")
export COMPOPT="-xO1 -Xc -xCC -W0,-xd"
# export COMPOPT="-xCC -Xc"

export COMPILER="cc"
export MKDOPT="-DX11 -DNOT_SHARABLE -DINTEL -DSUNOS5 -DLITTLE_ENDIAN -DSYSV -DSYS5"
export MKDOPT="${MKDOPT} -Di386 -D__i386 -DINGR -DRUN_X=1"
export MKMKOPT="-DRUN_X -DX11 -DSUNOS5 -Di386 -D__i386 -DLITTLE_ENDIAN -DSYSV -DSYS5 -DNOT_SHARABLE -DINTEL -i ${GRNUC}/Isl.mkmk"
export GRLIB=$GRTARG
export PLATFORMMAKELIB=$GRNUC/islmakelib
export EXNUCMAKELIB=$EXTARG/exnucmakelib
export INGRHOME=${INGRHOME:-/opt/ingr}
export CPUTYPE=isl
