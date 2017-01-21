# bash-wp-deply

## Get started
```
$ git clone https://github.com/inc2734/bash-wp-deploy.git
$ cd bash-wp-deploy
$ cp config-sample.json config.json
$ vi config.json
```

## Downlods
### All files and database
```
$ ./pull.sh -e production -a
```

### WordPress Core
```
$ ./pull.sh -e production -w
```

### The themes directory
```
$ ./pull.sh -e production -t
```

### The plugins directory
```
$ ./pull.sh -e production -p
```

### The uplaods directory
```
$ ./pull.sh -e production -u
```

### Database
```
$ ./pull.sh -e production -d
```

## Uploads
### All files and database
```
$ ./push.sh -e production -a
```

### WordPress Core
```
$ ./push.sh -e production -w
```

### The themes directory
```
$ ./push.sh -e production -t
```

### The plugins directory
```
$ ./push.sh -e production -p
```

### The uplaods directory
```
$ ./push.sh -e production -u
```

### Database
```
$ ./push.sh -e production -d
```
