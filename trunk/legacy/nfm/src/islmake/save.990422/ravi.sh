echo "Building all executables"
cd $HOME/src/islmake
makeexec.sh 2> execerr.out
echo "Delivering Server"
cd $HOME/src/isldel/deliver_srv
./deliver.isl 2> delser.out
echo "Delivering UI"
cd $HOME/src/isldel/deliver_ui
./deliver.isl 2>delui.out
echo "Delivering DP"
cd $HOME/src/isldel/deliver_dp
./deliver.isl 2>deldp.out
echo "Transfering files to impd02"
cd $HOME
rcp -r intelsol guest@impd02:/usr/guest
