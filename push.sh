cwd=`dirname $0`
. ${cwd}/variables.sh

function push () {
	local path=${1}
	shift
	local excludes=($@)
	local exclude=;
	
	for i in ${excludes[@]}
	do
		exclude="--exclude ${i} ${exclude}"
	done

	rsync -e "ssh -p ${SSH_PORT}" -rlptvz --delete --exclude .git/ --exclude .gitignore --exclude .sass-cache/ --exclude bin/ --exclude 'tmp/*' --exclude wp-config.php --exclude node_modules/ --exclude .DS_Store --exclude '*.sql' ${exclude} --exclude demo/ ${LOCAL_WORDPRESS_PATH}${path} ${SSH_USER}@${SSH_HOST}:${WORDPRESS_PATH}${path}
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
	echo "===== Search replace =========="
	wp search-replace ${LOCAL_URL} ${URL} > /dev/null

	echo "===== Local database export =========="
	wp db export local.sql
	wp search-replace ${URL} ${LOCAL_URL} > /dev/null

	echo "===== Import to temote database =========="
	ssh ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} "mysql --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" ${DB_NAME}" < local.sql
}

if [ "$a" = 1 ] ; then
	push /
	exportdb
fi

if [ "${w}" = 1 ] ; then
	echo "===== Upload WordPress core ====="
	excludes=(wp-content)
	push / ${excludes[@]}
fi

if [ "${d}" = 1 ] ; then
	exportdb
fi

if [ "${t}" = 1 ] ; then
	echo "===== Upload themes ====="
	push /wp-content/themes/
fi

if [ "${p}" = 1 ] ; then
	echo "===== Upload plugins ====="
	push /wp-content/plugins/
fi

if [ "${u}" = 1 ] ; then
	echo "===== Upload uploads ====="
	push /wp-content/uploads/
fi
