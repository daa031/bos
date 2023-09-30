while IFS=: read login pas uid geg name e
do
	printf "%-12s %s \n" $login $name
done <pswd
