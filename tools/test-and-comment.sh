#!/bin/bash
t=`mktemp`
OPTION=--log-level=3 make test > $t
status=$?
cat $t
if [ $status -ne 0 ]; then
    message=":x: このままではマージできません！"
elif grep "^\[ERR\]" $t > /dev/null; then
    message=":warning: エラーが残っています。"
else
    message=":white_check_mark: マージしても問題ありません！"
fi

echo $message

if [ $(wc -c < $t) -eq 0 ]; then
    content=$message
else
    content="$(cat <<EOS
$message


\`\`\`
$(cat $t)
\`\`\`
EOS
)"
fi

bitbucket_pr_commnet <<<"$content"
rm $t
exit $status
