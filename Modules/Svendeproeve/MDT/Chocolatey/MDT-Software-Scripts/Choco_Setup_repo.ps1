$ChocoRepoURL = 'http://localhost:8081/repository/Choco-Group/'

choco source remove -n chocolatey
Choco source add -n LKKORP_Proxy -s=http://localhost:8081/repository/Choco-Group/
Choco source add -n LKKORP_Hosted -s=http://localhost:8081/repository/Choco-Hosted/


choco install chocolateygui
choco install vscode

#To push to source install vscode + choco extension