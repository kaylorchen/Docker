#include <unistd.h>
#include <stdio.h>
#include <sys/mount.h>

int main() {
    if (umount("/sys/fs/cgroup") < 0) {
        perror("Unable to umount /sys/fs/cgroup");
        return -1;
    }

    const char * prog = "/lib/systemd/systemd";
    char * args[] = {"/lib/systemd/systemd", nullptr};
    if (execv(prog, args) < 0) {
        perror("Unable to exec /lib/systemd/systemd");
        return -1;
    }

    return 0;
}

