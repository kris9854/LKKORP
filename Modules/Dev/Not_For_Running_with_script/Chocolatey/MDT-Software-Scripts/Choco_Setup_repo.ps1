$ChocoRepoURL = 'http://localhost:8081/repository/Choco-Group/'

choco source remove -n chocolatey
# Remove Standard source repo so we only pull from explicit set repositories
choco source remove -n chocolatey -y

# Set the source feed/repositorie to LKKORP-Internal
Choco source add -n 'LKKORP-Internal' -s=http://proget.lkkorp.local/nuget/LKKORP-Internal/ -y


choco install chocolateygui
choco install vscode

#To push to source install vscode + choco extension