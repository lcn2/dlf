# dlf

dnf list fix: convert dnf list output to useful data for programs


# To install

```sh
sudo make install
```


# To use

```
/usr/local/sbin/dlf [-h] [-v level] [-V] [-N] [-d dlf.awk]

    -h          print help message and exit
    -v level    set verbosity level (def level: 0)
    -V          print version string and exit

    -N          do not process anything, just parse arguments (def: process something)

    -d dlf.awk	path to dlf.awk file (def: ./dlf.awk}

NOTE: Some possible use cases:

    dnf list | dlf

    dnf list --available | dlf

    dnf list --updates | dlf

    dnf list --autoremove | dlf

    dnf list --recent | dlf

Exit codes:
     0         all OK
     1         some internal tool exited non-zero
     2         -h and help string printed or -V and version string printed
     3         command line error
     4	       dlf.awk file not found or not readable
     5	       cannot find aek
 >= 10         internal error

dlf version: 1.0.0 2025-03-22
```

**NOTE**: The output of the following to stderr means that no dnf listing was found:

```
\#Warning no_end_of_headers_found
```


# Reporting Security Issues

To report a security issue, please visit "[Reporting Security Issues](https://github.com/lcn2/dlf/security/policy)".
