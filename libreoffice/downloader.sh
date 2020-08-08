#!/bin/bash
echo "File listing";
echo $(ls);
timestamp=$(curl "http://download.documentfoundation.org/TIMESTAMP");
if [[ $(< TIMESTAMP) != "$timestamp" ]]; then
        echo "$timestamp" > oss_rss/libreoffice/TIMESTAMP;
	N=15;
	(
	while read -r url;
	do
		((i=i%N)); ((i++==0)) && wait
		(if ! curl -s --head  --request GET "${url}" | grep "404 Not Found" &> /dev/null
		then
			echo "$url"
		fi &)
	done < <(rsync --dry-run -avz rsync://rsync.documentfoundation.org/tdf-pub/ | awk '{print $5}' | sed -e 's/.*/http:\/\/download.documentfoundation.org\/&\.torrent/')
	) > oss_rss/libreoffice/all_torrent_links.txt;
	sed 's/\.torrent/\.magnet/g' oss_rss/libreoffice/all_torrent_links.txt > oss_rss/libreoffice/all_magnet_links.txt;

	# html links
	sed 's/.*/\<a href=\"&\"\>&\<\/a\>/' oss_rss/libreoffice/all_torrent_links.txt > oss_rss/libreoffice/all_torrent_links.html;
	sed 's/.*/\<a href=\"&\"\>&\<\/a\>/' oss_rss/libreoffice/all_magnet_links.txt > oss_rss/libreoffice/all_magnet_links.html;

	# all rss links
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><rss version=\"2.0\"><channel><title>LibreOffice links</title><link></link><description></description>" | tee oss_rss/libreoffice/all_torrent_links.rss oss_rss/libreoffice/all_magnet_links.rss > /dev/null;

	while read -r url; do
		echo "$url" | sed 's/.*/\<item\>\<title\>&\<\/title\>\<link\>&\<\/link\>\<description\>\<\/description>\<\/item\>/' >> oss_rss/libreoffice/all_magnet_links.rss;
	done < oss_rss/libreoffice/all_magnet_links.txt;
	echo '</channel></rss>' >> oss_rss/libreoffice/all_magnet_links.rss;

	while read -r url; do
		echo "$url" | sed 's/.*/\<item\>\<title\>&\<\/title\>\<link\>&\<\/link\>\<description\>\<\/description>\<\/item\>/' >> oss_rss/libreoffice/all_torrent_links.rss;
	done < oss_rss/libreoffice/all_torrent_links.txt;
	echo '</channel></rss>' >> oss_rss/libreoffice/all_torrent_links.rss;
fi
