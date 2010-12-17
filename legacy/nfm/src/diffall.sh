Diff_Dirs ()
{
   for dir in  \
\
nfms \
convert          \
nfmtools \
nfmu \
dbtools          \
sc \
filetransfer \
acad \
systools \
acadinc \
fserver \
admin \
nfma \
alpha \
v_nfms \
alter \
nfmd \
verify \
version \
liberr \
wff_x \
libmem \
wfg \
libnet \
workflow \
cfg \
libqui \
libsql \
nfmr \
libtli \
include \
acadinc \
clhtodat \
dattoclh \
initial \
marcomp \
marinc \
nfmcli \
nfmfi \
nfmmonitor \
scpp \
utilities \
cmdtools

do
  echo "diff -lw ./$dir /usr2/nfm352/src/$dir > ./$dir/diff.all ..."
  diff -lw ./$dir /usr2/nfm352/src/$dir > ./$dir/diff.all
done
}

echo "Diff all direcotories"
Diff_Dirs

