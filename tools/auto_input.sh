#!/bin/bash
# - written by @aonrjp

TYPES=("houshin" "soukatsu")
SECTIONS=("kaikei" "kensui" "soumu" "syogai" "system" "zentai")

for type in ${TYPES[@]}
do
    for section in ${SECTIONS[@]}
    do
        # 所定ディレクトリ以下に含まれるtexファイルを取得してソート
        files=`find src/${type}/${section} -type f -name "*.tex" | sort`
        
        if [ "$1" = "show" ]; then
            # 見つかったtexファイルのパスを出力
            echo "${files}"
        else
            # input文を生成 (シェルによって\\\\が\\となり、正規表現で\\は\を表す)
            doc=`echo "${files}" | sed -e 's/^/\\\\input{/' | sed -e 's/$/}/'`

            # texファイルが発見できなければ虚無を
            if [[ $files == '' ]]; then
                doc=''
            fi

            # 書き込む
            echo "${doc}" > src/${type}/${section}.tex
        fi
    done
done
