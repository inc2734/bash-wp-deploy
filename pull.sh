cwd=`dirname $0`
. ${cwd}/variables.sh

function pull () {
	local path=${1}
	shift
	local excludes=($@)
	local exclude=;
	
	for i in ${excludes[@]}
	do
		exclude="--exclude ${i} ${exclude}"
	done

	rsync -e "ssh -p ${SSH_PORT}" -rlptvz --delete --exclude .git/ --exclude .gitignore --exclude .sass-cache/ --exclude bin/ --exclude 'tmp/*' --exclude wp-config.php --exclude node_modules/ --exclude .DS_Store --exclude '*.sql' --exclude '.ht*' --exclude '*.log' ${exclude} --exclude demo/ ${SSH_USER}@${SSH_HOST}:${WORDPRESS_PATH}${path} ${LOCAL_WORDPRESS_PATH}${path}
}

while getopts awdtpue: opt
do
	case $opt in
		a) a=1
			;;
		w) w=1
			;;
		d) d=1
			;;
		t) t=1
			;;
		p) p=1
			;;
		u) u=1
			;;
		e) e=1
			environment=$OPTARG
			;;
	esac
done

function exportdb () {
	cd ${LOCAL_WORDPRESS_PATH}
	
	echo "===== Remote database export ====="
	ssh ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} "mysqldump --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" > remote.sql

	echo "===== Import to local database ====="
	wp db import remote.sql
	wp search-replace ${URL} ${LOCAL_URL} > /dev/null
}

if [ "$a" = 1 ] ; then
	pull /
	exportdb
fi

if [ "${w}" = 1 ] ; then
	echo "===== Download WordPress core ====="
	excludes=(wp-content)
	pull / ${excludes[@]}
fi

if [ "${d}" = 1 ] ; then
	exportdb
fi

if [ "${t}" = 1 ] ; then
	echo "===== Download themes ====="
	pull /wp-content/themes/
fi

if [ "${p}" = 1 ] ; then
	echo "===== Download plugins ====="
	pull /wp-content/plugins/
fi

if [ "${u}" = 1 ] ; then
	echo "===== Download uploads ====="
	pull /wp-content/uploads/
fi
