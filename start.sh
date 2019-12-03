#!/bin/bash
# Description:  A wrapper script used to stop/start another script.

#--------------------------------------
# Define Global Environment Settings:
#--------------------------------------
cvsUsername='NidhiU'
cvsPassword='cvsPassword'
cvsAppName='project1'
gitRepoName='project1'
gitRemoteURL='https://NidhiUdev.azure.com/NidhiU/TestProjectForConversion/_git/project1'
gitPassword='gitPasswordHash'

#--------------------------------------------------------------------------------- 
# Define Files(+ its history) you want to remove from repository in conversion.sh
#--------------------------------------------------------------------------------- 


#--------------------------------------------------
# Script does following:
# 1) Convert cvs to git
# 2) Remove secret files from git using bfg
# 3) Push git repo to git remote using gitRemoteURL
#--------------------------------------------------
./conversion.sh ${cvsUsername} ${cvsPassword} ${cvsAppName} ${gitRepoName} ${gitRemoteURL} 
