function mkd --description 'Create a new directory and enter it' --argument dirName
    mkdir -p $dirName
    cd $dirName
end
