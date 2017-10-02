cluster --machine kaki41 --memoire 6000 --duree 1j --execute 'matlab -nodesktop -r "IMtest_RL_Real" ' &
sleep 10s
cluster --machine kaki41 --memoire 6000 --duree 1j --execute 'matlab -nodesktop -r "IMtest_RL_Synt" ' &
sleep 10s
cluster --machine kaki41 --memoire 6000 --duree 1j --execute 'matlab -nodesktop -r "IMtest_RLLS_real" ' &
sleep 10s
cluster --machine kaki41 --memoire 6000 --duree 1j --execute 'matlab -nodesktop -r "IMtest_RLLS_Synt" ' &
sleep 10s